CREATE TABLE [ADPR].[Input_Data_AssociateRAW] (
    [ID]                    BIGINT         IDENTITY (1, 1) NOT NULL,
    [PracticeOwner]         VARCHAR (50)   NULL,
    [ProjectOwningPractice] VARCHAR (50)   NULL,
    [DE_Inscope]            VARCHAR (50)   NULL,
    [EsaProjectID]          VARCHAR (50)   NULL,
    [ProjectName]           VARCHAR (50)   NULL,
    [PO ID]                 VARCHAR (50)   NULL,
    [PO Name]               VARCHAR (50)   NULL,
    [DM ID]                 VARCHAR (50)   NULL,
    [DM Name]               VARCHAR (50)   NULL,
    [Project Department]    VARCHAR (50)   NULL,
    [PM ID]                 VARCHAR (50)   NULL,
    [PM Name]               VARCHAR (50)   NULL,
    [ParentAccountID]       VARCHAR (50)   NULL,
    [ParentAccountName]     VARCHAR (50)   NULL,
    [MARKET]                NVARCHAR (100) NULL,
    [MARKET_BU]             NVARCHAR (100) NULL,
    [PROJECTSCOPE]          NVARCHAR (50)  NULL,
    [OnboardStatus]         VARCHAR (50)   NULL
);

