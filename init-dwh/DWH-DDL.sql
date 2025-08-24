CREATE SCHEMA IF NOT EXISTS dwh_detailed;

CREATE TABLE dwh_detailed.hub_airports (
    hub_airport_id SERIAL PRIMARY KEY,
    airport_code CHAR(3) NOT NULL, 
    record_source TEXT NOT NULL,
    load_date TIMESTAMPTZ NOT NULL,
    CONSTRAINT uk_hub_airports_airport_code UNIQUE (airport_code)
);

CREATE TABLE dwh_detailed.hub_aircrafts (
    hub_aircraft_id SERIAL PRIMARY KEY,
    aircraft_code CHAR(3) NOT NULL, 
    record_source TEXT NOT NULL,
    load_date TIMESTAMPTZ NOT NULL,
    CONSTRAINT uk_hub_aircrafts_aircraft_code UNIQUE (aircraft_code)
);

CREATE TABLE dwh_detailed.hub_flights (
    hub_flight_id SERIAL PRIMARY KEY,
    flight_no CHAR(6) NOT NULL,
    scheduled_departure TIMESTAMPTZ NOT NULL,
    record_source TEXT NOT NULL,
    load_date TIMESTAMPTZ NOT NULL,
    CONSTRAINT uk_hub_flights UNIQUE (flight_no, scheduled_departure)
);

CREATE TABLE dwh_detailed.hub_bookings (
    hub_booking_id SERIAL PRIMARY KEY,
    book_ref CHAR(6) NOT NULL,
    record_source TEXT NOT NULL,
    load_date TIMESTAMPTZ NOT NULL,
    CONSTRAINT uk_hub_bookings UNIQUE (book_ref)
);


CREATE TABLE dwh_detailed.hub_tickets (
    hub_ticket_id SERIAL PRIMARY KEY,
    ticket_no CHAR(13) NOT NULL,  
    record_source TEXT NOT NULL,
    load_date TIMESTAMPTZ NOT NULL,
    CONSTRAINT uk_hub_tickets UNIQUE (ticket_no)
);

CREATE TABLE dwh_detailed.link_ticket_flights (
    link_id SERIAL PRIMARY KEY,
    hub_ticket_id INTEGER NOT NULL,
    hub_flight_id INTEGER NOT NULL,
    record_source TEXT NOT NULL,
    load_date TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_link_ticket_flights_ticket FOREIGN KEY (hub_ticket_id)
        REFERENCES dwh_detailed.hub_tickets(hub_ticket_id),
    CONSTRAINT fk_link_ticket_flights_flight FOREIGN KEY (hub_flight_id)
        REFERENCES dwh_detailed.hub_flights(hub_flight_id),
    CONSTRAINT uk_link_ticket_flights UNIQUE (hub_ticket_id, hub_flight_id)
);

CREATE TABLE dwh_detailed.sat_airports (
    hub_airport_id INTEGER NOT NULL,
    airport_name TEXT,
    city TEXT,
    coordinates_lon DOUBLE PRECISION,
    coordinates_lat DOUBLE PRECISION,
    timezone TEXT,
    effective_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    effective_to TIMESTAMPTZ,
    record_source TEXT NOT NULL,
    load_date TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_sat_airports FOREIGN KEY (hub_airport_id)
        REFERENCES dwh_detailed.hub_airports(hub_airport_id)
);

CREATE TABLE dwh_detailed.sat_aircrafts (
    hub_aircraft_id INTEGER NOT NULL,
    model JSONB,
    range INTEGER,
    effective_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    effective_to TIMESTAMPTZ,
    record_source TEXT NOT NULL,
    load_date TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_sat_aircrafts FOREIGN KEY (hub_aircraft_id)
        REFERENCES dwh_detailed.hub_aircrafts(hub_aircraft_id)
);

CREATE TABLE dwh_detailed.sat_flights (
    hub_flight_id INTEGER NOT NULL,
    scheduled_arrival TIMESTAMPTZ,
    departure_airport CHAR(3),
    arrival_airport CHAR(3),
    status VARCHAR(20),
    aircraft_code CHAR(3),
    actual_departure TIMESTAMPTZ,
    actual_arrival TIMESTAMPTZ,
    effective_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    effective_to TIMESTAMPTZ,
    record_source TEXT NOT NULL,
    load_date TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_sat_flights FOREIGN KEY (hub_flight_id)
        REFERENCES dwh_detailed.hub_flights(hub_flight_id)
);

CREATE TABLE dwh_detailed.sat_bookings (
    hub_booking_id INTEGER NOT NULL,
    book_date TIMESTAMPTZ,
    total_amount NUMERIC(10,2),
    effective_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    effective_to TIMESTAMPTZ,
    record_source TEXT NOT NULL,
    load_date TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_sat_bookings FOREIGN KEY (hub_booking_id)
        REFERENCES dwh_detailed.hub_bookings(hub_booking_id)
);

CREATE TABLE dwh_detailed.sat_tickets (
    hub_ticket_id INTEGER NOT NULL,
    book_ref CHAR(6), 
    passenger_id VARCHAR(20),
    passenger_name TEXT,
    contact_data JSONB,
    effective_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    effective_to TIMESTAMPTZ,
    record_source TEXT NOT NULL,
    load_date TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_sat_tickets FOREIGN KEY (hub_ticket_id)
        REFERENCES dwh_detailed.hub_tickets(hub_ticket_id)
);