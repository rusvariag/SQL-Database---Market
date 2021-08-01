/************************************************** Object: Drop System -- Script ID: 1 -- Lang : SQL ************************************************
-- Author:				  Ivan
-- Script Date: 		23/02/2020
-- Description:			Clean the database
*****************************************************************************************************************************************************/
IF OBJECT_ID('INVAPP.MKT_Quotes') IS NOT NULL
	DROP TABLE INVAPP.MKT_Quotes;
GO

IF OBJECT_ID('INVAPP.MKT_IndexWeights') IS NOT NULL
	DROP TABLE INVAPP.MKT_IndexWeights;
GO

IF OBJECT_ID('INVAPP.MKT_Indices') IS NOT NULL
	DROP TABLE INVAPP.MKT_Indices;
GO

IF OBJECT_ID('INVAPP.MKT_Securities') IS NOT NULL
	DROP TABLE INVAPP.MKT_Securities;
GO

/*****************************************************************************************************************************************************
-- Drop Create Schemas
*****************************************************************************************************************************************************/
IF EXISTS (SELECT name FROM sys.schemas WHERE name = N'INVOP')
	BEGIN
		DROP SCHEMA INVOP;
		EXEC('CREATE SCHEMA INVOP;');
	END
ELSE
	BEGIN
		EXEC('CREATE SCHEMA INVOP;');
	END
GO

IF EXISTS (SELECT name FROM sys.schemas WHERE name = N'INVREF')
	BEGIN
		DROP SCHEMA INVREF;
		EXEC('CREATE SCHEMA INVREF;');
	END
ELSE
	BEGIN
		EXEC('CREATE SCHEMA INVREF;');
	END
GO

IF EXISTS (SELECT name FROM sys.schemas WHERE name = N'INVAPP')
	BEGIN
		DROP SCHEMA INVAPP;
		EXEC('CREATE SCHEMA INVAPP;');
	END
ELSE
	BEGIN
		EXEC('CREATE SCHEMA INVAPP;');
	END
GO

/************************************************** Object: Create Table -- Script ID: 2 -- Lang : SQL ***********************************************
-- Author:				  Ivan
-- Script Date: 		23/02/2020
-- Description:			Create market tables + Unique constrain
*****************************************************************************************************************************************************/
CREATE TABLE INVREF.QuotesType (
    QuotesType_Key				INT					    NOT NULL	IDENTITY(1, 1),
    QuotesType					  VARCHAR(100)		NOT NULL,
	  Date_Created				  DATETIME			  NULL		DEFAULT CURRENT_TIMESTAMP,
    CreatedBy_UserID			VARCHAR(50)			NULL		DEFAULT	CURRENT_USER,
    Date_Updated				  DATETIME			  NULL		DEFAULT	CURRENT_TIMESTAMP,
    UpdatedBy_UserID			VARCHAR(50)			NULL		DEFAULT	CURRENT_USER,
    Record_Status				  SMALLINT			  NULL		DEFAULT 0,
	  CONSTRAINT PK_QuotesType PRIMARY KEY (QuotesType_Key),
);
GO

CREATE TABLE INVREF.SourceSystem (
    Source_Key					  INT					    NOT NULL	IDENTITY(1, 1),
    Source						    VARCHAR(100)		NOT NULL,
	  Rec_Insert_Date				DATETIME			  NULL		DEFAULT	CURRENT_TIMESTAMP,
	  Rec_Insert_User				VARCHAR(50)			NULL		DEFAULT	CURRENT_USER,
	  Rec_Update_Date				DATETIME			  NULL		DEFAULT	CURRENT_TIMESTAMP,
	  Rec_Update_User				VARCHAR(50)			NULL		DEFAULT	CURRENT_USER,
	  Rec_Delete_Flag				BIT					    NULL		DEFAULT 0,
	  CONSTRAINT PK_SourceSystem PRIMARY KEY (Source_Key),
);
GO

CREATE TABLE INVREF.EntityType (
	Entity_Type_Key				INT					  NOT NULL 	IDENTITY(1, 1),
	Entity_Type					  INT					  NOT NULL,
	Rec_Insert_Date				DATETIME			NULL		DEFAULT	CURRENT_TIMESTAMP,
	Rec_Insert_User				VARCHAR(50)   NULL		DEFAULT	CURRENT_USER,
	Rec_Update_Date				DATETIME			NULL		DEFAULT	CURRENT_TIMESTAMP,
	Rec_Update_User				VARCHAR(50)   NULL		DEFAULT	CURRENT_USER,
	Rec_Delete_Flag				BIT					  NULL		DEFAULT 0,
	CONSTRAINT PK_EntityType PRIMARY KEY (Entity_Type_Key),
);
GO

CREATE TABLE INVREF.Entity (
	Entity_Key					  INT					  NOT NULL 	IDENTITY(1, 1),
	Entity_Type_Key				INT					  NOT NULL,
	Rec_Insert_Date				DATETIME			NULL		DEFAULT	CURRENT_TIMESTAMP,
	Rec_Insert_User				VARCHAR(50)   NULL		DEFAULT	CURRENT_USER,
	Rec_Update_Date				DATETIME			NULL		DEFAULT	CURRENT_TIMESTAMP,
	Rec_Update_User				VARCHAR(50)   NULL		DEFAULT	CURRENT_USER,
	Rec_Delete_Flag				BIT					  NULL		DEFAULT 0,
	CONSTRAINT PK_MKT_Entity PRIMARY KEY (Entity_Key),
);
GO

CREATE TABLE INVAPP.IndexWeights (
	Row_Key						    INT 				    NOT NULL	IDENTITY(1, 1),
	DateKey						    DATE				    NOT NULL,
	Security_Key				  INT					    NOT NULL	FOREIGN KEY REFERENCES INVREF.Entity(Entity_Key),
	Index_Key					    INT					    NOT NULL	FOREIGN KEY REFERENCES INVREF.Entity(Entity_Key),
	Weights						    DECIMAL(10, 8)  NULL		DEFAULT 0,
	Rec_Insert_Date				DATETIME			  NULL		DEFAULT	CURRENT_TIMESTAMP,
	Rec_Insert_User				VARCHAR(50)			NULL		DEFAULT	CURRENT_USER,
	Rec_Update_Date				DATETIME			  NULL		DEFAULT	CURRENT_TIMESTAMP,
	Rec_Update_User				VARCHAR(50)			NULL		DEFAULT	CURRENT_USER,
	Rec_Delete_Flag				BIT					    NULL		DEFAULT 0,
	CONSTRAINT PK_IndexWeights PRIMARY KEY (Row_Key),
	CONSTRAINT UN_IndexWeights UNIQUE (DateKey, Security_Key, Index_Key) WHERE Record_Status = 0
);
GO

CREATE TABLE INVAPP.Quotes (
	Row_Key						    INT					    NOT NULL	IDENTITY(1, 1),
	Entity_Key					  INT					    NOT NULL	FOREIGN KEY REFERENCES INVREF.Entity(Entity_Key),
	DateKey						    DATE				    NOT NULL,
	QuotesType_Key				INT					    NOT NULL	FOREIGN KEY REFERENCES INVREF.QuotesType(QuotesType_Key),
	Source_Key					  INT					    NOT NULL	FOREIGN KEY REFERENCES INVREF.SourceSystem(Source_Key),
	DateTimeStamp				  TIME				    NOT NULL	DEFAULT '00:00:00.000',
	BaseCurrency_Key			INT					    NOT NULL  FOREIGN KEY REFERENCES INVREF.Entity(Entity_Key),
	Quotes						    DECIMAL(18, 6)  NOT NULL	CHECK (Quotes >= 0),
	Rec_Insert_Date				DATETIME			  NULL		  DEFAULT	CURRENT_TIMESTAMP,
	Rec_Insert_User				VARCHAR(50)			NULL		  DEFAULT	CURRENT_USER,
	Rec_Update_Date				DATETIME			  NULL		  DEFAULT	CURRENT_TIMESTAMP,
	Rec_Update_User				VARCHAR(50)			NULL		  DEFAULT	CURRENT_USER,
	Rec_Delete_Flag				BIT					    NULL		  DEFAULT 0,
  CONSTRAINT PK_Quotes PRIMARY KEY (Row_Key),
	CONSTRAINT UN_Quotes UNIQUE (Entity_Key, DateKey, QuotesType_Key, Source_Key, DateTimeStamp, BaseCurrency_Key) WHERE Record_Status = 0,
	CONSTRAINT FK_FRX_Quotes_Entity_Entity_Key FOREIGN KEY (Entity_Key) REFERENCES INVREF.Entity(Entity_Key),
	CONSTRAINT FK_FRX_Quotes_QuotesType_QuotesType_Key FOREIGN KEY (QuotesType_Key) REFERENCES INVREF.QuotesType(QuotesType_Key),
	CONSTRAINT FK_FRX_Quotes_Source_Source_Key FOREIGN KEY (Source_Key) REFERENCES INVREF.SourceSystem(Source_Key),
	CONSTRAINT FK_FRX_Quotes_Entity_BaseCurrency_Key FOREIGN KEY (BaseCurrency_Key) REFERENCES INVREF.Entity(Entity_Key)
);
GO
