ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false

function MissionSetup()
    local x, y, z = 270, -110, 6.4
    PlayerSetHealth(200)
    AreaTransitionXYZ(0, x, y, z)
    local model2 = 25
    local x, y, z = PedGetPosXYZ(gPlayer)
    local ally1 = PedCreateXYZ(model2, x + 1, y + 1, z)
    PedRecruitAlly(gPlayer, ally1, true)
    PedMakeAmbient(ally1)
end

function MissionCleanup()
end

function main()
    while mission_completed == false do
        Wait(0)
    end
    Wait(3000)
    MissionSucceed()
end
