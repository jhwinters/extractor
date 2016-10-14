/*
 * Try to extract just phone numbers as notes.
 */

USE Schoolbasebak;
GO

/*
 * For each pupil dump *all* the attached telephone numbers into a
 * note attached to the pupil's record.  Where a pupil has more than
 * one AdultOffspring record he will get more than one note.
 */
INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Pupil Data.xls;', 'SELECT * FROM [General Notes$]')
SELECT
    CONVERT(INT, ao.PupOrigNum)                         AS 'Pupil Id',
    dbo.tidy('Old phone numbers')                       AS 'Type',
    LEFT(dbo.TIDY((
            SELECT 
                pn.Ph_Location + ': ' + pn.Ph_PhoneNo + ',' AS [text()]
            FROM 
                PhoneNos pn
            WHERE 
                pn.AdultNo = ao.AdultNo
            FOR XML PATH ('')
        )
    ), 255)                                               AS 'Body', 
    CONVERT(NVARCHAR(10), GETDATE(), 103)                 AS 'Date'
FROM
  AdultOffspring ao INNER JOIN Pupil p on p.PupOrigNum = ao.PupOrigNum

GO
