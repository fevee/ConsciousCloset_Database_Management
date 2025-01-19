-- Name: Faye Vaquilar
-- Course: DBMS-2006
-- Date: 11-28-2023
-- Updated: 12-13-2023
-- Milestone 2 

-- Create Database
CREATE DATABASE ConsciousCloset;

-- Create Users Table
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(25) NOT NULL,
    email NVARCHAR(50) NOT NULL,
    password VARCHAR(25) NOT NULL,
    registration_date DATETIME NOT NULL,
	
);

-- Create Brands Table
CREATE TABLE Brands (
    brand_id INT IDENTITY(1,1) PRIMARY KEY,
    brand_name NVARCHAR NOT NULL,
    description NVARCHAR(350) NOT NULL,
	website nVARCHAR(100) NOT NULL
);
ALTER TABLE Brands ALTER COLUMN brand_name nVARCHAR(100) NOT NULL;

-- Create BrandFollowers Table
CREATE TABLE BrandFollowers (
    user_id INT,
    brand_id INT,
    follow_date DATETIME NOT NULL,
    PRIMARY KEY (user_id, brand_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (brand_id) REFERENCES Brands(brand_id)
);
ALTER TABLE BrandFollowers
DROP CONSTRAINT FK__BrandFoll__brand__3C69FB99;

ALTER TABLE BrandFollowers
ADD CONSTRAINT FK__BrandFoll__brand__3C69FB99
FOREIGN KEY (brand_id) REFERENCES Brands(brand_id)
ON DELETE CASCADE;

-- Create UserFollowers Table
CREATE TABLE UserFollowers (
    follower_user_id INT,
    followed_user_id INT,
    follow_date DATETIME NOT NULL,
    PRIMARY KEY (follower_user_id, followed_user_id),
    FOREIGN KEY (follower_user_id) REFERENCES Users(user_id),
    FOREIGN KEY (followed_user_id) REFERENCES Users(user_id)
);

-- Create Certifications Table
CREATE TABLE Certifications (
    certification_id INT IDENTITY(1,1) PRIMARY KEY,
    certification_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(350) NOT NULL,
	website nVARCHAR(100) NOT NULL
);

-- Create BrandCertifications Table
CREATE TABLE BrandCertifications (
    brand_id INT,
    certification_id INT,
    date_added DATETIME NOT NULL,
    PRIMARY KEY (brand_id, certification_id),
    FOREIGN KEY (brand_id) REFERENCES Brands(brand_id),
    FOREIGN KEY (certification_id) REFERENCES Certifications(certification_id)
);

-- Create Posts Table
CREATE TABLE Posts (
	post_id INT IDENTITY(1,1) PRIMARY KEY,
	user_id INT,
	post_type VARCHAR(10) NOT NULL,
	date_posted DATETIME NOT NULL,
	FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
ALTER TABLE Posts
ADD post_url NVARCHAR(255);
ALTER TABLE Posts ALTER COLUMN user_id INT NOT NULL;
ALTER TABLE Posts ALTER COLUMN post_url NVARCHAR(255) NOT NULL;


-- Create SecondhandItems Table
CREATE TABLE SecondhandItems (
	secondhand_item_id INT IDENTITY(1,1) PRIMARY KEY,
	seller_user_id INT,
	secondhand_item_name nVARCHAR(50) NOT NULL,
	size VARCHAR(3) NOT NULL, -- added to ERD
	description nVARCHAR(250) NOT NULL,
	status VARCHAR(10) NOT NULL,
	date_listed DATETIME NOT NULL,
	FOREIGN KEY (seller_user_id) REFERENCES Users(user_id)
);
ALTER TABLE SecondhandItems ALTER COLUMN description nVARCHAR(350) NOT NULL;
ALTER TABLE SecondhandItems ALTER COLUMN seller_user_id INT NOT NULL;
ALTER TABLE SecondhandItems ALTER COLUMN price DECIMAL(7, 2) NOT NULL;

-- Add CHECK constraint for valid usernames. 
-- Can only contain a-z, A-Z, 0-9, "-", "_", "."
ALTER TABLE Users
ADD CONSTRAINT Check_ValidUsername CHECK (
    username NOT LIKE '%[^a-zA-Z0-9\-_\.]%'
);

INSERT INTO Users
VALUES('hd4', 'email@email.com', 'pw', 2023-12-06);
-- Add unique constraint for usernames
ALTER TABLE Users
ADD CONSTRAINT Unique_Username UNIQUE (username);
-- Add unique constraint for emails
ALTER TABLE Users
ADD CONSTRAINT Unique_Email UNIQUE (email);

-- Import data using CSV or similar files
SELECT * FROM  Brands;
SELECT * FROM  Users;
SELECT * FROM BrandFollowers;
SELECT * FROM UserFollowers;
SELECT * FROM Certifications;
SELECT * FROM BrandCertifications;
SELECT * FROM SecondhandItems;
SELECT * FROM Posts;
-- Total Rows: 203 

-- View for usernames followed by a user
CREATE VIEW UserFollowedUsernames AS
-- Select the follower user ID and the followed username
SELECT
    UF.follower_user_id,
    U.username AS followed_username
FROM
    UserFollowers UF
-- Join with Users table to get details of the followed user
INNER JOIN
    Users U ON UF.followed_user_id = U.user_id;

-- View for brands followed by a user
CREATE VIEW UserFollowedBrands AS
-- Select the follower user ID and the brand name
SELECT
    UF.follower_user_id,
    B.brand_name AS followed_brand
FROM
    UserFollowers UF
-- Join with BrandFollowers to get details of brands followed by the user
INNER JOIN
    BrandFollowers BF ON UF.follower_user_id = BF.user_id
-- Join with Brands table to get details of the followed brands
INNER JOIN
    Brands B ON BF.brand_id = B.brand_id;

-- Select usernames followed by a specific user
DECLARE @user_id INT = 1; -- Replace with the user's actual ID
SELECT *
FROM UserFollowedUsernames
WHERE follower_user_id = @user_id;

-- Select brands followed by a specific user
DECLARE @userID INT = 1; -- Replace with the user's actual ID
SELECT *
FROM UserFollowedBrands
WHERE follower_user_id = @userID;

-- Create function to get all secondhand items by size
CREATE FUNCTION GetItemsBySize(@size VARCHAR(3))
RETURNS TABLE
AS
RETURN
(
    SELECT SHI.secondhand_item_id, SHI.secondhand_item_name, SHI.size, SHI.description, SHI.status, SHI.date_listed
    FROM SecondhandItems AS SHI
    WHERE UPPER(SHI.size) = UPPER(@size)
);

-- Use the function to get all size small items 
SELECT * FROM GetItemsBySize('l');



