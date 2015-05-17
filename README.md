# The-SQL-KitchenSink-StoredProcedure
Describes the typical Do-it-all Stored procedure with multiple optional parameters used to satisfy all sorts of search criteria. This has serious performance issues and there are ways to mitigate it. The following code samples illustrates a bad example and how to best address these issues.


SQL 2008 and higher - Highly recommended to use "Optimize for Adhoc Workload" setting if it is an OLTP database
Dynamic SQL is the best tool for this scenario
Another option could be to use RECOMPILE hint, but then you pay compile cost every time the stored procedure is run
