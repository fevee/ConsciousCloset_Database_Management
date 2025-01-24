# Conscious Closet (2C)  

## Project Overview  
**Conscious Closet (2C)** is a **database management system** for sustainable fashion enthusiasts, built using **Microsoft SQL Server**. It enables users to explore sustainable brands, buy/sell second-hand garments, and promote a circular fashion economy. The project aligns with ethical consumerism and sustainable fashion goals.  

## Technical Highlights  
- **Database Design**: Entity Relationship Diagram (ERD), normalization, and schema creation.  
- **Microsoft SQL Server**: Used for database creation, optimization, and querying.  
- **SQL Features Utilized**:  
  - Constraints (e.g., `UNIQUE`, `CHECK`).  
  - Advanced Queries (e.g., `JOIN`, Views, Functions).  
  - Triggers (e.g., auto-deletion of brands without certifications).  
  - Stored Procedures (e.g., marking items as sold).  
- **Data Integrity**: Foreign key relationships, cascading actions, and validation rules.  
- **Data Population**: Imported datasets for brands, users, and transactions.

## Entity Relationship Diagram (ERD)
![image](https://github.com/user-attachments/assets/ee07e938-0ec3-4fc1-b458-c76b5e39f4e2)

## Core Functionalities  
1. **User Interactions**:  
   - Follow users and brands.  
   - Share posts (text, photo, video).  

2. **Secondhand Marketplace**:  
   - List, filter, and manage second-hand items.  
   - Track item statuses (listed/sold).  

3. **Sustainability Features**:  
   - Brands linked to verified certifications.  
   - Views for users’ followed brands and users.  

4. **Custom SQL Functions & Procedures**:  
   - Retrieve second-hand items by size.  
   - Update item statuses efficiently.  

## Example Code Snippets  
**View: Followed Usernames**  
```sql
CREATE VIEW UserFollowedUsernames AS
SELECT UF.follower_user_id, U.username AS followed_username
FROM UserFollowers UF
INNER JOIN Users U ON UF.followed_user_id = U.user_id;
```
**Stored Procedure: Mark Item as Sold**  
```sql
CREATE OR ALTER PROCEDURE usp_MarkItemAsSold
    @itemId INT
AS
BEGIN
    BEGIN TRANSACTION;
    UPDATE SecondhandItems
    SET status = 'Sold'
    WHERE secondhand_item_id = @itemId;
    COMMIT;
    PRINT 'Secondhand item marked as sold successfully.';
END;
```
**Trigger: Delete Brands Without Certifications**  
```sql
CREATE OR ALTER TRIGGER DeleteBrandOnCertificationRemoval
ON BrandCertifications
AFTER DELETE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BrandCertifications 
                   GROUP BY brand_id HAVING COUNT(certification_id) > 0)
    BEGIN
        DELETE FROM Brands WHERE brand_id IN (SELECT brand_id FROM deleted);
    END
END;
