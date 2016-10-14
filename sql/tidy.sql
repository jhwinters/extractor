/*
 *  This script simply creates a function for use by all the other
 *  scripts.  It deletes the function first if it exists already.
 */

USE Schoolbasebak;
GO

IF OBJECT_ID(N'dbo.TIDY', N'FN') IS NOT NULL
DROP FUNCTION dbo.TIDY;
GO

CREATE FUNCTION TIDY(@string NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
BEGIN
  RETURN (
    CASE WHEN @string IS NULL THEN
      ''
    ELSE
      LTRIM(RTRIM(@string))
    END
	 )
END
GO
