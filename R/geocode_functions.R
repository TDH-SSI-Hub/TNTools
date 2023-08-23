
#' Function to interface with the TN geocoder. Needs a lot of love.
#'
#' @param df dataframe to use and return with additional columns
#' @param match_on Named character vector of columns in the dataframe that map to geocoded elements.
#'  geocoder_name=df_name
#' @param return_fields Character vector of fields to return. Check TN geocoder site for options.
#'
#' @return Dataframe with added columns from geocoder
#' @export
geocode_address<-function(df,
                          match_on=c('address'='pt_address'
                                     ,'city'='pt_city'
                                     ,'region'='pt_state'
                                     ,'postal'='pt_zip'
                          )
                          , return_fields=c('Score','Match_addr','Subregion','X','Y')){

  df$OBJECTID<-1:nrow(df)

  geo_df<-data.frame(OBJECTID=df$OBJECTID)
  new_col<-names(match_on)
  for(j in 1:length(match_on)){
    geo_df[,new_col[j]]<-df[,match_on[j]]
  }

  geocode_response<-list()
  batch_size<-10

  for(i in 1:ceiling((nrow(geo_df)/batch_size))){
    # Put the dataframe in a list
    jlist<-list("records"=geo_df[((i-1)*batch_size+1):min(i*batch_size,nrow(geo_df)),])


    # The sketchy part
    # Add the attributes header thing to each 'line' in the dataframe
    j1<-gsub('\\{\\\"OBJECTID\"','\\{\\\"attributes\\\":\\{\\\"OBJECTID\"',as.character(jsonlite::toJSON(jlist)))
    # Close the brackets we just opened
    j2<-gsub('\\},','\\}\\},',j1) # in the middle
    j3<-gsub('\\}\\]','\\}\\}\\]',j2) # last bracket

    # Request to the geocoding API
    response <- httr::POST(geocoding_api_url,
                     query = list(
                       addresses = j3
                       ,f = "pjson"
                     )
    )

    # Parse the JSON response
    res_df<-tidyr::unnest(as.data.frame(jsonlite::fromJSON(rawToChar(response$content))),tidyr::everything())

    geocode_response[[length(geocode_response)+1]] <- res_df

  }



  all_data<-as.data.frame(data.table::rbindlist(geocode_response))

  all_data<-all_data[,c('ResultID',return_fields)]

  out_data<-merge(df,all_data, by.x = 'OBJECTID', by.y = 'ResultID', all = T)
  out_data<-out_data[,colnames(out_data)!='OBJECTID']

  return(out_data)

}
