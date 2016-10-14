/*
 *  Script to extract the Passport Info sheet for the Pupil Data workbook.
 *
 *  Relies on the dbo.TIDY method being already installed.
 */

USE Schoolbasebak;
GO

INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Pupil Data.xls;', 'SELECT * FROM [Passport Info$]')
SELECT
    p.Pu_CompNo                                  AS 'Pupil Id',
    pt.PassportType                              AS 'Type',
    p.PupPassNo                                  AS 'Number',
    n.Nationality                                AS 'Nationality',
    p.PupPassIssuePlace                          AS 'Place of Issue',
    CONVERT(NVARCHAR(10), p.PupPassExpires, 103) AS 'Expiry Date'
FROM
    Pupil p 
INNER JOIN
    PassportType pt
ON
    p.PassportType = pt.PassportTypeIdent
INNER JOIN
    Nationality n
ON
    p.NatIdent = n.NatIdent
WHERE
    p.PassportType IS NOT NULL
GO
