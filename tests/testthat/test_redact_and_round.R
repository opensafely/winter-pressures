library(tibble)


input_d = tibble(
    practice = 1:10,
    num_practices = c(1:10),
    num_patients = c(3:12),
    value = c(4:13)
)


context("Testing the function redact_and_round()")

test_that( desc = "Testing redaction and rounding functions", {

    redacted_string = formals(redact_and_round)$redaction_string

    d_out <- input_d %>%
        mutate(across(starts_with("num"), redact_and_round, redact_below=5 ))

    ### This will be redacted and rounded
    expected_num_practices = c(redacted_string, redacted_string, redacted_string, redacted_string, 5, 5, 5, 10, 10, 10)
    expect_equal(d_out$num_practices, expected_num_practices)

    ### This will be redacted and rounded
    expected_num_patients = c(redacted_string, redacted_string, 5, 5, 5, 10, 10, 10, 10, 10)
    expect_equal(d_out$num_patients, expected_num_patients)

    ### 'value' shouldn't change
    expect_equal(input_d$value, d_out$value)
})


