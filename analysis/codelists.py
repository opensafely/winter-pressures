from cohortextractor import (
    codelist,
    codelist_from_csv,
    combine_codelists
)


asthma_codelist = codelist_from_csv("codelists/opensafely-asthma-annual-review-qof.csv",
                                 system="snomed",
                                 column="code",)

copd_codelist = codelist_from_csv("codelists/opensafely-chronic-obstructive-pulmonary-disease-copd-review-qof.csv",
                                 system="snomed",
                                 column="code",)

qrisk_codelist = codelist_from_csv("codelists/opensafely-cvd-risk-assessment-score-qof.csv",
                                 system="snomed",
                                 column="code",)

tsh_codelist = codelist_from_csv("codelists/opensafely-thyroid-stimulating-hormone-tsh-testing.csv",
                                 system="snomed",
                                 column="code",)

alt_codelist = codelist_from_csv("codelists/opensafely-alanine-aminotransferase-alt-tests.csv",
                                 system="snomed",
                                 column="code",)

cholesterol_codelist = codelist_from_csv("codelists/opensafely-cholesterol-tests.csv",
                                 system="snomed",
                                 column="code",)

hba1c_codelist = codelist_from_csv("codelists/opensafely-glycated-haemoglobin-hba1c-tests.csv",
                                 system="snomed",
                                 column="code",)

rbc_codelist = codelist_from_csv("codelists/opensafely-red-blood-cell-rbc-tests.csv",
                                 system="snomed",
                                 column="code",)

sodium_codelist = codelist_from_csv("codelists/opensafely-sodium-tests-numerical-value.csv",
                                 system="snomed",
                                 column="code",)

systolic_bp_codelist = codelist_from_csv("codelists/opensafely-systolic-blood-pressure-qof.csv",
                                 system="snomed",
                                 column="code",)



medication_review_1 = codelist_from_csv("codelists/opensafely-care-planning-medication-review-simple-reference-set-nhs-digital.csv",
    system="snomed",
    column="code",)

medication_review_2 = codelist_from_csv("codelists/nhsd-primary-care-domain-refsets-medrvw_cod.csv",
    system="snomed",
    column="code",)

medication_review_codelist = combine_codelists(
    medication_review_1, 
    medication_review_2
)

icd1 = codelist_from_csv("codelists/opensafely-icd-10-chapter-i.csv",
                         system="icd10",
                         column="code",)

icd2 = codelist_from_csv("codelists/opensafely-icd-10-chapter-ii.csv",
                         system="icd10",
                         column="code",)

icd3 = codelist_from_csv("codelists/opensafely-icd-10-chapter-iii.csv",
                         system="icd10",
                         column="code",)
icd4 = codelist_from_csv("codelists/opensafely-icd-10-chapter-iv.csv",
                         system="icd10",
                         column="code",)

icd5 = codelist_from_csv("codelists/opensafely-icd-10-chapter-v.csv",
                         system="icd10",
                         column="code",)

icd6 = codelist_from_csv("codelists/opensafely-icd-10-chapter-vi.csv",
                         system="icd10",
                         column="code",)
icd7 = codelist_from_csv("codelists/opensafely-icd-10-chapter-vii.csv",
                         system="icd10",
                         column="code",)

icd8 = codelist_from_csv("codelists/opensafely-icd-10-chapter-viii.csv",
                         system="icd10",
                         column="code",)

icd9 = codelist_from_csv("codelists/opensafely-icd-10-chapter-ix.csv",
                         system="icd10",
                         column="code",)
icd10 = codelist_from_csv("codelists/opensafely-icd-10-chapter-x.csv",
                         system="icd10",
                         column="code",)

icd11 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xi.csv",
                         system="icd10",
                         column="code",)

icd12 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xii.csv",
                         system="icd10",
                         column="code",)
icd13 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xiii.csv",
                         system="icd10",
                         column="code",)

icd14 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xiv.csv",
                         system="icd10",
                         column="code",)

icd15 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xv.csv",
                         system="icd10",
                         column="code",)

icd16 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xvi.csv",
                         system="icd10",
                         column="code",)

icd17 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xvii.csv",
                         system="icd10",
                         column="code",)

icd18 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xviii.csv",
                         system="icd10",
                         column="code",)

icd19 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xix.csv",
                         system="icd10",
                         column="code",)

icd20 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xx.csv",
                         system="icd10",
                         column="code",)

icd21 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xxi.csv",
                         system="icd10",
                         column="code",)

icd22 = codelist_from_csv("codelists/opensafely-icd-10-chapter-xxii.csv",
                         system="icd10",
                         column="code",)
###

