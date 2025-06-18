-- Create database (optional: run manually if needed)
-- CREATE DATABASE conservation_db;
-- \c conservation_db

-- ==========================
-- Table Creation
-- ==========================

-- Drop tables if they already exist (for clean setup)
DROP TABLE IF EXISTS sightings;
DROP TABLE IF EXISTS species;
DROP TABLE IF EXISTS rangers;

-- Create rangers table
CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL
);

-- Create species table
CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(150) NOT NULL,
    discovery_date DATE NOT NULL,
    conservation_status VARCHAR(50) DEFAULT 'Unknown'
);

-- Create sightings table
CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    species_id INT REFERENCES species(species_id),
    ranger_id INT REFERENCES rangers(ranger_id),
    sighting_time TIMESTAMP NOT NULL,
    location VARCHAR(150) NOT NULL,
    notes TEXT
);

-- ==========================
-- Sample Data Insertion
-- ==========================

-- Rangers
INSERT INTO rangers (ranger_id, name, region) VALUES
(1, 'Alice Green', 'Northern Hills'),
(2, 'Bob White', 'River Delta'),
(3, 'Carol King', 'Mountain Range');

-- Species
INSERT INTO species (species_id, common_name, scientific_name, discovery_date, conservation_status) VALUES
(1, 'Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
(2, 'Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
(3, 'Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
(4, 'Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

-- Sightings
INSERT INTO sightings (sighting_id, species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 1, 'Peak Ridge', '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 2, 'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
(4, 1, 2, 'Snowfall Pass', '2024-05-18 18:30:00', NULL);

-- ==========================
-- Assignment Problems
-- ==========================

-- Problem 1️⃣: Register a new ranger
INSERT INTO rangers (name, region) VALUES ('Derek Fox', 'Coastal Plains');

-- Problem 2️⃣: Count unique species ever sighted
SELECT COUNT(DISTINCT species_id) AS unique_species_count FROM sightings;

-- Problem 3️⃣: Sightings where location includes "Pass"
SELECT * FROM sightings
WHERE location ILIKE '%Pass%';

-- Problem 4️⃣: Total number of sightings per ranger
SELECT r.name, COUNT(s.sighting_id) AS total_sightings
FROM rangers r
LEFT JOIN sightings s ON r.ranger_id = s.ranger_id
GROUP BY r.ranger_id;

-- Problem 5️⃣: Species never sighted
SELECT s.common_name
FROM species s
LEFT JOIN sightings si ON s.species_id = si.species_id
WHERE si.sighting_id IS NULL;

-- Problem 6️⃣: Most recent 2 sightings
SELECT sp.common_name, si.sighting_time, r.name
FROM sightings si
JOIN species sp ON si.species_id = sp.species_id
JOIN rangers r ON si.ranger_id = r.ranger_id
ORDER BY si.sighting_time DESC
LIMIT 2;

-- Problem 7️⃣: Update conservation status to 'Historic'
UPDATE species
SET conservation_status = 'Historic'
WHERE discovery_date < '1800-01-01';

-- Problem 8️⃣: Label time of day
SELECT sighting_id,
    CASE
        WHEN EXTRACT(HOUR FROM sighting_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sighting_time) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sightings;

-- Problem 9️⃣: Delete rangers who never sighted anything
DELETE FROM rangers
WHERE ranger_id NOT IN (
    SELECT DISTINCT ranger_id FROM sightings
);
