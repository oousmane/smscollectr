# R/auth.R

.auth_state <- new.env(parent = emptyenv())

#' Authenticate with Google Sheets
#'
#' Wraps [googlesheets4::gs4_auth()]. Call once per session before using
#' any Sheet-related functions. Uses a service account JSON if provided,
#' otherwise falls back to OAuth with a persistent cache.
#'
#' @param path `character(1)` or `NULL`. Path to a service account JSON key
#'   file. If `NULL`, OAuth is used.
#' @param email `character(1)` or `NULL`. Google account email for OAuth.
#' @param cache `character(1)`. Path to the OAuth token cache directory.
#'   Default is `"~/.smscollectr_secrets"`.
#'
#' @return Invisibly returns `TRUE`.
#' @export
sms_auth <- function(path  = NULL,
                     email = NULL,
                     cache = "~/.smscollectr_secrets") {
  if (!is.null(path)) {
    googlesheets4::gs4_auth(path = path)
  } else {
    googlesheets4::gs4_auth(email = email, cache = cache)
  }
  .auth_state$authenticated <- TRUE
  message("Authenticated with Google Sheets.")
  invisible(TRUE)
}

# Internal check called by read_sms() and clean_sheet()
.check_auth <- function() {
  if (!isTRUE(.auth_state$authenticated) &&
      !googlesheets4::gs4_has_token()) {
    stop(
      "Not authenticated. Run sms_auth() first:\n",
      "  sms_auth()                             # OAuth\n",
      "  sms_auth(path = 'key.json')            # Service account"
    )
  }
}