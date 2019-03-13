DROP TRIGGER put_into_waiting ON registrations;
DROP TRIGGER update_waiting ON registrations;
DROP FUNCTION manage_registered;
DROP FUNCTION manage_waiting_list;
DROP FUNCTION isFull;



/* Given a course code, check whether it's full. */   
CREATE FUNCTION isFull(TEXT)
    RETURNS INT AS $signal$
	
BEGIN
	RETURN CASE WHEN
	EXISTS (SELECT seats FROM LimitedCourses WHERE code = $1) AND
        (SELECT count(*) FROM Registered WHERE course = $1) 
	>= (SELECT seats FROM LimitedCourses WHERE code = $1)
	THEN 1
	ELSE 0
	END;	
END;

$signal$ LANGUAGE plpgsql;

/* Handle newly added member. */   
CREATE FUNCTION manage_registered()
    RETURNS TRIGGER AS $work$
	
BEGIN

/* Check whether such a person is in registered or waitinglist. */
    IF NOT EXISTS (SELECT * FROM WaitingList WHERE student = NEW.student AND course = NEW.course) AND NOT EXISTS (SELECT * FROM Registered WHERE student = NEW.student AND course = NEW.course) THEN
        IF isFull(NEW.course) = 1 THEN
	    INSERT INTO WaitingList (student, course, position) VALUES(NEW.student, NEW.course, (SELECT count(*) FROM WaitingList WHERE course = NEW.course) + 1);
	ELSE
	    INSERT INTO Registered (student, course) VALUES (NEW.student, NEW.course);
	END IF;

    ELSE
	RAISE EXCEPTION 'The student is either registered or on the waiting list. It is not possible to try to register twice!';
    END IF;

    RETURN NEW;
END;

$work$ LANGUAGE plpgsql;

CREATE TRIGGER put_into_waiting
    INSTEAD OF INSERT ON registrations
    FOR EACH ROW
    EXECUTE PROCEDURE manage_registered();

CREATE FUNCTION manage_waiting_list()
    RETURNS TRIGGER AS $work$
	
BEGIN

    IF NOT EXISTS (SELECT * FROM registered WHERE student = OLD.student AND course = OLD.course) THEN
    	RAISE EXCEPTION 'The student is never registered. Cannot remove.';
    END IF;

    DELETE FROM registered WHERE student = OLD.student AND course = OLD.course;

    IF isFull(OLD.course) = 0 AND EXISTS (SELECT count(*) FROM WaitingList WHERE WaitingList.course = OLD.course) THEN
	INSERT INTO registered (student, course) SELECT student, course FROM WaitingList WHERE course = OLD.course AND position = 1;
        DELETE FROM WaitingList WHERE course = OLD.course AND position = 1;
	UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course;

    END IF;

    RETURN NEW;
END;

$work$ LANGUAGE plpgsql;

CREATE TRIGGER update_waiting
    INSTEAD OF DELETE ON registrations
    FOR EACH ROW
    EXECUTE PROCEDURE manage_waiting_list();




