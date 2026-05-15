#' Delete all data rows from a Google Sheet
#'
#' Reads a Google Sheet and deletes all data rows, preserving the header row.
#' Has no effect if the sheet is already empty.
#'
#' @param url `character(1)`. Full URL of the Google Sheet.
#'
#' @return Invisibly returns the number of deleted rows (`integer`).
#'   Returns `0L` if the sheet was already empty.
#'
#' @examples
#' \dontrun{
#' url <- "https://docs.google.com/spreadsheets/d/SHEET_ID/edit"
#' clean_sheet(url)
#' }
#'
#' @export
#' 
clean_sheet <- function(url) {
  
  .check_auth()
  
  stopifnot(is.character(url), length(url) == 1, nchar(url) > 0)
  
  df <- tryCatch(
    googlesheets4::read_sheet(url),
    error = function(e) stop("Failed to read sheet: ", conditionMessage(e))
  )
  
  nrows <- nrow(df)
  
  if (nrows == 0) {
    message("Sheet is already empty.")
    return(invisible(0L))
  }
  
  tryCatch(
    googlesheets4::range_delete(
      ss    = url,
      range = paste0("2:", nrows + 1),
      shift = "up"
    ),
    error = function(e) stop("Failed to delete rows: ", conditionMessage(e))
  )
  
  message(nrows, " row(s) deleted.")
  invisible(nrows)
}