local MAX_HATTRICK_DISTANCE = 70
local DESTRUCTO_METER_MAX = 80
local HATTRICK_GATE
local MISSION_RUNNING = 0
local MISSION_PASS = 1
local MISSION_FAIL = 2
local PROP_BREAKABLE_COST = 2
local WINDOW_BREAKABLE_COST = 3
local gPropBreakCount = 0
local gMissionState = MISSION_RUNNING
local gCurrentStage, gFailMessage
local NumBreakablesBroken = 0
local NumBreakablesBrokenEvent = 0
local gCop1, gCopCar1, gCop2, gCopCar2
local bCopAlive = false
local bCop2Alive = false
local bHattrickLine1Done = false
local bHattrickLine2Done = false
local bHattrickLine4Done = false
local gBike1, gBike2, gCop3, gCop4, gCop5, gHattrickCar, gHattrick
local bReadyToGo = false
local bAllBroken = false
local bBreakablesSet = false
local gBreakables
local gMidIntensityStarted = false
local gHighIntensityStarted = false

function F3_BreakablesAllCreate()
    gBreakables = {
        {
            name = "trich_PrepDoor01",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x225",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x75",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x226",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x227",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x228",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x229",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x230",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x231",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x232",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x233",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x234",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x235",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x236",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x237",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x238",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x239",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x240",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x241",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x242",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x243",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x244",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x76",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x77",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x78",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x79",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x80",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x249",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x250",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x81",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x82",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x83",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x84",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x251",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x85",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x86",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x87",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x88",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x253",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x89",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x90",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x91",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x255",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x256",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x225",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x226",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x227",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x228",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x229",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x230",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x231",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_150x232",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x257",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x258",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x259",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPE_G_300x260",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPI_pDoorBrk01",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPI_pCabDoor02",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPI_pCabDoor03",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPI_pCabDoor04",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_DPI_pCabDoor05",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_HT_MrHatricksXINT08",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_HT_MrHatricksXINT07",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_HT_MrHatricksXINT09",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_HT_MrHatricksXINT01",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_HT_MrHatricksXINT02",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_HT_MrHatricksXINT06",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_HT_DormGxref85",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_HT_DormGxref86",
            broken = false,
            count = true,
            cost = WINDOW_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersA13",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersA14",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersA15",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersA16",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersA17",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersA18",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersA19",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_pVase05",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_Planters19",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_Planters20",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_Planters21",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_Planters22",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_Planters23",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersA43",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersA44",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersA45",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_SCfern04",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_SCfern05",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase21",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase22",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase23",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase24",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase25",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase26",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_pVase06",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_pVase07",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_pVase08",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_pVase09",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_pVase10",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersB09",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersB10",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersB11",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersB12",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase27",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase28",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase29",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_pVase11",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_pVase12",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_pVase13",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPI_pVase14",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase30",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase31",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase32",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_FlowersB13",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_HT_DPE_HatSVase33",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_wall_lampSM67",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_wall_lampSM68",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_wall_lampSM69",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_wall_lampSM70",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_wall_lampSM71",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_wall_lampSM72",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_wall_lampSM97",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_wall_lampSM98",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_wall_lampSM109",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_wall_lampSM110",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        },
        {
            name = "trich_wall_lampSM111",
            broken = false,
            count = true,
            cost = PROP_BREAKABLE_COST
        }
    }
    SetNumberOfHandledHashEventObjects(table.getn(gBreakables))
    for _, entry in gBreakables do
        entry.id = ObjectNameToHashID(entry.name)
        RegisterHashEventHandler(entry.id, 0, cbObjectCreatedCallback)
        RegisterHashEventHandler(entry.id, 3, cbObjectBrokenCallback)
    end
    bBreakablesSet = true
    --print(">>>[RUI]", "++F3_BreakablesAllCreate " .. tostring(table.getn(gBreakables)))
end

function GetBreakable(hashId)
    local Breakable
    for _, entry in gBreakables do
        if CompareHashIDs(hashId, entry.id) then
            --print(">>>[RUI]", "GetBreakable found " .. tostring(entry.name))
            Breakable = entry
        end
    end
    return Breakable
end

function cbObjectCreatedCallback(HashID, ModelPoolIndex)
    --print(">>>[RUI]", "cbObjectCreatedCallback entry: " .. tostring(HashID))
    Breakable = GetBreakable(HashID)
    if Breakable and Breakable.broken then
        --print(">>>[RUI]", "cbObjectCreatedCallback created: " .. tostring(Breakable.name))
        ObjectBreak(ModelPoolIndex)
    end
end

function cbObjectBrokenCallback(HashID, ModelPoolIndex)
    --print(">>>[RUI]", "cbObjectBrokenCallback " .. tostring(HashID))
    Breakable = GetBreakable(HashID)
    if Breakable then
        --print(">>>[RUI]", "cbObjectBrokenCallback obj: " .. tostring(Breakable.name) .. " cost: " .. tostring(Breakable.cost))
        bObjectDestroyed = true
        Breakable.broken = true
        IncrementBrokenCounters(Breakable.cost)
    end
end

function F_SpawnCop1()
    --print(">>>[RUI]", "++F_SpawnCop1")
    AreaSetDoorOpen(HATTRICK_GATE, true)
    gCopCar1 = VehicleCreatePoint(295, POINTLIST._2_S02_COP_CAR1)
    gCop1 = PedCreatePoint(97, POINTLIST._2_S02_COP1)
    bCopAlive = true
    PedWarpIntoCar(gCop1, gCopCar1)
    Wait(1000)
    VehicleEnableSiren(gCopCar1, true)
    VehicleSirenAllwaysOn(gCopCar1, true)
    VehicleSetCruiseSpeed(gCopCar1, 35)
    VehicleFollowPath(gCopCar1, PATH._2_S02_COP_CAR1_PATH, true)
    while not VehicleIsInTrigger(gCopCar1, TRIGGER._2_S02_COP_CAR1_STOP) do
        Wait(0)
    end
    VehicleSetCruiseSpeed(gCopCar1, 0)
    VehicleStop(gCopCar1)
    VehicleEnableEngine(gCopCar1, false)
    Wait(2000)
    PedExitVehicle(gCop1)
    Wait(3000)
    --print(">>>[RUI]", "F_SpawnCop1 gCop1 patrol Path")
    PedStop(gCop1)
    PedSetStealthBehavior(gCop1, 1, cbCop1Spot)
    PedOverrideStat(gCop1, 3, 15)
    PedFollowPath(gCop1, PATH._2_S02_COP1STARTER, 0, 1)
end

function cbCop1Spot()
    --print(">>>[RUI]", "!!cbCop1Spot")
    bCop1Spot = true
end

function T_Cop1Monitor()
    --print(">>>[RUI]", "++T_Cop1Monitor")
    while gMissionState == MISSION_RUNNING do
        if not F_PedExists(gCop1) then
            break
        end
        if PedIsInTrigger(gCop1, TRIGGER._2_S02_COP1) or bCop1Spot then
            PedFollowPath(gCop1, PATH._2_S02_COP1_PATH, 1, 0)
            break
        end
        Wait(10)
    end
    collectgarbage()
    --print(">>>[RUI]", "--T_Cop1Monitor")
end

function T_SpawnCopWave01_Go()
    --print(">>>[RUI]", "++T_SpawnCopWave01_Go")
    F_SpawnCop1()
    F_SpawnCop2()
    collectgarbage()
    CreateThread("T_Cop1Monitor")
    --print(">>>[RUI]", "--T_SpawnCopWave01_Go")
end

function T_SpawnCopWave02_Go()
    --print(">>>[RUI]", "++T_SpawnCopWave02_Go")
    F_SpawnCop3()
    F_SpawnCop4()
    F_SpawnCop5()
    collectgarbage()
    --print(">>>[RUI]", "--T_SpawnCopWave02_Go")
end

function F_SpawnCop2()
    --print(">>>[RUI]", "F_SpawnCop2++")
    AreaSetDoorOpen(HATTRICK_GATE, true)
    gCopCar2 = VehicleCreatePoint(295, POINTLIST._2_S02_COP_CAR2)
    gCop2 = PedCreatePoint(97, POINTLIST._2_S02_COP2)
    bCop2Alive = true
    PedWarpIntoCar(gCop2, gCopCar2)
    Wait(1000)
    VehicleEnableSiren(gCopCar2, true)
    VehicleSirenAllwaysOn(gCopCar2, true)
    VehicleSetCruiseSpeed(gCopCar2, 35)
    VehicleFollowPath(gCopCar2, PATH._2_S02_COP_CAR2_PATH, true)
    while not VehicleIsInTrigger(gCopCar2, TRIGGER._2_S02_COP_CAR2_STOP) do
        Wait(0)
    end
    VehicleSetCruiseSpeed(gCopCar2, 0)
    VehicleStop(gCopCar2)
    VehicleEnableEngine(gCopCar2, false)
    Wait(2000)
    PedExitVehicle(gCop2)
    Wait(3000)
    --print(">>>[RUI]", "F_SpawnCop2 gCop2 patrol Path")
    PedStop(gCop2)
    PedSetStealthBehavior(gCop2, 1)
    PedOverrideStat(gCop2, 3, 15)
    PedFollowPath(gCop2, PATH._2_S02_COP2_PATH, 1, 0)
end

function F_SpawnCop3()
    --print(">>>[RUI]", "++F_SpawnCop3")
    AreaSetDoorOpen(HATTRICK_GATE, true)
    gBike1 = VehicleCreatePoint(275, POINTLIST._2_S02_COP_BIKE1)
    VehicleEnableEngine(gBike1, false)
    VehicleEnableSiren(gBike1, true)
    VehicleSirenAllwaysOn(gBike1, true)
    gCop3 = PedCreatePoint(97, POINTLIST._2_S02_COP3)
    PedSetStealthBehavior(gCop3, 1)
    PedOverrideStat(gCop3, 3, 15)
    PedFollowPath(gCop3, PATH._2_S02_COP3_PATH, 3, 0)
end

function F_SpawnCop4()
    --print(">>>[RUI]", "++SpawnCop4")
    gBike2 = VehicleCreatePoint(275, POINTLIST._2_S02_COP_BIKE2)
    VehicleEnableEngine(gBike2, false)
    VehicleEnableSiren(gBike2, true)
    VehicleSirenAllwaysOn(gBike2, true)
    gCop4 = PedCreatePoint(83, POINTLIST._2_S02_COP4)
    PedSetStealthBehavior(gCop4, 1)
    PedOverrideStat(gCop4, 3, 15)
    PedFollowPath(gCop4, PATH._2_S02_COP4_PATH, 1, 0)
end

function F_SpawnCop5()
    --print(">>>[RUI]", "++SpawnCop5")
    gCop5 = PedCreatePoint(83, POINTLIST._2_S02_COP5)
    PedSetStealthBehavior(gCop5, 1)
    PedOverrideStat(gCop5, 3, 15)
    PedFollowPath(gCop5, PATH._2_S02_COP5_PATH, 1, 0)
end

function F_SpawnCop6()
    --print(">>>[RUI]", "++F_SpawnCop6")
    cop6 = PedCreatePoint(97, POINTLIST._2_S02_COP6)
    PedSetStealthBehavior(cop6, 1)
    PedOverrideStat(gHattrick, 3, 35)
    PedFollowPath(cop6, PATH._2_S02_COP6_PATH, 1, 0)
end

function CS_GallowayMeeting()
    --print(">>>[RUI]", "++CS_GallowayMeeting")
    PlayerSetControl(0)
    PlayCutsceneWithLoad("2-S02", true, true)
    PlayerSetPosPoint(POINTLIST._2_S02_AFTER_NIS, 1)
    LoadWeaponModels({ 303 })
    LoadModels({
        297,
        61,
        295,
        97,
        275,
        83
    })
    F_SetCharacterModelsUnique(true, { 61 })
    ClockSet(18, 30)
    CameraFade(500, 1)
    Wait(501)
    PlayerSetControl(1)
end

function NIS_HattrickArrivesHome()
    --print(">>>[RUI]", "--NIS_HattrickArrivesHome")
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    if PedIsInAnyVehicle(gPlayer) then
        local vehicle = PedGetLastVehicle(gPlayer)
        if F_ObjectIsValid(vehicle) and VehicleIsValid(vehicle) then
            VehicleStop(vehicle)
        end
    else
        PedSetActionNode(gPlayer, "/Global/Vehicles/SkateBoard/Locomotion/Ride/Coast", "Act/Vehicles.act")
    end
    Wait(1000)
    CameraFade(FADE_OUT_TIME, 0)
    Wait(FADE_OUT_TIME + 1)
    --print(">>>[RUI]", "NIS_HattrickArrivesHome  faded out")
    F_MakePlayerSafeForNIS(true)
    F_PlayerExitBike(true)
    Wait(50)
    local x, y, z = GetPointList(POINTLIST._2_S02_PLAYER_INTRO_NIS2)
    PlayerSetPosSimple(x, y, z)
    CameraSetXYZ(404.6507, 500.78845, 22.782606, 404.2575, 501.70367, 22.869776)
    HattrickCarCleanup(true)
    VehicleOverrideAmbient(0, 0, 0, 0)
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaClearAllPeds()
    AreaClearAllVehicles()
    F1_RemoveVehicles(POINTLIST._2_S02_BIKE_DELETE, 60)
    F3_BreakablesAllCreate()
    HattrickCarCreate(2)
    CameraFade(1000, 1)
    VehicleFollowPath(gHattrickCar, PATH._2_S02_CARENTERDRIVEWAY, true)
    VehicleSetCruiseSpeed(gHattrickCar, 1.5)
    Wait(200)
    VehicleSetCruiseSpeed(gHattrickCar, 2.5)
    Wait(200)
    VehicleSetCruiseSpeed(gHattrickCar, 4.5)
    Wait(600)
    while not VehicleIsInTrigger(gHattrickCar, TRIGGER._2_S02_CARINDRIVEWAY) do
        Wait(0)
    end
    PedFollowPath(gPlayer, PATH._2_S02_PLAYERENTERYARD, 0, 0, cbPlayerAtYard)
    VehicleEnableEngine(gHattrickCar, false)
    VehicleStop(gHattrickCar)
    SoundPlay2D("Car_DoorOpen")
    Wait(700)
    SoundPlay2D("Car_DoorClose")
    PedFollowPath(gHattrick, PATH._2_S02_HATTRICK_TO_HOUSE, 0, 0, cbHattrickInHouse)
    CreateThread("T_HattrickEntersHouse")
    while not bPlayerAtYard do
        Wait(0)
    end
    CameraSetWidescreen(false)
    CameraReturnToPlayer(false)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    --print(">>>[RUI]", "--NIS_HattrickArrivesHome")
end

function cbPlayerAtYard(pedId, pathId, pathNode)
    if pathNode == PathGetLastNode(pathId) then
        bPlayerAtYard = true
    end
end

function F1_RemoveVehicles(point, radius)
    local vx, vy, vz = GetPointList(point)
    local vehicleTable = VehicleFindInAreaXYZ(vx, vy, vz, radius, true)
    if vehicleTable then
        for _, vehicle in vehicleTable do
            VehicleDelete(vehicle)
        end
    end
    --print(">>>[RUI]", "--F1_RemoveVehicles")
end

function HattrickGateOpen(bOpen)
    if bOpen then
        AreaSetDoorLocked(HATTRICK_GATE, false)
        AreaSetDoorLockedToPeds(HATTRICK_GATE, true)
        AreaSetDoorPathableToPeds(TRIGGER._HATTRICK_GATE, true)
        AreaSetDoorLockedToPeds(TRIGGER._HATTRICKDOOR, false)
        AreaSetDoorPathableToPeds(TRIGGER._HATTRICKDOOR, true)
        PAnimOpenDoor(TRIGGER._HATTRICK_GATE)
        --print(">>>[RUI]", "HattrickGateOpen LOCK")
    else
        AreaSetDoorLocked(HATTRICK_GATE, true)
        AreaSetDoorLockedToPeds(HATTRICK_GATE, true)
        AreaSetDoorPathableToPeds(TRIGGER._HATTRICK_GATE, false)
        AreaSetDoorLockedToPeds(TRIGGER._HATTRICKDOOR, true)
        AreaSetDoorPathableToPeds(TRIGGER._HATTRICKDOOR, false)
        PAnimCloseDoor(TRIGGER._HATTRICK_GATE)
        --print(">>>[RUI]", "HattrickGateOpen UNLOCK")
    end
end

function T_HattrickEntersHouse()
    --print(">>>[RUI]", "++T_HattrickEntersHouse")
    while not bHattrickInHouse do
        if bHattrickHit or bObjectDestroyed then
            PedIgnoreStimuli(gHattrick, false)
            PedRemovePedFromIgnoreList(gHattrick, gPlayer)
            PedAttack(gHattrick, gPlayer)
            gCurrentStage = nil
            gMissionState = MISSION_FAIL
            gFailMessage = "2_S02_FAIL01"
            bFailInYard = true
            return
        end
        Wait(10)
    end
    bReadyToGo = true
    AreaSetDoorLocked(TRIGGER._HATTRICKDOOR, true)
    AreaSetDoorLockedToPeds(TRIGGER._HATTRICKDOOR, true)
    AreaSetDoorPathableToPeds(TRIGGER._HATTRICKDOOR, false)
    Wait(1000)
    PedDelete(gHattrick)
    gHattrick = HattrickCreateInHouse()
    --print(">>>[RUI]", "--T_HattrickEntersHouse")
    collectgarbage()
end

function HattrickCreateInHouse()
    --print(">>>[RUI]", "++HattrickCreateInHouse")
    local hattrick = PedCreatePoint(61, POINTLIST._2_S02_HATTRICKINHOUSE, 1)
    BlipRemoveFromChar(hattrick)
    PedStop(hattrick)
    PedSetStationary(hattrick, true)
    PedIgnoreStimuli(hattrick, true)
    PedIgnoreAttacks(hattrick, true)
    PedMakeTargetable(hattrick, false)
    PedSetInvulnerable(hattrick, true)
    PedSetImmortalFlag(hattrick, true)
    PedSetMinHealth(hattrick, 50)
    return hattrick
end

function F3_PlayerLeftYard()
    if not PlayerIsInTrigger(TRIGGER._2_S02_HATTRICKYARD) then
        TextPrint("2_S02_25", 0, 1)
        if not PlayerIsInTrigger(TRIGGER._2_S02_END_TRIGGER1) then
            return true
        end
    end
    return false
end

function F4_HattrickChasePlayer()
    --print(">>>[RUI]", "++F4_HattrickChasePlayer")
    PedSetPosPoint(gHattrick, POINTLIST._2_S02_HATTRICKINHOUSE, 2)
    hattrickBlip = AddBlipForChar(gHattrick, 8, 2, 1)
    PedSetStationary(gHattrick, false)
    PedIgnoreStimuli(gHattrick, false)
    PedIgnoreAttacks(gHattrick, false)
    PedMakeTargetable(gHattrick, true)
    PedSetMinHealth(gHattrick, -100)
    PedSetInvulnerable(gHattrick, false)
    PedSetImmortalFlag(gHattrick, false)
    AreaSetDoorLocked(TRIGGER._HATTRICKDOOR, true)
    AreaSetDoorLockedToPeds(TRIGGER._HATTRICKDOOR, false)
    AreaSetDoorPathableToPeds(TRIGGER._HATTRICKDOOR, true)
    PedOverrideStat(gHattrick, 3, 40)
    PedOverrideStat(gHattrick, 14, 100)
    PedOverrideStat(gHattrick, 33, 150)
    PedSetIsStealthMissionPed(gHattrick, true)
    PedSetStealthBehavior(gHattrick, 0, cbHattrickAttack, cbHattrickAttack)
    PedFollowPath(gHattrick, PATH._2_S02_HATTRICKLEAVEHOUSE, 0, 1, cbHattrickOutside)
end

function cbHattrickOutside(pedId, pathId, pathNode)
    if pathNode == 1 then
        --print(">>>[RUI]", "!!cbHattrickOutside lock doors")
        AreaSetDoorLocked(TRIGGER._HATTRICKDOOR, true)
        AreaSetDoorLockedToPeds(TRIGGER._HATTRICKDOOR, true)
        AreaSetDoorPathableToPeds(TRIGGER._HATTRICKDOOR, false)
    end
end

function cbHattrickAttack()
    --print(">>>[RUI]", "!!cbHattrickAttack")
    if not bHattrickAttacking then
        SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 10, "supersize")
        PedAttackPlayer(gHattrick, 1, true)
        bHattrickAttacking = true
    end
end

function cbHattrickInHouse(pedId, pathId, pathNode)
    if pedId == gHattrick and pathNode == PathGetLastNode(pathId) then
        bHattrickInHouse = true
    end
end

function cbHattrickHit(victim, attacker)
    if attacker == gPlayer and (victim == gHattrick or victim == gHattrick) then
        bHattrickHit = true
    end
end

function ObjectiveBlipUpdate(blip)
    --print(">>>[RUI]", "!!ObjectiveBlipUpdate")
    gObjectiveBlip = F_CleanBlip(gObjectiveBlip)
    gObjectiveBlip = blip
end

function UpdateObjectiveLog(newObjStr, oldObj)
    local newObj
    if newObjStr then
        newObj = MissionObjectiveAdd(newObjStr)
        TextPrint(newObjStr, 3, 1)
    end
    if oldObj then
        MissionObjectiveComplete(oldObj)
    end
    return newObj
end

function CounterSetup(bOn)
    local on = true
    if bOn ~= nil then
        on = bOn
    end
    if on then
        CounterUseMeter(true)
        CounterSetCurrent(0)
        CounterSetMax(DESTRUCTO_METER_MAX)
        CounterSetIcon("Window", "Window_x")
        CounterMakeHUDVisible(true)
        --print(">>>[RUI]", "++CounterSetup")
    else
        CounterUseMeter(false)
        CounterMakeHUDVisible(false)
        CounterClearIcon()
        CounterSetMax(0)
        CounterSetCurrent(0)
        --print(">>>[RUI]", "--CounterSetup")
    end
end

function IncrementBrokenCounters(num)
    local n = num or 1
    NumBreakablesBrokenEvent = NumBreakablesBrokenEvent + n
    NumBreakablesBroken = NumBreakablesBroken + n
    if bAllBroken then
        return
    end
    CounterSetCurrent(NumBreakablesBroken)
    --print(">>>[RUI]", "++IncrementBrokenCounters", tostring(n))
end

function MakeAmbient(ped)
    if F_PedExists(ped) then
        PedMakeAmbient(ped)
        --print(">>>[RUI]", "--MakeAmbient")
    end
end

function CarCleanup(car)
    if car and car ~= -1 then
        VehicleMakeAmbient(car)
        --print(">>>[RUI]", "--CarCleanup")
    end
end

function F_CleanBlip(blip)
    if blip then
        BlipRemove(blip)
    end
    return nil
end

function HattrickCarCreate(stage)
    if stage == 1 then
        gHattrickCar = VehicleCreatePoint(297, POINTLIST._2_S02_HATTRICK_CAR, 1)
        gHattrick = PedCreatePoint(61, POINTLIST._2_S02_HATTRICK_DRIVER, 1)
        BlipRemoveFromChar(gHattrick)
        PedIgnoreStimuli(gHattrick, true)
        PedSetFlag(gHattrick, 108, true)
        PedAddPedToIgnoreList(gHattrick, gPlayer)
        PedMakeTargetable(gHattrick, false)
        PedSetAsleep(gHattrick, true)
        PedWarpIntoCar(gHattrick, gHattrickCar)
        VehicleEnableEngine(gHattrickCar, true)
        VehicleSetColor(gHattrickCar, 96, 96)
    else
        gHattrickCar = VehicleCreatePoint(297, POINTLIST._2_S02_HATTRICK_CAR, 2)
        gHattrick = PedCreatePoint(61, POINTLIST._2_S02_HATTRICK_DRIVER, 2)
        BlipRemoveFromChar(gHattrick)
        PedIgnoreStimuli(gHattrick, true)
        PedAddPedToIgnoreList(gHattrick, gPlayer)
        PedMakeTargetable(gHattrick, false)
        RegisterPedEventHandler(gHattrick, 0, cbHattrickHit)
        VehicleSetColor(gHattrickCar, 96, 96)
    end
    --print(">>>[RUI]", "++HattrickCarCreate")
end

function HattrickLeaveCarAndAttack()
    --print(">>>[RUI]", "!!HattrickLeaveCarAndAttack")
    VehicleStop(gHattrickCar)
    SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 10, "large")
    PedIgnoreStimuli(gHattrick, false)
    PedSetFlag(gHattrick, 108, false)
    PedRemovePedFromIgnoreList(gHattrick, gPlayer)
    PedMakeTargetable(gHattrick, true)
    PedSetAsleep(gHattrick, false)
    PedCreateStimulus(gPlayer, gHattrick, 2)
    VehicleEnableEngine(gHattrickCar, false)
end

function HattrickCarCleanup(bImmediate)
    if F_PedExists(gHattrick) then
        if bImmediate then
            PedDelete(gHattrick)
        else
            PedMakeAmbient(gHattrick)
        end
    end
    if gHattrickCar and gHattrickCar ~= -1 then
        VehicleStop(gHattrickCar)
        if bImmediate then
            VehicleDelete(gHattrickCar)
        else
            VehicleMakeAmbient(gHattrickCar, false)
        end
    end
    --print(">>>[RUI]", "--HattrickCarCleanup")
end

function F3_AllPropsDestroyed()
    if PAnimNumDestroyed(TRIGGER._2_S02_HATTRICKYARD) >= 0 then
        NewBreakablesBrokenEvent = PAnimNumDestroyed(TRIGGER._2_S02_HATTRICKYARD)
        if NewBreakablesBrokenEvent > NumBreakablesBrokenEvent then
            NumBreakablesBrokenEvent = NewBreakablesBrokenEvent
            gPropBreakCount = gPropBreakCount + 3
        end
        if not bAllBroken then
            CounterSetCurrent(NumBreakablesBrokenEvent)
        end
        if 5 <= NumBreakablesBrokenEvent and not bHattrickLine1Done then
            bHattrickLine1Done = true
            SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 3, "supersize")
        end
        if 10 <= NumBreakablesBrokenEvent and not bHattrickLine2Done then
            bHattrickLine2Done = true
            SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 4, "supersize")
            CreateThread("T_SpawnCopWave01_Go")
        end
        if 15 <= NumBreakablesBrokenEvent and not hattrick_line3 then
            hattrick_line3 = true
            SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 6, "supersize")
        end
        if 20 <= NumBreakablesBrokenEvent and not bHattrickLine4Done then
            bHattrickLine4Done = true
            SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 6, "supersize")
        end
        if 25 <= NumBreakablesBrokenEvent then
            if not gMidIntensityStarted then
                SoundPlayInteractiveStreamLocked("MS_DestructionVandalismMid.rsm", 0.6, 500, 500)
                gMidIntensityStarted = true
            end
            if not hattrick_line5 then
                hattrick_line5 = true
                CreateThread("T_SpawnCopWave02_Go")
                SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 6, "supersize")
            end
        end
        if 30 <= NumBreakablesBrokenEvent and not hattrick_line6 then
            hattrick_line6 = true
            SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 6, "supersize")
        end
        if 35 <= NumBreakablesBrokenEvent and not hattrick_line7 then
            hattrick_line7 = true
            SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 7, "supersize")
        end
        if 40 <= NumBreakablesBrokenEvent and not hattrick_line8 then
            hattrick_line8 = true
            SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 7, "supersize")
            F_SpawnCop6()
        end
        if 45 <= NumBreakablesBrokenEvent then
            if not gHighIntensityStarted then
                SoundPlayInteractiveStreamLocked("MS_DestructionVandalismHigh.rsm", 0.7, 500, 500)
                gHighIntensityStarted = true
            end
            if not hattrick_line9 then
                hattrick_line9 = true
                SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 5, "supersize")
            end
        end
        if 50 <= NumBreakablesBrokenEvent and not hattrick_line10 then
            hattrick_line10 = true
            SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 7, "supersize")
        end
        if 60 <= NumBreakablesBrokenEvent and not hattrick_line11 then
            hattrick_line11 = true
            SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 7, "supersize")
        end
        if NumBreakablesBrokenEvent >= DESTRUCTO_METER_MAX then
            if F_PedExists(gCop3) then
                PedFollowPath(gCop3, PATH._2_S02_HATTRICK_TO_HOUSE, 3, 0)
            end
            SoundPlayScriptedSpeechEvent(gHattrick, "M_2_S02", 8, "supersize")
            bAllBroken = true
            return true
        end
    end
    return false
end

function Stage00_FindCarInit()
    --print(">>>[RUI]", "!!Stage00_FindCarInit")
    local blip = BlipAddPoint(POINTLIST._2_S02_HATTRICK_CAR, 0, 1, 1, 0)
    ObjectiveBlipUpdate(blip)
    gObjective = UpdateObjectiveLog("2_S02_OBJ00", gObjective)
    gCurrentStage = Stage00_FindCarLoop
end

function Stage00_FindCarLoop()
    if F1_HattrickCarDamageCheck(gHattrickCar) then
        --print(">>>[RUI]", "!!Stage00_FindCarLoop Car attacked")
        gFailMessage = "2_S02_FAIL02"
        gCurrentStage = nil
        gMissionState = MISSION_FAIL
        HattrickLeaveCarAndAttack()
        return
    end
    if PlayerIsInTrigger(TRIGGER._2_S02_CARTRIGGER) then
        gCurrentStage = Stage01_FollowHattrickInit
    elseif PlayerIsInTrigger(TRIGGER._2_S02_CARINIT) and not bHattrickCarMade then
        HattrickCarCreate(1)
        local blip = AddBlipForCar(gHattrickCar, 0, 4)
        VehicleSetCruiseSpeed(gHattrickCar, 2)
        VehicleFollowPath(gHattrickCar, PATH._2_S02_FROMSCHOOL, true)
        Wait(10)
        VehicleStop(gHattrickCar)
        ObjectiveBlipUpdate(blip)
        bHattrickCarMade = true
    end
end

function Stage01_FollowHattrickInit()
    --print(">>>[RUI]", "!!Stage01_FollowHattrickInit")
    VehicleOverrideAmbient(1, 1, 0, 0)
    AreaClearAllVehicles()
    gObjective = UpdateObjectiveLog("2_S02_OBJ01", gObjective)
    gHattrickLeaveTimer = GetTimer() + 3500
    TutorialShowMessage("TUT_SKTC01", 5000, false)
    --print(">>>[RUI]", "++Stage01A_StartCarLoop")
    gCurrentStage = Stage01A_StartCarLoop
end

function Stage01A_StartCarLoop()
    if PlayerIsInTrigger(TRIGGER._2_S02_CARFAILTRIGGER) or PedIsStandingOnVehicle(gPlayer, gHattrickCar) then
        --print(">>>[RUI]", "!!Stage01A_StartCarLoop car attacked")
        gFailMessage = "2_S02_FAIL01"
        gMissionState = MISSION_FAIL
        HattrickLeaveCarAndAttack()
        gCurrentStage = nil
        return
    elseif TimerPassed(gHattrickLeaveTimer) then
        --print(">>>[RUI]", "Stage01A_StartCarLoop Drive off")
        VehicleSetDrivingMode(gHattrickCar, 3)
        VehicleSetMission(gHattrickCar, 22)
        gStartSpeed = 0.5
        VehicleSetCruiseSpeed(gHattrickCar, gStartSpeed)
        VehicleFollowPath(gHattrickCar, PATH._2_S02_FROMSCHOOL, true)
        bRegulateHattrickCar = true
        CreateThread("T1_HattrickCarGovernor")
        gCurrentStage = Stage01_FollowHattrickLoop
    end
end

function TimerPassed(time)
    return time < GetTimer()
end

function Stage01_FollowHattrickLoop()
    if VehicleIsInTrigger(gHattrickCar, TRIGGER._2_S02_HATTRICKNIS) then
        NIS_HattrickArrivesHome()
        gCurrentStage = Stage02_GetInYardInit
    end
    if F1_HattrickCarDamageCheck(gHattrickCar) or PedIsStandingOnVehicle(gPlayer, gHattrickCar) then
        --print(">>>[RUI]", "!!Stage01_FollowHattrickLoop Car attacked")
        if PedIsStandingOnVehicle(gPlayer, gHattrickCar) then
            gFailMessage = "2_S02_FAIL01"
        else
            gFailMessage = "2_S02_FAIL02"
        end
        gCurrentStage = nil
        gMissionState = MISSION_FAIL
        HattrickLeaveCarAndAttack()
        return
    end
    if DistanceBetweenPeds3D(gPlayer, gHattrick) >= MAX_HATTRICK_DISTANCE then
        gFailMessage = "2_S02_FAIL03"
        gCurrentStage = nil
        gMissionState = MISSION_FAIL
        return
    end
end

function F1_HattrickCarDamageCheck(car)
    if not F_ObjectIsValid(car) then
        return false
    end
    if not VehicleIsValid(car) then
        return false
    end
    if CarGetDamageNumber(car) >= 2 then
        return true
    end
    return false
end

function T1_HattrickCarGovernor()
    --print(">>>[RUI]", "++T1_HattrickCarGovernor")
    Wait(300)
    while gStartSpeed < 7 do
        Wait(10)
        gStartSpeed = gStartSpeed + 0.1
        VehicleSetCruiseSpeed(gHattrickCar, gStartSpeed)
    end
    while not VehicleIsInTrigger(gHattrickCar, TRIGGER._2_S02CARSPEEDUP) do
        if gMissionState ~= MISSION_RUNNING then
            break
        end
        Wait(0)
    end
    --print(">>>[RUI]", "T1_HattrickCarGovernor  speed up")
    VehicleSetCruiseSpeed(gHattrickCar, 12)
    while not VehicleIsInTrigger(gHattrickCar, TRIGGER._2_S02_INTRO_FAILURE) do
        Wait(0)
    end
    --print(">>>[RUI]", "T1_HattrickCarGovernor  slow down open gate")
    HattrickGateOpen(true)
    collectgarbage()
    --print(">>>[RUI]", "--T1_HattrickCarGovernor")
end

function Stage02_GetInYardInit()
    --print(">>>[RUI]", "!!Stage02_GetInYardInit")
    SoundPlayInteractiveStreamLocked("MS_DestructionVandalismMid.rsm", MUSIC_DEFAULT_VOLUME, 500, 500)
    RadarSetMinMax(30, 75, 45)
    local blip = BlipAddPoint(POINTLIST._2_S02_HATTRICKYARDBLIP, 0, 1, 1)
    ObjectiveBlipUpdate(blip)
    VehicleStop(gHattrickCar)
    VehicleEnableEngine(gHattrickCar, false)
    VehicleSetMission(gHattrickCar, 11)
    VehicleSetStatus(gHattrickCar, 4)
    MissionTimerStart(10)
    gObjective = UpdateObjectiveLog("2_S02_OBJ04", gObjective)
    gCurrentStage = Stage02_GetInYardLoop
end

function Stage02_GetInYardLoop()
    if MissionTimerHasFinished() then
        MissionTimerStop()
        HattrickGateOpen(false)
        bDidntGetInYardInTime = true
        gFailMessage = "PUN_02"
        gMissionState = MISSION_FAIL
        gCurrentStage = nil
        return
    end
    if PlayerIsInTrigger(TRIGGER._2_S02_HATTRICKYARD) then
        MissionTimerStop()
        gCurrentStage = Stage03_DestroyEverythingInit
    end
end

function Stage03_DestroyEverythingInit()
    --print(">>>[RUI]", "!!Stage03_DestroyEverythingInit")
    ObjectiveBlipUpdate(nil)
    CounterSetup(true)
    gObjective = UpdateObjectiveLog("2_S02_OBJ02", gObjective)
    gCurrentStage = Stage03_DestroyEverythingLoop
    CreateThread("T_DestructoTutorial")
    gOldDamageState = CarGetDamageNumber(gHattrickCar)
end

function Stage03_DestroyEverythingLoop()
    if F3_AllPropsDestroyed() then
        gCurrentStage = Stage04_EscapeInit
    else
        F3_CarDamageCheck()
        if F3_PlayerLeftYard() then
            gFailMessage = "2_S02_FAIL04"
            gMissionState = MISSION_FAIL
            gCurrentStage = nil
            return
        end
    end
end

function T_DestructoTutorial()
    Wait(3000)
    TutorialShowMessage("2_S02_24", 4000)
end

function F3_CarDamageCheck()
    gNewDamageState = CarGetDamageNumber(gHattrickCar)
    if gNewDamageState ~= gOldDamageState then
        --print(">>>[RUI]", "F3_CarDamageCheck " .. tostring(gNewDamageState))
        IncrementBrokenCounters(2)
        gOldDamageState = gNewDamageState
    end
end

function Stage04_EscapeInit()
    --print(">>>[RUI]", "!!Stage04_EscapeInit")
    gObjective = UpdateObjectiveLog("2_S02_OBJ03", gObjective)
    F4_HattrickChasePlayer()
    CounterSetup(false)
    gCurrentStage = Stage04_EscapeLoop
end

function Stage04_EscapeLoop()
    if not PlayerIsInTrigger(TRIGGER._2_S02_HATTRICKYARD) then
        if hattrickBlip then
            BlipRemove(hattrickBlip)
        end
        ObjectiveBlipUpdate(nil)
        gObjective = UpdateObjectiveLog(nil, gObjective)
        gMissionState = MISSION_PASS
        gCurrentStage = nil
        return
    end
end

function MissionSetup()
    MissionDontFadeIn()
    DATLoad("2_S02.DAT", 2)
    DATInit()
    HATTRICK_GATE = ObjectNameToHashID("HATTRICK_GATE")
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._2_S02_PATHVOLUME, true)
    WeaponRequestModel(303)
    SoundEnableInteractiveMusic(true)
    SoundLoadBank("Engine.bnk")
end

function MissionInit()
    --print(">>>[RUI]", "!!MissionInit")
    CS_GallowayMeeting()
end

function MissionCleanup()
    MissionTimerStop()
    SoundStopInteractiveStream()
    if PlayerIsInTrigger(TRIGGER._2_S02_HATTRICKYARD) then
        PedSetPosPoint(gPlayer, POINTLIST._2_S02_EMERGENCYPOINT, 1)
    end
    CounterSetup(false)
    HattrickCarCleanup()
    if F_PedExists(gHattrick) then
        PedSetIsStealthMissionPed(gHattrick, false)
        PedSetStationary(gHattrick, false)
        PedIgnoreStimuli(gHattrick, false)
        PedIgnoreAttacks(gHattrick, false)
        PedMakeTargetable(gHattrick, true)
        PedSetMinHealth(gHattrick, -100)
        PedSetMinHealth(gHattrick, -100)
        PedSetInvulnerable(gHattrick, false)
        PedSetImmortalFlag(gHattrick, false)
        PedMakeAmbient(gHattrick)
    end
    F_SetCharacterModelsUnique(false)
    MakeAmbient(gCop1)
    CarCleanup(gCopCar1)
    MakeAmbient(gCop2)
    CarCleanup(gCopCar2)
    MakeAmbient(gCop3)
    MakeAmbient(gCop4)
    MakeAmbient(gCop5)
    MakeAmbient(cop6)
    CarCleanup(gBike1)
    CarCleanup(gBike2)
    if not bAllBroken then
        PAnimCloseDoor(TRIGGER._HATTRICK_GATE)
        AreaSetDoorLocked(TRIGGER._HATTRICK_GATE, true)
        AreaSetDoorLocked(TRIGGER._HATTRICKDOOR, true)
        AreaSetDoorLockedToPeds(TRIGGER._HATTRICKDOOR, true)
        AreaSetDoorPathableToPeds(TRIGGER._HATTRICKDOOR, false)
    end
    CameraReturnToPlayer()
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._2_S02_PATHVOLUME, false)
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
    DATUnload(2)
end

function main()
    MissionInit()
    gCurrentStage = Stage00_FindCarInit
    while gMissionState == MISSION_RUNNING do
        if gCurrentStage then
            gCurrentStage()
        end
        Wait(0)
    end
    if gMissionState == MISSION_PASS then
        CameraSetWidescreen(true)
        SoundPlayMissionEndMusic(true, 10)
        MissionSucceed(false, true, true, 4000)
    else
        SoundPlayMissionEndMusic(false, 10)
        if gFailMessage then
            MissionFail(false, true, gFailMessage)
        else
            MissionFail(false, true)
        end
    end
end
