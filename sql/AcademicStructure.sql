
USE SchoolBasebak
GO

/*
    Departments Information
*/

INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Academic Structure.xls;', 'SELECT * FROM [Departments$]')
SELECT
    dbo.TIDY(DepIdent)                    AS 'Code',
    dbo.TIDY(Department)                  AS 'Name',
    dbo.TIDY(UserIdent)                   AS 'Head'
FROM
    Department
GO    

/*
    Subjects
*/

INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Academic Structure.xls;', 'SELECT * FROM [Subjects$]')
SELECT
    dbo.TIDY(s.SubCode)                   AS 'Code',
    dbo.TIDY(s.SubName)                   AS 'Name',
    dbo.TIDY('')                          AS 'Report Name',
    dbo.TIDY('')                          AS 'Head',
    dbo.TIDY(s.DepIdent)                  AS 'Department Code'
FROM
    Subjects s INNER JOIN Department d ON s.DepIdent = d.DepIdent
GO
    
