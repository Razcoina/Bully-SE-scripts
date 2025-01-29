local bChocboxCreated = false
local bGreetedPlayer = false
local bPlayerGreetedBif = false
local bPlayerAttackedBif = false
local bMovedKeyToInside = false
local bBifFollowingPath = false
local bLetPlayerIn = false
local bLeftHarrington = false
local bSetupDoors = false
local plantIndex, plantPool
local gPlantHealth = 0
local gPlantIndex, gPlantObject

function main()
    if MissionActiveSpecific("6_03") and shared.g6_03_PreppiesAlive == true then
        AreaDisableCameraControlForTransition(true)
    end
    DATLoad("PAn_Prep.DAT", 0)
    DATLoad("SP_Prep_House.DAT", 0)
    LoadPedModels({ 33 })
    LoadActionTree("Act/Conv/PrepHouse.act")
    LoadAnimationGroup("NPC_ADULT")
    F_PreDATInit()
    DATInit()
    shared.gAreaDATFileLoaded[32] = true
    LoadPAnims({
        TRIGGER._PANIM_FLYTRAP
    })
    F_SetupBif()
    F_SetupHarringtonHouse()
    Wait(1000)
    --print("SETTING THE DOORS!!!")
    if MissionActiveSpecific("6_03") and shared.g6_03_PreppiesAlive == true then
        shared.g6_03_PreppiesAlive = false
        shared.g6_03_AreaReady = true
    end
    while not (AreaGetVisible() ~= 32 or SystemShouldEndScript()) do
        F_UpdateBif()
        F_UpdatePickup()
        Wait(0)
        if not bSetupDoors and PlayerIsInTrigger(TRIGGER._PREPHOUSE_MAIN2ND) then
            bSetupDoors = true
            GeometryInstance("PH_OpenDoor01", false, -524.291, 118.2, 50.68, true)
            GeometryInstance("PH_OpenDoor02", false, -516.797, 133.414, 55.6463, true)
            GeometryInstance("DPI_pDoorBrk", true, -524.291, 118.2, 50.68, false)
            GeometryInstance("DPI_pDoorBrk", true, -516.797, 133.414, 55.6463, false)
        end
    end
    bLeftHarrington = true
    UnLoadAnimationGroup("NPC_ADULT")
    DATUnload(0)
    DATUnload(5)
    shared.gAreaDATFileLoaded[32] = false
    F_DeregisterPropEvents()
    collectgarbage()
end

function F_DeregisterPropEvents()
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_prepWinBrk01"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_prepWinBrk"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pDoorBrk01"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pDoorBrk02"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_StableS04"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_Gramophone"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_SCfern03"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_StableS05"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_PokerTbl"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair08"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair10"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair09"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair11"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair03"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair02"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair12"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair01"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_PokerTbl01"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair07"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair04"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_StableS03"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_StableS02"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pPlant05"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pPlant02"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pPlant03"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pPlant04"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pVase08"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pVase07"), 3, -1)
    RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pVase06"), 3, -1)
end

function F_SetupBif()
    if MissionActiveSpecific("2_08") then
        AreaSetDoorLocked("DT_PREPTOMAIN", true)
        if shared.bAllowPlayerInside then
            bGreetedPlayer = true
            bPlayerGreetedBif = true
            shared.gBif = PedCreatePoint(33, POINTLIST._PREPHS_BIFMOVED, 1)
            local health = PedGetHealth(shared.gBif) / 100 * 40
            PedSetHealth(shared.gBif, health)
            PedSetMaxHealth(shared.gBif, health)
            Wait(10)
            if not shared.bBifAttacked then
                PedSetEmotionTowardsPed(shared.gBif, gPlayer, 7)
                PlayerRegisterSocialCallbackVsPed(shared.gBif, 35, F_PlayerGreetedBif)
                PlayerRegisterSocialCallbackVsPed(shared.gBif, 23, F_PlayerGreetedBif)
            end
            GameSetPedStat(shared.gBif, 38, 30)
            GameSetPedStat(shared.gBif, 39, 30)
        else
            shared.gBif = PedCreatePoint(33, POINTLIST._PREPHS_BIF, 1)
            local health = PedGetHealth(shared.gBif) / 100 * 40
            PedSetHealth(shared.gBif, health)
            PedSetMaxHealth(shared.gBif, health)
            PedSetEmotionTowardsPed(shared.gBif, gPlayer, 7)
            PlayerRegisterSocialCallbackVsPed(shared.gBif, 35, F_PlayerGreetedBif)
            PlayerRegisterSocialCallbackVsPed(shared.gBif, 23, F_PlayerGreetedBif)
        end
    end
end

function F_SetupHarringtonHouse()
    AreaSetPathableInRadius(-516.62, 129.015, 55.575, 0.15, 0.5, false)
    AreaSetPathableInRadius(-516.622, 137.852, 55.575, 0.15, 0.5, false)
    AreaSetPathableInRadius(-524.295, 118.29, 50.616, 0.152, 0.5, true)
    AreaSetPathableInRadius(-516.618, 133.406, 55.577, 0.15, 0.5, true)
    if MissionActiveSpecific("2_08") or MissionActiveSpecific("6_03") then
        --print("REGISTERING THE EVENTS!!")
        RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_prepWinBrk01"), 3, CB_EnablePath)
        RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_prepWinBrk"), 3, CB_EnablePath)
        RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pDoorBrk01"), 3, CB_EnablePath)
        RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pDoorBrk02"), 3, CB_EnablePath)
        if MissionActiveSpecific("2_08") then
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_StableS04"), 3, CB_Floor1HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_Gramophone"), 3, CB_Floor1HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_SCfern03"), 3, CB_Floor1HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_StableS05"), 3, CB_Floor1HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_PokerTbl02"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_PokerTbl"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair08"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair10"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair09"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair11"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair03"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair02"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair12"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair01"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_PokerTbl01"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair07"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pChair04"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_StableS03"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_StableS02"), 3, CB_Floor2HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pPlant05"), 3, CB_Floor3HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pPlant02"), 3, CB_Floor3HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pPlant03"), 3, CB_Floor3HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pPlant04"), 3, CB_Floor3HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pVase08"), 3, CB_Floor3HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pVase07"), 3, CB_Floor3HeardNoise)
            RegisterHashEventHandler(ObjectNameToHashID("isc_prep_DPI_pVase06"), 3, CB_Floor3HeardNoise)
        end
    end
    if PAnimExists(TRIGGER._DOOR_PREPHOUSE_FOYEROUT) then
        PAnimDelete(TRIGGER._DOOR_PREPHOUSE_FOYEROUT)
    end
    if PAnimExists(TRIGGER._DOOR_PREPHOUSE_STAIRS) then
        AreaSetDoorLocked(TRIGGER._DOOR_PREPHOUSE_STAIRS, true)
        AreaSetDoorLockedToPeds(TRIGGER._DOOR_PREPHOUSE_STAIRS, true)
        AreaSetDoorPathableToPeds(TRIGGER._DOOR_PREPHOUSE_STAIRS, true)
        PAnimOpenDoor(TRIGGER._DOOR_PREPHOUSE_STAIRS)
        PAnimDoorStayOpen(TRIGGER._DOOR_PREPHOUSE_STAIRS)
    end
    if MissionActiveSpecific("2_08") or MissionActiveSpecific2("2_08") then
        --print("2_08 NOT COMPLEATED!!")
        PAnimSetActionNode(TRIGGER._PANIM_FLYTRAP, "/Global/VFlyTrap/Idle", "Act/Props/VFlyTrap.act")
        if not shared.bWeedPlantIsDestroyed then
            CreateThread("T_MonitorWeedDestroy")
        end
        if MissionActiveSpecific("2_08") or MissionActiveSpecific2("2_08") then
            if shared.bAllowPlayerInside then
                F_OpenHarringtonHouseDoors()
            else
                F_LockHarringtonHouseDoors()
            end
        end
    else
        if PAnimExists(TRIGGER._PANIM_FLYTRAP) then
            PAnimSetActionNode(TRIGGER._PANIM_FLYTRAP, "/Global/VFlyTrap/Death/Dead", "Act/Props/VFlyTrap.act")
        end
        --print("OPEN THAT SHIT UP!")
        F_OpenHarringtonHouseDoors()
    end
end

function T_MonitorWeedDestroy()
    while not bLeftHarrington do
        --print("WTF??")
        if PAnimExists(TRIGGER._PANIM_FLYTRAP) then
            if PedHasWeapon(gPlayer, 395) then
                break
            end
            if PAnimGetHealth(TRIGGER._PANIM_FLYTRAP) <= 0.15 then
                break
            end
        end
        Wait(100)
    end
    while not bLeftHarrington and PAnimGetHealth(TRIGGER._PANIM_FLYTRAP) > 0.15 do
        Wait(0)
    end
    --print("PLANT WAS DESTROYED!!")
    PAnimHideHealthBar(TRIGGER._PANIM_FLYTRAP)
    shared.bWeedPlantIsDestroyed = true
    collectgarbage()
end

function F_UpdateBif()
    if MissionActiveSpecific("2_08") and shared.gBif and PedIsValid(shared.gBif) then
        if not shared.bAllowPlayerInside and bPlayerGreetedBif and not bPlayerAttackedBif and not bBifFollowingPath then
            PedStopSocializing(shared.gBif)
            PedFollowPath(shared.gBif, PATH._PREPHS_OPENDOORPATH, 0, 0, CB_BifOpeningDoor)
            SoundPlayScriptedSpeechEvent(shared.gBif, "M_2_08", 53, "large")
            bBifFollowingPath = true
        end
        if PedIsHit(shared.gBif, 2, 500) and PedGetWhoHitMeLast(shared.gBif) == gPlayer then
            bPlayerAttackedBif = true
            PedAttack(shared.gBif, gPlayer, 1)
            ClearTextQueue()
        end
        if not shared.bBifAttacked and shared.gBif and PedIsValid(shared.gBif) and PedIsHit(shared.gBif, 2, 1000) and PedGetWhoHitMeLast(shared.gBif) == gPlayer then
            shared.bBifAttacked = true
            PedSetPedToTypeAttitude(shared.gBif, 13, 0)
        end
        if not bGreetedPlayer and not shared.bBifAttacked then
            bGreetedPlayer = true
            QueueSoundSpeech(shared.gBif, "RESPONSE_GREET_FRIENDLY", 0, nil, "large")
            QueueSoundSpeech(shared.gBif, "GREET_CLOTHES_LIKE", 0, nil, "large")
            if math.random(1, 100) > 50 then
                QueueSoundSpeech(shared.gBif, "GREET_PLAYER_HAIRCUT_LIKE", 0, nil, "large")
            else
                QueueSoundSpeech(shared.gBif, "GREET_PLAYER_SHIRT_LIKE", 0, nil, "large")
            end
            UpdateTextQueue()
        end
    end
end

function F_UpdatePickup()
    if MissionActiveSpecific("2_08") and bLetPlayerIn and shared.gBif and PedIsValid(shared.gBif) then
        PAnimOpenDoor(TRIGGER._DOOR_PREPHOUSE_FOYER)
    end
end

function F_PlayerGreetedBif()
    ClearTextQueue()
    SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_GREET_GENERIC_BOY", 0, "speech")
    bPlayerGreetedBif = true
end

function CB_BifOpeningDoor(pedId, pathId, nodeId)
    if nodeId == 1 then
        PedSetActionNode(shared.gBif, "/Global/PrepHouse/OpenFoyeurDoor/DoAnim", "Act/Conv/PrepHouse.act")
    elseif nodeId == PathGetLastNode(pathId) then
        PedFaceHeading(shared.gBif, 90, 1)
    end
end

function F_OpenHarringtonHouseDoors()
    --print("F_OpenHarringtonHouseDoors")
    shared.bAllowPlayerInside = true
    bLetPlayerIn = true
    AreaSetDoorLocked(TRIGGER._DOOR_PREPHOUSE_FOYER, false)
    AreaSetDoorLockedToPeds(TRIGGER._DOOR_PREPHOUSE_FOYER, false)
    AreaSetDoorPathableToPeds(TRIGGER._DOOR_PREPHOUSE_FOYER, true)
    if MissionActiveSpecific("2_08") and shared.gBif ~= nil and PedIsPlaying(shared.gBif, "/Global/PrepHouse/OpenFoyeurDoor/DoAnim", true) then
        PAnimOpenDoor(TRIGGER._DOOR_PREPHOUSE_FOYER)
        PAnimDoorStayOpen(TRIGGER._DOOR_PREPHOUSE_FOYER)
    end
    if MissionActiveSpecific("6_03") then
        AreaSetDoorLockedToPeds(TRIGGER._DOOR_PREPHOUSE_FOYER, false)
        PAnimOpenDoor(TRIGGER._DOOR_PREPHOUSE_FOYER)
        AreaSetDoorOpen(TRIGGER._DOOR_PREPHOUSE_FOYER, true)
        PAnimDoorStayOpen(TRIGGER._DOOR_PREPHOUSE_FOYER)
    end
end

function F_LockHarringtonHouseDoors()
    AreaSetDoorLocked(TRIGGER._DOOR_PREPHOUSE_FOYER, true)
    AreaSetDoorLockedToPeds(TRIGGER._DOOR_PREPHOUSE_FOYER, true)
    AreaSetDoorPathableToPeds(TRIGGER._DOOR_PREPHOUSE_FOYER, true)
end

function CB_EnablePath(HashID, ModelPoolIndex)
    --print("HashID: ", tostring(HashID))
    --print("ModelPoolIndex: ", ModelPoolIndex)
    --print("DPI_prepWinBrk01: ", tostring(ObjectNameToHashID("isc_prep_DPI_prepWinBrk01")))
    --print("DPI_prepWinBrk: ", tostring(ObjectNameToHashID("isc_prep_DPI_prepWinBrk")))
    --print("DPI_pDoorBrk01: ", tostring(ObjectNameToHashID("isc_prep_DPI_pDoorBrk01")))
    --print("DPI_pDoorBrk02: ", tostring(ObjectNameToHashID("isc_prep_DPI_pDoorBrk02")))
    if ObjectNameToHashID("isc_prep_DPI_prepWinBrk01") == HashID then
        AreaSetPathableInRadius(-516.62, 129.015, 55.575, 0.15, 0.5, true)
        shared.nFloorHeard = 3
    elseif ObjectNameToHashID("isc_prep_DPI_prepWinBrk") == HashID then
        AreaSetPathableInRadius(-516.622, 137.852, 55.575, 0.15, 0.5, true)
        shared.nFloorHeard = 3
    elseif ObjectNameToHashID("isc_prep_DPI_pDoorBrk01") == HashID then
        AreaSetPathableInRadius(-524.295, 118.29, 50.616, 0.152, 0.5, true)
        shared.nFloorHeard = 2
        --print("Guys should go after the player!")
    elseif ObjectNameToHashID("isc_prep_DPI_pDoorBrk02") == HashID then
        AreaSetPathableInRadius(-516.618, 133.406, 55.577, 0.15, 0.5, true)
        shared.nFloorHeard = 3
        --print("Guys should go after the player!")
    end
end

function CB_Floor1HeardNoise(HashId, ModelPoolIndex)
    --print("Object in the first floor broke!")
    shared.nFloorHeard = 1
end

function CB_Floor2HeardNoise(HashId, ModelPoolIndex)
    --print("Object in the second floor broke!")
    shared.nFloorHeard = 2
end

function CB_Floor3HeardNoise(HashId, ModelPoolIndex)
    --print("Object in the third floor broke!")
    shared.nFloorHeard = 3
end
