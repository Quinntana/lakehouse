# Use the official Airflow image as base
FROM apache/airflow:2.7.0-python3.10

# Switch to root to install system dependencies
USER root

# Install system dependencies required to build `sasl`, `thrift-sasl`, etc.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libldap2-dev \
        python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch back to airflow user (required for pip installs)
USER airflow

# Install Python dependencies
RUN pip install --no-cache-dir \
    "apache-airflow==2.7.0" \
    "dbt-core" \
    "dbt-trino" \
    "trino" \
    "dbt-spark[PyHive]" \
    "thrift-sasl"
