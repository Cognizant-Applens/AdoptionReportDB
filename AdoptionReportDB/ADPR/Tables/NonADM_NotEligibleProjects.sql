CREATE TABLE [ADPR].[NonADM_NotEligibleProjects] (
    [EsaProjectID]  NVARCHAR (50)  NULL,
    [ReportType]    NVARCHAR (50)  NULL,
    [Comments]      NVARCHAR (100) NULL,
    [IsDeleted]     BIT            NULL,
    [ValidTilldate] DATETIME       NULL,
    [CreatedBy]     NVARCHAR (50)  NULL,
    [CreatedDate]   DATETIME       NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL
);

