library(tidymodels)
library(tidyverse)
library(readr)
library(skimr)
library(lubridate)

load("data/loan.rda")

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

