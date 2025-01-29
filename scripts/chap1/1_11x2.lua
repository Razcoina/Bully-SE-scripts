local bDebug = false
local bDebugLevel = 2
local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bGoToStage3 = false
local bCheckForPoopBag = false
local pooTargetX, pooTargetY, pooTargetZ = 0, 0, 0
local bTimerStarted = false
local bEndMission = false
local bPopDisabled = false
local bObjective3Displayed = false
local bSkipFirstCutscene = false
local bSkipSecondCutscene = false
local bPoopTargetBlipped = false
local bFireWarn = false
local bPlayerIsHoldingPoopBag = false
local spawnNumberChad = 0
local spawnNumberDog = 0
local spawnNumberBurton = 0
local gMissionFailMessage = 0
local gLockedDoor = false
local bFixWierdBug = false
local bSetGaryInvulnerable = false
local gBagInd, gBagModel

function MissionSetup()
    --print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
    MissionDontFadeIn()
    DATLoad("1_11X2.DAT", 2)
    DATInit()
    if shared.gPetey and PedIsValid(shared.gPetey) then
        PedDelete(shared.gPetey)
        shared.gPetey = nil
    end
    if shared.gGary and PedIsValid(shared.gGary) then
        PedDelete(shared.gGary)
        shared.gGary = nil
    end
    if IsMissionFromDebug() then
        CameraFade(500, 0)
    end
    SoundPlayInteractiveStream("MS_HalloweenLow.rsm", 0.5)
    SoundSetMidIntensityStream("MS_HalloweenMid.rsm", 0.6)
    SoundSetHighIntensityStream("MS_HalloweenHigh.rsm", 1)
    --print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
    --print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
    if F_PedExists(pedGary.id) then
        PedSetMissionCritical(pedGary.id, false)
        PedMakeAmbient(pedGary.id)
        PedDismissAlly(gPlayer, pedGary.id)
    end
    if gBagInd ~= nil and gBagModel ~= nil then
        DeletePersistentEntity(gBagInd, gBagModel)
    end
    if PlayerHasWeapon(399) then
        PedDestroyWeapon(gPlayer, 399)
    end
    if not bGoToStage2 then
        if PedIsValid(pedGary.id) then
            PedMakeAmbient(pedGary.id)
        end
        if PedIsValid(pedChad.id) then
            if pedChad.blip then
                BlipRemove(pedChad.blip)
            end
            PedMakeAmbient(pedChad.id)
        end
        if PedIsValid(pedDog.id) then
            PedStop(pedDog.id)
            PedClearObjectives(pedDog.id)
            PedMakeTargetable(pedDog.id, true)
            PedIgnoreAttacks(pedDog.id, false)
            PedSetInvulnerable(pedDog.id, false)
            PedMakeAmbient(pedDog.id)
            PedWander(pedDog.id, 1)
        end
    end
    F_MakePlayerSafeForNIS(false)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    if bMissionPassed then
        ClothingGivePlayerOutfit("Ninja_RED")
        shared.cm_lockHead = false
        shared.cm_lockTorso = false
        shared.cm_lockLWrist = false
        shared.cm_lockRWrist = false
        shared.cm_lockLegs = false
        shared.cm_lockFeet = false
        shared.cm_lockOutfit = false
        shared.lockClothingManager = false
        shared.g1_11X2JustFinished = true
        SoundStopInteractiveStream()
    else
        local halloweenHour, halloweenMin = ClockGet()
        if 2 <= halloweenHour and halloweenHour < 8 then
            F_ProcessWakeUpMissionBasedLogic()
        end
    end
    F_CleanupEffects()
    DATUnload(2)
    DATInit()
    AreaEnableAllPatrolPaths()
    UnLoadAnimationGroup("POI_Smoking")
    UnLoadAnimationGroup("POI_WarmHands")
    UnLoadAnimationGroup("Halloween")
    UnLoadAnimationGroup("W_PooBag")
    UnLoadAnimationGroup("Px_Sink")
    UnLoadAnimationGroup("NIS_1_11")
    UnLoadAnimationGroup("MINI_React")
    SoundUnLoadBank("MISSIONFlameBag.bnk")
    PedSetUniqueModelStatus(55, spawnNumberBurton)
    PedSetUniqueModelStatus(32, spawnNumberChad)
    PedSetUniqueModelStatus(141, spawnNumberDog)
    DisablePunishmentSystem(false)
    PAnimSetPropFlag(TRIGGER._DT_ISCHOOL_STAFF, 22, false)
    PickupRemoveAll(399)
    AreaClearAllProjectiles(399)
    collectgarbage()
    --print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
    --print("()xxxxx[:::::::::::::::> [start] main()")
    F_SetupMission()
    if bDebug then
        if bDebugLevel == 2 then
            F_StartAtStage2()
        else
            F_Stage1()
        end
    else
        F_Stage1()
    end
    if bMissionFailed then
        bFixWierdBug = true
        TextPrint("1_11X2_EMPTY", 1, 1)
        SoundPlayMissionEndMusic(false, 10)
        if gMissionFailMessage == 1 then
            MissionFail(false, true, "1_11X2_FAIL_01")
        elseif gMissionFailMessage == 2 then
            F_CutGaryDissapointed()
            MissionFail(true, true, "1_11X2_FAIL_02")
        else
            MissionFail(true)
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_TableInit()
    --print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
    pedGary = {
        spawn = POINTLIST._1_11X2_SPAWNGARY,
        element = 1,
        model = 160
    }
    pedPete = {
        spawn = POINTLIST._1_11X2_SPAWNPETE,
        element = 1,
        model = 165
    }
    pedDog = {
        spawn = POINTLIST._1_11X2_SPAWNDOG,
        element = 1,
        model = 141
    }
    pedChad = {
        spawn = POINTLIST._1_11X2_SPAWNCHAD,
        element = 1,
        model = 32
    }
    pedBurton = {
        spawn = POINTLIST._1_11X2_SPAWNBURTON,
        element = 1,
        model = 55
    }
    --print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_SetupMission()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupMission()")
    if IsMissionFromDebug() then
        ClockSet(22, 0)
        ClothingSetPlayerOutfit("Halloween")
        ClothingBuildPlayer()
        CameraFade(10, 0)
        Wait(11)
    end
    F_TableInit()
    AreaTransitionPoint(0, POINTLIST._1_11X2_CUTPLAYER, 1, false)
    AreaDisableAllPatrolPaths()
    WeaponRequestModel(399)
    WeaponRequestModel(411)
    LoadAnimationGroup("POI_Smoking")
    LoadAnimationGroup("POI_WarmHands")
    LoadAnimationGroup("Halloween")
    LoadAnimationGroup("W_PooBag")
    LoadAnimationGroup("Px_Sink")
    LoadAnimationGroup("MINI_React")
    BlipRemove(shared.gHallowPrankBlip01)
    BlipRemove(shared.gHallowPrankBlip02)
    BlipRemove(shared.gHallowPrankBlip03)
    BlipRemove(shared.gHallowPrankBlip04)
    BlipRemove(shared.gHallowPrankBlip05)
    BlipRemove(shared.gHallowPrankBlip06)
    BlipRemove(shared.gHallowPrankBlip07)
    BlipRemove(shared.gHallowPrankBlip08)
    SoundLoadBank("MISSIONFlameBag.bnk")
    spawnNumberBurton = PedGetUniqueModelStatus(55)
    spawnNumberChad = PedGetUniqueModelStatus(32)
    spawnNumberDog = PedGetUniqueModelStatus(141)
    PedSetUniqueModelStatus(55, -1)
    PedSetUniqueModelStatus(32, -1)
    PedSetUniqueModelStatus(141, -1)
    DisablePunishmentSystem(true)
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupMission()")
end

function F_Stage1()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
    F_Stage1_Setup()
    F_Stage1_Loop()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
    pedPete.id = PedCreatePoint(pedPete.model, pedPete.spawn, pedPete.element)
    pedGary.id = PedCreatePoint(pedGary.model, pedGary.spawn, pedGary.element)
    pedDog.id = PedCreatePoint(pedDog.model, pedDog.spawn, pedDog.element)
    pedChad.id = PedCreatePoint(pedChad.model, pedChad.spawn, pedChad.element)
    PedSetInfiniteSprint(pedDog.id, true)
    PedMakeTargetable(pedDog.id, false)
    PedIgnoreAttacks(pedDog.id, true)
    PedSetInvulnerable(pedDog.id, true)
    PedSetMissionCritical(pedGary.id, true, F_MissionCritical, false)
    PedSetWeaponNow(pedGary.id, 411, 1)
    PedSetPedToTypeAttitude(pedGary.id, 13, 4)
    PedSetFlag(pedGary.id, 68, true)
    PedSetFlag(pedPete.id, 108, true)
    PedSetFlag(pedGary.id, 108, true)
    F_cutDogPlan()
    PedSetFlag(pedGary.id, 108, false)
    gObjective01 = MissionObjectiveAdd("1_11X2_MOBJ_01")
    SoundPlayScriptedSpeechEventWrapper(pedGary.id, "M_1_11X2", 98, "large")
    PedFollowPath(pedDog.id, PATH._1_11X2_DOGGARDEN, 1, 2)
    PedFollowFocus(pedGary.id, pedDog.id)
    PedIgnoreAttacks(pedGary.id, true)
    PedIgnoreStimuli(pedGary.id, true)
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
    while bLoop do
        Stage1_Objectives()
        if bMissionFailed then
            break
        end
        if bGoToStage2 then
            F_Stage2()
            break
        end
        Wait(0)
    end
end

function F_Stage2()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage2()")
    F_Stage2_Setup()
    F_Stage2_Loop()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage2()")
end

function F_Stage2_Setup()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage2_Setup()")
    SoundPlayScriptedSpeechEventWrapper(pedGary.id, "M_1_11X2", 104)
    PedRecruitAlly(gPlayer, pedGary.id)
    PedSetMissionCritical(pedGary.id, true, F_MissionCritical, false)
    PedSetInvulnerable(pedGary.id, false)
    Wait(4000)
    TextPrint("1_11X2_MOBJ_02", 3, 1)
    blipObjective02 = BlipAddPoint(POINTLIST._1_11X2_BLIPLOUNGE, 0, 1, 1, 7)
    MissionObjectiveComplete(gObjective01)
    MissionObjectiveRemove(gObjective01b)
    gObjective02 = MissionObjectiveAdd("1_11X2_MOBJ_02")
    bCheckForPoopBag = true
    CreateThread("T_CheckIfPlayerHasPoop")
    pooTargetX, pooTargetY, pooTargetZ = GetPointList(POINTLIST._1_11X2_BLIPLOUNGE)
    AreaSetDoorLocked("DT_ISCHOOL_STAFF", true)
    bPlayerIsHoldingPoopBag = true
    bPoopTargetBlipped = true
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
    while bLoop do
        Stage2_Objectives()
        if bMissionFailed then
            break
        end
        if bGoToStage3 then
            F_Stage3()
            break
        end
        Wait(0)
    end
end

function F_Stage3()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage3()")
    F_Stage3_Setup()
    F_Stage3_Loop()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage3()")
end

function F_Stage3_Setup()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage3_Setup()")
    bFixWierdBug = true
    ObjectRemovePickupsInTrigger(TRIGGER._1_11X2_SHITTARGET)
    gBagInd, gBagModel = CreatePersistentEntity("SC_PooBag", -589.35, -295.331, 0.116788, 0, 2)
    SoundPlayScriptedSpeechEventWrapper(pedGary.id, "M_1_11X2", 106)
    PedSetMissionCritical(pedGary.id, false)
    PedDismissAlly(gPlayer, pedGary.id)
    PedSetMissionCritical(pedGary.id, true, F_MissionCritical, false)
    PedMakeTargetable(pedGary.id, false)
    PedSetInvulnerable(pedGary.id, true)
    PedFollowPath(pedGary.id, PATH._1_11X2_GARYLIGHTPOOP, 0, 1, F_routeGaryLightPoop)
    BlipRemove(blipObjective02)
    if gObjective03 then
        MissionObjectiveComplete(gObjective03)
    end
    gObjective3b = MissionObjectiveAdd("1_11X2_MOBJ_03B")
    TextPrint("1_11X2_MOBJ_03B", 4, 1)
    local alarmX, alarmY, alarmZ = GetPointFromPointList(POINTLIST._1_11X2_BLIPALARM, 1)
    blipAlarm = BlipAddXYZ(alarmX, alarmY, alarmZ + 1, 0, 4)
    F_StopTimer()
    F_StartTimer(15)
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage3_Setup()")
end

function F_Stage3_Loop()
    while bLoop do
        Stage3_Objectives()
        if bMissionFailed then
            break
        end
        if bMissionPassed then
            break
        end
        Wait(0)
    end
end

function Stage1_Objectives()
    if not bChadAgro and PedIsInTrigger(pedGary.id, TRIGGER._1_11X2_CHADATTACK) then
        SoundPlayScriptedSpeechEventWrapper(pedChad.id, "M_1_11X2", 99, "jumbo")
        PedAttack(pedChad.id, pedGary.id, 1)
        TextPrint("1_11X2_MOBJ_01B", 3, 1)
        gObjective01b = MissionObjectiveAdd("1_11X2_MOBJ_01B")
        pedChad.blip = AddBlipForChar(pedChad.id, 5, 26, 4)
        bChadAgro = true
    end
    if not bSetGaryInvulnerable and PedGetHealth(pedChad.id) <= 0 then
        PedSetInvulnerable(pedGary.id, true)
        bSetGaryInvulnerable = true
    end
    if PedIsDead(pedChad.id) then
        PedStop(pedDog.id)
        PedDismissAlly(pedDog.id, pedGary.id)
        F_CutPoop()
        bGoToStage2 = true
    end
end

function Stage2_Objectives()
    if shared.gSchoolFAlarmOn == true then
        if bPoopTargetBlipped then
            F_RemovePoopTarget()
        end
    elseif not bPoopTargetBlipped then
        F_ShowPoopTarget()
    end
    if bPoopTargetBlipped then
        if PlayerIsInTrigger(TRIGGER._1_11X2_SHITTARGET) and bPlayerIsHoldingPoopBag then
            TextPrint("1_11X2_DROPPOOP", 0.1, 3)
            bCheckForPoopBag = false
            if not bObjective3Displayed then
                MissionObjectiveComplete(gObjective02)
                gObjective03 = MissionObjectiveAdd("1_11X2_MOBJ_03")
                TextPrint("1_11X2_MOBJ_03", 4, 1)
                --print("()xxxxx[:::::::::::::::> TESTSPAM1")
                bObjective3Displayed = true
            end
        else
            bCheckForPoopBag = true
        end
        if ObjectTypeIsInTrigger(399, TRIGGER._1_11X2_SHITTARGET) == 1 then
            --print("()xxxxx[:::::::::::::::> SHITBAG PLACED")
            SoundPlay2D("PaperbagDrop")
            TextPrint("1_11X2_EMPTY", 1, 1)
            bGoToStage3 = true
        end
        if not gLockedDoor then
            if PlayerIsInTrigger(TRIGGER._1_11X2_SHITTARGET) then
                PAnimSetPropFlag(TRIGGER._DT_ISCHOOL_STAFF, 22, true)
                gLockedDoor = true
            end
        elseif not PlayerIsInTrigger(TRIGGER._1_11X2_SHITTARGET) then
            PAnimSetPropFlag(TRIGGER._DT_ISCHOOL_STAFF, 22, false)
            gLockedDoor = false
        end
    end
end

function Stage3_Objectives()
    if bTimerStarted and MissionTimerHasFinished() then
        F_StopTimer()
        gMissionFailMessage = 2
        bMissionFailed = true
    end
    if not bEndMission and shared.gSchoolFAlarmOn == true then
        F_StopTimer()
        PlayerSetControl(0)
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        SoundPlayScriptedSpeechEventWrapper(pedGary.id, "M_1_11X2", 57, "medium")
        CameraSetXYZ(-594.813, -294.81302, 1.376248, -593.8194, -294.92416, 1.356479)
        Wait(2000)
        PedSetActionNode(pedGary.id, "/Global/1_11X2/empty", "Act/Conv/1_11X2.act")
        PedFollowPath(pedGary.id, PATH._1_11X2_GARYHIDE, 0, 2)
        BlipRemove(blipAlarm)
        pedBurton.id = PedCreatePoint(pedBurton.model, pedBurton.spawn, pedBurton.element)
        PedIgnoreStimuli(pedBurton.id, true)
        PedIgnoreStimuli(pedGary.id, true)
        SoundPlayScriptedSpeechEventWrapper(pedBurton.id, "M_1_11X2", 113, "large")
        Wait(2000)
        SoundPlay2D("ESCDOORL_Open")
        PedFollowPath(pedBurton.id, PATH._1_11X2_BURTONTOSHIT, 0, 0, F_routeBurtonToShit)
        PedFaceObject(pedGary.id, pedBurton.id, 2, 1)
        Wait(500)
        PedSetActionNode(pedGary.id, "/Global/1_11X2/Animations/KneelIdle/Kneel", "Act/Conv/1_11X2.act")
        Wait(3500)
        EffectSlowKill(effectShitFire01, 1, true)
        effectMudSplat = EffectCreate("MudImpact", pooTargetX, pooTargetY, pooTargetZ)
        MinigameSetCompletion("M_PASS", true, 0, "1_11_x2_UNLKCSTM")
        SoundPlayMissionEndMusic(true, 10)
        SoundPlayScriptedSpeechEventWrapper(pedBurton.id, "M_1_11X2", 114, "large")
        PlayerFaceHeadingNow(270)
        Wait(1000)
        SoundPlayScriptedSpeechEventWrapper(pedGary.id, "M_1_11X2", 45, "medium")
        EffectSlowKill(effectShitFire00, 2, true)
        bMissionPassed = true
        bEndMission = true
        while SoundSpeechPlaying(pedBurton.id) do
            Wait(0)
        end
        while SoundSpeechPlaying(pedGary.id) do
            Wait(0)
        end
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        CameraFade(500, 0)
        Wait(501)
        CameraReset()
        CameraReturnToPlayer()
        if gBagInd ~= nil and gBagModel ~= nil then
            DeletePersistentEntity(gBagInd, gBagModel)
            gBagInd = nil
            gBagModel = nil
        end
        PedIgnoreStimuli(pedBurton.id, false)
        PedMakeAmbient(pedBurton.id)
        PedSetMissionCritical(pedGary.id, false)
        PedSetActionNode(pedGary.id, "/Global/1_11X2/empty", "Act/Conv/1_11X2.act")
        PedMakeAmbient(pedGary.id)
        PedIgnoreStimuli(pedGary.id, false)
        MissionSucceed(false, false, false)
        Wait(500)
        CameraFade(500, 1)
        Wait(101)
        PlayerSetControl(1)
    end
end

function F_StartTimer(seconds)
    --print("()xxxxx[:::::::::::::::> [start] F_StartTimer()")
    MissionTimerStart(seconds)
    bTimerStarted = true
    --print("()xxxxx[:::::::::::::::> [finish] F_StartTimer()")
end

function F_StopTimer()
    --print("()xxxxx[:::::::::::::::> [start] F_StopTimer()")
    MissionTimerStop()
    bTimerStarted = false
    --print("()xxxxx[:::::::::::::::> [finish] F_StopTimer()")
end

function F_MissionCritical()
    --print("()xxxxx[:::::::::::::::> [start] F_MissionCritical()")
    gMissionFailMessage = 1
    bCheckForPoopBag = false
    bMissionFailed = true
    --print("()xxxxx[:::::::::::::::> [finish] F_MissionCritical()")
end

function F_WaitForSpeech(pedID)
    --print("()xxxxx[:::::::::::::::> [start] F_WaitForSpeech()")
    if pedID == nil then
        while SoundSpeechPlaying() do
            Wait(0)
        end
    else
        while SoundSpeechPlaying(pedID) do
            Wait(0)
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_WaitForSpeech()")
end

function F_WaitForSpeechCutscene01(pedID)
    --print("()xxxxx[:::::::::::::::> [start] F_WaitForSpeechCutscene01()")
    if pedID == nil then
        while SoundSpeechPlaying() do
            Wait(0)
        end
    else
        while SoundSpeechPlaying(pedID) do
            if bSkipFirstCutscene then
                break
            end
            Wait(0)
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_WaitForSpeechCutscene01()")
end

function F_CleanupEffects()
    --print("()xxxxx[:::::::::::::::> [start] F_CleanupEffects()")
    if effectShitFire00 then
        EffectSlowKill(effectShitFire00, 2, true)
    end
    if effectShitFire01 then
        EffectSlowKill(effectShitFire01, 1, true)
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_CleanupEffects()")
end

function F_RemovePoopTarget()
    --print("()xxxxx[:::::::::::::::> [start] F_RemovePoopTarget()")
    BlipRemove(blipObjective02)
    bFireWarn = true
    bPoopTargetBlipped = false
    --print("()xxxxx[:::::::::::::::> [finish] F_RemovePoopTarget()")
end

function F_ShowPoopTarget()
    --print("()xxxxx[:::::::::::::::> [start] F_ShowPoopTarget()")
    BlipRemove(blipObjective02)
    blipObjective02 = BlipAddPoint(POINTLIST._1_11X2_BLIPLOUNGE, 0, 1, 1, 7)
    TextPrint("1_11X2_MOBJ_03", 4, 1)
    --print("()xxxxx[:::::::::::::::> TESTSPAM2")
    bFireWarn = false
    bPoopTargetBlipped = true
    --print("()xxxxx[:::::::::::::::> [finish] F_ShowPoopTarget()")
end

function F_cutDogPlan()
    --print("()xxxxx[:::::::::::::::> [start] F_cutDogPlan()")
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    PlayerSetControl(0)
    PlayerSetPosPoint(POINTLIST._1_11X2_CUTPLAYER, 1)
    PedSetPosPoint(pedGary.id, POINTLIST._1_11X2_CUTGARY, 1)
    PedSetPosPoint(pedPete.id, POINTLIST._1_11X2_CUTPETE, 1)
    PedFaceObject(pedGary.id, gPlayer, 2, 0)
    PedFollowPath(pedDog.id, PATH._1_11X2_DOG01, 1, 1)
    LoadActionTree("Act/Conv/1_11X2.act")
    LoadAnimationGroup("NIS_1_11")
    CameraFade(500, 1)
    CreateThread("T_Cutscene01")
    while not bSkipFirstCutscene do
        if IsButtonPressed(7, 0) then
            bSkipFirstCutscene = true
        end
        Wait(0)
    end
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(500)
    CameraSetWidescreen(false)
    PedStop(pedPete.id)
    PedDelete(pedPete.id)
    PedShowHealthBar(pedGary.id, true, "1_11X2_GHEALTH", false)
    PedSetPosPoint(pedDog.id, POINTLIST._1_11_X2_STARTDOG)
    PedSetPosPoint(pedGary.id, POINTLIST._1_11_X2_STARTGARY)
    PlayerSetPosPoint(POINTLIST._1_11_X2_STARTPLAYER)
    CameraReturnToPlayer()
    CameraAllowChange(true)
    F_MakePlayerSafeForNIS(false)
    CameraFade(500, 1)
    Wait(500)
    PlayerSetControl(1)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    --print("()xxxxx[:::::::::::::::> [finish] F_cutDogPlan()")
end

function F_CutPoop()
    --print("()xxxxx[:::::::::::::::> [start] F_CutPoop()")
    local cameraX, cameraY, cameraZ = GetPointList(POINTLIST._1_11X2_CUTPOOPCAMERA)
    local lookX, lookY, lookZ = GetPointList(POINTLIST._1_11X2_CUTPOOPDOG)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PlayerSetControl(0)
    CameraFade(500, 0)
    Wait(500)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    PedSetMissionCritical(pedGary.id, false)
    PedDelete(pedDog.id)
    PedDelete(pedGary.id)
    pedDog.id = PedCreatePoint(pedDog.model, POINTLIST._1_11X2_CUTPOOPDOG, 1)
    pedGary.id = PedCreatePoint(pedGary.model, POINTLIST._1_11X2_CUTPOOPGARY, 1)
    PedSetStationary(pedDog.id, true)
    PedSetStationary(pedGary.id, true)
    PedIgnoreStimuli(pedDog.id, true)
    PedIgnoreStimuli(pedGary.id, true)
    PedSetActionNode(pedDog.id, "/Global/1_11X2/empty", "Act/Conv/1_11X2.act")
    PedSetActionNode(pedGary.id, "/Global/1_11X2/empty", "Act/Conv/1_11X2.act")
    local tempX, tempY, tempZ = GetPointList(POINTLIST._1_11X2_CUTPOOPPLAYER)
    PlayerSetPosSimple(tempX, tempY, tempZ)
    PedHideHealthBar()
    PedFaceObject(gPlayer, pedDog.id, 2, 0)
    PedFaceObject(pedGary.id, pedDog.id, 2, 0)
    CameraSetFOV(80)
    CameraSetXYZ(138.13452, -132.61316, 7.045309, 137.16325, -132.61761, 7.282878)
    PedFaceHeading(pedDog.id, 115, 0)
    LoadAnimationGroup("QPED")
    LoadAnimationGroup("Px_Sink")
    LoadAnimationGroup("GEN_Social")
    LoadAnimationGroup("NPC_Cheering")
    if PedIsValid(pedChad.id) then
        PedDelete(pedChad.id)
    end
    PedClearAllWeapons(pedGary.id)
    CameraFade(500, 1)
    Wait(1000)
    CreateThread("T_Cutscene02")
    while not bSkipSecondCutscene do
        if IsButtonPressed(7, 0) then
            bSkipSecondCutscene = true
        end
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(500)
    PedSetActionNode(pedGary.id, "/Global/1_11X2/empty", "Act/Conv/1_11X2.act")
    CameraDefaultFOV()
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    UnLoadAnimationGroup("QPED")
    UnLoadAnimationGroup("Px_Sink")
    UnLoadAnimationGroup("GEN_Social")
    UnLoadAnimationGroup("NPC_Cheering")
    PedSetStationary(pedDog.id, false)
    PedSetStationary(pedGary.id, false)
    PedIgnoreStimuli(pedDog.id, false)
    PedIgnoreStimuli(pedGary.id, false)
    PedMakeTargetable(pedDog.id, true)
    PedIgnoreAttacks(pedDog.id, false)
    PedMakeAmbient(pedDog.id)
    PedSetInvulnerable(pedDog.id, false)
    PedIgnoreStimuli(pedGary.id, false)
    PedDestroyWeapon(pedGary.id, 399)
    PedSetWeapon(pedGary.id, 411, 1)
    PedRequestModel(55)
    F_MakePlayerSafeForNIS(false)
    CameraFade(500, 1)
    Wait(500)
    PlayerSetControl(1)
    PedSetWeapon(gPlayer, 399, 1)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    --print("()xxxxx[:::::::::::::::> [finish] F_CutPoop()")
end

function F_CutGaryDissapointed()
    --print("()xxxxx[:::::::::::::::> [start] F_CutGaryDissapointed()")
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true, false, false, true)
    local playerX, playerY, playerZ = PedGetPosXYZ(gPlayer)
    PickupDestroyTypeInAreaXYZ(playerX, playerY, playerZ, 50, 399)
    PedSetFlag(pedGary.id, 108, true)
    PedSetActionNode(pedGary.id, "/Global/1_11X2/empty", "Act/Conv/1_11X2.act")
    PedSetActionNode(gPlayer, "/Global/1_11X2/Failure", "Act/Conv/1_11X2.act")
    PedSetStationary(pedGary.id, false)
    PedSetMissionCritical(pedGary.id, false)
    PedDismissAlly(gPlayer, pedGary.id)
    PedWander(pedGary.id, 1)
    local x1, y1, z1 = PedGetOffsetInWorldCoords(gPlayer, 0.5, 1, 1.2)
    local x2, y2, z2 = PedGetOffsetInWorldCoords(gPlayer, -0.5, -0.7, 1.7)
    CameraSetXYZ(x1, y1, z1, x2, y2, z2)
    AreaClearAllPeds()
    SoundStopCurrentSpeechEvent(pedGary.id)
    SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_11X1", 42, "medium", true, true)
    --print("()xxxxx[:::::::::::::::> [finish] F_CutGaryDissapointed()")
end

function T_Cutscene01()
    DoublePedShadowDistance(true)
    if not bSkipFirstCutscene then
        CameraSetFOV(90)
        CameraSetXYZ(107.458435, -118.89011, 6.98363, 106.95887, -118.042274, 7.161223)
        CameraSetFOV(90)
    end
    if not bSkipFirstCutscene then
        WaitSkippable(500)
    end
    if not bSkipFirstCutscene then
        SoundPlayScriptedSpeechEventWrapper(pedGary.id, "M_1_11X2", 92, "large")
    end
    if not bSkipFirstCutscene then
        ExecuteActionNode(pedGary.id, "/Global/1_11X2/CutPlan/Gary92", "Act/Conv/1_11X2.act")
    end
    if not bSkipFirstCutscene then
        F_WaitForSpeechCutscene01(pedGary.id)
    end
    if not bSkipFirstCutscene then
        SoundPlayScriptedSpeechEventWrapper(pedGary.id, "M_1_11X2", 93, "large")
        PedSetActionNode(pedGary.id, "/Global/1_11X2/CutPlan/Gary93", "Act/Conv/1_11X2.act")
    end
    if not bSkipFirstCutscene then
        WaitSkippable(1600)
    end
    if not bSkipFirstCutscene then
        CameraSetFOV(40)
        CameraSetXYZ(106.75926, -118.264915, 7.836123, 106.303665, -117.37477, 7.831728)
        SoundPlayScriptedSpeechEventWrapper(pedPete.id, "M_1_11X2", 94, "large")
        PedSetActionNode(pedPete.id, "/Global/1_11X2/CutPlan/Pete94", "Act/Conv/1_11X2.act")
    end
    if not bSkipFirstCutscene then
        F_WaitForSpeechCutscene01(pedPete.id)
    end
    if not bSkipFirstCutscene then
        PedLockTarget(pedGary.id, pedPete.id, 3)
        SoundPlayScriptedSpeechEventWrapper(pedPete.id, "M_1_11X2", 97, "large")
        PedSetActionNode(pedPete.id, "/Global/1_11X2/CutPlan/Pete96", "Act/Conv/1_11X2.act")
    end
    if not bSkipFirstCutscene then
        F_WaitForSpeechCutscene01(pedPete.id)
    end
    if not bSkipFirstCutscene then
        PedFollowPath(pedPete.id, PATH._1_11X2_PETEFLEE, 0, 1)
        SoundPlayScriptedSpeechEventWrapper(pedGary.id, "M_1_11X2", 97, "large")
        PedLockTarget(pedGary.id, gPlayer, 3)
        PedSetActionNode(pedGary.id, "/Global/1_11X2/CutPlan/Gary97", "Act/Conv/1_11X2.act")
    end
    if not bSkipFirstCutscene then
        F_WaitForSpeechCutscene01(pedGary.id)
    end
    PedLockTarget(pedGary.id, -1)
    DoublePedShadowDistance(false)
    SoundStopCurrentSpeechEvent(pedGary.id)
    bSkipFirstCutscene = true
end

function T_Cutscene02()
    DoublePedShadowDistance(true)
    if not bSkipSecondCutscene then
        SoundPlayScriptedSpeechEventWrapper(pedGary.id, "M_1_11X2", 100)
        PedSetActionNode(pedGary.id, "/Global/1_11X2/Animations/KneelFeed/KneelFeed", "Act/Conv/1_11X2.act")
    end
    if not bSkipSecondCutscene then
        WaitSkippable(2000)
    end
    if not bSkipSecondCutscene then
        PedSetActionNode(pedDog.id, "/Global/1_11X2/Animations/DogChew/ChewIn", "Act/Conv/1_11X2.act")
        SoundPlayScriptedSpeechEventWrapper(pedGary.id, "M_1_11X2", 101)
    end
    if not bSkipSecondCutscene then
        WaitSkippable(5000)
    end
    if not bSkipSecondCutscene then
        CameraSetFOV(40)
        CameraSetXYZ(132.54547, -131.91151, 10.314656, 133.31483, -132.09818, 9.703887)
        PedSetActionNode(gPlayer, "/Global/1_11X2/Animations/Stop/Stop", "Act/Conv/1_11X2.act")
        PedSetActionNode(pedDog.id, "/Global/1_11X2/Animations/DogShit/ShitIn", "Act/Conv/1_11X2.act")
        SoundPlayScriptedSpeechEventWrapper(gPlayer, "M_1_11X2", 102)
    end
    if not bSkipSecondCutscene then
        WaitSkippable(2000)
    end
    if not bSkipSecondCutscene then
        PedSetActionNode(pedGary.id, "/Global/1_11X2/empty", "Act/Conv/1_11X2.act")
    end
    if not bSkipSecondCutscene then
        WaitSkippable(3000)
    end
    if not bSkipSecondCutscene then
        CameraSetFOV(80)
        CameraSetXYZ(136.47432, -132.6544, 7.835443, 136.13542, -133.56049, 8.088558)
        CameraSetFOV(80)
        PedSetActionNode(pedGary.id, "/Global/1_11X2/Animations/KneelFeed/KneelFeed", "Act/Conv/1_11X2.act")
    end
    if not bSkipSecondCutscene then
        WaitSkippable(500)
    end
    if not bSkipSecondCutscene then
        PedSetActionNode(pedDog.id, "/Global/1_11X2/Sounds/StuffPooBag", "Act/Conv/1_11X2.act")
    end
    if not bSkipSecondCutscene then
        WaitSkippable(3200)
    end
    if not bSkipSecondCutscene then
        CameraSetFOV(80)
        PedSetWeapon(pedGary.id, 399, 1)
        SoundPlay2D("PaperbagPicup")
        SoundPlayScriptedSpeechEventWrapper(pedGary.id, "M_1_11X2", 103)
    end
    if not bSkipSecondCutscene then
        WaitSkippable(1000)
    end
    if not bSkipSecondCutscene then
        PedMoveToPoint(pedGary.id, 1, POINTLIST._1_11X2_GARYHANDBAG)
    end
    if not bSkipSecondCutscene then
        WaitSkippable(800)
    end
    if not bSkipSecondCutscene then
        PedDestroyWeapon(pedGary.id, 399)
        PedSetActionNode(gPlayer, "/Global/1_11X2/Animations/Receive/Take", "Act/Conv/1_11X2.act")
    end
    if not bSkipSecondCutscene then
        WaitSkippable(1700)
    end
    DoublePedShadowDistance(false)
    bSkipSecondCutscene = true
end

function T_CheckIfPlayerHasPoop()
    while not (not bLoop or bFixWierdBug) do
        if bCheckForPoopBag and not PlayerHasWeapon(399) then
            BlipRemove(blipObjective02)
            bPlayerIsHoldingPoopBag = false
            F_StartTimer(15)
            while not PlayerHasWeapon(399) do
                if bFixWierdBug then
                    break
                end
                TextPrint("1_11X2_PICKUPPOOP", 0.1, 1)
                if MissionTimerHasFinished() then
                    F_StopTimer()
                    gMissionFailMessage = 2
                    bMissionFailed = true
                    break
                end
                Wait(0)
            end
            if not bMissionFailed then
                bPlayerIsHoldingPoopBag = true
                if not bFixWierdBug then
                    F_StopTimer()
                end
                if bFireWarn then
                    TextPrint("1_11X2_FIREWARN", 4, 1)
                else
                    if bObjective3Displayed then
                        if not bFixWierdBug then
                            TextPrint("1_11X2_MOBJ_03", 4, 1)
                            --print("()xxxxx[:::::::::::::::> TESTSPAM3")
                        end
                    elseif not bFixWierdBug then
                        TextPrint("1_11X2_MOBJ_02", 3, 1)
                    end
                    if not bFixWierdBug then
                        BlipRemove(blipObjective02)
                        blipObjective02 = BlipAddPoint(POINTLIST._1_11X2_BLIPLOUNGE, 0, 1, 1, 7)
                    end
                end
            end
        end
        Wait(0)
    end
end

function F_StartAtStage2()
    --print("()xxxxx[:::::::::::::::> [start] F_StartAtStage2()")
    pedGary.id = PedCreatePoint(pedGary.model, POINTLIST._1_11X2_DEBUGSPAWNGARY, pedGary.element)
    PedSetWeapon(pedGary.id, 411, 1)
    PedSetMissionCritical(pedGary.id, true, F_MissionCritical, false)
    AreaTransitionPoint(2, POINTLIST._1_11X2_DEBUGSPAWNPLAYER)
    PedSetWeapon(gPlayer, 399, 1)
    gObjective01 = MissionObjectiveAdd("1_11X2_MOBJ_01")
    gObjective01b = MissionObjectiveAdd("1_11X2_MOBJ_01B")
    PedRecruitAlly(gPlayer, pedGary.id)
    CameraFade(500, 1)
    Wait(500)
    F_Stage2()
    --print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage2()")
end

function F_routeGaryLightPoop(pedID, pathID, nodeID)
    --print("()xxxxx[:::::::::::::::> F_routeGaryLightPoop() @ node: " .. nodeID)
    if nodeID == 1 then
        PedSetActionNode(pedID, "/Global/1_11X2/Animations/GaryLightBag/KneelIn", "Act/Conv/1_11X2.act")
    end
end

function F_routeBurtonToShit(pedID, pathID, nodeID)
    --print("()xxxxx[:::::::::::::::> F_routeBurtonToShit() @ node: " .. nodeID)
    if nodeID == 1 then
        PedSetActionNode(pedID, "/Global/1_11X2/Animations/ShitStomp/StompIn", "Act/Conv/1_11X2.act")
    end
end

function F_StartShitFireEffects()
    effectShitFire00 = EffectCreate("ShowerSteam2", pooTargetX, pooTargetY, pooTargetZ)
    effectShitFire01 = EffectCreate("boilerfire2", pooTargetX, pooTargetY, pooTargetZ + 0.15)
    PedMakeTargetable(pedGary.id, true)
    PedSetInvulnerable(pedGary.id, false)
end

function F_DeletePooBag()
    if gBagInd ~= nil and gBagModel ~= nil then
        DeletePersistentEntity(gBagInd, gBagModel)
    end
end
