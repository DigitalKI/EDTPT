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

This query is probably best to get info about rings, it returned 632 systems:
````
SELECT StarSystem, COUNT(DISTINCT BodyName)
FROM Scan S
WHERE length(Rings) > 0
GROUP BY StarSystem
ORDER BY COUNT(DISTINCT BodyName) DESC
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

# Exporting to coriolis.io or EDSY

How data seems to be encoded into a URL:

- first is encoded into a byte array using UTF-8 format
- then it is saved into a compressed file (gzip format)
- the compressed array is converted into a string again using base 64 format
- finally is URL escaped and added to the url as a parameter

The code here was a first attempt at doing so, but it doesn't work, possibly due to how godot compress into a gzip format.
Maybe 7zip can be used to do it via command line.


```
	var shiploadout : String = # data coming from a outfit event
#	print(parse_json(shiploadout))
	var file = File.new()
	file.open("user://save_game.dat", File.WRITE)
	file.close()
	file.open_compressed("user://save_game.dat", File.WRITE, File.COMPRESSION_GZIP)
	file.store_buffer(shiploadout.to_utf8())
	file.close()
	file.open("user://save_game.dat", File.READ)
	var result : String = Marshalls.raw_to_base64(file.get_buffer(file.get_len())).http_escape()
#	print(result)
	OS.clipboard = result
	
	file.close()
```

https://github.com/EDDiscovery/BaseUtilities/blob/c03507247988fa3d21b257e2ef8494c5ab6a5dcb/BaseUtilities/HTTP/HttpUriEncode.cs
https://github.com/EDDiscovery/EDDiscovery/blob/ab86438cf0a2191353436bc56c3ac877f10cb3db/EDDiscovery/UserControls/Overlays/UserControlSysInfo.cs#L521


# Sources of info and data

Data used by the Coriolis front-end and back-end apps:

https://github.com/EDCD/coriolis-data

Elite dangerous data network:

https://github.com/EDCD/EDDN/wiki

Inara API:
https://inara.cz/inara-api/
