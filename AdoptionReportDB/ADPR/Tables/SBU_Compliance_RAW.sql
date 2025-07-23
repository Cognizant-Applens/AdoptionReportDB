CREATE TABLE [ADPR].[SBU_Compliance_RAW] (
    [ID]                           BIGINT          IDENTITY (1, 1) NOT NULL,
    [SBU]                          VARCHAR (50)    NULL,
    [EmployeeID]                   VARCHAR (50)    NULL,
    [Department_Name]              VARCHAR (100)   NULL,
    [Associate Allocation(In FTE)] DECIMAL (10, 2) NULL,
    [Available_Hours]              DECIMAL (10, 2) NULL,
    [MPS_Effort]                   DECIMAL (10, 2) NULL,
    [WorkProfile AD]               DECIMAL (10, 2) NULL,
    [MAS_Effort]                   DECIMAL (10, 2) NULL,
    [Actual_Effort]                DECIMAL (10, 2) NULL,
    [Associate_BU_Compliance]      DECIMAL (10, 2) NULL
);

