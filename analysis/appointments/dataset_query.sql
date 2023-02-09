DECLARE @study_start_date DATE;
SET @study_start_date = DATEFROMPARTS(2018, 6, 1);

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
        Appointment.Organisation_ID AS practice_pseudo_id
    FROM Appointment
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
        practice_pseudo_id
    FROM appointments
    WHERE appointments.booked_date <= appointments.start_date
)


-- This query is similar to Data Builder's dataset definition.

SELECT
    patient_id,
    practice_pseudo_id AS practice,
    DATEFROMPARTS(YEAR(booked_date), MONTH(booked_date), 1) AS booked_month,
    DATEFROMPARTS(YEAR(start_date), MONTH(start_date), 1) AS start_month,
    DATEDIFF(
        DAY,
        booked_date,
        start_date
    ) AS lead_time_in_days
FROM valid_appointments
WHERE
    patient_id IN (SELECT patient_id FROM practice_registration_in_study_period)
    AND valid_appointments.booked_date >= @study_start_date
    AND valid_appointments.booked_date <= @study_end_date
    AND valid_appointments.start_date >= @study_start_date
    AND valid_appointments.start_date <= @study_end_date
-- This ensures that vectors of `lead_time_in_days`, for which we want to compute
-- medians, are contiguous in the output.
ORDER BY booked_month, start_month, practice, lead_time_in_days
