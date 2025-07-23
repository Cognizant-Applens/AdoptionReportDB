CREATE Procedure [ADP].[AIA_Adoption_Associate_MailRecipientlist]  
  
  
AS  
  
BEGIN    
BEGIN TRY  
BEGIN TRAN
  SET NOCOUNT ON;   

UPDATE [Adp].[MailRecipient_Associate] SET IsDeleted=1 
WHERE [Type]=1 AND SBU='AIA' AND ID NOT IN (56)

SELECT DISTINCT CC.PROJECT_MANAGER AS EmployeeID,A.Email AS EmailID 
INTO #TempAIA
FROM [ADP].[Project_Compliance] PC (NOLOCK)
JOIN adp.CentralRepository_Project CP (NOLOCK)
ON PC.EsaProjectID=CP.Project_ID
JOIN [Adp].[CentralRepository_Current_ProjectManager] CC (NOLOCK) 
ON CC.PROJECT_ID=CP.Project_ID
JOIN [AppVisionLens].[ESA].[Associates] A (NOLOCK) 
ON CC.PROJECT_MANAGER=A.AssociateID AND A.IsActive=1

MERGE [Adp].[MailRecipient_Associate] T
USING  #TempAIA S ON 
T.EmployeeID=S.EmployeeID AND T.Type=1 AND T.SBU='AIA'
WHEN MATCHED THEN
UPDATE SET IsDeleted=0
WHEN NOT MATCHED THEN
INSERT (EmployeeID,EmailID,Type,SBU,IsDeleted)
VALUES (S.EmployeeID,S.EmailID,1,'AIA',0);
select (STUFF((SELECT distinct ',' +  
  
 EmailID from  [Adp].[MailRecipient_Associate] where [Type]=1  and SBU='AIA' and isdeleted='0'
  
  
         
         FOR XML PATH(''), TYPE  
  
  
        ).value('.', 'NVARCHAR(MAX)')   
  
  
  
        , 1, 1, '')) as To_SDList  
  
  
     ,(STUFF((SELECT distinct ',' +  
  
  
        EmailID from  [Adp].[MailRecipient_Associate] where [Type]=2  and SBU='AIA' and isdeleted='0'
  
         FOR XML PATH(''), TYPE  
  
  
        ).value('.', 'NVARCHAR(MAX)')   
  
  
  
        , 1, 1, '')) as Cc_SDList  
  
   
 ,(STUFF((SELECT distinct ',' +  
  
  
 EmailID from  [Adp].[MailRecipient_Associate] where [Type]=3  and SBU='AIA' and isdeleted='0'
  
         FOR XML PATH(''), TYPE  
  
  
        ).value('.', 'NVARCHAR(MAX)')   
  
  
  
        , 1, 1, '')) as Bcc_SDList   
  
 COMMIT TRAN     
  
END TRY  
  BEGIN CATCH  
 DECLARE @ErrorMessage VARCHAR(8000);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC [AppVisionLens].[dbo].AVL_InsertError '[dbo].[AIA_Adoption_Associate_MailRecipientlist]', @ErrorMessage, '',''  
  ROLLBACK TRAN
  RETURN @ErrorMessage  
  END CATCH     
  
END  