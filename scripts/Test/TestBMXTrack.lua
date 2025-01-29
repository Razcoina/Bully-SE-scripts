ImportScript("Library/BikeRace_util.lua")
local race, player, racers, shortcuts, highlighted_nodes

function F_TableInit()
    race = {
        path = PATH._TESTBMXTRACE,
        laps = 5,
        reward = 1000,
        missionCode = "blah"
    }
    player = {
        id = nil,
        bike = nil,
        start_pos = POINTLIST._TESTBMXT_PEDSPAWN,
        bike_model = 273,
        bike_start_pos = POINTLIST._TESTBMXT_BIKESPAWN4
    }
    racers = {
        {
            id = nil,
            bike = nil,
            blip = nil,
            start_pos = POINTLIST._TESTBMXT_PEDSPAWN,
            bike_start_pos = POINTLIST._TESTBMXT_BIKESPAWN1,
            model = 23,
            bike_model = 273,
            max_sprint_speed = 0.82,
            max_normal_speed = 0.79,
            catch_up_dist = 20,
            catch_up_speed = 1.6,
            slow_down_dist = 25,
            slow_down_speed = 0.35,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            target = nil,
            sprint_freq = 0,
            sprint_duration = 0,
            sprint_likelyhood = 0,
            aggressiveness = 0.65
        },
        {
            id = nil,
            bike = nil,
            blip = nil,
            start_pos = POINTLIST._TESTBMXT_PEDSPAWN,
            bike_start_pos = POINTLIST._TESTBMXT_BIKESPAWN2,
            model = 23,
            bike_model = 273,
            max_sprint_speed = 0.82,
            max_normal_speed = 0.79,
            catch_up_dist = 20,
            catch_up_speed = 1.6,
            slow_down_dist = 25,
            slow_down_speed = 0.35,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            target = nil,
            sprint_freq = 0,
            sprint_duration = 0,
            sprint_likelyhood = 0,
            aggressiveness = 0.65
        },
        {
            id = nil,
            bike = nil,
            blip = nil,
            start_pos = POINTLIST._TESTBMXT_PEDSPAWN,
            bike_start_pos = POINTLIST._TESTBMXT_BIKESPAWN3,
            model = 23,
            bike_model = 273,
            max_sprint_speed = 0.82,
            max_normal_speed = 0.79,
            catch_up_dist = 20,
            catch_up_speed = 1.6,
            slow_down_dist = 25,
            slow_down_speed = 0.35,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            target = nil,
            sprint_freq = 0,
            sprint_duration = 0,
            sprint_likelyhood = 0,
            aggressiveness = 0.65
        },
        {
            id = nil,
            bike = nil,
            blip = nil,
            start_pos = POINTLIST._TESTBMXT_PEDSPAWN,
            bike_start_pos = POINTLIST._TESTBMXT_BIKESPAWN5,
            model = 23,
            bike_model = 273,
            max_sprint_speed = 1.28,
            max_normal_speed = 0.48,
            catch_up_dist = 5,
            catch_up_speed = 1.6,
            slow_down_dist = 5,
            slow_down_speed = 0.3,
            shortcut_odds = 0,
            shooting_odds = 0,
            trick_odds = 0
        }
    }
    shortcuts = {}
    highlighted_nodes = {
        0,
        3,
        7,
        10,
        12,
        14,
        18,
        21,
        24,
        27,
        29,
        31,
        33
    }
end

function MissionSetup()
    DATLoad("TestBMXTrack.DAT", 2)
    DATInit()
    F_TableInit()
    AreaSetVisible(62)
    SetParam_Race(race)
    SetParam_Player(player)
    SetParam_Racers(racers)
    SetParam_HighlightedNodes(highlighted_nodes)
    SetParam_Shortcuts(shortcuts)
    RaceSetup()
end

function MissionCleanup()
    RaceCleanup()
    VehicleRevertToDefaultAmbient()
    AreaRevertToDefaultPopulation()
    DATUnload(2)
end

function main()
    RaceControl()
end
