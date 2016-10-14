
USE SchoolBasebak
GO

/*
 *  Building Information
 */

INSERT INTO OPENROWSET(
    'Microsoft.Ace.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Buildings.xls;',
    'SELECT * FROM [Buildings$]')
SELECT
    dbo.TIDY(LEFT(Building, 3))                         AS 'Code',
    dbo.TIDY(Building)                                  AS 'Name',
    dbo.TIDY('')                                        AS 'Description',
    dbo.TIDY(
        CASE
            WHEN EXISTS(SELECT Top 1 RoomIdent FROM Room r WHERE r.BuildIdent = BuildIdent) THEN 1 ELSE 0
        END
    )                                                   AS 'Has Classrooms'
FROM
    Building
GO
    
/*
 *  Classroom Information
 */

INSERT INTO OPENROWSET(
    'Microsoft.Ace.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Buildings.xls;',
    'SELECT * FROM [Classrooms$]')
SELECT
    dbo.TIDY(Room)                                          AS 'Code',
    dbo.TIDY(RoomName)                                      AS 'Name',
    dbo.TIDY('')                                            AS 'Description',
    dbo.TIDY(LEFT(Building, 3))                             AS 'Building'
FROM
    BuildingRooms
WHERE RoomCurrent = 1
GO
