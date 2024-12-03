local gCops = {}
local gCopCars = {}
local gRussell, gStageUpdateFunction
local gMissionStage = "running"
local gStageEvent = false
local gBikePeds = {}
local gPeds = {}
local gEdgar
local gCurrentRussellNode = 0
local bNerdBoss = true
local bGreaserBoss = true
local bJockBoss = true
local bPreppyBoss = true
local bUpdatePlayerLoc = true
local gNerdThread, gJockThread, gGreaserThread, gPreppyThread, gTriggerActivated
local gObjectiveBlips = {}
local gGary
local gGaryAttacking = 1
local gGaryCurrentNode = 0
local gOriginalGaryHealth = 0
local bGaryAlive = true
local gGaryPos = {}
local geometryTable = {}
local gObjectiveTable = {}
local gGirlsHaveAttacked = false
local bPlayerReachedEnd = false
local bRussDied = false
local geoIndex, geoEntityType

function MissionCleanup()
	VehicleRevertToDefaultAmbient()
	AreaSetDoorLocked(TRIGGER._DT_TSCHOOL_SCHOOLFRONTDOORL, false)
	AreaSetDoorLocked(TRIGGER._TSCHOOL_SCHOOLFRONTDOORR, false)
	SoundStopInteractiveStream()
	SoundEnableSpeech_ActionTree()
	F_RemoveObjectiveBlip()
	for i, entity in geometryTable do
		DeletePersistentEntity(entity[2], entity[3])
	end
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	SoundEnableSpeech_ActionTree()
	F_MakePlayerSafeForNIS(false)
	F_CleanupCops(true)
	if gRussell then
		PedDelete(gRussell)
		gRussell = nil
	end
	UnLoadAnimationGroup("NIS_6_02")
	PlayerSetControl(1)
end

function MissionSetup()
	MissionDontFadeIn()
	PedSetUniqueModelStatus(176, -1)
	AreaSetDoorLocked(TRIGGER._DT_TSCHOOL_SCHOOLFRONTDOORL, true)
	shared.gOverrideSchoolGates = true
	shared.gParkingGateOpen = false
	shared.gFrontGateOpen = false
	SoundPlayInteractiveStream("MS_RunningLow02.rsm", MUSIC_DEFAULT_VOLUME)
	SoundSetMidIntensityStream("MS_SearchingMid.rsm", MUSIC_DEFAULT_VOLUME)
	PlayCutsceneWithLoad("6-02", true, true)
	DATLoad("6_02.DAT", 2)
	DATInit()
end

function F_MissionSetup()
	LoadAnimationGroup("6_02CompMayh")
	LoadAnimationGroup("NIS_6_02")
	local index, simpleObject = CreatePersistentEntity("DPE_Dumpster", 79.0067, -418.112, 0.710667, -169.314, 0)
	table.insert(geometryTable, {
		"DPE_Dumpster",
		index,
		simpleObject
	})
	POIGroupsEnabled(false)
	LoadPedModels({
		176,
		83,
		97,
		72,
		66,
		70,
		73
	})
	LoadVehicleModels({ 295 })
	LoadActionTree("Act/Conv/6_02.act")
	shared.enclaveGateRespawn = 2
end

function F_Stage3()
	if PlayerIsInTrigger(TRIGGER._INDUSTRIALGATES) then
		F_RunFinalNIS()
	end
end

function F_Stage2A()
	if PlayerIsInTrigger(TRIGGER._FACTORYENTRANCE) then
		PedAttack(gCops[1], gPlayer, 1)
		PedAttack(gCops[2], gPlayer, 1)
		gStageUpdateFunction = F_Stage3
	end
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

function F_Stage1()
	if gRussell == nil and PlayerIsInTrigger(TRIGGER._FACTORYENTRANCE) then
		gRussell = PedCreatePoint(176, POINTLIST._INDUS_POINTS, 6)
		PedSetActionNode(gRussell, "/Global/6_02/RussellHide/Cower_Child", "Act/Conv/6_02.act")
		MissionObjectiveComplete(gObjectiveTable[1])
		table.insert(gObjectiveTable, MissionObjectiveAdd("6_02_OBJ2"))
		TextPrint("6_02_OBJ2", 4, 1)
		F_AddObjectiveBlip("POINT", POINTLIST._INDUS_POINTS, 6, 1)
		SoundPlayInteractiveStream("MS_SearchingLow.rsm", MUSIC_DEFAULT_VOLUME)
		SoundSetMidIntensityStream("MS_SearchingMid.rsm", MUSIC_DEFAULT_VOLUME)
		SoundSetHighIntensityStream("MS_SearchingHigh.rsm", MUSIC_DEFAULT_VOLUME)
	end
	if gRussell and PlayerIsInAreaObject(gRussell, 2, 5, 0) and PlayerIsInTrigger(TRIGGER._6_02_WONDERMEATS) then
		PedSetActionNode(gRussell, "/Global/6_02/Russell_NIS/Russell/Russell01", "Act/Conv/6_02.act")
		SoundPlayScriptedSpeechEvent(gRussell, "M_6_02", 3, "jumbo")
		Wait(3000)
		SoundPlayScriptedSpeechEvent(gRussell, "M_6_03", 9, "jumbo")
		PedFollowPath(gRussell, PATH._6_02_RUSSELLRUNAWAY, 0, 3, CB_RussellPath)
		PedShowHealthBar(gRussell, true, "6_02_RUSSELL", false)
		PedOverrideStat(gRussell, 6, 0)
		PedSetInfiniteSprint(gRussell, true)
		F_AddObjectiveBlip("CHAR", gRussell, 11, 4)
		MissionObjectiveComplete(gObjectiveTable[2])
		table.insert(gObjectiveTable, MissionObjectiveAdd("6_02_OBJ3"))
		TextPrint("6_02_OBJ3", 4, 1)
		AreaClearAllVehicles()
		VehicleOverrideAmbient(0, 0, 0, 0)
		F_CleanupCops()
		F_SetupFinalCops()
		gStageUpdateFunction = F_Stage2A
	end
end

function F_SetupStage1()
	local cop = PedCreatePoint(83, POINTLIST._INDUS_POINTS, 7)
	PedFollowPath(cop, PATH._INDUS_COPA, 1, 0)
	PedSetPedToTypeAttitude(cop, 3, 0)
	PedSetPedToTypeAttitude(cop, 13, 0)
	table.insert(gCops, cop)
	cop = PedCreatePoint(97, POINTLIST._INDUS_POINTS, 8)
	PedFollowPath(cop, PATH._INDUS_COPB, 1, 0)
	PedSetPedToTypeAttitude(cop, 3, 0)
	PedSetPedToTypeAttitude(cop, 13, 0)
	table.insert(gCops, cop)
	cop = PedCreatePoint(83, POINTLIST._COPS, 1)
	PedSetPedToTypeAttitude(cop, 3, 0)
	PedSetPedToTypeAttitude(cop, 13, 0)
	table.insert(gCops, cop)
	local copCar
	copCar = VehicleCreatePoint(295, POINTLIST._COPS, 4)
	VehicleEnableEngine(copCar, true)
	VehicleEnableSiren(copCar, true)
	PedWarpIntoCar(gCops[3], copCar)
	table.insert(gCopCars, copCar)
	cop = PedCreatePoint(97, POINTLIST._COPS, 2)
	PedSetPedToTypeAttitude(cop, 3, 0)
	PedSetPedToTypeAttitude(cop, 13, 0)
	table.insert(gCops, cop)
	copCar = nil
	copCar = VehicleCreatePoint(295, POINTLIST._COPS, 3)
	--print("Cop car: ", tostring(copCar))
	VehicleEnableEngine(copCar, true)
	VehicleEnableSiren(copCar, true)
	PedWarpIntoCar(gCops[4], copCar)
	table.insert(gCopCars, copCar)
	cop = PedCreatePoint(83, POINTLIST._COPS, 1)
	PedSetPedToTypeAttitude(cop, 3, 0)
	PedSetPedToTypeAttitude(cop, 13, 0)
	table.insert(gCops, cop)
	cop = PedCreatePoint(97, POINTLIST._COPS, 2)
	PedSetPedToTypeAttitude(cop, 3, 0)
	PedSetPedToTypeAttitude(cop, 13, 0)
	table.insert(gCops, cop)
	F_AddObjectiveBlip("POINT", POINTLIST._OBJECTIVELOCS, 7, 1)
	TextPrint("6_02_OBJ1", 4, 1)
	table.insert(gObjectiveTable, MissionObjectiveAdd("6_02_OBJ1"))
	gStageUpdateFunction = F_Stage1
end

function main()
	F_MissionSetup()
	F_MagicalJasonsByRobertoTransition(0, POINTLIST._INDUS_POINTS, 1, true)
	PlayerFaceHeading(90, 0)
	CameraReturnToPlayer(true)
	CameraFade(500, 1)
	Wait(500)
	gStageUpdateFunction = F_SetupStage1
	while gMissionStage == "running" do
		gStageUpdateFunction()
		UpdateTextQueue()
		Wait(0)
		if gRussell and PedIsDead(gRussell) then
			bRussDied = true
			gMissionStage = "failed"
			break
		end
	end
	if gMissionStage == "failed" then
		if bRussDied then
			SoundPlayMissionEndMusic(false, 10)
			MissionFail(false, true, "6_02_RUSSKO")
		else
			SoundPlayMissionEndMusic(false, 10)
			MissionFail()
		end
	elseif gMissionStage == "passed" then
		MissionSucceed(true, false, false)
	end
end

local gObjectiveBlip

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

function F_RemoveObjectiveBlip()
	if gObjectiveBlip ~= nil then
		BlipRemove(gObjectiveBlip)
		Wait(100)
		gObjectiveBlip = nil
	end
end

function F_AddObjectiveBlip(blipType, point, index, blipEnum)
	F_RemoveObjectiveBlip()
	if gObjectiveBlip == nil then
		if blipType == "POINT" then
			Wait(100)
			local x, y, z = GetPointFromPointList(point, index)
			gObjectiveBlip = BlipAddXYZ(x, y, z + 0.1, 0)
		elseif blipType == "CHAR" and not PedIsDead(point) then
			Wait(100)
			gObjectiveBlip = AddBlipForChar(point, index, 0, blipEnum)
		end
	end
end

function F_RunRescueRussellNIS()
end

function F_CleanupCops(bDelete)
	for i, cop in gCops do
		if cop and PedIsValid(cop) then
			if bDelete then
				PedDelete(cop)
			else
				PedMakeAmbient(cop)
			end
		end
	end
	gCops = {}
	for i, car in gCopCars do
		if VehicleIsValid(car) then
			VehicleDelete(car)
		end
	end
	gCopCars = {}
end

function CB_RussellPath(ped, path, node)
	if node == PathGetLastNode(PATH._6_02_RUSSELLRUNAWAY) then
		bRussellReachedEnd = true
	end
end

function F_RunFinalNIS()
	CameraFade(500, 0)
	Wait(501)
	if PedIsInAnyVehicle(gPlayer) then
		local vehicle
		vehicle = PedGetLastVehicle(gPlayer)
		PlayerDetachFromVehicle()
		if vehicle and VehicleIsValid(vehicle) then
			VehicleDelete(vehicle)
		end
	end
	F_CleanupCops(true)
	PlayerSetControl(0)
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	PedStop(gRussell)
	PedClearObjectives(gRussell)
	PlayerSetPosPoint(POINTLIST._INDUS_POINTS, 4)
	PedSetPosPoint(gRussell, POINTLIST._INDUS_POINTS, 3)
	gCop1 = PedCreatePoint(97, POINTLIST._6_02_COPSNIS, 1)
	gCop2 = PedCreatePoint(83, POINTLIST._6_02_COPSNIS, 2)
	PedFollowPath(gPlayer, PATH._6_02_PLAYERRUN, 0, 2, CB_PLAYEREND)
	CameraSetXYZ(129.82951, -402.33475, 3.904367, 129.37022, -401.44717, 3.872292)
	CameraFade(500, 1)
	CameraSetFOV(30)
	Wait(501)
	while not bPlayerReachedEnd do
		Wait(0)
	end
	PedSetActionNode(gRussell, "/Global/6_02/WonderNIS/Grapple", "Act/Conv/6_02.act")
	PedSetActionNode(gPlayer, "/Global/6_02/WonderNIS/Receive", "Act/Conv/6_02.act")
	Wait(500)
	CameraFade(500, 0)
	Wait(501)
	PlayerSetPosPoint(POINTLIST._INDUS_POINTS, 9)
	PedSetPosPoint(gRussell, POINTLIST._INDUS_POINTS, 5)
	PedStop(gPlayer)
	PedStop(gRussell)
	CameraSetXYZ(125.54463, -391.90854, 2.874992, 125.86193, -392.84317, 3.035046)
	PedStop(gCop1)
	PedClearObjectives(gCop1)
	PedClearObjectives(gCop2)
	PedSetPosPoint(gCop1, POINTLIST._6_02_COPSNIS, 3)
	PedFollowPath(gCop2, PATH._6_02_COPGOFOLLOW, 0, 2)
	PedSetAsleep(gPlayer, true)
	PedSetAsleep(gRussell, true)
	PedSetAsleep(gCop1, true)
	Wait(50)
	F_MakePlayerSafeForNIS(true)
	DisablePunishmentSystem(true)
	PedSetPedToTypeAttitude(gCop1, 13, 4)
	PedStop(gCop1)
	PedClearObjectives(gCop1)
	PedIgnoreStimuli(gCop1, true)
	PedIgnoreStimuli(gCop2, true)
	PedAddPedToIgnoreList(gCop1, gRussell)
	PedAddPedToIgnoreList(gCop2, gRussell)
	PedAddPedToIgnoreList(gCop1, gRussell)
	PedAddPedToIgnoreList(gCop2, gPlayer)
	Wait(10)
	PedSetActionNode(gPlayer, "/Global/6_02/RussellAlley/Jimmy/Jimmy01", "Act/Conv/6_02.act")
	PedSetActionNode(gRussell, "/Global/6_02/RussellAlley/Russell/Russell01", "Act/Conv/6_02.act")
	PedSetActionNode(gCop1, "/Global/6_02/WonderNIS/LookAround", "Act/Conv/6_02.act")
	Wait(50)
	CameraFade(500, 1)
	Wait(501)
	Wait(10)
	SoundPlayScriptedSpeechEvent(gCop1, "STEALTH_TARGET_LOST", 0, "jumbo")
	PedClearObjectives(gCop1)
	while PedIsPlaying(gCop1, "/Global/6_02/WonderNIS/LookAround", true) do
		Wait(0)
	end
	PedSetAsleep(gCop1, false)
	PedFollowPath(gCop1, PATH._6_02_COPGOFOLLOW, 0, 2, nil, 2)
	CameraSetXYZ(119.74129, -387.15884, 5.153429, 120.4866, -387.7998, 4.970528)
	CameraSetXYZ(119.74129, -387.15884, 5.153429, 120.4866, -387.7998, 4.970528)
	Wait(2000)
	CameraFade(500, 0)
	Wait(501)
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	SoundDisableSpeech_ActionTree()
	F_MakePlayerSafeForNIS(true)
	PedSetMissionCritical(gRussell, false, nil, false)
	PedDismissAlly(gPlayer, gRussell)
	PlayerSetPosPoint(POINTLIST._6_02_ENDNIS, 1)
	PedSetPosPoint(gRussell, POINTLIST._6_02_ENDNIS, 2)
	PedFaceObject(gPlayer, gRussell, 2, 1)
	PedFaceObject(gRussell, gPlayer, 3, 1)
	CameraSetXYZ(124.66725, -394.8919, 3.525755, 123.68189, -394.97818, 3.672737)
	Wait(100)
	CameraFade(500, 1)
	Wait(501)
	PedSetAsleep(gPlayer, false)
	PedSetActionNode(gRussell, "/Global/6_02/Russell_NIS/Russell/Russell03", "Act/Conv/6_02.act")
	SoundPlayScriptedSpeechEvent(gRussell, "M_6_02", 5, "jumbo")
	F_WaitForSpeech(gRussell)
	CameraSetXYZ(120.09238, -395.6573, 4.364055, 121.05116, -395.41248, 4.220038)
	PedSetActionNode(gPlayer, "/Global/6_02/Russell_NIS/Player/Player02", "Act/Conv/6_02.act")
	SoundPlayScriptedSpeechEvent(gPlayer, "M_6_02", 12, "jumbo")
	F_WaitForSpeech(gPlayer)
	PedSetActionNode(gPlayer, "/Global/6_02/Blank", "Act/Conv/6_02.act")
	PlayerSetControl(1)
	F_MakePlayerSafeForNIS(false)
	PedStop(gPlayer)
	gMissionStage = "passed"
end

function CB_PLAYEREND(ped, path, node)
	if node == PathGetLastNode(PATH._6_02_PLAYERRUN) then
		bPlayerReachedEnd = true
	end
end

function F_SetupFinalCops()
	local cop = PedCreatePoint(83, POINTLIST._6_02_CHASECOPS, 1)
	PedSetPedToTypeAttitude(cop, 3, 0)
	PedSetPedToTypeAttitude(cop, 13, 0)
	table.insert(gCops, cop)
	cop = PedCreatePoint(97, POINTLIST._6_02_CHASECOPS, 2)
	PedSetPedToTypeAttitude(cop, 3, 0)
	PedSetPedToTypeAttitude(cop, 13, 0)
	table.insert(gCops, cop)
	cop = PedCreatePoint(83, POINTLIST._6_02_OUTSIDECOPS, 3)
	PedSetPedToTypeAttitude(cop, 3, 0)
	PedSetPedToTypeAttitude(cop, 13, 0)
	table.insert(gCops, cop)
	local copCar
	copCar = VehicleCreatePoint(295, POINTLIST._6_02_OUTSIDECOPS, 1)
	VehicleEnableEngine(copCar, true)
	VehicleEnableSiren(copCar, true)
	PedWarpIntoCar(gCops[3], copCar)
	table.insert(gCopCars, copCar)
	cop = PedCreatePoint(97, POINTLIST._6_02_OUTSIDECOPS, 4)
	PedSetPedToTypeAttitude(cop, 3, 0)
	PedSetPedToTypeAttitude(cop, 13, 0)
	table.insert(gCops, cop)
	copCar = nil
	copCar = VehicleCreatePoint(295, POINTLIST._6_02_OUTSIDECOPS, 2)
	--print("Cop car: ", tostring(copCar))
	VehicleEnableEngine(copCar, true)
	VehicleEnableSiren(copCar, true)
	PedWarpIntoCar(gCops[4], copCar)
	table.insert(gCopCars, copCar)
end
