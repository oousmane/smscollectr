# Attempt to fix a malformed SMS

Extracts the last valid line, cleans the station ID, and normalises the
rainfall value. Handles the following cases:

- Missing comma between ID and date.

- Spaces in station ID.

- Extra digits appended to the date field.

- Decimal point in value (e.g. `1.0` -\> `10`).

- Comma as decimal separator (e.g. `12,6` -\> `126`).

- Unit suffixes (e.g. `12mm` -\> `12`).

- Hour annotations (e.g. `19h`, `de 1730 a 1830`).

- Date-like patterns in value field (e.g. `02/07/2026`).

- "No rain" mentions -\> `"0"`.

- Trace rainfall variants -\> `"TR"`.

- Date shift: if date is yesterday, shifts to today.

## Usage

``` r
fix_sms(x, gauge = TRUE, sent_date = Sys.Date())
```

## Arguments

- x:

  A character vector of SMS texts (possibly multi-line).

- gauge:

  Logical. If `TRUE` (default), fixes against gauge SMS rules via
  [`is_gauge_sms()`](https://oousmane.github.io/smscollectr/reference/is_gauge_sms.md).
  If `FALSE`, throws an error as non-gauge fixing is not yet
  implemented.

- sent_date:

  `Date(1)`. The date the message was received. Used for date validation
  and the yesterday-shift. Defaults to
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html).

## Value

A character vector the same length as `x`, in the form
`"ID, DD-MM-YYYY, value"`, or `NA_character_` for each SMS that cannot
be fixed.

## Details

Returns `NA_character_` if the SMS is unrecoverable (no valid gauge ID,
unparseable date, future date, or older than `SMSCOLLECTR_MAX_AGE`
days).

The maximum SMS age can be configured via the environment variable
`SMSCOLLECTR_MAX_AGE`:


    Sys.setenv(SMSCOLLECTR_MAX_AGE = "10")

Fully vectorised — accepts a character vector of any length.

## See also

[`is_bad_sms()`](https://oousmane.github.io/smscollectr/reference/is_bad_sms.md),
[`is_gauge_sms()`](https://oousmane.github.io/smscollectr/reference/is_gauge_sms.md),
[`is_no_rain()`](https://oousmane.github.io/smscollectr/reference/is_no_rain.md)

## Examples

``` r
fix_sms("200068P, 24-06-2026, 12,6")                          # "200068P, 24-06-2026, 126"
#> [1] NA
fix_sms("200068P, 24-06-2026, 12mm")                          # "200068P, 24-06-2026, 12"
#> [1] NA
fix_sms("200053A , 30-06-2026, 1.0")                          # "200053A, 30-06-2026, 10"
#> [1] NA
fix_sms("200068P, 24-06-2026, TR")                            # "200068P, 24-06-2026, TR"
#> [1] NA
fix_sms("200068P, 24-06-2026, traces")                        # "200068P, 24-06-2026, TR"
#> [1] NA
fix_sms("200068P, 24-06-2026, pas de pluie")                  # "200068P, 24-06-2026, 0"
#> [1] NA
fix_sms("200034P, 23-06-2026, boussouma n'a pas eu de pluie") # "200034P, 23-06-2026, 0"
#> [1] NA
fix_sms("200043A, 03-07-2026, 008 19h")                       # "200043A, 03-07-2026, 8"
#> [1] "200043A, 04-07-2026, 8"
fix_sms("200043A, 03-07-2026, 1730 a 1830 008")               # "200043A, 03-07-2026, 8"
#> [1] "200043A, 04-07-2026, 8"
fix_sms("32mm enregistre le 12/06/26")                        # NA
#> [1] NA
```
