#' Transforms tracer concentrations into normalized values between 0 and 1
#' 
#' @param MCS_input A list of sample Data frames created by 
#' [get_all_sample_concentrations()]
#' 
#' @details Normalization per tracer by equation: \cr
#' (c_i - min(c)) / (max(c) - min(c)) \cr
#' This results in values between 0 (equals the overall minimal value of the
#' tracer within all samples) and 1 (equals the overall maximal value of the
#' tracer within all samples). 
#' 
#' @return 
#' Same structured list as the input with normalized values instead of absolute
#' concentrations
#' 
#' @export
#' 
normalize_MCS_input <- function(
    MCS_input
){
  tracer_ranges <- get_concentration_ranges(MCS_input = MCS_input)
  lapply(MCS_input, function(df){
    sapply(colnames(tracer_ranges), function(x){
      (df[,x] - tracer_ranges[1,x]) / diff(tracer_ranges[,x])
    })
  })
}

#' Find minimum and maximum of the tracers in all samples (including MCS)
#' 
#' @param MCS_input A list of sample Data frames created by 
#' [get_all_sample_concentrations()]
#' 
#' @return 
#' 
#' @export
#' 
get_concentration_ranges <- function(MCS_input){
  tracer_max <- sapply(MCS_input, function(df){apply(df, 2, max)})
  tracer_min <- sapply(MCS_input, function(df){apply(df, 2, min)})
  apply(cbind(tracer_max, tracer_min), 1, range)
}