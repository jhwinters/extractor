/*
 *  Script to extract the Pupils sheet for the Pupil Data workbook.
 *
 *  Relies on the dbo.TIDY method being already installed.
 */
USE Schoolbasebak;
GO
INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Pupil Data.xls;', 'SELECT * FROM [Pupils$]')
SELECT
  dbo.TIDY(PupOrigNum)                                  AS 'Id',
  dbo.TIDY(PupUPN)                                      AS 'UPN',
  dbo.TIDY(PupULN)                                      AS 'ULN',
  dbo.TIDY(PupADSname)                                  AS 'AD Username',
  dbo.TIDY(Pu_CandNo)                                   AS 'Exam Candidate Number',
  dbo.TIDY(PupUCI)                                      AS 'Exam UCI Number',
  dbo.TIDY(
    CASE WHEN Pu_Gender IN ('M', 'm') THEN 'Mr' ELSE 'Miss' END) AS 'Title',
  dbo.TIDY('')                                          AS 'Name Initials',
  dbo.TIDY(Pu_Firstname)                                AS 'Forename',
  dbo.TIDY(PupSecondName) + ' ' + dbo.TIDY(PupThirdName) AS 'Middle Names',
  dbo.TIDY(Pu_Surname)                                  AS 'Surname',
  /*
   * This next one is spelled wrongly, but that's how it is in the iSAMS spreadsheet.
   */
  dbo.TIDY(Pu_GivenName)                                AS 'Preffered Name',
  dbo.TIDY(CONVERT(NVARCHAR(10), Pu_Dob, 103))          AS 'DOB',
  dbo.TIDY(UPPER(Pu_Gender))                            AS 'Gender',
  dbo.TIDY('')                                          AS 'Country of Residence',
  dbo.TIDY(
    (SELECT Nationality FROM Nationality
                        WHERE p.NatIdent = Nationality.NatIdent)
	  )                                             AS 'Nationality',
  dbo.TIDY(
    (SELECT [Language] FROM [Language]
                       WHERE p.LanIdent = [Language].LanIdent)
	  )                                             AS 'Language',
  dbo.TIDY(
    (SELECT Religion FROM Rel WHERE p.RelIdent = Rel.RelIdent)
          )                                             AS 'Religion',
  dbo.TIDY(
    (SELECT Ethnicity FROM Ethnicity WHERE p.EthIdent = Ethnicity.EthIdent)
          )                                             AS 'Ethnic Group',    
  dbo.TIDY('')                                          AS 'Birth Place',
  dbo.TIDY('')                                          AS 'Birth County',
  dbo.TIDY('')                                          AS 'Birth Country',
  dbo.TIDY('')                                          AS 'Diplomatic And Forces',
  dbo.TIDY(
    SELECT NCYear FROM (
       (SELECT YearDesc AS NCYear
       FROM Years
       WHERE Years.YearIdent = p.YearIdent AND YearName NOT LIKE '%Prep%')
       UNION ALL
       (SELECT CONVERT(INT, YearDesc) + 20 as NCYear
       FROM Years
       WHERE Years.YearIdent = p.YearIdent AND YearName LIKE '%Prep%')
     )                                             AS 'NC Year',    
  dbo.TIDY(
    (SELECT Class.ClassName FROM Class WHERE Class.ClassIdent = p.ClassIdent)
          )                                             AS 'Form/Tutor Group',
  dbo.TIDY(dbo.StaffMnem(UserIdent))                    AS 'Tutor',
  dbo.TIDY(
    (SELECT HouseName FROM House WHERE p.HouseIdent = House.HouseIdent)
          )                                             AS 'Academic House',
  dbo.TIDY(Pu_PSHouse)                                  AS 'Boarding House',
  dbo.TIDY('')                                          AS 'Enquiry Date',
  dbo.TIDY('')                                          AS 'Enquiry Type',
  dbo.TIDY('')                                          AS 'Admissions Date',
  dbo.TIDY(
    (SELECT StageName FROM StageOfProspect s
                      WHERE s.StageOfProspect = p.StageOfProspect AND
		            p.PType = 5)
	  )                                             AS 'Admissions Status',
  dbo.TIDY(
    CONVERT(NVARCHAR(10), PupProposedDateIn, 103)
          )                                             AS 'Enrolment Date',
  dbo.TIDY(
    (SELECT Years.YearDesc FROM Years
                           WHERE Years.YearIdent = p.PupProposedYear)
	  )                                             AS 'Enrolment NC Year',
  dbo.TIDY('')                                          AS 'Enrolment Term Name',
  dbo.TIDY('')                                          AS 'Enrolment Form',
  dbo.TIDY('')                                          AS 'Enrolment Academic House',
  dbo.TIDY('')                                          AS 'Enrolment Boarding House',
  dbo.TIDY(Pu_LastSchoolId)                             AS 'Previous School Code',
  dbo.TIDY('')                                          AS 'Leaving Date',
  dbo.TIDY('')                                          AS 'Leaving Reason',
  dbo.TIDY('')                                          AS 'Leaving NC Year',
  dbo.TIDY('')                                          AS 'Leaving Term Name',
  dbo.TIDY('')                                          AS 'Leaving Form',
  dbo.TIDY('')                                          AS 'Leaving Academic House',
  dbo.TIDY('')                                          AS 'Leaving Boarding House',
  dbo.TIDY('')                                          AS 'Exam Candidate Surname',
  dbo.TIDY('')                                          AS 'Exam Candidate Forenames',
  dbo.TIDY(PupEmail)                                    AS 'School Email Address',
  dbo.TIDY(PupMobile)                                   AS 'Mobile Number',
  dbo.TIDY(
    (SELECT BoarderType.BoarderType
       FROM BoarderType
      WHERE BoarderType.BoarderIdent = p.BoarderIdent)
          )                                             AS 'School Status',
  dbo.TIDY(
    CASE
      WHEN p.PType IN (40,60,95) THEN 1
      WHEN p.PType IN (5,8) THEN 0
      WHEN p.PType IN (100,200,255) THEN -1
    END)                                                AS 'System Status'
  
FROM
    Pupil p
WHERE 
    p.PType IN (5,8,40,60,95,100,200,255)
ORDER BY
    (SELECT Years.YearDesc FROM Years WHERE Years.YearIdent = p.YearIdent), p.PupOrigNum
GO
