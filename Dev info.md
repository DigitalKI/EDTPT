# Queries that I might need

Find all tables containing "SystemAddress" in the schema, useful to find all tables related to certain things such as star system information:
````
SELECT *
FROM sqlite_master
WHERE sql like '%SystemAddress%'
````


Find all bodies inside a star system.
````
SELECT *
FROM Location
WHERE StarSystem like 'Beta Hydri'
AND BodyType IN('Planet')
````

## Find activities inside a system

This finds when you leave out of supercruise, to find all activity within the same area I've found 2 types of events
that determine the end of activity in the same area:

- SupercruiseEnter
- FSDJump
- StartJump (seems to be the most appropriate as int is triggered on any jump type, either supercruise or hyperspace)

But there might be more I'm missing.
All queries below are not taking into account FSDJump, so they need an update.
````
SELECT *
FROM SupercruiseExit
WHERE StarSystem = 'Col 285 Sector KM-V d2-106'
AND BodyType = 'PlanetaryRing'`
````
 
This query should work, takes a supercruise exit, and gets where it is (system and body), then it takes the closest StartJump event after that, between the 2 timestamps everything should be occouring inside the same place:
````
SELECT A.Id, A.SystemAddress, A.Body, A.BodyID, A.timestamp as entered, B.Id, B.timestamp as exited
FROM SupercruiseExit as A
INNER JOIN StartJump as B
ON b.timestamp > A.timestamp
WHERE A.SystemAddress = 3652643195227
GROUP BY A.Id, A.BodyID
HAVING MIN(B.timestamp) = b.timestamp
````

union of the 2 tables for easier check on validity of the above:
````
SELECT *
FROM (SELECT Id, FileheaderId, Body, timestamp
FROM SupercruiseExit
WHERE StarSystem = 'Col 285 Sector KM-V d2-106'
AND BodyID = 28
UNION
SELECT Id, FileheaderId, '' as Body, timestamp
FROM SupercruiseEntry)
order by timestamp desc
````


## Find Systems with rings
TRying to make a query to get rings from Scan table, as it has more data, apparentyl.

This returns 19 systems with rings:
````
SELECT SystemAddress, StarSystem, COUNT(BodyId)
FROM Scan S
WHERE BodyName LIKE '% Ring'
GROUP BY SystemAddress, StarSystem
````

This only 2, somethins is wrong.

````
SELECT F.*, COUNT(DISTINCT S.BodyID) Rings
FROM FSDJump F
LEFT JOIN Scan S
ON (F.SystemAddress = S.SystemAddress AND S.BodyName LIKE '% Ring')
GROUP BY F.SystemAddress
HAVING MAX(F.timestamp)
````

SELECT F.*
FROM FSDJump F
LEFT JOIN Scan S
ON F.SystemAddress = S.SystemAddress
GROUP BY F.SystemAddress
HAVING MAX(F.timestamp)