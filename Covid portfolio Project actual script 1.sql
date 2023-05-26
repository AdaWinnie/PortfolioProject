
select *
from ProjectPortfolio..CovidDeaths
where continent is  not null
order by 3,4


--select *
--from ProjectPortfolio..CovidVaccinations
--order by 3,4

--Lets select data we are going to use


select location, date, total_cases, new_cases, total_deaths, population
from ProjectPortfolio..CovidDeaths
order by 1,2 

--We are going to be looking at Total cases vs Total Deaths
--We make use of 2 statement 
--First one 


select location, date, total_cases, total_deaths, (try_cast(total_deaths as decimal(12,2)) /(try_cast(total_cases as int)))*100 as DeathPercent
from ProjectPortfolio..CovidDeaths
where continent is not null
order by 1,2

                                         --OR 2nd statement
--shows the likehood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (CONVERT(DECIMAL(18,2), total_deaths) / CONVERT(DECIMAL(18,2), total_cases) )*100 as DeathPercent
from ProjectPortfolio..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases Vs population
--Shows what percentage of population for covid

select location, date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from ProjectPortfolio..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2 

--looking at Country with highest infection rates compared to population

select location,population,max (total_cases) as highestInfectionCount,max ((total_cases/population))*100 as PercentPopulationInfected
from ProjectPortfolio..CovidDeaths
--where location like '%states%'
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--showing countries with the highest Death count per popuation

select location,max (cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--LETS BREAK THINGS UP BY COTINENT 
        --SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT

select continent,max (cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
 SUM(cast(new_deaths as int))/Sum(new_cases) *100 as DeathPercentage 
from ProjectPortfolio..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



--LOOKING AT TOTAL POPULATION VS VACCINATION
--ie looking for the number of people that has been vaccinated

                --USE CT
with PopvsVac(continent, location,date,Population, new_vaccinations, RollingpeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum (cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated
--(RollingpeopleVaccinated)*100
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
  on dea.location= vac.location
   and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingpeopleVaccinated/Population)*100
from PopvsVac







--TEMP TABLE 

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
 Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
 RollingpeopleVaccinated numeric 
 )
 insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum (cast(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated
--(RollingpeopleVaccinated)*100
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
  on dea.location= vac.location
   and dea.date= vac.date
--where dea.continent is not null
--order by 2,3

select*,(RollingpeopleVaccinated/Population)*100
from #percentpopulationvaccinated





        --CREATING VIEWS TO STORE DATA FOR VISUALIZATIONS

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum (cast(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinated
--(RollingpeopleVaccinated)*100
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccinations vac
  on dea.location= vac.location
   and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select*
from percentpopulationvaccinated