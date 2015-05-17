/* Kitchen Sink using Dynamic SQL correctly avoiding Plan Cache bloat. */

-- Chaotic do-it-all procedure using dynamic SQL correctly
create procedure dbo.KitchenSinkUsingGoodDynamicSql
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
		from Sales.SalesOrderHeader where 1 = 1 '; -- returns all rows

	set @sql += case when @CustomerID is not null
		then N' and CustomerID = @CustomerID' else '' end
	  + case when @OrderDate is not null 
	   	then N' and OrderDate = @OrderDate' else '' end
	  + case when @ShipDate is not null 
	   	then N' and ShipDate = @ShipDate' else '' end
	  + case when @Status is not null 
	   	then N' and [Status] = @Status' else '' end
	  -- and other params ---;

	-- set @sql += N' option (recompile)';

	exec sp_executesql @sql,
		N'@CustomerID int, @OrderDate date, @ShipDate date, @Status tinyint',
		@CustomerID, @OrderDate, @ShipDate, @Status;
end
go

/* sp_executesql promotes better plan reuse and encourages strongly typed parameters
   instead of building up a massive sql string like exec(@sql)  */