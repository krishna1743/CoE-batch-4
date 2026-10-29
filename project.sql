-- =====================================================================
--  Student Performance Analytics System  -  PART A (MySQL 8.0.16+)
--  File   : project.sql
--  Run    : mysql -u root -p < project.sql     (or open in MySQL Workbench and run all)
--  Note   : CHECK constraints are enforced only from MySQL 8.0.16 onwards.
-- =====================================================================

DROP DATABASE IF EXISTS student_analytics;
CREATE DATABASE student_analytics;
USE student_analytics;

-- =====================================================================
--  DAY 1 : TABLE DESIGN
-- =====================================================================

-- 1) departments : one row per department
CREATE TABLE departments (
    dept_id    INT           PRIMARY KEY AUTO_INCREMENT,            -- PRIMARY KEY
    dept_name  VARCHAR(60)   NOT NULL UNIQUE,                       -- NOT NULL + UNIQUE
    hod_name   VARCHAR(60)   NOT NULL DEFAULT 'To be appointed'     -- DEFAULT
);

-- 2) subjects : one row per subject
CREATE TABLE subjects (
    subject_id    INT          PRIMARY KEY AUTO_INCREMENT,
    subject_code  VARCHAR(10)  NOT NULL UNIQUE,
    subject_name  VARCHAR(80)  NOT NULL,
    credits       INT          NOT NULL DEFAULT 3,
    CONSTRAINT chk_subject_credits CHECK (credits BETWEEN 1 AND 6)
);

-- 3) students : one row per student, linked to a department
CREATE TABLE students (
    student_id      INT          PRIMARY KEY AUTO_INCREMENT,
    roll_no         VARCHAR(15)  NOT NULL UNIQUE,
    name            VARCHAR(80)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,                    -- rule: e-mail must be unique
    dept_id         INT          NOT NULL,
    semester        INT          NOT NULL DEFAULT 1,
    admission_year  INT          NOT NULL DEFAULT 2024,
    CONSTRAINT chk_semester CHECK (semester BETWEEN 1 AND 8),        -- rule: semester 1..8
    CONSTRAINT fk_student_dept FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)                              -- FOREIGN KEY
);

-- 4) marks : one row per (student, subject)
CREATE TABLE marks (
    mark_id     INT           PRIMARY KEY AUTO_INCREMENT,
    student_id  INT           NOT NULL,
    subject_id  INT           NOT NULL,
    marks       DECIMAL(5,2)  NOT NULL,
    CONSTRAINT chk_marks_range CHECK (marks BETWEEN 0 AND 100),      -- rule: marks 0..100
    CONSTRAINT uq_student_subject UNIQUE (student_id, subject_id),   -- rule: one entry per subject
    CONSTRAINT fk_marks_student FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_marks_subject FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

/* ---------------------------------------------------------------------
   NORMALIZATION (why the design is in 1NF, 2NF and 3NF)
   1NF : Every column holds a single atomic value (no lists such as "Maths,Physics"),
         every row is unique because each table has a primary key.
   2NF : All tables have a single-column primary key, except marks, whose key is
         (student_id, subject_id). The only non-key column of marks is "marks", which
         depends on BOTH parts of the key; student and subject details are stored in
         their own tables, so there is no partial dependency.
   3NF : No non-key column depends on another non-key column. Department name and HOD
         live only in departments (students stores just dept_id); subject name and
         credits live only in subjects. So there is no transitive dependency
         (student_id -> dept_id -> dept_name is split across two tables).
   Result: each fact is stored once, so there are no update, insert or delete anomalies.
   --------------------------------------------------------------------- */

-- =====================================================================
--  DAY 2 : DATA
--  (4 departments + 1 empty department, 6 subjects, 30 students, 180 marks)
-- =====================================================================

INSERT INTO departments (dept_id, dept_name, hod_name) VALUES
  (1, 'Computer Science', 'Dr. A. Kulkarni'),
  (2, 'Electronics', 'Dr. S. Deshmukh'),
  (3, 'Mechanical', 'Dr. R. Patil'),
  (4, 'Civil', 'Dr. M. Joshi'),
  (5, 'Biotechnology', 'Dr. N. Iyer');

INSERT INTO subjects (subject_id, subject_code, subject_name, credits) VALUES
  (1, 'MA101', 'Mathematics', 4),
  (2, 'PH102', 'Physics', 4),
  (3, 'CS103', 'Python Programming', 3),
  (4, 'CS104', 'Database Management', 3),
  (5, 'CS105', 'Data Structures', 4),
  (6, 'HU106', 'English Communication', 2);

INSERT INTO students (student_id, roll_no, name, email, dept_id, semester, admission_year) VALUES
  (1, 'B241001', 'Aarav Sharma', 'aarav.sharma1@college.edu', 1, 3, 2024),
  (2, 'B242002', 'Vivaan Patil', 'vivaan.patil2@college.edu', 2, 3, 2024),
  (3, 'B243003', 'Aditya Kulkarni', 'aditya.kulkarni3@college.edu', 3, 4, 2024),
  (4, 'B244004', 'Sai Deshmukh', 'sai.deshmukh4@college.edu', 4, 4, 2024),
  (5, 'B241005', 'Arjun Joshi', 'arjun.joshi5@college.edu', 1, 3, 2024),
  (6, 'B242006', 'Riya Gupta', 'riya.gupta6@college.edu', 2, 3, 2024),
  (7, 'B243007', 'Ananya Iyer', 'ananya.iyer7@college.edu', 3, 4, 2024),
  (8, 'B244008', 'Diya Nair', 'diya.nair8@college.edu', 4, 4, 2024),
  (9, 'B241009', 'Isha Verma', 'isha.verma9@college.edu', 1, 4, 2024),
  (10, 'B242010', 'Kavya Reddy', 'kavya.reddy10@college.edu', 2, 4, 2024),
  (11, 'B243011', 'Rohan Mehta', 'rohan.mehta11@college.edu', 3, 4, 2024),
  (12, 'B244012', 'Karan Singh', 'karan.singh12@college.edu', 4, 4, 2024),
  (13, 'B241013', 'Neha Pawar', 'neha.pawar13@college.edu', 1, 4, 2024),
  (14, 'B242014', 'Pooja Jadhav', 'pooja.jadhav14@college.edu', 2, 4, 2024),
  (15, 'B243015', 'Sneha Kale', 'sneha.kale15@college.edu', 3, 4, 2024),
  (16, 'B244016', 'Omkar Bhosale', 'omkar.bhosale16@college.edu', 4, 3, 2024),
  (17, 'B241017', 'Prathamesh More', 'prathamesh.more17@college.edu', 1, 3, 2024),
  (18, 'B242018', 'Shreya Shinde', 'shreya.shinde18@college.edu', 2, 4, 2024),
  (19, 'B243019', 'Tanmay Chavan', 'tanmay.chavan19@college.edu', 3, 3, 2024),
  (20, 'B244020', 'Vedant Gaikwad', 'vedant.gaikwad20@college.edu', 4, 3, 2024),
  (21, 'B241021', 'Aishwarya Salunkhe', 'aishwarya.salunkhe21@college.edu', 1, 3, 2024),
  (22, 'B242022', 'Harsh Thakur', 'harsh.thakur22@college.edu', 2, 3, 2024),
  (23, 'B243023', 'Mihir Bansal', 'mihir.bansal23@college.edu', 3, 4, 2024),
  (24, 'B244024', 'Sakshi Rane', 'sakshi.rane24@college.edu', 4, 3, 2024),
  (25, 'B241025', 'Yash Agarwal', 'yash.agarwal25@college.edu', 1, 4, 2024),
  (26, 'B242026', 'Tanvi Kadam', 'tanvi.kadam26@college.edu', 2, 3, 2024),
  (27, 'B243027', 'Manas Bhatt', 'manas.bhatt27@college.edu', 3, 3, 2024),
  (28, 'B244028', 'Nidhi Saxena', 'nidhi.saxena28@college.edu', 4, 4, 2024),
  (29, 'B241029', 'Rahul Yadav', 'rahul.yadav29@college.edu', 1, 3, 2024),
  (30, 'B242030', 'Siddhi Naik', 'siddhi.naik30@college.edu', 2, 3, 2024);

INSERT INTO marks (mark_id, student_id, subject_id, marks) VALUES
  (1, 1, 1, 91),
  (2, 1, 2, 98),
  (3, 1, 3, 52),
  (4, 1, 4, 89),
  (5, 1, 5, 93),
  (6, 1, 6, 86),
  (7, 2, 1, 75),
  (8, 2, 2, 90),
  (9, 2, 3, 90),
  (10, 2, 4, 66),
  (11, 2, 5, 76),
  (12, 2, 6, 77),
  (13, 3, 1, 51),
  (14, 3, 2, 51),
  (15, 3, 3, 66),
  (16, 3, 4, 50),
  (17, 3, 5, 54),
  (18, 3, 6, 71),
  (19, 4, 1, 74),
  (20, 4, 2, 59),
  (21, 4, 3, 50),
  (22, 4, 4, 76),
  (23, 4, 5, 74),
  (24, 4, 6, 86),
  (25, 5, 1, 72),
  (26, 5, 2, 75),
  (27, 5, 3, 77),
  (28, 5, 4, 78),
  (29, 5, 5, 83),
  (30, 5, 6, 94),
  (31, 6, 1, 74),
  (32, 6, 2, 67),
  (33, 6, 3, 61),
  (34, 6, 4, 62),
  (35, 6, 5, 62),
  (36, 6, 6, 71),
  (37, 7, 1, 68),
  (38, 7, 2, 66),
  (39, 7, 3, 81),
  (40, 7, 4, 98),
  (41, 7, 5, 64),
  (42, 7, 6, 64),
  (43, 8, 1, 55),
  (44, 8, 2, 51),
  (45, 8, 3, 63),
  (46, 8, 4, 47),
  (47, 8, 5, 37),
  (48, 8, 6, 62),
  (49, 9, 1, 58),
  (50, 9, 2, 54),
  (51, 9, 3, 57),
  (52, 9, 4, 46),
  (53, 9, 5, 42),
  (54, 9, 6, 41),
  (55, 10, 1, 43),
  (56, 10, 2, 70),
  (57, 10, 3, 67),
  (58, 10, 4, 81),
  (59, 10, 5, 48),
  (60, 10, 6, 67),
  (61, 11, 1, 57),
  (62, 11, 2, 87),
  (63, 11, 3, 58),
  (64, 11, 4, 60),
  (65, 11, 5, 92),
  (66, 11, 6, 84),
  (67, 12, 1, 78),
  (68, 12, 2, 63),
  (69, 12, 3, 48),
  (70, 12, 4, 84),
  (71, 12, 5, 96),
  (72, 12, 6, 71),
  (73, 13, 1, 60),
  (74, 13, 2, 58),
  (75, 13, 3, 72),
  (76, 13, 4, 74),
  (77, 13, 5, 70),
  (78, 13, 6, 49),
  (79, 14, 1, 72),
  (80, 14, 2, 72),
  (81, 14, 3, 49),
  (82, 14, 4, 59),
  (83, 14, 5, 88),
  (84, 14, 6, 81),
  (85, 15, 1, 80),
  (86, 15, 2, 65),
  (87, 15, 3, 37),
  (88, 15, 4, 57),
  (89, 15, 5, 51),
  (90, 15, 6, 70),
  (91, 16, 1, 57),
  (92, 16, 2, 64),
  (93, 16, 3, 85),
  (94, 16, 4, 69),
  (95, 16, 5, 72),
  (96, 16, 6, 67),
  (97, 17, 1, 81),
  (98, 17, 2, 89),
  (99, 17, 3, 61),
  (100, 17, 4, 62),
  (101, 17, 5, 67),
  (102, 17, 6, 54),
  (103, 18, 1, 43),
  (104, 18, 2, 18),
  (105, 18, 3, 34),
  (106, 18, 4, 48),
  (107, 18, 5, 42),
  (108, 18, 6, 25),
  (109, 19, 1, 66),
  (110, 19, 2, 83),
  (111, 19, 3, 79),
  (112, 19, 4, 74),
  (113, 19, 5, 68),
  (114, 19, 6, 53),
  (115, 20, 1, 95),
  (116, 20, 2, 84),
  (117, 20, 3, 77),
  (118, 20, 4, 90),
  (119, 20, 5, 79),
  (120, 20, 6, 87),
  (121, 21, 1, 76),
  (122, 21, 2, 82),
  (123, 21, 3, 74),
  (124, 21, 4, 68),
  (125, 21, 5, 79),
  (126, 21, 6, 72),
  (127, 22, 1, 77),
  (128, 22, 2, 75),
  (129, 22, 3, 73),
  (130, 22, 4, 83),
  (131, 22, 5, 82),
  (132, 22, 6, 77),
  (133, 23, 1, 34),
  (134, 23, 2, 23),
  (135, 23, 3, 46),
  (136, 23, 4, 47),
  (137, 23, 5, 56),
  (138, 23, 6, 44),
  (139, 24, 1, 40),
  (140, 24, 2, 56),
  (141, 24, 3, 32),
  (142, 24, 4, 56),
  (143, 24, 5, 71),
  (144, 24, 6, 77),
  (145, 25, 1, 61),
  (146, 25, 2, 50),
  (147, 25, 3, 56),
  (148, 25, 4, 50),
  (149, 25, 5, 63),
  (150, 25, 6, 52),
  (151, 26, 1, 81),
  (152, 26, 2, 68),
  (153, 26, 3, 70),
  (154, 26, 4, 81),
  (155, 26, 5, 74),
  (156, 26, 6, 80),
  (157, 27, 1, 52),
  (158, 27, 2, 79),
  (159, 27, 3, 51),
  (160, 27, 4, 74),
  (161, 27, 5, 98),
  (162, 27, 6, 82),
  (163, 28, 1, 35),
  (164, 28, 2, 62),
  (165, 28, 3, 61),
  (166, 28, 4, 38),
  (167, 28, 5, 61),
  (168, 28, 6, 49),
  (169, 29, 1, 85),
  (170, 29, 2, 61),
  (171, 29, 3, 67),
  (172, 29, 4, 87),
  (173, 29, 5, 84),
  (174, 29, 6, 60),
  (175, 30, 1, 60),
  (176, 30, 2, 67),
  (177, 30, 3, 57),
  (178, 30, 4, 72),
  (179, 30, 5, 65),
  (180, 30, 6, 63);

-- =====================================================================
--  DAY 2 : STORED FUNCTIONS
-- =====================================================================
DELIMITER $$

-- Grade for a mark / percentage (same scale is used in Python with np.select)
CREATE FUNCTION get_grade(p_marks DECIMAL(5,2))
RETURNS VARCHAR(2)
DETERMINISTIC
BEGIN
    DECLARE g VARCHAR(2);
    IF p_marks IS NULL THEN SET g = NULL;
    ELSEIF p_marks >= 90 THEN SET g = 'A+';
    ELSEIF p_marks >= 80 THEN SET g = 'A';
    ELSEIF p_marks >= 70 THEN SET g = 'B+';
    ELSEIF p_marks >= 60 THEN SET g = 'B';
    ELSEIF p_marks >= 50 THEN SET g = 'C';
    ELSEIF p_marks >= 40 THEN SET g = 'D';
    ELSE SET g = 'F';
    END IF;
    RETURN g;
END$$

-- Overall percentage of one student = total obtained / (subjects x 100) x 100
CREATE FUNCTION get_percentage(p_student_id INT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE pct DECIMAL(5,2);
    SELECT ROUND(SUM(marks) / (COUNT(*) * 100) * 100, 2) INTO pct
    FROM marks
    WHERE student_id = p_student_id;
    RETURN pct;
END$$

-- BONUS: PASS only if the student has no subject below 40
CREATE FUNCTION get_result(p_student_id INT)
RETURNS VARCHAR(4)
READS SQL DATA
BEGIN
    DECLARE failed INT;
    SELECT COUNT(*) INTO failed
    FROM marks
    WHERE student_id = p_student_id AND marks < 40;
    RETURN IF(failed = 0, 'PASS', 'FAIL');
END$$

DELIMITER ;

-- =====================================================================
--  DAY 2 : JOIN QUERIES
-- =====================================================================

-- (a) Marks with student, department and subject name
SELECT m.mark_id, s.roll_no, s.name AS student_name, d.dept_name,
       sub.subject_name, m.marks
FROM marks m
JOIN students    s   ON s.student_id = m.student_id
JOIN departments d   ON d.dept_id    = s.dept_id
JOIN subjects    sub ON sub.subject_id = m.subject_id
ORDER BY s.student_id, sub.subject_id;

-- (b) Subject-wise average, highest and lowest marks
SELECT sub.subject_name,
       ROUND(AVG(m.marks), 2) AS avg_marks,
       MAX(m.marks)           AS highest,
       MIN(m.marks)           AS lowest
FROM marks m
JOIN subjects sub ON sub.subject_id = m.subject_id
GROUP BY sub.subject_id, sub.subject_name
ORDER BY avg_marks DESC;

-- (c) Department-wise topper (highest total marks in each department)
WITH student_total AS (
    SELECT s.student_id, s.name, s.dept_id, SUM(m.marks) AS total_marks
    FROM students s
    JOIN marks m ON m.student_id = s.student_id
    GROUP BY s.student_id, s.name, s.dept_id
),
ranked AS (
    SELECT st.*, RANK() OVER (PARTITION BY st.dept_id ORDER BY st.total_marks DESC) AS rnk
    FROM student_total st
)
SELECT d.dept_name, r.name AS topper, r.total_marks
FROM ranked r
JOIN departments d ON d.dept_id = r.dept_id
WHERE r.rnk = 1
ORDER BY d.dept_name;

-- (d) Students failing in at least one subject (marks < 40)
SELECT s.roll_no, s.name, d.dept_name,
       COUNT(*)                 AS failed_subjects,
       GROUP_CONCAT(sub.subject_name ORDER BY sub.subject_name SEPARATOR ', ') AS failed_in
FROM marks m
JOIN students    s   ON s.student_id = m.student_id
JOIN departments d   ON d.dept_id    = s.dept_id
JOIN subjects    sub ON sub.subject_id = m.subject_id
WHERE m.marks < 40
GROUP BY s.student_id, s.roll_no, s.name, d.dept_name
ORDER BY failed_subjects DESC, s.name;

-- (e) Department average using LEFT JOIN
--     LEFT JOIN keeps departments that have no students (Biotechnology -> NULL average)
SELECT d.dept_name,
       COUNT(DISTINCT s.student_id) AS students,
       ROUND(AVG(m.marks), 2)       AS avg_marks
FROM departments d
LEFT JOIN students s ON s.dept_id    = d.dept_id
LEFT JOIN marks    m ON m.student_id = s.student_id
GROUP BY d.dept_id, d.dept_name
ORDER BY avg_marks DESC;

-- Using the stored functions
SELECT s.student_id, s.name,
       get_percentage(s.student_id)                 AS percentage,
       get_grade(get_percentage(s.student_id))      AS grade,
       get_result(s.student_id)                     AS result
FROM students s
ORDER BY percentage DESC;

-- =====================================================================
--  DAY 2 : CONSTRAINT TESTS  (every INSERT below is SUPPOSED TO FAIL)
--  Run them ONE AT A TIME in Workbench and paste/screenshot the error in your report.
--  Expected MySQL 8 messages are given in the comments.
-- =====================================================================

-- T1  CHECK (marks 0-100)
--     ERROR 3819 (HY000): Check constraint 'chk_marks_range' is violated.
-- INSERT INTO marks (student_id, subject_id, marks) VALUES (1, 1, 150);

-- T2  UNIQUE (one mark per student per subject)
--     ERROR 1062 (23000): Duplicate entry '1-1' for key 'marks.uq_student_subject'
-- INSERT INTO marks (student_id, subject_id, marks) VALUES (1, 1, 70);

-- T3  CHECK (semester 1-8)
--     ERROR 3819 (HY000): Check constraint 'chk_semester' is violated.
-- INSERT INTO students (roll_no, name, email, dept_id, semester)
-- VALUES ('B249999', 'Test Student', 'test1@college.edu', 1, 9);

-- T4  UNIQUE (e-mail)
--     ERROR 1062 (23000): Duplicate entry 'aarav.sharma1@college.edu' for key 'students.email'
-- INSERT INTO students (roll_no, name, email, dept_id, semester)
-- VALUES ('B249998', 'Test Student', 'aarav.sharma1@college.edu', 1, 3);

-- T5  FOREIGN KEY (department must exist)
--     ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
--     (`student_analytics`.`students`, CONSTRAINT `fk_student_dept` ...)
-- INSERT INTO students (roll_no, name, email, dept_id, semester)
-- VALUES ('B249997', 'Test Student', 'test2@college.edu', 99, 3);

-- T6  NOT NULL (name is mandatory)
--     ERROR 1048 (23000): Column 'name' cannot be null
-- INSERT INTO students (roll_no, name, email, dept_id, semester)
-- VALUES ('B249996', NULL, 'test3@college.edu', 1, 3);

-- T7  DEFAULT (this one SUCCEEDS - hod_name gets 'To be appointed'); then delete the row
-- INSERT INTO departments (dept_name) VALUES ('Test Dept');
-- SELECT * FROM departments WHERE dept_name = 'Test Dept';
-- DELETE FROM departments WHERE dept_name = 'Test Dept';
