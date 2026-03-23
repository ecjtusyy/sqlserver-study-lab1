USE master;
GO

IF DB_ID('Study') IS NOT NULL
BEGIN
    ALTER DATABASE Study SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Study;
END
GO

CREATE DATABASE Study;
GO

USE Study;
GO

-- 1. Class
CREATE TABLE Class (
    class_no CHAR(6) PRIMARY KEY,
    class_name NVARCHAR(20) NOT NULL,
    class_special NVARCHAR(20),
    class_dept NVARCHAR(20)
);
GO

-- 2. Student
CREATE TABLE Student (
    s_no CHAR(6) PRIMARY KEY,
    class_no CHAR(6) NOT NULL,
    s_name NVARCHAR(10) NOT NULL,
    s_sex NCHAR(2) CHECK (s_sex IN (N'男', N'女')),
    s_birthday DATETIME,
    CONSTRAINT FK_Student_Class FOREIGN KEY (class_no) REFERENCES Class(class_no)
);
GO

-- 3. Course
CREATE TABLE Course (
    course_no CHAR(5) PRIMARY KEY,
    course_name NVARCHAR(20) NOT NULL,
    course_score NUMERIC(6,2)
);
GO

-- 4. Choice
CREATE TABLE Choice (
    s_no CHAR(6),
    course_no CHAR(5),
    score NUMERIC(6,1),
    CONSTRAINT FK_Choice_Student FOREIGN KEY (s_no) REFERENCES Student(s_no),
    CONSTRAINT FK_Choice_Course FOREIGN KEY (course_no) REFERENCES Course(course_no)
);
GO

-- 5. Teacher
CREATE TABLE Teacher (
    t_no CHAR(6) PRIMARY KEY,
    t_name NVARCHAR(10) NOT NULL,
    t_sex NCHAR(2) CHECK (t_sex IN (N'男', N'女')),
    t_birthday DATETIME,
    t_title NVARCHAR(10)
);
GO

-- 6. Teaching
CREATE TABLE Teaching (
    course_no CHAR(5),
    t_no CHAR(6),
    CONSTRAINT FK_Teaching_Course FOREIGN KEY (course_no) REFERENCES Course(course_no),
    CONSTRAINT FK_Teaching_Teacher FOREIGN KEY (t_no) REFERENCES Teacher(t_no)
);
GO

-- 插入 Class
INSERT INTO Class VALUES ('js9901', N'计算机99-1', N'计算机', N'计算机系');
INSERT INTO Class VALUES ('js9902', N'计算机99-2', N'计算机', N'计算机系');
INSERT INTO Class VALUES ('js0001', N'计算机00-1', N'计算机', N'计算机系');
INSERT INTO Class VALUES ('js0002', N'计算机00-2', N'计算机', N'计算机系');
INSERT INTO Class VALUES ('xx0001', N'信息00-1', N'信息', N'信息系');
INSERT INTO Class VALUES ('xx0002', N'信息00-2', N'信息', N'信息系');
GO

-- 插入 Student
INSERT INTO Student VALUES ('991101', 'js9901', N'张彬',   N'男', '1981-10-01');
INSERT INTO Student VALUES ('991102', 'js9901', N'王蕾',   N'女', '1980-08-08');
INSERT INTO Student VALUES ('991103', 'js9901', N'李建国', N'男', '1981-04-05');
INSERT INTO Student VALUES ('991104', 'js9901', N'李平方', N'男', '1981-05-12');
INSERT INTO Student VALUES ('991201', 'js9902', N'陈东辉', N'男', '1980-02-08');
INSERT INTO Student VALUES ('991202', 'js9902', N'葛鹏',   N'男', '1979-12-23');
INSERT INTO Student VALUES ('991203', 'js9902', N'藩桃芝', N'女', '1980-02-06');
INSERT INTO Student VALUES ('991204', 'js9902', N'姚一峰', N'男', '1981-05-07');
INSERT INTO Student VALUES ('001101', 'js0001', N'宋大方', N'男', '1980-04-09');
INSERT INTO Student VALUES ('001102', 'js0001', N'许辉',   N'女', '1978-08-01');
INSERT INTO Student VALUES ('001201', 'js0002', N'王一山', N'男', '1980-12-04');
INSERT INTO Student VALUES ('001202', 'js0002', N'牛莉',   N'女', '1981-06-09');
INSERT INTO Student VALUES ('002101', 'xx0001', N'李丽丽', N'女', '1981-09-19');
INSERT INTO Student VALUES ('002102', 'xx0001', N'李王',   N'男', '1980-09-23');
GO

-- 插入 Course
INSERT INTO Course VALUES ('01001', N'计算机基础',       3);
INSERT INTO Course VALUES ('01002', N'程序设计语言',     5);
INSERT INTO Course VALUES ('01003', N'数据结构',         6);
INSERT INTO Course VALUES ('02001', N'数据库原理与应用', 6);
INSERT INTO Course VALUES ('02002', N'计算机网络',       6);
INSERT INTO Course VALUES ('02003', N'微机原理与应用',   8);
GO

-- 插入 Choice
INSERT INTO Choice VALUES ('991101', '01001', 88.0);
INSERT INTO Choice VALUES ('991102', '01001', NULL);
INSERT INTO Choice VALUES ('991103', '01001', 91.0);
INSERT INTO Choice VALUES ('991104', '01001', 78.0);
INSERT INTO Choice VALUES ('991201', '01001', 67.0);
INSERT INTO Choice VALUES ('991101', '01002', 90.0);
INSERT INTO Choice VALUES ('991102', '01002', 58.0);
INSERT INTO Choice VALUES ('991103', '01002', 71.0);
INSERT INTO Choice VALUES ('991104', '01002', 85.0);
GO

-- 插入 Teacher
INSERT INTO Teacher VALUES ('000001', N'李英',   N'女', '1964-11-03', N'讲师');
INSERT INTO Teacher VALUES ('000002', N'王大山', N'男', '1955-03-07', N'副教授');
INSERT INTO Teacher VALUES ('000003', N'张朋',   N'男', '1960-10-05', N'讲师');
INSERT INTO Teacher VALUES ('000004', N'陈为军', N'男', '1970-03-02', N'助教');
INSERT INTO Teacher VALUES ('000005', N'宋浩然', N'男', '1966-12-04', N'讲师');
INSERT INTO Teacher VALUES ('000006', N'许红霞', N'女', '1951-05-08', N'副教授');
INSERT INTO Teacher VALUES ('000007', N'徐永军', N'男', '1948-04-08', N'教授');
INSERT INTO Teacher VALUES ('000008', N'李桂菁', N'女', '1940-11-03', N'教授');
INSERT INTO Teacher VALUES ('000009', N'王一凡', N'女', '1962-05-09', N'讲师');
INSERT INTO Teacher VALUES ('000010', N'田峰',   N'男', '1972-11-05', N'助教');
GO

-- 插入 Teaching
INSERT INTO Teaching VALUES ('01001', '000001');
INSERT INTO Teaching VALUES ('01002', '000002');
INSERT INTO Teaching VALUES ('01003', '000002');
INSERT INTO Teaching VALUES ('02001', '000003');
INSERT INTO Teaching VALUES ('02002', '000004');
INSERT INTO Teaching VALUES ('01001', '000005');
INSERT INTO Teaching VALUES ('01002', '000006');
INSERT INTO Teaching VALUES ('01003', '000007');
INSERT INTO Teaching VALUES ('02001', '000007');
INSERT INTO Teaching VALUES ('02002', '000008');
GO