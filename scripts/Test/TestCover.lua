ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false

function MissionSetup()
    DATLoad("TFIGHT01.DAT", 2)
    DATInit()
    PlayerSetHealth(200)
    AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
    EnemyCreate()
end

function EnemyCreate()
    c = PedCreatePoint(28, POINTLIST._TFIGHT01_NE_01)
    PedSetWeapon(c, 329, 999)
    PedCoverSet(c, gPlayer, POINTLIST._TFIGHT01_NE_01, 50, 50, 5, 0, 0, 1, 1, 1, 1, 1, 1, true)
    c = PedCreatePoint(28, POINTLIST._TFIGHT01_E_01)
    PedSetWeapon(c, 329, 999)
    PedCoverSet(c, gPlayer, POINTLIST._TFIGHT01_E_01, 50, 50, 5, 5, 10, 1, 1, 1, 1, 1, 1, true)
    c = PedCreatePoint(28, POINTLIST._TFIGHT01_SE_01)
    PedSetWeapon(c, 329, 999)
    PedCoverSet(c, gPlayer, POINTLIST._TFIGHT01_SE_01, 50, 50, 5, 0, 0, 1, 1, 1, 1, 1, 1, true)
    c = PedCreatePoint(28, POINTLIST._TFIGHT01_W_01)
    PedSetWeapon(c, 329, 999)
    PedCoverSet(c, gPlayer, POINTLIST._TFIGHT01_W_01, 50, 50, 5, 5, 10, 1, 1, 1, 1, 1, 1, true)
end

function MissionCleanup()
    DATUnload(2)
end

function main()
    while mission_completed == false do
        Wait(0)
    end
    Wait(3000)
    MissionSucceed()
end
