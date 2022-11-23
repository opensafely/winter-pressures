from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv  # NOQA

from lib.appointments_helper_functions import get_X_appointments

index_date = "2020-03-01"

study = StudyDefinition(
    index_date=index_date,

    default_expectations={
        "date": {"earliest": "index_date", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },

    population=patients.satisfying(
        "registered",
        registered=patients.registered_as_of("index_date",),
    ),

    ### ========================================================= ###
    ### === ADMINISTRATIVE DATA ================================= ###
    ### ========================================================= ###

    practice=patients.registered_practice_as_of(
        "index_date",
        returning="pseudo_id",
        return_expectations={
            "int": {"distribution": "normal", "mean": 50, "stddev": 30},
            "incidence": 1,
        },
    ),

    region=patients.registered_practice_as_of(
        "index_date",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "North East": 0.1,
                    "North West": 0.1,
                    "Yorkshire and the Humber": 0.1,
                    "East Midlands": 0.1,
                    "West Midlands": 0.1,
                    "East of England": 0.1,
                    "London": 0.2,
                    "South East": 0.2,
                },
            },
        },
    ),

    ### ========================================================= ###
    ### === APPOINTMENTS DATA =================================== ###
    ### ========================================================= ###

    **get_X_appointments(
        name="appointment",
        index_date="index_date",
        n=10,
        report=False
    )

)
