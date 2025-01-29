function MissionSetup()
end

function MissionCleanup()
end

function main()
    DATLoad("BuildTest.DAT", 2)
    DATInit()
    math.randomseed(GetTimer())
    PedSetPunishmentPoints(gPlayer, 0)
    AreaTransitionPoint(14, POINTLIST._TB_PLAYERSTART)
    PlayerSetControl(0)
    PedSetInfiniteSprint(gPlayer, true)
    Wait(1000)
    gMissionSuccess = false
    PedFollowPath(gPlayer, PATH._TB_PLAYERPATH01, 0, 2, CbPath01)
    while not gMissionSuccess do
        Wait(0)
    end
    AreaTransitionPoint(0, POINTLIST._TB_SCHOOLGROUNDS)
    gMissionSuccess = false
    PedFollowPath(gPlayer, PATH._TB_PLAYERPATH02, 0, 2, CbPath02)
    while not gMissionSuccess do
        Wait(0)
    end
    AreaTransitionPoint(2, POINTLIST._TB_SCHOOLHALLWAYS)
    Wait(3000)
    PedSetInfiniteSprint(gPlayer, false)
    PlayerSetControl(1)
    DATUnload(2)
    Quit()
end

function CbPath01(pedId, pathId, pathNode)
    if pathNode == 18 then
        gMissionSuccess = true
    end
end

function CbPath02(pedId, pathId, pathNode)
    if pathNode == 14 then
        gMissionSuccess = true
    end
end
