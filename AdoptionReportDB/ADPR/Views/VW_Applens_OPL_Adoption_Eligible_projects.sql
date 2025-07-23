CREATE View [ADPR].[VW_Applens_OPL_Adoption_Eligible_projects]  
AS  

SELECT SBU_Delivery,EsaProjectId,[DEx Assessment feasibility flag],Archetype,FinalScope,Market 
from ADPR.AdoptionTotalEligibleProjects 
  
