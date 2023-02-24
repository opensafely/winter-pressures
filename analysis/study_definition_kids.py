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


# Specifiy study definition
study = StudyDefinition(
    index_date=start_date,
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "exponential_increase",
        "incidence": 0.1,
    },
    population = patients.satisfying(
        """
        registered AND
        (NOT died) 
        """,
    ),
    start_date = patients.fixed_value(start_date),
    end_date = patients.fixed_value(end_date),
    
    registered = patients.registered_as_of(
        "index_date",
        return_expectations={"incidence": 0.9},
        ),
    
    died = patients.died_from_any_cause(
        on_or_before="index_date",
        returning="binary_flag",
        return_expectations={"incidence": 0.1}
        ),

    age=patients.age_as_of(
        "index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),

    practice=patients.registered_practice_as_of(
        "index_date",
        returning="pseudo_id",
        return_expectations={"int" : {"distribution": "normal", "mean": 25, "stddev": 5}, "incidence" : 0.5}
    ),


    population_over12 = patients.satisfying(
        """
        (age >11 AND age <=15) 
        """,
    ),

    population_under12 = patients.satisfying(
        """
        (age >=5 AND age <=11) 
        """,
    ),

    ### appointment 
    appt = patients.with_gp_consultations(
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ), 

    appt_over12 = patients.satisfying(
    """
    appt AND
    population_over12
    """
    ),

    appt_under12 = patients.satisfying(
    """
    appt AND
    population_under12
    """
    )

)
#### Measures

measures = [
    ##### child appt rate per child population
    Measure(
    id=f"over12_appt_rate",
    numerator="appt_over12",
    denominator="population_over12",
    group_by=["practice"]
),

    Measure(
    id=f"under12_appt_rate",
    numerator="appt_under12",
    denominator="population_under12",
    group_by=["practice"]
),
    
    ##### child rate per total population
    Measure(
    id=f"over12_appt_pop_rate",
    numerator="appt_over12",
    denominator="population",
    group_by=["practice"]
),

    Measure(
    id=f"under12_appt_pop_rate",
    numerator="appt_under12",
    denominator="population",
    group_by=["practice"]
),

]
