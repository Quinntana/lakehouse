# Lakehouse Playground

![check](https://github.com/Quinntana/lakehouse/tree/development)

Supported Data Pipeline Components

| Pipeline Component                     | Version | Description              |
|----------------------------------------|---------|--------------------------|
| [Trino](https://trino.io/)             | 425+    | Query Engine             |
| [DBT](https://www.getdbt.com/)         | 1.5+    | Analytics Framework      |
| [Spark](https://spark.apache.org/)     | 3.4+    | Computing Engine         |
| [Flink](https://flink.apache.org/)     | 1.16+   | Streaming Engine         |
| [Iceberg](https://iceberg.apache.org/) | 1.3.1+  | Table Format (Lakehouse) |
| [Airflow](https://airflow.apache.org/) | 2.7+    | Scheduler                |
| [Kafka](https://kafka.apache.org/)     | 3.4+    | Messaging Broker         |
| [Debezium](https://debezium.io/)       | 2.3+    | CDC Connector            |
| [MinIO](https://min.io/)               | Latest  | Object Storage           |
| [Dremio](https://www.dremio.com/)      | Latest  | Data Lake Engine         |

## Getting Started

Follow these steps to set up and run the lakehouse pipeline on your local machine using Docker (tested with the latest Docker version on WSL without Docker Desktop).

### Setting Up the Pipeline

1. **Start all containers:**

   ```bash
   make compose.clean compose.freshstart
   ```

   This command cleans any existing volumes and starts all necessary containers (`Kafka`, `Zookeeper`, `Debezium`, `MySQL`, `MinIO`, `Hive Metastore`, `Trino`, `Spark`, `Flink`, `Airflow`, `Dremio`) in detached mode with a fresh build.

2. **Register Debezium connectors:**

   ```bash
   make debezium.register
   ```

   Registers the Debezium connectors to capture changes from the MySQL database (`inventory.customers` and `inventory.products`) and stream them to Kafka topics.

3. **Create the datalake bucket in MinIO:**

   - Access the MinIO web UI at [http://localhost:9001/](http://localhost:9001/)
   - Log in with username `minio` and password `minio123`
   - Create a bucket named `datalake` (if not already created by `minio-job`).

4. **Run Flink SQL scripts for streaming ingestion:**

   - Access the Flink shell:

     ```bash
     make flink.shell
     ```

   - Inside the Flink container, set the Hadoop classpath and run the SQL script:

     ```bash
     export HADOOP_CLASSPATH=`/opt/hadoop/bin/hadoop classpath`
     /opt/flink/bin/sql-client.sh embedded -f /opt/flink-client/flink-sql-demo.sql
     ```

   This sets up the Iceberg catalog and streams data from Kafka to Iceberg tables in MinIO.

5. **Run dbt models via Airflow:**

   - Access the Airflow web UI at [http://localhost:8080/](http://localhost:8080/) (username: `airflow`, password: `airflow`)
   - Trigger the `dag_dbt` DAG to run dbt models using the Spark profile.

   Alternatively, run dbt manually inside the Airflow container:

   ```bash
   make airflow.shell
   dbt run --profiles-dir . --profile spark --target dev
   ```

6. **Configure Dremio for querying:**

   - Access the Dremio web UI at [http://localhost:9047/](http://localhost:9047/)
   - Sign up and log in as an admin user.
   - Add a new hive.s3 source:
     - Type: hive.s3
     - Name: `HiveMetastore`
     - Hive Metastore Host: `hive-metastore`
     - Port: `9083`
     - Enable "Advanced Options"
     - Connection Properties:
       - `fs.s3a.endpoint`: `minio:9000`
       - `fs.s3a.path.style.access`: `true`
       - `fs.s3a.connection.ssl.enabled`: `false`
       - `dremio.s3.compat`: `true`
       - `fs.s3a.aws.credentials.provider`: `org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider`
    - Credentials:
       - `fs.s3a.access.key`: `minio`
       - `fs.s3a.secret.key`: `minio123`
   - Save the source and query the Iceberg tables.

### Accessing Pipeline Components

- **Airflow UI**: [http://localhost:8080/](http://localhost:8080/) (`airflow` / `airflow`)
- **Dremio UI**: [http://localhost:9047/](http://localhost:9047/)
- **MinIO UI**: [http://localhost:9001/](http://localhost:9001/) (`minio` / `minio123`)
- **Kafka UI**: [http://localhost:8088/](http://localhost:8088/)
- **Kafka Connect UI**: [http://localhost:8089/](http://localhost:8089/)
- **Flink Job Manager UI**: [http://localhost:8082/](http://localhost:8082/)
- **Trino CLI**: `make trino.cli`
- **Spark Thrift Server**: `make spark.cli` (connects via `jdbc:hive2://spark-thrift:10000`)
- **Jupyter Notebook (Spark/Iceberg)**: [http://localhost:8900/](http://localhost:8900/)

## Screenshots

### Flink Job Manager UI
![flink](./docs/images/flink.png)

### Kafka UI
![kafka](./docs/images/kafka.png)

### Minio UI
![minio](./docs/images/minio.png)

### Running Local Flink Application in IDEA
![kafka](./docs/images/application.png)
