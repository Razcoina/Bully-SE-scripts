--[[ Changes to this file:
    * Modified function MissionInit, may require testing
    * Modified function main, may require testing
    * Modified function InterruptSheet4Wait, may require testing
    * Modified function T_SheetMonitor, may require testing
    * Modified function DropCharacterSheet, may require testing
]]

local gRewardMoney = 1000
local missionRunning = true
local sheets_collected = false
local gMelvin, gBucky, gThad, gFatty, gHealthNerd
local gBeanedCounter = 0
local BULLIES_FLEE = 0
local BULLIES_HANGOUT = 1
local gSheetGuardFleeBehaviour = BULLIES_HANGOUT
local sheet1Guard, sheet1Bruiser, sheet2Guard, sheet2Goon1, sheet3Guard, sheet4Guard
local sheet1_dropped = false
local sheet2_dropped = false
local sheet3_dropped = false
local sheet4_dropped = false
local sheet1_attack = false
local sheet2_attack = false
local sheet3_attack = false
local bNerdsEscaped = false
local bSheet3GuysHit = false
local ped, path
local marblesDropped = 0
local bMarblesMaxed = false
local MAX_SHEETS = 4
local bGotSheets = false
local sheet = 0
local gThreads = {}
local fleeTaunts = {}
local arriveTaunts = {}
local marbleTaunts = {}
local sheet4Laps = 0
local gSheetDropDelay = 2000
local gRochambeauTimeLimit = 8000
local MAX_SHEET4_LAPS = 2
local FLEE_DISTANCE = 6.7
local MARBLE_DISTANCE = 4
local MARBLE_DROP_MAX = 3
local CROUCH_DISTANCE = 6
local TAUNT_DISTANCE = 25
local gObjectiveList = {
    { objective = "2_S04_C01" },
    { objective = "2_S04_C02" },
    { objective = "2_S04_C03" },
    { objective = "2_S04_C04" }
}

function MissionThreadSetup()
    ThreadCreate("T_SheetMonitor")
    ThreadCreate("T_Sheet1AttackMonitor")
    ThreadCreate("T_Sheet2AttackMonitor")
    ThreadCreate("T_Sheet3AttackMonitor")
    ThreadCreate("T_Sheet4AttackMonitor")
end

function MissionSetup()
    --print(">>>[RUI]", "MissionSetup")
    MissionDontFadeIn()
    DATLoad("2_S04.DAT", 2)
    DATInit()
    PedSetTypeToTypeAttitude(1, 13, 4)
    LoadActionTree("Act/Anim/Overrides/Mission/2_S04Greeting.act")
    LoadActionTree("Act/Conv/2_S04.act")
    LoadActionTree("Act/Gifts/Give2S04.act")
    PedSetDefaultTypeToTypeAttitude(11, 13, 2)
    LoadAnimationGroups(true)
end

function MissionInit() -- ! Modified
    fleeTaunts = { 18 }
    arriveTaunts = {
        8,
        10,
        12,
        14
    }
    marbleTaunts = { 6, 7 }
    --[[
    PlayerSetPosPoint(POINTLIST._2_S04_START)
    ]] -- Removed this
    savedState = PedGetUniqueModelStatus(6)
    PedSetUniqueModelStatus(6, -1)
    DisablePOI()
    F_RainBeGone()
end

function CleanCharacterSheetPickups()
    F_ClearPickup(sheet1)
    F_CleanBlip(sheet1Blip)
    F_ClearPickup(sheet2)
    F_CleanBlip(sheet2Blip)
    F_ClearPickup(sheet3)
    F_CleanBlip(sheet3Blip)
    F_ClearPickup(sheet4)
    F_CleanBlip(sheet4Blip)
end

function MissionCleanup()
    if PlayerHasItem(497) then
        ItemSetCurrentNum(497, 0)
    end
    EnablePOI()
    gMelvinBlip = F_CleanBlip(gMelvinBlip)
    if F_PedExists(gMelvin) then
        PedMakeAmbient(gMelvin)
    end
    PedSetUniqueModelStatus(6, savedState)
    Sheet1AttackCleanup()
    Sheet2AttackCleanup()
    Sheet3AttackCleanup()
    Sheet4AttackCleanup()
    CleanCharacterSheetPickups()
    CameraSetWidescreen(false)
    SetupSheetCounter(false)
    ThreadCleanup()
    BlipSheetGuards(false)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    AreaEnableAllPatrolPaths()
    WeatherRelease()
    PedResetTypeAttitudesToDefault()
    SoundStopInteractiveStream()
    LoadAnimationGroups(false)
    DATUnload(2)
end

function LoadAnimationGroups(bLoad)
    --print(">>>[RUI]", "!!LoadAnimationGroups " .. tostring(bLoad))
    if bLoad then
        LoadAnimationGroup("2_S04CharSheets")
        LoadAnimationGroup("NIS_2_S04")
        LoadAnimationGroup("F_Girls")
        LoadAnimationGroup("F_Nerds")
        LoadAnimationGroup("Cheer_Nerd1")
        LoadAnimationGroup("Hang_Talking")
        LoadAnimationGroup("NPC_Cheering")
        LoadAnimationGroup("POI_Smoking")
        LoadAnimationGroup("POI_Booktease")
        LoadAnimationGroup("NPC_AggroTaunt")
        LoadAnimationGroup("LE_Orderly")
        LoadAnimationGroup("GEN_Social")
        LoadAnimationGroup("IDLE_GSF")
    else
        UnLoadAnimationGroup("2_S04CharSheets")
        UnLoadAnimationGroup("NIS_2_S04")
        UnLoadAnimationGroup("F_Girls")
        UnLoadAnimationGroup("F_Nerds")
        UnLoadAnimationGroup("Cheer_Nerd1")
        UnLoadAnimationGroup("Hang_Argue")
        UnLoadAnimationGroup("Hang_Talking")
        UnLoadAnimationGroup("NPC_Cheering")
        UnLoadAnimationGroup("POI_Smoking")
        UnLoadAnimationGroup("POI_Booktease")
        UnLoadAnimationGroup("NPC_AggroTaunt")
        UnLoadAnimationGroup("LE_Orderly")
        UnLoadAnimationGroup("GEN_Social")
        UnLoadAnimationGroup("IDLE_GSF")
    end
end

function main() -- ! Modified
    OpeningCutscene()
    MissionInit()
    while not AreaDisablePatrolPath(PATH._SGD_PREFECT3) do -- Added this loop
        Wait(0)
    end
    CreateCharacters()
    BlipSheetGuards(true)
    ObjectiveLogListInit(gObjectiveList)
    TextPrint("2_S04_OBJ1", 6, 1)
    SetupSheetCounter(true)
    MissionThreadSetup()
    Wait(1000)
    while not sheets_collected do
        UpdateTextQueue()
        if PedIsDead(gPlayer) then
            SoundPlayMissionEndMusic(false, 10)
            MissionFail(false, true)
            break
        end
        if bMelvinExists and F_PedIsDead(gMelvin) then
            bMelvinKilled = true
            --print(">>>[RUI]", "while not sheets_collected  MELVIN Killed")
            bPass = false
            sheets_collected = false
            break
        end
        Wait(0)
    end
    --print(">>>[RUI]", "Sheets_Collected")
    if sheets_collected then
        bPass = true
        while not MelvinIsReceivingGifts() do
            if bMelvinExists and F_PedIsDead(gMelvin) then
                bMelvinKilled = true
                bPass = false
                break
            end
            Wait(10)
        end
        PedSetInvulnerable(gMelvin, true)
        PlayerSetInvulnerable(true)
        --print(">>>[RUI]", "player giving!")
        if bPass then
            NIS_MelvinReceivesSheets()
        elseif bMelvinKilled then
            --print(">>>[RUI]", "Melvin Dead")
            SoundPlayScriptedSpeechEvent(gMelvin, "M_2_S04", 84)
            Wait(1000)
            MissionFail(false, true, "2_S04_FAIL01")
        else
            --print(">>>[RUI]", "MissionFail handled")
            SoundPlayMissionEndMusic(false, 10)
            MissionFail(false, true)
        end
    end
end

function MelvinIsReceivingGifts()
    return PlayerIsInAreaObject(gMelvin, 2, 3, 0)
end

function ObjectiveLogListInit(objList)
    local newObj
    for _, obj in objList do
        if obj and obj.objective then
            newObj = ObjectiveLogUpdateItem(obj.objective, nil, true)
            obj.id = newObj
        end
    end
end

function ObjectiveLogListUpdate(tbl)
    for _, obj in tbl do
        if not obj.bCheckedOff then
            obj.bCheckedOff = true
            ObjectiveLogUpdateItem(nil, obj.id)
            break
        end
    end
end

function ObjectiveLogUpdateItem(newObjStr, oldObj, bSkipPrint)
    local newObj
    if newObjStr then
        newObj = MissionObjectiveAdd(newObjStr)
        if not bSkipPrint then
            TextPrint(newObjStr, 3, 1)
        end
    end
    if oldObj then
        MissionObjectiveComplete(oldObj)
    end
    return newObj
end

function SetupSheetCounter(bOn)
    if bOn then
        CounterSetIcon("charasheet", "charasheet_x")
        CounterSetCurrent(0)
        CounterSetMax(MAX_SHEETS)
        CounterMakeHUDVisible(true)
        --print(">>>[RUI]", "SetupSheetCounter")
    else
        CounterMakeHUDVisible(false)
        CounterSetMax(0)
        CounterSetCurrent(0)
        CounterClearIcon()
        --print(">>>[RUI]", "ClearSheetCounter")
    end
end

function WorldSetPopulation(bOff)
    if bOff then
        DisablePOI()
        AreaActivatePopulationTrigger(TRIGGER._2_S04_AUTOSHOPAREA)
        AreaActivatePopulationTrigger(TRIGGER._2_S04_SCHOOLPOP)
        AreaDisableAllPatrolPaths()
        VehicleOverrideAmbient(0, 0, 0, 0)
        --print(">>>[RUI]", "!!WorldSetPopulation bOff")
    else
        EnablePOI()
        AreaEnableAllPatrolPaths()
        AreaDeactivatePopulationTrigger(TRIGGER._2_S04_AUTOSHOPAREA)
        AreaDeactivatePopulationTrigger(TRIGGER._2_S04_SCHOOLPOP)
        VehicleRevertToDefaultAmbient()
        AreaRevertToDefaultPopulation()
        --print(">>>[RUI]", "!!WorldSetPopulation REVERT")
    end
end

function MelvinCreate(bReceiveGifts)
    --print(">>>[RUI]", "++MelvinCreate")
    gMelvin = PedCreatePoint(6, POINTLIST._2_S04_MELVIN)
    PedIgnoreAttacks(gMelvin, true)
    PedSetMissionCritical(gMelvin, true)
    if not bReceiveGifts then
        PlayerSocialDisableActionAgainstPed(gMelvin, 28, true)
        PlayerSocialDisableActionAgainstPed(gMelvin, 29, true)
        PlayerSocialDisableActionAgainstPed(gMelvin, 32, true)
        PlayerSocialDisableActionAgainstPed(gMelvin, 35, true)
        PedIgnoreStimuli(gMelvin, true)
        PedMakeTargetable(gMelvin, false)
    end
    bMelvinExists = true
end

function OpeningCutscene()
    --print(">>>[RUI]", "!!OpeningCutscene")
    PlayerSetControl(0)
    SoundPlayInteractiveStream("MS_EpicConfrontationLow.rsm", 0.6)
    SoundSetMidIntensityStream("MS_EpicConfrontationMid.rsm", 0.7)
    SoundSetHighIntensityStream("MS_EpicConfrontationHigh.rsm", 0.7)
    PlayCutsceneWithLoad("2-S04", true)
    LoadWeaponModels({
        349,
        309,
        320,
        303,
        392
    })
    LoadModels({
        6,
        7,
        5,
        3,
        8
    })
    LoadModels({
        85,
        102,
        99
    })
    LoadModels({
        502,
        497,
        339
    })
    MelvinCreate()
    PedFollowPath(gMelvin, PATH._2_S04_TOLIBRARY, 0, 0, cbMelvinInLibrary)
    CreateThread("T_CleanupMelvinInLibrary")
    PlayerSetPosPoint(POINTLIST._2_S04_START)
    CameraFade(1000, 1)
    Wait(1000)
    PlayerSetControl(1)
    --print(">>>[RUI]", "!!OpeningCutscene DONE")
end

function cbMelvinInLibrary(pedId, pathId, pathNode)
    if pedId == gMelvin and PathGetLastNode(pathId) == pathNode then
        bMelvinInLibrary = true
    end
end

function T_CleanupMelvinInLibrary()
    while missionRunning do
        if bMelvinInLibrary then
            Wait(500)
            --print(">>>[RUI]", "--T_CleanupMelvinInLibrary")
            PedDelete(gMelvin)
            bMelvinExists = false
            break
        end
        Wait(10)
    end
end

function cbEnterRochambeau(pedId, pathId, pathNode)
    if pedId == gPlayer and PathGetLastNode(pathId) == pathNode then
        --print(">>>[RUI]", "++cbEnterRochameau")
        bEnterRochambeau = true
    end
end

function F_MakePlayerSafeForRochambeau(bOn)
    local turnOn = bOn
    if turnOn == nil then
        turnOn = true
    end
    if turnOn then
        EnterNIS()
        AreaClearAllExplosions()
        AreaClearAllProjectiles()
        DisablePunishmentSystem(true)
        StopAmbientPedAttacks()
        --print(">>>[RUI]", "++F_MakePlayerSafeForRochambeau")
    else
        DisablePunishmentSystem(false)
        ExitNIS()
        --print(">>>[RUI]", "--F_MakePlayerSafeForRochambeau")
    end
end

function RochambeauMiniGame()
    F_MakePlayerSafeForNIS(true)
    AreaSetPathableInRadius(164.4, -176.9, 7.8, 0.1, 5, false)
    CreateThread("T_Sheet1GuardsBuggerOff")
    bEnterRochambeau = false
    PedFollowPath(gPlayer, PATH._2_S04_PLAYERENTERPATH, 0, 0, cbEnterRochambeau)
    PedFaceObject(gPlayer, sheet1Guard, 2, 1)
    PedFaceObject(sheet1Guard, gPlayer, 3, 1)
    PedFaceObject(sheet1Bruiser, gPlayer, 3, 1)
    while not bEnterRochambeau do
        Wait(0)
    end
    CameraSetWidescreen(true)
    CameraSetXYZ(166.31854, -163.23898, 9.004641, 166.13483, -162.2562, 9.020187)
    DoDialogLine(gPlayer, "/Global/2_S04/Anim/RochambeauNIS/JimmyLine1")
    CameraSetXYZ(163.12056, -159.45274, 8.842199, 164.06009, -159.77383, 8.960558)
    DoDialogLine(sheet1Guard, "/Global/2_S04/Anim/RochambeauNIS/TrentGreet")
    DoDialogLine(sheet1Guard, "/Global/2_S04/Anim/RochambeauNIS/TrentRules")
    CameraSetXYZ(164.00285, -163.56578, 9.202619, 164.43384, -162.67166, 9.08219)
    DoDialogLine(gPlayer, "/Global/2_S04/Anim/RochambeauNIS/JimmyThatStupid")
    DoDialogLine(sheet1Bruiser, "/Global/2_S04/Anim/RochambeauNIS/TroyAttacks")
    PedFollowPath(sheet1Bruiser, PATH._2_S04_SBPATH, 0, 0, cbBruiserWalk)
    while not bBruiserReady do
        Wait(10)
    end
    CameraSetXYZ(161.50214, -161.16605, 8.283806, 162.4786, -160.96713, 8.364085)
    CameraAllowChange(false)
    bRochambeauDone = false
    bWon = false
    bSacked = false
    PedLockTarget(sheet1Bruiser, gPlayer)
    PedSetActionNode(sheet1Bruiser, "/Global/2_S04/Anim/Rochambeau", "Act/Conv/2_S04.act")
    local sackTimeOut = GetTimer() + 1000
    while not bSacked do
        if sackTimeOut <= GetTimer() then
            --print(">>>[RUI]", "emergency sackTimeOut")
            break
        end
        Wait(10)
    end
    Wait(100)
    PedSetActionNode(sheet1Guard, "/Global/2_S04/Anim/Laugh", "Act/Conv/2_S04.act")
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false)
    PlayerSetControl(1)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    --print(">>>[RUI]", "!!RochambeauPlay Recover time")
    rochambeauTimeOut = GetTimer() + gRochambeauTimeLimit
    while not bRochambeauDone do
        if GetTimer() >= rochambeauTimeOut then
            --print(">>>[RUI]", "emergency sackTimeOut")
            break
        end
        Wait(0)
    end
    PedIgnoreStimuli(sheet1Bruiser, true)
    PedIgnoreStimuli(sheet1Guard, true)
    bCheckSheet1 = true
    CameraAllowChange(true)
    CameraReturnToPlayer(true)
    if bWon then
        --print(">>>[RUI]", "RochambeauPlay PASSED!!")
        sheet1GuardBlip = F_CleanBlip(sheet1GuardBlip)
        SoundPlayScriptedSpeechEvent(sheet1Bruiser, "M_2_S04", 76)
        sheet1, sheet1Blip = DropCharacterSheet(sheet1Guard, true)
        sheet1_dropped = true
        gSheetGuardFleeBehaviour = BULLIES_FLEE
    else
        SoundPlayScriptedSpeechEvent(sheet1Bruiser, "M_2_S04", 77)
        gSheetGuardFleeBehaviour = BULLIES_HANGOUT
        --print(">>>[RUI]", "RochambeauPlay FAILED!!")
    end
    SoundEnableSpeech_ActionTree()
    bSheetGuardBuggerOffTime = true
end

function PedsDoConversation(ped1, ped2, conv)
    --print(">>>[RUI]", "++PedsDoConversation " .. conv)
    CameraSetWidescreen(true)
    ConversationMovePeds(false)
    PedStartConversation(conv, "Act/Conv/2_S04.act", ped1, ped2)
    while PedInConversation(ped1) or PedInConversation(ped2) do
        Wait(0)
    end
    CameraSetWidescreen(true)
end

function DoDialogLine(ped, action, actionFile)
    local file = actionFile or "Act/Conv/2_S04.act"
    PedSetActionNode(ped, action, file)
    while PedIsPlaying(ped, action, true) or SoundSpeechPlaying(ped) do
        Wait(0)
    end
end

function F_BruiserTaunt()
    --print(">>>[RUI]", "!!F_BruiserTaunt")
    PedSetActionNode(sheet1Bruiser, "/Global/2_S04/Anim/BullyTaunt", "Act/Conv/2_S04.act")
end

function T_Sheet1GuardsBuggerOff()
    --print(">>>[RUI]", "++T_Sheet1GuardsBuggerOff")
    while not bSheetGuardBuggerOffTime do
        Wait(0)
    end
    if gSheetGuardFleeBehaviour == BULLIES_HANGOUT then
        speed = 0
    else
        speed = 2
    end
    PedSetAsleep(sheet1Bruiser, false)
    PedSetAsleep(sheet1Guard, false)
    PedIgnoreStimuli(sheet1Bruiser, true)
    PedIgnoreStimuli(sheet1Guard, true)
    PedClearObjectives(sheet1Bruiser)
    PedStop(sheet1Bruiser)
    Wait(100)
    PedMoveToPoint(sheet1Bruiser, speed, POINTLIST._2_S04_SHEET1EXIT, 2, cbSheet1BruiserDoneClimb, 0.3, false, true)
    Wait(200)
    PedClearObjectives(sheet1Guard)
    PedStop(sheet1Guard)
    Wait(100)
    PedMoveToPoint(sheet1Guard, speed, POINTLIST._2_S04_SHEET1EXIT, 1, cbSheet1GuardDoneClimb, 0.3, false, true)
    while missionRunning do
        if PedIsInTrigger(sheet1Bruiser, TRIGGER._2_S04_TETHERBULLY) then
            if not F_PedIsDead(sheet1Bruiser) and not bSheet1BruiserHandled then
                --print(">>>[RUI]", "T_Sheet1GuardsBuggerOff BRUISER reached destination")
                PedIgnoreStimuli(sheet1Bruiser, false)
                PedSetFlag(sheet1Bruiser, 75, false)
                if gSheetGuardFleeBehaviour == BULLIES_HANGOUT then
                    PedStop(sheet1Bruiser)
                    PedSetTetherToTrigger(sheet1Bruiser, TRIGGER._2_S04_TETHERBULLY)
                    PedWander(sheet1Bruiser, 0)
                    --print(">>>[RUI]", "cbSheet1BruiserDoneClimb:  sheet1Bruiser wander to tether")
                else
                    PedFlee(sheet1Bruiser, gPlayer)
                    --print(">>>[RUI]", "cbSheet1BruiserDoneClimb:  FLEE")
                end
            end
            bSheet1BruiserHandled = true
        end
        if PedIsInTrigger(sheet1Guard, TRIGGER._2_S04_TETHERBULLY) then
            if not F_PedIsDead(sheet1Guard) and not bSheet1GuardHandled then
                --print(">>>[RUI]", "T_Sheet1GuardsBuggerOff GUARD reached destination")
                PedIgnoreStimuli(sheet1Guard, false)
                PedSetFlag(sheet1Bruiser, 75, false)
                if gSheetGuardFleeBehaviour == BULLIES_HANGOUT then
                    PedStop(sheet1Guard)
                    PedSetTetherToTrigger(sheet1Guard, TRIGGER._2_S04_TETHERBULLY)
                    PedWander(sheet1Guard, 0)
                    --print(">>>[RUI]", "cbSheet1GuardDoneClimb: Sheet1Guard wander to tether")
                else
                    PedFlee(sheet1Guard, gPlayer)
                    --print(">>>[RUI]", "cbSheet1GuardDoneClimb: FLEE")
                end
            end
            bSheet1GuardHandled = true
        end
        if bSheet1BruiserHandled and bSheet1GuardHandled then
            break
        end
        Wait(0)
    end
    collectgarbage()
    --print(">>>[RUI]", "--T_Sheet1GuardsBuggerOff")
end

function cbSheet1BruiserDoneClimb()
    --print(">>>[RUI]", "!!cbSheet1BruiserDoneClimb")
end

function cbSheet1GuardDoneClimb()
    --print(">>>[RUI]", "!!cbSheet1GuardDoneClimb")
end

function cbBruiserWalk(pedId, pathId, pathNode)
    if pedId == sheet1Bruiser and pathNode == PathGetLastNode(pathId) then
        --print(">>>[RUI]", "cbBruiserWalk Bruiser Ready")
        bBruiserReady = true
    end
end

function F_CleanBlip(blip)
    if blip and blip ~= -1 then
        BlipRemove(blip)
    end
    return nil
end

function BlipSheetGuards(bOn)
    if bOn then
        sheet1GuardBlip = BlipAddPoint(POINTLIST._2_S04_SHEET1, 0)
        sheet2GuardBlip = BlipAddPoint(POINTLIST._2_S04_SHEET2, 0)
        sheet3GuardBlip = BlipAddPoint(POINTLIST._2_S04_SHEET3, 0)
        sheet4GuardBlip = BlipAddPoint(POINTLIST._2_S04_SHEET4, 0)
    else
        sheet1GuardBlip = F_CleanBlip(sheet1GuardBlip)
        sheet2GuardBlip = F_CleanBlip(sheet2GuardBlip)
        sheet3GuardBlip = F_CleanBlip(sheet3GuardBlip)
        sheet4GuardBlip = F_CleanBlip(sheet4GuardBlip)
    end
end

function SheetGuardFleeingLoop()
    bHasMarbles = true
    while missionRunning do
        --print(">>>[RUI]", "FleePath1")
        SheetGuardFleeAndWaitForPlayer(PATH._2_S04_FLEE1)
        if F_PedIsDead(sheet4Guard) then
            return
        end
        --print(">>>[RUI]", "FleePath2")
        SheetGuardFleeAndWaitForPlayer(PATH._2_S04_FLEE2)
        if F_PedIsDead(sheet4Guard) then
            return
        end
        --print(">>>[RUI]", "FleePath3")
        SheetGuardFleeAndWaitForPlayer(PATH._2_S04_FLEE3)
        if F_PedIsDead(sheet4Guard) then
            return
        end
        --print(">>>[RUI]", "FleePath4")
        SheetGuardFleeAndWaitForPlayer(PATH._2_S04_FLEE4)
        if F_PedIsDead(sheet4Guard) then
            return
        end
        sheet4Laps = sheet4Laps + 1
        Wait(0)
        if sheet4Laps >= MAX_SHEET4_LAPS then
            break
        end
    end
    --print(">>>[RUI]", "!!T_SheetGuardFleeing lapped")
    PedStop(sheet4Guard)
    PedClearObjectives(sheet4Guard)
    PedSetInfiniteSprint(sheet4Guard, false)
    while not (bSheet4GuardHit or PlayerIsInAreaObject(sheet4Guard, 2, FLEE_DISTANCE, 0)) do
        if F_PedIsDead(sheet4Guard) then
            return
        else
            Sheet4DistanceTaunt()
        end
        Wait(0)
    end
    --print(">>>[RUI]", "SheetGuardFleeingLoop it's ON!")
    SoundStopCurrentSpeechEvent(sheet4Guard)
    PedIgnoreAttacks(sheet4Guard, false)
    PedIgnoreStimuli(sheet4Guard, false)
    PedRemovePedFromIgnoreList(sheet4Guard, gPlayer)
    PedStop(sheet4Guard)
    if not bSheet4GuardHit then
        Sheet4GuardCrouch(false)
    end
    PedSetTetherToTrigger(sheet4Guard, TRIGGER._2_S04_SCHOOLPOP)
    SoundPlayScriptedSpeechEvent(sheet4Guard, "M_2_S04", 19, "large")
    PedAttack(sheet4Guard, gPlayer, 3)
end

function SheetGuardFleeAndWaitForPlayer(path)
    Sheet4GuardCrouch(false)
    bSheet4GuardFleeHitMonitor = true
    PedClearObjectives(sheet4Guard)
    PedFollowPath(sheet4Guard, path, 0, 3, cbSheet4ReachedPoint)
    bSheet4Fleeing = true
    while bSheet4Fleeing do
        if PlayerIsInAreaObject(sheet4Guard, 2, MARBLE_DISTANCE, 0) and not bMarblesMaxed and F_PedExists(sheet4Guard) and bHasMarbles then
            PedSetActionNode(sheet4Guard, "/Global/2_S04/Anim/AttachMarbles", "Act/Conv/2_S04.act")
            SoundPlayScriptedSpeechEvent(sheet4Guard, "M_2_S04", PickRandom(marbleTaunts))
            while PedIsPlaying(sheet4Guard, "/Global/2_S04/Anim/AttachMarbles", true) do
                if F_PedIsDead(sheet4Guard) then
                    break
                end
                Wait(0)
            end
            --print(">>>[RUI]", "Marbles away!")
            marblesDropped = marblesDropped + 1
            if marblesDropped >= MARBLE_DROP_MAX then
                bMarblesMaxed = true
                --print(">>>[RUI]", "marbles maxxed")
            end
        end
        if F_PedIsDead(sheet4Guard) then
            return
        end
        Wait(10)
    end
    while not (PlayerIsInAreaObject(sheet4Guard, 2, FLEE_DISTANCE, 0) or bSheet4GuardHit) do
        if F_PedIsDead(sheet4Guard) then
            return
        else
            Sheet4DistanceTaunt()
        end
        Wait(20)
    end
    bMarblesMaxed = false
    marblesDropped = 0
    if not bSheet4GuardHit then
        SoundStopCurrentSpeechEvent(sheet4Guard)
        SoundPlayScriptedSpeechEvent(sheet4Guard, "M_2_S04", 18, "supersize")
    end
    bSheet4GuardHit = false
end

function TimerPassed(timer)
    if timer < GetTimer() then
        return true
    else
        return false
    end
end

function Sheet4DistanceTaunt()
    if gTauntTimer then
        if TimerPassed(gTauntTimer) and PlayerIsInAreaObject(sheet4Guard, 2, TAUNT_DISTANCE, 0) then
            SoundPlayScriptedSpeechEvent(sheet4Guard, "M_2_S04", PickRandom(arriveTaunts), "large")
            gTauntTimer = GetTimer() + 1000
        end
    else
        gTauntTimer = GetTimer() + 8000
    end
end

function Sheet4GuardCrouch(bOn)
    --print(">>>[RUI]", "Sheet4GuardCrouch " .. tostring(bOn))
    if bOn then
        if not PlayerIsInAreaObject(sheet4Guard, 2, CROUCH_DISTANCE, 0) then
            PedFaceObject(sheet4Guard, gPlayer, 3, 0)
            PedSetFlag(sheet4Guard, 2, true)
            bCrouching = true
        end
    elseif bCrouching then
        PedSetFlag(sheet4Guard, 2, false)
        --print(">>>[RUI]", "SheetGuardFleeAndWaitForPlayer un crouch")
    end
end

function cbSheet4ReachedPoint(pedId, pathId, pathNode)
    if pedId ~= sheet4Guard or not F_PedExists(sheet4Guard) then
        return
    end
    if pathId == PATH._2_S04_FLEE1 then
        if pathNode >= PathGetLastNode(pathId) then
            bSheet4Fleeing = false
            Sheet4GuardCrouch(true)
            --print(">>>[RUI]", "Flee1 done")
        end
    elseif pathId == PATH._2_S04_FLEE2 then
        if pathNode >= PathGetLastNode(pathId) then
            bSheet4Fleeing = false
            Sheet4GuardCrouch(true)
            --print(">>>[RUI]", "Flee2 Done")
        end
    elseif pathId == PATH._2_S04_FLEE3 then
        if pathNode >= PathGetLastNode(pathId) then
            bSheet4Fleeing = false
            Sheet4GuardCrouch(true)
            --print(">>>[RUI]", "Flee3 Done")
        end
    elseif pathId == PATH._2_S04_FLEE4 and pathNode >= PathGetLastNode(pathId) then
        bSheet4Fleeing = false
        Sheet4GuardCrouch(true)
        --print(">>>[RUI]", "Flee4 Done")
    end
end

function PickRandom(tbl)
    local tab = {}
    local n = 0
    if type(tbl) ~= "table" then
        --print(">>>[RUI]", "PickRandom tbl~=table")
        return nil
    end
    if 0 >= table.getn(tbl) then
        --print(">>>[RUI]", "PickRandom tbl.size=0")
        return nil
    end
    for _, item in tbl do
        table.insert(tab, item)
    end
    n = table.getn(tab)
    if n <= 0 then
        --print(">>>[RUI]", "PickRandom tab==nil")
        return nil
    end
    local i = math.random(1, n)
    local item = tab[i]
    tab = {}
    return item
end

function PlayerIsSacked()
    if PedIsPlaying(gPlayer, "/Global/HitTree/Standing/Melee/Unique/ROCHAMBEAU", true) then
        --print(">>>[RUI]", "PlayerIsSacked")
        return true
    else
        --print(">>>[RUI]", "NOT PlayerIsSacked")
        return false
    end
end

function EmergencySackPlayer()
    PedSetActionNode(gPlayer, "/Global/HitTree/Standing/Melee/Unique/ROCHAMBEAU/Front", "Act/HitTree.act")
    --print(">>>[RUI]", "!!EmergencySackPlayer")
end

function PlayerRecovered()
    if PedIsPlaying(gPlayer, "/Global/HitTree/Standing/Melee/Unique/ROCHAMBEAU/Front/Knockout/KnockoutRecover", true) or PedIsPlaying(gPlayer, "/Global/HitTree/Standing/PostHit/BellyUp/BellyUpGetUp/BellyUpGetUpGetUp", true) then
        --print(">>>[RUI]", "!!PlayerRecovered")
        return true
    else
        return false
    end
end

function PlayerKOd()
    if PedIsPlaying(gPlayer, "/Global/HitTree/Standing/Melee/Unique/ROCHAMBEAU/Front/Knockout/KnockoutDead", true) then
        --print(">>>[RUI]", "PlayerKOd")
        return true
    else
        --print(">>>[RUI]", "NOT PlayerKOd")
        return false
    end
end

function cbRochambeauWon()
    bRochambeauDone = true
    bWon = true
    --print(">>>[RUI]", "!!cbRochambeauWon")
    return
end

function cbRochambeauLost()
    bRochambeauDone = true
    bWon = false
    --print(">>>[RUI]", "!!cbRochambeauLost")
    return
end

function cbSacked()
    bSacked = true
    --print(">>>[RUI]", "!!cbSacked")
    return
end

function Sheet1GuardsReset()
    --print(">>>[RUI]", "!!Sheet1GuardsReset")
    PedDelete(sheet1Guard)
    PedDelete(sheet1Bruiser)
    Wait(100)
    Sheet1AttackSetup(true)
end

function T_Sheet1AttackMonitor()
    sheet1_attack = false
    while not sheets_collected do
        if PlayerIsInTrigger(TRIGGER._2_S04_SHEET1) or Sheet1Interrupt() then
            bDoFade = true
            break
        end
        if PlayerIsInTrigger(TRIGGER._2_S04_LIBRARYJUMP) and (PedIsPlaying(gPlayer, "/Global/WProps/WallClimb", true) or PedIsPlaying(gPlayer, "/Global/Player/JumpActions/Jump/IdleJump", true)) then
            break
        end
        Wait(0)
    end
    Sheet1GuardsReset()
    PlayerSetControl(0)
    F_MakePlayerSafeForRochambeau(true)
    SoundDisableSpeech_ActionTree()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    if bDoFade then
        CameraFade(FADE_OUT_TIME, 0)
        Wait(FADE_OUT_TIME + 1)
        CameraReset()
        CameraReturnToPlayer(true)
        F_PlayerDismountBike()
        AreaDisableCameraControlForTransition(true)
        local x, y, z = GetPointList(POINTLIST._2_S04_SHEET1START)
        PlayerSetPosSimple(x, y, z)
        PedFaceObject(gPlayer, sheet1Guard, 2, 0)
        AreaDisableCameraControlForTransition(false)
        CameraSetXYZ(160.97711, -165.2791, 9.864191, 161.4937, -164.4234, 9.834362)
        CameraSetWidescreen(true)
        CameraFade(FADE_IN_TIME, 1)
        Wait(FADE_IN_TIME + 1)
    else
        CameraSetXYZ(160.97711, -165.2791, 9.864191, 161.4937, -164.4234, 9.834362)
        CameraSetWidescreen(true)
    end
    bSheet1Attacked = false
    Wait(800)
    sheet1GuardBlip = F_CleanBlip(sheet1GuardBlip)
    sheet1GuardBlip = AddBlipForChar(sheet1Guard, 2, 26, 4)
    RochambeauMiniGame()
    --print(">>>[RUI]", "Challenge 1 Sheet1Attack")
    while not (not missionRunning or sheet1_dropped) do
        if not bGuardMonitorDone and bSheet1Attacked then
            --print(">>>[RUI]", "sheet1AttackMonitor: guards attacked")
            if F_PedExists(sheet1Guard) then
                PedStop(sheet1Guard)
                PedAttackPlayer(sheet1Guard)
            end
            if F_PedExists(sheet1Bruiser) then
                PedStop(sheet1Bruiser)
                PedAttackPlayer(sheet1Bruiser)
            end
            bGuardMonitorDone = true
        end
        Wait(0)
    end
    --print(">>>[RUI]", "--T_Sheet1AttackMonitor")
    Sheet1AttackCleanup()
    collectgarbage()
end

function Sheet1Interrupt()
    return bSheet1Attacked
end

function T_Sheet2AttackMonitor()
    WaitUntilInTrigger(TRIGGER._2_S04_STARTSHEET2, 100)
    Sheet2AttackSetup()
    WaitUntilInTrigger(TRIGGER._2_S04_NERD_ESCAPE, 10)
    NerdsEscape()
    WaitUntilInTrigger(TRIGGER._2_S04_SHEET2, 10)
    if missionRunning then
        PedAttack(sheet2Guard, gPlayer, 1)
        PedAttackPlayer(sheet2Goon1, 1)
        sheet2_attack = true
        CreateThread("ThadReturnsToHelp")
        CreateThread("NerdGivesHealth")
        Wait(0)
    end
    while not (not missionRunning or sheet2_dropped) do
        HandleNerdEscapes()
        Wait(100)
    end
    --print(">>>[RUI]", "--T_Sheet2AttackMonitor")
    Sheet2AttackCleanup()
    collectgarbage()
end

function HandleNerdEscapes()
    if bNerd2Escaped then
        PedMakeAmbient(gFatty)
        --print(">>>[RUI]", "PedMakeAmbient(gFatty)")
        bNerd2Escaped = false
    end
end

function WaitUntilInTrigger(trigger, delay, interruptFunc)
    local nDelay = delay or 100
    while not PlayerIsInTrigger(trigger) do
        if interruptFunc and interruptFunc() then
            --print(">>>[RUI]", "!!WaitUntilInTrigger interrupted")
            break
        end
        Wait(nDelay)
    end
end

function NerdsEscape()
    --print(">>>[RUI]", "!!NerdEscape")
    Wait(1000)
    PedWander(gThad, 2)
    SoundPlayScriptedSpeechEvent(gFatty, "M_2_S04", 61, "supersize")
    PedFollowPath(gFatty, PATH._2_S04_NERD_ESCAPE1, 0, 2, cbNerd2Escape)
    Wait(250)
    PedFollowPath(gHealthNerd, PATH._2_S04_NERDESCAPE3, 0, 1, cbNerdReturn)
end

function ThadReturnsToHelp()
    Wait(5000)
    if F_PedExists(gThad) and not sheet2_dropped then
        --print(">>>[RUI]", "!!ThadReturnsToHelp")
        PedClearObjectives(gThad)
        Wait(50)
        PedSetPedToTypeAttitude(gThad, 13, 4)
        PedSetPedToTypeAttitude(gThad, 11, 0)
        PedSetInvulnerableToPlayer(gThad, true)
        PedMakeTargetable(gThad, false)
        PedOverrideStat(gThad, 6, 0)
        PedOverrideStat(gThad, 14, 100)
        PedOverrideStat(gThad, 7, 0)
        PedOverrideStat(gThad, 8, 80)
        Wait(100)
        PedRecruitAlly(gPlayer, gThad)
        PedSetAllyAutoEngage(gThad, true)
        PedSetAllyJump(gThad, true)
        SoundPlayScriptedSpeechEvent(gThad, "M_2_S04", 63, "large")
        PedHideHealthBar()
    end
    collectgarbage()
    --print(">>>[RUI]", "--ThadReturnsToHelp")
end

function cbNerd2Escape(pedId, pathId, pathNode)
    if pathNode == PathGetLastNode(pathId) and F_PedExists(gFatty) and pedId == gFatty then
        PedWander(gFatty, 2)
        bNerd2Escaped = true
        --print(">>>[RUI]", "!!cbNerdEscape gFatty")
    end
end

function cbNerdReturn(pedId, pathId, pathNode)
    if pathNode == PathGetLastNode(pathId) and pedId == gHealthNerd then
        bNerdReturn = true
        --print(">>>[RUI]", "!!cbNerdReturn")
    end
end

function cbGiveHealth(pedId, pathId, pathNode)
    if pathNode == PathGetLastNode(pathId) and pedId == gHealthNerd then
        bGiveHealth = true
        --print(">>>[RUI]", "!!cbGiveHealth")
    end
end

function NerdGivesHealth()
    --print(">>>[RUI]", "!!NerdGivesHealth")
    while not bNerdReturn do
        Wait(100)
    end
    PedStop(gHealthNerd)
    --print(">>>[RUI]", "nerd returning")
    Wait(2000)
    PedSetInvulnerable(gHealthNerd, true)
    PedFollowPath(gHealthNerd, PATH._2_S04_NERDRETURN, 0, 1, cbGiveHealth)
    --print(">>>[RUI]", "sent on give health path")
    while not bGiveHealth do
        Wait(100)
    end
    --print(">>>[RUI]", "health point reached")
    PedStop(gHealthNerd)
    SoundPlayScriptedSpeechEvent(gHealthNerd, "M_2_S04", 64)
    Wait(1000)
    DropSodaCan(gHealthNerd)
    Wait(1000)
    PedFollowPath(gHealthNerd, PATH._2_S04_NERD_ESCAPE1, 0, 2, cbNerdEscape)
    --print(">>>[RUI]", "!!NerdGivesHealth DONE")
end

function F_NerdTeasingEnd()
    if PlayerIsInTrigger(TRIGGER._2_S04_SHEET3) or bSheet3GuysHit then
        --print(">>>[RUI]", "!!F_NerdTeasingEnd YES")
        return 1
    else
        return 0
    end
    return 0
end

function T_Sheet3AttackMonitor()
    Wait(100)
    while not (not missionRunning or sheet3_dropped) do
        while not sheet3_attack do
            if PlayerIsInTrigger(TRIGGER._2_S04_SHEET3OUTER) or bSheet3GuysHit then
                --print(">>>[RUI]", "!!T_Sheet3AttackMonitor entered Tease Area")
                if not bTeasing then
                    Sheet3_StartNerdTease()
                    bTeasing = true
                end
                sheet3GuardBlip = F_CleanBlip(sheet3GuardBlip)
                sheet3GuardBlip = AddBlipForChar(sheet3Guard, 2, 26, 4)
                NIS_Sheet3_NerdTease()
            end
            if F_NerdTeasingEnd() == 1 then
                RegisterHitCallback(gBucky, false)
                RegisterHitCallback(sheet3Guard, false)
                --print(">>>[RUI]", "entered TRIGGER._2_S04_SHEET3")
                bTeasing = false
                PlayerIgnorePed(gBucky)
                Wait(10)
                if not F_PedIsDead(sheet3Guard) then
                    PedAttack(sheet3Guard, gPlayer)
                end
                while PedIsPlaying(gBucky, "/Global/2_S04/Anim/NerdTeased/endTeased", true) do
                    Wait(5)
                end
                PedFollowPath(gBucky, PATH._2_S04_NERD_LOOP, 0, 2, cbBuckyFinished)
                sheet3_attack = true
                bTeasing = false
                --print(">>>[RUI]", "Sheet3Attack")
                ThreadCreate("SheetGuard3CheckLife")
            end
            Wait(0)
        end
        Wait(0)
    end
    --print(">>>[RUI]", "--T_Sheet3AttackMonitor")
    Sheet3AttackCleanup()
    collectgarbage()
end

function NIS_Sheet3_NerdTease()
    if bSheet3NISDone then
        return
    end
    --print(">>>[RUI]", "++NIS_Sheet3_NerdTease")
    Wait(600)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    CameraSetWidescreen(true)
    CameraFade(250, 0)
    Wait(250)
    SoundSetAudioFocusCamera()
    CameraSetXYZ(240.49532, -131.45654, 7.289726, 241.23705, -130.78592, 7.290389)
    CameraFade(250, 1)
    Wait(250)
    Wait(800)
    WaitSkippable(4000)
    CameraFade(250, 0)
    Wait(250)
    CameraReturnToPlayer()
    CameraReset()
    CameraFade(250, 1)
    Wait(250)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
    SoundSetAudioFocusPlayer()
    bSheet3NISDone = true
    --print(">>>[RUI]", "--NIS_Sheet3_NerdTease")
end

function T_Sheet4AttackMonitor()
    WaitUntilInTrigger(TRIGGER._2_S04_SHEET4, 10, InterruptSheet4Wait)
    if not F_PedIsDead(sheet4Guard) then
        sheet4GuardBlip = F_CleanBlip(sheet4GuardBlip)
        sheet4GuardBlip = AddBlipForChar(sheet4Guard, 2, 26, 4)
        PedIgnoreAttacks(sheet4Guard, true)
        SoundPlayScriptedSpeechEvent(sheet4Guard, "M_2_S04", 3, "supersize")
        WaitUntilInTrigger(TRIGGER._2_S04_SHEET4INNER, 10, InterruptSheet4Wait)
        if not bSheet4GuardHit then
            PedSetActionNode(sheet4Guard, "/Global/2_S04/Anim/BullyWall_Smoke/EndingSequences/StepAwayEnd", "Act/Conv/2_S04.act")
        end
        bSheet4GuardHit = false
        --print(">>>[RUI]", "T_Sheet4AttackMonitor bully Flee Start")
        Wait(250)
        SoundPlayScriptedSpeechEvent(sheet4Guard, "M_2_S04", 16, "supersize")
        SheetGuardFleeingLoop()
        while not (not missionRunning or sheet4_dropped) do
            Wait(100)
        end
    end
    --print(">>>[RUI]", "--T_Sheet4AttackMonitor")
    Sheet4AttackCleanup()
    collectgarbage()
end

function InterruptSheet4Wait() -- ! Modified
    --[[
    if bSheet4GuardHit then
        print(">>>[RUI]", "bSheet4Interrupted == true")
    end
    ]] -- Not present in original script
    return bSheet4GuardHit or F_PedIsDead(sheet4Guard)
end

function NerdEscape()
    Wait(100)
    while missionRunning do
        while bNerdsEscaped == false do
            if PlayerIsInTrigger(TRIGGER._2_S04_NERD_ESCAPE) then
                --print(">>>[RUI]", "NerdEscape")
                bNerdsEscaped = true
                Wait(1000)
                SoundPlayScriptedSpeechEvent(gFatty, "M_2_S04", 61, "supersize")
                PedWander(gThad, 1)
                PedFollowPath(gFatty, PATH._2_S04_NERD_ESCAPE2, 0, 2)
                Wait(250)
                PedFollowPath(gHealthNerd, PATH._2_S04_NERD_ESCAPE2, 0, 2)
                break
            end
            Wait(20)
        end
        Wait(20)
    end
    --print(">>>[RUI]", "--NerdEscape")
    collectgarbage()
end

function T_NerdTeased() -- Continue: line 3100
    while bTeasing and missionRunning do
        SoundPlayScriptedSpeechEvent(sheet3Guard, "M_2_S04", 23, "large")
        WaitWhileSpeechPlays()
        if not bTeasing then
            break
        end
        SoundPlayScriptedSpeechEvent(gBucky, "M_2_S04", 24, "large")
        WaitWhileSpeechPlays()
        if not bTeasing then
            break
        end
        SoundPlayScriptedSpeechEvent(sheet3Guard, "M_2_S04", 25, "large")
        WaitWhileSpeechPlays()
        if not bTeasing then
            break
        end
        SoundPlayScriptedSpeechEvent(gBucky, "M_2_S04", 26, "large")
        WaitWhileSpeechPlays()
        if not bTeasing then
            break
        end
        SoundPlayScriptedSpeechEvent(sheet3Guard, "M_2_S04", 27, "large")
        WaitWhileSpeechPlays()
        if not bTeasing then
            break
        end
        SoundPlayScriptedSpeechEvent(gBucky, "M_2_S04", 28, "large")
        WaitWhileSpeechPlays()
        if not bTeasing then
            break
        end
        SoundPlayScriptedSpeechEvent(sheet3Guard, "M_2_S04", 30, "large")
        WaitWhileSpeechPlays()
        if not bTeasing then
            break
        end
        Wait(10000)
    end
    --print(">>>[RUI]", "--T_NerdTeased END")
    collectgarbage()
end

function WaitWhileSpeechPlays()
    Wait(200)
    while SoundSpeechPlaying() do
        if not bTeasing then
            break
        end
        Wait(10)
    end
    Wait(250)
end

function cbBuckyFinished(pedId, pathId, pathNode)
    if pedId == gBucky and pathNode == PathGetLastNode(pathId) then
        --print(">>>[RUI]", "!!cbBuckyFinished")
        SoundPlayScriptedSpeechEvent(gBucky, "M_2_S04", 33, "large")
        bBuckyDone = true
    end
end

function F_HaveAllSheets()
    --print(">>>[RUI]", "!!F_HaveAllSheets  bGotSheets: " .. tostring(bGotSheets))
    if bGotSheets then
        return 1
    else
        return 0
    end
end

function F_MelvinReceivedSheets()
    --print(">>>[RUI]", "!!F_MelvinReceivedSheets")
    bMelvinReceivedSheets = true
end

function T_SheetMonitor() -- ! Modified
    Wait(100)
    --[[
    sheet1, sheet2, sheet3, sheet4 = nil, nil, nil, nil
    ]] -- Changed to:
    sheet1, sheet2, sheet3, sheet4 = nil, nil, nil, nil, nil
    while not (not missionRunning or sheets_collected) do
        if bCheckSheet1 and not sheet1_dropped and F_PedIsDead(sheet1Guard) then
            sheet1, sheet1Blip = DropCharacterSheet(sheet1Guard)
            sheet1_dropped = true
            bCheckSheet1 = false
        end
        if bSheet2AttackExists and not sheet2_dropped and F_PedIsDead(sheet2Guard) then
            sheet2, sheet2Blip = DropCharacterSheet(sheet2Guard)
            sheet2_dropped = true
        end
        if not sheet3_dropped and F_PedIsDead(sheet3Guard) then
            sheet3, sheet3Blip = DropCharacterSheet(sheet3Guard)
            sheet3_dropped = true
        end
        if not sheet4_dropped and F_PedIsDead(sheet4Guard) then
            sheet4, sheet4Blip = DropCharacterSheet(sheet4Guard)
            bSheet4DoneFleeing = true
            sheet4_dropped = true
        end
        if bGotSheets then
            Wait(1000)
            sheets_collected = true
            SetupSheetCounter(false)
            MelvinCreate(true)
            gMelvinBlip = BlipAddPoint(POINTLIST._2_S04_MELVIN, 0)
            gMelvinBlip = AddBlipForChar(gMelvin, 2, 0, 4)
            ObjectiveLogUpdateItem("2_S04_OBJ2", nil)
            --print(">>>[RUI]", "bGotSheets")
            break
        else
            if CharacterSheetPickedUp() then
                --print(">>>[RUI]", "!!T_SheetMonitor sheet picked up")
                CounterIncrementCurrent(1)
                ObjectiveLogListUpdate(gObjectiveList)
            end
            if CounterGetCurrent() == MAX_SHEETS then
                bGotSheets = true
            end
        end
        Wait(250)
    end
    --print(">>>[RUI]", "--T_SheetMonitor")
    collectgarbage()
end

function NIS_MelvinReceivesSheets()
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    SoundDisableSpeech_ActionTree()
    F_PlayerDismountBike()
    PedClearObjectives(gMelvin)
    PedFaceObjectNow(gMelvin, gPlayer, 3)
    PedFaceObjectNow(gPlayer, gMelvin, 2)
    PedLockTarget(gPlayer, gMelvin, 3)
    PedStop(gMelvin)
    PedClearObjectives(gMelvin)
    PedFaceObjectNow(gMelvin, gPlayer, 3)
    PedFaceObjectNow(gPlayer, gMelvin, 2)
    PedLockTarget(gPlayer, gMelvin, 3)
    PedLockTarget(gMelvin, gPlayer, 3)
    Wait(300)
    PedSetActionNode(gPlayer, "/Global/Give2S04/Give_Attempt", "Act/Gifts/Give2S04.act")
    while PedIsPlaying(gPlayer, "/Global/Give2S04", true) do
        Wait(0)
    end
    MinigameSetCompletion("M_PASS", true, gRewardMoney)
    SoundPlayMissionEndMusic(true, 10)
    missionRunning = false
    PedLockTarget(gPlayer, -1)
    PedLockTarget(gMelvin, -1)
    PedClearObjectives(gMelvin)
    PedMakeAmbient(gMelvin)
    Wait(10)
    PedSetActionNode(gMelvin, "/Global/2_S04/Anim/MelvinCheers", "Act/Conv/2_S04.act")
    SoundEnableSpeech_ActionTree()
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    PedSetInvulnerable(gMelvin, false)
    PlayerSetInvulnerable(false)
    CameraFade(500, 0)
    Wait(501)
    CameraReset()
    CameraReturnToPlayer()
    MissionSucceed(false, false, false)
    Wait(500)
    CameraFade(500, 1)
    Wait(101)
    PlayerSetControl(1)
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
    if bAmbient then
        SoundPlayAmbientSpeechEvent(pedId, strEvent)
        while SoundSpeechPlaying() do
            Wait(0)
        end
    else
        SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
        while SoundSpeechPlaying() do
            Wait(0)
        end
    end
end

function F_CheckSheetPickedUp(sheet)
    if sheet == nil then
        return false
    else
        return PickupIsPickedUp(sheet)
    end
end

function CharacterSheetPickedUp()
    if F_CheckSheetPickedUp(sheet1) then
        sheet1 = nil
        BlipRemove(sheet1Blip)
        --print(">>>[RUI]", "CharacterSheetPickedUp sheet 1")
        return true
    elseif F_CheckSheetPickedUp(sheet2) then
        sheet2 = nil
        BlipRemove(sheet2Blip)
        --print(">>>[RUI]", "CharacterSheetPickedUp sheet 2")
        return true
    elseif F_CheckSheetPickedUp(sheet3) then
        sheet3 = nil
        BlipRemove(sheet3Blip)
        --print(">>>[RUI]", "CharacterSheetPickedUp sheet 3")
        return true
    elseif F_CheckSheetPickedUp(sheet4) then
        sheet4 = nil
        BlipRemove(sheet4Blip)
        --print(">>>[RUI]", "CharacterSheetPickedUp sheet 4")
        return true
    end
end

function Sheet1AttackSetup(bAfterAttack)
    if not bAfterAttack then
        sheet1Guard = PedCreatePoint(85, POINTLIST._2_S04_SHEET1)
        PedClearAllWeapons(sheet1Guard)
        PlayerIgnorePed(sheet1Guard, true)
        PedSetStationary(sheet1Guard, true)
        sheet1GuardAttitude = PedGetPedToTypeAttitude(sheet1Guard, 13)
        PedSetPedToTypeAttitude(sheet1Guard, 13, 4)
        PedSetFlag(sheet1Guard, 75, true)
        PedSetFlag(sheet1Guard, 98, false)
        PedSetMinHealth(sheet1Guard, 20)
        RegisterHitCallback(sheet1Guard, true, cbSheet1Attacked)
        sheet1Bruiser = PedCreatePoint(102, POINTLIST._2_S04_SHEET1BRUISER)
        PedClearAllWeapons(sheet1Bruiser)
        PlayerIgnorePed(sheet1Bruiser, true)
        PedAddPedToIgnoreList(sheet1Bruiser, gPlayer)
        PedSetStationary(sheet1Bruiser, true)
        sheet1BruiserAttitude = PedGetPedToTypeAttitude(sheet1Bruiser, 13)
        PedSetPedToTypeAttitude(sheet1Bruiser, 13, 4)
        PedSetFlag(sheet1Bruiser, 75, true)
        PedSetFlag(sheet1Bruiser, 98, false)
        PedSetMinHealth(sheet1Bruiser, 20)
        RegisterHitCallback(sheet1Bruiser, true, cbSheet1Attacked)
        --print(">>>[RUI]", "++Sheet1AttackSetup")
    else
        sheet1Guard = PedCreatePoint(85, POINTLIST._2_S04_SHEET1)
        PedClearAllWeapons(sheet1Guard)
        PedSetAsleep(sheet1Guard, true)
        PedIgnoreStimuli(sheet1Guard, true)
        sheet1Bruiser = PedCreatePoint(102, POINTLIST._2_S04_SHEET1BRUISER)
        PedClearAllWeapons(sheet1Bruiser)
        PedSetAsleep(sheet1Bruiser, true)
        PedIgnoreStimuli(sheet1Bruiser, true)
        --print(">>>[RUI]", "++Sheet1AttackSetup RESET")
    end
end

function cbSheet1Attacked(victim, attacker)
    if attacker == gPlayer and (victim == sheet1Guard or victim == sheet1Bruiser) then
        bSheet1Attacked = true
        --print(">>>[RUI]", "!!cbSheet1Attacked")
    end
end

function Sheet2AttackSetup()
    PAnimCreate(TRIGGER._2_S04_TRASHCAN)
    sheet2Guard = PedCreatePoint(99, POINTLIST._2_S04_SHEET2)
    sheet2GuardBlip = F_CleanBlip(sheet2GuardBlip)
    sheet2GuardBlip = AddBlipForChar(sheet2Guard, 2, 26, 4)
    PedSetTetherToTrigger(sheet2Guard, TRIGGER._2_S04_AUTOSHOPAREA)
    sheet2Goon1 = PedCreatePoint(102, POINTLIST._2_S04_SHEET2_G1)
    PedSetTetherToTrigger(sheet2Goon1, TRIGGER._2_S04_AUTOSHOPAREA)
    gThad = PedCreatePoint(7, POINTLIST._2_S04_SHEET2_N1)
    PedSetTetherToTrigger(gThad, TRIGGER._2_S04_AUTOSHOPAREA)
    PlayerIgnorePed(gThad)
    gFatty = PedCreatePoint(5, POINTLIST._2_S04_SHEET2_N2)
    PlayerIgnorePed(gFatty)
    gHealthNerd = PedCreatePoint(3, POINTLIST._2_S04_SHEET2_N4)
    PlayerIgnorePed(gHealthNerd)
    bSheet2AttackExists = true
    bSheet2On = true
    --print(">>>[RUI]", "++Sheet2AttackSetup: sheet two guards and nerds")
end

function Sheet3AttackSetup()
    sheet3Guard = PedCreatePoint(102, POINTLIST._2_S04_SHEET3)
    RegisterHitCallback(sheet3Guard, true, cbSheet3GuysHit)
    PedSetTetherToTrigger(sheet3Guard, TRIGGER._2_S04_SHEET3CREATE)
    gBucky = PedCreatePoint(8, POINTLIST._2_S04_SHEET3_1)
    RegisterHitCallback(gBucky, true, cbSheet3GuysHit)
    PlayerIgnorePed(gBucky)
    PedSetTetherToTrigger(gBucky, TRIGGER._2_S04_SHEET3CREATE)
    --print(">>>[RUI]", "++Sheet3AttackSetup")
end

function cbSheet3GuysHit(victim, attacker)
    if attacker == gPlayer and (victim == sheet3Guard or victim == gBucky) then
        bSheet3GuysHit = true
        --print(">>>[RUI]", "!!cbSheet3GuysHit")
    end
end

function Sheet4AttackSetup()
    sheet4Guard = PedCreatePoint(99, POINTLIST._2_S04_SHEET4)
    RegisterHitCallback(sheet4Guard, true, cbSheet4GuardHit)
    PedIgnoreAttacks(sheet4Guard, true)
    PedAddPedToIgnoreList(sheet4Guard, gPlayer)
    PedIgnoreStimuli(sheet4Guard, true)
    PedSetInfiniteSprint(sheet4Guard, true)
    PedSetActionNode(sheet4Guard, "/Global/2_S04/Anim/BullyWall_Smoke", "Act/Conv/2_S04.act")
    --print(">>>[RUI]", "++Sheet4Guard and id")
end

function cbSheet4GuardHit(victim, attacker)
    if attacker == gPlayer and victim == sheet4Guard then
        SoundPlayScriptedSpeechEvent(sheet4Guard, "M_2_S04", 21, "large")
        bSheet4GuardHit = true
        gBeanedCounter = gBeanedCounter + 1
        if bHasMarbles then
            PedDestroyWeapon(sheet4Guard, 349)
            bHasMarbles = false
        end
    end
end

function CreateCharacters()
    Sheet1AttackSetup()
    Sheet3AttackSetup()
    Sheet4AttackSetup()
    --print(">>>[RUI]", "++CreateCharacters")
end

function PlayerIgnorePed(ped, bIgnore)
    local ignore
    if bIgnore == nil then
        ignore = true
    end
    if F_PedExists(ped) then
        if ignore then
            PedSetInvulnerableToPlayer(ped, true)
            PedMakeTargetable(ped, false)
        else
            PedSetInvulnerableToPlayer(ped, false)
            PedMakeTargetable(ped, true)
        end
    end
end

function PedCleanup(ped, bHitReaction)
    if F_PedExists(ped) then
        if bHitReaction then
            --print(">>>[RUI]", "PedCleanup clear hit reaction")
            RegisterHitCallback(ped, false)
        end
        PedMakeAmbient(ped)
    end
end

function F_ClearPickup(pickup)
    --print(">>>[RUI]", "--F_ClearPickup")
    if pickup and pickup ~= -1 then
        PickupDelete(pickup)
    end
end

function Sheet1AttackCleanup()
    if bSheet1CleanedUp then
        return
    end
    bSheet1CleanedUp = true
    --print(">>>[RUI]", "--Sheet1AttackCleanup")
end

function Sheet2AttackCleanup()
    if bSheet2CleanedUp then
        return
    end
    PAnimDelete(TRIGGER._2_S04_TRASHCAN)
    PedCleanup(sheet2Guard)
    PedCleanup(sheet2Goon1)
    ThadCleanup()
    PedCleanup(gFatty)
    if F_PedExists(gFatty) then
        PlayerIgnorePed(gFatty, false)
    end
    PedCleanup(gHealthNerd)
    if F_PedExists(gHealthNerd) then
        PlayerIgnorePed(gHealthNerd, false)
    end
    bSheet2On = false
    bSheet2CleanedUp = true
    --print(">>>[RUI]", "--Sheet2AttackCleanup")
end

function ThadCleanup()
    if F_PedExists(gThad) then
        PedClearObjectives(gThad)
        Wait(50)
        if PedGetAllyFollower(gPlayer) == gThad then
            PedDismissAlly(gPlayer, gThad)
        end
        PedMakeAmbient(gThad)
        PlayerIgnorePed(gThad, false)
    end
end

function Sheet3AttackCleanup()
    if bSheet3CleanedUp then
        return
    end
    PedCleanup(sheet3Guard, true)
    PlayerIgnorePed(gBucky, false)
    PedCleanup(gBucky, true)
    bSheet3CleanedUp = true
    --print(">>>[RUI]", "--Sheet3AttackCleanup")
end

function Sheet4AttackCleanup()
    if bSheet4CleanedUp then
        return
    end
    sheet4GuardBlip = F_CleanBlip(sheet4GuardBlip)
    PedCleanup(sheet4Guard, true)
    bSheet4CleanedUp = true
    --print(">>>[RI]", "--Sheet4AttackCleanup")
end

function DropSodaCan(nerd, bWander)
    local x, y, z = PedGetPosXYZ(nerd)
    PickupCreateXYZ(502, x, y, z, "HealthBute")
    if bWander then
        PedWander(nerd, 2)
    end
    --print(">>>[RUI]", "++DropSodaCan")
end

function DropCharacterSheet(ped, bNoDelay) -- ! Modified
    local x3, y3, z3 = PedGetPosXYZ(ped)
    if not bNoDelay then                   -- Added this
        Wait(gSheetDropDelay)
    end
    local sheetPickup = PickupCreateXYZ(497, x3, y3, z3, "PermanentButes")
    local blip = BlipAddXYZ(x3, y3, z3, 0, 4)
    --print(">>>[RUI]", "++DropCharacterSheet")
    return sheetPickup, blip
end

function Sheet3_StartNerdTease()
    --print(">>>[RUI]", "Sheet3_StartNerdTease")
    PedClearAllWeapons(sheet3Guard)
    PedClearAllWeapons(gBucky)
    Wait(200)
    if not F_PedIsDead(sheet3Guard) then
        PedSetPedToTypeAttitude(sheet3Guard, 1, 2)
    end
    PedSetPedToTypeAttitude(gBucky, 11, 2)
    Wait(200)
    if not F_PedIsDead(sheet3Guard) then
        PedSetActionNode(sheet3Guard, "/Global/2_S04/Anim/BullyNerdTease", "Act/Conv/2_S04.act")
    end
    PedSetActionNode(gBucky, "/Global/2_S04/Anim/NerdTeased", "Act/Conv/2_S04.act")
    bNerdTeased = true
    ThreadCreate("T_NerdTeased")
end

function Sheet3_StopNerdTease()
    --print(">>>[RUI]", "Sheet3_StopNerdTease")
    if bNerdTeased then
        if not F_PedIsDead(sheet3Guard) then
            PedSetActionNode(sheet3Guard, "/Global/2_S04/Anim/BullyNerdTease/endTease", "Act/Conv/2_S04.act")
        end
        PedSetActionNode(gBucky, "/Global/2_S04/Anim/NerdTeased/endTeased", "Act/Conv/2_S04.act")
        --print(">>>[RUI]", "tease stop")
    end
end

function SheetGuard3CheckLife()
    while not (not missionRunning or bWandering) do
        if bBuckyDone then
            --print(">>>[RUI]", "stop gBucky")
            PedStop(gBucky)
            PedClearObjectives(gBucky)
            Wait(10)
            PedFaceObject(gBucky, gPlayer, 2, 0)
            Wait(40)
            PedSetActionNode(gBucky, "/Global/2_S04/Anim/NerdCheer", "Act/Conv/2_S04.act")
            bBuckyDone = nil
        end
        if F_PedIsDead(sheet3Guard) and not bWandering then
            PedSetActionNode(gBucky, "/Global/N_Ranged_A", "Act/Anim/N_Ranged_A.act")
            Wait(20)
            PedWander(gBucky, 0)
            SoundPlayScriptedSpeechEvent(gBucky, "M_2_S04", 34, "large")
            bWandering = true
        end
        Wait(0)
    end
end

function F_SetPlayerLoc(point, area)
    local areaID = area or 0
    AreaTransitionPoint(areaID, point)
end

function ThreadCreate(threadName)
    table.insert(gThreads, {
        name = threadName,
        id = CreateThread(threadName)
    })
end

function ThreadCleanup()
    if not gThreads then
        return
    end
    for _, thread in gThreads do
        if thread and thread.id then
            TerminateThread(thread.id)
        end
    end
end

function RegisterHitCallback(ped, bOn, cb)
    if bOn then
        --assert(cb, "**RegisterHitCallback(ped, bOn, cb):  cb==nil")
        --print(">>>[RUI]", "++RegisterHitCallback")
        RegisterPedEventHandler(ped, 0, cb)
    else
        --print(">>>[RUI]", "--RegisterHitCallback")
        RegisterPedEventHandler(ped, 0, nil)
    end
end
