CREATE PROCEDURE [ADPR].[NonADM_ACCOUNT_PROJECT_SUMMARY_RAW]     
(      
@startdate datetime,      
@endDate datetime,      
@mode varchar(200),    
@ReportType nvarchar(100)  
)       
As      
BEGIN        
BEGIN TRY       
  SET NOCOUNT ON;       
      
--Read Me   
SELECT  REPLACE([Column_Name], 'ADM', @ReportType) AS [Column_Name],             
REPLACE([Description], 'ADM', @ReportType) AS [Description]           
FROM adp.adoption_readme

--Account Summary

DECLARE @AccountSummarySQL NVARCHAR(MAX)
SET @AccountSummarySQL = N'SELECT DISTINCT a.Parent_Accountid
	,a.Parent_AccountName AS [Parent AccountName]
	,A.Vertical,A.MARKETUNITNAME as [SBU Delivery (PC2Geo mapping)]  
    ,ISNULL(A.[Overall #FTE],0) AS [Overall #FTE]      
    ,ISNULL(B.AVM_ESA_FTE,0) AS ['+ @ReportType +' FTE]   
    ,ISNULL(A.[Overall #FTE with TSC %=0],0) AS [Overall #FTE with TSC %=0]
    ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0) AS [Overall #FTE with TSC %>0 to 25]
    ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS [Overall #FTE with TSC %>25 to 50]
    ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS [Overall #FTE with TSC %>50 to 80]
    ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS [Overall #FTE with TSC %>80] 
    ,ISNULL(B.[AVM FTE with TSC %>80],0) AS ['+ @ReportType +' FTE with TSC %>80]
    ,ISNULL(a.[Available Hours],0) AS [Available Hours (All)] 
    ,ISNULL(B.Available_Hours,0) AS [Available Hours ('+ @ReportType +')] 
    ,ISNULL(A.[Actual Effort],0) AS [Actual Effort (All)]   
    ,ISNULL(B.Actual_Effort,0) AS [Actual Effort ('+ @ReportType +')]  
    ,ISNULL(A.[Effort Account Compliance% (All)],0) AS [Account Effort Compliance% (All)]
    ,ISNULL(a.All_Associate_Compliance_Percent,0) AS [Account Associate Compliance% (All)]
    ,ISNULL(B.[Effort Account Compliance% (AVM)],0) AS [Account Effort Compliance% ('+ @ReportType +')]  
    ,ISNULL(B.AVM_Associate_Compliance_Percent,0) AS [Account Associate Compliance% ('+ @ReportType +')]        
	FROM [ADPR].[Account_Compliance] A            
	LEFT JOIN [ADPR].[Account_Compliance_AVM] B ON a.Parent_Accountid=B.Parent_Accountid AND A.vertical=B.vertical and A.MarketUnitName=B.MarketUnitName         
	JOIN [ADPR].[Input_Data_AssociateRAW]  C on a.Parent_Accountid=C.ParentAccountID --AND A.vertical=B.vertical      
	WHERE C.PracticeOwner not in (''LATAM'')'

EXEC sp_executesql @AccountSummarySQL

--Project Summary

DECLARE @ProjectSummarySQL NVARCHAR(MAX)
SET @ProjectSummarySQL = N'SELECT  DISTINCT          
    a.Parent_Accountid  AS [Parent Accountid]      
    ,a.Parent_AccountName AS [Parent AccountName]      
    ,A.EsaProjectid      
    ,A.ProjectName      
    ,A.SBU  AS [SBU Delivery (PC2Geo mapping)]  
    ,C.[PO ID] AS [SDM_ID]      
    ,C.[PO Name] AS [SDM_Name]      
    ,C.[DM ID] AS [SDD_ID]     
    ,C.[DM Name] AS [SDD_Name]     
    ,C.[PM ID] AS [PM_ID]      
    ,C.[PM Name] AS [PM_Name]      
    ,D.[SBU] AS [Project_Department]      
    ,C.DE_Inscope AS [DE_Inscope]      
    ,ISNULL(A.[Overall #FTE],0) AS [Overall #FTE]      
    ,ISNULL(B.[AVM #FTE],0) AS ['+ @ReportType +' FTE]      
    ,ISNULL(A.[Overall #FTE with TSC %=0],0) AS [Overall #FTE with TSC %=0]      
    ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0) AS [Overall #FTE with TSC %>0 to 25]      
    ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS [Overall #FTE with TSC %>25 to 50]      
    ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS [Overall #FTE with TSC %>50 to 80]      
    ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS [Overall #FTE with TSC %>80]      
    ,ISNULL(B.[AVM #FTE with TSC %>80],0) AS ['+ @ReportType +' #FTE with TSC %>80]      
    ,ISNULL(a.[Available Hours],0) AS [Available Hours (All)]      
    ,ISNULL(B.[Available Hours],0) AS [Available Hours ('+ @ReportType +')]      
    ,ISNULL(A.[Actual Effort],0) AS [Actual Effort (All)]      
    ,ISNULL(B.[Actual Effort],0) AS [Actual Effort ('+ @ReportType +')]      
    ,ISNULL(a.[Effort Project Compliance% (All)],0) AS [Project Effort Compliance% (All)]   
    ,ISNULL(a.Associate_Project_Compliance_Percent,0) AS [Project Associate Compliance% (All)]      
    ,ISNULL(B.[Effort Project Compliance% (AVM)],0) AS [Project Effort Compliance% ('+ @ReportType +')]      
    ,ISNULL(B.AVMAssociate_Project_Compliance_Percent,0) AS [Project Associate Compliance% ('+ @ReportType +')]     
	,D.[CHILDPROJECT] AS [Child_Project]     
	,C.PROJECTSCOPE          
	FROM [ADPR].[Project_Compliance] A           
	LEFT JOIN [ADPR].[Project_Compliance_AVM] B ON a.Parent_Accountid=B.Parent_Accountid AND A.SBU=B.SBU AND A.EsaProjectid=B.EsaProjectid            
	LEFT JOIN [ADPR].[Input_Data_AssociateRAW] C ON a.[EsaProjectID]=C.EsaProjectID            
	LEFT JOIN [ADPR].[input_excel_associate] D ON a.[EsaProjectID]=D.EsaProjectID             
	WHERE C.DE_Inscope IN(''In scope'',''Yet to scope'')  and A.SBU not in (''LATAM'')'

EXEC sp_executesql @ProjectSummarySQL

--Associate Summary    
             
SELECT DISTINCT              
      A.SBU  AS 'SBU Delivery (PC2Geo mapping)'      
     ,A.Vertical        
     ,A.[Parent Accountid]        
     ,A.[Parent AccountName]        
     ,A.[EsaProjectID]        
     ,A.Projectname        
     ,A.EmployeeID        
     ,A.EmployeeName        
     ,A.Department_Name        
     ,ISNULL(A.[AvaialbleFTE Below_M],0) As 'Associate Allocation(In FTE)'        
     ,ISNULL(A.[Available Hours],0) AS 'Available Hours'        
     ,ISNULL(A.[MPS Effort],0) AS 'MPS Effort'        
     ,ISNULL(A.[WorkProfile AD Effort],0) AS 'WorkProfile AD Effort'       
     ,ISNULL(A.[MAS Effort],0) AS 'AD & MAS Effort'        
     ,ISNULL(A.[Actual Effort],0) AS 'Actual Effort'        
     ,ISNULL(A.[Associate Compliance %],0) AS 'Effort TS Compliance%'        
     ,A.jobcode as 'JobCode'        
     ,A.[Designation]        
     ,B.DE_Inscope        
     ,B.[PO ID] as 'SDM_ID'        
     ,B.[PO Name] As 'SDM_Name'        
     ,B.[DM ID] as 'SDD_ID'        
     ,B.[DM Name] as 'SDD_Name'        
     ,B.[PM ID] as 'PM_ID'        
     ,B.[PM Name] As 'PM_Name'        
     ,c.[SBU] AS 'Project Department' into #AssociateSummary4       
     FROM [ADPR].[Associate_Compliance_RAW] A      
left JOIN [ADPR].[Input_Data_AssociateRAW] B ON a.[EsaProjectID]=b.EsaProjectID         
left join [ADPR].[input_excel_associate] C ON a.[EsaProjectID]=C.EsaProjectID         
where A.SBU not in ('LATAM')      
    
----GradeEquivalent Logic    
--SELECT DISTINCT A.Grade,Grade_Equivalent,JobCode INTO #GradeEqi    
--FROM [$(AppVisionLens)].ESA.Associates A     
--JOIN [$(AppVisionLens)].[dbo].[Grade_Equivalent] B ON A.Grade=B.Grade    
    
--UPDATE #GradeEqi SET Grade_Equivalent=    
--CASE WHEN Grade_Equivalent='A & eqvt' THEN 'A'    
--WHEN Grade_Equivalent='AD & eqvt' THEN 'AD'    
--WHEN Grade_Equivalent='Admin Staff & eqvt' THEN 'Admin Staff'    
--WHEN Grade_Equivalent='AVP & eqvt' THEN 'AVP'    
--WHEN Grade_Equivalent='D & eqvt' THEN 'D'    
--WHEN Grade_Equivalent='M & eqvt' THEN 'M'    
--WHEN Grade_Equivalent='P & eqvt' THEN 'P'    
--WHEN Grade_Equivalent='PA & eqvt' THEN 'PA'    
--WHEN Grade_Equivalent='PAT & eqvt' THEN 'PAT'    
--WHEN Grade_Equivalent='PT & eqvt' THEN 'PT'     
--WHEN Grade_Equivalent='SA & eqvt' THEN 'SA'    
--WHEN Grade_Equivalent='SM & eqvt' THEN 'SM'    
--WHEN Grade_Equivalent='SA & eqvt' THEN 'SA'    
--WHEN Grade_Equivalent='Sr. Dir. & Eqvt' THEN 'Sr. Dir.'    
--WHEN Grade_Equivalent='TDC STP & eqvt' THEN 'TDC STP'    
--WHEN Grade_Equivalent='VP & eqvt' THEN 'VP'    
--ELSE Grade_Equivalent END    
    
select DISTINCT [SBU Delivery (PC2Geo mapping)],      
[Vertical],      
[Parent Accountid],      
[Parent AccountName],      
[EsaProjectID],      
[Projectname],      
[EmployeeID],      
[EmployeeName],      
[Department_Name],      
[Associate Allocation(In FTE)],      
[Available Hours],      
[MPS Effort],      
[WorkProfile AD Effort],      
[AD & MAS Effort],      
[Actual Effort],      
CASE WHEN [Associate Allocation(In FTE)]=0 AND [Available Hours]=0 THEN CONVERT(nvarchar,'NA')      
ELSE      
CONVERT(NVARCHAR,[Effort TS Compliance%])      
END AS '[Effort TS Compliance%]',      
A.[JobCode],    
--Grade_Equivalent,    
[Designation],      
[DE_Inscope],      
[SDM_ID],      
[SDM_Name],      
[SDD_ID],      
[SDD_Name],      
[PM_ID],      
[PM_Name],      
[Project Department] from #AssociateSummary4 A --JOIN #GradeEqi G ON A.JobCode=G.JobCode          
      
--Associate Allocation  

SELECT DISTINCT           
   SBU  AS 'SBU Delivery (PC2Geo mapping)'    
   ,Vertical      
   ,Project_ID AS 'ESAProjectid'      
   ,[Project Name] As 'Project Name'      
   , Associate_id As 'Employee id'      
   ,Associate_Name AS 'Employee Name'      
   ,(Allocation_Startdate) AS 'Allocation_Startdate'      
   ,(Allocation_Enddate) AS 'Allocation_Enddate'      
   ,(Allocation_Percentage) AS 'Allocation_Percentage'      
   ,Isnull(ESA_FTE_Count,0) As 'Associate Allocation(In FTE)'             
FROM [ADPR].[Associate_Allocation_Raw]      
where  SBU not in ('LATAM')     
    
--Inserting into tables    
  
IF @mode='weekly' 

BEGIN      
      
 IF((SELECT JobMode FROM ADPR.ReportTimingDetails WHERE ReportType=@ReportType AND IsDeleted=0) = 'Weekly' AND ((SELECT CONVERT(DATE,Weekly_JobRunDate) FROM ADPR.ReportTimingDetails WHERE ReportType=@ReportType AND IsDeleted=0) = (SELECT CONVERT(DATE,GETDATE()))))   
 
 BEGIN     
 
	insert into [ADPR].[Project_Compliance_Weekly] (Parent_Accountid,Parent_AccountName,EsaProjectid,ProjectName,SBU,[PO ID],[PO Name],[DM ID],[DM Name],[PM ID],[PM Name],Project_Department,DE_Inscope,      
	[Overall #FTE],[AVM #FTE],[Overall #FTE with TSC %=0],[Overall #FTE with TSC %>0 to 25],[Overall #FTE with TSC %>25 to 50],[Overall #FTE with TSC %>50 to 80]      
	,[Overall #FTE with TSC %>80],[AVM #FTE with TSC %>80],[Available Hours],[Available Hours AVM],[Actual Effort],[Actual Effort_AVM],[Effort Project Compliance% (All)]      
	,[Associate_Project_Compliance_Percent],[Effort Project Compliance% (AVM)],[AVM Associate_Project_Compliance_Percent],Startdate,Enddate,[Created datetime],MARKETUNITNAME)      
	      
	SELECT              
	    a.Parent_Accountid  AS 'Parent Accountid'      
	    ,a.Parent_AccountName AS 'Parent AccountName'      
	    ,A.EsaProjectid      
	    ,A.ProjectName      
	    ,A.SBU      
	    ,C.[PO ID] as 'SDM_ID'      
	    ,C.[PO Name] As 'SDM_Name'      
	    ,C.[DM ID] as 'SDD_ID'      
	    ,C.[DM Name] as 'SDD_Name'      
	    ,C.[PM ID] as 'PM_ID'      
	    ,C.[PM Name] As 'PM_Name'      
	    ,D.[SBU] As 'Project_Department'      
	    ,C.DE_Inscope As 'DE_Inscope'     
	    ,ISNULL(A.[Overall #FTE],0) AS 'Overall #FTE'      
	    ,ISNULL(B.[AVM #FTE],0) AS 'AVM FTE'      
	    ,ISNULL(A.[Overall #FTE with TSC %=0],0) As 'Overall #FTE with TSC %=0'      
	    ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0) AS 'Overall #FTE with TSC %>0 to 25'      
	    ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS 'Overall #FTE with TSC %>25 to 50'      
	    ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS 'Overall #FTE with TSC %>50 to 80'      
	    ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS 'Overall #FTE with TSC %>80'      
	    ,ISNULL(B.[AVM #FTE with TSC %>80],0) AS 'AVM #FTE with TSC %>80'      
	    ,ISNULL(a.[Available Hours],0) AS 'Available Hours (All)'   
	    ,ISNULL(B.[Available Hours],0) As 'Available Hours (AVM)'      
	    ,ISNULL(A.[Actual Effort],0) as 'Actual Effort (All)'      
	    ,ISNULL(B.[Actual Effort],0) as 'Actual Effort (AVM)'      
	    ,ISNULL(a.[Effort Project Compliance% (All)],0) as 'Project Effort Compliance% (All)'      
	    ,ISNULL(a.Associate_Project_Compliance_Percent,0) as 'Project Associate Compliance% (All)'      
	    ,ISNULL(B.[Effort Project Compliance% (AVM)],0) as 'Project Effort Compliance% (AVM)'      
	    ,ISNULL(B.AVMAssociate_Project_Compliance_Percent,0) AS 'Project Associate Compliance% (AVM)' ,      
	    @startdate,      
	    @endDate,      
	    getdate(),     
		A.SBU  as 'MARKET UNIT NAME'     	      
	FROM [ADPR].[Project_Compliance] A      	      
	left JOIN [ADPR].[Project_Compliance_AVM] B ON a.Parent_Accountid=B.Parent_Accountid AND A.SBU=B.SBU AND A.EsaProjectid=B.EsaProjectid      	      
	left JOIN [ADPR].[Input_Data_AssociateRAW] C ON a.[EsaProjectID]=C.EsaProjectID       	      
	LEFT JOIN [ADPR].[input_excel_associate] D ON a.[EsaProjectID]=D.EsaProjectID       	      
	WHERE C.DE_Inscope IN('In scope','Yet to scope') and A.SBU not in ('LATAM')   
	  
	UPDATE ADPR.ReportTimingDetails SET Weekly_JobRunDate=DATEADD(DAY,7,Weekly_JobRunDate),CreatedDate=GETDATE() WHERE ReportType=@ReportType 
	
	DECLARE @WeeklyDate DATETIME;
	SET @WeeklyDate=(SELECT Weekly_JobRunDate FROM ADPR.ReportTimingDetails WHERE ReportType=@ReportType AND IsDeleted=0)

	IF(DAY(@WeeklyDate)=5)
	BEGIN
		UPDATE ADPR.ReportTimingDetails SET Weekly_JobRunDate=DATEADD(DAY,7,Weekly_JobRunDate),CreatedDate=GETDATE() WHERE ReportType=@ReportType 
	END

 END  

 IF((SELECT JobMode FROM ADPR.ReportTimingDetails WHERE ReportType=@ReportType AND IsDeleted=0) = 'Daily' AND ((SELECT CONVERT(DATE,Weekly_JobRunDate) FROM ADPR.ReportTimingDetails WHERE ReportType=@ReportType AND IsDeleted=0) = (SELECT CONVERT(DATE,GETDATE()))))   
 
 BEGIN  
 
	insert into [ADPR].[Project_Compliance_Weekly] (Parent_Accountid,Parent_AccountName,EsaProjectid,ProjectName,SBU,[PO ID],[PO Name],[DM ID],[DM Name],[PM ID],[PM Name],Project_Department,DE_Inscope,      
	[Overall #FTE],[AVM #FTE],[Overall #FTE with TSC %=0],[Overall #FTE with TSC %>0 to 25],[Overall #FTE with TSC %>25 to 50],[Overall #FTE with TSC %>50 to 80]      
	,[Overall #FTE with TSC %>80],[AVM #FTE with TSC %>80],[Available Hours],[Available Hours AVM],[Actual Effort],[Actual Effort_AVM],[Effort Project Compliance% (All)]      
	,[Associate_Project_Compliance_Percent],[Effort Project Compliance% (AVM)],[AVM Associate_Project_Compliance_Percent],Startdate,Enddate,[Created datetime],MARKETUNITNAME)      
	      
	SELECT        
	      
	    a.Parent_Accountid  AS 'Parent Accountid'      
	    ,a.Parent_AccountName AS 'Parent AccountName'      
	    ,A.EsaProjectid      
	    ,A.ProjectName      
	    ,A.SBU      
	    ,C.[PO ID] as 'SDM_ID'      
	    ,C.[PO Name] As 'SDM_Name'      
	    ,C.[DM ID] as 'SDD_ID'      
	    ,C.[DM Name] as 'SDD_Name'      
	    ,C.[PM ID] as 'PM_ID'      
	    ,C.[PM Name] As 'PM_Name'      
	    ,D.[SBU] As 'Project_Department'      
	    ,C.DE_Inscope As 'DE_Inscope'     
	    ,ISNULL(A.[Overall #FTE],0) AS 'Overall #FTE'      
	    ,ISNULL(B.[AVM #FTE],0) AS 'AVM FTE'      
	    ,ISNULL(A.[Overall #FTE with TSC %=0],0) As 'Overall #FTE with TSC %=0'      
	    ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0) AS 'Overall #FTE with TSC %>0 to 25'      
	    ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS 'Overall #FTE with TSC %>25 to 50'      
	    ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS 'Overall #FTE with TSC %>50 to 80'      
	    ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS 'Overall #FTE with TSC %>80'      
	    ,ISNULL(B.[AVM #FTE with TSC %>80],0) AS 'AVM #FTE with TSC %>80'      
	    ,ISNULL(a.[Available Hours],0) AS 'Available Hours (All)'      
	    ,ISNULL(B.[Available Hours],0) As 'Available Hours (AVM)'      
	    ,ISNULL(A.[Actual Effort],0) as 'Actual Effort (All)'      
	    ,ISNULL(B.[Actual Effort],0) as 'Actual Effort (AVM)'      
	    ,ISNULL(a.[Effort Project Compliance% (All)],0) as 'Project Effort Compliance% (All)'      
	    ,ISNULL(a.Associate_Project_Compliance_Percent,0) as 'Project Associate Compliance% (All)'      
	    ,ISNULL(B.[Effort Project Compliance% (AVM)],0) as 'Project Effort Compliance% (AVM)'      
	    ,ISNULL(B.AVMAssociate_Project_Compliance_Percent,0) AS 'Project Associate Compliance% (AVM)' ,      
	    @startdate,      
	    @endDate,      
	    getdate(),     
		A.SBU  as 'MARKET UNIT NAME'     	      
	FROM [ADPR].[Project_Compliance] A      	      
	left JOIN [ADPR].[Project_Compliance_AVM] B ON a.Parent_Accountid=B.Parent_Accountid AND A.SBU=B.SBU AND A.EsaProjectid=B.EsaProjectid      	      
	left JOIN [ADPR].[Input_Data_AssociateRAW] C ON a.[EsaProjectID]=C.EsaProjectID       	      
	LEFT JOIN [ADPR].[input_excel_associate] D ON a.[EsaProjectID]=D.EsaProjectID       	      
	WHERE C.DE_Inscope IN('In scope','Yet to scope') and A.SBU not in ('LATAM')   
	 
	UPDATE ADPR.ReportTimingDetails SET Weekly_JobRunDate=DATEADD(DAY,1,Weekly_JobRunDate),CreatedDate=GETDATE() WHERE ReportType=@ReportType  
    
	DECLARE @DailyDate DATETIME;
	SET @DailyDate=(SELECT Weekly_JobRunDate FROM ADPR.ReportTimingDetails WHERE ReportType=@ReportType AND IsDeleted=0)

	IF(DAY(@DailyDate)=5)
	BEGIN
		UPDATE ADPR.ReportTimingDetails SET Weekly_JobRunDate=DATEADD(DAY,1,Weekly_JobRunDate),CreatedDate=GETDATE() WHERE ReportType=@ReportType 
	END
 
	 
 END  
      
END      
    
ELSE IF @mode='monthly'      
BEGIN      
  
  IF((SELECT CONVERT(DATE,Monthly_JobRunDate) FROM ADPR.ReportTimingDetails WHERE ReportType=@ReportType AND IsDeleted=0) = (SELECT CONVERT(DATE,GETDATE())))   
  BEGIN  
      
 insert into [ADPR].Project_Compliance_Monthly (Parent_Accountid,Parent_AccountName,EsaProjectid,ProjectName,SBU,[PO ID],[PO Name],[DM ID],[DM Name],[PM ID],[PM Name],Project_Department,DE_Inscope,      
 [Overall #FTE],[AVM #FTE],[Overall #FTE with TSC %=0],[Overall #FTE with TSC %>0 to 25],[Overall #FTE with TSC %>25 to 50],[Overall #FTE with TSC %>50 to 80]      
 ,[Overall #FTE with TSC %>80],[AVM #FTE with TSC %>80],[Available Hours],[Available Hours AVM],[Actual Effort],[Actual Effort_AVM],[Effort Project Compliance% (All)]      
 ,[Associate_Project_Compliance_Percent],[Effort Project Compliance% (AVM)],[AVM Associate_Project_Compliance_Percent],Startdate,Enddate,[Created datetime],MARKETUNITNAME)      
       
 SELECT    DISTINCT    
       
     a.Parent_Accountid  AS 'Parent Accountid'      
     ,a.Parent_AccountName AS 'Parent AccountName'      
     ,A.EsaProjectid      
     ,A.ProjectName      
     ,A.SBU      
     ,C.[PO ID] as 'SDM_ID'      
     ,C.[PO Name] As 'SDM_Name'      
     ,C.[DM ID] as 'SDD_ID'      
     ,C.[DM Name] as 'SDD_Name'      
     ,C.[PM ID] as 'PM_ID'      
     ,C.[PM Name] As 'PM_Name'      
     ,D.[SBU] As 'Project_Department'      
     ,C.DE_Inscope As 'DE_Inscope'      
     ,ISNULL(A.[Overall #FTE],0) AS 'Overall #FTE'      
     ,ISNULL(B.[AVM #FTE],0) AS 'AVM FTE'      
     ,ISNULL(A.[Overall #FTE with TSC %=0],0) As 'Overall #FTE with TSC %=0'      
     ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0) AS 'Overall #FTE with TSC %>0 to 25'      
     ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS 'Overall #FTE with TSC %>25 to 50'      
     ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS 'Overall #FTE with TSC %>50 to 80'      
     ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS 'Overall #FTE with TSC %>80'      
     ,ISNULL(B.[AVM #FTE with TSC %>80],0) AS 'AVM #FTE with TSC %>80'      
     ,ISNULL(a.[Available Hours],0) AS 'Available Hours (All)'      
     ,ISNULL(B.[Available Hours],0) As 'Available Hours (AVM)'      
     ,ISNULL(A.[Actual Effort],0) as 'Actual Effort (All)'      
     ,ISNULL(B.[Actual Effort],0) as 'Actual Effort (AVM)'      
     ,ISNULL(a.[Effort Project Compliance% (All)],0) as 'Project Effort Compliance% (All)'      
     ,ISNULL(a.Associate_Project_Compliance_Percent,0) as 'Project Associate Compliance% (All)'      
     ,ISNULL(B.[Effort Project Compliance% (AVM)],0) as 'Project Effort Compliance% (AVM)'      
     ,ISNULL(B.AVMAssociate_Project_Compliance_Percent,0) AS 'Project Associate Compliance% (AVM)' ,      
     @startdate,      
     @endDate,      
     getdate(),    
	 A.SBU  as 'MARKET UNIT NAME'           
 FROM [ADPR].[Project_Compliance] A             
 left JOIN [ADPR].[Project_Compliance_AVM] B ON a.Parent_Accountid=B.Parent_Accountid AND A.SBU=B.SBU AND A.EsaProjectid=B.EsaProjectid            
 left JOIN [ADPR].[Input_Data_AssociateRAW] C ON a.[EsaProjectID]=C.EsaProjectID              
 LEFT JOIN [ADPR].[input_excel_associate] D ON a.[EsaProjectID]=D.EsaProjectID              
 WHERE C.DE_Inscope IN('In scope','Yet to scope') and A.SBU not in ('LATAM')   
   
 UPDATE ADPR.ReportTimingDetails SET Monthly_JobRunDate=DATEADD(MONTH,1,DATEFROMPARTS(YEAR(Monthly_JobRunDate),MONTH(Monthly_JobRunDate),5)) WHERE ReportType=@ReportType     
 
 END  
  
END    
  
    
END TRY      
  BEGIN CATCH      
 DECLARE @ErrorMessage VARCHAR(8000);      
 SELECT @ErrorMessage = ERROR_MESSAGE()      
  --INSERT Error          
  EXEC [AppVisionLens].dbo.AVL_InsertError '[ADPR].[NonADM_ACCOUNT_PROJECT_SUMMARY_RAW]', @ErrorMessage, '',''      
  RETURN @ErrorMessage      
  END CATCH         
      
END