function MissionSetup()
    DisablePOI()
    --print(" MISSION SETUP LOADED")
    DATLoad("3_S09.DAT", 2)
    DATInit()
    CameraFade(1000, 0)
    Wait(1000)
    AreaTransitionPoint(0, POINTLIST._3_S09_RAULTEST_PLAYERSTART)
    Wait(1500)
end

function MissionCleanup()
    DATUnload(2)
    EnablePOI()
end

function main()
    CameraFade(1000, 1)
    Wait(1000)
    gDumpster01 = PAnimCreate(TRIGGER._3_S09_DUMPSTER01)
    iGreaser01 = PedCreatePoint(28, POINTLIST._3_S09_INITIALGREASERS, 1)
    PedAttackProp(iGreaser01, TRIGGER._3_S09_DUMPSTER01)
    mission_running = true
    while mission_running do
        Wait(0)
    end
    MissionSucceed()
end
