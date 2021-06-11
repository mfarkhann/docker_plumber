library(dplyr)

irisData <- iris %>% 
  mutate(id = rownames(iris)) %>% 
  select(id, everything())
irisData$Species = NULL

saveRDS(irisData, here::here('data','iris_data.rds'))
