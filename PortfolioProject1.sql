--Check that the data is loaded 
Select *
From PortfolioProject1..covid_deaths

Select *
From PortfolioProject1..covid_vaccinations

--EXPLORING THE COVID_DEATHS DATA

--Select data to be used for the analysis
Select location, date, total_cases, total_deaths, population
From PortfolioProject1..covid_deaths
order by 1,2

--What's the percentage of Total deaths by Total Cases
--Shows the likelihood of dying of covid for each location by date
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..covid_deaths
Order by 1, 2
--Shows the likelihood of dying of covid in Nigeria 
--As at 15 Oct 2021, this is 1.33%
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..covid_deaths
where location like '%Nigeria%'
Order by date DESC
--which country has the highest likelihood of death from covid as at 15 oct 2021
--Yemen, Vanuatu, Peru, Mexico 
--however, this may not be a true picture since total case count is very low in some of these countries
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..covid_deaths
where date = '2021-10-15 00:00:00.000'
Order by DeathPercentage DESC

--Looking at countries with the highest infection rate when compared to their population
--Seychelles, Montenegro, Andorra, Georgia are amoungst the countries with the highest infection rate 
--use where continent is not null to remove continents from appearing as countries
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PopInfectedPercent
From PortfolioProject1..covid_deaths
where continent is not null
Group by location, population
order by PopInfectedPercent desc
--What is the highest infection rate China ever attained? 
--This is very low as China was struck during the first wave 
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PopInfectedPercent
From PortfolioProject1..covid_deaths
where continent is not null and location like '%China%'
Group by location, population
order by PopInfectedPercent desc
--Lets check this for Canada
--4.43..this is because canada was really impacted during the 3/4th wave which was driven by the more infectious delta variant
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PopInfectedPercent
From PortfolioProject1..covid_deaths
where continent is not null and location like '%Canada%'
Group by location, population
order by PopInfectedPercent desc

--Looking at countries with the highest DEATHS when compared to their population
--United States, Brazil, India has the highest deaths
--use where continent is not null to remove continents from appearing as countries
Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..covid_deaths
where continent is not null
Group by location, population
order by TotalDeathCount desc
--However checking this inrelation to each country's population
--Peru, Bosnia and Herzegovina, North Macedonia, Bulgaria have the highest death rates when compared by their population
Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(cast(total_deaths as int)/population)*100 as PopDeathpercent
From PortfolioProject1..covid_deaths
where continent is not null
Group by location, population
order by PopDeathpercent desc

--Looking at DeathRate by Infection
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX(cast(total_deaths as int)/total_cases)*100 as InfectedDeathPercent
From PortfolioProject1..covid_deaths
where continent is not null
Group by location, population
order by InfectedDeathPercent desc

--Analyzing by continent
--Analyzing DeathRate by continent
--North America has the highest DeathRate
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..covid_deaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers
--What's is the total cases, deaths and death percentage the first days of covid
--98 reported cases, 1 death and an death rate of 1.02 on 23 Jan
--Today 15 Oct, Total cases of 462853, total deaths of 7,671 and death rate of 1.66
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as InfectedDeathPercent
From PortfolioProject1..covid_deaths
where continent is not null
Group by date
order by date desc


--EXPLORING THE COVID_VACCINATIONS DATA

Select *
From PortfolioProject1..covid_vaccinations

--joining covid_vaccinations to covid_deaths
--Looking at Total Population vs Vaccinations
Select codeaths.continent, codeaths.date, codeaths.location, codeaths.population, covaccines.new_vaccinations
From PortfolioProject1..covid_deaths codeaths
Join PortfolioProject1..covid_vaccinations covaccines
	On codeaths.location = covaccines.location
	and codeaths.date = covaccines.date
where codeaths.continent is not null
--when did each continent(Africa) give the first vaccine
--First vaccination in Africa took place in Seychelles on 16 Jan 2021, 3000 vaccines were given 
Select codeaths.continent, codeaths.date, codeaths.location, codeaths.population, covaccines.new_vaccinations
From PortfolioProject1..covid_deaths codeaths
Join PortfolioProject1..covid_vaccinations covaccines
	On codeaths.location = covaccines.location
	and codeaths.date = covaccines.date
where codeaths.continent is not null and codeaths.continent like '%Africa%' and covaccines.new_vaccinations is not null
order by codeaths.date
--While firth vaccine in North America wasgiven in Canada on 15 Dec 2020. 718 shots 
Select codeaths.continent, codeaths.date, codeaths.location, codeaths.population, covaccines.new_vaccinations
From PortfolioProject1..covid_deaths codeaths
Join PortfolioProject1..covid_vaccinations covaccines
	On codeaths.location = covaccines.location
	and codeaths.date = covaccines.date
where codeaths.continent is not null and codeaths.continent like '%North America%' and covaccines.new_vaccinations is not null
order by codeaths.date

--Calculating rolling sum of new_vaccinations by date
Select codeaths.continent, codeaths.location, codeaths.date, codeaths.population, covaccines.new_vaccinations, 
SUM(cast( covaccines.new_vaccinations as bigint)) OVER (Partition by codeaths.Location order by codeaths.location) as RollingPeopleVaccinated
From PortfolioProject1..covid_deaths codeaths
Join PortfolioProject1..covid_vaccinations covaccines
	On codeaths.location = covaccines.location
	and codeaths.date = covaccines.date
where codeaths.continent is not null
order by 2, 3

--Few things i tried (a. and b.)
--a.
--Calculating Total vaccinations for each country
--In Morocco(Africa), China(Asia), UK(Europe), US (North America), Ocenia (Australia) --the countries with the highest total vaccinations for each continenet
Select codeaths.continent, codeaths.location, SUM(cast(covaccines.total_vaccinations as bigint)) as TotalRecordedvaccinations
From PortfolioProject1..covid_deaths codeaths
Join PortfolioProject1..covid_vaccinations covaccines
	On codeaths.location = covaccines.location
	and codeaths.date = covaccines.date
where codeaths.continent is not null
Group by codeaths.location, codeaths.continent
order by codeaths.continent, TotalRecordedvaccinations desc
--b.
--Calculating Total vaccinations for each country in propotion to their population
--In Morocco(Africa), China(Asia), UK(Europe), US (North America), Ocenia (Australia) --the countries with the highest total vaccinations for each continenet
Select codeaths.continent, codeaths.location, SUM(cast(covaccines.new_vaccinations as bigint)) as TotalNewvaccinations, 
MAX(codeaths.population) as HighestPopulation, SUM(cast(covaccines.new_vaccinations as bigint))/MAX(codeaths.population) *100 as PopVaccinatedPercent
From PortfolioProject1..covid_deaths codeaths
Join PortfolioProject1..covid_vaccinations covaccines
	On codeaths.location = covaccines.location
	and codeaths.date = covaccines.date
where codeaths.continent is not null
Group by codeaths.location, codeaths.continent
order by codeaths.continent, PopVaccinatedPercent desc
--However, a. and b. gives misleading numbers 


--Using CTE
With VacvsPop (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
--Calculating rolling sum of new_vaccinations by date
Select codeaths.continent, codeaths.location, codeaths.date, codeaths.population, covaccines.new_vaccinations, 
SUM(cast( covaccines.new_vaccinations as bigint)) OVER (Partition by codeaths.Location order by codeaths.location) as RollingPeopleVaccinated
From PortfolioProject1..covid_deaths codeaths
Join PortfolioProject1..covid_vaccinations covaccines
	On codeaths.location = covaccines.location
	and codeaths.date = covaccines.date
where codeaths.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentVaccinated
From VacvsPop
where Continent like '%Africa%' and Location like '%Nigeria%'
order by Date desc


--Creating View to store data for visualization in Tableau
Create View RollingPeopleVaccinated as 
Select codeaths.continent, codeaths.location, codeaths.date, codeaths.population, covaccines.new_vaccinations, 
SUM(cast( covaccines.new_vaccinations as bigint)) OVER (Partition by codeaths.Location order by codeaths.location) as RollingPeopleVaccinated
From PortfolioProject1..covid_deaths codeaths
Join PortfolioProject1..covid_vaccinations covaccines
	On codeaths.location = covaccines.location
	and codeaths.date = covaccines.date
where codeaths.continent is not null


--Looking into our newly created dataset RollingPeopleVaccinated
Select * 
From RollingPeopleVaccinated