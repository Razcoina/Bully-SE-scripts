ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPed.lua")
ImportScript("Library/LibPlayer.lua")
local tblPlayer, tblPed

function F_TableInit()
    tblPlayer = {
        startPosition = POINTLIST._TESTMESHPLAYER
    }
    tblPed = {
        model = 33,
        point = POINTLIST._TESTMESHPED1,
        path = PATH._TESTMESHPED1
    }
end

function MissionSetup()
    DATLoad("TestWalkableMesh.DAT", 2)
    DATInit()
    F_TableInit()
    L_PlayerLoad(tblPlayer)
    tblPed.id = PedCreatePoint(tblPed.model, tblPed.point)
    PedSetStealthBehavior(tblPed.id, 1)
    PedFollowPath(tblPed.id, tblPed.path, 2, 0)
end

function MissionCleanup()
    DATUnload(2)
end

function main()
    while true do
        Wait(0)
    end
end
