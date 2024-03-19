-- Create the continent table
CREATE TABLE continent (
    continent_id SERIAL PRIMARY KEY,
    continent_name VARCHAR(100)
);

-- Insert dummy values into the continent table
INSERT INTO continent (continent_name) VALUES
    ('North America'),
    ('Europe'),
    ('Asia'),
    ('Africa'),
    ('South America'),
    ('Oceania');


-- Create the country table with the area column
CREATE TABLE country (
    country_id SERIAL PRIMARY KEY,
    code CHAR(2) UNIQUE,
    country_name VARCHAR(100),
    capital_city VARCHAR(100),
    population INT,
    area DECIMAL(10, 2), -- Add the area column
    continent_id INT,
    FOREIGN KEY (continent_id) REFERENCES continent(continent_id)
);

-- Insert dummy values into the country table
INSERT INTO country (code, country_name, capital_city, population, area, continent_id) VALUES
    ('US', 'United States', 'Washington D.C.', 328200000, 9833510.00, 1),   -- North America
    ('CA', 'Canada', 'Ottawa', 37742154, 9976140.00, 1),                    -- North America
    ('GB', 'United Kingdom', 'London', 67886011, 242495.00, 2),             -- Europe
    ('FR', 'France', 'Paris', 65273511, 551695.00, 2),                      -- Europe
    ('JP', 'Japan', 'Tokyo', 126500000, 377975.00, 3),                      -- Asia
    ('CN', 'China', 'Beijing', 1439323776, 9596960.00, 3),                  -- Asia
    ('NG', 'Nigeria', 'Abuja', 206139589, 923768.00, 4),                    -- Africa
    ('ZA', 'South Africa', 'Pretoria', 59308690, 1221037.00, 4),            -- Africa
    ('BR', 'Brazil', 'Brasília', 212559417, 8515767.00, 5),                 -- South America
    ('AR', 'Argentina', 'Buenos Aires', 45195777, 2780400.00, 5),           -- South America
    ('AU', 'Australia', 'Canberra', 25788202, 7692024.00, 6),               -- Oceania
    ('NZ', 'New Zealand', 'Wellington', 4822233, 270467.00, 6);             -- Oceania


-- Create the person table
CREATE TABLE person (
    person_id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

-- Insert dummy values into the person table
INSERT INTO person (name) VALUES
    ('John Doe'),         -- United States
    ('Jane Smith'),       -- France
    ('Bob Johnson'),      -- Brazil
    ('Emily Brown'),      -- Japan
    ('Michael Davis'),   -- Argentina
    ('Sophia Wilson'),    -- Nigeria
    ('William Miller'),   -- South Africa
    ('Olivia Taylor'),   -- New Zealand
    ('James Jones'),      -- Canada
    ('Emma Brown'),       -- China
    ('Liam Wilson'),     -- Australia
    ('Ava Taylor'),       -- Japan
    ('Pratik Kumar'),   -- No citizenship
    ('Pratik Kumar');   -- No citizenship

-- Create the citizenship table
CREATE TABLE citizenship (
    citizenship_id SERIAL PRIMARY KEY,
    person_id INT,
    country_id INT,
    FOREIGN KEY (person_id) REFERENCES person(person_id),
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

-- Insert dummy values into the citizenship table
INSERT INTO citizenship (person_id, country_id) VALUES
    (1, 1),   -- John Doe is a citizen of the United States
    (2, 4),   -- Jane Smith is a citizen of France
    (3, 9),   -- Bob Johnson is a citizen of Brazil
    (4, 3),   -- Emily Brown is a citizen of Japan
    (5, 10),  -- Michael Davis is a citizen of Argentina
    (6, 7),   -- Sophia Wilson is a citizen of Nigeria
    (7, 8),   -- William Miller is a citizen of South Africa
    (8, 12),  -- Olivia Taylor is a citizen of New Zealand
    (9, 2),   -- James Jones is a citizen of Canada
    (10, 5),  -- Emma Brown is a citizen of China
    (11, 11), -- Liam Wilson is a citizen of Australia
    (12, 4),  -- Ava Taylor is also a citizen of France
    (1, 4);   -- John Doe is a citizen of the France

--Write SQL queries to find the following data about countries:


--Country with the biggest population (id and name of the country)

select country_id, country_name from country where population = (select MAX(population) from country);

-- Top 10 countries with the lowest population density (names of the countries)

select country_name from country order by population asc limit 10;

-- Countries with population density higher than average across all countries

select * from country where population > (select AVG(population) from country);

-- Country with the longest name (if several countries have name of the same length, show all of them)

select *, length(country_name) as name_length from country where length(country_name) = (select max(length(country_name)) from country);

-- All countries with name containing letter “F”, sorted in alphabetical order

select * from country where country_name like '%F%' order by country_name asc;

-- Country which has a population, closest to the average population of all countries

SELECT *
FROM country
WHERE abs(population - (SELECT avg(population) FROM country)) = 
      (SELECT min(abs(population - (SELECT avg(population) FROM country))) FROM country);

-- Write SQL queries to find the following data about countries and continents:


-- Count of countries for each continent

SELECT COUNT(country.country_id) AS country_count, continent.continent_name 
FROM country 
INNER JOIN continent ON country.continent_id = continent.continent_id 
GROUP BY continent.continent_name;

-- Total area for each continent (print continent name and total area), sorted by area from biggest to smallest

select sum(country.area) as "total area", continent.continent_name from country inner join continent on country.continent_id = continent.continent_id group by continent.continent_id order by sum(country.area);

-- Average population density per continent

select avg(country.population) as "average population", continent.continent_name from country inner join continent on country.continent_id = continent.continent_id group by continent.continent_name order by avg(country.population);

-- For each continent, find a country with the smallest area (print continent name, country name and area)

select subquery.min_area, subquery.continent_name, country.country_name from 
	(select min(country.area) as "min_area", continent.continent_name, continent.continent_id from country 
		inner join 
		continent on country.continent_id = continent.continent_id 
		group by continent.continent_id) as subquery 
inner join country on subquery.continent_id = country.continent_id
where subquery.min_area = country.area;


-- Find all continents, which have average country population less than 90000000

select avg(country.population) as "average population", continent.continent_name from country inner join continent on country.continent_id = continent.continent_id group by continent.continent_id having avg(country.population) < 90000000 order by avg(country.population);


-- Write SQL queries to find the following data about people

-- Person with the biggest number of citizenships

select count(person.person_id) as "total_citizenships", person.person_id from citizenship inner join person on person.person_id = citizenship.person_id group by person.person_id order by count(person.person_id) desc limit 1;

-- All people who have no citizenship

select  person.person_id, person.name from citizenship right join person on person.person_id = citizenship.person_id where citizenship.citizenship_id is null;

-- Country with the least people in People table

select count(country.country_id) as "people", country.country_name from country inner join citizenship on country.country_id = citizenship.country_id group by country.country_id order by count(country.country_id) limit 1;

-- Continent with the most people in People table

select count(country.country_id) as "people", country.country_name from country inner join citizenship on country.country_id = citizenship.country_id group by country.country_id order by count(country.country_id) desc limit 1;

-- Find pairs of people with the same name - print 2 ids and the name

select p1.*, p2.* from person as p1, person p2 where p1.person_id != p2.person_id and p1.name = p2.name and p1.person_id <= p2.person_id;

