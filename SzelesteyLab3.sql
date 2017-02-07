-- Clayton Szelestey, 2/7/17, Database Management, Lab 3 --
select ordnumber, totalusd
from orders;

select name, city
from agents
where name = 'Smith';

select pid, name, priceUSD
from products
where quantity > 200100;

select name, city
from customers
where city = 'Duluth';

select name
from agents
where city != 'New York' and city != 'Duluth';

select *
from products
where city != 'Dallas' and city != 'Duluth' and priceUSD >= 1;

select *
from orders
where month = 'Feb' or month = 'May';

select *
from orders
where month = 'Feb' and totalUSD >= 600;

select *
from orders
where cid = 'c005';