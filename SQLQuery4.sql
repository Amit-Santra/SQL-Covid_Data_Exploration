--SELECT *
--FROM SQL_Data_Exploration_Project..Covid_death
--ORDER BY 3,4

--SELECT *
--FROM SQL_Data_Exploration_Project..Covid_Vaccinations
--ORDER BY 3,4

-- Selecting Usedcase Data

-- Lets Find Total Cases VS Total Deaths to Find Percentage of People Dying

SELECT location, date, total_Cases, total_deaths,       
    CASE 
        WHEN total_cases = 0 THEN 0  -- Handle division by zero
        ELSE (total_deaths * 100.0 / NULLIF(total_cases, 0))  -- Avoid division by zero
    END AS DeathPercentage
FROM SQL_Data_Exploration_Project..Covid_death  
ORDER BY location, date;

-- Looking at the Data Percentage of People Dying in India

SELECT location, date, total_cases,	total_deaths,
	CASE
		WHEN total_cases = 0 THEN 0
		ELSE (total_deaths * 100.0 / NULLIF(total_cases, 0)) 
	END AS DeathPercentage
FROM SQL_Data_Exploration_Project..Covid_death
WHERE location LIKE '%INDIA%'
ORDER BY location, date;

-- Lets Find Total Cases VS Population to Find Percentage of People getting Infected in INDIA

SELECT location, date, total_cases, [population],
	CASE
		WHEN population = 0 THEN 0
		ELSE (total_cases * 100.0 / NULLIF(population, 0)) 
	END AS InfectionRates
FROM SQL_Data_Exploration_Project..Covid_death
WHERE location LIKE '%INDIA%'
ORDER BY location, date; 

-- What Countries has Highest Infection Rates

SELECT location, population, MAX(total_cases) AS HighestNumberInfection,
	CASE
		WHEN population =0 THEN 0
		ELSE MAX(total_cases * 100.0 / NULLIF(population, 0))
	END AS HighestInfectionRates
FROM SQL_Data_Exploration_Project..Covid_death
GROUP BY location, population
ORDER BY HighestInfectionRates DESC;

-- What Countries has Highest Death Counts

SELECT location, population, MAX(total_deaths) AS HighestNumberDeaths
FROM SQL_Data_Exploration_Project..Covid_death
GROUP BY location, population
ORDER BY HighestNumberDeaths DESC;

-- Lets Look how Death Pecentage changes According Time

SELECT date, SUM(new_cases) AS WorldCases, SUM(new_deaths) AS WorldDeathCount,
	CASE
		WHEN new_cases = 0 THEN 0
		ELSE (SUM(new_deaths) * 100)/SUM(new_cases)
	END AS WorldWideDeathPercent
FROM SQL_Data_Exploration_Project..Covid_death
GROUP BY date, new_cases
ORDER BY date;

-- Getting the Vaccination Data

SELECT *
FROM SQL_Data_Exploration_Project..Covid_death dea
JOIN SQL_Data_Exploration_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Population VS Vaccination Done

SELECT dea.Continent, dea.location, dea.date, Population, vac.new_vaccinations
FROM SQL_Data_Exploration_Project..Covid_death dea
JOIN SQL_Data_Exploration_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- Let's Look Total Vaccination Done in Each Coutry

SELECT dea.Continent, dea.location, dea.date, Population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Totalvaccinated
FROM SQL_Data_Exploration_Project..Covid_death dea
JOIN SQL_Data_Exploration_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- Let's Show the how many Vaccinated aginst the total population

DROP TABLE IF EXISTS VaccinationPercent
CREATE TABLE VaccinationPercent
(continent NVARCHAR(50),location NVARCHAR(50), date DATE, population NUMERIC, new_vaccinations NUMERIC, Totalvaccinated NUMERIC )
INSERT INTO VaccinationPercent
SELECT dea.Continent, dea.location, dea.date, Population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Totalvaccinated
FROM SQL_Data_Exploration_Project..Covid_death dea
JOIN SQL_Data_Exploration_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
ORDER BY dea.location, dea.date;

SELECT *, (Totalvaccinated/population)*100
FROM VaccinationPercent

-- Creating View for Visualization
-- no.1
CREATE VIEW DeathPercent AS -- DeathPercentage VS Days
SELECT date, SUM(new_cases) AS WorldCases, SUM(new_deaths) AS WorldDeathCount,
	CASE
		WHEN new_cases = 0 THEN 0
		ELSE (SUM(new_deaths) * 100)/SUM(new_cases)
	END AS WorldWideDeathPercent
FROM SQL_Data_Exploration_Project..Covid_death
GROUP BY date, new_cases
-- no.2
CREATE VIEW IndiaInfection AS -- India's Death Percentage vs Days
SELECT location, date, total_cases, [population],
	CASE
		WHEN population = 0 THEN 0
		ELSE (total_cases * 100.0 / NULLIF(population, 0)) 
	END AS InfectionRates
FROM SQL_Data_Exploration_Project..Covid_death
WHERE location LIKE '%INDIA%'
-- no.3
CREATE VIEW VaccPercent as -- For Population VS Vaccination
SELECT dea.Continent, dea.location, dea.date, Population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Totalvaccinated
FROM SQL_Data_Exploration_Project..Covid_death dea
JOIN SQL_Data_Exploration_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.Continent IS NOT NULL
