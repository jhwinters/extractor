/*
 *  Script to extract the Visa Info sheet for the Pupil Data workbook.
 *
 *  Relies on the dbo.TIDY method being already installed.
 */

USE Schoolbasebak;
GO

INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Pupil Data.xls;', 'SELECT * FROM [Visa Info$]')
SELECT
    p.Pu_CompNo                                   AS 'Pupil Id',
    p.PupVisaType                                 AS 'Type',
    p.PupVisaNo                                   AS 'Id',
    ''                                            AS 'CAS',
    n.Nationality                                 AS 'Nationality',
    ''                                            AS 'Country of Issue',
    CONVERT(NVARCHAR(10), p.PupVisaIssued, 103)   AS 'Valid From Date',
    CONVERT(NVARCHAR(10), p.PupVisaExpires, 103)  AS 'Valid Until Date',
    ''                                            AS 'Entry Date',
    ''                                            AS 'Notes'
FROM
    Pupil p
INNER JOIN
    Nationality n
ON
    p.NatIdent = n.NatIdent
WHERE
    p.PupVisaType IS NOT NULL
