CREATE Procedure [ADP].[Adoption_Associate_MailRecipientlist]  
  
  
AS  
  
  
BEGIN    
BEGIN TRY  
BEGIN TRAN
 SET NOCOUNT ON;  
 
UPDATE [Adp].[MailRecipient_Associate] SET IsDeleted=1 
WHERE [Type]=1 AND SBU='ADM' AND ID NOT IN (35,36,55)

SELECT DISTINCT CC.PROJECT_MANAGER as EmployeeID,A.Email AS EmailID 
INTO #TempADM
FROM [ADP].[Project_Compliance] PC (NOLOCK)
JOIN adp.CentralRepository_Project CP (NOLOCK)
ON PC.EsaProjectID=CP.Project_ID
JOIN [Adp].[CentralRepository_Current_ProjectManager] CC (NOLOCK) 
ON CC.PROJECT_ID=CP.Project_ID
JOIN [AppVisionLens].[ESA].[Associates] A (NOLOCK) 
ON CC.PROJECT_MANAGER=A.AssociateID AND A.IsActive=1

MERGE [Adp].[MailRecipient_Associate] T
USING  #TempADM S ON 
T.EmployeeID=S.EmployeeID AND T.Type=1 AND T.SBU='ADM'
WHEN MATCHED THEN
UPDATE SET IsDeleted=0
WHEN NOT MATCHED THEN
INSERT (EmployeeID,EmailID,Type,SBU,IsDeleted)
VALUES (S.EmployeeID,S.EmailID,1,'ADM',0);

Update [Adp].[MailRecipient_Associate] SET IsDeleted=1 
WHERE [Type]=4 AND SBU='ADM' AND ID NOT IN (52,53)

MERGE [Adp].[MailRecipient_Associate] T
USING  #TempADM S ON 
T.EmployeeID=S.EmployeeID AND T.Type=4 AND T.SBU='ADM'
WHEN MATCHED THEN
UPDATE SET IsDeleted=0
WHEN NOT MATCHED THEN
INSERT (EmployeeID,EmailID,Type,SBU,IsDeleted)
VALUES (S.EmployeeID,S.EmailID,4,'ADM',0);

select (STUFF((SELECT distinct ',' +  
  
 EmailID from  [Adp].[MailRecipient_Associate] where [Type]=1  and SBU='ADM' and isdeleted='0'
  
  
         
         FOR XML PATH(''), TYPE  
  
  
        ).value('.', 'NVARCHAR(MAX)')   
  
  
  
        , 1, 1, '')) as To_SDList  
  
  
     ,(STUFF((SELECT distinct ',' +  
  
  
        EmailID from  [Adp].[MailRecipient_Associate] where [Type]=2  and SBU='ADM' and isdeleted='0'
  
         FOR XML PATH(''), TYPE  
  
  
        ).value('.', 'NVARCHAR(MAX)')   
  
  
  
        , 1, 1, '')) as Cc_SDList  
  
   
 ,(STUFF((SELECT distinct ',' +  
  
  
 EmailID from  [Adp].[MailRecipient_Associate] where [Type]=3  and SBU='ADM' and isdeleted='0'
  
         FOR XML PATH(''), TYPE  
  
  
        ).value('.', 'NVARCHAR(MAX)')   
  
  
  
        , 1, 1, '')) as Bcc_SDList   
  

 ,(STUFF((SELECT distinct ',' +  
  
  
 EmailID from  [Adp].[MailRecipient_Associate] where [Type]=4  and SBU='ADM' and isdeleted='0'
  
         FOR XML PATH(''), TYPE  
  
  
        ).value('.', 'NVARCHAR(MAX)')   
  
  
  
        , 1, 1, '')) as Monthly_ToList        
  COMMIT TRAN
END TRY  
  BEGIN CATCH  
 DECLARE @ErrorMessage VARCHAR(8000);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC [AppVisionLens].[dbo].AVL_InsertError '[dbo].[Adoption_Associate_MailRecipientlist]', @ErrorMessage, '',''  
 ROLLBACK TRAN
 RETURN @ErrorMessage  
  END CATCH     
  
END  