shared.on_mission_110 = true
shared.gAreaDATFileLoaded[8] = false
local MISSION_RUNNING = 0
local MISSION_PASS = 1
local MISSION_FAIL = 2
local gMissionState = MISSION_RUNNING
local gMissionStage, gFailMessage
local FIREDAMAGE = 40
local FIREHEALTH = 1000
local ROOM_00 = 1
local ROOM_01 = 2
local ROOM_02 = 3
local ROOM_03 = 4
local ROOM_04 = 5
local HINT_DELAY = 10000
local MAX_HINTS = 3
local gHintCount = 0
local gObjective, gObjectiveBlip, gGary
local bGaryAttacked = false
local bGaryDead = false
local bMissionFailed = true
local gBully1, gBully2, gBully3
local bBulliesPeaceful = true
local basement_triggers_locked = false
local bInBasement = false

function ElectricNoGoZone(bOn)
    if bOn then
        --print(">>>[RUI]", "++ElectricNoGoZone")
        if AreaTriggerIsValid(TRIGGER._JANELECTRICPROXY) then
            PAnimCreate(TRIGGER._JANELECTRICPROXY)
        end
        NoGoElectricLI, NoGoElectricSO = CreatePersistentEntity("NOGO_ElecRoomOP", -762.044, -74.6036, 10.8326, 0, 8)
    else
        if AreaTriggerIsValid(TRIGGER._JANELECTRICPROXY) then
            PAnimDelete(TRIGGER._JANELECTRICPROXY)
        end
        if NoGoElectricLI and NoGoElectricSO then
            DeletePersistentEntity(NoGoElectricLI, NoGoElectricSO)
        end
        --print(">>>[RUI]", "--ElectricNoGoZone")
    end
end

function SteamNoGoZone(bOn)
    if bOn then
        --print(">>>[RUI]", "++SteamNoGoZone")
        if AreaTriggerIsValid(TRIGGER._JANSTEAMPROXY) then
            PAnimCreate(TRIGGER._JANSTEAMPROXY)
        end
        NoGoSteamLI, NoGoSteamSO = CreatePersistentEntity("NOGO_SteamOP", -761.193, -62.6332, 10.8326, 0, 8)
    else
        if AreaTriggerIsValid(TRIGGER._JANSTEAMPROXY) then
            PAnimDelete(TRIGGER._JANSTEAMPROXY)
        end
        if NoGoSteamLI and NoGoSteamSO then
            DeletePersistentEntity(NoGoSteamLI, NoGoSteamSO)
        end
        --print(">>>[RUI]", "--SteamNoGoZone")
    end
end

function CS_Intro()
    --print(">>>[RUI]", "!!CS_Intro")
    PlayerSetControl(0)
    PlayCutsceneWithLoad("1-10", true)
    MissionInit()
    CameraReturnToPlayer(false)
    CameraFade(1000, 1)
    Wait(500)
    PedIgnoreStimuli(gGary, true)
    PedFollowPath(gGary, PATH._1_10_TO_PARKINGLOT, 0, 3, cbGaryNearBullies)
    Wait(500)
    PlayerSetControl(1)
end

function GaryCreate(point)
    local nemesis
    F_SetCharacterModelsUnique(true, { 130 })
    nemesis = PedCreatePoint(130, POINTLIST._1_10_NEMESIS_MM)
    PedOverrideStat(nemesis, 6, 0)
    PedSetMissionCritical(nemesis, true, cbGaryAttacked, true)
    PlayerSocialDisableActionAgainstPed(nemesis, 28, true)
    PlayerSocialDisableActionAgainstPed(nemesis, 29, true)
    PedSetHealth(nemesis, 400)
    PedAddPedToIgnoreList(nemesis, gPlayer)
    PedSetFlag(nemesis, 117, false)
    PedSetInfiniteSprint(nemesis, true)
    return nemesis
end

function GaryIgnorePlayer(bOn)
    --print(">>>[RUI]", "!!GaryIgnorePlayer")
    if bOn then
        PedIgnoreAttacks(gGary, true)
        PedIgnoreStimuli(gGary, true)
    else
        PedIgnoreAttacks(gGary, false)
        PedIgnoreStimuli(gGary, false)
    end
end

function GaryCleanup()
    if gGary and PedIsValid(gGary) and PedIsDead(gGary) then
        PedMakeAmbient(gGary)
    elseif F_PedExists(gGary) then
        if PedGetAllyFollower(gPlayer) == gGary then
            PedDismissAlly(gPlayer, gGary)
        end
        gGary = MakeAmbient(gGary)
    end
    PedHideHealthBar()
    --print(">>>[RUI]", "--GaryCleanup")
end

function AudienceCreate()
    --print(">>>[RUI]", "AudienceCreate() start")
    aud1 = PedCreatePoint(23, POINTLIST._1_10_AUDIENCE, 1)
    aud2 = PedCreatePoint(10, POINTLIST._1_10_AUDIENCE, 2)
    aud3 = PedCreatePoint(19, POINTLIST._1_10_AUDIENCE, 3)
    aud4 = PedCreatePoint(37, POINTLIST._1_10_AUDIENCE, 4)
    PedMoveToPoint(aud1, 1, POINTLIST._1_10_AUDVIEW, 1)
    PedMoveToPoint(aud2, 1, POINTLIST._1_10_AUDVIEW, 2)
    PedMoveToPoint(aud3, 1, POINTLIST._1_10_AUDVIEW, 3)
    PedMoveToPoint(aud4, 1, POINTLIST._1_10_AUDVIEW, 4)
    PedFaceObject(aud1, gPlayer, 3, 1)
    PedFaceObject(aud2, gPlayer, 3, 1)
    PedFaceObject(aud3, gPlayer, 3, 1)
    PedFaceObject(aud4, gPlayer, 3, 1)
end

function BullyEncounterCreate()
    F_SetCharacterModelsUnique(true, {
        102,
        99,
        85
    })
    gBully1 = PedCreatePoint(102, POINTLIST._1_10BULLY01)
    gBully2 = PedCreatePoint(99, POINTLIST._1_10BULLY02A)
    gBully3 = PedCreatePoint(85, POINTLIST._1_10BULLY02B)
    BulliesRegisterHitCheck(true)
    bBulliesPeaceful = true
    F_PedSetDropItem(gBully2, 362)
    --print(">>>[RUI]", "++BullyEncounterCreate()")
end

function BulliesRegisterHitCheck(bOn)
    if bOn then
        RegisterPedEventHandler(gBully1, 0, cbBullyHit)
        RegisterPedEventHandler(gBully2, 0, cbBullyHit)
        RegisterPedEventHandler(gBully3, 0, cbBullyHit)
        --print(">>>[RUI]", "++BulliesRegisterHitCheck")
    else
        RegisterPedEventHandler(gBully1, 0, nil)
        RegisterPedEventHandler(gBully2, 0, nil)
        RegisterPedEventHandler(gBully3, 0, nil)
        --print(">>>[RUI]", "--BulliesRegisterHitCheck")
    end
end

function cbBullyHit(victim, attacker)
    if (attacker == gPlayer or attacker == gGary) and (victim == gBully1 or victim == gBully2 or victim == gBully3) then
        --print(">>>[RUI]", "!!cbBullyHit")
        bBulliesPeaceful = false
    end
end

function cbGaryAttacked()
    if F_PedIsDead(gGary) then
        bGaryDead = true
        gFailMessage = "1_10_Fail1"
        gMissionStage = nil
        gMissionState = MISSION_FAIL
        bMissionFailed = true
        --print(">>>[RUI]", "Gary KO'd")
    end
    bGaryAttacked = true
end

function ExtraHealthsCreate()
    local point = POINTLIST._1_10_HEALTHPICKUPS
    local count = GetPointListSize(point)
    for i = 1, count do
        PickupCreatePoint(502, point, i, 0, "HealthBute")
        --print(">>>[RUI]", "++fraffy")
    end
    --print(">>>[RUI]", "++ExtraHealthsCreate")
end

function UpdateObjectiveLog(newObjStr, oldObj)
    local newObj
    if newObjStr then
        newObj = MissionObjectiveAdd(newObjStr)
        TextPrint(newObjStr, 4, 1)
    end
    if oldObj then
        MissionObjectiveComplete(oldObj)
    end
    return newObj
end

function SwitchDeactivate(switch)
    --print(">>>[RUI]", "--SwitchDeactivate " .. switch)
    Wait(150)
    if switch == ROOM_00 then
        PAnimSetActionNode(TRIGGER._JANSWTCH00, "/Global/AsySwtch/NotUseable", "Act/Props/AsySwtch.act")
    elseif switch == ROOM_01 then
        PAnimSetActionNode(TRIGGER._JANSWTCH01, "/Global/AsySwtch/NotUseable", "Act/Props/AsySwtch.act")
    elseif switch == ROOM_02 then
        PAnimSetActionNode(TRIGGER._JANSWTCH02, "/Global/AsySwtch/NotUseable", "Act/Props/AsySwtch.act")
    elseif switch == ROOM_03 then
        PAnimSetActionNode(TRIGGER._JANSWTCH03A, "/Global/AsySwtch/NotUseable", "Act/Props/AsySwtch.act")
    end
end

function SwitchCheck(room)
    if room == ROOM_00 then
        if PAnimIsPlaying(TRIGGER._JANSWTCH00, "/Global/AsySwtch/Active", true) then
            return true
        end
    elseif room == ROOM_01 then
        if PAnimIsPlaying(TRIGGER._JANSWTCH01, "/Global/AsySwtch/Active", true) then
            return true
        end
    elseif room == ROOM_02 then
        return bBroomHit
    elseif room == ROOM_03 then
        if bSwitchCheck then
            if PlayerIsInTrigger(TRIGGER._JANSWTCH03A) and PAnimIsPlaying(TRIGGER._JANSWTCH03A, "/Global/AsySwtch/Active", true) and bElectricArcsOn then
                ElectricArcsOff()
                CreateThread("T_ElectricityBackOn")
                bSwitchCheck = false
                return false
            end
        elseif AreaIsDoorOpen(TRIGGER._JANDOORS03B) then
            return true
        end
    elseif room == ROOM_04 and FireGetHealth(triggerFire.fx) <= 0 then
        local x, y, z = GetAnchorPosition(triggerFire.trigger)
        SoundPlay3D(x, y, z, "FlameOut")
        EffectCreate("BoilerSteam", x, y, z)
        return true
    end
    return false
end

function TimerPassed(timer)
    if timer < GetTimer() then
        return true
    else
        return false
    end
end

function DoorOpen(door)
    --print(">>>[RUI]", "!!DoorOpen " .. tostring(door))
    PAnimOpenDoor(door)
    PAnimDoorStayOpen(door)
    AreaSetDoorLockedToPeds(door, false)
    AreaSetDoorPathableToPeds(door, true)
end

local runQuotes = {
    40,
    50,
    9,
    36
}

function NIS_OpenDoor(door, room, garyPath)
    --print(">>>[RUI]", "!!NIS_OpenDoor")
    SoundStopCurrentSpeechEvent(gGary)
    SoundSetAudioFocusCamera()
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    PlayerSetControl(0)
    if room == ROOM_00 then
        --print("Door 1")
        CameraSetFOV(70)
        CameraSetXYZ(-744.9688, -51.954773, 10.44758, -745.50476, -52.79608, 10.516687)
    elseif room == ROOM_01 then
        --print("Door 2")
        CameraSetFOV(70)
        CameraSetXYZ(-743.5867, -69.363495, 9.932215, -742.69934, -69.823555, 9.959297)
        --print("Door 3")
    elseif room == ROOM_02 then
        CameraSetFOV(70)
        CameraSetXYZ(-741.10443, -79.66768, 8.970539, -742.0783, -79.45642, 9.052053)
    end
    if door then
        DoorOpen(door)
    end
    Wait(500)
    local q = RandomTableElement(runQuotes)
    SoundPlayScriptedSpeechEvent(gGary, "M_1_10", q, "supersize")
    PedFollowPath(gGary, garyPath, 0, 1, cbGaryRoomPath)
    while SoundSpeechPlaying(gGary) do
        Wait(0)
    end
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    SoundSetAudioFocusPlayer()
    CameraReset()
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    --print(">>>[RUI]", "--NIS_OpenDoor")
end

function FXCreateWithDirection(effect, point, e, dx, dy, dz)
    --print(">>>[RUI]", "FXCreateWithDirection " .. tostring(effect))
    local x, y, z = GetPointFromPointList(point, e)
    local fx = EffectCreate(effect, x, y, z)
    if dx and dy and dz then
        EffectSetDirection(fx, dx, dy, dz)
    end
    return fx
end

function cbGaryRoomPath(pedId, pathId, pathNode)
    if pedId == gGary and pathNode == PathGetLastNode(pathId) then
        if pathId == PATH._1_10_ROOM00 then
            --print(">>>[RUI]", "!!cbGaryRoom00")
            PedFaceObject(gGary, gPlayer, 3, 1, false)
            bGaryRoom00 = true
        elseif pathId == PATH._1_10_ROOM01 then
            --print(">>>[RUI]", "!!cbGaryRoom01")
            PedFaceObject(gGary, gPlayer, 3, 1, false)
            bGaryRoom01 = true
        elseif pathId == PATH._1_10_ROOM02 then
            --print(">>>[RUI]", "!!cbGaryRoom02")
            PedFaceObject(gGary, gPlayer, 3, 1, false)
            bGaryRoom02 = true
        elseif pathId == PATH._1_10_ROOM03 then
            --print(">>>[RUI]", "!!cbGaryRoom03")
            PedFaceObject(gGary, gPlayer, 3, 1, false)
            bGaryRoom03 = true
        elseif pathId == PATH._1_10_ROOM04 then
            --print(">>>[RUI]", "!!cbGaryRoom04")
            PedFaceObject(gGary, gPlayer, 3, 1, false)
            bGaryRoom04 = true
        elseif pathId == PATH._1_10_ROOM05 then
            --print(">>>[RUI]", "!!cbGaryRoom05")
            PedFaceObject(gGary, gPlayer, 3, 1, false)
        end
    end
end

function HintsReset()
    --print(">>>[RUI]", "!!HintsReset")
    SoundStopCurrentSpeechEvent(gGary)
    gRoomHintTimer = nil
    gHintCount = 0
    bOpeningHint = false
    bGiveHints = true
end

function Stage00_FollowGaryInit()
    --print(">>>[RUI]", "++Stage00_FollowGaryInit")
    GaryIgnorePlayer(true)
    local blip = AddBlipForChar(gGary, 2, 0, 4)
    ObjectiveBlipUpdate(blip)
    gObjective = UpdateObjectiveLog("1_10_OBJ00", gObjective)
    BullyEncounterCreate()
    PedShowHealthBar(gGary, true, "1_10_NEMESIS")
    gMissionStage = Stage00_FollowGaryLoop
end

function Stage00_FollowGaryLoop()
    if bGaryNearBullies then
        if PlayerIsInTrigger(TRIGGER._1_10_BULLYTRIGGER) or not bBulliesPeaceful then
            gMissionStage = Stage01_BullyFightInit
            --print(">>>[RUI]", "--Stage00_FollowGaryLoop")
        end
        Wait(10)
    end
end

function cbGaryNearBullies(pedId, pathId, pathNode)
    if pedId == gGary and pathNode == PathGetLastNode(pathId) then
        --print(">>>[RUI]", "!cbGaryNearBullies")
        bGaryNearBullies = true
        PedFaceObject(gGary, gBully1, 2, 1)
        PedAddPedToIgnoreList(gGary, gPlayer)
        GaryIgnorePlayer(false)
    end
end

function Stage01_BullyFightInit()
    --print(">>>[RUI]", "++Stage01_BullyFightInit")
    gObjectiveBlip = BlipClean(gObjectiveBlip)
    if bBulliesPeaceful then
        PedFaceObject(gBully1, gGary, 2, 1, true)
        PedFaceObject(gBully2, gGary, 2, 1, true)
        PedFaceObject(gBully3, gGary, 2, 1, true)
        PedIgnoreStimuli(gGary, false)
        SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 13, "supersize")
        gBully1Blip = AddBlipForChar(gBully1, 2, 26, 4)
        gBully2Blip = AddBlipForChar(gBully2, 2, 26, 4)
        gBully3Blip = AddBlipForChar(gBully3, 2, 26, 4)
        while SoundSpeechPlaying(gGary) and bBulliesPeaceful do
            if bGaryDead then
                break
            end
            Wait(0)
        end
    else
        SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 13, "supersize")
    end
    PedHideHealthBar()
    PedStop(gGary)
    PedRecruitAlly(gPlayer, gGary)
    gObjective = UpdateObjectiveLog("1_10_OBJ01", gObjective)
    BulliesRegisterHitCheck(false)
    --print(">>>[RUI]", "bullies attack")
    PedAttack(gBully1, gGary)
    PedAttack(gBully2, gPlayer, 1)
    PedAttack(gBully3, gPlayer, 1)
    --print(">>>[RUI]", "blip bullies")
    gMissionStage = Stage01_BullyFightLoop
    --print(">>>[RUI]", "++Stage01_BullyFightLoop")
end

function Stage01_BullyFightLoop()
    if bGaryDead then
        gMissionStage = MISSION_FAIL
        gMissionStage = nil
        gFailMessage = "1_10_Fail1"
    end
    if F_PedIsDead(gBully1) and F_PedIsDead(gBully2) and F_PedIsDead(gBully3) then
        --print(">>>[RUI]", "--Stage01_BullyFightLoop")
        SetCharacterModelsUnique(false)
        gMissionStage = Stage02_EnterBasementInit
    end
end

function Stage02_EnterBasementInit()
    --print(">>>[RUI]", "++Stage02_EnterBasementInit")
    gObjective = UpdateObjectiveLog(nil, gObjective)
    PedSetActionNode(gGary, "/Global/1_10_anims/Gary/KeyPickup", "Act/Anim/1_10.act")
    while SoundSpeechPlaying(gGary) do
        Wait(0)
    end
    local blip = BlipAddPoint(POINTLIST._1_10JANDOORBLIP, 0)
    ObjectiveBlipUpdate(blip)
    gObjective = UpdateObjectiveLog("1_10_OBJ02", gObjective)
    PedDismissAlly(gPlayer, gGary)
    PedShowHealthBar(gGary, true, "1_10_NEMESIS")
    PedIgnoreStimuli(gGary, true)
    PedFollowPath(gGary, PATH._1_10_TO_BASEMENT, 0, 3, cbGaryAtBasementDoor)
    gMissionStage = Stage02_EnterBasementLoop
end

function cbGaryAtBasementDoor(pedId, pathId, pathNode)
    if pedId == gGary and PathGetLastNode(pathId) == pathNode then
        bGaryAtBasementDoor = true
        PedFaceObject(gGary, gPlayer, 3, 1, false)
    end
end

function Stage02_EnterBasementLoop()
    if PlayerIsInTrigger(TRIGGER._1_10_NEAR_BASEMENTDOOR) then
        if bGaryDead then
            return
        end
        if not bDoorsUnlocked then
            AreaSetDoorLocked("DT_TSCHOOL_SCHOOLSIDEDOORL", false)
            AreaSetDoorLockedToPeds("DT_TSCHOOL_SCHOOLSIDEDOORL", false)
            gObjective = UpdateObjectiveLog("1_10_OBJ03", gObjective)
            MissionAllowAmbientTransitions(false)
            bDoorsUnlocked = true
        end
        if bGaryAtBasementDoor then
            SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 19, "supersize")
            bGaryAtBasementDoor = false
        end
        if AreaIsDoorOpen(TRIGGER._DT_TSCHOOL_SCHOOLSIDEDOORL) then
            SoundStopCurrentSpeechEvent(gGary)
            PedFollowPath(gGary, PATH._1_10_ENTERBASEMENT, 0, 1)
            while AreaGetVisible() == 0 do
                Wait(10)
            end
            --print(">>>[RUI]", "!!janitor streaming done")
            gMissionStage = Room00_SimpleSwitchInit
        end
    end
end

function Room00_SimpleSwitchInit()
    --print(">>>[RUI]", "++Room00_SimpleSwitchInit")
    RadarSetMinMax(30, 30, 30)
    AreaSetDoorLocked("DT_JANITOR_MAINEXIT", true)
    AreaSetDoorLockedToPeds("DT_JANITOR_MAINEXIT", true)
    GaryIgnorePlayer(true)
    HintsReset()
    PAnimCreate(TRIGGER._JANSTEAMPROXY)
    while not shared.gAreaDATFileLoaded[8] do
        Wait(10)
    end
    bInBasement = true
    local blip = AddBlipForProp(TRIGGER._JANSWTCH00, 0, 1)
    ObjectiveBlipUpdate(blip)
    AddBlipForChar(gGary, 0, 27, 1)
    gObjective = UpdateObjectiveLog("1_10_OBJ04", gObjective)
    MissionObjectiveReminderTime(-1)
    PedSetPosPoint(gGary, POINTLIST._1_10_GARYBS)
    SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 21, "supersize")
    PedFollowPath(gGary, PATH._1_10_ROOM00, 0, 1, cbGaryRoomPath)
    SoundPlayInteractiveStream("MS_CarnivalFunhouseMiner.rsm", 0.4)
    PAnimDelete(TRIGGER._JANSTEAMPROXY)
    gMissionStage = Room00_SimpleSwitchLoop
end

function Room00_SimpleSwitchLoop()
    if SwitchCheck(ROOM_00) then
        SwitchDeactivate(ROOM_00)
        bGiveHints = false
        NIS_OpenDoor(TRIGGER._JANDOORS00, ROOM_00, PATH._1_10_ROOM01)
        gMissionStage = Room01_TheCageInit
        --print(">>>[RUI]", "--Room00_SimpleSwitchLoop")
    else
        Room00_HintCheck()
    end
end

function Room00_HintCheck()
    if bGaryRoom00 and bGiveHints and PlayerIsInTrigger(TRIGGER._1_10_ROOM0) then
        if gRoomHintTimer then
            if TimerPassed(gRoomHintTimer) then
                SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 23, "supersize")
                PedSetActionNode(gGary, "/Global/1_10_anims/Gary/PointAtSwitch", "Act/Anim/1_10.act")
                gRoomHintTimer = gRoomHintTimer + HINT_DELAY + math.random(2000, 5000)
                gHintCount = gHintCount + 1
                if gHintCount == MAX_HINTS then
                    local blip = AddBlipForProp(TRIGGER._JANSWTCH00, 0, 1)
                    ObjectiveBlipUpdate(blip)
                end
            end
        else
            gRoomHintTimer = GetTimer() + 2000
        end
    end
end

function Room01_TheCageInit()
    --print(">>>[RUI]", "++Room01_TheCageInit")
    HintsReset()
    local blip = AddBlipForProp(TRIGGER._JANSWTCH01, 0, 1)
    ObjectiveBlipUpdate(blip)
    gMissionStage = Room01_TheCageLoop
end

function Room01_TheCageLoop()
    if SwitchCheck(ROOM_01) then
        SwitchDeactivate(ROOM_01)
        bGiveHints = false
        NIS_OpenDoor(TRIGGER._JANDOORS01, ROOM_01, PATH._1_10_ROOM02)
        gMissionStage = Room02_BroomSwitchInit
        --print(">>>[RUI]", "--Room01_TheCageLoop")
    else
        Room01_HintCheck()
    end
end

local gRoom01Hints = {
    25,
    26,
    28
}

function Room01_HintCheck()
    if bGaryRoom01 and bGiveHints and PlayerIsInTrigger(TRIGGER._1_10_ROOM1) then
        if gRoomHintTimer then
            if TimerPassed(gRoomHintTimer) and not SoundSpeechPlaying(gGary) then
                event = RandomTableElement(gRoom01Hints)
                SoundPlayScriptedSpeechEvent(gGary, "M_1_10", event, "supersize")
                gRoomHintTimer = gRoomHintTimer + HINT_DELAY + math.random(2000, 5000)
                gHintCount = gHintCount + 1
                if gHintCount == MAX_HINTS then
                    local blip = AddBlipForProp(TRIGGER._JANSWTCH01, 0, 1)
                    ObjectiveBlipUpdate(blip)
                end
            end
        elseif not bOpeningHint then
            SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 24, "supersize")
            bOpeningHint = true
        else
            gRoomHintTimer = GetTimer() + HINT_DELAY + 2000
        end
        if PlayerIsInTrigger(TRIGGER._1_10_INCAGE) then
            bGiveHints = false
        end
    end
end

function Room02_BroomSwitchInit()
    --print(">>>[RUI]", "++Room02_BroomSwitchInit")
    HintsReset()
    local blip = AddBlipForProp(TRIGGER._ANIBROOM, 0, 1)
    ObjectiveBlipUpdate(blip)
    gRoomHintTimer = nil
    gMissionStage = Room02_BroomSwitchLoop
end

function Room02_BroomSwitchLoop()
    if SwitchCheck(ROOM_02) then
        SwitchDeactivate(ROOM_02)
        bGiveHints = false
        NIS_OpenDoor(TRIGGER._JANDOORS02, ROOM_02, PATH._1_10_ROOM03)
        gMissionStage = Room03_ElectricInit
    else
        Room02_HintCheck()
    end
end

local gRoom02Hints = { 30, 31 }

function Room02_HintCheck()
    if bGaryRoom02 and bGiveHints and PlayerIsInTrigger(TRIGGER._1_10_ROOM2) then
        if gRoomHintTimer then
            if TimerPassed(gRoomHintTimer) and not SoundSpeechPlaying(gGary) then
                event = RandomTableElement(gRoom02Hints)
                SoundPlayScriptedSpeechEvent(gGary, "M_1_10", event, "supersize")
                gRoomHintTimer = gRoomHintTimer + HINT_DELAY + math.random(2000, 5000)
                gHintCount = gHintCount + 1
                if gHintCount == MAX_HINTS then
                    local blip = AddBlipForProp(TRIGGER._ANIBROOM, 0, 1)
                    ObjectiveBlipUpdate(blip)
                end
            end
        elseif not bOpeningHint then
            SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 28, "supersize")
            bOpeningHint = true
        else
            gRoomHintTimer = GetTimer() + HINT_DELAY + 2000
        end
    end
end

function cbBroomHit()
    --print(">>>[RUI]", "!!cbBroomHit")
    bBroomHit = true
end

function Room03_ElectricInit()
    --print(">>>[RUI]", "++Room03_ElectricInit")
    HintsReset()
    bSwitchCheck = true
    local bx, by, bz = GetPointFromPointList(POINTLIST._1_10_ELECBLIP, 1)
    local blip = BlipAddXYZ(bx, by, bz, 0, 1)
    ObjectiveBlipUpdate(blip)
    ElectricArcsInit()
    ElectricNoGoZone(true)
    CreateThread("T_GaryTurnOffElectric")
    TutorialStart("CRAWLING1")
    gRoomHintTimer = nil
    gMissionStage = Room03_ElectricLoop
end

function T_GaryTurnOffElectric()
    --print(">>>[RUI]", "++T_GaryTurnOffElectric")
    while not PlayerIsInTrigger(TRIGGER._1_10_CRAWL_ELEC) do
        Wait(10)
    end
    bGiveHints = false
    SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 37, "jumbo")
    while not PlayerIsInTrigger(TRIGGER._1_10_GARY_TURN_OFF_ELEC) do
        Wait(10)
    end
    PedStop(gGary)
    Wait(10)
    --print(">>>[RUI]", "send gary")
    PedMoveToPoint(gGary, 0, POINTLIST._1_10_GARYSWITCHELEC, 1, cbGaryAtSwitch, 0.3)
    while not bGaryAtSwitch do
        Wait(0)
    end
    --print(">>>[RUI]", "GaryArrived")
    PedSetActionNode(gGary, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
    while PedIsPlaying(gGary, "/Global/WProps/Peds/ScriptedPropInteract", true) do
        Wait(0)
    end
    ElectricArcsOff()
    ElectricNoGoZone(false)
    AreaSetDoorLocked(TRIGGER._JANDOORS03B, false)
    AreaSetDoorLockedToPeds(TRIGGER._JANDOORS03B, false)
    bSwitchCheck = false
    --print(">>>[RUI]", "--T_GaryTurnOffElectric")
end

function cbGaryAtSwitch()
    --print(">>>[RUI]", "!!cbGaryAtSwitch")
    bGaryAtSwitch = true
end

function Room03_ElectricLoop()
    if SwitchCheck(ROOM_03) then
        SwitchDeactivate(ROOM_03)
        bGiveHints = false
        if PAnimIsOpen(TRIGGER._JANDOORS03B) then
            NIS_Room03DoorOpen()
            gMissionStage = Room04_FurnaceRoomInit
        end
    else
        Room03_HintCheck()
    end
end

function NIS_Room03DoorOpen()
    --print(">>>[RUI]", "!!NIS_Room03DoorOpen")
    SoundStopCurrentSpeechEvent(gGary)
    SoundSetAudioFocusCamera()
    CameraSetWidescreen(true)
    F_MakePlayerSafeForNIS(true)
    PlayerSetControl(0)
    --print("door 4")
    CameraSetFOV(70)
    CameraSetXYZ(-754.04944, -76.997116, 10.207438, -754.346, -76.04292, 10.174994)
    Wait(600)
    SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 47, "supersize")
    while SoundSpeechPlaying(gGary) do
        Wait(0)
    end
    PedFollowPath(gGary, PATH._1_10_ROOM04, 0, 1, cbGaryRoomPath)
    Wait(1000)
    CameraSetWidescreen(false)
    CameraDefaultFOV()
    CameraReturnToPlayer()
    SoundSetAudioFocusPlayer()
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
end

function Room03_HintCheck()
    if bGaryRoom03 and bGiveHints and PlayerIsInTrigger(TRIGGER._1_10_ROOM3) then
        if gRoomHintTimer then
            if TimerPassed(gRoomHintTimer) and not SoundSpeechPlaying() then
                SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 39, "supersize")
                gRoomHintTimer = GetTimer() + HINT_DELAY + math.random(3000, 5000)
                gHintCount = gHintCount + 1
                if not bSwitchBlipped then
                    --print(">>>[RUI]", "Room03_HintCheck BLINK blip")
                    local bx, by, bz = GetPointFromPointList(POINTLIST._1_10_ELECBLIP, 1)
                    local blip = BlipAddXYZ(bx, by, bz, 0, 1)
                    ObjectiveBlipUpdate(blip)
                    bSwitchBlipped = true
                end
            end
        elseif not bOpeningHint then
            SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 33, "supersize")
            bOpeningHint = true
        else
            gRoomHintTimer = GetTimer() + HINT_DELAY + 4000
        end
    end
    if PlayerIsInTrigger(TRIGGER._1_10_CROUCHHINT) and not PedGetFlag(gPlayer, 3) then
        TextPrint("1_10_CRAWL", 0.1, 3)
    end
end

function ElectricArcsInit()
    local n = GetPointListSize(POINTLIST._JANELECPTS)
    gElectricArcs = {}
    for i = 1, n do
        gElectricArcs[i] = FXCreateWithDirection("ElectrocuteLRG", POINTLIST._JANELECPTS, i, 1, 0, 0)
    end
    SoundEmitterEnable("PlasmaBall", true)
    bElectricArcsOn = true
    --print(">>>[RUI]", "++ElectricArcsInit+")
end

function ElectricArcsOff()
    if not bElectricArcsOn then
        return
    end
    for _, arc in gElectricArcs do
        EffectKill(arc)
    end
    SoundEmitterEnable("PlasmaBall", false)
    bElectricArcsOn = false
    --print(">>>[RUI]", "--ElectricArcsOff")
end

function T_ElectricityBackOn()
    --print(">>>[RUI]", "++T_ElectricityBackOn")
    Wait(4000)
    ElectricArcsInit()
    PAnimSetActionNode(TRIGGER._JANSWTCH03A, "/Global/AsySwtch/Inactive", "Act/Props/AsySwtch.act")
    --print(">>>[RUI]", "--T_ElectricityBackOn")
end

function Room04_FurnaceRoomInit()
    --print(">>>[RUI]", "++Room04_FurnaceRoomInit")
    local x, y, z = GetAnchorPosition(TRIGGER._JANEXTRAFIRE)
    local blip = BlipAddXYZ(x, y, z, 0, 1)
    ObjectiveBlipUpdate(blip)
    HintsReset()
    SteamInit()
    SteamNoGoZone(true)
    FiresCreate()
    while not PlayerIsInTrigger(TRIGGER._1_10_ROOM4) do
        Wait(20)
    end
    gMissionStage = Room04_FurnaceRoomLoop
end

function Room04_FurnaceRoomLoop()
    if SwitchCheck(ROOM_04) then
        bGiveHints = false
        SteamNoGoZone(false)
        NIS_Room04DoorOpen()
        local blip = BlipAddPoint(POINTLIST._1_10_HOLEBILIP, 0, 1, 1, 7, 0)
        ObjectiveBlipUpdate(blip)
        while not PlayerIsInTrigger(TRIGGER._AFTERSTEAM) do
            Wait(0)
        end
        SteamInit()
        SteamNoGoZone(true)
        gMissionStage = Room05_EnterHoleInit
        --print(">>>[RUI]", "--Room04_FurnaceRoomLoop")
    else
        Room04_HintCheck()
    end
end

local gRoom04Hints = { 42, 43 }

function Room04_HintCheck()
    if bGaryRoom04 and bGiveHints and PlayerIsInTrigger(TRIGGER._1_10_ROOM4) then
        if PlayerIsInTrigger(TRIGGER._1_10_ATFURNACE) and PlayerHasWeapon(326) and not bMessageShown then
            TutorialShowMessage("1_10_FURNEXT", 6000)
            bMessageShown = true
        end
        if gRoomHintTimer then
            if TimerPassed(gRoomHintTimer) then
                event = RandomTableElement(gRoom04Hints)
                SoundPlayScriptedSpeechEvent(gGary, "M_1_10", event, "supersize")
                gRoomHintTimer = gRoomHintTimer + HINT_DELAY + math.random(2000, 5000)
                gHintCount = gHintCount + 1
                if gHintCount == MAX_HINTS then
                    local x, y, z = GetAnchorPosition(TRIGGER._JANEXTRAFIRE)
                    local blip = BlipAddXYZ(x, y, z, 0, 1)
                    ObjectiveBlipUpdate(blip)
                end
            end
        elseif not bOpeningHint then
            SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 41, "supersize")
            bOpeningHint = true
        else
            gRoomHintTimer = GetTimer() + HINT_DELAY + 2000
        end
    end
end

function NIS_Room04DoorOpen()
    --print(">>>[RUI]", "!!NIS_Room04DoorOpen")
    SoundStopCurrentSpeechEvent(gGary)
    SoundSetAudioFocusCamera()
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    CameraSetFOV(70)
    CameraSetXYZ(-756.5916, -65.32355, 9.873087, -757.0953, -64.46868, 9.997118)
    Wait(500)
    SteamOff()
    FiresCleanup()
    SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 44, "supersize")
    while SoundSpeechPlaying(gGary) do
        Wait(0)
    end
    PedFollowPath(gGary, PATH._1_10_ROOM05, 0, 1, cbGaryRoomPath)
    Wait(1000)
    CameraSetWidescreen(false)
    SoundSetAudioFocusPlayer()
    CameraDefaultFOV()
    CameraReturnToPlayer()
    PlayerSetControl(1)
end

function SteamInit()
    --print(">>>[RUI]", "++SteamInit")
    gSteam = {}
    local n = GetPointListSize(POINTLIST._JANSTEAMPTS)
    for i = 1, n do
        gSteam[i] = FXCreateWithDirection("steam_pipe", POINTLIST._JANSTEAMPTS, i, 1, 0, 0)
    end
    bSteamOn = true
end

function SteamOff()
    --print(">>>[RUI]", "--SteamOff")
    if bSteamOn then
        for _, steam in gSteam do
            EffectSlowKill(steam, 3.5, true)
        end
    end
    bSteamOn = false
end

function Room05_EnterHoleInit()
    --print(">>>[RUI]", "++Room05_EnterHoleInit")
    local blip = BlipAddPoint(POINTLIST._1_10_HOLEBILIP, 0, 1, 1, 7, 0)
    ObjectiveBlipUpdate(blip)
    HintsReset()
    gRoomHintTimer = nil
    gMissionStage = Room05_EnterHoleLoop
    bGaryAttacked = false
    PedSetMinHealth(gGary, 50)
end

function Room05_EnterHoleLoop()
    if not bGaryToHole and PlayerIsInTrigger(TRIGGER._1_10_NEARHOLE) then
        local blip = BlipAddPoint(POINTLIST._1_10_HOLEBILIP, 0, 1, 1, 7, 0)
        ObjectiveBlipUpdate(blip)
        SoundPlayScriptedSpeechEvent(gGary, "M_1_10", 49, "supersize")
        PedFollowPath(gGary, PATH._1_10_ENTERHOLE, 0, 1)
        bGaryToHole = true
    end
    if PlayerIsInTrigger(TRIGGER._1_10_THEHOLE) or bGaryAttacked then
        Wait(700)
        gMissionState = MISSION_PASS
        gMissionStage = nil
    end
end

function BlipClean(blip)
    --print(">>>[RUI]", "!!BlipClean")
    if blip and blip ~= -1 then
        BlipRemove(blip)
    end
    return nil
end

function MakeAmbient(ped)
    if F_PedExists(ped) then
        PedMakeAmbient(ped)
    end
    return nil
end

function ObjectiveBlipUpdate(newBlip)
    --print(">>>[RUI]", "!!ObjectiveBlipUpdate")
    if newBlip then
        BlipClean(gObjectiveBlip)
        gObjectiveBlip = newBlip
    elseif gObjectiveBlip then
        gObjectiveBlip = BlipClean(gObjectiveBlip)
    end
end

function SetCharacterModelsUnique(bOn, models)
    if not gUniqueModels then
        gUniqueModels = {}
    end
    if bOn then
        --print(">>>[RUI]", "++SetCharacterModelsUnique")
        if not models then
            return
        end
        for _, m in models do
            u = PedGetUniqueModelStatus(m)
            PedSetUniqueModelStatus(m, -1)
            table.insert(gUniqueModels, { model = m, unique = u })
        end
    else
        --print(">>>[RUI]", "--SetCharacterModelsUnique")
        if not gUniqueModels then
            return
        end
        for _, m in gUniqueModels do
            if m.unique then
                PedSetUniqueModelStatus(m.model, m.unique)
            end
        end
    end
end

function MissionSetup()
    MissionDontFadeIn()
    DATLoad("1_10.DAT", 2)
    DATInit()
    DisablePOI(true, true)
    AreaOverridePopulationPedType(11, 0)
end

function MissionInit()
    LoadModels({
        23,
        10,
        19,
        37
    })
    LoadModels({
        102,
        99,
        85
    })
    LoadModels({ 130, 362 })
    LoadWeaponModels({ 326, 303 })
    LoadAnimationGroup("1_10Betrayal")
    LoadAnimationGroup("Px_RedButton")
    LoadAnimationGroup("MINI_Lock")
    LoadActionTree("Act/Anim/1_10.act")
    LoadActionTree("Act/Props/Switch.act")
    LoadActionTree("Act/Props/AsySwtch.act")
    LoadActionTree("Act/Anim/Funhouse.act")
    SoundLoadBank("MISSION\\1_10.bnk")
    AreaLoadSpecialEntities("TombstonePost", true)
    AreaLoadSpecialEntities("PumpkinPost", true)
    AreaTransitionPoint(0, POINTLIST._1_10_PSTART_MM)
    --print(">>>[RUI]", "++DEBUG make sure player has a slingshot")
    gGary = GaryCreate(POINTLIST._1_10_NEMESIS_MM)
    AreaSetDoorLocked("DT_TSCHOOL_SCHOOLSIDEDOORL", true)
    AreaSetDoorLocked("TSCHOOL_SCHOOLSIDEDOORR", true)
end

function MissionCleanup()
    RadarRestoreMinMax()
    TutorialRemoveMessage()
    shared.on_mission_110 = false
    PlayerSetControl(1)
    SoundStopInteractiveStream()
    MissionAllowAmbientTransitions(true)
    --print(">>>[RUI]", "1.10 MissionCleanup()")
    gBully1 = MakeAmbient(gBully1)
    gBully2 = MakeAmbient(gBully2)
    gBully3 = MakeAmbient(gBully3)
    gBully1Blip = BlipClean(gBully1Blip)
    gBully2Blip = BlipClean(gBully2Blip)
    gBully3Blip = BlipClean(gBully3Blip)
    if bMissionFailed then
        if bInBasement and not F_PedIsDead(gPlayer) then
            PlayerSetPosPoint(POINTLIST._1_10_FAILURE, 1)
        end
        AreaSetDoorLocked("DT_TSCHOOL_SCHOOLSIDEDOORL", true)
        AreaSetDoorLockedToPeds("DT_TSCHOOL_SCHOOLSIDEDOORL", true)
    end
    GaryCleanup()
    FiresCleanup()
    ElectricArcsOff()
    SteamOff()
    ElectricNoGoZone(false)
    SteamNoGoZone(false)
    if basement_triggers_locked then
        AreaSetDoorLocked("DT_JANITOR_MAINEXIT", false)
        AreaSetDoorLocked("DT_JANITOR_SCHOOLEXIT", false)
    end
    UnLoadAnimationGroup("1_10Betrayal")
    UnLoadAnimationGroup("Px_RedButton")
    UnLoadAnimationGroup("MINI_Lock")
    SoundUnLoadBank("MISSION\\1_10.bnk")
    F_SetCharacterModelsUnique(false)
    EnablePOI()
    AreaRevertToDefaultPopulation()
    DATUnload(2)
    CameraSetWidescreen(false)
    collectgarbage()
end

function main()
    CS_Intro()
    gMissionStage = Stage00_FollowGaryInit
    while gMissionState == MISSION_RUNNING do
        if gMissionStage then
            gMissionStage()
        end
        if F_PedIsDead(gPlayer) then
            bMissionFailed = true
            gMissionState = MISSION_FAIL
        end
        Wait(10)
    end
    ObjectiveBlipUpdate(nil)
    if gMissionState == MISSION_PASS then
        bMissionFailed = false
        gObjectiveBlip = BlipClean(gObjectiveBlip)
        AudienceCreate()
        if PlayerHasWeapon(326) or PlayerHasItem(326) then
            PedSetWeaponNow(gPlayer, -1, 0)
        end
        MissionSucceed(true, false, false)
    else
        fadeout = bInBasement
        SoundPlayMissionEndMusic(false, 10)
        if gFailMessage == "1_10_Fail1" and not bInBasement then
            MissionFail(false, true, gFailMessage)
        elseif gFailMessage then
            MissionFail(fadeout, true, gFailMessage)
        else
            MissionFail(fadeout, true)
        end
    end
end

function FiresCreate()
    triggerFire = {}
    triggerFire.trigger = TRIGGER._JANEXTRAFIRE
    triggerFire.fx = FireCreate(triggerFire.trigger, FIREHEALTH, FIREDAMAGE, 100, 115, "boilerfire2")
    fire1 = FireCreate(TRIGGER._JANFIRE01, FIREHEALTH, FIREDAMAGE, 100, 115, "boilerfire2")
    fire2 = FireCreate(TRIGGER._JANFIRE02, FIREHEALTH, FIREDAMAGE, 100, 115, "boilerfire2")
    bFiresCreated = true
    --print(">>>[RUI]", "++FiresCreate")
    Wait(1000)
end

function FiresCleanup()
    if not bFiresCreated then
        return
    end
    FireDestroy(fire1)
    FireDestroy(fire2)
    FireDestroy(triggerFire.fx)
    bFiresCreated = false
    --print(">>>[RUI]", "--FiresCleanup()")
end
