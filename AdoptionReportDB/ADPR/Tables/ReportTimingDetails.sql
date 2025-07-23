CREATE TABLE [ADPR].[ReportTimingDetails] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [ReportType]         NVARCHAR (10) NULL,
    [JobMode]            NVARCHAR (10) NULL,
    [Weekly_JobRunDate]  DATETIME      NULL,
    [Monthly_JobRunDate] DATETIME      NULL,
    [IsDeleted]          BIT           NULL,
    [CreatedBy]          NVARCHAR (10) NULL,
    [CreatedDate]        DATETIME      NULL
);

