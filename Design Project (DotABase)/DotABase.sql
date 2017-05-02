-- Clayton Szelestey
-- 5/2/17
-- Design Project
-- DotABase
CREATE ROLE dev;
GRANT ALL ON ALL TABLES IN SCHEMA public TO dev;

CREATE ROLE player;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM player;

CREATE TABLE Items(
	IID int not null unique,
	ItemName text not null,
	IsConsumable bool not null,
    ItemCost int not null,
	PRIMARY KEY(IID)
);

CREATE TABLE Stats(
	IID int not null unique references Items(IID),
	Intelligence int,
    Strength int,
    Agility int,
    Evasion int,
    Attack_Speed int,
    Damage int,
    HP int,
    Mana int,
    HP_Regen int,
    Mana_Regen int,
    Armor int,
    Movement_Speed int,
    Magic_Resist int,
	PRIMARY KEY(IID)
);

CREATE TABLE Stats_Static_or_Percentage(
	IID int not null unique references Stats(IID),
	Intelligence_SOP bool,
    Strength_SOP bool,
    Agility_SOP bool,
    Evasion_SOP bool,
    Attack_Speed_SOP bool,
    Damage_SOP bool,
    HP_SOP bool,
    Mana_SOP bool,
    HP_Regen_SOP bool,
    Mana_Regen_SOP bool,
    Armor_SOP bool,
    Movement_Speed_SOP bool,
    Magic_Resist_SOP bool,
	PRIMARY KEY(IID)
);

CREATE TABLE Passives(
	IID int not null unique references Items(IID),
	Passive_Desc text not null,
    Is_Aura bool not null,
	PRIMARY KEY(IID)
);

CREATE TABLE Cooldowns(
	IID int not null unique references Items(IID),
	Timer int not null,
	PRIMARY KEY(IID)
);

CREATE TABLE Actives(
	IID int not null unique references Items(IID),
	Active_Desc text not null,
    Is_Toggle bool not null,
    Mana_Cost int,
	PRIMARY KEY(IID)
);

CREATE TABLE Charges(
	IID int not null unique references Items(IID),
	Num_of_Charges int not null,
    Is_Refillable bool not null,
	PRIMARY KEY(IID)
);

CREATE TABLE Upgrades(
	IID int not null references Items(IID),
	RequiredID int not null references Items(IID),
    Num_Required int not null,
	PRIMARY KEY(IID, RequiredID)
);

CREATE TABLE Shop(
	SID int not null unique,
    Shop_Name text not null,
	PRIMARY KEY(SID)
);

CREATE TABLE Basics(
	IID int not null references Items(IID),
	SID int not null references Shop(SID),
	PRIMARY KEY(IID, SID)
);

create trigger priceWarning
BEFORE INSERT OR UPDATE ON Items
	FOR EACH ROW EXECUTE PROCEDURE priceChange();

create trigger priceWarningDown
BEFORE INSERT OR UPDATE ON Items
	FOR EACH ROW EXECUTE PROCEDURE priceChangeDown();

create or replace function Required(int) returns TABLE(item text, num int, idd int) as 
$$
declare
   searchIID   int       := $1;
begin
   return QUERY
   select 
       Items.ItemName,
       Upgrades.Num_Required,
       Items.IID
   from Items join Upgrades on Upgrades.RequiredID = Items.IID
   where Upgrades.IID = searchIID;
end;
$$ 
language plpgsql;

create or replace function RequiredFor(int) returns TABLE(item text, idd int) as 
$$
declare
   searchIID   int       := $1;
begin
   return QUERY
   select 
       Items.ItemName,
       Items.IID
   from Items join Upgrades on Upgrades.IID = Items.IID
   where Upgrades.RequiredID = searchIID;
end;
$$ 
language plpgsql;

create or replace function componentPrice(int) returns TABLE(num int) as 
$$
declare
   searchIID   int       := $1;
begin
   return QUERY
   select 
       Items.ItemCost * Upgrades.Num_Required
   from Items join Upgrades on Upgrades.RequiredID = Items.IID
   where Upgrades.IID = searchIID;
end;
$$ 
language plpgsql;

create or replace function findLocation(int) returns TABLE (Shop_Name text) as 
$$
declare
   searchIID   int       := $1;
begin
   return QUERY
   select Shop.Shop_Name
   from Shop
   where SID in (
       select SID
	   from Basics
	   where IID = searchIID
	);
end;
$$ 
language plpgsql;

create or replace function ItemFunc(int) returns TABLE (Item_Name text, Passive text, Active text) as 
$$
declare
   searchIID   int       := $1;
begin
   return QUERY
   select Items.ItemName,
          case when Exists(Select Passives.IID from Passives where Passives.IID = Items.IID) then (select Passives.Passive_Desc from passives where Passives.IID = Items.IID)
          else null end as Passive,
          case when Exists(Select Actives.IID from Actives where Actives.IID = Items.IID) then (select Actives.Active_Desc from Actives where Actives.IID = Items.IID)
          else null end as Active
       
   from Items
   where Items.IID = searchIID;
end;
$$ 
language plpgsql;

Create or Replace View UpgradableItems AS
	select ItemName
    from Items
    Where IID in(
        select IID 
        from Upgrades);
        
Create or Replace View BasicItems AS
	select ItemName
    from Items
    Where IID in(
        select IID 
        from Basics);
        
CREATE OR REPLACE FUNCTION priceChange()
RETURNS TRIGGER AS
$$
DECLARE
    affectedID	   int;
BEGIN
	IF new.ItemCost != Items.ItemCost from Items where IID = new.IID AND (EXISTS(select idd from RequiredFor(new.IID))) THEN
        
    RAISE NOTICE 'Updating item % affects cost of an Upgrade Item',
    	new.IID;
	 
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION priceChangeDown()
RETURNS TRIGGER AS
$$
DECLARE
    affectedID	   int;
BEGIN
	IF new.ItemCost != Items.ItemCost from Items where IID = new.IID AND (EXISTS(select idd from Required(new.IID))) THEN
     
    RAISE NOTICE 'Updating item % affects cost of a Basic Item',
    	new.IID;
	 
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;





Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (1, 'Dragon Lance', false, 1900);
Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (2, 'Band of Elvinskin', false, 450);
Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (3, 'Ogre Club', false, 1000);
Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (4, 'Belt of Strength', false, 450);
Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (5, 'Blade of Alacrity', false, 1000);
Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (6, 'Yasha Recipe', false, 600);
Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (7, 'Yasha', false, 2050);
Insert Into Upgrades (IID, RequiredID, Num_Required)
Values (1, 2, 2);
Insert Into Upgrades (IID, RequiredID, Num_Required)
Values (1, 3, 1);
Insert Into Upgrades (IID, RequiredID, Num_Required)
Values (7, 2, 1);
Insert Into Upgrades (IID, RequiredID, Num_Required)
Values (7, 5, 1);
Insert Into Upgrades (IID, RequiredID, Num_Required)
Values (7, 6, 1);
Insert Into Shop(SID, Shop_Name)
Values (1, 'Home Shop');
Insert Into Shop(SID, Shop_Name)
Values (2, 'Side Shop');
Insert Into Shop(SID, Shop_Name)
Values (3, 'Secret Shop');
Insert Into Basics(IID, SID)
Values (2, 1);
Insert Into Basics(IID, SID)
Values (2, 2);
Insert Into Basics(IID, SID)
Values (3, 1);
Insert Into Basics(IID, SID)
Values (4, 1);
Insert Into Basics(IID, SID)
Values (4, 2);
Insert Into Basics(IID, SID)
Values (5, 1);
Insert Into Basics(IID, SID)
Values (6,1);
Insert Into Stats(IID, Agility)
Values(2, 6);
Insert Into Stats(IID, Strength)
Values(3, 10);
Insert Into Stats(IID, Strength)
Values(4, 6);
Insert Into Stats(IID, Agility, Strength)
Values(1, 12, 12);
Insert Into Stats(IID, Agility)
Values(5, 10);
Insert Into Stats(IID, Agility, Attack_Speed, Movement_Speed)
Values(7, 16, 15, 8);
Insert Into Stats_Static_or_Percentage(IID, Agility_SOP)
Values(2, true);
Insert Into Stats_Static_or_Percentage(IID, Strength_SOP)
Values(3, true);
Insert Into Stats_Static_or_Percentage(IID, Strength_SOP)
Values(4, true);
Insert Into Stats_Static_or_Percentage(IID, Agility_SOP, Strength_SOP)
Values(1, true, true);
Insert Into Stats_Static_or_Percentage(IID, Agility_SOP)
Values(5, true);
Insert Into Stats_Static_or_Percentage(IID, Agility_SOP, Attack_Speed_SOP, Movement_Speed_SOP)
Values(7, true, true, false);

Insert Into Passives(IID, Passive_Desc, Is_Aura)
Values(1, 'Increases Attack Range By 140', false);
Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (8, 'Robe of the Magi', false, 450);
Insert Into Basics(IID, SID)
Values (8, 1);
Insert Into Basics(IID, SID)
Values (8, 2);
Insert Into Stats(IID, Intelligence)
Values(8, 6);
Insert Into Stats_Static_or_Percentage(IID, Intelligence_SOP)
Values(8, true);

Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (9, 'Boots of Speed', false, 400);
Insert Into Basics(IID, SID)
Values (9, 1);
Insert Into Basics(IID, SID)
Values (9, 2);
Insert Into Stats(IID, Movement_Speed)
Values(9, 45);
Insert Into Stats_Static_or_Percentage(IID, Movement_Speed_SOP)
Values(9, true);

Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (10, 'Gloves of Haste', false, 500);
Insert Into Basics(IID, SID)
Values (10, 1);
Insert Into Basics(IID, SID)
Values (10, 2);
Insert Into Stats(IID, Attack_Speed)
Values(10, 20);
Insert Into Stats_Static_or_Percentage(IID, Attack_Speed_SOP)
Values(10, true);

Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (11, 'Power Treads', false, 500);
Insert Into Upgrades (IID, RequiredID, Num_Required)
Values (11, 10, 1);
Insert Into Upgrades (IID, RequiredID, Num_Required)
Values (11, 2, 1);
Insert Into Upgrades (IID, RequiredID, Num_Required)
Values (11, 9, 1);
Insert Into Stats(IID, Attack_Speed, Movement_Speed)
Values(11, 25, 45);
Insert Into Stats_Static_or_Percentage(IID, Attack_Speed_SOP, Movement_Speed_SOP)
Values(11, true, true);
Insert Into Actives(IID, Active_Desc, Is_Toggle, Mana_Cost)
Values(11, 'Switch Attribute', true, 0);

Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (12, 'Blades of Attack', false, 420);
Insert Into Basics(IID, SID)
Values (12, 1);
Insert Into Basics(IID, SID)
Values (12, 2);
Insert Into Stats(IID, Damage)
Values(12, 9);
Insert Into Stats_Static_or_Percentage(IID, Damage_SOP)
Values(12, true);

Insert Into Items (IID, ItemName, IsConsumable, ItemCost)
Values (13, 'Phase Boots', false, 1240);
Insert Into Upgrades (IID, RequiredID, Num_Required)
Values (13, 9, 1);
Insert Into Upgrades (IID, RequiredID, Num_Required)
Values (13, 12, 2);
Insert Into Stats(IID, Damage, Movement_Speed)
Values(13, 24, 45);
Insert Into Stats_Static_or_Percentage(IID, Damage_SOP, Movement_Speed_SOP)
Values(13, true, true);
Insert Into Actives(IID, Active_Desc, Is_Toggle, Mana_Cost)
Values(13, 'Phase', false, 0);
Insert Into Cooldowns(IID, Timer)
Values(13, 8);


Select *
from Required(1);

Select *
from findLocation(2);

Select *
from findLocation(3);

Select *
from UpgradableItems;

Select *
from BasicItems;

Select *
from ItemFunc(1);
                             
Select *
from componentPrice(1);
        
Select *
from RequiredFor(3);

Update Items
Set ItemCost = 450
where IID = 2;

Select ItemName, ItemCost
from Items
Order By ItemCost DESC;

Select ItemName, Count(Num_Required) as Uses
from Items, Upgrades
Where Items.IID = Upgrades.RequiredID
Group By ItemName
Order By Uses DESC;