# Authenticate with Google Sheets

Forces re-authentication. Useful when the token has expired or when
switching accounts. If keyring credentials are available they are used;
otherwise falls back to OAuth with the provided email.

## Usage

``` r
sms_auth(email = NULL, cache = "~/.smscollectr/oauth")
```

## Arguments

- email:

  `character(1)` or `NULL`. Google account email for OAuth fallback when
  no keyring credentials are found.

- cache:

  `character(1)`. OAuth token cache directory. Default
  `~/.smscollectr/oauth`.

## Value

Invisibly returns `TRUE`.

## Examples

``` r
if (FALSE) { # \dontrun{
sms_auth()                            # service account via keyring
sms_auth(email = "you@gmail.com")     # OAuth fallback
} # }
```
