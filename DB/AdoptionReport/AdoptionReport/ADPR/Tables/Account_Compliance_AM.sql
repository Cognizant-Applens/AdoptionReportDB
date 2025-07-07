CREATE TABLE [ADPR].[Account_Compliance_AM] (
    [ID]                               BIGINT          IDENTITY (1, 1) NOT NULL,
    [Parent_Accountid]                 CHAR (15)       NULL,
    [Parent_AccountName]               VARCHAR (100)   NULL,
    [Vertical]                         VARCHAR (50)    NULL,
    [MarketUnitName]                   VARCHAR (50)    NULL,
    [BU]                               VARCHAR (50)    NULL,
    [AM Project #]                     INT             NULL,
    [Overall #FTE]                     DECIMAL (10, 2) NULL,
    [Overall #FTE with TSC %=0]        DECIMAL (10, 2) NULL,
    [Overall #FTE with TSC %>0 to 25]  DECIMAL (10, 2) NULL,
    [Overall #FTE with TSC %>25 to 50] DECIMAL (10, 2) NULL,
    [Overall #FTE with TSC %>50 to 80] DECIMAL (10, 2) NULL,
    [Overall #FTE with TSC %>80]       DECIMAL (10, 2) NULL,
    [Available Hours]                  DECIMAL (10, 2) NULL,
    [MPS Effort]                       DECIMAL (10, 2) NULL,
    [WorkProfile AD]                   DECIMAL (10, 2) NULL,
    [MAS Effort]                       DECIMAL (10, 2) NULL,
    [Actual Effort]                    DECIMAL (10, 2) NULL,
    [Effort Account Compliance% (All)] DECIMAL (10, 2) NULL,
    [All_Associate_Compliance_Percent] DECIMAL (10, 2) NULL
);

