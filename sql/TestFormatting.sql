/*
Try to tickle the Excel formatting bug.
*/

INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\School Structure.xls;', 'SELECT * FROM [Term Dates$]')
SELECT
    'AbleData'          AS 'Start Date',
    ''  	        AS 'End Date',
    'CharlieData'       AS 'Term Name'
UNION ALL
SELECT
    'Able2Data'          AS 'Start Date',
    'BakerData'          AS 'End Date',
    'Charlie2Data'       AS 'Term Name'
GO
