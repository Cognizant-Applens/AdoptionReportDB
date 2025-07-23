CREATE TABLE [ADP].[CentralRepository_Associate_Details] (
    [Associate_ID] VARCHAR (20)  NOT NULL,
    [JobCode]      VARCHAR (30)  NULL,
    [Dept_Name]    VARCHAR (200) NULL,
    [Designation]  VARCHAR (100) NULL,
    [Createddate]  DATETIME      NULL,
    [Created by]   VARCHAR (20)  NULL,
    PRIMARY KEY CLUSTERED ([Associate_ID] ASC)
);

