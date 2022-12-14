% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_and_reshape.R
\name{load_lab_data}
\alias{load_lab_data}
\title{Loads CSV-Data table}
\usage{
load_lab_data(path, file)
}
\arguments{
\item{path}{The filepath}

\item{file}{The filename including the ".csv" ending}
}
\value{
A data frame corresding to the csv file, with date columns specified as
POSIXct
}
\description{
The CSV table must contain one row per measurement and standard column names
as defined in the details section
}
\details{
Required table column names: \cr
\itemize{
\item sample_name: unique ID  of the sample (at least unique per sampling campaign) \cr
\item sampling_campaign: unique ID of the sampling campaign \cr
\item tBeg: starting time of the sample (format: "YYYY-mm-dd HH:MM:SS") \cr
\item tEnd: ending time of the sample (format: "YYYY-mm-dd HH:MM:SS") \cr
\item operator: definition of LOD-relation (either "<", ">" or empty) \cr
\item value: measured value \cr
\item parameter: unique name of the measured parameter (this parameter is used
column name after reshaping the table, so it should not start with a number
or contain any special symbols or spaces) \cr
\item unit: the unit of the measured value
}
}
