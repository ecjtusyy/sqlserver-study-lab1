USE Study;
GO

-- （1）查询所有同学的基本信息
SELECT s_no, class_no, s_name, s_sex, s_birthday
FROM Student;
GO

-- （2）查询所有同学，显示学号、姓名
SELECT s_no, s_name
FROM Student;
GO

-- （3）查询所有男同学
SELECT s_no, s_name, s_birthday
FROM Student
WHERE s_sex = N'男';
GO

-- （4）查询出生日期在 1980-01-01 前的女同学
SELECT s_no, s_name, s_sex, s_birthday
FROM Student
WHERE s_sex = N'女'
  AND s_birthday < '1980-01-01';
GO

-- （5）查询所有姓“李”的男同学
SELECT s_no, s_name, s_sex, s_birthday
FROM Student
WHERE s_name LIKE N'李%'
  AND s_sex = N'男';
GO

-- （6）查询姓名中含有“一”字的同学
SELECT s_no, s_name
FROM Student
WHERE s_name LIKE N'%一%';
GO

-- （7）查询职称不是“讲师”的教师
SELECT t_no, t_name, t_title
FROM Teacher
WHERE t_title <> N'讲师';
GO

-- （8）查询虽选修了课程，但未参加考试的同学
SELECT DISTINCT s_no
FROM Choice
WHERE score IS NULL;
GO

-- （9）查询所有考试不及格的同学，按成绩降序排列
SELECT s_no, score
FROM Choice
WHERE score < 60
ORDER BY score DESC;
GO

-- （10）查询课程号为 01001、02001、02003 的课程（IN）
SELECT course_no, course_name
FROM Course
WHERE course_no IN ('01001', '02001', '02003');
GO

-- （11）查询所有在 1970 年出生的教师
SELECT t_no, t_name, t_birthday
FROM Teacher
WHERE YEAR(t_birthday) = 1970;
GO

-- （12）查询各个课程号及相应的选课人数
SELECT c.course_no, COUNT(ch.s_no) AS student_count
FROM Course c
LEFT JOIN Choice ch ON c.course_no = ch.course_no
GROUP BY c.course_no
ORDER BY c.course_no;
GO

-- （13）查询教授两门以上课程的教师号
SELECT t_no
FROM Teaching
GROUP BY t_no
HAVING COUNT(course_no) > 1;
GO

-- （14）查询选修了 01001 课程的学生平均分、最低分、最高分
SELECT AVG(score) AS avg_score,
       MIN(score) AS min_score,
       MAX(score) AS max_score
FROM Choice
WHERE course_no = '01001';
GO

-- （15）查询 1960 年以后出生且职称为讲师的教师姓名、出生日期，并按出生日期升序排列
SELECT t_name, t_birthday
FROM Teacher
WHERE YEAR(t_birthday) > 1960
  AND t_title = N'讲师'
ORDER BY t_birthday ASC;
GO
