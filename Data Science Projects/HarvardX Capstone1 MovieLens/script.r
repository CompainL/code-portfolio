###Set seed and download libraries
set.seed(1) 
library(tidyverse)
library(caret)
library(caTools)
library(class)
library(rpart)
library(e1071)
library(h2o)

### Reproduce Dataset


options(timeout = 120)
ratings_file <- "ml-10M100K/ratings.dat"
movies_file <- "ml-10M100K/movies.dat"


ratings <- as.data.frame(str_split(read_lines(ratings_file), fixed("::"), simplify = TRUE),
                         stringsAsFactors = FALSE)
colnames(ratings) <- c("userId", "movieId", "rating", "timestamp")
ratings <- ratings %>%
  mutate(userId = as.integer(userId),
         movieId = as.integer(movieId),
         rating = as.numeric(rating),
         timestamp = as.integer(timestamp))

movies <- as.data.frame(str_split(read_lines(movies_file), fixed("::"), simplify = TRUE),
                        stringsAsFactors = FALSE)
colnames(movies) <- c("movieId", "title", "genres")
movies <- movies %>%
  mutate(movieId = as.integer(movieId))

movielens <- left_join(ratings, movies, by = "movieId")

# Final hold-out test set will be 10% of MovieLens data
set.seed(1, sample.kind="Rounding") # if using R 3.6 or later
test_index <- createDataPartition(y = movielens$rating, times = 1, p = 0.1, list = FALSE)
edx <- movielens[-test_index,]
temp <- movielens[test_index,]

# Make sure userId and movieId in final hold-out test set are also in edx set
final_holdout_test <- temp %>% 
  semi_join(edx, by = "movieId") %>%
  semi_join(edx, by = "userId")

# Add rows removed from final hold-out test set back into edx set
removed <- anti_join(temp, final_holdout_test)
edx <- rbind(edx, removed)

rm(dl, ratings, movies, test_index, temp, movielens, removed)


### Initial Analysis

ggplot(edx, aes(x=rating)) + geom_histogram() + ggtitle("Distribution of rating values")
n_distinct(edx$movieId) 
n_distinct(edx$userId) 
ggplot(edx, aes(x=timestamp)) + geom_histogram() + ggtitle("Distribution of timestamp values")

### Dataset Transformation

# use regex to get the date from the title
dat_train_1 <- edx %>%
  mutate(title = str_trim(title)) %>%
  extract(title, c("title_tmp", "year"), regex = "^(.*) \\(([0-9 \\-]*)\\)$", remove = F) %>%
  mutate(year = if_else(str_length(year) > 4, as.integer(str_split(year, "-", simplify = T)[1]), as.integer(year))) %>%
  mutate(title = if_else(is.na(title_tmp), title, title_tmp)) %>%
  select(-title_tmp)  %>%
  mutate(genres = if_else(genres == "(no genres listed)", `is.na<-`(genres), genres))

# Get the genre as binary dummy variables
genres <- c("Action", "Adventure", "Animation", 
            "Children", "Comedy", "Crime", 
            "Documentary", "Drama", "Fantasy", 
            "Film-Noir", "Horror", "Musical", 
            "Mystery", "Romance", "Sci-Fi", 
            "Thriller", "War", "Western")

for (genre_index in 1:length(genres)){
  dat_train_1[genres[genre_index]] <- NA
  detection <-as.integer(
    str_detect(
      dat_train_1$genre, 
      genres[genre_index]
    )
  )
  detection[is.na(detection)] <- 0
  dat_train_1[genres[genre_index]] <- detection
}

#rename Film-Noir and Sci-Fi to avoid issues later on with the "-"
names(dat_train_1)[names(dat_train_1) == "Film-Noir"] <- "Film_Noir"
names(dat_train_1)[names(dat_train_1) == "Sci-Fi"] <- "Sci_Fi"

#Eliminate redundant columns
dat_train_2 <- dat_train_1[,c(-5, -7)]

avg <- mean(dat_train_2$rating)
#computing the bias
movie_avgs <- dat_train_2 %>%
  group_by(movieId) %>%
  summarize(bias_movie = mean(rating - avg))
user_avgs<- dat_train_2 %>% 
  left_join(movie_avgs, by='movieId') %>%
  group_by(userId) %>%
  summarize(bias_user = mean(rating - avg - bias_movie))

#adding the bias to the main dataset
dat_train_3 <- dat_train_2%>%
  left_join(movie_avgs, by='movieId') %>%
  left_join(user_avgs, by='userId') %>%
  mutate(pred = avg + bias_movie + bias_user)

dat_train_3 <- dat_train_3[,c(-1,-2)]

#create the scale
scale <- preProcess(as.data.frame(dat_train_3[,c(-1)]), method=c("range"))
#apply it
dat_train_4 <- predict(scale, as.data.frame(dat_train_3))

### Post-preparation Analysis

ggplot(dat_train_3, aes(x=year)) + geom_histogram()  + ggtitle("Distribution of rated movies over time")
ggplot(dat_train_3, aes(x=bias_movie)) + geom_histogram() + ggtitle("Distribution of movie bias")
ggplot(dat_train_3, aes(x=bias_user)) + geom_histogram() + ggtitle("Distribution of user bias")

#change the genre to reflect the change from "-" to "_"
modified_genres <- c("Action", "Adventure", "Animation", 
                     "Children", "Comedy", "Crime", 
                     "Documentary", "Drama", "Fantasy", 
                     "Film_Noir", "Horror", "Musical", 
                     "Mystery", "Romance", "Sci_Fi", 
                     "Thriller", "War", "Western")
#count number of films with each genre
genre_counter <- data.frame(modified_genres)
genre_counter$counter <- NA 
for (genre_index in 1:length(modified_genres)){
  genre_counter$counter[genre_index] <-sum(dat_train_4[modified_genres[genre_index]])
}
# display
ggplot(genre_counter, aes(x = modified_genres, y = counter)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  ggtitle("Distribution of genre accross the dataset") + 
  scale_x_discrete(name ="Genre") + 
  scale_y_discrete(name ="Number")

### Small scale model tests

# Create reduced dataset
reduction_index <- createDataPartition(
  y = dat_train_4$rating, 
  times = 1, 
  p = 0.01, 
  list = FALSE
)
reduced_set <- dat_train_4[reduction_index,]

train_test_index <- createDataPartition(y = reduced_set$rating, times = 1, p = 0.2, list = FALSE)
reduced_dat_train <- reduced_set[-train_test_index,]
reduced_dat_test <- reduced_set[train_test_index,]
reduced_prediction_results <- reduced_dat_test[,1]
reduced_dat_test<- reduced_dat_test[,-1]

#Naive prediction
avg <- mean(reduced_dat_train$rating)
RMSE_AVG <- RMSE(reduced_prediction_results, avg)

# Linear Model
#create model
linear_regression_model_1 <- lm(
  rating ~ timestamp + year + Action + Adventure + Animation +
    Children + Comedy +Crime + Documentary + Drama + Fantasy +
    Film_Noir + Horror + Musical + Mystery + Romance + Sci_Fi + 
    Thriller + War + Western + bias_movie + bias_user + pred,
  data = reduced_dat_train)

#predict values
linear_regression_prediction_1 <- predict(
  linear_regression_model_1, 
  newdata = reduced_dat_test
)
linear_regression_prediction_1 <- round(linear_regression_prediction_1*2, digits = 0)/2 # round to the closest cetegorical value

#calculate RMSE
linear_regression_RMSE_1 <- RMSE(
  linear_regression_prediction_1, 
  reduced_prediction_results
)

#Treemap rpart model

#create model
rpart_model_1 <- rpart(
  rating ~ timestamp + year + Action + Adventure + Animation +
    Children + Comedy +Crime + Documentary + Drama + Fantasy +
    Film_Noir + Horror + Musical + Mystery + Romance + Sci_Fi + 
    Thriller + War + Western + bias_movie + bias_user + pred
  , data = reduced_dat_train)
summary(rpart_model_1)
#predict values
rpart_prediction_1 <- predict(rpart_model_1, reduced_dat_test)
#calculate RMSE
rpart_RMSE_1 <- RMSE(rpart_prediction_1, reduced_prediction_results)

#Naive Bayes model
#create model
naice_bayes_model_1 = naiveBayes(
  x = reduced_dat_train[-1],
  y = reduced_dat_train$rating
)
#predict values
naice_bayes_prediction_1 = predict(
  naice_bayes_model_1, 
  newdata = reduced_dat_test
)
#calculate RMSE
naice_bayes_RMSE_1 <- RMSE(
  as.numeric(as.character(naice_bayes_prediction_1)),
  reduced_prediction_results
)

#Initialize h2o
h2o.init(nthreads = -1)
#create model
ann_model_1 = h2o.deeplearning(
  y = 'rating',
  training_frame = as.h2o(reduced_dat_train),
  activation = 'Rectifier',
  hidden = c(20,20),
  epochs = 10,
  train_samples_per_iteration = -2
  )
#predict values
ann_prediction_1 = h2o.predict(
  ann_model_1, 
  newdata = as.h2o(reduced_dat_test)
  )
ann_prediction_1 = as.vector(ann_prediction_1)
ann_prediction_1 <- round(
  as.numeric(as.character(ann_prediction_1))*2, 
  digits = 0
  )/2
#calculate RMSE
ann_RMSE_1 <- RMSE(ann_prediction_1, reduced_prediction_results)E_1 <- RMSE(
  as.numeric(as.character(naice_bayes_prediction_1)),
  reduced_prediction_results
)

#Initialize h2o
h2o.init(nthreads = -1)
#create model
ann_model_1 = h2o.deeplearning(
  y = 'rating',
  training_frame = as.h2o(reduced_dat_train),
  activation = 'Rectifier',
  hidden = c(20,20),
  epochs = 10,
  train_samples_per_iteration = -2
)
#predict values
ann_prediction_1 = h2o.predict(
  ann_model_1, 
  newdata = as.h2o(reduced_dat_test)
)
ann_prediction_1 = as.vector(ann_prediction_1)
ann_prediction_1 <- round(
  as.numeric(as.character(ann_prediction_1))*2, 
  digits = 0
)/2
#calculate RMSE
ann_RMSE_1 <- RMSE(ann_prediction_1, reduced_prediction_results)

### Improving on Linear Model

#create model
linear_regression_model_2 <- lm(
  rating ~ .^2, #all values and all interaction terms
  data = reduced_dat_train)

#predict values
linear_regression_prediction_2 <- predict(
  linear_regression_model_2, 
  newdata = reduced_dat_test
)
linear_regression_prediction_2 <- round(linear_regression_prediction_2*2, digits = 0)/2

#calculate RMSE
linear_regression_RMSE_2 <- RMSE(
  linear_regression_prediction_2, 
  reduced_prediction_results
)

varImp(linear_regression_model_2, conditional=TRUE) #Search most relevant parameters

#3rd version of the linear model

#create model
linear_regression_model_3 <- lm(
  rating ~ timestamp + year + Action + Adventure + 
    Animation + Children + Comedy + Crime + Documentary + Drama + 
    Fantasy + Film_Noir + Horror + Musical + Mystery + Romance + 
    Sci_Fi + Thriller + War + Western + bias_movie + bias_user + bias_movie:bias_user,
  data = reduced_dat_train)

#predict values
linear_regression_prediction_3 <- predict(
  linear_regression_model_3, 
  newdata = reduced_dat_test
)
linear_regression_prediction_3 <- round(linear_regression_prediction_3*2, digits = 0)/2

#calculate RMSE
linear_regression_RMSE_3 <- RMSE(
  linear_regression_prediction_3, 
  reduced_prediction_results
)
linear_regression_RMSE_3

### Adapting final test data 

# use regex to get the date from the title
final_holdout_test_2 <- final_holdout_test %>%
  mutate(title = str_trim(title)) %>%
  extract(title, c("title_tmp", "year"), regex = "^(.*) \\(([0-9 \\-]*)\\)$", remove = F) %>%
  mutate(year = if_else(str_length(year) > 4, as.integer(str_split(year, "-", simplify = T)[1]), as.integer(year))) %>%
  mutate(title = if_else(is.na(title_tmp), title, title_tmp)) %>%
  select(-title_tmp)  %>%
  mutate(genres = if_else(genres == "(no genres listed)", `is.na<-`(genres), genres))


for (genre_index in 1:length(genres)){
  final_holdout_test_2[genres[genre_index]] <- NA
  final_holdout_test_2[genres[genre_index]] <- as.integer(str_detect(final_holdout_test_2$genre, genres[genre_index]))
}

#rename Film-Noir and Sci-Fi to avoid issues later on with the "-"
names(final_holdout_test_2)[names(final_holdout_test_2) == "Film-Noir"] <- "Film_Noir"
names(final_holdout_test_2)[names(final_holdout_test_2) == "Sci-Fi"] <- "Sci_Fi"

#add the biases for movie and user, from the training data
final_holdout_test_3 <- final_holdout_test_2%>%
  left_join(movie_avgs, by='movieId') %>%
  left_join(user_avgs, by='userId') %>%
  mutate(pred = avg + bias_movie + bias_user)

final_holdout_test_3 <- final_holdout_test_3[,c(-1,-2, -5, -7)] # remove excess columns

final_holdout_test_4 <- predict(scale, as.data.frame(final_holdout_test_3)) #set to the same scale as the training data


### Test with full dataset

train_test_index <- createDataPartition(y = dat_train_4$rating, times = 1, p = 0.2, list = FALSE)
check_dat_train <- dat_train_4[-train_test_index,]
check_dat_test <- dat_train_4[train_test_index,]
check_prediction_results <- check_dat_test[,1]
check_dat_test<- check_dat_test[,-1]

#create model
linear_regression_model_4 <- lm(
  rating ~ timestamp + year + Action + Adventure + Animation +
    Children + Comedy +Crime + Documentary + Drama + Fantasy +
    Film_Noir + Horror + Musical + Mystery + Romance + Sci_Fi + 
    Thriller + War + Western + bias_movie + bias_user + bias_movie:bias_user,
  data = check_dat_train)

#predict values
linear_regression_prediction_4 <- predict(
  linear_regression_model_4, 
  newdata = check_dat_test
)
linear_regression_prediction_4 <- round(linear_regression_prediction_4*2, digits = 0)/2

#calculate RMSE
linear_regression_RMSE_4 <- RMSE(
  linear_regression_prediction_4, 
  check_prediction_results
)

### Final implementation and results
final_model <- lm(
  rating ~ timestamp + year + Action + Adventure + Animation +
    Children + Comedy +Crime + Documentary + Drama + Fantasy +
    Film_Noir + Horror + Musical + Mystery + Romance + Sci_Fi + 
    Thriller + War + Western + bias_movie + bias_user + bias_movie:bias_user,
  data= dat_train_4
)


final_prediction <- predict(final_model, final_holdout_test_4[,-1])
final_RMSE <- RMSE(final_prediction, final_holdout_test_4[,1])
final_RMSE
