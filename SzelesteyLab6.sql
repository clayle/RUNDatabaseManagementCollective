-- Clayton Szelestey, 2/28/17, Database Management, Lab 6 --
select c.name, c.city
from customers c
where c.city in (
	  select p.city
	  from products p
	  group by p.city
	  order by count(*) DESC
	  limit 1
);

select p.name
from products p
where p.priceUSD > (
      select AVG(p.priceUSD)
      from products p)
order by p.name DESC;

select c.name, o.pid, o.totalUSD
from customers c, orders o
where c.cid = o.cid
order by o.totalUSD ASC;

select c.name, coalesce(sum(o.qty), 0) as "total ordered"
from orders o
right outer join customers c on o.cid = c.cid
group by c.name
order by c.name ASC;

select c.name, p.name, a.name
from orders o
inner join customers c on o.cid = c.cid
inner join products p on o.pid = p.pid
inner join agents a on o.aid = a.aid
where a.city = 'Newark';

select *
from (
      select o.*, o.qty*p.priceUSD*(1-(c.discount/100)) as realUSD
      from orders o
      inner join products p on o.pid = p.pid
      inner join customers c on o.cid = c.cid) as foo
where totalUSD != realUSD;

/* The difference between a left outer join and a right outer join is which table will be displayed
in its entirety. A left outer join will display the entire left table and the corresponding parts from
the right table even if the parts in the right table are null. It is the opposite for a right outer 
join. A right outer join will display the entire right table and the corresponding parts from the left
table even if the parts in the left table are null. See below for an example of each. */

select *
from orders o
left outer join customers c on c.cid = o.cid;

select *
from orders o
right outer join customers c on c.cid = o.cid;

/* Notice how in the second query there is an empty section. This is because there is a customer
who never actually placed an order */ 