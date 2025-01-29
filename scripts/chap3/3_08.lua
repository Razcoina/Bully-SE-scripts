--[[ Changes to this file:
    * Modified function MissionSetup, may require testing
]]

ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPed.lua")
local gMissionRunning = true
local gDestinationBlip, gMissionStage
local gMissionRunning = "running"
local gMissionObjectives = {}
local bJimmyReachedDest = false
local gSecretary
local bStartSecNIS = false
local present
local gPAAnnouncementTimer = 0
local bGetOutOfBed = false
local gCurrentArea
local bDebug = false
local bPlayerGoToPrincipal = false
local gCurrentArea
local gMissionTimer = 0

function MissionSetup() -- ! Modified
    MissionDontFadeIn()
    MissionSurpressMissionNameText()
    LoadAnimationGroup("Try_Clothes")
    LoadAnimationGroup("MINI_Lock")
    LoadAnimationGroup("NIS_3_08")
    PedSetUniqueModelStatus(59, -1)
    DATLoad("PriOffice.DAT", 2) -- Added this
    DATLoad("3_08.DAT", 2)
    DATInit()
    shared.gPrincipalCheck = false
    LoadPedModels({ 59 })
    LoadWeaponModels({ 436 })
    LoadActionTree("Act/Conv/3_08.act")
    AreaActivatePopulationTrigger(TRIGGER._3_08_SCHOOLPOP)
end

function main()
    F_SecretarySetup()
    F_StartNIS()
    PedSetActionNode(gPlayer, "/Global/3_08/NewSweater", "Act/Conv/3_08.act")
    while PedIsPlaying(gPlayer, "/Global/3_08/NewSweater", false) do
        Wait(0)
    end
    CameraSetWidescreen(false)
    ClockSet(8, 30)
    MissionSucceed(false, false, false)
end

function MissionCleanup()
    AreaDeactivatePopulationTrigger(TRIGGER._3_08_SCHOOLPOP)
    AreaRevertToDefaultPopulation()
    UnpauseGameClock()
    PedMakeAmbient(gSecretary)
    shared.gSecretaryID = gSecretary
    CameraSetWidescreen(false)
    UnLoadAnimationGroup("Try_Clothes")
    UnLoadAnimationGroup("MINI_Lock")
    UnLoadAnimationGroup("NIS_3_08")
    DATUnload(2)
    shared.gPrincipalCheck = true
end

function F_SecretarySetup()
    gSecretary = PedCreatePoint(59, POINTLIST._SECRETARY)
    L_PedLoad("secretary", {
        {
            id = gSecretary,
            bNISPed = true,
            cbAttacked = F_FireSecretaryNIS
        }
    })
    CreateThread("T_PedMonitor")
    PedSetEmotionTowardsPed(gSecretary, gPlayer, 7)
    PedFollowPath(gSecretary, PATH._SECRETARYOFFICEPATH, 2, 0)
end

function F_FireSecretaryNIS()
    if bStartSecNIS == false then
        bStartSecNIS = true
    end
end

function F_StartNIS()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PlayerSetControl(0)
    CameraFade(500, 0)
    Wait(500)
    present = PickupCreatePoint(436, POINTLIST._3_08_PRESENT, 1, 230, "PermanentButes")
    F_MakePlayerSafeForNIS(true)
    SoundDisableSpeech_ActionTree()
    PedSetInvulnerable(gSecretary, true)
    PedClearObjectives(gSecretary)
    PlayerSetPunishmentPoints(0)
    AreaClearAllPeds()
    TextPrintString("", 2, 1)
    PlayerUnequip()
    while WeaponEquipped() do
        Wait(0)
    end
    CameraSetWidescreen(true)
    if gSecretary == nil then
        F_SecretarySetup()
    end
    PlayerSetPosPoint(POINTLIST._3_08_DESTINATION, 1)
    --print("+====>>> gSecretary: ", gSecretary)
    PedStop(gSecretary)
    PedClearObjectives(gSecretary)
    --print("+====>>> gSecretary: ", gSecretary)
    PedSetPosPoint(gSecretary, POINTLIST._3_08_DNISPOS, 1)
    CameraSetFOV(80)
    CameraSetXYZ(-630.6381, -290.56006, 7.530675, -631.4325, -290.01364, 7.265559)
    CameraFade(500, 1)
    F_XmasNISCore()
    CameraFade(500, 0)
    Wait(500)
    if present then
        PickupDelete(present)
        present = nil
    end
    SoundEnableSpeech_ActionTree()
    ClothingPlayerOwns("SP_XmsSweater", 1)
    ClothingGivePlayer("SP_XmsSweater", 1)
    ClothingSetPlayerOutfit("Uniform")
    ClothingSetPlayer(1, "SP_XmsSweater")
    ClothingBuildPlayer()
    F_MakePlayerSafeForNIS(false)
    PedStop(gPlayer)
    PedClearObjectives(gPlayer)
    PlayerSetControl(1)
    PlayerSetPosPoint(POINTLIST._3_08_AFTERPRES, 1)
    CameraReset()
    CameraReturnToPlayer()
    Wait(100)
    PlayerFaceHeadingNow(180)
    CameraFade(500, 1)
    Wait(500)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
end

function F_XmasNISCore()
    local bSkip = false
    PedFollowPath(gPlayer, PATH._3_08_JNISPATH, 0, 0, CB_JimmyHitNode)
    if WaitSkippable(500) then
        PedStop(gPlayer)
        PedClearObjectives(gPlayer)
        return
    end
    while not bJimmyReachedDest do
        if WaitSkippable(1) then
            bSkip = true
            break
        end
    end
    if bSkip then
        return
    end
    CameraSetFOV(40)
    CameraSetXYZ(-632.56635, -284.8601, 7.57797, -632.9278, -285.75604, 7.320108)
    PedSetActionNode(gPlayer, "/Global/3_08/WaveAtSecretary/WaveAtSecretary_Child", "Act/Conv/3_08.act")
    SoundPlayScriptedSpeechEvent(gPlayer, "M_3_08", 2, "generic")
    while SoundSpeechPlaying(gPlayer) do
        if WaitSkippable(1) then
            bSkip = true
            break
        end
    end
    if bSkip then
        return
    end
    CameraSetFOV(40)
    CameraSetXYZ(-632.7018, -291.1923, 7.309863, -633.0144, -290.25113, 7.181806)
    PedStop(gSecretary)
    PedFaceObject(gSecretary, gPlayer, 3, 1)
    Wait(200)
    if WaitSkippable(250) then
        return
    end
    PedSetActionNode(gSecretary, "/Global/3_08/SecretaryGetUp/GetUp", "Act/Conv/3_08.act")
    SoundPlayScriptedSpeechEvent(gSecretary, "M_3_08", 1, "generic")
    while SoundSpeechPlaying(gSecretary) do
        if WaitSkippable(1) then
            bSkip = true
            break
        end
    end
    if bSkip then
        return
    end
    PedStop(gSecretary)
    PedFaceObject(gSecretary, gPlayer, 3, 1)
    if WaitSkippable(250) then
        return
    end
    PedSetActionNode(gSecretary, "/Global/3_08/GiveJimmyGift/GiveJimmyGift", "Act/Conv/3_08.act")
    SoundPlayScriptedSpeechEvent(gSecretary, "M_3_08", 3, "generic")
    while SoundSpeechPlaying(gSecretary) do
        if WaitSkippable(1) then
            bSkip = true
            break
        end
    end
    if bSkip then
        return
    end
    CameraSetFOV(40)
    CameraSetXYZ(-632.6774, -286.57837, 7.323637, -633.0524, -287.4846, 7.128572)
    PedSetActionNode(gPlayer, "/Global/3_08/JimmyGetGift/JimmyGetGift", "Act/Conv/3_08.act")
    SoundPlayScriptedSpeechEvent(gPlayer, "M_3_08", 4, "generic")
    while SoundSpeechPlaying(gPlayer) do
        if WaitSkippable(1) then
            bSkip = true
            break
        end
    end
    if bSkip then
        return
    end
    CameraSetFOV(40)
    CameraSetXYZ(-632.7018, -291.1923, 7.309863, -633.0144, -290.25113, 7.181806)
    PedSetActionNode(gSecretary, "/Global/3_08/OpenGift/OpenGift", "Act/Conv/3_08.act")
    SoundPlayScriptedSpeechEvent(gSecretary, "M_3_08", 5, "generic")
    while SoundSpeechPlaying(gSecretary) do
        if WaitSkippable(1) then
            bSkip = true
            break
        end
    end
    if bSkip then
        return
    end
end

function CB_JimmyHitNode(pedId, pathId, nodeId)
    if nodeId == PathGetLastNode(pathId) then
        bJimmyReachedDest = true
    end
end

function CB_SecHitNode(pedId, pathId, nodeId)
    if nodeId == PathGetLastNode(pathId) then
        bSecretaryReachedDest = true
    end
end

function F_MissionFail()
    gMissionRunning = "secretary"
end

function F_PlayerGetOutOfBed()
    --print("WTF???!?!?!")
    if bGetOutOfBed then
        return 1
    end
    return 0
end
