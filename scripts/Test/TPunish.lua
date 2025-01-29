local x, y, z

function main()
    F_CreatePeds()
    PedSetPunishmentPoints(gPlayer, 0)
    while true do
        Wait(0)
    end
end

function F_CreatePeds()
    Prefect1 = PedCreatePoint(50, POINTLIST._PUNISHTEST_P1)
    PedFollowPath(Prefect1, PATH._PUNISHTEST_PATH2, 2)
    Student = PedCreatePoint(24, POINTLIST._PUNISHTEST_P2)
    PedMakeAmbient(Student)
    Wait(5000)
end

function MissionCleanup()
end

function MissionSetup()
    local x, y, z = -9.988, 21.42, 30.06
    AreaTransitionXYZ(22, x, y, z)
    PlayerFaceHeading(270, 1)
end
