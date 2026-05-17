# Parse a vector of SMS messages (all formats)

Detects the format of each SMS message, dispatches to the appropriate
parser, and returns a named list of two tibbles — one per format.

## Usage

``` r
parse_sms(texts)
```

## Arguments

- texts:

  `character` vector of raw SMS strings.

## Value

A named list with two
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
elements:

- `gauge`:

  Parsed rain gauge observations with columns `eg_gh_id`, `year`,
  `month`, `day`, `time`, `eg_el_abbreviation`, `value`, `flag`.

- `agro`:

  Parsed agrometeorological observations with the same columns.

Each tibble is empty (but correctly typed) if no valid messages of that
format are found.

## Details

Supported formats:

- `gauge`:

  Format A — Rain gauge: `"200001S, 03-06-2026, 125"`.

- `agro`:

  Format B — Agrometeorological: multi-line `[STATION]\n[DD]\nKey= val`.

Invalid or unrecognised messages are silently dropped. Duplicates (same
`eg_gh_id`, `year`, `month`, `day`, `eg_el_abbreviation`) keep the last
occurrence within each tibble.

## See also

[`read_sms()`](https://oousmane.github.io/smscollectr/reference/read_sms.md)
