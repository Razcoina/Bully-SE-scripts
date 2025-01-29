ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false

function MissionSetup()
    DATLoad("TFIGHT01.DAT", 2)
    DATInit()
    AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
    PlayerSetHealth(200)
    PlayerSetPosPoint(POINTLIST._TFIGHT01_C)
    EnemyCreate()
end

function EnemyCreate()
    L_PedLoadPoint(nil, {
        {
            model = MODELENUM._GRH3_Lucky,
            point = POINTLIST._TFIGHT01_NE_01
        }
    })
    L_PedExec(nil, PedSetWeapon, "id", 303, 99)
end

function MissionCleanup()
    DATUnload(2)
end

function main()
    L_PedExec(nil, PedAttack, "id", gPlayer)
    while mission_completed == false do
        if L_PedAllDead() then
            mission_completed = true
        end
        Wait(0)
    end
    Wait(3000)
    MissionSucceed()
end
