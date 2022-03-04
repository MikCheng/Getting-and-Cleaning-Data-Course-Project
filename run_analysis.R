# run_analysis.R

#Task 1: Merges the training and the test sets to create one data set
ProjectrawDataDir <- "./rawData"
ProjectrawDataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
ProjectrawDataFilename <- "rawData.zip"
ProjectrawDataDFn <- paste(rawDataDir, "/", "rawData.zip", sep = "")
dataDir <- "./Project"

if (!file.exists(ProjectrawDataDir)) {
  dir.create(ProjectrawDataDir)
  download.file(url = ProjectrawDataUrl, destfile = ProjectrawDataDFn)}
if (!file.exists(dataDir)) {
  dir.create(dataDir)
  unzip(zipfile = ProjectrawDataDFn, exdir = dataDir)}

#data extraction
activity_data_test<-read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/Y_test.txt"))
activity_data_train<-read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/Y_train.txt"))

subject_data_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/subject_test.txt"))
subject_data_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/subject_train.txt"))

feature_data_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/X_test.txt"))
feature_data_train <-read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/X_train.txt"))
feature_name <- read.table(paste(sep = "", dataDir, "./UCI HAR Dataset/features.txt"))

subject_data <- rbind(subject_data_test, subject_data_train)
activity_data<- rbind(activity_data_train, activity_data_test)
feature_data<- rbind(feature_data_train, feature_data_test)

names(subject_data)<-c("subject")
names(activity_data)<- c("activity")
names(feature_data)<- feature_name$V2
data <- cbind(feature_data, subject_data, activity_data)

#Task 2:Extracts only the measurements on the mean and standard deviation for each measurement. 
feature_subname<-feature_name$V2[grep("mean\\(\\)|std\\(\\)", feature_name$V2)]
selected_names<-c(as.character(feature_subname), "subject", "activity" )
data<-subset(data,select=selected_names)

#Task 3: Uses descriptive activity names to name the activities in the data set
activity_labels <- read.table(paste(sep = "", dataDir, "./UCI HAR Dataset/activity_labels.txt"))
data$activity <- factor(data$activity, labels = activity_labels$V2)


#Task 4: Appropriately labels the data set with descriptive variable names
names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))

#Task 5: creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(plyr);
data2<-aggregate(. ~subject + activity, data, mean)
data2<-data2[order(data2$subject,data2$activity),]
write.table(data2, file = "tidydata.txt",row.name=FALSE)

