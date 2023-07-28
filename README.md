
# In Database Machine Learning Service through SQL Server

When we design the ML system,normaly we do data movement from the database for data transformation and model training purpose through the feature engineering pipeline.But it consumes more resources to create this data pipeline.Following image desribes entire process for this type of ML system.

![ML service in outside of database]("/Images/in_db.png")

Instead of this kind of design,we can do data transformations,model training and scoring inside the databse.Using the SQL server,It can be enabled this feature in our ML system.Then it is not required to build a feature engineering(data movement is not required) pipeline separately.Then entire process as follows.

![In database ML service]("E:\Projects-AI\Project-1\Images\in_db.png")

Using this design concept, I am going to solve following business problem.

## Business PROBLEM 

Our organization unraveled a case of expense report fraud among several employees.

Employees were allowed to submit expense reports of up to $40 without a receipt, but needed to include a receipt for everything above. Several employees began submitting fraudulent claims under that amount.

Management would like to know how much we believe employees took above and beyond the expected amounts.

To solve this problem,expenses amount of the person will be predited using the Randomforest rgression algorithm.In here no need to build data pipeline.But instead training and inference component should be build inside th database.SQL server "stored prcedure" has been used for creating those two pipeline inside th database.