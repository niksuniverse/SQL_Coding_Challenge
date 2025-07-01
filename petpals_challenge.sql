-- Create database only if it doesn't exist
CREATE DATABASE IF NOT EXISTS PetPals;
USE PetPals;

-- Pets Table
CREATE TABLE IF NOT EXISTS Pets (
    PetID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Age INT,
    Breed VARCHAR(100),
    Type VARCHAR(50),
    AvailableForAdoption BIT,
    ShelterID INT,
    OwnerID INT DEFAULT NULL
);

-- Shelters Table
CREATE TABLE IF NOT EXISTS Shelters (
    ShelterID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Location VARCHAR(255)
);

-- Donations Table
CREATE TABLE IF NOT EXISTS Donations (
    DonationID INT PRIMARY KEY AUTO_INCREMENT,
    DonorName VARCHAR(100),
    DonationType VARCHAR(50),
    DonationAmount DECIMAL(10,2),
    DonationItem VARCHAR(100),
    DonationDate DATETIME,
    ShelterID INT,
    FOREIGN KEY (ShelterID) REFERENCES Shelters(ShelterID)
);

-- AdoptionEvents Table
CREATE TABLE IF NOT EXISTS AdoptionEvents (
    EventID INT PRIMARY KEY AUTO_INCREMENT,
    EventName VARCHAR(100),
    EventDate DATETIME,
    Location VARCHAR(255)
);

-- Participants Table
CREATE TABLE IF NOT EXISTS Participants (
    ParticipantID INT PRIMARY KEY AUTO_INCREMENT,
    ParticipantName VARCHAR(100),
    ParticipantType VARCHAR(50),
    EventID INT,
    FOREIGN KEY (EventID) REFERENCES AdoptionEvents(EventID)
);

-- ================================
-- 🌐 Sample Data Inserts for PetPals
-- ================================

-- 1️ Shelters (5 Records)
INSERT INTO Shelters (Name, Location) VALUES
('Happy Tails Shelter', 'Chennai'),
('Paw Haven', 'Bangalore'),
('Animal Care Center', 'Hyderabad'),
('Furry Friends Rescue', 'Mumbai'),
('Safe Paws Shelter', 'Delhi');

-- 2️ Pets (10 Records)
INSERT INTO Pets (Name, Age, Breed, Type, AvailableForAdoption, ShelterID, OwnerID) VALUES
('Max', 3, 'Labrador', 'Dog', 1, 1, NULL),
('Milo', 2, 'Beagle', 'Dog', 1, 1, NULL),
('Bella', 6, 'Persian', 'Cat', 0, 2, 2),
('Lucy', 1, 'Bulldog', 'Dog', 1, 2, NULL),
('Simba', 5, 'Siamese', 'Cat', 0, 3, 3),
('Daisy', 4, 'Golden Retriever', 'Dog', 1, 3, NULL),
('Charlie', 7, 'German Shepherd', 'Dog', 0, 4, 4),
('Luna', 2, 'Ragdoll', 'Cat', 1, 4, NULL),
('Rocky', 3, 'Pomeranian', 'Dog', 1, 5, NULL),
('Oscar', 6, 'British Shorthair', 'Cat', 0, 5, 5);

-- 3️ Donations (8 Records)
INSERT INTO Donations (DonorName, DonationType, DonationAmount, DonationItem, DonationDate, ShelterID) VALUES
('John Doe', 'Cash', 5000.00, NULL, '2025-06-01 10:00:00', 1),
('Jane Smith', 'Item', NULL, 'Dog Food', '2025-06-02 11:00:00', 2),
('Ravi Kumar', 'Cash', 2000.00, NULL, '2025-06-03 14:00:00', 1),
('Anita Rao', 'Cash', 3500.00, NULL, '2025-06-05 15:00:00', 3),
('Priya Mehta', 'Item', NULL, 'Blankets', '2025-06-07 13:00:00', 4),
('Suresh Babu', 'Cash', 1000.00, NULL, '2025-06-09 09:30:00', 5),
('Amit Singh', 'Item', NULL, 'Toys', '2025-06-10 16:30:00', 1),
('Ritika Jain', 'Cash', 2500.00, NULL, '2025-06-12 12:45:00', 2);

-- 4️ Adoption Events (5 Records)
INSERT INTO AdoptionEvents (EventName, EventDate, Location) VALUES
('Adopt-A-Pet Day', '2025-06-15 10:00:00', 'Chennai'),
('Forever Home Fair', '2025-06-20 11:00:00', 'Bangalore'),
('Paw Meet & Greet', '2025-06-25 12:00:00', 'Hyderabad'),
('Furry Friends Fiesta', '2025-07-01 09:00:00', 'Delhi'),
('Home for Every Pet', '2025-07-05 15:00:00', 'Mumbai');

-- 5️ Participants (10 Records)
INSERT INTO Participants (ParticipantName, ParticipantType, EventID) VALUES
('Happy Tails Shelter', 'Shelter', 1),
('John Doe', 'Adopter', 1),
('Paw Haven', 'Shelter', 2),
('Jane Smith', 'Adopter', 2),
('Animal Care Center', 'Shelter', 3),
('Ravi Kumar', 'Adopter', 3),
('Furry Friends Rescue', 'Shelter', 4),
('Anita Rao', 'Adopter', 4),
('Safe Paws Shelter', 'Shelter', 5),
('Priya Mehta', 'Adopter', 5);

-- 6️ Users (5 Records) – for Adopter Info (optional)
INSERT INTO User (UserID, Name) VALUES
(1, 'John Doe'),
(2, 'Jane Smith'),
(3, 'Ravi Kumar'),
(4, 'Anita Rao'),
(5, 'Priya Mehta');

-- 7️ Adoption (5 Records) – Mapping PetID to UserID
INSERT INTO Adoption (PetID, UserID) VALUES
(3, 2),
(5, 3),
(7, 4),
(10, 5),
(1, 1);

-- 1. Retrieve a list of available pets
SELECT Name, Age, Breed, Type
FROM Pets
WHERE AvailableForAdoption = 1;

-- 2. Retrieve participants for a specific adoption event
-- Replace ? with the specific EventID
SELECT ParticipantName, ParticipantType
FROM Participants
WHERE EventID = ?;

-- 3. Stored procedure to update shelter info
DELIMITER $$

CREATE PROCEDURE UpdateShelterInfo(
    IN p_ShelterID INT,
    IN p_NewName VARCHAR(100),
    IN p_NewLocation VARCHAR(255)
)
BEGIN
    IF EXISTS (SELECT * FROM Shelters WHERE ShelterID = p_ShelterID) THEN
        UPDATE Shelters
        SET Name = p_NewName,
            Location = p_NewLocation
        WHERE ShelterID = p_ShelterID;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Shelter ID';
    END IF;
END $$

DELIMITER ;

-- Call the procedure example
-- CALL UpdateShelterInfo(1, 'New Name', 'New Location');

-- 4. Total donation amount for each shelter
SELECT s.Name AS ShelterName, COALESCE(SUM(d.DonationAmount), 0) AS TotalDonations
FROM Shelters s
LEFT JOIN Donations d ON s.ShelterID = d.ShelterID
GROUP BY s.ShelterID;

-- 5. Pets with no owner
SELECT Name, Age, Breed, Type
FROM Pets
WHERE OwnerID IS NULL;

-- 6. Total donation amount per month and year
SELECT 
    DATE_FORMAT(DonationDate, '%M %Y') AS MonthYear,
    SUM(DonationAmount) AS TotalAmount
FROM Donations
GROUP BY MonthYear
ORDER BY MIN(DonationDate);

-- 7. Distinct breeds of pets aged 1-3 or older than 5
SELECT DISTINCT Breed
FROM Pets
WHERE (Age BETWEEN 1 AND 3) OR Age > 5;

-- 8. Available pets and their respective shelters
SELECT p.Name AS PetName, s.Name AS ShelterName
FROM Pets p
JOIN Shelters s ON p.ShelterID = s.ShelterID
WHERE p.AvailableForAdoption = 1;

-- 9. Total participants in events held in a specific city
-- Replace 'Chennai' with the desired city
SELECT COUNT(*) AS TotalParticipants
FROM Participants p
JOIN AdoptionEvents e ON p.EventID = e.EventID
WHERE e.Location = 'Chennai';

-- 10. Unique breeds of pets aged between 1 and 5
SELECT DISTINCT Breed
FROM Pets
WHERE Age BETWEEN 1 AND 5;

-- 11. Find pets that have not been adopted
SELECT *
FROM Pets
WHERE OwnerID IS NULL;

-- 12. Adopted pets and adopter names
-- Assumes tables: Adoption(PetID, UserID), User(UserID, Name)
SELECT p.Name AS PetName, u.Name AS AdopterName
FROM Adoption a
JOIN Pets p ON a.PetID = p.PetID
JOIN User u ON a.UserID = u.UserID;

-- 13. Shelters and count of pets currently available for adoption
SELECT s.Name AS ShelterName, COUNT(p.PetID) AS AvailablePets
FROM Shelters s
LEFT JOIN Pets p ON s.ShelterID = p.ShelterID AND p.AvailableForAdoption = 1
GROUP BY s.ShelterID;

-- 14. Pairs of pets from the same shelter with same breed
SELECT p1.Name AS Pet1, p2.Name AS Pet2, p1.Breed, s.Name AS Shelter
FROM Pets p1
JOIN Pets p2 ON p1.ShelterID = p2.ShelterID AND p1.Breed = p2.Breed AND p1.PetID < p2.PetID
JOIN Shelters s ON p1.ShelterID = s.ShelterID;

-- 15. All combinations of shelters and adoption events
SELECT s.Name AS ShelterName, e.EventName
FROM Shelters s
CROSS JOIN AdoptionEvents e;

-- 16. Shelter with the highest number of adopted pets
-- Assumes pets with non-null OwnerID are adopted
SELECT s.Name AS ShelterName, COUNT(p.PetID) AS AdoptedPets
FROM Shelters s
JOIN Pets p ON s.ShelterID = p.ShelterID
WHERE p.OwnerID IS NOT NULL
GROUP BY s.ShelterID
ORDER BY AdoptedPets DESC
LIMIT 1;
