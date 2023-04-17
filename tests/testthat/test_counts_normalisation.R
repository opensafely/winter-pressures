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

    out = normalise_raw_counts(input_raw_counts, input_practice_populations)
    output_observed = out$normalised
    
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

    out <- normalise_raw_counts(input_raw_counts_missing_count, input_practice_populations)
    output_observed = out$normalised

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

    out <- normalise_raw_counts(input_raw_counts, input_practice_populations_one_missing)
    output_observed = out$normalised

    output_expected <- output_expected %>% arrange(practice, date)
    output_observed <- output_observed %>% arrange(practice, date)

    expect_equal(output_observed, output_expected)
})

input_raw_counts = tribble(
    ~raw_count, ~date, ~practice,
    100, "2021-01-01", 1,
    200, "2021-02-01", 1,
    50, "2021-01-01", 2,
    50, "2021-02-01", 2
) %>% mutate( date = as_date(date) )

input_practice_populations_for_population_missing = tribble(
    ~practice, ~population, ~date,
    1, 200, "2021-02-01",
    2, 500, "2021-01-01",
    2, 1000, "2021-02-01"
) %>% mutate( date = as_date(date) )


test_that(desc = glue("Valid data for population_missing"), {
    output_expected_population_missing <- tribble(
        ~date, ~raw_count_dropped, ~num_practices,
        "2021-01-01", 100,1,
    ) %>% mutate(date = as_date(date))

    out = normalise_raw_counts(input_raw_counts, input_practice_populations_for_population_missing)
    output_observed_population_missing = out$population_missing
    
    output_expected_population_missing <- output_expected_population_missing %>% arrange(date,raw_count_dropped)
    output_observed_population_missing <- output_observed_population_missing %>% arrange(date,raw_count_dropped)

    expect_equal(output_observed_population_missing,output_expected_population_missing)   
})

test_that(desc = glue("Null for zero missing population_missing"), {
    out = normalise_raw_counts(input_raw_counts, input_practice_populations)
    output_observed_population_missing = out$population_missing
    
    expect_equal(output_observed_population_missing$date,as_date(NULL))
    expect_equal(output_observed_population_missing$raw_count_dropped,as.numeric(NULL))
    expect_equal(output_observed_population_missing$num_practices,as.numeric(NULL))
})



input_raw_counts_for_raw_counts_missing = tribble(
    ~raw_count, ~date, ~practice,
    200, "2021-02-01", 1,
    50, "2021-01-01", 2,
    50, "2021-02-01", 2
) %>% mutate( date = as_date(date) )

input_practice_populations = tribble(
    ~practice, ~population, ~date,
    1, 200, "2021-01-01",
    1, 300, "2021-02-01",
    2, 500, "2021-01-01",
    2, 1000, "2021-02-01"
) %>% mutate( date = as_date(date) )


test_that(desc = glue("Valid data for raw_counts_missing"), {
    output_expected_raw_counts_missing <- tribble(
        ~date, ~population_dropped, ~num_practices,
        "2021-01-01", 300,1,
 ) %>% mutate(date = as_date(date))

    out = normalise_raw_counts(input_raw_counts_for_raw_counts_missing, input_practice_populations)
    output_observed_raw_counts_missing = out$raw_counts_missing
    
    output_expected_raw_counts_missing <- output_expected_raw_counts_missing %>% arrange(date,population_dropped)
    output_observed_raw_counts_missing <- output_observed_raw_counts_missing %>% arrange(date,population_dropped)

    expect_equal(output_observed_raw_counts_missing,output_observed_raw_counts_missing)
    

})

test_that(desc = glue("Null for zero missing raw_counts_missing"), {
    out = normalise_raw_counts(input_raw_counts, input_practice_populations)
    output_observed_raw_counts_missing = out$raw_counts_missing

    expect_equal(output_observed_raw_counts_missing$date,as_date(NULL))
    expect_equal(output_observed_raw_counts_missing$population_dropped,as.numeric(NULL))
    expect_equal(output_observed_raw_counts_missing$num_practices,as.numeric(NULL))
})