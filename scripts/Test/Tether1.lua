local mission_completed = false

function MissionSetup()
    PlayerSetHealth(200)
    local x, y, z = -9, 23, 27
    AreaTransitionXYZ(22, x, y, z)
    EnemyCreate()
end

function EnemyCreate()
    local model = 17
    local x, y, z = 0, 23, 27
    local ped = PedCreateXYZ(model, x, y, z)
    PedSetTetherToXYZ(ped, x, y, z, 5)
    PedAttack(ped, gPlayer, true, false)
end

function MissionCleanup()
end

function main()
    while mission_completed == false do
        Wait(0)
    end
    Wait(1000)
    TextPrintString("Clear Fight Test", 2000)
    Wait(4000)
    MissionSucceed()
end
