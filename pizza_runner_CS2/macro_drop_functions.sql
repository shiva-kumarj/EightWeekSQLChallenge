-- Use this to check database name.
SELECT name, object_id, create_date, modify_date, type_desc
FROM sys.objects
WHERE type_desc = 'SQL_SCALAR_FUNCTION'

select @@SERVERNAME as server_name, DB_NAME() as db_name; 

use PIZZA_RESTAURANT;

IF OBJECT_ID('pizza_restaurant..#dropFunctionsEnabled') IS NOT NULL
    DROP TABLE #dropFunctionsEnabled;


CREATE TABLE #dropFunctionsEnabled (enabled BIT);

INSERT INTO #dropFunctionsEnabled (enabled) VALUES (1);

GO

-- macro to enable or disable DROP FUNCTION statements
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[toggleDropFunctions]'))
BEGIN
DROP PROCEDURE [dbo].[toggleDropFunctions];
END
GO

CREATE PROCEDURE dbo.toggleDropFunctions (@enable BIT)
AS
BEGIN
    UPDATE #dropFunctionsEnabled SET enabled = @enable;
END
GO

-- DROP FUNCTION statement that uses the macro
IF EXISTS (SELECT 1 FROM #dropFunctionsEnabled WHERE enabled = 1)
BEGIN
    DROP FUNCTION [dbo].[ingredientIdtoName];
    DROP FUNCTION [dbo].[getIngredientName];
    DROP FUNCTION [dbo].[readablePizzaOrder];
    DROP FUNCTION [dbo].[getPizzaName];
END
GO

select * from #dropFunctionsEnabled;
EXEC dbo.toggleDropFunctions 1;

