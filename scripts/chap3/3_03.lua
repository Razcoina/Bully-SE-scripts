local objMeet, objVant, objProt
local blipGreaserSpotter = true
local bGreaserReachedBalcony = false
local bGreaserSpotting = false
local bLoop = true
local bGoToStage2 = false
local bMissionFailed = false
local bMissionPassed = false
local bDeleteLola = false
local bDeletePeanut = false
local bReachedAlley = false
local gWave = 1
local bWave1Launched = false
local bWave2Launched = false
local bWave3Launched = false
local bWave4Launched = false
local bWave5Launched = false
local bTestingCrates = false
local bWave2DialogueReply = false
local bLolaAlleyGreet = false
local bMoveLolaToAlley = false
local idGetOffBike
local bSpottedOnBalcony = false
local tadBlip, tadBlip2
local tblGreasers = {}
local tblGreasersAlive = {}

function MissionSetup()
	DATLoad("3_03.DAT", 2)
	DATInit()
	PlayCutsceneWithLoad("3-03", true)
	WeaponRequestModel(303)
	F_TableInit()
	AreaTransitionPoint(0, POINTLIST._SPAWNPLAYER)
	while AreaGetVisible() ~= 0 do
		Wait(100)
	end
	RadarSetMinMax(30, 75, 45)
	POISetSystemEnabled(false)
	PedSetUniqueModelStatus(25, -1)
	PedSetUniqueModelStatus(31, -1)
	MissionDontFadeIn()
end

function MissionCleanup()
	PedSetUniqueModelStatus(25, 0)
	PedSetUniqueModelStatus(31, 0)
	PedHideHealthBar()
	AreaRevertToDefaultPopulation()
	RadarRestoreMinMax()
	DATUnload(2)
	DATInit()
	POISetSystemEnabled(true)
end

function main()
	F_SetupWorld()
	F_Intro()
	F_Stage1()
	if bMissionFailed then
		TextPrint("MFAIL", 3, 1)
		if table.getn(tblGreasersAlive) > 0 then
			for _, entry in tblGreasersAlive do
				PedRemovePedFromIgnoreList(entry, gPlayer)
				PedMakeAmbient(entry)
			end
		end
		Wait(3000)
		SoundPlayMissionEndMusic(false, 10)
		MissionFail()
	elseif bMissionPassed then
		TextPrint("MPASS", 3, 1)
		Wait(3000)
		SoundPlayMissionEndMusic(true, 10)
		MissionSucceed()
	end
end

function F_TableInit()
	--print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
	pedLola = {
		spawn = POINTLIST._SPAWNLOLA,
		element = 1,
		model = 25
	}
	pedTad = {
		spawn = POINTLIST._SPAWNTAD,
		element = 1,
		model = 31
	}
	vehicleLolaBike = {
		spawn = POINTLIST._SPAWNLOLABIKE,
		element = 1,
		model = 279
	}
	pedGreaserA01 = {
		spawn = POINTLIST._SPAWNGREASERSNORTH,
		element = 1,
		model = 24
	}
	pedGreaserA02 = {
		spawn = POINTLIST._SPAWNGREASERSNORTH,
		element = 2,
		model = 29
	}
	pedGreaserA03 = {
		spawn = POINTLIST._SPAWNGREASERSNORTH,
		element = 3,
		model = 21
	}
	pedGreaserB01 = {
		spawn = POINTLIST._SPAWNGREASERSSOUTH,
		element = 1,
		model = 28
	}
	pedGreaserB02 = {
		spawn = POINTLIST._SPAWNGREASERSSOUTH,
		element = 2,
		model = 27
	}
	pedGreaserB03 = {
		spawn = POINTLIST._SPAWNGREASERSSOUTH,
		element = 3,
		model = 22
	}
	pedGreaserC01 = {
		spawn = POINTLIST._SPAWNBIKES,
		element = 1,
		model = 22
	}
	pedGreaserC02 = {
		spawn = POINTLIST._SPAWNBIKES,
		element = 2,
		model = 24
	}
	pedGreaserC03 = {
		spawn = POINTLIST._SPAWNENEMYWINDOW,
		element = 1,
		model = 26
	}
	vehicleBikeC01 = {
		spawn = POINTLIST._SPAWNBIKESNORTH,
		element = 1,
		model = 273
	}
	vehicleBikeC02 = {
		spawn = POINTLIST._SPAWNBIKESNORTH,
		element = 2,
		model = 273
	}
	pedGreaserD01 = {
		spawn = POINTLIST._SPAWNGREASERSNORTH,
		element = 1,
		model = 24
	}
	pedGreaserD02 = {
		spawn = POINTLIST._SPAWNGREASERSSOUTH,
		element = 1,
		model = 29
	}
	pedGreaserE01 = {
		spawn = POINTLIST._SPAWNGREASERSNORTH,
		element = 1,
		model = 21
	}
	pedGreaserE02 = {
		spawn = POINTLIST._SPAWNGREASERSNORTH,
		element = 2,
		model = 28
	}
	vehicleBikeE01 = {
		spawn = POINTLIST._SPAWNBIKESNORTH,
		element = 1,
		model = 273
	}
	vehicleBikeE02 = {
		spawn = POINTLIST._SPAWNBIKESNORTH,
		element = 2,
		model = 273
	}
	pedGreaserJump1 = {
		spawn = POINTLIST._SPAWNGREASERSEAST,
		element = 1,
		model = 28
	}
	pedGreaserJump2 = {
		spawn = POINTLIST._SPAWNGREASERSEAST,
		element = 2,
		model = 27
	}
	--print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_SetupWorld()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupWorld()")
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupWorld()")
end

function F_Intro()
	--print("()xxxxx[:::::::::::::::> [start] F_Intro()")
	PlayerSetControl(0)
	local setX, setY, setZ, heading = GetPointList(POINTLIST._SPAWNPLAYER)
	PlayerSetPosXYZ(setX, setY, setZ)
	PlayerFaceHeading(heading, 0)
	vehicleLolaBike.id = VehicleCreatePoint(vehicleLolaBike.model, vehicleLolaBike.spawn, vehicleLolaBike.element)
	VehicleMakeAmbient(vehicleLolaBike.id)
	VehicleCreatePoint(vehicleLolaBike.model, POINTLIST._SPAWNPLAYERBIKE, 1)
	pedLola.id = PedCreatePoint(pedLola.model, pedLola.spawn, pedLola.element)
	PedMakeTargetable(pedLola.id, false)
	PedSetFlag(pedLola.id, 20, true)
	Wait(1000)
	CameraFade(500, 1)
	PedEnterVehicle(pedLola.id, vehicleLolaBike.id)
	while not PedIsInVehicle(pedLola.id, vehicleLolaBike.id) do
		Wait(0)
	end
	F_LolaRunOff()
	Wait(500)
	PlayerSetControl(1)
	--print("()xxxxx[:::::::::::::::> [finish] F_Intro()")
end

function F_Stage1()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
	F_Stage1_Setup()
	F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
	objMeet = MissionObjectiveAdd("3_03_OMEET")
	TextPrint("3_03_MOBJ_03", 4, 1)
	blipLola = BlipAddPoint(POINTLIST._SPAWNLOLAALLEY, 0)
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
	local tempX, tempY, tempZ = GetPointList(POINTLIST._BLIPBALCONY)
	MissionTimerStart(60)
	while bLoop do
		if bMissionFailed then
			break
		end
		if bGoToStage2 then
			MissionTimerPause(true)
			MissionTimerStop()
			F_Stage2()
			break
		end
		PlayerIsInAreaXYZ(tempX, tempY, tempZ, 2, 9)
		if bMoveLolaToAlley then
			PedDelete(pedLola.id)
			pedLola.id = nil
			pedLola.id = PedCreatePoint(pedLola.model, POINTLIST._SPAWNLOLAALLEY, pedLola.element)
			PedSetFlag(pedLola.id, 23, true)
			PedSetInvulnerable(pedLola.id, true)
			Wait(0)
			if VehicleIsValid(vehicleLolaBike.id) then
				VehicleDelete(vehicleLolaBike.id)
			end
			VehicleCreatePoint(vehicleLolaBike.model, POINTLIST._SPAWNLOLABIKEALLEY, vehicleLolaBike.element)
			bMoveLolaToAlley = false
		end
		if not bLolaAlleyGreet and PlayerIsInTrigger(TRIGGER._TRIGGERLOLA) then
			PedFaceObject(pedLola.id, gPlayer, 3, 1)
			PedFaceObject(gPlayer, pedLola.id, 2, 1)
			BlipRemove(blipLola)
			MissionObjectiveComplete(objMeet)
			blipBalcony = BlipAddPoint(POINTLIST._BLIPBALCONY, 0)
			TextPrint("3_03_LOLA_02", 3, 2)
			bReachedAlley = true
			MissionTimerStart(15)
			TextPrint("3_03_MOBJ_01", 3, 1)
			objVantage = MissionObjectiveAdd("3_03_OVANT")
			bLolaAlleyGreet = true
		end
		if MissionTimerHasFinished() or PlayerIsInAreaXYZ(tempX, tempY, tempZ, 2, 0) then
			if bReachedAlley then
				MissionObjectiveComplete(objVantage)
				bGoToStage2 = true
			else
				bMissionFailed = true
			end
			--print("()xxxxx[:::::::::::::::> [failure] Stage 1 timer expired")
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
	objProt = MissionObjectiveAdd("3_03_OPROT")
	BlipRemove(blipBalcony)
	pedTad.id = PedCreatePoint(pedTad.model, pedTad.spawn, pedTad.element)
	PedSetInvulnerableToPlayer(pedTad.id, true)
	PedSetHealth(pedTad.id, 350)
	Wait(100)
	PedFollowPath(pedTad.id, PATH._ROUTETAD, 0, 1, F_routeTad)
	TextPrint("3_03_LOLA_01", 3, 2)
	PedFaceObject(pedLola.id, pedTad.id, 2, 1)
	Wait(500)
	PedSetActionNode(pedLola.id, "/Global/3_03/Wave", "Act/Conv/3_03.act")
	Wait(3000)
	TextPrint("3_03_TAD_01", 3, 2)
	Wait(3000)
	TextPrint("3_03_TAD_02", 3, 2)
	Wait(3000)
	PedSetTetherToTrigger(pedTad.id, TRIGGER._TRIGGERTADTETHER)
	F_CreateGreaser(pedGreaserA01)
	F_CreateGreaser(pedGreaserA02)
	F_CreateGreaser(pedGreaserA03)
	threadMonitorTad = CreateThread("T_MonitorTad")
	threadMonitorWaves = CreateThread("T_MonitorWaves")
	CreateThread("T_MonitorGreasers")
	PedFollowPath(pedGreaserA01.id, PATH._ROUTEGREASER01, 0, 1, F_routeGreaserA01)
	PedFollowPath(pedGreaserA02.id, PATH._ROUTEGREASER02, 0, 1, F_routeGreaserA02)
	PedFollowPath(pedGreaserA03.id, PATH._ROUTEGREASER03, 0, 1, F_routeGreaserA03)
	PedOverrideStat(pedGreaserA01.id, 3, 10)
	PedOverrideStat(pedGreaserA02.id, 3, 10)
	PedOverrideStat(pedGreaserA03.id, 3, 10)
	TextPrint("3_03_TAD_03", 3, 2)
	PedFollowPath(pedLola.id, PATH._ROUTELOLARUN, 0, 1, F_routeLolaRun)
	Wait(3000)
	TextPrint("3_03_GREASER_01", 3, 2)
	Wait(3000)
	TextPrint("3_03_GREASER_02", 3, 2)
	PedFollowPath(pedGreaserA03.id, PATH._ROUTEGREASER03b, 0, 1, F_routeGreaserA03b)
	Wait(2000)
	PedAttack(pedGreaserA01.id, pedTad.id, false)
	PedAttack(pedGreaserA02.id, pedTad.id, false)
	Wait(500)
	PedShowHealthBar(pedTad.id, true, "3_03_HEALTHBAR", false)
	PedMakeTargetable(pedTad.id, false)
	PedSetFlag(pedTad.id, 20, true)
	PedSetPedToTypeAttitude(pedTad.id, 13, 4)
	TextPrint("3_03_MOBJ_02", 3, 1)
	tadBlip = AddBlipForChar(pedTad.id, 12, 0)
	tadBlip2 = AddBlipForChar(pedTad.id, 12, 0, 4)
	PedSetFaction(pedLola.id, 1)
	PedSetFaction(pedTad.id, 5)
	PedOverrideStat(pedGreaserA01.id, 3, 50)
	PedOverrideStat(pedGreaserA02.id, 3, 50)
	PedOverrideStat(pedGreaserA03.id, 3, 50)
	Wait(3000)
	PedOverrideStat(pedTad.id, 6, 0)
	PedOverrideStat(pedTad.id, 3, 50)
	PedOverrideStat(pedTad.id, 2, 360)
	PedOverrideStat(pedTad.id, 14, 90)
	PedSetPedToTypeAttitude(pedTad.id, 13, 4)
	PedSetPedToTypeAttitude(pedTad.id, 4, 0)
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
	local testX, testY, testZ = GetPointList(POINTLIST._TESTCRATES)
	while bLoop do
		if bDeleteLola then
			--print("()xxxxx[:::::::::::::::> Deleting Lola")
			PedDelete(pedLola.id)
			bDeleteLola = false
		end
		if bDeletePeanut then
			--print("()xxxxx[:::::::::::::::> Deleting Peanut")
			PedDelete(pedGreaserA03.id)
			bDeletePeanut = false
		end
		if bWave2DialogueReply then
			Wait(3000)
			TextPrint("3_03_GREASER_05", 3, 2)
			bWave2DialogueReply = false
		end
		if bMissionFailed then
			TextPrint("3_03_MFAIL", 3, 1)
			break
		end
		if bMissionPassed then
			MissionObjectiveComplete(objProt)
			F_EndingCinematic()
			break
		end
		Wait(0)
	end
end

function F_LolaRunOff()
	--print("()xxxxx[:::::::::::::::> [start] F_LolaRunOff()")
	PedFollowPath(pedLola.id, PATH._INTROLOLARIDEOFF, 0, 1, F_IntroLolaRideOff)
	--print("()xxxxx[:::::::::::::::> [finish] F_LolaRunOff()")
end

function F_LaunchWave2()
	--print("()xxxxx[:::::::::::::::> [start] F_LaunchWave2()")
	CreateThread("T_LaunchJumpers")
	F_CreateGreaser(pedGreaserB01)
	PedFollowPath(pedGreaserB01.id, PATH._ROUTEGREASERSSOUTH, 0, 1, F_routeGreasersNorth)
	Wait(500)
	F_CreateGreaser(pedGreaserB02)
	PedFollowPath(pedGreaserB02.id, PATH._ROUTEGREASERSSOUTH, 0, 1, F_routeGreasersNorth)
	Wait(500)
	F_CreateGreaser(pedGreaserB03)
	PedFollowPath(pedGreaserB03.id, PATH._ROUTEGREASERSSOUTH, 0, 1, F_routeGreasersNorth)
	TextPrint("3_03_GREASER_03", 3, 2)
	Wait(3000)
	TextPrint("3_03_LOLA_03", 3, 2)
	Wait(5000)
	TextPrint("3_03_GREASER_04", 3, 2)
	bWave2DialogueReply = true
	--print("()xxxxx[:::::::::::::::> [finish] F_LaunchWave2()")
end

function F_LaunchWave3()
	--print("()xxxxx[:::::::::::::::> [start] F_LaunchWave3()")
	vehicleBikeC01.id = VehicleCreatePoint(vehicleBikeC01.model, POINTLIST._SPAWNBIKES, 3)
	vehicleBikeC02.id = VehicleCreatePoint(vehicleBikeC02.model, POINTLIST._SPAWNBIKES, 4)
	F_CreateGreaser(pedGreaserC01)
	PedPutOnBike(pedGreaserC01.id, vehicleBikeC01.id)
	PedFollowPath(pedGreaserC01.id, PATH._ROUTEGREASERSNORTH, 0, 1, F_routeGreasersNorth)
	PedPathNodeReachedDistance(pedGreaserC01.id, 3)
	Wait(500)
	F_CreateGreaser(pedGreaserC02)
	PedPutOnBike(pedGreaserC02.id, vehicleBikeC02.id)
	PedPathNodeReachedDistance(pedGreaserC02.id, 3)
	PedFollowPath(pedGreaserC02.id, PATH._ROUTEGREASERSNORTH, 0, 1, F_routeGreasersNorth)
	Wait(500)
	F_CreateGreaser(pedGreaserC03)
	ObjectMakeTargetable(pedGreaserC03.id, false)
	PedSetWeapon(pedGreaserC03.id, 303, 200)
	PedAddPedToIgnoreList(pedTad.id, pedGreaserC03.id)
	PedCoverSet(pedGreaserC03.id, pedTad.id, POINTLIST._POINTENEMYWINDOW, 100, 50, 5, 0, 0, 1, 1, 1, 1, 0, 0, true)
	PedAttack(pedGreaserC03.id, pedTad.id, 0)
	TextPrint("3_03_GREASER_07", 3, 2)
	Wait(3000)
	TextPrint("3_03_LOLA_04", 3, 2)
	--print("()xxxxx[:::::::::::::::> [finish] F_LaunchWave3()")
end

function F_LaunchWave4()
	--print("()xxxxx[:::::::::::::::> [start] F_LaunchWave4()")
	F_CreateGreaser(pedGreaserD01)
	PedFollowPath(pedGreaserD01.id, PATH._ROUTEGREASERSNORTH, 0, 1, F_routeGreasersNorth)
	F_CreateGreaser(pedGreaserD02)
	PedFollowPath(pedGreaserD02.id, PATH._ROUTEGREASERSSOUTH, 0, 1, F_routeGreasersNorth)
	Wait(4000)
	TextPrint("3_03_LOLA_05", 4, 2)
	--print("()xxxxx[:::::::::::::::> [finish] F_LaunchWave4()")
end

function F_LaunchWave5()
	--print("()xxxxx[:::::::::::::::> [start] F_LaunchWave5()")
	F_CreateGreaser(pedGreaserE01)
	PedFollowPath(pedGreaserE01.id, PATH._ROUTEGREASERSNORTH, 0, 1, F_routeGreasersNorth)
	Wait(500)
	F_CreateGreaser(pedGreaserE02)
	PedFollowPath(pedGreaserE02.id, PATH._ROUTEGREASERSNORTH, 0, 1, F_routeGreasersNorth)
	Wait(4000)
	TextPrint("3_03_LOLA_06", 4, 2)
	--print("()xxxxx[:::::::::::::::> [finish] F_LaunchWave5()")
end

function F_EndingCinematic()
	bLoop = false
	--print("()xxxxx[:::::::::::::::> [start] F_EndingCinematic()")
	PlayerSetControl(0)
	CameraFade(500, 0)
	Wait(500)
	BlipRemove(tadBlip)
	BlipRemove(tadBlip2)
	PedSetPosPoint(pedTad.id, POINTLIST._ENDTADLOCATION, 1)
	PedClearTether(pedTad.id)
	PedSetPosPoint(pedLola.id, POINTLIST._ENDLOLALOCATION, 1)
	PlayerSetPosPoint(POINTLIST._ENDPLAYERLOCATION, 1)
	CameraSetXYZ(540.877, -109.256, 12.798, 545.193, -104.917, 10.1)
	AreaClearAllVehicles()
	CameraSetWidescreen(true)
	Wait(500)
	CameraFade(500, 1)
	TextPrint("3_03_LOLA_07", 3, 2)
	WaitSkippable(3000)
	PedFollowPath(pedLola.id, PATH._ENDLOLARUN, 0, 1)
	Wait(1000)
	TextPrint("3_03_LOLA_08", 3, 2)
	CameraLookAtXYZ(568.883, -112.568, 6, false)
	Wait(3000)
	TextPrint("3_03_TAD_05", 4, 2)
	PedFollowPath(pedTad.id, PATH._ENDTADRUN, 0, 1)
	Wait(6000)
	CameraFade(500, 0)
	Wait(500)
	PedDelete(pedTad.id)
	PedDelete(pedLola.id)
	Wait(100)
	CameraFade(500, 1)
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	CameraReturnToPlayer()
	--print("()xxxxx[:::::::::::::::> [finish] F_EndingCinematic()")
end

function F_CreateGreaser(tblGreaser)
	tblGreaser.id = PedCreatePoint(tblGreaser.model, tblGreaser.spawn, tblGreaser.element)
	tblGreaser.blip = AddBlipForChar(tblGreaser.id, 4, 2, 1)
	PedSetPedToTypeAttitude(tblGreaser.id, 5, 0)
	PedSetPedToTypeAttitude(tblGreaser.id, 13, 1)
	PedOverrideStat(tblGreaser.id, 3, 35)
	PedSetCombatZoneMask(tblGreaser.id, true, true, false)
	PedOverrideStat(tblGreaser.id, 14, 90)
	PedAddPedToIgnoreList(tblGreaser.id, gPlayer)
	PedAddPedToIgnoreList(tblGreaser.id, pedLola.id)
	table.insert(tblGreasersAlive, tblGreaser.id)
	--print("[JASON] =========> Inserting Greaser into cleanup table. Current Size: " .. table.getn(tblGreasersAlive))
end

function CB_FailMission()
	TextPrint("3_03_MOBJ_05", 4, 1)
	Wait(4000)
	bMissionFailed = true
end

function F_AbsNumber(number)
	if number < 0 then
		--print("[JASON] Absolute Number: number < 0" .. number)
		return number * -1
	end
	return number
end

function F_JumpWavePicker(nChoice)
	if nChoice == 2 then
		return bWave2Launched
	elseif nChoice == 3 then
		return bWave3Launched
	elseif nChoice == 4 then
		return bWave4Launched
	elseif nChoice == 5 then
		return bWave5Launched
	end
end

function F_AllPedsInTableDead(tblPeds)
	if table.getn(tblPeds) > 0 then
		--print("[JASON] ============> F_AllPedsInTableDead: checking table...")
		for i, entry in tblPeds do
			if PedIsDead(entry) then
				table.remove(tblPeds, i)
			end
		end
		return false
	elseif table.getn(tblPeds) <= 0 then
		--print("[JASON] ============> F_AllPedsInTableDead: Return TRUE, all peds are dead.")
		return true
	end
end

function T_MonitorTad()
	--print("()xxxxx[:::::::::::::::> [start] T_MonitorTad()")
	while bLoop do
		if PedIsDead(pedTad.id) then
			--print("()xxxxx[:::::::::::::::> ** TAD IS DEAD **")
			--print("()xxxxx[:::::::::::::::> ** TAD IS DEAD **")
			bMissionFailed = true
			break
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] T_MonitorTad()")
end

function T_MonitorWaves()
	--print("()xxxxx[:::::::::::::::> [start] T_MonitorWaves()")
	while bLoop do
		if gWave == 1 then
			if PedIsDead(pedGreaserA01.id) and PedIsDead(pedGreaserA02.id) then
				gWave = 2
			end
		elseif gWave == 2 then
			if not bWave2Launched then
				F_LaunchWave2()
				bWave2Launched = true
			end
			if F_AllPedsInTableDead(tblGreasersAlive) then
				gWave = 3
			end
		elseif gWave == 3 then
			if not bWave3Launched then
				F_LaunchWave3()
				bWave3Launched = true
			end
			if F_AllPedsInTableDead(tblGreasersAlive) then
				gWave = 4
			end
		elseif gWave == 4 then
			if not bWave4Launched then
				F_LaunchWave4()
				bWave4Launched = true
			end
			if F_AllPedsInTableDead(tblGreasersAlive) then
				gWave = 5
			end
		elseif gWave == 5 then
			if not bWave5Launched then
				F_LaunchWave5()
				bWave5Launched = true
			end
			if F_AllPedsInTableDead(tblGreasersAlive) then
				bMissionPassed = true
				break
			end
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] T_MonitorWaves()")
end

function T_PlayerOnBalcony()
	local bTimerRunning = false
	--print("()xxxxx[:::::::::::::::> [start] T_PlayerOnBalcony()")
	while bLoop do
		if PlayerIsInTrigger(TRIGGER._TRIGGERBALCONY2) then
			if bTimerRunning then
				MissionTimerPause(true)
				MissionTimerStop()
				MissionTimerPause(true)
				bTimerRunning = false
			end
		elseif not bTimerRunning then
			MissionTimerStart(5)
			bTimerRunning = true
		end
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> [finish] T_PlayerOnBalcony()")
	collectgarbage()
end

function T_MonitorGreasers()
	local nSpotTimer = GetTimer()
	local nGreasersOffBikes = 0
	while not bMissionFailed do
		if 0 < table.getn(tblGreasersAlive) then
			for i, entry in tblGreasersAlive do
				if not PedIsValid(entry) then
					table.remove(tblGreasersAlive, i)
					--print("[JASON] =============> T_MonitorGreasers: Removing Entry #" .. i)
				elseif PedCanSeeObject(entry, gPlayer, 3) and PlayerIsInTrigger(TRIGGER._TRIGGERBACKALLEY) then
					TextPrint("3_03_MOBJ_05", 4, 1)
					Wait(4000)
					bMissionFailed = true
				end
			end
		end
		if idGetOffBike then
			PedStop(idGetOffBike)
			PedExitVehicle(idGetOffBike)
			PedAttack(idGetOffBike, pedTad.id, 3)
			--print("[JASON] ==========> T_MonitorGreasers: Exiting Vehicle, Ped #: " .. idGetOffBike)
			idGetOffBike = nil
			nGreasersOffBikes = nGreasersOffBikes + 1
		end
		if PedIsValid(pedTad.id) and PedCanSeeObject(pedTad.id, gPlayer, 3) and PlayerIsInTrigger(TRIGGER._TRIGGERBACKALLEY) then
			TextPrint("3_03_MOBJ_05", 4, 1)
			Wait(4000)
			bMissionFailed = true
		end
		if nGreasersOffBikes == 2 then
			Wait(1000)
			PedAttack(pedGreaserC01.id, pedTad.id, 3)
			PedAttack(pedGreaserC02.id, pedTad.id, 3)
		end
		Wait(0)
	end
	collectgarbage()
end

function T_LaunchJumpers()
	--print("()xxxxx[:::::::::::::::> [start] F_LaunchJumpers()")
	local nChoice = math.random(2, 4)
	--print("nChoice = " .. nChoice)
	while not F_JumpWavePicker(nChoice) do
		Wait(0)
	end
	Wait(5000)
	--print("()xxxxx[:::::::::::::::> [start] F_LaunchJumpers()")
	F_CreateGreaser(pedGreaserJump1)
	F_CreateGreaser(pedGreaserJump2)
	PedJump(pedGreaserJump1.id, POINTLIST._EASTWALL, 1, 1)
	PedJump(pedGreaserJump2.id, POINTLIST._EASTWALL, 1, 2)
	Wait(6000)
	PedAttack(pedGreaserJump1.id, pedTad.id, 3)
	PedAttack(pedGreaserJump2.id, pedTad.id, 3)
	--print("()xxxxx[:::::::::::::::> [finish] F_LaunchJumpers()")
end

function CB_SpotPlayer(pedID, pathID, nodeID)
	if nodeID == PathGetLastNode(pathID) then
		BlipRemove(blipGreaserSpotter)
	end
	if PedCanSeeObject(pedID, gPlayer, 3) then
		bMissionFailed = true
	end
end

function F_routeLolaIntro(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeLolaIntro() Node @ : " .. nodeID)
end

function F_routeTad(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeTad() Node @ : " .. nodeID)
end

function F_routeGreaserA01(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeGreaserA01() Node @ : " .. nodeID)
end

function F_routeGreaserA02(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeGreaserA02() Node @ : " .. nodeID)
end

function F_routeGreaserA03(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeGreaserA03() Node @ : " .. nodeID)
end

function F_routeGreaserA03b(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeGreaserA03b() Node @ : " .. nodeID)
	if nodeID == 2 then
		bDeletePeanut = true
	end
end

function F_routeLolaRun(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeLolaRun() Node @ : " .. nodeID)
	if nodeID == PathGetLastNode(pathID) then
	end
end

function F_routeGreasersNorth(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeGreasersNorth() Node @ : " .. nodeID)
	if nodeID == PathGetLastNode(pathID) then
		if PedIsInAnyVehicle(pedID) then
			idGetOffBike = pedID
			PedAttack(pedID, pedTad.id, 3)
		end
		PedAttack(pedID, pedTad.id, false)
	end
end

function F_routeGreasersSouth(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> F_routeGreasersSouth() Node @ : " .. nodeID)
	if nodeID == PathGetLastNode(pathID) then
		PedAttack(pedID, pedTad.id, true)
		if gWave == 2 then
			TextPrint("3_03_GREASER_04", 3, 2)
			bWave2DialogueReply = true
		end
	end
end

function F_routeGreasersEast(pedID, pathID, nodeID)
	if nodeID == 2 then
		--print("()xxxxx[:::::::::::::::> F_routeGreasersEast - CLIMB FENCE")
		if pedID == pedGreaserD01.id then
			PedClimbWall(pedID, POINTLIST._EASTWALL, 1)
		else
			PedClimbWall(pedID, POINTLIST._EASTWALL, 2)
		end
	end
end

function F_routeCrate()
end

function F_routeUpstairs(pedID, pathID, nodeID)
	if nodeID == PathGetLastNode(pathID) then
		PedSetActionNode(pedID, "/Global/3_03/Animations/Talking", "Act/Conv/3_03.act")
		PedIgnoreStimuli(pedID, false)
		PedIgnoreAttacks(pedID, false)
		bGreaserReachedBalcony = true
	elseif nodeID == PathGetLastNode(pathID) - 1 then
	end
end

function F_IntroLolaRideOff(pedID, pathID, nodeID)
	if nodeID == 4 then
		bMoveLolaToAlley = true
	end
end

function CbStealthCallback(pedID)
	--print("[JASON] ================> Firing ** CbStealthCallback")
	bSpottedOnBalcony = true
end
