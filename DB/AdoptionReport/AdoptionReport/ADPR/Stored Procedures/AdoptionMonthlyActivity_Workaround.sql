CREATE PROCEDURE ADPR.AdoptionMonthlyActivity_Workaround

AS

BEGIN

	BEGIN TRY   
   
    BEGIN TRANSACTION

		--Duplicate Deletion
		DECLARE @CreatedDate DATE = FORMAT(GETDATE(),'yyyy-MM-dd')
		DECLARE @Count INT=0
		DECLARE @i INT=1
		
		CREATE TABLE Duplicate(
		ID INT IDENTITY (1,1),
		EsaProjectId NVARCHAR(50),
		)
		
		INSERT INTO Duplicate
		SELECT EsaProjectid FROM [AdoptionReport].[ADPR].[Project_Compliance_Monthly] WHERE CONVERT(DATE,[Created datetime])= @CreatedDate
		GROUP BY EsaProjectid HAVING COUNT(*) >1
		
		--SELECT * FROM Duplicate
		
		SET @Count= (SELECT COUNT(*) FROM Duplicate)
		
		WHILE (@Count > 0)
		
		BEGIN
		
		DELETE FROM [AdoptionReport].[ADPR].[Project_Compliance_Monthly] WHERE ID IN (
		SELECT MAX(A.ID) FROM [AdoptionReport].[ADPR].[Project_Compliance_Monthly] A JOIN Duplicate B 
		ON A.EsaProjectid = B.EsaProjectid WHERE B.EsaProjectid IN (SELECT EsaProjectid FROM Duplicate WHERE ID=@i)
		)
		
		SET @i = @i+1
		SET @Count = @Count-1
		
		END
		
		DROP TABLE Duplicate


		--Data Merge to ADP Monthly Table
		INSERT INTO [ADP].[Project_Compliance_Monthly] (Parent_Accountid
		,[Parent_AccountName]
		,[EsaProjectid]
		,[ProjectName]
		,[SBU]
		,[PO ID]
		,[PO Name]
		,[DM ID]
		,[DM Name]
		,[PM ID]
		,[PM Name]
		,[Project_Department]
		,[DE_Inscope]
		,[AVM #FTE]
		,[Overall #FTE with TSC %=0]
		,[Overall #FTE with TSC %>0 to 25]
		,[Overall #FTE with TSC %>25 to 50]
		,[Overall #FTE with TSC %>50 to 80]
		,[Overall #FTE with TSC %>80]
		,[AVM #FTE with TSC %>80]
		,[Available Hours]
		,[Available Hours AVM]
		,[Actual Effort]
		,[Actual Effort_AVM]
		,[Effort Project Compliance% (All)]
		,[Associate_Project_Compliance_Percent]
		,[Effort Project Compliance% (AVM)]
		,[AVM Associate_Project_Compliance_Percent]
		,[Startdate]
		,[Enddate]
		,[Created datetime]
		,[MARKETUNITNAME]) 
		SELECT Parent_Accountid
		,[Parent_AccountName]
		,[EsaProjectid]
		,[ProjectName]
		,[SBU]
		,[PO ID]
		,[PO Name]
		,[DM ID]
		,[DM Name]
		,[PM ID]
		,[PM Name]
		,[Project_Department]
		,[DE_Inscope]
		,[AVM #FTE]
		,[Overall #FTE with TSC %=0]
		,[Overall #FTE with TSC %>0 to 25]
		,[Overall #FTE with TSC %>25 to 50]
		,[Overall #FTE with TSC %>50 to 80]
		,[Overall #FTE with TSC %>80]
		,[AVM #FTE with TSC %>80]
		,[Available Hours]
		,[Available Hours AVM]
		,[Actual Effort]
		,[Actual Effort_AVM]
		,[Effort Project Compliance% (All)]
		,[Associate_Project_Compliance_Percent]
		,[Effort Project Compliance% (AVM)]
		,[AVM Associate_Project_Compliance_Percent]
		,[Startdate]
		,[Enddate]
		,[Created datetime]
		,[MARKETUNITNAME] FROM [ADPR].[Project_Compliance_Monthly] WHERE CONVERT(DATE,[Created datetime])=FORMAT(GETDATE(),'yyyy-MM-dd')

	COMMIT TRANSACTION

		--DECLARE @MailSubject VARCHAR(MAX);      
		--DECLARE @MailBody  VARCHAR(MAX);    
		      
		--SELECT @MailSubject = CONCAT(@@servername, ' AdoptionMonthlyActivity_Workaround  - Job Success Notification')    
		--SELECT @MailBody = '<font color="Black" face="Arial" Size = "2">Hi Team,<br><br>Duplicate entries got deleted and data merged to [ADP].[Project_Compliance_Monthly] table successfully!<br><br>
		--					Regards,<br>Applens Support Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>'     
		  
		--EXEC msdb.dbo.sp_send_dbmail @recipients = 'AVMCoEL1Team@cognizant.com;AVMDARTL2@cognizant.com',    
		--@profile_name ='ApplensSupport',    
		--@subject = @MailSubject,    
		--@body = @MailBody,    
		--@body_format = 'HTML';   

	END TRY

	BEGIN CATCH    

		ROLLBACK TRANSACTION

		--DECLARE @errorMessage VARCHAR(MAX);    
		
		--SELECT @errorMessage = ERROR_MESSAGE()   
		
		--Send failure mail notification  
		--DECLARE @MailSubjectFailure VARCHAR(MAX);      
		--DECLARE @MailBodyFailure  VARCHAR(MAX);    
		      
		--SELECT @MailSubjectFailure = CONCAT(@@servername, ' AdoptionMonthlyActivity_Workaround - Job Failure Notification')    
		--SELECT @MailBodyFailure = CONCAT('<font color="Black" face="Arial" Size = "2">Hi Team, <br><br>Oops! Error occurred while deleting duplicates and merging the data to [ADP].[Project_Compliance_Monthly] table. Kindly check!<br>    
		--       <br>Error: ', @ErrorMessage,    
		--       '<br><br>Regards,<br>Applens Support Team<br><br>***Note: This is an auto generated mail. Please do not reply.***</font>')    
		  
		--EXEC msdb.dbo.sp_send_dbmail @recipients = 'AVMCoEL1Team@cognizant.com;AVMDARTL2@cognizant.com',    
		--@profile_name ='ApplensSupport',    
		--@subject = @MailSubjectFailure,    
		--@body = @MailBodyFailure,    
		--@body_format = 'HTML';     


	END CATCH    

END