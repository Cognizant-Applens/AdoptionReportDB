CREATE TABLE [ADPR].[MailRecipient_Associate] (
    [ID]         BIGINT         IDENTITY (1, 1) NOT NULL,
    [EmployeeID] VARCHAR (15)   NULL,
    [EmailID]    NVARCHAR (400) NULL,
    [Type]       INT            NULL,
    [SBU]        VARCHAR (15)   NULL,
    [IsDeleted]  BIT            NULL
);

