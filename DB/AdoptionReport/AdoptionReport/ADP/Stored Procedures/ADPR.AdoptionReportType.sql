USE [AdoptionReport]
GO
/****** Object:  StoredProcedure [ADPR].[AdoptionReportType]    Script Date: 11/1/2023 8:17:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [ADPR].[AdoptionReportType]
AS  
BEGIN    
	BEGIN TRY   
	SET NOCOUNT ON;
	--2023-11-31 12:56:48.110

	--select DateAdd(day,2,getdate())
	DECLARE @JobType nvarchar(30)
	DECLARE @Mode nvarchar(30)
	DECLARE @Rundate INT 


	SET @Rundate = 
	SUBSTRING( CONVERT(VARCHAR(30),getdate(), 11) , 
	LEN(CONVERT(VARCHAR(30), getdate(), 11)) -  
	CHARINDEX('/',REVERSE(CONVERT(VARCHAR(30), getdate(), 11))) + 2  , 
	LEN(CONVERT(VARCHAR(30), getdate(), 11)))

	select @JobType=
	CASE
		WHEN @Rundate in (3,4) THEN 'Month'
		WHEN @Rundate = 5 THEN 'Month'
		ELSE 'Week'
		END

		select @Mode=
	CASE
		WHEN @Rundate in (3,4) THEN 'Weekly'
		WHEN @Rundate = 5 THEN 'Monthly'
		ELSE 'Weekly'
		END
		select @JobType AS JobType,@Mode AS Mode
	END TRY  
	BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(8000);  
		SELECT @ErrorMessage = ERROR_MESSAGE()  
		--INSERT Error      
		EXEC [AppVisionLens].[dbo].AVL_InsertError '[ADP].[AdoptionReportType] ', @ErrorMessage, '',''  
		RETURN @ErrorMessage  
	END CATCH     
  
END 
