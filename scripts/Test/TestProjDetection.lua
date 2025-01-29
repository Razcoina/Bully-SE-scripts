ImportScript("Library/LibPlayer.lua")
local follower1, follower1_bike, follower2, follower2_bike, tblPlayer

function F_TableInit()
    tblPlayer = {
        startPosition = POINTLIST._TESTPROJDETECTIONPLAYER
    }
end

function MissionSetup()
    DATLoad("TestProjDetection.DAT", 2)
    DATInit()
    F_TableInit()
    L_PlayerLoad(tblPlayer)
end

function MissionCleanup()
    DATUnload(2)
end

function main()
    local eggImpacts = 0
    while true do
        local currentImpacts = ObjectNumProjectileImpacts(TRIGGER._TESTPROJDETECTIONWALL, 312)
        if eggImpacts < currentImpacts then
            eggImpacts = currentImpacts
            TextPrintString("DETECTED EGG IMPACT!  NUMBER STANDS AT: " .. tostring(eggImpacts), 3)
        end
        Wait(100)
    end
end
