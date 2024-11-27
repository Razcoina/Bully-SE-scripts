--[[ Changes to this file:
	* Modified function T_MonitorKlepto, may require testing
]]

local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bGoToStage3 = false
local bKleptoIsDead = false
local bComicSpawned = false
local bLaunchedBikeTutorial = false
local bBikeTutorialShown = false
local bKleptoDismounted = false
local gWarningRange = 50
local gFailRange = 75
local bKleptoEscaping = false
local gPlayerX, gPlayerY, gKleptoX, gKleptoY = 0, 0, 0, 0
local gDistanceBetween = 0
local gMissionFailMessage = 0
local gMusicPlayerX, gMusicPlayerY, gMusicKleptoX, gMusicKleptoY = 0, 0, 0, 0
local bCurrentMusicIsMid = true
local gMusicRange = 45
local gMusicDistance = 0

function MissionSetup()
	--print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
	MissionDontFadeIn()
	DATLoad("2_02.DAT", 2)
	DATInit()
	if IsMissionFromDebug() then
		AreaTransitionPoint(0, POINTLIST._2_02_PLAYER, nil, false)
	end
	SoundPlayInteractiveStreamLocked("MS_BikeActionMid.rsm", MUSIC_DEFAULT_VOLUME)
	PlayCutsceneWithLoad("2-02", true, false, false, false)
	--print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
	--print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
	PickupRemoveAll(504)
	if F_PedExists(pedStoreOwner.id) then
		PedSetFlag(pedStoreOwner.id, 113, false)
		PedSetInvulnerable(pedStoreOwner.id, false)
		PedIgnoreStimuli(pedStoreOwner.id, false)
		PedSetStationary(pedStoreOwner.id, false)
		PedMakeAmbient(pedStoreOwner.id)
	end
	CameraSetWidescreen(false)
	SoundEnableSpeech_ActionTree()
	PlayerSetControl(1)
	if bMissionPassed then
		F_MakePlayerSafeForNIS(false)
	end
	SoundStopInteractiveStream()
	PedHideHealthBar()
	DATUnload(2)
	ItemSetCurrentNum(504, 0)
	--print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
	F_SetupMission()
	F_Stage1()
	if bMissionFailed then
		TextPrint("2_02_EMPTY", 1, 1)
		SoundPlayMissionEndMusic(false, 8)
		if gMissionFailMessage == 1 then
			MissionFail(false, true, "2_02_FAIL_01")
		elseif gMissionFailMessage == 2 then
			MissionFail(false, true, "2_02_FAIL_02")
		else
			MissionFail(false)
		end
	elseif bMissionPassed then
		CameraFade(500, 0)
		Wait(501)
		CameraReset()
		CameraReturnToPlayer()
		MissionSucceed(false, false, false)
		Wait(500)
		CameraFade(500, 1)
		Wait(101)
		PlayerSetControl(1)
	end
end

function F_TableInit()
	pedStoreOwner = {
		spawn = POINTLIST._2_02_OWNER,
		element = 1,
		model = 84
	}
	pedKlepto = {
		spawn = POINTLIST._2_02_KLEPTO,
		element = 1,
		model = 70
	}
	vehicleKleptoBike = {
		spawn = POINTLIST._2_02_KLEPTOBIKE,
		element = 1,
		model = 282
	}
	vehiclePlayerBike = {
		spawn = POINTLIST._2_02_PLAYERBIKE,
		element = 1,
		model = 273
	}
end

function F_SetupMission()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupMission()")
	WeaponRequestModel(301)
	LoadPedModels({ 84, 70 })
	LoadWeaponModels({ 333 })
	LoadVehicleModels({ 282, 273 })
	LoadActionTree("Act/Conv/2_02.act")
	F_TableInit()
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupMission()")
end

function F_Stage1()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
	F_Stage1_Setup()
	F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
	AreaClearAllVehicles()
	F_DeleteAllBikes()
	F_SetupKlepto()
	F_SetupShopOwner()
	CreateThread("T_MonitorKlepto")
	PlayerFaceHeading(45, 0)
	Wait(10)
	PlayerPutOnBike(vehiclePlayerBike.id)
	CameraSetXYZ(517.10706, -58.569523, 7.816613, 517.7849, -57.87431, 7.577494)
	Wait(30)
	CameraReturnToPlayer()
	CameraReset()
	CameraFade(500, 1)
	Wait(500)
	PedSetFocus(pedKlepto.id, gPlayer)
	PedFleeOnPathOnBike(pedKlepto.id, PATH._2_02_NEWESCAPE, 0)
	SoundPlayScriptedSpeechEvent(pedStoreOwner.id, "M_2_02", 26, "medium")
	TextPrint("2_02_INSTRUC01", 3, 1)
	gObjective01 = MissionObjectiveAdd("2_02_INSTRUC01")
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
	while bLoop do
		Stage1_Objectives()
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
	F_Stage2_Setup()
	F_Stage2_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2()")
end

function F_Stage2_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2_Setup()")
	SoundStopInteractiveStream()
	MissionObjectiveComplete(gObjective02)
	gObjective03 = MissionObjectiveAdd("2_02_INSTRUC04")
	TextPrint("2_02_INSTRUC04", 4, 1)
	BlipRemove(blipComic)
	pedStoreOwner.blip = AddBlipForChar(pedStoreOwner.id, 9, 0, 4, 0)
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
	while bLoop do
		Stage2_Objectives()
		if bMissionFailed then
			break
		end
		if bMissionPassed then
			break
		end
		Wait(0)
	end
end

function Stage1_Objectives()
	if not bLaunchedBikeTutorial and not bBikeTutorialShown and PlayerIsInAnyVehicle() then
		CreateThread("T_ShowBikeCombatTutorial")
		bLaunchedBikeTutorial = true
	end
	if bComicSpawned and PlayerHasItem(504) then
		bComicSpawned = false
		bGoToStage2 = true
	end
	if PedIsInTrigger(pedKlepto.id, TRIGGER._2_02_SCHOOLPARKING) then
		F_KleptoEscaped()
		gMissionFailMessage = 1
		bMissionFailed = true
	end
	if not bKleptoDismounted and not PedIsInAnyVehicle(pedKlepto.id) then
		F_KleptoDismounted()
		bKleptoDismounted = true
	end
end

function Stage2_Objectives()
	if PlayerIsInTrigger(TRIGGER._2_02_RETURNCOMIC) then
		PedSetInvulnerable(pedStoreOwner.id, true)
		PlayerSetInvulnerable(true)
		F_DoFinalNIS()
	end
end

function F_SetupKlepto()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupKlepto()")
	vehicleKleptoBike.id = VehicleCreatePoint(vehicleKleptoBike.model, vehicleKleptoBike.spawn, vehicleKleptoBike.element)
	pedKlepto.id = PedCreatePoint(pedKlepto.model, pedKlepto.spawn, pedKlepto.element)
	pedKlepto.blip = AddBlipForChar(pedKlepto.id, 6, 26, 4, 0)
	PedPutOnBike(pedKlepto.id, vehicleKleptoBike.id)
	PedIgnoreStimuli(pedKlepto.id, true)
	PedIgnoreAttacks(pedKlepto.id, true)
	PedLockTarget(pedKlepto.id, gPlayer, 3)
	PedOverrideStat(pedKlepto.id, 9, 75)
	PedOverrideStat(pedKlepto.id, 30, 50)
	PedOverrideStat(pedKlepto.id, 10, 50)
	PedOverrideStat(pedKlepto.id, 37, 100)
	PedOverrideStat(pedKlepto.id, 24, 30)
	PedOverrideStat(pedKlepto.id, 35, 33)
	PedOverrideStat(pedKlepto.id, 26, 35)
	PedOverrideStat(pedKlepto.id, 28, 1.0E-4)
	PedOverrideStat(pedKlepto.id, 27, 10)
	PedOverrideStat(pedKlepto.id, 29, 20)
	PedSetWeaponNow(pedKlepto.id, 301, 20)
	PedSetHealth(pedKlepto.id, PedGetHealth(pedKlepto.id) * 1.5)
	PedSetMaxHealth(pedKlepto.id, PedGetHealth(pedKlepto.id))
	PedShowHealthBar(pedKlepto.id, true, "2_02_KLEPTONAME")
	F_PedSetDropItem(pedKlepto.id, 504, 100, 1)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupKlepto()")
end

function F_SetupShopOwner()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupShopOwner()")
	pedStoreOwner.id = PedCreatePoint(pedStoreOwner.model, pedStoreOwner.spawn, pedStoreOwner.element)
	vehiclePlayerBike.id = VehicleCreatePoint(vehiclePlayerBike.model, vehiclePlayerBike.spawn, vehiclePlayerBike.element)
	PedSetMissionCritical(pedStoreOwner.id, true, F_MissionCriticalShopKeeper, true)
	PedSetFlag(pedStoreOwner.id, 113, true)
	VehicleSetOwner(vehiclePlayerBike.id, gPlayer)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupShopOwner()")
end

function F_DoFinalNIS()
	CameraSetWidescreen(true)
	SoundDisableSpeech_ActionTree()
	PlayerSetControl(0)
	F_MakePlayerSafeForNIS(true)
	F_PlayerDismountBike()
	PedSetMissionCritical(pedStoreOwner.id, false)
	PedSetInvulnerable(pedStoreOwner.id, false)
	PlayerSetInvulnerable(false)
	PedSetStationary(pedStoreOwner.id, false)
	PedIgnoreStimuli(pedStoreOwner.id, false)
	PedSetFlag(pedStoreOwner.id, 113, false)
	PedSetFlag(pedStoreOwner.id, 128, true)
	PedSetFlag(gPlayer, 128, true)
	PedStop(pedStoreOwner.id)
	PedClearObjectives(pedStoreOwner.id)
	PedSetStationary(pedStoreOwner.id, false)
	PedLockTarget(gPlayer, pedStoreOwner.id, 3)
	PedSetActionNode(gPlayer, "/Global/2_02_Owner/Anims/GIVE/GiveComicOwner", "Act/Conv/2_02.act")
	while PedIsPlaying(gPlayer, "/Global/2_02_Owner/Anims/GIVE/GiveComicOwner", true) do
		Wait(0)
	end
	MinigameSetCompletion("M_PASS", true, 3000)
	SoundPlayMissionEndMusic(true, 8)
	Wait(200)
	PedLockTarget(pedStoreOwner.id, -1, 1)
	Wait(2000)
	PedClearObjectives(pedStoreOwner.id)
	PedMakeAmbient(pedStoreOwner.id)
	PedMoveToPoint(pedStoreOwner.id, 0, POINTLIST._TBUSINES_COMICSHOPDOOR1, 1, nil, 0.1, true)
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	PedSetFlag(pedStoreOwner.id, 128, false)
	PedSetFlag(gPlayer, 128, false)
	PedSetInvulnerable(pedStoreOwner.id, false)
	PlayerSetInvulnerable(false)
	bMissionPassed = true
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
	if bAmbient then
		SoundPlayAmbientSpeechEvent(pedId, strEvent)
		while SoundSpeechPlaying() do
			Wait(0)
		end
	else
		SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
		while SoundSpeechPlaying() do
			Wait(0)
		end
	end
end

function F_KleptoDismounted()
	--print("()xxxxx[:::::::::::::::> [start] F_KleptoDismounted()")
	PedSetEmotionTowardsPed(pedKlepto.id, gPlayer, 0, true)
	PedSetPedToTypeAttitude(pedKlepto.id, 13, 0)
	PedLockTarget(pedKlepto.id, gPlayer, 3)
	PedClearAllWeapons(pedKlepto.id)
	PedAttackPlayer(pedKlepto.id, 3)
	--print("()xxxxx[:::::::::::::::> [finish] F_KleptoDismounted()")
end

function F_KleptoEscaped()
	--print("()xxxxx[:::::::::::::::> [start] F_KleptoEscaped()")
	PedStop(pedKlepto.id)
	PedClearObjectives(pedKlepto.id)
	BlipRemoveFromChar(pedKlepto.id)
	F_PedSetDropItem(pedKlepto.id, 362, 100, 1)
	PedFlee(pedKlepto.id, gPlayer)
	PedMakeAmbient(pedKlepto.id)
	if VehicleIsValid(vehicleKleptoBike.id) then
		VehicleMakeAmbient(vehicleKleptoBike.id)
	end
	if VehicleIsValid(vehiclePlayerBike.id) then
		VehicleMakeAmbient(vehiclePlayerBike.id)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_KleptoEscaped()")
end

function F_CheckKleptoDistance()
	gPlayerX, gPlayerY = PedGetPosXYZ(gPlayer)
	gKleptoX, gKleptoY = PedGetPosXYZ(pedKlepto.id)
	gDistanceBetween = DistanceBetweenCoords2d(gPlayerX, gPlayerY, gKleptoX, gKleptoY)
	if gDistanceBetween >= gFailRange then
		return 2
	elseif gDistanceBetween >= gWarningRange then
		return 1
	end
	return 0
end

function F_CheckKleptoMusicDistance()
	gMusicPlayerX, gMusicPlayerY = PedGetPosXYZ(gPlayer)
	gMusicKleptoX, gMusicKleptoY = PedGetPosXYZ(pedKlepto.id)
	gMusicDistance = DistanceBetweenCoords2d(gMusicPlayerX, gMusicPlayerY, gMusicKleptoX, gMusicKleptoY)
	if gMusicDistance >= gMusicRange then
		return 1
	end
	return 0
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

function F_MissionCriticalShopKeeper()
	if pedStoreOwner.id and PedIsValid(pedStoreOwner.id) then
		PedSetInvulnerable(pedStoreOwner.id, false)
		PedSetFlag(pedStoreOwner.id, 113, false)
		PedSetStationary(pedStoreOwner.id, false)
		PedIgnoreStimuli(pedStoreOwner.id, false)
		PedMakeAmbient(pedStoreOwner.id)
	end
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalShopKeeper()")
	gMissionFailMessage = 2
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalShopKeeper()")
end

function F_DeleteAllBikes()
	local x, y, z = PlayerGetPosXYZ()
	bikes = VehicleFindInAreaXYZ(x, y, z, 100, false)
	--print("[RAUL] - FINDING BIKES ")
	if not bikes then
		return
	end
	--print("[RAUL] - FOUND BIKES ")
	for _, bike in bikes do
		--print("[RAUL] - OTHER BIKE FOUND")
		VehicleDelete(bike)
	end
end

function T_MonitorKlepto() -- ! Modified
	--print("()xxxxx[:::::::::::::::> [start] T_MonitorKlepto()")
	while MissionActive() do
		if not bKleptoIsDead then
			if not bKleptoEscaping then
				if F_CheckKleptoDistance() == 1 then
					TextPrint("2_02_WARN", 4, 1)
					bKleptoEscaping = true
				end
			else
				if F_CheckKleptoDistance() == 2 then
					gMissionFailMessage = 1
					bMissionFailed = true
					break
				end
				if F_CheckKleptoDistance() == 0 then
					bKleptoEscaping = false
				end
			end
			if bCurrentMusicIsMid then
				if F_CheckKleptoMusicDistance() == 0 then
					--print("()xxxxx[:::::::::::::::> [msuic] Playing HIGH stream.")
					SoundPlayInteractiveStreamLocked("MS_BikeActionHigh.rsm", MUSIC_DEFAULT_VOLUME, 500, 500)
					bCurrentMusicIsMid = false
				end
			elseif F_CheckKleptoMusicDistance() == 1 then
				--print("()xxxxx[:::::::::::::::> [msuic] Playing MID stream.")
				SoundPlayInteractiveStreamLocked("MS_BikeActionMid.rsm", MUSIC_DEFAULT_VOLUME, 500, 500)
				bCurrentMusicIsMid = true
			end
			if PedIsDead(pedKlepto.id) then
				--PedHideHealthBar()
				local tempX, tempY, tempZ = PedGetPosXYZ(pedKlepto.id)
				blipComic = BlipAddXYZ(tempX, tempY, tempZ, 0, 4, 0)
				MissionObjectiveComplete(gObjective01)
				gObjective02 = MissionObjectiveAdd("2_02_INSTRUC03")
				TextPrint("2_02_INSTRUC03", 4, 1)
				bComicSpawned = true
				bKleptoIsDead = true
				if pedStoreOwner.id and PedIsValid(pedStoreOwner.id) then
					PedSetMissionCritical(pedStoreOwner.id, false)
					PedDelete(pedStoreOwner.id)
				end
				pedStoreOwner.id = PedCreatePoint(pedStoreOwner.model, pedStoreOwner.spawn, pedStoreOwner.element)
				PedSetMissionCritical(pedStoreOwner.id, true, F_MissionCriticalShopKeeper, true)
				PedSetStationary(pedStoreOwner.id, true)
				PedIgnoreStimuli(pedStoreOwner.id, true)
				PedSetFlag(pedStoreOwner.id, 113, true)
			end
		end
		Wait(0)
	end
	collectgarbage()
	--print("()xxxxx[:::::::::::::::> [finish] T_MonitorKlepto()")
end

function T_ShowBikeCombatTutorial()
	Wait(5000)
	if PlayerGetBikeId() ~= -1 then
		TutorialShowMessage("BIKECOMBAT_TUT01", 6000)
		bBikeTutorialShown = true
	else
		bLaunchedBikeTutorial = false
	end
end
