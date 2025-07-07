CREATE TABLE [ADP].[MandatoryHoursConfig] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [EsaProjectID]    NVARCHAR (50)  NULL,
    [Project_Name]    NVARCHAR (500) NULL,
    [Mandatory_Hours] BIGINT         NULL,
    [Createddate]     DATETIME       NULL,
    [Createdby]       NVARCHAR (50)  NULL,
    [Modifieddate]    DATETIME       NULL,
    [Modifiedby]      NVARCHAR (50)  NULL,
    [Isdeleted]       BIT            NOT NULL
);

