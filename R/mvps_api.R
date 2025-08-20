

#' Save MVPS API credentials locally
#'
#' @param client_id Client ID
#' @param scope Scope
#' @param client_secret Client Secret
#' @param subscription_key Subscription Key
#'
#' @return Nothing
#' @export
tn_mvps_credentials_set<-function(client_id,scope,client_secret,subscription_key){
  keyring::key_set_with_value('MVPS_api','client_id',client_id)
  keyring::key_set_with_value('MVPS_api','scope',scope)
  keyring::key_set_with_value('MVPS_api','client_secret',client_secret)
  keyring::key_set_with_value('MVPS_api','subscription_key',subscription_key)
}

#' Return locally saved MVPS API credentials
#'
#' @return List with necessary fields
#' @export
tn_mvps_credentials_get<-function(){
  list(  client_id=keyring::key_get('MVPS_api','client_id')
         ,scope=keyring::key_get('MVPS_api','scope')
         ,client_secret=keyring::key_get('MVPS_api','client_secret')
         ,subscription_key=keyring::key_get('MVPS_api','subscription_key'))
}

#' Pull MVPS condition categories
#'
#' @return Vector of disease categories
#' @export
tn_mvps_categories<-function(){
cats<-httr2::request('https://api.cdc.gov/mvps/1.0.0/api/Lookups/Categories') |>
  httr2::req_perform()
cats2<-httr2::resp_body_json(cats)
sapply(cats2, function(x) x$category)
}

#' Valid MVPS message types
#'
#' @return Vector of MVPS message types
#' @export
tn_mvps_message_types<-function(){
  c(
    'HL7'
    ,'NBS'
    ,'NETSS'
    ,'CSV'
    ,'MDN'
    ,'CDS'
  )
}

#' Valid MVPS case statuses
#'
#' @return Vector of MVPS case statuses
#' @export
tn_mvps_case_class_codes<-function(){
  c('Confirmed'
    ,'Probable'
    ,'Suspected'
    ,'Unknown'
    ,'Not a Case'
    ,'UI Deleted'
    ,'NETSS YTD Deleted'
    ,'Message Type Retired')
}

#' Generate an MVPS access token for use in other API calls
#'
#' You must have previously set your MVPS credentials using tn_mvps_credentials_set()
#'
#' @return Access token
#' @export
tn_mvps_jwt<-function(){
  credentials<-tn_mvps_credentials_get()
  auth_url<-'https://login.microsoftonline.com/9ce70869-60db-44fd-abe8-d2767077fc8f/oauth2/v2.0/token'
  auth_response<-httr2::request(auth_url) |>
    httr2::req_body_form("grant_type"= "client_credentials",
                  "client_id"= credentials$client_id,
                  "scope"= credentials$scope,
                  "client_secret"= credentials$client_secret,
                  "Ocp-Apim-Subscription-Key"=credentials$subscription_key) |>
    httr2::req_perform()

  return(httr2::resp_body_json(auth_response)$access_token)
}

#' Pull in linelist data from the MVPS API
#'
#' You must set the MVPS credentials on your machine using tn_mvps_credentials_set() prior to calling this function.
#' For "complete" API documentation, see https://developer.cdc.gov/docs/mvps-external-api/documentation
#'
#' @param year Integer for year of data to pull
#' @param from Integer for starting MMWR Week
#' @param to Integer for ending MMWR Week
#' @param eventCode Condition codes to pull (doesn't work currently)
#' @param category Category of event codes to pull (doesn't work currently)
#' @param classificationStatus Limit extract to these case statuses (from tn_mvps_case_class_codes())
#' @param messageType Limit extract to these message types (from tn_mvps_message_types())
#' @param reconciliationStatus Limit extract by reconciliation status
#'
#' @return Date or formatted string
#' @export
tn_mvps_linelist<-function(year=2024,from=1,to=53,
                        eventCode=NULL,
                        category=NULL,
                        classificationStatus=NULL,
                        messageType=NULL,
                        reconciliationStatus=NULL){


  url <-"https://api.cdc.gov/mvps/1.0.0/api/Reports/LineList"

  message('Pulling data')
  linelist_response<-httr2::request(url) |>
    httr2::req_headers(Authorization=paste0('Bearer ',tn_mvps_jwt())) |>
    httr2::req_body_json(data=list(mmwrYear=year,
                            mmwrWeekFrom=from,
                            mmwrWeekTo=to,
                            eventCode=eventCode,
                            category=category,
                            classificationStatus=classificationStatus,
                            messageType=messageType,
                            reconciliationStatus=reconciliationStatus)) |>
    httr2::req_perform()


  return(suppressWarnings(as.data.frame(rbindlist(httr2::resp_body_json(linelist_response)))))

}
