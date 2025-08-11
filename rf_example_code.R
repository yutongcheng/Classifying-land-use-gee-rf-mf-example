# Install and load necessary libraries
#install.packages("randomForest")
#install.packages("caret")
#install.packages("dplyr")

library(randomForest)
library(caret)
library(dplyr)

# Use ten spectral bands (B2–B8A, B11–B12) from Sentinel-2 via GEE and elevation change from TanDEM-X DCM, rescaled to 10 m


# Calculate indices
#MNDWI<-(B3-B11)/(B3+B11)
#NDBI<-(B11-B8)/(B11+B8)
#NDVI <- (B8-B4)/(B8+B4)
#BSI <- ((B11+B4)-(B8+B2))/((B11+B4)+(B8+B2)+1e-6)

# Thresholds used for refining the training dataset:
# - Open-pit: Δelev < 0 m
# - Waste dumping: Δelev > 1 m
# - General disturbed land: 0 m ≤ Δelev ≤ 1 m & BSI < 0.2
# - Facility: NDBI > 0.28
# - Water: MNDWI > 0
# - Vegetation: NDVI > 0.3

# Load pre-processed example data.
# NOTE: This dataset is for both training and prediction/classification,
# and is ONLY for code demonstration, not for real evaluation.


data <- read.csv("example_data_rf.csv")

set.seed(12)  # For reproducibility

# Separate the data by class
class1_data <- data[data$label == "1", ]
class2_data <- data[data$label == "2", ]
class3_data <- data[data$label == "3", ]
class4_data <- data[data$label == "4", ]
class5_data <- data[data$label == "5", ]
class6_data <- data[data$label == "6", ]
class7_data <- data[data$label == "7", ]


# Sample 80% for training and 20% for testing from each class

# Class 1
train_indices_class1 <- sample(1:nrow(class1_data), 0.8 * nrow(class1_data))
train_class1 <- class1_data[train_indices_class1, ]
test_class1 <- class1_data[-train_indices_class1, ]

# Class 2
train_indices_class2 <- sample(1:nrow(class2_data), 0.8 * nrow(class2_data))
train_class2 <- class2_data[train_indices_class2, ]
test_class2 <- class2_data[-train_indices_class2, ]

# Class 3
train_indices_class3 <- sample(1:nrow(class3_data), 0.8 * nrow(class3_data))
train_class3 <- class3_data[train_indices_class3, ]
test_class3 <- class3_data[-train_indices_class3, ]

# Class 4
train_indices_class4 <- sample(1:nrow(class4_data), 0.8 * nrow(class4_data))
train_class4 <- class4_data[train_indices_class4, ]
test_class4 <- class4_data[-train_indices_class4, ]

# Class 5
train_indices_class5 <- sample(1:nrow(class5_data), 0.8 * nrow(class5_data))
train_class5 <- class5_data[train_indices_class5, ]
test_class5 <- class5_data[-train_indices_class5, ]

# Class 6
train_indices_class6 <- sample(1:nrow(class6_data), 0.8 * nrow(class6_data))
train_class6 <- class6_data[train_indices_class6, ]
test_class6 <- class6_data[-train_indices_class6, ]

# Class 7
train_indices_class7 <- sample(1:nrow(class7_data), 0.8 * nrow(class7_data))
train_class7 <- class7_data[train_indices_class7, ]
test_class7 <- class7_data[-train_indices_class7, ]

# Combine the training and testing sets from both classes
train_data <- rbind(train_class1, train_class2, train_class3, train_class4, train_class5, train_class6, train_class7)
test_data <-  rbind(test_class1, test_class2, test_class3, test_class4, test_class5, test_class6, test_class7)

# Train the Random Forest Model for classification
train_data$label<-as.factor(train_data$label)
test_data$label<-as.factor(test_data$label)

colnames(train_data)[1] <- c("id")
colnames(test_data)[1] <- c("id")

# Set up cross-validation
control <- trainControl(method = "cv", number = 10)  # 10-fold cross-validation

# Expand the tuning grid for mtry
tunegrid <- expand.grid(.mtry = c(4))

# Train the Random Forest model using cross-validation with expanded mtry values
rf_model_cv <- train(label ~ . - id, 
                     data = train_data, 
                     method = "rf", 
                     tuneGrid = tunegrid, 
                     trControl = control,
                     ntree = 100)

# Print the results of cross-validation
print(rf_model_cv)

# Make predictions on the test data using the best model
best_rf_model <- rf_model_cv$finalModel
predictions <- predict(best_rf_model, newdata = test_data)

# Calculate the confusion matrix
conf_matrix <- confusionMatrix(predictions, test_data$label)

# Print confusion matrix and importance analysis results
print(conf_matrix)
importance(best_rf_model)

# Load unclassified example data
unclassified_data<- read.csv("example_data_rf.csv")

# Classify unclassified data
predictions <- predict(best_rf_model, newdata = unclassified_data)
summary(predictions)
