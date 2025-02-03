local MISSION_RUNNING = -1
local MISSION_PASSED = 0
local MISSION_FAILED = 1
local gMissionState = MISSION_RUNNING
local attempts = GetMissionCurrentAttemptCount()
local PUNISHMENT_TIER1 = 1
local PUNISHMENT_TIER2 = 2
local PUNISHMENT_TIER3 = 3
local JOB_TIER1 = 4
local JOB_TIER2 = 5
local MISSION_PUNISHMENT = 0
local MISSION_JOB = 1
local gMissionType, gCurrentTier, gCurrentDifficulty
local DIFFICULTY_EASY = 1
local DIFFICULTY_MEDIUM = 2
local DIFFICULTY_HARD = 3
local gDestroyables = {}
local gPlants = {}
local gPlantsDestroyed = 0
local MAX_PROP_DAMAGED_ALLOWED = 2
local MAX_PLANT_DAMAGED_ALLOWED = 3
local PLANT = 0
local PROP = 1
local gPropsDamagedCount = 0
local PROP_DAMAGE_COST = 0
local gMoneyLost = 0
local bPropsDestroyed = false
local GAMEAREA_RETURN_DELAY = 8500
local MOWER_REENTRY_DELAY = 8500
local MOWER_COUNTDOWN_MAX = 8
local GAMEAREA_RETURN_MAX = 8
local gMowerExitTimer
local onMower = true
local inLot = true
local startPoint, lmPoint, gMinPoint, gMaxPoint, mower, gMissionTime, gAccuracy
local bSuccessMessage = false
local gExitTimer
local bSuccess = false
local gBonusMoney
local bPlayerBusted = false
local gBasePunishment = 200

function F_SetupPunishmentTier(tier)
    if tier <= 10 then
        gCurrentTier, gCurrentDifficulty = PUNISHMENT_TIER1, DIFFICULTY_EASY
    else
        gCurrentTier, gCurrentDifficulty = DecodeTierCode(tier)
    end
    --print(">>>[RUI]", "F_SetupPunishmentTier: " .. tier)
end

function DecodeTierCode(tierCode)
    local difficulty = math.mod(tierCode, 10)
    local tier = (tierCode - difficulty) / 10
    return tier, difficulty
end

function F_StorePlayersBikeIfInTrigger(trigger, point)
    local x, y, z = GetAnchorPosition(trigger)
    bikes = VehicleFindInAreaXYZ(x, y, z, 70, false)
    pBike = PlayerGetLastBikeId()
    if bikes ~= nil then
        for i, bike in bikes do
            if VehicleIsInTrigger(bike, trigger) then
                if bike == pBike then
                    VehicleSetPosPoint(bike, point)
                else
                    VehicleDelete(bike)
                end
            end
        end
    end
end

function UpdateObjectiveLog(newObjStr, oldObj, percent, minutes)
    local newObj
    if newObjStr then
        if percent then
            newObj = MissionObjectiveAdd(newObjStr, 2, -1)
            MissionObjectiveUpdateParam(newObj, 1, percent)
            TextAddParamNum(percent)
            TextAddParamNum(minutes)
            TextPrintF(newObjStr, 5, 1)
        else
            newObj = MissionObjectiveAdd(newObjStr, 0, -1)
            TextPrint(newObjStr, 5, 1)
        end
    end
    if oldObj then
        MissionObjectiveComplete(oldObj)
    end
    return newObj
end

function PlayerBusted()
    if gMissionType == MISSION_JOB then
        return false
    end
    if PlayerGetPunishmentPoints() >= gBasePunishment then
        --print(">>>[RUI]", "!!PlayerBusted " .. tostring(gBasePunishment) .. " " .. tostring(PlayerGetPunishmentPoints()))
        return true
    else
        return false
    end
end

function cbGuardHit(victim, attacker)
    --print(">>>[RUI]", "!!cbGuardHit")
    if victim == gPrefect and attacker == gPlayer then
        gMissionState = MISSION_FAILED
        if gMissionType == MISSION_JOB then
            gFailMessage = "P_LAWN_16"
        else
            gFailMessage = "P_LAWN_13"
        end
        bGuardHit = true
    end
end

function TimerPassed(time)
    return time < GetTimer()
end

function PlayerLeftGameAreaTimedOut()
    if gMissionType == MISSION_JOB then
        if not PlayerIsInTrigger(gameArea) then
            if gExitTimer then
                if PedIsInVehicle(gPlayer, mower) then
                    TextAddParamNum(gAreaCountDown)
                    TextPrint("PUN_04", 0.5, 1)
                end
                if TimerPassed(gAreaCountDownTimer) then
                    gAreaCountDown = gAreaCountDown - 1
                    if gAreaCountDown < 0 then
                        gAreaCountDown = 0
                    end
                    gAreaCountDownTimer = GetTimer() + 1000
                end
                if TimerPassed(gExitTimer) then
                    inLot = false
                end
            else
                gExitTimer = GetTimer() + GAMEAREA_RETURN_DELAY
                gAreaCountDownTimer = GetTimer() + 1000
                gAreaCountDown = GAMEAREA_RETURN_MAX
            end
        else
            inLot = true
            gExitTimer = nil
        end
        return not inLot
    elseif not PlayerIsInTrigger(gameArea) then
        PlayerSetControl(0)
        MinigameEnableHUD(false)
        CameraFade(500, 0)
        Wait(501)
        VehicleStop(mower)
        CameraSetWidescreen(true)
        PedFaceObjectNow(gPrefect, gPlayer, 3)
        Wait(1000)
        SoundSetAudioFocusCamera()
        F_PedSetCameraOffsetXYZ(gPrefect, 0.3, 1.4, 1.3, 0, 0, 1.5)
        CameraFade(500, 1)
        Wait(501)
        SoundPlayScriptedSpeechEvent(gPrefect, "WAIT_FOR_ME", 0, "large")
        Wait(1000)
        while SoundSpeechPlaying(gPrefect) do
            Wait(0)
        end
        CameraFade(500, 0)
        Wait(501)
        CameraSetWidescreen(false)
        CameraReturnToPlayer(true)
        if PedIsInVehicle(gPlayer, mower) then
            PlayerDetachFromVehicle(gPlayer)
            while PedIsInVehicle(gPlayer, mower) do
                Wait(0)
            end
        end
        VehicleDelete(mower)
        mower = VehicleCreatePoint(284, lmPoint)
        PedSetWeaponNow(gPlayer, -1, 0)
        PedWarpIntoCar(gPlayer, mower)
        CameraReturnToPlayer(true)
        PedFaceObject(gPrefect, gPlayer, 3, 1, false)
        gMowerCountDown = MOWER_COUNTDOWN_MAX
        gMowerCountDownTime = nil
        gMowerExitTimer = nil
        onMower = true
        SoundSetAudioFocusPlayer()
        MinigameEnableHUD(true)
        CameraFade(500, 1)
        Wait(501)
        PlayerSetControl(1)
    end
end

function PlayerLeftMowerTimedOut()
    if not PedIsInVehicle(gPlayer, mower) then
        if gMowerExitTimer then
            TextAddParamNum(gMowerCountDown)
            TextPrintF("P_LAWN_07", 0.5, 1)
            if TimerPassed(gMowerCountDownTime) then
                gMowerCountDown = gMowerCountDown - 1
                if gMowerCountDown < 0 then
                    gMowerCountDown = 0
                end
                gMowerCountDownTime = GetTimer() + 1000
            end
            if TimerPassed(gMowerExitTimer) then
                onMower = false
            end
        else
            if PlayerIsInTrigger(gameArea) then
                gMowerExitTimer = GetTimer() + MOWER_REENTRY_DELAY
                gMowerCountDown = MOWER_COUNTDOWN_MAX
            else
                if gExitTimer then
                    delay = gExitTimer
                    count = gAreaCountDown
                end
                gMowerExitTimer = GetTimer() + delay
                gMowerCountDown = count
            end
            gMowerCountDownTime = GetTimer() + 1000
        end
    else
        gMowerCountDown = MOWER_COUNTDOWN_MAX
        gMowerCountDownTime = nil
        gMowerExitTimer = nil
        onMower = true
    end
    return not onMower
end

function JobTier2_CreatePlants()
    gDestroyables = {
        {
            hash = ObjectNameToHashID("trich_DPE_BirdBath05")
        },
        {
            hash = ObjectNameToHashID("trich_DPE_BirdBath08")
        },
        {
            hash = ObjectNameToHashID("trich_DPE_BirdBath06")
        },
        {
            hash = ObjectNameToHashID("trich_DPE_BirdBath07")
        }
    }
    local index, simpleObject
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 561.091, 487.589, 18.8332, 171.4, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersB", 560.571, 485.606, 18.7352, 175.239, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 560.078, 482.709, 18.5517, -179.722, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 559.626, 479.648, 18.4131, -179.722, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersB", 559.716, 477.266, 18.3398, 179.986, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 559.942, 474.807, 18.3199, -179.971, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 582.737, 483.105, 18.868, -179.996, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersB", 582.511, 485.564, 18.9891, 179.988, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 582.422, 487.947, 19.0275, -179.72, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_HatSVase", 561.923, 467.216, 18.4417, -0.00270598, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PROP
    })
    index, simpleObject = CreatePersistentEntity("DPE_HatSVase", 561.412, 472.861, 18.4118, -0.00270598, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PROP
    })
    index, simpleObject = CreatePersistentEntity("DPE_HatSVase", 566.29, 467.524, 18.574, -0.00270598, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PROP
    })
    index, simpleObject = CreatePersistentEntity("DPE_HatSVase", 568.242, 473.247, 18.6681, -0.00270598, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PROP
    })
    index, simpleObject = CreatePersistentEntity("DPE_HatSVase", 574.039, 473.685, 18.7429, -0.00270598, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PROP
    })
    index, simpleObject = CreatePersistentEntity("DPE_HatSVase", 579.798, 467.658, 18.6253, -0.00270598, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PROP
    })
    index, simpleObject = CreatePersistentEntity("DPE_HatSVase", 580.106, 474.117, 18.6995, -0.00270598, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PROP
    })
    --print(">>>[RUI]", "++JobTier2_CreatePlants")
end

function JobTier1_CreatePlants()
    local index, simpleObject
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 485.146, 308.294, 20.3203, -67.6008, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 487.408, 308.882, 20.3203, -83.3395, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 490.002, 309.004, 20.293, -82.8627, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 492.683, 308.799, 20.2311, -97.4194, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 495.141, 307.937, 20.1985, -96.9899, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 497.536, 306.67, 20.2044, -126.119, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 499.581, 305.309, 20.2381, -125.981, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 501.392, 303.32, 20.191, -140.793, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 502.568, 301.027, 20.2052, -149.43, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 503.34, 298.956, 20.2003, -146.56, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 504.179, 296.862, 20.1857, -161.381, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 504.755, 294.187, 20.1541, -165.637, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 504.982, 291.85, 20.3054, -164.229, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 504.969, 288.986, 20.2349, -178.76, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 504.659, 286.557, 20.2026, -177.356, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 504.44, 284.319, 20.1089, 177.484, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 503.527, 281.605, 20.1003, 162.873, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 502.467, 279.397, 20.0778, 164.261, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 494.091, 291.93, 20.7425, 3.53308, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 495.386, 296.305, 20.7425, 8.30528, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 493.951, 297.271, 20.7765, 87.2991, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 490.093, 296.687, 20.8798, -62.0728, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 488.294, 295.74, 20.923, 87.4664, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 485.889, 295.716, 20.6437, -94.4164, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 494.023, 280.297, 20.4237, 19.3388, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 495.618, 277.327, 20.0646, 32.3669, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    index, simpleObject = CreatePersistentEntity("DPE_FlowersA", 496.977, 274.852, 20.0646, 8.28537, 0)
    table.insert(gPlants, {
        id = index,
        object = simpleObject,
        propType = PLANT
    })
    --print(">>>[RUI]", "++JobTier1_CreatePlants")
end

function PlayerDamagedPlants()
    for _, plant in gPlants do
        if not plant.bDestroyed and ObjectIsDestroyed(plant.id) then
            --print(">>>[RUI]", "PlayerDamagedPlants: " .. tostring(gPlantsDestroyed))
            plant.bDestroyed = true
            if plant.propType == PLANT then
                --print(">>>[RUI]", "PlayerDamagedPlants PLANT")
                gPlantsDestroyed = gPlantsDestroyed + 1
                PlayerAddMoney(-PROP_DAMAGE_COST)
                gMoneyLost = gMoneyLost + PROP_DAMAGE_COST
            end
        end
    end
    return false
end

function RemoveLawnPlants()
    if not gPlants then
        return
    end
    for _, plant in gPlants do
        if plant then
            DeletePersistentEntity(plant.id, plant.object)
        end
    end
end

function RegisterPropHashHandlers()
    if gDestroyables then
        for i, entry in gDestroyables do
            RegisterHashEventHandler(entry.hash, 3, cbLawnPropBroken)
        end
    end
end

function DeregisterPropHashHandlers()
    if gDestroyables then
        for i, entry in gDestroyables do
            RegisterHashEventHandler(entry.hash, 3, nil)
        end
    end
end

function cbLawnPropBroken(HashID, ModelPoolIndex)
    --print(">>>[RUI]", "!!cbLawnPropBroken")
    local pedDestroyer = PAnimDestroyedByPed(ModelPoolIndex, 0)
    if pedDestroyer == gPlayer then
        --print(">>>[RUI]", "!!cbLawnPropBroken  BY PLAYER")
        PlayerAddMoney(-PROP_DAMAGE_COST)
        gMoneyLost = gMoneyLost + PROP_DAMAGE_COST
    end
end

function PunishmentTier1_Setup(difficulty)
    gMissionType = MISSION_PUNISHMENT
    if difficulty == DIFFICULTY_EASY then
        gAccuracy = 70
    elseif difficulty == DIFFICULTY_MEDIUM then
        gAccuracy = 80
    elseif difficulty == DIFFICULTY_HARD then
        gAccuracy = 90
    else
        gAccuracy = 70
    end
    gMissionTime = 180
    gAwardMoney = nil
    gBonusMoney = nil
    startPoint = POINTLIST._LM1_PSTART
    lmPoint = POINTLIST._LM1_LMSTART
    gMinPoint = POINTLIST._LM1_MINAREA
    gMaxPoint = POINTLIST._LM1_MAXAREA
    startPoint = POINTLIST._LM1_PSTART
    bikeStoragePoint = POINTLIST._LM1_BIKE
    prefectStart = POINTLIST._LM1_PREFECTSTART
    prefectI = 2
    guardModel = 50
    gameArea = TRIGGER._LM1_GAMEAREA
    endPointCS = POINTLIST._LM1_ENDPOS
    gMowerPoint = POINTLIST._LM1_MOVETO
    PrefectPointCS = POINTLIST._LM1_PSTART
    camPath = PATH._LM1_CAM
    gPrefectLine = 3
    gJimmyLine = 4
    gTutorialMessage = "TUT_LMP_01"
    PedSetTypeToTypeAttitude(5, 13, 3)
    --print(">>>[RUI]", "SetupDifficulty  tier 1")
end

function PunishmentTier2_Setup(difficulty)
    gMissionType = MISSION_PUNISHMENT
    if difficulty == DIFFICULTY_EASY then
        gAccuracy = 70
    elseif difficulty == DIFFICULTY_MEDIUM then
        gAccuracy = 80
    elseif difficulty == DIFFICULTY_HARD then
        gAccuracy = 90
    else
        gAccuracy = 70
    end
    gMissionTime = 180
    gAwardMoney = nil
    gBonusMoney = nil
    startPoint = POINTLIST._LM5_PSTART
    lmPoint = POINTLIST._LM5_LMSTART
    gMinPoint = POINTLIST._LM5_MINAREA
    gMaxPoint = POINTLIST._LM5_MAXAREA
    startPoint = POINTLIST._LM5_PSTART
    bikeStoragePoint = POINTLIST._LM5_BIKE
    prefectStart = POINTLIST._LM5_PREFECTSTART
    prefectI = 2
    guardModel = 50
    gameArea = TRIGGER._LM5_GAMEAREA
    endPointCS = POINTLIST._LM5_ENDPOS
    gMowerPoint = POINTLIST._LM5_MOVETO
    PrefectPointCS = POINTLIST._LM5_PSTART
    gPrefectLine = 1
    gJimmyLine = 2
    PedSetTypeToTypeAttitude(5, 13, 3)
    --print(">>>[RUI]", "SetupDifficulty  tier 2")
end

function PunishmentTier3_Setup(difficulty)
    shared.bFootBallFieldEnabled = false
    gMissionType = MISSION_PUNISHMENT
    if difficulty == DIFFICULTY_EASY then
        gAccuracy = 60
    elseif difficulty == DIFFICULTY_MEDIUM then
        gAccuracy = 70
    elseif difficulty == DIFFICULTY_HARD then
        gAccuracy = 80
    else
        gAccuracy = 60
    end
    gMissionTime = 390
    gAwardMoney = nil
    gBonusMoney = nil
    startPoint = POINTLIST._LM4_PSTART
    bikeStoragePoint = POINTLIST._LM4_BIKE
    lmPoint = POINTLIST._LM4_LMSTART
    gMinPoint = POINTLIST._LM4_MINAREA
    gMaxPoint = POINTLIST._LM4_MAXAREA
    prefectStart = POINTLIST._LM4_PREFECTSTART
    prefectI = 2
    guardModel = 50
    gameArea = TRIGGER._LM4_GAMEAREA
    PrefectPointCS = POINTLIST._LM4_PSTART
    endPointCS = POINTLIST._LM4_ENDPOINTCS
    gMowerPoint = POINTLIST._LM4_MOVETO
    gExitPath = PATH._LM4_EXITPATH
    gPrefectLine = 5
    gJimmyLine = 6
    PedSetTypeToTypeAttitude(5, 13, 3)
    --print(">>>[RUI]", "SetupDifficulty  Punishment tier 3")
end

function JobTier1_Setup(difficulty)
    gMissionType = MISSION_JOB
    DisablePOI(true, true)
    if difficulty == DIFFICULTY_EASY then
        gAccuracy = 70
        PROP_DAMAGE_COST = 500
    elseif difficulty == DIFFICULTY_MEDIUM then
        gAccuracy = 80
        PROP_DAMAGE_COST = 550
    elseif difficulty == DIFFICULTY_HARD then
        gAccuracy = 90
        PROP_DAMAGE_COST = 600
    else
        gAccuracy = 70
        PROP_DAMAGE_COST = 500
    end
    gMissionTime = 180
    gAwardMoney = 1500
    gBonusMoney = 1000
    startPoint = POINTLIST._LM3_PSTART
    bikeStoragePoint = POINTLIST._LM3_BIKE
    lmPoint = POINTLIST._LM3_LMSTART
    gMinPoint = POINTLIST._LM3_MINAREA
    gMaxPoint = POINTLIST._LM3_MAXAREA
    prefectStart = POINTLIST._LM3_PREFECTSTART
    prefectI = 1
    guardModel = 114
    PrefectPointCS = POINTLIST._LM3_PSTART
    endPointCS = POINTLIST._LM3_ENDPOS
    gMowerPoint = POINTLIST._LM3_MOVETO
    gameArea = TRIGGER._LM3_GAMEAREA
    camPath = PATH._LM3_CAM
    gTutorialMessage = "TUT_LMP_01"
    gTutorialMessage2 = "TUT_JOBL01"
    JobTier1_CreatePlants()
    --print(">>>[RUI]", "SetupDifficulty  Job tier 1")
end

function JobTier2_Setup(difficulty)
    gMissionType = MISSION_JOB
    DisablePOI(true, true)
    if difficulty == DIFFICULTY_EASY then
        gAccuracy = 70
        PROP_DAMAGE_COST = 500
    elseif difficulty == DIFFICULTY_MEDIUM then
        gAccuracy = 80
        PROP_DAMAGE_COST = 550
    elseif difficulty == DIFFICULTY_HARD then
        gAccuracy = 90
        PROP_DAMAGE_COST = 600
    else
        gAccuracy = 70
        PROP_DAMAGE_COST = 500
    end
    gMissionTime = 180
    gAwardMoney = 2000
    gBonusMoney = 2000
    startPoint = POINTLIST._LM2_PSTART
    bikeStoragePoint = POINTLIST._LM2_BIKE
    lmPoint = POINTLIST._LM2_LMSTART
    gMinPoint = POINTLIST._LM2_MINAREA
    gMaxPoint = POINTLIST._LM2_MAXAREA
    prefectStart = POINTLIST._LM2_PREFECTSTART
    prefectI = 1
    guardModel = 114
    PrefectPointCS = POINTLIST._LM2_PSTART
    endPointCS = POINTLIST._LM2_ENDPOS
    gMowerPoint = POINTLIST._LM2_MOVETO
    gameArea = TRIGGER._LM2_GAMEAREA
    camPath = PATH._LM2_CAM
    JobTier2_CreatePlants()
    gTutorialMessage = "TUT_JOBL02"
    --print(">>>[RUI]", "SetupDifficulty  Job tier 2")
end

function SetupDifficulty(tier)
    if tier == PUNISHMENT_TIER1 then
        PunishmentTier1_Setup(gCurrentDifficulty)
    elseif tier == PUNISHMENT_TIER2 then
        PunishmentTier2_Setup(gCurrentDifficulty)
    elseif tier == PUNISHMENT_TIER3 then
        PunishmentTier3_Setup(gCurrentDifficulty)
    elseif tier == JOB_TIER1 then
        JobTier1_Setup(gCurrentDifficulty)
    elseif tier == JOB_TIER2 then
        JobTier2_Setup(gCurrentDifficulty)
    end
    if gMissionType == MISSION_JOB then
        gCompleteStr = "P_LAWN_05"
    else
        gCompleteStr = "P_LAWN_00"
    end
    RegisterPropHashHandlers()
    bDoTutorials = gCurrentDifficulty == DIFFICULTY_EASY and attempts <= 2
end

function CameraSetForTier(tier)
    if tier == PUNISHMENT_TIER1 then
        CameraSetFOV(80)
        CameraSetXYZ(114.337456, -122.97675, 12.307152, 115.11542, -123.36214, 11.811224)
    elseif tier == PUNISHMENT_TIER2 then
        CameraSetFOV(80)
        CameraSetXYZ(198.85011, -34.776733, 10.538029, 198.20328, -34.15361, 10.09888)
    elseif tier == PUNISHMENT_TIER3 then
        CameraSetFOV(80)
        CameraSetXYZ(-1.137063, -77.27278, 5.913183, -1.937864, -76.72564, 5.669632)
    elseif tier == JOB_TIER1 then
        CameraSetFOV(80)
        CameraSetXYZ(475.806, 309.8449, 23.792383, 476.62854, 309.35764, 23.499746)
    elseif tier == JOB_TIER2 then
        CameraSetFOV(80)
        CameraSetXYZ(558.3849, 468.91272, 21.828033, 559.0781, 469.56958, 21.532858)
    end
end

function Vehicle_CameraForTier(tier)
    if tier == PUNISHMENT_TIER1 then
        CameraSetXYZ(121.32155, -126.91157, 10.738907, 122.236, -126.9786, 10.339844)
    elseif tier == PUNISHMENT_TIER2 then
        CameraSetXYZ(196.70465, -36.070084, 8.80645, 196.97766, -35.125908, 8.622165)
    elseif tier == PUNISHMENT_TIER3 then
        CameraSetXYZ(-7.649837, -76.80565, 3.61713, -7.890822, -75.8444, 3.485427)
    elseif tier == JOB_TIER1 then
        CameraSetXYZ(481.197, 313.973, 23.942, 482.883, 309.266, 21.942)
    elseif tier == JOB_TIER2 then
        CameraSetXYZ(566.294, 468.706, 22.3773, 566.27, 473.702, 20.3773)
    end
end

function F_AttackedAtendeeCamera()
    --print("tier IS WHAT?", gCurrentTier, JOB_TIER1)
    if gCurrentTier == PUNISHMENT_TIER1 then
        CameraSetXYZ(124.542755, -128.21509, 9.618655, 123.738754, -127.76074, 9.235094)
    elseif gCurrentTier == PUNISHMENT_TIER2 then
        CameraSetXYZ(185.33562, -37.604313, 8.824678, 185.6637, -36.713486, 8.510473)
    elseif gCurrentTier == PUNISHMENT_TIER3 then
        CameraSetXYZ(-1.030677, -70.94023, 4.475965, -1.887038, -71.23644, 4.053127)
    elseif gCurrentTier == JOB_TIER1 then
        CameraSetXYZ(484.4746, 306.08594, 21.861517, 483.70734, 306.72186, 21.778996)
    elseif gCurrentTier == JOB_TIER2 then
        CameraSetXYZ(565.5701, 465.58386, 20.345194, 565.1159, 466.4571, 20.169064)
    end
end

function NIS_Intro()
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    --print(">>>[RUI]", "!!NIS_Intro:  gPrefect" .. tostring(gPrefect))
    PedFaceObject(gPrefect, gPlayer, 3, 1, false)
    AreaClearAllPeds()
    CameraSetForTier(gCurrentTier)
    LawnMowerSetLawn(gMinPoint, gMaxPoint, gAccuracy)
    CameraSetWidescreen(true)
    Wait(500)
    CameraFade(500, 1)
    Wait(500)
    AreaDisableCameraControlForTransition(false)
    if gPrefectLine then
        --print(">>>[RUI]", "Play Prefect Speech")
        SoundPlayScriptedSpeechEvent(gPrefect, "LAWNMOWER", gPrefectLine, "large", true)
        Wait(1000)
        while SoundSpeechPlaying(gPrefect) do
            Wait(0)
        end
    end
    PedMoveToPoint(gPlayer, 0, gMowerPoint, 1)
    if gJimmyLine then
        --print(">>>[RUI]", "Play Jimmy Speech")
        SoundPlayScriptedSpeechEvent(gPlayer, "LAWNMOWER", gJimmyLine, "large", true)
    end
    Wait(2000)
    PedFaceObject(gPlayer, mower, 1, 1)
    if SoundSpeechPlaying(gPlayer) then
        while SoundSpeechPlaying(gPlayer) do
            Wait(0)
        end
    end
    CameraFade(500, 0)
    Wait(501)
    F_MakePlayerSafeForNIS(false)
    PedClearObjectives(gPlayer)
    PedWarpIntoCar(gPlayer, mower)
    PedSetPosPoint(gPrefect, prefectStart, prefectI)
    PedFaceObject(gPrefect, gPlayer, 3, 1, false)
    Wait(1)
    FollowCamSetVehicleShot("LawnMover")
    CameraReturnToPlayer()
    CameraSetWidescreen(false)
    Wait(1000)
    LawnMowerMinigameStart()
    CameraFade(500, 1)
    Wait(501)
    PlayerSetControl(1)
    gObjective = UpdateObjectiveLog("P_LAWN_OBJ", nil, gAccuracy, gMissionTime / 60)
end

function SetCameraForOutro(tier)
    if gCurrentTier == PUNISHMENT_TIER1 then
        CameraSetXYZ(124.67825, -124.934784, 9.618258, 123.72747, -125.08598, 9.347862)
    elseif gCurrentTier == PUNISHMENT_TIER2 then
        CameraSetXYZ(192.3034, -28.031298, 6.735517, 191.66278, -28.770185, 6.943917)
    elseif gCurrentTier == PUNISHMENT_TIER3 then
        CameraSetXYZ(-9.571856, -73.33005, 2.453491, -8.75781, -73.91009, 2.481419)
    end
end

function NIS_OutroSuccess()
    --print(">>>[RUI]", "++NIS_OutroSuccess")
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    TextPrintString("", 1, 1)
    SoundPlayScriptedSpeechEvent(gPrefect, "SNOW_SHOVELLING", 2, "large", true)
    Wait(2000)
    MinigameSetCompletion("M_PASS", true, 0, "MDETENTION_CLEARED")
    if gCurrentTier == PUNISHMENT_TIER3 and GetMissionSuccessCount("LawnMowing3c") == 0 and 0 < GetMissionSuccessCount("LawnMowing3b") then
        Wait(500)
        ClothingGivePlayerOutfit("Prison")
        MinigameAddCompletionMsg("P_LAWN_UNLOCK", 1)
    end
    SoundPlayMissionEndMusic(true, 4)
    while SoundSpeechPlaying(gPrefect) do
        Wait(10)
    end
    Wait(1000)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(FADE_OUT_TIME, 0)
    Wait(FADE_OUT_TIME + 1)
    if PedIsOnVehicle(gPlayer) then
        PlayerDismountBike()
        while PedIsOnVehicle(gPlayer) do
            Wait(0)
        end
    end
    VehicleDelete(mower)
    mower = nil
    PlayerSetPosPoint(endPointCS, 1)
    --print(">>>[RUI]", "--NIS_OutroSuccess")
end

function NIS_JobOutroSuccess()
    TextPrintString("", 1, 1)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    local rewardMoney = 0
    if LawnMowingGetPercent() >= 99 then
        rewardMoney = gAwardMoney + gBonusMoney
    else
        rewardMoney = gAwardMoney
    end
    StatAddToInt(175, rewardMoney)
    MinigameSetCompletion("M_PASS", true, rewardMoney)
    SoundPlayMissionEndMusic(true, 4)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(FADE_OUT_TIME, 0)
    Wait(FADE_OUT_TIME + 1)
    if PedIsOnVehicle(gPlayer) then
        PlayerDismountBike()
        while PedIsOnVehicle(gPlayer) do
            Wait(0)
        end
    end
    VehicleDelete(mower)
    mower = nil
    PlayerSetPosPoint(endPointCS, 1)
end

function NIS_OutroFailure()
    --print(">>>[RUI]", "++NIS_OutroFailure")
    TextPrintString("", 1, 1)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    F_PlayerDismountBike()
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    if gFailMessage then
        MinigameSetCompletion("P_LAWN_FAIL", false, 0, gFailMessage)
    else
        MinigameSetCompletion("P_LAWN_FAIL", false, 0, "P_LAWN_15")
    end
    if bPlayerBusted then
        SoundPlayScriptedSpeechEvent(gPrefect, "BUSTING_JIMMY", 0, "large", true)
    elseif bGuardHit then
        F_AttackedAtendeeCamera()
        SoundPlayScriptedSpeechEvent(gPrefect, "LAWNMOWER", 1, "large")
    else
        SoundPlayScriptedSpeechEvent(gPrefect, "JEER", 0, "large", true)
    end
    Wait(2000)
    SoundPlayMissionEndMusic(false, 4)
    while SoundSpeechPlaying(gPrefect) do
        Wait(10)
    end
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(FADE_OUT_TIME, 0)
    Wait(FADE_OUT_TIME)
    if PedIsOnVehicle(gPlayer) then
        PlayerDetachFromVehicle()
        while PedIsOnVehicle(gPlayer) do
            Wait(0)
        end
    end
    VehicleDelete(mower)
    mower = nil
    PlayerSetPosPoint(endPointCS, 1)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    --print(">>>[RUI]", "--NIS_OutroFailure")
end

function NIS_JobOutroFailure()
    TextPrintString("", 1, 1)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    F_PlayerDismountBike()
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    if gFailMessage then
        MinigameSetCompletion("P_LAWN_FAIL", false, 0, gFailMessage)
    else
        MinigameSetCompletion("P_LAWN_FAIL", false, 0, "P_LAWN_15")
    end
    if bGuardHit then
        PedFaceObjectNow(gPrefect, gPlayer, 3)
        PedFaceObjectNow(gPlayer, gPrefect, 2)
        Wait(50)
        F_AttackedAtendeeCamera()
        SoundPlayScriptedSpeechEvent(gPrefect, "LAWNMOWER", 7, "large")
        Wait(2000)
    end
    SoundPlayMissionEndMusic(false, 4)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(FADE_OUT_TIME, 0)
    Wait(FADE_OUT_TIME)
    if PedIsOnVehicle(gPlayer) then
        PlayerDetachFromVehicle()
        while PedIsOnVehicle(gPlayer) do
            Wait(0)
        end
    end
    VehicleDelete(mower)
    mower = nil
    if PedExists(gPrefect) then
        PrefectWanderAmbiently(gPrefect)
    end
    PedDelete(gPrefect)
    PlayerSetPosPoint(endPointCS, 1)
end

function SuccessMessage()
    if not bSuccessMessage then
        bSuccessMessage = true
        TextPrint(gCompleteStr, 4, 1)
        if bDoTutorials then
            CreateThread("T_LeaveMowerInstructions")
        end
    end
end

function MissionSetup()
    shared.bFootBallFieldEnabled = false
    MissionDontFadeIn()
    RadarSetMinMax(10, 75, 15)
    PlayerSetPunishmentPoints(0)
    SoundPlayInteractiveStream("MS_CarnivalFunhouseMaze.rsm", 0.45, 500, 500)
    DATLoad("LawnMowing.DAT", 2)
    DATInit()
    shared.gDisablePrepGate = false
    DisablePunishmentSystem(true)
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    POIGroupsEnabled(false)
    DisablePOI(true, true)
    AreaClearAllPeds()
    F_SetCharacterModelsUnique(true, { 50 })
    MinigameCreate("LAWNMOWING", false)
    PedSetWeaponNow(gPlayer, -1, 0)
    F_RainBeGone()
end

function MissionCleanup()
    F_MakePlayerSafeForNIS(false)
    if gMissionType == MISSION_JOB then
        --print(">>>[RUI]", "DisablePunishmentSystem(false)")
        DisablePunishmentSystem(false)
    elseif gMissionState == MISSION_PASSED or IsMissionDebugSuccess() then
        PlayerSetScriptSavedData(14, 0)
    else
        PlayerSetScriptSavedData(14, 1)
    end
    if PedExists(gPrefect) then
        PrefectWanderAmbiently(gPrefect)
    end
    if gMissionState == MISSION_PASSED then
        if gPrefect and PedIsValid(gPrefect) then
            PedMakeAmbient(gPrefect)
        end
    elseif gMissionType == MISSION_JOB then
        if gPrefect and PedIsValid(gPrefect) then
            PedMakeAmbient(gPrefect)
        end
    elseif gPrefect and PedIsValid(gPrefect) then
        PedDelete(gPrefect)
    end
    CameraSetWidescreen(false)
    WeatherRelease()
    F_SetCharacterModelsUnique(false)
    if PedIsInAnyVehicle(gPlayer) then
        PlayerDetachFromVehicle()
    end
    if mower ~= nil then
        VehicleDelete(mower)
    end
    RadarRestoreMinMax()
    MinigameDestroy()
    MissionTimerStop()
    SoundStopInteractiveStream()
    if gDestroyables then
        DeregisterPropHashHandlers()
        gDestroyables = {}
    end
    RemoveLawnPlants()
    shared.gDisablePrepGate = true
    AreaRevertToDefaultPopulation()
    EnablePOI(true, true)
    POIGroupsEnabled(true)
    PedResetTypeAttitudesToDefault()
    DATUnload(2)
    if newObj then
        MissionObjectiveRemove(newObj)
    end
    DisablePunishmentSystem(false)
    FollowCamDefaultVehicleShot()
    CameraReturnToPlayer()
end

function PrefectWanderAmbiently(prefect)
    PedClearTether(prefect)
    PedClearObjectives(prefect)
    PedWander(prefect, 0)
    PedMakeAmbient(prefect)
    --print(">>>[RUI]", "!!PrefectWanderAmbiently")
end

function PedExists(ped)
    return ped and PedIsValid(ped) and not (PedGetHealth(ped) <= 0)
end

function GuardCreate(pos, model)
    local guard = PedCreatePoint(model, pos, 1)
    PedSetTetherToPoint(guard, pos, 2, 15)
    PedIgnoreStimuli(guard, false)
    PedIgnoreAttacks(guard, false)
    PedLockTarget(guard, gPlayer, 3)
    RegisterPedEventHandler(guard, 0, cbGuardHit)
    --print(">>>[RUI]", "++GuardCreate")
    return guard
end

function MissionInit(tier)
    SetupDifficulty(tier)
    LoadModels({ 50, 284 })
    AreaTransitionPoint(0, startPoint, 1, false)
    while MinigameIsReady() == false do
        Wait(0)
    end
    if PlayerIsInAnyVehicle() then
        --print(">>>[RUI]", "MissinSetup: clear the bike")
        local bike = VehicleFromDriver(gPlayer)
        PlayerDetachFromVehicle()
        VehicleSetPosPoint(bike, bikeStoragePoint)
    else
        F_StorePlayersBikeIfInTrigger(gameArea, bikeStoragePoint)
    end
    mower = VehicleCreatePoint(284, lmPoint)
    gPrefect = GuardCreate(prefectStart, guardModel)
    AreaClearAllPeds()
    PedSetAsleep(gPrefect, true)
end

function T_MissionTutorial()
    if gTutorialMessage then
        Wait(1000)
        --print(">>>[RUI]", "++T_MissionTutorial")
        TutorialShowMessage(gTutorialMessage, 8000)
        Wait(8000)
        if gTutorialMessage2 then -- Added this
            TutorialShowMessage(gTutorialMessage2, 8000)
            Wait(8000)
        end
        --print(">>>[RUI]", "--T_MissionTutorial")
    end
    collectgarbage()
end

function T_LeaveMowerInstructions()
    --print(">>>[RUI]", "++T_LeaveMowerInstructions")
    Wait(2000)
    TutorialShowMessage("TUT_LMP_03", 8000)
    Wait(8000)
    collectgarbage()
    --print(">>>[RUI]", "--T_LeaveMowerInstructions")
end

function LawnMowerSetLawn(minPoint, maxPoint, accuracy)
    --print(">>>[RUI]", "++LawnMowerSetLawn accuracy=" .. accuracy)
    local minX, minY = GetPointList(minPoint)
    local maxX, maxY = GetPointList(maxPoint)
    LawnMowingSetMinScore(accuracy)
    LawnMowingSetLawnArea(minX, minY, maxX, maxY)
end

function LawnMowerMinigameStart()
    --print(">>>[RUI]", "!![[LawnMowerMinigameStart")
    LawnMowingSetTimer(gMissionTime)
    MissionTimerStart(gMissionTime)
    MinigameStart()
    MinigameEnableHUD(true)
    --print(">>>[RUI]", "!!LawnMowerMinigameStart duration=" .. gMissionTime .. "]]")
end

function main()
    while not gCurrentTier do
        Wait(10)
    end
    MissionInit(gCurrentTier)
    NIS_Intro()
    DisablePunishmentSystem(true)
    if bDoTutorials then
        CreateThread("T_MissionTutorial")
    end
    gStartTime = GetTimer()
    while MinigameIsActive() do
        bSuccess = MinigameIsSuccess()
        PlayerDamagedPlants()
        if bSuccess then
            SuccessMessage()
            gMissionState = MISSION_PASSED
            if MissionTimerHasFinished() then
                gMissionState = MISSION_PASSED
                break
            end
            if not PedIsInVehicle(gPlayer, mower) then
                --print(">>>[RUI]", "main:  Player exited vehicle")
                gMissionState = MISSION_PASSED
                break
            end
        elseif PlayerLeftMowerTimedOut() then
            --print(">>>[RUI]", "main:  player left mower")
            gFailMessage = "P_LAWN_12"
            gMissionState = MISSION_FAILED
            break
        end
        if MissionFailureConditionsMet() then
            gMissionState = MISSION_FAILED
            break
        end
        Wait(0)
    end
    if gObjective then
        gObjective = UpdateObjectiveLog(nil, gObjective)
    end
    local xTime = GetTimer() - gStartTime
    MissionTimerStop()
    MinigameEnableHUD(false)
    MinigameEnd()
    StatAddToInt(172)
    StatAddToInt(174, xTime)
    if gMissionState == MISSION_PASSED then
        if gMissionType == MISSION_PUNISHMENT then
            --print("Player should not be doing punishment anymore!!")
            PlayerSetScriptSavedData(14, 0)
            NIS_OutroSuccess()
        else
            NIS_JobOutroSuccess()
        end
        StatAddToInt(173)
        shared.bFootBallFieldEnabled = true
        MissionSucceed(false, false, false)
    elseif gMissionType == MISSION_PUNISHMENT then
        --print("Player Failed!!!")
        PlayerSetScriptSavedData(14, 1)
        NIS_OutroFailure()
        MissionFail(false, false)
    else
        NIS_JobOutroFailure()
        MissionFail(false, false)
    end
end

function MissionFailureConditionsMet()
    if PlayerLeftGameAreaTimedOut() and gMissionType == MISSION_JOB then
        --print(">>>[RUI]", "main:  player left play area")
        gMissionState = MISSION_FAILED
        gFailMessage = "P_LAWN_12"
        return true
    end
    if PlayerBusted() and not bGuardHit then
        gFailMessage = nil
        gMissionState = MISSION_FAILED
        bPlayerBusted = true
        gFailMessage = "P_LAWN_14"
        return true
    end
    if bGuardHit then
        PedSetAsleep(gPrefect, true)
        return true
    end
    if not bSuccess and MissionTimerHasFinished() then
        --print(">>>[RUI]", "main:  FAIL Timed Out")
        gFailMessage = "P_LAWN_15"
        gMissionState = MISSION_FAILED
        return true
    end
    return false
end
