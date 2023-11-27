-- Deletes a Path if it is not Saved by anyone anymore
DELIMITER //
CREATE TRIGGER UnsavedPaths
AFTER DELETE ON Saved
FOR EACH ROW
BEGIN
    SET @numsavedby = (
        SELECT COUNT(*)
        FROM Saved s
        WHERE OLD.path_id = s.path_id
    );
    IF @numsavedby = 0 THEN
        DELETE FROM Paths p
        WHERE p.path_id = OLD.path_id;
    END IF;
END;
//
DELIMITER ;