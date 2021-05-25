select * 
from PortofolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likeliehood of dying if you contract Covid-19 in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
Where location like 'United Kingdom'
and Where continent is not null
order by 1,2

United Kingdom	2021-05-24 Total_cases: 4,480,760 Total_Deaths: 127,986 DeathPercentage: 2.85634579848062

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
Where location like 'Romania'
and Where continent is not null
order by 1,2

Romania	2021-05-24 Total_cases:	1075773	Total_Deaths: 29,977 DeathPercentage: 2.78655441250152

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid-19

select location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
from PortofolioProject..CovidDeaths
Where location like 'United Kingdom'
and Where continent is not null
order by 1,2

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
Where location like 'Romania'
and Where continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with the Highest Death Count Per Population

select location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
from PortofolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--Let's Break things down by Continent 

select location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
from PortofolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

select continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
from PortofolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Nubmers

select 
SUM(new_cases) as total_cases, 
SUM( CAST(new_deaths AS INT)) as total_deaths, 
SUM(CAST(new_deaths AS INT))/ SUM(new_cases) *100 as DeathPercentage
from PortofolioProject..CovidDeaths
--Where location like 'Romania'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population Vaccinated 

select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location)
from PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
order by 2,3

select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255), 
Date Datetime,
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
--Where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS 

CREATE VIEW PercentPopulationVaccinated AS
select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 2,3

SELECT * FROM PercentPopulationVaccinated