CREATE Procedure [ADP].[AIA_ACCOUNT_PROJECT_SUMMARY_RAW] 
(  
@startdate datetime,  
@endDate datetime,  
@mode varchar(200)  
)   
As  
BEGIN    
BEGIN TRY   
  SET NOCOUNT ON;   
  
--****************  
  
select   
[Column_Name],   
[Description]   
from adoption_readme   
  
--***********Account Compliacne ***********************  
-- Account summary  
  
SELECT  DISTINCT  
  
   a.Parent_Accountid,a.Parent_AccountName AS 'Parent AccountName'  
   ,A.Vertical  
   ,A.MARKETUNITNAME as 'SBU Delivery (PC2Geo mapping)'
   --,C.MARKET 
   --,A.BU as 'BU'
   ,ISNULL(A.[Overall #FTE],0) AS 'Overall #FTE'  
   ,ISNULL(B.AVM_ESA_FTE,0) AS 'AIA FTE'  
   ,ISNULL(A.[Overall #FTE with TSC %=0],0) AS 'Overall #FTE with TSC %=0'  
   ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0)AS 'Overall #FTE with TSC %>0 to 25'  
   ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS 'Overall #FTE with TSC %>25 to 50'  
   ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS 'Overall #FTE with TSC %>50 to 80'  
   ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS 'Overall #FTE with TSC %>80'  
   ,ISNULL(B.[AVM FTE with TSC %>80],0) AS 'AIA FTE with TSC %>80'  
   ,ISNULL(a.[Available Hours],0) AS 'Available Hours (All)'  
   ,ISNULL(B.Available_Hours,0) As 'Available Hours (AIA)'  
   ,ISNULL(A.[Actual Effort],0) as 'Actual Effort (All)'  
   ,ISNULL(B.Actual_Effort,0) as 'Actual Effort (AIA)'  
   ,ISNULL(A.[Effort Account Compliance% (All)],0) as 'Account Effort Compliance% (All)'  
   ,ISNULL(a.All_Associate_Compliance_Percent,0) as 'Account Associate Compliance% (All)'  
   ,ISNULL(B.[Effort Account Compliance% (AVM)],0) as 'Account Effort Compliance% (AIA)'  
   ,ISNULL(B.AVM_Associate_Compliance_Percent,0) AS 'Account Associate Compliance% (AIA)'  
  
FROM [Adp].[Account_Compliance] A  
  
left JOIN [Adp].[Account_Compliance_AVM] B ON a.Parent_Accountid=B.Parent_Accountid AND A.vertical=B.vertical and A.MarketUnitName=B.MarketUnitName  

join [Adp].[Input_Data_AssociateRAW]  C on a.Parent_Accountid=C.ParentAccountID --AND A.vertical=B.vertical  
where C.PracticeOwner not in ('LATAM')
  

--**************************************-Project_compliacne****************************************************  
  
-- Project summary  
SELECT  DISTINCT 
  
    a.Parent_Accountid  AS 'Parent Accountid'  
    ,a.Parent_AccountName AS 'Parent AccountName'  
    ,A.EsaProjectid  
    ,A.ProjectName  
    ,A.SBU  as 'SBU Delivery (PC2Geo mapping)'-->add
	--,c.MARKET_BU AS 'BU'
    ,C.[PO ID] as 'SDM_ID'  
    ,C.[PO Name] As 'SDM_Name'  
    ,C.[DM ID] as 'SDD_ID'  
    ,C.[DM Name] as 'SDD_Name'  
    ,C.[PM ID] as 'PM_ID'  
    ,C.[PM Name] As 'PM_Name'  
    ,D.[SBU] As 'Project_Department'  
    ,C.DE_Inscope As 'DE_Inscope'  
    ,ISNULL(A.[Overall #FTE],0) AS 'Overall #FTE'  
    ,ISNULL(B.[AVM #FTE],0) AS 'AIA FTE'  
    ,ISNULL(A.[Overall #FTE with TSC %=0],0) As 'Overall #FTE with TSC %=0'  
    ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0) AS 'Overall #FTE with TSC %>0 to 25'  
    ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS 'Overall #FTE with TSC %>25 to 50'  
    ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS 'Overall #FTE with TSC %>50 to 80'  
    ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS 'Overall #FTE with TSC %>80'  
    ,ISNULL(B.[AVM #FTE with TSC %>80],0) AS 'AIA #FTE with TSC %>80'  
    ,ISNULL(a.[Available Hours],0) AS 'Available Hours (All)'  
    ,ISNULL(B.[Available Hours],0) As 'Available Hours (AIA)'  
    ,ISNULL(A.[Actual Effort],0) as 'Actual Effort (All)'  
    ,ISNULL(B.[Actual Effort],0) as 'Actual Effort (AIA)'  
    ,ISNULL(a.[Effort Project Compliance% (All)],0) as 'Project Effort Compliance% (All)'  
    ,ISNULL(a.Associate_Project_Compliance_Percent,0) as 'Project Associate Compliance% (All)'  
    ,ISNULL(B.[Effort Project Compliance% (AVM)],0) as 'Project Effort Compliance% (AIA)'  
    ,ISNULL(B.AVMAssociate_Project_Compliance_Percent,0) AS 'Project Associate Compliance% (AIA)' 
	,D.[CHILDPROJECT] as 'Child_Project' 
	,C.PROJECTSCOPE
  
FROM [Adp].[Project_Compliance] A  
  
left JOIN [Adp].[Project_Compliance_AVM] B ON a.Parent_Accountid=B.Parent_Accountid AND A.SBU=B.SBU AND A.EsaProjectid=B.EsaProjectid  
  
left JOIN [Adp].[Input_Data_AssociateRAW] C ON a.[EsaProjectID]=C.EsaProjectID   
  
LEFT JOIN [adp].[input_excel_associate] D ON a.[EsaProjectID]=D.EsaProjectID   
  
WHERE C.DE_Inscope IN('In scope','Yet to scope')  and A.SBU not in ('LATAM')

  
--***************************Asociate Summary ***********  
  
-- summary raw  
SELECT    DISTINCT
  
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
     ,c.[SBU] AS 'Project Department' into #AssociateSummary 
     FROM Adp.[Associate_Compliance_RAW] A  
  
  
left JOIN [Adp].[Input_Data_AssociateRAW] B ON a.[EsaProjectID]=b.EsaProjectID   
left join [adp].[input_excel_associate] C ON a.[EsaProjectID]=C.EsaProjectID   
where A.SBU not in ('LATAM')
  
select [SBU Delivery (PC2Geo mapping)],
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
[JobCode],
[Designation],
[DE_Inscope],
[SDM_ID],
[SDM_Name],
[SDD_ID],
[SDD_Name],
[PM_ID],
[PM_Name],
[Project Department] from #AssociateSummary
  
--**********************Associate allocationW*******************************************  
  
-- Associate allocation  
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
  
FROM [Adp].[Associate_Allocation_Raw]  
 where  SBU not in ('LATAM')


---------

--- Inserting into tables
  


IF @mode='weekly'  
BEGIN  
  
  
  
 insert into [Adp].[Project_Compliance_Weekly] (Parent_Accountid,Parent_AccountName,EsaProjectid,ProjectName,SBU,[PO ID],[PO Name],[DM ID],[DM Name],[PM ID],[PM Name],Project_Department,DE_Inscope,  
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
   
 FROM [Adp].[Project_Compliance] A  
   
 left JOIN [Adp].[Project_Compliance_AVM] B ON a.Parent_Accountid=B.Parent_Accountid AND A.SBU=B.SBU AND A.EsaProjectid=B.EsaProjectid  
   
 left JOIN [Adp].[Input_Data_AssociateRAW] C ON a.[EsaProjectID]=C.EsaProjectID   
   
 LEFT JOIN [adp].[input_excel_associate] D ON a.[EsaProjectID]=D.EsaProjectID   
   
 WHERE C.DE_Inscope IN('In scope','Yet to scope') and A.SBU not in ('LATAM')
  
END  

ELSE IF @mode='monthly'  
BEGIN  
  
 insert into [Adp].Project_Compliance_Monthly (Parent_Accountid,Parent_AccountName,EsaProjectid,ProjectName,SBU,[PO ID],[PO Name],[DM ID],[DM Name],[PM ID],[PM Name],Project_Department,DE_Inscope,  
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
   
 FROM [Adp].[Project_Compliance] A  
   
 left JOIN [Adp].[Project_Compliance_AVM] B ON a.Parent_Accountid=B.Parent_Accountid AND A.SBU=B.SBU AND A.EsaProjectid=B.EsaProjectid  
   
 left JOIN [Adp].[Input_Data_AssociateRAW] C ON a.[EsaProjectID]=C.EsaProjectID   
   
 LEFT JOIN [adp].[input_excel_associate] D ON a.[EsaProjectID]=D.EsaProjectID   
   
 WHERE C.DE_Inscope IN('In scope','Yet to scope') and A.SBU not in ('LATAM')
  
END  

END TRY  
  BEGIN CATCH  
 DECLARE @ErrorMessage VARCHAR(8000);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC [AppVisionLens].dbo.AVL_InsertError '[ADP].[AIA_ACCOUNT_PROJECT_SUMMARY_RAW]', @ErrorMessage, '',''  
  RETURN @ErrorMessage  
  END CATCH     
  
END