CREATE   PROCEDURE [ADP].[AssociateData_Weekly]  
  
As  
  
--all asso  
  
  
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
  
DECLARE @IndiaHours INT = 9;  
  
Declare @NonIndiaHours INT =8;  
    
    
    
SET @DatepartToday = DATEPART(dd, GETDATE())    
     
    
  
    
IF(@DatepartToday != 3)    
    
    
BEGIN    
    
SELECT  @FirstDay =  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE() - 2), 0)  
,@LastDate = GETDATE() - 2      
    
SELECT @StartDate = (SELECT @FirstDay), @EndDate = (SELECT @LastDate)    
    
    
END ELSE BEGIN    
    
    
SELECT @FirstDay = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE() - 3), 0),  @LastDate = GETDATE() - 3    
    
    
      
SELECT @StartDate = (SELECT @FirstDay),@EndDate = (SELECT @LastDate)    
    
    
END    
    
     
    
    
CREATE TABLE #WeekDays    
    
    
(    
    
    
DateList DATE,    
    
    
DayWeek VARCHAR(15)    
    
    
)    
    
    
DECLARE @Datepart1 INT    
    
    
SELECT @Datepart1 = DATEPART(dd, @FirstDay)    
     
    
    
DECLARE @Datepart2 INT    
    
    
SELECT @Datepart2 = DATEPART(dd, @LastDate)    
     
   
    
    
DECLARE @DATE DATE    
    
    
SELECT @DATE = @FirstDay    
    
    
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
    
  
    
SELECT  @WorkdAYS = (SELECT COUNT(1) AS WorkDays FROM #WeekDays)    
    
    
SELECT @WorkHours = (SELECT (COUNT(1) * 8) AS WorkHours FROM #WeekDays)    
    
    
  
    
SELECT @MASCOUNT = CONVERT(DECIMAL(10, 2), (22 / CONVERT(DECIMAL(10, 2), @WorkdAYS)))    
    
  
    
SELECT    
 CONVERT(VARCHAR, CONVERT(DATE, @StartDate), 9)    
    
SELECT    
 CONVERT(VARCHAR, CONVERT(DATE, @Enddate), 9)    
    
    
     
    
CREATE table #Associate_Applens    
    
    
(    
    
Id int not null identity(1,1),    
    
Project_ID Char(15) Not Null,    
    
Associate_id  varchar(10),    
    
App_User_id varchar(10),    
    
ISNonESAAuthorized varchar(10),    
    
)    
    
INSERT INTO #Associate_Applens    
    
    
 SELECT DISTINCT    
  T.EsaProjectID    
  ,GA.EmployeeID    
  ,ga.UserID    
  ,ga.IsNonESAAuthorized    
 FROM [Adp].[Input_Data_AssociateRAW] T    
    
    
 LEFT JOIN [AppVisionLens].esa.Projects GP    
  ON CONVERT(VARCHAR, GP.ID) = T.EsaProjectID    
    
 JOIN [AppVisionLens].AVL.MAS_ProjectMaster PM    
  ON CONVERT(VARCHAR, GP.ID) = PM.EsaProjectID    
    
    
 LEFT OUTER JOIN [AppVisionLens].AVL.MAS_LoginMaster GA    
  ON PM.ProjectID = GA.ProjectID    
    
 WHERE GA.IsDeleted = '0'    
     
--Allocation Issue Fix  
  
IF OBJECT_ID(N'tempdb..#CentralRepository_LatestAllocation') IS NOT NULL    
BEGIN DROP TABLE #CentralRepository_LatestAllocation END    
  
CREATE TABLE #CentralRepository_LatestAllocation(  
 [Associate_ID] [char](11) NULL,  
 [Project_ID] [char](15) NULL,  
 [Allocation_Start_Date] [datetime] NULL,  
 [Allocation_End_Date] [datetime] NULL,  
 [Allocation_Percentage] [decimal](5, 2) NULL,  
 [Location] [char](10) NULL,  
 [LastUpdatedDateTime] [varchar](60) NULL,  
 [Createddate] [datetime] NULL,  
 [Created by] [varchar](20) NULL  
);  
  
WITH LatestAllocationData AS (  
SELECT Associate_ID, Project_ID, Allocation_Start_Date, Allocation_End_Date,Allocation_Percentage, Location, LastUpdatedDateTime, Createddate, [Created by],   
ROW_NUMBER() OVER (PARTITION BY Associate_ID,Project_ID ORDER BY Allocation_End_Date DESC) AS R  
FROM [Adp].[CentralRepository_Allocation] WHERE Allocation_Start_Date<=@EndDate AND Allocation_End_Date>@EndDate)  
  
  
INSERT INTO #CentralRepository_LatestAllocation (Associate_ID, Project_ID, Allocation_Start_Date, Allocation_End_Date, Allocation_Percentage,   
Location, LastUpdatedDateTime, Createddate, [Created by])  
SELECT Associate_ID, Project_ID, Allocation_Start_Date, Allocation_End_Date, Allocation_Percentage,   
Location, LastUpdatedDateTime, Createddate, [Created by] FROM LatestAllocationData WHERE R=1   
    
    
    
CREATE table #FTE_GRT    
    
    
(    
    
Id int not null identity(1,1),    
    
Project_ID Char(15) Not Null,    
    
Associate_id  varchar(10),    
    
Allocation_Startdate datetime,    
    
Allocation_enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
    
FTE_Location nvarchar(20)    
    
)    
    
    
    
INSERT INTO #FTE_GRT    
    
    
  SELECT  DISTINCT  
  T.EsaProjectID    
  ,GA.Associate_ID ,   
  GA.[Allocation_Start_Date],  
GA.[Allocation_End_Date],  
GA.[Allocation_Percentage],GA.Location   
 FROM [Adp].[Input_Data_AssociateRAW]  T    
    
 LEFT JOIN [AppVisionLens].esa.Projects GP    
  ON CONVERT(VARCHAR, GP.ID) = T.EsaProjectID    
    
 --LEFT OUTER JOIN CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_ActiveAllocations GA    
 -- ON CONVERT(VARCHAR, GP.ID) = GA.Project_ID    
  
 --LEFT OUTER JOIN [Adp].[CentralRepository_ActiveAllocations] GA    
  LEFT OUTER JOIN #CentralRepository_LatestAllocation GA    
  
 ON CONVERT(VARCHAR, GP.ID) = GA.[Project_ID]   
  
      
 WHERE ga.[Allocation_Start_Date] between  @startdate and @enddate    
    
   
    
    
BEGIN    
    
select DISTINCT HOLIDAY,LOCATION,DATENAME(dw, HOLIDAY) As 'DAY_NAME' INTO #HOLIDAYLIST from     
--CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_HolidayDate WHERE YEAR(HOLIDAY) between YEAR(@startdate) AND YEAR(@EndDate)    
[ADP].[CentralRepository_HolidayDate] WHERE YEAR(HOLIDAY) between YEAR(@startdate) AND YEAR(@EndDate)    
    
and MONTH(holiday) between month(@startdate) AND MONTH(@EndDate) and holiday <=@EndDate    
    
DELETE FROM  #HOLIDAYLIST  WHERE DAY_NAME  IN ('Saturday', 'Sunday')    
    
END    
    
  
CREATE TABLE #Associate_WeekDays    
    
(    
    
DateList DATE,    
    
DayWeek VARCHAR(100)    
    
)    
    
CREATE table #Associate_days    
    
(    
    
    
Project_id Char(15) Not Null,    
    
Associate_id varchar(20),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
    
FTE_Location nvarchar(20),    
    
Workdays  int,    
Holidays int    
    
)    
    
    
DECLARE @id_first int    
    
DECLARE @id_last int    
    
DECLARE @id_first_Date date    
    
DECLARE @id_Last_date date    
    
DECLARE @As_Datepart1 INT    
    
DECLARE @As_Datepart2 INT    
    
DECLARE @As_Datepart3 INT    
    
DECLARE @AL_Date date    
    
DECLARE @AssociateId varchar(10)    
    
DECLARE @FTE_Location nvarchar(20)    
    
      
DECLARE @Project_id Char(15)    
     
    
DECLARE @Allocation_startdate datetime    
    
DECLARE @Allocation_enddate datetime    
    
DECLARE @allocation_Percentage_grt  decimal(10,4)    
    
SET @id_first = (SELECT MIN(id) FROM #FTE_GRT)    
SET @id_last = (SELECT MAX(id) FROM #FTE_GRT)    
    
    
  
    
WHILE(@id_last>=@id_first)    
    
Begin    
    
    
SET @id_first_Date = (SELECT Allocation_Startdate  FROM #FTE_GRT WHERE Id = @id_first)    
SET @id_Last_date = (SELECT Allocation_enddate FROM #FTE_GRT WHERE Id = @id_first)    
SET @AL_Date = @id_first_Date    
SET @AssociateId = (SELECT Associate_id FROM #FTE_GRT WHERE Id = @id_first)    
SET @Project_id = (SELECT Project_ID FROM #FTE_GRT WHERE Id = @id_first AND Associate_id = @AssociateId)    
SET @Allocation_startdate = (SELECT Allocation_Startdate FROM #FTE_GRT WHERE Id = @id_first AND Associate_id = @AssociateId)    
SET @Allocation_enddate = (SELECT  Allocation_enddate FROM #FTE_GRT WHERE Id = @id_first AND Associate_id = @AssociateId)    
SET @allocation_Percentage_grt = (SELECT  Allocation_Percentage FROM #FTE_GRT WHERE Id = @id_first AND Associate_id = @AssociateId)    
set @FTE_Location =   (SELECT  FTE_Location FROM #FTE_GRT WHERE Id = @id_first AND Associate_id = @AssociateId)    
SET @As_Datepart1 = DATEPART(dd, @id_first_Date)    
SET  @As_Datepart2 = DATEPART(dd, @EndDate)    
    
WHILE (@As_Datepart2 >= @As_Datepart1) BEGIN    
    
    
INSERT INTO #Associate_WeekDays    
    
 SELECT @AL_Date ,DATENAME(dw, @AL_Date)    
     
SET @AL_DATE = DATEADD(DAY, 1, @AL_DATE)    
    
SET @As_Datepart1 = @As_Datepart1 + 1    
    
    
END    
    
    
DELETE FROM #Associate_WeekDays WHERE DayWeek IN ('Saturday', 'Sunday')    
    
    
INSERT INTO #Associate_days    
    
    
 SELECT    
  @Project_id    
  ,@AssociateId    
  ,@Allocation_startdate    
  ,@Allocation_enddate    
  ,@allocation_Percentage_grt    
  ,@FTE_Location    
  ,(SELECT    
    COUNT(1)    
   FROM #Associate_WeekDays)    
,(SELECT count(holiday) As 'Holidays'     
from  #HOLIDAYLIST where Location=@FTE_Location  and holiday BETWEEN @Allocation_startdate AND  @Allocation_enddate)    
    
SET @id_first = @id_first + 1    
    
    
TRUNCATE TABLE #Associate_WeekDays    
    
    
END    
    
  
    
CREATE table #Associate_diff    
    
(    
    
    
Project_id Char(15) Not Null,    
    
Associate_id varchar(20),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
  
FTE_Location nvarchar(20)  ,  
    
Workdays_diff int,    
    
Workdays_Loc   int    
    
)    
    
Insert into #Associate_diff    
    
select DISTINCT Project_id , Associate_id, Allocation_Startdate,Allocation_Enddate,Allocation_Percentage,FTE_Location,Workdays, Isnull(Workdays-Holidays,0)  from #Associate_days    
    
  
    
CREATE table #FTE_Cal_A    
    
    
(     
    
    
Project_ID Char(15) Not Null,    
    
Associate_id  varchar(10),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
  
FTE_Location nvarchar(20)  ,  
  
FTE_City nvarchar(40)  ,  
  
FTE_Country nvarchar(40)  ,  
  
Days_different numeric,    
    
FTE_Percentage decimal(10,4),    
    
ESA_FTE_Count Decimal(10,4),    
    
)    
    
    
INSERT INTO #FTE_Cal_A    
    
    
 SELECT  DISTINCT  
  a.Project_id    
  ,a.Associate_id    
  ,B.Allocation_Startdate    
  ,b.Allocation_enddate    
  ,B.Allocation_Percentage   
  ,a.FTE_Location,Ltrim(Rtrim(LC.City)) as 'City',Ltrim(Rtrim(LC.country)) as country--,ac.Offshore_Onsite  
  ,sum(a.Workdays_diff )   
  ,ISNULL(SUM((A.Workdays_diff / (CONVERT(DECIMAL(5, 2), @WorkdAYS))) * B.Allocation_Percentage), 0) AS FTE_Percentage    
  ,ISNULL(SUM((A.Workdays_diff / CONVERT(DECIMAL(5, 2), @WorkdAYS)) * B.Allocation_Percentage) / 100, 0) AS ESA_FTE_Count    
  
 FROM #Associate_diff A    
    
 LEFT JOIN #FTE_GRT B    
  ON a.Associate_id = b.Associate_id    
  AND a.Project_id = b.Project_ID  and a.Allocation_Startdate =b.Allocation_Startdate   
  and a.Allocation_enddate =b.Allocation_enddate  
  and a.Allocation_Percentage  =b.Allocation_Percentage    
  
  left join [AppVisionLens].esa.locationmaster LC on A.FTE_Location=LC.Assignment_Location  
  --left join esa.associates Ac on A.Associate_id=Ac.associateid  
  
 GROUP BY a.Project_id    
    ,a.Associate_id    
    ,B.Allocation_Startdate    
    ,b.Allocation_enddate    
    ,B.Allocation_Percentage  ,a.FTE_Location,LC.City,LC.country--,ac.Offshore_Onsite  
    ,a.Workdays_diff    
  
    
  
  
CREATE table #FTE_Cal    
    
    
(     
    
    
Project_ID Char(15) Not Null,    
    
Associate_id  varchar(10),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
  
FTE_Location nvarchar(20)  ,  
  
FTE_City nvarchar(40)  ,  
  
FTE_Country nvarchar(40)  ,  
  
Days_different numeric,    
    
FTE_Percentage decimal(10,4),    
    
ESA_FTE_Count Decimal(10,4),    
    
Available_Hours  Decimal(10,2)    
    
)    
  
   insert into #FTE_Cal    
 SELECT  DISTINCT  
  a.Project_id    
  ,a.Associate_id    
  ,B.Allocation_Startdate    
  ,b.Allocation_enddate    
  ,B.Allocation_Percentage , A.FTE_Location,A.FTE_City,A.FTE_Country  
  ,a.Days_different    
  ,A.FTE_Percentage    
  ,A.ESA_FTE_Count    
   ,CASE WHEN isnull(MHC.Mandatory_Hours,0)=0  
  THEN  
  ISNULL(SUM(B.Workdays_Loc * B.Allocation_Percentage * @IndiaHours)/100 , 0)   
  ELSE  
   ISNULL(SUM(B.Workdays_Loc * B.Allocation_Percentage * MHC.Mandatory_Hours)/100 , 0)   
   END As Available_Hours  
 FROM #FTE_Cal_A A     
 join #Associate_diff B  ON A.associate_id = b.Associate_id    
   AND a.Project_id = b.Project_ID   and A.Allocation_Startdate=B.Allocation_Startdate and A.Allocation_Enddate=B.Allocation_Enddate  
  and A.Allocation_Percentage=B.Allocation_Percentage  
  left join [ADP].[MandatoryHoursConfig] MHC on MHC.EsaProjectID=A.Project_ID  and MHC.Isdeleted=0  
  where A.FTE_Country='IND' and A.FTE_city not in ('Kolkata','Noida')   
 GROUP BY a.Project_id    
    ,a.Associate_id    
    ,B.Allocation_Startdate    
    ,b.Allocation_enddate    
    ,B.Allocation_Percentage  ,A.FTE_Location,A.FTE_City,A.FTE_Country  
    ,a.Days_different    
,A.FTE_Percentage    
  ,A.ESA_FTE_Count   
,MHC.Mandatory_Hours  
  
--Non India  
  
insert into #FTE_Cal    
 SELECT  DISTINCT  
  a.Project_id    
  ,a.Associate_id    
  ,B.Allocation_Startdate    
  ,b.Allocation_enddate    
  ,B.Allocation_Percentage , A.FTE_Location,A.FTE_City,A.FTE_Country  
  ,a.Days_different    
  ,A.FTE_Percentage    
  ,A.ESA_FTE_Count    
  --,0 as Available_Hours   
   ,CASE WHEN isnull(MHC.Mandatory_Hours,0)=0  
  THEN  
  ISNULL(SUM(B.Workdays_Loc * B.Allocation_Percentage * @NonIndiaHours)/100 , 0)   
  ELSE  
   ISNULL(SUM(B.Workdays_Loc * B.Allocation_Percentage * MHC.Mandatory_Hours)/100 , 0)   
   END As Available_Hours   
 FROM #FTE_Cal_A A     
 join #Associate_diff B  ON A.associate_id = b.Associate_id    
   AND a.Project_id = b.Project_ID   and A.Allocation_Startdate=B.Allocation_Startdate and A.Allocation_Enddate=B.Allocation_Enddate  
  and A.Allocation_Percentage=B.Allocation_Percentage  
 -- left join esa.locationmaster LO on A.FTE_Location=LO.assignment_location  
 left join [ADP].[MandatoryHoursConfig] MHC on MHC.EsaProjectID=A.Project_ID  and MHC.Isdeleted=0  
 where A.FTE_country<>'IND' or A.FTE_city  in ('Kolkata','Noida') or A.FTE_country is null  
 GROUP BY a.Project_id    
    ,a.Associate_id    
    ,B.Allocation_Startdate    
    ,b.Allocation_enddate    
    ,B.Allocation_Percentage  ,A.FTE_Location,A.FTE_City,A.FTE_Country  
    ,a.Days_different    
,A.FTE_Percentage    
  ,A.ESA_FTE_Count   
,MHC.Mandatory_Hours  
  
  
 CREATE table #FTE_Final    
    
    
    
(    
    
    
Project_ID Char(15) Not Null,    
    
associate_id char(15),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
    
ESA_FTE_Count Decimal(10,4),    
    
Available_Hours  Decimal(10,2)     
)    
    
    
    
INSERT INTO #FTE_Final    
    
    
 SELECT  DISTINCT  
  A.Project_ID    
  ,A.Associate_id    
  ,A.Allocation_Startdate    
  ,A.Allocation_Enddate    
  ,A.Allocation_Percentage    
  ,sum(A.ESA_FTE_Count) AS ESA_FTE_Count, sum(A.Available_Hours)   
 FROM #FTE_Cal A    
  
  
 GROUP BY a.Project_ID    
    ,A.Associate_id    
    ,A.Allocation_Startdate    
    ,A.Allocation_Enddate    
    ,A.Allocation_Percentage    
    
    
    
CREATE table #FTE_count_Loc    
    
(    
    
Project_ID Char(15) Not Null,    
    
associate_id char(15),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
     
Workdays numeric,    
    
FTE_LOCATION_CUR nvarchar(20),    
    
HOLIDAY numeric,    
    
Diff numeric     
    
)    
    
    
    
INSERT INTO #FTE_count_Loc    
    
    
 SELECT DISTINCT    
  T.EsaProjectID  ,  
  GA.[Associate_ID]  ,  
GA.[Allocation_Start_Date],  
GA.[Allocation_End_Date],  
GA.[Allocation_Percentage],  
  @WorkdAYS    
  ,ga.LOCATION    
  ,Count(holiday)    
  ,ISNULL((@WorkdAYS-Count(holiday)), 0)    
  FROM [Adp].[Input_Data_AssociateRAW] T    
    
    
 LEFT JOIN [AppVisionLens].esa.Projects GP    
  ON CONVERT(VARCHAR, GP.ID) = T.EsaProjectID    
    
 --LEFT OUTER JOIN CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_ActiveAllocations GA    
 -- ON T.EsaProjectID = GA.Project_ID    
  
 --LEFT OUTER JOIN [Adp].[CentralRepository_ActiveAllocations] GA    
  LEFT OUTER JOIN #CentralRepository_LatestAllocation GA    
  
  ON T.EsaProjectID = GA.Project_ID   
  
   
LEFT join #HOLIDAYLIST HL on GA.Location = HL.Location and holiday between @StartDate and @EndDate    
    
 WHERE ga.[Allocation_Start_Date] < @StartDate     
 GROUP BY T.EsaProjectID ,GA.[Associate_ID]  ,  
GA.[Allocation_Start_Date],  
GA.[Allocation_End_Date],  
GA.[Allocation_Percentage],  
    GA.location    
    
  
    
CREATE table #FTE_count_Cal_A   
    
(    
    
Project_ID Char(15) Not Null,    
    
associate_id char(15),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
  
FTE_Location nvarchar(20)  ,  
  
FTE_City nvarchar(40)  ,  
  
FTE_Country nvarchar(40)  ,  
    
FTE_Percentage Decimal(10,4),    
     
ESA_FTE_Count Decimal(10,4),    
    
    
)    
    
Insert into  #FTE_count_Cal_A   
    
SELECT DISTINCT Project_ID,associate_id ,Allocation_Startdate ,    
    
Allocation_Enddate ,Allocation_Percentage ,A.FTE_LOCATION_CUR,Ltrim(Rtrim(LC.City)) as 'City',Ltrim(Rtrim(LC.country)) as country,  
  
ISNULL(SUM(Workdays / (CONVERT(DECIMAL(5, 2), @WorkdAYS)) * Allocation_Percentage), 0) AS FTE_Percentage,    
    
ISNULL(SUM((Workdays / CONVERT(DECIMAL(5, 2),@WorkdAYS)) * Allocation_Percentage) / 100, 0) AS ESA_FTE_Count   
    
  FROM  #FTE_count_Loc  A  
  
left join [AppVisionLens].esa.locationmaster LC on A.FTE_LOCATION_CUR=LC.Assignment_Location  
  
    
group by Project_ID,associate_id ,Allocation_Startdate ,Allocation_Enddate ,Allocation_Percentage ,A.FTE_LOCATION_CUR,LC.City,LC.country,  
Workdays ,Diff     
  
--drop  table #FTE_count_Cal_A   
  
CREATE table #FTE_count_Cal   
    
(    
    
Project_ID Char(15) Not Null,    
    
associate_id char(15),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
    
FTE_Location nvarchar(20)  ,  
  
FTE_City nvarchar(40)  ,  
  
FTE_Country nvarchar(40) ,  
  
FTE_Percentage Decimal(10,4),    
     
ESA_FTE_Count Decimal(10,4),   
  
Available_Hours decimal(10,2)  
    
    
)    
    
Insert into  #FTE_count_Cal  
    
SELECT DISTINCT A.Project_ID,A.associate_id ,A.Allocation_Startdate ,    
    
A.Allocation_Enddate ,A.Allocation_Percentage , A.FTE_Location,A.FTE_City,A.FTE_Country,A.FTE_Percentage,  A.ESA_FTE_Count,   
    
CASE WHEN isnull(MHC.Mandatory_Hours,0)=0  
  THEN  
  ISNULL(SUM(B.Diff * B.Allocation_Percentage * @IndiaHours)/100 , 0)   
  ELSE  
   ISNULL(SUM(B.Diff * B.Allocation_Percentage * MHC.Mandatory_Hours)/100 , 0)      
   END As Available_Hours  
  
FROM  #FTE_count_Cal_A A   
  
left join #FTE_count_Loc  B on A.associate_id=B.associate_id and A.Project_ID=B.Project_ID and A.Allocation_Startdate=B.Allocation_Startdate and A.Allocation_Enddate=B.Allocation_Enddate  
  and A.Allocation_Percentage=B.Allocation_Percentage  
left join [ADP].[MandatoryHoursConfig] MHC on MHC.EsaProjectID=A.Project_ID  and MHC.Isdeleted=0  
 where A.FTE_Country='IND' and A.FTE_city not in ('Kolkata','Noida')   
  
  group by  A.Project_ID,A.associate_id ,A.Allocation_Startdate ,    
    
A.Allocation_Enddate ,A.Allocation_Percentage , A.FTE_Percentage, A.FTE_Location,A.FTE_City,A.FTE_Country, A.ESA_FTE_Count,MHC.Mandatory_Hours  
  
  
--non india  
  
  
Insert into  #FTE_count_Cal  
    
SELECT DISTINCT A.Project_ID,A.associate_id ,A.Allocation_Startdate ,    
    
A.Allocation_Enddate ,A.Allocation_Percentage , A.FTE_Location,A.FTE_City,A.FTE_Country,A.FTE_Percentage,  A.ESA_FTE_Count,   
    
CASE WHEN isnull(MHC.Mandatory_Hours,0)=0  
  THEN  
  ISNULL(SUM(B.Diff * B.Allocation_Percentage * @NonIndiaHours)/100 , 0)   
  ELSE  
   ISNULL(SUM(B.Diff * B.Allocation_Percentage * MHC.Mandatory_Hours)/100 , 0)   
   END As Available_Hours   
  
FROM  #FTE_count_Cal_A A   
  
left join #FTE_count_Loc  B on A.associate_id=B.associate_id and A.Project_ID=B.Project_ID and A.Allocation_Startdate=B.Allocation_Startdate and A.Allocation_Enddate=B.Allocation_Enddate  
  and A.Allocation_Percentage=B.Allocation_Percentage  
left join [ADP].[MandatoryHoursConfig] MHC on MHC.EsaProjectID=A.Project_ID  and MHC.Isdeleted=0  
 where A.FTE_country <> 'IND' or A.FTE_city  in ('Kolkata','Noida') or A.FTE_country is null  
  
  group by  A.Project_ID,A.associate_id ,A.Allocation_Startdate ,    
    
A.Allocation_Enddate ,A.Allocation_Percentage , A.FTE_Percentage, A.FTE_Location,A.FTE_City,A.FTE_Country, A.ESA_FTE_Count,MHC.Mandatory_Hours  
  
    
    
CREATE table #FTE_count    
    
(    
    
Project_ID Char(15) Not Null,    
    
associate_id char(15),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
    
ESA_FTE_Count Decimal(10,4),    
    
Available_Hours  Decimal(10,2)    
    
)    
    
Insert into  #FTE_count    
    
    
SELECT DISTINCT Project_ID,associate_id ,Allocation_Startdate ,Allocation_Enddate ,Allocation_Percentage,sum(ESA_FTE_Count), sum(Available_Hours) from #FTE_count_Cal  group by Project_ID,associate_id ,Allocation_Startdate ,Allocation_Enddate ,Allocation_Percentage    
    
 -------------------------------------------    
  
    
 --Logic for mid-allocation    
 -----------------------------------    
    
 CREATE Table #FTE_ENDATE    
    
(    
    
Id int not null identity(1,1),    
    
Project_ID Char(15) Not Null,    
    
Associate_id  varchar(10),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
    
FTE_Location_END nvarchar(20)    
    
)    
    
INSERT INTO #FTE_ENDATE    
    
 SELECT DISTINCT    
  T.EsaProjectID    
  ,crs.Associate_ID    
  ,crs.Allocation_Start_Date    
  ,crs.Allocation_End_Date    
  ,crs.Allocation_Percentage    
  ,crs.Location    
 FROM [Adp].[Input_Data_AssociateRAW] T    
    
 LEFT JOIN [AppVisionLens].esa.Projects GP    
  ON CONVERT(VARCHAR, GP.ID) = T.EsaProjectID    
    
 --LEFT JOIN CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Allocation CRS    
 -- ON CONVERT(VARCHAR, GP.ID) = CRS.Project_ID    
  
 LEFT JOIN [Adp].[CentralRepository_Allocation] CRS    
  ON CONVERT(VARCHAR, GP.ID) = CRS.[Project_ID]    
  
    
 WHERE (crs.Allocation_Start_Date <= @StartDate    
 OR crs.Allocation_Start_Date >= @StartDate)    
 AND (CRS.Allocation_End_Date >= @StartDate    
 AND CRS.Allocation_End_Date <= @EndDate)    
    
    
-------------------------    
    
    
CREATE TABLE #Associate_endate_WeekDays    
    
(    
    
DateList DATE,    
    
DayWeek VARCHAR(100)    
    
)    
    
CREATE table #Associate__endate_diff_loc    
    
(    
    
Project_id Char(15) Not Null,    
    
Associate_id varchar(20),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
    
FTE_Location_END nvarchar(20),    
    
Workdays_loc int,    
    
Holidays_end int    
    
)    
    
DECLARE @id_first_1 int    
    
DECLARE @id_last_1 int    
    
DECLARE @id_first_Date_1 date    
    
DECLARE @id_first_Date_2 date    
    
DECLARE @As_Datepart1_1 INT    
    
DECLARE @da_1 varchar    
     
    
DECLARE @As_Datepart2_1 INT    
    
DECLARE @As_Datepart3_1 INT    
    
DECLARE @AL_Date_1 date    
    
DECLARE @AL_Date_2 date    
    
DECLARE @AssociateId_1 varchar(10)    
    
    
DECLARE @Project_id_1 Char(15)    
     
    
DECLARE @Allocation_startdate1 datetime    
    
DECLARE @Allocation_enddate1 datetime    
    
DECLARE @allocation_Percentage  decimal(10,4)    
    
DECLARE @FTE_Location_END nvarchar(20)    
    
SET @id_first_1 = (SELECT    
  MIN(id)    
 FROM #FTE_ENDATE)    
    
SET @id_last_1 = (SELECT    
  MAX(id)    
 FROM #FTE_ENDATE)    
    
  
WHILE(@id_last_1>=@id_first_1)    
    
Begin    
    
SET @id_first_Date_1 = (SELECT    
  Allocation_Enddate    
 FROM #FTE_ENDATE    
 WHERE Id = @id_first_1)  
    
SET @id_first_Date_2 = (SELECT    
  Allocation_Startdate    
 FROM #FTE_ENDATE    
 WHERE Id = @id_first_1)    
    
SET @AL_Date_1 = @id_first_Date_1  
    
SET @AL_Date_2 = @id_first_Date_2    
    
PRINT @AL_Date_1    
    
  
    
SET @AssociateId_1 = (SELECT    
  Associate_id    
 FROM #FTE_ENDATE    
 WHERE Id = @id_first_1)--    
    
SET @Project_id_1 = (SELECT    
  Project_ID    
 FROM #FTE_ENDATE    
 WHERE Id = @id_first_1    
 AND Associate_id = @AssociateId_1)    
    
SET @Allocation_startdate1 = (SELECT    
  Allocation_Startdate    
 FROM #FTE_ENDATE    
 WHERE Id = @id_first_1    
 AND Associate_id = @AssociateId_1)    
    
SET @Allocation_enddate1 = (SELECT    
  Allocation_Enddate    
 FROM #FTE_ENDATE    
 WHERE Id = @id_first_1    
 AND Associate_id = @AssociateId_1)    
    
SET @allocation_Percentage = (SELECT    
  Allocation_Percentage    
 FROM #FTE_ENDATE    
 WHERE Id = @id_first_1    
 AND Associate_id = @AssociateId_1)    
    
    
SET @FTE_Location_END =  (SELECT    
  FTE_Location_END    
 FROM #FTE_ENDATE    
 WHERE Id = @id_first_1    
 AND Associate_id = @AssociateId_1)    
    
SET @As_Datepart1_1 = DATEPART(dd, @StartDate)     
    
SET @As_Datepart2_1 = DATEPART(dd, @id_first_Date_1)     
    
SET @As_Datepart3_1 = DATEPART(dd, @id_first_Date_2)    
    
IF @Allocation_startdate1 >= @StartDate     
    
BEGIN    
    
WHILE (@As_Datepart2_1 >= @As_Datepart3_1) -- datepart2 allocat enddate || datepart3 allocat startdate    
    
BEGIN    
    
INSERT INTO #Associate_endate_WeekDays    
    
 SELECT    
  @AL_Date_2    
  ,DATENAME(dw, @AL_Date_2)    
    
SELECT @AL_DATE_2 = DATEADD(DAY, 1, @AL_Date_2)    
    
, @As_Datepart3_1 = @As_Datepart3_1 + 1    
    
END    
    
END ELSE BEGIN    
    
WHILE (@As_Datepart2_1 >= @As_Datepart1_1)--- datepart2 : allocation enda date || datepart 1 : report startdate    
    
BEGIN    
    
INSERT INTO #Associate_endate_WeekDays    
    
 SELECT    
  @AL_Date_1    
  ,DATENAME(dw, @AL_Date_1)    
    
SELECT @AL_DATE_1 = DATEADD(DAY, -1, @AL_DATE_1)    
    
, @As_Datepart1_1 = @As_Datepart1_1 + 1    
    
    
END    
    
END    
    
DELETE FROM #Associate_endate_WeekDays WHERE DayWeek IN ('Saturday', 'Sunday')    
    
    
    
INSERT INTO #Associate__endate_diff_loc    
    
 SELECT  DISTINCT  
  @Project_id_1    
  ,@AssociateId_1    
  ,@Allocation_startdate1    
  ,@Allocation_enddate1    
  ,@allocation_Percentage    
   ,@FTE_Location_END    
  ,(SELECT COUNT(1) FROM #Associate_endate_WeekDays)    
  ,(SELECT count(holiday) As 'Holidays' from  #HOLIDAYLIST     
where Location=@FTE_Location_END and  holiday BETWEEN @Allocation_startdate1 AND  @Allocation_enddate1)    
    
SET @id_first_1 = @id_first_1 + 1    
    
TRUNCATE TABLE #Associate_endate_WeekDays    
    
END    
  
    
CREATE table #Associate__endate_diff    
    
(    
    
    
Project_id Char(15) Not Null,    
    
Associate_id varchar(20),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
  
FTE_Location_END nvarchar(20),  
    
Workdays_diff  int,    
    
Workdays_Loc_end int    
    
)    
    
Insert into #Associate__endate_diff    
    
select DISTINCT Project_id , Associate_id, Allocation_Startdate,Allocation_Enddate,Allocation_Percentage,FTE_Location_END ,  
Workdays_loc,Isnull(Workdays_loc-Holidays_end,0)  from #Associate__endate_diff_loc    
    
  
CREATE table #FTE_endate_Cal_A    
    
(     
    
Project_ID Char(15) Not Null,    
    
Associate_id  varchar(10),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
  
FTE_Location nvarchar(20)  ,  
  
FTE_City nvarchar(40)  ,  
  
FTE_Country nvarchar(40)  ,  
    
Days_different numeric,    
    
FTE_Percentage decimal(10,4),    
    
ESA_FTE_Count Decimal(10,4),    
    
  
)    
    
INSERT INTO #FTE_endate_Cal_A   
    
 SELECT DISTINCT    
  a.Project_id    
  ,a.Associate_id    
  ,B.Allocation_Startdate    
  ,B.Allocation_Enddate    
  ,B.Allocation_Percentage  , A.FTE_Location_END,Ltrim(Rtrim(LC.City)) as 'City',Ltrim(Rtrim(LC.country)) as country  
  ,SUM(a.Workdays_diff)    
  ,ISNULL(SUM((A.Workdays_diff / (CONVERT(DECIMAL(5, 2), @WorkdAYS))) * B.Allocation_Percentage), 0) AS FTE_Percentage    
  ,ISNULL(SUM((A.Workdays_diff / CONVERT(DECIMAL(5, 2), @WorkdAYS)) * B.Allocation_Percentage) / 100, 0) AS ESA_FTE_Count    
    FROM #Associate__endate_diff A    
    
 LEFT JOIN #FTE_ENDATE B    
  ON a.Associate_id = b.Associate_id    
  AND a.Project_id = b.Project_ID    
  AND A.Allocation_Startdate = b.Allocation_Startdate    
  AND A.Allocation_Enddate = b.Allocation_Enddate    
  AND A.Allocation_Percentage = b.Allocation_Percentage    
  
    
  left join [AppVisionLens].esa.locationmaster LC on A.FTE_Location_END=LC.Assignment_Location  
    
 GROUP BY a.Project_id    
    ,a.Associate_id    
    ,B.Allocation_Startdate    
    ,B.Allocation_Enddate    
    ,B.Allocation_Percentage  ,A.FTE_Location_END,LC.City ,LC.country ,a.Workdays_diff    
    
  
  
  
  
CREATE table #FTE_endate_Cal    
    
(     
    
Project_ID Char(15) Not Null,    
    
Associate_id  varchar(10),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
  
FTE_Location nvarchar(20)  ,  
  
FTE_City nvarchar(40)  ,  
  
FTE_Country nvarchar(40) ,  
    
Days_different numeric,    
    
FTE_Percentage decimal(10,4),    
    
ESA_FTE_Count Decimal(10,4),    
    
Available_Hours Decimal(10,2)    
    
)    
    
INSERT INTO #FTE_endate_Cal    
    
 SELECT  DISTINCT  
  a.Project_id    
  ,A.Associate_id    
  ,A.Allocation_Startdate    
  ,A.Allocation_Enddate    
  ,A.Allocation_Percentage  , A.FTE_location, A.FTE_city,A.FTE_Country  
  ,A.Days_different    
  ,A.FTE_Percentage    
  ,A.ESA_FTE_Count    
  ,CASE WHEN isnull(MHC.Mandatory_Hours,0)=0  
  THEN  
  ISNULL(SUM(B.Workdays_Loc_end * B.Allocation_Percentage * @IndiaHours)/100 , 0)   
  ELSE  
   ISNULL(SUM(B.Workdays_Loc_end * B.Allocation_Percentage * MHC.Mandatory_Hours)/100 , 0)      
   END As Available_Hours  
  
   FROM #FTE_endate_Cal_A  A    
    
  left  JOIN #Associate__endate_diff B   ON a.Associate_id = b.Associate_id    
  AND a.Project_id = b.Project_ID  and A.Allocation_Startdate=B.Allocation_Startdate and A.Allocation_Enddate=B.Allocation_Enddate  
  and A.Allocation_Percentage=B.Allocation_Percentage  
left join [ADP].[MandatoryHoursConfig] MHC on MHC.EsaProjectID=A.Project_ID  and MHC.Isdeleted=0  
   where A.FTE_Country='IND' and A.FTE_city not in ('Kolkata','Noida')   
    
 GROUP BY  a.Project_id    
  ,A.Associate_id    
  ,A.Allocation_Startdate    
  ,A.Allocation_Enddate    
  ,A.Allocation_Percentage , A.FTE_location, A.FTE_city,A.FTE_Country   
  ,A.Days_different    
  ,A.FTE_Percentage    
  ,A.ESA_FTE_Count ,B.Workdays_Loc_end  
  ,MHC.Mandatory_Hours  
  
---Non india  
  
INSERT INTO #FTE_endate_Cal   
  
 SELECT  DISTINCT  
  a.Project_id    
  ,A.Associate_id    
  ,A.Allocation_Startdate    
  ,A.Allocation_Enddate    
  ,A.Allocation_Percentage,A.FTE_location, A.FTE_city,A.FTE_Country     
  ,A.Days_different    
  ,A.FTE_Percentage    
  ,A.ESA_FTE_Count    
  ,CASE WHEN isnull(MHC.Mandatory_Hours,0)=0  
  THEN  
  ISNULL(SUM(B.Workdays_Loc_end * B.Allocation_Percentage * @NonIndiaHours)/100 , 0)   
  ELSE  
   ISNULL(SUM(B.Workdays_Loc_end * B.Allocation_Percentage * MHC.Mandatory_Hours)/100 , 0)   
   END As Available_Hours   
  
   FROM #FTE_endate_Cal_A  A    
    
  left  JOIN #Associate__endate_diff B   ON a.Associate_id = b.Associate_id    
  AND a.Project_id = b.Project_ID  and A.Allocation_Startdate=B.Allocation_Startdate and A.Allocation_Enddate=B.Allocation_Enddate  
  and A.Allocation_Percentage=B.Allocation_Percentage  
  left join [ADP].[MandatoryHoursConfig] MHC on MHC.EsaProjectID=A.Project_ID  and MHC.Isdeleted=0  
  
   where A.FTE_country <> 'IND' or A.FTE_city  in ('Kolkata','Noida') or A.FTE_country is null  
       
 GROUP BY  a.Project_id    
  ,A.Associate_id    
  ,A.Allocation_Startdate    
  ,A.Allocation_Enddate    
  ,A.Allocation_Percentage ,A.FTE_location, A.FTE_city,A.FTE_Country    
  ,A.Days_different    
  ,A.FTE_Percentage    
  ,A.ESA_FTE_Count ,B.Workdays_Loc_end,MHC.Mandatory_Hours  
  
---------------    
    
   
CREATE table #FTE_End_Final    
    
(    
    
Project_ID Char(15) Not Null,    
    
associate_id char(15),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
    
ESA_FTE_Count Decimal(10,4),    
    
Available_Hours Decimal(10,2)    
    
)    
    
INSERT INTO #FTE_End_Final    
    
 SELECT  DISTINCT  
  A.Project_ID    
  ,A.Associate_id    
  ,A.Allocation_Startdate    
  ,A.Allocation_Enddate    
  ,A.Allocation_Percentage    
  ,SUM(A.ESA_FTE_Count) AS ESA_FTE_Count, sum(A.Available_Hours)    
 FROM #FTE_endate_Cal A    
 GROUP BY a.Project_ID    
    ,A.Associate_id    
    ,A.Allocation_Startdate    
    ,A.Allocation_Enddate    
    ,A.Allocation_Percentage    
    
    
------------- Union of both the tables    
    
  
    
SELECT Project_ID, associate_id,Allocation_Startdate,Allocation_Enddate,Allocation_Percentage,ESA_FTE_Count,Available_Hours  INTO #FTE_BM    
FROM ((SELECT    
  Project_ID, associate_id,Allocation_Startdate,Allocation_Enddate,Allocation_Percentage,ESA_FTE_Count,Available_Hours   
 FROM #FTE_count) UNION ALL (SELECT    
Project_ID, associate_id,Allocation_Startdate,Allocation_Enddate,Allocation_Percentage,ESA_FTE_Count,Available_Hours    
 FROM #FTE_Final) UNION ALL (SELECT    
Project_ID, associate_id,Allocation_Startdate,Allocation_Enddate,Allocation_Percentage,ESA_FTE_Count,Available_Hours   
 FROM #FTE_End_Final)) p    
   
  
  
   CREATE table #Associalte_FinalAllocation    
    
(    
    
Parent_Accountid Char(15),    
    
Parent_AccountName varchar (100),    
    
SBU varchar (50),    
    
Vertical varchar (50),    
    
SDM_ID char(15),    
    
SDM_Name varchar (100),    
    
SDD_ID char(15),    
    
SDD_Name varchar (100),    
    
Project_ID Char(15) Not Null,    
    
associate_id char(15),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
    
ESA_FTE_Count Decimal(10,4),    
    
Available_Hours Decimal(10,2),    
    
DE_Inscope varchar(50)    
    
)    
    
INSERT INTO #Associalte_FinalAllocation    
    
 SELECT DISTINCT    
  C.ParentAccountID    
  ,C.ParentAccountName    
  ,C.PracticeOwner,C.ProjectOwningPractice,c.[PO ID],c.[PO Name],c.[DM ID],c.[DM Name]    
  ,A.Project_ID ,A.associate_id,A.Allocation_Startdate,A.Allocation_Enddate,A.Allocation_Percentage,A.ESA_FTE_Count     
  ,sum(A.Available_Hours)  As Available_Hours   
  ,B.DE_Inscope    
 FROM #FTE_BM A    
    
 INNER JOIN [Adp].[Input_Excel_Associate] B    
  ON a.project_id = b.EsaProjectID    
 INNER JOIN [Adp].[Input_Data_AssociateRAW] C    
  ON a.project_id = c.EsaProjectID     
group by C.ParentAccountID    
  ,C.ParentAccountName    
  ,C.PracticeOwner,C.ProjectOwningPractice,c.[PO ID],c.[PO Name],c.[DM ID],c.[DM Name]    
  ,A.Project_ID ,A.associate_id,A.Allocation_Startdate,A.Allocation_Enddate,A.Allocation_Percentage,A.ESA_FTE_Count  ,B.DE_Inscope    
  
    
  ------------------------------------------------------------------    
SELECT    
 AssociateID,AssociateName,Designation,Grade,Email,PassportNo,PassPortIssueDate,PassportExpiryDate,IsActive,LastModifiedDate,Supervisor_ID,Supervisor_Name,JobCode,    
Offshore_Onsite,Assignment_Location,City,[State],Country    
 ,CASE    
  WHEN ISNUMERIC(SUBSTRING(Grade, 2, 2)) = 1 THEN SUBSTRING(Grade, 2, 2)    
    
  ELSE NULL    
    
 END AS UpdatedGrade INTO #Temp_Applens    
    
FROM [AppVisionLens].ESA.Associates    
    
    
  
    
SELECT DISTINCT AssociateID,AssociateName,Designation,Grade,Email,PassportNo,PassPortIssueDate,PassportExpiryDate,IsActive,LastModifiedDate,Supervisor_ID,Supervisor_Name,JobCode,    
Offshore_Onsite,Assignment_Location,City,[State],Country,UpdatedGrade    
    
INTO #Temp_BM_Applns FROM #Temp_Applens WHERE updatedGrade > 50    
    
    
CREATE table #Associalte_Final_All    
    
(    
    
Parent_Accountid Char(15),    
    
Parent_AccountName varchar (100),    
    
SBU varchar (50),    
    
Vertical varchar (50),    
    
SDM_ID char(15),    
    
SDM_Name varchar (100),    
    
SDD_ID char(15),    
    
SDD_Name varchar (100),    
    
Project_ID Char(15) Not Null,    
    
Project_Name varchar(100),    
    
associate_id char(15),    
    
Assciate_Name varchar(100),    
    
Allocation_Startdate datetime,    
    
Allocation_Enddate datetime,    
    
Allocation_Percentage decimal(10,4),    
    
ESA_FTE_Count Decimal(10,4),    
    
Available_Hours Decimal(10,2),    
    
DE_Inscope varchar(50),    
    
Department_Name varchar(100),    
    
Job_Code varchar(20),    
    
Designation varchar(50),    
    
    
)    
    
  
  
begin    
    
INSERT INTO #Associalte_Final_All    
    
    
    
 SELECT DISTINCT    
     
  AF.Parent_Accountid,AF.Parent_AccountName,AF.SBU,AF.Vertical,AF.SDM_ID,AF.SDM_Name,AF.SDD_ID,AF.SDD_Name,AF.Project_ID,PRS.Project_Name,AF.associate_id,AP.AssociateName,AF.Allocation_Startdate,    
  AF.Allocation_Enddate,AF.Allocation_Percentage,AF.ESA_FTE_Count,AF.Available_Hours,AF.DE_Inscope ,CRS.[Dept_Name],CRS.[JobCode],CRS.[Designation]  
  
    
 FROM #Associalte_FinalAllocation AF    
  
 JOIN #Temp_BM_Applns AP    
  ON AF.Associate_id = ap.Associateid     
    
 --LEFT JOIN CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Project PRS    
 -- ON AF.Project_ID = PRS.Project_id    
    
 LEFT JOIN [Adp].[CentralRepository_Project] PRS    
  ON AF.Project_ID = PRS.Project_id    
    
 --LEFT JOIN CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Associate_Details CRS    
 -- ON AF.Associate_id = crs.Associate_ID    
  
   LEFT JOIN [Adp].[CentralRepository_Associate_Details] CRS    
  ON AF.Associate_id = crs.Associate_ID   
    
  
  
    
    
 ORDER BY Af.Associate_id DESC    
    
    
  
    
    
    
delete from #Associalte_Final_All where associate_id='323477'    
    
end    
    
  
  
    
SELECT DISTINCT    
 AF.associate_id,    
 AF.Assciate_Name    
 ,lg.UserID    
 ,PM.EsaProjectID    
 ,PM.ProjectName    
 ,LG.ProjectID    
 ,AF.Parent_Accountid as ParentCustomerID    
 ,AF.Parent_AccountName as   ParentCustomername  
 ,LG.IsNonESAAuthorized    
 ,AF.DE_Inscope INTO #Allocatedassoc    
FROM #Associalte_Final_All AF    
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
WHERE   
CS.IsDeleted = '0' AND PM.IsDeleted = '0' --AND PA.IsActive = '1'     
    
    
    
SELECT DISTINCT    
 LG.EmployeeID,    
 LG.EmployeeName    
 ,PM.EsaProjectID,    
 PM.ProjectName    
 ,lg.UserID    
 ,LG.ProjectID    
 ,LG.IsNonESAAuthorized   
INTO #TEMPR    
FROM [AppVisionLens].AVL.MAS_LoginMaster LG    
JOIN #Temp_BM_Applns APS    
 ON LG.EmployeeID = APS.associateid    
LEFT JOIN [AppVisionLens].AVL.MAS_ProjectMaster PM    
 ON LG.ProjectID = PM.ProjectID    
LEFT JOIN [Adp].[Input_Data_AssociateRAW] AD    
 ON PM.EsaProjectID = ad.EsaProjectID    
LEFT JOIN [Adp].[Input_Excel_Associate] B ON PM.EsaProjectID=b.EsaProjectID    
WHERE LG.IsDeleted = '0'    
AND PM.IsDeleted = '0'    
    
DELETE  FROM #TEMPR WHERE EmployeeID='323477'    
    
  
    
SELECT DISTINCT    
 EmployeeID,EmployeeName    
 ,EsaProjectID,ProjectName    
 ,UserID    
 ,ProjectID    
 ,ParentCustomerID    
 ,ParentCustomerName    
 ,IsNonESAAuthorized    
 ,DE_Inscope    
 ,Dept_Name    
 ,Jobcode    
 ,Designation INTO #LoginAssociate    
FROM (SELECT DISTINCT    
  LG.EmployeeID,LG.EmployeeName    
  ,LG.EsaProjectID,LG.ProjectName    
  ,LG.UserID    
  ,LG.ProjectID    
  ,AF.Parent_Accountid as ParentCustomerID  
  ,AF.Parent_AccountName  as ParentCustomerName  
  ,LG.IsNonESAAuthorized    
  ,AF.DE_Inscope ,   
CRS.[Dept_Name],  
CRS.[JobCode],  
CRS.[Designation]   
    
 FROM #TEMPR LG    
 JOIN #Temp_BM_Applns APS    
  ON LG.EmployeeID = APS.associateid    
 LEFT JOIN [AppVisionLens].AVL.MAS_ProjectMaster PM    
  ON LG.ProjectID = PM.ProjectID    
 JOIN [AppVisionLens].AVL.Customer CS    
  ON PM.CustomerID = CS.CustomerID    
 LEFT JOIN #Associalte_Final_All AF    
  ON PM.EsaProjectID = AF.Project_ID    
  LEFT JOIN [Adp].[CentralRepository_Associate_Details] CRS    
  ON LG.EmployeeID = crs.Associate_ID    
 WHERE   
 CS.IsDeleted = '0'    
 AND PM.IsDeleted = '0'   
   
  
 ) TMP    
--WHERE Topp = 1     
    
    
SELECT DISTINCT    
 EmployeeID,EmployeeName    
 ,UserID    
 ,EsaProjectID,Projectname    
 ,ProjectID    
 ,ParentCustomerID    
 ,ParentCustomerName    
 ,IsNonESAAuthorized    
 ,Dept_name    
 ,Jobcode    
 ,designation INTO #Tempfin    
FROM #LoginAssociate A    
WHERE NOT EXISTS (SELECT    
associate_id,assciate_name    
  ,UserID    
  ,EsaProjectID,projectname    
  ,ProjectID    
  ,ParentCustomerID    
  ,ParentCustomerName    
  ,IsNonESAAuthorized  
  ,DE_Inscope  
 FROM #Allocatedassoc B    
 WHERE a.EmployeeID = b.associate_id    
 AND a.EsaProjectID = b.EsaProjectID)    
    
  
    
INSERT INTO #Associalte_Final_All (Parent_Accountid, Parent_AccountName, SBU,Vertical,SDM_ID,SDM_Name,SDD_ID,SDD_Name ,Project_ID, Project_Name,associate_id, Assciate_Name,B.DE_Inscope, Department_Name,Job_Code, Designation)    
    
 SELECT DISTINCT    
  ParentCustomerID    
  ,ParentCustomerName    
  ,C.PracticeOwner,C.ProjectOwningPractice    
  ,c.[PO ID],c.[PO Name],c.[DM ID],c.[DM Name]    
  ,a.EsaProjectID,A.Projectname    
  ,EmployeeID,EMployeeName    
  ,B.DE_Inscope    
  ,Dept_Name    
  ,jobcode    
  ,designation    
 FROM #Tempfin A    
 JOIN [Adp].[Input_Excel_Associate] B    
  ON a.EsaProjectID = b.EsaProjectID    
  JOIN [Adp].[Input_Data_AssociateRAW] C    
  ON a.EsaProjectID = c.EsaProjectID    
  
DELETE FROM #Associalte_Final_All where (   
--Allocation in first 2 days of the month and 2 days are sat and sun  
(DATEDIFF(DAY,Allocation_StartDate,Allocation_EndDate)=1 AND Allocation_StartDate=@StartDate  
AND DATENAME(WEEKDAY,@StartDate)='Saturday'  
AND DATENAME(WEEKDAY,DATEADD(DAY,1,@StartDate))='Sunday') OR  
--Allocation in first 2 days of the month and 2 days are sat and sun where AllocationStartDate is in past  
(DATEDIFF(DAY,@StartDate,Allocation_EndDate)=1  
AND DATENAME(WEEKDAY,@StartDate)='Saturday'  
AND DATENAME(WEEKDAY,DATEADD(DAY,1,@StartDate))='Sunday') OR  
--Allocation in last 2 days of the month and 2 days are sat and sun  
(DATEDIFF(DAY,Allocation_StartDate,Allocation_EndDate)=1 AND Allocation_EndDate=EOMONTH(@StartDate)  
AND DATEPART(WEEKDAY,DATEADD(DAY,-1,EOMONTH(@StartDate)))=7  
AND DATEPART(WEEKDAY,EOMONTH(@StartDate))=1) OR  
--Allocation in first day of month and it is either sat or sun  
(Allocation_EndDate=@StartDate  
AND (DATENAME(WEEKDAY,@StartDate)='Saturday' OR DATENAME(WEEKDAY,@StartDate)='Sunday')) OR  
--Allocation in last day of month and it is either sat or sun  
(Allocation_StartDate=EOMONTH(@StartDate)   
AND (DATEPART(WEEKDAY,EOMONTH(@StartDate))=7 OR DATEPART(WEEKDAY,EOMONTH(@StartDate))=1)) OR  
--Mid Allocation for only 2 days and 2 days are sat and sun  
(DATEDIFF(DAY,Allocation_StartDate,Allocation_EndDate)=1   
AND DATENAME(WEEKDAY,Allocation_StartDate)='Saturday'  
AND DATENAME(WEEKDAY,Allocation_EndDate)='Sunday') OR  
--Mid Allocation for only 1 day and it either sat or sun   
(DATEDIFF(DAY,Allocation_StartDate,Allocation_EndDate)=0  
AND (DATENAME(WEEKDAY,Allocation_StartDate)='Saturday'   
OR DATENAME(WEEKDAY,Allocation_StartDate)='Sunday'))  
)  
    
    
TRUNCATE table [ADP].[Associate_Allocation_Raw]   
    
INSERT INTO [ADP].[Associate_Allocation_Raw]   
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,SBU, Vertical,SDM_ID ,SDM_Name ,SDD_ID ,SDD_Name     
,Project_ID ,Project_Name,associate_id ,Assciate_Name, Allocation_Startdate ,Allocation_Enddate ,Allocation_Percentage,    
    
ESA_FTE_Count ,Available_Hours ,DE_Inscope ,Department_Name ,Job_Code,Designation     
    
FROM #Associalte_Final_All     
    
  
    
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
  associate_id,assciate_name    
  ,UserID    
  ,EsaProjectID,projectname    
  ,ProjectID    
  ,ParentCustomerID    
  ,ParentCustomerName    
  ,IsNonESAAuthorized    
 FROM #Allocatedassoc    
  
DELETE FROM #Loginmaster_associate WHERE EmployeeID='323477'    
    
   
    
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
    
 SELECT  DISTINCT   
  Parent_Accountid    
  ,Parent_AccountName    
  ,EsaProjectID,Projectname    
  ,EmployeeID,EmployeeName    
  ,IsNonESAAuthorized    
  ,ISNULL(SUM(D.Hours),0) As 'MPS_Effort'    
   FROM #Loginmaster_associate tmp    
 LEFT JOIN [AppVisionLens].AVL.TM_PRJ_Timesheet B    
  ON tmp.UserID = b.SubmitterId    
  AND B.TimesheetDate BETWEEN @StartDate AND @enddate    
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
    
 SELECT  DISTINCT   
  Parent_Accountid    
  ,Parent_AccountName    
  ,EsaProjectID,Projectname    
  ,EmployeeID,EmployeeName    
  ,IsNonESAAuthorized    
  ,ISNULL(SUM(D.Hours),0) As 'Workitem_effort'    
   FROM #Loginmaster_associate tmp    
 LEFT JOIN [AppVisionLens].AVL.TM_PRJ_Timesheet B    
  ON tmp.UserID = b.SubmitterId    
  AND B.TimesheetDate BETWEEN @StartDate AND @enddate    
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
  ,A.IsNonESAAuthorized ,Isnull(sum(AP.MPS_Effort+INF.Infra_Effort),0) as 'MPS' --Isnull(sum(AP.MPS_Effort+INF.Infra_Effort+WI.Workitem_Effort),0) as 'MPS'    
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
  ,SUM(ISNULL(MP.MPS_Effort, 0) + ISNULL(WI.Workitem_Effort, 0)+ ISNULL(MA.MAS_Effort, 0)) 'Actual_Effort'    
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
  ,Project_ID,A.Project_Name    
  ,associate_id    
  ,A.Assciate_Name    
  ,ISNULL(SUM(ESA_FTE_Count), 0)    
  ,ISNULL(SUM(Available_Hours), 0)    
 FROM #Associalte_Final_All A    
  
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,Project_ID,A.Project_Name    
    ,associate_id,A.Assciate_Name    
    
   
    
CREATE Table #Associate_Summary    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
SBU varchar (50),    
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
  ,ISNULL((B.Work_Profile_AD), 0)  
  ,ISNULL((B.MAS_Effort), 0)    
  ,ISNULL((B.Actual_Effort), 0)    
  ,ISNULL(((Actual_Effort / NULLIF(Available_Hours, 0)) * 100), 0)    
 FROM #Associate_FTE_Hours AF    
  
 join [Adp].[Input_Data_AssociateRAW] BU    
  ON af.EsaProjectID = bU.EsaProjectID    
 LEFT JOIN #Total_Effort B    
  ON af.Parent_Accountid = b.Parent_Accountid    
  AND af.Parent_AccountName = b.Parent_AccountName    
  AND af.EsaProjectID = b.EsaProjectID    
  AND af.EmployeeID = b.EmployeeID    
    
  
    
select distinct Parent_Accountid,SBU,VERTICAL,Associate_ID,project_id, Department_Name into #department from [ADP].[Associate_Allocation_Raw]     
    
SELECT DISTINCT Parent_Accountid,SBU,VERTICAL,Associate_ID, project_id,Job_code,Designation into #designation from [ADP].[Associate_Allocation_Raw]    
    
SELECT DISTINCT    
 a.Parent_Accountid    
  ,a.Parent_AccountName,A.SBU,A.Vertical    
  ,a.EmployeeID,A.EmployeeName,    
  A.EsaProjectID,A.Projectname--,B.Designation    
  ,SUM(A.Avaialble_FTE_Below_M)AS 'Avaialble_FTE_Below_M'    
  ,SUM(A.Available_Hours) AS 'Available_Hours'    
  ,SUM(A.MPS_Effort) AS 'MPS_Effort'    
  ,SUM(A.Work_Profile_AD) AS 'Work_Profile_AD'  
  ,SUM(A.MAS_Effort) AS 'MAS_Effort'    
  ,SUM(A.Actual_Effort) AS 'Actual_Effort'    
  ,ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours), 0) * 100), 0) AS 'Associate_Account_Compliance' into #AssociateSummarytmp    
 FROM #Associate_Summary A    
  GROUP BY A.Parent_Accountid    
    ,A.Parent_AccountName,A.SBU,a.Vertical    
    ,EmployeeID,A.EsaProjectID,A.EmployeeName,A.Projectname  
  
    
CREATE Table #AssociateActual_Final    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
SBU varchar (50),    
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
  
    
    
INSERT INTO #AssociateActual_Final    
    
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
    
TRUNCATE TABLE [Adp].Associate_Compliance_RAW    
INSERT  INTO [ADP].Associate_Compliance_RAW    
SELECT DISTINCT Parent_Accountid,    
Parent_AccountName ,    
SBU ,    
Vertical ,    
EsaProjectID,    
Projectname ,    
EmployeeID ,    
EmployeeName ,    
Department_Name ,    
Job_Code ,    
Designation ,    
Avaialble_FTE_Below_M ,    
Available_Hours ,    
MPS_Effort ,  
Work_Profile_AD ,   
MAS_Effort ,    
Actual_Effort ,    
Associate_Account_Compliance  FROM #AssociateActual_Final  
  
  
  
    
---------*******************************    
    
    
CREATE Table #Associate_Projectcompliance    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
SBU varchar (50),    
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
    
  
    
INSERT INTO #Associate_Projectcompliance    
    
SELECT  DISTINCT A.Parent_Accountid,A.Parent_AccountName,A.EsaProjectID,A.Projectname,A.SBU,A.EmployeeID,A.Department_Name,sum(A.Avaialble_FTE_Below_M),sum(Available_Hours),    
sum(A.MPS_Effort),Sum(a.Work_Profile_AD),Sum(A.MAS_Effort),sum(A.Actual_Effort),ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours), 0) * 100), 0) from #AssociateActual_Final A    
JOIN [ADP].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope in('In Scope','Yet to scope')    
GROUP BY A.Parent_Accountid,A.Parent_AccountName,A.EsaProjectID,A.Projectname,A.SBU,A.EmployeeID,A.Department_Name    
    
    
    
CREATE Table #Associate_Total_project_Compliance    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
SBU varchar (50),    
EmployeeID varchar(15),    
Avaialble_FTE_Below_M decimal (10,2),    
Available_Hours decimal (10,2),    
MPS_Effort decimal (10,2),    
Work_Profile_AD decimal (10,2),   
MAS_Effort decimal (10,2),    
Actual_Effort decimal (10,2),    
Associate_Project_Compliance decimal (10,2)    
)    
    
INSERT INTO #Associate_Total_project_Compliance    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName, EsaProjectid,ProjectName,SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)    
  ,SUM(Available_Hours)    
  ,SUM(MPS_Effort)  
  ,SUM(Work_Profile_AD)  
  ,SUM(MAS_Effort)    
  ,SUM(Actual_Effort)    
  ,sum(Associate_Project_Compliance)    
 FROM #Associate_Projectcompliance     
 GROUP BY Parent_Accountid    
  ,Parent_AccountName, EsaProjectid,ProjectName,SBU    
  ,EmployeeID    
    
   
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,EsaProjectid,ProjectName,SBU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,    
Associate_Project_Compliance INTO #Associate_Greater80_Prj    
FROM #Associate_Total_project_Compliance    
WHERE Associate_Project_Compliance > 80    
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,EsaProjectid,ProjectName,SBU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,    
Associate_Project_Compliance INTO #Associate_Greater_50_80_Prj    
FROM #Associate_Total_project_Compliance    
WHERE Associate_Project_Compliance >50  and Associate_Project_Compliance <=80    
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,EsaProjectid,ProjectName,SBU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,    
Associate_Project_Compliance INTO #Associate_Greater_25_50_prj    
FROM #Associate_Total_project_Compliance    
WHERE  Associate_Project_Compliance >25  and Associate_Project_Compliance <=50  
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,EsaProjectid,ProjectName,SBU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,    
Associate_Project_Compliance INTO #Associate_Greater_0_25_prj    
FROM #Associate_Total_project_Compliance    
WHERE  Associate_Project_Compliance >0  and Associate_Project_Compliance <=25    
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,EsaProjectid,ProjectName,SBU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,    
Associate_Project_Compliance INTO #Associate_Greater_Zero_prj    
FROM #Associate_Total_project_Compliance    
WHERE Associate_Project_Compliance =0    
    
  
CREATE TABLE #Associate_zero_prj    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
EmployeeID varchar(15),    
ESA_FTE_Zero DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_zero_prj    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,EsaProjectid,ProjectName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_Zero_prj   
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,EsaProjectid,ProjectName    
    ,EmployeeID    
    
CREATE TABLE #Associate_0_25_prj    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
EmployeeID varchar(15),    
ESA_FTE_0_25 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_prj    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,EsaProjectid,ProjectName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_0_25_prj --where parent_accountid='2000004'    
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,EsaProjectid,ProjectName    
    ,EmployeeID    
    
CREATE TABLE #Associate_25_50_prj    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
EmployeeID varchar(15),    
ESA_FTE_25_50 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_prj    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,EsaProjectid,ProjectName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50_Prj     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,EsaProjectid,ProjectName    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_50_80_Prj    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
EmployeeID varchar(15),    
ESA_FTE_50_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_Prj    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,EsaProjectid,ProjectName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80_prj   
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,EsaProjectid,ProjectName    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_80_Prj    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
EmployeeID varchar(15),    
ESA_FTE_80 DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_Prj    
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName,EsaProjectid,ProjectName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_Prj  
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,EsaProjectid,ProjectName    
    ,EmployeeID    
    
  
    
    
CREATE table #Project_Compliance    
    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EsaProjectid Char(15),    
ProjectName varchar(100),    
SBU varchar (50),    
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
Associate_Project_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #Project_Compliance    
    
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
  ,ISNULL(SUM(a.Work_Profile_AD), 0)  
  ,ISNULL(SUM(a.MAS_Effort), 0)    
  ,ISNULL(SUM(a.Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(F.ESA_FTE_80), 0)) / NULLIF(SUM(a.Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_Total_project_Compliance A    
   
 LEFT JOIN #Associate_zero_prj B ON a.Parent_Accountid = b.Parent_Accountid AND A.EmployeeID = b.EmployeeID AND a.EsaProjectid=b.EsaProjectid    
 LEFT JOIN #Associate_0_25_prj C ON a.Parent_Accountid = c.Parent_Accountid AND A.EmployeeID = c.EmployeeID AND a.EsaProjectid = c.EsaProjectid    
 LEFT JOIN #Associate_25_50_prj D ON a.Parent_Accountid = d.Parent_Accountid AND A.EmployeeID = d.EmployeeID AND a.EsaProjectid = d.EsaProjectid    
 LEFT JOIN #Associate_50_80_Prj E ON a.Parent_Accountid = e.Parent_Accountid AND A.EmployeeID =e.EmployeeID AND a.EsaProjectid = e.EsaProjectid    
 LEFT JOIN #Associate_80_Prj F ON a.Parent_Accountid = f.Parent_Accountid AND A.EmployeeID = f.EmployeeID AND a.EsaProjectid = f.EsaProjectid      
    
 GROUP BY a.Parent_Accountid    
  ,a.Parent_AccountName,A.EsaProjectid,A.ProjectName,A.SBU    
    
 --select * from #Associate_Accountcompliance   
  
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
  
----select * from  #Associate_Accountcompliance a  
--JOIN [Adp].[Input_Data_AssociateRAW] C ON a.EsaProjectID=C.EsaProjectID   
  
INSERT INTO  #Associate_Accountcompliance    
    
SELECT  DISTINCT A.Parent_Accountid,A.Parent_AccountName,A.Vertical,C.PracticeOwner,C.MARKET_BU,A.EmployeeID,A.Department_Name,PROJECTSCOPE,  
sum(A.Avaialble_FTE_Below_M),sum(A.Available_Hours),    
sum(A.MPS_Effort),sum(A.Work_Profile_AD),Sum(A.MAS_Effort),sum(A.Actual_Effort),ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours),0) * 100), 0)   
from #AssociateActual_Final A    
JOIN [Adp].Input_Data_AssociateRAW C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'  --and Parent_Accountid='2000004'  
Group by  A.Parent_Accountid,A.Parent_AccountName,A.Vertical,A.EmployeeID,A.Department_Name,C.PracticeOwner,C.MARKET_BU,PROJECTSCOPE  
  
select distinct A.Parent_Accountid,A.EsaProjectID as 'Project#',c.projectscope,A.Vertical,C.PracticeOwner,C.MARKET_BU,sum(Available_Hours) as 'Availablehours' Into #ScopeProject_tmp  
from #AssociateActual_Final A  
JOIN [Adp].[Input_Data_AssociateRAW] C ON A.parent_accountid=C.parentaccountid and a.EsaProjectID=C.EsaProjectID     
group by A.Parent_Accountid ,A.EsaProjectID,c.projectscope,A.Vertical,C.PracticeOwner,C.MARKET_BU  
  
--select * from #ScopeProject  
  
--drop table #ScopeProject  
  
select Parent_Accountid, ProjectScope,Vertical,PracticeOwner,MARKET_BU, count(Project#) as 'Project#',sum(Availablehours) as 'Availablehours'   
into #ScopeProject  
from  #ScopeProject_tmp a  
group by A.Parent_Accountid,a.ProjectScope,Vertical,PracticeOwner,MARKET_BU  
  
  
CREATE TABLE #YETTOSCOPE  
(  
Parent_Accountid Char(15),    
Vertical [varchar](50) NULL,  
[MARKET UNIT NAME] [varchar](50) NULL,  
[BU] [varchar](50) NULL,  
[Yet to onboard projects #] INT,  
Available_Hours decimal (10,2)  
)  
  
INSERT INTO #YETTOSCOPE  
  
SELECT Parent_Accountid,Vertical,PracticeOwner,MARKET_BU,Project#, Availablehours FROM  #ScopeProject WHERE ProjectScope=''  
  
INSERT INTO [ADP].[Account_Compliance_YETTOSCOPE]  
SELECT Parent_Accountid,Vertical,[MARKET UNIT NAME],[BU], [Yet to onboard projects #],Available_Hours FROM #YETTOSCOPE  
  
--select * from #AssociateActual_Final  
--drop table #YETTOSCOPE  
  
  
  
TRUNCATE table  [Adp].[Associate_Accountcompliance_Raw]  
    
INSERT INTO  [Adp].[Associate_Accountcompliance_Raw]    
    
select DISTINCT  Parent_Accountid ,    
Parent_AccountName ,    
Vertical ,    
EmployeeID ,    
Department_Name ,    
Avaialble_FTE_Below_M ,    
Available_Hours ,    
MPS_Effort ,   
Work_Profile_AD,  
MAS_Effort ,    
Actual_Effort ,    
Associate_Account_Compliance FROM #Associate_Accountcompliance   
  
--select * from #Associate_Total_account_Compliance where Parent_Accountid='2000559'  
  
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
  ,Parent_AccountName,Vertical,  
  MarketUnitName,BU,Project_Scope,  
  EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)    
  ,SUM(Available_Hours)    
  ,SUM(MPS_Effort)  
  ,SUM(Work_Profile_AD)  
  ,SUM(MAS_Effort)    
  ,SUM(Actual_Effort)    
  ,sum(Associate_Account_Compliance)   
 FROM #Associate_Accountcompliance   
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,Vertical,MarketUnitName,BU,Project_Scope, EmployeeID   
  
--AVM scope Account Compliance Split  
  
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,  
MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
INTO #Associate_Greater80_AM    
FROM #Associate_Total_account_Compliance  
WHERE [Associate_Account_Compliance] > 80  and Project_scope='AVM'  
  
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_50_80_AM  
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80  and Project_scope='AVM'  
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_25_50_AM    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50  and Project_scope='AVM'  
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_0_25_AM    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25  and Project_scope='AVM'  
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_Zero_AM   
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] =0  and Project_scope='AVM'  
  
CREATE TABLE #Associate_zero_AM   
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_Zero DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_zero_AM   
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_AM     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
    
  
    
CREATE table #Account_Compliance_AM_temp    
    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),   
MarketUnitName varchar(50),  
BU varchar(50),  
[AVM Project #] INT,  
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
Effort_Account_Compliance decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
 --select * from #Account_Compliance_AD  
    
INSERT INTO #Account_Compliance_AM_temp  
    
SELECT DISTINCT    
  a.Parent_Accountid    
  ,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU,S.Project#  
  ,ISNULL(SUM(a.Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(b.ESA_FTE_Zero), 0)    
  ,ISNULL(SUM(c.ESA_FTE_0_25), 0)    
  ,ISNULL(SUM(d.ESA_FTE_25_50), 0)    
  ,ISNULL(SUM(e.ESA_FTE_50_80), 0)    
  ,ISNULL(SUM(f.ESA_FTE_80), 0)    
  ,ISNULL(SUM(a.Available_Hours), 0)    
  ,ISNULL(SUM(a.MPS_Effort), 0)   
  ,ISNULL(SUM(a.Work_Profile_AD), 0)  
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
 and a.Vertical=s.Vertical  and a.MarketUnitName=s.PracticeOwner  
  where A.Project_scope='AVM'  
 GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU,S.Project#    
  
  
CREATE table #Account_Compliance_AM  
(  
Parent_Accountid Char(15),  
Parent_AccountName varchar (100),  
Vertical varchar (50),  
MarketUnitName varchar(50),  
BU varchar(50),  
[AVM Project #] INT,  
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
Effort_Account_Compliance decimal (10,2),  
Associate_Compliance_Percent decimal (10,2)  
)  
--select * from #Account_Compliance_AD  
INSERT INTO #Account_Compliance_AM  
SELECT DISTINCT  
a.Parent_Accountid  
,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU,sum(a.[AVM Project #])  
,ISNULL(SUM(a.ESA_All_FTE), 0)  
,ISNULL(SUM(a.ESA_FTE_Zero), 0)  
,ISNULL(SUM(a.ESA_FTE_0_25), 0)  
,ISNULL(SUM(a.ESA_FTE_25_50), 0)  
,ISNULL(SUM(a.ESA_FTE_50_80), 0)  
,ISNULL(SUM(a.ESA_FTE_80), 0)  
,ISNULL(SUM(a.Available_Hours), 0)  
,ISNULL(SUM(a.MPS_Effort), 0)  
,ISNULL(SUM(a.Work_Profile_AD), 0)  
,ISNULL(SUM(a.MAS_Effort), 0)  
,ISNULL(SUM(a.Actual_Effort), 0)  
,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)  
,ISNULL(((ISNULL(SUM(a.ESA_FTE_80), 0)) / NULLIF(SUM(a.ESA_All_FTE), 0) * 100), 0)  
FROM #Account_Compliance_AM_temp A  
GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU  
  
 --AD Scope Account Compliance Split  
   
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,  
MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
INTO #Associate_Greater80_AD    
FROM #Associate_Total_account_Compliance  
WHERE [Associate_Account_Compliance] > 80  and Project_scope='AD'  
  
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_50_80_AD  
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80  and Project_scope='AD'  
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_25_50_AD    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50  and Project_scope='AD'  
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_0_25_AD   
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25  and Project_scope='AD'  
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_Zero_AD   
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] =0  and Project_scope='AD'  
  
CREATE TABLE #Associate_zero_AD   
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_Zero DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_zero_AD   
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_AD     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
    
  
    
CREATE table #Account_Compliance_AD_temp   
    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),   
MarketUnitName varchar(50),  
BU varchar(50),  
[AD Project #] INT,  
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
Effort_Account_Compliance decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #Account_Compliance_AD_temp  
--select * from #Account_Compliance_AD  where Parent_Accountid='2000559'  
  
SELECT DISTINCT    
  a.Parent_Accountid    
  ,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU , S.Project#  
  ,ISNULL(SUM(a.Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(b.ESA_FTE_Zero), 0)    
  ,ISNULL(SUM(c.ESA_FTE_0_25), 0)    
  ,ISNULL(SUM(d.ESA_FTE_25_50), 0)    
  ,ISNULL(SUM(e.ESA_FTE_50_80), 0)    
  ,ISNULL(SUM(f.ESA_FTE_80), 0)    
  ,ISNULL(SUM(a.Available_Hours), 0)    
  ,ISNULL(SUM(a.MPS_Effort), 0)   
  ,ISNULL(SUM(a.Work_Profile_AD), 0)  
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
 and a.Vertical=s.Vertical  and a.MarketUnitName=s.PracticeOwner  
 where A.Project_scope='AD'  
 GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU,S.Project#  
  
  
CREATE table #Account_Compliance_AD  
(  
Parent_Accountid Char(15),  
Parent_AccountName varchar (100),  
Vertical varchar (50),  
MarketUnitName varchar(50),  
BU varchar(50),  
[AD Project #] INT,  
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
Effort_Account_Compliance decimal (10,2),  
Associate_Compliance_Percent decimal (10,2)  
)  
  
INSERT INTO #Account_Compliance_AD  
SELECT DISTINCT  
a.Parent_Accountid  
,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU,sum(a.[AD Project #])  
,ISNULL(SUM(a.ESA_All_FTE), 0)  
,ISNULL(SUM(a.ESA_FTE_Zero), 0)  
,ISNULL(SUM(a.ESA_FTE_0_25), 0)  
,ISNULL(SUM(a.ESA_FTE_25_50), 0)  
,ISNULL(SUM(a.ESA_FTE_50_80), 0)  
,ISNULL(SUM(a.ESA_FTE_80), 0)  
,ISNULL(SUM(a.Available_Hours), 0)  
,ISNULL(SUM(a.MPS_Effort), 0)  
,ISNULL(SUM(a.Work_Profile_AD), 0)  
,ISNULL(SUM(a.MAS_Effort), 0)  
,ISNULL(SUM(a.Actual_Effort), 0)  
,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)  
,ISNULL(((ISNULL(SUM(a.ESA_FTE_80), 0)) / NULLIF(SUM(a.ESA_All_FTE), 0) * 100), 0)  
FROM #Account_Compliance_AD_temp A  
GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU  
  
--Integrated Account Compliance Split  
  
  
  
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,  
MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
INTO #Associate_Greater80_INTEG    
FROM #Associate_Total_account_Compliance  
WHERE [Associate_Account_Compliance] > 80  and Project_scope not in ('AD','AVM','')  
  
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_50_80_INTEG  
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80  and Project_scope not in ('AD','AVM','')  
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_25_50_INTEG    
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50  and Project_scope not in ('AD','AVM','')  
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_0_25_INTEG   
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25  and Project_scope not in ('AD','AVM','')  
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours  
,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_Zero_INTEG   
FROM #Associate_Total_account_Compliance    
WHERE [Associate_Account_Compliance] =0  and Project_scope not in ('AD','AVM','')  
  
CREATE TABLE #Associate_zero_INTEG   
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
EmployeeID varchar(15),    
ESA_FTE_Zero DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_zero_INTEG   
    
 SELECT DISTINCT    
  Parent_Accountid    
  ,Parent_AccountName    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_INTEG     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID    
    
  
    
CREATE table #Account_Compliance_INTEG_temp   
    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),   
MarketUnitName varchar(50),  
BU varchar(50),  
[INTEGRATED Project #] INT,  
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
Effort_Account_Compliance decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #Account_Compliance_INTEG_temp  
    
SELECT DISTINCT    
  a.Parent_Accountid    
  ,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU , S.Project#  
  ,ISNULL(SUM(a.Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(b.ESA_FTE_Zero), 0)    
  ,ISNULL(SUM(c.ESA_FTE_0_25), 0)    
  ,ISNULL(SUM(d.ESA_FTE_25_50), 0)    
  ,ISNULL(SUM(e.ESA_FTE_50_80), 0)    
  ,ISNULL(SUM(f.ESA_FTE_80), 0)    
  ,ISNULL(SUM(a.Available_Hours), 0)    
  ,ISNULL(SUM(a.MPS_Effort), 0)   
  ,ISNULL(SUM(a.Work_Profile_AD), 0)  
  ,ISNULL(SUM(a.MAS_Effort), 0)    
  ,ISNULL(SUM(a.Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(F.ESA_FTE_80), 0)) / NULLIF(SUM(a.Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_Total_account_Compliance A    
  
 LEFT JOIN #Associate_zero_INTEG B ON a.Parent_Accountid = b.Parent_Accountid AND A.EmployeeID = b.EmployeeID    
 LEFT JOIN #Associate_0_25_INTEG C ON a.Parent_Accountid = c.Parent_Accountid AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_25_50_INTEG D ON a.Parent_Accountid = d.Parent_Accountid AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_INTEG E ON a.Parent_Accountid = e.Parent_Accountid AND A.EmployeeID =e.EmployeeID    
 LEFT JOIN #Associate_80_INTEG F ON a.Parent_Accountid = f.Parent_Accountid AND A.EmployeeID = f.EmployeeID     
  left join #ScopeProject S on A.Parent_Accountid =S.Parent_Accountid and A.Project_scope=S.ProjectScope  
  and a.Vertical=s.Vertical  and a.MarketUnitName=s.PracticeOwner  
 where A.Project_scope not in ('AD','AVM','')  
 GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU,S.Project#  
  
  
CREATE table #Account_Compliance_INTEG  
(  
Parent_Accountid Char(15),  
Parent_AccountName varchar (100),  
Vertical varchar (50),  
MarketUnitName varchar(50),  
BU varchar(50),  
[INTEGRATED Project #] INT,  
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
Effort_Account_Compliance decimal (10,2),  
Associate_Compliance_Percent decimal (10,2)  
)  
--select * from #Account_Compliance_INTEG_temp  
INSERT INTO #Account_Compliance_INTEG  
  
SELECT DISTINCT  
a.Parent_Accountid  
,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU,sum(a.[INTEGRATED Project #])  
,ISNULL(SUM(a.ESA_All_FTE), 0)  
,ISNULL(SUM(a.ESA_FTE_Zero), 0)  
,ISNULL(SUM(a.ESA_FTE_0_25), 0)  
,ISNULL(SUM(a.ESA_FTE_25_50), 0)  
,ISNULL(SUM(a.ESA_FTE_50_80), 0)  
,ISNULL(SUM(a.ESA_FTE_80), 0)  
,ISNULL(SUM(a.Available_Hours), 0)  
,ISNULL(SUM(a.MPS_Effort), 0)  
,ISNULL(SUM(a.Work_Profile_AD), 0)  
,ISNULL(SUM(a.MAS_Effort), 0)  
,ISNULL(SUM(a.Actual_Effort), 0)  
,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)  
,ISNULL(((ISNULL(SUM(a.ESA_FTE_80), 0)) / NULLIF(SUM(a.ESA_All_FTE), 0) * 100), 0)  
FROM #Account_Compliance_INTEG_temp A  
GROUP BY a.Parent_Accountid,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU  
  
 --Account compliance for all scope.  
  
  
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
  
----select * from  #Associate_Accountcompliance a  
--JOIN [Adp].[Input_Data_AssociateRAW] C ON a.EsaProjectID=C.EsaProjectID   
  
INSERT INTO  #Associate_Accountcompliance_all    
    
SELECT  DISTINCT A.Parent_Accountid,A.Parent_AccountName,A.Vertical,C.PracticeOwner,C.MARKET_BU,A.EmployeeID,A.Department_Name,  
sum(A.Avaialble_FTE_Below_M),sum(A.Available_Hours),    
sum(A.MPS_Effort),sum(A.Work_Profile_AD),Sum(A.MAS_Effort),sum(A.Actual_Effort),ISNULL(((SUM(A.Actual_Effort)) / NULLIF(SUM(A.Available_Hours),0) * 100), 0)   
from #AssociateActual_Final A    
JOIN [Adp].[Input_Data_AssociateRAW] C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'  --and Parent_Accountid='2000004'  
Group by  A.Parent_Accountid,A.Parent_AccountName,A.Vertical,A.EmployeeID,A.Department_Name,C.PracticeOwner,C.MARKET_BU  
  
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
  ,Parent_AccountName,Vertical,  
  MarketUnitName,BU,  
  EmployeeID    
  ,SUM(Avaialble_FTE_Below_M)    
  ,SUM(Available_Hours)    
  ,SUM(MPS_Effort)  
  ,SUM(Work_Profile_AD)  
  ,SUM(MAS_Effort)    
  ,SUM(Actual_Effort)    
  ,sum(Associate_Account_Compliance)   
 FROM #Associate_Accountcompliance_all   
 GROUP BY Parent_Accountid    
    ,Parent_AccountName,Vertical,MarketUnitName,BU, EmployeeID   
  
     
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater80    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] > 80    
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_50_80    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] > 50 and Associate_Account_Compliance  <=80    
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_25_50    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] > 25 and Associate_Account_Compliance  <=50    
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_0_25    
FROM #Associate_Total_account_Compliance_all    
WHERE [Associate_Account_Compliance] >0 and Associate_Account_Compliance  <=25    
    
SELECT DISTINCT Parent_Accountid,Parent_AccountName,Vertical,MarketUnitName,BU,EmployeeID,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_Account_Compliance    
 INTO #Associate_Greater_Zero    
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
  ,EmployeeID ,Vertical   
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,EmployeeID,Vertical    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
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
  ,EmployeeID  ,Vertical  
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50   
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID  ,Vertical  
    
    
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
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80   
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID ,Vertical   
    
    
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
  ,EmployeeID ,Vertical   
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80     
 GROUP BY Parent_Accountid    
    ,Parent_AccountName    
    ,EmployeeID,Vertical    
    
  
    
CREATE table #Account_Compliance    
    
(    
    
Parent_Accountid Char(15),    
Parent_AccountName varchar (100),    
Vertical varchar (50),   
MarketUnitName varchar(50),  
BU varchar(50),  
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
Effort_Account_Compliance decimal (10,2),    
Associate_Compliance_Percent decimal (10,2)    
)    
    
    
INSERT INTO #Account_Compliance    
    
SELECT DISTINCT    
  a.Parent_Accountid    
  ,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU   
  ,ISNULL(SUM(a.Avaialble_FTE_Below_M), 0)    
  ,ISNULL(SUM(b.ESA_FTE_Zero), 0)    
  ,ISNULL(SUM(c.ESA_FTE_0_25), 0)    
  ,ISNULL(SUM(d.ESA_FTE_25_50), 0)    
  ,ISNULL(SUM(e.ESA_FTE_50_80), 0)    
  ,ISNULL(SUM(f.ESA_FTE_80), 0)    
  ,ISNULL(SUM(a.Available_Hours), 0)    
  ,ISNULL(SUM(a.MPS_Effort), 0)   
  ,ISNULL(SUM(a.Work_Profile_AD), 0)  
  ,ISNULL(SUM(a.MAS_Effort), 0)    
  ,ISNULL(SUM(a.Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(a.Actual_Effort), 0)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(F.ESA_FTE_80), 0)) / NULLIF(SUM(a.Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_Total_account_Compliance_all A    
  
 LEFT JOIN #Associate_zero B ON a.Parent_Accountid = b.Parent_Accountid AND A.EmployeeID = b.EmployeeID and a.Vertical=b.Vertical  
 LEFT JOIN #Associate_0_25 C ON a.Parent_Accountid = c.Parent_Accountid AND A.EmployeeID = c.EmployeeID and a.Vertical=c.Vertical   
 LEFT JOIN #Associate_25_50 D ON a.Parent_Accountid = d.Parent_Accountid AND A.EmployeeID = d.EmployeeID  and a.Vertical=d.Vertical  
 LEFT JOIN #Associate_50_80 E ON a.Parent_Accountid = e.Parent_Accountid AND A.EmployeeID =e.EmployeeID and a.Vertical=e.Vertical   
 LEFT JOIN #Associate_80 F ON a.Parent_Accountid = f.Parent_Accountid AND A.EmployeeID = f.EmployeeID  and a.Vertical=f.Vertical   
   
 GROUP BY a.Parent_Accountid    
    ,a.Parent_AccountName,A.Vertical,A.MarketUnitName,A.BU    
  
  
TRUNCATE table [Adp].[Account_Compliance]  
    
INSERT INTO [Adp].[Account_Compliance]  
    
    
SELECT DISTINCT    
 Parent_Accountid    
 ,Parent_AccountName    
 ,Vertical,  
 MarketUnitName,BU  
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
 ,Effort_Account_Compliance    
 ,Associate_Compliance_Percent    
FROM #Account_Compliance   
    
  
TRUNCATE table [Adp].Account_Compliance_AD   
    
INSERT INTO [Adp].Account_Compliance_AD    
  
--select * from [dbo].Adp_Account_Compliance_AD where Parent_Accountid='2000559'  
    
    
SELECT DISTINCT    
 Parent_Accountid    
 ,Parent_AccountName    
 ,Vertical,  
 MarketUnitName,BU,[AD Project #]  
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
 ,Effort_Account_Compliance    
 ,Associate_Compliance_Percent    
FROM #Account_Compliance_AD   
  
  
  
TRUNCATE table [Adp].Account_Compliance_AM    
    
INSERT INTO [Adp].Account_Compliance_AM    
    
    
SELECT DISTINCT    
 Parent_Accountid    
 ,Parent_AccountName    
 ,Vertical,  
 MarketUnitName,BU,[AVM Project #]  
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
 ,Effort_Account_Compliance    
 ,Associate_Compliance_Percent    
FROM #Account_Compliance_AM   
  
  
TRUNCATE table [Adp].Account_Compliance_INTEG    
    
INSERT INTO [Adp].Account_Compliance_INTEG    
    
    
SELECT DISTINCT    
 Parent_Accountid    
 ,Parent_AccountName    
 ,Vertical,  
 MarketUnitName,BU,[INTEGRATED Project #]  
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
 ,Effort_Account_Compliance    
 ,Associate_Compliance_Percent    
FROM #Account_Compliance_INTEG   
    
CREATE Table #Associate_BUcompliance    
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
  
    
    
INSERT INTO #Associate_BUcompliance    
    
SELECT DISTINCT a.SBU,a.EmployeeID,a.Department_Name,C.PROJECTSCOPE ,sum(a.Avaialble_FTE_Below_M),sum(a.Available_Hours),    
sum(a.MPS_Effort),sum(a.Work_Profile_AD),Sum(a.MAS_Effort),sum(a.Actual_Effort),ISNULL(((SUM(a.Actual_Effort)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0) from #AssociateActual_Final A    
JOIN [Adp].[Input_Data_AssociateRAW] C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'    
GROUP BY SBU,EmployeeID,Department_Name,C.PROJECTSCOPE  
    
  
select A.SBU,C.ProjectScope,count(A.EsaProjectID) as 'Project#' Into #ScopeBU from #AssociateActual_Final A  
JOIN [Adp].[Input_Data_AssociateRAW] C ON A.parent_accountid=C.parentaccountid and a.EsaProjectID=C.EsaProjectID     
group by A.SBU,C.ProjectScope  
    
    
TRUNCATE table [Adp].SBU_Compliance_RAW    
INSERT INTO   [Adp].SBU_Compliance_RAW     
SELECT DISTINCT  SBU ,    
EmployeeID ,    
Department_Name ,    
Avaialble_FTE_Below_M ,    
Available_Hours ,    
MPS_Effort ,    
Work_Profile_AD,  
MAS_Effort ,    
Actual_Effort ,    
Associate_BU_Compliance   from #Associate_BUcompliance    
  
--AVM SCOPE BU COmpliance  
  
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater80_SBU_AVM    
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] > 80  and Project_Scope='AVM'  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_50_80_SBU_AVM    
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80 and Project_Scope='AVM'  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_25_50_SBU_AVM    
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50  and Project_Scope='AVM'  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_0_25_SBU_AVM    
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25  and Project_Scope='AVM'  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_zero_SBU_AVM    
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] =0  and Project_Scope='AVM'  
    
  
CREATE TABLE #Associate_80_SBU_AVM    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_SBU_AVM    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_SBU_AVM    
 GROUP BY SBU    
    ,EmployeeID    
    
  
    
CREATE TABLE #Associate_50_80_SBU_AVM    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_SBU_AVM    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80_SBU_AVM    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_25_50_SBU_AVM    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_SBU_AVM    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50_SBU_AVM    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_25_SBU_AVM    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_SBU_AVM    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_0_25_SBU_AVM    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_SBU_AVM    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_SBU_AVM    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_Zero_SBU_AVM    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE table #SBU_Compliance_AVM    
    
(    
SBU varchar (50),    
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
  ,ISNULL(SUM(Work_Profile_AD), 0)  
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)   
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_BUcompliance A    
 LEFT JOIN #Associate_0_SBU_AVM F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_SBU_AVM E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_SBU_AVM D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_SBU_AVM C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_SBU_AVM B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
  where A.Project_scope='AVM'   
  
 GROUP BY a.SBU    
    
    
SELECT DISTINCT SBU,ESA_FTE,ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,Available_Hours,    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,    
BU_Effort_Compliance_Percent,    
Associate_Compliance_Percent    
INTO #BUDATA_AVM    
FROM #SBU_Compliance_AVM    
  
  
INSERT INTO #SBU_Compliance_AVM    
    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]    
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
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'    
    
 FROM #BUDATA_AVM      
  
TRUNCATE table [Adp].SBU_Compliance_AM    
    
INSERT INTO [Adp].SBU_Compliance_AM  
    
SELECT    
 [SBU] AS 'SBU'    
 ,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,BU_Effort_Compliance_Percent AS [BU Effort Compliance%(All)]    
 ,Associate_Compliance_Percent AS [Associate_BU_Compliance%]    
FROM #SBU_Compliance_AVM    
ORDER BY CASE   WHEN [SBU] = 'GRAND TOTAL' THEN 1    
 ELSE 0    
END, [SBU]    
  
 -- AD Scope BU Compliance  
  
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater80_SBU_AD    
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] > 80  and Project_Scope='AD'  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_50_80_SBU_AD    
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80 and Project_Scope='AD'  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_25_50_SBU_AD    
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50  and Project_Scope='AD'  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_0_25_SBU_AD    
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25  and Project_Scope='AD'  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_zero_SBU_AD    
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] =0  and Project_Scope='AD'  
    
  
CREATE TABLE #Associate_80_SBU_AD    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_SBU_AD    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_SBU_AD    
 GROUP BY SBU    
    ,EmployeeID    
    
  
    
CREATE TABLE #Associate_50_80_SBU_AD    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_SBU_AD    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80_SBU_AD    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_25_50_SBU_AD    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_SBU_AD    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50_SBU_AD    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_25_SBU_AD    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_SBU_AD    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_0_25_SBU_AD   
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_SBU_AD    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_SBU_AD  
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_Zero_SBU_AD  
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE table #SBU_Compliance_AD    
    
(    
SBU varchar (50),    
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
    
    
INSERT INTO #SBU_Compliance_AD  
    
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
  ,ISNULL(SUM(Work_Profile_AD), 0)  
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_BUcompliance A    
 LEFT JOIN #Associate_0_SBU_AD F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_SBU_AD E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_SBU_AD D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_SBU_AD C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_SBU_AD B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
  where A.Project_scope='AD'   
  
 GROUP BY a.SBU    
    
    
SELECT DISTINCT SBU,ESA_FTE,ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,Available_Hours,    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,    
BU_Effort_Compliance_Percent,    
Associate_Compliance_Percent    
INTO #BUDATA_AD    
FROM #SBU_Compliance_AD    
  
  
INSERT INTO #SBU_Compliance_AD    
    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]    
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
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'    
    
 FROM #BUDATA_AD      
  
TRUNCATE table [Adp].SBU_Compliance_AD    
    
INSERT INTO [Adp].SBU_Compliance_AD  
    
SELECT    
 [SBU] AS 'SBU'    
 ,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,BU_Effort_Compliance_Percent AS [BU Effort Compliance%(All)]    
 ,Associate_Compliance_Percent AS [Associate_BU_Compliance%]    
FROM #SBU_Compliance_AD    
ORDER BY CASE   WHEN [SBU] = 'GRAND TOTAL' THEN 1    
 ELSE 0    
END, [SBU]    
  
  
 -- INTEG Scope BU Compliance  
  
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater80_SBU_INTEG    
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] > 80  and Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_50_80_SBU_INTEG     
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80 and Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_25_50_SBU_INTEG     
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50  and Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_0_25_SBU_INTEG     
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25  and Project_Scope not in ('AD','AVM','')  
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_zero_SBU_INTEG     
FROM #Associate_BUcompliance    
WHERE [Associate_BU_Compliance] =0  and Project_Scope not in ('AD','AVM','')  
    
  
CREATE TABLE #Associate_80_SBU_INTEG    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_SBU_INTEG    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_SBU_INTEG    
 GROUP BY SBU    
    ,EmployeeID    
    
  
    
CREATE TABLE #Associate_50_80_SBU_INTEG    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_SBU_INTEG    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80_SBU_INTEG    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_25_50_SBU_INTEG    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_SBU_INTEG    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50_SBU_INTEG    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_25_SBU_INTEG    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_SBU_INTEG    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_0_25_SBU_INTEG   
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_SBU_INTEG    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_SBU_INTEG  
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_Zero_SBU_INTEG  
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE table #SBU_Compliance_INTEG    
    
(    
SBU varchar (50),    
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
    
    
INSERT INTO #SBU_Compliance_INTEG  
    
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
  ,ISNULL(SUM(Work_Profile_AD), 0)  
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_BUcompliance A    
 LEFT JOIN #Associate_0_SBU_INTEG F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_SBU_INTEG E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_SBU_INTEG D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_SBU_INTEG C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_SBU_INTEG B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
  where A.Project_scope not in ('AD','AVM','')  
  
 GROUP BY a.SBU    
    
    
SELECT DISTINCT SBU,ESA_FTE,ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,Available_Hours,    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,    
BU_Effort_Compliance_Percent,    
Associate_Compliance_Percent    
INTO #BUDATA_INTEG    
FROM #SBU_Compliance_INTEG    
  
  
INSERT INTO #SBU_Compliance_INTEG    
    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]    
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
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'    
    
 FROM #BUDATA_INTEG      
  
TRUNCATE table [Adp].SBU_Compliance_INTEG    
    
INSERT INTO [Adp].SBU_Compliance_INTEG    
    
SELECT    
 [SBU] AS 'SBU'    
 ,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,BU_Effort_Compliance_Percent AS [BU Effort Compliance%(All)]    
 ,Associate_Compliance_Percent AS [Associate_BU_Compliance%]    
FROM #SBU_Compliance_INTEG    
ORDER BY CASE   WHEN [SBU] = 'GRAND TOTAL' THEN 1    
 ELSE 0    
END, [SBU]    
  
  
CREATE Table #Associate_BUcompliance_all    
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
  
    
    
INSERT INTO #Associate_BUcompliance_all    
    
SELECT DISTINCT a.SBU,a.EmployeeID,a.Department_Name ,sum(a.Avaialble_FTE_Below_M),sum(a.Available_Hours),    
sum(a.MPS_Effort),sum(a.Work_Profile_AD),Sum(a.MAS_Effort),sum(a.Actual_Effort),ISNULL(((SUM(a.Actual_Effort)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0) from #AssociateActual_Final A    
JOIN [Adp].[Input_Data_AssociateRAW] C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'    
GROUP BY SBU,EmployeeID,Department_Name  
  
  
--All Scope BU Compliance    
  
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater80_SBU    
FROM #Associate_BUcompliance_all    
WHERE [Associate_BU_Compliance] > 80    
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_50_80_SBU    
FROM #Associate_BUcompliance_all    
WHERE [Associate_BU_Compliance] > 50 and [Associate_BU_Compliance]  <=80    
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_25_50_SBU    
FROM #Associate_BUcompliance_all    
WHERE [Associate_BU_Compliance] >  25 and [Associate_BU_Compliance]  <=50    
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_0_25_SBU    
FROM #Associate_BUcompliance_all    
WHERE [Associate_BU_Compliance]  >0 and [Associate_BU_Compliance]  <=25    
    
SELECT DISTINCT SBU,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_BU_Compliance    
 INTO #Associate_Greater_zero_SBU    
FROM #Associate_BUcompliance_all    
WHERE [Associate_BU_Compliance] =0    
    
  
CREATE TABLE #Associate_80_SBU    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_SBU    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_SBU    
 GROUP BY SBU    
    ,EmployeeID    
    
  
    
CREATE TABLE #Associate_50_80_SBU    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_SBU    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80_SBU    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_25_50_SBU    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_SBU    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50_SBU    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_25_SBU    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_SBU    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_0_25_SBU    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_SBU    
(    
    
SBU varchar (50),    
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_SBU    
    
 SELECT DISTINCT    
  SBU    
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_Zero_SBU    
 GROUP BY SBU    
    ,EmployeeID    
    
    
CREATE table #SBU_Compliance    
    
(    
SBU varchar (50),    
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
    
    
INSERT INTO #SBU_Compliance    
    
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
  ,ISNULL(SUM(Work_Profile_AD), 0)  
  ,ISNULL(SUM(MAS_Effort), 0)    
  ,ISNULL(SUM(Actual_Effort), 0)    
  ,ISNULL(((ISNULL(SUM(Actual_Effort), 0)) / NULLIF(SUM(Available_Hours), 0) * 100), 0)    
  ,ISNULL(((ISNULL(SUM(ESA_FTE_80_BU), 0)) / NULLIF(SUM(Avaialble_FTE_Below_M), 0) * 100), 0)    
 FROM #Associate_BUcompliance_all A    
 LEFT JOIN #Associate_0_SBU F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_SBU E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_SBU D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_SBU C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_SBU B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
     
  
 GROUP BY a.SBU    
    
    
SELECT DISTINCT SBU,ESA_FTE,ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,Available_Hours,    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,    
BU_Effort_Compliance_Percent,    
Associate_Compliance_Percent    
INTO #BUDATA    
FROM #SBU_Compliance    
    
  
    
INSERT INTO #SBU_Compliance    
    
 SELECT DISTINCT    
  'GRAND TOTAL' AS [SBU]    
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
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'    
    
 FROM #BUDATA      
  
TRUNCATE table [Adp].SBU_Compliance    
    
INSERT INTO [Adp].SBU_Compliance    
    
SELECT    
 [SBU] AS 'SBU'    
 ,ESA_FTE, ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80    
 ,Available_Hours    
 ,MPS_Effort    
 ,Work_Profile_AD  
 ,MAS_Effort    
 ,Actual_Effort    
 ,BU_Effort_Compliance_Percent AS [BU Effort Compliance%(All)]    
 ,Associate_Compliance_Percent AS [Associate_BU_Compliance%]    
FROM #SBU_Compliance    
ORDER BY CASE   WHEN [SBU] = 'GRAND TOTAL' THEN 1    
 ELSE 0    
END, [SBU]    
    
   
CREATE Table #Associate_VERTICALcompliance    
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
  
    
 INSERT INTO #Associate_VERTICALcompliance    
  
 SELECT DISTINCT A.SBU,a.Vertical,a.EmployeeID,a.Department_Name ,C.PROJECTSCOPE,sum(a.Avaialble_FTE_Below_M),sum(a.Available_Hours),    
sum(a.MPS_Effort),sum(a.Work_Profile_AD),Sum(a.MAS_Effort),sum(a.Actual_Effort),ISNULL(((SUM(a.Actual_Effort)) / NULLIF(SUM(a.Available_Hours), 0) * 100), 0) from #AssociateActual_Final A    
JOIN [Adp].[Input_Data_AssociateRAW] C ON a.EsaProjectID=C.EsaProjectID     
where C.DE_Inscope='In scope'    
GROUP BY sbu,Vertical,EmployeeID,Department_Name ,C.PROJECTSCOPE   
  
  
TRUNCATE table [Adp].VERTICAL_Compliance_RAW    
INSERT INTO   [Adp].VERTICAL_Compliance_RAW     
SELECT DISTINCT SBU ,  
VERTICAL,  
EmployeeID ,    
Department_Name ,    
Avaialble_FTE_Below_M ,    
Available_Hours ,    
MPS_Effort ,  
Work_Profile_AD,  
MAS_Effort ,    
Actual_Effort ,    
Associate_VERTICAL_Compliance   from #Associate_VERTICALcompliance  
  
  
--AD Scope Vertical  
  
SELECT DISTINCT SBU,vERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater80_VERTICAL_AD    
FROM #Associate_VERTICALcompliance    
WHERE [Associate_VERTICAL_Compliance] > 80  and Project_Scope='AD'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_50_80_VERTICAL_AD   
FROM #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance > 50 and Associate_VERTICAL_Compliance  <=80  and Project_Scope='AD'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_25_50_VERTICAL_AD   
FROM #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance >  25 and Associate_VERTICAL_Compliance  <=50  and Project_Scope='AD'  
    
--select * from #Associate_Greater_25_50_VERTICAL   
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance   
 INTO #Associate_Greater_0_25_VERTICAL_AD    
FROM  #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance  >0 and Associate_VERTICAL_Compliance  <=25  and Project_Scope='AD'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_zero_VERTICAL_AD   
FROM  #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance =0  and Project_Scope='AD'  
  
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
 FROM #Associate_Greater_Zero_VERTICAL_AD    
 GROUP BY SBU  , VERTICAL  
    ,EmployeeID    
    
    
  CREATE table #VERTICAL_Compliance_AD    
    
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
    
    
INSERT INTO #VERTICAL_Compliance_AD    
    
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
 FROM #Associate_VERTICALcompliance A    
 LEFT JOIN #Associate_0_VERTICAL_AD F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_VERTICAL_AD E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_VERTICAL_AD D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_VERTICAL_AD C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_VERTICAL_AD B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
where A.Project_Scope='AD'     
  
 GROUP BY a.SBU  ,A.VERTICAL  
    
    
SELECT DISTINCT SBU,VERTICAL,ESA_FTE,ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,Available_Hours,    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,    
VERTICAL_Effort_Compliance_Percent,    
Associate_Compliance_Percent    
INTO #VERTICALDATA_AD    
FROM #VERTICAL_Compliance_AD    
--order by sbu  
  
  
  
INSERT INTO #VERTICAL_Compliance_AD   
    
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
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS'Work_Profile_AD'  
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'    
    
FROM #VERTICALDATA_AD  --group by vertical  
  
 TRUNCATE table [Adp].VERTICAL_Compliance_AD   
    
INSERT INTO [Adp].VERTICAL_Compliance_AD   
    
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
FROM #VERTICAL_Compliance_AD    
ORDER BY CASE    
 WHEN SBU = 'GRAND TOTAL' THEN 1    
    
 ELSE 0    
END, [SBU]    
  
    
--AVM SCOPE VERTICAL  
  
SELECT DISTINCT SBU,vERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater80_VERTICAL_AVM    
FROM #Associate_VERTICALcompliance    
WHERE [Associate_VERTICAL_Compliance] > 80  and Project_Scope='AVM'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_50_80_VERTICAL_AVM   
FROM #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance > 50 and Associate_VERTICAL_Compliance  <=80  and Project_Scope='AVM'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_25_50_VERTICAL_AVM   
FROM #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance >  25 and Associate_VERTICAL_Compliance  <=50  and Project_Scope='AVM'  
    
--select * from #Associate_Greater_25_50_VERTICAL   
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_0_25_VERTICAL_AVM    
FROM  #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance  >0 and Associate_VERTICAL_Compliance  <=25  and Project_Scope='AVM'  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_zero_VERTICAL_AVM   
FROM  #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance =0  and Project_Scope='AVM'  
  
CREATE TABLE #Associate_80_VERTICAL_AVM   
(    
    
SBU varchar (50),   
VERTICAL varchar (50),   
EmployeeID varchar(15),    
ESA_FTE_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_80_VERTICAL_AVM    
    
 SELECT DISTINCT    
  SBU  , VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater80_VERTICAL_AVM    
 GROUP BY SBU  , VERTICAL  
    ,EmployeeID    
    
  
    
CREATE TABLE #Associate_50_80_VERTICAL_AVM   
(    
    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
EmployeeID varchar(15),    
ESA_FTE_50_80_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_50_80_VERTICAL_AVM  
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_50_80_VERTICAL_AVM    
 GROUP BY SBU ,VERTICAL   
    ,EmployeeID    
    
    
CREATE TABLE #Associate_25_50_VERTICAL_AVM    
(    
    
SBU varchar (50),    
VERTICAL varchar (50),  
EmployeeID varchar(15),    
ESA_FTE_25_50_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_25_50_VERTICAL_AVM    
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_25_50_VERTICAL_AVM  
 GROUP BY SBU  ,VERTICAL  
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_25_VERTICAL_AVM  
(    
    
SBU varchar (50),   
VERTICAL varchar (50),  
EmployeeID varchar(15),    
ESA_FTE_0_25_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_25_VERTICAL_AVM    
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_0_25_VERTICAL_AVM   
 GROUP BY SBU  ,VERTICAL  
    ,EmployeeID    
    
    
CREATE TABLE #Associate_0_VERTICAL_AVM   
(    
    
SBU varchar (50),    
VERTICAL VARCHAR(50),  
EmployeeID varchar(15),    
ESA_FTE_0_BU DECIMAL(10,2) NULL    
    
)    
    
INSERT INTO #Associate_0_VERTICAL_AVM   
    
 SELECT DISTINCT    
  SBU  ,VERTICAL  
  ,EmployeeID    
  ,SUM(Avaialble_FTE_Below_M) AS 'Associate_Greater>80%'    
 FROM #Associate_Greater_Zero_VERTICAL_AVM    
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
 FROM #Associate_VERTICALcompliance A    
 LEFT JOIN #Associate_0_VERTICAL_AVM F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_VERTICAL_AVM E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_VERTICAL_AVM D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_VERTICAL_AVM C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_VERTICAL_AVM B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
where A.Project_Scope='AVM'     
  
 GROUP BY a.SBU  ,A.VERTICAL  
    
    
SELECT DISTINCT SBU,VERTICAL,ESA_FTE,ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,Available_Hours,    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,    
VERTICAL_Effort_Compliance_Percent,    
Associate_Compliance_Percent    
INTO #VERTICALDATA_AVM    
FROM #VERTICAL_Compliance_AVM  
  
  
  
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
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS'Work_Profile_AD'  
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'    
    
FROM #VERTICALDATA_AVM  --group by vertical  
  
 TRUNCATE table [Adp].VERTICAL_Compliance_AM    
    
INSERT INTO [Adp].VERTICAL_Compliance_AM   
    
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
  
  
--INTEGRATED SCOPE VERTICAL  
  
SELECT DISTINCT SBU,vERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater80_VERTICAL_INTEG    
FROM #Associate_VERTICALcompliance    
WHERE [Associate_VERTICAL_Compliance] > 80  and Project_Scope NOT IN ('AD','AVM','')  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_50_80_VERTICAL_INTEG   
FROM #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance > 50 and Associate_VERTICAL_Compliance  <=80  and Project_Scope NOT IN ('AD','AVM','')  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_25_50_VERTICAL_INTEG   
FROM #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance >  25 and Associate_VERTICAL_Compliance  <=50  and Project_Scope NOT IN ('AD','AVM','')  
    
--select * from #Associate_Greater_25_50_VERTICAL   
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_0_25_VERTICAL_INTEG    
FROM  #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance  >0 and Associate_VERTICAL_Compliance  <=25  and Project_Scope NOT IN ('AD','AVM','')  
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_zero_VERTICAL_INTEG   
FROM  #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance =0  and Project_Scope NOT IN ('AD','AVM','')  
  
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
 FROM #Associate_Greater_Zero_VERTICAL_INTEG    
 GROUP BY SBU  , VERTICAL  
    ,EmployeeID    
    
    
  CREATE table #VERTICAL_Compliance_INTEG    
    
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
    
    
INSERT INTO #VERTICAL_Compliance_INTEG    
    
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
 FROM #Associate_VERTICALcompliance A    
 LEFT JOIN #Associate_0_VERTICAL_INTEG F ON a.SBU = f.SBU AND A.EmployeeID = f.EmployeeID    
 LEFT JOIN #Associate_0_25_VERTICAL_INTEG E ON a.SBU = e.SBU AND A.EmployeeID = e.EmployeeID    
 LEFT JOIN #Associate_25_50_VERTICAL_INTEG D ON a.SBU = d.SBU AND A.EmployeeID = d.EmployeeID    
 LEFT JOIN #Associate_50_80_VERTICAL_INTEG C ON a.SBU = c.SBU AND A.EmployeeID = c.EmployeeID    
 LEFT JOIN #Associate_80_VERTICAL_INTEG B ON a.SBU = b.SBU AND A.EmployeeID = b.EmployeeID    
where A.Project_Scope NOT IN ('AD','AVM','')     
  
 GROUP BY a.SBU  ,A.VERTICAL  
    
    
SELECT DISTINCT SBU,VERTICAL,ESA_FTE,ESA_FTE_Zero,ESA_FTE_0_25,ESA_FTE_25_50,ESA_FTE_50_80,ESA_FTE_80,Available_Hours,    
MPS_Effort,Work_Profile_AD,MAS_Effort,    
Actual_Effort,    
VERTICAL_Effort_Compliance_Percent,    
Associate_Compliance_Percent    
INTO #VERTICALDATA_INTEG    
FROM #VERTICAL_Compliance_INTEG  
  
  
INSERT INTO #VERTICAL_Compliance_INTEG    
    
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
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS'Work_Profile_AD'  
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'    
    
FROM #VERTICALDATA_INTEG  --group by vertical  
  
 TRUNCATE table [Adp].VERTICAL_Compliance_INTEG    
    
INSERT INTO [Adp].VERTICAL_Compliance_INTEG    
    
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
FROM #VERTICAL_Compliance_INTEG    
ORDER BY CASE    
 WHEN SBU = 'GRAND TOTAL' THEN 1    
    
 ELSE 0    
END, [SBU]    
  
  
 --All Scopr Vertical  
  
  
SELECT DISTINCT SBU,vERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater80_VERTICAL    
FROM #Associate_VERTICALcompliance    
WHERE [Associate_VERTICAL_Compliance] > 80    
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_50_80_VERTICAL   
FROM #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance > 50 and Associate_VERTICAL_Compliance  <=80    
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_25_50_VERTICAL   
FROM #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance >  25 and Associate_VERTICAL_Compliance  <=50    
    
--select * from #Associate_Greater_25_50_VERTICAL   
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_0_25_VERTICAL    
FROM  #Associate_VERTICALcompliance    
WHERE Associate_VERTICAL_Compliance  >0 and Associate_VERTICAL_Compliance  <=25    
    
SELECT DISTINCT SBU,VERTICAL,EmployeeID,Department_Name,Avaialble_FTE_Below_M,Available_Hours,MPS_Effort,Work_Profile_AD,MAS_Effort,Actual_Effort,Associate_VERTICAL_Compliance    
 INTO #Associate_Greater_zero_VERTICAL   
FROM  #Associate_VERTICALcompliance    
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
    
    
  CREATE table #VERTICAL_Compliance    
    
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
    
    
INSERT INTO #VERTICAL_Compliance    
    
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
 FROM #Associate_VERTICALcompliance A    
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
INTO #VERTICALDATA    
FROM #VERTICAL_Compliance    
--order by sbu  
    
  
    
INSERT INTO #VERTICAL_Compliance    
    
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
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS'Work_Profile_AD'  
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)), 0) * 100,0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)), 0) * 100,0) AS 'Associate_Compliance'    
    
FROM #VERTICALDATA  --group by vertical  
  
  
INSERT INTO #VERTICAL_Compliance    
    
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
  ,SUM(CONVERT(DECIMAL(10,2), Work_Profile_AD)) AS'Work_Profile_AD'  
  ,SUM(CONVERT(DECIMAL(10,2), MAS_Effort)) AS 'MAS_Effort'    
  ,SUM(CONVERT(DECIMAL(10,2), Actual_Effort)) AS 'Actual_Effort'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), Actual_Effort)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), Available_Hours)) * 100, 0),0) AS 'BU_Effort_Compliance'    
  ,ISNULL(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE_80)) / NULLIF(SUM(CONVERT(DECIMAL(10, 2), ESA_FTE)) * 100, 0),0) AS 'Associate_Compliance'    
    
FROM #VERTICALDATA  --group by vertical  
  
 TRUNCATE table [Adp].VERTICAL_Compliance    
    
INSERT INTO [Adp].VERTICAL_Compliance    
    
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
FROM #VERTICAL_Compliance    
ORDER BY CASE    
 WHEN SBU = 'GRAND TOTAL' THEN 1    
    
 ELSE 0    
END, [SBU]    
  
  
TRUNCATE table [Adp].Project_Compliance    
    
INSERT INTO [Adp].Project_Compliance    
    
    
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
 ,Actual_Effort,    
 Effort_Project_Compliance_percent    
 ,Associate_Project_Compliance_Percent    
FROM #Project_Compliance  
  
  
  
  
  
DROP TABLE #WeekDays  
DROP TABLE #Associate_Applens  
DROP TABLE #FTE_GRT  
DROP TABLE #Associate_WeekDays  
DROP TABLE #Associate_diff  
DROP TABLE #FTE_Cal  
DROP TABLE #FTE_Final  
DROP TABLE #FTE_count  
DROP TABLE #FTE_ENDATE  
DROP TABLE #Associate_endate_WeekDays  
DROP TABLE #Associate__endate_diff  
DROP TABLE #FTE_endate_Cal  
DROP TABLE #FTE_End_Final  
DROP TABLE #FTE_BM  
DROP TABLE #Associalte_FinalAllocation  
DROP TABLE #Temp_Applens  
DROP TABLE #Temp_BM_Applns  
DROP TABLE #Associalte_Final_All  
--DROP TABLE #tmp_DPT  
--DROP TABLE #tmp_DSG  
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
DROP TABLE #AssociateActual_Final  
DROP TABLE #Associate_Projectcompliance  
DROP TABLE #Associate_Total_project_Compliance  
DROP TABLE #Associate_Greater80_Prj  
DROP TABLE #Associate_Greater_50_80_Prj  
DROP TABLE #Associate_Greater_25_50_prj  
DROP TABLE #Associate_Greater_0_25_prj  
DROP TABLE #Associate_Greater_Zero_prj  
DROP TABLE #Associate_zero_prj  
DROP TABLE #Associate_0_25_prj  
DROP TABLE #Associate_25_50_prj  
DROP TABLE #Associate_50_80_Prj  
DROP TABLE #Associate_80_Prj  
DROP TABLE #Project_Compliance  
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
DROP TABLE #Account_Compliance  
DROP TABLE #Associate_BUcompliance  
DROP TABLE #Associate_Greater80_SBU  
DROP TABLE #Associate_Greater_50_80_SBU  
DROP TABLE #Associate_Greater_0_25_SBU  
DROP TABLE #Associate_Greater_zero_SBU  
DROP TABLE #Associate_80_SBU  
DROP TABLE #Associate_50_80_SBU  
DROP TABLE #Associate_25_50_SBU  
DROP TABLE #Associate_0_25_SBU  
DROP TABLE #Associate_0_SBU  
DROP TABLE #SBU_Compliance  
DROP TABLE #BUDATA  
DROP TABLE #HOLIDAYLIST  
DROP TABLE #Associate_days   
DROP TABLE #FTE_Cal_A   
DROP TABLE #FTE_count_Loc   
DROP TABLE #FTE_count_Cal_A   
DROP TABLE #FTE_count_Cal   
DROP TABLE #Associate__endate_diff_loc   
DROP TABLE #FTE_endate_Cal_A    
DROP TABLE #MPS_Effort_App   
DROP TABLE #MPS_Effort_Infra   
DROP TABLE #MPS_Effort_Workitem  
DROP TABLE #AssociateSummarytmp   
DROP TABLE #ScopeProject_tmp  
DROP TABLE #YETTOSCOPE  
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
--DROP TABLE #Account_Compliance_AVM_AM   
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
--DROP TABLE #Account_Compliance_AVM_AD   
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
DROP TABLE #Account_Compliance_INTEG   
DROP TABLE #Associate_Accountcompliance_all   
DROP TABLE #Associate_Total_account_Compliance_all    
DROP TABLE #Account_Compliance_AD   
DROP TABLE #Account_Compliance_AM   
--DROP TABLE  #Account_Compliance_INTEG   
DROP TABLE #ScopeBU  
DROP TABLE #Associate_Greater80_SBU_AVM   
DROP TABLE #Associate_Greater_50_80_SBU_AVM    
DROP TABLE #Associate_Greater_25_50_SBU_AVM    
DROP TABLE  #Associate_Greater_0_25_SBU_AVM    
DROP TABLE #Associate_Greater_zero_SBU_AVM    
DROP TABLE #Associate_80_SBU_AVM    
DROP TABLE  #Associate_50_80_SBU_AVM    
DROP TABLE #Associate_25_50_SBU_AVM    
DROP TABLE  #Associate_0_25_SBU_AVM    
DROP TABLE #Associate_0_SBU_AVM    
DROP TABLE #SBU_Compliance_AVM    
DROP TABLE #BUDATA_AVM   
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
DROP TABLE #SBU_Compliance_AD    
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
DROP TABLE #SBU_Compliance_INTEG    
DROP TABLE #BUDATA_INTEG   
DROP TABLE #Associate_Greater_25_50_SBU    
 DROP TABLE #Associate_VERTICALcompliance  
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
DROP TABLE #VERTICAL_Compliance_AD    
DROP TABLE #VERTICALDATA_AD   
DROP TABLE #Associate_Greater80_VERTICAL_AVM    
DROP TABLE #Associate_Greater_50_80_VERTICAL_AVM   
DROP TABLE #Associate_Greater_25_50_VERTICAL_AVM   
DROP TABLE #Associate_Greater_0_25_VERTICAL_AVM    
DROP TABLE #Associate_Greater_zero_VERTICAL_AVM   
DROP TABLE #Associate_80_VERTICAL_AVM   
DROP TABLE #Associate_50_80_VERTICAL_AVM   
DROP TABLE #Associate_25_50_VERTICAL_AVM   
DROP TABLE #Associate_0_25_VERTICAL_AVM  
DROP TABLE #Associate_0_VERTICAL_AVM   
DROP TABLE #VERTICAL_Compliance_AVM  
---DROP TABLE #Associate_Greater_Zero_VERTICAL_AVM    
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
DROP TABLE #VERTICAL_Compliance_INTEG    
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
DROP TABLE #VERTICALDATA   
  
  
  
  
 END TRY  
  BEGIN CATCH  
 DECLARE @ErrorMessage VARCHAR(8000);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
      
  EXEC [AppVisionLens].dbo.AVL_InsertError '[ADP].[AssociateData_Weekly] ', @ErrorMessage, '',''  
  RETURN @ErrorMessage  
  END CATCH     
 end  

