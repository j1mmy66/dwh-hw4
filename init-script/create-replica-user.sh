#!/bin/bash
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'my_replicator_password';
  -- Физический слот для реплики
  SELECT * FROM pg_create_physical_replication_slot('replication_slot_slave1');
  -- Логический слот для Debezium (используем плагин pgoutput)
  SELECT * FROM pg_create_logical_replication_slot('replication_slot_debezium', 'pgoutput');
EOSQL