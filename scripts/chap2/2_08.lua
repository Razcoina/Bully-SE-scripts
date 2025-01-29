--[[ Changes to this file:
    * Modified function F_StageFive_FightBif, may require testing
    * Modified function F_RunPlantNIS, may require testing
]]

local sMissionState = "running"
local fMissionStage
local tObjectiveTable = {}
local bGotHaircut = false
local bGotAquaberry = false
local bLetIntoHarrington = false
local bPlantDestroyed = false
local bBlippedKey = false
local bGoToHarrington = false
local bMovedBif = false
local bDisplayedPlantObjective = false
local bGetToBottomFloorMsg = false
local bBifObjectiveComplete = false
local bPlantTargetDeleted = false
local tFirstFloorTable = {}
local tSecondFloorTable = {}
local tThirdFloorTable = {}
local bFirstFloorFight = false
local bSecondFloorFight = false
local bThirdFloorFight = false
local nToldPlayerToPickupKey = 0
local nDestroyPlantObjective = 0
local bGetByBif = false
local nTotalObjectsDestroyed = 0
local bDestructibleSetup = true
local tDestroyables = {}
local bEnteredSolarium = false
local bExtraGuy
local bSetupFirstFloorForExit = false
local gDoorGuard
local bPlayerHasHat = true
local bPlayerHasAcquiredHaircut = false
local bPlayerHasAcquiredAquaberry = false
local bGrabbedPoison = false
local gClothingManagerBlip

function MissionSetup()
    shared.gBif = nil
    shared.bBifDefeated = false
    shared.bGrabbedHarringtonHouseKey = false
    shared.bAllowPlayerInside = false
    shared.gHarringtonKeyPickup = nil
    shared.bWeedPlantIsDestroyed = false
    shared.nFloorHeard = 0
    shared.bBifAttacked = false
    MissionDontFadeIn()
    PlayCutsceneWithLoad("2-08", true, true)
    MissionDontFadeIn()
    if PlayerGetMoney() < 1200 then
        PlayerSetMoney(1200)
    end
end

function F_MissionSetup()
    PlayerSetControl(0)
    DATLoad("2_08.DAT", 2)
    DATLoad("SP_BoysDorm.DAT", 2)
    DATInit()
    LoadAnimationGroup("Px_Urinal")
    LoadAnimationGroup("NPC_AggroTaunt")
    LoadAnimationGroup("2_08WeedKiller")
    LoadAnimationGroup("SGEN_S")
    LoadAnimationGroup("NPC_Chat_1")
    LoadAnimationGroup("Hang_Talking")
    LoadAnimationGroup("MINI_Lock")
    SoundStopPA()
    F_InitializeFirstFloor()
    F_InitializeSecondFloor()
    F_InitializeThirdFloor()
    WeaponRequestModel(302)
    WeaponRequestModel(353)
    WeaponRequestModel(300)
    WeaponRequestModel(357)
    LoadPedModels({
        30,
        40,
        31,
        34,
        32,
        35,
        362
    })
    LoadWeaponModels({
        302,
        353,
        300,
        357
    })
    SetNumberOfHandledHashEventObjects(50)
    LoadActionTree("Act/Conv/2_08.act")
    AreaSetDoorLocked("DT_TSCHOOL_PREPPYL", true)
    PAnimCreate(TRIGGER._2_08_PLANTTARGET)
    PlayerSetControl(1)
    F_MoveToSchool()
end

function MissionCleanup()
    for i, entry in tDestroyables do
        RegisterHashEventHandler(entry.id, 3, -1)
    end
    shared.bBifDefeated = false
    shared.bGrabbedHarringtonHouseKey = false
    shared.bAllowPlayerInside = false
    if sMissionState ~= "Success" then
        ItemSetCurrentNum(493, 0)
    end
    CameraReset()
    CameraReturnToPlayer()
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    PedResetTypeAttitudesToDefault()
    AreaDisableCameraControlForTransition(false)
    UnLoadAnimationGroup("Px_Urinal")
    UnLoadAnimationGroup("SGEN_S")
    UnLoadAnimationGroup("2_08WeedKiller")
    UnLoadAnimationGroup("NPC_AggroTaunt")
    UnLoadAnimationGroup("NPC_Chat_1")
    UnLoadAnimationGroup("Hang_Talking")
    UnLoadAnimationGroup("MINI_Lock")
    if not bPlantTargetDeleted then
        PAnimMakeTargetable(TRIGGER._2_08_PLANTTARGET, false)
        PAnimDelete(TRIGGER._2_08_PLANTTARGET)
    end
    SoundStopInteractiveStream()
    SoundEnableInteractiveMusic(true)
    SoundRestartPA()
    SoundEnableSpeech_ActionTree()
    DATUnload(2)
end

local hasAquaberry = false
local hasHaircut = false
local hasHat = false

function main()
    F_MissionSetup()
    CameraFade(500, 1)
    Wait(501)
    CreateThread("T_PrepsLikePlayer")
    hasAquaberry = F_PlayerHasAquaberryClothing()
    hasHaircut = F_PlayerHasFancyHaircut()
    hasHat = F_PlayerIsWearingHat()
    if hasAquaberry and hasHaircut and not hasHat then
        bPlayerHasAcquiredHaircut = true
        bPlayerHasAcquiredAquaberry = true
        bGoToHarrington = true
        F_AddObjectiveBlip("POINT", POINTLIST._2_08_BIFLOC, 1, 1)
        F_AddMissionObjective("2_08_HARRINGOBJ", true)
        AreaSetDoorLocked("DT_TSCHOOL_PREPPYL", false)
        fMissionStage = F_StageTwo_SneakIntoHarrington
    else
        if not hasHaircut and not hasAquaberry then
            F_AddObjectiveBlip("POINT", POINTLIST._2_08_SALONCORONA, 1, 1)
            local x, y, z = GetPointFromPointList(POINTLIST._2_08_CLOTHINGMANAGER, 1)
            gClothingManagerBlip = BlipAddXYZ(x, y, z + 0.1, 0, 1)
            --print("OBJECTIVE BLIP!?!?!? NEITHER")
            bPlayerHasAcquiredHaircut = false
            F_AddMissionObjective("2_08_RICHBARBOBJ", false)
            bPlayerHasAcquiredAquaberry = false
            F_AddMissionObjective("2_08_AQUAOBJ", false)
            TextPrint("2_08_DISGUISE", 4, 1)
        elseif not hasHaircut then
            F_AddObjectiveBlip("POINT", POINTLIST._2_08_SALONCORONA, 1, 1)
            --print("OBJECTIVE BLIP!?!?!? NOT HAIRCUT BUT HAS AQUA")
            bPlayerHasAcquiredHaircut = false
            bPlayerHasAcquiredAquaberry = true
            F_AddMissionObjective("2_08_AQUAOBJ", false)
            F_CompleteMissionObjective("2_08_AQUAOBJ")
            F_AddMissionObjective("2_08_RICHBARBOBJ", true)
        elseif not hasAquaberry then
            F_AddObjectiveBlip("POINT", POINTLIST._2_08_CLOTHINGMANAGER, 1, 1)
            bPlayerHasAcquiredAquaberry = false
            bPlayerHasAcquiredHaircut = true
            F_AddMissionObjective("2_08_RICHBARBOBJ", false)
            F_CompleteMissionObjective("2_08_RICHBARBOBJ")
            F_AddMissionObjective("2_08_AQUAOBJ", true)
        elseif hasHat then
            F_AddObjectiveBlip("POINT", POINTLIST._2_08_CLOTHINGMANAGER, 1, 1)
            F_AddMissionObjective("2_08_HATOBJ", true)
            bPlayerHasHat = false
            bPlayerHasAcquiredAquaberry = true
            bPlayerHasAcquiredHaircut = true
            F_AddMissionObjective("2_08_RICHBARBOBJ", false)
            F_CompleteMissionObjective("2_08_RICHBARBOBJ")
            F_AddMissionObjective("2_08_AQUAOBJ", false)
            F_CompleteMissionObjective("2_08_AQUAOBJ")
        end
        fMissionStage = F_StageOne_DisguiseYourself
    end
    while sMissionState == "running" do
        fMissionStage()
        UpdateTextQueue()
        Wait(0)
    end
    if sMissionState == "Success" then
        SoundStopInteractiveStream()
        MinigameSetCompletion("M_PASS", true, 3000)
        SoundPlayMissionEndMusic(true, 10)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        CameraFade(500, 0)
        Wait(501)
        PlayerSetPosPoint(POINTLIST._2_08_FINALPOS, 1)
        CameraReturnToPlayer(true)
        MissionSucceed(false, false, false)
    elseif sMissionState == "OutOfMoney" then
        SoundPlayMissionEndMusic(false, 10)
        MissionFail(false, true, "CMN_STR_06")
    else
        SoundPlayMissionEndMusic(false, 10)
        MissionFail(false)
    end
end

function F_StageOne_DisguiseYourself()
    hasAquaberry = F_PlayerHasAquaberryClothing()
    hasHaircut = F_PlayerHasFancyHaircut()
    hasHat = F_PlayerIsWearingHat()
    if shared.PlayerInClothingManager == nil and not shared.playerShopping then
        if bPlayerHasHat then
            if not hasHaircut and PlayerGetMoney() < 1200 and not shared.playerShopping then
                sMissionState = "OutOfMoney"
                return
            end
            if not bPlayerHasAcquiredHaircut then
                if hasHaircut then
                    bPlayerHasAcquiredHaircut = true
                    F_RemoveObjectiveBlip()
                    F_CompleteMissionObjective("2_08_RICHBARBOBJ")
                    if not hasAquaberry then
                        TextPrint("2_08_AQUAOBJ", 4, 1)
                        if gClothingManagerBlip then
                            BlipRemove(gClothingManagerBlip)
                            gClothingManagerBlip = nil
                        end
                        local x, y, z = GetPointFromPointList(POINTLIST._2_08_CLOTHINGMANAGER, 1)
                        gClothingManagerBlip = BlipAddXYZ(x, y, z + 0.1, 0, 1)
                    end
                end
            elseif not hasHaircut then
                F_AddObjectiveBlip("POINT", POINTLIST._2_08_SALONCORONA, 1, 1)
                F_ClearMissionObjectives()
                F_AddMissionObjective("2_08_AQUAOBJ", false)
                if hasAquaberry then
                    F_CompleteMissionObjective("2_08_AQUAOBJ")
                end
                F_AddMissionObjective("2_08_RICHBARBOBJ", true)
                bPlayerHasAcquiredHaircut = false
            end
            if not bPlayerHasAcquiredAquaberry then
                if hasAquaberry then
                    bPlayerHasAcquiredAquaberry = true
                    F_RemoveObjectiveBlip()
                    F_CompleteMissionObjective("2_08_AQUAOBJ")
                    if gClothingManagerBlip then
                        BlipRemove(gClothingManagerBlip)
                        gClothingManagerBlip = nil
                    end
                    if not hasHaircut then
                        F_AddObjectiveBlip("POINT", POINTLIST._2_08_SALONCORONA, 1, 1)
                        TextPrint("2_08_RICHBARBOBJ", 4, 1)
                    end
                end
            elseif not hasAquaberry then
                local x, y, z = GetPointFromPointList(POINTLIST._2_08_CLOTHINGMANAGER, 1)
                gClothingManagerBlip = BlipAddXYZ(x, y, z + 0.1, 0, 1)
                F_ClearMissionObjectives()
                F_AddMissionObjective("2_08_RICHBARBOBJ", false)
                if hasHaircut then
                    F_CompleteMissionObjective("2_08_RICHBARBOBJ")
                end
                F_AddMissionObjective("2_08_AQUAOBJ", true)
                bPlayerHasAcquiredAquaberry = false
            end
        end
        if bPlayerHasAcquiredHaircut and bPlayerHasAcquiredHaircut then
            if bPlayerHasHat then
                if hasHat then
                    F_ClearMissionObjectives()
                    F_AddMissionObjective("2_08_RICHBARBOBJ", false)
                    F_AddMissionObjective("2_08_AQUAOBJ", false)
                    F_CompleteMissionObjective("2_08_RICHBARBOBJ")
                    F_CompleteMissionObjective("2_08_AQUAOBJ")
                    TextPrint("2_08_HATOBJ", 4, 1)
                    F_AddObjectiveBlip("POINT", POINTLIST._2_08_CLOTHINGMANAGER, 1, 1)
                    F_AddMissionObjective("2_08_HATOBJ", false)
                    bPlayerHasHat = false
                end
            elseif not hasHat then
                bPlayerHasHat = true
                F_RemoveObjectiveBlip()
                F_CompleteMissionObjective("2_08_HATOBJ")
                if not hasHaircut then
                    F_AddObjectiveBlip("POINT", POINTLIST._2_08_SALONCORONA, 1, 1)
                    TextPrint("2_08_RICHBARBOBJ", 4, 1)
                end
                if not hasAquaberry then
                    TextPrint("2_08_AQUAOBJ", 4, 1)
                    F_AddObjectiveBlip("POINT", POINTLIST._2_08_CLOTHINGMANAGER, 1, 1)
                end
            end
        end
        if hasAquaberry and hasHaircut and not hasHat then
            if gClothingManagerBlip then
                BlipRemove(gClothingManagerBlip)
                gClothingManagerBlip = nil
            end
            fMissionStage = F_SetupStageTwo_SneakIntoHarrington
        end
    end
end

function F_SetupStageTwo_SneakIntoHarrington()
    if not F_PlayerHasFancyHaircut() then
        fMissionStage = F_StageOne_DisguiseYourself
    elseif not F_PlayerHasAquaberryClothing() then
        fMissionStage = F_StageOne_DisguiseYourself
    elseif F_PlayerIsWearingHat() then
        fMissionStage = F_StageOne_DisguiseYourself
    else
        bGoToHarrington = true
        F_AddObjectiveBlip("POINT", POINTLIST._2_08_BIFLOC, 1, 1)
        F_AddMissionObjective("2_08_HARRINGOBJ", true)
        AreaSetDoorLocked("DT_TSCHOOL_PREPPYL", false)
        fMissionStage = F_StageTwo_SneakIntoHarrington
    end
end

function F_StageTwo_SneakIntoHarrington()
    hasAquaberry = F_PlayerHasAquaberryClothing()
    hasHaircut = F_PlayerHasFancyHaircut()
    hasHat = F_PlayerIsWearingHat()
    if not (hasHaircut and hasAquaberry) or hasHat then
        AreaSetDoorLocked("DT_TSCHOOL_PREPPYL", true)
        bGoToHarrington = false
        fMissionStage = F_StageOne_DisguiseYourself
    end
    F_MonitorObjectives()
end

function F_SetupStageThree_DestroyThePlant()
    fMissionStage = F_StageThree_DestroyThePlant
end

function F_StageThree_DestroyThePlant()
    if not bPlantDestroyed and shared.bWeedPlantIsDestroyed then
        bPlantDestroyed = true
        F_RunPlantNIS()
        F_ResetAllPedsToNewLocations()
        fMissionStage = F_StageFour_ClearOutThirdFloor
    end
    F_MonitorObjectives()
end

local bPedsOnStairsAttacked = false

function F_StageFour_ClearOutThirdFloor()
    if not bPedsOnStairsAttacked and PlayerIsInTrigger(TRIGGER._2_08_TRIGGERSTAIRS) then
        if F_AreSecondFloorPrepsAlive() then
            if tSecondFloorTable.justin.bAlive then
                --print("Justin should be attacking!!")
                PedStop(tSecondFloorTable.justin.id)
                PedClearObjectives(tSecondFloorTable.justin.id)
                PedClearPOI(tSecondFloorTable.justin.id)
                PedSetPedToTypeAttitude(tSecondFloorTable.justin.id, 13, 0)
                PedAttack(tSecondFloorTable.justin.id, gPlayer, 1)
                PedSetActionNode(tSecondFloorTable.justin.id, "/Global/2_08Conv/Idle/PlayerIdle", "Act/Conv/2_08.act")
            end
            if tSecondFloorTable.tad.bAlive then
                --print("Tad should be attacking!!")
                PedStop(tSecondFloorTable.tad.id)
                PedClearObjectives(tSecondFloorTable.tad.id)
                PedClearPOI(tSecondFloorTable.tad.id)
                PedSetPedToTypeAttitude(tSecondFloorTable.tad.id, 13, 0)
                PedAttack(tSecondFloorTable.tad.id, gPlayer, 1)
                PedSetActionNode(tSecondFloorTable.tad.id, "/Global/2_08Conv/Idle/PlayerIdle", "Act/Conv/2_08.act")
            end
        end
        bPedsOnStairsAttacked = true
    end
    if tThirdFloorTable.chad.bAlive and tThirdFloorTable.chad.id and PedIsDead(tThirdFloorTable.chad.id) then
        PedMakeAmbient(tThirdFloorTable.chad.id)
        tThirdFloorTable.chad.id = nil
        tThirdFloorTable.chad.bAlive = false
    end
    if tThirdFloorTable.bryce.bAlive and tThirdFloorTable.bryce.id and PedIsDead(tThirdFloorTable.bryce.id) then
        PedMakeAmbient(tThirdFloorTable.bryce.id)
        tThirdFloorTable.bryce.id = nil
        tThirdFloorTable.bryce.bAlive = false
    end
    if tSecondFloorTable.justin.bAlive and tSecondFloorTable.justin.id and PedIsDead(tSecondFloorTable.justin.id) then
        PedMakeAmbient(tSecondFloorTable.justin.id)
        tSecondFloorTable.justin.id = nil
        tSecondFloorTable.justin.bAlive = false
    end
    if tSecondFloorTable.tad.bAlive and tSecondFloorTable.tad.id and PedIsDead(tSecondFloorTable.tad.id) then
        PedMakeAmbient(tSecondFloorTable.tad.id)
        tSecondFloorTable.tad.id = nil
        tSecondFloorTable.tad.bAlive = false
    end
    if bFirstFloorFight then
        if tFirstFloorTable.gord.bAlive and tFirstFloorTable.gord.id and PedIsDead(tFirstFloorTable.gord.id) then
            PedMakeAmbient(tFirstFloorTable.gord.id)
            tFirstFloorTable.gord.id = nil
            tFirstFloorTable.gord.bAlive = false
        end
        if tFirstFloorTable.parker.bAlive and tFirstFloorTable.parker.id and PedIsDead(tFirstFloorTable.parker.id) then
            PedMakeAmbient(tFirstFloorTable.parker.id)
            tFirstFloorTable.parker.id = nil
            tFirstFloorTable.parker.bAlive = false
        end
    end
    if not F_AreThirdFloorPrepsAlive() and not F_AreSecondFloorPrepsAlive() then
        if not bFirstFloorFight then
            if not bGetToBottomFloorMsg then
                bGetToBottomFloorMsg = true
                F_AddObjectiveBlip("POINT", POINTLIST._2_08_EXITLOC, 1, 1)
            end
        elseif F_AreFirstFloorPrepsAlive() and not bGetToBottomFloorMsg then
            bGetToBottomFloorMsg = true
            F_AddObjectiveBlip("POINT", POINTLIST._2_08_EXITLOC, 1, 1)
        end
    end
    if not bSetupFirstFloorForExit then
        F_PedDeleteFirstFloorGuys()
        bExtraGuy = PedCreatePoint(30, POINTLIST._2_08_SECONDFLOORPED, 1)
        PedFaceHeading(bExtraGuy, 0, 0)
        F_AddObjectiveBlip("POINT", POINTLIST._2_08_EXITLOC, 1, 1)
        if PAnimExists(TRIGGER._DOOR_PREPHOUSE_STAIRS) then
            AreaSetDoorLocked(TRIGGER._DOOR_PREPHOUSE_STAIRS, true)
            AreaSetDoorLockedToPeds(TRIGGER._DOOR_PREPHOUSE_STAIRS, true)
            AreaSetDoorPathableToPeds(TRIGGER._DOOR_PREPHOUSE_STAIRS, false)
            PAnimCloseDoor(TRIGGER._DOOR_PREPHOUSE_STAIRS)
        end
        bSetupFirstFloorForExit = true
    end
    if F_FightingDone() and bSetupFirstFloorForExit and PlayerIsInTrigger(TRIGGER._2_08_DOORSTAIRS) then
        PedSetActionNode(bExtraGuy, "/Global/PrepHouse/OpenSecondFloorDoor", "Act/Conv/2_08.act")
        Wait(100)
        if PAnimExists(TRIGGER._DOOR_PREPHOUSE_STAIRS) then
            AreaSetDoorLocked(TRIGGER._DOOR_PREPHOUSE_STAIRS, true)
            AreaSetDoorLockedToPeds(TRIGGER._DOOR_PREPHOUSE_STAIRS, true)
            AreaSetDoorPathableToPeds(TRIGGER._DOOR_PREPHOUSE_STAIRS, true)
            PAnimOpenDoor(TRIGGER._DOOR_PREPHOUSE_STAIRS)
            PAnimDoorStayOpen(TRIGGER._DOOR_PREPHOUSE_STAIRS)
        end
        PedSetPedToTypeAttitude(bExtraGuy, 13, 0)
        PedAttack(bExtraGuy, gPlayer, 1)
        PedMakeAmbient(bExtraGuy)
        fMissionStage = F_StageFive_FightBif
    end
    F_MonitorObjectives()
end

local bBifAttackedPlayer = false

function F_StageFive_FightBif() -- ! Modified
    if not bBifAttackedPlayer and PlayerIsInTrigger(TRIGGER._2_08_BIFATTACKTRIG) then
        bBifAttackedPlayer = true
        if shared.gBif and not shared.bBifDefeated and PedIsValid(shared.gBif) then
            F_RemoveObjectiveBlip()
            if shared.bWeedPlantIsDestroyed then
                F_AddObjectiveBlip("POINT", POINTLIST._2_08_EXITLOC, 1, 1)
            end
            SoundPlayScriptedSpeechEvent(shared.gBif, "FIGHT_INITIATE", 0, "large")
            PedSetActionNode(shared.gBif, "/Global/2_08Conv/ComeOn", "Act/Conv/2_08.act")
            Wait(500)
            while SoundSpeechPlaying(shared.gBif) do
                Wait(0)
            end
            PedSetPedToTypeAttitude(shared.gBif, 13, 0)
            PedAttack(shared.gBif, gPlayer, 1)
        end
    end
    if shared.bWeedPlantIsDestroyed and PedIsPlaying(gPlayer, "/Global/Door/PedPropsActions", true) then
        AreaDisableCameraControlForTransition(true) -- Added this
        CameraFade(500, 0)                    -- Added this
        Wait(501)                             -- Added this
        SoundStopInteractiveStream(0)         -- Added this
        PlayerSetControl(0)
        --[[
        while AreaGetVisible() ~= 0 do
            Wait(0)
        end
        ]] -- Replaced this loop for the next one
        while not shared.gAreaDATFileLoaded[0] do
            Wait(0)
        end
        F_RemoveObjectiveBlip()
        CameraSetWidescreen(true)
        if PedGetWeapon(gPlayer) == 395 then
            --print("REMOVE THE PLAYERS WEAPON!")
            PedSetActionNode(gPlayer, "/Global/2_08Conv/Idle_Remove", "Act/Conv/2_08.act")
        end
        Wait(1000)
        PlayerSetControl(0)
        PlayerSetPosPoint(POINTLIST._2_08_OUTHAR, 1)
        CameraSetXYZ(103.56771, -125.023994, 7.458748, 103.49873, -126.01162, 7.599507)
        SoundEnableInteractiveMusic(false)
        CameraFade(500, 1) -- Added this
        Wait(501)    -- Added this
        AreaDisableCameraControlForTransition(false)
        sMissionState = "Success"
    end
    F_MonitorObjectives()
    Wait(500) -- Added this
end

local gObjectiveBlip

function F_RemoveObjectiveBlip()
    if gObjectiveBlip ~= nil then
        --print("BLIP IS GETTING DELETED!!")
        BlipRemove(gObjectiveBlip)
        Wait(100)
        gObjectiveBlip = nil
    end
end

function F_AddObjectiveBlip(blipType, point, index, blipEnum, xObj, yObj, zObj)
    F_RemoveObjectiveBlip()
    if gObjectiveBlip == nil then
        if blipType == "POINT" then
            Wait(100)
            if xObj == nil then
                xObj, yObj, zObj = GetPointFromPointList(point, index)
            end
            gObjectiveBlip = BlipAddXYZ(xObj, yObj, zObj + 0.1, 0, blipEnum)
            --print("gObjective blip: ", gObjectiveBlip)
        elseif blipType == "CHAR" and not PedIsDead(point) then
            Wait(100)
            gObjectiveBlip = AddBlipForChar(point, index, 0, blipEnum)
        end
    end
end

function F_ClearMissionObjectives()
    local tableSize = table.getn(tObjectiveTable)
    while table.getn(tObjectiveTable) > 0 do
        MissionObjectiveRemove(tObjectiveTable[tableSize].id)
        table.remove(tObjectiveTable, table.getn(tObjectiveTable))
        tableSize = table.getn(tObjectiveTable)
        Wait(0)
    end
    tObjectiveTable = {}
end

local bReleaseToPOI1 = false

function T_MonitorFirstFloor()
    local bStartedSpeaking1 = false
    while not bPlantDestroyed do
        if PlayerIsInTrigger(TRIGGER._2_08_FIRSTFLOORTRIG) then
            if tFirstFloorTable.parker.id == nil and tFirstFloorTable.parker.bAlive then
                tFirstFloorTable.parker.id = PedCreatePoint(tFirstFloorTable.parker.model, tFirstFloorTable.parker.point, tFirstFloorTable.parker.num)
                PedOverrideStat(tFirstFloorTable.parker.id, 0, 362)
                PedOverrideStat(tFirstFloorTable.parker.id, 1, 100)
            end
            if tFirstFloorTable.gord.id == nil and tFirstFloorTable.gord.bAlive then
                tFirstFloorTable.gord.id = PedCreatePoint(tFirstFloorTable.gord.model, tFirstFloorTable.gord.point, tFirstFloorTable.gord.num)
            end
        end
        if not bStartedSpeaking1 and not bFirstFloorFight and tFirstFloorTable.gord.id and tFirstFloorTable.gord.bAlive and PlayerIsInAreaObject(tFirstFloorTable.gord.id, 2, 6, 0) then
            bStartedSpeaking1 = true
            QueueSoundSpeech(tFirstFloorTable.gord.id, "M_2_08", 38, nil, "large")
            QueueSoundSpeech(tFirstFloorTable.parker.id, "M_2_08", 39, nil, "large")
            QueueSoundSpeech(tFirstFloorTable.gord.id, "M_2_08", 40, nil, "large")
            QueueSoundSpeech(tFirstFloorTable.parker.id, "M_2_08", 41, nil, "large")
            QueueSoundSpeech(tFirstFloorTable.gord.id, "M_2_08", 42, nil, "large")
            QueueSoundSpeech(tFirstFloorTable.parker.id, "M_2_08", 43, nil, "large")
            QueueSoundSpeech(tFirstFloorTable.gord.id, "M_2_08", 44, nil, "large")
            QueueSoundSpeech(tFirstFloorTable.parker.id, "M_2_08", 45, F_ReleaseToPOI, "large")
            PedSetActionNode(tFirstFloorTable.gord.id, "/Global/2_08Conv/Interruptable/TalkAnims", "Act/Conv/2_08.act")
            PedSetActionNode(tFirstFloorTable.parker.id, "/Global/2_08Conv/Interruptable/ListenAnims", "Act/Conv/2_08.act")
        end
        if tFirstFloorTable.gord.bAlive or tFirstFloorTable.parker.bAlive then
            if tFirstFloorTable.gord.id ~= nil and PedGetWhoHitMeLast(tFirstFloorTable.gord.id) == gPlayer or tFirstFloorTable.parker.id ~= nil and PedGetWhoHitMeLast(tFirstFloorTable.parker.id) == gPlayer and not bFirstFloorFight then
                ClearTextQueue()
                Wait(1000)
                F_FirstFloorPedsAttack()
            else
                if tFirstFloorTable.gord.id ~= nil and PedIsValid(tFirstFloorTable.gord.bAlive) and PedIsDead(tFirstFloorTable.gord.bAlive) then
                    PedMakeAmbient(tFirstFloorTable.gord.id)
                    tFirstFloorTable.gord.id = nil
                    tFirstFloorTable.gord.bAlive = false
                end
                if tFirstFloorTable.parker.id ~= nil and PedIsValid(tFirstFloorTable.parker.bAlive) and PedIsDead(tFirstFloorTable.parker.bAlive) then
                    PedMakeAmbient(tFirstFloorTable.parker.id)
                    tFirstFloorTable.parker.id = nil
                    tFirstFloorTable.gord.bAlive = false
                end
            end
        end
        if bStartedSpeaking1 and not bReleaseToPOI1 and not PlayerIsInAreaObject(tFirstFloorTable.gord.id, 2, 8, 0) then
            bReleaseToPOI1 = true
            ClearTextQueue()
            F_SetFirstFloorPedsIntoPOI()
        end
        Wait(0)
    end
end

function F_ReleaseToPOI1()
    bReleaseToPOI1 = true
    F_SetFirstFloorPedsIntoPOI()
end

function F_FirstFloorPedsAttack()
    if not bFirstFloorFight then
        if tFirstFloorTable.parker.bAlive and PedGetHealth(tFirstFloorTable.parker.id) > 0 then
            SoundRemoveAllQueuedSpeech(tFirstFloorTable.parker.id, true)
            F_HarringtonHousePedsAttack(tFirstFloorTable.parker.id)
        end
        if tFirstFloorTable.gord.bAlive and 0 < PedGetHealth(tFirstFloorTable.gord.id) then
            SoundRemoveAllQueuedSpeech(tFirstFloorTable.gord.id, true)
            F_HarringtonHousePedsAttack(tFirstFloorTable.gord.id)
        end
        bFirstFloorFight = true
    end
end

function F_PedDeleteFirstFloorGuys()
    if not bFirstFloorFight then
        if tFirstFloorTable.parker.bAlive and PedGetHealth(tFirstFloorTable.parker.id) > 0 then
            PedDelete(tFirstFloorTable.parker.id)
            tFirstFloorTable.parker.bAlive = false
        end
        if tFirstFloorTable.gord.bAlive and 0 < PedGetHealth(tFirstFloorTable.gord.id) then
            PedDelete(tFirstFloorTable.gord.id)
            tFirstFloorTable.gord.bAlive = false
        end
    end
end

local bReleaseToPOI2 = false

function T_MonitorSecondFloor()
    local bStartedSpeaking2 = false
    while not bPlantDestroyed do
        if PlayerIsInTrigger(TRIGGER._2_08_SECNDFLOORTRIG) then
            if tSecondFloorTable.justin.id == nil and tSecondFloorTable.justin.bAlive then
                tSecondFloorTable.justin.id = PedCreatePoint(tSecondFloorTable.justin.model, tSecondFloorTable.justin.point, tSecondFloorTable.justin.num)
            end
            if tSecondFloorTable.tad.id == nil and tSecondFloorTable.tad.bAlive then
                tSecondFloorTable.tad.id = PedCreatePoint(tSecondFloorTable.tad.model, tSecondFloorTable.tad.point, tSecondFloorTable.tad.num)
                PedOverrideStat(tSecondFloorTable.tad.id, 0, 362)
                PedOverrideStat(tSecondFloorTable.tad.id, 1, 100)
            end
        end
        if not bStartedSpeaking2 and not bSecondFloorFight and tSecondFloorTable.tad.id and tSecondFloorTable.tad.bAlive and PlayerIsInAreaObject(tSecondFloorTable.tad.id, 2, 8, 0) then
            bStartedSpeaking2 = true
            if bFirstFloorFight then
                Wait(1000)
                QueueSoundSpeech(tSecondFloorTable.tad.id, "M_2_08", 29, nil, "large")
                QueueSoundSpeech(tSecondFloorTable.justin.id, "M_2_08", 30, nil, "large")
                QueueSoundSpeech(tSecondFloorTable.justin.id, "M_2_08", 31, F_ReleaseToPOI2, "large")
                PedSetActionNode(tSecondFloorTable.tad.id, "/Global/2_08Conv/Interruptable/TalkAnims", "Act/Conv/2_08.act")
                PedSetActionNode(tSecondFloorTable.justin.id, "/Global/2_08Conv/Interruptable/ListenAnims", "Act/Conv/2_08.act")
            else
                bReleaseToPOI2 = true
                F_SetSecondFloorPedsIntoPOI()
            end
        end
        if tSecondFloorTable.tad.bAlive or tSecondFloorTable.justin.bAlive then
            if tSecondFloorTable.tad.id ~= nil and PedGetWhoHitMeLast(tSecondFloorTable.tad.id) == gPlayer or tSecondFloorTable.justin.id ~= nil and PedGetWhoHitMeLast(tSecondFloorTable.justin.id) == gPlayer and not bSecondFloorFight then
                ClearTextQueue()
                Wait(1000)
                F_SecondFloorPedsAttack()
            else
                if tSecondFloorTable.tad.id ~= nil and PedIsValid(tSecondFloorTable.tad.bAlive) and PedIsDead(tSecondFloorTable.tad.bAlive) then
                    PedMakeAmbient(tSecondFloorTable.tad.id)
                    tSecondFloorTable.tad.id = nil
                    tSecondFloorTable.tad.bAlive = false
                end
                if tSecondFloorTable.justin.id ~= nil and PedIsValid(tSecondFloorTable.justin.bAlive) and PedIsDead(tSecondFloorTable.justin.bAlive) then
                    PedMakeAmbient(tSecondFloorTable.justin.id)
                    tSecondFloorTable.justin.id = nil
                    tSecondFloorTable.justin.bAlive = false
                end
            end
        end
        if bStartedSpeaking2 and not bReleaseToPOI2 and not PlayerIsInAreaObject(tSecondFloorTable.tad.id, 2, 10, 0) then
            bReleaseToPOI2 = true
            ClearTextQueue()
            F_SetSecondFloorPedsIntoPOI()
        end
        Wait(0)
    end
end

function F_ReleaseToPOI2()
    bReleaseToPOI2 = true
    F_SetSecondFloorPedsIntoPOI()
end

function F_SecondFloorPedsAttack()
    --print("bSecondFloorFight: ", tostring(bSecondFloorFight))
    if not bSecondFloorFight then
        --print("tSecondFloorTable.tad.bAlive: ", tostring(tSecondFloorTable.tad.bAlive))
        --print("tSecondFloorTable.tad.id: ", tostring(tSecondFloorTable.tad.id))
        if tSecondFloorTable.tad.bAlive and PedGetHealth(tSecondFloorTable.tad.id) > 0 then
            SoundRemoveAllQueuedSpeech(tSecondFloorTable.tad.id, true)
            F_HarringtonHousePedsAttack(tSecondFloorTable.tad.id)
        end
        --print("tSecondFloorTable.justin.bAlive: ", tostring(tSecondFloorTable.justin.bAlive))
        --print("tSecondFloorTable.justin.id: ", tostring(tSecondFloorTable.justin.id))
        if tSecondFloorTable.justin.bAlive and 0 < PedGetHealth(tSecondFloorTable.justin.id) then
            SoundRemoveAllQueuedSpeech(tSecondFloorTable.justin.id, true)
            F_HarringtonHousePedsAttack(tSecondFloorTable.justin.id)
        end
        bSecondFloorFight = true
    end
end

local bReleaseToPOI3 = false

function T_MonitorThirdFloor()
    local bStartedSpeaking3 = false
    while not bPlantDestroyed do
        if PlayerIsInTrigger(TRIGGER._2_08_THRDFLOORTRIG) then
            if tThirdFloorTable.chad.id == nil and tThirdFloorTable.chad.bAlive then
                tThirdFloorTable.chad.id = PedCreatePoint(tThirdFloorTable.chad.model, tThirdFloorTable.chad.point, tThirdFloorTable.chad.num)
                PedOverrideStat(tThirdFloorTable.chad.id, 0, 362)
                PedOverrideStat(tThirdFloorTable.chad.id, 1, 100)
            end
            if tThirdFloorTable.bryce.id == nil and tThirdFloorTable.bryce.bAlive then
                tThirdFloorTable.bryce.id = PedCreatePoint(tThirdFloorTable.bryce.model, tThirdFloorTable.bryce.point, tThirdFloorTable.bryce.num)
            end
        end
        if not bStartedSpeaking3 and not bThirdFloorFight and tThirdFloorTable.bryce.id and tThirdFloorTable.bryce.bAlive and PlayerIsInAreaObject(tThirdFloorTable.bryce.id, 2, 6, 0) then
            bStartedSpeaking3 = true
            QueueSoundSpeech(tThirdFloorTable.chad.id, "M_2_08", 32, nil, "large")
            QueueSoundSpeech(tThirdFloorTable.bryce.id, "M_2_08", 33, nil, "large")
            QueueSoundSpeech(tThirdFloorTable.chad.id, "M_2_08", 34, nil, "large")
            QueueSoundSpeech(tThirdFloorTable.bryce.id, "M_2_08", 35, nil, "large")
            QueueSoundSpeech(tThirdFloorTable.chad.id, "M_2_08", 36, F_ReleaseToPOI3, "large")
            PedSetActionNode(tThirdFloorTable.bryce.id, "/Global/2_08Conv/Interruptable/TalkAnims", "Act/Conv/2_08.act")
            PedSetActionNode(tThirdFloorTable.chad.id, "/Global/2_08Conv/Interruptable/ListenAnims", "Act/Conv/2_08.act")
        end
        if tThirdFloorTable.bryce.bAlive or tThirdFloorTable.chad.bAlive then
            if tThirdFloorTable.bryce.id ~= nil and PedGetWhoHitMeLast(tThirdFloorTable.bryce.id) == gPlayer or tThirdFloorTable.chad.id ~= nil and PedGetWhoHitMeLast(tThirdFloorTable.chad.id) == gPlayer and not bThirdFloorFight then
                ClearTextQueue()
                Wait(1000)
                F_ThirdFloorPedsAttack()
            else
                if tThirdFloorTable.bryce.id ~= nil and PedIsValid(tThirdFloorTable.bryce.bAlive) and PedIsDead(tThirdFloorTable.bryce.bAlive) then
                    PedMakeAmbient(tThirdFloorTable.bryce.id)
                    tThirdFloorTable.bryce.id = nil
                    tThirdFloorTable.bryce.bAlive = false
                end
                if tThirdFloorTable.chad.id ~= nil and PedIsValid(tThirdFloorTable.chad.bAlive) and PedIsDead(tThirdFloorTable.chad.bAlive) then
                    PedMakeAmbient(tThirdFloorTable.chad.id)
                    tThirdFloorTable.chad.id = nil
                    tThirdFloorTable.chad.bAlive = false
                end
            end
        end
        if bStartedSpeaking3 and not bReleaseToPOI3 and not PlayerIsInAreaObject(tThirdFloorTable.chad.id, 2, 8, 0) then
            bReleaseToPOI3 = true
            ClearTextQueue()
            F_SetThirdFloorPedsIntoPOI()
        end
        Wait(0)
    end
end

function F_ReleaseToPOI3()
    bReleaseToPOI3 = true
    F_SetThirdFloorPedsIntoPOI()
end

function F_ThirdFloorPedsAttack()
    if not bThirdFloorFight then
        if tThirdFloorTable.bryce.bAlive and PedGetHealth(tThirdFloorTable.bryce.id) > 0 then
            SoundRemoveAllQueuedSpeech(tThirdFloorTable.bryce.id, true)
            F_HarringtonHousePedsAttack(tThirdFloorTable.bryce.id)
        end
        if tThirdFloorTable.chad.bAlive and 0 < PedGetHealth(tThirdFloorTable.chad.id) then
            SoundRemoveAllQueuedSpeech(tThirdFloorTable.chad.id, true)
            F_HarringtonHousePedsAttack(tThirdFloorTable.chad.id)
        end
        bThirdFloorFight = true
    end
end

function F_HarringtonHousePedsAttack(pedId)
    PedStop(pedId)
    PedClearObjectives(pedId)
    PedLockTarget(pedId, -1, 3)
    if PedIsPlaying(pedId, "/Global/2_08Conv/Interruptable", true) then
        PedSetActionNode(pedId, "/Global/2_08Conv/Idle/PlayerIdle", "Act/Conv/2_08.act")
    end
    PedSetPedToTypeAttitude(pedId, 13, 0)
    PedAttack(pedId, gPlayer, 1)
end

local nAddedBlip = 0
local bPreviousBifAttacked = shared.bBifAttacked

function F_MonitorObjectives()
    if shared.bBifDefeated then
        if bGetByBif then
            bGetByBif = false
            F_CompleteMissionObjective("2_08_GETBYBIF")
            F_CompleteMissionObjective("2_08_BEATBIF")
        end
    elseif shared.gBif and PedIsValid(shared.gBif) and PedIsDead(shared.gBif) then
        if not shared.bWeedPlantIsDestroyed then
            AreaSetDoorLocked(TRIGGER._DOOR_PREPHOUSE_FOYER, false)
            AreaSetDoorLockedToPeds(TRIGGER._DOOR_PREPHOUSE_FOYER, false)
            AreaSetDoorPathableToPeds(TRIGGER._DOOR_PREPHOUSE_FOYER, false)
            PAnimOpenDoor(TRIGGER._DOOR_PREPHOUSE_FOYER)
            AreaSetDoorOpen(TRIGGER._DOOR_PREPHOUSE_FOYER, true)
            F_AddObjectiveBlip("POINT", POINTLIST._2_08_TOSOLARIUM, 1, 1)
            nDestroyPlantObjective = F_AddMissionObjective("2_08_DESTROYPLNT", true)
            fMissionStage = F_SetupStageThree_DestroyThePlant
            bDisplayedPlantObjective = true
        end
        shared.bBifDefeated = true
        shared.gHarringtonKeyPickup = true
    end
    if shared.bAllowPlayerInside and nDestroyPlantObjective == 0 and not bDisplayedPlantObjective then
        if bGetByBif then
            bGetByBif = false
            F_CompleteMissionObjective("2_08_GETBYBIF")
        end
        bDisplayedPlantObjective = true
        if bEnteredSolarium then
            F_AddObjectiveBlip("POINT", POINTLIST._2_08_PLANT, 1, 4)
        else
            F_AddObjectiveBlip("POINT", POINTLIST._2_08_TOSOLARIUM, 1, 1)
        end
        nDestroyPlantObjective = F_AddMissionObjective("2_08_DESTROYPLNT", true)
        fMissionStage = F_SetupStageThree_DestroyThePlant
    end
    if shared.bWeedPlantIsDestroyed and 0 < nDestroyPlantObjective then
        nDestroyPlantObjective = 0
    end
    if shared.gHarringtonKeyPickup and nBlippedKey == 0 then
        if shared.bWeedPlantIsDestroyed then
            nBlippedKey = 2
        else
            nBlippedKey = 1
        end
        local x, y, z = PickupGetXYZ(shared.gHarringtonKeyPickup)
        F_AddObjectiveBlip("POINT", nil, 0, 1, x, y, z)
    elseif nBlippedKey == 1 and shared.bWeedPlantIsDestroyed then
        nBlippedKey = 2
        if bEnteredSolarium then
            F_AddObjectiveBlip("POINT", POINTLIST._2_08_PLANT, 1, 4)
        else
            F_AddObjectiveBlip("POINT", POINTLIST._2_08_TOSOLARIUM, 1, 1)
        end
    end
    if AreaGetVisible() == 32 then
        if not bGetByBif and not shared.bAllowPlayerInside and not shared.bBifDefeated and shared.gAreaDATFileLoaded[32] and shared.gBif and PedIsValid(shared.gBif) then
            bGetByBif = true
            CreateThread("T_MonitorFirstFloor")
            CreateThread("T_MonitorSecondFloor")
            CreateThread("T_MonitorThirdFloor")
            F_CompleteMissionObjective("2_08_HARRINGOBJ")
            F_AddMissionObjective("2_08_GETBYBIF", true)
        end
        if nAddedBlip == 0 then
            if not shared.bBifAttacked and shared.gBif and PedIsValid(shared.gBif) then
                --print("Player didn't attack bif inside...")
                F_RemoveObjectiveBlip()
                if shared.bWeedPlantIsDestroyed then
                    F_AddObjectiveBlip("POINT", POINTLIST._2_08_EXITLOC, 1, 1)
                else
                    gObjectiveBlip = AddBlipForChar(shared.gBif, 5, 17, 4)
                end
                nAddedBlip = 32
            elseif shared.gBif and PedIsValid(shared.gBif) and (PedHasGeneratedStimulusOfType(shared.gBif, 9) or PedHasGeneratedStimulusOfType(shared.gBif, 55) or shared.bBifAttacked) then
                --print("Player had already attacked bif inside...")
                nAddedBlip = 32
                F_RemoveObjectiveBlip()
                if shared.bWeedPlantIsDestroyed then
                    F_AddObjectiveBlip("POINT", POINTLIST._2_08_EXITLOC, 1, 1)
                elseif not shared.bAllowPlayerInside then
                    F_RemoveMissionObjective("2_08_GETBYBIF")
                    F_AddMissionObjective("2_08_BEATBIF", true)
                    gObjectiveBlip = AddBlipForChar(shared.gBif, 5, 26, 4)
                end
                PedClearObjectives(shared.gBif)
                PedStopSocializing(shared.gBif)
                PedSetPedToTypeAttitude(shared.gBif, 13, 0)
                PedAttack(shared.gBif, gPlayer, 3)
            end
            bPreviousBifAttacked = shared.bBifAttacked
        elseif nAddedBlip == 32 then
            if not bPreviousBifAttacked and shared.bBifAttacked then
                nAddedBlip = 32
                F_RemoveObjectiveBlip()
                --print("PLAYER ALREADY IN HARRINGTON HOUSE!")
                if shared.bWeedPlantIsDestroyed then
                    F_AddObjectiveBlip("POINT", POINTLIST._2_08_EXITLOC, 1, 1)
                elseif not shared.bAllowPlayerInside then
                    F_RemoveMissionObjective("2_08_GETBYBIF")
                    F_AddMissionObjective("2_08_BEATBIF", true)
                    gObjectiveBlip = AddBlipForChar(shared.gBif, 5, 26, 4)
                end
            end
            bPreviousBifAttacked = shared.bBifAttacked
        end
        if not bGrabbedPoison then
            if not F_ObjectiveAlreadyGiven("2_08_PESTICIDE") and PlayerIsInTrigger(TRIGGER._HOUSETHIRDFLOOR) then
                F_RemoveMissionObjective("2_08_DESTROYPLNT")
                F_AddMissionObjective("2_08_PESTICIDE", true)
                F_AddObjectiveBlip("POINT", POINTLIST._2_08_POISON, 1, 4)
            end
            if PedHasWeapon(gPlayer, 395) and not shared.bWeedPlantIsDestroyed then
                bGrabbedPoison = true
                SoundPlayInteractiveStream("MS_ActionMid.rsm", 0.6, 500, 500)
                SoundSetHighIntensityStream("MS_ActionHigh.rsm", 0.7, 500, 1000)
                F_CompleteMissionObjective("2_08_PESTICIDE")
                F_AddMissionObjective("2_08_DESTROY", true)
                F_AddObjectiveBlip("POINT", POINTLIST._2_08_PLANT, 1, 4)
                PAnimShowHealthBar(TRIGGER._PANIM_FLYTRAP, true, "2_08_PLANT", true)
            end
        end
    elseif nAddedBlip == 32 then
        F_AddObjectiveBlip("POINT", POINTLIST._2_08_BIFLOC, 1, 1)
        nAddedBlip = 0
    end
    if not bEnteredSolarium and PlayerIsInTrigger(TRIGGER._2_08_TOSOLARIUM) then
        bEnteredSolarium = true
        F_AddObjectiveBlip("POINT", POINTLIST._2_08_PLANT, 1, 4)
    end
    if shared.nFloorHeard == 1 then
        F_FirstFloorPedsAttack()
        shared.nFloorHeard = 0
    elseif shared.nFloorHeard == 2 then
        F_SecondFloorPedsAttack()
        shared.nFloorHeard = 0
    elseif shared.nFloorHeard == 3 then
        F_ThirdFloorPedsAttack()
        shared.nFloorHeard = 0
    end
end

function T_PrepsLikePlayer()
    while sMissionState == "running" do
        Wait(0)
        if AreaGetVisible() ~= 32 then
            if PedGetTypeToTypeAttitude(5, 13) < 3 and F_PlayerHasFancyHaircut() and F_PlayerHasAquaberryClothing() then
                PedSetTypeToTypeAttitude(5, 13, 4)
            elseif PedGetTypeToTypeAttitude(5, 13) == 4 and (not F_PlayerHasFancyHaircut() or not F_PlayerHasAquaberryClothing()) then
                PedResetTypeAttitudesToDefault()
            end
        end
    end
    collectgarbage()
end

function F_InitializeFirstFloor()
    tFirstFloorTable = {
        gord = {
            id = nil,
            bAlive = true,
            point = POINTLIST._2_08_FIRSTFLOORSPAWN,
            model = 30,
            num = 1
        },
        parker = {
            id = nil,
            bAlive = true,
            point = POINTLIST._2_08_FIRSTFLOORSPAWN,
            model = 40,
            num = 2
        }
    }
end

function F_InitializeSecondFloor()
    tSecondFloorTable = {
        justin = {
            id = nil,
            bAlive = true,
            point = POINTLIST._2_08_SECONDFLOORSPAWN,
            model = 34,
            num = 1
        },
        tad = {
            id = nil,
            bAlive = true,
            point = POINTLIST._2_08_SECONDFLOORSPAWN,
            model = 31,
            num = 2
        }
    }
end

function F_InitializeThirdFloor()
    tThirdFloorTable = {
        chad = {
            id = nil,
            bAlive = true,
            point = POINTLIST._2_08_THIRDFLOORSPAWN,
            model = 32,
            num = 1
        },
        bryce = {
            id = nil,
            bAlive = true,
            point = POINTLIST._2_08_THIRDFLOORSPAWN,
            model = 35,
            num = 2
        }
    }
end

function F_MoveToSchool()
    AreaTransitionPoint(2, POINTLIST._2_08_BIOLOGYROOM, 1, true)
end

function F_RunPlantNIS() -- ! Modified
    local NISPed
    local playerX, playerY, playerZ = 0, 0, 0
    local playerHeading = 0
    local bGun
    bGun = PedGetWeapon(gPlayer)
    local ammo
    if bGun then
        ammo = PedGetAmmoCount(gPlayer, bGun)
    end
    F_MakePlayerSafeForNIS(true)
    if bGun then
        PlayerSetWeapon(bGun, ammo, false)
    end
    MusicFadeWithCamera(false)
    SoundFadeWithCamera(false)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    CameraSetXYZ(-543.90265, 136.8605, 59.50786, -544.7172, 136.30087, 59.35554)
    GeometryInstance("PH_OpenDoor01", true, -524.291, 118.2, 50.68, false)
    GeometryInstance("DPI_pDoorBrk", false, -524.291, 118.2, 50.68, true)
    AreaSetPathableInRadius(-524.291, 118.2, 50.68, 0.1, 0.5, false)
    PAnimSetActionNode(TRIGGER._PANIM_FLYTRAP, "/Global/VFlyTrap/Death/Dead", "Act/Props/VFlyTrap.act")
    Wait(200)
    while not PAnimIsPlaying(TRIGGER._PANIM_FLYTRAP, "/Global/VFlyTrap/Death/Dead/DeadHold", false) do
        Wait(0)
    end
    Wait(1500)
    if not PlayerIsInTrigger(TRIGGER._2_08_SOLARIUMENTRANCE) then
        --print("Fighting Done: ", tostring(F_FightingDone()))
        --print("F_AnyPrepsAroundThePlayer: ", tostring(F_AnyPrepsAroundThePlayer()))
        if F_FightingDone() and not F_AnyPrepsAroundThePlayer() then
            --print("tThirdFloorTable.chad.bAlive: ", tostring(tThirdFloorTable.chad.bAlive))
            --print("tThirdFloorTable.bryce.bAlive: ", tostring(tThirdFloorTable.bryce.bAlive))
            if tThirdFloorTable.chad.bAlive or tThirdFloorTable.bryce.bAlive then
                PlayerSetControl(0)
                MusicFadeWithCamera(false)
                SoundFadeWithCamera(false)
                CameraFade(500, 0)
                Wait(500)
                SoundDisableSpeech_ActionTree()
                playerX, playerY, playerZ = PlayerGetPosXYZ()
                playerHeading = PedGetHeading(gPlayer)
                GeometryInstance("PH_OpenDoor02", true, -516.797, 133.414, 55.6463, false)
                GeometryInstance("DPI_pDoorBrk", false, -516.797, 133.414, 55.6463, true)
                AreaSetPathableInRadius(-516.797, 133.414, 55.6463, 0.1, 0.5, false)
                if tThirdFloorTable.chad.bAlive then
                    PedSetPosPoint(tThirdFloorTable.chad.id, POINTLIST._2_08_SOLARIUMPEDS, 1)
                    PedFaceHeading(tThirdFloorTable.chad.id, 90, 0)
                    NISPed = tThirdFloorTable.chad.id
                    if tThirdFloorTable.bryce.bAlive then
                        PedSetPosPoint(tThirdFloorTable.bryce.id, POINTLIST._2_08_SOLARIUMPEDS, 2)
                        PedFaceHeading(tThirdFloorTable.bryce.id, 270, 0)
                    end
                elseif tThirdFloorTable.bryce.bAlive then
                    PedSetPosPoint(tThirdFloorTable.bryce.id, POINTLIST._2_08_SOLARIUMPEDS, 1)
                    PedFaceHeading(tThirdFloorTable.bryce.id, 90, 0)
                    NISPed = tThirdFloorTable.bryce.id
                end
                SoundSetAudioFocusCamera()
                CameraSetWidescreen(true)
                CameraSetXYZ(-531.16907, 137.61205, 57.597054, -530.2804, 137.16061, 57.516857)
                Wait(100)
                CameraFade(500, 1)
                Wait(500)
                MusicFadeWithCamera(true)
                SoundFadeWithCamera(true)
                PedSetActionNode(NISPed, "/Global/2_08Conv/Taunt/TauntPlayer", "Act/Conv/2_08.act")
                if NISPed ~= tThirdFloorTable.bryce.id then
                    PedSetActionNode(tThirdFloorTable.bryce.id, "/Global/2_08Conv/Lock_Picking/Lock_Picking_Loop", "Act/Conv/2_08.act")
                end
                --[[
                PedFollowPath(NISPed, PATH._2_08_NIS, 0, 2)
                ]] -- Changed to:
                PedFollowPath(NISPed, PATH._, 0, 2)
                SoundPlayScriptedSpeechEvent(NISPed, "FIGHTING", 0, "jumbo")
                Wait(1000)
                while SoundSpeechPlaying(NISPed) do
                    Wait(0)
                end
                if tThirdFloorTable.chad.bAlive then
                    PedMoveToObject(tThirdFloorTable.chad.id, gPlayer, 2, 2)
                    if tThirdFloorTable.bryce.bAlive then
                        PedMoveToObject(tThirdFloorTable.bryce.id, gPlayer, 2, 2)
                    end
                else
                    PedMoveToObject(tThirdFloorTable.bryce.id, gPlayer, 2, 2)
                end
                MusicFadeWithCamera(false)
                SoundFadeWithCamera(false)
                CameraFade(500, 0)
                Wait(500)
                SoundSetAudioFocusPlayer()
                SoundEnableSpeech_ActionTree()
                PlayerSetControl(1)
                CameraSetWidescreen(false)
                CameraReturnToPlayer()
                CameraReset()
                CameraFade(500, 1)
                Wait(500)
                MusicFadeWithCamera(true)
                SoundFadeWithCamera(true)
                if tThirdFloorTable.chad.bAlive then
                    PedSetPedToTypeAttitude(tThirdFloorTable.chad.id, 13, 0)
                    PedAttack(tThirdFloorTable.chad.id, gPlayer, 1)
                    if tThirdFloorTable.bryce.bAlive then
                        PedSetPedToTypeAttitude(tThirdFloorTable.bryce.id, 13, 0)
                        PedAttack(tThirdFloorTable.bryce.id, gPlayer, 1)
                    end
                else
                    PedSetPedToTypeAttitude(tThirdFloorTable.bryce.id, 13, 0)
                    PedAttack(tThirdFloorTable.bryce.id, gPlayer, 1)
                end
            end
        end
    elseif F_AreThirdFloorPrepsAlive() then
        F_ThirdFloorPedsAttack()
    end
    bPlantTargetDeleted = true
    PAnimMakeTargetable(TRIGGER._2_08_PLANTTARGET, false)
    PAnimDelete(TRIGGER._2_08_PLANTTARGET)
    F_PedsHatePlayer()
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    CameraReset()
    MusicFadeWithCamera(true)
    SoundFadeWithCamera(true)
    bThirdFloorFight = true
    SoundPlayInteractiveStreamLocked("MS_ActionHigh.rsm", 0.7, 500, 500)
    F_AddObjectiveBlip("POINT", POINTLIST._2_08_MIDDLEFLOOREXIT, 1, 1)
    F_AddMissionObjective("2_08_OUTHAR", true)
    AreaSetDoorLocked("DT_PREPTOMAIN", false)
    F_CompleteMissionObjective("2_08_PESTICIDE")
    F_CompleteMissionObjective("2_08_HARRINGOBJ")
    F_CompleteMissionObjective("2_08_DESTROY")
    F_CompleteMissionObjective("2_08_DESTROYPLNT")
end

function F_PedsHatePlayer()
    if tFirstFloorTable.gord.bAlive then
        PedSetPedToTypeAttitude(tFirstFloorTable.gord.id, 13, 0)
    end
    if tFirstFloorTable.parker.bAlive then
        PedSetPedToTypeAttitude(tFirstFloorTable.parker.id, 13, 0)
    end
    if tSecondFloorTable.tad.id then
        PedSetPedToTypeAttitude(tSecondFloorTable.tad.id, 13, 0)
    end
    if tSecondFloorTable.justin.id then
        PedSetPedToTypeAttitude(tSecondFloorTable.justin.id, 13, 0)
    end
    if tThirdFloorTable.chad.bAlive then
        PedSetPedToTypeAttitude(tThirdFloorTable.chad.id, 13, 0)
    end
    if tThirdFloorTable.bryce.id then
        PedSetPedToTypeAttitude(tThirdFloorTable.bryce.id, 13, 0)
    end
end

function F_AreThirdFloorPrepsAlive()
    if tThirdFloorTable.chad.id ~= nil and PedIsDead(tThirdFloorTable.chad.id) then
        PedMakeAmbient(tThirdFloorTable.chad.id)
        tThirdFloorTable.chad.id = nil
        tThirdFloorTable.chad.bAlive = false
    end
    if tThirdFloorTable.bryce.id ~= nil and PedIsDead(tThirdFloorTable.bryce.id) then
        PedMakeAmbient(tThirdFloorTable.bryce.id)
        tThirdFloorTable.bryce.id = nil
        tThirdFloorTable.bryce.bAlive = false
    end
    if tThirdFloorTable.chad.bAlive or tThirdFloorTable.bryce.bAlive then
        return true
    end
    return false
end

function F_AreSecondFloorPrepsAlive()
    if tSecondFloorTable.tad.id ~= nil and PedIsDead(tSecondFloorTable.tad.id) then
        PedMakeAmbient(tSecondFloorTable.tad.id)
        tSecondFloorTable.tad.id = nil
        tSecondFloorTable.tad.bAlive = false
    end
    if tSecondFloorTable.justin.id ~= nil and PedIsDead(tSecondFloorTable.justin.id) then
        PedMakeAmbient(tSecondFloorTable.justin.id)
        tSecondFloorTable.justin.id = nil
        tSecondFloorTable.justin.bAlive = false
    end
    if tSecondFloorTable.tad.bAlive or tSecondFloorTable.justin.bAlive then
        return true
    end
    return false
end

function F_AreFirstFloorPrepsAlive()
    if tFirstFloorTable.gord.id ~= nil and PedIsDead(tFirstFloorTable.gord.id) then
        PedMakeAmbient(tFirstFloorTable.gord.id)
        tFirstFloorTable.gord.id = nil
        tFirstFloorTable.gord.bAlive = false
    end
    if tFirstFloorTable.parker.id ~= nil and PedIsDead(tFirstFloorTable.parker.id) then
        PedMakeAmbient(tFirstFloorTable.parker.id)
        tFirstFloorTable.parker.id = nil
        tFirstFloorTable.parker.bAlive = false
    end
    if tFirstFloorTable.gord.bAlive or tFirstFloorTable.parker.bAlive then
        return true
    end
    return false
end

function F_ResetAllPedsToNewLocations()
    if not bMovedBif and shared.bWeedPlantIsDestroyed and shared.gBif and not PedIsDead(shared.gBif) then
        bMovedBif = true
        PedSetPosPoint(shared.gBif, POINTLIST._PREPHS_BIFINSIDE, 1)
        PedFaceHeading(shared.gBif, 270, 0)
    end
end

function F_AnyPrepsAroundThePlayer()
    local ped1, ped2, ped3
    ped1 = PedFindInAreaObject(gPlayer, 4)
    if ped2 ~= nil and ped3 ~= nil then
        return true
    end
    return false
end

function F_ObjectiveAlreadyGiven(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            return true
        end
    end
    return false
end

function F_ObjectiveAlreadyComplete(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            return objective.bComplete
        end
    end
    return false
end

function F_RemoveMissionObjective(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            MissionObjectiveRemove(objective.id)
            table.remove(tObjectiveTable, i)
        end
    end
end

function F_CompleteMissionObjective(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            MissionObjectiveComplete(objective.id)
            objective.bComplete = true
        end
    end
end

function F_AddMissionObjective(reference, bTextPrint)
    if F_ObjectiveAlreadyGiven(reference) then
        for i, objective in tObjectiveTable do
            if objective.ref == reference then
                return objective.id
            end
        end
    end
    local objId = MissionObjectiveAdd(reference)
    table.insert(tObjectiveTable, {
        id = objId,
        ref = reference,
        bComplete = false
    })
    --print("Mission objective added! ", reference)
    if bTextPrint then
        --print("SD:FLMSDLF<SDLF<S:DF<!!!")
        TextPrint(reference, 4, 1)
    end
    return objId
end

function F_SetFirstFloorPedsIntoPOI()
    PedSetActionNode(tFirstFloorTable.gord.id, "/Global/2_08Conv/Idle/PlayerIdle", "Act/Conv/2_08.act")
    PedSetActionNode(tFirstFloorTable.parker.id, "/Global/2_08Conv/Idle/PlayerIdle", "Act/Conv/2_08.act")
    PedSetPOI(tFirstFloorTable.gord.id, POI._2_08_FIRSTFLOORHANG, false)
    PedSetPOI(tFirstFloorTable.parker.id, POI._2_08_FIRSTFLOORHANG, false)
end

function F_SetSecondFloorPedsIntoPOI()
    PedSetActionNode(tSecondFloorTable.tad.id, "/Global/2_08Conv/Idle/PlayerIdle", "Act/Conv/2_08.act")
    PedSetActionNode(tSecondFloorTable.justin.id, "/Global/2_08Conv/Idle/PlayerIdle", "Act/Conv/2_08.act")
    PedSetPOI(tSecondFloorTable.tad.id, POI._2_08_SECONDFLOORHANG, false)
    PedSetPOI(tSecondFloorTable.justin.id, POI._2_08_SECONDFLOORHANG, false)
end

function F_SetThirdFloorPedsIntoPOI()
    PedSetActionNode(tThirdFloorTable.bryce.id, "/Global/2_08Conv/Idle/PlayerIdle", "Act/Conv/2_08.act")
    PedSetActionNode(tThirdFloorTable.chad.id, "/Global/2_08Conv/Idle/PlayerIdle", "Act/Conv/2_08.act")
    PedSetPOI(tThirdFloorTable.bryce.id, POI._2_08_THIRDFLOORHANG, false)
    PedSetPOI(tThirdFloorTable.chad.id, POI._2_08_THIRDFLOORHANG, false)
end

function F_InitializeDestuctiblesInHarrington()
    tDestroyables = {
        { id = 1283794432, ipld = 9821 },
        { id = 1283794432, ipld = 9822 },
        { id = 1824143872, ipld = 9823 },
        { id = 264268704,  ipld = 9824 },
        { id = 264268704,  ipld = 9824 },
        { id = 264560432,  ipld = 9823 },
        { id = 264560432,  ipld = 9823 },
        { id = 264560448,  ipld = 9823 },
        { id = 264268704,  ipld = 9824 }
    }
end

function F_SetupObjectDestroyedCB()
    if AreaGetVisible() == 32 and not bDestructibleSetup then
        bDestructibleSetup = true
        for i, entry in tDestroyables do
            RegisterHashEventHandler(entry.id, 3, OnObjectBrokenCallback)
        end
    end
end

function F_FightingDone()
    local bFightingDone = true
    if bThirdFloorFight and F_AreThirdFloorPrepsAlive() then
        return false
    elseif bSecondFloorFight and F_AreSecondFloorPrepsAlive() then
        return false
    elseif bFirstFloorFight and F_AreFirstFloorPrepsAlive() then
        return false
    end
    return true
end

function F_ObjectDestroyed()
    nTotalObjectsDestroyed = nTotalObjectsDestroyed + 1
end

function F_PlantNotDestroyed()
    if not shared.bWeedPlantIsDestroyed then
        return 1
    end
    return 0
end

local boughtSomething = 0

function F_PlayerHasFancyHaircut()
    local hairMdl = ClothingGetPlayersHair()
    if hairMdl == ObjectNameToHashID("R_GoodBoy_01") or hairMdl == ObjectNameToHashID("R_GoodBoy_02") or hairMdl == ObjectNameToHashID("R_GoodBoy_03") or hairMdl == ObjectNameToHashID("R_GoodBoy_04") or hairMdl == ObjectNameToHashID("R_Hwood_01") or hairMdl == ObjectNameToHashID("R_Hwood_02") or hairMdl == ObjectNameToHashID("R_Hwood_03") or hairMdl == ObjectNameToHashID("R_Hwood_04") or hairMdl == ObjectNameToHashID("R_HThrob_01") or hairMdl == ObjectNameToHashID("R_HThrob_02") or hairMdl == ObjectNameToHashID("R_HThrob_03") or hairMdl == ObjectNameToHashID("R_HThrob_04") or hairMdl == ObjectNameToHashID("R_SShag_01") or hairMdl == ObjectNameToHashID("R_SShag_02") or hairMdl == ObjectNameToHashID("R_SShag_03") or hairMdl == ObjectNameToHashID("R_SShag_04") or hairMdl == ObjectNameToHashID("R_ILeague_01") or hairMdl == ObjectNameToHashID("R_ILeague_02") or hairMdl == ObjectNameToHashID("R_ILeague_03") or hairMdl == ObjectNameToHashID("R_ILeague_04") or hairMdl == ObjectNameToHashID("R_SSmart_01") or hairMdl == ObjectNameToHashID("R_SSmart_02") or hairMdl == ObjectNameToHashID("R_SSmart_03") or hairMdl == ObjectNameToHashID("R_SSmart_04") then
        return true
    end
    return false
end

function F_PlayerHasAquaberryClothing()
    local chestMdl = ClothingGetPlayer(1)
    if chestMdl == ObjectNameToHashID("R_Sweater1") or chestMdl == ObjectNameToHashID("R_Sweater5") then
        return true
    end
    return false
end

function F_PlayerIsWearingHat()
    local index, id = ClothingGetPlayer(0)
    if id == -1 then
        return false
    end
    return true
end
