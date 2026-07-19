# tests/testthat/test-sms.R


test_that("fix_sms repairs common malformations", {
  d2 <- format(Sys.Date() - 2, "%d-%m-%Y") # ni "hier" (décalage), ni trop vieux
  future <- format(Sys.Date() + 3650, "%d-%m-%Y")

  expect_equal(fix_sms(paste0("200068P, ", d2, ", 12,6")), paste0("200068P, ", d2, ", 126"))
  expect_equal(fix_sms(paste0("200068P, ", d2, ", 12mm")), paste0("200068P, ", d2, ", 12"))
  expect_equal(fix_sms(paste0("200053A , ", d2, ", 1.0")), paste0("200053A, ", d2, ", 10"))
  expect_equal(fix_sms(paste0("200068P, ", d2, ", TR")), paste0("200068P, ", d2, ", TR"))
  expect_equal(fix_sms(paste0("200068P, ", d2, ", traces")), paste0("200068P, ", d2, ", TR"))
  expect_equal(fix_sms(paste0("200068P, ", d2, ", pas de pluie")), paste0("200068P, ", d2, ", 0"))
  expect_equal(fix_sms(paste0("200068P  ", d2, ", 21")), paste0("200068P, ", d2, ", 21"))
  expect_equal(fix_sms(paste0("200043A, ", d2, ", 008 19h")), paste0("200043A, ", d2, ", 8"))
  expect_equal(fix_sms(paste0("200043A, ", d2, ", 1730 a 1830 008")), paste0("200043A, ", d2, ", 8"))
  expect_true(is.na(fix_sms("32mm le 12/06/26")))
  expect_true(is.na(fix_sms(paste0("200068P, ", future, ", 21")))) # future
})

test_that("fix_sms shifts a yesterday date to sent_date (morning report)", {
  yesterday <- format(Sys.Date() - 1, "%d-%m-%Y")
  today <- format(Sys.Date(), "%d-%m-%Y")
  expect_equal(
    fix_sms(paste0("200068P, ", yesterday, ", 21")),
    paste0("200068P, ", today, ", 21")
  )
})

test_that("fix_sms is vectorised", {
  d2 <- format(Sys.Date() - 2, "%d-%m-%Y")
  result <- fix_sms(c(paste0("200068P, ", d2, ", 12mm"), "32mm le 12/06/26"))
  expect_equal(result[1], paste0("200068P, ", d2, ", 12"))
  expect_true(is.na(result[2]))
})
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
  yesterday <- format(Sys.Date() - 1, "%d-%m-%Y")
  future <- format(Sys.Date() + 3650, "%d-%m-%Y")

  expect_false(is_bad_sms(paste0("200068P, ", yesterday, ", 21")))
  expect_false(is_bad_sms(paste0("200068P, ", yesterday, ", TR")))
  expect_false(is_bad_sms(paste0("200068P, ", yesterday, ", pas de pluie")))
  expect_true(is_bad_sms(paste0("200068P, ", yesterday, ", 12mm")))
  expect_true(is_bad_sms(paste0("200068P, ", yesterday, ",")))
  expect_true(is_bad_sms(paste0("200286P, ", yesterday, ", 21"))) # ID > 200166
  expect_true(is_bad_sms(paste0("200068P, ", future, ", 21"))) # future date
  expect_true(is_bad_sms("hello world"))
})



test_that(".parse_sms date rules relative to sent_date", {
  old_max_age <- Sys.getenv("SMSCOLLECTR_MAX_AGE", unset = NA_character_)

  on.exit(
    {
      if (is.na(old_max_age)) {
        Sys.unsetenv("SMSCOLLECTR_MAX_AGE")
      } else {
        Sys.setenv(SMSCOLLECTR_MAX_AGE = old_max_age)
      }
    },
    add = TRUE
  )

  smscollectr::set_sms_max_age(days = 30)

  sent <- as.Date("2026-07-03")

  # body == sent_date → shift to sent_date - 1
  r <- smscollectr:::.parse_sms("200068P, 03-07-2026, 21", sent_date = sent)
  expect_equal(r$day, 2L)
  expect_equal(r$month, 7L)

  # body < sent_date, within max_age → parsed as body date
  r <- smscollectr:::.parse_sms("200068P, 02-07-2026, 21", sent_date = sent)
  expect_equal(r$day, 2L)
  expect_equal(r$month, 7L)
  expect_false(is.na(r$eg_gh_id))

  # body > sent_date → rejected
  r <- smscollectr:::.parse_sms("200068P, 04-07-2026, 21", sent_date = sent)
  expect_true(is.na(r$eg_gh_id))

  # body < sent_date, within configured max_age → accepted
  r <- smscollectr:::.parse_sms("200068P, 28-06-2026, 21", sent_date = sent)
  expect_equal(r$day, 28L)
  expect_equal(r$month, 6L)
  expect_false(is.na(r$eg_gh_id))

  # body < sent_date, beyond configured max_age → rejected
  r <- smscollectr:::.parse_sms("200068P, 02-06-2026, 21", sent_date = sent)
  expect_true(is.na(r$eg_gh_id))
})

test_that("parse_sms returns correct structure", {
  sent <- as.Date("2026-07-01")
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
  sent <- as.Date(c("2026-07-01", "2026-07-01"))
  result <- parse_sms(c(
    "200068P, 01-07-2026, 10",
    "200068P, 01-07-2026, 20"
  ), sent_dates = sent)
  expect_equal(nrow(result$gauge), 1)
  expect_equal(result$gauge$value, 2) # 20/10
})

test_that("parse_sms returns empty tibbles for invalid input", {
  result <- parse_sms("hello world")
  expect_equal(nrow(result$gauge), 0)
  expect_equal(nrow(result$agro), 0)
})

test_that("set_sms_max_age and get_sms_max_age work", {
  set_sms_max_age(10)
  expect_equal(get_sms_max_age(), 10L)
  set_sms_max_age(3) # reset
  expect_equal(get_sms_max_age(), 3L)
})
