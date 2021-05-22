library(tidymodels)
library(tidyverse)
library(skimr)
library(readr)
library(lubridate)
library(stacks)

set.seed(333)

load("data/loan.rda")


loan_split <- initial_split(loan, prop = .8, strata = hi_int_prncp_pd)
loan_train <- training(loan_split)
loan_test <- testing(loan_split)

loan_fold <- vfold_cv(loan_train, v = 10, repeats = 5, strata = hi_int_prncp_pd)

loan_recipe <- recipe(hi_int_prncp_pd ~ ., data = loan_train) %>%
  step_rm(sub_grade, id, emp_title) %>%
  step_date(earliest_cr_line, features = c("year")) %>%
  step_date(last_credit_pull_d, features = c("year")) %>%
  step_rm(earliest_cr_line, last_credit_pull_d) %>%
  step_other(addr_state, emp_length, threshold = .05) %>%
  step_dummy(all_nominal(), -all_outcomes(), one_hot = T) %>%
  step_nzv(all_predictors()) %>%
  step_normalize(all_predictors(), -all_outcomes())



skim_without_charts(
  loan_recipe %>%
  prep(loan_train) %>%
  bake(new_data = NULL)
)

save(loan_fold, loan_recipe, loan_split, loan_train, file = "data/temp_02/loan_setup.rda")


load(file = "data/temp_02/rf_tune.rda")
load(file = "data/temp_02/nnet_tune.rda")
load(file = "data/temp_02/mars_tune.rda")

loan_data_stack <- stacks() %>%
  add_candidates(nnet_tune) %>%
  add_candidates(rf_tune) %>%
  add_candidates(mars_tune)

blend_penalty <- c(10^(-6:-1), 0.5, 1, 1.5, 2)


loan_model_stack <-
  loan_data_stack %>%
  blend_predictions(penalty = blend_penalty)


loan_model_stack <-
  loan_model_stack %>%
  fit_members()

autoplot(loan_model_stack, type = "weights") +
  theme_minimal()


testing <- read.csv(file = "data/test.csv") %>%
  mutate(
    initial_list_status = as.factor(initial_list_status),
    verification_status = as.factor(verification_status),
    last_credit_pull_d = paste(last_credit_pull_d, "-01"),
    last_credit_pull_d = myd(last_credit_pull_d),
    earliest_cr_line = paste(earliest_cr_line, "-01"),
    earliest_cr_line = myd(earliest_cr_line),
    addr_state = as.factor(addr_state),
    emp_title = as.factor(emp_title),
    home_ownership = as.factor(home_ownership),
    application_type = as.factor(application_type),
    grade = as.factor(grade),
    sub_grade = as.factor(sub_grade),
    term = as.factor(term),
    emp_length = as.factor(emp_length)
  )

valid_purpose <- c("credit_card", "debt_consolidation", "home_improvement")

testing <- testing %>%
  mutate(
    last_credit_feb = ifelse(months.Date(last_credit_pull_d) == "February", 1, 0),
    purpose = ifelse(purpose %in% valid_purpose, purpose, "other"),
    purpose = as.factor(purpose)
  )


final_predict <- loan_model_stack %>%
  predict(testing) %>%
  rename(Id = .pred_class)


write.csv(final_predict, file = "data/temp_02/test_pred.csv")
