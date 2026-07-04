#' Read and parse SMS messages from a Google Sheet
#'
#' Reads raw SMS messages from a Google Sheet column, attempts to fix
#' malformed gauge messages via [fix_sms()], parses valid messages into
#' structured observations via [parse_sms()], and returns a named list
#' with parsed data, malformed rows, and the raw sheet.
#'
#' @param sheet_url `character(1)`. Full URL of the Google Sheet.
#' @param sheet `character(1)` or `integer(1)`. Sheet name or index.
#'   Default is `1` (first sheet).
#' @param col `character(1)` or `integer(1)`. Name or index of the column
#'   containing SMS text. Default is `"sms"`.
#'
#' @return A named list with four elements:
#'   \describe{
#'     \item{`gauge`}{[tibble::tibble()] of parsed rain gauge observations
#'       with columns `eg_gh_id`, `year`, `month`, `day`, `time`,
#'       `eg_el_abbreviation`, `value`, `flag`.}
#'     \item{`agro`}{[tibble::tibble()] of parsed agrometeorological
#'       observations with the same columns.}
#'     \item{`bad`}{[tibble::tibble()] — raw sheet rows flagged for review,
#'       with an extra `bad_reason` column explaining why each row was flagged.
#'       Possible values: `"malformed"`, `"future date"`, `"late submission"`,
#'       `"too old"`.}
#'     \item{`raw`}{[tibble::tibble()] — the full raw sheet as read from
#'       Google Sheets, with list columns coerced to character.}
#'   }
#'   `gauge` and `agro` are empty but correctly typed tibbles if no valid
#'   messages of that format are found.
#'
#' @examples
#' \dontrun{
#' sms_auth()
#' url <- get_sheet_url()
#' result <- read_sms(url)
#' result$gauge
#' result$bad
#' }
#'
#' @seealso [parse_sms()], [fix_sms()], [is_bad_sms()], [sms_auth()],
#'   [get_sheet_url()]
#'
#' @importFrom dplyr mutate across pull
#' @importFrom googlesheets4 read_sheet
#' @importFrom tibble tibble
#'
#' @export
read_sms <- function(sheet_url, sheet = 1, col = "sms") {
  
  .check_auth()
  
  stopifnot(
    is.character(sheet_url), length(sheet_url) == 1, nchar(sheet_url) > 0,
    length(sheet) == 1,
    length(col)   == 1
  )
  
  raw <- tryCatch(
    googlesheets4::read_sheet(sheet_url, sheet = sheet),
    error = function(e) stop("Failed to read sheet: ", conditionMessage(e))
  ) |>
    dplyr::mutate(dplyr::across(
      tidyselect::where(is.list),
      ~ vapply(.x, function(x) as.character(x[[1]]), character(1))
    )) |>
    # Keep only messages from numeric senders (226xxxxxxxxx)
    dplyr::filter(grepl("^\\d{9,12}$", .data$sender))
  
  if (!col %in% names(raw) && !is.numeric(col)) {
    stop("Column '", col, "' not found in sheet. Available columns: ",
         paste(names(raw), collapse = ", "))
  }
  
  texts <- as.character(dplyr::pull(raw, {{ col }}))

  # Parse sent date from raw$date (e.g. "July 4, 2026 at 12:49AM")
  sent_dates <- as.Date(
    sub("\\s+at\\s+.*$", "", raw$date),
    format = "%B %d, %Y"
  )

  empty_tbl <- tibble::tibble(
    eg_gh_id = character(), year = integer(), month = integer(),
    day = integer(), time = character(), eg_el_abbreviation = character(),
    value = numeric(), flag = character()
  )
  
  valid <- !is.na(texts) & nchar(trimws(texts)) > 0
  
  if (!any(valid)) {
    message("No SMS messages found in column '", col, "'.")
    return(list(gauge = empty_tbl, agro = empty_tbl, bad = raw[0, ], raw = raw))
  }
  
  result <- parse_sms(texts[valid], sent_dates = sent_dates[valid])

  v_texts <- texts[valid]
  v_sent  <- sent_dates[valid]

  # Structurally malformed gauge SMS
  struct_bad <- is_bad_sms(v_texts) & !is_agro_sms(v_texts)

  # Gauge SMS with a date anomaly: future body date or body < sent_date
  body_dates <- suppressWarnings(as.Date(
    ifelse(is_gauge_sms(v_texts),
           sub("^[^,]+,\\s*([0-9]{2}-[0-9]{2}-[0-9]{4}).*$", "\\1", v_texts),
           NA_character_),
    format = "%d-%m-%Y"
  ))
  date_bad <- !is.na(body_dates) & !is.na(v_sent) & body_dates != v_sent

  bad_mask   <- struct_bad | date_bad
  bad_raw    <- raw[valid, ][bad_mask, ]

  bad_reason <- dplyr::case_when(
    # Date reasons take priority — is_bad_sms also catches date issues so a
    # future/too-old SMS would appear in both struct_bad and date_bad.
    !is.na(body_dates[bad_mask]) & body_dates[bad_mask] > v_sent[bad_mask]  ~ "future date",
    !is.na(body_dates[bad_mask]) &
      as.integer(v_sent[bad_mask] - body_dates[bad_mask]) > .max_sms_age() ~ "too old",
    date_bad[bad_mask]                                                       ~ "late submission",
    TRUE                                                                     ~ "malformed"
  )

  result$bad <- dplyr::mutate(bad_raw, bad_reason = bad_reason)
  result$raw <- raw
  result
}