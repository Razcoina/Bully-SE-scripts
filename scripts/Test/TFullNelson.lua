mission_completed = false
enemies = {}

function MissionSetup()
    DATLoad("TFIGHT01.DAT", 2)
    DATInit()
    AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
    PlayerSetHealth(200)
    EnemyCreate()
end

function EnemyCreate()
    table.insert(enemies, {
        id = StrikerCreate(POINTLIST._TFIGHT01_N_01)
    })
    table.insert(enemies, {
        id = GrapplerCreate(POINTLIST._TFIGHT01_SE_01)
    })
    for i, entry in enemies do
        PedAttack(entry.id, gPlayer)
    end
end

function EnemyAllDead()
    for i, entry in enemies do
        if PedIsDead(entry.id) == false then
            return false
        end
    end
    return true
end

function MissionCleanup()
    DATUnload(2)
end

function StrikerCreate(point)
    local id = PedCreatePoint(31, point)
    return id
end

function GrapplerCreate(point)
    local id = PedCreatePoint(35, point)
    return id
end

function main()
    while mission_completed == false do
        Wait(0)
        if EnemyAllDead() then
            Wait(1000)
            TextPrintString("Clear Full Nelson Test", 2000)
            Wait(4000)
            MissionSucceed()
        end
    end
end
