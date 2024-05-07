## ADT Final Project Part 2 - SQL Code
## Team 11: Ameya Parab & Trishna Patil

##STEP 1: CREATION OF DATABASE
CREATE DATABASE doctors_appointment_db;
USE doctors_appointment_db;

##STEP 2:  CREATION OF TABLES
# Author: Trishna Patil
CREATE TABLE Doctors (
    DoctorID int,
    FirstName varchar(50),
    MiddleName varchar(50),
    LastName varchar(50),
    Gender varchar(10),
    CONSTRAINT PK_Doctors PRIMARY KEY (DoctorID)
);

# Author: Trishna Patil
CREATE TABLE Contacts (
    DoctorID int NOT NULL,
    PhoneNumber varchar(25) NOT NULL,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    CONSTRAINT chk_phonenumber_format CHECK (PhoneNumber REGEXP '^[(][0-9]{3}[)][-][0-9]{3}[-][0-9]{4}$')
);

# Author: Trishna Patil
CREATE TABLE Services (
    DoctorID int NOT NULL,
    Teleconsultation varchar(1) NOT NULL DEFAULT "N",
    IndividualMedicare varchar(1) NOT NULL,
    GroupMedicare varchar(1) NOT NULL,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

# Author: Trishna Patil
CREATE TABLE Schools (
    SchoolID int AUTO_INCREMENT,
    SchoolName varchar(255),
    CONSTRAINT PK_Schools PRIMARY KEY (SchoolID)
);

# Author: Trishna Patil
CREATE TABLE Education (
    DoctorID int NOT NULL,
    SchoolID int NOT NULL,
    Credential varchar(5),
    GraduationYear YEAR NOT NULL,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (SchoolID) REFERENCES Schools(SchoolID)
);

# Author: Trishna Patil
CREATE TABLE Specialties (
    SpecialtyID int NOT NULL AUTO_INCREMENT,
    SpecialtyName varchar(255) NOT NULL,
    CONSTRAINT PK_Specialties PRIMARY KEY (SpecialtyID)
) AUTO_INCREMENT = 100;

# Author: Trishna Patil
CREATE TABLE DoctorSpecialties (
    DoctorID int NOT NULL,
    SpecialtyID int,
    IsPrimary boolean,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (SpecialtyID) REFERENCES Specialties(SpecialtyID)
);

# Author: Ameya Parab
CREATE TABLE Addresses (
    AddressID varchar(50),
    AddressLine1 varchar(255) NOT NULL,
    AddressLine2 varchar(255),
    City varchar(255) NOT NULL,
    State varchar(255) NOT NULL,
    Zip varchar(15) NOT NULL,
    CONSTRAINT PK_Adresses PRIMARY KEY (AddressID),
    CONSTRAINT chk_zip_format CHECK (zip_code REGEXP '^[0-9]{5}[-][0-9]{4}$')
);

# Author: Ameya Parab
CREATE TABLE DoctorClinics (
    DoctorID int NOT NULL,
    AddressID varchar(50) NOT NULL,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (AddressID) REFERENCES Addresses(AddressID)
);

# Author: Ameya Parab
CREATE TABLE Organizations (
    OrganizationID varchar(50),
    OrganizationName varchar(255) NOT NULL,
    AddressID varchar(50) NOT NULL,
    Members int,
    CONSTRAINT PK_Organizations PRIMARY KEY (OrganizationID),
    FOREIGN KEY (AddressID) REFERENCES Addresses(AddressID)
);

# Author: Ameya Parab
CREATE TABLE DoctorOrganizations (
    DoctorID int,
    OrganizationID varchar(50) NOT NULL,
    isHospital boolean DEFAULT FALSE,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (OrganizationID) REFERENCES Organizations(OrganizationID)
);

# Author: Ameya Parab
CREATE TABLE Patients (
    PatientID int NOT NULL AUTO_INCREMENT,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
    Gender varchar(10) NOT NULL,
    Email varchar(50) NOT NULL,
    CONSTRAINT PK_Patients PRIMARY KEY (PatientID),
    CONSTRAINT chk_email_format CHECK(Email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
) AUTO_INCREMENT = 100;

# Author: Ameya Parab
CREATE TABLE Appointments (
    AppointmentID int NOT NULL AUTO_INCREMENT,
	PatientID int NOT NULL,
	DoctorID int NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Teleconsultation VARCHAR(1),
    CONSTRAINT PK_Appointments PRIMARY KEY (AppointmentID),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
) AUTO_INCREMENT = 1000;


## INSERTION OF DATA
#STEP 3: Refer RMD file
#Insertion of Data from temporary tables to the original table as it can't be directly inserted because of normalization
#STEP 4: Doctors_temp table
# Author: Trishna Patil
INSERT INTO Doctors
SELECT NPI, frst_nm, mid_nm, lst_nm, gndr
FROM Doctors_temp;

# Author: Ameya Parab
#STEP 11: Organizations_temp table
INSERT INTO Organizations
SELECT DISTINCT org_pac_id, org_nm, adrs_id, num_org_mem
FROM Organizations_temp;

#STEP 15: Insert in tables normalized data
# Author: Trishna Patil
ALTER TABLE Education MODIFY COLUMN GraduationYear INT;
INSERT INTO Education
SELECT e.NPI, s.SchoolID, e.Cred, e.Grd_yr
FROM Education_temp e
JOIN Schools s ON e.Med_sch = s.SchoolName;

# Author: Trishna Patil
INSERT INTO DoctorSpecialties
SELECT d.NPI, s.SpecialtyID, d.IsPrimary
FROM DoctorSpecialties_temp d
JOIN Specialties s ON d.specialty = s.SpecialtyName;

# Author: Ameya Parab
# Inserting data into new tables
INSERT INTO Patients (FirstName, LastName, Gender, Email) VALUES ("Ameya", "Parab", "M", "ameyaparab@dummyemail.com");
INSERT INTO Patients (FirstName, LastName, Gender, Email) VALUES ("Trishna", "Patil", "F", "trishnapatil@dummyemail.com");
INSERT INTO Patients (FirstName, LastName, Gender, Email) VALUES ("Sumeet", "Suvarna", "M", "sumeetsuvarna@dummyemail.com");
INSERT INTO Patients (FirstName, LastName, Gender, Email) VALUES ("Anuja", "Merwade", "F", "anujamerwade@dummyemail.com");
INSERT INTO Patients (FirstName, LastName, Gender, Email) VALUES ("Shreyas", "Sawant", "M", "shreyassawant@dummyemail.com");

# Inserting into Appointments
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, AppointmentTime, Teleconsultation) VALUES ("100", "1396810032", "2023-04-23", "10:30", "N");
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, AppointmentTime, Teleconsultation) VALUES ("100", "1396701157", "2023-04-29", "14:00", "Y");

# BASIC QUERIES
# Getting statistics for Education Degree
# Author: Trishna Patil
SELECT Credential, COUNT(*) AS Num_Of_Doctors 
FROM Education
WHERE Credential != ""
GROUP BY Credential
ORDER BY Num_Of_Doctors;

# Getting statistics for Service
# Author: Ameya Parab
SELECT (SELECT COUNT(*) FROM Services WHERE Teleconsultation = "Y") AS Teleconsultation,
		(SELECT COUNT(*) FROM Services WHERE IndividualMedicare = "Y") AS IndividualMedicare,
        (SELECT COUNT(*) FROM Services WHERE GroupMedicare = "Y") AS GroupMedicare;


# VIEWS
# View for storing years of experience of Doctors and their specialties
# Author: Ameya Parab
CREATE VIEW doctors_experience AS 
SELECT e.DoctorID, s.SpecialtyID, (YEAR(NOW()) - e.GraduationYear) AS Experience
FROM Education e
INNER JOIN DoctorSpecialties dspl USING(DoctorID)
INNER JOIN Specialties s USING(SpecialtyID)
WHERE SpecialtyName != "";

# Using the doctors_experience View to get statistics of each specialty
# Author: Ameya Parab 
SELECT s.SpecialtyName, 
	COUNT(de.DoctorID) AS Num_of_Doctors, 
	CAST(AVG(de.Experience) AS UNSIGNED) AS Avg_Experience, 
    MIN(de.Experience) AS Min_Experience, 
    MAX(de.Experience) AS Max_Experience 
FROM doctors_experience de
JOIN Specialties s
USING (SpecialtyID)
GROUP BY SpecialtyName
ORDER BY Num_Of_Doctors DESC;

# View to return basic necessary details of doctor which will be displayed for booking an appointment
# Author: Trishna Patil
CREATE VIEW doctor_details AS
SELECT DISTINCT doc.DoctorID, doc.FirstName, doc.MiddleName, doc.LastName, spl.SpecialtyName, edu.Credential, edu.GraduationYear, ser.Teleconsultation, con.PhoneNumber
FROM Doctors doc
JOIN DoctorSpecialties docspl ON doc.DoctorID = docspl.DoctorID
JOIN Specialties spl ON spl.SpecialtyID = docspl.SpecialtyID
JOIN Education edu ON doc.DoctorID = edu.DoctorID
JOIN Services ser ON doc.DoctorID = ser.DoctorID
JOIN Contacts con ON doc.DoctorID = con.DoctorID
WHERE docspl.IsPrimary = 1;

SELECT * FROM doctor_details WHERE DoctorID = 1316910771;

# View to display all the other specialties of a Doctor in a single string
# Author: Ameya Parab
CREATE VIEW secondary_specialties AS
SELECT docspl.DoctorID, GROUP_CONCAT(DISTINCT spl.SpecialtyName SEPARATOR ', ') AS SecondarySpecialties
FROM DoctorSpecialties docspl
JOIN Specialties spl USING (SpecialtyID)
WHERE docspl.IsPrimary = 0
GROUP BY DoctorID
HAVING SecondarySpecialties != "";

SELECT SecondarySpecialties FROM secondary_specialties WHERE DoctorID = 1063402972;


# COMPLEX QUERIES
# Query to print complete address for a particular Doctor (to be used to find latitude and longitude)
# Author: Ameya Parab
SELECT CONCAT(AddressLine1, ", ", City, ", ", State) AS Address
FROM Addresses 
WHERE AddressID = (SELECT 
					CASE 
						WHEN (SELECT COUNT(*) FROM DoctorClinics WHERE DoctorID = 1316910771) > 0 
                        THEN (SELECT DISTINCT AddressID
							FROM DoctorClinics
							WHERE DoctorID = 1316910771)
						ELSE (SELECT DISTINCT o.AddressID
							FROM DoctorOrganizations dorg
							JOIN Organizations o USING(OrganizationID)
							WHERE dorg.DoctorID = 1316910771)
					END AS AddressID)
                    
                    
CREATE VIEW doctor_details AS
SELECT DISTINCT doc.DoctorID, CONCAT(doc.FirstName, " ", doc.MiddleName, " ", doc.LastName) AS DoctorName, spl.SpecialtyName, edu.Credential, edu.GraduationYear, ser.Teleconsultation, con.PhoneNumber
FROM Doctors doc
JOIN DoctorSpecialties docspl ON doc.DoctorID = docspl.DoctorID
JOIN Specialties spl ON spl.SpecialtyID = docspl.SpecialtyID
JOIN Education edu ON doc.DoctorID = edu.DoctorID
JOIN Services ser ON doc.DoctorID = ser.DoctorID
JOIN Contacts con ON doc.DoctorID = con.DoctorID
WHERE docspl.IsPrimary = 1;

SELECT DISTINCT(DoctorID), DoctorName, SpecialtyName, Credential, GraduationYear, Teleconsultation FROM doctor_details;

CREATE VIEW appointment_details AS
SELECT DISTINCT a.AppointmentID, a.PatientID, CONCAT(doc.FirstName, " ", doc.MiddleName, " ", doc.LastName) AS DoctorName, a.Teleconsultation, a.AppointmentDate, a.AppointmentTime
FROM Appointments a
JOIN Doctors doc ON doc.DoctorID = a.DoctorID;
SELECT AppointmentID, DoctorName, Teleconsultation, AppointmentDate, AppointmentTime
FROM appointment_details
WHERE PatientID = '100';

SELECT COUNT(DISTINCT Credential) FROM doctors_appointment_db.education;
SELECT Credential, COUNT(*) AS Num_Of_Doctors 
FROM Education
WHERE Credential != ""
GROUP BY Credential
ORDER BY Num_Of_Doctors LIMIT 10;

SELECT CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName, CONCAT(a.AddressLine1, ', ', a.City, ', ', a.State) AS Address
FROM Addresses a
INNER JOIN DoctorClinics dc
ON a.AddressID = dc.AddressID
INNER JOIN Doctors d
ON dc.DoctorId = d.DoctorId