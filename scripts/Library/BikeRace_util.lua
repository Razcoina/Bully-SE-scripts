--[[ Changes to this file:
	* Modified function F_AnyRaceFinished, may require testing
	* Modified function F_RaceEndNIS, may require testing
]]

local gReward = 1500
local tblRaceFinishCheck = {
	{
		race = "3_R08_Rich7"
	},
	{
		race = "3_R08_Business4"
	},
	{
		race = "3_R08_Poor2"
	},
	{
		race = "3_R08_School1"
	}
}
local tblFoundPeds = {}
local tblFoundVehicles = {}
local race
local race_default = {
	race_path = nil,
	jump_nodes = {},
	reward = 1000,
	laps = 3,
	head_start = 0,
	countdown_start = 3,
	racer_delay = 100,
	finish_delay = 30,
	missionCode = "",
	soundTrack = "",
	volume = 0.4,
	mission_specific_flag = false,
	countdown_ped = {
		model = nil,
		actionFile = "Act/Anim/Race.act",
		actionNodeStart = "/Global/Race/Countdown/Initialize",
		actionNodeEnd = "/Global/Race/Countdown/Initialize"
	},
	end_mission_on_finish = true,
	path_smoothing = 0.75,
	get_on_delay = 10,
	racer_spacing = 1.3,
	auto_lineup = false,
	cam_offset_x = 0,
	cam_offset_y = -6,
	cam_offset_z = 1.5
}
local player = {
	id = nil,
	bike = nil,
	start_pos = nil,
	area_code = nil,
	bike_start_pos = nil
}
local racers
local racers_default = {
	{
		id = nil,
		bike = nil,
		blip = nil,
		start_pos = nil,
		bike_start_pos = nil,
		ammo = 0,
		weapon = nil,
		model = 16,
		bike_model = 273,
		add_blip = true,
		radarIcon = 2,
		blipStyle = 1,
		max_sprint_speed = 100,
		max_normal_speed = 3.5,
		catch_up_dist = 14,
		catch_up_speed = 1.6,
		slow_down_dist = 13,
		slow_down_speed = 0.85,
		shortcut_odds = 30,
		shooting_odds = 0,
		trick_odds = 0,
		target = nil,
		sprint_freq = 0,
		sprint_duration = 0,
		sprint_likelyhood = 0,
		aggressiveness = 0.5
	}
}
local shortcuts = {
	{
		path = nil,
		start_node = nil,
		end_node = nil,
		jump_nodes = {}
	}
}
local highlighted_nodes = {}
local actions = {
	{
		to_run = nil,
		on_lap = nil,
		is_thread = false,
		params = {}
	}
}
local race_ongoing = true
local debug = 3
local debug_mis_name = "BikeRace_util.lua "
local failTooFar
local nWarningDistance = 60
local nFailDistance = 85

function debug_print(debug_lvl, str)
	if debug_lvl <= debug then
		--print(debug_mis_name .. str)
	end
end

function SetParam_Race(race_param)
	--assert(race_param.path ~= nil, "LUA ERROR: SetParam_Race - path is nil")
	--assert(race_param.missionCode ~= nil, "LUA ERROR: SetParam_Race - Mission Code Not Specified")
	race = race_param
	race.path = race_param.path
	race.laps = race_param.laps or race_default.laps
	race.auto_lineup = F_DefaultIfNil(race_param.auto_lineup, race_default.auto_lineup)
	race.unlock = race_param.unlock
	--print("@@@@@@@auto_lineup was set to " .. tostring(race.auto_lineup))
	if race_param.jump_nodes ~= nil and table.getn(race_param.jump_nodes) > 0 then
		race.jump_nodes = race_param.jump_nodes
	end
	race.reward = race_param.reward or race_default.reward
	race.head_start = race_param.head_start or race_default.head_start
	race.racer_delay = race_param.racer_delay or race_default.racer_delay
	race.countdown_start = race_param.countdown_start or race_default.countdown_start
	race.finish_delay = race_param.finish_delay or race_default.finish_delay
	race.missionCode = race_param.missionCode or race_default.missionCode
	race.soundTrack = race_param.soundTrack or race_default.soundTrack
	race.volume = race_param.volume or race_default.volume
	race.end_mission_on_finish = F_DefaultIfNil(race_param.end_mission_on_finish, race_default.end_mission_on_finish)
	race.path_smoothing = race_param.path_smoothing or race_default.path_smoothing
	race.get_on_delay = race_param.get_on_delay or race_default.get_on_delay
	race.countdown_ped = race.countdown_ped or race_default.countdown_ped
	race.racer_spacing = race.racer_spacing or race_default.racer_spacing
	race.cam_offset_x = race.cam_offset_x or race_default.cam_offset_x
	race.cam_offset_y = race.cam_offset_y or race_default.cam_offset_y
	race.cam_offset_z = race.cam_offset_z or race_default.cam_offset_z
	race.countdown_ped.actionFile = race.countdown_ped.actionFile or race_default.countdown_ped.actionFile
	race.countdown_ped.actionNodeStart = race.countdown_ped.actionNodeStart or race_default.countdown_ped.actionNodeStart
	race.countdown_ped.actionNodeEnd = race.countdown_ped.actionNodeEnd or race_default.countdown_ped.actionNodeEnd
end

function SetParam_Player(player_param)
	--print("ATTENTION: SetParam_Player() running in BikeRace_util.  Get Jak if the game crashed.")
	--assert(player_param.start_pos ~= nil, "LUA ERROR: SetParam_Player - start_pos is nil")
	if player_param.bike_start_pos == nil then
		if race then
			race.auto_lineup = true
		else
			race_default.auto_lineup = true
		end
	end
	player_param.bike_model = player_param.bike_model
	player = player_param
end

function SetParam_Racers(racers_param)
	for i, racer in racers_param do
		if racer.start_pos == nil or racer.bike_start_pos == nil then
			if race then
				race.auto_lineup = true
			else
				race_default.auto_lineup = true
			end
		end
		local default_index = RandomIndex(racers_default)
		racer.start_pos = racer.start_pos
		racer.bike_start_pos = racer.bike_start_pos
		racer.weapon = racer.weapon or racers_default[default_index].weapon
		racer.ammo = racer.ammo or racers_default[default_index].ammo
		racer.model = racer.model or racers_default[default_index].model
		--assert(racer.model ~= nil, "LUA ERROR: SetParam_Racers - Unable to find model for racer " .. i)
		racer.bike_model = racer.bike_model or racers_default[default_index].bike_model
		--assert(racer.bike_model ~= nil, "LUA ERROR: SetParam_Racers - Unable to find bike_model for racer " .. i)
		VehicleRequestModel(racer.bike_model)
		racer.add_blip = racer.add_blip or racers_default[default_index].add_blip
		--assert(racer.add_blip ~= nil, "LUA ERROR: SetParam_Racers - Unable to find add_blip for racer " .. i)
		racer.radarIcon = racer.radarIcon or racers_default[default_index].radarIcon
		--assert(racer.radarIcon ~= nil, "LUA ERROR: SetParam_Racers - Unable to find radarIcon for racer " .. i)
		racer.blipStyle = racer.blipStyle or racers_default[default_index].blipStyle
		--assert(racer.blipStyle ~= nil, "LUA ERROR: SetParam_Racers - Unable to find blipStyle for racer " .. i)
		racer.max_sprint_speed = racer.max_sprint_speed or racers_default[default_index].max_sprint_speed
		--assert(racer.max_sprint_speed ~= nil, "LUA ERROR: SetParam_Racers - Unable to find max_sprint_speed for racer " .. i)
		racer.max_normal_speed = racer.max_normal_speed or racers_default[default_index].max_normal_speed
		--assert(racer.max_normal_speed ~= nil, "LUA ERROR: SetParam_Racers - Unable to find max_normal_speed for racer " .. i)
		racer.catch_up_dist = racer.catch_up_dist or racers_default[default_index].catch_up_dist
		--assert(racer.catch_up_dist ~= nil, "LUA ERROR: SetParam_Racers - Unable to find catch_up_dist for racer " .. i)
		racer.catch_up_speed = racer.catch_up_speed or racers_default[default_index].catch_up_speed
		--assert(racer.catch_up_speed ~= nil, "LUA ERROR: SetParam_Racers - Unable to find catch_up_speed for racer " .. i)
		racer.slow_down_dist = racer.slow_down_dist or racers_default[default_index].slow_down_dist
		--assert(racer.slow_down_dist ~= nil, "LUA ERROR: SetParam_Racers - Unable to find slow_down_dist for racer " .. i)
		racer.slow_down_speed = racer.slow_down_speed or racers_default[default_index].slow_down_speed
		--assert(racer.slow_down_speed ~= nil, "LUA ERROR: SetParam_Racers - Unable to find slow_down_speed for racer " .. i)
		racer.shortcut_odds = racer.shortcut_odds or racers_default[default_index].shortcut_odds
		--assert(racer.shortcut_odds ~= nil, "LUA ERROR: SetParam_Racers - Unable to find shortcut_odds for racer " .. i)
		racer.shooting_odds = racer.shooting_odds or racers_default[default_index].shooting_odds
		--assert(racer.shooting_odds ~= nil, "LUA ERROR: SetParam_Racers - Unable to find shooting_odds for racer " .. i)
		racer.trick_odds = racer.trick_odds or racers_default[default_index].trick_odds
		--assert(racer.trick_odds ~= nil, "LUA ERROR: SetParam_Racers - Unable to find trick_odds for racer " .. i)
		racer.sprint_freq = racer.sprint_freq or racers_default[default_index].sprint_freq
		--assert(racer.sprint_freq ~= nil, "LUA ERROR: SetParam_Racers - Unable to find sprint_freq for racer " .. i)
		racer.sprint_duration = racer.sprint_duration or racers_default[default_index].sprint_duration
		--assert(racer.sprint_duration ~= nil, "LUA ERROR: SetParam_Racers - Unable to find sprint_duration for racer " .. i)
		racer.sprint_likelyhood = racer.sprint_likelyhood or racers_default[default_index].sprint_likelyhood
		--assert(racer.sprint_likelyhood ~= nil, "LUA ERROR: SetParam_Racers - Unable to find sprint_likelyhood for racer " .. i)
		racer.aggressiveness = racer.aggressiveness or racers_default[default_index].aggressiveness
		--assert(racer.aggressiveness ~= nil, "LUA ERROR: SetParam_Racers - Unable to find aggressiveness for racer " .. i)
		racer.target = racer.target or racers_default[default_index].target
	end
	racers = racers_param
end

function SetParam_Shortcuts(shortcuts_param)
	table.remove(shortcuts, 1)
	if shortcuts_param then
		for i, shortcut in shortcuts_param do
			--assert(shortcut.path ~= nil, "LUA ERROR: SetParam_Shortcuts - path nil")
			--assert(shortcut.start_node ~= nil, "LUA ERROR: SetParam_Shortcuts - start_node nil")
			--assert(shortcut.end_node ~= nil, "LUA ERROR: SetParam_Shortcuts - end_node nil")
			local jump_nodes
			if shortcut.jump_nodes ~= nil and table.getn(shortcut.jump_nodes) > 0 then
				jump_nodes = shortcut.jump_nodes
			end
			table.insert(shortcuts, {
				path = shortcut.path,
				start_node = shortcut.start_node,
				end_node = shortcut.end_node,
				jump_nodes = jump_nodes
			})
		end
	end
end

function SetParam_HighlightedNodes(highlighted_nodes_param)
	highlighted_nodes = highlighted_nodes_param
end

function SetParam_Actions(actions_param)
	for i, action in actions_param do
		local new_action = {}
		--assert(action.to_run ~= nil, "LUA ERROR: SetParam_Actions - Unable to find function for action " .. i)
		--assert(action.on_lap ~= nil, "LUA ERROR: SetParam_Actions - Unable to find on_lap for action " .. i)
		new_action.to_run = action.to_run
		new_action.on_lap = action.on_lap
		local default_index = RandomIndex(actions_default)
		new_action.is_thread = actions_param.is_thread or actions_default[default_index].is_thread
		--assert(new_action.is_thread ~= nil, "LUA ERROR: SetParam_Actions - Unable to find AI_file for action " .. i)
		table.insert(actions, new_action)
	end
end

function CreateCountdownPed(race)
	if type(race.countdown_ped) == "table" and race.countdown_ped.model ~= nil and race.countdown_ped.point ~= nil then
		--print("[RACES] >> CreateCountdownPed >> Type check passed")
		if race.countdown_ped.id == nil and race.countdown_ped.model and race.countdown_ped.point then
			--print("[RACES] >> CreateCountdownPed >> Creating")
			race.countdown_ped.id = PedCreatePoint(race.countdown_ped.model, race.countdown_ped.point)
		end
		if race.countdown_ped.id then
			PedSetAsleep(race.countdown_ped.id, true)
			PedIgnoreStimuli(race.countdown_ped.id, true)
		end
	end
end

function CreateRacer(racer)
	racer.id = PedCreatePoint(racer.model, racer.start_pos)
	if racer.add_blip == true then
		racer.blip = AddBlipForChar(racer.id, 2, racer.radarIcon, racer.blipStyle)
	end
	debug_print(1, "CreateRacer after blip")
	while not VehicleRequestModel(racer.bike_model) do
		Wait(0)
	end
	racer.bike = VehicleCreatePoint(racer.bike_model, racer.bike_start_pos)
	PedClearAllWeapons(racer.id)
	if racer.weapon then
		WeaponRequestModel(racer.weapon)
		PedSetWeapon(racer.id, racer.weapon, racer.ammo)
	end
	PedShowHealthBar(racer.id, false)
	PedSetAsleep(racer.id, true)
	PedIgnoreStimuli(racer.id, true)
end

function RacersEnterVehicle(racers)
	for i, racer in racers do
		PedPutOnBike(racer.id, racer.bike)
	end
end

function HighlightNodes(nodes)
	if not mission_specific_flag then
		for i, node in highlighted_nodes do
			debug_print(1, "Highlighted node " .. node)
			RaceAddNodeToHighlight(node)
		end
	end
end

function CreateRacerGroup(racers)
	for i, racer in racers do
		debug_print(1, "About to create racer " .. i)
		CreateRacer(racer)
	end
end

function CreateRacerGroupProc(racers, player, race)
	local Xp, Yp, z = GetPointList(player.start_pos)
	local Xs, Ys = GetPointFromPath(race.path, 0)
	local racerSpacing = race.racer_spacing
	local c_racer = table.getn(racers)
	if math.mod(c_racer, 2) == 0 then
		for i = 1, c_racer do
			local dX, dY = GetSideOffsetDelta(i * racerSpacing, Xp, Yp, Xs, Ys)
			if math.mod(i, 2) == 1 then
				dX, dY = -dX, -dY
			end
			racers[i].id = PedCreateXYZ(racers[i].model, Xp + dX, Yp - dY, z)
			while not VehicleRequestModel(racers[i].bike_model) do
				Wait(0)
			end
			racers[i].bike = VehicleCreateXYZ(racers[i].bike_model, Xp + dX, Yp - dY, z)
			VehicleSetPosXYZ(racers[i].bike, Xp + dX, Yp - dY, z, Xs + dX, Ys - dY, z, true)
			PedPutOnBike(racers[i].id, racers[i].bike)
		end
	else
		local dX, dY = GetSideOffsetDelta(racerSpacing / 2, Xp, Yp, Xs, Ys)
		ManagedPlayerSetPosXYZ(Xp + dX, Yp - dY, z)
		if not player.bike then
			player.bike = VehicleCreateXYZ(player.bike_model, Xp + dX, Yp - dY, z)
		end
		VehicleSetPosXYZ(player.bike, Xp + dX, Yp - dY, z, Xs + dX, Ys - dY, z, true)
		PlayerPutOnBike(player.bike)
		local spacingMultiplier = 1
		for i = 1, c_racer do
			local parity = math.mod(i, 2)
			if parity == 0 then
				spacingMultiplier = spacingMultiplier + 2
			end
			local dX, dY = GetSideOffsetDelta(spacingMultiplier * racerSpacing / 2, Xp, Yp, Xs, Ys)
			if parity == 1 then
				dX, dY = -dX, -dY
			end
			racers[i].id = PedCreateXYZ(racers[i].model, Xp + dX, Yp - dY, z)
			while not VehicleRequestModel(racers[i].bike_model) do
				Wait(0)
			end
			racers[i].bike = VehicleCreateXYZ(racers[i].bike_model, Xp + dX, Yp - dY, z)
			VehicleSetPosXYZ(racers[i].bike, Xp + dX, Yp - dY, z, Xs + dX, Ys - dY, z, true)
			PedPutOnBike(racers[i].id, racers[i].bike)
		end
	end
	F_PedSetOnMark(gPlayer)
	for i, racer in racers do
		debug_print(1, "About to process racer " .. i)
		if racer.add_blip == true then
			racer.blip = AddBlipForChar(racer.id, 2, racer.radarIcon, racer.blipStyle)
		end
		debug_print(1, "CreateRacerGroupProc after blip")
		if racer.weapon then
			WeaponRequestModel(racer.weapon)
			PedSetWeapon(racer.id, racer.weapon, racer.ammo)
		end
		PedShowHealthBar(racer.id, false)
		PedSetAsleep(racer.id, true)
		PedIgnoreStimuli(racer.id, true)
	end
end

function RaceSetupCamProc(race, player)
	local Xp, Yp, z = GetPointList(player.start_pos)
	local Xs, Ys = GetPointFromPath(race.path, 0)
	local Xc, Yc
	local dX, dY = GetSideOffsetDelta(race.cam_offset_x, Xp, Yp, Xs, Ys)
	Xc, Yc = Xp + dX, Yp + dY
	dX, dY = GetBackOffsetDelta(race.cam_offset_y, Xp, Yp, Xs, Ys)
	Xc, Yc = Xc + dX, Yc + dY
	CameraSetXYZ(Xc, Yc, z + race.cam_offset_z, Xs, Ys, z)
	FollowCamDefaultVehicleShot()
end

function AddShortcuts(shortcuts)
	for i, shortcut in shortcuts do
		debug_print(1, "Adding shortcut: path = " .. shortcut.path .. " start_node = " .. shortcut.start_node .. " end_node = " .. shortcut.end_node)
		RaceAddShortcutPath(shortcut.path, shortcut.start_node, shortcut.end_node)
		AddShortcutJump(shortcut)
	end
end

function AddRacers(racers)
	for i, racer in racers do
		RaceAddRacer(racer.id)
	end
end

function AddJumps(race)
	for i, node in race.jump_nodes do
		debug_print(1, "Adding jump for path " .. race.path .. " at node " .. node)
		RaceAddJumpNode(race.path, node)
	end
end

function AddShortcutJump(shortcut)
	if shortcut.jump_nodes ~= nil then
		RaceAddJumpPath(shortcut.path, shortcut.start_node, shortcut.end_node)
		for i, node in shortcut.jump_nodes do
			debug_print(1, "Adding shortcut jump for path " .. shortcut.path .. " at node " .. node)
			RaceAddJumpNode(shortcut.path, node)
		end
	end
end

function WaitForRacersReady(racers)
	local ready = false
	while not ready do
		for i, racer in racers do
			if not PedIsOnVehicle(racer.id) then
				break
			end
		end
		ready = true
	end
end

function WaitForRaceToStart(timer_start)
	debug_print(1, "About to start countdown")
	local flag3 = false
	local flag2 = false
	local flag1 = false
	local flagGo = false
	F_MakePlayerSafeForNIS(true)
	if race.countdown_ped.id ~= nil and race.countdown_ped.actionFile ~= nil and race.countdown_ped.actionNodeStart ~= nil and race.countdown_ped.actionNodeEnd ~= nil then
		ExecuteActionNode(race.countdown_ped.id, race.countdown_ped.actionNodeStart, race.countdown_ped.actionFile)
		while PedIsPlaying(race.countdown_ped.id, race.countdown_ped.actionNodeStart, true) do
			Wait(0)
		end
	else
		Wait(500)
		TextPrint("RACING_3", 1, 1)
		SoundPlay2D("CountBeep")
		Wait(750)
		TextPrint("RACING_2", 1, 1)
		SoundPlay2D("CountBeep")
		Wait(750)
		TextPrint("RACING_1", 1, 1)
		SoundPlay2D("CountBeep")
		Wait(750)
		TextPrint("RACING_GO", 1, 1)
		SoundPlay2D("GoBeep")
		MissionTimerStop()
	end
	CameraReturnToPlayer(false)
	F_MakePlayerSafeForNIS(false)
end

function SetRacerStats(racers)
	for i, racer in racers do
		RaceSetRacerStats(racer.id, racer.max_sprint_speed, racer.max_normal_speed, racer.catch_up_dist, racer.catch_up_speed, racer.slow_down_dist, racer.slow_down_speed, racer.shortcut_odds, racer.shooting_odds, racer.trick_odds, racer.sprint_freq, racer.sprint_duration, racer.sprint_likelyhood, racer.aggressiveness)
		PedOnBikePathSmoothing(racer.id, race.path_smoothing)
	end
end

function PlayerSetup(player)
	player.bike = PedGetLastVehicle(gPlayer)
	PlayerDetachFromVehicle(gPlayer)
	local x, y, z = GetPointList(player.start_pos)
	local px, py, pz = PlayerGetPosXYZ()
	local tblAreaBikes = VehicleFindInAreaXYZ(x, y, z, 15, true)
	if tblAreaBikes then
		for i, bikeID in tblAreaBikes do
			if bikeID ~= player.bike then
				VehicleDelete(bikeID)
			end
		end
	end
	local bike_start_pos = player.bike_start_pos
	--print("bike_start_pos = " .. tostring(bike_start_pos))
	--print("start_pos = " .. tostring(player.start_pos))
	if bike_start_pos == nil or bike_start_pos == -1 then
		bike_start_pos = player.start_pos
	end
	if player.bike and not VehicleIsModel(player.bike, 289) and VehicleIsInAreaXYZ(player.bike, px, py, pz, 10, 0) then
		--print("player.bike FOUND!!!")
		VehicleSetPosPoint(player.bike, bike_start_pos)
	elseif player.bike_model then
		--print("player.bike NOT FOUND!!!")
		player.bike = VehicleCreatePoint(player.bike_model, bike_start_pos)
	end
	ManagedPlayerSetPosPoint(player.start_pos)
	if not race.auto_lineup then
		PedStop(gPlayer)
		PlayerPutOnBike(player.bike)
		F_PedSetOnMark(gPlayer)
	end
end

function RaceSetup()
	debug_print(1, "Start RaceSetup(), before PlayerSetup()")
	PedSetWeaponNow(gPlayer, -1, 0)
	MinigameCreate("RACE", true)
	while MinigameIsReady() == false do
		Wait(0)
	end
	local x, y, z
	PlayerSetup(player)
	if not mission_specific_flag then
		--print("@@@@@RUNNING RACE AREA TRANSITION")
		--print("player.area_code = " .. tostring(player.area_code))
		AreaTransitionPoint(player.area_code, player.start_pos, nil, true)
	end
	--print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@race.auto_lineup = " .. tostring(race.auto_lineup))
	if race.auto_lineup then
		--print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@auto_lineup is on")
		CreateRacerGroupProc(racers, player, race)
		RaceSetupCamProc(race, player)
	else
		--print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@auto_lineup is off")
		CreateRacerGroup(racers)
	end
	debug_print(1, "before create countdown ped")
	CreateCountdownPed(race)
	debug_print(1, "before create racers")
	debug_print(1, "before ordering opponents to mount their bikes")
	RaceSetupRace(race.path, race.laps, table.getn(racers))
	debug_print(1, "before highlighting nodes")
	HighlightNodes(nodes)
	debug_print(1, "before adding shortcuts")
	if 0 < table.getn(shortcuts) and shortcuts[1].path ~= nil then
		AddShortcuts(shortcuts)
	end
	if race.jump_nodes ~= nil and 0 < table.getn(race.jump_nodes) then
		AddJumps(race)
	end
	debug_print(1, "before registering racers with AI")
	if not mission_specific_flag then
		RaceClearResults()
		RaceHUDVisible(true)
	end
	if not race.auto_lineup then
		RacersEnterVehicle(racers)
	end
	for i, racer in racers do
		F_PedSetOnMark(racer.id)
	end
	PlayerSetControl(0)
	debug_print(1, "finished RaceSetup()")
end

function RaceCleanup()
	SoundStopStream()
	RaceHUDVisible(false)
	RaceDeleteRacers()
	RaceCleanUpRace()
	FollowCamDefaultVehicleShot()
	race = nil
	race_default = nil
	player = nil
	racers = nil
	racers_default = nil
	shortcuts = nil
	highlighted_nodes = nil
	actions = nil
	collectgarbage()
	MinigameDestroy()
end

function RaceDeleteRacers()
	for i, racer in racers do
		if PedIsValid(racer.id) then
			RaceRemoveRacer(racer.id)
			PedDelete(racer.id)
		end
		if VehicleIsValid(racer.bike) and PedGetLastVehicle(gPlayer) ~= racer.bike then
			VehicleDelete(racer.bike)
		end
	end
end

function RaceMakeRacersAmbient()
	for i, racer in racers do
		if PedIsValid(racer.id) then
			PedMakeAmbient(racer.id)
			PedWander(racer.id, 4)
		end
		if VehicleIsValid(racer.bike) then
			PedMakeAmbient(racer.bike)
			PedWander(racer.id, 4)
		end
	end
end

function RaceForceEnd()
	race_ongoing = false
end

function RaceWait(waitTime)
	local timerStart = GetTimer()
	while waitTime >= GetTimer() - timerStart do
		for i, racer in racers do
			if RaceHasRacerFinished(racer.id) then
				PedClearObjectives(racer.id)
				PedSetFlag(racer.id, 45, true)
			end
		end
		Wait(0)
	end
end

function RaceControl()
	local bWinState = false
	local szFailReason
	gReward = race.reward
	race.winObjID = MissionObjectiveAdd("RACE_WINOBJ", 0, -1)
	WaitForRacersReady(racers)
	WaitForRaceToStart(race.countdown_start)
	if race.soundTrack ~= "" then
		SoundPlayStream(race.soundTrack, race.volume)
	end
	AddRacers(racers)
	SetRacerStats(racers)
	if 0 < race.head_start then
		RaceStartRace()
		Wait(race.head_start)
		PlayerSetControl(1)
	elseif 0 < race.racer_delay then
		PlayerSetControl(1)
		Wait(race.racer_delay)
		RaceStartRace()
	else
		PlayerSetControl(1)
		RaceStartRace()
	end
	F_PedResetOnMark(gPlayer)
	for i, racer in racers do
		F_PedResetOnMark(racer.id)
	end
	for i, racer in racers do
		PedSetPedToTypeAttitude(racer.id, 13, 0)
	end
	local countingDown = false
	local getOnObjID
	local RacerDistance = 0
	while not (RaceHasRacerFinished(gPlayer) or RaceHasAnyRacerFinished()) and race_ongoing do
		if not shared.gPlayerIncapacitated and not F_AboutToPassOut() then
			if not PedIsOnVehicle(gPlayer) and not countingDown then
				countingDown = true
				MissionTimerStart(race.get_on_delay)
				TextPrint("RACE_GETONOBJ", race.get_on_delay, 1)
				getOnObjID = MissionObjectiveAdd("RACE_GETONOBJ", 0, -1)
			elseif countingDown then
				if PedIsOnVehicle(gPlayer) then
					countingDown = false
					MissionObjectiveRemove(getOnObjID)
					getOnObjID = nil
					TextPrintString("", 0, 1)
					MissionTimerStop()
				elseif MissionTimerHasFinished() then
					countingDown = false
					MissionObjectiveRemove(getOnObjID)
					getOnObjID = nil
					TextPrintString("", 0, 1)
					MissionTimerStop()
					race.getOnTimeOut = true
					race_ongoing = false
				end
			end
			debug_print(5, "looping till race done...")
			if 0 < table.getn(actions) and actions[1].to_run ~= nil then
				for action in actions do
					local current_lap = RaceGetRacerLapNum(gPlayer)
					if action.on_lap == current_lap then
						action.to_run(action.params)
					end
				end
			end
			RacerDistance = F_GetBikersDistance()
			if RacerDistance > nWarningDistance or AreaGetVisible() ~= 0 then
				TextPrint("RACE_FAR", 0.3, 1)
				if RacerDistance > nFailDistance or AreaGetVisible() ~= 0 then
					race_ongoing = false
					countingDown = false
					if getOnObjID then
						MissionObjectiveRemove(getOnObjID)
					end
					getOnObjID = nil
					failTooFar = true
					MissionTimerStop()
				end
			end
		end
		Wait(100)
	end
	debug_print(1, "Main loop in RaceControl() done, running EndMission()")
	bWinState, szFailReason = EndMission(race)
	if bWinState then
		F_RaceEndNIS()
	else
		RaceHUDVisible(false)
	end
	return bWinState, szFailReason, gReward
end

function F_AllRacesFinished()
	--print(">>[F_AllRacesFinished]", "START")
	if not ClothingPlayerOwns("SP_BMXHelmet", 0) then
		local bFinishedRacesCount = 0
		for i, entry in tblRaceFinishCheck do
			if IsMissionCompleated(entry.race) or MissionActiveSpecific(entry.race) then
				--print("[F_AllRacesFinished]", "PASSED MISSION", i)
				bFinishedRacesCount = bFinishedRacesCount + 1
			end
		end
		if bFinishedRacesCount == table.getn(tblRaceFinishCheck) then
			--print("[F_AllRacesFinished]", "FINISH, SUCCEED")
			ClothingGivePlayer("SP_BMXHelmet", 0)
			return true
		end
	end
	--print(">>[F_AllRacesFinished]", "FINISH, FAIL")
	return false
end

function F_AnyRaceFinished() -- ! Modified
	if not ClothingPlayerOwns("SP_BikeHelmet", 0) then
		ClothingGivePlayer("SP_BikeHelmet", 0)
		ClothingGivePlayer("SP_BikeJersey", 1)
		ClothingGivePlayerOutfit("BMX Champion") -- Added this
		return true
	end
end

function F_DeleteUnusedVehicles(x, y, z, radius)
	local tblFoundPeds = {}
	local tblFoundVehicles = {}
	tblFoundPeds = {
		PedFindInAreaXYZ(x, y, z, radius)
	}
	tblFoundVehicles = VehicleFindInAreaXYZ(x, y, z, radius, false)
	--print(tostring(tblFoundPeds), tostring(tblFoundVehicles))
	for i, vehicle in tblFoundVehicles do
		local bDelete = true
		for _, ped in tblFoundPeds do
			--print("TESTING VEHICLE", i, "PED", _)
			if PedIsValid(ped) and PedIsInVehicle(ped, vehicle) then
				--print("TESTING VEHICLE", i, "PED", _, "** PASSED **")
				bDelete = false
			end
		end
		if bDelete then
			--print("DELETING VEHICLE", i)
			VehicleDelete(vehicle)
		end
	end
end

function F_RaceEndNIS() -- ! Modified
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	PedStop(gPlayer)
	F_MakePlayerSafeForNIS(true)
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	CameraFade(500, 0)
	Wait(1505)
	RaceDeleteRacers()
	local x, y, z = PedGetOffsetInWorldCoords(gPlayer, 0.9, 1.8, 1)
	local fx, fy, fz = PedGetOffsetInWorldCoords(gPlayer, 0, 0, 1)
	CameraSetXYZ(x, y, z, fx, fy, fz)
	CameraFade(500, 1)
	Wait(400)
	if PedIsInAnyVehicle(gPlayer) and not VehicleIsModel(VehicleFromDriver(gPlayer), 276) then
		PedSetActionNode(gPlayer, "/Global/Vehicles/Bikes/ScriptCalls/RaceVictory", "Act/Vehicles.act")
	end
	if not MissionActiveSpecific("2_04") or not not MissionActiveSpecific("3_G3") then
		if F_AllRacesFinished() then
			AwardAchievement("THE_CHAMPION") -- Added this
			race.unlock = "3_R08_BMXHELMET"
		elseif F_AnyRaceFinished() and not MissionActiveSpecific("2_04") then
			race.unlock = "3_R08_REWARD"
		end
		MinigameSetCompletion("GKART_YOUWIN", true, gReward, race.unlock)
		SoundPlayMissionEndMusic(true, 8)
		Wait(1500)
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
	else
		MinigameSetCompletion("GKART_YOUWIN", true)
		Wait(200)
	end
	while PedIsPlaying(gPlayer, "/Global/Vehicles/Bikes/ScriptCalls/RaceVictory", true) do
		Wait(0)
	end
	RaceHUDVisible(false)
	Wait(1000)
	CameraFade(500, 0)
	Wait(505)
	F_MakePlayerSafeForNIS(false)
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
	if not MissionActiveSpecific("2_04") or not not MissionActiveSpecific("3_G3") then
		CameraFade(500, 1)
		Wait(500)
	end
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
end

function EndMission(race)
	local failMessage
	race.end_position = RaceGetPositionInRaceOfRacer(gPlayer)
	debug_print(1, "race.end_position = " .. race.end_position)
	local pos = race.end_position
	if pos == 1 and not race.getOnTimeOut and AreaGetVisible() == 0 then
		race.won = true
		if race.winObjID then
			MissionObjectiveComplete(race.winObjID)
		end
		return true
	elseif race.getOnTimeOut then
		if race.getOnTimeOut then
			failMessage = "RACING_L_NOBIKE"
		end
		return false, "RACING_L_NOBIKE"
	elseif failTooFar then
		return false, "RACE_TOOFAR"
	else
		race.won = false
		return false
	end
	if race.end_mission_on_finish == true then
		debug_print(1, "Supposed to end mission on finish")
		if pos == 1 then
			SoundPlayMissionEndMusic(true, 8)
			MissionSucceed(false)
		else
			SoundPlayMissionEndMusic(false, 8)
			if failMessage ~= nil then
				MissionFail(true, true, failMessage)
			else
				MissionFail()
			end
		end
	else
		debug_print(1, "Not supposed to end mission on finish")
	end
	debug_print(1, "Race won: " .. tostring(race.won) .. " in " .. tostring(race))
end

function RaceHasAnyRacerFinished()
	for i, racer in racers do
		if RaceHasRacerFinished(racer.id) then
			return true
		end
	end
	return false
end

function AutoLoseThread()
	local countdown_started = false
	while not (RaceHasFinished() or countdown_started) do
		Wait(0)
		for i, racer in racers do
			if not RaceHasRacerFinished(gPlayer) and RaceHasRacerFinished(racer.id) then
				if not race.mission_specific_flag then
					CreateThread("CountdownStopRaceThread")
				end
				countdown_started = true
				break
			end
		end
	end
end

function StringFormatTime(seconds)
	local mytimeMin = math.floor(seconds / 60)
	local mytimeSec = math.mod(seconds, 60)
	local mytimeFracSec = mytimeSec - math.floor(mytimeSec)
	mytimeFracSec = mytimeFracSec * 100
	local mytimeString = string.format("%2i:%02i.%02i", mytimeMin, mytimeSec, mytimeFracSec)
	return mytimeString
end

function CountdownStopRaceThread()
	if not race.mission_specific_flag then
		debug_print(1, "CountdownStopRaceThread started.")
		TextPrint(race.missionCode .. "_16", 3, 1)
	end
	Wait(2000)
	MissionTimerStart(race.finish_delay)
	while not (MissionTimerHasFinished() or RaceHasRacerFinished(gPlayer)) do
		Wait(100)
	end
	MissionTimerStop()
	race_ongoing = false
end

function main()
end

function F_PedSetOnMark(pedID)
end

function F_PedResetOnMark(pedID)
end

function GetSideOffsetDelta(distance, x1, y1, x2, y2)
	local dX = distance * (y2 - y1) / DistanceBetweenCoords2d(x1, y1, x2, y2)
	local dY = distance * (x2 - x1) / DistanceBetweenCoords2d(x1, y1, x2, y2)
	return dX, dY
end

function GetBackOffsetDelta(distance, x1, y1, x2, y2)
	local dX = distance * (x2 - x1) / DistanceBetweenCoords2d(x1, y1, x2, y2)
	local dY = distance * (y2 - y1) / DistanceBetweenCoords2d(x1, y1, x2, y2)
	return dX, dY
end

function F_RaceCleanup_Junkyard()
	for i, racer in racers do
		PedWarpOutOfCar(racer.id)
		VehicleDelete(racer.bike)
		PedDelete(racer.id)
	end
	RaceHUDVisible(false)
	RaceCleanUpRace()
end

function F_JunkyardRaceSetup()
	PlayerSetup(player)
	CreateRacerGroup(racers)
	RacersEnterVehicle(racers)
	RaceSetupRace(race.path, race.laps, table.getn(racers))
	AddRacers(racers)
	SetRacerStats(racers)
	RaceClearResults()
	RaceHUDVisible(false)
	PlayerSetControl(0)
end

function F_GetBikersList()
	local BikerArray = {}
	for i, racer in racers do
		if PedIsValid(racer.id) then
			table.insert(BikerArray, racer.id)
		end
	end
	return BikerArray
end

function F_GetBikersDistance()
	if RaceGetPositionInRaceOfRacer(gPlayer) == 1 then
		return 0
	end
	local distance
	local foundDistance = 0
	local x1, y1, x2, y2
	x1, y1 = PlayerGetPosXYZ()
	for i, racer in racers do
		if PedIsValid(racer.id) then
			x2, y2 = PedGetPosXYZ(racer.id)
			foundDistance = DistanceBetweenCoords2d(x1, y1, x2, y2)
			if not distance or distance > foundDistance then
				distance = foundDistance
			end
		end
	end
	return distance or 0
end

function L_RaceStart(tblRaceInfo, objective)
	local racers = tblRaceInfo.racers
	local race = tblRaceInfo.race
	race.winObjID = MissionObjectiveAdd("RACE_WINOBJ", 0, -1)
	WaitForRacersReady(racers)
	WaitForRaceToStart(race.countdown_start)
	AddRacers(racers)
	SetRacerStats(racers)
	if race.soundTrack ~= "" then
		SoundPlayStream(race.soundTrack, race.volume)
	end
	if 0 < race.head_start then
		RaceStartRace()
		Wait(race.head_start)
		PlayerSetControl(1)
	elseif 0 < race.racer_delay then
		PlayerSetControl(1)
		Wait(race.racer_delay)
		RaceStartRace()
	else
		PlayerSetControl(1)
		RaceStartRace()
	end
	F_PedResetOnMark(gPlayer)
	for i, racer in racers do
		F_PedResetOnMark(racer.id)
	end
	for i, racer in racers do
		PedSetPedToTypeAttitude(racer.id, 13, 0)
	end
end

function L_RaceStayOnBike(tblRaceInfo, tblObjective)
	if not shared.gPlayerIncapacitated and not F_AboutToPassOut() then
		if not PedIsOnVehicle(gPlayer) and not tblObjective.countingDown then
			local getOnDelay = tblRaceInfo.race.get_on_delay
			tblObjective.countingDown = true
			MissionTimerStart(getOnDelay)
			TextPrint("RACE_GETONOBJ", getOnDelay, 1)
			tblObjective.logID = MissionObjectiveAdd("RACE_GETONOBJ", 0, -1)
		elseif tblObjective.countingDown then
			if PedIsOnVehicle(gPlayer) then
				tblObjective.countingDown = false
				MissionObjectiveRemove(tblObjective.logID)
				tblObjective.logID = nil
				TextPrintString("", 0, 1)
				MissionTimerStop()
			elseif MissionTimerHasFinished() then
				countingDown = false
				MissionObjectiveRemove(tblObjective.logID)
				tblObjective.logID = nil
				TextPrintString("", 0, 1)
				MissionTimerStop()
				tblRaceInfo.race.getOnTimeOut = true
				return true
			end
		end
	end
	return false
end

function L_RaceTooFarBehind()
	local RacerDistance = F_GetBikersDistance()
	if not shared.gPlayerIncapacitated and not F_AboutToPassOut() and RacerDistance and RacerDistance > nWarningDistance then
		TextPrint("RACE_FAR", 0.3, 1)
		if RacerDistance > nFailDistance then
			race_ongoing = false
			countingDown = false
			if getOnObjID then
				MissionObjectiveRemove(getOnObjID)
			end
			getOnObjID = nil
			failTooFar = true
			MissionTimerStop()
			return true
		end
	end
	return false
end

function L_RaceWinNotify()
	TextPrint("RACING_W_GEN", 2, 1)
end

function L_RaceLoseNotify()
	TextPrint("RACING_L_GEN", 2, 1)
end

function L_RaceIsOnGoing(tblRaceInfo)
	local racers = tblRaceInfo.racers
	local race = tblRaceInfo.race
	for i, racer in racers do
		if RaceHasRacerFinished(racer.id) then
			PedClearObjectives(racer.id)
			PedSetFlag(racer.id, 45, true)
		end
	end
	return not RaceHasRacerFinished(gPlayer) and race_ongoing
end

function L_RaceIsOver(tblRaceInfo)
	return not L_RaceIsOnGoing(tblRaceInfo)
end

function L_RaceActionTriggered(tblRaceInfo)
	local actions = tblRaceInfo.actions
	return actions[1] ~= nil and actions[1].to_run ~= nil
end

function L_RaceProcessAction(tblRaceInfo)
	for action in tblRaceInfo.actions do
		local current_lap = RaceGetRacerLapNum(gPlayer)
		if action.on_lap == current_lap then
			action.to_run(action.params)
		end
	end
end

function L_RaceEnd(tblRaceInfo, tblObjective)
	if tblObjective.logID then
		MissionObjectiveComplete(tblObjective.logID)
	end
	EndMission(tblRaceInfo.race)
end

function L_RacePlayerNotFirst(tblRaceInfo)
	for i, racer in tblRaceInfo.racers do
		if RaceHasRacerFinished(racer.id) then
			return true
		end
	end
	return false
end

function L_RaceStartCountdownNotice(tblRaceInfo)
	debug_print(1, "CountdownStopRaceThread started.")
	TextPrint(race.missionCode .. "_16", 3, 1)
	tblRaceInfo.race.countDownStart = GetTimer()
end

function L_RaceStartCountdownNoticeDone(tblRaceInfo)
	return GetTimer() - tblRaceInfo.race.countDownStart > 3000
end

function L_RaceStartCountdown(tblRaceInfo)
	MissionTimerStart(tblRaceInfo.race.finish_delay)
end

function L_RaceCountdownOver()
	return MissionTimerHasFinished() or RaceHasRacerFinished(gPlayer)
end

function L_RaceStopCountdown()
	MissionTimerStop()
end

function L_RacePlayerWon(tblRaceInfo)
	return tblRaceInfo.race.won
end

function F_DefaultIfNil(value, default)
	if value == nil then
		return default
	end
	return value
end

function F_AboutToPassOut()
	local h, m = ClockGet()
	if h == 1 and 59 <= m or 2 <= h and h <= 3 then
		return true
	else
		return false
	end
end
