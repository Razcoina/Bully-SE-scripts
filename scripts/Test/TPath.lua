local x, y, z

function main()
    F_CreatePeds()
    while true do
        Wait(0)
    end
end

local function F_HitCheck()
    while true do
        Wait(0)
        if not PedIsDead(Prefect1) and PedIsHit(Prefect1, 2, 0) then
            TextPrintString("HOLYSHIT", 3, 1)
            PedClearObjectives(Prefect1)
            PedFollowPath(Prefect1, PATH._PUNISHTEST_PATH2, 0, 1)
        end
    end
end

function F_CreatePeds()
    Prefect1 = PedCreatePoint(13, POINTLIST._PUNISHTEST_P1)
    Wait(5000)
    PedFollowPath(Prefect1, PATH._PUNISHTEST_PATH2, 0, 1, F_CallBack)
    CreateThread("F_HitCheck")
end

function MissionCleanup()
end

function MissionSetup()
    local x, y, z = -9.988, 21.42, 30.06
    AreaTransitionXYZ(22, x, y, z)
    PlayerFaceHeading(270, 1)
end

function F_CallBack(ped, path, node)
    if node == 2 then
        PedAttack(ped, gPlayer)
    end
end
