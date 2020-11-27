library(reshape2)

## Download and unzip dataset
project_data <- "project_data.zip"
if (!file.exists(project_data)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, project_data, method="curl")
}
if (!file.exists("UCI HAR Dataset")) {
  unzip(project_data)
}

## Load activity and features data
act_labs <- read.table("UCI HAR Dataset/activity_labels.txt")
act_labs$V2 <- as.character(act_labs$V2)
feats <- read.table("UCI HAR Dataset/features.txt")
feats$V2 <- as.character(feats$V2)

## Extract only the measurements on the mean and standard deviation for each measurement.
req_feats <- grep(".*mean.*|.*std.*", feats[,2])
req_feats.names <- feats[req_feats,2]
req_feats.names = gsub('-mean', 'Mean', req_feats.names)
req_feats.names = gsub('-std', 'Std', req_feats.names)
req_feats.names <- gsub('[-()]', '', req_feats.names)

## Load remaining datasets
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")[req_feats]
y_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")[req_feats]
y_test <- read.table("UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

## Merge the training and the test sets to create one data set.
trainData <- cbind(x_train, y_train, subject_train)
testData <- cbind(x_test, y_test, subject_test)
combinedData <- rbind(trainData, testData)

## Label the data
colnames(combinedData) <- c("subject", "activity", req_feats.names)

## Store activities and subjects into vectors
combinedData$activity <- factor(combinedData$activity, levels = act_labs$V1, labels = act_labs$V2)
combinedData$subject <- as.factor(combinedData$subject)

combinedData_melted <- melt(combinedData, id = c("subject", "activity"))
combinedData_mean <- dcast(combinedData_melted, subject + activity ~ variable, mean)

## Create tidy dataset as text file
write.table(combinedData_mean, "tidy_data_set.txt", row.names = FALSE, quote = FALSE, sep = " ")