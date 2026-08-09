# Retrieve a stored Google Sheet URL from the system credential store

Retrieves a Google Sheet URL previously saved with
[`set_sheet_url()`](https://oousmane.github.io/smscollectr/reference/set_sheet_url.md).
Raises an informative error if the key is not found.

## Usage

``` r
get_sheet_url(key = "gs_url", service = "smscollectr")
```

## Arguments

- key:

  `character(1)`. Key name used when storing the URL. Default is
  `"gs_url"`.

- service:

  `character(1)`. Keyring service namespace. Default is `"smscollectr"`.

## Value

`character(1)`. The stored Google Sheet URL.

## See also

[`set_sheet_url()`](https://oousmane.github.io/smscollectr/reference/set_sheet_url.md)

## Examples

``` r
if (FALSE) { # \dontrun{
url <- get_sheet_url()
read_sms(url)

# Multiple sheets
gauge_url <- get_sheet_url(key = "gauge_url")
agro_url  <- get_sheet_url(key = "agro_url")
} # }
```
