INSERT INTO dwh_detailed.hub_flights (flight_no, scheduled_departure, record_source, load_date)
VALUES
  ('XYZ001', '2025-03-24 08:00:00', 'test', NOW()),
  ('DDD001', '2025-03-24 09:00:00', 'test', NOW()),
  ('FFF001', '2025-03-24 10:00:00', 'test', NOW()),
  ('AAA013', '2025-03-24 07:00:00', 'test', NOW()),
  ('BBB013', '2025-03-13 08:30:00', 'test', NOW()),
  ('CCC016', '2025-03-25 11:00:00', 'test', NOW()),
  ('DDD016', '2025-03-25 12:00:00', 'test', NOW());

INSERT INTO dwh_detailed.sat_flights
  (hub_flight_id, scheduled_arrival, departure_airport, arrival_airport, status, aircraft_code, actual_departure, actual_arrival, record_source, load_date)
VALUES
  (
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'XYZ001'),
    '2025-03-24 09:00:00', 'XYZ', 'XYZ', 'OnTime', 'A01',
    '2025-03-24 08:05:00', '2025-03-24 09:05:00', 'test', NOW()
  ),
  (
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'DDD001'),
    '2025-03-24 10:00:00', 'DDD', 'EEE', 'OnTime', 'A02',
    NULL, '2025-03-24 10:05:00', 'test', NOW()
  ),
  (
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'FFF001'),
    '2025-03-24 11:00:00', 'FFF', 'GGG', 'OnTime', 'A03',
    '2025-03-24 10:05:00', NULL, 'test', NOW()
  );

INSERT INTO dwh_detailed.sat_flights
  (hub_flight_id, scheduled_arrival, departure_airport, arrival_airport, status, aircraft_code, actual_departure, actual_arrival, record_source, load_date)
VALUES
  (
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'AAA013'),
    '2025-03-13 08:00:00', 'AAA', 'AAA', 'OnTime', 'A10',
    '2025-03-13 07:05:00', '2025-03-13 08:05:00', 'test', NOW()
  ),
  (
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'BBB013'),
    '2025-03-13 09:00:00', 'BBB', 'CCC', 'OnTime', 'A11',
    '2025-03-13 08:00:00', NULL, 'test', NOW()
  );

INSERT INTO dwh_detailed.sat_flights
  (hub_flight_id, scheduled_arrival, departure_airport, arrival_airport, status, aircraft_code, actual_departure, actual_arrival, record_source, load_date)
VALUES
  (
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'CCC016'),
    '2025-03-25 12:30:00', 'CCC', 'ZZZ', 'OnTime', 'A20',
    NULL, '2025-03-25 12:35:00', 'test', NOW()
  ),
  (
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'DDD016'),
    '2025-03-25 13:30:00', 'DDD', 'MMM', 'OnTime', 'A21',
    '2025-03-25 12:55:00', '2025-03-25 13:35:00', 'test', NOW()
  );

INSERT INTO dwh_detailed.hub_bookings (book_ref, record_source, load_date)
VALUES 
  ('BKG001', 'test', NOW()),
  ('BKG002', 'test', NOW()),
  ('BKG003', 'test', NOW()),
  ('BKG004', 'test', NOW()),
  ('BKG005', 'test', NOW()),
  ('BKG006', 'test', NOW());

INSERT INTO dwh_detailed.sat_bookings (hub_booking_id, book_date, total_amount, record_source, load_date)
VALUES
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG001'), '2025-03-24 07:50:00', 100.00, 'test', NOW()),
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG002'), '2025-03-24 08:50:00', 150.00, 'test', NOW()),
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG003'), '2025-03-24 08:55:00', 150.00, 'test', NOW()),
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG004'), '2025-03-24 09:50:00', 200.00, 'test', NOW()),
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG005'), '2025-03-24 09:55:00', 200.00, 'test', NOW()),
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG006'), '2025-03-24 10:00:00', 200.00, 'test', NOW());

INSERT INTO dwh_detailed.hub_bookings (book_ref, record_source, load_date)
VALUES 
  ('BKG007', 'test', NOW()),
  ('BKG008', 'test', NOW()),
  ('BKG009', 'test', NOW());

INSERT INTO dwh_detailed.sat_bookings (hub_booking_id, book_date, total_amount, record_source, load_date)
VALUES
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG007'), '2025-03-13 06:50:00', 80.00, 'test', NOW()),
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG008'), '2025-03-13 07:50:00', 90.00, 'test', NOW()),
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG009'), '2025-03-13 07:55:00', 90.00, 'test', NOW());

INSERT INTO dwh_detailed.hub_bookings (book_ref, record_source, load_date)
VALUES 
  ('BKG010', 'test', NOW()),
  ('BKG011', 'test', NOW()),
  ('BKG012', 'test', NOW()),
  ('BKG013', 'test', NOW()),
  ('BKG014', 'test', NOW());

INSERT INTO dwh_detailed.sat_bookings (hub_booking_id, book_date, total_amount, record_source, load_date)
VALUES
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG010'), '2025-03-25 10:50:00', 120.00, 'test', NOW()),
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG011'), '2025-03-25 10:55:00', 120.00, 'test', NOW()),
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG012'), '2025-03-25 11:50:00', 250.00, 'test', NOW()),
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG013'), '2025-03-25 11:55:00', 250.00, 'test', NOW()),
  ((SELECT hub_booking_id FROM dwh_detailed.hub_bookings WHERE book_ref = 'BKG014'), '2025-03-25 12:00:00', 250.00, 'test', NOW());

INSERT INTO dwh_detailed.hub_tickets (ticket_no, record_source, load_date)
VALUES
  ('TICKET000001', 'test', NOW()),
  ('TICKET000002', 'test', NOW()),
  ('TICKET000003', 'test', NOW()),
  ('TICKET000004', 'test', NOW()),
  ('TICKET000005', 'test', NOW()),
  ('TICKET000006', 'test', NOW());

INSERT INTO dwh_detailed.sat_tickets (hub_ticket_id, book_ref, passenger_id, passenger_name, contact_data, record_source, load_date)
VALUES
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000001'),
    'BKG001', 'P001', 'Alice', '{}'::jsonb, 'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000002'),
    'BKG002', 'P002', 'Bob', '{}'::jsonb, 'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000003'),
    'BKG003', 'P003', 'Charlie', '{}'::jsonb, 'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000004'),
    'BKG004', 'P004', 'David', '{}'::jsonb, 'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000005'),
    'BKG005', 'P005', 'Eva', '{}'::jsonb, 'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000006'),
    'BKG006', 'P006', 'Frank', '{}'::jsonb, 'test', NOW()
  );

INSERT INTO dwh_detailed.hub_tickets (ticket_no, record_source, load_date)
VALUES
  ('TICKET000007', 'test', NOW()),
  ('TICKET000008', 'test', NOW()),
  ('TICKET000009', 'test', NOW());

INSERT INTO dwh_detailed.sat_tickets (hub_ticket_id, book_ref, passenger_id, passenger_name, contact_data, record_source, load_date)
VALUES
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000007'),
    'BKG007', 'P007', 'George', '{}'::jsonb, 'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000008'),
    'BKG008', 'P008', 'Hannah', '{}'::jsonb, 'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000009'),
    'BKG009', 'P009', 'Ivan', '{}'::jsonb, 'test', NOW()
  );

INSERT INTO dwh_detailed.hub_tickets (ticket_no, record_source, load_date)
VALUES
  ('TICKET000010', 'test', NOW()),
  ('TICKET000011', 'test', NOW()),
  ('TICKET000012', 'test', NOW()),
  ('TICKET000013', 'test', NOW()),
  ('TICKET000014', 'test', NOW());

INSERT INTO dwh_detailed.sat_tickets (hub_ticket_id, book_ref, passenger_id, passenger_name, contact_data, record_source, load_date)
VALUES
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000010'),
    'BKG010', 'P010', 'Julia', '{}'::jsonb, 'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000011'),
    'BKG011', 'P011', 'Kevin', '{}'::jsonb, 'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000012'),
    'BKG012', 'P012', 'Laura', '{}'::jsonb, 'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000013'),
    'BKG013', 'P013', 'Mike', '{}'::jsonb, 'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000014'),
    'BKG014', 'P014', 'Nina', '{}'::jsonb, 'test', NOW()
  );


INSERT INTO dwh_detailed.link_ticket_flights (hub_ticket_id, hub_flight_id, record_source, load_date)
VALUES
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000001'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'XYZ001'),
    'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000002'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'DDD001'),
    'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000003'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'DDD001'),
    'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000004'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'FFF001'),
    'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000005'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'FFF001'),
    'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000006'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'FFF001'),
    'test', NOW()
  );

INSERT INTO dwh_detailed.link_ticket_flights (hub_ticket_id, hub_flight_id, record_source, load_date)
VALUES
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000007'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'AAA013'),
    'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000008'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'BBB013'),
    'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000009'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'BBB013'),
    'test', NOW()
  );

INSERT INTO dwh_detailed.link_ticket_flights (hub_ticket_id, hub_flight_id, record_source, load_date)
VALUES
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000010'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'CCC016'),
    'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000011'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'CCC016'),
    'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000012'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'DDD016'),
    'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000013'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'DDD016'),
    'test', NOW()
  ),
  (
    (SELECT hub_ticket_id FROM dwh_detailed.hub_tickets WHERE ticket_no = 'TICKET000014'),
    (SELECT hub_flight_id FROM dwh_detailed.hub_flights WHERE flight_no = 'DDD016'),
    'test', NOW()
  );