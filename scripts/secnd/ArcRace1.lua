ImportScript("Library/ArcadeRace_util.lua")
local debug_level = 2
local race, player, racers, shortcuts, highlighted_nodes, Px, Py, Pz, PLAYER_AREA, heading
local bFinishPrematurely = false

function MissionSetup()
	RaceStopGameClock()
	F_Set_Current_Race(1)
	LoadAnimationGroup("Go_Cart")
	Px, Py, Pz = PlayerGetPosXYZ()
	PLAYER_AREA = AreaGetVisible()
	heading = PedGetHeading(gPlayer)
	--print("Player's position: ", Px, Py, Pz)
	--print("Visible area: ", PLAYER_AREA)
	--print("Heading: ", heading)
	AreaClearAllPeds()
	RaceOverridePlayerPos(Px, Py, Pz)
	DisablePunishmentSystem(true)
	SoundDisableSpeech()
	SoundStopCurrentSpeechEvent()
	SoundDisableSpeech_ActionTree()
	SoundStopAmbiences()
	LoadVehicleModels({
		285,
		298,
		287
	})
	LoadPedModels({
		8,
		11,
		7
	})
end

function MissionCleanup()
	--print("==calling cleanup==")
	RaceRestartGameClock()
	MusicFadeWithCamera(true)
	SoundStopStream()
	SoundEnableSpeech()
	SoundEnableSpeech_ActionTree()
	SoundRestartAmbiences()
	MissionCleanUpEnd()
	VehicleRevertToDefaultAmbient()
	UnLoadAnimationGroup("Go_Cart")
	DATUnload(2)
	F_EnableHUDComponents()
	DisablePunishmentSystem(false)
	PlayerSetPosXYZArea(Px, Py, Pz, PLAYER_AREA)
	Wait(500)
	PlayerFaceHeadingNow(90)
	Wait(500)
	Px, Py, Pz = PlayerGetPosXYZ()
	PLAYER_AREA = AreaGetVisible()
	heading = PedGetHeading(gPlayer)
	--print("Player's position: ", Px, Py, Pz)
	--print("Visible area: ", PLAYER_AREA)
	--print("Heading: ", heading)
	CameraReturnToPlayer()
	AreaDisableCameraControlForTransition(false)
	if not bFinishPrematurely then
		MissionDontFadeInAfterCompetion()
	else
		CameraFade(500, 1)
		Wait(501)
	end
end

function main()
	--print("==StartingMain==")
	shared.gArcadeRaceIn3D = false
	while F_mission_running() do
		if F_RaceCompleted() then
			--print("==Starting RaceInit==")
			RaceInit()
			if bFinishPrematurely then
				break
			end
		end
		Wait(0)
	end
	if F_mission_succeed() then
		MissionSucceed(true, false, false)
	else
		SoundPlayMissionEndMusic(false, 10)
		MissionFail(true, false)
	end
	--print("==EndingMain==")
end

function RaceInit()
	MusicFadeWithCamera(false)
	if F_Current_Race() == 1 then
		SoundPlayStream("ArcRaceMXmidi02SPLASH.rsm", 1)
		RaceOneInit()
	elseif F_Current_Race() == 2 then
		--print("==Setup Race Two ==")
		race = nil
		player = nil
		racers = nil
		collectgarbage()
		race = {}
		player = {}
		racers = {}
		RaceTwoInit()
	elseif F_Current_Race() == 3 then
		--print("==Setup Race Three ==")
		race = nil
		player = nil
		racers = nil
		collectgarbage()
		race = {}
		player = {}
		racers = {}
		RaceThreeInit()
	end
	--print("==Done Init Races ==")
	VehicleOverrideAmbient(0, 0, 0, 0)
	SetParam_Race(race)
	SetParam_Player(player)
	SetParam_Racers(racers)
	SetParam_HighlightedNodes(highlighted_nodes)
	SetParam_Shortcuts(shortcuts)
	--print("==Done Setting up other params, starting RaceSetup ==")
	RaceSetup()
	if F_Current_Race() == 1 then
		local ScreenLoop = true
		RaceDisplayTransition(1)
		Wait(1500)
		CameraFade(1000, 0)
		Wait(500)
		CameraFade(1000, 1)
		RaceDestroyTransition()
		RaceDisplayTransition(5)
		while ScreenLoop == true do
			if not MinigameIsActive() then
				SoundPlay2D("BUMP02")
				bFinishPrematurely = true
				ScreenLoop = false
				CameraFade(500, 0)
				Wait(501)
			elseif IsButtonBeingPressed(7, 0) then
				SoundPlay2D("BUMP02")
				ScreenLoop = false
			elseif IsButtonBeingPressed(9, 0) then
				SoundPlay2D("BUMP02")
				RaceDisplayTransition(7)
			end
			Wait(0)
		end
		if not bFinishPrematurely then
			RaceDestroyTransition()
			RaceDisplayTransition(2)
		end
	elseif F_Current_Race() == 2 then
		RaceDisplayTransition(3)
	elseif F_Current_Race() == 3 then
		RaceDisplayTransition(4)
	end
	if not bFinishPrematurely then
		F_StartRace()
		F_SetUpBoosters()
		F_DisableHUDComponents()
		CameraFade(1000, 1)
		Wait(2500)
		CameraFade(500, 0)
		Wait(501)
		RaceDestroyTransition()
		CameraSetActive(14, 0, false)
		CameraSetFOV(70)
		CameraAllowChange(false)
		CameraFade(1000, 1)
		Wait(1001)
		RaceControl(TrackObjects)
	end
end

function RaceOneInit()
	DATLoad("ArcadeRace.DAT", 2)
	DATInit()
	--print("==done loading .dat==")
	race = {
		laps = 3,
		path = PATH._ARC1_ARCADERACETRACK,
		missionCode = "Arcade Race Level 1"
	}
	player = {
		id = nil,
		car = nil,
		start_pos = POINTLIST._ARC1_RACEPOS4,
		area_code = 51,
		car_model = 285,
		car_start_pos = POINTLIST._ARC1_RACEPOS4
	}
	racers = {
		{
			id = nil,
			car = nil,
			blip = nil,
			start_pos = POINTLIST._ARC1_RACEPOS1,
			car_start_pos = POINTLIST._ARC1_RACEPOS1,
			model = 8,
			car_model = 298,
			max_sprint_speed = 27,
			max_normal_speed = 23,
			catch_up_dist = 1,
			catch_up_speed = 1.2,
			slow_down_dist = 10,
			slow_down_speed = 0.6,
			shortcut_odds = 30,
			shooting_odds = 0,
			trick_odds = 0,
			aggressiveness = 0.1
		},
		{
			id = nil,
			car = nil,
			blip = nil,
			start_pos = POINTLIST._ARC1_RACEPOS2,
			car_start_pos = POINTLIST._ARC1_RACEPOS2,
			model = 11,
			car_model = 287,
			max_sprint_speed = 27,
			max_normal_speed = 23,
			catch_up_dist = 1,
			catch_up_speed = 1.2,
			slow_down_dist = 10,
			slow_down_speed = 0.6,
			shortcut_odds = 30,
			shooting_odds = 0,
			trick_odds = 0,
			aggressiveness = 0.1
		},
		{
			id = nil,
			car = nil,
			blip = nil,
			start_pos = POINTLIST._ARC1_RACEPOS3,
			car_start_pos = POINTLIST._ARC1_RACEPOS3,
			model = 7,
			car_model = 298,
			max_sprint_speed = 27,
			max_normal_speed = 23,
			catch_up_dist = 1,
			catch_up_speed = 1.2,
			slow_down_dist = 10,
			slow_down_speed = 0.6,
			shortcut_odds = 30,
			shooting_odds = 0,
			trick_odds = 0,
			aggressiveness = 0.1
		}
	}
	shortcuts = {
		{
			path = PATH._ARC1_RACETRACKSHORTCUT1,
			start_node = 23,
			end_node = 28
		},
		{
			path = PATH._ARC1_RACETRACKSHORTCUT2,
			start_node = 12,
			end_node = 22
		}
	}
	highlighted_nodes = {
		1,
		12,
		21,
		27,
		35,
		-2
	}
	TrackObjects = {}
	ClockSet(12, 0)
end

function RaceTwoInit()
	DATLoad("ArcadeRace2.DAT", 2)
	DATInit()
	race = {
		laps = 3,
		path = PATH._ARC2_MAINTRACK,
		missionCode = "Arcade Race Level 2"
	}
	player = {
		id = nil,
		car = nil,
		start_pos = POINTLIST._ARC2_RACEPOS4,
		area_code = 52,
		car_model = 285,
		car_start_pos = POINTLIST._ARC2_RACEPOS4
	}
	racers = {
		{
			id = nil,
			car = nil,
			blip = nil,
			start_pos = POINTLIST._ARC2_RACEPOS1,
			car_start_pos = POINTLIST._ARC2_RACEPOS1,
			model = 8,
			car_model = 287,
			max_sprint_speed = 27,
			max_normal_speed = 24,
			catch_up_dist = 1,
			catch_up_speed = 1.2,
			slow_down_dist = 10,
			slow_down_speed = 0.6,
			shortcut_odds = 30,
			shooting_odds = 0,
			trick_odds = 0,
			aggressiveness = 0.1
		},
		{
			id = nil,
			car = nil,
			blip = nil,
			start_pos = POINTLIST._ARC2_RACEPOS2,
			car_start_pos = POINTLIST._ARC2_RACEPOS2,
			model = 11,
			car_model = 298,
			max_sprint_speed = 27,
			max_normal_speed = 24,
			catch_up_dist = 1,
			catch_up_speed = 1.2,
			slow_down_dist = 10,
			slow_down_speed = 0.6,
			shortcut_odds = 30,
			shooting_odds = 0,
			trick_odds = 0,
			aggressiveness = 0.1
		},
		{
			id = nil,
			car = nil,
			blip = nil,
			start_pos = POINTLIST._ARC2_RACEPOS3,
			car_start_pos = POINTLIST._ARC2_RACEPOS3,
			model = 7,
			car_model = 287,
			max_sprint_speed = 27,
			max_normal_speed = 23.5,
			catch_up_dist = 1,
			catch_up_speed = 1.2,
			slow_down_dist = 10,
			slow_down_speed = 0.6,
			shortcut_odds = 30,
			shooting_odds = 0,
			trick_odds = 0,
			aggressiveness = 0.1
		}
	}
	shortcuts = {
		{
			path = PATH._ARC2_SHORTTRACK,
			start_node = 22,
			end_node = 36
		}
	}
	highlighted_nodes = {
		1,
		3,
		7,
		10,
		14,
		20,
		22,
		36,
		-2
	}
	TrackObjects = {}
	ClockSet(22, 0)
end

function RaceThreeInit()
	DATLoad("ArcadeRace3.DAT", 2)
	DATInit()
	race = {
		laps = 3,
		path = PATH._ARC3_MAINPATH,
		missionCode = "Arcade Race Level 3"
	}
	player = {
		id = nil,
		car = nil,
		start_pos = POINTLIST._ARC3_RACEPOS4,
		area_code = 53,
		car_model = 285,
		car_start_pos = POINTLIST._ARC3_RACEPOS4
	}
	racers = {
		{
			id = nil,
			car = nil,
			blip = nil,
			start_pos = POINTLIST._ARC3_RACEPOS1,
			car_start_pos = POINTLIST._ARC3_RACEPOS1,
			model = 8,
			car_model = 298,
			max_sprint_speed = 27,
			max_normal_speed = 24,
			catch_up_dist = 1,
			catch_up_speed = 1.2,
			slow_down_dist = 10,
			slow_down_speed = 0.6,
			shortcut_odds = 30,
			shooting_odds = 0,
			trick_odds = 0,
			aggressiveness = 0.1
		},
		{
			id = nil,
			car = nil,
			blip = nil,
			start_pos = POINTLIST._ARC3_RACEPOS2,
			car_start_pos = POINTLIST._ARC3_RACEPOS2,
			model = 11,
			car_model = 298,
			max_sprint_speed = 27,
			max_normal_speed = 23.5,
			catch_up_dist = 1,
			catch_up_speed = 1.2,
			slow_down_dist = 10,
			slow_down_speed = 0.6,
			shortcut_odds = 30,
			shooting_odds = 0,
			trick_odds = 0,
			aggressiveness = 0.1
		},
		{
			id = nil,
			car = nil,
			blip = nil,
			start_pos = POINTLIST._ARC3_RACEPOS3,
			car_start_pos = POINTLIST._ARC3_RACEPOS3,
			model = 7,
			car_model = 287,
			max_sprint_speed = 28,
			max_normal_speed = 23.5,
			catch_up_dist = 1,
			catch_up_speed = 1.2,
			slow_down_dist = 10,
			slow_down_speed = 0.6,
			shortcut_odds = 30,
			shooting_odds = 0,
			trick_odds = 0,
			aggressiveness = 0.1
		},
		{
			id = nil,
			car = nil,
			blip = nil,
			start_pos = POINTLIST._ARC3_RACEPOS5,
			car_start_pos = POINTLIST._ARC3_RACEPOS5,
			model = 7,
			car_model = 298,
			max_sprint_speed = 27,
			max_normal_speed = 23,
			catch_up_dist = 1,
			catch_up_speed = 1.2,
			slow_down_dist = 10,
			slow_down_speed = 0.6,
			shortcut_odds = 30,
			shooting_odds = 0,
			trick_odds = 0,
			aggressiveness = 0.1
		}
	}
	shortcuts = {
		{
			path = PATH._ARC3_SHORT1,
			start_node = 1,
			end_node = 12
		},
		{
			path = PATH._ARC3_SHORT2,
			start_node = 30,
			end_node = 38
		}
	}
	highlighted_nodes = {
		1,
		12,
		18,
		23,
		25,
		28,
		30,
		38,
		42,
		46,
		49,
		50,
		-2
	}
	TrackObjects = {}
	ClockSet(12, 0)
end
