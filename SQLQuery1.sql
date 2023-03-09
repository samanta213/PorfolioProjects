Select [location], [date], [total_deaths], [new_cases], [total_deaths], [population] 
From PortfolioProject..CovidDeaths order by 1,2


--Looking at Total Cases Vs Total Deaths
Select [location], [date], [total_cases], [total_deaths],round([total_cases]/[total_deaths],2) as Deathpercentage  
From PortfolioProject..CovidDeaths 
where location = 'India'
order by 1,2

--Looking at Total cases vs Population

Select [location], [date], [total_cases],[population], round([total_cases]/[population],2) as Totalpercentage  
From PortfolioProject..CovidDeaths 
where location = 'India'
order by 1,2

--Looking at Countries with Highest Infection compared to Population

Select [location], max([total_cases]) as Highestinfection, [population], round(max([total_cases]/[population]),2) as percentagepeopleinfected  
From PortfolioProject..CovidDeaths 
group by location, population
order by 4 desc

--Showing the Coutries with Highest Death per Population

Select [location], max(cast([total_cases] as int)) as Totdeathcount  
From PortfolioProject..CovidDeaths 
where [continent] is not null
group by location, population
order by Totdeathcount desc

--Breaking down by continents
Select[continent], max(cast([total_cases] as int)) as Totdeathcount  
From PortfolioProject..CovidDeaths 
where [continent] is not null
group by [continent]
order by Totdeathcount desc

--Global Numbers

Select [date], sum([new_cases]) as TotalCases, sum(cast([new_deaths] as int)) as Totaldeaths, 
round(sum(cast([new_deaths] as int)/NULLIF([new_cases], 0)),2) as Deathpercentage  
From PortfolioProject..CovidDeaths 
where [continent] is not null
group by [date]
order by 1,2

--Totals
Select  SUM([new_cases]) as TotalCases, SUM(cast([new_deaths] as bigint)) as TotalDeaths,
round(SUM(cast([new_deaths] as bigint))/SUM([new_cases])*100,2) as DeathPercentage
From PortfolioProject..CovidDeaths 

-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.date,dea.Location) as RollingpeopleVacination
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac on dea.location = vac.location and
									  dea.date = vac.date
where dea.[continent] is not null
order by 2,3

--Using WITH
with PopulationVsVaccination (continent, location, date, population, new_vaccinations,RollingpeopleVacination) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.date,dea.Location) as RollingpeopleVacination
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac on dea.location = vac.location and
									  dea.date = vac.date
where dea.[continent] is not null
)
select *, round((RollingpeopleVacination/Population),2) from PopulationVsVaccination

--Using Temp Table
--drop table if exists #percentagepeoplevaccinated
--create table #percentagepeoplevaccinated
--(
--Continent nvarchar(255),Location nvarchar(255),Date datetime, Population numeric, RollingpeopleVaccinated numeric)
--insert into #percentagepeoplevaccinated
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.Location order by dea.Location,dea.Date) as RollingpeopleVaccinated
--from [dbo].[CovidDeaths] dea
--join [dbo].[CovidVaccinations] vac on dea.location = vac.location and
--									  dea.date = vac.date
--select *, (RollingpeopleVaccinated/Population)*100 from #percentagepeoplevaccinated

Create view PercentagepeopleVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.date,dea.Location) as RollingpeopleVacination
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccinations] vac on dea.location = vac.location and
									  dea.date = vac.date
where dea.[continent] is not null
--order by 2,3