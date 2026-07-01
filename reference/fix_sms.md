# Attempt to fix a malformed SMS

Extracts the last valid line, cleans the station ID, and normalises the
rainfall value by stripping non-numeric characters. Special values are
handled as follows: a "no rain" mention is converted to `"0"`, and a
trace rainfall (`TR`) is normalised to `"TR"`. Returns the canonical
form `"XXXXXXP, DD-MM-YYYY, VVV"`.

## Usage

``` r
fix_sms(x, gauge = TRUE)
```

## Arguments

- x:

  A character string containing the SMS text (possibly multi-line).

- gauge:

  Logical. If `TRUE` (default), fixes against gauge SMS rules via
  [`is_gauge_sms()`](https://oousmane.github.io/smscollectr/reference/is_gauge_sms.md).
  If `FALSE`, throws an error as non-gauge fixing is not yet
  implemented.

## Value

A character string in the form `"ID, DD-MM-YYYY, value"`, or
`NA_character_` if the SMS cannot be fixed.

## See also

[`is_bad_sms()`](https://oousmane.github.io/smscollectr/reference/is_bad_sms.md),
[`is_gauge_sms()`](https://oousmane.github.io/smscollectr/reference/is_gauge_sms.md),
[`is_no_rain()`](https://oousmane.github.io/smscollectr/reference/is_no_rain.md)

## Examples

``` r
fix_sms("200068P, 24-06-2026, 12,6")                        # "200068P, 24-06-2026, 126"
#> [1] "200068P, 24-06-2026, 126"
fix_sms("200068P, 24-06-2026, 12mm")                        # "200068P, 24-06-2026, 12"
#> [1] "200068P, 24-06-2026, 12"
fix_sms("200053A , 30-06-2026, 1.0")                        # "200053A, 30-06-2026, 10"
#> [1] "200053A, 30-06-2026, 10"
fix_sms("200068P, 24-06-2026, TR")                          # "200068P, 24-06-2026, TR"
#> [1] NA
fix_sms("200068P, 24-06-2026, pas de pluie")                # "200068P, 24-06-2026, 0"
#> [1] "200068P, 24-06-2026, 0"
fix_sms("200034P,23-06-2026,boussouma n'a pas eu de pluie") # "200034P, 23-06-2026, 0"
#> [1] "200034P, 23-06-2026, 0"
fix_sms("32mm enregistré le 12/06/26")                      # NA
#> [1] NA
```
