Select *
From PortfolioProject..CovidDeaths$
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Total  Cases vs Population

Select Location, date, total_cases, Population, (total_deaths/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%india%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing countries with Highest Death Count per population

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%india%'
Where continent is not null
Group by Location
order by TotalDeathCount  desc

--Breaking things down by Continent
--Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%india%'
Where continent is not null
Group by continent
order by TotalDeathCount  desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2 

-- Lokking at Total population vs vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated, 
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --Use CTE 
 With PopvsVac (Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)as
 (
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 )
 Select *, (RollingPeopleVaccinated/Population)/100
 from PopvsVac

 --Temp Table
 
 Create table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into #PercentPopulationVaccinated
  Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

  Select *, (RollingPeopleVaccinated/Population)/100
 from #PercentPopulationVaccinated

 Drop table if exists #PercentPopulationVaccinated

 --Creating View to store data for later Visulations

Create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 Select * from PercentPopulationVaccinated