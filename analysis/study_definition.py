from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv  # NOQA


study = StudyDefinition(
    index_date = "2010-01-01", 

    default_expectations={
        "date": {"earliest": "index_date", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },

    population=patients.satisfying(
        "registered",
        registered=patients.registered_as_of("index_date",),
    ),
)
