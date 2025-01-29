ImportScript("\\Test\\SwimRace_util.lua")
local gMissionCompleted, gSwimmerPed, SwimPath, SwimmerModel, SwimmerSpawn

function MissionSetup()
    DATLoad("SWIMRACE.DAT", 2)
    DATInit()
    PlayerSetHealth(200)
    AreaTransitionPoint(0, POINTLIST._SWIMRACE_PLAYERSTART)
    CameraFade(100, 0)
    F_InitRaceData()
    MAIN_RaceSetup()
end

function F_InitRaceData()
    local race = {
        laps = 1,
        path = PATH._SWIMRACE_TEST_PATH,
        missionCode = "Swim Test",
        countdown_start = 5,
        head_start = 0,
        jump_nodes = {},
        reward = 0,
        FOV = 80,
        mission_specific_flag = false
    }
    local player = {
        id = nil,
        bike = nil,
        start_pos = POINTLIST._SWIMRACE_PLAYERSTART,
        bike_model = 273,
        bike_start_pos = POINTLIST._SWIMRACE_PLAYERSTART
    }
    local racers = {
        {
            id = nil,
            bike = nil,
            blip = nil,
            start_pos = POINTLIST._SWIMRACE_RACERSTART_A,
            bike_start_pos = POINTLIST._SWIMRACE_RACERSTART_A,
            model = 96,
            bike_model = 273,
            add_blip = true,
            max_normal_speed = 1.3,
            catch_up_dist = 5,
            catch_up_speed = 2,
            slow_down_dist = 15,
            slow_down_speed = 0.9,
            max_sprint_speed = 2.3,
            sprint_freq = 0,
            sprint_duration = 0,
            sprint_likelyhood = 0
        }
    }
    local highlighted_nodes = {
        1,
        5,
        9
    }
    EXT_SetParam_Player(player)
    EXT_SetParam_Race(race)
    EXT_SetParam_Racers(racers)
    EXT_SetParam_HighlightedNodes(highlighted_nodes)
end

function main()
    MAIN_RaceControl()
    Wait(3000)
    MAIN_RaceCleanup()
    repeat
        Wait(0)
    until gMissionCompleted
    Wait(2000)
    MissionSucceed()
end

function MissionCleanup()
    DATUnload(2)
end
