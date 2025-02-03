ImportScript("Library/LibTagging.lua")
ImportScript("Library/LibTable.lua")
ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibPed.lua")
local gBusTagCount = 0
local gSchoolTagCount = 0
local gTotalTags = 0
local gMissionTime = 300
local gBonusTime = 300
local missionPassed = false
local tblSchoolTags = {}
local tblBusinessTags = {}
local tblAlgieTags = {}
local tblPerverts = {}
local idValidTagType, algie, mandy
local bReachedPathEnd = false
local currentTrig = 1
local bYelled = false
local gPostersChanged = false
local algieScrubbing = false
local nMissionPhase = 0
local bCharactersCreated = false
local gMandyBlip
local gAlgieCutscenePlayed = false
local gTblComicBookTag = {}
local bDisabledSigns = false
local timerStart, timerCurrent
local timerElapsed = 0
local timerMax = 5000
local gStageUpdateFunction
local gMissionStage = "running"
local bCheckFailing = false
local bTetherJimmyToTown = false
local gMandyNode = 0
local pedModels = {
    { id = 14,  maxNum = 0 },
    { id = 85,  maxNum = 0 },
    { id = 99,  maxNum = 0 },
    { id = 146, maxNum = 0 },
    { id = 76,  maxNum = 0 },
    { id = 144, maxNum = 0 },
    { id = 18,  maxNum = 0 },
    { id = 15,  maxNum = 0 },
    { id = 20,  maxNum = 0 },
    { id = 13,  maxNum = 0 },
    { id = 149, maxNum = 0 },
    { id = 4,   maxNum = 0 },
    { id = 7,   maxNum = 0 },
    { id = 11,  maxNum = 0 }
}
local bPlayerGreetedMandy = false
local bPlayerShotMandy = false
local bVandalizingTutorial = true
local gJocks = {}
local bJocksFought = false
local gNerds = {}
local bNerdsFought = false
local bInNIS = false
local gLastPersonTalked
local bNeedSpray = false
local gSprayBlip
local bMandyAttacked = false

function F_SetupStage1()
    if PedGetAmmoCount(gPlayer, 321) < 3 then
        GiveWeaponToPlayer(321, false)
        GiveAmmoToPlayer(321, 3, false)
    end
    nMissionPhase = 1
    MissionTimerStart(gMissionTime)
    F_StartCounter()
    F_CreateThreads()
    CameraFade(500, 1)
    Wait(500)
    F_AddMissionObjective("4_G4_OBJ1", true)
    Wait(4500)
    gStageUpdateFunction = F_Stage1
end

function F_Stage1()
    while not AreaGetVisible() == 0 do
        Wait(0)
    end
    F_DisableBusinessPosters()
    F_CheckNerds()
    F_CheckSpray()
end

local bSaidSpeech = false
local bWalkingAway = false
local bNerdSpeaking = 0

function F_CheckNerds()
    if not bNerdsFought then
        if table.getn(gNerds) == 0 then
            if PlayerIsInTrigger(TRIGGER._4_G4_LIBNERDS) then
                table.insert(gNerds, PedCreatePoint(4, POINTLIST._4G4_NERDLIBRARY, 1))
                table.insert(gNerds, PedCreatePoint(11, POINTLIST._4G4_NERDLIBRARY, 2))
                PedSetFlag(gNerds[1], 122, true)
                PedSetFlag(gNerds[2], 122, true)
            end
        else
            if not PlayerIsInTrigger(TRIGGER._4_G4_LIBNERDS) then
                if gNerds[1] and PedIsValid(gNerds[1]) then
                    PedDelete(gNerds[1])
                end
                if gNerds[2] and PedIsValid(gNerds[2]) then
                    PedDelete(gNerds[2])
                end
                gNerds = {}
            elseif PedIsHit(gNerds[1], 2, 1000) and PedGetWhoHitMeLast(gNerds[1]) or PedIsHit(gNerds[2], 2, 1000) and PedGetWhoHitMeLast(gNerds[2]) then
                bNerdsFought = true
                PedClearObjectives(gNerds[1])
                PedClearObjectives(gNerds[2])
                PedAttack(gNerds[1], gPlayer, 1)
                PedAttack(gNerds[2], gPlayer, 1)
                PedMakeAmbient(gNerds[1])
                PedMakeAmbient(gNerds[2])
                if PedIsValid(gNerds[1]) and not PedIsDead(gNerds[1]) then
                    SoundPlayScriptedSpeechEvent(gNerds[1], "FIGHTING", 0, "large")
                elseif PedIsValid(gNerds[2]) and not PedIsDead(gNerds[2]) then
                    SoundPlayScriptedSpeechEvent(gNerds[2], "FIGHTING", 0, "large")
                end
            elseif not bSaidSpeech and PlayerIsInAreaObject(gNerds[1], 2, 3.5, 0) then
                bSaidSpeech = true
                SoundPlayScriptedSpeechEvent(gNerds[1], "M_4_G4", 199, "large")
                bNerdSpeaking = 1
            end
            if PedIsValid(gNerds[2]) and PAnimIsPlaying(TRIGGER._4_G4_SCHOOLTAG2, "/Global/TagSmall/NotUseable/Tagged/VandalTag", false) and PedIsPlaying(gPlayer, "/Global/TagSmall/PedPropsActions/IsPlayer/DrawVandalTag/ParametricTagging/Finished", false) then
                SoundPlayScriptedSpeechEvent(gNerds[2], "SEE_VANDALISM", 0, "large")
                bNerdsFought = true
                bNerdSpeaking = 2
            end
        end
    elseif not bWalkingAway then
        if bNerdSpeaking == 1 then
            if not SoundSpeechPlaying(gNerds[1]) and not bWalkingAway then
                bWalkingAway = true
                PedClearObjectives(gNerds[1])
                PedClearObjectives(gNerds[2])
                PedWander(gNerds[1], 0)
                PedWander(gNerds[2], 0)
                PedMakeAmbient(gNerds[1])
                PedMakeAmbient(gNerds[2])
            end
        elseif bNerdSpeaking == 2 and not SoundSpeechPlaying(gNerds[2]) and not bWalkingAway then
            bWalkingAway = true
            PedClearObjectives(gNerds[1])
            PedClearObjectives(gNerds[2])
            PedWander(gNerds[1], 0)
            PedWander(gNerds[2], 0)
            PedMakeAmbient(gNerds[1])
            PedMakeAmbient(gNerds[2])
        end
    end
end

function F_VandalismTutorial()
    --print("THIS IS EXECUTING!!")
    if bVandalizingTutorial then
        return 1
    end
    return 0
end

function F_SetupStage2()
    bMandyHold = true
    if mandy ~= nil and PedIsValid(mandy) then
        PedDelete(mandy)
    end
    local timeLeft = MissionTimerGetTimeRemaining()
    MissionTimerStart(timeLeft + gBonusTime)
    F_CompleteMissionObjective("4_G4_OBJ1")
    F_AddMissionObjective("4_G4_19", true)
    F_CreateBusinessPosters()
    --print("==== Finished Business Poster Create ====")
    L_TagLoad("4G4_BusTags", tblBusinessTags)
    --print("==== Finished 4G4_BusTags Poster Create ====")
    L_TagExec("4G4_BusTags", F_SetupTag, "element")
    --print("==== Finished F_SetupTag Poster Create ====")
    --print("==== Start gTblComicBookTag ====", i)
    --print("==== Done gTblComicBookTag ====", i)
    gStageUpdateFunction = F_Stage2
end

function F_CheckSpray()
    if not bInNIS then
        if not bNeedSpray then
            if ItemGetCurrentNum(321) == 0 then
                if PlayerGetMoney() < 100 and not shared.playerShopping then
                    gMissionStage = "OutOfMoney"
                else
                    bNeedSpray = true
                    if gStageUpdateFunction == F_Stage2 or gStageUpdateFunction == F_Stage3 then
                        F_RemoveMissionObjective("4_G4_19")
                        F_AddMissionObjective("4_G4_SPRAYBUY", true)
                        gSprayBlip = BlipAddPoint(POINTLIST._4G4_YUMYUM, 0, 1, 1)
                    elseif gStageUpdateFunction == F_Stage1 then
                        F_RemoveMissionObjective("4_G4_OBJ1")
                        F_AddMissionObjective("4_G4_SPRAYBUY", true)
                        gSprayBlip = BlipAddPoint(POINTLIST._4G4_YUMYUM, 0, 1, 1)
                    end
                    if gAlgieCutscenePlayed then
                        --print("Do business comics")
                        L_TagExec("4G4_BusComicTags", F_CleanBlip, "element")
                    end
                    if gStageUpdateFunction == F_Stage2 or gStageUpdateFunction == F_Stage3 then
                        --print("Do business tags comics")
                        L_TagExec("4G4_BusTags", F_CleanBlip, "element")
                        --print("Do school tags!")
                        L_TagExec("4G4SchoolTags", F_CleanBlip, "element")
                    elseif gStageUpdateFunction == F_Stage1 then
                        --print("DO SCHOOL TAAGS!!")
                        L_TagExec("4G4SchoolTags", F_CleanBlip, "element")
                    end
                end
            end
        elseif bNeedSpray then
            if ItemGetCurrentNum(321) > 0 then
                bNeedSpray = false
                if gSprayBlip then
                    BlipRemove(gSprayBlip)
                    gSprayBlip = nil
                end
                if gStageUpdateFunction == F_Stage2 or gStageUpdateFunction == F_Stage3 then
                    F_RemoveMissionObjective("4_G4_SPRAYBUY")
                    F_AddMissionObjective("4_G4_19", false)
                elseif gStageUpdateFunction == F_Stage1 then
                    F_RemoveMissionObjective("4_G4_SPRAYBUY")
                    F_AddMissionObjective("4_G4_OBJ1", false)
                end
                if gAlgieCutscenePlayed then
                    L_TagExec("4G4_BusComicTags", F_SetupTag, "element")
                end
                if gStageUpdateFunction == F_Stage2 or gStageUpdateFunction == F_Stage3 then
                    L_TagExec("4G4_BusTags", F_SetupTag, "element")
                elseif gStageUpdateFunction == F_Stage1 then
                    L_TagExec("4G4SchoolTags", F_SetupTag, "element")
                end
                while AreaGetVisible() ~= 0 do
                    Wait(0)
                end
                if gStageUpdateFunction == F_Stage2 or gStageUpdateFunction == F_Stage3 then
                    TextPrint("4_G4_19", 4, 1)
                elseif gStageUpdateFunction == F_Stage1 then
                    TextPrint("4_G4_OBJ1", 4, 1)
                end
            elseif PlayerGetMoney() < 100 and not shared.playerShopping then
                gMissionStage = "OutOfMoney"
            end
        end
    end
end

function F_Stage2()
    F_DisableBusinessPosters()
    F_CheckSpray()
    F_CheckNerds()
    F_MonitorJimmy()
    if PlayerIsInTrigger(TRIGGER._AMB_BUSINESS_AREA) then
        gStageUpdateFunction = F_SetupStage3
    end
end

function F_SetupStage3()
    gStageUpdateFunction = F_Stage3
end

local bPissedOffJocks = false

function F_Stage3()
    F_CheckSpray()
    F_MonitorJimmy()
    if CounterGetCurrent() == CounterGetMax() then
        F_CompleteMissionObjective("4_G4_19")
        gStageUpdateFunction = F_SetupStage4
    end
    if not bPissedOffJocks and PedIsPlaying(gPlayer, "/Global/TagSmall/PedPropsActions/IsPlayer", true) and PlayerIsInTrigger(TRIGGER._4_G4_NERDCOMICS) then
        for i, ped in tblPerverts do
            if (ped.model == 18 or ped.model == 13) and ped.id and PedIsValid(ped.id) and not PedIsDead(ped.id) then
                if ped.model == 18 then
                    SoundPlayScriptedSpeechEvent(ped.id, "FIGHTING", 0, "large")
                end
                PedSetActionNode(ped.id, "/Global/4_G4/ShortIdle", "Act/Conv/4_G4.act")
                PedAttack(ped.id, gPlayer, 1)
            end
        end
        bPissedOffJocks = true
    end
end

function F_SetupStage4()
    nMissionPhase = 3
    bEndAlgieThread = true
    Wait(0)
    L_StopMonitoringTags()
    MissionTimerStop()
    ToggleHUDComponentVisibility(3, false)
    bTetherJimmyToTown = false
    F_CompleteMissionObjective("4_G4_19")
    F_AddMissionObjective("4_G4_OBJ2", true)
    gMandyBlip = BlipAddPoint(POINTLIST._4G4_MANDYEND, 0, 4)
    Wait(4000)
    CounterClearIcon()
    CounterMakeHUDVisible(false, false)
    gStageUpdateFunction = F_SetupStage5
end

function F_SetupStage5()
    bMandyHold = false
    gStageUpdateFunction = F_Stage5
end

function CB_MandyAttacked()
    if mandy and PedIsValid(mandy) then
        PedSetInvulnerable(mandy, false)
        PedSetFlag(mandy, 113, false)
        PedSetStationary(mandy, false)
        PedIgnoreStimuli(mandy, false)
        PedMakeAmbient(mandy)
    end
    bMandyAttacked = true
    gMissionStage = "failed"
end

function F_Stage5()
    if mandy == nil then
        if gMandyBlip then
            BlipRemove(gMandyBlip)
        end
        mandy = PedCreatePoint(14, POINTLIST._4G4_MANDYEND)
        PedSetMissionCritical(mandy, true, CB_MandyAttacked, true)
        PedSetFlag(mandy, 113, true)
        PedSetStationary(mandy, true)
        PedIgnoreStimuli(mandy, true)
        PedSetPedToTypeAttitude(mandy, 13, 3)
        gMandyBlip = AddBlipForChar(mandy, 2, 17, 4, 0)
        PedSetActionNode(mandy, "/Global/4_G4/4_G4_Where", "Act/Conv/4_G4.act")
        PedStop(mandy)
        PedClearObjectives(mandy)
    end
    if PedIsInAreaObject(gPlayer, mandy, 2, 3, 0) then
        PedSetInvulnerable(mandy, true)
        PlayerSetInvulnerable(true)
        PedSetActionNode(mandy, "/Global/4_G4/ShortIdle", "Act/Conv/4_G4.act")
        PlayerSetControl(0)
        CameraSetWidescreen(true)
        SoundDisableSpeech_ActionTree()
        F_MakePlayerSafeForNIS(true)
        F_PlayerDismountBike()
        PedSetInvulnerable(mandy, false)
        PedSetFlag(mandy, 113, false)
        PedSetStationary(mandy, false)
        PedIgnoreStimuli(mandy, false)
        PedSetEmotionTowardsPed(mandy, gPlayer, 8, true)
        PedSetPedToTypeAttitude(mandy, gPlayer, 4)
        PedSetFlag(mandy, 84, true)
        PedFaceObject(mandy, gPlayer, 3, 1)
        PedFaceObject(gPlayer, mandy, 2, 1)
        PedLockTarget(gPlayer, mandy, 3)
        PedMoveToObject(mandy, gPlayer, 2, 0)
        while not PlayerIsInAreaObject(mandy, 2, 0.8, 0) do
            Wait(0)
        end
        PedStop(mandy)
        PedClearObjectives(mandy)
        PedFaceObject(gPlayer, mandy, 2, 0)
        PedFaceObject(mandy, gPlayer, 3, 0, false)
        PedLockTarget(gPlayer, mandy, 3)
        PedSetActionNode(mandy, "/Global/4_G4/4_G4_Hello", "Act/Conv/4_G4.act")
        SoundPlayScriptedSpeechEvent(mandy, "M_4_G4", 27, "large")
        Wait(100)
        F_PedSetCameraOffsetXYZ(gPlayer, 1, -1, 1.4, 0.5, -0.5, 1.4, mandy)
        while SoundSpeechPlaying(mandy) do
            Wait(0)
        end
        PedLockTarget(mandy, gPlayer)
        PedLockTarget(gPlayer, mandy)
        PedSetActionNode(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt", "Act/Player.act")
        CameraSetWidescreen(true)
        Wait(6000)
        SoundStopInteractiveStream()
        PedIgnoreStimuli(mandy, true)
        MinigameSetCompletion("M_PASS", true, 0, "4_G4_RESPECT")
        MinigameAddCompletionMsg("MRESPECT_NM5", 1)
        SoundPlayMissionEndMusic(true, 4)
        while PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) or PedIsPlaying(mandy, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
            Wait(0)
        end
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        CameraFade(500, 0)
        Wait(501)
        CameraReset()
        CameraReturnToPlayer()
        PedSetPedToTypeAttitude(mandy, 13, 4)
        PedSetEmotionTowardsPed(mandy, gPlayer, 8, true)
        PedLockTarget(gPlayer, -1)
        PedLockTarget(mandy, -1)
        PedStop(mandy)
        BlipRemove(gMandyBlip)
        PedMakeAmbient(mandy)
        gMissionStage = "passed"
    end
end

function F_PlayerGreetedMandy()
    bPlayerGreetedMandy = true
end

function CleanupFailed()
    for i, tag in tblSchoolTags do
        if tag.poster then
            PAnimDelete(tag.poster)
            --print("CleanupFailed Poster deleted!", tag.tagName)
        end
        if tag.id then
            PAnimDelete(tag.id)
        end
    end
    for i, tag in tblBusinessTags do
        if tag.poster then
            PAnimDelete(tag.poster)
        end
        if tag.id then
            PAnimDelete(tag.id)
        end
    end
end

function F_CreateSchoolPosters()
    for i, tag in tblSchoolTags do
        --print("==== F_CreateSchoolPosters ====", i)
        if tag.id then
            PAnimCreate(tag.id, false)
        end
        if tag.poster then
            PAnimCreate(tag.poster, false)
        else
            --print(">>>[RUI]", "BAD School Poster Trigger")
        end
    end
    --print(">>>[RUI]", "++SchoolPosters")
    --print(">>>[RUI]", "++F_CreateSchoolPosters")
end

function F_CreateBusinessPosters()
    --print("Size of tblBusinessTags: ", table.getn(tblBusinessTags))
    for i, tag in tblBusinessTags do
        --print("==== F_CreateBusinessPosters ====", i, "tag name: ", tag.tagName)
        if tag.id then
            PAnimCreate(tag.id, false)
        end
        if tag.poster and tag.bCheckTag then
            --print("Creating poster!")
            PAnimCreate(tag.poster, false)
        elseif not tag.bCheckTag and PAnimExists(tag.poster) then
            PAnimDelete(tag.poster)
            --print("Do not create poster!!")
            --print("F_CreateBusinessPosters Poster deleted!", tag.tagName)
        end
    end
    --print(">>>[RUI]", "++BusinessPosters")
    --print(">>>[RUI]", "++F_CreateBusinessPosters")
end

function T_MonitorAttackedPervs()
    while gMissionStage == "running" do
        for i, perv in tblPerverts do
            if perv.id and not PedIsDead(perv.id) and perv.bAttacked == false and PedGetWhoHitMeLast(perv.id) == gPlayer then
                PedAttack(perv.id, gPlayer, 3)
                perv.bAttacked = true
                if perv.buddy then
                    for j, buddyPerv in tblPerverts do
                        if buddyPerv.tagName == perv.buddy and buddyPerv.id then
                            PedSetActionNode(buddyPerv.id, "/Global/Ambient/MissionSpec/PlayerIdle/IdleOneFrame", "/Act/Anim/Ambient.act")
                            Wait(1)
                            PedAttack(buddyPerv.id, gPlayer, 3)
                            buddyPerv.bAttacked = true
                            if buddyPerv.buddy ~= perv.tagName then
                                for l, buddyPervbuddy in tblPerverts do
                                    if buddyPervbuddy.tagName == buddyPerv.buddy and buddyPervbuddy.id then
                                        PedAttack(buddyPervbuddy.id, gPlayer, 3)
                                        buddyPervbuddy.bAttacked = true
                                        break
                                    end
                                    Wait(1)
                                end
                            end
                            break
                        end
                        Wait(1)
                    end
                end
                break
            end
            Wait(1)
        end
        Wait(1)
    end
end

function F_DisableBusinessPosters()
    if shared.gAreaDATFileLoaded[0] == true and bDisabledSigns == false then
        bDisabledSigns = true
        for i, tag in tblBusinessTags do
            if tag.id then
                --print("========>>> disable tag.")
                PAnimSetActionNode(tag.id, "/Global/TagSmall/NotUseable", "Act/Props/TagSmall.act")
            end
        end
        for i, tag in gTblComicBookTag do
            if tag.id and PAnimExists(tag.id) then
                PAnimDelete(tag.id)
                PAnimDelete(tag.poster)
                --print("F_DisableBusinessPosters Poster deleted!", tag.tagName)
            end
        end
    elseif not shared.gAreaDATFileLoaded[0] and bDisabledSigns then
        bDisabledSigns = false
    end
end

function PervertsAttack(taggedPoint)
    bYelled = false
    for i, perv in tblPerverts do
        if perv.id and not PedIsDead(perv.id) and perv.id and taggedPoint == perv.trigger and PedIsInAreaObject(perv.id, gPlayer, 3, 6, 0) and not PedIsDead(perv.id) then
            PedSetActionNode(perv.id, "/Global/Ambient/MissionSpec/PlayerIdle/IdleOneFrame", "Act/Anim/Ambient.act")
            Wait(10)
            perv.bAttacked = true
            if perv.reaction then
                perv.reaction(perv.id, perv.yell)
            else
                FightPlayer(perv.id, perv.yell)
            end
            PedMakeAmbient(perv.id)
        end
    end
end

function PervertsLeave(pervId, yell)
    if yell == "4_G4_13" then
        QueueSoundSpeech(pervId, "WTF_TV", 0, nil, "large")
        QueueTextString("", 0.1, 2, false, CB_BulliesLeave)
    elseif yell == "4_G4_A2" then
        SoundPlayScriptedSpeechEvent(pervId, "M_4_G4", 15, "large")
    elseif yell == "4_G4_A1" then
        SoundPlayScriptedSpeechEvent(pervId, "M_4_G4", 14, "large")
    end
    if not gAlgieCutscenePlayed then
        gLastPersonTalked = pervId
        SoundDisableSpeech_ActionTree()
    end
    PedMakeAmbient(pervId)
    PedWander(pervId, 0)
end

function CB_BulliesLeave()
    if tblPerverts[1].id and PedIsValid(tblPerverts[1].id) then
        PedWander(tblPerverts[1].id, 0)
    end
    if tblPerverts[2].id and PedIsValid(tblPerverts[3].id) then
        PedWander(tblPerverts[2].id, 0)
    end
    if tblPerverts[3].id and PedIsValid(tblPerverts[3].id) then
        PedWander(tblPerverts[3].id, 0)
    end
end

function BleacherPervAttack(ped)
end

function AlgieCreate()
    algie = PedCreatePoint(7, POINTLIST._4_G4_PEDALGIESTART)
end

function PervertsCreate()
    local theAction, theModel
    for i, entry in tblPerverts do
        if entry.phase == nMissionPhase and entry.bAlive and entry.id == nil and not entry.bAttacked then
            theModel = entry.model
            --print("MODEL ENUM: ", theModel)
            entry.id = PedCreatePoint(theModel, entry.point, entry.element)
            theAction = entry.action or "/Global/4_G4/Animations/GenStandTalking/TalkingLoops"
            PedSetActionNode(entry.id, theAction, "Act/Conv/4_G4.act")
            PedSetFlag(entry.id, 122, true)
            if entry.threadInit then
                entry.threadInit(entry.id)
            else
            end
        end
    end
end

function PervertsDelete()
    for i, entry in tblPerverts do
        if entry.phase == nMissionPhase and entry.id and PedIsValid(entry.id) and not entry.bAttacked then
            if PedIsDead(entry.id) or PedGetHealth(entry.id) <= 0 then
                entry.bAlive = false
            end
            PedMakeAmbient(entry.id)
            entry.id = nil
        end
    end
end

function MonitorPerverts()
    local previousPhase = 0
    bCharactersCreated = true
    while gMissionStage == "running" do
        if nMissionPhase ~= 0 then
            if previousPhase ~= nMissionPhase then
                PervertsDelete()
                bCharactersCreated = false
            end
            previousPhase = nMissionPhase
            if bCharactersCreated == false and AreaGetVisible() == 0 then
                PervertsCreate()
                bCharactersCreated = true
            elseif bCharactersCreated == true and AreaGetVisible() ~= 0 then
                PervertsDelete()
                bCharactersCreated = false
            end
        end
        Wait(0)
    end
end

function F_CreateThreads()
    CreateThread("L_MonitorTags")
    --print(">>>[RUI]", "++L_MonitorTags")
    CreateThread("T_MandyMonitor")
    --print(">>>[RUI]", "++T_MandyMonitor")
    CreateThread("MonitorPerverts")
    --print(">>>[RUI]", "++MonitorPerverts")
    CreateThread("T_MonitorTimer")
    --print(">>>[RUI]", "++T_MonitorTimer")
    CreateThread("T_MonitorAttackedPervs")
    --print(">>>[RUI]", "++T_MonitorAttackedPervs")
end

function CB_MandyPath(pedId, pathId, nodeId)
    gMandyNode = nodeId
end

function F_OnClean()
end

function FightPlayer(ped, yell)
    if not bYelled then
        if yell == "4_G4_10" then
            SoundPlayScriptedSpeechEvent(ped, "M_4_G4", 5, "large")
        end
        bYelled = true
    end
    if ped and not PedIsDead(ped) then
        PedAttackPlayer(ped)
        PedMakeAmbient(ped)
        --print(">>>[RUI]", "!!FightPlayer")
    end
end

function FleePlayer(ped)
    if ped and not PedIsDead(ped) then
        PedFlee(ped, gPlayer)
        PedMakeAmbient(ped)
        --print(">>>[RUI]", "!!FleePlayer")
    end
end

function F_PopulateTables()
    tblSchoolTags = {
        {
            id = TRIGGER._4_G4_SCHOOLTAG2,
            poster = TRIGGER._4_G4_SCHOOLPOSTER02,
            idBlip = nil,
            completed = false,
            bCheckTag = true,
            count = 30,
            OnTagDone = F_OnTagDone,
            OnSetup = nil,
            tagType = 5,
            tagName = "SchoolTagEntranceA",
            startNode = "/Global/TagSmall/Useable",
            startFile = "/Act/Props/TagSmall.act"
        },
        {
            id = TRIGGER._4_G4_SCHOOLTAG3,
            poster = TRIGGER._4_G4_SCHOOLPOSTER03,
            idBlip = nil,
            completed = false,
            bCheckTag = true,
            count = 30,
            OnTagDone = F_OnTagDone,
            OnSetup = nil,
            tagType = 5,
            tagName = "SchoolTagMain",
            startNode = "/Global/TagSmall/Useable",
            startFile = "/Act/Props/TagSmall.act"
        },
        {
            id = TRIGGER._4_G4_TILTTAG1,
            poster = TRIGGER._4_G4_TILTPOST1,
            idBlip = nil,
            completed = false,
            bCheckTag = true,
            count = 30,
            OnTag = nil,
            OnClean = nil,
            OnSetup = nil,
            bIsTagged = true,
            bIsTagDone = true,
            tagType = 5,
            tagName = "BusinessTaggedComics",
            startNode = "/Global/TagSmall/NotUseable/Tagged/Executes/SetTagDone",
            startFile = "/Act/Props/TagSmall.act"
        }
    }
    gSchoolTagCount = table.getn(tblSchoolTags) - 1
    tblBusinessTags = {
        {
            id = TRIGGER._4_G4_BUSTAG2,
            poster = TRIGGER._4_G4_BUSPOSTER02,
            idBlip = nil,
            completed = false,
            bCheckTag = true,
            count = 30,
            OnTagDone = F_OnTagDone,
            OnClean = F_OnClean,
            OnSetup = nil,
            tagType = 5,
            tagName = "BusinessTagCinema",
            startNode = "/Global/TagSmall/Useable",
            startFile = "/Act/Props/TagSmall.act"
        },
        {
            id = TRIGGER._4_G4_BUSTAG8,
            poster = TRIGGER._4_G4_BUSPOSTER08,
            idBlip = nil,
            completed = false,
            bCheckTag = true,
            count = 30,
            OnTagDone = F_OnTagDone,
            OnClean = F_OnClean,
            OnSetup = nil,
            tagType = 5,
            tagName = "BusinessTagStatue",
            startNode = "/Global/TagSmall/Useable",
            startFile = "/Act/Props/TagSmall.act"
        }
    }
    --print("Size of business tags: ", table.getn(tblBusinessTags))
    gBusTagCount = table.getn(tblBusinessTags)
    gTblComicBookTag = {
        {
            id = TRIGGER._4_G4_SCHOOLTAG4,
            poster = TRIGGER._4_G4_SCHOOLPOSTER04,
            idBlip = nil,
            completed = false,
            bCheckTag = true,
            count = 30,
            OnTagDone = F_OnTagDone,
            OnClean = F_OnClean,
            OnSetup = nil,
            bIsTagged = false,
            bIsTagDone = false,
            bIsTagDone = true,
            tagType = 5,
            tagName = "BusinessTagComics",
            startNode = "/Global/TagSmall/Useable",
            startFile = "/Act/Props/TagSmall.act"
        }
    }
    gTotalTags = gSchoolTagCount
    tblPerverts = {
        {
            id = nil,
            trigger = TRIGGER._4_G4_SCHOOLTAG3,
            point = POINTLIST._4_G4_SCHOOLTAG3A,
            action = "/Global/4_G4/Animations/GenReactions/ReactionLoops",
            element = 1,
            phase = 1,
            reaction = PervertsLeave,
            blipid = nil,
            tagName = "SchoolPervTag3a",
            buddy = "SchoolPervTag3b",
            bAlive = true,
            bAttacked = false,
            model = 85,
            yell = "4_G4_15"
        },
        {
            id = nil,
            trigger = TRIGGER._4_G4_SCHOOLTAG3,
            point = POINTLIST._4_G4_SCHOOLTAG3A,
            action = nil,
            element = 2,
            phase = 1,
            reaction = PervertsLeave,
            blipid = nil,
            tagName = "SchoolPervTag3b",
            buddy = "SchoolPervTag3c",
            bAlive = true,
            bAttacked = false,
            model = 99,
            yell = "4_G4_14"
        },
        {
            id = nil,
            trigger = TRIGGER._4_G4_SCHOOLTAG3,
            point = POINTLIST._4_G4_SCHOOLTAG3A,
            action = "/Global/4_G4/Animations/GenReactions/ReactionLoops",
            element = 3,
            phase = 1,
            reaction = PervertsLeave,
            blipid = nil,
            tagName = "SchoolPervTag3c",
            buddy = "SchoolPervTag3a",
            bAlive = true,
            bAttacked = false,
            model = 146,
            yell = "4_G4_13"
        },
        {
            id = nil,
            trigger = TRIGGER._4_G4_BUSTAG2,
            point = POINTLIST._4_G4_BUSTAG2A,
            action = nil,
            element = 1,
            phase = 2,
            reaction = PervertsLeave,
            blipid = nil,
            tagName = "BusPervCinema1",
            buddy = "BusPervCinema2",
            bAlive = true,
            bAttacked = false,
            model = 76,
            yell = "4_G4_A0"
        },
        {
            id = nil,
            trigger = TRIGGER._4_G4_BUSTAG2,
            point = POINTLIST._4_G4_BUSTAG2A,
            action = nil,
            element = 3,
            phase = 2,
            reaction = PervertsLeave,
            blipid = nil,
            tagName = "BusPervCinema2",
            buddy = "BusPervCinema1",
            bAlive = true,
            bAttacked = false,
            model = 144,
            yell = "4_G4_A1"
        },
        {
            id = nil,
            trigger = TRIGGER._4_G4_BUSTAG4,
            point = POINTLIST._4_G4_BUSTAG4A,
            action = nil,
            element = 1,
            phase = 2,
            reaction = FightPlayer,
            blipid = nil,
            tagName = "BusPervComic1",
            buddy = "BusPervComic2",
            bAlive = false,
            bAttacked = false,
            model = 18,
            yell = "4_G4_14"
        },
        {
            id = nil,
            trigger = TRIGGER._4_G4_BUSTAG4,
            point = POINTLIST._4_G4_BUSTAG4A,
            action = nil,
            element = 2,
            phase = 2,
            reaction = FightPlayer,
            blipid = nil,
            tagName = "BusPervComic2",
            buddy = "BusPervComic1",
            bAlive = false,
            bAttacked = false,
            model = 13,
            yell = "4_G4_10"
        },
        {
            id = nil,
            trigger = TRIGGER._4_G4_BUSTAG8,
            point = POINTLIST._4_G4_BUSTAG8A,
            action = "/Global/4_G4/Animations/GenReactions/ReactionLoops",
            element = 1,
            phase = 2,
            reaction = PervertsLeave,
            blipid = nil,
            tagName = "BusPervStatue",
            bAlive = true,
            bAttacked = false,
            model = 149,
            yell = "4_G4_A2"
        }
    }
    bleacherPervIdx = 3
    tblAlgieTags = {
        {
            poster = TRIGGER._4_G4_BUSPOSTER08,
            id = TRIGGER._4_G4_BUSTAG8,
            path = PATH._4G4_COMICTOBACKALLEY,
            idBlip = nil,
            bCurrentFollowing = false,
            tagName = "BusinessTagStatue",
            bCheckTag = true
        },
        {
            poster = TRIGGER._4_G4_BUSPOSTER02,
            id = TRIGGER._4_G4_BUSTAG2,
            path = PATH._4G4_PITTOALLEY,
            idBlip = nil,
            bCurrentFollowing = false,
            tagName = "BusinessTagCinema",
            bCheckTag = true
        },
        {
            poster = TRIGGER._4_G4_BUSPOSTER04,
            id = TRIGGER._4_G4_BUSTAG4,
            path = PATH._4G4_CINEMATOMEX,
            idBlip = nil,
            bCurrentFollowing = false,
            tagName = "BusinessTagComics",
            bCheckTag = true
        }
    }
    gMaxNerdTrigs = table.getn(tblAlgieTags)
end

function F_StartCounter()
    CounterSetCurrent(0)
    CounterSetMax(2)
    CounterSetIcon("MandPost", "MandPost_x")
    CounterMakeHUDVisible(true, true)
end

function F_OnTagDone(tblTag)
    --print(">>>[RUI]", "++F_OnTag: ")
    if L_TagIsFaction(tblTag.id, tblTag.tagType) then
        --print(">>>[RUI]", "Tag Good")
        bVandalizingTutorial = false
        CounterIncrementCurrent(1)
        if tblTag.idBlip ~= nil then
            BlipRemove(tblTag.idBlip)
            tblTag.idBlip = nil
        end
        PervertsAttack(tblTag.id)
    else
        L_ClearTag(tblTag.id, 210)
        --print(">>>[RUI]", "Tag Bad")
    end
    --print("Number of posters tagged: ", CounterGetCurrent())
    if not gAlgieCutscenePlayed and nMissionPhase == 2 then
        if SoundSpeechPlaying(gLastPersonTalked) then
            PlayerSetControl(0)
            while SoundSpeechPlaying(gLastPersonTalked) do
                Wait(0)
                --print("IN HERE!")
            end
            SoundEnableSpeech_ActionTree()
        end
        F_DoAlgieCutscene()
    elseif nMissionPhase == 1 and CounterGetCurrent() == gSchoolTagCount then
        CounterSetCurrent(2)
        CounterSetMax(4)
        nMissionPhase = 2
        gStageUpdateFunction = F_SetupStage2
    end
end

function F_SetupTag(tag)
    local idBlip
    --print("Tag name: ", tag.tagName)
    --print("Tag check tag?: ", tostring(tag.bCheckTag))
    --print("Tag is tagged?: ", tostring(tag.bIsTagged))
    --print("Tag is done?: ", tostring(tag.bIsTagDone))
    if tag.id and tag.bCheckTag and not tag.bIsTagDone then
        --print(">>>[RUI]", "F_SetupTag  add blip")
        local x, y, z = GetAnchorPosition(tag.id)
        idBlip = BlipAddXYZ(x, y, z, 0)
        tag.idBlip = idBlip
    end
end

function F_CleanBlip(tag)
    if tag.idBlip then
        BlipRemove(tag.idBlip)
        tag.idBlip = nil
    end
end

function F_SetValidTags(intFaction)
    if intFaction == 1 then
        idValidTagType = 1
    elseif intFaction == 2 then
        idValidTagType = 2
    elseif intFaction == 3 then
        idValidTagType = 3
    elseif intFaction == 4 then
        idValidTagType = 4
    elseif intFaction == 5 then
        idValidTagType = 5
    end
end

function T_AlgieTagCleanup()
    local nextTrig = 1
    local bAlgieSprinting = false
    local bAlgieCleanupTags = true
    local bAlgieWasAttacked = false
    local bAlgieWasAttackedAgain = false
    local nTimeAlgieWasAttacked = 0
    while 0 < PedGetHealth(algie) do
        if not bInNIS then
            if not bAlgieWasAttacked then
                if PedIsHit(algie, 2, 1000) and PedGetWhoHitMeLast(algie) == gPlayer and 0 < PedGetHealth(algie) then
                    SoundStopCurrentSpeechEvent(algie)
                    PedClearObjectives(algie)
                    SoundPlayScriptedSpeechEvent(algie, "VICTIMIZED", 0, "large")
                    if not PedMePlaying(algie, "Grapples", true) then
                        PedSetActionNode(algie, "/Global/4_G4/Cower", "Act/Conv/4_G4.act")
                        while PedIsPlaying(algie, "/Global/4_G4/Cower", false) do
                            Wait(0)
                        end
                    end
                    PedIgnoreStimuli(algie, true)
                    PedAddPedToIgnoreList(algie, gPlayer)
                    PedClearObjectives(algie)
                    PedStop(algie)
                    PedMoveToPoint(algie, 3, POINTLIST._4G4_THADRUN, 1)
                    nTimeAlgieWasAttacked = GetTimer()
                    bAlgieCleanupTags = false
                    tblAlgieTags[currentTrig].bCurrentFollowing = false
                    bAlgieWasAttacked = true
                end
            elseif bAlgieWasAttacked then
                if not bAlgieCleanupTags and (GetTimer() - nTimeAlgieWasAttacked > 30000 or not PlayerIsInAreaObject(algie, 2, 40, 0)) then
                    PedClearObjectives(algie)
                    PedIgnoreStimuli(algie, false)
                    bAlgieCleanupTags = true
                end
                if not bAlgieWasAttackedAgain and bAlgieCleanupTags and (PedCanSeeObject(gPlayer, algie, 2) and PlayerIsInAreaObject(algie, 2, 10, 0) or PedIsHit(algie, 2, 1000) and PedGetWhoHitMeLast(algie) == gPlayer) and 0 < PedGetHealth(algie) then
                    F_DoAlgieRunNIS()
                    bAlgieWasAttackedAgain = true
                    PedMakeAmbient(algie)
                    bAlgieCleanupTags = false
                    break
                end
            end
            if bAlgieCleanupTags then
                if tblAlgieTags[currentTrig].path and tblAlgieTags[currentTrig].bCurrentFollowing == false then
                    PedFollowPath(algie, tblAlgieTags[currentTrig].path, 0, 1, F_ReachedPathEnd)
                    tblAlgieTags[currentTrig].bCurrentFollowing = true
                end
                if bReachedPathEnd then
                    tblAlgieTags[currentTrig].bCurrentFollowing = false
                    AlgieCleansTag(tblAlgieTags[currentTrig])
                    currentTrig = F_CycleTriggers(currentTrig)
                    bReachedPathEnd = false
                end
            end
        end
        Wait(1)
    end
end

function F_DoAlgieRunNIS()
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    CameraSetWidescreen(true)
    PedSetInvulnerable(algie, true)
    PedClearObjectives(algie)
    PedStop(algie)
    PedSetStationary(algie, true)
    PedFaceObjectNow(algie, gPlayer, 2)
    Wait(500)
    F_PedSetCameraOffsetXYZ(algie, 0.1, 1.3, 1.4, 0, 0, 1.4)
    Wait(500)
    PedSetStationary(algie, false)
    PedSetActionNode(algie, "/Global/4_G4/Scream", "Act/Conv/4_G4.act")
    SoundPlayScriptedSpeechEvent(algie, "TAUNT_RESPONSE_CRY", 0, "large")
    Wait(1500)
    PedMoveToPoint(algie, 3, POINTLIST._4G4_THADRUN, 1)
    CameraLookAtObject(algie, 2, true, 1.4)
    Wait(4000)
    PedSetInvulnerable(algie, false)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    CameraReset()
    CameraReturnToPlayer()
    CameraFollowPed(gPlayer)
    F_MakePlayerSafeForNIS(false)
end

function F_ReachedPathEnd(pedid, pathid, nodeid)
    if nodeid == PathGetLastNode(pathid) then
        bReachedPathEnd = true
    end
end

function AlgieCleansTag(tag)
    if not bEndAlgieThread then
        local Dachoice = math.random(1, 3)
        local DaScaredChoice = math.random(4, 6)
        local bFoundTag = false
        local bPlayerAlreadyTaggingIt = false
        --print("tag.tagName: ", tostring(tag.tagName))
        --print("tag.bCheckTag: ", tostring(tag.bCheckTag))
        --print("tag.id: ", tostring(tag.id))
        tag = GetRelativeTag(tag.tagName)
        if AreaGetVisible() == 0 and tag.bCheckTag and (not tag.id or not PAnimIsPlaying(tag.id, "/Global/TagSmall/NotUseable/Tagged/VandalTag", false)) then
            --print(">>>[RUI]", "!!AlgieCleansTag  INVALID TAG")
            return
        end
        PedStop(algie)
        bReachedPathEnd = false
        timerElapsed = 0
        timerStart = GetTimer()
        if PAnimIsPlaying(tag.id, "/Global/TagSmall/NotUseable/Tagged/VandalTag", false) then
            bFoundTag = true
        end
        if not tag.bCheckTag then
            bFoundTag = true
        end
        algieScrubbing = false
        if PlayerIsInAreaObject(algie, 2, 4, 0) and PedIsPlaying(gPlayer, "/Global/TagSmall/PedPropsActions/IsPlayer", true) then
            bPlayerAlreadyTaggingIt = true
        end
        if bFoundTag and not bPlayerAlreadyTaggingIt then
            local x, y, z = GetAnchorPosition(tag.id)
            PedFaceXYZ(algie, x, y, z, 0)
            Wait(40)
            TextPrint("4_G4_ALGIECLEAN", 4, 1)
            PedSetActionNode(algie, "/Global/4_G4/Animations/SetupPoster/PlaceIt", "Act/Conv/4_G4.act")
            while PedIsPlaying(algie, "/Global/4_G4/Animations/SetupPoster/PlaceIt", false) do
                Wait(0)
            end
            tag.bCurrentFollowing = false
            if not tag.bCheckTag then
                PAnimCreate(tag.poster, false)
                CounterSetMax(CounterGetMax() + 1)
            else
                CounterIncrementCurrent(-1)
            end
            tag.bIsTagged = false
            tag.bIsTagDone = false
            tag.bCheckTag = true
            if not bNeedSpray then
                tag.idBlip = BlipAddXYZ(x, y, z, 0)
            else
                tag.idBlip = nil
            end
            PAnimSetActionNode(tag.id, "/Global/TagSmall/Useable", "/Act/Props/TagSmall.act")
        end
    end
end

function F_CycleTriggers(triggerNumber)
    triggerNumber = triggerNumber + 1
    if triggerNumber > gMaxNerdTrigs then
        triggerNumber = 1
    end
    return triggerNumber
end

function GetRelativeTag(name)
    for i, tag in tblBusinessTags do
        if tag.tagName == name then
            return tag
        end
    end
    for i, tag in gTblComicBookTag do
        if tag.tagName == name then
            return tag
        end
    end
    return nil
end

function PlayerHasHitPed(ped)
    return PedGetWhoHitMeLast(ped) == gPlayer
end

function T_MandyMonitor()
    while gMissionStage == "running" do
        if mandy and (PlayerHasHitPed(mandy) or PedIsDead(mandy)) and gMissionStage ~= "passed" then
            if PlayerHasHitPed(mandy) then
            elseif PedIsDead(mandy) then
            end
            bMandySlapped = true
            break
        end
        if AreaGetVisible() == 13 and mandy == nil then
            if gStageUpdateFunction == F_Stage5 and mandy and PedIsValid(mandy) then
                PedSetMissionCritical(mandy, false)
                PedDelete(mandy)
            end
        elseif AreaGetVisible() == 0 and gStageUpdateFunction == F_Stage5 and mandy == nil then
            mandy = PedCreatePoint(14, POINTLIST._4G4_MANDYEND)
            PedSetMissionCritical(mandy, true, CB_MandyAttacked, true)
            PedSetPedToTypeAttitude(mandy, 13, 3)
            PedSetActionNode(mandy, "/Global/4_G4/4_G4_Where", "Act/Conv/4_G4.act")
            gMandyBlip = BlipAddPoint(POINTLIST._4G4_MANDYEND, 0, 4)
        end
        Wait(100)
    end
    if gMissionStage ~= "passed" and bMandySlapped and not bMandyHold then
        gMissionStage = "failed"
        if not PedIsDead(mandy) then
            PedFlee(mandy, gPlayer)
        end
        Wait(4000)
    end
end

function T_MonitorTimer()
    while gMissionStage == "running" do
        if MissionTimerHasFinished() then
            bTimesUp = true
            break
        end
        Wait(100)
    end
    if bTimesUp and nMissionPhase < 3 then
        gMissionStage = "failed"
    end
    collectgarbage()
end

function F_SetPlayerLoc(point, area)
    local areaID = area or 0
    AreaTransitionPoint(areaID, point)
end

function F_CleanupTags(tag)
    --print("tag.id = ", tostring(tag.id))
    --print("tag.poster = ", tostring(tag.poster))
    if tag.id then
        PAnimDelete(tag.id)
    end
    if tag.poster then
        PAnimDelete(tag.poster)
        --print("F_CleanupTags Poster deleted!", tag.tagName)
    end
    if tag.idBlip then
        BlipRemove(tag.idBlip)
        tag.idBlip = nil
    end
end

function CB_PedArrivedAtNode(pedId, pathId, nodeId)
    if nodeId == PathGetLastNode(pathId) and pedId == perv1 then
        PedSetActionNode(perv1, "/Global/4_G4/Animations/GenStandTalking/TalkingLoops", "Act/Conv/4_G4.act")
    end
    if nodeId == PathGetLastNode(pathId) and pedId == perv2 then
        PedSetActionNode(perv2, "/Global/4_G4/Animations/GenStandTalking/TalkingLoops", "Act/Conv/4_G4.act")
    end
end

function F_DoAlgieCutscene()
    local perv1, perv2, x, y, z, heading
    x2, y2, z2 = PlayerGetPosXYZ()
    gAlgieCutscenePlayed = true
    CameraFade(500, 0)
    Wait(500)
    TextPrintString("", 1, 2)
    TextPrintString("", 1, 1)
    bInNIS = true
    PlayerUnequip()
    while WeaponEquipped() do
        Wait(0)
    end
    PlayerSetPosXYZ(516.14, -70.544, 4.64)
    PlayerSetControl(0)
    F_MakePlayerSafeForNIS(true)
    CameraSetWidescreen(true)
    AlgieCreate()
    for i, perv in tblPerverts do
        if perv.tagName == "BusPervComic1" or perv.tagName == "BusPervComic2" then
            perv.bAlive = true
        end
    end
    PervertsCreate()
    for i, perv in tblPerverts do
        if perv.tagName == "BusPervComic1" then
            perv1 = perv.id
            PedSetActionNode(perv1, "/Global/Ambient/MissionSpec/PlayerIdle/IdleOneFrame", "Act/Anim/Ambient.act")
        elseif perv.tagName == "BusPervComic2" then
            perv2 = perv.id
            PedSetActionNode(perv2, "/Global/Ambient/MissionSpec/PlayerIdle/IdleOneFrame", "Act/Anim/Ambient.act")
        end
    end
    PAnimSetActionNode(TRIGGER._4_G4_TILTTAG1, "/Global/TagSmall/NotUseable/Tagged/Executes/SetTagDone", "Act/Props/TagSmall.act")
    PedSetPosPoint(perv1, POINTLIST._4_G4_ALGIECUT, 2)
    PedSetPosPoint(perv2, POINTLIST._4_G4_ALGIECUT, 1)
    PedSetPosPoint(algie, POINTLIST._4_G4_ALGIECUT, 3)
    PedClearAllWeapons(algie)
    CameraSetFOV(70)
    CameraSetXYZ(512.32794, -64.18165, 6.174207, 513.1554, -63.620415, 6.186368)
    CameraFade(500, 1)
    Wait(500)
    PedFollowPath(algie, PATH._4G4_ALGIEPATH, 0, 1)
    SoundPlayScriptedSpeechEvent(algie, "M_4_G4", 22, "large")
    Wait(3000)
    PedStop(algie)
    while SoundSpeechPlaying(algie) do
        Wait(0)
    end
    PedSetActionNode(algie, "/Global/4_G4/Animations/SetupPoster/PlaceIt", "Act/Conv/4_G4.act")
    while PedIsPlaying(algie, "/Global/4_G4/Animations/SetupPoster/PlaceIt", false) do
        Wait(0)
    end
    for i, tag in gTblComicBookTag do
        PAnimCreate(tag.id)
        PAnimCreate(tag.poster)
    end
    --print("Load tag during the NIS!")
    L_TagLoad("4G4_BusComicTags", gTblComicBookTag)
    for i, tag in gTblComicBookTag do
        if tag.id then
            tag.bIsTagged = false
            tag.bIsTagDone = false
            tag.bCheckTag = true
            tag.bIsTagDone = false
            PAnimSetActionNode(tag.id, "/Global/TagSmall/Useable", "/Act/Props/TagSmall.act")
        end
    end
    if not bNeedSpray then
        --print("Setup the business comic tags")
        L_TagExec("4G4_BusComicTags", F_SetupTag, "element")
    end
    PedFollowPath(algie, tblAlgieTags[currentTrig].path, 0, 1, F_ReachedPathEnd)
    CreateThread("T_AlgieTagCleanup")
    Wait(1000)
    PedFollowPath(perv1, PATH._4G4_PERV1, 0, 0, CB_PedArrivedAtNode)
    PedFollowPath(perv2, PATH._4G4_PERV1, 0, 0, CB_PedArrivedAtNode)
    CameraFade(500, 0)
    Wait(500)
    CameraDefaultFOV()
    CameraReset()
    CameraReturnToPlayer()
    CameraSetWidescreen(false)
    PlayerSetPosXYZ(x2, y2, z2)
    PlayerFaceHeading(180, 0)
    TextPrintString("", 1, 2)
    CounterSetIcon("MandPost", "MandPost_x")
    CounterMakeHUDVisible(true, true)
    CounterSetMax(5)
    bTetherJimmyToTown = true
    bInNIS = false
    F_MakePlayerSafeForNIS(false)
    Wait(300)
    CameraFade(500, 1)
    Wait(500)
    PlayerSetControl(1)
    if bNeedSpray then
        TextPrint("4_G4_SPRAYBUY", 4, 1)
    end
end

function F_MonitorJimmy()
    if bTetherJimmyToTown and not AreaIsLoading() and AreaGetVisible() == 0 then
        if bCheckFailing then
            if not PlayerIsInTrigger(TRIGGER._4_G4_LEFTTOWN) then
                gMissionStage = "LeftTown"
            elseif PlayerIsInTrigger(TRIGGER._AMB_BUSINESS_AREA) then
                bCheckFailing = false
                TextPrintString("", 1, 1)
            end
        elseif not PlayerIsInTrigger(TRIGGER._AMB_BUSINESS_AREA) then
            TextPrint("4_G4_SEARCH", 4000000, 1)
            bCheckFailing = true
        end
    end
end

function InitialSetup()
    WeaponRequestModel(321)
    LoadAnimationGroup("MINIGraf")
    LoadAnimationGroup("Hang_Jock")
    LoadAnimationGroup("Hang_Talking")
    LoadAnimationGroup("NPC_Love")
    LoadAnimationGroup("NPC_NeedsResolving")
    LoadAnimationGroup("POI_Smoking")
    LoadAnimationGroup("GEN_Socia")
    LoadAnimationGroup("IDLE_SEXY_C")
    LoadAnimationGroup("SGIRL_F")
    LoadPAnims({
        TRIGGER._4_G4_SCHOOLPOSTER02,
        TRIGGER._4_G4_SCHOOLPOSTER03,
        TRIGGER._4_G4_SCHOOLPOSTER04,
        TRIGGER._4_G4_BUSPOSTER02,
        TRIGGER._4_G4_BUSPOSTER03,
        TRIGGER._4_G4_BUSPOSTER04,
        TRIGGER._4_G4_BUSPOSTER06A,
        TRIGGER._4_G4_BUSPOSTER08
    })
    for i, ped in pedModels do
        ped.maxNum = PedGetUniqueModelStatus(ped.id)
        PedSetUniqueModelStatus(ped.id, -1)
    end
    LoadPedModels({
        85,
        99,
        146,
        76,
        144,
        18,
        15,
        20,
        13,
        149,
        14,
        4,
        7,
        11
    })
    LoadActionTree("Act/Conv/4_G4.act")
    F_PopulateTables()
    F_SetValidTags(5)
    F_CreateSchoolPosters()
    L_TagLoad("4G4SchoolTags", tblSchoolTags)
    for i, tag in tblSchoolTags do
        if tag.id and tag.tagName == "BusinessTaggedComics" then
            tag.bIsTagged = true
            tag.bIsTagDone = true
            tag.bCheckTag = false
        end
    end
    L_TagExec("4G4SchoolTags", F_SetupTag, "element")
    F_DisableBusinessPosters()
    AreaTransitionPoint(0, POINTLIST._4_G4_PLAYERSTART)
    while not shared.gAreaDATFileLoaded[0] == true do
        Wait(100)
    end
    TaggingStartPersistentTag()
    Wait(100)
    CameraReset()
    CameraReturnToPlayer()
end

function MissionSetup()
    MissionDontFadeIn()
    TaggingOnlyShowMissionTags(true)
    SoundPlayInteractiveStream("MS_SearchingLow.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetMidIntensityStream("MS_SearchingMid.rsm", 0.6)
    SoundSetHighIntensityStream("MS_SearchingHigh.rsm", 0.7)
    PlayCutsceneWithLoad("4-G4", true, true)
    DATLoad("4_G4.DAT", 2)
    DATInit()
    if PlayerGetMoney() < 100 then
        PlayerSetMoney(100)
    end
end

function main()
    InitialSetup()
    CreateThread("T_PedMonitor")
    gStageUpdateFunction = F_SetupStage1
    while not (gMissionStage ~= "running" or bPlayerShotMandy) do
        UpdateTextQueue()
        gStageUpdateFunction()
        Wait(0)
    end
    if gMissionStage == "passed" then
        SoundStopInteractiveStream()
        SetFactionRespect(1, GetFactionRespect(1) - 5)
        MissionSucceed(false, false, false)
        AreaEnsureSpecialEntitiesAreCreatedWithOverride("4_G4", 4)
        Wait(500)
        CameraFade(500, 1)
        Wait(101)
    else
        CleanupFailed()
        if bMandyAttacked then
            if mandy and PedIsValid(mandy) then
                PedSetInvulnerable(mandy, false)
                PedSetFlag(mandy, 113, false)
                PedSetStationary(mandy, false)
                PedIgnoreStimuli(mandy, false)
                PedMakeAmbient(mandy)
            end
            SoundPlayMissionEndMusic(false, 4)
            MissionFail(false, true, "4_G4_MANDHIT")
        elseif gMissionStage == "OutOfMoney" then
            CounterClearIcon()
            CounterMakeHUDVisible(false, false)
            SoundPlayMissionEndMusic(false, 4)
            TextPrintString("", 1, 1)
            MissionFail(false, true, "CMN_STR_06")
        elseif bTimesUp then
            CounterClearIcon()
            CounterMakeHUDVisible(false, false)
            SoundPlayMissionEndMusic(false, 4)
            MissionFail(false, true, "4_G4_TIMEUP")
        elseif gMissionStage == "LeftTown" then
            CounterClearIcon()
            CounterMakeHUDVisible(false, false)
            SoundPlayMissionEndMusic(false, 4)
            TextPrintString("", 1, 1)
            MissionFail(false, true, "4_G4_FAILLEFT")
        else
            SoundPlayMissionEndMusic(false, 4)
            MissionFail()
        end
    end
end

function MissionCleanup()
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false)
    CameraSetWidescreen(false)
    CameraReturnToPlayer(true)
    CameraReset()
    TaggingStopPersistentTag()
    TaggingOnlyShowMissionTags(false)
    SoundStopInteractiveStream()
    SoundEnableSpeech_ActionTree()
    if mandy and PedIsValid(mandy) then
        PedSetInvulnerable(mandy, false)
        PedSetFlag(mandy, 113, false)
        PedSetStationary(mandy, false)
        PedIgnoreStimuli(mandy, false)
        PedMakeAmbient(mandy)
        PedWander(mandy, 0)
    end
    for i, ped in pedModels do
        PedSetUniqueModelStatus(ped.id, ped.maxNum)
    end
    CounterClearIcon()
    CounterMakeHUDVisible(false, false)
    --print("SLKDFMSKMFSM!")
    if 1 <= nMissionPhase and 0 < table.getn(tblSchoolTags) then
        L_TagExec("4G4SchoolTags", F_CleanupTags, "element")
    end
    if 2 <= nMissionPhase then
        --print("E{LWPREPWLRWLPERWR!")
        if 0 < table.getn(tblBusinessTags) then
            L_TagExec("4G4_BusTags", F_CleanupTags, "element")
        end
        --print("LNKEWRMKMKKMKLFIOI!")
        if gAlgieCutscenePlayed and 0 < table.getn(gTblComicBookTag) then
            L_TagExec("4G4_BusComicTags", F_CleanupTags, "element")
        end
    end
    UnLoadAnimationGroup("MINIGraf")
    UnLoadAnimationGroup("Hang_Jock")
    UnLoadAnimationGroup("Hang_Talking")
    UnLoadAnimationGroup("NPC_Love")
    UnLoadAnimationGroup("NPC_NeedsResolving")
    UnLoadAnimationGroup("POI_Smoking")
    UnLoadAnimationGroup("GEN_Socia")
    UnLoadAnimationGroup("IDLE_SEXY_C")
    UnLoadAnimationGroup("SGIRL_F")
    DATUnload(2)
end

function F_PlayerShotMandy()
    --print("PWNED!")
    bPlayerShotMandy = true
end

local tObjectiveTable = {}

function F_ObjectiveAlreadyGiven(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            return true
        end
    end
    return false
end

function F_ObjectiveAlreadyComplete(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            return objective.bComplete
        end
    end
    return false
end

function F_RemoveMissionObjective(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            MissionObjectiveRemove(objective.id)
            table.remove(tObjectiveTable, i)
        end
    end
end

function F_CompleteMissionObjective(reference)
    for i, objective in tObjectiveTable do
        if objective.ref == reference then
            MissionObjectiveComplete(objective.id)
            objective.bComplete = true
        end
    end
end

function F_AddMissionObjective(reference, bPrint)
    if F_ObjectiveAlreadyGiven(reference) then
        for i, objective in tObjectiveTable do
            if objective.ref == reference then
                return objective.id
            end
        end
    end
    if bPrint then
        TextPrint(reference, 3, 1)
    end
    local objId = MissionObjectiveAdd(reference)
    table.insert(tObjectiveTable, {
        id = objId,
        ref = reference,
        bComplete = false
    })
    return objId
end
