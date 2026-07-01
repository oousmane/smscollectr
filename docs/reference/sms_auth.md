# Authenticate with Google Sheets

Wraps
[`googlesheets4::gs4_auth()`](https://googlesheets4.tidyverse.org/reference/gs4_auth.html).
Call once per session before using any Sheet-related functions. Uses a
service account JSON if provided, otherwise falls back to OAuth with a
persistent cache.

## Usage

``` r
sms_auth(path = NULL, email = NULL, cache = "~/.smscollectr_secrets")
```

## Arguments

- path:

  `character(1)` or `NULL`. Path to a service account JSON key file. If
  `NULL`, OAuth is used.

- email:

  `character(1)` or `NULL`. Google account email for OAuth.

- cache:

  `character(1)`. Path to the OAuth token cache directory. Default is
  `"~/.smscollectr_secrets"`.

## Value

Invisibly returns `TRUE`.
