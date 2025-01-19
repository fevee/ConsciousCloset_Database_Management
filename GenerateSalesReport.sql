-- Name: Faye Vaquilar
-- Course: DBMS-2006
-- Date: 12-12-2023
-- Final Project: Milestone 3 - batch file sql

USE ConsciousCloset;

SET NOCOUNT ON

DECLARE @ReportDate VARCHAR(20);
SET @ReportDate = CONVERT(VARCHAR, GETDATE());
PRINT 'Report Date: ' + @ReportDate;

PRINT 'Sales Report: Secondhand Items Sold and Their Prices';

SELECT
    SI.secondhand_item_id,
    SI.secondhand_item_name,
    SI.size,
    SI.date_listed,
    SI.price,
    U.user_id,
    U.username
FROM
    SecondhandItems SI
JOIN
    Users U ON SI.seller_user_id = U.user_id
WHERE
    SI.status = 'Sold'
ORDER BY
    SI.date_listed;

-- Variable to store the total sales amount
DECLARE @TotalSalesAmount DECIMAL(10, 2);

-- Assign result to variable
SELECT @TotalSalesAmount = SUM(price)
FROM SecondhandItems
WHERE status = 'Sold';

-- The total sales amount is now used in the PRINT statement
PRINT 'Total Sales Amount: $' + CONVERT(VARCHAR, @TotalSalesAmount);

PRINT 'End of Report';