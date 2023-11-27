SELECT
  st1.trip_id AS trip_id,
  st1.stop_sequence AS departure_sequence,
  st2.stop_sequence AS arrival_sequence,
  st1.departure_time AS departure_time,
  st2.departure_time AS arrival_time
FROM StopTimes st1
  JOIN StopTimes st2 USING(trip_id)
  JOIN Stops s1 ON (st1.stop_id = s1.stop_id)
  JOIN Stops s2 ON (st2.stop_id = s2.stop_id)
WHERE
  s1.stop_name = ? AND s2.stop_name = ?
  AND (TIME_TO_SEC(st1.departure_time)-TIME_TO_SEC(?))>=0 
  AND (TIME_TO_SEC(st1.departure_time)-TIME_TO_SEC(?))<=3600
  AND st1.stop_sequence < st2.stop_sequence
ORDER BY (arrival_time - departure_time) ASC;