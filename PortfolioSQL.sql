--Deaths
select *
From [Covid-Deaths]
order by 3,4

select *
From ['Covid-Vaccinations$']
order by 3,4

Select location,date,total_cases, new_cases,total_deaths,population
From [Covid-Deaths]
order by 1,2	

--Total cases vs Total deaths by country

Select location,date,total_cases,total_deaths, (total_deaths/total_cases) as DeathPercentage
From [Covid-Deaths]
order by 1,2	

--Total cases vs Total deaths germany ( indicator of the percentage chance of dying, if you get covid in Germany)
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid-Deaths]
where location like 'Germany'
order by 1,2	

--Total cases vs population 
-- Shows what percentage of germany had the coronavirus
Select location,date,total_cases,population, (total_cases/population)*100 as CasePercentageOfPopulation
From [Covid-Deaths]
where location like 'Germany'
order by 1,2	


-- Looking at the highest infection rates worldwide

Select location, max(total_cases) as HighestTotalCases,population, max(total_cases/population)*100 as HighestCasePercentageOfPopulation
From [Covid-Deaths]
where continent is not null
group by location,population
order by HighestCasePercentageOfPopulation DESC



-- Looking at the highest deaths worldwide
Select location, max(cast (total_deaths as int)) as HighestTotalDeaths
From [Covid-Deaths]
where continent is not null 
group by location,continent
order by HighestTotalDeaths DESC

-- Division into continents  
Select location as ContinentTrue, max(cast (total_deaths as int)) as HighestTotalDeaths
From [Covid-Deaths]
where continent is  null 
group by location
order by HighestTotalDeaths DESC

--Global data ( a bit of perspective for visualisation and views) (1)
Select  date, sum (cast(new_cases as int)) as CaseSum, sum(cast(new_deaths as int)) as DeathSum , sum(cast(new_deaths as int))/sum(new_cases)*100 as PerCasToDeathSum
From [Covid-Deaths]
where continent is null and date != '2020-01-22'
group by date
order by 1,2 DESC   

--Global data ( a bit of perspective for visualisation and views) (2)
Select  sum (cast(new_cases as int)) as CaseSum, sum(cast(new_deaths as int)) as DeathSum , sum(cast(new_deaths as int))/sum(new_cases)*100 as PerCasToDeathSum
From [Covid-Deaths]
where continent is null and date != '2020-01-22'
order by 1,2 DESC   


--Vaccinations overview
select *
from ['Covid-Vaccinations$']

-- Total population vs vaccinations

--select *
--from [Covid-Deaths] Dea
--join ['Covid-Vaccinations$'] Vac
--on dea.date=vac.date and dea.location=vac.location

select dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, sum(convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as NewVacSumBycountry
from [Covid-Deaths] Dea
join ['Covid-Vaccinations$'] Vac
on dea.date=vac.date and dea.location=vac.location
where dea.continent is not null
order by 2,3

--CTE
with TotPopVsVacc (continent, location, date, new_vaccinations,population, NewVacSumBycountry)
as
(
select dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, sum(convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as NewVacSumBycountry
from [Covid-Deaths] Dea
join ['Covid-Vaccinations$'] Vac
on dea.date=vac.date and dea.location=vac.location
where dea.continent is not null

)
select * , (NewVacSumBycountry/population)*100
from TotPopVsVacc

--Temp Table 

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
new_vaccinations bigint,
population  bigint,
NewVacSumBycountry bigint 
)
insert into #PercentagePopulationVaccinated
 select dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, sum(convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as NewVacSumBycountry
from [Covid-Deaths] Dea
join ['Covid-Vaccinations$'] Vac
on dea.date=vac.date and dea.location=vac.location 
where dea.continent is not null 


from #PercentagePopulationVaccinated

--Creating view to visualise 

Create view  ViewPercentagePopulationVaccinated as

select dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, sum(convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as NewVacSumBycountry
from [Covid-Deaths] Dea
join ['Covid-Vaccinations$'] Vac
on dea.date=vac.date and dea.location=vac.location 
where dea.continent is not null 