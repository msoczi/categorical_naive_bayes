#########################################################
################ CATEGORICAL NAIVE BAYES ################ 
################# Mateusz Soczewka (C) ################## 
#########################################################


# _______________________________________________________
# FUNCTION: naive_bayes() _______________________________
# DECRIPTION: ___________________________________________
# Function create naive bayes model on categorical data _
# ARGUMENTS: ____________________________________________
# X_data - train dataframe ______________________________
# y_data - vector with target variable (multilass) ______
# lambda - Laplace smoothing parameter. If 0 (defalut) __
#          there is no smoothing. Nonzero values prevents
#          zero probabilities in further computations. __
# RETURNS: ______________________________________________
# Function return list object with attributes: __________
# p_xi - probabilities of x_i ___________________________
# p_y - probabilities of target variable Y ______________
# p_xiy - conditional probabilities P(X_i | Y) __________
# response_class - levels of target variable ____________
# n_var - number of features in X_data __________________
# preds - predictions for X_data ________________________
# _______________________________________________________
naive_bayes <- function(X_data, y_data, lambda = 0){
  # Data parameters:
  response_class <- levels(as.factor(y_data)) # classes of the target variable
  n_var <- dim(X_data)[2] # number of variables
  # Check if all columns have at least 2 levels
  n_unique <- function(x){return(length(unique(x)))}
  if( any(apply(X_data, 2, n_unique) < 2) ){
    stop("The number of unique levels in some columns is 1. Remove them from the dataset.")
  }
  
  # Lists will hold the probabilities
  tab <- list() # main table
  p_xi <- list()
  p_y <- list()
  p_xiy <- list()
  for (i in 1:n_var) {
    tab <- append(tab, list(table(X_data[,i], y_data)))
    # The probability of the given category occurring - P(x_i)
    p_xi <- append(p_xi, list(tab[[i]]/sum(tab[[i]])))
    # Target variable probability - P(Y)
    p_y <- (apply(tab[[i]], MARGIN = 2, FUN = sum)+lambda)/(sum(tab[[i]])+lambda*length(response_class))
    # Conditional probabilities - P(x_i | y)
    p_xiy <- append(p_xiy, list(apply(tab[[i]], MARGIN = 2, FUN = function(x) (x+lambda)/(sum(x)+lambda*dim(tab[[i]])[1]))))
  }
  
  
  # vectors with observation indices to get the appropriate probabilities
  indx_to_calc_prob <- list()
  for (i in 1:n_var) {
    indx_to_calc_prob <- append(indx_to_calc_prob, list(match(X_data[,i], rownames(p_xiy[[i]]))))
  }
  
  # The function calculates the product of the probabilities P(x_i | y) with respect to i
  var_prod <- function(){
    produkt = 1
    for (j in 1:n_var) {
      produkt <- produkt * p_xiy[[j]][indx_to_calc_prob[[j]],]
    }
    return(produkt)
  }
  pr_warunk <- var_prod()
  rownames(pr_warunk) <- NULL
  
  # Calculate the results, i.e. P(y | x_1, x_2, ..., x_n)
  result <- list()
  for (i in 1:length(response_class)) {
    result <- append(result, list(as.matrix(p_y[i]*pr_warunk[,i])))
  }
  result <- do.call(cbind.data.frame, result)
  names(result) <- response_class
  
  # Predict the class with the highest probability
  preds <- colnames(result)[apply(result, MARGIN = 1, which.max)]
  
  LS <- list(p_xi, p_y, p_xiy, response_class, n_var, preds)
  names(LS) <- c('p_xi', 'p_y', 'p_xiy', 'response_class', 'n_var', 'preds')
  return(LS)
}



# _______________________________________________________
# FUNCTION: predict.nb() _______________________________
# DECRIPTION: ___________________________________________
# Function make predictions for naive bayes model created
# by naive_bayes() funtion. _____________________________
# ARGUMENTS: ____________________________________________
# X_data - test dataframe _______________________________
# model - model object generated by naive_bayes() funtion
# RETURNS: ______________________________________________
# Function return vector with predictions _______________
# _______________________________________________________
predict.nb <- function(X_data, model){
  
  # vectors with observation indices to get the appropriate probabilities
  indx_to_calc_prob <- list()
  for (i in 1:model$n_var) {
    indx_to_calc_prob <- append(indx_to_calc_prob, list(match(X_data[,i], rownames(model$p_xiy[[i]]))))
  }
  
  # The function calculates the product of the probabilities P(x_i | y) with respect to i
  var_prod <- function(){
    produkt = 1
    for (j in 1:model$n_var) {
      produkt <- produkt * model$p_xiy[[j]][indx_to_calc_prob[[j]],]
    }
    return(produkt)
  }
  pr_warunk <- var_prod()
  rownames(pr_warunk) <- NULL
  
  # Calculate the results, i.e. P(y | x_1, x_2, ..., x_n)
  result <- list()
  for (i in 1:length(model$response_class)) {
    result <- append(result, list(as.matrix(model$p_y[i]*pr_warunk[,i])))
  }
  result <- do.call(cbind.data.frame, result)
  names(result) <- model$response_class
  
  # Predict the class with the highest probability
  return(colnames(result)[apply(result, MARGIN = 1, which.max)])
}





