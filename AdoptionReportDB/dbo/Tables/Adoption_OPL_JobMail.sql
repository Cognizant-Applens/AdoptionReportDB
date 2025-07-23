CREATE TABLE [dbo].[Adoption_OPL_JobMail] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeName]  NVARCHAR (100) NOT NULL,
    [EmployeeEmail] NVARCHAR (100) NOT NULL,
    [IsActive]      BIT            NOT NULL,
    [CreatedDate]   DATETIME       NULL,
    [CreatedBy]     NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    CONSTRAINT [PK_OPL_JOBMAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);

