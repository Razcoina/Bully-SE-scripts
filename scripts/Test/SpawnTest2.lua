function MissionSetup()
    AreaTransitionPoint(22, POINTLIST._SPAWNTEST_SPAWNSTART)
    ClockSet(8, 59)
    Docker1 = AreaAddDocker(2, 1, 2000, 0)
    AreaAddDockPeriod(Docker1, 11, 0, 15)
    AreaAddDockPeriod(Docker1, 15, 0, 15)
    DockP1 = AreaAddDockLocation(Docker1, POINTLIST._SPAWNTEST_SPAWNP1, TRIGGER._SPAWNTEST_DOOR1)
    DockP2 = AreaAddSpawnLocation(Docker1, POINTLIST._SPAWNTEST_SPAWNP2, TRIGGER._SPAWNTEST_DOOR2)
end

function main()
    MissionSetup()
    while true do
        Wait(0)
    end
end
