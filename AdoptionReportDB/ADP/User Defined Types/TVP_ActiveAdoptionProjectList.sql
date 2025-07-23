CREATE TYPE [ADP].[TVP_ActiveAdoptionProjectList] AS TABLE (
    [ESAProjectID]   NVARCHAR (50)  NULL,
    [ApplensScope]   NVARCHAR (50)  NOT NULL,
    [BU]             NVARCHAR (50)  NOT NULL,
    [MARKET]         NVARCHAR (100) NULL,
    [IsChildProject] NVARCHAR (50)  NULL);

