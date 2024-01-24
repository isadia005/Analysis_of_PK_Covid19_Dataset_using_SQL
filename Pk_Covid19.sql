SELECT *
FROM ['PK COVID-19$'];

--1) Total number of cases, deaths, and recovered:
SELECT SUM(Cases) AS TotalCases, SUM(Deaths) AS TotalDeaths, SUM(Recovered) AS TotalRecovered
FROM ['PK COVID-19$'];

--2) Cases, deaths, and recovered per day:
SELECT Date, Cases, Deaths, Recovered
FROM ['PK COVID-19$']
ORDER BY Date;

--3) Total cases, deaths, and recovered per province:
SELECT Province, SUM(Cases) AS TotalCases, SUM(Deaths) AS TotalDeaths, SUM(Recovered) AS TotalRecovered
FROM ['PK COVID-19$']
GROUP BY Province;

--4) Total cases, deaths, and recovered per city:
SELECT City, SUM(Cases) AS TotalCases, SUM(Deaths) AS TotalDeaths, SUM(Recovered) AS TotalRecovered
FROM ['PK COVID-19$']
GROUP BY City;

--5)Cases with travel history vs. cases without travel history:
SELECT Travel_history, COUNT(*) AS TotalCases
FROM ['PK COVID-19$']
GROUP BY Travel_history;

--6) Top 10 cities with the highest number of cases:
SELECT TOP 10 City, SUM(Cases) AS TotalCases
FROM ['PK COVID-19$']
GROUP BY City
ORDER BY TotalCases DESC;

--7) Daily new cases:
SELECT Date, Cases - LAG(Cases, 1, 0) OVER (ORDER BY Date) AS NewCases
FROM ['PK COVID-19$']
ORDER BY Date;

--8) Average cases, deaths, and recovered per day:
SELECT AVG(Cases) AS AvgCases, AVG(Deaths) AS AvgDeaths, AVG(Recovered) AS AvgRecovered
FROM ['PK COVID-19$'];

--9) Case fatality rate (CFR) per province:
SELECT Province, (SUM(Deaths) / SUM(Cases)) * 100 AS CFR
FROM ['PK COVID-19$']
GROUP BY Province;

--10) Recovery rate per province:
SELECT Province, (SUM(Recovered) / SUM(Cases)) * 100 AS RecoveryRate
FROM ['PK COVID-19$']
GROUP BY Province;

--11) Total cases, deaths, and recovered for the latest date:
SELECT Cases, Deaths, Recovered
FROM ['PK COVID-19$']
WHERE Date = (SELECT MAX(Date) FROM ['PK COVID-19$']);

--12) Cities with zero deaths:
SELECT City
FROM ['PK COVID-19$']
WHERE Deaths = 0;

--13) Cases with travel history in each province:
SELECT Province, Travel_history, COUNT(*) AS CasesWithTravelHistory
FROM ['PK COVID-19$']
WHERE Travel_history IS NOT NULL
GROUP BY Province, Travel_history;

--14) Days with the highest number of cases:
SELECT Date, Cases
FROM ['PK COVID-19$']
WHERE Cases = (SELECT MAX(Cases) FROM ['PK COVID-19$']);

--15) Total cases, deaths, and recovered by month:
SELECT MONTH(Date) AS Month, SUM(Cases) AS TotalCases, SUM(Deaths) AS TotalDeaths, SUM(Recovered) AS TotalRecovered
FROM ['PK COVID-19$']
GROUP BY MONTH(Date);

--16)Cities with a recovery rate above a certain threshold:
SELECT City, 
       CASE 
           WHEN SUM(Cases) = 0 THEN NULL -- or another default value
           ELSE (SUM(Recovered) / NULLIF(SUM(Cases), 0)) * 100
       END AS RecoveryRate
FROM ['PK COVID-19$']
GROUP BY City
HAVING (SUM(Recovered) / NULLIF(SUM(Cases), 0)) * 100 > 80;

--17) Total cases and deaths for a specific province:
SELECT Province, SUM(Cases) AS TotalCases, SUM(Deaths) AS TotalDeaths
FROM ['PK COVID-19$']
WHERE Province = 'Punjab'
GROUP BY Province;

--18) Top 5 provinces with the highest average daily cases:
WITH DailyCases AS (
    SELECT Province, Date, Cases - LAG(Cases, 1, 0) OVER (PARTITION BY Province ORDER BY Date) AS DailyCases
    FROM ['PK COVID-19$']
)
SELECT TOP 5 Province, AVG(DailyCases) AS AvgDailyCases
FROM DailyCases
GROUP BY Province
ORDER BY AvgDailyCases DESC;

--19) Days with a significant increase in cases compared to the previous day:
SELECT Date, DailyIncrease
FROM (
    SELECT Date, Cases - LAG(Cases, 1, 0) OVER (ORDER BY Date) AS DailyIncrease
    FROM ['PK COVID-19$']
) Subquery
WHERE DailyIncrease > 100;

--20) Percentage change in cases, deaths, and recovered compared to the previous day:
SELECT Date, 
       CASE WHEN LAG(Cases, 1, 0) OVER (ORDER BY Date) <> 0
            THEN (Cases - LAG(Cases, 1, 0) OVER (ORDER BY Date)) / LAG(Cases, 1, 0) OVER (ORDER BY Date) * 100
            ELSE NULL
       END AS CasesChange,
       CASE WHEN LAG(Deaths, 1, 0) OVER (ORDER BY Date) <> 0
            THEN (Deaths - LAG(Deaths, 1, 0) OVER (ORDER BY Date)) / NULLIF(LAG(Deaths, 1, 0) OVER (ORDER BY Date), 0) * 100
            ELSE NULL
       END AS DeathsChange,
       CASE WHEN LAG(Recovered, 1, 0) OVER (ORDER BY Date) <> 0
            THEN (Recovered - LAG(Recovered, 1, 0) OVER (ORDER BY Date)) / NULLIF(LAG(Recovered, 1, 0) OVER (ORDER BY Date), 0) * 100
            ELSE NULL
       END AS RecoveredChange
FROM ['PK COVID-19$']
ORDER BY Date;