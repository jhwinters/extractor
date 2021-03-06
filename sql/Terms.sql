/*
 *  Term Information
 */

USE SchoolBasebak
GO

INSERT INTO OPENROWSET(
    'Microsoft.Ace.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\School Structure.xls;',
    'SELECT * FROM [Term Dates$]')
SELECT 
    dbo.TIDY(CONVERT(NVARCHAR(10), TermActualStart, 103))           AS 'Start Date',
    dbo.TIDY(CONVERT(NVARCHAR(10), TermActualEnd, 103))             AS 'End Date',
    dbo.TIDY(TermName)                                              AS 'Term Name' 
FROM (
    SELECT t.*, tn.TermName FROM Term t, TermName tn WHERE t.TermNo = tn.TermNo
) AS Data
