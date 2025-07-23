CREATE   PROCEDURE [ADP].[CDB_AssociateData_Monthly]    
    
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
     
    
    
--Select @DatepartToday    
    
    
IF(@DatepartToday != 3)    
    
    
    
BEGIN    
    
SET @FirstDay =  DATEADD(month, DATEDIFF(month, -2, getdate()) -2, 0)    
    
-- DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0)--    
    
SET @LastDate =  DATEADD(ss, -1, DATEADD(month, DATEDIFF(month, 0, getdate()), 0))    
    
--DATEADD(ss, -1, DATEADD(month, DATEDIFF(month, 0, getdate()), 0))--    
    
--set  @LastDate = DATEADD(wk,DATEDIFF(wk,7,@LastDate),5)    
    
SET @StartDate = (SELECT    
  @FirstDay)    
    
SET @EndDate = (SELECT    
  @LastDate)    
    
    
END ELSE BEGIN    
    
    
SET @FirstDay = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE() - 3), 0)    
    
    
SET @LastDate = GETDATE() - 3    
    
    
    
--set  @LastDate = DATEADD(wk,DATEDIFF(wk,7,@LastDate),5)    
    
    
SET @StartDate = (SELECT    
  @FirstDay)    
    
SET @EndDate = (SELECT    
  @LastDate)    
    
    
END    
    
    
--select @FirstDay    
    
    
    
--select @LastDate    
    
    
CREATE TABLE #WeekDays    
    
    
(    
    
    
DateList DATE,    
    
    
DayWeek VARCHAR(15)    
    
    
)    
    
    
DECLARE @Datepart1 INT    
    
    
SET @Datepart1 = DATEPART(dd, @FirstDay)    
     
    
    
DECLARE @Datepart2 INT    
    
    
SET @Datepart2 = DATEPART(dd, @LastDate)    
     
    
    
--SELECT @Datepart1    
    
    
    
--SELECT @Datepart2    
    
    
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
    
--select * from #WeekDays    
    
    
SET @WorkdAYS = (SELECT    
  COUNT(*) AS WorkDays    
 FROM #WeekDays)    
    
    
SET @WorkHours = (SELECT    
  (COUNT(*) * 8) AS WorkHours    
 FROM #WeekDays)    
    
    
--SELECT @WorkHours    
    
SET @MASCOUNT = CONVERT(DECIMAL(10, 2), (22 / CONVERT(DECIMAL(10, 2), @WorkdAYS)))    
    
    
--SELECT @MASCOUNT    
    
--SELECT @WorkdAYS    
    
--SELECT @Workhours    
    
SELECT    
 CONVERT(VARCHAR, CONVERT(DATE, @StartDate), 9)    
    
SELECT    
 CONVERT(VARCHAR, CONVERT(DATE, @Enddate), 9)    
    
    
    
-------------------------------------------------------------------    
SELECT    
 *    
 ,CASE    
  WHEN ISNUMERIC(SUBSTRING(Grade, 2, 2)) = 1 THEN SUBSTRING(Grade, 2, 2)    
    
  ELSE NULL    
    
 END AS UpdatedGrade INTO #Temp_Applens    
    
FROM [AppVisionLens].ESA.Associates    
    
    
-- Query to get 'below M' associates i.e grade id greater than 50    
    
    
    
SELECT    
 * INTO #Temp_BM_Applns FROM #Temp_Applens WHERE updatedGrade > 50    
    
    
BEGIN    
    
--SELECT    
-- *    
-- ,ROW_NUMBER() OVER (PARTITION BY Dept_ID ORDER BY EffDt DESC) AS Topp INTO #tmp_DPT    
----FROM CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Department  
--FROM [ADP].[Gmspmo_department_master]    
  
    
--SELECT DISTINCT    
-- JobCode    
-- ,JobCodeDescription INTO #tmp_DSG    
----FROM CTSINTBMVPCRSR1.CentralRepository_Report.dbo.GMSPMO_Designation_Master   
--FROM [Adp].[GMSPMO_Designation_Master]    
  
    
    
SELECT * INTO #Associalte_Final_AVM FROM [Adp].Associate_Allocation_Raw WHERE Department_Name='CDB' OR Department_Name LIKE  '%CDB%' or  
Department_Name LIKE  '%CDB-%'   
    
DELETE  from #Associalte_Final_AVM where associate_id='323477'    
    
END    
--select *from #Associalte_Final_AVM where associate_id='323477'  '1000012040'    
--drop table #Associalte_Final_AVM    
SELECT DISTINCT    
 AF.associate_id    
 ,AF.Associate_Name    
 ,lg.UserID    
 ,PM.EsaProjectID,PM.ProjectName    
 ,LG.ProjectID    
 ,AF.Parent_Accountid as ParentCustomerID    
 ,AF.Parent_AccountName as ParentCustomerName    
 ,LG.IsNonESAAuthorized    
 ,AF.DE_Inscope INTO #Allocatedassoc    
FROM #Associalte_Final_AVM AF    
LEFT JOIN [AppVisionLens].AVL.MAS_ProjectMaster PM    
 ON AF.Project_ID = PM.EsaProjectID    
LEFT JOIN [AppVisionLens].AVL.MAS_LoginMaster LG    
 ON PM.ProjectID = LG.ProjectID    
 AND AF.associate_id = lg.EmployeeID    
LEFT JOIN [AppVisionLens].AVL.Customer CS    
 ON PM.CustomerID = CS.CustomerID    
--LEFT JOIN ESA.BUParentAccounts PA    
-- ON CS.ESA_AccountID = PA.ESA_AccountID    
-- AND af.Parent_Accountid = pa.ParentCustomerID    
WHERE -- AF.DE_Inscope IN('In Scope','Yet to scope') --LG.IsDeleted='0' AND     
CS.IsDeleted = '0' AND PM.IsDeleted = '0' --AND PA.IsActive = '1'      
    
--SELECT *FROM #Allocatedassoc  where EsaProjectID='1000216596' associate_id in ('487358')and     
    
    
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
LEFT JOIN [Adp].Input_Data_AssociateRAW AD    
 ON PM.EsaProjectID = ad.EsaProjectID    
LEFT JOIN [Adp].Input_Excel_Associate B ON PM.EsaProjectID=b.EsaProjectID    
WHERE LG.IsDeleted = '0'    
AND PM.IsDeleted = '0'    
    
--select * FROM #TEMPR WHERE  EsaProjectID='1000216596'    
    
--SELECT * FROM #Temp_BM_Applns WHERE associateid='591548'    
    
SELECT DISTINCT    
 EmployeeID,EMployeeName    
 ,EsaProjectID,ProjectName    
 ,UserID    
 ,ProjectID    
 ,ParentCustomerID    
 ,ParentCustomerName    
 ,IsNonESAAuthorized    
 ,DE_Inscope    
 ,[Dept_Name]    
 ,[Designation] INTO #LoginAssociate    
FROM (SELECT DISTINCT    
  LG.EmployeeID,LG.EMployeeName    
  ,LG.EsaProjectID,LG.ProjectName    
  ,LG.UserID    
  ,LG.ProjectID    
  ,AF.Parent_Accountid as ParentCustomerID    
  ,AF.Parent_AccountName as ParentCustomerName    
  ,LG.IsNonESAAuthorized    
  ,AF.DE_Inscope  ,CRS.[Dept_Name],CRS.[Designation]  
  --,DPT.Dept_Desc    
  --,DS.JobCodeDescription    
  --,ROW_NUMBER() OVER (PARTITION BY LG.EmployeeID, PM.EsaProjectID ORDER BY PM.EsaProjectID DESC) AS Topp    
 FROM #TEMPR LG    
 JOIN #Temp_BM_Applns APS    
  ON LG.EmployeeID = APS.associateid    
 LEFT JOIN [AppVisionLens].AVL.MAS_ProjectMaster PM    
  ON LG.ProjectID = PM.ProjectID    
 JOIN [AppVisionLens].AVL.Customer CS    
  ON PM.CustomerID = CS.CustomerID    
 --JOIN ESA.BUParentAccounts PA    
 -- ON CS.ESA_AccountID = PA.ESA_AccountID    
 LEFT JOIN #Associalte_Final_AVM AF    
  ON PM.EsaProjectID = AF.Project_ID    
 -- AND PA.ParentCustomerID = AF.Parent_Accountid-- AND AF.associate_id=LG.EmployeeID    
 --LEFT JOIN CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Associate_Details CRS    
  LEFT JOIN [Adp].[CentralRepository_Associate_Details] CRS    
  
  ON LG.EmployeeID = crs.Associate_ID    
 --LEFT JOIN #tmp_DPT DPT    
 -- ON CRS.Dept_ID = DPT.Dept_ID    
 --LEFT JOIN #tmp_DSG DS    
 -- ON CRS.JobCode = DS.JobCode --AND TOPP='1'    
 WHERE --LG.IsDeleted='0' AND     
 CS.IsDeleted = '0'    
 AND PM.IsDeleted = '0' --AND AF.DE_Inscope in('In Scope','Yet to scope')     
 --AND DPT.Eff_Status = 'A'    
 --AND DPT.TOPP = 1 --and LG.EmployeeID='669346'    
 --AND PA.IsActive = '1'    
 AND Dept_Name LIKE '%AVM%') TMP    
--WHERE Topp = 1     
    
--select * from  #LoginAssociate where EsaProjectID='1000062765' where employeeid='659975' and esaprojectid='    
-- drop table #LoginAssociate    
--DELETE FROM  #temp2 WHERE topp >1    
    
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
    
--drop table  #Loginmaster_associate    
    
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
 --WHERE DE_Inscope in('In scope','Yet to scope')     
 UNION SELECT DISTINCT    
  associate_id,associate_name    
  ,UserID    
  ,EsaProjectID,projectname    
  ,ProjectID    
  ,ParentCustomerID    
  ,ParentCustomerName    
  ,IsNonESAAuthorized    
 FROM #Allocatedassoc    
 --WHERE DE_Inscope in('In scope','Yet to scope')    
    
--select * from #Loginmaster_associate where IsNonESAAuthorized='1'    
    
    
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
LEFT JOIN [DiscoverEDS].[EDS].[TimesheetDetail_All_Enhancement_AD] B    
  ON a.EmployeeID = b.[SubmitterID]    
  AND a.EsaProjectID = b.[ESAProjectID]    
  AND B.[TimesheetSubmissionDate] BETWEEN @StartDate AND @EndDate  
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,A.EsaProjectID,A.Projectname    
  ,A.EmployeeID,A.EmployeeName    
    ,IsNonESAAuthorized    
    
     
    
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
 FROM #Associalte_Final_AVM     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
   ,Project_ID,[Project Name]    
  ,associate_id    
  ,Associate_Name    
    
    
    
    
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
     
 join [Adp].Input_Data_AssociateRAW BU    
  ON af.EsaProjectID = bU.EsaProjectID    
 LEFT JOIN #Total_Effort B    
  ON af.Parent_Accountid = b.Parent_Accountid    
  AND af.Parent_AccountName = b.Parent_AccountName    
  AND af.EsaProjectID = b.EsaProjectID    
  AND af.EmployeeID = b.EmployeeID    
    
    
    
select distinct Parent_Accountid,SBU,VERTICAL,Associate_ID,project_id, Department_Name into #department from [Adp].Associate_Allocation_Raw     
    
SELECT DISTINCT Parent_Accountid,SBU,VERTICAL,Associate_ID, project_id,Job_code,Designation into #designation from [Adp].Associate_Allocation_Raw    
    
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
sum(A.MPS_Effort),sum(A.Work_Profile_AD),Sum(A.MAS_Effort),sum(A.Actual_Effort),ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours), 0) * 100), 0) from #AssociateActual_Final_AVM A    
JOIN [Adp].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID      
where C.DE_Inscope in('In Scope','Yet to scope')    
GROUP BY A.Parent_Accountid,A.Parent_AccountName,A.EsaProjectID,A.Projectname,A.SBU,A.EmployeeID,A.Department_Name    
    
    
    
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
    
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,EsaProjectid ,ProjectName ,SBU ,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort ,Work_Profile_AD,MAS_Effort ,Actual_Effort ,    
Associate_Project_Compliance    
  INTO #Associate_Greater80_Prj_avm    
FROM #Associate_Total_project_Compliance_avm    
WHERE Associate_Project_Compliance > 80    
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,EsaProjectid ,ProjectName ,SBU ,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,    
Associate_Project_Compliance INTO #Associate_Greater_50_80_Prj_avm    
FROM #Associate_Total_project_Compliance_avm    
WHERE Associate_Project_Compliance > 50 and Associate_Project_Compliance  <=80    
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,EsaProjectid ,ProjectName ,SBU ,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,    
Associate_Project_Compliance INTO #Associate_Greater_25_50_prj_avm    
FROM #Associate_Total_project_Compliance_avm    
WHERE Associate_Project_Compliance > 25 and Associate_Project_Compliance  <=50    
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,EsaProjectid ,ProjectName ,SBU ,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD  ,MAS_Effort ,Actual_Effort ,    
Associate_Project_Compliance INTO #Associate_Greater_0_25_prj_avm    
FROM #Associate_Total_project_Compliance_avm    
WHERE Associate_Project_Compliance >0 and Associate_Project_Compliance  <=25    
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,EsaProjectid ,ProjectName ,SBU ,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD  ,MAS_Effort ,Actual_Effort ,    
Associate_Project_Compliance INTO #Associate_Greater_Zero_prj_avm    
FROM #Associate_Total_project_Compliance_avm    
WHERE Associate_Project_Compliance =0    
    
    
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
from #AssociateActual_Final_AVM A    
JOIN [Adp].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'  --and Parent_Accountid in('2000004','2000522')  
GROUP BY Parent_Accountid,Parent_AccountName,EmployeeID,Department_Name,Vertical,C.PracticeOwner,C.MARKET_BU ,C.PROJECTSCOPE  
    
    
select distinct A.Parent_Accountid ,A.EsaProjectID as 'Project#',c.projectscope,sum(Available_Hours) as 'Availablehours' Into #ScopeProject_tmp  
from #AssociateActual_Final_AVM A  
JOIN [Adp].Input_Data_AssociateRAW C ON A.parent_accountid=C.parentaccountid and a.EsaProjectID=C.EsaProjectID     
GROUP BY A.Parent_Accountid ,A.EsaProjectID ,c.projectscope  
 --where Parent_Accountid='2000559'  
  
select Parent_Accountid, ProjectScope, count(Project#) as 'Project#',sum(Availablehours) as 'Availablehours' into #ScopeProject  
from  #ScopeProject_tmp a  
group by A.Parent_Accountid,a.ProjectScope  
  
  
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
  
    
SELECT  DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater80_AM    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 80  and Project_scope='AVM'  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_50_80_AM    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80  and Project_scope='AVM'  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_25_50_AM    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50  and Project_scope='AVM'  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_0_25_AM    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25  and Project_scope='AVM'  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance    
INTO #Associate_Greater_Zero_AM   
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] =0   and Project_scope='AVM'  
    
      
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
       
   
 --AD Scope Account Compliance Split  
    
    
SELECT  DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater80_AD    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 80  and Project_scope='AD'  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_50_80_AD    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80  and Project_scope='AD'  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_25_50_AD    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50  and Project_scope='AD'  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_0_25_AD    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25  and Project_scope='AD'  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance    
INTO #Associate_Greater_Zero_AD   
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] =0   and Project_scope='AD'  
    
      
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
       
   
 --INTEG Scope Account Compliance Split  
    
    
SELECT  DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater80_INTEG    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 80  and Project_scope not in ('AD','AVM','')  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_50_80_INTEG    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80  and Project_scope not in ('AD','AVM','')  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_25_50_INTEG    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50  and Project_scope not in ('AD','AVM','')  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_0_25_INTEG    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25  and Project_scope not in ('AD','AVM','')  
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance    
INTO #Associate_Greater_Zero_INTEG   
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] =0   and Project_scope not in ('AD','AVM','')  
    
      
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
    
    
    
CREATE table #Account_Compliance_AVM_INTEG     
    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),  
MarketUnitName varchar(50),  
BU varchar(50),  
[AVM INTEG  Project #] INT,  
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
       
  
  
--All Scope account compliance split  
  
  
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
from #AssociateActual_Final_AVM A    
JOIN [Adp].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'  --and Parent_Accountid in('2000004','2000522')  
GROUP BY Parent_Accountid,Parent_AccountName,EmployeeID,Department_Name,Vertical,C.PracticeOwner,C.MARKET_BU   
    
  
  
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
  
   
    
SELECT  DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater80    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] > 80    
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_50_80    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80    
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_25_50    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50    
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance     
INTO #Associate_Greater_0_25    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25    
    
SELECT DISTINCT Parent_Accountid ,Parent_AccountName ,Vertical ,MarketUnitName,BU,EmployeeID ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_Account_Compliance  INTO #Associate_Greater_Zero    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] =0    
    
    
    
CREATE TABLE #Associate_zero    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),  
Vertical varchar(50),  
ESA_FTE_Zero DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_Zero    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID  ,Vertical  
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_Zero     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID ,Vertical   
    
CREATE TABLE #Associate_0_25    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),   
Vertical varchar(50),  
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
    ,EmployeeID,Vertical    
    
CREATE TABLE #Associate_25_50    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),  
Vertical varchar(50),  
ESA_FTE_25_50 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID ,Vertical   
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater_25_50     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID ,Vertical   
    
    
CREATE TABLE #Associate_50_80    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),  
Vertical varchar(50),  
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
    
    
CREATE TABLE #Associate_80    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
Vertical varchar(50),  
ESA_FTE_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID,Vertical    
  ,SUM(Avaialble_FTE_Below_M)     
 FROM #Associate_Greater80     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID,Vertical    
    
     
    
    
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
 LEFT JOIN #Associate_zero B ON a.Parent_Accountid = b.Parent_Accountid AND A.EmployeeID = b.EmployeeID  and a.Vertical=b.Vertical  
 LEFT JOIN #Associate_0_25 C ON a.Parent_Accountid = c.Parent_Accountid AND A.EmployeeID = c.EmployeeID  and a.Vertical=c.Vertical  
 LEFT JOIN #Associate_25_50 D ON a.Parent_Accountid = d.Parent_Accountid AND A.EmployeeID = d.EmployeeID  and a.Vertical=d.Vertical  
 LEFT JOIN #Associate_50_80 E ON a.Parent_Accountid = e.Parent_Accountid AND A.EmployeeID =e.EmployeeID  and a.Vertical=e.Vertical  
 LEFT JOIN #Associate_80 F ON a.Parent_Accountid = f.Parent_Accountid AND A.EmployeeID = f.EmployeeID and a.Vertical=f.Vertical    
    
 GROUP BY a.Parent_Accountid    
    ,a.Parent_AccountName,A.Vertical,a.MarketUnitName,a.BU    
       
   
 TRUNCATE table [Adp].Account_Compliance_AVM    
    
INSERT INTO [ADP].Account_Compliance_AVM    
    
    
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
   
  
TRUNCATE table [Adp].Account_Compliance_AVM_AM    
    
INSERT INTO [Adp].Account_Compliance_AVM_AM    
    
    
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
  
  
  
TRUNCATE table [Adp].Account_Compliance_AVM_AD    
    
INSERT INTO [Adp].Account_Compliance_AVM_AD    
    
    
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
   
  
 TRUNCATE table [Adp].Account_Compliance_AVM_INTEG   
    
INSERT INTO [Adp].Account_Compliance_AVM_INTEG    
    
    
SELECT DISTINCT    
 Parent_Accountid    
 ,Parent_AccountName,    
 Vertical,   
 MarketUnitName,BU,[AVM INTEG  Project #],  
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
JOIN [Adp].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'    
GROUP BY SBU,EmployeeID,Department_Name ,C.PROJECTSCOPE   
    
  
    
select A.SBU,C.ProjectScope,count(A.EsaProjectID) as 'Project#' Into #ScopeBU from #AssociateActual_Final_AVM A  
JOIN [Adp].Input_Data_AssociateRAW C ON A.parent_accountid=C.parentaccountid and a.EsaProjectID=C.EsaProjectID     
group by A.SBU,C.ProjectScope  
  
  
--AVM Scopr BU Compliance  
  
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater80_SBU_AM    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] > 80  and Project_Scope='AVM'  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_50_80_SBU_AM    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80  and Project_Scope='AVM'  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_25_50_SBU_AM    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50  and Project_Scope='AVM'  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_0_25_SBU_AM    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25  and Project_Scope='AVM'  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_zero_SBU_AM    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] =0  and Project_Scope='AVM'  
    
    
    
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
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)) * 100, 0),0) AS 'Associate_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)) * 100, 0),0) AS 'Associate_Compliance'    
    
 FROM #BUDATA_AM    
    
TRUNCATE table [Adp].SBU_Compliance_AVM_AM    
    
INSERT INTO [Adp].SBU_Compliance_AVM_AM    
    
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
  
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater80_SBU_AD   
FROM #Associate_BUcompliance_AVM  
WHERE [Associate_BU_Compliance] > 80  and Project_Scope='AD'  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_50_80_SBU_AD    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80  and Project_Scope='AD'  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_25_50_SBU_AD    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50  and Project_Scope='AD'  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_0_25_SBU_AD    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25  and Project_Scope='AD'  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_zero_SBU_AD    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] =0  and Project_Scope='AD'  
    
    
    
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
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)) * 100, 0),0) AS 'Associate_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)) * 100, 0),0) AS 'Associate_Compliance'    
    
 FROM #BUDATA_AD    
    
TRUNCATE table [Adp].SBU_Compliance_AVM_AD    
    
INSERT INTO [Adp].SBU_Compliance_AVM_AD    
    
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
  
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater80_SBU_INTEG   
FROM #Associate_BUcompliance_AVM  
WHERE [Associate_BU_Compliance] > 80  and Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_50_80_SBU_INTEG    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80  and Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_25_50_SBU_INTEG    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50  and Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_0_25_SBU_INTEG    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25  and Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_zero_SBU_INTEG    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] =0  and Project_Scope not in ('AD','AVM','')  
    
    
    
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
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)) * 100, 0),0) AS 'Associate_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)) * 100, 0),0) AS 'Associate_Compliance'    
    
 FROM #BUDATA_INTEG    
    
TRUNCATE table [Adp].SBU_Compliance_AVM_INTEG    
    
INSERT INTO [Adp].SBU_Compliance_AVM_INTEG    
    
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
  
  
  
  
-- All Scope BU Compliacne    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort, Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater80_SBU    
FROM #Associate_BUcompliance_AVM   
WHERE [Associate_BU_Compliance] > 80    
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_50_80_SBU    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80    
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_25_50_SBU    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50    
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_0_25_SBU    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25    
    
SELECT DISTINCT SBU ,EmployeeID ,Department_Name ,Avaialble_FTE_Below_M ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,Associate_BU_Compliance     
INTO #Associate_Greater_zero_SBU    
FROM #Associate_BUcompliance_AVM    
WHERE [Associate_BU_Compliance] =0    
    
    
    
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
 FROM #Associate_BUcompliance_AVM A    
 LEFT JOIN #Associate_0_SBU F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_SBU E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_SBU D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_SBU C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_SBU B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
    
 GROUP BY a.SBU    
    
    
    
SELECT DISTINCT SBU ,ESA_FTE ,ESA_FTE_Zero ,ESA_FTE_0_25 ,ESA_FTE_25_50 ,ESA_FTE_50_80 ,ESA_FTE_80 ,Available_Hours ,MPS_Effort,Work_Profile_AD ,MAS_Effort ,Actual_Effort ,BU_Effort_Compliance_Percent ,    
Associate_Compliance_Percent INTO #BUDATA    
FROM #SBU_Compliance_AVM    
    
    
    
INSERT INTO #SBU_Compliance_AVM    
    
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
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)) * 100, 0),0) AS 'Associate_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)) * 100, 0),0) AS 'Associate_Compliance'    
    
 FROM #BUDATA    
    
TRUNCATE table [Adp].SBU_Compliance_AVM    
    
INSERT INTO [Adp].SBU_Compliance_AVM    
    
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
FROM #SBU_Compliance_AVM    
ORDER BY CASE   WHEN [SBU]= 'GRAND TOTAL' THEN 1    
   ELSE 0    
END, [SBU]    
  
----****************Vertical****************_-----------------  
  
    
CREATE Table #Associate_VERTICALcompliance_AVM    
(    
    
SBU varchar (100),    
VERTICAL varchar (100),   
EmployeeID varchar(15),    
Department_Name varchar(100),    
Project_Scope varchar(50),  
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),   
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_VERTICAL_Compliance decimal (10,2)    
)    
  
    
 INSERT INTO #Associate_VERTICALcompliance_AVM    
  
 SELECT DISTINCT A.SBU,a.Vertical,a.EmployeeID,a.Department_Name,C.PROJECTSCOPE,sum(a.Avaialble_FTE_Below_M),sum(a.Available_Hours),    
sum(a.MPS_Effort),sum(a.Work_Profile_AD),Sum(a.MAS_Effort),sum(a.Actual_Effort),ISNULL(((SUM(a.Actual_Effort)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0) from #AssociateActual_Final_AVM A    
JOIN [Adp].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'    
GROUP BY sbu,Vertical,EmployeeID,Department_Name,C.PROJECTSCOPE    
  
  
--TRUNCATE table [dbo].Adp_VERTICAL_Compliance_RAW    
--INSERT INTO   [dbo].Adp_VERTICAL_Compliance_RAW     
--SELECT SBU ,  
--VERTICAL,  
--EmployeeID ,    
--Department_Name ,    
--Avaialble_FTE_Below_M ,    
--Available_Hours ,    
--MPS_Effort ,    
--MAS_Effort ,    
--Actual_Effort ,    
--Associate_VERTICAL_Compliance   from #Associate_VERTICALcompliance  
  
  
--AD SCOPE VERTICAL  
  
  
SELECT DISTINCT SBU,vERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater80_VERTICAL_AD    
FROM #Associate_VERTICALcompliance_AVM    
WHERE [Associate_VERTICAL_Compliance] > 80  AND Project_Scope='AD'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_50_80_VERTICAL_AD   
FROM #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance > 50 and Associate_VERTICAL_Compliance  <=80  AND Project_Scope='AD'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_25_50_VERTICAL_AD   
FROM #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance >  25 and Associate_VERTICAL_Compliance  <=50  AND Project_Scope='AD'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_0_25_VERTICAL_AD    
FROM  #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance  >0 and Associate_VERTICAL_Compliance  <=25  AND Project_Scope='AD'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_zero_VERTICAL_AD   
FROM  #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance =0  AND Project_Scope='AD'  
  
CREATE TABLE #Associate_80_VERTICAL_AD   
(    
    
SBU varchar (50),   
VERTICAL varchar (50),   
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_VERTICAL_AD    
    
 SELECT DISTINCT    
  SBU  , VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_VERTICAL_AD  
 GROUP BY SBU  , VERTICAL  
    ,EmployeeID    
    
  
    
CREATE TABLE #Associate_50_80_VERTICAL_AD   
(    
    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_VERTICAL_AD  
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80_VERTICAL_AD    
 GROUP BY SBU ,VERTICAL   
    ,EmployeeID    
    
    
CREATE TABLE #Associate_25_50_VERTICAL_AD    
(    
    
SBU varchar (50),    
VERTICAL varchar (50),  
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_VERTICAL_AD    
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50_VERTICAL_AD  
 GROUP BY SBU  ,VERTICAL  
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_25_VERTICAL_AD  
(    
    
SBU varchar (50),   
VERTICAL varchar (50),  
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_VERTICAL_AD    
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_0_25_VERTICAL_AD   
 GROUP BY SBU  ,VERTICAL  
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_VERTICAL_AD   
(    
    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_VERTICAL_AD   
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_zero_VERTICAL_AD    
 GROUP BY SBU  , VERTICAL  
    ,EmployeeID    
    
    
  CREATE table #VERTICAL_Compliance_AVM_AD    
    
(    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
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
VERTICAL_Effort_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #VERTICAL_Compliance_AVM_AD    
    
 SELECT DISTINCT    
  a.SBU,  
  A.VERTICAL  
  ,ISNULL(SUM(Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(f.ESA_FTE_0_BU), 0)    
  ,ISNULL(SUM(e.ESA_FTE_0_25_BU), 0)    
  ,ISNULL(SUM(D.ESA_FTE_25_50_BU), 0)    
  ,ISNULL(SUM(C.ESA_FTE_50_80_BU), 0)    
  ,ISNULL(SUM(b.ESA_FTE_80_BU), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
  ,ISNULL(SUM(MPS_Effort), 0)    
  ,ISNULL(SUM(Work_Profile_AD), 0)    
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_VERTICALcompliance_AVM A    
 LEFT JOIN #Associate_0_VERTICAL_AD F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_VERTICAL_AD E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_VERTICAL_AD D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_VERTICAL_AD C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_VERTICAL_AD B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
  WHERE A.Project_Scope='AD'   
 GROUP BY a.SBU  ,A.VERTICAL  
    
    
SELECT DISTINCT SBU,VERTICAL,ESA_FTE,ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,Available_Hours,    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,    
VERTICAL_Effort_Compliance_Percent,    
Associate_Compliance_Percent    
INTO #VERTICALDATA_AVM_AD    
FROM #VERTICAL_Compliance_AVM_AD   
  
  
INSERT INTO #VERTICAL_Compliance_AVM_AD    
    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]  ,''  
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE)) AS 'ESA_FTE'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_Zero)) AS 'ESA FTE with TSC %=0'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_0_25)) AS 'ESA FTE with TSC %>0 to 25'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_25_50)) AS 'ESA FTE with TSC %>25 to 50'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_50_80)) AS 'ESA FTE with TSC %>50 to 80'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_80)) AS 'ESA FTE with TSC %>80'    
  ,SUM(CONVERT(DECIMAL(10,2), Available_Hours)) AS 'Available_Hours'    
  ,SUM(CONVERT(DECIMAL(10,2), MPS_Effort)) AS 'MPS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS 'Work_Profile_AD'    
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)) * 100, 0),0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)) * 100, 0),0) AS 'Associate_Compliance'    
    
FROM #VERTICALDATA_AVM_AD  --group by vertical  
  
 TRUNCATE table [Adp].VERTICAL_Compliance_AVM_AD    
    
INSERT INTO [Adp].VERTICAL_Compliance_AVM_AD  
    
SELECT    
 [SBU] AS 'SBU'  ,VERTICAL  
 ,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,VERTICAL_Effort_Compliance_Percent AS [VERTICAL Effort Compliance%(All)]    
 ,Associate_Compliance_Percent AS [Associate_BU_Compliance%]    
FROM #VERTICAL_Compliance_AVM_AD    
ORDER BY CASE    
 WHEN SBU = 'GRAND TOTAL' THEN 1    
    
 ELSE 0    
END, [SBU]    
    
  
  
--AM SCOPE VERTICAL  
  
  
SELECT DISTINCT SBU,vERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater80_VERTICAL_AM    
FROM #Associate_VERTICALcompliance_AVM    
WHERE [Associate_VERTICAL_Compliance] > 80  AND Project_Scope='AVM'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_50_80_VERTICAL_AM   
FROM #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance > 50 and Associate_VERTICAL_Compliance  <=80  AND Project_Scope='AVM'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_25_50_VERTICAL_AM   
FROM #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance >  25 and Associate_VERTICAL_Compliance  <=50  AND Project_Scope='AVM'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_0_25_VERTICAL_AM    
FROM  #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance  >0 and Associate_VERTICAL_Compliance  <=25  AND Project_Scope='AVM'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_zero_VERTICAL_AM   
FROM  #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance =0  AND Project_Scope='AVM'  
  
CREATE TABLE #Associate_80_VERTICAL_AM   
(    
    
SBU varchar (50),   
VERTICAL varchar (50),   
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_VERTICAL_AM    
    
 SELECT DISTINCT    
  SBU  , VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_VERTICAL_AM  
 GROUP BY SBU  , VERTICAL  
    ,EmployeeID    
    
  
    
CREATE TABLE #Associate_50_80_VERTICAL_AM   
(    
    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_VERTICAL_AM  
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80_VERTICAL_AM    
 GROUP BY SBU ,VERTICAL   
    ,EmployeeID    
    
    
CREATE TABLE #Associate_25_50_VERTICAL_AM    
(    
    
SBU varchar (50),    
VERTICAL varchar (50),  
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_VERTICAL_AM    
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50_VERTICAL_AM  
 GROUP BY SBU  ,VERTICAL  
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_25_VERTICAL_AM  
(    
    
SBU varchar (50),   
VERTICAL varchar (50),  
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_VERTICAL_AM    
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_0_25_VERTICAL_AM   
 GROUP BY SBU  ,VERTICAL  
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_VERTICAL_AM   
(    
    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_VERTICAL_AM   
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_zero_VERTICAL_AM    
 GROUP BY SBU  , VERTICAL  
    ,EmployeeID    
    
    
  CREATE table #VERTICAL_Compliance_AVM_AM    
    
(    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
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
VERTICAL_Effort_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #VERTICAL_Compliance_AVM_AM    
    
 SELECT DISTINCT    
  a.SBU,  
  A.VERTICAL  
  ,ISNULL(SUM(Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(f.ESA_FTE_0_BU), 0)    
  ,ISNULL(SUM(e.ESA_FTE_0_25_BU), 0)    
  ,ISNULL(SUM(D.ESA_FTE_25_50_BU), 0)    
  ,ISNULL(SUM(C.ESA_FTE_50_80_BU), 0)    
  ,ISNULL(SUM(b.ESA_FTE_80_BU), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
  ,ISNULL(SUM(MPS_Effort), 0)    
  ,ISNULL(SUM(Work_Profile_AD), 0)    
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_VERTICALcompliance_AVM A    
 LEFT JOIN #Associate_0_VERTICAL_AM F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_VERTICAL_AM E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_VERTICAL_AM D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_VERTICAL_AM C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_VERTICAL_AM B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
  WHERE A.Project_Scope='AVM'   
 GROUP BY a.SBU  ,A.VERTICAL  
    
    
SELECT DISTINCT SBU,VERTICAL,ESA_FTE,ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,Available_Hours,    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,    
VERTICAL_Effort_Compliance_Percent,    
Associate_Compliance_Percent    
INTO #VERTICALDATA_AVM_AM    
FROM #VERTICAL_Compliance_AVM_AM   
  
  
INSERT INTO #VERTICAL_Compliance_AVM_AM    
    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]  ,''  
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE)) AS 'ESA_FTE'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_Zero)) AS 'ESA FTE with TSC %=0'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_0_25)) AS 'ESA FTE with TSC %>0 to 25'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_25_50)) AS 'ESA FTE with TSC %>25 to 50'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_50_80)) AS 'ESA FTE with TSC %>50 to 80'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_80)) AS 'ESA FTE with TSC %>80'    
  ,SUM(CONVERT(DECIMAL(10,2), Available_Hours)) AS 'Available_Hours'    
  ,SUM(CONVERT(DECIMAL(10,2), MPS_Effort)) AS 'MPS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS 'Work_Profile_AD'    
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)) * 100, 0),0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)) * 100, 0),0) AS 'Associate_Compliance'    
    
FROM #VERTICALDATA_AVM_AM  --group by vertical  
  
 TRUNCATE table [Adp].VERTICAL_Compliance_AVM_AM    
    
INSERT INTO [Adp].VERTICAL_Compliance_AVM_AM  
    
SELECT    
 [SBU] AS 'SBU'  ,VERTICAL  
 ,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,VERTICAL_Effort_Compliance_Percent AS [VERTICAL Effort Compliance%(All)]    
 ,Associate_Compliance_Percent AS [Associate_BU_Compliance%]    
FROM #VERTICAL_Compliance_AVM_AM    
ORDER BY CASE    
 WHEN SBU = 'GRAND TOTAL' THEN 1    
    
 ELSE 0    
END, [SBU]    
    
  
--INTEH Scope Vertical  
  
SELECT DISTINCT SBU,vERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater80_VERTICAL_INTEG    
FROM #Associate_VERTICALcompliance_AVM    
WHERE [Associate_VERTICAL_Compliance] > 80  AND Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_50_80_VERTICAL_INTEG   
FROM #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance > 50 and Associate_VERTICAL_Compliance  <=80  AND Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_25_50_VERTICAL_INTEG   
FROM #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance >  25 and Associate_VERTICAL_Compliance  <=50  AND Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_0_25_VERTICAL_INTEG    
FROM  #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance  >0 and Associate_VERTICAL_Compliance  <=25  AND Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_zero_VERTICAL_INTEG   
FROM  #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance =0  AND Project_Scope not in ('AD','AVM','')  
  
CREATE TABLE #Associate_80_VERTICAL_INTEG   
(    
    
SBU varchar (50),   
VERTICAL varchar (50),   
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_VERTICAL_INTEG    
    
 SELECT DISTINCT    
  SBU  , VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_VERTICAL_INTEG  
 GROUP BY SBU  , VERTICAL  
    ,EmployeeID    
    
  
    
CREATE TABLE #Associate_50_80_VERTICAL_INTEG   
(    
    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_VERTICAL_INTEG  
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80_VERTICAL_INTEG    
 GROUP BY SBU ,VERTICAL   
    ,EmployeeID    
    
    
CREATE TABLE #Associate_25_50_VERTICAL_INTEG    
(    
    
SBU varchar (50),    
VERTICAL varchar (50),  
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_VERTICAL_INTEG    
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50_VERTICAL_INTEG  
 GROUP BY SBU  ,VERTICAL  
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_25_VERTICAL_INTEG  
(    
    
SBU varchar (50),   
VERTICAL varchar (50),  
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_VERTICAL_INTEG    
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_0_25_VERTICAL_INTEG   
 GROUP BY SBU  ,VERTICAL  
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_VERTICAL_INTEG   
(    
    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_VERTICAL_INTEG   
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_zero_VERTICAL_INTEG    
 GROUP BY SBU  , VERTICAL  
    ,EmployeeID    
    
    
  CREATE table #VERTICAL_Compliance_AVM_INTEG    
    
(    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
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
VERTICAL_Effort_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #VERTICAL_Compliance_AVM_INTEG    
    
 SELECT DISTINCT    
  a.SBU,  
  A.VERTICAL  
  ,ISNULL(SUM(Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(f.ESA_FTE_0_BU), 0)    
  ,ISNULL(SUM(e.ESA_FTE_0_25_BU), 0)    
  ,ISNULL(SUM(D.ESA_FTE_25_50_BU), 0)    
  ,ISNULL(SUM(C.ESA_FTE_50_80_BU), 0)    
  ,ISNULL(SUM(b.ESA_FTE_80_BU), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
  ,ISNULL(SUM(MPS_Effort), 0)    
  ,ISNULL(SUM(Work_Profile_AD), 0)    
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_VERTICALcompliance_AVM A    
 LEFT JOIN #Associate_0_VERTICAL_INTEG F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_VERTICAL_INTEG E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_VERTICAL_INTEG D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_VERTICAL_INTEG C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_VERTICAL_INTEG B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
  WHERE A.Project_Scope not in ('AD','AVM','')  
 GROUP BY a.SBU  ,A.VERTICAL  
    
    
SELECT DISTINCT SBU,VERTICAL,ESA_FTE,ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,Available_Hours,    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,    
VERTICAL_Effort_Compliance_Percent,    
Associate_Compliance_Percent    
INTO #VERTICALDATA_AVM_INTEG    
FROM #VERTICAL_Compliance_AVM_INTEG   
  
  
INSERT INTO #VERTICAL_Compliance_AVM_INTEG    
    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]  ,''  
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE)) AS 'ESA_FTE'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_Zero)) AS 'ESA FTE with TSC %=0'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_0_25)) AS 'ESA FTE with TSC %>0 to 25'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_25_50)) AS 'ESA FTE with TSC %>25 to 50'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_50_80)) AS 'ESA FTE with TSC %>50 to 80'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_80)) AS 'ESA FTE with TSC %>80'    
  ,SUM(CONVERT(DECIMAL(10,2), Available_Hours)) AS 'Available_Hours'    
  ,SUM(CONVERT(DECIMAL(10,2), MPS_Effort)) AS 'MPS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS 'Work_Profile_AD'    
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)) * 100, 0),0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)) * 100, 0),0) AS 'Associate_Compliance'    
    
FROM #VERTICALDATA_AVM_INTEG  --group by vertical  
  
 TRUNCATE table [Adp].VERTICAL_Compliance_AVM_INTEG    
    
INSERT INTO [Adp].VERTICAL_Compliance_AVM_INTEG  
    
SELECT    
 [SBU] AS 'SBU'  ,VERTICAL  
 ,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,VERTICAL_Effort_Compliance_Percent AS [VERTICAL Effort Compliance%(All)]    
 ,Associate_Compliance_Percent AS [Associate_BU_Compliance%]    
FROM #VERTICAL_Compliance_AVM_INTEG    
ORDER BY CASE    
 WHEN SBU = 'GRAND TOTAL' THEN 1    
    
 ELSE 0    
END, [SBU]    
    
  
  
--ALL SCOPE VERTICAL  
  
SELECT DISTINCT SBU,vERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater80_VERTICAL    
FROM #Associate_VERTICALcompliance_AVM    
WHERE [Associate_VERTICAL_Compliance] > 80    
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_50_80_VERTICAL   
FROM #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance > 50 and Associate_VERTICAL_Compliance  <=80    
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_25_50_VERTICAL   
FROM #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance >  25 and Associate_VERTICAL_Compliance  <=50    
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_0_25_VERTICAL    
FROM  #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance  >0 and Associate_VERTICAL_Compliance  <=25    
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_zero_VERTICAL   
FROM  #Associate_VERTICALcompliance_AVM    
WHERE Associate_VERTICAL_Compliance =0    
  
CREATE TABLE #Associate_80_VERTICAL   
(    
    
SBU varchar (50),   
VERTICAL varchar (50),   
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_VERTICAL    
    
 SELECT DISTINCT    
  SBU  , VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_VERTICAL  
 GROUP BY SBU  , VERTICAL  
    ,EmployeeID    
    
  
    
CREATE TABLE #Associate_50_80_VERTICAL   
(    
    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_VERTICAL  
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80_VERTICAL    
 GROUP BY SBU ,VERTICAL   
    ,EmployeeID    
    
    
CREATE TABLE #Associate_25_50_VERTICAL    
(    
    
SBU varchar (50),    
VERTICAL varchar (50),  
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_VERTICAL    
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50_VERTICAL  
 GROUP BY SBU  ,VERTICAL  
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_25_VERTICAL  
(    
    
SBU varchar (50),   
VERTICAL varchar (50),  
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_VERTICAL    
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_0_25_VERTICAL   
 GROUP BY SBU  ,VERTICAL  
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_VERTICAL   
(    
    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_VERTICAL   
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_Zero_VERTICAL    
 GROUP BY SBU  , VERTICAL  
    ,EmployeeID    
    
    
  CREATE table #VERTICAL_Compliance_AVM    
    
(    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
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
VERTICAL_Effort_Compliance_Percent decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #VERTICAL_Compliance_AVM    
    
 SELECT DISTINCT    
  a.SBU,  
  A.VERTICAL  
  ,ISNULL(SUM(Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(f.ESA_FTE_0_BU), 0)    
  ,ISNULL(SUM(e.ESA_FTE_0_25_BU), 0)    
  ,ISNULL(SUM(D.ESA_FTE_25_50_BU), 0)    
  ,ISNULL(SUM(C.ESA_FTE_50_80_BU), 0)    
  ,ISNULL(SUM(b.ESA_FTE_80_BU), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
  ,ISNULL(SUM(MPS_Effort), 0)    
  ,ISNULL(SUM(Work_Profile_AD), 0)    
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_VERTICALcompliance_AVM A    
 LEFT JOIN #Associate_0_VERTICAL F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_VERTICAL E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_VERTICAL D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_VERTICAL C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_VERTICAL B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
     
 GROUP BY a.SBU  ,A.VERTICAL  
    
    
SELECT DISTINCT SBU,VERTICAL,ESA_FTE,ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,Available_Hours,    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,    
VERTICAL_Effort_Compliance_Percent,    
Associate_Compliance_Percent    
INTO #VERTICALDATA_AVM    
FROM #VERTICAL_Compliance_AVM    
--order by sbu  
    
  
    
INSERT INTO #VERTICAL_Compliance_AVM    
    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]  ,''  
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE)) AS 'ESA_FTE'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_Zero)) AS 'ESA FTE with TSC %=0'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_0_25)) AS 'ESA FTE with TSC %>0 to 25'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_25_50)) AS 'ESA FTE with TSC %>25 to 50'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_50_80)) AS 'ESA FTE with TSC %>50 to 80'    
  ,SUM(CONVERT(DECIMAL(10,2), ESA_FTE_80)) AS 'ESA FTE with TSC %>80'    
  ,SUM(CONVERT(DECIMAL(10,2), Available_Hours)) AS 'Available_Hours'    
  ,SUM(CONVERT(DECIMAL(10,2), MPS_Effort)) AS 'MPS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS 'Work_Profile_AD'    
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)) * 100, 0),0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)) * 100, 0),0) AS 'Associate_Compliance'    
    
FROM #VERTICALDATA_AVM  --group by vertical  
  
 TRUNCATE table [Adp].VERTICAL_Compliance_AVM    
    
INSERT INTO [Adp].VERTICAL_Compliance_AVM  
    
SELECT    
 [SBU] AS 'SBU'  ,VERTICAL  
 ,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,VERTICAL_Effort_Compliance_Percent AS [VERTICAL Effort Compliance%(All)]    
 ,Associate_Compliance_Percent AS [Associate_BU_Compliance%]    
FROM #VERTICAL_Compliance_AVM    
ORDER BY CASE    
 WHEN SBU = 'GRAND TOTAL' THEN 1    
    
 ELSE 0    
END, [SBU]    
    
    
   
TRUNCATE table [Adp].Project_Compliance_AVM    
    
INSERT INTO [Adp].Project_Compliance_AVM    
    
    
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
    
    
DROP TABLE #WeekDays    
DROP TABLE #Temp_Applens    
DROP TABLE #Temp_BM_Applns    
DROP TABLE #Associalte_Final_AVM    
DROP TABLE #Allocatedassoc    
DROP TABLE #TEMPR    
DROP TABLE #LoginAssociate    
DROP TABLE #Tempfin    
DROP TABLE #Loginmaster_associate    
DROP TABLE #MPS_Effort    
DROP TABLE #MAS_Effort    
DROP TABLE #Total_Effort    
DROP TABLE #Associate_FTE_Hours    
DROP TABLE #Associate_Summary    
DROP TABLE #department    
DROP TABLE #designation    
DROP TABLE #AssociateActual_Final_AVM    
DROP TABLE #Associate_Projectcompliance_avm   
DROP TABLE #Associate_Total_project_Compliance_avm   
DROP TABLE #Associate_Greater80_Prj_avm  
DROP TABLE #Associate_Greater_50_80_Prj_avm  
DROP TABLE #Associate_Greater_25_50_prj_avm  
DROP TABLE #Associate_Greater_0_25_prj_avm  
DROP TABLE #Associate_Greater_Zero_prj_avm    
DROP TABLE #Associate_zero_prj_avm  
DROP TABLE #Associate_0_25_prj_avm   
DROP TABLE #Associate_25_50_prj_avm   
DROP TABLE #Associate_50_80_Prj_avm  
DROP TABLE #Associate_80_Prj_avm   
DROP TABLE #Project_Compliance_AVM    
DROP TABLE #Associate_Accountcompliance    
DROP TABLE #Associate_Total_account_Compliance    
DROP TABLE #Associate_Greater80    
DROP TABLE #Associate_Greater_50_80    
DROP TABLE #Associate_Greater_25_50    
DROP TABLE #Associate_Greater_Zero    
DROP TABLE #Associate_zero    
DROP TABLE #Associate_0_25    
DROP TABLE #Associate_25_50    
DROP TABLE #Associate_50_80    
DROP TABLE #Associate_80    
DROP TABLE #Account_Compliance_AVM    
DROP TABLE #Associate_BUcompliance_AVM    
DROP TABLE #Associate_Greater80_SBU    
DROP TABLE #Associate_Greater_50_80_SBU    
DROP TABLE #Associate_Greater_0_25_SBU    
DROP TABLE #Associate_Greater_zero_SBU    
DROP TABLE #Associate_80_SBU    
DROP TABLE #Associate_50_80_SBU    
DROP TABLE #Associate_25_50_SBU    
DROP TABLE #Associate_0_25_SBU    
DROP TABLE #Associate_0_SBU    
DROP TABLE #SBU_Compliance_AVM    
DROP TABLE #BUDATA   
DROP TABLE #MPS_Effort_App   
DROP TABLE #MPS_Effort_Infra   
DROP TABLE #MPS_Effort_Workitem  
DROP TABLE #AssociateSummarytmp   
DROP TABLE #ScopeProject_tmp  
DROP TABLE #YETTOSCOPE_ADM  
DROP TABLE #ScopeProject  
DROP TABLE #Associate_Greater80_AM   
DROP TABLE #Associate_Greater_50_80_AM   
DROP TABLE #Associate_Greater_25_50_AM   
DROP TABLE #Associate_Greater_0_25_AM   
DROP TABLE #Associate_Greater_Zero_AM   
DROP TABLE #Associate_zero_AM   
DROP TABLE #Associate_0_25_AM   
DROP TABLE #Associate_25_50_AM   
DROP TABLE #Associate_50_80_AM    
DROP TABLE #Associate_80_AM   
DROP TABLE #Account_Compliance_AVM_AM   
DROP TABLE #Associate_Greater80_AD   
DROP TABLE #Associate_Greater_50_80_AD   
DROP TABLE #Associate_Greater_25_50_AD  
DROP TABLE #Associate_Greater_0_25_AD   
DROP TABLE #Associate_Greater_Zero_AD  
DROP TABLE #Associate_zero_AD   
DROP TABLE #Associate_0_25_AD  
DROP TABLE #Associate_25_50_AD   
DROP TABLE #Associate_50_80_AD   
DROP TABLE #Associate_80_AD   
DROP TABLE #Account_Compliance_AVM_AD   
DROP TABLE #Associate_Greater80_INTEG   
DROP TABLE #Associate_Greater_50_80_INTEG    
DROP TABLE #Associate_Greater_25_50_INTEG    
DROP TABLE #Associate_Greater_0_25_INTEG   
DROP TABLE #Associate_Greater_Zero_INTEG   
DROP TABLE #Associate_zero_INTEG   
DROP TABLE #Associate_0_25_INTEG   
DROP TABLE #Associate_25_50_INTEG   
DROP TABLE #Associate_50_80_INTEG   
DROP TABLE #Associate_80_INTEG   
DROP TABLE #Account_Compliance_AVM_INTEG   
DROP TABLE #Associate_Accountcompliance_all   
DROP TABLE #Associate_Total_account_Compliance_all    
DROP TABLE #Associate_Greater_0_25    
DROP TABLE #ScopeBU  
DROP TABLE #Associate_Greater80_SBU_AM   
DROP TABLE #Associate_Greater_50_80_SBU_AM   
DROP TABLE #Associate_Greater_25_50_SBU_AM   
DROP TABLE #Associate_Greater_0_25_SBU_AM    
DROP TABLE #Associate_Greater_zero_SBU_AM   
DROP TABLE #Associate_80_SBU_AM    
DROP TABLE #Associate_50_80_SBU_AM   
DROP TABLE #Associate_25_50_SBU_AM    
DROP TABLE #Associate_0_25_SBU_AM   
DROP TABLE #Associate_0_SBU_AM   
DROP TABLE #SBU_Compliance_AVM_AM   
DROP TABLE #BUDATA_AM  
DROP TABLE #Associate_Greater80_SBU_AD   
DROP TABLE #Associate_Greater_50_80_SBU_AD   
DROP TABLE #Associate_Greater_25_50_SBU_AD    
DROP TABLE #Associate_Greater_0_25_SBU_AD   
DROP TABLE #Associate_Greater_zero_SBU_AD    
DROP TABLE #Associate_80_SBU_AD   
DROP TABLE #Associate_50_80_SBU_AD   
DROP TABLE #Associate_25_50_SBU_AD   
DROP TABLE #Associate_0_25_SBU_AD    
DROP TABLE #Associate_0_SBU_AD   
DROP TABLE #SBU_Compliance_AVM_AD    
DROP TABLE #Associate_Greater80_SBU_INTEG   
DROP TABLE #Associate_Greater_50_80_SBU_INTEG    
DROP TABLE #Associate_Greater_25_50_SBU_INTEG   
DROP TABLE #Associate_Greater_0_25_SBU_INTEG   
DROP TABLE #Associate_Greater_zero_SBU_INTEG    
DROP TABLE #Associate_80_SBU_INTEG    
DROP TABLE #Associate_50_80_SBU_INTEG    
DROP TABLE #Associate_25_50_SBU_INTEG    
DROP TABLE #Associate_0_25_SBU_INTEG    
DROP TABLE #Associate_0_SBU_INTEG    
DROP TABLE #SBU_Compliance_AVM_INTEG    
DROP TABLE #BUDATA_INTEG   
DROP TABLE #Associate_Greater_25_50_SBU    
DROP TABLE #Associate_VERTICALcompliance_AVM    
DROP TABLE #Associate_Greater80_VERTICAL_AD    
DROP TABLE #Associate_Greater_50_80_VERTICAL_AD   
DROP TABLE #Associate_Greater_25_50_VERTICAL_AD   
DROP TABLE #Associate_Greater_0_25_VERTICAL_AD   
DROP TABLE #Associate_Greater_zero_VERTICAL_AD   
DROP TABLE #Associate_80_VERTICAL_AD   
DROP TABLE #Associate_50_80_VERTICAL_AD   
DROP TABLE #Associate_25_50_VERTICAL_AD    
DROP TABLE #Associate_0_25_VERTICAL_AD  
DROP TABLE #Associate_0_VERTICAL_AD   
DROP TABLE #VERTICAL_Compliance_AVM_AD    
DROP TABLE #Associate_Greater80_VERTICAL_AM    
DROP TABLE #Associate_Greater_50_80_VERTICAL_AM   
DROP TABLE #Associate_Greater_25_50_VERTICAL_AM   
DROP TABLE #Associate_Greater_0_25_VERTICAL_AM    
DROP TABLE #Associate_Greater_zero_VERTICAL_AM   
DROP TABLE #Associate_80_VERTICAL_AM   
DROP TABLE #Associate_50_80_VERTICAL_AM   
DROP TABLE #Associate_25_50_VERTICAL_AM   
DROP TABLE #Associate_0_25_VERTICAL_AM  
DROP TABLE #Associate_0_VERTICAL_AM   
DROP TABLE #VERTICAL_Compliance_AVM_AM    
DROP TABLE #Associate_Greater80_VERTICAL_INTEG   
DROP TABLE #Associate_Greater_50_80_VERTICAL_INTEG   
DROP TABLE #Associate_Greater_25_50_VERTICAL_INTEG   
DROP TABLE #Associate_Greater_0_25_VERTICAL_INTEG   
DROP TABLE #Associate_Greater_zero_VERTICAL_INTEG   
DROP TABLE #Associate_80_VERTICAL_INTEG   
DROP TABLE #Associate_50_80_VERTICAL_INTEG   
DROP TABLE #Associate_25_50_VERTICAL_INTEG    
DROP TABLE #Associate_0_25_VERTICAL_INTEG  
DROP TABLE #Associate_0_VERTICAL_INTEG   
DROP TABLE #VERTICAL_Compliance_AVM_INTEG    
DROP TABLE #Associate_Greater80_VERTICAL    
DROP TABLE #Associate_Greater_50_80_VERTICAL   
DROP TABLE #Associate_Greater_25_50_VERTICAL   
DROP TABLE #Associate_Greater_0_25_VERTICAL    
DROP TABLE #Associate_Greater_zero_VERTICAL   
DROP TABLE #Associate_80_VERTICAL   
DROP TABLE #Associate_50_80_VERTICAL   
DROP TABLE #Associate_25_50_VERTICAL    
DROP TABLE #Associate_0_25_VERTICAL  
DROP TABLE #Associate_0_VERTICAL   
DROP TABLE #VERTICAL_Compliance_AVM    
DROP TABLE #VERTICALDATA_AVM   
  
END TRY    
  BEGIN CATCH    
 DECLARE @ErrorMessage VARCHAR(8000);    
 SELECT @ErrorMessage = ERROR_MESSAGE()    
  --INSERT Error        
  EXEC [AppVisionLens].dbo.AVL_InsertError '[Adp].[CDB_AssociateData_Monthly]', @ErrorMessage, '',''    
  RETURN @ErrorMessage    
  END CATCH       
    
END 
