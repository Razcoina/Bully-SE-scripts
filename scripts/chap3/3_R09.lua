--[[ Changes to this file:
	* Modified function F_PrepStage01, may require testing
]]

local gMaxKills = 6
local gSimultEnemies = 3
local gTimeForSpawns = 1500
local gSpawnLocations = {}
local gSpawnIds = {}
local gSpawnModels = {}
local gArea = 0
local datId = "3_R09_Nerds.DAT"
local gAllies = {}
local gPedsSpawned = 0
local gRewardMoney = 0
local gMissionNoRunning = -1
local gShowBook = false
local gTotalSpawned = 0
local gSpawnedPeds = {
	false,
	false,
	false,
	false,
	false,
	false
}
local gTotalPeds = 0
local gEndPed = 0
local gSpawnerPedsAttack = {
	false,
	false,
	false
}
local gMusicType = 0
local gUniqueStatus = {}
local gNerdModels = {
	5,
	4,
	7,
	9,
	8,
	11
}
local gGreaserModels = {
	24,
	29,
	28
}
local gPrepModels = {
	32,
	34,
	40
}
local gJockModels = {
	13,
	15,
	231
}
local gJockSportModels = {
	109,
	111,
	16,
	17,
	18
}
local gDOModels = {
	43,
	45,
	46
}
local gToAttack = {}

function F_SetupVendetta(param)
	--print("><><><><<><><<><><> Calling F_SetupVendetta()", param)
	if param == 0 then
		gSetupFunction = F_NerdSetup
		gInitialArea = 30
		gRewardMoney = 500
		gNerdMissionRunning = true
		gMusicType = 4
	elseif param == 1 then
		datId = "3_R09_Greasers.DAT"
		gInitialArea = 61
		gSetupFunction = F_GreaserSetupP1
		gRewardMoney = 1000
		gMusicType = 0
	elseif param == 2 then
		datId = "3_R09_Greasers.DAT"
		gInitialArea = 61
		gSetupFunction = F_GreaserSetupP2
		gRewardMoney = 1500
		gMusicType = 0
	elseif param == 3 then
		datId = "3_R09_Greasers.DAT"
		gInitialArea = 61
		gSetupFunction = F_GreaserSetupP3
		gRewardMoney = 1600
		gMusicType = 0
	elseif param == 4 then
		datId = "3_R09_Preppies.DAT"
		gInitialArea = 60
		gSetupFunction = F_PrepsSetupP1
		gRewardMoney = 2000
		gMusicType = 10
	elseif param == 5 then
		datId = "3_R09_Preppies.DAT"
		gInitialArea = 60
		gSetupFunction = F_PrepsSetupP2
		gRewardMoney = 2200
		gMusicType = 10
	elseif param == 6 then
		datId = "3_R09_Preppies.DAT"
		gInitialArea = 60
		gSetupFunction = F_PrepsSetupP3
		gRewardMoney = 2500
		gMusicType = 10
	elseif param == 7 then
		datId = "3_R09_Jocks.DAT"
		gInitialArea = 59
		gSetupFunction = F_JocksSetupP1
		gRewardMoney = 2500
		gMusicType = 10
	elseif param == 8 then
		datId = "3_R09_Jocks.DAT"
		gInitialArea = 59
		gSetupFunction = F_JocksSetupP2
		gRewardMoney = 2600
		gMusicType = 10
	elseif param == 9 then
		datId = "3_R09_Jocks.DAT"
		gInitialArea = 13
		gSetupFunction = F_JocksSetupP3
		gRewardMoney = 2700
		gMusicType = 10
	elseif param == 10 then
		datId = "3_R09_Dropouts.DAT"
		gInitialArea = 57
		gSetupFunction = F_DOSetupP1
		gRewardMoney = 3000
		gMusicType = 10
	elseif param == 11 then
		datId = "3_R09_Dropouts.DAT"
		gInitialArea = 57
		gSetupFunction = F_DOSetupP2
		gRewardMoney = 3100
		gMusicType = 10
	elseif param == 12 then
		datId = "3_R09_Dropouts.DAT"
		gInitialArea = 57
		gSetupFunction = F_DOSetupP3
		gRewardMoney = 3500
		gMusicType = 10
	end
	gMissionWait = nil
end

function MissionSetup()
	--print("[RAUL] --- INIT MISSION SETUP ")
	MissionDontFadeIn()
	DisablePunishmentSystem(true)
	PauseGameClock()
	shared.vendettaRunning = true
	gMissionWait = true
	gInitialArea = 0
end

function main()
	--print("Waiting for Setup >><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	while gMissionWait do
		Wait(0)
	end
	DATLoad(datId, 2)
	DATInit()
	--print("Finished Setup >><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	gMissionRunning = true
	AreaTransitionPoint(gInitialArea, POINTLIST._3_R09_PLAYER, nil, true)
	while IsStreamingBusy() do
		Wait(0)
	end
	--print("Streaming is no longer busy >><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	LoadActionTree("Act/Conv/3_R09.act")
	gSetupFunction()
	--print("Starting gMainFunction>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	local attackIndex = {}
	while gMissionRunning do
		gMainFunction()
		Wait(0)
	end
	PedClearHasAggressed(gPlayer)
end

function MissionCleanup()
	MissionAllowConcurrentMissions(false)
	PedClearHasAggressed(gPlayer)
	MissionTimerStop()
	DisablePunishmentSystem(false)
	CounterMakeHUDVisible(false)
	PedResetTypeAttitudesToDefault()
	AreaRevertToDefaultPopulation()
	SoundFadeoutStream()
	gMissionRunning = false
	shared.vendettaRunning = false
	shared.NerdVendettaRunning = nil
	shared.PrepVendettaRunning = nil
	shared.JockVendettaRunning = nil
	shared.g3_R09_N = false
	PedSetFlag(gPlayer, 58, false)
	CameraAllowChange(true)
	CameraReturnToPlayer()
	CameraReset()
	if gDoorToLock then
		AreaSetDoorLocked(gDoorToLock, false)
		AreaSetDoorLockedToPeds(gDoorToLock, false)
	end
	UnpauseGameClock()
	if attackedClerk then
		AreaTransitionPoint(0, POINTLIST._3_R09_COMICSHOP, nil, true)
	elseif gAggressed then
		PlayerSetPosPoint(POINTLIST._3_R09_BLIPP3)
	end
	F_MakePlayerSafeForNIS(false)
	if shared.playerAggressedInStore then
		shared.playerAggressedInStore = nil
	end
	EnablePOI(true, true)
	CameraSetWidescreen(false)
	F_SetAllUnique(false)
	if endPed and PedIsValid(endPed) then
		PedDelete(endPed)
	end
	DATUnload(2)
	DATInit()
	collectgarbage()
end

function CbSeenPlayer(pedId)
	if PedIsPlaying(pedId, "/Global/Generic/GenericWallSmoking/", true) then
		PedSetActionNode(pedId, "/Global/3_R09/Animations/Empty", "Act/Conv/3_R09.act")
	else
		PedAttackPlayer(pedId)
	end
end

function F_SetAllUnique(unique)
	if unique then
		for i, model in gSpawnModels do
			gUniqueStatus[i] = PedGetUniqueModelStatus(model)
			PedSetUniqueModelStatus(model, 1)
		end
	else
		for i, model in gSpawnModels do
			if gUniqueStatus[i] then
				PedSetUniqueModelStatus(model, gUniqueStatus[i])
			end
		end
	end
end

function F_NerdSetup()
	MissionAllowConcurrentMissions(true)
	shared.g3_R09 = true
	gUnlockHideoutText = "3_R09_UN"
	gMainFunction = F_NerdStage01
	gSpawnModels = gNerdModels
	F_SetAllUnique(true)
	gDoorTrigger = "DT_TBUSINES_SAFENERD"
	gSpawnLocations = {
		{
			pointlist = POINTLIST._3_R09_SPAWN01,
			trigger = TRIGGER._3_R09_SPAWNT01
		},
		{
			pointlist = POINTLIST._3_R09_SPAWN02,
			trigger = TRIGGER._3_R09_SPAWNT02
		}
	}
	gSpawnText = {
		"3_R09_C8",
		"3_R09_C9",
		"3_R09_D1"
	}
	gArea = 30
	tx, ty, tz = -734.503, 36.3224, -1.32136
	bx, by, bz = -734.503, 36.3224, -1.32136
	fx, fy, fz = -725.6378, 36.8653, -1.32136
	gStagePart = 1
	gMaxKills = 4
	gEnemyPedType = 1
	gGiverModel = 70
	gGiverPoint = POINTLIST._3_R09_N
	gObjectiveString = "3_R09_E5"
	gMissionNoRunning = 1
	gSimultEnemies = 2
end

function F_NerdStage01()
	if gStagePart == 1 then
		shared.g3_R09_N = true
		--print(" _/_/_/_/_/_ Stage 01 - Part 02 ")
		CameraSetWidescreen(true)
		F_MakePlayerSafeForNIS(true)
		PlayerSetControl(0)
		local koX, koY, koZ = GetPointList(POINTLIST._3_R09_BLIPP3)
		MissionOverrideKOPoint(koX, koY, koZ, 0, 30)
		while not shared.finishedLoadingShop do
			Wait(0)
		end
		while not shared.vendettaClerk do
			Wait(0)
		end
		LoadModels({ 186 })
		LoadModels(gSpawnModels)
		LoadAnimationGroup("NIS_3_R09_N")
		Wait(4000)
		--print("DID HE AGGRESS IN THE STORE?", tostring(shared.playerAggressedInStore))
		if not shared.playerAggressedInStore then
			AreaSetDoorLocked(TRIGGER._FMDOORN01, false)
			CameraLookAtXYZ(-726.3282, 18.083551, 1.435173, true)
			CameraSetXYZ(-728.49286, 20.001883, 1.861192, -727.94073, 19.207907, 1.608468)
			CameraFade(1000, 1)
			Wait(1000)
			SoundDisableSpeech_ActionTree()
			local nisRunning = true
			while nisRunning do
				nisRunning = false
				PedFaceObject(shared.vendettaClerk, gPlayer, 3, 0)
				PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Comic/Player01", "Act/Conv/3_R09.act")
				if F_PlaySpeechAndWait(gPlayer, "M_3_R09", 127, "large", false, true) then
					break
				end
				CameraSetXYZ(-727.8272, 14.952086, 1.25812, -727.293, 15.797104, 1.234105)
				PedSetActionNode(shared.vendettaClerk, "/Global/3_R09/Animations/ComicOwner/Comic01", "Act/Conv/3_R09.act")
				if F_PlaySpeechAndWait(shared.vendettaClerk, "M_3_R09", 93, "large", false, true) then
					break
				end
				CameraSetXYZ(-727.5154, 17.209179, 1.233189, -726.9101, 16.413967, 1.238974)
				PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Comic/Player02", "Act/Conv/3_R09.act")
				if F_PlaySpeechAndWait(gPlayer, "M_3_R09", 22, "large", false, true) then
					break
				end
			end
			Wait(500)
			CameraFade(500, 0)
			Wait(500)
			PedStop(gPlayer)
			PedClearObjectives(gPlayer)
			local x, y, z = GetAnchorPosition(TRIGGER._3_R09_BASEMENTTRIGGER)
			PlayerSetPosSimple(x, y, z)
			DisablePOI(true, true)
			AreaSetDoorLocked(TRIGGER._FMDOORN, true)
			PAnimCloseDoor(TRIGGER._FMDOORN)
		else
			gMissionRunning = false
			SoundPlayMissionEndMusic(false, gMusicType)
			PlayerSetPunishmentPoints(0)
			MissionFail(false, false, "3_R09_Sfail")
		end
		gStagePart = 2
	elseif gStagePart == 2 then
		if PedIsHit(shared.vendettaClerk, 2, 1000) and PedGetWhoHitMeLast(shared.vendettaClerk) == gPlayer then
			shared.g3_R09_N = false
		end
		BlipRemove(gBlip)
		LoadAnimationGroup("Cheer_Nerd3")
		LoadAnimationGroup("NIS_3_R09_N")
		LoadAnimationGroup("Hang_Talking")
		--print(" _/_/_/_/_/_ Stage 01 - Part 03 ")
		gNerd01 = PedCreatePoint(186, POINTLIST._3_R09_FIRST, 1)
		gNerd02 = PedCreatePoint(4, POINTLIST._3_R09_FIRST, 2)
		gNerd03 = PedCreatePoint(8, POINTLIST._3_R09_FIRST, 3)
		PAnimOpenDoor(TRIGGER._FMDOORN01)
		PAnimOpenDoor(TRIGGER._FMDOORN)
		PAnimDoorStayOpen(TRIGGER._FMDOORN01)
		PAnimDoorStayOpen(TRIGGER._FMDOORN)
		F_PedFearless(gNerd01)
		F_PedFearless(gNerd02)
		F_PedFearless(gNerd03)
		PedSetMissionCritical(gNerd01, true, CbPlayerAggressed, true)
		PedSetMissionCritical(gNerd02, true, CbPlayerAggressed, true)
		PedSetMissionCritical(gNerd03, true, CbPlayerAggressed, true)
		CameraSetWidescreen(true)
		AreaClearAllPeds()
		Wait(1000)
		CameraFade(1000, 1)
		local nisRunning = true
		local skipped = false
		while nisRunning do
			nisRunning = false
			CameraSetXYZ(-721.7357, 38.77579, 0.659548, -721.9925, 37.96601, 0.132051)
			PedFollowPath(gPlayer, PATH._3_R09_PLAYERPATH, 0, 0)
			PedSetActionNode(gNerd02, "/Global/3_R09/Animations/Nerds/Nerds01", "Act/Conv/3_R09.act")
			if F_PlaySpeechAndWait(gNerd02, "M_3_R09", 8, "jumbo", false, true) then
				skipped = true
				break
			end
			CameraSetXYZ(-721.45654, 36.84287, -0.622337, -722.3205, 36.399994, -0.861693)
			PedSetActionNode(gNerd01, "/Global/3_R09/Animations/Nerds/Nerds02", "Act/Conv/3_R09.act")
			if F_PlaySpeechAndWait(gNerd01, "M_3_R09", 50, "jumbo", false, true) then
				skipped = true
				break
			end
			CameraSetXYZ(-724.6291, 35.413933, -1.046123, -724.4542, 34.429577, -1.059661)
			PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Nerds/Player01", "Act/Conv/3_R09.act")
			if F_PlaySpeechAndWait(gPlayer, "M_3_R09", 10, "jumbo", false, true) then
				skipped = true
				break
			end
			WaitSkippable(500)
			PedFaceObject(gNerd01, gPlayer, 3, 1)
			PedFaceObject(gNerd02, gPlayer, 3, 1)
			PedFaceObject(gNerd03, gPlayer, 3, 1)
			PedStop(gPlayer)
			PedClearObjectives(gPlayer)
			CameraSetXYZ(-725.599, 33.70943, -0.831467, -724.7561, 34.216095, -1.012014)
			PedSetActionNode(gNerd01, "/Global/3_R09/Animations/Nerds/Nerds03", "Act/Conv/3_R09.act")
			if F_PlaySpeechAndWait(gNerd01, "M_3_R09", 52, "jumbo", false, true) then
				skipped = true
				break
			end
			PedSetActionNode(gNerd03, "/Global/3_R09/Animations/Nerds/Nerds01", "Act/Conv/3_R09.act")
			if F_PlaySpeechAndWait(gNerd03, "M_3_R09", 94, "jumbo", false, true) then
				skipped = true
				break
			end
			CameraSetXYZ(-724.6291, 35.413933, -1.046123, -724.4542, 34.429577, -1.059661)
			PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Nerds/Player01", "Act/Conv/3_R09.act")
			if F_PlaySpeechAndWait(gPlayer, "M_3_R09", 95, "jumbo", false, true) then
				skipped = true
				break
			end
			CameraSetXYZ(-727.0536, 35.568577, -0.435671, -726.1668, 36.00349, -0.591144)
		end
		if skipped then
			CameraFade(500, 0)
			Wait(500)
			PedFaceObject(gNerd01, gPlayer, 3, 1)
			PedFaceObject(gNerd02, gPlayer, 3, 1)
			PedFaceObject(gNerd03, gPlayer, 3, 1)
		end
		PedFollowPath(gPlayer, PATH._3_R09_TOMACHINE, 0, 1)
		Wait(1500)
		CameraSetWidescreen(false)
		PedStop(gPlayer)
		PedClearObjectives(gPlayer)
		F_MakePlayerSafeForNIS(false)
		PlayerSetControl(1)
		PedSetPedToTypeAttitude(gNerd01, 13, 4)
		PedSetPedToTypeAttitude(gNerd02, 13, 4)
		PedSetPedToTypeAttitude(gNerd03, 13, 4)
		CameraReturnToPlayer()
		CameraReset()
		PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Empty", "Act/Conv/3_R09.act")
		UnLoadAnimationGroup("Cheer_Nerd3")
		UnLoadAnimationGroup("NIS_3_R09_N")
		UnLoadAnimationGroup("Hang_Talking")
		shared.NerdVendettaRunning = true
		shared.vendettaFatty = gNerd01
		shared.vendettaAlgie = gNerd02
		shared.vendettaBucky = gNerd03
		gStagePart = 3
		if skipped then
			CameraFade(-1, 1)
		end
		TextPrint("3_R09_ArObj", 4, 1)
		gArcObjective = MissionObjectiveAdd("3_R09_ArObj")
		gArcCorona = BlipAddPoint(POINTLIST._3_R09_ARCADEMACH, 0, 1, 1, 7)
		PedFaceObject(gNerd01, gPlayer, 3, 1, false)
		PedFaceObject(gNerd02, gPlayer, 3, 1, false)
		PedFaceObject(gNerd03, gPlayer, 3, 1, false)
		F_FailIfOutside()
	elseif gStagePart == 3 then
		if PlayerIsInTrigger(TRIGGER._3_R09_UPSTAIRS) then
			TextPrint("3_R09_Upstairs", 1, 1)
		end
		if shared.ConSumoFinished and not MissionActiveSpecific("TrainASumo") then
			if 0 < shared.ConSumoFinished then
				--print("CONSUMO FINISHED")
				PlayerSetControl(0)
				CameraSetWidescreen(true)
				CameraSetXYZ(-724.0699, 41.775166, -0.346846, -723.6151, 40.94008, -0.656254)
				PedFaceObject(gPlayer, gNerd03, 2, 0)
				CameraFade(-1, 1)
				Wait(2000)
				PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Empty", "Act/Conv/3_R09.act")
				PedStop(gPlayer)
				PedClearObjectives(gPlayer)
				PedStop(gNerd03)
				PedClearObjectives(gNerd03)
				PedLockTarget(gPlayer, gNerd03, 3)
				PedLockTarget(gNerd03, gPlayer, 3)
				PedSetActionNode(gPlayer, "/Global/3_R09/Animations/GetBrocketLauncher", "Act/Conv/3_R09.act")
				while PedIsPlaying(gPlayer, "/Global/3_R09/Animations/GetBrocketLauncher", true) do
					if not saidmyline then
						SoundPlayScriptedSpeechEvent(gNerd03, "M_3_R09_N", 97, "speech")
						saidmyline = true
					end
					Wait(0)
				end
				PedLockTarget(gPlayer, -1)
				PedLockTarget(gNerd03, -1)
				F_TakeoverScene()
				AreaSetDoorLocked(TRIGGER._FMDOORN, false)
				PAnimOpenDoor(TRIGGER._ICOMSHP_BASEMENT)
				PAnimDoorStayOpen(TRIGGER._ICOMSHP_BASEMENT)
				gMissionRunning = false
				shared.nerdsSave = true
				shared.unlockedClothing = true
				gMissionSucceeded = true
				MissionSucceed(true, true, false)
				shared.ConSumoFinished = nil
			else
				if 50 < math.random(1, 100) then
					SoundPlayScriptedSpeechEvent(gNerd01, "COMPLAIN", 0, "speech")
				else
					SoundPlayScriptedSpeechEvent(gNerd02, "COMPLAIN", 0, "speech")
				end
				TextPrint("3_R09_ArObj", 4, 1)
				PedFaceObject(gNerd01, gPlayer, 3, 1, true)
				PedFaceObject(gNerd02, gPlayer, 3, 1, true)
				shared.ConSumoFinished = nil
			end
		end
		if PedIsHit(shared.vendettaClerk, 2, 1000) then
			PlayerSetControl(0)
			F_MakePlayerSafeForNIS(true)
			PedFaceObject(shared.vendettaClerk, gPlayer, 3, 0)
			SoundPlayScriptedSpeechEvent(shared.vendettaClerk, "STORE_VIOLENCE_RESPONSE", 0, "supersize")
			PedSetActionNode(shared.vendettaClerk, "/Global/Welcome/ShakeFist", "Act/Conv/Store.act")
			PedStop(shared.vendettaClerk)
			PedClearObjectives(shared.vendettaClerk)
			SoundPlayMissionEndMusic(false, gMusicType)
			gMissionRunning = false
			AreaSetDoorLocked(TRIGGER._FMDOORN01, true)
			PAnimCloseDoor(TRIGGER._FMDOORN01)
			MissionFail(true, true, "3_R09_Nfail")
			attackedClerk = true
		end
		if gAggressed then
			SoundPlayMissionEndMusic(false, gMusicType)
			gMissionRunning = false
			AreaSetDoorLocked(TRIGGER._FMDOORN01, true)
			PAnimCloseDoor(TRIGGER._FMDOORN01)
			MissionFail(true, true, "3_R09_Nfail")
		end
		F_FailIfOutside()
	end
end

function F_NerdStage02()
	if AreaMissionSpawnerExhausted(idSpawner) then
		F_TakeoverScene()
		AreaSetDoorLocked(TRIGGER._FMDOORN, false)
		gMissionRunning = false
		shared.nerdsSave = true
		shared.unlockedClothing = true
		gMissionSucceeded = true
		MissionSucceed(true, true, false)
	end
	if not AreaGetVisible() == gArea then
		TextPrint("3_R09_69", 4, 1)
		Wait(3000)
		gMissionRunning = false
		SoundPlayMissionEndMusic(false, gMusicType)
		MissionFail()
	end
end

function F_GreaserSetupP1()
	gUnlockHideoutText = "3_R09_UG"
	TextPrint("3_R09_70", 4, 1)
	gMainFunction = F_Part01S1
	gSpawnModels = gGreaserModels
	gAllyModels = gPrepModels
	gEnemyPedType = 4
	gAllyPedType = 5
	gNoOfEnemies = 4
	gNoOfAllies = 1
	gStagePart = 0
	gArea = 0
	gEnemies = {}
	gMissionText = "3_R09_71"
	gPop = {
		9,
		0,
		0,
		0,
		0,
		0,
		0,
		4,
		0,
		0,
		5,
		0,
		0
	}
	gGiverModel = 33
	gGiverPoint = POINTLIST._3_R09_G
	gObjectiveString = "3_R09_84"
end

function F_GreaserSetupP2()
	TextPrint("3_R09_72", 4, 1)
	gSpawnModels = gGreaserModels
	gAllyModels = gPrepModels
	gEnemyPedType = 4
	gAllyPedType = 5
	gNoOfEnemies = 8
	gStagePart = 0
	gArea = 0
	gEnemies = {}
	gMissionText = "3_R09_71"
	gPOIList = {
		POI._3_R09_POI01,
		POI._3_R09_POI01,
		POI._3_R09_POI01,
		POI._3_R09_POI02,
		POI._3_R09_POI02,
		POI._3_R09_POI02,
		false,
		false
	}
	LoadAnimationGroup("POI_Smoking")
	gFunctions = {
		false,
		false,
		false,
		false,
		false,
		false,
		{
			"PedSetActionNode",
			"/Global/Generic/GenericWallSmoking/WalkTOWall",
			"/Act/Anim/GenericSequences.act"
		},
		{
			"PedSetActionNode",
			"/Global/Generic/GenericWallSmoking/WalkTOWall",
			"/Act/Anim/GenericSequences.act"
		}
	}
	gWeaponList = {
		376,
		false,
		false,
		376,
		false,
		false,
		323,
		false
	}
	gGiverModel = 33
	gGiverPoint = POINTLIST._3_R09_G
end

function F_GreaserSetupP3()
	gUnlockHideoutText = "3_R09_UG"
	gMainFunction = F_Part03S1
	gCutsceneFunction = F_P03CutGreasers
	gSpawnModels = gGreaserModels
	F_SetAllUnique(true)
	gDoorTrigger = "DT_TPOOR_SAFEGREASER"
	gSpawnLocations = {
		{
			pointlist = POINTLIST._3_R09_SPAWN01,
			trigger = TRIGGER._3_R09_SPAWNT01
		},
		{
			pointlist = POINTLIST._3_R09_SPAWN02,
			trigger = TRIGGER._3_R09_SPAWNT02
		}
	}
	gSpawnText = {
		"3_R09_D2",
		"3_R09_D3",
		"3_R09_D4"
	}
	gStagePart = 0
	gMaxKills = 3
	gArea = 61
	cx, cy, cz = -692.8128, 347.8948, 4.7339
	tx, ty, tz = -697.129, 350.235, 4.891
	bx, by, bz = -696.652, 353.604, 4.791
	fx, fy, fz = -696.8748, 349.5245, 4.7919
	gCutsceneGuys = {
		26,
		22,
		27
	}
	gAnimationGroups = {
		"Hang_Talking",
		"Cheer_Cool2",
		"NIS_3_R09_G"
	}
	gEnemyPedType = 4
	gGiverModel = 33
	gGiverPoint = POINTLIST._3_R09_G
	gObjectiveString = "3_R09_71"
	gMissionNoRunning = 2
	gFinalHeading = 0
	gMusic = "MS_FightingJohnnyVincentFight.rsm"
	gDoorToLock = TRIGGER._DT_ISAFEGRSR_DOORL
	gSpawnerDoors = {
		TRIGGER._FMDOOR01,
		TRIGGER._FMDOOR
	}
	gEndPed = 29
end

function F_P03CutGreasers()
	LoadAnimationGroup("NIS_3_R09_N")
	SoundSetAudioFocusCamera()
	PAnimSetActionNode("pxDormTV", -691.518, 356.414, 3.30094, 125, "/Global/DormTV/On/PlayShow", "Act/Props/DormTV.act")
	CameraSetXYZ(-695.7887, 355.47, 5.277423, -694.8476, 355.3273, 4.971286)
	PedSetActionNode(gEnemy01, "/Global/3_R09/Animations/Greasers/Greasers01", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy01, "M_3_R09_G", 16, "jumbo", true)
	CameraSetXYZ(-692.68134, 356.5676, 4.829493, -692.6271, 355.5767, 4.706552)
	PedSetActionNode(gEnemy02, "/Global/3_R09/Animations/Greasers/Greasers02", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy02, "M_3_R09_G", 17, "jumbo", true)
	CameraSetXYZ(-691.96014, 349.5128, 4.48351, -691.9753, 348.51712, 4.392413)
	PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Greasers/Greasers01", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gPlayer, "M_3_R09_G", 18, "jumbo", true)
	PedFaceObject(gEnemy01, gPlayer, 2, 0)
	PedFaceObject(gEnemy02, gPlayer, 2, 0)
	CameraSetXYZ(-694.1731, 352.00827, 4.491082, -693.5983, 352.82617, 4.467034)
	PedSetActionNode(gEnemy02, "/Global/3_R09/Animations/Greasers/Greasers02", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy02, "M_3_R09_G", 19, "jumbo", true)
	CameraSetXYZ(-691.9329, 348.16818, 4.521013, -691.9836, 347.16995, 4.549005)
	PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Greasers/Greasers02", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gPlayer, "M_3_R09_G", 20, "jumbo", true)
	PedClearObjectives(gEnemy02)
	PedStop(gEnemy02)
	PedFaceObject(gEnemy02, gPlayer, 3, 1)
	PedClearObjectives(gEnemy01)
	PedClearObjectives(gEnemy03)
	PedStop(gEnemy01)
	PedStop(gEnemy03)
	PedFaceObject(gEnemy01, gPlayer, 3, 1)
	PedFaceObject(gEnemy03, gPlayer, 3, 1)
	SoundSetAudioFocusPlayer()
	UnLoadAnimationGroup("NIS_3_R09_N")
end

function F_PrepsSetupP1()
	gMainFunction = F_Part01S1
	gSpawnModels = gPrepModels
	gAllyModels = gGreaserModels
	gEnemyPedType = 5
	gAllyPedType = 4
	gNoOfEnemies = 4
	gNoOfAllies = 1
	gStagePart = 0
	gArea = 0
	gEnemies = {}
	gMissionText = "3_R09_84"
	gPop = {
		9,
		0,
		0,
		0,
		0,
		0,
		0,
		4,
		0,
		0,
		5,
		0,
		0
	}
	gGiverModel = 21
	gGiverPoint = POINTLIST._3_R09_P
end

function F_PrepsSetupP2()
	gMainFunction = F_Part02S1
	gSpawnModels = gPrepModels
	gAllyModels = gGreaserModels
	gEnemyPedType = 5
	gAllyPedType = 4
	gNoOfEnemies = 9
	gStagePart = 0
	gArea = 0
	gEnemies = {}
	gMissionText = "3_R09_84"
	gPOIList = {
		false,
		false,
		POI._3_R09_POI02,
		POI._3_R09_POI02,
		POI._3_R09_POI02,
		POI._3_R09_POI03,
		POI._3_R09_POI03,
		false,
		false
	}
	gFunctions = {
		false,
		{ "PlayCatch" },
		false,
		false,
		false,
		false,
		false,
		false,
		{ "PlayCatch" }
	}
	gDogPoint = 8
	gWeaponList = {
		false,
		318,
		false,
		false,
		false,
		320,
		false,
		false,
		335
	}
	gGiverModel = 21
	gGiverPoint = POINTLIST._3_R09_P
end

function F_PrepsSetupP3()
	MissionAllowConcurrentMissions(true)
	gMainFunction = F_PrepStage01
	gCutsceneFunction = F_P03CutPreps
	gSpawnModels = gPrepModels
	F_SetAllUnique(true)
	gDoorTrigger = "DT_TRICH_SAFEPREP"
	gUnlockHideoutText = "3_R09_UP"
	LoadAnimationGroup("NIS_3_R09_P")
	gSpawnLocations = {
		{
			pointlist = POINTLIST._3_R09_SPAWN01,
			trigger = TRIGGER._3_R09_SPAWNT01
		},
		{
			pointlist = POINTLIST._3_R09_SPAWN02,
			trigger = TRIGGER._3_R09_SPAWNT02
		}
	}
	gSpawnText = {
		"3_R09_D5",
		"3_R09_D6",
		"3_R09_D7"
	}
	gStagePart = 0
	gMaxKills = 3
	gArea = 60
	cx, cy, cz = -774.9336, 354.3926, 7.469
	tx, ty, tz = -776.854, 358.89, 7.796
	bx, by, bz = -778.202, 358.872, 7.896
	fx, fy, fz = -776.1575, 353.6959, 8.3965
	gCutsceneGuys = {
		30,
		31,
		35
	}
	gBoxers = {
		133,
		118,
		117,
		119,
		36
	}
	gAnimationGroups = {
		"Hang_Talking",
		"Cheer_Cool1",
		"NIS_3_R09_P"
	}
	gEnemyPedType = 5
	gGiverModel = 21
	gGiverPoint = POINTLIST._3_R09_P
	gObjectiveString = "3_R09_84"
	gMissionNoRunning = 3
	gMusic = "MS_EpicConfrontationHigh.rsm"
	gFinalHeading = 200
	gDoorToLock = TRIGGER._DT_ISAFEPREP_DOORL
end

function F_P03CutPreps()
	CameraSetWidescreen(true)
	CameraSetXYZ(-773.0398, 354.38376, 7.76424, -773.6949, 355.13223, 7.662468)
	PedFollowPath(gPlayer, PATH._3_R09_PLAYERPATH, 0, 0)
	PedFaceObject(gPlayer, gEnemy01, 3, 0)
	Wait(500)
	PedSetActionNode(gEnemy03, "/Global/3_R09/Animations/Preppies/Preppies01", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy03, "M_3_R09_P", 17, "jumbo", true)
	Wait(1000)
	CameraSetXYZ(-776.0425, 359.52112, 8.240999, -775.92285, 358.56363, 7.979183)
	PedSetActionNode(gEnemy01, "/Global/3_R09/Animations/Preppies/Preppies02", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy01, "M_3_R09_P", 18, "jumbo", true)
	CameraSetXYZ(-773.88855, 354.4307, 7.510019, -773.88544, 353.45074, 7.708982)
	PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Preppies/Player01", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gPlayer, "M_3_R09_P", 19, "jumbo", true)
	PedFaceObject(gEnemy01, gPlayer, 3, 1)
	PedFaceObject(gEnemy02, gPlayer, 3, 1)
	PedFaceObject(gEnemy03, gPlayer, 3, 1)
	CameraSetXYZ(-774.0905, 356.01126, 7.425745, -774.8027, 356.70676, 7.518255)
	PedSetActionNode(gEnemy03, "/Global/3_R09/Animations/Preppies/Preppies03", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy03, "M_3_R09_P", 20, "jumbo", true)
	Wait(1000)
	CameraSetXYZ(-773.88855, 354.4307, 7.510019, -773.88544, 353.45074, 7.708982)
	PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Preppies/Player01", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gPlayer, "M_3_R09_P", 21, "jumbo", true)
	UnLoadAnimationGroup("NIS_3_R09_P")
end

function F_JocksSetupP1()
	TextPrint("3_R09_96", 4, 1)
	gMainFunction = F_Part01S1
	gSpawnModels = gJockModels
	gAllyModels = gNerdModels
	gEnemyPedType = 2
	gAllyPedType = 1
	gNoOfEnemies = 5
	gNoOfAllies = 1
	gStagePart = 0
	gArea = 0
	gEnemies = {}
	gMissionText = "3_R09_97"
	gPop = {
		9,
		0,
		0,
		0,
		0,
		0,
		0,
		4,
		0,
		0,
		5,
		0,
		0
	}
	gGiverModel = 6
	gGiverPoint = POINTLIST._3_R09_J
end

function F_JocksSetupP2()
	TextPrint("3_R09_98", 4, 1)
	gMainFunction = F_Part02S1
	gSpawnModels = gJockSportModels
	gAllyModels = gNerdModels
	gEnemyPedType = 2
	gAllyPedType = 1
	gNoOfEnemies = 10
	gStagePart = 0
	gArea = 0
	gEnemies = {}
	gMissionText = "3_R09_97"
	gPOIList = {
		POI._3_R09_POI01,
		POI._3_R09_POI01,
		POI._3_R09_POI01,
		POI._3_R09_POI02,
		POI._3_R09_POI02,
		POI._3_R09_POI02,
		false,
		false,
		false,
		false
	}
	gFunctions = {
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		{ "PlayCatch" },
		{
			PedFollowPath,
			PATH._3_R09_TRAINPATH,
			1,
			1,
			F_EmptyCallback
		},
		{
			PedFollowPath,
			PATH._3_R09_TRAINPATH,
			1,
			1,
			F_EmptyCallback
		}
	}
	gWeaponList = {
		false,
		false,
		300,
		false,
		false,
		false,
		false,
		331,
		331,
		false
	}
	gGiverModel = 6
	gGiverPoint = POINTLIST._3_R09_J
end

function F_JocksSetupP3()
	MissionAllowConcurrentMissions(true)
	gUnlockHideoutText = "3_R09_UJ"
	gMainFunction = F_JockStage01
	gCutsceneFunction = F_P03CutJocks
	gSpawnModels = gJockModels
	F_SetAllUnique(true)
	gDoorTrigger = "DT_TSCHOOL_SAFEJOCK"
	gSpawnLocations = {
		{
			pointlist = POINTLIST._3_R09_SPAWN01,
			trigger = TRIGGER._3_R09_SPAWNT01
		},
		{
			pointlist = POINTLIST._3_R09_SPAWN02,
			trigger = TRIGGER._3_R09_SPAWNT02
		}
	}
	gSpawnText = {
		"3_R09_D8",
		"3_R09_D9",
		"3_R09_E1"
	}
	gStagePart = 0
	gMaxKills = 3
	gArea = 13
	cx, cy, cz = -751.7783, 352.9332, 4.664
	tx, ty, tz = -753.502, 348.234, 5.07941
	bx, by, bz = -740.786, 348.685, 4.707
	fx, fy, fz = -752.2782, 352.8313, 5.2639
	gCutsceneGuys = {
		18,
		17,
		16
	}
	gAnimationGroups = {
		"Hang_Talking",
		"Cheer_Cool1",
		"NIS_3_R09_J"
	}
	gEnemyPedType = 2
	gGiverModel = 6
	gGiverPoint = POINTLIST._3_R09_J
	gObjectiveString = "3_R09_97"
	gMissionNoRunning = 4
	gFinalHeading = 170
	gMusic = "MS_GymClass.rsm"
end

function F_P03CutJocks()
	F_MakePlayerSafeForNIS(true)
	PedMoveToPoint(gPlayer, 0, POINTLIST._3_R09_NISPLAYER, 2)
	PedFaceObject(gEnemy02, gPlayer, 3, 0)
	Wait(1500)
	PedSetWeapon(gEnemy01, 331, 1)
	PedPlayCatch(gEnemy01, gEnemy03, 10000)
	PedPlayCatch(gEnemy03, gEnemy01, 10000)
	PedSetActionNode(gEnemy02, "/Global/3_R09/Animations/Jocks/Casey01", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy02, "M_3_R09", 102, "large", true)
	CameraSetFOV(30)
	CameraSetXYZ(-625.7554, -61.391476, 61.22005, -625.411, -62.326435, 61.144203)
	PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Jock/Player02", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gPlayer, "M_3_R09", 103, "large", true)
	CameraSetFOV(30)
	CameraSetXYZ(-626.3904, -70.10445, 61.129646, -625.9414, -69.215706, 61.048626)
	PedSetActionNode(gEnemy02, "/Global/3_R09/Animations/Jocks/Casey02", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy02, "M_3_R09", 104, "large", true)
	PedClearObjectives(gEnemy02)
	PedStop(gEnemy02)
	PedClearObjectives(gPlayer)
	PedStop(gPlayer)
	UnLoadAnimationGroup("3_R09_J")
	F_MakePlayerSafeForNIS(false)
	CameraDefaultFOV()
end

function F_DOSetupP1()
	TextPrint("3_R09_B1", 4, 1)
	gMainFunction = F_Part01S1
	gSpawnModels = gDOModels
	gAllyModels = gJockModels
	gEnemyPedType = 3
	gAllyPedType = 2
	gNoOfEnemies = 7
	gNoOfAllies = 2
	gStagePart = 0
	gArea = 0
	gEnemies = {}
	gMissionText = "3_R09_B2"
	gPop = {
		4,
		0,
		0,
		0,
		0,
		0,
		0,
		4,
		0,
		0,
		0,
		0,
		0
	}
	gGiverModel = 12
	gGiverPoint = POINTLIST._3_R09_D
	VehicleCreatePoint(293, POINTLIST._3_R09_VEHICLES01, 1)
	VehicleCreatePoint(293, POINTLIST._3_R09_VEHICLES01, 2)
end

function F_DOSetupP2()
	TextPrint("3_R09_B3", 4, 1)
	gMainFunction = F_Part02S1
	gSpawnModels = gDOModels
	gAllyModels = gJockModels
	gEnemyPedType = 3
	gAllyPedType = 2
	gNoOfEnemies = 12
	gStagePart = 0
	gArea = 0
	gEnemies = {}
	gMissionText = "3_R09_B2"
	gPOIList = {
		POI._3_R09_POI01,
		POI._3_R09_POI01,
		POI._3_R09_POI01,
		POI._3_R09_POI02,
		POI._3_R09_POI02,
		POI._3_R09_POI02,
		POI._3_R09_POI03,
		POI._3_R09_POI03,
		POI._3_R09_POI03,
		POI._3_R09_POI04,
		POI._3_R09_POI04,
		POI._3_R09_POI04
	}
	gWeaponList = {
		311,
		false,
		false,
		false,
		MODELENUM._W_GARBBIN,
		false,
		false,
		false,
		311,
		false,
		false,
		false
	}
	gGiverModel = 12
	gGiverPoint = POINTLIST._3_R09_D
end

function F_DOSetupP3()
	gUnlockHideoutText = "3_R09_UD"
	gMainFunction = F_Part03S1
	gCutsceneFunction = F_P03CutDOs
	gSpawnModels = gDOModels
	F_SetAllUnique(true)
	gDoorTrigger = "DT_TIND_SAFEDROP"
	gSpawnLocations = {
		{
			pointlist = POINTLIST._3_R09_SPAWN01,
			trigger = TRIGGER._3_R09_SPAWNT01
		},
		{
			pointlist = POINTLIST._3_R09_SPAWN02,
			trigger = TRIGGER._3_R09_SPAWNT02
		}
	}
	gSpawnText = {
		"3_R09_E2",
		"3_R09_E3",
		"3_R09_E4"
	}
	gStagePart = 0
	gMaxKills = 3
	gArea = 57
	cx, cy, cz = -659.063, 252.345, 16.485
	tx, ty, tz = -659.937, 253.595, 15.731
	bx, by, bz = -653.655, 247.796, 16.331
	fx, fy, fz = -660.38, 254.271, 16.731
	gCutsceneGuys = {
		44,
		41,
		42
	}
	gAnimationGroups = {
		"Hang_Talking",
		"IDLE_DOUT_B",
		"IDLE_DOUT_D",
		"NIS_3_R09_D"
	}
	gEnemyPedType = 3
	gGiverModel = 12
	gGiverPoint = POINTLIST._3_R09_D
	gObjectiveString = "3_R09_B2"
	gMissionNoRunning = 5
	gFinalHeading = 120
	gMusic = "MS_FightingDropouts.rsm"
	gDoorToLock = TRIGGER._DT_ISAFEDROP_DOORL
	gSpawnerDoors = {
		TRIGGER._DRPDOOR,
		TRIGGER._DRPDOOR01
	}
	gEndPed = 43
end

function F_P03CutDOs()
	CameraSetXYZ(-659.11426, 250.01138, 15.68246, -658.7884, 250.94919, 15.801522)
	PedSetActionNode(gEnemy01, "/Global/3_R09/Animations/Dropouts/Dropouts01", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy01, "M_3_R09", 87, "large", true)
	CameraSetXYZ(-656.5098, 253.56673, 16.314045, -657.2159, 254.27415, 16.343697)
	PedSetActionNode(gEnemy02, "/Global/3_R09/Animations/Dropouts/Dropouts02", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy02, "M_3_R09", 13, "large", true)
	CameraSetXYZ(-658.6594, 257.1186, 16.250246, -658.36487, 256.16312, 16.265566)
	PedFaceObject(gEnemy01, gPlayer, 3, 1)
	PedSetActionNode(gEnemy01, "/Global/3_R09/Animations/Dropouts/Dropouts03", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy01, "M_3_R09", 89, "large", true)
	CameraSetXYZ(-657.2502, 248.99585, 16.144533, -656.9541, 248.04109, 16.118336)
	PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Dropouts/Dropouts01", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gPlayer, "M_3_R09", 115, "large", true)
	PedFaceObject(gEnemy02, gPlayer, 3, 0)
	PedFaceObject(gEnemy03, gPlayer, 3, 0)
	CameraSetXYZ(-657.82135, 253.53845, 16.39159, -657.30396, 254.39395, 16.40358)
	PedSetActionNode(gEnemy03, "/Global/3_R09/Animations/Dropouts/Dropouts04", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gEnemy03, "M_3_R09", 16, "large", true)
	CameraSetXYZ(-656.91284, 247.70456, 16.407793, -656.6116, 246.75157, 16.437649)
	PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Dropouts/Dropouts02", "Act/Conv/3_R09.act")
	F_PlaySpeechAndWait(gPlayer, "M_3_R09", 17, "large", true)
	UnLoadAnimationGroup("NIS_3_R09_N")
end

function F_JockStage01()
	if gStagePart == 0 then
		gStagePart = 1
	elseif gStagePart == 1 then
		if AreaGetVisible() == gArea then
			local koX, koY, koZ = GetPointList(POINTLIST._3_R09_BLIPP3)
			for i, group in gAnimationGroups do
				LoadAnimationGroup(group)
			end
			LoadModels(gCutsceneGuys)
			LoadModels(gSpawnModels)
			gEnemy01 = PedCreatePoint(gCutsceneGuys[1], POINTLIST._3_R09_FIRST, 1)
			gEnemy02 = PedCreatePoint(gCutsceneGuys[2], POINTLIST._3_R09_FIRST, 2)
			gEnemy03 = PedCreatePoint(gCutsceneGuys[3], POINTLIST._3_R09_FIRST, 3)
			F_PedFearless(gEnemy01)
			F_PedFearless(gEnemy02)
			F_PedFearless(gEnemy03)
			PedIgnoreStimuli(gEnemy01, true)
			PedIgnoreStimuli(gEnemy02, true)
			PedIgnoreStimuli(gEnemy03, true)
			PedClearAllWeapons(gEnemy01)
			PedClearAllWeapons(gEnemy02)
			PedOverrideStat(gEnemy02, 0, 362)
			PedOverrideStat(gEnemy02, 1, 100)
			PedClearAllWeapons(gEnemy03)
			PlayerSetControl(0)
			CameraSetWidescreen(true)
			PlayerSetPosPoint(POINTLIST._3_R09_NISPLAYER, 1)
			PedStop(gPlayer)
			PedClearObjectives(gPlayer)
			Wait(500)
			CameraSetFOV(70)
			CameraSetXYZ(-627.9048, -69.9778, 62.765903, -627.2915, -69.26165, 62.434746)
			CameraFade(1000, 1)
			gCutsceneFunction()
			CameraSetWidescreen(false)
			PlayerSetControl(1)
			CameraReturnToPlayer()
			CameraReset()
			PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Empty", "Act/Conv/3_R09.act")
			AddBlipForChar(gEnemy01, gEnemyPedType, 2, 1)
			PedSetPedToTypeAttitude(gEnemy01, 13, 4)
			AddBlipForChar(gEnemy02, gEnemyPedType, 2, 1)
			PedSetPedToTypeAttitude(gEnemy02, 13, 4)
			AddBlipForChar(gEnemy03, gEnemyPedType, 2, 1)
			PedSetPedToTypeAttitude(gEnemy03, 13, 4)
			for i, group in gAnimationGroups do
				UnLoadAnimationGroup(group)
			end
			CameraFade(-1, 0)
			Wait(FADE_OUT_TIME)
			PedDelete(gEnemy01)
			PedDelete(gEnemy02)
			PedDelete(gEnemy03)
			gStagePart = 2
		end
	elseif gStagePart == 2 then
		gMainFunction = F_JockStage02DodgeballGame
		shared.JockVendettaRunning = true
		shared.DodgeballSuccess = nil
		gStagePart = 1
	end
end

function F_JockStage02DodgeballGame()
	if gStagePart == 1 then
		if gStartedAFight then
			if shared.DodgeballSuccess == 1 and not MissionActiveSpecific("C_Dodgeball_5") then
				gStagePart = 2
				shared.DodgeballSuccess = nil
				gStartedAFight = false
			elseif shared.DodgeballSuccess == 0 and not MissionActiveSpecific("C_Dodgeball_5") then
				shared.DodgeballSuccess = nil
				SoundPlayMissionEndMusic(false, gMusicType)
				gMissionRunning = false
				MissionFail(true, true, "3_R09_Dodgeball")
			end
		else
			gStartedAFight = true
			ForceStartMission("C_Dodgeball_5")
		end
	elseif gStagePart == 2 then
		F_MakePlayerSafeForNIS(true)
		PlayerSetPosPoint(POINTLIST._3_R09_UNLOCKPEDS)
		LoadModels({
			204,
			206,
			207
		})
		jock01 = PedCreatePoint(204, POINTLIST._3_R09_UNLOCKPEDS, 2)
		jock02 = PedCreatePoint(17, POINTLIST._3_R09_UNLOCKPEDS, 3)
		jock03 = PedCreatePoint(207, POINTLIST._3_R09_UNLOCKPEDS, 4)
		LoadAnimationGroup("NIS_3_R09_J")
		PedFaceObject(jock01, gPlayer, 2, 0)
		PedLockTarget(jock01, gPlayer)
		CameraSetFOV(40)
		CameraSetXYZ(-626.34326, -68.70289, 61.321487, -625.3926, -68.97655, 61.17689)
		SoundDisableSpeech_ActionTree()
		CameraSetWidescreen(true)
		PlayerSetControl(0)
		CameraFade(-1, 1)
		PedSetActionNode(jock02, "/Global/3_R09/Animations/Jocks/JocksOutro/Casey01", "Act/Conv/3_R09.act")
		F_PlaySpeechAndWait(jock02, "M_3_R09", 105, "large", true)
		CameraSetFOV(40)
		CameraSetXYZ(-618.74493, -67.910095, 61.402576, -619.56915, -68.45039, 61.23326)
		PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Jock/PlayerOutro", "Act/Conv/3_R09.act")
		F_PlaySpeechAndWait(gPlayer, "M_3_R09", 106, "large", true)
		CameraFade(-1, 0)
		Wait(FADE_OUT_TIME)
		CameraDefaultFOV()
		UnLoadAnimationGroup("NIS_3_R09_J")
		AreaTransitionPoint(0, POINTLIST._3_R09_ENDAFTERGAME, 1, true)
		CameraSetFOV(30)
		CameraSetXYZ(-40.395813, -59.555893, 9.653583, -39.973267, -58.66006, 9.516783)
		CameraSetWidescreen(true)
		Wait(3000)
		SoundDisableSpeech_ActionTree()
		SoundDisableSpeech()
		CameraFade(-1, 1)
		Wait(FADE_IN_TIME)
		MinigameSetCompletion("M_PASS", true, 0, gUnlockHideoutText)
		MinigameHoldCompletion()
		SoundPlayMissionEndMusic(true, gMusicType)
		Wait(3000)
		MinigameSetCompletion("M_PASS", true, 0, gUnlockHideoutText)
		MinigameHoldCompletion()
		Wait(2000)
		CameraFade(-1, 0)
		Wait(FADE_OUT_TIME + 500)
		AreaTransitionPoint(59, POINTLIST._3_R09_SPAWN02, nil, true)
		Wait(500)
		tx, ty, tz = -753.502, 348.234, 5.07941
		CameraLookAtXYZ(tx, ty, tz, true)
		CameraSetPath(PATH._3_R09_UNLOCKPATH, true)
		CameraSetSpeed(2.2, 2.2, 2.2)
		CameraSetWidescreen(true)
		CameraFade(-1, 1)
		MinigameSetCompletion("M_PASS", true, 0, "3_R09_C7")
		MinigameHoldCompletion()
		Wait(3000)
		MinigameSetCompletion("M_PASS", true, 0, "3_R09_C7")
		MinigameHoldCompletion()
		Wait(2000)
		MinigameReleaseCompletion()
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		Wait(1000)
		CameraFade(-1, 0)
		Wait(FADE_OUT_TIME + 500)
		AreaTransitionPoint(0, POINTLIST._3_R09_ENDAFTERGAME, 1, true)
		SoundEnableSpeech_ActionTree()
		SoundEnableSpeech()
		CameraSetWidescreen(false)
		CameraReset()
		CameraReturnToPlayer()
		PedMakeAmbient(jock01)
		PedMakeAmbient(jock02)
		PedMakeAmbient(jock03)
		PlayerSetControl(1)
		PedSetWeaponNow(gPlayer, -1, 0)
		shared.jocksSave = true
		F_MakePlayerSafeForNIS(false)
		MissionSucceed(false, false, false)
		PedWander(jock01, 0)
		PedWander(jock02, 0)
		PedWander(jock03, 0)
	end
end

function F_PrepStage01() -- ! Modified
	if gStagePart == 0 then
		AreaTransitionPoint(27, POINTLIST._3_R09_POSTERVIEWING, 1, true)
		Wait(1000)
		CameraLookAtXYZ(-697.56714, 373.25122, 295.77036, true)
		CameraSetXYZ(-698.9878, 372.7426, 295.27097, -697.56714, 373.25122, 295.77036)
		t, i = CreatePersistentEntity("BX_PosterHI", -696.933, 373.405, 296.084, 0, 27)
		GeometryInstance("BX_PosterLO", true, -696.933, 373.405, 296.084, false)
		PlayerSetControl(0)
		CameraSetWidescreen(true)
		CameraFade(-1, 1)
		Wait(2000)
		PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Nerds/Player01", "Act/Conv/3_R09.act")
		SoundPlayScriptedSpeechEvent(gPlayer, "M_3_R09", 38, "speech")
		Wait(4000)
		CameraFade(-1, 0)
		Wait(FADE_OUT_TIME)
		DeletePersistentEntity(t, i)
		GeometryInstance("BX_PosterLO", false, -696.933, 373.405, 296.084, false)
		CameraSetWidescreen(false)
		shared.PrepVendettaRunning = 1
		gStartedAFight = false
		gFightStage = 1
		gFightMission = "2_R11_Random"
		gStagePart = 1
	elseif gStagePart == 1 then
		if gStartedAFight then
			if shared.BoxingSuccess == 1 and not MissionActiveSpecific(gFightMission) then
				gFightStage = gFightStage + 1
				if gFightStage == 2 then
					shared.PrepVendettaRunning = 2
					gFightMission = "2_R11_Random"
				elseif gFightStage == 3 then
					shared.PrepVendettaRunning = 3
					gFightMission = "2_R11_Random"
				end
				if gFightStage >= 4 then
					gStagePart = 2
				end
				shared.BoxingSuccess = nil
				gStartedAFight = false
			elseif shared.BoxingSuccess == 0 and not MissionActiveSpecific(gFightMission) then
				shared.BoxingSuccess = nil
				gMissionRunning = false
				MissionFail(false, false, "3_R09_Tournament")
			end
		else
			gStartedAFight = true
			ForceStartMission(gFightMission)
		end
	elseif gStagePart == 2 then
		ClothingBackup()
		ClothingSetPlayerOutfit("Boxing")
		ClothingBuildPlayer()
		LoadAnimationGroup("NIS_3R09_P")
		CameraSetFOV(80)
		CameraSetXYZ(-701.7605, 370.26483, 295.00967, -702.388, 371.0432, 295.02457)
		CameraSetWidescreen(true)
		PlayerSetControl(0)
		gBoxerIds = {}
		for i, boxer in gBoxers do
			gBoxerIds[i] = PedCreatePoint(boxer, POINTLIST._3_R09_BOXERS, i)
			PedSetCheap(gBoxerIds[i], true)
		end
		PlayerSetPosPoint(POINTLIST._3_R09_BOXERS, 6)
		SoundDisableSpeech_ActionTree()
		CameraFade(-1, 1)
		CameraSetFOV(80)
		Wait(FADE_IN_TIME)
		PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Player/Preppies/Player01", "Act/Conv/3_R09.act")
		F_PlaySpeechAndWait(gPlayer, "M_3_R09", 99, "jumbo")
		PedSetActionNode(gBoxerIds[2], "/Global/3_R09/Animations/Preppies/Preppies01", "Act/Conv/3_R09.act")
		F_PlaySpeechAndWait(gBoxerIds[2], "M_3_R09", 100, "jumbo")
		CameraSetFOV(40)
		CameraSetXYZ(-707.1513, 370.5077, 294.99432, -706.37, 371.13174, 294.99826)
		PedSetActionNode(gBoxerIds[2], "/Global/3_R09/Animations/Preppies/Preppies02", "Act/Conv/3_R09.act")
		F_PlaySpeechAndWait(gBoxerIds[2], "M_3_R09", 101, "jumbo")
		CameraFade(-1, 0)
		Wait(FADE_OUT_TIME)
		CameraSetWidescreen(false)
		--[[
		AreaTransitionPoint(0, POINTLIST._3_R09_BEACH, nil, true)
		]] -- Modified to:
		AreaTransitionPoint(0, POINTLIST._3_R09_BOXINGOUTSIDE, nil, true)
		gStagePart = 3
	elseif gStagePart == 3 then
		CameraSetWidescreen(true)
		CameraSetFOV(80)
		CameraSetXYZ(250.81638, 315.11426, 7.10624, 250.24348, 315.9081, 7.309675)
		Wait(4500)
		SoundDisableSpeech_ActionTree()
		SoundDisableSpeech()
		CameraFade(-1, 1)
		Wait(FADE_IN_TIME)
		MinigameSetCompletion("M_PASS", true, 0, gUnlockHideoutText)
		SoundPlayMissionEndMusic(true, gMusicType)
		Wait(3000)
		MinigameSetCompletion("M_PASS", true, 0, gUnlockHideoutText)
		Wait(3000)
		CameraFade(-1, 0)
		Wait(FADE_OUT_TIME + 500)
		AreaTransitionPoint(60, POINTLIST._3_R09_PLAYER, nil, true)
		Wait(500)
		tx, ty, tz = -776.854, 358.89, 7.796
		CameraLookAtXYZ(tx, ty, tz, true)
		CameraSetPath(PATH._3_R09_UNLOCKPATH, true)
		CameraSetSpeed(2.2, 2.2, 2.2)
		CameraSetWidescreen(true)
		CameraFade(-1, 1)
		Wait(FADE_IN_TIME)
		MinigameSetCompletion("M_PASS", true, 0, "3_R09_C7")
		MinigameHoldCompletion()
		Wait(3000)
		MinigameSetCompletion("M_PASS", true, 0)
		Wait(500)
		MinigameSetCompletion("M_PASS", true, 0, "3_R09_Boxing")
		MinigameReleaseCompletion()
		Wait(3000)
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		Wait(1000)
		CameraFade(-1, 0)
		Wait(FADE_OUT_TIME + 500)
		AreaTransitionPoint(0, POINTLIST._3_R09_BOXINGOUTSIDE, nil, true)
		SoundEnableSpeech()
		SoundEnableSpeech_ActionTree()
		UnLoadAnimationGroup("NIS_3R09_P")
		ClothingGivePlayerOutfit("Boxing NG")
		CameraSetWidescreen(false)
		shared.prepsSave = true
		ClothingRestore()
		ClothingBuildPlayer()
		CameraReset()
		CameraReturnToPlayer()
		PlayerSetControl(1)
		MissionSucceed(false, false, false)
	end
end

function F_EmptyCallback()
end

function F_PedFearless(pedId)
	PedOverrideStat(pedId, 7, 0)
	PedOverrideStat(pedId, 6, 0)
end

function F_CreateEnemy(pointList, index, setPOI)
	--print(" CREATING ENEMY", index)
	gEnemies[index] = {
		id = -1,
		blipId = -1,
		isRequired = true
	}
	if gDogPoint == index then
		gEnemies[index].id = PedCreatePoint(141, pointList, index)
		gEnemies[index].isRequired = false
	else
		gEnemies[index].id = PedCreatePoint(RandomTableElement(gSpawnModels), pointList, index)
	end
	Wait(10)
	PedClearAllWeapons(gEnemies[index].id)
	PedSetPedToTypeAttitude(gEnemies[index].id, gAllyPedType, 0)
	PedSetPedToTypeAttitude(gEnemies[index].id, 13, 0)
	PedSetPedToTypeAttitude(gEnemies[index].id, 9, 2)
	PedSetPedToTypeAttitude(gEnemies[index].id, 6, 2)
	Wait(100)
	F_PedFearless(gEnemies[index].id)
	if setPOI then
		if gWeaponList[index] then
			PedSetWeapon(gEnemies[index].id, gWeaponList[index], 1)
		end
		if gPOIList[index] then
			POISetDisablePedProduction(gPOIList[index], false)
			PedSetPOI(gEnemies[index].id, gPOIList[index], false)
		else
			PedSetStealthBehavior(gEnemies[index].id, 1, CbSeenPlayer)
			local lFunction = gFunctions[index]
			if gFunctions[index] then
				if lFunction[1] == "PlayCatch" then
					PedPlayCatch(gEnemies[index].id, gEnemies[index - 1].id, 58000)
					PedPlayCatch(gEnemies[index - 1].id, gEnemies[index].id, 58000)
				elseif lFunction[1] == "Hangout" then
					PedSetActionNode(gEnemies[index].id, "/Global/POIPoint/HangOut", "Act/AI/AI_POI.act")
				elseif lFunction[1] == "PedSetActionNode" then
					PedSetActionNode(gEnemies[index].id, lFunction[2], lFunction[3])
				else
					lFunction[1](gEnemies[index].id, lFunction[2], lFunction[3], lFunction[4], lFunction[5])
				end
			end
		end
	else
		PedOverrideStat(gEnemies[index].id, 15, 100)
		PedOverrideStat(gEnemies[index].id, 14, 100)
		PedWander(gEnemies[index].id, 1)
		PedSetTetherToTrigger(gEnemies[index].id, TRIGGER._3_R09_AREAT01)
	end
	gPedsSpawned = gPedsSpawned + 1
	if 2 <= gPedsSpawned then
		PedOverrideStat(gEnemies[index].id, 0, 362)
		PedOverrideStat(gEnemies[index].id, 1, 100)
		gPedsSpawned = 0
	end
	if gEnemies[index].isRequired then
		gEnemies[index].blipId = AddBlipForChar(gEnemies[index].id, gEnemyPedType, 0, 4)
	end
	--print(" FINISHED CREATING ENEMY", index)
end

function F_CreateAlly(pointList, index)
	local allyId = PedCreatePoint(RandomTableElement(gAllyModels), pointList, index)
	PedSetPedToTypeAttitude(allyId, gEnemyPedType, 0)
	PedSetPedToTypeAttitude(allyId, gPlayer, 4)
	PedSetPedToTypeAttitude(gPlayer, allyId, 4)
	AddBlipForChar(allyId, gAllyPedType, 2, 1)
	table.insert(gAllies, allyId)
	PedRecruitAlly(gPlayer, allyId)
	PedSetAllyAutoEngage(allyId, true)
	local health = PedGetHealth(allyId)
	PedSetHealth(allyId, health * 2)
end

function F_CheckEnemies()
	local allDead = true
	for i, lEnemy in gEnemies do
		if gEnemies[i].id and not PedIsDead(gEnemies[i].id) and gEnemies[i].isRequired then
			allDead = false
			break
		end
	end
	return allDead
end

function F_Part01S1()
	if gStagePart == 0 then
		gBlip = BlipAddPoint(POINTLIST._3_R09_BLIPP1, 0)
		--print("CREATED THE FIRST BLIP")
		gStagePart = 1
	elseif gStagePart == 1 then
		if PlayerIsInTrigger(TRIGGER._3_R09_AREAT01) then
			BlipRemove(gBlip)
			AreaOverridePopulation(gPop[1], gPop[2], gPop[3], gPop[4], gPop[5], gPop[6], gPop[7], gPop[8], gPop[9], gPop[10], gPop[11], gPop[12], gPop[13])
			for i = 1, gNoOfEnemies do
				F_CreateEnemy(POINTLIST._3_R09_ENEMIESP1, i)
			end
			for j = 1, gNoOfAllies do
				F_CreateAlly(POINTLIST._3_R09_ALLIESP1, j)
			end
			TextPrint(gMissionText, 4, 1)
			gStagePart = 2
		end
	elseif gStagePart == 2 then
		if F_CheckEnemies() then
			TextPrint("3_R09_C5", 3, 1)
			Wait(1000)
			gMissionRunning = false
			MissionSucceed()
		end
		if not AreaGetVisible() == gArea then
			gMissionRunning = false
			SoundPlayMissionEndMusic(false, gMusicType)
			MissionFail(true, true, "3_R09_Failed")
		end
	end
end

function F_Part02S1()
	if gStagePart == 0 then
		gBlip = BlipAddPoint(POINTLIST._3_R09_BLIPP2, 0)
		gStagePart = 1
	elseif gStagePart == 1 then
		if PlayerIsInTrigger(TRIGGER._3_R09_AREAT02) then
			BlipRemove(gBlip)
			AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
			PedSetTypeToTypeAttitude(9, 13, 4)
			for i = 1, gNoOfEnemies do
				F_CreateEnemy(POINTLIST._3_R09_ENEMIESP2, i, true)
			end
			TextPrint(gMissionText, 4, 1)
			gStagePart = 2
		end
	elseif gStagePart == 2 then
		if F_CheckEnemies() then
			TextPrint("3_R09_C5", 3, 1)
			Wait(1000)
			gMissionRunning = false
			MissionSucceed()
		end
		if not AreaGetVisible() == gArea then
			gMissionRunning = false
			SoundPlayMissionEndMusic(false, gMusicType)
			MissionFail(true, true, "3_R09_Failed")
		end
	end
end

local mpx, mpy, mpz = 0, 0, 0

function F_Part03S1()
	if gStagePart == 0 then
		--print("Stage Part 0 ")
		gStagePart = 1
	elseif gStagePart == 1 then
		--print("Stage Part 1 ")
		if AreaGetVisible() == gArea then
			local koX, koY, koZ = GetPointList(POINTLIST._3_R09_BLIPP3)
			AreaClearAllPeds()
			MissionOverrideKOPoint(koX, koY, koZ, gFinalHeading, 0)
			for i, group in gAnimationGroups do
				LoadAnimationGroup(group)
			end
			LoadModels(gCutsceneGuys)
			LoadModels(gSpawnModels)
			gEnemy01 = PedCreatePoint(gCutsceneGuys[1], POINTLIST._3_R09_FIRST, 1)
			gEnemy02 = PedCreatePoint(gCutsceneGuys[2], POINTLIST._3_R09_FIRST, 2)
			gEnemy03 = PedCreatePoint(gCutsceneGuys[3], POINTLIST._3_R09_FIRST, 3)
			F_PedFearless(gEnemy01)
			F_PedFearless(gEnemy02)
			F_PedFearless(gEnemy03)
			PedIgnoreStimuli(gEnemy01, true)
			PedIgnoreStimuli(gEnemy02, true)
			PedIgnoreStimuli(gEnemy03, true)
			PedClearAllWeapons(gEnemy01)
			PedClearAllWeapons(gEnemy02)
			PedOverrideStat(gEnemy02, 0, 362)
			PedOverrideStat(gEnemy02, 1, 100)
			PedClearAllWeapons(gEnemy03)
			PlayerSetControl(0)
			CameraLookAtXYZ(cx, cy, cz, true)
			CameraSetPath(PATH._3_R09_CAMERAPATH, true)
			CameraSetWidescreen(true)
			AreaClearAllPeds()
			F_MakePlayerSafeForNIS(true)
			Wait(1000)
			CameraFade(1000, 1)
			AreaSetDoorLocked(gDoorToLock, true)
			AreaSetDoorLockedToPeds(gDoorToLock, true)
			gCutsceneFunction()
			CameraSetWidescreen(false)
			PlayerSetControl(1)
			F_MakePlayerSafeForNIS(false)
			CameraReturnToPlayer()
			CameraReset()
			PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Empty", "Act/Conv/3_R09.act")
			AddBlipForChar(gEnemy01, gEnemyPedType, 2, 1)
			PedSetPedToTypeAttitude(gEnemy01, 13, 0)
			AddBlipForChar(gEnemy02, gEnemyPedType, 2, 1)
			PedSetPedToTypeAttitude(gEnemy02, 13, 0)
			AddBlipForChar(gEnemy03, gEnemyPedType, 2, 1)
			PedSetPedToTypeAttitude(gEnemy03, 13, 0)
			PedAttackPlayer(gEnemy01)
			PedAttackPlayer(gEnemy02)
			PedAttackPlayer(gEnemy03)
			gSpawnedPeds[1] = gEnemy01
			gSpawnedPeds[2] = gEnemy02
			gSpawnedPeds[3] = gEnemy03
			gTotalPeds = 3
			PedIgnoreStimuli(gEnemy01, false)
			PedIgnoreStimuli(gEnemy02, false)
			PedIgnoreStimuli(gEnemy03, false)
			for i, group in gAnimationGroups do
				UnLoadAnimationGroup(group)
			end
			PedSetFlag(gPlayer, 58, true)
			gMissionObjective = MissionObjectiveAdd(gObjectiveString)
			TextPrint(gObjectiveString, 4, 1)
			if gMusic then
				SoundPlayStream(gMusic, 0.6)
			end
			if gSpawnerDoors then
				for i, door in gSpawnerDoors do
					AreaSetDoorLocked(door, true)
					AreaSetDoorLockedToPeds(door, false)
				end
			end
			gStagePart = 2
		end
	elseif gStagePart == 2 then
		if PedIsDead(gEnemy01) and PedIsDead(gEnemy02) and PedIsDead(gEnemy03) then
			gStagePart = 1
			F_SetupSpawner()
			mpx, mpy, mpz = GetPointList(POINTLIST._3_R09_GOTO)
			gMainFunction = F_Part03S2
		end
		F_FailIfOutside()
		F_FailIfDead()
	end
end

function F_Part03S2()
	for i, enemy in gSpawnerPedsAttack do
		if enemy and PedIsValid(enemy) then
			if PedIsInTrigger(enemy, TRIGGER._3_R09_MAINAREA) then
				gSpawnerPedsAttack[i] = false
				PedSetFocus(enemy, gPlayer)
				PedAttackPlayer(enemy, 3)
				--print("ATTACKING THE PLAYER PED NO..", i)
			else
				PedMoveToPoint(enemy, 2, POINTLIST._3_R09_GOTO, 1, nil, 2)
			end
		end
	end
	if AreaMissionSpawnerExhausted(idSpawner) then
		F_TakeoverScene()
		if gMissionNoRunning == 2 then
			shared.greasersSave = true
		elseif gMissionNoRunning == 3 then
			shared.prepsSave = true
		elseif gMissionNoRunning == 4 then
			shared.jocksSave = true
		elseif gMissionNoRunning == 5 then
			shared.dropoutsSave = true
		end
		if gMissionNoRunning ~= 4 then
			shared.unlockedClothing = true
		end
		gMissionRunning = false
		--print(" < < < < <  < < < < <  < << < < [RAUL]", gMissionNoRunning)
		gMissionSucceeded = true
		MissionSucceed(true, true, false)
	end
	F_FailIfDead()
	F_FailIfOutside()
end

function F_FailIfOutside()
	if AreaGetVisible() ~= gArea then
		gMissionRunning = false
		SoundPlayMissionEndMusic(false, gMusicType)
		MissionFail(false, true, "3_R09_Left")
	end
end

function F_FailIfDead()
	if PlayerGetHealth() <= 0 then
		gMissionRunning = false
		PlayerSetControl(0)
		CameraFade(-1, 0)
		Wait(FADE_OUT_TIME + 10)
		F_DeleteAll()
		Wait(500)
		PlayerSetHealth(PedGetMaxHealth(gPlayer))
		PedSetActionNode(gPlayer, "/Global/Player/Default_KEY/Default", "Act/Player.act")
		if gDoorToLock then
			AreaSetDoorLocked(gDoorToLock, false)
			AreaSetDoorLockedToPeds(gDoorToLock, false)
		end
		AreaTransitionPoint(0, POINTLIST._3_R09_ENDSEQUENCE, 1, true)
		PlayerSetPunishmentPoints(0)
		local endPed = PedCreatePoint(gEndPed, POINTLIST._3_R09_ENDSEQUENCE, 2)
		PedIgnoreStimuli(endPed, true)
		PedSetPedToTypeAttitude(endPed, 13, 3)
		PedFaceObject(endPed, gPlayer, 3, 0)
		CameraSetWidescreen(true)
		PedClearAllWeapons(endPed)
		local x, y, z = GetPointList(POINTLIST._3_R09_FAILLOOKAT)
		CameraLookAtXYZ(x, y, z, true)
		NonMissionPedGenerationDisable()
		CameraSetPath(PATH._3_R09_FAILCAM, true)
		PedLockTarget(endPed, gPlayer, 3)
		CameraAllowChange(false)
		CameraFade(-1, 1)
		Wait(500)
		SoundPlayScriptedSpeechEvent(endPed, "VICTORY_TEAM", 0, "jumbo")
		PedSetActionNode(endPed, "/Global/Player/Social_Actions/HarassMoves/Shove_Still/Shove", "Act/Player.act")
		Wait(1000)
		SoundPlayMissionEndMusic(false, gMusicType)
		MissionFail(true, true, "M_FAIL_DEAD")
		Wait(5000)
		PedMoveToPoint(endPed, 0, POINTLIST._3_R09_ENDSEQUENCE, 3)
		PlayerSetControl(1)
		PedLockTarget(endPed, -1)
		NonMissionPedGenerationEnable()
	end
end

function F_SpawnerCallback(idPed, idSpawner)
	PedMakeMissionChar(idPed)
	if GetTimer() - gSpawningTimer > 4000 then
		SoundPlayAmbientSpeechEvent(idPed, "TRASH_TALK_TEAM")
		gSpawningTextCount = gSpawningTextCount + 1
		if gSpawningTextCount > 3 then
			gSpawningTextCount = 1
		end
		gSpawningTimer = GetTimer()
	end
	gTotalSpawned = gTotalSpawned + 1
	gSpawnerPedsAttack[gTotalSpawned] = idPed
	gPedsSpawned = gPedsSpawned + 1
	if 3 <= gPedsSpawned then
		PedOverrideStat(idPed, 0, 362)
		PedOverrideStat(idPed, 1, 100)
		gPedsSpawned = 0
	end
	AddBlipForChar(idPed, gEnemyPedType, 2, 1)
	PedSetPedToTypeAttitude(idPed, 13, 0)
	PedMoveToPoint(idPed, 2, POINTLIST._3_R09_GOTO, 1, nil, 2)
	table.insert(gToAttack, idPed)
end

function F_SetupSpawner()
	gSpawningTimer = GetTimer()
	gSpawningTextCount = 1
	idSpawner = AreaAddMissionSpawner(gMaxKills, gSimultEnemies, -1, 0, gTimeForSpawns)
	AreaMissionSpawnerSetCallback(idSpawner, F_SpawnerCallback)
	AreaMissionSpawnerSetAttackTarget(idSpawner, gPlayer, true)
	for i, spawnLoc in gSpawnLocations do
		gSpawnIds[i] = AreaAddSpawnLocation(idSpawner, spawnLoc.pointlist, spawnLoc.trigger)
	end
	local spawnerUsed = 1
	for _, idModel in gSpawnModels do
		--print("ADDING SPAWNER-MODEL", gSpawnIds[spawnerUsed], idModel)
		AreaAddPedModelIdToSpawnLocation(idSpawner, gSpawnIds[spawnerUsed], idModel)
		spawnerUsed = spawnerUsed + 1
		if spawnerUsed > table.getn(gSpawnIds) then
			spawnerUsed = 1
		end
	end
	AreaMissionSpawnerSetActivated(idSpawner, true)
end

function F_TakeoverScene()
	CameraFade(1000, 0)
	PlayerSetControl(0)
	LoadModels({ 307 })
	Wait(1500)
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	if gNerdMissionRunning then
		LoadAnimationGroup("WeaponUnlock")
		PlayerSetPosSimple(-730.2934, 36.06182, -2.3)
		PlayerFaceHeadingNow(-60.161495)
		GiveWeaponToPlayer(307, false)
		PlayerSetWeapon(307, 1, false)
		GiveAmmoToPlayer(307, 10, false)
		while not WeaponEquipped() do
			Wait(0)
		end
		PedSetActionNode(gPlayer, "//Global/3_R09/Animations/LoadBrocket/RemoveRocketsInCase", "Act/Conv/3_R09.act")
	end
	SoundDisableSpeech_ActionTree()
	CameraLookAtXYZ(tx, ty, tz, true)
	CameraSetPath(PATH._3_R09_UNLOCKPATH, true)
	CameraSetSpeed(2.2, 2.2, 2.2)
	CameraFade(500, 1)
	Wait(501)
	MinigameSetCompletion("M_PASS", true, 0, gUnlockHideoutText)
	MinigameHoldCompletion()
	SoundPlayMissionEndMusic(true, gMusicType)
	gShowBook = true
	Wait(3000)
	MinigameSetCompletion("M_PASS", true, 0)
	Wait(500)
	CameraLookAtXYZ(bx, by, bz, true)
	CameraSetPath(PATH._3_R09_BookPath, true)
	MinigameSetCompletion("M_PASS", true, 0, "3_R09_C7")
	Wait(3000)
	if gNerdMissionRunning then
		MinigameSetCompletion("M_PASS", true, 0)
		Wait(500)
		MinigameSetCompletion("M_PASS", true, 0, "3_R09_Unlock")
		CameraLookAtXYZ(-730.2934, 36.06182, -1.3129523, true)
		CameraSetXYZ(-727.4454, 36.311512, -1.212951, -730.2934, 36.06182, -1.3129523)
		PedSetActionNode(gPlayer, "/Global/3_R09/Animations/LoadBrocket", "Act/Conv/3_R09.act")
		SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "jumbo")
		Wait(3000)
	end
	MinigameReleaseCompletion()
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	if gNerdMissionRunning then
		PedSetActionNode(gPlayer, "/Global/3_R09/Animations/Empty", "Act/Conv/3_R09.act")
	end
	CameraFade(500, 0)
	Wait(501)
	SoundEnableSpeech_ActionTree()
	F_MakePlayerSafeForNIS(false)
	PlayerSetControl(1)
	CameraSetWidescreen(false)
end

function F_Continue()
	shared.g3_R09 = false
end

function F_IsSaveBookActive()
	if gShowBook then
		return 1
	else
		return 0
	end
end

function CbPlayerAggressed(id)
	SoundPlayScriptedSpeechEvent(id, "FIGHT_WTF", 0, "jumbo")
	gAggressed = true
end

function F_DeleteAll()
	for i, ped in gToAttack do
		if ped and PedIsValid(ped) then
			CleanPed(ped)
		end
	end
	if gEnemy01 and PedIsValid(gEnemy01) then
		CleanPed(gEnemy01)
	end
	if gEnemy02 and PedIsValid(gEnemy02) then
		CleanPed(gEnemy02)
	end
	if gEnemy03 and PedIsValid(gEnemy03) then
		CleanPed(gEnemy03)
	end
end

function CleanPed(id)
	--print("DELETING PED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	PedSetActionNode(id, "/Global/3_R09/Animations/Empty", "Act/Conv/3_R09.act")
	PedStop(id)
	PedClearObjectives(id)
	PedDelete(id)
end
