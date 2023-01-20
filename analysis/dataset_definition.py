import datetime

from databuilder import ehrql
from databuilder.tables.beta.tpp import appointments, practice_registrations

start_date = datetime.date(2019, 7, 1)
end_date = datetime.date(2020, 6, 30)

# If a patient is registered at more than one practice in the study period, then return
# the registration with the most recent start date. If there are more than one
# registrations with the most recent start date, then return the registration with the
# longest duration.
practice_registration_in_study_period = (
    practice_registrations.take(
        practice_registrations.start_date.is_on_or_before(end_date)
    )
    .take(
        practice_registrations.end_date.is_on_or_after(start_date)
        | practice_registrations.end_date.is_null()
    )
    .sort_by(practice_registrations.start_date, practice_registrations.end_date)
    .last_for_patient()
)

dataset = ehrql.Dataset()

# In the cohort-extractor version of the study, the study definition was executed once a
# month for a period of 12 months, so changes to the population (e.g. patients entering
# the system; patients leaving the system) were captured. Here, the dataset definition
# is executed once, so changes to the population are not captured.
dataset.set_population(practice_registration_in_study_period.exists_for_patient())

# Administrative data
# -------------------
# These data are extracted for one practice. If a patient is registered at more than one
# practice in the study period, then the appointments data *may* be incorrectly
# attributed to the practice.

dataset.practice = practice_registration_in_study_period.practice_pseudo_id

dataset.region = practice_registration_in_study_period.practice_nuts1_region_name

# Appointments data
# -----------------

# The first appointment should have a booked date in the study period.
apt = appointments.take(appointments.booked_date.is_on_or_after(start_date)).take(
    appointments.booked_date.is_on_or_before(end_date)
)

num_appointments = 10
for i in range(1, num_appointments + 1):
    # The first/next appointment should be first, when appointments are sorted by booked
    # date. If more than one appointment was booked on the same date, then return the
    # appointment with the shortest lead time.
    apt = apt.sort_by(apt.booked_date, apt.start_date).first_for_patient()

    lead_time_in_days = (apt.start_date - apt.booked_date).days

    setattr(dataset, f"booked_date_{i}", apt.booked_date)
    setattr(dataset, f"lead_time_in_days_{i}", lead_time_in_days)

    # The next appointment should have a booked date that is after the booked date of
    # the previous appointment, and in the study period.
    apt = appointments.take(appointments.booked_date.is_after(apt.booked_date)).take(
        appointments.booked_date.is_on_or_before(end_date)
    )
