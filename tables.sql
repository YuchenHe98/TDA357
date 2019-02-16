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
	program TEXT NOT NULL REFERENCES Programs(name)
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
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
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
	position TEXT NOT NULL,
    /* position timestamp NOT NULL, */
    CONSTRAINT waiting_list_key PRIMARY KEY(course, student),
	FOREIGN KEY (course) REFERENCES LimitedCourses(code),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    CONSTRAINT course_position UNIQUE(course, position)
);
