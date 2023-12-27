
############################ 
######## Preparation #######
############################

#------libraries loading--------------
library(readr)
library(tidyverse)
library(caret)
library(e1071)
library(ggplot2)
library(here)

#------seed setting--------------
set.seed(1, sample.kind="Rounding")


#------Get dataset--------------
here("ocd_patient_dataset.csv")
ocd_patient_dataset <- read_csv(here("ocd_patient_dataset.csv"))

#------Clean data--------------
ocd_patient_dataset <- as.data.frame(ocd_patient_dataset)

names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Patient ID"] <- "Patient_ID"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Marital Status"] <- "Marital_Status"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Education Level"] <- "Education_Level"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "OCD Diagnosis Date"] <- "OCD_Diagnosis_Date"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Duration of Symptoms (months)"] <- "Duration_of_Symptoms"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Previous Diagnoses"] <- "Previous_Diagnoses"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Family History of OCD"] <- "Family_History_of_OCD"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Obsession Type"] <- "Obsession_Type"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Compulsion Type"] <- "Compulsion_Type"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Y-BOCS Score (Obsessions)"] <- "Y_BOCS_Score_Obsessions"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Y-BOCS Score (Compulsions)"] <- "Y_BOCS_Score_Compulsions"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Depression Diagnosis"] <- "Depression_Diagnosis"
names(ocd_patient_dataset)[names(ocd_patient_dataset) == "Anxiety Diagnosis"] <- "Anxiety_Diagnosis"

#------Separate train and test--------------
test_index <- createDataPartition(y = ocd_patient_dataset$`Duration_of_Symptoms`, times = 1, p = 0.1, list = FALSE)
work_set <- ocd_patient_dataset[-test_index,]
final_test_set <- ocd_patient_dataset[test_index,]

############################## 
#### Preprocess train data ###
############################## 
encoded_work_set <- work_set

#----Encoding binaries----

encoded_work_set <- mutate(encoded_work_set, Gender = if_else(Gender=="Female", 1, 0))
encoded_work_set <- mutate(encoded_work_set, Family_History_of_OCD  = if_else(Family_History_of_OCD=="No",0,1))
encoded_work_set <- mutate(encoded_work_set, Depression_Diagnosis  = if_else(Depression_Diagnosis=="No",0,1))
encoded_work_set <- mutate(encoded_work_set, Anxiety_Diagnosis  = if_else(Anxiety_Diagnosis=="No",0,1))

#------Encoding Categorical variables------



Ethnicities <- c("African","Asian","Caucasian","Hispanic")
Education_Level <- c("High School","Some College","College Degree","Graduate Degree")
Marital_Statuses <- c("Divorced","Married","Single")
Previous_Diagnoses  <- c("GAD","MDD","Panic Disorder","PTSD","None")
Obsession_Types <- c("Contamination","Harm-related","Hoarding","Religious","Symmetry")
Compulsion_Types <- c("Checking", "Counting", "Ordering", "Praying", "Washing")
Medications <- c("Benzodiazepine","None","SNRI","SSRI")

for(index in 1:length(Ethnicities)){
  value <- Ethnicities[index] #Select value
  name = paste("Ethnicity", value, sep = "_") #Create a name for the new column
  encoded_work_set[name] <- NA #Create new column
  # set at 1 if the value is present in the line and 0 if not
  detection <-as.integer(
    str_detect(
      encoded_work_set$Ethnicity, 
      value
    )
  )
  detection[is.na(detection)] <- 0 #Little additional security if we get NA
  encoded_work_set[name] <- detection # get the value of detection in the new column
}
for(index in 1:length(Marital_Statuses)){
  value <- Marital_Statuses[index]
  name = paste("Marital_Status", value, sep = "_")
  encoded_work_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_work_set$Marital_Status, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_work_set[name] <- detection
}
for(index in 1:length(Previous_Diagnoses)){
  value <- Previous_Diagnoses[index]
  name = paste("Previous_Diagnosis", value, sep = "_")
  encoded_work_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_work_set$Previous_Diagnoses, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_work_set[name] <- detection
}
for(index in 1:length(Obsession_Types)){
  value <- Obsession_Types[index]
  name = paste("Obsession_Type", value, sep = "_")
  encoded_work_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_work_set$Obsession_Type, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_work_set[name] <- detection
}
for(index in 1:length(Compulsion_Types)){
  value <- Compulsion_Types[index]
  name = paste("Compulsion_Type", value, sep = "_")
  encoded_work_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_work_set$Compulsion_Type, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_work_set[name] <- detection
}
for(index in 1:length(Medications)){
  value <- Medications[index]
  name = paste("Medications", value, sep = "_")
  encoded_work_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_work_set$Medications, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_work_set[name] <- detection
}
for(index in 1:length(Education_Level)){
  value <- Education_Level[index]
  name = paste("Education_Level", value, sep = "_")
  encoded_work_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_work_set$Education_Level, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_work_set[name] <- detection
}
#---- Variable renaming ----

names(encoded_work_set)[names(encoded_work_set) == "Previous_Diagnosis_Panic Disorder"] <- "Previous_Diagnosis_Panic_Disorder"
names(encoded_work_set)[names(encoded_work_set) == "Obsession_Type_Harm-related"] <- "Obsession_Type_Harm_related"
names(encoded_work_set)[names(encoded_work_set) == "Education_Level_High School"] <- "Education_Level_High_School"
names(encoded_work_set)[names(encoded_work_set) == "Education_Level_Some College"] <- "Education_Level_Some_College"
names(encoded_work_set)[names(encoded_work_set) == "Education_Level_College Degree"] <- "Education_Level_College_Degree"
names(encoded_work_set)[names(encoded_work_set) == "Education_Level_Graduate Degree"] <- "Education_Level_Graduate_Degree"

encoded_work_set <- encoded_work_set[,c(-1, -4,-5,-6,-9,-11,-12,-17)]

#---- Scaling ----
scale <- preProcess(encoded_work_set[,c(-4)], method=c("range"))
scaled_work_set <- predict(scale, encoded_work_set)



############################### 
##### Preprocess test data ####
############################### 

encoded_final_test_set <- final_test_set
#----Encoding binaries----
encoded_final_test_set <- mutate(encoded_final_test_set, Gender = if_else(Gender=="Female", 1, 0))
encoded_final_test_set <- mutate(encoded_final_test_set, Family_History_of_OCD  = if_else(Family_History_of_OCD=="No",0,1))
encoded_final_test_set <- mutate(encoded_final_test_set, Depression_Diagnosis  = if_else(Depression_Diagnosis=="No",0,1))
encoded_final_test_set <- mutate(encoded_final_test_set, Anxiety_Diagnosis  = if_else(Anxiety_Diagnosis=="No",0,1))

#------Encoding Categorical variables------
for(index in 1:length(Ethnicities)){
  value <- Ethnicities[index]
  name = paste("Ethnicity", value, sep = "_")
  encoded_final_test_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_final_test_set$Ethnicity, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_final_test_set[name] <- detection
}
for(index in 1:length(Marital_Statuses)){
  value <- Marital_Statuses[index]
  name = paste("Marital_Status", value, sep = "_")
  encoded_final_test_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_final_test_set$Marital_Status, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_final_test_set[name] <- detection
}
for(index in 1:length(Previous_Diagnoses)){
  value <- Previous_Diagnoses[index]
  name = paste("Previous_Diagnosis", value, sep = "_")
  encoded_final_test_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_final_test_set$Previous_Diagnoses, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_final_test_set[name] <- detection
}
for(index in 1:length(Obsession_Types)){
  value <- Obsession_Types[index]
  name = paste("Obsession_Type", value, sep = "_")
  encoded_final_test_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_final_test_set$Obsession_Type, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_final_test_set[name] <- detection
}
for(index in 1:length(Compulsion_Types)){
  value <- Compulsion_Types[index]
  name = paste("Compulsion_Type", value, sep = "_")
  encoded_final_test_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_final_test_set$Compulsion_Type, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_final_test_set[name] <- detection
}
for(index in 1:length(Medications)){
  value <- Medications[index]
  name = paste("Medications", value, sep = "_")
  encoded_final_test_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_final_test_set$Medications, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_final_test_set[name] <- detection
}
for(index in 1:length(Education_Level)){
  value <- Education_Level[index]
  name = paste("Education_Level", value, sep = "_")
  encoded_final_test_set[name] <- NA
  detection <-as.integer(
    str_detect(
      encoded_final_test_set$Education_Level, 
      value
    )
  )
  detection[is.na(detection)] <- 0
  encoded_final_test_set[name] <- detection
}
#---- Variable renaming ----

names(encoded_final_test_set)[names(encoded_final_test_set) == "Previous_Diagnosis_Panic Disorder"] <- "Previous_Diagnosis_Panic_Disorder"
names(encoded_final_test_set)[names(encoded_final_test_set) == "Obsession_Type_Harm-related"] <- "Obsession_Type_Harm_related"
names(encoded_final_test_set)[names(encoded_final_test_set) == "Education_Level_High School"] <- "Education_Level_High_School"
names(encoded_final_test_set)[names(encoded_final_test_set) == "Education_Level_Some College"] <- "Education_Level_Some_College"
names(encoded_final_test_set)[names(encoded_final_test_set) == "Education_Level_College Degree"] <- "Education_Level_College_Degree"
names(encoded_final_test_set)[names(encoded_final_test_set) == "Education_Level_Graduate Degree"] <- "Education_Level_Graduate_Degree"

encoded_final_test_set <- encoded_final_test_set[,c(-1, -4,-5,-6,-9,-11,-12,-17)]

#---- Scaling ----

scales_final_test_set <- predict(scale, encoded_final_test_set)

#---- Separate Predictions ----
final_prediction_results <- scales_final_test_set[,4]
scaled_final_test_set<- scales_final_test_set[,-4]

############################### 
####### Prediction task #######
###############################
#---- Model ----
svm_model <-svm(
  Duration_of_Symptoms~.,
  data = scaled_work_set,
  gamma = 0.01,
  cost = 1)

#---- Prediction ----
svm_prediction <- predict(
  svm_model, 
  newdata = scaled_final_test_set
)
#---- Evaluation metrics ----
postResample(pred  = svm_prediction, obs  = final_prediction_results)

