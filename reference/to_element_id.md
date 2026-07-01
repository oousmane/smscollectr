# Map a TCM variable name to its CLIDATA element abbreviation

Map a TCM variable name to its CLIDATA element abbreviation

## Usage

``` r
to_element_id(x)
```

## Arguments

- x:

  `character`. Internal TCM variable name(s) (e.g. `"TMIN"`, `"TS-10"`,
  `"WDD"`).

## Value

`character` vector of CLIDATA element abbreviations
(`eg_el_abbreviation`). Returns `NA` with a warning for unrecognised
names.

## Examples

``` r
to_element_id("Tn")    # "TMIN"
#> [1] "TMIN"
to_element_id("T-10")   # "TS-10"
#> [1] "TS-10"
to_element_id("UNKNOWN") # NA + warning
#> Warning: Unrecognised element name(s): UNKNOWN
#> [1] NA
```
