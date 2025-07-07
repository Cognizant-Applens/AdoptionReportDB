USE [AdoptionReport]
GO
/****** Object:  StoredProcedure [ADPR].[AssociateData_WeeklyAndMonthly_AllBU]    Script Date: 11/3/2023 12:47:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [ADPR].[AssociateData_WeeklyAndMonthly_AllBU] --'ADM','Week'
(
@ReportType varchar(10),
@JobType varchar(10)
)
AS  
BEGIN    
BEGIN TRY   
SET NOCOUNT ON;

DECLARE @StartDate date        
DECLARE @EndDate date        
DECLARE @WorkHours int        
DECLARE @WorkdAYS int        
DECLARE @MASCOUNT Decimal(10,1)        
DECLARE @FirstDay date        
DECLARE @LastDate date        
DECLARE @DatepartToday INT 
SET @DatepartToday = DATEPART(dd, GETDATE())    


IF @JobType = 'Week' BEGIN
	IF(@DatepartToday != 3)       
	BEGIN        
		SELECT @FirstDay = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE() - 2), 0), @LastDate = GETDATE() - 2           
		SELECT @StartDate = (SELECT @FirstDay), @EndDate = (SELECT @LastDate)        
	END ELSE BEGIN       
		SELECT @FirstDay = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE() - 3), 0), @LastDate = GETDATE() - 3       
		SELECT @StartDate = (SELECT @FirstDay), @EndDate = (SELECT @LastDate)    
	END END
ELSE
	BEGIN
		IF(@DatepartToday != 3)  
		BEGIN  
			SELECT @FirstDay = DATEADD(month, DATEDIFF(month, -2, getdate()) -2, 0)  
			SELECT @LastDate =  DATEADD(ss, -1, DATEADD(month, DATEDIFF(month, 0, getdate()), 0))  
		END ELSE BEGIN  
			SELECT @FirstDay = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE() - 3), 0)  
			SELECT @LastDate = GETDATE() - 3  
		END 
		SET @StartDate = (SELECT @FirstDay)  
		SET @EndDate = (SELECT @LastDate) 
	END

--SELECT @StartDate,@EndDate

IF OBJECT_ID(N'tempdb..#WeekDays') IS NOT NULL BEGIN DROP TABLE #WeekDays END 

CREATE TABLE #WeekDays (       
DateList DATE,      
DayWeek VARCHAR(15))    
        
DECLARE @Datepart1 INT        
SET @Datepart1 = DATEPART(dd, @FirstDay)    
  
DECLARE @Datepart2 INT      
SET @Datepart2 = DATEPART(dd, @LastDate)      
    
DECLARE @DATE DATE    
SET @DATE = @FirstDay    
        
WHILE(@Datepart2 >= @Datepart1)       
BEGIN        
INSERT INTO #WeekDays      
 SELECT    
  @DATE    
  ,DATENAME(dw, @DATE)    
  
SET @DATE = DATEADD(DAY, 1, @DATE)       
SET @Datepart1 = @Datepart1 + 1       
END    
    
    
DELETE FROM #WeekDays    
WHERE DayWeek IN ('Saturday', 'Sunday')    
  
select @WorkdAYS = (SELECT COUNT(1) AS WorkDays FROM #WeekDays)      
, @WorkHours = (SELECT (COUNT(1) * 8) AS WorkHours FROM #WeekDays)      
, @MASCOUNT = CONVERT(DECIMAL(10, 2), (22 / CONVERT(DECIMAL(10, 2), @WorkdAYS)))    
   
--SELECT CONVERT(VARCHAR, CONVERT(DATE, @StartDate), 9)        
--SELECT CONVERT(VARCHAR, CONVERT(DATE, @Enddate), 9)     
-------------------------------------------------------------------    
 IF OBJECT_ID(N'tempdb..#Temp_Applens') IS NOT NULL  
BEGIN DROP TABLE #Temp_Applens END
SELECT    
  AssociateID,AssociateName,Designation,Grade,Email,PassportNo,PassPortIssueDate,PassportExpiryDate,IsActive,LastModifiedDate,Supervisor_ID,Supervisor_Name,JobCode,      
Offshore_Onsite,Assignment_Location,City,[State],Country      
 ,CASE WHEN ISNUMERIC(SUBSTRING(Grade, 2, 2)) = 1 THEN SUBSTRING(Grade, 2, 2)    
  ELSE NULL END AS UpdatedGrade INTO #Temp_Applens    
  FROM [AppVisionLens].ESA.Associates   
  
 IF OBJECT_ID(N'tempdb..#Temp_BM_Applns') IS NOT NULL  
BEGIN DROP TABLE #Temp_BM_Applns END     
SELECT DISTINCT AssociateID,AssociateName,Designation,Grade,Email,PassportNo,PassPortIssueDate,PassportExpiryDate,IsActive,LastModifiedDate,Supervisor_ID,Supervisor_Name,JobCode,      
Offshore_Onsite,Assignment_Location,City,[State],Country,UpdatedGrade   INTO #Temp_BM_Applns FROM #Temp_Applens WHERE updatedGrade > 50    

 IF OBJECT_ID(N'tempdb..#Temp_BM_Applns_All_Grade') IS NOT NULL  
BEGIN DROP TABLE #Temp_BM_Applns_All_Grade END    
SELECT DISTINCT AssociateID,AssociateName,Designation,Grade,Email,PassportNo,PassPortIssueDate,PassportExpiryDate,IsActive,LastModifiedDate,Supervisor_ID,Supervisor_Name,JobCode,      
Offshore_Onsite,Assignment_Location,City,[State],Country,UpdatedGrade   INTO #Temp_BM_Applns_All_Grade FROM #Temp_Applens 

IF OBJECT_ID(N'tempdb..#Associalte_Final_AVM') IS NOT NULL  BEGIN DROP TABLE #Associalte_Final_AVM END

CREATE TABLE #Associalte_Final_AVM (
Parent_Accountid char(50)
,Parent_AccountName	varchar(100)
,SBU	varchar(50)
,Vertical	varchar(50)
,SDM_ID	char(50)
,SDM_Name	varchar(100)
,SDD_ID	char(50)
,SDD_Name	varchar(100)
,Project_ID	char(15)
,[Project Name]	varchar(100)
,Associate_id	char(15)
,Associate_Name	varchar(100)
,Allocation_Startdate	DATE
,Allocation_Enddate	DATE
,Allocation_Percentage	decimal (10,2)
,ESA_FTE_Count	decimal (10,2)
,Available_Hours	decimal (10,2)
,DE_Inscope	varchar(50)
,Department_Name	varchar(100)
,Job_code	varchar(50)
,Designation	varchar(50))

IF @ReportType = 'ADM' 
BEGIN
	INSERT INTO #Associalte_Final_AVM
	SELECT DISTINCT Parent_Accountid,Parent_AccountName,SBU, Vertical,SDM_ID ,SDM_Name ,SDD_ID ,SDD_Name       
	,Project_ID ,[Project Name],associate_id ,Associate_Name, Allocation_Startdate ,Allocation_Enddate ,Allocation_Percentage,            
	ESA_FTE_Count ,Available_Hours ,DE_Inscope ,Department_Name ,Job_Code,Designation        
	FROM [ADPR].[Associate_Allocation_Raw] WHERE Department_Name='ADM' OR Department_Name LIKE  '%AVM%' or  
	Department_Name LIKE  '%ADM-%' or Department_Name LIKE  'ADM%'   
END
ELSE IF @ReportType = 'AIA' 
BEGIN
	INSERT INTO #Associalte_Final_AVM
	SELECT DISTINCT Parent_Accountid,Parent_AccountName,SBU, Vertical,SDM_ID ,SDM_Name ,SDD_ID ,SDD_Name     
	,Project_ID ,[Project Name],associate_id ,Associate_Name, Allocation_Startdate ,Allocation_Enddate ,Allocation_Percentage,    
	ESA_FTE_Count ,Available_Hours ,DE_Inscope ,Department_Name ,Job_Code,Designation   
	FROM [ADPR].[Associate_Allocation_Raw] 
	WHERE Department_Name='AIA' OR Department_Name LIKE  '%AIA%' or
	Department_Name LIKE  '%AIA-%' 
END
ELSE IF @ReportType = 'CDB'
BEGIN
	INSERT INTO #Associalte_Final_AVM
	SELECT DISTINCT Parent_Accountid,Parent_AccountName,SBU, Vertical,SDM_ID ,SDM_Name ,SDD_ID ,SDD_Name     
	,Project_ID ,[Project Name],associate_id ,Associate_Name, Allocation_Startdate ,Allocation_Enddate ,Allocation_Percentage,    
	ESA_FTE_Count ,Available_Hours ,DE_Inscope ,Department_Name ,Job_Code,Designation 
	FROM [AdpR].Associate_Allocation_Raw 
	WHERE Department_Name='CDB' OR Department_Name LIKE  '%CDB%' or  
	Department_Name LIKE  '%CDB-%'  
END
ELSE IF @ReportType = 'EAS'
BEGIN
	INSERT INTO #Associalte_Final_AVM
	SELECT DISTINCT Parent_Accountid,Parent_AccountName,SBU, Vertical,SDM_ID ,SDM_Name ,SDD_ID ,SDD_Name     
	,Project_ID ,[Project Name],associate_id ,Associate_Name, Allocation_Startdate ,Allocation_Enddate ,Allocation_Percentage,    
	ESA_FTE_Count ,Available_Hours ,DE_Inscope ,Department_Name ,Job_Code,Designation 
	FROM [AdpR].Associate_Allocation_Raw 
	WHERE Department_Name='EAS' OR Department_Name LIKE  '%EAS%' or
	Department_Name LIKE  '%EAS-%' OR Department_Name LIKE  '%EPS%'
END
    
DELETE  from #Associalte_Final_AVM where associate_id='323477'        
    
 IF OBJECT_ID(N'tempdb..#Allocatedassoc') IS NOT NULL  
BEGIN DROP TABLE #Allocatedassoc END    
SELECT DISTINCT    
 AF.associate_id    
 ,AF.Associate_Name    
 ,lg.UserID    
 ,PM.EsaProjectID,PM.ProjectName    
 ,LG.ProjectID    
 ,AF. Parent_Accountid as ParentCustomerID    
 ,AF. Parent_AccountName as ParentCustomerName    
 ,LG.IsNonESAAuthorized    
 ,AF.DE_Inscope INTO #Allocatedassoc    
FROM #Associalte_Final_AVM AF    
LEFT JOIN [AppVisionLens].AVL.MAS_ProjectMaster PM    
 ON AF.Project_ID = PM.EsaProjectID    
LEFT JOIN [AppVisionLens].AVL.MAS_LoginMaster LG    
 ON PM.ProjectID = LG.ProjectID    
 AND AF.associate_id = lg.EmployeeID    
LEFT JOIN [AppVisionLens].AVL.Customer CS   ON PM.CustomerID = CS.CustomerID      
WHERE CS.IsDeleted = '0' AND PM.IsDeleted = '0'  
 
IF OBJECT_ID(N'tempdb..#TEMPR') IS NOT NULL  
BEGIN DROP TABLE #TEMPR END 
SELECT DISTINCT    
 LG.EmployeeID,LG.EmployeeName    
 ,PM.EsaProjectID,PM.ProjectName    
 ,lg.UserID    
 ,LG.ProjectID    
 ,LG.IsNonESAAuthorized --B.DE_Inscope     
INTO #TEMPR    
FROM [AppVisionLens].AVL.MAS_LoginMaster LG    
JOIN #Temp_BM_Applns APS    
 ON LG.EmployeeID = APS.associateid    
LEFT JOIN [AppVisionLens].AVL.MAS_ProjectMaster PM    
 ON LG.ProjectID = PM.ProjectID    
LEFT JOIN [AdpR].Input_Data_AssociateRAW AD    
 ON PM.EsaProjectID = ad.EsaProjectID    
LEFT JOIN [AdpR].Input_Excel_Associate B ON PM.EsaProjectID=b.EsaProjectID    
WHERE LG.IsDeleted = '0'    
AND PM.IsDeleted = '0'    

IF OBJECT_ID(N'tempdb..#LoginAssociate') IS NOT NULL  
BEGIN DROP TABLE #LoginAssociate END          
SELECT DISTINCT    
 EmployeeID,EMployeeName    
 ,EsaProjectID,ProjectName    
 ,UserID    
 ,ProjectID    
 ,ParentCustomerID    
 ,ParentCustomerName    
 ,IsNonESAAuthorized    
 ,DE_Inscope    
 ,Dept_name    
 ,designation INTO #LoginAssociate    
FROM (SELECT DISTINCT    
  LG.EmployeeID,LG.EMployeeName    
  ,LG.EsaProjectID,LG.ProjectName    
  ,LG.UserID    
  ,LG.ProjectID    
  ,AF.Parent_Accountid as ParentCustomerID  
  ,AF.Parent_AccountName as ParentCustomerName  
  ,LG.IsNonESAAuthorized    
  ,AF.DE_Inscope ,CRS.[Dept_Name],CRS.[Designation]    
FROM #TEMPR LG    
 JOIN #Temp_BM_Applns APS ON LG.EmployeeID = APS.associateid    
 LEFT JOIN [AppVisionLens].AVL.MAS_ProjectMaster PM ON LG.ProjectID = PM.ProjectID    
 JOIN [AppVisionLens].AVL.Customer CS ON PM.CustomerID = CS.CustomerID     
 LEFT JOIN #Associalte_Final_AVM AF ON PM.EsaProjectID = AF.Project_ID    
 LEFT JOIN [Adp].[CentralRepository_Associate_Details] CRS ON LG.EmployeeID = crs.Associate_ID    
 WHERE CS.IsDeleted = '0' AND PM.IsDeleted = '0' AND Dept_name LIKE '%ADM%') TMP   

IF OBJECT_ID(N'tempdb..#Tempfin') IS NOT NULL  
BEGIN DROP TABLE #Tempfin END   
SELECT DISTINCT    
 EmployeeID,EmployeeName    
 ,UserID    
 ,EsaProjectID,Projectname    
 ,ProjectID    
 ,ParentCustomerID    
 ,ParentCustomerName    
 ,IsNonESAAuthorized    
 ,Dept_name  
 ,designation INTO #Tempfin    
FROM #LoginAssociate A    
WHERE NOT EXISTS (SELECT    
  *    
 FROM #Allocatedassoc B    
 WHERE a.EmployeeID = b.associate_id    
 AND a.EsaProjectID = b.EsaProjectID) 
 
IF OBJECT_ID(N'tempdb..#Loginmaster_associate') IS NOT NULL  
BEGIN DROP TABLE #Loginmaster_associate END    
CREATE Table #Loginmaster_associate    
(    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
UserID int ,    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
ProjectID int,    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
IsNonESAAuthorized bit,    
)    
    
      
INSERT INTO #Loginmaster_associate    
 SELECT DISTINCT    
  EmployeeID,Employeename    
  ,UserID    
  ,EsaProjectID,projectname    
  ,ProjectID    
  ,ParentCustomerID    
  ,ParentCustomerName    
  ,IsNonESAAuthorized    
 FROM #LoginAssociate    
    
 UNION SELECT DISTINCT    
  associate_id,associate_name    
  ,UserID    
  ,EsaProjectID,projectname    
  ,ProjectID    
  ,ParentCustomerID    
  ,ParentCustomerName    
  ,IsNonESAAuthorized    
 FROM #Allocatedassoc 
   
IF OBJECT_ID(N'tempdb..#MPS_Effort_App') IS NOT NULL  
BEGIN DROP TABLE #MPS_Effort_App END     
CREATE Table #MPS_Effort_App    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
IsNonESAAuthorized bit,    
MPS_Effort decimal (10,2),    
)    
   
INSERT INTO #MPS_Effort_APP    
    
 SELECT   DISTINCT  
  Parent_Accountid    
  ,Parent_AccountName    
  ,EsaProjectID,Projectname    
  ,EmployeeID,EmployeeName    
  ,IsNonESAAuthorized    
  ,ISNULL(SUM(c.Hours),0) As 'MPS_Effort'    
    
  FROM #Loginmaster_associate tmp    
 LEFT JOIN [AppVisionLens].AVL.TM_PRJ_Timesheet B    
  ON tmp.UserID = b.SubmitterId    
  AND B.TimesheetDate BETWEEN @StartDate AND @EndDate    
 LEFT JOIN [AppVisionLens].AVL.TM_TRN_TimesheetDetail C  ON b.TimesheetId = C.TimesheetId AND B.ProjectID=c.ProjectId     
    
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EsaProjectID,Projectname    
    ,EmployeeID,EmployeeName    
    ,IsNonESAAuthorized    
    
   
IF OBJECT_ID(N'tempdb..#MPS_Effort_Infra') IS NOT NULL  
BEGIN DROP TABLE #MPS_Effort_Infra END        
CREATE Table #MPS_Effort_Infra    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
IsNonESAAuthorized bit,    
Infra_Effort decimal (10,2),    
)    
    
INSERT INTO #MPS_Effort_Infra    
    
 SELECT   DISTINCT  
  Parent_Accountid    
  ,Parent_AccountName    
  ,EsaProjectID,Projectname    
  ,EmployeeID,EmployeeName    
  ,IsNonESAAuthorized    
  ,ISNULL(SUM(D.Hours),0) As 'MPS_Effort'    
   FROM #Loginmaster_associate tmp    
 LEFT JOIN [AppVisionLens].AVL.TM_PRJ_Timesheet B    
  ON tmp.UserID = b.SubmitterId    
  AND B.TimesheetDate BETWEEN @StartDate AND @EndDate    
  LEFT join [AppVisionLens].AVL.TM_TRN_InfraTimesheetDetail D on b.TimesheetId = D.TimesheetId AND B.ProjectID=d.ProjectId      
    
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EsaProjectID,Projectname    
    ,EmployeeID,EmployeeName    
    ,IsNonESAAuthorized    

   
IF OBJECT_ID(N'tempdb..#MPS_Effort_Workitem') IS NOT NULL  
BEGIN DROP TABLE #MPS_Effort_Workitem END    
CREATE Table #MPS_Effort_Workitem  
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
IsNonESAAuthorized bit,    
Workitem_Effort decimal (10,2),    
)    
    
INSERT INTO #MPS_Effort_Workitem      
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EsaProjectID,Projectname    
  ,EmployeeID,EmployeeName    
  ,IsNonESAAuthorized    
  ,ISNULL(SUM(D.Hours),0) As 'MPS_Effort'    
   FROM #Loginmaster_associate tmp    
 LEFT JOIN [AppVisionLens].AVL.TM_PRJ_Timesheet B    
  ON tmp.UserID = b.SubmitterId    
  AND B.TimesheetDate BETWEEN @StartDate AND @EndDate      
  LEFT join [AppVisionLens].ADM.TM_TRN_WorkItemTimesheetDetail D on b.TimesheetId = D.TimesheetId --AND B.ProjectID=d.ProjectId      
  
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EsaProjectID,Projectname    
    ,EmployeeID,EmployeeName    
    ,IsNonESAAuthorized    

IF OBJECT_ID(N'tempdb..#MPS_Effort') IS NOT NULL  
BEGIN DROP TABLE #MPS_Effort END   
CREATE Table #MPS_Effort    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
IsNonESAAuthorized bit,    
MPS_Effort decimal (10,2),    
)    
    
INSERT INTO #MPS_Effort    
    
select  DISTINCT    
  A.Parent_Accountid    
  ,A.Parent_AccountName    
  ,A.EsaProjectID,A.Projectname    
  ,A.EmployeeID,A.EmployeeName    
  ,A.IsNonESAAuthorized ,Isnull(sum(AP.MPS_Effort+INF.Infra_Effort),0) as 'MPS'  --Isnull(sum(AP.MPS_Effort+INF.Infra_Effort+WI.Workitem_Effort),0) as 'MPS'    
  FROM #Loginmaster_associate A    
   Left join #MPS_Effort_App AP on a.EmployeeID=AP.employeeid and  A.EsaProjectID=AP.EsaProjectID    
  left Join #MPS_Effort_Infra InF on a.EmployeeID=inf.employeeid and A.EsaProjectID=inf.EsaProjectID    
  --left join #MPS_Effort_Workitem WI on a.EmployeeID=WI.EmployeeID and A.EsaProjectID=WI.EsaProjectID  
  group by  A.Parent_Accountid    
  ,A.Parent_AccountName    
  ,A.EsaProjectID,A.Projectname    
  ,A.EmployeeID,A.EmployeeName    
  ,A.IsNonESAAuthorized    
    
IF OBJECT_ID(N'tempdb..#MAS_Effort') IS NOT NULL  
BEGIN DROP TABLE #MAS_Effort END         
CREATE Table #MAS_Effort    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
IsNonESAAuthorized bit,    
MAS_Effort decimal (10,2)    
)    
    
INSERT INTO #MAS_Effort    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,A.EsaProjectID,A.Projectname    
  ,A.EmployeeID,A.EmployeeName    
  ,IsNonESAAuthorized    
  ,ISNULL(SUM(b.Hours), 0) AS 'MAS_Effort'    
 FROM #Loginmaster_associate A    
LEFT JOIN [CPCINCHPV004140].[DiscoverEDS].[EDS].[TimesheetDetail_All_Enhancement] B    
  ON a.EmployeeID = b.[SubmitterID]    
  AND a.EsaProjectID = b.[ESAProjectID]    
  AND B.[TimesheetSubmissionDate] BETWEEN @StartDate AND @EndDate  
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,A.EsaProjectID,A.Projectname    
  ,A.EmployeeID,A.EmployeeName    
    ,IsNonESAAuthorized    
        
IF OBJECT_ID(N'tempdb..#Total_Effort') IS NOT NULL  
BEGIN DROP TABLE #Total_Effort END      
CREATE Table #Total_Effort    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
MPS_Effort decimal (10,2),  
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2)    
)    
    
INSERT INTO #Total_Effort    
    
 SELECT DISTINCT    
  A.Parent_Accountid    
  ,A.Parent_AccountName    
  ,A.EsaProjectID,A.Projectname    
  ,A.EmployeeID,A.EmployeeName    
  ,SUM(ISNULL(MP.MPS_Effort, 0))    
   ,SUM(ISNULL(WI.Workitem_Effort, 0))  
  ,SUM(ISNULL(MA.MAS_Effort, 0))    
  ,SUM(ISNULL(MP.MPS_Effort, 0) + ISNULL(WI.Workitem_Effort, 0) + ISNULL(MA.MAS_Effort, 0)) 'Actual_Effort'    
 FROM #Loginmaster_associate A    
    
 LEFT JOIN #MPS_Effort MP    
  ON a.EmployeeID = MP.EmployeeID    
  AND a.EsaProjectID = mp.EsaProjectID    
    
left join #MPS_Effort_Workitem WI  
on a.EmployeeID=WI.EmployeeID  
and a.EsaProjectID=wi.EsaProjectID  
  
 LEFT JOIN #MAS_Effort MA    
  ON a.EmployeeID = MA.EmployeeID    
  AND a.EsaProjectID = mA.EsaProjectID    
    
 GROUP BY A.Parent_Accountid    
    ,A.Parent_AccountName    
   ,A.EsaProjectID,A.Projectname    
    ,A.EmployeeID,A.EmployeeName    
 
 IF OBJECT_ID(N'tempdb..#Associate_FTE_Hours') IS NOT NULL  
BEGIN DROP TABLE #Associate_FTE_Hours END    
CREATE table #Associate_FTE_Hours    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
Avaialble_FTE_Below_M decimal (10,4),    
Available_Hours decimal (10,2)    
)    
    
INSERT INTO #Associate_FTE_Hours    
    
SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,Project_ID,[Project Name]    
  ,associate_id    
  ,Associate_Name    
  ,ISNULL(SUM(ESA_FTE_Count), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
 FROM #Associalte_Final_AVM A  
 INNER JOIN #Temp_BM_Applns B On A.Associate_id=B.AssociateID 
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
   ,Project_ID,[Project Name]    
  ,associate_id    
  ,Associate_Name    

IF OBJECT_ID(N'tempdb..#Associate_Summary') IS NOT NULL  
BEGIN DROP TABLE #Associate_Summary END     
CREATE Table #Associate_Summary    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
SBU nvarchar (50),    
Vertical varchar (50),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
Avaialble_FTE_Below_M decimal (10,4),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),   
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_Compliance decimal (10,2)    
)    
    
INSERT INTO #Associate_Summary    
    
 SELECT DISTINCT    
  af.Parent_Accountid    
  ,af.Parent_AccountName        
  ,BU.PracticeOwner,Bu.ProjectOwningPractice    
  ,af.EsaProjectID,AF.Projectname    
  ,af.EmployeeID,AF.EmployeeName    
  ,ISNULL((Avaialble_FTE_Below_M), 0) AS ESA_FTE    
  ,ISNULL((Available_Hours), 0)    
  AS Available_hours    
  ,ISNULL((B.MPS_Effort), 0)    
  ,ISNULL((B.Work_Profile_AD),0)  
  ,ISNULL((B.MAS_Effort), 0)    
  ,ISNULL((B.Actual_Effort), 0)    
  ,ISNULL(((Actual_Effort / NULLIF(Available_Hours, 0)) * 100), 0)    
 FROM #Associate_FTE_Hours AF    
     
 join [AdpR].Input_Data_AssociateRAW BU    
  ON af.EsaProjectID = bU.EsaProjectID    
 LEFT JOIN #Total_Effort B    
  ON af.Parent_Accountid = b.Parent_Accountid    
  AND af.Parent_AccountName = b.Parent_AccountName    
  AND af.EsaProjectID = b.EsaProjectID    
  AND af.EmployeeID = b.EmployeeID  
  

IF OBJECT_ID(N'tempdb..#department') IS NOT NULL BEGIN DROP TABLE #department END   
    
select distinct Parent_Accountid,SBU,VERTICAL,Associate_ID,project_id, Department_Name into #department from [AdpR].Associate_Allocation_Raw     

IF OBJECT_ID(N'tempdb..#designation') IS NOT NULL BEGIN DROP TABLE #designation END   
SELECT DISTINCT Parent_Accountid,SBU,VERTICAL,Associate_ID, project_id,Job_code,Designation into #designation from [AdpR].Associate_Allocation_Raw     

IF OBJECT_ID(N'tempdb..#AssociateSummarytmp') IS NOT NULL  
BEGIN DROP TABLE #AssociateSummarytmp END     
SELECT DISTINCT    
 a.Parent_Accountid    
  ,a.Parent_AccountName,A.SBU,A.Vertical    
  ,a.EmployeeID,A.EmployeeName,    
  A.EsaProjectID,A.Projectname    
  ,SUM(A.Avaialble_FTE_Below_M)AS 'Avaialble_FTE_Below_M'    
  ,SUM(A.Available_Hours) AS 'Available_Hours'    
  ,SUM(A.MPS_Effort) AS 'MPS_Effort'  
  ,sum(A.Work_Profile_AD) as 'Work_Profile_AD'  
  ,SUM(A.MAS_Effort) AS 'MAS_Effort'    
  ,SUM(A.Actual_Effort) AS 'Actual_Effort'    
  ,ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours), 0) * 100), 0) AS 'Associate_Account_Compliance' into #AssociateSummarytmp    
 FROM #Associate_Summary A    
  GROUP BY A.Parent_Accountid    
    ,A.Parent_AccountName,A.SBU,a.Vertical    
    ,EmployeeID,A.EsaProjectID,A.EmployeeName,A.Projectname    
    
IF OBJECT_ID(N'tempdb..#AssociateActual_Final_AVM') IS NOT NULL  
BEGIN DROP TABLE #AssociateActual_Final_AVM END      
CREATE Table #AssociateActual_Final_AVM    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
SBU nvarchar (50),    
Vertical varchar (50),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
Department_Name varchar(100),    
Job_Code varchar(50),    
Designation varchar(100),    
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_Account_Compliance decimal (10,2)    
)    
    
    
INSERT INTO #AssociateActual_Final_avm    
    
SELECT DISTINCT    
 a.Parent_Accountid    
  ,a.Parent_AccountName,A.SBU,A.Vertical,EsaProjectID,Projectname    
  ,a.EmployeeID,EmployeeName,Department_Name,Job_code,Designation    
  ,(A.Avaialble_FTE_Below_M)    
  ,(A.Available_Hours)    
  ,(A.MPS_Effort)   
  ,(A.Work_Profile_AD)  
  ,(A.MAS_Effort)    
  ,(A.Actual_Effort)    
  ,Associate_Account_Compliance    
 FROM #AssociateSummarytmp A    
 left outer join #department dp ON A.EmployeeID = dp.Associate_ID and a.Parent_Accountid=dp.Parent_Accountid and A.EsaProjectID=dp.Project_ID AND a.SBU=dp.SBU    
     
 left outer join #designation ds ON A.EmployeeID = ds.Associate_ID and a.Parent_Accountid=ds.Parent_Accountid and A.EsaProjectID=ds.Project_ID AND a.SBU=ds.SBU    
 ---UMA----
 --SELECT * FROM #AssociateActual_Final_AVM WHERE EmployeeID =111309         
 --ORDER BY Parent_Accountid,  EsaProjectID,EmployeeID


 
   
     
IF OBJECT_ID(N'tempdb..#Associate_BUcompliance_AVM') IS NOT NULL  
BEGIN DROP TABLE #Associate_BUcompliance_AVM END    
CREATE Table #Associate_BUcompliance_AVM    
(    
    
SBU varchar (100),    
EmployeeID varchar(15),    
Department_Name varchar(100),   
Project_Scope varchar(50),  
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),   
Work_Profile_AD decimal (10,2),   
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_BU_Compliance decimal (10,2)    
)    
    
    
INSERT INTO #Associate_BUcompliance_AVM    
       
SELECT DISTINCT A.SBU,A.EmployeeID,A.Department_Name,C.PROJECTSCOPE,sum(A.Avaialble_FTE_Below_M),sum(A.Available_Hours),sum(A.MPS_Effort), sum(A.Work_Profile_AD),   
Sum(A.MAS_Effort),sum(A.Actual_Effort),ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours), 0) * 100), 0) from #AssociateActual_Final_AVM A    
JOIN [AdpR].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'    
GROUP BY SBU,EmployeeID,Department_Name ,C.PROJECTSCOPE   
    
 IF OBJECT_ID(N'tempdb..#ScopeBU') IS NOT NULL  
BEGIN DROP TABLE #ScopeBU END     
select A.SBU,C.ProjectScope,count(A.EsaProjectID) as 'Project#' Into #ScopeBU from #AssociateActual_Final_AVM A  
JOIN [AdpR].Input_Data_AssociateRAW C ON A.parent_accountid=C.parentaccountid and a.EsaProjectID=C.EsaProjectID     
group by A.SBU,C.ProjectScope  
   
--AVM Scopr BU Compliance  
 IF OBJECT_ID(N'tempdb..#Associate_Greater80_SBU_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater80_SBU_AM END  
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater80_SBU_AM    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] > 80  and Project_Scope='AVM'  

 IF OBJECT_ID(N'tempdb..#Associate_Greater_50_80_SBU_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_50_80_SBU_AM END    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_50_80_SBU_AM    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80  and Project_Scope='AVM'  

 IF OBJECT_ID(N'tempdb..#Associate_Greater_25_50_SBU_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_25_50_SBU_AM END     
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_25_50_SBU_AM    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50  and Project_Scope='AVM'  

IF OBJECT_ID(N'tempdb..#Associate_Greater_0_25_SBU_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_0_25_SBU_AM END     
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_0_25_SBU_AM    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25  and Project_Scope='AVM'  

IF OBJECT_ID(N'tempdb..#Associate_Greater_zero_SBU_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_zero_SBU_AM END     
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_zero_SBU_AM    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] =0  and Project_Scope='AVM'  
 
IF OBJECT_ID(N'tempdb..#Associate_80_SBU_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_80_SBU_AM END
CREATE TABLE #Associate_80_SBU_AM    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_SBU_AM    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)    
 FROM #Associate_Greater80_SBU_AM    
 GROUP BY SBU    
    ,EmployeeID    
    
    
IF OBJECT_ID(N'tempdb..#Associate_50_80_SBU_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_50_80_SBU_AM END    
CREATE TABLE #Associate_50_80_SBU_AM    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_SBU_AM    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_50_80_SBU_AM     
 GROUP BY SBU    
    ,EmployeeID    
    
    
IF OBJECT_ID(N'tempdb..#Associate_25_50_SBU_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_25_50_SBU_AM END    
CREATE TABLE #Associate_25_50_SBU_AM    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_SBU_AM    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_25_50_SBU_AM    
 GROUP BY SBU    
    ,EmployeeID    
    
 IF OBJECT_ID(N'tempdb..#Associate_0_25_SBU_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_0_25_SBU_AM END   
CREATE TABLE #Associate_0_25_SBU_AM    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_SBU_AM    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_0_25_SBU_AM    
 GROUP BY SBU    
    ,EmployeeID    
    
 IF OBJECT_ID(N'tempdb..#Associate_0_SBU_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_0_SBU_AM END     
CREATE TABLE #Associate_0_SBU_AM    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_SBU_AM    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_Zero_SBU_AM    
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#SBU_Compliance_AVM_AM') IS NOT NULL  
BEGIN DROP TABLE #SBU_Compliance_AVM_AM END     
CREATE table #SBU_Compliance_AVM_AM    
    
(    
SBU nvarchar (50),    
ESA_FTE decimal (10,2),    
ESA_FTE_Zero  decimal (10,2),    
ESA_FTE_0_25  decimal (10,2),    
ESA_FTE_25_50  decimal (10,2),    
ESA_FTE_50_80  decimal (10,2),    
ESA_FTE_80  decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),    
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
BU_Effort_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #SBU_Compliance_AVM_AM    
    
 SELECT DISTINCT    
  a.SBU    
  ,ISNULL(SUM(Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(f.ESA_FTE_0_BU), 0)    
  ,ISNULL(SUM(e.ESA_FTE_0_25_BU), 0)    
  ,ISNULL(SUM(D.ESA_FTE_25_50_BU), 0)    
  ,ISNULL(SUM(C.ESA_FTE_50_80_BU), 0)    
  ,ISNULL(SUM(b.ESA_FTE_80_BU), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
  ,ISNULL(SUM(MPS_Effort), 0)   
  ,ISNULL(SUM(Work_Profile_AD),0)  
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_BUcompliance_AVM A    
 LEFT JOIN #Associate_0_SBU_AM F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_SBU_AM E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_SBU_AM D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_SBU_AM C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_SBU_AM B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
 where A.Project_scope='AVM'   
    
 GROUP BY a.SBU    
    
IF OBJECT_ID(N'tempdb..#BUDATA_AM') IS NOT NULL  
BEGIN DROP TABLE #BUDATA_AM END    
    
SELECT DISTINCT SBU ,ESA_FTE ,ESA_FTE_Zero ,ESA_FTE_0_25 ,ESA_FTE_25_50 ,ESA_FTE_50_80 ,ESA_FTE_80 ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,BU_Effort_Compliance_Percent ,    
Associate_Compliance_Percent INTO #BUDATA_AM    
FROM #SBU_Compliance_AVM_AM   
  
INSERT INTO #SBU_Compliance_AVM_AM    
    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE)) AS 'AVM_FTE'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_Zero)) AS 'AVM FTE with TSC %=0'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_0_25)) AS 'AVM FTE with TSC %>0 to 25'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_25_50)) AS 'AVM FTE with TSC %>25 to 50'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_50_80)) AS 'AVM FTE with TSC %>50 to 80'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_80)) AS 'AVM FTE with TSC %>80'    
  ,SUM(CONVERT(DECIMAL(10,2), Available_Hours)) AS 'Available_Hours'    
  ,SUM(CONVERT(DECIMAL(10,2), MPS_Effort)) AS 'MPS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS 'Work_Profile_AD'    
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'Associate_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'    
    
 FROM #BUDATA_AM    
    
TRUNCATE table [AdpR].SBU_Compliance_AVM_AM    
    
INSERT INTO [AdpR].SBU_Compliance_AVM_AM    
    
SELECT   
 [SBU] AS 'SBU'    
 ,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,BU_Effort_Compliance_Percent    
 ,Associate_Compliance_Percent AS [AVM_Associate_BU_Compliance%]    
FROM #SBU_Compliance_AVM_AM    
ORDER BY CASE   WHEN [SBU]= 'GRAND TOTAL' THEN 1    
   ELSE 0    
END, [SBU]    
    
  
--AD Scopr BU COMPLIANCE  
IF OBJECT_ID(N'tempdb..#Associate_Greater80_SBU_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater80_SBU_AD END
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater80_SBU_AD   
FROM #Associate_BUcompliance_AVM  
WHERE [Associate_BU_Compliance] > 80  and Project_Scope='AD'  

IF OBJECT_ID(N'tempdb..#Associate_Greater_50_80_SBU_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_50_80_SBU_AD END    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_50_80_SBU_AD    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80  and Project_Scope='AD'  

IF OBJECT_ID(N'tempdb..#Associate_Greater_25_50_SBU_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_25_50_SBU_AD END     
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_25_50_SBU_AD    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50  and Project_Scope='AD'  

IF OBJECT_ID(N'tempdb..#Associate_Greater_0_25_SBU_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_0_25_SBU_AD END    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_0_25_SBU_AD    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25  and Project_Scope='AD'  

IF OBJECT_ID(N'tempdb..#Associate_Greater_zero_SBU_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_zero_SBU_AD END    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_zero_SBU_AD    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] =0  and Project_Scope='AD'  
    
    
IF OBJECT_ID(N'tempdb..#Associate_80_SBU_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_80_SBU_AD END     
CREATE TABLE #Associate_80_SBU_AD    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_SBU_AD    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)    
 FROM #Associate_Greater80_SBU_AD    
 GROUP BY SBU    
    ,EmployeeID    
    
    
IF OBJECT_ID(N'tempdb..#Associate_50_80_SBU_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_50_80_SBU_AD END     
CREATE TABLE #Associate_50_80_SBU_AD    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_SBU_AD    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_50_80_SBU_AD     
 GROUP BY SBU    
    ,EmployeeID    
    
    
IF OBJECT_ID(N'tempdb..#Associate_25_50_SBU_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_25_50_SBU_AD END    
CREATE TABLE #Associate_25_50_SBU_AD    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_SBU_AD    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_25_50_SBU_AD    
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_0_25_SBU_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_0_25_SBU_AD END   
CREATE TABLE #Associate_0_25_SBU_AD    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_SBU_AD    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_0_25_SBU_AD    
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_0_SBU_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_0_SBU_AD END    
CREATE TABLE #Associate_0_SBU_AD    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_SBU_AD    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_Zero_SBU_AD    
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#SBU_Compliance_AVM_AD') IS NOT NULL  
BEGIN DROP TABLE #SBU_Compliance_AVM_AD END    
CREATE table #SBU_Compliance_AVM_AD    
    
(    
SBU nvarchar (50),    
ESA_FTE decimal (10,2),    
ESA_FTE_Zero  decimal (10,2),    
ESA_FTE_0_25  decimal (10,2),    
ESA_FTE_25_50  decimal (10,2),    
ESA_FTE_50_80  decimal (10,2),    
ESA_FTE_80  decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),    
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
BU_Effort_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #SBU_Compliance_AVM_AD    
    
 SELECT DISTINCT    
  a.SBU    
  ,ISNULL(SUM(Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(f.ESA_FTE_0_BU), 0)    
  ,ISNULL(SUM(e.ESA_FTE_0_25_BU), 0)    
  ,ISNULL(SUM(D.ESA_FTE_25_50_BU), 0)    
  ,ISNULL(SUM(C.ESA_FTE_50_80_BU), 0)    
  ,ISNULL(SUM(b.ESA_FTE_80_BU), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
  ,ISNULL(SUM(MPS_Effort), 0)   
  ,ISNULL(SUM(Work_Profile_AD),0)  
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_BUcompliance_AVM A    
 LEFT JOIN #Associate_0_SBU_AD F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_SBU_AD E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_SBU_AD D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_SBU_AD C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_SBU_AD B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
 where A.Project_scope='AD'   
    
 GROUP BY a.SBU    
    
    
IF OBJECT_ID(N'tempdb..#BUDATA_AD') IS NOT NULL  
BEGIN DROP TABLE #BUDATA_AD END    
SELECT DISTINCT SBU ,ESA_FTE ,ESA_FTE_Zero ,ESA_FTE_0_25 ,ESA_FTE_25_50 ,ESA_FTE_50_80 ,ESA_FTE_80 ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,BU_Effort_Compliance_Percent ,    
Associate_Compliance_Percent INTO #BUDATA_AD    
FROM #SBU_Compliance_AVM_AD  
  
  
INSERT INTO #SBU_Compliance_AVM_AD    
    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE)) AS 'AVM_FTE'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_Zero)) AS 'AVM FTE with TSC %=0'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_0_25)) AS 'AVM FTE with TSC %>0 to 25'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_25_50)) AS 'AVM FTE with TSC %>25 to 50'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_50_80)) AS 'AVM FTE with TSC %>50 to 80'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_80)) AS 'AVM FTE with TSC %>80'    
  ,SUM(CONVERT(DECIMAL(10,2), Available_Hours)) AS 'Available_Hours'    
  ,SUM(CONVERT(DECIMAL(10,2), MPS_Effort)) AS 'MPS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS 'Work_Profile_AD'    
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'Associate_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'    
    
 FROM #BUDATA_AD    
    
TRUNCATE table [AdpR].SBU_Compliance_AVM_AD    
    
INSERT INTO [ADPR].SBU_Compliance_AVM_AD    
    
SELECT   
 [SBU] AS 'SBU'    
 ,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,BU_Effort_Compliance_Percent    
 ,Associate_Compliance_Percent AS [AVM_Associate_BU_Compliance%]    
FROM #SBU_Compliance_AVM_AD    
ORDER BY CASE   WHEN [SBU]= 'GRAND TOTAL' THEN 1    
   ELSE 0    
END, [SBU]    
  
--INTEG Scopr BU COMPLIANCE  
IF OBJECT_ID(N'tempdb..#Associate_Greater80_SBU_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater80_SBU_INTEG END  
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater80_SBU_INTEG   
FROM #Associate_BUcompliance_AVM  
WHERE [Associate_BU_Compliance] > 80  and Project_Scope not in ('AD','AVM','')  

IF OBJECT_ID(N'tempdb..#Associate_Greater_50_80_SBU_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_50_80_SBU_INTEG END    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_50_80_SBU_INTEG    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80  and Project_Scope not in ('AD','AVM','')  

IF OBJECT_ID(N'tempdb..#Associate_Greater_25_50_SBU_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_25_50_SBU_INTEG END    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_25_50_SBU_INTEG    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50  and Project_Scope not in ('AD','AVM','')  

IF OBJECT_ID(N'tempdb..#Associate_Greater_0_25_SBU_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_0_25_SBU_INTEG END    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_0_25_SBU_INTEG    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25  and Project_Scope not in ('AD','AVM','')  

IF OBJECT_ID(N'tempdb..#Associate_Greater_zero_SBU_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_zero_SBU_INTEG END    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_zero_SBU_INTEG    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] =0  and Project_Scope not in ('AD','AVM','')  
    
    
IF OBJECT_ID(N'tempdb..#Associate_80_SBU_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_80_SBU_INTEG END    
CREATE TABLE #Associate_80_SBU_INTEG    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_SBU_INTEG    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)    
 FROM #Associate_Greater80_SBU_INTEG    
 GROUP BY SBU    
    ,EmployeeID    
    
    
IF OBJECT_ID(N'tempdb..#Associate_50_80_SBU_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_50_80_SBU_INTEG END     
CREATE TABLE #Associate_50_80_SBU_INTEG    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_SBU_INTEG    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_50_80_SBU_INTEG     
 GROUP BY SBU    
    ,EmployeeID    
    
    
 IF OBJECT_ID(N'tempdb..#Associate_25_50_SBU_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_25_50_SBU_INTEG END   
CREATE TABLE #Associate_25_50_SBU_INTEG    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_SBU_INTEG    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_25_50_SBU_INTEG    
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_0_25_SBU_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_0_25_SBU_INTEG END     
CREATE TABLE #Associate_0_25_SBU_INTEG    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_SBU_INTEG    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_0_25_SBU_INTEG    
 GROUP BY SBU    
    ,EmployeeID    
    
 IF OBJECT_ID(N'tempdb..#Associate_0_SBU_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_0_SBU_INTEG END    
CREATE TABLE #Associate_0_SBU_INTEG    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_SBU_INTEG    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_Zero_SBU_INTEG    
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#SBU_Compliance_AVM_INTEG') IS NOT NULL  
BEGIN DROP TABLE #SBU_Compliance_AVM_INTEG END   
CREATE table #SBU_Compliance_AVM_INTEG    
    
(    
SBU nvarchar (50),    
ESA_FTE decimal (10,2),    
ESA_FTE_Zero  decimal (10,2),    
ESA_FTE_0_25  decimal (10,2),    
ESA_FTE_25_50  decimal (10,2),    
ESA_FTE_50_80  decimal (10,2),    
ESA_FTE_80  decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),    
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
BU_Effort_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #SBU_Compliance_AVM_INTEG    
    
 SELECT DISTINCT    
  a.SBU    
  ,ISNULL(SUM(Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(f.ESA_FTE_0_BU), 0)    
  ,ISNULL(SUM(e.ESA_FTE_0_25_BU), 0)    
  ,ISNULL(SUM(D.ESA_FTE_25_50_BU), 0)    
  ,ISNULL(SUM(C.ESA_FTE_50_80_BU), 0)    
  ,ISNULL(SUM(b.ESA_FTE_80_BU), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
  ,ISNULL(SUM(MPS_Effort), 0)   
  ,ISNULL(SUM(Work_Profile_AD),0)  
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_BUcompliance_AVM A    
 LEFT JOIN #Associate_0_SBU_INTEG F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_SBU_INTEG E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_SBU_INTEG D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_SBU_INTEG C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_SBU_INTEG B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
 where A.Project_scope not in('AD','AVM','')   
    
 GROUP BY a.SBU    
    
 IF OBJECT_ID(N'tempdb..#BUDATA_INTEG') IS NOT NULL  
BEGIN DROP TABLE #BUDATA_INTEG END       
SELECT DISTINCT SBU ,ESA_FTE ,ESA_FTE_Zero ,ESA_FTE_0_25 ,ESA_FTE_25_50 ,ESA_FTE_50_80 ,ESA_FTE_80 ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,BU_Effort_Compliance_Percent ,    
Associate_Compliance_Percent INTO #BUDATA_INTEG    
FROM #SBU_Compliance_AVM_INTEG  
  
  
INSERT INTO #SBU_Compliance_AVM_INTEG    
    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE)) AS 'AVM_FTE'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_Zero)) AS 'AVM FTE with TSC %=0'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_0_25)) AS 'AVM FTE with TSC %>0 to 25'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_25_50)) AS 'AVM FTE with TSC %>25 to 50'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_50_80)) AS 'AVM FTE with TSC %>50 to 80'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_80)) AS 'AVM FTE with TSC %>80'    
  ,SUM(CONVERT(DECIMAL(10,2), Available_Hours)) AS 'Available_Hours'    
  ,SUM(CONVERT(DECIMAL(10,2), MPS_Effort)) AS 'MPS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS 'Work_Profile_AD'    
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'Associate_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'    
    
 FROM #BUDATA_INTEG    
    
TRUNCATE table [AdpR].SBU_Compliance_AVM_INTEG    
    
INSERT INTO [AdpR].SBU_Compliance_AVM_INTEG    
    
SELECT   
 [SBU] AS 'SBU'    
 ,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,BU_Effort_Compliance_Percent    
 ,Associate_Compliance_Percent AS [AVM_Associate_BU_Compliance%]    
FROM #SBU_Compliance_AVM_INTEG    
ORDER BY CASE   WHEN [SBU]= 'GRAND TOTAL' THEN 1    
   ELSE 0    
END, [SBU]    
  
  
 IF OBJECT_ID(N'tempdb..#Associate_BUcompliance_AVM_all') IS NOT NULL  
BEGIN DROP TABLE #Associate_BUcompliance_AVM_all END  
CREATE Table #Associate_BUcompliance_AVM_all    
(    
    
SBU varchar (100),    
EmployeeID varchar(15),    
Department_Name varchar(100),   
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),   
Work_Profile_AD decimal (10,2),   
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_BU_Compliance decimal (10,2)    
)    
    
    
INSERT INTO #Associate_BUcompliance_AVM_all    
    
    
    
SELECT DISTINCT A.SBU,A.EmployeeID,A.Department_Name,sum(A.Avaialble_FTE_Below_M),sum(A.Available_Hours),sum(A.MPS_Effort), sum(A.Work_Profile_AD),   
Sum(A.MAS_Effort),sum(A.Actual_Effort),ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours), 0) * 100), 0) from #AssociateActual_Final_AVM A    
JOIN [AdpR].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'    
GROUP BY SBU,EmployeeID,Department_Name   
  
  
  
-- All Scope BU Compliacne
IF OBJECT_ID(N'tempdb..#Associate_Greater80_SBU') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater80_SBU END
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater80_SBU    
FROM #Associate_BUcompliance_AVM_all   
WHERE [Associate_BU_Compliance] > 80    

IF OBJECT_ID(N'tempdb..#Associate_Greater_50_80_SBU') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_50_80_SBU END    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_50_80_SBU    
FROM #Associate_BUcompliance_AVM_all    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80    

IF OBJECT_ID(N'tempdb..#Associate_Greater_25_50_SBU') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_25_50_SBU END    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_25_50_SBU    
FROM #Associate_BUcompliance_AVM_all    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50    

IF OBJECT_ID(N'tempdb..#Associate_Greater_0_25_SBU') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_0_25_SBU END    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_0_25_SBU    
FROM #Associate_BUcompliance_AVM_all    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25    
 
 IF OBJECT_ID(N'tempdb..#Associate_Greater_zero_SBU') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_zero_SBU END
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_zero_SBU    
FROM #Associate_BUcompliance_AVM_all    
WHERE [Associate_BU_Compliance] =0    
    
 IF OBJECT_ID(N'tempdb..#Associate_80_SBU') IS NOT NULL BEGIN DROP TABLE #Associate_80_SBU END    
    
CREATE TABLE #Associate_80_SBU    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_SBU    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)    
 FROM #Associate_Greater80_SBU    
 GROUP BY SBU    
    ,EmployeeID    
    
 IF OBJECT_ID(N'tempdb..#Associate_50_80_SBU') IS NOT NULL BEGIN DROP TABLE #Associate_50_80_SBU END    
    
CREATE TABLE #Associate_50_80_SBU    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_SBU    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_50_80_SBU     
 GROUP BY SBU    
    ,EmployeeID    
    
 IF OBJECT_ID(N'tempdb..#Associate_25_50_SBU') IS NOT NULL BEGIN DROP TABLE #Associate_25_50_SBU END    
    
CREATE TABLE #Associate_25_50_SBU    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_SBU    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_25_50_SBU    
 GROUP BY SBU    
    ,EmployeeID    
    
 IF OBJECT_ID(N'tempdb..#Associate_0_25_SBU') IS NOT NULL BEGIN DROP TABLE #Associate_0_25_SBU END    
    
CREATE TABLE #Associate_0_25_SBU    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_SBU    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_0_25_SBU    
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_0_SBU') IS NOT NULL BEGIN DROP TABLE #Associate_0_SBU END    
    
CREATE TABLE #Associate_0_SBU    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_SBU    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_Zero_SBU    
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#SBU_Compliance_AVM') IS NOT NULL BEGIN DROP TABLE #SBU_Compliance_AVM END    
    
CREATE table #SBU_Compliance_AVM    
    
(    
SBU nvarchar (50),    
ESA_FTE decimal (10,2),    
ESA_FTE_Zero  decimal (10,2),    
ESA_FTE_0_25  decimal (10,2),    
ESA_FTE_25_50  decimal (10,2),    
ESA_FTE_50_80  decimal (10,2),    
ESA_FTE_80  decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),    
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
BU_Effort_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #SBU_Compliance_AVM    
    
 SELECT DISTINCT    
  a.SBU    
  ,ISNULL(SUM(Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(f.ESA_FTE_0_BU), 0)    
  ,ISNULL(SUM(e.ESA_FTE_0_25_BU), 0)    
  ,ISNULL(SUM(D.ESA_FTE_25_50_BU), 0)    
  ,ISNULL(SUM(C.ESA_FTE_50_80_BU), 0)    
  ,ISNULL(SUM(b.ESA_FTE_80_BU), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
  ,ISNULL(SUM(MPS_Effort), 0)   
  ,ISNULL(SUM(Work_Profile_AD),0)  
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_BUcompliance_AVM_all A    
 LEFT JOIN #Associate_0_SBU F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_SBU E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_SBU D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_SBU C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_SBU B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID        
 GROUP BY a.SBU      
 

 
 
    
    ---ALL GRADE ---
IF OBJECT_ID(N'tempdb..#TEMPR_All_Grade') IS NOT NULL BEGIN DROP TABLE #TEMPR_All_Grade END    

	SELECT DISTINCT    
 LG.EmployeeID,LG.EmployeeName    
 ,PM.EsaProjectID,PM.ProjectName    
 ,lg.UserID    
 ,LG.ProjectID    
 ,LG.IsNonESAAuthorized --B.DE_Inscope     
INTO #TEMPR_All_Grade    
FROM [AppVisionLens].AVL.MAS_LoginMaster LG    
JOIN #Temp_BM_Applns_All_Grade APS    
 ON LG.EmployeeID = APS.associateid    
LEFT JOIN [AppVisionLens].AVL.MAS_ProjectMaster PM    
 ON LG.ProjectID = PM.ProjectID    
LEFT JOIN [AdpR].Input_Data_AssociateRAW AD    
 ON PM.EsaProjectID = ad.EsaProjectID    
LEFT JOIN [AdpR].Input_Excel_Associate B ON PM.EsaProjectID=b.EsaProjectID    
WHERE LG.IsDeleted = '0'    
AND PM.IsDeleted = '0' 
IF OBJECT_ID(N'tempdb..#LoginAssociate_All_Grade') IS NOT NULL BEGIN DROP TABLE #LoginAssociate_All_Grade END    

 SELECT DISTINCT    
 EmployeeID,EMployeeName    
 ,EsaProjectID,ProjectName    
 ,UserID    
 ,ProjectID    
 ,ParentCustomerID    
 ,ParentCustomerName    
 ,IsNonESAAuthorized    
 ,DE_Inscope    
 ,Dept_name    
 ,designation INTO #LoginAssociate_All_Grade    
FROM (SELECT DISTINCT    
  LG.EmployeeID,LG.EMployeeName    
  ,LG.EsaProjectID,LG.ProjectName    
  ,LG.UserID    
  ,LG.ProjectID    
  ,AF.Parent_Accountid as ParentCustomerID  
  ,AF.Parent_AccountName as ParentCustomerName  
  ,LG.IsNonESAAuthorized    
  ,AF.DE_Inscope ,CRS.[Dept_Name],CRS.[Designation]    
FROM #TEMPR_All_Grade LG    
 JOIN #Temp_BM_Applns_All_Grade APS    
  ON LG.EmployeeID = APS.associateid    
 LEFT JOIN [AppVisionLens].AVL.MAS_ProjectMaster PM    
  ON LG.ProjectID = PM.ProjectID    
 JOIN [AppVisionLens].AVL.Customer CS    
  ON PM.CustomerID = CS.CustomerID    
  
 LEFT JOIN #Associalte_Final_AVM AF    
  ON PM.EsaProjectID = AF.Project_ID    
  
  LEFT JOIN [Adp].[CentralRepository_Associate_Details] CRS    
  
  ON LG.EmployeeID = crs.Associate_ID    
 WHERE     
 CS.IsDeleted = '0'    
 AND PM.IsDeleted = '0'      
  
 AND Dept_name LIKE '%ADM%') TMP    
   
IF OBJECT_ID(N'tempdb..#Loginmaster_associate_All_Grade') IS NOT NULL BEGIN DROP TABLE #Loginmaster_associate_All_Grade END    
    
CREATE Table #Loginmaster_associate_All_Grade    
(    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
UserID int ,    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
ProjectID int,    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
IsNonESAAuthorized bit,    
)    
    
    
    
INSERT INTO #Loginmaster_associate_All_Grade    
 SELECT DISTINCT    
  EmployeeID,Employeename    
  ,UserID    
  ,EsaProjectID,projectname    
  ,ProjectID    
  ,ParentCustomerID    
  ,ParentCustomerName    
  ,IsNonESAAuthorized    
 FROM #LoginAssociate_All_Grade    
    
 UNION SELECT DISTINCT    
  associate_id,associate_name    
  ,UserID    
  ,EsaProjectID,projectname    
  ,ProjectID    
  ,ParentCustomerID    
  ,ParentCustomerName    
  ,IsNonESAAuthorized    
 FROM #Allocatedassoc  
    
IF OBJECT_ID(N'tempdb..#MPS_Effort_App_All_Grade') IS NOT NULL BEGIN DROP TABLE #MPS_Effort_App_All_Grade END    
   
CREATE Table #MPS_Effort_App_All_Grade    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
IsNonESAAuthorized bit,    
MPS_Effort decimal (10,2),    
)    
    
INSERT INTO #MPS_Effort_App_All_Grade    
    
 SELECT   DISTINCT  
  Parent_Accountid    
  ,Parent_AccountName    
  ,EsaProjectID,Projectname    
  ,EmployeeID,EmployeeName    
  ,IsNonESAAuthorized    
  ,ISNULL(SUM(c.Hours),0) As 'MPS_Effort'    
    
  FROM #Loginmaster_associate_All_Grade tmp    
 LEFT JOIN [AppVisionLens].AVL.TM_PRJ_Timesheet B    
  ON tmp.UserID = b.SubmitterId    
  AND B.TimesheetDate BETWEEN @StartDate AND @EndDate    
 LEFT JOIN [AppVisionLens].AVL.TM_TRN_TimesheetDetail C  ON b.TimesheetId = C.TimesheetId AND B.ProjectID=c.ProjectId     
    
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EsaProjectID,Projectname    
    ,EmployeeID,EmployeeName    
    ,IsNonESAAuthorized    
    
    
IF OBJECT_ID(N'tempdb..#MPS_Effort_Infra_All_Grade') IS NOT NULL BEGIN DROP TABLE #MPS_Effort_Infra_All_Grade END    
    
CREATE Table #MPS_Effort_Infra_All_Grade    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
IsNonESAAuthorized bit,    
Infra_Effort decimal (10,2),    
)    
    
INSERT INTO #MPS_Effort_Infra_All_Grade    
    
 SELECT   DISTINCT  
  Parent_Accountid    
  ,Parent_AccountName    
  ,EsaProjectID,Projectname    
  ,EmployeeID,EmployeeName    
  ,IsNonESAAuthorized    
  ,ISNULL(SUM(D.Hours),0) As 'MPS_Effort'    
   FROM #Loginmaster_associate_All_Grade tmp    
 LEFT JOIN [AppVisionLens].AVL.TM_PRJ_Timesheet B    
  ON tmp.UserID = b.SubmitterId    
  AND B.TimesheetDate BETWEEN @StartDate AND @EndDate    
  LEFT join [AppVisionLens].AVL.TM_TRN_InfraTimesheetDetail D on b.TimesheetId = D.TimesheetId AND B.ProjectID=d.ProjectId      
    
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EsaProjectID,Projectname    
    ,EmployeeID,EmployeeName    
    ,IsNonESAAuthorized    

IF OBJECT_ID(N'tempdb..#MPS_Effort_Workitem_All_Grade') IS NOT NULL BEGIN DROP TABLE #MPS_Effort_Workitem_All_Grade END    
  
CREATE Table #MPS_Effort_Workitem_All_Grade  
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
IsNonESAAuthorized bit,    
Workitem_Effort decimal (10,2),    
)    
    
INSERT INTO #MPS_Effort_Workitem_All_Grade    
    
  
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EsaProjectID,Projectname    
  ,EmployeeID,EmployeeName    
  ,IsNonESAAuthorized    
  ,ISNULL(SUM(D.Hours),0) As 'MPS_Effort'    
   FROM #Loginmaster_associate_All_Grade tmp    
 LEFT JOIN [AppVisionLens].AVL.TM_PRJ_Timesheet B    
  ON tmp.UserID = b.SubmitterId    
  AND B.TimesheetDate BETWEEN @StartDate AND @EndDate      
  LEFT join [AppVisionLens].ADM.TM_TRN_WorkItemTimesheetDetail D on b.TimesheetId = D.TimesheetId --AND B.ProjectID=d.ProjectId      
  
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EsaProjectID,Projectname    
    ,EmployeeID,EmployeeName    
    ,IsNonESAAuthorized    
   
    
IF OBJECT_ID(N'tempdb..#MPS_Effort_All_Grade') IS NOT NULL BEGIN DROP TABLE #MPS_Effort_All_Grade END    
        
CREATE Table #MPS_Effort_All_Grade    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
IsNonESAAuthorized bit,    
MPS_Effort decimal (10,2),    
)    
    
INSERT INTO #MPS_Effort_All_Grade    
    
select  DISTINCT    
  A.Parent_Accountid    
  ,A.Parent_AccountName    
  ,A.EsaProjectID,A.Projectname    
  ,A.EmployeeID,A.EmployeeName    
  ,A.IsNonESAAuthorized ,Isnull(sum(AP.MPS_Effort+INF.Infra_Effort),0) as 'MPS'  --Isnull(sum(AP.MPS_Effort+INF.Infra_Effort+WI.Workitem_Effort),0) as 'MPS'    
  FROM #Loginmaster_associate_All_Grade A    
   Left join #MPS_Effort_App_All_Grade AP on a.EmployeeID=AP.employeeid and  A.EsaProjectID=AP.EsaProjectID    
  left Join #MPS_Effort_Infra_All_Grade InF on a.EmployeeID=inf.employeeid and A.EsaProjectID=inf.EsaProjectID    
  --left join #MPS_Effort_Workitem WI on a.EmployeeID=WI.EmployeeID and A.EsaProjectID=WI.EsaProjectID  
  group by  A.Parent_Accountid    
  ,A.Parent_AccountName    
  ,A.EsaProjectID,A.Projectname    
  ,A.EmployeeID,A.EmployeeName    
  ,A.IsNonESAAuthorized    
    
IF OBJECT_ID(N'tempdb..#MAS_Effort_All_Grade') IS NOT NULL BEGIN DROP TABLE #MAS_Effort_All_Grade END    
     
CREATE Table #MAS_Effort_All_Grade    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
IsNonESAAuthorized bit,    
MAS_Effort decimal (10,2)    
)    
    
INSERT INTO #MAS_Effort_All_Grade    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,A.EsaProjectID,A.Projectname    
  ,A.EmployeeID,A.EmployeeName    
  ,IsNonESAAuthorized    
  ,ISNULL(SUM(b.Hours), 0) AS 'MAS_Effort'    
 FROM #Loginmaster_associate_All_Grade A    
LEFT JOIN [CPCINCHPV004140].[DiscoverEDS].[EDS].[TimesheetDetail_All_Enhancement] B    
  ON a.EmployeeID = b.[SubmitterID]    
  AND a.EsaProjectID = b.[ESAProjectID]    
  AND B.[TimesheetSubmissionDate] BETWEEN @StartDate AND @EndDate  
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,A.EsaProjectID,A.Projectname    
  ,A.EmployeeID,A.EmployeeName    
    ,IsNonESAAuthorized    
    
     
IF OBJECT_ID(N'tempdb..#Total_Effort_All_Grade') IS NOT NULL BEGIN DROP TABLE #Total_Effort_All_Grade END    
    
CREATE Table #Total_Effort_All_Grade    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
MPS_Effort decimal (10,2),  
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2)    
)    
    
INSERT INTO #Total_Effort_All_Grade    
    
 SELECT DISTINCT    
  A.Parent_Accountid    
  ,A.Parent_AccountName    
  ,A.EsaProjectID,A.Projectname    
  ,A.EmployeeID,A.EmployeeName    
  ,SUM(ISNULL(MP.MPS_Effort, 0))    
   ,SUM(ISNULL(WI.Workitem_Effort, 0))  
  ,SUM(ISNULL(MA.MAS_Effort, 0))    
  ,SUM(ISNULL(MP.MPS_Effort, 0) + ISNULL(WI.Workitem_Effort, 0) + ISNULL(MA.MAS_Effort, 0)) 'Actual_Effort'    
 FROM #Loginmaster_associate_All_Grade A    
    
 LEFT JOIN #MPS_Effort_All_Grade MP    
  ON a.EmployeeID = MP.EmployeeID    
  AND a.EsaProjectID = mp.EsaProjectID    
    
left join #MPS_Effort_Workitem_All_Grade WI  
on a.EmployeeID=WI.EmployeeID  
and a.EsaProjectID=wi.EsaProjectID  
  
 LEFT JOIN #MAS_Effort_All_Grade MA    
  ON a.EmployeeID = MA.EmployeeID    
  AND a.EsaProjectID = mA.EsaProjectID    
    
 GROUP BY A.Parent_Accountid    
    ,A.Parent_AccountName    
   ,A.EsaProjectID,A.Projectname    
    ,A.EmployeeID,A.EmployeeName    

IF OBJECT_ID(N'tempdb..#Associate_FTE_Hours_All_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_FTE_Hours_All_Grade END    
    
CREATE table #Associate_FTE_Hours_All_Grade   
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
Avaialble_FTE_Below_M decimal (10,4),    
Available_Hours decimal (10,2)    
)    
    
INSERT INTO #Associate_FTE_Hours_All_Grade    
    
SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,Project_ID,[Project Name]    
  ,associate_id    
  ,Associate_Name    
  ,ISNULL(SUM(ESA_FTE_Count), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
 FROM #Associalte_Final_AVM  --WHERE Associate_id = '111309'   
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
   ,Project_ID,[Project Name]    
  ,associate_id    
  ,Associate_Name       
    
IF OBJECT_ID(N'tempdb..#Associate_Summary_All_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_Summary_All_Grade END    
    
 CREATE Table #Associate_Summary_All_Grade    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
SBU nvarchar (50),    
Vertical varchar (50),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
Avaialble_FTE_Below_M decimal (10,4),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),   
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_Compliance decimal (10,2)    
)    
 IF OBJECT_ID(N'tempdb..#AssociateSummarytmp_All_Grade') IS NOT NULL BEGIN DROP TABLE #AssociateSummarytmp_All_Grade END    
   
INSERT INTO #Associate_Summary_All_Grade   
    
 SELECT DISTINCT    
  af.Parent_Accountid    
  ,af.Parent_AccountName    
     
  ,BU.PracticeOwner,Bu.ProjectOwningPractice    
  ,af.EsaProjectID,AF.Projectname    
  ,af.EmployeeID,AF.EmployeeName    
  ,ISNULL((Avaialble_FTE_Below_M), 0) AS ESA_FTE    
  ,ISNULL((Available_Hours), 0)    
  AS Available_hours    
  ,ISNULL((B.MPS_Effort), 0)    
  ,ISNULL((B.Work_Profile_AD),0)  
  ,ISNULL((B.MAS_Effort), 0)    
  ,ISNULL((B.Actual_Effort), 0)    
  ,ISNULL(((Actual_Effort / NULLIF(Available_Hours, 0)) * 100), 0)    
 FROM #Associate_FTE_Hours_All_Grade AF    
     
 join [AdpR].Input_Data_AssociateRAW BU    
  ON af.EsaProjectID = bU.EsaProjectID    
 LEFT JOIN #Total_Effort_All_Grade B    
  ON af.Parent_Accountid = b.Parent_Accountid    
  AND af.Parent_AccountName = b.Parent_AccountName    
  AND af.EsaProjectID = b.EsaProjectID    
  AND af.EmployeeID = b.EmployeeID    

 SELECT DISTINCT    
 a.Parent_Accountid    
  ,a.Parent_AccountName,A.SBU,A.Vertical    
  ,a.EmployeeID,A.EmployeeName,    
  A.EsaProjectID,A.Projectname    
  ,SUM(A.Avaialble_FTE_Below_M)AS 'Avaialble_FTE_Below_M'    
  ,SUM(A.Available_Hours) AS 'Available_Hours'    
  ,SUM(A.MPS_Effort) AS 'MPS_Effort'  
  ,sum(A.Work_Profile_AD) as 'Work_Profile_AD'  
  ,SUM(A.MAS_Effort) AS 'MAS_Effort'    
  ,SUM(A.Actual_Effort) AS 'Actual_Effort'    
  ,ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours), 0) * 100), 0) AS 'Associate_Account_Compliance' into #AssociateSummarytmp_All_Grade    
 FROM #Associate_Summary_All_Grade A    
  GROUP BY A.Parent_Accountid    
    ,A.Parent_AccountName,A.SBU,a.Vertical    
    ,EmployeeID,A.EsaProjectID,A.EmployeeName,A.Projectname  
IF OBJECT_ID(N'tempdb..#AssociateActual_Final_AVM_All_Grade') IS NOT NULL BEGIN DROP TABLE #AssociateActual_Final_AVM_All_Grade END    

CREATE Table #AssociateActual_Final_AVM_All_Grade    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
SBU nvarchar (50),    
Vertical varchar (50),    
EsaProjectID Char(15) Not Null,    
Projectname varchar(100),    
EmployeeID varchar(15),    
EmployeeName varchar(100),    
Department_Name varchar(100),    
Job_Code varchar(50),    
Designation varchar(100),    
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_Account_Compliance decimal (10,2)    
)    
    
    
INSERT INTO #AssociateActual_Final_AVM_All_Grade    
    
SELECT DISTINCT    
 a.Parent_Accountid    
  ,a.Parent_AccountName,A.SBU,A.Vertical,EsaProjectID,Projectname    
  ,a.EmployeeID,EmployeeName,Department_Name,Job_code,Designation    
  ,(A.Avaialble_FTE_Below_M)    
  ,(A.Available_Hours)    
  ,(A.MPS_Effort)   
  ,(A.Work_Profile_AD)  
  ,(A.MAS_Effort)    
  ,(A.Actual_Effort)    
  ,Associate_Account_Compliance    
 FROM #AssociateSummarytmp_All_Grade A    
 left outer join #department dp ON A.EmployeeID = dp.Associate_ID and a.Parent_Accountid=dp.Parent_Accountid and A.EsaProjectID=dp.Project_ID AND a.SBU=dp.SBU    
     
 left outer join #designation ds ON A.EmployeeID = ds.Associate_ID and a.Parent_Accountid=ds.Parent_Accountid and A.EsaProjectID=ds.Project_ID AND a.SBU=ds.SBU    
  
IF OBJECT_ID(N'tempdb..#Associate_BUcompliance_AVM_ALL_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_BUcompliance_AVM_ALL_Grade END          

CREATE Table #Associate_BUcompliance_AVM_ALL_Grade    
(SBU varchar (100),    
EmployeeID varchar(15),    
Department_Name varchar(100),   
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),   
Work_Profile_AD decimal (10,2),   
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_BU_Compliance decimal (10,2)    
)    
    
    
INSERT INTO #Associate_BUcompliance_AVM_ALL_Grade    
   
SELECT DISTINCT A.SBU,A.EmployeeID,A.Department_Name,sum(A.Avaialble_FTE_Below_M),sum(A.Available_Hours),sum(A.MPS_Effort), sum(A.Work_Profile_AD),   
Sum(A.MAS_Effort),sum(A.Actual_Effort),ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours), 0) * 100), 0) 
from #AssociateActual_Final_AVM_All_Grade A    
JOIN [AdpR].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'    
GROUP BY SBU,EmployeeID,Department_Name   
  
IF OBJECT_ID(N'tempdb..#Associate_Greater80_SBU_ALL_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_Greater80_SBU_ALL_Grade END          
   
-- All Scope BU Compliacne    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater80_SBU_ALL_Grade    
FROM #Associate_BUcompliance_AVM_ALL_Grade   
WHERE [Associate_BU_Compliance] > 80    
IF OBJECT_ID(N'tempdb..#Associate_Greater_50_80_SBU_ALL_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_Greater_50_80_SBU_ALL_Grade END              
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_50_80_SBU_ALL_Grade    
FROM #Associate_BUcompliance_AVM_ALL_Grade    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80    

IF OBJECT_ID(N'tempdb..#Associate_Greater_25_50_SBU_ALL_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_Greater_25_50_SBU_ALL_Grade END              
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_25_50_SBU_ALL_Grade    
FROM #Associate_BUcompliance_AVM_ALL_Grade    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50    

IF OBJECT_ID(N'tempdb..#Associate_Greater_0_25_SBU_ALL_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_Greater_0_25_SBU_ALL_Grade END              
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_0_25_SBU_ALL_Grade    
FROM #Associate_BUcompliance_AVM_ALL_Grade    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25    

IF OBJECT_ID(N'tempdb..#Associate_Greater_zero_SBU_ALL_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_Greater_zero_SBU_ALL_Grade END                 
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_zero_SBU_ALL_Grade    
FROM #Associate_BUcompliance_AVM_ALL_Grade    
WHERE [Associate_BU_Compliance] =0    
    
IF OBJECT_ID(N'tempdb..#Associate_80_SBU_All_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_80_SBU_All_Grade END          
CREATE TABLE #Associate_80_SBU_All_Grade    
(    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
)    
    
INSERT INTO #Associate_80_SBU_All_Grade    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)    
 FROM #Associate_Greater80_SBU_ALL_Grade    
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_50_80_SBU_All_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_50_80_SBU_All_Grade END          
    
    
CREATE TABLE #Associate_50_80_SBU_All_Grade   
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_SBU_All_Grade    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_50_80_SBU_ALL_Grade     
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_25_50_SBU_All_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_25_50_SBU_All_Grade END          
    
    
CREATE TABLE #Associate_25_50_SBU_All_Grade    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_SBU_All_Grade    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_25_50_SBU_ALL_Grade    
 GROUP BY SBU    
    ,EmployeeID    

IF OBJECT_ID(N'tempdb..#Associate_0_25_SBU_All_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_0_25_SBU_All_Grade END             
    
CREATE TABLE #Associate_0_25_SBU_All_Grade    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_SBU_All_Grade    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_0_25_SBU_ALL_Grade    
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_0_SBU_All_Grade') IS NOT NULL BEGIN DROP TABLE #Associate_0_SBU_All_Grade END             
    
CREATE TABLE #Associate_0_SBU_All_Grade    
(    
    
SBU nvarchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_SBU_All_Grade    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_Zero_SBU_ALL_Grade    
 GROUP BY SBU    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#SBU_Compliance_AVM_ALL_Grade') IS NOT NULL BEGIN DROP TABLE #SBU_Compliance_AVM_ALL_Grade END             
   
CREATE table #SBU_Compliance_AVM_ALL_Grade    
    
(    
SBU nvarchar (50),    
ESA_FTE decimal (10,2),    
ESA_FTE_Zero  decimal (10,2),    
ESA_FTE_0_25  decimal (10,2),    
ESA_FTE_25_50  decimal (10,2),    
ESA_FTE_50_80  decimal (10,2),    
ESA_FTE_80  decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),    
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
BU_Effort_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #SBU_Compliance_AVM_ALL_Grade    
    
 SELECT DISTINCT    
  a.SBU    
  ,ISNULL(SUM(Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(f.ESA_FTE_0_BU), 0)    
  ,ISNULL(SUM(e.ESA_FTE_0_25_BU), 0)    
  ,ISNULL(SUM(D.ESA_FTE_25_50_BU), 0)    
  ,ISNULL(SUM(C.ESA_FTE_50_80_BU), 0)    
  ,ISNULL(SUM(b.ESA_FTE_80_BU), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
  ,ISNULL(SUM(MPS_Effort), 0)   
  ,ISNULL(SUM(Work_Profile_AD),0)  
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_BUcompliance_AVM_ALL_Grade A    
 LEFT JOIN #Associate_0_SBU_ALL_Grade F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_SBU_ALL_Grade E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_SBU_ALL_Grade D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_SBU_ALL_Grade C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_SBU_ALL_Grade B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
    
 GROUP BY a.SBU    
 IF OBJECT_ID(N'tempdb..#SBUComplianceTotal') IS NOT NULL BEGIN DROP TABLE #SBUComplianceTotal END             

 Create Table #SBUComplianceTotal
(
SBU varchar (50),    
ESA_FTE decimal (10,2), 
[ESA FTE(Below_M)] decimal (10,2), 
ESA_FTE_Zero  decimal (10,2),    
ESA_FTE_0_25  decimal (10,2),    
ESA_FTE_25_50  decimal (10,2),    
ESA_FTE_50_80  decimal (10,2),    
ESA_FTE_80  decimal (10,2), 
[ESA FTE 80(Below_M)] decimal(10,2),
Available_Hours decimal (10,2),
[Available Hours(Below_M)] decimal (10,2),
MPS_Effort decimal (10,2),  
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),
[Actual Effort(Below_M)] decimal (10,2),
BU_Effort_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2),
BU_Effort_Compliance_Percent_Below_M decimal (10,2),    
Associate_Compliance_Percent_Below_M decimal (10,2)
)

INSERT INTO #SBUComplianceTotal       
SELECT    
 a.[SBU] AS 'SBU'    
 ,a.ESA_FTE,b.ESA_FTE AS [ESA FTE(Below_M)], a.ESA_FTE_Zero,a.ESA_FTE_0_25,a.ESA_FTE_25_50,a.ESA_FTE_50_80,a.ESA_FTE_80,b.ESA_FTE_80 AS [ESA FTE 80(Below_M)]
 ,a.Available_Hours  
 ,b.Available_Hours As [Available Hours(Below_M)]
 ,a.MPS_Effort    
 ,a.Work_Profile_AD  
 ,a.MAS_Effort    
 ,a.Actual_Effort 
 ,b.Actual_Effort AS [Actual Effort(Below_M)]
 ,a.BU_Effort_Compliance_Percent AS [BU Effort Compliance%(All)]    
 ,a.Associate_Compliance_Percent AS [Associate_BU_Compliance%(All)]
 ,b.BU_Effort_Compliance_Percent AS [BU Effort Compliance%(Below_M)]    
 ,b.Associate_Compliance_Percent AS [Associate_BU_Compliance%(Below_M)]
FROM #SBU_Compliance_AVM_ALL_Grade a
join #SBU_Compliance_AVM b on a.SBU = b.SBU 


  
IF OBJECT_ID(N'tempdb..#BUDATA_All_Grade') IS NOT NULL
BEGIN DROP TABLE #BUDATA_All_Grade END   
SELECT DISTINCT SBU,ESA_FTE,[ESA FTE(Below_M)],ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,[ESA FTE 80(Below_M)],
Available_Hours,[Available Hours(Below_M)],    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,[Actual Effort(Below_M)],    
BU_Effort_Compliance_Percent,    
Associate_Compliance_Percent,
BU_Effort_Compliance_Percent_Below_M,    
Associate_Compliance_Percent_Below_M
INTO #BUDATA_All_Grade    
FROM #SBUComplianceTotal    
    
INSERT INTO #SBUComplianceTotal    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE)) AS 'ESA_FTE' 
  ,SUM(CONVERT(DECIMAL(10,2), [ESA FTE(Below_M)])) AS 'ESA FTE(Below_M)' 
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_Zero)) AS 'ESA FTE with TSC %=0'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_0_25)) AS 'ESA FTE with TSC %>0 to 25'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_25_50)) AS 'ESA FTE with TSC %>25 to 50'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_50_80)) AS 'ESA FTE with TSC %>50 to 80'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_80)) AS 'ESA FTE with TSC %>80' 
  ,SUM(CONVERT(DECIMAL(10,2), [ESA FTE 80(Below_M)])) AS 'ESA FTE 80(Below_M)'
  ,SUM(CONVERT(DECIMAL(10,2), Available_Hours)) AS 'Available_Hours' 
  ,SUM(CONVERT(DECIMAL(10,2), [Available Hours(Below_M)])) AS 'Available Hours(Below_M)'
  ,SUM(CONVERT(DECIMAL(10,2), MPS_Effort)) AS 'MPS_Effort'   
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS 'Work_Profile_AD'  
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort' 
  ,SUM(CONVERT(DECIMAL(10,2), [Actual Effort(Below_M)])) AS 'Actual Effort(Below_M)'
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), [Actual Effort(Below_M)])) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), [Available Hours(Below_M)])), 0) * 100,0) AS 'BU_Effort_Compliance_Percent_Below_M'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), [ESA FTE 80(Below_M)])) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), [ESA FTE(Below_M)])), 0) * 100,0) AS 'Associate_Compliance_Percent_Below_M'  
 FROM #BUDATA_All_Grade  
 
 --select * from #SBUComplianceTotal

TRUNCATE table [AdpR].SBU_Compliance_AVM    
    
INSERT INTO [AdpR].SBU_Compliance_AVM       
SELECT    
[SBU] AS 'SBU'    
,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
,Available_Hours    
,MPS_Effort    
,Work_Profile_AD  
,MAS_Effort    
,Actual_Effort    
,BU_Effort_Compliance_Percent AS [BU Effort Compliance%(All)]    
,Associate_Compliance_Percent AS [Associate_BU_Compliance%(All)]
,[ESA FTE(Below_M)]
,[ESA FTE 80(Below_M)]
,[Available Hours(Below_M)]
,[Actual Effort(Below_M)]
,[BU_Effort_Compliance_Percent_Below_M]
,[Associate_Compliance_Percent_Below_M]
FROM #SBUComplianceTotal 
ORDER BY CASE   WHEN [SBU] = 'GRAND TOTAL' THEN 1    
 ELSE 0     
END, [SBU]

IF OBJECT_ID(N'tempdb..#Associate_Projectcompliance_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_Projectcompliance_avm END 
    
CREATE Table #Associate_Projectcompliance_avm    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
SBU nvarchar (50),    
EmployeeID varchar(15),    
Department_Name varchar(100),    
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),   
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_Project_Compliance decimal (10,2)    
)    
    
    
    
INSERT INTO #Associate_Projectcompliance_avm    
    
SELECT  DISTINCT A.Parent_Accountid,A.Parent_AccountName,A.EsaProjectID,A.Projectname,A.SBU,A.EmployeeID,A.Department_Name,sum(A.Avaialble_FTE_Below_M),sum(A.Available_Hours),    
sum(A.MPS_Effort),sum(A.Work_Profile_AD),Sum(A.MAS_Effort),sum(A.Actual_Effort),ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours), 0) * 100), 0) from #AssociateActual_Final_AVM_All_Grade A    
JOIN [AdpR].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID      
where C.DE_Inscope in('In Scope','Yet to scope')    
GROUP BY A.Parent_Accountid,A.Parent_AccountName,A.EsaProjectID,A.Projectname,A.SBU,A.EmployeeID,A.Department_Name    
    
IF OBJECT_ID(N'tempdb..#Associate_Total_project_Compliance_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_Total_project_Compliance_avm END     
    
CREATE Table #Associate_Total_project_Compliance_avm    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
SBU nvarchar (50),    
EmployeeID varchar(15),    
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_Project_Compliance decimal (10,2)    
)    
    
INSERT INTO #Associate_Total_project_Compliance_avm    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName, EsaProjectid,ProjectName,SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)    
  ,SUM(Available_Hours)    
  ,SUM(MPS_Effort)    
  ,sum(Work_Profile_AD)  
  ,SUM(MAS_Effort)    
  ,SUM(Actual_Effort)    
  ,sum(Associate_Project_Compliance)    
 FROM #Associate_Projectcompliance_avm     
 GROUP BY Parent_Accountid    
  ,Parent_AccountName, EsaProjectid,ProjectName,SBU    
  ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_Greater80_Prj_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater80_Prj_avm END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,EsaProjectid ,ProjectName ,SBU ,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort ,Work_Profile_AD,MAS_Effort ,Actual_Effort ,    
Associate_Project_Compliance    
  INTO #Associate_Greater80_Prj_avm    
FROM #Associate_Total_project_Compliance_avm    
WHERE Associate_Project_Compliance > 80    

IF OBJECT_ID(N'tempdb..#Associate_Greater_50_80_Prj_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_50_80_Prj_avm END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,EsaProjectid ,ProjectName ,SBU ,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,    
Associate_Project_Compliance INTO #Associate_Greater_50_80_Prj_avm    
FROM #Associate_Total_project_Compliance_avm    
WHERE Associate_Project_Compliance > 50 and Associate_Project_Compliance  <=80    

IF OBJECT_ID(N'tempdb..#Associate_Greater_25_50_prj_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_25_50_prj_avm END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,EsaProjectid ,ProjectName ,SBU ,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,    
Associate_Project_Compliance INTO #Associate_Greater_25_50_prj_avm    
FROM #Associate_Total_project_Compliance_avm    
WHERE Associate_Project_Compliance > 25 and Associate_Project_Compliance  <=50    

IF OBJECT_ID(N'tempdb..#Associate_Greater_0_25_prj_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_0_25_prj_avm END      
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,EsaProjectid ,ProjectName ,SBU ,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD  ,MAS_Effort ,Actual_Effort ,    
Associate_Project_Compliance INTO #Associate_Greater_0_25_prj_avm    
FROM #Associate_Total_project_Compliance_avm    
WHERE Associate_Project_Compliance >0 and Associate_Project_Compliance  <=25    

IF OBJECT_ID(N'tempdb..#Associate_Greater_Zero_prj_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_Zero_prj_avm END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,EsaProjectid ,ProjectName ,SBU ,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD  ,MAS_Effort ,Actual_Effort ,    
Associate_Project_Compliance INTO #Associate_Greater_Zero_prj_avm    
FROM #Associate_Total_project_Compliance_avm    
WHERE Associate_Project_Compliance =0    
    
IF OBJECT_ID(N'tempdb..#Associate_zero_prj_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_zero_prj_avm END      
CREATE TABLE #Associate_zero_prj_avm    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
EmployeeID varchar(15),    
ESA_FTE_Zero DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_zero_prj_avm    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,EsaProjectid,ProjectName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_Zero_prj_avm     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,EsaProjectid,ProjectName    
    ,EmployeeID    

IF OBJECT_ID(N'tempdb..#Associate_0_25_prj_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_0_25_prj_avm END     
CREATE TABLE #Associate_0_25_prj_avm    
(    
    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
EmployeeID varchar(15),    
ESA_FTE_0_25 DECIMAL(10,2) NULL    
    
    
)    
    
INSERT INTO #Associate_0_25_prj_avm    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,EsaProjectid,ProjectName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_0_25_prj_avm     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,EsaProjectid,ProjectName    
    ,EmployeeID
	
IF OBJECT_ID(N'tempdb..#Associate_25_50_prj_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_25_50_prj_avm END    
CREATE TABLE #Associate_25_50_prj_avm    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
EmployeeID varchar(15),    
ESA_FTE_25_50 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_prj_avm    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,EsaProjectid,ProjectName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50_Prj_avm     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,EsaProjectid,ProjectName    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_50_80_Prj_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_50_80_Prj_avm END     
CREATE TABLE #Associate_50_80_Prj_avm    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
EmployeeID varchar(15),    
ESA_FTE_50_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_Prj_avm    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,EsaProjectid,ProjectName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80_prj_avm     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,EsaProjectid,ProjectName    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_80_Prj_avm') IS NOT NULL  
BEGIN DROP TABLE #Associate_80_Prj_avm END      
CREATE TABLE #Associate_80_Prj_avm    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
EmployeeID varchar(15),    
ESA_FTE_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_Prj_avm    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,EsaProjectid,ProjectName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_Prj_avm     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,EsaProjectid,ProjectName    
    ,EmployeeID    
    
    
IF OBJECT_ID(N'tempdb..#Project_Compliance_AVM') IS NOT NULL  
BEGIN DROP TABLE #Project_Compliance_AVM END    
CREATE table #Project_Compliance_AVM    
    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName nvarchar (100),    
EsaProjectid Char(15),    
ProjectName nvarchar(100),    
SBU nvarchar (50),    
ESA_All_FTE decimal (10,2),    
ESA_FTE_Zero decimal (10,2),    
ESA_FTE_0_25 decimal (10,2),    
ESA_FTE_25_50 decimal (10,2),    
ESA_FTE_50_80 decimal (10,2),    
ESA_FTE_80 decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),   
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Effort_Project_Compliance_percent decimal (10,2),    
AVMAssociate_Project_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #Project_Compliance_AVM    
    
SELECT DISTINCT    
  a.Parent_Accountid    
  ,a.Parent_AccountName,A.EsaProjectid,A.ProjectName,A.SBU    
  ,ISNULL(SUM(a.Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(b.ESA_FTE_Zero), 0)    
  ,ISNULL(SUM(c.ESA_FTE_0_25), 0)    
  ,ISNULL(SUM(d.ESA_FTE_25_50), 0)    
  ,ISNULL(SUM(e.ESA_FTE_50_80), 0)    
  ,ISNULL(SUM(f.ESA_FTE_80), 0)    
  ,ISNULL(SUM(a.Available_Hours), 0)    
  ,ISNULL(SUM(a.MPS_Effort), 0)   
  ,ISNULL(sum(a.Work_Profile_AD),0)  
  ,ISNULL(SUM(a.MAS_Effort), 0)    
  ,ISNULL(SUM(a.Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(F.ESA_FTE_80), 0)) / NULLIF(SUM(a.Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_Total_project_Compliance_avm A    
    
 LEFT JOIN #Associate_zero_prj_avm B ON a.Parent_Accountid = b.Parent_Accountid AND A.EmployeeID = b.EmployeeID AND a.EsaProjectid=b.EsaProjectid    
 LEFT JOIN #Associate_0_25_prj_avm C ON a.Parent_Accountid = c.Parent_Accountid AND A.EmployeeID = c.EmployeeID AND a.EsaProjectid = c.EsaProjectid    
 LEFT JOIN #Associate_25_50_prj_avm D ON a.Parent_Accountid = d.Parent_Accountid AND A.EmployeeID = d.EmployeeID AND a.EsaProjectid = d.EsaProjectid    
 LEFT JOIN #Associate_50_80_Prj_avm E ON a.Parent_Accountid = e.Parent_Accountid AND A.EmployeeID =e.EmployeeID AND a.EsaProjectid = e.EsaProjectid    
 LEFT JOIN #Associate_80_Prj_avm F ON a.Parent_Accountid = f.Parent_Accountid AND A.EmployeeID = f.EmployeeID AND a.EsaProjectid = f.EsaProjectid      
    
 GROUP BY a.Parent_Accountid    
  ,a.Parent_AccountName,A.EsaProjectid,A.ProjectName,A.SBU    

   
TRUNCATE table [AdpR].Project_Compliance_AVM    
    
INSERT INTO [AdpR].Project_Compliance_AVM    
     
SELECT DISTINCT    
 Parent_Accountid    
 ,Parent_AccountName    
 ,EsaProjectid, ProjectName,SBU    
 ,ESA_All_FTE    
 ,ESA_FTE_Zero    
 ,ESA_FTE_0_25    
 ,ESA_FTE_25_50    
 ,ESA_FTE_50_80    
 ,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort  
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,Effort_Project_Compliance_percent    
 ,avmAssociate_Project_Compliance_Percent    
FROM #Project_Compliance_AVM     
ORDER BY avmAssociate_Project_Compliance_Percent DESC   
    
    
IF OBJECT_ID(N'tempdb..#Associate_Accountcompliance') IS NOT NULL  
BEGIN DROP TABLE #Associate_Accountcompliance END      
    
CREATE Table #Associate_Accountcompliance    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),   
MarketUnitName varchar(50),  
BU varchar(50),  
EmployeeID varchar(15),    
Department_Name varchar(100),    
Project_Scope varchar(50),  
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),   
Work_Profile_AD decimal (10,2),   
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_Account_Compliance decimal (10,2)    
)    
    
  --select * from #Associate_Accountcompliance  
    
INSERT INTO #Associate_Accountcompliance    
    
SELECT DISTINCT A.Parent_Accountid,A.Parent_AccountName,A.Vertical,C.PracticeOwner,C.MARKET_BU,A.EmployeeID,A.Department_Name,C.PROJECTSCOPE,  
sum(A.Avaialble_FTE_Below_M),sum(A.Available_Hours),    
sum(A.MPS_Effort),sum(A.Work_Profile_AD),Sum(A.MAS_Effort),sum(A.Actual_Effort),ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours), 0) * 100), 0)  
from #AssociateActual_Final_AVM_All_Grade A    
JOIN [AdpR].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'  --and Parent_Accountid in('2000004','2000522')  
GROUP BY Parent_Accountid,Parent_AccountName,EmployeeID,Department_Name,Vertical,C.PracticeOwner,C.MARKET_BU ,C.PROJECTSCOPE  
    
IF OBJECT_ID(N'tempdb..#ScopeProject_tmp') IS NOT NULL  
BEGIN DROP TABLE #ScopeProject_tmp END     
select distinct A.Parent_Accountid ,A.EsaProjectID as 'Project#',c.projectscope,sum(Available_Hours) as 'Availablehours' Into #ScopeProject_tmp  
from #AssociateActual_Final_AVM_All_Grade A  
JOIN [AdpR].Input_Data_AssociateRAW C ON A.parent_accountid=C.parentaccountid and a.EsaProjectID=C.EsaProjectID     
GROUP BY A.Parent_Accountid ,A.EsaProjectID ,c.projectscope  
 --where Parent_Accountid='2000559'  

IF OBJECT_ID(N'tempdb..#ScopeProject') IS NOT NULL  
BEGIN DROP TABLE #ScopeProject END    
select Parent_Accountid, ProjectScope, count(Project#) as 'Project#',sum(Availablehours) as 'Availablehours' into #ScopeProject  
from  #ScopeProject_tmp a  
group by A.Parent_Accountid,a.ProjectScope  
  
IF OBJECT_ID(N'tempdb..#YETTOSCOPE_ADM') IS NOT NULL  
BEGIN DROP TABLE #YETTOSCOPE_ADM END    
CREATE TABLE #YETTOSCOPE_ADM  
(  
Parent_Accountid Char(15),    
[Yet to onboard projects #] INT,  
Available_Hours decimal (10,2)  
)  
  
INSERT INTO #YETTOSCOPE_ADM  
  
SELECT Parent_Accountid,Project#, Availablehours FROM  #ScopeProject WHERE ProjectScope=''  
  
--INSERT INTO [dbo].[Account_Compliance_YETTOSCOPE_ADM]  
--SELECT Parent_Accountid, [Yet to onboard projects #],Available_Hours FROM #YETTOSCOPE_ADM  
  
  
IF OBJECT_ID(N'tempdb..#Associate_Total_account_Compliance') IS NOT NULL  
BEGIN DROP TABLE #Associate_Total_account_Compliance END       
CREATE Table #Associate_Total_account_Compliance    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),   
MarketUnitName varchar(50),  
BU varchar(50),  
Project_scope varchar(50),  
EmployeeID varchar(15),    
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),   
Work_Profile_AD decimal (10,2),   
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_Account_Compliance decimal (10,2)    
)    
    
INSERT INTO #Associate_Total_account_Compliance    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,Vertical, MarketUnitName,BU,Project_scope  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)    
  ,SUM(Available_Hours)    
  ,SUM(MPS_Effort)    
  ,SUM(Work_Profile_AD)  
  ,SUM(MAS_Effort)    
  ,SUM(Actual_Effort)    
  ,sum(Associate_Account_Compliance)     
 FROM #Associate_Accountcompliance     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,Vertical,MarketUnitName,BU  ,Project_scope ,EmployeeID    
    
--AVM Scope Account Compliance Split  
  
IF OBJECT_ID(N'tempdb..#Associate_Greater80_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater80_AM END     
SELECT  DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater80_AM    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 80  and Project_scope='AVM'  

IF OBJECT_ID(N'tempdb..#Associate_Greater_50_80_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_50_80_AM END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_50_80_AM    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80  and Project_scope='AVM'  

IF OBJECT_ID(N'tempdb..#Associate_Greater_25_50_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_25_50_AM END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_25_50_AM    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50  and Project_scope='AVM'  

IF OBJECT_ID(N'tempdb..#Associate_Greater_0_25_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_0_25_AM END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_0_25_AM    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25  and Project_scope='AVM'  

IF OBJECT_ID(N'tempdb..#Associate_Greater_Zero_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_Zero_AM END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance    
INTO #Associate_Greater_Zero_AM   
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] =0   and Project_scope='AVM'  
    
IF OBJECT_ID(N'tempdb..#Associate_zero_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_zero_AM END       
CREATE TABLE #Associate_zero_AM    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_Zero DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_Zero_AM    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_Zero_AM     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    

IF OBJECT_ID(N'tempdb..#Associate_0_25_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_0_25_AM END     
CREATE TABLE #Associate_0_25_AM  
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_0_25 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_AM    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_0_25_AM    
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
 
IF OBJECT_ID(N'tempdb..#Associate_25_50_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_25_50_AM END    
CREATE TABLE #Associate_25_50_AM    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_25_50 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_AM    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_25_50_AM     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_50_80_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_50_80_AM END      
CREATE TABLE #Associate_50_80_AM    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_50_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_AM    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_50_80_AM     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_80_AM') IS NOT NULL  
BEGIN DROP TABLE #Associate_80_AM END      
CREATE TABLE #Associate_80_AM    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_AM    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater80_AM     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
       
IF OBJECT_ID(N'tempdb..#Account_Compliance_AVM_AM_temp') IS NOT NULL  
BEGIN DROP TABLE #Account_Compliance_AVM_AM_temp END     
CREATE table #Account_Compliance_AVM_AM_temp    
    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),  
MarketUnitName varchar(50),  
BU varchar(50),  
[AVM AM Project #] INT,  
ESA_AVM_FTE decimal (10,2),    
ESA_FTE_Zero decimal (10,2),    
ESA_FTE_0_25 decimal (10,2),    
ESA_FTE_25_50 decimal (10,2),    
ESA_FTE_50_80 decimal (10,2),    
ESA_FTE_80 decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Effort_Account_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #Account_Compliance_AVM_AM_temp    
    
    
 SELECT DISTINCT    
  a.Parent_Accountid    
  ,a.Parent_AccountName,A.Vertical ,  a.MarketUnitName,a.BU,S.Project#  
  ,ISNULL(SUM(a.Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(b.ESA_FTE_Zero), 0)    
  ,ISNULL(SUM(c.ESA_FTE_0_25), 0)    
  ,ISNULL(SUM(d.ESA_FTE_25_50), 0)    
  ,ISNULL(SUM(e.ESA_FTE_50_80), 0)    
  ,ISNULL(SUM(f.ESA_FTE_80), 0)    
  ,ISNULL(SUM(a.Available_Hours), 0)    
  ,ISNULL(SUM(a.MPS_Effort), 0)   
  ,ISNULL(SUM(a.Work_Profile_AD),0)  
  ,ISNULL(SUM(a.MAS_Effort), 0)    
  ,ISNULL(SUM(a.Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(F.ESA_FTE_80), 0)) / NULLIF(SUM(a.Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_Total_account_Compliance A    
 LEFT JOIN #Associate_zero_AM B ON a.Parent_Accountid = b.Parent_Accountid AND A.EmployeeID = b.EmployeeID    
 LEFT JOIN #Associate_0_25_AM C ON a.Parent_Accountid = c.Parent_Accountid AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_25_50_AM D ON a.Parent_Accountid = d.Parent_Accountid AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_AM E ON a.Parent_Accountid = e.Parent_Accountid AND A.EmployeeID =e.EmployeeID    
 LEFT JOIN #Associate_80_AM F ON a.Parent_Accountid = f.Parent_Accountid AND A.EmployeeID = f.EmployeeID     
  left join #ScopeProject S on A.Parent_Accountid =S.Parent_Accountid and A.Project_scope=S.ProjectScope  
    where A.Project_scope='AVM'  
 GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU,S.Project#    
       
    
IF OBJECT_ID(N'tempdb..#Account_Compliance_AVM_AM') IS NOT NULL  
BEGIN DROP TABLE #Account_Compliance_AVM_AM END    
CREATE table #Account_Compliance_AVM_AM  
(  
Parent_Accountid Char(15),  
Parent_AccountName varchar (100),  
Vertical varchar (50),  
MarketUnitName varchar(50),  
BU varchar(50),  
[AVM AM Project #] INT,  
ESA_AVM_FTE decimal (10,2),  
ESA_FTE_Zero decimal (10,2),  
ESA_FTE_0_25 decimal (10,2),  
ESA_FTE_25_50 decimal (10,2),  
ESA_FTE_50_80 decimal (10,2),  
ESA_FTE_80 decimal (10,2),  
Available_Hours decimal (10,2),  
MPS_Effort decimal (10,2),  
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),  
Actual_Effort decimal (10,2),  
Effort_Account_Compliance_Percent decimal (10,2),  
Associate_Compliance_Percent decimal (10,2)  
)  
  
INSERT INTO #Account_Compliance_AVM_AM  
  
SELECT DISTINCT  
a.Parent_Accountid  
,a.Parent_AccountName,A.Vertical , a.MarketUnitName,a.BU,sum([AVM AM Project #])  
,ISNULL(SUM(a.ESA_AVM_FTE), 0)  
,ISNULL(SUM(a.ESA_FTE_Zero), 0)  
,ISNULL(SUM(a.ESA_FTE_0_25), 0)  
,ISNULL(SUM(a.ESA_FTE_25_50), 0)  
,ISNULL(SUM(a.ESA_FTE_50_80), 0)  
,ISNULL(SUM(a.ESA_FTE_80), 0)  
,ISNULL(SUM(a.Available_Hours), 0)  
,ISNULL(SUM(a.MPS_Effort), 0)  
,ISNULL(SUM(a.Work_Profile_AD),0)  
,ISNULL(SUM(a.MAS_Effort), 0)  
,ISNULL(SUM(a.Actual_Effort), 0)  
,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)  
,ISNULL(((ISNULL(SUM(a.ESA_FTE_80), 0)) / NULLIF(SUM(a.ESA_AVM_FTE), 0) * 100), 0)  
FROM #Account_Compliance_AVM_AM_temp A  
GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU     
 --AD Scope Account Compliance Split  
    
    
IF OBJECT_ID(N'tempdb..#Associate_Greater80_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater80_AD END      
SELECT  DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater80_AD    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 80  and Project_scope='AD'  
     
IF OBJECT_ID(N'tempdb..#Associate_Greater_50_80_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_50_80_AD END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_50_80_AD    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80  and Project_scope='AD'  
    
IF OBJECT_ID(N'tempdb..#Associate_Greater_25_50_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_25_50_AD END  
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_25_50_AD    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50  and Project_scope='AD'  

IF OBJECT_ID(N'tempdb..#Associate_Greater_0_25_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_0_25_AD END      
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_0_25_AD    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25  and Project_scope='AD'  
 
 IF OBJECT_ID(N'tempdb..#Associate_Greater_Zero_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_Zero_AD END  
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance    
INTO #Associate_Greater_Zero_AD   
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] =0   and Project_scope='AD'  
    
IF OBJECT_ID(N'tempdb..#Associate_zero_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_zero_AD END        
CREATE TABLE #Associate_zero_AD    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_Zero DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_Zero_AD    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_Zero_AD     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    

IF OBJECT_ID(N'tempdb..#Associate_0_25_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_0_25_AD END     
CREATE TABLE #Associate_0_25_AD  
(    
    
Parent_Accountid Char(15),   
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_0_25 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_AD    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_0_25_AD   
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID  
	
IF OBJECT_ID(N'tempdb..#Associate_25_50_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_25_50_AD END
CREATE TABLE #Associate_25_50_AD    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_25_50 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_AD   
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_25_50_AD    
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
    
	
IF OBJECT_ID(N'tempdb..#Associate_50_80_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_50_80_AD END    
CREATE TABLE #Associate_50_80_AD   
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_50_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_AD  
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_50_80_AD    
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_80_AD') IS NOT NULL  
BEGIN DROP TABLE #Associate_80_AD END      
CREATE TABLE #Associate_80_AD   
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_AD    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater80_AD     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
    
     
IF OBJECT_ID(N'tempdb..#Account_Compliance_AVM_AD_temp') IS NOT NULL  
BEGIN DROP TABLE #Account_Compliance_AVM_AD_temp END     
    
CREATE table #Account_Compliance_AVM_AD_temp    
    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),  
MarketUnitName varchar(50),  
BU varchar(50),  
[AVM AD Project #] INT,  
ESA_AVM_FTE decimal (10,2),    
ESA_FTE_Zero decimal (10,2),    
ESA_FTE_0_25 decimal (10,2),    
ESA_FTE_25_50 decimal (10,2),    
ESA_FTE_50_80 decimal (10,2),    
ESA_FTE_80 decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Effort_Account_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #Account_Compliance_AVM_AD_temp    
    
    
 SELECT DISTINCT    
  a.Parent_Accountid    
  ,a.Parent_AccountName,A.Vertical ,  a.MarketUnitName,a.BU,S.Project#  
  ,ISNULL(SUM(a.Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(b.ESA_FTE_Zero), 0)    
  ,ISNULL(SUM(c.ESA_FTE_0_25), 0)    
  ,ISNULL(SUM(d.ESA_FTE_25_50), 0)    
  ,ISNULL(SUM(e.ESA_FTE_50_80), 0)    
  ,ISNULL(SUM(f.ESA_FTE_80), 0)    
  ,ISNULL(SUM(a.Available_Hours), 0)    
  ,ISNULL(SUM(a.MPS_Effort), 0)   
  ,ISNULL(SUM(a.Work_Profile_AD),0)  
  ,ISNULL(SUM(a.MAS_Effort), 0)    
  ,ISNULL(SUM(a.Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(F.ESA_FTE_80), 0)) / NULLIF(SUM(a.Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_Total_account_Compliance A    
 LEFT JOIN #Associate_zero_AD B ON a.Parent_Accountid = b.Parent_Accountid AND A.EmployeeID = b.EmployeeID    
 LEFT JOIN #Associate_0_25_AD C ON a.Parent_Accountid = c.Parent_Accountid AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_25_50_AD D ON a.Parent_Accountid = d.Parent_Accountid AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_AD E ON a.Parent_Accountid = e.Parent_Accountid AND A.EmployeeID =e.EmployeeID    
 LEFT JOIN #Associate_80_AD F ON a.Parent_Accountid = f.Parent_Accountid AND A.EmployeeID = f.EmployeeID     
  left join #ScopeProject S on A.Parent_Accountid =S.Parent_Accountid and A.Project_scope=S.ProjectScope  
    where A.Project_scope='AD'  
 GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU,S.Project#    
  
IF OBJECT_ID(N'tempdb..#Account_Compliance_AVM_AD') IS NOT NULL  
BEGIN DROP TABLE #Account_Compliance_AVM_AD END   
  
CREATE table #Account_Compliance_AVM_AD  
(  
Parent_Accountid Char(15),  
Parent_AccountName varchar (100),  
Vertical varchar (50),  
MarketUnitName varchar(50),  
BU varchar(50),  
[AVM AD Project #] INT,  
ESA_AVM_FTE decimal (10,2),  
ESA_FTE_Zero decimal (10,2),  
ESA_FTE_0_25 decimal (10,2),  
ESA_FTE_25_50 decimal (10,2),  
ESA_FTE_50_80 decimal (10,2),  
ESA_FTE_80 decimal (10,2),  
Available_Hours decimal (10,2),  
MPS_Effort decimal (10,2),  
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),  
Actual_Effort decimal (10,2),  
Effort_Account_Compliance_Percent decimal (10,2),  
Associate_Compliance_Percent decimal (10,2)  
)  
  
INSERT INTO #Account_Compliance_AVM_AD  
  
 SELECT DISTINCT  
a.Parent_Accountid  
,a.Parent_AccountName,A.Vertical , a.MarketUnitName,a.BU,sum([AVM AD Project #])  
,ISNULL(SUM(a.ESA_AVM_FTE), 0)  
,ISNULL(SUM(a.ESA_FTE_Zero), 0)  
,ISNULL(SUM(a.ESA_FTE_0_25), 0)  
,ISNULL(SUM(a.ESA_FTE_25_50), 0)  
,ISNULL(SUM(a.ESA_FTE_50_80), 0)  
,ISNULL(SUM(a.ESA_FTE_80), 0)  
,ISNULL(SUM(a.Available_Hours), 0)  
,ISNULL(SUM(a.MPS_Effort), 0)  
,ISNULL(SUM(a.Work_Profile_AD),0)  
,ISNULL(SUM(a.MAS_Effort), 0)  
,ISNULL(SUM(a.Actual_Effort), 0)  
,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)  
,ISNULL(((ISNULL(SUM(a.ESA_FTE_80), 0)) / NULLIF(SUM(a.ESA_AVM_FTE), 0) * 100), 0)  
FROM #Account_Compliance_AVM_AD_temp A  
GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU        
   
 --INTEG Scope Account Compliance Split  
    
IF OBJECT_ID(N'tempdb..#Associate_Greater80_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater80_INTEG END     
SELECT  DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater80_INTEG    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 80  and Project_scope not in ('AD','AVM','')  

IF OBJECT_ID(N'tempdb..#Associate_Greater_50_80_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_50_80_INTEG END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_50_80_INTEG    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80  and Project_scope not in ('AD','AVM','')  

IF OBJECT_ID(N'tempdb..#Associate_Greater_25_50_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_25_50_INTEG END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_25_50_INTEG    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50  and Project_scope not in ('AD','AVM','')  

IF OBJECT_ID(N'tempdb..#Associate_Greater_0_25_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_0_25_INTEG END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_0_25_INTEG    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25  and Project_scope not in ('AD','AVM','')  

IF OBJECT_ID(N'tempdb..#Associate_Greater_Zero_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_Zero_INTEG END     
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance    
INTO #Associate_Greater_Zero_INTEG   
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] =0   and Project_scope not in ('AD','AVM','')  
    
IF OBJECT_ID(N'tempdb..#Associate_zero_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_zero_INTEG END       
CREATE TABLE #Associate_zero_INTEG     
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_Zero DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_Zero_INTEG     
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_Zero_INTEG      
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    

IF OBJECT_ID(N'tempdb..#Associate_0_25_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_0_25_INTEG END      
CREATE TABLE #Associate_0_25_INTEG   
(    
    
Parent_Accountid Char(15),   
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_0_25 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_INTEG     
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_0_25_INTEG    
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    

IF OBJECT_ID(N'tempdb..#Associate_25_50_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_25_50_INTEG END    
CREATE TABLE #Associate_25_50_INTEG    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_25_50 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_INTEG    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_25_50_INTEG     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
    
IF OBJECT_ID(N'tempdb..#Associate_50_80_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_50_80_INTEG END    
CREATE TABLE #Associate_50_80_INTEG    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_50_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_INTEG   
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
FROM #Associate_Greater_50_80_INTEG     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
    
 IF OBJECT_ID(N'tempdb..#Associate_80_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Associate_80_INTEG END    
CREATE TABLE #Associate_80_INTEG    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_INTEG     
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater80_INTEG      
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
    
    
IF OBJECT_ID(N'tempdb..#Account_Compliance_AVM_INTEG_temp') IS NOT NULL  
BEGIN DROP TABLE #Account_Compliance_AVM_INTEG_temp END     
CREATE table #Account_Compliance_AVM_INTEG_temp     
    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),  
MarketUnitName varchar(50),  
BU varchar(50),  
[AVM INTEG Project #] INT,  
ESA_AVM_FTE decimal (10,2),    
ESA_FTE_Zero decimal (10,2),    
ESA_FTE_0_25 decimal (10,2),    
ESA_FTE_25_50 decimal (10,2),    
ESA_FTE_50_80 decimal (10,2),    
ESA_FTE_80 decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Effort_Account_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #Account_Compliance_AVM_INTEG_temp    
    
    
 SELECT DISTINCT    
  a.Parent_Accountid    
  ,a.Parent_AccountName,A.Vertical ,  a.MarketUnitName,a.BU,S.Project#  
  ,ISNULL(SUM(a.Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(b.ESA_FTE_Zero), 0)    
  ,ISNULL(SUM(c.ESA_FTE_0_25), 0)    
  ,ISNULL(SUM(d.ESA_FTE_25_50), 0)    
  ,ISNULL(SUM(e.ESA_FTE_50_80), 0)    
  ,ISNULL(SUM(f.ESA_FTE_80), 0)    
  ,ISNULL(SUM(a.Available_Hours), 0)    
  ,ISNULL(SUM(a.MPS_Effort), 0)   
  ,ISNULL(SUM(a.Work_Profile_AD),0)  
  ,ISNULL(SUM(a.MAS_Effort), 0)    
  ,ISNULL(SUM(a.Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(F.ESA_FTE_80), 0)) / NULLIF(SUM(a.Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_Total_account_Compliance A    
 LEFT JOIN #Associate_zero_INTEG  B ON a.Parent_Accountid = b.Parent_Accountid AND A.EmployeeID = b.EmployeeID    
 LEFT JOIN #Associate_0_25_INTEG  C ON a.Parent_Accountid = c.Parent_Accountid AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_25_50_INTEG  D ON a.Parent_Accountid = d.Parent_Accountid AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_INTEG  E ON a.Parent_Accountid = e.Parent_Accountid AND A.EmployeeID =e.EmployeeID    
 LEFT JOIN #Associate_80_INTEG  F ON a.Parent_Accountid = f.Parent_Accountid AND A.EmployeeID = f.EmployeeID     
  left join #ScopeProject S on A.Parent_Accountid =S.Parent_Accountid and A.Project_scope=S.ProjectScope  
    where A.Project_scope not in ('AD','AVM','')  
 GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU,S.Project#    
  
  
IF OBJECT_ID(N'tempdb..#Account_Compliance_AVM_INTEG') IS NOT NULL  
BEGIN DROP TABLE #Account_Compliance_AVM_INTEG END  
CREATE table #Account_Compliance_AVM_INTEG  
(  
Parent_Accountid Char(15),  
Parent_AccountName varchar (100),  
Vertical varchar (50),  
MarketUnitName varchar(50),  
BU varchar(50),  
[AVM INTEG Project #] INT,  
ESA_AVM_FTE decimal (10,2),  
ESA_FTE_Zero decimal (10,2),  
ESA_FTE_0_25 decimal (10,2),  
ESA_FTE_25_50 decimal (10,2),  
ESA_FTE_50_80 decimal (10,2),  
ESA_FTE_80 decimal (10,2),  
Available_Hours decimal (10,2),  
MPS_Effort decimal (10,2),  
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),  
Actual_Effort decimal (10,2),  
Effort_Account_Compliance_Percent decimal (10,2),  
Associate_Compliance_Percent decimal (10,2)  
)  
  
INSERT INTO #Account_Compliance_AVM_INTEG  
  
 SELECT DISTINCT  
a.Parent_Accountid  
,a.Parent_AccountName,A.Vertical , a.MarketUnitName,a.BU,sum([AVM INTEG Project #])  
,ISNULL(SUM(a.ESA_AVM_FTE), 0)  
,ISNULL(SUM(a.ESA_FTE_Zero), 0)  
,ISNULL(SUM(a.ESA_FTE_0_25), 0)  
,ISNULL(SUM(a.ESA_FTE_25_50), 0)  
,ISNULL(SUM(a.ESA_FTE_50_80), 0)  
,ISNULL(SUM(a.ESA_FTE_80), 0)  
,ISNULL(SUM(a.Available_Hours), 0)  
,ISNULL(SUM(a.MPS_Effort), 0)  
,ISNULL(SUM(a.Work_Profile_AD),0)  
,ISNULL(SUM(a.MAS_Effort), 0)  
,ISNULL(SUM(a.Actual_Effort), 0)  
,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)  
,ISNULL(((ISNULL(SUM(a.ESA_FTE_80), 0)) / NULLIF(SUM(a.ESA_AVM_FTE), 0) * 100), 0)  
FROM #Account_Compliance_AVM_INTEG_temp A  
GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU  

--All Scope account compliance 
  
IF OBJECT_ID(N'tempdb..#Associate_Accountcompliance_all') IS NOT NULL  
BEGIN DROP TABLE #Associate_Accountcompliance_all END 
CREATE Table #Associate_Accountcompliance_all    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),   
MarketUnitName varchar(50),  
BU varchar(50),  
EmployeeID varchar(15),    
Department_Name varchar(100),    
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),   
Work_Profile_AD decimal (10,2),   
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_Account_Compliance decimal (10,2)    
)    
    
  --select * from #Associate_Accountcompliance  
    
INSERT INTO #Associate_Accountcompliance_all    
    
SELECT DISTINCT A.Parent_Accountid,A.Parent_AccountName,A.Vertical,C.PracticeOwner,C.MARKET_BU,A.EmployeeID,A.Department_Name,  
sum(A.Avaialble_FTE_Below_M),sum(A.Available_Hours),    
sum(A.MPS_Effort),sum(A.Work_Profile_AD),Sum(A.MAS_Effort),sum(A.Actual_Effort),ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours), 0) * 100), 0)  
from #AssociateActual_Final_AVM_All_Grade A    
JOIN [AdpR].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'  --and Parent_Accountid in('2000004','2000522')  
GROUP BY Parent_Accountid,Parent_AccountName,EmployeeID,Department_Name,Vertical,C.PracticeOwner,C.MARKET_BU   
    
IF OBJECT_ID(N'tempdb..#Associate_Total_account_Compliance_all') IS NOT NULL  
BEGIN DROP TABLE #Associate_Total_account_Compliance_all END   
CREATE Table #Associate_Total_account_Compliance_all    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),   
MarketUnitName varchar(50),  
BU varchar(50),  
EmployeeID varchar(15),    
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),   
Work_Profile_AD decimal (10,2),   
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_Account_Compliance decimal (10,2)    
)    
    
INSERT INTO #Associate_Total_account_Compliance_all    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,Vertical, MarketUnitName,BU  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)    
  ,SUM(Available_Hours)    
  ,SUM(MPS_Effort)    
  ,SUM(Work_Profile_AD)  
  ,SUM(MAS_Effort)    
  ,SUM(Actual_Effort)    
  ,sum(Associate_Account_Compliance)     
 FROM #Associate_Accountcompliance_all     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,Vertical,MarketUnitName,BU ,EmployeeID    
  
  
IF OBJECT_ID(N'tempdb..#Associate_Greater80') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater80 END    
SELECT  DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater80    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] > 80    
  
IF OBJECT_ID(N'tempdb..#Associate_Greater_50_80') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_50_80 END 
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_50_80    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80    

IF OBJECT_ID(N'tempdb..#Associate_Greater_25_50') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_25_50 END 
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_25_50    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50    

IF OBJECT_ID(N'tempdb..#Associate_Greater_0_25') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_0_25 END    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_0_25    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25    
 
IF OBJECT_ID(N'tempdb..#Associate_Greater_Zero') IS NOT NULL  
BEGIN DROP TABLE #Associate_Greater_Zero END   

SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance  
INTO #Associate_Greater_Zero    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] =0    
    
    
 IF OBJECT_ID(N'tempdb..#Associate_zero') IS NOT NULL  
BEGIN DROP TABLE #Associate_zero END   
CREATE TABLE #Associate_zero    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
vertical varchar(50),  
ESA_FTE_Zero DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_Zero    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID,Vertical    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_Zero     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID  ,Vertical 
	
  IF OBJECT_ID(N'tempdb..#Associate_0_25') IS NOT NULL  
BEGIN DROP TABLE #Associate_0_25 END   
CREATE TABLE #Associate_0_25    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
vertical varchar(50),  
ESA_FTE_0_25 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID  ,Vertical  
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_0_25     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID ,Vertical   

IF OBJECT_ID(N'tempdb..#Associate_25_50') IS NOT NULL  BEGIN DROP TABLE #Associate_25_50 END      
CREATE TABLE #Associate_25_50    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),   
vertical varchar(50),  
ESA_FTE_25_50 DECIMAL(10,2) NULL    
)    
    
INSERT INTO #Associate_25_50    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID  ,Vertical  
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_25_50     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID  ,Vertical  
    
IF OBJECT_ID(N'tempdb..#Associate_50_80') IS NOT NULL  
BEGIN DROP TABLE #Associate_50_80 END    
CREATE TABLE #Associate_50_80    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
vertical varchar(50),  
ESA_FTE_50_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID  ,Vertical  
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_50_80     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID,Vertical    

IF OBJECT_ID(N'tempdb..#Associate_80') IS NOT NULL  
BEGIN DROP TABLE #Associate_80 END    
CREATE TABLE #Associate_80    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),  
vertical varchar(50),  
ESA_FTE_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID  ,Vertical  
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater80     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID  ,Vertical  
    
IF OBJECT_ID(N'tempdb..#Account_Compliance_AVM') IS NOT NULL  
BEGIN DROP TABLE #Account_Compliance_AVM END   
CREATE table #Account_Compliance_AVM    
    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),  
MarketUnitName varchar(50),  
BU varchar(50),  
ESA_AVM_FTE decimal (10,2),    
ESA_FTE_Zero decimal (10,2),    
ESA_FTE_0_25 decimal (10,2),    
ESA_FTE_25_50 decimal (10,2),    
ESA_FTE_50_80 decimal (10,2),    
ESA_FTE_80 decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),  
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Effort_Account_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #Account_Compliance_AVM    
    
    
 SELECT DISTINCT    
  a.Parent_Accountid    
  ,a.Parent_AccountName,A.Vertical ,  
  a.MarketUnitName,a.BU  
  ,ISNULL(SUM(a.Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(b.ESA_FTE_Zero), 0)    
  ,ISNULL(SUM(c.ESA_FTE_0_25), 0)    
  ,ISNULL(SUM(d.ESA_FTE_25_50), 0)    
  ,ISNULL(SUM(e.ESA_FTE_50_80), 0)    
  ,ISNULL(SUM(f.ESA_FTE_80), 0)    
  ,ISNULL(SUM(a.Available_Hours), 0)    
  ,ISNULL(SUM(a.MPS_Effort), 0)   
  ,ISNULL(SUM(a.Work_Profile_AD),0)  
  ,ISNULL(SUM(a.MAS_Effort), 0)    
  ,ISNULL(SUM(a.Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(F.ESA_FTE_80), 0)) / NULLIF(SUM(a.Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_Total_account_Compliance_all A    
 LEFT JOIN #Associate_zero B ON a.Parent_Accountid = b.Parent_Accountid AND A.EmployeeID = b.EmployeeID  and a.Vertical=b.vertical  
 LEFT JOIN #Associate_0_25 C ON a.Parent_Accountid = c.Parent_Accountid AND A.EmployeeID = c.EmployeeID  and a.Vertical=c.vertical  
 LEFT JOIN #Associate_25_50 D ON a.Parent_Accountid = d.Parent_Accountid AND A.EmployeeID = d.EmployeeID  and a.Vertical=d.vertical  
 LEFT JOIN #Associate_50_80 E ON a.Parent_Accountid = e.Parent_Accountid AND A.EmployeeID =e.EmployeeID  and a.Vertical=e.vertical  
 LEFT JOIN #Associate_80 F ON a.Parent_Accountid = f.Parent_Accountid AND A.EmployeeID = f.EmployeeID   and a.Vertical=f.vertical  
    
 GROUP BY a.Parent_Accountid    
    ,a.Parent_AccountName,A.Vertical,a.MarketUnitName,a.BU    
       
   
 TRUNCATE table [AdpR].Account_Compliance_AVM    
    
INSERT INTO [AdpR].Account_Compliance_AVM    
    
    
SELECT DISTINCT    
 Parent_Accountid    
 ,Parent_AccountName,    
 Vertical,   
 MarketUnitName,BU,  
 ESA_AVM_FTE ,    
ESA_FTE_Zero ,    
ESA_FTE_0_25 ,    
ESA_FTE_25_50 ,    
ESA_FTE_50_80 ,    
ESA_FTE_80 ,    
 Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,Effort_Account_Compliance_Percent    
 ,Associate_Compliance_Percent    
FROM #Account_Compliance_AVM     
ORDER BY Associate_Compliance_Percent DESC    
   
  
TRUNCATE table [AdpR].Account_Compliance_AVM_AM    
    
INSERT INTO [AdpR].Account_Compliance_AVM_AM    
    
    
SELECT DISTINCT    
 Parent_Accountid    
 ,Parent_AccountName,    
 Vertical,   
 MarketUnitName,BU,[AVM AM Project #],  
 ESA_AVM_FTE ,    
ESA_FTE_Zero ,    
ESA_FTE_0_25 ,    
ESA_FTE_25_50 ,    
ESA_FTE_50_80 ,    
ESA_FTE_80 ,    
 Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,Effort_Account_Compliance_Percent    
 ,Associate_Compliance_Percent    
FROM #Account_Compliance_AVM_AM     
ORDER BY Associate_Compliance_Percent DESC    
  
--select * from #Account_Compliance_AVM_INTEG  
  
  
  
TRUNCATE table [AdpR].Account_Compliance_AVM_AD    
    
INSERT INTO [AdpR].Account_Compliance_AVM_AD    
    
    
SELECT DISTINCT    
 Parent_Accountid    
 ,Parent_AccountName,    
 Vertical,   
 MarketUnitName,BU,[AVM AD Project #],  
 ESA_AVM_FTE ,    
ESA_FTE_Zero ,    
ESA_FTE_0_25 ,    
ESA_FTE_25_50 ,    
ESA_FTE_50_80 ,    
ESA_FTE_80 ,    
 Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,Effort_Account_Compliance_Percent    
 ,Associate_Compliance_Percent    
FROM #Account_Compliance_AVM_AD    
ORDER BY Associate_Compliance_Percent DESC    
   
  
 TRUNCATE table [AdpR].Account_Compliance_AVM_INTEG   
    
INSERT INTO [AdpR].Account_Compliance_AVM_INTEG    
    
    
SELECT DISTINCT    
 Parent_Accountid    
 ,Parent_AccountName,    
 Vertical,   
 MarketUnitName,BU,[AVM INTEG Project #],  
 ESA_AVM_FTE ,    
ESA_FTE_Zero ,    
ESA_FTE_0_25 ,    
ESA_FTE_25_50 ,    
ESA_FTE_50_80 ,    
ESA_FTE_80 ,    
 Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,Effort_Account_Compliance_Percent    
 ,Associate_Compliance_Percent    
FROM #Account_Compliance_AVM_INTEG     
ORDER BY Associate_Compliance_Percent DESC   

END TRY  
  BEGIN CATCH  
 DECLARE @ErrorMessage VARCHAR(8000);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC [AppVisionLens].[dbo].AVL_InsertError '[dbo].[AVM_AssociateData_WeekAndMonth] ', @ErrorMessage, '',''  
  RETURN @ErrorMessage  
  END CATCH     
  
END 