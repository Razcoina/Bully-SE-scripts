ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false

function MissionSetup()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    DATLoad("TFIGHT01.DAT", 2)
    DATLoad("TFIGHT01POI.DAT", 2)
    DATInit()
    PlayerSetHealth(200)
    AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
    EnemyCreate()
end

function EnemyCreate()
    L_PedLoadPoint(poi1NPC, {
        {
            model = 24,
            point = POINTLIST._TFIGHT01_E_01,
            POINAME = POI._POI1
        },
        {
            model = 22,
            point = POINTLIST._TFIGHT01_N_01,
            POINAME = POI._POI1
        },
        {
            model = 26,
            point = POINTLIST._TFIGHT01_NE_01,
            POINAME = POI._POI1
        },
        {
            model = 28,
            point = POINTLIST._TFIGHT01_NW_01,
            POINAME = POI._POI1
        }
    })
    L_PedLoadPoint(poi2NPC, {
        {
            model = 24,
            point = POINTLIST._TFIGHT01_S_01,
            POINAME = POI._POI2
        },
        {
            model = 22,
            point = POINTLIST._TFIGHT01_SE_01,
            POINAME = POI._POI2
        },
        {
            model = 26,
            point = POINTLIST._TFIGHT01_SW_01,
            POINAME = POI._POI2
        },
        {
            model = 28,
            point = POINTLIST._TFIGHT01_W_01,
            POINAME = POI._POI2
        }
    })
    L_PedLoadPoint(poi3NPC, {
        {
            model = 24,
            point = POINTLIST._TFIGHT01_NWN_01,
            POINAME = POI._POI3
        },
        {
            model = 22,
            point = POINTLIST._TFIGHT01_NEN_01,
            POINAME = POI._POI3
        },
        {
            model = 26,
            point = POINTLIST._TFIGHT01_NEE_01,
            POINAME = POI._POI3
        },
        {
            model = 28,
            point = POINTLIST._TFIGHT01_SEE_01,
            POINAME = POI._POI3
        }
    })
end

function MissionCleanup()
    DATUnload(2)
end

function main()
    L_PedExec(poi1NPC, PedWander, "id", 0)
    L_PedExec(poi2NPC, PedWander, "id", 0)
    L_PedExec(poi3NPC, PedWander, "id", 0)
    L_PedExec(poi1NPC, PedSetPOI, "id", "POINAME")
    L_PedExec(poi2NPC, PedSetPOI, "id", "POINAME")
    L_PedExec(poi3NPC, PedSetPOI, "id", "POINAME")
    while mission_completed == false do
        if L_PedAllDead() then
            mission_completed = true
        end
        Wait(0)
    end
    Wait(3000)
    MissionSucceed()
end
