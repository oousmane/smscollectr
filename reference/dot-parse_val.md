# Parse a raw SMS value into a numeric value and quality flag

Internal helper. Interprets a raw string extracted from an SMS message
and returns a named list with the physical value and a quality flag.

## Usage

``` r
.parse_val(raw, divisor = 10)
```

## Arguments

- raw:

  `character(1)`. Raw string extracted from the SMS message.

- divisor:

  `numeric(1)`. Value to divide the numeric raw value by. Default `10`.

## Value

A named `list` with two elements:

- `value`:

  `numeric`. Physical value, or `0`, `-9999`, or `NA`.

- `flag`:

  `character`. `"T"` for trace, `"M"` for missing, `NA` otherwise.

## Details

Recognised special strings (case-insensitive):

- `TR`, `Tr`, `tR`, `tr`:

  Trace — returns `value = 0`, `flag = "T"`.

- `NT`, `Nt`, `nT`, `nt`:

  Not measured — returns `value = 0`, `flag = NA`.

- `xx`, `XX`, `Xx` (and `xxx` variants):

  Missing — returns `value = -9999`, `flag = "M"`.
