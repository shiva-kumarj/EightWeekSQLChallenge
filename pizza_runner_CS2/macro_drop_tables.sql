select @@SERVERNAME as server_name, DB_NAME() as db_name;

use PIZZA_RESTAURANT;
go

if object_id('tempdb..#dropTablesFunction') is not NULL
    drop table #dropTablesFunction

create table #dropTablesFunction
(
    enabled bit
);

insert into #dropTablesFunction
    (enabled)
values(1);

go

if exists (select *
from sys.objects
where object_id = OBJECT_ID(N'dbo.toggleDropTables'))
begin
    drop procedure dbo.toggleDropTables;
end
go

create procedure dbo.toggleDropTables(@enable bit)
as
begin
    update #dropTablesFunction set enabled = @enable
end
go

if exists (select 1 from #dropTablesFunction where enabled = 1)
begin
    DROP TABLE [dbo].[unique_recipes]
    DROP TABLE [dbo].[extra_toppings]
    DROP TABLE [dbo].[common_exclusions]
end
GO

select * from #dropTablesFunction;
exec dbo.toggleDropTables 0;