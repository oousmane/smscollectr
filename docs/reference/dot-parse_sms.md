# Parse a single rain gauge SMS into a one-row tibble

Internal helper. Returns a row of `NA`s for any SMS that fails
validation or cannot be parsed.

## Usage

``` r
.parse_sms(txt)
```

## Arguments

- txt:

  `character(1)`. A single SMS string.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with columns `eg_gh_id`, `year`, `month`, `day`, `value`, and `flag`.
All columns are `NA` when parsing fails.
