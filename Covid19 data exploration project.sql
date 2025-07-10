-- Covid19 Data Exploration
-- Covid data up to November 6, 2021

SELECT * 
FROM PortfolioProject..Covid_Cases
WHERE continent  IS NOT NULL
ORDER BY 7 desc;


-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- This is the data we will be starting with 

SELECT location, population, date,new_cases, new_deaths, total_cases, total_deaths 
FROM PortfolioProject..Covid_Cases
WHERE continent  IS NOT NULL and location = 'united states'
ORDER BY 1, 3;


-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with the highest infection 

SELECT location, population, max(total_cases) AS highest_cases
FROM PortfolioProject..Covid_Cases
WHERE continent  IS NOT NULL
GROUP BY population,location
ORDER BY highest_cases DESC

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Countries with the highest infection rate compared to their population


SELECT location, population, max(total_cases) AS highest_cases, max((total_cases/population))*100 AS percentage_of_population_infeted 
FROM PortfolioProject..Covid_Cases
WHERE continent  IS NOT NULL
GROUP BY population,location
ORDER BY highest_cases DESC


-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with the Highest Death 


SELECT location, population, max(cast(total_deaths as int)) AS highest_death
FROM PortfolioProject..Covid_Cases
WHERE continent  IS NOT NULL
GROUP BY population,location
ORDER BY highest_death DESC


-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Countries with the Highest Death rate compared to Population


SELECT location, population, max(cast(total_deaths as int)) AS highest_death, max((total_deaths/population))*100 AS death_percentage_of_population 
FROM PortfolioProject..Covid_Cases
WHERE continent  IS NOT NULL
GROUP BY population,location
ORDER BY highest_death DESC


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Total Cases vs Total Deaths
-- Likely hood of dying after incurring COVID19 in your country 


SELECT location, population, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS survivsl_rate 
FROM PortfolioProject..Covid_Cases
WHERE continent IS NOT NULL 
ORDER BY 1, 3

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Showing contintents with the highest death



SELECT location, MAX(cast(total_deaths as int))AS highest_death
FROM PortfolioProject..Covid_Cases
WHERE continent IS  NULL 
Group BY location
ORDER BY highest_death DESC


-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global numbers

	SELECT date, SUM(cast(new_cases as int)) AS total_cases, SUM(cast(new_deaths as int)) total_death, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS survial_rate
	FROM PortfolioProject..Covid_Cases
	WHERE continent  IS NOT NULL
	group by date
	 ORDER BY date


 -----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Population vs Vaccinations
-- Percentage of population that has bee vaccinated

select  cases.continent, cases.location, cases.date, cases.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over ( partition by cases.location order by  cases.date) as total_vaccination
from PortfolioProject..Covid_Cases as cases
inner join PortfolioProject..covid_vaccination as vac on
cases.location = vac.location
and cases.date = vac.date
where cases.continent is not null
order by 2,3

--- using CTE to perform calculation 
with vaccine_percent(continent, location, date, population, new_vaccinations, total_vaccinations)
as
(select  cases.continent, cases.location, cases.date, cases.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over ( partition by cases.location order by  cases.date) as total_vaccination
from PortfolioProject..Covid_Cases as cases
inner join PortfolioProject..covid_vaccination as vac on
cases.location = vac.location
and cases.date = vac.date
where cases.continent is not null)

select top 1000 *, (total_vaccinations/population)*100
from vaccine_percent

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- createing view to store our table

CREATE VIEW Percentage_of_vaccination 
AS
SELECT  cases.continent, cases.location, cases.date, cases.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER ( PARTITION BY cases.location ORDER  BY  cases.date) as total_vaccination
FROM PortfolioProject..Covid_Cases as cases
 join PortfolioProject..covid_vaccination as vac on
cases.location = vac.location
and cases.date = vac.date
WHERE cases.continent IS NOT NULL

select *
from Percentage_of_vaccination
where location like '%nigeria%';
-----------------------------------------------------------------------------------------------------------------------------------------------------------
select cases.location, cases.date, cases.population, cases.total_cases, cases.total_deaths, vacc.total_vaccinations
from PortfolioProject..Covid_Cases as cases
left outer join PortfolioProject..Covid_vaccination as vacc on
cases.location = vacc.location and cases.date = vacc.date
where cases.continent is not null;
-----------------------------------------------------------------------------------------------------------------------------------------------------------
select cases.location, cases.date, cases.population, cases.total_cases, cases.total_deaths, vac.total_vaccinations
from PortfolioProject..Covid_Cases as cases
left outer join portfolioproject..Covid_vaccination as vac on
cases.location = vac.location and cases.date = vac.date
where cases.location like 'wo%'
