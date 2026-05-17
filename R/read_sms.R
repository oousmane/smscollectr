#' Read and parse SMS rain gauge entries from a Google Sheet
#'
#' Reads SMS messages from a Google Sheet column, parses them into structured
#' rainfall observations, deduplicates by station and date, and formats the
#' result for ingestion into a climatological database.
#'
#' @param sheet_url `character(1)`. Full URL of the Google Sheet.
#' @param sheet `character(1)` or `integer(1)`. Sheet name or index.
#'   Default is `1` (first sheet).
#' @param col `character(1)` or `integer(1)`. Name or index of the column
#'   containing SMS text. Default is `"sms"`.
#'
#' @return A [tibble::tibble()] with columns:
#'   \describe{
#'     \item{eg_gh_id}{`character`. Station identifier.}
#'     \item{eg_el_abbreviation}{`character`. Element code, always `"RR"`
#'       (rainfall).}
#'     \item{month}{`character`. Zero-padded month (`"01"` to `"12"`).}
#'     \item{day}{`character`. Zero-padded day (`"01"` to `"31"`).}
#'     \item{value}{`numeric`. Rainfall in mm.}
#'     \item{flag}{`character`. `"T"` for trace rainfall, `NA` otherwise.}
#'   }
#'   Returns an empty tibble with the correct column types if no valid SMS
#'   messages are found.
#'
#' @examples
#' \dontrun{
#' url <- "https://docs.google.com/spreadsheets/d/SHEET_ID/edit"
#' read_sms(url)
#' read_sms(url, sheet = "Saisie", col = "message")
#' }
#'
#' @export
read_sms <- function(sheet_url, sheet = 1, col = "sms") {
  
  .check_auth()
  
  stopifnot(
    is.character(sheet_url), length(sheet_url) == 1, nchar(sheet_url) > 0,
    length(sheet) == 1,
    length(col)   == 1
  )
  
  empty_result <- tibble::tibble(
    eg_gh_id           = character(),
    year               = character(),
    month              = character(),
    day                = character(),
    time               = character(),
    value              = numeric(),
    flag               = character()
  )
  
  raw <- tryCatch(
    googlesheets4::read_sheet(sheet_url, sheet = sheet),
    error = function(e) stop("Failed to read sheet: ", conditionMessage(e))
  )
  
  if (!col %in% names(raw) && !is.numeric(col)) {
    stop("Column '", col, "' not found in sheet. Available columns: ",
         paste(names(raw), collapse = ", "))
  }
  
  texts <- dplyr::pull(raw, {{ col }})
  texts <- as.character(texts)
  texts <- texts[!is.na(texts) & nchar(trimws(texts)) > 0]
  
  if (length(texts) == 0) {
    message("No SMS messages found in column '", col, "'.")
    return(empty_result)
  }
  
 parse_sms(texts)
 
}
