# Read and parse SMS rain gauge entries from a Google Sheet

Reads SMS messages from a Google Sheet column, parses them into
structured rainfall observations, deduplicates by station and date, and
formats the result for ingestion into a climatological database.

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

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with columns:

- eg_gh_id:

  `character`. Station identifier.

- eg_el_abbreviation:

  `character`. Element code, always `"RR"` (rainfall).

- month:

  `character`. Zero-padded month (`"01"` to `"12"`).

- day:

  `character`. Zero-padded day (`"01"` to `"31"`).

- value:

  `numeric`. Rainfall in mm.

- flag:

  `character`. `"T"` for trace rainfall, `NA` otherwise.

Returns an empty tibble with the correct column types if no valid SMS
messages are found.

## Examples

``` r
if (FALSE) { # \dontrun{
url <- "https://docs.google.com/spreadsheets/d/SHEET_ID/edit"
read_sms(url)
read_sms(url, sheet = "Saisie", col = "message")
} # }
```
