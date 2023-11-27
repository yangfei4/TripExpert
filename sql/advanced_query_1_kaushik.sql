/*
Given the day, day of the week, time, and two locations (lat/long), find all 
the ways to get from one location to the other in one bus ride. Stops are 
selected in a 0.002-degree square centered at each location.
Paths are returned by their trip_id's and the two relevant stop_sequence's.

Values are currently hardcoded, but will be replaced with inputted variables
in the final app.
*/
SELECT
    st1.trip_id AS trip_id, 
    st1.stop_sequence AS departure_sequence, 
    st2.stop_sequence AS arrival_sequence
FROM StopTimes st1 
    JOIN StopTimes st2 USING(trip_id)
    JOIN Stops s1 ON (st1.stop_id = s1.stop_id)
    JOIN Stops s2 ON (st2.stop_id = s2.stop_id)
WHERE 
    trip_id IN (
        SELECT DISTINCT trip_id
        FROM Trips NATURAL JOIN Frequencies NATURAL JOIN Calendar
        WHERE start_time <= '10:30:00'
        AND '10:30:00' <= end_time
        AND Calendar.saturday = 1
        AND start_date <= '2022-01-01'
        AND '2022-01-01' <= end_date
    )
    AND s1.stop_lat < -23.446258 + 0.001 AND s1.stop_lat > -23.446258 - 0.001
    AND s1.stop_lon < -46.712298 + 0.001 AND s1.stop_lon > -46.712298 - 0.001
    AND s2.stop_lat < -23.447209 + 0.001 AND s2.stop_lat > -23.447209 - 0.001
    AND s2.stop_lon < -46.709039 + 0.001 AND s2.stop_lon > -46.709039 - 0.001
    AND st1.stop_sequence <= st2.stop_sequence
ORDER BY st2.stop_sequence - st1.stop_sequence ASC;

