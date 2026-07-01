# R/auth.R
.auth_state <- new.env(parent = emptyenv())


#' Save service account credentials to the system keyring
#'
#' Reads a service account JSON key file and stores its contents securely in
#' the system keyring. After this, authentication is fully automatic, no
#' arguments needed in any session.
#'
#' @param path `character(1)`. Path to the service account JSON key file.
#' @param overwrite `logical(1)`. Overwrite if already exists. Default `FALSE`.
#'
#' @return Invisibly returns `TRUE`.
#'
#' @examples
#' \dontrun{
#' config_auth("~/Downloads/key.json")  # once
#' }
#'
#' @export
config_auth <- function(path, overwrite = FALSE) {
  if (!file.exists(path)) stop("File not found: ", path)
  
  already <- tryCatch(
    { keyring::key_get("smscollectr", "service_account"); TRUE },
    error = function(e) FALSE
  )
  
  if (already && !overwrite) {
    message("Credentials already configured. Use overwrite = TRUE to update.")
    return(invisible(TRUE))
  }
  
  json <- paste(readLines(path, warn = FALSE), collapse = "\n")
  keyring::key_set_with_value("smscollectr", "service_account", json)
  
  message("Credentials saved to system keyring.")
  invisible(TRUE)
}


#' Authenticate with Google Sheets
#'
#' Forces re-authentication. Useful when the token has expired or when
#' switching accounts. If keyring credentials are available they are used;
#' otherwise falls back to OAuth with the provided email.
#'
#' @param email `character(1)` or `NULL`. Google account email for OAuth
#'   fallback when no keyring credentials are found.
#' @param cache `character(1)`. OAuth token cache directory. Default
#'   `~/.smscollectr/oauth`.
#'
#' @return Invisibly returns `TRUE`.
#'
#' @examples
#' \dontrun{
#' sms_auth()                            # service account via keyring
#' sms_auth(email = "you@gmail.com")     # OAuth fallback
#' }
#'
#' @export
sms_auth <- function(email = NULL, cache = "~/.smscollectr/oauth") {
  .auth_state$authenticated <- FALSE
  .check_auth(email = email, cache = cache)
}


# Called internally by read_sms(), clean_sheet(), etc.
.check_auth <- function(email = NULL, cache = "~/.smscollectr/oauth") {
  if (isTRUE(.auth_state$authenticated) || googlesheets4::gs4_has_token()) {
    return(invisible(NULL))
  }
  
  json <- tryCatch(
    keyring::key_get("smscollectr", "service_account"),
    error = function(e) NULL
  )
  
  if (!is.null(json)) {
    tmp <- tempfile(fileext = ".json")
    on.exit(unlink(tmp), add = TRUE)
    writeLines(json, tmp)
    googlesheets4::gs4_auth(path = tmp)
    googledrive::drive_auth(path = tmp)
  } else if (!is.null(email)) {
    cache_dir <- path.expand(cache)
    if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE, mode = "0700")
    googlesheets4::gs4_auth(email = email, cache = cache_dir)
    googledrive::drive_auth(email = email, cache = cache_dir)
  } else {
    stop(
      "Not authenticated. Either:\n",
      "  config_auth('key.json')            # once : saves to keyring\n",
      "  sms_auth(email = 'you@gmail.com')  # OAuth fallback"
    )
  }
  
  .auth_state$authenticated <- TRUE
  message("Authenticated with Google Sheets.")
  invisible(TRUE)
}