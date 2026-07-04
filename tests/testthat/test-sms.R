# tests/testthat/test-sms.R

test_that("is_gauge_sms detects valid gauge SMS", {
  expect_true(is_gauge_sms("200001P, 03-06-2026, 125"))
  expect_true(is_gauge_sms("200096 P, 01-07-2026, 0"))
  expect_true(is_gauge_sms("200053A , 28-06-2026, 180"))
  expect_false(is_gauge_sms("hello world"))
  expect_false(is_gauge_sms("32mm le 12/06/26"))
  expect_equal(is_gauge_sms(NULL), logical(0))
})

test_that("is_no_rain catches variants", {
  expect_true(is_no_rain("pas de pluie"))
  expect_true(is_no_rain("Pa de plu"))
  expect_true(is_no_rain("boussouma n'a pas eu de pluie"))
  expect_false(is_no_rain("126"))
})

test_that("is_bad_sms identifies malformed SMS", {
  expect_false(is_bad_sms("200068P, 01-07-2026, 21"))
  expect_false(is_bad_sms("200068P, 01-07-2026, TR"))
  expect_false(is_bad_sms("200068P, 01-07-2026, pas de pluie"))
  expect_true(is_bad_sms("200068P, 01-07-2026, 12mm"))
  expect_true(is_bad_sms("200068P, 01-07-2026,"))
  expect_true(is_bad_sms("200286P, 01-07-2026, 21"))   # ID > 200166
  expect_true(is_bad_sms("200068P, 03-07-2030, 21"))   # future date
  expect_true(is_bad_sms("hello world"))
})

test_that("fix_sms repairs common malformations", {
  expect_equal(fix_sms("200068P, 01-07-2026, 12,6"),   "200068P, 01-07-2026, 126")
  expect_equal(fix_sms("200068P, 01-07-2026, 12mm"),   "200068P, 01-07-2026, 12")
  expect_equal(fix_sms("200053A , 01-07-2026, 1.0"),   "200053A, 01-07-2026, 10")
  expect_equal(fix_sms("200068P, 01-07-2026, TR"),     "200068P, 01-07-2026, TR")
  expect_equal(fix_sms("200068P, 01-07-2026, traces"), "200068P, 01-07-2026, TR")
  expect_equal(fix_sms("200068P, 01-07-2026, pas de pluie"), "200068P, 01-07-2026, 0")
  expect_equal(fix_sms("200068P  01-07-2026, 21"),     "200068P, 01-07-2026, 21")
  expect_equal(fix_sms("200043A, 01-07-2026, 008 19h"),"200043A, 01-07-2026, 8")
  expect_equal(fix_sms("200043A, 01-07-2026, 1730 a 1830 008"), "200043A, 01-07-2026, 8")
  expect_true(is.na(fix_sms("32mm le 12/06/26")))
  expect_true(is.na(fix_sms("200068P, 03-07-2030, 21")))  # future
})

test_that("fix_sms is vectorised", {
  result <- fix_sms(c("200068P, 01-07-2026, 12mm", "32mm le 12/06/26"))
  expect_equal(result[1], "200068P, 01-07-2026, 12")
  expect_true(is.na(result[2]))
})

test_that(".parse_sms date rules relative to sent_date", {
  sent <- as.Date("2026-07-03")

  # body == sent_date → shift to sent_date - 1
  r <- smscollectr:::.parse_sms("200068P, 03-07-2026, 21", sent_date = sent)
  expect_equal(r$day, 2L)
  expect_equal(r$month, 7L)

  # body < sent_date, within max_age → parsed as body date
  r <- smscollectr:::.parse_sms("200068P, 02-07-2026, 21", sent_date = sent)
  expect_equal(r$day, 2L)

  # body > sent_date → rejected
  r <- smscollectr:::.parse_sms("200068P, 04-07-2026, 21", sent_date = sent)
  expect_true(is.na(r$eg_gh_id))

  # body < sent_date, beyond max_age → rejected
  r <- smscollectr:::.parse_sms("200068P, 28-06-2026, 21", sent_date = sent)
  expect_true(is.na(r$eg_gh_id))
})

test_that("parse_sms returns correct structure", {
  sent   <- as.Date("2026-07-01")
  result <- parse_sms("200068P, 01-07-2026, 125", sent_dates = sent)
  expect_named(result, c("gauge", "agro"))
  expect_s3_class(result$gauge, "tbl_df")
  expect_equal(nrow(result$gauge), 1)
  expect_equal(result$gauge$eg_gh_id, "200068P")
  expect_equal(result$gauge$value, 12.5)
})

test_that("parse_sms handles TR correctly", {
  result <- parse_sms("200068P, 01-07-2026, TR", sent_dates = as.Date("2026-07-01"))
  expect_equal(result$gauge$value, 0)
  expect_equal(result$gauge$flag, "T")
})

test_that("parse_sms deduplicates keeping last", {
  sent   <- as.Date(c("2026-07-01", "2026-07-01"))
  result <- parse_sms(c(
    "200068P, 01-07-2026, 10",
    "200068P, 01-07-2026, 20"
  ), sent_dates = sent)
  expect_equal(nrow(result$gauge), 1)
  expect_equal(result$gauge$value, 2)  # 20/10
})

test_that("parse_sms returns empty tibbles for invalid input", {
  result <- parse_sms("hello world")
  expect_equal(nrow(result$gauge), 0)
  expect_equal(nrow(result$agro), 0)
})

test_that("set_sms_max_age and get_sms_max_age work", {
  set_sms_max_age(10)
  expect_equal(get_sms_max_age(), 10L)
  set_sms_max_age(3)  # reset
  expect_equal(get_sms_max_age(), 3L)
})
