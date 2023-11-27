DELIMITER //
CREATE PROCEDURE AddToMyTrip(
    IN p_trip_id VARCHAR(255),
    IN p_departure_sequence INT,
    IN p_arrival_sequence INT,
    IN p_departure_time TIME,
    IN p_arrival_time TIME,
    IN p_user_id VARCHAR(255)
)
BEGIN
    DECLARE path_id_tmp VARCHAR(255);
	DECLARE p_color CHAR(6);

	-- Search for path color
    SELECT route_color INTO p_color
    FROM Routes r NATURAL JOIN Trips t
    WHERE t.trip_id = p_trip_id;

    -- Check if the path already exists in the Paths table
    SELECT path_id INTO path_id_tmp
    FROM Paths
    WHERE trip_id = p_trip_id
    AND departure_sequence = p_departure_sequence
    AND arrival_sequence = p_arrival_sequence
    AND departure_time = p_departure_time
    AND arrival_time = p_arrival_time;

    IF path_id_tmp IS NOT NULL THEN
        -- Path already exists, insert into Saved table
        INSERT INTO Saved (color, user_id, path_id)
        VALUES (p_color, p_user_id, path_id_tmp)
        ON DUPLICATE KEY UPDATE color = p_color;
    ELSE
        -- Path does not exist, create a new path and insert into Paths table
        SET path_id_tmp = CONCAT(p_trip_id, '_', CAST(p_departure_sequence AS CHAR), '_', CAST(p_arrival_sequence AS CHAR));

        INSERT INTO Paths (path_id, trip_id, departure_sequence, arrival_sequence, departure_time, arrival_time)
        VALUES (path_id_tmp, p_trip_id, p_departure_sequence, p_arrival_sequence, p_departure_time, p_arrival_time);

        -- Insert into Saved table
        INSERT INTO Saved (color, user_id, path_id)
        VALUES (p_color, p_user_id, path_id_tmp);
    END IF;

    CALL UpdatePopularity();
END;
//
DELIMITER ;