CREATE TABLE [ADPR].[Associate_Accountcompliance_Raw] (
    [ID]                           BIGINT          IDENTITY (1, 1) NOT NULL,
    [Parent_Accountid]             CHAR (15)       NULL,
    [Parent_AccountName]           VARCHAR (100)   NULL,
    [Vertical]                     VARCHAR (50)    NULL,
    [EmployeeID]                   VARCHAR (50)    NULL,
    [Department_Name]              VARCHAR (100)   NULL,
    [Associate Allocation(In FTE)] DECIMAL (10, 2) NULL,
    [Available Hours]              DECIMAL (10, 2) NULL,
    [MPS Effort]                   DECIMAL (10, 2) NULL,
    [WorkProfile AD]               DECIMAL (10, 2) NULL,
    [MAS_Effort]                   DECIMAL (10, 2) NULL,
    [Actual_Effort]                DECIMAL (10, 2) NULL,
    [Associate_Account_Compliance] DECIMAL (10, 2) NULL
);

