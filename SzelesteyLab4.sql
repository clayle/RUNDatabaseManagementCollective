-- Clayton Szelestey, 2/14/17, Database Management, Lab 4 --
select distinct city 
from agents 
where aid in(
      select aid  
      from orders
      where cid = 'c006');
       
select distinct pid 
from orders 
where aid in(
      select aid 
      from orders
      where cid in(
            select cid 
            from customers
            where city = 'Kyoto'))
order by pid DESC;    

select cid, name
from customers
where cid not in(
      select cid
      from orders 
      where aid = 'a01' );
      
select cid
from customers
where cid in(
      select cid
      from orders
      where pid = 'p01')
      and cid in(
      select cid
      from orders
      where pid = 'p07');

select distinct pid
from products
where pid not in(
      select pid
      from orders
      where cid in (
            select cid
            from orders
            where aid = 'a08'))
order by pid DESC;

select name, city, discount
from customers
where cid in(
      select cid
      from orders
      where aid in(
            select aid
            from agents
            where city in ('Tokyo', 'New York')));
            
select *
from customers
where discount in(
      select discount
      from customers
      where city in ('Duluth', 'London'));
      
/* A check constraint is used to limit the range of values that can be put into a column. They allow you to limit the chance that your database accepts incorrect/impossible data. For
example, the price of a product cannot be negative, so you might make a check constraint that limits that column to only positive numbers. An example of a bad check constraint would be 
limiting an age column to only 2 digit numbers, as while it is unlikely, it is possible for someone to be over 99 years old. */