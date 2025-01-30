local tblPedModels = {
    25,
    24,
    27,
    22,
    26,
    28,
    29
}
local tblPickupModels = {
    509,
    490,
    496,
    508,
    507,
    521,
    362,
    315
}
local tblWeaponModels = {
    324,
    303,
    339
}
local bMissionComplete = false
local bMissionFailed = false
local bExited = false
local bGotAllItems = false
local bStage = 1
local nNumberPickups = 16
local nNumberHighPickups = 11
local nGreasersKilled = 0
local tblPickups = {}
local tblGreasers = {}
local tblPickupsLoad = {}
local nPickupCounter = 0
local bSmokerSpotted = false
local bReachedEndPath = false
local bCatwalkFightStarted = false
local TESTblip
local bSleeperAwake = false
local bCatwalkFight = false
local bCatwalkCam = true
local idSmoker, idNorton
local bDebug = true
local idLola, idNorton, blipNorton, lolaBlip
local nMaxLolaUnique = PedGetUniqueModelStatus(25)
local tennPipes, tennPipesType
local nGreaserModelRequestCount = 1
local objEnter, objPerfume, objLipstick, objKey, objDiary, objLaundry, objLeave, objNorton, objSmash, objGetAll, EscapeBlip
local nThreadsCreated = 0
local nThreadsKilled = 0
local tblGreaserModels = {
    24,
    27,
    26,
    28
}

function MissionSetup()
    shared.gWindowsOpen = true
    PlayCutsceneWithLoad("3-05", true)
    DATLoad("3_05.DAT", 2)
    PedSetUniqueModelStatus(25, -1)
    LoadAnimationGroup("Area_Tenements")
    LoadAnimationGroup("G_Grappler")
    LoadAnimationGroup("POI_Smoking")
    LoadAnimationGroup("Sitting_Boys")
    LoadAnimationGroup("NIS_3_05")
    LoadAnimationGroup("1_G1_TheDiary")
    MissionDontFadeIn()
end

function main()
    LoadModels(tblPedModels)
    LoadModels(tblPickupModels)
    LoadWeaponModels(tblWeaponModels)
    LoadActionTree("Act/Conv/3_05.act")
    LoadActionTree("Act/AI/AI_Norton.act")
    LoadActionTree("Act/Anim/3_05_Norton.act")
    LoadActionTree("Act/Conv/1_G1.act")
    F_PopulateTables()
    AreaSetDoorLocked(TRIGGER._DT_TPOOR_TENWINDOW, false)
    PedSetTypeToTypeAttitude(4, 13, 0)
    F_IntroCinematic()
    PauseGameClock()
    F_CreatePickups()
    F_SetupHUD()
    CreateThread("T_HammerwallHints")
    F_FirstFloor()
    F_CatWalk()
    F_SecondThirdFloor()
    F_NortonFight()
    F_Escape()
    UnpauseGameClock()
    F_Return()
    Wait(1000)
end

function MissionCleanup()
    UnpauseGameClock()
    if tennPipes then
        DeletePersistentEntity(tennPipes, tennPipesType)
    end
    SoundStopInteractiveStream()
    RemovePlayerItem(521)
    RemovePlayerItem(496)
    RemovePlayerItem(507)
    RemovePlayerItem(508)
    RemovePlayerItem(490)
    RemovePlayerItem(509)
    if idLola ~= nil and not PedIsDead(idLola) then
        PedSetMissionCritical(idLola, false)
        PedSetFlag(idLola, 113, false)
        PedSetInvulnerable(idLola, false)
        PedIgnoreStimuli(idLola, false)
        PedSetStationary(idLola, false)
        PedMakeAmbient(idLola)
        PedWander(idLola, 0)
    end
    CameraSetWidescreen(false)
    BlipRemove(lolaBlip)
    shared.gWindowsOpen = nil
    PedResetTypeAttitudesToDefault()
    PedSetUniqueModelStatus(25, nMaxLolaUnique)
    ToggleHUDComponentVisibility(0, true)
    AreaSetDoorLocked(TRIGGER._DT_TPOOR_TENWINDOW, true)
    if TESTblip then
        BlipRemove(TESTblip)
    end
    PedHideHealthBar()
    CounterMakeHUDVisible(false, false)
    if AreaGetVisible() == 36 and 0 < PlayerGetHealth() then
        AreaTransitionPoint(0, POINTLIST._3_05_TENWINDOW)
    end
    DATUnload(2)
    UnLoadAnimationGroup("Area_Tenements")
    UnLoadAnimationGroup("Sitting_Boys")
    UnLoadAnimationGroup("POI_Smoking")
    UnLoadAnimationGroup("G_Grappler")
    PickupRemoveAll(324)
end

function F_Fail()
    if idLola and PedIsValid(idLola) then
        PedSetInvulnerable(idLola, false)
        PedSetFlag(idLola, 113, false)
        PedSetStationary(idLola, false)
        PedIgnoreStimuli(idLola, false)
        PedMakeAmbient(idLola)
    end
    bMissionFailed = true
end

function T_HammerwallHints()
    while AreaGetVisible() == 36 do
        Wait(0)
        if (PlayerIsInTrigger(TRIGGER._3_05_HAMMERWALL01) or PlayerIsInTrigger(TRIGGER._3_05_HAMMERWALL02) or PlayerIsInTrigger(TRIGGER._3_05_HAMMERWALL03) or PlayerIsInTrigger(TRIGGER._3_05_HAMMERWALL03) or PlayerIsInTrigger(TRIGGER._3_05_HAMMERWALL05)) and not WeaponEquipped(324) then
            TextPrint("3_05_OBRWALL", 0.5, 1)
        end
    end
    collectgarbage()
end

local tblFirstGrease = {}
local tblCatwalkGrease = {}
local tblSecondGrease = {}
local tblEndGrease = {}

function F_IntroCinematic()
    local bx, by, bz = GetPointList(POINTLIST._3_05_TENWINDOW)
    objEnter = MissionObjectiveAdd("3_05_OENTER")
    TextPrint("3_05_OENTER", 4, 1)
    AreaTransitionPoint(0, POINTLIST._3_05_CINESTART)
    while AreaGetVisible() ~= 0 do
        Wait(0)
    end
    AreaClearAllPeds()
    Wait(2000)
    CameraFade(1000, 1)
    CameraReturnToPlayer()
    Wait(500)
    CameraFade(1000, 1)
    TextPrint("3_05_OENTER", 4, 1)
    --print("[JASON]===========> COORDS : " .. bx .. " " .. by .. " " .. bz)
    TESTblip = BlipAddXYZ(bx, by, bz, 0)
    while AreaGetVisible() ~= 36 do
        if PlayerIsInAreaXYZ(bx, by, bz, 1, 7) then
        end
        Wait(0)
    end
    PAnimSetActionNode(TRIGGER._DT_TENEMENT_WINDOW, "/Global/ExtWind/NotUseable", "Act/Props/ExtWind.act")
    MissionObjectiveComplete(objEnter)
    BlipRemove(TESTblip)
end

function F_FirstFloor()
    SoundStopInteractiveStream()
    SoundPlayInteractiveStream("MS_TenementsLow.rsm", 0.6)
    SoundSetHighIntensityStream("MS_TenementsMid.rsm", 0.6)
    objPerfume = MissionObjectiveAdd("3_05_OPERF")
    objLipstick = MissionObjectiveAdd("3_05_OLIPSTICK")
    objKey = MissionObjectiveAdd("3_05_OKEY")
    objDiary = MissionObjectiveAdd("3_05_ODIARY")
    objLaundry = MissionObjectiveAdd("3_05_OLAUND")
    objGetAll = MissionObjectiveAdd("3_05_GETITEMS")
    TextPrint("3_05_GETITEMS", 4, 1)
    F_CreatePedList(POINTLIST._3_05_FIRSTFLOORGREASE, tblFirstGrease)
    F_SpecialCaseSetups(1)
    local bGreaserSpeaking = false
    local timeSlice = GetTimer()
    while not (PlayerIsInTrigger(TRIGGER._3_05_STARTSHOOTING) or PedIsHit(tblFirstGrease[5], 2, 1000) or PedIsHit(tblFirstGrease[6], 2, 1000)) do
        Wait(0)
        if not SoundSpeechPlaying(tblFirstGrease[5]) and not SoundSpeechPlaying(tblFirstGrease[6]) and GetTimer() - timeSlice > 9000 then
            if bGreaserSpeaking then
                SoundPlayScriptedSpeechEvent(tblFirstGrease[5], "CONVERSATION_NEGATIVE_PERSONAL", 0, "large", false)
            else
                SoundPlayScriptedSpeechEvent(tblFirstGrease[6], "CONVERSATION_NEGATIVE_REPLY", 0, "large", false)
                timeSlice = GetTimer()
            end
            bGreaserSpeaking = not bGreaserSpeaking
        end
    end
    SoundStopCurrentSpeechEvent(tblFirstGrease[5])
    SoundPlayScriptedSpeechEvent(tblFirstGrease[5], "TAUNT_NEIGHBOURHOOD_GREASER", 0, "jumbo", false)
    PedCoverSet(tblFirstGrease[5], gPlayer, POINTLIST._3_05_COVERPOINT1, 1, 20, 1, 0, 0, 2, 1, 0, 0, 1, 1, true)
    PedCoverSet(tblFirstGrease[6], gPlayer, POINTLIST._3_05_COVERPOINT2, 1, 20, 1, 0, 0, 2, 1, 0, 0, 1, 1, true)
    F_CleanPedTable(tblFirstGrease)
end

function F_CatWalk()
    local ped1 = PedCreatePoint(22, POINTLIST._3_05_CATRUNNERS, 1)
    while not (PedCanSeeObject(ped1, gPlayer, 3) or PedIsHit(ped1, 2, 1000) or PlayerIsInTrigger(TRIGGER._3_05_STARTCATWALK)) do
        Wait(0)
    end
    PedIgnoreStimuli(ped1, true)
    PedIgnoreAttacks(ped1, true)
    PedFollowPath(ped1, PATH._3_05_HALRUN, 0, 2)
    if PedIsValid(ped1) then
        SoundPlayScriptedSpeechEvent(ped1, "M_3_05", 10, "jumbo", false)
    end
    while not PlayerIsInTrigger(TRIGGER._3_05_CATWALK2) do
        Wait(0)
    end
    PedMakeAmbient(ped1)
    if PedIsValid(ped1) then
        SoundPlayScriptedSpeechEvent(ped1, "M_3_05", 9, "jumbo", false)
        PedStop(ped1)
        PedIgnoreStimuli(ped1, false)
        PedIgnoreAttacks(ped1, false)
        PedAttack(ped1, gPlayer, 3)
    end
    local ped2 = PedCreatePoint(26, POINTLIST._3_05_CATWALKB, 1)
    PedAttack(ped2, gPlayer, 3)
    PedMakeAmbient(ped2)
    while not PlayerIsInTrigger(TRIGGER._3_05_2CATWALKSTART) do
        Wait(0)
    end
    local ped4 = PedCreatePoint(27, POINTLIST._3_05_CATWALKA, 1)
    PedAttack(ped4, gPlayer, 3)
    PedMakeAmbient(ped4)
    while not PlayerIsInTrigger(TRIGGER._3_05_SECONDFLOOR) do
        Wait(0)
    end
    F_CleanPedTable(tblCatwalkGrease)
end

function F_SecondThirdFloor()
    F_CreatePedList(POINTLIST._3_05_SECONDFLOORGREASE, tblSecondGrease)
    F_SpecialCaseSetups(2)
    local bGreaserSpeaking = false
    local timeSlice = GetTimer()
    while not (PlayerIsInTrigger(TRIGGER._3_05_STARTSHOOTING2) or PedIsHit(tblSecondGrease[2], 2, 1000) or PedIsHit(tblSecondGrease[3], 2, 1000) or PedIsHit(tblSecondGrease[4], 2, 1000)) do
        Wait(0)
        if not SoundSpeechPlaying(tblSecondGrease[2]) and not SoundSpeechPlaying(tblSecondGrease[3]) and GetTimer() - timeSlice > 9000 then
            if bGreaserSpeaking then
                SoundPlayScriptedSpeechEvent(tblSecondGrease[2], "CONVERSATION_NEGATIVE_PERSONAL", 0, "medium", false)
            else
                SoundPlayScriptedSpeechEvent(tblSecondGrease[3], "CONVERSATION_NEGATIVE_REPLY", 0, "medium", false)
                timeSlice = GetTimer()
            end
            bGreaserSpeaking = not bGreaserSpeaking
        end
    end
    SoundPlayScriptedSpeechEvent(tblSecondGrease[4], "TAUNT_NEIGHBOURHOOD_GREASER", 0, "jumbo", false)
    PedCoverSet(tblSecondGrease[2], gPlayer, POINTLIST._3_05_COVERPOINT3, 1, 20, 1, 0, 0, 2, 1, 0, 0, 1, 1, false)
    PedCoverSet(tblSecondGrease[3], gPlayer, POINTLIST._3_05_COVERPOINT4, 1, 20, 1, 0, 0, 2, 1, 0, 0, 1, 1, false)
    PedCoverSet(tblSecondGrease[4], gPlayer, POINTLIST._3_05_COVERPOINT5, 1, 20, 1, 0, 0, 2, 1, 0, 0, 1, 1, false)
end

function F_NortonFight()
    while not PickupIsPickedUp(tblPickups.nortontrig.id) do
        Wait(0)
    end
    CounterIncrementCurrent(1)
    MissionObjectiveComplete(objLaundry)
    AreaClearAllPeds()
    F_ClearPedList(tblFirstGrease)
    F_ClearPedList(tblCatwalkGrease)
    F_ClearPedList(tblSecondGrease)
    F_ClearPedList(tblEndGrease)
    F_NortonIntro()
    Wait(1000)
    objNorton = MissionObjectiveAdd("3_05_ONORTON", 0, -1)
    TextPrint("3_05_ONORTON", 4, 1)
    blipNorton = AddBlipForChar(idNorton, 12, 26, 4)
    PedSetImmortalFlag(gPlayer, true)
    while not PedIsDead(idNorton) do
        Wait(0)
        if 0 >= PlayerGetHealth() then
            F_RestartNorton()
        end
    end
    PedSetImmortalFlag(gPlayer, false)
    BlipRemove(blipNorton)
    MissionObjectiveComplete(objNorton)
    TextPrint("3_05_GETITEMS", 4, 1)
    local nortonx, nortony, nortonz = PedGetPosXYZ(idNorton)
    PedDestroyWeapon(idNorton, 324)
    PedHideHealthBar()
    TextPrint("3_05_GETSLEDGE", 4, 1)
    local objGetSledge = MissionObjectiveAdd("3_05_GETSLEDGE", 0, -1)
    SoundPlayInteractiveStream("MS_TenementsLow.rsm", 0.6, 500, 500)
    SoundSetHighIntensityStream("MS_TenementsMid.rsm", 0.6)
    while not WeaponEquipped(324) do
        Wait(0)
    end
    TextPrint("3_05_GOTHAMR", 4, 1)
    MissionObjectiveComplete(objGetSledge)
end

function F_Escape()
    local x, y, z = GetPointList(POINTLIST._3_05_PSTART)
    local bExited = false
    while CounterGetCurrent() ~= CounterGetMax() do
        Wait(0)
    end
    PAnimSetActionNode(TRIGGER._DT_TENEMENT_WINDOW, "/Global/ExtWind/Reset", "Act/Props/ExtWind.act")
    MissionObjectiveComplete(objGetAll)
    CounterMakeHUDVisible(false, false)
    EscapeBlip = BlipAddPoint(POINTLIST._3_05_PSTART, 0)
    objLeave = MissionObjectiveAdd("3_05_OLEAVE")
    TextPrint("3_05_OLEAVE", 4, 1)
    while AreaGetVisible() ~= 0 do
        if PlayerIsInAreaXYZ(x, y, z, 1, 7) then
        end
        --print("Waiting for Exit.")
        Wait(0)
    end
    RemovePlayerItem(496)
    RemovePlayerItem(507)
    RemovePlayerItem(508)
    RemovePlayerItem(490)
    RemovePlayerItem(509)
    BlipRemove(EscapeBlip)
    MissionObjectiveComplete(objLeave)
end

local bPlayerNearLola = false

function F_Return()
    ToggleHUDComponentVisibility(0, true)
    MissionObjectiveRemove(objPerfume)
    MissionObjectiveRemove(objLipstick)
    MissionObjectiveRemove(objKey)
    MissionObjectiveRemove(objDiary)
    MissionObjectiveRemove(objLaundry)
    local objective = MissionObjectiveAdd("3_05_ORETLOLA")
    TextPrint("3_05_ORETLOLA", 4, 1)
    SoundStopInteractiveStream()
    local loop = true
    for i, entry in tblPickups do
        ItemSetCurrentNum(entry.model, 0)
    end
    ItemSetCurrentNum(521, 1)
    idLola = PedCreatePoint(25, POINTLIST._3_05_LOLAEND)
    lolaBlip = AddBlipForChar(idLola, 12, 0, 4)
    PedSetPedToTypeAttitude(idLola, 13, 4)
    PedSetMissionCritical(idLola, true, F_Fail, true)
    PedIgnoreAttacks(idLola, true)
    PedSetFlag(idLola, 113, true)
    PedSetStationary(idLola, true)
    PedIgnoreStimuli(idLola, true)
    PlayerRegisterSocialCallbackVsPed(idLola, 32, F_PlayerGiveGiftCallback, true)
    while loop do
        Wait(0)
        if not bPlayerNearLola and PlayerIsInAreaObject(idLola, 2, 3.5, 0) then
            PedSetInvulnerable(idLola, true)
            PlayerSetInvulnerable(true)
            bPlayerNearLola = true
            loop = false
        end
        if bMissionFailed then
            SoundPlayMissionEndMusic(false, 0)
            MissionFail(false, true, "3_05_HITLOLA")
            loop = false
        end
    end
    if bPlayerNearLola then
        PedSetMissionCritical(idLola, false)
        PlayerSetControl(0)
        CameraSetWidescreen(true)
        SoundDisableSpeech_ActionTree()
        F_MakePlayerSafeForNIS(true)
        F_PlayerDismountBike()
        PedSetFlag(idLola, 113, false)
        PedSetStationary(idLola, false)
        PedIgnoreStimuli(idLola, false)
        PedSetInvulnerable(idLola, false)
        PedFaceObject(idLola, gPlayer, 3, 1)
        PedFaceObject(gPlayer, idLola, 2, 1)
        PedLockTarget(gPlayer, idLola, 3)
        PedStop(idLola)
        PedClearObjectives(idLola)
        PedFaceObject(gPlayer, idLola, 2, 1)
        PedFaceObject(idLola, gPlayer, 3, 1)
        PedLockTarget(gPlayer, idLola, 3)
        Wait(500)
        PedSetActionNode(gPlayer, "/Global/3_05/Animations/Give/GiveLola3_05/", "Act/Conv/3_05.act")
        while PedIsPlaying(gPlayer, "/Global/3_05/Animations/Give/GiveLola3_05/", true) do
            Wait(0)
        end
        PedLockTarget(idLola, gPlayer)
        PedLockTarget(gPlayer, idLola)
        PedSetActionNode(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt", "Act/Player.act")
        while not PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
            Wait(0)
        end
        Wait(1000)
        MinigameSetCompletion("M_PASS", true, 2000)
        MinigameAddCompletionMsg("MRESPECT_GM10", 1)
        SoundPlayMissionEndMusic(true, 0)
        while PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) or PedIsPlaying(idLola, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
            Wait(0)
        end
        PedLockTarget(gPlayer, -1, 3)
        PedMakeAmbient(idLola)
        PedWander(idLola, 0)
        SetFactionRespect(4, GetFactionRespect(4) - 10)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        CameraFade(500, 0)
        Wait(501)
        CameraReset()
        CameraReturnToPlayer()
        PlayerSetPosPoint(POINTLIST._3_05_CINESTART, 1)
        MissionSucceed(false, false, false)
        CameraSetWidescreen(false)
        F_MakePlayerSafeForNIS(false)
        Wait(500)
        CameraFade(500, 1)
        Wait(101)
        PlayerSetControl(1)
    end
    BlipRemove(lolaBlip)
    PedMakeAmbient(idLola)
    Wait(50000)
end

function F_PlayerGiveGiftCallback()
    PedSetActionNode(gPlayer, "/Global/1_G1/Give", "Act/Conv/1_G1.act")
    PedSetMissionCritical(idLola, false)
end

function F_SpecialCaseSetups(phase)
    if phase == 1 then
        tblPickups[1].text = objDiary
        tblPickups[2].text = objPerfume
        tblPickups[3].text = objKey
        tblPickups[4].text = objLipstick
        PedSetActionNode(tblFirstGrease[1], "/Global/3_05/Animations/Idles/Smoking", "Act/Conv/3_05.act")
        PedSetActionNode(tblFirstGrease[3], "/Global/3_05/Animations/Idles/Smoking", "Act/Conv/3_05.act")
        PedSetActionNode(tblFirstGrease[4], "/Global/3_05/Animations/Idles/Smoking", "Act/Conv/3_05.act")
        PedSetWeapon(tblFirstGrease[5], 303, 100)
        PedSetWeapon(tblFirstGrease[6], 303, 100)
    elseif phase == 2 then
        PedDelete(tblSecondGrease[1])
        PedSetWeapon(tblSecondGrease[2], 303, 100)
        PedSetWeapon(tblSecondGrease[3], 303, 100)
        PedSetWeapon(tblSecondGrease[4], 303, 100)
    elseif phase == 3 then
    elseif phase == 4 then
    end
end

function F_CreatePedList(pointlist, tableToPutThemIn)
    --print(">>>[ F_CreatePedList ]", "STARTING")
    local i
    for i = 1, GetPointListSize(pointlist) do
        table.insert(tableToPutThemIn, PedCreatePoint(F_GetGreaserModel(), pointlist, i))
        --print(">>>[ F_CreatePedList ]", "Creating Ped#   ** " .. i .. " **")
    end
    for i, entry in tableToPutThemIn do
        --print(">>>[ F_CreatePedList ]", "Ped has can #   ** " .. i .. " **")
        PedOverrideStat(entry, 1, 50)
        PedOverrideStat(entry, 0, 362)
    end
    --print(">>>[ F_CreatePedList ]", "ENDING")
end

function F_ClearPedList(table)
    for i, entry in table do
        if PedIsValid(entry) then
            PedDelete(entry)
        end
    end
end

function F_SetupHUD()
    CounterSetCurrent(0)
    CounterSetMax(5)
    CounterSetIcon("lola", "lola_x")
    CounterMakeHUDVisible(true, true)
    ToggleHUDComponentVisibility(0, false)
    CreateThread("F_tPickupMaintenance")
end

function F_PopulateTables()
    tblPickups = {
        {
            id = nil,
            model = 509,
            point = POINTLIST._3_05_LOLAPICKUPS,
            element = 1,
            text = "3_05_DIARY"
        },
        {
            id = nil,
            model = 490,
            point = POINTLIST._3_05_LOLAPICKUPS,
            element = 2,
            text = "3_05_PERF"
        },
        {
            id = nil,
            model = 496,
            point = POINTLIST._3_05_LOLAPICKUPS,
            element = 3,
            text = "3_05_KEY"
        },
        {
            id = nil,
            model = 508,
            point = POINTLIST._3_05_LOLAPICKUPS,
            element = 4,
            text = "3_05_LIPSTICK"
        },
        nortontrig = {
            id = nil,
            model = 507,
            point = POINTLIST._3_05_LOLAPICKUPS,
            element = 5,
            text = "3_05_LAUND"
        }
    }
end

function F_ExecuteAnimationSequence(ped, actionNode, fileName)
    local szFile = fileName
    if ped then
        --print("[JASON]============> Executing Animation on Ped#: " .. ped)
        while not PedIsPlaying(ped, actionNode, true) do
            if szFile == nil then
                szFile = "Act/Conv/3_05.act"
            end
            Wait(0)
            PedSetActionNode(ped, actionNode, szFile)
        end
    end
end

function F_CreatePickups()
    for i, entry in tblPickups do
        --print("[JASON] ======> Processing tblPickups index# " .. i .. "     Model#" .. entry.model)
        entry.id = PickupCreatePoint(entry.model, entry.point, entry.element, 0, "PermanentButes")
        --print("[JASON] ======> Finished creating Model#" .. entry.model)
    end
    PickupCreatePoint(315, POINTLIST._3_05_LID, 1, 0, "PermanentButes")
    PickupCreatePoint(315, POINTLIST._3_05_LID, 2, 0, "PermanentButes")
    for i, entry in tblPickups do
        AddBlipForPickup(entry.id, 0, 4)
        --print("FINISHED ADDING BLIP")
    end
end

function F_SmokerCallback()
    bSmokerSpotted = true
end

function F_tCatwalkCam()
    while AreaGetVisible() == 36 do
        Wait(0)
        if bCatwalkCam then
            if PlayerIsInTrigger(TRIGGER._TENEMENTS_FIRE_ESCAPE_CAMERA) then
                if not bFixedCamera then
                    bFixedCamera = true
                    PlayerSetControl(0)
                    F_SetupPerspectiveCamera()
                    PlayerSetControl(1)
                end
            elseif bFixedCamera then
                bFixedCamera = false
                CameraAllowChange(true)
                CameraReturnToPlayer()
            end
        end
    end
    collectgarbage()
end

function F_NortonIntro()
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    F_MakePlayerSafeForNIS(true)
    CameraFade(1000, 0)
    Wait(1050)
    idNorton = PedCreatePoint(29, POINTLIST._3_05_NORTKNOCK)
    F_SetupNorton()
    PlayerSetControl(0)
    PedSetPedToTypeAttitude(idNorton, 13, 4)
    PedSetPosPoint(gPlayer, POINTLIST._3_05_JIMKNOCK)
    Wait(1000)
    PlayerFaceHeadingNow(-273)
    CameraSetWidescreen(true)
    PedSetPosPoint(idNorton, POINTLIST._3_05_NORTKNOCK)
    CameraFade(1000, 1)
    CameraSetFOV(70)
    CameraSetPath(PATH._3_05_NORTONNISCAM, true)
    CameraSetSpeed(1, 0, 2)
    CameraLookAtPath(PATH._3_05_NORTONNISCAMLOOKAT, true)
    CameraLookAtPathSetSpeed(1, 0, 2)
    F_PlayDialogueWait(idNorton, 19)
    CameraSetFOV(40)
    CameraSetXYZ(-533.05096, -42.58636, 41.97315, -532.1645, -42.126842, 41.92266)
    PedSetActionNode(gPlayer, "/Global/3_05/Animations/Player/Player01", "Act/Conv/3_05.act")
    F_PlayDialogueWait(gPlayer, 20)
    CameraSetFOV(40)
    CameraSetXYZ(-528.74255, -42.006508, 41.88461, -529.6353, -41.55634, 41.890232)
    F_PlayDialogueWait(idNorton, 21)
    PedSetActionNode(gPlayer, "/Global/3_05/Animations/DontHurt", "Act/Conv/3_05.act")
    PedSetActionNode(idNorton, "/Global/3_05/Animations/SledgeSwing", "Act/Conv/3_05.act")
    Wait(300)
    CameraSetFOV(70)
    CameraSetXYZ(-523.9464, -42.22376, 41.157673, -524.90686, -41.977615, 41.287514)
    Wait(300)
    PedSetActionNode(gPlayer, "/Global/3_05/Animations/Wall_Break", "Act/Conv/3_05.act")
    Wait(300)
    F_PlayDialogueWait(idNorton, 18)
    PedStop(idNorton)
    PedClearObjectives(idNorton)
    Wait(500)
    PedSetActionNode(idNorton, "/Global/3_05/Animations/Laugh", "Act/Conv/3_05.act")
    CameraFade(1000, 0)
    Wait(1000)
    CameraDefaultFOV()
    PedSetActionNode(idNorton, "/Global/3_05/Animations/Break", "Act/Conv/3_05.act")
    PedSetPosPoint(idNorton, POINTLIST._3_05_BOSSBATTLEJASON, 1)
    PedSetPosPoint(gPlayer, POINTLIST._3_05_BOSSBATTLEJASON, 2)
    PedFaceObjectNow(idNorton, gPlayer, 3)
    PedFaceObjectNow(gPlayer, idNorton, 2)
    PedSetPedToTypeAttitude(idNorton, 13, 0)
    PedShowHealthBar(idNorton, true, "3_05_BOSSNAME", true)
    CameraReturnToPlayer()
    SoundPlayInteractiveStreamLocked("MS_TenementsHigh.rsm", 0.5, 500, 500)
    Wait(1000)
    tennPipes, tennPipesType = CreatePersistentEntity("TennBRkPipes01", -529.151, -40.751, 41.2078, 0, 36)
    CameraFade(1000, 1)
    Wait(1000)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    PedAttack(idNorton, gPlayer, true, false)
    bSleeperAwake = true
    UnLoadAnimationGroup("NIS_3_05")
    F_MakePlayerSafeForNIS(false)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
end

function F_SetupNorton()
    PedSetIsStealthMissionPed(idNorton, false)
    PedSetStatsType(idNorton, "STAT_3_05_NORTON")
    PedSetCombatZoneMask(idNorton, true, false, false)
    PedSetAITree(idNorton, "/Global/NortonAI", "Act/AI/AI_Norton.act")
    PedSetActionTree(idNorton, "/Global/Norton", "Act/Anim/3_05_Norton.act")
    PedSetWeapon(idNorton, 324, 1)
    PedSetDamageTakenMultiplier(idNorton, 3, 0.5)
    PedSetDamageTakenMultiplier(idNorton, 0, 0.5)
    PlayerSocialDisableActionAgainstPed(idNorton, 35, true)
    PlayerSocialDisableActionAgainstPed(idNorton, 23, true)
    PlayerSocialDisableActionAgainstPed(idNorton, 30, true)
    PlayerSocialDisableActionAgainstPed(idNorton, 29, true)
    PlayerSocialDisableActionAgainstPed(idNorton, 28, true)
end

function F_tPickupMaintenance()
    nThreadsCreated = nThreadsCreated + 1
    local nIndexCount = 1
    while not bMissionComplete do
        if table.getn(tblPickups) > 0 then
            if PickupIsPickedUp(tblPickups[nIndexCount].id) then
                MissionObjectiveComplete(tblPickups[nIndexCount].text)
                table.remove(tblPickups, nIndexCount)
                CounterIncrementCurrent(1)
                if CounterGetCurrent() == CounterGetMax() then
                    if TESTblip then
                        BlipRemove(TESTblip)
                    end
                    TextPrint("3_05_OLEAVE", 4, 1)
                end
            end
            nIndexCount = nIndexCount + 1
            if nIndexCount > table.getn(tblPickups) then
                nIndexCount = 1
            end
        end
        Wait(100)
    end
    nThreadsKilled = nThreadsKilled + 1
    --print("[JASON] =======> Thread F_tPickupMaintenance KILLED, #" .. nThreadsKilled .. "/" .. nThreadsCreated)
    collectgarbage()
end

function F_GetGreaserModel()
    if nGreaserModelRequestCount > table.getn(tblGreaserModels) then
        nGreaserModelRequestCount = 1
    end
    local model = tblGreaserModels[nGreaserModelRequestCount]
    nGreaserModelRequestCount = nGreaserModelRequestCount + 1
    return model
end

function F_SetupPerspectiveCamera()
    CameraLookAtPlayer(true)
    CameraSetRelativePath(PATH._TENEMENTS_CAM_PATH2, POINTLIST._TENEMENTS_CAM_POINT_01, 0, true)
    Wait(500)
    CameraAllowChange(false)
end

function F_CleanPedTable(table)
    for _, entry in table do
        if PedIsValid(entry) then
            PedMakeAmbient(entry)
        end
    end
    table = nil
end

function F_PlayDialogueWait(speaker, nEvent)
    SoundPlayScriptedSpeechEvent(speaker, "M_3_05", nEvent, "jumbo")
    while SoundSpeechPlaying() do
        Wait(0)
        --print(SoundSpeechPlaying())
    end
end

function F_RestartNorton()
    Wait(2000)
    CameraFade(500, 0)
    Wait(505)
    PickupRemoveAll(324)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    if PedIsValid(idNorton) then
        PedDelete(idNorton)
    end
    idNorton = PedCreatePoint(29, POINTLIST._3_05_BOSSBATTLEJASON)
    F_SetupNorton()
    PedSetPosPoint(idNorton, POINTLIST._3_05_BOSSBATTLEJASON, 1)
    PedSetPosPoint(gPlayer, POINTLIST._3_05_BOSSBATTLEJASON, 2)
    Wait(100)
    PedFaceObjectNow(idNorton, gPlayer, 3)
    PedFaceObjectNow(gPlayer, idNorton, 2)
    Wait(100)
    PedSetPedToTypeAttitude(idNorton, 13, 0)
    PedShowHealthBar(idNorton, true, "3_05_BOSSNAME", true)
    CameraReturnToPlayer()
    PlayerSetHealth(PedGetMaxHealth(gPlayer))
    Wait(100)
    CameraFade(500, 1)
    CameraSetWidescreen(false)
    TextPrint("3_05_ONORTON", 4, 1)
    Wait(1300)
    PlayerSetControl(1)
    PedAttack(idNorton, gPlayer, true, false)
end
