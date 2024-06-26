library(tibble)

input_d_valid = tribble(
    ~practice,  ~season, ~year, ~value,
    1, 0, 2021, 0.1,
    1, 1, 2021, 0.2,
    2, 0, 2021, 0.3,
    2, 1, 2021, 0.4,
    3, 0, 2021, 0.5,
    3, 1, 2022, 0.6,
    4, 0, 2022, 0.7,
    4, 1, 2022, NA,
    5, 0, 2021, 0.1,
    5, 1, 2021, 0.2,
)

input_practices_to_remove <- c(5)

output_expected_valid = tribble(
    ~practice, ~year, ~summer, ~winter,
    1, 2021, 0.1, 0.2,
    2, 2021, 0.3, 0.4
)

context("Testing the function generate_wide_season_data()")

test_that( desc = "Wide to long with valid data", {
    ### The test dataframe (input_d_valid) contains long
    ### data summarising seasonal data:
    ### (1) practice: practice_id
    ### (2) season: where 1=winter and 0=summer
    ### (3) year: year
    ### (4) value: the value
    ### The generate_wide_season_data() function will translate this to a wide
    ### format, retaining only those practices where:
    ### - there is a seasonal summary entry for summer AND winter
    ### - neither seasonal summary entry for summer or winter is NA

    if (!(Sys.getenv("OPENSAFELY_BACKEND") %in% c("", "expectations"))) {
        output_observed_valid = generate_wide_season_data(
            season_data = input_d_valid,
            practices_to_remove = input_practices_to_remove
        )
        expect_equal(output_observed_valid, output_expected_valid)
    } 
})


input_d_invalid_season_code <- tribble(
    ~practice, ~season, ~year, ~value,
    1, 2, 2021, 0.1,
    1, 3, 2021, 0.2
)

output_expected_invalid_season_code <- tribble()

test_that(desc = "Wide to long with invalid season codes", {
    ### The test dataframe (input_d_invalid_season_code)
    ### contains long data summarising seasonal data:
    ### (1) practice: practice_id
    ### (2) season: where 1=winter and 0=summer
    ### (3) year: year
    ### (4) value: the value

    expect_error(
      generate_wide_season_data(
        season_data = input_d_invalid_season_code,
        practices_to_remove = input_practices_to_remove
      ),
      "Invalid season entry: values must be either 0 or 1."
    )
})
