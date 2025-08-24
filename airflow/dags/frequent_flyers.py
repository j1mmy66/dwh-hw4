from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.operators.empty import EmptyOperator
from datetime import datetime, timedelta

DEFAULT_ARGS = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 3, 14),
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'execution_timeout': timedelta(minutes=60)
}

create_schema_sql = '''
CREATE SCHEMA IF NOT EXISTS presentation;
'''

create_table_sql = '''
CREATE TABLE IF NOT EXISTS presentation.frequent_flyers (
    created_at TIMESTAMP DEFAULT NOW(),
    passenger_id VARCHAR(20),
    passenger_name TEXT,
    flights_number INTEGER,
    purchase_sum NUMERIC(10, 2),
    home_airport CHAR(3),
    customer_group VARCHAR(5),
    CONSTRAINT pk_frequent_flyers PRIMARY KEY (passenger_id)
);

DELETE FROM presentation.frequent_flyers
WHERE created_at < DATE_TRUNC('day', NOW()) - INTERVAL '1 day';
'''

insert_data_sql = """
WITH stats_passenger AS (
    SELECT
        t.passenger_id,
        t.passenger_name,
        COUNT(*) AS flights_number,
        SUM(b.total_amount) AS purchase_sum
    FROM dwh_detailed.sat_tickets t
    JOIN dwh_detailed.hub_bookings hb 
        ON t.book_ref = hb.book_ref
    JOIN dwh_detailed.sat_bookings b 
        ON hb.hub_booking_id = b.hub_booking_id
    JOIN dwh_detailed.link_ticket_flights ltf 
        ON t.hub_ticket_id = ltf.hub_ticket_id
    JOIN dwh_detailed.sat_flights f 
        ON ltf.hub_flight_id = f.hub_flight_id
    GROUP BY t.passenger_id, t.passenger_name
),
stats_airport AS (
    SELECT
        t.passenger_id,
        f.departure_airport AS airport_code,
        COUNT(*) AS flight_count,
        ROW_NUMBER() OVER (PARTITION BY t.passenger_id ORDER BY COUNT(*) DESC, f.departure_airport) AS rank
    FROM dwh_detailed.sat_tickets t
    JOIN dwh_detailed.link_ticket_flights ltf 
        ON t.hub_ticket_id = ltf.hub_ticket_id
    JOIN dwh_detailed.sat_flights f 
        ON ltf.hub_flight_id = f.hub_flight_id
    GROUP BY t.passenger_id, f.departure_airport
),
gmv AS (
    SELECT
        passenger_id,
        purchase_sum,
        PERCENT_RANK() OVER (ORDER BY purchase_sum DESC) AS percentile
    FROM stats_passenger
)
INSERT INTO presentation.frequent_flyers (
    passenger_id, passenger_name, flights_number, purchase_sum, home_airport, customer_group
)
SELECT
    ps.passenger_id, 
    ps.passenger_name, 
    ps.flights_number, 
    ps.purchase_sum, 
    a.airport_code AS home_airport,
    CASE
        WHEN percentile <= 0.05 THEN '5'
        WHEN percentile <= 0.1 THEN '10'
        WHEN percentile <= 0.25 THEN '25'
        WHEN percentile <= 0.5 THEN '50'
        ELSE '50+'
    END AS customer_group
FROM stats_passenger ps
LEFT JOIN stats_airport a
    ON ps.passenger_id = a.passenger_id AND a.rank = 1
LEFT JOIN gmv g
    ON ps.passenger_id = g.passenger_id;
"""

with DAG(
    "frequent_flyers",
    default_args=DEFAULT_ARGS,
    schedule_interval='0 2 * * *', 
    catchup=False,
    max_active_runs=1,
    concurrency=1
) as dag:
    
    start = EmptyOperator(task_id="start")
    
    create_schema = PostgresOperator(
        task_id="create_schema",
        postgres_conn_id="postgres_dwh",
        sql=create_schema_sql
    )
    
    create_table = PostgresOperator(
        task_id="create_table",
        postgres_conn_id="postgres_dwh",
        sql=create_table_sql
    )
    
    insert_data = PostgresOperator(
        task_id="insert_data",
        postgres_conn_id="postgres_dwh",
        sql=insert_data_sql
    )
    
    end = EmptyOperator(task_id="end")
    
    start >> create_schema >> create_table >> insert_data >> end