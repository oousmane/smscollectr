# Check whether a string is a valid agrometeorological SMS

A valid agrometeorological SMS starts with a plain station name on line
1, followed by a full date in `DD-MM-YYYY` format on line 2, then a
series of `Key= value` lines.

## Usage

``` r
is_agro_sms(text = NULL)
```

## Arguments

- text:

  `character` vector of SMS strings to check. `NULL` is accepted and
  returns `logical(0)`.

## Value

A `logical` vector the same length as `text`.

## See also

[`is_gauge_sms()`](https://oousmane.github.io/smscollectr/reference/is_gauge_sms.md)

## Examples

``` r
msg <- "DEDOUGOU\n11-05-2026\nTn= 305\nTx= 438"
is_agro_sms(msg)                          # TRUE
#> [1] FALSE
is_agro_sms("200001S, 03-06-2026, 125")   # FALSE
#> [1] FALSE
is_agro_sms(NULL)                         # logical(0)
#> logical(0)
```
