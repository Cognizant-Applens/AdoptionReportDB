CREATE TABLE [ADP].[CentralRepository_Project] (
    [Project_ID]        NVARCHAR (20)  NOT NULL,
    [Project_Name]      NVARCHAR (200) NULL,
    [DeliveryManagerId] NVARCHAR (20)  NULL,
    [Project_Owner]     NVARCHAR (20)  NULL,
    [Customer_ID]       NVARCHAR (30)  NULL,
    [Createddate]       DATETIME       NULL,
    [Created by]        VARCHAR (20)   NULL,
    PRIMARY KEY CLUSTERED ([Project_ID] ASC)
);

