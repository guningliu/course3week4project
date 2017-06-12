library(reshape2)
## Download and unzip the dataset:
if (!file.exists("./course3/week4/data/getdata_dataset.zip")){
      fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
      download.file(fileURL, destfile="./course3/week4/data/getdata_dataset.zip", method="curl")
}  
if (!file.exists("./course3/week4/data/UCI HAR Dataset")) { 
      unzip("./course3/week4/data/getdata_dataset.zip") 
}

# Load activity labels + features
activityLabels <- read.table("./course3/week4/data/UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("./course3/week4/data/UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

# Load the datasets
train <- read.table("./course3/week4/data/UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("./course3/week4/data/UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("./course3/week4/data/UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("./course3/week4/data/UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("./course3/week4/data/UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("./course3/week4/data/UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
