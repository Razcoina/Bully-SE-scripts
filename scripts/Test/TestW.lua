local FireID = -1

function MissionSetup()
    PlayerSetWeapon(326, 0)
end

function MissionCleanup()
    FireDestroy(FireID)
end

function main()
    while 1 do
        FireID = FireCreate(TRIGGER._SMALLCRATE2, 1000, 1, 1, 100)
        PAnimMakeTargetable(TRIGGER._SMALLCRATE2, false)
        FireSetScale(FireID, 1)
        FireSetDamageRadius(FireID, 1)
        StartTime = GetTimer()
        while GetTimer() - StartTime < 300000 do
            Health = FireGetHealth(FireID)
            DisplayString = string.format("                                HEALTH %d", tostring(Health))
            TextPrintString(DisplayString, 0.3)
            Wait(0)
        end
        FireDestroy(FireID)
        FireID = -1
    end
    Wait(10000000)
end
