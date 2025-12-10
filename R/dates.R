
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



#' Send a single line to the NIOSH API
#' @param i The industry string
#' @param o The occupation string
#' @param id The ID string/numeric
#' @export
niosh_api_single<-function(i,o,id){
  results<-jsonlite::fromJSON(httr::content(httr::GET("https://wwwn.cdc.gov/nioccs/IOCode", query = list(i = i, o = o, c="1")), as="text"))

  out_df<-data.frame(matrix(c(id, unlist(results)[1:6]), ncol=7))
  names(out_df)<-c('ID','Industry_Code','Industry_Title','Industry_Score'
                   ,'Occupation_Code','Occupation_Title','Occupation_Score')
  out_df
}

#' Standardize a dataframe of industries and occupations
#'
#' This function outputs a dataframe with an ID column, and codes, tiles, and match scores for industry and occupation.
#'
#' @param df A dataframe with industry and occupation columns
#' @param id_col String with the column name for the ID. Optional, will be assigned to row number if absent.
#' @param industry_col String with the column name for the industry.
#' @param occupation_col String with the column name for the occupation.
#' @export
tn_niosh_api<-function(df,id_col=NA,industry_col='Industry',occupation_col='Occupation'){
  if(is.na(id_col)){
    id_col<-'niosh_id'
    df[,id_col]<-1:nrow(df)
  }

  df2<-data.frame(matrix(NA,ncol = 7, nrow=nrow(df)))
  colnames(df2)<-c(id_col,'Industry_Code','Industry_Title','Industry_Score','Occupation_Code','Occupation_Title','Occupation_Score')

  pb <- progress::progress_bar$new(
    format = "  NIOSH API [:bar] :current/:total (:percent) in :elapsed eta: :eta",
    total = nrow(df), clear = FALSE, width= 80)

  tickmark<-pb$tick(0)

  for (x in 1:nrow(df2)){
    df2[x,]<-niosh_api_single(i=df[x,industry_col]
                              ,o=df[x,occupation_col]
                              ,df[x,id_col])
    pb$tick(1)
  }
  df2
}

