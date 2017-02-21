-- Clayton Szelestey, 2/21/17, Database Management, Lab 5 --
select a.city
from agents a inner join orders o on a.aid = o.aid
where o.cid = 'c006';
                
select distinct p.pid
from orders o full outer join orders p on o.aid = p.aid, customers c
where c.cid = o.cid and c.city = 'Kyoto' 
order by p.pid ASC;
                
select name
from customers
where not cid in(
      select cid
      from orders);
    
select c.name
from customers c full outer join orders o on o.cid = c.cid
where o.cid is null;

select distinct c.name, a.name
from customers c, agents a, orders o
where c.city = a.city 
	  and c.cid = o.cid 
	  and o.aid = a.aid;

select c.name , a.name , c.city
from customers c, agents a
where c.city = a.city;

select c.name, c.city
from customers c
where c.city in (
	  select p.city
	  from products p
	  group by p.city
	  order by count(*) ASC
	  limit 1
);