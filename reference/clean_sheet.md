# Delete all data rows from a Google Sheet

Reads a Google Sheet and deletes all data rows, preserving the header
row. Has no effect if the sheet is already empty.

## Usage

``` r
clean_sheet(url)
```

## Arguments

- url:

  `character(1)`. Full URL of the Google Sheet.

## Value

Invisibly returns the number of deleted rows (`integer`). Returns `0L`
if the sheet was already empty.

## Examples

``` r
if (FALSE) { # \dontrun{
url <- "https://docs.google.com/spreadsheets/d/SHEET_ID/edit"
clean_sheet(url)
} # }
```
