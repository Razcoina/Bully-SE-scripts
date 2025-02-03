local gStageLoaded = false
local missionSuccess = false
local gStudents = {}
local gClassNo = 1
local gKissingGirlModels = {
    74,
    39,
    67,
    181,
    63
}
local gEnemyEnum = {
    0,
    1,
    2,
    3,
    4,
    5,
    6
}
local gPowerupEnum = {
    0,
    1,
    2,
    3
}
local gClassSettings = {
    completion = 90,
    playerSpeed = 0.1666,
    pathSpeedup = 1.5,
    enemySpeed = {
        0.09,
        0.13,
        0.2,
        0.13,
        0.2,
        0.2,
        0.2
    },
    enemyPeriod = {
        15,
        0,
        0,
        15,
        0,
        0,
        0
    },
    enemyInitialPeriod = {
        10,
        0,
        0,
        15,
        0,
        0,
        0
    },
    enemyInstanceMax = {
        1,
        0,
        0,
        1,
        0,
        0,
        0
    },
    exploderTimeout = 30,
    exploderDebrisCount = 16,
    exploderDebrisSpeed = 0.3,
    powerupSpeed = {
        0.05,
        0.05,
        0.05,
        0.05
    },
    powerupPeriod = {
        50,
        0,
        50,
        50
    },
    powerupInitialPeriod = {
        40,
        0,
        0,
        0
    },
    powerupDuration = {
        10,
        10,
        10,
        10
    },
    powerupSpeedFactor = 1.5,
    powerupClearRadius = 0.25,
    levelTimeout = 90,
    currentBackground = 0,
    maxEnemies = 5,
    lives = 3
}

function F_SetupMinigame()
    --print(" >>>> EXECUTING ALL THE LUA COMMANDS ")
    MGCA_SetCompletionThreshold(gClassSettings.completion)
    MGCA_SetPlayerSpeed(gClassSettings.playerSpeed)
    MGCA_SetPathSpeedupFactor(gClassSettings.pathSpeedup)
    MGCA_SetEnemyTotalMax(gClassSettings.maxEnemies)
    for i, enemy in gEnemyEnum do
        --print("Setting up enemy:", i)
        MGCA_SetEnemySpeed(i - 1, gClassSettings.enemySpeed[i])
        MGCA_SetEnemyPeriod(i - 1, gClassSettings.enemyPeriod[i])
        MGCA_SetEnemyInitialPeriod(i - 1, gClassSettings.enemyInitialPeriod[i])
        MGCA_SetEnemyInstanceMax(i - 1, gClassSettings.enemyInstanceMax[i])
    end
    MGCA_SetExploderTimeOut(gClassSettings.exploderTimeout)
    MGCA_SetExploderDebrisCount(gClassSettings.exploderDebrisCount)
    MGCA_SetExploderDebrisSpeed(gClassSettings.exploderDebrisSpeed)
    for i, powerup in gPowerupEnum do
        --print("Setting up powerup:", i)
        MGCA_SetPowerUpSpeed(i - 1, gClassSettings.powerupSpeed[i])
        MGCA_SetPowerUpPeriod(i - 1, gClassSettings.powerupPeriod[i])
        MGCA_SetPowerUpDuration(i - 1, gClassSettings.powerupDuration[i])
        MGCA_SetPowerUpInitialPeriod(i - 1, gClassSettings.powerupInitialPeriod[i])
    end
    if gClassSettings.initialEnemies then
        for i, iEnemy in gClassSettings.initialEnemies do
            --print("Preinstancing enemies", i)
            MGCA_PreInstanceEnemy(iEnemy.eType, iEnemy.x, iEnemy.y, iEnemy.direction)
        end
    end
    MGCA_SetPowerUpFreezeFactor(0.5)
    MGCA_SetPowerUpSpeedBoostFactor(gClassSettings.powerupSpeedFactor)
    MGCA_SetSetPowerUpClearRadius(gClassSettings.powerupClearRadius)
    MGCA_SetLevelTimeout(gClassSettings.levelTimeout)
    MGCA_SetLives(gClassSettings.lives)
    MGCA_SetTextureBank(gClassSettings.currentBackground)
    --print(" >>>> FINISHED EXECUTING ALL THE LUA COMMANDS ")
end

function F_SetupClass(classStage)
    --print("CLASS STAGE: ", classStage)
    if classStage == 0 or classStage == 1 then
        if classStage == 1 then
            bIsRepeatable = true
        end
        gGrade = 1
        gTeacherSpeech = 1
        gClassSettings.maxEnemies = 3
        gClassSettings.completion = 80
        gClassSettings.currentBackground = 0
        gClassSettings.initialEnemies = {
            {
                eType = 0,
                x = 0,
                y = 25,
                direction = 0
            },
            {
                eType = 3,
                x = 0.35,
                y = 0.85,
                direction = 3
            }
        }
        gClassSettings.powerupPeriod = {
            50,
            0,
            50,
            50
        }
        gClassSettings.powerupInitialPeriod = {
            10,
            0,
            0,
            0
        }
    elseif classStage == 2 or classStage == 3 then
        gPlayerExtraHealth = PedGetMaxHealth(gPlayer) / 2
        if classStage == 3 then
            bIsRepeatable = true
        end
        gGrade = 2
        gTeacherSpeech = 6
        gClassSettings.completion = 80
        gClassSettings.currentBackground = 1
        gClassSettings.maxEnemies = 4
        gClassSettings.enemyPeriod = {
            30,
            0,
            0,
            30,
            0,
            0,
            40
        }
        gClassSettings.enemyInstanceMax = {
            1,
            0,
            0,
            2,
            0,
            0,
            0
        }
        gClassSettings.enemySpeed = {
            0.13,
            0.18,
            0.2,
            0.13,
            0.22,
            0.2,
            0.2
        }
        gClassSettings.initialEnemies = {
            {
                eType = 0,
                x = 0,
                y = 25,
                direction = 0
            },
            {
                eType = 3,
                x = 0.55,
                y = 0.85,
                direction = 1
            },
            {
                eType = 3,
                x = 0.8,
                y = 0.35,
                direction = 3
            }
        }
        gClassSettings.powerupInitialPeriod = {
            30,
            0,
            10,
            0
        }
    elseif classStage == 4 or classStage == 5 then
        gPlayerExtraHealth = PedGetMaxHealth(gPlayer) / 4 * 3
        if classStage == 5 then
            bIsRepeatable = true
        end
        gGrade = 3
        gTeacherSpeech = 7
        gClassSettings.completion = 80
        gClassSettings.currentBackground = 2
        gClassSettings.maxEnemies = 4
        gClassSettings.initialEnemies = {
            {
                eType = 0,
                x = 0,
                y = 25,
                direction = 0
            },
            {
                eType = 1,
                x = 50,
                y = 25,
                direction = 0
            },
            {
                eType = 3,
                x = 0.15,
                y = 0.35,
                direction = 1
            },
            {
                eType = 3,
                x = 0.85,
                y = 0.35,
                direction = 3
            }
        }
        gClassSettings.enemyInstanceMax = {
            1,
            1,
            0,
            2,
            0,
            0,
            0
        }
        gClassSettings.enemyPeriod = {
            30,
            0,
            0,
            30,
            25,
            0,
            30
        }
        gClassSettings.enemySpeed = {
            0.13,
            0.18,
            0.2,
            0.13,
            0.22,
            0.2,
            0.2
        }
        gClassSettings.powerupInitialPeriod = {
            40,
            0,
            20,
            10
        }
    elseif classStage == 6 or classStage == 7 then
        gPlayerExtraHealth = PedGetMaxHealth(gPlayer)
        if classStage == 7 then
            bIsRepeatable = true
        end
        gGrade = 4
        gTeacherSpeech = 8
        gClassSettings.completion = 80
        gClassSettings.currentBackground = 3
        gClassSettings.enemyPeriod = {
            30,
            0,
            0,
            25,
            25,
            0,
            25
        }
        gClassSettings.enemySpeed = {
            0.13,
            0.18,
            0.2,
            0.13,
            0.22,
            0.2,
            0.2
        }
        gClassSettings.initialEnemies = {
            {
                eType = 0,
                x = 0,
                y = 25,
                direction = 0
            },
            {
                eType = 0,
                x = 50,
                y = 25,
                direction = 0
            },
            {
                eType = 1,
                x = 25,
                y = 50,
                direction = 3
            },
            {
                eType = 3,
                x = 0.15,
                y = 0.35,
                direction = 1
            },
            {
                eType = 4,
                x = 0.85,
                y = 0.35,
                direction = 3
            }
        }
        gClassSettings.enemyInstanceMax = {
            2,
            1,
            0,
            2,
            1,
            0,
            0
        }
        gClassSettings.powerupInitialPeriod = {
            40,
            0,
            25,
            10
        }
        gClassSettings.maxEnemies = 5
    elseif classStage == 8 or classStage == 9 then
        gPlayerExtraHealth = PedGetMaxHealth(gPlayer)
        if classStage == 9 then
            bIsRepeatable = true
        end
        gGrade = 5
        gTeacherSpeech = 9
        gClassSettings.completion = 80
        gClassSettings.currentBackground = 4
        gClassSettings.enemyPeriod = {
            10,
            15,
            0,
            15,
            25,
            0,
            20
        }
        gClassSettings.enemySpeed = {
            0.13,
            0.18,
            0.2,
            0.13,
            0.22,
            0.2,
            0.2
        }
        gClassSettings.initialEnemies = {
            {
                eType = 0,
                x = 0,
                y = 25,
                direction = 0
            },
            {
                eType = 1,
                x = 25,
                y = 50,
                direction = 3
            },
            {
                eType = 4,
                x = 0.15,
                y = 0.35,
                direction = 1
            },
            {
                eType = 3,
                x = 0.45,
                y = 0.85,
                direction = 1
            },
            {
                eType = 6,
                x = 0.5,
                y = 0.5,
                direction = 3
            }
        }
        gClassSettings.enemyInstanceMax = {
            1,
            2,
            0,
            1,
            2,
            0,
            1
        }
        gClassSettings.powerupInitialPeriod = {
            30,
            0,
            25,
            15
        }
        gClassSettings.maxEnemies = 6
    end
    gStageLoaded = true
    gClassNo = classStage
end

function MissionSetup()
    MissionDontFadeIn()
    --print("Initiating MissionSetup")
    DATLoad("C2.DAT", 2)
    DATInit()
    SoundEnableInteractiveMusic(false)
    AreaTransitionPoint(17, POINTLIST._C2_PLAYER, nil, true)
    LoadActionTree("Act/Conv/C2.act")
    HUDSaveVisibility()
    HUDClearAllElements()
    ToggleHUDComponentVisibility(42, true)
    AreaClearAllPeds()
    SoundStopPA()
    SoundStopCurrentSpeechEvent()
end

function MissionCleanup()
    if not RestoredVisibility then
        HUDRestoreVisibility()
        PlayerWeaponHudLock(false)
    end
    SoundRestartPA()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    UnLoadAnimationGroup("MINI_React")
    if not gMinigameDestroyed then
        MinigameDestroy()
    end
    CameraReturnToPlayer(false)
    SoundEnableInteractiveMusic(true)
    SoundFadeoutStream()
    PedSetFlag(gPlayer, 128, false)
    PedLockTarget(gPlayer, -1)
    local setX, setY, setZ = GetPointList(POINTLIST._CLASS_ART)
    PlayerSetPunishmentPoints(0)
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
    SoundEnableSpeech_ActionTree()
    if not gTransitioned then
        AreaTransitionPoint(2, POINTLIST._C2_EXITCLASS)
    end
    DATUnload(2)
end

function F_CreateStudent(model, point)
    local student = PedCreatePoint(model, POINTLIST._C2_STUDENTS, point)
    PedSetPedToTypeAttitude(student, 13, 4)
    PedSetStationary(student, true)
    PedSetCheap(student, true)
    table.insert(gStudents, student)
end

function F_InitialCutscene()
    teacher = PedCreatePoint(63, POINTLIST._C2_TEACHER, 1)
    F_CreateStudent(3, 1)
    F_CreateStudent(14, 3)
    F_CreateStudent(72, 4)
    F_CreateStudent(24, 5)
    F_CreateStudent(66, 6)
    local x, y, z = -531.671, 382.957, 15.3596
    CameraSetWidescreen(true)
    SoundDisableSpeech_ActionTree()
    AreaClearAllPeds()
    if not F_CheckIfPrefect() then
        CameraFade(1000, 1)
    end
    PedFollowPath(gPlayer, PATH._C2_PLAYERPATH, 0, 0)
    PedSetActionNode(teacher, "/Global/C2_ArtClass/TeacherSpeaking", "Act/Conv/C2.act")
    CameraSetPath(PATH._C2_CAMERA, true)
    CameraLookAtXYZ(x, y, z, true)
    CameraSetSpeed(1.8, 1.8, 1.8)
    Wait(1005)
    SoundPlayScriptedSpeechEvent(teacher, "ART", gTeacherSpeech, "jumbo", true)
    Wait(7508)
    CameraFade(500, 0)
    Wait(500)
    F_CleanPrefect()
    PedSetActionNode(teacher, "/Global/C2_ArtClass/TeacherSpeaking", "Act/Conv/C2.act")
    CameraSetWidescreen(false)
    PedSetActionNode(teacher, "/Global/C2_ArtClass/TeacherSpeaking", "Act/Conv/C2.act")
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
end

function main()
    LoadAnimationGroup("MINI_React")
    MinigameCreate("ART", false)
    while MinigameIsReady() == false do
        Wait(0)
    end
    Wait(2)
    while not gStageLoaded do
        Wait(0)
    end
    AreaClearAllPeds()
    PlayerUnequip()
    while WeaponEquipped() do
        Wait(0)
    end
    PlayerWeaponHudLock(true)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    F_SetupMinigame()
    F_InitialCutscene()
    Wait(100)
    SoundPlayStream("MS_ArtClass.rsm", 0.2)
    MinigameStart()
    MinigameEnableHUD(true)
    Wait(100)
    CameraFade(500, 1)
    Wait(500)
    Wait(10)
    while MinigameIsActive() do
        Wait(0)
    end
    if MinigameIsSuccess() then
        missionSuccess = true
    end
    MinigameEnableHUD(false)
    MinigameEnd()
    gMinigameDestroyed = true
    CameraFade(500, 1)
    Wait(500)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    gLivesLeft = MGCA_GetLives()
    if missionSuccess then
        MinigameDestroy()
        SoundPlayScriptedSpeechEvent(teacher, "ART", 10, "large", true)
        PedSetActionNode(gPlayer, "/Global/C2_ArtClass/PlayerVictory/PlayerVictory01", "Act/Conv/C2.act")
    else
        local failureCode = MGCA_GetFailureCode()
        MinigameDestroy()
        --print("FAILURE CODE =", failureCode)
        SoundPlayScriptedSpeechEvent(teacher, "ART", 11, "jumbo", true)
        if failureCode == 1 then
            --print("FAILURE CODE =", failureCode)
        elseif failureCode == 2 then
            --print("FAILURE CODE =", failureCode)
        elseif failureCode == 3 then
            --print("FAILURE CODE =", failureCode)
        end
        PedSetActionNode(gPlayer, "/Global/C2_ArtClass/PlayerFail", "Act/Conv/C2.act")
    end
    if missionSuccess then
        if not bIsRepeatable then
            PlayerSetGrade(0, gGrade)
            SoundFadeoutStream()
            SoundPlayMissionEndMusic(true, 9)
            MinigameSetGrades(0, gGrade - 1)
            while MinigameIsShowingGrades() do
                Wait(0)
            end
            if gClassNo == 8 then
                CameraFade(500, 0)
                Wait(FADE_OUT_TIME)
                CameraLookAtXYZ(-528.04224, 385.786, 15.449584, true)
                CameraSetXYZ(-529.73364, 384.83725, 15.349741, -528.04224, 385.786, 15.449584)
                CameraFade(500, 1)
                Wait(500)
                F_PlaySpeechAndWait(teacher, "ART", 14, "jumbo")
            end
            F_EndCinematic()
        else
            CameraFade(-1, 0)
            Wait(FADE_OUT_TIME)
        end
        --print("LIVES LEFT vs. Total Lives:", gLivesLeft, gClassSettings.lives)
        MissionSucceed(false, false, false)
    else
        SoundFadeoutStream()
        SoundPlayMissionEndMusic(false, 9)
        if not bIsRepeatable then
            MinigameSetGrades(0, gGrade - 1)
            while MinigameIsShowingGrades() do
                Wait(0)
            end
        else
            Wait(3000)
        end
        MissionFail(true, false)
    end
end

function F_EndCinematic()
    local cinematicActive = false
    local flirtEvent = "PLAYER_FLIRT_DEFAULT"
    local victoryAnim = "/Global/C2_ArtClass/PlayerVictory/PlayerVictory01"
    local tutorialMessage = "MGCA_TUT1"
    local unlockText = "A1_UNLOCK1"
    if gClassNo == 0 then
        cinematicActive = 1
    elseif gClassNo == 2 then
        cinematicActive = 2
        tutorialMessage = "MGCA_TUT2"
        victoryAnim = "/Global/C2_ArtClass/PlayerVictory/Unlocks/SuccessMed1"
    elseif gClassNo == 4 then
        flirtEvent = "PLAYER_FLIRT_GOOD"
        cinematicActive = 3
        tutorialMessage = "MGCA_TUT3"
        victoryAnim = "/Global/C2_ArtClass/PlayerVictory/Unlocks/SuccessHi2"
    elseif gClassNo == 6 then
        flirtEvent = "PLAYER_FLIRT_GOOD"
        cinematicActive = 4
        tutorialMessage = "MGCA_TUT4"
        victoryAnim = "/Global/C2_ArtClass/PlayerVictory/Unlocks/SuccessHi1"
    elseif gClassNo == 8 then
        cinematicActive = 5
        flirtEvent = "PLAYER_FLIRT_GOOD"
        tutorialMessage = "MGCA_TUT5"
        victoryAnim = "/Global/C2_ArtClass/PlayerVictory/Unlocks/SuccessHi3"
    end
    CameraFade(-1, 0)
    Wait(FADE_OUT_TIME + 1000)
    if cinematicActive then
        RestoredVisibility = true
        AreaTransitionPoint(2, POINTLIST._C2_EXITCLASS, nil, true)
        gTransitioned = true
        AreaClearAllPeds()
        NonMissionPedGenerationDisable()
        HUDRestoreVisibility()
        PlayerWeaponHudLock(false)
        CameraAllowChange(true)
        SoundEnableSpeech_ActionTree()
        CameraSetWidescreen(true)
        local kissGirl = -1
        if gClassNo == 0 then
            CameraSetXYZ(-670.4946, -293.46982, 7.089344, -670.37573, -294.45618, 6.976038)
            CameraAllowChange(false)
            kissGirl = PedCreatePoint(39, POINTLIST._C2_GIRLSPAWN)
            F_Socialize(kissGirl, true)
            PedSetPedToTypeAttitude(kissGirl, 13, 4)
            PedSetRequiredGift(kissGirl, 2, false, true)
            PlayerSetControl(1)
            PlayerLockButtonInputsExcept(true, 10, 7)
            CameraFade(-1, 1)
            PedFollowPath(kissGirl, PATH._C2_GIRLPATH, 0, 0)
            TutorialShowMessage("MGCA_KISS01", -1, true)
            F_PlaySpeechAndWait(gPlayer, flirtEvent, 0, "speech")
            SoundPlayAmbientSpeechEvent(kissGirl, "GREET")
            PlayerLockButtonInputsExcept(true, 10)
            Wait(3000)
            CameraSetWidescreen(false)
            TutorialRemoveMessage()
            Wait(500)
            TutorialShowMessage("MGCA_KISS02", -1, true)
            PlayerLockButtonInputsExcept(true, 10, 7)
            PedSetFlag(gPlayer, 128, true)
            PedFaceObject(kissGirl, gPlayer, 3, 1, true)
            PedFaceObject(gPlayer, kissGirl, 2, 1, true)
            PedLockTarget(gPlayer, kissGirl)
            PedLockTarget(kissGirl, gPlayer)
            if 0 >= ItemGetCurrentNum(475) then
                ItemSetCurrentNum(475, 1)
            end
            while not PedIsPlaying(gPlayer, "/Global/Player/Gifts/GiveFlowers", true) do
                PedSocialKeepAlive(kissGirl)
                Wait(0)
            end
            TutorialRemoveMessage()
            PlayerLockButtonInputsExcept(true, 10)
            Wait(1000)
            TutorialShowMessage("MGCA_KISS03", -1, true)
            PlayerLockButtonInputsExcept(true, 10, 7)
            PedSetFlag(kissGirl, 84, true)
            while not PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout", true) do
                Wait(0)
            end
            CreateThread("T_FlashHud")
            TutorialRemoveMessage()
            Wait(500)
            TutorialShowMessage(tutorialMessage, -1, true)
            while PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout", true) do
                PedSocialKeepAlive(kissGirl)
                Wait(0)
            end
            PlayerSetControl(0)
            PedWander(kissGirl, 0)
            Wait(1500)
            CameraSetWidescreen(true)
            PlayerLockButtonInputsExcept(false)
            MinigameSetCompletion("MEN_BLANK", true, 0, unlockText)
            CameraAllowChange(true)
        else
            MinigameSetCompletion("MEN_BLANK", true, 0, unlockText)
            TutorialShowMessage(tutorialMessage, -1, true)
        end
        CameraSetXYZ(-668.60754, -296.3059, 6.783578, -669.5556, -295.98804, 6.790044)
        Wait(500)
        CameraFade(-1, 1)
        if kissGirl and PedIsValid(kissGirl) then
            PedDelete(kissGirl)
        end
        SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "speech")
        PedSetActionNode(gPlayer, victoryAnim, "Act/Conv/C2.act")
        Wait(4000)
        TutorialRemoveMessage()
        CameraSetWidescreen(false)
        NonMissionPedGenerationEnable()
        if gClassNo == 0 then
            PedIgnoreStimuli(kissGirl, false)
            PedMakeAmbient(kissGirl)
        end
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
        CameraSetXYZ(-534.034, 378.7261, 15.394567, -534.6163, 377.91824, 15.30445)
        CameraFade(-1, 1)
        SoundPlayScriptedSpeechEvent(prefect, "BUSTED_CLASS", 0, "speech")
        PedSetActionNode(prefect, "/Global/Ambient/MissionSpec/Prefect/PrefectChew", "Act/Anim/Ambient.act")
        PedSetActionNode(gPlayer, "/Global/C2_ArtClass/PlayerFail", "Act/Conv/C2.act")
        Wait(3000)
        PedSetActionNode(gPlayer, "/Global/C2_ArtClass/Clear", "Act/Conv/C2.act")
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

function F_Socialize(pedId, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 23, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 27, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 24, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 28, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 29, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 30, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 33, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 34, bDisable)
    PlayerSocialDisableActionAgainstPed(pedId, 36, bDisable)
end

function T_FlashHud()
    ToggleHUDComponentFlashing(4, true)
end
