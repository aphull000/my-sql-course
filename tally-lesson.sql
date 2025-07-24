/*
A tally table, also known as a numbers table or sequence table, is a utility table in SQL
that contains a sequence of numbers (e.g., 1, 2, 3, ..., N) in a single column.
 
This table can be incredibly useful for a variety of tasks in SQL querying and data manipulation.
For example, tally tables can easily generate a sequence of dates, numbers, or time intervals without using recursive queries or loops. This is particularly useful for filling in gaps in data, generating date ranges, or creating bins for histograms.
*/
 
-- Many databases, including the course database, may already have a tally table you can use.
SELECT * FROM Tally WHERE N < 10;
 
/*
Exercise: write a SQL statement to find out how many rows are in this table.  Are the values contiguous?
*/
 
/*
 * Using a Tally Table
 *
 * We can use a Tally table to create a Dates (Calendar) table
 * This sort of table is essential in analytical databases
 * For example, we use the Tally table  to create a table of dates in 2024.
 */
 
-- Here is a simple, but not good, way to build a Dates table for 2024
SELECT
    t.N AS DayOfYear
    ,DATEADD(DAY, t.N, '2023-12-31') AS TheDate
FROM
    Tally t WHERE N <=366
order by 1
 
-- A better approach is to use SQL variables to set the start and end dates
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
SELECT @StartDate = DATEFROMPARTS(2024, 1, 1);
SELECT  @EndDate = DATEFROMPARTS(2024, 12, 31);
DECLARE @NumberOfDays INT = DATEDIFF(DAY, @StartDate, @EndDate) + 1;
SELECT
    DATEADD(DAY, N-1, @StartDate) AS Date
FROM
    Tally
WHERE
    N <= @NumberOfDays
ORDER BY Date
   
 
/*
 Creating a Tally Table
 Many databases, including the course database, may already have a tally table you can use.
 Before we see how to implement this, let's remind ourselves about UNION and CROSS JOIN
 */
 
-- A UNION stacks one table on another (like a VSTACK in Excel)
SELECT
    'A' AS MyColumn
UNION
SELECT
    'B'
UNION
SELECT
    'C';
 
/*
 CROSS JOIN creates a row for every combination of the left and right tables.
 There is no ON clause since no need for a matching column
 */
WITH TableAB (a, b) AS
(
SELECT
    *
FROM
( VALUES
    ('a1', 'b1')
    , ('a2', 'b2')
    ) ab (A , B))
, TableXY (x, y) AS
(
SELECT
    *
FROM
( VALUES
    ('x1', 'y1')
    ,('x2', 'y2')
    ) XY (x , y)
)
SELECT
    *
FROM
    TableAB
CROSS JOIN TableXY;
 
 
/*
One way to build a tally tables  is to use a recursive CTE
This returns a Tally table with 10,000 rows
E1 is a table of 10 rows created by UNION of 10 SELECT statements
E2 is a CROSS JOIN of E1 with itself so has 10 x 10 or 1000 rows
E4 is a CROSS JOIN of E2 with itself so has 100 x 100 or 10,000 rows
ROW_NUMBER() is Window function that generates an index 1,2,3,... over the 10,000 rows of E4
ROW_NUMBER() must have an ORDER BY clause
If we need fewer than 10,000 rows the final statement use a WHERE cluase
*/
 
WITH E1(N) AS (
        SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
        UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
    )
    , E2(N) AS ( SELECT 1 FROM E1 a CROSS JOIN E1 b)
    , E4(N) AS ( SELECT 1 FROM E2 a CROSS JOIN E2 b)
    , FinalTally(N) AS ( SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4)
SELECT
    N
FROM
    FinalTally
WHERE
    N <= 1000
ORDER BY
    N;
 







 /*
 * Tally Tables Exercise
 
 * The temporary table, #PatientAdmission, has values for dates between the 1st and 8th January inclusive
 * But not all dates are present
 */
 
DROP TABLE IF EXISTS #PatientAdmission;
CREATE TABLE #PatientAdmission (AdmittedDate DATE, NumAdmissions INT);
INSERT INTO #PatientAdmission (AdmittedDate, NumAdmissions) VALUES ('2024-01-01', 5)
INSERT INTO #PatientAdmission (AdmittedDate, NumAdmissions) VALUES ('2024-01-02', 6)
INSERT INTO #PatientAdmission (AdmittedDate, NumAdmissions) VALUES ('2024-01-03', 4)
INSERT INTO #PatientAdmission (AdmittedDate, NumAdmissions) VALUES ('2024-01-05', 2)
INSERT INTO #PatientAdmission (AdmittedDate, NumAdmissions) VALUES ('2024-01-08', 2)
SELECT * FROM #PatientAdmission
 
/*
 * Exercise: create a resultset that has a row for all dates in that period
 * of 8 days with NumAdmissions set to 0 for missing dates.
 You may wish to use the SQL statements below to set the start and end dates
 */
 
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
SELECT @StartDate = DATEFROMPARTS(2024, 1, 1);
SELECT @EndDate = DATEFROMPARTS(2024, 1, 8);
DECLARE @numdays INT


SELECT @numdays = DATEDIFF(DAY,@StartDate,@EndDate)+1

SELECT
    DATEADD(DAY, N-1, @StartDate) AS Date
FROM Tally
WHERE N <=@numdays
ORDER BY Date


-- write your answer here
--alternative
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
SELECT @StartDate = DATEFROMPARTS(2024, 1, 1);
SELECT @EndDate = DATEFROMPARTS(2024, 1, 8);


DECLARE @NumDays INT = DATEDIFF(DAY, @StartDate, @EndDate) + 1;
 
SELECT
    DATEADD(DAY, N-1, @StartDate) AS AdmittedDate
FROM
    Tally
WHERE N <= @NumDays
ORDER BY N;
 
 







/*
 * Exercise: list the dates that have no patient admissions
*/
 
 
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
SELECT @StartDate = DATEFROMPARTS(2024, 1, 1);
SELECT @EndDate = DATEFROMPARTS(2024, 1, 8);
DECLARE @NumDays INT = DATEDIFF(DAY, @StartDate, @EndDate) + 1;

drop table if exists #Dates;
SELECT
    DATEADD(DAY, N-1, @StartDate) AS AdmittedDate
into #Dates
FROM
    Tally
WHERE N <= @NumDays
ORDER BY N;
 
SELECT * FROM #Dates d
WHERE d.AdmittedDate NOT IN (SELECT AdmittedDate FROM #PatientAdmission)





--not exists

DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
SELECT @StartDate = DATEFROMPARTS(2024, 1, 1);
SELECT @EndDate = DATEFROMPARTS(2024, 1, 8);
DECLARE @NumDays INT = DATEDIFF(DAY, @StartDate, @EndDate) + 1;


SELECT * FROM #Dates d
WHERE NOT EXISTS (SELECT * FROM #PatientAdmission p
                 WHERE d.AdmittedDate = p.AdmittedDate
                 )


--left join

SELECT d.AdmittedDate
FROM #Dates d
LEFT JOIN #PatientAdmission p 
ON d.AdmittedDate = p.AdmittedDate
WHERE p.AdmittedDate IS NULL


--except

SELECT AdmittedDate
FROM #Dates
EXCEPT
SELECT AdmittedDate
FROM #PatientAdmission
