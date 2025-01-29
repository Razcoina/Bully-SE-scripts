local mission_completed = false

function MissionSetup()
    DATLoad("TFIGHT01.DAT", 2)
    DATInit()
    PlayerSetHealth(200)
    AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
    EnemyCreate()
end

function EnemyCreate()
    local enemy = PedCreatePoint(15, POINTLIST._TFIGHT01_N_01)
    PedAttack(enemy, gPlayer)
    enemy = PedCreatePoint(15, POINTLIST._TFIGHT01_E_01)
    PedAttack(enemy, gPlayer)
    enemy = PedCreatePoint(24, POINTLIST._TFIGHT01_NE_01)
    PedAttack(enemy, gPlayer)
end

function MissionCleanup()
    DATUnload(2)
end

function main()
    while mission_completed == false do
        Wait(0)
    end
end
