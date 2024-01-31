DECLARE @SearchString1 NVARCHAR(100) = 'test';
DECLARE @SearchString2 NVARCHAR(100) = 'demo';

-- Create a temporary table to store the results
CREATE TABLE #TempResult (FilePath NVARCHAR(MAX), TestCount INT, DemoCount INT);

-- Iterate over each path in the table
DECLARE @FilePath NVARCHAR(MAX);
DECLARE filePath_cursor CURSOR FOR 
SELECT FilePath FROM YourTableName;

OPEN filePath_cursor;
FETCH NEXT FROM filePath_cursor INTO @FilePath;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Dynamic SQL to read and count occurrences of @SearchString1 and @SearchString2 in the file
    DECLARE @DynamicSQL NVARCHAR(MAX) = '
        DECLARE @InputString NVARCHAR(MAX);
        DECLARE @TestCount INT = 0;
        DECLARE @DemoCount INT = 0;

        -- Read the contents of the file into @InputString
        SET @InputString = (SELECT BulkColumn FROM OPENROWSET(BULK ''' + @FilePath + ''', SINGLE_CLOB) AS Contents);

        -- Count occurrences of @SearchString1 in @InputString
        DECLARE @Position INT = 1;
        WHILE @Position > 0
        BEGIN
            SET @Position = CHARINDEX(''' + @SearchString1 + ''', @InputString, @Position);
            IF @Position > 0
            BEGIN
                SET @TestCount = @TestCount + 1;
                SET @Position = @Position + LEN(''' + @SearchString1 + ''');
            END
        END

        -- Count occurrences of @SearchString2 in @InputString
        SET @Position = 1;
        WHILE @Position > 0
        BEGIN
            SET @Position = CHARINDEX(''' + @SearchString2 + ''', @InputString, @Position);
            IF @Position > 0
            BEGIN
                SET @DemoCount = @DemoCount + 1;
                SET @Position = @Position + LEN(''' + @SearchString2 + ''');
            END
        END

        -- Output the result
        SELECT ''' + @FilePath + ''' AS FilePath, @TestCount AS TestCount, @DemoCount AS DemoCount;
    ';

    -- Execute the dynamic SQL
    INSERT INTO #TempResult (FilePath, TestCount, DemoCount)
    EXEC sp_executesql @DynamicSQL;

    FETCH NEXT FROM filePath_cursor INTO @FilePath;
END

CLOSE filePath_cursor;
DEALLOCATE filePath_cursor;

-- Select the results from the temporary table
SELECT * FROM #TempResult;

-- Drop the temporary table
DROP TABLE #TempResult;

-- I've added another search string @SearchString2 for 'demo'.
-- The dynamic SQL now includes counting occurrences of both @SearchString1 ('test') 
-- and @SearchString2 ('demo') in the file.
-- The results are inserted into the temporary table #TempResult, 
-- which has columns for FilePath, TestCount, and DemoCount.
-- Finally, the results are selected from the temporary table, 
-- and the temporary table is dropped.
-- Again, replace YourTableName with the actual name of your table containing the file paths. 
-- Adjust the search strings (@SearchString1 and @SearchString2) 
-- as needed for your specific scenario.

-- Create a temporary table to store the results
CREATE TABLE #TempResult (FilePath NVARCHAR(MAX), FromTestCount INT, AsDemoCount INT);

-- Iterate over each path in the table
DECLARE @FilePath NVARCHAR(MAX);
DECLARE filePath_cursor CURSOR FOR 
SELECT FilePath FROM YourTableName;

OPEN filePath_cursor;
FETCH NEXT FROM filePath_cursor INTO @FilePath;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Dynamic SQL to read and count occurrences of texts with wildcards in the file
    DECLARE @DynamicSQL NVARCHAR(MAX) = '
        DECLARE @InputString NVARCHAR(MAX);
        DECLARE @FromTestCount INT = 0;
        DECLARE @AsDemoCount INT = 0;

        -- Read the contents of the file into @InputString
        SET @InputString = (SELECT BulkColumn FROM OPENROWSET(BULK ''' + @FilePath + ''', SINGLE_CLOB) AS Contents);

        -- Count occurrences of '%from%test' in @InputString
        SET @FromTestCount = (SELECT COUNT(*) FROM (SELECT 1 WHERE @InputString LIKE ''%from%test%'') AS T);

        -- Count occurrences of '%as%demo' in @InputString
        SET @AsDemoCount = (SELECT COUNT(*) FROM (SELECT 1 WHERE @InputString LIKE ''%as%demo%'') AS T);

        -- Output the result
        SELECT ''' + @FilePath + ''' AS FilePath, @FromTestCount AS FromTestCount, @AsDemoCount AS AsDemoCount;
    ';

    -- Execute the dynamic SQL
    INSERT INTO #TempResult (FilePath, FromTestCount, AsDemoCount)
    EXEC sp_executesql @DynamicSQL;

    FETCH NEXT FROM filePath_cursor INTO @FilePath;
END

CLOSE filePath_cursor;
DEALLOCATE filePath_cursor;

-- Select the results from the temporary table
SELECT * FROM #TempResult;

-- Drop the temporary table
DROP TABLE #TempResult;



-- I've defined two variables @FromTestCount and @AsDemoCount to 
-- store the count of occurrences for the respective wildcard patterns.
-- The dynamic SQL now uses the LIKE operator with the % wildcard character 
-- to count occurrences of the specified wildcard patterns in the file contents.
-- The results are inserted into the temporary table #TempResult, 
-- which has columns for FilePath, FromTestCount, and AsDemoCount.
-- Finally, the results are selected from the temporary table, 
-- and the temporary table is dropped.

-- CREATE PROCEDURE Examples
CREATE PROCEDURE GetRecordCount
    @RecordCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Actual query to get the record count
    SELECT @RecordCount = COUNT(*)
    FROM YourTableName;
END;

DECLARE @OutputCount INT;

EXEC GetRecordCount @RecordCount = @OutputCount OUTPUT;

-- Now @OutputCount contains the record count
PRINT 'Record Count: ' + CAST(@OutputCount AS VARCHAR);

-- CREATE PROCEDURE Examples
CREATE PROCEDURE GetRecordCountByParameters
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @RecordCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Actual query to get the record count based on input parameters
    SELECT @RecordCount = COUNT(*)
    FROM YourTableName
    WHERE FirstName = @FirstName AND LastName = @LastName;
END;


DECLARE @OutputCount INT;

-- Execute the stored procedure with specific values for input parameters
EXEC GetRecordCountByParameters 
@FirstName = 'John', 
@LastName = 'Doe', 
@RecordCount = @OutputCount OUTPUT;

-- Now @OutputCount contains the record count based on the specified parameters
PRINT 'Record Count: ' + CAST(@OutputCount AS VARCHAR);


-- CREATE PROCEDURE Examples
CREATE PROCEDURE AssignCategory
    @Parameter1 INT,
    @Parameter2 INT,
    @Category NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Use a CASE statement to determine the category based on input parameters
    SELECT @Category = 
        CASE
            WHEN @Parameter1 > @Parameter2 THEN 'Category A'
            WHEN @Parameter1 < @Parameter2 THEN 'Category B'
            ELSE 'Equal Categories'
        END;
END;

DECLARE @OutputCategory NVARCHAR(50);

-- Execute the stored procedure with specific values for input parameters
EXEC AssignCategory @Parameter1 = 10, @Parameter2 = 5, @Category = @OutputCategory OUTPUT;

-- Now @OutputCategory contains the assigned category based on the specified parameters
PRINT 'Category: ' + ISNULL(@OutputCategory, 'No Category');


-- WHEN THEN Examples
SELECT
    CustomerID,
    OrderDate,
    CASE
        WHEN TotalAmount > 1000 THEN
            BEGIN
                'High Value'
                + ' - Pay with Credit Card'
                + ' - Total Amount: ' + CAST(TotalAmount AS VARCHAR(20))
            END
        WHEN TotalAmount > 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS OrderCategory
FROM
    Orders;


-- WHEN THEN Examples
-- Create a table to store the results
CREATE TABLE ResultTable (
    CustomerID INT,
    OrderDate DATE,
    OrderCategory NVARCHAR(100)
);

-- Insert results into the table based on the CASE statement
INSERT INTO ResultTable (CustomerID, OrderDate, OrderCategory)
SELECT
    CustomerID,
    OrderDate,
    CASE
        WHEN TotalAmount > 1000 THEN
            'High Value - Pay with Credit Card - Total Amount: ' + CAST(TotalAmount AS VARCHAR(20))
        WHEN TotalAmount > 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS OrderCategory
FROM
    Orders;

-- Select all rows from the result table
SELECT * FROM ResultTable;

-- Drop the result table (optional)
DROP TABLE ResultTable;




