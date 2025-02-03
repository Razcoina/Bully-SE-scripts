ImportScript("Library\\LibPlayer.lua")
local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bRecruitedPete = false
local bLoadedGary = false
local bGarySpeech = false
local bReleaseBullies = false
local gMissionFailMessage = 0

function MissionSetup()
    --print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
    MissionDontFadeIn()
    DATLoad("1_11X1.DAT", 2)
    DATInit()
    if shared.gPetey and PedIsValid(shared.gPetey) then
        PedDelete(shared.gPetey)
        shared.gPetey = nil
    end
    if shared.gGary and PedIsValid(shared.gGary) then
        PedDelete(shared.gGary)
        shared.gGary = nil
    end
    if shared._1_11X1entereddorm then
        if AreaGetVisible() == 14 then
            CameraFade(500, 0)
            Wait(500)
            PlayerSetPosPoint(POINTLIST._1_11X1_SPAWNPLAYERDOWNSTAIRS)
            CameraFade(500, 1)
            Wait(500)
        else
            AreaTransitionPoint(14, POINTLIST._1_11X1_SPAWNPLAYERDOWNSTAIRS)
        end
    end
    --print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
    --print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
    shared.PlayerInClothingManager = nil
    shared.finishedFirstClothing = false
    if not bMissionPassed then
        if PedGetWeapon(gPlayer) == 411 then
            PedDestroyWeapon(gPlayer, 411)
        end
        shared.cm_lockHead = false
        shared.cm_lockTorso = false
        shared.cm_lockLWrist = false
        shared.cm_lockRWrist = false
        shared.cm_lockLegs = false
        shared.cm_lockFeet = false
        shared.cm_lockOutfit = false
        L_PlayerClothingRestore()
        SoundStopInteractiveStream()
        shared.b1x11_failed = true
        PedSetActionNode(gPlayer, "/Global/1_11X1/empty", "Act/Conv/1_11X1.act")
        local tempX, tempY, tempZ = GetPointList(POINTLIST._BOYSDORM_1_11_RESPAWNPLAYER)
        PlayerSetPosSimple(tempX, tempY, tempZ)
        PedFaceHeading(gPlayer, 315, 0)
        CameraReset()
    end
    if bMissionPassed then
        ClothingGivePlayerOutfit("Halloween")
        shared._1_11X1entereddorm = nil
        shared.g1_11X1JustFinished = true
        AreaEnsureSpecialEntitiesAreCreated()
    end
    DATUnload(2)
    DATInit()
    EnablePOI()
    UnLoadAnimationGroup("3_04WrongPtTown")
    SoundRestartPA()
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    collectgarbage()
    MissionDontFadeInAfterCompetion()
    --print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
    --print("()xxxxx[:::::::::::::::> [start] main()")
    F_SetupMission()
    F_Stage2()
    if bMissionFailed then
        TextPrint("1_11X1_EMPTY", 1, 1)
        SoundPlayMissionEndMusic(false, 10)
        if gMissionFailMessage == 1 then
            MissionFail(true, true, "1_11X1_FAIL_01")
        else
            MissionFail(true)
        end
    elseif bMissionPassed then
        CameraFade(1, 0)
        MissionSucceed(false, false, false)
    end
    --print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_TableInit()
    --print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
    pedGary = {
        spawn = POINTLIST._1_11X1_SPAWNGARYBED,
        element = 1,
        model = 160
    }
    pedPete = {
        spawn = POINTLIST._1_11X1_SPAWNPETE,
        element = 1,
        model = 165
    }
    pedBully01 = {
        spawn = POINTLIST._1_11X1_SPAWNLAUGH01,
        element = 1,
        model = 170
    }
    pedBully02 = {
        spawn = POINTLIST._1_11X1_SPAWNLAUGH02,
        element = 1,
        model = 75
    }
    --print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_SetupMission()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupMission()")
    F_TableInit()
    AreaDisableAllPatrolPaths()
    shared.gHalloweenActive = true
    F_SetupHallowenPeds(false)
    SoundStopPA()
    AreaLoadSpecialEntities("Halloween3", true)
    AreaEnsureSpecialEntitiesAreCreated()
    LoadPedModels({ 160 })
    L_PlayerClothingBackup()
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupMission()")
end

function F_Stage2()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage2()")
    F_Stage2_Setup()
    F_Stage2_Loop()
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage2()")
end

function F_Stage2_Setup()
    --print("()xxxxx[:::::::::::::::> [start] F_Stage2_Setup()")
    SoundPlayInteractiveStream("MS_HalloweenLow.rsm", 0.5)
    SoundSetMidIntensityStream("MS_HalloweenMid.rsm", 0.6)
    SoundSetHighIntensityStream("MS_HalloweenHigh.rsm", 1)
    shared.lockClothingManager = true
    ClothingSetPlayerOutfit("Halloween")
    ClothingBuildPlayer()
    BlipRemove(blipObjective01)
    blipObjective02 = BlipAddPoint(POINTLIST._1_11X1_BLIPEXIT, 0, 1, 1, 0)
    PlayCutsceneWithLoad("1-11", true, false)
    PlayerSetPosPoint(POINTLIST._1_11X1_SPAWNPLAYER)
    Wait(100)
    PedRequestModel(165)
    PedRequestModel(170)
    PedRequestModel(75)
    WeaponRequestModel(411)
    WeaponRequestModel(372)
    WeaponRequestModel(397)
    LoadAnimationGroup("3_04WrongPtTown")
    AreaLoadSpecialEntities("Halloween3", true)
    F_SetupGary()
    F_SetupPete()
    F_SetupLaughers()
    if shared.gHCriminalsActive == false then
        shared.gHCriminalsActive = true
    end
    ClothingSetPlayerOutfit("Halloween")
    ClothingBuildPlayer()
    F_ToggleArcadeScreens()
    CameraReset()
    CameraFade(500, 1)
    Wait(500)
    TextPrint("1_11X1_MOBJ02", 4, 1)
    gObjective02 = MissionObjectiveAdd("1_11X1_MOBJ02")
    SoundPlayScriptedSpeechEvent(shared.gGary, "M_1_11X1", 7)
    --print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
    while bLoop do
        Stage2_Objectives()
        if bMissionPassed or bMissionFailed then
            break
        end
        Wait(0)
    end
end

function Stage2_Objectives()
    if not bReleaseBullies and PlayerIsInTrigger(TRIGGER._1_11X1_BULLIES) then
        PedSetActionNode(pedBully01.id, "/Global/1_11X1/empty", "Act/Conv/1_11X1.act")
        PedSetActionNode(pedBully02.id, "/Global/1_11X1/empty", "Act/Conv/1_11X1.act")
        PedMakeAmbient(pedBully01.id)
        PedMakeAmbient(pedBully02.id)
        bReleaseBullies = true
    end
    if not bRecruitedPete and not PedIsDead(shared.gGary) and PlayerIsInTrigger(TRIGGER._1_11X1_PETE) then
        CreateThread("T_PeteText")
        bRecruitedPete = true
    end
    if not bMissionPassed and AreaGetVisible() == 0 then
        PedMakeAmbient(shared.gGary)
        PedMakeAmbient(shared.gPetey)
        bMissionPassed = true
    end
end

function F_SetupGary()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupGary()")
    shared.gGary = PedCreatePoint(pedGary.model, pedGary.spawn, pedGary.element)
    PedSetInvulnerable(shared.gGary, false)
    PedMakeTargetable(shared.gGary, true)
    PedSetActionNode(shared.gGary, "/Global/1_11X1/empty", "Act/Conv/1_11X1.act")
    PedSetPosPoint(shared.gGary, POINTLIST._1_11X1_SPAWNGARY)
    PedRecruitAlly(gPlayer, shared.gGary)
    PedSetWeapon(shared.gGary, 411, 1)
    PedSetMissionCritical(shared.gGary, true, F_MissionCriticalGary, false)
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupGary()")
end

function F_SetupPete()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupPete()")
    shared.gPetey = PedCreatePoint(pedPete.model, pedPete.spawn, pedPete.element)
    PedOverrideStat(shared.gPetey, 6, 75)
    ExecuteActionNode(shared.gPetey, "/Global/1_11X1/Animations/PeteCan/Cycle", "Act/Conv/1_11X1.act")
    PedSetInvulnerable(shared.gPetey, true)
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupPete()")
end

function F_SetupLaughers()
    --print("()xxxxx[:::::::::::::::> [start] F_SetupLaughers()")
    pedBully01.id = PedCreatePoint(pedBully01.model, pedBully01.spawn, pedBully01.element)
    PedSetActionNode(pedBully01.id, "/Global/1_11X1/Animations/Laugh_Shove/Laugh", "Act/Conv/1_11X1.act")
    pedBully02.id = PedCreatePoint(pedBully02.model, pedBully02.spawn, pedBully02.element)
    PedSetActionNode(pedBully02.id, "/Global/1_11X1/Animations/LaughCyclic/LaughCyclic", "Act/Conv/1_11X1.act")
    --print("()xxxxx[:::::::::::::::> [finish] F_SetupLaughers()")
end

function T_MissionStartText()
    --print("()xxxxx[:::::::::::::::> [start] T_MissionStartText()")
    Wait(4000)
    TextPrint("1_11X1_MOBJ01", 4, 1)
    gObjective01 = MissionObjectiveAdd("1_11X1_MOBJ01")
    --print("()xxxxx[:::::::::::::::> [finish] T_MissionStartText()")
end

function T_PeteText()
    --print("()xxxxx[:::::::::::::::> [start] T_PeteText()")
    SoundPlayScriptedSpeechEventWrapper(shared.gPetey, "M_1_11X1", 8)
    PedSetActionNode(shared.gPetey, "/Global/1_11X1/Animations/PeteCan/GetOut", "Act/Conv/1_11X1.act")
    PedSetInvulnerable(shared.gPetey, false)
    Wait(500)
    if F_PedExists(shared.gPetey) then
        PedRecruitAlly(shared.gGary, shared.gPetey)
    end
    if F_PedExists(shared.gPetey) then
        F_WaitForSpeech(shared.gPetey)
    end
    if F_PedExists(shared.gGary) then
        SoundPlayScriptedSpeechEventWrapper(shared.gGary, "M_1_11X1", 9)
    end
    if F_PedExists(shared.gGary) then
        F_WaitForSpeech(shared.gGary)
    end
    if F_PedExists(shared.gPetey) then
        SoundPlayScriptedSpeechEventWrapper(shared.gPetey, "M_1_11X1", 10)
    end
    if F_PedExists(shared.gPetey) then
        F_WaitForSpeech(shared.gPetey)
    end
    if F_PedExists(shared.gGary) then
        SoundPlayScriptedSpeechEventWrapper(shared.gGary, "M_1_11X1", 6)
    end
    --print("()xxxxx[:::::::::::::::> [finish] T_PeteText()")
end

function F_MissionCriticalGary()
    --print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalGary()")
    gMissionFailMessage = 1
    bMissionFailed = true
    --print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalGary()")
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
