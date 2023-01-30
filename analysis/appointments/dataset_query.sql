DECLARE @study_start_date DATE;
SET @study_start_date = DATEFROMPARTS(2021, 6, 1);

DECLARE @study_end_date DATE;
SET @study_end_date = DATEFROMPARTS(2022, 12, 31);

-- These queries are similar to Data Builder's tables. They provide a "view" onto the
-- database's tables, but with a different naming convention, slightly different names,
-- and slightly different data types.

WITH practice_registrations AS (
    SELECT
        Patient_ID AS patient_id,
        CAST(StartDate AS DATE) AS start_date,
        CAST(EndDate AS DATE) AS end_date
    FROM RegistrationHistory
),

appointments AS (
    SELECT DISTINCT
        -- At present, there are duplicate rows in the `Appointment` table. We remove
        -- them by including `Appointment_ID` in the select list.
        Appointment.Appointment_ID AS appointment_id,
        Appointment.Patient_ID AS patient_id,
        CAST(Appointment.BookedDate AS DATE) AS booked_date,
        CAST(Appointment.StartDate AS DATE) AS start_date,
        -- We differ from the dataset definition and extract `practice_pseudo_id` and
        -- `practice_nuts1_region_name` for each appointment.
        Organisation.Organisation_ID AS practice_pseudo_id,
        Organisation.Region AS practice_nuts1_region_name
    FROM Appointment
    INNER JOIN Organisation ON
        Appointment.Organisation_ID = Organisation.Organisation_ID
),

-- These queries are similar to Data Builder's reusable variables; that is, they are
-- transformations of the above queries.

practice_registration_in_study_period AS (
    SELECT DISTINCT patient_id
    FROM
        practice_registrations
    WHERE
        practice_registrations.start_date <= @study_end_date AND (
            practice_registrations.end_date >= @study_start_date
            OR practice_registrations.end_date IS NULL
        )
),

valid_appointments AS (
    SELECT
        patient_id,
        booked_date,
        start_date,
        practice_pseudo_id,
        practice_nuts1_region_name
    FROM appointments
    WHERE appointments.booked_date <= appointments.start_date
)


-- This query is similar to Data Builder's dataset definition.

SELECT
    patient_id,
    practice_pseudo_id AS practice,
    practice_nuts1_region_name AS region,
    DATEFROMPARTS(YEAR(booked_date), MONTH(booked_date), 1) AS booked_month,
    DATEDIFF(
        DAY,
        start_date,
        booked_date
    ) AS lead_time_in_days
FROM valid_appointments
WHERE
    patient_id IN (SELECT patient_id FROM practice_registration_in_study_period)
    AND valid_appointments.booked_date >= @study_start_date
    AND valid_appointments.booked_date <= @study_end_date
-- This ensures that vectors of `lead_time_in_days`, for which we want to compute
-- medians, are contiguous in the output.
ORDER BY booked_month, practice, region, lead_time_in_days
