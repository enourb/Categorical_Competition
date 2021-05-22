library(tidymodels)
library(tidyverse)
library(readr)
library(skimr)
library(lubridate)

# convert categorical variables to factors
# convert dates to standard date form
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

# Add february dummy becomes all other months have similar values excpet the huge spike at february
loan <- loan %>%
  mutate(
    last_credit_feb = ifelse(months.Date(last_credit_pull_d) == "February", 1, 0)
  )

save(loan, file = "data/loan.rda")
