## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

require("data.table")
require("reshape2")

# activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Solo nos interesa la media y la desviación
med_desv <- grepl("mean|std", features)

# Cargamos los datos de X y de Y
x <- read.table("./UCI HAR Dataset/test/X_test.txt")
names(x) = features
#nos quedamos con la media y la desviacion
x = x[,med_desv]

y <- read.table("./UCI HAR Dataset/test/y_test.txt")
# Cargamos actividades
y[,2] = activity_labels[y[,1]]
names(y) = c("ID_Actividad", "Actividad")

subject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(subject) = "subject"

# Bind data
dataset_test <- cbind(as.data.table(subject), y, x)

# Cargamos los train de la misma manera
xTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
names(xTrain) = features
xTrain = xTrain[,med_desv]

yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
yTrain[,2] = activity_labels[yTrain[,1]]
names(yTrain) = c("ID_Actividad", "Actividad")

subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(subjectTrain) = "subject"

# Bind data
dataset_train <- cbind(as.data.table(subjectTrain), yTrain, xTrain)

#hacemos el merge
dataset = rbind(dataset_test, dataset_train)


ids   = c("subject", "ID_Actividad", "Actividad")
nombres_features = setdiff(colnames(dataset), ids)
melt_dataset = melt(dataset, id = ids, measure.vars = nombres_features)

# Aplicamos la media
tidy_dataset   = dcast(melt_dataset, subject + Actividad ~ variable, mean)

#escribimos el texto
write.table(tidy_dataset, file = "./dataset.txt")