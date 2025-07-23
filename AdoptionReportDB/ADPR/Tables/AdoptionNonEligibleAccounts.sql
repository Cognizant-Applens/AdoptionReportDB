CREATE TABLE [ADPR].[AdoptionNonEligibleAccounts] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [AccountId]          INT           NOT NULL,
    [AccountName]        NVARCHAR (50) NULL,
    [IsAdoptionEligible] BIT           CONSTRAINT [DF_ADPR.AdoptionNonEligibleAccounts_IsAdoptionEligible] DEFAULT ((0)) NOT NULL
);

