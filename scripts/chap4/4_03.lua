--[[ Changed to:
    * Modified function F_NISFail, may require testing
]]

local nFirstBarricadeJockNumber = 6
local nSecondBarricadeJockNumber = 10
local tblPedModels = {
    11,
    6,
    7,
    5,
    9,
    8,
    18,
    17,
    109,
    111,
    16,
    10,
    110
}
local tblPickupModels = { 316, 362 }
local tblWeaponModels = {
    305,
    307,
    303
}
local tblNerdDefenders1 = {}
local tblJockWave1 = {}
local tblJockWave2 = {}
local tblNerdModels = {
    11,
    9,
    8,
    7
}
local bDefend1, bDefend2, bDefend3 = false
local reserves = -1
local CurrentTarget, CurrentEscapeTrigger, CurrentEscapeTriggerFinal
local mission_success = false
local MISSION_SUCCESS = 1
local MISSION_FAILURE = 0
local objGotoBarricade, objDefendFirstBarricade, objReturnObservatory, objMountSpudGun, objDefendSecondBarricade, objDefendDoors, szFailReason

function MissionSetup()
    PlayCutsceneWithLoad("4-03", true, true, true)
    MissionDontFadeIn()
    DATLoad("4_03.DAT", 2)
    DATInit()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaClearAllPeds()
end

function main()
    SoundPlayInteractiveStreamLocked("MS_EpicConfrontationLow.rsm", MUSIC_DEFAULT_VOLUME, 500, 500)
    F_CreateBarricades()
    LoadModels(tblPedModels)
    LoadModels(tblPickupModels)
    LoadWeaponModels(tblWeaponModels)
    LoadActionTree("Act/Conv/4_03.act")
    AreaTransitionPoint(0, POINTLIST._4_03_PLAYER_START, nil, true)
    CameraFade(1000, 1)
    DisablePOI()
    F_SetupMission()
    CurrentEscapeTrigger = TRIGGER._4_03_JOCK_PAST_WATER
    CurrentEscapeTriggerFinal = TRIGGER._4_03_LEAVE1
    CreateThread("T_FailureConditions")
    F_DefendFirstBarricade()
    F_DefendSecondBarricade()
    if mission_success == MISSION_FAILURE then
    else
        mission_success = MISSION_SUCCESS
    end
    Wait(10000)
end

function MissionCleanup()
    if mission_success == MISSION_FAILURE then
        AreaEnsureSpecialEntitiesAreCreatedWithOverride("1_03", 1)
    end
    PedSetInvulnerable(gPlayer, false)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
    CameraReturnToPlayer()
    SoundStopInteractiveStream()
    F_ClearPedTable(tblJockWave1, true)
    F_ClearPedTable(tblNerdDefenders1, false)
    AreaSetPathableInRadius(19.8, -127.1, 2.8, 0.1, 5, true)
    AreaSetPathableInRadius(18.2, -116.7, 3, 0.1, 5, true)
    AreaSetPathableInRadius(19, -141.1, 2.8, 0.1, 5, true)
    AreaSetPathableInRadius(8.7, -139.7, 2.8, 1, 5, true)
    EnablePOI()
    AreaSetDoorLocked(TRIGGER._SCGATE_OBSERVATORY, false)
    AreaSetDoorLockedToPeds("SCGATE_OBSERVATORY", false)
    PedHideHealthBar()
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    PedResetTypeAttitudesToDefault()
    AreaRevertToDefaultPopulation()
    UnLoadAnimationGroup("F_JOCKS")
    UnLoadAnimationGroup("DodgeBall")
    DATUnload(2)
end

function F_AnyJocksAlive()
    local tblObjectsFound = {}
    local x, y, z = GetPointList(POINTLIST._4_03_NERD_D2)
    tblObjectsFound = {
        PedFindInAreaXYZ(x, y, z, 16)
    }
    for i, entry in tblObjectsFound do
        if entry == gPlayer then
            table.remove(tblObjectsFound, i)
            --print("REMOVING ZERO")
        elseif not PedIsValid(entry) then
            table.remove(tblObjectsFound, i)
            --print("REMOVING INVALID")
        elseif PedIsValid(entry) and PedGetFaction(entry) == 1 then
            table.remove(tblObjectsFound, i)
            --print("REMOVING NONJOCK")
        end
    end
    while true do
        Wait(0)
    end
end

function F_SetupMission()
    WeatherSet(0)
    AreaSetDoorLocked("SCGATE_OBSERVATORY", false)
    AreaSetDoorLockedToPeds("SCGATE_OBSERVATORY", true)
    AreaSetDoorPathableToPeds(TRIGGER._SCGATE_OBSERVATORY, true)
    AreaSetDoorLocked(TRIGGER._SCGATE_OBSERVATORY, false)
    PAnimOpenDoor(TRIGGER._SCGATE_OBSERVATORY)
    AreaSetPathableInRadius(1.1, -113, 2.1, 0.5, 5, true)
    AreaSetPathableInRadius(19.8, -127.1, 2.8, 0.1, 5, false)
    AreaSetPathableInRadius(18.2, -116.7, 3, 0.1, 5, false)
    AreaSetPathableInRadius(19, -141.1, 2.8, 0.1, 5, false)
    AreaSetPathableInRadius(8.7, -139.7, 2.8, 1, 5, false)
    PlayerSetWeapon(305, 25)
    GiveAmmoToPlayer(316, 25)
    melvin = PedCreatePoint(6, POINTLIST._4_03_MELVIN)
    PedMakeTargetable(melvin, false)
    PedSetHealth(melvin, 100)
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaClearAllPeds()
    PedSetTypeToTypeAttitude(1, 13, 4)
    PedSetTypeToTypeAttitude(1, 2, 0)
    PedSetTypeToTypeAttitude(2, 1, 0)
    PedSetTypeToTypeAttitude(2, 13, 0)
    PAnimSetActionNode(TRIGGER._4_03_OBSDOOR, "/Global/OBSDoor/PlayOpenAnim", "Act/Props/OBSDoor.act")
    Wait(2000)
    CameraFade(1000, 1)
end

function F_CreateBarricades()
    PAnimCreate(TRIGGER._4_03_BAR_05_02, false, true)
    PAnimCreate(TRIGGER._4_03_BAR_05_01, false, true)
    PAnimOverrideDamage(TRIGGER._4_03_BAR_05_02, 500)
    PAnimOverrideDamage(TRIGGER._4_03_BAR_05_01, 500)
    PAnimOverrideDamage(TRIGGER._DT_OBSERVATORY, 300)
end

function F_DefendFirstBarricade()
    local objective = MissionObjectiveAdd("4_03_21")
    local x, y, z = GetAnchorPosition(TRIGGER._4_03_BAR_05_02)
    local blip = BlipAddXYZ(x, y, z, 0)
    CurrentTarget = TRIGGER._4_03_BAR_05_02
    reserves = nFirstBarricadeJockNumber
    bDefend1 = false
    PAnimShowHealthBar(TRIGGER._4_03_BAR_05_02, true, "4_03_14")
    AreaSetPathableInRadius(1.1, -113, 2.1, 0.5, 5, true)
    TextPrint("4_03_21", 3, 1)
    PAnimSetActionNode(TRIGGER._4_03_OBSDOOR, "/Global/OBSDoor/PlayOpenAnim", "Act/Props/OBSDoor.act")
    F_CreatePedCover(7, POINTLIST._4_03_B2_J_P1, tblNerdDefenders1, 1, POINTLIST._4_03_NERD_D_WAVE1_04)
    F_CreatePedCover(5, POINTLIST._4_03_B2_J_L1, tblNerdDefenders1, 1, POINTLIST._4_03_NERD_D_WAVE1_03)
    F_CreatePedCover(9, POINTLIST._4_03_B2_J_L2, tblNerdDefenders1, 1, POINTLIST._4_03_NERD_D_WAVE1_06)
    F_CreatePedCover(8, POINTLIST._4_03_B2_J_L3, tblNerdDefenders1, 1, POINTLIST._4_03_NERD_D_WAVE1_02)
    while not (PlayerIsInTrigger(TRIGGER._4_03_TRIGGER_WAVE1) or F_CurrentTargetBreached()) do
        Wait(0)
    end
    MissionObjectiveComplete(objective)
    objective = MissionObjectiveAdd("4_03_07")
    TextPrint("4_03_07", 3, 1)
    SoundPlayInteractiveStreamLocked("MS_EpicConfrontationHigh.rsm", 0.7, 500, 500)
    F_PlaySpeechOnModel(7, 3, tblNerdDefenders1)
    for _, entry in tblNerdDefenders1 do
        PedClearAllWeapons(entry.id)
        PedIgnoreStimuli(entry.id, true)
        PedSetWeapon(entry.id, 307, 99)
    end
    F_TableTakeCover(tblNerdDefenders1, true)
    F_CreateJockCover(18, POINTLIST._4_03_JOCK_SPAWN_GOTO_P1, tblJockWave1, 1, POINTLIST._4_03_JOCK_P1)
    F_CreateJockCover(17, POINTLIST._4_03_JOCK_SPAWN_GOTO_L3, tblJockWave1, 1, POINTLIST._4_03_JOCK_P2)
    F_CreateJockCharger(109, POINTLIST._4_03_JOCK_SPAWN_GOTO_L1, tblJockWave1, 1, CurrentTarget, 3, 0)
    F_CreateJockCharger(111, POINTLIST._4_03_JOCK_SPAWN_GOTO_L2, tblJockWave1, 1, CurrentTarget, 5, 0)
    --print("F_ClearPedTable Complete: Current Size: " .. table.getn(tblJockWave1))
    Wait(2500)
    F_PlaySpeechOnModel(5, 2, tblNerdDefenders1)
    while not bDefend1 do
        Wait(0)
        if table.getn(tblJockWave1) == 0 then
            bDefend1 = "success"
            --print(table.getn(tblJockWave1))
        elseif PAnimGetHealth(TRIGGER._4_03_BAR_05_02) == 0 then
            SoundPlayScriptedSpeechEvent_2D("M_4_03_2D", 8)
            F_ClearPedTable(tblJockWave1)
            F_ClearPedTable(tblNerdDefenders1)
            bDefend1 = "failure"
        end
        F_JockAssaultManager(tblJockWave1, reserves)
    end
    PAnimHideHealthBar()
    if bDefend1 == "success" then
    elseif bDefend1 == "failure" then
        F_PlaySpeechOnModel(8, 11, tblNerdDefenders1)
    end
    MissionObjectiveComplete(objective)
    BlipRemove(blip)
end

function F_GetToSecondBarricade()
end

function F_DefendSecondBarricade()
    local objective = MissionObjectiveAdd("4_03_01")
    local x, y, z = GetAnchorPosition(TRIGGER._4_03_OB_BAR2)
    local blip = BlipAddPoint(POINTLIST._4_03_BLIPCANNONFIRST, 0, 1, 1)
    local gunObjective
    reserves = nSecondBarricadeJockNumber
    bDefend2 = false
    bDefend3 = false
    CurrentTarget = TRIGGER._4_03_OB_BAR2
    TextPrint("4_03_01", 3, 1)
    PAnimSetActionNode(TRIGGER._4_03_OBSDOOR, "/Global/OBSDoor/PlayOpenAnim", "Act/Props/OBSDoor.act")
    F_CreatePedCover(7, POINTLIST._4_03_N_UD_2, tblNerdDefenders1, 1, POINTLIST._4_03_N_UD_2)
    F_CreatePedCover(8, POINTLIST._4_03_N_UD_1, tblNerdDefenders1, 1, POINTLIST._4_03_N_UD_1)
    local msgGetOnCannon, msgDefendObservatory = false
    for i = 1, GetPointListSize(POINTLIST._4_03_FRAFFYCANS) do
        PickupCreatePoint(362, POINTLIST._4_03_FRAFFYCANS, i, 0)
    end
    MissionTimerStart(70)
    SoundPlayInteractiveStreamLocked("MS_EpicConfrontationLow.rsm", MUSIC_DEFAULT_VOLUME, 500, 500)
    while not (MissionTimerHasFinished() or PlayerIsInTrigger(TRIGGER._4_03_OPEN_DOOR)) do
        Wait(0)
    end
    if PlayerIsInTrigger(TRIGGER._4_03_OPEN_DOOR) then
        MissionObjectiveComplete(objective)
        SoundPlayScriptedSpeechEvent_2D("M_4_03_2D", 16)
        TextPrint("4_03_22", 4, 1)
        gunObjective = MissionObjectiveAdd("4_03_22")
        BlipRemove(blip)
        blip = AddBlipForProp(TRIGGER._SCHOOL_TURRET, 0, 4)
        msgGetOnCannon = true
    elseif MissionTimerHasFinished() then
        szFailReason = "4_03_FAILREACH"
        SoundPlayMissionEndMusic(false, 4)
        MissionFail(true, true, szFailReason)
        Wait(50000)
    end
    while not (MissionTimerHasFinished() or PedIsPlaying(gPlayer, "/Global/WPCANNON/UseSpudCannon", true)) do
        Wait(0)
    end
    if gunObjective then
        MissionObjectiveComplete(gunObjective)
    end
    MissionTimerStop()
    objective = MissionObjectiveAdd("4_03_23")
    TextPrint("4_03_23", 3, 1)
    CurrentEscapeTrigger = TRIGGER._4_03_OPEN_DOOR
    CurrentEscapeTriggerFinal = TRIGGER._4_03_LEAVE2
    F_TableTakeCover(tblNerdDefenders1)
    SoundPlayScriptedSpeechEvent_2D("M_4_03_2D", 17)
    Wait(6000)
    F_PlaySpeechOnModel(8, 13, tblNerdDefenders1)
    for _, entry in tblNerdDefenders1 do
        PedClearAllWeapons(entry.id)
        PedIgnoreStimuli(entry.id, true)
        PedSetWeapon(entry.id, 307, 99)
    end
    F_PlaySpeechOnModel(5, 2, tblNerdDefenders1)
    F_CreateJockCover(18, POINTLIST._4_03_SPAWNTWO1, tblJockWave2, 1, POINTLIST._4_03_JOCK_B2_2W_P1_2)
    F_CreateJockCover(17, POINTLIST._4_03_SPAWNTWO2, tblJockWave2, 1, POINTLIST._4_03_B2_J_P1_2)
    F_CreateJockCover(16, POINTLIST._4_03_SPAWNTWO3, tblJockWave2, 1, POINTLIST._4_03_B2_J_P2_2)
    F_CreateJockCharger(109, POINTLIST._4_03_SPAWNTWO4, tblJockWave1, 1, CurrentTarget, 0, 0)
    F_CreateJockCharger(111, POINTLIST._4_03_SPAWNTWO5, tblJockWave1, 1, CurrentTarget, 0, 0)
    --print("F_ClearPedTable Complete: Current Size: " .. table.getn(tblJockWave1))
    --print("bDefend1", bDefend1)
    local AuxiliaryTimer
    if bDefend1 == "failure" then
        AuxiliaryTimer = GetTimer()
    end
    SoundPlayInteractiveStreamLocked("MS_EpicConfrontationHigh.rsm", 0.7, 500, 500)
    while not bDefend2 do
        Wait(0)
        if table.getn(tblJockWave1) == 0 then
            bDefend2 = "success"
            --print(table.getn(tblJockWave1))
        else
            CurrentTarget = TRIGGER._DT_OBSERVATORY
            F_AttackNewTarget(tblJockWave1, CurrentTarget)
            bDefend2 = "failure"
        end
        if AuxiliaryTimer and GetTimer() - AuxiliaryTimer > 18000 then
            PAnimApplyDamage("scFieldObsGate", 0.881498, -111.463, 2.00091, 9000)
            PAnimApplyDamage("scFieldObsGate", 0.821367, -113.954, 2.055, 9000)
            PAnimApplyDamage("scFieldObsGate", 0.881498, -111.463, 2.00091, 9000)
            PAnimApplyDamage("scFieldObsGate", 0.821367, -113.954, 2.055, 9000)
            F_CreateJockCover(17, POINTLIST._4_03_JOCK_B2_2W_L2, tblJockWave2, 1, POINTLIST._4_03_AUXCOVER2)
            F_CreateJockCover(16, POINTLIST._4_03_JOCK_B2_2W_P1, tblJockWave2, 1, POINTLIST._4_03_AUXCOVER3)
            F_CreateJockCharger(109, POINTLIST._4_03_AUXSPAWN1, tblJockWave1, 1, CurrentTarget, 0, 0)
            F_CreateJockCharger(111, POINTLIST._4_03_AUXSPAWN2, tblJockWave1, 1, CurrentTarget, 0, 0)
            AuxiliaryTimer = nil
        end
        F_JockAssaultManager(tblJockWave1, reserves)
    end
    while not bDefend3 do
        Wait(0)
        if table.getn(tblJockWave1) == 0 then
            bDefend3 = "success"
            --print(table.getn(tblJockWave1))
        elseif PAnimGetHealth(TRIGGER._DT_OBSERVATORY) == 0 then
            CurrentTarget = TRIGGER._DT_OBSERVATORY
            F_AttackNewTarget(tblJockWave1, CurrentTarget)
            bDefend3 = "failure"
            mission_success = MISSION_FAILURE
        end
        F_JockAssaultManager(tblJockWave1, reserves)
    end
    MissionObjectiveComplete(objective)
    BlipRemove(blip)
end

function F_CreatePedCover(model, point, dataTable, element, coverPoint)
    local ped = PedCreatePoint(model, point, element)
    PedMakeTargetable(ped, false)
    PedSetPedToTypeAttitude(ped, 13, 4)
    table.insert(dataTable, { id = ped, cover = coverPoint })
end

function F_CreateJockCover(model, point, dataTable, element, coverPoint)
    local ped = PedCreatePoint(model, point, element)
    if dataTable then
        table.insert(dataTable, {
            id = ped,
            cover = coverPoint,
            modenum = model,
            pointlist = point
        })
        --print("INSERTING COVER JOCK, Total Table Size: " .. table.getn(dataTable))
    end
    PedSetWeapon(ped, 303, 99)
    PedCoverSet(ped, nil, coverPoint, 100, 35, 2, 0, 1, 1, 1, 1, 1, 0, 0, true)
    PedSetFlag(ped, 21, false)
    PedSetFlag(ped, 13, true)
    PedAlwaysUpdateAnimation(ped, true)
    PedIgnoreStimuli(ped, true)
    return ped
end

function F_CreateJockCharger(model, point, dataTable, element, targetProp, offsetX, offsetY)
    local ped = PedCreatePoint(model, point, element)
    if dataTable then
        table.insert(dataTable, {
            id = ped,
            modenum = model,
            pointlist = point,
            target = CurrentTarget,
            x = offsetX,
            y = offsetY
        })
        --print("INSERTING CHARGER JOCK, Total Table Size: " .. table.getn(dataTable))
    end
    PedIgnoreStimuli(ped, true)
    PedIgnoreAttacks(ped, true)
    AddBlipForChar(ped, 12, 2, 2)
    PedAttackProp(ped, targetProp)
    PedAlwaysUpdateAnimation(ped, true)
    return ped
end

function F_PlaySpeechOnModel(model, event, dataTable)
    for i, entry in dataTable do
        --print("X")
        if PedIsModel(entry.id, model) then
            --print("XA")
            SoundPlayScriptedSpeechEvent(entry.id, "M_4_03", event, "large")
            --print("XB")
            break
        end
    end
end

function F_TableTakeCover(dataTable, bNeverLeave)
    if bNeverLeave == nil then
        bNeverLeave = false
    end
    for _, entry in dataTable do
        if entry.cover then
            PedCoverSet(entry.id, nil, entry.cover, 100, 35, 2, 0, 1, 1, 0, 1, 1, 0, 0, bNeverLeave)
        end
    end
end

function F_JockAssaultManager(tableToCheck, reinforcements)
    for i, entry in tblJockWave1 do
        if PedGetHealth(entry.id) <= 0 then
            PedMakeAmbient(entry.id)
            if 0 < reserves then
                if entry.cover then
                    entry.id = F_CreateJockCover(entry.modenum, entry.pointlist, nil, 1, entry.cover)
                elseif entry.target then
                    entry.id = F_CreateJockCharger(entry.modenum, entry.pointlist, nil, 1, entry.target, entry.x, entry.y)
                end
                reserves = reserves - 1
            else
                --print("Removing Jock Index: " .. i)
                table.remove(tblJockWave1, i)
            end
        end
        if PedIsValid(entry.id) and PedIsInTrigger(entry.id, TRIGGER._4_03_OB_GROUNDS) then
            mission_success = MISSION_FAILURE
            szFailReason = "4_03_JOCKTHRU"
            --print("Jock Breaks Through!")
        end
        Wait(500)
    end
end

function F_ClearPedTable(dataTable, bDelete)
    while table.getn(dataTable) > 0 do
        Wait(0)
        if PedIsValid(dataTable[1].id) then
            if bDelete then
                PedDelete(dataTable[1].id)
            else
                if PedGetFaction(dataTable[1].id) == 2 then
                    --print("Setting to Hate Player... " .. PedGetFaction(dataTable[1].id), 2)
                    PedSetPedToTypeAttitude(dataTable[1].id, 13, 0)
                    PedSetPedToTypeAttitude(dataTable[1].id, 1, 0)
                    PedAttack(dataTable[1].id, gPlayer, 0)
                end
                PedIgnoreAttacks(dataTable[1].id, false)
                PedIgnoreStimuli(dataTable[1].id, false)
                PedMakeAmbient(dataTable[1].id)
            end
        end
        table.remove(dataTable, 1)
    end
    --print("F_ClearPedTable Complete: Current Size: " .. table.getn(dataTable))
end

function F_AttackNewTarget(dataTable, newTargetProp)
    for i, entry in dataTable do
        if entry.target then
            if PedIsValid(entry.id) then
                PedClearObjectives(entry.id)
                PedAttackProp(entry.id, newTargetProp)
            end
            entry.target = newTargetProp
            entry.x = 0
            entry.y = 0
        end
    end
end

function T_FailureConditions()
    local missionRunning = true
    while missionRunning do
        Wait(0)
        if mission_success == MISSION_SUCCESS then
            PedSetActionNode(gPlayer, "/Global/WPCANNON/Disengage/null", "Act/Props/WPCANNON.act")
            F_NISSucceed()
            missionRunning = false
            ObjectTypeSetPickupListOverride("DPI_CrateBrk", "PickupListCrateSpudGuns")
            ObjectTypeSetPickupListOverride("DPE_CrateBrk", "PickupListCrateSpudGuns")
            SetFactionRespect(2, GetFactionRespect(2) - 10)
            SetFactionRespect(1, GetFactionRespect(1) + 20)
            MissionSucceed(false, false, false)
        elseif mission_success == MISSION_FAILURE then
            missionRunning = false
            if szFailReason == "4_03_JOCKTHRU" then
                F_NISFail()
            elseif szFailReason then
                SoundPlayMissionEndMusic(false, 4)
                MissionFail(true, true, szFailReason)
                CameraFade(1000, 1)
            end
        end
        F_RunAwayCheck()
    end
end

function F_NISFail() -- ! Modified
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PlayerSetControl(0)
    CameraFade(700, 0)
    Wait(720)
    PedSetActionNode(gPlayer, "/Global/WPCANNON/Disengage/null", "Act/Props/WPCANNON.act")
    F_ClearPedTable(tblJockWave1, true)
    F_ClearPedTable(tblJockWave2, true)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    PedSetFlag(gPlayer, 108, true)
    F_MakePlayerSafeForNIS(true)
    PedSetInvulnerable(gPlayer, true)
    --[[
    AreaClearAllPeds()
    ]] -- Removed this
    local ped1, ped2, ped3, ped4, thad
    ped1 = PedCreatePoint(110, POINTLIST._4_03_CAMFAILJOCKS, 1)
    ped2 = PedCreatePoint(111, POINTLIST._4_03_CAMFAILJOCKS, 2)
    ped3 = PedCreatePoint(109, POINTLIST._4_03_CAMFAILJOCKS, 3)
    ped4 = PedCreatePoint(111, POINTLIST._4_03_CAMFAILJOCKS, 4)
    thad = PedCreatePoint(7, POINTLIST._4_03_MELVIN, 2)
    bucky = PedCreatePoint(8, POINTLIST._4_03_NIS_NERDS, 1)
    donald = PedCreatePoint(11, POINTLIST._4_03_NIS_NERDS, 2)
    cornelius = PedCreatePoint(9, POINTLIST._4_03_NIS_NERDS, 3)
    earnest = PedCreatePoint(10, POINTLIST._4_03_NIS_NERDS, 4)
    PedSetHealth(bucky, 0.2)
    PedSetHealth(donald, 0.2)
    PedSetHealth(cornelius, 0.2)
    PedSetHealth(melvin, 0.2)
    PedSetHealth(earnest, 0.2)
    PedSetHealth(thad, 0.2)
    PedFlee(thad, ped1)
    PedFlee(bucky, ped2)
    PedFlee(donald, ped3)
    PedFlee(earnest, ped3)
    PedSetPedToTypeAttitude(ped1, 1, 0)
    PedSetPedToTypeAttitude(ped2, 1, 0)
    PedSetPedToTypeAttitude(ped3, 1, 0)
    PedSetPedToTypeAttitude(ped4, 1, 0)
    PedMakeTargetable(melvin, true)
    PedAttack(ped1, melvin, 3)
    PedAttack(ped2, bucky, 3)
    PedAttack(ped3, donald, 3)
    PedAttack(ped4, cornelius, 3)
    SoundSetAudioFocusCamera()
    CameraSetFOV(40)
    CameraSetXYZ(23.864506, -137.62936, 3.821961, 24.769567, -137.21213, 3.90397)
    CameraFade(700, 1)
    MinigameSetCompletion("M_FAIL", false, 0, "4_03_JOCKTHRU")
    SoundPlayScriptedSpeechEvent(ped1, "FIGHT_WATCH", 0, "supersize")
    Wait(1500)
    CameraSetFOV(40)
    CameraSetXYZ(50.305546, -148.113, 5.382324, 49.789753, -147.26782, 5.242621)
    SoundPlayScriptedSpeechEvent(ped2, "FIGHT_WATCH", 0, "supersize")
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(1000, 0)
    Wait(1010)
    CameraDefaultFOV()
    PedDelete(ped1)
    PedDelete(ped2)
    PedDelete(ped3)
    PedDelete(ped4)
    PedDelete(thad)
    MissionFail(false, false)
    PedSetFlag(gPlayer, 108, false)
end

function F_NISSucceed()
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    PedSetFlag(gPlayer, 108, true)
    F_MakePlayerSafeForNIS(true)
    PedSetInvulnerable(gPlayer, true)
    CameraFade(500, 0)
    Wait(505)
    F_ClearPedTable(tblJockWave1, true)
    F_ClearPedTable(tblJockWave2, true)
    F_ClearPedTable(tblNerdDefenders1, true)
    LoadAnimationGroup("MINI_React")
    Wait(505)
    CameraFade(500, 1)
    local x, y, z = GetPointList(POINTLIST._4_03_NIS_PLAYER)
    PlayerSetPosSimple(x, y, z)
    CameraSetXYZ(29.671312, -135.59628, 8.640634, 30.552816, -135.13303, 8.731487)
    PedSetActionNode(gPlayer, "/Global/4_03/Anims/Celebrate", "Act/Conv/4_03.act")
    MinigameSetCompletion("M_PASS", true, 2500)
    MinigameAddCompletionMsg("MRESPECT_NP20", 2)
    MinigameAddCompletionMsg("MRESPECT_JM10", 1)
    SoundPlayMissionEndMusic(true, 4)
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    CameraFade(500, 0)
    Wait(505)
    PedSetFlag(gPlayer, 108, false)
    CameraFade(500, 1)
    UnLoadAnimationGroup("MINI_React")
    PedSetInvulnerable(gPlayer, false)
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
    CameraReturnToPlayer()
end

function F_RunAwayCheck()
    if not PlayerIsInTrigger(CurrentEscapeTrigger) then
        TextPrint("4_03_LEAVINGOBS", 0.3, 1)
        if not PlayerIsInTrigger(CurrentEscapeTriggerFinal) then
            mission_success = MISSION_FAILURE
            szFailReason = "4_03_LEFTOBS"
        end
    end
end

function F_DestroyCurrentTarget()
    if MissionTimerHasFinished() then
        PAnimApplyDamage(CurrentTarget, 5000)
    end
end

function F_CurrentTargetBreached()
    if PAnimGetHealth(CurrentTarget) <= 0 then
        return true
    end
end
