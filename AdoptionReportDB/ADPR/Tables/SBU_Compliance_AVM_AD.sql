CREATE TABLE [ADPR].[SBU_Compliance_AVM_AD] (
    [ID]                               BIGINT          IDENTITY (1, 1) NOT NULL,
    [SBU]                              VARCHAR (50)    NULL,
    [AVM #FTE]                         DECIMAL (10, 2) NULL,
    [AVM #FTE with TSC %=0]            DECIMAL (10, 2) NULL,
    [AVM #FTE with TSC %>0 to 25]      DECIMAL (10, 2) NULL,
    [AVM #FTE with TSC %>25 to 50]     DECIMAL (10, 2) NULL,
    [AVM #FTE with TSC %>50 to 80]     DECIMAL (10, 2) NULL,
    [AVM #FTE with TSC %>80]           DECIMAL (10, 2) NULL,
    [Available Hours]                  DECIMAL (10, 2) NULL,
    [MPS Effort]                       DECIMAL (10, 2) NULL,
    [WorkProfile AD]                   DECIMAL (10, 2) NULL,
    [MAS Effort]                       DECIMAL (10, 2) NULL,
    [Actual Effort]                    DECIMAL (10, 2) NULL,
    [BU Effort Compliance%(AVM)]       DECIMAL (10, 2) NULL,
    [AVM_Associate_Compliance_Percent] DECIMAL (10, 2) NULL
);

