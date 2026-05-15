#' @keywords internal
"_PACKAGE"

#' @importFrom dplyr bind_rows filter if_all everything group_by slice_tail
#'   ungroup mutate select pull
#' @importFrom googlesheets4 read_sheet range_delete gs4_auth gs4_has_token
#' @importFrom keyring key_set_with_value key_get key_list
#' @importFrom purrr map
#' @importFrom rlang .data
#' @importFrom tibble tibble
NULL

utils::globalVariables(c("month", "day"))