# R/zzz.R

.onLoad <- function(libname, pkgname) {
  path <- .default_auth_path()
  if (!is.na(path)) {
    tryCatch(
      {
        googlesheets4::gs4_auth(path = path)
        googledrive::drive_auth(path = path)
        .auth_state$authenticated <- TRUE
      },
      error = function(e) {
        packageStartupMessage(
          "smscollectr: auto-authentication failed.\n",
          "  Run sms_auth() manually.\n",
          "  Reason: ", conditionMessage(e)
        )
      }
    )
  }
}