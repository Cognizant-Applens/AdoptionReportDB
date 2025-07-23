CREATE TABLE [ADP].[CentralRepository_SFDC_Financial_Ultimate_Parent_Account] (
    [Financial_Ultimate_Customer_Id__C] VARCHAR (20) NOT NULL,
    [Name]                              VARCHAR (80) NOT NULL,
    [LastUpdatedDateTime]               DATETIME     NULL,
    [Createddate]                       DATETIME     NULL,
    [Created by]                        VARCHAR (20) NULL,
    PRIMARY KEY CLUSTERED ([Financial_Ultimate_Customer_Id__C] ASC)
);

