# Changelog

## smscollectr 0.0.2

### New features

- **Agrometeorological SMS support** —
  [`read_sms()`](https://oousmane.github.io/smscollectr/reference/read_sms.md)
  now returns an `$agro` list element containing parsed
  agrometeorological observations alongside the existing `$gauge`
  element. Two new helpers,
  [`is_agro_sms()`](https://oousmane.github.io/smscollectr/reference/is_agro_sms.md)
  and
  [`.parse_agro_sms()`](https://oousmane.github.io/smscollectr/reference/dot-parse_agro_sms.md),
  drive detection and parsing of the 17-line agro format
  (`Station / DD-MM-YYYY / Key= value` × 15).

- **[`config_auth()`](https://oousmane.github.io/smscollectr/reference/config_auth.md)**
  — new function to save a Google service account JSON key to the system
  keyring once (`config_auth("key.json")`). All subsequent sessions
  authenticate automatically without any user interaction.

- **[`set_sheet_url()`](https://oousmane.github.io/smscollectr/reference/set_sheet_url.md)
  /
  [`get_sheet_url()`](https://oousmane.github.io/smscollectr/reference/get_sheet_url.md)**
  — store and retrieve Google Sheet URLs securely via the system keyring
  (macOS Keychain, Windows Credential Manager, Linux Secret Service).
  URLs are never written to disk in plain text.

- **[`to_station_id()`](https://oousmane.github.io/smscollectr/reference/to_station_id.md)
  /
  [`to_element_id()`](https://oousmane.github.io/smscollectr/reference/to_element_id.md)**
  — lookup helpers that translate raw SMS station codes and element
  abbreviations to their canonical identifiers using an internal
  reference table (`R/sysdata.rda`, built from `data-raw/lookup.R`).

- **[`is_no_rain()`](https://oousmane.github.io/smscollectr/reference/is_no_rain.md)
  /
  [`is_bad_sms()`](https://oousmane.github.io/smscollectr/reference/is_bad_sms.md)
  /
  [`fix_sms()`](https://oousmane.github.io/smscollectr/reference/fix_sms.md)**
  — additional predicates and a fixer function exported for downstream
  use in custom workflows.

- **pkgdown website** — automated GitHub Actions workflow
  (`.github/workflows/pkgdown.yaml`) builds and deploys the reference
  site on every push to `master`. Site available at
  <https://oousmane.github.io/smscollectr/>.

### Improvements

- [`read_sms()`](https://oousmane.github.io/smscollectr/reference/read_sms.md)
  now filters out non-numeric senders (keeps only `226xxxxxxxxx`-style
  numbers) before parsing, reducing noise from gateway messages.
- [`sms_auth()`](https://oousmane.github.io/smscollectr/reference/sms_auth.md)
  gained a service-account-first auth path: if keyring credentials are
  present they are used automatically; OAuth is the fallback when
  `email` is supplied.
- `.check_auth()` is now called lazily inside
  [`read_sms()`](https://oousmane.github.io/smscollectr/reference/read_sms.md),
  so no explicit
  [`sms_auth()`](https://oousmane.github.io/smscollectr/reference/sms_auth.md)
  call is needed when keyring credentials exist.
- [`parse_sms()`](https://oousmane.github.io/smscollectr/reference/parse_sms.md)
  returns a named list `list(gauge = ..., agro = ...)` instead of a
  single tibble.

### Bug fixes

- Fixed an authentication regression where `gs4_auth()` and
  `drive_auth()` could get out of sync when switching credentials
  (#auth).

### Internal changes

- Added `R/lookup-funs.R` with internal lookup helpers backed by
  `R/sysdata.rda`.
- Added `R/zzz.R` for package-load hooks.
- Removed the `docs/` static snapshot — the site is now built by CI
  only.

------------------------------------------------------------------------

## smscollectr 0.0.1

- Initial release.
- [`read_sms()`](https://oousmane.github.io/smscollectr/reference/read_sms.md)
  — read raw SMS from a Google Sheet column.
- [`parse_sms()`](https://oousmane.github.io/smscollectr/reference/parse_sms.md)
  — parse valid rain gauge messages into a tidy tibble.
- [`is_gauge_sms()`](https://oousmane.github.io/smscollectr/reference/is_gauge_sms.md)
  — detect well-formed gauge SMS strings.
- [`clean_sheet()`](https://oousmane.github.io/smscollectr/reference/clean_sheet.md)
  — remove processed rows from the source sheet.
- [`sms_auth()`](https://oousmane.github.io/smscollectr/reference/sms_auth.md)
  — authenticate with Google Sheets (OAuth or service account).
- [`set_sheet_url()`](https://oousmane.github.io/smscollectr/reference/set_sheet_url.md)
  /
  [`get_sheet_url()`](https://oousmane.github.io/smscollectr/reference/get_sheet_url.md)
  — store and retrieve the target sheet URL via the system keyring.
