CREATE TABLE [ADP].[centralrepository_SFDC_Account] (
    [Peoplesoft_Customer_Id__C]         VARCHAR (20) NOT NULL,
    [Financial_Ultimate_Customer_Id__C] VARCHAR (20) NULL,
    [LastUpdatedDateTime]               DATETIME     NULL,
    [Createddate]                       DATETIME     NULL,
    [Created by]                        VARCHAR (20) NULL,
    PRIMARY KEY CLUSTERED ([Peoplesoft_Customer_Id__C] ASC)
);

