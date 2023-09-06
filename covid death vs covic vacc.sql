-- "CovidProject".coviddeaths1 definition

-- Drop table

-- DROP TABLE "CovidProject".coviddeaths1;

CREATE TABLE "CovidProject".coviddeaths1 (
	iso_code varchar(50) NULL,
	continent varchar(50) NULL,
	"location" varchar(50) NULL,
	"date" varchar(50) NULL,
	population int4 NULL,
	total_cases int4 NULL,
	new_cases int4 NULL,
	new_cases_smoothed float4 NULL,
	total_deaths int4 NULL,
	new_deaths int4 NULL,
	new_deaths_smoothed int4 NULL,
	total_cases_per_million float4 NULL,
	new_cases_per_million float4 NULL,
	new_cases_smoothed_per_million float4 NULL,
	total_deaths_per_million float4 NULL,
	new_deaths_per_million float4 NULL,
	new_deaths_smoothed_per_million int4 NULL,
	reproduction_rate float4 NULL,
	icu_patients varchar(50) NULL,
	icu_patients_per_million varchar(50) NULL,
	hosp_patients varchar(50) NULL,
	hosp_patients_per_million varchar(50) NULL,
	weekly_icu_admissions varchar(50) NULL,
	weekly_icu_admissions_per_million varchar(50) NULL,
	weekly_hosp_admissions varchar(50) NULL,
	weekly_hosp_admissions_per_million varchar(50) NULL,
	new_tests varchar(50) NULL,
	total_tests varchar(50) NULL,
	total_tests_per_thousand varchar(50) NULL,
	new_tests_per_thousand varchar(50) NULL,
	new_tests_smoothed varchar(50) NULL,
	new_tests_smoothed_per_thousand varchar(50) NULL,
	positive_rate varchar(50) NULL,
	tests_per_case varchar(50) NULL,
	tests_units varchar(50) NULL,
	total_vaccinations varchar(50) NULL,
	people_vaccinated varchar(50) NULL,
	people_fully_vaccinated varchar(50) NULL,
	new_vaccinations varchar(50) NULL,
	new_vaccinations_smoothed varchar(50) NULL,
	total_vaccinations_per_hundred varchar(50) NULL,
	people_vaccinated_per_hundred varchar(50) NULL,
	people_fully_vaccinated_per_hundred varchar(50) NULL,
	new_vaccinations_smoothed_per_million varchar(50) NULL,
	stringency_index float4 NULL,
	population_density float4 NULL,
	median_age float4 NULL,
	aged_65_older float4 NULL,
	aged_70_older float4 NULL,
	gdp_per_capita float4 NULL,
	extreme_poverty varchar(50) NULL,
	cardiovasc_death_rate float4 NULL,
	diabetes_prevalence float4 NULL,
	female_smokers varchar(50) NULL,
	male_smokers varchar(50) NULL,
	handwashing_facilities float4 NULL,
	hospital_beds_per_thousand float4 NULL,
	life_expectancy float4 NULL,
	human_development_index float4 NULL
);

-- Permissions

ALTER TABLE "CovidProject".coviddeaths1 OWNER TO postgres;
GRANT ALL ON TABLE "CovidProject".coviddeaths1 TO postgres;

-- Alter the data type of the column to NUMERIC
ALTER TABLE coviddeaths1
ALTER COLUMN new_deaths_smoothed TYPE NUMERIC;

ALTER TABLE coviddeaths1
ALTER COLUMN new_deaths_smoothed_per_million TYPE NUMERIC;

-- Alter the data type of the column to BIGINT
ALTER TABLE coviddeaths1
ALTER COLUMN population TYPE BIGINT;


Select *
From "CovidProject".CovidDeaths1
Where continent is not null 
order by 3,4


---select data we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From "CovidProject".coviddeaths1
order by 1,2 ;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases,total_deaths, (total_deaths / total_cases)*100 as Deathprecentage
from "CovidProject".coviddeaths1 
where location like'%States%'
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, total_cases,population, (total_cases / population)*100 as InfectedPercentage
from "CovidProject".coviddeaths1 
--where location like'%States%'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

select location ,population , MAX(total_cases) as HighestInfectionCount ,MAX ((total_cases  / population))*100 as PercentOfPopulationInfected
from "CovidProject".coviddeaths1 
--where location like'%States%'
group by location,population 
order by PercentOfPopulationInfected desc ;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

-- Countries with Highest Death Count per Population
select continent  , MAX(cast(total_deaths as int )) as TotalDeathCount 
from "CovidProject".coviddeaths1 
--where location like'%States%'
where continent is not null 
group by continent 
order by totalDeathCount  desc ;


---- GLOBAL NUMBERS
Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
From "CovidProject".CovidDeaths1
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

select date, sum(new_cases) as total_cases --sum(new_deaths ) as total_deaths, sum(new_deaths )/sum(new_cases)*100 as DeathPercentage  
from "CovidProject".coviddeaths1 
where continent is not null 
group by date
order by 1,2;


SELECT
    date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE SUM(CAST(new_deaths AS int)) * 100.0 / NULLIF(SUM(new_cases), 0)
    END AS DeathPercentage
FROM
    "CovidProject".CovidDeaths1
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY date;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT c.continent ,c.location , c.date, c.population, c2.new_vaccinations
FROM "CovidProject".coviddeaths1 c
JOIN "CovidProject".covidvaccinations c2 ON c.location = c2.location AND c.date = c2.date
WHERE c.continent  IS not NULL 
order by 2,3;


SELECT 
    c.continent,
    c.location,
    c.date,
    c.population,
    c2.new_vaccinations,
    SUM(CAST(NULLIF(c2.new_vaccinations, '') AS INTEGER)) 
        OVER (PARTITION BY c.location order by c.location, c.date) AS RollingPeopleVaccinated
FROM 
    "CovidProject".coviddeaths1 c
JOIN 
    "CovidProject".covidvaccinations c2 
ON 
    c.location = c2.location 
    AND c.date = c2.date
WHERE 
    c.continent IS NOT NULL 
ORDER BY 
    2,3; 



-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
   (
SELECT 
    c.continent,
    c.location,
    c.date,
    c.population,
    c2.new_vaccinations,
    SUM(CAST(NULLIF(c2.new_vaccinations, '') AS INTEGER)) 
        OVER (PARTITION BY c.location order by c.location, c.date) AS RollingPeopleVaccinated
FROM 
    "CovidProject".coviddeaths1 c
JOIN 
    "CovidProject".covidvaccinations c2 
ON 
    c.location = c2.location 
    AND c.date = c2.date
WHERE 
    c.continent IS NOT NULL 
--ORDER BY   2,3
 )
select * , (RollingpeopleVaccinated/population)*100
from popvsvac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date TIMESTAMP,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);


INSERT INTO PercentPopulationVaccinated
SELECT 
    c.continent,
    c.location,
    TO_TIMESTAMP(c.date, 'YYYY-MM-DD') AS date,
    c.population,
    CAST(NULLIF(c2.new_vaccinations, '') AS NUMERIC) AS new_vaccinations,
    SUM(CAST(NULLIF(c2.new_vaccinations, '') AS NUMERIC)) 
        OVER (PARTITION BY c.location ORDER BY c.location, TO_TIMESTAMP(c.date, 'YYYY-MM-DD')) AS RollingPeopleVaccinated
FROM 
    "CovidProject".coviddeaths1 c
JOIN 
    "CovidProject".covidvaccinations c2 
ON 
    c.location = c2.location 
    AND c.date = c2.date
WHERE 
    c.continent IS NOT NULL;

 
select * , (RollingpeopleVaccinated/population)*100
from PercentPopulationVaccinated ;
 



