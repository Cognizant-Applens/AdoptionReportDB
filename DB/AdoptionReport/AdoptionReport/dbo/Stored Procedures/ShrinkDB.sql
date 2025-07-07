

CREATE   PROCEDURE [dbo].[ShrinkDB]
  
AS
BEGIN
  ALTER DATABASE [AdoptionReport]
SET RECOVERY SIMPLE;



-- Shrink the truncated log file to 1 MB.
DBCC SHRINKFILE (AdoptionReport_log, 1);



-- Reset the database recovery model.
ALTER DATABASE [AdoptionReport]
SET RECOVERY FULL;





END