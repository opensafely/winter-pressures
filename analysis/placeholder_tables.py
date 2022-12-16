import datetime

from databuilder.tables import EventFrame, Series, table


@table
class appointments(EventFrame):
    booked_date = Series(datetime.date)  # book_date ?
    start_date = Series(datetime.date)
