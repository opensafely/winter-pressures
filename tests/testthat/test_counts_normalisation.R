library(tibble)
library(glue)

context("Testing normalise_raw_counts()")

input_raw_counts = tribble(
    ~raw_count, ~date, ~practice,
    100, "2021-01-01", 1,
    200, "2021-02-01", 1,
    50, "2021-01-01", 2,
    50, "2021-02-01", 2
) %>% mutate( date = as_date(date) )

input_practice_populations = tribble(
    ~practice, ~population, ~date,
    1, 200, "2021-01-01",
    1, 200, "2021-02-01",
    2, 500, "2021-01-01",
    2, 1000, "2021-02-01"
) %>% mutate( date = as_date(date) )

test_that( desc = glue("Valid data"), {
    output_expected = tribble(
        ~value, ~date, ~practice,
        0.5, "2021-01-01", 1,
        1.0, "2021-02-01", 1,
        0.1, "2021-01-01", 2,
        0.05, "2021-02-01", 2
    ) %>% mutate( date = as_date(date) )

    output_observed = normalise_raw_counts(input_raw_counts, input_practice_populations)
    
    output_expected = output_expected %>% arrange(practice, date)
    output_observed = output_observed %>% arrange(practice, date)

    expect_equal(output_observed, output_expected)
})



input_raw_counts_missing_count <- tribble(
    ~raw_count, ~date, ~practice,
    100, "2021-01-01", 1,
    200, "2021-02-01", 1,
    NA, "2021-01-01", 2,
    50, "2021-02-01", 2
) %>% mutate(date = as_date(date))

test_that(desc = glue("One missing raw count"), {
    output_expected <- tribble(
        ~value, ~date, ~practice,
        0.5, "2021-01-01", 1,
        1.0, "2021-02-01", 1,
        NA, "2021-01-01", 2,
        0.05, "2021-02-01", 2
    ) %>% mutate(date = as_date(date))

    output_observed <- normalise_raw_counts(input_raw_counts_missing_count, input_practice_populations)

    output_expected <- output_expected %>% arrange(practice, date)
    output_observed <- output_observed %>% arrange(practice, date)

    expect_equal(output_observed, output_expected)
})


input_practice_populations_one_missing <- tribble(
    ~practice, ~population, ~date,
    1, 200, "2021-01-01",
    1, 200, "2021-02-01",
    2, 500, "2021-01-01",
    2, NA, "2021-02-01"
) %>% mutate(date = as_date(date))


test_that(desc = glue("One missing population"), {
    output_expected <- tribble(
        ~value, ~date, ~practice,
        0.5, "2021-01-01", 1,
        1.0, "2021-02-01", 1,
        0.1, "2021-01-01", 2,
        NA, "2021-02-01", 2
    ) %>% mutate(date = as_date(date))

    output_observed <- normalise_raw_counts(input_raw_counts, input_practice_populations_one_missing)

    output_expected <- output_expected %>% arrange(practice, date)
    output_observed <- output_observed %>% arrange(practice, date)

    expect_equal(output_observed, output_expected)
})
