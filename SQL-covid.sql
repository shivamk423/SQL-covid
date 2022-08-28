--Creating  covide death Table 
CREATE table covid_death (	
iso_code varchar,
continent varchar ,
location varchar,
date_ date,
population BIGINT,
total_cases int ,
new_cases int,
new_cases_smoothed DOUBLE PRECISION,
total_deaths DOUBLE PRECISION,
new_deaths DOUBLE PRECISION,
new_deaths_smoothed DOUBLE PRECISION,
total_cases_per_million DOUBLE PRECISION,
new_cases_per_million DOUBLE PRECISION,
new_cases_smoothed_per_million DOUBLE PRECISION,
total_deaths_per_million DOUBLE PRECISION,
new_deaths_per_million double PRECISION,
new_deaths_smoothed_per_million DOUBLE PRECISION,
reproduction_rate DOUBLE PRECISION,icu_patients DOUBLE PRECISION,
icu_patients_per_million DOUBLE PRECISION,
hosp_patients DOUBLE PRECISION,
hosp_patients_per_million DOUBLE PRECISION,
weekly_icu_admissions DOUBLE PRECISION,
weekly_icu_admissions_per_million DOUBLE PRECISION,
weekly_hosp_admissions DOUBLE PRECISION,
weekly_hosp_admissions_per_million DOUBLE PRECISION);

copy covid_death from 'C:\Program Files\PostgreSQL\14\data\data_set\CovidDeaths.csv' DELIMITER ',' csv header;

select * FROM covid_death;

--creating covid_vaccination Table 
CREATE TABLE covid_vaccination (
	iso_code varchar,
	continent varchar,
	location varchar,
	date_ date ,
	total_tests DOUBLE PRECISION ,
	new_tests DOUBLE PRECISION ,
	total_tests_per_thousand DOUBLE PRECISION , 
	new_tests_per_thousand DOUBLE PRECISION,
	new_tests_smoothed DOUBLE PRECISION, 
	new_tests_smoothed_per_thousand DOUBLE PRECISION,
	positive_rate DOUBLE PRECISION,
	tests_per_case DOUBLE PRECISION ,
	tests_units VARCHAR,
	total_vaccinations DOUBLE PRECISION ,
	people_vaccinated DOUBLE PRECISION ,
	people_fully_vaccinated DOUBLE PRECISION ,
	total_boosters DOUBLE PRECISION,
	new_vaccinations DOUBLE PRECISION,
	new_vaccinations_smoothed DOUBLE PRECISION ,
	total_vaccinations_per_hundred DOUBLE PRECISION,
	people_vaccinated_per_hundred DOUBLE PRECISION,
	people_fully_vaccinated_per_hundred DOUBLE PRECISION,
	total_boosters_per_hundred DOUBLE PRECISION,
	new_vaccinations_smoothed_per_million DOUBLE PRECISION,
	new_people_vaccinated_smoothed DOUBLE PRECISION,
	new_people_vaccinated_smoothed_per_hundred DOUBLE PRECISION,
	stringency_index DOUBLE PRECISION,
	population_density DOUBLE PRECISION,
	median_age DOUBLE PRECISION,
	aged_65_older DOUBLE PRECISION,
	aged_70_older DOUBLE PRECISION,
	gdp_per_capita DOUBLE PRECISION,
	extreme_poverty DOUBLE PRECISION,
	cardiovasc_death_rate DOUBLE PRECISION,
	diabetes_prevalence DOUBLE PRECISION,
	female_smokers DOUBLE PRECISION,
	male_smokers DOUBLE PRECISION,
	handwashing_facilities DOUBLE PRECISION,
	hospital_beds_per_thousand DOUBLE PRECISION,
	life_expectancy DOUBLE PRECISION,
	human_development_index DOUBLE PRECISION,
	excess_mortality_cumulative_absolute DOUBLE PRECISION,
	excess_mortality_cumulative DOUBLE PRECISION,
	excess_mortality DOUBLE PRECISION,
	excess_mortality_cumulative_per_million DOUBLE PRECISION
);

copy covid_vaccination from 'C:\Program Files\PostgreSQL\14\data\data_set\covidvaccinations.csv' DELIMITER ',' csv header;

--Select Data that we are going to be using
SELECT location, date_ ,total_cases , new_cases, total_deaths, population
from covid_death
order by 1,2

--lOOKING AT TOTAL CASE VS TOTAL DEATH.
select LOCATION, date_, total_cases, total_deaths
from covid_death
order by 1,2

-lOOKING AT TOTAL CASE VS TOTAL DEATH.
select LOCATION, date_, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_death
order by 1,2

--SELECT * FROM covid_death where location = 'India’

--lOOKING AT TOTAL CASE VS TOTAL DEATH.
-- shows likelihood of dying if you contract covid in your country
select LOCATION, date_, total_cases, total_deaths, (total_deaths/total_cases)*100 as percent_population_infected
from covid_death
WHERE location like '%India%'
order by 1,2

--looking at total cases vs population
-- shows what pecentage of population got covid
select location , population,max(total_cases) as higest_infection_count , max((total_cases/population))*100 as  Percent_population_infected
from covid_death
--where location like '%India%'
GROUP by location , population
order by  percent_population_infected desc

-- Showing countries with highest death count per population
select location , max(total_deaths) as totaldeathcount
from covid_death
--where location like '%India%'
where continent is not null
GROUP by location
order by totaldeathcount desc

-- lets break things down by continent
select continent , max(total_deaths) as totaldeathcount 
from covid_death
--where location like '%India%'
where continent is not null
GROUP by continent
order by  totaldeathcount desc

-- Showing countries with highest death count per population
select location , max(total_deaths) as totaldeathcount
from covid_death
--where location like '%India%'
where continent is  null
GROUP by location
order by totaldeathcount desc

-- Global Numbers
select date_ , sum(new_cases) as Total_case, sum(total_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage 
from covid_death
where continent is not NULL
group by date_
order by 1,2

-- looking at the Total population vs vaccination
SELECT dea.continent, dea.location, dea.date_, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date_)
from covid_death dea
join covid_vaccination vac
on dea.location = vac.location
and dea.date_ = vac.date_
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date_, Population, New_Vaccinations, RollingPeopleVaccinated )
as
(
Select dea.continent, dea.location, dea.date_, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date_) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covid_death dea
join covid_vaccination vac
	On dea.location = vac.location
	and dea.date_ = vac.date_
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp table
DROP Table if exists PercentPopulationVaccinated
CREATE table PercentPopulationVaccinated
( 
	continent varchar,
	location varchar,
	date_ date,
	population DOUBLE PRECISION,
	new_vaccinations DOUBLE PRECISION,
	RollingPeopleVaccinated DOUBLE PRECISION
);
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date_, Population, New_Vaccinations, RollingPeopleVaccinated )
as
(
Select dea.continent, dea.location, dea.date_, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date_) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covid_death dea
join covid_vaccination vac
	On dea.location = vac.location
	and dea.date_ = vac.date_
--where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date_, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date_) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from covid_death dea
join covid_vaccination vac
	On dea.location = vac.location
	and dea.date_ = vac.date_
where dea.continent is not null

SELECT *
from Percent_Population_Vaccinated