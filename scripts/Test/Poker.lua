local mission_completed = false

function MissionSetup()
    local x, y, z = -527.9, 137.8, 50.7
    PlayerSetHealth(200)
    AreaTransitionXYZ(32, x, y, z + 1)
end

function EnemyCreate()
    local model = 15
    local x, y, z = -524.25, 126.2, 50.7
    local ped = PedCreateXYZ(model, x, y, z)
    PedAttack(ped, gPlayer, true, false)
end

function MissionCleanup()
end

function main()
    Wait(3000)
    EnemyCreate()
    while mission_completed == false do
        Wait(0)
    end
    Wait(1000)
    TextPrintString("Clear Fight Test", 2000)
    Wait(4000)
    MissionSucceed()
end
