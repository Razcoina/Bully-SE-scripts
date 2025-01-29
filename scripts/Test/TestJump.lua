ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false

function MissionSetup()
    DATLoad("TFIGHT01.DAT", 2)
    DATInit()
    PlayerSetHealth(200)
    AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
    local ped = PedCreatePoint(15, POINTLIST._TFIGHT01_E_01)
    PedJump(ped, POINTLIST._TFIGHT01_W_01)
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
