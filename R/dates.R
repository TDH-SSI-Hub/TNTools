
#' Cleans dates in a variety of formats
#'
#' @param x vector of date-like values
#' @param format string recognized by format() to format the date
#'
#' @return Date or formatted string
#' @export
tn_clean_date <- function(x, format = NA) {
  x <- as.character(x)
  x[grepl("^\\d{5}$|^\\d{5}\\..*$", x)] <- as.character(as.Date(as.numeric(x[grepl("^\\d{5}", x)]),origin = "1899-12-30"))
  new_dates<- anytime::anydate(x)
  new_dates[is.na(new_dates)]<-parsedate::parse_date(x[is.na(new_dates)])
  if(!is.na(format)){
  return(format(new_dates,format))
  }else{
    return(new_dates)
  }
}
