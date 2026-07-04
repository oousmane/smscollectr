# tests/testthat/test-read_sms.R

# Fake sheet returned by mocked read_sheet
fake_sheet <- function(rows) {
  tibble::tibble(
    date   = rows$date,
    sender = rows$sender,
    name   = NA,
    sms    = rows$sms
  )
}

with_mocked_read_sms <- function(sheet_tbl, code) {
  withr::with_envvar(list(SMSCOLLECTR_MAX_AGE = "30"), {
    testthat::local_mocked_bindings(
      read_sheet  = function(...) sheet_tbl,
      gs4_has_token = function(...) TRUE,
      .package = "googlesheets4"
    )
    force(code)
  })
}

test_that("read_sms parses valid gauge SMS and returns correct structure", {
  sheet <- fake_sheet(data.frame(
    date   = "July 1, 2026 at 06:00AM",
    sender = "22655018202",
    sms    = "200068P, 01-07-2026, 125",
    stringsAsFactors = FALSE
  ))

  with_mocked_read_sms(sheet, {
    result <- read_sms("https://docs.google.com/spreadsheets/d/fake/edit")
  })

  expect_named(result, c("gauge", "agro", "bad", "raw"))
  expect_equal(nrow(result$gauge), 1)
  expect_equal(result$gauge$eg_gh_id, "200068P")
  expect_equal(result$gauge$value, 12.5)
  expect_equal(nrow(result$bad), 0)
})

test_that("read_sms shifts body==sent_date to sent_date-1", {
  sheet <- fake_sheet(data.frame(
    date   = "July 3, 2026 at 06:00AM",
    sender = "22655018202",
    sms    = "200068P, 03-07-2026, 100",
    stringsAsFactors = FALSE
  ))

  with_mocked_read_sms(sheet, {
    result <- read_sms("https://docs.google.com/spreadsheets/d/fake/edit")
  })

  expect_equal(result$gauge$day,   2L)
  expect_equal(result$gauge$month, 7L)
})

test_that("read_sms flags future-date SMS as bad and does not parse them", {
  sheet <- fake_sheet(data.frame(
    date   = "July 1, 2026 at 06:00AM",
    sender = "22655018202",
    sms    = "200068P, 05-07-2026, 100",
    stringsAsFactors = FALSE
  ))

  with_mocked_read_sms(sheet, {
    result <- read_sms("https://docs.google.com/spreadsheets/d/fake/edit")
  })

  expect_equal(nrow(result$gauge), 0)
  expect_equal(nrow(result$bad),   1)
  expect_equal(result$bad$bad_reason, "future date")
})

test_that("read_sms flags late-submission SMS as bad and still parses them", {
  sheet <- fake_sheet(data.frame(
    date   = "July 3, 2026 at 06:00AM",
    sender = "22655018202",
    sms    = "200068P, 01-07-2026, 100",
    stringsAsFactors = FALSE
  ))

  with_mocked_read_sms(sheet, {
    result <- read_sms("https://docs.google.com/spreadsheets/d/fake/edit")
  })

  expect_equal(nrow(result$gauge), 1)
  expect_equal(result$gauge$day, 1L)
  expect_equal(nrow(result$bad), 1)
  expect_equal(result$bad$bad_reason, "late submission")
})

test_that("read_sms flags too-old SMS as bad and does not parse them", {
  sheet <- fake_sheet(data.frame(
    date   = "July 3, 2026 at 06:00AM",
    sender = "22655018202",
    sms    = "200068P, 01-06-2026, 100",
    stringsAsFactors = FALSE
  ))

  with_mocked_read_sms(sheet, {
    result <- read_sms("https://docs.google.com/spreadsheets/d/fake/edit")
  })

  expect_equal(nrow(result$gauge), 0)
  expect_equal(nrow(result$bad),   1)
  expect_equal(result$bad$bad_reason, "too old")
})

test_that("read_sms filters out non-numeric senders", {
  sheet <- fake_sheet(data.frame(
    date   = c("July 1, 2026 at 06:00AM", "July 1, 2026 at 07:00AM"),
    sender = c("Telecel", "22655018202"),
    sms    = c("200068P, 01-07-2026, 50", "200068P, 01-07-2026, 100"),
    stringsAsFactors = FALSE
  ))

  with_mocked_read_sms(sheet, {
    result <- read_sms("https://docs.google.com/spreadsheets/d/fake/edit")
  })

  expect_equal(nrow(result$raw), 1)
  expect_equal(result$gauge$value, 10)
})

test_that("read_sms bad_reason is 'malformed' for structurally broken SMS", {
  sheet <- fake_sheet(data.frame(
    date   = "July 1, 2026 at 06:00AM",
    sender = "22655018202",
    sms    = "hello world",
    stringsAsFactors = FALSE
  ))

  with_mocked_read_sms(sheet, {
    result <- read_sms("https://docs.google.com/spreadsheets/d/fake/edit")
  })

  expect_equal(nrow(result$bad), 1)
  expect_equal(result$bad$bad_reason, "malformed")
})

test_that("sent_dates stay aligned when bad SMS are dropped mid-vector", {
  # First SMS is unfixable (bad, becomes NA after fix_sms).
  # Second SMS body == sent_date and should shift to sent_date-1.
  # Bug: if sds lost alignment, second SMS would get wrong sent_date.
  sheet <- fake_sheet(data.frame(
    date   = c("July 3, 2026 at 06:00AM", "July 3, 2026 at 06:30AM"),
    sender = c("22655018202",              "22655018202"),
    sms    = c("not_an_sms_at_all",        "200068P, 03-07-2026, 80"),
    stringsAsFactors = FALSE
  ))

  with_mocked_read_sms(sheet, {
    result <- read_sms("https://docs.google.com/spreadsheets/d/fake/edit")
  })

  expect_equal(nrow(result$gauge), 1)
  expect_equal(result$gauge$day, 2L)  # shifted to July 2, not some wrong date
})
