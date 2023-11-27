DELIMITER //
CREATE PROCEDURE UpdatePopularity()
BEGIN
    
    DECLARE var_path_id VARCHAR(255);
    DECLARE var_user_count INT;
    DECLARE var_popularity VARCHAR(255);

    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE cur CURSOR FOR (
        SELECT path_id, COUNT(user_id) as user_count
        FROM Saved
        GROUP BY path_id
    );
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    cloop: LOOP
        FETCH cur INTO var_path_id, var_user_count;
        IF done THEN
            LEAVE cloop;
        END IF;

        IF var_user_count >= 10 THEN
            SET var_popularity = 'Very Popular';
        ELSEIF var_user_count >= 5 THEN
            SET var_popularity = 'Popular';
        ELSEIF var_user_count >= 2 THEN
            SET var_popularity = 'Not Popular';
        ELSE
            SET var_popularity = 'Personal Favorite';
        END IF;

        UPDATE Paths
        SET popularity = var_popularity
        WHERE path_id = var_path_id;
    END LOOP cloop;
    CLOSE cur;

END;
//
DELIMITER ;