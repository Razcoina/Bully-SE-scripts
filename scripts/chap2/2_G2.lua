--[[ Changes to this file:
    * Modified function F_Stage3_Objectives, may require testing
]]

function F_PlayerHasFlowers()
    if IsMissionFromDebug() then
        ItemSetCurrentNum(475, 1)
    end
    return PlayerHasItem(475)
end

local bHasFlowers = F_PlayerHasFlowers()
local bDebugFlag = false
local gDebugLevel = 3
local bLoop = true
local bMonitorMinigames = true
local bGoToStage2 = false
local bGoToStage3 = false
local bMissionPassed = false
local bMissionFailed = false
local gStage = 0
local bPlayerHasBear = false
local bSetupDunkTank = false
local bSetupBaseballToss = false
local bSetupCarnieStriker = false
local bSetupShootingGallery = false
local bSetupCarnieStore = false
local bMiniGameRunning = false
local gLastMGScore = 0
local gLastGamePlayed = "none"
local tableTrackGameStats = {}
local gPinkyMGActionTimer = 0
local bMonitorPinky = true
local bIntroPinkyArrived = false
local bTextPlayDunk = false
local bTextPlayShoot = false
local bTextPlayToss = false
local bTextPlayStriker = false
local bTicketCount = 0
local gTicketsRequired = 10
local bPinkyHasArrived = false
local bPinkyFlee = false
local bRanOutro = false
local bCleanupPassed = false
local bPinkyWarn = false
local bStage3ProgressOnce = false
local bPlayerHasGift = false
local bPinkyHasBear = false
local bTextPinkyFreak = false
local bPinkyReceivedBear = false
local bPlayerGetBearDialgoue = false
local bTextCuteBear = false
local bGiveBearObjective = false
local bTentEntranceBlipped = false
local gPinkyDialogueRepeatTime = 20000
local gMeetPinkyTime = 240
local bSkipFirstCutscene = false
local gMissionFailMessage = 0
local gPlayersTicketCountBeforeStartingMission = 0
local gClockHour, gClockMin = 0, 0

function MissionSetup()
    --print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
    shared.g2_G2_ReturnPinky = false
    shared.g2_G2_HidePinky = false
    MissionAllowConcurrentMissions(true)
    if bHasFlowers then
        PlayCutsceneWithLoad("2-G2", true)
        MissionDontFadeIn()
        DATLoad("2_G2.DAT", 2)
        DATInit()
    else
        MissionSurpressMissionNameText()
    end
    if PlayerGetMoney() < 1000 then
        PlayerSetMoney(1000)
    end
    --print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
    if bHasFlowers then
        CameraSetWidescreen(false)
        SoundEnableSpeech_ActionTree()
        F_MakePlayerSafeForNIS(false)
        AreaDisableCameraControlForTransition(false)
        --print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
        F_CleanUpPinky()
        SoundStopInteractiveStream()
        if not bMissionPassed then
            ItemSetCurrentNum(495, gPlayersTicketCountBeforeStartingMission)
            ItemSetCurrentNum(363, 0)
        end
        PedHideHealthBar()
        AreaRevertToDefaultPopulation()
        CounterMakeHUDVisible(false)
        DATUnload(2)
        DATInit()
        UnLoadAnimationGroup("F_Girls")
        UnLoadAnimationGroup("NPC_Love")
        UnLoadAnimationGroup("2_G2CarnivalDate")
        UnLoadAnimationGroup("2_G2_GiftExchange")
        PedSetUniqueModelStatus(38, 1)
        shared.g2_G2 = nil
        shared.MGaction = nil
        shared.minigameRunning = nil
        PlayerSetControl(1)
        collectgarbage()
    end
    --print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
    --print("()xxxxx[:::::::::::::::> [start] main()")
    if bHasFlowers then
        F_SetupMission()
        if bDebugFlag then
            if gDebugLevel == 2 then
                F_StartAtStage2()
            elseif gDebugLevel == 3 then
                F_StartAtStage3()
            end
        else
            F_Stage1()
        end
        if bMissionFailed then
            MissionDontFadeInAfterCompetion()
            TextPrint("2_G2_EMPTY", 1, 1)
            SoundPlayMissionEndMusic(false, 7)
            if gMissionFailMessage == 1 then
                MissionFail(false, true, "2_G2_FAIL_01")
            elseif gMissionFailMessage == 2 then
                MissionFail(false, true, "2_G2_FAIL_02")
            elseif gMissionFailMessage == 3 then
                MissionFail(false, true, "2_G2_FAIL_03")
            elseif gMissionFailMessage == 4 then
                MissionFail(false, true, "2_G2_FAIL_04")
            elseif gMissionFailMessage == 5 then
                MissionFail(false, true, "2_G2_FAIL_05")
            elseif gMissionFailMessage == 6 then
                MissionFail(false, true, "CMN_STR_06")
            else
                MissionFail(false)
            end
        end
    else
        TextPrint("2_G2_NOFLOWER", 5, 1)
        TutorialShowMessage("2_G2_FLOWERTUT", 6000, true)
        SoundPlayMissionEndMusic(false, 7)
        MissionFail(false, false)
    end
    --print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_TableInit()
    --print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
    pedPinky = {
        spawn = POINTLIST._2_G2_INTROPINKY,
        element = 1,
        model = 38
    }
    vehiclePinkyBike = {
        spawn = POINTLIST._2_G2_INTROPINKY,
        element = 1,
        model = 283
    }
    pedStrikerJock01 = {
        spawn = POINTLIST._2_G2_INTROJOCK1,
        element = 1,
        model = 13
    }
    pedStrikerJock02 = {
        spawn = POINTLIST._2_G2_INTROJOCK2,
        element = 1,
        model = 15
    }
    --print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_SetupMission()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupMission()")
    LoadAnimationGroup("F_Girls")
    LoadAnimationGroup("NPC_Love")
    LoadAnimationGroup("2_G2CarnivalDate")
    LoadAnimationGroup("2_G2_GiftExchange")
    WeaponRequestModel(363)
    LoadActionTree("Act/Gifts/Give2G2.act")
    LoadActionTree("Act/Conv/2_G2.act")
    PedSetUniqueModelStatus(38, -1)
    F_TableInit()
    math.randomseed(GetTimer())
    shared.g2_G2 = true
    AreaEnsureSpecialEntitiesAreCreated()
    PedRequestModel(38)
    PedRequestModel(13)
    PedRequestModel(15)
    ItemSetCurrentNum(475, ItemGetCurrentNum(475) - 1)
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
    gStage = 1
    meetX, meetY, meetZ = GetPointList(POINTLIST._2_G2_PINKYARRIVED)
    blipCarnival = BlipAddPoint(POINTLIST._2_G2_PINKYARRIVED, 0)
    AreaTransitionPoint(0, POINTLIST._2_G2_SPAWNPLAYER, 1, false)
    PlayerFaceHeading(45, 0)
    CameraReturnToPlayer()
    CameraReset()
    gPlayersTicketCountBeforeStartingMission = ItemGetCurrentNum(495)
    CameraFade(500, 1)
    Wait(500)
    TextPrint("2_G2_MOBJ_01", 5, 1)
    gObjective01 = MissionObjectiveAdd("2_G2_MOBJ_01")
    PedSocialOverrideLoad(4, "Mission/2_G2Follow.act")
    PlayerSocialOverrideLoad(32, "Mission/2_G2PlayerGift.act")
    MissionTimerStart(gMeetPinkyTime)
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
    while bLoop do
        F_Stage1_Objectives()
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
    gStage = 2
    BlipRemove(blipCarnival)
    PedRecruitAlly(gPlayer, pedPinky.id, true)
    PedSetMissionCritical(pedPinky.id, true, F_MissionCritical, true)
    MissionObjectiveComplete(gObjective01)
    TextPrint("2_G2_MOBJ_02", 4, 1)
    gObjective02 = MissionObjectiveAdd("2_G2_MOBJ_02")
    CreateThread("T_TextCarnyTutorial")
    SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 7, "large")
    threadMonitorMiniGames = CreateThread("T_MonitorMiniGames")
    threadMonitorPinky = CreateThread("T_MonitorPinky")
    F_TicketCounterToggle(true)
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
    while bLoop do
        F_Stage2_Objectives()
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
    gStage = 3
    if not bDebugFlag then
        MissionObjectiveComplete(gObjective02)
    end
    TextPrint("2_G2_MOBJ_03", 5, 1)
    if not bPlayerGetBearDialgoue then
        SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 44)
    end
    gObjective03 = MissionObjectiveAdd("2_G2_MOBJ_03")
    blipBooth = BlipAddPoint(POINTLIST._2_G2_BLIPTENTENTER, 0)
    bTentEntranceBlipped = true
    CreateThread("T_RemoveCounter")
    PlayerRegisterSocialCallbackVsPed(pedPinky.id, 32, F_PlayerGiveGiftCallback, true)
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage3_Setup()")
end

function F_Stage3_Loop()
    while bLoop do
        F_Stage3_Objectives()
        if bMissionFailed then
            break
        end
        if bMissionPassed or bMissionFailed then
            break
        end
        Wait(0)
    end
end

function F_Stage1_Objectives()
    F_CheckMoney()
    if PlayerIsInTrigger(TRIGGER._2_G2_PINKYARRIVED) then
        MissionTimerStop()
        F_CutPinkyArrive()
        SoundPlayInteractiveStream("MS_RomanceHigh.rsm", MUSIC_DEFAULT_VOLUME)
        bGoToStage2 = true
        bPinkyHasArrived = true
    end
    if MissionTimerHasFinished() then
        MissionTimerStop()
        gMissionFailMessage = 3
        bMissionFailed = true
    end
    F_CheckClockForFail()
end

function F_Stage2_Objectives()
    if not bTextPlayStriker and PlayerIsInTrigger(TRIGGER._2_G2_HIGHSTRIKER) and PedIsInTrigger(pedPinky.id, TRIGGER._2_G2_HIGHSTRIKER) then
        CreateThread("T_SpeechPinkyLip")
        bTextPlayStriker = true
    end
    if not bTextPlayDunk and PlayerIsInTrigger(TRIGGER._2_G2_DUNKTANK) and PedIsInTrigger(pedPinky.id, TRIGGER._2_G2_DUNKTANK) and not F_PlayHasEnoughTickets() then
        SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 30)
        bTextPlayDunk = true
    end
    if not bTextPlayToss and PlayerIsInTrigger(TRIGGER._2_G2_BALLTOSS) and PedIsInTrigger(pedPinky.id, TRIGGER._2_G2_BALLTOSS) and not F_PlayHasEnoughTickets() then
        SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 26)
        bTextPlayToss = true
    end
    if not bTextPlayShoot and PlayerIsInTrigger(TRIGGER._2_G2_SHOOTINGGALLERY) and PedIsInTrigger(pedPinky.id, TRIGGER._2_G2_SHOOTINGGALLERY) and not F_PlayHasEnoughTickets() then
        SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 34)
        bTextPlayShoot = true
    end
    if ItemGetCurrentNum(495) >= gTicketsRequired then
        --print("()xxxxx[:::::::::::::::> [STAGE] Player has required number of tickets.")
        if not bMiniGameRunning then
            bGoToStage3 = true
        end
    end
    if not bPinkyWarn then
        if PlayerIsInTrigger(TRIGGER._2_G2_PINKYARRIVED) then
            SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 14)
            bPinkyWarn = true
        end
    elseif PlayerIsInTrigger(TRIGGER._2_G2_PINKYANGRYFAIL) then
        SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 100)
        PedSetMissionCritical(pedPinky.id, false)
        PedDismissAlly(gPlayer, pedPinky.id)
        PedMakeAmbient(pedPinky.id)
        gMissionFailMessage = 4
        bMissionFailed = true
    end
    if not bTextPinkyFreak and PedIsInTrigger(pedPinky.id, TRIGGER._2_G2_FREAKSHOW) then
        SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 43)
        bTextPinkyFreak = true
    end
    F_CheckClockForFail()
end

function F_Stage3_Objectives() -- ! Modified
    if not bPinkyWarn then
        if PlayerIsInTrigger(TRIGGER._2_G2_PINKYARRIVED) then
            SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 14)
            bPinkyWarn = true
        end
    elseif PlayerIsInTrigger(TRIGGER._2_G2_PINKYANGRYFAIL) then
        SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 100)
        PedSetMissionCritical(pedPinky.id, false)
        PedDismissAlly(gPlayer, pedPinky.id)
        PedMakeAmbient(pedPinky.id)
        gMissionFailMessage = 4
        bMissionFailed = true
    end
    if PlayerHasWeapon(363) then
        if not bStage3ProgressOnce then
            CounterMakeHUDVisible(false)
            blipTextExit = BlipAddPoint(POINTLIST._2_G2_BLIPTENTEXIT, 0)
            MissionObjectiveComplete(gObjective03)
            gObjective04 = MissionObjectiveAdd("2_G2_MOBJ_04")
            TextPrint("2_G2_MOBJ_04", 4, 1)
            bStage3ProgressOnce = true
        end
        bPlayerHasBear = true
    else
        bPlayerHasBear = false
        if bTentEntranceBlipped then
            if AreaGetVisible() == 50 then
                BlipRemove(blipBooth)
                bTentEntranceBlipped = false
            end
        elseif AreaGetVisible() ~= 50 then
            blipBooth = BlipAddPoint(POINTLIST._2_G2_BLIPTENTENTER, 0)
            bTentEntranceBlipped = true
        end
    end
    if PlayerIsInTrigger(TRIGGER._2_G2_TICKETSHOP) and not bRanOutro then
        PedSetMissionCritical(pedPinky.id, false)
        PedDismissAlly(gPlayer, pedPinky.id)
        PlayerSocialEnableOverrideAgainstPed(pedPinky.id, 32, true)
        PedFollowPath(pedPinky.id, PATH._2_G2_PINKYWANTSBEAR, 0, 1)
        pedPinky.blip = AddBlipForChar(pedPinky.id, 0, 27, 1)
        PedSetMissionCritical(pedPinky.id, true, F_MissionCritical, true)
        PedSetRequiredGift(pedPinky.id, 21, false, true)
        PlayerSocialDisableActionAgainstPed(pedPinky.id, 28, true)
        PlayerSocialDisableActionAgainstPed(pedPinky.id, 29, true)
        PedUseSocialOverride(pedPinky.id, 4)
        SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 49)
        bMonitorMinigames = false
        bRanOutro = true
    end
    if PlayerIsInTrigger(TRIGGER._2_G2_TICKETSHOP) and bPlayerHasBear and not bGiveBearObjective then
        BlipRemove(blipTextExit)
        pedPinky.blip = AddBlipForChar(pedPinky.id, 6, 2, 4)
        MissionObjectiveComplete(gObjective03)
        bGiveBearObjective = true
    end
    if AreaGetVisible() ~= 50 and bPlayerHasBear then
        --CameraFade(-1, 0)
        SoundRemoveAllQueuedSpeech(pedPinky.id, true)
        PedSetFlag(pedPinky.id, 113, true)
        PedSetInvulnerable(pedPinky.id, true)
        PlayerSetInvulnerable(true)
        PedSetMissionCritical(pedPinky.id, false)
        bMonitorPinky = false
        CameraFade(0, 0)	-- Added this
        AreaDisableCameraControlForTransition(true)
        CameraSetXYZ(179.95161, 434.85175, 7.635641, 180.7026, 435.50375, 7.532141)
        PlayerSetControl(0)
        CameraSetWidescreen(true)
        SoundDisableSpeech_ActionTree()
        F_MakePlayerSafeForNIS(true)
        PedSetWeapon(gPlayer, 363, 1)
        local tempX, tempY, tempZ = GetPointList(POINTLIST._2_G2_MOVEPLAYERWITHBEAR)
        PlayerSetPosSimple(tempX, tempY, tempZ)
        PedLockTarget(gPlayer, pedPinky.id, 3)
        PedLockTarget(pedPinky.id, gPlayer, 3)
        Wait(100)
        PedStop(pedPinky.id)
        PedClearObjectives(pedPinky.id)
        PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_OUTSIDEVENDOR, 1)
        CameraFade(500, 1)
        PedSetFlag(pedPinky.id, 113, false)
        PedSetActionNode(gPlayer, "/Global/Give2G2/Give_Attempt", "Act/Gifts/Give2G2.act")
        while not PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
            Wait(0)
        end
        MinigameSetCompletion("M_PASS", true, 0, "2_G2_PINKYUNLCK")
        SoundPlayMissionEndMusic(true, 7)
        while PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) or PedIsPlaying(pedPinky.id, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
            Wait(0)
        end
        Wait(500)
        CameraFade(500, 0)
        Wait(501)
        CameraReset()
        CameraReturnToPlayer()
        PlayerSocialDisableActionAgainstPed(pedPinky.id, 32, true)
        PedSetEmotionTowardsPed(pedPinky.id, gPlayer, 8, true)
        PedSetPedToTypeAttitude(pedPinky.id, gPlayer, 4)
        PedSetStationary(pedPinky.id, true)
        PedSetFlag(pedPinky.id, 84, true)
        BlipRemove(pedPinky.blip)
        PedSetRequiredGift(pedPinky.id, 2, true)
        bPinkyHasBear = true
        bMissionPassed = true
        PedDismissAlly(gPlayer, pedPinky.id)
        PedLockTarget(gPlayer, -1)
        PedSetStationary(pedPinky.id, false)
        PedMakeAmbient(pedPinky.id)
        PedWander(pedPinky.id, 0)
        PedDelete(pedPinky.id)
        CameraSetXYZ(184.13364, 436.1515, 6.715083, 183.17294, 436.16342, 6.992436)
        Wait(50)
        CameraReturnToPlayer(false)
        Wait(500)
        PedSetInvulnerable(pedPinky.id, false)
        PlayerSetInvulnerable(false)
        PedSetStationary(pedPinky.id, false)
        MissionSucceed(false, false, false)
        Wait(500)
        CameraFade(500, 1)
        Wait(101)
        PlayerSetControl(1)
    end
    if not bTextPinkyFreak and PlayerIsInTrigger(TRIGGER._2_G2_FREAKSHOW) then
        SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 43)
        bTextPinkyFreak = true
    end
    F_CheckClockForFail()
end

function F_CutPinkyArrive()
    --print("()xxxxx[:::::::::::::::> [start] F_CutPinkyArrive()")
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PlayerSetControl(0)
    CameraFade(500, 0)
    Wait(500)
    if PedIsOnVehicle(gPlayer) then
        local playerBike = PlayerGetBikeId()
        PlayerDetachFromVehicle()
        VehicleSetPosPoint(playerBike, POINTLIST._2_G2_MOVEBIKE)
        VehicleSetStatic(playerBike, true)
    end
    pedPinky.id = PedCreatePoint(pedPinky.model, pedPinky.spawn, pedPinky.element)
    PedSetMissionCritical(pedPinky.id, true, F_MissionCritical, true)
    PedSetFlag(pedPinky.id, 98, false)
    PedSetActionNode(gPlayer, "/Global/2_G2/JimmyWaits", "Act/Conv/2_G2.act")
    PlayerSetPosPoint(POINTLIST._2_G2_INTROJIMMY)
    F_MakePlayerSafeForNIS(true)
    CameraSetWidescreen(true)
    StopAmbientPedAttacks()
    CameraSetFOV(80)
    CameraSetXYZ(210.5629, 422.19632, 4.557801, 210.01942, 423.00427, 4.785322)
    F_DisablePopulation()
    pedStrikerJock01.id = PedCreatePoint(pedStrikerJock01.model, POINTLIST._2_G2_INTROJOCK1, pedStrikerJock01.element)
    pedStrikerJock02.id = PedCreatePoint(pedStrikerJock02.model, POINTLIST._2_G2_INTROJOCK2, pedStrikerJock02.element)
    CameraFade(500, 1)
    Wait(500)
    CreateThread("T_Cutscene01")
    while not bSkipFirstCutscene do
        if IsButtonPressed(7, 0) then
            bSkipFirstCutscene = true
        end
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(500)
    PedDelete(pedStrikerJock01.id)
    PedDelete(pedStrikerJock02.id)
    PedSetActionNode(gPlayer, "/Global/2_G2/2_G2_Anims/Empty", "Act/Conv/2_G2.act")
    PedStop(gPlayer)
    PedClearObjectives(pedPinky.id)
    PedStop(pedPinky.id)
    PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_CUTBEARSPAWNPINKY, 1)
    PlayerSetPosPoint(POINTLIST._2_G2_CUTBEARSPAWNJIMMY, 1)
    F_EnablePopulation()
    F_MakePlayerSafeForNIS(false)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    CameraDefaultFOV()
    CameraFade(500, 1)
    Wait(500)
    PedLockTarget(gPlayer, -1)
    PedLockTarget(pedPinky.id, -1)
    PlayerSetControl(1)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    --print("()xxxxx[:::::::::::::::> [finish] F_CutPinkyArrive()")
end

function F_StartAtStage2()
    --print("()xxxxx[:::::::::::::::> [start] F_StartAtStage2()")
    TextPrint("2_G2_MOBJ_02", 5, 1)
    threadMonitorPinky = CreateThread("T_MonitorPinky")
    AreaTransitionPoint(0, POINTLIST._2_G2_CUTBEARSPAWNJIMMY)
    F_Stage2()
    --print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage2()")
end

function F_StartAtStage3()
    --print("()xxxxx[:::::::::::::::> [start] F_StartAtStage3()")
    pedPinky.id = PedCreatePoint(pedPinky.model, pedPinky.spawn, pedPinky.element)
    threadMonitorPinky = CreateThread("T_MonitorPinky")
    threadMonitorMiniGames = CreateThread("T_MonitorMiniGames")
    PedSocialOverrideLoad(4, "Mission/2_G2Follow.act")
    PlayerSocialOverrideLoad(32, "Mission/2_G2PlayerGift.act")
    AreaTransitionPoint(0, POINTLIST._2_G2_STAGE3DEBUG)
    PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_STAGE3DEBUG, 1)
    PlayerSetPosPoint(POINTLIST._2_G2_STAGE3DEBUG, 2)
    GiveItemToPlayer(495)
    GiveItemToPlayer(495)
    GiveItemToPlayer(495)
    GiveItemToPlayer(495)
    GiveItemToPlayer(495)
    GiveItemToPlayer(495)
    GiveItemToPlayer(495)
    GiveItemToPlayer(495)
    GiveItemToPlayer(495)
    GiveItemToPlayer(495)
    CameraFade(500, 1)
    Wait(500)
    F_Stage3()
    --print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage3()")
end

function F_SetupDunkTank()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupDunkTank()")
    bTicketCount = ItemGetCurrentNum(495)
    PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_MGDUNKPINKY)
    Wait(500)
    PedFaceObject(pedPinky.id, gPlayer, 3, 1)
    F_TicketCounterToggle(false)
    PedHideHealthBar()
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupDunkTank()")
end

function F_SetupBaseballToss()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupBaseballToss()")
    bTicketCount = ItemGetCurrentNum(495)
    Wait(500)
    PedFaceHeading(pedPinky.id, 0, 0)
    F_TicketCounterToggle(false)
    PedHideHealthBar()
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupBaseballToss()")
end

function F_SetupCarnieStriker()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupCarnieStriker()")
    bTicketCount = ItemGetCurrentNum(495)
    PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_MGSTRIKEPINKY)
    Wait(500)
    PedFaceObject(pedPinky.id, gPlayer, 3, 1)
    F_TicketCounterToggle(false)
    PedHideHealthBar()
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupCarnieStriker()")
end

function F_SetupShootingGallery()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupShootingGallery()")
    bTicketCount = ItemGetCurrentNum(495)
    PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_MGSHOOTPINKY)
    Wait(500)
    PedFaceHeading(pedPinky.id, 180, 0)
    F_TicketCounterToggle(false)
    PedHideHealthBar()
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupShootingGallery()")
end

function F_SetupCarnieStore()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupCarnieStore()")
    bTicketCount = ItemGetCurrentNum(495)
    F_TicketCounterToggle(false)
    PedHideHealthBar()
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupCarnieStore()")
end

function F_MiniGameFinished()
    --print("()xxxxx[:::::::::::::::> [start] F_MiniGameFinished()")
    shared.MGaction = nil
    if not bGoToStage3 then
        F_TicketCounterToggle(true)
    end
    if CounterGetCurrent() > gTicketsRequired then
        CounterSetCurrent(gTicketsRequired)
    end
    if ItemGetCurrentNum(495) > bTicketCount then
        if gLastGamePlayed == "DunkTank" then
            SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 31)
        elseif gLastGamePlayed == "BaseballToss" then
        elseif gLastGamePlayed == "ShootingGallery" then
            if F_PlayHasEnoughTickets() then
                SoundPlayScriptedSpeechEventWrapper(pedPinky.id, "M_2_G2", 44)
                bPlayerGetBearDialgoue = true
            else
                SoundPlayScriptedSpeechEventWrapper(pedPinky.id, "M_2_G2", 37)
            end
        end
    elseif gLastGamePlayed ~= "CarnieStore" then
        if shared.quit_minigame then
            shared.quit_minigame = false
        else
            SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 15)
        end
    end
    PedShowHealthBar(pedPinky.id, true, "N_Pinky", false)
    --print("()xxxxx[:::::::::::::::> [finish] F_MiniGameFinished()")
end

function F_TicketCounterToggle(onOff)
    --print("()xxxxx[:::::::::::::::> [start] F_TicketCounterToggle()")
    if onOff == true then
        CounterSetIcon("CarnTicket", "CarnTicket_x")
        CounterMakeHUDVisible(true, true)
        if ItemGetCurrentNum(495) > gTicketsRequired then
            CounterSetCurrent(gTicketsRequired)
        else
            CounterSetCurrent(ItemGetCurrentNum(495))
        end
        CounterSetMax(gTicketsRequired)
    else
        CounterClearIcon()
        CounterMakeHUDVisible(false)
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_TicketCounterToggle()")
end

function F_PinkyCheer()
    --print("()xxxxx[:::::::::::::::> [start] F_PinkyCheer()")
    if gPinkyMGActionTimer + gPinkyDialogueRepeatTime < GetTimer() then
        if shared.minigameRunning == "DunkTank" then
        elseif shared.minigameRunning == "BaseballToss" then
            SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 27)
        elseif shared.minigameRunning == "ShootingGallery" then
            SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 35)
        elseif shared.minigameRunning == "CarnieStriker" then
        end
        gPinkyMGActionTimer = GetTimer()
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_PinkyCheer()")
end

function F_PinkyBoo()
    --print("()xxxxx[:::::::::::::::> [start] F_PinkyBoo()")
    if gPinkyMGActionTimer + gPinkyDialogueRepeatTime < GetTimer() then
        if shared.minigameRunning == "DunkTank" then
        elseif shared.minigameRunning == "BaseballToss" then
            SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 28)
        elseif shared.minigameRunning == "ShootingGallery" then
            SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 36)
        elseif shared.minigameRunning == "CarnieStriker" then
        end
        gPinkyMGActionTimer = GetTimer()
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_PinkyBoo()")
end

function F_DisablePopulation()
    --print("()xxxxx[:::::::::::::::> [start] F_DisablePopulation()")
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    --print("()xxxxx[:::::::::::::::> [finish] F_DisablePopulation()")
end

function F_EnablePopulation()
    --print("()xxxxx[:::::::::::::::> [start] F_EnablePopulation()")
    AreaRevertToDefaultPopulation()
    --print("()xxxxx[:::::::::::::::> [finish] F_EnablePopulation()")
end

function F_PinkyReceivedBear()
    --print("()xxxxx[:::::::::::::::> [start] F_PinkyReceivedBear()")
    bPinkyReceivedBear = true
    --print("()xxxxx[:::::::::::::::> [finish] F_PinkyReceivedBear()")
end

function F_RemovePlayersBear()
    --print("()xxxxx[:::::::::::::::> [start] F_RemovePlayersBear()")
    SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 45)
    PedDestroyWeapon(gPlayer, 363)
    --print("()xxxxx[:::::::::::::::> [finish] F_RemovePlayersBear()")
end

function F_PlayerSnarky()
    --print("()xxxxx[:::::::::::::::> [start] F_PlayerSnarky()")
    PlayerSetControl(0)
    SoundPlayScriptedSpeechEvent(gPlayer, "M_2_G2", 57)
    --print("()xxxxx[:::::::::::::::> [finish] F_PlayerSnarky()")
end

function F_PlayHasEnoughTickets()
    --print("()xxxxx[:::::::::::::::> [start] F_PlayHasEnoughTickets()")
    if ItemGetCurrentNum(495) >= gTicketsRequired then
        return true
    else
        return false
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_PlayHasEnoughTickets()")
end

function F_HackSetupPinkyFollow()
    --print("()xxxxx[:::::::::::::::> [start] F_HackSetupPinkyFollow()")
    while IsStreamingBusy() do
        Wait(0)
    end
    if gLastGamePlayed == "DunkTank" then
        PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_HACKEXITDUNK)
    elseif gLastGamePlayed == "BaseballToss" then
        PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_HACKEXITTOSS)
    elseif gLastGamePlayed == "ShootingGallery" then
        PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_HACKEXITSHOOT)
    elseif gLastGamePlayed == "CarnieStriker" then
        PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_HACKEXITSTRIKE)
    end
    PedRecruitAlly(gPlayer, pedPinky.id, true)
    --print("()xxxxx[:::::::::::::::> [finish] F_HackSetupPinkyFollow()")
end

function F_MissionCritical()
    --print("()xxxxx[:::::::::::::::> [start] F_MissionCritical()")
    F_CleanUpPinky()
    gMissionFailMessage = 1
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

function F_GivePinkyBear()
    PedSetWeaponNow(pedPinky.id, 363, 1)
end

function F_CleanUpPinky()
    --print("()xxxxx[:::::::::::::::> [start] F_CleanUpPinky()")
    if F_PedExists(pedPinky.id) then
        PedSetInvulnerable(pedPinky.id, false)
        PedSetFlag(pedPinky.id, 113, false)
        PedSetStationary(pedPinky.id, false)
        PedIgnoreStimuli(pedPinky.id, false)
        PedSetMissionCritical(pedPinky.id, false)
        PedDismissAlly(gPlayer, pedPinky.id)
        PedMakeAmbient(pedPinky.id)
        PedWander(pedPinky.id, 0)
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_CleanUpPinky()")
end

function F_HidePinky()
    --print("()xxxxx[:::::::::::::::> [start] F_HidePinky()")
    PedSetMissionCritical(pedPinky.id, false)
    PedDismissAlly(gPlayer, pedPinky.id)
    PedSetInvulnerable(pedPinky.id, true)
    PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_HIDEPINKY, 1)
    --print("()xxxxx[:::::::::::::::> [finish] F_HidePinky()")
end

function F_ReturnPinky(where)
    --print("()xxxxx[:::::::::::::::> [start] F_ReturnPinky()")
    if where == 1 then
        PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_EXITCOASTER, 1)
    elseif where == 2 then
        PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_EXITSQUID, 1)
    elseif where == 3 then
        PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_EXITWHEEL, 1)
    else
        PedSetPosPoint(pedPinky.id, POINTLIST._2_G2_EXITKARTS, 1)
    end
    PedSetInvulnerable(pedPinky.id, false)
    PedRecruitAlly(gPlayer, pedPinky.id, true)
    PedSetMissionCritical(pedPinky.id, true, F_MissionCritical, true)
    F_TicketCounterToggle(true)
    if CounterGetCurrent() > gTicketsRequired then
        CounterSetCurrent(gTicketsRequired)
    end
    --print("()xxxxx[:::::::::::::::> [finish] F_ReturnPinky()")
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

function F_CheckClockForFail()
    gClockHour, gClockMin = ClockGet()
    if gClockHour == 1 and 10 <= gClockMin then
        gMissionFailMessage = 2
        bMissionFailed = true
    end
end

function T_MonitorPinky()
    --print("()xxxxx[:::::::::::::::> [start] T_MonitorPinky()")
    while bMonitorPinky do
        if PedIsDead(pedPinky.id) then
            --print("()xxxxx[:::::::::::::::> [mission fail] PINKY DIED!")
            gMissionFailMessage = 5
            bMissionFailed = true
            break
        end
        Wait(0)
    end
    --print("()xxxxx[:::::::::::::::> [finish] T_MonitorPinky()")
end

function T_MonitorMiniGames()
    --print("()xxxxx[:::::::::::::::> [start] T_MonitorMiniGames()")
    while bMonitorMinigames do
        if shared.minigameRunning == "DunkTank" and not bSetupDunkTank then
            --print("()xxxxx[:::::::::::::::> [minigame running] DunkTank")
            gLastGamePlayed = "DunkTank"
            F_SetupDunkTank()
            bSetupDunkTank = true
            bMiniGameRunning = true
        elseif shared.minigameRunning == "BaseballToss" and not bSetupBaseballToss then
            --print("()xxxxx[:::::::::::::::> [minigame running] BaseballToss")
            gLastGamePlayed = "BaseballToss"
            F_SetupBaseballToss()
            bSetupBaseballToss = true
            bMiniGameRunning = true
        elseif shared.minigameRunning == "CarnieStriker" and not bSetupCarnieStriker then
            --print("()xxxxx[:::::::::::::::> [minigame running] CarnieStriker")
            gLastGamePlayed = "CarnieStriker"
            F_SetupCarnieStriker()
            bSetupCarnieStriker = true
            bMiniGameRunning = true
        elseif shared.minigameRunning == "ShootingGallery" and not bSetupShootingGallery then
            --print("()xxxxx[:::::::::::::::> [minigame running] ShootingGallery")
            gLastGamePlayed = "ShootingGallery"
            F_SetupShootingGallery()
            bSetupShootingGallery = true
            bMiniGameRunning = true
        elseif shared.minigameRunning == "CarnieStore" and not bSetupCarnieStore then
            --print("()xxxxx[:::::::::::::::> [minigame running] Carnival Store")
            gLastGamePlayed = "CarnieStore"
            F_SetupCarnieStore()
            bSetupCarnieStore = true
            bMiniGameRunning = true
        elseif shared.minigameRunning == nil and bMiniGameRunning then
            --print("()xxxxx[:::::::::::::::> [minigame finished]")
            F_MiniGameFinished()
            bSetupDunkTank = false
            bSetupBaseballToss = false
            bSetupCarnieStriker = false
            bSetupShootingGallery = false
            bSetupCarnieStore = false
            bMiniGameRunning = false
        end
        if bMiniGameRunning then
            if shared.MGaction == 1 then
                F_PinkyCheer()
                shared.MGaction = 0
            elseif shared.MGaction == 2 then
                F_PinkyBoo()
                shared.MGaction = 0
            end
        end
        if shared.g2_G2_HidePinky then
            F_HidePinky()
            shared.g2_G2_HidePinky = false
        end
        if shared.g2_G2_ReturnPinky then
            F_ReturnPinky(shared.g2_G2_ReturnWhere)
            shared.g2_G2_ReturnPinky = false
        end
        Wait(0)
    end
    --print("()xxxxx[:::::::::::::::> [finish] T_MonitorMiniGames()")
end

function T_TextCarnyTutorial()
    --print("()xxxxx[:::::::::::::::> [start] T_TextCarnyTutorial()")
    Wait(4000)
    TutorialShowMessage("2_G2_TUT_01", 6000)
    --print("()xxxxx[:::::::::::::::> [finish] T_TextCarnyTutorial()")
end

function T_SpeechPinkyLip()
    --print("()xxxxx[:::::::::::::::> [start] T_SpeechPinkyLip()")
    SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 54)
    F_WaitForSpeech(pedPinky.id)
    SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 56)
    --print("()xxxxx[:::::::::::::::> [finish] T_SpeechPinkyLip()")
end

function T_RemoveCounter()
    --print("()xxxxx[:::::::::::::::> [start] T_RemoveCounter()")
    Wait(3000)
    F_TicketCounterToggle(false)
    --print("()xxxxx[:::::::::::::::> [finish] T_RemoveCounter()")
end

function T_Cutscene01()
    if not bSkipFirstCutscene then
        PedSetActionNode(gPlayer, "/Global/2_G2/JimmyWaits", "Act/Conv/2_G2.act")
        SoundPlayScriptedSpeechEvent(gPlayer, "M_2_G2", 1)
    end
    if not bSkipFirstCutscene then
        F_WaitForSpeechCutscene01(gPlayer)
    end
    if not bSkipFirstCutscene then
        PedFollowPath(pedStrikerJock01.id, PATH._2_G2_INTROJOCK1, 0, 0, F_routeIntroJock1)
        PedFollowPath(pedStrikerJock02.id, PATH._2_G2_INTROJOCK2, 0, 0, F_routeIntroJock2)
    end
    if not bSkipFirstCutscene then
        WaitSkippable(1000)
    end
    if not bSkipFirstCutscene then
        PedFollowPath(pedPinky.id, PATH._2_G2_INTROPINKY, 0, 1, F_routeIntroPinky)
        PedLockTarget(gPlayer, pedPinky.id, 3)
        PedLockTarget(pedPinky.id, gPlayer, 3)
        SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 3, "large")
        Wait(500)
        PedSetActionNode(gPlayer, "/Global/2_G2/2_G2_Anims/Empty", "Act/Conv/2_G2.act")
    end
    if not bSkipFirstCutscene then
        F_WaitForSpeechCutscene01(pedPinky.id)
    end
    if not bSkipFirstCutscene then
        CameraSetFOV(30)
        CameraSetXYZ(205.89542, 424.03558, 5.607414, 206.86961, 424.25504, 5.659357)
        SoundPlayScriptedSpeechEvent(pedPinky.id, "M_2_G2", 4)
    end
    if not bSkipFirstCutscene then
        F_WaitForSpeechCutscene01(pedPinky.id)
    end
    if not bSkipFirstCutscene then
        CameraSetFOV(80)
        CameraSetXYZ(209.6018, 423.38013, 4.852606, 208.98424, 424.1485, 5.019646)
        PedMoveToPoint(pedPinky.id, 1, POINTLIST._2_G2_CUTBEARSPAWNJIMMY, 1)
    end
    if not bSkipFirstCutscene then
        WaitSkippable(1200)
    end
    if not bSkipFirstCutscene then
        SoundPlayScriptedSpeechEvent(gPlayer, "M_2_G2", 6, "large")
        PedMoveToPoint(gPlayer, 1, POINTLIST._2_G2_CUTBEARSPAWNJIMMY, 1)
    end
    if not bSkipFirstCutscene then
        WaitSkippable(2000)
    end
    bSkipFirstCutscene = true
end

function F_routeCutBearPinky(pedID, pathID, nodeID)
    if nodeID == 3 then
        PedFaceObject(pedPinky.id, gPlayer, 3, 1)
    end
end

function F_routeCutBearJimmy(pedID, pathID, nodeID)
    if nodeID == 3 then
        PedFaceObject(gPlayer, pedPinky.id, 2, 1)
    end
end

function F_routeIntroPinky(pedID, pathID, nodeID)
    if nodeID == 4 then
        PedFaceObject(pedID, gPlayer, 3, 1)
        bIntroPinkyArrived = true
    end
end

function F_routeIntroJock1(pedID, pathID, nodeID)
end

function F_routeIntroJock2(pedID, pathID, nodeID)
end

function F_routePinkyGrabBear(pedID, pathID, nodeID)
    if nodeID == 1 then
        PedSetActionNode(pedID, "/Global/2_G2/2_G2_Anims/GrabBear", "Act/Conv/2_G2.act")
    end
end

function F_routePinkyLeave(pedID, pathID, nodeID)
    if nodeID == 1 then
        bCleanupPassed = true
    end
end

function F_CheckMoney()
    if PlayerGetMoney() < 100 and not shared.playerShopping and (not PlayerHasItem(479) or ItemGetCurrentNum(495) < gTicketsRequired) then
        gMissionFailMessage = 6
        bMissionFailed = true
    end
end
