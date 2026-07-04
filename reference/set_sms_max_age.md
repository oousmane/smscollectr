# Set the maximum SMS age

Convenience wrapper around
[`Sys.setenv()`](https://rdrr.io/r/base/Sys.setenv.html) to set the
maximum acceptable age (in days) for SMS messages. Equivalent to
`Sys.setenv(SMSCOLLECTR_MAX_AGE = days)`.

## Usage

``` r
set_sms_max_age(days = 3L)
```

## Arguments

- days:

  `integer(1)`. Maximum age in days. Default `3`.

## Value

Invisibly returns `days`.

## See also

[`get_sms_max_age()`](https://oousmane.github.io/smscollectr/reference/get_sms_max_age.md)

## Examples

``` r
set_sms_max_age(10)   # accept SMS up to 10 days old
set_sms_max_age()     # reset to default (3)
```
