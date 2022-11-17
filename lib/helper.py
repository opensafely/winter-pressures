
# Import functions
from cohortextractor import patients

def get_X_appointments(name, index_date, n, report=False):
    
    def appointment_variable_template(name, on_or_after):

        booked_date_variable_name = f"{name}_booked_date"
        start_date_variable_name = f"{name}_start_date"

        if report:
            print("======================================================")
            print(f"Creating '{booked_date_variable_name}' from {name}, on or after '{on_or_after}'")
            print(f"Creating '{start_date_variable_name}' from {name}, on or after '{on_or_after}'")

        return {
            booked_date_variable_name: patients.with_gp_consultations(
                    on_or_after=on_or_after,
                    find_first_match_in_period=True,
                    returning="date",
                    # date_type = "Booked",
                    date_format="YYYY-MM-DD"
                ),
            start_date_variable_name: patients.with_gp_consultations(
                    on_or_after=on_or_after,
                    find_first_match_in_period=True,
                    returning="date",
                    # date_type = "Start",
                    date_format="YYYY-MM-DD"
                )
            }
    
    variables = appointment_variable_template(f"{name}_1", index_date)

    if report:
        print("------------------------------------------------------")
        print(f"After round #1, the variables are:" ) 
        for key in variables.keys():
            print(f" - {key}")

    for i in range(2, n+1):

        variables.update(appointment_variable_template(
            name=f"{name}_{i}",
            on_or_after=f"{name}_{i-1}_booked_date + 1 day",
        ))

        if report:
            print("------------------------------------------------------")
            print(f"After round #{i}, the variables are:" ) 
            for key in variables.keys():
                print(f" - {key}")

    return variables

