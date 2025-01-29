---@diagnostic disable: param-type-mismatch
--[[ Changes to this file:
    * Modified function MissionCleanup, may require testing
    * Modified function F_SetupCameraWork, may require testing
]]

local tObjectives = {}
local tAnims = {}
local tKidSet = {}
local bObjectsCollected = false
local bPhotosTaken = false
local bMissionComplete = false
local tOrnamentModels = { 521 }
local bReturnedRudy = false
local bGoodPose = false
local bGoodFace = false
local bMissionOver = false
local bRoundTwo = false
local nPickedUp = 0
local NUM_ORNAMENTS = 5
local bADown_pos = false
local bADown_neg = false
local nPhotos = 0
local NUM_PHOTOS = 5
local Anim_Index = 0
local Kid_Index = 1
local bFirstWave = true
local bMissionFail = false
local RUDY_DEFAULT_VOLUME = 0.8
local tKidModels = {
    69,
    66,
    68,
    137,
    138,
    159
}
tPhotoPhrase = {
    "3_01D_TEXT_02",
    "3_01D_TEXT_03"
}
local tPhotos = {}
tPhotos[1] = "3_01D_PHOTO_01"
tPhotos[2] = "3_01D_PHOTO_02"
tPhotos[3] = "3_01D_PHOTO_03"
tPhotos[4] = "3_01D_PHOTO_04"
tPhotos[5] = "3_01D_PHOTO_05"
local tSantaTalk = {}
local tSantaTalk1 = {}
local tSantaTalk2 = {}
local tElves = {
    MODELENUM._TO_ElfM,
    MODELENUM._TO_ElfF,
    219
}

function MissionSetup()
    --print("3.10D MissionSetup")
    PedSaveWeaponInventorySnapshot(gPlayer)
    PlayerSetControl(0)
    CameraFade(0, 0)
    DATLoad("3_01D.DAT", 2)
    LoadActionTree("Act/Conv/3_01D.act")
    LoadAnimationGroup("Santa_lap")
    AreaTransitionPoint(0, POINTLIST._3_01D_PSTART)
    AreaLoadSpecialEntities("Rudy1", true)
    AreaLoadSpecialEntities("Rudy3", true)
    AreaEnsureSpecialEntitiesAreCreated()
    AreaOverridePopulation(6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaClearAllVehicles()
    HUDPhotographySetColourUpgrade(true)
    PlayCutsceneWithLoad("3-01DA", true)
    AreaSetPathableInRadius(489.428, -115.542, 5.4376, 1, 2, false)
    RegisterCallbackOnYearbookPhoto(F_YearBookDummy)
    LoadModels(tKidModels)
    LockStores(true)
end

function F_YearBookDummy()
    --print("F_YearBookDummy")
end

function MissionCleanup()  -- ! Modified
    --print("3.10D MissionCleanup")
    PhotoShowExitString(true) -- Added this
    CameraSetActive(1)
    CameraReset()
    CameraReturnToPlayer()
    CameraClearRotationLimit()
    CameraAllowChange(true)
    PedDestroyWeapon(gPlayer, 426)
    AreaSetPathableInRadius(489.428, -115.542, 5.4376, 1, 2, true)
    RegisterCallbackOnYearbookPhoto(CB_YearbookPhotoMain)
    HUDPhotographySetColourUpgrade(false)
    for i, v in tObjectives do
        MissionObjectiveComplete(tObjectives[i])
    end
    PedDelete(Rudy)
    PedSetFlag(gPlayer, 2, false)
    LockStores(false)
    PlayerLockButtonInputsExcept(false)
    AreaRevertToDefaultPopulation()
    UnLoadAnimationGroup("Santa_lap")
    DATUnload(2)
    CameraSetWidescreen(false)
    AreaLoadSpecialEntities("Rudy1", false)
    if bReturnedRudy then
        AreaLoadSpecialEntities("Rudy2", false)
    end
    AreaLoadSpecialEntities("Rudy3", false)
    PedRestoreWeaponInventorySnapshot(gPlayer)
end

function main()
    --print("3.10D Main()")
    Rudy = PedCreatePoint(252, POINTLIST._3_01D_RUDYSTART)
    PedSetFlag(Rudy, 19, true)
    PedSetEmotionTowardsPed(Rudy, gPlayer, 7)
    PedSetInvulnerable(Rudy, true)
    PedSetAsleep(Rudy, true)
    PedSetPosPoint(gPlayer, POINTLIST._3_01D_PSTART, 2)
    PlayerSetControl(1)
    LoadModels(tOrnamentModels)
    LoadModels(tElves)
    Wait(200)
    CameraFade(1, 1000)
    SoundPlayInteractiveStream("MS_XmasComeRudyLow.rsm", 1, 0, 500)
    SoundSetMidIntensityStream("MS_XmasComeRudyMid.rsm", 1, 0, 500)
    SoundSetHighIntensityStream("MS_XmasComeRudyHigh.rsm", 0.9, 0, 500)
    F_SetupHUD()
    F_SetupCollectables()
    table.insert(tObjectives, MissionObjectiveAdd("3_01D_OBJ1_01"))
    TextPrint("3_01D_OBJ1_01", 5, 1)
    MissionTimerStart(180)
    while not (bObjectsCollected or bMissionOver) do
        Wait(0)
        if MissionTimerHasFinished() then
            F_CollectableCleanup()
            bMissionOver = true
            Wait(0)
            MissionFail(false, true, "3_01D_FAIL_01")
        end
        if not bMissionOver then
            F_CheckCollectables()
        end
    end
    if not bMissionOver then
        F_SetupCameraWork()
        SoundPlayInteractiveStream("MS_KidsPlay.rsm", RUDY_DEFAULT_VOLUME)
        SoundSetMidIntensityStream("MS_KidsPlay.rsm", RUDY_DEFAULT_VOLUME)
        SoundSetHighIntensityStream("MS_KidsPlay.rsm", RUDY_DEFAULT_VOLUME)
        while not F_PhotosTaken() do
            Wait(0)
            F_CheckGoodPhoto()
            if nPhotos ~= 5 and kidActive ~= nil and (tKidSet[Kid_Index].sequence1[Anim_Index] == nil or not PedIsPlaying(Rudy, tAnims[tKidSet[Kid_Index].sequence1[Anim_Index]].SantaCycle, false)) then
                if tKidSet[Kid_Index].sequence1[Anim_Index + 1] or Anim_Index == 0 then
                    Anim_Index = Anim_Index + 1
                    F_RunAnimCycle()
                else
                    Anim_Index = 0
                    F_KidTransition()
                end
            end
        end
        CameraReset()
        CameraReturnToPlayer()
        CameraClearRotationLimit()
        CameraAllowChange(true)
        Wait(10)
        if not bMissionFail then
            PlayCutsceneWithLoad("3-01DC", true)
            Wait(1000)
            MissionSucceed(true, true, false, 50)
            Wait(10)
            MinigameSetCompletion("M_PASS", true, 5000)
            SoundPlayMissionEndMusic(true, 10)
            while MinigameIsShowingCompletion() do
                Wait(10)
            end
        end
    end
end

function F_SetupCollectables()
    --print("F_SetupObjects()")
    tObjectPoints = {
        {
            point = POINTLIST._3_01D_OBJECT1,
            model = 521,
            element = 1,
            bPicked = false
        },
        {
            point = POINTLIST._3_01D_OBJECT2,
            model = 521,
            element = 2,
            bPicked = false
        },
        {
            point = POINTLIST._3_01D_OBJECT3,
            model = 521,
            element = 3,
            bPicked = false
        },
        {
            point = POINTLIST._3_01D_OBJECT4,
            model = 521,
            element = 4,
            bPicked = false
        },
        {
            point = POINTLIST._3_01D_OBJECT5,
            model = 521,
            element = 5,
            bPicked = false
        }
    }
    for i, dataSet in tObjectPoints do
        dataSet.id = PickupCreatePoint(dataSet.model, dataSet.point, dataSet.element, 0, "PermanentButes")
        dataSet.blip = BlipAddPoint(dataSet.point, 0, 1, 4)
    end
    F_SetupCollectables = nil
end

function F_CollectableCleanup()
    --print("F_CollectableCleanup")
    for i, dataSet in tObjectPoints do
        if dataSet.id then
            BlipRemove(dataSet.blip)
            dataSet.id = nil
        end
    end
    tObjectPoints = nil
end

function F_ModelCleanup()
    --print("F_ModelCleanup")
    for i, model in tElves do
        ModelNotNeeded(model)
    end
    for i, model in tOrnamentModels do
        ModelNotNeeded(model)
    end
end

function F_ElfAttack()
    --print("F_ElfAttack()")
    dog = PedCreatePoint(219, POINTLIST._3_01D_JIMMYPHOTO)
    Elf1 = PedCreatePoint(MODELENUM._TO_ElfM, POINTLIST._3_01D_ELF1)
    Elf2 = PedCreatePoint(MODELENUM._TO_ElfF, POINTLIST._3_01D_ELF2)
    PedAttack(dog, gPlayer, 1)
    PedAttack(Elf1, gPlayer, 1)
    PedAttack(Elf2, gPlayer, 1)
    PedSetInfiniteSprint(dog, true)
    PedSetInfiniteSprint(Elf1, true)
    PedSetInfiniteSprint(Elf2, true)
end

function F_ElfAttack2()
    --print("F_ElfAttack2()")
    Elf4 = PedCreatePoint(MODELENUM._TO_ElfM, POINTLIST._3_01D_ELF1)
    Elf5 = PedCreatePoint(MODELENUM._TO_ElfF, POINTLIST._3_01D_ELF2)
    PedAttack(Elf4, gPlayer, 1)
    PedAttack(Elf5, gPlayer, 1)
    PedSetInfiniteSprint(Elf4, true)
    PedSetInfiniteSprint(Elf5, true)
end

function F_ElfCleanup()
    --print("F_ElfCleanup()")
    local tElves = {
        Elf1,
        Elf2,
        Elf4,
        Elf5,
        dog
    }
    for i, elf in tElves do
        if elf then
            PedDelete(elf)
        end
    end
    F_ElfCleanup = nil
end

function F_PhotosTaken()
    return bPhotosTaken
end

function F_SetupHUD()
    --print("F_SetupHUD")
    CounterSetCurrent(nPickedUp)
    CounterSetMax(NUM_ORNAMENTS)
    CounterSetIcon("rudy", "rudy_x")
    CounterMakeHUDVisible(true, true)
end

function F_SetupHUD_photos()
    --print("F_SetupHUD_photos()")
    CounterSetCurrent(nPhotos)
    CounterSetMax(NUM_PHOTOS)
    CounterSetIcon("HUDIcon_photos", "HUDIcon_photos_x")
    CounterMakeHUDVisible(true, true)
end

function F_CheckGoodPhoto()
    bValidTarget = false
    local x, y, z = PedGetPosXYZ(Rudy)
    local bPhotoTaken, bValid = PhotoHasBeenTaken()
    if PhotoTargetInFrame(x, y, z + 1) then
        bValidTarget = true
    end
    if IsButtonPressed(12, 0) then
        if bValidTarget and bGoodFace then
            CounterIncrementCurrent(1)
            nPhotos = nPhotos + 1
            CounterSetCurrent(nPhotos)
            if nPhotos == NUM_PHOTOS then
                bPhotosTaken = true
                PlayerLockButtonInputsExcept(true)
            end
            bADown_pos = true
            PhotoSetValid(true, tPhotos[nPhotos])
            Wait(1000)
            tKidSet[Kid_Index].bPassed = true
            Wait(500)
            Anim_Index = 0
            F_KidTransition()
        else
            bADown_neg = true
            PhotoSetValid(false, tPhotoPhrase[math.random(1, 2)])
        end
    end
end

function F_ParentDialoguePass()
    --print("F_ParentDialoguePass")
    PedSetFlag(MomTalker, 113, false)
    SoundPlayScriptedSpeechEvent(MomTalker, "M_3_01D", tKidSet[Kid_Index].ParentSpeech.Pass[math.random(1, F_tsize(tKidSet[Kid_Index].ParentSpeech.Pass))], "jumbo")
    while SoundSpeechPlaying(MomTalker) do
        Wait(10)
    end
    PedSetFlag(MomTalker, 113, true)
end

function F_ParentDialoguePos()
    --print("F_ParentDialoguePos")
    PedSetFlag(MomTalker, 113, false)
    SoundPlayScriptedSpeechEvent(MomTalker, "M_3_01D", tKidSet[Kid_Index].ParentSpeech.Nice[math.random(1, F_tsize(tKidSet[Kid_Index].ParentSpeech.Nice))], "jumbo")
    while SoundSpeechPlaying(MomTalker) do
        Wait(10)
    end
    PedSetFlag(MomTalker, 113, true)
end

function F_ParentDialogueNeg()
    --print("F_ParentDialogueNeg")
    PedSetFlag(MomTalker, 113, false)
    local rNum = math.random(1, 3)
    if Anim_Index == 5 or Anim_Index == 6 or Anim_Index == 7 then
        SoundPlayScriptedSpeechEvent(MomTalker, "M_3_01D", tKidSet[Kid_Index].ParentSpeech.Behave[math.random(1, F_tsize(tKidSet[Kid_Index].ParentSpeech.Behave))], "jumbo")
    else
        if rNum == 1 then
            SoundPlayScriptedSpeechEvent(MomTalker, "M_3_01D", tKidSet[Kid_Index].ParentSpeech.Fail[math.random(1, F_tsize(tKidSet[Kid_Index].ParentSpeech.Fail))], "jumbo")
        elseif rNum == 2 then
            SoundPlayScriptedSpeechEvent(MomTalker, "M_3_01D", tKidSet[Kid_Index].ParentSpeech.Hurry[math.random(1, F_tsize(tKidSet[Kid_Index].ParentSpeech.Hurry))], "jumbo")
        end
        while SoundSpeechPlaying(MomTalker) do
            Wait(10)
        end
    end
    PedSetFlag(MomTalker, 113, true)
end

function F_ReAddBlip()
    --print("F_ReAddBlip")
    for i, dataSet in tObjectPoints do
        if dataSet.bPicked == false then
            AddBlipForPickup(dataSet.id, 0, 4)
        end
    end
end

function F_CheckCollectables()
    for i, dataSet in tObjectPoints do
        if dataSet.id and PickupIsPickedUp(dataSet.id) then
            BlipRemove(dataSet.blip)
            if dataSet.bPicked == false then
                ItemSetCurrentNum(521, 0)
                nPickedUp = nPickedUp + 1
                dataSet.bPicked = true
                SoundPlay2D("Gong")
                if nPickedUp == NUM_ORNAMENTS then
                    bObjectsCollected = true
                    F_ReturnOrnaments()
                end
                if nPickedUp == 2 then
                    F_ElfAttack()
                elseif nPickedUp == 4 then
                    F_ElfAttack2()
                end
            end
            CounterSetCurrent(nPickedUp)
            ItemSetCurrentNum(dataSet.id, 0)
        end
    end
end

function F_ReturnOrnaments()
    --print("F_ReturnOrnaments()")
    MissionObjectiveComplete(tObjectives[1])
    table.insert(tObjectives, MissionObjectiveAdd("3_01D_OBJ1_03"))
    TextPrint("3_01D_OBJ1_03", 5, 1)
    CounterMakeHUDVisible(false)
    RudyBlip = AddBlipForChar(Rudy, 2, 0, 1)
    while not (bReturnedRudy or bMissionOver) do
        Wait(0)
        F_CheckReturn()
    end
end

function F_CheckReturn()
    --print("F_CheckReturn()")
    if F_CheckDistance(gPlayer, Rudy) then
        for i, v in tObjectives do
            MissionObjectiveComplete(v)
        end
        bReturnedRudy = true
        CameraFade(1, 500)
        PlayerSetControl(0)
        table.insert(tObjectives, MissionObjectiveAdd("3_01D_OBJ2_01"))
        MissionTimerStop()
        F_ElfCleanup()
        F_Scene2()
    end
end

function F_CheckDistance(ped_id1, ped_id2)
    myBool = false
    local x1, y1, z1 = PedGetPosXYZ(ped_id1)
    local x2, y2, z2 = PedGetPosXYZ(ped_id2)
    local nDistance = DistanceBetweenCoords2d(x1, y1, x2, y2)
    if nDistance < 3.5 then
        myBool = true
    end
    return myBool
end

function F_Scene1()
    --print("F_Scene1")
    PedSetPosPoint(gPlayer, POINTLIST._3_01D_PSTART, 2)
    Rudy = PedCreatePoint(252, POINTLIST._3_01D_RUDYSTART)
    PedSetFlag(Rudy, 19, true)
    CameraFade(500, 1)
    TextPrint("3_01D_SCENE1", 5, 1)
    CameraSetFOV(50)
    CameraSetXYZ(492.5634, -117.63233, 6.968617, 491.74142, -117.06345, 6.941158)
    Wait(6000)
    CameraFade(500, 0)
    Wait(500)
end

function F_Scene2()
    --print("F_Scene2()")
    BlipRemove(RudyBlip)
    AreaLoadSpecialEntities("Rudy2", true)
    PlayCutsceneWithLoad("3-01DB", true)
end

function F_Dialogue1Cleanup()
    --print("F_Dialogue1Cleanup")
    tSantaTalk = nil
    for i = 1, 5 do
        tKidSet[1].speech1 = nil
    end
end

function F_CfgDialogue2()
    --print("F_CfgDialogue2")
    tSantaTalk2 = {
        { intro = 4,   outtro = 21 },
        { intro = 13,  outtro = nil },
        { intro = nil, outtro = nil },
        { intro = 3,   outtro = 10 },
        { intro = 12,  outtro = 40 }
    }
    tKidSet[1].speech2 = {
        { char = kidActive, dialogue = 68 },
        { char = Rudy,      dialogue = 30 },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = 69 },
        { char = Rudy,      dialogue = 41 },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = nil }
    }
    tKidSet[2].speech2 = {
        { char = kidActive, dialogue = 72 },
        { char = Rudy,      dialogue = 7 },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = 73 },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = nil },
        { char = Rudy,      dialogue = 8 },
        { char = kidActive, dialogue = nil }
    }
    tKidSet[3].speech2 = {
        { char = kidActive, dialogue = 44 },
        { char = kidActive, dialogue = nil },
        { char = Rudy,      dialogue = 26 },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = 45 },
        { char = kidActive, dialogue = nil },
        { char = Rudy,      dialogue = 33 },
        { char = kidActive, dialogue = nil }
    }
    tKidSet[4].speech2 = {
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = 63 },
        { char = kidActive, dialogue = 58 },
        { char = Rudy,      dialogue = 23 },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = 59 },
        { char = kidActive, dialogue = 64 },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = nil },
        { char = Rudy,      dialogue = 38 },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = 65 }
    }
    tKidSet[5].speech2 = {
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = 54 },
        { char = Rudy,      dialogue = 24 },
        { char = kidActive, dialogue = 135 },
        { char = Rudy,      dialogue = 32 },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = 49 },
        { char = kidActive, dialogue = 55 },
        { char = kidActive, dialogue = nil },
        { char = kidActive, dialogue = nil },
        { char = Rudy,      dialogue = 20 },
        { char = kidActive, dialogue = 50 },
        { char = kidActive, dialogue = 51 }
    }
end

function F_AnimString(string_passed, bool_kid)
    --print("F_ReturnString")
    local my_string
    if bool_kid then
        my_string = "/Global/3_01D/KidAnimations/" .. string_passed
    else
        my_string = "/Global/3_01D/Animations/" .. string_passed
    end
    return my_string
end

function F_CfgAnimations()
    --print("F_CfgAnimations")
    local GOOD_POSE = 1
    local KID_TALK = 2
    local SANTA_TALK = 3
    local KID_LISTEN_SMILE = 4
    local STRUGGLE = 5
    local MAKE_FACE1 = 6
    local MAKE_FACE2 = 7
    local ALMOST_GOOD_POSE1 = 8
    local ALMOST_GOOD_POSE2 = 9
    local SIDE_LOOK_SMILE = 10
    local SIDE_LOOK_FROWN = 11
    tSantaTalk = {
        { intro = 16,  outtro = nil },
        { intro = 17,  outtro = 18 },
        { intro = nil, outtro = nil },
        { intro = 15,  outtro = 27 },
        { intro = nil, outtro = 19 }
    }
    tKidSet[1] = {
        bPassed = false,
        bSecond = false,
        model = 69,
        sequence1 = {
            STRUGGLE,
            SANTA_TALK,
            SIDE_LOOK_SMILE,
            SIDE_LOOK_FROWN,
            STRUGGLE,
            KID_LISTEN_SMILE,
            SIDE_LOOK_FROWN,
            SIDE_LOOK_SMILE
        },
        speech1 = {
            { char = kidActive, dialogue = 66 },
            { char = Rudy,      dialogue = 28 },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = 67 },
            { char = Rudy,      dialogue = 22 },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = nil }
        },
        ParentSpeech = {
            Intro = { 79 },
            Fail = { 76, 77 },
            LastChance = { 80 },
            Hurry = { 78 },
            Behave = { 74, 75 },
            Nice = { 81, 82 },
            Pass = { 83 }
        }
    }
    tKidSet[2] = {
        bPassed = false,
        bSecond = false,
        model = 66,
        sequence1 = {
            KID_TALK,
            SANTA_TALK,
            GOOD_POSE,
            KID_TALK,
            ALMOST_GOOD_POSE2,
            GOOD_POSE,
            KID_LISTEN_SMILE,
            SIDE_LOOK_SMILE
        },
        speech1 = {
            { char = kidActive, dialogue = 70 },
            { char = Rudy,      dialogue = 11 },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = 71 },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = nil },
            { char = Rudy,      dialogue = 39 },
            { char = kidActive, dialogue = nil }
        },
        ParentSpeech = {
            Intro = { 89 },
            Fail = { 86, 87 },
            LastChance = { 90 },
            Hurry = { 88 },
            Behave = { 84, 85 },
            Nice = { 100, 101 },
            Pass = { 102 }
        }
    }
    tKidSet[3] = {
        bPassed = false,
        bSecond = false,
        model = 68,
        sequence1 = {
            KID_TALK,
            SIDE_LOOK_SMILE,
            SANTA_TALK,
            ALMOST_GOOD_POSE1,
            KID_TALK,
            SIDE_LOOK_SMILE,
            SANTA_TALK,
            SIDE_LOOK_SMILE
        },
        speech1 = {
            { char = kidActive, dialogue = 42 },
            { char = kidActive, dialogue = nil },
            { char = Rudy,      dialogue = 37 },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = 43 },
            { char = kidActive, dialogue = nil },
            { char = Rudy,      dialogue = 36 },
            { char = kidActive, dialogue = nil }
        },
        ParentSpeech = {
            Intro = { 108 },
            Fail = { 105, 106 },
            LastChance = { 109 },
            Hurry = { 107 },
            Behave = { 103, 104 },
            Nice = { 110, 111 },
            Pass = { 112 }
        }
    }
    tKidSet[4] = {
        bPassed = false,
        bSecond = false,
        model = 137,
        sequence1 = {
            SIDE_LOOK_FROWN,
            KID_TALK,
            MAKE_FACE1,
            KID_LISTEN_SMILE,
            SIDE_LOOK_FROWN,
            SIDE_LOOK_SMILE,
            MAKE_FACE1,
            KID_TALK,
            ALMOST_GOOD_POSE1,
            GOOD_POSE,
            SANTA_TALK,
            SIDE_LOOK_SMILE,
            KID_TALK
        },
        speech1 = {
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = 60 },
            { char = kidActive, dialogue = 56 },
            { char = Rudy,      dialogue = 35 },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = 57 },
            { char = kidActive, dialogue = 61 },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = nil },
            { char = Rudy,      dialogue = 34 },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = 62 }
        },
        ParentSpeech = {
            Intro = { 118 },
            Fail = { 115, 116 },
            LastChance = { 119 },
            Hurry = { 117 },
            Behave = { 113, 114 },
            Nice = { 120, 121 },
            Pass = { 122 }
        }
    }
    tKidSet[5] = {
        bPassed = false,
        bSecond = false,
        model = 138,
        sequence1 = {
            SIDE_LOOK_FROWN,
            KID_TALK,
            KID_LISTEN_SMILE,
            MAKE_FACE2,
            SANTA_TALK,
            SIDE_LOOK_SMILE,
            MAKE_FACE2,
            KID_TALK,
            ALMOST_GOOD_POSE1,
            GOOD_POSE,
            KID_LISTEN_SMILE,
            MAKE_FACE2,
            MAKE_FACE1
        },
        speech1 = {
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = 52 },
            { char = Rudy,      dialogue = 29 },
            { char = kidActive, dialogue = 134 },
            { char = Rudy,      dialogue = 0 },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = 46 },
            { char = kidActive, dialogue = 53 },
            { char = kidActive, dialogue = nil },
            { char = kidActive, dialogue = nil },
            { char = Rudy,      dialogue = 31 },
            { char = kidActive, dialogue = 49 },
            { char = kidActive, dialogue = 48 }
        },
        ParentSpeech = {
            Intro = { 128 },
            Fail = { 125, 126 },
            LastChance = { 129 },
            Hurry = { 127 },
            Behave = { 123, 124 },
            Nice = { 130, 131 },
            Pass = { 132 }
        }
    }
    tAnims[GOOD_POSE] = {
        SantaCycle = F_AnimString("SANTA_CYCLE", false),
        KidCycle = F_AnimString("KID_SMILE", true)
    }
    tAnims[ALMOST_GOOD_POSE1] = {
        SantaCycle = F_AnimString("SANTA_CYCLE", false),
        KidCycle = F_AnimString("KID_NEUTRAL", true)
    }
    tAnims[ALMOST_GOOD_POSE2] = {
        SantaCycle = F_AnimString("SANTA_CYCLE", false),
        KidCycle = F_AnimString("KID_ANGRY", true)
    }
    tAnims[KID_TALK] = {
        SantaCycle = F_AnimString("SANTA_LISTEN", false),
        KidCycle = F_AnimString("KID_TALK", true)
    }
    tAnims[SANTA_TALK] = {
        SantaCycle = F_AnimString("SANTA_TALK", false),
        KidCycle = F_AnimString("KID_LISTEN", true)
    }
    tAnims[KID_LISTEN_SMILE] = {
        SantaCycle = F_AnimString("SANTA_TALK", false),
        KidCycle = F_AnimString("KID_LISTEN_SMILE", true)
    }
    tAnims[STRUGGLE] = {
        SantaCycle = F_AnimString("SANTA_STRUGGLE", false),
        KidCycle = F_AnimString("KID_STRUGGLE", true)
    }
    tAnims[MAKE_FACE1] = {
        SantaCycle = F_AnimString("SANTA_ANNOYED", false),
        KidCycle = F_AnimString("KID_MAKEFACE1", true)
    }
    tAnims[MAKE_FACE2] = {
        SantaCycle = F_AnimString("SANTA_ANNOYED", false),
        KidCycle = F_AnimString("KID_MAKEFACE2", true)
    }
    tAnims[SIDE_LOOK_SMILE] = {
        SantaCycle = F_AnimString("SANTA_CYCLE2", false),
        KidCycle = F_AnimString("KID_SMILE_SIDE", true)
    }
    tAnims[SIDE_LOOK_FROWN] = {
        SantaCycle = F_AnimString("SANTA_CYCLE2", false),
        KidCycle = F_AnimString("KID_FROWN_SIDE", true)
    }
    PedSetActionTree(Rudy, "/Global/3_01D/", "Act/Conv/3_01D.act")
end

function F_GoodCamera()
    --print("F_GoodCamera")
    SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_CAMERA_GOOD", 0, "jumbo")
end

function F_GoodCameraPedro()
    --print("F_GoodCameraPedro")
    if Kid_Index == 1 and (Anim_Index == 3 or Anim_Index == 7) then
        SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_CAMERA_GOOD", 0, "jumbo")
    end
end

function F_RunAnimCycle()
    --print("F_RunAnimCycle")
    tKidSet[Kid_Index].bSecond = true
    PedSetActionNode(Rudy, tAnims[tKidSet[Kid_Index].sequence1[Anim_Index]].SantaCycle, "Act/Conv/3_01D.act")
    PedSetActionNode(kidActive, tAnims[tKidSet[Kid_Index].sequence1[Anim_Index]].KidCycle, "Act/Conv/3_01D.act")
    if tKidSet[Kid_Index].speech1[Anim_Index].dialogue ~= nil then
        if tKidSet[Kid_Index].speech1[Anim_Index].char == Rudy then
            SoundPlayScriptedSpeechEvent(Rudy, "M_3_01D", tKidSet[Kid_Index].speech1[Anim_Index].dialogue, "jumbo")
        else
            SoundPlayScriptedSpeechEvent(kidActive, "M_3_01D", tKidSet[Kid_Index].speech1[Anim_Index].dialogue, "jumbo")
        end
    end
end

function F_SetupCameraWork() -- ! Modified
    --print("F_SetupCameraWork()")
    F_CollectableCleanup()
    if PlayerIsInAnyVehicle() then
        local bike = VehicleFromDriver(gPlayer)
        PlayerDetachFromVehicle()
        VehicleDelete(bike)
        Wait(100)
    end
    CameraFade(1000, 1)
    PedSetPosPoint(Rudy, POINTLIST._3_01D_RUDYTHRONE, 2)
    PedSetPosPoint(gPlayer, POINTLIST._3_01D_JIMMYPHOTO, 2)
    AreaClearAllPeds()
    F_SetupLine()
    PedSetWeaponNow(gPlayer, 426, 1, false)
    Wait(100)
    CameraSetActive(2)
    PedSetFlag(gPlayer, 2, true)
    CameraSetFOV(30)
    PhotoShowExitString(false) -- Added this
    CameraSetRotationLimit(0, 0, -1, 1, 0)
    CameraAllowChange(false)
    PlayerSetControl(1)
    kidActive = PedCreatePoint(69, POINTLIST._3_01D_RUDYTHRONE)
    PedSetActionTree(kidActive, "/Global/3_01D/", "Act/Conv/3_01D.act")
    PedSetGrappleTarget(kidActive, Rudy)
    PedSetGrappleTarget(Rudy, kidActive)
    F_CfgAnimations()
    PlayerLockButtonInputsExcept(true, 12)
    F_SetupCameraWork = nil
end

function F_KidTransition()
    --print("F_KidTransition")
    if kidActive ~= nil then
        if tSantaTalk[Kid_Index].outtro ~= nil then
            SoundPlayScriptedSpeechEvent(Rudy, "M_3_01D", tSantaTalk[Kid_Index].outtro, "jumbo", true)
        end
        Wait(50)
        CameraFade(0, 250)
        PedSetActionNode(Rudy, "/Global/3_01D/Animations/SANTA_END", "Act/Conv/3_01D.act")
        PedSetActionNode(kidActive, "/Global/3_01D/KidAnimations/SANTA_END", "Act/Conv/3_01D.act")
        Wait(1600)
        LastKid = kidActive
        PedDelete(LastKid)
    end
    Kid_Index = Kid_Index + 1
    if not (5 < Kid_Index) or nPhotos == 5 then
    elseif bRoundTwo == false then
        bRoundTwo = true
        F_Dialogue1Cleanup()
        F_CfgDialogue2()
        tSantaTalk = nil
        Wait(100)
        tSantaTalk = tSantaTalk2
        Kid_Index = 1
        for i, dataSet in tKidSet do
            tKidSet[i].speech1 = nil
            tKidSet[i].speech1 = tKidSet[i].speech2
        end
    else
        bMissionFail = true
        PedSetFlag(gPlayer, 2, false)
        MissionFail(true, true, "3_01D_FAIL_04")
        bPhotosTaken = true
        CameraAllowChange(true)
        CameraSetActive(1)
        Wait(200)
        CameraFade(0, 2000)
        Wait(2000)
        CameraFade(1, 2000)
    end
    if not bPhotosTaken then
        while tKidSet[Kid_Index + 1] ~= nil and tKidSet[Kid_Index].bPassed do
            Kid_Index = Kid_Index + 1
        end
        --print("[RW] Kid Index = ")
        --print(Kid_Index)
        kidActive = PedCreatePoint(tKidSet[Kid_Index].model, POINTLIST._3_01D_LINE6)
        PedSetActionTree(kidActive, "/Global/3_01D/", "Act/Conv/3_01D.act")
    end
    Wait(500)
    if kidActive ~= nil and not bPhotosTaken then
        PedSetGrappleTarget(kidActive, Rudy)
        PedSetGrappleTarget(Rudy, kidActive)
        if tSantaTalk[Kid_Index].intro ~= nil then
            SoundPlayScriptedSpeechEvent(Rudy, "M_3_01D", tSantaTalk[Kid_Index].intro, "jumbo", true)
        end
        PedSetActionNode(Rudy, "/Global/3_01D/Animations/SANTA_START", "Act/Conv/3_01D.act")
        PedSetActionNode(kidActive, "/Global/3_01D/KidAnimations/SANTA_START", "Act/Conv/3_01D.act")
        Wait(150)
        PedSetPosPoint(kidActive, POINTLIST._3_01D_RUDYTHRONE, 2)
        while PedIsPlaying(Rudy, "/Global/3_01D/Animations/SANTA_START", false) do
            Wait(10)
        end
        if tSantaTalk[Kid_Index].intro ~= nil then
            Wait(1000)
        end
    end
end

function F_SetupLine()
    --print("F_SetupLine()")
    MomTalker = PedCreatePoint(80, POINTLIST._3_01D_MOTHER)
    PedSetFlag(MomTalker, 113, true)
end

function F_SetFaceOn()
    --[[
    print("F_SetFaceOn")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    print("[RW]: SMILE ON")
    ]]
    bGoodFace = true
end

function F_SetFaceOff()
    --[[
    print("F_SetFaceOff")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    print("[RW]: FROWN AGAIN")
    ]]
    bGoodFace = false
end

function F_tsize(tTable)
    --print("F_tsize")
    local counter = 0
    for i, v in tTable do
        counter = counter + 1
    end
    return counter
end

function LockStores(bLock)
    AreaSetDoorLocked("DT_tbusines_BikeShopDoor", bLock)
    AreaSetDoorLocked("DT_tbusines_ClothDoor", bLock)
    AreaSetDoorLocked("DT_tbusines_ComicShopDoor", bLock)
    AreaSetDoorLocked("DT_tbusines_GenShop1Door", bLock)
    AreaSetDoorLocked("DT_tbusines_GenShop2Door", bLock)
    AreaSetDoorLocked("DT_tbusiness_Barber", bLock)
    AreaSetDoorLocked("DT_tpoor_Barber", bLock)
end
