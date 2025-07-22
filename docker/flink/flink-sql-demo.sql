CREATE CATALOG iceberg WITH (
    'type'='iceberg',
    'metastore' = 'hive',
    'uri'='thrift://hive-metastore:9083',
    'clients'='5',
    'property-version'='1',
    'warehouse'='s3a://datalake/iceberg'
);

CREATE DATABASE IF NOT EXISTS iceberg.flink;
set sql-client.execution.runtime-mode=STREAMING;
set sql-client.execution.result-mode=TABLEAU;
set sql-client.verbose=true;
SET execution.checkpointing.interval = 10000;

CREATE TABLE IF NOT EXISTS kafka_customers (
  id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  op STRING,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'kafka',
  'topic' = 'cdc-json.inventory.data.inventory.customers',
  'properties.bootstrap.servers' = 'kafka1:29092',
  'properties.group.id' = 'flink-consumer-group',
  'properties.request.timeout.ms' = '30000',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'debezium-json',
  'debezium-json.schema-include' = 'true'
);

DROP TABLE IF EXISTS iceberg.flink.iceberg_customers;

-- Iceberg sink: Customers
CREATE TABLE IF NOT EXISTS iceberg.flink.iceberg_customers (
  id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'write.upsert.enabled' = 'true',
  'format-version' = '2',
  'catalog-name' = 'iceberg',
  'catalog-type' = 'hive',
  'uri' = 'thrift://hive-metastore:9083',
  'warehouse' = 's3a://datalake/iceberg'
);

-- Stream data to Iceberg
INSERT INTO iceberg.flink.iceberg_customers
SELECT id, first_name, last_name, email
FROM kafka_customers;
