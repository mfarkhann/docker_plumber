library(dplyr)
library(rpart)

get_species <- function(id, data, model) {
  
  id_numerik <- tryCatch(as.numeric(id), 
                         warning = function(w) NA)
  
  if(is.na(id_numerik)) {
    stop("ID Harus Numerik")
  }
  
  df_predict <- data %>% 
    filter(id == id_numerik)

  if(nrow(df_predict) == 0) {
    stop("ID Tidak ada")
  }
  
  df_predict$species <- predict(model, df_predict, type = 'class')
  
  return(df_predict)
}