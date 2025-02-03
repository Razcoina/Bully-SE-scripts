local gClassNo = 1
local gTotalPics = 1
local gGoodPicsTaken = 0
local gObjectiveText = ""
local gExitPoint = -1
local gExitArea = 2
local gPhotoTargets = {}
local objBlip = -1
local gTotalTime = 300
local gTargetsTaken = {}
local gEntities = {}
local gPhotoHasBeenTaken = false
local gGoodStringOne = "C5_05"
local gGoodStringMore = "C5_06"
local gSecondTutorial = false
local gFirstTutorial = false
local gValidTargetsTaken = {}

function MissionCleanup()
    ClockSet(gHr, gMin)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    SoundRestartPA()
    MissionTimerStop()
    CounterMakeHUDVisible(false)
    SoundFadeoutStream()
    SoundEnableInteractiveMusic(true)
    PlayerSetControl(1)
    AreaSetDoorLocked("DT_ischool_Art", true)
    if shared.gMissionPhoto4 then
        shared.gMissionPhoto4 = nil
    end
    if not gMissionSucceeded then
        if gClassNo == 1 then
            ResetYearbookPhotos()
        end
        if gClassNo == 3 then
            HUDPhotographySetColourUpgrade(false)
            PlayerSetWeapon(328, 1, false)
            PedClearWeapon(gPlayer, 426)
        end
    elseif gClassNo == 2 then
        HUDPhotographySetSaveLevel1(true)
    elseif gClassNo == 1 then
        F_UnlockPhotos()
    elseif gClassNo == 4 then
        HUDPhotographySetSaveLevel2(true)
    elseif gClassNo == 3 then
    elseif gClassNo == 5 then
    end
    UnLoadAnimationGroup("WeaponUnlock")
    UnLoadAnimationGroup("MINI_React")
    F_MakePlayerSafeForNIS(false)
    if objBlip then
        BlipRemove(objBlip)
    end
    WeaponSetRangeMultiplier(gPlayer, 328, 1)
    CameraSetWidescreen(false)
    DATUnload(2)
end

function MissionSetup()
    gHr, gMin = ClockGet()
    ClockSet(12, 0)
    MissionDontFadeIn()
    SoundEnableInteractiveMusic(false)
    DATLoad("C5.DAT", 2)
    DATInit()
    PlayerSetControl(0)
    WeaponRequestModel(328)
    WeaponRequestModel(426)
    LoadAnimationGroup("WeaponUnlock")
    LoadAnimationGroup("MINI_React")
    LoadActionTree("Act/Conv/C5.act")
    SoundStopPA()
    SoundStopCurrentSpeechEvent()
end

function main()
    while not gDoneSettingUp do
        Wait(0)
    end
    AreaTransitionPoint(17, POINTLIST._C5_PLAYERSTART, nil, true)
    F_MakePlayerSafeForNIS(true)
    F_InitialCutscene()
    AreaSetDoorLocked("DT_ischool_Art", true)
    AreaTransitionPoint(gExitArea, gExitPoint, 2, true)
    SoundPlayStream("MS_PhotographyClass.rsm", 0.25, 2, 1)
    if gClassNo == 3 then
        --print("GIVING THE PLAYER THE DIG CAM")
        HUDPhotographySetColourUpgrade(true)
        PedDestroyWeapon(gPlayer, 328)
        PlayerSetWeapon(426, 1, false)
        while not WeaponEquipped(426) do
            Wait(0)
        end
    end
    gClassSetupFunction()
    gMissionRunning = true
    if gClassNo ~= 3 then
        CreateThread("F_CheckThread")
    end
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    CameraFade(1000, 1)
    TextPrint(gObjectiveText, 5, 1)
    misObj = MissionObjectiveAdd(gObjectiveText)
    F_Explain(gClassNo)
    CounterClearIcon()
    CounterClearText()
    CounterSetCurrent(0)
    CounterSetMax(gTotalPics)
    CounterMakeHUDVisible(true, true)
    CounterSetIcon("HUDIcon_photos", "HUDIcon_photos_x")
    Wait(600)
    MissionTimerStart(gTotalTime)
    while gMissionRunning do
        F_ClassLoop(gClassNo)
        if gGoodPicsTaken >= gTotalPics then
            gMissionRunning = false
            AreaSetDoorLocked("DT_ischool_Art", true)
            Wait(2000)
            CounterMakeHUDVisible(false)
            TextPrint("C5_02", 5, 1)
            MissionObjectiveComplete(misObj)
            misObj1 = MissionObjectiveAdd("C5_02")
            Wait(1000)
            shared.photoClass01 = nil
            F_CleanupClass()
            if objBlip then
                BlipRemove(objBlip)
                objBlip = nil
            end
            objBlip = BlipAddPoint(POINTLIST._C5_CORONA, 0, 1, 1, 7)
        end
        Wait(0)
        if MissionTimerHasFinished() then
            gMissionRunning = false
            gMissionFailed = true
        end
    end
    local x, y, z = GetPointList(POINTLIST._C5_CORONA)
    while not PlayerIsInAreaXYZ(x, y, z, 1, 0) do
        if MissionTimerHasFinished() then
            gMissionFailed = true
            break
        end
        Wait(0)
    end
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    if gMissionFailed then
        CameraReturnToPlayer()
        MissionTimerStop()
        PlayerSetControl(0)
        PlayerUnequip()
        MinigameSetGrades(7, gGrade - 1)
        SoundFadeoutStream()
        SoundPlayMissionEndMusic(false, 9)
        while MinigameIsShowingGrades() do
            Wait(0)
        end
        PlayerSetControl(1)
        MissionFail(false, false)
    else
        PlayerSetControl(0)
        CameraFade(1000, 0)
        Wait(1000)
        MissionTimerStop()
        SoundPlayMissionEndMusic(true, 9)
        PlayerSetGrade(7, gGrade)
        F_EndingCutscene()
        CameraReturnToPlayer()
        F_EndCinematic()
        gMissionSucceeded = true
        MissionSucceed(false, false, false)
    end
end

function F_ClassLoop(classNo)
    if classNo == 1 then
        if not gFirstTutorial then
            TutorialStart("PHOTO2X")
            gFirstTutorial = true
        end
        if not gFirstEvent and PlayerIsInTrigger(TRIGGER._C5_PEDEVENT01) then
            --print("[RAUL] PEDEVENT 1 ")
            gFirstEvent = true
            gFirstEventPed = PedCreatePoint(69, POINTLIST._C5_PEDEVENT01)
            PedSetActionNode(gFirstEventPed, "/Global/WProps/PropInteract", "Act/WProps.act")
            Wait(0)
        end
        if not gSecondEvent and PlayerIsInTrigger(TRIGGER._C5_PEDEVENT02) then
            --print("[RAUL] PEDEVENT 2 ")
            gSecondEvent = true
            gSecondEventPedA = PedCreatePoint(73, POINTLIST._C5_PEDEVENT02, 2)
            Wait(0)
            gSecondEventPedB = PedCreatePoint(74, POINTLIST._C5_PEDEVENT02, 1)
            Wait(0)
            PedLockTarget(gSecondEventPedA, gSecondEventPedB, 0)
            PedSetActionNode(gSecondEventPedA, "/Global/Ambient/Scripted/Kiss_Me_Baby", "Act/Anim/Ambient.act")
            PedMakeAmbient(gSecondEventPedA)
        end
        if not gThirdEvent and PlayerIsInTrigger(TRIGGER._C5_PEDEVENT03) then
            --print("[RAUL] PEDEVENT 3 ")
            gThirdEvent = true
            gThirdEventPed = PedCreatePoint(71, POINTLIST._C5_PEDEVENT03)
            PedSetActionNode(gThirdEventPed, "/Global/WProps/PropInteract", "Act/WProps.act")
            Wait(0)
        end
    elseif classNo == 2 then
        if not gSecondTutorial then
            TutorialStart("PHOTO1X")
            gSecondTutorial = true
        end
    elseif classNo == 3 then
        for i, photo in gPhotoTargets do
            if not photo.taken and PlayerIsInAreaXYZ(photo.px, photo.py, photo.pz, 1, 0) then
                TextPrint(photo.text, 4, 1)
                photo.objective = MissionObjectiveAdd(photo.text)
                pLoc = i
                break
            end
            Wait(0)
        end
        if pLoc then
            cEntry = gPhotoTargets[pLoc]
            gInArea = true
            while gInArea do
                validTarget = false
                if PhotoTargetInFrame(cEntry.x, cEntry.y, cEntry.z) then
                    validTarget = true
                end
                PhotoSetValid(validTarget)
                photohasbeentaken, wasValid = PhotoHasBeenTaken()
                if photohasbeentaken and wasValid and validTarget then
                    CounterIncrementCurrent(1)
                    MissionObjectiveComplete(gPhotoTargets[pLoc].objective)
                    gGoodPicsTaken = gGoodPicsTaken + 1
                    gGoodPictureTaken = true
                end
                if gGoodPictureTaken then
                    gGoodPictureTaken = false
                    gInArea = false
                    MissionObjectiveComplete(gPhotoTargets[pLoc].objective)
                    BlipRemove(gPhotoTargets[pLoc].corona)
                    gPhotoTargets[pLoc].corona = nil
                    PhotoSetValid(false)
                    gPhotoTargets[pLoc].taken = true
                elseif not PlayerIsInAreaXYZ(cEntry.px, cEntry.py, cEntry.pz, 3, 0) then
                    MissionObjectiveRemove(gPhotoTargets[pLoc].objective)
                    TextPrint("C5_10", 4, 1)
                    gInArea = false
                end
                Wait(0)
            end
            pLoc = nil
        end
    elseif classNo == 4 then
        if objBlip and PlayerIsInTrigger(TRIGGER._AMB_POOR_AREA) then
            TextPrint("C5_13", 4, 1)
            BlipRemove(objBlip)
            objBlip = nil
        end
    elseif classNo == 5 and objBlip and AreaGetVisible() == 55 then
        BlipRemove(objBlip)
        objBlip = nil
    end
end

function F_JockWorkout(id)
    PedSetActionNode(id, "/Global/C5/Workout", "Act/Conv/C5.act")
    PedMakeAmbient(id)
end

function F_Explain(no)
    if gClassNo == 1 then
        shared.photoClass01 = true
    elseif gClassNo == 2 then
        CameraSetWidescreen(true)
        PlayerSetControl(0)
        CameraSetPath(PATH._C5_INTROCAMC02, true)
        CameraSetSpeed(1.8, 1.8, 1.8)
        CameraLookAtPath(PATH._C5_INTROLOOKATC02, true)
        CameraLookAtPathSetSpeed(1.8, 1.8, 1.8)
        Wait(6000)
        CameraFade(500, 0)
        Wait(550)
        CameraSetWidescreen(false)
        CameraReturnToPlayer()
        CameraReset()
        PlayerSetControl(1)
        CameraFade(500, 1)
    elseif gClassNo == 4 then
        local x, y, z = GetAnchorPosition(TRIGGER._AMB_POOR_AREA)
        objBlip = BlipAddXYZ(x, y, z, 0)
    elseif gClassNo == 5 then
        objBlip = BlipAddPoint(POINTLIST._C5_FREAKHOUSE, 0)
    end
end

function F_ClassOne()
    gTargetsTaken = {}
    gValidTargetsTaken = {
        false,
        false,
        false,
        false,
        false
    }
end

function F_ClassTwo()
    local itemsToRemove = 0
    WeaponSetRangeMultiplier(gPlayer, 328, 2)
    local bannerTable = {
        {
            trigger = TRIGGER._SCHOOLENTRR2,
            blipId = -1
        },
        {
            trigger = TRIGGER._LIBRARYL,
            blipId = -1
        },
        {
            trigger = TRIGGER._AUTOSHOP,
            blipId = -1
        },
        {
            trigger = TRIGGER._GLASSDOME,
            blipId = -1
        },
        {
            trigger = TRIGGER._GDORMENTRANCE,
            blipId = -1
        }
    }
    local x2, y2, z2
    for i, event in bannerTable do
        PAnimCreate(event.trigger)
        x2, y2, z2 = GetAnchorPosition(event.trigger)
        --print(" trigger: ", event.trigger, x2, y2, z2)
        table.insert(gPhotoTargets, {
            x = x2,
            y = y2,
            z = z2,
            blipId = BlipAddXYZ(x2, y2, 8.6, 0, 1),
            valid = false,
            taken = false
        })
    end
end

function F_ClassThree()
    gPhotoTargets = {
        {
            text = "C5_3_01",
            corona = nil,
            x = 266.3092,
            y = -73.23689,
            z = 7.5714674,
            px = 272.03143,
            py = -73.16567,
            pz = 6,
            taken = false
        },
        {
            text = "C5_3_03",
            corona = nil,
            x = 573.8481,
            y = 77.35596,
            z = 15.027881,
            px = 568.2637,
            py = 76.04305,
            pz = 13.967935,
            taken = false
        },
        {
            text = "C5_3_04",
            corona = nil,
            x = 267.06357,
            y = 307.17627,
            z = 3.219628,
            px = 269.2503,
            py = 304.56186,
            pz = 0.81963855,
            taken = false
        },
        {
            text = "C5_3_05",
            corona = nil,
            x = 247.57248,
            y = 394.64005,
            z = 6.9025292,
            px = 250.00829,
            py = 392.58865,
            pz = 4.9627414,
            taken = false
        },
        {
            text = "C5_3_07",
            corona = nil,
            x = 635.1715,
            y = 166.17995,
            z = 21.624157,
            px = 636.17346,
            py = 164.59558,
            pz = 19.945162,
            taken = false
        }
    }
    for i, photo in gPhotoTargets do
        photo.corona = BlipAddXYZ(photo.px, photo.py, photo.pz, 0, 1, 7)
    end
end

function F_ClassFour()
    gEntities = {
        {
            eType = 2,
            eId = -1,
            model = 141,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 141,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 219,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 219,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 220,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 220,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 116,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 116,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 116,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 116,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 157,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 157,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 157,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 157,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 87,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 87,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 131,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 131,
            valid = false,
            taken = false
        }
    }
end

function F_ClassFive()
    gEntities = {
        {
            eType = 2,
            eId = -1,
            model = 190,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 191,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 192,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 193,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 194,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 188,
            valid = false,
            taken = false
        },
        {
            eType = 2,
            eId = -1,
            model = 189,
            valid = false,
            taken = false
        }
    }
end

function F_CleanupClass()
    if gClassNo == 3 then
        for i, photo in gPhotoTargets do
            if photo.corona then
                BlipRemove(photo.corona)
                photo.corona = nil
            end
        end
    end
end

function F_EndingCutscene()
    AreaTransitionPoint(17, POINTLIST._C5_ENDINGPOINTS, 2, true)
    teacher = PedCreatePoint(63, POINTLIST._C5_ENDINGPOINTS, 1)
    PedIgnoreStimuli(teacher, true)
    SoundDisableSpeech_ActionTree()
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    CameraLookAtXYZ(-536.29114, 394.74268, 15.509263, true)
    CameraSetXYZ(-534.2692, 394.0767, 15.329271, -536.29114, 394.74268, 15.509263)
    PedFaceObject(gPlayer, teacher, 2, 0, true)
    CameraLookAtXYZ(-537.4361, 395.07306, 15.68962, true)
    CameraSetXYZ(-535.05505, 393.89645, 15.029265, -537.4361, 395.07306, 15.68962)
    CameraFade(1000, 1)
    Wait(500)
    if gClassNo < 5 then
        SoundPlayScriptedSpeechEvent(teacher, "PHOTOGRAPHY", 9, "large", true)
    else
        F_PlaySpeechAndWait(teacher, "PHOTOGRAPHY", 9, "large")
        SoundPlayScriptedSpeechEvent(teacher, "PHOTOGRAPHY", 10, "large", true)
    end
    Wait(2000)
    MinigameSetGrades(7, gGrade - 1)
    SoundFadeoutStream()
    while MinigameIsShowingGrades() do
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(500)
    PedDelete(teacher)
    SoundEnableSpeech_ActionTree()
end

function F_InitialCutscene()
    teacher = PedCreatePoint(63, POINTLIST._C5_TEACHERSTART)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    if not F_CheckIfPrefect() then
        CameraFade(1000, 1)
    end
    CameraSetPath(PATH._C5_INTROCAM, true)
    CameraSetSpeed(1.8, 1.8, 1.8)
    CameraLookAtPath(PATH._C5_INTROLOOKAT, true)
    CameraLookAtPathSetSpeed(1.8, 1.8, 1.8)
    PedFollowPath(gPlayer, PATH._C5_PLAYERPATH, 0, 0)
    SoundDisableSpeech_ActionTree()
    Wait(500)
    if gClassNo == 2 then
        SoundPlayScriptedSpeechEvent(teacher, "PHOTOGRAPHY", 1, "large", true)
        Wait(3000)
        SoundPlayScriptedSpeechEvent(teacher, "PHOTOGRAPHY", 3, "large", true)
    elseif gClassNo == 1 then
        SoundPlayScriptedSpeechEvent(teacher, "PHOTOGRAPHY", 5, "large", true)
    elseif gClassNo == 3 then
        SoundPlayScriptedSpeechEvent(teacher, "PHOTOGRAPHY", 6, "large", true)
        Wait(1538)
    elseif gClassNo == 4 then
        SoundPlayScriptedSpeechEvent(teacher, "PHOTOGRAPHY", 5, "large", true)
    elseif gClassNo == 5 then
        SoundPlayScriptedSpeechEvent(teacher, "PHOTOGRAPHY", 8, "large", true)
        Wait(1538)
    end
    Wait(3538)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(1000, 0)
    Wait(1050)
    F_CleanPrefect()
    SoundEnableSpeech_ActionTree()
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PedDelete(teacher)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
end

function F_CheckThread()
    local checkValid = false
    --print("<<<<<<<<<<<<<< INITIALIZING THREAD")
    local totalTargets = 0
    local properString = gGoodStringOne
    local L3_2 = -1 -- Added this
    while gMissionRunning do
        if gClassNo == 2 then
            validTarget = false
            for i, target in gPhotoTargets do
                if not target.taken and PhotoTargetInFrame(target.x, target.y, target.z) then
                    gPhotoTargets[i].valid = true
                    validTarget = true
                    L3_2 = i
                end
            end
            PhotoSetValid(validTarget)
            photohasbeentaken, wasValid = PhotoHasBeenTaken()
            if photohasbeentaken and wasValid then
                for i, target in gPhotoTargets do
                    if not target.taken then
                        if target.valid == true or i == L3_2 then
                            target.taken = true
                            if target.blipId then
                                BlipRemove(target.blipId)
                            end
                            target.blipId = nil
                            CounterIncrementCurrent(1)
                            gGoodPicsTaken = gGoodPicsTaken + 1
                            targetFound = true
                            L3_2 = -1
                        end
                    end
                end
            end
            for i, target in gPhotoTargets do
                if target.valid == true and not target.taken then
                    target.valid = false
                end
            end
        elseif gClassNo == 1 then
            validTarget = false
            totalTargets = 0
            PhotoGetEntityStart()
            repeat
                gEntity, gType = PhotoGetEntityNext()
                if F_CheckTargets(gClassNo, gEntity, gType) then
                    validTarget = true
                    totalTargets = totalTargets + 1
                    gValidTargetsTaken[totalTargets] = gEntity
                end
            until gEntity == -1
            if 1 < totalTargets then
                properString = gGoodStringMore
            else
                properString = gGoodStringOne
            end
            if validTarget then
                PhotoSetValid(validTarget, properString)
            else
                PhotoSetValid(validTarget)
            end
            photohasbeentaken, wasValid = PhotoHasBeenTaken()
            if photohasbeentaken and wasValid then
                for i, target in gValidTargetsTaken do
                    if target then
                        gGoodPicsTaken = gGoodPicsTaken + 1
                        hashId = PedGetNameHashID(target)
                        table.insert(gTargetsTaken, hashId)
                        gValidTargetsTaken[i] = false
                    end
                end
                CounterIncrementCurrent(totalTargets)
            end
        elseif gClassNo == 4 or gClassNo == 5 then
            validTarget = false
            totalTargets = 0
            PhotoGetEntityStart()
            repeat
                gEntity, gType = PhotoGetEntityNext()
                if F_CheckTargets(gClassNo, gEntity, gType) then
                    validTarget = true
                    totalTargets = totalTargets + 1
                end
            until gEntity == -1
            if 1 < totalTargets then
                properString = gGoodStringMore
            else
                properString = gGoodStringOne
            end
            if validTarget then
                PhotoSetValid(validTarget, properString)
            else
                PhotoSetValid(validTarget)
            end
            photohasbeentaken, wasValid = PhotoHasBeenTaken()
            if photohasbeentaken and wasValid then
                for i, target in gEntities do
                    if not target.taken and target.valid then
                        gGoodPicsTaken = gGoodPicsTaken + 1
                        table.insert(gTargetsTaken, target.eId)
                        target.taken = true
                    end
                end
                CounterIncrementCurrent(totalTargets)
            end
            for i, target in gEntities do
                if not target.taken then
                    target.valid = false
                    target.eId = -1
                end
            end
        end
        Wait(0)
    end
end

function F_CheckTargets(classNo, entityId, entityType, photoHasBeenTaken)
    local valid = true
    local hashId
    if classNo == 1 then
        if entityType == 2 then
            hashId = PedGetNameHashID(entityId)
            for j, target in gTargetsTaken do
                if target == hashId then
                    valid = false
                end
            end
            if valid and IsValidYearbookPhotoOfPed(entityId) then
                return true
            end
        end
    elseif classNo == 4 or classNo == 5 then
        for i, entity in gEntities do
            if entity.eId == -1 and entity.eType == entityType then
                if PedIsModel(entityId, entity.model) then
                    for j, target in gTargetsTaken do
                        if target == entityId then
                            valid = false
                        end
                    end
                    if valid then
                        entity.eId = entityId
                        entity.valid = true
                        return true
                    end
                end
            elseif entity.eId == entityId then
                return false
            end
        end
        return false
    end
    return false
end

function F_SetupClass(param)
    --print("SETTING UP PHOTO CLASS", param)
    if param == 1 then
        gClassNo = 1
        gObjectiveText = "C5_08"
        gExitPoint = POINTLIST._C5_EXITPOINT
        gClassSetupFunction = F_ClassOne
        gTotalTime = 600
        gTotalPics = 3
        gGoodStringOne = "C5_03"
        gGoodStringMore = "C5_04"
        gGrade = 2
    elseif param == 2 then
        gClassNo = 2
        gObjectiveText = "C5_09"
        gExitPoint = POINTLIST._C5_EXITPOINT02
        gExitArea = 0
        gClassSetupFunction = F_ClassTwo
        gTotalPics = 5
        gTotalTime = 400
        gGrade = 1
    elseif param == 3 then
        gClassNo = 3
        gObjectiveText = "C5_10"
        gExitPoint = POINTLIST._C5_EXITPOINT02
        gExitArea = 0
        gClassSetupFunction = F_ClassThree
        gTotalPics = 5
        gTotalTime = 600
        gGrade = 4
    elseif param == 4 then
        --print("SETUP FOR CLASS 4 <<<<<<<<<<<<<<<<<<<<<")
        shared.gMissionPhoto4 = true
        gClassNo = 4
        gObjectiveText = "C5_11"
        gExitPoint = POINTLIST._C5_EXITPOINT02
        gExitArea = 0
        gClassSetupFunction = F_ClassFour
        gTotalPics = 4
        gTotalTime = 900
        gGrade = 3
    elseif 5 <= param then
        gClassNo = 5
        gObjectiveText = "C5_12"
        gExitPoint = POINTLIST._C5_EXITPOINT02
        gExitArea = 0
        gClassSetupFunction = F_ClassFive
        gTotalPics = 7
        gTotalTime = 600
        gGrade = 5
    end
    gDoneSettingUp = true
end

function F_EndCinematic()
    local cinematicActive = false
    local unlockText = "C5_UNLK_1"
    local unlockMissionText = "P_UNLOCK1"
    local unlockAnim = "/Global/C5/EarnC"
    local unlockAnim2
    if gClassNo == 2 then
        cinematicActive = 1
        unlockAnim2 = "/Global/C5/PlayerVictory01"
    elseif gClassNo == 1 then
        cinematicActive = 2
        unlockText = "C5_UNLK_2"
        unlockMissionText = "P_UNLOCK2"
        unlockAnim = "/Global/C5/Unlocks/SuccessHi2"
    elseif gClassNo == 4 then
        unlockText = "C5_UNLK_3"
        unlockMissionText = "P_UNLOCK3"
        unlockAnim = "/Global/C5/Unlocks/SuccessHi1"
        cinematicActive = 3
    elseif gClassNo == 3 then
        unlockText = "C5_UNLK_4"
        unlockMissionText = "P_UNLOCK4"
        cinematicActive = 4
    elseif gClassNo == 5 then
        unlockText = "C5_UNLK_5"
        unlockMissionText = "P_UNLOCK5"
        cinematicActive = 5
        unlockAnim = "/Global/C5/Unlocks/SuccessHi3"
    end
    if cinematicActive then
        CameraFade(-1, 0)
        Wait(FADE_OUT_TIME + 1000)
        RestoredVisibility = true
        AreaTransitionPoint(2, POINTLIST._C5_EXITPOINT, nil, true)
        AreaClearAllPeds()
        NonMissionPedGenerationDisable()
        CameraAllowChange(true)
        F_MakePlayerSafeForNIS(true)
        Wait(1000)
        local x, y, z = GetPointList(POINTLIST._C5_CAMERALOOKAT)
        CameraLookAtXYZ(x, y, z, true)
        CameraSetPath(PATH._C5_CAMERAPATH, true)
        SoundEnableSpeech_ActionTree()
        CameraSetWidescreen(true)
        if gClassNo == 2 or gClassNo == 1 or gClassNo == 4 then
            PedSetWeaponNow(gPlayer, 328, 1, false)
        else
            PedSetWeaponNow(gPlayer, 426, 1, false)
        end
        CameraFade(-1, 1)
        MinigameSetCompletion("MEN_BLANK", true, 0, unlockMissionText)
        TutorialShowMessage(unlockText, -1, true)
        Wait(1000)
        SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "jumbo")
        PedSetActionNode(gPlayer, unlockAnim, "Act/Conv/C5.act")
        Wait(5000)
        TutorialRemoveMessage()
        CameraSetWidescreen(false)
        F_MakePlayerSafeForNIS(false)
        NonMissionPedGenerationEnable()
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
        CameraSetXYZ(-535.5674, 377.4347, 15.39489, -536.53723, 377.19128, 15.395476)
        CameraFade(-1, 1)
        SoundPlayScriptedSpeechEvent(prefect, "BUSTED_CLASS", 0, "speech")
        PedSetActionNode(prefect, "/Global/Ambient/MissionSpec/Prefect/PrefectChew", "Act/Anim/Ambient.act")
        PedSetActionNode(gPlayer, "/Global/C5/Failure", "Act/Conv/C5.act")
        Wait(3000)
        PedSetActionNode(gPlayer, "/Global/C5/Clear", "Act/Conv/C5.act")
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

function F_UnlockPhotos()
    UnlockYearbookPicture(134)
    if IsMissionCompleated("1_B") then
        UnlockYearbookPicture(75)
    end
    if IsMissionCompleated("2_B") then
        UnlockYearbookPicture(37)
    end
    if IsMissionCompleated("3_B") then
        UnlockYearbookPicture(23)
    end
    if IsMissionCompleated("4_B1") then
        UnlockYearbookPicture(10)
    end
    if IsMissionCompleated("4_B2") then
        UnlockYearbookPicture(110)
    end
    if IsMissionCompleated("5_B") then
        UnlockYearbookPicture(91)
    end
    if IsMissionCompleated("6_B") then
        UnlockYearbookPicture(130)
    end
    F_UnlockYearbookReward()
end
