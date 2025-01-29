local climber

function MissionSetup()
    DATLoad("TestClimbLadder.DAT", 2)
    DATInit()
    AreaTransitionPoint(0, POINTLIST._PLAYERSTART, 1)
    CameraReturnToPlayer()
    CameraReset()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    VehicleOverrideAmbient(0, 0, 0, 0)
end

function MissionCleanup()
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
    DATUnload(2)
end

function F_CreateDude()
    if climber == nill then
        climber = PedCreatePoint(24, POINTLIST._PEDLOCATION, 1)
    end
end

function F_SetupEvent()
    if climber ~= nil then
        PedClearObjectives(climber)
        PedClearAllWeapons(climber)
        PedClimbLadder(climber, POINTLIST._PEDLOCATION, 2)
    end
end

function main()
    while true do
        if IsButtonPressed(8, 0) then
            F_CreateDude()
        end
        if IsButtonPressed(7, 0) then
            F_SetupEvent()
            Wait(1000)
        end
        Wait(0)
    end
    MissionSucceed()
end
