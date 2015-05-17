/* Kitchen Sink using Dynamic SQL incorrectly causing Plan Cache bloat. 
   This is not parameterizing any of these values, just concatenating strings.
   Vulnerable to Sql Injection as well. 
   * Note that table names and column names cannot be parameterized, but we should
   parameterize these other input values. */

-- Chaotic do-it-all procedure using dynamic SQL incorrectly
create procedure dbo.KitchenSinkUsingBadDynamicSql
	@CustomerID 	int = NULL,
	@OrderDate		date = NULL,
	@ShipDate		date = NULL,
	@Status			tinyint = NULL,
	-- other parameters --

as
begin
	set nocount on;

	declare @sql nvarchar(max) = N'select SalesOrderID
		-- other columns --
		from Sales.SalesOrderHeader where 1 = 1 ';

	if @CustomerID is not null
		set @sql += N' and CustomerID = ' + convert(varchar(10), @CustomerID);

	if @OrderDate is not null
		set @sql += N' and OrderDate = ''' + convert(char(8), @OrderDate, 112) + '''';

	if @ShipDate is not null
		set @sql += N' and ShipDate = ''' + convert(char(8), @ShipDate, 112) + '''';

	if @Status is not null
		set @sql += N' and [Status] = ' + convert(varchar(2), @Status);

	-- Other columns --

	-- if we had a string field (single ' values in the data), it becomes even more ugly
	-- += N' and LastName = N''' + replace(@LastName, '''', '''''') + '''';

	exec(@sql);
end
go
