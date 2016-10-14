/*
	Core School Structure Data Sheet Extraction
*/

USE SchoolBaseBak
GO

/*
	Years Information
	
	Do Check NC Year the numbers for them might be out of sync.
*/

INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\School Structure.xls;', 'SELECT * FROM [Years$]')
SELECT * FROM (
    SELECT
	CONVERT(INT, dbo.TIDY(YearDesc))      AS 'NC Year',
	dbo.TIDY(YearDesc1)	              AS 'Code',
	dbo.TIDY(YearName)                    AS 'Name',
	dbo.TIDY(HeadOfYear)                  AS 'Head',
	dbo.TIDY('')                          AS 'Assistant Head'
    FROM
	Years
    WHERE
	YearName NOT LIKE '%Prep%'
    UNION ALL
    SELECT
	CONVERT(INT, dbo.TIDY(YearDesc)) + 20 AS 'NC Year',
	dbo.TIDY(YearDesc1)	              AS 'Code',
	dbo.TIDY(YearName)                    AS 'Name',
	dbo.TIDY(HeadOfYear)                  AS 'Head',
	dbo.TIDY('')                          AS 'Assistant Head'
    FROM
	Years
    WHERE
	YearName LIKE '%Prep%'
) AS Data
ORDER BY CONVERT(INT, Data.[NC Year])
GO
	
/*
	Houses Information

	All ours are Academic houses, even if they do boarding as well.
*/

INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\School Structure.xls;', 'SELECT * FROM [Houses$]')
SELECT
    dbo.TIDY(LEFT(HouseName, 3))          AS 'Code',
    dbo.TIDY(HouseName)                   AS 'Name',
    dbo.TIDY('Academic')                  AS 'Type',
    dbo.TIDY(UserIdent)                   AS 'Head',
    dbo.TIDY('')                          AS 'Assistant Head'
FROM
    House
GO

/*
	Forms Information
*/

INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\School Structure.xls;', 'SELECT * FROM [Forms$]')
SELECT * FROM (
    SELECT
        dbo.TIDY(ClassName)                                                              AS 'Form',
        CONVERT(INT,
                (SELECT YearDesc FROM Years y WHERE y.YearIdent = Class.YearIdent)) + 20 AS 'NC Year',
        dbo.TIDY(StaffIdent)                                                             AS 'Tutor',
        dbo.TIDY('')                                                                     AS 'Assistant Tutor'
    FROM
        Class
    WHERE
        ClassName LIKE 'Year %'
    UNION ALL
    SELECT
        dbo.TIDY(ClassName)                                                              AS 'Form',
        CONVERT(INT,
                (SELECT YearDesc FROM Years y WHERE y.YearIdent = Class.YearIdent))      AS 'NC Year',
        dbo.TIDY(StaffIdent)                                                             AS 'Tutor',
        dbo.TIDY('')                                                                     AS 'Assistant Tutor'
    FROM
        Class
    WHERE
        ClassName NOT LIKE 'Year %'
) AS Data
ORDER BY 
	Data.[NC Year]
GO
