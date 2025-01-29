local mission_completed = false

function MissionSetup()
    local x, y, z = 3, 23, 27
    PlayerSetHealth(200)
    AreaTransitionXYZ(22, x, y, z)
    pickup = PickupCreateXYZ(311, 3, 12, 26.061)
    EnemyCreate()
end

function EnemyCreate()
    local model = 15
    local x, y, z = 6, 38, 26
    local ped = PedCreateXYZ(model, x, y, z)
    PedPickup(ped, pickup)
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
