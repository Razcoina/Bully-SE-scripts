--[[ Changes to this file:
    * Modified function MissionCleanup, may require testing
    * Modified function main, may require testing
    * Modified function F_IntroCinematic, may require testing
    * Modified function F_EndCinematic, may require testing
]]

local missionSuccess = false
local nCurrentWordScore = 0
local nCurrentScore = 0
local nCurrentClass
local bStageLoaded = false
local tblClasses = {
    {
        timer = 175,
        percent = 0.75,
        grade = 1
    },
    {
        timer = 170,
        percent = 1,
        grade = 2
    },
    {
        timer = 165,
        percent = 1,
        grade = 3
    },
    {
        timer = 160,
        percent = 1,
        grade = 4
    },
    {
        timer = 155,
        percent = 1,
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
    MinigameCreate("GEOGRAPHY", false)
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

function MissionCleanup() -- ! Modified
    --[[
    AreaLoadSpecialEntities("geography", false)
    ]] -- Removed this
    HUDRestoreVisibility()
    PlayerWeaponHudLock(false)
    --print("1aaaaaaaaaaaaaaa")
    SoundRestartPA()
    SoundEnableInteractiveMusic(true)
    --print("2aaaaaaaaaaaaaaa")
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    SoundFadeoutStream()
    --print("3aaaaaaaaaaaaaaa")
    PedSetActionNode(gPlayer, "/Global/C7/Release", "Act/Conv/C7.act")
    MinigameDestroy()
    SoundStopStream()
    SoundEnableSpeech_ActionTree()
    --print("4aaaaaaaaaaaaaaa")
    UnLoadAnimationGroup("NPC_Adult")
    UnLoadAnimationGroup("UBO")
    --print("5aaaaaaaaaaaaaaa")
    UnLoadAnimationGroup("MINI_React")
    UnLoadAnimationGroup("ENGLISHCLASS")
    UnLoadAnimationGroup("SBULL_X")
    --print("6aaaaaaaaaaaaaaa")
    if not transitioned then
        --[[
        AreaTransitionPoint(2, POINTLIST._C7_PEND)
        ]] -- Changed to:
        AreaTransitionPoint(2, POINTLIST._C7_GEO_PEND)
    end
    --print("7aaaaaaaaaaaaaaa")
    PedClearObjectives(gPlayer)
    PedStop(gPlayer)
    PlayerSetPunishmentPoints(0)
    --print("8aaaaaaaaaaaaaaa")
    F_MakePlayerSafeForNIS(false)
    if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
        PlayerSetHealth(PedGetMaxHealth(gPlayer))
    end
    --print("9aaaaaaaaaaaaaaa")
    PedSetFlag(gPlayer, 128, false)
    PlayerSetControl(1)
    DATUnload(2)
end

function main() -- ! Modified
    while not bStageLoaded do
        Wait(0)
        --print("STUCK HERE")
    end
    --[[
    AreaLoadSpecialEntities("geography", true)
    AreaEnsureSpecialEntitiesAreCreated()
    ]] -- Removed this
    F_MakePlayerSafeForNIS(true)
    PlayerWeaponHudLock(true)
    VehicleOverrideAmbient(0, 0, 0, 0)
    AreaClearAllPeds()
    PlayerSetControl(0)
    LoadActionTree("Act/Conv/C7.act")
    LoadAnimationGroup("NPC_Adult")
    LoadAnimationGroup("MINI_React")
    LoadAnimationGroup("UBO")
    LoadAnimationGroup("ENGLISHCLASS")
    LoadAnimationGroup("SBULL_X")
    F_IntroCinematic()
    ClassGeographySetLevel(nCurrentClass)
    MinigameStart()
    --[[
    SoundPlayStream("MS_GeographyClass.rsm", 1, 0, 0)
    ]] -- Changed to:
    SoundPlayStream("MS_GeographyClass.rsm", 0.15, 0, 0)
    F_InitRules()
    CameraSetWidescreen(false)
    MinigameEnableHUD(true)
    Wait(1000)
    CameraSetFOV(30)
    CameraSetXYZ(-561.0058, 321.40848, -0.828353, -560.6053, 322.3187, -0.724545)
    while MinigameIsActive() do
        Wait(100)
        if gStartedLoop and GetTimer() - gStartedLoop > 13000 then
            SoundLoopPlay2D("TimeWarningLOOP", false)
        end
        if ClassGeographyInvalidOperation() then
            SoundPlayScriptedSpeechEvent(teacher, "ClassGeography", 12, "large", true)
        end
        F_CheckRules()
    end
    CameraSetWidescreen(true)
    MinigameEnableHUD(false)
    PedFaceObject(gPlayer, teacher, 2, 0)
    if missionSuccess then
        PedSetActionNode(gPlayer, "/Global/C7/PlayerVictory/PlayerVictory03", "Act/Conv/C7.act")
        if nCurrentClass == 5 then
            SoundPlayScriptedSpeechEvent(teacher, "ClassGeography", 6, "large", true)
        else
            SoundPlayScriptedSpeechEvent(teacher, "ClassGeography", nCurrentClass + 5, "large", true)
        end
    else
        SoundPlayScriptedSpeechEvent(teacher, "ClassGeography", 11, "large", true)
        PedSetActionNode(gPlayer, "/Global/C7/PlayerFail", "Act/Conv/C7.act")
        PedSetActionNode(teacher, "/Global/C7/TeacherDisgust", "Act/Conv/C7.act")
    end
    SoundLoopPlay2D("TimeWarningLOOP", false)
    if missionSuccess and not bIsRepeatable then
        PlayerSetGrade(5, tblClasses[nCurrentClass].grade)
    end
    if not bIsRepeatable then
        if 0 < tblClasses[nCurrentClass].grade then
            MinigameSetGrades(5, tblClasses[nCurrentClass].grade - 1)
        else
            MinigameSetGrades(5, tblClasses[nCurrentClass].grade)
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
            SoundStopCurrentSpeechEvent(teacher)
            PedStop(teacher)
            PedClearObjectives(teacher)
            PedFaceHeading(teacher, 0, 0)
            CameraFade(500, 1)
            Wait(500)
            SoundPlayScriptedSpeechEvent(teacher, "ClassGeography", 10, "large", true)
            Wait(6500)
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
    if tblClasses[nCurrentClass].timer then
        if tblClasses[nCurrentClass].taxicab then
            ClassGeographySetTimer(tblClasses[nCurrentClass].timer, tblClasses[nCurrentClass].taxicab)
        else
            ClassGeographySetTimer(tblClasses[nCurrentClass].timer, 0)
        end
    end
    if tblClasses[nCurrentClass].percent then
        ClassGeographySetScorePercentage(tblClasses[nCurrentClass].percent)
    end
end

function F_CheckRules()
    if MinigameIsSuccess() then
        missionSuccess = true
    end
end

function F_CalcTime()
    --print("[RJW] CalcTime******************************* ")
    --print("[RJW] CalcTime******************************* ")
    --print("[RJW] CalcTime******************************* ")
    --print("[RJW] CalcTime******************************* ")
    --print("[RJW] CalcTime******************************* ")
    --print("[RJW] CalcTime******************************* ")
    --print("[RJW] CalcTime******************************* ")
    --print("[RJW] CalcTime******************************* ")
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

function F_IntroCinematic() -- ! Modified
    PedSetPosPoint(gPlayer, POINTLIST._C7_PSTART, 1)
    teacher = PedCreatePoint(248, POINTLIST._C7_GALLOWAY)
    student1 = PedCreatePoint(3, POINTLIST._C7_STUDENTS, 1)
    student2 = PedCreatePoint(35, POINTLIST._C7_STUDENTS, 2)
    student3 = PedCreatePoint(66, POINTLIST._C7_STUDENTS, 3)
    Wait(1500)
    --[[
    PedFaceHeading(teacher, 0, 0)
    ]] -- Removed this
    GeometryInstance("kidchair", true, -560.141, 322.159, -1.48522, false)
    PedIgnoreStimuli(teacher, true)
    PedIgnoreStimuli(student1, true)
    PedIgnoreStimuli(student2, true)
    PedIgnoreStimuli(student3, true)
    PedSetAsleep(teacher, true)
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
    SoundPlayScriptedSpeechEvent(teacher, "ClassGeography", nCurrentClass, "large", true)
    --[[
    Wait(7500)
    ]] -- Changed to:
    Wait(7000)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedSetPosPoint(gPlayer, POINTLIST._C7_PLAYERSIT, 1)
    Wait(1000)
    CameraSetFOV(40)
    CameraSetXYZ(-560.63806, 321.6818, -1.018964, -560.3866, 322.64926, -0.993759)
    PedSetActionNode(gPlayer, "/Global/C7/PlayerSit", "Act/Conv/C7.act")
    CameraFade(500, 0)
    Wait(600)
    F_CleanPrefect()
    CameraFade(0, 1)
end

function F_SetStage(param)
    nCurrentClass = param
    bStageLoaded = true
    --print("[SCOTT]======> nCurrentClass = " .. nCurrentClass)
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

function F_EndCinematic() -- ! Modified
    local victoryAnim
    if nCurrentClass == 1 then
        ClothingGivePlayer("SP_EiffelHat", 0)
        victoryAnim = "/Global/C7/PlayerVictory/"
        unlockText = "MGGE_Unlock01"
    elseif nCurrentClass == 2 then
        --[[
        ClothingGivePlayerOutfit("Nascar", true, true)
        ]] -- Changed to:
        ClothingGivePlayer("SP_Nascar_H", 0)
        victoryAnim = "/Global/C7/PlayerVictory/Unlocks/SuccessMed1"
        unlockText = "MGGE_Unlock02"
        CollectibleOnMapEnable(2, true)
    elseif nCurrentClass == 3 then
        --[[
        ClothingGivePlayerOutfit("Panda", true, true)
        ]] -- Changed to:
        ClothingGivePlayer("SP_Panda_H", 0)
        victoryAnim = "/Global/C7/PlayerVictory/Unlocks/SuccessHi2"
        unlockText = "MGGE_Unlock03"
        CollectibleOnMapEnable(3, true)
    elseif nCurrentClass == 4 then
        ClothingGivePlayer("SP_PithHelmet", 0)
        victoryAnim = "/Global/C7/PlayerVictory/Unlocks/SuccessHi1"
        unlockText = "MGGE_Unlock04"
        CollectibleOnMapEnable(1, true)
    elseif nCurrentClass == 5 then
        ClothingGivePlayerOutfit("Columbus", true, true)
        victoryAnim = "/Global/C7/PlayerVictory/Unlocks/SuccessHi3"
        unlockText = "MGGE_Unlock05"
        unlockTextRoom = "MGGE_Unlock06"
        CollectibleOnMapEnable(0, true)
    end
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME + 1000)
    PlayerSetControl(0)
    --[[
    AreaTransitionPoint(2, POINTLIST._C7_PEND, nil, true)
    ]] -- Changed to:
    AreaTransitionPoint(2, POINTLIST._C7_GEO_PEND, nil, true)
    NonMissionPedGenerationDisable()
    HUDRestoreVisibility()
    PlayerWeaponHudLock(false)
    CameraAllowChange(true)
    PedSetWeaponNow(gPlayer, -1, 0)
    SoundEnableSpeech_ActionTree()
    CameraSetWidescreen(true)
    while not AreaGetVisible() == 2 do
        Wait(0)
    end
    transitioned = true
    CameraFade(1000, 1)
    Wait(1000)
    MinigameSetCompletion("MEN_BLANK", true, 0, unlockText)
    SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "speech")
    PedSetActionNode(gPlayer, victoryAnim, "Act/Conv/C7.act")
    if unlockTextRoom then
        TutorialShowMessage(unlockTextRoom, -1, true)
        Wait(3000)
    end
    while PedIsPlaying(gPlayer, victoryAnim, true) do
        Wait(0)
    end
    NonMissionPedGenerationEnable()
    TutorialRemoveMessage()
    CameraSetWidescreen(false)
    PedLockTarget(gPlayer, -1)
end

function F_ScenePlay(sceneNo, unlockText, unlockMissionText)
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
