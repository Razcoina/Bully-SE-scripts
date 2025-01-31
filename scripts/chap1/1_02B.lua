--[[ Changes to this file:
    * Modified function F_Stage1_Setup, may require testing
    * Modified function T_LockerLoop, may require testing
    * Function calls related to controls have been changed to match the PC version
]]

local bDebugFlag = false
local gDebugLevel = 2
local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bGoToStage3 = false
local numGreekboy = 0
local numEunice = 0
local numBully = 0
local numAlgie = 0
local gMissionFailMessage = 0
local gTimerRecruitGary = 0
local bDiscoveredLocker = false
local bObjectiveLocker = false
local bGaryArrivedAtEunice = false
local bGaryArrivedAtCafe = false
local bShouldEuniceCry = false
local gCurrentTut01 = 0
local bActivateSocialSystem = false
local bBullyCutscenePlayed = false
local bCompletedLocker = false
local bRetrievingChocolates = false
local bShownNewConstTut = false
local bConstantineReceivedMoney = false
local bConstantineHumiliated = false
local bConstantineLostHealth = false
local bBullyDead = false
local bGaryWaiting = false
local bChocolatesSpawned = false
local bPlayerHasChocolates = false
local bReturnChocolates = false
local gDoneTutorial03 = false
local bPOIdisabled = false
local bTextGaryHatesConstantine = false
local bRemoveTutorials = false
local bPlayerKissedEunice = false
local bDiscoveredLocker = false
local bDiscoveredSocial = false
local bPrefectPathActive = true
local bCompletedCafe = false
local bChocolatesDelivered = false
local bApologizedToRussell = false
local DoAction = false
local bRusLockXTutorial = true
local bGreetedEunice = false
local bPlayerGreetedEunice = false
local bRunEuniceObjective = false
local gDoneTutorial03 = false
local gCurrentTut03 = 0
local bConSocTutorial = true
local bReminderOff = false
local bGavePlayerHat = false
local bGaryRanToClass = false
local bPlayerPickedUpTheChocolates = false
local tLockers
local bAllowPunishmentToDrop = false

function MissionSetup()
    --print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
    MissionDontFadeIn()
    MissionDontFadeInAfterCompetion()
    DATLoad("1_02B.DAT", 2)
    DATInit()
    local tempX, tempY, tempZ = GetPointList(POINTLIST._1_02B_OBJSCHOOL)
    MissionOverrideArrestPoint(tempX, tempY, tempZ, 0, 2)
    PlayerSetControl(0)
    shared.bBathroomPOIEnabled = false
    PlayerSetPunishmentPoints(0)
    CameraSetWidescreen(false)
    --print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
    --print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
    if bGavePlayerHat and not bMissionPassed then
        ClothingRemovePlayer("S_Bhat1", 0)
    end
    SoundStopInteractiveStream()
    if F_PedExists(pedGary.id) then
        PedSetMissionCritical(pedGary.id, false)
        PedDismissAlly(gPlayer, pedGary.id)
    end
    if bGaryRanToClass and PedIsValid(pedGary.id) then
        PedDelete(pedGary.id)
    end
    EnablePOI()
    POIGroupsEnabled(true)
    shared.bBathroomPOIEnabled = true
    F_CleanupBlips()
    PedHideHealthBar()
    DATUnload(2)
    DATInit()
    PedSetUniqueModelStatus(70, numGreekboy)
    PedSetUniqueModelStatus(74, numEunice)
    PedSetUniqueModelStatus(99, numBully)
    PedSetUniqueModelStatus(4, numAlgie)
    PedSetUniqueModelStatus(69, numPedro)
    PedSetUniqueModelStatus(52, numKarl)
    shared.gLockpickSuccessFunction = nil
    UnLoadAnimationGroup("1_02BYourSchool")
    UnLoadAnimationGroup("SGEN_I")
    UnLoadAnimationGroup("3_04WrongPtTown")
    UnLoadAnimationGroup("G_Johnny")
    UnLoadAnimationGroup("SNERD_I")
    UnLoadAnimationGroup("SNERD_S")
    UnLoadAnimationGroup("KISSF")
    UnLoadAnimationGroup("NIS_1_02")
    UnLoadAnimationGroup("SBULL_X")
    if bMissionPassed then
        shared.b102CafeComplete = nil
        shared.b102SocialComplete = nil
        shared.b102LockerComplete = nil
        shared.b102spawnInHallways = nil
        shared.b102finished = true
        bCompletedLocker = true
        F_ResetLockerStates(true)
    end
    if not bMissionPassed then
        F_ResetLockerStates(false)
        ItemSetCurrentNum(478, 0)
    end
    SoundRestartPA()
    PlayerSetPunishmentPoints(0)
    TutorialRemoveMessage()
    AreaEnableAllPatrolPaths()
    AreaRevertToDefaultPopulation()
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    CameraReturnToPlayer()
    CameraReset()
    collectgarbage()
    --print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
    --print("()xxxxx[:::::::::::::::> [start] main()")
    F_SetupMission()
    if bDebugFlag then
        if gDebugLevel == 2 then
            F_StartAtStage2()
        elseif gDebugLevel == 3 then
            F_StartAtStage3()
        else
            F_Stage1()
        end
    else
        F_Stage1()
    end
    if bMissionFailed then
        TextPrint("1_02B_EMPTY", 1, 1)
        SoundPlayMissionEndMusic(false, 4)
        if gMissionFailMessage == 1 then
            MissionFail(true, true, "1_02B_FAIL_01")
        elseif gMissionFailMessage == 2 then
            MissionFail(true, true, "1_02B_FAIL_02")
        elseif gMissionFailMessage == 3 then
            MissionFail(true, true, "1_02B_FAIL_03")
        elseif gMissionFailMessage == 4 then
            MissionFail(true, true, "1_02B_FAIL_04")
        elseif gMissionFailMessage == 5 then
            MissionFail(true, true, "1_02B_FAIL_05")
        else
            MissionFail(true)
        end
    elseif bMissionPassed then
        F_OutroCuts()
        SoundEnableInteractiveMusic(true)
        MissionSucceed(true, false, false)
    end
    --print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_TableInit()
    --print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
    pedGary = {
        spawn = POINTLIST._1_02B_SPAWNGARYNEW,
        element = 1,
        model = 130
    }
    pedConstantine = {
        spawn = POINTLIST._1_02B_SPAWNCONSTANTINE,
        element = 1,
        model = 70
    }
    pedEunice = {
        spawn = POINTLIST._1_02B_SPAWNEUNICE,
        element = 1,
        model = 74
    }
    pedRussell = {
        spawn = POINTLIST._1_02B_SPAWNBULLY01,
        element = 1,
        model = 75
    }
    pedAlgie = {
        spawn = POINTLIST._1_02B_SPAWNGARYVICTIM,
        element = 1,
        model = 4
    }
    pedPrefect = {
        spawn = POINTLIST._1_02B_OUTROPREFECT,
        element = 1,
        model = 51
    }
    pedPrefectKarl = {
        spawn = POINTLIST._1_02B_SPAWNKARL,
        element = 1,
        model = 52
    }
    --print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_SetupLockerTable()
    tLockers = {
        {
            LockerTrig = TRIGGER._NLOCK01A01
        },
        {
            LockerTrig = TRIGGER._NLOCK01A02
        },
        {
            LockerTrig = TRIGGER._NLOCK01B
        },
        {
            LockerTrig = TRIGGER._NLOCK01B01
        },
        {
            LockerTrig = TRIGGER._NLOCK01B02
        },
        {
            LockerTrig = TRIGGER._NLOCK01B03
        },
        {
            LockerTrig = TRIGGER._NLOCK01B04
        },
        {
            LockerTrig = TRIGGER._NLOCK01B05
        },
        {
            LockerTrig = TRIGGER._NLOCK01B06
        },
        {
            LockerTrig = TRIGGER._NLOCK01B07
        },
        {
            LockerTrig = TRIGGER._NLOCK01B08
        },
        {
            LockerTrig = TRIGGER._NLOCK02A
        },
        {
            LockerTrig = TRIGGER._NLOCK02A01
        },
        {
            LockerTrig = TRIGGER._NLOCK02A02
        },
        {
            LockerTrig = TRIGGER._NLOCK02A03
        },
        {
            LockerTrig = TRIGGER._NLOCK02B
        },
        {
            LockerTrig = TRIGGER._NLOCK02B01
        },
        {
            LockerTrig = TRIGGER._NLOCK02B02
        },
        {
            LockerTrig = TRIGGER._NLOCK02B03
        },
        {
            LockerTrig = TRIGGER._NLOCK02B04
        },
        {
            LockerTrig = TRIGGER._NLOCK02B05
        },
        {
            LockerTrig = TRIGGER._NLOCK02B06
        },
        {
            LockerTrig = TRIGGER._NLOCK02B07
        },
        {
            LockerTrig = TRIGGER._NLOCK02B08
        },
        {
            LockerTrig = TRIGGER._NLOCK02B09
        },
        {
            LockerTrig = TRIGGER._NLOCK02B10
        }
    }
end

function F_SetupMission()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupWorld()")
    WeaponRequestModel(341)
    LoadPedModels({
        74,
        130,
        70,
        75,
        99,
        4,
        51,
        52,
        69,
        139
    })
    LoadAnimationGroup("1_02BYourSchool")
    LoadAnimationGroup("SGEN_I")
    LoadAnimationGroup("3_04WrongPtTown")
    LoadAnimationGroup("G_Johnny")
    LoadAnimationGroup("SNERD_I")
    LoadAnimationGroup("SNERD_S")
    LoadAnimationGroup("KISSF")
    LoadAnimationGroup("NIS_1_02B")
    LoadAnimationGroup("SBULL_X")
    numGreekboy = PedGetUniqueModelStatus(70)
    PedSetUniqueModelStatus(70, -1)
    numEunice = PedGetUniqueModelStatus(74)
    PedSetUniqueModelStatus(74, -1)
    numBully = PedGetUniqueModelStatus(99)
    PedSetUniqueModelStatus(99, -1)
    numAlgie = PedGetUniqueModelStatus(4)
    PedSetUniqueModelStatus(4, -1)
    numPedro = PedGetUniqueModelStatus(69)
    PedSetUniqueModelStatus(69, -1)
    numKarl = PedGetUniqueModelStatus(52)
    PedSetUniqueModelStatus(52, -1)
    LoadVehicleModels({ 282 })
    WeaponRequestModel(478)
    LoadWeaponModels({ 431, 398 })
    LoadActionTree("Act/Conv/1_02B.act")
    F_TableInit()
    PAnimSetPropFlag(TRIGGER._NLOCK01A, 7, true)
    PAnimSetPropFlag(TRIGGER._NLOCK01A, 19, true)
    PAnimSetPropFlag(TRIGGER._NLOCK01A, 22, true)
    PAnimSetPropFlag(TRIGGER._NLOCK01A, 11, true)
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupWorld()")
end

function T_ConSocLoop()
    local bTutorialStarted = false
    while bConSocTutorial do
        if PlayerIsInTrigger(TRIGGER._1_02B_BATHROOM) then
            --print("Player is in trigger.")
            if not bTutorialStarted then
                --print("Start the tutorial")
                TutorialStart("CONSTANTX")
                bTutorialStarted = true
            end
        else
            --print("Player left the trigger.")
            if bTutorialStarted then
                --print("Tutorial reset")
                bTutorialStarted = false
            end
        end
        Wait(100)
    end
    collectgarbage()
end

function F_Stage1()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
    F_Stage1_Setup()
    F_Stage1_Loop()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup() -- ! Modified
    --print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
    SoundPlayInteractiveStream("MS_MisbehavingLow.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetMidIntensityStream("MS_MisbehavingMid.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetHighIntensityStream("MS_MisbehavingHigh.rsm", MUSIC_DEFAULT_VOLUME)
    AreaTransitionPoint(2, POINTLIST._1_02B_OBJSCHOOL, nil, true)
    PedSocialOverrideLoad(24, "Mission/1_02BWantGift.act")
    PedSocialOverrideLoad(4, "Mission/1_02BFollow.act")
    PedSocialOverrideLoad(19, "Mission/1_02BFlee.act")
    PedSocialOverrideLoad(18, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(3, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(13, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(7, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(1, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(23, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(14, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(11, "Mission/1_02BGreeting.act")
    PlayerSocialOverrideLoad(32, "Mission/1_02BGiveChocolates.act")
    pedRussell.id = PedCreatePoint(pedRussell.model, pedRussell.spawn, pedRussell.element)
    PedSetMissionCritical(pedRussell.id, true, F_MissionCriticalRussell, true)
    PedSetPedToTypeAttitude(pedRussell.id, 13, 1)
    PedSetEmotionTowardsPed(pedRussell.id, gPlayer, 0)
    PedSetStationary(pedRussell.id, true)
    PlayerSocialDisableActionAgainstPed(pedRussell.id, 28, true)
    PlayerSocialDisableActionAgainstPed(pedRussell.id, 29, true)
    PlayerSocialDisableActionAgainstPed(pedRussell.id, 35, true)
    PlayerSocialDisableActionAgainstPed(pedRussell.id, 23, true)
    pedGary.id = PedCreatePoint(pedGary.model, pedGary.spawn, pedGary.element)
    PedSetMissionCritical(pedGary.id, true, F_MissionCriticalGary, false)
    PlayerSocialDisableActionAgainstPed(pedGary.id, 35, true)
    PlayerSocialDisableActionAgainstPed(pedGary.id, 29, true)
    PlayerSocialDisableActionAgainstPed(pedGary.id, 28, true)
    PedSetFlag(pedGary.id, 117, false)
    PedSetInfiniteSprint(pedGary.id, true)
    PedSetFlag(pedGary.id, 108, true)
    PedSetFlag(pedGary.id, 129, true)
    PedIgnoreStimuli(pedGary.id, true)
    pedGary.blip = AddBlipForChar(pedGary.id, 0, 0, 4, 0)
    CreateThread("T_MonitorGarysHealth")
    pedAlgie.id = PedCreatePoint(pedAlgie.model, pedAlgie.spawn, pedAlgie.element)
    PedSetGrappleTarget(pedGary.id, pedAlgie.id)
    PedSetActionNode(pedGary.id, "/Global/1_02B/Anims/GaryShove/GIVE", "Act/Conv/1_02B.act")
    local ActionTreeIndex
    ActionTreeIndex = RequestActionTree("NLockA")
    if 0 < ActionTreeIndex then
        while not IsActionTreeLoaded(ActionTreeIndex) do
            --print("()xxxxx[:::::::::::::::> Waiting for NLockA action tree to load.")
            Wait(0)
        end
        while not PAnimExists(TRIGGER._NLOCK01A) do -- ! This cycle was outside the if block
            --print("()xxxxx[:::::::::::::::> Waiting for locker to load.")
            Wait(0)
        end
    end
    F_SetupLockerTable()
    F_ResetLockerStates(false)
    PAnimSetActionNode(TRIGGER._NLOCK01A, "/Global/NLockA/Locked", "Act/Props/NLockA.act")
    PAnimSetPropFlag(TRIGGER._NLOCK01A, 7, true)
    PAnimSetPropFlag(TRIGGER._NLOCK01A, 19, false)
    PAnimSetPropFlag(TRIGGER._NLOCK01A, 11, true)
    CreateThread("T_CreateGary")
    CreateThread("T_MonitorPlayerLocation")
    PlayerSetControl(1)
    CameraReset()
    CameraFade(500, 1)
    Wait(1000)
    TutorialStart("YELAROW1")
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
    while PlayerIsInStealthProp() do
        Wait(0)
    end
    Wait(1000)
    PedSetMissionCritical(pedGary.id, false)
    PedDismissAlly(gPlayer, pedGary.id)
    PedSetMissionCritical(pedGary.id, true, F_MissionCriticalGary, false)
    PedShowHealthBar(pedGary.id, true, "1_02B_GARYHEALTH", false)
    PedStop(pedGary.id)
    PedClearObjectives(pedGary.id)
    PedMoveToPoint(pedGary.id, 2, POINTLIST._1_02B_GARYEUNICE, 1, F_GaryArrivedAtEunice)
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
    F_WaitForSpeech(pedGary.id)
    SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 35, "large")
    MissionObjectiveComplete(gObjective04c)
    Wait(2000)
    TextPrint("1_02B_MOBJ_02", 3, 1)
    gObjective01 = MissionObjectiveAdd("1_02B_MOBJ_02")
    pedGary.blip = AddBlipForChar(pedGary.id, 0, 0, 4, 0)
    PedSetMissionCritical(pedGary.id, false)
    PedDismissAlly(gPlayer, pedGary.id)
    PedSetMissionCritical(pedGary.id, true, F_MissionCriticalGary, false)
    PedShowHealthBar(pedGary.id, true, "1_02B_GARYHEALTH", false)
    PedMoveToPoint(pedGary.id, 2, POINTLIST._1_02B_OBJCAFE)
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
    if not bDiscoveredLocker then
        if PlayerIsInTrigger(TRIGGER._1_02B_LOCKERMESSAGE) then
            F_NewRussell(1)
            bDiscoveredLocker = true
        elseif PlayerIsInTrigger(TRIGGER._1_02B_LOCKERMESSAGE02) then
            F_NewRussell(2)
            bDiscoveredLocker = true
        end
    elseif not bApologizedToRussell then
        TutorialRemoveMessage()
        Wait(100)
        TutorialShowMessage("TUT_RUSS01A", 4500, false)
        PlayerSetControl(1)
        PlayerLockButtonInputsExcept(true, 10)
        PedLockTarget(gPlayer, pedRussell.id, 3)
        PedRegisterSocialCallback(pedRussell.id, 10, F_RussellSocialAction)
        PedOverrideSocialResponseToStimulus(pedRussell.id, 32, 10)
        PedSetWantsToSocializeWithPed(pedRussell.id, gPlayer, true, 1)
        Wait(4500)
        TutorialRemoveMessage()
        Wait(500)
        TutorialShowMessage("TUT_RUSS02C", -1, false)
        PlayerLockButtonInputsExcept(true, 10, 7)
        PlayerSocialDisableActionAgainstPed(pedRussell.id, 23, false)
        DoAction = false
        while DoAction == false do
            PedSocialKeepAlive(pedRussell.id)
            Wait(0)
        end
        TutorialRemoveMessage()
        Wait(500)
        TutorialShowMessage("TUT_RUSS03A", 4500, false)
        PlayerLockButtonInputsExcept(true, 10)
        DoAction = false
        PedOverrideSocialResponseToStimulus(pedRussell.id, 28, 10)
        PedSetWantsToSocializeWithPed(pedRussell.id, gPlayer, true, 17)
        PedSetRequiredGift(pedRussell.id, 22, false, true)
        PlayerSocialDisableActionAgainstPed(pedRussell.id, 32, true)
        Wait(4500)
        TutorialRemoveMessage()
        Wait(500)
        TutorialShowMessage("TUT_RUSS03C", -1, false)
        PlayerSocialDisableActionAgainstPed(pedRussell.id, 32, false)
        PlayerLockButtonInputsExcept(true, 10, 7)
        while DoAction == false do
            PedSocialKeepAlive(pedRussell.id)
            Wait(0)
        end
        PlayerSocialDisableActionAgainstPed(pedRussell.id, 32, true)
        PlayerSocialDisableActionAgainstPed(pedRussell.id, 23, true)
        PlayerSetMoney(PlayerGetMoney() - 200)
        TutorialRemoveMessage()
        Wait(1000)
        TutorialShowMessage("TUT_RUSS04A", 5000, false)
        DoAction = false
        PedOverrideSocialResponseToStimulus(pedRussell.id, 0, 10)
        PedSetRequiredGift(pedRussell.id, 0, false, false)
        while PedIsPlaying(pedRussell.id, "/Global/Ambient/SocialAnims/SocialHumiliateAttack", true) do
            Wait(0)
        end
        PedSetActionNode(pedRussell.id, "/Global/Ambient/SocialAnims/SocialAcceptApology/Bully/GiveUp", "Act/Anim/Ambient.act")
        Wait(500)
        while not PedIsPlaying(pedRussell.id, "/Global/Ambient/SocialAnims/SocialAcceptApology", true) do
            Wait(0)
        end
        while PedIsPlaying(pedRussell.id, "/Global/Ambient/SocialAnims/SocialAcceptApology", true) do
            Wait(0)
        end
        PlayerLockButtonInputsExcept(false)
        PlayerSetControl(0)
        PedLockTarget(gPlayer, -1)
        F_RussellLeave()
        bApologizedToRussell = true
    else
        if PlayerIsInTrigger(TRIGGER._1_02B_OBJLOCKER) then
            if MinigameIsReady() and shared.gLockpickSuccessFunction == nil then
                shared.gLockpickSuccessFunction = F_UnlockBalloons
            elseif PedIsPlaying(gPlayer, "/Global/NLockA/PedPropsActions/Locked/LoopPicking", true) and not bObjectiveLocker then
                SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 37, "large")
                bObjectiveLocker = true
            end
        else
            shared.gLockpickSuccessFunction = nil
        end
        if bUnlockLocker then
            bRusLockXTutorial = false
            ClothingGivePlayer("S_Bhat1", 0)
            bGavePlayerHat = true
            PlayerClearRewardStore()
            PAnimSetActionNode(TRIGGER._NLOCK01A, "/Global/NLockA/Unlocked/Default", "Act/Props/NLockA.act")
            Wait(1000)
            MissionObjectiveComplete(gObjective03)
            F_RemoveABlip(blipLocker)
            blipLocker = nil
            shared.gLockpickSuccessFunction = nil
            F_SetupLockerPrefect()
            PAnimSetPropFlag(TRIGGER._NLOCK01A, 7, true)
            PAnimSetPropFlag(TRIGGER._NLOCK01A, 19, true)
            PAnimSetPropFlag(TRIGGER._NLOCK01A, 22, true)
            PAnimSetPropFlag(TRIGGER._NLOCK01A, 11, true)
            bObjectiveHideInGarbage = true
            bUnlockLocker = false
        end
        if bObjectiveHideInGarbage then
            if not bReleasePrefect and PlayerIsInStealthProp() then
                F_ReleasePrefect()
                bReleasePrefect = true
            end
            if not bAllowPunishmentToDrop and PlayerIsInStealthProp() then
                PlayerSetPunishmentPoints(200)
                bAllowPunishmentToDrop = true
            end
            if PlayerGetPunishmentPoints() == 0 then
                PedRecruitAlly(gPlayer, pedGary.id)
                PedSetMissionCritical(pedGary.id, true, F_MissionCriticalGary, false)
                MissionObjectiveComplete(gObjective03b)
                bObjectiveLocker = false
                bObjectiveHideInGarbage = false
                BlipRemove(blipGarbageBin)
                pedGary.blip = AddBlipForChar(pedGary.id, 0, 0, 4, 0)
                TextPrint("1_02B_MOBJ_01", 3, 1)
                gObjective01 = MissionObjectiveAdd("1_02B_MOBJ_01")
                while DistanceBetweenPeds3D(gPlayer, pedGary.id) >= 5 do
                    Wait(0)
                end
                SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 81, "large", false, true)
                if not bReleasePrefect then
                    F_ReleasePrefect()
                    bReleasePrefect = true
                end
                bGoToStage2 = true
            end
        end
    end
end

function Stage2_Objectives()
    if not bDiscoveredSocial then
        if PlayerIsInTrigger(TRIGGER._1_02B_SOCIALMESSAGE) then
            F_cutEunice()
            TextPrint("1_02B_MOBJ_04", 4, 1)
            gObjective04 = MissionObjectiveAdd("1_02B_MOBJ_04")
            if gObjective01 then
                MissionObjectiveRemove(gObjective01)
                --print("()xxxxx[:::::::::::::::> [MOBJ] REMOVING: 1_02B_MOBJ_01")
                gObjective01 = nil
            end
            bDiscoveredSocial = true
        end
    elseif not bGreetedEunice then
        TutorialRemoveMessage()
        Wait(100)
        TutorialShowMessage("TUT_EUNSOC01", 4500, false)
        Wait(4500)
        TutorialRemoveMessage()
        Wait(500)
        TutorialShowMessage("TUT_EUNSOC03", -1, false)
        PlayerSocialDisableActionAgainstPed(pedEunice.id, 35, false)
        while not bPlayerGreetedEunice do
            PedSocialKeepAlive(pedEunice.id)
            if IsButtonPressed(10, 0) and bEuniceIsCrying then
                PedSetActionNode(pedEunice.id, "/Global/1_02B/Empty", "Act/Conv/1_02B.act")
                Wait(10)
                PedFaceObject(pedEunice.id, gPlayer, 3, 0)
                bEuniceIsCrying = false
            end
            Wait(0)
        end
        TutorialRemoveMessage()
        CameraSetFOV(30)
        CameraSetXYZ(-671.5806, -319.33948, 1.392932, -671.7506, -320.32483, 1.398956)
        CameraSetWidescreen(true)
        bGreetedEunice = true
        F_EnablePopulation()
        TextPrint("1_02B_EMPTY", 1, 1)
        F_RemoveABlip(pedEunice.blip)
        pedEunice.blip = nil
        PedUseSocialOverride(pedEunice.id, 18, false)
        PedSetRequiredGift(pedEunice.id, 1, false, true)
        PedStopSocializing(pedEunice.id)
        F_WaitForSpeech(pedEunice.id)
        CameraReset()
        CameraReturnToPlayer()
        CameraSetWidescreen(false)
        PlayerLockButtonInputsExcept(false)
        PedLockTarget(gPlayer, -1)
        F_SetupConstantine()
        MissionObjectiveComplete(gObjective04)
        gObjective04a = MissionObjectiveAdd("1_02B_MOBJ_04A")
        TextPrint("1_02B_MOBJ_04A", 4, 1)
        PedHideHealthBar()
        PedRecruitAlly(gPlayer, pedGary.id)
        PedSetMissionCritical(pedGary.id, true, F_MissionCriticalGary, false)
        bRetrievingChocolates = true
        Wait(3000)
        PedFaceHeading(pedEunice.id, 290, 1)
        bRemoveTutorials = false
        TutorialShowMessage("1_02B_TUT09", 6000)
        CreateThread("T_ConSocLoop")
    end
    if bRetrievingChocolates then
        if not bShownNewConstTut and PedIsTargetable(gPlayer, pedConstantine.id) then
            --print(".....813.....")
            bShownNewConstTut = true
        end
        if bConstantineReceivedMoney then
            --print(".....819.....")
            F_GiveCardToPlayer()
            bPlayerPickedUpTheChocolates = true
            bConstantineReceivedMoney = false
        end
        if not bConstantineHumiliated then
            tempStimBool, tempStimTarget = PedHasGeneratedStimulusOfType(gPlayer, 49)
            if tempStimBool and tempStimTarget == pedConstantine.id then
                --print(".....827.....")
                F_HumiliatedConstantine(true)
                bPlayerPickedUpTheChocolates = true
                bConstantineHumiliated = true
                bConstantineLostHealth = true
            end
        end
        if not bConstantineLostHealth and (gConstantineHealth > PedGetHealth(pedConstantine.id) or PedMePlaying(pedConstantine.id, "Hold_Idle", true)) and PedGetWhoHitMeLast(pedConstantine.id) == gPlayer then
            SoundPlayScriptedSpeechEvent(pedConstantine.id, "M_1_02B", 104, "medium", false, true)
            PedAttackPlayer(pedConstantine.id, 3)
            PedClearTether(pedConstantine.id)
            bConstantineLostHealth = true
            bConSocTutorial = false
        end
        if not bChocolatesSpawned and not bBullyDead and PedIsDead(pedConstantine.id) then
            --print(".....850.....")
            bPlayerPickedUpTheChocolates = true
            F_SpawnCard(true)
            bBullyDead = true
        end
        if not bGaryWaiting then
            if PlayerIsInTrigger(TRIGGER._1_02B_BATHROOM) then
                F_GaryWait()
                bGaryWaiting = true
            end
        elseif not PlayerIsInTrigger(TRIGGER._1_02B_BATHROOM) then
            F_GaryFollow()
            bGaryWaiting = false
        end
    end
    if bGaryWaiting and not PlayerIsInTrigger(TRIGGER._1_02B_BATHROOM) then
        F_GaryFollow()
        bGaryWaiting = false
    end
    if bChocolatesSpawned and not bPlayerHasChocolates and PlayerHasItem(478) then
        if gObjective04b then
            MissionObjectiveRemove(gObjective04b)
            --print("()xxxxx[:::::::::::::::> [MOBJ] REMOVING: 1_02B_MOBJ_04B")
        end
        TextPrint("1_02B_MOBJ_04C", 4, 1)
        bConSocTutorial = false
        gObjective04c = MissionObjectiveAdd("1_02B_MOBJ_04C")
        --print("()xxxxx[:::::::::::::::> [MOBJ] ADDING: 1_02B_MOBJ_04C")
        pedEunice.blip = AddBlipForChar(pedEunice.id, 0, 0, 4, 0)
        F_RemoveABlip(blipChocolates)
        F_RemoveABlip(pedConstantine.blip)
        blipChocolates = nil
        --print(".....891.....")
        bPlayerPickedUpTheChocolates = true
        bPlayerHasChocolates = true
        CreateThread("T_RemindForObj")
    end
    if bReturnChocolates and bPlayerHasChocolates and PlayerIsInAreaObject(pedEunice.id, 2, 3, 0) then
        F_NIS_ReturnChocolates()
        F_WaitForSpeech(pedEunice.id)
        SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 125, "supersize")
        if PedIsValid(pedConstantine.id) then
            PedMakeAmbient(pedConstantine.id)
        end
        ItemSetCurrentNum(478, 0)
        TutorialRemoveMessage()
        bGoToStage3 = true
        bReturnChocolates = false
    end
end

function F_ConstantinosWasHit()
    --print("Constantinos lost health??: ", tostring(bConstantineLostHealth))
    if bConstantineLostHealth then
        return 1
    end
    return 0
end

function F_PickedUpTheChocolates()
    --print(".....927.....")
    if bPlayerPickedUpTheChocolates then
        return 1
    end
    return 0
end

function Stage3_Objectives()
    if not bCompletedCafe and PlayerIsInTrigger(TRIGGER._1_02B_OBJCAFE) then
        PlayerSetControl(0)
        TextPrint("1_02B_EMPTY", 4, 1)
        --DebugPrint("************WMW - CALLING THE FADE HERE***************************")
        CameraFade(500, 0)
        Wait(500)
        --DebugPrint("************WMW - FADE AND WAIT ARE DONE***************************")
        SoundStopInteractiveStream(0)
        SoundEnableInteractiveMusic(false)
        F_RemoveABlip(pedGary.blip)
        PlayerSetPosPoint(POINTLIST._1_02B_EXITEDCAFE, 1)
        PlayCutsceneWithLoad("1-02D", true, false)
        bCompletedCafe = true
        CameraFade(500, 1)
        PlayerSetControl(1)
        bMissionPassed = true
    end
end

function F_RemoveABlip(blip)
    --print("()xxxxx[:::::::::::::::> [start] F_RemoveABlip")
    if blip ~= nil then
        BlipRemove(blip)
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_RemoveABlip")
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

function F_UnlockBalloons()
    --print("()xxxxx[:::::::::::::::> [start] F_UnlockBalloons")
    bUnlockLocker = true
    --print("()xxxxx[:::::::::::::::> [finish] F_UnlockBalloons")
end

function F_ResetLockerStates(LockTheLockers)
    --print("()xxxxx[:::::::::::::::> [start] F_ResetLockerStates() " .. tostring(LockTheLockers))
    local i, entry
    for i, entry in tLockers do
        if entry.LockerTrig > 0 then
            if LockTheLockers == true then
                PAnimSetActionNode(entry.LockerTrig, "/Global/NLockA/RandomLockState", "Act/Props/NLockA.act")
                PAnimSetPropFlag(entry.LockerTrig, 19, false)
                PAnimSetPropFlag(entry.LockerTrig, 11, false)
                PAnimSetPropFlag(entry.LockerTrig, 22, false)
            else
                PAnimSetActionNode(entry.LockerTrig, "/Global/NLockA/Locked", "Act/Props/NLockA.act")
                PAnimSetPropFlag(entry.LockerTrig, 11, true)
                PAnimSetPropFlag(entry.LockerTrig, 19, true)
                PAnimSetPropFlag(entry.LockerTrig, 22, true)
            end
        end
    end
    if LockTheLockers == false then
        PAnimSetPropFlag(TRIGGER._NLOCK01A, 7, false)
        PAnimSetPropFlag(TRIGGER._NLOCK01A, 19, false)
        PAnimSetPropFlag(TRIGGER._NLOCK01A, 22, false)
        PAnimSetPropFlag(TRIGGER._NLOCK01A, 11, true)
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_ResetLockerStates()")
end

function F_SetupLockerPrefect()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupLockerPrefect()")
    CameraSetWidescreen(false)
    SoundDisableSpeech_ActionTree()
    pedPrefectKarl.id = PedCreatePoint(pedPrefectKarl.model, pedPrefectKarl.spawn, pedPrefectKarl.element)
    PedIgnoreStimuli(pedPrefectKarl.id, true)
    PedSetMissionCritical(pedGary.id, false)
    PedDismissAlly(gPlayer, pedGary.id)
    PedStop(pedGary.id)
    PedClearObjectives(pedGary.id)
    PedMoveToPoint(pedGary.id, 0, POINTLIST._1_02B_MOVEGARYRUSSELL1, 2)
    PedSetMissionCritical(pedGary.id, true, F_MissionCriticalGary, false)
    PlayerSetControl(0)
    local tempX, tempY, tempZ = GetPointList(POINTLIST._1_02B_SPAWNKARL)
    PlayerFaceHeading(90, 1)
    Wait(1000)
    PedSetActionNode(gPlayer, "/Global/1_02B/Victory/Victory", "Act/Conv/1_02B.act")
    SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_11", 21, "supersize")
    PlayerSetPunishmentPoints(200)
    PlayerSetMinPunishmentPoints(199)
    TutorialShowMessage("TUT_PUN01", 4500, false)
    Wait(4500)
    TutorialShowMessage("TUT_PUN04", 4500, false)
    Wait(4500)
    TutorialShowMessage("TUT_PUN03", 4500, false)
    PedFaceXYZ(pedGary.id, tempX, tempY, tempZ, 0)
    DoublePedShadowDistance(true)
    CameraSetFOV(25)
    CameraSetXYZ(-609.12976, -321.81824, 4.363642, -608.84955, -320.89392, 4.105217)
    PedLockTarget(pedPrefectKarl.id, pedGary.id, 3)
    PedFollowPath(pedPrefectKarl.id, PATH._1_02B_KARLPATH, 0, 1)
    PedFaceObject(gPlayer, pedPrefectKarl.id, 2, 1)
    Wait(2000)
    SoundSetAudioFocusCamera()
    SoundPlayScriptedSpeechEvent(pedPrefectKarl.id, "M_1_02B", 83, "supersize", true)
    F_WaitForSpeech(pedPrefectKarl.id)
    SoundSetAudioFocusPlayer()
    PedMoveToPoint(pedGary.id, 2, POINTLIST._1_02B_GARYFLEELOCKER)
    PedFollowFocus(pedPrefectKarl.id, pedGary.id)
    Wait(2000)
    CameraSetWidescreen(true)
    PedFollowPath(gPlayer, PATH._1_02B_PLAYERTOTRASH, 0, 2)
    CameraSetFOV(40)
    CameraSetXYZ(-608.1951, -295.0979, 1.758579, -607.55145, -295.83392, 1.549697)
    CameraLookAtObject(gPlayer, 3, true, 1)
    Wait(3500)
    F_EnablePopulation()
    SoundEnableSpeech_ActionTree()
    CameraFade(500, 0)
    Wait(501)
    DoublePedShadowDistance(false)
    CameraSetWidescreen(false)
    CameraSetXYZ(-601.7148, -297.37604, 1.490144, -600.95184, -296.7314, 1.44164)
    Wait(1)
    CameraReturnToPlayer(false)
    CameraDefaultFOV()
    tempX, tempY, tempZ = GetPointList(POINTLIST._1_02B_MOVEPLAYERLOCKER)
    PlayerSetPosSimple(tempX, tempY, tempZ)
    tempX, tempY, tempZ = GetPointList(POINTLIST._1_02B_BLIPGARBAGE)
    PedFaceXYZ(gPlayer, tempX, tempY, tempZ, 0)
    CameraFade(500, 1)
    blipGarbageBin = BlipAddPoint(POINTLIST._1_02B_BLIPGARBAGE, 0, 1, 4, 0)
    TextPrint("1_02B_GARB_01", 3, 1)
    gObjective03b = MissionObjectiveAdd("1_02B_GARB_01")
    TutorialStart("InTheBin")
    Wait(1000)
    PlayerSetControl(1)
    Wait(1000)
    PedIgnoreStimuli(pedPrefectKarl.id, false)
    PedAttackPlayer(pedPrefectKarl.id, 3)
    SoundPlayAmbientSpeechEvent(pedPrefectKarl.id, "WARNING_COMING_TO_CATCH")
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupLockerPrefect()")
end

function F_ReleasePrefect()
    PedStop(pedPrefectKarl.id)
    PedClearObjectives(pedPrefectKarl.id)
    PedFlee(pedPrefectKarl.id, gPlayer)
    PedMakeAmbient(pedPrefectKarl.id)
    AreaEnableAllPatrolPaths()
end

function F_CleanupBlips()
    --print("()xxxxx[:::::::::::::::> [start] F_CleanupBlips")
    F_RemoveABlip(pedGary.blip)
    pedGary.blip = nil
    F_RemoveABlip(pedEunice.blip)
    pedEunice.blip = nil
    F_RemoveABlip(blipCafe)
    blipCafe = nil
    F_RemoveABlip(blipSocial)
    blipSocial = nil
    F_RemoveABlip(blipLocker)
    blipLocker = nil
    --print("()xxxxx[:::::::::::::::> [finish] F_CleanupBlips")
end

function F_EuniceCry()
    if bShouldEuniceCry then
        SoundPlayScriptedSpeechEventWrapper(pedEunice.id, "M_1_02B", 101, "large")
    end
end

function F_SetupConstantine()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupConstantine")
    pedConstantine.id = PedCreatePoint(pedConstantine.model, pedConstantine.spawn, pedConstantine.element)
    pedConstantine.blip = AddBlipForChar(pedConstantine.id, 11, 0, 4, 0)
    PedDisableMoveOutOfWay(pedConstantine.id, true)
    PedUseSocialOverride(pedConstantine.id, 18)
    PedUseSocialOverride(pedConstantine.id, 24)
    PedUseSocialOverride(pedConstantine.id, 3)
    PedUseSocialOverride(pedConstantine.id, 13)
    PedUseSocialOverride(pedConstantine.id, 7)
    PedUseSocialOverride(pedConstantine.id, 19)
    PedUseSocialOverride(pedConstantine.id, 11)
    PedOverrideSocialResponseToStimulus(pedConstantine.id, 10, 18)
    PedSetEmotionTowardsPed(pedConstantine.id, gPlayer, 4, false)
    PedSetTetherToTrigger(pedConstantine.id, TRIGGER._1_02B_CONSTTETHER)
    PlayerSocialEnableOverrideAgainstPed(pedConstantine.id, 32, true)
    PlayerSocialDisableActionAgainstPed(pedConstantine.id, 28, true)
    PedSetActionNode(pedConstantine.id, "/Global/1_02B/ConstantinosIdle/Load", "Act/Conv/1_02B.act")
    gConstantineHealth = PedGetHealth(pedConstantine.id)
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupConstantine")
end

function F_SpawnCard(spawnOnCorpse)
    --print("()xxxxx[:::::::::::::::> [start] F_SpawnCard")
    local tempX, tempY, tempZ = 0, 0, 0
    if spawnOnCorpse then
        tempX, tempY, tempZ = PedGetPosXYZ(pedConstantine.id)
        pickupChocolates = PickupCreateXYZ(478, tempX, tempY, tempZ, "PermanentMission")
    else
        tempX, tempY, tempZ = GetPointList(POINTLIST._1_02B_SPAWNCHOCOLATES)
        pickupChocolates = PickupCreateXYZ(478, tempX, tempY, tempZ, "PermanentMission")
    end
    blipChocolates = BlipAddXYZ(tempX, tempY, tempZ, 0, 4)
    if PedIsValid(pedConstantine.id) then
        F_RemoveABlip(pedConstantine.blip)
        pedConstantine.blip = nil
    end
    if not bBullyFleeDontWaitInCallback then
        Wait(1000)
    end
    MissionObjectiveRemove(gObjective04a)
    --print("()xxxxx[:::::::::::::::> [MOBJ] REMOVING: 1_02B_MOBJ_04A")
    gObjective04b = MissionObjectiveAdd("1_02B_MOBJ_04B")
    --print("()xxxxx[:::::::::::::::> [MOBJ] ADDING: 1_02B_MOBJ_04B")
    TextPrint("1_02B_MOBJ_04B", 4, 1)
    bRetrievingChocolates = false
    bReturnChocolates = true
    bChocolatesSpawned = true
    --print("()xxxxx[:::::::::::::::> [finish] F_SpawnCard")
end

function F_BullyFlee()
    --print("()xxxxx[:::::::::::::::> [start] F_BullyFlee")
    if not bConstantineHumiliated then
        bBullyFleeDontWaitInCallback = true
        F_HumiliatedConstantine(false)
        bConstantineHumiliated = true
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_BullyFlee")
end

function F_GiveCardToPlayer()
    --print("()xxxxx[:::::::::::::::> [start] F_GiveCardToPlayer")
    if PedIsValid(pedConstantine.id) then
        F_RemoveABlip(pedConstantine.blip)
        pedConstantine.blip = nil
    end
    GiveItemToPlayer(478)
    PedUseSocialOverride(pedConstantine.id, 4, false)
    PedUseSocialOverride(pedConstantine.id, 3, false)
    PedUseSocialOverride(pedConstantine.id, 7, false)
    PedUseSocialOverride(pedConstantine.id, 23, false)
    PedUseSocialOverride(pedConstantine.id, 13, false)
    PedUseSocialOverride(pedConstantine.id, 1, false)
    PedUseSocialOverride(pedConstantine.id, 14, false)
    PedUseSocialOverride(pedConstantine.id, 11, false)
    PedSetRequiredGift(pedConstantine.id, 0, false)
    PedClearTether(pedConstantine.id)
    PedMakeAmbient(pedConstantine.id)
    MissionObjectiveRemove(gObjective04a)
    --print("()xxxxx[:::::::::::::::> [MOBJ] REMOVING: 1_02B_MOBJ_04A")
    SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 126, "supersize")
    gObjective04c = MissionObjectiveAdd("1_02B_MOBJ_04C")
    --print("()xxxxx[:::::::::::::::> [MOBJ] ADDING: 1_02B_MOBJ_04C")
    TextPrint("1_02B_MOBJ_04C", 4, 1)
    bConSocTutorial = false
    pedEunice.blip = AddBlipForChar(pedEunice.id, 6, 0, 4)
    PlayerSocialEnableOverrideAgainstPed(pedEunice.id, 32, true)
    PlayerSocialEnableOverrideAgainstPed(pedConstantine.id, 32, false)
    bRetrievingChocolates = false
    bReturnChocolates = true
    bPlayerHasChocolates = true
    CreateThread("T_RemindForObj")
    --print("()xxxxx[:::::::::::::::> [finish] F_GiveCardToPlayer")
end

function T_RemindForObj()
    Wait(5000)
    if bReminderOff == false then
        TutorialStart("PUNHIDINGX")
    end
    collectgarbage()
end

function F_ConstantineReceivedMoney()
    --print("()xxxxx[:::::::::::::::> [start] F_ConstantineReceivedMoney")
    SoundPlayScriptedSpeechEventWrapper(pedConstantine.id, "M_1_02B", 99)
    bConstantineReceivedMoney = true
    --print("()xxxxx[:::::::::::::::> [finish] F_ConstantineReceivedMoney")
end

function F_EuniceGreeting()
    --print("()xxxxx[:::::::::::::::> [start] F_EuniceGreeting")
    SoundStopCurrentSpeechEvent(pedEunice.id)
    SoundPlayScriptedSpeechEventWrapper(pedEunice.id, "M_1_02B", 95)
    bPlayerGreetedEunice = true
    PedSetFlag(pedEunice.id, 132, true)
    --print("()xxxxx[:::::::::::::::> [finish] F_EuniceGreeting")
end

function F_ConstantineGreeting()
    --print("()xxxxx[:::::::::::::::> [start] F_ConstantineGreeting")
    SoundPlayScriptedSpeechEventWrapper(pedConstantine.id, "M_1_02B", 97)
    PedSetRequiredGift(pedConstantine.id, 22, false, true)
    PedUseSocialOverride(pedConstantine.id, 4)
    PedStopSocializing(pedConstantine.id)
    --print("()xxxxx[:::::::::::::::> [finish] F_ConstantineGreeting")
end

function F_FinishSocialObjective()
    --print("()xxxxx[:::::::::::::::> [start] F_FinishSocialObjective")
    bCompletedSocial = true
    if PedIsValid(pedConstantine.id) then
        PedMakeAmbient(pedConstantine.id)
    end
    ItemSetCurrentNum(478, 0)
    TutorialRemoveMessage()
    if F_PedExists(pedEunice.id) then
        PedDisableMoveOutOfWay(pedEunice.id, false)
        PedMakeAmbient(pedEunice.id)
        PedWander(pedEunice.id, 0)
    end
    PedSetFlag(gPlayer, 13, false)
    CameraSetWidescreen(false)
    ExitNIS()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    --print("()xxxxx[:::::::::::::::> [finish] F_FinishSocialObjective")
end

function F_GaryWait()
    --print("()xxxxx[:::::::::::::::> [start] F_GaryWait")
    if not bGarySpeechConstantinos then
        SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 124, "supersize")
        bGarySpeechConstantinos = true
    end
    PedSetMissionCritical(pedGary.id, false)
    PedDismissAlly(gPlayer, pedGary.id)
    PedSetMissionCritical(pedGary.id, true, F_MissionCriticalGary, false)
    PedStop(pedGary.id)
    PedClearObjectives(pedGary.id)
    PedMoveToPoint(pedGary.id, 1, POINTLIST._1_02B_GARYWAITBATHROOM)
    PedShowHealthBar(pedGary.id, true, "1_02B_GARYHEALTH", false)
    --print("()xxxxx[:::::::::::::::> [finish] F_GaryWait")
end

function F_GaryFollow()
    --print("()xxxxx[:::::::::::::::> [start] F_GaryFollow")
    PedHideHealthBar()
    PedRecruitAlly(gPlayer, pedGary.id)
    PedSetMissionCritical(pedGary.id, true, F_MissionCriticalGary, false)
    --print("()xxxxx[:::::::::::::::> [finish] F_GaryFollow")
end

function F_HumiliatedConstantine(waitForSpeech)
    PlayerSocialDisableActionAgainstPed(pedConstantine.id, 30, true)
    SoundPlayScriptedSpeechEventWrapper(pedConstantine.id, "M_1_02B", 98)
    if waitForSpeech == true then
        F_WaitForSpeech(pedConstantine.id)
    end
    F_SpawnCard(true)
    PedUseSocialOverride(pedConstantine.id, 4, false)
    PedSetRequiredGift(pedConstantine.id, 0, false)
    PedDisableMoveOutOfWay(pedConstantine.id, false)
    PedClearObjectives(pedConstantine.id)
    PedClearTether(pedConstantine.id)
    PedMakeAmbient(pedConstantine.id)
    PedFollowPath(pedConstantine.id, PATH._1_02B_BULLYFLEE, 0, 1)
    if PedIsValid(pedConstantine.id) then
        F_RemoveABlip(pedConstantine.blip)
        pedConstantine.blip = nil
    end
end

function F_ShutOffPrefectPath()
    if not shared.b102LockerComplete then
        while not AreaDisablePatrolPath(PATH._HALLSPATROL_1A) do
            Wait(0)
        end
        bPrefectPathActive = false
    end
end

function F_PlayerGiveGiftCallback()
    StopAmbientPedAttacks()
    PlayerSocialEnableOverrideAgainstPed(pedEunice.id, 32, false)
    bEuniceReceivedChocolate = true
end

function F_IsPlayerInWarnZone()
    if PlayerIsInTrigger(TRIGGER._1_02B_WARN01) or PlayerIsInTrigger(TRIGGER._1_02B_WARN02) or PlayerIsInTrigger(TRIGGER._1_02B_WARN03) or PlayerIsInTrigger(TRIGGER._1_02B_WARN04) then
        return true
    else
        return false
    end
end

function F_RussellLeave()
    PedStopSocializing(pedRussell.id)
    PedStop(pedRussell.id)
    PedClearObjectives(pedRussell.id)
    PedSetTaskNode(pedRussell.id, "/Global/AI", "Act/AI/AI.act")
    PedFlee(pedRussell.id, gPlayer)
    PedMakeAmbient(pedRussell.id)
    Wait(3000)
    if gObjective01 then
        MissionObjectiveRemove(gObjective01)
        gObjective01 = nil
    end
    SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 119, "supersize", true)
    blipLocker = BlipAddPoint(POINTLIST._1_02B_OBJLOCKER, 0, 1, 1, 7)
    Wait(2000)
    TextPrint("1_02B_MOBJ_03", 4, 1)
    gObjective03 = MissionObjectiveAdd("1_02B_MOBJ_03")
    CreateThread("T_LockerLoop")
    PlayerSetControl(1)
    F_EnablePopulation()
end

function F_RussellSocialAction()
    --print("()xxxxx[:::::::::::::::> [start] F_RussellSocialAction")
    DoAction = true
    --print("()xxxxx[:::::::::::::::> [finish] F_RussellSocialAction")
end

function F_DisablePopulation()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

function F_EnablePopulation()
    AreaRevertToDefaultPopulation()
end

function F_CreateEunice()
    pedEunice.id = PedCreatePoint(pedEunice.model, pedEunice.spawn, pedEunice.element)
    PedSetMissionCritical(pedEunice.id, true, F_MissionCriticalEunice, true)
    PedDisableMoveOutOfWay(pedEunice.id, true)
    PedSetActionNode(pedEunice.id, "/Global/1_02B/Crying/CryLoop", "Act/Conv/1_02B.act")
    bEuniceIsCrying = true
    bShouldEuniceCry = true
    PlayerSocialDisableActionAgainstPed(pedEunice.id, 28, true)
    PlayerSocialDisableActionAgainstPed(pedEunice.id, 29, true)
    PlayerSocialDisableActionAgainstPed(pedEunice.id, 35, true)
    PedUseSocialOverride(pedEunice.id, 18)
    PedSetEmotionTowardsPed(pedEunice.id, gPlayer, 8)
    PedSetPedToTypeAttitude(pedEunice.id, 13, 4)
    PedOverrideStat(pedEunice.id, 6, 0)
    PedFollowPath(pedEunice.id, PATH._1_02B_PATHEUNICE, 0, 0)
end

function F_DisableAndClearPopulation()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

function F_ApologizedToConstantinos()
    PedStop(pedConstantine.id)
    PedClearObjectives(pedConstantine.id)
    PedSetEmotionTowardsPed(pedConstantine.id, gPlayer, 7, true)
end

function F_cutEunice()
    --print("()xxxxx[:::::::::::::::> [start] F_cutEunice")
    F_RemoveABlip(pedGary.blip)
    AreaClearAllPeds()
    F_DisablePopulation()
    F_CreateEunice()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PlayerSetControl(0)
    if PlayerHasWeapon(381) then
        PedDestroyWeapon(gPlayer, 381)
    end
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true, false)
    PlayerSetPunishmentPoints(0)
    CameraSetFOV(40)
    CameraSetXYZ(-668.8145, -318.77008, 1.499427, -669.49384, -319.49207, 1.368598)
    CameraLookAtObject(pedEunice.id, 2, true, 0.5)
    local tempX, tempY, tempZ = GetPointList(POINTLIST._1_02B_MOVEPLAYEREUNICE)
    PlayerSetPosSimple(tempX, tempY, tempZ)
    PedStop(pedGary.id)
    PedClearObjectives(pedGary.id)
    PedSetActionNode(pedGary.id, "/Global/1_02B/Empty", "Act/Conv/1_02B.act")
    Wait(1000)
    PedSetPosPoint(pedGary.id, POINTLIST._1_02B_GARYEUNICE, 1)
    SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 120, "speech", true)
    Wait(2000)
    PedFollowPath(pedGary.id, PATH._1_02B_GARYTOEUNICE, 0, 0)
    Wait(250)
    PedFollowPath(gPlayer, PATH._1_02B_PLAYERTOEUNICE, 0, 0)
    F_WaitForSpeech(pedGary.id)
    CameraFade(500, 0)
    Wait(501)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    PedFaceObject(gPlayer, pedEunice.id, 2, 0)
    CameraSetXYZ(-670.87067, -317.12982, 1.713793, -670.9902, -318.11157, 1.565998)
    Wait(1)
    CameraReturnToPlayer(false)
    CameraDefaultFOV()
    PlayerSetControl(1)
    PlayerLockButtonInputsExcept(true, 10, 7)
    PedLockTarget(gPlayer, pedEunice.id, 3)
    PedFaceObject(gPlayer, pedEunice.id, 2, 1)
    CameraFade(500, 1)
    Wait(501)
    SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 121, "large")
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    pedEunice.blip = AddBlipForChar(pedEunice.id, 0, 0, 4, 0)
    TextPrint("1_02B_MOBJ_04", 1000, 1)
    --print("()xxxxx[:::::::::::::::> [finish] F_cutEunice")
end

function F_OutroCuts()
    --print("()xxxxx[:::::::::::::::> [start] F_OutroCuts")
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    SoundStopPA()
    PAnimCloseDoor(10029, -628, -327, 1)
    PAnimCloseDoor(10030, -628, -327, 1)
    PlayerSetControl(0)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true, false)
    CameraFade(500, 1)
    bRecruitedGary = false
    PedSetMissionCritical(pedGary.id, false)
    PedDismissAlly(gPlayer, pedGary.id)
    PedStop(pedGary.id)
    PedClearObjectives(pedGary.id)
    PedClearFocus(pedGary.id)
    pedPrefect.id = PedCreatePoint(pedPrefect.model, pedPrefect.spawn, pedPrefect.element)
    PedSetPosPoint(pedGary.id, POINTLIST._1_02B_OUTROGARY, 1)
    PedFaceHeading(pedPrefect.id, 0, 0)
    CameraSetFOV(65)
    CameraSetXYZ(-640.07544, -295.173, 1.401847, -639.48755, -295.97488, 1.297521)
    SoundPlayScriptedSpeechEvent(pedPrefect.id, "M_1_02B", 169, "supersize")
    PedSetActionNode(pedPrefect.id, "/Global/1_02B/PrefectEdwardWarn/Animation", "Act/Conv/1_02B.act")
    F_WaitForSpeech(pedPrefect.id)
    PedMoveToPoint(pedGary.id, 1, POINTLIST._1_02B_OUTROGARYFLEE)
    bGaryRanToClass = true
    Wait(2000)
    PedMakeAmbient(pedPrefect.id)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    --print("()xxxxx[:::::::::::::::> [finish] F_OutroCuts")
end

function F_NIS_ReturnChocolates()
    --print("()xxxxx[:::::::::::::::> [start] F_NIS_ReturnChocolates")
    bReminderOff = true
    CameraSetWidescreen(true)
    if PlayerHasWeapon(381) then
        PedDestroyWeapon(gPlayer, 381)
    end
    F_MakePlayerSafeForNIS(true, false)
    PlayerSetControl(0)
    PedSetMissionCritical(pedEunice.id, false)
    PedSetStationary(pedEunice.id, false)
    PedFaceObject(pedEunice.id, gPlayer, 3, 1)
    PedStop(pedEunice.id)
    PedClearObjectives(pedEunice.id)
    PedFaceObject(pedEunice.id, gPlayer, 3, 1)
    PedLockTarget(gPlayer, pedEunice.id, 3)
    Wait(500)
    PedSetActionNode(gPlayer, "/Global/Player/Gifts/GiveChocolates/GiveChocolateBox", "Act/Player.act")
    while PedIsPlaying(gPlayer, "/Global/Player/Gifts/GiveChocolates", true) do
        Wait(0)
    end
    while not PedIsPlaying(pedEunice.id, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses/Dismiss", true) do
        Wait(0)
    end
    PedSetRequiredGift(pedEunice.id, 0, false, true)
    PedSetFlag(pedEunice.id, 132, false)
    PlayerSocialDisableActionAgainstPed(pedEunice.id, 28, false)
    PlayerSocialDisableActionAgainstPed(pedEunice.id, 29, false)
    PedLockTarget(gPlayer, -1)
    PedLockTarget(pedEunice.id, -1)
    F_RemoveABlip(pedEunice.blip)
    PedWander(pedEunice.id, 0)
    PedMakeAmbient(pedEunice.id)
    CameraReturnToPlayer()
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    bChocolatesDelivered = true
    --print("()xxxxx[:::::::::::::::> [finish] F_NIS_ReturnChocolates")
end

function F_NewRussell(whichWay)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PlayerSetControl(0)
    if PlayerHasWeapon(381) then
        PedDestroyWeapon(gPlayer, 381)
    end
    F_MakePlayerSafeForNIS(true, false)
    CameraSetWidescreen(true)
    if PlayerGetMoney() <= 199 then
        PlayerSetMoney(200)
    end
    PlayerSetPunishmentPoints(0)
    PedStop(pedGary.id)
    PedClearObjectives(pedGary.id)
    PedSetActionNode(pedGary.id, "/Global/1_02B/Empty", "Act/Conv/1_02B.act")
    local tempX, tempY, tempZ = 0, 0, 0
    if whichWay == 1 then
        CameraSetFOV(70)
        tempX, tempY, tempZ = GetPointList(POINTLIST._1_02B_MOVEPLAYERRUSSELL1)
        PlayerSetPosSimple(tempX, tempY, tempZ)
        CameraSetFOV(40)
        CameraSetXYZ(-604.6959, -302.1921, 1.726116, -604.7079, -303.1871, 1.628526)
        PedSetPosPoint(pedGary.id, POINTLIST._1_02B_MOVEGARYRUSSELL1)
        PedFaceObject(gPlayer, pedRussell.id, 2, 0)
    else
        CameraSetFOV(70)
        tempX, tempY, tempZ = GetPointList(POINTLIST._1_02B_MOVEPLAYERRUSSELL2)
        PlayerSetPosSimple(tempX, tempY, tempZ)
        CameraSetFOV(30)
        CameraSetXYZ(-605.7907, -311.2778, 1.540111, -605.70233, -310.28296, 1.491012)
        PedSetPosPoint(pedGary.id, POINTLIST._1_02B_MOVEGARYRUSSELL2)
        PedFaceObject(gPlayer, pedRussell.id, 2, 0)
    end
    PedSetMissionCritical(pedRussell.id, false)
    PedHideHealthBar()
    PedRecruitAlly(gPlayer, pedGary.id)
    PedSetMissionCritical(pedGary.id, true, F_MissionCriticalGary, false)
    SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 118, "speech", true)
    Wait(3000)
    PedLockTarget(pedRussell.id, gPlayer, 3)
    PedSetStationary(pedRussell.id, false)
    F_WaitForSpeech(pedGary.id)
    PedMoveToObject(pedRussell.id, gPlayer, 2, 1)
    Wait(500)
    CameraLookAtObject(pedRussell.id, 2, false, 0.7)
    PedLockTarget(gPlayer, pedRussell.id, 3)
    PedLockTarget(pedRussell.id, gPlayer, 3)
    while not PedIsInAreaObject(pedRussell.id, gPlayer, 2, 1.5, 0) do
        Wait(0)
    end
    PedClearObjectives(pedRussell.id)
    CameraFade(500, 0)
    Wait(500)
    PedFaceObjectNow(gPlayer, pedRussell.id, 2)
    PedFaceObjectNow(pedRussell.id, gPlayer, 2)
    F_MakePlayerSafeForNIS(false)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    CameraReset()
    F_DisablePopulation()
    AreaClearAllPeds()
    F_RemoveABlip(pedGary.blip)
    CameraFade(500, 1)
    Wait(500)
    --print("()xxxxx[:::::::::::::::> [finish] F_cutBullies")
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
end

function F_StartAtStage2()
    SoundPlayInteractiveStream("MS_FriendshipAllyLow.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetMidIntensityStream("MS_FriendshipAllyMid.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetHighIntensityStream("MS_FriendshipAllyHigh.rsm", MUSIC_DEFAULT_VOLUME)
    AreaTransitionPoint(2, POINTLIST._1_02B_OBJSCHOOL, nil, true)
    PedSocialOverrideLoad(24, "Mission/1_02BWantGift.act")
    PedSocialOverrideLoad(4, "Mission/1_02BFollow.act")
    PedSocialOverrideLoad(19, "Mission/1_02BFlee.act")
    PedSocialOverrideLoad(18, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(3, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(13, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(7, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(1, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(23, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(14, "Mission/1_02BGreeting.act")
    PedSocialOverrideLoad(11, "Mission/1_02BGreeting.act")
    PlayerSocialOverrideLoad(32, "Mission/1_02BGiveChocolates.act")
    pedGary.id = PedCreatePoint(pedGary.model, pedGary.spawn, pedGary.element)
    PedSetMissionCritical(pedGary.id, true, F_MissionCriticalGary, false)
    PlayerSocialDisableActionAgainstPed(pedGary.id, 35, true)
    PlayerSocialDisableActionAgainstPed(pedGary.id, 29, true)
    PlayerSocialDisableActionAgainstPed(pedGary.id, 28, true)
    PedSetFlag(pedGary.id, 117, false)
    PedSetInfiniteSprint(pedGary.id, true)
    PedSetFlag(pedGary.id, 108, true)
    PedIgnoreStimuli(pedGary.id, true)
    gTimerRecruitGary = GetTimer()
    PedSetActionNode(pedGary.id, "/Global/1_02B/Empty", "Act/Conv/1_02B.act")
    PedSetMissionCritical(pedGary.id, true, F_MissionCriticalGary, false)
    SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 117, "supersize")
    Wait(1000)
    PedShowHealthBar(pedGary.id, true, "1_02B_GARYHEALTH", false)
    pedGary.blip = AddBlipForChar(pedGary.id, 0, 0, 4, 0)
    CreateThread("T_MonitorPlayerLocation")
    CameraFade(500, 1)
    Wait(500)
    PlayerSetControl(1)
    F_Stage2()
end

function F_StartAtStage3()
end

function T_CreateGary()
    --print("()xxxxx[:::::::::::::::> [start] T_CreateGary()")
    gTimerRecruitGary = GetTimer()
    SoundPlayScriptedSpeechEvent(pedAlgie.id, "M_1_02B", 76)
    while gTimerRecruitGary + 3000 >= GetTimer() do
        if PlayerIsInTrigger(TRIGGER._1_02B_RECRUITGARY) then
            break
        end
        Wait(0)
    end
    PedSetActionNode(pedGary.id, "/Global/1_02B/Empty", "Act/Conv/1_02B.act")
    PedSetActionNode(pedAlgie.id, "/Global/1_02B/Empty", "Act/Conv/1_02B.act")
    PedMakeAmbient(pedAlgie.id)
    PedFlee(pedAlgie.id, pedGary.id)
    SoundPlayScriptedSpeechEvent(pedGary.id, "M_1_02B", 117, "supersize")
    Wait(1000)
    PedShowHealthBar(pedGary.id, true, "1_02B_GARYHEALTH", false)
    TextPrint("1_02B_MOBJ_01", 3, 1)
    gObjective01 = MissionObjectiveAdd("1_02B_MOBJ_01")
    PedMoveToPoint(pedGary.id, 2, POINTLIST._1_02B_GARYLOCKER, 1)
    collectgarbage()
    --print("()xxxxx[:::::::::::::::> [finish] T_CreateGary()")
end

function T_MonitorPlayerLocation()
    --print("()xxxxx[:::::::::::::::> [start] T_MonitorPlayerLocation()")
    while bLoop do
        if AreaGetVisible() == 2 then
            if bPrefectPathActive then
                F_ShutOffPrefectPath()
            end
            if F_IsPlayerInWarnZone() then
                TextPrint("1_02B_WARNLEAVE", 1, 1)
            end
            bPlayerIsInsideSchool = true
        else
            bPrefectPathActive = true
            bPlayerIsInsideSchool = false
            gMissionFailMessage = 5
            bMissionFailed = true
        end
        Wait(0)
    end
    collectgarbage()
    --print("()xxxxx[:::::::::::::::> [finish] T_MonitorPlayerLocation()")
end

function T_LockerLoop() -- ! Modified
    local bTutorialStarted = false
    while bRusLockXTutorial do
        if PlayerIsInTrigger(TRIGGER._1_02B_OBJLOCKER) then
            --print("Player is in trigger.")
            --[[
            if not bTutorialStarted then
                print("Start the tutorial")
                if MinigameIsActive() then
                    TutorialStart("RUSLOCKX")
                    bTutorialStarted = true
                end
            ]] -- Changed to:
            if not bTutorialStarted and MinigameIsActive() then
                --print("Start the tutorial")
                TutorialStart("RUSLOCKX")
                bTutorialStarted = true
            elseif bTutorialStarted then
                if not MinigameIsActive() then
                    TutorialStop("RUSLOCKX")
                end
            end
        else
            --print("Player left the trigger.")
            if bTutorialStarted then
                --print("Tutorial reset")
                bTutorialStarted = false
            end
        end
        Wait(100)
    end
    collectgarbage()
end

function F_MissionCriticalEunice()
    --print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalEunice")
    gMissionFailMessage = 1
    bMissionFailed = true
    --print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalEunice")
end

function F_MissionCriticalGary()
    --print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalGary")
    gMissionFailMessage = 2
    bMissionFailed = true
    --print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalGary")
end

function F_MissionCriticalRussell()
    --print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalRussell")
    gMissionFailMessage = 3
    bMissionFailed = true
    --print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalRussell")
end

function F_MissionCriticalRussellsGoon()
    --print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalRussellsGoon")
    gMissionFailMessage = 4
    bMissionFailed = true
    --print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalRussellsGoon")
end

function F_GaryArrivedAtEunice()
    --print("()xxxxx[:::::::::::::::> [start] F_GaryArrivedAtEunice")
    PedClearObjectives(pedGary.id)
    bGaryArrivedAtEunice = true
    --print("()xxxxx[:::::::::::::::> [finish] F_GaryArrivedAtEunice")
end

function F_SocialSystemCanActivate()
    if bActivateSocialSystem then
        return 1
    end
    return 0
end

function F_AreLockersAvailable()
    if bCompletedLocker then
        return 1
    end
    return 0
end

function T_MonitorGarysHealth()
    local originalHealth = PedGetHealth(pedGary.id)
    while not (bMissionPassed or bMissionFailed) do
        if pedGary.id and PedIsValid(pedGary.id) and (PedGetHealth(pedGary.id) / originalHealth) < 0.75 and not IsMissionCompleated("CLIMBING") then
            TutorialStart("CLIMBING")
            break
        end
        Wait(1000)
    end
    collectgarbage()
end
