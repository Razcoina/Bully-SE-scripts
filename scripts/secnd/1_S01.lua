local gOBjectiveTable = {}
local gHattrickSpeech = {}
local gHattrickNextStep = 0
local bMissionSuccess = false

function MissionSetup()
    PlayCutsceneWithLoad("1-S01", true)
    DATLoad("1_S01.DAT", 2)
    DATInit()
    MissionDontFadeIn()
    DisablePOI()
    POIGroupsEnabled(false)
    LoadAnimationGroup("Hang_Talking")
    LoadAnimationGroup("F_Adult")
    LoadAnimationGroup("NPC_Adult")
    LoadAnimationGroup("WeaponUnlock")
    LoadModels({ 327, 328 }, true)
    shared.gEdnaOverride = true
    PedSetUniqueModelStatus(57, -1)
    PedSetUniqueModelStatus(63, -1)
    PedSetUniqueModelStatus(54, -1)
end

function MissionCleanup()
    F_MakePlayerSafeForNIS(false)
    PAnimCloseDoor(TRIGGER._BUSDOORS)
    if phillips and PedIsValid(phillips) then
        PedSetFlag(phillips, 113, false)
        PedSetInvulnerable(phillips, false)
        PedIgnoreStimuli(phillips, false)
        PedSetStationary(phillips, false)
    end
    if bMissionSuccess then
        if phillips and PedIsValid(phillips) then
            PedDelete(phillips)
        end
        if gHobo and PedIsValid(gHobo) then
            PedDelete(gHobo)
        end
        CounterMakeHUDVisible(false)
        CameraSetWidescreen(false)
        SoundEnableSpeech_ActionTree()
        PedStop(gPlayer)
        PedClearObjectives(gPlayer)
        CameraReset()
        CameraReturnToPlayer()
    end
    SoundEnableSpeech_ActionTree()
    SoundStopInteractiveStream()
    shared.gEdnaOverride = false
    CameraReturnToPlayer()
    PlayerSetControl(1)
    EnablePOI(true, true)
    PedSetUniqueModelStatus(57, 1)
    PedSetUniqueModelStatus(63, 1)
    PedSetUniqueModelStatus(54, 1)
    CameraSetWidescreen(false)
    CounterMakeHUDVisible(false)
    ItemSetCurrentNum(529, 0)
    UnLoadAnimationGroup("Hang_Talking")
    UnLoadAnimationGroup("F_Adult")
    UnLoadAnimationGroup("NPC_Adult")
    UnLoadAnimationGroup("WeaponUnlock")
    DATUnload(2)
end

function main()
    MissionDontFadeIn()
    SoundDisableSpeech_ActionTree()
    PlayerSetPunishmentPoints(0)
    AreaTransitionPoint(2, POINTLIST._1_S01_PLAYER_START, nil, true)
    PlayerSetControl(0)
    LoadActionTree("Act/Conv/1_S01.act")
    LoadAnimationGroup("Px_Sink")
    LoadModels({
        54,
        63,
        87,
        14,
        50,
        58,
        65,
        61,
        529
    })
    SoundStopInteractiveStream(0)
    SoundPlayInteractiveStream("MS_InTroubleLow.rsm", 0.8)
    SoundSetHighIntensityStream("MS_InTroubleHigh.rsm", 0.8)
    AreaClearAllPeds()
    Wait(1000)
    CameraFade(1000, 1)
    PlayerSetControl(1)
    TextPrint("1_S01_42", 3, 1)
    gOBjectiveTable[1] = MissionObjectiveAdd("1_S01_42")
    CounterMakeHUDVisible(true, true)
    CounterClearText()
    CounterSetCurrent(0)
    CounterSetMax(3)
    CounterSetIcon("bagged_bottle", "bagged_bottle_x")
    ItemSetCurrentNum(529, 1)
    index_g1, simplePool_g1 = PAnimGetPoolIndex("DPI_TrophyGlsC", -627.861, -293.856, 6.95912, 1)
    index_g2, simplePool_g2 = PAnimGetPoolIndex("DPI_TrophyGlsA,", -629.372, -293.856, 6.56114, 1)
    index_g3, simplePool_g3 = PAnimGetPoolIndex("DPI_TrophyGlsB", -629.372, -293.856, 7.18237, 1)
    index_g4, simplePool_g4 = PAnimGetPoolIndex("DPI_TrophyGlsC", -628.579, -293.856, 6.95912, 1)
    index_g5, simplePool_g5 = PAnimGetPoolIndex("DPI_TrophyGlsB", -627.083, -293.856, 7.18237, 1)
    index_g6, simplePool_g6 = PAnimGetPoolIndex("DPI_TrophyGlsA", -627.083, -293.856, 6.56114, 1)
    gMissionRunning = true
    gBottlesPickedUp = 0
    gBathBottleFunction = F_S1_BottleBath_Setup
    gCafeBottleFunction = F_S1_BottleCafe_Setup
    gTrophyBottleFunction = F_S1_BottleTrophy_Setup
    gReturnBottleFunction = F_S2_ReturnBottles_Setup
    F_Set_Up_Bottles()
    while gMissionRunning do
        if not gHattrickSeenPlayer and gHattrickFunction then
            F_HattrickFunctions()
        end
        if 3 <= gBottlesPickedUp then
            if not gPlayerReset and AreaGetVisible() == 0 then
                gPlayerReset = true
                AreaResetPunishmentAlertLevels()
                SoundEnableSpeech_ActionTree()
                AreaEnableAllPatrolPaths()
            end
            if not gMissionFail then
                gReturnBottleFunction()
            end
        elseif not gMissionFail then
            if not gHasBathBottle then
                gBathBottleFunction()
            end
            if not gHasCafeBottle then
                gCafeBottleFunction()
            end
            if not gHasTrophyBottle then
                gTrophyBottleFunction()
            end
            F_BlipHandling()
        end
        if gMissionFail then
            SoundPlayMissionEndMusic(false, 10)
            gMissionRunning = false
            if gMissionFailMessage then
                MissionFail(true, true, gMissionFailMessage)
            else
                MissionFail()
            end
        end
        if gMakeMandyAmbient and gMandy then
            PedMakeAmbient(gMandy)
            gMakeMandyAmbient = nil
        end
        if gHattrickAttack and gHattrick then
            gHattrickAttack = nil
            if PedIsValid(gHattrick) then
                SoundStopCurrentSpeechEvent()
                SoundPlayScriptedSpeechEvent(gHattrick, "M_1_S01", 36, "large")
                PedAttackPlayer(gHattrick, 0, true)
                PedMakeAmbient(gHattrick)
            end
            if gPrincipal and PedIsValid(gPrincipal) then
                PedMakeAmbient(gPrincipal)
            end
        end
        if gHattrickNearBathroom and not gHattrickSeenPlayer and (gBathroomSetup or GetTimer() - gHattrickReachBathroomTime > 8000) then
            gHattrickNextStep = gHattrickNextStep + 1
            gHattrickFunction = true
        end
        if not gHallMonFollow and gHallMon then
            --print("[RAUL] Hall mon created")
            gHallMon = PedCreatePoint(54, POINTLIST._1_S01_BROOM_PREFECT)
            PedSetStealthBehavior(gHallMon, 0, CbHallMonitorAttack)
            PedFollowPath(gHallMon, PATH._1_S01_BROOM_PREFECT_PATH2, 0, 2, CbHallMonitor)
            gHallMonFollow = true
        end
        if not initialHallMonSaw and hallmonSawPlayer and gHallMon then
            --print("[RAUL] Hall mon saw player, must attack now ")
            SoundPlayAmbientSpeechEvent(gHallMon, "STEALTH_PURSUIT")
            Wait(1)
            PedMakeAmbient(gHallMon)
            PedAttackPlayer(gHallMon, 0, true)
            initialHallMonSaw = true
        end
        if gHattrickInCafeteria then
            if gPrincipal and PedIsValid(gPrincipal) then
                PedDelete(gPrincipal)
                gPrincipal = nil
            end
            if gHattrick and PedIsValid(gHattrick) then
                PedDelete(gHattrick)
                gHattrick = nil
            end
            if not gHattrick and not gPrincipal then
                gHattrickInCafeteria = nil
            end
        end
        if gMonitorInWashroom and gHallMon then
            PedSetIsStealthMissionPed(gHallMon)
            CreateThread("T_BathroomMonitor")
            gMonitorInWashroom = nil
        end
        Wait(0)
    end
end

function F_S2_ReturnBottles_Setup()
    MissionObjectiveComplete(gOBjectiveTable[1])
    Wait(1000)
    gOBjectiveTable[5] = MissionObjectiveAdd("1_S01_56")
    TextPrint("1_S01_56", 4, 1)
    CounterMakeHUDVisible(false)
    phillips = PedCreatePoint(63, POINTLIST._1_S01_PHILLIPS)
    PedSetFlag(phillips, 113, true)
    PedIgnoreStimuli(phillips, true)
    PedSetStationary(phillips, true)
    PedSetFaction(phillips, 9)
    PedSetMissionCritical(phillips, true, CbPlayerAggressed, true)
    local x, y, z = GetPointList(POINTLIST._1_S01_PHILLIPS)
    F_Socialize(phillips, true)
    x = x + 2
    PedSetRequiredGift(phillips, 17, false, true)
    p_blip = AddBlipForChar(phillips, 8, 17, 4)
    TextPrint("1_S01_56", 3, 1)
    gTimesHit = 0
    gReturnBottleFunction = F_S2_ReturnBottles
end

function F_S2_ReturnBottles()
    if phillips and PedIsValid(phillips) and PlayerIsInAreaObject(phillips, 2, 3.5, 0) and PedGetFlag(gPlayer, 1) then
        PlayerSetInvulnerable(true)
        PedSetInvulnerable(phillips, true)
        PlayerSetControl(0)
        Wait(200)
        if not gMissionFail then
            SoundStopCurrentSpeechEvent()
            F_MakePlayerSafeForNIS(true)
            CameraSetWidescreen(true)
            F_PlayerDismountBike()
            PedSetFlag(phillips, 113, false)
            PedSetInvulnerable(phillips, false)
            PedIgnoreStimuli(phillips, false)
            PedSetStationary(phillips, false)
            PlayerSetInvulnerable(false)
            gHobo = PedCreatePoint(87, POINTLIST._1_S01_HOBO, 1)
            PedIgnoreStimuli(gHobo, true)
            PedFollowPath(gHobo, PATH._1_S01_HOBO_PATH, 0, 0)
            CameraSetXYZ(179.7372, 3.151522, 6.393147, 179.32288, 4.061574, 6.403118)
            PedFaceObject(phillips, gPlayer, 3, 1)
            PedFaceObject(gPlayer, phillips, 2, 1)
            PedLockTarget(gPlayer, phillips, 3)
            PedClearObjectives(phillips)
            SoundPlayScriptedSpeechEvent(gPlayer, "M_1_S01", 53)
            local speech = 1
            PedSetActionNode(gPlayer, "/Global/1_S01/Animations/GIVE_B/GiveMissPhillips1_S01", "Act/Conv/1_S01.act")
            while PedIsPlaying(gPlayer, "/Global/1_S01/Animations/GIVE_B/GiveMissPhillips1_S01", true) do
                if speech == 1 and not SoundSpeechPlaying(gPlayer) then
                    SoundPlayScriptedSpeechEvent(phillips, "M_1_S01", 18)
                    speech = 2
                elseif speech == 2 and not SoundSpeechPlaying(phillips) then
                    SoundPlayScriptedSpeechEvent(gPlayer, "M_1_S01", 19)
                    speech = 3
                elseif speech == 3 and not SoundSpeechPlaying(gPlayer) then
                    SoundPlayScriptedSpeechEvent(phillips, "M_1_S01", 99)
                    speech = 4
                end
                if gMissionFail then
                    break
                end
                Wait(0)
            end
            if not gMissionFail then
                PedStopSocializing(phillips)
                CameraSetXYZ(179.7372, 3.151522, 6.393147, 179.32288, 4.061574, 6.403118)
                PedSetActionNode(phillips, "/Global/1_S01/ClearNode", "Act/Conv/1_S01.act")
                PedSetActionNode(gPlayer, "/Global/1_S01/ClearNode", "Act/Conv/1_S01.act")
                PedStop(phillips)
                PedClearObjectives(phillips)
                if PlayerIsInTrigger(TRIGGER._1_S01_PLAYERBLOCKING) then
                    PedStop(gPlayer)
                    PedClearObjectives(gPlayer)
                    PedMoveToPoint(gPlayer, 0, POINTLIST._1_S01_PLAYERENDING)
                    Wait(1000)
                end
                Wait(500)
                AreaSetDoorLockedToPeds(TRIGGER._BUSDOORS, false)
                PAnimOpenDoor(TRIGGER._BUSDOORS)
                PedFollowPath(phillips, PATH._1_S01_PHILLIPS_PATH, 0, 0)
                Wait(3000)
                PedSetActionNode(gPlayer, "/Global/1_S01/Success", "Act/Conv/1_S01.act")
                F_PedSetCameraOffsetXYZ(gPlayer, 0.3, 1.4, 1.3, 0, 0, 1.5)
                MinigameSetCompletion("M_PASS", true, 0, "1_S01_REWARD")
                SoundPlayMissionEndMusic(true, 10)
                PedMoveToXYZ(gHobo, 0, 166.04, 18.9094, 6.29449)
                PedMoveToXYZ(phillips, 0, 166.04, 18.9094, 6.294)
                PedLockTarget(gPlayer, -1)
                while PedIsPlaying(gPlayer, "/Global/1_S01/Success", false) or PedIsPlaying(gPlayer, "/Global/1_S01/Success", true) do
                    Wait(0)
                end
                while MinigameIsShowingCompletion() do
                    Wait(0)
                end
                CameraFade(500, 0)
                Wait(501)
                PedClearObjectives(gPlayer)
                PedStop(gPlayer)
                gMissionRunning = false
                PedSetWeaponNow(gPlayer, 328, 1, false)
                CameraReset()
                CameraReturnToPlayer()
                MissionSucceed(false, false, false)
                Wait(500)
                CameraFade(500, 1)
                Wait(101)
                PlayerSetControl(1)
            end
        end
    end
end

function F_S1_BottleBath_Setup()
    timeHour, timeMin = ClockGet()
    if not gBathroomSetup and PlayerIsInTrigger(TRIGGER._1_S01_BATHROOMSETUP) then
        gBathroomSetup = true
        if not shared.gAlarmOn then
            gMandy = PedCreatePoint(14, POINTLIST._1_S01_BROOM_GIRL)
            PedIgnoreStimuli(gMandy, true)
            PedSetActionNode(gMandy, "/Global/1_S01/1_S01_Bathroom/1_S01_Bathroom_Loop", "Act/Conv/1_S01.act")
        end
    end
    if gBathroomSetup and not gMandyHit and gMandy and (PedIsHit(gMandy, 2, 1000) or shared.gAlarmOn) then
        PedClearHitRecord(gMandy)
        gMandyHit = true
    end
    if PlayerIsInTrigger(TRIGGER._1_S01_BATHROOM) or gMandyHit or shared.gAlarmOn then
        if gMandy then
            PedSetActionNode(gMandy, "/Global/1_S01/ClearNode", "Act/Conv/1_S01.act")
            PedStop(gMandy)
            PedClearObjectives(gMandy)
            PedIgnoreStimuli(gMandy, false)
        end
        if shared.gAlarmOn then
            if gMandy then
                PedFollowPath(gMandy, PATH._1_S01_BATHROOM_GIRL_PATH, 0, 1)
                PedMakeAmbient(gMandy)
            end
        else
            gOBjectiveTable[2] = MissionObjectiveAdd("1_S01_02")
            TextPrint("1_S01_02", 3, 1)
            SoundPlayScriptedSpeechEvent(gMandy, "M_4_01", 7)
            PedFollowPath(gMandy, PATH._1_S01_BATHROOM_GIRL_PATH, 0, 1, CbMandyRunaway)
            if not gHallMon then
                gHallMon = true
            end
        end
        gBathBottleFunction = F_S1_BottleBath
    end
end

function F_S1_BottleBath()
    if not gOBjectiveTable[2] and PlayerIsInTrigger(TRIGGER._1_S01_BATHROOM) then
        gOBjectiveTable[2] = MissionObjectiveAdd("1_S01_02")
        TextPrint("1_S01_02", 3, 1)
    end
    if PickupIsPickedUp(bath_bottle) then
        if bath_bottle_arrow then
            BlipRemove(bath_bottle_arrow)
        end
        CounterIncrementCurrent(1)
        MissionObjectiveComplete(gOBjectiveTable[2])
        gHasBathBottle = true
        gBottlesPickedUp = gBottlesPickedUp + 1
    end
end

function F_S1_BottleCafe_Setup()
    if PlayerIsInTrigger(TRIGGER._1_S01_CAFE) then
        gOBjectiveTable[3] = MissionObjectiveAdd("1_S01_01")
        TextPrint("1_S01_01", 3, 1)
        gEdnaGuard = PedCreatePoint(50, POINTLIST._1_S01_EDNA_GUARD)
        if gEdnaGuard then
            PedFollowPath(gEdnaGuard, PATH._1_S01_EDNA_GUARD_PATH, 2, 0)
            PedOverrideStat(gEdnaGuard, 3, 12)
            PedOverrideStat(gEdnaGuard, 2, 70)
        end
        gEdna = PedCreatePoint(58, POINTLIST._1_S01_EDNA)
        if gEdna then
            PedSetPedToTypeAttitude(gEdna, 13, 0)
            PedSetTetherToTrigger(gEdna, TRIGGER._1_S01_KITCHEN)
            PedSetStealthBehavior(gEdna, 0, Cb_EdnaCallPrefect)
            PedFollowPath(gEdna, PATH._1_S01_EDNA_PATH, 2, 0)
            BlipRemoveFromChar(gEdna)
        end
        gCafeBottleFunction = F_S1_BottleCafe
    end
end

function F_S1_BottleCafe()
    if PickupIsPickedUp(cafe_bottle) then
        if cafe_bottle_arrow then
            BlipRemove(cafe_bottle_arrow)
        end
        CounterIncrementCurrent(1)
        MissionObjectiveComplete(gOBjectiveTable[3])
        gHasCafeBottle = true
        gBottlesPickedUp = gBottlesPickedUp + 1
    elseif gEdnaSpeechTimer and GetTimer() - gEdnaSpeechTimer > 8000 then
        SoundPlayScriptedSpeechEvent(gEdna, "CONVERSATION_GOSSIP", 0, "large")
        gEdnaSpeechTimer = GetTimer()
    end
    if not gEdnaFirstSpeech and PedIsValid(gEdna) and PlayerIsInAreaObject(gEdna, 2, 8, 0) then
        gEdnaFirstSpeech = true
        SoundPlayScriptedSpeechEvent(gEdna, "CONVERSATION_GOSSIP_CHAPTER_1", 0, "large")
        gEdnaSpeechTimer = GetTimer()
    end
end

function F_S1_BottleTrophy_Setup()
    if not gTrophySetup and (PlayerIsInTrigger(TRIGGER._1_S01_TROPHYSETUP) or PAnimNumDestroyed(TRIGGER._1_S01_GLASS) > 0) then
        gTrophySetup = true
        gPrincipal = PedCreatePoint(65, POINTLIST._1_S01_CRABBLE, 1)
        gHattrick = PedCreatePoint(61, POINTLIST._1_S01_CRABBLE, 2)
        F_Socialize(gPrincipal, true)
        F_Socialize(gHattrick, true)
        PedFaceObject(gHattrick, gPrincipal, 2, 0)
        PedFaceObject(gPrincipal, gHattrick, 2, 0)
        PedSetStealthBehavior(gHattrick, 0, Cb_HattrickSeePlayer)
        gHattrickSpeech = {
            { gHattrick,  1 },
            { gPrincipal, 2 },
            { gHattrick,  3 },
            { gPrincipal, 5 }
        }
        CreateThread("T_HattrickSpeech")
        if PAnimNumDestroyed(TRIGGER._1_S01_GLASS) > 0 then
            gBrokeGlass = true
        end
    end
    if PlayerIsInTrigger(TRIGGER._1_S01_BOTTLE_TRIG_CASE) or gBrokeGlass then
        gOBjectiveTable[4] = MissionObjectiveAdd("1_S01_03")
        TextPrint("1_S01_03", 3, 1)
        gTrophyBottleFunction = F_S1_BottleTrophy
    end
end

function F_S1_BottleTrophy()
    if not trophy_bottle and PAnimNumDestroyed(TRIGGER._1_S01_GLASS) > 0 then
        local tbx, tby, tbz = GetPointList(POINTLIST._1_S01_BOTTLE3_CASE)
        trophy_bottle = PickupCreateXYZ(529, tbx, tby, tbz, "PermanentButes")
        local hx, hy, hz = PedGetPosXYZ(gHattrick)
        if DistanceBetweenCoords3d(tbx, tby, tbz, hx, hy, hz) <= 10 and gHattrick and gPrincipal then
            gBreakSpeech = true
            SoundStopCurrentSpeechEvent()
            SoundPlayScriptedSpeechEvent(gHattrick, "M_4_06", 27, "large")
            PedRecruitAlly(gHattrick, gPrincipal)
            --print("[RAUL][HATTRICK] - Following Path 1_S01_HATTRICKPATH01")
            gHeardPlayerBreakingGlass = true
            PedFollowPath(gHattrick, PATH._1_S01_HATTRICKPATH01, 0, 1, CbHattrickEndPath01)
        end
    end
    if trophy_bottle and PickupIsPickedUp(trophy_bottle) then
        GeometryInstance("1S01_bbagbottle", true, -627.619, -293.51, 6.55437, false)
        CounterIncrementCurrent(1)
        MissionObjectiveComplete(gOBjectiveTable[4])
        gHasTrophyBottle = true
        gBottlesPickedUp = gBottlesPickedUp + 1
    end
end

function F_HattrickFunctions()
    if gHattrick and gPrincipal and not gHattrickAttack then
        if gHattrickNextStep == 1 then
            PedRecruitAlly(gHattrick, gPrincipal)
            --print("[RAUL][HATTRICK] - Following Path 1_S01_HATTRICKPATH01 - Inside HattrickFunctions")
            PedFollowPath(gHattrick, PATH._1_S01_HATTRICKPATH01, 0, 0, CbHattrickEndPath01)
        elseif gHattrickNextStep == 2 then
            gHattrickSpeech = {
                { gHattrick,  27 },
                { gPrincipal, 28 },
                { gHattrick,  29 },
                { gPrincipal, 30 },
                { gHattrick,  4 }
            }
            CreateThread("T_HattrickSpeech")
        elseif gHattrickNextStep == 3 then
            --print("[RAUL][HATTRICK] - Following Path 1_S01_HATTRICKPATH02 - Inside HattrickFunctions")
            PedFollowPath(gHattrick, PATH._1_S01_HATTRICKPATH02, 0, 0, CbHattrickEndPath02)
        elseif gHattrickNextStep == 4 then
            gHattrickSpeech = {
                { gPrincipal, 8 },
                { gPrincipal, 9 },
                { gHattrick,  10 },
                { gHattrick,  11 }
            }
            CreateThread("T_HattrickSpeech")
        elseif gHattrickNextStep == 5 then
            --print("[RAUL][HATTRICK] - Following Path 1_S01_HATTRICKPATH03 - Inside HattrickFunctions")
            PedFollowPath(gHattrick, PATH._1_S01_HATTRICKPATH03, 0, 0, CbHattrickCafeteriaPath)
        end
    end
    gHattrickFunction = false
end

function T_BathroomMonitor()
    if gHallMon then
        PedIgnoreStimuli(gHallMon, false)
    end
    glookingForPlayer = true
    local lookingStage = 1
    if gHallMon then
        SoundPlayAmbientSpeechEvent(gHallMon, "WARNING_COMING_TO_CATCH")
        PedFollowPath(gHallMon, PATH._1_S01_BROOMSTALLS, 0, 0, CbCheckingStalls)
    end
    while glookingForPlayer and gMissionRunning do
        if gReachedNextStall then
            if lookingStage == 1 then
                lookingStage = lookingStage + 1
            elseif lookingStage == 2 then
                if not AreaIsDoorOpen(TRIGGER._STALDOOR06) then
                    PAnimOpenDoor(TRIGGER._STALDOOR06)
                end
                SoundPlayAmbientSpeechEvent(gHallMon, "CHASE")
                lookingStage = lookingStage + 1
            elseif lookingStage == 3 then
                if not AreaIsDoorOpen(TRIGGER._STALDOOR07) then
                    PAnimOpenDoor(TRIGGER._STALDOOR07)
                end
                SoundPlayAmbientSpeechEvent(gHallMon, "STEALTH_INVESTIGATING")
                lookingStage = lookingStage + 1
            elseif lookingStage == 4 then
                SoundPlayAmbientSpeechEvent(gHallMon, "STEALTH_CONFUSION")
                lookingStage = lookingStage + 1
            end
            gReachedNextStall = false
        end
        Wait(0)
    end
    if gHallMon then
        PedMakeAmbient(gHallMon)
    end
end

function T_HattrickSpeech()
    SoundDisableSpeech_ActionTree()
    local i = 1
    while i <= table.getn(gHattrickSpeech) and gMissionRunning do
        if gBreakSpeech then
            break
        end
        PedSetActionNode(gHattrickSpeech[i][1], "/Global/1_S01/1_S01_Stand_Talking/TalkingLoops", "Act/Conv/1_S01.act")
        F_PlaySpeechAndWait(gHattrickSpeech[i][1], "M_1_S01", gHattrickSpeech[i][2], "medium")
        i = i + 1
        Wait(0)
        if gBreakSpeech then
            break
        end
    end
    SoundEnableSpeech_ActionTree()
    if not gBreakSpeech then
        gHattrickNextStep = gHattrickNextStep + 1
        gHattrickFunction = true
    end
end

function CbHallMonitorAttack(pedId)
    --print("[RAUL] - HALL MONITOR CALLBACK CALLED ")
    if not hallmonSawPlayer then
        gPlayerSpotted = true
        hallmonSawPlayer = true
    end
end

function Cb_HattrickSeePlayer(pedId)
    if not gHattrickSeenPlayer and (gBottlesPickedUp > 0 or gHeardPlayerBreakingGlass) then
        gBreakSpeech = true
        gHattrickSeenPlayer = true
        gHattrickAttack = true
        PedClearTether(gHattrick)
        PedClearTether(gPrincipal)
    end
end

function Cb_EdnaCallPrefect(pedId)
    if not ednaSawPlayer and gEdna and PlayerIsInTrigger(TRIGGER._1_S01_KITCHEN) then
        SoundPlayScriptedSpeechEvent(gEdna, "M_4_06", 8, "large")
        if gEdnaGuard then
            PedAttackPlayer(gEdnaGuard, 0, true)
        end
        ednaSawPlayer = true
        gPlayerSpotted = true
    end
end

function CbCheckingStalls(pedId, pathId, pathNode)
    gReachedNextStall = true
    if pathNode == 7 then
        glookingForPlayer = false
    end
end

function CbHallMonitor(pedId, pathId, pathNode)
    if pathNode == 4 then
        gMonitorInWashroom = true
    end
end

function CbMandyRunaway(pedId, pathId, pathNode)
    if pathNode == 3 then
        if not gHallMon then
            gHallMon = true
        end
    elseif pathNode == 4 then
        gMakeMandyAmbient = true
    end
end

function CbHattrickEndPath01(pedId, pathId, pathNode)
    if pathNode == 3 then
        gHattrickNextStep = gHattrickNextStep + 1
        gHattrickFunction = true
        gHeardPlayerBreakingGlass = false
    end
end

function CbHattrickEndPath02(pedId, pathId, pathNode)
    if pathNode == 8 then
        gHattrickNearBathroom = true
        gHattrickReachBathroomTime = GetTimer()
    end
end

function CbHattrickCafeteriaPath(pedId, pathId, pathNode)
    --print("[RAUL] HATTRICK PATHNODE:", pathNode)
    if pathNode == 23 then
        gHattrickInCafeteria = true
    end
end

function F_Set_Up_Bottles()
    local b2x, b2y, b2z = GetPointList(POINTLIST._1_S01_2ND_BOTTLE_BATH)
    bath_bottle = PickupCreateXYZ(529, b2x, b2y, b2z, "PermanentButes")
    bath_bottle_blip = BlipAddPoint(POINTLIST._1_S01_BATHROOM_BLIP, 0)
    bath_bottle_arrow = BlipAddXYZ(b2x, b2y, b2z, 0, 2)
    local b3x, b3y, b3z = GetPointList(POINTLIST._1_S01_3RD_BOTTLE_CAFE)
    cafe_bottle = PickupCreateXYZ(529, b3x, b3y, b3z, "PermanentButes")
    cafe_bottle_arrow = BlipAddXYZ(b3x, b3y, b3z, 0, 2)
    cafe_bottle_blip = BlipAddPoint(POINTLIST._1_S01_CAFE_BLIP, 0)
    trophy_bottle_blip = BlipAddPoint(POINTLIST._1_S01_BOTTLE3_BLIP, 0)
end

function F_Socialize(pedId, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 25, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 26, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 28, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 29, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 30, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 33, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 34, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 35, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 36, bDisable)
end

function CbPlayerAggressed()
    gMissionFail = true
    gMissionFailMessage = "1_S01_04"
    if phillips and PedIsValid(phillips) then
        PedSetInvulnerable(phillips, false)
        PedSetFlag(phillips, 113, false)
        PedSetStationary(phillips, false)
        PedIgnoreStimuli(phillips, false)
        PedMakeAmbient(phillips)
    end
end

function F_BlipHandling()
    if not gHasBathBottle then
        if not gInsideBathroom and PlayerIsInTrigger(TRIGGER._1_S01_BATHROOM) then
            BlipRemove(bath_bottle_blip)
            gInsideBathroom = true
        elseif gInsideBathroom and not PlayerIsInTrigger(TRIGGER._1_S01_BATHROOM) then
            bath_bottle_blip = BlipAddPoint(POINTLIST._1_S01_BATHROOM_BLIP, 0)
            gInsideBathroom = false
        end
    end
    if not gHasCafeBottle then
        if not gInsideCafe and PlayerIsInTrigger(TRIGGER._1_S01_CAFE) then
            BlipRemove(cafe_bottle_blip)
            gInsideCafe = true
        elseif gInsideCafe and not PlayerIsInTrigger(TRIGGER._1_S01_CAFE) then
            cafe_bottle_blip = BlipAddPoint(POINTLIST._1_S01_CAFE_BLIP, 0)
            gInsideCafe = false
        end
    end
    if not gHasTrophyBottle then
        if not gInsideTrophy and PlayerIsInTrigger(TRIGGER._1_S01_BOTTLE_TRIG_CASE) then
            BlipRemove(trophy_bottle_blip)
            gInsideTrophy = true
        elseif gInsideTrophy and not PlayerIsInTrigger(TRIGGER._1_S01_BOTTLE_TRIG_CASE) then
            trophy_bottle_blip = BlipAddPoint(POINTLIST._1_S01_BOTTLE3_BLIP, 0)
            gInsideTrophy = false
        end
    end
end
