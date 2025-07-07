USE [AdoptionReport]
GO
/****** Object:  StoredProcedure [ADPR].[BU_SUMMARY]    Script Date: 11/3/2023 12:46:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [ADPR].[BU_SUMMARY] --NULL
(
@ReportType nvarchar(max) = NULL
)
AS
BEGIN    
BEGIN TRY   
  SET NOCOUNT ON; 

SELECT  A.SBU AS 'MARKET UNIT NAME' ,Isnull(convert(decimal(10,1),A.[Overall #FTE]),0) AS 'Overall FTE'
,Isnull(convert(decimal(10,1),A.[ESA FTE(Below_M)]),0) AS 'Overall FTE(Below_M)'
,Isnull(convert(decimal(10,1),C.[Overall #FTE]),0) AS 'AD Overall FTE'
,Isnull(convert(decimal(10,1),D.[Overall #FTE]),0) AS 'AM Overall FTE'
,Isnull(convert(decimal(10,1),E.[Overall #FTE]),0) AS 'INTEGRATED Overall FTE'
,isnull(convert(decimal(10,1),F.[AVM #FTE]),0) AS 'AD ADM FTE'
,isnull(convert(decimal(10,1),G.[AVM #FTE]),0) AS 'AM ADM FTE'
,isnull(convert(decimal(10,1),H.[AVM #FTE]),0) AS 'INTEGRATED ADM FTE'
,isnull(convert(decimal(10,1),B.[AVM #FTE]),0) AS 'ADM FTE'
,isnull(convert(decimal(10,1),B.[AVM FTE(Below_M)]),0) AS 'ADM FTE(Below_M)'
,isnull(convert(decimal(10,1),A.[Overall #FTE with TSC %=0]),0) AS 'Overall #FTE with TSC %=0'  
,isnull(convert(decimal(10,1),A.[Overall #FTE with TSC %>0 to 25]),0) AS 'Overall #FTE with TSC %>0 to 25'  
,isnull(convert(decimal(10,1),A.[Overall #FTE with TSC %>25 to 50]),0)AS 'Overall #FTE with TSC %>25 to 50'  
,isnull(convert(decimal(10,1),A.[Overall #FTE with TSC %>50 to 80]),0) AS 'Overall #FTE with TSC %>50 to 80'  
,isnull(convert(decimal(10,1),C.[Overall #FTE with TSC %>80]),0) AS 'AD Overall #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),D.[Overall #FTE with TSC %>80]),0) AS 'AM Overall #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),E.[Overall #FTE with TSC %>80]),0) AS 'INTEGRATED Overall #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),A.[Overall #FTE with TSC %>80]),0) AS 'Overall #FTE with TSC %>80' 
,isnull(convert(decimal(10,1),A.[ESA FTE 80(Below_M)]),0) AS 'Overall #FTE with TSC %>80(Below_M)'
,isnull(convert(decimal(10,1),F.[AVM #FTE with TSC %>80]),0) AS 'AD ADM #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),G.[AVM #FTE with TSC %>80]),0) AS 'AM ADM #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),H.[AVM #FTE with TSC %>80]),0) AS 'INTEGRATED ADM #FTE with TSC %>80'  
,isnull(convert(decimal(10,1),B.[AVM #FTE with TSC %>80]),0) AS 'ADM #FTE with TSC %>80'
,isnull(convert(decimal(10,1),B.[AVM FTE 80(Below_M)]),0) AS 'ADM #FTE with TSC %>80(Below_M)'
,isnull(convert(decimal(10,1),C.[Available Hours]),0)AS 'AD Available Hours (All)'  
,isnull(convert(decimal(10,1),D.[Available Hours]),0)AS 'AM Available Hours (All)' 
,isnull(convert(decimal(10,1),E.[Available Hours]),0)AS 'INTEGRATED Available Hours (All)' 
,isnull(convert(decimal(10,1),a.[Available Hours]),0)AS 'Available Hours (All)'
,isnull(convert(decimal(10,1),a.[Available Hours(Below_M)]),0)AS 'Available Hours(Below_M)' 
,isnull(convert(decimal(10,1),F.[Available Hours]) ,0)AS 'AD Available Hours (ADM)'  
,isnull(convert(decimal(10,1),G.[Available Hours]) ,0)AS 'AM Available Hours (ADM)'  
,isnull(convert(decimal(10,1),H.[Available Hours]) ,0)AS 'INTEGRATED Available Hours (ADM)'  
,isnull(convert(decimal(10,1),B.[Available Hours]) ,0)AS 'Available Hours (ADM)'  
,isnull(convert(decimal(10,1),B.[Available Hours(Below_M)]) ,0)AS 'Available Hours(Below_M_ADM)' 
,isnull(convert(decimal(10,1),C.[Actual Effort]),0) as 'AD Actual Effort (All)'  
,isnull(convert(decimal(10,1),D.[Actual Effort]),0) as 'AM Actual Effort (All)' 
,isnull(convert(decimal(10,1),E.[Actual Effort]),0) as 'INTEGRATED Actual Effort (All)' 
,isnull(convert(decimal(10,1),A.[Actual Effort]),0) as 'Actual Effort (All)' 
,isnull(convert(decimal(10,1),A.[Actual Effort(Below_M)]),0) as 'Actual Effort(Below_M)' 
,isnull(convert(decimal(10,1),F.[Actual Effort]),0) as 'AD Actual Effort (ADM)'  
,isnull(convert(decimal(10,1),G.[Actual Effort]),0) as 'AM Actual Effort (ADM)' 
,isnull(convert(decimal(10,1),H.[Actual Effort]),0) as 'INTEGRATED Actual Effort (ADM)' 
,isnull(convert(decimal(10,1),B.[Actual Effort]),0) as 'Actual Effort (ADM)' 
,isnull(convert(decimal(10,1),B.[Actual Effort(Below_M)]),0) as 'Actual Effort(Below_M_ADM)' 
,ISNULL(convert(decimal(10,1),c.[BU Effort Compliance%(All)]),0) AS 'AD Scope -BU Effort Compliance%(All)' 
,ISNULL(convert(decimal(10,1),d.[BU Effort Compliance%(All)]),0) AS 'AM Scope -BU Effort Compliance%(All)' 
,ISNULL(convert(decimal(10,1),e.[BU Effort Compliance%(All)]),0) AS 'Integrated Scope -BU Effort Compliance%(All)' 
,ISNULL(convert(decimal(10,1),a.[BU Effort Compliance%(All)]),0) AS 'BU Effort Compliance%(All)' 
,ISNULL(convert(decimal(10,1),a.[BU_Effort_Compliance_Percent_Below_M]),0) AS 'BU_Effort_Compliance_Below_M' 
,ISNULL(convert(decimal(10,1),c.[Associate Compliance Percent]),0) AS 'AD Scope -BU Associate Compliance% (All)'   
,ISNULL(convert(decimal(10,1),d.[Associate Compliance Percent]),0) AS 'AM Scope -BU Associate Compliance% (All)'   
,ISNULL(convert(decimal(10,1),e.[Associate Compliance Percent]),0) AS 'Integrated Scope -BU Associate Compliance% (All)'   
,ISNULL(convert(decimal(10,1),a.[Associate Compliance Percent]),0) AS 'BU Associate Compliance% (All)'
,ISNULL(convert(decimal(10,1),a.[Associate_Compliance_Percent_Below_M]),0) AS 'BU_Associate_Compliance_Below_M'
,ISNULL(convert(decimal(10,1),F.[BU Effort Compliance%(AVM)]),0) AS 'AD Scope-BU Effort Compliance%(ADM)'
,ISNULL(convert(decimal(10,1),G.[BU Effort Compliance%(AVM)]),0) AS 'AM Scope -BU Effort Compliance%(ADM)'  
,ISNULL(convert(decimal(10,1),H.[BU Effort Compliance%(AVM)]),0) AS 'Integrated Scope -BU Effort Compliance%(ADM)'  
,ISNULL(convert(decimal(10,1),B.[BU Effort Compliance%(AVM)]),0) AS 'BU Effort Compliance%(ADM)' 
,ISNULL(convert(decimal(10,1),B.[BU_Effort_Compliance_Percent_Below_M]),0) AS 'BU_Effort_Compliance_Below_M(ADM)'  
,ISNULL(convert(decimal(10,1),F.[AVM_Associate_Compliance_Percent]),0)  AS 'AD Scope-BU Associate Compliance% (ADM)'  
,ISNULL(convert(decimal(10,1),G.[AVM_Associate_Compliance_Percent]),0)  AS 'AM Scope -BU Associate Compliance% (ADM)'  
,ISNULL(convert(decimal(10,1),H.[AVM_Associate_Compliance_Percent]),0)  AS 'Integrated Scope -BU Associate Compliance% (ADM)'  
,ISNULL(convert(decimal(10,1),B.[AVM_Associate_Compliance_Percent]),0)  AS 'BU Associate Compliance% (ADM)'
,ISNULL(convert(decimal(10,1),B.[Associate_Compliance_Percent_Below_M]),0)  AS 'BU_Associate_Compliance_Below_M(ADM)'
,ISNULL(convert(decimal(10,0),A.[No of Projects DE Eligible]),0)  AS 'No of Projects DE Eligible'
,ISNULL(convert(decimal(10,1),A.[DE Eligible Total FTE]),0)  AS 'DE Eligible Total FTE'
,ISNULL(convert(decimal(10,0),A.[No of Projects Adoption Eligible]),0)  AS 'No of Projects Adoption Eligible'
,ISNULL(convert(decimal(10,1),A.[Adoption Total FTE]),0)  AS 'Adoption Total FTE'
,ISNULL(convert(decimal(10,1),A.[ESA TS Compliance (Overall)]),0)  AS 'ESA TS Compliance (Overall)'
 Into #Adp_SBU_Compliance_AL_BU
FROM [ADPR].[SBU_Compliance] A  
LEFT JOIN [ADPR].[SBU_Compliance_AVM] B ON a.sbu=b.sbu   
LEFT JOIN [ADPR].[SBU_Compliance_AD] C ON a.sbu=C.sbu   
LEFT JOIN [ADPR].[SBU_Compliance_AM] D ON a.sbu=D.sbu   
LEFT JOIN [ADPR].[SBU_Compliance_INTEG] E ON a.sbu=E.sbu   
LEFT JOIN [ADPR].[SBU_Compliance_AVM_AD] F ON a.sbu=F.sbu   
LEFT JOIN [ADPR].[SBU_Compliance_AVM_AM] G ON a.sbu=G.sbu   
LEFT JOIN [ADPR].[SBU_Compliance_AVM_INTEG] H ON a.sbu=H.sbu   


ORDER BY CASE   WHEN A.SBU = 'GRAND TOTAL' THEN 1  
  
 ELSE 0  
END, A.[SBU]  
  ASC  

select [MARKET UNIT NAME],[Overall FTE],[Overall FTE(Below_M)],[ADM FTE],[ADM FTE(Below_M)],[Overall #FTE with TSC %=0],[Overall #FTE with TSC %>0 to 25],[Overall #FTE with TSC %>25 to 50],
[Overall #FTE with TSC %>50 to 80],[Overall #FTE with TSC %>80],[Overall #FTE with TSC %>80(Below_M)],[ADM #FTE with TSC %>80],[ADM #FTE with TSC %>80(Below_M)],
[Available Hours (All)],[Available Hours(Below_M)],[Available Hours (ADM)],[Available Hours(Below_M_ADM)],
[Actual Effort (All)],[Actual Effort(Below_M)],[Actual Effort (ADM)],[Actual Effort(Below_M_ADM)],
[AD Scope -BU Effort Compliance%(All)] ,[AM Scope -BU Effort Compliance%(All)],[Integrated Scope -BU Effort Compliance%(All)],
[BU Effort Compliance%(All)],[BU_Effort_Compliance_Below_M],[AD Scope -BU Associate Compliance% (All)] ,[AM Scope -BU Associate Compliance% (All)],
[INTEGRATED Scope -BU Associate Compliance% (All)],[BU Associate Compliance% (All)],[BU_Associate_Compliance_Below_M],
[AD Scope-BU Effort Compliance%(ADM)] ,[AM Scope -BU Effort Compliance%(ADM)],[Integrated Scope -BU Effort Compliance%(ADM)],
[BU Effort Compliance%(ADM)],[BU_Effort_Compliance_Below_M(ADM)],[AD Scope-BU Associate Compliance% (ADM)] ,[AM Scope -BU Associate Compliance% (ADM)],
[Integrated Scope -BU Associate Compliance% (ADM)],[BU Associate Compliance% (ADM)],[BU_Associate_Compliance_Below_M(ADM)], 
[No of Projects DE Eligible],[DE Eligible Total FTE],[No of Projects Adoption Eligible],[Adoption Total FTE],[ESA TS Compliance (Overall)]
into  #Adp_SBU_Compliance_FIN_BU 
from #Adp_SBU_Compliance_AL_BU where [MARKET UNIT NAME]not in('M&A NA','RCGTH-NA')

--select * from #Adp_SBU_Compliance_FIN 


IF (@ReportType is NULL)

BEGIN

insert into #Adp_SBU_Compliance_FIN_BU 
     
 select  'RCGTH-NA' AS [MARKET UNIT NAME],
 ISNULL(sum([Overall FTE]),0) AS 'Overall FTE',
 ISNULL(sum([Overall FTE(Below_M)]),0) AS 'Overall FTE(Below_M)',
 ISNULL(sum([ADM FTE]),0) AS 'ADM FTE',
 ISNULL(sum([ADM FTE(Below_M)]),0) AS 'ADM FTE(Below_M)',
 ISNULL(sum([Overall #FTE with TSC %=0]),0) AS 'Overall #FTE with TSC %=0',
 ISNULL(sum([Overall #FTE with TSC %>0 to 25]),0) As 'Overall #FTE with TSC %>0 to 25',
 ISNULL(sum([Overall #FTE with TSC %>25 to 50]),0) As 'Overall #FTE with TSC %>25 to 50', 
 ISNULL(sum([Overall #FTE with TSC %>50 to 80]),0) As 'Overall #FTE with TSC %>50 to 80',
 ISNULL(sum([Overall #FTE with TSC %>80]),0) As 'Overall #FTE with TSC %>80',
 ISNULL(sum([Overall #FTE with TSC %>80(Below_M)]),0) As 'Overall #FTE with TSC %>80(Below_M)',
 ISNULL(sum([ADM #FTE with TSC %>80]),0) As 'ADM #FTE with TSC %>80',
 ISNULL(sum([ADM #FTE with TSC %>80(Below_M)]),0) As 'ADM #FTE with TSC %>80(Below_M)',
 ISNULL(sum([Available Hours (All)]),0) AS 'Available Hours (All)',
 ISNULL(sum([Available Hours(Below_M)]),0) AS 'Available Hours(Below_M)',
 ISNULL(sum([Available Hours (ADM)]),0)AS 'Available Hours (ADM)',
 ISNULL(sum([Available Hours(Below_M_ADM)]),0)AS 'Available Hours(Below_M_ADM)',
 ISNULL(sum([Actual Effort (All)]),0) AS 'Actual Effort (All)',
 ISNULL(sum([Actual Effort(Below_M)]),0) AS 'Actual Effort(Below_M)',
 ISNULL(sum([Actual Effort (ADM)]),0) AS 'Actual Effort (ADM)',
 ISNULL(sum([Actual Effort(Below_M_ADM)]),0) AS 'Actual Effort(Below_M_ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AD Actual Effort (All)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([AD Available Hours (All)],0))) * 100, 0) AS 'AD SCOPE BU Effort Compliance%(All)' ,
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AM Actual Effort (All)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([AM Available Hours (All)],0))) * 100, 0) AS 'AM SCOPE BU Effort Compliance%(All)' ,
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [INTEGRATED Actual Effort (All)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([INTEGRATED Available Hours (All)],0))) * 100, 0) AS 'INTEGRATED SCOPE BU Effort Compliance%(All)' ,
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [Actual Effort (All)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([Available Hours (All)],0))) * 100, 0) AS 'BU Effort Compliance%(All)' ,
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [Actual Effort(Below_M)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([Available Hours(Below_M)],0))) * 100, 0) AS 'BU_Effort_Compliance_Below_M' ,
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AD Overall #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([AD Overall FTE],0))) * 100, 0) AS 'AD SCOPE BU Associate Compliance% (All)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AM Overall #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([AM Overall FTE],0))) * 100, 0) AS 'AM SCOPE BU Associate Compliance% (All)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [INTEGRATED Overall #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([INTEGRATED Overall FTE],0))) * 100, 0) AS 'INTEGRATED SCOPE Associate Compliance% (All)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [Overall #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([Overall FTE],0))) * 100, 0) AS 'BU Associate Compliance% (All)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [Overall #FTE with TSC %>80(Below_M)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([Overall FTE(Below_M)],0))) * 100, 0) AS 'BU_Associate_Compliance_Below_M',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AD Actual Effort (ADM)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([AD Available Hours (ADM)],0))) * 100, 0) AS 'AD SCOPE BU Effort Compliance%(ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AM Actual Effort (ADM)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([AM Available Hours (ADM)],0))) * 100, 0) AS 'AM SCOPE BU Effort Compliance%(ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [INTEGRATED Actual Effort (ADM)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([INTEGRATED Available Hours (ADM)],0))) * 100, 0) AS 'INTEGRATED SCOPE Effort Compliance%(ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [Actual Effort (ADM)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([Available Hours (ADM)],0))) * 100, 0) AS 'BU Effort Compliance%(ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [Actual Effort(Below_M_ADM)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([Available Hours(Below_M_ADM)],0))) * 100, 0) AS 'BU_Effort_Compliance_Below_M(ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AD ADM #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([AD ADM FTE],0))) * 100, 0) AS 'AD SCOPE BU Associate Compliance% (ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [AM ADM #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([AM ADM FTE],0))) * 100, 0) AS 'AM SCOPE BU Associate Compliance% (ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [INTEGRATED ADM #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([INTEGRATED ADM FTE],0))) * 100, 0) AS 'INTEGRATED SCOPE BU Associate Compliance% (ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [ADM #FTE with TSC %>80])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([ADM FTE],0))) * 100, 0) AS 'BU Associate Compliance% (ADM)',
 ISNULL(SUM(CONVERT(DECIMAL(10, 2), [ADM #FTE with TSC %>80(Below_M)])) / SUM(CONVERT(DECIMAL(10, 2), NULLIF([ADM FTE(Below_M)],0))) * 100, 0) AS 'BU_Associate_Compliance_Below_M(ADM)',
 ISNULL(sum([No of Projects DE Eligible]),0) AS 'No of Projects DE Eligible',
 ISNULL(sum([DE Eligible Total FTE]),0) AS 'DE Eligible Total FTE',
 ISNULL(sum([No of Projects Adoption Eligible]),0) AS 'No of Projects Adoption Eligible',
 ISNULL(sum([Adoption Total FTE]),0) AS 'Adoption Total FTE',
 ISNULL(sum([ESA TS Compliance (Overall)]),0) AS 'ESA TS Compliance (Overall)'
 from #Adp_SBU_Compliance_AL_BU where [MARKET UNIT NAME] in('M&A NA','RCGTH-NA')

 END

 



  
select *  Into #BUFINALTEMP_BU from (
(select * from #Adp_SBU_Compliance_FIN_BU where [MARKET UNIT NAME] like '%NA')

UNION ALL

(select * from #Adp_SBU_Compliance_FIN_BU where [MARKET UNIT NAME] not like '%NA' and [MARKET UNIT NAME] not like 'GRAND TOTAL')
 Union All
 
(select * from #Adp_SBU_Compliance_FIN_BU where [MARKET UNIT NAME] not like '%NA' and [MARKET UNIT NAME]  like 'GRAND TOTAL'))B

----
SELECT * INTO #fINAL_SBU_BU
FROM(
select * from #BUFINALTEMP_BU where [MARKET UNIT NAME] in ('CMT NA','FSI NA')

Union ALl
select * from #BUFINALTEMP_BU where [MARKET UNIT NAME]  in ('HEALTh NA')

Union All

select * from #BUFINALTEMP_BU where [MARKET UNIT NAME]not  in ('CMT NA','FSI NA','HEALTH NA'))P


CREATE table #SBU_FINAL_BU 
  
(  
[MARKET UNIT NAME] VARCHAR(50),
[Overall FTE]VARCHAR(50),
[Overall FTE(Below_M)] VARCHAR(50),
[ADM FTE] VARCHAR(50),
[ADM FTE(Below_M)] VARCHAR(50),
[Overall #FTE with TSC %=0] VARCHAR(50),
[Overall #FTE with TSC %>0 to 25] VARCHAR(50),
[Overall #FTE with TSC %>25 to 50] VARCHAR(50),
[Overall #FTE with TSC %>50 to 80] VARCHAR(50),
[Overall #FTE with TSC %>80] VARCHAR(50),
[Overall #FTE with TSC %>80(Below_M)] VARCHAR(50),
[ADM #FTE with TSC %>80] VARCHAR(50),
[ADM #FTE with TSC %>80(Below_M)] VARCHAR(50),
[Available Hours (All)] VARCHAR(50),
[Available Hours(Below_M)] VARCHAR(50),
[Available Hours (ADM)] VARCHAR(50),
[Available Hours(Below_M_ADM)] VARCHAR(50),
[Actual Effort (All)] VARCHAR(50),
[Actual Effort(Below_M)] VARCHAR(50),
[Actual Effort (ADM)] VARCHAR(50),
[Actual Effort(Below_M_ADM)] VARCHAR(50),
[AD Scope-BU Effort Compliance%(All)] VARCHAR(50),
[AM Scope-BU Effort Compliance%(All)] VARCHAR(50),
[INTEGRATED Scope-BU Effort Compliance%(All)] VARCHAR(50),
[BU Effort Compliance%(All)] VARCHAR(50),
[BU_Effort_Compliance_Below_M] VARCHAR(50),
[AD Scope-BU Associate Compliance% (All)] VARCHAR(50),
[AM Scope-BU Associate Compliance% (All)] VARCHAR(50),
[INTEGRATED Scope-BU Associate Compliance% (All)] VARCHAR(50),
[BU Associate Compliance% (All)] VARCHAR(50),
[BU_Associate_Compliance_Below_M] VARCHAR(50),
[AD Scope-BU Effort Compliance%(ADM)] VARCHAR(50),
[AM Scope-BU Effort Compliance%(ADM)] VARCHAR(50),
[INTEGRATED Scope-BU Effort Compliance%(ADM)] VARCHAR(50),
[BU Effort Compliance%(ADM)] VARCHAR(50),
[BU_Effort_Compliance_Below_M(ADM)] VARCHAR(50),
[AD Scope-BU Associate Compliance% (ADM)] VARCHAR(50),
[AM Scope-BU Associate Compliance% (ADM)] VARCHAR(50),
[INTEGRATED Scope-BU Associate Compliance% (ADM)] VARCHAR(50),
[BU Associate Compliance% (ADM)] VARCHAR(50),
[BU_Associate_Compliance_Below_M(ADM)] VARCHAR(50),
[No of Projects DE Eligible]  VARCHAR(50),
[DE Eligible Total FTE]  VARCHAR(50),
[No of Projects Adoption Eligible]  VARCHAR(50),
[Adoption Total FTE]  VARCHAR(50),
[ESA TS Compliance (Overall)] VARCHAR(50)
) 

iNSERT INTO #SBU_FINAL_BU 
SELECT * FROM #fINAL_SBU_BU

IF (@ReportType is NULL)

BEGIN

SELECT 
--[MARKET UNIT NAME] as 'SBU Delivery (PC2Geo mapping)',
--[Overall FTE], [AD Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (AD)] ,
--[AM Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (AM)] ,
--[INTEGRATED Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (INTEGRATED)] ,
--[BU Effort Compliance%(All)] ,
--[AD Scope-BU Associate Compliance% (All)] AS [BU Associate Compliance% (AD)] ,
--[AM Scope-BU Associate Compliance% (All)] AS [BU Associate Compliance% (AM)] ,
--[INTEGRATED Scope-BU Associate Compliance% (All)] as [BU Associate Compliance% (INTEGRATED)] ,
--[BU Associate Compliance% (All)] ,[BU Associate Compliance% (ADM)]    

[MARKET UNIT NAME] as 'SBU Name',
[No of Projects DE Eligible] as 'No. of Projects',
[DE Eligible Total FTE] as 'Total FTE',
[No of Projects Adoption Eligible] as 'No. of Projects_Adoption',
[Adoption Total FTE] as 'Total FTE_Adoption',
[BU_Associate_Compliance_Below_M(ADM)] as 'Associate Compliance% (SA-)',
[BU Associate Compliance% (ADM)] as 'Associate Compliance% (All Grade)',
[BU_Effort_Compliance_Below_M(ADM)] as 'Effort Compliance% (SA-)',
[BU Effort Compliance%(ADM)] as 'Effort Compliance% (All Grade)',
[BU_Associate_Compliance_Below_M] as 'Associate Compliance% (SA-)_All',
[BU Associate Compliance% (All)] as 'Associate Compliance% (All Grade)_All',
[BU_Effort_Compliance_Below_M] as 'Effort Compliance% (SA-)_All',
[BU Effort Compliance%(All)] as 'Effort Compliance% (All Grade)_All',
[ESA TS Compliance (Overall)] as 'ESA TS Compliance% (Overall)'
FROM #SBU_FINAL_BU where [MARKET UNIT NAME] not in ('LATAM')

END

Else IF (@ReportType='EPS')

BEGIN

SELECT 
--[MARKET UNIT NAME] as 'SBU Delivery (PC2Geo mapping)',
--[Overall FTE], [AD Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (AD)] ,
--[AM Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (AM)] ,
--[INTEGRATED Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (INTEGRATED)] ,
--[BU Effort Compliance%(All)] ,
--[AD Scope-BU Associate Compliance% (All)] AS [BU Associate Compliance% (AD)] ,
--[AM Scope-BU Associate Compliance% (All)] AS [BU Associate Compliance% (AM)] ,
--[INTEGRATED Scope-BU Associate Compliance% (All)] as [BU Associate Compliance% (INTEGRATED)] ,
--[BU Associate Compliance% (All)] ,[BU Associate Compliance% (ADM)] as 'BU Associate Compliance% (EPS)',
--[ESA TS Compliance (Overall)]

[MARKET UNIT NAME] as 'SBU Delivery (PC2Geo mapping)',
[No of Projects DE Eligible], [DE Eligible Total FTE],[No of Projects Adoption Eligible],[Adoption Total FTE],
[BU Effort Compliance%(All)] ,
[BU Associate Compliance% (All)] ,[BU Associate Compliance% (ADM)] as 'BU Associate Compliance% (EPS)',
[ESA TS Compliance (Overall)]
FROM #SBU_FINAL_BU where [MARKET UNIT NAME] not in ('LATAM')

END

Else IF (@ReportType='AIA')

BEGIN

SELECT [MARKET UNIT NAME] as 'SBU Delivery (PC2Geo mapping)',
[Overall FTE], [AD Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (AD)] ,
[AM Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (AM)] ,
[INTEGRATED Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (INTEGRATED)] ,
[BU Effort Compliance%(All)] ,
[AD Scope-BU Associate Compliance% (All)] AS [BU Associate Compliance% (AD)] ,
[AM Scope-BU Associate Compliance% (All)] AS [BU Associate Compliance% (AM)] ,
[INTEGRATED Scope-BU Associate Compliance% (All)] as [BU Associate Compliance% (INTEGRATED)] ,
[BU Associate Compliance% (All)] ,[BU Associate Compliance% (ADM)] as 'BU Associate Compliance% (AIA)'
FROM #SBU_FINAL_BU where [MARKET UNIT NAME] not in ('LATAM')

END

Else IF (@ReportType='CDBI')

BEGIN

SELECT [MARKET UNIT NAME] as 'SBU Delivery (PC2Geo mapping)',
[Overall FTE], [AD Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (AD)] ,
[AM Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (AM)] ,
[INTEGRATED Scope-BU Effort Compliance%(All)] as [BU Effort Compliance (INTEGRATED)] ,
[BU Effort Compliance%(All)] ,
[AD Scope-BU Associate Compliance% (All)] AS [BU Associate Compliance% (AD)] ,
[AM Scope-BU Associate Compliance% (All)] AS [BU Associate Compliance% (AM)] ,
[INTEGRATED Scope-BU Associate Compliance% (All)] as [BU Associate Compliance% (INTEGRATED)] ,
[BU Associate Compliance% (All)] ,[BU Associate Compliance% (ADM)] as 'BU Associate Compliance% (CDBI)'
FROM #SBU_FINAL_BU where [MARKET UNIT NAME] not in ('LATAM')

END




drop table #Adp_SBU_Compliance_AL_BU
drop table #Adp_SBU_Compliance_FIN_BU

  
END TRY  
  BEGIN CATCH  
 DECLARE @ErrorMessage VARCHAR(8000);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC [AppVisionLens].dbo.AVL_InsertError '[ADPR].[BU_SUMMARY]', @ErrorMessage, '',''  
  RETURN @ErrorMessage  
  END CATCH     
  
END