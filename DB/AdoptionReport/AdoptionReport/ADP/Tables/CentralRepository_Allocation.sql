CREATE TABLE [ADP].[CentralRepository_Allocation] (
    [ID]                    INT            IDENTITY (1, 1) NOT NULL,
    [Associate_ID]          CHAR (11)      NULL,
    [Project_ID]            CHAR (15)      NULL,
    [Allocation_Start_Date] DATETIME       NULL,
    [Allocation_End_Date]   DATETIME       NULL,
    [Allocation_Percentage] DECIMAL (5, 2) NULL,
    [Location]              CHAR (10)      NULL,
    [LastUpdatedDateTime]   [varchar](60)        NULL,
    [Createddate]           DATETIME        NULL,
    [Created by]            VARCHAR (20)    NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

