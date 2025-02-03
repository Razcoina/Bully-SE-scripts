local bLoop = true
local countMax = 5
local bAcquired = false

function MissionSetup()
    print("***************************************** 3_09 Mission setup *************************************")
    CameraFade(0, 0)
    DATLoad("3_09.DAT", 2)
    DATInit()
    LoadActionTree("Act/Conv/3_09.act")
    LoadAnimationGroup("1_G1_TheDiary")
    LoadAnimationGroup("1_06ALittleHelp")
    PlayerSetControl(0)
    LoadPedModels({
        106,
        183,
        55,
        151,
        131,
        132
    })
    LoadModels({ 521 })
    PlayCutsceneWithLoad("3-R05A", true)
    AreaTransitionPoint(2, POINTLIST._3_09_PLAYSTART)
end

function MissionCleanup()
    UnLoadAnimationGroup("1_G1_TheDiary")
    UnLoadAnimationGroup("1_06ALittleHelp")
    F_ResetControls()
    DATUnload(2)
end

function main()
    print("*************************** 3_09 main ******************************************")
    PlayerSetControl(1)
    F_ArrangePickup()
    while bAcquired == false do
        F_CheckAssistant()
        Wait(30)
    end
    if not bMissionFail then
        F_Mission()
    end
end

function F_CheckAssistant()
    --print("F_CheckAssistant")
    if MissionTimerHasFinished() then
        SoundPlayMissionEndMusic(false, 8)
        MissionFail(true, true)
        bMissionFail = true
        bLoop = false
        bAcquired = true
    end
    if F_CheckDistance(assistant, gPlayer) and not PlayerIsInAnyVehicle() and PedGetWeapon(gPlayer) ~= 437 then
        PlayerSetControl(0)
        MissionTimerStop()
        BlipRemove(AssistantBlip)
        SoundPlayScriptedSpeechEvent(gPlayer, "M_3_R05A", 1, "speech")
        Wait(1000)
        PedSetGrappleTarget(gPlayer, assistant)
        PedSetGrappleTarget(assistant, gPlayer)
        PedClearObjectives(gPlayer)
        MissionObjectiveComplete(objId_pickup)
        PedFaceObject(gPlayer, assistant, 2, 0)
        PedFaceObject(assistant, gPlayer, 3, 0)
        PedLockTarget(assistant, gPlayer, 3)
        Wait(500)
        PedSetActionNode(assistant, "/Global/3_09/Anims2/Give/GivePackage_3_09", "Act/Conv/3_09.act")
        if PedIsPlaying(assistant, "/Global/3_09/Anims2/Give/GivePackage_3_09", true) then
            while PedIsPlaying(assistant, "/Global/3_09/Anims2/Give/GivePackage_3_09", true) do
                Wait(0)
            end
        end
        Wait(1000)
        bAcquired = true
        PedMakeAmbient(assistant, false)
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

function F_ArrangePickup()
    --print("F_ArrangePickup")
    assistant = PedCreatePoint(11, POINTLIST._3_09_ASSISTANT, 1)
    PedSetInvulnerable(assistant, true)
    AssistantBlip = AddBlipForChar(assistant, 2, 0, 4)
    objId_pickup = MissionObjectiveAdd("3_R05B_ASSISTANT", 1)
    TextPrint("3_R05B_ASSISTANT", 5, 1)
    MissionTimerStart(120)
end

function F_Mission()
    print("************************* F_MissionOne ***************************************")
    gRichM01 = PedCreatePoint(183, POINTLIST._3_09_PAK01, 1)
    gRichM02 = PedCreatePoint(55, POINTLIST._3_09_PAK02, 1)
    gRichM03 = PedCreatePoint(151, POINTLIST._3_09_PAK03, 1)
    gRichM04 = PedCreatePoint(131, POINTLIST._3_09_PAK04, 1)
    gRichM05 = PedCreatePoint(132, POINTLIST._3_09_PAK05, 1)
    RichM01_blip = AddBlipForChar(gRichM01, 12, 17, 4)
    RichM02_blip = AddBlipForChar(gRichM02, 12, 17, 4)
    RichM03_blip = AddBlipForChar(gRichM03, 12, 17, 4)
    RichM04_blip = AddBlipForChar(gRichM04, 12, 17, 4)
    RichM05_blip = AddBlipForChar(gRichM05, 12, 17, 4)
    F_SetGiftReceiver(gRichM01)
    F_SetGiftReceiver(gRichM02)
    F_SetGiftReceiver(gRichM03)
    F_SetGiftReceiver(gRichM04)
    F_SetGiftReceiver(gRichM05)
    CameraFade(500, 1)
    Wait(500)
    TextPrint("3_R05B_MOBJ_01", 5, 1)
    objId = MissionObjectiveAdd("3_R05B_MOBJ_02", 1)
    MissionObjectiveUpdateParam(objId, 1, countMax)
    Wait(500)
    bObj1Completed = false
    bObj2Completed = false
    bObj3Completed = false
    bObj4Completed = false
    bObj5Completed = false
    F_ResetControls()
    MissionTimerStart(300)
    Wait(1000)
    F_SetPackageCounter(countMax)
    while bLoop do
        Wait(0)
        if MissionTimerHasFinished() then
            SoundPlayMissionEndMusic(false, 8)
            MissionFail(true, true)
            bMissionFail = true
            bLoop = false
        end
        if not bObj1Completed then
            bObj1Completed = F_CheckReceiver(gRichM01, RichM01_blip)
        end
        if not bObj2Completed then
            bObj2Completed = F_CheckReceiver(gRichM02, RichM02_blip)
        end
        if not bObj3Completed then
            bObj3Completed = F_CheckReceiver(gRichM03, RichM03_blip)
        end
        if not bObj4Completed then
            bObj4Completed = F_CheckReceiver(gRichM04, RichM04_blip)
        end
        if not bObj5Completed then
            bObj5Completed = F_CheckReceiver(gRichM05, RichM05_blip)
        end
    end
    if bMissionFail == nil then
        MissionTimerStop()
        BackToChemClass()
    end
end

function F_CheckReceiver(dude, dude_blip)
    local x, y, z = PedGetPosXYZ(dude)
    if PlayerIsInAreaXYZ(x, y, z, 2, 0) and not PlayerIsInAnyVehicle() and PedGetWeapon(gPlayer) ~= 437 then
        BlipRemove(dude_blip)
        F_ResetReceiver(dude)
        return true
    end
end

function F_HitReceiver(victim, attacker)
    if attacker == gPlayer then
        bMissionFail = true
        MissionFail(false, true, "3_R05B_FAIL_02")
    end
end

function F_SetGiftReceiver(dude)
    PedIgnoreStimuli(dude, true)
    PedSetStationary(dude, true)
    PedSetMissionCritical(dude, true, F_MissionFailed, true)
    RegisterPedEventHandler(dude, 0, F_HitReceiver)
end

function F_ResetReceiver(dude)
    PlayerSetControl(0)
    PedSetGrappleTarget(dude, gPlayer)
    PedSetGrappleTarget(gPlayer, dude)
    PedClearObjectives(dude)
    PedFaceObject(gPlayer, dude, 2, 0)
    PedFaceObject(dude, gPlayer, 3, 0)
    PedLockTarget(gPlayer, dude, 3)
    Wait(500)
    PedSetActionNode(gPlayer, "/Global/3_09/Anims/Give/GivePackage_3_09", "Act/Conv/3_09.act")
    if PedIsPlaying(gPlayer, "/Global/3_09/Anims/Give/GivePackage_3_09", true) then
        while PedIsPlaying(gPlayer, "/Global/3_09/Anims/Give/GivePackage_3_09", true) do
            Wait(0)
        end
    end
    PlayerSetControl(1)
    CameraReset()
    CameraReturnToPlayer()
    PedMakeAmbient(dude, false)
    PedIgnoreStimuli(dude, false)
    PedSetStationary(dude, false)
    PedSetMissionCritical(dude, false)
    F_DropAPackage()
end

function F_SetPackageCounter(cMax)
    CounterClearText()
    CounterSetCurrent(0)
    CounterSetMax(cMax)
    CounterSetIcon("package", "package_x")
    CounterMakeHUDVisible(true)
end

function F_DropAPackage()
    CounterIncrementCurrent(1)
    MissionObjectiveUpdateParam(objId, 1, CounterGetMax() - CounterGetCurrent())
    Wait(10)
    TextAddParamNum(CounterGetMax() - CounterGetCurrent())
    TextPrint("3_R05B_MOBJ_02", 5, 1)
    if CounterGetCurrent() == CounterGetMax() then
        bLoop = false
        F_ClearPackageIcon()
    end
end

function F_ClearPackageIcon()
    MissionObjectiveRemove(objId)
    objId = MissionObjectiveAdd("3_R05B_MOBJ_01")
    MissionObjectiveComplete(objId)
    TextPrint("3_R05B_MOBJ_03", 5, 1)
    objId = MissionObjectiveAdd("3_R05B_MOBJ_03")
    Wait(1000)
    CounterMakeHUDVisible(false)
    CounterSetMax(0)
    CounterSetCurrent(0)
    CounterClearIcon()
end

function BackToChemClass()
    gChem_blip = BlipAddPoint(POINTLIST.CLASS_CHEM, 0, 1, 1, 7)
    bLoop = true
    AreaLoadSpecialEntities("delivery", true)
    while bLoop do
        Wait(0)
        local x, y, z = GetPointList(POINTLIST.CLASS_CHEM)
        if PlayerIsInAreaXYZ(x, y, z, 1.5, 0) then
            BlipRemove(gChem_blip)
            bLoop = false
        end
    end
    F_MissionEnd()
end

function F_MissionEnd()
    PedDelete(gRichM01)
    PedDelete(gRichM02)
    PedDelete(gRichM03)
    PedDelete(gRichM04)
    PedDelete(gRichM05)
    Wait(200)
    PlayCutsceneWithLoad("3-R05B", true)
    AreaLoadSpecialEntities("delivery", false)
    AreaTransitionPoint(2, POINTLIST._3_09_PLAYSTART)
    PlayerSetControl(0)
    CameraReset()
    CameraReturnToPlayer()
    CameraFade(500, 1)
    Wait(500)
    SoundPlayMissionEndMusic(true, 10)
    MissionSucceed(false, false, false)
    SoundPlayMissionEndMusic(true, 10)
    MinigameSetCompletion("M_PASS", true, 5000)
end

function F_KillControls()
    DisablePunishmentSystem(true)
    PauseGameClock()
    CameraSetWidescreen(true)
    PlayerSetControl(0)
end

function F_ResetControls()
    DisablePunishmentSystem(false)
    UnpauseGameClock()
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    ButtonHistoryIgnoreController(false)
    PedLockTarget(gPlayer, -1)
    AreaRevertToDefaultPopulation()
    SoundStopInteractiveStream()
    SoundEnableInteractiveMusic(true)
    PlayerWeaponHudLock(false)
    CameraAllowChange(true)
    PlayerIgnoreTargeting(false)
end
