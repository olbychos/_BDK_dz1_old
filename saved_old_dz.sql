--base actions:login
CREATE LOGIN babych_final WITH PASSWORD='pass' ;
GO
--schema
CREATE SCHEMA o_babych_schema;
GO
--user and manage him to being as owner
CREATE USER o_babych_f FROM LOGIN babych_final WITH DEFAULT_SCHEMA = "o_babych_schema";
GO
EXEC sp_addrolemember 'db_owner', o_babych_f
GO
--ext file
CREATE EXTERNAL FILE FORMAT babych_file
WITH (FORMAT_TYPE = DELIMITEDTEXT,
      FORMAT_OPTIONS(
          FIELD_TERMINATOR = ',',
          STRING_DELIMITER = '"',
          First_Row=2,
          USE_TYPE_DEFAULT = True)
)
GO
--db 
CREATE DATABASE SCOPED CREDENTIAL o_babych_cred
WITH IDENTITY ='o_babych_f',
     SECRET = 'keytoblob'
GO
--external data
CREATE EXTERNAL DATA SOURCE o_babych_blob
 WITH (TYPE = HADOOP,
       LOCATION = 'wasbs://babychcontainer@bigdataschoolst01.blob.core.windows.net',
       CREDENTIAL= [o_babych_cred]); 
CREATE TABLE [o_babych_schema2].[fact_tripdata]
(
    [VendorID] int NOT NULL,
    [tpep_pickup_datetime]  datetime NOT NULL,
    [tpep_dropoff_datetime] datetime NOT NULL,
    [passenger_count] int,
    [trip_distance] real,
    [RatecodeID] int NOT NULL,
    [store_and_fwd_flag] char(1),
    [PULocationID] int,
    [DOLocationID] int,
    [payment_type] int NOT NULL,
    [fare_amount] real, 
    [extra] real,
    [mta_tax] real,
    [tip_amount] real,
    [tolls_amount] real,
    [improvement_surcharge] real,
    [total_amount] real,
    [congestion_surcharge] real
) WITH (
    CLUSTERED COLUMNSTORE INDEX,  
    DISTRIBUTION = HASH([tpep_pickup_datetime])
)
GO

-- import hash  table from ext table
INSERT INTO [o_babych_schema].[fact_tripdata] ([VendorID]
      ,[tpep_pickup_datetime]
      ,[tpep_dropoff_datetime]
      ,[passenger_count]
      ,[trip_distance]
      ,[RatecodeID]
      ,[store_and_fwd_flag]
      ,[PULocationID]
      ,[DOLocationID]
      ,[payment_type]
      ,[fare_amount]
      ,[extra]
      ,[mta_tax]
      ,[tip_amount]
      ,[tolls_amount]
      ,[improvement_surcharge]
      ,[total_amount]
      ,[congestion_surcharge])

SELECT  [VendorID]
      ,[tpep_pickup_datetime]
      ,[tpep_dropoff_datetime]
      ,[passenger_count]
      ,[trip_distance]
      ,[RatecodeID]
      ,[store_and_fwd_flag]
      ,[PULocationID]
      ,[DOLocationID]
      ,[payment_type]
      ,[fare_amount]
      ,[extra]
      ,[mta_tax]
      ,[tip_amount]
      ,[tolls_amount]
      ,[improvement_surcharge]
      ,[total_amount]
      ,[congestion_surcharge]
  FROM [o_babych_schema].[yellow_trip_2020_01_external]
GO
CREATE TABLE [o_babych_schema].[Vendor] (
    [ID] int NOT NULL,
    [Name] varchar(255)
)  WITH
  (
    CLUSTERED COLUMNSTORE INDEX,  
    DISTRIBUTION = REPLICATE  
  ) 

INSERT INTO   [o_babych_schema].[Vendor] (ID, Name) VALUES (1, 'Creative Mobile Technologies, LLC');
INSERT INTO   [o_babych_schema].[Vendor] (ID, Name) VALUES (2, 'VeriFone Inc.');

CREATE TABLE [o_babych_schema2].[RateCode] (
    [ID] int NOT NULL,
    [Name] varchar(50)
)  WITH
  (
    CLUSTERED COLUMNSTORE INDEX,  
    DISTRIBUTION = REPLICATE  
  ); 
  
INSERT INTO   [o_babych_schema].[RateCode] (ID, Name) VALUES (1, 'Standard rate');
INSERT INTO   [o_babych_schema].[RateCode] (ID, Name) VALUES (2, 'JFK');
INSERT INTO   [o_babych_schema].[RateCode] (ID, Name) VALUES (3, 'Newark');
INSERT INTO   [o_babych_schema].[RateCode] (ID, Name) VALUES (4, 'Nassau or Westchester');
INSERT INTO   [o_babych_schema].[RateCode] (ID, Name) VALUES (5, 'Negotiated fare');
INSERT INTO   [o_babych_schema].[RateCode] (ID, Name) VALUES (6, 'Group ride');
INSERT INTO   [o_babych_schema].[RateCode] (ID, Name) VALUES (99, NULL);


CREATE TABLE  [o_babych_schema].[Payment_type]
(
    [ID] int NOT NULL,
    [Name] varchar(50) NOT NULL
) WITH
  (
    CLUSTERED COLUMNSTORE INDEX,  
    DISTRIBUTION = REPLICATE  
  ); 
  
INSERT INTO  [o_babych_schema].[Payment_type] (ID, Name) VALUES (1, 'Credit card');
INSERT INTO  [o_babych_schema].[Payment_type] (ID, Name) VALUES (2, 'Cash');
INSERT INTO  [o_babych_schema].[Payment_type] (ID, Name) VALUES (3, 'No charge');
INSERT INTO  [o_babych_schema].[Payment_type] (ID, Name) VALUES (4, 'Dispute');
INSERT INTO  [o_babych_schema].[Payment_type] (ID, Name) VALUES (5, 'Unknown');
INSERT INTO  [o_babych_schema].[Payment_type] (ID, Name) VALUES (6, 'Voided trip');
