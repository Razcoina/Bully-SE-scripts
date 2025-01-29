ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false

function MissionSetup()
    DATLoad("TFIGHT01.DAT", 2)
    DATInit()
    AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
    PlayerSetHealth(200)
    EnemyCreate()
end

function EnemyCreate()
    L_PedLoadPoint(nil, {
        {
            model = 17,
            point = POINTLIST._TFIGHT01_NE_01
        },
        {
            model = 15,
            point = POINTLIST._TFIGHT01_E_01
        },
        {
            model = 29,
            point = POINTLIST._TFIGHT01_SE_01
        },
        {
            model = 24,
            point = POINTLIST._TFIGHT01_W_01
        }
    })
end

function MissionCleanup()
    DATUnload(2)
end

function main()
    PedSetTypeToTypeAttitude(2, 4, 0)
    PedSetTypeToTypeAttitude(4, 2, 0)
    L_PedExec(nil, PedOverrideStat, "id", 3, 60)
    L_PedExec(nil, PedOverrideStat, "id", 2, 359)
    L_PedExec(nil, PedOverrideStat, "id", 4, 400)
    while mission_completed == false do
        if L_PedAllDead() then
            mission_completed = true
        end
        Wait(0)
    end
    Wait(1000)
    TextPrintString("Clear Fight Test", 2000)
    Wait(4000)
    MissionSucceed()
end
