#' Loads CSV-Data table
#' 
#' The CSV table must contain one row per measurement and standard column names
#' as defined in the details section
#' 
#' @param path The filepath 
#' @param file The filename including the ".csv" ending
#' 
#' @details 
#' Required table column names: \cr
#' - sample_name: unique ID  of the sample (at least unique per sampling campaign) \cr
#' - sampling_campaign: unique ID of the sampling campaign \cr
#' - tBeg: starting time of the sample (format: "YYYY-mm-dd HH:MM:SS") \cr
#' - tEnd: ending time of the sample (format: "YYYY-mm-dd HH:MM:SS") \cr
#' - operator: definition of LOD-relation (either "<", ">" or empty) \cr
#' - value: measured value \cr
#' - parameter: unique name of the measured parameter (this parameter is used 
#' column name after reshaping the table, so it should not start with a number 
#' or contain any special symbols or spaces) \cr
#' - unit: the unit of the measured value
#' 
#' @return
#' A data frame corresding to the csv file, with date columns specified as 
#' POSIXct
#' 
#' @importFrom utils read.csv
#' 
#' @export
load_lab_data <- function(
    path, file
){
  data <- read.csv(file = file.path(path, file), 
                   header = TRUE, sep = ";", dec = ".")
  
  data$tBeg <- as.POSIXct(data$tBeg, tz = "CET", format = "%Y-%m-%d %H:%M:%S")
  data$tEnd <- as.POSIXct(data$tEnd, tz = "CET", format = "%Y-%m-%d %H:%M:%S")
  data
}

#' Check for unique units per parameter
#' 
#' @param df_in Data frame loaded with [load_lab_data()]
#' 
#' @return 
#' Returns either a warning or a confirmation
#' 
#' @export
#' 
check_for_units <- function(
    df_in
){
  paras <- unique(df_in$parameter)
  units <- lapply(paras, function(x){
    unique(df_in$unit[df_in$parameter == x])
  })
  
  to_many_units <- which(sapply(units, length) > 1)
  if(length(to_many_units) > 0L){
    warning(paste(paras[to_many_units], collapse =  ", "), " have more than", 
            " one unit in data set.")
  } else {
      cat("One unit per parameter -> Data can be aggregated.")
    }
}


#' Reshape Data to Parameter-as-Columns-Structure
#' 
#' This function keeps the columns "sample_name", "sampling_campaign", "tBeg", 
#' "tEnd" and adds one column per parameter. The operators are taken into
#' account.
#' 
#' @param df_in Data frame loaded with [load_lab_data()]
#' @param sampling_campaigns One or more sampling Campaign IDs to be considered
#' @param bLOD Character string defining the handling of operator "<" (below 
#' limit of detection). Either "half" for dividing the value by 2, "zero" or 
#' "na" for setting the value to 0 or NA, respectively.
#' @param aLOD Character string defining the handling of operator ">" (above 
#' limit of detection). Either "double" for multiplying the value by 2, 
#' "use_limit" for using the limit value or "na" for setting the value to NA.
#' 
#' @return 
#' A data frame of all data per sample in a row, arranged by the 
#' starting time of the sample.
#' 
#' @importFrom tidyr spread
#' @export
#' 
reshape_table <- function(
    df_in, sampling_campaigns, bLOD = "na", aLOD = "na"
){
  df_in <- df_in[df_in$sampling_campaign %in% sampling_campaigns,]
  
  bLODrows <- which(df_in$operator == "<")
  aLODrows <- which(df_in$operator == ">")
  
  df_in$value[bLODrows] <- 
    if(bLOD == "half"){
      df_in$value[bLODrows] / 2
    } else if(bLOD == "zero"){
      0
    } else if(bLOD == "na"){
      NA
    }
  
  df_in$value[aLODrows] <- 
    if(aLOD == "double"){
      df_in$value[aLODrows] * 2
    } else if(aLOD == "na"){
      NA
    }
  
  df_out <- 
    df_in[,c("sampling_campaign", 
             "sample_name", 
             "tBeg", 
             "tEnd",  
             "value", 
             "parameter")]
  
  parameter <- value <- NULL
  
  df_out %>% 
    tidyr::spread(key = parameter, value = value)
}
