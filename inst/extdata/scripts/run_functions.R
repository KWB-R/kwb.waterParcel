# load example data set
df <- kwb.waterParcel::load_lab_data(
  path = system.file(package = "kwb.waterParcel", "extdata"), 
  file = "measurements.csv"
)

kwb.waterParcel::check_for_units(df_in = df)

# reshape the data
df_pro <- kwb.waterParcel::reshape_table(
  df_in = df, 
  sampling_campaigns = 1, 
  bLOD = "half", 
  aLOD = "na"
)

# Prepare regression
MCS_input <- kwb.waterParcel::get_all_sample_concentrations(
  input_table = df_pro, 
  predictor_samples = c("Vorbelastung_rechts", "Weid_1", "Gotz_7"), 
  tracer_names = c("SO4", "Cl", "Cond", "ACS", "GAB"), 
  MCS_runs = 10, 
  rel_deviation = c(0.05, 0.05, 0.05, 0.1, 0.1)
)

MCS_norm <- kwb.waterParcel::normalize_MCS_input(MCS_input = MCS_input)

