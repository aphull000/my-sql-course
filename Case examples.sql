/*
SQL Course - CASE Lesson
We can add a new calculated columns and use CASE as a switch between options.
*/
 
/*
A "simple form" CASE statement based on the values of a single column
*/
 
SELECT
	ps.PatientId
	, ps.Hospital
	, CASE
		ps.Hospital
	    WHEN 'PRUH' THEN 'Princess Royal University Hospital'
		WHEN 'Oxleas' THEN 'Oxleas NHS Foundation Trust'
		ELSE 'Other Hospitals'
	END AS HospitalGroup
	, ps.Ward
FROM
	dbo.PatientStay ps
ORDER BY
	HospitalGroup;
 
/*
A "searched form" CASE statement based on a boolean condition
*/
 
SELECT
	ps.PatientId
	, ps.Hospital
	, ps.Ward
	, CASE
		WHEN ps.Ward LIKE '%Surgery' THEN 'Surgical'
		WHEN ps.Ward IN ('Accident', 'Emergency', 'Ophthalmology') THEN 'A&E'
		ELSE 'General'
	END AS WardType
FROM
	dbo.PatientStay ps
ORDER BY WardType;
 
/*
* A common pattern is to use a SUM(CASE ... WHEN ... THEN 1 ELSE 0 END) calculation 
* to count where the number of rows where a condition occurs
*/
 
SELECT
	ps.Hospital
	, COUNT(*) AS NumberOfPatients
	, SUM(CASE WHEN ps.Ward LIKE '%Surgery' THEN 1 ELSE 0 END) AS NumberOfPatientsInSurgery
	, (100 * SUM(CASE WHEN ps.Ward LIKE '%Surgery' THEN 1 ELSE 0 END)) / COUNT(*) * 1.0 AS PercentageOfPatientsInSurgery
FROM
	dbo.PatientStay ps
GROUP BY ps.Hospital 
ORDER BY ps.Hospital
 
 
/*
Optional advanced section
A more complex "searched form" CASE syntax statement  for more general cases
Assume that the Financial Year starts on March 1st
*/
SELECT
    ps.PatientId
    , ps.AdmittedDate
    , CASE
        WHEN DATEPART(MONTH, ps.AdmittedDate) >= 3 -- March or later in the year
    THEN     CONCAT('FY-', DATEPART(YEAR, ps.AdmittedDate), '-', DATEPART(YEAR, ps.AdmittedDate) + 1)
        ELSE CONCAT('FY-', DATEPART(YEAR, ps.AdmittedDate) - 1, '-', DATEPART(YEAR, ps.AdmittedDate))
    END AS FinancialYear
FROM dbo.PatientStay ps
WHERE ps.Hospital = 'PRUH'
ORDER BY ps.AdmittedDate,
         ps.PatientId;


--error message
SELECT 5.0/13




--tasks
/* 
* Create a new column HospitalLocation
* Kings College is Urban, other hospitals are Rural 
* Use the simple CASE form
*/
 
SELECT
	ps.PatientId
	, ps.Hospital
    ,CASE
        ps.Hospital
	    WHEN 'Kings College' THEN 'Urban'
		ELSE 'Rural'
	END AS HospitalLocation
FROM
	dbo.PatientStay ps
ORDER BY
	HospitalLocation;
 
/* 
* Create a new column WardType
* Any ward that contains 'Surgery' is 'Surgical', otherwise 'Non Surgical'
* Use the searched CASE form
*/
 
SELECT
	ps.PatientId
	, ps.Hospital
    ,ps.Ward
    ,CASE WHEN ps.Ward LIKE '%Surgery%' THEN 'Surgical'
          ELSE 'Non Surgical'
    END AS WardType
FROM
	dbo.PatientStay ps
ORDER BY
	WardType;
 
/*
* Create a new column PatientTariffGroup
* A patient with a Tariff of 7 or more is in the 'High Tariff' group
* A patient with a Tariff of 4 or more but below 7 is in the 'Medium Tariff' group
* A patient with a Tariff below 4 is is in the 'Low Tariff' group
* 
* Optional advanced question: how many patients are in each PatientTariffGroup?
*/
SELECT
	ps.PatientId
	, ps.AdmittedDate
	, ps.Tariff
    , CASE WHEN ps.Tariff >='7' THEN 'High Tariff'
           WHEN ps.Tariff >='4' THEN 'Medium Tariff'
           ELSE 'Low Tariff'
      END PatientTariffGroup
FROM
	dbo.PatientStay ps
GROUP BY 
	ps.PatientId
	, ps.AdmittedDate
	, ps.Tariff
ORDER BY
	PatientTariffGroup
	, ps.Tariff
	, ps.PatientId;





--Sub query (table sub query)
SELECT 
p.PatientTariffGroup
,Count(*)NumberOfPatients
FROM (

                SELECT
                    ps.PatientId
                    , ps.AdmittedDate
                    , ps.Tariff
                    , CASE WHEN ps.Tariff >='7' THEN 'High Tariff'
                        WHEN ps.Tariff >='4' THEN 'Medium Tariff'
                        ELSE 'Low Tariff'
                    END PatientTariffGroup
                FROM
                    dbo.PatientStay ps
                GROUP BY 
                    ps.PatientId
                    , ps.AdmittedDate
                    , ps.Tariff

    ) AS p
GROUP BY p.PatientTariffGroup
ORDER BY p.PatientTariffGroup



--Rewrite as a CTE (common table expression)

;WITH 
    p 
    AS 
    (SELECT
    ps.PatientId
    , ps.AdmittedDate
    , ps.Tariff
    , CASE WHEN ps.Tariff >= 7 THEN 'High Tariff'
        WHEN ps.Tariff >= 4 THEN 'Medium Tariff'
        ELSE 'Low Tariff'
    END    
     AS PatientTariffGroup
FROM
    dbo.PatientStay ps)  
SELECT
    p.PatientTariffGroup
    , COUNT(*) AS NumberOfPatients      
FROM p
GROUP BY p.PatientTariffGroup
ORDER BY p.PatientTariffGroup;


--better CTE

;WITH 
    p (PatientId, AdmittedDate, Tariff, PatientTariffGroup) --Lists the fields it's returing so easier to read!
    AS 
    (SELECT
    ps.PatientId
    , ps.AdmittedDate
    , ps.Tariff
    , CASE WHEN ps.Tariff >= 7 THEN 'High Tariff'
        WHEN ps.Tariff >= 4 THEN 'Medium Tariff'
        ELSE 'Low Tariff'
    END    
FROM
    dbo.PatientStay ps)  
SELECT
    p.PatientTariffGroup
    , COUNT(*) AS NumberOfPatients      
FROM p
GROUP BY p.PatientTariffGroup
ORDER BY p.PatientTariffGroup;

