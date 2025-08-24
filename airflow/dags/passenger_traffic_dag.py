from airflow import DAG
from airflow.operators.postgres_operator import PostgresOperator
from airflow.operators.dummy_operator import DummyOperator
from datetime import datetime, timedelta

DEFAULT_ARGS = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 3, 14),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'execution_timeout': timedelta(minutes=60)
}


first =  '''
    CREATE SCHEMA IF NOT EXISTS presentation;
'''

second = '''
    DROP TABLE IF EXISTS presentation.passenger_traffic;


    CREATE TABLE IF NOT EXISTS presentation.passenger_traffic (
         created_at timestamp,
         flight_date date,
         airport_code char(3),
         linked_airport_code char(3),
         flights_in integer,
         flights_out integer,
         passengers_in integer,
         passengers_out integer);
'''

third = """
        WITH arrivals AS (
          SELECT
            date(actual_arrival) AS flight_date,
            arrival_airport AS airport_code,
            departure_airport AS linked_airport_code,
            count(*) AS flights_in,
            count(ltf.hub_ticket_id) AS passengers_in
          FROM dwh_detailed.sat_flights f
          LEFT JOIN dwh_detailed.link_ticket_flights ltf
            ON f.hub_flight_id = ltf.hub_flight_id
          WHERE actual_arrival IS NOT NULL
            AND date(actual_arrival) = DATE '{{ macros.ds_add(ds, -1) }}'
          GROUP BY date(actual_arrival), arrival_airport, departure_airport
        ),
        departures AS (
          SELECT
            date(actual_departure) AS flight_date,
            departure_airport AS airport_code,
            arrival_airport AS linked_airport_code,
            count(*) AS flights_out,
            count(ltf.hub_ticket_id) AS passengers_out
          FROM dwh_detailed.sat_flights f
          LEFT JOIN dwh_detailed.link_ticket_flights ltf
            ON f.hub_flight_id = ltf.hub_flight_id
          WHERE actual_departure IS NOT NULL
            AND date(actual_departure) = DATE '{{ macros.ds_add(ds, -1) }}'
          GROUP BY date(actual_departure), departure_airport, arrival_airport
        )
        INSERT INTO presentation.passenger_traffic
        SELECT
          now() AS created_at,
          COALESCE(a.flight_date, d.flight_date) AS flight_date,
          COALESCE(a.airport_code, d.airport_code) AS airport_code,
          COALESCE(a.linked_airport_code, d.linked_airport_code) AS linked_airport_code,
          COALESCE(a.flights_in, 0) AS flights_in,
          COALESCE(d.flights_out, 0) AS flights_out,
          COALESCE(a.passengers_in, 0) AS passengers_in,
          COALESCE(d.passengers_out, 0) AS passengers_out
        FROM arrivals a
        FULL OUTER JOIN departures d
          ON a.flight_date = d.flight_date
          AND a.airport_code = d.airport_code
          AND a.linked_airport_code = d.linked_airport_code;
        """



with DAG(
    'passanger_traffic',
    default_args=DEFAULT_ARGS,
    schedule_interval='0 3 * * *', 
    catchup=False,
    max_active_runs=1,
    concurrency=1
) as dag:
    
    start = DummyOperator(task_id='start')

    first = PostgresOperator(
        task_id="creare1",
        postgres_conn_id="postgres_dwh",
        sql = first
    )
    second = PostgresOperator(
        task_id="creare2",
        postgres_conn_id="postgres_dwh",
        sql = second
    )
    third = PostgresOperator(
        task_id="do_work",
        postgres_conn_id="postgres_dwh",
        sql = third
    )
    
    
    end = DummyOperator(task_id='end')
    
    start >> first >> second >> third  >> end
