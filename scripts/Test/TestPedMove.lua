ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")

function main()
    while not IsButtonPressed(9, 0) do
        Wait(0)
        L_PedExec(janitor, F_JanitorEvent, "element")
    end
end

function MissionSetup()
    local setX, setY, setZ = -16.01, 22.97, 26.06
    AreaTransitionXYZ(22, setX, setY, setZ)
    DATLoad("MOVETEST.DAT", 2)
    DATInit()
    L_PedLoadPoint(nil, {
        {
            model = 56,
            point = POINTLIST._MOVET_FROM,
            pointA = POINTLIST._MOVET_FROM,
            pointB = POINTLIST._MOVET_TO,
            nextPoint = POINTLIST._MOVET_TO,
            walkTime = 0
        }
    })
end

function MissionCleanup()
    MissionTimerStop()
    DATUnload(2)
    DATInit()
end

function F_JanitorEvent(janitor)
    if GetTimer() - janitor.walkTime > 10000 then
        MissionTimerStart(10)
        local x, y, z = GetPointList(janitor.nextPoint)
        PedClearObjectives(janitor.id)
        PedMoveToXYZ(janitor.id, 0, x, y)
        janitor.walkTime = GetTimer()
        if janitor.nextPoint == janitor.pointA then
            janitor.nextPoint = janitor.pointB
        else
            janitor.nextPoint = janitor.pointA
        end
    end
end
