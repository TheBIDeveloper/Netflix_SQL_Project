-- Create Database
CREATE DATABASE NetflixAnalytics;
GO

USE NetflixAnalytics;
GO

--------------------------------------------------
-- Users Table
--------------------------------------------------
CREATE TABLE users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    user_name VARCHAR(100),
    country VARCHAR(50)
);

--------------------------------------------------
-- Genres Table
--------------------------------------------------
CREATE TABLE genres (
    genre_id INT IDENTITY(1,1) PRIMARY KEY,
    genre_name VARCHAR(50)
);

--------------------------------------------------
-- Shows Table
--------------------------------------------------
CREATE TABLE shows (
    show_id INT IDENTITY(1,1) PRIMARY KEY,
    show_name VARCHAR(100),
    genre_id INT,
    release_year INT,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

--------------------------------------------------
-- Viewing Sessions Table
--------------------------------------------------
CREATE TABLE viewing_sessions (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    show_id INT,
    watch_date DATE,
    watch_duration_minutes INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (show_id) REFERENCES shows(show_id)
);

--------------------------------------------------
-- Insert Genres
--------------------------------------------------
INSERT INTO genres (genre_name)
VALUES
('Drama'),
('Comedy'),
('Action'),
('Thriller'),
('Documentary');

--------------------------------------------------
-- Insert Shows
--------------------------------------------------
INSERT INTO shows (show_name, genre_id, release_year)
VALUES
('Stranger Things', 1, 2016),
('The Crown', 1, 2016),
('Brooklyn Nine-Nine', 2, 2013),
('Money Heist', 3, 2017),
('Narcos', 4, 2015),
('Our Planet', 5, 2019);

--------------------------------------------------
-- Insert Users
--------------------------------------------------
INSERT INTO users (user_name, country)
VALUES
('Alice', 'USA'),
('Bob', 'UK'),
('Charlie', 'India'),
('Diana', 'Canada'),
('Ethan', 'Australia');

--------------------------------------------------
-- Insert Viewing Sessions
--------------------------------------------------
INSERT INTO viewing_sessions (user_id, show_id, watch_date, watch_duration_minutes)
VALUES
(1, 1, GETDATE()-10, 50),
(1, 3, GETDATE()-9, 30),
(2, 2, GETDATE()-8, 45),
(2, 4, GETDATE()-7, 60),
(3, 1, GETDATE()-6, 55),
(3, 5, GETDATE()-5, 40),
(4, 6, GETDATE()-4, 50),
(4, 2, GETDATE()-3, 45),
(5, 3, GETDATE()-2, 35),
(5, 4, GETDATE()-1, 60);
