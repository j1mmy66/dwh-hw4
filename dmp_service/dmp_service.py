import os
import json
import time
import logging
from confluent_kafka import Consumer, KafkaException
import psycopg2
from psycopg2 import sql

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("dmp_service")

KAFKA_BOOTSTRAP_SERVERS = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:29092")
KAFKA_GROUP_ID = os.getenv("KAFKA_GROUP_ID", "dmp-service-group")
KAFKA_TOPICS = os.getenv("KAFKA_TOPICS", "masterdb.public.airports,masterdb.public.aircrafts,masterdb.public.seats,masterdb.public.flights,masterdb.public.bookings,masterdb.public.tickets,masterdb.public.ticket_flights,masterdb.public.boarding_passes").split(',')

DWH_HOST = os.getenv("DWH_HOST", "postgres_dwh")
DWH_PORT = os.getenv("DWH_PORT", "5432")
DWH_USER = os.getenv("DWH_USER", "postgres")
DWH_PASSWORD = os.getenv("DWH_PASSWORD", "postgres")
DWH_DB = os.getenv("DWH_DB", "postgres")

def get_dwh_connection():
    conn = psycopg2.connect(
        host=DWH_HOST,
        port=DWH_PORT,
        user=DWH_USER,
        password=DWH_PASSWORD,
        dbname=DWH_DB
    )
    conn.autocommit = True
    return conn

def process_bookings_event(payload, dwh_conn):
    data = payload.get("after")
    if data is None:
        logger.info("Удаление или событие без after для bookings – пропускаем")
        return

    book_ref = data.get("book_ref")
    book_date = data.get("book_date")
    total_amount = data.get("total_amount")

    record_source = "postgres_master" 
    load_date = time.strftime("%Y-%m-%d %H:%M:%S")

    try:
        with dwh_conn.cursor() as cur:
            insert_hub = """
                INSERT INTO dwh_detailed.hub_bookings (book_ref, record_source, load_date)
                VALUES (%s, %s, %s)
                ON CONFLICT (book_ref) DO NOTHING;
            """
            cur.execute(insert_hub, (book_ref, record_source, load_date))

            select_hub = "SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = %s;"
            cur.execute(select_hub, (book_ref,))
            hub_booking_id = cur.fetchone()[0]

            insert_sat = """
                INSERT INTO dwh_detailed.sat_bookings (hub_booking_id, book_date, total_amount, effective_from, record_source, load_date)
                VALUES (%s, %s, %s, NOW(), %s, %s);
            """
            cur.execute(insert_sat, (hub_booking_id, book_date, total_amount, record_source, load_date))
            logger.info(f"Processed bookings event for book_ref={book_ref}")
    except Exception as e:
        logger.exception(f"Ошибка при обработке bookings: {e}")

def process_flights_event(payload, dwh_conn):
    data = payload.get("after")
    if data is None:
        logger.info("Удаление или событие без after для flights – пропускаем")
        return

    flight_no = data.get("flight_no")
    scheduled_departure = data.get("scheduled_departure")
    scheduled_arrival = data.get("scheduled_arrival")
    departure_airport = data.get("departure_airport")
    arrival_airport = data.get("arrival_airport")
    status = data.get("status")
    aircraft_code = data.get("aircraft_code")
    actual_departure = data.get("actual_departure")
    actual_arrival = data.get("actual_arrival")

    record_source = "postgres_master"
    load_date = time.strftime("%Y-%m-%d %H:%M:%S")

    try:
        with dwh_conn.cursor() as cur:
            insert_hub = """
                INSERT INTO dwh_detailed.hub_flights (flight_no, scheduled_departure, record_source, load_date)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (flight_no, scheduled_departure) DO NOTHING;
            """
            cur.execute(insert_hub, (flight_no, scheduled_departure, record_source, load_date))

            select_hub = "SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = %s AND scheduled_departure = %s;"
            cur.execute(select_hub, (flight_no, scheduled_departure))
            hub_flight_id = cur.fetchone()[0]

            insert_sat = """
                INSERT INTO dwh_detailed.sat_flights (hub_flight_id, scheduled_arrival, departure_airport, arrival_airport, status, aircraft_code, actual_departure, actual_arrival, effective_from, record_source, load_date)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NOW(), %s, %s);
            """
            cur.execute(insert_sat, (hub_flight_id, scheduled_arrival, departure_airport, arrival_airport,
                                       status, aircraft_code, actual_departure, actual_arrival, record_source, load_date))
            logger.info(f"Processed flights event for flight_no={flight_no}")
    except Exception as e:
        logger.exception(f"Ошибка при обработке flights: {e}")

def process_event(message_value, dwh_conn):
    try:
        payload = message_value.get("payload")
        if payload is None:
            logger.warning("Нет payload в сообщении")
            return

        op = payload.get("op")
        if op not in ("c", "r"):
            logger.info(f"Пропускаем событие с op={op}")
            return

        source = payload.get("source", {})
        table = source.get("table")
        if not table:
            logger.warning("Не указан table в source")
            return

        if table == "bookings":
            process_bookings_event(payload, dwh_conn)
        elif table == "flights":
            process_flights_event(payload, dwh_conn)
        else:
            logger.info(f"Для таблицы {table} обработчик не реализован – событие пропущено")
    except Exception as e:
        logger.exception(f"Ошибка при обработке события: {e}")

def main():
    kafka_conf = {
        'bootstrap.servers': KAFKA_BOOTSTRAP_SERVERS,
        'group.id': KAFKA_GROUP_ID,
        'auto.offset.reset': 'earliest'
    }
    consumer = Consumer(kafka_conf)
    consumer.subscribe(KAFKA_TOPICS)
    logger.info(f"Подписались на топики: {KAFKA_TOPICS}")

    dwh_conn = None
    while dwh_conn is None:
        try:
            dwh_conn = get_dwh_connection()
            logger.info("Соединение с DWH установлено")
        except Exception as e:
            logger.error(f"Ошибка подключения к DWH: {e}. Повтор через 10 секунд")
            time.sleep(10)

    try:
        while True:
            msg = consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                if msg.error().code() == msg.error().UNKNOWN_TOPIC_OR_PART:
                    logger.warning(f"Топик не существует (ожидайте создания): {msg.error()}")
                    continue
                else:
                    logger.error(f"Ошибка сообщения: {msg.error()}")
                    continue
            try:
                message_value = json.loads(msg.value().decode('utf-8'))
            except Exception as e:
                logger.exception(f"Ошибка декодирования сообщения: {e}")
                continue

            process_event(message_value, dwh_conn)

    except KeyboardInterrupt:
        logger.info("Завершение работы по запросу пользователя")
    except KafkaException as e:
        logger.exception(f"KafkaException: {e}")
    finally:
        consumer.close()
        if dwh_conn:
            dwh_conn.close()

if __name__ == '__main__':
    main()