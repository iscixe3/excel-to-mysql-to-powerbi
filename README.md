# excel-to-mysql-to-powerbi
from excel loaded to mysql then to powerbi

Original data set is from 
' https://github.com/kahethu/hr_data/tree/main '

Tweak some queries like 
1.) instead of using subquery, used CTE tables
2.) Clean the data and changing the data type for dates. As compared to mssql, mysql can't read the date from excel
