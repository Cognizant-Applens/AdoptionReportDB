CREATE TABLE [ADPR].[Associate_Compliance_RAW] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [Parent Accountid]       CHAR (15)       NULL,
    [Parent AccountName]     VARCHAR (100)   NULL,
    [SBU]                    VARCHAR (50)    NULL,
    [Vertical]               VARCHAR (50)    NULL,
    [EsaProjectID]           CHAR (15)       NOT NULL,
    [Projectname]            VARCHAR (100)   NULL,
    [EmployeeID]             VARCHAR (50)    NULL,
    [EmployeeName]           VARCHAR (100)   NULL,
    [Department_Name]        VARCHAR (100)   NULL,
    [Jobcode]                VARCHAR (100)   NULL,
    [Designation]            VARCHAR (100)   NULL,
    [AvaialbleFTE Below_M]   DECIMAL (10, 2) NULL,
    [Available Hours]        DECIMAL (10, 2) NULL,
    [MPS Effort]             DECIMAL (10, 2) NULL,
    [WorkProfile AD Effort]  DECIMAL (10, 2) NULL,
    [MAS Effort]             DECIMAL (10, 2) NULL,
    [Actual Effort]          DECIMAL (10, 2) NULL,
    [Associate Compliance %] DECIMAL (10, 2) NULL
);

