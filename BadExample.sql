/* Builds a huge WHERE clause with a bunch of optional parameters and OR statements.
Each OR statement checks if the parameter is NULL then use that parameter.
All the OR statements are then combined using AND resulting in one gigantic WHERE clause!

Depending on what parameters are used the first time the stored procedure is used, it will
compile a plan optimized for those parameters (and parameter values) and the sproc will use that plan for 
subsequent calls. That's because SQL Server will only see all the parameters and the same SQL statement.
It doesn't matter that those parameter values can be all optional and passing in NULL values.

This is obviously not good, because if say we first searched with first and last names and we have a plan
that uses indexes on those columns, it will use the same plan when seraching next time for another parameter set!
All kinds of things can go wrong with this. If the next search parameter has a good index, it may not get used
because the first plan used a clustered index scan because because a previously run parameter didn't have any index. 

To try to mitigate this, we can use RECOMPILE to generate a new plan for each call to the stored procedure.
But that's not optimal because it becomes more and more costly as the number of parameters increases.
Moreover it can lead to massive Plan pollution if the stored procedure is called very frequently.
Bloated Plan Cache pollution can often times bring a SQL Server down to its knees.

The best option is to use Dynamic SQL notwithstanding the fact that we lose intellisense, not easy to read etc.
Many people think because it is dynamic SQL, it will have poor performance, it won't be cached, it won't be
parameterized and there will be SQL injection issues. But these are all just assumptions.

Dynamic SQL is just another ad hoc SQL and will be compiled and cached and reused as long as the text in the statement
stays the same. The caveat is if you use dynamic SQL incorrectly and have a different plan in the Plan cache for every 
combination of the optional parameters that can cause massive plan cache pollution. 
Using the Optimize for Ad hoc Workload setting can offset any plan cache bloat with dynamic SQL, but the answer
really is writing the dynamic SQL correctly so we don't pollute the Plan cache.

*/

-- Chaotic do-it-all procedure without using dynamic SQL
create procedure dbo.KitchenSink
	@CustomerID 	int = NULL,
	@OrderDate		date = NULL,
	@ShipDate		date = NULL,
	@Status			tinyint = NULL,
	-- other parameters --

as
begin
	set nocount on;

	select SalesOrderID,
	       -- Other Columns ---
	     from Sales.SalesOrderHeader
	     where CustomerID = coalesce(@CustomerID, CustomerID)
	     	and OrderDate = coalesce(@OrderDate, OrderDate)
	     	and (ShipDate = @ShipDate OR @ShipDate IS NULL)  -- nullable column
	     	and [Status] = coalesce(@Status, [Status])
	     	-- AND other conditional clauses ---

end

/* Note that if the nullability of any of the column changes, then we will get incorrect results
from this stored procedure if we don't update it here, otherwise becomes column = NULL producing 
incorrect results!
*/