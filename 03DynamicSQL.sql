--Here's an example of a dynamic SQL query with one parameter

DECLARE @DynamicSQL NVARCHAR(MAX);
DECLARE @Parameter INT = 10; -- Example parameter value

SET @DynamicSQL = '
    SELECT *
    FROM YourTable
    WHERE YourColumn = @ParamValue
';

EXEC sp_executesql @DynamicSQL, N'@ParamValue INT', @ParamValue = @Parameter;

--Here's the expanded example with two more parameters

DECLARE @DynamicSQL NVARCHAR(MAX);
DECLARE @Parameter1 INT = 10; -- Example parameter value
DECLARE @Parameter2 NVARCHAR(50) = 'SomeValue'; -- Example parameter value
DECLARE @Parameter3 DATE = '2023-01-01'; -- Example parameter value

SET @DynamicSQL = '
    SELECT *
    FROM YourTable
    WHERE YourColumn1 = @ParamValue1
    AND YourColumn2 = @ParamValue2
    AND YourColumn3 >= @ParamValue3
';

EXEC sp_executesql @DynamicSQL, N'
    @ParamValue1 INT,
    @ParamValue2 NVARCHAR(50),
    @ParamValue3 DATE
', 
@ParamValue1 = @Parameter1,
@ParamValue2 = @Parameter2,
@ParamValue3 = @Parameter3;


--If you want the dynamic SQL query to return a parameter as part of its result set, 
-- you can declare an output parameter in the sp_executesql statement 
-- and retrieve the value after executing the dynamic SQL query.

DECLARE @DynamicSQL NVARCHAR(MAX);
DECLARE @Parameter1 INT = 10; -- Example parameter value
DECLARE @Parameter2 NVARCHAR(50) = 'SomeValue'; -- Example parameter value
DECLARE @Parameter3 DATE = '2023-01-01'; -- Example parameter value
DECLARE @OutputParameter INT; -- Declaration of output parameter

SET @DynamicSQL = '
    SELECT @OutputParam = COUNT(*)
    FROM YourTable
    WHERE YourColumn1 = @ParamValue1
    AND YourColumn2 = @ParamValue2
    AND YourColumn3 >= @ParamValue3
';

EXEC sp_executesql @DynamicSQL, N'
    @ParamValue1 INT,
    @ParamValue2 NVARCHAR(50),
    @ParamValue3 DATE,
    @OutputParam INT OUTPUT -- Declaration of output parameter
', 
@ParamValue1 = @Parameter1,
@ParamValue2 = @Parameter2,
@ParamValue3 = @Parameter3,
@OutputParam = @OutputParameter OUTPUT; -- Assigning the output parameter

-- Use @OutputParameter here, it holds the value returned by the dynamic SQL query
SELECT @OutputParameter AS OutputResult;



