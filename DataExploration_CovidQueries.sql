/*
Covid Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types, and more basic or fundamentals
*/

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths
--Shows % of dying if you conract covid in the Philippines
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Philippines'
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Philippines'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing countries  with highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing continents with highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking ate total population vs vaccinations
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 as Percentage
FROM PopvsVac

--Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/population)*100 as Percentage
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualzitaions
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null



