# Parse a single agrometeorological SMS into a long tibble

Internal helper. Parses a multi-line agrometeorological SMS message into
a tidy long-format tibble with one row per observed variable. Returns a
single-row all-`NA` tibble for any message that fails validation or
cannot be parsed.

## Usage

``` r
.parse_agro_sms(txt)
```

## Arguments

- txt:

  `character(1)`. A single raw SMS string with newline-separated lines.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with columns `eg_gh_id`, `year`, `month`, `day`, `time`,
`eg_el_abbreviation`, `value`, `flag`. One row per variable (15 rows for
a complete message). Returns a single-row all-`NA` tibble when parsing
fails.

## Details

The SMS format is:

    STATION-NAME
    DD-MM-YYYY
    Tn= 305
    Tx= 438
    ...
    RA= NT

## See also

[`to_station_id()`](https://oousmane.github.io/smscollectr/reference/to_station_id.md),
[`to_element_id()`](https://oousmane.github.io/smscollectr/reference/to_element_id.md),
[`parse_sms()`](https://oousmane.github.io/smscollectr/reference/parse_sms.md)
