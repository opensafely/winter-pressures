library(tibble)

input_d_valid = tribble(
    ~practice, ~year, ~summer, ~winter,
    1, 2021, 0.1, 0.2,
    2, 2021, 0.3, 0.4
)


output_expected_valid = tribble(
    ~practice, ~year, ~summer, ~winter, ~seasonal_log2_ratio,
    1, 2021, 0.1, 0.2, log2(0.2/0.1),
    2, 2021, 0.3, 0.4, log2(0.4/0.3)
)


context("Testing the function calculate_season_ratio()")

test_that( desc = "Calculate seasonal ratio with valid data", {
    ### The test dataframe (input_d_valid) contains long
    ### data summarising seasonal data:
    ### (1) practice: practice_id
    ### (2) year: year
    ### (3) summer: value for the summer period
    ### (4) winter: value for the winter period
    ### The calculate_season_ratio() function add a column
    ###  'seasonal_log2_ratio' that will calculate the
    ### log2 ratio of winter vs summer, specifically:
    ### log2( winter/summer ).

    output_observed_valid = calculate_season_ratio(
        input_d_valid
    )

    expect_equal(output_observed_valid, output_expected_valid)
})



input_d_missing = tribble(
    ~practice, ~year, ~summer, ~winter,
    1, 2021, 0.1, 0.2,
    2, 2021, 0.3, NA,
    3, 2021, NA, 0.3
)

output_expected_missing <- tribble(
    ~practice, ~year, ~summer, ~winter, ~seasonal_log2_ratio,
    1, 2021, 0.1, 0.2, log2(0.2 / 0.1),
    2, 2021, 0.3,  NA, log2(NA / 0.3),
    3, 2021, NA , 0.3, log2(0.3 / NA)
    
)


test_that(desc = "Calculate seasonal ratio with missing data", {
    ### The test dataframe (input_d_valid) contains long
    ### data summarising seasonal data:
    ### (1) practice: practice_id
    ### (2) year: year
    ### (3) summer: value for the summer period
    ### (4) winter: value for the winter period
    ### The calculate_season_ratio() function add a column
    ###  'seasonal_log2_ratio' that will calculate the
    ### log2 ratio of winter vs summer, specifically:
    ### log2( winter/summer ).
    ###
    ### We do know from our previous testing of the function
    ### that gives rise to this input data that NAs will not
    ### be present. However, we have included a test here anyway
    ### incase the input data is generated via some other method.
    ###
    ### Question: should we interpret NAs as 0s?

    output_observed_missing <- calculate_season_ratio(
        input_d_missing
    )

    expect_equal(output_observed_missing, output_expected_missing)
})



input_d_zeros <- tribble(
    ~practice, ~year, ~summer, ~winter,
    1, 2021, 0.1, 0.2,
    2, 2021, 0.3, 0,
    3, 2021, 0, 0.3
)

output_expected_zeros <- tribble(
    ~practice, ~year, ~summer, ~winter, ~seasonal_log2_ratio,
    1, 2021, 0.1, 0.2, log2(0.2 / 0.1),
    2, 2021, 0.3, 0, -Inf,
    3, 2021, 0, 0.3, Inf
)


test_that(desc = "Calculate seasonal ratio where data contain zeros", {
    ### The test dataframe (input_d_valid) contains long
    ### data summarising seasonal data:
    ### (1) practice: practice_id
    ### (2) year: year
    ### (3) summer: value for the summer period
    ### (4) winter: value for the winter period
    ### The calculate_season_ratio() function add a column
    ###  'seasonal_log2_ratio' that will calculate the
    ### log2 ratio of winter vs summer, specifically:
    ### log2( winter/summer ).
    ###
    ### Where zeros are present, we will get Inf/-Inf, where:
    ### * positive Inf indicates that value is 0 in the summer
    ### * negative Inf indicates that value is 0 in the winter

    output_observed_zeros <- calculate_season_ratio(
        input_d_zeros
    )

    expect_equal(output_observed_zeros, output_expected_zeros)
})
