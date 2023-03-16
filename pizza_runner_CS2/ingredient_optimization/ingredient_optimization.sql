use PIZZA_RESTAURANT;
GO
-- C. Ingredient Optimisation
-- Function to return the ingredientName with ingredientId as input
create function dbo.getIngredientName(@ingredient_id int)
returns varchar(50)
as 
begin
    declare @ingredient_name varchar(50) = '';
    if @ingredient_id = 0
    begin
        set @ingredient_name = '';
    end
    else
    begin
        select @ingredient_name = topping_name
        from pizza_toppings
        where topping_id = @ingredient_id
    end
    return @ingredient_name;
end
GO

-- Function that takes in the ingredient_id as a comma separated value of integers and
-- returns their respective names in a comma delimited fasion. 
create function dbo.ingredientIdtoName(@ingredients_id_csv varchar(max))
returns varchar(max)
as 
begin
    declare @ingredient_names_csv varchar(max) = ''
    while len(@ingredients_id_csv) > 0
    begin
        declare @split_id int = 0;
        declare @first_comma_index int = charindex(',', @ingredients_id_csv)
        if @first_comma_index > 0
        begin
            set @split_id = left(@ingredients_id_csv, @first_comma_index - 1);
            set @ingredients_id_csv = stuff(@ingredients_id_csv, 1, @first_comma_index, '');
            set @ingredient_names_csv = @ingredient_names_csv + dbo.getIngredientName(@split_id) + ',';
        end
        else
        begin
            set @split_id = @ingredients_id_csv;
            set @ingredients_id_csv = '';
            set @ingredient_names_csv = @ingredient_names_csv + dbo.getIngredientName(@split_id);

        end
    end
    return @ingredient_names_csv
end
go

-- Function to concatenate all the inputs into a human readable format
create function dbo.readablePizzaOrder(@pizza_name varchar(20), @exclude_toppings varchar(20), @extra_toppings varchar(20))
returns varchar(100)
as
begin
    declare @pizza_order varchar(100);
    declare @exclude_tag varchar(20) = ' - Exclude ';
    declare @extra_tag varchar(20) = ' - Extra ';
    declare @exclusions varchar(20) = dbo.ingredientIdtoName(@exclude_toppings);
    declare @extras varchar(20) = dbo.ingredientIdtoName(@extra_toppings);
    if @exclusions = ''
    begin
        set @exclude_tag = '';
    end
    if @extras = ''
    begin
        set @extra_tag =  '';
    end
    set @pizza_order = concat(@pizza_name, @exclude_tag, @exclusions, @extra_tag, @extras)
    return @pizza_order
end
go

-- Function to return the pizza name by taking the pizza id as input.
create function dbo.getPizzaName(@pizza_id int)
returns varchar(20)
as
begin
    declare @pizza_name varchar(20)
    select @pizza_name = pizza_name
    from pizza_names
    where pizza_id = @pizza_id
    return @pizza_name
end
go