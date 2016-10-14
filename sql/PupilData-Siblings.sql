/*
 *  Script to extract the Siblings sheet for the Pupil Data workbook.
 *
 *  Relies on the dbo.TIDY method being already installed.
 */

USE SchoolBasebak;
GO

INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Pupil Data.xls;', 'SELECT * FROM [Siblings$]')
SELECT
    dbo.TIDY(PupOrigNum) AS 'Pupil Id 1',
    dbo.TIDY(Sibling)    AS 'Pupil ID 2'
FROM (
    SELECT
	*
    FROM 
	Siblings
    WHERE
	PupOrigNum IN (
            SELECT
	        PupOrigNum
            FROM
		Pupil
	    WHERE PType IN (5,8,40,60,95,100)
	)
) AS Data
WHERE
    Sibling IN (
	SELECT
	    PupOrigNum
	FROM
	    Pupil
	WHERE PType IN (5,8,40,60,95,100)
    )
ORDER BY 
    PupOrigNum
