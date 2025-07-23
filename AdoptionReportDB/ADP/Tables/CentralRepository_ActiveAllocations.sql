CREATE TABLE [ADP].[CentralRepository_ActiveAllocations] (
    [ID]                         INT            IDENTITY (1, 1) NOT NULL,
    [Associate_ID]               CHAR (11)      NULL,
    [Project_ID]                 CHAR (15)      NULL,
    [Allocation_Start_Date]      DATETIME       NULL,
    [Allocation_End_Date]        DATETIME       NULL,
    [Allocation_Percentage]      DECIMAL (5, 2) NULL,
    [Location]                   CHAR (10)      NULL,
    [LastUpdatedDateTime]        DATETIME       NULL,
    [Createddate]                DATETIME       NULL,
    [Created by]                 VARCHAR (20)   NULL,
    [Associate_Billability_Type] CHAR (3)       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

