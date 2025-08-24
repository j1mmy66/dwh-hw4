CREATE TABLE airports (
    airport_code CHAR(3) PRIMARY KEY,
    airport_name TEXT,
    city TEXT,
    coordinates_lon DOUBLE PRECISION,
    coordinates_lat DOUBLE PRECISION,
    timezone TEXT
);

CREATE TABLE aircrafts (
    aircraft_code CHAR(3) PRIMARY KEY,
    model JSONB NOT NULL,
    range INTEGER
);

CREATE TABLE seats (
    aircraft_code CHAR(3) REFERENCES aircrafts(aircraft_code),
    seat_no VARCHAR(4),
    fare_conditions VARCHAR(10),
    PRIMARY KEY (aircraft_code, seat_no)
);


CREATE TABLE flights (
    flight_id SERIAL PRIMARY KEY,
    flight_no CHAR(6),
    scheduled_departure TIMESTAMPTZ NOT NULL,
    scheduled_arrival TIMESTAMPTZ NOT NULL,
    departure_airport CHAR(3) REFERENCES airports(airport_code),
    arrival_airport CHAR(3) REFERENCES airports(airport_code),
    status VARCHAR(20),
    aircraft_code CHAR(3) REFERENCES aircrafts(aircraft_code),
    actual_departure TIMESTAMPTZ,
    actual_arrival TIMESTAMPTZ
);

CREATE TABLE bookings (
    book_ref CHAR(6) PRIMARY KEY,
    book_date TIMESTAMPTZ NOT NULL,
    total_amount NUMERIC(10,2)
);

CREATE TABLE tickets (
    ticket_no CHAR(13) PRIMARY KEY,
    book_ref CHAR(6) REFERENCES bookings(book_ref),
    passenger_id VARCHAR(20),
    passenger_name TEXT,
    contact_data JSONB
);

CREATE TABLE ticket_flights (
    ticket_no CHAR(13) REFERENCES tickets(ticket_no),
    flight_id INTEGER REFERENCES flights(flight_id),
    fare_conditions NUMERIC(10,2),
    amount NUMERIC(10,2),
    PRIMARY KEY (flight_id, ticket_no)
);


CREATE TABLE boarding_passes (
    ticket_no CHAR(13),
    flight_id INTEGER,
    boarding_no INTEGER,
    seat_no VARCHAR(4),
    PRIMARY KEY (flight_id, ticket_no) 
);