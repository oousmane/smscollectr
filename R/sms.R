#' Check whether a string is a valid rain gauge SMS
#'
#' A valid SMS starts with a 6-digit station identifier followed by one of
#' `P`, `A`, or `C`, then a comma (e.g. `"200001S, 03-06-2026, 125"`).
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
  grepl("^[0-9]{6}\\s*[PAC]\\s*,", trimws(text))
}

#' Check whether a string is a valid agrometeorological SMS
#'
#' A valid agrometeorological SMS starts with a plain station name on line 1,
#' followed by a full date in `DD-MM-YYYY` format on line 2, then a series
#' of `Key= value` lines.
#'
#' @param text `character` vector of SMS strings to check. `NULL` is accepted
#'   and returns `logical(0)`.
#'
#' @return A `logical` vector the same length as `text`.
#'
#' @examples
#' msg <- "DEDOUGOU\n11-05-2026\nTn= 305\nTx= 438"
#' is_agro_sms(msg)                          # TRUE
#' is_agro_sms("200001S, 03-06-2026, 125")   # FALSE
#' is_agro_sms(NULL)                         # logical(0)
#'
#' @seealso [is_gauge_sms()]
#' @export
is_agro_sms <- function(text = NULL) {
  if (is.null(text)) return(logical(0))
  if (!is.character(text)) stop("`text` must be character", call. = FALSE)
  
  vapply(text, function(txt) {
    # handle both real newlines and literal \n
    sep   <- if (grepl("\n", txt, fixed = TRUE)) "\n" else "\\n"
    lines <- trimws(strsplit(txt, sep, fixed = TRUE)[[1]])
    lines <- lines[nchar(lines) > 0]
    
    if (length(lines) != 17) return(FALSE)
    if (!grepl("^[A-Za-z][A-Za-z0-9 _-]*$", lines[1])) return(FALSE)
    if (!grepl("^\\d{2}-\\d{2}-\\d{4}$",    lines[2])) return(FALSE)
    
    valid_keys  <- c("Tn","Tx","TnSol","TxSol","T-10","T-20","T-50",
                     "Un","Ux","Vent","Inso","e","BAC","PICHE","RA")
    key_pattern <- paste0("^(", paste(valid_keys, collapse = "|"), ")=")
    all(grepl(key_pattern, lines[3:17]))
    
  }, logical(1), USE.NAMES = FALSE)
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
  
  d <- as.Date(sms_parts[2], "%d-%m-%Y")-1
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
    day      = as.integer(format(d, "%d")),
    value    = value,
    flag     = flag
  )
}

#' Parse a raw SMS value into a numeric value and quality flag
#'
#' Internal helper. Interprets a raw string extracted from an SMS message
#' and returns a named list with the physical value and a quality flag.
#'
#' Recognised special strings (case-insensitive):
#' \describe{
#'   \item{`TR`, `Tr`, `tR`, `tr`}{Trace — returns `value = 0`, `flag = "T"`.}
#'   \item{`NT`, `Nt`, `nT`, `nt`}{Not measured — returns `value = 0`,
#'     `flag = NA`.}
#'   \item{`xx`, `XX`, `Xx` (and `xxx` variants)}{Missing — returns
#'     `value = -9999`, `flag = "M"`.}
#' }
#'
#' @param raw `character(1)`. Raw string extracted from the SMS message.
#' @param divisor `numeric(1)`. Value to divide the numeric raw value by.
#'   Default `10`.
#'
#' @return A named `list` with two elements:
#'   \describe{
#'     \item{`value`}{`numeric`. Physical value, or `0`, `-9999`, or `NA`.}
#'     \item{`flag`}{`character`. `"T"` for trace, `"M"` for missing,
#'       `NA` otherwise.}
#'   }
#'
#'
#' @keywords internal
.parse_val <- function(raw, divisor = 10) {
  raw <- trimws(raw)
  
  # Trace — TR / Tr / tr / tR
  if (grepl("^[Tt][Rr]$", raw)) {
    return(list(value = 0, flag = "T"))
  }
  
  # Missing — xx / XX / Xx / xxx / XXX / Xxx (any case, 2 or 3 chars)
  if (grepl("^[Xx]{2,3}$", raw)) {
    return(list(value = -9999, flag = "M"))
  }
  
  # Not measured — NT / Nt / nT / nt → 0, no flag
  if (grepl("^[Nn][Tt]$", raw)) {
    return(list(value = 0, flag = NA_character_))
  }
  
  # Numeric
  v <- suppressWarnings(as.numeric(raw))
  if (is.na(v)) return(list(value = NA_real_, flag = NA_character_))
  
  list(value = v / divisor, flag = NA_character_)
}

#' Parse a single agrometeorological SMS into a long tibble
#'
#' Internal helper. Parses a multi-line agrometeorological SMS message into a
#' tidy long-format tibble with one row per observed variable. Returns a
#' single-row all-`NA` tibble for any message that fails validation or cannot
#' be parsed.
#'
#' The SMS format is:
#' ```
#' STATION-NAME
#' DD-MM-YYYY
#' Tn= 305
#' Tx= 438
#' ...
#' RA= NT
#' ```
#'
#' @param txt `character(1)`. A single raw SMS string with newline-separated
#'   lines.
#'
#' @return A [tibble::tibble()] with columns `eg_gh_id`, `year`, `month`,
#'   `day`, `time`, `eg_el_abbreviation`, `value`, `flag`. One row per
#'   variable (15 rows for a complete message). Returns a single-row
#'   all-`NA` tibble when parsing fails.
#'
#' @seealso [to_station_id()], [to_element_id()], [parse_sms()]
#'
#' @keywords internal
#' 
.parse_agro_sms <- function(txt) {
  na_row <- tibble::tibble(
    eg_gh_id           = NA_character_,
    year               = NA_integer_,
    month              = NA_integer_,
    day                = NA_integer_,
    time               = NA_character_,
    eg_el_abbreviation = NA_character_,
    value              = NA_real_,
    flag               = NA_character_
  )
  
  if (!is.character(txt) || length(txt) != 1) return(na_row)
  if (!is_agro_sms(txt)) return(na_row)
  
  # Split — handle both real newlines and literal \n
  sep   <- if (grepl("\n", txt, fixed = TRUE)) "\n" else "\\n"
  lines <- trimws(strsplit(txt, sep, fixed = TRUE)[[1]])
  lines <- lines[nchar(lines) > 0]
  
  # Line 1 — station name
  eg_gh_id <- to_station_id(trimws(lines[1]))
  
  # Line 2 — full date DD-MM-YYYY
  d <- as.Date(trimws(lines[2]), "%d-%m-%Y")
  if (is.na(d)) return(na_row)
  year  <- as.integer(format(d, "%Y"))
  month <- as.integer(format(d, "%m"))
  day   <- as.integer(format(d, "%d"))
  
  # Extract raw string for a given SMS key
  .raw <- function(key) {
    pattern <- paste0("^", key, "=\\s*(.+)$")
    match   <- grep(pattern, lines, value = TRUE)
    if (length(match) == 0) return(NA_character_)
    trimws(sub(pattern, "\\1", match[1]))
  }
  
  # Variable specifications: internal name -> SMS key + divisor
  vars <- list(
    Tn     = list(key = "Tn",    divisor = 10),
    Tx     = list(key = "Tx",    divisor = 10),
    TnSol  = list(key = "TnSol", divisor = 10),
    TxSol  = list(key = "TxSol", divisor = 10),
    `T-10` = list(key = "T-10",  divisor = 10),
    `T-20` = list(key = "T-20",  divisor = 10),
    `T-50` = list(key = "T-50",  divisor = 10),
    Un     = list(key = "Un",    divisor = 1),
    Ux     = list(key = "Ux",    divisor = 1),
    Vent   = list(key = "Vent",  divisor = 1),
    Inso   = list(key = "Inso",  divisor = 10),
    e      = list(key = "e",     divisor = 10),
    BAC    = list(key = "BAC",   divisor = 10),
    PICHE  = list(key = "PICHE", divisor = 10),
    RA     = list(key = "RA",    divisor = 10)
  )
  
  # Parse all variables into a long tibble — one row per variable
  rows <- purrr::imap(vars, function(spec, var_name) {
    raw    <- .raw(spec$key)
    parsed <- if (is.na(raw)) {
      list(value = NA_real_, flag = NA_character_)
    } else {
      .parse_val(raw, spec$divisor)
    }
    tibble::tibble(
      eg_gh_id           = eg_gh_id,
      year               = year,
      month              = month,
      day                = day,
      time               = "06:00",
      eg_el_abbreviation = to_element_id(var_name),
      value              = parsed$value,
      flag               = parsed$flag
    )
  })
  
  dplyr::bind_rows(rows)
}

#' Parse a vector of SMS messages (all formats)
#'
#' Detects the format of each SMS message, dispatches to the appropriate
#' parser, and returns a named list of two tibbles — one per format.
#'
#' Supported formats:
#' \describe{
#'   \item{`gauge`}{Format A — Rain gauge: `"200001S, 03-06-2026, 125"`.}
#'   \item{`agro`}{Format B — Agrometeorological: multi-line `[STATION]\n[DD]\nKey= val`.}
#' }
#'
#' Invalid or unrecognised messages are silently dropped. Duplicates
#' (same `eg_gh_id`, `year`, `month`, `day`, `eg_el_abbreviation`) keep
#' the last occurrence within each tibble.
#'
#' @param texts `character` vector of raw SMS strings.
#'
#' @return A named list with two [tibble::tibble()] elements:
#'   \describe{
#'     \item{`gauge`}{Parsed rain gauge observations with columns `eg_gh_id`,
#'       `year`, `month`, `day`, `time`, `eg_el_abbreviation`, `value`,
#'       `flag`.}
#'     \item{`agro`}{Parsed agrometeorological observations with the same
#'       columns.}
#'   }
#'   Each tibble is empty (but correctly typed) if no valid messages of that
#'   format are found.
#'
#' @seealso [read_sms()]
#'
#' @importFrom purrr map compact
#' @importFrom dplyr bind_rows filter if_all everything group_by slice_tail
#'   ungroup mutate
#' @export

parse_sms <- function(texts) {
  if (!is.character(texts)) stop("`texts` must be a character vector.", call. = FALSE)
  
  empty <- function() {
    tibble::tibble(
      eg_gh_id           = character(),
      year               = integer(),
      month              = integer(),
      day                = integer(),
      time               = character(),
      eg_el_abbreviation = character(),
      value              = numeric(),
      flag               = character()
    )
  }
  
  .dedup <- function(df) {
    if (nrow(df) == 0) return(df)
    df |>
      dplyr::filter(!dplyr::if_all(dplyr::everything(), is.na)) |>
      dplyr::group_by(
        .data$eg_gh_id, .data$year, .data$month,
        .data$day, .data$eg_el_abbreviation
      ) |>
      dplyr::slice_tail(n = 1) |>
      dplyr::ungroup()
  }
  
  texts <- texts[!is.na(texts) & nchar(trimws(texts)) > 0]
  
  if (length(texts) == 0) {
    return(list(gauge = empty(), agro = empty()))
  }
  
  # Fix only gauge SMS — never touch agro
  gauge_mask <- (is_gauge_sms(texts) | is_bad_sms(texts, gauge = TRUE)) &
    !is_agro_sms(texts)
  texts <- ifelse(gauge_mask, fix_sms(texts), texts)
  texts <- texts[!is.na(texts)]
  
  if (length(texts) == 0) {
    return(list(gauge = empty(), agro = empty()))
  }
  
  gauge_rows <- purrr::map(texts[is_gauge_sms(texts)], function(txt) {
    .parse_sms(txt) |>
      dplyr::mutate(
        time               = "06:00",
        eg_el_abbreviation = "RR"
      ) |>
      dplyr::select(
        .data$eg_gh_id, .data$year, .data$month, .data$day,
        .data$time, .data$eg_el_abbreviation, .data$value, .data$flag
      )
  }) |>
    purrr::compact() |>
    dplyr::bind_rows()
  
  agro_rows <- purrr::map(texts[is_agro_sms(texts)], .parse_agro_sms) |>
    purrr::compact() |>
    dplyr::bind_rows()
  
  list(
    gauge = .dedup(if (nrow(gauge_rows) == 0) empty() else gauge_rows),
    agro  = .dedup(if (nrow(agro_rows)  == 0) empty() else agro_rows)
  )
}


#' Attempt to fix a malformed SMS
#'
#' Extracts the last valid line, cleans the station ID, and normalises the
#' rainfall value by stripping non-numeric characters. Special values are
#' handled as follows: a "no rain" mention is converted to \code{"0"}, and
#' a trace rainfall (\code{TR}) is normalised to \code{"TR"}. Returns the
#' canonical form \code{"XXXXXXP, DD-MM-YYYY, VVV"}.
#'
#' @param x A character string containing the SMS text (possibly multi-line).
#' @param gauge Logical. If \code{TRUE} (default), fixes against gauge SMS
#'   rules via \code{is_gauge_sms()}. If \code{FALSE}, throws an error as
#'   non-gauge fixing is not yet implemented.
#'
#' @return A character string in the form \code{"ID, DD-MM-YYYY, value"}, or
#'   \code{NA_character_} if the SMS cannot be fixed.
#'
#' @examples
#' fix_sms("200068P, 24-06-2026, 12,6")                        # "200068P, 24-06-2026, 126"
#' fix_sms("200068P, 24-06-2026, 12mm")                        # "200068P, 24-06-2026, 12"
#' fix_sms("200053A , 30-06-2026, 1.0")                        # "200053A, 30-06-2026, 10"
#' fix_sms("200068P, 24-06-2026, TR")                          # "200068P, 24-06-2026, TR"
#' fix_sms("200068P, 24-06-2026, pas de pluie")                # "200068P, 24-06-2026, 0"
#' fix_sms("200034P,23-06-2026,boussouma n'a pas eu de pluie") # "200034P, 23-06-2026, 0"
#' fix_sms("32mm enregistré le 12/06/26")                      # NA
#'
#' @seealso [is_bad_sms()], [is_gauge_sms()], [is_no_rain()]
#'
#' @export

fix_sms <- function(x, gauge = TRUE) {
  if (gauge) {
    if (length(x) > 1) return(vapply(x, fix_sms, character(1), gauge = gauge))
    if (!is_gauge_sms(x)) return(NA_character_)
    
    lines <- trimws(strsplit(x, "\n")[[1]])
    lines <- lines[nzchar(lines)]
    last  <- lines[length(lines)]
    parts <- trimws(strsplit(last, ",")[[1]])
    
    id       <- gsub("\\s+", "", parts[1])
    date_raw <- trimws(parts[2])
    
    # Extract valid date prefix + leftover digits
    date  <- regmatches(date_raw, regexpr("^\\d{2}-\\d{2}-\\d{4}", date_raw))
    extra <- gsub("^\\d{2}-\\d{2}-\\d{4}", "", date_raw)
    
    if (length(date) == 0) return(NA_character_)
    
    reste <- trimws(paste(c(extra, parts[-(1:2)]), collapse = ","))
    
    val <- if (is_no_rain(reste)) "0" else
      if (grepl("^=?TR$", reste, ignore.case = TRUE)) "TR" else {
        v <- paste(gsub("[^0-9]", "", c(extra, parts[-(1:2)])), collapse = "")
        if (!nzchar(v)) return(NA_character_)
        v
      }
    
    return(paste(id, date, val, sep = ", "))
  }
  
  stop("non-gauge SMS fixing is not yet implemented.", call. = FALSE)
}
#' Check whether a string mentions no rainfall
#'
#' Uses both exact regex and fuzzy matching to catch common misspellings
#' of the French phrase "pas de pluie" (no rain).
#'
#' @param x A character string.
#'
#' @return A logical scalar.
#'
#' @examples
#' is_no_rain("pas de pluie")                        # TRUE
#' is_no_rain("Pa de plu")                           # TRUE
#' is_no_rain("boussouma n'a pas eu de pluie")       # TRUE
#' is_no_rain("126")                                  # FALSE
#'
#' @export
is_no_rain <- function(x) {
  grepl("pas\\s*de\\s*plu", x, ignore.case = TRUE) ||
    agrepl("pas de pluie", x, ignore.case = TRUE, max.distance = 0.3)
}


#' Check whether an SMS is malformed
#'
#' Validates an SMS against format-specific rules. Currently only gauge SMS
#' validation is implemented. A valid gauge SMS has exactly one line, a
#' station ID matching \code{[0-9]{6}[PAC]}, a date in \code{DD-MM-YYYY}
#' format, and a value of 1-4 digits or a "no rain" mention.
#'
#' @param x A character string containing the SMS text.
#' @param gauge Logical. If \code{TRUE} (default), validates via
#'   \code{is_gauge_sms()} rules.
#'
#' @return A logical scalar. \code{TRUE} if malformed, \code{FALSE} if valid.
#'
#' @examples
#' is_bad_sms("200068P, 24-06-2026, 21")            # FALSE
#' is_bad_sms("200068P, 24-06-2026, 12mm")           # TRUE
#' is_bad_sms("200068P, 24-06-2026, pas de pluie")   # FALSE
#' is_bad_sms("200068P, 24-06-2026,")                # TRUE
#'
#' @export
is_bad_sms <- function(x, gauge = TRUE) {
  if (length(x) > 1) return(vapply(x, is_bad_sms, logical(1), gauge = gauge))
  
  if (gauge) {
    if (!is_gauge_sms(x)) return(TRUE)
    
    lines <- trimws(strsplit(x, "\n")[[1]])
    lines <- lines[nzchar(lines)]
    
    if (length(lines) != 1) return(TRUE)
    
    parts <- trimws(strsplit(lines, ",")[[1]])
    
    if (length(parts) != 3) return(TRUE)
    
    return(
      !grepl("^\\d{2}-\\d{2}-\\d{4}$", parts[2]) ||
        (!grepl("^\\d{1,4}$", parts[3])             &&
           !grepl("^=?TR$", parts[3], ignore.case = TRUE) &&
           !is_no_rain(parts[3]))
    )
  }
  
  # agro
  !is_agro_sms(x)
}