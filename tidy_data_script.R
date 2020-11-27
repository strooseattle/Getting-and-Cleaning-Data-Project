## load libraries
library(dplyr)

## download data
rawDataDir <- "./rawData"
rawDataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawDataFilename <- "rawData.zip"
rawDataDFn <- paste(rawDataDir, "/", "rawData.zip", sep = "")
dataDir <- "./data"

if (!file.exists(rawDataDir)) {
    dir.create(rawDataDir)
    download.file(url = rawDataUrl, destfile = rawDataDFn)
}
if (!file.exists(dataDir)) {
    dir.create(dataDir)
    unzip(zipfile = rawDataDFn, exdir = dataDir)
}

## merge {train, test} data set
xtrain <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/X_train.txt"))
ytrain <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/Y_train.txt"))
strain <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/subject_train.txt"))
xtest <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/X_test.txt"))
ytest <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/Y_test.txt"))
stest <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/subject_test.txt"))
xdata <- rbind(xtrain, xtest)
ydata <- rbind(ytrain, ytest)
s_ata <- rbind(strain, stest)

## load feature and activity info
feature <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/features.txt"))
alabel <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/activity_labels.txt"))
alabel[,2] <- as.character(alabel[,2])

## extract feature columns & names named 'mean, std'
selectedCols <- grep("-(mean|std).*", as.character(feature[,2]))
selectedColNames <- feature[selectedCols, 2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)

## extract data 
xdata <- xdata[selectedCols]
allData <- cbind(sdata, ydata, xdata)
colnames(allData) <- c("Subject", "Activity", selectedColNames)

allData$Activity <- factor(allData$Activity, levels = alabel[,1], labels = alabel[,2])
allData$Subject <- as.factor(allData$Subject)

## create tidy data set
meltedData <- melt(allData, id = c("Subject", "Activity"))
tidyData <- dcast(meltedData, Subject + Activity ~ variable, mean)
write.table(tidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)