select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVacs
--order by 3,4

--Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in USA

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, total_cases,population,  (total_cases/population)*100 as PercentageOFPop
from PortfolioProject..CovidDeaths
---Where location like '%states%'
order by 1,2

-- Looking at Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CovidCases
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location,population
order by CovidCases desc

--Showing Contries ith Highest Death count per population

select location,max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- LETS BREAK THING DOWN BY CONTINENTS
--Showing the continents with highest death counts

select location,max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select continent,sum(new_cases) as NewCases, Sum(cast(new_deaths as int)) as Deaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentages --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
group by continent
order by 1,2


select sum(new_cases) as NewCases, Sum(cast(new_deaths as int)) as NewDeaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentages --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--group by date
order by 1,2


-- Looking at total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) Over(Partition by dea.Location Order by dea.location,dea.date) as RollingVaxCount
, (RollingVaxCount/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
where continent is not null
order by 2,3

--Use CTE

With PopVsVac (Continent, Location, Date, Population, New_Vacctionations, RollingVaxCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) Over(Partition by dea.Location Order by dea.location,dea.date) as RollingVaxCount
--, (RollingVaxCount/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
where continent is not null
--order by 2,3
)

Select *, (RollingVaxCount/population)*100
from PopVsVac


--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaxCount numeric
)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) Over(Partition by dea.Location Order by dea.location,dea.date) as RollingVaxCount
--, (RollingVaxCount/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
--where continent is not null
--order by 2,3

Select *, (RollingVaxCount/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) Over(Partition by dea.Location Order by dea.location,dea.date) as RollingVaxCount
--, (RollingVaxCount/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacs vac
	On dea.location = vac.location
	and dea.date = vac.date
where continent is not null
--order by 2,3
