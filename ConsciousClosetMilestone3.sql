-- Name: Faye Vaquilar
-- Course: DBMS-2006
-- Date: 12-8-2023
-- Updated: 12-13-2023
-- Milestone 3

USE ConsciousCloset;

-- Create Trigger to Delete Brand with No Certifications
CREATE OR ALTER TRIGGER DeleteBrandOnCertificationRemoval
ON BrandCertifications
-- Execute after delete from BrandCertifications Table
AFTER DELETE
AS
BEGIN
    -- Turn off counting of rows affected to reduce overhead 
    SET NOCOUNT ON;

    -- Check for Brands without Certifications:
    IF NOT EXISTS (SELECT 1 FROM BrandCertifications 
				   GROUP BY brand_id HAVING COUNT(certification_id) = 0) --  counts the number of certifications for each brand and checks if zero
    BEGIN
        -- Delete Brands with No Certifications:
        DELETE FROM Brands -- If condition is true delete those brands
        WHERE brand_id IN (SELECT brand_id FROM deleted); -- delete brands where ID matches those in delete table
    END
END;

-- Select brands with only one certification
SELECT b.brand_id, b.brand_name, bc.certification_id, c.certification_name
FROM Brands b
INNER JOIN BrandCertifications bc ON b.brand_id = bc.brand_id
INNER JOIN Certifications c ON bc.certification_id = c.certification_id
GROUP BY b.brand_id, b.brand_name, bc.certification_id, c.certification_name
HAVING COUNT(bc.certification_id) = 1;

BEGIN TRANSACTION;
-- Delete the certification for Helly Hansen to trigger
DELETE FROM BrandCertifications WHERE brand_id = 1 AND certification_id = 4;

-- Check the Brands table after the trigger execution
SELECT * FROM Brands;
ROLLBACK;

-- Create a stored procedure for marking a secondhand item as sold
CREATE OR ALTER PROCEDURE usp_MarkItemAsSold
    @itemId INT
AS
BEGIN
    -- Begin the transaction
    BEGIN TRANSACTION;

    -- Update the status of the secondhand item to 'Sold'
    UPDATE SecondhandItems
    SET status = 'Sold'
    WHERE secondhand_item_id = @itemId;

    -- Commit the transaction
    COMMIT;

    PRINT 'Secondhand item marked as sold successfully.';
END;
-- Example usp_MarkItemAsSold
SELECT * FROM SecondhandItems WHERE secondhand_item_id = 1;
DECLARE @item_id INT = 1;
BEGIN TRANSACTION;
EXEC usp_MarkItemAsSold @item_id;
--SELECT * FROM SecondhandItems WHERE secondhand_item_id = @item_id;
ROLLBACK;

-- Write a query (outer join) to retrieve data from 3 or more tables
SELECT
    U.user_id,
    U.username,
    P.post_id,
    P.post_type,
    P.date_posted,
    SI.secondhand_item_id,
    SI.secondhand_item_name,
    SI.description
FROM
    Users U
LEFT JOIN
    Posts P ON U.user_id = P.user_id
LEFT JOIN
    SecondhandItems SI ON U.user_id = SI.seller_user_id
WHERE
    P.post_id IS NULL AND SI.secondhand_item_id IS NULL;

-- Create and demonstrate 2 Roles/Users interacting with database objects
CREATE ROLE AdminRole;
CREATE ROLE UserRole;
-- Create Logins
CREATE LOGIN AdminLogin WITH PASSWORD = 'AdminPW';
CREATE LOGIN UserLogin WITH PASSWORD = 'UserPW';
-- Create Users
CREATE USER AdminUser FOR LOGIN AdminLogin;
CREATE USER RegularUser FOR LOGIN UserLogin;
-- Assign roles
-- Assign roles to users
ALTER ROLE AdminRole ADD MEMBER AdminUser;
ALTER ROLE UserRole ADD MEMBER RegularUser;
-- Grant permissions
-- User
GRANT SELECT ON Brands TO UserRole;
GRANT SELECT ON Certifications TO UserRole;
GRANT SELECT ON BrandCertifications TO UserRole;
-- Admin
GRANT SELECT, INSERT, UPDATE, DELETE ON Brands TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Certifications TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON BrandCertifications TO AdminRole;

SELECT CURRENT_USER;

-- AdminRole demo
EXECUTE AS USER = 'AdminUser';
BEGIN TRANSACTION;
INSERT INTO Brands (brand_name, description, website)
VALUES ('NewBrand', 'Description of NewBrand', 'http://newbrand.com');
DELETE FROM BrandCertifications WHERE brand_id = 1;
UPDATE Certifications SET description = 'New Description' WHERE certification_id = 1;
-- Check changes
SELECT * FROM Brands;
SELECT * FROM BrandCertifications;
SELECT * FROM Certifications;
ROLLBACK;
-- Compare with rollback table
SELECT * FROM Brands;
SELECT * FROM BrandCertifications;
SELECT * FROM Certifications;
-- Revert to original user
REVERT;

-- UserRole Demo
EXECUTE AS USER = 'RegularUser';
INSERT INTO Brands (brand_name, description, website) VALUES ('NewBrand', 'Description', 'www.newbrand.com');
DELETE FROM Certifications WHERE certification_id = 1;
UPDATE Brands SET description = 'New Description' WHERE brand_id = 1;
SELECT * FROM Brands;
SELECT * FROM BrandCertifications;
SELECT * FROM Certifications;
REVERT;

--  Non-correlated subquery
-- Brands with at least 2 certifications
SELECT brand_name
FROM Brands
WHERE brand_id IN (
    SELECT brand_id
    FROM BrandCertifications
    GROUP BY brand_id
    HAVING COUNT(certification_id) >= 2
);

-- Correlated subquery
-- Users and items listed count
SELECT username,
       (SELECT COUNT(*) 
	    FROM SecondhandItems 
		WHERE seller_user_id = U.user_id) AS item_count
FROM Users U;

-- Aggregate data
SELECT FORMAT(AVG(price), 'C') AS average_item_price
FROM SecondhandItems;










