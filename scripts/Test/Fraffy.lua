function MissionSetup()
end

function MissionCleanup()
end

function main()
    DATLoad("FraffyMachine.DAT", 0)
    DATInit()
    AreaTransitionPoint(38, POINTLIST._FRAFFY, 1)
    DATUnload(0)
end
