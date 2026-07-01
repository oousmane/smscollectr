#' Check whether a string is a valid rain gauge SMS
#'
#' A valid SMS starts with a 6-digit station identifier followed by one of
#' `P`, `S`, `A`, or `C`, then a comma (e.g. `"200001S, 03-06-2026, 125"`).
#'
#' @param text `character` vector of SMS strings to check. `NULL` is accepted
#'   and returns `logical(0)`.
#'
#' @return A `logical` vector the same length as `text`.
#'
#' @examples
#' is_gauge_sms("200001S, 03-06-2026, 125")  # TRUE
#' is_gauge_sms("hello world")               # FALSE
#' is_gauge_sms(NULL)                        # logical(0)
#'
#' @export
is_gauge_sms <- function(text = NULL) {
  if (is.null(text)) return(logical(0))
  if (!is.character(text)) stop("`text` must be character")
  grepl("^[0-9]{6}[PSAC],", trimws(text))
}


#' Parse a single rain gauge SMS into a one-row tibble
#'
#' Internal helper. Returns a row of `NA`s for any SMS that fails validation
#' or cannot be parsed.
#'
#' @param txt `character(1)`. A single SMS string.
#'
#' @return A [tibble::tibble()] with columns `eg_gh_id`, `year`, `month`,
#'   `day`, `value`, and `flag`. All columns are `NA` when parsing fails.
#'
#' @keywords internal
.parse_sms <- function(txt) {
  na_row <- tibble::tibble(
    eg_gh_id = NA_character_,
    year     = NA_integer_,
    month    = NA_integer_,
    day      = NA_integer_,
    value    = NA_real_,
    flag     = NA_character_
  )
  
  if (!is.character(txt) || length(txt) != 1) return(na_row)
  if (!is_gauge_sms(txt)) return(na_row)
  
  sms_parts <- trimws(strsplit(txt, ",")[[1]])
  if (length(sms_parts) < 3) return(na_row)
  
  d <- as.Date(sms_parts[2], "%d-%m-%Y")
  if (is.na(d)) return(na_row)
  
  if (tolower(sms_parts[3]) == "tr") {
    value <- 0
    flag  <- "T"
  } else {
    value <- suppressWarnings(as.numeric(sms_parts[3])) / 10
    flag  <- NA_character_
    if (is.na(value)) return(na_row)
  }
  
  tibble::tibble(
    eg_gh_id = sms_parts[1],
    year     = as.integer(format(d, "%Y")),
    month    = as.integer(format(d, "%m")),
    day      = as.integer(format(d, "%d"))-1,
    value    = value,
    flag     = flag
  )
}


#' Parse a vector of rain gauge SMS messages
#'Duplicate observations (same station, year, month, day) are
#' deduplicated, keeping the last occurrence.
#'
#' @param texts `character` vector of SMS strings.
#'
#' @return A [tibble::tibble()] with columns:
#'   \describe{
#'     \item{eg_gh_id}{`character`. Station identifier (6 digits + type code).}
#'     \item{year}{`integer`. Observation year.}
#'     \item{month}{`integer`. Observation month.}
#'     \item{day}{`integer`. Observation day.}
#'     \item{value}{`numeric`. Rainfall in mm (raw value divided by 10).
#'       `0` for trace rainfall.}
#'     \item{flag}{`character`. `"T"` for trace rainfall, `NA` otherwise.}
#'   }
#'
#' @examples
#' \dontrun{
#' msgs <- c(
#'   "200001S, 03-06-2026, 125",
#'   "200002P, 04-06-2026, TR",
#'   "invalid message"
#' )
#' parse_sms(msgs)
#' }
#'
#' @export
parse_sms <- function(texts) {
  if (!is.character(texts)) stop("`texts` must be a character vector")
  
  purrr::map(texts, .parse_sms) |>
    dplyr::bind_rows() |>
    dplyr::filter(!dplyr::if_all(dplyr::everything(), is.na))
}