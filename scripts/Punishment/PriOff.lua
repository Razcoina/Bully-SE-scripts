ImportScript("Punishment/PrincipalSayings.lua")
local principal
local weaponString = ""
local missionDescString = ""
local gListOfBadDeeds = {}

function F_ExecutePrincipalCutscene()
    CameraSetWidescreen(true)
    LoadAnimationGroup("IDLE_BULLY_D")
    PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetBreathe", "Act/Conv/PriOff.act")
    PedSetActionNode(gPlayer, "/Global/PriOff/Jimmy/Jimmy01", "Act/Conv/PriOff.act")
    CameraSetWidescreen(false)
    --print("WTF?????!!!!!")
end

function F_ExecutePunishmentMissionBriefing()
    F_ExecutePrincipalMissionDialogue()
end

function main()
    --print("Starting mission.")
    LoadAnimationGroup("IDLE_BULLY_D")
    SoundStopInteractiveStream(0)
    SoundEnableInteractiveMusic(false)
    SoundDisableSpeech_ActionTree()
    SoundStopCurrentSpeechEvent(gPlayer)
    F_MakePlayerSafeForNIS(true)
    PedLockTarget(gPlayer, principal)
    PedLockTarget(principal, gPlayer)
    PedSetActionNode(gPlayer, "/Global/PriOff/Jimmy/Jimmy01", "Act/Conv/PriOff.act")
    CameraSetFOV(70)
    CameraSetXYZ(-700.4642, 201.46802, 32.831036, -700.9804, 202.3243, 32.819817)
    CameraSetWidescreen(true)
    PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetBreathe", "Act/Conv/PriOff.act")
    CameraFade(500, 1)
    Wait(500)
    F_NISCore()
    CameraFade(500, 0)
    Wait(500)
    if 0 < GetMissionSuccessCount("PriOff") then
        StatUpdatePrincipalStats()
        AreaDisableCameraControlForTransition(true)
        PlayerSetScriptSavedData(14, 1)
    end
    SoundRestartPA()
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    SoundEnableSpeech_ActionTree()
    if GetMissionSuccessCount("PriOff") == 0 then
        StatUpdatePrincipalStats()
        AreaTransitionPoint(2, POINTLIST._PRIOFF_OUTSIDE, 1, true)
        while not shared.gAreaDATFileLoaded[2] do
            Wait(0)
        end
        CameraSetXYZ(-631.3006, -297.3262, 7.366553, -631.9573, -296.5855, 7.224535)
        CameraFade(500, 1)
        Wait(10)
        TutorialShowMessage("TUT_NOW01", 5000, false)
        CameraReturnToPlayer(false)
    end
    SoundEnableInteractiveMusic(true)
    MissionSucceed(false, false, false)
end

function F_NISCore()
    local badDeed = -1
    if GetMissionSuccessCount("PriOff") == 0 then
        PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetBreathe", "Act/Conv/PriOff.act")
        if F_PlaySpeechWait(principal, "PRINCIPAL_LECTURING", 10, "large") then
            return
        end
        CameraSetFOV(40)
        CameraSetXYZ(-705.6322, 204.21594, 33.77, -704.7316, 204.54642, 33.487885)
        PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetGesture", "Act/Conv/PriOff.act")
        if F_PlaySpeechWait(principal, "PRINCIPAL_LECTURING", 51, "large") then
            return
        end
        CameraSetFOV(20)
        CameraSetXYZ(-699.4192, 203.85728, 32.82823, -700.37585, 204.13902, 32.895573)
        PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetPoint", "Act/Conv/PriOff.act")
        if F_PlaySpeechWait(principal, "PRINCIPAL_LECTURING", 52, "large") then
            return
        end
    else
        PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetBreathe", "Act/Conv/PriOff.act")
        if F_PlaySpeechWait(principal, "PRINCIPAL_LECTURING", 1, "large") then
            return
        end
        CameraSetFOV(30)
        CameraSetXYZ(-698.947, 202.12222, 32.280045, -699.7298, 202.72948, 32.415512)
        PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetBreathe", "Act/Conv/PriOff.act")
        if F_PlaySpeechWait(principal, "PRINCIPAL_LECTURING", 2, "large") then
            return
        end
        badDeed = F_GetBadDeed()
        if badDeed ~= -1 then
            CameraSetFOV(40)
            CameraSetXYZ(-705.68225, 203.56009, 33.12385, -704.8029, 204.02673, 33.030518)
            PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetBreathe", "Act/Conv/PriOff.act")
            if F_PlaySpeechWait(principal, "PRINCIPAL_LECTURING", badDeed, "large") then
                return
            end
            badDeed = -1
        end
        badDeed = F_GetBadDeed()
        if badDeed ~= -1 then
            PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetBreathe", "Act/Conv/PriOff.act")
            if F_PlaySpeechWait(principal, "PRINCIPAL_LECTURING", badDeed, "large") then
                return
            end
        end
        CameraSetFOV(20)
        CameraSetXYZ(-699.4192, 203.85728, 32.82823, -700.37585, 204.13902, 32.895573)
        PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetGesture", "Act/Conv/PriOff.act")
        if F_PlaySpeechWait(principal, "PRINCIPAL_LECTURING", 50, "large") then
            return
        end
        PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetPoint", "Act/Conv/PriOff.act")
        if F_PlaySpeechWait(principal, "PRINCIPAL_LECTURING", 52, "large") then
            return
        end
    end
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
    local skip = false
    local waitTime = 0
    if bAmbient then
        SoundPlayAmbientSpeechEvent(pedId, strEvent)
        while not (not SoundSpeechPlaying() or skip) do
            skip = WaitSkippable(1)
        end
    else
        SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
        while not (not SoundSpeechPlaying() or skip) do
            skip = WaitSkippable(1)
        end
    end
    return skip
end

function MissionSetup()
    MissionDontFadeIn()
    LoadAnimationGroup("NPC_Principal")
    LoadAnimationGroup("NPC_AggroTaunt")
    DATLoad("PrincipalCutscene.DAT", 2)
    DATInit()
    WeaponRequestModel(305)
    WeaponRequestModel(307)
    WeaponRequestModel(308)
    WeaponRequestModel(306)
    WeaponRequestModel(303)
    WeaponRequestModel(304)
    WeaponRequestModel(322)
    PlayerSetControl(0)
    AreaTransitionPoint(5, POINTLIST._PRIOFF_SPAWN, 1, true)
    local x, y, z = GetPointFromPointList(POINTLIST._PRIOFF_SPAWN, 1)
    PedRequestModel(65)
    principal = PedCreatePoint(65, POINTLIST._PRIOFF_SPAWN, 2)
    PedSetActionNode(principal, "/Global/PriOff/TargetAnimations/TargetBreathe", "Act/Conv/PriOff.act")
    gListOfBadDeeds = {
        { stat = 0,  func = F_NumberOfBikesJacked },
        { stat = 1,  func = F_NumberOfFireAlarmsPulled },
        { stat = 3,  func = F_NumberOfArtClassesFailed },
        { stat = 4,  func = F_NumberOfWrestlingClassesFailed },
        { stat = 5,  func = F_NumberOfChemistryClassesFailed },
        { stat = 6,  func = F_NumberOfEnglishClassesFailed },
        { stat = 7,  func = F_NumberOfShopClassesFailed },
        { stat = 8,  func = F_NumberOfPhotographyClassesFailed },
        { stat = 9,  func = F_NumberOfPeopleHitByPapers },
        { stat = 10, func = F_NumberOfDogsHitByPapers },
        { stat = 11, func = F_NumberOfTimesCaughtTagging },
        { stat = 12, func = F_NumberOfLockersBrokenInto },
        { stat = 13, func = F_NumberOfDiceGamesPlayed },
        { stat = 14, func = F_NumberOfPeopleDefeated },
        { stat = 16, func = F_NumberOfPeopleAssaultedWithAToilet },
        { stat = 17, func = F_NumberOfPeopleShovedIntoGarbageBins },
        { stat = 18, func = F_NumberOfPunishmentPointsAccumulated },
        { stat = 19, func = F_NumberOfTimesBustedByTeachers },
        { stat = 20, func = F_NumberOfTimesTauntedTeachers },
        { stat = 21, func = F_NumberOfTimesBustedByPrefects },
        { stat = 22, func = F_NumberOfTimesTauntedPrefects },
        { stat = 23, func = F_NumberOfTimesBustedByCops },
        { stat = 24, func = F_NumberOfTimesTauntedCops },
        { stat = 25, func = F_NumberOfTimesBustedByOrderlies },
        { stat = 28, func = F_NumberOfStolenBikesSold },
        { stat = 30, func = F_NumberOfTrashBinsSmashed },
        { stat = 31, func = F_NumberOfCarsEgged },
        { stat = 32, func = F_NumberOfWindowsBroken },
        { stat = 33, func = F_NumberOfPlantsSmashed },
        { stat = 34, func = F_NumberOfTimesPlayerMadeSomeonePuke },
        { stat = 35, func = F_NumberOfTimesPlayerMadeSomeoneCry }
    }
    --print("Mission setup done.")
end

function MissionCleanup()
    --print("Executing mission cleanup")
    UnLoadAnimationGroup("NPC_Principal")
    UnLoadAnimationGroup("NPC_AggroTaunt")
    UnLoadAnimationGroup("IDLE_BULLY_D")
    PedDelete(principal)
    ConversationMovePeds(true)
    PlayerSetControl(1)
    DATUnload(2)
end

function F_GetBadDeed()
    local index, refEntry, count
    while table.getn(gListOfBadDeeds) > 0 do
        index = math.random(1, table.getn(gListOfBadDeeds))
        refEntry = table.remove(gListOfBadDeeds, index)
        count = StatGetPrincipalDiffAsInt(refEntry.stat)
        --print("Count is: ", count, " Punishment enum: ", refEntry.stat)
        if 0 < count then
            --print("BAD DEED FOUND!: ", refEntry.stat)
            count = refEntry.func()
            --print("BAD DEED ID!: ", count)
            break
        end
    end
    return count or -1
end

function F_ExecutePrincipalMissionDialogue()
end
