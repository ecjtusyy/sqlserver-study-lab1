USE Study;
GO

-- （1）查询所有同学的选课及成绩情况
SELECT s.s_no, s.s_name, ch.course_no, ch.score
FROM Student s
JOIN Choice ch ON s.s_no = ch.s_no
ORDER BY s.s_no, ch.course_no;
GO

-- （2）查询所有同学的选课及成绩情况，并保存到 new_table
IF OBJECT_ID('new_table', 'U') IS NOT NULL
    DROP TABLE new_table;
GO

SELECT s.s_name, c.course_name, ch.score
INTO new_table
FROM Student s
JOIN Choice ch ON s.s_no = ch.s_no
JOIN Course c ON ch.course_no = c.course_no;
GO

SELECT s_name, course_name, score
FROM new_table
ORDER BY s_name, course_name;
GO

-- （3）查询“计算机99-1”班同学的选课及成绩情况
SELECT s.s_no, s.s_name, c.course_no, c.course_name, ch.score
FROM Student s
JOIN Class cl ON s.class_no = cl.class_no
JOIN Choice ch ON s.s_no = ch.s_no
JOIN Course c ON ch.course_no = c.course_no
WHERE cl.class_name = N'计算机99-1'
ORDER BY s.s_no, c.course_no;
GO

-- （4）查询所有同学的学分情况（成绩>=60分获得学分）（用JOIN）
SELECT s.s_no,
       s.s_name,
       ISNULL(SUM(CASE WHEN ch.score >= 60 THEN c.course_score ELSE 0 END), 0) AS total_score
FROM Student s
LEFT JOIN Choice ch ON s.s_no = ch.s_no
LEFT JOIN Course c ON ch.course_no = c.course_no
GROUP BY s.s_no, s.s_name
ORDER BY s.s_no;
GO

-- （5）查询所有同学的平均成绩及选课门数
SELECT s.s_no,
       s.s_name,
       CAST(ISNULL(AVG(CAST(ch.score AS DECIMAL(10,2))), 0) AS DECIMAL(10,2)) AS average_score,
       COUNT(ch.course_no) AS choice_num
FROM Student s
LEFT JOIN Choice ch ON s.s_no = ch.s_no
GROUP BY s.s_no, s.s_name
ORDER BY s.s_no;
GO

-- （6）查询选修了课程但未参加考试的同学及相应课程
SELECT s.s_no, s.s_name, c.course_no, c.course_name
FROM Student s
JOIN Choice ch ON s.s_no = ch.s_no
JOIN Course c ON ch.course_no = c.course_no
WHERE ch.score IS NULL
ORDER BY s.s_no, c.course_no;
GO

-- （7）查询选修了课程但考试不及格的同学及相应课程
SELECT s.s_no, s.s_name, c.course_no, c.course_name, c.course_score
FROM Student s
JOIN Choice ch ON s.s_no = ch.s_no
JOIN Course c ON ch.course_no = c.course_no
WHERE ch.score < 60
ORDER BY s.s_no, c.course_no;
GO

-- （8）查询选修“程序设计语言”的所有同学及成绩（使用ANY）
SELECT s.s_name, ch.score
FROM Student s
JOIN Choice ch ON s.s_no = ch.s_no
WHERE ch.course_no = ANY (
    SELECT c.course_no
    FROM Course c
    WHERE c.course_name = N'程序设计语言'
)
ORDER BY s.s_name;
GO

-- （9）查询“计算机系”的所有同学及成绩情况
SELECT s.s_no, s.s_name, cl.class_name, ch.course_no, c.course_name, ch.score
FROM Student s
JOIN Class cl ON s.class_no = cl.class_no
LEFT JOIN Choice ch ON s.s_no = ch.s_no
LEFT JOIN Course c ON ch.course_no = c.course_no
WHERE cl.class_dept = N'计算机系'
ORDER BY s.s_no, ch.course_no;
GO

-- （10）查询所有教师的任课情况
SELECT t.t_name, c.course_name
FROM Teacher t
LEFT JOIN Teaching te ON t.t_no = te.t_no
LEFT JOIN Course c ON te.course_no = c.course_no
ORDER BY t.t_no, c.course_no;
GO

-- （11）查询所有教师的任课门数
SELECT t.t_name, COUNT(te.course_no) AS course_number
FROM Teacher t
LEFT JOIN Teaching te ON t.t_no = te.t_no
GROUP BY t.t_no, t.t_name
ORDER BY t.t_no;
GO

-- （12）查询和“李建国”是同一班级的同学姓名（使用子查询）
SELECT s_name
FROM Student
WHERE class_no = (
    SELECT class_no
    FROM Student
    WHERE s_name = N'李建国'
)
AND s_name <> N'李建国';
GO

-- （13）查询没有选修“计算机基础”课程的学生姓名（NOT EXISTS）
SELECT s.s_name
FROM Student s
WHERE NOT EXISTS (
    SELECT 1
    FROM Choice ch
    JOIN Course c ON ch.course_no = c.course_no
    WHERE ch.s_no = s.s_no
      AND c.course_name = N'计算机基础'
)
ORDER BY s.s_no;
GO

-- （14）查询主讲“数据库原理与应用”和主讲“数据结构”的教师姓名（UNION）
SELECT t.t_name
FROM Teacher t
JOIN Teaching te ON t.t_no = te.t_no
JOIN Course c ON te.course_no = c.course_no
WHERE c.course_name = N'数据库原理与应用'

UNION

SELECT t.t_name
FROM Teacher t
JOIN Teaching te ON t.t_no = te.t_no
JOIN Course c ON te.course_no = c.course_no
WHERE c.course_name = N'数据结构';
GO

-- （15）查询讲授了所有课程的教师姓名
SELECT t.t_name
FROM Teacher t
WHERE NOT EXISTS (
    SELECT 1
    FROM Course c
    WHERE NOT EXISTS (
        SELECT 1
        FROM Teaching te
        WHERE te.t_no = t.t_no
          AND te.course_no = c.course_no
    )
);
GO
