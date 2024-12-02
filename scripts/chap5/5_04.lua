ImportScript("Library/LibTable.lua")
ImportScript("Library/LibTrigger.lua")
ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibPed.lua")
ImportScript("Library/LibPropNew.lua")
local DO_MAX_HEALTH = 200
local DO_MODEL = 46
local GYM_TIME = 210
local gTimeForRespawn = 20
local gCurrentRespawn = GYM_TIME - gTimeForRespawn
local gCurrentRespawnedFires = 0
local gGymAlpha = 0
local gTargetGymAlpha = 0
local mission_started = false
local bAmbush01Peds, bAmbush02Peds, bAmbush03Peds, bAmbush04Peds, bAmbush05Peds = false
local bDOOnBike, bFirstStop, bSecondStop = false
local bFoundDO = false
local bTimer = false
idDO, idDOBike, idBlip, idBike = nil, nil, nil, nil
local idCurrentPath, idPrevModel1, idPrevModel2, idPrevModel3, idPrevModel4
local intNextChatTime = 0
local tblCopCars = {}
local tblDOModels = {
	44,
	42,
	41,
	43,
	45
}
local tblThreadFunctions = {}
local tblFires = {}
local gJocksFree = {
	false,
	false,
	false,
	false,
	false
}
local startnode = 0
local gObjs = {}
local gStageFunction = -1
local FIREDAMAGE = 40
local gMandyHealth, gCaseyHealth, gKirbyHealth = 0, 0, 0

function F_PutOnBike()
	--print("[RAUL] ===========><> F_PutOnBike <><============== ")
	PedClearAllWeapons(idDO)
	idCurrentPath = PATH._5_04_BIKE_ESCAPE_01
	PedClearObjectives(idDO)
	local x, y, z = PedGetPosXYZ(idDO)
	local timeout = GetTimer()
	if not PlayerIsInVehicle(idDOBike) then
		--print("PUTTING ON ORIGINAL BIKE ")
		PedEnterVehicle(idDO, idDOBike)
		while not PedIsInVehicle(idDO, idDOBike) do
			if GetTimer() - timeout > 5000 then
				break
			end
			Wait(0)
		end
	elseif PlayerIsInVehicle(idDOBike) then
		--print("PUTTING ON PlayerORIGINAL BIKE ")
		PedEnterVehicle(idDO, idBike)
		while not PedIsInVehicle(idDO, idBike) do
			if GetTimer() - timeout > 5000 then
				break
			end
			Wait(0)
		end
	end
	gGurneyIsOnBike = true
	bDOOnBike = true
	F_SetupDOFlee(startnode)
	SoundPlayScriptedSpeechEvent(idLittleBoy, "BIKE_STOLEN", 0, "jumbo")
	PedFlee(idLittleBoy, idDO)
	PedMakeAmbient(idLittleBoy)
	F_FirstCops()
	F_SecondCops()
end

function F_FirstStop()
	--print("[RAUL] ===========><> F_FirstStop <><============== ")
	PedStop(idDO)
	PedClearObjectives(idDO)
	if PedIsInAnyVehicle(idDO) then
		PedFleeOnPathOnBike(idDO, PATH._5_04_BIKE_ESCAPE_02, 0)
	else
		PedFollowPath(idDO, PATH._5_04_BIKE_ESCAPE_02, 0, 3)
	end
	idCurrentPath = PATH._5_04_BIKE_ESCAPE_02
end

function F_SecondStop()
	--print("[RAUL] ===========><> F_SecondStop <><============== ")
	PedStop(idDO)
	PedClearObjectives(idDO)
	if PedIsInAnyVehicle(idDO) then
		PedFleeOnPathOnBike(idDO, PATH._5_04_BIKE_ESCAPE_03, 0)
	else
		PedFollowPath(idDO, PATH._5_04_BIKE_ESCAPE_03, 0, 3)
	end
	idCurrentPath = PATH._5_04_BIKE_ESCAPE_03
end

function F_SetupDOFlee(startnode)
	--print("[RAUL] ===========><> F_SetupDOFlee <><============== ")
	--print("F_SetupDOFlee", idDO, idCurrentPath, startnode)
	if PedIsInAnyVehicle(idDO) then
		PedSetFocus(idDO, gPlayer)
		PedFleeOnPathOnBike(idDO, idCurrentPath, 0, startnode)
		PedLockTarget(idDO, gPlayer)
		lStat = {
			{ name = 33, value = 0 },
			{ name = 4,  value = 100 },
			{ name = 14, value = 100 },
			{ name = 9,  value = 100 },
			{ name = 30, value = 50 },
			{ name = 37, value = 100 },
			{ name = 24, value = 60 },
			{ name = 35, value = 63 },
			{ name = 6,  value = 0 },
			{ name = 26, value = 55 },
			{ name = 28, value = 1.0E-4 },
			{ name = 27, value = 10 },
			{ name = 29, value = 20 }
		}
		for i, stat in lStat do
			PedOverrideStat(idDO, stat.name, stat.value)
		end
	else
		PedFollowPath(idDO, idCurrentPath, 0, 3)
	end
	if not bAmbush01Peds then
		F_CreateFirstAmbushPeds()
	end
	--print("Finish F_SetupDOFlee")
end

function F_CreateFirstCops()
	--print("[RAUL] ===========><> F_CreateFirstCops <><============== ")
end

function F_FirstCops()
	--print("[RAUL] ===========><> F_FirstCops <><============== ")
	local idCar1 = VehicleCreatePoint(295, POINTLIST._5_04_COP_CAR_01)
	local idCar2 = VehicleCreatePoint(295, POINTLIST._5_04_COP_CAR_02)
	local idCar3 = VehicleCreatePoint(295, POINTLIST._5_04_COP_CAR_03)
	table.insert(tblCopCars, idCar1)
	table.insert(tblCopCars, idCar2)
	table.insert(tblCopCars, idCar3)
	collectgarbage()
end

function F_CreateSecondCops()
	--print("[RAUL] ===========><> F_CreateSecondCops <><============== ")
end

function F_SecondCops(tblParams)
	--print("[RAUL] ===========><> F_SecondCops <><============== ")
	local idCar1, idCar2, idCar3
	idCar1 = VehicleCreatePoint(295, POINTLIST._5_04_COP_CAR_04)
	idCar2 = VehicleCreatePoint(295, POINTLIST._5_04_COP_CAR_05)
	idCar3 = VehicleCreatePoint(295, POINTLIST._5_04_COP_CAR_06)
	table.insert(tblCopCars, idCar1)
	table.insert(tblCopCars, idCar2)
	table.insert(tblCopCars, idCar3)
	collectgarbage()
end

function F_CreateBikes(idPed, idBikePoint)
	--print("[RAUL] ===========><> F_CreateBikes <><============== ")
	--assert(idPed ~= nil, "5_04.lua: F_CreateBikes - ped id is nil")
	--assert(idBikePoint ~= nil, "5_04.lua: F_CreateBikes - bike point is nil")
	local idBike = VehicleCreatePoint(273, idBikePoint)
	L_PedSetData(idPed, "idBike", idBike)
	PedStop(idPed)
	PedEnterVehicle(idPed, idBike)
end

function F_GetDOModel()
	local idModel = RandomTableElement(tblDOModels)
	while idModel == nil or idModel == idPrevModel1 or idModel == idPrevModel2 or idModel == idPrevModel3 do
		idModel = RandomTableElement(tblDOModels)
	end
	idPrevModel3 = idPrevModel2
	idPrevModel2 = idPrevModel1
	idPrevModel1 = idModel
	return idModel
end

function F_CreateFirstAmbushPeds()
	--print(" CREATING FIRST AMBUSH PEDS ")
	L_PedLoadPoint("ambush01", {
		{
			id = nil,
			model = 42,
			point = POINTLIST._5_04_AMBUSH_01
		}
	})
	bAmbush01Peds = true
	Wait(100)
	L_PedExec("ambush01", PedFaceObject, "id", TRIGGER._5_04_DOOR_HACK, 0, 0)
	L_PedExec("ambush01", PedClearAllWeapons, "id")
end

function F_CleanupFirstAmbushPeds()
	if bAmbush01Peds then
		L_PedExec("ambush01", PedDelete, "id")
	end
end

function F_CreateSecondAmbushPeds()
	L_PedLoadPoint("ambush02", {
		{
			id = nil,
			model = F_GetDOModel(),
			point = POINTLIST._5_04_AMBUSH_05,
			bikePoint = POINTLIST._5_04_AMBUSH_05_BIKE,
			idBike = nil,
			state = 0,
			idPath = PATH._5_04_AMBUSH_02
		},
		{
			id = nil,
			model = F_GetDOModel(),
			point = POINTLIST._5_04_AMBUSH_06,
			bikePoint = POINTLIST._5_04_AMBUSH_06_BIKE,
			idBike = nil,
			state = 0,
			idPath = PATH._5_04_AMBUSH_02
		}
	})
	L_PedExec("ambush02", F_CreateBikes, "id", "bikePoint")
	L_PedExec("ambush02", PedClearAllWeapons, "id")
	bAmbush02Peds = true
end

function F_CleanupSecondAmbushPeds()
	if bAmbush02Peds then
		L_PedExec("ambush02", VehicleDelete, "idBike")
		L_PedExec("ambush02", PedDelete, "id")
	end
end

function F_SetupRanged(idPed)
	PedSetWeapon(idPed, 303, 50)
	PedOverrideStat(idPed, 14, 100)
	PedOverrideStat(idPed, 8, 25)
	PedOverrideStat(idPed, 7, 0)
	PedOverrideStat(idPed, 6, 0)
	PedOverrideStat(idPed, 10, 75)
	PedOverrideStat(idPed, 11, 100)
	PedOverrideStat(idPed, 3, 100)
end

function F_CreateThirdAmbushPeds()
	L_PedLoadPoint("ambush03", {
		{
			id = nil,
			model = F_GetDOModel(),
			point = POINTLIST._5_04_AMBUSH_07
		},
		{
			id = nil,
			model = F_GetDOModel(),
			point = POINTLIST._5_04_AMBUSH_08
		},
		{
			id = nil,
			model = F_GetDOModel(),
			point = POINTLIST._5_04_AMBUSH_09
		}
	})
	L_PedExec("ambush03", PedClearAllWeapons, "id")
	bAmbush03Peds = true
end

function F_CleanupThirdAmbushPeds()
	if bAmbush03Peds then
		L_PedExec("ambush03", PedDelete, "id")
	end
end

function F_CreateFourthAmbushPeds()
end

function F_CleanupFourthAmbushPeds()
end

function F_CreateFifthAmbushPeds()
	L_PedLoadPoint("ambush05", {
		{
			id = nil,
			model = F_GetDOModel(),
			point = POINTLIST._5_04_AMBUSH_14,
			bikePoint = POINTLIST._5_04_AMBUSH_14_BIKE,
			idBike = nil,
			state = 0,
			idPath = PATH._5_04_AMBUSH_05
		},
		{
			id = nil,
			model = F_GetDOModel(),
			point = POINTLIST._5_04_AMBUSH_15,
			bikePoint = POINTLIST._5_04_AMBUSH_15_BIKE,
			idBike = nil,
			state = 0,
			idPath = PATH._5_04_AMBUSH_05
		},
		{
			id = nil,
			model = F_GetDOModel(),
			point = POINTLIST._5_04_AMBUSH_16,
			bikePoint = POINTLIST._5_04_AMBUSH_16_BIKE,
			idBike = nil,
			state = 0,
			idPath = PATH._5_04_AMBUSH_05
		}
	})
	L_PedExec("ambush05", F_CreateBikes, "id", "bikePoint")
	L_PedExec("ambush05", PedClearAllWeapons, "id")
	bAmbush05Peds = true
end

function F_CleanupFifthAmbushPeds()
	if bAmbush05Peds then
		L_PedExec("ambush05", VehicleDelete, "idBike")
		L_PedExec("ambush05", PedDelete, "id")
	end
end

function F_FollowPath(idPed)
	L_PedSetData(idPed, "state", 2)
end

function F_Ambush01()
	--print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FALLING TREE !!!!")
	PAnimSetActionNode(TRIGGER._5_04_DOOR_HACK, "/Global/TreeFall/Damage/Fall", "Act/Props/TreeFall.act")
	L_PedExec("ambush01", PedSetActionNode, "id", "/Global/5_04/DOPush", "Act/Conv/5_04.act")
	SoundPlayScriptedSpeechEvent(L_PedGetIDByIndex("ambush01", 1), "M_5_04", 41, "large")
	F_CleanupCopCars()
	Wait(1000)
	L_PedExec("ambush01", PedFlee, "id", gPlayer)
	F_CreateSecondAmbushPeds()
end

function F_DOStop01()
	--print("[RAUL] ===========><> F_DOStop01 <><============== ")
	if PedGetHealth(idDO) / DO_MAX_HEALTH > 0.75 then
		SoundPlayScriptedSpeechEvent(idDO, "M_5_04", 40, "large")
	end
end

function F_Ambush02()
	--print(" AMBUSH 02 <><><><><><><<><><><<><> ")
	--print(" AMBUSH 02 <><><><><><><<><><><<><> ")
	--print(" AMBUSH 02 <><><><><><><<><><><<><> ")
	--print(" AMBUSH 02 <><><><><><><<><><><<><> ")
	if not bAmbush02Peds then
		F_CreateSecondAmbushPeds()
	end
	F_CleanupFirstAmbushPeds()
	F_SetupBikeFollow("ambush02")
	F_CreateThirdAmbushPeds()
end

function F_Ambush03()
	--print(" AMBUSH 03 <><><><><><><<><><><<><> ")
	--print(" AMBUSH 03 <><><><><><><<><><><<><> ")
	--print(" AMBUSH 03 <><><><><><><<><><><<><> ")
	--print(" AMBUSH 03 <><><><><><><<><><><<><> ")
	if not bAmbush03Peds then
		F_CreateThirdAmbushPeds()
	end
	SoundPlayScriptedSpeechEvent(idDO, "M_5_04", 40, "large")
	L_PedExec("ambush03", PedSetPedToTypeAttitude, "id", 13, 0)
	Wait(1000)
	L_PedExec("ambush03", PedAttackPlayer, "id")
end

function F_Ambush04()
	--print(" AMBUSH 04 <><><><><><><<><><><<><> ")
	--print(" AMBUSH 04 <><><><><><><<><><><<><> ")
	--print(" AMBUSH 04 <><><><><><><<><><><<><> ")
	--print(" AMBUSH 04 <><><><><><><<><><><<><> ")
	if not bAmbush04Peds then
		F_CreateFourthAmbushPeds()
	end
	F_CleanupThirdAmbushPeds()
end

function F_DOStop02()
	--print("[RAUL] ===========><> F_DOStop02 <><============== ")
	if PedGetHealth(idDO) / DO_MAX_HEALTH > 0.5 then
	end
end

function F_Ambush05()
end

function F_LastBattle()
	--print("[RAUL] ===========><> F_LastBattle <><============== ")
	PedStop(idDO)
	PedClearObjectives(idDO)
	if PedIsInAnyVehicle(idDO) then
		PedExitVehicle(idDO)
		Wait(500)
	end
	PedAttackPlayer(idDO, 3)
end

function F_SetupBikeFollow(strGroup)
	L_PedExec(strGroup, PedAttackPlayer, "id")
end

function F_DOChat()
	if not bFoundDO and GetTimer() >= intNextChatTime then
		intNextChatTime = GetTimer() + 8000 + math.random(0, 2000)
		SoundPlayScriptedSpeechEvent(idDO, "M_5_04", 31, "large")
	end
end

function F_DoPrevent2()
	if not gCanAccessBathrooms then
		PlayerSetControl(0)
		TextPrint("5_04_41", 2, 1)
		CameraSetWidescreen(true)
		Wait(2000)
		CameraFade(1000, 0)
		Wait(1000)
		local prx, pry, prz = GetPointList(POINTLIST._5_04_PREVENT_RETURN)
		PlayerSetPosSimple(prx, pry, prz)
		PlayerFaceHeadingNow(-92.90063)
		CameraReturnToPlayer()
		CameraReset()
		CameraFade(1000, 1)
		CameraSetWidescreen(false)
		PlayerSetControl(1)
	end
end

function F_DoPrevent()
	if not gCanAccessBathrooms then
		TextPrint("5_04_41", 4, 1)
	end
end

function F_DropoutCharge(pedId, pathId, pathNode)
	if pathNode == 5 then
		gDoChargeNow = true
	end
end

function F_Changeroom()
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	PedSetWeaponNow(gPlayer, -1, 0)
	if PlayerGetHealth() <= 30 then
		PlayerSetHealth(PlayerGetHealth() + 20)
	end
	if gObjs[5] then
		MissionObjectiveComplete(gObjs[5])
	end
	PedSetActionNode(idDO, "/Global/5_04/GurneyCrouchOut", "Act/Conv/5_04.act")
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	PedFollowPath(gPlayer, PATH._5_04_PLAYERCHARGED, 0, 0)
	PedSetInvulnerable(idDO, true)
	PedIgnoreStimuli(idDO, true)
	MissionTimerStop()
	Wait(1000)
	PedFollowPath(idDO, PATH._5_04_CHANGEROOMCHARGE, 0, 2, F_DropoutCharge)
	SoundPlayScriptedSpeechEvent(gPlayer, "M_5_04", 28, "large")
	bTimer = false
	while not gDoChargeNow do
		Wait(0)
	end
	PedFaceObject(idDO, gPlayer, 3, 0)
	Wait(50)
	PedSetActionNode(idDO, "/Global/5_04/RunShoulder", "Act/Conv/5_04.act")
	SoundPlayScriptedSpeechEvent(idDO, "M_5_04", 29, "large")
	PedSetInfiniteSprint(idDO, true)
	idBlip = AddBlipForChar(idDO, 3, 26, 4)
	Wait(1500)
	CameraFade(-1, 0)
	Wait(FADE_OUT_TIME)
	LoadAnimationGroup("Ambient3")
	PedStop(idDO)
	PedClearObjectives(idDO)
	PedSetPosPoint(idDO, POINTLIST._5_04_PREVENT_RETURN)
	CameraSetXYZ(-628.45233, -58.27194, 62.403015, -628.0733, -59.176186, 62.206657)
	SoundSetAudioFocusCamera()
	CameraAllowChange(false)
	CameraSetWidescreen(true)
	Wait(1000)
	SoundPlayStream("MS_BikeChaseHigh.rsm", 0.6)
	CameraFade(500, 1)
	Wait(500)
	SoundPlayScriptedSpeechEvent(idDO, "M_5_04", 45, "jumbo")
	PedFollowPath(idDO, PATH._5_04_DO_ESCAPE_GYM, 0, 3, CbDOEscape)
	AreaSetDoorLocked(TRIGGER._DT_GYM_DOORL, false)
	AreaSetDoorLocked(TRIGGER._DT_POOL_DOORL, false)
	AreaSetDoorLockedToPeds(TRIGGER._DT_GYM_DOORL, false)
	PedSetInvulnerable(idDO, false)
	PedIgnoreStimuli(idDO, false)
	Wait(4000)
	CameraFade(500, 0)
	Wait(500)
	SoundSetAudioFocusPlayer()
	CameraAllowChange(true)
	bFoundDO = true
	CameraSetWidescreen(false)
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	PlayerSetPosPoint(POINTLIST._5_04_INGYM_END)
	gTheMissionWasPassed = true
end

function F_ForceFlee(idPed)
	--print("[RAUL] ===========><> F_ForceFlee <><============== ")
	PedStop(idPed)
	PedClearObjectives(idPed)
	PedMakeAmbient(idPed)
	PedFlee(idPed, gPlayer)
end

function F_DOEscape()
end

function F_SetupTriggers()
	L_AddTrigger("triggers", {
		trigger1 = {
			trigger = TRIGGER._5_04_DO_NEAR_BIKE,
			OnEnter = F_PutOnBike,
			OnExit = nil,
			ped = idDO,
			bTriggerOnlyOnce = true
		},
		trigger2 = {
			trigger = TRIGGER._5_04_BIKE_STOP_01,
			OnEnter = F_FirstStop,
			OnExit = nil,
			ped = idDO,
			bTriggerOnlyOnce = true
		},
		trigger3 = {
			trigger = TRIGGER._5_04_BIKE_STOP_02,
			OnEnter = F_SecondStop,
			OnExit = nil,
			ped = idDO,
			bTriggerOnlyOnce = true
		},
		trigger4 = {
			trigger = TRIGGER._5_04_COP_START_01,
			OnEnter = F_CreateFirstCops,
			OnExit = nil,
			ped = idDO,
			bTriggerOnlyOnce = true
		},
		trigger5 = {
			trigger = TRIGGER._5_04_COP_START_02,
			OnEnter = F_CreateSecondCops,
			OnExit = nil,
			ped = idDO,
			bTriggerOnlyOnce = true
		},
		trigger6 = {
			trigger = TRIGGER._5_04_AMBUSH_01,
			OnEnter = F_Ambush01,
			OnExit = nil,
			ped = gPlayer,
			bTriggerOnlyOnce = true
		},
		trigger7 = {
			trigger = TRIGGER._5_04_AMBUSH_02,
			OnEnter = F_Ambush02,
			OnExit = nil,
			ped = gPlayer,
			bTriggerOnlyOnce = true
		},
		trigger8 = {
			trigger = TRIGGER._5_04_AMBUSH_03,
			OnEnter = F_Ambush03,
			OnExit = nil,
			ped = gPlayer,
			bTriggerOnlyOnce = true
		},
		trigger9 = {
			trigger = TRIGGER._5_04_AMBUSH_04,
			OnEnter = F_Ambush04,
			OnExit = nil,
			ped = gPlayer,
			bTriggerOnlyOnce = true
		},
		trigger10 = {
			trigger = TRIGGER._5_04_LASTAMBUSH,
			OnEnter = F_Ambush05,
			OnExit = nil,
			ped = idDO,
			bTriggerOnlyOnce = true
		},
		trigger11 = {
			trigger = TRIGGER._5_04_DO_STOP_01,
			OnEnter = F_DOStop01,
			OnExit = nil,
			ped = idDO,
			bTriggerOnlyOnce = true
		},
		trigger12 = {
			trigger = TRIGGER._5_04_AMBUSH_04,
			OnExit = F_DOStop02,
			ped = idDO,
			bTriggerOnlyOnce = true
		},
		trigger13 = {
			trigger = TRIGGER._5_04_CREATE_FOURTH_PEDS,
			OnEnter = F_CreateFourthAmbushPeds,
			ped = gPlayer,
			bTriggerOnlyOnce = true
		},
		trigger14 = {
			trigger = TRIGGER._5_04_DO_CHAT,
			InTrigger = F_DOChat,
			ped = gPlayer,
			bTriggerOnlyOnce = false
		},
		trigger15 = {
			trigger = TRIGGER._5_04_CHANGEROOM,
			OnEnter = F_Changeroom,
			ped = gPlayer,
			bTriggerOnlyOnce = true
		},
		trigger16 = {
			trigger = TRIGGER._5_04_DO_ESCAPE,
			OnEnter = F_DOEscape,
			ped = idDO,
			bTriggerOnlyOnce = true
		},
		trigger17 = {
			trigger = TRIGGER._5_04_PREVENT01,
			OnEnter = F_DoPrevent,
			OnExit = nil,
			ped = gPlayer,
			bTriggerOnlyOnce = false
		},
		trigger18 = {
			trigger = TRIGGER._5_04_PREVENT02,
			OnEnter = F_DoPrevent2,
			OnExit = nil,
			ped = gPlayer,
			bTriggerOnlyOnce = false
		},
		trigger19 = {
			trigger = TRIGGER._5_04_OTHERROUTE,
			OnEnter = F_OtherRoute,
			OnExit = nil,
			ped = gPlayer,
			bTriggerOnlyOnce = true
		}
	})
end

function F_CleanupPeds()
	if bAmbush01Peds then
		L_PedExec("ambush01", PedDelete, "id")
	end
	if bAmbush02Peds then
		L_PedExec("ambush02", PedDelete, "id")
	end
	if bAmbush03Peds then
		L_PedExec("ambush03", PedDelete, "id")
	end
	if bAmbush04Peds then
	end
	if bAmbush05Peds then
		L_PedExec("ambush05", PedDelete, "id")
	end
end

function F_CleanupCopCars()
	local i, idCar
	for i, idCar in tblCopCars do
		if idCar ~= nil and VehicleIsValid(idCar) then
			VehicleDelete(idCar)
		end
	end
end

function F_CleanupBikes()
	if idDOBike ~= nil and VehicleIsValid(idDOBike) then
		VehicleMakeAmbient(idDOBike)
		idDOBike = nil
	end
	if idBike ~= nil and VehicleIsValid(idBike) and not PedIsInVehicle(gPlayer, idBike) then
		VehicleMakeAmbient(idBike)
		idBike = nil
	end
end

function F_BikeAI(idPed, idBike, intState, idPath)
	--print("[RAUL] ===========><> F_BikeAI <><============== ")
	if intState == 0 then
		if VehicleIsValid(idBike) and not PedIsInVehicle(idPed, idBike) then
			PedClearObjectives(idPed)
			PedEnterVehicle(idPed, idBike)
		else
			L_PedSetData(idPed, "state", 1)
		end
	elseif intState == 1 then
		PedStop(idPed)
	elseif intState ~= 2 or VehicleIsValid(idBike) and PedIsInVehicle(idPed, idBike) then
	else
		PedStop(idPed)
	end
end

function F_MonitorDO()
	local fHealthThreshold = 0
	local x, y, z
	local bExitingVehicle = false
	local bSetupFlee = false
	local ax, ay, az = GetPointList(POINTLIST._5_04_ANGRY_JOCKS_01)
	while mission_started do
		if not gLastStand and PedIsValid(idDO) and PedIsInTrigger(idDO, TRIGGER._5_04_DO_GOAL) then
			F_LastBattle()
			gLastStand = true
		end
		Wait(100)
		if not gGurneyIsOnBike then
			if gTookOtherRoute then
				PedSetActionNode(idDO, "/Global/5_04/JockIdle", "Act/Conv/5_04.act")
				gTookOtherRoute = false
			elseif not gThrowMarbles then
				if DistanceBetweenPeds2D(gPlayer, idDO) > 50 then
					gThrowMarbles = true
					TextPrint("5_04_05", 4, 1)
				end
			else
				if DistanceBetweenPeds2D(gPlayer, idDO) > 65 then
					gMissionFailed = true
					gMissionFailedMessage = "5_04_06"
				end
				if DistanceBetweenPeds2D(gPlayer, idDO) <= 50 then
					gGurneyIsTired = nil
					gThrowMarbles = false
				end
			end
		elseif not PedIsDead(idDO) and DistanceBetweenPeds2D(gPlayer, idDO) > 75 then
			gMissionFailed = true
			gMissionFailedMessage = "5_04_06"
		elseif not PedIsDead(idDO) and DistanceBetweenPeds2D(gPlayer, idDO) > 55 then
			TextPrint("5_04_05", 4, 1)
		end
		if not gAngryJocks and PlayerIsInAreaXYZ(ax, ay, az, 10, 0) then
			gAngryJocks = true
			SoundPlayScriptedSpeechEvent(gAngryJock01, "M_5_04", 33, "large")
			PedOverrideStat(gAngryJock01, 10, 100)
			PedPassBall(gAngryJock01, gPlayer, 3000)
			AddBlipForChar(gAngryJock02, 2, 2, 1)
			AddBlipForChar(gAngryJock01, 2, 2, 1)
			PedMakeAmbient(gAngryJock02)
			PedMakeAmbient(gAngryJock01)
			Wait(100)
			PedAttackPlayer(gAngryJock02)
			Wait(500)
			PedAttackPlayer(gAngryJock01)
			Wait(500)
			SoundPlayScriptedSpeechEvent(gAngryJock02, "M_5_04", 35, "large")
		end
	end
end

function F_MonitorBikePeds()
	while mission_started do
		if bAmbush02Peds then
			L_PedExec("ambush02", F_BikeAI, "id", "idBike", "state", "idPath")
		end
		if bAmbush05Peds then
			L_PedExec("ambush05", F_BikeAI, "id", "idBike", "state", "idPath")
		end
		Wait(100)
	end
end

function F_MonitorHealth()
	if PlayerGetHealth() <= 0 then
		return true
	end
	return false
end

function F_MonitorAlpha()
	while bTimer do
		if gTargetGymAlpha < gGymAlpha then
			gGymAlpha = gGymAlpha - 0.01
			if gGymAlpha < 0 then
				gTargetGymAlpha = 0
				gGymAlpha = 0
			end
			if gGymAlpha == 0 then
				EffectSetGymnFireOn(false)
				gEffectOff = true
			end
			EffectSetGymnFireAlpha(gGymAlpha)
		elseif gTargetGymAlpha > gGymAlpha then
			gGymAlpha = gGymAlpha + 0.01
			if 1 < gGymAlpha then
				gTargetGymAlpha = 1
				gGymAlpha = 1
			end
			if gEffectOff then
				EffectSetGymnFireOn(true)
				gEffectOff = false
			end
			EffectSetGymnFireAlpha(gGymAlpha)
		end
		Wait(0)
	end
end

function F_AttackerFlee()
	if bAmbush01Peds then
		L_PedExec("ambush01", F_PedFlee, "id")
	end
	if bAmbush04Peds then
	end
end

function F_PedFlee(idPed)
	PedIgnoreAttacks(idPed, true)
	PedOverrideStat(idPed, 6, 100)
	PedOverrideStat(idPed, 7, 100)
end

function F_FailMission()
	shared.gGymHasBurnt = false
	gMissionFailed = true
end

function F_CopsArrived()
	PlayerSetControl(0)
	PedSetActionNode(gPlayer, "/Global/5_04/Idle", "Act/Conv/5_04.act")
	CameraFade(-1, 0)
	Wait(FADE_OUT_TIME)
	LoadModels({
		83,
		97,
		82
	})
	cop1 = PedCreatePoint(83, POINTLIST._5_04_COP_END, 1)
	cop2 = PedCreatePoint(97, POINTLIST._5_04_COP_END, 2)
	cop3 = PedCreatePoint(82, POINTLIST._5_04_COP_END, 3)
	PedFaceObject(cop3, gPlayer, 2, 1)
	CameraSetWidescreen(true)
	CameraSetPath(PATH._5_04_JOCK_CAM, true)
	CameraLookAtObject(cop1, 2, true)
	CameraFade(1000, 1)
	Wait(1000)
	Wait(2000)
	gMissionFailed = true
	gMissionFailedMessage = "5_04_04"
	gCopsArrived = true
end

function F_CompleteMission()
	PedMakeAmbient(idDO)
	PlayerSetPunishmentPoints(0)
	if bAmbush01Peds then
		L_PedExec("ambush01", F_ForceFlee, "id")
	end
	if bAmbush02Peds then
		L_PedExec("ambush02", F_ForceFlee, "id")
	end
	if bAmbush03Peds then
		L_PedExec("ambush03", F_ForceFlee, "id")
	end
	if bAmbush05Peds then
		L_PedExec("ambush05", F_ForceFlee, "id")
	end
	PlayerSetControl(1)
	gTheMissionWasPassed = true
	mission_started = false
end

function F_LeaveGym()
	if not bFoundDO and AreaGetVisible() ~= 13 then
		return true
	end
	return false
end

function F_DefeatDO()
	if idDO ~= nil and PedGetHealth(idDO) <= 0 then
		if bTimer then
			MissionTimerStop()
			bTimer = false
		end
		return true
	end
	return false
end

function F_ReachedGoal()
	if idDO ~= nil and PedIsInTrigger(idDO, TRIGGER._5_04_DO_GOAL) then
		return true
	end
	return false
end

function F_JocksFree()
	if not gJock01Free and gJocksFree[1] then
		gJock01Free = true
		local a = L_PedGetIDByIndex("gymjocks", 2)
		BlipRemove(gMandyBlip)
		PedSetActionNode(a, "/Global/5_04/MandyStand", "Act/Conv/5_04.act")
		Wait(1500)
		SoundPlayScriptedSpeechEvent(a, "M_5_04", 18, "large")
		local waitForMandyEnd = true
		while waitForMandyEnd do
			if not PedIsPlaying(a, "/Global/5_04/MandyStand", true) then
				waitForMandyEnd = false
			end
			Wait(0)
		end
		PedClearObjectives(a)
		PedStop(a)
		PedFollowPath(a, PATH._5_04_JOCKPATH01, 0, 1, CbMandyPath)
		F_ResetJock(a)
	end
	if not gJock02Free and gJocksFree[2] and gJocksFree[3] then
		gJock02Free = true
		--print("in JOCK 02 FREE")
		local a = L_PedGetIDByIndex("gymjocks", 1)
		SoundPlayAmbientSpeechEvent(a, "VICTIMIZED")
		PAnimSetActionNode(TRIGGER._5_04_GYMWALL, "/Global/GymWLad/Damage/Fall/OnGround/Useable", "Act/Props/GymWLad.act")
		Wait(100)
		gWallCoronaActive = true
		gWallCorona = BlipAddXYZ(-615.174, -65.5818, 59.6611, 0, 0, 7)
		Wait(100)
		--print("JOCK 02 FREE")
	end
	if not gJock03Free and gJocksFree[4] then
		gJock03Free = true
		local a = L_PedGetIDByIndex("gymjocks", 3)
		PedSetActionNode(a, "/Global/5_04/JockIdle", "Act/Conv/5_04.act")
		SoundPlayScriptedSpeechEvent(a, "M_5_04", 16, "large")
		Wait(100)
		PedClearObjectives(a)
		PedStop(a)
		BlipRemove(gCaseyBlip)
		PedFollowPath(a, PATH._5_04_JOCKPATH03, 0, 1, CbJock01Path)
		F_ResetJock(a)
	end
end

function F_JockConv()
	gMandyArrived = false
	local mandy = L_PedGetIDByIndex("gymjocks", 2)
	local time = 45
	MissionObjectiveComplete(gObjs[2])
	MissionObjectiveComplete(gObjs[3])
	local x, y, z = PedGetPosXYZ(mandy)
	CameraFade(500, 0)
	MissionTimerStop()
	PlayerSetControl(0)
	SoundDisableSpeech_ActionTree()
	Wait(500)
	CameraSetWidescreen(true)
	F_MakePlayerSafeForNIS(true)
	PedStop(mandy)
	PedClearObjectives(mandy)
	Wait(100)
	local x, y, z = GetPointList(POINTLIST._5_04_PLAYERMANDYCONV)
	PedSetPosXYZ(gPlayer, x, y, z)
	PedSetActionNode(gPlayer, "/Global/5_04/Idle", "Act/Conv/5_04.act")
	PedSetPosPoint(mandy, POINTLIST._5_04_PLAYERMANDYCONV, 2)
	PedStop(gPlayer)
	Wait(500)
	PedFaceObject(gPlayer, mandy, 2, 0)
	PedFaceObject(mandy, gPlayer, 3, 1, false)
	LoadModels({
		44,
		42,
		41,
		43,
		45,
		295,
		273,
		282,
		69,
		15,
		18
	})
	LoadAnimationGroup("NIS_5_04")
	CameraFade(500, 1)
	Wait(300)
	PedSetActionTree(mandy, "/Global/GS_Female_A", "Act/Anim/GS_Female_A.act")
	SoundStopCurrentSpeechEvent(mandy)
	CameraSetXYZ(-628.93585, -73.33503, 60.9616, -627.9413, -73.279175, 60.875393)
	PedSetActionNode(mandy, "/Global/5_04/Talking/MandyTalk", "Act/Conv/5_04.act")
	F_PlaySpeechAndWait(mandy, "M_5_04", 22, "large")
	CameraSetXYZ(-626.96924, -74.67165, 60.975555, -626.9247, -73.67498, 60.910103)
	F_PlaySpeechAndWait(gPlayer, "M_5_04", 23, "large")
	CameraSetXYZ(-628.93585, -73.33503, 60.9616, -627.9413, -73.279175, 60.875393)
	PedSetActionNode(mandy, "/Global/5_04/Talking/MandyTalk02", "Act/Conv/5_04.act")
	F_PlaySpeechAndWait(mandy, "M_5_04", 24, "large")
	CameraSetXYZ(-626.9549, -74.064255, 60.868847, -627.17303, -73.08873, 60.868923)
	F_PlaySpeechAndWait(gPlayer, "M_5_04", 25, "large")
	CameraSetXYZ(-627.838, -73.04977, 60.829853, -626.97156, -73.53872, 60.92742)
	PedSetActionNode(mandy, "/Global/5_04/Talking/MandyTalk03", "Act/Conv/5_04.act")
	F_PlaySpeechAndWait(mandy, "M_5_04", 26, "large")
	CameraFade(500, 0)
	UnLoadAnimationGroup("NIS_5_04")
	Wait(500)
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
	CameraReset()
	F_MakePlayerSafeForNIS(false)
	PedSetActionNode(mandy, "/Global/5_04/Idle", "Act/Conv/5_04.act")
	PedFollowPath(mandy, PATH._5_04_BURTON_OUT, 0, 1, CbBurtonOut)
	CameraFade(500, 1)
	SoundEnableSpeech_ActionTree()
	PlayerSetControl(1)
	gObjs[5] = MissionObjectiveAdd("5_04_12")
	TextPrint("5_04_12", 4, 1)
	Wait(1000)
	gCanAccessBathrooms = true
	gCheckForExtinguisher = false
	MissionTimerStart(time)
end

function F_TimerFinished()
	if bTimer and MissionTimerHasFinished() then
		MissionTimerStop()
		return true
	end
	return false
end

function F_Setup()
	local x, y, z = GetPointList(POINTLIST._5_04_BURTON)
	if not PlayerIsInAreaXYZ(x, y, z, 15, 0) then
		AreaTransitionPoint(0, POINTLIST._5_04_BURTON, nil, true)
	end
end

function F_SetupProps()
	L_PropLoad("barricades", {
		prop8 = {
			id = TRIGGER._5_04_DOOR_HACK
		},
		prop9 = {
			id = TRIGGER._5_04_BANNERS_01,
			bGenerateObstacle = false
		},
		prop10 = {
			id = TRIGGER._5_04_BANNERS_02,
			bGenerateObstacle = false
		},
		prop11 = {
			id = TRIGGER._5_04_BANNERS_03,
			bGenerateObstacle = false
		},
		prop12 = {
			id = TRIGGER._5_04_BANNERS_04,
			bGenerateObstacle = false
		},
		prop13 = {
			id = TRIGGER._5_04_BANNERS_05,
			bGenerateObstacle = false
		},
		prop14 = {
			id = TRIGGER._5_04_BANNERS_06,
			bGenerateObstacle = false
		},
		prop15 = {
			id = TRIGGER._5_04_BANNERS_07,
			bGenerateObstacle = false
		},
		prop16 = {
			id = TRIGGER._5_04_BANNERS_08,
			bGenerateObstacle = false
		},
		prop17 = {
			id = TRIGGER._5_04_BANNERS_09,
			bGenerateObstacle = false
		},
		prop18 = {
			id = TRIGGER._5_04_BANNERS_10,
			bGenerateObstacle = false
		},
		prop19 = {
			id = TRIGGER._5_04_BANNERS_11,
			bGenerateObstacle = false
		},
		prop20 = {
			id = TRIGGER._5_04_BANNERS_12,
			bGenerateObstacle = false
		},
		prop21 = {
			id = TRIGGER._5_04_BANNERS_13,
			bGenerateObstacle = false
		},
		prop23 = {
			id = TRIGGER._5_04_LIGHT_01,
			bGenerateObstacle = false
		},
		prop24 = {
			id = TRIGGER._5_04_LIGHT_02,
			bGenerateObstacle = false
		},
		prop25 = {
			id = TRIGGER._5_04_LIGHT_03,
			bGenerateObstacle = false
		},
		prop26 = {
			id = TRIGGER._5_04_LIGHT_04,
			bGenerateObstacle = false
		},
		prop27 = {
			id = TRIGGER._5_04_GYMHOOP,
			bGenerateObstacle = false
		},
		prop28 = {
			id = TRIGGER._5_04_GYMWALL,
			bGenerateObstacle = false
		}
	})
end

function F_SetupFires()
	local i, tblEntry
	tblFires = {
		{
			idFire = nil,
			trigger = TRIGGER._5_04_BANNERS_02,
			canHaveSmoke = true,
			idSmoke = nil,
			idFX = nil,
			fireAlive = false,
			blipId = nil
		},
		{
			idFire = nil,
			trigger = TRIGGER._5_04_BANNERS_07,
			canHaveSmoke = false,
			idSmoke = nil,
			idFX = nil,
			fireAlive = false,
			blipId = nil
		},
		{
			idFire = nil,
			trigger = TRIGGER._5_04_BANNERS_08,
			canHaveSmoke = true,
			idSmoke = nil,
			idFX = nil,
			fireAlive = false,
			blipId = nil
		},
		{
			idFire = nil,
			trigger = TRIGGER._5_04_BANNERS_10,
			canHaveSmoke = true,
			idSmoke = nil,
			idFX = nil,
			fireAlive = false,
			blipId = nil
		},
		{
			idFire = nil,
			trigger = TRIGGER._5_04_BANNERS_11,
			canHaveSmoke = false,
			idSmoke = nil,
			idFX = nil,
			fireAlive = false,
			blipId = nil
		},
		{
			idFire = nil,
			trigger = TRIGGER._5_04_BANNERS_12,
			canHaveSmoke = true,
			idSmoke = nil,
			idFX = nil,
			fireAlive = false,
			blipId = nil
		}
	}
	local randInt = 0
	local fxCreated = 0
	for i, tblEntry in tblFires do
		if tblEntry.trigger ~= nil then
			gTargetGymAlpha = gTargetGymAlpha + 0.1
			tblEntry.idFire = FireCreate(tblEntry.trigger, 1000, FIREDAMAGE, 100, 115, "GymFire")
			tblEntry.fireAlive = true
			FireSetScale(tblEntry.idFire, 1)
			FireSetDamageRadius(tblEntry.idFire, 1)
			PAnimHideHealthBar(tblEntry.trigger)
			local bx, by, bz = GetAnchorPosition(tblEntry.trigger)
		end
	end
	--print("The total alpha after the creation is: ", gTargetGymAlpha)
	gGymAlpha = gTargetGymAlpha
	EffectSetGymnFireAlpha(gGymAlpha)
end

function F_CleanupFires()
	local i, tblEntry
	for i, tblEntry in tblFires do
		if tblEntry.idFire ~= nil then
			FireDestroy(tblEntry.idFire)
			if tblEntry.idFX then
				EffectKill(tblEntry.idFX)
			end
			tblEntry.idFire = nil
		end
		if tblEntry.idSmoke then
			EffectKill(tblEntry.idSmoke)
		end
	end
end

function F_FiresOut()
	local i, tblEntry
	local allFiresOut = true
	local xf, yf, zf
	for i, tblEntry in tblFires do
		if tblEntry.idFire ~= nil and tblEntry.fireAlive then
			if FireGetHealth(tblEntry.idFire) > 0 then
				allFiresOut = false
			else
				tblEntry.fireAlive = false
				gTargetGymAlpha = gGymAlpha - 0.1
				--print(" PUT OUT A FIRE <<<<<<<<<<<<<<<<<<<<<<<<<<< alpha = ", gGymAlpha)
				if tblEntry.trigger == TRIGGER._5_04_BANNERS_07 then
					gJocksFree[1] = true
				elseif tblEntry.trigger == TRIGGER._5_04_BANNERS_02 then
					gJocksFree[2] = true
				elseif tblEntry.trigger == TRIGGER._5_04_BANNERS_11 then
					gJocksFree[3] = true
				elseif tblEntry.trigger == TRIGGER._5_04_BANNERS_03 then
					gJocksFree[4] = true
				elseif tblEntry.trigger == TRIGGER._5_04_BANNERS_06 then
					gJocksFree[5] = true
				end
				xf, yf, zf = GetAnchorPosition(tblEntry.trigger)
				if tblEntry.canHaveSmoke then
					tblEntry.idSmoke = EffectCreate("SmokeStackLRG", xf, yf, zf)
				end
				--print("Before JOCKS FREE")
				F_JocksFree()
				--print("After JOCKS FREE")
				if tblEntry.idFX then
					EffectKill(tblEntry.idFX)
					tblEntry.idFX = nil
				end
				--print(" FINISHED PUTTING OUT A FIRE <<<<<<<<<<<<<<<<<<<<<<<<<<< alpha = ", gGymAlpha)
			end
		else
		end
	end
	if allFiresOut then
		if gCaseyFree and gKirbyFree then
			gTargetGymAlpha = 0
			return true
		else
			if not gCaseyObjective then
				MissionObjectiveComplete(gObjs[2])
				gCaseyObjective = true
			end
			return false
		end
	else
		if not gRestateMission and gJock01Free and gJock02Free and gJock03Free then
			MissionObjectiveComplete(gObjs[3])
			gRestateMission = true
		end
		return false
	end
end

function F_Intro()
	local bSkipIntro = false
	DoublePedShadowDistance(true)
	CameraSetWidescreen(true)
	CameraSetPath(PATH._5_04_JOCK_CAM, true)
	PedSetActionNode(gPlayer, "/Global/5_04/Idle", "Act/Conv/5_04.act")
	CameraLookAtObject(L_PedGetIDByIndex("gymjocks", 1), 2, true)
	F_MakePlayerSafeForNIS(true)
	CameraFade(1000, 1)
	Wait(1500)
	local a = L_PedGetIDByIndex("gymjocks", 1)
	PedSetActionNode(a, "/Global/5_04/KirbyInit", "Act/Conv/5_04.act")
	SoundPlayScriptedSpeechEvent(a, "M_4_04", 51, "large")
	Wait(2000)
	SoundPlayAmbientSpeechEvent(a, "DEFEAT_INDIVIDUAL")
	Wait(1400)
	F_PlaySpeechAndWait(a, "M_5_04", 3, "large")
	PedSetActionNode(a, "/Global/5_04/JockIdle", "Act/Conv/5_04.act")
	PAnimSetActionNode(TRIGGER._5_04_GYMWALL, "/Global/GymWLad/Damage/Fall", "Act/Props/GymWLad.act")
	Wait(150)
	PedMoveToXYZ(a, 1, -614.011, -63.813, 59.6573)
	Wait(100)
	PedSetEffectedByGravity(a, false)
	Wait(10)
	Wait(550)
	PedFaceHeading(a, 90, 0)
	PedSetActionNode(a, "/Global/5_04/KirbyFall", "Act/Conv/5_04.act")
	F_PlaySpeechAndWait(a, "M_5_04", 2, "large")
	CameraSetWidescreen(false)
	F_MakePlayerSafeForNIS(false)
	DoublePedShadowDistance(false)
	CameraReturnToPlayer()
end

function F_ResetJock(id)
	PedIgnoreStimuli(id, false)
	PedIgnoreAttacks(id, false)
	PedSetInvulnerable(id, false)
	PedMakeTargetable(id, true)
	PedSetMissionCritical(id, true, CbPlayerAggressed, true)
end

function CbPlayerAggressed(id)
	--print("PLAYER HAS AGGRESSED !!!!")
	if PedIsValid(id) and PedGetHealth(id) <= 145 or not PedIsValid(id) then
		--print("PLAYER HAS AGGRESSED BADLY!!!!")
		gMissionFailed = true
		gMissionFailedMessage = "5_04_07"
	end
end

function F_CreatePeds()
	local idJock1, idJock2, idJock3
	gCreatedTheJocks = true
	idDO = PedCreatePoint(DO_MODEL, POINTLIST._5_04_GYM_DOSTART)
	PedSetActionNode(idDO, "/Global/5_04/GurneyKneel", "Act/Conv/5_04.act")
	PedStop(idDO)
	L_PedLoadPoint("gymjocks", {
		{
			id = nil,
			model = 13,
			point = POINTLIST._5_04_GYM_JOCK_01,
			girl = false
		},
		{
			id = nil,
			model = 14,
			point = POINTLIST._5_04_GYM_JOCK_02,
			girl = true
		},
		{
			id = nil,
			model = 20,
			point = POINTLIST._5_04_GYM_JOCK_03,
			girl = false
		}
	})
	L_PedExec("gymjocks", PedIgnoreStimuli, "id", true)
	L_PedExec("gymjocks", PedIgnoreAttacks, "id", true)
	L_PedExec("gymjocks", PedClearAllWeapons, "id")
	L_PedExec("gymjocks", PedSetInvulnerable, "id", true)
	L_PedExec("gymjocks", PedMakeTargetable, "id", false)
	L_PedExec("gymjocks", PedSetPedToTypeAttitude, "id", 13, 4)
	L_PedExec("gymjocks", PedSetHealth, "id", 150)
	L_PedExec("gymjocks", PedSetFlag, "id", 111, false)
	Wait(100)
	local a, b, c = L_PedGetIDByIndex("gymjocks", 1), L_PedGetIDByIndex("gymjocks", 2), L_PedGetIDByIndex("gymjocks", 3)
	--print(" JOCKS ", a, b, c)
	PedSetActionNode(a, "/Global/5_04/Coughing", "Act/Conv/5_04.act")
	Wait(200)
	PedSetActionNode(b, "/Global/5_04/Coughing/CoughingMandy", "Act/Conv/5_04.act")
	Wait(150)
	PedSetActionNode(c, "/Global/5_04/Coughing/CoughingCasey", "Act/Conv/5_04.act")
end

function F_DropLamp(lampNo)
	if lampNo == 1 then
		gLampId = TRIGGER._5_04_LIGHT_01
	elseif lampNo == 2 then
		gLampId = TRIGGER._5_04_LIGHT_02
	elseif lampNo == 3 then
		gLampId = TRIGGER._5_04_LIGHT_03
	elseif lampNo == 4 then
		gLampId = TRIGGER._5_04_LIGHT_04
	end
	PAnimSetActionNode(gLampId, "/Global/AGymLght/Damage/Fall", "Act/Props/AGymLght.act")
	gFallenLamp = true
end

function F_DestroyLamp()
	if gLampId then
		local tx, ty, tz = GetAnchorPosition(gLampId)
		EffectCreate("GymLightSmash", tx, ty, tz)
		gDestroyLamp = gLampId
		gLampId = nil
	end
end

function F_FinishedGymWall()
	if not wallOnce then
		gFinishedGymWall = true
		wallOnce = true
	end
end

function F_FinishedGymHoop()
	if not hoopOnce then
		gFinishedGymHoop = true
		hoopOnce = true
	end
end

function F_OtherRoute()
	--print(" OTHER ROUTE ")
	--print(" OTHER ROUTE ")
	--print(" OTHER ROUTE ")
	--print(" OTHER ROUTE ")
	--print(" OTHER ROUTE ")
	--print(" OTHER ROUTE ")
	gTookOtherRoute = true
end

function CbDOEscape(pedId, pathId, pathNode)
	if pathNode == 7 then
		gDOArrived = pedId
	end
end

function CbBurtonOut(pedId, pathId, pathNode)
	if pathNode == 1 then
		gJockArrived = pedId
	end
end

function CbMandyPath(pedId, pathId, pathNode)
	if pathNode == 7 then
		gMandyArrived = pedId
		PedFaceObject(pedId, gPlayer, 3, 1)
	end
end

function CbJock01Path(pedId, pathId, pathNode)
	--print(" PATHNODE FOR JOCK ", pathNode)
	if pathNode == 7 then
		--print(" ARRIVED ", pathNode)
		gJockArrived = pedId
	end
end

function MissionSetup()
	MissionDontFadeIn()
	DATLoad("5_04.DAT", 2)
	DATInit()
end

function MissionCleanup()
	CameraSetWidescreen(false)
	mission_started = false
	gCheckForExtinguisher = false
	if not returnedCamera then
		CameraReset()
		CameraReturnToPlayer()
	end
	VehicleRevertToDefaultAmbient()
	AreaRevertToDefaultPopulation()
	EffectSetGymnFireOn(false)
	PedSetFlag(gPlayer, 109, false)
	F_MakePlayerSafeForNIS(false)
	F_CleanupFires()
	F_CleanupBikes()
	F_CleanupPeds()
	F_CleanupSmokes()
	if not gTheMissionWasPassed then
		shared.gGymHasBurnt = false
	end
	if idBlip ~= nil then
		BlipRemove(idBlip)
	end
	if bTimer then
		MissionTimerStop()
		bTimer = false
	end
	if AreaGetVisible() == 13 then
		if PAnimExists(TRIGGER._DT_GYM_DOORL) then
			AreaSetDoorLocked(TRIGGER._DT_GYM_DOORL, false)
		end
		if PAnimExists(TRIGGER._DT_POOL_DOORL) then
			AreaSetDoorLocked(TRIGGER._DT_POOL_DOORL, false)
		end
	end
	SoundFadeoutStream()
	SoundStopInteractiveStream()
	PlayerSetControl(1)
	UnLoadAnimationGroup("2_S04CharSheets")
	UnLoadAnimationGroup("MINICHEM")
	UnLoadAnimationGroup("1_03The Setup")
	UnLoadAnimationGroup("F_Nerds")
	UnLoadAnimationGroup("GEN_Social")
	UnLoadAnimationGroup("Area_Asylum")
	UnLoadAnimationGroup("F_Adult")
	UnLoadAnimationGroup("Ambient3")
	DATUnload(2)
end

function F_SetupSmokes()
	gSmokesTable = {}
	local x, y, z = 0, 0, 0
	for i = 1, 6 do
		--print("CREATING SMOKE", i)
		x, y, z = GetPointFromPointList(POINTLIST._5_04_OUTSIDESMOKE, i)
		gSmokesTable[i] = EffectCreate("SmokeStackLRG", x, y, z)
		gSmokesTable[i] = EffectCreate("GymFire", x, y, z)
	end
end

function F_CleanupSmokes()
	for i, smoke in gSmokesTable do
		EffectKill(smoke)
	end
end

function main()
	F_Setup()
	F_SetupSmokes()
	PlayCutsceneWithLoad("5-04", true)
	WeaponRequestModel(303)
	WeaponRequestModel(310)
	WeaponRequestModel(311)
	WeaponRequestModel(346)
	WeaponRequestModel(349)
	WeaponRequestModel(331)
	WeaponRequestModel(326)
	shared.gGymHasBurnt = true
	L_ObjectiveSetParam({
		objDiscoverDO = {
			failureConditions = { F_LeaveGym },
			stopOnFailed = true,
			failActions = { F_FailMission }
		},
		objPutOutFires = {
			successConditions = { F_FiresOut },
			stopOnCompleted = false,
			completeActions = { F_JockConv }
		},
		objTimer = {
			failureConditions = { F_TimerFinished },
			stopOnFailed = true,
			failActions = { F_CopsArrived }
		},
		objDefeatDO = {
			successConditions = { F_DefeatDO },
			stopOnCompleted = true,
			completeActions = { F_CompleteMission }
		}
	})
	GeometryInstance("PGymLights", true, -619.172, -63.31, 68.9731, false)
	GeometryInstance("PGymLights", true, -624.326, -48.2877, 68.9731, false)
	GeometryInstance("PGymLights", true, -624.326, -71.013, 68.9731, false)
	GeometryInstance("PGymLights", true, -614.133, -48.2877, 68.9731, false)
	mission_started = true
	if mission_started then
		F_Stage01InTheGymSetup()
		while mission_started do
			gStageFunction()
			if gDestroyLamp then
				PAnimDelete(gDestroyLamp)
				gDestroyLamp = nil
			end
			if gMissionFailed then
				PlayerSetControl(0)
				F_MakePlayerSafeForNIS(true, false)
				mission_started = false
				SoundPlayMissionEndMusic(false, 8)
				if gMissionFailedMessage then
					MinigameSetCompletion("M_FAIL", false, 0, gMissionFailedMessage)
				else
					MinigameSetCompletion("M_FAIL", false)
				end
				while MinigameIsShowingCompletion() do
					Wait(0)
				end
				if PAnimExists(TRIGGER._DT_GYM_DOORL) then
					AreaSetDoorLocked(TRIGGER._DT_GYM_DOORL, false)
				end
				if PAnimExists(TRIGGER._DT_POOL_DOORL) then
					AreaSetDoorLocked(TRIGGER._DT_POOL_DOORL, false)
				end
				CameraFade(-1, 0)
				Wait(FADE_OUT_TIME)
				EffectSetGymnFireOn(false)
				CameraReset()
				CameraReturnToPlayer()
				AreaTransitionPoint(0, POINTLIST._5_04_PSTART_TEST)
				F_MakePlayerSafeForNIS(false)
				MissionFail(false, false)
			end
			if gTheMissionWasPassed then
				mission_started = false
			end
			Wait(0)
		end
		L_StopMonitoringTriggers()
		if gTheMissionWasPassed then
			mission_started = false
			CameraSetWidescreen(true)
			CameraSetXYZ(-647.9261, -59.289787, 56.57997, -648.6833, -58.6377, 56.54336)
			CameraFade(-1, 1)
			Wait(500)
			PedSetActionNode(gPlayer, "/Global/5_04/PlayerScratch", "Act/Conv/5_04.act")
			MinigameSetCompletion("M_PASS", true, 3000)
			MinigameAddCompletionMsg("MRESPECT_JP15", 2)
			SoundPlayMissionEndMusic(true, 8)
			SetFactionRespect(2, GetFactionRespect(2) + 15)
			while MinigameIsShowingCompletion() do
				Wait(0)
			end
			PlayerSetPunishmentPoints(0)
			MissionSucceed(false, false, false)
			CameraSetXYZ(-647.9261, -59.289787, 56.57997, -648.6833, -58.6377, 56.54336)
			Wait(1)
			CameraReturnToPlayer(false)
			returnedCamera = true
		end
	end
end

function F_Stage01InTheGymSetup()
	PlayerSetControl(0)
	Wait(600)
	AreaTransitionPoint(13, POINTLIST._5_04_COP_END, 3, true)
	AreaSetDoorLocked(TRIGGER._DT_GYM_DOORL, true)
	AreaSetDoorLocked(TRIGGER._DT_POOL_DOORL, true)
	AreaSetDoorLockedToPeds(TRIGGER._DT_GYM_DOORL, false)
	NonMissionPedGenerationDisable()
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	AreaClearAllPeds()
	PedSetFlag(gPlayer, 109, true)
	F_CleanupSmokes()
	BlipRemove(gExitBlip)
	EffectSetGymnFireOn(true)
	LoadAnimationGroup("Area_Asylum")
	LoadAnimationGroup("MINICHEM")
	LoadAnimationGroup("1_03The Setup")
	LoadAnimationGroup("F_Nerds")
	LoadAnimationGroup("GEN_Social")
	LoadAnimationGroup("2_S04CharSheets")
	LoadAnimationGroup("F_Adult")
	F_SetupProps()
	F_SetupFires()
	F_CreatePeds()
	F_SetupTriggers()
	F_Intro()
	TextPrint("5_04_11", 4, 1)
	gObjs[1] = MissionObjectiveAdd("5_04_11")
	F_DropLamp(3)
	Wait(1000)
	PlayerSetControl(1)
	MissionTimerStart(GYM_TIME)
	bTimer = true
	CreateThread("F_MonitorAlpha")
	CreateThread("T_ObjectiveMonitor")
	CreateThread("L_MonitorTriggers")
	fCasey = L_PedGetIDByIndex("gymjocks", 3)
	local kby = L_PedGetIDByIndex("gymjocks", 1)
	SoundPlayScriptedSpeechEvent(kby, "M_5_04", 4, "large")
	cx, cy, cz = PedGetPosXYZ(fCasey)
	gCheckForExtinguisher = true
	CreateThread("T_ExtinguisherCheck")
	SoundPlayStream("MS_BikeChaseMid.rsm", 0.6)
	gStageFunction = F_Stage01InTheGym
end

function F_WaitingForExtinguisher()
	if playerHasExting and not addedAllObjectives then
		MissionObjectiveComplete(gObjs[1])
		TextPrint("5_04_35", 4, 1)
		gObjs[2] = MissionObjectiveAdd("5_04_35")
		gObjs[3] = MissionObjectiveAdd("5_04_36")
		local a, b, c = L_PedGetIDByIndex("gymjocks", 1), L_PedGetIDByIndex("gymjocks", 2), L_PedGetIDByIndex("gymjocks", 3)
		gKirbyBlip = AddBlipForChar(a, 2, 0, 4)
		gMandyBlip = AddBlipForChar(b, 2, 0, 4)
		gCaseyBlip = AddBlipForChar(c, 2, 0, 4)
	end
end

function F_Stage01InTheGym()
	if playerHasExting and not addedAllObjectives then
		MissionObjectiveComplete(gObjs[1])
		TextPrint("5_04_35", 4, 1)
		gObjs[2] = MissionObjectiveAdd("5_04_35")
		gObjs[3] = MissionObjectiveAdd("5_04_36")
		local a, b, c = L_PedGetIDByIndex("gymjocks", 1), L_PedGetIDByIndex("gymjocks", 2), L_PedGetIDByIndex("gymjocks", 3)
		gKirbyBlip = AddBlipForChar(a, 2, 0, 4)
		gMandyBlip = AddBlipForChar(b, 2, 0, 4)
		gCaseyBlip = AddBlipForChar(c, 2, 0, 4)
		addedAllObjectives = true
	end
	if AreaGetVisible() == 0 then
		if bTimer then
			MissionTimerStop()
			bTimer = false
		end
		F_CleanupFires()
		BlipRemove(gExitBlip)
		NonMissionPedGenerationEnable()
		if not gMissionFailed then
			gStageFunction = F_Stage02OutOfTheGymSetup
		end
	end
	if not caseyDown and PedIsInAreaXYZ(gPlayer, cx, cy, cz, 14, 0) then
		Wait(10)
		PedSetEffectedByGravity(fCasey, false)
		PAnimSetActionNode(TRIGGER._5_04_GYMHOOP, "/Global/GymHoop/Damage/Fall", "Act/Props/GymHoop.act")
		Wait(1000)
		SoundPlayScriptedSpeechEvent(fCasey, "M_5_04", 8, "large")
		PedSetActionNode(fCasey, "/Global/5_04/KirbyFall", "Act/Conv/5_04.act")
		SoundPlayScriptedSpeechEvent(fCasey, "M_5_04", 9, "large")
		Wait(100)
		caseyDown = true
		hoopDown = true
		gHoopCoronaActive = true
		gHoopCorona = BlipAddXYZ(-617.361, -45.9852, 59.6611, 0, 0, 7)
	end
	if gFinishedGymHoop then
		BlipRemove(gHoopCorona)
		PedSetActionNode(fCasey, "/Global/5_04/JockIdle", "Act/Conv/5_04.act")
		SoundPlayScriptedSpeechEvent(fCasey, "M_5_04", 12, "large")
		PedSetActionNode(fCasey, "/Global/5_04/CrawlCycle", "Act/Conv/5_04.act")
		local waitForEnd = true
		while waitForEnd do
			if not PedIsPlaying(fCasey, "/Global/5_04/CrawlCycle", true) then
				waitForEnd = false
			end
			Wait(0)
		end
		PedSetEffectedByGravity(fCasey, true)
		Wait(600)
		F_DropLamp(2)
		PedMoveToXYZ(fCasey, 1, -622.704, -46.1418)
		Wait(750)
		local tableSize = table.getn(tblFires)
		table.insert(tblFires, {
			idFire = nil,
			trigger = TRIGGER._5_04_BANNERS_03,
			idFX = nil,
			fireAlive = true,
			blipId = nil
		})
		tblFires[tableSize + 1].idFire = FireCreate(TRIGGER._5_04_BANNERS_03, 1000, FIREDAMAGE, 100, 150, "GymFire")
		FireSetScale(tblFires[tableSize + 1].idFire, 1)
		FireSetDamageRadius(tblFires[tableSize + 1].idFire, 1)
		PAnimHideHealthBar(TRIGGER._5_04_BANNERS_03)
		gTargetGymAlpha = gGymAlpha + 0.2
		local bx, by, bz = GetAnchorPosition(TRIGGER._5_04_BANNERS_03)
		gFinishedGymHoop = nil
		gCaseyFree = true
		gHoopCoronaActive = nil
		SoundRemoveAllQueuedSpeech(fCasey, true)
		SoundPlayScriptedSpeechEvent(fCasey, "M_5_04", 14, "large")
		PedSetActionNode(fCasey, "/Global/5_04/KirbyInit/KirbyCough", "Act/Conv/5_04.act")
	end
	if gFinishedGymWall then
		BlipRemove(gWallCorona)
		local a = L_PedGetIDByIndex("gymjocks", 1)
		--print("FINISHED GYM WALL")
		PedSetActionNode(a, "/Global/5_04/CrawlCycle", "Act/Conv/5_04.act")
		SoundPlayScriptedSpeechEvent(a, "M_5_04", 7, "large")
		local waitForEnd = true
		while waitForEnd do
			if not PedIsPlaying(a, "/Global/5_04/CrawlCycle", true) then
				waitForEnd = false
			end
			Wait(0)
		end
		PedSetEffectedByGravity(a, true)
		PedClearObjectives(a)
		PedStop(a)
		Wait(100)
		PedFollowPath(a, PATH._5_04_JOCKPATH02, 0, 1, CbJock01Path)
		BlipRemove(gKirbyBlip)
		F_ResetJock(a)
		gFinishedGymWall = nil
		gKirbyFree = true
		gWallCoronaActive = nil
	end
	if gMandyArrived then
		if PedIsValid(gMandyArrived) and not MandyInitTalk then
			MandyInitTalk = true
			gMandyTalkTimer = GetTimer()
			PedFaceObject(gMandyArrived, gPlayer, 3, 1, false)
		end
		if gMandyTalkTimer and GetTimer() - gMandyTalkTimer > 10000 then
			PedSetActionNode(gMandyArrived, "/Global/5_04/MandyStand/MandyFreak", "Act/Conv/5_04.act")
			if (not gKirbyFree or not gCaseyFree) and math.random(1, 100) < 50 then
				SoundPlayScriptedSpeechEvent(gMandyArrived, "M_5_04", 20, "xtralarge")
			else
				SoundPlayScriptedSpeechEvent(gMandyArrived, "M_5_04", 21, "xtralarge")
			end
			gMandyTalkTimer = GetTimer()
		end
	end
	if gJockArrived then
		--print(" DELETING PED")
		PedSetMissionCritical(gJockArrived, false)
		PedDelete(gJockArrived)
		gJockArrived = nil
	end
	if gExitTimer and not AreaIsLoading() and GetTimer() > gExitTimer and AreaGetVisible() ~= 0 then
		gMissionFailed = true
		gMissionFailedMessage = "5_04_06"
		gCopsArrived = true
	end
	if gDOArrived then
		gExitTimer = GetTimer() + 15000
		Wait(300)
		PAnimCloseDoor(TRIGGER._DT_GYM_DOORL)
		gDOArrived = nil
	end
end

function F_Stage02OutOfTheGymSetup()
	TextPrint("5_04_40", 5, 1)
	AreaRevertToDefaultPopulation()
	PedSetPosPoint(idDO, POINTLIST._5_04_DO_START)
	PedSetFlag(gPlayer, 109, false)
	EffectSetGymnFireOn(false)
	Wait(0)
	PedStop(idDO)
	idDOBike = VehicleCreatePoint(282, POINTLIST._5_04_DO_BIKE)
	Wait(0)
	idBike = VehicleCreatePoint(273, POINTLIST._5_04_PBIKE)
	Wait(0)
	idLittleBoy = PedCreatePoint(69, POINTLIST._5_04_DO_BIKE, 2)
	Wait(100)
	gAngryJock01 = PedCreatePoint(15, POINTLIST._5_04_ANGRY_JOCKS_01, 1)
	Wait(0)
	gAngryJock02 = PedCreatePoint(18, POINTLIST._5_04_ANGRY_JOCKS_01, 2)
	Wait(0)
	PedSetWeapon(gAngryJock01, 331, 1)
	Wait(0)
	PedSetHealth(idDO, DO_MAX_HEALTH)
	PedSetInfiniteSprint(idDO, true)
	PedIgnoreAttacks(idDO, true)
	PedIgnoreStimuli(idDO, true)
	PedFollowPath(idDO, PATH._5_04_SCHOOL_ESCAPE, 0, 3)
	--print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<< CREATING THREADS")
	CreateThread("F_MonitorDO")
	--print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<< FINISHED CREATING THREADS")
	gStageFunction = F_Stage02OutOfTheGym
end

function F_Stage02OutOfTheGym()
end

function T_ExtinguisherCheck()
	playerHasExting = true
	WeaponRequestModel(326)
	if not WeaponEquipped(326) then
		gExtinguishBlip = BlipAddXYZ(-630.103, -62.6126, 59.7198, 0)
		playerHasExting = false
	end
	while gCheckForExtinguisher do
		if playerHasExting then
			if not WeaponEquipped(326) then
				local xx, xy, xz = PlayerGetPosXYZ()
				gExtinguishBlip = BlipAddXYZ(xx, xy, xz, 0)
				playerHasExting = false
			end
		elseif WeaponEquipped(326) then
			BlipRemove(gExtinguishBlip)
			gExtinguishBlip = nil
			playerHasExting = true
		end
		Wait(0)
	end
	if gExtinguishBlip then
		BlipRemove(gExtinguishBlip)
		gExtinguishBlip = nil
	end
end
