--[[ Changes to this file:
	* Heavily modified function MissionSetup, requires testing
	* Heavily modified function F_Intro, requires testing
	* Modified function MissionCleanup, may require testing
	* Modified function F_SetupWorld, may require testing
]]

local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bMonitorAlgie = false
local bPlayerIsInSchool = false
local gStage = 1
local bMonitorAlgie = false
local bAlgieCanPiss = false
local gPoopDuration = 15000
local gPissTimerStarted = 0
local gCurrentTime = 0
local bLaunchStage3 = false
local bAlgieMovingToSink = false
local bFightingFirstFloorBathroomJocks = false
local bGoUpstairs = false
local pedAlgie
local pedAlgie = {}
local bathroomX, bathroomY, bathroomZ = 0, 0, 0
local tableBathroomPeds
local tableBathroomPeds = {}
local gBathroomPeds = 0
local bAlgieWhine01 = false
local bAlgieWhine02 = false
local bAlgieWhine03 = false
local bAlgieWhine04 = false
local bAlgieRelief01 = false
local timerAlgieWhine = 0
local pedFirstBully
local pedFirstBully = {}
local pedSecondBully
local pedSecondBully = {}
local pedJockPack_01
local pedJockPack_01 = {}
local pedJockPack_02
local pedJockPack_02 = {}
local pedJockPack_03
local pedJockPack_03 = {}
local pedJockBathroomFirstFloor01
local pedJockBathroomFirstFloor01 = {}
local pedJockBathroomFirstFloor02
local pedJockBathroomFirstFloor02 = {}
local pedJockBathroomSecondFloor01
local pedJockBathroomSecondFloor01 = {}
local pedJockBathroomSecondFloor02
local pedJockBathroomSecondFloor02 = {}
local pedStage4JockNearLibrary01
local pedStage4JockNearLibrary01 = {}
local pedStage4JockNearLibrary02
local pedStage4JockNearLibrary02 = {}
local bEncounterJocksNearLibrary = false
local bBulliesRightAttack = false
local bEncounterJockPackWarning = false
local bBulliesLeftAttack = false
local bEncounterBathroomFirstFloor = false
local bEncounterBathroomSecondFloor = false
local bAlgieClosedFirstFloorStallDoor = false
local bTriggerAlgieLocker = false
local bBathroomWarning = false
local bWentInGirlsBathroom01 = false
local bWentInGirlsBathroom02 = false
local bAlgieNeedsToGo = false
local bAlgieDistanceCheck = true
local bMonitorForIdle = true
local cAlgieIdleTime = 400
local bBullyMadeIt = false
local bDeleteWierdos01 = false
local bDeleteWierdos02 = false
local bAmbientOn = false
local bPeeSoundOn = false
local bExteriorDoorsHandled = false
local bInteriorDoorsHandled = false
local bAlgieIsPissing = false
local timerAlgieHitWhine = 0
local timerAlgiePeeWhine = 0
local bFirstBullyWarn = false
local bFirstJockAttack = false
local bSecondJockAttack = false
local bStartBathroomSequence = false
local gPeeTimer = 0
local bPissLoop = true
local bStage1FirstBullyDead = false
local bStopFleeing = false
local bFirstJockHit = false
local bBullyObjective = false
local bAnticsLoop = true
local bUpstairsBulliesActive = false
local bFirstBullyAgro = false
local bHelpMeGuys = false
local bTimerStarted = false
local bLockerLocked = false
local bUnlockedStage2 = false
local bEuniceChat = false
local bIsAlgieInStallYet = false
local gStage = 0
local tempHour, tempMinute = 0, 0
local gMissionFailMessage = 0
local gAlgiePeeDanceWait = 30000
local gTimerInSeconds = 180
local bAlgieRightBullySpeech = false
local bAlgieLeftBullySpeech = false
local pedNumberAlgie = 0

function MissionSetup() -- ! Heavily modified
	shared.gCloseStallDoors = true
	--print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
	SoundPlayInteractiveStream("MS_FriendshipAllyLow.rsm", MUSIC_DEFAULT_VOLUME)
	SoundSetMidIntensityStream("MS_FriendshipAllyMid.rsm", MUSIC_DEFAULT_VOLUME)
	SoundSetHighIntensityStream("MS_FriendshipAllyHigh.rsm", MUSIC_DEFAULT_VOLUME)
	DATLoad("1_05.DAT", 2)
	DATLoad("1_05b.DAT", 2)
	DATInit()
	--[[
	DisablePOI()
	LoadAnimationGroup("2_08WeedKiller")
	LoadAnimationGroup("GEN_Social")
	LoadAnimationGroup("F_Pref")
	LoadAnimationGroup("Px_Sink")
	LoadAnimationGroup("Px_Gen")
	LoadAnimationGroup("NPC_Cheering")
	LoadAnimationGroup("POI_Smoking")
	LoadAnimationGroup("HUMIL_5-8F_A")
	WeaponRequestModel(300)
	WeaponRequestModel(405)
	WeaponRequestModel(362)
	PedRequestModel(102)
	PedRequestModel(99)
	PedRequestModel(85)
	PedRequestModel(145)
	PedRequestModel(146)
	PedRequestModel(147)
	LoadActionTree("Act/Conv/1_05.act")
	]]
	MissionDontFadeIn()
	PlayerSetControl(0)
	--PlayCutsceneWithLoad("1-05", true)
end

function MissionCleanup() -- ! Modified
	shared.gCloseStallDoors = nil
	--print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
	PedSetUniqueModelStatus(4, pedNumberAlgie)
	if gStage == 1 then
		F_MakeAmbient(pedFirstBully.id)
		F_MakeAmbient(pedBulliesRight01.id)
		F_MakeAmbient(pedBulliesRight02.id)
		F_MakeAmbient(pedBulliesLeft01.id)
		F_MakeAmbient(pedBulliesLeft02.id)
		F_MakeAmbient(pedBulliesLeft03.id)
	end
	F_CleanupAlgie()
	TextClear()
	DATUnload(2)
	DATInit()
	EnablePOI()
	MissionClearDisablePedTypes()
	UnLoadAnimationGroup("2_08WeedKiller")
	UnLoadAnimationGroup("GEN_Social")
	UnLoadAnimationGroup("F_Pref")
	UnLoadAnimationGroup("Px_Sink")
	UnLoadAnimationGroup("Px_Gen")
	UnLoadAnimationGroup("NPC_Cheering")
	UnLoadAnimationGroup("POI_Smoking")
	UnLoadAnimationGroup("HUMIL_5-8F_A")
	AreaEnableAllPatrolPaths()
	PedHideHealthBar()
	AreaRevertToDefaultPopulation()
	PAnimSetActionNode(TRIGGER._NLOCK02B06, "/Global/NLockA/Unlocked/Default", "Act/Props/NLockA.act")
	PAnimSetPropFlag(TRIGGER._NLOCK02B06, 11, false)
	PAnimSetPropFlag(TRIGGER._NLOCK02B06, 19, false)
	if pedAlgie.blip ~= nil then
		BlipRemove(pedAlgie.blip)
	end
	if blipLibrary then
		BlipRemove(blipLibrary)
	end
	if blipSchool then
		BlipRemove(blipSchool)
	end
	tempHour, tempMinute = ClockGet()
	if tempHour < 19 then
		AreaSetDoorLocked("DT_TSCHOOL_SCHOOLRIGHTFRONTDOOR", false)
		AreaSetDoorLocked("DT_TSCHOOL_SCHOOLRIGHTBACKDOOR", false)
		AreaSetDoorLocked("DT_TSCHOOL_SCHOOLLEFTBACKDOOR", false)
		AreaSetDoorLocked("DT_TSCHOOL_SCHOOLFRONTDOORL", false)
	end
	PedResetTypeAttitudesToDefault()
	SoundStopInteractiveStream()
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
	PlayerSetControl(1)
	--[[
	print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
	local isDemoBuild = false
	isDemoBuild = IsDemoBuildEnabled()
	if isDemoBuild == true then
		DemoBuildReturnToMain()
	end
	]]
end

function main()
	--print("()xxxxx[:::::::::::::::> [start] main()")
	F_Intro()
	F_Stage1()
	if bMissionFailed then
		TextPrint("1_05_EMPTY", 1, 1)
		SoundPlayMissionEndMusic(false, 4)
		if gMissionFailMessage == 1 then
			MissionFail(false, true, "1_05_FAIL_01")
		elseif gMissionFailMessage == 2 then
			MissionFail(false, true, "1_05_FAIL_02")
		elseif gMissionFailMessage == 3 then
			MissionFail(false, true, "1_05_FAIL_03")
		else
			MissionFail(false)
		end
	elseif bMissionPassed then
	end
	--print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_TableInit()
	--print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
	pedAlgie = {
		spawn = POINTLIST._1_05_SPAWNALGIE,
		element = 1,
		model = 4
	}
	pedFirstBully = {
		spawn = POINTLIST._1_05_SPAWNJOCKSNEARLIBRARY,
		element = 1,
		model = 99
	}
	pedJockPack_01 = {
		spawn = POINTLIST._1_05_SPAWNJOCKPACK,
		element = 1,
		model = 102
	}
	pedJockPack_02 = {
		spawn = POINTLIST._1_05_SPAWNJOCKPACK,
		element = 2,
		model = 99
	}
	pedJockPack_03 = {
		spawn = POINTLIST._1_05_SPAWNJOCKPACK,
		element = 3,
		model = 85
	}
	pedJockBathroomFirstFloor01 = {
		spawn = POINTLIST._1_05B_SPAWNJOCKSBRFIRSTFLOOR,
		element = 1,
		model = 85
	}
	pedJockBathroomFirstFloor02 = {
		spawn = POINTLIST._1_05B_SPAWNJOCKSBRFIRSTFLOOR,
		element = 2,
		model = 102
	}
	pedJockBathroomSecondFloor01 = {
		spawn = POINTLIST._1_05B_SPAWNSECONDFLOORAMBUSH,
		element = 1,
		model = 146
	}
	pedJockBathroomSecondFloor02 = {
		spawn = POINTLIST._1_05B_SPAWNSECONDFLOORAMBUSH,
		element = 2,
		model = 102
	}
	pedEunice = {
		spawn = POINTLIST._1_05B_SPAWNBATHROOMWIERDOS,
		element = 2,
		model = 74
	}
	pedBathroomWierdo02 = {
		spawn = POINTLIST._1_05B_SPAWNBATHROOMWIERDOS,
		element = 1,
		model = 69
	}
	pedBulliesRight01 = {
		spawn = POINTLIST._1_05_SPAWNBULLIESRIGHT,
		element = 1,
		model = 102
	}
	pedBulliesRight02 = {
		spawn = POINTLIST._1_05_SPAWNBULLIESRIGHT,
		element = 2,
		model = 146
	}
	pedBulliesLeft01 = {
		spawn = POINTLIST._1_05_SPAWNBULLIESLEFT,
		element = 1,
		model = 145
	}
	pedBulliesLeft02 = {
		spawn = POINTLIST._1_05_SPAWNBULLIESLEFT,
		element = 2,
		model = 146
	}
	pedBulliesLeft03 = {
		spawn = POINTLIST._1_05_SPAWNBULLIESLEFT,
		element = 3,
		model = 147
	}
	--print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_SetupWorld() -- ! Modified
	AreaClearAllPeds()
	--[[]
	local waitCount = 60
	while not AreaDisablePatrolPath(PATH._SGD_PREFECT2) and 0 < waitCount do
		Wait(33)
		waitCount = waitCount - 1
	end
	]]
	while not AreaDisablePatrolPath(PATH._SGD_PREFECT2) do
		Wait(0)
	end
	PedSetTypeToTypeAttitude(1, 13, 4)
	MissionDisablePedType(11, true)
	LoadWeaponModels({ 339, 398 })
	pedNumberAlgie = PedGetUniqueModelStatus(4)
	PedSetUniqueModelStatus(4, -1)
end

function F_Intro() -- ! Heavily modified
	--print("()xxxxx[:::::::::::::::> [start] F_Intro()")
	DisablePOI()
	LoadAnimationGroup("2_08WeedKiller")
	LoadAnimationGroup("GEN_Social")
	LoadAnimationGroup("F_Pref")
	LoadAnimationGroup("Px_Sink")
	LoadAnimationGroup("Px_Gen")
	LoadAnimationGroup("NPC_Cheering")
	LoadAnimationGroup("POI_Smoking")
	LoadAnimationGroup("HUMIL_5-8F_A")
	WeaponRequestModel(300)
	WeaponRequestModel(405)
	WeaponRequestModel(362)
	PedRequestModel(102)
	PedRequestModel(99)
	PedRequestModel(85)
	PedRequestModel(145)
	PedRequestModel(146)
	PedRequestModel(147)
	LoadActionTree("Act/Conv/1_05.act")
	F_TableInit()
	NISTable = { F_NIS_AlgieLocker, F_NIS_Outro }
	AreaTransitionPoint(0, POINTLIST._1_05_SPAWNPLAYER, 1, true)
	F_SetupWorld()
	F_Stage1_Setup()
	--[[
	local waitCount = 150
	while not AreaGetVisible() == 0 and 0 < waitCount do
		Wait(33)
		waitCount = waitCount - 1
	end
	]]
	while AreaGetVisible() == 0 do
		Wait(0)
	end
	Wait(100)
	CameraReturnToPlayer()
	PlayerSetControl(1)
	CameraFade(500, 1)
	Wait(500)
	TextPrint("1_05_MOBJ_01", 3, 1)
	gObjective01 = MissionObjectiveAdd("1_05_MOBJ_01")
	blipSchool = BlipAddPoint(POINTLIST._1_05_BLIPSCHOOL, 0)
	SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 10)
end

function F_Stage1()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
	F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
	F_LoadExteriorPeds()
	F_SetupAlgie()
	Wait(0)
	threadMonitorAlgie = CreateThread("T_MonitorAlgie")
	bMonitorAlgie = true
	threadMonitorPlayerLocation = CreateThread("T_MonitorPlayerLocation")
	bullyMaxHealth = PedGetHealth(pedFirstBully.id)
	gStage = 1
	POISetDisablePedProduction(POI._POIBULLIESRIGHT, true)
	PedSetTypeToTypeAttitude(1, 11, 2)
	F_LowerNerdPopulation()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
	while bLoop do
		F_Stage1Objectives()
		if bMissionFailed then
			break
		end
		if bGoToStage2 then
			F_Stage2()
			break
		end
		Wait(0)
	end
end

function F_Stage2()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2()")
	gStage = 2
	F_Stage2_Setup()
	F_Stage2_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2()")
end

function F_Stage2_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2_Setup()")
	Wait(0)
	F_CleanupExteriorPeds()
	F_SetupInteriorPeds()
	BlipRemove(blipSchool)
	if threadAlgieInSchoolTimer then
		TerminateThread(threadAlgieInSchoolTimer)
	end
	F_SetupBathroomBlips()
	threadStage2_Locates = CreateThread("T_Stage2_Locates")
	bathroomX, bathroomY, bathroomZ = GetPointList(POINTLIST._1_05B_BATHROOMCHECK)
	PlayerSetPunishmentPoints(0)
	SoundPlayScriptedSpeechEventWrapper(pedAlgie.id, "M_1_05", 99)
	bAlgieDistanceCheck = true
	threadBathroomAntics = CreateThread("T_BathroomAntics")
	gStage = 2
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
	while bLoop do
		if bTimerStarted and MissionTimerHasFinished() then
			F_AlgiePissSelf()
		end
		if bMissionFailed then
			break
		end
		if bFightingFirstFloorBathroomJocks and PedIsDead(pedJockBathroomFirstFloor01.id) and PedIsDead(pedJockBathroomFirstFloor02.id) then
			bAlgieDistanceCheck = false
			bAlgieNeedsToGo = false
			PedHideHealthBar()
			PedClearTether(pedAlgie.id)
			PedStop(pedAlgie.id)
			PedClearObjectives(pedAlgie.id)
			PedIgnoreStimuli(pedAlgie.id, true)
			F_BullyObjectiveRemove()
			--print("()xxxxx[:::::::::::::::> ALGIE SHOULD ENTER FIRST FLOOR STALL NOW")
			PedFollowPath(pedAlgie.id, PATH._1_05B_ROUTEFIRSTFLOORSTALL, 0, 1, F_routeFirstFloorStall)
			bFightingFirstFloorBathroomJocks = false
		end
		if bAlgieClosedFirstFloorStallDoor then
			PedFaceHeading(pedAlgie.id, -180, 0)
			Wait(750)
			PAnimCloseDoor(TRIGGER._STALDOOR11)
			Wait(1750)
			PAnimDoorStayOpen(TRIGGER._STALDOOR11)
			PAnimOpenDoor(TRIGGER._STALDOOR11)
			SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 19)
			TextPrint("1_05_MOBJ_02B", 3, 1)
			blipBathroomSecondFloor = BlipAddPoint(POINTLIST._1_05B_BLIPBATHROOMSECONDFLOOR, 0)
			gObjective02b = MissionObjectiveAdd("1_05_MOBJ_02B")
			bAlgieNeedsToGo = true
			bGoUpstairs = true
			bAlgieClosedFirstFloorStallDoor = false
		end
		if bGoUpstairs then
			F_SetupAlgieFollow()
			bGoUpstairs = false
			bAlgieDistanceCheck = true
		end
		if AreaGetVisible() == 2 then
			if PAnimExists(TRIGGER._NLOCK02B06) then
				if not bLockerLocked then
					cbLockerCreated()
					bLockerLocked = true
				end
			else
				bLockerLocked = false
			end
		end
		if bLaunchStage3 then
			F_Stage3()
			break
		end
		Wait(0)
	end
end

function F_Stage3()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage3()")
	gStage = 3
	F_Stage3_Setup()
	F_Stage3_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage3()")
end

function F_Stage3_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage3_Setup()")
	bMonitorForIdle = true
	bPissLoop = false
	bAnticsLoop = false
	AreaRevertToDefaultPopulation()
	F_SetupAlgieFollow()
	SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 31)
	WaitForInterval(3000)
	MissionObjectiveComplete(gObjective05)
	gObjective03 = MissionObjectiveAdd("1_05_MOBJ_03")
	TextPrint("1_05_MOBJ_03", 3, 1)
	TerminateThread(threadStage2_Locates)
	if F_PedExists(pedJockBathroomSecondFloor01.id) then
		BlipRemove(pedJockBathroomSecondFloor01.blip)
	end
	if F_PedExists(pedJockBathroomSecondFloor02.id) then
		BlipRemove(pedJockBathroomSecondFloor02.blip)
	end
	blipLocker = BlipAddPoint(POINTLIST._1_05B_BLIPALGIELOCKER, 0, 1, 1, 7)
	gStage = 3
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage3_Setup()")
end

function F_Stage3_Loop()
	while bLoop do
		if bMissionPassed or bMissionFailed then
			break
		end
		if AreaGetVisible() == 2 then
			if PAnimExists(TRIGGER._NLOCK02B06) then
				if not bLockerLocked then
					cbLockerCreated()
					bLockerLocked = true
				end
			else
				bLockerLocked = false
			end
		end
		if not bTriggerAlgieLocker and PlayerIsInTrigger(TRIGGER._1_05B_ALGIELOCKER) then
			--print("()xxxxx[:::::::::::::::> Launch F_NIS_AlgieLocker()")
			F_NIS_AlgieLocker()
			bMissionPassed = true
			bTriggerAlgieLocker = true
		end
		Wait(0)
	end
end

function F_Stage1Objectives()
	if not bEncounterJocksNearLibrary and PedIsInTrigger(gPlayer, TRIGGER._1_05_TRIGGERJOCKSNEARLIBRARY) then
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 11)
		F_EncounterFirstBully()
		bEncounterJocksNearLibrary = true
	end
	if not bFirstJockAttack and not bFirstJockHit and F_HitByPlayer(pedFirstBully.id) then
		PedStop(pedFirstBully.id)
		PedClearObjectives(pedFirstBully.id)
		bFirstJockHit = true
		bFirstJockAttack = true
	end
	if bFirstJockAttack then
		F_Stage1FirstBullyAttacking()
		bFirstJockAttack = false
	end
	if bFirstBullyAgro then
		if bBulliesLeftAttack and bBulliesRightAttack then
			if PedIsDead(pedFirstBully.id) and PedIsDead(pedBulliesLeft01.id) and PedIsDead(pedBulliesLeft02.id) and PedIsDead(pedBulliesLeft03.id) and PedIsDead(pedBulliesRight01.id) and PedIsDead(pedBulliesRight02.id) and not bUnlockedStage2 then
				threadUnlockStage2 = CreateThread("F_UnlockStage2")
				bUnlockedStage2 = true
			end
		elseif bBulliesRightAttack then
			if PedIsDead(pedFirstBully.id) and PedIsDead(pedBulliesRight01.id) and PedIsDead(pedBulliesRight02.id) and not bUnlockedStage2 then
				threadUnlockStage2 = CreateThread("F_UnlockStage2")
				bUnlockedStage2 = true
			end
		elseif bBulliesLeftAttack then
			if PedIsDead(pedFirstBully.id) and PedIsDead(pedBulliesLeft01.id) and PedIsDead(pedBulliesLeft02.id) and PedIsDead(pedBulliesLeft03.id) and not bUnlockedStage2 then
				threadUnlockStage2 = CreateThread("F_UnlockStage2")
				bUnlockedStage2 = true
			end
		elseif PedIsDead(pedFirstBully.id) and not bUnlockedStage2 then
			threadUnlockStage2 = CreateThread("F_UnlockStage2")
			bUnlockedStage2 = true
		end
	end
	if not bBulliesRightAttack and (PedIsInTrigger(gPlayer, TRIGGER._1_05_TRIGGERJOCKSNEARFRONT) or F_CheckRightForHit()) then
		F_BulliesRightAttack()
		bBulliesRightAttack = true
	end
	if not bBulliesLeftAttack and (PedIsInTrigger(gPlayer, TRIGGER._1_05_TRIGGERJOCKPACK) or F_CheckLeftForHit()) then
		F_BulliesLeftAttack()
		bBulliesLeftAttack = true
	end
	if not bAlgieRightBullySpeech and bUnlockedStage2 and bBulliesRightAttack and PedIsDead(pedBulliesRight01.id) and PedIsDead(pedBulliesRight02.id) then
		SoundStopCurrentSpeechEvent(pedAlgie.id)
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 10)
		bAlgieRightBullySpeech = true
	end
	if not bAlgieLeftBullySpeech and bUnlockedStage2 and bBulliesLeftAttack and PedIsDead(pedBulliesLeft01.id) and PedIsDead(pedBulliesLeft02.id) and PedIsDead(pedBulliesLeft03.id) then
		SoundStopCurrentSpeechEvent(pedAlgie.id)
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 10)
		bAlgieLeftBullySpeech = true
	end
	if not bStopFleeing and PedGetHealth(pedFirstBully.id) < bullyMaxHealth / 2 then
		--print("()xxxxx[:::::::::::::::> BULLY TRYING TO FLEE")
		PedClearObjectives(pedFirstBully.id)
		PedFollowPath(pedFirstBully.id, PATH._1_05_ROUTEBULLYFLEENEW, 0, 2, F_routeBullyFleeNew, 1)
		if not bFirstBullyWarn then
			SoundPlayScriptedSpeechEvent(pedFirstBully.id, "M_1_05", 2)
			bFirstBullyWarn = true
		end
		Wait(1000)
		if PedIsDead(pedFirstBully.id) then
			bStopFleeing = true
		end
	end
	if not bEncounterJockPackWarning and PedIsInTrigger(gPlayer, TRIGGER._1_05_TRIGGERJOCKPACKWARNING) then
		--print("()xxxxx[:::::::::::::::> Launch F_EncounterJockPackWarning()")
		F_EncounterJockPackWarning()
		bEncounterJockPackWarning = true
	end
	if PlayerIsInTrigger(TRIGGER._1_05_FRONTDOOROFF) then
		bAlgieDistanceCheck = false
		--print("()xxxxx[:::::::::::::::> MONITORFORDISTANCE = FALSE")
	end
	if PlayerIsInTrigger(TRIGGER._TRIGGERSTAGE4FRONTDOOR) then
		bAlgieDistanceCheck = true
		--print("()xxxxx[:::::::::::::::> MONITORFORDISTANCE = TRUE")
	end
	if PlayerIsInTrigger(TRIGGER._1_05_BACKDOOROFF) then
		bAlgieDistanceCheck = false
		--print("()xxxxx[:::::::::::::::> MONITORFORDISTANCE = FALSE")
	end
	if PlayerIsInTrigger(TRIGGER._TRIGGERSTAGE4REARRIGHT) then
		bAlgieDistanceCheck = true
		--print("()xxxxx[:::::::::::::::> MONITORFORDISTANCE = TRUE")
	end
	if bTimerStarted and MissionTimerHasFinished() then
		F_AlgiePissSelf()
	end
	if bPlayerIsInSchool and bStage1BulliesDefeated then
		bGoToStage2 = true
	end
end

function F_LoadExteriorPeds()
	--print("()xxxxx[:::::::::::::::> [start] F_LoadExteriorPeds()")
	pedFirstBully.id = PedCreatePoint(pedFirstBully.model, pedFirstBully.spawn, pedFirstBully.element)
	PedSetInfiniteSprint(pedFirstBully.id, true)
	PedSetInvulnerable(pedFirstBully.id, true)
	PedCanTeleportOnAreaTransition(pedFirstBully.id, false)
	pedBulliesRight01.id = PedCreatePoint(pedBulliesRight01.model, pedBulliesRight01.spawn, pedBulliesRight01.element)
	PedOverrideStat(pedBulliesRight01.id, 0, 362)
	PedOverrideStat(pedBulliesRight01.id, 1, 100)
	PedSetPOI(pedBulliesRight01.id, POI._POIBULLIESRIGHT, false)
	PedCanTeleportOnAreaTransition(pedBulliesRight01.id, false)
	pedBulliesRight02.id = PedCreatePoint(pedBulliesRight02.model, pedBulliesRight02.spawn, pedBulliesRight02.element)
	PedSetPOI(pedBulliesRight02.id, POI._POIBULLIESRIGHT, false)
	PedCanTeleportOnAreaTransition(pedBulliesRight02.id, false)
	pedBulliesLeft01.id = PedCreatePoint(pedBulliesLeft01.model, pedBulliesLeft01.spawn, pedBulliesLeft01.element)
	PedOverrideStat(pedBulliesLeft01.id, 0, 362)
	PedOverrideStat(pedBulliesLeft01.id, 1, 100)
	PedCanTeleportOnAreaTransition(pedBulliesLeft01.id, false)
	pedBulliesLeft02.id = PedCreatePoint(pedBulliesLeft02.model, pedBulliesLeft02.spawn, pedBulliesLeft02.element)
	PedCanTeleportOnAreaTransition(pedBulliesLeft02.id, false)
	pedBulliesLeft03.id = PedCreatePoint(pedBulliesLeft03.model, pedBulliesLeft03.spawn, pedBulliesLeft03.element)
	PedCanTeleportOnAreaTransition(pedBulliesLeft03.id, false)
	--print("()xxxxx[:::::::::::::::> [finish] F_LoadExteriorPeds()")
end

function F_SetupAlgie()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupAlgie()")
	pedAlgie.id = PedCreatePoint(pedAlgie.model, pedAlgie.spawn, pedAlgie.element)
	PedSetMissionCritical(pedAlgie.id, true, F_MissionCritical, false)
	PedSetFlag(pedAlgie.id, 106, false)
	PedRecruitAlly(gPlayer, pedAlgie.id)
	PedOverrideStat(pedAlgie.id, 6, 75)
	PedOverrideStat(pedAlgie.id, 12, 30)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupAlgie()")
end

function F_SetupBathroomBlips()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupBathroomBlips()")
	blipBathroomSecondFloor = BlipAddPoint(POINTLIST._1_05B_BLIPBATHROOMSECONDFLOOR, 0)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupBathroomBlips()")
end

function F_StopAlgie()
	PedSetMissionCritical(pedAlgie.id, false)
	PedDismissAlly(gPlayer, pedAlgie.id)
	pedAlgie.blip = AddBlipForChar(pedAlgie.id, 1, 27, 1, 0)
	PedSetFlag(pedAlgie.id, 20, true)
	PedShowHealthBar(pedAlgie.id, true, "1_05_HEALTHBAR", false)
	PedIgnoreStimuli(pedAlgie.id, true)
end

function F_SetupAlgieFollow()
	PedSetMissionCritical(pedAlgie.id, true, F_MissionCritical, false)
	PedSetFlag(pedAlgie.id, 20, false)
	PedHideHealthBar()
	BlipRemove(pedAlgie.blip)
	PedRecruitAlly(gPlayer, pedAlgie.id)
	PedIgnoreStimuli(pedAlgie.id, false)
end

function F_CleanupExteriorPeds()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupExteriorPeds()")
	F_CharDelete(pedFirstBully.id)
	F_CharDelete(pedBulliesRight01.id)
	F_CharDelete(pedBulliesRight02.id)
	F_CharDelete(pedBulliesLeft01.id)
	F_CharDelete(pedBulliesLeft02.id)
	F_CharDelete(pedBulliesLeft03.id)
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupExteriorPeds()")
end

function F_SetupInteriorPeds()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupInteriorPeds()")
	pedJockBathroomFirstFloor01.id = PedCreatePoint(pedJockBathroomFirstFloor01.model, pedJockBathroomFirstFloor01.spawn, pedJockBathroomFirstFloor01.element)
	pedJockBathroomFirstFloor02.id = PedCreatePoint(pedJockBathroomFirstFloor02.model, pedJockBathroomFirstFloor02.spawn, pedJockBathroomFirstFloor02.element)
	PedSetActionNode(pedJockBathroomFirstFloor02.id, "/Global/Generic/GenericWallSmoking", "Act/Anim/GenericSequences.act")
	PedOverrideStat(pedJockBathroomFirstFloor02.id, 0, 362)
	PedOverrideStat(pedJockBathroomFirstFloor02.id, 1, 100)
	pedEunice.id = PedCreatePoint(pedEunice.model, pedEunice.spawn, pedEunice.element)
	pedBathroomWierdo02.id = PedCreatePoint(pedBathroomWierdo02.model, pedBathroomWierdo02.spawn, pedBathroomWierdo02.element)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupInteriorPeds()")
end

function F_CharDelete(pedID)
	if not PedIsDead(pedID) then
		PedDelete(pedID)
	end
end

function F_EncounterBathroomFirstFloor()
	--print("()xxxxx[:::::::::::::::> [start] F_EncounterBathroomFirstFloor()")
	F_CleanupBathroomBlips()
	MissionObjectiveRemove(gObjective02)
	F_BullyObjectiveAdd()
	PedSetActionNode(pedJockBathroomFirstFloor02.id, "/Global/Generic/GenericWallSmoking/EndingSequences/PutOutCigEnd", "Act/Anim/GenericSequences.act")
	pedJockBathroomFirstFloor01.blip = AddBlipForChar(pedJockBathroomFirstFloor01.id, 11, 26, 1)
	pedJockBathroomFirstFloor02.blip = AddBlipForChar(pedJockBathroomFirstFloor02.id, 11, 26, 1)
	PedFaceObject(pedJockBathroomFirstFloor01.id, gPlayer, 3, 1)
	PedFaceObject(pedJockBathroomFirstFloor02.id, gPlayer, 3, 1)
	Wait(500)
	F_StopAlgie()
	PedIgnoreStimuli(pedAlgie.id, false)
	PedMoveToPoint(pedAlgie.id, 1, POINTLIST._1_05B_ALGIETETHER, 1, cbAlgieRanInFirstFloor, 2)
	PedSetMissionCritical(pedAlgie.id, true, F_MissionCritical, false)
	PedRestrictToTrigger(pedJockBathroomFirstFloor01.id, TRIGGER._1_05B_BATHROOMFIRSTFLOOR)
	PedRestrictToTrigger(pedJockBathroomFirstFloor02.id, TRIGGER._1_05B_BATHROOMFIRSTFLOOR)
	PedAttackPlayer(pedJockBathroomFirstFloor01.id, 1)
	PedAttack(pedJockBathroomFirstFloor02.id, pedAlgie.id, 1)
	bFightingFirstFloorBathroomJocks = true
	--print("()xxxxx[:::::::::::::::> [finish] F_EncounterBathroomFirstFloor()")
end

function F_EncounterBathroomSecondFloor()
	--print("()xxxxx[:::::::::::::::> [start] F_EncounterBathroomSecondFloor()")
	if not bBathroomWarning then
		TextPrint("1_05_MOBJ_05", 5, 1)
		if gObjective04 then
			MissionObjectiveComplete(gObjective04)
		end
		if not gObjective05 then
			if gObjective02 then
				MissionObjectiveComplete(gObjective02)
			end
			if gObjective02b then
				MissionObjectiveComplete(gObjective02b)
			end
			gObjective05 = MissionObjectiveAdd("1_05_MOBJ_05")
		end
		bBathroomWarning = true
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_EncounterBathroomSecondFloor()")
end

function F_CleanupStage2InteriorPeds()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupStage2InteriorPeds()")
	F_CharDelete(pedJockBathroomFirstFloor01.id)
	F_CharDelete(pedJockBathroomFirstFloor02.id)
	F_CharDelete(pedJockBathroomSecondFloor01.id)
	F_CharDelete(pedJockBathroomSecondFloor02.id)
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupStage2InteriorPeds()")
end

function F_CleanupBathroomBlips()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupBathroomBlips()")
	if blipBathroomSecondFloor then
		BlipRemove(blipBathroomSecondFloor)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupBathroomBlips()")
end

function WaitForInterval(interval)
	local timerStart = GetTimer()
	while interval > GetTimer() - timerStart do
		Wait(0)
	end
end

function F_AlgieWhine()
	if not bAlgieWhine01 then
		timerAlgieWhine = GetTimer()
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 27)
		bAlgieWhine01 = true
	end
	if bAlgieWhine01 and not bAlgieWhine02 and timerAlgieWhine + 20000 < GetTimer() then
		timerAlgieWhine = GetTimer()
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 27)
		bAlgieWhine02 = true
	end
	if bAlgieWhine03 and not bAlgieWhine04 and timerAlgieWhine + 20000 < GetTimer() then
		timerAlgieWhine = GetTimer()
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 27)
		bAlgieWhine04 = true
	end
end

function F_Stage4SetupPeds()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage4SetupPeds()")
	pedStage4JockNearLibrary01.id = PedCreatePoint(pedStage4JockNearLibrary01.model, pedStage4JockNearLibrary01.spawn, pedStage4JockNearLibrary01.element)
	pedStage4JockNearLibrary02.id = PedCreatePoint(pedStage4JockNearLibrary02.model, pedStage4JockNearLibrary02.spawn, pedStage4JockNearLibrary02.element)
	PedSetWeapon(pedStage4JockNearLibrary01.id, 300, 1)
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage4SetupPeds()")
end

function F_DanceDecision()
	if bAlgieNeedsToGo then
		--print("()xxxxx[:::::::::::::::> [spam] F_DanceDecision() true")
		return 1
	else
		--print("()xxxxx[:::::::::::::::> [spam] F_DanceDecision() false")
		return 0
	end
end

function F_AlgieComplainIdle()
	--print("()xxxxx[:::::::::::::::> [start] F_AlgieComplainIdle()")
	math.randomseed(GetTimer())
	local intRandom = math.random(1, 3)
	if bAlgieNeedsToGo then
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 15)
	else
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 10)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_AlgieComplainIdle()")
end

function F_AlgiePeeDanceDialogue()
	--print("()xxxxx[:::::::::::::::> [start] F_AlgiePeeDanceDialogue()")
	if GetTimer() >= timerAlgiePeeWhine + gAlgiePeeDanceWait then
		SoundStopCurrentSpeechEvent(pedAlgie.id)
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 15)
		timerAlgiePeeWhine = GetTimer()
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_AlgiePeeDanceDialogue()")
end

function F_BathroomSequence()
	--print("()xxxxx[:::::::::::::::> [start] F_BathroomSequence()")
	PAnimDoorStayOpen(TRIGGER._STALDOOR01)
	PAnimOpenDoor(TRIGGER._STALDOOR01)
	Wait(250)
	PedFollowPath(pedBathroomWierdo02.id, PATH._1_05B_ROUTEBATHROOMWIERDOS, 0, 1, F_routeBathroomWierdos)
	Wait(250)
	PedFollowPath(pedEunice.id, PATH._1_05B_ROUTEBATHROOMWIERDOS, 0, 1, F_routeBathroomWierdos)
	SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 25)
	pedJockBathroomSecondFloor01.id = PedCreatePoint(pedJockBathroomSecondFloor01.model, pedJockBathroomSecondFloor01.spawn, pedJockBathroomSecondFloor01.element)
	PedClearAllWeapons(pedJockBathroomSecondFloor01.id)
	pedJockBathroomSecondFloor02.id = PedCreatePoint(pedJockBathroomSecondFloor02.model, pedJockBathroomSecondFloor02.spawn, pedJockBathroomSecondFloor02.element)
	PedClearAllWeapons(pedJockBathroomSecondFloor02.id)
	PedFollowPath(pedJockBathroomSecondFloor01.id, PATH._1_05B_ROUTESECONDFLOORAMBUSH, 0, 1, F_routeSecondFloorAmbush)
	PedFollowPath(pedJockBathroomSecondFloor02.id, PATH._1_05B_ROUTESECONDFLOORAMBUSH, 0, 1, F_routeSecondFloorAmbush)
	PedOverrideStat(pedJockBathroomSecondFloor01.id, 0, 362)
	PedOverrideStat(pedJockBathroomSecondFloor01.id, 1, 100)
	threadMonitorAlgiePee = CreateThread("T_MonitorAlgiePee")
	bUpstairsBulliesActive = true
	--print("()xxxxx[:::::::::::::::> [finish] F_BathroomSequence()")
end

function F_HandleInteriorDoors()
	--print("()xxxxx[:::::::::::::::> [start] F_HandleInteriorDoors()")
	AreaSetDoorLocked(TRIGGER._STALDOOR01, true)
	AreaSetDoorLocked(TRIGGER._STALDOOR02, true)
	PAnimSetActionNode(TRIGGER._NLOCK02B06, "/Global/NLockA/Unlocked/NotUseable", "Act/Props/NLockA.act")
	--print("()xxxxx[:::::::::::::::> [finish] F_HandleInteriorDoors()")
end

function F_HandleExteriorDoors()
	--print("()xxxxx[:::::::::::::::> [start] F_HandleExteriorDoors()")
	if not bStage1BulliesDefeated then
		AreaSetDoorLocked("DT_TSCHOOL_SCHOOLRIGHTFRONTDOOR", true)
		AreaSetDoorLocked("DT_TSCHOOL_SCHOOLRIGHTBACKDOOR", true)
		AreaSetDoorLocked("DT_TSCHOOL_SCHOOLLEFTBACKDOOR", true)
		AreaSetDoorLocked("DT_TSCHOOL_SCHOOLFRONTDOORL", true)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_HandleExteriorDoors()")
end

function F_AlgieHitWhine()
	--print("()xxxxx[:::::::::::::::> [start] F_AlgieHitWhine()")
	if GetTimer() >= timerAlgieHitWhine + 5000 then
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 18)
		timerAlgieHitWhine = GetTimer()
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_AlgieHitWhine()")
end

function F_Stage1FirstBullyAttacking()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1FirstBullyAttacking()")
	bFirstJockHit = true
	F_BullyObjectiveAdd()
	SoundPlayScriptedSpeechEvent(pedFirstBully.id, "M_1_05", 1, "large")
	pedFirstBully.blip = AddBlipForChar(pedFirstBully.id, 11, 26, 4)
	PedStop(pedFirstBully.id)
	PedAttack(pedFirstBully.id, pedAlgie.id, 1)
	if blipSchool then
		BlipRemove(blipSchool)
	end
	bFirstBullyAgro = true
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1FirstBullyAttacking()")
end

function F_BullyObjectiveAdd()
	--print("()xxxxx[:::::::::::::::> [start] F_BullyObjectiveAdd()")
	if not bBullyObjective then
		TextPrint("1_05_MOBJ_00", 3, 1)
		gObjective00 = MissionObjectiveAdd("1_05_MOBJ_00")
		bBullyObjective = true
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_BullyObjectiveAdd()")
end

function F_BullyObjectiveRemove()
	--print("()xxxxx[:::::::::::::::> [start] F_BullyObjectiveRemove()")
	if bBullyObjective then
		MissionObjectiveComplete(gObjective00)
		bBullyObjective = false
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_BullyObjectiveRemove()")
end

function F_MissionCritical()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCritical()")
	PedMakeAmbient(pedAlgie.id)
	gMissionFailMessage = 1
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCritical()")
end

function F_UnlockStage2()
	--print("()xxxxx[:::::::::::::::> [start] F_UnlockStage2()")
	bAlgieNeedsToGo = true
	bStage1BulliesDefeated = true
	bFirstBullyAgro = false
	bStage1FirstBullyDead = true
	SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 13)
	MissionObjectiveRemove(gObjective01)
	MissionObjectiveComplete(gObjective00)
	Wait(3000)
	blipSchool = BlipAddPoint(POINTLIST._1_05_BLIPSCHOOL, 0)
	gObjective02 = MissionObjectiveAdd("1_05_MOBJ_02")
	TextPrint("1_05_MOBJ_02", 4, 1)
	Wait(4000)
	TutorialStart("Timer")
	F_StartTimer(gTimerInSeconds)
	--print("()xxxxx[:::::::::::::::> [finish] F_UnlockStage2()")
end

function F_BulliesLeftAttack()
	--print("()xxxxx[:::::::::::::::> [start] F_BulliesLeftAttack()")
	if not bStage1FirstBullyDead and not bHelpMeGuys then
		SoundPlayScriptedSpeechEvent(pedFirstBully.id, "M_1_05", 3)
		bHelpMeGuys = true
	end
	if not bStage1BulliesDefeated then
		pedBulliesLeft01.blip = AddBlipForChar(pedBulliesLeft01.id, 11, 26, 4)
		pedBulliesLeft02.blip = AddBlipForChar(pedBulliesLeft02.id, 11, 26, 4)
		pedBulliesLeft03.blip = AddBlipForChar(pedBulliesLeft03.id, 11, 26, 4)
	end
	PedAttackPlayer(pedBulliesLeft01.id, 1)
	PedAttackPlayer(pedBulliesLeft02.id, 1)
	PedAttack(pedBulliesLeft03.id, pedAlgie.id, 1)
	bStopFleeing = true
	if not PedIsDead(pedFirstBully.id) then
		PedAttack(pedFirstBully.id, pedAlgie.id, 1)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_BulliesLeftAttack()")
end

function F_BulliesRightAttack()
	--print("()xxxxx[:::::::::::::::> [start] F_BulliesRightAttack()")
	if not bStage1FirstBullyDead and not bHelpMeGuys then
		SoundPlayScriptedSpeechEventWrapper(pedFirstBully.id, "M_1_05", 3)
		bHelpMeGuys = true
	end
	Wait(500)
	SoundPlayScriptedSpeechEventWrapper(pedBulliesRight02.id, "M_1_05", 4)
	if not bStage1BulliesDefeated then
		pedBulliesRight01.blip = AddBlipForChar(pedBulliesRight01.id, 11, 26, 4)
		pedBulliesRight02.blip = AddBlipForChar(pedBulliesRight02.id, 11, 26, 4)
	end
	PedClearPOI(pedBulliesRight01.id)
	PedClearPOI(pedBulliesRight02.id)
	PedAttackPlayer(pedBulliesRight01.id, 1)
	PedAttack(pedBulliesRight02.id, pedAlgie.id, 1)
	bStopFleeing = true
	if not PedIsDead(pedFirstBully.id) then
		PedAttack(pedFirstBully.id, pedAlgie.id, 1)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_BulliesRightAttack()")
end

function F_CheckRightForHit()
	if F_HitByPlayer(pedBulliesRight01.id) or F_HitByPlayer(pedBulliesRight02.id) then
		return true
	else
		return false
	end
end

function F_CheckLeftForHit()
	if F_HitByPlayer(pedBulliesLeft01.id) or F_HitByPlayer(pedBulliesLeft02.id) or F_HitByPlayer(pedBulliesLeft03.id) then
		return true
	else
		return false
	end
end

function F_StartTimer(seconds)
	--print("()xxxxx[:::::::::::::::> [start] F_StartTimer()")
	MissionTimerStart(seconds)
	bTimerStarted = true
	--print("()xxxxx[:::::::::::::::> [finish] F_StartTimer()")
end

function F_StopTimer()
	--print("()xxxxx[:::::::::::::::> [start] F_StopTimer()")
	MissionTimerStop()
	bTimerStarted = false
	--print("()xxxxx[:::::::::::::::> [finish] F_StopTimer()")
end

function F_AlgiePissSelf()
	--print("()xxxxx[:::::::::::::::> [start] F_AlgiePissSelf()")
	F_StopTimer()
	bAlgieNeedsToGo = false
	SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 29)
	PedSetActionNode(pedAlgie.id, "/Global/1_05/Anims/PissSelf/PeeSelf", "Act/Conv/1_05.act")
	Wait(8000)
	PedDismissAlly(gPlayer, pedAlgie.id)
	PedMakeAmbient(pedAlgie.id)
	gMissionFailMessage = 2
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_AlgiePissSelf()")
end

function cbLockerCreated()
	--print("()xxxxx[:::::::::::::::> [start] cbLockerCreated()")
	PAnimSetActionNode(TRIGGER._NLOCK02B06, "/Global/NLockA/Unlocked/NotUseable", "Act/Props/NLockA.act")
	PAnimSetPropFlag(TRIGGER._NLOCK02B06, 11, true)
	PAnimSetPropFlag(TRIGGER._NLOCK02B06, 19, true)
	--print("()xxxxx[:::::::::::::::> [finish] cbLockerCreated()")
end

function F_HitByPlayer(ped)
	if PedIsHit(ped, 2, 500) and PedGetWhoHitMeLast(ped) == gPlayer then
		return true
	end
	return false
end

function cbAlgieRanInFirstFloor()
	--print("()xxxxx[:::::::::::::::> [start] cbAlgieRanInFirstFloor()")
	PedStop(pedJockBathroomFirstFloor01.id)
	PedStop(pedJockBathroomFirstFloor02.id)
	PedClearObjectives(pedJockBathroomFirstFloor01.id)
	PedClearObjectives(pedJockBathroomFirstFloor02.id)
	PedAttack(pedJockBathroomFirstFloor01.id, pedAlgie.id, 1)
	PedAttack(pedJockBathroomFirstFloor02.id, pedAlgie.id, 1)
	PedSetTetherToPoint(pedAlgie.id, POINTLIST._1_05B_ALGIETETHER, 1, 2)
	--print("()xxxxx[:::::::::::::::> [finish] cbAlgieRanInFirstFloor()")
end

function F_MakeAmbient(pedID)
	if F_PedExists(pedID) then
		PedMakeAmbient(pedID)
	end
end

function F_LowerNerdPopulation()
	--print("()xxxxx[:::::::::::::::> [start] F_LowerNerdPopulation()")
	AreaOverridePopulationPedType(1, 2)
	--print("()xxxxx[:::::::::::::::> [finish] F_LowerNerdPopulation()")
end

function F_CleanupAlgie()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupAlgie()")
	if F_PedExists(pedAlgie.id) then
		PedSetMissionCritical(pedAlgie.id, false)
		PedMakeAmbient(pedAlgie.id)
		PedDismissAlly(gPlayer, pedAlgie.id)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupAlgie()")
end

function F_WaitForSpeech(pedID)
	--print("()xxxxx[:::::::::::::::> [start] F_WaitForSpeech()")
	if pedID == nil then
		while SoundSpeechPlaying() do
			Wait(0)
		end
	else
		while SoundSpeechPlaying(pedID) do
			Wait(0)
		end
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_WaitForSpeech()")
end

function F_CheckClockFailure()
	tempHour, tempMinute = ClockGet()
	if 23 <= tempHour and 1 <= tempMinute and AreaGetVisible() ~= 2 then
		gMissionFailMessage = 3
		bMissionFailed = true
	end
end

function F_CutAlgieToStall()
	PlayerSetControl(0)
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	bMonitorForIdle = false
	bAlgieNeedsToGo = false
	F_CleanupBathroomBlips()
	SoundPlayScriptedSpeechEventWrapper(pedAlgie.id, "M_1_05", 21)
	F_StopAlgie()
	PedPathNodeReachedDistance(pedAlgie.id, 0.5)
	PedSetActionNode(gPlayer, "/Global/1_05/Anims/Empty", "Act/Conv/1_05.act")
	PedMoveToPoint(gPlayer, 1, POINTLIST._1_05B_BLIPBATHROOMSECONDFLOOR, 1, F_cbPlayerWaiting)
	PedSetActionNode(pedAlgie.id, "/Global/1_05/Anims/Empty", "Act/Conv/1_05.act")
	PedFollowPath(pedAlgie.id, PATH._1_05B_ROUTEALGIESTALL, 0, 1, F_routeAlgieStall)
	CameraSetXYZ(-668.3964, -325.4147, 6.420433, -668.85815, -326.30154, 6.405958)
	while not bIsAlgieInStallYet do
		Wait(0)
	end
	CameraSetWidescreen(false)
	F_MakePlayerSafeForNIS(false)
	CameraReturnToPlayer()
	PlayerSetControl(1)
	bStartBathroomSequence = true
end

function F_NIS_AlgieLocker()
	--print("()xxxxx[:::::::::::::::> [start] F_NIS_AlgieLocker()")
	bMonitorForIdle = false
	if b_DebuggingNIS then
		AreaTransitionPoint(2, POINTLIST._1_05B_NIS_LOCKER)
		local tempX, tempY, tempZ = GetPointFromPointList(POINTLIST._1_05B_NIS_LOCKER, 2)
		PedSetPosXYZ(pedAlgie.id, tempX, tempY, tempZ)
		while IsStreamingBusy() do
			Wait(0)
		end
		PAnimSetActionNode(TRIGGER._NLOCK02B06, "/Global/NLockA/Unlocked/NotUseable", "Act/Props/NLockA.act")
	end
	local cameraX, cameraY, cameraZ = GetPointList(POINTLIST._1_05B_CAMERALOCKER)
	local lookX, lookY, lookZ = GetPointFromPointList(POINTLIST._1_05B_NIS_LOCKER, 2)
	CameraFade(500, 0)
	Wait(500)
	PlayerSetControl(0)
	F_MakePlayerSafeForNIS(true)
	BlipRemove(blipLocker)
	PedSetMissionCritical(pedAlgie.id, false)
	PedDismissAlly(gPlayer, pedAlgie.id)
	PlayerSetPosPoint(POINTLIST._1_05B_NIS_LOCKER, 1)
	PedStop(pedAlgie.id)
	PedClearObjectives(pedAlgie.id)
	PedSetActionNode(pedAlgie.id, "/Global/1_05/Anims/Empty", "Act/Conv/1_05.act")
	PedSetPosPoint(pedAlgie.id, POINTLIST._1_05B_NIS_LOCKER, 2)
	CameraSetWidescreen(true)
	CameraSetXYZ(-654.11884, -295.7761, 6.852561, -654.76294, -296.53342, 6.745663)
	if PedIsValid(pedJockBathroomSecondFloor01.id) then
		PedDelete(pedJockBathroomSecondFloor01.id)
	end
	if PedIsValid(pedJockBathroomSecondFloor02.id) then
		PedDelete(pedJockBathroomSecondFloor02.id)
	end
	CameraFade(500, 1)
	Wait(500)
	SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 34)
	F_StopAlgie()
	PedFollowPath(pedAlgie.id, PATH._1_05B_ROUTEALGIELOCKER, 0, 1, F_routeAlgieLocker)
	while not PedIsPlaying(pedAlgie.id, "/Global/NLockA/PedPropsActions/Interact/NPCGetItem/GetBooks/NPCGetItem/GetItem/CloseDoor", false) do
		PedFaceObject(gPlayer, pedAlgie.id, 2, 1)
		Wait(0)
	end
	PedSetWeapon(pedAlgie.id, 405, 1)
	Wait(1000)
	PedPathNodeReachedDistance(pedAlgie.id, 0)
	PedFollowPath(pedAlgie.id, PATH._1_05B_ALGIEFLEE, 0, 0)
	Wait(800)
	PedStop(pedAlgie.id)
	PedFaceObject(pedAlgie.id, gPlayer, 3, 0)
	PedFaceObject(gPlayer, pedAlgie.id, 2, 1, false)
	Wait(500)
	PedLockTarget(gPlayer, pedAlgie.id, 3)
	PedSetActionNode(gPlayer, "/Global/Player/Gifts/GetMoney", "Act/Player.act")
	while PedIsPlaying(gPlayer, "/Global/Player/Gifts/GetMoney", true) do
		Wait(0)
	end
	PedClearObjectives(gPlayer)
	PedMakeAmbient(pedAlgie.id)
	SetFactionRespect(11, 10)
	SetFactionRespect(1, 60)
	MinigameSetCompletion("M_PASS", true, 500)
	SoundPlayMissionEndMusic(true, 4)
	Wait(500)
	MinigameAddCompletionMsg("MRESPECT_NP5", 2)
	MinigameAddCompletionMsg("MRESPECT_BM10", 1)
	PedLockTarget(gPlayer, -1, 1)
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	CameraFade(500, 0)
	Wait(501)
	CameraReset()
	CameraReturnToPlayer()
	F_MakePlayerSafeForNIS(false)
	PedClearObjectives(gPlayer)
	MissionSucceed(false, false, false)
	--print("()xxxxx[:::::::::::::::> [finish] F_NIS_AlgieLocker()")
	Wait(500)
	CameraFade(500, 1)
	Wait(101)
	PlayerSetControl(1)
end

function T_MonitorAlgie()
	local idleCounter = 0
	while bMonitorAlgie do
		if bAlgieNeedsToGo and gPeeTimer + gAlgiePeeDanceWait < GetTimer() then
			PedSetActionNode(pedAlgie.id, "/Global/1_05/Anims/PeeDance", "Act/Conv/1_05.act")
			gPeeTimer = GetTimer()
		end
		if bMonitorForIdle then
			if PedIsPlaying(gPlayer, "/Global/Player/Default_KEY/Locomotion/Idle", false) then
				idleCounter = idleCounter + 1
				if idleCounter > cAlgieIdleTime then
					if not PedIsPlaying(pedAlgie.id, "F_NERDSALG_PEEDANCE", false) then
						F_AlgieComplainIdle()
					end
					idleCounter = 0
				end
			else
				idleCounter = 0
			end
		end
		if bDeleteWierdos01 then
			F_CharDelete(pedEunice.id)
			bDeleteWierdos01 = false
		end
		if bDeleteWierdos02 then
			F_CharDelete(pedBathroomWierdo02.id)
			bDeleteWierdos02 = false
		end
		Wait(0)
	end
	collectgarbage()
end

function T_MonitorPlayerLocation()
	while bLoop do
		if AreaGetVisible() == 2 then
			bPlayerIsInSchool = true
			if not bInteriorDoorsHandled then
				Wait(2000)
				F_HandleInteriorDoors()
				bInteriorDoorsHandled = true
				bExteriorDoorsHandled = false
			end
		else
			bPlayerIsInSchool = false
			if not bExteriorDoorsHandled then
				Wait(2000)
				bExteriorDoorsHandled = true
				bInteriorDoorsHandled = false
			end
		end
		Wait(0)
	end
	collectgarbage()
end

function T_Stage2_Locates()
	--print("()xxxxx[:::::::::::::::> [start] T_Stage2_Locates()")
	while bLoop do
		if bPlayerIsInSchool then
			if not bEncounterBathroomFirstFloor then
				if PedIsInTrigger(pedAlgie.id, TRIGGER._1_05B_BATHROOMFIRSTFLOOR) then
					--print("()xxxxx[:::::::::::::::> Launch F_EncounterBathroomFirstFloor()")
					SoundPlayScriptedSpeechEvent(pedJockBathroomFirstFloor01.id, "M_1_05", 17, "large")
					F_EncounterBathroomFirstFloor()
					bEncounterBathroomFirstFloor = true
				elseif F_HitByPlayer(pedJockBathroomFirstFloor01.id) or F_HitByPlayer(pedJockBathroomFirstFloor02.id) then
					SoundPlayScriptedSpeechEvent(pedJockBathroomFirstFloor02.id, "M_1_05", 8)
					F_EncounterBathroomFirstFloor()
					bEncounterBathroomFirstFloor = true
				end
			end
			if not bEncounterBathroomSecondFloor and not bFightingFirstFloorBathroomJocks and PedIsInTrigger(pedAlgie.id, TRIGGER._1_05B_BATHROOMSECONDFLOOR) then
				--print("()xxxxx[:::::::::::::::> Launch F_EncounterBathroomSecondFloor()")
				F_CutAlgieToStall()
				F_StopTimer()
				F_EncounterBathroomSecondFloor()
				bEncounterBathroomSecondFloor = true
				--print("()xxxxx[:::::::::::::::> Starting Poop Timer.")
			end
			if not bWentInGirlsBathroom01 and PlayerIsInTrigger(TRIGGER._1_05B_FIRSTFLOORGIRLSBR) then
				SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 16)
				bWentInGirlsBathroom01 = true
			end
			if not bWentInGirlsBathroom02 and PlayerIsInTrigger(TRIGGER._1_05B_SECONDFLOORGIRLSBR) then
				SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 16)
				bWentInGirlsBathroom02 = true
			end
			if not bEuniceChat and PlayerIsInTrigger(TRIGGER._1_05B_BATHROOMSECONDFLOOR) then
				CreateThread("T_EuniceChat")
				bEuniceChat = true
			end
			if not bAmbientOn then
				if PlayerIsInTrigger(TRIGGER._1_05B_AREASECONDFLOORBR) then
					--print("()xxxxx[:::::::::::::::> Turning Ambient Population Off")
					AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
					while not AreaDisablePatrolPath(PATH._HALLSPATROL_2B) do
						Wait(0)
					end
					bAmbientOn = true
				end
			elseif PlayerIsInTrigger(TRIGGER._1_05B_LOADSMOKE) then
				--print("()xxxxx[:::::::::::::::> Resetting Ambient Population")
				AreaRevertToDefaultPopulation()
				AreaEnablePatrolPath(PATH._HALLSPATROL_2A)
				bAmbientOn = false
			end
			if not bAmbientOn then
				if PlayerIsInTrigger(TRIGGER._1_05B_FIRSTFLOORAMBIENTOFF) then
					--print("()xxxxx[:::::::::::::::> Turning Ambient Population Off")
					AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
					bAmbientOn = true
					while not AreaDisablePatrolPath(PATH._HALLSPATROL_1A) do
						wait(0)
					end
				end
			elseif PlayerIsInTrigger(TRIGGER._1_05B_FIRSTFLOORAMBIENTON) then
				--print("()xxxxx[:::::::::::::::> Resetting Ambient Population")
				AreaRevertToDefaultPopulation()
				AreaEnablePatrolPath(PATH._HALLSPATROL_1A)
				bAmbientOn = false
			end
		end
		Wait(0)
	end
	collectgarbage()
	--print("()xxxxx[:::::::::::::::> [finish] T_Stage2_Locates()")
end

function T_BathroomAntics()
	--print("()xxxxx[:::::::::::::::> [start] T_BathroomAntics()")
	while bAnticsLoop do
		if bStartBathroomSequence then
			PAnimCloseDoor(TRIGGER._STALDOOR02)
			gPissTimerStarted = GetTimer()
			bAlgieDistanceCheck = false
			F_BathroomSequence()
			bStartBathroomSequence = false
		end
		if bUpstairsBulliesActive and PedIsDead(pedJockBathroomSecondFloor01.id) and pedJockBathroomSecondFloor02.id then
			bUpstairsBulliesActive = false
			bAlgieCanPiss = true
		end
		if bAlgieCanPiss then
			tableBathroomPeds = {
				PedFindInAreaXYZ(bathroomX, bathroomY, bathroomZ, 12)
			}
			if tableBathroomPeds[1] == true then
				table.remove(tableBathroomPeds, 1)
				gBathroomPeds = table.getn(tableBathroomPeds)
				for i = 1, gBathroomPeds do
					if tableBathroomPeds[i] == gPlayer or tableBathroomPeds[i] == pedAlgie.id then
						bBathroomClear = true
					elseif not PedIsDead(tableBathroomPeds[i]) then
						bBathroomClear = false
						break
					end
					Wait(0)
				end
			else
				bBathroomClear = true
			end
			tableBathroomPeds = nil
			collectgarbage()
			if not bBathroomClear then
				--print("()xxxxx[:::::::::::::::> Bathroom not clear, resetting poop timer!")
				gPissTimerStarted = GetTimer()
				F_AlgieWhine()
				bPeeSoundOn = false
			else
				--print("()xxxxx[:::::::::::::::> Bathroom clear!")
				if not bAlgieRelief01 and bAlgieWhine01 then
					SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 29)
					bAlgieRelief01 = true
				end
				bPeeSoundOn = true
			end
			gCurrentTime = GetTimer()
			if not bAlgieMovingToSink and gPissTimerStarted + gPoopDuration <= gCurrentTime then
				bPeeSoundOn = false
				Wait(2000)
				SoundPlay2D("Toilet_Flush")
				AreaSetDoorLocked(TRIGGER._STALDOOR02, false)
				PAnimDoorStayOpen(TRIGGER._STALDOOR02)
				PAnimOpenDoor(TRIGGER._STALDOOR02)
				PedFollowPath(pedAlgie.id, PATH._1_05B_ROUTEALGIESTALLTOSINK, 0, 1, F_routeAlgieStallToSink)
				SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 30)
				bAlgieMovingToSink = true
				bAlgieCanPiss = false
				bAlgieDistanceCheck = true
				--print("()xxxxx[:::::::::::::::> Algie has been in bathroom for X seconds undisturbed.")
			end
		end
		Wait(0)
	end
	collectgarbage()
	--print("()xxxxx[:::::::::::::::> [finish] T_BathroomAntics()")
end

function T_MonitorAlgiePee()
	while bPissLoop do
		if bPeeSoundOn then
			if not bAlgieIsPissing then
				--print("()xxxxx[:::::::::::::::> PEE SOUND ON")
				Wait(500)
				PedSetActionNode(pedAlgie.id, "/Global/1_05/Sounds/Pee/PeeStart", "Act/Conv/1_05.act")
				bAlgieIsPissing = true
			end
		elseif bAlgieIsPissing then
			--print("()xxxxx[:::::::::::::::> PEE SOUND OFF")
			PedSetActionNode(pedAlgie.id, "/Global/1_05/Sounds/Pee/PeeStop", "Act/Conv/1_05.act")
			Wait(500)
			F_StopAlgie()
			bAlgieIsPissing = false
		end
		Wait(0)
	end
	collectgarbage()
end

function T_EuniceChat()
	SoundPlayScriptedSpeechEventWrapper(pedEunice.id, "M_1_05", 23)
end

function F_EncounterFirstBully()
	--print("()xxxxx[:::::::::::::::> [start] F_EncounterFirstBully()")
	PedSetInvulnerable(pedFirstBully.id, false)
	PedFollowPath(pedFirstBully.id, PATH._1_05_ROUTEFIRSTBULLY, 0, 0, F_routeFirstBully)
	--print("()xxxxx[:::::::::::::::> [finish] F_EncounterFirstBully()")
end

function F_EncounterSecondBully()
	--print("()xxxxx[:::::::::::::::> [start] F_EncounterSecondBully()")
	PedFollowPath(pedSecondBully.id, PATH._1_05_ROUTESECONDBULLY, 0, 0, F_routeSecondBully)
	--print("()xxxxx[:::::::::::::::> [finish] F_EncounterSecondBully()")
end

function F_EncounterJockPackWarning()
	--print("()xxxxx[:::::::::::::::> [start] F_EncounterJockPackWarning()")
	--print("()xxxxx[:::::::::::::::> [speech] should be playing M_1_05, 5")
	SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_05", 5)
	--print("()xxxxx[:::::::::::::::> [finish] F_EncounterJockPackWarning()")
end

function F_EncounterJockPackAttack()
	--print("()xxxxx[:::::::::::::::> [start] F_EncounterJockPackAttack()")
	PedStop(pedJockPack_01.id)
	PedAttack(pedJockPack_01.id, pedAlgie.id, 1)
	PedAttack(pedJockPack_02.id, pedAlgie.id, 1)
	PedAttack(pedJockPack_03.id, pedAlgie.id, 1)
	--print("()xxxxx[:::::::::::::::> [finish] F_EncounterJockPackAttack()")
end

function F_routeSecondFloorAmbush(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeSecondFloorAmbush() @ node: " .. nodeID)
	if pedID == pedJockBathroomSecondFloor01.id then
		if nodeID == 3 then
			--print("()xxxxx[:::::::::::::::> THERE HE IS!")
			pedJockBathroomSecondFloor02.blip = AddBlipForChar(pedJockBathroomSecondFloor02.id, 11, 26, 4)
			PedAttack(pedJockBathroomSecondFloor02.id, gPlayer, 3)
		elseif nodeID == 4 then
			pedJockBathroomSecondFloor01.blip = AddBlipForChar(pedJockBathroomSecondFloor01.id, 11, 26, 4)
			PedAttack(pedJockBathroomSecondFloor01.id, gPlayer, 3)
			bUpstairsBulliesActive = false
			bAlgieCanPiss = true
		end
	elseif pedID == pedJockBathroomSecondFloor02.id then
		if nodeID == 3 then
			if PlayerIsInTrigger(TRIGGER._1_05B_AREASECONDFLOORBR) then
				SoundPlayScriptedSpeechEventWrapper(pedJockBathroomSecondFloor02.id, "M_1_05", 22, "large")
			end
		elseif nodeID == 4 and PlayerIsInTrigger(TRIGGER._1_05B_AREASECONDFLOORBR) then
			SoundPlayScriptedSpeechEventWrapper(pedJockBathroomSecondFloor02.id, "M_1_05", 40, "large")
		end
	end
end

function F_routeAlgieStall(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeSecondFloorAmbush() @ node: " .. nodeID)
	if nodeID == 2 then
		PAnimOpenDoor(TRIGGER._STALDOOR02)
	elseif nodeID == 3 then
		--print("()xxxxx[:::::::::::::::> CLOSE STALL DOOR")
		bIsAlgieInStallYet = true
	end
end

function F_routeAlgieStallToSink(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeAlgieStallToSink() @ node: " .. nodeID)
	if nodeID == 4 then
		PedSetActionNode(pedAlgie.id, "/Global/1_05/Anims/Handwash/WashHands", "Act/Conv/1_05.act")
		bLaunchStage3 = true
	end
end

function F_routeFirstFloorStall(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeFirstFloorStall() @ node: " .. nodeID)
	if nodeID == 1 then
		PAnimOpenDoor(TRIGGER._STALDOOR11)
	elseif nodeID == 2 then
		PAnimCloseDoor(TRIGGER._STALDOOR11)
		PedFaceObject(pedAlgie.id, gPlayer, 3, 1)
		bAlgieClosedFirstFloorStallDoor = true
	end
end

function F_routeAlgieLocker(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeAlgieLocker() @ node: " .. nodeID)
	if nodeID == 1 then
		PAnimSetActionNode(TRIGGER._NLOCK02B06, "/Global/NLockA/Unlocked/Scripted/SaveAlgieBooks", "Act/Props/NLockA.act")
		PedSetActionNode(pedAlgie.id, "/Global/1_05/Anims/Rummage/Locker", "Act/Conv/1_05.act")
		PedFaceObject(gPlayer, pedAlgie.id, 2, 1)
	end
end

function F_routeAlgieOutro(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeAlgieOutro() @ node: " .. nodeID)
	if nodeID == 2 then
		PAnimCloseDoor(TRIGGER._DT_TSCHOOL_LIBRARYL)
	end
end

function F_routeBullyFlee(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeBullyFlee() @ node: " .. nodeID)
	if nodeID == 1 then
		SoundPlayScriptedSpeechEvent(pedFirstBully.id, "M_1_05", 3)
		bMonitorFirstBully = false
		bBullyMadeIt = true
	end
end

function F_routeBullyFleeNew(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeBullyFleeNew() @ node: " .. nodeID)
	if nodeID == 1 then
		if not bStage1FirstBullyDead and not bHelpMeGuys then
			SoundPlayScriptedSpeechEvent(pedFirstBully.id, "M_1_05", 3)
			bHelpMeGuys = true
		end
		bStopFleeing = true
		pedBulliesRight01.blip = AddBlipForChar(pedBulliesRight01.id, 11, 26, 4)
		pedBulliesRight02.blip = AddBlipForChar(pedBulliesRight02.id, 11, 26, 4)
		PedAttack(pedFirstBully.id, pedAlgie.id, 1)
		PedAttackPlayer(pedBulliesRight01.id, 1)
		PedAttackPlayer(pedBulliesRight02.id, 1)
		bBulliesRightAttack = true
	end
end

function F_routeBathroomWierdos(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeBathroomWierdos() @ node: " .. nodeID)
	if nodeID == 6 then
		if pedID == pedEunice.id then
			bDeleteWierdos01 = true
		elseif pedID == pedBathroomWierdo02.id then
			bDeleteWierdos02 = true
		end
	end
end

function F_routeFirstBully(pedID, pathID, nodeID)
	if nodeID == 2 then
		bFirstJockAttack = true
	end
end

function F_routeSecondBully(pedID, pathID, nodeID)
	if nodeID == 2 then
		bSecondJockAttack = true
	end
end

function F_cbPlayerWaiting()
	PedFaceHeading(gPlayer, 170, 1)
end
