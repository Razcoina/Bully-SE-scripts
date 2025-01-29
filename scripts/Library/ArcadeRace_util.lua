--[[ Changes to this file:
    * Modified function RaceRestartGameClock, may require testing
]]

local mission_running = true
local mission_succeed = false
local racepassed = false
local RaceCompleted = true
local StartHour = 0
local StartMinute = 0
local tblMusicStreams = {
    "ArcRaceMXmidi02SPLASHBED01.rsm",
    "ArcRaceMXmidi02SPLASHBED02.rsm",
    "ArcRaceMXmidi02SPLASHBED03.rsm",
    "ArcRaceMXmidi02SPLASHBED04.rsm",
    "ArcRaceMXmidi02SPLASHBED05.rsm",
    "ArcRaceMXmidi02SPLASHBED06.rsm"
}

function F_Current_Race()
    return shared.gArcadeRaceLevel
end

function F_Set_Current_Race(NewLevel)
    shared.gArcadeRaceLevel = NewLevel
end

function F_Current_Race3D()
    return shared.gArcadeRaceIn3D
end

function F_Set_Current_Race3D(RaceIn3D)
    shared.gArcadeRaceIn3D = RaceIn3D
end

local race = {}
local race_default = {
    race_path = nil,
    jump_nodes = {},
    reward = 1000,
    laps = 3,
    head_start = 100,
    countdown_start = 3,
    finish_delay = 30,
    FOV = 70,
    missionCode = "",
    soundTrack = "",
    volume = 0.4
}
local player = {
    id = nil,
    car = nil,
    car_model = MODELENUM._PEUGEOT,
    start_pos = nil,
    car_start_pos = nil
}
local racers = {}
local racers_default = {
    {
        id = nil,
        car = nil,
        blip = nil,
        start_pos = nil,
        car_start_pos = nil,
        ammo = 0,
        weapon = nil,
        model = 16,
        car_model = 294,
        add_blip = true,
        max_sprint_speed = 35,
        max_normal_speed = 20,
        catch_up_dist = 14,
        catch_up_speed = 1.6,
        slow_down_dist = 13,
        slow_down_speed = 0.85,
        shortcut_odds = 30,
        shooting_odds = 0,
        trick_odds = 0,
        target = { gPlayer },
        aggressiveness = 0
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
local default_FOV
local debug = 3
local debug_mis_name = "ArcadeRace_util.lua "
local mytimeTotalS = 0
local StopRaceThread = -1
local bClockIsPaused = false

function debug_print(debug_lvl, str)
    if debug_lvl <= debug then
        --print(debug_mis_name .. str)
    end
end

function SetParam_Race(race_param)
    --assert(race_param.path ~= nil, "LUA ERROR: SetParam_Race - path is nil")
    --assert(race_param.missionCode ~= nil, "LUA ERROR: SetParam_Race - Mission Code Not Specified")
    race.path = race_param.path
    race.laps = race_param.laps or race_default.laps
    if race_param.jump_nodes ~= nil and table.getn(race_param.jump_nodes) > 0 then
        race.jump_nodes = race_param.jump_nodes
    end
    race.reward = race_param.reward or race_default.reward
    race.head_start = race_param.head_start or race_default.head_start
    race.countdown_start = race_param.countdown_start or race_default.countdown_start
    race.finish_delay = race_param.finish_delay or race_default.finish_delay
    race.FOV = race_param.FOV or race_default.FOV
    race.missionCode = race_param.missionCode or race_default.missionCode
    race.soundTrack = race_param.soundTrack or race_default.soundTrack
    race.volume = race_param.volume or race_default.volume
end

function SetParam_Player(player_param)
    --print("ATTENTION: SetParam_Player() running in ArcadeRace_util.  Get Jak if the game crashed.")
    --assert(player_param.start_pos ~= nil, "LUA ERROR: SetParam_Player - start_pos is nil")
    --assert(player_param.car_start_pos ~= nil, "LUA ERROR: SetParam_Player - car_start_pos is nil")
    player_param.car_model = player_param.car_model or player_default.car_model
    player = player_param
end

function SetParam_Racers(racers_param)
    for i, racer in racers_param do
        --assert(racer.start_pos ~= nil, "LUA ERROR: SetParam_Racers - start_pos of racer " .. i .. " is nil")
        --assert(racer.car_start_pos ~= nil, "LUA ERROR: SetParam_Racers - car_start_pos of racer " .. i .. " is nil")
        local default_index = RandomIndex(racers_default)
        local new_racer = {}
        new_racer.start_pos = racer.start_pos
        new_racer.car_start_pos = racer.car_start_pos
        new_racer.weapon = racer.weapon or racers_default[default_index].weapon
        new_racer.ammo = racer.ammo or racers_default[default_index].ammo
        --print("DEBUG: car_start_pos = " .. new_racer.car_start_pos)
        new_racer.model = racer.model or racers_default[default_index].model
        --assert(new_racer.model ~= nil, "LUA ERROR: SetParam_Racers - Unable to find model for racer " .. i)
        new_racer.car_model = racer.car_model or racers_default[default_index].car_model
        --assert(new_racer.car_model ~= nil, "LUA ERROR: SetParam_Racers - Unable to find car_model for racer " .. i)
        new_racer.add_blip = racer.add_blip or racers_default[default_index].add_blip
        --assert(new_racer.add_blip ~= nil, "LUA ERROR: SetParam_Racers - Unable to find add_blip for racer " .. i)
        new_racer.max_sprint_speed = racer.max_sprint_speed or racers_default[default_index].max_sprint_speed
        --assert(new_racer.max_sprint_speed ~= nil, "LUA ERROR: SetParam_Racers - Unable to find max_sprint_speed for racer " .. i)
        new_racer.max_normal_speed = racer.max_normal_speed or racers_default[default_index].max_normal_speed
        --assert(new_racer.max_normal_speed ~= nil, "LUA ERROR: SetParam_Racers - Unable to find max_normal_speed for racer " .. i)
        new_racer.catch_up_dist = racer.catch_up_dist or racers_default[default_index].catch_up_dist
        --assert(new_racer.catch_up_dist ~= nil, "LUA ERROR: SetParam_Racers - Unable to find catch_up_dist for racer " .. i)
        new_racer.catch_up_speed = racer.catch_up_speed or racers_default[default_index].catch_up_speed
        --assert(new_racer.catch_up_speed ~= nil, "LUA ERROR: SetParam_Racers - Unable to find catch_up_speed for racer " .. i)
        new_racer.slow_down_dist = racer.slow_down_dist or racers_default[default_index].slow_down_dist
        --assert(new_racer.slow_down_dist ~= nil, "LUA ERROR: SetParam_Racers - Unable to find slow_down_dist for racer " .. i)
        new_racer.slow_down_speed = racer.slow_down_speed or racers_default[default_index].slow_down_speed
        --assert(new_racer.slow_down_speed ~= nil, "LUA ERROR: SetParam_Racers - Unable to find slow_down_speed for racer " .. i)
        new_racer.shortcut_odds = racer.shortcut_odds or racers_default[default_index].shortcut_odds
        --assert(new_racer.shortcut_odds ~= nil, "LUA ERROR: SetParam_Racers - Unable to find shortcut_odds for racer " .. i)
        new_racer.shooting_odds = racer.shooting_odds or racers_default[default_index].shooting_odds
        --assert(new_racer.shooting_odds ~= nil, "LUA ERROR: SetParam_Racers - Unable to find shooting_odds for racer " .. i)
        new_racer.trick_odds = racer.trick_odds or racers_default[default_index].trick_odds
        --assert(new_racer.trick_odds ~= nil, "LUA ERROR: SetParam_Racers - Unable to find trick_odds for racer " .. i)
        new_racer.target = racer.target or racers_default[default_index].target
        --assert(table.getn(new_racer.target) > 0, "LUA ERROR: SetParam_Racers - target table has no racers")
        new_racer.aggressiveness = racer.aggressiveness or racers_default[default_index].aggressiveness
        --assert(new_racer.aggressiveness ~= nil, "LUA ERROR: SetParam_Racers - Unable to find aggressiveness for racer " .. i)
        table.insert(racers, new_racer)
    end
end

function SetParam_Shortcuts(shortcuts_param)
    table.remove(shortcuts, 1)
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
        --assert(new_action.is_thread ~= nil, "LUA ERROR: SetParam_Actions - Unable to find AI_file for sniper " .. i)
        table.insert(actions, new_action)
    end
end

function CreateRacer(racer)
    --print("racer.model: ", racer.model)
    racer.id = PedCreatePoint(racer.model, racer.start_pos)
    racer.blip = AddBlipForChar(racer.id, 2, 2, racer.add_blip and 4 or 0)
    debug_print(1, "CreateRacer after blip")
    racer.car = VehicleCreatePoint(racer.car_model, racer.car_start_pos)
    if racer.weapon then
        PedSetWeapon(racer.id, racer.weapon, racer.ammo)
    end
    for i, targetID in racer.target do
        PedLockTarget(racer.id, targetID)
    end
    VehicleStop(racer.car)
end

function RacersEnterVehicle(racers)
    for i, racer in racers do
        PedWarpIntoCar(racer.id, racer.car)
        VehicleStop(racer.car)
    end
end

function HighlightNodes(nodes)
    for i, node in highlighted_nodes do
        debug_print(1, "Highlighted node " .. node)
        RaceAddNodeToHighlight(node)
    end
end

function CreateRacerGroup(racers)
    for i, racer in racers do
        debug_print(1, "About to create racer " .. i)
        CreateRacer(racer)
    end
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
    for i, racer in racers do
        if racer.id and PedIsValid(racer.id) and not PedIsOnVehicle(racer.id) then
            Wait(100)
            if racer.car and VehicleIsValid(racer.car) then
                VehicleStop(racer.car)
            end
        end
    end
end

function WaitForRaceToStart(timer_start)
    if MinigameIsActive() then
        SoundPlay2D("BeepCount")
        TextPrint("Arc_01", 2, 1)
        Wait(1000)
    end
    if MinigameIsActive() then
        SoundPlay2D("BeepCount")
        TextPrint("Arc_02", 2, 1)
        Wait(1000)
    end
    if MinigameIsActive() then
        SoundStopStream()
        SoundPlay2D("Go")
        TextPrint("Arc_03", 2, 1)
        if F_Current_Race() == 1 then
            SoundPlayStream("ArcRaceMXmidi02Drive01.rsm", 1)
        elseif F_Current_Race() == 2 then
            SoundPlayStream("ArcRaceMXmidi02Drive02.rsm", 1)
        elseif F_Current_Race() == 3 then
            SoundPlayStream("ArcRaceMXmidi02Drive03.rsm", 1)
        end
        --print("===done starting stream===")
        for i, racer in racers do
            VehicleFollowPath(racer.car, race.path)
        end
    end
end

function SetRacerStats(racers)
    for i, racer in racers do
        RaceSetRacerStats(racer.id, racer.max_sprint_speed, racer.max_normal_speed, racer.catch_up_dist, racer.catch_up_speed, racer.slow_down_dist, racer.slow_down_speed, racer.shortcut_odds, racer.shooting_odds, racer.trick_odds, 0, 0, 0, racer.aggressiveness)
    end
end

function SetTrackGeometry(TrackObjects)
    for i, object in TrackObjects do
        GeometryInstance(object.name, object.bHidden, object.x, object.y, object.z, object.bCol)
    end
end

function PlayerSetup(player)
    if PedIsOnVehicle(gPlayer) then
        --print("====you are going here===")
        local x, y, z = GetPointList(POINTLIST._HACK_BIKEDUMP)
        PlayerSetPosXYZ(x, y, z)
        PlayerDetachFromVehicle(gPlayer)
    end
    ManagedPlayerSetPosPoint(player.start_pos)
    player.car = VehicleCreatePoint(player.car_model, player.car_start_pos)
    Wait(0)
    PedWarpIntoCar(gPlayer, player.car)
end

function RaceSetup()
    debug_print(1, "Start RaceSetup(), before PlayerSetup()")
    MinigameCreate("RACE", true)
    while MinigameIsReady() == false do
        Wait(0)
    end
    RaceSetArcade()
    AreaDisableCameraControlForTransition(true)
    PlayerSetControl(0)
end

function F_StartRace()
    AreaTransitionPoint(player.area_code, player.start_pos, nil, true)
    --print("==============second fade out============")
    PlayerSetup(player)
    debug_print(1, "before create racers")
    CreateRacerGroup(racers)
    debug_print(1, "before ordering opponents to mount their cars")
    RacersEnterVehicle(racers)
    RaceSetupRace(race.path, race.laps, table.getn(racers), true)
    debug_print(1, "before highlighting nodes")
    HighlightNodes(nodes)
    F_SetupGeo()
    debug_print(1, "before adding shortcuts")
    if table.getn(shortcuts) > 0 and shortcuts[1].path ~= nil then
        AddShortcuts(shortcuts)
    end
    if race.jump_nodes ~= nil and 0 < table.getn(race.jump_nodes) then
        AddJumps(race)
    end
    if snipers_present then
        CreateSnipers(snipers)
    end
    debug_print(1, "before registering racers with AI")
    AddRacers(racers)
    SetRacerStats(racers)
    RaceClearResults()
    RaceHUDVisible(true)
    PlayerSetControl(0)
    MusicFadeWithCamera(false)
end

function RaceStopGameClock()
    StartHour, StartMinute = ClockGet()
    gTimeStarted = GetTimer()
    if ClockIsPaused() then
        bClockIsPaused = true
    end
    PauseGameClock()
    --print("Race start time set = " .. StartHour .. ":" .. StartMinute)
    --print("Game start time set = " .. gTimeStarted)
end

function RaceRestartGameClock() -- ! Modified
    local timePassed = GetTimer() - gTimeStarted
    if not bClockIsPaused then
        --print("Race time started = " .. StartHour .. ":" .. StartMinute)
        --print("Game time started = " .. gTimeStarted)
        --print("Game time ended   = " .. GetTimer())
        --print("Game time passed  = " .. timePassed)
        if StartHour <= 2 then
            StartHour = StartHour + 24
        end
        StartMinute = StartMinute + timePassed / 2000
        --print("Race time ended0  = " .. StartHour .. ":" .. StartMinute)
        while 59 < StartMinute do
            StartMinute = StartMinute - 60
            StartHour = StartHour + 1
            if 25 <= StartHour then
                StartHour = 1
                StartMinute = 0
                break
            end
        end
        if 25 <= StartHour then
            StartHour = 1
            StartMinute = 0
        end
        if 23 < StartHour then
            StartHour = StartHour - 24
        end
        --print("Race time ended1  = " .. StartHour .. ":" .. StartMinute)
    end
    --[[
    if 23 < StartHour then
        StartHour = 23
    end
    if StartHour < 0 then
        StartHour = 0
    end
    if 59 < StartMinute then
        StartMinute = 59
    end
    if StartMinute < 0 then
        StartMinute = 0
    end
    ]] -- Removed this
    ClockSet(StartHour, StartMinute)
    if not bClockIsPaused then
        UnpauseGameClock()
    end
end

function RaceCleanup()
    PedWarpOutOfCar(gPlayer)
    for i, racer in racers do
        if racer.id and PedIsValid(racer.id) then
            PedWarpOutOfCar(racer.id)
        end
    end
    RaceHUDVisible(false)
    RaceCleanUpRace()
    CameraAllowChange(true)
    CameraReturnToPlayer(true)
    if default_FOV then
        CameraSetFOV(default_FOV)
    end
    MinigameDestroy()
end

function RaceControl(TrackObjects)
    --print("inside race control")
    RaceCompleted = false
    default_FOV = CameraGetFOV()
    WaitForRacersReady(racers)
    if MinigameIsActive() then
        TextPrint("Arc_04", 3, 1)
        Wait(3000)
    end
    if MinigameIsActive() then
        WaitForRaceToStart(race.countdown_start)
    end
    if MinigameIsActive() then
        RaceStartRace()
        Wait(race.head_start)
    end
    PlayerSetControl(1)
    local AutoLose
    if MinigameIsActive() then
        AutoLose = CreateThread("AutoLoseThread")
    else
        race_ongoing = false
    end
    while not (not MinigameIsActive() or RaceHasRacerFinished(gPlayer)) and race_ongoing do
        if table.getn(actions) > 0 and actions[1].to_run ~= nil then
            for action in actions do
                local current_lap = RaceGetRacerLapNum(gPlayer)
                if action.on_lap == current_lap then
                    action.to_run(action.params)
                end
            end
        end
        Wait(100)
    end
    if AutoLose ~= nil then
        TerminateThread(AutoLose)
    end
    if StopRaceThread ~= -1 then
    end
    if not MinigameIsActive() then
        SoundFadeoutStream()
        MissionFail(true, false)
    end
    if race and MinigameIsActive() then
        EndMission(race)
    end
    --print("exiting race control")
end

function EndMission(race)
    local pos = RaceGetPositionInRaceOfRacer(gPlayer)
    local nCurrentRace = F_Current_Race()
    PlayerSetControl(0)
    if shared.gArcadeRaceIn3D then
        if pos == 1 then
            CameraAllowChange(true)
            CameraLookAtPlayer(true)
            if nCurrentRace == 1 then
                CameraSetPath(PATH._ARC1_CAM_POS, true)
                VehicleFollowPath(player.car, PATH._ARC1_ARCADERACETRACK)
            elseif nCurrentRace == 2 then
                CameraSetPath(PATH._ARC2_CAMERA_POS, true)
                VehicleFollowPath(player.car, PATH._ARC2_MAINTRACK)
            elseif nCurrentRace == 3 then
                CameraSetPath(PATH._ARC3_CAM_POS, true)
                VehicleFollowPath(player.car, PATH._ARC3_MAINPATH)
            end
        end
    elseif pos == 1 then
        if nCurrentRace == 1 then
            VehicleFollowPath(player.car, PATH._ARC1_ARCADERACETRACK)
        elseif nCurrentRace == 2 then
            VehicleFollowPath(player.car, PATH._ARC2_MAINTRACK)
        elseif nCurrentRace == 3 then
            VehicleFollowPath(player.car, PATH._ARC3_MAINPATH)
        end
    end
    for i, racer in racers do
        PedSetFlag(racer.id, 45, true)
        VehicleStop(racer.car)
    end
    TextPrint("Arc_05", 2, 1)
    SoundStopStream()
    if pos == 1 then
        SoundPlay2D("BUMP06")
        SoundPlayStreamNoLoop("ArcRaceMXmidi02WIN.rsm", 1)
    else
        SoundPlay2D("BUMP07")
        SoundPlayStreamNoLoop("ArcRaceMXmidi02LOSE01.rsm", 1)
    end
    if not MinigameIsActive() then
        SoundFadeoutStream()
        MissionFail(true, false)
        mission_running = false
        return
    end
    Wait(2000)
    if pos == 1 then
        TextPrint("Arc_06", 2, 1)
    elseif pos == 2 then
        TextPrint("Arc_07", 2, 1)
    elseif pos == 3 then
        TextPrint("Arc_08", 2, 1)
    elseif pos == 4 then
        TextPrint("Arc_09", 2, 1)
    elseif pos == 5 then
        TextPrint("Arc_10", 2, 1)
    else
        TextPrint("Arc_11", 2, 1)
    end
    if not MinigameIsActive() then
        SoundFadeoutStream()
        MissionFail(true, false)
        mission_running = false
        return
    end
    Wait(2000)
    if pos == 1 then
        if nCurrentRace == 3 then
            F_Set_Current_Race(4)
            mission_succeed = true
            mission_running = false
            if not F_Current_Race3D() then
                RaceDisplayTransition(0)
                Wait(4000)
                RaceDestroyTransition()
                RaceDisplayTransition(6)
            else
                RaceDisplayTransition(0, true)
                Wait(4000)
                RaceDestroyTransition()
                RaceDisplayTransition(6, true)
            end
            Wait(3500)
            --print("nCurrentRace 3 ======fade out start===")
            CameraFade(500, 0)
            Wait(501)
            --print("======hello move the player===")
        elseif nCurrentRace == 1 then
            TextPrint("Arc_12", 3, 1)
            Wait(1000)
            F_RandomStreamPlay()
            Wait(1000)
            PlayerSetControl(1)
            if not MinigameIsActive() then
                SoundFadeoutStream()
                MissionFail(true, false)
                mission_running = false
            else
                --print("==Calling repeat cleanup==")
                racepassed = true
                MissionRepeatCleanUp()
                --print("==repeat cleanup done, setting race flages to next level==")
                F_Set_Current_Race(2)
                RaceCompleted = true
            end
        elseif nCurrentRace == 2 then
            TextPrint("Arc_12", 3, 1)
            Wait(1000)
            F_RandomStreamPlay()
            Wait(1000)
            PlayerSetControl(1)
            if not MinigameIsActive() then
                SoundFadeoutStream()
                MissionFail(true, false)
                mission_running = false
            else
                racepassed = true
                MissionRepeatCleanUp()
                F_Set_Current_Race(3)
                RaceCompleted = true
            end
        end
    else
        TextPrint("Arc_13", 3, 1)
        Wait(1000)
        F_RandomStreamPlay()
        Wait(1000)
        if PlayerGetMoney() >= 50 or MiniObjectiveGetIsComplete(0) then
            RaceDisplayTransition(8)
            local littleloop = true
            while littleloop do
                if IsButtonPressed(7, 0) then
                    SoundPlay2D("BUMP02")
                    littleloop = false
                    Wait(1000)
                    SoundPlay2D("MoneyIn")
                    if shared.gArcadeRaceIn3D then
                        StatAddToInt(228)
                        if not MiniObjectiveGetIsComplete(0) then
                            PlayerAddMoney(-50, false)
                            StatAddToInt(229, 50)
                        end
                    else
                        StatAddToInt(226)
                        if not MiniObjectiveGetIsComplete(0) then
                            PlayerAddMoney(-50, false)
                            StatAddToInt(227, 50)
                        end
                    end
                    CameraFade(500, 0)
                    Wait(501)
                    RaceDestroyTransition()
                    MissionRepeatSetup()
                elseif IsButtonPressed(8, 0) then
                    SoundPlay2D("BUMP02")
                    littleloop = false
                    RaceDestroyTransition()
                    SoundFadeoutStream()
                    mission_running = false
                    if not F_Current_Race3D() then
                        RaceDisplayTransition(6)
                    else
                        RaceDisplayTransition(6, true)
                    end
                    Wait(3500)
                    CameraFade(500, 0)
                    Wait(501)
                    --print("==you are here==")
                end
                Wait(0)
            end
        else
            if shared.gArcadeRaceIn3D then
                RaceDisplayTransition(6, true)
            else
                RaceDisplayTransition(6)
            end
            SoundFadeoutStream()
            mission_running = false
            Wait(3500)
            CameraFade(500, 0)
            Wait(501)
        end
    end
end

function CheckInCarThread()
    local i
    while not RaceHasFinished() do
        Wait(500)
        for i, racer in racers do
            if RaceHasRacerFinished(racer.id) then
                if racer.blip ~= nil then
                    BlipRemove(racer.blip)
                    racer.blip = nil
                end
                PedStop(racer.id)
            else
            end
        end
    end
    debug_print(1, "CheckInCarThread done")
end

function AutoLoseThread()
    local countdown_started = false
    StopRaceThread = -1
    while not (countdown_started or RaceHasFinished()) do
        Wait(0)
        if MinigameIsActive() then
            for i, racer in racers do
                if not RaceHasRacerFinished(gPlayer) and RaceHasRacerFinished(racer.id) then
                    race_ongoing = false
                    countdown_started = true
                    break
                end
            end
        else
            race_ongoing = false
            countdown_started = true
        end
    end
end

function F_SetupGeo()
end

function F_DisableHUDComponents()
    ToggleHUDComponentVisibility(11, false)
    ToggleHUDComponentVisibility(6, false)
    ToggleHUDComponentVisibility(0, false)
    ToggleHUDComponentVisibility(4, false)
end

function F_EnableHUDComponents()
    ToggleHUDComponentVisibility(11, true)
    ToggleHUDComponentVisibility(6, true)
    ToggleHUDComponentVisibility(0, true)
    ToggleHUDComponentVisibility(4, true)
end

function main()
end

function MissionRepeatSetup()
    --print("MissionRepeatSetup Entry")
    MissionRepeatCleanUp()
    race_ongoing = true
    RaceSetup()
    F_StartRace()
    F_SetUpBoosters()
    if not shared.gArcadeRaceIn3D then
        CameraSetActive(14, 0, false)
    end
    CameraSetFOV(70)
    CameraAllowChange(false)
    CameraFade(500, 1)
    Wait(501)
    --print("Fade back in!")
    RaceControl(TrackObjects)
    --print("MissionRepeatSetup Exit")
end

function MissionRepeatCleanUp()
    CameraFade(500, 0)
    Wait(501)
    RaceCleanup()
    for i, racer in racers do
        if racer.id and PedIsValid(racer.id) then
            PedDelete(racer.id)
        end
    end
    for i, racer in racers do
        if racer.car and VehicleIsValid(racer.car) then
            VehicleDelete(racer.car)
        end
    end
    if player.car and VehicleIsValid(player.car) then
        VehicleDelete(player.car)
    end
    if racepassed then
        racepassed = false
        race = nil
        player = nil
        racers = nil
        collectgarbage()
        race = {}
        player = {}
        racers = {}
    end
end

function MissionCleanUpEnd()
    MusicFadeWithCamera(true)
    RaceCleanup()
    for i, racer in racers do
        if racer.id and PedIsValid(racer.id) then
            PedDelete(racer.id)
        end
    end
    for i, racer in racers do
        if racer.car and VehicleIsValid(racer.car) then
            VehicleDelete(racer.car)
        end
    end
    if player.car and VehicleIsValid(player.car) then
        VehicleDelete(player.car)
    end
    if racepassed then
        racepassed = false
        race = nil
        player = nil
        racers = nil
        collectgarbage()
        race = {}
        player = {}
        racers = {}
    end
end

function F_SetUpBoosters()
    if F_Current_Race() == 1 then
        RaceAddBarrier(-98.31, -9.84, 27.63, -113.03, -9.58, 26.82)
        RaceAddBarrier(-37.44, -51.68, 27.25, -41.43, -41.74, 26.82)
        RaceAddBoostPoint(14.8956, -33.6964, 90)
        RaceAddBoostPoint(4.47953, 68.9892, 270)
        ClockSet(12, 0)
    end
    if F_Current_Race() == 2 then
        RaceAddBarrier(-41.5506, 44.4887, 0.471533, -28.0112, 36.8176, 0.834364)
        RaceAddBoostPoint(173.306, 56.9456, 235)
        RaceAddBoostPoint(-87.2465, -49.3929, 90)
        ClockSet(22, 0)
    end
    if F_Current_Race() == 3 then
        RaceAddBarrier(109.595, -87.8961, 62.4894, 100.759, -81.6735, 62.6203)
        RaceAddBarrier(-95.0424, 56.7946, 62.6542, -106.673, 56.9224, 62.6542)
        RaceAddBoostPoint(18.9915, 62.6205, 270)
        RaceAddBoostPoint(-29.9513, -43.1431, 135)
        RaceAddBoostPoint(113.897, -52.1505, 0)
        ClockSet(12, 0)
    end
end

function F_RandomStreamPlay()
    math.randomseed(GetTimer())
    randomizer = math.random(1, 6)
    SoundPlayStream(tblMusicStreams[randomizer], 1)
end

function F_mission_running()
    if mission_running then
        return true
    else
        return false
    end
end

function F_mission_succeed()
    if mission_succeed then
        return true
    else
        return false
    end
end

function F_RaceCompleted()
    if RaceCompleted then
        return true
    else
        return false
    end
end
