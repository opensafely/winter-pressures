from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv  # NOQA

from lib.appointments_helper_functions import get_X_appointments

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

    **get_X_appointments(
        name="appointment",
        index_date="index_date",
        n=10,
        report=False
    )
    
)

