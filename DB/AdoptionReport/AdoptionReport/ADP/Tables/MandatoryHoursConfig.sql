CREATE TABLE [ADP].[MandatoryHoursConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EsaProjectID] [nvarchar](50) NULL,
	[Project_Name] [nvarchar](500) NULL,
	[Mandatory_Hours] [bigint] NULL,
	[Createddate] [datetime] NULL,
	[Createdby] [nvarchar](50) NULL,
	[Modifieddate] [datetime] NULL,
	[Modifiedby] [nvarchar](50) NULL,
	[Isdeleted] [bit] NOT NULL
) ON [PRIMARY]
GO