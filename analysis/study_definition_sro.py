# Import functions

from cohortextractor import (
    StudyDefinition,
    patients,
    codelist_from_csv,
    codelist,
    Measure,
    params
)
sentinel_measures = ["qrisk2", "asthma", "copd", "sodium", "cholesterol", "alt", "tsh", "rbc", 'hba1c', 'systolic_bp', 'medication_review']

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

    age=patients.age_as_of(
            "index_date",
            return_expectations={
                "rate": "universal",
                "int": {"distribution": "population_ages"},
            },
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

    ##### SRO measures

    medication_review =patients.with_these_clinical_events(
        codelist=medication_review_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    medication_review_event_code=patients.with_these_clinical_events(
        codelist=medication_review_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1079381000000109): 0.6, str(1127441000000107): 0.2, str(1239511000000100): 0.2}}, }
    ),
    
    systolic_bp =patients.with_these_clinical_events(
        codelist=systolic_bp_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    systolic_bp_event_code=patients.with_these_clinical_events(
        codelist=systolic_bp_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(198081000000101): 0.6, str(251070002): 0.2, str(271649006): 0.2}}, }
    ),
    
  
    qrisk2 =patients.with_these_clinical_events(
        codelist=qrisk_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    qrisk2_event_code=patients.with_these_clinical_events(
        codelist=qrisk_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1085871000000105): 0.6, str(450759008): 0.2, str(718087004): 0.2}}, }
    ),

    cholesterol =patients.with_these_clinical_events(
        codelist=cholesterol_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    cholesterol_event_code=patients.with_these_clinical_events(
        codelist=cholesterol_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1005671000000105): 0.8, str(1017161000000104): 0.2}}, }
    ),
    
    alt =patients.with_these_clinical_events(
        codelist=alt_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    alt_event_code=patients.with_these_clinical_events(
        codelist=alt_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1013211000000103): 0.8, str(1018251000000107): 0.2}}, }
    ),

    tsh =patients.with_these_clinical_events(
        codelist=tsh_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    tsh_event_code=patients.with_these_clinical_events(
        codelist=tsh_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1022791000000101): 0.8, str(1022801000000102): 0.2}}, }
    ),

    rbc =patients.with_these_clinical_events(
        codelist=rbc_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    rbc_event_code=patients.with_these_clinical_events(
        codelist=rbc_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1022451000000103): 1}}, }
    ),

    hba1c =patients.with_these_clinical_events(
        codelist=hba1c_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    hba1c_event_code=patients.with_these_clinical_events(
        codelist=hba1c_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1003671000000109): 0.6, str(144176003): 0.2, str(166902009): 0.2}}, }
    ),

    sodium =patients.with_these_clinical_events(
        codelist=sodium_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    sodium_event_code=patients.with_these_clinical_events(
        codelist=sodium_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1000661000000107): 0.6, str(1017381000000106): 0.4}}, }
    ),

    asthma =patients.with_these_clinical_events(
        codelist=asthma_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    asthma_event_code=patients.with_these_clinical_events(
        codelist=asthma_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(270442000): 0.6, str(390872009): 0.2, str(390877003): 0.2}}, }
    ),

    copd =patients.with_these_clinical_events(
        codelist=copd_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    copd_event_code=patients.with_these_clinical_events(
        codelist=copd_codelist,
        between=["first_day_of_month(start_date)", "last_day_of_month(end_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(394703002): 0.6, str(760601000000107): 0.2, str(760621000000103): 0.2}}, }
    ),
)
#### Measures

measures = [ ]


### SRO measures
for measure in sentinel_measures:
    measure
    measures.extend([
        Measure(
        id=f"{measure}_rate",
        numerator=measure,
        denominator="population",
        group_by=["practice", f"{measure}_event_code"]
    ),

        Measure(
        id=f"{measure}_practice_only_rate",
        numerator=measure,
        denominator="population",
        group_by=["practice"]
    )
    ])