# Check whether a string mentions no rainfall

Uses both exact regex and fuzzy matching to catch common misspellings of
the French phrase "pas de pluie" (no rain).

## Usage

``` r
is_no_rain(x)
```

## Arguments

- x:

  A character string.

## Value

A logical scalar.

## Examples

``` r
is_no_rain("pas de pluie")                        # TRUE
#> [1] TRUE
is_no_rain("Pa de plu")                           # TRUE
#> [1] TRUE
is_no_rain("boussouma n'a pas eu de pluie")       # TRUE
#> [1] TRUE
is_no_rain("126")                                  # FALSE
#> [1] FALSE
```
