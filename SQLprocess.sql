select *
from Portfolio1..CovidDeaths
order by 3,4;

select *
from Portfolio1..CovidVaccinations
order by 3,4;

-- Select the Data we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio1..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio1..CovidDeaths
where location like '%germany%'
order by 5 desc

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from Portfolio1..CovidDeaths
where location like '%germany%'
order by 1, 2

-- Looking at Countries with highest infection rate compared to poplulation
select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PercentPopulationInfected
from Portfolio1..CovidDeaths
--where location like '%germany%'
group by location, population
order by 4 desc

-- Showing Countries with the highest death count per population
-- Discovered a problem with the dataset, to avoid seeing locations grouped by the entire continent -> choose data that have a continent assigned to.
select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio1..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Let's break things down by continent
--Showing the contintents with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio1..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolio1..CovidDeaths
where continent is not null
--group by date
order by 1,2 


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
 , (
from Portfolio1..CovidDeaths dea
join Portfolio1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with Popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio1..CovidDeaths dea
join Portfolio1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from Popvsvac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio1..CovidDeaths dea
join Portfolio1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio1..CovidDeaths dea
join Portfolio1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated
Footer
© 2023 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
