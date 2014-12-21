# run_analysis.R
# getdata-016 Assignment
# 12.21.2014
# vandrei@gmu.edu

# read in the activity labels
activity_labels <- read.table("activity_labels.txt")
colnames(activity_labels) <- c("Activity", "Activity Description")

# read in the feature labels
feature_labels <- subset(read.table("features.txt"), select = V2)
colnames(feature_labels) <- "Feature"

# read in the training data set
train <- cbind(
  
  # subject number
  read.table("train/subject_train.txt"),
  
  # feature measurements
  read.table("train/x_train.txt"),
  
  # activity number
  read.table("train/y_train.txt")
    
  )

colnames(train) <- cbind("Subject", t(feature_labels), "Activity")

# read in the test data set
test <- cbind(
  
  # subject number
  read.table("test/subject_test.txt"),
  
  # feature measurements
  read.table("test/x_test.txt"),
  
  # activity number
  read.table("test/y_test.txt")

  )

colnames(test) <- cbind("Subject", t(feature_labels), "Activity")

# merge the data sets
merged_data <- rbind(train, test)

# extract mean and st. dev. measurements
merged_data <- merged_data[sort(c(1,
                                  grep("mean", colnames(merged_data)),
                                  grep("std" , colnames(merged_data)),
                                  563))]
                    
# add activity labels
merged_data <- merge(merged_data, activity_labels, by.y="Activity", all=TRUE)

# change the column order to something that makes a bit more sense
merged_data <- merged_data[c(2, 82, 3:81)]

# remove meanFreq() columns
merged_data <- merged_data[c(1:48, 52:57, 61:66, 70:71, 73:74, 76:77, 79:80)]

# clean up the column names
colnames(merged_data) <- gsub("tBody", "TimeBody", colnames(merged_data))
colnames(merged_data) <- gsub("tGravity", "TimeGravity", colnames(merged_data))
colnames(merged_data) <- gsub("fBody", "FFTBody", colnames(merged_data))
colnames(merged_data) <- gsub("Mag", "Magnitude", colnames(merged_data))
colnames(merged_data) <- gsub("Acc", "Accelerometer", colnames(merged_data))
colnames(merged_data) <- gsub("Gyro", "Gyroscope", colnames(merged_data))
colnames(merged_data) <- gsub("Activity Description", "Activity", colnames(merged_data))

# create a second tidy data set showing averages by subject and by activity

# some preliminaries
library(dplyr)
har_smartphone <- tbl_df(merged_data)

# group by subject and activity
har_smartphone <- group_by(har_smartphone, Subject, Activity)

# calculate averages of each of the feature measurements
har_smartphone <- summarise_each(har_smartphone, funs(mean))

# clean up the columns a bit
colnames(har_smartphone) <- gsub("mean", "mean-of-means", colnames(har_smartphone))
colnames(har_smartphone) <- gsub("std",  "mean-of-stds",  colnames(har_smartphone))

# write the second data set to a file
write.table(har_smartphone, file = "har-smartphone.txt", sep=",", row.names=FALSE)