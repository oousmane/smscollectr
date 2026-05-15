#' Store a Google Sheet URL in the system credential store
#'
#' Saves a Google Sheet URL securely using the system keyring (macOS Keychain,
#' Windows Credential Manager, or Linux Secret Service). The URL is never
#' written to disk in plain text, `.Renviron`, or any R script.
#'
#' @param url `character(1)`. Full Google Sheet URL to store.
#' @param key `character(1)`. Key name used to retrieve the URL later.
#'   Default is `"gs_url"`.
#' @param service `character(1)`. Keyring service namespace.
#'   Default is `"smscollectr"`.
#'
#' @return Invisibly returns `key`.
#'
#' @examples
#' \dontrun{
#' set_sheet_url("https://docs.google.com/spreadsheets/d/SHEET_ID/edit")
#' }
#'
#' @seealso [get_sheet_url()]
#' @export
set_sheet_url <- function(url,
                          key     = "gs_url",
                          service = "smscollectr") {
  stopifnot(
    is.character(url),     length(url)     == 1, nchar(url)     > 0,
    is.character(key),     length(key)     == 1, nchar(key)     > 0,
    is.character(service), length(service) == 1, nchar(service) > 0
  )
  
  if (!grepl("^https://docs\\.google\\.com/spreadsheets/", url)) {
    stop("'url' does not look like a valid Google Sheets URL.")
  }
  
  if (!requireNamespace("keyring", quietly = TRUE)) {
    stop(
      "Package 'keyring' is required. Install it with:\n",
      "  install.packages(\"keyring\")"
    )
  }
  
  keyring::key_set_with_value(
    service  = service,
    username = key,
    password = url
  )
  
  message("Sheet URL stored securely under key '", key, "'.")
  invisible(key)
}


#' Retrieve a stored Google Sheet URL from the system credential store
#'
#' Retrieves a Google Sheet URL previously saved with [set_sheet_url()].
#' Raises an informative error if the key is not found.
#'
#' @param key `character(1)`. Key name used when storing the URL.
#'   Default is `"gs_url"`.
#' @param service `character(1)`. Keyring service namespace.
#'   Default is `"smscollectr"`.
#'
#' @return `character(1)`. The stored Google Sheet URL.
#'
#' @examples
#' \dontrun{
#' url <- get_sheet_url()
#' read_sms(url)
#' }
#'
#' @seealso [set_sheet_url()]
#' @export
get_sheet_url <- function(key     = "gs_url",
                          service = "smscollectr") {
  stopifnot(
    is.character(key),     length(key)     == 1,
    is.character(service), length(service) == 1
  )
  
  if (!requireNamespace("keyring", quietly = TRUE)) {
    stop(
      "Package 'keyring' is required. Install it with:\n",
      "  install.packages(\"keyring\")"
    )
  }
  
  stored <- tryCatch(
    keyring::key_list(service = service),
    error = function(e) NULL
  )
  
  if (is.null(stored) || !key %in% stored$username) {
    stop(
      "No URL found for key '", key, "' in service '", service, "'.\n",
      "Run set_sheet_url() first to register the URL."
    )
  }
  
  keyring::key_get(service = service, username = key)
}