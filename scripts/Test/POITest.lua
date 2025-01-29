function MissionSetup()
end

function MissionCleanup()
end

function cbReachedPoint(ped, route, num)
end

function main()
    DATLoad("PedTest.DAT", 1)
    DATInit()
    if shared.gRunPOITest == true then
        shared.gRunPOITest = false
        TextPrintString("==============>>>> POI's will  be created 100% of the time!", 5, 2)
    else
        shared.gRunPOITest = true
        TextPrintString("==============>>>> POI's be created at regular intervals!", 5, 2)
    end
    MissionSucceed()
end
