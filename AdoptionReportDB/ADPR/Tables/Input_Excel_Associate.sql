CREATE TABLE [ADPR].[Input_Excel_Associate] (
    [ID]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [EsaProjectID]  VARCHAR (15)  NOT NULL,
    [PracticeOwner] VARCHAR (50)  NOT NULL,
    [DE_Inscope]    VARCHAR (50)  NOT NULL,
    [SBU]           VARCHAR (50)  NOT NULL,
    [DartOrApp]     VARCHAR (10)  NULL,
    [IsConfigured]  INT           NULL,
    [CHILDPROJECT]  NVARCHAR (50) NULL
);

