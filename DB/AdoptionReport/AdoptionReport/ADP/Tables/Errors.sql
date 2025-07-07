CREATE TABLE [ADP].[Errors](
	[ErrorID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [bigint] NOT NULL,
	[ErrorSource] [nvarchar](max) NOT NULL,
	[ErrorDescription] [nvarchar](max) NOT NULL,
	[CreatedBy] [varchar](10) NOT NULL,
	[CreatedDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO