function MissionSetup()
    DATLoad("mlee_pickups.DAT", 2)

    DATInit()
    PlayerSetControl(1)
    WeatherSet(0)
end

function MissionCleanup()
    DATUnload(2)
end

function main()
    AreaTransitionPoint(31, POINTLIST._PICKUP_TEST_START)
    local pickuptable = {
        {
            ModelName = 329,
            name = "(SOCBALL) Soccer Ball",
            Point = 1
        },
        {
            ModelName = 381,
            name = "(ANIBALL) Basketball",
            Point = 2
        },
        {
            ModelName = 331,
            name = "(WFTBALL) Football",
            Point = 3
        }
    }
    for i, pickup in pickuptable do
        --print(pickup.ModelName)
        pickup.ID = PickupCreatePoint(pickup.ModelName, POINTLIST._PICKUP_LIST, pickup.Point)
        pickup.State = false
    end
    gMissionRunning = true
    while gMissionRunning do
        Wait(0)
        for i, key in pickuptable do
            if PickupIsPickedUp(key.ID) and key.State == false then
                TextPrintString(key.name, 2, 2)
                Wait(200)
                key.State = true
            end
        end
    end
    if gMissionSuccess then
        MissionSucceed(true, false)
    else
        MissionFail()
    end
end
