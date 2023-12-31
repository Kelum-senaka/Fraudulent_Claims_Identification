USE [ExpenseReports]

GO

IF (OBJECT_ID('dbo.Model') IS NULL)
BEGIN
	CREATE TABLE dbo.Model
	(
		ModelID INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_Model] PRIMARY KEY CLUSTERED,
		ModelLanguage NVARCHAR(20),
		ModelType NVARCHAR(40),
		Model VARBINARY(MAX)
	);
END

GO

CREATE OR ALTER PROCEDURE dbo.ExpenseReports_TrainModelML
(
@language NVARCHAR(128),
@modelType NVARCHAR(30),
@trainedModel VARBINARY(MAX) OUTPUT
)
AS
BEGIN
	DECLARE
		@sql NVARCHAR(MAX),
		@remoteCommand NVARCHAR(MAX);

	SET @sql = N'
	SELECT
		er.EmployeeID,
		CONCAT(e.FirstName, '' '', e.LastName) AS EmployeeName,
		ec.ExpenseCategoryID,
		ec.ExpenseCategory,
		er.ExpenseDate,
		YEAR(er.ExpenseDate) AS ExpenseYear,
		-- Python requires FLOAT values--it does not support DECIMAL
		CAST(er.Amount AS FLOAT) AS Amount
	FROM dbo.ExpenseReport er
		INNER JOIN dbo.ExpenseCategory ec
			ON er.ExpenseCategoryID = ec.ExpenseCategoryID
		INNER JOIN dbo.Employee e
			ON e.EmployeeID = er.EmployeeID 
	WHERE
		er.ExpenseDate < ''2017-01-01'';';


	BEGIN
		-- Note that Python is whitespace-sensitive, so we don't want to mess with the alignment.
		SET @remoteCommand = N'
import pickle 
from sklearn.ensemble import RandomForestRegressor
reg = RandomForestRegressor() 
trained_model = pickle.dumps(reg.fit(ExpenseData[["ExpenseCategoryID", "ExpenseYear"]], ExpenseData[["Amount"]].values.ravel())) 
';
	END

	EXEC sp_execute_external_script
		@language = @language,
		@script = @remoteCommand,
		@input_data_1 = @sql,
		@input_data_1_name = N'ExpenseData',
		@params = N'@trained_model varbinary(max) OUTPUT',
		@trained_model = @trainedModel OUTPUT;
END

GO

-- Give this a run just to make sure it works the way we expect it to.
DECLARE
	@trainedModel VARBINARY(MAX);

EXEC dbo.ExpenseReports_TrainModelML
	@language = N'Python',
	@modelType = N'RandomForestRegression',
	@trainedModel = @trainedModel OUTPUT;

PRINT(@trainedModel);

GO

CREATE OR ALTER PROCEDURE dbo.ExpenseReports_TrainModel(@language NVARCHAR(128),@modelType NVARCHAR(30))
AS
BEGIN
	DECLARE
		@trainedModel VARBINARY(MAX);

	EXEC dbo.ExpenseReports_TrainModelML
		@language = @language,
		@modelType = @modelType,
		@trainedModel = @trainedModel OUTPUT;

	INSERT INTO dbo.Model
	(
		ModelLanguage,
		ModelType,
		Model
	)
	VALUES
	(
		@language,
		@modelType,
		@trainedModel
	);
END
 
GO

-- Clear out any existing models.
TRUNCATE TABLE dbo.Model;

EXEC dbo.ExpenseReports_TrainModel
	@language = N'Python',
	@modelType = N'RandomForestRegression';
GO

SELECT
	ModelID,
	ModelLanguage,
	ModelType,
	Model,
	DATALENGTH(Model) AS ModelSize
	
FROM dbo.Model m;

