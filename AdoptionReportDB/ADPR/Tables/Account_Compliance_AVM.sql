CREATE TABLE [ADPR].[Account_Compliance_AVM] (
    [ID]                               BIGINT          IDENTITY (1, 1) NOT NULL,
    [Parent_Accountid]                 CHAR (15)       NULL,
    [Parent_AccountName]               VARCHAR (50)    NULL,
    [Vertical]                         VARCHAR (50)    NULL,
    [MarketUnitName]                   VARCHAR (50)    NULL,
    [BU]                               VARCHAR (50)    NULL,
    [AVM_ESA_FTE]                      DECIMAL (10, 2) NULL,
    [AVM FTE with TSC %=0]             DECIMAL (10, 2) NULL,
    [AVM FTE with TSC %>0 to 25]       DECIMAL (10, 2) NULL,
    [AVM FTE with TSC %>25 to 50]      DECIMAL (10, 2) NULL,
    [AVM FTE with TSC %>50 to 80]      DECIMAL (10, 2) NULL,
    [AVM FTE with TSC %>80]            DECIMAL (10, 2) NULL,
    [Available_Hours]                  DECIMAL (10, 2) NULL,
    [MPS_Effort]                       DECIMAL (10, 2) NULL,
    [WorkProfile AD]                   DECIMAL (10, 2) NULL,
    [MAS_Effort]                       DECIMAL (10, 2) NULL,
    [Actual_Effort]                    DECIMAL (10, 2) NULL,
    [Effort Account Compliance% (AVM)] DECIMAL (10, 2) NULL,
    [AVM_Associate_Compliance_Percent] DECIMAL (10, 2) NULL
);

