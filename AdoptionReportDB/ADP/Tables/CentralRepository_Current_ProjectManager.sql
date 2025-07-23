CREATE TABLE [ADP].[CentralRepository_Current_ProjectManager] (
    [PROJECT_ID]          CHAR (15)    NOT NULL,
    [PROJECT_MANAGER]     CHAR (11)    NULL,
    [LastUpdatedDateTime] DATETIME     NULL,
    [Createddate]         DATETIME     NULL,
    [Created by]          VARCHAR (20) NULL,
    PRIMARY KEY CLUSTERED ([PROJECT_ID] ASC)
);

