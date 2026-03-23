## Storage Systems

* Data Warehouse (e.g., Redshift, Snowflake, BigQuery): Used for structured, historical patient data to support readmission risk prediction, reporting, and analytics. Optimized for ML training, aggregations, and OLAP queries.

* Vector Database (e.g., Pinecone, Weaviate, FAISS): Stores embeddings of patient records and clinical notes to enable semantic search and natural language queries by doctors.

* Time-Series Database (e.g., InfluxDB, TimescaleDB): Handles real-time ICU vitals (heart rate, oxygen levels, etc.) with high-frequency writes and time-based queries.

* Data Lake (e.g., S3, Azure Data Lake): Central repository for raw, semi-structured, and unstructured data, acting as a staging layer before transformation and loading into other systems.



## OLTP vs OLAP Boundary

* OLTP systems: Hospital operational systems like EHR, billing, and ICU devices that handle real-time transactions (admissions, updates, vitals).
* Boundary: At the ETL/ingestion layer, where data is extracted, cleaned, and transformed.
* OLAP systems: Data Warehouse and Data Lake used for analytics, reporting, and ML. OLTP is write-heavy and real-time; OLAP is read-heavy and analytical.



## Trade-offs

A key trade-off is data consistency vs. performance and scalability. Real-time syncing between operational and analytical systems can introduce latency and complexity.

Mitigation:

* Use streaming pipelines (e.g., Kafka) for real-time data like ICU vitals
* Use batch ETL for less time-sensitive data
* Add validation and reconciliation checks to ensure data consistency

This balances timely insights with scalability and reliability.
