CREATE Procedure [ADP].[ACCOUNT_PROJECT_SUMMARY_RAW] 
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
from adp.adoption_readme   
  
--***********Account Compliacne ***********************  
-- Account summary  
  
SELECT  DISTINCT  
  
   a.Parent_Accountid,a.Parent_AccountName AS 'Parent AccountName'  
   ,A.Vertical  
   ,A.MARKETUNITNAME as 'SBU Delivery (PC2Geo mapping)'
   --,C.MARKET 
   --,A.BU as 'BU'
   ,ISNULL(A.[Overall #FTE],0) AS 'Overall #FTE'  
   ,ISNULL(B.AVM_ESA_FTE,0) AS 'ADM FTE'  
   ,ISNULL(A.[Overall #FTE with TSC %=0],0) AS 'Overall #FTE with TSC %=0'  
   ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0)AS 'Overall #FTE with TSC %>0 to 25'  
   ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS 'Overall #FTE with TSC %>25 to 50'  
   ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS 'Overall #FTE with TSC %>50 to 80'  
   ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS 'Overall #FTE with TSC %>80'  
   ,ISNULL(B.[AVM FTE with TSC %>80],0) AS 'ADM FTE with TSC %>80'  
   ,ISNULL(a.[Available Hours],0) AS 'Available Hours (All)'  
   ,ISNULL(B.Available_Hours,0) As 'Available Hours (ADM)'  
   ,ISNULL(A.[Actual Effort],0) as 'Actual Effort (All)'  
   ,ISNULL(B.Actual_Effort,0) as 'Actual Effort (ADM)'  
   ,ISNULL(A.[Effort Account Compliance% (All)],0) as 'Account Effort Compliance% (All)'  
   ,ISNULL(a.All_Associate_Compliance_Percent,0) as 'Account Associate Compliance% (All)'  
   ,ISNULL(B.[Effort Account Compliance% (AVM)],0) as 'Account Effort Compliance% (ADM)'  
   ,ISNULL(B.AVM_Associate_Compliance_Percent,0) AS 'Account Associate Compliance% (ADM)'  
  
FROM [Adp].[Account_Compliance] A  
  
left JOIN [Adp].[Account_Compliance_AVM] B ON a.Parent_Accountid=B.Parent_Accountid AND A.vertical=B.vertical and A.MarketUnitName=B.MarketUnitName  

join [Adp].[Input_Data_AssociateRAW]  C on a.Parent_Accountid=C.ParentAccountID --AND A.vertical=B.vertical  
where C.PracticeOwner not in ('LATAM')
  
-- ORDER BY  B.AVM_Associate_Compliance_Percent DESC   

--select * from  [dbo].[Adp_Input_Data_AssociateRAW]

--select * from [dbo].[Adp_Account_Compliance]
  
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
    ,ISNULL(B.[AVM #FTE],0) AS 'ADM FTE'  
    ,ISNULL(A.[Overall #FTE with TSC %=0],0) As 'Overall #FTE with TSC %=0'  
    ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0) AS 'Overall #FTE with TSC %>0 to 25'  
    ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS 'Overall #FTE with TSC %>25 to 50'  
    ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS 'Overall #FTE with TSC %>50 to 80'  
    ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS 'Overall #FTE with TSC %>80'  
    ,ISNULL(B.[AVM #FTE with TSC %>80],0) AS 'ADM #FTE with TSC %>80'  
    ,ISNULL(a.[Available Hours],0) AS 'Available Hours (All)'  
    ,ISNULL(B.[Available Hours],0) As 'Available Hours (ADM)'  
    ,ISNULL(A.[Actual Effort],0) as 'Actual Effort (All)'  
    ,ISNULL(B.[Actual Effort],0) as 'Actual Effort (ADM)'  
    ,ISNULL(a.[Effort Project Compliance% (All)],0) as 'Project Effort Compliance% (All)'  
    ,ISNULL(a.Associate_Project_Compliance_Percent,0) as 'Project Associate Compliance% (All)'  
    ,ISNULL(B.[Effort Project Compliance% (AVM)],0) as 'Project Effort Compliance% (ADM)'  
    ,ISNULL(B.AVMAssociate_Project_Compliance_Percent,0) AS 'Project Associate Compliance% (ADM)' 
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

--Account Summary Scope Split up

SELECT  DISTINCT  
  
   a.Parent_Accountid,a.Parent_AccountName AS 'Parent AccountName'  
   ,A.Vertical  
   ,A.MARKETUNITNAME as 'SBU Delivery (PC2Geo mapping)'
   --,C.MARKET 
   --,A.BU as 'BU'
   ,A.[AD Project #]
   ,ISNULL(A.[Overall #FTE],0) AS 'Overall #FTE'  
   ,ISNULL(B.AVM_ESA_FTE,0) AS 'ADM FTE'  
   ,ISNULL(A.[Overall #FTE with TSC %=0],0) AS 'Overall #FTE with TSC %=0'  
   ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0)AS 'Overall #FTE with TSC %>0 to 25'  
   ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS 'Overall #FTE with TSC %>25 to 50'  
   ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS 'Overall #FTE with TSC %>50 to 80'  
   ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS 'Overall #FTE with TSC %>80'  
   ,ISNULL(B.[AVM FTE with TSC %>80],0) AS 'ADM FTE with TSC %>80'  
   ,ISNULL(a.[Available Hours],0) AS 'Available Hours (All)'  
   ,ISNULL(B.Available_Hours,0) As 'Available Hours (ADM)'  
   ,ISNULL(A.[Actual Effort],0) as 'Actual Effort (All)'  
   ,ISNULL(B.Actual_Effort,0) as 'Actual Effort (ADM)'  
   ,ISNULL(A.[Effort Account Compliance% (All)],0) as 'Account Effort Compliance% (All)'  
   ,ISNULL(a.All_Associate_Compliance_Percent,0) as 'Account Associate Compliance% (All)'  
   ,ISNULL(B.[Effort Account Compliance% (AVM)],0) as 'Account Effort Compliance% (ADM)'  
   ,ISNULL(B.AVM_Associate_Compliance_Percent,0) AS 'Account Associate Compliance% (ADM)'  
  
  Into #Account_AD
FROM [Adp].[Account_Compliance_AD] A  
  
left JOIN [Adp].[Account_Compliance_AVM_AD] B ON a.Parent_Accountid=B.Parent_Accountid AND A.vertical=B.vertical and A.MarketUnitName=B.MarketUnitName  

join [Adp].[Input_Data_AssociateRAW]  C on a.Parent_Accountid=C.ParentAccountID --AND A.vertical=B.vertical  
where C.PracticeOwner not in ('LATAM')

--select * from [dbo].[Adp_Account_Compliance_AD]


SELECT  DISTINCT  
  
   a.Parent_Accountid,a.Parent_AccountName AS 'Parent AccountName'  
   ,A.Vertical  
   ,A.MARKETUNITNAME as 'SBU Delivery (PC2Geo mapping)'
   --,C.MARKET 
   --,A.BU as 'BU'
   ,A.[AM Project #]
   ,ISNULL(A.[Overall #FTE],0) AS 'Overall #FTE'  
   ,ISNULL(B.AVM_ESA_FTE,0) AS 'ADM FTE'  
   ,ISNULL(A.[Overall #FTE with TSC %=0],0) AS 'Overall #FTE with TSC %=0'  
   ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0)AS 'Overall #FTE with TSC %>0 to 25'  
   ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS 'Overall #FTE with TSC %>25 to 50'  
   ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS 'Overall #FTE with TSC %>50 to 80'  
   ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS 'Overall #FTE with TSC %>80'  
   ,ISNULL(B.[AVM FTE with TSC %>80],0) AS 'ADM FTE with TSC %>80'  
   ,ISNULL(a.[Available Hours],0) AS 'Available Hours (All)'  
   ,ISNULL(B.Available_Hours,0) As 'Available Hours (ADM)'  
   ,ISNULL(A.[Actual Effort],0) as 'Actual Effort (All)'  
   ,ISNULL(B.Actual_Effort,0) as 'Actual Effort (ADM)'  
   ,ISNULL(A.[Effort Account Compliance% (All)],0) as 'Account Effort Compliance% (All)'  
   ,ISNULL(a.All_Associate_Compliance_Percent,0) as 'Account Associate Compliance% (All)'  
   ,ISNULL(B.[Effort Account Compliance% (AVM)],0) as 'Account Effort Compliance% (ADM)'  
   ,ISNULL(B.AVM_Associate_Compliance_Percent,0) AS 'Account Associate Compliance% (ADM)' 
     Into #Account_AM
  
FROM [Adp].[Account_Compliance_AM] A  
  
left JOIN [Adp].[Account_Compliance_AVM_AM] B ON a.Parent_Accountid=B.Parent_Accountid AND A.vertical=B.vertical and A.MarketUnitName=B.MarketUnitName  

join [Adp].[Input_Data_AssociateRAW]  C on a.Parent_Accountid=C.ParentAccountID --AND A.vertical=B.vertical  
where C.PracticeOwner not in ('LATAM')

SELECT  DISTINCT  
  
   a.Parent_Accountid,a.Parent_AccountName AS 'Parent AccountName'  
   ,A.Vertical  
   ,A.MARKETUNITNAME as 'SBU Delivery (PC2Geo mapping)'
   --,C.MARKET 
   --,A.BU as 'BU'
   ,A.[INTEGRATED Project #]
   ,ISNULL(A.[Overall #FTE],0) AS 'Overall #FTE'  
   ,ISNULL(B.AVM_ESA_FTE,0) AS 'ADM FTE'  
   ,ISNULL(A.[Overall #FTE with TSC %=0],0) AS 'Overall #FTE with TSC %=0'  
   ,ISNULL(A.[Overall #FTE with TSC %>0 to 25],0)AS 'Overall #FTE with TSC %>0 to 25'  
   ,ISNULL(A.[Overall #FTE with TSC %>25 to 50],0) AS 'Overall #FTE with TSC %>25 to 50'  
   ,ISNULL(A.[Overall #FTE with TSC %>50 to 80],0) AS 'Overall #FTE with TSC %>50 to 80'  
   ,ISNULL(A.[Overall #FTE with TSC %>80],0) AS 'Overall #FTE with TSC %>80'  
   ,ISNULL(B.[AVM FTE with TSC %>80],0) AS 'ADM FTE with TSC %>80'  
   ,ISNULL(a.[Available Hours],0) AS 'Available Hours (All)'  
   ,ISNULL(B.Available_Hours,0) As 'Available Hours (ADM)'  
   ,ISNULL(A.[Actual Effort],0) as 'Actual Effort (All)'  
   ,ISNULL(B.Actual_Effort,0) as 'Actual Effort (ADM)'  
   ,ISNULL(A.[Effort Account Compliance% (All)],0) as 'Account Effort Compliance% (All)'  
   ,ISNULL(a.All_Associate_Compliance_Percent,0) as 'Account Associate Compliance% (All)'  
   ,ISNULL(B.[Effort Account Compliance% (AVM)],0) as 'Account Effort Compliance% (ADM)'  
   ,ISNULL(B.AVM_Associate_Compliance_Percent,0) AS 'Account Associate Compliance% (ADM)'  
     Into #Account_INTEG
  
FROM [Adp].[Account_Compliance_INTEG] A  
  
left JOIN [Adp].[Account_Compliance_AVM_INTEG] B ON a.Parent_Accountid=B.Parent_Accountid AND A.vertical=B.vertical and A.MarketUnitName=B.MarketUnitName  

join [Adp].[Input_Data_AssociateRAW]  C on a.Parent_Accountid=C.ParentAccountID --AND A.vertical=B.vertical  
where C.PracticeOwner not in ('LATAM')

--select * from #Account_AD
--select * from #Account_AM
--select * from #Account_INTEG

create table #AccountCompliance_Split

(
[Parent_Accountid]	[char](15) NULL,
[Parent AccountName]	[varchar](50) NULL,
[Vertical]	[varchar](50) NULL,
[SBU Delivery (PC2Geo mapping)]	[varchar](50) NULL,
[Count of Projet]	INT,
[Overall #FTE]	[decimal](10, 2) NULL,
[ADM FTE]	[decimal](10, 2) NULL,
[Overall #FTE with TSC %=0]	[decimal](10, 2) NULL,
[Overall #FTE with TSC %>0 to 25]	[decimal](10, 2) NULL,
[Overall #FTE with TSC %>25 to 50]	[decimal](10, 2) NULL,
[Overall #FTE with TSC %>50 to 80]	[decimal](10, 2) NULL,
[Overall #FTE with TSC %>80]	[decimal](10, 2) NULL,
[ADM FTE with TSC %>80]	[decimal](10, 2) NULL,
[Available Hours (All)]	[decimal](10, 2) NULL,
[Available Hours (ADM)]	[decimal](10, 2) NULL,
[Actual Effort (All)]	[decimal](10, 2) NULL,
[Actual Effort (ADM)]	[decimal](10, 2) NULL,
[Account Effort Compliance% (All)]	[decimal](10, 2) NULL,
[Account Associate Compliance% (All)]	[decimal](10, 2) NULL,
[Account Effort Compliance% (ADM)]	[decimal](10, 2) NULL,
[Account Associate Compliance% (ADM)]	[decimal](10, 2) NULL,
[Scope] char(15)
)

INSERT INTO #AccountCompliance_Split

SELECT [Parent_Accountid],[Parent AccountName],[Vertical],[SBU Delivery (PC2Geo mapping)],[AD Project #],[Overall #FTE],[ADM FTE],[Overall #FTE with TSC %=0],
[Overall #FTE with TSC %>0 to 25],[Overall #FTE with TSC %>25 to 50],[Overall #FTE with TSC %>50 to 80],[Overall #FTE with TSC %>80],[ADM FTE with TSC %>80],
[Available Hours (All)],[Available Hours (ADM)],[Actual Effort (All)],[Actual Effort (ADM)],[Account Effort Compliance% (All)],[Account Associate Compliance% (All)],
[Account Effort Compliance% (ADM)],[Account Associate Compliance% (ADM)],'AD'
 FROM #Account_AD
 

 uNION

 SELECT [Parent_Accountid],[Parent AccountName],[Vertical],[SBU Delivery (PC2Geo mapping)],[AM Project #],[Overall #FTE],[ADM FTE],[Overall #FTE with TSC %=0],
[Overall #FTE with TSC %>0 to 25],[Overall #FTE with TSC %>25 to 50],[Overall #FTE with TSC %>50 to 80],[Overall #FTE with TSC %>80],[ADM FTE with TSC %>80],
[Available Hours (All)],[Available Hours (ADM)],[Actual Effort (All)],[Actual Effort (ADM)],[Account Effort Compliance% (All)],[Account Associate Compliance% (All)],
[Account Effort Compliance% (ADM)],[Account Associate Compliance% (ADM)],'AM'
 FROM #Account_Am

 UNION

 SELECT [Parent_Accountid],[Parent AccountName],[Vertical],[SBU Delivery (PC2Geo mapping)],[INTEGRATED Project #],[Overall #FTE],[ADM FTE],[Overall #FTE with TSC %=0],
[Overall #FTE with TSC %>0 to 25],[Overall #FTE with TSC %>25 to 50],[Overall #FTE with TSC %>50 to 80],[Overall #FTE with TSC %>80],[ADM FTE with TSC %>80],
[Available Hours (All)],[Available Hours (ADM)],[Actual Effort (All)],[Actual Effort (ADM)],[Account Effort Compliance% (All)],[Account Associate Compliance% (All)],
[Account Effort Compliance% (ADM)],[Account Associate Compliance% (ADM)],'INTEG'
 FROM #Account_integ

 TRUNCATE TABLE [Adp].[Account_Compliance_Scope]


Insert into [Adp].[Account_Compliance_Scope] ( [Parent_Accountid],[Parent AccountName],[Vertical],[MARKET UNIT NAME])

SELECT distinct  [Parent_Accountid],[Parent AccountName],[Vertical],[SBU Delivery (PC2Geo mapping)] FROM #AccountCompliance_Split






UPDATE A set 
A.[AM Project #] = B.[Count of Projet],
A.[AM Project -Overall #FTE] =B.[Overall #FTE],
A.[AM Project-ADM FTE] = [ADM FTE],
A.[AM- Overall #FTE with TSC %=0] = B.[Overall #FTE with TSC %=0],
A.[AM- Overall #FTE with TSC %>0 to 25] = B.[Overall #FTE with TSC %>0 to 25],
A.[AM- Overall #FTE with TSC %>25 to 50] = B.[Overall #FTE with TSC %>25 to 50],
A.[AM- Overall #FTE with TSC %>50 to 80] = B.[Overall #FTE with TSC %>50 to 80],
A.[AM- Overall #FTE with TSC %>80] =B.[Overall #FTE with TSC %>80],
A.[AM Project- ADM FTE with TSC %>80] = B.[ADM FTE with TSC %>80],
A.[AM Project- Available Hours (All)] = B.[Available Hours (All)],
A.[AM Project- Available Hours (ADM)] = B.[Available Hours (ADM)],
A.[AM Project- Actual Effort (All)] = B.[Actual Effort (All)],	
A.[AM Project- Actual Effort (ADM)] = B.[Actual Effort (ADM)],
A.[AM Scope - Account Effort Compliance% (All)] = B.[Account Effort Compliance% (All)],
A.[AM Scope - Account Associate Compliance% (All)] = B.[Account Associate Compliance% (All)],
A.[AM Scope - Account Effort Compliance% (ADM)] = B.[Account Effort Compliance% (ADM)],
A.[AM Scope - Account Associate Compliance% (ADM)] = B.[Account Associate Compliance% (ADM)]
 from [Adp].[Account_Compliance_Scope] A
join #AccountCompliance_Split B on A.[Parent_Accountid]=B.[Parent_Accountid] and a.[Parent AccountName]=b.[Parent AccountName]
and a.[Vertical]=b.[Vertical] and a.[MARKET UNIT NAME]=b.[SBU Delivery (PC2Geo mapping)] 
where B.scope='AM'

UPDATE A set 
A.[AD Project #] = B.[Count of Projet],
A.[AD Project -Overall #FTE] =B.[Overall #FTE],
A.[AD Project-ADM FTE] = [ADM FTE],
A.[AD- Overall #FTE with TSC %=0] = B.[Overall #FTE with TSC %=0],
A.[AD- Overall #FTE with TSC %>0 to 25] = B.[Overall #FTE with TSC %>0 to 25],
A.[AD- Overall #FTE with TSC %>25 to 50] = B.[Overall #FTE with TSC %>25 to 50],
A.[AD- Overall #FTE with TSC %>50 to 80] = B.[Overall #FTE with TSC %>50 to 80],
A.[AD- Overall #FTE with TSC %>80] =B.[Overall #FTE with TSC %>80],
A.[AD Project- ADM FTE with TSC %>80] = B.[ADM FTE with TSC %>80],
A.[AD Project- Available Hours (All)] = B.[Available Hours (All)],
A.[AD Project- Available Hours (ADM)] = B.[Available Hours (ADM)],
A.[AD Project- Actual Effort (All)] = B.[Actual Effort (All)],
A.[AD Project- Actual Effort (ADM)] = B.[Actual Effort (ADM)],
A.[AD Scope - Account Effort Compliance% (All)] = B.[Account Effort Compliance% (All)],
A.[AD Scope - Account Associate Compliance% (All)] = B.[Account Associate Compliance% (All)],
A.[AD Scope - Account Effort Compliance% (ADM)] = B.[Account Effort Compliance% (ADM)],
A.[AD Scope - Account Associate Compliance% (ADM)] = B.[Account Associate Compliance% (ADM)]
 from [Adp].[Account_Compliance_Scope] A
join #AccountCompliance_Split B on A.[Parent_Accountid]=B.[Parent_Accountid] and a.[Parent AccountName]=b.[Parent AccountName]
and a.[Vertical]=b.[Vertical] and a.[MARKET UNIT NAME]=b.[SBU Delivery (PC2Geo mapping)] 
where B.scope='AD'


UPDATE A set 
A.[INTEGRATED Project #] = B.[Count of Projet],
A.[INTEGRATED Project -Overall #FTE] =B.[Overall #FTE],
A.[INTEGRATED Project-ADM FTE] = [ADM FTE],
A.[INTEGRATED- Overall #FTE with TSC %=0] = B.[Overall #FTE with TSC %=0],
A.[INTEGRATED- Overall #FTE with TSC %>0 to 25] = B.[Overall #FTE with TSC %>0 to 25],
A.[INTEGRATED- Overall #FTE with TSC %>25 to 50] = B.[Overall #FTE with TSC %>25 to 50],
A.[INTEGRATED- Overall #FTE with TSC %>50 to 80] = B.[Overall #FTE with TSC %>50 to 80],
A.[INTEGRATED- Overall #FTE with TSC %>80] =B.[Overall #FTE with TSC %>80],
A.[INTEGRATED Project- ADM FTE with TSC %>80] = B.[ADM FTE with TSC %>80],
A.[INTEGRATED Project- Available Hours (All)] = B.[Available Hours (All)],
A.[INTEGRATED Project- Available Hours (ADM)] = B.[Available Hours (ADM)],
A.[INTEGRATED Project- Actual Effort (All)] = B.[Actual Effort (All)],
A.[INTEGRATED Project- Actual Effort (ADM)] = B.[Actual Effort (ADM)],
A.[INTEGRATED Scope - Account Effort Compliance% (All)] = B.[Account Effort Compliance% (All)],
A.[INTEGRATED Scope - Account Associate Compliance% (All)] = B.[Account Associate Compliance% (All)],
A.[INTEGRATED Scope - Account Effort Compliance% (ADM)] = B.[Account Effort Compliance% (ADM)],
A.[INTEGRATED Scope - Account Associate Compliance% (ADM)] = B.[Account Associate Compliance% (ADM)]
  from [Adp].[Account_Compliance_Scope] A
join #AccountCompliance_Split B on A.[Parent_Accountid]=B.[Parent_Accountid] and a.[Parent AccountName]=b.[Parent AccountName]
and a.[Vertical]=b.[Vertical] and a.[MARKET UNIT NAME]=b.[SBU Delivery (PC2Geo mapping)]
where B.scope='INTEG'


UPDATE A set  a.[Yet to scope project #]=b.[Yet to onboard projects #], a.[Available Hours]=b.[Available_Hours] 
from [Adp].[Account_Compliance_Scope] A
join [Adp].[Account_Compliance_YETTOSCOPE] B on A.[Parent_Accountid]=b.[Parent_Accountid]
and a.Vertical=b.vertical and a.[MARKET UNIT NAME]=b.[MARKET UNIT NAME]

select  [Parent_Accountid],[Parent AccountName],[Vertical],[MARKET UNIT NAME] as 'SBU Delivery (PC2Geo mapping)' ,[Yet to scope project #],[Available Hours],
 [AD Project #],[AD Project -Overall #FTE],[AD Project-ADM FTE],[AD- Overall #FTE with TSC %=0],
[AD- Overall #FTE with TSC %>0 to 25],[AD- Overall #FTE with TSC %>25 to 50],[AD- Overall #FTE with TSC %>50 to 80],[AD- Overall #FTE with TSC %>80],[AD Project- ADM FTE with TSC %>80],
[AD Project- Available Hours (All)],[AD Project- Available Hours (ADM)],[AD Project- Actual Effort (All)],[AD Project- Actual Effort (ADM)],[AD Scope - Account Effort Compliance% (All)],
[AD Scope - Account Associate Compliance% (All)],[AD Scope - Account Effort Compliance% (ADM)],[AD Scope - Account Associate Compliance% (ADM)],[AM Project #],
[AM Project -Overall #FTE],[AM Project-ADM FTE],[AM- Overall #FTE with TSC %=0],[AM- Overall #FTE with TSC %>0 to 25],[AM- Overall #FTE with TSC %>25 to 50],
[AM- Overall #FTE with TSC %>50 to 80],[AM- Overall #FTE with TSC %>80],[AM Project- ADM FTE with TSC %>80],[AM Project- Available Hours (All)],[AM Project- Available Hours (ADM)],
[AM Project- Actual Effort (All)],[AM Project- Actual Effort (ADM)],[AM Scope - Account Effort Compliance% (All)],[AM Scope - Account Associate Compliance% (All)],[AM Scope - Account Effort Compliance% (ADM)],
[AM Scope - Account Associate Compliance% (ADM)],[INTEGRATED Project #],[INTEGRATED Project -Overall #FTE],[INTEGRATED Project-ADM FTE],[INTEGRATED- Overall #FTE with TSC %=0],[INTEGRATED- Overall #FTE with TSC %>0 to 25],
[INTEGRATED- Overall #FTE with TSC %>25 to 50],[INTEGRATED- Overall #FTE with TSC %>50 to 80],[INTEGRATED- Overall #FTE with TSC %>80],[INTEGRATED Project- ADM FTE with TSC %>80],
[INTEGRATED Project- Available Hours (All)],[INTEGRATED Project- Available Hours (ADM)],[INTEGRATED Project- Actual Effort (All)],[INTEGRATED Project- Actual Effort (ADM)],[INTEGRATED Scope - Account Effort Compliance% (All)],
[INTEGRATED Scope - Account Associate Compliance% (All)],[INTEGRATED Scope - Account Effort Compliance% (ADM)],[INTEGRATED Scope - Account Associate Compliance% (ADM)] 
from [Adp].[Account_Compliance_Scope] 


--Bu Split up


SELECT  A.SBU AS 'SBU Delivery (PC2Geo mapping)' ,Isnull(convert(decimal(10,1),A.[Overall #FTE]),0) AS 'Overall FTE'
,Isnull(convert(decimal(10,1),C.[Overall #FTE]),0) AS 'AD Overall FTE'
,Isnull(convert(decimal(10,1),D.[Overall #FTE]),0) AS 'AM Overall FTE'
,Isnull(convert(decimal(10,1),E.[Overall #FTE]),0) AS 'INTEGRATED Overall FTE'
,isnull(convert(decimal(10,1),F.[AVM #FTE]),0) AS 'AD ADM FTE'
,isnull(convert(decimal(10,1),G.[AVM #FTE]),0) AS 'AM ADM FTE'
,isnull(convert(decimal(10,1),H.[AVM #FTE]),0) AS 'INTEGRATED ADM FTE'
,isnull(convert(decimal(10,1),B.[AVM #FTE]),0) AS 'ADM FTE'
,isnull(convert(decimal(10,1),A.[Overall #FTE with TSC %=0]),0) AS 'Overall #FTE with TSC %=0'  
,isnull(convert(decimal(10,1),A.[Overall #FTE with TSC %>0 to 25]),0) AS 'Overall #FTE with TSC %>0 to 25'  
,isnull(convert(decimal(10,1),A.[Overall #FTE with TSC %>25 to 50]),0)AS 'Overall #FTE with TSC %>25 to 50'  
,isnull(convert(decimal(10,1),A.[Overall #FTE with TSC %>50 to 80]),0) AS 'Overall #FTE with TSC %>50 to 80'  
,isnull(convert(decimal(10,1),C.[Overall #FTE with TSC %>80]),0) AS 'AD Overall #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),D.[Overall #FTE with TSC %>80]),0) AS 'AM Overall #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),E.[Overall #FTE with TSC %>80]),0) AS 'INTEGRATED Overall #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),A.[Overall #FTE with TSC %>80]),0) AS 'Overall #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),F.[AVM #FTE with TSC %>80]),0) AS 'AD ADM #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),G.[AVM #FTE with TSC %>80]),0) AS 'AM ADM #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),H.[AVM #FTE with TSC %>80]),0) AS 'INTEGRATED ADM #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),B.[AVM #FTE with TSC %>80]),0) AS 'ADM #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),C.[Available Hours]),0)AS 'AD Available Hours (All)'  
,isnull(convert(decimal(10,1),D.[Available Hours]),0)AS 'AM Available Hours (All)' 
,isnull(convert(decimal(10,1),E.[Available Hours]),0)AS 'INTEGRATED Available Hours (All)' 
,isnull(convert(decimal(10,1),a.[Available Hours]),0)AS 'Available Hours (All)' 
,isnull(convert(decimal(10,1),F.[Available Hours]) ,0)AS 'AD Available Hours (ADM)'  
,isnull(convert(decimal(10,1),G.[Available Hours]) ,0)AS 'AM Available Hours (ADM)'  
,isnull(convert(decimal(10,1),H.[Available Hours]) ,0)AS 'INTEGRATED Available Hours (ADM)'  
,isnull(convert(decimal(10,1),B.[Available Hours]) ,0)AS 'Available Hours (ADM)'  
,isnull(convert(decimal(10,1),C.[Actual Effort]),0) as 'AD Actual Effort (All)'  
,isnull(convert(decimal(10,1),D.[Actual Effort]),0) as 'AM Actual Effort (All)' 
,isnull(convert(decimal(10,1),E.[Actual Effort]),0) as 'INTEGRATED Actual Effort (All)' 
,isnull(convert(decimal(10,1),A.[Actual Effort]),0) as 'Actual Effort (All)' 
,isnull(convert(decimal(10,1),F.[Actual Effort]),0) as 'AD Actual Effort (ADM)'  
,isnull(convert(decimal(10,1),G.[Actual Effort]),0) as 'AM Actual Effort (ADM)' 
,isnull(convert(decimal(10,1),H.[Actual Effort]),0) as 'INTEGRATED Actual Effort (ADM)' 
,isnull(convert(decimal(10,1),B.[Actual Effort]),0) as 'Actual Effort (ADM)' 
,ISNULL(convert(decimal(10,1),c.[BU Effort Compliance%(All)]),0) AS 'AD Scope -BU Effort Compliance%(All)' 
,ISNULL(convert(decimal(10,1),d.[BU Effort Compliance%(All)]),0) AS 'AM Scope -BU Effort Compliance%(All)' 
,ISNULL(convert(decimal(10,1),e.[BU Effort Compliance%(All)]),0) AS 'Integrated Scope -BU Effort Compliance%(All)' 
,ISNULL(convert(decimal(10,1),a.[BU Effort Compliance%(All)]),0) AS 'BU Effort Compliance%(All)' 
,ISNULL(convert(decimal(10,1),c.[Associate Compliance Percent]),0) AS 'AD Scope -BU Associate Compliance% (All)'   
,ISNULL(convert(decimal(10,1),d.[Associate Compliance Percent]),0) AS 'AM Scope -BU Associate Compliance% (All)'   
,ISNULL(convert(decimal(10,1),e.[Associate Compliance Percent]),0) AS 'Integrated Scope -BU Associate Compliance% (All)'   
,ISNULL(convert(decimal(10,1),a.[Associate Compliance Percent]),0) AS 'BU Associate Compliance% (All)'
,ISNULL(convert(decimal(10,1),F.[BU Effort Compliance%(AVM)]),0) AS 'AD Scope-BU Effort Compliance%(ADM)'
,ISNULL(convert(decimal(10,1),G.[BU Effort Compliance%(AVM)]),0) AS 'AM Scope -BU Effort Compliance%(ADM)'  
,ISNULL(convert(decimal(10,1),H.[BU Effort Compliance%(AVM)]),0) AS 'Integrated Scope -BU Effort Compliance%(ADM)'  
,ISNULL(convert(decimal(10,1),B.[BU Effort Compliance%(AVM)]),0) AS 'BU Effort Compliance%(ADM)'  
,ISNULL(convert(decimal(10,1),F.[AVM_Associate_Compliance_Percent]),0)  AS 'AD Scope-BU Associate Compliance% (ADM)'  
,ISNULL(convert(decimal(10,1),G.[AVM_Associate_Compliance_Percent]),0)  AS 'AM Scope -BU Associate Compliance% (ADM)'  
,ISNULL(convert(decimal(10,1),H.[AVM_Associate_Compliance_Percent]),0)  AS 'Integrated Scope -BU Associate Compliance% (ADM)'  
,ISNULL(convert(decimal(10,1),B.[AVM_Associate_Compliance_Percent]),0)  AS 'BU Associate Compliance% (ADM)'  
 Into #Adp_SBU_Compliance_AL
FROM [Adp].[SBU_Compliance] A  
  
LEFT JOIN [Adp].[SBU_Compliance_AVM] B ON a.sbu=b.sbu   
LEFT JOIN [Adp].[SBU_Compliance_AD] C ON a.sbu=C.sbu   
LEFT JOIN [Adp].[SBU_Compliance_AM] D ON a.sbu=D.sbu   
LEFT JOIN [Adp].[SBU_Compliance_INTEG] E ON a.sbu=E.sbu   
LEFT JOIN [Adp].[SBU_Compliance_AVM_AD] F ON a.sbu=F.sbu   
LEFT JOIN [Adp].[SBU_Compliance_AVM_AM] G ON a.sbu=G.sbu   
LEFT JOIN [Adp].[SBU_Compliance_AVM_INTEG] H ON a.sbu=H.sbu   


ORDER BY CASE   WHEN A.SBU = 'GRAND TOTAL' THEN 1  
  
 ELSE 0  
END, A.[SBU]  
  ASC  

select [SBU Delivery (PC2Geo mapping)],[Overall FTE],[ADM FTE],[Overall #FTE with TSC %=0],[Overall #FTE with TSC %>0 to 25],[Overall #FTE with TSC %>25 to 50],
[Overall #FTE with TSC %>50 to 80],[Overall #FTE with TSC %>80],[ADM #FTE with TSC %>80],[Available Hours (All)],
[Available Hours (ADM)],[Actual Effort (All)],[Actual Effort (ADM)],[AD Scope -BU Effort Compliance%(All)] 
,[AM Scope -BU Effort Compliance%(All)],[Integrated Scope -BU Effort Compliance%(All)] ,[BU Effort Compliance%(All)]
,[AD Scope -BU Associate Compliance% (All)] ,[AM Scope -BU Associate Compliance% (All)],[INTEGRATED Scope -BU Associate Compliance% (All)],[BU Associate Compliance% (All)],
[AD Scope-BU Effort Compliance%(ADM)] ,[AM Scope -BU Effort Compliance%(ADM)],[Integrated Scope -BU Effort Compliance%(ADM)],[BU Effort Compliance%(ADM)],
[AD Scope-BU Associate Compliance% (ADM)] ,[AM Scope -BU Associate Compliance% (ADM)],[Integrated Scope -BU Associate Compliance% (ADM)],[BU Associate Compliance% (ADM)] 
into  #Adp_SBU_Compliance_FIN 
from #Adp_SBU_Compliance_AL where [SBU Delivery (PC2Geo mapping)]not in('M&A NA','RCGTH-NA')

--drop table #Adp_SBU_Compliance_FIN

insert into #Adp_SBU_Compliance_FIN 
     
 select  'RCGTH-NA' AS [SBU Delivery (PC2Geo mapping)],
 ISNULL(sum([Overall FTE]),0) AS 'Overall FTE',
 ISNULL(sum([ADM FTE]),0) AS 'ADM FTE',
 ISNULL(sum([Overall #FTE with TSC %=0]),0) AS 'Overall #FTE with TSC %=0',
 ISNULL(sum([Overall #FTE with TSC %>0 to 25]),0) As 'Overall #FTE with TSC %>0 to 25',
 ISNULL(sum([Overall #FTE with TSC %>25 to 50]),0) As 'Overall #FTE with TSC %>25 to 50', 
 ISNULL(sum([Overall #FTE with TSC %>50 to 80]),0) As 'Overall #FTE with TSC %>50 to 80',
 ISNULL(sum([Overall #FTE with TSC %>80]),0) As 'Overall #FTE with TSC %>80',
 ISNULL(sum([ADM #FTE with TSC %>80]),0) As 'ADM #FTE with TSC %>80',
 ISNULL(sum([Available Hours (All)]),0) AS 'Available Hours (All)',
 ISNULL(sum([Available Hours (ADM)]),0)AS 'Available Hours (ADM)',
 ISNULL(sum([Actual Effort (All)]),0) AS 'Actual Effort (All)',
 ISNULL(sum([Actual Effort (ADM)]),0) AS 'Actual Effort (ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AD Actual Effort (All)])) / SUM(CONVERT(DECIMAL(10, 2), nullif([AD Available Hours (All)],0))) * 100, 0) AS 'AD SCOPE BU Effort Compliance%(All)' ,
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AM Actual Effort (All)])) / SUM(CONVERT(DECIMAL(10, 2), nullif([AM Available Hours (All)],0))) * 100, 0) AS 'AM SCOPE BU Effort Compliance%(All)' ,
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [INTEGRATED Actual Effort (All)])) / SUM(CONVERT(DECIMAL(10, 2), nullif([INTEGRATED Available Hours (All)],0))) * 100, 0) AS 'INTEGRATED SCOPE BU Effort Compliance%(All)' ,
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [Actual Effort (All)])) / SUM(CONVERT(DECIMAL(10, 2), nullif([Available Hours (All)],0))) * 100, 0) AS 'BU Effort Compliance%(All)' ,
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AD Overall #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), nullif([AD Overall FTE],0))) * 100, 0) AS 'AD SCOPE BU Associate Compliance% (All)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AM Overall #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), nullif([AM Overall FTE],0))) * 100, 0) AS 'AM SCOPE BU Associate Compliance% (All)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [INTEGRATED Overall #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), nullif([INTEGRATED Overall FTE],0))) * 100, 0) AS 'INTEGRATED SCOPE Associate Compliance% (All)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [Overall #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), nullif([Overall FTE],0))) * 100, 0) AS 'BU Associate Compliance% (All)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AD Actual Effort (ADM)])) / SUM(CONVERT(DECIMAL(10, 2), nullif([AD Available Hours (ADM)],0))) * 100, 0) AS 'AD SCOPE BU Effort Compliance%(ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AM Actual Effort (ADM)])) / SUM(CONVERT(DECIMAL(10, 2), nullif([AM Available Hours (ADM)],0))) * 100, 0) AS 'AM SCOPE BU Effort Compliance%(ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [INTEGRATED Actual Effort (ADM)])) / SUM(CONVERT(DECIMAL(10, 2), nullif([INTEGRATED Available Hours (ADM)],0))) * 100, 0) AS 'INTEGRATED SCOPE Effort Compliance%(ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [Actual Effort (ADM)])) / SUM(CONVERT(DECIMAL(10, 2), nullif([Available Hours (ADM)],0))) * 100, 0) AS 'BU Effort Compliance%(ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AD ADM #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), nullif([AD ADM FTE],0))) * 100, 0) AS 'AD SCOPE BU Associate Compliance% (ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AM ADM #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), nullif([AM ADM FTE],0))) * 100, 0) AS 'AM SCOPE BU Associate Compliance% (ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [INTEGRATED ADM #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), nullif([INTEGRATED ADM FTE],0))) * 100, 0) AS 'INTEGRATED SCOPE BU Associate Compliance% (ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [ADM #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), nullif([ADM FTE],0))) * 100, 0) AS 'BU Associate Compliance% (ADM)'
 from #Adp_SBU_Compliance_AL where [SBU Delivery (PC2Geo mapping)] in('M&A NA','RCGTH-NA')

--select * from #Adp_SBU_Compliance_AL

  
select *  Into #BUFINALTEMP from (
(select * from #Adp_SBU_Compliance_FIN where [SBU Delivery (PC2Geo mapping)] like '%NA')

UNION ALL

(select * from #Adp_SBU_Compliance_FIN where [SBU Delivery (PC2Geo mapping)] not like '%NA' and [SBU Delivery (PC2Geo mapping)] not like 'GRAND TOTAL')
 Union All
 
(select * from #Adp_SBU_Compliance_FIN where [SBU Delivery (PC2Geo mapping)] not like '%NA' and [SBU Delivery (PC2Geo mapping)]  like 'GRAND TOTAL'))B

----
SELECT * INTO #fINAL_SBU
FROM(
select * from #BUFINALTEMP where [SBU Delivery (PC2Geo mapping)] in ('CMT NA','FSI NA')

--Union ALl
--select * from #FSI_NA where Vertical in ('INSURANCE-NA','BFS-NA')

Union ALl
select * from #BUFINALTEMP where [SBU Delivery (PC2Geo mapping)]  in ('HEALTh NA')
--Union All

--select * from #FSI_NA where Vertical not in ('INSURANCE-NA','BFS-NA')
Union All

select * from #BUFINALTEMP where [SBU Delivery (PC2Geo mapping)]not  in ('CMT NA','FSI NA','HEALTH NA'))P


CREATE table #SBU_FINAL 
  
(  
[SBU Delivery (PC2Geo mapping)] VARCHAR(50),
[Overall FTE]VARCHAR(50),
[ADM FTE] VARCHAR(50),
[Overall #FTE with TSC %=0] VARCHAR(50),
[Overall #FTE with TSC %>0 to 25] VARCHAR(50),
[Overall #FTE with TSC %>25 to 50] VARCHAR(50),
[Overall #FTE with TSC %>50 to 80] VARCHAR(50),
[Overall #FTE with TSC %>80] VARCHAR(50),
[ADM #FTE with TSC %>80] VARCHAR(50),
[Available Hours (All)] VARCHAR(50),
[Available Hours (ADM)] VARCHAR(50),
[Actual Effort (All)] VARCHAR(50),
[Actual Effort (ADM)] VARCHAR(50),
[AD Scope-BU Effort Compliance%(All)] VARCHAR(50),
[AM Scope-BU Effort Compliance%(All)] VARCHAR(50),
[INTEGRATED Scope-BU Effort Compliance%(All)] VARCHAR(50),
[BU Effort Compliance%(All)] VARCHAR(50),
[AD Scope-BU Associate Compliance% (All)] VARCHAR(50),
[AM Scope-BU Associate Compliance% (All)] VARCHAR(50),
[INTEGRATED Scope-BU Associate Compliance% (All)] VARCHAR(50),
[BU Associate Compliance% (All)] VARCHAR(50),
[AD Scope-BU Effort Compliance%(ADM)] VARCHAR(50),
[AM Scope-BU Effort Compliance%(ADM)] VARCHAR(50),
[INTEGRATED Scope-BU Effort Compliance%(ADM)] VARCHAR(50),
[BU Effort Compliance%(ADM)] VARCHAR(50),
[AD Scope-BU Associate Compliance% (ADM)] VARCHAR(50),
[AM Scope-BU Associate Compliance% (ADM)] VARCHAR(50),
[INTEGRATED Scope-BU Associate Compliance% (ADM)] VARCHAR(50),
[BU Associate Compliance% (ADM)] VARCHAR(50),

) 

iNSERT INTO #SBU_FINAL
SELECT * FROM #fINAL_SBU

SELECT [SBU Delivery (PC2Geo mapping)],[Overall FTE],[ADM FTE],[Overall #FTE with TSC %=0],[Overall #FTE with TSC %>0 to 25],[Overall #FTE with TSC %>25 to 50],
[Overall #FTE with TSC %>50 to 80],[Overall #FTE with TSC %>80],[ADM #FTE with TSC %>80],[Available Hours (All)],[Available Hours (ADM)],
[Actual Effort (All)],[Actual Effort (ADM)],[AD Scope-BU Effort Compliance%(All)],[AM Scope-BU Effort Compliance%(All)],
[INTEGRATED Scope-BU Effort Compliance%(All)],[BU Effort Compliance%(All)],[AD Scope-BU Associate Compliance% (All)],
[AM Scope-BU Associate Compliance% (All)],[INTEGRATED Scope-BU Associate Compliance% (All)],[BU Associate Compliance% (All)],
[AD Scope-BU Effort Compliance%(ADM)],[AM Scope-BU Effort Compliance%(ADM)],[INTEGRATED Scope-BU Effort Compliance%(ADM)],
[BU Effort Compliance%(ADM)],[AD Scope-BU Associate Compliance% (ADM)],[AM Scope-BU Associate Compliance% (ADM)],
[INTEGRATED Scope-BU Associate Compliance% (ADM)],[BU Associate Compliance% (ADM)]
 FROM #SBU_FINAL where [SBU Delivery (PC2Geo mapping)] not in ('LATAM')

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
  
 insert into [Adp].[Project_Compliance_Monthly] (Parent_Accountid,Parent_AccountName,EsaProjectid,ProjectName,SBU,[PO ID],[PO Name],[DM ID],[DM Name],[PM ID],[PM Name],Project_Department,DE_Inscope,  
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
  EXEC [AppVisionLens].dbo.AVL_InsertError '[dbo].[ACCOUNT_PROJECT_SUMMARY_RAW]  ', @ErrorMessage, '',''  
  RETURN @ErrorMessage  
  END CATCH     
  
END  