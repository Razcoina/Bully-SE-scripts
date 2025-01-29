function main()
    F_CreatePeds()

    while true do
        Wait(0)
    end
    MissionSucceed()
end

function F_CreatePeds()
    local ped = PedCreatePoint(102, POINTLIST._TESTAVOIDPED01, 1)
    ped = PedCreatePoint(102, POINTLIST._TESTAVOIDPED01, 2)
    ped = PedCreatePoint(102, POINTLIST._TESTAVOIDPED02, 1)
    PedFollowPath(ped, PATH._TESTAVOID401, 2, 0)
    ped = PedCreatePoint(102, POINTLIST._TESTAVOIDPED02, 2)
    PedFollowPath(ped, PATH._TESTAVOID401, 2, 1)
    ped = PedCreatePoint(102, POINTLIST._TESTCOLLIDE, 1)
    PedFollowPath(ped, PATH._TESTAVOID101, 2, 0)
    ped = PedCreatePoint(102, POINTLIST._TESTCOLLIDE, 2)
    PedFollowPath(ped, PATH._TESTAVOID102, 2, 0)
    ped = PedCreatePoint(102, POINTLIST._TESTFOLLOW, 1)
    PedFollowPath(ped, PATH._TESTAVOID201, 2, 0)
    ped = PedCreatePoint(102, POINTLIST._TESTPEDONSPOT, 1)
    PedFollowPath(ped, PATH._TESTAVOID301, 2, 0)
    ped = PedCreatePoint(102, POINTLIST._TESTPEDONSPOT, 2)
    ped = PedCreatePoint(102, POINTLIST._TESTPROPUSE, 1)
    ped = PedCreatePoint(102, POINTLIST._TESTPROPUSE, 2)
    PedUseProp(ped, TRIGGER._NLOCK01A, true)
end

function MissionCleanup()
    DATUnload(2)
end

function MissionSetup()
    DATLoad("TestAvoidance.DAT", 2)
    AreaTransitionPoint(31, POINTLIST._TESTAVOIDPLAYER, 1)
    while shared.gAreaDATFileLoaded[31] == false do
        Wait(0)
    end
end
