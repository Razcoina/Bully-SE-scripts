local missionSuccess = false
local nCurrentWordScore = 0
local nCurrentScore = 0
local nCurrentClass
local bStageLoaded = false
local tblClasses = {
    {
        cinconv = "C7_INTRO_1",
        percent = 55,
        wordlimit = 3,
        timer = 180,
        grade = 1
    },
    {
        cinconv = "C7_INTRO_2",
        percent = 55,
        wordlimit = 6,
        taxicab = 1,
        timer = 165,
        grade = 2
    },
    {
        cinconv = "C7_INTRO_3",
        percent = 55,
        wordlimit = 3,
        letterlimit = 4,
        timer = 170,
        grade = 3
    },
    {
        cinconv = "C7_INTRO_4",
        percent = 55,
        wordlimit = 1,
        letterlimit = 6,
        timer = 165,
        grade = 4
    },
    {
        cinconv = "C7_INTRO_5",
        percent = 55,
        taxicab = 1,
        timer = 160,
        grade = 5
    }
}
local tblClasses1 = {
    {
        cinconv = "C7_INTRO_1",
        percent = 14,
        wordlimit = 3,
        timer = 180,
        grade = 1
    },
    {
        cinconv = "C7_INTRO_2",
        percent = 19,
        wordlimit = 6,
        taxicab = 1,
        timer = 165,
        grade = 2
    },
    {
        cinconv = "C7_INTRO_3",
        percent = 12,
        wordlimit = 3,
        letterlimit = 4,
        timer = 170,
        grade = 3
    },
    {
        cinconv = "C7_INTRO_4",
        percent = 13,
        wordlimit = 1,
        letterlimit = 6,
        timer = 165,
        grade = 4
    },
    {
        cinconv = "C7_INTRO_5",
        percent = 16,
        taxicab = 1,
        timer = 160,
        grade = 5
    }
}

local gInsultModels = {
    70,
    66,
    69,
    142,
    139
}
function MissionSetup()
    DATLoad("ClassLoc.DAT", 2)
    DATLoad("C7.DAT", 2)
    DATInit()
    MissionDontFadeIn()
    SoundEnableInteractiveMusic(false)
    AreaTransitionPoint(15, POINTLIST._C7_PSTART, nil, true)
    MinigameCreate("ENGLISH", false)
    while not MinigameIsReady() do
        --print("STUCK MISSION SETUP")
        Wait(0)
    end
    PlayerSetMinPunishmentPoints(0)
    HUDSaveVisibility()
    HUDClearAllElements()
    ToggleHUDComponentVisibility(42, true)
    Wait(2)
    SoundStopPA()
    SoundStopCurrentSpeechEvent()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    SoundDisableSpeech_ActionTree()
end

function MissionCleanup()
    HUDRestoreVisibility()
    SoundRestartPA()
    SoundEnableInteractiveMusic(true)
    PlayerWeaponHudLock(false)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    SoundFadeoutStream()
    PedSetActionNode(gPlayer, "/Global/C7/Release", "Act/Conv/C7.act")
    MinigameDestroy()
    SoundStopStream()
    SoundEnableSpeech_ActionTree()
    UnLoadAnimationGroup("NPC_Adult")
    UnLoadAnimationGroup("UBO")
    UnLoadAnimationGroup("MINI_React")
    UnLoadAnimationGroup("ENGLISHCLASS")
    UnLoadAnimationGroup("SBULL_X")
    if not transitioned then
        AreaTransitionPoint(2, POINTLIST._C7_PEND)
    end
    PedClearObjectives(gPlayer)
    PedStop(gPlayer)
    PlayerSetPunishmentPoints(0)
    F_MakePlayerSafeForNIS(false)
    if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
        PlayerSetHealth(PedGetMaxHealth(gPlayer))
    end
    PedSetFlag(gPlayer, 128, false)
    PlayerSetControl(1)
    DATUnload(2)
end

function main()
    while not bStageLoaded do
        Wait(0)
        print("STUCK HERE")
    end
    F_MakePlayerSafeForNIS(true)
    PlayerWeaponHudLock(true)
    VehicleOverrideAmbient(0, 0, 0, 0)
    AreaClearAllPeds()
    PlayerSetControl(0)
    AreaSetDoorLocked("DT_CLASSR_DOORL", true)
    LoadActionTree("Act/Conv/C7.act")
    LoadAnimationGroup("NPC_Adult")
    LoadAnimationGroup("MINI_React")
    LoadAnimationGroup("UBO")
    LoadAnimationGroup("ENGLISHCLASS")
    LoadAnimationGroup("SBULL_X")
    F_IntroCinematic()
    ClassEnglishSetLevel(nCurrentClass)
    MinigameStart()
    SoundPlayStream("MS_EnglishClass.rsm", 0.15, 0, 0)
    F_InitRules()
    CameraSetWidescreen(false)
    MinigameEnableHUD(true)
    Wait(1000)
    CameraSetFOV(30)
    CameraSetXYZ(-561.0058, 321.40848, -0.828353, -560.6053, 322.3187, -0.724545)
    while MinigameIsActive() do
        Wait(0)
        if ClassEnglishWordWasValid() and not ClassEnglishWordWasDuplicate() then
            SoundPlayScriptedSpeechEvent(galloway, "ENGLISH", 11, "large", true)
            SoundPlay2D("SpellRight")
            --print("WORD LENGTH = " .. ClassEnglishGetLastSubmittedWord())
            --print("VALID WORD! Count: " .. nCurrentWordScore)
        elseif ClassEnglishWordWasNaughty() then
            SoundPlayScriptedSpeechEvent(galloway, "ENGLISH", 14, "large", true)
            SoundPlay2D("SpellWrong")
            --print("NAUGHTY WORD!!!")
        elseif ClassEnglishWordWasTooShort() then
            SoundPlay2D("SpellWrong")
            SoundPlayScriptedSpeechEvent(galloway, "ENGLISH", 13, "large", true)
        elseif ClassEnglishWordWasNotValid() then
            SoundPlay2D("SpellWrong")
            SoundPlayScriptedSpeechEvent(galloway, "ENGLISH", 12, "large", true)
            --print("INVALID WORD!!!")
        end
        if gStartedLoop and GetTimer() - gStartedLoop > 13000 then
            SoundLoopPlay2D("TimeWarningLOOP", false)
        end
        F_CheckRules()
    end
    CameraSetWidescreen(true)
    MinigameEnableHUD(false)
    PedFaceObject(gPlayer, galloway, 2, 0)
    PedSetActionNode(gPlayer, "/Global/C7/PlayerSit/PlayerStand", "Act/Conv/C7.act")
    while PedIsPlaying(gPlayer, "/Global/C7/PlayerSit/PlayerStand", true) do
        Wait(0)
    end
    if missionSuccess then
        SoundPlayScriptedSpeechEvent(galloway, "ENGLISH", 9, "large", true)
        PedSetActionNode(gPlayer, "/Global/C7/PlayerVictory/PlayerVictory03", "Act/Conv/C7.act")
    else
        SoundPlayScriptedSpeechEvent(galloway, "ENGLISH", 10, "large", true)
        SoundPlay2D("Fatigued01")
        PedSetActionNode(gPlayer, "/Global/C7/PlayerFail", "Act/Conv/C7.act")
        PedSetActionNode(galloway, "/Global/C7/TeacherDisgust", "Act/Conv/C7.act")
    end
    SoundLoopPlay2D("TimeWarningLOOP", false)
    if missionSuccess and not bIsRepeatable then
        if GetLanguage() == 7 then
            PlayerSetGrade(2, tblClasses1[nCurrentClass].grade)
        else
            PlayerSetGrade(2, tblClasses[nCurrentClass].grade)
        end
    end
    if not bIsRepeatable then
        if GetLanguage() == 7 then
            if 0 < tblClasses1[nCurrentClass].grade then
                MinigameSetGrades(2, tblClasses1[nCurrentClass].grade - 1)
            else
                MinigameSetGrades(2, tblClasses1[nCurrentClass].grade)
            end
        else
            if 0 < tblClasses[nCurrentClass].grade then
                MinigameSetGrades(2, tblClasses[nCurrentClass].grade - 1)
            else
                MinigameSetGrades(2, tblClasses[nCurrentClass].grade)
            end
        end
        SoundFadeoutStream()
        if missionSuccess then
            SoundPlayMissionEndMusic(true, 9)
        else
            SoundPlayMissionEndMusic(false, 9)
        end
        while MinigameIsShowingGrades() do
            Wait(0)
        end
        if missionSuccess and nCurrentClass == 5 then
            CameraFade(500, 0)
            Wait(500)
            CameraSetXYZ(-560.21686, 320.88766, -0.310778, -560.04767, 319.90237, -0.288369)
            SoundStopCurrentSpeechEvent(galloway)
            PedStop(galloway)
            PedClearObjectives(galloway)
            PedFaceHeading(galloway, 0, 0)
            CameraFade(500, 1)
            Wait(500)
            F_PlaySpeechAndWait(galloway, "ENGLISH", 15, "large")
        end
    end
    Wait(1000)
    CameraFade(500, 0)
    Wait(500)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    if missionSuccess then
        if not bIsRepeatable then
            F_EndCinematic()
        end
        MissionSucceed(false, true, false)
    else
        SoundPlayMissionEndMusic(false, 9)
        MissionFail(true, false)
    end
    CameraReturnToPlayer()
    CameraReset()
end

function F_InitRules()
    if GetLanguage() == 7 then
        if tblClasses1[nCurrentClass].timer then
            if tblClasses1[nCurrentClass].taxicab then
                ClassEnglishSetTimer(tblClasses1[nCurrentClass].timer, tblClasses1[nCurrentClass].taxicab)
            else
                ClassEnglishSetTimer(tblClasses1[nCurrentClass].timer, 0)
            end
        end
        if tblClasses1[nCurrentClass].percent then
            ClassEnglishSetScorePercentage(tblClasses1[nCurrentClass].percent)
        end
        local dif = (100 - tblClasses1[nCurrentClass].percent) / 2
        ClassEnglishSetScoreMsg(tblClasses1[nCurrentClass].percent, "MGCE_SCMSG1")
        ClassEnglishSetScoreMsg(tblClasses1[nCurrentClass].percent + dif, "MGCE_SCMSG2")
    else
        if tblClasses[nCurrentClass].timer then
            if tblClasses[nCurrentClass].taxicab then
                ClassEnglishSetTimer(tblClasses[nCurrentClass].timer, tblClasses[nCurrentClass].taxicab)
            else
                ClassEnglishSetTimer(tblClasses[nCurrentClass].timer, 0)
            end
        end
        if tblClasses[nCurrentClass].percent then
            ClassEnglishSetScorePercentage(tblClasses[nCurrentClass].percent)
        end
        local dif = (100 - tblClasses[nCurrentClass].percent) / 2
        ClassEnglishSetScoreMsg(tblClasses[nCurrentClass].percent, "MGCE_SCMSG1")
        ClassEnglishSetScoreMsg(tblClasses[nCurrentClass].percent + dif, "MGCE_SCMSG2")
    end
    ClassEnglishSetScoreMsg(100, "MGCE_SCMSG3")
    ClassEnglishSetTrigFunc(15, F_ChangeMusic)
end

function F_CheckRules()
    if MinigameIsSuccess() then
        missionSuccess = true
    end
end

function F_CalcTime()
    initTimer = GetTimer()
    while true do
        if IsButtonPressed(0, 0) then
            endTimer = GetTimer()
            break
        end
        Wait(0)
    end
    --print(" TIMER ", endTimer - initTimer)
end

function F_IntroCinematic()
    PedSetPosPoint(gPlayer, POINTLIST._C7_PSTART, 1)
    galloway = PedCreatePoint(57, POINTLIST._C7_GALLOWAY)
    student1 = PedCreatePoint(3, POINTLIST._C7_STUDENTS, 1)
    student2 = PedCreatePoint(35, POINTLIST._C7_STUDENTS, 2)
    student3 = PedCreatePoint(66, POINTLIST._C7_STUDENTS, 3)
    Wait(1500)
    GeometryInstance("kidchair", true, -560.141, 322.159, -1.48522, false)
    PedIgnoreStimuli(galloway, true)
    PedIgnoreStimuli(student1, true)
    PedIgnoreStimuli(student2, true)
    PedIgnoreStimuli(student3, true)
    PedSetAsleep(galloway, true)
    CameraSetWidescreen(true)
    Wait(1000)
    if not F_CheckIfPrefect() then
        CameraFade(1000, 1)
    end
    CameraSetXYZ(-562.5938, 323.06516, -0.722657, -562.10114, 322.19528, -0.698963)
    PedFollowPath(student1, PATH._C7_STUDENT1, 0, 0)
    PedFollowPath(student2, PATH._C7_STUDENT2, 0, 0)
    PedFollowPath(student3, PATH._C7_STUDENT3, 0, 0)
    PedStop(gPlayer)
    PedIgnoreStimuli(gPlayer, true)
    PedFollowPath(gPlayer, PATH._C7_PLAYERPATH, 0, 0)
    PedPathNodeReachedDistance(gPlayer, 0.5)
    if nCurrentClass == 1 then
        F_PlaySpeechAndWait(galloway, "ENGLISH", 1, "large")
        F_PlaySpeechAndWait(galloway, "ENGLISH", 2, "large")
    elseif nCurrentClass == 2 then
        F_PlaySpeechAndWait(galloway, "ENGLISH", 5, "large")
    elseif nCurrentClass == 3 then
        F_PlaySpeechAndWait(galloway, "ENGLISH", 4, "large")
    elseif nCurrentClass == 4 then
        F_PlaySpeechAndWait(galloway, "ENGLISH", 8, "large")
    elseif nCurrentClass == 5 then
        F_PlaySpeechAndWait(galloway, "ENGLISH", 6, "large")
    end
    if nCurrentClass == 1 then
        Wait(0)
    elseif nCurrentClass == 4 then
        Wait(3000)
    else
        Wait(2000)
    end
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedSetPosPoint(gPlayer, POINTLIST._C7_PLAYERSIT, 1)
    Wait(1000)
    CameraSetFOV(40)
    CameraSetXYZ(-560.63806, 321.6818, -1.018964, -560.3866, 322.64926, -0.993759)
    PedSetActionNode(gPlayer, "/Global/C7/PlayerSit", "Act/Conv/C7.act")
    if nCurrentClass == 4 then
        F_PlaySpeechAndWait(galloway, "ENGLISH", 7, "large")
        if GetLanguage() == 7 then
            Wait(2000)
        end
    end
    if nCurrentClass == 1 then
        F_PlaySpeechAndWait(galloway, "ENGLISH", 3, "large")
        if GetLanguage() == 7 then
            Wait(1462)
        end
    end
    Wait(1838)
    CameraFade(500, 0)
    Wait(600)
    F_CleanPrefect()
    CameraFade(0, 1)
end

function F_SetStage(param)
    nCurrentClass = param
    bStageLoaded = true
    --print("[JASON]======> nCurrentClass = " .. nCurrentClass)
end

function F_SetStageRepeatable(param)
    nCurrentClass = param
    bStageLoaded = true
    bIsRepeatable = true
    --print("[JASON]======> nCurrentClass = " .. nCurrentClass)
end

function F_ChangeMusic()
    --print("CHANGING MUSIC")
    SoundPlay2D("TimeTransition")
    SoundLoopPlay2D("TimeWarningLOOP", true)
    gStartedLoop = GetTimer()
end

function F_EndCinematic()
    local cinematicActive = false
    local flirtEvent = "PLAYER_FLIRT_POOR"
    local victoryAnim = "/Global/C7/PlayerVictory/"
    local unlockText = false
    local unlockMissionText = false
    if nCurrentClass == 1 then
        unlockText = "ENG_TUT1"
        unlockMissionText = "MGCE_UNLOCK1"
        cinematicActive = 1
    elseif nCurrentClass == 2 then
        unlockText = "ENG_TUT2"
        unlockMissionText = "MGCE_UNLOCK2"
        cinematicActive = 2
        victoryAnim = "/Global/C7/PlayerVictory/Unlocks/SuccessMed1"
    elseif nCurrentClass == 3 then
        unlockText = "ENG_TUT3"
        unlockMissionText = "MGCE_UNLOCK3"
        flirtEvent = "PLAYER_FLIRT_GOOD"
        cinematicActive = 3
        victoryAnim = "/Global/C7/PlayerVictory/Unlocks/SuccessHi2"
    elseif nCurrentClass == 4 then
        unlockText = "ENG_TUT4"
        unlockMissionText = "MGCE_UNLOCK4"
        flirtEvent = "PLAYER_FLIRT_GOOD"
        cinematicActive = 4
        victoryAnim = "/Global/C7/PlayerVictory/Unlocks/SuccessHi1"
    elseif nCurrentClass == 5 then
        unlockMissionText = "MGCE_UNLOCK5"
        unlockText = "ENG_TUT5"
        cinematicActive = 5
        flirtEvent = "PLAYER_FLIRT_GOOD"
        victoryAnim = "/Global/C7/PlayerVictory/Unlocks/SuccessHi3"
    end
    if cinematicActive then
        CameraFade(-1, 0)
        Wait(FADE_OUT_TIME + 1000)
        PlayerSetControl(0)
        RestoredVisibility = true
        transitioned = true
        AreaTransitionPoint(2, POINTLIST._C7_PEND, nil, true)
        NonMissionPedGenerationDisable()
        HUDRestoreVisibility()
        PlayerWeaponHudLock(false)
        CameraAllowChange(true)
        PedSetWeaponNow(gPlayer, -1, 0)
        SoundEnableSpeech_ActionTree()
        CameraSetWidescreen(true)
        F_ScenePlay(nCurrentClass, unlockText, unlockMissionText)
        Wait(1000)
        SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "speech")
        PedSetActionNode(gPlayer, victoryAnim, "Act/Conv/C7.act")
        Wait(2000)
        NonMissionPedGenerationEnable()
        TutorialRemoveMessage()
        CameraSetWidescreen(false)
        PedLockTarget(gPlayer, -1)
    end
end

function F_ScenePlay(sceneNo, unlockText, unlockMissionText)
    PedSetFlag(gPlayer, 128, true)
    if sceneNo == 1 then
        CameraSetXYZ(-651.0539, -293.17877, 1.53899, -650.8692, -294.1503, 1.3909)
        CameraAllowChange(false)
        local insultBoy = PedCreatePoint(75, POINTLIST._C7_UNLOCKPED, 3)
        DisablePOI(true, true)
        NonMissionPedGenerationDisable()
        CameraFade(-1, 1)
        TutorialShowMessage("MGCE_TUTORIAL01", -1, true)
        Wait(4500)
        TutorialRemoveMessage()
        Wait(500)
        PedSetPedToTypeAttitude(insultBoy, 13, 1)
        PedSetWantsToSocializeWithPed(insultBoy, gPlayer, false, 0)
        F_Socialize(insultBoy, false, true)
        PedLockTarget(gPlayer, insultBoy)
        CameraSetWidescreen(false)
        PlayerSetControl(1)
        PlayerLockButtonInputsExcept(true, 10, 7)
        TutorialShowMessage("MGCE_TUTORIAL02", -1, true)
        while not PedMePlaying(gPlayer, "Social_Actions", true) do
            PedSocialKeepAlive(insultBoy)
            Wait(0)
        end
        PedLockTarget(gPlayer, -1)
        Wait(1250)
        PedLockTarget(insultBoy, gPlayer, 3)
        PedStopSocializing(insultBoy)
        PedSetActionNode(insultBoy, "/Global/Ambient/SocialAnims/SocialAcceptApology/Bully/GiveUp", "Act/Anim/Ambient.act")
        Wait(500)
        while not PedIsPlaying(insultBoy, "/Global/Ambient/SocialAnims/SocialAcceptApology", true) do
            Wait(0)
        end
        SoundPlayScriptedSpeechEvent(insultBoy, "LAUGH_CRUEL", -1, "jumbo", true)
        while PedIsPlaying(insultBoy, "/Global/Ambient/SocialAnims/SocialAcceptApology", true) do
            Wait(0)
        end
        PedLockTarget(insultBoy, -1)
        TutorialRemoveMessage()
        PlayerSetControl(0)
        PedMakeAmbient(insultBoy)
        PedWander(insultBoy, 0)
        PedSetPedToTypeAttitude(insultBoy, 13, 3)
        Wait(1500)
        CameraAllowChange(true)
        CameraSetWidescreen(true)
        F_PedSetCameraOffsetXYZ(gPlayer, 0.474976, 1.566317, 1.606372, 0.164124, 0.642633, 1.38351)
        PlayerLockButtonInputsExcept(false)
        PlayerSetControl(0)
        EnablePOI(true, true)
        MinigameSetCompletion("MEN_BLANK", true, 0, unlockMissionText)
        if unlockText then
            Wait(1000)
            TutorialShowMessage(unlockText, -1, true)
        end
        NonMissionPedGenerationEnable()
        PedClearObjectives(gPlayer)
        PedStop(gPlayer)
    elseif sceneNo == 2 then
        CameraSetXYZ(-652.17017, -294.01434, 1.674368, -651.4868, -294.70288, 1.431949)
        CameraAllowChange(false)
        local insultBoy = PedCreatePoint(70, POINTLIST._C7_UNLOCKPED, 3)
        DisablePOI(true, true)
        NonMissionPedGenerationDisable()
        CameraFade(-1, 1)
        TutorialShowMessage("MGCE_TAUNT01", -1, true)
        Wait(4500)
        TutorialRemoveMessage()
        Wait(500)
        PedSetPedToTypeAttitude(insultBoy, 13, 1)
        SoundStopCurrentSpeechEvent(insultBoy)
        PedSetWantsToSocializeWithPed(insultBoy, gPlayer, false, 1)
        F_Socialize(insultBoy, true, false)
        CameraSetWidescreen(false)
        PlayerSetControl(1)
        PlayerLockButtonInputsExcept(true, 10, 8)
        PedLockTarget(gPlayer, insultBoy)
        TutorialShowMessage("MGCE_TAUNT02", -1, true)
        while not PedMePlaying(gPlayer, "Social_Actions", true) do
            PedSocialKeepAlive(insultBoy)
            Wait(0)
        end
        PedLockTarget(gPlayer, -1)
        Wait(1250)
        TutorialRemoveMessage()
        Wait(500)
        PedSetWantsToSocializeWithPed(insultBoy, gPlayer, true, 19)
        SoundPlayScriptedSpeechEvent(insultBoy, "SCARED", 0, "large")
        PedMoveToXYZ(insultBoy, 1, -661.74115, -295.48602, -0.0036995336)
        PlayerSetControl(0)
        PedMakeAmbient(insultBoy)
        PedSetPedToTypeAttitude(insultBoy, 13, 3)
        Wait(1500)
        CameraAllowChange(true)
        CameraSetWidescreen(true)
        F_PedSetCameraOffsetXYZ(gPlayer, 0.474976, 1.566317, 1.606372, 0.164124, 0.642633, 1.38351)
        if PedIsValid(insultBoy) then
            PedDelete(insultBoy)
        end
        PlayerLockButtonInputsExcept(false)
        PlayerSetControl(0)
        MinigameSetCompletion("MEN_BLANK", true, 0, unlockMissionText)
        if unlockText then
            Wait(1000)
            TutorialShowMessage(unlockText, -1, true)
        end
        NonMissionPedGenerationEnable()
        EnablePOI(true, true)
        PedClearObjectives(gPlayer)
        PedStop(gPlayer)
    elseif sceneNo == 3 then
        CameraSetXYZ(-647.9221, -296.62323, 2.100897, -648.82574, -296.44977, 1.709499)
        CameraAllowChange(false)
        local insultBoy = PedCreatePoint(70, POINTLIST._C7_UNLOCKPED, 3)
        local prefect = PedCreatePoint(50, POINTLIST._C7_LASTPREFECT)
        PedFaceObject(gPlayer, insultBoy, 2, 0)
        DisablePOI(true, true)
        NonMissionPedGenerationDisable()
        CameraFade(-1, 1)
        TutorialShowMessage("MGCE_PREFAPOL01", -1, true)
        Wait(4500)
        TutorialRemoveMessage()
        Wait(500)
        PedSetPedToTypeAttitude(insultBoy, 13, 1)
        PedSetWantsToSocializeWithPed(insultBoy, gPlayer, false, 1)
        F_Socialize(insultBoy, true, false)
        CameraSetWidescreen(false)
        PlayerSetControl(1)
        PlayerLockButtonInputsExcept(true, 10, 8)
        PedSetStationary(insultBoy, true)
        TutorialShowMessage("MGCE_PREFAPOL02", -1, true)
        PedLockTarget(gPlayer, insultBoy)
        while not PedMePlaying(gPlayer, "Social_Actions", true) do
            PedSocialKeepAlive(insultBoy)
            Wait(0)
        end
        Wait(1250)
        PedLockTarget(gPlayer, -1)
        PedSetStationary(insultBoy, false)
        PedSetWantsToSocializeWithPed(insultBoy, gPlayer, true, 12)
        Wait(500)
        PlayerSetPunishmentPoints(95)
        --print("SETTING MIN POINTS 95")
        PlayerSetMinPunishmentPoints(95)
        TutorialRemoveMessage()
        PedSetPedToTypeAttitude(insultBoy, 13, 3)
        PedStop(insultBoy)
        PedClearObjectives(insultBoy)
        PedFollowPath(insultBoy, PATH._C7_SCENE3, 0, 1)
        TutorialRemoveMessage()
        PlayerSetControl(0)
        Wait(1500)
        CameraAllowChange(true)
        CameraSetXYZ(-648.7729, -292.54712, 2.157269, -648.8505, -293.49347, 1.843951)
        CameraAllowChange(false)
        if PedIsValid(insultBoy) then
            PedDelete(insultBoy)
        end
        PedFaceObject(gPlayer, prefect, 2, 1)
        PedSetStationary(prefect, true)
        PlayerSetControl(1)
        PlayerLockButtonInputsExcept(true, 10, 7)
        TutorialShowMessage("MGCE_TUTORIAL02", -1, true)
        PedSetWantsToSocializeWithPed(prefect, gPlayer, false, 13)
        PedLockTarget(gPlayer, prefect)
        F_Socialize(prefect, false, true)
        while not PedMePlaying(gPlayer, "Social_Combat_X", true) do
            PedSocialKeepAlive(prefect)
            if PedMePlaying(gPlayer, "Social_Actions", true) then
                break
            end
            Wait(0)
        end
        StatAddToInt(133, 1)
        PedLockTarget(gPlayer, -1)
        PlayerSetPunishmentPoints(0)
        PlayerSetMinPunishmentPoints(0)
        TutorialRemoveMessage()
        PlayerSetControl(0)
        PedSetStationary(prefect, false)
        PedSetWantsToSocializeWithPed(prefect, gPlayer, true, 23)
        Wait(2000)
        PedMakeAmbient(prefect)
        Wait(1500)
        CameraAllowChange(true)
        CameraSetXYZ(-648.85376, -297.31168, 1.102631, -649.339, -296.43933, 1.04434)
        CameraSetWidescreen(true)
        PlayerLockButtonInputsExcept(false)
        MinigameSetCompletion("MEN_BLANK", true, 0, unlockMissionText)
        if unlockText then
            Wait(1000)
            TutorialShowMessage(unlockText, -1, true)
        end
        EnablePOI(true, true)
        PedClearObjectives(gPlayer)
        PedStop(gPlayer)
        NonMissionPedGenerationEnable()
    elseif sceneNo == 4 then
        CameraSetXYZ(-651.68164, -293.61465, 1.767969, -651.2293, -294.47018, 1.516313)
        CameraAllowChange(false)
        local insultBoy = PedCreatePoint(70, POINTLIST._C7_UNLOCKPED, 5)
        DisablePOI(true, true)
        NonMissionPedGenerationDisable()
        CameraFade(-1, 1)
        TutorialShowMessage("MGCE_ENG0401", -1, true)
        Wait(4500)
        TutorialRemoveMessage()
        PedSetPedToTypeAttitude(insultBoy, 13, 1)
        F_Socialize(insultBoy, true, false)
        CameraSetWidescreen(false)
        PedSetFlag(gPlayer, 128, true)
        PedFaceObject(insultBoy, gPlayer, 3, 1, true)
        PedFaceObject(gPlayer, insultBoy, 2, 1, true)
        Wait(1000)
        PedSetWantsToSocializeWithPed(insultBoy, gPlayer, false, 1)
        PlayerSetControl(1)
        PlayerLockButtonInputsExcept(true, 10, 8)
        TutorialShowMessage("MGCE_ENG0402", -1, true)
        PedLockTarget(gPlayer, insultBoy)
        while not PedMePlaying(gPlayer, "Social_Actions", true) do
            PedSocialKeepAlive(insultBoy)
            Wait(0)
        end
        PedLockTarget(gPlayer, -1)
        PlayerSetControl(0)
        Wait(1250)
        PedSetStationary(insultBoy, false)
        PedSetWantsToSocializeWithPed(insultBoy, gPlayer, true, 19)
        Wait(500)
        TutorialRemoveMessage()
        PedMakeAmbient(insultBoy)
        PedSetPedToTypeAttitude(insultBoy, 13, 3)
        Wait(1500)
        CameraAllowChange(true)
        CameraSetXYZ(-651.83435, -296.39398, 1.519369, -650.8957, -296.09137, 1.35474)
        CameraSetWidescreen(true)
        PlayerLockButtonInputsExcept(false)
        PlayerSetControl(0)
        MinigameSetCompletion("MEN_BLANK", true, 0, unlockMissionText)
        if unlockText then
            Wait(1000)
            TutorialShowMessage(unlockText, -1, true)
        end
        EnablePOI(true, true)
        PedClearObjectives(gPlayer)
        PedSetFlag(gPlayer, 128, false)
        PedStop(gPlayer)
        NonMissionPedGenerationEnable()
    elseif sceneNo == 5 then
        CameraSetXYZ(-650.1485, -298.40274, 1.099456, -650.15735, -297.40286, 1.093695)
        CameraFade(-1, 1)
        MinigameSetCompletion("MEN_BLANK", true, 0, unlockMissionText)
        if unlockText then
            Wait(1000)
            TutorialShowMessage(unlockText, -1, true)
        end
        Wait(2000)
    end
end

function F_CheckIfPrefect()
    if shared.bBustedClassLaunched then
        local prefectModels = {
            49,
            50,
            51,
            52
        }
        local prefectModel = prefectModels[math.random(1, 4)]
        LoadModels({ prefectModel })
        prefect = PedCreatePoint(prefectModel, POINTLIST._PREFECTLOC)
        PedStop(prefect)
        PedClearObjectives(prefect)
        PedIgnoreStimuli(prefect, true)
        PedFaceObject(gPlayer, prefect, 2, 0)
        PedFaceObject(prefect, gPlayer, 3, 1, false)
        PedSetInvulnerable(prefect, true)
        PedSetPedToTypeAttitude(prefect, 3, 2)
        CameraSetXYZ(-562.8464, 317.35223, -0.673942, -563.56836, 316.66055, -0.686741)
        CameraFade(-1, 1)
        SoundPlayScriptedSpeechEvent(prefect, "BUSTED_CLASS", 0, "speech")
        PedSetActionNode(prefect, "/Global/Ambient/MissionSpec/Prefect/PrefectChew", "Act/Anim/Ambient.act")
        PedSetActionNode(gPlayer, "/Global/C7/PlayerFail", "Act/Conv/C7.act")
        Wait(3000)
        PedSetActionNode(gPlayer, "/Global/C7/Release", "Act/Conv/C7.act")
        shared.bBustedClassLaunched = false
        return true
    end
    return false
end

function F_CleanPrefect()
    if prefect and PedIsValid(prefect) then
        PedDelete(prefect)
    end
end

function F_Socialize(pedId, bDisableX, bDisableO)
    PlayerSocialDisableActionAgainstPed(pedId, 23, bDisableX)
    PlayerSocialDisableActionAgainstPed(pedId, 24, bDisableX)
    PlayerSocialDisableActionAgainstPed(pedId, 25, bDisableX)
    PlayerSocialDisableActionAgainstPed(pedId, 26, bDisableX)
    PlayerSocialDisableActionAgainstPed(pedId, 32, bDisableX)
    PlayerSocialDisableActionAgainstPed(pedId, 35, bDisableX)
    PlayerSocialDisableActionAgainstPed(pedId, 28, bDisableO)
    PlayerSocialDisableActionAgainstPed(pedId, 29, bDisableO)
    PlayerSocialDisableActionAgainstPed(pedId, 30, bDisableO)
    PlayerSocialDisableActionAgainstPed(pedId, 33, bDisableO)
    PlayerSocialDisableActionAgainstPed(pedId, 36, bDisableO)
    PlayerSocialDisableActionAgainstPed(pedId, 34, bDisableO)
    PlayerSocialDisableActionAgainstPed(pedId, 31, bDisableO)
end
