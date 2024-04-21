use pizza_hub;

create table [orders](
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id)
);

BULK INSERT dbo.orders
FROM 'C:\Users\NCC\Desktop\pizza_sales\orders.csv'
WITH (
    FIELDTERMINATOR = ',',  -- Specify the delimiter used in your CSV file
    ROWTERMINATOR = '\n',   -- Specify the row terminator used in your CSV file
    FIRSTROW = 2            -- Specify the row number to start importing (if there's a header row)
);

create table orders_details(
order_detail_id int  primary key not null,
order_id int not null,
pizza_id text not null,
quantity int not null
);

bulk insert orders_details
from 'C:\Users\NCC\Desktop\pizza_sales\order_details.csv'
with (
 fieldterminator = ',',
 rowterminator = '\n',
 firstrow = 2
 );


 --Retrieve the total number of orders placed.

 select count(*) as totalOrder from orders;
 select count(order_id) as totalOrder from orders;

 --Calculate the total revenue generated from pizza sales.

 select round(sum(orders_details.quantity * pizzas.price),2) as totalRevenue
 from orders_details inner join pizzas
 on orders_details.pizza_id = pizzas.pizza_id;

 -- alter table pizzas
 --alter column pizza_id varchar(50) not null;
 -- alter table orders_details 
 --alter column pizza_id varchar(50) not null;
 --select * from orders_details;
 -- select * from pizzas;
 -- select * from  orders_details
 --  inner join pizzas
 -- on orders_details.pizza_id= pizzas.pizza_id;

 --Identify the highest-priced pizza.

select  pizza_types.name, pizzas.price from 
pizza_types inner join pizzas 
on pizzas.pizza_type_id = pizza_types.pizza_type_id
where pizzas.price=(select  max(pizzas.price) from pizzas);

--Identify the most common pizza size ordered.

select pizzas.size, COUNT(orders_details.order_detail_id) as orderCount from  orders_details inner join pizzas
	on orders_details.pizza_id = pizzas.pizza_id
	group by size order by orderCount desc;

--select quantity , COUNT(order_detail_id) as orders
--from orders_details
--group by quantity 
--order by orders_details.quantity; 

--List the top 5 most ordered pizza types along with their quantities.

select top 5 pizza_types.name, sum(orders_details.quantity) 
as countedQuantity from orders_details 
inner join pizzas
on pizzas.pizza_id = orders_details.pizza_id
inner join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by name order by countedQuantity desc;

--Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, sum(orders_details.quantity) as pizzaCategoryOrdered from orders_details 
inner join pizzas
on pizzas.pizza_id = orders_details.pizza_id
inner join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category order by pizzaCategoryOrdered desc;

--Determine the distribution of orders by hour of the day.

select datepart(hour, order_time) as Hrs, 
count(order_id) as [orders] from orders
group by datepart(hour, order_time) order by [orders] desc;

--Join relevant tables to find the category-wise distribution of pizzas.
select category ,count(name) as typed from pizza_types group by category;
--select category ,count(pizza_type_id ) as typed from pizza_types group by category;

--Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(ordered),1) as [average/day] from 
(select order_date, sum(quantity) as ordered
from orders inner join orders_details 
on orders.order_id=orders_details.order_id
group by order_date) as dateBassedQuantity;

--Determine the top 3 most ordered pizza types based on revenue.

select top 3 name, sum(price*quantity) as revenues from  pizza_types
inner join pizzas
on pizza_types.pizza_type_id =pizzas.pizza_type_id
inner join orders_details
on pizzas.pizza_id=orders_details.pizza_id
group by name order by revenues desc;

--Calculate the percentage contribution of each pizza type to total revenue.

select category, round(sum(quantity * price) 
/ (select sum(quantity * price) as totalRevenue 
from orders_details
inner join pizzas
on pizzas.pizza_id=orders_details.pizza_id) *
100,1) as revenue from pizzas
inner join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
inner join orders_details
on orders_details.pizza_id= pizzas.pizza_id
group by category order by revenue desc;


--Analyze the cumulative revenue generated over time.

  select order_date,  sales,
  sum(sales) over(order by order_date) as cumulativeRevenue 
  from (
select  order_date, 
sum(quantity* price) as sales from orders_details
inner join  orders
on orders_details.order_id = orders.order_id
inner join pizzas
on pizzas.pizza_id = orders_details.pizza_id
group by order_date) as salesByDate;


--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with pizzaSaling as (
select category, name, revenue_basedOn_categoryName,
RANk() over(partition by category order by revenue_basedOn_categoryName desc) as ranking
from
(select category, name ,
sum(quantity *price) as revenue_basedOn_categoryName
from orders_details
inner join pizzas
on orders_details.pizza_id = pizzas.pizza_id
inner join pizza_types
on pizza_types.pizza_type_id =pizzas.pizza_type_id
group by category, name) as details
)
select  category, name, revenue_basedOn_categoryName from pizzaSaling
where ranking <= 3;



















  

  

 







