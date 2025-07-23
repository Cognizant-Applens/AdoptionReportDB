CREATE PROCEDURE [ADP].[Input_Data_Refresh_Associate]


AS


BEGIN  
BEGIN TRY 
  SET NOCOUNT ON; 


TRUNCATE table [Adp].[Input_Excel_Associate]

INSERT into [Adp].[Input_Excel_Associate] (EsaProjectID,PracticeOwner,DE_Inscope,SBU,[CHILDPROJECT])

SELECT distinct EsaProjectID,PracticeOwner,DE_Inscope,SBU,[CHILDPROJECT] FROM [ADP].[Associate_Projects]




UPDATE EX set EX.DartOrApp=2  from [Adp].[Input_Excel_Associate] EX 


join [AppVisionLens].AVL.MAS_ProjectMaster PM on Pm.EsaProjectID=EX.EsaProjectID  and  PM.IsDeleted=0 and PM.IsESAProject=1 --and (pm.IsMigratedFromDART=2 or pm.IsMigratedFromDART is null) 


UPDATE EX set EX.IsConfigured=1  from [Adp].[Input_Excel_Associate] EX 

join [AppVisionLens].AVL.MAS_ProjectMaster PM on Pm.EsaProjectID=EX.EsaProjectID  and  PM.IsDeleted=0 and PM.IsESAProject=1 --and (pm.IsMigratedFromDART=2 or pm.IsMigratedFromDART is null) 

join [AppVisionLens].AVL.PRJ_ConfigurationProgress CP on CP.ProjectID=PM.ProjectID and CP.ScreenID=2 and CP.ITSMScreenId=11 and CP.CompletionPercentage=100 and CP.IsDeleted=0

join [AppVisionLens].AVL.PRJ_ConfigurationProgress CP1 on CP1.ProjectID=PM.ProjectID and CP1.ScreenID=4  and CP1.CompletionPercentage=100 and cp1.IsDeleted=0

UPDATE EX set EX.IsConfigured=1 from [Adp].[Input_Excel_Associate] EX
join [AppVisionLens].AVL.MAS_ProjectMaster PM on Pm.EsaProjectID=EX.EsaProjectID and PM.IsDeleted=0 and PM.IsESAProject=1
join [AppVisionLens].PP.ProjectProfilingTileProgress CP on CP.ProjectID=PM.ProjectID and CP.TileID=5 and CP.TileProgressPercentage=100 and CP.IsDeleted=0
join [AppVisionLens].AVL.PRJ_ConfigurationProgress CP1 on CP1.ProjectID=PM.ProjectID and CP1.ScreenID=4 and CP1.CompletionPercentage=100 and cp1.IsDeleted=0
where EX.IsConfigured is null


UPDATE A set A.DartOrApp=3 from [Adp].[Input_Excel_Associate] A

join [AppVisionLens].AVL.MAS_ProjectMaster pm on pm.EsaProjectID =A.EsaProjectID and pm.IsDeleted=0  and  pm.IsODCRestricted='Y'



CREATE TABLE #TMP_INPUT

(

EsaProjectID VARCHAR (50) null,

PracticeOwner VARCHAR(50) null,

DE_Inscope VARCHAR(50) null,

DartOrApp VARCHAR(50) 


)



insert INTO #TMP_INPUT

SELECT Distinct AIE.EsaProjectID,AIE.PracticeOwner,AIE.DE_Inscope,AIE.DartOrApp 

from [Adp].[Input_Excel_Associate] AIE where  AIE.DartOrApp=2 and AIE.DartOrApp=2


SELECT CTS_VERTICAL,ProjectID INTO #TempPracOwningBU FROM  


	(SELECT DISTINCT CTS_VERTICAL,ID as ProjectID FROM [AppVisionLens].ESA.Projects where CONVERT(varchar,ID) in(
	
	SELECT ESAProjectID from #TMP_INPUT)

	   	) AS BUName


Select DISTINCT CP.project_ID,CP.Project_Name,CP.Project_Owner,CP.Deliverymanagerid,PM.PROJECT_MANAGER into #tmp_pre_ID 

--from CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Project CP

from [Adp].[CentralRepository_Project] CP

INNER JOIN #TMP_INPUT AC ON AC.ESAProjectID=CP.Project_ID

--LEFT JOIN CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Current_ProjectManager PM  ON AC.ESAProjectID=PM.PROJECT_ID

LEFT JOIN [Adp].[CentralRepository_Current_ProjectManager] PM  ON AC.ESAProjectID=PM.PROJECT_ID





select distinct TF.PROJECT_ID, TF.Project_Name, 

TF.project_Owner , associate.AssociateName as POName

,TF.Deliverymanagerid , associate1.AssociateName  as DMName

,TF.PROJECT_MANAGER , associate2.AssociateName  as PMName

into #tmp_data_preview_old


from #tmp_pre_ID TF 

left join [AppVisionLens].[ESA].[Associates] AS associate on TF.project_Owner = associate.AssociateID

left join [AppVisionLens].[ESA].[Associates] AS associate1 on TF.Deliverymanagerid = associate1.AssociateID

left join [AppVisionLens].[ESA].[Associates] AS associate2 on TF.PROJECT_MANAGER = associate2.AssociateID






--SELECT Dept_ID,Dept_Desc,Eff_Status

--	,ROW_NUMBER() OVER (PARTITION BY Dept_ID ORDER BY EffDt DESC) AS Topp INTO #tmp_DPT
----FROM CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Department
--FROM [ADP].[Gmspmo_department_master]




SELECT DISTINCT DM.PROJECT_ID, DM.Project_Name, DM.project_Owner, DM.POName, DM.Deliverymanagerid, DM.DMName, CRS.Dept_Name, DM.PROJECT_MANAGER,DM.PMName
INTO #tmp_data_preview FROM #tmp_data_preview_old DM

--left JOIN CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Associate_Details CRS ON DM.Deliverymanagerid=CRS.Associate_ID

left JOIN [Adp].[CentralRepository_Associate_Details] CRS ON DM.Deliverymanagerid=CRS.Associate_ID

--left JOIN #tmp_DPT dpt ON CRS.Dept_ID = DPT.Dept_ID AND DPT.Eff_Status = 'A'
--	AND DPT.TOPP = 1


select PM.PROJECT_ID,PM.Project_Name,
PM.project_Owner,PM.POName,PM.Deliverymanagerid,PM.DMName,PM.Dept_Name,PM.PROJECT_MANAGER,PM.PMName, 
Cus.Financial_Ultimate_Customer_Id__C AS Parent_Account_ID, PC.Name as Parent_Account_Name

into #tmp_PAcc_ID

from #tmp_data_preview PM


--Left join CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Project avmsbu ON PM.Project_ID = avmsbu.project_ID
Left join [Adp].[CentralRepository_Project] avmsbu ON PM.Project_ID = avmsbu.project_ID

--Left join CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_SFDC_Account Cus ON Cus.Peoplesoft_Customer_Id__C = avmsbu.customer_id
Left join [Adp].[centralrepository_SFDC_Account] Cus ON Cus.Peoplesoft_Customer_Id__C = avmsbu.customer_id


--Left join CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_centralrepository_rhms_parentcustomerlevel1 PC ON PC.Parentcustomerid = Cus.Financial_Ultimate_Customer_Id__C
--Left join CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_SFDC_Financial_Ultimate_Parent_Account PC ON CUS.Financial_Ultimate_Customer_Id__C = PC.Financial_Ultimate_Customer_Id__C

Left join [Adp].[CentralRepository_SFDC_Financial_Ultimate_Parent_Account] PC ON CUS.Financial_Ultimate_Customer_Id__C = PC.Financial_Ultimate_Customer_Id__C


TRUNCATE table [Adp].[Input_Data_AssociateRAW]


Insert into [Adp].[Input_Data_AssociateRAW]

Select distinct 	A.PracticeOwner, C.CTS_Vertical as Project_Owning_Practice, A.DE_Inscope, b.PROJECT_ID,b.Project_Name,b.project_Owner,b.POName,b.Deliverymanagerid,b.DMName,
b.Dept_Name,b.PROJECT_MANAGER,b.PMName,b.Parent_Account_ID,b.Parent_Account_Name,MARKET,MARKET_BU,''
from [Adp].[Input_Excel_Associate] A 


Inner Join #tmp_PAcc_ID B on A.ESAProjectID= B.Project_ID 

inner join [Adp].[Associate_Projects] AP on B.Project_ID =Ap.EsaProjectID


Inner Join #TempPracOwningBU C on A.ESAProjectID= C.ProjectID



Delete from [Adp].[Input_Data_AssociateRAW] where EsaProjectID in (Select EsaProjectID from [AppVisionLens].AVL.MAS_ProjectMaster where IsODCRestricted = 'Y')

Update [Adp].[Input_Data_AssociateRAW] SET PracticeOwner = 'HEALTHCARE' WHERE PracticeOwner = 'XEROX'


Update [Adp].[Input_Data_AssociateRAW] SET ProjectOwningPractice = 'HEALTHCARE' WHERE ProjectOwningPractice = 'XEROX'


select distinct A.EsaProjectID,C.AttributeValueID as 'ScopeName' , 'Scp' As 'Scope'into #ProjectScope from [Adp].[Input_Data_AssociateRAW] A
join [AppVisionLens].AVL.MAS_ProjectMaster B on A.EsaProjectid=B.EsaProjectID
join [AppVisionLens].PP.ProjectAttributeValues C on B.ProjectID=C.ProjectID
join [AppVisionLens].MAS.PPAttributeValues D on C.AttributeValueID=D.AttributeValueID
where C.AttributeID='1'
order by A.EsaProjectid


Update A set PROJECTSCOPE='AD'
from [Adp].[Input_Data_AssociateRAW] A join #ProjectScope B on A.EsaProjectID=B.EsaProjectID where B.ScopeName in ('1')

Update A set PROJECTSCOPE='AD'
from [Adp].[Input_Data_AssociateRAW] A join #ProjectScope B on A.EsaProjectID=B.EsaProjectID where B.ScopeName in ('4')

Update A set PROJECTSCOPE='AD + AVM'
from [Adp].[Input_Data_AssociateRAW] A join #ProjectScope B on A.EsaProjectID=B.EsaProjectID where B.ScopeName in ('2')
and A.PROJECTSCOPE='AD'

Update A set PROJECTSCOPE='AVM'
from [Adp].[Input_Data_AssociateRAW] A join #ProjectScope B on A.EsaProjectID=B.EsaProjectID where B.ScopeName in ('2')
and A.PROJECTSCOPE =''

Update A set PROJECTSCOPE= CONCAT(A.PROJECTSCOPE ,' + INFRA')
from [Adp].[Input_Data_AssociateRAW] A join #ProjectScope B on A.EsaProjectID=B.EsaProjectID where B.ScopeName in ('3')
and A.PROJECTSCOPE <> ''

Update A set PROJECTSCOPE= 'INFRA'
from [Adp].[Input_Data_AssociateRAW] A join #ProjectScope B on A.EsaProjectID=B.EsaProjectID where B.ScopeName in ('3')
and A.PROJECTSCOPE = ''


Select ID
,PracticeOwner
,ProjectOwningPractice
,DE_Inscope
,EsaProjectID
,ProjectName
,[PO ID]
,[PO Name]
,[DM ID]
,[DM Name]
,[Project Department]
,[PM ID]
,[PM Name]
,[ParentAccountID]
,[ParentAccountName]
,[MARKET]
,[MARKET_BU]
,[PROJECTSCOPE]
from [Adp].[Input_Data_AssociateRAW] 


DROP TABLE #TempPracOwningBU
DROP TABLE #tmp_PAcc_ID
DROP TABLE #tmp_data_preview

DROP TABLE #tmp_data_preview_old
DROP TABLE #tmp_pre_ID
DROP TABLE #TMP_INPUT

END TRY
  BEGIN CATCH
 DECLARE @ErrorMessage VARCHAR(8000);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		--INSERT Error    
		EXEC [AppVisionLens].dbo.AVL_InsertError '[Adp].[Input_Data_Refresh_Associate]', @ErrorMessage, '',''
		RETURN @ErrorMessage
  END CATCH   

END