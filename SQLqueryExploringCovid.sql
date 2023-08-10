
SELECT 
* FROM Project.dbo.CovidDeaths
order by 3,4

SELECT 
* FROM Project.dbo.CovidVaccinations
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project.dbo.CovidDeaths
order by 1,2

--Relationship between total cases and total deaths
--Allows us to understand the chances of dying to Covid in whatever country
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPERCENTAGE
FROM Project.dbo.CovidDeaths
WHERE location like '%kingdom%' --United Kingdom is the location that interests me
order by 1,2

--I altered two columns below because the data types they previously had did not let me divide then multiply by 100, preventing me from finding the odds of dying to Covid in certain countries
ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_deaths BIGINT

ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_cases BIGINT

--Relationship between population and Covid cases
--Shows us the percentage of population who has/had Covid
SELECT Location, date, total_cases,population, (total_cases/population)*100 as CovidInfectedPERCENTAGE
FROM Project.dbo.CovidDeaths
WHERE location like '%kingdom%'
order by 1,2

--Gives me a table where i can see every locations number of cases and it puts the location with the highest numbers at the top of the grid
SELECT Location, MAX(total_cases) as InfectionSum
FROM Project.dbo.CovidDeaths
Group By location
order by InfectionSum desc

--Shows countries and continents that suffered the most casualties from Covid
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeaths
FROM Project..CovidDeaths
Group By Location
Order By TotalDeaths desc 
--This dataset is from WHO. when running this query it told me that there has been a total of 6,950,642 deaths and the WHO website says there are 6,951,677 deaths
--Roughly the same results. Indicates that this dataset is accurate#

--Same query that is above but only if i wanted continents 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths
FROM Project..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeaths desc 

-- Creating a view so i can get back to the results of this query easier.
Create View ContinentDeaths as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths
FROM Project..CovidDeaths
Where continent is not null
Group By continent
 
SELECT * FROM ContinentDeaths

--This next query will allow me to see how many covid cases and deaths were confirmed each day from the start of Covid pandemic to current day.
SELECT date, SUM(new_cases), SUM(new_deaths) 
From Project..CovidDeaths
Where continent is not null
Group by date
order by 1

SELECT  SUM(new_cases), SUM(new_deaths) 
From Project..CovidDeaths
Where continent is not null
order by 1

--Moving on to my other table. This table is focused on Covid vaccines.
--SELECT * FROM Project..CovidVaccinations

--Joined both the tables
SELECT * 
FROM Project..CovidDeaths
Join Project..CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date

SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidVaccinations.new_vaccinations
, SUM(CAST(CovidVaccinations.new_vaccinations as bigint)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.date) as ROLLCOUNT
FROM Project..CovidDeaths
Join Project..CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
Where CovidDeaths.continent is not null 
-- This should give us a table that tells us the number of new vaccinations and the total vaccinations on each day.

-- This table already has numbers for the total vaccination therefore im going to use it to calculate the percentage of people vaccinated 
-- IF this dataset did not have the total vaccination column i would've had to use a CTE or a temp table
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidVaccinations.new_vaccinations, CovidVaccinations.total_vaccinations, (CovidVaccinations.total_vaccinations/population)*100 as VACPERCENT
FROM Project..CovidDeaths
Join Project..CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.location like '%kingdom%'

