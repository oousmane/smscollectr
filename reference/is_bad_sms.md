# Check whether an SMS is malformed

Validates an SMS against format-specific rules. Currently only gauge SMS
validation is implemented. A valid gauge SMS has exactly one line, a
station ID matching `[0-9]{6}[PAC]`, a date in `DD-MM-YYYY` format, and
a value of 1-4 digits or a "no rain" mention.

## Usage

``` r
is_bad_sms(x, gauge = TRUE)
```

## Arguments

- x:

  A character string containing the SMS text.

- gauge:

  Logical. If `TRUE` (default), validates via
  [`is_gauge_sms()`](https://oousmane.github.io/smscollectr/reference/is_gauge_sms.md)
  rules.

## Value

A logical scalar. `TRUE` if malformed, `FALSE` if valid.

## Examples

``` r
is_bad_sms("200068P, 24-06-2026, 21")            # FALSE
#> [1] FALSE
is_bad_sms("200068P, 24-06-2026, 12mm")           # TRUE
#> [1] TRUE
is_bad_sms("200068P, 24-06-2026, pas de pluie")   # FALSE
#> [1] FALSE
is_bad_sms("200068P, 24-06-2026,")                # TRUE
#> [1] TRUE
```
