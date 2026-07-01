#' Map a station name to its CLIDATA station code
#'
#' @param x `character`. Station name(s) as they appear in the TCM or SMS.
#'   Matching is case-insensitive and strips surrounding whitespace.
#'
#' @return `character` vector of CLIDATA station codes (`eg_gh_id`).
#'   Returns `NA` with a warning for unrecognised names.
#'
#' @examples
#' to_station_id("DORI")              # "200026S"
#' to_station_id("bobo-dioulasso")    # "200099S"
#' to_station_id("UNKNOWN")           # NA + warning
#'
#' @export
to_station_id <- function(x) {
  key <- toupper(trimws(x))
  out <- unname(station_lookup[key])
  if (any(is.na(out))) {
    warning(
      "Unrecognised station name(s): ",
      paste(x[is.na(out)], collapse = ", "),
      call. = FALSE
    )
  }
  out
}

#' Map a TCM variable name to its CLIDATA element abbreviation
#'
#' @param x `character`. Internal TCM variable name(s) (e.g. `"TMIN"`,
#'   `"TS-10"`, `"WDD"`).
#'
#' @return `character` vector of CLIDATA element abbreviations
#'   (`eg_el_abbreviation`). Returns `NA` with a warning for unrecognised
#'   names.
#'
#' @examples
#' to_element_id("Tn")    # "TMIN"
#' to_element_id("T-10")   # "TS-10"
#' to_element_id("UNKNOWN") # NA + warning
#'
#' @export
to_element_id <- function(x) {
  out <- unname(element_lookup[x])
  if (any(is.na(out))) {
    warning(
      "Unrecognised element name(s): ",
      paste(x[is.na(out)], collapse = ", "),
      call. = FALSE
    )
  }
  out
}