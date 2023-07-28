
import sqlmlutils

# Connect to the Database
conn = sqlmlutils.ConnectionInfo(server="RUWINI", database="ExpenseReports")

# Install libraries
sqlmlutils.SQLPackageManager(conn).install("pickle-mixin",upgrade = True)
