/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE procedure [ADP].[GetOPLMailerList]
AS          
BEGIN         
BEGIN TRY         

SELECT EmployeeName,EmployeeEmail FROM dbo.Adoption_OPL_JobMail where IsActive = 1;
   
END TRY        
BEGIN CATCH               
DECLARE @Message VARCHAR(MAX);  
DECLARE @ErrorSource VARCHAR(MAX);      
        
  SELECT @Message = ERROR_MESSAGE()
  select @ErrorSource = ERROR_STATE()  
EXEC [AppVisionLens].dbo.AVL_InsertError '[ADP].[GetOPLMailerList]',@ErrorSource,@Message,0               
END CATCH           
END