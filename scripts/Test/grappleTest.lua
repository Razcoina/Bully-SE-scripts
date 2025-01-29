ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false
local grappleLevel = 0
g_PosX, g_PosY, g_PosZ = -8, 57, 27

function MissionSetup()
    PlayerSetHealth(200)
    local Offset = 2
    AreaTransitionXYZ(22, g_PosX, g_PosY + Offset, g_PosZ)
    grappleMissions = {
        {
            name = "C_Wrestling_1"
        },
        {
            name = "C_Wrestling_2"
        },
        {
            name = "C_Wrestling_3"
        }
    }
    for i, mission in grappleMissions do
        MissionSuccessCountInc(mission.name)
    end
    EnemyCreate()
end

function EnemyCreate()
    pedTable = {
        {
            x = g_PosX,
            y = g_PosY,
            z = g_PosZ,
            model = 32
        },
        {
            x = g_PosX,
            y = g_PosY,
            z = g_PosZ,
            model = 75
        },
        {
            x = g_PosX,
            y = g_PosY,
            z = g_PosZ,
            model = 66
        }
    }
    local xPos = 0
    local Offset = -2
    for i, ped in pedTable do
        ped.x = ped.x + Offset * (i - 1)
    end
    L_PedLoadXYZ(nil, pedTable)
end

function MissionCleanup()
end

function main()
    L_PedExec(nil, PedSetPedToTypeAttitude, "id", gPlayer, 2)
    L_PedExec(nil, PedAddPedToIgnoreList, "id", gPlayer)
    while mission_completed == false do
        if L_PedAllDead() then
            mission_completed = true
        end
        Wait(0)
    end
    MissionSucceed()
end
