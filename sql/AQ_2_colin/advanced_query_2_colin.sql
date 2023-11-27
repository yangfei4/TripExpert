-- Functionality: return the saved paths for a given user subject to a filter that the user can apply
-- which shows only the paths which are available on certain days.
-- This query returns the necessary data for our "My Trips" page of our application, but just with an 
-- added bonus of complying with the aforementioned "days" filter.

-- BACKEND (NodeJS) VARIABLES
    -- * the_user_id * ==  the id of the user currently using the application.
    -- * days * == the id of the user currently using the application. This is a 7-digit numeric binary array,
    -- of 0's and 1's, where a 1 represents "true" - that a trip MUST be on this day - and where a 0
    -- represents "false" -- where it doesn't matter if a trip is on this day.


SELECT s.color, p.departure_stop, p.arrival_stop, p.departure_time, p.arrival_time
FROM Paths p NATURAL JOIN Saved s
WHERE s.user_id = the_user_id AND p.path_id IN (
    SELECT p1.path_id 
    FROM Paths p1 NATURAL JOIN Trips t1 NATURAL JOIN Calendar c1
    WHERE (
        (days[0] = 0 OR c1.Monday = 1) AND
        (days[1] = 0 OR c1.Tuesday = 1) AND
        (days[2] = 0 OR c1.Wednesday = 1) AND
        (days[3] = 0 OR c1.Thursday = 1) AND
        (days[4] = 0 OR c1.Friday = 1) AND
        (days[5] = 0 OR c1.Saturday = 1) AND
        (days[6] = 0 OR c1.Sunday = 1)
    )
)
;

-- USING DUMMY VALUES:
    -- the_user_id = 1
    -- days = (0,1,1,0,0,1,0)

-- day-checking part becomes:
    -- (0 = 0 OR c1.Monday = 1) AND
    -- (1 = 0 OR c1.Tuesday = 1) AND
    -- (1 = 0 OR c1.Wednesday = 1) AND
    -- (0 = 0 OR c1.Thursday = 1) AND
    -- (0 = 0 OR c1.Friday = 1) AND
    -- (1 = 0 OR c1.Saturday = 1) AND
    -- (0 = 0 OR c1.Sunday = 1)
-- so I simplify it in the query below

SELECT s.color, p.departure_sequence, p.arrival_sequence, p.departure_time, p.arrival_time
FROM Paths p NATURAL JOIN Saved s
WHERE s.user_id = '1' AND p.path_id IN (
    SELECT p1.path_id 
    FROM Paths p1 NATURAL JOIN Trips t1 NATURAL JOIN Calendar c1
    WHERE (
        (c1.Tuesday = 1) AND
        (c1.Wednesday = 1) AND
        (c1.Saturday = 1)
    )
)
LIMIT 15
;

-- This is the query that'll be run in the demo.
-- Note: we will actually have to write more SQL code for the actual applicaiton to work properly (
    -- currently this only returns departure sequence numbers and trip_id's, not the actual stop
    -- latitudes, longitudes, and names, which are what we would actually need for this 
    -- functionality to work properly in "My Trips", but for now this part of the query works as
    -- A.Q. 2.)
