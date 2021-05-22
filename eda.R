library(tidymodels)
library(tidyverse)
library(readr)
library(skimr)
library(lubridate)

loan <- read.csv(file = "data/train.csv") %>%
  mutate(
    hi_int_prncp_pd = as.factor(hi_int_prncp_pd),
    initial_list_status = as.factor(initial_list_status),
    verification_status = as.factor(verification_status),
    last_credit_pull_d = paste(last_credit_pull_d, "-01"),
    last_credit_pull_d = myd(last_credit_pull_d),
    earliest_cr_line = paste(earliest_cr_line, "-01"),
    earliest_cr_line = myd(earliest_cr_line),
    addr_state = as.factor(addr_state),
    emp_title = as.factor(emp_title),
    home_ownership = as.factor(home_ownership),
    purpose = as.factor(purpose),
    application_type = as.factor(application_type),
    grade = as.factor(grade),
    sub_grade = as.factor(sub_grade),
    term = as.factor(term),
    emp_length = as.factor(emp_length)
  )

## emp_title has too many factors
skim_without_charts(loan)

## sub_grade perfectly explains grade
ggplot(loan, aes(grade, sub_grade)) +
  geom_point()
## significantly more 0
ggplot(loan, aes(emp_title)) +
  geom_bar()


ggplot(loan, aes(hi_int_prncp_pd)) +
  geom_bar()

## some highly used states, step_other() appropriate
ggplot(loan, aes(addr_state)) +
  geom_bar()

## some highly used purpose, step_other() appropriate
ggplot(loan, aes(purpose)) +
  geom_bar()

ggplot(loan, aes(emp_length)) +
  geom_bar()

## single high month, new variable appropriate
ggplot(loan, aes(months.Date(last_credit_pull_d))) +
  geom_bar()

ggplot(loan, aes(months.Date(earliest_cr_line))) +
  geom_bar()

ggplot(loan, aes(home_ownership)) +
  geom_histogram()

loan <- loan %>%
  mutate(
    last_credit_feb = ifelse(months.Date(last_credit_pull_d) == "February", 1, 0)
  )

save(loan, file = "data/loan.rda")
