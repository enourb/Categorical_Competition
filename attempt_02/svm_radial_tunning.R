# SVM Radial Tuning

library(tidyverse)
library(tidymodels)
library(stacks)
set.seed(333)

load("../data/temp_02/loan_setup.rda")


# define model

svm_radial_model <- svm_rbf(cost = tune(), rbf_sigma = tune(), margin = tune()) %>%
  set_engine("kernlab") %>%
  set_mode("classification")


# set up tuning grid

svm_radial_params <- parameters(svm_radial_model)


# define grid

svm_radial_grid <- grid_regular(svm_radial_params, levels = 5)


# workflow

svm_radial_workflow <- workflow() %>%
  add_model(svm_radial_model) %>%
  add_recipe(loan_recipe)


# Tuning/fitting

svm_radial_tune <- svm_radial_workflow %>%
  tune_grid(resamples = loan_fold,
            grid = svm_radial_grid,
            control = control_stack_grid())



# Write out results and workflow
save(svm_radial_tune, svm_radial_workflow, file = "../data/temp_02/svm_radial_tune.rda")
