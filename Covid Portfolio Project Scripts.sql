SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

--Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Kenya'
AND continent IS NOT NULL
ORDER BY 1, 2

--Total_cases vs Population
--shows percentage of population infected by covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentofPopulationInfected
FROM CovidDeaths
WHERE location = 'Kenya'
AND continent IS NOT NULL
ORDER BY 1, 2 

--Countries With The Highest Infection Rate Compared To Population 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX ((total_cases)/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

--Countries With The Highest Death Count per Population

SELECT location, population, MAX (CAST (total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC

--Breaking Down By Continent

--Continents With The Highest Death Count

SELECT continent, MAX (CAST (total_deaths AS INT)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--GLOBAL NUMBERS

SELECT SUM (new_cases) AS total_cases, SUM (CAST (new_deaths AS INT)) total_deaths, 
SUM(CAST(new_deaths AS INT))/ SUM(new_cases)*100 AS total_death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1

--DAILY GLOBAL NUMBERS

SELECT date, SUM (new_cases) AS total_cases, SUM (CAST (new_deaths AS INT)) total_deaths, 
SUM(CAST(new_deaths AS INT))/ SUM(new_cases)*100 AS total_death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

--Number of Vaccinations per population

SELECT dea.continent, dea.location, dea.population, MAX(new_vaccinations)
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.population
ORDER BY 2,3


--TotalPopulation VS Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM (CONVERT(INT,vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Used CTE

--Percentage of Rolling People Vaccinated

WITH popvsvacc (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS 
(SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM (CONVERT(INT,vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 AS percent_population_vaccinated
FROM popvsvacc

--TEMP TABLE

DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(continent NVARCHAR (255),
location NVARCHAR (255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_people_vaccinated NUMERIC
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM (CONVERT(INT,vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100 AS percent_population_vaccinated
FROM #percent_population_vaccinated

--Creating View 

CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM (CONVERT(INT,vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM percent_population_vaccinated