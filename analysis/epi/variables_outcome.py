from cohortextractor import patients, combine_codelists
from codelists import *
import codelists

from itertools import product

icd_chapters = [
    f"icd{n[0]}"
    for n in product( list(range(1,23)))
]

def icd_deaths_between(start_date, end_date):
  return{   
            f"{chapter}_death_date": patients.with_these_codes_on_death_certificate(
            between=[start_date,end_date],
            codelist=globals()[chapter],
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            )
            for chapter in icd_chapters
        }

def generate_outcome_variables(start_date, end_date):
  outcome_variables = dict(

    dereg_date=patients.date_deregistered_from_all_supported_practices(
      between=[start_date,end_date],
      date_format="YYYY-MM-DD",
    ),
  
    # All-cause death
    death_date=patients.died_from_any_cause(
      between=[start_date,end_date],
      returning="date_of_death",
      date_format="YYYY-MM-DD",
    ),
    
    **icd_deaths_between(start_date, end_date),

    emergency_date=patients.attended_emergency_care(
      returning="date_arrived",
      between=[start_date,end_date],
      date_format="YYYY-MM-DD",
      find_first_match_in_period=True,
    ),
    
        # unplanned hospital admission
    admitted_unplanned_date=patients.admitted_to_hospital(
      returning="date_admitted",
      between=[start_date,end_date],
      # see https://github.com/opensafely-core/cohort-extractor/pull/497 for codes
      # see https://docs.opensafely.org/study-def-variables/#sus for more info
      with_admission_method=["21", "22", "23", "24", "25", "2A", "2B", "2C", "2D", "28"],
      with_patient_classification = ["1"], # ordinary admissions only
      date_format="YYYY-MM-DD",
      find_first_match_in_period=True,
    ),

  )

  return outcome_variables

