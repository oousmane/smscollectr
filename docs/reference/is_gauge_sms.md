# Check whether a string is a valid rain gauge SMS

A valid SMS starts with a 6-digit station identifier followed by one of
`P`, `S`, `A`, or `C`, then a comma (e.g. `"200001S, 03-06-2026, 125"`).

## Usage

``` r
is_gauge_sms(text = NULL)
```

## Arguments

- text:

  `character` vector of SMS strings to check. `NULL` is accepted and
  returns `logical(0)`.

## Value

A `logical` vector the same length as `text`.

## Examples

``` r
is_gauge_sms("200001S, 03-06-2026, 125")  # TRUE
#> [1] TRUE
is_gauge_sms("hello world")               # FALSE
#> [1] FALSE
is_gauge_sms(NULL)                        # logical(0)
#> logical(0)
```
