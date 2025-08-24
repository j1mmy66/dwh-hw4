#!/bin/bash
set -e

echo "Clearing data..."
rm -rf ./data/*
rm -rf ./data-slave/*
rm -rf ./data-dwh/*
rm -rf ./airflow/airflow_db_data/*
docker compose down

echo "Starting postgres_master node..."
docker compose up -d postgres_master
echo "Waiting for postgres_master to initialize..."
sleep 30

echo "Preparing replication config on master..."
docker exec -it postgres_master sh /etc/postgresql/init-script/init.sh

echo "Restarting postgres_master to apply changes..."
docker compose restart postgres_master
sleep 15

echo "Starting postgres_slave node..."
docker compose up -d postgres_slave
echo "Waiting for postgres_slave to initialize..."
sleep 15

echo "Starting postgres_dwh node..."
docker compose up -d postgres_dwh
echo "Waiting for postgres_dwh to initialize..."
sleep 15

echo "Starting Metabase..."
docker compose up -d metabase
echo "Waiting for Metabase to be ready..."
sleep 20

echo "Проверяем наличие тестовых данных в postgres_dwh..."
row_count=$(docker exec postgres_dwh psql -U postgres -d postgres -t -c "SELECT count(*) FROM dwh_detailed.hub_flights;" | tr -d '[:space:]')
if [ "$row_count" -eq "0" ]; then
    echo "Тестовые данные не обнаружены (0 строк в hub_flights). Применяем скрипт populate_test_data.sql..."
    cat init-test-data/populate_test_data.sql | docker exec -i postgres_dwh psql -U postgres -d postgres
else
    echo "Тестовые данные уже присутствуют (в hub_flights $row_count строк). Пропускаем запуск тестового скрипта."
fi

echo "Starting Zookeeper and Kafka..."
docker compose up -d zookeeper kafka
echo "Waiting for Kafka to be ready..."
sleep 15

echo "Starting Debezium connector service..."
docker compose up -d debezium
sleep 45

curl -X POST -H "Content-Type: application/json" \
     --data @debezium-postgres-connector.json \
     http://localhost:8083/connectors

echo "Starting DMP service..."
docker compose up -d dmp_service
sleep 10

echo "Инициализация базы данных Airflow и создание пользователя..."
docker compose up -d airflow_init
echo "Ожидаем завершения инициализации Airflow (примерно 20 секунд)..."
sleep 20

echo "Запуск планировщика и веб-сервера Airflow..."
docker compose up -d airflow_scheduler airflow_webserver
sleep 15

echo "All services are up and running."