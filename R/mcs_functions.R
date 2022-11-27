#' Random concentrations in all samples based on measured data and assumed 
#' deviation
#' 
#' @param input_table Data frame reshaped by function [reshape_table()]
#' @param predictor_samples A character vector of names of samples used 
#' for predicting the substance concentration of the remaining samples.
#' @param tracer_names A vector of character strings defining the tracers used
#' @param MCS_runs The number of random samples drawn 
#' (Monte-Carlo-Simulation runs)
#' @param rel_deviation Either one numeric value between 0 and 1 defining the 
#' standard deviation relative to the measured value for all tracers or a vector
#' of the same length as 'tracer_names' defining a deviation for each tracer
#' 
#' @return
#' A List of data frames with columns corresponding to the tracers and 
#' rows correspoding to the Monte Carlo runs. The predictor samples are the 
#' first three entries and are named "A", "B" and "C"
#' 
#' @export
#' 
get_all_sample_concentrations <- function(
    input_table, predictor_samples, tracer_names,  MCS_runs, rel_deviation
){
  dl_out <- lapply(
    predictor_samples, 
    get_varrying_sample_concentration, 
    input_table = input_table, 
    tracer_names = tracer_names, 
    MCS_runs = MCS_runs, 
    rel_deviation = rel_deviation
  )
  names(dl_out) <- LETTERS[1:length(dl_out)]
  
  remaining_samples <- input_table$sample_name[
    !(input_table$sample_name %in% predictor_samples)]
  
  dl_out2 <- lapply(
    remaining_samples , 
    get_varrying_sample_concentration, 
    input_table = input_table, 
    tracer_names = tracer_names, 
    MCS_runs = MCS_runs, 
    rel_deviation = rel_deviation
  )
  names(dl_out2) <- remaining_samples
  
  dl_out <- c(dl_out, dl_out2)
  discard_na_samples(MCS_input = dl_out)
}


#' Random concentrations in sample based on measured data and assumed deviation
#' 
#' @param input_table Data frame reshaped by function [reshape_table()]
#' @param sample_name A character string defining the sample
#' @param tracer_names A vector of character strings defining the tracers used
#' @param MCS_runs The number of random samples drawn 
#' (Monte-Carlo-Simulation runs)
#' @param rel_deviation Either one numeric value between 0 and 1 defining the 
#' standard deviation relative to the measured value for all tracers or a vector
#' of the same length as 'tracer_names' defining a deviation for each tracer
#' 
#' @return
#' A data frame, columns corresponding to the tracers and rows correspoding to
#' the runs.
#' 
#' @importFrom stats rnorm 
#' @export
#' 
get_varrying_sample_concentration <- function(
    input_table, sample_name, tracer_names, MCS_runs, rel_deviation
){
  row_filter <- which(input_table$sample_name == sample_name)
  if(length(row_filter) < 1L){
    stop("Defined samples not found in the input table. Any Typos?")
  } else if(length(row_filter) > 1L){
    stop(sample_name, " is no unique Sample ID.")
  }
  col_filter <- which(colnames(input_table) %in% tracer_names)
  if(length(col_filter) < length(tracer_names)){
    stop("Not all defined tracers found in the input table. Any Typos?")
  }
  
  df_pro <- input_table[row_filter, c("sample_name", tracer_names)]
  
  if(length(rel_deviation) < length(tracer_names)){
    rel_deviation <- rep(rel_deviation, length(tracer_names))
  }
  
  df_out <- sapply(seq_along(tracer_names), function(i){
    measured_value <- df_pro[[i + 1]]
    if(is.na(measured_value)){
      rep(NA, MCS_runs)
    } else {
      rnorm(
        n = MCS_runs, 
        mean = measured_value, 
        sd = measured_value * rel_deviation[i]
      )
    }
  })
  
  colnames(df_out) <- tracer_names
  df_out
}


#' Removes all samples without complete tracer data
#' 
#' @param MCS_input A list of tracer concentrations per sample
#' 
#' @return 
#' A list of tracer concentrations per sample
#' 
discard_na_samples <- function(MCS_input){
  somethings_missing <- sapply(MCS_input, function(x){any(is.na(x))})
  if(sum(somethings_missing) > 0L){
    warning(paste(names(MCS_input)[somethings_missing], collapse =  ", "), 
            " do not have a complete tracer data set and are removed.")
  } 
  enough_data <- which(!somethings_missing)
  MCS_input[enough_data]
}