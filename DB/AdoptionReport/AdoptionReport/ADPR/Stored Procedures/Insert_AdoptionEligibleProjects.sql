CREATE PROCEDURE [ADPR].[Insert_AdoptionEligibleProjects]    
AS    
BEGIN      
BEGIN TRY                  
  

	IF OBJECT_ID(N'tempdb..#ExemptionProjects') IS NOT NULL BEGIN  DROP TABLE #ExemptionProjects END
	CREATE table #ExemptionProjects    
	(    
	ESAProjectID VARCHAR(100)  
	)    
        
	INSERT INTO #ExemptionProjects    
	SELECT DISTINCT PM.EsaProjectID           
	FROM SmartGovernance.[dbo].[ApplensExemptionDetails](NOLOCK) ED             
	LEFT JOIN SmartGovernance. [MAS].[ExemptionReason](NOLOCK) ER ON ED.ReasonID = ER.ID    
	LEFT JOIN SmartGovernance.[dbo].ModuleExemptionDetails(NOLOCK) ME ON ME.ApplensExemptionID = ED.ID            
	INNER JOIN [AppvisionLens].AVL.MAS_ProjectMaster(NOLOCK) PM ON ED.AccessLevelID = PM.EsaProjectID           
	WHERE (
	ED.OptedFor='Exemption' AND ED.Status='Approved' AND ED.IsDeleted='0')
	OR (ME.ModuleId=4 AND ME.OptedFor='Exemption' AND ME.Status='Approved' AND ME.IsDeleted=0)  

	IF OBJECT_ID(N'tempdb..#OnboardedProjects') IS NOT NULL BEGIN DROP TABLE #OnboardedProjects END    
	CREATE TABLE #OnboardedProjects    (ESAProjectID nvarchar(50))  
       
	INSERT INTO #OnboardedProjects
	select distinct  a.EsaProjectId
	from [AppVisionLens].avl.mas_projectmaster(nolock) a join   
	[AppVisionLens].[AVL].[PRJ_ConfigurationProgress](nolock)b on a.projectid=b.projectid  
	--join [ADPR].[VW_Applens_OPL_Adoption_Eligible_projects](NOLOCK) c on c.EsaProjectId=a.EsaProjectID  
	where b.ScreenID=4 and b.CompletionPercentage=100  
	--AND c.EsaProjectId NOT IN
	--(
	--	SELECT EsaProjectID FROM #ExemptionProjects
	--)
	--=============================================================================
	IF OBJECT_ID(N'tempdb..#OBP') IS NOT NULL BEGIN  DROP TABLE #OBP END

	select EsaProjectId,ESAProjectName,AccountId,AccountName,Market,b.SBU_Delivery,Archetype,FinalScope,
	[DEx Assessment feasibility flag],[Esa Project Category],IsPerformanceSharingRestricted,[3x3 Matrix],'OnBoarded' As OnBoardStatus,a.Client_Practice  --,Total_FTE  
	INTO #OBP
	from [AppVisionLens].[dbo].[ADM_OPLMasterData](NOLOCK) a left join  
	[AppVisionLens].dbo.geomapping(nolock) b on a.AccountId=b.ESA_AccountID  AND a.Client_Practice=b.Client_Practice
	where 
	FinalScope ='In scope' AND (A.ProjectOwningUnit LIKE 'ADM%' OR A.ProjectOwningUnit LIKE 'DE %')
	AND EsaProjectId not in (select projectID from [OneAVMChargeback].[OAC].[OnpremMaster] where isdeleted=0)
	--AND A.AccountId not in (select AccountId from ADPR.[AdoptionNonEligibleAccounts] where IsAdoptionEligible = 0)

	--AND AccountName NOT LIKE '%Walgreens%'
	--AND AccountName NOT LIKE '%CVS Pharmacy%'
	--AND AccountName NOT LIKE '%Cargill%'
	--AND AccountName NOT LIKE '%Mapfre%'
	--AND AccountName NOT LIKE '%The Travelers Indemnity%'
	--AND AccountName NOT LIKE '%Medtronic%'
	----AND AccountName NOT LIKE '%Health Care Service%'
	--AND AccountName NOT LIKE '%CNO Services%'
	--AND AccountName NOT LIKE '%Consolidated Edison%'
	--AND AccountName NOT LIKE '%Centrica%'
	--AND AccountName NOT LIKE '%CC Services%'

	AND IsPerformanceSharingRestricted =0 
	AND b.SBU_Delivery IS NOT NULL
	--AND b.SBU_Delivery  = 'HC-NA'
	AND EsaProjectId NOT IN
	(
		SELECT EsaProjectID FROM #ExemptionProjects
	)
	AND EsaProjectId IN
	(
		SELECT EsaProjectID FROM #OnboardedProjects --WHERE SBU = 'HC-NA' 
	)
	AND EsaProjectId IN   
	(  
	SELECT DISTINCT EsaProjectId FROM  [AppVisionLens].AVL.MAS_ProjectMaster A  
	LEFT JOIN  [AdoptionReport].[Adp].[CentralRepository_ActiveAllocations] C ON A.EsaProjectId=C.Project_ID  
	WHERE A.IsDeleted=0   
	GROUP BY EsaProjectId  
	HAVING COUNT(Associate_ID) >= 5   
	)  

	--#OBP_OnpremEligible
	--select EsaProjectId,ESAProjectName,AccountId,AccountName,Market,b.SBU_Delivery,Archetype,FinalScope,
	--[DEx Assessment feasibility flag],[Esa Project Category],IsPerformanceSharingRestricted,[3x3 Matrix],'OnBoarded' As OnBoardStatus  --,Total_FTE  
	--INTO #OBP_OnpremEligible
	-- from [AppVisionLens].[dbo].[ADM_OPLMasterData](NOLOCK) a left join  
	--[AppVisionLens].dbo.geomapping(nolock) b on a.AccountId=b.ESA_AccountID  
	--where 
	--FinalScope ='In scope'  
	--AND EsaProjectId IN ('1000280452','1000362103','1000357418') 
	--AND IsPerformanceSharingRestricted =0 
	--AND b.SBU_Delivery IS NOT NULL
	----AND b.SBU_Delivery  = 'HC-NA'
	--AND EsaProjectId NOT IN
	--(
	--	SELECT EsaProjectID FROM #ExemptionProjects
	--)
	--AND EsaProjectId IN
	--(
	--	SELECT EsaProjectID FROM #OnboardedProjects --WHERE SBU = 'HC-NA' 
	--)
	--AND EsaProjectId IN   
	--(  
	--SELECT DISTINCT EsaProjectId FROM  [AppVisionLens].AVL.MAS_ProjectMaster A  
	--LEFT JOIN  [AdoptionReport].[Adp].[CentralRepository_ActiveAllocations] C ON A.EsaProjectId=C.Project_ID  
	--WHERE A.IsDeleted=0   
	--GROUP BY EsaProjectId  
	--HAVING COUNT(Associate_ID) >= 5   
	--)  


	IF OBJECT_ID(N'tempdb..#NOBP') IS NOT NULL BEGIN  DROP TABLE #NOBP END

	select EsaProjectId,ESAProjectName,AccountId,AccountName,Market,b.SBU_Delivery,Archetype,FinalScope,
	[DEx Assessment feasibility flag],[Esa Project Category],IsPerformanceSharingRestricted,[3x3 Matrix],'YetToOnBoarded' As OnBoardStatus,a.Client_Practice  --,Total_FTE  
	INTO #NOBP
	from [AppVisionLens].[dbo].[ADM_OPLMasterData](NOLOCK) a left join  
	[AppVisionLens].dbo.geomapping(nolock) b on a.AccountId=b.ESA_AccountID AND a.Client_Practice=b.Client_Practice
	where 
	FinalScope ='In scope' AND  (A.ProjectOwningUnit LIKE 'ADM%' OR A.ProjectOwningUnit LIKE 'DE %')
	and EsaProjectId not in (select projectID from [OneAVMChargeback].[OAC].[OnpremMaster] where isdeleted=0)
	--AND A.AccountId not in (select AccountId from ADPR.[AdoptionNonEligibleAccounts] where IsAdoptionEligible = 0)

	--AND AccountName NOT LIKE '%Walgreens%'
	--AND AccountName NOT LIKE '%CVS Pharmacy%'
	--AND AccountName NOT LIKE '%Cargill%'
	--AND AccountName NOT LIKE '%Mapfre%'
	--AND AccountName NOT LIKE '%The Travelers Indemnity%'
	--AND AccountName NOT LIKE '%Medtronic%'
	----AND AccountName NOT LIKE '%Health Care Service%'
	--AND AccountName NOT LIKE '%CNO Services%'
	--AND AccountName NOT LIKE '%Consolidated Edison%'
	--AND AccountName NOT LIKE '%Centrica%'
	--AND AccountName NOT LIKE '%CC Services%'

	AND IsPerformanceSharingRestricted =0 
	AND b.SBU_Delivery IS NOT NULL
	--AND b.SBU_Delivery  = 'HC-NA'
	AND [3x3 Matrix] <> ('[1,1]') 
	and [Esa Project Category]<>'staff aug'   
	AND ([DEx Assessment feasibility flag] ='Yes' OR ISNULL([DEx Assessment feasibility flag],'') = '')
	and Archetype='Enhancement and support'
	AND EsaProjectId NOT IN
	(
		SELECT EsaProjectID FROM #ExemptionProjects
	)
	AND EsaProjectId NOT IN
	(
		SELECT EsaProjectID FROM #OnboardedProjects --WHERE SBU = 'HC-NA' 
	)
	AND EsaProjectId IN   
	(  
	SELECT DISTINCT EsaProjectId FROM  [AppVisionLens].AVL.MAS_ProjectMaster A  
	LEFT JOIN  [AdoptionReport].[Adp].[CentralRepository_ActiveAllocations] C ON A.EsaProjectId=C.Project_ID  
	WHERE A.IsDeleted=0   
	GROUP BY EsaProjectId  
	HAVING COUNT(Associate_ID) >= 5   
	)

	--#NOBP_OnpremEligible
	--select EsaProjectId,ESAProjectName,AccountId,AccountName,Market,b.SBU_Delivery,Archetype,FinalScope,
	--[DEx Assessment feasibility flag],[Esa Project Category],IsPerformanceSharingRestricted,[3x3 Matrix],'YetToOnBoarded' As OnBoardStatus  --,Total_FTE  
	--INTO #NOBP_OnpremEligible
	--from [AppVisionLens].[dbo].[ADM_OPLMasterData](NOLOCK) a left join  
	--[AppVisionLens].dbo.geomapping(nolock) b on a.AccountId=b.ESA_AccountID  
	--where 
	--FinalScope ='In scope'  
	--AND EsaProjectId IN ('1000280452','1000362103','1000357418') 
	--AND IsPerformanceSharingRestricted =0 
	--AND b.SBU_Delivery IS NOT NULL
	----AND b.SBU_Delivery  = 'HC-NA'
	--AND [3x3 Matrix] <> ('[1,1]') 
	--and [Esa Project Category]<>'staff aug'   
	--AND ([DEx Assessment feasibility flag] ='Yes' OR ISNULL([DEx Assessment feasibility flag],'') = '')
	--and Archetype='Enhancement and support'
	--AND EsaProjectId NOT IN
	--(
	--	SELECT EsaProjectID FROM #ExemptionProjects
	--)
	--AND EsaProjectId NOT IN
	--(
	--	SELECT EsaProjectID FROM #OnboardedProjects --WHERE SBU = 'HC-NA' 
	--)
	--AND EsaProjectId IN   
	--(  
	--SELECT DISTINCT EsaProjectId FROM  [AppVisionLens].AVL.MAS_ProjectMaster A  
	--LEFT JOIN  [AdoptionReport].[Adp].[CentralRepository_ActiveAllocations] C ON A.EsaProjectId=C.Project_ID  
	--WHERE A.IsDeleted=0   
	--GROUP BY EsaProjectId  
	--HAVING COUNT(Associate_ID) >= 5   
	--)


	TRUNCATE TABLE [ADPR].[AdoptionTotalEligibleProjects]

	INSERT INTO [ADPR].[AdoptionTotalEligibleProjects](
	EsaProjectId,ESAProjectName,AccountId,AccountName,Market,SBU_Delivery,Archetype,FinalScope,
	[DEx Assessment feasibility flag],[Esa Project Category],IsPerformanceSharingRestricted,[3x3 Matrix],
	OnBoardStatus,Client_Practice) 
	(
	SELECT DISTINCT EsaProjectId,ESAProjectName,AccountId,AccountName,Market,SBU_Delivery,Archetype,FinalScope,
	[DEx Assessment feasibility flag],[Esa Project Category],IsPerformanceSharingRestricted,[3x3 Matrix],
	OnBoardStatus,Client_Practice FROM #OBP
	UNION
	SELECT DISTINCT EsaProjectId,ESAProjectName,AccountId,AccountName,Market,SBU_Delivery,Archetype,FinalScope,
	[DEx Assessment feasibility flag],[Esa Project Category],IsPerformanceSharingRestricted,[3x3 Matrix],
	OnBoardStatus,Client_Practice  FROM #NOBP
	--UNION
	--SELECT DISTINCT EsaProjectId,ESAProjectName,AccountId,AccountName,Market,SBU_Delivery,Archetype,FinalScope,
	--[DEx Assessment feasibility flag],[Esa Project Category],IsPerformanceSharingRestricted,[3x3 Matrix],
	--OnBoardStatus  FROM #OBP_OnpremEligible
	--UNION
	--SELECT DISTINCT EsaProjectId,ESAProjectName,AccountId,AccountName,Market,SBU_Delivery,Archetype,FinalScope,
	--[DEx Assessment feasibility flag],[Esa Project Category],IsPerformanceSharingRestricted,[3x3 Matrix],
	--OnBoardStatus  FROM #NOBP_OnpremEligible
	)

	DROP TABLE #OBP
	DROP TABLE #NOBP
	--DROP TABLE #OBP_OnpremEligible
	--DROP TABLE #NOBP_OnpremEligible

END TRY    
BEGIN CATCH    
     
	DECLARE @ErrorMessage NVARCHAR(4000);    
	DECLARE @ErrorSeverity INT;    
	DECLARE @ErrorState INT;    
     
	SELECT     
	@ErrorMessage = ERROR_MESSAGE(),    
	@ErrorSeverity = ERROR_SEVERITY(),    
	@ErrorState = ERROR_STATE();  
    
	-- Use RAISERROR inside the CATCH block to return error    
	-- information about the original error that caused    
	-- execution to jump to the CATCH block.    
	RAISERROR (@ErrorMessage, -- Message text.    
	@ErrorSeverity, -- Severity.    
	@ErrorState -- State.    
	);    
     
	END CATCH    
     
END