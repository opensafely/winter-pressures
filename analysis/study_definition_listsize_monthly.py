# Import functions

from cohortextractor import (
    StudyDefinition,
    patients,
    codelist_from_csv,
    codelist,
    Measure,
    params
)

# Import codelists

from codelists import *
from datetime import date

start_date = "2018-06-01"

# Specifiy study definition
study = StudyDefinition(
    index_date=start_date,
    default_expectations={
        "date": {"earliest": "index_date", "latest": "today"},
        "rate": "exponential_increase",
        "incidence": 0.1,
    },
    population = patients.satisfying(
        """
        registered AND
        (NOT died) 
        """,
    ),
    
    registered = patients.registered_as_of(
        "index_date",
        return_expectations={"incidence": 0.9},
        ),
    
    died = patients.died_from_any_cause(
        on_or_before="index_date",
        returning="binary_flag",
        return_expectations={"incidence": 0.1}
        ),

    practice=patients.registered_practice_as_of(
        "index_date",
        returning="pseudo_id",
        return_expectations={"int" : {"distribution": "normal", "mean": 25, "stddev": 5}, "incidence" : 0.5}
    ),

)

#### Measures

measures = [
    ##### child appt rate per child population
    Measure(
    id=f"listsize",
    numerator="population",
    denominator="population",
    group_by=["practice"]
),

]
