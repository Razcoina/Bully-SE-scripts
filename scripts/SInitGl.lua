--[[ Changes to this file:
	* Removed unused variables
	* Modified function F_BuildAreaTable, may require testing
]]

MUSIC_DEFAULT_VOLUME = 0.5
FADE_OUT_TIME = AreaGetTransitionTime(0)
FADE_IN_TIME = AreaGetTransitionTime(1)
shared.bBustedClassLaunched = false
shared.gPlayerSlept = false
shared.gTeleport3R10 = false
shared.gTeleport1R01 = false
shared.gTeleport_3_R05 = false
shared.gTeleport_2_R03 = false
shared.gConversationOver_2_R03 = false
shared.g3BMissionState = 0
shared.g1FCXFightType = -1
shared.g1FC01MissionState = 0
shared.g1FC02MissionState = 0
shared.g1FC03MissionState = 0
shared.g1FC04MissionState = 0
shared.g3RS02MissionState = 0
shared.g2SS07MissionState = 0
shared.g3R10MissionState = 0
shared.g3R10MissionHistory = 0
shared.g3R07BikeID = -1
shared.g206Subquest = -1
shared.gSchoolSpawner = nil
shared.gCurfew = false
shared.gSkippedWeedKiller = false
shared.gDisablePrepGate = true
shared.gDisableRumbleCollision = true
shared.gDisableRumbleFire01 = true
shared.gDisableRumbleFire02 = true
shared.gDisableRearSchoolLogs = true
shared.gHideSchoolLocks = true
shared.gHideIndustShortcut = true
shared.gHidePoorRaceBarrier1 = true
shared.gHidePoorRaceBarrier2 = true
shared.gHideBusinessRaceBarrier1 = true
shared.gGymHasBurnt = false
shared.gArcadeRaceLevel = 1
shared.gArcadeRaceIn3D = false
shared.gPrincipalCheck = true
shared.gDangerAreasEnabled = true
shared.gBballLevel = 1
shared.gSchoolGates = {}
shared.g101PunishmentTutorial = false
shared.g101LevelBlipTutorial = false
shared.g3_R08_CurrentRace = nil
shared.g3_R08_LevelAttained = 0
shared.passed1_02C = false
shared.bCrateStateSetup = false
shared.g4_S12_DeliveryBranch = 0
shared.g4_S12_PossessionBranch = 0
gPlayerStartZone = 0
shared.gBif = nil
shared.gHarringtonKeyPickup = nil
shared.bBifDefeated = false
shared.bGrabbedHarringtonHouseKey = false
shared.bAllowPlayerInside = false
shared.bWeedPlantIsDestroyed = false
shared.nFloorHeard = 0
shared.bBifAttacked = false
shared.gPlayerInitialArea = nil
shared.playerShopping = false
shared.g1_02PlayerBusted = 0
shared.g1_08_bGymPop = true
shared.WakeUpType = 0
shared.gCutsceneRunning = false
shared.gRunPOITest = true
shared.gMissionEventFunction = nil
shared.ChemistrySetLocked = 0
shared.ChemistrySetLastTimeUsed = -1
shared.ChemistrySetLastDayUsed = -1
shared.gCurrentAmbientScenario = nil
shared.gCurrentAmbientScenarioObject = nil
shared.gSchoolBusDoorIndex = nil
shared.gSchoolBusDoorGeometry = nil
shared.gCheckHoboDoors = true
shared.gHoleGateOpenIndex = nil
shared.gHoleGateOpenGeometry = nil
shared.gStartingEvent = false
shared.gFirstTimePlaying = false
shared.gMonitorDiceEvent = false
shared.gMinigameMissionTime = 0
shared.gDiceStandingUp = false
shared.gDicePOIModel = nil
shared.gDicePOIModel2 = nil
shared.gPOIKidsPlayingDice = {}
shared.gLockpickingHudTurnOn = false
shared.gLockpickingSuccess = false
shared.gLastLockPickCombo = {}
shared.gLastLockPickLocation = {
	x1 = 0,
	y1 = 0,
	z1 = 0
}
shared.gFailedPickingLocker = false
shared.gLockpickStartingFunction = nil
shared.gLockpickFailureFunction = nil
shared.gLockpickSuccessFunction = nil
shared.gLastDay = -2
shared.g6_03_AreaReady = false
shared.g6_03_GreasersAlive = true
shared.g6_03_NerdsAlive = true
shared.g6_03_PreppiesAlive = true
shared.g6_03_JocksAlive = true
shared.gCurrentPhotographyMission = 0
shared.gGarbagePickupStage = 1
shared.gLawnMowingStage = 0
shared.gHoboStage = 1
shared.nTimesBusted = 0
shared.gHackPunishment = 0
shared.gPunishmentMission = 0
shared.gWeaponTaken = nil
shared.gAmmoTypeTaken = nil
shared.gAmmoTaken = 0
shared.gWindowsOpen = nil
--[[
shared.gPunishmentMissionDebug = 0
]] -- Removed this
shared.gPrepPwd = 0
shared.gPrepDoorConv = false
shared.gBoxingOpponent = 1
shared.gGoKartGPLevel = 0
shared.gGoKartSRLevel = 0
shared.gGoKartINTLevel = 0
shared.GoKartRaceType = nil
shared.gMinPunishPoints = 275
gGameStartHour = 8
gGameStartMinute = 0
gPlayer = 0
gCurrentZone = gPlayerStartZone
gContinue = false
shared.gClassesSkipped = {
	false,
	false,
	false,
	false,
	false
}
shared.gDBDiff = 1
shared.g3_R05_Diff = 1
shared.g3_R05_SuccessCount = 0
g_3RM01_opponent = 1
g_3RM01_GreaserLevel = 1
g_3RM01_PreppyLevel = 1
shared.g1_03_BoughtSlingshot = nil
shared.bFallenInGraves = false
shared.g2_01 = false
shared.g3_01_Reminder = false
shared.g2_03 = nil
shared.g2_03Shirt = nil
shared.gAreaDataLoaded = false
shared.gAreaDATFileLoaded = {}
shared.gAreaDATFileLoaded[0] = false
shared.gAreaDATFileLoaded[2] = false
shared.gAreaDATFileLoaded[22] = false
shared.gAreaDATFileLoaded[26] = false
shared.gAreaDATFileLoaded[29] = false
shared.gAreaDATFileLoaded[30] = false
shared.gAreaDATFileLoaded[36] = false
shared.gAreaDATFileLoaded[14] = false
shared.gAreaDATFileLoaded[37] = false
shared.gAreaDATFileLoaded[27] = false
shared.gAreaDATFileLoaded[32] = false
shared.gAreaDATFileLoaded[31] = false
shared.gAreaDATFileLoaded[8] = false
shared.gAreaDATFileLoaded[13] = false
shared.gAreaDATFileLoaded[29] = false
shared.gAreaDATFileLoaded[34] = false
shared.gAreaDATFileLoaded[38] = false
shared.gSchoolFAlarmOn = false
shared.gBDormFAlarmOn = false
shared.gGDormFAlarmOn = false
shared.gSchoolToilet = false
shared.gBDormToilet = false
shared.gGymToilet = false
shared.gGdormToilet = false
shared.gSchoolFAlarmTime = 20000
shared.gAlarmOn = false
shared.gHasTadKey = false
shared.gParkSprinklers = false
shared.g2_02_GotComic = false
shared.g2_02_ReturnedComic = false
shared.gDefaultHead = "B_Buzz"
shared.gDefaultHeadTXD = "B_Buzz"
shared.gDefaultTorso = "B_Jacket6"
shared.gDefaultTorsoTXD = "B_Jacket6"
shared.gDefaultLegs = "B_Pants2"
shared.gDefaultLegsTXD = "B_Pants2"
shared.gDefaultFeet = "P_Sneakers2"
shared.gDefaultFeetTXD = "P_Sneakers2"
shared.gUniformHead = "B_Buzz"
shared.gUniformHeadTXD = "B_Buzz"
shared.gUniformTorso = "S_Sweater5"
shared.gUniformTorsoTXD = "S_Sweater5"
shared.gUniformLegs = "B_Pants4"
shared.gUniformLegsTXD = "B_Pants4"
shared.gUniformFeet = "P_Boots2"
shared.gUniformFeetTXD = "P_Boots2"
shared.bUnlockEdnaMask = false
shared.bUnlockPumpkinMask = false
shared.bUnlockGnomeOutfit = false
shared.bSnowmenSmashed = false
shared.bPumpkinsSmashed = false
shared.bTombstonesSmashed = false
shared.bRubberBandsCollected = false
shared.bUnlockGGOutfit = false
shared.gWeaponBeforeCut = nil
shared.gAmmoBeforeCut = 0
gTut_DormClothes = 0
shared.g5_03_A_Passed = false
shared.gSecretaryID = nil
shared.LibrarianID = nil
shared.gEdnaID = nil
shared.gControllerPed = gPlayer
shared.areaTable = {}
shared.areaTable.size = 0
shared.bAsylumPatrols = true
shared.bBMXGatesInit = false
shared.bBMXWarehouseInit = false
shared.bMovieTicketLine = false
shared.b2_06Failed = false
shared.gStreetWakeCount = 0
shared.g4S12Perfume = false
shared.gNoEggers = false
shared.g_603_NerdBlip = nil
shared.g_603_GreaserBlip = nil
shared.g_603_PreppyBlip = nil
shared.g_603_JockBlip = nil
shared.g4_06OpAcomplete = false
shared.g4_06OpCcomplete = false
shared.g4_06OpDcomplete = false
shared.g4_06OpEcomplete = false
shared.g4_06OpFcomplete = false
shared.gAllMissionsPassed = false
shared.gMonitorTags = false
shared.gMonitoredTag = nil
shared.ArcadeMachinesOn = false
shared.FHPlayerControlTraps = 0
shared.gDunkMidget = nil
shared.gdormHeadID = nil
shared.gdormHeadSpottedPlayer = nil
shared.gdormHeadStop = nil
shared.gdormHeadStart = nil
shared.gdormHeadCanMove = true
shared.g1_09JustFinished = false
shared.g1_11X1JustFinished = false
shared.g1_11X2JustFinished = false
shared.g1_11XpJustFinished = false
shared.gHCriminalsActive = false
shared.gHalloweenActive = false
shared.gPetey = nil
shared.gGary = nil
shared.b1x11_failed = false
shared.bCleanUpErrand = false
shared.gTurnOff_SG_PREFECT01 = false
shared.gTurnOff_SG_PREFECT02 = false
shared.gTurnOff_SG_PREFECT03 = false
shared.gTurnOff_SG_PREFECT04 = false
shared.gTurnOff_SG_PREFECT05 = false
shared.gTurnOff_SGD_PREFECT1 = false
shared.gTurnOff_SGD_PREFECT2 = false
shared.gTurnOff_SGD_PREFECT3 = false
shared.gTurnOff_1F_PREFECT01 = false
shared.gTurnOff_1F_PREFECT02 = false
shared.gTurnOff_1F_PREFECT03 = false
shared.gTurnOff_2F_PREFECT01 = false
shared.gTurnOff_2F_PREFECT02 = false
shared.gTurnOff_HALLSPATROL_1A = false
shared.gTurnOff_HALLSPATROL_1B = false
shared.gTurnOff_HALLSPATROL_1C = false
shared.gTurnOff_HALLSPATROL_2A = false
shared.gTurnOff_HALLSPATROL_2B = false
shared.boughtBikeOffset = 0
shared.boughtBike01 = false
shared.boughtBike02 = false
shared.boughtBike03 = false
shared.boughtBike04 = false
shared.boughtBike05 = false
shared.boughtScooter = false
shared.extraKOPointsAdded = false
shared.extraKOPoints = false
shared.updateDefaultKOPoint = false
shared.bFootBallFieldEnabled = true
shared.bBathroomPOIEnabled = true

function F_AreaTableAdd(newElement)
	shared.areaTable[shared.areaTable.size] = newElement
	shared.areaTable.size = shared.areaTable.size + 1
end

function F_BuildAreaTable() -- ! Modified
	--[[
	F_AreaTableAdd({
		zone = 31,
		name = "Test Area (Bikes, Peds, Pickups)",
		x = -0.113735,
		y = -2.00068,
		z = 15,
		h = 0
	})
	F_AreaTableAdd({
		zone = 22,
		name = "Fight Area ",
		x = -9.988,
		y = 21.42,
		z = 30,
		h = 0
	})
	]] -- Removed this
	F_AreaTableAdd({
		zone = 0,
		name = "Business District",
		x = 458.59,
		y = -80.7372,
		z = 5.91727,
		h = 0
	})
	F_AreaTableAdd({
		zone = 0,
		name = "Rich Area",
		x = 338.8,
		y = 113.8,
		z = 7.8,
		h = 90
	})
	F_AreaTableAdd({
		zone = 0,
		name = "Cemetery",
		x = 616.307,
		y = 238.97,
		z = 19,
		h = 90
	})
	F_AreaTableAdd({
		zone = 0,
		name = "Carnival",
		x = 226.2,
		y = 412.6,
		z = 5,
		h = 150
	})
	F_AreaTableAdd({
		zone = 0,
		name = "Industrial Area",
		x = 355,
		y = -432,
		z = 3,
		h = 0
	})
	F_AreaTableAdd({
		zone = 0,
		name = "School Grounds",
		x = 272.68,
		y = -73.1309,
		z = 6.96913,
		h = 90
	})
	F_AreaTableAdd({
		zone = 0,
		name = "School Rooftop",
		x = 185.78,
		y = -65.8,
		z = 26.09,
		h = 90
	})
	F_AreaTableAdd({
		zone = 2,
		name = "School Hallways",
		x = -628.7,
		y = -326.3,
		z = 0,
		h = 90
	})
	F_AreaTableAdd({
		zone = 2,
		name = "Principal (Front Desk)",
		x = -633.348,
		y = -292.075,
		z = 6.415,
		h = 90
	})
	F_AreaTableAdd({
		zone = 5,
		name = "Principal (Office)",
		x = -701.084,
		y = 213.482,
		z = 31.957,
		h = 90
	})
	F_AreaTableAdd({
		zone = 23,
		name = "Staff Room",
		x = -655.347,
		y = 228.989,
		z = 0,
		h = 0
	})
	F_AreaTableAdd({
		zone = 6,
		name = "Biology",
		x = -709.749,
		y = 312.36,
		z = 33.574,
		h = 0
	})
	F_AreaTableAdd({
		zone = 4,
		name = "Chemistry",
		x = -599.199,
		y = 326.327,
		z = 34.411,
		h = 0
	})
	F_AreaTableAdd({
		zone = 8,
		name = "Janitors Room",
		x = -746.935,
		y = -51.183,
		z = 9.301,
		h = 0
	})
	F_AreaTableAdd({
		zone = 9,
		name = "Library",
		x = -784.875,
		y = 203.098,
		z = 90.31,
		h = 0
	})
	F_AreaTableAdd({
		zone = 35,
		name = "Girls Dorm",
		x = -454,
		y = 311,
		z = 3.5,
		h = 0
	})
	F_AreaTableAdd({
		zone = 14,
		name = "Boys Dorm",
		x = -502.47,
		y = 309.606,
		z = 31.963,
		h = 0
	})
	F_AreaTableAdd({
		zone = 15,
		name = "Classroom",
		x = -563.082,
		y = 316.99,
		z = -1.8,
		h = 0
	})
	F_AreaTableAdd({
		zone = 15,
		name = "Classroom 2",
		x = -563.082,
		y = 316.99,
		z = 6.174,
		h = 0
	})
	F_AreaTableAdd({
		zone = 17,
		name = "Art Room",
		x = -536.998,
		y = 376.584,
		z = 14.18,
		h = 0
	})
	F_AreaTableAdd({
		zone = 13,
		name = "Pool and Gym",
		x = -623.211,
		y = -72.821,
		z = 60.119,
		h = 0
	})
	F_AreaTableAdd({
		zone = 18,
		name = "Auto shop",
		x = -427.469,
		y = 365.065,
		z = 81.1,
		h = 0
	})
	F_AreaTableAdd({
		zone = 32,
		name = "Prep House",
		x = -569.538,
		y = 133.33,
		z = 46.3,
		h = 0
	})
	F_AreaTableAdd({
		zone = 19,
		name = "Auditorium",
		x = -778.496,
		y = 292.221,
		z = 77.951,
		h = 0
	})
	F_AreaTableAdd({
		zone = 26,
		name = "General Store",
		x = -573.884,
		y = 388.877,
		z = 0.213,
		h = 90
	})
	F_AreaTableAdd({
		zone = 27,
		name = "Boxing Club",
		x = -702.445,
		y = 372.796,
		z = 293.937,
		h = 252.5
	})
	F_AreaTableAdd({
		zone = 29,
		name = "Bike Shop",
		x = -785.601,
		y = 380.055,
		z = 0.73,
		h = 0
	})
	F_AreaTableAdd({
		zone = 30,
		name = "Comic Shop",
		x = -724.707,
		y = 12.604,
		z = 1.696,
		h = 0
	})
	F_AreaTableAdd({
		zone = 36,
		name = "Tenements",
		x = -544.463,
		y = -48.881,
		z = 32.009,
		h = 0
	})
	F_AreaTableAdd({
		zone = 34,
		name = "Clothing (Poor)",
		x = -647.592,
		y = 255.706,
		z = 1.436,
		h = 0
	})
	F_AreaTableAdd({
		zone = 33,
		name = "Clothing (Rich)",
		x = -707.636,
		y = 257.073,
		z = 0.3,
		h = 0
	})
	F_AreaTableAdd({
		zone = 37,
		name = "Funhouse",
		x = -704.7,
		y = -537.944,
		z = 8.26901,
		h = 0
	})
	F_AreaTableAdd({
		zone = 38,
		name = "Asylum",
		x = -736.295,
		y = 422.404,
		z = 2.5,
		h = 30
	})
	F_AreaTableAdd({
		zone = 39,
		name = "Barber Shop",
		x = -655.34,
		y = 121.404,
		z = 4.602,
		h = 90
	})
	F_AreaTableAdd({
		zone = 45,
		name = "Ball Toss",
		x = -792.618,
		y = 89.306,
		z = 10.34,
		h = 90
	})
	F_AreaTableAdd({
		zone = 20,
		name = "Chemical Plant",
		x = -759.167,
		y = 96.995,
		z = 31.413,
		h = 0
	})
	F_AreaTableAdd({
		zone = 40,
		name = "Observatory",
		x = -696.615,
		y = 61.633,
		z = 21.089,
		h = 90
	})
	F_AreaTableAdd({
		zone = 43,
		name = "Junk Yard",
		x = -588.417,
		y = -632.785,
		z = 5,
		h = 0
	})
	F_AreaTableAdd({
		zone = 45,
		name = "Shooting Gallery",
		x = -792.507,
		y = 75.569,
		z = 10.34,
		h = 90
	})
	F_AreaTableAdd({
		zone = 42,
		name = "GoKart Track 2",
		x = -338.426,
		y = 494.663,
		z = 3.008,
		h = 90
	})
	F_AreaTableAdd({
		zone = 16,
		name = "Tattoo Trailer",
		x = -654.824,
		y = 80.927,
		z = 0.345,
		h = 90
	})
	F_AreaTableAdd({
		zone = 46,
		name = "Hair Salon",
		x = -766.037,
		y = 17.693,
		z = 3.714,
		h = 0
	})
	F_AreaTableAdd({
		zone = 51,
		name = "Arcade Race LV 1",
		x = -31.612,
		y = 68.692,
		z = 27.516,
		h = 0
	})
	F_AreaTableAdd({
		zone = 52,
		name = "Arcade Race LV 2",
		x = -94.936,
		y = -72.928,
		z = 0.99,
		h = 0
	})
	F_AreaTableAdd({
		zone = 53,
		name = "Arcade Race LV 3",
		x = -9.347,
		y = 62.253,
		z = 63.251,
		h = 0
	})
	F_AreaTableAdd({
		zone = 50,
		name = "Souvenir Shop",
		x = -794.68,
		y = 45.84,
		z = 7.256,
		h = 90
	})
	F_AreaTableAdd({
		zone = 54,
		name = "Warehouse",
		x = -672.404,
		y = -154.813,
		z = 1.04,
		h = 0
	})
	F_AreaTableAdd({
		zone = 56,
		name = "Poor Barbershop",
		x = -664.978,
		y = 393.284,
		z = 2.878,
		h = 0
	})
	F_AreaTableAdd({
		zone = 55,
		name = "Freak Show",
		x = -469.61,
		y = -78.906,
		z = 9.278,
		h = 90
	})
	F_AreaTableAdd({
		zone = 57,
		name = "Drop Out Save Zone",
		x = -654.664,
		y = 244.846,
		z = 15.485,
		h = 0
	})
	F_AreaTableAdd({
		zone = 60,
		name = "Preppies Save Zone",
		x = -773.434,
		y = 349.695,
		z = 6.869,
		h = 0
	})
	F_AreaTableAdd({
		zone = 59,
		name = "Jocks Save Zone",
		x = -749.179,
		y = 347.235,
		z = 4.064,
		h = 0
	})
	F_AreaTableAdd({
		zone = 61,
		name = "Greaser Save Zone",
		x = -692.013,
		y = 341.897,
		z = 3.534,
		h = 0
	})
	F_AreaTableAdd({
		zone = 62,
		name = "BMX Track",
		x = -780.997,
		y = 634.384,
		z = 29.298,
		h = 0
	})
	F_AreaTableAdd({
		zone = 0,
		name = "Poor Area",
		x = 499.367,
		y = -245.193,
		z = 1.94765,
		h = -90
	})
	F_AreaTableAdd({
		zone = 0,
		name = "Nerd Fort",
		x = 50.256,
		y = -135.00665,
		z = 11.905,
		h = 180
	})
end

function F_AreaTableGetSize()
	return shared.areaTable.size
end

function F_AreaTableGetProperty(index, property)
	return shared.areaTable[index][property]
end

shared.gAreaLoadCompleted = nil
