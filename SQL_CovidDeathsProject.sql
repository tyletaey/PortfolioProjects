-- Explore CovidDeaths and CovidVaccinations data

Select * From PortfolioProjects..CovidDeaths
Where continent is not null
Order by 3,4

Select * From PortfolioProjects..CovidVaccinations
Where continent is not null
Order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total cases vs Total deaths
-- Show likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProjects..CovidDeaths
Where continent is not null AND Location = 'Thailand'
Order by 1,2

-- Change datatype from char to float
-- This will change in the database not temporary change
	
Alter table CovidDeaths alter column total_deaths float
Alter table CovidDeaths alter column total_cases float

-- Looking at total cases vs population
-- Show what percentage of population

Select Location, date, population, total_cases, (total_cases/population)*100 AS PercentageOfPoppulationInfected
From PortfolioProjects..CovidDeaths
Where continent is not null
-- Where Location = 'Thailand'
Order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) AS Highest_Infection, MAX((total_cases/population))*100 AS Percentage
From PortfolioProjects..CovidDeaths
Where continent is not null
-- Where Location = 'Thailand'
Group by location, population
Order by Percentage desc

-- Showing Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) AS TotalDeathsCount
From PortfolioProjects..CovidDeaths
Where continent is not null
-- Where Location = 'Thailand'
Group by Location
Order by TotalDeathsCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(total_deaths) AS TotalDeathsCount
From PortfolioProjects..CovidDeaths
-- Where Location = 'Thailand'
Where continent is not null
Group by continent
Order by TotalDeathsCount desc


-- Showing the continents with the highest death count per population

Select continent, MAX(total_deaths) AS TotalDeathsCount
From PortfolioProjects..CovidDeaths
Where continent is not null
-- Where Location = 'Thailand'
Group by continent
Order by TotalDeathsCount desc


-- GLOBAL NUMBERS Looking at all the countries

Select SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathsPercentage
From PortfolioProjects..CovidDeaths
-- Where Location = 'Thailand'
Where continent is not null
--Group By date
order by 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) AS RollingPeopleVaccinations
	--,(RollingPeopleVaccinations/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinations)
AS
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) AS RollingPeopleVacinations
	--,(RollingPeopleVaccinations/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinations/population)*100
From PopvsVac


-- Create Temporary Table

DROP Table if exists #PercentagePopulationVaccinate
CREATE Table #PercentagePopulationVaccinate
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinations numeric
)

Insert into #PercentagePopulationVaccinate
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) AS RollingPeopleVacinations
	--,(RollingPeopleVaccinations/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinations/population)*100
From #PercentagePopulationVaccinate

-- Creating view to store data for later datavisualization

CREATE VIEW PercentagePopulationVaccinate AS
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) AS RollingPeopleVacinations
	--,(RollingPeopleVaccinations/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentagePopulationVaccinate






