CREATE Procedure [ADP].[InsertAdoptionProjects] 
(  
@TVP_AssociateProjectList [ADP].[TVP_ActiveAdoptionProjectList] READONLY
)   
As  
BEGIN    
	BEGIN TRY 
		BEGIN TRANSACTION

			Declare @Jobid int
			set @Jobid = (Select Top 1 Jobid from [Appvisionlens].MAS.jobmaster where JobName='Adoption - OPL ProjectData Job' and isdeleted=0)
			
			TRUNCATE TABLE [ADP].[Associate_Projects]  

			DECLARE @StartDateTime DATETIME 
			SET @StartDateTime=GetDate()
			DECLARE @Rows int = 0
			

			--SELECT * FROM ADP.ActiveAdoptionProjectList_TVP WHERE ESAProjectID IN( '1000354115','1000243026')
			--INSERT INTO ADP.ActiveAdoptionProjectList_TVP
			--SELECT 
			--ESAProjectID
			--,ApplensScope
			--,BU
			--,MARKET
			--,IsChildProject			
			--FROM @TVP_AssociateProjectList 
			
			INSERT INTO [ADP].[Associate_Projects]  
			SELECT 
			ESAProjectID,
			BU,
			ApplensScope,
			BU,
			MARKET,
			BU,
			Case when IsChildProject =  0 then 'No' Else 'Yes' End as IsChildProject
			FROM @TVP_AssociateProjectList 

			--Less than 5 Fte Projects - Removal
			SELECT * INTO #ftecheck FROM (SELECT EsaProjectId,COUNT(AssociateID) AS [ESA Total FTE] 
			FROM [AppVisionLens].AVL.MAS_ProjectMaster A WITH (NOLOCK)
            LEFT JOIN [AppVisionLens].ESA.ProjectAssociates C WITH (NOLOCK) ON A.EsaProjectId=C.ProjectId
            WHERE A.EsaProjectId IN (SELECT EsaProjectId FROM adoptionreport.adp.Associate_Projects) AND A.IsDeleted=0 
            GROUP BY EsaProjectId HAVING COUNT(AssociateID)<5)T

		    DELETE FROM [AdoptionReport].[ADP].[Associate_Projects] WHERE EsaProjectId IN (SELECT EsaProjectId FROM #ftecheck)

			-------NEW Adoption View----------

			EXEC [ADPR].[Insert_AdoptionEligibleProjects]  

			TRUNCATE TABLE [ADPR].[Associate_Projects] 
			
			INSERT INTO [ADPR].[Associate_Projects]  

			SELECT ESAProjectID,SBU_Delivery AS BU,FinalScope,SBU_Delivery AS BU,Market,
			SBU_Delivery AS BU,'No',Client_Practice  FROM [ADPR].[AdoptionTotalEligibleProjects]
			--WHERE OnBoardStatus = 'OnBoarded'

			--Workaround --> Parent Exempted but Child is shown in the report.
			DELETE FROM [ADPR].[Associate_Projects] WHERE EsaProjectID='1000380367'

			--SELECT 
			--ESAProjectID,
			--BU AS SBU,
			--ApplensScope AS FinalScope,
			--BU AS SBU,
			--MARKET,
			--BU AS SBU,
			--Case when IsChildProject =  0 then 'No' Else 'Yes' End as IsChildProject
			--FROM @TVP_AssociateProjectList WHERE BU IS NOT NULL
			
			--Less than 5 Fte Projects - Removal
			--SELECT * INTO #ftecheckADPR FROM (SELECT EsaProjectId,COUNT(AssociateID) AS [ESA Total FTE] 
			--FROM [AppVisionLens].AVL.MAS_ProjectMaster A WITH (NOLOCK)
   --         LEFT JOIN [AppVisionLens].ESA.ProjectAssociates C WITH (NOLOCK) ON A.EsaProjectId=C.ProjectId
   --         WHERE A.EsaProjectId IN (SELECT EsaProjectId FROM adoptionreport.ADPR.Associate_Projects) AND A.IsDeleted=0 
   --         GROUP BY EsaProjectId HAVING COUNT(AssociateID)<5)T

			--DELETE FROM [AdoptionReport].[ADPR].[Associate_Projects] WHERE EsaProjectId IN (SELECT EsaProjectId FROM #ftecheckADPR)
		
			UPDATE A SET A.CHILDPROJECT = Case when T.IsChildProject =  0 then 'No' Else 'Yes' End
			FROM [ADPR].[Associate_Projects]  A
			JOIN @TVP_AssociateProjectList T ON A.EsaProjectID = T.ESAProjectID
				
			SET @Rows = @@ROWCOUNT

			INSERT INTO [Appvisionlens].MAS.JobStatus
			(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)
			VALUES(@JobID,@StartDateTime,GETDATE(),'Success',GETDATE(),0,'Adoption - OPL ProjectData Job',GETDATE(),@Rows,0,0)

COMMIT TRANSACTION
   
SELECT 'Success' AS strMessage	

END TRY  
	BEGIN CATCH 
		ROLLBACK TRANSACTION
		
			DECLARE @errorMessage VARCHAR(MAX) =  ERROR_MESSAGE();  
  
			SELECT 'Failed' AS strMessage
	
			INSERT INTO [Appvisionlens].MAS.JobStatus
			(JobId,StartDateTime,EndDateTime,JobStatus,JobRunDate,IsDeleted,CreatedBy,CreatedDate,InsertedRecordCount,DeletedRecordCount,UpdatedRecordCount)
			VALUES(@JobID,@StartDateTime,GETDATE(),'Failed',GETDATE(),0,'Adoption - OPL ProjectData Job',GETDATE(),@Rows,0,0)

			--INSERT Error      
			EXEC [Appvisionlens].DBO.AVL_InsertError '[ADP].[InsertAdoptionProjects] ',@errorMessage,'',0  
	END CATCH  
End
