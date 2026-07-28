CREATE DATABASE smart_clinic_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE smart_clinic_db;


-- =========================================================
-- 1. PATIENTS TABLE
-- =========================================================

CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender ENUM('Male', 'Female') NOT NULL,
    date_of_birth DATE NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    address VARCHAR(200),
    blood_type ENUM(
        'A+', 'A-', 'B+', 'B-',
        'AB+', 'AB-', 'O+', 'O-'
    ),

    CONSTRAINT pk_patients
        PRIMARY KEY (patient_id),

    CONSTRAINT uq_patients_phone
        UNIQUE (phone),

    CONSTRAINT uq_patients_email
        UNIQUE (email)
);


-- =========================================================
-- 2. DOCTORS TABLE
-- =========================================================

CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,

    CONSTRAINT pk_doctors
        PRIMARY KEY (doctor_id),

    CONSTRAINT uq_doctors_phone
        UNIQUE (phone),

    CONSTRAINT uq_doctors_email
        UNIQUE (email)
);


-- =========================================================
-- 3. APPOINTMENTS TABLE
-- =========================================================

CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason VARCHAR(255),
    status ENUM(
        'Scheduled',
        'Completed',
        'Cancelled',
        'No Show'
    ) NOT NULL DEFAULT 'Scheduled',
    notes TEXT,

    CONSTRAINT pk_appointments
        PRIMARY KEY (appointment_id),

    CONSTRAINT fk_appointments_patient
        FOREIGN KEY (patient_id)
        REFERENCES Patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_appointments_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_doctor_appointment_time
        UNIQUE (
            doctor_id,
            appointment_date,
            appointment_time
        )
);


-- =========================================================
-- 4. MEDICINES TABLE
-- =========================================================

CREATE TABLE Medicines (
    medicine_id INT AUTO_INCREMENT,
    medicine_name VARCHAR(100) NOT NULL,
    medicine_type VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    expiry_date DATE NOT NULL,

    CONSTRAINT pk_medicines
        PRIMARY KEY (medicine_id),

    CONSTRAINT uq_medicines_name
        UNIQUE (medicine_name),

    CONSTRAINT chk_medicines_unit_price_nonnegative
        CHECK (unit_price >= 0),

    CONSTRAINT chk_medicines_stock_nonnegative
        CHECK (stock_quantity >= 0)
);

-- =========================================================
-- 5. TREATMENTS TABLE
-- =========================================================

CREATE TABLE Treatments (
    treatment_id INT AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    medicine_id INT NULL,
    diagnosis VARCHAR(255) NOT NULL,
    procedure_name VARCHAR(150),
    dosage VARCHAR(100),
    treatment_date DATE NOT NULL,
    treatment_cost DECIMAL(10,2) NOT NULL DEFAULT 0,

    CONSTRAINT pk_treatments
        PRIMARY KEY (treatment_id),

    CONSTRAINT fk_treatments_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES Appointments(appointment_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_treatments_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES Medicines(medicine_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT chk_treatments_cost_nonnegative
        CHECK (treatment_cost >= 0)
);


-- =========================================================
-- 6. PAYMENTS SUPERCLASS TABLE
-- =========================================================

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM(
        'Pending',
        'Paid',
        'Partially Paid',
        'Refunded'
    ) NOT NULL DEFAULT 'Pending',
    payment_method ENUM(
        'Cash',
        'Card',
        'Insurance'
    ) NOT NULL,

    CONSTRAINT pk_payments
        PRIMARY KEY (payment_id),

    CONSTRAINT fk_payments_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES Appointments(appointment_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_payments_amount_positive
        CHECK (amount > 0)
);


-- =========================================================
-- PAYMENT SPECIALIZATION TABLES
-- Total and disjoint specialization
-- =========================================================

CREATE TABLE Cash_Payments (
    payment_id INT,
    receipt_number VARCHAR(50) NOT NULL,

    CONSTRAINT pk_cash_payments
        PRIMARY KEY (payment_id),

    CONSTRAINT uq_cash_receipt
        UNIQUE (receipt_number),

    CONSTRAINT fk_cash_payment
        FOREIGN KEY (payment_id)
        REFERENCES Payments(payment_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


CREATE TABLE Card_Payments (
    payment_id INT,
    card_last_four CHAR(4) NOT NULL,
    authorization_code VARCHAR(50) NOT NULL,

    CONSTRAINT pk_card_payments
        PRIMARY KEY (payment_id),

    CONSTRAINT uq_card_authorization
        UNIQUE (authorization_code),

    CONSTRAINT fk_card_payment
        FOREIGN KEY (payment_id)
        REFERENCES Payments(payment_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_card_last_four
        CHECK (card_last_four REGEXP '^[0-9]{4}$')
);


CREATE TABLE Insurance_Payments (
    payment_id INT,
    insurance_provider VARCHAR(100) NOT NULL,
    claim_number VARCHAR(50) NOT NULL,

    CONSTRAINT pk_insurance_payments
        PRIMARY KEY (payment_id),

    CONSTRAINT uq_insurance_claim
        UNIQUE (claim_number),

    CONSTRAINT fk_insurance_payment
        FOREIGN KEY (payment_id)
        REFERENCES Payments(payment_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- =========================================================
-- INSERT RECORDS INTO PATIENTS
-- =========================================================

INSERT INTO Patients (
    first_name,
    last_name,
    gender,
    date_of_birth,
    phone,
    email,
    address,
    blood_type
)
VALUES
(
    'Ahmed',
    'Alqahtani',
    'Male',
    '1990-03-15',
    '0501234501',
    'ahmed.alqahtani@example.com',
    'Al Olaya District, Riyadh',
    'O+'
),
(
    'Noura',
    'Alharbi',
    'Female',
    '1987-08-22',
    '0532345602',
    'noura.alharbi@example.com',
    'Al Rawdah District, Jeddah',
    'A+'
),
(
    'Khalid',
    'Alotaibi',
    'Male',
    '2001-01-10',
    '0553456703',
    'khalid.alotaibi@example.com',
    'Al Faisaliyah District, Dammam',
    'B+'
),
(
    'Reem',
    'Alshammari',
    'Female',
    '1995-11-05',
    '0564567804',
    'reem.alshammari@example.com',
    'Al Malqa District, Riyadh',
    'AB+'
),
(
    'Fahad',
    'Aldossari',
    'Male',
    '1978-06-28',
    '0585678905',
    'fahad.aldossari@example.com',
    'Al Aziziyah District, Al Khobar',
    'O-'
);


-- =========================================================
-- INSERT RECORDS INTO DOCTORS
-- =========================================================

INSERT INTO Doctors (
    first_name,
    last_name,
    specialization,
    phone,
    email,
    hire_date
)
VALUES
(
    'Saad',
    'Alzahrani',
    'General Medicine',
    '0507001001',
    'saad.alzahrani@smartclinic.example',
    '2021-02-01'
),
(
    'Maha',
    'Almutairi',
    'Dermatology',
    '0537001002',
    'maha.almutairi@smartclinic.example',
    '2020-09-15'
),
(
    'Yousef',
    'Alghamdi',
    'Internal Medicine',
    '0557001003',
    'yousef.alghamdi@smartclinic.example',
    '2019-05-20'
),
(
    'Lama',
    'Alenezi',
    'Pediatrics',
    '0567001004',
    'lama.alenezi@smartclinic.example',
    '2022-01-10'
),
(
    'Omar',
    'Alshehri',
    'Orthopedics',
    '0587001005',
    'omar.alshehri@smartclinic.example',
    '2018-11-25'
);


-- =========================================================
-- INSERT RECORDS INTO APPOINTMENTS
-- =========================================================

INSERT INTO Appointments (
    patient_id,
    doctor_id,
    appointment_date,
    appointment_time,
    reason,
    status,
    notes
)
VALUES
(
    1,
    1,
    '2026-07-20',
    '09:00:00',
    'Fever and sore throat',
    'Completed',
    'Patient reported symptoms for three days.'
),
(
    2,
    2,
    '2026-07-20',
    '10:30:00',
    'Skin irritation',
    'Completed',
    'Mild allergic skin reaction was observed.'
),
(
    3,
    3,
    '2026-07-21',
    '11:00:00',
    'Stomach discomfort',
    'Completed',
    'Diet and medication history were reviewed.'
),
(
    4,
    4,
    '2026-07-22',
    '13:00:00',
    'Routine child health consultation',
    'Completed',
    'General condition was stable.'
),
(
    5,
    5,
    '2026-07-23',
    '15:30:00',
    'Knee pain',
    'Completed',
    'Pain increased during physical activity.'
);


-- =========================================================
-- INSERT RECORDS INTO MEDICINES
-- Prices are recorded in Saudi riyals
-- =========================================================

INSERT INTO Medicines (
    medicine_name,
    medicine_type,
    unit_price,
    stock_quantity,
    expiry_date
)
VALUES
(
    'Paracetamol 500 mg',
    'Tablet',
    12.50,
    150,
    '2028-01-31'
),
(
    'Cetirizine 10 mg',
    'Tablet',
    18.00,
    90,
    '2027-10-31'
),
(
    'Omeprazole 20 mg',
    'Capsule',
    25.75,
    110,
    '2028-03-31'
),
(
    'Amoxicillin Suspension',
    'Suspension',
    32.00,
    65,
    '2027-08-31'
),
(
    'Diclofenac Gel',
    'Topical Gel',
    21.50,
    80,
    '2028-05-31'
);


-- =========================================================
-- INSERT RECORDS INTO TREATMENTS
-- Costs are recorded in Saudi riyals
-- =========================================================

INSERT INTO Treatments (
    appointment_id,
    medicine_id,
    diagnosis,
    procedure_name,
    dosage,
    treatment_date,
    treatment_cost
)
VALUES
(
    1,
    1,
    'Viral upper respiratory infection',
    'General examination',
    'One tablet every eight hours when required',
    '2026-07-20',
    150.00
),
(
    2,
    2,
    'Mild allergic dermatitis',
    'Skin examination',
    'One tablet once daily for five days',
    '2026-07-20',
    220.00
),
(
    3,
    3,
    'Gastritis',
    'Abdominal examination',
    'One capsule before breakfast for fourteen days',
    '2026-07-21',
    180.00
),
(
    4,
    4,
    'Bacterial throat infection',
    'Pediatric examination',
    'Five millilitres every eight hours for seven days',
    '2026-07-22',
    200.00
),
(
    5,
    5,
    'Knee muscle strain',
    'Orthopedic examination',
    'Apply to the affected area twice daily',
    '2026-07-23',
    300.00
);


-- =========================================================
-- INSERT RECORDS INTO PAYMENTS
-- Amounts are recorded in Saudi riyals
-- =========================================================

INSERT INTO Payments (
    appointment_id,
    payment_date,
    amount,
    payment_status,
    payment_method
)
VALUES
(
    1,
    '2026-07-20',
    150.00,
    'Paid',
    'Cash'
),
(
    2,
    '2026-07-20',
    220.00,
    'Paid',
    'Card'
),
(
    3,
    '2026-07-21',
    180.00,
    'Paid',
    'Insurance'
),
(
    4,
    '2026-07-22',
    200.00,
    'Paid',
    'Card'
),
(
    5,
    '2026-07-23',
    300.00,
    'Paid',
    'Cash'
);


-- =========================================================
-- INSERT RECORDS INTO PAYMENT SUBCLASSES
-- Each payment is assigned to exactly one subtype
-- =========================================================

INSERT INTO Cash_Payments (
    payment_id,
    receipt_number
)
VALUES
(1, 'CASH-RYD-2026-001'),
(5, 'CASH-KHB-2026-002');


INSERT INTO Card_Payments (
    payment_id,
    card_last_four,
    authorization_code
)
VALUES
(2, '4821', 'AUTH-JED-200721'),
(4, '7316', 'AUTH-RYD-220724');


INSERT INTO Insurance_Payments (
    payment_id,
    insurance_provider,
    claim_number
)
VALUES
(
    3,
    'Bupa Arabia',
    'CLM-DMM-2026-003'
);



SELECT
    appointment_id,
    patient_id,
    doctor_id,
    appointment_date,
    appointment_time,
    reason,
    status
FROM Appointments
WHERE status = 'Scheduled'
ORDER BY appointment_date, appointment_time;

SELECT
    a.appointment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    a.appointment_date,
    a.appointment_time,
    a.status
FROM Appointments AS a
INNER JOIN Patients AS p
    ON a.patient_id = p.patient_id
INNER JOIN Doctors AS d
    ON a.doctor_id = d.doctor_id
ORDER BY a.appointment_date, a.appointment_time;


SELECT
    d.doctor_id,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization
FROM Doctors AS d
WHERE d.doctor_id IN (
    SELECT a.doctor_id
    FROM Appointments AS a
    GROUP BY a.doctor_id
    HAVING COUNT(*) > (
        SELECT AVG(appointment_count)
        FROM (
            SELECT COUNT(*) AS appointment_count
            FROM Appointments
            GROUP BY doctor_id
        ) AS doctor_totals
    )
);

SELECT
    d.doctor_id,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    COUNT(a.appointment_id) AS total_appointments
FROM Doctors AS d
LEFT JOIN Appointments AS a
    ON d.doctor_id = a.doctor_id
GROUP BY
    d.doctor_id,
    d.first_name,
    d.last_name,
    d.specialization
ORDER BY total_appointments DESC;

UPDATE Appointments
SET
    status = 'Completed',
    notes = 'The consultation and examination were completed.'
WHERE appointment_id = 5;

DELETE FROM Appointments
WHERE status = 'Cancelled'
  AND appointment_id NOT IN (
      SELECT appointment_id
      FROM Treatments
  )
  AND appointment_id NOT IN (
      SELECT appointment_id
      FROM Payments
  );

CREATE OR REPLACE VIEW Appointment_Details_View AS
SELECT
    a.appointment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    p.phone AS patient_phone,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    d.specialization,
    a.appointment_date,
    a.appointment_time,
    a.reason,
    a.status
FROM Appointments AS a
INNER JOIN Patients AS p
    ON a.patient_id = p.patient_id
INNER JOIN Doctors AS d
    ON a.doctor_id = d.doctor_id;

SELECT *
FROM Appointment_Details_View
ORDER BY appointment_date, appointment_time;


DELIMITER //

CREATE TRIGGER trg_validate_appointment_datetime
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    IF TIMESTAMP(
        NEW.appointment_date,
        NEW.appointment_time
    ) < CURRENT_TIMESTAMP THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'The appointment date and time cannot be in the past.';
    END IF;
END//

DELIMITER ;










