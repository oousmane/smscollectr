# Save service account credentials to the system keyring

Reads a service account JSON key file and stores its contents securely
in the system keyring. After this, authentication is fully automatic, no
arguments needed in any session.

## Usage

``` r
config_auth(path, overwrite = FALSE)
```

## Arguments

- path:

  `character(1)`. Path to the service account JSON key file.

- overwrite:

  `logical(1)`. Overwrite if already exists. Default `FALSE`.

## Value

Invisibly returns `TRUE`.

## Examples

``` r
if (FALSE) { # \dontrun{
config_auth("~/Downloads/key.json")  # once
} # }
```
