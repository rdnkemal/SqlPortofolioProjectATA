/*
select *
from coviddeaths 
order by 3,4 

select *
from covidvaccinations 
order by 3,4
*/


-- Selecting the data to be used

select location , `date`, total_cases, new_cases, total_deaths,  population
from coviddeaths
order by 1,2


-- Displaying the percentage of deaths in Indonesia
-- Total Cases vs Total Deaths

select location, `date`, total_cases, total_deaths, (total_deaths/total_cases)* 100 as deathpercentage
from coviddeaths
where location like '%indo%'
order by 1, 2


-- Viewing the percentage of the population exposed to COVID-19
-- Total Cases vs Population

select location, `date`, population ,total_cases,  (total_cases /population)* 100 as casepercentage
from coviddeaths
-- where location like '%indo%'
order by 1,2


-- Viewing countries with the highest infection rates compared to their populations

select location, population ,max(total_cases) as higestinfection , max((total_cases /population))* 100 as populationcasepercentage
from coviddeaths
-- where location like '%indo%'
where continent <> ''
group by location, population
order by populationcasepercentage desc 


-- Viewing countries with the highest death rates per population.

select location, max(total_deaths) as totaldeathcount  
from coviddeaths
-- where location like '%indo%'
where continent <> ''
group by location
order by totaldeathcount desc 
 

-- Breakdown by continent
-- Viewing continents with the highest death rates from COVID-19 per population

select continent  , max(total_deaths) as totaldeathcount  
from coviddeaths
-- where location like '%indo%'
where continent <> ''
group by continent 
order by totaldeathcount desc 

select location  , max(total_deaths) as totaldeathcount  
from coviddeaths
-- where location like '%indo%'
where continent = ''
and location not like '%income%'
group by location  
order by totaldeathcount desc 


-- Date and Global Figures

select `date`, sum(new_cases) as total_cases , sum(new_deaths)as total_deaths ,sum(new_deaths)/sum(new_cases)*100  as deathpercentage
from coviddeaths
-- where location like '%indo%'
where continent <> ''
group by `date` 
order by 1, 2

-- Global Figures

select sum(new_cases) as total_cases , sum(new_deaths)as total_deaths ,sum(new_deaths)/sum(new_cases)*100  as deathpercentage
from coviddeaths
-- where location like '%indo%'
where continent <> ''
-- group by `date` 
order by 1, 2


-- Total Population vs Vaccinations

select 
dea.continent , dea.location , dea.`date` , dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.`date`) as total_vaccinations  
from coviddeaths dea
join covidvaccinations vac
  on dea.location = vac.location 
  and dea.`date` = vac.`date`
where dea.continent <> '' 
order by 2, 3

  
-- Using CTEs

with popvsvac (continent, location,date,population,new_vaccinations, total_vaccinations)
as
(
select 
dea.continent , dea.location , dea.`date` , dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.`date`) as total_vaccinations  
from coviddeaths dea
join covidvaccinations vac
  on dea.location = vac.location 
  and dea.`date` = vac.`date`
where dea.continent <> '' 
-- order by 2, 3
)  
select *, (total_vaccinations /population)*100 
from popvsvac
  
  
-- Temp Table

drop table if exists percent_total_vaccinations

create table percent_total_vaccinations
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccations varchar(50),
total_vaccinations numeric
)

insert into percent_total_vaccinations
select dea.continent , dea.location , dea.`date` , dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.`date`) as total_vaccinations  
from coviddeaths dea
join covidvaccinations vac
  on dea.location = vac.location 
  and dea.`date` = vac.`date`
where dea.continent <> '' 
-- order by 2, 3

select *, (total_vaccinations /population)*100 as vaccinationspercent
from percent_total_vaccinations
  

-- Creating a View

create view percentpopulationvaccinated as
select dea.continent , dea.location , dea.`date` , dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.`date`) as total_vaccinations  
from coviddeaths dea
join covidvaccinations vac
  on dea.location = vac.location 
  and dea.`date` = vac.`date`
where dea.continent <> '' 
-- order by 2, 3




select *
from percentpopulationvaccinated limit 10