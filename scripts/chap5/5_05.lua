ImportScript("Library/LibTable.lua")
ImportScript("Library/LibTrigger.lua")
local tblPedModels = {
    123,
    48,
    55,
    141
}
local tblPickupModels = { 412 }
local tblVehicleModels = { 273, 284 }
local bThreads = true
local mission_running = true
local bMissionFailed = false
local stage
local gGuardList = {}
local tblGuardPaths = {}
local gObjectiveBlip = -1
local modelCutters = 487
local modelCuttersWeapon = 412
local bMeatSpotted = false
local nPlayerSpottedByPed, idBoltCutters
local bEndPath = false
local gSprinklerTable = {}
local gDogAttack = false
local idZoe = -1
local idBurton = -1
local PottyPoolIndex, pxCrappyIndex, pxRailIndex, pxRailType
local idMower = -1
local bPottyPushSuccess = false
local nPottyPushText = 1
local bBurtonLeavePotty = false
local bUnBlipPotties = false
local tblDeleteVehicles
local bMissionPassedCreatePotty = false
local bReachedZoe = false
local sprinklerIndex, sprinklerPool, doggyIndex, doggyPool, elseIndex, elsePool
local nMaxZoeUnique = PedGetUniqueModelStatus(48)
local bCleanUpBurton = false
local finalPottyIndex, finalPottyType
local giftType = 20
local giftModel = 497
local objGetBoltCutters, objMeetZoe, objSabotagePotties, objRevenge, objPushPotty, szFailReason, BLIPSTATE_UNOCCUPIED
local BLIPSTATE_OCCUPIED = 1
local BLIPSTATE_DESTROYED = 2
local BLIPSTATE_BLOCKED = 3
local tblPotties = {
    sprinklers = {
        x = 425.196,
        y = 426.149,
        z = 17.3927,
        blipState = BLIPSTATE_UNOCCUPIED,
        blip = nil,
        endPath = PATH._5_05_BURTONCINEMATIC1A,
        dialogue = 13
    },
    doggy = {
        x = 481.04,
        y = 386.96,
        z = 16.0377,
        blipState = BLIPSTATE_UNOCCUPIED,
        blip = nil,
        endPath = PATH._5_05_BURTONCINEMATIC2A,
        dialogue = 9
    },
    hide = {
        x = 411.561,
        y = 355.808,
        z = 16.388,
        blipState = BLIPSTATE_UNOCCUPIED,
        blip = nil,
        endPath = PATH._5_05_BURTONCINEMATIC3A
    }
}
local threadCount = 0

function MissionSetup()
    if not shared.g5_05 then
        PlayCutsceneWithLoad("5-05", true, true)
    end
    ConversationMovePeds(false)
    PedSetUniqueModelStatus(48, -1)
    DisablePOI()
    DATLoad("5_05.DAT", 2)
    DATInit()
    LoadAnimationGroup("Dodgeball")
    LoadAnimationGroup("Dodgeball2")
    LoadAnimationGroup("SAUTH_U")
    LoadAnimationGroup("1_03The Setup")
    LoadAnimationGroup("QPed")
    LoadAnimationGroup("NIS_5_05")
    MissionDontFadeIn()
    PottyPoolIndex, PottyPoolType = CreatePersistentEntity("PortaPoo", 483.007, 267.632, 19.8585, 126.511, 0)
    pxCrappyIndex, _ = CreatePersistentEntity("pxCrappy", 481.582, 268.893, 19.9743, -52.0531, 0)
    pxRailIndex, pxRailType = CreatePersistentEntity("RI1d_railChunk1", 482.443, 266.737, 20.6787, 0, 0)
end

function MissionCleanup()
    local px, py, pz = PlayerGetPosXYZ()
    PickupDestroyTypeInAreaXYZ(px, py, pz, 50, modelCuttersWeapon)
    PickupDestroyTypeInAreaXYZ(px, py, pz, 50, modelCutters)
    PedDestroyWeapon(gPlayer, modelCuttersWeapon)
    ToggleHUDComponentVisibility(20, true)
    if PedIsValid(shared.idDog) then
        PedMakeAmbient(shared.idDog)
        shared.idDog = nil
    end
    PedSetInvulnerable(gPlayer, false)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    CameraReturnToPlayer()
    if not bMissionPassedCreatePotty then
        AreaEnsureSpecialEntitiesAreCreatedWithOverride("5_05", 1)
    end
    if VehicleIsValid(idMower) then
        VehicleMakeAmbient(idMower, false)
    end
    if PedIsValid(idZoe) then
        PedSetFlag(idZoe, 113, false)
        PedSetInvulnerable(idZoe, false)
        PedIgnoreStimuli(idZoe, false)
        PedSetStationary(idZoe, false)
        PedStop(idZoe)
        PedClearObjectives(idZoe)
        PedDestroyWeapon(idZoe, 412)
        PedMakeAmbient(idZoe)
        PedWander(idZoe, 0)
    end
    if PedIsValid(idBurton) and not bCleanUpBurton then
        PedSetInvulnerable(idBurton, false)
        PedStop(idBurton)
        PedClearObjectives(idBurton)
        PedMakeAmbient(idBurton)
        PedWander(idBurton, 0)
    elseif PedIsValid(idBurton) then
        PedDelete(idBurton)
    end
    if PedIsOnVehicle(gPlayer) then
        local x, y, z = PlayerGetPosXYZ()
        --print("DETACH A")
        ToggleHUDComponentVisibility(20, true)
    end
    RemovePlayerItem(487)
    SoundStopInteractiveStream()
    UnLoadAnimationGroup("Dodgeball")
    UnLoadAnimationGroup("Dodgeball2")
    UnLoadAnimationGroup("SAUTH_U")
    UnLoadAnimationGroup("QPed")
    UnLoadAnimationGroup("1_03The Setup")
    UnLoadAnimationGroup("NIS_5_05")
    ConversationMovePeds(true)
    if PottyPoolIndex then
        DeletePersistentEntity(PottyPoolIndex, 5)
    end
    DeletePersistentEntity(pxCrappyIndex, 5)
    if finalPottyIndex then
        DeletePersistentEntity(finalPottyIndex, finalPottyType)
    end
    AreaRevertToDefaultPopulation()
    PedSetUniqueModelStatus(48, nMaxZoeUnique)
    if 0 < table.getn(gSprinklerTable) then
        for i, effect in gSprinklerTable do
            EffectKill(effect)
        end
    end
    if dogThreadCreated then
        gDogAttack = true
    end
    mission_running = false
    DATUnload(2)
    EnablePOI()
end

function F_Debug()
end

function CbInteract(pedid, pathid, nodeid)
    if nodeid == PathGetLastNode(pathid) then
        PedSetActionNode(pedid, "/Global/WProps/PropInteract", "Act/WProps.act")
    end
end

function F_ForceAreaTransitionPoint(map, point)
    AreaForceLoadAreaByAreaTransition(true)
    AreaTransitionPoint(map, point)
    while AreaIsLoading() do
        Wait(0)
    end
    AreaForceLoadAreaByAreaTransition(false)
end

function main()
    AreaEnsureSpecialEntitiesAreCreatedWithOverride("5_05", 2)
    SoundPlayStream("MS_StealthHigh.rsm", 0.5, 0, 1000)
    tblGuardPaths = {
        {
            id = nil,
            path = PATH._5_05_MEAT01
        },
        {
            id = nil,
            path = PATH._5_05_MEAT02
        },
        {
            id = nil,
            path = PATH._5_05_MEAT03
        },
        {
            id = nil,
            path = PATH._5_05_MEAT04
        },
        {
            id = nil,
            path = PATH._5_05_MEAT05
        },
        {
            id = nil,
            path = PATH._5_05_MEAT06
        }
    }
    LoadModels(tblPedModels)
    LoadModels(tblPickupModels)
    LoadVehicleModels(tblVehicleModels)
    LoadActionTree("Act/Conv/5_05.act")
    if IsMissionFromDebug() then
        AreaForceLoadAreaByAreaTransition(true)
    end
    if not shared.g5_05 then
        --print("[5.05] >> Warp to Industrial Area")
        F_ForceAreaTransitionPoint(0, POINTLIST._5_05_PLAYERSPAWN)
    else
        --print("[5.05] >> Warp to Park AND Reset Potties")
        F_ForceAreaTransitionPoint(0, POINTLIST._5_05_BURTONWARP)
    end
    if IsMissionFromDebug() then
        AreaForceLoadAreaByAreaTransition(false)
    end
    if not shared.g5_05 then
        F_Intro()
        StageOneSetup()
        StageOne()
        SoundPlayInteractiveStream("MS_RunningLow.rsm", 0.5)
        SoundSetHighIntensityStream("MS_RunningHigh.rsm", 0.5)
        StageTwoSetup()
        StageTwo()
    elseif shared.g5_05 then
        local x, y, z = PlayerGetPosXYZ()
        F_ClearVehiclesXYZ(x, y, z, 100, 284)
        Wait(500)
        CameraFade(1000, 1)
        AreaClearAllVehicles()
        SoundStopInteractiveStream()
        idBurton = PedCreatePoint(55, POINTLIST._5_05_BURTONSTART, 1)
        PedSetTetherToTrigger(idBurton, TRIGGER._5_05_BURTONTETHER)
        PedSetInfiniteSprint(idBurton, true)
        PedFollowPath(idBurton, PATH._5_05_BURTONMAINPATH, 1, 2)
        idZoe = PedCreatePoint(48, POINTLIST._5_05_ZOEPOTTY, 1)
        PedSetMissionCritical(idZoe, true, cbMissionCritFailure, true)
        PedSetPedToTypeAttitude(idZoe, 13, 3)
        SoundPlayStream("MS_MisbehavingHigh.rsm", 0.5, 0, 1000)
    end
    F_ParkScenario()
    L_StopMonitoringTriggers()
    if not bMissionFailed then
        if PottyPoolIndex then
            DeletePersistentEntity(PottyPoolIndex, 5)
        end
        --print("DETACH B")
        PlayerDetachFromVehicle()
        ToggleHUDComponentVisibility(20, true)
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        MusicAllowPlayDuringCutscenes(true)
        PedSetMissionCritical(idZoe, false)
        if PedIsValid(idZoe) then
            PedDelete(idZoe)
        end
        UnLoadAnimationGroup("Dodgeball")
        UnLoadAnimationGroup("Dodgeball2")
        UnLoadAnimationGroup("SAUTH_U")
        UnLoadAnimationGroup("1_03The Setup")
        UnLoadAnimationGroup("QPed")
        UnLoadAnimationGroup("NIS_5_05")
        UnloadModels(tblPedModels)
        UnloadModels(tblPickupModels)
        UnloadModels(tblVehicleModels)
        PlayCutsceneWithLoad("5-05B", true, true, true, true)
        PlayerSetControl(0)
        MusicAllowPlayDuringCutscenes(false)
        AreaEnsureSpecialEntitiesAreCreatedWithOverride("5_05", 4)
        Wait(100)
        finalPottyIndex, finalPottyType = CreatePersistentEntity("rc2d_PortaPoo_A", 473.144, 260.006, 13.0302, 1.00179E-5, 0)
        LoadModels({ 55, 48 })
        idBurton = PedCreatePoint(55, POINTLIST._5_05_BURTONPOOPED, 1)
        PlayerSetPosPoint(POINTLIST._5_05_PLAYERAFTERPUSH)
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        PedFollowPath(idBurton, PATH._5_05_BURTONPOOPED, 0, 2)
        Wait(500)
        local x1, y1, z1 = PedGetOffsetInWorldCoords(gPlayer, 0.5, 1, 1.2)
        local x2, y2, z2 = PedGetOffsetInWorldCoords(gPlayer, -0.5, -0.7, 1.7)
        CameraSetXYZ(x1, y1, z1, x2, y2, z2)
        CameraFade(500, 1)
        Wait(501)
        PedSetActionNode(gPlayer, "/Global/5_05/Success", "Act/Conv/5_05.act")
        MinigameSetCompletion("M_PASS", true, 3000)
        SoundPlayMissionEndMusic(true, 4)
        Wait(2000)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        bMissionPassedCreatePotty = true
        CameraFade(500, 0)
        Wait(501)
        CameraReturnToPlayer(true)
        MissionSucceed(true, false, false)
    else
        SoundPlayMissionEndMusic(false, 4)
        if szFailReason then
            if szFailReason == "5_05_FAILPOT" then
                MissionFail(true, true, szFailReason)
                Wait(3000)
            else
                MissionFail(false, true, szFailReason)
            end
        else
            MissionFail()
        end
    end
end

function F_TerminateThread(threadName)
    threadCount = threadCount - 1
    --print(threadCount, " <<<<<<<<<<<< THREADS REMAINING - ", threadName, " FINISHED ITS TASKS ")
end

function F_InitThread(threadName)
    threadCount = threadCount + 1
    CreateThread(threadName)
    --print(threadCount, " <<<<<<<<<<<<< THREADS CREATED ", threadName)
end

function F_WaitForNextStage()
end

function F_SetupTriggers()
    L_AddTrigger("triggers", {
        trigger1 = {
            trigger = TRIGGER._5_05_SPRINKLERTRIG01,
            InTrigger = F_CheckSprinkler01,
            ped = gPlayer,
            bTriggerOnlyOnce = false
        },
        trigger2 = {
            trigger = TRIGGER._5_05_SPRINKLERTRIG02,
            InTrigger = F_CheckSprinkler02,
            ped = gPlayer,
            bTriggerOnlyOnce = false
        },
        trigger3 = {
            trigger = TRIGGER._5_05_SPRINKLERTRIG03,
            InTrigger = F_CheckSprinkler03,
            ped = gPlayer,
            bTriggerOnlyOnce = false
        },
        trigger4 = {
            trigger = TRIGGER._5_05_ZOETRIGGERPARK,
            InTrigger = F_ZoeRichArea,
            ped = gPlayer,
            bTriggerOnlyOnce = false
        }
    })
end

function F_CreateGuard(model, pointlist, pointNo, pedType)
    local tPed = PedCreatePoint(model, pointlist, pointNo)
    PedSetIsStealthMissionPed(tPed, true)
    PedSetStealthBehavior(tPed, 0, F_KickPlayerOut)
    PedOverrideStat(tPed, 3, 13)
    PedOverrideStat(tPed, 2, 60)
    PedClearAllWeapons(tPed)
    table.insert(gGuardList, { gId = tPed, pedType = pedType })
    return tPed
end

function F_KickPlayerOut(pedid)
    if PedIsValid(pedid) then
        nPlayerSpottedByPed = pedid
    end
end

function F_Intro()
    PlayerSetControl(0)
    CameraFade(1000, 1)
    PlayerSetControl(1)
    TextPrint("5_05_OGETBOLT", 3, 1)
    objGetBoltCutters = MissionObjectiveAdd("5_05_OGETBOLT")
    stage = StageOneSetup
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
    if bAmbient then
        SoundPlayAmbientSpeechEvent(pedId, strEvent)
        while SoundSpeechPlaying() do
            Wait(0)
        end
    else
        SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
        while SoundSpeechPlaying() do
            Wait(0)
        end
    end
    return false
end

function StageOneSetup()
    idBoltCutters = PickupCreatePoint(modelCutters, POINTLIST._5_05_BOLTCUTTERS, 1, 0, "PermanentButes")
    Wait(500)
    gObjectiveBlip = BlipAddPoint(POINTLIST._5_05_BOLTCUTTERS, 0, 1, 4)
    Wait(200)
    stage = StageOne
end

function StageOne()
    local pass = false
    local gGetCuttersMsg = false
    while not pass do
        Wait(0)
        if not gGetCuttersMsg and PlayerIsInTrigger(TRIGGER._5_05_ALLEY) then
            gGetCuttersMsg = true
            MissionObjectiveComplete(objGetBoltCutters)
            objGetBoltCutters = MissionObjectiveAdd("5_05_OGETCUTS")
            TextPrint("5_05_OGETCUTS", 4, 1)
        end
        if PickupIsPickedUp(idBoltCutters) then
            --print("Got Boltcutters")
            MissionObjectiveComplete(objGetBoltCutters)
            TextPrint("5_05_17", 3, 1)
            objMeetZoe = MissionObjectiveAdd("5_05_OMEETZOE")
            BlipRemove(gObjectiveBlip)
            pass = true
            if not PlayerHasItem(modelCutters) then
                GiveItemToPlayer(modelCutters, 1)
            end
        end
    end
end

function StageTwoSetup()
    local x, y, z = GetPointList(POINTLIST._5_05_BURTONSTART)
    if not PlayerIsInTrigger(TRIGGER._5_05_FACTORYAREA) then
    end
    if gCheckingDoorDone then
        PedClearObjectives(tblGuardPaths[4].id)
        PedStop(tblGuardPaths[4].id)
        Wait(500)
        PedFollowPath(tblGuardPaths[4].id, PATH._5_05_MEAT04, 3, 0)
        gCheckingDoorDone = nil
    end
    stage = StageTwo
end

function StageTwo()
    local bZoeGotCutters = false
    idZoe = PedCreatePoint(48, POINTLIST._5_05_ZOESTART, 1)
    PedSetFlag(idZoe, 113, true)
    PedSetPedToTypeAttitude(idZoe, 13, 3)
    PedIgnoreStimuli(idZoe, true)
    PedIgnoreAttacks(idZoe, true)
    PedSetStationary(idZoe, true)
    gObjectiveBlip = AddBlipForChar(idZoe, 12, 0, 1)
    PedSetMissionCritical(idZoe, true, cbMissionCritFailure, true)
    PedSetPosPoint(idZoe, POINTLIST._5_05_ZOESTART)
    PedSetPedToTypeAttitude(idZoe, 13, 3)
    while not PlayerIsInTrigger(TRIGGER._AMB_RICH_AREA) do
        if PlayerIsInAreaObject(idZoe, 2, 2, 0, 0) then
        end
        Wait(0)
    end
    idBurton = PedCreatePoint(55, POINTLIST._5_05_BURTONSTART, 1)
    PedSetTetherToTrigger(idBurton, TRIGGER._5_05_BURTONTETHER)
    PedSetInfiniteSprint(idBurton, true)
    PedFollowPath(idBurton, PATH._5_05_BURTONMAINPATH, 1, 2)
    PedSetPosPoint(idZoe, POINTLIST._5_05_ZOESTART)
    Wait(500)
    PedOverrideSocialResponseToStimulus(idZoe, 28, 4)
    if not PlayerHasItem(modelCutters) then
        GiveItemToPlayer(modelCutters, 1)
    end
    while not PlayerIsInAreaObject(idZoe, 2, 3, 0, 0) and PlayerHasItem(modelCutters) do
        Wait(0)
    end
    if not bMissionFailed then
        F_GiveZoeCuttersNIS()
        PedDestroyWeapon(idZoe, modelCuttersWeapon)
    end
    stage = StageThreeRemake
    Wait(100)
    BlipRemove(gObjectiveBlip)
    gObjectiveBlip = nil
    MissionObjectiveComplete(objMeetZoe)
    PedFollowPath(idZoe, PATH._5_05_ZOEHIDE, 0, 1)
end

function socWantGift()
    --print("[5.05] >>>>", "socWantGift")
end

function socFollow()
    --print("[5.05] >>>>", "socFollow")
end

function F_GiveZoeCuttersNIS()
    shared.g5_05 = 1
    SoundPlayStream("MS_5-05_MeetZoe_NIS.rsm", 0.4, 1000, 500)
    PedSetInvulnerable(idZoe, true)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    F_ForcePlayerDismountBike()
    PedSetActionNode(idZoe, "/Global/5_05/NIS/Zoe/ZoeIdle", "Act/Conv/5_05.act")
    PedSetFlag(idZoe, 113, false)
    PedSetInvulnerable(idZoe, false)
    PedIgnoreStimuli(idZoe, false)
    PedIgnoreAttacks(idZoe, false)
    PedSetStationary(idZoe, false)
    PedStop(idZoe)
    PedClearObjectives(idZoe)
    PedFaceObject(gPlayer, idZoe, 2, 1)
    PedFaceObject(idZoe, gPlayer, 3, 1)
    PedLockTarget(gPlayer, idZoe, 3)
    Wait(500)
    PedSetInvulnerable(idZoe, false)
    CameraSetFOV(70)
    CameraSetXYZ(489.68997, 274.44092, 23.409494, 488.9158, 274.0159, 22.940704)
    CameraLookAtObject(gPlayer, 3, true, 0.5)
    PedSetActionNode(idZoe, "/Global/5_05/NIS/Zoe/Zoe01", "Act/Conv/5_05.act")
    F_PlaySpeechWait(idZoe, "M_5_05", 3, "jumbo")
    PedSetActionNode(gPlayer, "/Global/5_05/NIS/Player/Player01", "Act/Conv/5_05.act")
    F_PlaySpeechWait(gPlayer, "M_5_05", 4, "jumbo")
    CameraSetFOV(40)
    CameraSetXYZ(488.47, 275.47244, 21.59046, 487.88367, 274.6648, 21.529163)
    PedSetActionNode(idZoe, "/Global/5_05/NIS/Zoe/Zoe02", "Act/Conv/5_05.act")
    F_PlaySpeechWait(idZoe, "M_5_05", 5, "jumbo")
    Wait(500)
    PedLockTarget(gPlayer, idZoe, 3)
    PedSetActionNode(gPlayer, "/Global/5_05/NIS/Give/GiveZoe_5_05/Give_Attempt", "Act/Conv/5_05.act")
    while PedIsPlaying(gPlayer, "/Global/5_05/NIS/Give/GiveZoe_5_05", true) do
        Wait(0)
    end
    Wait(1750)
    PedSetActionNode(idZoe, "/Global/5_05/NIS/Zoe/Zoe03", "Act/Conv/5_05.act")
    F_PlaySpeechWait(idZoe, "M_5_05", 6, "jumbo")
    PedSetActionNode(idZoe, "/Global/5_05/NIS/Zoe/ZoeIdle", "Act/Conv/5_05.act")
    CameraSetFOV(40)
    CameraSetXYZ(482.6726, 269.51935, 22.598248, 483.3498, 270.1553, 22.228931)
    CameraLookAtObject(gPlayer, 3, true, 0.5)
    PedSetActionNode(gPlayer, "/Global/5_05/NIS/Player/Player02", "Act/Conv/5_05.act")
    F_PlaySpeechWait(gPlayer, "M_5_05", 7, "jumbo")
    PedMakeTargetable(idZoe, false)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    CameraDefaultFOV()
    CameraReturnToPlayer(true)
    CameraSetWidescreen(false)
    PedSetActionNode(idZoe, "/Global/5_05/Blank", "Act/Conv/5_05.act")
    SoundPlayInteractiveStream("MS_MisbehavingHigh.rsm", 0.5, 0, 500)
end

function F_ForcePlayerDismountBike()
    local nTimer = GetTimer()
    while PedIsOnVehicle(gPlayer) and GetTimer() - nTimer < 15000 do
        Wait(0)
        PlayerDismountBike()
        Wait(3000)
    end
    Wait(1000)
    if PedIsInAnyVehicle(gPlayer) then
        CameraFade(500, 0)
        Wait(505)
        local idVeh = VehicleFromDriver(gPlayer)
        PlayerDetachFromVehicle()
        VehicleDelete(idVeh)
        Wait(100)
        CameraFade(500, 1)
    end
end

function cbReachedZoe()
    bReachedZoe = true
end

function F_ParkScenario()
    local nTimeLeft = 90
    local blipDog, blipPottySprink, blipPottyDog, blipPottyHide
    shared.idDog = PedCreatePoint(141, POINTLIST._5_05_PPDOG, 1)
    local loop1 = true
    PedSetActionNode(shared.idDog, "/Global/5_05/Dog/Initialize", "Act/Conv/5_05.act")
    CreateThread("T_PottyBlipManager")
    CreateThread("T_ParkOut")
    objSabotagePotties = MissionObjectiveAdd("5_05_OSABPOT")
    TextPrint("5_05_SABOTAGE", 4, 1)
    MissionTimerStart(nTimeLeft)
    while not (tblPotties.sprinklers.blipState and tblPotties.doggy.blipState and tblPotties.hide.blipState) do
        if shared.gParkSprinklers then
            if tblPotties.sprinklers.blipState ~= BLIPSTATE_DESTROYED then
                tblPotties.sprinklers.blipState = BLIPSTATE_BLOCKED
            end
        elseif not shared.gParkSprinklers and tblPotties.sprinklers.blipState == BLIPSTATE_BLOCKED then
            tblPotties.sprinklers.blipState = BLIPSTATE_UNOCCUPIED
        end
        if MissionTimerHasFinished() then
            bMissionFailed = true
            SoundPlayMissionEndMusic(false, 4)
            MissionFail(false, true, "5_05_FAILRUN")
            break
        end
        Wait(0)
    end
    MissionObjectiveComplete(objSabotagePotties)
    MissionTimerStop()
    gObjectiveBlip = AddBlipForChar(idZoe, 12, 0, 4)
    TextPrint("5_05_MEETZOE2", 4, 1)
    local objective = MissionObjectiveAdd("5_05_MEETZOE2")
    while not PlayerIsInAreaObject(idZoe, 2, 8, 0) do
        Wait(0)
    end
    PedSetInvulnerable(idZoe, true)
    if not bMissionFailed then
        F_CheckNIS()
        --print("ZOE: Finished Cut")
        PedFaceObjectNow(idZoe, gPlayer, 3)
        MissionObjectiveComplete(objective)
        objPushPotty = MissionObjectiveAdd("5_05_OPUSHPOT")
        TextPrint("5_05_OPUSHPOT", 4, 1)
        BlipRemove(gObjectiveBlip)
        gObjectiveBlip = AddBlipForCar(idMower, 0, 4)
        local bZoeRunAway = false
        local blipLastPotty
    end
    while mission_running do
        F_FinalPottyPushCheck()
        if not bZoeRunAway and PlayerIsInTrigger(TRIGGER._5_05_RUNAWAYZOE) and PlayerIsInAnyVehicle() and VehicleIsModel(VehicleFromDriver(gPlayer), 284) then
            PedFollowPath(idZoe, PATH._5_05_ZOERUNAWAY, 0, 1, cbFacePlayer)
            bZoeRunAway = true
            PedDestroyWeapon(idZoe, modelCuttersWeapon)
        end
        if PedIsInVehicle(gPlayer, idMower) and gObjectiveBlip then
            BlipRemove(gObjectiveBlip)
            gObjectiveBlip = nil
            blipLastPotty = BlipAddPoint(POINTLIST._5_05_PPFINAL, 0)
        elseif blipLastPotty and not PedIsInVehicle(gPlayer, idMower) then
            BlipRemove(blipLastPotty)
            blipLastPotty = nil
            gObjectiveBlip = AddBlipForCar(idMower, 0, 4)
        end
        Wait(0)
    end
    if bPottyPushSuccess then
        MissionTimerStop()
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(true)
        Wait(50)
        PedSetInvulnerable(gPlayer, true)
        CameraFade(500, 0)
        Wait(501)
        F_MakePlayerSafeForNIS(true, true, true, false)
        SoundPreloadStreamNoLoop("5-05_NIS_PottyFall.rsm", 1, 0, 500)
        Wait(500)
        while not SoundIsPreloadReady() do
            Wait(0)
        end
        CameraFade(500, 1)
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        BlipRemove(gObjectiveBlip)
        MissionObjectiveComplete(objPushPotty)
        PedDelete(idBurton)
        CameraLookAtPathSetSpeed(22, 13, 19)
        CameraSetPath(PATH._5_05_CINPOTTY, true)
        CameraLookAtPath(PATH._5_05_CINPOTTYTARGET, true)
        MusicFadeWithCamera(false)
        SoundPlayPreloadedStream()
        PAnimSetActionNode("PortaPoo", 483.007, 267.632, 19.8585, 2, "/Global/StealthDoor/Falldown", "Act/Props/StealthDoor.act")
        Wait(3500)
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        CameraFade(1000, 0)
        Wait(1001)
        PedSetInvulnerable(gPlayer, false)
        CameraSetWidescreen(false)
        F_MakePlayerSafeForNIS(false)
    end
end

function F_AlphaBurtonOff()
end

function F_AlphaBurton()
end

function T_ParkOut()
    while mission_running do
        if not PlayerIsInTrigger(TRIGGER._5_05_PARK) then
            if not PlayerIsInTrigger(TRIGGER._5_05_PARKOUT) then
                mission_running = false
                bMissionFailed = true
                szFailReason = "5_05_LEFTPARK"
                SoundPlayMissionEndMusic(false, 4)
                if szFailReason then
                    MissionFail(false, true, szFailReason)
                else
                    MissionFail()
                end
                Wait(50000)
            else
                TextPrint("5_05_RETPARK", 0.1, 1)
            end
        end
        Wait(0)
    end
end

function T_PottyBlipManager()
    for i, entry in tblPotties do
        PAnimSetActionNode("PortaPoo", entry.x, entry.y, entry.z, 2, "/Global/StealthDoor", false)
    end
    while MissionActive() do
        for i, entry in tblPotties do
            if entry.blipState ~= BLIPSTATE_UNOCCUPIED then
                if entry.blip then
                    BlipRemove(entry.blip)
                    entry.blip = nil
                end
                if entry.blipState == BLIPSTATE_OCCUPIED and PAnimIsPlaying("PortaPoo", entry.x, entry.y, entry.z, 2, "/Global/StealthDoor/Unoccupied", false) then
                    entry.blipState = BLIPSTATE_UNOCCUPIED
                end
            elseif entry.blipState == BLIPSTATE_UNOCCUPIED then
                if not entry.blip then
                    entry.blip = BlipAddXYZ(entry.x, entry.y, entry.z, 0)
                end
                if PAnimGetHealth("PortaPoo", entry.x, entry.y, entry.z) < 1 or PAnimIsPlaying("PortaPoo", entry.x, entry.y, entry.z, 2, "/Global/StealthDoor/NotUseable/Damaged", true) then
                    entry.blipState = BLIPSTATE_DESTROYED
                    --print(">>>>  Potty Destroyed")
                end
                if PAnimIsPlaying("PortaPoo", entry.x, entry.y, entry.z, 2, "/Global/StealthDoor/Occupied", false) then
                    entry.blipState = BLIPSTATE_OCCUPIED
                end
            end
        end
        Wait(0)
    end
end

function F_FinalPottyPushCheck()
    if PlayerIsInTrigger(TRIGGER._5_05_LASTPOTTY) and PlayerIsInAnyVehicle() and VehicleIsModel(VehicleFromDriver(gPlayer), 284) then
        MissionTimerStop()
        bPottyPushSuccess = true
        SoundPlay2D("PortaCrash")
        mission_running = false
    end
    if bBurtonLeavePotty or MissionTimerHasFinished() then
        CameraFade(500, 0)
        CameraSetWidescreen(true)
        Wait(505)
        ToggleHUDComponentVisibility(20, true)
        PlayerSetControl(0)
        PedSetInvulnerable(gPlayer, true)
        Wait(100)
        CameraFade(500, 1)
        CameraLookAtObject(idBurton, 2, true, 1)
        CameraSetPath(PATH._5_05_BURTONCINPOTTY, true)
        bMissionFailed = true
        mission_running = false
    end
end

function T_PottyOccupiedCheck()
    while MissionActive() do
        for i, entry in tblPotties do
            if PedIsPlaying(gPlayer, "/Global/StealthDoor/PedPropsActions", true) and PedIsInAreaXYZ(gPlayer, entry[2], entry[3], entry[4], 5, 0) then
                tblPotties[i].occupied = true
                --print("[JASON] ========> Potty Index ** " .. i .. " ** is occupied.")
            end
        end
        Wait(0)
    end
end

function StageThreeRemake()
end

function F_PottyCheckOccupied(tblPotty)
    if not bUnBlipPotties and not tblPotty.blocked and not tblPotty.broke then
        local x, y, z = tblPotty[2], tblPotty[3], tblPotty[4]
        if tblPotty.blip then
            if PlayerIsInAreaXYZ(x, y, z, 4, 0) and PedIsPlaying(gPlayer, "/Global/StealthDoor/PedPropActions/Unoccupied/NoAuthorityInView/RunInside/CloseDoor/WaitInside", true) then
                tblPotty.blip = nil
                tblPotty.occupied = true
            end
        elseif not PedIsPlaying(gPlayer, "/Global/StealthDoor/PedPropActions/Unoccupied/NoAuthorityInView", true) then
            --print("[JASON] ============>  F_PottyCheckOccupied: ADDBLIP!")
            if tblPotty.blocked then
                --print("THIS POTTY BLOCKED")
            else
                --print("THIS POTTY NOT BLOCKED??")
            end
            tblPotty.occupied = false
        end
        if PAnimIsPlaying(tblPotty[1], x, y, z, 2, "/Global/StealthDoor/NotUseable/Damaged", false) then
            tblPotty.broke = true
            tblPotty.blip = nil
        end
    end
end

function F_ClearVehiclesXYZ(x, y, z, prox, model)
    tblDeleteVehicles = VehicleFindInAreaXYZ(x, y, z, prox, false)
    --print("[F_ClearVehiclesXYZ] >> Table: ", tostring(tblDeleteVehicles))
    if tblDeleteVehicles then
        for i, entry in tblDeleteVehicles do
            if VehicleIsValid(entry) then
                if not model then
                    VehicleDelete(entry)
                elseif VehicleIsModel(entry, model) then
                    VehicleDelete(entry)
                end
            end
        end
    end
    tblDeleteVehicles = nil
end

function F_DeleteUnusedVehicles(x, y, z, radius)
    local tblFoundPeds = {}
    local tblFoundVehicles = {}
    tblFoundPeds = {
        PedFindInAreaXYZ(x, y, z, radius)
    }
    tblFoundVehicles = VehicleFindInAreaXYZ(x, y, z, radius, false)
    --print(tostring(tblFoundPeds), tostring(tblFoundVehicles))
    if tblFoundVehicles then
        for i, vehicle in tblFoundVehicles do
            local bDelete = true
            for _, ped in tblFoundPeds do
                --print("TESTING VEHICLE", i, "PED", _)
                if PedIsValid(ped) and PedIsInVehicle(ped, vehicle) then
                    --print("TESTING VEHICLE", i, "PED", _, "** PASSED **, detaching ped from Vehicle!")
                    PlayerDetachFromVehicle()
                    bDelete = true
                end
            end
            if bDelete then
                --print("DELETING VEHICLE", i)
                VehicleDelete(vehicle)
            end
        end
    end
end

function CbStealthBehaviour(pedID)
    bMeatSpotted = pedID
end

function CbCheckDoor(pedId, pathId, pathNode)
    --print(" CHECKING ", pathNode)
    if pathNode == 1 then
        if not bFirstTime then
            bFirstTime = true
            --print(" CHECKING FIRST TIME")
        else
            --print(" CHECKING FIRST SECOND TIME")
            gCheckingDoorDone = true
        end
    elseif pathNode == 5 then
    end
end

function DrvToiletSplode(param)
    --print("[JASON] ============> DrvToiletSplode: Creating Effect")
    --print("[JASON] ============> DrvToiletSplode: Killing Effect")
end

function CbStealthBurton(pedID)
    if mission_running then
        TextPrint("5_05_BURTSPOT", 4, 2)
        mission_running = false
        bMissionFailed = true
    end
end

function drvLiftText(param)
    if nPottyPushText then
        if param == 1 then
            TextPrint("5_05_PUSH2", 4, 2)
        elseif param == 2 then
            TextPrint("5_05_PUSH3", 4, 2)
            nPottyPushText = nil
        end
    end
end

function drvBurtonLeavePotty(param)
    --print("[drvBurtonLeavePotty] >> Setting Mission to Fail")
    bBurtonLeavePotty = true
    szFailReason = "5_05_FAILPOT"
end

function cbPottyPushed()
    --print("[cbPottyPushed] =====> TRUE")
    bPottyPushSuccess = true
end

function CbBurtonEnd(pedid, pathid, nodeid)
    if nodeid == PathGetLastNode(pathid) then
        cbBurtonNextStep = true
    end
end

function CbCut(pedid, pathid, nodeid)
    if nodeid == PathGetLastNode(pathid) then
        PedSetActionNode(pedid, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
    end
end

function cbReachedEnd(pedid, pathid, nodeid)
    if nodeid then
        if nodeid == PathGetLastNode(pathid) then
            bEndPath = true
        end
    else
        bEndPath = true
    end
end

function cbMissionCritFailure()
    if idZoe and PedIsValid(idZoe) then
        PedSetInvulnerable(idZoe, false)
        PedSetFlag(idZoe, 113, false)
        PedSetStationary(idZoe, false)
        PedIgnoreStimuli(idZoe, false)
        PedMakeAmbient(idZoe)
    end
    if not bMissionFailed then
        mission_running = false
        bMissionFailed = true
        szFailReason = "5_05_FAILHITZOE"
        bCleanUpBurton = true
        --print("FAILED BY MISSION CRIT PED")
        SoundPlayMissionEndMusic(false, 4)
        MissionFail(false, true, szFailReason)
    end
end

function cbUseProp(pedid, pathid, nodeid)
    if nodeid == PathGetLastNode(pathid) then
        PedSetActionNode(pedid, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
    end
end

function cbFacePlayer(pedid, pathid, nodeid)
    PedFaceObjectNow(idZoe, gPlayer, 3)
end

local gTextQueue = {}
local gTextQueueTimer = 0
local gTextWaitTimer = 0
local gStartPrinting = false

function TextQueue(val, tTime, style, isText, priority)
    if table.getn(gTextQueue) <= 0 then
        gStartPrinting = true
    end
    if priority then
        table.insert(gTextQueue, 1, {
            textVal = val,
            textTime = tTime,
            bText = isText,
            tStyle = style
        })
    else
        table.insert(gTextQueue, {
            textVal = val,
            textTime = tTime,
            bText = isText,
            tStyle = style
        })
    end
end

function F_PedIsHurt(pedid)
    if PedIsValid(pedid) then
        if PedGetHealth(pedid) < PedGetMaxHealth(pedid) then
            return true
        end
    else
        return false
    end
end

function F_CheckNIS()
    local nTimeSlice = 0
    PAnimSetActionNode("PortaPoo", 483.007, 267.632, 19.8585, 2, "/Global/StealthDoor/Mission505/Idle", "Act/Props/StealthDoor.act")
    if PedIsValid(idBurton) then
        PedClearTether(idBurton)
    end
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    local px, py, pz = GetPointList(POINTLIST._5_05_MOWER)
    F_DeleteUnusedVehicles(483, 267.5, 20.6, 6)
    F_DeleteUnusedVehicles(px, py, pz, 10)
    while not VehicleRequestModel(284) do
        Wait(0)
    end
    ObjectRemovePickupsInTrigger(TRIGGER._5_05_CLEARMOWER)
    --print("CREATED MOWER")
    idMower = VehicleCreatePoint(284, POINTLIST._5_05_MOWER)
    SoundSetAudioFocusCamera()
    if PedIsValid(shared.idDog) then
        PedDelete(shared.idDog)
    end
    if not PedIsValid(idBurton) then
        idBurton = PedCreatePoint(55, POINTLIST._5_05_CHECKPOT1, 1)
        PedAlwaysUpdateAnimation(idBurton, true)
    else
        PedDelete(idBurton)
        idBurton = PedCreatePoint(55, POINTLIST._5_05_CHECKPOT1, 1)
        PedSetPosPoint(idBurton, POINTLIST._5_05_CHECKPOT1)
        PedAlwaysUpdateAnimation(idBurton, true)
    end
    if not PedIsValid(idZoe) then
        idZoe = PedCreatePoint(48, POINTLIST._5_05_CHECKPOT2, 2)
    else
        PedSetPosPoint(idZoe, POINTLIST._5_05_CHECKPOT2, 2)
    end
    CameraSetXYZ(476.1362, 391.63004, 17.436625, 476.62936, 390.76035, 17.417648)
    CameraLookAtObject(idBurton, 2, true, 1)
    SoundPlayInteractiveStream("MS_FunLow.rsm", 0.5, 0, 500)
    SoundSetMidIntensityStream("MS_FunMid.rsm", 0.5, 0, 500)
    SoundSetHighIntensityStream("MS_FunHigh.rsm", 0.5, 0, 500)
    SoundPlayScriptedSpeechEvent(idBurton, "M_5_05", 11, "supersize")
    --print("DETACH D")
    PlayerDetachFromVehicle()
    ToggleHUDComponentVisibility(20, true)
    PlayerSetPosPoint(POINTLIST._5_05_CHECKPOT2)
    PedSetWeapon(idZoe, 412, 1)
    PedFollowPath(idBurton, PATH._5_05_CHECKPOT1, 0, 1, cbReachedEnd)
    nTimeSlice = GetTimer()
    while not bEndPath and GetTimer() - nTimeSlice < 10000 do
        Wait(0)
    end
    bEndPath = false
    PedSetActionNode(idBurton, "/Global/5_05/BurtonReactions/BurtonPeeDance", "Act/Conv/5_05.act")
    while not bEndPath and GetTimer() - nTimeSlice < 10000 do
        Wait(0)
    end
    bEndPath = false
    PedSetActionNode(idZoe, "/Global/5_05/Blank", "Act/Conv/5_05.act")
    CameraSetFOV(80)
    CameraSetXYZ(483.14313, 277.39093, 20.41725, 482.1863, 277.19214, 20.629347)
    PedSetPosPoint(idBurton, POINTLIST._5_05_BURTONWARP)
    PedSetActionNode(idBurton, "/Global/5_05/Blank", "Act/Conv/5_05.act")
    PedStop(idBurton)
    PedClearObjectives(idBurton)
    PedFollowPath(idBurton, PATH._5_05_BURTONRUNLAST, 0, 1, cbReachedEnd)
    while not bEndPath do
        Wait(0)
    end
    bEndPath = false
    CameraSetXYZ(484.6608, 272.67795, 20.88983, 484.3478, 271.73123, 20.965149)
    PedSetActionNode(idBurton, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
    SoundPlayScriptedSpeechEvent(idBurton, "M_5_05", 20, "supersize")
    PedIgnoreStimuli(idBurton, true)
    PedSetInvulnerable(idBurton, true)
    PedFollowPath(idZoe, PATH._5_05_ZOECUT, 0, 1, cbReachedEnd)
    while not bEndPath do
        Wait(0)
    end
    bEndPath = false
    Wait(1000)
    PedSetInvulnerable(idZoe, false)
    PedSetActionNode(idZoe, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
    DeletePersistentEntity(pxRailIndex, pxRailType)
    MissionTimerStart(30)
    CameraDefaultFOV()
    PlayerFaceHeadingNow(180)
    CameraReturnToPlayer()
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    SoundSetAudioFocusPlayer()
end

function drvDogAttack()
    if PedIsValid(shared.idDog) then
        PedAttackPlayer(shared.idDog, 0)
    end
    --print("[5.05] >> Dog Attack!")
end
