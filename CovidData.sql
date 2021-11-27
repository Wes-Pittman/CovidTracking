

--Total Cases vs Total Deaths -- 
SELECT location, population, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProjects..covid_deaths
WHERE location like 'united states'
ORDER BY 1,3;


--Total Cases vs Pop -- 
SELECT location, population, date, total_cases, (total_cases/population)*100 as Percentage_Infection
FROM PortfolioProjects..covid_deaths
WHERE location like 'united states'
ORDER BY location, population;


--Countries w/ High Infection -- 
SELECT location, population, MAX(total_cases) as high_infection, MAX((total_deaths/population))*100 as infection_percent
FROM PortfolioProjects..covid_deaths
--WHERE location like 'united states'
GROUP BY location, population
ORDER BY infection_percent desc;


--Highest Death count per Pop -- 
SELECT Location, population, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProjects..covid_deaths
WHERE continent is not NULL
GROUP BY Location, population
ORDER BY TotalDeathCount desc;


--Continent Highest Death per Pop
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..covid_deaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..covid_deaths
Where location like '%states%'
AND continent is not null 
AND total_cases is not NULL
AND total_deaths is not NULL
--Group By date
order by 1,2;


--Total Pop vs Vax
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations as bigint)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..covid_deaths dea
JOIN PortfolioProjects..covid_vax vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not NULL
ORDER BY dea.location

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..covid_deaths dea
Join PortfolioProjects..covid_vax vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
