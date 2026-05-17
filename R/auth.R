# R/auth.R

.auth_state <- new.env(parent = emptyenv())

.default_auth_path <- function() {
  f <- path.expand("~/.smscollectr/config_auth.json")
  if (file.exists(f)) f else NA_character_
}


#' Save service account credentials
#'
#' Copies the JSON key file to `~/.smscollectr/config_auth.json`.
#' After this, [sms_auth()] can be called without arguments in any session.
#'
#' @param path `character(1)`. Path to the service account JSON key file.
#' @param overwrite `logical(1)`. Overwrite if already exists. Default `FALSE`.
#'
#' @return Invisibly returns the destination path.
#' @export
config_auth <- function(path, overwrite = FALSE) {
  
  if (!file.exists(path)) stop("File not found: ", path)
  
  dest_dir  <- path.expand("~/.smscollectr")
  dest_file <- file.path(dest_dir, "config_auth.json")
  
  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE, mode = "0700")
    message("Created directory: ", dest_dir)
  }
  
  if (file.exists(dest_file) && !overwrite) {
    message("config_auth.json already exists. Use overwrite = TRUE to update.")
    return(invisible(dest_file))
  }
  
  file.copy(path, dest_file, overwrite = overwrite)
  Sys.chmod(dest_file, mode = "0600")
  
  message("Credentials saved to ", dest_file)
  invisible(dest_file)
}


#' Authenticate with Google Sheets
#'
#' Wraps [googlesheets4::gs4_auth()] and [googledrive::drive_auth()].
#' Call once per session before using any Sheet-related functions.
#' If [config_auth()] has been run previously, no arguments are needed.
#'
#' @param path `character(1)` or `NA`. Path to a service account JSON key file.
#'   Defaults to `~/.smscollectr/config_auth.json` if it exists.
#' @param email `character(1)` or `NULL`. Google account email for OAuth fallback.
#' @param cache `character(1)`. OAuth token cache directory.
#'
#' @return Invisibly returns `TRUE`.
#' @export
sms_auth <- function(path  = .default_auth_path(),
                     email = NULL,
                     cache = "~/.smscollectr/oauth") {
  
  if (!is.na(path)) {
    googlesheets4::gs4_auth(path = path)
    googledrive::drive_auth(path = path)
  } else {
    googlesheets4::gs4_auth(email = email, cache = cache)
    googledrive::drive_auth(email = email, cache = cache)
  }
  
  .auth_state$authenticated <- TRUE
  message("Authenticated with Google Sheets.")
  invisible(TRUE)
}


# Internal — called by read_sms(), clean_sheet(), etc.
.check_auth <- function() {
  if (!isTRUE(.auth_state$authenticated) &&
      !googlesheets4::gs4_has_token()) {
    stop(
      "Not authenticated. Run sms_auth() first:\n",
      "  config_auth('key.json')  # once — saves credentials\n",
      "  sms_auth()               # each session"
    )
  }
}