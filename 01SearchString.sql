DECLARE @InputString NVARCHAR(MAX) = 'This is a test. This is the second test.';
DECLARE @SearchString NVARCHAR(100) = 'test';
DECLARE @Position INT = 1;
DECLARE @Count INT = 0;

WHILE @Position > 0
BEGIN
    SET @Position = CHARINDEX(@SearchString, @InputString, @Position);
    IF @Position > 0
    BEGIN
        SET @Count = @Count + 1;
        SET @Position = @Position + LEN(@SearchString);
    END
END

SELECT @Count AS TestCount;

-- @InputString is the input string you want to search within.
-- @SearchString is the substring you want to count occurrences of (in this case, "test").
-- @Position is used to keep track of the current position in the string.
-- @Count is the variable that accumulates the count of occurrences.
-- The WHILE loop iterates through the string, searching for the occurrence of "test" 
-- using the CHARINDEX function. 
-- If an occurrence is found, the count is incremented, 
-- and the search position is updated to continue searching from the next position.
-- After the loop, the value of @Count is returned as the result, 
-- which represents the number of occurrences of "test" in the input string. 
-- In this example, it should return 2. Adjust @InputString and @SearchString 
-- as needed for your specific scenario.


DECLARE @SearchString NVARCHAR(100) = 'test';
DECLARE @Count INT = 0;

-- Create a temporary table to store the results
CREATE TABLE #TempResult (FilePath NVARCHAR(MAX), TestCount INT);

-- Iterate over each path in the table
DECLARE @FilePath NVARCHAR(MAX);
DECLARE filePath_cursor CURSOR FOR 
SELECT FilePath FROM YourTableName;

OPEN filePath_cursor;
FETCH NEXT FROM filePath_cursor INTO @FilePath;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Dynamic SQL to read and count occurrences of @SearchString in the file
    DECLARE @DynamicSQL NVARCHAR(MAX) = '
        DECLARE @InputString NVARCHAR(MAX);
        DECLARE @LocalCount INT = 0;

        -- Read the contents of the file into @InputString
        SET @InputString = (SELECT BulkColumn FROM OPENROWSET(BULK ''' + @FilePath + ''', SINGLE_CLOB) AS Contents);

        -- Count occurrences of @SearchString in @InputString
        DECLARE @Position INT = 1;
        WHILE @Position > 0
        BEGIN
            SET @Position = CHARINDEX(''' + @SearchString + ''', @InputString, @Position);
            IF @Position > 0
            BEGIN
                SET @LocalCount = @LocalCount + 1;
                SET @Position = @Position + LEN(''' + @SearchString + ''');
            END
        END

        -- Output the result
        SELECT ''' + @FilePath + ''' AS FilePath, @LocalCount AS TestCount;
    ';

    -- Execute the dynamic SQL
    INSERT INTO #TempResult (FilePath, TestCount)
    EXEC sp_executesql @DynamicSQL;

    FETCH NEXT FROM filePath_cursor INTO @FilePath;
END

CLOSE filePath_cursor;
DEALLOCATE filePath_cursor;

-- Select the results from the temporary table
SELECT * FROM #TempResult;

-- Drop the temporary table
DROP TABLE #TempResult;

-- Replace YourTableName with the name of your table that contains the paths to the CSV files.
-- The code iterates over each file path in the table using a cursor.
-- For each file path, it reads the contents of the file using OPENROWSET 
-- and counts the occurrences of @SearchString.
-- The results (file path and corresponding count) are inserted 
-- into a temporary table (#TempResult).
-- Finally, the results are selected from the temporary table, 
-- and the temporary table is dropped.




