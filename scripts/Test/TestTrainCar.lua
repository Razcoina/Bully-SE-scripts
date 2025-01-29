ImportScript("Library/LibPlayer.lua")
local tblPlayer, tblPersistentEntity, tblTrain

function MissionSetup()
    DATLoad("3_G3.DAT", 2)
    DATInit()
    --print("mission name is " .. tostring(MissionGetCurrentName()))
    tblPlayer = {
        startPosition = POINTLIST._3_G3_TESTTRAINPLAYER,
        startOnBike = true,
        bike = {
            model = 273,
            location = POINTLIST._3_G3_TESTTRAINBIKE
        }
    }
    tblPersistentEntity = {
        {
            id = "TrainCarA",
            x = 237.265,
            y = -325.231,
            z = 8.04209,
            heading = 99,
            visibleArea = 0,
            path = PATH._3_G3_CAR4,
            speed = 3
        }
    }
    tblTrain = tblPersistentEntity[1]
    for i, entity in tblPersistentEntity do
        entity.poolIndex, entity.type = CreatePersistentEntity(entity.id, entity.x, entity.y, entity.z, entity.heading, entity.visibleArea)
    end
    L_PlayerLoad(tblPlayer)
end

function MissionCleanup()
    DATUnload(2)
    for i, entity in tblPersistentEntity do
        DeletePersistentEntity(entity.poolIndex, entity.type)
    end
end

function F_Nil()
end

function main()
    TextPrintString("Press up on the d-pad to get the train to move", 3, 1)
    while not IsButtonPressed(2, 0) do
        Wait(0)
    end
    PAnimFollowPath(tblTrain.poolIndex, tblTrain.type, tblTrain.path, false, F_Nil)
    --print("passed PAnimFollowPath")
    PAnimSetPathFollowSpeed(tblTrain.poolIndex, tblTrain.type, tblTrain.speed)
    --print("passed PAnimSetPathFollowSpeed")
end
