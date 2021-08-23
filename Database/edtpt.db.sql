BEGIN TRANSACTION;
DROP TABLE IF EXISTS "Commander";
CREATE TABLE IF NOT EXISTS "Commander" (
	"Id"	INTEGER NOT NULL UNIQUE,
	"FID"	INTEGER NOT NULL,
	"Name"	TEXT NOT NULL,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Fileheader";
CREATE TABLE IF NOT EXISTS "Fileheader" (
	"Id"	INTEGER NOT NULL UNIQUE,
	"part"	INTEGER NOT NULL,
	"language"	TEXT NOT NULL,
	"Odyssey"	INTEGER NOT NULL,
	"gameversion"	TEXT NOT NULL,
	"build"	TEXT NOT NULL,
	"filename"	TEXT NOT NULL,
	PRIMARY KEY("Id")
);
DROP TABLE IF EXISTS "event_types";
CREATE TABLE IF NOT EXISTS "event_types" (
	"Id"	INTEGER NOT NULL UNIQUE,
	"event_type"	TEXT NOT NULL,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Backpack";
CREATE TABLE IF NOT EXISTS "Backpack" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Items"	text,
	"Components"	text,
	"Consumables"	text,
	"Data"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Music";
CREATE TABLE IF NOT EXISTS "Music" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MusicTrack"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "NewCommander";
CREATE TABLE IF NOT EXISTS "NewCommander" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"FID"	text,
	"Name"	text,
	"Package"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Materials";
CREATE TABLE IF NOT EXISTS "Materials" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Raw"	text,
	"Manufactured"	text,
	"Encoded"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "LoadGame";
CREATE TABLE IF NOT EXISTS "LoadGame" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"FID"	text,
	"Commander"	text,
	"Horizons"	text,
	"Ship"	text,
	"ShipID"	text,
	"ShipName"	text,
	"ShipIdent"	text,
	"FuelLevel"	numeric,
	"FuelCapacity"	numeric,
	"GameMode"	text,
	"Credits"	numeric,
	"Loan"	text,
	"Ship_Localised"	text,
	"StartLanded"	text,
	"Odyssey"	text,
	"Group"	text,
	"language"	text,
	"gameversion"	text,
	"build"	text,
	"StartDead"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Rank";
CREATE TABLE IF NOT EXISTS "Rank" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Combat"	text,
	"Trade"	text,
	"Explore"	text,
	"Empire"	text,
	"Federation"	text,
	"CQC"	text,
	"Soldier"	text,
	"Exobiologist"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Progress";
CREATE TABLE IF NOT EXISTS "Progress" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Combat"	text,
	"Trade"	text,
	"Explore"	text,
	"Empire"	text,
	"Federation"	text,
	"CQC"	text,
	"Soldier"	text,
	"Exobiologist"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Reputation";
CREATE TABLE IF NOT EXISTS "Reputation" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Federation"	numeric,
	"Empire"	numeric,
	"Alliance"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "EngineerProgress";
CREATE TABLE IF NOT EXISTS "EngineerProgress" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Engineers"	text,
	"Engineer"	text,
	"EngineerID"	numeric,
	"Progress"	text,
	"Rank"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Location";
CREATE TABLE IF NOT EXISTS "Location" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Docked"	text,
	"StationName"	text,
	"StationType"	text,
	"MarketID"	numeric,
	"StationFaction"	text,
	"StationGovernment"	text,
	"StationGovernment_Localised"	text,
	"StationAllegiance"	text,
	"StationServices"	text,
	"StationEconomy"	text,
	"StationEconomy_Localised"	text,
	"StationEconomies"	text,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"StarPos"	text,
	"SystemAllegiance"	text,
	"SystemEconomy"	text,
	"SystemEconomy_Localised"	text,
	"SystemSecondEconomy"	text,
	"SystemSecondEconomy_Localised"	text,
	"SystemGovernment"	text,
	"SystemGovernment_Localised"	text,
	"SystemSecurity"	text,
	"SystemSecurity_Localised"	text,
	"Population"	numeric,
	"Body"	text,
	"BodyID"	numeric,
	"BodyType"	text,
	"Factions"	text,
	"SystemFaction"	text,
	"Conflicts"	text,
	"Latitude"	numeric,
	"Longitude"	numeric,
	"Powers"	text,
	"PowerplayState"	text,
	"DistFromStarLS"	numeric,
	"Taxi"	text,
	"Multicrew"	text,
	"OnFoot"	text,
	"InSRV"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Missions";
CREATE TABLE IF NOT EXISTS "Missions" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Active"	text,
	"Failed"	text,
	"Complete"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Docked";
CREATE TABLE IF NOT EXISTS "Docked" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"StationName"	text,
	"StationType"	text,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"MarketID"	numeric,
	"StationFaction"	text,
	"StationGovernment"	text,
	"StationGovernment_Localised"	text,
	"StationAllegiance"	text,
	"StationServices"	text,
	"StationEconomy"	text,
	"StationEconomy_Localised"	text,
	"StationEconomies"	text,
	"DistFromStarLS"	numeric,
	"ActiveFine"	text,
	"Taxi"	text,
	"Multicrew"	text,
	"Wanted"	text,
	"CockpitBreach"	text,
	"LandingPads"	text,
	"StationState"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Loadout";
CREATE TABLE IF NOT EXISTS "Loadout" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Ship"	text,
	"ShipID"	text,
	"ShipName"	text,
	"ShipIdent"	text,
	"HullHealth"	numeric,
	"UnladenMass"	numeric,
	"CargoCapacity"	numeric,
	"MaxJumpRange"	numeric,
	"FuelCapacity"	text,
	"Rebuy"	text,
	"Modules"	text,
	"ModulesValue"	numeric,
	"HullValue"	numeric,
	"Hot"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Cargo";
CREATE TABLE IF NOT EXISTS "Cargo" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Vessel"	text,
	"Count"	text,
	"Inventory"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Statistics";
CREATE TABLE IF NOT EXISTS "Statistics" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Bank_Account"	text,
	"Combat"	text,
	"Crime"	text,
	"Smuggling"	text,
	"Trading"	text,
	"Mining"	text,
	"Exploration"	text,
	"Passengers"	text,
	"Search_And_Rescue"	text,
	"Crafting"	text,
	"Crew"	text,
	"Multicrew"	text,
	"Material_Trader_Stats"	text,
	"TG_ENCOUNTERS"	text,
	"Exobiology"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ReceiveText";
CREATE TABLE IF NOT EXISTS "ReceiveText" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"From"	text,
	"Message"	text,
	"Channel"	text,
	"From_Localised"	text,
	"Message_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SendText";
CREATE TABLE IF NOT EXISTS "SendText" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"To"	text,
	"Message"	text,
	"Sent"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ModuleInfo";
CREATE TABLE IF NOT EXISTS "ModuleInfo" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Shutdown";
CREATE TABLE IF NOT EXISTS "Shutdown" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "NavRoute";
CREATE TABLE IF NOT EXISTS "NavRoute" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "FSDTarget";
CREATE TABLE IF NOT EXISTS "FSDTarget" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"SystemAddress"	numeric,
	"StarClass"	text,
	"RemainingJumpsInRoute"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Undocked";
CREATE TABLE IF NOT EXISTS "Undocked" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"StationName"	text,
	"StationType"	text,
	"MarketID"	numeric,
	"Taxi"	text,
	"Multicrew"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Scanned";
CREATE TABLE IF NOT EXISTS "Scanned" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ScanType"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "StartJump";
CREATE TABLE IF NOT EXISTS "StartJump" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"JumpType"	text,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"StarClass"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "FSDJump";
CREATE TABLE IF NOT EXISTS "FSDJump" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"StarPos"	text,
	"SystemAllegiance"	text,
	"SystemEconomy"	text,
	"SystemEconomy_Localised"	text,
	"SystemSecondEconomy"	text,
	"SystemSecondEconomy_Localised"	text,
	"SystemGovernment"	text,
	"SystemGovernment_Localised"	text,
	"SystemSecurity"	text,
	"SystemSecurity_Localised"	text,
	"Population"	numeric,
	"Body"	text,
	"BodyID"	text,
	"BodyType"	text,
	"JumpDist"	numeric,
	"FuelUsed"	numeric,
	"FuelLevel"	numeric,
	"Factions"	text,
	"SystemFaction"	text,
	"Conflicts"	text,
	"Powers"	text,
	"PowerplayState"	text,
	"BoostUsed"	numeric,
	"Taxi"	text,
	"Multicrew"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ShipTargeted";
CREATE TABLE IF NOT EXISTS "ShipTargeted" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"TargetLocked"	text,
	"Ship"	text,
	"ScanStage"	text,
	"PilotName"	text,
	"PilotName_Localised"	text,
	"PilotRank"	text,
	"ShieldHealth"	numeric,
	"HullHealth"	numeric,
	"LegalStatus"	text,
	"Ship_Localised"	text,
	"Faction"	text,
	"Bounty"	numeric,
	"Power"	text,
	"SquadronID"	text,
	"Subsystem"	text,
	"Subsystem_Localised"	text,
	"SubsystemHealth"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SupercruiseExit";
CREATE TABLE IF NOT EXISTS "SupercruiseExit" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"Body"	text,
	"BodyID"	numeric,
	"BodyType"	text,
	"Taxi"	text,
	"Multicrew"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "FSSSignalDiscovered";
CREATE TABLE IF NOT EXISTS "FSSSignalDiscovered" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SystemAddress"	numeric,
	"SignalName"	text,
	"SignalName_Localised"	text,
	"IsStation"	text,
	"USSType"	text,
	"USSType_Localised"	text,
	"SpawningState"	text,
	"SpawningFaction"	text,
	"ThreatLevel"	numeric,
	"TimeRemaining"	numeric,
	"SpawningState_Localised"	text,
	"SpawningFaction_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DockingDenied";
CREATE TABLE IF NOT EXISTS "DockingDenied" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Reason"	text,
	"MarketID"	numeric,
	"StationName"	text,
	"StationType"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DockingRequested";
CREATE TABLE IF NOT EXISTS "DockingRequested" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"StationName"	text,
	"StationType"	text,
	"LandingPads"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DockingGranted";
CREATE TABLE IF NOT EXISTS "DockingGranted" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"LandingPad"	numeric,
	"MarketID"	numeric,
	"StationName"	text,
	"StationType"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MissionAccepted";
CREATE TABLE IF NOT EXISTS "MissionAccepted" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Faction"	text,
	"Name"	text,
	"LocalisedName"	text,
	"Commodity"	text,
	"Commodity_Localised"	text,
	"Count"	numeric,
	"DestinationSystem"	text,
	"DestinationStation"	text,
	"Expiry"	text,
	"Wing"	text,
	"Influence"	text,
	"Reputation"	text,
	"Reward"	numeric,
	"MissionID"	numeric,
	"TargetFaction"	text,
	"Donation"	text,
	"PassengerCount"	numeric,
	"PassengerVIPs"	text,
	"PassengerWanted"	text,
	"PassengerType"	text,
	"TargetType"	text,
	"TargetType_Localised"	text,
	"KillCount"	numeric,
	"Target"	text,
	"Target_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Market";
CREATE TABLE IF NOT EXISTS "Market" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"StationName"	text,
	"StationType"	text,
	"StarSystem"	text,
	"CarrierDockingAccess"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CommitCrime";
CREATE TABLE IF NOT EXISTS "CommitCrime" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"CrimeType"	text,
	"Faction"	text,
	"Fine"	numeric,
	"Victim"	text,
	"Bounty"	numeric,
	"Victim_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ReservoirReplenished";
CREATE TABLE IF NOT EXISTS "ReservoirReplenished" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"FuelMain"	numeric,
	"FuelReservoir"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "PayFines";
CREATE TABLE IF NOT EXISTS "PayFines" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Amount"	numeric,
	"AllFines"	text,
	"ShipID"	text,
	"BrokerPercentage"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Outfitting";
CREATE TABLE IF NOT EXISTS "Outfitting" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"StationName"	text,
	"StarSystem"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "StoredModules";
CREATE TABLE IF NOT EXISTS "StoredModules" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"StationName"	text,
	"StarSystem"	text,
	"Items"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ModuleBuy";
CREATE TABLE IF NOT EXISTS "ModuleBuy" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Slot"	text,
	"BuyItem"	text,
	"BuyItem_Localised"	text,
	"MarketID"	numeric,
	"BuyPrice"	numeric,
	"Ship"	text,
	"ShipID"	text,
	"StoredItem"	text,
	"StoredItem_Localised"	text,
	"SellItem"	text,
	"SellItem_Localised"	text,
	"SellPrice"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ModuleSell";
CREATE TABLE IF NOT EXISTS "ModuleSell" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"Slot"	text,
	"SellItem"	text,
	"SellItem_Localised"	text,
	"SellPrice"	text,
	"Ship"	text,
	"ShipID"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MarketBuy";
CREATE TABLE IF NOT EXISTS "MarketBuy" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"Type"	text,
	"Count"	numeric,
	"BuyPrice"	numeric,
	"TotalCost"	numeric,
	"Type_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "RefuelAll";
CREATE TABLE IF NOT EXISTS "RefuelAll" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Cost"	numeric,
	"Amount"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CargoDepot";
CREATE TABLE IF NOT EXISTS "CargoDepot" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MissionID"	numeric,
	"UpdateType"	text,
	"CargoType"	text,
	"Count"	numeric,
	"StartMarketID"	text,
	"EndMarketID"	numeric,
	"ItemsCollected"	text,
	"ItemsDelivered"	numeric,
	"TotalItemsToDeliver"	numeric,
	"Progress"	text,
	"CargoType_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Promotion";
CREATE TABLE IF NOT EXISTS "Promotion" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Trade"	numeric,
	"Explore"	numeric,
	"Combat"	numeric,
	"Empire"	numeric,
	"Federation"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MissionCompleted";
CREATE TABLE IF NOT EXISTS "MissionCompleted" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Faction"	text,
	"Name"	text,
	"MissionID"	numeric,
	"Commodity"	text,
	"Commodity_Localised"	text,
	"Count"	numeric,
	"DestinationSystem"	text,
	"DestinationStation"	text,
	"Reward"	numeric,
	"FactionEffects"	text,
	"TargetFaction"	text,
	"Donation"	text,
	"Donated"	numeric,
	"NewDestinationSystem"	text,
	"MaterialsReward"	text,
	"CommodityReward"	text,
	"TargetType"	text,
	"TargetType_Localised"	text,
	"KillCount"	numeric,
	"NewDestinationStation"	text,
	"Target"	text,
	"Target_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Shipyard";
CREATE TABLE IF NOT EXISTS "Shipyard" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"StationName"	text,
	"StarSystem"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "StoredShips";
CREATE TABLE IF NOT EXISTS "StoredShips" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"StationName"	text,
	"MarketID"	numeric,
	"StarSystem"	text,
	"ShipsHere"	text,
	"ShipsRemote"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Scan";
CREATE TABLE IF NOT EXISTS "Scan" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ScanType"	text,
	"BodyName"	text,
	"BodyID"	numeric,
	"Parents"	text,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"DistanceFromArrivalLS"	numeric,
	"WasDiscovered"	text,
	"WasMapped"	text,
	"StarType"	text,
	"Subclass"	numeric,
	"StellarMass"	numeric,
	"Radius"	numeric,
	"AbsoluteMagnitude"	numeric,
	"Age_MY"	numeric,
	"SurfaceTemperature"	numeric,
	"Luminosity"	text,
	"RotationPeriod"	numeric,
	"AxialTilt"	text,
	"Rings"	text,
	"TidalLock"	text,
	"TerraformState"	text,
	"PlanetClass"	text,
	"Atmosphere"	text,
	"AtmosphereType"	text,
	"Volcanism"	text,
	"MassEM"	numeric,
	"SurfaceGravity"	numeric,
	"SurfacePressure"	numeric,
	"Landable"	text,
	"Materials"	text,
	"Composition"	text,
	"SemiMajorAxis"	numeric,
	"Eccentricity"	numeric,
	"OrbitalInclination"	numeric,
	"Periapsis"	numeric,
	"OrbitalPeriod"	numeric,
	"AtmosphereComposition"	text,
	"ReserveLevel"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CodexEntry";
CREATE TABLE IF NOT EXISTS "CodexEntry" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"EntryID"	numeric,
	"Name"	text,
	"Name_Localised"	text,
	"SubCategory"	text,
	"SubCategory_Localised"	text,
	"Category"	text,
	"Category_Localised"	text,
	"Region"	text,
	"Region_Localised"	text,
	"System"	text,
	"SystemAddress"	numeric,
	"IsNewEntry"	text,
	"NearestDestination"	text,
	"NearestDestination_Localised"	text,
	"VoucherAmount"	numeric,
	"Latitude"	numeric,
	"Longitude"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SupercruiseEntry";
CREATE TABLE IF NOT EXISTS "SupercruiseEntry" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"Taxi"	text,
	"Multicrew"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MarketSell";
CREATE TABLE IF NOT EXISTS "MarketSell" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"Type"	text,
	"Type_Localised"	text,
	"Count"	numeric,
	"SellPrice"	numeric,
	"TotalSale"	numeric,
	"AvgPricePaid"	numeric,
	"StolenGoods"	text,
	"BlackMarket"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "HeatWarning";
CREATE TABLE IF NOT EXISTS "HeatWarning" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ApproachSettlement";
CREATE TABLE IF NOT EXISTS "ApproachSettlement" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"MarketID"	numeric,
	"SystemAddress"	numeric,
	"BodyID"	numeric,
	"BodyName"	text,
	"Latitude"	numeric,
	"Longitude"	numeric,
	"Name_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ApproachBody";
CREATE TABLE IF NOT EXISTS "ApproachBody" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"Body"	text,
	"BodyID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "LeaveBody";
CREATE TABLE IF NOT EXISTS "LeaveBody" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"Body"	text,
	"BodyID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "RepairAll";
CREATE TABLE IF NOT EXISTS "RepairAll" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Cost"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ShipyardBuy";
CREATE TABLE IF NOT EXISTS "ShipyardBuy" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ShipType"	text,
	"ShipPrice"	numeric,
	"SellOldShip"	text,
	"SellShipID"	text,
	"SellPrice"	numeric,
	"MarketID"	numeric,
	"ShipType_Localised"	text,
	"StoreOldShip"	text,
	"StoreShipID"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ShipyardNew";
CREATE TABLE IF NOT EXISTS "ShipyardNew" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ShipType"	text,
	"NewShipID"	text,
	"ShipType_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ModuleRetrieve";
CREATE TABLE IF NOT EXISTS "ModuleRetrieve" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"Slot"	text,
	"RetrievedItem"	text,
	"RetrievedItem_Localised"	text,
	"Ship"	text,
	"ShipID"	text,
	"Hot"	text,
	"EngineerModifications"	text,
	"Level"	numeric,
	"Quality"	numeric,
	"SwapOutItem"	text,
	"SwapOutItem_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MissionFailed";
CREATE TABLE IF NOT EXISTS "MissionFailed" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"MissionID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "FSSDiscoveryScan";
CREATE TABLE IF NOT EXISTS "FSSDiscoveryScan" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Progress"	numeric,
	"BodyCount"	numeric,
	"NonBodyCount"	numeric,
	"SystemName"	text,
	"SystemAddress"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MaterialDiscovered";
CREATE TABLE IF NOT EXISTS "MaterialDiscovered" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Category"	text,
	"Name"	text,
	"Name_Localised"	text,
	"DiscoveryNumber"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MaterialCollected";
CREATE TABLE IF NOT EXISTS "MaterialCollected" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Category"	text,
	"Name"	text,
	"Name_Localised"	text,
	"Count"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "FSSAllBodiesFound";
CREATE TABLE IF NOT EXISTS "FSSAllBodiesFound" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SystemName"	text,
	"SystemAddress"	numeric,
	"Count"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SellExplorationData";
CREATE TABLE IF NOT EXISTS "SellExplorationData" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Systems"	text,
	"Discovered"	text,
	"BaseValue"	numeric,
	"Bonus"	text,
	"TotalEarnings"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MultiSellExplorationData";
CREATE TABLE IF NOT EXISTS "MultiSellExplorationData" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Discovered"	text,
	"BaseValue"	numeric,
	"Bonus"	text,
	"TotalEarnings"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "FuelScoop";
CREATE TABLE IF NOT EXISTS "FuelScoop" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Scooped"	numeric,
	"Total"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Screenshot";
CREATE TABLE IF NOT EXISTS "Screenshot" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Filename"	text,
	"Width"	numeric,
	"Height"	numeric,
	"System"	text,
	"Body"	text,
	"Latitude"	numeric,
	"Longitude"	numeric,
	"Heading"	text,
	"Altitude"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "EscapeInterdiction";
CREATE TABLE IF NOT EXISTS "EscapeInterdiction" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Interdictor"	text,
	"IsPlayer"	text,
	"Interdictor_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "USSDrop";
CREATE TABLE IF NOT EXISTS "USSDrop" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"USSType"	text,
	"USSType_Localised"	text,
	"USSThreat"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SAAScanComplete";
CREATE TABLE IF NOT EXISTS "SAAScanComplete" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"BodyName"	text,
	"SystemAddress"	numeric,
	"BodyID"	numeric,
	"ProbesUsed"	numeric,
	"EfficiencyTarget"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "UnderAttack";
CREATE TABLE IF NOT EXISTS "UnderAttack" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Target"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "HullDamage";
CREATE TABLE IF NOT EXISTS "HullDamage" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Health"	numeric,
	"PlayerPilot"	text,
	"Fighter"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Died";
CREATE TABLE IF NOT EXISTS "Died" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"KillerName"	text,
	"KillerShip"	text,
	"KillerRank"	text,
	"KillerName_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Resurrect";
CREATE TABLE IF NOT EXISTS "Resurrect" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Option"	text,
	"Cost"	numeric,
	"Bankrupt"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Touchdown";
CREATE TABLE IF NOT EXISTS "Touchdown" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"PlayerControlled"	text,
	"Latitude"	numeric,
	"Longitude"	numeric,
	"NearestDestination"	text,
	"NearestDestination_Localised"	text,
	"Taxi"	text,
	"Multicrew"	text,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"Body"	text,
	"BodyID"	numeric,
	"OnStation"	text,
	"OnPlanet"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "LaunchSRV";
CREATE TABLE IF NOT EXISTS "LaunchSRV" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Loadout"	text,
	"ID_ID"	numeric,
	"PlayerControlled"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DockSRV";
CREATE TABLE IF NOT EXISTS "DockSRV" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ID_ID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Liftoff";
CREATE TABLE IF NOT EXISTS "Liftoff" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"PlayerControlled"	text,
	"Latitude"	numeric,
	"Longitude"	numeric,
	"NearestDestination"	text,
	"NearestDestination_Localised"	text,
	"Taxi"	text,
	"Multicrew"	text,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"Body"	text,
	"BodyID"	numeric,
	"OnStation"	text,
	"OnPlanet"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SAASignalsFound";
CREATE TABLE IF NOT EXISTS "SAASignalsFound" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"BodyName"	text,
	"SystemAddress"	numeric,
	"BodyID"	numeric,
	"Signals"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "BuyExplorationData";
CREATE TABLE IF NOT EXISTS "BuyExplorationData" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"System"	text,
	"Cost"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CollectCargo";
CREATE TABLE IF NOT EXISTS "CollectCargo" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Type"	text,
	"Type_Localised"	text,
	"Stolen"	text,
	"MissionID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "AfmuRepairs";
CREATE TABLE IF NOT EXISTS "AfmuRepairs" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Module"	text,
	"Module_Localised"	text,
	"FullyRepaired"	text,
	"Health"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "BuyAmmo";
CREATE TABLE IF NOT EXISTS "BuyAmmo" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Cost"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DockingTimeout";
CREATE TABLE IF NOT EXISTS "DockingTimeout" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"StationName"	text,
	"StationType"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "RedeemVoucher";
CREATE TABLE IF NOT EXISTS "RedeemVoucher" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Type"	text,
	"Amount"	numeric,
	"Faction"	text,
	"Factions"	text,
	"BrokerPercentage"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DataScanned";
CREATE TABLE IF NOT EXISTS "DataScanned" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Type"	text,
	"Type_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DatalinkScan";
CREATE TABLE IF NOT EXISTS "DatalinkScan" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Message"	text,
	"Message_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DatalinkVoucher";
CREATE TABLE IF NOT EXISTS "DatalinkVoucher" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Reward"	numeric,
	"VictimFaction"	text,
	"PayeeFaction"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Friends";
CREATE TABLE IF NOT EXISTS "Friends" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Status"	text,
	"Name"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CrewMemberJoins";
CREATE TABLE IF NOT EXISTS "CrewMemberJoins" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Crew"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Interdicted";
CREATE TABLE IF NOT EXISTS "Interdicted" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Submitted"	text,
	"Interdictor"	text,
	"IsPlayer"	text,
	"Faction"	text,
	"Interdictor_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "EndCrewSession";
CREATE TABLE IF NOT EXISTS "EndCrewSession" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"OnCrime"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "EngineerContribution";
CREATE TABLE IF NOT EXISTS "EngineerContribution" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Engineer"	text,
	"EngineerID"	numeric,
	"Type"	text,
	"Commodity"	text,
	"Commodity_Localised"	text,
	"Quantity"	numeric,
	"TotalQuantity"	numeric,
	"Material"	text,
	"Material_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "EngineerCraft";
CREATE TABLE IF NOT EXISTS "EngineerCraft" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Slot"	text,
	"Module"	text,
	"Ingredients"	text,
	"Engineer"	text,
	"EngineerID"	numeric,
	"BlueprintID"	numeric,
	"BlueprintName"	text,
	"Level"	numeric,
	"Quality"	numeric,
	"Modifiers"	text,
	"ApplyExperimentalEffect"	text,
	"ExperimentalEffect"	text,
	"ExperimentalEffect_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ShipyardTransfer";
CREATE TABLE IF NOT EXISTS "ShipyardTransfer" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ShipType"	text,
	"ShipType_Localised"	text,
	"ShipID"	text,
	"System"	text,
	"ShipMarketID"	numeric,
	"Distance"	numeric,
	"TransferPrice"	numeric,
	"TransferTime"	numeric,
	"MarketID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SetUserShipName";
CREATE TABLE IF NOT EXISTS "SetUserShipName" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Ship"	text,
	"ShipID"	numeric,
	"UserShipName"	text,
	"UserShipId"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "WingJoin";
CREATE TABLE IF NOT EXISTS "WingJoin" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Others"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "WingAdd";
CREATE TABLE IF NOT EXISTS "WingAdd" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "WingLeave";
CREATE TABLE IF NOT EXISTS "WingLeave" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Repair";
CREATE TABLE IF NOT EXISTS "Repair" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Item"	text,
	"Cost"	numeric,
	"Items"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "PowerplayJoin";
CREATE TABLE IF NOT EXISTS "PowerplayJoin" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Power"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Powerplay";
CREATE TABLE IF NOT EXISTS "Powerplay" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Power"	text,
	"Rank"	text,
	"Merits"	text,
	"Votes"	text,
	"TimePledged"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "BuyDrones";
CREATE TABLE IF NOT EXISTS "BuyDrones" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Type"	text,
	"Count"	numeric,
	"BuyPrice"	numeric,
	"TotalCost"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MaterialTrade";
CREATE TABLE IF NOT EXISTS "MaterialTrade" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"TraderType"	text,
	"Paid"	text,
	"Received"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "LaunchDrone";
CREATE TABLE IF NOT EXISTS "LaunchDrone" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Type"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Bounty";
CREATE TABLE IF NOT EXISTS "Bounty" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Target"	text,
	"Reward"	text,
	"VictimFaction"	text,
	"VictimFaction_Localised"	text,
	"Rewards"	text,
	"Target_Localised"	text,
	"TotalReward"	numeric,
	"SharedWithOthers"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "EjectCargo";
CREATE TABLE IF NOT EXISTS "EjectCargo" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Type"	text,
	"Type_Localised"	text,
	"Count"	numeric,
	"Abandoned"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Synthesis";
CREATE TABLE IF NOT EXISTS "Synthesis" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"Materials"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "TechnologyBroker";
CREATE TABLE IF NOT EXISTS "TechnologyBroker" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"BrokerType"	text,
	"MarketID"	numeric,
	"ItemsUnlocked"	text,
	"Commodities"	text,
	"Materials"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ModuleSwap";
CREATE TABLE IF NOT EXISTS "ModuleSwap" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"FromSlot"	text,
	"ToSlot"	text,
	"FromItem"	text,
	"FromItem_Localised"	text,
	"ToItem"	text,
	"Ship"	text,
	"ShipID"	numeric,
	"ToItem_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "PayBounties";
CREATE TABLE IF NOT EXISTS "PayBounties" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Amount"	numeric,
	"Faction"	text,
	"Faction_Localised"	text,
	"ShipID"	numeric,
	"BrokerPercentage"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "PowerplaySalary";
CREATE TABLE IF NOT EXISTS "PowerplaySalary" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Power"	text,
	"Amount"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SRVDestroyed";
CREATE TABLE IF NOT EXISTS "SRVDestroyed" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ID_ID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "VehicleSwitch";
CREATE TABLE IF NOT EXISTS "VehicleSwitch" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"To"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "RestockVehicle";
CREATE TABLE IF NOT EXISTS "RestockVehicle" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Type"	text,
	"Loadout"	text,
	"Cost"	numeric,
	"Count"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "JetConeBoost";
CREATE TABLE IF NOT EXISTS "JetConeBoost" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"BoostValue"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ModuleStore";
CREATE TABLE IF NOT EXISTS "ModuleStore" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"Slot"	text,
	"StoredItem"	text,
	"StoredItem_Localised"	text,
	"Ship"	text,
	"ShipID"	numeric,
	"Hot"	text,
	"EngineerModifications"	text,
	"Level"	numeric,
	"Quality"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "WingInvite";
CREATE TABLE IF NOT EXISTS "WingInvite" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "HeatDamage";
CREATE TABLE IF NOT EXISTS "HeatDamage" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DiscoveryScan";
CREATE TABLE IF NOT EXISTS "DiscoveryScan" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SystemAddress"	numeric,
	"Bodies"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "AppliedToSquadron";
CREATE TABLE IF NOT EXISTS "AppliedToSquadron" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SquadronName"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "JoinedSquadron";
CREATE TABLE IF NOT EXISTS "JoinedSquadron" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SquadronName"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SquadronStartup";
CREATE TABLE IF NOT EXISTS "SquadronStartup" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SquadronName"	text,
	"CurrentRank"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "JoinACrew";
CREATE TABLE IF NOT EXISTS "JoinACrew" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Captain"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ChangeCrewRole";
CREATE TABLE IF NOT EXISTS "ChangeCrewRole" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Role"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "QuitACrew";
CREATE TABLE IF NOT EXISTS "QuitACrew" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Captain"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ProspectedAsteroid";
CREATE TABLE IF NOT EXISTS "ProspectedAsteroid" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Materials"	text,
	"Content"	text,
	"Content_Localised"	text,
	"Remaining"	numeric,
	"MotherlodeMaterial"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MiningRefined";
CREATE TABLE IF NOT EXISTS "MiningRefined" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Type"	text,
	"Type_Localised"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ShipyardSwap";
CREATE TABLE IF NOT EXISTS "ShipyardSwap" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ShipType"	text,
	"ShipType_Localised"	text,
	"ShipID"	numeric,
	"StoreOldShip"	text,
	"StoreShipID"	numeric,
	"MarketID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "NavBeaconScan";
CREATE TABLE IF NOT EXISTS "NavBeaconScan" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SystemAddress"	numeric,
	"NumBodies"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "KickCrewMember";
CREATE TABLE IF NOT EXISTS "KickCrewMember" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Crew"	text,
	"OnCrime"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "PowerplayCollect";
CREATE TABLE IF NOT EXISTS "PowerplayCollect" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Power"	text,
	"Type"	text,
	"Type_Localised"	text,
	"Count"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "PowerplayFastTrack";
CREATE TABLE IF NOT EXISTS "PowerplayFastTrack" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Power"	text,
	"Cost"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "PowerplayDeliver";
CREATE TABLE IF NOT EXISTS "PowerplayDeliver" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Power"	text,
	"Type"	text,
	"Type_Localised"	text,
	"Count"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CrewHire";
CREATE TABLE IF NOT EXISTS "CrewHire" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"CrewID"	numeric,
	"Faction"	text,
	"Cost"	numeric,
	"CombatRank"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CrewAssign";
CREATE TABLE IF NOT EXISTS "CrewAssign" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"CrewID"	numeric,
	"Role"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CrewFire";
CREATE TABLE IF NOT EXISTS "CrewFire" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"CrewID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "NpcCrewPaidWage";
CREATE TABLE IF NOT EXISTS "NpcCrewPaidWage" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"NpcCrewName"	text,
	"NpcCrewId"	numeric,
	"Amount"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ModuleSellRemote";
CREATE TABLE IF NOT EXISTS "ModuleSellRemote" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"StorageSlot"	numeric,
	"SellItem"	text,
	"SellItem_Localised"	text,
	"ServerId"	numeric,
	"SellPrice"	numeric,
	"Ship"	text,
	"ShipID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "FetchRemoteModule";
CREATE TABLE IF NOT EXISTS "FetchRemoteModule" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"StorageSlot"	numeric,
	"StoredItem"	text,
	"StoredItem_Localised"	text,
	"ServerId"	numeric,
	"TransferCost"	numeric,
	"TransferTime"	numeric,
	"Ship"	text,
	"ShipID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MassModuleStore";
CREATE TABLE IF NOT EXISTS "MassModuleStore" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"Ship"	text,
	"ShipID"	numeric,
	"Items"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "LaunchFighter";
CREATE TABLE IF NOT EXISTS "LaunchFighter" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Loadout"	text,
	"ID_ID"	numeric,
	"PlayerControlled"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DockFighter";
CREATE TABLE IF NOT EXISTS "DockFighter" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ID_ID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MissionRedirected";
CREATE TABLE IF NOT EXISTS "MissionRedirected" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MissionID"	numeric,
	"Name"	text,
	"NewDestinationStation"	text,
	"NewDestinationSystem"	text,
	"OldDestinationStation"	text,
	"OldDestinationSystem"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "MissionAbandoned";
CREATE TABLE IF NOT EXISTS "MissionAbandoned" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"MissionID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SystemsShutdown";
CREATE TABLE IF NOT EXISTS "SystemsShutdown" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ShipLockerMaterials";
CREATE TABLE IF NOT EXISTS "ShipLockerMaterials" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Items"	text,
	"Components"	text,
	"Consumables"	text,
	"Data"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Disembark";
CREATE TABLE IF NOT EXISTS "Disembark" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SRV"	text,
	"Taxi"	text,
	"Multicrew"	text,
	"ID_ID"	numeric,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"Body"	text,
	"BodyID"	numeric,
	"OnStation"	text,
	"OnPlanet"	text,
	"StationName"	text,
	"StationType"	text,
	"MarketID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SuitLoadout";
CREATE TABLE IF NOT EXISTS "SuitLoadout" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SuitID"	numeric,
	"SuitName"	text,
	"SuitName_Localised"	text,
	"LoadoutID"	numeric,
	"LoadoutName"	text,
	"Modules"	text,
	"SuitMods"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "BuySuit";
CREATE TABLE IF NOT EXISTS "BuySuit" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"Name_Localised"	text,
	"Price"	numeric,
	"SuitID"	numeric,
	"SuitMods"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "BuyWeapon";
CREATE TABLE IF NOT EXISTS "BuyWeapon" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"Name_Localised"	text,
	"Price"	numeric,
	"SuitModuleID"	numeric,
	"Class"	numeric,
	"WeaponMods"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "BuyMicroResources";
CREATE TABLE IF NOT EXISTS "BuyMicroResources" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"Name_Localised"	text,
	"Category"	text,
	"Count"	numeric,
	"Price"	numeric,
	"MarketID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Embark";
CREATE TABLE IF NOT EXISTS "Embark" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SRV"	text,
	"Taxi"	text,
	"Multicrew"	text,
	"ID_ID"	numeric,
	"StarSystem"	text,
	"SystemAddress"	numeric,
	"Body"	text,
	"BodyID"	numeric,
	"OnStation"	text,
	"OnPlanet"	text,
	"StationName"	text,
	"StationType"	text,
	"MarketID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CreateSuitLoadout";
CREATE TABLE IF NOT EXISTS "CreateSuitLoadout" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SuitID"	numeric,
	"SuitName"	text,
	"SuitName_Localised"	text,
	"LoadoutID"	numeric,
	"LoadoutName"	text,
	"Modules"	text,
	"SuitMods"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SwitchSuitLoadout";
CREATE TABLE IF NOT EXISTS "SwitchSuitLoadout" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SuitID"	numeric,
	"SuitName"	text,
	"SuitName_Localised"	text,
	"LoadoutID"	numeric,
	"LoadoutName"	text,
	"Modules"	text,
	"SuitMods"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SellSuit";
CREATE TABLE IF NOT EXISTS "SellSuit" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SuitID"	numeric,
	"Name"	text,
	"Name_Localised"	text,
	"Price"	numeric,
	"SuitMods"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "TransferMicroResources";
CREATE TABLE IF NOT EXISTS "TransferMicroResources" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Transfers"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CollectItems";
CREATE TABLE IF NOT EXISTS "CollectItems" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"Name_Localised"	text,
	"Type"	text,
	"OwnerID"	text,
	"Count"	numeric,
	"Stolen"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "BackpackChange";
CREATE TABLE IF NOT EXISTS "BackpackChange" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Added"	text,
	"Removed"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CargoTransfer";
CREATE TABLE IF NOT EXISTS "CargoTransfer" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Transfers"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ShieldState";
CREATE TABLE IF NOT EXISTS "ShieldState" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ShieldsUp"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SellDrones";
CREATE TABLE IF NOT EXISTS "SellDrones" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Type"	text,
	"Count"	numeric,
	"SellPrice"	numeric,
	"TotalSale"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SellMicroResources";
CREATE TABLE IF NOT EXISTS "SellMicroResources" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"TotalCount"	numeric,
	"MicroResources"	text,
	"Price"	numeric,
	"MarketID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SellWeapon";
CREATE TABLE IF NOT EXISTS "SellWeapon" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"Name_Localised"	text,
	"Class"	numeric,
	"WeaponMods"	text,
	"Price"	numeric,
	"SuitModuleID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "LoadoutEquipModule";
CREATE TABLE IF NOT EXISTS "LoadoutEquipModule" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"LoadoutName"	text,
	"SuitID"	numeric,
	"SuitName"	text,
	"SuitName_Localised"	text,
	"LoadoutID"	numeric,
	"SlotName"	text,
	"ModuleName"	text,
	"ModuleName_Localised"	text,
	"Class"	numeric,
	"WeaponMods"	text,
	"SuitModuleID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Passengers";
CREATE TABLE IF NOT EXISTS "Passengers" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Manifest"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SearchAndRescue";
CREATE TABLE IF NOT EXISTS "SearchAndRescue" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"Name"	text,
	"Name_Localised"	text,
	"Count"	numeric,
	"Reward"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "FactionKillBond";
CREATE TABLE IF NOT EXISTS "FactionKillBond" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Reward"	numeric,
	"AwardingFaction"	text,
	"VictimFaction"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DockingCancelled";
CREATE TABLE IF NOT EXISTS "DockingCancelled" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"StationName"	text,
	"StationType"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ShipLocker";
CREATE TABLE IF NOT EXISTS "ShipLocker" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Items"	text,
	"Components"	text,
	"Consumables"	text,
	"Data"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ShipyardSell";
CREATE TABLE IF NOT EXISTS "ShipyardSell" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ShipType"	text,
	"SellShipID"	numeric,
	"ShipPrice"	text,
	"System"	text,
	"ShipMarketID"	numeric,
	"MarketID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "RepairDrone";
CREATE TABLE IF NOT EXISTS "RepairDrone" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"HullRepaired"	numeric,
	"CockpitRepaired"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "UseConsumable";
CREATE TABLE IF NOT EXISTS "UseConsumable" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Name"	text,
	"Name_Localised"	text,
	"Type"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CrimeVictim";
CREATE TABLE IF NOT EXISTS "CrimeVictim" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Offender"	text,
	"CrimeType"	text,
	"Bounty"	numeric,
	"Fine"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CockpitBreached";
CREATE TABLE IF NOT EXISTS "CockpitBreached" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "NpcCrewRank";
CREATE TABLE IF NOT EXISTS "NpcCrewRank" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"NpcCrewName"	text,
	"NpcCrewId"	numeric,
	"RankCombat"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "FighterDestroyed";
CREATE TABLE IF NOT EXISTS "FighterDestroyed" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"ID_ID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CrewLaunchFighter";
CREATE TABLE IF NOT EXISTS "CrewLaunchFighter" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Crew"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CrewMemberRoleChange";
CREATE TABLE IF NOT EXISTS "CrewMemberRoleChange" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Crew"	text,
	"Role"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CrewMemberQuits";
CREATE TABLE IF NOT EXISTS "CrewMemberQuits" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Crew"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "FighterRebuilt";
CREATE TABLE IF NOT EXISTS "FighterRebuilt" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Loadout"	text,
	"ID_ID"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "BuyTradeData";
CREATE TABLE IF NOT EXISTS "BuyTradeData" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"System"	text,
	"Cost"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "RefuelPartial";
CREATE TABLE IF NOT EXISTS "RefuelPartial" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Cost"	numeric,
	"Amount"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "DeleteSuitLoadout";
CREATE TABLE IF NOT EXISTS "DeleteSuitLoadout" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"SuitID"	numeric,
	"SuitName"	text,
	"SuitName_Localised"	text,
	"LoadoutID"	numeric,
	"LoadoutName"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "RebootRepair";
CREATE TABLE IF NOT EXISTS "RebootRepair" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Modules"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CommunityGoalJoin";
CREATE TABLE IF NOT EXISTS "CommunityGoalJoin" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"CGID"	numeric,
	"Name"	text,
	"System"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CommunityGoal";
CREATE TABLE IF NOT EXISTS "CommunityGoal" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"CurrentGoals"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "ScientificResearch";
CREATE TABLE IF NOT EXISTS "ScientificResearch" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"MarketID"	numeric,
	"Name"	text,
	"Name_Localised"	text,
	"Category"	text,
	"Count"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CommunityGoalReward";
CREATE TABLE IF NOT EXISTS "CommunityGoalReward" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"CGID"	numeric,
	"Name"	text,
	"System"	text,
	"Reward"	numeric,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "SelfDestruct";
CREATE TABLE IF NOT EXISTS "SelfDestruct" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "FSSBodySignals";
CREATE TABLE IF NOT EXISTS "FSSBodySignals" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"BodyName"	text,
	"BodyID"	numeric,
	"SystemAddress"	numeric,
	"Signals"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "BookTaxi";
CREATE TABLE IF NOT EXISTS "BookTaxi" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Cost"	numeric,
	"DestinationSystem"	text,
	"DestinationLocation"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "CancelTaxi";
CREATE TABLE IF NOT EXISTS "CancelTaxi" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	"Refund"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
DROP TABLE IF EXISTS "Resupply";
CREATE TABLE IF NOT EXISTS "Resupply" (
	"Id"	INTEGER NOT NULL,
	"CMDRId"	INTEGER NOT NULL,
	"FileheaderId"	INTEGER NOT NULL,
	"timestamp"	text,
	PRIMARY KEY("Id" AUTOINCREMENT)
);
COMMIT;
