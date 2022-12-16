import datetime

from databuilder import ehrql
from databuilder.tables.beta.tpp import practice_registrations
from placeholder_tables import appointments

index_date = datetime.date(2020, 1, 1)

# If a patient is registered at more than one practice on the index date, then return
# the registration with the most recent start date. If there are more than one
# registrations with the most recent start date, then return the registration with the
# longest duration.
practice_registration_on_index_date = (
    practice_registrations.take(
        practice_registrations.start_date.is_on_or_before(index_date)
    )
    .take(
        practice_registrations.end_date.is_on_or_after(index_date)
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
dataset.set_population(practice_registration_on_index_date.exists_for_patient())

# Administrative data
# -------------------
#
# These data are extracted on the index date. However, the appointments data are
# extracted on or after, and potentially a long time after, the index date.
# Consequently, we may incorrectly attribute lead times to practices/regions.

dataset.practice = practice_registration_on_index_date.practice_pseudo_id

dataset.region = practice_registration_on_index_date.practice_nuts1_region_name

# Appointments data
# -----------------

# The first appointment should have a booked date that is on or after the index date.
apt = appointments.take(appointments.booked_date.is_on_or_after(index_date))

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
    # the previous appointment.
    apt = appointments.take(appointments.booked_date.is_after(apt.booked_date))
