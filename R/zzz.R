# R/zzz.R
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "smscollectr: run sms_auth() to authenticate with Google Sheets."
  )
}