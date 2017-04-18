create or replace function PreReqsFor(int, REFCURSOR) returns refcursor as 
$$
declare
   course      int       := $1;
   resultset   REFCURSOR := $2;
begin
   open resultset for 
      select num, name
      from   courses
      where num in (
          select preReqNum
          from Prerequisites 
          where courseNum = course
       	  );
   return resultset;
end;
$$ 
language plpgsql;

select PreReqsFor(499, 'results');
Fetch all from results;

create or replace function IsPreReqFor(int, REFCURSOR) returns refcursor as 
$$
declare
   course      int       := $1;
   resultset   REFCURSOR := $2;
begin
   open resultset for 
      select num, name
      from   courses
      where num in (
          select courseNum
          from Prerequisites 
          where preReqNum = course
       	  );
   return resultset;
end;
$$ 
language plpgsql;

select IsPreReqFor(120, 'esults');
Fetch all from esults;