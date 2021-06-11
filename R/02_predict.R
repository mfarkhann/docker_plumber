library(dplyr)
library(rpart)
library(readr)

get_detail_data <- function(id_input) {
  
  irisData <- try(read_rds(here::here('data','iris_data.rds')))

  if(inherits(irisData, "try-error")){
    stop("Database not found")
  }
  
  irisData %>% 
    filter(id == id_input)
}

get_species <- function(id, model) {
  
  id_numerik <- tryCatch(as.numeric(id), 
                         warning = function(w) NA)
  
  if(is.na(id_numerik)) {
    stop("ID Harus Numerik")
  }
  
  df_predict = get_detail_data(id_input = id_numerik)

  if(nrow(df_predict) == 0) {
    stop("ID Tidak ada")
  }
  
  df_predict$species <- predict(model, df_predict, type = 'class')
  
  return(df_predict)
}