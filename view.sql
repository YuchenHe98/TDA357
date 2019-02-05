CREATE VIEW BasicInformation (idnr, name, login, program, branch) AS
SELECT idnr, name, login, Students.program, StudentBranches.branch
FROM Students 
LEFT JOIN StudentBranches ON idnr = student;


CREATE VIEW FinishedCourses (student, course, grade, credits) AS
SELECT student, course, grade, credit FROM Taken, Courses 
WHERE Taken.course = Courses.code;


CREATE VIEW PassedCourses(student, course, credits) AS
SELECT student, course, credits FROM Taken, Courses 
WHERE Taken.course = Courses.code
AND grade != 'U'

CREATE VIEW Registrations(student, course, status) AS
SELECT student, course, 'registered' AS status FROM Registered
UNION
SELECT student, course, 'waiting' AS status FROM WaitingList
	
/*
View: BasicInformation(idnr, name, login, program, branch) For all students, their national identification number, name, login, their program and the branch (if any). The branch column is the only column in any of the views that is allowed to contain NULL.
*/
