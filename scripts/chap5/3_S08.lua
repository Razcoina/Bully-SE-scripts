local MISSION_RUNNING = 0
local MISSION_PASS = 1
local MISSION_FAIL = 2
local gMissionState
local gCurrentTier = 1
local MAILBOXES_CREATE = 0
local MAILBOXES_DELETE = 1
local gMailboxesSmashed = 0
local gMissionTime = 0
local gMailBoxes = {}
local gMinMailboxes = 0
local gDifficulty = 2
local gCurrentState = 0
local gMinRideTime = 2 * 60
local gBike, gDogHazards, bDogHazardsCreated
local bMissionDone = false

function F_MailboxSmash_Intro()
    --print(">>>[RUI]", "!!NIS_Intro")
    F_MakePlayerSafeForNIS(true)
    F_SetupMailboxes(gCurrentTier)
    CameraSetXYZ(283.34317, -460.46704, 5.451378, 284.2813, -460.8025, 5.366951)
    if PlayerIsInAnyVehicle() then
        local bike = VehicleFromDriver(gPlayer)
        PlayerDetachFromVehicle()
        VehicleDelete(bike)
    end
    gBike = VehicleCreatePoint(281, POINTLIST._3_S08_BIKESTART)
    PlayCutsceneWithLoad("3-S08", true)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    CameraDefaultFOV()
    if not gBike then
        gBike = VehicleCreatePoint(281, POINTLIST._3_S08_BIKESTART)
    end
    AreaTransitionPoint(0, POINTLIST._3_S08_BIKESTART)
    PedSetWeaponNow(gPlayer, 300, 1, false)
    F_MailBoxesInit()
    Wait(500)
    PlayerPutOnBike(gBike)
    while not PlayerIsInVehicle(gBike) do
        Wait(0)
    end
    Wait(500)
end

function F_MailboxSmash_End()
    --print(">>>[RUI]", "!!NIS_End")
    PedDestroyWeapon(gPlayer, 300)
    F_MakePlayerSafeForNIS(true)
    PlayerSetControl(0)
    F_MailboxHud(false)
    CameraFade(500, 0)
    Wait(500)
    if PlayerIsInAnyVehicle() then
        local bike = VehicleFromDriver(gPlayer)
        PlayerDetachFromVehicle()
        VehicleDelete(bike)
    end
    gEdgar = PedCreatePoint(45, POINTLIST._3_S08_SCENEPLAYER)
    PedSetEmotionTowardsPed(gEdgar, gPlayer, 8)
    AreaTransitionPoint(0, POINTLIST._3_S08_SCENEEDGER)
    PedSetEffectedByGravity(gEdgar, false)
    Wait(100)
    PedSetEffectedByGravity(gPlayer, false)
    Wait(200)
    PedFaceObjectNow(gPlayer, gEdgar, 2)
    PedFaceObjectNow(gEdgar, gPlayer, 2)
    Wait(100)
    CameraSetWidescreen(true)
    CameraSetXYZ(288.3408, -461.30362, 6.196917, 287.37122, -461.3564, 5.959265)
    CameraSetWidescreen(true)
    CameraSetFOV(70)
    Wait(2000)
    CameraFade(500, 1)
    Wait(500)
    SoundPlayScriptedSpeechEvent(gEdgar, "M_3_S08", 0, "supersize")
    Wait(500)
    PedIgnoreStimuli(gEdgar, true)
    PedSetAsleep(gEdgar, true)
    Wait(3000)
    F_PlaySpeechAndWait(gPlayer, "M_3_S08", 0, "supersize")
    Wait(2000)
    PlayerSetControl(1)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(700)
    PedDestroyWeapon(gPlayer, 300)
    Wait(100)
    CameraFade(500, 1)
    SoundPlayMissionEndMusic(true, 8)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraSetWidescreen(false)
    MissionSucceed(false, false, false)
    MinigameSetCompletion("M_PASS", true, 2000)
    PedSetEffectedByGravity(gPlayer, true)
    PedDelete(gEdgar)
    CameraReset()
    CameraReturnToPlayer()
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    CameraDefaultFOV()
end

function F_SetupMailboxes(tier)
    --print(">>>[RUI]", "!!MailboxSmashInit")
    dx, dy, dz = GetPointFromPointList(POINTLIST._PR_CARMOVETO, 1)
    F_TierInit()
    Wait(500)
    F_DogHazardsCreate()
end

function F_TierInit()
    if gDifficulty == 0 then
        F_TierSetupDifficulty01()
    elseif gDifficulty == 1 then
        F_TierSetupDifficulty02()
    elseif gDifficulty == 2 then
        F_TierSetupDifficulty03()
    elseif 3 <= gDifficulty then
        F_TierSetupDifficulty04()
    end
end

function F_TierSetupDifficulty01()
    gMissionTime = 10 * 60
    gMinMailboxes = 10
    gMailBoxes = {
        {
            id = TRIGGER._RICH_MAILBOX02
        },
        {
            id = TRIGGER._RICH_MAILBOX03
        },
        {
            id = TRIGGER._RICH_MAILBOX05
        },
        {
            id = TRIGGER._RICH_MAILBOX07
        },
        {
            id = TRIGGER._RICH_MAILBOX11
        },
        {
            id = TRIGGER._RICH_MAILBOX12
        },
        {
            id = TRIGGER._RICH_MAILBOX13
        },
        {
            id = TRIGGER._RICH_MAILBOX14
        },
        {
            id = TRIGGER._RICH_MAILBOX15
        },
        {
            id = TRIGGER._RICH_MAILBOX16
        },
        {
            id = TRIGGER._RICH_MAILBOX17
        },
        {
            id = TRIGGER._RICH_MAILBOX18
        },
        {
            id = TRIGGER._RICH_MAILBOX19
        },
        {
            id = TRIGGER._RICH_MAILBOX20
        },
        {
            id = TRIGGER._RICH_MAILBOX22
        }
    }
    gDogHazards = {
        {
            trigger = TRIGGER._PR_DOGSTART02,
            point = POINTLIST._PR_MAILBOXDOG02,
            bActive = true
        }
    }
    --print(">>>[RUI]", "++F_TierSetupDifficulty01")
end

function F_TierSetupDifficulty02()
    gMissionTime = 2 * 60
    gMinMailboxes = 14
    gMailBoxes = {
        {
            id = TRIGGER._RICH_MAILBOX02
        },
        {
            id = TRIGGER._RICH_MAILBOX03
        },
        {
            id = TRIGGER._RICH_MAILBOX05
        },
        {
            id = TRIGGER._RICH_MAILBOX07
        },
        {
            id = TRIGGER._RICH_MAILBOX08
        },
        {
            id = TRIGGER._RICH_MAILBOX09
        },
        {
            id = TRIGGER._RICH_MAILBOX10
        },
        {
            id = TRIGGER._RICH_MAILBOX11
        },
        {
            id = TRIGGER._RICH_MAILBOX12
        },
        {
            id = TRIGGER._RICH_MAILBOX13
        },
        {
            id = TRIGGER._RICH_MAILBOX14
        },
        {
            id = TRIGGER._RICH_MAILBOX15
        },
        {
            id = TRIGGER._RICH_MAILBOX16
        },
        {
            id = TRIGGER._RICH_MAILBOX17
        },
        {
            id = TRIGGER._RICH_MAILBOX18
        },
        {
            id = TRIGGER._RICH_MAILBOX19
        },
        {
            id = TRIGGER._RICH_MAILBOX20
        },
        {
            id = TRIGGER._RICH_MAILBOX21
        },
        {
            id = TRIGGER._RICH_MAILBOX22
        }
    }
    gDogHazards = {
        {
            trigger = TRIGGER._PR_DOGSTART02,
            point = POINTLIST._PR_MAILBOXDOG02,
            bActive = true
        }
    }
    --print(">>>[RUI]", "++F_TierSetupDifficulty02")
end

function F_TierSetupDifficulty03()
    gMissionTime = 3 * 60
    gMinMailboxes = 20
    gMailBoxes = {
        {
            id = TRIGGER._RICH_MAILBOX03
        },
        {
            id = TRIGGER._RICH_MAILBOX05
        },
        {
            id = TRIGGER._RICH_MAILBOX06
        },
        {
            id = TRIGGER._RICH_MAILBOX07
        },
        {
            id = TRIGGER._RICH_MAILBOX08
        },
        {
            id = TRIGGER._RICH_MAILBOX10
        },
        {
            id = TRIGGER._RICH_MAILBOX11
        },
        {
            id = TRIGGER._RICH_MAILBOX12
        },
        {
            id = TRIGGER._RICH_MAILBOX13
        },
        {
            id = TRIGGER._RICH_MAILBOX14
        },
        {
            id = TRIGGER._RICH_MAILBOX15
        },
        {
            id = TRIGGER._RICH_MAILBOX16
        },
        {
            id = TRIGGER._RICH_MAILBOX17
        },
        {
            id = TRIGGER._RICH_MAILBOX18
        },
        {
            id = TRIGGER._RICH_MAILBOX19
        },
        {
            id = TRIGGER._RICH_MAILBOX20
        },
        {
            id = TRIGGER._RICH_MAILBOX21
        },
        {
            id = TRIGGER._RICH_MAILBOX22
        },
        {
            id = TRIGGER._RICH_MAILBOX24
        },
        {
            id = TRIGGER._RICH_MAILBOX25
        }
    }
    gDogHazards = {
        {
            trigger = TRIGGER._PR_DOGSTART03,
            point = POINTLIST._PR_MAILBOXDOG03,
            bActive = true
        },
        {
            trigger = TRIGGER._PR_DOGSTART04,
            point = POINTLIST._PR_MAILBOXDOG04,
            bActive = true
        }
    }
    --print(">>>[RUI]", "++F_TierSetupDifficulty03")
end

function F_TierSetupDifficulty04()
    gMissionTime = 3 * 60
    gMinMailboxes = 24
    gMailBoxes = {
        {
            id = TRIGGER._RICH_MAILBOX01
        },
        {
            id = TRIGGER._RICH_MAILBOX02
        },
        {
            id = TRIGGER._RICH_MAILBOX03
        },
        {
            id = TRIGGER._RICH_MAILBOX04
        },
        {
            id = TRIGGER._RICH_MAILBOX05
        },
        {
            id = TRIGGER._RICH_MAILBOX06
        },
        {
            id = TRIGGER._RICH_MAILBOX07
        },
        {
            id = TRIGGER._RICH_MAILBOX08
        },
        {
            id = TRIGGER._RICH_MAILBOX09
        },
        {
            id = TRIGGER._RICH_MAILBOX10
        },
        {
            id = TRIGGER._RICH_MAILBOX11
        },
        {
            id = TRIGGER._RICH_MAILBOX12
        },
        {
            id = TRIGGER._RICH_MAILBOX13
        },
        {
            id = TRIGGER._RICH_MAILBOX14
        },
        {
            id = TRIGGER._RICH_MAILBOX15
        },
        {
            id = TRIGGER._RICH_MAILBOX16
        },
        {
            id = TRIGGER._RICH_MAILBOX17
        },
        {
            id = TRIGGER._RICH_MAILBOX18
        },
        {
            id = TRIGGER._RICH_MAILBOX19
        },
        {
            id = TRIGGER._RICH_MAILBOX20
        },
        {
            id = TRIGGER._RICH_MAILBOX21
        },
        {
            id = TRIGGER._RICH_MAILBOX22
        },
        {
            id = TRIGGER._RICH_MAILBOX23
        },
        {
            id = TRIGGER._RICH_MAILBOX24
        },
        {
            id = TRIGGER._RICH_MAILBOX25
        }
    }
    gDogHazards = {
        {
            trigger = TRIGGER._PR_DOGSTART00,
            point = POINTLIST._PR_MAILBOXDOG00
        },
        {
            trigger = TRIGGER._PR_DOGSTART01,
            point = POINTLIST._PR_MAILBOXDOG01
        },
        {
            trigger = TRIGGER._PR_DOGSTART02,
            point = POINTLIST._PR_MAILBOXDOG02
        },
        {
            trigger = TRIGGER._PR_DOGSTART03,
            point = POINTLIST._PR_MAILBOXDOG03
        },
        {
            trigger = TRIGGER._PR_DOGSTART04,
            point = POINTLIST._PR_MAILBOXDOG04
        }
    }
    HazardsRandomize(gDogHazards, 2)
    --print(">>>[RUI]", "++F_TierSetupDifficulty04")
end

function cbMailBoxHitBat(mailBox)
    --print(">>>[RUI]", "cbMailBoxHit " .. tostring(mailBox))
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    --print("-----------------MAILBOX SMASHED--------------------------")
    local mailbox = MailBoxesFindBox(mailBox)
    if mailbox and not mailbox.gSmashed then
        TutorialStart("BUSTPREFNIGHT")
        if bTutorialOn then
            bTutorialOn = false
        end
        CounterIncrementCurrent(1)
        if mailbox.ped then
            MailBoxPedThank(mailbox.ped)
        end
        mailbox.blip = BlipCleanup(mailbox.blip)
        PAnimMakeTargetable(mailbox.id, false)
        gMailboxesSmashed = gMailboxesSmashed + 1
        MissionObjectiveUpdateParam(objId, 1, gMinMailboxes - gMailboxesSmashed)
        mailbox.gSmashed = true
    end
end

function MailBoxesFindBox(trigger)
    --print(">>>[RUI]", "!!MailBoxesFindBox")
    for k, mailbox in gMailBoxes do
        if mailbox.id == trigger then
            return mailbox
        end
    end
    return nil
end

function F_MailBoxesInit()
    --print(">>>[RUI]", "++MailBoxesInit")
    for k, mailbox in gMailBoxes do
        PAnimCreate(mailbox.id)
        PAnimMakeTargetable(mailbox.id, true)
        PAnimEnableStreaming(mailbox.id, false)
        mailbox.destroyed = false
    end
end

function MailBoxesCleanup()
    --print(">>>[RUI]", "--MailBoxesCleanup")
    F_MailBoxesBlip(false)
    for k, mailbox in gMailBoxes do
        PAnimDelete(mailbox.id)
    end
end

function F_MailBoxesBlip(bOn)
    for k, mailbox in gMailBoxes do
        if bOn then
            if not mailbox.gSmashed then
                print("&&&&&&&&&& adding Blip &&&&&&&&&&&&&&&&&&&&&")
                local bx, by, bz = GetAnchorPosition(mailbox.id)
                mailbox.blip = BlipAddXYZ(bx, by, bz, 0, 4)
            end
        else
            mailbox.blip = BlipCleanup(mailbox.blip)
        end
    end
end

function MailBoxesClearAmbient()
    shared.MailboxesRespawn = MAILBOXES_DELETE
    AreaForceLoadAreaByAreaTransition(true)
    --print(">>>[RUI]", "--MailBoxesClearAmbient")
end

function MailBoxesRestoreAmbient()
    shared.MailboxesRespawn = MAILBOXES_CREATE
    AreaForceLoadAreaByAreaTransition(true)
    --print(">>>[RUI]", "++MailBoxesRestoreAmbient")
end

function FailMission(message)
    bMissionDone = true
    gFailMessage = message
    gMissionState = MISSION_FAIL
    gCurrentStageFunc = nil
    --print(">>>[RUI]", "--FailMission " .. tostring(message))
end

function F_MailboxHud(bOn, cMaxMailBoxes)
    if bOn then
        CounterSetCurrent(0)
        CounterSetMax(cMaxMailBoxes)
        CounterSetIcon("mailboxb", "mailboxb_x")
        CounterMakeHUDVisible(true)
    else
        CounterMakeHUDVisible(false)
        CounterClearIcon()
        CounterSetCurrent(0)
        CounterSetMax(0)
        CounterClearText()
        CounterClearIcon()
    end
end

function TimerPassed(time)
    return time < GetTimer()
end

function PedCleanup(ped)
    if F_PedExists(ped) then
        --print(">>>[RUI]", "--PedCleanup")
        PedClearObjectives(ped)
        PedMakeAmbient(ped)
    end
end

function BlipCleanup(blip)
    --print(">>>[RUI]", "--BlipCleanup " .. tostring(blip))
    if blip and blip ~= -1 then
        BlipRemove(blip)
    end
    return nil
end

function AnimationGroupsLoad(bLoad, groups)
    if bLoad then
        if groups then
            gAnimationGroups = groups
            for _, group in gAnimationGroups do
                LoadAnimationGroup(group)
            end
            --print(">>>[RUI]", "++AnimationGroupsLoad LOAD")
        end
    elseif gAnimationGroups then
        for _, group in gAnimationGroups do
            UnLoadAnimationGroup(group)
        end
        --print(">>>[RUI]", "--AnimationGroupsLoad UNLOAD")
    end
end

function MakeAmbient(ped, bForce)
    if F_PedExists(ped) then
        if bForce then
            PedDelete(ped)
        else
            PedMakeAmbient(ped)
        end
    end
end

function F_SmashMailboxesRide()
    --print(">>>[RUI]", "F_SmashMailboxesInit")
    gObjectiveBlip = BlipCleanup(gObjectiveBlip)
    TextPrint("3_S08_MOBJ_01", 5, 1)
    objId = MissionObjectiveAdd("3_S08_MOBJ_01", 1)
    Mailbox_blip = BlipAddPoint(POINTLIST._3_S08_MAILBOXES, 0, 1, 1, 7)
    MissionTimerStart(gMinRideTime)
    gCurrentStageFunc = F_StateMachine()
end

function F_SmashMailboxesRide_Loop()
    local bx, by, bz = GetPointList(POINTLIST._3_S08_MAILBOXES)
    if PlayerIsInAreaXYZ(bx, by, bz, 2.5, 1) then
        MissionTimerStop()
        BlipRemove(Mailbox_blip)
        gCurrentStageFunc = F_StateMachine()
    end
end

function F_SmashMailboxesInit()
    TextPrint("3_S08_MOBJ_02", 5, 1)
    objId = MissionObjectiveAdd("3_S08_MOBJ_03", 1)
    MissionObjectiveUpdateParam(objId, 1, gMinMailboxes)
    F_MailBoxesBlip(true)
    F_MailboxHud(true, gMinMailboxes)
    CreateThread("T_DogHazardsMonitor")
    MissionTimerStart(gMissionTime)
    Wait(1000)
    gCurrentStageFunc = F_StateMachine()
end

function F_SmashMailboxes()
    if MissionTimerHasFinished() or gMailboxesSmashed >= gMinMailboxes then
        MissionTimerStop()
        if gMailboxesSmashed >= gMinMailboxes then
            gMissionState = MISSION_PASS
        else
            gMissionState = MISSION_FAIL
        end
        gCurrentStageFunc = nil
        return
    end
end

function MissionSetup()
    MissionDontFadeIn()
    MailBoxesClearAmbient()
    DATLoad("3_S08.DAT", 2)
    DATLoad("PaperRoute.DAT", 2)
    DATLoad("Mailboxes_Rich.DAT", 2)
    DATInit()
    RadarSetMinMax(30, 65, 30)
    AnimationGroupsLoad(true, {
        "NIS_0_00A",
        "F_Adult",
        "2_R03PaperRoute",
        "SBULL_S"
    })
    WeaponRequestModel(300)
    gDogModels = { 219, 220 }
    LoadModels(gDogModels)
    LoadModels({
        MODELENUM._MAILBOX,
        521
    })
    LoadModels({ 91 })
    F_SetCharacterModelsUnique(true, gDogModels)
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._PR_HILLTOPEXCLUDER, true)
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._PAPERROUTE_EXCLUDER, true)
    AreaOverridePopulation(8, 0, 0, 0, 0, 0, 0, 0, 10, 0, 2, 0, 0)
    VehicleOverrideAmbient(2, 1, 1, 0)
    AreaClearAllVehicles()
    AreaClearAllPeds()
    shared.gDisableBusStops = true
end

function MissionCleanup()
    PedDestroyWeapon(gPlayer, 300)
    bMissionDone = true
    RadarRestoreMinMax()
    PlayerWeaponHudLock(false)
    shared.gDisableBusStops = false
    F_SetCharacterModelsUnique(false)
    MissionTimerStop()
    SoundEnableInteractiveMusic(true)
    F_MakePlayerSafeForNIS(false, true)
    CameraSetWidescreen(false)
    MailBoxesCleanup()
    MailBoxesRestoreAmbient()
    DogHazardsCleanup()
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._PR_HILLTOPEXCLUDER, false)
    AreaSetNodesSwitchedOffInTrigger(TRIGGER._PAPERROUTE_EXCLUDER, false)
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
    EnablePOI(true, true)
    AnimationGroupsLoad(false)
    DATUnload(2)
    PedSetGlobalSleep(false)
    FollowCamDefaultVehicleShot()
    SoundStopInteractiveStream()
end

tblStates = { F_SmashMailboxesInit, F_SmashMailboxes }

function F_StateMachine()
    gCurrentState = gCurrentState + 1
    --DebugPrint("********************** Current State " .. gCurrentState)
    if gCurrentState <= 2 then
        return tblStates[gCurrentState]
    end
end

function F_CheckMailboxes()
    --print("F_CheckMailboxes")
    for i, mailbox in gMailBoxes do
        local x, y, z = GetAnchorPosition(mailbox.id)
        mailbox.index, mailbox.pool = PAnimGetPoolIndex("RMailbox", x, y, z, 1)
        if PAnimIsDestroyed(mailbox.index, mailbox.pool) == true and mailbox.destroyed == false then
            --print("------------------------------------DESTROYED MAILBOX------------------------------------")
            --print("DESTROYED>>>>>MAILBOX DESTROYED")
            mailbox.destroyed = true
            gMailboxesSmashed = gMailboxesSmashed + 1
            PedSetWeaponNow(gPlayer, 300, 1, false)
            CounterIncrementCurrent(1)
            mailbox.blip = BlipCleanup(mailbox.blip)
            MissionObjectiveUpdateParam(objId, 1, gMinMailboxes - gMailboxesSmashed)
            Wait(450)
            PAnimDelete(mailbox.id)
        else
        end
    end
end

function main()
    --print(">>>[RUI]", "++F_TierInit difficulty: " .. tostring(gDifficulty))
    F_MailboxSmash_Intro()
    gMissionState = MISSION_RUNNING
    PlayerSetControl(1)
    PedLockTarget(gPlayer, -1)
    PlayerWeaponHudLock(true)
    CameraAllowChange(true)
    PlayerIgnoreTargeting(false)
    CameraReset()
    CameraReturnToPlayer()
    CameraFade(500, 1)
    Wait(500)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    gCurrentStageFunc = F_StateMachine()
    Wait(1000)
    while gMissionState == MISSION_RUNNING do
        if gCurrentStageFunc then
            gCurrentStageFunc()
        end
        F_CheckMailboxes()
        Wait(0)
    end
    MissionTimerStop()
    F_MailBoxesBlip(false)
    TextPrint("", 8, 1)
    TutorialRemoveMessage()
    bMissionDone = true
    if gMissionState == MISSION_PASS then
        F_MailboxSmash_End()
    else
        SoundPlayMissionEndMusic(false, 8)
        MissionFail(true, true)
        --print("-----------------THIS MISSION FAILED------------------------")
        --print("-----------------THIS MISSION FAILED------------------------")
        --print("-----------------THIS MISSION FAILED------------------------")
        --print("-----------------THIS MISSION FAILED------------------------")
        --print("-----------------THIS MISSION FAILED------------------------")
        --print("-----------------THIS MISSION FAILED------------------------")
        --print("-----------------THIS MISSION FAILED------------------------")
        --print("-----------------THIS MISSION FAILED------------------------")
        --print("-----------------THIS MISSION FAILED------------------------")
        --print("-----------------THIS MISSION FAILED------------------------")
        --print("-----------------THIS MISSION FAILED------------------------")
    end
    PlayerWeaponHudLock(false)
end

function F_DogHazardsCreate()
    if not gDogHazards then
        return -1
    end
    --print(">>>[RUI]", "++DogHazardsCreate")
    for k, dog in gDogHazards do
        if dog.bActive then
            dog.id = PedCreatePoint(RandomTableElement(gDogModels), dog.point, 1)
            PedSetTetherToPoint(dog.id, dog.point, 1, 5)
        end
    end
    bDogHazardsCreated = true
end

function T_DogHazardsMonitor()
    --print(">>>[RUI]", "++T_DogHazardsMonitor")
    if bDogHazardsCreated then
        while gMissionState == MISSION_RUNNING and MissionActive() do
            for _, dog in gDogHazards do
                if dog and dog.id and not dog.bAttacking and PlayerIsInTrigger(dog.trigger) then
                    PedClearTether(dog.id)
                    PedAttack(dog.id, gPlayer, 1, true)
                    dog.bAttacking = true
                    --print(">>>[RUI]", "T_DogHazardsMonitor send dog")
                end
            end
            Wait(20)
        end
        --print(">>>[RUI]", "NO DOGS")
    end
    --print(">>>[RUI]", "--T_DogHazardsMonitor")
    collectgarbage()
end

function DogHazardsCleanup()
    if not gDogHazards then
        return
    end
    for _, dog in gDogHazards do
        PedCleanup(dog.id)
    end
    bDogHazardsCreated = false
    --print(">>>[RUI]", "--DogHazardsCleanup")
end

function HazardsRandomize(hazardTbl, limit)
    local roll
    local limitCount = 0
    for _, hazard in hazardTbl do
        roll = math.random(100)
        if 50 <= roll then
            hazard.bActive = true
            limitCount = limitCount + 1
            if limit <= limitCount then
                break
            end
        else
            hazard.bActive = false
        end
    end
end
