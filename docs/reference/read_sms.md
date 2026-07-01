# Read and parse SMS messages from a Google Sheet

Reads raw SMS messages from a Google Sheet column, attempts to fix
malformed gauge messages via
[`fix_sms()`](https://oousmane.github.io/smscollectr/reference/fix_sms.md),
parses valid messages into structured observations via
[`parse_sms()`](https://oousmane.github.io/smscollectr/reference/parse_sms.md),
and returns a named list with parsed data, malformed rows, and the raw
sheet.

## Usage

``` r
read_sms(sheet_url, sheet = 1, col = "sms")
```

## Arguments

- sheet_url:

  `character(1)`. Full URL of the Google Sheet.

- sheet:

  `character(1)` or `integer(1)`. Sheet name or index. Default is `1`
  (first sheet).

- col:

  `character(1)` or `integer(1)`. Name or index of the column containing
  SMS text. Default is `"sms"`.

## Value

A named list with four elements:

- `gauge`:

  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  of parsed rain gauge observations with columns `eg_gh_id`, `year`,
  `month`, `day`, `time`, `eg_el_abbreviation`, `value`, `flag`.

- `agro`:

  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  of parsed agrometeorological observations with the same columns.

- `bad`:

  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  — subset of the raw sheet rows whose SMS could not be parsed or fixed.

- `raw`:

  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  — the full raw sheet as read from Google Sheets, with list columns
  coerced to character.

`gauge` and `agro` are empty but correctly typed tibbles if no valid
messages of that format are found.

## See also

[`parse_sms()`](https://oousmane.github.io/smscollectr/reference/parse_sms.md),
[`fix_sms()`](https://oousmane.github.io/smscollectr/reference/fix_sms.md),
[`is_bad_sms()`](https://oousmane.github.io/smscollectr/reference/is_bad_sms.md),
[`sms_auth()`](https://oousmane.github.io/smscollectr/reference/sms_auth.md),
[`get_sheet_url()`](https://oousmane.github.io/smscollectr/reference/get_sheet_url.md)

## Examples

``` r
if (FALSE) { # \dontrun{
sms_auth()
url <- get_sheet_url()
result <- read_sms(url)
result$gauge
result$bad
} # }
```
