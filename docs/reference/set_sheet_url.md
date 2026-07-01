# Store a Google Sheet URL in the system credential store

Saves a Google Sheet URL securely using the system keyring (macOS
Keychain, Windows Credential Manager, or Linux Secret Service). The URL
is never written to disk in plain text, `.Renviron`, or any R script.

## Usage

``` r
set_sheet_url(url, key = "gs_url", service = "smscollectr")
```

## Arguments

- url:

  `character(1)`. Full Google Sheet URL to store.

- key:

  `character(1)`. Key name used to retrieve the URL later. Default is
  `"gs_url"`.

- service:

  `character(1)`. Keyring service namespace. Default is `"smscollectr"`.

## Value

Invisibly returns `key`.

## See also

[`get_sheet_url()`](https://oousmane.github.io/smscollectr/reference/get_sheet_url.md)

## Examples

``` r
if (FALSE) { # \dontrun{
set_sheet_url("https://docs.google.com/spreadsheets/d/SHEET_ID/edit")
} # }
```
