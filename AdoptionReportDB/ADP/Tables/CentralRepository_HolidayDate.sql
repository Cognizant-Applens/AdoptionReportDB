CREATE TABLE [ADP].[CentralRepository_HolidayDate] (
    [ID]          INT          IDENTITY (1, 1) NOT NULL,
    [HOLIDAY]     DATE         NOT NULL,
    [LOCATION]    CHAR (10)    NOT NULL,
    [Createddate] DATETIME     NULL,
    [Created by]  VARCHAR (20) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

