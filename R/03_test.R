suppressPackageStartupMessages({
  library(dplyr)
  source(here::here("R","02_predict.R"))
  options(scipen = 99)
})

model <- readRDS(here::here('data','model.rds'))


# Success
get_species(1, model = model)
get_species("1", model = model)

# Data not found
get_species("0", model = model)


# Data not found
get_species("a", model = model)
