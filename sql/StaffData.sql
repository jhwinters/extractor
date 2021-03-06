
/*
 * Script to extract Staff data from SB.  Relies on the TIDY function having been
 * set up already.
 */

USE SchoolBasebak
GO

/*
    Staff Details
*/

INSERT INTO OPENROWSET(
    'Microsoft.Ace.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Staff Data.xls;',
    'SELECT * FROM [Staff$]')
SELECT
    dbo.TIDY(UserIdent)                                    AS 'Id',
    dbo.TIDY(UserMnemonic)                                 AS 'Code',
    dbo.TIDY(UserTitle)                                    AS 'Title',
    dbo.TIDY(UserMnemonic)                                 AS 'Name Initials',
    dbo.TIDY(UserForename)                                 AS 'Forename',
    dbo.TIDY(UserMiddle)                                   AS 'Middle Names',
    dbo.TIDY(UserSurname)                                  AS 'Surname',
    dbo.TIDY(CASE WHEN UserPrefName IS NULL THEN UserForename ELSE UserPrefName END)
                                                           AS 'PrefferedName',
    dbo.TIDY(CONVERT(NVARCHAR(10), UserDOB, 103))          AS 'DOB',
    dbo.TIDY(UserGender)                                   AS 'Gender',
    dbo.TIDY('')                                           AS 'Country of Residence',
    dbo.TIDY(
        (SELECT Nationality FROM Nationality WHERE s.NatIdent = Nationality.NatIdent)
    )                                                      AS 'Nationality',
    dbo.TIDY('')                                           AS 'Language',
    dbo.TIDY((SELECT Religion FROM Rel WHERE s.RelIdent = Rel.RelIdent))
                                                           AS 'Religion',
    dbo.TIDY('')                                           AS 'Ethnic Group',
    dbo.TIDY(CONVERT(NVARCHAR(10), UserDateJoin, 103))     AS 'Enrolment Date',
    dbo.TIDY('')                                           AS 'Previous School ID',
    dbo.TIDY(UserDateLeft)                                 AS 'Leaving Date',
    dbo.TIDY(UserLeftReason)                               AS 'Leaving Reason',
    dbo.TIDY('')                                           AS 'Future School ID',
    dbo.TIDY(UserEmail)                                    AS 'School Email Address',
    dbo.TIDY(UserDD)                                       AS 'School Telephone Number',
    dbo.TIDY(
      (SELECT CASE WHEN EXISTS(SELECT 1 FROM tutorgroup t WHERE UserIdent = s.UserIdent) THEN 'Yes' ELSE 'No' END)
    )                                                      AS 'Personal Tutor',
    dbo.TIDY(UserTeach)                                    AS 'Teaching Staff',
    dbo.TIDY(CASE WHEN UserFullTime = 1 THEN 0 ELSE 1 END) AS 'Part Time',
    dbo.TIDY(CASE WHEN UserLeft = 0 THEN 1 ELSE -1 END)    AS 'System Status'
FROM
    Staff s
GO

INSERT INTO OPENROWSET(
    'Microsoft.Ace.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Staff Data.xls;',
    'SELECT * FROM [Staff Contacts$]')
SELECT
    dbo.TIDY(UserIdent)                                    AS 'Staff Id',
    dbo.TIDY('Home')                                       AS 'Contact Type',
    dbo.TIDY('Self')                                       AS 'Relation Type',
    dbo.TIDY(UserTitle)                                    AS 'Title',
    dbo.TIDY(UserMnemonic)                                 AS 'Initials',
    dbo.TIDY(UserForename)                                 AS 'Forename',
    dbo.TIDY(UserMiddle)                                   AS 'Middle Names',
    dbo.TIDY(UserSurname)                                  AS 'Surname',
    dbo.TIDY(dbo.AddressLineMax(UserHomeAdP1, 1))          AS 'Address 1',
    /*
     *  Only want line 2 if there are 2 non-blank lines after it.
     */
    dbo.TIDY(
        CASE
            WHEN
                dbo.AddressLineMax(UserHomeAdP1, 4) <> '' AND
                dbo.AddressLineMax(UserHomeAdP1, 3) <> ''
            THEN
                dbo.AddressLineMax(UserHomeAdP1, 2)
            ELSE
                ''
        END)                                               AS 'Address 2',
    /*
     *  Likewise.
     */
    dbo.TIDY(
        CASE
            WHEN
                dbo.AddressLineMax(UserHomeAdP1, 5) <> '' AND
                dbo.AddressLineMax(UserHomeAdP1, 4) <> ''
            THEN
                dbo.AddressLineMax(UserHomeAdP1, 3)
            ELSE
                ''
        END)                                               AS 'Address 3',
    /*
     *  Assume penultimate line of address is the town.
     */
    dbo.TIDY(
        CASE
            WHEN
                dbo.AddressLineMax(UserHomeAdP1, 5) = '' AND
                dbo.AddressLineMax(UserHomeAdP1, 4) = '' AND
                dbo.AddressLineMax(UserHomeAdP1, 3) <> ''
            THEN dbo.AddressLineMax(UserHomeAdP1, 2)
            WHEN
                dbo.AddressLineMax(UserHomeAdP1, 5) = '' AND
                dbo.AddressLineMax(UserHomeAdP1, 4) <> ''
            THEN dbo.AddressLineMax(UserHomeAdP1, 3)
            ELSE dbo.AddressLineMax(UserHomeAdP1, 4)
        END)                                               AS 'Town',
    /*
     *  And that the final line is the county.
     */
    dbo.TIDY(
        CASE
            WHEN
                dbo.AddressLineMax(UserHomeAdP1, 5) = '' AND
                dbo.AddressLineMax(UserHomeAdP1, 4) = '' AND
                dbo.AddressLineMax(UserHomeAdP1, 3) <> ''
            THEN dbo.AddressLineMax(UserHomeAdP1, 3)
            WHEN
                dbo.AddressLineMax(UserHomeAdP1, 5) = '' AND
                dbo.AddressLineMax(UserHomeAdP1, 4) <> ''
            THEN dbo.AddressLineMax(UserHomeAdP1, 4)
            ELSE dbo.AddressLineMax(UserHomeAdP1, 3)
        END)                                               AS 'County',
    dbo.TIDY('')                                           AS 'Country',
    dbo.TIDY(UserHomeAdP2)                                 AS 'Postcode',
    dbo.TIDY(UserHomeTel)                                  AS 'Telephone',
    dbo.TIDY(UserFax)                                      AS 'Fax',
    dbo.TIDY(UserMob)                                      AS 'Mobile',
    dbo.TIDY(UserEmail)                                    AS 'Email'
FROM
    Staff s
GO


/*
    Staff Notes
*/
INSERT INTO OPENROWSET(
    'Microsoft.Ace.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Staff Data.xls;',
    'SELECT * FROM [Notes$]')
SELECT 
    UserIdent        AS 'Staff Id', 
    'General'        AS 'Type', 
    UserNote         AS 'Body' 
FROM 
    Staff
WHERE
    UserNote IS NOT NULL
UNION ALL
SELECT
    UserIdent             AS 'Staff Id',
    'Qualifications'      AS 'Type',
    LEFT(UserQualif, 255) AS 'Body'
FROM
    Staff
WHERE
    UserQualif IS NOT NULL

/*
 *  Absence types.
 */
INSERT INTO OPENROWSET(
    'Microsoft.Ace.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Staff Data.xls;',
    'SELECT * FROM [Absence Types$]')
SELECT 
    StAbCovReason   AS 'Name' 
FROM 
    StAbCovReason

/*
 *  Actual absences.  Note that StaffAbsences is a view, not a table.  It combines
 *  information from StaffAbsence (which is a table) and Staff.
 */
INSERT INTO OPENROWSET(
    'Microsoft.Ace.OLEDB.12.0',
    'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Staff Data.xls;',
    'SELECT * FROM [Absence$]')
SELECT DISTINCT
    dbo.TIDY(UserIdent)                              AS 'Staff Id',
    dbo.TIDY(StAbCovReason)                          AS 'Absence Type',
    dbo.TIDY(CONVERT(NVARCHAR(10), StartDay, 103))   AS 'Start Date',
    dbo.TIDY(CONVERT(NVARCHAR(10), EndDay, 103))     AS 'End Date',
    dbo.TIDY('')                                     AS 'Notes'
FROM 
    StaffAbsences
