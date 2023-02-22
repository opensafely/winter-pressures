library(tibble)

input_d_valid = tribble(
    ~practice, ~year, ~summer, ~winter,
    1, 2021, 0.1, 0.2,
    2, 2021, 0.3, 0.4
)


output_expected_valid = tribble(
    ~practice, ~year, ~summer, ~winter, ~seasonal_difference,
    1, 2021, 0.1, 0.2, 0.1,
    2, 2021, 0.3, 0.4, 0.1
)


context("Testing the function calculate_season_difference()")

test_that( desc = "Calculate seasonal difference with valid data", {
    ### The test dataframe (input_d_valid) contains long
    ### data summarising seasonal data:
    ### (1) practice: practice_id
    ### (2) year: year
    ### (3) summer: value for the summer period
    ### (4) winter: value for the winter period
    ### The calculate_season_difference() function add a column
    ### 'seasonal_difference' that will calculate the difference
    ### (winter-summer).

    output_observed_valid = calculate_season_difference(
        input_d_valid
    )

    expect_equal(output_observed_valid, output_expected_valid)
})



input_d_missing = tribble(
    ~practice, ~year, ~summer, ~winter,
    1, 2021, 0.1, 0.2,
    2, 2021, 0.3, NA,
    2, 2021, NA, 0.3
)


output_expected_missing = tribble(
    ~practice, ~year, ~summer, ~winter, ~seasonal_difference,
    1, 2021, 0.1, 0.2, 0.1,
    2, 2021, 0.3, NA, NA,
    2, 2021, NA, 0.3, NA
)

test_that(desc = "Calculate seasonal difference with missing data", {
    ### The test dataframe (input_d_valid) contains long
    ### data summarising seasonal data:
    ### (1) practice: practice_id
    ### (2) year: year
    ### (3) summer: value for the summer period
    ### (4) winter: value for the winter period
    ### The calculate_season_difference() function add a column
    ###  'seasonal_difference' that will calculate the difference
    ### (winter-summer).
    ###
    ### We do know from our previous testing of the function
    ### that gives rise to this input data that NAs will not
    ### be present. However, we have included a test here anyway
    ### incase the input data is generated via some other method.
    ###
    ### Question: should we interpret NAs as 0s?

    output_observed_missing <- calculate_season_difference(
        input_d_missing
    )

    expect_equal(output_observed_missing, output_expected_missing)
})
