local GeoTable = {}
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
    soundTrack = "MS_GoKart 01.rsm",
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
local debug = 0
local debug_mis_name = "CarRace_util.lua "
local mytimeTotalS = 0
local bLose = false

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
    race.timeToBeat = race_param.timeToBeat
end

function SetParam_Player(player_param)
    --print("ATTENTION: SetParam_Player() running in CarRace_util.  Get Jak if the game crashed.")
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
    racer.id = PedCreatePoint(racer.model, racer.start_pos)
    racer.blip = AddBlipForChar(racer.id, 2, 2, racer.add_blip and 1 or 0)
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
        if not PedIsOnVehicle(racer.id) then
            Wait(100)
            VehicleStop(racer.car)
        end
    end
end

function WaitForRaceToStart(timer_start)
    MissionTimerStart(timer_start)
    local flag3 = false
    local flag2 = false
    local flag1 = false
    local flagGo = false
    while not MissionTimerHasFinished() do
        Wait(100)
        if MissionTimerGetTimeRemaining() == 3 and flag3 == false then
            flag3 = true
            if AreaGetVisible() == 42 then
                GeometryInstance("TGK_StartGo", true, -350.963, 493.747, 4.48503, false)
                GeometryInstance("TGK_StartR3", true, -350.878, 493.308, 4.48503, false)
                GeometryInstance("TGK_StartR2", true, -350.791, 492.855, 4.48503, false)
                GeometryInstance("TGK_StartR1", false, -350.705, 492.403, 4.48503, false)
            end
            SoundPlay2D("CountBeep")
        elseif MissionTimerGetTimeRemaining() == 2 and flag2 == false then
            flag2 = true
            if AreaGetVisible() == 42 then
                GeometryInstance("TGK_StartGo", true, -350.963, 493.747, 4.48503, false)
                GeometryInstance("TGK_StartR3", true, -350.878, 493.308, 4.48503, false)
                GeometryInstance("TGK_StartR2", false, -350.791, 492.855, 4.48503, false)
                GeometryInstance("TGK_StartR1", false, -350.705, 492.403, 4.48503, false)
            end
            SoundPlay2D("CountBeep")
        elseif MissionTimerGetTimeRemaining() == 1 and flag1 == false then
            flag1 = true
            if AreaGetVisible() == 42 then
                GeometryInstance("TGK_StartGo", true, -350.963, 493.747, 4.48503, false)
                GeometryInstance("TGK_StartR3", false, -350.878, 493.308, 4.48503, false)
                GeometryInstance("TGK_StartR2", false, -350.791, 492.855, 4.48503, false)
                GeometryInstance("TGK_StartR1", false, -350.705, 492.403, 4.48503, false)
            end
            SoundPlay2D("CountBeep")
        elseif MissionTimerGetTimeRemaining() == 0 and flagGo == false then
            flagGo = true
            if AreaGetVisible() == 42 then
                GeometryInstance("TGK_StartGo", false, -350.963, 493.747, 4.48503, false)
                GeometryInstance("TGK_StartR3", true, -350.878, 493.308, 4.48503, false)
                GeometryInstance("TGK_StartR2", true, -350.791, 492.855, 4.48503, false)
                GeometryInstance("TGK_StartR1", true, -350.705, 492.403, 4.48503, false)
            end
            SoundPlay2D("GoBeep")
        end
    end
    MissionTimerStop()
    for i, racer in racers do
        VehicleFollowPath(racer.car, race.path)
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
        local x, y, z = GetPointList(POINTLIST._HACK_BIKEDUMP)
        PlayerSetPosXYZ(x, y, z)
        PlayerDetachFromVehicle(gPlayer)
    end
    PlayerSetPosPoint(player.start_pos)
    player.car = VehicleCreatePoint(player.car_model, player.car_start_pos)
    Wait(0)
    PedWarpIntoCar(gPlayer, player.car)
end

function RaceSetup()
    PauseGameClock()
    debug_print(1, "Start RaceSetup(), before PlayerSetup()")
    MinigameCreate("RACE", true)
    while MinigameIsReady() == false do
        Wait(0)
    end
    AreaTransitionPoint(AreaGetVisible(), player.start_pos)
    PlayerSetup(player)
    debug_print(1, "before create racers")
    CreateRacerGroup(racers)
    debug_print(1, "before ordering opponents to mount their cars")
    RacersEnterVehicle(racers)
    RaceSetupRace(race.path, race.laps, table.getn(racers))
    debug_print(1, "before highlighting nodes")
    HighlightNodes(nodes)
    F_SetupGeo()
    debug_print(1, "before adding shortcuts")
    if 0 < table.getn(shortcuts) and shortcuts[1].path ~= nil then
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
end

function RaceCleanup()
    F_DestroyGeo()
    if shared.GoKartRaceType ~= 0 then
        PedWarpOutOfCar(gPlayer)
        PlayerSetPosPoint(player.start_pos)
        VehicleDelete(player.car)
    end
    if shared.GoKartRaceType == 0 then
        VehicleMakeAmbient(player.car)
    end
    for i, racer in racers do
        PedWarpOutOfCar(racer.id)
    end
    SoundFadeoutStream()
    RaceHUDVisible(false)
    RaceCleanUpRace()
    MinigameSetElapsedGameTime(1, 0)
    UnpauseGameClock()
    MinigameDestroy()
end

function CountdownStopRaceThread()
    debug_print(1, "CountdownStopRaceThread started.")
    TextPrint("GKART_TIMELIMIT", 1, 1)
    Wait(2000)
    MissionTimerStart(race.finish_delay)
    while not (MissionTimerHasFinished() or RaceHasRacerFinished(gPlayer)) do
        Wait(100)
    end
    MissionTimerStop()
    race_ongoing = false
end

function CheckInCarThread()
    local i
    while not RaceHasFinished() do
        Wait(500)
        for i, racer in racers do
            if not PedIsInVehicle(racer.id, racer.car) then
                debug_print(2, "putting ped " .. racer.id .. " back in car " .. racer.car)
                PedWarpIntoCar(racer.id, racer.car)
            end
            if RaceHasRacerFinished(racer.id) then
                if racer.blip ~= nil then
                    BlipRemove(racer.blip)
                    racer.blip = nil
                end
                PedStop(racer.id)
            else
            end
        end
        if not PedIsInVehicle(gPlayer, player.car) and bLose == false then
            bLose = true
            race_ongoing = false
        end
    end
    debug_print(1, "CheckInCarThread done")
end

function AutoLoseThread()
    local countdown_started = false
    while not (RaceHasFinished() or countdown_started) do
        Wait(0)
        for i, racer in racers do
            if not RaceHasRacerFinished(gPlayer) and RaceHasRacerFinished(racer.id) then
                CreateThread("CountdownStopRaceThread")
                countdown_started = true
                break
            end
        end
    end
end

function RaceControl(TrackObjects)
    default_FOV = CameraGetFOV()
    WaitForRacersReady(racers)
    TextPrint("GKART_WINRACE", 3, 1)
    Wait(3000)
    if shared.GoKartRaceType == 0 then
        --print("time to beat****** " .. race.timeToBeat)
        local RaceString = StringFormatTime(race.timeToBeat)
        --print("RaceString =" .. RaceString)
        TextAddNonLocalizedString(RaceString)
        TextPrintF("GKART_TIME2BEAT", 3, 1)
        Wait(3000)
    end
    WaitForRaceToStart(race.countdown_start)
    SoundPlayStream(race.soundTrack, race.volume)
    RaceStartRace()
    Wait(race.head_start)
    PlayerSetControl(1)
    CreateThread("CheckInCarThread")
    CreateThread("AutoLoseThread")
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
    EndMission(race)
end

function EndMission(race)
    TextPrint("GKART_RACEOVER", 2, 1)
    Wait(2000)
    local pos = RaceGetPositionInRaceOfRacer(gPlayer)
    if bLose ~= true then
        if shared.GoKartRaceType == 1 then
            if pos == 1 then
                TextPrint("GKART_1ST", 2, 1)
                Wait(2000)
            elseif pos == 2 then
                TextPrint("GKART_2ND", 2, 1)
                Wait(2000)
            elseif pos == 3 then
                TextPrint("GKART_3RD", 2, 1)
                Wait(2000)
            elseif pos == 4 then
                TextPrint("GKART_4TH", 2, 1)
                Wait(2000)
            elseif pos == 5 then
                TextPrint("GKART_5TH", 2, 1)
                Wait(2000)
            elseif pos == 6 then
                TextPrint("GKART_6TH", 2, 1)
                Wait(2000)
            end
            if pos == 1 then
                shared.gGoKartGPLevel = shared.gGoKartGPLevel + 1
                TextPrint("GKART_YOUWON", 3, 1)
                Wait(3000)
            else
                TextPrint("GKART_NEXTTIME", 3, 1)
                Wait(3000)
            end
        elseif shared.GoKartRaceType == 0 then
            if mytimeTotalS <= race.timeToBeat then
                TextPrint("GKART_YOUWON", 3, 1)
                shared.gGoKartSRLevel = shared.gGoKartSRLevel + 1
                Wait(3000)
            else
                TextPrint("GKART_NEXTTIME", 3, 1)
                Wait(3000)
            end
        end
        SoundPlayMissionEndMusic(true, 10)
        MissionSucceed()
    else
        SoundPlayMissionEndMusic(false, 10)
        MissionFail()
    end
end

function StringFormatTime(seconds)
    --print("Seconds==" .. seconds)
    local mytimeMin = math.floor(seconds / 60)
    --print("myTimeMin==" .. mytimeMin)
    local mytimeSec = math.mod(seconds, 60)
    --print("myTimeSec==" .. mytimeSec)
    local mytimeFracSec = mytimeSec - math.floor(mytimeSec)
    mytimeFracSec = mytimeFracSec * 100
    local mytimeString = string.format("%2i:%02i.%02i", mytimeMin, mytimeSec, mytimeFracSec)
    --print("StringFormatTime: mytimeString = " .. mytimeString)
    return mytimeString
end

function F_GetGPRaceLevel()
    return shared.gGoKartGPLevel
end

function F_SetupGeo()
    if AreaGetVisible() == 42 then
        local objID, objPool
        objID, objPool = CreatePersistentEntity("TGK_BarricadeB", -293.032, 500.71, 1.53315, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_BarricadeC", -196.4, 490.514, 1.53315, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_BarricadeD", -284.025, 521.332, 1.53315, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_BarricadeE", -281.942, 557.986, 1.44717, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_BarricadeI", -357.647, 558.93, 1.53315, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_BarricadeJ", -364.255, 565.378, 1.53315, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_BarricadeA", -421.161, 501.303, 1.38397, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_BarricadeF", -302.775, 556.328, 1.54701, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_BarricadeG", -311.967, 566.321, 1.50497, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_BarricadeH", -323.693, 559.983, 1.50571, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_BarricadeK", -203.552, 493.473, 1.54701, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_StartGo", -350.963, 493.747, 4.48503, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_StartR3", -350.878, 493.308, 4.48503, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_StartR2", -350.791, 492.855, 4.48503, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        objID, objPool = CreatePersistentEntity("TGK_StartR1", -350.705, 492.403, 4.48503, 0, 42)
        table.insert(GeoTable, { id = objID, bPool = objPool })
        GeometryInstance("TGK_StartGo", true, -350.963, 493.747, 4.48503, false)
        GeometryInstance("TGK_StartR3", true, -350.878, 493.308, 4.48503, false)
        GeometryInstance("TGK_StartR2", true, -350.791, 492.855, 4.48503, false)
        GeometryInstance("TGK_StartR1", false, -350.705, 492.403, 4.48503, false)
    end
end

function F_DestroyGeo()
    for i, Entry in GeoTable do
        if Entry.id ~= nil and Entry.id ~= -1 then
            DeletePersistentEntity(Entry.id, Entry.bPool)
        end
    end
    GeoTable = {}
end

function F_DisableHUDComponents()
    ToggleHUDComponentVisibility(11, false)
    ToggleHUDComponentVisibility(0, false)
    ToggleHUDComponentVisibility(4, false)
end

function F_EnableHUDComponents()
    ToggleHUDComponentVisibility(11, true)
    ToggleHUDComponentVisibility(0, true)
    ToggleHUDComponentVisibility(4, true)
end

function main()
    while PedInConversation(gPlayer) do
        Wait(0)
    end
end
