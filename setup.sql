CREATE TABLE Programs (
    name TEXT PRIMARY KEY,
    abbreviation TEXT NOT NULL,
    UNIQUE(abbreviation)
);

CREATE TABLE Departments (
    name TEXT PRIMARY KEY,
    abbreviation TEXT NOT NULL,
    UNIQUE(abbreviation)
);

CREATE TABLE Hosts (
    department TEXT NOT NULL REFERENCES Departments(name),
    program TEXT NOT NULL REFERENCES Programs(name)
);

CREATE TABLE Students (
    idnr NUMERIC(10, 0) PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL,
	program TEXT NOT NULL REFERENCES Programs(name),
    UNIQUE(idnr, program)
);

CREATE TABLE Employees (
    idnr NUMERIC(10, 0) PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL,
	department TEXT NOT NULL REFERENCES Departments(name)
);

CREATE TABLE Branches (
    name TEXT,
	program TEXT,
    CONSTRAINT branch_key PRIMARY KEY (name, program)
);

CREATE TABLE Courses (
    code TEXT PRIMARY KEY,
	name TEXT NOT NULL,
	credits NUMERIC(10, 1) NOT NULL,
	department TEXT NOT NULL REFERENCES Departments(name)
);

CREATE TABLE LimitedCourses (
    code TEXT primary KEY,
	seats int NOT NULL,
    FOREIGN KEY (code) REFERENCES Courses(code)
);


CREATE TABLE Classifications (
    name TEXT primary KEY
);

CREATE TABLE StudentBranches (
    student NUMERIC(10, 0) PRIMARY KEY,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
	FOREIGN KEY (student, program) REFERENCES Students(idnr, program)
);

CREATE TABLE Classified (
    course TEXT NOT NULL,
	classification TEXT NOT NULL,
    CONSTRAINT classified_key PRIMARY KEY(course, classification),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (classification) REFERENCES Classifications(name)
);

CREATE TABLE MandatoryProgram(
    course TEXT,
	program TEXT,
    CONSTRAINT mandatory_program_key PRIMARY KEY(course, program),
	FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE MandatoryBranch(
    course TEXT,
	branch TEXT,
	program TEXT,
    CONSTRAINT mandatory_branch_key PRIMARY KEY(course, branch, program),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE RecommendedBranch(
    course TEXT,
	branch TEXT,
	program TEXT,
    CONSTRAINT recommended_branch_key PRIMARY KEY(course, branch, program),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Registered(
    student NUMERIC(10, 0),
	course TEXT NOT NULL,
    CONSTRAINT registered_key PRIMARY KEY(course, student),
	FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (student) REFERENCES Students(idnr)
);

CREATE TABLE Taken(
    student NUMERIC(10, 0),
	course TEXT NOT NULL,
	grade char(1) NOT NULL,
    CONSTRAINT taken_key PRIMARY KEY(course, student),
	FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    CONSTRAINT taken_grade_check CHECK (grade IN ('3', '4', '5', 'U'))
);

CREATE TABLE WaitingList(
    student NUMERIC(10, 0),
	course TEXT NOT NULL,
	position INT NOT NULL,
    CONSTRAINT waiting_list_key PRIMARY KEY(course, student),
	FOREIGN KEY (course) REFERENCES LimitedCourses(code),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    CONSTRAINT course_position UNIQUE(course, position)
);



/*
Insertions
*/

INSERT INTO Programs VALUES ('Prog1', 'P1');
INSERT INTO Programs VALUES ('Prog2', 'P2');

INSERT INTO Departments VALUES ('Dep1', 'D1');

INSERT INTO Hosts VALUES ('Dep1', 'Prog1');
INSERT INTO Hosts VALUES ('Dep1', 'Prog2');

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Students VALUES (1111111111,'S1','ls1','Prog1');
INSERT INTO Students VALUES (2222222222,'S2','ls2','Prog1');
INSERT INTO Students VALUES (3333333333,'S3','ls3','Prog2');
INSERT INTO Students VALUES (4444444444,'S4','ls4','Prog1');

INSERT INTO Courses VALUES ('CCC111','C1',10,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',40,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');

INSERT INTO StudentBranches VALUES (2222222222,'B1','Prog1');
INSERT INTO StudentBranches VALUES (3333333333,'B1','Prog2');
INSERT INTO StudentBranches VALUES (4444444444,'B1','Prog1');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC555', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');

INSERT INTO Registered VALUES (1111111111,'CCC111');
INSERT INTO Registered VALUES (1111111111,'CCC222');
INSERT INTO Registered VALUES (1111111111,'CCC333');

INSERT INTO Registered VALUES (2222222222,'CCC222');

INSERT INTO Taken VALUES(4444444444,'CCC111','5');
INSERT INTO Taken VALUES(4444444444,'CCC222','5');
INSERT INTO Taken VALUES(4444444444,'CCC333','5');
INSERT INTO Taken VALUES(4444444444,'CCC444','5');

INSERT INTO Taken VALUES(1111111111,'CCC111','3');
INSERT INTO Taken VALUES(1111111111,'CCC222','3');
INSERT INTO Taken VALUES(1111111111,'CCC333','3');
INSERT INTO Taken VALUES(1111111111,'CCC444','3');

INSERT INTO Taken VALUES(2222222222,'CCC111','U');
INSERT INTO Taken VALUES(2222222222,'CCC222','U');
INSERT INTO Taken VALUES(2222222222,'CCC444','U');

INSERT INTO WaitingList VALUES(3333333333,'CCC222',1);
INSERT INTO WaitingList VALUES(3333333333,'CCC333',1);
INSERT INTO WaitingList VALUES(2222222222,'CCC333',2);

/* 
Views 
*/

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
) AS mustReadedCourses
WHERE (student, course) NOT IN 
(
    SELECT student, course FROM PassedCourses
);


/* graduation path */
CREATE VIEW PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified) AS
SELECT idnr AS student, coalesce (totalcredits, 0) as totalcredits,  coalesce (mandatoryleft, 0) as mandatoryleft, coalesce (mathcredits, 0) as mathcredits, coalesce (researchcredits, 0) as researchcredits, coalesce (seminarcourses, 0) as seminarcourses,
CASE 
WHEN mandatoryleft > 0 THEN FALSE
WHEN idnr IN (SELECT student FROM StudentBranches) THEN TRUE
ELSE FALSE

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
WHERE PassedCourses.course = Classified.course AND Classified.classification = 'math' GROUP BY student
) AS mathSub

ON idnr = mathSub.student

LEFT JOIN
(
SELECT student, SUM(credits) AS researchcredits FROM PassedCourses, Classified 
WHERE PassedCourses.course = Classified.course AND Classified.classification = 'research' GROUP BY student
) AS researchSub

ON idnr = researchSub.student

LEFT JOIN
(
SELECT student, COUNT(credits) AS seminarcourses FROM PassedCourses, Classified 
WHERE PassedCourses.course = Classified.course AND Classified.classification = 'seminar' GROUP BY student
) AS seminarSub

ON idnr = seminarSub.student;

CREATE VIEW CourseQueuePositions (course, student, place) AS
SELECT course, student, position FROM WaitingList;

