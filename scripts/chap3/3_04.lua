local bDebugFlag = false
local gDebugLevel = 3
local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bGoToStage3 = false
local bGoToStage4 = false
local bPlayerOnBike = false
local bCornScream2 = false
local bCornCut = false
local bPlayerAgrodBullys = false
local bDeleteCorn = false
local bSaveCorn = false
local bCleanupJCrew = false
local bMonitorCornBullies = true
local bReadyForStage3Cut = false
local bIntroCutWait = false
local bCutEscape = false
local bGreasersResumeChase = false
local bCleanupAlgieBiking = false
local bCleanupAlgieBiking02 = false
local bDeleteExtraGoon01 = false
local bDeleteExtraGoon03 = false
local bLaunchEscapeRoute02 = false
local bLaunchEscapeRoute04 = false
local tableBikerPeds = {}
local tableBikerBikes = {}
local tableBikerBlips = {}
local tableMarkForDelete = {}
local bMonitorBikers = false
local bDeleteSomeBikePeds = false
local tableGreaserModels = {
	27,
	29,
	21,
	28,
	22
}
local tableGreaserWeapons = {
	301,
	312,
	301
}
local gChadsBikeSpeed = 70
local gChadsBikeSpeedNIS = 80
local gChasersHealth = 40
local bJimmyOneDown = false
local bStartLostEmDialogue = false
local bLoadedEscapeBikes = false
local bPlayerKilledBully = false
local gPlayerMaxHealth = 0
local gPlayerBikeHealthMultiplyer = 3
local bBikeCameraCut01 = false
local bBikeCameraCut02 = false
local bBikeCameraCut03 = false
local bBikeCameraCut04 = false
local bBikeCameraCut05 = false
local bBikeCameraReset = false
local bCreateAlgieTrapTrap = false
local bChaseCount = 0
local bCornIsAlly = false
local bSkipFirstCutscene = false
local bSkipSecondCutscene = false
local gLastGreaserSpawned = 1
local pedNumberChad = 1
local pedNumberAlgie = 1
local pedNumberLola = 1
local pedNumberCornelius = 1
local gMissionFailMessage = 0
local bPlayerFacingBackwardsForNIS = 0

function MissionSetup()
	--print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
	if not bDebugFlag then
		PlayCutsceneWithLoad("3-04", true)
	end
	MissionDontFadeIn()
	DATLoad("3_04.DAT", 2)
	DATInit()
	--print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
	--print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
	if not bGoToStage2 then
		if PedIsValid(pedCornelius.id) then
			PedDismissAlly(gPlayer, pedCornelius.id)
			PedMakeAmbient(pedCornelius.id)
			PedIgnoreStimuli(pedCornelius.id, false)
			PedSetStationary(pedCornelius.id, false)
		end
		if PedIsValid(pedGreaser03.id) then
			PedMakeAmbient(pedGreaser03.id)
		end
		if PedIsValid(pedGreaser04.id) then
			PedMakeAmbient(pedGreaser04.id)
		end
	end
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	F_MakePlayerSafeForNIS(false)
	SoundStopInteractiveStream()
	DisablePunishmentSystem(false)
	if bPlayerOnBike then
		CameraAllowChange(true)
		PlayerFixToBackOfVehicle(vehicleBikeChad.id, false)
		CameraClearRotationLimit()
		Wait(3000)
	end
	PedHideHealthBar()
	AreaRevertToDefaultPopulation()
	VehicleRevertToDefaultAmbient()
	DATUnload(2)
	DATInit()
	UnLoadAnimationGroup("Cheer_Cool3")
	UnLoadAnimationGroup("G_Johnny")
	UnLoadAnimationGroup("NPC_Spectator")
	UnLoadAnimationGroup("Cheer_Nerd1")
	UnLoadAnimationGroup("Cheer_Cool1")
	UnLoadAnimationGroup("NPC_Adult")
	UnLoadAnimationGroup("3_04WrongPtTown")
	UnLoadAnimationGroup("G_Johnny")
	UnLoadAnimationGroup("SNERD_I")
	UnLoadAnimationGroup("SNERD_S")
	PedSetUniqueModelStatus(32, pedNumberChad)
	PedSetUniqueModelStatus(4, pedNumberAlgie)
	PedSetUniqueModelStatus(25, pedNumberLola)
	PedSetUniqueModelStatus(9, pedNumberCornelius)
	EnablePOI()
	SoundEmitterEnable("Poor_AutoBodyShop", true)
	SoundEmitterEnable("Poor_TennmentsDay01", true)
	--print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
	--print("()xxxxx[:::::::::::::::> [start] main()")
	F_SetupMission()
	if bDebugFlag then
		if gDebugLevel == 2 then
			F_StartAtStage2()
		elseif gDebugLevel == 3 then
			F_StartAtStage3()
		else
			F_StartAtStage4()
		end
	else
		F_Stage1()
	end
	if bMissionFailed then
		TextPrint("3_04_EMPTY", 1, 1)
		SoundPlayMissionEndMusic(false, 8)
		if gMissionFailMessage == 1 then
			MissionFail(false, true, "3_04_FAIL_01")
		elseif gMissionFailMessage == 2 then
			MissionFail(false, true, "3_04_FAIL_02")
		elseif gMissionFailMessage == 3 then
			MissionFail(false, true, "3_04_FAIL_03")
		elseif gMissionFailMessage == 4 then
			MissionFail(false, true, "3_04_FAIL_04")
		else
			MissionFail(false)
		end
	elseif bMissionPassed then
		CameraSetWidescreen(true)
		PlayerSetControl(0)
		F_MakePlayerSafeForNIS(true)
		SetFactionRespect(4, GetFactionRespect(4) - 5)
		SetFactionRespect(1, GetFactionRespect(1) + 5)
		MinigameSetCompletion("M_PASS", true, 2000)
		MinigameAddCompletionMsg("MRESPECT_NP5", 2)
		MinigameAddCompletionMsg("MRESPECT_GM5", 1)
		SoundPlayMissionEndMusic(true, 8)
		Wait(3000)
		if pedEarnest.id then
			PedDelete(pedEarnest.id)
			pedEarnest.id = nil
		end
		if pedCornelius.id then
			PedDelete(pedCornelius.id)
			pedCornelius.id = nil
		end
		if pedAlgie.id then
			PedDelete(pedAlgie.id)
			pedAlgie.id = nil
		end
		Wait(1000)
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		CameraFade(500, 0)
		Wait(501)
		CameraReset()
		CameraReturnToPlayer()
		MissionSucceed(false, false, false)
		CameraSetWidescreen(false)
		Wait(500)
		CameraFade(500, 1)
		Wait(101)
		PlayerSetControl(1)
	end
	--print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_SetupMission()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupMission()")
	PedSetTypeToTypeAttitude(1, 13, 4)
	F_TableInit()
	LoadAnimationGroup("Cheer_Cool3")
	LoadAnimationGroup("G_Johnny")
	LoadAnimationGroup("NPC_Spectator")
	LoadAnimationGroup("Cheer_Nerd1")
	LoadAnimationGroup("Cheer_Cool1")
	LoadAnimationGroup("NPC_Adult")
	LoadAnimationGroup("3_04WrongPtTown")
	LoadAnimationGroup("G_Johnny")
	LoadAnimationGroup("SNERD_I")
	LoadAnimationGroup("SNERD_S")
	LoadAnimationGroup("NIS_3_04")
	LoadActionTree("Act/Conv/3_04.act")
	pedNumberChad = PedGetUniqueModelStatus(32)
	pedNumberAlgie = PedGetUniqueModelStatus(4)
	pedNumberLola = PedGetUniqueModelStatus(25)
	pedNumberCornelius = PedGetUniqueModelStatus(9)
	PedSetUniqueModelStatus(32, -1)
	PedSetUniqueModelStatus(4, -1)
	PedSetUniqueModelStatus(25, -1)
	PedSetUniqueModelStatus(9, -1)
	LoadPedModels({
		9,
		23,
		130,
		22,
		28,
		29,
		27,
		21,
		4,
		32,
		25
	})
	LoadVehicleModels({
		281,
		273,
		282
	})
	gPlayerMaxHealth = PedGetMaxHealth(gPlayer)
	--print("()xxxxx[:::::::::::::::> [gPlayerMaxHealth] " .. gPlayerMaxHealth)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupMission()")
	SoundEmitterEnable("Poor_AutoBodyShop", false)
	SoundEmitterEnable("Poor_TennmentsDay01", false)
end

function F_TableInit()
	--print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
	pedEarnest = {
		spawn = POINTLIST._3_04_SPAWNEARNESTLIB,
		element = 1,
		model = 10
	}
	pedCornelius = {
		spawn = POINTLIST._3_04_SPAWNCORNELIUSSTG1,
		element = 1,
		model = 9
	}
	pedJohnny = {
		spawn = POINTLIST._3_04_SPAWNJOHNNYSTG1,
		element = 1,
		model = 23
	}
	pedGary = {
		spawn = POINTLIST._3_04_SPAWNGARYSTG1,
		element = 1,
		model = 130
	}
	pedGreaser01 = {
		spawn = POINTLIST._3_04_SPAWNGOON1STG1,
		element = 1,
		model = 22
	}
	pedGreaser02 = {
		spawn = POINTLIST._3_04_SPAWNGOON2STG1,
		element = 1,
		model = 28
	}
	pedGreaser03 = {
		spawn = POINTLIST._3_04_SPAWNGOON3STG1,
		element = 1,
		model = 29
	}
	pedGreaser04 = {
		spawn = POINTLIST._3_04_SPAWNGOON4STG1,
		element = 1,
		model = 27
	}
	pedNorton = {
		spawn = POINTLIST._3_04_STG3CUT_TEMPNORTON,
		element = 1,
		model = 29
	}
	pedAlgie = {
		spawn = POINTLIST._3_04_SPAWNALGIESTG2,
		element = 1,
		model = 4
	}
	pedChad = {
		spawn = POINTLIST._3_04_SPAWNCHADSTG2,
		element = 1,
		model = 32
	}
	pedLola = {
		spawn = POINTLIST._3_04_SPAWNLOLASTG2,
		element = 1,
		model = 25
	}
	vehicleBikeAlgie = {
		spawn = POINTLIST._3_04_BIKEALGIE,
		element = 1,
		model = 281
	}
	vehicleBikeChad = {
		spawn = POINTLIST._3_04_BIKECHAD,
		element = 1,
		model = 273
	}
	vehicleEnemyBike01 = {
		spawn = POINTLIST._3_04_SPAWNGBIKE01,
		element = 1,
		model = 282
	}
	vehicleEnemyBike02 = {
		spawn = POINTLIST._3_04_SPAWNGBIKE02,
		element = 1,
		model = 282
	}
	vehicleEnemyBike03 = {
		spawn = POINTLIST._3_04_HILLBIKE01,
		element = 1,
		model = 282
	}
	vehicleEnemyBike04 = {
		spawn = POINTLIST._3_04_HILLBIKE02,
		element = 1,
		model = 282
	}
	pedExtraGoon01 = {
		spawn = POINTLIST._3_04_STG3EXTRAGOON01,
		element = 1,
		model = 28
	}
	vehicleExtraGoon01 = {
		spawn = POINTLIST._3_04_STG3EXTRAGOON01,
		element = 1,
		model = 282
	}
	pedExtraGoon02 = {
		spawn = POINTLIST._3_04_STG3EXTRAGOON02,
		element = 1,
		model = 22
	}
	vehicleExtraGoon02 = {
		spawn = POINTLIST._3_04_STG3EXTRAGOON02,
		element = 1,
		model = 282
	}
	pedExtraGoon03 = {
		spawn = POINTLIST._3_04_STG3EXTRAGOON03,
		element = 1,
		model = 29
	}
	vehicleExtraGoon03 = {
		spawn = POINTLIST._3_04_STG3EXTRAGOON03,
		element = 1,
		model = 282
	}
	--print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_Stage1()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
	F_Stage1_Setup()
	F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
	AreaTransitionPoint(0, POINTLIST._3_04_SPAWNPLAYER, nil, true)
	CameraReset()
	CameraReturnToPlayer()
	F_LoadBullyScene()
	CameraFade(500, 1)
	Wait(500)
	TextPrint("3_04_MOBJ_01", 4, 1)
	gObjective01 = MissionObjectiveAdd("3_04_MOBJ_01")
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Loop()")
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
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Loop()")
end

function F_Stage2()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2()")
	F_Stage2_Setup()
	F_Stage2_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2()")
end

function F_Stage2_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2_Setup()")
	SoundPlayInteractiveStream("MS_RunningLow02.rsm", MUSIC_DEFAULT_VOLUME)
	SoundSetMidIntensityStream("MS_RunningMid.rsm", MUSIC_DEFAULT_VOLUME)
	SoundSetHighIntensityStream("MS_RunningHigh.rsm", MUSIC_DEFAULT_VOLUME)
	MissionObjectiveComplete(gObjective02)
	TextPrint("3_04_MOBJ_03", 4, 1)
	gObjective03 = MissionObjectiveAdd("3_04_MOBJ_03")
	pedAlgie.id = PedCreatePoint(pedAlgie.model, pedAlgie.spawn, pedAlgie.element)
	pedAlgie.blip = AddBlipForChar(pedAlgie.id, 1, 0, 4)
	pedLola.id = PedCreatePoint(pedLola.model, pedLola.spawn, pedLola.element)
	pedChad.id = PedCreatePoint(pedChad.model, pedChad.spawn, pedChad.element)
	PedSetFlag(pedAlgie.id, 129, true)
	PedFaceObject(pedChad.id, pedLola.id, 2, 0)
	PedSetStationary(pedAlgie.id, true)
	PedSetMinHealth(pedAlgie.id, PedGetHealth(pedAlgie.id))
	PedIgnoreStimuli(pedAlgie.id, true)
	PedIgnoreAttacks(pedAlgie.id, true)
	bReadyForStage3Cut = true
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2_Loop()")
	while bLoop do
		Stage2_Objectives()
		if bMissionFailed then
			break
		end
		if bGoToStage3 then
			F_Stage3()
			break
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Loop()")
end

function F_Stage3()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage3()")
	F_Stage3_Setup()
	F_Stage3_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage3()")
end

function F_Stage3_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage3_Setup()")
	MissionObjectiveComplete(gObjective03)
	SoundDisableSpeech_ActionTree()
	SoundMakeEverythingCloser(true)
	local cameraX, cameraY, cameraZ = GetPointList(POINTLIST._3_04_CAMSTG3INTRO)
	local lookX, lookY, lookZ = GetPointList(POINTLIST._3_04_CAMSTG3INTRO2)
	local look2X, look2Y, look2Z = GetPointList(POINTLIST._3_04_CAMSTG3INTRO3)
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	CameraFade(500, 0)
	Wait(500)
	PlayerSetPunishmentPoints(0)
	VehicleOverrideAmbient(0, 0, 0, 0)
	AreaOverridePopulation(3, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0)
	DisablePOI()
	if PedIsOnVehicle(gPlayer) then
		--print("()xxxxx[:::::::::::::::> PLAYER IS ON A BIKE ATTEMPTING TO REMOVE")
		PlayerDetachFromVehicle()
	end
	if not bDebugFlag then
		F_Stage2Cleanup()
	end
	ModelNotNeeded(4)
	ModelNotNeeded(32)
	ModelNotNeeded(25)
	ModelNotNeeded(9)
	ModelNotNeeded(23)
	ModelNotNeeded(130)
	ModelNotNeeded(22)
	ModelNotNeeded(28)
	ModelNotNeeded(29)
	ModelNotNeeded(21)
	ModelNotNeeded(27)
	UnLoadAnimationGroup("Cheer_Cool3")
	UnLoadAnimationGroup("G_Johnny")
	UnLoadAnimationGroup("NPC_Spectator")
	UnLoadAnimationGroup("Cheer_Nerd1")
	UnLoadAnimationGroup("Cheer_Cool1")
	UnLoadAnimationGroup("NPC_Adult")
	UnLoadAnimationGroup("3_04WrongPtTown")
	UnLoadAnimationGroup("G_Johnny")
	UnLoadAnimationGroup("SNERD_I")
	UnLoadAnimationGroup("SNERD_S")
	UnLoadAnimationGroup("NIS_3_04")
	if not bDebugFlag then
		PlayCutsceneWithLoad("3-04B", true)
	end
	LoadWeaponModels({ 306 })
	LoadVehicleModels({ 282 })
	LoadAnimationGroup("Cheer_Cool3")
	LoadAnimationGroup("G_Johnny")
	LoadAnimationGroup("NPC_Spectator")
	LoadAnimationGroup("Cheer_Nerd1")
	LoadAnimationGroup("Cheer_Cool1")
	LoadAnimationGroup("NPC_Adult")
	LoadAnimationGroup("3_04WrongPtTown")
	LoadAnimationGroup("G_Johnny")
	LoadAnimationGroup("SNERD_I")
	LoadAnimationGroup("SNERD_S")
	LoadAnimationGroup("NIS_3_04")
	LoadPedModels({
		10,
		9,
		22,
		28,
		29,
		27,
		21,
		4,
		32
	})
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	PlayerSetPosPoint(POINTLIST._3_04_SPAWNPLAYERSTG3)
	pedChad.id = PedCreatePoint(pedChad.model, pedChad.spawn, pedChad.element)
	PedSetHealth(pedChad.id, PedGetMaxHealth(pedChad.id) * 2)
	pedAlgie.id = PedCreatePoint(pedAlgie.model, POINTLIST._3_04_SPAWNALGIESTG3, pedAlgie.element)
	pedGreaser01.id = PedCreatePoint(pedGreaser01.model, POINTLIST._3_04_SPAWNGPED01, pedGreaser01.element)
	pedGreaser02.id = PedCreatePoint(pedGreaser02.model, POINTLIST._3_04_SPAWNGPED02, pedGreaser02.element)
	pedNorton.id = PedCreatePoint(pedNorton.model, pedNorton.spawn, pedNorton.element)
	PedSetStationary(pedNorton.id, true)
	VehicleSetPosPoint(vehicleBikeAlgie.id, vehicleBikeAlgie.spawn, vehicleBikeAlgie.element)
	VehicleSetPosPoint(vehicleBikeChad.id, vehicleBikeChad.spawn, vehicleBikeChad.element)
	vehicleEnemyBike01.id = VehicleCreatePoint(vehicleEnemyBike01.model, vehicleEnemyBike01.spawn, vehicleEnemyBike01.element)
	vehicleEnemyBike02.id = VehicleCreatePoint(vehicleEnemyBike02.model, vehicleEnemyBike02.spawn, vehicleEnemyBike02.element)
	Wait(100)
	PedPutOnBike(pedGreaser01.id, vehicleEnemyBike01.id)
	PedPutOnBike(pedGreaser02.id, vehicleEnemyBike02.id)
	local tempBikeID = PlayerGetLastBikeId()
	if tempBikeID ~= -1 then
		VehicleDelete(tempBikeID)
	end
	PedSetFlag(pedAlgie.id, 20, true)
	PedSetFlag(pedChad.id, 20, true)
	PedSetPedToTypeAttitude(pedChad.id, 13, 4)
	PedMakeTargetable(pedChad.id, false)
	PedIgnoreAttacks(pedChad.id, true)
	PedSetInvulnerable(pedChad.id, true)
	PedOverrideStat(pedAlgie.id, 6, 0)
	PedFaceObject(pedAlgie.id, gPlayer, 3, 0)
	PedFaceObject(pedChad.id, gPlayer, 3, 0)
	PedFaceObject(gPlayer, pedAlgie.id, 2, 0)
	CameraReset()
	CameraSetFOV(30)
	CameraSetXYZ(508.40573, -435.79477, 6.044368, 507.49744, -435.4033, 5.897112)
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	CameraFade(500, 1)
	Wait(500)
	CreateThread("T_CutsceneBikeEscape")
	while not bSkipSecondCutscene do
		if IsButtonPressed(7, 0) then
			bSkipSecondCutscene = true
		end
		Wait(0)
	end
	CameraFade(500, 0)
	Wait(500)
	F_SetupBikeChase()
	CameraReturnToPlayer(true)
	Wait(100)
	PlayerSetTakeDamageWhenAttachedToVehicle(true)
	PlayerFixToBackOfVehicle(vehicleBikeChad.id, true)
	CameraSetRotationLimitRel(45, 55, 0, -1, 0, vehicleBikeChad.id, 1)
	bPlayerOnBike = true
	PedSetWeaponNow(gPlayer, 306, 1)
	CameraSetWidescreen(false)
	PedOverrideStat(pedChad.id, 24, 40)
	PedFollowPath(pedChad.id, PATH._3_04_BIKEESCAPE, 0, 4, F_routeBikeEscape)
	PedDisableMoveOutOfWay(pedChad.id, true)
	Wait(2500)
	PedOverrideStat(pedAlgie.id, 24, 80)
	PedFollowPath(pedAlgie.id, PATH._3_04_ALGIELEAVELOLAS, 0, 4, F_routeAlgieLeaveLolas)
	PedSetPedToTypeAttitude(pedGreaser01.id, 13, 0)
	PedSetPedToTypeAttitude(pedGreaser02.id, 13, 0)
	pedGreaser01.blip = AddBlipForChar(pedGreaser01.id, 4, 26, 1)
	pedGreaser02.blip = AddBlipForChar(pedGreaser02.id, 4, 26, 1)
	pedAlgie.blip = AddBlipForChar(pedAlgie.id, 1, 2, 1)
	bMonitorAlgie = true
	if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
		PedSetHealth(gPlayer, PedGetMaxHealth(gPlayer))
	end
	local tempHealth = PedGetHealth(gPlayer)
	--print("()xxxxx[:::::::::::::::> [tempHealth] " .. tempHealth)
	CameraSetRotationLimitRel(45, 90, 0, -1, 0, vehicleBikeChad.id, 1)
	CameraAllowChange(false)
	F_MakePlayerSafeForNIS(false)
	PlayerSetControl(1)
	CameraFade(500, 1)
	Wait(500)
	CreateThread("T_SpeechJimmyBike")
	F_SetupChaserStats(pedGreaser01.id)
	F_SetupChaserStats(pedGreaser02.id)
	PedSetWeapon(pedGreaser01.id, 312, 100)
	PedSetWeapon(pedGreaser02.id, 301, 100)
	PedAttack(pedGreaser01.id, pedChad.id, 3)
	PedAttack(pedGreaser02.id, pedChad.id, 3)
	PedSetHealth(pedGreaser01.id, gChasersHealth)
	PedSetMaxHealth(pedGreaser01.id, gChasersHealth)
	PedSetHealth(pedGreaser02.id, gChasersHealth)
	PedSetMaxHealth(pedGreaser02.id, gChasersHealth)
	table.insert(tableBikerPeds, pedGreaser01.id)
	table.insert(tableBikerBikes, vehicleEnemyBike01.id)
	table.insert(tableBikerBlips, pedGreaser01.blip)
	table.insert(tableBikerPeds, pedGreaser02.id)
	table.insert(tableBikerBikes, vehicleEnemyBike02.id)
	table.insert(tableBikerBlips, pedGreaser02.blip)
	bMonitorBikers = true
	threadMonitorBikers = CreateThread("T_MonitorBikers")
	SoundEnableSpeech_ActionTree()
	SoundPlayStream("MS_BikeFastMid.rsm", MUSIC_DEFAULT_VOLUME)
	TextPrint("3_04_MOBJ_04", 4, 1)
	gObjective04 = MissionObjectiveAdd("3_04_MOBJ_04")
	MissionObjectiveReminderTime(-1)
	DisablePunishmentSystem(true)
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage3_Setup()")
	UnLoadAnimationGroup("NIS_3_04")
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
end

function F_Stage3_Loop()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage3_Loop()")
	while bLoop do
		Stage3_Objectives()
		if bMissionFailed then
			break
		end
		if bGoToStage4 then
			F_Stage4()
			break
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Loop()")
end

function F_Stage4()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage4()")
	F_Stage4_Setup()
	F_Stage4_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage4()")
end

function F_Stage4_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage4_Setup()")
	SoundStopInteractiveStream()
	VehicleRevertToDefaultAmbient()
	AreaRevertToDefaultPopulation()
	CreateThread("T_TextChadLeave")
	pedEarnest.id = PedCreatePoint(pedEarnest.model, POINTLIST._3_04_STG4_SPAWNEARNEST, 1)
	pedCornelius.id = PedCreatePoint(pedCornelius.model, POINTLIST._3_04_STG4_SPAWNCORNELIUS, 1)
	PedSetFlag(pedEarnest.id, 113, true)
	PedSetFlag(pedCornelius.id, 113, true)
	PedIgnoreStimuli(pedEarnest.id, true)
	PedIgnoreStimuli(pedCornelius.id, true)
	PedSetMissionCritical(pedEarnest.id, true, F_MissionCriticalEarnest, false)
	PedSetMissionCritical(pedCornelius.id, true, F_MissionCriticalCornelius, false)
	PedSetFlag(pedEarnest.id, 117, false)
	PedSetFlag(pedCornelius.id, 117, false)
	PedSetStationary(pedEarnest.id, true)
	PedSetStationary(pedCornelius.id, true)
	if bPlayerOnBike then
		CameraAllowChange(true)
		PlayerFixToBackOfVehicle(vehicleBikeChad.id, false)
		Wait(150)
		PedSetActionNode(gPlayer, "/Global/Player/JumpActions/Jump/Falling/Fall/Falling/Fall_No_Damage", "act/player.act")
		CameraClearRotationLimit()
		local px, py, pz = PlayerGetPosXYZ()
		CameraReturnToPlayer(false, false, px + 2, py + 2, pz + 1.5)
		bPlayerOnBike = false
	end
	pedAlgie.id = PedCreatePoint(pedAlgie.model, POINTLIST._3_04_STG4_SPAWNALGIE, 1)
	PedSetFlag(pedAlgie.id, 117, false)
	vehicleBikeAlgie.id = VehicleCreatePoint(vehicleBikeAlgie.model, POINTLIST._3_04_STG4_SPAWNALGIEBIKE, 1)
	PedRecruitAlly(gPlayer, pedAlgie.id)
	PedSetMissionCritical(pedAlgie.id, true, F_MissionCriticalAlgie, false)
	PedWander(pedChad.id, 1)
	PedShowHealthBar(pedAlgie.id, true, "3_04_HEALTH_ALGIE", false)
	Wait(3000)
	blipMainSchool = BlipAddPoint(POINTLIST._3_04_STG4_OBJECTIVE, 0, 1)
	MissionObjectiveComplete(gObjective04)
	TextPrint("3_04_MOBJ_05", 4, 1)
	gObjective05 = MissionObjectiveAdd("3_04_MOBJ_05")
	DisablePunishmentSystem(false)
	EnablePOI()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage4_Setup()")
end

function F_Stage4_Loop()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage4_Loop()")
	while bLoop do
		Stage4_Objectives()
		if bMissionFailed then
			break
		end
		if bMissionPassed then
			break
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage4_Loop()")
end

function Stage1_Objectives()
	if not bCornScream2 and PlayerIsInTrigger(TRIGGER._3_04_CORNSCREAM2) and not bCornCut then
		CreateThread("T_CornScream")
		bCornScream2 = true
	end
	if bPlayerAgrodBullys and not bCornCut then
		F_CutCornelius01()
		TextPrint("3_04_MOBJ_02", 3, 1)
		bCornCut = true
		bSaveCorn = true
	end
	if not bCornCut and PlayerIsInTrigger(TRIGGER._3_04_CORNELIUSCUT) then
		F_CutCornelius01()
		TextPrint("3_04_MOBJ_02", 3, 1)
		bSaveCorn = true
		bCornCut = true
	end
	if bCornIsAlly then
		if not PlayerIsInTrigger(TRIGGER._3_04_CORNELIUSCUT) then
			F_DismissCorn()
		end
	elseif PlayerIsInTrigger(TRIGGER._3_04_CORNELIUSCUT) then
		F_RecruitCorn()
	end
	if bSaveCorn then
		if PedIsDead(pedCornelius.id) then
			if F_PedExists(pedGreaser03.id) then
				PedMakeAmbient(pedGreaser03.id)
			end
			if F_PedExists(pedGreaser04.id) then
				PedMakeAmbient(pedGreaser04.id)
			end
			gMissionFailMessage = 1
			bMissionFailed = true
		elseif PedIsDead(pedGreaser03.id) and PedIsDead(pedGreaser04.id) then
			F_CutCornelius02()
		end
	end
	if bCleanupJCrew then
		F_CleanupJCrew()
		bCleanupJCrew = false
	end
end

function Stage2_Objectives()
	if not bLoadedEscapeBikes and PlayerIsInTrigger(TRIGGER._3_04_LOADBIKES) then
		vehicleBikeAlgie.id = VehicleCreatePoint(vehicleBikeAlgie.model, vehicleBikeAlgie.spawn, vehicleBikeAlgie.element)
		vehicleBikeChad.id = VehicleCreatePoint(vehicleBikeChad.model, vehicleBikeChad.spawn, vehicleBikeChad.element)
		bLoadedEscapeBikes = true
	end
	if bReadyForStage3Cut and (PlayerIsInTrigger(TRIGGER._3_04_ALGIEFLEE) or F_AlgieIsHit()) then
		CameraReturnToPlayer()
		CameraReset()
		PlayerSetControl(0)
		CameraSetWidescreen(true)
		BlipRemove(pedAlgie.blip)
		F_PlayerDismountBike()
		F_MakePlayerSafeForNIS(true)
		PedFollowPath(gPlayer, PATH._3_04_CHASEALGIE, 0, 1)
		SoundPlayScriptedSpeechEventWrapper(gPlayer, "M_3_04", 15)
		PedFaceObject(pedAlgie.id, gPlayer, 3, 1)
		F_WaitForSpeech(gPlayer)
		CameraSetXYZ(493.0894, -429.39145, 3.763034, 492.2085, -428.9226, 3.827792)
		PedFaceHeading(pedAlgie.id, 270, 0)
		CameraSetXYZ(493.0894, -429.39145, 3.763034, 492.2085, -428.9226, 3.827792)
		PedFaceHeading(pedAlgie.id, 270, 0)
		Wait(250)
		PedSetActionNode(pedAlgie.id, "/Global/3_04/3_04_Anim/AlgieOhFace/OhFace", "Act/Conv/3_04.act")
		Wait(750)
		CameraSetXYZ(486.25983, -423.79657, 5.521533, 487.11237, -424.3081, 5.415774)
		PedSetActionNode(pedAlgie.id, "/Global/3_04/3_04_Anim/Empty", "Act/Conv/3_04.act")
		PedSetStationary(pedAlgie.id, false)
		PedMoveToPoint(pedAlgie.id, 1, pedLola.spawn)
		Wait(500)
		PedMoveToPoint(gPlayer, 1, pedLola.spawn)
		Wait(1500)
		F_WaitForSpeech(gPlayer)
		bReadyForStage3Cut = false
		bGoToStage3 = true
	end
end

function Stage3_Objectives()
	F_HandleFancyCamera()
	if bCleanupAlgieBiking then
		F_CleanupAlgieBiking()
		bCleanupAlgieBiking = false
	end
	if bCleanupAlgieBiking02 then
		F_CleanupAlgieBiking02()
		bCleanupAlgieBiking02 = false
	end
	if bLaunchEscapeRoute02 then
		PedFollowPath(pedChad.id, PATH._3_04_BIKEESCAPE02, 0, 4, F_routeBikeEscape02)
		bLaunchEscapeRoute02 = false
	end
	if bCreateAlgieTrapTrap then
		F_CreateAlgieTrapTrap()
		bCreateAlgieTrapTrap = false
	end
	if bLaunchEscapeRoute04 then
		PedOverrideStat(pedChad.id, 24, gChadsBikeSpeed)
		PedFollowPath(pedChad.id, PATH._3_04_BIKEESCAPE04, 0, 4, F_routeBikeEscape04)
		bLaunchEscapeRoute04 = false
	end
	if bCutEscape then
		F_CutEscape()
		bCutEscape = false
	end
	if bStartLostEmDialogue then
		CreateThread("T_StartLostEmDialogue")
		bStartLostEmDialogue = false
	end
end

function Stage4_Objectives()
	if PedIsHit(pedEarnest.id, 2, 100) and PedGetWhoHitMeLast(pedEarnest.id) == gPlayer then
		if F_PedExists(pedEarnest.id) then
			PedSetStationary(pedEarnest.id, false)
			PedMoveToPoint(pedEarnest.id, 0, POINTLIST._3_04_SPAWNPLAYER)
			PedMakeAmbient(pedEarnest.id)
		end
		if F_PedExists(pedCornelius.id) then
			PedSetStationary(pedCornelius.id, false)
			PedMoveToPoint(pedCornelius.id, 0, POINTLIST._3_04_SPAWNPLAYER)
			PedMakeAmbient(pedCornelius.id)
		end
		if F_PedExists(pedAlgie.id) then
			PedDismissAlly(gPlayer, pedAlgie.id)
			PedMoveToPoint(pedAlgie.id, 0, POINTLIST._3_04_SPAWNPLAYER)
			PedMakeAmbient(pedAlgie.id)
		end
		gMissionFailMessage = 4
		bMissionFailed = true
	end
	if PedIsHit(pedCornelius.id, 2, 100) and PedGetWhoHitMeLast(pedCornelius.id) == gPlayer then
		if F_PedExists(pedEarnest.id) then
			PedSetStationary(pedEarnest.id, false)
			PedMoveToPoint(pedEarnest.id, 0, POINTLIST._3_04_SPAWNPLAYER)
			PedMakeAmbient(pedEarnest.id)
		end
		if F_PedExists(pedCornelius.id) then
			PedSetStationary(pedCornelius.id, false)
			PedMoveToPoint(pedCornelius.id, 0, POINTLIST._3_04_SPAWNPLAYER)
			PedMakeAmbient(pedCornelius.id)
		end
		if F_PedExists(pedAlgie.id) then
			PedDismissAlly(gPlayer, pedAlgie.id)
			PedMoveToPoint(pedAlgie.id, 0, POINTLIST._3_04_SPAWNPLAYER)
			PedMakeAmbient(pedAlgie.id)
		end
		gMissionFailMessage = 4
		bMissionFailed = true
	end
	if PlayerIsInTrigger(TRIGGER._3_04_STG4_RETURN) then
		PlayerSetInvulnerable(true)
		PedSetInvulnerable(pedEarnest.id, true)
		PedSetInvulnerable(pedCornelius.id, true)
		SoundFadeWithCamera(false)
		MusicFadeWithCamera(false)
		PlayerSetControl(0)
		CameraFade(500, 0)
		CameraSetWidescreen(true)
		Wait(500)
		SoundMakeEverythingCloser(false)
		F_PlayerDismountBike()
		PedSetFlag(pedEarnest.id, 113, false)
		PedSetFlag(pedCornelius.id, 113, false)
		PedIgnoreStimuli(pedEarnest.id, false)
		PedIgnoreStimuli(pedCornelius.id, false)
		PedSetMissionCritical(pedAlgie.id, false)
		F_MakePlayerSafeForNIS(true)
		PedDismissAlly(gPlayer, pedAlgie.id)
		PedSetPosPoint(gPlayer, POINTLIST._3_04_OUTRO_JIMMY)
		PedSetPosPoint(pedAlgie.id, POINTLIST._3_04_OUTRO_ALGIE)
		PedSetInvulnerable(pedEarnest.id, false)
		PedSetInvulnerable(pedCornelius.id, false)
		Wait(10)
		PedLockTarget(pedEarnest.id, gPlayer)
		PedLockTarget(pedCornelius.id, gPlayer)
		PedLockTarget(pedAlgie.id, gPlayer)
		PedLockTarget(gPlayer, pedAlgie.id)
		CameraSetFOV(30)
		CameraSetXYZ(286.70712, -74.012, 7.28272, 285.7094, -73.94914, 7.259933)
		Wait(500)
		SoundDisableSpeech_ActionTree()
		CameraSetFOV(30)
		CameraFade(1000, 1)
		Wait(500)
		PedSetActionNode(pedCornelius.id, "/Global/3_04/3_04_End/Nerds/Cornelius01", "Act/Conv/3_04.act")
		SoundPlayScriptedSpeechEvent(pedCornelius.id, "M_3_04", 37, "medium")
		F_WaitForSpeech(pedCornelius.id)
		PedSetActionNode(pedEarnest.id, "/Global/3_04/3_04_End/Nerds/Earnest01", "Act/Conv/3_04.act")
		SoundPlayScriptedSpeechEvent(pedEarnest.id, "M_3_04", 38, "medium")
		F_WaitForSpeech(pedEarnest.id)	
		PedSetActionNode(pedAlgie.id, "/Global/3_04/3_04_End/Nerds/Algie01", "Act/Conv/3_04.act")
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_3_04", 39, "medium")
		F_WaitForSpeech(pedAlgie.id)
		CameraSetXYZ(280.07404, -75.32707, 7.504412, 280.9235, -74.80684, 7.418878)
		PedSetActionNode(gPlayer, "/Global/3_04/3_04_End/Jimmy/Jimmy01", "Act/Conv/3_04.act")
		SoundPlayScriptedSpeechEvent(gPlayer, "M_3_04", 40, "medium")
		F_WaitForSpeech(gPlayer)
		CameraSetWidescreen(true)
		PedSetStationary(pedEarnest.id, false)
		PedSetStationary(pedCornelius.id, false)
		PedMoveToPoint(pedEarnest.id, 0, POINTLIST._3_04_SPAWNPLAYER)
		PedMoveToPoint(pedCornelius.id, 0, POINTLIST._3_04_SPAWNPLAYER)
		PedMoveToPoint(pedAlgie.id, 0, POINTLIST._3_04_SPAWNPLAYER)
		bMissionPassed = true
		UnLoadAnimationGroup("NIS_3_04")
		SoundEnableSpeech_ActionTree()
		SoundFadeWithCamera(true)
		MusicFadeWithCamera(true)
	end
end

function F_StartAtStage2()
	--print("()xxxxx[:::::::::::::::> [start] F_StartAtStage2()")
	gObjective01 = MissionObjectiveAdd("3_04_MOBJ_01")
	MissionObjectiveComplete(gObjective01)
	gObjective02 = MissionObjectiveAdd("3_04_MOBJ_02")
	AreaTransitionPoint(0, POINTLIST._3_04_DEBUGSTAGE2, nil, true)
	LoadActionTree("Act/Conv/3_04.act")
	CameraFade(500, 1)
	Wait(500)
	F_Stage2()
	--print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage2()")
end

function F_StartAtStage3()
	--print("()xxxxx[:::::::::::::::> [start] F_StartAtStage3()")
	AreaTransitionPoint(0, POINTLIST._3_04_SPAWNPLAYERSTG3)
	vehicleBikeAlgie.id = VehicleCreatePoint(vehicleBikeAlgie.model, vehicleBikeAlgie.spawn, vehicleBikeAlgie.element)
	vehicleBikeChad.id = VehicleCreatePoint(vehicleBikeChad.model, vehicleBikeChad.spawn, vehicleBikeChad.element)
	gObjective01 = MissionObjectiveAdd("3_04_MOBJ_01")
	MissionObjectiveComplete(gObjective01)
	gObjective02 = MissionObjectiveAdd("3_04_MOBJ_02")
	MissionObjectiveComplete(gObjective02)
	gObjective03 = MissionObjectiveAdd("3_04_MOBJ_03")
	F_Stage3()
	--print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage3()")
end

function F_StartAtStage4()
	--print("()xxxxx[:::::::::::::::> [start] F_StartAtStage4()")
	AreaTransitionPoint(0, POINTLIST._3_04_STG4_SPAWNPLAYER)
	pedChad.id = PedCreatePoint(pedChad.model, POINTLIST._3_04_STG4_SPAWNCHAD, 1)
	gObjective01 = MissionObjectiveAdd("3_04_MOBJ_01")
	MissionObjectiveComplete(gObjective01)
	gObjective02 = MissionObjectiveAdd("3_04_MOBJ_02")
	MissionObjectiveComplete(gObjective02)
	gObjective03 = MissionObjectiveAdd("3_04_MOBJ_03")
	MissionObjectiveComplete(gObjective03)
	gObjective04 = MissionObjectiveAdd("3_04_MOBJ_04")
	MissionObjectiveComplete(gObjective04)
	gObjective05 = MissionObjectiveAdd("3_04_MOBJ_05")
	CameraFade(500, 1)
	Wait(500)
	F_Stage4()
	--print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage4()")
end

function F_CutCornelius01()
	--print("()xxxxx[:::::::::::::::> [start] F_CutCornelius01()")
	SoundDisableSpeech_ActionTree()
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(true)
	PlayerSetControl(0)
	CameraFade(500, 0)
	Wait(500)
	LoadAnimationGroup("NIS_3_04")
	CameraSetFOV(40)
	CameraSetXYZ(239.43936, -118.954414, 7.672601, 239.63142, -119.92838, 7.5527)
	F_PrepCornCut()
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	local tempX, tempY, tempZ = GetPointList(POINTLIST._3_04_CORNCUTJIMMY)
	PlayerSetPosSimple(tempX, tempY, tempZ)
	PedFaceObject(gPlayer, pedJohnny.id, 2, 0)
	PedFaceObject(pedGary.id, pedCornelius.id, 2, 1)
	SoundEnableInteractiveMusic(false)
	CameraFade(500, 1)
	Wait(500)
	SoundStopInteractiveStream(0)
	SoundSetAudioFocusCamera()
	SoundPlayStream("MS_Confrontation_NIS.rsm", 0.4, 1000, 1000)
	CreateThread("T_CutsceneCornelius")
	while not bSkipFirstCutscene do
		if IsButtonPressed(7, 0) then
			bSkipFirstCutscene = true
		end
		Wait(0)
	end
	PlayerSetControl(1)
	CameraFade(500, 0)
	Wait(500)
	SoundEnableInteractiveMusic(true)
	CameraReturnToPlayer()
	CameraReset()
	PedSetStationary(pedCornelius.id, false)
	SoundPlayScriptedSpeechEvent(pedCornelius.id, "M_3_04", 11, "medium")
	PedSetActionNode(pedCornelius.id, "/Global/3_04/3_04_Anim/AlgieCower/CowerStart", "Act/Conv/3_04.act")
	PedRecruitAlly(gPlayer, pedCornelius.id)
	bCornIsAlly = true
	PedSetMissionCritical(pedCornelius.id, true, F_MissionCriticalCornelius, false)
	PedSetActionNode(pedGreaser03.id, "/Global/3_04/3_04_Anim/Empty", "Act/Conv/3_04.act")
	PedAttack(pedGreaser03.id, pedCornelius.id, 1)
	pedGreaser03.blip = AddBlipForChar(pedGreaser03.id, 11, 26, 1)
	PedSetActionNode(pedGreaser04.id, "/Global/3_04/3_04_Anim/Empty", "Act/Conv/3_04.act")
	PedAttack(pedGreaser04.id, pedCornelius.id, 1)
	pedGreaser04.blip = AddBlipForChar(pedGreaser04.id, 11, 26, 1)
	PedSetPedToTypeAttitude(pedCornelius.id, 4, 0)
	F_CleanupJCrew()
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
	CameraFade(500, 1)
	Wait(500)
	BlipRemove(pedCornelius.blip)
	bMonitorCornBullies = false
	MissionObjectiveComplete(gObjective01)
	TextPrint("3_04_MOBJ_02", 4, 1)
	gObjective02 = MissionObjectiveAdd("3_04_MOBJ_02")
	SoundEnableSpeech_ActionTree()
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	SoundEnableInteractiveMusic(true)
	SoundPlayInteractiveStream("MS_RunningLow02.rsm", 0.6)
	--print("()xxxxx[:::::::::::::::> [finish] F_CutCornelius01()")
end

function F_CutCornelius02()
	--print("()xxxxx[:::::::::::::::> [start] F_CutCornelius02()")
	SoundDisableSpeech_ActionTree()
	PedFaceObject(pedCornelius.id, gPlayer, 3, 1)
	Wait(10)
	PedHideHealthBar()
	PedRecruitAlly(gPlayer, pedCornelius.id)
	PedSetActionNode(pedCornelius.id, "/Global/3_04/3_04_Anim/Empty", "Act/Conv/3_04.act")
	SoundStopCurrentSpeechEvent(pedCornelius.id)
	SoundPlayScriptedSpeechEvent(pedCornelius.id, "M_3_04", 12, "medium", false, true)
	F_WaitForSpeech(pedCornelius.id)
	if pedCornelius.blip then
		BlipRemove(pedCornelius.blip)
	end
	PedSetMissionCritical(pedCornelius.id, false)
	PedDismissAlly(gPlayer, pedCornelius.id)
	PedFollowPath(pedCornelius.id, PATH._3_04_CORNLEAVE, 0, 1, F_routeCornLeave)
	bGoToStage2 = true
	SoundEnableSpeech_ActionTree()
	--print("()xxxxx[:::::::::::::::> [finish] F_CutCornelius02()")
	UnLoadAnimationGroup("NIS_3_04")
end

function F_CutEscape()
	SoundDisableSpeech_ActionTree()
	pedGreaser01.id = PedCreatePoint(pedGreaser01.model, POINTLIST._3_04_HILLPED01, 1)
	pedGreaser04.id = PedCreatePoint(pedGreaser04.model, POINTLIST._3_04_HILLPED02, 1)
	vehicleEnemyBike03.id = VehicleCreatePoint(vehicleEnemyBike03.model, vehicleEnemyBike03.spawn, vehicleEnemyBike03.element)
	vehicleEnemyBike04.id = VehicleCreatePoint(vehicleEnemyBike04.model, vehicleEnemyBike04.spawn, vehicleEnemyBike04.element)
	PedPutOnBike(pedGreaser01.id, vehicleEnemyBike03.id)
	PedPutOnBike(pedGreaser04.id, vehicleEnemyBike04.id)
	PedFollowPath(pedGreaser01.id, PATH._3_04_HILL01, 0, 1)
	PedFollowPath(pedGreaser04.id, PATH._3_04_HILL02, 0, 1)
	CameraSetFOV(80)
	CameraSetXYZ(430.55447, -260.60406, 3.296017, 430.58533, -261.58606, 3.482)
	SoundPlayScriptedSpeechEvent(pedGreaser01.id, "M_3_04", 30, "large", true)
	PedSetPedToTypeAttitude(pedGreaser01.id, 13, 0)
	PedSetPedToTypeAttitude(pedGreaser04.id, 13, 0)
	pedGreaser01.blip = AddBlipForChar(pedGreaser01.id, 4, 26, 1)
	pedGreaser04.blip = AddBlipForChar(pedGreaser04.id, 4, 26, 1)
	SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_3_04", 33, "large", true)
	F_WaitForSpeech(pedAlgie.id)
	CameraSetFOV(40)
	CameraSetXYZ(431.07797, -217.62842, 4.784076, 430.89832, -218.61191, 4.765756)
	F_MakeSafeForNISCustom(false)
	PedSetFlag(pedChad.id, 108, false)
	PedSetWeapon(pedGreaser01.id, 312, 100)
	PedSetWeapon(pedGreaser04.id, 301, 100)
	PedAttack(pedGreaser01.id, pedChad.id, 3)
	PedAttack(pedGreaser04.id, pedChad.id, 3)
	PedSetHealth(pedGreaser01.id, gChasersHealth)
	PedSetHealth(pedGreaser04.id, gChasersHealth)
	F_SetupChaserStats(pedGreaser01.id)
	F_SetupChaserStats(pedGreaser04.id)
	table.insert(tableBikerPeds, pedGreaser01.id)
	table.insert(tableBikerBikes, vehicleEnemyBike03.id)
	table.insert(tableBikerBlips, pedGreaser01.blip)
	table.insert(tableBikerPeds, pedGreaser04.id)
	table.insert(tableBikerBikes, vehicleEnemyBike04.id)
	table.insert(tableBikerBlips, pedGreaser04.blip)
	SoundPlayScriptedSpeechEvent(gPlayer, "M_3_04", 31, "large", true)
	SoundPlayStream("MS_BikeFastHigh.rsm", MUSIC_DEFAULT_VOLUME)
	PedSetWeaponNow(gPlayer, 306, 1)
	PedOverrideStat(pedAlgie.id, 24, 80)
	PedFollowPath(pedAlgie.id, PATH._3_04_ALGIETRAPTRAP, 0, 4, F_routeAlgieTrapTrap)
	PedOverrideStat(pedChad.id, 24, 40)
	PedFollowPath(pedChad.id, PATH._3_04_BIKEESCAPE03, 0, 4, F_routeBikeEscape03)
	SoundEnableSpeech_ActionTree()
	gLastGreaserSpawned = 2
end

function F_LoadBullyScene()
	--print("()xxxxx[:::::::::::::::> [start] F_LoadBullyScene()")
	pedCornelius.id = PedCreatePoint(pedCornelius.model, pedCornelius.spawn, pedCornelius.element)
	pedCornelius.blip = AddBlipForChar(pedCornelius.id, 1, 0, 4)
	PedClearAllWeapons(pedCornelius.id)
	PedSetHealth(pedCornelius.id, PedGetHealth(pedCornelius.id) * 2)
	PedSetStationary(pedCornelius.id, true)
	pedJohnny.id = PedCreatePoint(pedJohnny.model, pedJohnny.spawn, pedJohnny.element)
	PedSetInfiniteSprint(pedJohnny.id, true)
	PedSetGrappleTarget(pedJohnny.id, pedCornelius.id)
	PedSetActionNode(pedJohnny.id, "/Global/3_04/3_04_Anim/JohnnyShove/GIVE", "Act/Conv/3_04.act")
	PedSetHealth(pedJohnny.id, PedGetHealth(pedJohnny.id) * 2)
	PedSetPedToTypeAttitude(pedJohnny.id, 1, 4)
	PedSetPedToTypeAttitude(pedCornelius.id, 4, 4)
	PedFaceObject(pedCornelius.id, pedJohnny.id, 2, 1)
	pedGary.id = PedCreatePoint(pedGary.model, pedGary.spawn, pedGary.element)
	PedFaceObject(pedGary.id, pedCornelius.id, 2, 0)
	PedSetInfiniteSprint(pedGary.id, true)
	PedSetHealth(pedGary.id, PedGetHealth(pedGary.id) * 2)
	pedGreaser01.id = PedCreatePoint(pedGreaser01.model, pedGreaser01.spawn, pedGreaser01.element)
	PedFaceObject(pedGreaser01.id, pedCornelius.id, 2, 0)
	PedSetInfiniteSprint(pedGreaser01.id, true)
	PedSetActionNode(pedGreaser01.id, "//Global/3_04/3_04_Anim/Cheer_Cool3/Cheer_Cool_11", "Act/Conv/3_04.act")
	PedSetHealth(pedGreaser01.id, PedGetHealth(pedGreaser01.id) * 2)
	pedGreaser02.id = PedCreatePoint(pedGreaser02.model, pedGreaser02.spawn, pedGreaser02.element)
	PedFaceObject(pedGreaser02.id, pedCornelius.id, 2, 0)
	PedSetInfiniteSprint(pedGreaser02.id, true)
	PedSetActionNode(pedGreaser02.id, "/Global/3_04/3_04_Anim/Cheer_Cool3/Cheer_Cool_12", "Act/Conv/3_04.act")
	PedSetHealth(pedGreaser02.id, PedGetHealth(pedGreaser02.id) * 2)
	pedGreaser03.id = PedCreatePoint(pedGreaser03.model, pedGreaser03.spawn, pedGreaser03.element)
	PedFaceObject(pedGreaser03.id, pedCornelius.id, 2, 0)
	PedSetActionNode(pedGreaser03.id, "/Global/3_04/3_04_Anim/Cheer_Cool3/Cheer_Cool_13", "Act/Conv/3_04.act")
	PedSetHealth(pedGreaser03.id, PedGetHealth(pedGreaser03.id) * 2)
	pedGreaser04.id = PedCreatePoint(pedGreaser04.model, pedGreaser04.spawn, pedGreaser04.element)
	PedFaceObject(pedGreaser04.id, pedCornelius.id, 2, 0)
	PedSetActionNode(pedGreaser04.id, "/Global/3_04/3_04_Anim/Cheer_Cool3/Cheer_Cool_14", "Act/Conv/3_04.act")
	PedSetHealth(pedGreaser04.id, PedGetHealth(pedGreaser04.id) * 2)
	CreateThread("T_MonitorCornBullies")
	--print("()xxxxx[:::::::::::::::> [finish] F_LoadBullyScene()")
end

function F_Stage2Cleanup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2Cleanup()")
	bMonitorAlgie = false
	PedDelete(pedAlgie.id)
	PedDelete(pedChad.id)
	PedDelete(pedLola.id)
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2Cleanup()")
end

function F_CleanupJCrew()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupJCrew()")
	PedDelete(pedJohnny.id)
	PedDelete(pedGary.id)
	PedDelete(pedGreaser01.id)
	PedDelete(pedGreaser02.id)
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupJCrew()")
end

function F_CleanupBikeChase01()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupBikeChase01()")
	if not PedIsDead(pedGreaser01.id) then
		PedDelete(pedGreaser01.id)
	end
	if not PedIsDead(pedGreaser02.id) then
		PedDelete(pedGreaser02.id)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupBikeChase01()")
end

function F_GreasersWipeOut()
	--print("()xxxxx[:::::::::::::::> [start] F_GreasersWipeOut()")
	for i = 1, table.getn(tableBikerPeds) do
		PedStop(tableBikerPeds[i])
		PedClearObjectives(tableBikerPeds[i])
		PedExitVehicle(tableBikerPeds[i])
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_GreasersWipeOut()")
end

function F_CornRequestHelp()
	--print("()xxxxx[:::::::::::::::> [start] F_CornRequestHelp()")
	PedSetActionNode(pedCornelius.id, "/Global/3_04/3_04_Anim/AlgieCower/CowerStart", "Act/Conv/3_04.act")
	--print("()xxxxx[:::::::::::::::> [finish] F_CornRequestHelp()")
end

function F_CleanupAlgieBiking()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupAlgieBiking()")
	bMonitorAlgie = false
	PedDelete(pedAlgie.id)
	VehicleDelete(vehicleBikeAlgie.id)
	PedOverrideStat(pedChad.id, 24, gChadsBikeSpeed)
	PedFollowPath(pedChad.id, PATH._3_04_BIKEESCAPE, 0, 4, F_routeBikeEscape)
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupAlgieBiking()")
end

function F_CleanupAlgieBiking02()
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupAlgieBiking02()")
	PedDelete(pedAlgie.id)
	VehicleDelete(vehicleBikeAlgie.id)
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupAlgieBiking02()")
end

function F_SetupChaserStats(pedID)
	--print("()xxxxx[:::::::::::::::> [start] F_SetupChaserStats()")
	PedOverrideStat(pedID, 9, 0)
	PedOverrideStat(pedID, 30, 80)
	PedOverrideStat(pedID, 10, 5)
	PedOverrideStat(pedID, 34, 0)
	PedOverrideStat(pedID, 33, 75)
	PedSetDamageTakenMultiplier(pedID, 3, 0.05)
	PedSetFlag(pedID, 125, true)
	PedOverrideStat(pedID, 28, 30)
	PedOverrideStat(pedID, 37, gChadsBikeSpeed + 10)
	PedOverrideStat(pedID, 36, gChadsBikeSpeed - 10)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupChaserStats()")
end

function F_WaitForSpeech()
	while SoundSpeechPlaying() do
		Wait(0)
	end
end

function F_MissionCritical()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCritical()")
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCritical()")
end

function F_MissionCriticalCornelius()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalCornelius()")
	gMissionFailMessage = 1
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalCornelius()")
end

function F_MissionCriticalAlgie()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalAlgie()")
	gMissionFailMessage = 2
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalAlgie()")
end

function F_MissionCriticalEarnest()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalEarnest()")
	gMissionFailMessage = 3
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalEarnest()")
end

function F_LaunchBikeDude(node)
	--print("()xxxxx[:::::::::::::::> [start] F_LaunchBikeDude()")
	--print("()xxxxx[:::::::::::::::> Checking chase table.")
	if table.getn(tableBikerPeds) <= 2 then
		--print("()xxxxx[:::::::::::::::> Launching bike dude @ node: " .. node)
		randPedModel = tableGreaserModels[gLastGreaserSpawned]
		local tempVehicle = VehicleCreatePoint(282, POINTLIST._3_04_BIKEATTACKERS, node)
		local tempPed = PedCreatePoint(randPedModel, POINTLIST._3_04_BIKEATTACKERS, node)
		local tempBlip = AddBlipForChar(tempPed, 4, 26, 1)
		PedSetPedToTypeAttitude(tempPed, 13, 0)
		PedPutOnBike(tempPed, tempVehicle)
		if bChaseCount == 4 or bChaseCount == 8 or bChaseCount == 12 or bChaseCount == 16 or bChaseCount == 20 then
			PedSetWeapon(tempPed, 312, 100)
		else
			PedSetWeapon(tempPed, 301, 100)
		end
		F_SetupChaserStats(tempPed)
		PedAttack(tempPed, pedChad.id, 3)
		PedSetHealth(tempPed, gChasersHealth)
		PedSetMaxHealth(tempPed, gChasersHealth)
		table.insert(tableBikerPeds, tempPed)
		table.insert(tableBikerBikes, tempVehicle)
		table.insert(tableBikerBlips, tempBlip)
		bChaseCount = bChaseCount + 1
		gLastGreaserSpawned = gLastGreaserSpawned + 1
		if 5 < gLastGreaserSpawned then
			gLastGreaserSpawned = 1
		end
		--print("()xxxxx[:::::::::::::::> bChaseCount = " .. bChaseCount)
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_LaunchBikeDude()")
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

function F_AlgieIsHit()
	if PedIsHit(pedAlgie.id, 2, 500) and PedGetWhoHitMeLast(pedAlgie.id) == gPlayer then
		return true
	end
	return false
end

function F_HandleFancyCamera()
	if bBikeCameraCut01 then
		F_ChaseCam(1)
		bBikeCameraCut01 = false
	end
	if bBikeCameraCut02 then
		F_ChaseCam(2)
		bBikeCameraCut02 = false
	end
	if bBikeCameraCut03 then
		F_ChaseCam(3)
		bBikeCameraCut03 = false
	end
	if bBikeCameraCut04 then
		F_ChaseCam(4)
		bBikeCameraCut04 = false
	end
	if bBikeCameraCut05 then
		F_ChaseCam(5)
		bBikeCameraCut05 = false
	end
	if bBikeCameraReset then
		F_ResetPlayersCamera()
		bBikeCameraReset = false
	end
end

function F_ChaseCam(shot)
	--print("()xxxxx[:::::::::::::::> [start] F_ChaseCam( " .. shot .. " )")
	PlayerSetControl(0)
	PedSetInvulnerable(gPlayer, true)
	CameraReset()
	CameraAllowChange(true)
	CameraSetWidescreen(true)
	CameraClearRotationLimit()
	SoundSetAudioFocusCamera()
	if shot == 1 then
		bPlayerFacingBackwardsForNIS = 1
		CameraSetXYZ(539.6545, -476.9065, 6.816537, 538.6742, -477.0885, 6.740471)
		CameraLookAtObject(gPlayer, 2, true)
	elseif shot == 2 then
		bPlayerFacingBackwardsForNIS = 1
		CameraSetFOV(80)
		CameraSetXYZ(543.8899, -480.82288, 5.095084, 543.1719, -481.42267, 5.448016)
		SoundSetAudioFocusCamera()
		SoundPlayScriptedSpeechEvent(pedChad.id, "M_2_R11", 10, "large", true)
		Wait(400)
		F_WaitForSpeech(pedChad.id)
		SoundPlay2D("NIS_BIKECEM")
	elseif shot == 3 then
		bPlayerFacingBackwardsForNIS = 0
		AreaClearAllPeds()
		SoundPlayStream("MS_BikeFastLow.rsm", MUSIC_DEFAULT_VOLUME)
		F_MakeSafeForNISCustom(true)
		PedSetFlag(pedChad.id, 108, true)
		PedSetWeaponNow(gPlayer, -1, 0)
		CameraSetFOV(30)
		CameraSetPath(PATH._3_04_CAMBIKE03, true)
		CameraSetSpeed(20, 20, 20)
		CameraLookAtObject(gPlayer, 2, true, 1)
	elseif shot == 4 then
		bPlayerFacingBackwardsForNIS = 1
		CameraSetXYZ(397.5877, -109.68237, 7.372814, 396.6171, -109.44856, 7.316334)
		CameraLookAtObject(pedChad.id, 2, true, 0.3)
	elseif shot == 5 then
		bPlayerFacingBackwardsForNIS = 1
		CameraSetFOV(80)
		CameraSetXYZ(569.60297, -290.15594, 4.964992, 570.0377, -291.03503, 5.159698)
		SoundSetAudioFocusCamera()
		Wait(1500)
		SoundPlay2D("NIS_BIKEDIRT")
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_ChaseCam()")
end

function F_ResetPlayersCamera()
	--print("()xxxxx[:::::::::::::::> [start] F_ResetPlayersCamera()")
	PedSetInvulnerable(gPlayer, false)
	CameraSetWidescreen(false)
	CameraSetRotationLimitRel(45, 1, 0, -1, 0, vehicleBikeChad.id, 1)
	CameraReturnToPlayer()
	CameraReset()
	PedSetWeaponNow(gPlayer, 306, 1)
	PlayerSetControl(1)
	Wait(10)
	CameraSetRotationLimitRel(45, 90, 0, -1, 0, vehicleBikeChad.id, 1)
	CameraAllowChange(false)
	--print("()xxxxx[:::::::::::::::> [finish] F_ResetPlayersCamera()")
end

function F_CreateAlgieTrapTrap()
	--print("()xxxxx[:::::::::::::::> [start] F_CreateAlgieTrapTrap()")
	vehicleBikeAlgie.id = VehicleCreatePoint(vehicleBikeAlgie.model, POINTLIST._3_04_STG3WARPALGIE, 1)
	pedAlgie.id = PedCreatePoint(pedAlgie.model, POINTLIST._3_04_STG3WARPALGIE, 1)
	pedAlgie.blip = AddBlipForChar(pedAlgie.id, 1, 2, 1)
	PedPutOnBike(pedAlgie.id, vehicleBikeAlgie.id)
	--print("()xxxxx[:::::::::::::::> [finish] F_CreateAlgieTrapTrap()")
end

function F_PrepCornCut()
	--print("()xxxxx[:::::::::::::::> [start] F_PrepCornCut()")
	PedDelete(pedCornelius.id)
	PedDelete(pedJohnny.id)
	PedDelete(pedGary.id)
	PedDelete(pedGreaser01.id)
	PedDelete(pedGreaser02.id)
	PedDelete(pedGreaser03.id)
	PedDelete(pedGreaser04.id)
	pedCornelius.id = PedCreatePoint(pedCornelius.model, pedCornelius.spawn, pedCornelius.element)
	PedClearAllWeapons(pedCornelius.id)
	PedSetStationary(pedCornelius.id, true)
	PedOverrideStat(pedCornelius.id, 12, 30)
	pedJohnny.id = PedCreatePoint(pedJohnny.model, pedJohnny.spawn, pedJohnny.element)
	PedSetInfiniteSprint(pedJohnny.id, true)
	PedSetGrappleTarget(pedJohnny.id, pedCornelius.id)
	PedSetActionNode(pedJohnny.id, "/Global/3_04/3_04_Anim/JohnnyShove/GIVE", "Act/Conv/3_04.act")
	PedSetPedToTypeAttitude(pedCornelius.id, 4, 4)
	PedFaceObject(pedCornelius.id, pedJohnny.id, 2, 1)
	pedGary.id = PedCreatePoint(pedGary.model, pedGary.spawn, pedGary.element)
	PedIgnoreStimuli(pedGary.id, true)
	PedFaceObject(pedGary.id, pedCornelius.id, 2, 0)
	PedSetInfiniteSprint(pedGary.id, true)
	pedGreaser01.id = PedCreatePoint(pedGreaser01.model, pedGreaser01.spawn, pedGreaser01.element)
	PedFaceObject(pedGreaser01.id, pedCornelius.id, 2, 0)
	PedSetInfiniteSprint(pedGreaser01.id, true)
	PedSetActionNode(pedGreaser01.id, "/Global/3_04/3_04_Anim/Cheer_Cool3/Cheer_Cool_11", "Act/Conv/3_04.act")
	pedGreaser02.id = PedCreatePoint(pedGreaser02.model, pedGreaser02.spawn, pedGreaser02.element)
	PedFaceObject(pedGreaser02.id, pedCornelius.id, 2, 0)
	PedSetInfiniteSprint(pedGreaser02.id, true)
	PedSetActionNode(pedGreaser02.id, "/Global/3_04/3_04_Anim/Cheer_Cool3/Cheer_Cool_12", "Act/Conv/3_04.act")
	pedGreaser03.id = PedCreatePoint(pedGreaser03.model, pedGreaser03.spawn, pedGreaser03.element)
	PedFaceObject(pedGreaser03.id, pedCornelius.id, 2, 0)
	PedSetActionNode(pedGreaser03.id, "/Global/3_04/3_04_Anim/Cheer_Cool3/Cheer_Cool_13", "Act/Conv/3_04.act")
	pedGreaser04.id = PedCreatePoint(pedGreaser04.model, pedGreaser04.spawn, pedGreaser04.element)
	PedFaceObject(pedGreaser04.id, pedCornelius.id, 2, 0)
	PedSetActionNode(pedGreaser04.id, "/Global/3_04/3_04_Anim/Cheer_Cool3/Cheer_Cool_14", "Act/Conv/3_04.act")
	--print("()xxxxx[:::::::::::::::> [finish] F_PrepCornCut()")
end

function F_RecruitCorn()
	--print("()xxxxx[:::::::::::::::> [start] F_RecruitCorn()")
	if F_PedExists(pedGreaser03.id) then
		PedStop(pedGreaser03.id)
		PedClearObjectives(pedGreaser03.id)
		PedAttack(pedGreaser03.id, pedCornelius.id, 1)
	end
	if F_PedExists(pedGreaser04.id) then
		PedStop(pedGreaser04.id)
		PedClearObjectives(pedGreaser04.id)
		PedAttack(pedGreaser04.id, pedCornelius.id, 1)
	end
	PedHideHealthBar()
	PedRecruitAlly(gPlayer, pedCornelius.id)
	bCornIsAlly = true
	PedSetMissionCritical(pedCornelius.id, true, F_MissionCriticalCornelius, false)
	--print("()xxxxx[:::::::::::::::> [finish] F_RecruitCorn()")
end

function F_DismissCorn()
	--print("()xxxxx[:::::::::::::::> [start] F_DismissCorn()")
	if F_PedExists(pedGreaser03.id) then
		PedStop(pedGreaser03.id)
		PedClearObjectives(pedGreaser03.id)
		PedAttack(pedGreaser03.id, pedCornelius.id, 3)
	end
	if F_PedExists(pedGreaser04.id) then
		PedStop(pedGreaser04.id)
		PedClearObjectives(pedGreaser04.id)
		PedAttack(pedGreaser04.id, pedCornelius.id, 3)
	end
	PedSetMissionCritical(pedCornelius.id, false)
	PedDismissAlly(gPlayer, pedCornelius.id)
	PedShowHealthBar(pedCornelius.id, true, "3_04_HEALTH_CORN", false)
	bCornIsAlly = false
	--print("()xxxxx[:::::::::::::::> [finish] F_DismissCorn()")
end

function F_WaitForSpeechCutscene01(pedID)
	--print("()xxxxx[:::::::::::::::> [start] F_WaitForSpeechCutscene01()")
	if pedID == nil then
		while SoundSpeechPlaying() do
			Wait(0)
		end
	else
		while SoundSpeechPlaying(pedID) do
			if bSkipFirstCutscene then
				break
			end
			Wait(0)
		end
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_WaitForSpeechCutscene01()")
end

function F_WaitForSpeechCutscene02(pedID)
	--print("()xxxxx[:::::::::::::::> [start] F_WaitForSpeechCutscene02()")
	if pedID == nil then
		while SoundSpeechPlaying() do
			Wait(0)
		end
	else
		while SoundSpeechPlaying(pedID) do
			if bSkipSecondCutscene then
				break
			end
			Wait(0)
		end
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_WaitForSpeechCutscene02()")
end

function F_SetupBikeChase()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupBikeChase()")
	if not PedIsInAnyVehicle(pedChad.id) then
		PedPutOnBike(pedChad.id, vehicleBikeChad.id)
	end
	if not PedIsInAnyVehicle(pedAlgie.id) then
		PedPutOnBike(pedAlgie.id, vehicleBikeAlgie.id)
	end
	VehicleSetPosPoint(vehicleEnemyBike01.id, POINTLIST._3_04_SETUPCHASERS, 1)
	VehicleSetPosPoint(vehicleEnemyBike02.id, POINTLIST._3_04_SETUPCHASERS, 2)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupBikeChase()")
end

function F_MakeSafeForNISCustom(bOn)
	if bOn then
		--print("()xxxxx[:::::::::::::::> [SAFE FOR NIS CUSTOM] ON ")
		EnterNIS()
		AreaClearAllExplosions()
		AreaClearAllProjectiles()
		StopAmbientPedAttacks()
		SetAmbientPedsIgnoreStimuli(true)
		PedSetInvulnerable(gPlayer, true)
	else
		--print("()xxxxx[:::::::::::::::> [SAFE FOR NIS CUSTOM] OFF ")
		AreaClearAllExplosions()
		AreaClearAllProjectiles()
		StopAmbientPedAttacks()
		SetAmbientPedsIgnoreStimuli(false)
		PedSetInvulnerable(gPlayer, false)
		ExitNIS()
	end
end

function F_PlayerAimingInNIS()
	--print("()xxxxx[:::::::::::::::> F_PlayerAimingInNIS()")
	return bPlayerFacingBackwardsForNIS
end

function T_MonitorCornBullies()
	--print("()xxxxx[:::::::::::::::> [start] T_MonitorCornBullies()")
	local tableCornBullies = {
		pedCornelius.id,
		pedJohnny.id,
		pedGary.id,
		pedGreaser01.id,
		pedGreaser02.id,
		pedGreaser03.id,
		pedGreaser04.id
	}
	while bMonitorCornBullies do
		for i = 1, 7 do
			if PedIsHit(tableCornBullies[i], 2, 10) then
				--print("()xxxxx[:::::::::::::::> BULLY HIT")
				if PedGetWhoHitMeLast(tableCornBullies[i]) == gPlayer then
					--print("()xxxxx[:::::::::::::::> BULLY HIT BY PLAYER")
					if PedIsDead(tableCornBullies[i]) then
						bMissionFailed = true
						break
					end
					bPlayerAgrodBullys = true
				end
			end
		end
		if bPlayerAgrodBullys then
			break
		end
		Wait(0)
	end
	collectgarbage()
	--print("()xxxxx[:::::::::::::::> [finish] T_MonitorCornBullies()")
end

function T_SaveCorn()
	--print("()xxxxx[:::::::::::::::> [start] T_SaveCorn()")
	while not PedIsDead(pedCornelius.id) do
		if PedIsHit(pedGreaser03.id, 2, 10) and PedGetWhoHitMeLast(pedGreaser03.id) == gPlayer then
			F_CornRequestHelp()
			break
		end
		if PedIsHit(pedGreaser04.id, 2, 10) and PedGetWhoHitMeLast(pedGreaser04.id) == gPlayer then
			F_CornRequestHelp()
			break
		end
		Wait(0)
	end
	collectgarbage()
	--print("()xxxxx[:::::::::::::::> [finish] T_SaveCorn()")
end

function T_MonitorBikers()
	--print("()xxxxx[:::::::::::::::> [start] T_MonitorBikers()")
	local playerX, playerY, playerZ = 0, 0, 0
	while bMonitorBikers do
		if table.getn(tableBikerPeds) >= 1 then
			tableMarkForDelete = {}
			for i = 1, table.getn(tableBikerPeds) do
				playerX, playerY, playerZ = PlayerGetPosXYZ()
				if not PedIsOnVehicle(tableBikerPeds[i]) or not PedIsInAreaXYZ(tableBikerPeds[i], playerX, playerY, playerZ, 50, 0) then
					--print("()xxxxx[:::::::::::::::> Biker fell off bike or out of range, removing from chase table.")
					table.insert(tableMarkForDelete, 1, i)
					bDeleteSomeBikePeds = true
				end
			end
			if bDeleteSomeBikePeds then
				if not bJimmyOneDown then
					SoundPlayScriptedSpeechEvent(gPlayer, "M_3_04", 25, "large", true)
					bJimmyOneDown = true
				end
				for i = 1, table.getn(tableMarkForDelete) do
					PedStop(tableBikerPeds[tableMarkForDelete[i]])
					PedClearObjectives(tableBikerPeds[tableMarkForDelete[i]])
					PedMakeAmbientKeepResources(tableBikerPeds[tableMarkForDelete[i]])
					PedFlee(tableBikerPeds[tableMarkForDelete[i]], pedChad.id)
					table.remove(tableBikerPeds, tableMarkForDelete[i])
					VehicleMakeAmbient(tableBikerBikes[tableMarkForDelete[i]])
					table.remove(tableBikerBikes, tableMarkForDelete[i])
					BlipRemove(tableBikerBlips[tableMarkForDelete[i]])
					table.remove(tableBikerBlips, tableMarkForDelete[i])
				end
				tableMarkForDelete = {}
				collectgarbage()
				bDeleteSomeBikePeds = false
			end
		end
		Wait(0)
	end
	collectgarbage()
	--print("()xxxxx[:::::::::::::::> [finish] T_MonitorBikers()")
end

function T_StartLostEmDialogue()
	--print("()xxxxx[:::::::::::::::> [start] T_StartLostEmDialogue()")
	SoundPlayScriptedSpeechEvent(gPlayer, "M_3_04", 27, "large", true)
	F_WaitForSpeech(gPlayer)
	SoundPlayScriptedSpeechEvent(pedChad.id, "M_3_04", 28, "large", true)
	F_WaitForSpeech(pedChad.id)
	--print("()xxxxx[:::::::::::::::> [finish] T_StartLostEmDialogue()")
end

function T_CornScream()
	--print("()xxxxx[:::::::::::::::> [start] T_CornScream()")
	SoundPlayScriptedSpeechEvent(pedCornelius.id, "M_3_04", 2, "large")
	Wait(500)
	if F_PedExists(pedGreaser01.id) then
		SoundPlayScriptedSpeechEvent(pedGreaser01.id, "FIGHT_WATCH", 0, "small")
	end
	F_WaitForSpeech(pedCornelius.id)
	if F_PedExists(pedJohnny.id) then
		SoundPlayScriptedSpeechEvent(pedJohnny.id, "M_3_04", 1, "large")
	end
	Wait(500)
	if F_PedExists(pedGreaser02.id) then
		SoundPlayScriptedSpeechEvent(pedGreaser02.id, "FIGHT_WATCH", 0, "small")
	end
	--print("()xxxxx[:::::::::::::::> [finish] T_CornScream()")
end

function T_SpeechJimmyBike()
	--print("()xxxxx[:::::::::::::::> [start] T_SpeechJimmyBike()")
	SoundPlayScriptedSpeechEvent(gPlayer, "M_3_04", 24)
	F_WaitForSpeech(gPlayer)
	SoundPlayAmbientSpeechEvent(pedAlgie.id, "BOISTEROUS")
	--print("()xxxxx[:::::::::::::::> [finish] T_SpeechJimmyBike()")
end

function T_TextChadLeave()
	--print("()xxxxx[:::::::::::::::> [start] T_TextChadLeave()")
	SoundPlayScriptedSpeechEvent(pedChad.id, "M_3_04", 34)
	F_WaitForSpeech(pedChad.id)
	SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_3_04", 35)
	--print("()xxxxx[:::::::::::::::> [finish] T_TextChadLeave()")
end

function T_CutsceneCornelius()
	SoundSetAudioFocusCamera()
	if not bSkipFirstCutscene then
		PedSetActionNode(pedJohnny.id, "/Global/3_04/3_04_Anim/JohnnyShove/GIVE", "Act/Conv/3_04.act")
		SoundPlayScriptedSpeechEvent(pedJohnny.id, "M_3_04", 4, "medium")
	end
	if not bSkipFirstCutscene then
		WaitSkippable(1000)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser01.id, "FIGHT_WATCH", 0, "small")
	end
	if not bSkipFirstCutscene then
		WaitSkippable(1000)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser03.id, "FIGHT_WATCH", 0, "small")
	end
	if not bSkipFirstCutscene then
		F_WaitForSpeechCutscene01(pedJohnny.id)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedCornelius.id, "M_3_04", 5, "medium")
	end
	if not bSkipFirstCutscene then
		WaitSkippable(750)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser02.id, "FIGHT_WATCH", 0, "small")
	end
	if not bSkipFirstCutscene then
		F_WaitForSpeechCutscene01(pedCornelius.id)
	end
	if not bSkipFirstCutscene then
		CameraSetFOV(40)
		SoundPlayScriptedSpeechEvent(pedGreaser01.id, "FIGHT_WATCH", 0, "small")
		CameraSetXYZ(238.97276, -132.04884, 8.799355, 239.24603, -131.1322, 8.507829)
		SoundPlayScriptedSpeechEvent(pedGreaser01.id, "FIGHT_WATCH", 0, "small")
		PedSetActionNode(pedJohnny.id, "/Global/3_04/3_04_Anim/JohnnyIdle/JohnnyIdle", "Act/Conv/3_04.act")
		PedSetActionNode(pedCornelius.id, "/Global/3_04/3_04_Anim/NerdScared", "Act/Conv/3_04.act")
		PedSetActionNode(pedGary.id, "/Global/3_04/3_04_Anim/GaryIntro/Gary1", "Act/Conv/3_04.act")
		SoundPlayScriptedSpeechEvent(pedGary.id, "M_3_04", 6, "medium")
	end
	if not bSkipFirstCutscene then
		WaitSkippable(1000)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser02.id, "FIGHT_WATCH", 0, "small")
	end
	if not bSkipFirstCutscene then
		WaitSkippable(500)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser03.id, "FIGHT_WATCH", 0, "small")
		SoundPlayScriptedSpeechEvent(pedGreaser02.id, "FIGHT_WATCH", 0, "small")
	end
	if not bSkipFirstCutscene then
		F_WaitForSpeechCutscene01(pedGary.id)
	end
	if not bSkipFirstCutscene then
		PedSetActionNode(pedJohnny.id, "/Global/3_04/3_04_Anim/JohnnyIdle/Johnny1", "Act/Conv/3_04.act")
		SoundPlayScriptedSpeechEvent(pedJohnny.id, "M_3_04", 7, "medium")
	end
	if not bSkipFirstCutscene then
		WaitSkippable(1000)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser01.id, "FIGHT_WATCH", 0, "small")
	end
	if not bSkipFirstCutscene then
		WaitSkippable(500)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser04.id, "FIGHT_WATCH", 0, "small")
	end
	if not bSkipFirstCutscene then
		WaitSkippable(250)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser02.id, "FIGHT_WATCH", 0, "small")
	end
	if not bSkipFirstCutscene then
		F_WaitForSpeechCutscene01(pedJohnny.id)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser03.id, "FIGHT_WATCH", 0, "small")
		PedSetActionNode(pedJohnny.id, "/Global/3_04/3_04_Anim/JohnnyIdle/Johnny2", "Act/Conv/3_04.act")
		SoundPlayScriptedSpeechEvent(pedJohnny.id, "M_3_04", 8, "medium")
	end
	if not bSkipFirstCutscene then
		WaitSkippable(1000)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser04.id, "FIGHT_WATCH", 0, "small")
	end
	if not bSkipFirstCutscene then
		WaitSkippable(1000)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser03.id, "FIGHT_WATCH", 0, "small")
	end
	if not bSkipFirstCutscene then
		F_WaitForSpeechCutscene01(pedJohnny.id)
	end
	if not bSkipFirstCutscene then
		SoundPlayScriptedSpeechEvent(pedGreaser02.id, "M_3_04", 10, "small")
		CameraLookAtObject(pedJohnny.id, 2, false, 1)
		PedSetActionNode(pedJohnny.id, "/Global/3_04/3_04_Anim/Empty", "Act/Conv/3_04.act")
		PedFollowPath(pedJohnny.id, PATH._3_04_JOHNNYLEAVE, 0, 2)
	end
	if not bSkipFirstCutscene then
		WaitSkippable(500)
	end
	if not bSkipFirstCutscene then
		PedSetActionNode(pedGary.id, "/Global/3_04/3_04_Anim/Empty", "Act/Conv/3_04.act")
		PedFollowPath(pedGary.id, PATH._3_04_JOHNNYLEAVE, 0, 2)
	end
	if not bSkipFirstCutscene then
		WaitSkippable(500)
	end
	if not bSkipFirstCutscene then
		PedSetActionNode(pedGreaser01.id, "/Global/3_04/3_04_Anim/Empty", "Act/Conv/3_04.act")
		PedFollowPath(pedGreaser01.id, PATH._3_04_JOHNNYLEAVE, 0, 2)
		PedSetActionNode(pedGreaser02.id, "/Global/3_04/3_04_Anim/Empty", "Act/Conv/3_04.act")
		PedFollowPath(pedGreaser02.id, PATH._3_04_JOHNNYLEAVE, 0, 2)
	end
	if not bSkipFirstCutscene then
		WaitSkippable(2000)
	end
	SoundSetAudioFocusPlayer()
	bSkipFirstCutscene = true
end

function T_CutsceneBikeEscape()
	SoundSetAudioFocusCamera()
	if not bSkipSecondCutscene then
		PedSetActionNode(pedAlgie.id, "/Global/3_04/3_04_Anim/Algie/Algie01", "Act/Conv/3_04.act")
		SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_3_04", 16, "medium")
	end
	if not bSkipSecondCutscene then
		F_WaitForSpeechCutscene02(pedAlgie.id)
	end
	if not bSkipSecondCutscene then
		CameraSetFOV(30)
		CameraSetXYZ(508.45724, -398.3562, 3.449038, 507.57617, -397.88782, 3.513284)
		PedSetActionNode(pedNorton.id, "/Global/3_04/3_04_Anim/Norton/Norton01", "Act/Conv/3_04.act")
		SoundPlayScriptedSpeechEvent(pedNorton.id, "M_3_04", 14, "medium")
	end
	if not bSkipSecondCutscene then
		F_WaitForSpeechCutscene02(pedNorton.id)
	end
	if not bSkipSecondCutscene then
		CameraSetFOV(70)
		CameraSetXYZ(505.89886, -435.94614, 6.95325, 505.1477, -435.36276, 6.644832)
		PedEnterVehicle(pedAlgie.id, vehicleBikeAlgie.id)
		PedEnterVehicle(pedChad.id, vehicleBikeChad.id)
		PedFollowPath(gPlayer, PATH._3_04_STG3INTROJIMMY, 0, 1)
		PedDelete(pedNorton.id)
	end
	if not bSkipSecondCutscene then
		WaitSkippable(1000)
	end
	if not bSkipSecondCutscene then
		CameraSetFOV(40)
		CameraSetXYZ(489.37964, -439.3354, 3.433573, 489.5797, -438.35577, 3.451386)
		PedStop(pedAlgie.id)
		PedStop(pedChad.id)
		PedStop(gPlayer)
		PedFollowPath(pedGreaser01.id, PATH._3_04_STG3INTROGB1, 0, 1, F_routeStg3CutGB01)
		PedFollowPath(pedGreaser02.id, PATH._3_04_STG3INTROGB2, 0, 1, F_routeStg3CutGB02)
		PedEnterVehicle(pedAlgie.id, vehicleBikeAlgie.id)
		PedEnterVehicle(pedChad.id, vehicleBikeChad.id)
		PedFollowPath(gPlayer, PATH._3_04_STG3INTROJIMMY, 0, 1)
	end
	if not bSkipSecondCutscene then
		WaitSkippable(3000)
	end
	if not bSkipSecondCutscene then
		PedFaceObject(gPlayer, pedGreaser01.id, 2, 1)
		SoundPlayScriptedSpeechEventWrapper(pedGreaser01.id, "M_3_04", 21, "supersize", true)
		CameraSetFOV(30)
		CameraSetXYZ(492.9539, -409.0517, 3.508395, 492.92245, -410.05103, 3.492468)
	end
	if not bSkipSecondCutscene then
		F_WaitForSpeechCutscene02(pedGreaser01.id)
	end
	if not bSkipSecondCutscene then
		WaitSkippable(1000)
	end
	if not bSkipSecondCutscene then
		CameraSetFOV(30)
		CameraSetXYZ(488.61404, -413.486, 3.125624, 489.45847, -412.96896, 3.265319)
		SoundPlayScriptedSpeechEventWrapper(pedGreaser02.id, "M_3_04", 22, "medium")
	end
	if not bSkipSecondCutscene then
		F_WaitForSpeechCutscene02(pedGreaser02.id)
	end
	SoundSetAudioFocusPlayer()
	bSkipSecondCutscene = true
end

function F_routeCornLeave(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeCornLeave() @ node: " .. nodeID)
	if nodeID == 2 then
		bDeleteCorn = true
	end
end

function F_routeStg3CutGB01(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeStg3CutGB01() @ node: " .. nodeID)
	if nodeID == 5 then
		bIntroCutWait = true
	end
end

function F_routeStg3CutGB02(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeStg3CutGB01() @ node: " .. nodeID)
end

function F_routeJohnnyLeave(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeJohnnyLeave() @ node: " .. nodeID)
	if nodeID == 3 then
		bCleanupJCrew = true
	end
end

function F_routeBikeEscape(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeBikeEscape() @ node: " .. nodeID)
	if pedID == pedChad.id then
		if nodeID == 6 then
			bCleanupAlgieBiking = true
		elseif nodeID == 9 then
		elseif nodeID == 10 then
			F_LaunchBikeDude(1)
		elseif nodeID == 16 then
			F_LaunchBikeDude(2)
		elseif nodeID == 25 then
			F_LaunchBikeDude(3)
		elseif nodeID == 32 then
			F_LaunchBikeDude(4)
		elseif nodeID == 33 then
			F_LaunchBikeDude(5)
		elseif nodeID == 40 then
			F_LaunchBikeDude(6)
		elseif nodeID == 41 then
			F_LaunchBikeDude(7)
		elseif nodeID == 45 then
			BikeJump(vehicleBikeChad.id, 1)
		elseif nodeID == 44 then
			bBikeCameraCut02 = true
		elseif nodeID == 46 then
			bBikeCameraReset = true
			F_LaunchBikeDude(8)
			bLaunchEscapeRoute02 = true
		end
	end
end

function F_routeBikeEscape02(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeBikeEscape02() @ node: " .. nodeID)
	if nodeID == 1 then
		F_LaunchBikeDude(9)
	elseif nodeID == 9 then
		F_LaunchBikeDude(10)
	elseif nodeID == 10 then
		bBikeCameraCut05 = true
		SoundPlayAmbientSpeechEvent(pedChad.id, "BOISTEROUS")
	elseif nodeID == 11 then
		BikeJump(vehicleBikeChad.id, 0.75)
	elseif nodeID == 12 then
		bBikeCameraReset = true
	elseif nodeID == 21 then
		F_GreasersWipeOut()
	elseif nodeID == 23 then
	elseif nodeID == 24 then
		bStartLostEmDialogue = true
		bBikeCameraCut03 = true
		bCreateAlgieTrapTrap = true
	elseif nodeID == 32 then
		bCutEscape = true
	end
end

function F_routeBikeEscape03(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeBikeEscape03() @ node: " .. nodeID)
	if pedID == pedChad.id then
		if nodeID == 1 then
			SoundPlayScriptedSpeechEvent(pedChad.id, "M_3_04", 32, "large", true)
			bBikeCameraReset = true
		elseif nodeID == 4 then
			F_LaunchBikeDude(11)
		elseif nodeID == 5 then
			bLaunchEscapeRoute04 = true
		end
	end
end

function F_routeAlgieTrapTrap(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeAlgieTrapTrap() @ node: " .. nodeID)
	if nodeID == 5 then
		bCleanupAlgieBiking02 = true
	end
end

function F_routeBikeEscape04(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeBikeEscape04() @ node: " .. nodeID)
	if nodeID == 1 then
		F_LaunchBikeDude(12)
		SoundPlayAmbientSpeechEvent(pedChad.id, "COMPLAIN")
	elseif nodeID == 2 then
		F_LaunchBikeDude(13)
	elseif nodeID == 7 then
		F_LaunchBikeDude(14)
	elseif nodeID == 9 then
		F_LaunchBikeDude(15)
	elseif nodeID == 10 then
		F_LaunchBikeDude(16)
	elseif nodeID == 17 then
		F_LaunchBikeDude(17)
	elseif nodeID == 19 then
		F_LaunchBikeDude(18)
	elseif nodeID == 23 then
		F_LaunchBikeDude(19)
	elseif nodeID == 24 then
		F_LaunchBikeDude(20)
	elseif nodeID == 26 then
		F_LaunchBikeDude(21)
	elseif nodeID == 28 then
		F_LaunchBikeDude(22)
	elseif nodeID == 29 then
		SoundPlayScriptedSpeechEvent(pedChad.id, "M_3_04", 26, "large", true)
		bBikeCameraCut04 = true
	elseif nodeID == 30 then
		bBikeCameraReset = true
	elseif nodeID == 37 then
		PedPathNodeReachedDistance(pedChad.id, 2)
		bGoToStage4 = true
	end
end

function F_routeAlgieLeaveLolas(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeAlgieLeaveLolas() @ node: " .. nodeID)
	if nodeID == 6 then
		bCleanupAlgieBiking = true
	end
end

function F_routeChaseBreakOff01(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeChaseBreakOff01() @ node: " .. nodeID)
	if nodeID == 1 and pedID == pedExtraGoon01.id then
		bDeleteExtraGoon01 = true
	end
end

function F_routeAlgieLeaveAlley(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeAlgieLeaveAlley() @ node: " .. nodeID)
	if pedID == pedAlgie.id then
		if nodeID == 1 then
			bGreasersResumeChase = true
		elseif nodeID == 5 then
			bCleanupAlgieBiking02 = true
		end
	end
end

function F_routeChaseBreakOff03(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeChaseBreakOff03() @ node: " .. nodeID)
	if nodeID == 1 and pedID == pedExtraGoon03.id then
		bDeleteExtraGoon03 = true
	end
end
