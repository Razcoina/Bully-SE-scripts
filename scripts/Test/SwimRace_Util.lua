local race
local race_default = {
    race_path = nil,
    jump_nodes = {},
    reward = 1000,
    laps = 3,
    head_start = 0,
    countdown_start = 3,
    racer_delay = 300,
    finish_delay = 30,
    FOV = 70,
    missionCode = "",
    soundTrack = "zzzPat_batucada.rsm",
    volume = 0.4,
    mission_specific_flag = false
}
local player = {
    id = nil,
    bike = nil,
    bike_model = 273,
    start_pos = nil,
    bike_start_pos = nil
}
local racers = {}
local racers_default = {
    {
        id = nil,
        bike = nil,
        blip = nil,
        start_pos = nil,
        bike_start_pos = nil,
        ammo = 0,
        weapon = nil,
        add_blip = true,
        model = 16,
        bike_model = 273,
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
local default_FOV
local debug = 0
local debug_mis_name = "BikeRace_util.lua "

function MAIN_RaceSetup()
    F_PlayerSetup(player)
    F_CreateRacerGroup(racers)
    F_RacersEnterVehicle(racers)
    RaceSetupRace(race.path, race.laps, table.getn(racers))
    F_HighlightNodes(nodes)
    F_AddRacers(racers)
    F_SetRacerStats(racers)
    RaceClearResults()
    RaceHUDVisible(true)
    PlayerSetControl(0)
end

function MAIN_RaceControl()
    default_FOV = CameraGetFOV()
    CameraSetFOV(race.FOV)
    CameraReturnToPlayer(true)
    F_WaitForRaceToStart(race.countdown_start)
    if race.head_start > 0 then
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
    CreateThread("T_AutoLoseThread")
    while not RaceHasRacerFinished(gPlayer) and race_ongoing do
        if 0 < table.getn(actions) and actions[1].to_run ~= nil then
            for action in actions do
                local current_lap = RaceGetRacerLapNum(gPlayer)
                if action.on_lap == current_lap then
                    action.to_run(action.params)
                end
            end
        end
        Wait(100)
    end
    F_EndMission(race)
end

function MAIN_RaceCleanup()
    RaceHUDVisible(false)
    RaceCleanUpRace()
    CameraSetFOV(default_FOV)
end

function EXT_SetParam_Race(race_param)
    race = race_param
    race.path = race_param.path
    race.laps = race_param.laps or race_default.laps
    if race_param.jump_nodes ~= nil and table.getn(race_param.jump_nodes) > 0 then
        race.jump_nodes = race_param.jump_nodes
    end
    race.reward = race_param.reward or race_default.reward
    race.head_start = race_param.head_start or race_default.head_start
    race.racer_delay = race_param.racer_delay or race_default.racer_delay
    race.countdown_start = race_param.countdown_start or race_default.countdown_start
    race.finish_delay = race_param.finish_delay or race_default.finish_delay
    race.FOV = race_param.FOV or race_default.FOV
    race.missionCode = race_param.missionCode or race_default.missionCode
    race.soundTrack = race_param.soundTrack or race_default.soundTrack
    race.volume = race_param.volume or race_default.volume
    race.mission_specific_flag = race_param.mission_specific_flag or race_default.mission_specific_flag
end

function EXT_SetParam_Racers(racers_param)
    for i, racer in racers_param do
        local default_index = RandomIndex(racers_default)
        local new_racer = {}
        new_racer.start_pos = racer.start_pos
        new_racer.bike_start_pos = racer.bike_start_pos
        new_racer.weapon = racer.weapon or racers_default[default_index].weapon
        new_racer.ammo = racer.ammo or racers_default[default_index].ammo
        new_racer.model = racer.model or racers_default[default_index].model
        new_racer.bike_model = racer.bike_model or racers_default[default_index].bike_model
        new_racer.add_blip = racer.add_blip or racers_default[default_index].add_blip
        new_racer.max_sprint_speed = racer.max_sprint_speed or racers_default[default_index].max_sprint_speed
        new_racer.max_normal_speed = racer.max_normal_speed or racers_default[default_index].max_normal_speed
        new_racer.catch_up_dist = racer.catch_up_dist or racers_default[default_index].catch_up_dist
        new_racer.catch_up_speed = racer.catch_up_speed or racers_default[default_index].catch_up_speed
        new_racer.slow_down_dist = racer.slow_down_dist or racers_default[default_index].slow_down_dist
        new_racer.slow_down_speed = racer.slow_down_speed or racers_default[default_index].slow_down_speed
        new_racer.shortcut_odds = racer.shortcut_odds or racers_default[default_index].shortcut_odds
        new_racer.shooting_odds = racer.shooting_odds or racers_default[default_index].shooting_odds
        new_racer.trick_odds = racer.trick_odds or racers_default[default_index].trick_odds
        new_racer.sprint_freq = racer.sprint_freq or racers_default[default_index].sprint_freq
        new_racer.sprint_duration = racer.sprint_duration or racers_default[default_index].sprint_duration
        new_racer.sprint_likelyhood = racer.sprint_likelyhood or racers_default[default_index].sprint_likelyhood
        new_racer.aggressiveness = racer.aggressiveness or racers_default[default_index].aggressiveness
        new_racer.target = racer.target or racers_default[default_index].target
        table.insert(racers, new_racer)
    end
end

function EXT_SetParam_HighlightedNodes(highlighted_nodes_param)
    highlighted_nodes = highlighted_nodes_param
end

function EXT_SetParam_Player(player_param)
    player_param.bike_model = player_param.bike_model or player_default.bike_model
    player = player_param
end

function F_CreateRacerGroup(racers)
    for i, racer in racers do
        F_CreateRacer(racer)
    end
end

function F_CreateRacer(racer)
    racer.id = PedCreatePoint(racer.model, racer.start_pos)
    racer.blip = AddBlipForChar(racer.id, 2, racer.add_blip and 4 or 0)
    racer.bike = VehicleCreatePoint(racer.bike_model, racer.bike_start_pos)
end

function F_AddRacers(racers)
    for i, racer in racers do
        RaceAddRacer(racer.id)
    end
end

function F_SetRacerStats(racers)
    for i, racer in racers do
        RaceSetRacerStats(racer.id, racer.max_sprint_speed, racer.max_normal_speed, racer.catch_up_dist, racer.catch_up_speed, racer.slow_down_dist, racer.slow_down_speed, racer.shortcut_odds, racer.shooting_odds, racer.trick_odds, racer.sprint_freq, racer.sprint_duration, racer.sprint_likelyhood, racer.aggressiveness)
    end
end

function F_RacersEnterVehicle(racers)
    for i, racer in racers do
        PedEnterVehicle(racer.id, racer.bike)
    end
end

function F_HighlightNodes(nodes)
    for i, node in highlighted_nodes do
        RaceAddNodeToHighlight(node)
    end
end

function F_WaitForRaceToStart(timer_start)
    MissionTimerStart(timer_start)
    while not MissionTimerHasFinished() do
        Wait(100)
    end
    MissionTimerStop()
end

function F_EndMission(race)
    Wait(2000)
    local pos = RaceGetPositionInRaceOfRacer(gPlayer)
    if pos == 1 then
        TextPrint(race.missionCode .. "_13", 2, 1)
        PlayerAddMoney(race.reward)
        Wait(2000)
    else
        TextPrint(race.missionCode .. "_14", 2, 1)
        Wait(2000)
    end
end

function T_CheckOnBikeThread()
end

function T_AutoLoseThread()
    local countdown_started = false
    while not (RaceHasFinished() or countdown_started) do
        Wait(0)
        for i, racer in racers do
            if not RaceHasRacerFinished(gPlayer) and RaceHasRacerFinished(racer.id) then
                if not race.mission_specific_flag then
                    CreateThread("T_CountdownStopRaceThread")
                end
                countdown_started = true
                break
            end
        end
    end
end

function T_CountdownStopRaceThread()
    TextPrint(race.missionCode .. "_16", 3, 1)
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

function F_PlayerSetup(player)
    if PedIsOnVehicle(gPlayer) then
        local x, y, z = GetPointList(POINTLIST._HACK_BIKEDUMP)
        PlayerSetPosXYZ(x, y, z)
        PlayerDetachFromVehicle(gPlayer)
    end
    PlayerSetPosPoint(player.start_pos)
    player.bike = VehicleCreatePoint(player.bike_model, player.bike_start_pos)
    VehicleDontCleanup(player.bike)
    Wait(0)
    PlayerPutOnBike(player.bike)
end
