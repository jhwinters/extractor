/*
 *  Get User Details
 */
USE SchoolBasebak
GO

INSERT INTO OPENROWSET(
    'Microsoft.Ace.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Users.xls;',
    'SELECT * FROM [User Groups$]')
SELECT
   'Senior School Teaching'                           As 'StaffId',
   'Teaching staff at Abingdon School'                As 'Description'
UNION
SELECT
   'Prep School Teaching'                             As 'StaffId',
   'Teaching staff at Abingdon Prep'                  As 'Description'
UNION
SELECT
   'Senior School Non-teaching'                       As 'StaffId',
   'Non teaching staff at Abingdon School'            As 'Description'
UNION
SELECT
   'Prep School Non-teaching'                         As 'StaffId',
   'Non teaching staff at Abingdon Prep'              As 'Description'
UNION
SELECT
   'Others'                                           As 'StaffId',
   'Others'                                           As 'Description'
GO

INSERT INTO OPENROWSET(
    'Microsoft.Ace.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Users.xls;',
    'SELECT * FROM [Security Profiles$]')
SELECT
   'A'                                                As 'Code',
   'Administrators'                                   As 'Name',
   'Administrators with full control of iSAMS'        As 'Description'
UNION
SELECT
   'S'                                                As 'Code',
   'Staff'                                            As 'Name',
   'Normal staff access'                              As 'Description'
UNION
SELECT
   'E'                                                As 'Code',
   'Elevated staff'                                   As 'Name',
   'Staff with special responsibilities'              As 'Description'
GO

INSERT INTO OPENROWSET(
    'Microsoft.Ace.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Users.xls;',
    'SELECT * FROM [Users$]')
SELECT
    dbo.TIDY(UserIdent)                               AS 'StaffId',
    dbo.TIDY(LOWER(UserForename + '.' + UserSurname)) AS 'Username/AD Username',
    dbo.TIDY(UserEmail)                               AS 'Email Address',
    dbo.TIDY(
        (SELECT
            CASE
                WHEN Ptype = 60 AND UserTeach = 1 THEN 'Senior School Teaching'
                WHEN Ptype = 40 AND UserTeach = 1 THEN 'Prep School Teaching'
                WHEN Ptype = 60 AND UserTeach = 0 THEN 'Senior School Non-teaching'
                WHEN Ptype = 40 AND UserTeach = 0 THEN 'Prep School Non-teaching'
                ELSE 'Others'
            END
        )
    )                                                 AS 'User Group Name',
    dbo.TIDY(
        (SELECT
            CASE
                WHEN UserMnemonic = 'JHW' THEN 'A'
                WHEN UserMnemonic = 'ICF' THEN 'E'
                /*
                 *  Add more individuals here as needed.
                 */
                ELSE 'S'
            END
        )
    )                                                 AS 'Security Profile Code',
    dbo.TIDY('No')                                    AS 'AD Linked',
    dbo.TIDY('')                                      AS 'AD Domain'
FROM
    Staff s WHERE s.UserLeft = 0
GO
