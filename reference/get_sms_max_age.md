# Get the maximum SMS age

Returns the current maximum acceptable age (in days) for SMS messages,
as set by `SMSCOLLECTR_MAX_AGE` or
[`set_sms_max_age()`](https://oousmane.github.io/smscollectr/reference/set_sms_max_age.md).

## Usage

``` r
get_sms_max_age()
```

## Value

An `integer` scalar.

## See also

[`set_sms_max_age()`](https://oousmane.github.io/smscollectr/reference/set_sms_max_age.md)

## Examples

``` r
get_sms_max_age()   # 3 (default)
#> [1] 3
```
