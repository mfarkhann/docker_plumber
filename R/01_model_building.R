library(dplyr)
library(rpart)

# Split the data
set.seed(26)
row_train <- sample(1:nrow(iris), 0.8 * nrow(iris)) 
iris_train <- iris[row_train,]
iris_test <- iris[-row_train,]

# Generate Model
treeFit <- rpart(Species~.,data=iris_train,method = 'class')

# Predict on Test
iris_prediction <- predict(treeFit, iris_test,type = 'class')
table(iris_prediction, iris_test$Species)

saveRDS(treeFit, here::here('data','model.rds'))