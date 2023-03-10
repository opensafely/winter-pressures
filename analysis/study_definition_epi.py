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


start_date = params["start_date"]
end_date = params["end_date"]

############################################################
## outcome variables
from epi.variables_outcome import generate_outcome_variables
outcome_variables = generate_outcome_variables(start_date="start_date",end_date ="end_date")
############################################################


# Specifiy study definition
study = StudyDefinition(
    index_date=start_date,
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "exponential_increase",
        "incidence": 0.1,
    },
    population=patients.satisfying(
        """
        registered AND
        (NOT died) AND
        (age >=18 AND age <=120) 
        """,
    ),
    start_date = patients.fixed_value(start_date),
    end_date = patients.fixed_value(end_date),

    registered=patients.registered_as_of(
            "index_date",
            return_expectations={"incidence": 0.9},
        ),

    population_over12 = patients.satisfying(
    """
    (age >11 AND age <=15) 
    """,
    
        age=patients.age_as_of(
            "index_date",
            return_expectations={
                "rate": "universal",
                "int": {"distribution": "population_ages"},
            },
        ),
    ),

    died = patients.died_from_any_cause(
        on_or_before="index_date",
        returning="binary_flag",
        return_expectations={"incidence": 0.1}
        ),
        
    population_under12 = patients.satisfying(
        """
        (age >=5 AND age <=11) 
        """,
    ),

    population_sro = patients.satisfying(
        """
        (age >=18 AND age <=120)
        """,
    ),

    practice=patients.registered_practice_as_of(
        "index_date",
        returning="pseudo_id",
        return_expectations={"int" : {"distribution": "normal", "mean": 25, "stddev": 5}, "incidence" : 0.5}
    ),
  ##############################################################################
  # outcomes
  ##############################################################################
    **outcome_variables,

)