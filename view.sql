CREATE VIEW BasicInformation (idnr, name, login, program, branch) AS
SELECT idnr, name, login, Students.program, StudentBranches.branch
FROM Students 
LEFT JOIN StudentBranches ON idnr = student;

CREATE VIEW FinishedCourses (student, course, grade, credits) AS
SELECT student, course, grade, credits FROM Taken, Courses 
WHERE Taken.course = Courses.code;

CREATE VIEW PassedCourses(student, course, credits) AS
SELECT student, course, credits FROM Taken, Courses 
WHERE Taken.course = Courses.code
AND grade != 'U';

CREATE VIEW Registrations(student, course, status) AS
SELECT student, course, 'registered' AS status FROM Registered
UNION
SELECT student, course, 'waiting' AS status FROM WaitingList;

CREATE VIEW UnreadMandatory(student, course) AS
SELECT * FROM
(   
    SELECT student, MandatoryBranch.course
    FROM StudentBranches, MandatoryBranch
    WHERE (StudentBranches.branch, StudentBranches.program) = (MandatoryBranch.branch, MandatoryBranch.program)
    union
    SELECT idnr, MandatoryProgram.course FROM Students, MandatoryProgram
    WHERE Students.program = MandatoryProgram.program
)
WHERE (student, course) NOT IN 
(
    SELECT student, course FROM PassedCourses
);


/* graduation path */
CREATE VIEW PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified) AS
SELECT idnr AS student, coalesce (totalcredits, 0) as totalcredits,  coalesce (mandatoryleft, 0) as mandatoryleft, coalesce (mathcredits, 0) as mathcredits, coalesce (researchcredits, 0) as researchcredits, coalesce (seminarcourses, 0) as seminarcourses,
CASE 
WHEN mandatoryleft > 0 THEN "f"
WHEN idnr IN (SELECT student FROM StudentBranches) THEN "t"
ELSE "f"

END AS qualified FROM Students

LEFT JOIN 
(
    SELECT student, SUM(credits) AS totalcredits FROM PassedCourses GROUP BY student 
) AS totalCreditSub
ON
Students.idnr = totalCreditSub.student 

LEFT JOIN 
(
    SELECT student, COUNT (student) AS mandatoryleft FROM UnreadMandatory GROUP BY student
) AS mandatorySub
ON 
Students.idnr = mandatorySub.student 

LEFT JOIN
(
SELECT student, SUM(credits) AS mathcredits FROM PassedCourses, Classified 
WHERE PassedCourses.course = Classified.course AND Classified.classification = "math" GROUP BY student
) AS mathSub

ON idnr = mathSub.student

LEFT JOIN
(
SELECT student, SUM(credits) AS researchcredits FROM PassedCourses, Classified 
WHERE PassedCourses.course = Classified.course AND Classified.classification = "research" GROUP BY student
) AS researchSub

ON idnr = researchSub.student

LEFT JOIN
(
SELECT student, COUNT(credits) AS seminarcourses FROM PassedCourses, Classified 
WHERE PassedCourses.course = Classified.course AND Classified.classification = "seminar" GROUP BY student
) AS seminarSub

ON idnr = seminarSub.student
