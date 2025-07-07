CREATE TABLE [ADPR].[AdoptionTotalEligibleProjects] (
    [ID]                              INT           IDENTITY (1, 1) NOT NULL,
    [EsaProjectId]                    NVARCHAR (50) NOT NULL,
    [ESAProjectName]                  NVARCHAR (50) NOT NULL,
    [AccountId]                       NVARCHAR (50) NOT NULL,
    [AccountName]                     NVARCHAR (50) NOT NULL,
    [Market]                          NVARCHAR (50) NULL,
    [SBU_Delivery]                    NVARCHAR (50) NULL,
    [Archetype]                       NVARCHAR (50) NULL,
    [FinalScope]                      NVARCHAR (50) NOT NULL,
    [DEx Assessment feasibility flag] NVARCHAR (50) NULL,
    [Esa Project Category]            NVARCHAR (50) NULL,
    [IsPerformanceSharingRestricted]  NVARCHAR (50) NULL,
    [3x3 Matrix]                      NVARCHAR (50) NULL,
    [OnBoardStatus]                   VARCHAR (50)  NULL,
    [Client_Practice]                 NVARCHAR (50) NULL
);

