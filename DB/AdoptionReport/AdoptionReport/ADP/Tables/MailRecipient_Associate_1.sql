CREATE TABLE [Adp].[MailRecipient_Associate](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [varchar](15) NULL,
	[EmailID] [nvarchar](400) NULL,
	[Type] [int] NULL,
	[SBU] [varchar](15) NULL,
	[IsDeleted] [bit] NULL )