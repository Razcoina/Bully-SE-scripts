local attempts = GetMissionCurrentAttemptCount()
local TIER1 = 0
local TIER2 = 1
local TIER3 = 2
local TIER4 = 3
local TIER5 = 4
local TIER6 = 5
local gCurrentTier
local MISSION_RUNNING = 0
local MISSION_PASSED = 1
local MISSION_FAILED = 2
local gMissionState = MISSION_RUNNING
local gSnowPileGoal = 0
local gObj1, gCars
local DURATION_EASY = 70
local DURATION_MEDIUM = 100
local DURATION_HARD = 140
local gDuration = DURATION_EASY
local GAME_AREA_RETURN_DELAY = 5800
local GAMEAREA_RETURN_MAX = 5
local gSnowDestroyed = 0
local SHOVEL_DONE = 0
local SHOVEL_PROCESSING = 1
local jerkTaunts = {}
local gExitTimer
local inLot = true
local gCarHitCount = 0
local CAR_DAMAGE_MAX = 1
local bPlayerBusted = false
local gGameArea, snowpoofX, snowpoofY, snowpoofZ, gCarCheckTimer
local gBasePunishment = 200
local gPrefect
local bClockPaused = false
local gSnowPileBlips = {}

function F_SetupPunishmentTier(tier)
	gCurrentTier = tier
	--print(">>>[RUI]", "F_SetupPunishmentTier: " .. tier)
end

function PrefectWanderAmbiently(prefect)
	if F_PedExists(prefect) then
		PedClearTether(prefect)
		PedClearObjectives(prefect)
		PedWander(prefect, 0)
		bPrefectFreed = true
		--print(">>>[RUI]", "!!PrefectWanderAmbiently")
	end
end

function PrefectRemove(prefect)
	if not bPrefectFreed then
		PedClearTether(prefect)
		PedClearObjectives(prefect)
		PedWander(prefect, 0)
		PedMakeAmbient(prefect)
	else
		PedMakeAmbient(prefect)
	end
end

function T_MissionTutorial()
	Wait(1000)
	TutorialShowMessage("TUT_SP_01", 7000)
	Wait(7000)
	collectgarbage()
end

function PedExists(ped)
	return ped and PedIsValid(ped) and not (PedGetHealth(ped) <= 0)
end

function NIS_Intro()
	--print(">>>[RUI]", "++NIS_Intro()")
	PlayerSetControl(0)
	F_MakePlayerSafeForNIS(true)
	AreaTransitionPoint(0, gPlayerStart, 1, false)
	PlayerSetWeapon(364, 1, false)
	gPrefect = GuardCreate(gPrefectStart)
	PedFaceObject(gPrefect, gPlayer, 3, 1, false)
	PedSetAsleep(gPrefect, true)
	Wait(500)
	if bLibraryCam then
		CameraSetFOV(80)
		CameraSetXYZ(190.01863, -136.44211, 9.200684, 189.60976, -137.33684, 9.021392)
	else
		CameraSetFOV(80)
		CameraSetXYZ(184.13647, -21.066463, 8.240224, 184.58311, -20.210419, 7.980383)
	end
	CameraSetWidescreen(true)
	CameraFade(500, 1)
	Wait(501)
	AreaDisableCameraControlForTransition(false)
	SoundPlayScriptedSpeechEvent(gPrefect, "SNOW_SHOVELLING", 1, "large", true)
	WaitSkippable(3000)
	PedFollowPath(gPlayer, gExitPath, 0, 0)
	WaitSkippable(1500)
	CameraSetWidescreen(false)
	CameraReturnToPlayer(false)
	PlayerWeaponHudLock(true)
	F_MakePlayerSafeForNIS(false)
	PedStop(gPlayer)
	PlayerSetControl(1)
	--print(">>>[RUI]", "--NIS_Intro()")
end

function NIS_OutroSuccess()
	--print(">>>[RUI]", "++NIS_OutroSuccess")
	TextPrintString("", 1, 1)
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	SoundPlayScriptedSpeechEvent(gPrefect, "SNOW_SHOVELLING", 2, "supersize", true)
	Wait(2000)
	MinigameSetCompletion("M_PASS", true, 0, "P_SNOW_PASS")
	SoundPlayMissionEndMusic(true, 4)
	PlayerSetPunishmentPoints(0)
	while SoundSpeechPlaying(gPrefect) do
		Wait(10)
	end
	if PedExists(gPrefect) then
		PrefectWanderAmbiently(gPrefect)
	end
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	CameraFade(FADE_OUT_TIME, 0)
	Wait(FADE_OUT_TIME + 1)
	bWeaponCleared = true
	PedSetWeaponNow(gPlayer, -1, 0, false)
	PlayerSetPosPoint(gPlayerEnd, 1)
	F_MakePlayerSafeForNIS(false)
end

function F_AttackedAtendeeCamera()
	if gCurrentTier == TIER1 then
		CameraSetXYZ(188.14597, -144.61464, 9.608352, 187.8405, -143.67563, 9.45051)
	elseif gCurrentTier == TIER2 then
		CameraSetXYZ(188.14597, -144.61464, 9.608352, 187.8405, -143.67563, 9.45051)
	elseif gCurrentTier == TIER3 then
		CameraSetXYZ(188.14597, -144.61464, 9.608352, 187.8405, -143.67563, 9.45051)
	elseif gCurrentTier == TIER4 then
		CameraSetXYZ(182.78473, -14.867686, 8.745096, 183.37775, -15.562892, 8.338923)
	elseif gCurrentTier == TIER5 then
		CameraSetXYZ(182.78473, -14.867686, 8.745096, 183.37775, -15.562892, 8.338923)
	elseif gCurrentTier == TIER6 then
		CameraSetXYZ(182.78473, -14.867686, 8.745096, 183.37775, -15.562892, 8.338923)
	end
end

function NIS_OutroFailure()
	--print(">>>[RUI]", "++NIS_OutroFailure")
	TextPrintString("", 1, 1)
	CameraSetWidescreen(true)
	PlayerSetControl(0)
	if bPlayerBusted then
		SoundPlayScriptedSpeechEvent(gPrefect, "BUSTING_JIMMY", 0, "large", true)
	elseif bGuardHit then
		F_AttackedAtendeeCamera()
		SoundPlayScriptedSpeechEvent(gPrefect, "JEER", 0, "large", true)
	else
		SoundPlayScriptedSpeechEvent(gPrefect, "JEER", 0, "large", true)
	end
	while SoundSpeechPlaying(gPrefect) do
		Wait(10)
	end
	if gFailMessage then
		MinigameSetCompletion("P_SNOW_FAIL", false, 0, gFailMessage)
	else
		MinigameSetCompletion("P_SNOW_FAIL", false, 0, "P_SNOW_F5")
	end
	SoundPlayMissionEndMusic(false, 4)
	while SoundSpeechPlaying(gPrefect) do
		Wait(10)
	end
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	CameraFade(FADE_OUT_TIME, 0)
	Wait(FADE_OUT_TIME + 1)
	if PedExists(gPrefect) then
		PrefectWanderAmbiently(gPrefect)
	end
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	F_MakePlayerSafeForNIS(false)
	CameraReturnToPlayer()
	--print(">>>[RUI]", "--NIS_OutroSuccess")
	CounterSetup(false)
	--print(">>>[RUI]", "--NIS_OutroFailure")
end

function ParkedCarsCreate()
	if not gCars then
		return
	end
	for _, car in gCars do
		car.id = VehicleCreatePoint(car.model, car.point, car.e)
		car.oldHealth = VehicleGetHealth(car.id)
		VehicleStop(car.id)
	end
	--print(">>>[RUI]", "++ParkedCarsCreate")
end

function ParkedCarsRemove()
	if not gCars then
		return
	end
	for _, car in gCars do
		if VehicleIsValid(car.id) then
			VehicleMakeAmbient(car.id, false)
		end
	end
end

function SetupDifficulty(level)
	--print(">>>[RUI]", "!!SetupDifficulty " .. tostring(level))
	if level == TIER4 then
		Tier4_Setup()
	elseif level == TIER5 then
		Tier5_Setup()
	elseif level == TIER6 then
		Tier6_Setup()
	elseif level == TIER1 then
		Tier1_Setup()
	elseif level == TIER2 then
		Tier2_Setup()
	elseif level == TIER3 then
		Tier3_Setup()
	end
	if gDepopTrigger then
		AreaActivatePopulationTrigger(gDepopTrigger)
	end
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	POIGroupsEnabled(false)
	DisablePOI(true, true)
	AreaClearAllPeds()
	AreaClearAllVehicles()
	if gCars then
		ParkedCarsCreate()
	end
	SnowPilesCreate()
	bDoTutorials = level == TIER1 and attempts <= 2
	--print("()xxxxx[:::::::::::::::> [finish] SetupDifficulty()")
end

function ParkedCarsPrint()
	--print(">>>[RUI]", "[[ParkedCarsPrint:-----")
	--print(">>>[RUI]", "gCarHitCount: " .. gCarHitCount)
	for _, car in gCars do
		--print(">>>[RUI]", "car.is: " .. car.id, "car.oldHealth: " .. car.oldHealth, "car.newDamage: " .. car.newDamage, "CarGetDamageNumber:" .. tostring(CarGetDamageNumber(car.id)))
	end
	--print(">>>[RUI]", "ParkedCarsPrint:-----]]")
end

function Tier4_Setup()
	DATLoad("P_SNOW4.DAT", 2)
	DATInit()
	gDuration = DURATION_EASY
	gPlayerStart = POINTLIST._PSP_SPAWNPLAYER
	gPlayerEnd = POINTLIST._PSP_PLAYEREND
	gExitPath = PATH._PSP_EXITPATH
	gPrefectStart = POINTLIST._PSP_SPAWNPREFECT
	gGameArea = TRIGGER._LVL4GAMEAREA
	gDepopTrigger = TRIGGER._ST4_DEPOPSNOWAREA
	endPoint = POINTLIST._TIER4_END
	gCars = {
		{
			model = 294,
			point = POINTLIST._LVL4_AMBIENTCARS,
			e = 1
		},
		{
			model = 294,
			point = POINTLIST._LVL4_AMBIENTCARS,
			e = 2
		},
		{
			model = 293,
			point = POINTLIST._LVL4_AMBIENTCARS,
			e = 3
		}
	}
	gSnowPiles = {
		{
			trigger = TRIGGER._SNOWSTAGE4_01,
			name = "TRIGGER._SNOWSTAGE1_01",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWSTAGE4_02,
			name = "TRIGGER._SNOWSTAGE1_02",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWSTAGE4_04,
			name = "TRIGGER._SNOWSTAGE1_04",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWSTAGE4_05,
			name = "TRIGGER._SNOWSTAGE1_05",
			removed = false,
			blip = nil
		}
	}
	gSnowPileGoal = table.getn(gSnowPiles)
	gTaunters = POINTLIST._LVL4_JERKS
end

function Tier5_Setup()
	DATLoad("P_SNOW5.DAT", 2)
	DATInit()
	gDuration = DURATION_MEDIUM
	gPlayerStart = POINTLIST._PSP_SPAWNPLAYER
	gPlayerEnd = POINTLIST._PSP_PLAYEREND
	gExitPath = PATH._PSP_EXITPATH
	gPrefectStart = POINTLIST._PSP_SPAWNPREFECT
	gDepopTrigger = TRIGGER._ST5_DEPOPSNOWAREA
	gGameArea = TRIGGER._LVL5GAMEAREA
	gCars = {
		{
			model = 293,
			point = POINTLIST._LVL5_AMBIENTCARS,
			e = 1
		},
		{
			model = 294,
			point = POINTLIST._LVL5_AMBIENTCARS,
			e = 2
		}
	}
	gSnowPiles = {
		{
			trigger = TRIGGER._LVL5_SNOWPILE03,
			name = "TRIGGER._LVL5_SNOWPILE03",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL5_SNOWPILE06,
			name = "TRIGGER._LVL5_SNOWPILE06",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL5_SNOWPILE07,
			name = "TRIGGER._LVL5_SNOWPILE07",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL5_SNOWPILE08,
			name = "TRIGGER._LVL5_SNOWPILE08",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL5_SNOWPILE09,
			name = "TRIGGER._LVL5_SNOWPILE09",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL5_SNOWPILE10,
			name = "TRIGGER._LVL5_SNOWPILE10",
			removed = false,
			blip = nil
		}
	}
	gSnowPileGoal = table.getn(gSnowPiles)
	gTaunters = POINTLIST._LVL5_JERKS
end

function Tier6_Setup()
	DATLoad("P_SNOW6.DAT", 2)
	DATInit()
	gDuration = DURATION_HARD
	gPlayerStart = POINTLIST._PSP_SPAWNPLAYER
	gPlayerEnd = POINTLIST._PSP_PLAYEREND
	gExitPath = PATH._PSP_EXITPATH
	gPrefectStart = POINTLIST._PSP_SPAWNPREFECT
	gDepopTrigger = TRIGGER._ST6_DEPOPSNOWAREA
	gGameArea = TRIGGER._LVL6GAMEAREA
	gCars = {
		{
			model = 293,
			point = POINTLIST._LVL6_AMBIENTCARS,
			e = 1
		},
		{
			model = 293,
			point = POINTLIST._LVL6_AMBIENTCARS,
			e = 2
		},
		{
			model = 294,
			point = POINTLIST._LVL6_AMBIENTCARS,
			e = 3
		}
	}
	gSnowPiles = {
		{
			trigger = TRIGGER._LVL6_SNOWPILE_04,
			name = "TRIGGER._LVL6_SNOWPILE_04",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL6_SNOWPILE_05,
			name = "TRIGGER._LVL6_SNOWPILE_05",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL6_SNOWPILE_06,
			name = "TRIGGER._LVL6_SNOWPILE_06",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL6_SNOWPILE_07,
			name = "TRIGGER._LVL6_SNOWPILE_07",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL6_SNOWPILE_08,
			name = "TRIGGER._LVL6_SNOWPILE_08",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL6_SNOWPILE_09,
			name = "TRIGGER._LVL6_SNOWPILE_09",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL6_SNOWPILE_10,
			name = "TRIGGER._LVL6_SNOWPILE_10",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL6_SNOWPILE_12,
			name = "TRIGGER._LVL6_SNOWPILE_12",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._LVL6_SNOWPILE_14,
			name = "TRIGGER._LVL6_SNOWPILE_14",
			removed = false,
			blip = nil
		}
	}
	gSnowPileGoal = table.getn(gSnowPiles)
	gTaunters = POINTLIST._LVL6_JERKS
end

function Tier1_Setup()
	DATLoad("P_SNOW1.DAT", 2)
	DATInit()
	gDuration = DURATION_EASY
	bLibraryCam = true
	gPlayerStart = POINTLIST._PSL_SPAWNPLAYER
	gPlayerEnd = POINTLIST._PSL_PLAYEREND
	gExitPath = PATH._PSL_EXITPATH
	gPrefectStart = POINTLIST._PSL_SPAWNPREFECT
	gGameArea = TRIGGER._LVL1GAMEAREA
	gDepopTrigger = TRIGGER._ST1_DEPOPSNOWAREA
	endPoint = POINTLIST._TIER1_END
	gCars = nil
	gSnowPiles = {
		{
			trigger = TRIGGER._SNOWPILE1_01,
			name = "TRIGGER._SNOWPILE_01",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE1_02,
			name = "TRIGGER._SNOWPILE_02",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE1_03,
			name = "TRIGGER._SNOWPILE_03",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE1_04,
			name = "TRIGGER._SNOWPILE_04",
			removed = false,
			blip = nil
		}
	}
	gSnowPileGoal = table.getn(gSnowPiles)
	gTaunters = nil
end

function Tier2_Setup()
	DATLoad("P_SNOW2.DAT", 2)
	DATInit()
	gDuration = DURATION_HARD
	bLibraryCam = true
	gPlayerStart = POINTLIST._PSL_SPAWNPLAYER
	gPlayerEnd = POINTLIST._PSL_PLAYEREND
	gExitPath = PATH._PSL_EXITPATH
	gPrefectStart = POINTLIST._PSL_SPAWNPREFECT
	gDepopTrigger = TRIGGER._ST2_DEPOPSNOWAREA
	gGameArea = TRIGGER._LVL2GAMEAREA
	endPoint = POINTLIST._TIER2_END
	gCars = nil
	gSnowPiles = {
		{
			trigger = TRIGGER._SNOWPILE2_01,
			name = "TRIGGER._SNOWPILE2_01",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE2_02,
			name = "TRIGGER._SNOWPILE2_02",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE2_03,
			name = "TRIGGER._SNOWPILE2_03",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE2_04,
			name = "TRIGGER._SNOWPILE2_04",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE2_05,
			name = "TRIGGER._SNOWPILE2_05",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE2_06,
			name = "TRIGGER._SNOWPILE2_06",
			removed = false,
			blip = nil
		}
	}
	gSnowPileGoal = table.getn(gSnowPiles)
	gTaunters = nil
end

function Tier3_Setup()
	DATLoad("P_SNOW3.DAT", 2)
	DATInit()
	gDuration = DURATION_HARD
	bLibraryCam = true
	gPlayerStart = POINTLIST._PSL_SPAWNPLAYER
	gPlayerEnd = POINTLIST._PSL_PLAYEREND
	gExitPath = PATH._PSL_EXITPATH
	gPrefectStart = POINTLIST._PSL_SPAWNPREFECT
	gGameArea = TRIGGER._LVL3GAMEAREA
	gDepopTrigger = TRIGGER._ST3_DEPOPSNOWAREA
	endPoint = POINTLIST._TIER3_END
	gCars = nil
	gSnowPiles = {
		{
			trigger = TRIGGER._SNOWPILE3_01,
			name = "TRIGGER._SNOWPILE_01",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE3_02,
			name = "TRIGGER._SNOWPILE_01",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE3_03,
			name = "TRIGGER._SNOWPILE_01",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE3_04,
			name = "TRIGGER._SNOWPILE_01",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE3_05,
			name = "TRIGGER._SNOWPILE_01",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE3_06,
			name = "TRIGGER._SNOWPILE_01",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE3_07,
			name = "TRIGGER._SNOWPILE_01",
			removed = false,
			blip = nil
		},
		{
			trigger = TRIGGER._SNOWPILE3_08,
			name = "TRIGGER._SNOWPILE_01",
			removed = false,
			blip = nil
		}
	}
	gSnowPileGoal = table.getn(gSnowPiles)
	gTaunters = nil
end

function SnowPilesCreate()
	local x, y, z = 0, 0, 0
	for _, snow in gSnowPiles do
		x, y, z = GetAnchorPosition(snow.trigger)
		snow.blip = BlipAddXYZ(x, y, z + 0.6, 0, 1)
		snow.id = PAnimCreate(snow.trigger)
		snow.removed = false
		--print(">>>[RUI]", "++SnowPilesCreate: " .. snow.name)
	end
end

function SnowPilesRemove()
	for _, snow in gSnowPiles do
		if not snow.removed then
			PAnimDelete(snow.trigger)
			--print(">>>[RUI]", "--SnowPilesRemove: " .. snow.name)
		end
		if snow.blip then
			BlipRemove(snow.blip)
		end
	end
	gSnowPiles = nil
end

function CounterSetup(bOn, Max)
	if bOn then
		CounterSetCurrent(Max)
		CounterSetMax(Max)
		CounterSetText("P_SNOW_COUNT")
		CounterSetIcon("HUDIcon_snowoff", "HUDIcon_snowoff_x")
		CounterMakeHUDVisible(true, true)
	else
		CounterMakeHUDVisible(false)
		print(">>>[RUI]", "CounterMakeHUDVisible")
		CounterSetCurrent(0)
		CounterSetMax(0)
		CounterClearIcon()
		CounterClearText()
	end
end

function cbJerkSpotCheck()
	--print(">>>[RUI]", "!!cbJerkSpotCheck")
	bJerkSpottedYou = true
end

function UpdateObjectiveLog(newObjStr, oldObj)
	local newObj
	if newObjStr then
		newObj = MissionObjectiveAdd(newObjStr)
		TextPrint(newObjStr, 3, 1)
	end
	if oldObj ~= nil then
		MissionObjectiveComplete(oldObj)
	end
	return newObj
end

function PedIsHitByPlayer(ped)
	if not PedExists(ped) then
		return false
	end
	PedClearHitRecord(ped)
	Wait(5)
	return PedIsHit(ped, 2, 500) and PedGetWhoHitMeLast(ped) == gPlayer
end

function PlayerAttackedParkedCars()
	if not gCars then
		return false
	end
	if gCarCheckTimer then
		if GetTimer() - gCarCheckTimer > 300 then
			bCarHit = PedHasGeneratedStimulusOfType(gPlayer, 27)
			if bCarHit then
				--print(">>>[RUI]", "bCarHit: time: " .. GetTimer())
				gCarHitCount = gCarHitCount + 1
			end
			PedRemoveStimulus(gPlayer, 27)
			gCarCheckTimer = nil
		end
	else
		gCarCheckTimer = GetTimer()
	end
	if gCarHitCount == 1 and not bWarned then
		TextPrint("P_SNOW_06", 5, 1)
		bWarned = true
	elseif gCarHitCount > CAR_DAMAGE_MAX then
		return true
	end
	return false
end

function PlayerBusted()
	return PlayerGetPunishmentPoints() >= gBasePunishment
end

function cbGuardHit(victim, attacker)
	--print(">>>[RUI]", "!!cbGuardHit")
	if victim == gPrefect and attacker == gPlayer then
		gMissionState = MISSION_FAILED
		gFailMessage = "P_SNOW_F3"
		PlayerSetControl(0)
		bPlayerBusted = true
		bGuardHit = true
	end
end

function TimerPassed(time)
	return time < GetTimer()
end

function PlayerLeftGameAreaTimedOut()
	if not PlayerIsInTrigger(gGameArea) then
		PlayerSetControl(0)
		CameraFade(500, 0)
		Wait(501)
		CameraSetWidescreen(true)
		PedFaceObjectNow(gPrefect, gPlayer, 3)
		Wait(1000)
		F_PedSetCameraOffsetXYZ(gPrefect, 0.3, 1.4, 1.3, 0, 0, 1.5)
		SoundSetAudioFocusCamera()
		CameraFade(500, 1)
		Wait(501)
		SoundPlayScriptedSpeechEvent(gPrefect, "SNOW_SHOVELLING", 100, "large")
		Wait(1000)
		while SoundSpeechPlaying(gPrefect) do
			Wait(0)
		end
		CameraFade(500, 0)
		Wait(501)
		CameraSetWidescreen(false)
		CameraReturnToPlayer(true)
		PlayerSetPosPoint(gPlayerStart, 1)
		PedFaceObject(gPrefect, gPlayer, 3, 1, false)
		gMowerCountDown = MOWER_COUNTDOWN_MAX
		gMowerCountDownTime = nil
		gMowerExitTimer = nil
		onMower = true
		SoundSetAudioFocusPlayer()
		Wait(50)
		if gCurrentTier <= TIER3 then
			PlayerFaceHeadingNow(180)
		else
			PlayerFaceHeadingNow(0)
		end
		Wait(50)
		CameraReturnToPlayer(true)
		CameraFade(500, 1)
		Wait(501)
		PlayerSetControl(1)
	end
end

function MonitorSnowPilesLoop()
	for _, snow in gSnowPiles do
		if not snow.removed and PAnimIsDestroyed(snow.trigger) then
			--print("MonitorSnowPilesLoop snow " .. snow.name)
			snowpoofX, snowpoofY, snowpoofZ = GetAnchorPosition(snow.trigger)
			EffectCreate("SnowPoof", snowpoofX, snowpoofY, snowpoofZ)
			PAnimDelete(snow.trigger)
			if snow.blip then
				BlipRemove(snow.blip)
				snow.blip = nil
			end
			CounterIncrementCurrent(-1)
			gSnowDestroyed = gSnowDestroyed + 1
			snow.removed = true
			--print(">>>[RUI]", "!!MonitorSnowPilesLoop: shoveled " .. snow.name)
			break
		end
	end
	if gSnowDestroyed == gSnowPileGoal then
		--print(">>>[RUI]", "!!MonitorSnowPilesLoop  DONE")
		return SHOVEL_DONE
	end
	return SHOVEL_PROCESSING
end

function GuardCreate(pos)
	local guard = PedCreatePoint(50, pos, 1)
	PedSetTetherToPoint(guard, pos, 2, 15)
	PedIgnoreStimuli(guard, false)
	PedIgnoreAttacks(guard, false)
	RegisterPedEventHandler(guard, 0, cbGuardHit)
	--print(">>>[RUI]", "++GuardCreate")
	return guard
end

function MissionSetup()
	DATLoad("P_SNOWCOMMON.DAT", 2)
	MissionDontFadeIn()
	AreaClearAllPeds()
	AreaClearAllVehicles()
	DisablePOI(true, true)
	PlayerSetPunishmentPoints(0)
	math.randomseed(GetTimer())
	bClockPaused = ClockIsPaused()
	RadarSetMinMax(10, 75, 15)
	SoundPlayInteractiveStream("MS_CarnivalFunhouseMaze.rsm", 0.45, 500, 500)
	DisablePunishmentSystem(true)
end

function MissionCleanup()
	DisablePunishmentSystem(false)
	if not bClockPaused then
		UnpauseGameClock()
	end
	PlayerWeaponHudLock(false)
	CounterSetup(false)
	RadarRestoreMinMax()
	MissionTimerStop()
	SoundStopInteractiveStream()
	if gMissionState == MISSION_PASSED or IsMissionDebugSuccess() then
		PlayerSetScriptSavedData(14, 0)
	else
		PlayerSetScriptSavedData(14, 1)
	end
	AreaRevertToDefaultPopulation()
	EnablePOI(true, true)
	POIGroupsEnabled(true)
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	F_MakePlayerSafeForNIS(false)
	CameraReturnToPlayer()
	if not bWeaponCleared then
		PedSetWeaponNow(gPlayer, -1, 0, false)
	end
	if PedExists(gPrefect) then
		PrefectRemove(gPrefect)
	end
	if gCars then
		ParkedCarsRemove()
	end
	SnowPilesRemove()
	if gDepopTrigger then
		AreaDeactivatePopulationTrigger(gDepopTrigger)
	end
	AreaRevertToDefaultPopulation()
	AreaEnableAllPatrolPaths()
	if bPlayerBusted then
		PlayerSetControl(1)
	else
		PlayerSetPunishmentPoints(0)
	end
	WeatherRelease()
	DATUnload(2)
	DATInit()
end

function TimeElapsed(duration)
	local t = duration - MissionTimerGetTimeRemaining()
	return t
end

function MissionInit()
	WeatherSet(5)
	PauseGameClock()
	LoadWeaponModels({ 313, 364 })
	LoadModels({
		294,
		293,
		50
	})
	AreaDisableAllPatrolPaths()
	PedSetTypeToTypeAttitude(4, 13, 1)
	jerkTaunts = {
		"Kid: Hey check out the teachers pet!",
		"Kid: So you like snow eh?",
		"Kid: Hey what do you think you're doing??",
		"Kid: We just put that there!"
	}
	--print(">>>[RUI]", "--MissionInit")
end

function MissionFailureConditionsMet()
	if MissionTimerHasFinished() then
		--print(">>>[RUI]", "main:  Timed Out")
		MissionTimerStop()
		gFailMessage = "PUN_TIME"
		return true
	end
	if bGuardHit then
		return true
	end
	if PlayerAttackedParkedCars() then
		--print(">>>[RUI]", "!!PlayerAttackedParkedCars")
		gFailMessage = "P_SNOW_CARS"
		return true
	end
	PlayerLeftGameAreaTimedOut()
	return false
end

function main()
	while not gCurrentTier do
		Wait(10)
	end
	MissionInit()
	SetupDifficulty(gCurrentTier)
	NIS_Intro()
	CounterSetup(true, gSnowPileGoal)
	if bDoTutorials then
		CreateThread("T_MissionTutorial")
	end
	gObj1 = UpdateObjectiveLog("P_SNOW_MOBJ_01")
	MissionTimerStart(gDuration)
	DisablePunishmentSystem(true)
	gStartTime = GetTimer()
	while gMissionState == MISSION_RUNNING do
		if MonitorSnowPilesLoop() == SHOVEL_DONE then
			gMissionState = MISSION_PASSED
			break
		end
		if MissionFailureConditionsMet() then
			gMissionState = MISSION_FAILED
			break
		end
		Wait(0)
	end
	UpdateObjectiveLog(nil, gObj1)
	local xTime = GetTimer() - gStartTime
	StatAddToInt(176)
	StatAddToInt(178, xTime)
	if gMissionState == MISSION_FAILED then
		--print("FAILED!!")
		PlayerSetScriptSavedData(14, 1)
		NIS_OutroFailure()
		SoundPlayMissionEndMusic(false, 4)
		if gFailMessage then
			MissionFail(true, false, gFailMessage)
		else
			MissionFail(true, false)
		end
	elseif gMissionState == MISSION_PASSED then
		--print("SUCCESS!!")
		PlayerSetScriptSavedData(14, 0)
		NIS_OutroSuccess()
		MissionSucceed(false, false, false)
		StatAddToInt(177)
	end
end
