library(dplyr)

irisData <- iris %>% 
  mutate(id = rownames(iris)) %>% 
  select(id, everything())
irisData$Species = NULL

readr::write_rds(irisData, here::here('data','iris_data.rds'))
