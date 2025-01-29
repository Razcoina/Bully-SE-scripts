ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false
local tEnemies = {
    model = {},
    point = {}
}
local tEnemyID = {}
local totalEnemies = 0

function MissionSetup()
    DATLoad("TFIGHT01.DAT", 2)
    DATInit()
    PlayerSetHealth(200)
    AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
    EnemyCreate()
end

function EnemyCreate()
    tEnemies = {
        {
            model = 24,
            point = POINTLIST._TFIGHT01_E_01
        },
        {
            model = 22,
            point = POINTLIST._TFIGHT01_N_01
        },
        {
            model = 26,
            point = POINTLIST._TFIGHT01_NE_01
        },
        {
            model = 28,
            point = POINTLIST._TFIGHT01_NW_01
        },
        {
            model = 24,
            point = POINTLIST._TFIGHT01_S_01
        },
        {
            model = 22,
            point = POINTLIST._TFIGHT01_SE_01
        },
        {
            model = 26,
            point = POINTLIST._TFIGHT01_SW_01
        },
        {
            model = 28,
            point = POINTLIST._TFIGHT01_W_01
        },
        {
            model = 12,
            point = POINTLIST._TFIGHT01_NWN_01
        },
        {
            model = 17,
            point = POINTLIST._TFIGHT01_NEN_01
        },
        {
            model = 15,
            point = POINTLIST._TFIGHT01_NEE_01
        },
        {
            model = 16,
            point = POINTLIST._TFIGHT01_SEE_01
        },
        {
            model = 12,
            point = POINTLIST._TFIGHT01_SES_01
        },
        {
            model = 17,
            point = POINTLIST._TFIGHT01_SWS_01
        },
        {
            model = 15,
            point = POINTLIST._TFIGHT01_SWW_01
        },
        {
            model = 16,
            point = POINTLIST._TFIGHT01_NWW_01
        }
    }
    totalEnemies = table.getn(tEnemies)
    for i = 1, 16 do
        tEnemyID[i] = PedCreatePoint(tEnemies[i].model, tEnemies[i].point)
    end
end

function MissionCleanup()
    DATUnload(2)
end

function main()
    local deadCount = 0
    local target = 0
    PedSetTypeToTypeAttitude(4, 2, 0)
    PedSetTypeToTypeAttitude(2, 4, 0)
    for i = 1, 16 do
        PedMoveToPoint(tEnemyID[i], 1, POINTLIST._TFIGHT01_C)
        if i <= totalEnemies / 2 then
            target = math.random(totalEnemies / 2 + 1, totalEnemies)
            PedAttack(tEnemyID[i], tEnemyID[target], 1)
        else
            target = math.random(1, totalEnemies / 2)
            PedAttack(tEnemyID[i], tEnemyID[target], 1)
        end
    end
    while mission_completed == false do
        deadCount = 0
        for index, value in tEnemyID do
            if PedIsDead(value) then
                deadCount = deadCount + 1
            end
        end
        --DebugPrint("Number of guys dead is " .. deadCount .. "")
        if deadCount == 16 then
            mission_completed = true
        end
        Wait(0)
        TextPrintString("Press ~t~ to end the script!", 3, 2)
        if IsButtonPressed(9, 0) then
            mission_completed = true
        end
    end
    Wait(3000)
    MissionSucceed()
end
