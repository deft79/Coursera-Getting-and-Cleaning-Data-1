#set working directory and read the files
setwd("C:/Users/Eugene/Documents/GitHub/coursera-getting-and-cleaning-data")

filename <- "getdata_dataset.zip"
# Check if dataset exists. Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filezip, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filezip) 
}

#read and combine train datasets into one data frame
training = read.csv("UCI HAR Dataset/train/X_train.txt", sep="", header=FALSE)
training[,562] = read.csv("UCI HAR Dataset/train/Y_train.txt", sep="", header=FALSE)
training[,563] = read.csv("UCI HAR Dataset/train/subject_train.txt", sep="", header=FALSE)

#read and combine test datasets into one data frame
testing = read.csv("UCI HAR Dataset/test/X_test.txt", sep="", header=FALSE)
testing[,562] = read.csv("UCI HAR Dataset/test/Y_test.txt", sep="", header=FALSE)
testing[,563] = read.csv("UCI HAR Dataset/test/subject_test.txt", sep="", header=FALSE)

#read activity labels
activityLabels = read.csv("UCI HAR Dataset/activity_labels.txt", sep="", header=FALSE)

# Read features, modify feature names for easier labelling
features = read.csv("UCI HAR Dataset/features.txt", sep="", header=FALSE)
features[,2] = gsub('-mean', 'Mean', features[,2])
features[,2] = gsub('-std', 'Std', features[,2])
features[,2] = gsub('[-()]', '', features[,2])

# Merge training and test sets together
mergeData = rbind(training, testing)

# Show the columns that contain mean and std. dev.
columns <- grep(".*Mean.*|.*Std.*", features[,2])
# Filter down the columns and discard unwanted columns
features <- features[columns,]
# Append subject and activity columns 
columns  <- c(columns, 562, 563)
# And remove the unwanted columns from mergeData
mergeData <- mergeData[,columns]
# Add the column names (features) to mergeData
colnames(mergeData) <- c(features$V2, "Activity", "Subject")
colnames(mergeData) <- tolower(colnames(mergeData))

currentActivity = 1
for (currentActivityLabel in activityLabels$V2) {
  mergeData$activity <- gsub(currentActivity, currentActivityLabel, mergeData$activity)
  currentActivity <- currentActivity + 1
}

mergeData$activity <- as.factor(mergeData$activity)
mergeData$subject <- as.factor(mergeData$subject)

tidy = aggregate(mergeData, by=list(activity = mergeData$activity, subject=mergeData$subject), mean)
# Remove the subject and activity column, since a mean of those has no use
tidy[,90] = NULL
tidy[,89] = NULL
write.table(tidy, "tidy.txt", sep="\t")

