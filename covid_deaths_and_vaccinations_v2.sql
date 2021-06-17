--Looking at Cases vs. Deaths
--What percentage of COVID-19 cases resulted in death?
Create View death_rate_by_country AS
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	100 * total_deaths / total_cases AS death_rate_among_infected
FROM covid_deaths
WHERE continent IS NOT NULL;
--ORDER BY 1,2;

--Looking at Total Cases vs. Population
--What percentage of a country's population contracted COVID-19?

Create View infection_rate_by_country AS
SELECT
	location,
	date,
	total_cases,
	population,
	100 * total_cases / population AS infection_rate
FROM covid_deaths
WHERE continent IS NOT NULL;
--ORDER BY 1,2;

--What country has the highest infection rate?
Create View maximum_infection_rate AS
SELECT
	location,
	population,
	MAX(total_cases) AS infection_count,
	MAX(100 * total_cases / population) AS infection_rate_on_20210616
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population;
--ORDER BY 4 DESC;

--What country has the highest death count?
Create View death_count_by_country AS
SELECT
	location,
	MAX(CAST(total_deaths AS INT)) AS total_deathcount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location;
--ORDER BY 2 DESC;

--Let's break things down by continent.
Create View death_count_by_continent AS
SELECT
	location AS continent,
	MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM covid_deaths
WHERE continent IS NULL
	AND location NOT IN ('World', 'International', 'European Union')
GROUP BY location;
--ORDER BY 2 DESC;

--GLOBAL NUMBERS
Create View global_death_rate AS 
SELECT
	SUM(new_cases) AS global_infections,
	SUM(CAST(new_deaths AS INT)) AS global_deaths,
	100 * SUM(CAST(new_deaths AS INT)) / SUM(new_cases) AS death_rate_among_infected
FROM covid_deaths
WHERE 
	location = 'World';

--running total of vaccination count and vaccination percentage per country
Create View percent_population_vaccinated_by_country AS
WITH population_vs_vaccination AS (
	SELECT
		d.continent AS continent,
		d.location AS location,
		d.date AS date,
		d.population AS population,
		v.new_vaccinations AS new_vaccinations,
		SUM(CAST(v.new_vaccinations AS INT)) OVER(PARTITION BY d.location ORDER BY d.date) AS total_vaccinations
	FROM covid_deaths d
	INNER JOIN
		covid_vaccinations v
		ON v.location = d.location
		AND v.date = d.date
	WHERE 
		d.continent IS NOT NULL
	--ORDER BY 2,3
)
SELECT
	*,
	100.0 * (total_vaccinations / population) AS percent_population_vaccinated
FROM population_vs_vaccination;