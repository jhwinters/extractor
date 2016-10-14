/*
 *  Script to extract the Pupils sheet for the Pupil Data workbook.
 *
 *  Relies on the dbo.TIDY method being already installed.
 */

USE Schoolbasebak;
GO

INSERT INTO OPENROWSET('Microsoft.Ace.OLEDB.12.0', 'Excel 12.0;Database=C:\Users\JHW\iSAMS\DataTransfer\AutoXLS\Pupil Data.xls;', 'SELECT * FROM [Pupil Contacts$]')
SELECT * FROM (
  SELECT
    CONVERT(INT, ao.PupOrigNum)                         AS 'Pupil Id',
    dbo.TIDY('Home')                                    AS 'Address Type',
    dbo.TIDY(ao.Relationship1)                          AS 'Relation To Student',
    dbo.TIDY(
      CASE WHEN AdultGuardian = 1 THEN 'Y' ELSE 'N' END
            )                                           AS 'Pupils Main Home',
    dbo.TIDY(ao.AdultTitle1)                            AS 'Title',
    dbo.TIDY('')                                        AS 'Name Initials',
    dbo.TIDY(ao.AdultFirst1)                            AS 'Forename',
    dbo.TIDY('')                                        AS 'Middle Names',
    dbo.TIDY(ao.AdultSurname1)                          AS 'Surname',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 1))       AS 'Address 1',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 2))       AS 'Address 2',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 3))       AS 'Address 3',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 4))       AS 'Town',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 5))       AS 'County',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 6))       AS 'Country',
    dbo.TIDY(ao.PostCode)                               AS 'Postcode',
    dbo.TIDY(
      (
        SELECT TOP 1
          pn.Ph_PhoneNo
        FROM 
          PhoneNos pn
        WHERE 
          pn.AdultNo = ao.AdultNo
      )
    )                                                   AS 'Telephone',
    dbo.TIDY('')                                        AS 'Mobile',
    dbo.TIDY(ao.EMail2)                                 AS 'Email',
    dbo.TIDY('')                                        AS 'Fax',
    dbo.TIDY('')                                        AS 'Profession',
    dbo.TIDY('')                                        AS 'Marital Status',
    dbo.TIDY('N')                                       AS 'SOS Contact',
    dbo.TIDY('N')                                       AS 'SOS Note',
    dbo.TIDY('')                                        AS 'All Merges',
    dbo.TIDY(
      CASE WHEN FeePayer = 1 THEN 'Y' ELSE 'N' END
    )                                                   AS 'Billing Merge',
    dbo.TIDY('N')                                       AS 'Correspondence Merge',
    dbo.TIDY(
      CASE WHEN Report = 1 THEN 'Y' ELSE 'N' END
    )                                                   AS 'Report Merge',
    dbo.TIDY('N')                                       AS 'Contact Only'
  FROM
    AdultOffspring ao INNER JOIN Pupil p ON p.PupOrigNum = ao.PupOrigNum
  WHERE
    /*
     * Arguably the constraint on Ptype is unnecessary, because that's all
     * of them.  I'll leave it in for now in case we decide there are some
     * records which we don't need.
     */
    ao.AdultSurname1 <> '' AND p.PType IN (5,8,40,60,95,100,200,255)
  UNION ALL
  SELECT
    CONVERT(INT, ao.PupOrigNum)                         AS 'Pupil Id',
    dbo.TIDY('Home')                                    AS 'Address Type',
    dbo.TIDY(ao.Relationship2)                          AS 'Relation To Student',
    dbo.TIDY(
      CASE WHEN AdultGuardian = 1 THEN 'Y' ELSE 'N' END
    )                                                   AS 'Pupils Main Home',
    dbo.TIDY(ao.AdultTitle2)                            AS 'Title',
    dbo.TIDY('')                                        AS 'Name Initials',
    dbo.TIDY(ao.AdultFirst2)                            AS 'Forename',
    dbo.TIDY('')                                        AS 'Middle Names',
    dbo.TIDY(ao.AdultSurname2)                          AS 'Surname',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 1))       AS 'Address 1',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 2))       AS 'Address 2',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 3))       AS 'Address 3',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 4))       AS 'Town',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 5))       AS 'County',
    dbo.TIDY(dbo.AddressLineMax(ao.[Address], 6))       AS 'Country',
    dbo.TIDY(ao.PostCode)                               AS 'Postcode',
    dbo.TIDY(
      (
        SELECT TOP 1
          pn.Ph_PhoneNo
        FROM 
          PhoneNos pn
        WHERE 
          pn.AdultNo = ao.AdultNo
      )
    )                                                   AS 'Telephone',
    dbo.TIDY('')                                        AS 'Mobile',
    dbo.TIDY(ao.EMail2)                                 AS 'Email',
    dbo.TIDY('')                                        AS 'Fax',
    dbo.TIDY('')                                        AS 'Profession',
    dbo.TIDY('')                                        AS 'Marital Status',
    dbo.TIDY('N')                                       AS 'SOS Contact',
    dbo.TIDY('')                                        AS 'SOS Note',
    dbo.TIDY('N')                                       AS 'All Merges',
    dbo.TIDY(
      CASE WHEN FeePayer = 1 THEN 'Y' ELSE 'N' END
    )                                                   AS 'Billing Merge',
    dbo.TIDY('N')                                       AS 'Correspondence Merge',
    dbo.TIDY(
      CASE WHEN Report = 1 THEN 'Y' ELSE 'N' END
    )                                                   AS 'Report Merge',
    dbo.TIDY('N')                                       AS 'Contact Only'
  FROM
    AdultOffspring ao INNER JOIN Pupil p ON p.PupOrigNum = ao.PupOrigNum
  WHERE
    ao.AdultSurname2 <> '' AND RTRIM(LTRIM(ISNULL(AdultSurname2, ''))) <> '' AND p.PType IN (5,8,40,60,95,100,200,255)
  UNION ALL
  SELECT
    CONVERT(INT, ao.PupOrigNum)                         AS 'Pupil Id',
    dbo.TIDY('Work')                                    AS 'Address Type',
    dbo.TIDY(ao.Relationship1)                          AS 'Relation To Student',
    dbo.TIDY('N')                                       AS 'Pupils Main Home',
    dbo.TIDY(ao.AdultTitle1)                            AS 'Title',
    dbo.TIDY('')                                        AS 'Initials',
    dbo.TIDY(ao.AdultFirst1)                            AS 'Forename',
    dbo.TIDY('')                                        AS 'Middle Names',
    dbo.TIDY(ao.AdultSurname1)                          AS 'Surname',
    dbo.TIDY('')                                        AS 'Address 1',
    dbo.TIDY('')                                        AS 'Address 2',
    dbo.TIDY('')                                        AS 'Address 3',
    dbo.TIDY('')                                        AS 'Town',
    dbo.TIDY('')                                        AS 'County',
    dbo.TIDY('')                                        AS 'Country',
    dbo.TIDY('')                                        AS 'Postcode',
    dbo.TIDY(
      (
        SELECT TOP 1
          pn.Ph_PhoneNo
        FROM 
          PhoneNos pn
        WHERE 
          pn.AdultNo = ao.AdultNo
      )
    )                                                   AS 'Telephone',
    dbo.TIDY('')                                        AS 'Mobile',
    dbo.TIDY('')                                        AS 'Email',
    dbo.TIDY('')                                        AS 'Fax',
    dbo.TIDY(Occupation1)                               AS 'Profession',
    dbo.TIDY('')                                        AS 'Marital Status',
    dbo.TIDY('N')                                       AS 'SOS Contact',
    dbo.TIDY('')                                        AS 'SOS Note',
    dbo.TIDY('N')                                       AS 'All Merges',
    dbo.TIDY('N')                                       AS 'Billing Merge',
    dbo.TIDY('N')                                       AS 'Correspondence Merge',
    dbo.TIDY('N')                                       AS 'Report Merge',
    dbo.TIDY('N')                                       AS 'Contact Only'
  FROM
    AdultOffspring ao INNER JOIN Pupil p ON p.PupOrigNum = ao.PupOrigNum
  WHERE
    ao.AdultSurname1 <> '' AND RTRIM(LTRIM(ISNULL(Occupation1, ''))) <> '' AND p.PType IN (5,8,40,60,95,100,200,255)
  UNION ALL
  SELECT
    CONVERT(INT, ao.PupOrigNum)                         AS 'Pupil Id',
    dbo.TIDY('Work')                                    AS 'Address Type',
    dbo.TIDY(ao.Relationship2)                          AS 'Relation To Student',
    dbo.TIDY('N')                                       AS 'Pupils Main Home',
    dbo.TIDY(ao.AdultTitle2)                            AS 'Title',
    dbo.TIDY('')                                        AS 'Name Initials',
    dbo.TIDY(ao.AdultFirst2)                            AS 'Forename',
    dbo.TIDY('')                                        AS 'Middle Names',
    dbo.TIDY(ao.AdultSurname2)                          AS 'Surname',
    dbo.TIDY('')                                        AS 'Address 1',
    dbo.TIDY('')                                        AS 'Address 2',
    dbo.TIDY('')                                        AS 'Address 3',
    dbo.TIDY('')                                        AS 'Town',
    dbo.TIDY('')                                        AS 'County',
    dbo.TIDY('')                                        AS 'Country',
    dbo.TIDY('')                                        AS 'Postcode',
    dbo.TIDY(
      (
        SELECT TOP 1
          pn.Ph_PhoneNo
        FROM 
          PhoneNos pn
        WHERE 
          pn.AdultNo = ao.AdultNo
      )
    )                                                   AS 'Telephone',
    dbo.TIDY('')                                        AS 'Mobile',
    dbo.TIDY('')                                        AS 'Email',
    dbo.TIDY('')                                        AS 'Fax',
    dbo.TIDY(Occupation2)                               AS 'Profession',
    dbo.TIDY('')                                        AS 'Marital Status',
    dbo.TIDY('N')                                       AS 'SOS Contact',
    dbo.TIDY('')                                        AS 'SOS Note',
    dbo.TIDY('N')                                       AS 'All Merges',
    dbo.TIDY('N')                                       AS 'Billing Merge',
    dbo.TIDY('N')                                       AS 'Correspondence Merge',
    dbo.TIDY('N')                                       AS 'Report Merge',
    dbo.TIDY('N')                                       AS 'Contact Only'
  FROM
    AdultOffspring ao INNER JOIN Pupil p ON p.PupOrigNum = ao.PupOrigNum
  WHERE
    ao.AdultSurname2 <> '' AND RTRIM(LTRIM(ISNULL(Occupation2, ''))) <> '' AND p.PType IN (5,8,40,60,95,100,200,255)
) AS Data
ORDER BY
  CONVERT(INT, Data.[Pupil Id])
GO
