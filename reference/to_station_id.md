# Map a station name to its CLIDATA station code

Map a station name to its CLIDATA station code

## Usage

``` r
to_station_id(x)
```

## Arguments

- x:

  `character`. Station name(s) as they appear in the TCM or SMS.
  Matching is case-insensitive and strips surrounding whitespace.

## Value

`character` vector of CLIDATA station codes (`eg_gh_id`). Returns `NA`
with a warning for unrecognised names.

## Examples

``` r
to_station_id("DORI")              # "200026S"
#> [1] "200026S"
to_station_id("bobo-dioulasso")    # "200099S"
#> [1] "200099S"
to_station_id("UNKNOWN")           # NA + warning
#> Warning: Unrecognised station name(s): UNKNOWN
#> [1] NA
```
