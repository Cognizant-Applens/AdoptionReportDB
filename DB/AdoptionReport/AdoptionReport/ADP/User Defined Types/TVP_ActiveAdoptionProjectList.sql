CREATE TYPE [ADP].[TVP_ActiveAdoptionProjectList] AS TABLE(
	[ESAProjectID] [nvarchar](50) NULL,
	[ApplensScope] [nvarchar](50) NOT NULL,
	[BU] [nvarchar](50) NOT NULL,
	[MARKET] [nvarchar](100) NULL,
	[IsChildProject] [nvarchar](50) NULL
)



