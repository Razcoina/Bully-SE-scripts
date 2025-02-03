local gActFile = "Act/Conv/2_03.act"

function F_PlayerHasAquaberrySweater()
    local shirtMI = ObjectNameToHashID("R_Sweater1")
    local shirt2MI = ObjectNameToHashID("R_Sweater5")
    local playerShirtMI = ClothingGetPlayer(1)
    return playerShirtMI == shirtMI or playerShirtMI == shirt2MI
end

local bHasSweater = F_PlayerHasAquaberrySweater()
local bGatesOpened = false
local mission_running = true
local bMissionSuccess = false
local gFailMessage
local enemyTable = {}
local enemyModels = {}
local bHasKey = false
local bKeyMasterFleeing = false
local gTad, gKeyMaster1, gKeyMaster2, gObjective
local bGotKey = false
local bKeyDropped = false
local monitor_ready = false
local gObjective
local eggs_to_tad = false
local tad_blipped = false
local tad_blip, gate1Blip, gate2Blip, TRICH_TADGATES01, TRICH_TADGATES
local bGatesOpened = false
local egg_hint_done = false
local thread_T_Egg_Hint, gate_key, b_key, gWindowEggers
local gInfiniteEggers = {}

function MissionSetup()
    if bHasSweater then
        --print(">>>[RUI]", "Has Sweater")
        MissionDontFadeIn()
        CameraFade(FADE_OUT_TIME, 0)
        Wait(FADE_OUT_TIME)
        DATLoad("2_03.DAT", 2)
        DATInit()
        mission_running = true
        if PlayerGetMoney() < 150 then
            PlayerSetMoney(150)
        end
    else
        MissionSurpressMissionNameText()
        --print(">>>[RUI]", "No Sweater")
    end
end

function MissionInit()
    --print(">>>[RUI]", "++MissionInit")
    enemyModels = {
        30,
        35,
        32,
        34,
        40
    }
    LoadModels(enemyModels)
    LoadModels({ 362, 494 })
    LoadWeaponModels({ 312 })
    TRICH_TADGATES01 = ObjectNameToHashID("TRICH_TADGATES01")
    TRICH_TADGATES = ObjectNameToHashID("TRICH_TADGATES")
    TadGroupCreate(1)
end

function main()
    if bHasSweater then
        CS_TadAssignsMission()
        Wait(600)
        Stage_GetEggsInit()
        while mission_running do
            if MissionStageRun then
                MissionStageRun()
            end
            Wait(0)
        end
        if bMissionSuccess then
            Wait(1000)
            CameraSetWidescreen(true)
            SoundDisableSpeech_ActionTree()
            SetFactionRespect(5, GetFactionRespect(5) - 10)
            TextPrintString("", 1, 1)
            MinigameSetCompletion("M_PASS", true, 0, "2_03_UNLOCK")
            SoundPlayMissionEndMusic(true, 10)
            Wait(500)
            MinigameAddCompletionMsg("MRESPECT_PM10", 1)
            while MinigameIsShowingCompletion() do
                Wait(0)
            end
            MissionSucceed(false, false, false)
        else
            SoundPlayMissionEndMusic(false, 10)
            if gFailMessage then
                MissionFail(true, true, gFailMessage)
            else
                MissionFail(true, true)
            end
            ForceMissionAvailable("2_03")
        end
    else
        TextPrint("BOX_SWEATER", 5, 1)
        MissionFail(false, false)
    end
end

function SetupCoverPoints()
    local table = {
        {
            point = POINTLIST._2_03_CP_01
        },
        {
            point = POINTLIST._2_03_CP_02
        },
        {
            point = POINTLIST._2_03_CP_03
        },
        {
            point = POINTLIST._2_03_CP_04
        },
        {
            point = POINTLIST._2_03_CP_05
        },
        {
            point = POINTLIST._2_03_CP_06
        },
        {
            point = POINTLIST._2_03_CP_07
        },
        {
            point = POINTLIST._2_03_CP_08
        },
        {
            point = POINTLIST._2_03_CP_09
        },
        {
            point = POINTLIST._2_03_CP_10
        },
        {
            point = POINTLIST._2_03_CP_11
        },
        {
            point = POINTLIST._2_03_CP_12
        },
        {
            point = POINTLIST._2_03_CP_13
        },
        {
            point = POINTLIST._2_03_CP_14
        },
        {
            point = POINTLIST._2_03_CP_15
        },
        {
            point = POINTLIST._2_03_CP_16
        },
        {
            point = POINTLIST._2_03_CP_17
        },
        {
            point = POINTLIST._2_03_CP_18
        },
        {
            point = POINTLIST._2_03_CP_19
        },
        {
            point = POINTLIST._2_03_CP_20
        },
        {
            point = POINTLIST._2_03_CP_21
        },
        {
            point = POINTLIST._2_03_CP_22
        },
        {
            point = POINTLIST._2_03_CP_23
        },
        {
            point = POINTLIST._2_03_CP_24
        },
        {
            point = POINTLIST._2_03_CP_25
        },
        {
            point = POINTLIST._2_03_CP_26
        },
        {
            point = POINTLIST._2_03_CP_27
        },
        {
            point = POINTLIST._2_03_CP_28
        },
        {
            point = POINTLIST._2_03_CP_29
        },
        {
            point = POINTLIST._2_03_CP_30
        },
        {
            point = POINTLIST._2_03_CP_31
        }
    }
    for i, p in table do
        PedAddCover(p.point, 100, 35, 2, 0, 0, 3, 3, 0, 0, 1, 1, true, 0.5)
    end
end

function F_SitPed(ped)
    PedSetActionNode(ped, "/Global/Ambient/Sitting_Down/SitHigh", "Act/Anim/Ambient.act")
    PedSetFlag(ped, 17, true)
end

function F_StandPed(ped)
    PedSetFlag(ped, 17, false)
end

function F_EggCheck()
    return PlayerHasItem(312)
end

function OpenTadsGatesMonitor()
    if not bGatesOpened and PlayerIsInTrigger(TRIGGER._2_03_TADSBLOCK) then
        --print(">>>[RUI]", "!!OpenTadsGatesMonitor")
        AreaSetDoorLocked(TRICH_TADGATES, false)
        AreaSetDoorLocked(TRICH_TADGATES01, false)
        AreaSetDoorOpen(TRICH_TADGATES01, true)
        PAnimOpenDoor(TRIGGER._TRICH_TADGATES01)
        bGatesOpened = true
    end
end

function Stage_GetEggsInit()
    --print(">>>[RUI]", "!!Stage_GetEggsInit")
    TadGroupCreate(2)
    shared.g2_03 = true
    thread_T_Egg_Hint = CreateThread("T_Egg_Hint")
    F_CheckMoney()
    if F_EggCheck() then
        gObjective = UpdateObjectiveLog("2_03_OBJ1C", nil)
    else
        gObjective = UpdateObjectiveLog("2_03_OBJ1B", nil)
    end
    MissionStageRun = Stage_GetEggsLoop
end

function Stage_GetEggsLoop()
    OpenTadsGatesMonitor()
    F_CheckMoney()
    if F_PedExists(gTad) then
        HandleTadSitDown_Stage02()
        Wait(500)
        if PlayerIsInTrigger(TRIGGER._2_03_TADNIS) or bTadGroupAttacked then
            if F_PedIsDead(gTad) then
                bMissionSuccess = false
                mission_running = false
                MissionStageRun = nil
                gFailMessage = "2_03_FAIL01"
                return
            end
            if F_EggCheck() then
                if not playing_cs then
                    playing_cs = true
                    eggs_to_Tad = true
                    CS_NemesisAppears()
                    Stage_AmbushInit()
                end
            else
                NIS_TadRebuffNoEggs()
            end
            bTadGroupAttacked = false
        end
    end
    if F_EggCheck() and AreaGetVisible() == 0 then
        shared.g2_03 = nil
    end
end

function HandleTadSitDown_Stage02()
    if PlayerIsInTrigger(TRIGGER._2_03_TADHOUSE) then
        if not bTadSitting then
            --print(">>>[RUI]", "HandleTadSitDown_Stage02 SIT TAD SIT")
            F_SitPed(gTad)
            bTadSitting = true
        end
    else
        bTadSitting = false
    end
end

function T_Egg_Hint()
    if not F_EggCheck() then
        store_blip = BlipAddPoint(POINTLIST._2_03_EGGSTOREBLIP, 0)
    else
        tad_blip = AddBlipForChar(gTad, 2, 0, 1)
        tad_blipped = true
    end
    Wait(10000)
    while not eggs_to_Tad and mission_running do
        if not F_EggCheck() then
            if not store_blip then
                --print(">>>[RUI]", "!!T_Egg_Hint NO EGGS blip STORE")
                store_blip = BlipAddPoint(POINTLIST._2_03_EGGSTOREBLIP, 0)
                MissionObjectiveRemove(gObjective)
                gObjective = UpdateObjectiveLog("2_03_OBJ1B", nil)
            end
            if tad_blipped then
                BlipRemove(tad_blip)
                tad_blipped = false
            end
            if not egg_hint_done then
                --print(">>>[RUI]", "!!T_Egg_Hint TUTORIAL")
                TutorialShowMessage("2_03_22", 4000)
                egg_hint_done = true
            end
        elseif store_blip and AreaGetVisible() == 0 then
            BlipRemove(store_blip)
            store_blip = nil
            if not tad_blipped then
                --print(">>>[RUI]", "!!T_Egg_Hint blip TAD")
                tad_blipped = true
                tad_blip = AddBlipForChar(gTad, 2, 0, 1)
            end
            Wait(1000)
            MissionObjectiveRemove(gObjective)
            gObjective = UpdateObjectiveLog("2_03_OBJ1C", nil)
        end
        Wait(100)
    end
    collectgarbage()
end

function CS_NemesisAppears()
    --print(">>>[RUI]", "++CS_NemesisAppears")
    F_StandPed(gTad)
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    PlayerSetControl(0)
    CameraFade(500, 0)
    Wait(501)
    F_PlayerExitBike(true)
    TadGroupCleanup()
    local vx, vy, vz = GetPointList(POINTLIST._2_03_PLAYER_AFTER_EGGS)
    local vehicleTable = VehicleFindInAreaXYZ(vx, vy, vz, 20, true)
    if vehicleTable then
        for _, vehicle in vehicleTable do
            VehicleDelete(vehicle)
        end
    end
    PlayCutsceneWithLoad("2-03b", true)
    Wait(100)
    SetupCoverPoints()
    ClearAmbientPeds()
    PlayerSetPosPoint(POINTLIST._2_03_PLAYER_AFTER_EGGS)
    PedDestroyWeapon(gPlayer, 312)
    TadGroupCreate(3)
    BlipRemove(tad_blip)
    PedSetPosPoint(gTad, POINTLIST._2_03_TAD_AFTER_EGGS)
    PedFaceObject(gTad, gPlayer, 3, 0)
    PedSetPosPoint(gChad, POINTLIST._2_03_CHAD_AFTER_EGGS)
    PedFaceObject(gChad, gPlayer, 3, 0)
    PedSetPosPoint(gGord, POINTLIST._2_03_GORD_AFTER_EGGS)
    PedFaceObject(gGord, gPlayer, 3, 0)
    ClearTadGroupHitRegister()
    CameraFade(500, 1)
    CameraReturnToPlayer()
    Wait(250)
    if F_PedExists(gChad) then
        F_IgnorePlayer(gChad, false)
        PedStop(gChad)
        PedFollowPath(gChad, PATH._2_03_EGGER2COVERPATH, 0, 1, cbChadReadyToEgg)
        PedSetFlag(gChad, 98, false)
        F_PedSetDropItem(gChad, 362)
    end
    if F_PedExists(gGord) then
        F_IgnorePlayer(gGord, false)
        PedStop(gGord)
        PedFollowPath(gGord, PATH._2_03_EGGER1COVERPATH, 0, 1, cbGordReadyToEgg)
        PedSetFlag(gGord, 98, false)
        F_PedSetDropItem(gGord, 362, 75)
    end
    WindowEggersCreate()
    Wait(250)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    --print(">>>[RUI]", "--CS_NemesisAppears")
end

function FreezeGoons()
    if F_PedExists(gTad) then
        PedStop(gTad)
        PedSetPosPoint(gTad, POINTLIST._2_03_TADSTART, 1)
    end
    if F_PedExists(gChad) then
        PedStop(gChad)
        PedSetPosPoint(gGord, POINTLIST._2_03_TADSTART, 2)
    end
    if F_PedExists(gGord) then
        PedStop(gGord)
        PedSetPosPoint(gChad, POINTLIST._2_03_TADSTART, 3)
    end
end

function NIS_TadRebuffNoEggs()
    --print(">>>[RUI]", "++NIS_TadRebuffNoEggs")
    if not eggs_to_tad then
        PlayerSetControl(0)
        F_MakePlayerSafeForNIS(true)
        CameraFade(250, 0)
        Wait(251)
        FreezeGoons()
        F_PlayerExitBike(true)
        CameraSetWidescreen(true)
        F_StandPed(gTad)
        PlayerSetPosPoint(POINTLIST._2_03_PLAYERREBUFFED, 2)
        CameraSetXYZ(445.4474, 488.47275, 24.408869, 444.75018, 487.75723, 24.36852)
        PedFaceObject(gTad, gPlayer, 3, 0)
        PedFaceObject(gGord, gPlayer, 3, 0)
        PedFaceObject(gChad, gPlayer, 3, 0)
        CameraFade(250, 1)
        Wait(251)
        DoDialogLine(gTad, "/Global/2_03Cnv/animations/TadRebuff")
        Wait(2000)
        CameraFade(500, 0)
        Wait(501)
        FreezeGoons()
        F_SitPed(gTad)
        CameraReturnToPlayer()
        CameraReset()
        CameraFade(500, 1)
        PlayerSetPosPoint(POINTLIST._2_03_PLAYERREBUFFED, 1)
        Wait(501)
        F_MakePlayerSafeForNIS(false)
        PlayerSetControl(1)
        CameraSetWidescreen(false)
    end
    --print(">>>[RUI]", "--NIS_TadRebuffNoEggs")
end

function DoDialogLine(ped, action, actionFile)
    local file = actionFile or "Act/Conv/2_03.act"
    PedSetActionNode(ped, action, file)
    while PedIsPlaying(ped, action, true) or SoundSpeechPlaying() do
        Wait(0)
    end
end

function Stage_AmbushInit()
    --print(">>>[RUI]", "!!Stage_AmbushInit")
    SoundPlayInteractiveStreamLocked("MS_ActionHigh.rsm", MUSIC_DEFAULT_VOLUME)
    gObjective = UpdateObjectiveLog("2_03_OBJ3", gObjective)
    PedSetFlag(gTad, 11, true)
    F_IgnorePlayer(gTad, false)
    PedAttack(gTad, gPlayer, 3)
    SoundPlayScriptedSpeechEvent(gTad, "M_2_03", 11, "jumbo")
    F_LockGates(true)
    F_StartKeyMaster()
    CreateThread("T_ResetEggsForInfiniteEggers")
    bStage_Ambush = true
    MissionStageRun = Stage_AmbushLoop
end

function cbGordReadyToEgg(pedId, pathId, pathNode)
    if pedId == gGord then
        if pathNode == 1 then
            SoundPlayScriptedSpeechEvent(gGord, "M_2_03", 16, "large")
        elseif PathGetLastNode(pathId) == pathNode then
            --print(">>>[RUI]", "!!cbGordReadyToEgg")
            PedSetFlag(gGord, 11, true)
            F_SetupEggChucker(gGord, true)
        end
    end
end

function cbChadReadyToEgg(pedId, pathId, pathNode)
    if pedId == gChad and PathGetLastNode(pathId) == pathNode then
        --print(">>>[RUI]", "!!cbChadReadyToEgg")
        PedSetFlag(gChad, 11, true)
        F_SetupEggChucker(gChad, true)
    end
end

function Stage_AmbushLoop()
    if PlayerHasKey() then
        Stage_TheGetawayInit()
        return
    else
        TadGateHintCheck()
        KeyMasterMonitor()
        GateExitCheck()
    end
end

function GateExitCheck()
    if not bBackGateClosed and PlayerIsInTrigger(TRIGGER._2_03_BACK_GATE) and eggs_to_tad then
        AreaSetDoorOpen(TRICH_TADGATES, false)
        bBackGateClosed = true
    end
    if not bKeyMasterChosen then
        if PlayerIsInTrigger(TRIGGER._2_03_FRONTGATEAREA) or bKeyMasterHit then
            if not bHasKey then
                if not F_PedIsDead(gKeyMaster1) then
                    KeyMasterChoose(gKeyMaster1, "front")
                else
                    SoundStopCurrentSpeechEvent(gKeyMaster1)
                    KeyMasterDropGateKey(gKeyMaster1)
                    bKeyDropped = true
                end
                PedCleanup(gKeyMaster2)
                gObjective = UpdateObjectiveLog("2_03_OBJ6", nil)
                bKeyMasterChosen = true
            end
        elseif (PlayerIsInTrigger(TRIGGER._2_03_REARGATEAREA) or bKeyMasterHit) and not bHasKey then
            if not F_PedIsDead(gKeyMaster2) then
                KeyMasterChoose(gKeyMaster2, "back")
            else
                SoundStopCurrentSpeechEvent(gKeyMaster2)
                KeyMasterDropGateKey(gKeyMaster2)
                bKeyDropped = true
            end
            PedCleanup(gKeyMaster1)
            gObjective = UpdateObjectiveLog("2_03_OBJ6", nil)
            bKeyMasterChosen = true
        end
    end
end

function KeyMasterChoose(km, name)
    --print(">>>[RUI]", "++KeyMasterChoose " .. tostring(name) .. " " .. tostring(km))
    gKeyMaster = km
    AddBlipForChar(gKeyMaster, 2, 26, 4)
    PedSetActionNode(gKeyMaster, "/Global/2_03Cnv/animations/Lock_Picking/Lock_Picking_Loop_To_Idle", gActFile)
    PedOverrideStat(gKeyMaster, 34, 15)
    PedOverrideStat(gKeyMaster, 13, 6)
    PedOverrideStat(gKeyMaster, 8, 90)
    PedOverrideStat(gKeyMaster, 6, 70)
    PedOverrideStat(gKeyMaster, 7, 60)
    PedAttack(gKeyMaster, gPlayer, 1)
    SoundPlayScriptedSpeechEvent(gKeyMaster, "M_2_03", 12, "jumbo")
    monitor_ready = true
    --print(">>>[RUI]", "--KeyMasterChoose")
end

function cbKeymasterHit(victim, attacker)
    if (victim == gKeyMaster1 or victim == gKeyMaster2) and attacker == gPlayer then
        bKeyMasterHit = true
    end
end

function WindowEggersCreate()
    models = {
        30,
        35,
        40
    }
    gWindowEggers = {
        {
            point = POINTLIST._2_03_WindowEgger1,
            model = RandomTableElement(models)
        },
        {
            point = POINTLIST._2_03_WindowEgger2,
            model = RandomTableElement(models)
        },
        {
            point = POINTLIST._2_03_WindowEgger3,
            model = RandomTableElement(models)
        },
        {
            point = POINTLIST._2_03_WindowEgger4,
            model = RandomTableElement(models)
        },
        {
            point = POINTLIST._2_03_WindowEgger5,
            model = RandomTableElement(models)
        },
        {
            point = POINTLIST._2_03_WindowEgger6,
            model = RandomTableElement(models)
        }
    }
    for _, egger in gWindowEggers do
        egger.id = PedCreatePoint(egger.model, egger.point, 1)
        PedSetStationary(egger.id, true)
        PedClearAllWeapons(egger.id)
        PedOverrideStat(egger.id, 3, 1000)
        PedOverrideStat(egger.id, 2, 359)
        PedOverrideStat(egger.id, 13, 0)
        PedOverrideStat(egger.id, 8, 20)
        PedOverrideStat(egger.id, 11, 90)
        PedOverrideStat(egger.id, 10, 10)
        PedOverrideStat(egger.id, 31, 10)
        PedOverrideStat(egger.id, 34, 0)
        PedSetWeapon(egger.id, 312, 100)
        PedLockTarget(egger.id, gPlayer, false)
        PedAttack(egger.id, gPlayer, 3)
        PedSetActionTree(egger.id, "/Global/G_Ranged_A", "Act/Anim/G_Ranged_A.act")
        table.insert(gInfiniteEggers, {
            egger.id
        })
    end
    --print(">>>[RUI]", "++WindowEggersCreate")
end

function WindowEggerCleanup()
    if not gWindowEggers then
        return
    end
    for _, egger in gWindowEggers do
        if egger then
            PedCleanup(egger.id)
        end
    end
    --print(">>>[RUI]", "--WindowEggerCleanup")
end

function T_ResetEggsForInfiniteEggers()
    --print(">>>[RUI]", "++T_ResetEggsForInfiniteEggers")
    while mission_running and MissionActive() do
        for _, egger in gInfiniteEggers do
            if F_PedExists(egger) and not PedHasWeapon(egger, 312) then
                --print(">>>[RUI]", "T_ResetEggsForInfiniteEggers restock " .. tostring(egger))
                PedSetWeapon(egger.id, 312, 100)
            end
        end
        Wait(100)
    end
    collectgarbage()
    --print(">>>[RUI]", "--T_ResetEggsForInfiniteEggers")
end

function F_LockGates(bLock)
    --print(">>>[RUI]", "!!F_LockGates " .. tostring(bLock))
    if bLock and AreaIsDoorOpen(TRICH_TADGATES01) then
        --print(">>>[RUI]", "Closing Door")
        AreaSetDoorOpen(TRICH_TADGATES01, false)
        Wait(100)
    end
    AreaSetDoorLocked(TRICH_TADGATES01, bLock)
    Wait(100)
    AreaSetDoorLockedToPeds(TRICH_TADGATES01, bLock)
    Wait(100)
    AreaSetDoorLocked(TRICH_TADGATES, bLock)
    Wait(100)
    AreaSetDoorLockedToPeds(TRICH_TADGATES, bLock)
end

function F_BlipGates(bBlip)
    --print(">>>[RUI]", "!!F_BlipGates " .. tostring(bBlip))
    if bBlip then
        gate1Blip = AddBlipForProp(TRIGGER._TRICH_TADGATES, 0, 1)
        gate2Blip = AddBlipForProp(TRIGGER._TRICH_TADGATES01, 0, 1)
    else
        gate1Blip = BlipRemove(gate1Blip)
        gate2Blip = BlipRemove(gate2Blip)
    end
end

function UpdateObjectiveLog(newObjStr, oldObj)
    local newObj
    if newObjStr then
        newObj = MissionObjectiveAdd(newObjStr)
        TextPrint(newObjStr, 7, 1)
    end
    if oldObj then
        MissionObjectiveComplete(oldObj)
    end
    return newObj
end

function F_StartKeyMaster()
    gKeyMaster1 = PedCreatePoint(34, POINTLIST._2_03_FRONT_GATE_LOCKER)
    RegisterPedEventHandler(gKeyMaster1, 0, cbKeymasterHit)
    PedSetFlag(gKeyMaster1, 98, false)
    PedSetActionNode(gKeyMaster1, "/Global/2_03Cnv/animations/Lock_Picking/Lock_Picking_Loop", gActFile)
    gKeyMaster2 = PedCreatePoint(34, POINTLIST._2_03_BACK_GATE_LOCKER)
    RegisterPedEventHandler(gKeyMaster2, 0, cbKeymasterHit)
    PedSetActionNode(gKeyMaster2, "/Global/2_03Cnv/animations/Lock_Picking/Lock_Picking_Loop", gActFile)
    PedSetFlag(gKeyMaster2, 98, false)
    bKeyMasterFleeing = true
    bStage_Ambush = true
    bKeyMasterChosen = false
    --print(">>>[RUI]", "++F_StartKeyMaster")
end

function KeyMasterMonitor()
    if not bKeyDropped and monitor_ready then
        if not bKeyMasterChosen then
            if PlayerIsInTrigger(TRIGGER._2_03_FRONTGATEAREA) or bKeyMasterHit then
                if not bHasKey then
                    KeyMasterChoose(gKeyMaster1, "front")
                    PedCleanup(gKeyMaster2)
                    gObjective = UpdateObjectiveLog("2_03_OBJ6", nil)
                    bKeyMasterChosen = true
                end
            elseif (PlayerIsInTrigger(TRIGGER._2_03_REARGATEAREA) or bKeyMasterHit) and not bHasKey then
                KeyMasterChoose(gKeyMaster2, "back")
                PedCleanup(gKeyMaster1)
                gObjective = UpdateObjectiveLog("2_03_OBJ6", nil)
                bKeyMasterChosen = true
            end
        else
            if not bKeyDropped and F_PedIsDead(gKeyMaster) and not bKeyDropped then
                --print(">>>[RUI]", "!!KeyMasterMonitor key drop time")
                SoundStopCurrentSpeechEvent(gKeyMaster)
                KeyMasterDropGateKey(gKeyMaster)
                bKeyDropped = true
            end
            KeyMasterDoTaunts()
        end
        Wait(0)
    end
end

function PlayerHasKey()
    if ItemGetCurrentNum(494) > 0 then
        --print(">>>[RUI]", "PlayerHasKey")
        bHasKey = true
        bGotKey = true
        return true
    else
        bHasKey = false
        bGotKey = false
        return false
    end
end

function TadGateHintCheck()
    if not bHasKey and (PlayerIsInTrigger(TRIGGER._2_03_BACK_UNLOCK) or PlayerIsInTrigger(TRIGGER._2_03_FRONT_UNLOCK)) then
        TextPrint("2_03_OBJ6", 0.5, 1)
    end
end

function KeyMasterDropGateKey(ped)
    --print(">>>[RUI]", "++KeyMasterDropGateKey")
    local x3, y3, z3 = PedGetPosXYZ(ped)
    gate_key = PickupCreateXYZ(494, x3 + 0.5, y3 + 0.5, z3 + 0.25, "PermanentButes")
    b_key = AddBlipForPickup(gate_key, 0, 4)
end

local taunts = { 12, 13 }
local event

function KeyMasterDoTaunts()
    if not gKeyMaster then
        print(">>>[RUI]", "gKeyMaster == NIL")
    end
    if gTauntTimer and not bKeyDropped then
        if TimerPassed(gTauntTimer) then
            --print(">>>[RUI]", "KeyMasterDoTaunts timer passed")
            if not SoundSpeechPlaying(gKeyMaster) and not F_PedIsDead(gKeyMaster) then
                --print(">>>[RUI]", "KeyMasterDoTaunts speech ready")
                event = RandomTableElement(taunts)
                SoundPlayScriptedSpeechEvent(gKeyMaster, "M_2_03", event, "jumbo")
                gTauntTimer = GetTimer() + 5000 + math.random(1000, 2000)
            end
        end
    else
        gTauntTimer = GetTimer() + 5000
    end
end

function Stage_TheGetawayInit()
    --print(">>>[RUI]", "!!Stage_TheGetawayInit")
    gObjective = UpdateObjectiveLog(nil, gObjective)
    TextPrint("2_03_11", 7, 1)
    F_LockGates(false)
    F_BlipGates(true)
    bStage_Ambush = false
    PedSetTypeToTypeAttitude(5, 13, 0)
    MissionStageRun = Stage_TheGetawayLoop
end

function Stage_TheGetawayLoop()
    if not PlayerIsInTrigger(TRIGGER._2_03_TADHOUSE) then
        mission_running = false
        MissionStageRun = nil
        bMissionSuccess = true
        F_BlipGates(false)
    end
end

function TadGroupCreate(stage)
    if stage == 1 then
        gTad = PedCreateOrMove(gTad, 31, POINTLIST._2_03_TAD_BOXING, 1)
        gGord = PedCreateOrMove(gGord, 30, POINTLIST._2_03_TAD_BOXING, 2)
        gChad = PedCreateOrMove(gChad, 32, POINTLIST._2_03_TAD_BOXING, 3)
        F_IgnorePlayer(gTad, true)
        F_IgnorePlayer(gGord, true)
        F_IgnorePlayer(gChad, true)
    else
        gTad = PedCreateOrMove(gTad, 31, POINTLIST._2_03_TADSTART, 1)
        gGord = PedCreateOrMove(gGord, 30, POINTLIST._2_03_TADSTART, 2)
        gChad = PedCreateOrMove(gChad, 32, POINTLIST._2_03_TADSTART, 3)
        if stage == 2 then
            F_SitPed(gTad)
            RegisterPedEventHandler(gTad, 0, cbTadGroupAttacked)
            RegisterPedEventHandler(gChad, 0, cbTadGroupAttacked)
            RegisterPedEventHandler(gGord, 0, cbTadGroupAttacked)
            F_IgnorePlayer(gTad, true)
            F_IgnorePlayer(gGord, true)
            F_IgnorePlayer(gChad, true)
        else
            F_IgnorePlayer(gTad, false)
            F_IgnorePlayer(gGord, false)
            F_IgnorePlayer(gChad, false)
        end
    end
end

function TadGroupCleanup()
    if not bTadCleanedup then
        PedCleanup(gTad)
        PedCleanup(gGord)
        PedCleanup(gChad)
        bTadCleanedup = true
    end
    UnloadModels({
        31,
        30,
        32
    })
    --print(">>>[RUI]", "--TadGroupCleanup")
end

function PedCreateOrMove(ped, model, point, index)
    local guy = ped
    if F_PedExists(guy) then
        --print(">>>[RUI]", "PedCreateOrMove MOVE")
        PedStop(guy)
        PedSetPosPoint(guy, point, index)
    else
        --print(">>>[RUI]", "PedCreateOrMove CREATE")
        guy = PedCreatePoint(model, point, index)
    end
    return guy
end

function ClearTadGroupHitRegister()
    --print(">>>[RUI]", "--ClearTadGroupHitRegister")
    if F_PedExists(gTad) then
        RegisterPedEventHandler(gTad, 0, nil)
    end
    if F_PedExists(gGord) then
        RegisterPedEventHandler(gGord, 0, nil)
    end
    if F_PedExists(gChad) then
        RegisterPedEventHandler(gChad, 0, nil)
    end
end

function cbTadGroupAttacked(victim, attacker)
    if attacker == gPlayer and (victim == gTad or victim == gChad or victim == gGord) then
        --print(">>>[RUI]", "!!cbTadGroupAttacked")
        bTadGroupAttacked = true
    end
end

function ClearAmbientPeds()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaClearAllPeds()
    VehicleOverrideAmbient(0, 0, 0, 0)
end

function CS_TadAssignsMission()
    PlayerSetControl(0)
    PlayCutsceneWithLoad("2-03", true)
    LoadAnimationGroup("TadGates")
    LoadAnimationGroup("NIS_2_03")
    LoadAnimationGroup("MINI_Lock")
    LoadActionTree(gActFile)
    LoadActionTree("Act/Anim/G_Ranged_A.act")
    MissionInit()
    AreaForceLoadAreaByAreaTransition(true)
    AreaTransitionPoint(0, POINTLIST._2_03_PLAYERSTART_NEW, 1, true)
    AreaForceLoadAreaByAreaTransition(false)
    CameraFade(FADE_IN_TIME, 1)
    Wait(FADE_IN_TIME)
    PlayerSetControl(1)
end

function F_IgnorePlayer(ped, bIgnore)
    if bIgnore then
        if F_PedExists(ped) then
            --print(">>>[RUI]", "F_IgnorePlayer ON")
            PedSetStationary(ped, true)
            PedMakeTargetable(ped, false)
            PedSetPedToTypeAttitude(ped, gPlayer, 4)
            local h = PedGetHealth(ped)
            PedSetMinHealth(ped, h)
        end
    elseif F_PedExists(ped) then
        --print(">>>[RUI]", "F_IgnorePlayer OFF")
        PedClearObjectives(ped)
        PedSetStationary(ped, false)
        PedMakeTargetable(ped, true)
        PedSetInvulnerableToPlayer(ped, false)
        PedSetTypeToTypeAttitude(5, 13, 0)
        PedSetMinHealth(ped, -1)
    end
end

function F_SetupEggChucker(guy, bRestricted)
    --assert(guy, "F_SetupEggChucker(guy, bRestricted) guy==nil")
    PedSetWeapon(guy, 312, 100)
    PedClearObjectives(guy)
    PedSetStationary(guy, false)
    PedMakeTargetable(guy, true)
    PedSetInvulnerableToPlayer(guy, false)
    PedSetTypeToTypeAttitude(5, 13, 0)
    if bRestricted then
        PedRestrictToTrigger(guy, TRIGGER._2_03_TADHOUSE)
    end
    PedAutoCover(guy, gPlayer)
    table.insert(gInfiniteEggers, { guy })
    --print(">>>[RUI]", "++F_SetupEggChucker")
end

function TimerPassed(time)
    return time <= GetTimer()
end

function CleanupEnemies()
    TadGroupCleanup()
    for i, enemy in enemyTable do
        PedCleanup(enemy)
    end
    --print(">>>[RUI]", "--CleanupEnemies")
end

function PedCleanup(ped)
    if F_PedExists(ped) then
        PedMakeAmbient(ped)
    end
end

function MissionCleanup()
    if bMissionSuccess then
        CameraSetWidescreen(false)
        SoundEnableSpeech_ActionTree()
        F_MakePlayerSafeForNIS(false)
    else
        RemovePlayerItem(494)
    end
    MissionStageRun = nil
    mission_running = true
    CleanupEnemies()
    WindowEggerCleanup()
    AreaRevertToDefaultPopulation()
    VehicleRevertToDefaultAmbient()
    shared.gHasTadKey = bMissionSuccess and bGotKey
    shared.g2_03 = nil
    shared.g2_03_shirt = false
    SoundStopInteractiveStream()
    UnLoadAnimationGroup("TadGates")
    UnLoadAnimationGroup("MINI_Lock")
    DATUnload(2)
    CameraSetWidescreen(false)
    collectgarbage()
end

function F_CheckMoney()
    if PlayerGetMoney() < 150 and ItemGetCurrentNum(312) == 0 and not shared.playerShopping then
        gFailMessage = "CMN_STR_06"
        mission_running = false
    end
end
