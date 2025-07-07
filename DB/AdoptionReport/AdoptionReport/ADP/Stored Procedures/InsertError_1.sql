CREATE PROCEDURE [ADP].[InsertError]     
 -- Add the parameters for the stored procedure here    
   @ErrSource VARCHAR(MAX),  
   @Message  VARCHAR(MAX),  
   @UserID  VARCHAR(50),  
   @CustomerID BIGINT =0  
AS    
BEGIN      
 BEGIN TRY     
                
  INSERT INTO    
   ADP.Errors    
  SELECT   
   @CustomerID, @ErrSource, @Message, @UserID, GETDATE()   
  
  SELECT 1 AS Result  
     
 END TRY    
 BEGIN CATCH    
     
  DECLARE @ErrorMessage NVARCHAR(4000);    
  DECLARE @ErrorSeverity INT;    
  DECLARE @ErrorState INT;    
     
  SELECT     
   @ErrorMessage = ERROR_MESSAGE(),    
   @ErrorSeverity = ERROR_SEVERITY(),    
   @ErrorState = ERROR_STATE();  
    
  -- Use RAISERROR inside the CATCH block to return error    
  -- information about the original error that caused    
  -- execution to jump to the CATCH block.    
  RAISERROR (@ErrorMessage, -- Message text.    
       @ErrorSeverity, -- Severity.    
       @ErrorState -- State.    
       );    
     
 END CATCH    
     
END