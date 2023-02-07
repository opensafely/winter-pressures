# Import functions

from cohortextractor import (
    StudyDefinition,
    patients,
    codelist_from_csv,
    codelist,
    Measure
)
sentinel_measures = ["qrisk2", "asthma", "copd", "sodium", "cholesterol", "alt", "tsh", "rbc", 'hba1c', 'systolic_bp', 'medication_review']

from metrics.co_prescribing_variables import create_co_prescribing_variables
from metrics.config import indicators_list


# Import codelists

from codelists import *
from datetime import date


### start, end and index dates will be ignored and replaced with dates specified in the yaml file
start_date = "2019-01-01"
end_date = "2022-04-30"
# Specifiy study definition





study = StudyDefinition(
    index_date=start_date,
    default_expectations={
        "date": {"earliest": start_date, "latest": end_date},
        "rate": "exponential_increase",
        "incidence": 0.1,
    },
    # N.B. `population` here is the population as specified in SRO. The population as specified in Pincer  is defined as `pincer_population` below
    population=patients.satisfying(
        """
        registered AND
        (NOT died) AND
        (age >=18 AND age <=120) 
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

    practice_population=patients.satisfying(
        """
        age <=120 AND
        registered
        """,
    ),

    ##### SRO measures

    medication_review=patients.with_these_clinical_events(
        codelist=medication_review_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    medication_review_event_code=patients.with_these_clinical_events(
        codelist=medication_review_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1079381000000109): 0.6, str(1127441000000107): 0.2, str(1239511000000100): 0.2}}, }
    ),
    
    systolic_bp=patients.with_these_clinical_events(
        codelist=systolic_bp_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    systolic_bp_event_code=patients.with_these_clinical_events(
        codelist=systolic_bp_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(198081000000101): 0.6, str(251070002): 0.2, str(271649006): 0.2}}, }
    ),
    
  
    qrisk2=patients.with_these_clinical_events(
        codelist=qrisk_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    qrisk2_event_code=patients.with_these_clinical_events(
        codelist=qrisk_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1085871000000105): 0.6, str(450759008): 0.2, str(718087004): 0.2}}, }
    ),

    cholesterol=patients.with_these_clinical_events(
        codelist=cholesterol_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    cholesterol_event_code=patients.with_these_clinical_events(
        codelist=cholesterol_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1005671000000105): 0.8, str(1017161000000104): 0.2}}, }
    ),
    
    alt=patients.with_these_clinical_events(
        codelist=alt_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    alt_event_code=patients.with_these_clinical_events(
        codelist=alt_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1013211000000103): 0.8, str(1018251000000107): 0.2}}, }
    ),

    tsh=patients.with_these_clinical_events(
        codelist=tsh_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    tsh_event_code=patients.with_these_clinical_events(
        codelist=tsh_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1022791000000101): 0.8, str(1022801000000102): 0.2}}, }
    ),

    rbc=patients.with_these_clinical_events(
        codelist=rbc_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    rbc_event_code=patients.with_these_clinical_events(
        codelist=rbc_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1022451000000103): 1}}, }
    ),

    hba1c=patients.with_these_clinical_events(
        codelist=hba1c_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    hba1c_event_code=patients.with_these_clinical_events(
        codelist=hba1c_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1003671000000109): 0.6, str(144176003): 0.2, str(166902009): 0.2}}, }
    ),

    sodium=patients.with_these_clinical_events(
        codelist=sodium_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    sodium_event_code=patients.with_these_clinical_events(
        codelist=sodium_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(1000661000000107): 0.6, str(1017381000000106): 0.4}}, }
    ),

    asthma=patients.with_these_clinical_events(
        codelist=asthma_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    asthma_event_code=patients.with_these_clinical_events(
        codelist=asthma_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(270442000): 0.6, str(390872009): 0.2, str(390877003): 0.2}}, }
    ),

    copd=patients.with_these_clinical_events(
        codelist=copd_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="binary_flag",
        return_expectations={"incidence": 0.5}
    ),

    copd_event_code=patients.with_these_clinical_events(
        codelist=copd_codelist,
        between=["first_day_of_month(index_date)", "last_day_of_month(index_date)"],
        returning="code",
        return_expectations={"category": {
            "ratios": {str(394703002): 0.6, str(760601000000107): 0.2, str(760621000000103): 0.2}}, }
    ),
    
    ##### PINCER Indicators
    # MONITORING COMPOSITE INDICATOR
    # AC - ACEI Audit (MO_P13)
    ####
    acei=patients.with_these_medications(
        codelist=acei_codelist,
        find_first_match_in_period=True,
        returning="binary_flag",
        on_or_before="index_date - 15 months",
    ),
    loop_diuretic=patients.with_these_medications(
        codelist=loop_diuretics_codelist,
        find_first_match_in_period=True,
        returning="binary_flag",
        on_or_before="index_date - 15 months",
    ),
    acei_recent=patients.with_these_medications(
        codelist=acei_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 6 months", "index_date"],
    ),
    loop_diuretic_recent=patients.with_these_medications(
        codelist=loop_diuretics_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 6 months", "index_date"],
    ),
    renal_function_test=patients.with_these_clinical_events(
        codelist=renal_function_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 15 months", "index_date"],
    ),
    electrolytes_test=patients.with_these_clinical_events(
        codelist=electrolytes_test_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 15 months", "index_date"],
    ),
    indicator_ac_denominator=patients.satisfying(
        """
        (age >=75 AND age <=120) AND
        (acei AND acei_recent) OR
        (loop_diuretic AND loop_diuretic_recent)
        """,
    ),
    indicator_ac_numerator=patients.satisfying(
        """
        (age >=75 AND age <=120) AND
        ((loop_diuretic AND loop_diuretic_recent) OR (acei AND acei_recent))AND
        ((NOT renal_function_test) OR (NOT electrolytes_test))
        """,
    ),
    ###
    # MONITORING COMPOSITE INDICATOR
    # ME - Methotrexate audit (MO_P15)
    ####
    methotrexate_6_3_months=patients.with_these_medications(
        codelist=methotrexate_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 6 months", "index_date - 3 months"],
    ),
    methotrexate_3_months=patients.with_these_medications(
        codelist=methotrexate_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 3 months", "index_date"],
    ),
    full_blood_count=patients.with_these_clinical_events(
        codelist=full_blood_count_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 3 months", "index_date"],
    ),
    liver_function_test=patients.with_these_clinical_events(
        codelist=liver_function_test_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 3 months", "index_date"],
    ),
    indicator_me_denominator=patients.satisfying(
        """
        methotrexate_6_3_months AND
        methotrexate_3_months
        """,
    ),
    indicator_me_no_fbc_numerator=patients.satisfying(
        """
        methotrexate_6_3_months AND
        methotrexate_3_months AND
        (NOT full_blood_count)
        """,
    ),
    indicator_me_no_lft_numerator=patients.satisfying(
        """
        methotrexate_6_3_months AND
        methotrexate_3_months AND
        (NOT liver_function_test)
        """,
    ),
    ###
    # MONITORING COMPOSITE INDICATOR
    # LI - Lithium audit (MO_P17)
    ####
    lithium_6_3_months=patients.with_these_medications(
        codelist=lithium_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 6 months", "index_date - 3 months"],
    ),
    lithium_3_months=patients.with_these_medications(
        codelist=lithium_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 3 months", "index_date"],
    ),
    lithium_level_3_months=patients.with_these_clinical_events(
        codelist=lithium_level_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 3 months", "index_date"],
    ),
    indicator_li_denominator=patients.satisfying(
        """
        lithium_6_3_months AND
        lithium_3_months
        """,
    ),
    indicator_li_numerator=patients.satisfying(
        """
        lithium_6_3_months AND
        lithium_3_months AND 
        (NOT lithium_level_3_months)
        """,
    ),
    ###
    # MONITORING COMPOSITE INDICATOR
    # AM - Amiodarone audit (MO_P18)
    ####
    amiodarone_12_6_months=patients.with_these_medications(
        codelist=amiodarone_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 12 months", "index_date - 6 months"],
    ),
    amiodarone_6_months=patients.with_these_medications(
        codelist=amiodarone_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 6 months", "index_date"],
    ),
    thyroid_function_test=patients.with_these_clinical_events(
        codelist=thyroid_function_test_codelist,
        find_last_match_in_period=True,
        returning="binary_flag",
        between=["index_date - 6 months", "index_date"],
    ),
    indicator_am_denominator=patients.satisfying(
        """
        amiodarone_12_6_months AND
        amiodarone_6_months
        """,
    ),
    indicator_am_numerator=patients.satisfying(
        """
        amiodarone_12_6_months AND
        amiodarone_6_months AND
        (NOT thyroid_function_test)
        """,
    ),

    # pincer_population=patients.satisfying(
    #     """
    #     registered AND
    #     NOT died AND
    #     (age >=18 AND age <=120) AND 
    #     (
    #        (age >=65 AND (NOT ppi)) OR
    #        (methotrexate_6_3_months AND methotrexate_3_months) OR
    #        (lithium_6_3_months AND lithium_3_months) OR
    #        (amiodarone_12_6_months AND amiodarone_6_months) OR
    #        ((gi_bleed OR peptic_ulcer) AND (NOT ppi)) OR
    #        (anticoagulant) OR
    #        (aspirin AND (NOT ppi)) OR
    #        ((asthma AND (NOT asthma_resolved)) OR (asthma_resolved_date <= asthma_date)) OR
    #        (heart_failure) OR
    #        (egfr_between_1_and_45=1) OR
    #        (age >= 75 AND acei AND acei_recent) OR
    #        (age >=75 AND loop_diuretic AND loop_diuretic_recent)
    #     )
    #     """
    # ),
)

measures = [
    # Measure(
    #     id="practice_population_rate",
    #     numerator="practice_population",
    #     denominator="pincer_population",
    #     group_by=["practice"],
    # )
]

for indicator in indicators_list:

    if indicator in ["me_no_fbc", "me_no_lft"]:
        m = Measure(
            id=f"indicator_{indicator}_rate",
            numerator=f"indicator_{indicator}_numerator",
            denominator=f"indicator_me_denominator",
            group_by=["practice"],
        )

    else:
        m = Measure(
            id=f"indicator_{indicator}_rate",
            numerator=f"indicator_{indicator}_numerator",
            denominator=f"indicator_{indicator}_denominator",
            group_by=["practice"],
        )

    measures.append(m)

for measure in sentinel_measures:
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