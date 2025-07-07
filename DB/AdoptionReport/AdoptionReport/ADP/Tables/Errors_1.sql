CREATE TABLE [ADP].[Errors] (
    [ErrorID]          INT            IDENTITY (1, 1) NOT NULL,
    [CustomerID]       BIGINT         NOT NULL,
    [ErrorSource]      NVARCHAR (MAX) NOT NULL,
    [ErrorDescription] NVARCHAR (MAX) NOT NULL,
    [CreatedBy]        VARCHAR (10)   NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL
);

