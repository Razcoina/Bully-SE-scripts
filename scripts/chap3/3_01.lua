local MISSION_RUNNING = 0
local MISSION_SUCCESS = 1
local MISSION_FAILURE = -1
local bMissionStatus = MISSION_RUNNING
local szMissionReason
local tblPedModels = {
    25,
    30,
    23
}
local tblPickupModels = { 526 }
local tblWeaponModels = {
    328,
    359,
    361
}
local tblPhotoTargets = {}
local tblDialogue = {}
local johnny = -1
local lola, gord
local bKissing = false
local bInitiateKiss = false
local bInitiateKissInAlley, bGoToAlley, bHandHolding
local bKissOver = false
local bReachedPathEnd = false
local giftType = 16
local giftModel = 526
local currentDestination = 999
local gDest = {}
local tblDestinations = {}
local spookMin, spookMax = 6, 40
local spookDif = spookMax - spookMin
local spookRatio = 0
local nCurrentDistancePercent = 0
local nCurrentDistancePercentMax = 100
local nVolumeKissers = "medium"
local speechSpokeTime = 0
local gObjective, objBlip, objRetJohnny
local bStartKissFinal = false
local nPhotoCount = 0
local kissCount = 0
local bLoop = true
local gGordBlip, gLolaBlip
local bGotFirstPic = false
local bSkipClose
local bNumKisses = 7
local bCounterRunning = true
local nClimbPed
local bPlayerIsSpotted = false
local bKissingState = false
local h, k, g = "H", "K", "G"
local bHandholdPhoto, bFlowerPhoto, bKissPhoto, bDisablePhoto

function MissionSetup()
    PlayCutsceneWithLoad("3-01", true)
    shared.inPhotoMission = true
    SoundPlayInteractiveStream("MS_FootStealthLow.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetMidIntensityStream("MS_FootStealthMid.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetHighIntensityStream("MS_FootStealthHigh.rsm", MUSIC_DEFAULT_VOLUME)
    MissionDontFadeIn()
    DATLoad("3_01.DAT", 2)
    DATInit()
    DisablePOI(false, true)
    PedSetUniqueModelStatus(25, -1)
end

function main()
    local gotoBlip
    local missionStarted = true
    bCounterRunning = true
    local bRetCashObj = false
    bLoop = true
    LoadModels(tblPedModels)
    LoadModels(tblPickupModels)
    LoadWeaponModels(tblWeaponModels)
    LoadActionTree("Act/Conv/3_01.act")
    LoadAnimationGroup("NPC_Love")
    LoadAnimationGroup("NIS_3_01")
    LoadAnimationGroup("MINI_React")
    F_PopulateTables()
    currentDestination = F_GetNextDestination()
    CounterSetIcon("HUDIcon_photos", "HUDIcon_photos_x")
    CounterSetCurrent(0)
    CounterSetMax(3)
    AreaForceLoadAreaByAreaTransition(true)
    AreaTransitionPoint(0, POINTLIST._3_01_GOTOBLIP, 1, true)
    AreaForceLoadAreaByAreaTransition(false)
    CreateThread("T_MissionStatus")
    CameraFade(1000, 1)
    local x, y, z = GetPointList(POINTLIST._3_01_GOTOBLIP)
    objBlip = BlipAddXYZ(x, y, z, 0)
    BlipRemove(objBlip)
    CounterMakeHUDVisible(true)
    while AreaIsLoading() do
        Wait(0)
    end
    F_SetupMission()
    Wait(500)
    local startx, starty, startz, head = GetPointList(POINTLIST._3_01_PLAYERSTART)
    PlayerSetPosSimple(startx, starty, startz)
    PedFaceHeading(gPlayer, head - 90, 0)
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false, true)
    CameraReturnToPlayer()
    Wait(500)
    CameraFade(500, 1)
    CreateThread("T_Photography")
    CreateThread("T_Dialogue")
    objPhotKiss = MissionObjectiveAdd("3_01_PHOTKISS")
    objPhotHand = MissionObjectiveAdd("3_01_PHOTHAND")
    objPhotFlow = MissionObjectiveAdd("3_01_PHOTFLOW")
    shared.gKiss = true
    local bGordSpeaking = true
    local nTimerSpeech = 9000
    while bLoop do
        Wait(0)
        bPlayerIsSpotted = PedCanSeeObject(gord, gPlayer, 3) or PedCanSeeObject(lola, gPlayer, 3)
        if bHandHolding and not bPlayerIsSpotted and PedIsValid(gord) and PedIsValid(lola) and GetTimer() - nTimerSpeech >= 6500 and not SoundSpeechPlaying(gord) and not SoundSpeechPlaying(lola) then
            if bGordSpeaking then
                --print("[3.01] HANDHOLDING SPEECH: Gord Replies ")
                SoundPlayScriptedSpeechEvent(gord, "CONVERSATION_QUESTION_REPLY", 0, "medium", false)
                nTimerSpeech = GetTimer()
            else
                --print("[3.01] HANDHOLDING SPEECH: Lola Talks ")
                SoundPlayScriptedSpeechEvent(lola, "CONVERSATION_QUESTION", 0, "medium", false)
            end
            bGordSpeaking = not bGordSpeaking
            --print(tostring(bGordSpeaking))
        end
        if bPlayerIsSpotted and not bKissingState then
            PedStop(gord)
            PedStop(lola)
            PedSetActionNode(gord, "/Global/3_01/Anims/Break", "Act/Conv/3_01.act")
            PedSetActionNode(lola, "/Global/3_01/Anims/Break", "Act/Conv/3_01.act")
            PedSetMissionCritical(lola, false)
            PedDismissAlly(gord, lola)
            PedFaceObject(gord, gPlayer, 3, 1, false)
            PedFaceObject(lola, gPlayer, 3, 1, false)
            PedSetMissionCritical(lola, true, cbFailLola, true)
            while PedCanSeeObject(gord, gPlayer, 3) or PedCanSeeObject(lola, gPlayer, 3) do
                TextPrint("3_01_SPOTTED", 0.2, 1)
                local nDialogueChoice = math.random(1, 4)
                if GetTimer() - nTimerSpeech >= 2200 then
                    if nDialogueChoice == 1 then
                        SoundPlayScriptedSpeechEvent(lola, "M_3_01", 59, "jumbo", false)
                        nTimerSpeech = GetTimer()
                    elseif nDialogueChoice == 2 or nDialogueChoice == 3 then
                        SoundPlayScriptedSpeechEvent(gord, "JEER", 0, "jumbo", false)
                        nTimerSpeech = GetTimer()
                    else
                        SoundPlayScriptedSpeechEvent(lola, "BUMP_RUDE", 0, "jumbo", false)
                        nTimerSpeech = GetTimer()
                    end
                end
                Wait(0)
            end
            PedFaceObject(gord, gPlayer, 3, 1, true)
            PedFaceObject(lola, gPlayer, 3, 1, true)
            PedStop(gord)
            PedStop(lola)
            PedClearObjectives(gord)
            PedClearObjectives(lola)
            bHandHolding = true
            PedRecruitAlly(gord, lola, true)
            Wait(1500)
            bGoToAlley = false
            bInitiateKissInAlley = false
            currentDestination = F_GetNextDestination()
            PedMoveToPoint(gord, 0, gDest.dest, 1, F_KissTime, 0.3, false)
        end
        if bCounterRunning then
            if true or bSkipClose then
                gGordBlip = AddBlipForChar(gord, 5, 0, 5)
                gLolaBlip = AddBlipForChar(lola, 4, 0, 5)
                bCounterRunning = false
                TextPrint("3_01_OALLEY", 4, 1)
            end
        end
        if shared.gKiss then
            --print("[3.01] >> Finding a Place to Kiss")
            currentDestination = F_GetNextDestination()
            shared.gDestination301 = gDest.dest
            shared.gKiss = false
        end
        if bInitiateKiss then
            --print("[3.01] >> Kissing Now!")
            bKissingState = true
            PedFaceObject(gord, lola, 2, 1, true)
            PedFaceObject(lola, gord, 2, 1, true)
            Wait(1500)
            PedDismissAlly(gord, lola)
            F_Kiss(gord, lola, "/Global/3_01/Anims/FlowerGive", false)
            bInitiateKiss = false
            bGoToAlley = true
        end
        if bInitiateKissInAlley then
            bKissingState = true
            PedFaceObject(gord, lola, 2, 1, true)
            PedFaceObject(lola, gord, 2, 1, true)
            Wait(1500)
            PedDismissAlly(gord, lola)
            F_Kiss(gord, lola, "/Global/3_01/Anims/Kiss", false)
            bInitiateKissInAlley = false
        end
        if bKissOver then
            --print("[3.01] >> Finished kissing")
            Wait(1000)
            bKissingState = false
            bKissOver = false
            if not bCounterRunning then
                kissCount = kissCount + 1
            end
            if kissCount >= bNumKisses then
                --print("MOVING TO FINAL")
                bHandHolding = true
                PedRecruitAlly(gord, lola, true)
                Wait(500)
                PedMoveToPoint(gord, 0, POINTLIST._3_01_KISSFINAL, 1, F_KissTime, 0.3, false)
                F_DoLastKiss()
            elseif bGoToAlley then
                --print("[3.01] >> Moving to Alley")
                PedRecruitAlly(gord, lola)
                Wait(500)
                SoundPlayScriptedSpeechEvent(lola, "SEE_BOY_IN_DORM", 0, "jumbo", false)
                PedMoveToPoint(gord, 1, gDest.dest, 4, F_KissTimeAlley, 0.3, false)
                bGoToAlley = false
                shared.gKiss = true
            else
                --print("[3.01] >> Moving to Sidewalk, STARTING HANDHOLDING")
                bHandHolding = true
                PedRecruitAlly(gord, lola, true)
                Wait(500)
                PedMoveToPoint(gord, 0, gDest.dest, 1, F_KissTime, 0.3, false)
            end
        end
        if not PlayerIsInTrigger(TRIGGER._3_01_MISSIONBLOCK) and 3 > CounterGetCurrent() then
            if not gotoBlip then
                if missionStarted then
                    missionStarted = false
                else
                    TextPrint("3_01_SEARCH", 4, 1)
                end
                gotoBlip = BlipAddPoint(POINTLIST._3_01_GOTOBLIP, 0)
            elseif not PlayerIsInTrigger(TRIGGER._3_01_MISSIONAREA) then
                szMissionReason = "3_01_FAILLEFT"
                bMissionStatus = MISSION_FAILURE
            end
        elseif gotoBlip then
            BlipRemove(gotoBlip)
            gotoBlip = nil
        end
        if bCounterRunning then
            local x1, y1 = PedGetPosXYZ(gPlayer)
            local x2, y2 = PedGetPosXYZ(gord)
            spookRatio = (DistanceBetweenCoords2d(x1, y1, x2, y2) - spookMin) / spookDif * 100
            if spookRatio < 0 then
                spookRatio = 0
            elseif 100 < spookRatio then
                spookRatio = 100
            end
            spookRatio = 100 - spookRatio
            nCurrentDistancePercent = spookRatio
        end
        if bKissFail then
            Wait(1000)
            if nPhotoCount <= 0 then
                szMissionReason = "3_01_ONOPIC"
                bMissionStatus = MISSION_FAILURE
            else
                bLoop = false
            end
        end
    end
    Wait(1000)
    if 3 > CounterGetCurrent() then
        szMissionReason = "3_01_ONOPIC"
        bMissionStatus = MISSION_FAILURE
    else
        BlipRemove(gotoBlip)
        gotoBlip = nil
        F_CleanupLolaAndGordBlips()
        AddBlipForChar(johnny, 12, 0, 1)
    end
    while MissionActive() do
        Wait(0)
    end
    Wait(50000)
end

function F_DoLastKiss()
    while not (bInitiateKiss or bInitiateKissInAlley) do
        Wait(0)
    end
    --print("F_DoLastKiss() >> FIRING")
    bStartKissFinal = true
    if bStartKissFinal then
        bHandHolding = false
        PedClearObjectives(shared.ped1)
        PedClearObjectives(shared.ped2)
        Wait(1000)
        while not PedIsPlaying(shared.ped2, "/Global/3_01/Anims/FlowerGive/FlowerGive", true) do
            PedLockTarget(shared.ped1, shared.ped2, 3)
            PedSetActionNode(shared.ped1, "/Global/3_01/Anims/FlowerGive/FlowerGive", "Act/Conv/3_01.act")
            Wait(500)
        end
        while PedIsPlaying(shared.ped1, "/Global/3_01/Anims/FlowerGive/FlowerGive", true) do
            Wait(0)
        end
        PedStop(gord)
        PedStop(lola)
        Wait(2500)
        while not PedIsPlaying(shared.ped2, "/Global/3_01/Anims/KissFinal", true) do
            PedLockTarget(shared.ped1, shared.ped2, 3)
            PedSetActionNode(shared.ped1, "/Global/3_01/Anims/KissFinal", "Act/Conv/3_01.act")
            Wait(500)
        end
        while PedIsPlaying(shared.ped2, "/Global/3_01/Anims/KissFinal", true) do
            Wait(0)
        end
        bStartKissFinal = false
    end
    bInitiateKiss = false
    bInitiateKissInAlley = false
    --print("F_DoLastKiss() >> EXITING")
end

function cbClimbLadder(pedid)
    nClimbPed = pedid
    --print("[cbClimbLadder] >> passing ped id: " .. tostring(pedid))
end

function F_CleanupLolaAndGordBlips()
    if gGordBlip then
        BlipRemove(gGordBlip)
        gGordBlip = nil
    end
    if gLolaBlip then
        BlipRemove(gLolaBlip)
        gLolaBlip = nil
    end
end

function MissionCleanup()
    UnLoadAnimationGroup("NPC_Love")
    UnLoadAnimationGroup("NIS_3_01")
    UnLoadAnimationGroup("MINI_React")
    shared.inPhotoMission = false
    EnablePOI(true, true)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    SoundEnableSpeech_ActionTree()
    F_MakePlayerSafeForNIS(false)
    CameraReturnToPlayer(false)
    F_CleanupLolaAndGordBlips()
    shared.gHitchHikeLoc = 1
    shared.gHitchHikeMis = MissionGetCurrentName()
    SoundStopInteractiveStream()
    if johnny and PedIsValid(johnny) then
        PedSetFlag(johnny, 113, false)
        PedSetInvulnerable(johnny, false)
        PedIgnoreStimuli(johnny, false)
        PedSetStationary(johnny, false)
    end
    RemovePlayerItem(526)
    if PedIsValid(johnny) then
        PedDelete(johnny)
    end
    if PedIsValid(gord) then
        PedClearObjectives(gord)
        PedMakeAmbient(gord)
        PedSetMinHealth(gord, 0)
    end
    if PedIsValid(lola) then
        PedClearObjectives(lola)
        PedMakeAmbient(lola)
        PedSetMinHealth(lola, 0)
    end
    CounterMakeHUDVisible(false)
    PedSetUniqueModelStatus(25, 1)
    DATUnload(2)
end

function F_PopulateTables()
    tblPhotoTargets = {
        gord = { id = nil },
        lola = { id = nil }
    }
    tblDestinations = {
        {
            dest = POINTLIST._3_01_KISSBIKEALLEY,
            pathpackage = nil
        },
        {
            dest = POINTLIST._3_01_KISSCOMICALLEY,
            pathpackage = nil
        },
        {
            dest = POINTLIST._3_01_KISSYUMALLEY,
            pathpackage = nil
        },
        {
            dest = POINTLIST._3_01_KISSBARBERALLEY,
            pathpackage = nil
        },
        {
            dest = POINTLIST._3_01_KISSDUMPSTERALLEY,
            pathpackage = nil
        }
    }
end

function cbJohnnyTalk()
    SoundPlayScriptedSpeechEvent(johnny, "M_3_01", 56, "jumbo", false)
    bMissionStatus = MISSION_SUCCESS
end

function cbFail()
    if PedGetWhoHitMeLast(johnny) == gPlayer then
        if johnny and PedIsValid(johnny) then
            PedSetInvulnerable(johnny, false)
            PedSetFlag(johnny, 113, false)
            PedSetStationary(johnny, false)
            PedIgnoreStimuli(johnny, false)
            PedMakeAmbient(johnny)
        end
        bMissionStatus = MISSION_FAILURE
        szMissionReason = "3_01_HITJOHN"
    end
end

function cbFailGord()
    --print("YOU HIT GORD")
    if PedIsValid(gord) and PedGetWhoHitMeLast(gord) == gPlayer then
        bMissionStatus = MISSION_FAILURE
        szMissionReason = "3_01_HITGORD"
    end
end

function cbFailLola()
    --print("YOU HIT LOLA")
    if PedIsValid(lola) and PedGetWhoHitMeLast(lola) == gPlayer then
        bMissionStatus = MISSION_FAILURE
        szMissionReason = "3_01_HITLOLA"
    end
end

function F_SetupMission()
    F_MakePlayerSafeForNIS(true)
    johnny = PedCreatePoint(23, POINTLIST._3_01_JOHNNYSPAWN, 1)
    PedSetPedToTypeAttitude(johnny, 13, 3)
    PlayerRegisterSocialCallbackVsPed(johnny, 32, cbJohnnyTalk, true)
    PedSetMissionCritical(johnny, true, cbFail, true)
    gord = PedCreatePoint(30, gDest.dest, 1)
    lola = PedCreatePoint(25, gDest.dest, 2)
    shared.ped1 = gord
    shared.ped2 = lola
    AddBlipForChar(gord, 12, 0, 2)
    AddBlipForChar(lola, 12, 0, 2)
    PedSetMinHealth(gord, 0.05)
    PedSetMinHealth(lola, 0.05)
    PedSetMissionCritical(gord, true, cbFailGord, true)
    PedSetMissionCritical(lola, true, cbFailLola, true)
    PedAlwaysUpdateAnimation(gord, true)
    PedAlwaysUpdateAnimation(lola, true)
    PedSetInfiniteSprint(gord, true)
    PedSetInfiniteSprint(lola, true)
    tblPhotoTargets.gord.id = gord
    tblPhotoTargets.lola.id = lola
    PedIgnoreAttacks(gord, true)
    PedIgnoreAttacks(lola, true)
    PedIgnoreStimuli(gord, true)
    PedIgnoreStimuli(lola, true)
    PedOverrideStat(gord, 3, 10)
    PedOverrideStat(lola, 3, 10)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    PedSetFlag(gord, 108, true)
    PedSetFlag(lola, 108, true)
    PedSetFlag(gord, 117, false)
    PedSetFlag(lola, 117, false)
    CameraSetWidescreen(true)
    CameraFade(500, 0)
    Wait(505)
    DoublePedShadowDistance(true)
    PlayerSetControl(0)
    CameraFade(500, 1)
    SoundSetAudioFocusCamera()
    local x, y, z = GetPointFromPointList(gDest.dest, 3)
    local cx, cy, cz = GetPointFromPointList(gDest.dest, 1)
    CameraSetXYZ(x, y, z, cx, cy, cz - 0.1)
    PedFaceObject(gord, lola, 2, 1, true)
    PedFaceObject(lola, gord, 2, 1, true)
    Wait(500)
    PedSetActionNode(gord, "/Global/3_01/Anims/FlowerGive/FlowerGive", "Act/Conv/3_01.act")
    TextPrint("3_01_OALLEY", 6.5, 1)
    Wait(6500)
    CameraFade(500, 0)
    Wait(505)
    DoublePedShadowDistance(false)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    CameraReset()
    Wait(500)
    SoundSetAudioFocusPlayer()
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
end

function drvKissOver()
    if kissCount >= bNumKisses then
        bKissFail = true
        --print("drvKissOver >> bKissFail")
    else
        bKissOver = true
        --print("drvKissOver >> bKissOver")
    end
end

function drvKissFailure()
end

function F_KissFinal()
    bStartKissFinal = true
end

function F_GetNextDestination()
    local choice = math.random(1, table.getn(tblDestinations))
    --print(" F_GetNextDestination()", "Chosen point: " .. choice)
    while choice == currentDestination do
        choice = math.random(1, table.getn(tblDestinations))
        --print(" F_GetNextDestination()", "Chosen point == last destination! Re-chose: " .. choice)
    end
    if choice == table.getn(tblDestinations) then
        if choice == currentDestination then
            choice = choice - 1
        end
    elseif choice == currentDestination then
        choice = choice + 1
    end
    gDest = tblDestinations[choice]
    --print("NEXT DESTINATION = " .. choice)
    if not bCounterRunning then
        --print("NEXT DESTINATION = " .. choice .. " REMOVED!")
    end
    return choice
end

function F_GoAndKissSomewhere()
    currentDestination = F_GetNextDestination()
    PedMoveToPoint(gord, 1, gDest.dest, 1, F_KissTime, 0.3, false)
    shared.gKiss = false
end

function F_KissTime(pedid)
    --print("FLOWERGIVING IN ALLEY!!! Or at least trying to.STOPPED HANDHOLDING")
    bHandHolding = false
    bInitiateKiss = true
end

function F_KissTimeAlley(pedid)
    --print("KISSING IN ALLEY!!! Or at least trying to. ")
    bInitiateKissInAlley = true
end

function F_QueueDialogue(speaker, nEvent)
    table.insert(tblDialogue, { id = speaker, event = nEvent })
end

function F_PlayDialogueWait(speaker, nEvent)
    SoundPlayScriptedSpeechEvent(speaker, "M_3_01", nEvent, "jumbo")
    while SoundSpeechPlaying() do
        Wait(0)
        --print(SoundSpeechPlaying())
    end
end

function F_Kiss(ped, targetPed, szKissNode, bWait)
    PedFaceObject(lola, gord, 2, 1)
    PedFaceObject(gord, lola, 2, 1)
    PedLockTarget(ped, targetPed, 3)
    while not PedIsPlaying(ped, szKissNode, true) do
        Wait(0)
        --print("TRYING TO KISS")
        PedSetActionNode(ped, szKissNode, "Act/Conv/3_01.act")
    end
    bKissing = true
    if bWait then
        while PedIsPlaying(ped, szKissNode, true) do
            Wait(0)
        end
    end
    bKissing = false
end

function F_Cinematic(bStart)
    if bStart then
        CameraFade(500, 0)
        Wait(500)
        PlayerSetControl(0)
        CameraSetWidescreen(true)
        CameraFade(500, 1)
        F_MakePlayerSafeForNIS(true, true)
    elseif not bStart then
        CameraFade(500, 0)
        Wait(500)
        CameraReturnToPlayer()
        CameraFade(500, 1)
        PlayerSetControl(1)
        CameraSetWidescreen(false)
        F_MakePlayerSafeForNIS(false, true)
    end
end

function F_Speech(speaker, event)
    SoundPlayScriptedSpeechEvent(speaker, "M_3_01", event, "jumbo")
end

function drvKissSpot()
    if bPlayerIsSpotted then
        SoundStopCurrentSpeechEvent()
        return 1
    else
        return 0
    end
end

function T_Dialogue()
    while not PlayerHasItem(526) do
        Wait(0)
        if 0 < table.getn(tblDialogue) and PedIsValid(tblDialogue[1].id) and not SoundSpeechPlaying(gord) and not SoundSpeechPlaying(lola) then
            SoundPlayScriptedSpeechEvent(tblDialogue[1].id, "M_3_01", tblDialogue[1].event, nVolumeKissers, false)
            table.remove(tblDialogue, 1)
        end
    end
end

function T_MissionStatus()
    local bLoop = true
    local bReturnToJohnnyMessage = false
    while bLoop and bMissionStatus ~= MISSION_FAILURE do
        Wait(0)
        if CounterGetCurrent() == 3 and PlayerIsInAreaObject(johnny, 2, 4, 0) then
            PedSetInvulnerable(johnny, true)
            PlayerSetInvulnerable(true)
            F_MakePlayerSafeForNIS(true, true)
            PlayerSetControl(0)
            SoundDisableSpeech_ActionTree()
            PedStop(gPlayer)
            Wait(10)
            CameraSetWidescreen(true)
            while PedIsOnVehicle(gPlayer) do
                Wait(0)
                F_ForcePlayerDismountBike()
            end
            PedIgnoreStimuli(johnny, false)
            PedSetStationary(johnny, false)
            PlayerSetInvulnerable(false)
            PedSetInvulnerable(johnny, false)
            CameraSetFOV(40)
            PedLockTarget(gPlayer, johnny, 3)
            PedMoveToObject(johnny, gPlayer, 2, 0)
            while not PlayerIsInAreaObject(johnny, 2, 0.8, 0) do
                Wait(0)
            end
            PedSetFlag(johnny, 113, false)
            PedStop(johnny)
            PedClearObjectives(johnny)
            PedFaceObject(gPlayer, johnny, 2, 1)
            PedFaceObject(johnny, gPlayer, 3, 1)
            PedLockTarget(gPlayer, johnny, 3)
            Wait(500)
            SoundPlayScriptedSpeechEvent(gPlayer, "M_3_01", 55, "genric", false, false)
            PedSetActionNode(gPlayer, "/Global/3_01/Anims/GivePhotos/GiveJohnny3_01", "Act/Conv/3_01.act")
            while PedIsPlaying(gPlayer, "/Global/3_01/Anims/GivePhotos/GiveJohnny3_01", true) do
                Wait(0)
            end
            bLoop = false
            PedStopSocializing(johnny)
            PedLockTarget(johnny, -1, 3)
            PedClearObjectives(johnny)
            PedMoveToXYZ(johnny, 0, 501.12103, -196.32683, 2.87158)
            MinigameSetCompletion("M_PASS", true, 2000)
            MinigameAddCompletionMsg("MRESPECT_GP5", 2)
            SetFactionRespect(4, GetFactionRespect(4) + 5)
            SoundPlayMissionEndMusic(true, 0)
            Wait(3000)
            while MinigameIsShowingCompletion() do
                Wait(0)
            end
            CameraFade(500, 0)
            Wait(501)
            if johnny then
                PedDelete(johnny)
                johnny = nil
            end
            CameraReset()
            CameraReturnToPlayer()
            MissionSucceed(false, false, false)
            Wait(500)
            CameraFade(500, 1)
            Wait(101)
            PlayerSetControl(1)
        elseif bMissionStatus == MISSION_FAILURE then
            bLoop = false
            SoundPlayMissionEndMusic(false, 0)
            if szMissionReason then
                F_MakePlayerSafeForNIS(true, true)
                if PedIsValid(johnny) then
                    PedDelete(johnny)
                end
                PlayerSetControl(0)
                local x, y, z = PedGetOffsetInWorldCoords(gPlayer, 0, 1, 1.3)
                local px, py, pz = PlayerGetPosXYZ()
                PedSetActionNode(gPlayer, "/Global/3_01/Anims/FailAnim", "Act/Conv/3_01.act")
                CameraSetXYZ(x, y, z, px, py, pz + 1.5)
                MissionFail(false, true, szMissionReason)
            else
                MissionFail(false)
            end
        end
        if not bReturnToJohnnyMessage and CounterGetCurrent() == 3 then
            PedSetFlag(johnny, 113, true)
            PedIgnoreStimuli(johnny, true)
            PedSetStationary(johnny, true)
            TextPrint("3_01_ORETCASH", 4, 1)
            CounterMakeHUDVisible(false)
            MissionObjectiveComplete(objPhotKiss)
            MissionObjectiveComplete(objPhotHand)
            MissionObjectiveComplete(objPhotFlow)
            objRetJohnny = MissionObjectiveAdd("3_01_ORETCASH")
            AddBlipForChar(johnny, 12, 0, 4)
            BlipRemove(gGordBlip)
            BlipRemove(gLolaBlip)
            bReturnToJohnnyMessage = true
        end
    end
    --print("[T_MISSIONSTATUS]>> ", "EXITING! ALARM!::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ")
end

function F_ForcePlayerDismountBike()
    Wait(3000)
    PlayerDismountBike()
end

function F_PhotConditionKiss()
    if not bKissPhoto and (PedIsPlaying(gord, "/Global/3_01/Anims/Kiss/", true) or PedIsPlaying(gord, "/Global/3_01/Anims/KissFinal", true)) then
        return true
    end
    return false
end

function F_PhotConditionFlower()
    if not bFlowerPhoto and PedIsPlaying(gord, "/Global/3_01/Anims/FlowerGive", true) and not PedIsPlaying(gord, "/Global/3_01/Anims/FlowerGive/FlowerGive/Give_Attempt/Receive/SeeBreak", true) then
        return true
    end
    return false
end

function F_PhotConditionHandhold()
    if not bHandholdPhoto and bHandHolding then
        return true
    end
    return false
end

function F_ToggleBool(param)
    if param == 1 then
        bHandholdPhoto = true
        h = ""
    elseif param == 2 then
        bFlowerPhoto = true
        g = ""
    elseif param == 3 then
        bKissPhoto = true
        k = ""
    end
end

function T_Photography()
    local gPhotoTargets = {
        { cond = F_PhotConditionHandhold, obj = objPhotHand },
        { cond = F_PhotConditionFlower,   obj = objPhotFlow },
        { cond = F_PhotConditionKiss,     obj = objPhotKiss }
    }
    local photohasbeentaken, wasValid
    while bMissionStatus == MISSION_RUNNING do
        Wait(0)
        validTarget = false
        for i, target in gPhotoTargets do
            if not target.taken and PhotoTargetInFrame(gord, 2) and target.cond() then
                gPhotoTargets[i].valid = true
                validTarget = true
            end
        end
        PhotoSetValid(validTarget)
        photohasbeentaken, wasValid = PhotoHasBeenTaken()
        if photohasbeentaken and wasValid then
            for i, target in gPhotoTargets do
                joshLazyHack = target.valid or target.wasValid
                if joshLazyHack and not target.taken then
                    target.taken = true
                    F_ToggleBool(i)
                    GiveItemToPlayer(giftModel)
                    CounterIncrementCurrent(1)
                    MissionObjectiveComplete(target.obj)
                    nPhotoCount = nPhotoCount + 1
                    TextPrint("3_01_PHOT" .. h .. k .. g, 4, 1)
                    if not bGotFirstPic then
                        bSkipClose = true
                        bGotFirstPic = true
                        AddBlipForChar(johnny, 12, 0, 2)
                    end
                end
            end
        end
        for i, target in gPhotoTargets do
            target.wasValid = target.valid
            if target.valid == true and not target.taken then
                target.valid = false
            end
        end
    end
end
