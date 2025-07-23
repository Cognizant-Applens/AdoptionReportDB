CREATE TABLE [ADPR].[NonADM_EligibleProjects] (
    [EsaProjectID]  NVARCHAR (50)  NULL,
    [ReportType]    NVARCHAR (50)  NULL,
    [PracticeOwner] NVARCHAR (50)  NULL,
    [DE_Inscope]    NVARCHAR (50)  NOT NULL,
    [SBU]           NVARCHAR (50)  NOT NULL,
    [MARKET]        NVARCHAR (100) NULL,
    [MARKET_BU]     NVARCHAR (100) NULL,
    [CHILDPROJECT]  NVARCHAR (50)  NULL,
    [IsDeleted]     BIT            NULL,
    [CreatedBy]     NVARCHAR (50)  NULL,
    [CreatedDate]   DATETIME       NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL
);

