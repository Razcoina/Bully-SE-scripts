function NIS_CarnivalEnterTrack()
    --print(">>>[RUI]", "++NIS_CarnivalEnterTrack")
    SoundFadeWithCamera(false)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    CameraFade(125, 0)
    Wait(125)
    CameraSetXYZ(209.83421, 459.3279, 6.052409, 210.54645, 459.99463, 6.271826)
    CameraFade(125, 1)
    Wait(125)
    PedFollowPath(gPlayer, PATH._GK_ENTERRACE, 0, 0, cbEnterTrack)
    while not bEnterTrack do
        Wait(0)
    end
    SoundFadeWithCamera(true)
    CameraFade(500, 0)
    Wait(500)
    --print(">>>[RUI]", "--NIS_CarnivalEnterTrack")
end

function cbEnterTrack(pedId, pathId, pathNode)
    if pathNode == PathGetLastNode(pathId) then
        bEnterTrack = true
    end
end

local CARNIVAL_RACE_COST = 100
local gRaceCost
local gTicketMultiplier = 1
local RACE_TICKETS_MAXIMUM = 2
local RACE_TICKETS_MINIMUM = 1
local GK_RACE_UNDEFINED = -1
local GK_RACE_CARNIVAL1 = 0
local GK_RACE_CARNIVAL2 = 1
local GK_RACE_CARNIVAL3 = 2
local GK_RACE_CARNIVAL4 = 3
local GK_RACE_CARNIVAL5 = 4
local GK_RACE_OUTDOOR1 = 5
local GK_RACE_OUTDOOR2 = 6
local GK_RACE_OUTDOOR3 = 7
local gCurrentRace = GK_RACE_UNDEFINED
local TRACK_UNDEFINED = -1
local TRACK_CARNIVAL_RACE = 1
local TRACK_STREET_RACE = 2
local RACE_RALLY = 0
local RACE_TIME_TRIALS = 1
local GoKartTrackType = TRACK_UNDEFINED
local GoKartRaceType = RACE_RALLY
local bPowerSlideTutorialHandled, gTicketsWon, gRaceMoneyAward
local TRACK_EXIT_FAILURE_DELAY = 4000
local gRace, player, gRacers, gShortcuts, gWayPointNodes, gVisibleArea, gExitArea, gExitPoint, gSpecialEntities, gcbEvent, bFirstHandled, bSecondHandled

function F_StorePlayersBikeIfInTrigger(trigger, point)
    if not trigger then
        print(">>>[RUI]", "!!F_StorePlayersBikeIfInTrigger NO TRIGGER " .. tostring(trigger))
        return
    end
    local x, y, z = GetAnchorPosition(trigger)
    bikes = VehicleFindInAreaXYZ(x, y, z, 100, false)
    pBike = PlayerGetLastBikeId()
    --print(">>>[RUI]", "!!F_StorePlayersBikeIfInTrigger playerBike==" .. tostring(pBike))
    if not bikes then
        return
    end
    for _, bike in bikes do
        if bike == pBike then
            --print(">>>[RUI]", "!!F_StorePlayersBikeIfInTrigger keep bike " .. tostring(bike))
            VehicleSetPosPoint(bike, point)
        else
            --print(">>>[RUI]", "--F_StorePlayersBikeIfInTrigger toss bike " .. tostring(bike))
            VehicleDelete(bike)
        end
    end
end

local CarnivalBarriers = {
    a = {
        name = "TGK_BarricadeA",
        x = -421.161,
        y = 501.303,
        z = 1.38397,
        h = 0,
        bActive = false
    },
    b = {
        name = "TGK_BarricadeB",
        x = -293.032,
        y = 500.71,
        z = 1.53315,
        h = 0,
        bActive = false
    },
    c = {
        name = "TGK_BarricadeC",
        x = -196.4,
        y = 490.514,
        z = 1.53315,
        h = 0,
        bActive = false
    },
    d = {
        name = "TGK_BarricadeD",
        x = -284.025,
        y = 521.332,
        z = 1.53315,
        h = 0,
        bActive = false
    },
    e = {
        name = "TGK_BarricadeE",
        x = -281.942,
        y = 557.986,
        z = 1.44717,
        h = 0,
        bActive = false
    },
    f = {
        name = "TGK_BarricadeF",
        x = -302.996,
        y = 555.917,
        z = 1.50571,
        h = 0,
        bActive = false
    },
    g = {
        name = "TGK_BarricadeG",
        x = -319.313,
        y = 567.803,
        z = 1.50497,
        h = 0,
        bActive = false
    },
    h = {
        name = "TGK_BarricadeH",
        x = -323.693,
        y = 559.983,
        z = 1.50571,
        h = 0,
        bActive = false
    },
    i = {
        name = "TGK_BarricadeI",
        x = -357.647,
        y = 558.93,
        z = 1.53315,
        h = 0,
        bActive = false
    },
    j = {
        name = "TGK_BarricadeJ",
        x = -364.255,
        y = 565.378,
        z = 1.53315,
        h = 0,
        bActive = false
    },
    k = {
        name = "TGK_BarricadeK",
        x = -203.552,
        y = 493.473,
        z = 1.54701,
        h = 0,
        bActive = false
    },
    l = {
        name = "TGK_BarricadeL",
        x = -282.455,
        y = 553.345,
        z = 1.54701,
        h = 0,
        bActive = false
    },
    m = {
        name = "TGK_BarricadeM",
        x = -429.081,
        y = 507.052,
        z = 1.38397,
        h = 0,
        bActive = false
    },
    n = {
        name = "TGK_BarricadeN",
        x = -302.43,
        y = 563.301,
        z = 1.54701,
        h = 0,
        bActive = false
    }
}
local RaceSignals = {
    r3 = {
        name = "TGK_StartR3",
        x = -350.878,
        y = 493.308,
        z = 4.48503,
        h = 0
    },
    r2 = {
        name = "TGK_StartR2",
        x = -350.791,
        y = 492.855,
        z = 4.48503,
        h = 0
    },
    r1 = {
        name = "TGK_StartR1",
        x = -350.705,
        y = 492.403,
        z = 4.48503,
        h = 0
    },
    go = {
        name = "TGK_StartGo",
        x = -350.963,
        y = 493.747,
        z = 4.48503,
        h = 0
    }
}

function F_RaceSetTier(race)
    if race == 0 or race == 1 then
        gCurrentRace = GK_RACE_CARNIVAL1
        gRaceCost = CARNIVAL_RACE_COST
        GoKartTrackType = TRACK_CARNIVAL_RACE
    elseif race == 2 then
        gCurrentRace = GK_RACE_CARNIVAL2
        gRaceCost = CARNIVAL_RACE_COST
        GoKartTrackType = TRACK_CARNIVAL_RACE
    elseif race == 3 then
        gCurrentRace = GK_RACE_CARNIVAL3
        gRaceCost = CARNIVAL_RACE_COST
        GoKartTrackType = TRACK_CARNIVAL_RACE
    elseif race == 4 then
        gCurrentRace = GK_RACE_CARNIVAL4
        gRaceCost = CARNIVAL_RACE_COST
        GoKartTrackType = TRACK_CARNIVAL_RACE
    elseif race == 5 then
        gCurrentRace = GK_RACE_CARNIVAL5
        gRaceCost = CARNIVAL_RACE_COST
        GoKartTrackType = TRACK_CARNIVAL_RACE
    elseif race == 6 then
        gCurrentRace = GK_RACE_OUTDOOR1
        GoKartTrackType = TRACK_STREET_RACE
    elseif race == 7 then
        gCurrentRace = GK_RACE_OUTDOOR2
        GoKartTrackType = TRACK_STREET_RACE
    elseif race == 8 then
        gCurrentRace = GK_RACE_OUTDOOR3
        GoKartTrackType = TRACK_STREET_RACE
    else
        gCurrentRace = GK_RACE_CARNIVAL1
        gRaceCost = CARNIVAL_RACE_COST
        GoKartTrackType = TRACK_CARNIVAL_RACE
    end
    if gRaceCost then
        --print(">>>[RUI]", "COST")
        PlayerAddMoney(-gRaceCost, true)
    end
    gRaceStyle = RACE_RALLY
    --print(">>>[RUI]", "F_RaceSetTier race: " .. tostring(race) .. " gCurrentRace: " .. tostring(gCurrentRace))
end

function RaceInitCarnival1()
    --print(">>>[RUI]", "++RaceInitCarnival1")
    DATLoad("GoKart.DAT", 2)
    DATInit()
    LoadModels({
        8,
        4,
        3
    })
    gKartThemeMusic = "MS_GoKarts01a.rsm"
    gRace = {
        laps = 3,
        path = PATH._GOKART_RACE01,
        missionCode = "GO KART LEVEL 1"
    }
    player = {
        id = nil,
        car = nil,
        start_pos = POINTLIST._GOKART_PED4,
        car_start_pos = POINTLIST._GOKART_POS4,
        endPath = PATH._GOKART_FINISH,
        car_model = 289
    }
    gRacers = {
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race1Racer01",
            start_pos = POINTLIST._GOKART_PED1,
            car_start_pos = POINTLIST._GOKART_POS1,
            endPath = PATH._GOKART_FINISH01,
            model = 8,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13,
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
            name = "race1Racer02",
            start_pos = POINTLIST._GOKART_PED2,
            car_start_pos = POINTLIST._GOKART_POS2,
            endPath = PATH._GOKART_FINISH02,
            model = 4,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13,
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
            name = "race1Racer03",
            start_pos = POINTLIST._GOKART_PED3,
            car_start_pos = POINTLIST._GOKART_POS3,
            endPath = PATH._GOKART_FINISH03,
            model = 3,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13,
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
    gShortcuts = {}
    gWayPointNodes = {
        0,
        2,
        4,
        6,
        7,
        9,
        10,
        12,
        -2
    }
    CarnivalBarriers.a.bActive = true
    CarnivalBarriers.b.bActive = true
    CarnivalBarriers.c.bActive = true
    CarnivalBarriers.d.bActive = true
    CarnivalBarriers.e.bActive = true
    CarnivalBarriers.f.bActive = true
    CarnivalBarriers.h.bActive = true
    CarnivalBarriers.i.bActive = true
    gVisibleArea = 42
    gExitArea, gExitPoint = 0, POINTLIST._GOKARTTRACKEXIT
    F_SetCamera = Race_SetCarnivalRaceCam
end

function RaceInitCarnival2()
    --print(">>>[RUI]", "++RaceInitCarnival2")
    DATLoad("GoKart.DAT", 2)
    DATInit()
    LoadModels({
        85,
        99,
        102
    })
    gKartThemeMusic = "MS_GoKarts01a.rsm"
    gRace = {
        laps = 3,
        path = PATH._GOKART_RACE02,
        missionCode = "GO KART LEVEL 2"
    }
    player = {
        id = nil,
        car = nil,
        start_pos = POINTLIST._GOKART_PED4,
        car_start_pos = POINTLIST._GOKART_POS4,
        endPath = PATH._GOKART_FINISH,
        car_model = 289
    }
    gRacers = {
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race2Racer01",
            start_pos = POINTLIST._GOKART_PED1,
            car_start_pos = POINTLIST._GOKART_POS1,
            endPath = PATH._GOKART_FINISH01,
            model = 85,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.4,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 10,
            slow_down_speed = 0.6,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race2Racer02",
            start_pos = POINTLIST._GOKART_PED2,
            car_start_pos = POINTLIST._GOKART_POS2,
            endPath = PATH._GOKART_FINISH02,
            model = 99,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.4,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 10,
            slow_down_speed = 0.6,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race2Racer03",
            start_pos = POINTLIST._GOKART_PED3,
            car_start_pos = POINTLIST._GOKART_POS3,
            endPath = PATH._GOKART_FINISH03,
            model = 102,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.4,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 10,
            slow_down_speed = 0.6,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        }
    }
    gShortcuts = {}
    gWayPointNodes = {
        0,
        1,
        4,
        7,
        8,
        11,
        14,
        18,
        19,
        22,
        25,
        27,
        28,
        -2
    }
    CarnivalBarriers.a.bActive = true
    CarnivalBarriers.b.bActive = true
    CarnivalBarriers.c.bActive = true
    CarnivalBarriers.d.bActive = true
    CarnivalBarriers.e.bActive = true
    CarnivalBarriers.g.bActive = true
    CarnivalBarriers.i.bActive = true
    CarnivalBarriers.n.bActive = true
    gVisibleArea = 42
    gExitArea, gExitPoint = 0, POINTLIST._GOKARTTRACKEXIT
    F_SetCamera = Race_SetCarnivalRaceCam
end

function F_PowerSlideTutorial()
    --print(">>>[RUI]", "!!F_PowerSlideTutorial")
    TutorialShowMessage("TUT_PSLIDE", 4000)
end

function F_DoPowerSlideTutorial()
    return PlayerIsInTrigger(TRIGGER._RACE3BRAKETUTORIAL) and not bPowerSlideTutorialHandled
end

function RaceInitCarnival3()
    --print(">>>[RUI]", "++RaceInitCarnival3")
    DATLoad("GoKart.DAT", 2)
    DATInit()
    LoadModels({
        40,
        32,
        35
    })
    gKartThemeMusic = "MS_GoKarts01a.rsm"
    event = { activate = F_DoPowerSlideTutorial, cbFunc = F_PowerSlideTutorial }
    gRace = {
        laps = 3,
        path = PATH._GOKART_RACE03,
        missionCode = "GO KART LEVEL 2",
        cbEvent = event
    }
    player = {
        id = nil,
        car = nil,
        start_pos = POINTLIST._GOKART_PED6,
        car_start_pos = POINTLIST._GOKART_POS6,
        endPath = PATH._GOKART_FINISH,
        car_model = 289
    }
    gRacers = {
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race3Racer01",
            start_pos = POINTLIST._GOKART_PED1,
            car_start_pos = POINTLIST._GOKART_POS1,
            endPath = PATH._GOKART_FINISH01,
            model = 40,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 10,
            slow_down_speed = 0.6,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race3Racer02",
            start_pos = POINTLIST._GOKART_PED2,
            car_start_pos = POINTLIST._GOKART_POS2,
            endPath = PATH._GOKART_FINISH02,
            model = 32,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 10,
            slow_down_speed = 0.6,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race3Racer03",
            start_pos = POINTLIST._GOKART_PED3,
            car_start_pos = POINTLIST._GOKART_POS3,
            endPath = PATH._GOKART_FINISH03,
            model = 35,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 10,
            slow_down_speed = 0.6,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        }
    }
    gShortcuts = {}
    gWayPointNodes = {
        0,
        2,
        4,
        5,
        7,
        9,
        11,
        15,
        17,
        18,
        19,
        22,
        23,
        24,
        -2
    }
    CarnivalBarriers.b.bActive = true
    CarnivalBarriers.f.bActive = true
    CarnivalBarriers.h.bActive = true
    CarnivalBarriers.j.bActive = true
    CarnivalBarriers.k.bActive = true
    CarnivalBarriers.l.bActive = true
    CarnivalBarriers.m.bActive = true
    gVisibleArea = 42
    gExitArea, gExitPoint = 0, POINTLIST._GOKARTTRACKEXIT
    F_SetCamera = Race_SetCarnivalRaceCam
end

function RaceInitCarnival4()
    --print(">>>[RUI]", "++RaceInitCarnival4")
    DATLoad("GoKart.DAT", 2)
    DATInit()
    LoadModels({
        16,
        13,
        15,
        14
    })
    gRace = {
        laps = 4,
        path = PATH._GOKART_RACE04,
        missionCode = "GO KART LEVEL 2"
    }
    gKartThemeMusic = "MS_GoKarts01B.rsm"
    player = {
        id = nil,
        car = nil,
        start_pos = POINTLIST._GOKART_PED6,
        car_start_pos = POINTLIST._GOKART_POS6,
        endPath = PATH._GOKART_FINISH,
        car_model = 289
    }
    gRacers = {
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race4Racer01",
            start_pos = POINTLIST._GOKART_PED1,
            car_start_pos = POINTLIST._GOKART_POS1,
            endPath = PATH._GOKART_FINISH01,
            model = 16,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race4Racer02",
            start_pos = POINTLIST._GOKART_PED2,
            car_start_pos = POINTLIST._GOKART_POS2,
            endPath = PATH._GOKART_FINISH02,
            model = 13,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race4Racer03",
            start_pos = POINTLIST._GOKART_PED3,
            car_start_pos = POINTLIST._GOKART_POS3,
            endPath = PATH._GOKART_FINISH03,
            model = 15,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race4Racer04",
            start_pos = POINTLIST._GOKART_PED4,
            car_start_pos = POINTLIST._GOKART_POS4,
            endPath = PATH._GOKART_FINISH04,
            model = 14,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        }
    }
    gShortcuts = {}
    gWayPointNodes = {
        0,
        4,
        6,
        10,
        12,
        15,
        19,
        22,
        25,
        27,
        31,
        35,
        36,
        -2
    }
    CarnivalBarriers.b.bActive = true
    CarnivalBarriers.g.bActive = true
    CarnivalBarriers.j.bActive = true
    CarnivalBarriers.k.bActive = true
    CarnivalBarriers.l.bActive = true
    CarnivalBarriers.m.bActive = true
    CarnivalBarriers.n.bActive = true
    gVisibleArea = 42
    gExitArea, gExitPoint = 0, POINTLIST._GOKARTTRACKEXIT
    F_SetCamera = Race_SetCarnivalRaceCam
end

function RaceInitCarnival5()
    --print(">>>[RUI]", "++RaceInitCarnival5")
    DATLoad("GoKart.DAT", 2)
    DATInit()
    LoadModels({
        27,
        24,
        29,
        22,
        25
    })
    gKartThemeMusic = "MS_GoKarts01B.rsm"
    gRace = {
        laps = 4,
        path = PATH._GOKART_RACE05,
        missionCode = "GO KART LEVEL 5"
    }
    player = {
        id = nil,
        car = nil,
        start_pos = POINTLIST._GOKART_PED6,
        car_start_pos = POINTLIST._GOKART_POS6,
        endPath = PATH._GOKART_FINISH,
        car_model = 289
    }
    gRacers = {
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race5Racer01",
            start_pos = POINTLIST._GOKART_PED1,
            car_start_pos = POINTLIST._GOKART_POS1,
            endPath = PATH._GOKART_FINISH01,
            model = 27,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race5Racer02",
            start_pos = POINTLIST._GOKART_PED2,
            car_start_pos = POINTLIST._GOKART_POS2,
            endPath = PATH._GOKART_FINISH02,
            model = 24,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race5Racer03",
            start_pos = POINTLIST._GOKART_PED3,
            car_start_pos = POINTLIST._GOKART_POS3,
            endPath = PATH._GOKART_FINISH03,
            model = 29,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race5Racer04",
            start_pos = POINTLIST._GOKART_PED4,
            car_start_pos = POINTLIST._GOKART_POS4,
            endPath = PATH._GOKART_FINISH04,
            model = 22,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "race5Racer05",
            start_pos = POINTLIST._GOKART_PED5,
            car_start_pos = POINTLIST._GOKART_POS5,
            endPath = PATH._GOKART_FINISH05,
            model = 25,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.5,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        }
    }
    gShortcuts = {}
    gWayPointNodes = {
        0,
        1,
        4,
        5,
        8,
        10,
        11,
        13,
        14,
        15,
        18,
        21,
        23,
        25,
        27,
        28,
        -2
    }
    CarnivalBarriers.b.bActive = true
    CarnivalBarriers.c.bActive = true
    CarnivalBarriers.d.bActive = true
    CarnivalBarriers.e.bActive = true
    CarnivalBarriers.g.bActive = true
    CarnivalBarriers.j.bActive = true
    CarnivalBarriers.m.bActive = true
    CarnivalBarriers.n.bActive = true
    gVisibleArea = 42
    gExitArea, gExitPoint = 0, POINTLIST._GOKARTTRACKEXIT
    F_SetCamera = Race_SetCarnivalRaceCam
end

function RaceInitOutdoor1_Rich()
    --print(">>>[RUI]", "++RaceInitOutdoor1_Rich (RICH)")
    DATLoad("GoKart_Outdoor.DAT", 2)
    DATInit()
    LoadModels({
        48,
        47,
        42
    })
    gRaceMoneyAward = 2000
    gKartThemeMusic = "MS_GoKarts02.rsm"
    gRace = {
        laps = 3,
        path = PATH._RICHRACEPATH,
        missionCode = "GO KART RICH"
    }
    player = {
        id = nil,
        car = nil,
        start_pos = POINTLIST._RICHPLAYERSTART,
        car_start_pos = POINTLIST._RICHPLAYERCAR,
        endPath = PATH._RICH_FINISH,
        car_model = 289
    }
    gRacers = {
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "RichRacer01",
            start_pos = POINTLIST._RICHRACER01,
            car_start_pos = POINTLIST._RICHRACERCAR01,
            endPath = PATH._RICH_FINISH01,
            model = 48,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.7,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 50,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "RichRacer02",
            start_pos = POINTLIST._RICHRACER02,
            car_start_pos = POINTLIST._RICHRACERCAR02,
            endPath = PATH._RICH_FINISH02,
            model = 47,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.7,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 60,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "RichRacer03",
            start_pos = POINTLIST._RICHRACER03,
            car_start_pos = POINTLIST._RICHRACERCAR03,
            endPath = PATH._RICH_FINISH03,
            model = 42,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.7,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 50,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        }
    }
    gShortcuts = {
        {
            path = PATH._RICHRACESHORTCUT01,
            start_node = 25,
            end_node = 33
        },
        {
            path = PATH._RICHRACESHORTCUT02,
            start_node = 34,
            end_node = 46
        }
    }
    gWayPointNodes = {
        0,
        3,
        4,
        7,
        10,
        13,
        15,
        17,
        18,
        20,
        23,
        25,
        33,
        34,
        46,
        47,
        -2
    }
    gTrackObjects = nil
    gSpecialEntities = "GK_SR1"
    gVisibleArea = 0
    gExitArea, gExitPoint = 0, POINTLIST._GOKART_RICH
    gDepopTrigger = TRIGGER._DEPOPRICHAREARACE
    gGameArea = gDepopTrigger
    gNoGoArea = TRIGGER._RICHNOGOAREA
    gBikeStoragePoint = POINTLIST._RICHBIKEPOINT

    function F_SetCamera()
        CameraSetXYZ(532.92816, 300.7724, 16.99246, 533.3162, 301.69092, 17.067421)
        CameraLookAtPlayer(true)
        --print(">>>[RUI]", "Rich CAM")
    end

    shared.gDisableBusStops = true
end

function RaceInitOutdoor2_Beach()
    --print(">>>[RUI]", "++RaceInitOutdoor2_Beach (BEACH)")
    DATLoad("GoKart_Outdoor.DAT", 2)
    DATInit()
    LoadModels({ 48, 47 })
    gRaceMoneyAward = 2500
    gKartThemeMusic = "MS_GoKarts02.rsm"
    gRace = {
        laps = 3,
        path = PATH._BEACHRACEPATH,
        missionCode = "GO KART BEACH"
    }
    player = {
        id = nil,
        car = nil,
        start_pos = POINTLIST._BEACHPLAYERSTART,
        car_start_pos = POINTLIST._BEACHPLAYERKART,
        endPath = PATH._BEACH_FINISH,
        car_model = 289
    }
    gRacers = {
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "BeachRacer01",
            start_pos = POINTLIST._BEACHRACER01,
            car_start_pos = POINTLIST._BEACHRACERKART01,
            endPath = PATH._BEACH_FINISH01,
            model = 48,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.7,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "BeachRacer02",
            start_pos = POINTLIST._BEACHRACER02,
            car_start_pos = POINTLIST._BEACHRACERKART02,
            endPath = PATH._BEACH_FINISH02,
            model = 47,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.7,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 30,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        }
    }
    gShortcuts = {}
    gWayPointNodes = {
        0,
        3,
        5,
        8,
        10,
        11,
        13,
        17,
        21,
        26,
        30,
        33,
        37,
        40,
        -2
    }
    gTrackObjects = nil
    gSpecialEntities = "GK_SR2"
    gVisibleArea = 0
    gExitArea, gExitPoint = 0, POINTLIST._GOKART_BEACH
    gDepopTrigger = TRIGGER._DEPOPBEACHAREARACE
    gGameArea = gDepopTrigger
    gNoGoArea = TRIGGER._BEACHNOGOAREA
    gBikeStoragePoint = POINTLIST._BEACHBIKEPOINT

    function F_SetCamera()
        CameraSetXYZ(314.30627, 242.54433, 4.923222, 313.72803, 241.77351, 5.190253)
        CameraLookAtPlayer(true)
        --print(">>>[RUI]", "BeachRace CAM")
    end

    shared.gDisableBusStops = true
end

function RaceInitOutdoor3_Industrial()
    --print(">>>[RUI]", "++RaceInitOutdoor3_Industrial (INDUSTRIAL)")
    DATLoad("GoKart_Outdoor.DAT", 2)
    DATInit()
    LoadModels({ 42, 44 })
    gRaceMoneyAward = 3000
    gKartThemeMusic = "MS_GoKarts02.rsm"
    gRace = {
        laps = 3,
        path = PATH._INDUSTRIALRACEPATH,
        missionCode = "GO KART INDUSTRIAL"
    }
    player = {
        id = nil,
        car = nil,
        start_pos = POINTLIST._INDUSTRIALPLAYERSTART,
        car_start_pos = POINTLIST._INDUSTRIALPLAYERCART,
        endPath = PATH._INDUSTRIAL_FINISH,
        car_model = 289
    }
    gRacers = {
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "IndustrialRacer01",
            start_pos = POINTLIST._INDUSTRIALRACER01,
            car_start_pos = POINTLIST._INDUSTRIALRACERCART01,
            endPath = PATH._INDUSTRIAL_FINISH01,
            model = 42,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.7,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 60,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        },
        {
            id = nil,
            car = nil,
            blip = nil,
            name = "IndustrialRacer02",
            start_pos = POINTLIST._INDUSTRIALRACER02,
            car_start_pos = POINTLIST._INDUSTRIALRACERCART02,
            endPath = PATH._INDUSTRIAL_FINISH02,
            model = 44,
            car_model = 289,
            max_sprint_speed = 16,
            max_normal_speed = 13.7,
            catch_up_dist = 1,
            catch_up_speed = 1.2,
            slow_down_dist = 15,
            slow_down_speed = 0.8,
            shortcut_odds = 60,
            shooting_odds = 0,
            trick_odds = 0,
            aggressiveness = 0.5
        }
    }
    gShortcuts = {
        {
            path = PATH._INDUSTRIALSHORTCUTPATH01,
            start_node = 5,
            end_node = 12
        },
        {
            path = PATH._INDUSTRIALSHORTCUTPATH02,
            start_node = 3,
            end_node = 13
        }
    }
    gWayPointNodes = {
        0,
        1,
        3,
        13,
        14,
        17,
        20,
        22,
        27,
        30,
        32,
        33,
        35,
        -2
    }
    gTrackObjects = nil
    gSpecialEntities = "GK_SR3"
    gVisibleArea = 0
    gExitArea, gExitPoint = 0, POINTLIST._GOKART_INDUSTRIAL
    gDepopTrigger = TRIGGER._DEPOPINDUSTRIALAREARACE
    gGameArea = gDepopTrigger
    gNoGoArea = TRIGGER._INDUSTRIALNOGOAREA
    gBikeStoragePoint = POINTLIST._IDUSTRIALBIKEPOINT

    function F_SetCamera()
        CameraSetXYZ(153.20938, -449.5874, 3.360861, 152.92625, -450.5431, 3.439104)
        CameraLookAtPlayer(true)
        --print(">>>[RUI]", "Industrial CAM")
    end

    shared.gDisableBusStops = true
end

function Race_SetCarnivalRaceCam()
    --print(">>>[RUI]", "!!Race_SetCarnivalRaceCam")
    CameraSetSpeed(20, 20, 40)
    CameraSetPath(PATH._GOKARTCAMPATH, true)
    CameraLookAtPlayer(true)
end

function RaceInit(race)
    --print(">>>[RUI]", "RaceInit race: " .. tostring(race))
    F_MakePlayerSafeForNIS(false)
    if GoKartTrackType == TRACK_CARNIVAL_RACE then
        --print(">>>[RUI]", "!!RaceInit Carnival TRACK_CARNIVAL_RACE")
        NIS_CarnivalEnterTrack()
    else
        --print(">>>[RUI]", "!!RaceInit Carnival TRACK_STREET_RACE")
        CameraFade(FADE_OUT_TIME, 0)
        Wait(FADE_OUT_TIME)
    end
    ClothingBackup()
    ClothingSetPlayer(0, "SP_GK_Helmet")
    ClothingBuildPlayer()
    LoadAnimationGroup("Go_Cart")
    LoadAnimationGroup("NPC_Adult")
    LoadModels({ 289 })
    LoadActionTree("Act/Conv/GoKart.act")
    F_RainBeGone()
    PlayerSetControl(0)
    if race == GK_RACE_CARNIVAL1 then
        RaceInitCarnival1()
    elseif race == GK_RACE_CARNIVAL2 then
        RaceInitCarnival2()
    elseif race == GK_RACE_CARNIVAL3 then
        RaceInitCarnival3()
    elseif race == GK_RACE_CARNIVAL4 then
        RaceInitCarnival4()
    elseif race == GK_RACE_CARNIVAL5 then
        RaceInitCarnival5()
    elseif race == GK_RACE_OUTDOOR1 then
        RaceInitOutdoor1_Rich()
    elseif race == GK_RACE_OUTDOOR2 then
        RaceInitOutdoor2_Beach()
    elseif race == GK_RACE_OUTDOOR3 then
        RaceInitOutdoor3_Industrial()
    end
    SoundPlayStream(gKartThemeMusic, 0.75)
    GoKartRaceType = gRaceStyle
    F_StorePlayersBikeIfInTrigger(gGameArea, gBikeStoragePoint)
    SetParam_Race(gRace)
    SetParam_Player(player)
    SetParam_Racers(gRacers)
    SetParam_Shortcuts(gShortcuts)
    Race_SetupTrack(gVisibleArea)
    Wait(500)
    CameraFade(1000, 1)
    Wait(1001)
    CameraAllowChange(false)
end

local race = {}
local race_default = {
    path = nil,
    jump_nodes = {},
    reward = 1000,
    laps = 3,
    head_start = 100,
    countdown_start = 3,
    finish_delay = 30000,
    FOV = 70,
    missionCode = "",
    soundTrack = "",
    volume = 0.4,
    cbEvent = nil
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
        name = "blank",
        start_pos = nil,
        car_start_pos = nil,
        endPath = nil,
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
local race_ongoing = true
local default_FOV
local mytimeTotalS = 0
local bPlayerAbandonedCar = false

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
    race.cbEvent = race_param.cbEvent or race_default.cbEvent
    if race.cbEvent and (race.cbEvent.activate == nil or race.cbEvent.cbFunc == nil) then
        race.cbEvent = nil
    end
end

function SetParam_Player(player_param)
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
        new_racer.name = racer.name or racers_default[default_index].name
        new_racer.endPath = racer.endPath or racers_default[default_index].endPath
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

function Race_CreateRacer(racer)
    racer.id = PedCreatePoint(racer.model, racer.start_pos)
    PedSetFlag(racer.id, 107, true)
    racer.blip = AddBlipForChar(racer.id, 2, 2, racer.add_blip and 1 or 0)
    --print(">>>[RUI]", "Race_CreateRacer after blip")
    racer.car = VehicleCreatePoint(racer.car_model, racer.car_start_pos)
    if racer.weapon then
        PedSetWeapon(racer.id, racer.weapon, racer.ammo)
    end
    for i, targetID in racer.target do
        PedLockTarget(racer.id, targetID)
    end
    if VehicleIsValid(racer.car) then
        --print(">>>[RUI]", "racer " .. racer.name .. " car " .. tostring(racer.car))
        VehicleStop(racer.car)
    else
        --print(">>>[RUI]", "Race_CreateRacer racer " .. racer.name .. " has NIL car")
    end
end

function Race_RacersEnterVehicle(racers)
    for i, racer in racers do
        if VehicleIsValid(racer.car) then
            PedWarpIntoCar(racer.id, racer.car)
            VehicleStop(racer.car)
        end
    end
end

function HighlightNodes(nodes)
    for i, node in nodes do
        --print(">>>[RUI]", "Highlighted node " .. node)
        RaceAddNodeToHighlight(node)
    end
end

function CreateRacerGroup(racers)
    for i, racer in racers do
        --print(">>>[RUI]", "About to create racer " .. i)
        Race_CreateRacer(racer)
    end
end

function AddShortcuts(shortcuts)
    for i, shortcut in shortcuts do
        --print(">>>[RUI]", "Adding shortcut: path = " .. shortcut.path .. " start_node = " .. shortcut.start_node .. " end_node = " .. shortcut.end_node)
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
        --print(">>>[RUI]", "Adding jump for path " .. race.path .. " at node " .. node)
        RaceAddJumpNode(race.path, node)
    end
end

function AddShortcutJump(shortcut)
    if shortcut.jump_nodes ~= nil then
        RaceAddJumpPath(shortcut.path, shortcut.start_node, shortcut.end_node)
        for i, node in shortcut.jump_nodes do
            --print(">>>[RUI]", "Adding shortcut jump for path " .. shortcut.path .. " at node " .. node)
            RaceAddJumpNode(shortcut.path, node)
        end
    end
end

function WaitForRacersReady(racers)
    for i, racer in racers do
        if VehicleIsValid(racer.car) and not PedIsOnVehicle(racer.id) then
            Wait(100)
            VehicleStop(racer.car)
        end
    end
end

function WaitForRaceToStart()
    Wait(500)
    if GoKartTrackType == TRACK_CARNIVAL_RACE then
        GeometryInstance(RaceSignals.r3.name, true, RaceSignals.r3.x, RaceSignals.r3.y, RaceSignals.r3.z, false)
        GeometryInstance(RaceSignals.r2.name, true, RaceSignals.r2.x, RaceSignals.r2.y, RaceSignals.r2.z, false)
        GeometryInstance(RaceSignals.r1.name, false, RaceSignals.r1.x, RaceSignals.r1.y, RaceSignals.r1.z, false)
        GeometryInstance(RaceSignals.go.name, true, RaceSignals.go.x, RaceSignals.go.y, RaceSignals.go.z, false)
    end
    SoundPlay2D("CountBeep")
    Wait(1000)
    if GoKartTrackType == TRACK_CARNIVAL_RACE then
        GeometryInstance(RaceSignals.r3.name, true, RaceSignals.r3.x, RaceSignals.r3.y, RaceSignals.r3.z, false)
        GeometryInstance(RaceSignals.r2.name, false, RaceSignals.r2.x, RaceSignals.r2.y, RaceSignals.r2.z, false)
        GeometryInstance(RaceSignals.r1.name, false, RaceSignals.r1.x, RaceSignals.r1.y, RaceSignals.r1.z, false)
        GeometryInstance(RaceSignals.go.name, true, RaceSignals.go.x, RaceSignals.go.y, RaceSignals.go.z, false)
    end
    SoundPlay2D("CountBeep")
    TextPrint("Arc_01", 3, 1)
    Wait(1000)
    if GoKartTrackType == TRACK_CARNIVAL_RACE then
        GeometryInstance(RaceSignals.r3.name, false, RaceSignals.r3.x, RaceSignals.r3.y, RaceSignals.r3.z, false)
        GeometryInstance(RaceSignals.r2.name, false, RaceSignals.r2.x, RaceSignals.r2.y, RaceSignals.r2.z, false)
        GeometryInstance(RaceSignals.r1.name, false, RaceSignals.r1.x, RaceSignals.r1.y, RaceSignals.r1.z, false)
        GeometryInstance(RaceSignals.go.name, true, RaceSignals.go.x, RaceSignals.go.y, RaceSignals.go.z, false)
    end
    SoundPlay2D("CountBeep")
    TextPrint("Arc_02", 3, 1)
    Wait(1000)
    if GoKartTrackType == TRACK_CARNIVAL_RACE then
        GeometryInstance(RaceSignals.r3.name, true, RaceSignals.r3.x, RaceSignals.r3.y, RaceSignals.r3.z, false)
        GeometryInstance(RaceSignals.r2.name, true, RaceSignals.r2.x, RaceSignals.r2.y, RaceSignals.r2.z, false)
        GeometryInstance(RaceSignals.r1.name, true, RaceSignals.r1.x, RaceSignals.r1.y, RaceSignals.r1.z, false)
        GeometryInstance(RaceSignals.go.name, false, RaceSignals.go.x, RaceSignals.go.y, RaceSignals.go.z, false)
    end
    SoundPlay2D("GoBeep")
    TextPrint("Arc_03", 3, 1)
    for _, racer in racers do
        if VehicleIsValid(racer.car) then
            VehicleFollowPath(racer.car, race.path)
        end
    end
end

function SetRacerStats(racers)
    for _, racer in racers do
        RaceSetRacerStats(racer.id, racer.max_sprint_speed, racer.max_normal_speed, racer.catch_up_dist, racer.catch_up_speed, racer.slow_down_dist, racer.slow_down_speed, racer.shortcut_odds, racer.shooting_odds, racer.trick_odds, 0, 0, 0, racer.aggressiveness)
    end
end

function Race_PlayerSetup(player)
    if PedIsOnVehicle(gPlayer) then
        PlayerDetachFromVehicle(gPlayer)
    end
    ManagedPlayerSetPosPoint(player.start_pos)
    player.car = VehicleCreatePoint(player.car_model, player.car_start_pos)
    Wait(0)
    PedWarpIntoCar(gPlayer, player.car)
end

function Race_SetupTrack(area)
    PauseGameClock()
    --print(">>>[RUI]", "Start Race_SetupTrack(), before Race_PlayerSetup()")
    MinigameCreate("RACE", true)
    while not MinigameIsReady() do
        Wait(0)
    end
    AreaTransitionPoint(area, player.start_pos, 1, true)
    while AreaIsLoading() do
        Wait(100)
    end
    --print(">>>[RUI]", "Race_SetupTrack done areaLoad")
    VehicleOverrideAmbient(0, 0, 0, 0)
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaClearAllPeds()
    AreaClearAllVehicles()
    Race_PlayerSetup(player)
    --print(">>>[RUI]", "before create racers")
    CreateRacerGroup(racers)
    --print(">>>[RUI]", "before ordering opponents to mount their cars")
    Race_RacersEnterVehicle(racers)
    RaceSetupRace(race.path, race.laps, table.getn(racers))
    --print(">>>[RUI]", "before highlighting nodes")
    HighlightNodes(gWayPointNodes)
    RaceShowFinishPointOnly(true)
    Race_InitGeo()
    --print(">>>[RUI]", "before adding shortcuts")
    if 0 < table.getn(shortcuts) and shortcuts[1].path ~= nil then
        AddShortcuts(shortcuts)
    end
    if race.jump_nodes ~= nil and 0 < table.getn(race.jump_nodes) then
        AddJumps(race)
    end
    --print(">>>[RUI]", "before registering racers with AI")
    AddRacers(racers)
    SetRacerStats(racers)
    gcbEvent = { cbEventCondition = F_DoPowerSlideTutorial, cbEventFunc = F_PowerSlideTutorial }
    --print("PATH._GOKARTTRACK = " .. tostring(gRace.path))
end

function RaceCleanup()
    --print(">>>[RUI]", "!!RaceCleanup")
    Race_DestroyGeo()
    Race_DestroySignals()
    if gSpecialEntities then
        AreaLoadSpecialEntities(gSpecialEntities, false)
        --print(">>>[RUI]", "--Special Entities")
    end
    if GoKartRaceType == RACE_RALLY then
        PlayerDetachFromVehicle()
        VehicleDelete(player.car)
        for i, racer in racers do
            RaceRemoveRacer(racer.id)
            PedDelete(racer.id)
            if VehicleIsValid(racer.car) then
                VehicleDelete(racer.car)
                --print(">>>[RUI]", "RaceCleanup other cars")
            end
        end
        AreaForceLoadAreaByAreaTransition(true)
        AreaTransitionPoint(gExitArea, gExitPoint, 1, true)
        AreaForceLoadAreaByAreaTransition(false)
        --print(">>>[RUI]", "RaceCleanup player warp out of car")
    elseif GoKartRaceType == RACE_TIME_TRIALS then
        --print(">>>[RUI]", "RaceCleanup make car ambient")
        VehicleMakeAmbient(player.car)
        for i, racer in racers do
            RaceRemoveRacer(racer.id)
            PedDelete(racer.id)
            if VehicleIsValid(racer.car) then
                VehicleDelete(racer.car)
                --print(">>>[RUI]", "RaceCleanup other cars")
            end
        end
    end
    SoundFadeoutStream()
    RaceCleanUpRace()
    MinigameSetElapsedGameTime(1, 0)
    UnpauseGameClock()
    MinigameDestroy()
    --print(">>>[RUI]", "--RaceCleanup")
end

function T_CountdownStopRaceThread()
    --print(">>>[RUI]", "++T_CountdownStopRaceThread")
    Wait(2000)
    gTimeOutTimer = GetTimer() + race.finish_delay
    while not RaceHasRacerFinished(gPlayer) and TimerPassed(gTimeOutTimer) do
        Wait(100)
        if not MissionActive() then
            break
        end
    end
    race_ongoing = false
    bRaceTimedOut = true
    --print(">>>[RUI]", "--T_CountdownStopRaceThread")
    collectgarbage()
end

function T_CheckInCarThread()
    --print(">>>[RUI]", "++T_CheckInCarThread")
    while not RaceHasFinished() and race_ongoing do
        Wait(500)
        for _, racer in racers do
            if VehicleIsValid(racer.car) and not PedIsInVehicle(racer.id, racer.car) then
                --print(">>>[RUI]", "putting ped " .. racer.id .. " back in car " .. racer.car)
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
        if not PedIsInVehicle(gPlayer, player.car) and bPlayerAbandonedCar == false then
            bPlayerAbandonedCar = true
            gFailMessage = "RACE_OFFGKART"
            race_ongoing = false
            break
        end
        if F_FailPlayerForLeavingTrack() then
            bPlayerLeftTrack = true
            gFailMessage = "RACE_AREAFAIL"
            race_ongoing = false
            break
        end
        if not MissionActive() then
            break
        end
    end
    collectgarbage()
    --print(">>>[RUI]", "--T_CheckInCarThread")
end

function TimerPassed(time)
    return time < GetTimer()
end

function F_FailPlayerForLeavingTrack()
    offTrack = nil
    if not Race_PlayerOnRaceTrack() then
        if gTrackExitTimer then
            TextPrint("RACE_OFFTRACK", 0.5, 1)
            if TimerPassed(gTrackExitTimer) then
                offTrack = true
            end
        else
            gTrackExitTimer = GetTimer() + TRACK_EXIT_FAILURE_DELAY
        end
    else
        gTrackExitTimer = nil
        offTrack = false
    end
    return offTrack
end

function Race_PlayerOnRaceTrack()
    if not gGameArea then
        return true
    elseif not gNoGoArea then
        return (PlayerIsInTrigger(gGameArea))
    else
        return PlayerIsInTrigger(gGameArea) and not PlayerIsInTrigger(gNoGoArea)
    end
end

function T_AutoLoseThread()
    --print(">>>[RUI]", "++T_AutoLoseThread")
    local countdown_started = false
    while not (RaceHasFinished() or countdown_started) do
        Wait(0)
        for i, racer in racers do
            if not RaceHasRacerFinished(gPlayer) and RaceHasRacerFinished(racer.id) then
                CreateThread("T_CountdownStopRaceThread")
                countdown_started = true
                break
            end
        end
        if not MissionActive() then
            break
        end
    end
    --print(">>>[RUI]", "--T_AutoLoseThread")
    collectgarbage()
end

function RaceControlLoop()
    default_FOV = CameraGetFOV()
    WaitForRacersReady(racers)
    TextPrint("GKART_WINRACE", 3, 1)
    Wait(1000)
    if GoKartRaceType == RACE_TIME_TRIALS then
        --print("time to beat****** " .. race.timeToBeat)
        --print("RaceString =" .. RaceString)
        TextAddNonLocalizedString(RaceString)
        TextPrintF("GKART_TIME2BEAT", 3, 1)
        Wait(1000)
    end
    WaitForRaceToStart()
    RaceClearResults()
    Race_HUDVisible(true)
    RaceStartRace()
    Wait(race.head_start)
    PlayerSetControl(1)
    CreateThread("T_CheckInCarThread")
    CreateThread("T_AutoLoseThread")
    local current_lap
    while not RaceHasRacerFinished(gPlayer) and race_ongoing do
        current_lap = RaceGetRacerLapNum(gPlayer)
        if race.cbEvent and race.cbEvent.activate() then
            race.cbEvent.cbFunc()
        end
        if current_lap == race.laps and not bFinalLap then
            TextPrint("RACE_LAST_LAP", 7, 1)
            bFinalLap = true
        end
        Race_HandleRacers()
        Wait(100)
    end
    PlayerSetControl(0)
    --print(">>>[RUI]", "!!RaceControlLoop race done")
end

function Race_HandleRacers()
    for _, racer in racers do
        if VehicleIsValid(racer.car) and not racer.bFinished and RaceHasRacerFinished(racer.id) then
            racer.bFinished = true
            --print(">>>[RUI]", "Race_HandleRacers " .. tostring(racer.name) .. " " .. tostring(racer.endPath))
            VehicleFollowPath(racer.car, racer.endPath)
            if RaceGetPositionInRaceOfRacer(racer.id) == 1 and not bFirstHandled then
                --print(">>>[RUI]", "!!Race_HandleRacers 1ST")
                SoundPlayScriptedSpeechEvent(racer.id, "VICTORY_INDIVIDUAL", 0, "xtralarge")
                bFirstHandled = true
            end
            if RaceGetPositionInRaceOfRacer(racer.id) == 2 and not bSecondHandled then
                --print(">>>[RUI]", "!!Race_HandleRacers 2ND")
                SoundPlayScriptedSpeechEvent(racer.id, "WHINE", 0, "xtralarge")
                bSecondHandled = true
            end
        end
    end
end

function F_CompletionMessageDisplay(heading, money, message)
    local m = money or 0
    if message then
        MinigameSetCompletion(heading, true, m, message)
    else
        MinigameSetCompletion(heading, true, m)
    end
end

function RaceEvaluateResults()
    local sucess = false
    if GoKartTrackType == TRACK_CARNIVAL_RACE then
        StatAddToInt(54)
    else
        StatAddToInt(56)
    end
    if not bPlayerAbandonedCar and not bRaceTimedOut and not bPlayerLeftTrack then
        if GoKartRaceType == RACE_RALLY then
            local playerPosition = RaceGetPositionInRaceOfRacer(gPlayer)
            local moneyWon
            if playerPosition <= 2 then
                if playerPosition == 1 then
                    --print(">>>[RUI]", "!!PLAYER 1ST PLACE")
                    gMessage = nil
                    gHeading = "GKART_YOUWIN"
                    moneyWon = gRaceMoneyAward
                    if GoKartTrackType == TRACK_CARNIVAL_RACE then
                        gTicketsWon = RACE_TICKETS_MAXIMUM * gTicketMultiplier
                        StatAddToInt(55)
                    else
                        StatAddToInt(57)
                    end
                    if gCurrentRace == GK_RACE_CARNIVAL1 then
                        ClothingGivePlayer("SP_GK_Helmet", 0)
                        gMessage = "GKART_HELMET"
                        bUberComplete = true
                    elseif gCurrentRace == GK_RACE_CARNIVAL5 then
                        if GetMissionSuccessCount("GoKart_GP5") == 0 then
                            gMessage = "GKART_RACES"
                        end
                    elseif gCurrentRace == GK_RACE_OUTDOOR3 and GetMissionSuccessCount("GoKart_SR3") == 0 then
                        gMessage = "RACE_UNLOCKGOKART"
                    end
                    shared.gGoKartSRLevel = shared.gGoKartSRLevel + 1
                    sucess = true
                    PedSetActionNode(gPlayer, "/Global/Vehicles/Cars/ExecuteNodes/GoKartVictory/Victory", "Act/Vehicles.act")
                    SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_VICTORY_INDIVIDUAL", 0)
                elseif playerPosition == 2 then
                    --print(">>>[RUI]", "PLAYER 2ND PLACE")
                    gHeading = "GKART_SECOND"
                    if GoKartTrackType == TRACK_CARNIVAL_RACE then
                        gTicketsWon = RACE_TICKETS_MINIMUM * gTicketMultiplier
                        gMessage = "GKART_TICKET"
                    end
                    moneyWon = nil
                end
                SoundPlayMissionEndMusic(true, 4)
                F_CompletionMessageDisplay(gHeading, moneyWon, gMessage)
                if GoKartTrackType == TRACK_CARNIVAL_RACE and gTicketsWon then
                    GiveItemToPlayer(495, gTicketsWon)
                end
                if bUberComplete then
                    MinigameSetUberCompletion()
                    MiniObjectiveSetIsComplete(15)
                end
            else
                --print(">>>[RUI]", "PLAYER LOST")
                SoundPlayMissionEndMusic(false, 4)
                F_CompletionMessageDisplay("GKART_YOULOSE", 0, gFailMessage)
            end
        elseif GoKartRaceType == RACE_TIME_TRIALS then
            if mytimeTotalS <= race.timeToBeat then
                MinigameSetCompletion("GKART_YOUWIN", true, 0)
                shared.gGoKartSRLevel = shared.gGoKartSRLevel + 1
                sucess = true
            else
                MinigameSetCompletion("GKART_YOULOSE", true, 0)
                sucess = false
            end
        end
        CameraAllowChange(true)
        PlayerSetControl(0)
        if F_SetCamera then
            F_SetCamera()
        end
        CameraSetWidescreen(true)
        if GoKartTrackType == TRACK_STREET_RACE then
            --print(">>>[RUI]", "Do outdoor camera")
            VehicleFollowPath(player.car, player.endPath)
        else
            VehicleFollowPath(player.car, player.endPath)
        end
        Wait(200)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
    else
        if bPlayerAbandonedCar then
            PedSetActionNode(gPlayer, "/Global/GoKart/Animations/OutOfCarFail", "Act/Conv/GoKart.act")
        else
            PedSetActionNode(gPlayer, "/Global/Vehicles/Cars/ExecuteNodes/GoKartFailure/Failure", "Act/Vehicles.act")
        end
        SoundPlayMissionEndMusic(false, 4)
        F_CompletionMessageDisplay("GKART_YOULOSE", 0, gFailMessage)
        Wait(1000)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
    end
    --print(">>>[RUI]", "--RaceEvaluateResults " .. tostring(sucess))
    return sucess
end

function Race_InitGeo()
    if GoKartTrackType == TRACK_CARNIVAL_RACE then
        for i, object in CarnivalBarriers do
            if object.bActive then
                object.id, object.pool = CreatePersistentEntity(object.name, object.x, object.y, object.z, object.h, 42)
                Wait(10)
                GeometryInstance(object.name, false, object.x, object.y, object.z, true)
                --print(">>>[RUI]", "++Race_InitGeo created " .. object.name)
            end
        end
        Race_CreateSignals()
    elseif GoKartTrackType == TRACK_STREET_RACE then
        if gSpecialEntities and gSpecialEntities ~= "" then
            --print(">>>[RUI]", "AreaLoadSpecialEntities " .. tostring(gSpecialEntities))
            AreaLoadSpecialEntities(gSpecialEntities, true)
            AreaEnsureSpecialEntitiesAreCreated()
        else
            --print(">>>[RUI]", "No special entities")
        end
    end
    --print(">>>[RUI]", "!!Race_InitGeo")
end

function Race_CreateSignals()
    for _, signal in RaceSignals do
        signal.id, signal.pool = CreatePersistentEntity(signal.name, signal.x, signal.y, signal.z, signal.h, 42)
        Wait(10)
        GeometryInstance(signal.name, true, signal.x, signal.y, signal.z, false)
    end
    --print(">>>[RUI]", "++Race_CreateSignals")
end

function Race_DestroySignals()
    for _, Entry in RaceSignals do
        if Entry.id ~= nil and Entry.id ~= -1 then
            DeletePersistentEntity(Entry.id, Entry.pool)
        end
    end
    --print(">>>[RUI]", "--Race_DestroySignals")
end

function Race_DestroyGeo()
    if GoKartTrackType == TRACK_CARNIVAL_RACE then
        for _, Entry in CarnivalBarriers do
            if Entry.id ~= nil and Entry.id ~= -1 then
                DeletePersistentEntity(Entry.id, Entry.pool)
            end
        end
    elseif GoKartTrackType == TRACK_STREET_RACE then
        AreaLoadSpecialEntities(gSpecialEntities, false)
        AreaForceLoadAreaByAreaTransition(true)
    end
    --print(">>>[RUI]", "--Race_DestroyGeo")
end

function Race_HUDVisible(bOn)
    if bOn then
        if GoKartTrackType == TRACK_CARNIVAL_RACE then
            RadarSetIndoorRange(60)
        else
            RadarSetMinMax(50, 100, 90)
        end
        ToggleHUDComponentVisibility(0, false)
        ToggleHUDComponentVisibility(4, false)
        RaceHUDVisible(true)
    else
        RadarRestoreMinMax()
        ToggleHUDComponentVisibility(0, true)
        ToggleHUDComponentVisibility(4, true)
        RaceHUDVisible(false)
    end
end

function MissionSetup()
    MissionDontFadeIn()
    shared.gDisableBusStops = true
    shared.bDisableRetirementHome = true
    PedSetWeaponNow(gPlayer, -1, 0)
    F_MakePlayerSafeForNIS(true)
    DisablePOI(true, true)
    if IsMissionCompleated("C_Photography_5") then
        gTicketMultiplier = 2
    else
        gTicketMultiplier = 1
    end
end

function MissionCleanup()
    --print(">>>[RUI]", "MissionCleanup")
    shared.bDisableRetirementHome = false
    shared.gDisableBusStops = false
    Race_HUDVisible(false)
    RaceCleanup()
    PedSetWeaponNow(gPlayer, -1, 0)
    ClothingRestore()
    ClothingBuildPlayer()
    SoundFadeWithCamera(true)
    TextClear()
    TutorialRemoveMessage()
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
    EnablePOI(true, true)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    CameraReset()
    PlayerSetControl(1)
    CameraAllowChange(true)
    SoundFadeoutStream()
    UnLoadAnimationGroup("Go_Cart")
    UnLoadAnimationGroup("NPC_Adult")
    DATUnload(2)
    --print(">>>[RUI]", "--MissionCleanup")
    collectgarbage()
end

function main()
    SoundFadeoutStream()
    while gCurrentRace == GK_RACE_UNDEFINED do
        Wait(0)
    end
    RaceInit(gCurrentRace)
    RaceControlLoop()
    Race_HUDVisible(false)
    local bMissionSuccess = RaceEvaluateResults()
    if bMissionSuccess then
        --print(">>>[RUI]", "main WON race")
        MissionSucceed(true, false, false)
    else
        MissionFail(true, false)
    end
end
