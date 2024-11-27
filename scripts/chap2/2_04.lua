ImportScript("Library/BikeRace_util.lua")
local bike, bikeBlip
local bRaceStarted = false
local idPeter, peteBike
local bStopBikeThread = false
local owner
local tblCheerers = {}
local tblCleanup = {}
local peteyFollow = true
local bCritFailed = false
local tblLoadModels = {
	134,
	273,
	31,
	32,
	30,
	38,
	67,
	142,
	9,
	68,
	139,
	86
}

function MissionSetup()
	GarageSetIsDeactivated(true)
	if PlayerGetScriptSavedData(23) == 1 then
	else
		PlayCutsceneWithLoad("2-04", true)
	end
	MissionDontFadeIn()
	DisablePOI()
end

function main()
	LoadModels(tblLoadModels)
	LoadAnimationGroup("NIS_2_04")
	LoadAnimationGroup("3_R08RaceLeague")
	LoadAnimationGroup("Cheer_Girl3")
	LoadAnimationGroup("Cheer_Nerd3")
	LoadAnimationGroup("Cheer_Posh3")
	LoadAnimationGroup("Cheer_Cool2")
	LoadAnimationGroup("3_G3")
	LoadActionTree("Act/Conv/2_04.act")
	LoadActionTree("Act/Anim/Race.act")
	DATLoad("2_04.DAT", 2)
	DATInit()
	F_InitTables()
	F_CreateMissionEntities()
	tblCleanup = {
		F_CreateBeachPeds()
	}
	if PlayerGetScriptSavedData(23) == 0 then
		CreateThread("T_Petey")
		CreateThread("T_GetBackOnBikeCheck")
		F_GetBike()
		F_GetToBeach()
	end
	if PedIsValid(tblRaceInfo.race.countdown_ped.id) then
		PedSetInvulnerable(tblRaceInfo.race.countdown_ped.id, false)
	end
	if not bCritFailed then
		for i, entry in tblCleanup do
			if entry.isPed and PedIsValid(entry.id) then
				PedSetMissionCritical(entry.id, false)
				PedSetInvulnerable(entry.id, false)
				if makeAmbient then
					PedMakeAmbient(entry.id)
				else
					PedDelete(entry.id)
				end
			elseif not entry.isPed and VehicleIsValid(entry.id) then
				if not PedIsInVehicle(gPlayer, entry.id) then
					VehicleDelete(entry.id)
				else
					VehicleMakeAmbient(entry.id)
				end
			end
		end
		tblCleanup = {}
		peteyFollow = false
		F_RaceSetup()
		F_CreateBeachCheerers()
		CreateThread("T_ChangeBeachPositions")
		Wait(1000)
		PlayerSetScriptSavedData(23, 1)
		F_BarrierInit()
		VehicleOverrideAmbient(0, 0, 0, 0)
		F_NISRace(PATH._2_04_INTROPATH, PATH._2_04_INTROLOOK)
		CreateCountdownPed(tblRaceInfo)
		bRaceStarted = true
		PedSetMissionCritical(gPlayer, true, cbCritPlayer)
		local bWin, szFailReason = RaceControl()
		RaceHUDVisible(false)
		if bWin then
			PedSetInvulnerable(tblRaceInfo.race.countdown_ped.id, true)
			PlayerSetInvulnerable(true)
			PedIgnoreStimuli(tblRaceInfo.race.countdown_ped.id, true)
			PedSetStationary(tblRaceInfo.race.countdown_ped.id, true)
			MissionTimerStop()
			F_EndNIS()
			SetFactionRespect(5, GetFactionRespect(5) - 10)
			MissionSucceed(true, false, false)
		else
			SoundPlayMissionEndMusic(false, 8)
			if szFailReason then
				MissionFail(false, true, szFailReason)
			else
				MinigameSetCompletion("GKART_YOULOSE", false)
				while MinigameIsShowingCompletion() do
					Wait(0)
				end
				MissionFail(false, false)
			end
		end
	end
	Wait(10000)
end

function cbCritFail()
	if not bCritFailed then
		SoundPlayMissionEndMusic(false, 8)
		MissionFail(false, true, "2_04_FAILPETE")
		bCritFailed = true
	end
end

function cbCritFailOwner()
	if not bCritFailed then
		if tblRaceInfo.race.countdown_ped.id and PedIsValid(tblRaceInfo.race.countdown_ped.id) then
			PedSetInvulnerable(tblRaceInfo.race.countdown_ped.id, false)
			PedSetFlag(tblRaceInfo.race.countdown_ped.id, 113, false)
			PedSetStationary(tblRaceInfo.race.countdown_ped.id, false)
			PedIgnoreStimuli(tblRaceInfo.race.countdown_ped.id, false)
			PedMakeAmbient(tblRaceInfo.race.countdown_ped.id)
		end
		SoundPlayMissionEndMusic(false, 8)
		MissionFail(false, true, "2_04_FAILOWNER")
		bCritFailed = true
	end
end

function cbCritFailRacer()
	if not bCritFailed then
		SoundPlayMissionEndMusic(false, 8)
		MissionFail(false, true, "2_04_FAILRACER")
		bCritFailed = true
	end
end

function MissionCleanup()
	EnablePOI()
	UnLoadAnimationGroup("NIS_2_04")
	UnLoadAnimationGroup("3_R08RaceLeague")
	UnLoadAnimationGroup("Cheer_Girl3")
	UnLoadAnimationGroup("Cheer_Nerd3")
	UnLoadAnimationGroup("Cheer_Posh3")
	UnLoadAnimationGroup("Cheer_Cool2")
	UnLoadAnimationGroup("3_G3")
	shared.gPlayerIncapacitated = nil
	PedSetMissionCritical(gPlayer, false)
	if bRaceStarted then
		AreaLoadSpecialEntities("RL_rich1", false)
		RaceCleanup()
	end
	if PedIsValid(idPeter) then
		--print("Peterage", i)
		PedHideHealthBar()
		PedMakeTargetable(idPeter, true)
		PedIgnoreStimuli(idPeter, false)
		PedIgnoreAttacks(idPeter, false)
		PedMakeAmbient(idPeter)
	end
	if VehicleIsValid(peteBike) then
		VehicleMakeAmbient(peteBike)
	end
	for i, entry in tblCleanup do
		--print("tblCleanup!!", i)
		if F_ObjectIsValid(entry.id) then
			if entry.isPed and PedIsValid(entry.id) then
				--print("tblCleanup!!", i)
				PedMakeTargetable(entry.id, true)
				PedIgnoreStimuli(entry.id, false)
				PedIgnoreAttacks(entry.id, false)
				PedMakeAmbient(entry.id)
			elseif not entry.isPed and VehicleIsValid(entry.id) then
				VehicleMakeAmbient(entry.id)
			end
		end
	end
	VehicleRevertToDefaultAmbient()
	GarageSetIsDeactivated(false)
	CameraSetWidescreen(false)
	SoundEnableSpeech_ActionTree()
	PlayerSetControl(1)
	F_MakePlayerSafeForNIS(false)
	CameraReset()
	CameraReturnToPlayer()
	F_CleanTable(tblCleanup, true)
	SoundEnableInteractiveMusic(true)
	SoundStopInteractiveStream()
	if PedIsValid(tblRaceInfo.race.countdown_ped.id) then
		PedSetFlag(tblRaceInfo.race.countdown_ped.id, 113, false)
		PedSetInvulnerable(tblRaceInfo.race.countdown_ped.id, false)
		PedIgnoreStimuli(tblRaceInfo.race.countdown_ped.id, false)
		PedSetStationary(tblRaceInfo.race.countdown_ped.id, false)
		PedMakeAmbient(tblRaceInfo.race.countdown_ped.id)
		PedMoveToXYZ(tblRaceInfo.race.countdown_ped.id, 0, 337.07733, 274.9468, 7.312996)
	end
	DATUnload(2)
end

function F_NISRace(path, pathlook)
	local x, y, z = PlayerGetPosXYZ()
	F_DeleteUnusedVehicles(x, y, z, 20)
	CameraSetWidescreen(true)
	F_MakePlayerSafeForNIS(true)
	Wait(500)
	F_RacerSpeech(tblRaceInfo, 1)
	CameraFade(500, 1)
	CameraSetPath(path, true)
	CameraLookAtPath(pathlook, true)
	CameraSetSpeed(5, 5, 5)
	CameraLookAtPathSetSpeed(5, 5, 5)
	Wait(1200)
	F_RacerSpeech(tblRaceInfo, 2)
	Wait(1200)
	F_RacerSpeech(tblRaceInfo, 3)
	Wait(1000)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	CameraFade(500, 0)
	Wait(550)
	SoundStopInteractiveStream(0)
	SoundEnableInteractiveMusic(false)
	CameraReturnToPlayer()
	CameraFade(500, 1)
	Wait(1350)
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
end

function F_RacerSpeech(tblOfTheRace, nRacer)
	SoundPlayScriptedSpeechEvent(tblOfTheRace.racers[nRacer].id, "TRASH_TALK_TEAM", 0, "jumbo", nil)
end

function T_Countdown()
	Wait(1000)
	PedSetActionNode(tblRaceInfo.race.countdown_ped.id, "/Global/Race/Countdown", "Act/Anim/Race.act")
end

function T_Petey()
	local x, y, z = PlayerGetPosXYZ()
	local blipPete
	PedPutOnBike(idPeter, peteBike)
	PedMakeTargetable(idPeter, false)
	PedIgnoreAttacks(idPeter, true)
	PedSetFocus(idPeter, gPlayer)
	PedFollowPath(idPeter, PATH._2_04_PETEPATH, 0, 1)
	PedShowHealthBar(idPeter, true, "2_04_PETER", false)
	blipPete = AddBlipForChar(idPeter, 0, 27, 1)
	Wait(5000)
	PedStop(idPeter)
	PedSetPosPoint(idPeter, POINTLIST._2_04_CROWDCHEER, 3)
	while peteyFollow do
		Wait(0)
	end
	PedShowHealthBar(idPeter, false)
	PedSetMissionCritical(idPeter, false)
	BlipRemove(blipPete)
	PedDelete(idPeter)
end

function T_GetBackOnBikeCheck()
	bikeBlip = nil
	local oBlip
	local x, y, z = GetPointList(POINTLIST._2_04_PETER)
	local bFirstMsg
	oBlip = BlipAddXYZ(x, y, z, 0)
	while not (not peteyFollow or bStopBikeThread) do
		Wait(0)
		if not PedIsOnVehicle(gPlayer) then
			if oBlip then
				if not bFirstMsg then
					TextPrint("2_04_INSTRUC01", 4, 1)
					bikeBlip = AddBlipForCar(bike, 0, 4)
					bFirstMsg = true
				else
					TextPrint("RACE_GETONOBJ", 4, 1)
					bikeBlip = AddBlipForCar(PedGetLastVehicle(gPlayer) or bike, 0, 4)
				end
				BlipRemove(oBlip)
				oBlip = nil
			end
		elseif PedIsOnVehicle(gPlayer) and bikeBlip then
			TextPrint("2_04_INSTRUC02", 4, 1)
			oBlip = BlipAddXYZ(x, y, z, 0)
			BlipRemove(bikeBlip)
			bikeBlip = nil
		end
	end
	BlipRemove(oBlip)
	BlipRemove(bikeBlip)
end

function T_ChangeBeachPositions()
	while not PlayerIsInTrigger(TRIGGER._2_04_CHANGEBEACH) do
		Wait(100)
	end
	F_ChangeCheererPositions()
end

function F_CreateMissionEntities()
	if PlayerGetScriptSavedData(23) == 1 then
		AreaTransitionPoint(0, POINTLIST._2_04_RESTARTPLAYER)
		idPeter = PedCreatePoint(134, POINTLIST._2_04_RESTARTPLAYER, 4)
		PedSetFlag(idPeter, 117, false)
		PedSetMissionCritical(idPeter, true, cbCritFail, true)
		peteBike = VehicleCreatePoint(273, POINTLIST._2_04_RESTARTPLAYER, 3)
		bike = VehicleCreatePoint(273, POINTLIST._2_04_RESTARTPLAYER, 2)
	else
		AreaTransitionPoint(0, POINTLIST._2_04_PLAYER)
		idPeter = PedCreatePoint(134, POINTLIST._2_04_PETEYSPAWN, 1)
		PedSetFlag(idPeter, 117, false)
		PedSetMissionCritical(idPeter, true, cbCritFail, true)
		peteBike = VehicleCreatePoint(273, POINTLIST._2_04_PETEYSPAWN, 2)
		bike = VehicleCreatePoint(273, POINTLIST._2_04_PLAYERBIKE, 1)
	end
end

function F_GetBike()
	local x, y, z = GetPointList(POINTLIST._2_04_PETER)
	local objective
	CameraFade(1000, 1)
	objective = MissionObjectiveAdd("2_04_INSTRUC01")
	TextPrint("2_04_INSTRUC01", 4, 1)
	while not PedIsOnVehicle(gPlayer) do
		Wait(0)
	end
	BlipRemove(bikeBlip)
	MissionObjectiveComplete(objective)
end

function F_GetToBeach()
	local x, y, z = GetPointList(POINTLIST._2_04_PETER)
	local blip, objective, prep1, prep2, prep3
	objective = MissionObjectiveAdd("2_04_INSTRUC02")
	TextPrint("2_04_INSTRUC02", 4, 1)
	while not PlayerIsInTrigger(TRIGGER._AMB_RICH_AREA) do
		Wait(0)
	end
	while not (PlayerIsInAreaXYZ(x, y, z, 10, 0) and PedIsOnVehicle(gPlayer)) do
		Wait(0)
	end
	bStopBikeThread = true
	if PedIsValid(tblRaceInfo.race.countdown_ped.id) then
		PedSetInvulnerable(tblRaceInfo.race.countdown_ped.id, true)
	end
	for i, entry in tblCleanup do
		if entry.isPed and PedIsValid(entry.id) then
			--print("INVULNERABLE!!!")
			PedSetInvulnerable(entry.id, true)
		end
	end
	if not bCritFailed then
		BlipRemove(blip)
		CameraFade(1000, 0)
		Wait(1005)
		peteyFollow = false
		MissionObjectiveComplete(objective)
	end
end

function F_EndNIS()
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	CameraFade(500, 0)
	Wait(501)
	RaceDeleteRacers()
	CameraSetWidescreen(true)
	SoundDisableSpeech_ActionTree()
	PlayerSetControl(0)
	F_MakePlayerSafeForNIS(true)
	PlayerDetachFromVehicle(tblPlayer.bike)
	PlayerSetPosPoint(POINTLIST._2_04_NIS_END, 2)
	PedSetPosPoint(tblRaceInfo.race.countdown_ped.id, POINTLIST._2_04_NIS_END, 1)
	Wait(500)
	PedFaceObjectNow(gPlayer, tblRaceInfo.race.countdown_ped.id, 2)
	PedFaceObjectNow(tblRaceInfo.race.countdown_ped.id, gPlayer, 2)
	Wait(10)
	PedFaceObject(gPlayer, tblRaceInfo.race.countdown_ped.id, 2, 1)
	PedFaceObject(tblRaceInfo.race.countdown_ped.id, gPlayer, 3, 1)
	PedLockTarget(gPlayer, tblRaceInfo.race.countdown_ped.id, 3)
	PedLockTarget(tblRaceInfo.race.countdown_ped.id, gPlayer, 3)
	CameraSetFOV(40)
	CameraSetXYZ(329.23877, 277.04636, 7.521709, 329.7032, 276.16272, 7.467021)
	CameraSetWidescreen(true)
	PedSetInvulnerable(tblRaceInfo.race.countdown_ped.id, false)
	PlayerSetInvulnerable(false)
	PedIgnoreStimuli(tblRaceInfo.race.countdown_ped.id, false)
	PedSetStationary(tblRaceInfo.race.countdown_ped.id, false)
	CameraFade(500, 1)
	Wait(500)
	PedSetActionNode(tblRaceInfo.race.countdown_ped.id, "/Global/2_04_Conv/NIS_SUCCESS/Tobias01", "Act/Conv/2_04.act")
	SoundPlayScriptedSpeechEvent(tblRaceInfo.race.countdown_ped.id, "M_2_04", 19, "supersize")
	F_WaitForSpeech(tblRaceInfo.race.countdown_ped.id)
	CameraSetFOV(80)
	CameraSetXYZ(324.55823, 269.22955, 7.751029, 325.4314, 269.66974, 7.960064)
	SoundPlayScriptedSpeechEvent(tblRaceInfo.race.countdown_ped.id, "M_2_04", 21, "supersize", true)
	F_WaitForSpeech(tblRaceInfo.race.countdown_ped.id)
	MinigameSetCompletion("M_PASS", true, 1500)
	MinigameAddCompletionMsg("MRESPECT_PM10", 1)
	SoundPlayMissionEndMusic(true, 8)
	while PedInConversation(gPlayer) do
		Wait(0)
	end
	Wait(5000)
	PedFollowPath(tblRaceInfo.race.countdown_ped.id, PATH._2_04_NIS_END_WALK, 0, 0)
	PedLockTarget(tblRaceInfo.race.countdown_ped.id, -1)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	CameraFade(500, 0)
	Wait(501)
	PedSetMissionCritical(tblRaceInfo.race.countdown_ped.id, false)
	PedDelete(tblRaceInfo.race.countdown_ped.id)
	tblRaceInfo.race.countdown_ped.id = nil
	PedLockTarget(gPlayer, -1)
	CameraDefaultFOV()
	CameraReturnToPlayer(true)
	ConversationMovePeds(true)
end

function drvEndConvo()
	bEndConvo = true
end

function F_CreateCheerer(model, point, element)
	local ped = PedCreatePoint(model, point, element)
	PedIgnoreAttacks(ped, true)
	PedIgnoreStimuli(ped, true)
	PedSetStationary(ped, true)
	PedClearAllWeapons(ped)
	PedSetActionNode(ped, "/Global/2_04_Conv/Cheerage", "Act/Conv/2_04.act")
	return ped
end

function F_CreateBeachPeds()
	tblRaceInfo.race.countdown_ped.id = PedCreatePoint(86, POINTLIST._2_04_OWNER)
	ped1 = PedCreatePoint(30, POINTLIST._2_04_PREP1, 1)
	ped2 = PedCreatePoint(32, POINTLIST._2_04_PREP2, 1)
	ped3 = PedCreatePoint(31, POINTLIST._2_04_PREP3, 1)
	veh1 = VehicleCreatePoint(273, POINTLIST._2_04_PREP1BIKE)
	veh2 = VehicleCreatePoint(273, POINTLIST._2_04_PREP2BIKE)
	veh3 = VehicleCreatePoint(273, POINTLIST._2_04_PREP3BIKE)
	PedSetMissionCritical(tblRaceInfo.race.countdown_ped.id, true, cbCritFailOwner, true)
	PedSetMissionCritical(ped1, true, cbCritFailRacer, true)
	PedSetMissionCritical(ped2, true, cbCritFailRacer, true)
	PedSetMissionCritical(ped3, true, cbCritFailRacer, true)
	return { id = ped1, isPed = true }, { id = ped2, isPed = true }, { id = ped3, isPed = true }, { id = veh1, isPed = false }, { id = veh2, isPed = false }, { id = veh3, isPed = false }
end

function F_CreateBeachCheerers()
	table.insert(tblCleanup, {
		id = F_CreateCheerer(134, POINTLIST._2_04_PETER, 1),
		isPed = true
	})
	table.insert(tblCleanup, {
		id = F_CreateCheerer(25, POINTLIST._2_04_CROWDCHEER, 1),
		isPed = true
	})
	table.insert(tblCleanup, {
		id = F_CreateCheerer(67, POINTLIST._2_04_CROWDCHEER, 2),
		isPed = true
	})
end

function F_ChangeCheererPositions()
	local pos = 1
	for i, entry in tblCleanup do
		if entry.isPed and PedIsValid(entry.id) then
			PedSetEffectedByGravity(entry.id, false)
			PedSetPosPoint(entry.id, POINTLIST._2_04_BEACHCHEERCHANGE, pos)
			PedFaceHeading(entry.id, 0, 0)
		end
		--print("Placed ped at pos: " .. pos)
		pos = pos + 1
	end
	if PedIsValid(tblRaceInfo.race.countdown_ped.id) then
		PedSetPosPoint(tblRaceInfo.race.countdown_ped.id, POINTLIST._2_04_BEACHCHEERCHANGE, 8)
	end
end

function F_CleanTable(table, makeAmbient)
	for i, entry in table do
		if PedIsValid(entry) then
			if makeAmbient then
				PedSetEffectedByGravity(entry, true)
				PedSetInvulnerable(entry, false)
				PedIgnoreAttacks(entry, false)
				PedIgnoreStimuli(entry, false)
				PedMakeTargetable(entry, true)
				PedSetStationary(entry, false)
				PedSetCheap(entry, false)
				PedClearAllWeapons(entry)
				PedSetActionNode(entry, "/Global/2_04_Conv/PlayerIdle", "Act/Conv/2_04.act")
				PedMakeAmbient(entry)
				PedWander(entry, 0)
			else
				PedDelete(entry)
			end
		end
	end
end

function F_BarrierInit()
	AreaLoadSpecialEntities("RL_rich1", true)
	AreaEnsureSpecialEntitiesAreCreated()
end

function F_RaceSetup()
	PlayerSetControl(0)
	AreaOverridePopulation(3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 2, 0, 0)
	SetParam_Player(tblPlayer)
	SetParam_Racers(tblRacer)
	SetParam_Race(tblRace)
	SetParam_HighlightedNodes(tblHighlightedNode)
	SetParam_Shortcuts(tblShortcut)
	RaceSetup()
end

function F_InitTables()
	tblRace = {
		laps = 1,
		path = PATH._2_04_RACE,
		missionCode = "2_04",
		end_mission_on_finish = false,
		countdown_ped = {
			model = 86,
			point = POINTLIST._2_04_OWNER,
			noSpawnBlip = true,
			asleep = true,
			ignoreStimuli = true
		},
		path_smoothing = 1,
		auto_lineup = true,
		soundTrack = "MS_BikeRace01.rsm",
		volume = 1
	}
	tblPlayer = {
		startPosition = POINTLIST._SV_BOYSDORMMAIN,
		visibleArea = 0,
		start_pos = POINTLIST._2_04_PLAYERRICH,
		area_code = 0,
		bike_model = 273
	}
	tblRacer = {
		{
			id = nil,
			bike = nil,
			blip = nil,
			model = 30,
			bike_model = 273,
			max_sprint_speed = 0.69,
			max_normal_speed = 0.67,
			catch_up_dist = 30,
			catch_up_speed = 1.3,
			slow_down_dist = 15,
			slow_down_speed = 0.35,
			shortcut_odds = 0,
			shooting_odds = 0,
			trick_odds = 0,
			target = nil,
			sprint_freq = 0,
			sprint_duration = 0,
			sprint_likelyhood = 0,
			aggressiveness = 0.5,
			point = POINTLIST._2_04_PREP1,
			bike = {
				point = POINTLIST._2_04_PREP1BIKE,
				model = 273
			},
			asleep = true,
			startOnBike = true,
			ignoreStimuli = true,
			noSpawnBlip = true,
			gravity = false
		},
		{
			id = nil,
			bike = nil,
			blip = nil,
			model = 32,
			bike_model = 273,
			max_sprint_speed = 0.69,
			max_normal_speed = 0.67,
			catch_up_dist = 30,
			catch_up_speed = 1.3,
			slow_down_dist = 15,
			slow_down_speed = 0.35,
			shortcut_odds = 0,
			shooting_odds = 0,
			trick_odds = 0,
			target = nil,
			sprint_freq = 0,
			sprint_duration = 0,
			sprint_likelyhood = 0,
			aggressiveness = 0.5,
			point = POINTLIST._2_04_PREP2,
			bike = {
				point = POINTLIST._2_04_PREP2BIKE,
				model = 273
			},
			asleep = true,
			startOnBike = true,
			ignoreStimuli = true,
			noSpawnBlip = true,
			gravity = false
		},
		{
			id = nil,
			bike = nil,
			blip = nil,
			model = 31,
			bike_model = 273,
			max_sprint_speed = 0.69,
			max_normal_speed = 0.67,
			catch_up_dist = 30,
			catch_up_speed = 1.3,
			slow_down_dist = 15,
			slow_down_speed = 0.35,
			shortcut_odds = 0,
			shooting_odds = 0,
			trick_odds = 0,
			target = nil,
			sprint_freq = 0,
			sprint_duration = 0,
			sprint_likelyhood = 0,
			aggressiveness = 0.5,
			point = POINTLIST._2_04_PREP3,
			bike = {
				point = POINTLIST._2_04_PREP3BIKE,
				model = 273
			},
			asleep = true,
			startOnBike = true,
			ignoreStimuli = true,
			noSpawnBlip = true,
			gravity = false
		}
	}
	tblShortcut = {
		{
			path = PATH._2_04_RICHSHORTCUT01,
			start_node = 7,
			end_node = 11
		},
		{
			path = PATH._2_04_RICHSHORTCUT02,
			start_node = 38,
			end_node = 44
		},
		{
			path = PATH._2_04_RICHSHORTCUT03,
			start_node = 46,
			end_node = 54
		},
		{
			path = PATH._2_04_RICHSHORTCUT04,
			start_node = 58,
			end_node = 63
		},
		{
			path = PATH._2_04_RICHSHORTCUT05,
			start_node = 63,
			end_node = 70
		}
	}
	tblHighlightedNode = {
		1,
		2,
		4,
		5,
		7,
		11,
		14,
		18,
		20,
		23,
		25,
		26,
		27,
		30,
		32,
		34,
		35,
		37,
		38,
		40,
		43,
		45,
		46,
		48,
		51,
		53,
		54,
		57,
		59,
		61,
		63,
		66,
		68,
		70
	}
	tblPersistentEntity = {}
	tblRaceInfo = {
		race = tblRace,
		racers = tblRacer,
		fireEvent = tblTireFireEvent
	}
end

function cbCritPlayer()
	shared.gPlayerIncapacitated = true
	TextPrintString("", 1, 1)
end

function F_WaitForSpeech()
	while SoundSpeechPlaying() do
		Wait(0)
	end
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
