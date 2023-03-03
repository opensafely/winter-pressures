library(tibble)
library(glue)

context("Testing calculate_deciles()")

n_practices = 10

test_that( desc = glue("{n_practices} valid datapoints"), {
    input_d = 1:n_practices
    output_expected = input_d
    output_observed <- calculate_deciles(input_d)
    expect_equal(output_observed, output_expected)
})

test_that(desc = glue("{n_practices-1} valid and 1 missing datapoints"), {
    input_d <- c(1:(n_practices - 1), NA)
    output_expected <- input_d
    output_observed <- calculate_deciles(input_d)
    expect_equal(output_observed, output_expected)
})

test_that(desc = glue("{n_practices*n_practices} valid datapoints"), {
    input_d <- 1:(n_practices * n_practices)
    output_expected <- rep(1:n_practices, each = n_practices)
    output_observed <- calculate_deciles(input_d)
    expect_equal(output_observed, output_expected)
})

context("Testing calculate_seasonal_deciles_across_years_and_variables()")

practice_list = 1:n_practices
year_list = c(2020,2021)
methods_list = c("seasonal_X","seasonal_Y")
variable_list = c("A", "B")

n_vars = variable_list %>% length()
n_methods = methods_list %>% length()
n_years = year_list %>% length()

test_dataset = tibble(
    practice = NA,
    year = NA,
    seasonal_sum = NA,
    seasonal_ratio = NA,
    variable = NA
)

test_dataset <- as_tibble(expand.grid(
    practice = practice_list,
    year = year_list,
    method = methods_list,
    variable = variable_list,
    stringsAsFactors = FALSE
)) %>%
    mutate(seasonal_sum = case_when(
        year == 2020 & variable == "A" ~ practice,
        year == 2020 & variable == "B" ~ length(practice_list) - practice,
        year == 2021 & variable == "A" ~ length(practice_list) - practice,
        year == 2021 & variable == "B" ~ practice
    )) %>%
    mutate(seasonal_ratio = case_when(
        year == 2020 & variable == "A" ~ length(practice_list) - practice,
        year == 2020 & variable == "B" ~ practice,
        year == 2021 & variable == "A" ~ practice,
        year == 2021 & variable == "B" ~ length(practice_list) - practice
    )) %>%
    select(practice, year, starts_with("seasonal"), variable) %>%
    unique()



test_that(desc = glue("Complex test ({n_years} years/{n_practices} practices/{n_vars} variables/{n_methods} methods)"), {
    output_observed = calculate_seasonal_deciles_across_years_and_variables(test_dataset)
    
    expected_nrow = n_practices * n_years * n_vars * n_methods
    expect_equal( nrow(output_observed), expected_nrow)

    expected_columns = c("practice", "year", "variable", "method", "value", "decile")
    expect_equal(colnames(output_observed), expected_columns)

    test_matrix = tribble(
        ~year, ~variable, ~practice, ~method, ~answer,
        2020, "A", 10, "seasonal_sum"  , 10,
        2020, "A", 10, "seasonal_ratio",  1,
        2021, "A", 10, "seasonal_sum"  ,  1,
        2021, "A", 10, "seasonal_ratio", 10
    )
        
    for ( i in 1:nrow(test_matrix) ) {
        expected_result = test_matrix$answer[i]
        observed_result = output_observed %>%
            filter(
                year == test_matrix$year[i] & 
                variable == test_matrix$variable[i]  & 
                practice == test_matrix$practice[i]  & 
                method == test_matrix$method[i] ) %>%
            pull( decile )

        expect_equal(observed_result, expected_result)
    }

})
