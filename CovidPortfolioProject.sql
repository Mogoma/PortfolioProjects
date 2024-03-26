--SELECT *
--FROM PortfolioProject.dbo.covidvaccinations$
--ORDER BY 3,4

SELECT *
FROM PortfolioProject.dbo.covideaths$
WHERE continent is not null
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.covideaths$
ORDER BY 1,2

--total_cases vs total_deaths
--likelihood of dying from COVID19
SELECT location, date, total_cases, total_deaths, CONVERT(DECIMAL(18, 6),(CONVERT(DECIMAL(18, 6), total_deaths)/CONVERT(DECIMAL(18, 6), total_cases)))*100 AS deaths_over_total 
FROM PortfolioProject.dbo.covideaths$
WHERE location like '%Benin%'
ORDER BY 1,2

--changing data types to be able to execute easily
SELECT * FROM PortfolioProject.dbo.covideaths$
WHERE continent is not null

ALTER TABLE PortfolioProject.dbo.covideaths$
ALTER COLUMN total_cases FLOAT

ALTER TABLE PortfolioProject.dbo.covideaths$
ALTER COLUMN total_deaths FLOAT

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deaths_over_total 
FROM PortfolioProject.dbo.covideaths$
WHERE location like '%Benin%'
ORDER BY 1,2

--total_cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS population_covid_percentage 
FROM PortfolioProject.dbo.covideaths$
WHERE location like '%Benin%'
ORDER BY 1,2

--countries with highest infection rates
SELECT location, population, MAX(total_cases) AS highest_infetion_count, MAX((total_cases/population))*100 AS population_covid_percentage 
FROM PortfolioProject.dbo.covideaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY population_covid_percentage DESC

--countries with highest death count
SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioProject.dbo.covideaths$
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC

--continent with highest death count 
SELECT continent, MAX(total_deaths) AS total_death_count
FROM PortfolioProject.dbo.covideaths$
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC

--SELECT location, MAX(total_deaths) AS total_death_count
--FROM PortfolioProject.dbo.covideaths$
--WHERE continent is null
--GROUP BY location
--ORDER BY total_death_count DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage --total_cases, total_deaths, (total_deaths/total_cases)*100 AS deaths_over_total 
FROM PortfolioProject.dbo.covideaths$
WHERE continent is  not null AND new_cases <> 0
GROUP BY date
ORDER BY 1,2

--overall global numbers

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage --total_cases, total_deaths, (total_deaths/total_cases)*100 AS deaths_over_total 
FROM PortfolioProject.dbo.covideaths$
WHERE continent is  not null AND new_cases <> 0
--GROUP BY date
ORDER BY 1,2

--vaccinations
SELECT *
FROM PortfolioProject..covideaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location and
dea.date = vac.date

--total_population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..covideaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--ALTER TABLE PortfolioProject.dbo.covidvaccinations$
--ALTER COLUMN new_vaccinations FLOAT

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS rolling_people_vaccinated
FROM PortfolioProject..covideaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
	ON dea.location = vac.location and
	dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--USE CTE
WITH popvsvac (continent,location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS rolling_people_vaccinated
FROM PortfolioProject..covideaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
	ON dea.location = vac.location and
	dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT*, (rolling_people_vaccinated/population)*100
FROM popvsvac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
ne_vaccinations numeric,
rolling_people_vaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS rolling_people_vaccinated
FROM PortfolioProject..covideaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
	ON dea.location = vac.location and
	dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated

--creating views for later data visualiations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS rolling_people_vaccinated
FROM PortfolioProject..covideaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
	ON dea.location = vac.location and
	dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated

CREATE VIEW PopulationVsVaccinations AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..covideaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location and
dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT * FROM PopulationVsVaccinations

CREATE VIEW OverallGlobalNumbers AS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage --total_cases, total_deaths, (total_deaths/total_cases)*100 AS deaths_over_total 
FROM PortfolioProject.dbo.covideaths$
WHERE continent is  not null AND new_cases <> 0
--GROUP BY date
--ORDER BY 1,2

CREATE VIEW HighestDeathCountCountries AS
SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioProject.dbo.covideaths$
WHERE continent is not null
GROUP BY location
--ORDER BY total_death_count DESC

SELECT * FROM HighestDeathCountCountries