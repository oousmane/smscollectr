# Check whether an SMS is malformed

Validates an SMS against format-specific rules. A valid gauge SMS has
exactly one line, a station ID matching `[0-9]{6}[PAC]` with a numeric
part not exceeding 200166, a date in `DD-MM-YYYY` format not in the
future and not older than `SMSCOLLECTR_MAX_AGE` days (default 3), and a
value of 1-4 digits, `TR`, or a "no rain" mention.

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
  rules. If `FALSE`, validates via
  [`is_agro_sms()`](https://oousmane.github.io/smscollectr/reference/is_agro_sms.md).

## Value

A logical scalar. `TRUE` if malformed, `FALSE` if valid.

## Details

The maximum SMS age can be configured via the environment variable
`SMSCOLLECTR_MAX_AGE`:


    Sys.setenv(SMSCOLLECTR_MAX_AGE = "10")

## See also

[`is_gauge_sms()`](https://oousmane.github.io/smscollectr/reference/is_gauge_sms.md),
[`is_no_rain()`](https://oousmane.github.io/smscollectr/reference/is_no_rain.md),
[`fix_sms()`](https://oousmane.github.io/smscollectr/reference/fix_sms.md)

## Examples

``` r
is_bad_sms("200068P, 24-06-2026, 21")              # FALSE
#> [1] TRUE
is_bad_sms("200068P, 24-06-2026, TR")              # FALSE
#> [1] TRUE
is_bad_sms("200068P, 24-06-2026, 12mm")            # TRUE
#> [1] TRUE
is_bad_sms("200068P, 24-06-2026, pas de pluie")    # FALSE
#> [1] TRUE
is_bad_sms("200068P, 24-06-2026,")                 # TRUE
#> [1] TRUE
is_bad_sms("200286P, 24-06-2026, 21")              # TRUE — ID out of range
#> [1] TRUE
```
