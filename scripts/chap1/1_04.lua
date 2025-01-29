---@diagnostic disable: inject-field
local bHasFailedElsewhere = false
local bGaryHasDied = false
local bSetWindows = false
local bSpotFailure = false
local bTreeSitting = false
local bMissionComplete = false
local bMissionRunning = true
local bGaryWithPlayer = true
local fCurrentFunc, idNemesis, nemesisBlip
local gWindowsTimer = 0
local gAllDead = 0
local bMakeEmHard = false
local playerEnteredBottleZoneTime = -1
local numBottlesBroken = 0
local gHighMusicPlaying = false
local b_DeadBeforeTheirTime = false
local lastTotalBroken = 0
local bFailForWrongWeapon = false
local bHitTheWindows = false
local bTreeSitting = true
local ParkingBlip, b_blipped
local bSpotting = true
local bSpotted = false
local tut01_time = -1
local tut02_time = -1
local tut11_time = -1
local tut12_time = -1
local tut13_time = -1
local gSitting = 1
local bFieldNISDone = false
local idBurton
local bStageThreeRun = false
local idGoon1
local tut31_time = -1
local tut32_time = -1
local tut33_time = -1
local tut34_time = -1
local BurtonLastShoutedTime = 0
local bCreateSpotTread = false
local bGoonWasHit = false
local bullyDeathCount = 0
local bWarnDontKOBullies = true
local bFirstHitBullyObjective = false
local bPlayingBurtonYell = false
local bBurtonWorkoutTimer = 0
local bBurtonChasing = false
local bBurtonSawAssault = false
local bHitFromTree = false
local bPlayerFistAttack = false
local bBurtonSeesHit = false
local nCurrentGoonRoute = 1
local bNextPhase = 0
local b_InTree = false
local totalhit = 0
local gTimerGetBackInTree = false
local gTreeFailure = false
local gTreeTime = 15
local bGoonsBarfed = false
local bRunning = false
local tblGoonDex = {}
local tblGoonText = {}
local STATE_NONE = 0
local STATE_EXER = 1
local STATE_RUNN = 2
local STATE_JACK = 4
local tegymuniq
local bottles_all_broken = false
local Obj01, Obj02, Obj04, Obj05, Obj06
local bBurtonShouldShout = false
local bSomeoneGotHit = false
local Tree1Blip = 0
local NISTable = {}
local gNIS = 1
local b_DebuggingNIS = false
local F_NIS_Parking1 = function()
end
local F_NIS_FieldBullies = function()
end
local NISTotal = 4
local gTutorialTimer = 0
local gSomeoneGotHitTimer = 0
local gHitPed = 0

function MissionSetup()
    PlayCutsceneWithLoad("1-04", true)
    DATLoad("1_04.DAT", 2)
    DATInit()
    MissionDontFadeIn()
end

function F_MissionSetup()
    LoadAnimationGroup("1_04TheSlingshot")
    LoadAnimationGroup("Hang_Workout")
    LoadAnimationGroup("NIS_1_04")
    LoadActionTree("Act/Conv/1_04.act")
    WeaponRequestModel(303)
    WeaponRequestModel(304)
    PedRequestModel(75)
    PedRequestModel(55)
    PedRequestModel(109)
    PedRequestModel(111)
    PedRequestModel(112)
    PedRequestModel(231)
    PedRequestModel(232)
    PedRequestModel(110)
    PedRequestModel(130)
    fCurrentFunc = F_IntroObjective
    tegymuniq = PedGetUniqueModelStatus(55)
    PedSetUniqueModelStatus(55, -1)
    --DebugPrint("----------- xUNIQUE == " .. tostring(-1))
    tblGoonDex = {
        {
            id = nil,
            model = 109,
            dead = false,
            element = 1,
            state = STATE_NONE,
            hit = false,
            blip = 0,
            workout = true,
            path = PATH._1_04_RUNPATH01,
            callback = cbRun01,
            cbJack = cbJacks,
            time = 0
        },
        {
            id = nil,
            model = 111,
            dead = false,
            element = 2,
            state = STATE_NONE,
            hit = false,
            blip = 0,
            workout = true,
            path = PATH._1_04_RUNPATH02,
            callback = cbRun02,
            cbJack = cbJacks,
            time = 0
        },
        {
            id = nil,
            model = 112,
            dead = false,
            element = 3,
            state = STATE_NONE,
            hit = false,
            blip = 0,
            workout = true,
            path = PATH._1_04_RUNPATH03,
            callback = cbRun03,
            cbJack = cbJacks,
            time = 0
        },
        {
            id = nil,
            model = 231,
            dead = false,
            element = 4,
            state = STATE_NONE,
            hit = false,
            blip = 0,
            workout = true,
            path = PATH._1_04_RUNPATH04,
            callback = cbRun04,
            cbJack = cbJacks,
            time = 0
        },
        {
            id = nil,
            model = 232,
            dead = false,
            element = 5,
            state = STATE_NONE,
            hit = false,
            blip = 0,
            workout = true,
            path = PATH._1_04_RUNPATH05,
            callback = cbRun05,
            cbJack = cbJacks,
            time = 0
        },
        {
            id = nil,
            model = 110,
            dead = false,
            element = 6,
            state = STATE_NONE,
            hit = false,
            blip = 0,
            workout = true,
            path = PATH._1_04_RUNPATH06,
            callback = cbRun06,
            cbJack = cbJacks,
            time = 0
        }
    }
    NISTable = { F_NIS_Parking1, F_NIS_FieldBullies }
    NISTotal = table.getn(NISTable)
end

function main()
    F_MissionSetup()
    SetNumberOfHandledTriggerEventObjects(4)
    while not (WeaponRequestModel(303) and WeaponRequestModel(303)) do
        Wait(0)
    end
    GiveWeaponToPlayer(303)
    GiveAmmoToPlayer(303, 30)
    CreateThread("T_MiscHandler")
    AreaTransitionPoint(0, POINTLIST._1_04_PLAYERSTART, 1, true)
    idNemesis = PedCreatePoint(130, POINTLIST._1_04_PLAYERSTART, 2)
    PedShowHealthBar(idNemesis, true, "N_GARY")
    PedIgnoreStimuli(idNemesis, true)
    PedAddPedToIgnoreList(idNemesis, gPlayer)
    PedSetInfiniteSprint(idNemesis, true)
    nemesisBlip = AddBlipForChar(idNemesis, 2, 27, 1)
    PedSetMissionCritical(idNemesis, true, F_OnGaryDeath)
    CreateThread("T_WatchForGaryDeath")
    CameraReturnToPlayer()
    F_BusWindowHash()
    while not (bMissionComplete or bHasFailedElsewhere) do
        Wait(0)
        if gTreeFailure or bSpotFailure or b_DeadBeforeTheirTime then
            --print("===== Someone Failed ====", tostring(gTreeFailure), tostring(bSpotFailure), tostring(b_DeadBeforeTheirTime))
            break
        end
        fCurrentFunc()
    end
    --print("===== Something has broken the mission, it should fail ====", tostring(gTreeFailure), tostring(bSpotFailure), tostring(b_DeadBeforeTheirTime))
    if gTreeFailure then
        SoundPlayMissionEndMusic(false, 4)
        MissionFail(false, true, "1_04_TREE_FAIL")
    elseif bSpotFailure then
        PlayerSetControl(1)
        SoundPlayMissionEndMusic(false, 4)
        MissionFail(false, true, "1_04_SPOTTED")
        SoundSetAudioFocusPlayer()
        CameraReturnToPlayer(true)
        CameraFollowPed(gPlayer)
    elseif b_DeadBeforeTheirTime then
        --print("===== Burton has died ====")
        ClearTextQueue()
        SoundPlayMissionEndMusic(false, 4)
        MissionFail(false, true, "1_04_BURTON_KO")
    elseif bGaryHasDied then
        ClearTextQueue()
        SoundPlayMissionEndMusic(false, 4)
        MissionFail(false, true, "1_04_KO_GARY")
    elseif bHasFailedElsewhere then
        SoundPlayMissionEndMusic(false, 4)
        MissionFail(false, true)
    end
    if not bMissionComplete then
        F_MakeFieldPedsAmb()
    end
end

function MissionCleanup()
    AreaDeactivatePopulationTrigger(TRIGGER._1_04_SUPPRESSFIELDPOP)
    AreaDeactivatePopulationTrigger(TRIGGER._1_04_SUPPRESSPARKINGPOP)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    SoundStopInteractiveStream()
    UnLoadAnimationGroup("1_04TheSlingshot")
    UnLoadAnimationGroup("Hang_Workout")
    UnLoadAnimationGroup("NIS_1_04")
    RegisterGlobalEventHandler(7, nil)
    BlipRemove(Tree1Blip)
    BlipRemove(nemesisBlip)
    EnablePOI()
    MissionTimerStop()
    TutorialRemoveMessage()
    RadarRestoreMinMax()
    if idNemesis ~= nil and PedIsValid(idNemesis) then
        PedHideHealthBar()
        if not PedIsDead(idNemesis) then
            PedStop(idNemesis)
            PedMakeAmbient(idNemesis)
            PedWander(idNemesis, 0)
        end
    end
    DATUnload(2)
end

function T_MiscHandler()
    while not (not MissionActive() or bHasFailedElsewhere) do
        UpdateTextQueue()
        Wait(33)
    end
end

function F_IntroObjective()
    Wait(200)
    CameraFade(1000, 1)
    Wait(1000)
    SoundPlayAmbientSpeechEvent(idNemesis, "THIS_WAY")
    TextPrint("1_04_OBJ01", 3, 1)
    Obj01 = MissionObjectiveAdd("1_04_OBJ01")
    ParkingBlip = BlipAddPoint(POINTLIST._1_04_NEMESISPARKING, 0, 1, 1, 0)
    PedMoveToPoint(idNemesis, 2, POINTLIST._1_04_NEMESISPARKING)
    b_blipped = true
    fCurrentFunc = F_WaitForMainMap
end

function F_WaitForMainMap()
    PedOverrideStat(idNemesis, 6, 0)
    PedSetInfiniteSprint(idNemesis, true)
    AreaActivatePopulationTrigger(TRIGGER._1_04_SUPPRESSFIELDPOP)
    AreaActivatePopulationTrigger(TRIGGER._1_04_SUPPRESSPARKINGPOP)
    fCurrentFunc = F_StageOneGetToBus
end

function F_Clamp(j, total)
    --DebugPrint("F_Clamp() j: " .. j .. " total: " .. total)
    if j <= 0 then
        j = total
    else
        if total < j then
            j = 1
        else
        end
    end
    --DebugPrint("F_Clamp() final j: " .. j)
    return j
end

function F_NISSelect()
    if F_IsButtonPressedWithDelayCheck(11, 1) then
        gNIS = gNIS - 1
        gNIS = F_Clamp(gNIS, NISTotal)
        TextPrintString("NIS: " .. gNIS, 3, 1)
    elseif F_IsButtonPressedWithDelayCheck(13, 1) then
        gNIS = gNIS + 1
        gNIS = F_Clamp(gNIS, NISTotal)
        TextPrintString("NIS: " .. gNIS, 3, 1)
    elseif F_IsButtonPressedWithDelayCheck(6, 1) then
        fCurrentFunc = F_RunNIS
    end
end

function F_RunNIS()
    TextPrintString("NIS: " .. gNIS, 3, 1)
    --DebugPrint("F_RunNIS - NIS: " .. gNIS)
    NISTable[gNIS]()
    fCurrentFunc = F_NISSelect
end

function F_IntroObjectiveMainMap()
    F_NIS_Parking1()
    TextPrint("1_04_BOT", 3, 1)
    Obj02 = MissionObjectiveAdd("1_04_BOT")
    TutorialStart("Shooting")
    gTutorialTimer = GetTimer()
    fCurrentFunc = F_StageTwoShootTheBottles
end

local px, py, pz, gx, gy, gz, pgx, pgy, pgz

function F_NIS_Parking1()
    --DebugPrint("F_NIS_Parking1 start")
    SoundSetAudioFocusPlayer()
    TextClear()
    AreaClearAllPeds()
    if b_DebuggingNIS then
        AreaTransitionXYZ(0, 177.77, 4.513, 5.475)
        PedSetPosXYZ(idNemesis, 178.47, 2.513, 5.475)
        TextPrintString("Lua NIS - initial camera pos depends on player pos", 4, 1)
    end
    F_MakePlayerSafeForNIS(true, true)
    PedStop(gPlayer)
    PedStop(idNemesis)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    SoundPlayInteractiveStream("MS_FunLow.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetMidIntensityStream("MS_FunMid.rsm", MUSIC_DEFAULT_VOLUME)
    SoundSetHighIntensityStream("MS_FunHigh.rsm", MUSIC_DEFAULT_VOLUME)
    CameraSetXYZ(181.48259, 6.016747, 9.577523, 180.8901, 6.738142, 9.219236)
    SoundPlayScriptedSpeechEvent(idNemesis, "M_1_04", 48, "genric", false, false)
    PlayerSetPosPoint(POINTLIST._1_04_NEMESISPARKING)
    Wait(250)
    local px, py, pz = PedGetOffsetInWorldCoords(gPlayer, 1, -2, 0)
    PedSetPosXYZ(idNemesis, px, py, pz)
    PedFaceHeading(idNemesis, 90, 0)
    PedSetStationary(idNemesis, true)
    while SoundSpeechPlaying(idNemesis) do
        Wait(0)
    end
    PlayerSetControl(1)
    F_MakePlayerSafeForNIS(false, true)
    CameraSetWidescreen(false)
    SoundPlayScriptedSpeechEvent(idNemesis, "M_1_04", 6, "genric", false, false)
    CameraReset()
    CameraReturnToPlayer()
    Wait(1)
    F_BusWindowsDestroyable()
    --DebugPrint("F_NIS_Parking1 end")
end

function F_StageOneGetToBus()
    if PlayerIsInTrigger(TRIGGER._1_04_SUPPRESSPARKINGPOP) and not bSetWindows then
        if gWindowsTimer == 0 then
            gWindowsTimer = GetTimer() + 1000
            bSetWindows = true
        end
    elseif PlayerIsInTrigger(TRIGGER._1_04_SUPPRESSPARKINGPOP) and bSetWindows and gWindowsTimer <= GetTimer() and not bMakeEmHard then
        gBusWindow = ObjectGetModelIndex("BusWindow")
        ObjectToggleVulnerability(gBusWindow, true)
        bMakeEmHard = true
    end
    if PlayerIsInTrigger(TRIGGER._1_04_PARKING) then
        --DebugPrint("F_StageOneGetToBus() - going to F_IntroObjectiveMainMap")
        BlipRemove(ParkingBlip)
        ParkingBlip = nil
        b_blipped = false
        fCurrentFunc = F_IntroObjectiveMainMap
        MissionObjectiveComplete(Obj01)
    end
end

function F_StageTwoShootTheBottles()
    if PlayerIsInTrigger(TRIGGER._1_04_BOTTLESHOOTAREA) then
        if b_blipped then
            BlipRemove(ParkingBlip)
            ParkingBlip = nil
            b_blipped = false
        end
    else
        if not b_blipped then
            ParkingBlip = BlipAddPoint(POINTLIST._1_04_NEMESISPARKING, 0, 1, 1, 0)
            b_blipped = true
        end
        if not bGaryHasDied and not bHasFailedElsewhere then
            TextPrint("1_04_LOT", 0.1, 1)
        end
    end
    if not bGaryHasDied and bHitTheWindows then
        bottles_all_broken = true
        fCurrentFunc = F_StageThreeGetToField
        MissionObjectiveComplete(Obj02)
        PedSetStationary(idNemesis, false)
    end
    if bFailForWrongWeapon then
        Wait(1500)
        SoundPlayMissionEndMusic(false, 4)
        MissionFail(false, true, "1_04_WRONG_GUN")
    end
end

local gBusWindow = 0

function F_BusWindowHash()
    tblBusWindowsSG = {
        {
            hash = 0,
            object = "tschool_BusWindow",
            destroyed = false,
            weapon = 0
        },
        {
            hash = 0,
            object = "tschool_BusWindow01",
            destroyed = false,
            weapon = 0
        },
        {
            hash = 0,
            object = "tschool_BusWindow02",
            destroyed = false,
            weapon = 0
        },
        {
            hash = 0,
            object = "tschool_BusWindow03",
            destroyed = false,
            weapon = 0
        },
        {
            hash = 0,
            object = "tschool_BusWindow04",
            destroyed = false,
            weapon = 0
        }
    }
    for i, entry in tblBusWindowsSG do
        entry.hash = ObjectNameToHashID(entry.object)
        RegisterHashEventHandler(entry.hash, 3, OnObjectBrokenCallback)
    end
end

function F_BusWindowsDestroyable()
    gBusWindow = ObjectGetModelIndex("BusWindow")
    ObjectToggleVulnerability(gBusWindow, false)
end

function F_UsedWrongWeapon()
    local wrongWeaponUsed = 0
    local rightWeaponUsed = 0
    local totalDestroyed = 0
    for i, entry in tblBusWindowsSG do
        if entry.destroyed == true then
            if 0 >= entry.weapon then
                wrongWeaponUsed = wrongWeaponUsed + 1
            elseif entry.weapon == 1 then
                rightWeaponUsed = rightWeaponUsed + 1
            end
            totalDestroyed = totalDestroyed + 1
            local X1, Y1 = PlayerGetPosXYZ()
            local X2, Y2 = 175.593, 12.4561
            if not bHitTheWindows then
                if not SoundSpeechPlaying(idNemesis) and DistanceBetweenCoords2d(X1, Y1, X2, Y2) >= 7 then
                    SoundPlayScriptedSpeechEvent(idNemesis, "M_1_04", 10, "genric", false, false)
                elseif not SoundSpeechPlaying(idNemesis) and DistanceBetweenCoords2d(X1, Y1, X2, Y2) <= 6.9 then
                    SoundPlayScriptedSpeechEvent(idNemesis, "M_1_04", 8, "genric", false, false)
                end
            end
        end
    end
    if 3 <= totalDestroyed then
        bHitTheWindows = true
    end
    if totalDestroyed == 5 and 3 <= wrongWeaponUsed then
        bHitTheWindows = true
    end
end

function F_WindowsHit()
    if bHitTheWindows then
        return 1
    else
        return 0
    end
end

function OnObjectBrokenCallback(HashID, ModelPoolIndex)
    local broken = 0
    for i, entry in tblBusWindowsSG do
        if entry.hash == HashID then
            broken = entry
            break
        end
    end
    if broken == 0 then
        return
    end
    pedDestroyer = PAnimDestroyedByPed(ModelPoolIndex, 0)
    local numHitsBySlingshot = ObjectNumProjectileImpacts(TRIGGER._1_04_BOTTLEZONE, 304)
    if pedDestroyer == gPlayer and not broken.destroyed then
        broken.destroyed = true
        if numHitsBySlingshot > lastTotalBroken then
            broken.weapon = 1
            numBottlesBroken = numBottlesBroken + 1
        else
            broken.weapon = -1
        end
        lastTotalBroken = numBottlesBroken
    end
    F_UsedWrongWeapon()
end

function T_BottleTrigger()
    --DebugPrint("T_BottleTrigger start")
    while not (not MissionActive() or bottles_all_broken or bHasFailedElsewhere) do
        if PlayerIsInTrigger(TRIGGER._1_04_BOTTLEZONE) then
        elseif playerEnteredBottleZoneTime ~= -1 then
            playerEnteredBottleZoneTime = -1
        end
        Wait(0)
    end
    --DebugPrint("T_BottleTrigger end")
end

function F_StageThreeGetToField()
    RadarRestoreMinMax()
    while SoundSpeechPlaying(idNemesis) do
        Wait(0)
    end
    SoundPlayScriptedSpeechEvent(idNemesis, "M_1_04", 47, "genric", false, true)
    if ParkingBlip ~= nil then
        BlipRemove(ParkingBlip)
    end
    PedMoveToPoint(idNemesis, 2, POINTLIST._1_04_PLAYERFIELDPT)
    FieldPt = BlipAddPoint(POINTLIST._1_04_FIELD, 0, 1, 1, 0)
    TextPrint("1_04_OBJ02", 3, 1)
    Obj04 = MissionObjectiveAdd("1_04_OBJ02")
    DisablePOI()
    while not (PlayerIsInTrigger(TRIGGER._1_04_FIELDTRIG) or bHasFailedElsewhere) do
        Wait(0)
    end
    if bHasFailedElsewhere then
        return
    end
    local Px, Py, Pz = PedGetPosXYZ(gPlayer)
    if PedIsValid(idNemesis) and not PedIsDead(idNemesis) then
        local Gx, Gy, Gz = PedGetPosXYZ(idNemesis)
        if DistanceBetweenCoords2d(Px, Py, Gx, Gy) >= 15 and not PedCanSeeObject(gPlayer, idNemesis, 2) then
            PedSetPosPoint(idNemesis, POINTLIST._1_04_FIELDSPAWN, 1)
        end
    end
    BlipRemove(FieldPt)
    FieldPt = nil
    MissionObjectiveComplete(Obj04)
    PedStop(idNemesis)
    F_GetInTheTree()
    F_LaunchFieldBullies()
    RegisterGlobalEventHandler(7, F_CheckHit)
    BurtonLastShoutedTime = GetTimer() + 10000
    fCurrentFunc = F_TreeAssault
end

function F_GetInTheTree()
    PedFaceHeading(idNemesis, 167.8, 1)
    Wait(250)
    SoundPlayScriptedSpeechEvent(idNemesis, "M_1_04", 51, "genric", false, false)
    PedSetActionNode(idNemesis, "/Global/1_04/GaryPoint/GaryPointAnim", "Act/Conv/1_04.act")
    TextPrint("1_04_TREE", 5, 1)
    while SoundSpeechPlaying(idNemesis) do
        Wait(0)
    end
    TutorialStart("Remember")
    Obj05 = MissionObjectiveAdd("1_04_TREE")
    if not bStageThreeRun then
        PedSetPedToTypeAttitude(idNemesis, 13, 3)
        PedFollowPath(idNemesis, PATH._1_04_NEMPATHTOBLEACHERS, 0, 0)
        CreateThread("T_NemBleach")
        bStageThreeRun = true
        F_ToggleTreeBlips(true)
        CreateThread("T_Treed")
        RadarSetMinMax(40, 50, 50)
    end
    while SoundSpeechPlaying(idNemesis) do
        Wait(0)
    end
    SoundPlayScriptedSpeechEvent(idNemesis, "M_1_04", 32, "genric", false, false)
    while SoundSpeechPlaying(idNemesis) do
        Wait(0)
    end
end

function F_LaunchFieldBullies()
    while not b_InTree do
        if tut31_time == -1 then
            tut31_time = GetTimer()
            TextPrint("1_04_CLIMBTREE", 7, 1)
        end
        if not bFieldNISDone and PlayerIsInTrigger(TRIGGER._1_04_TREE2_TRIG) and PedIsPlaying(gPlayer, "/Global/TreeClimb/Actions/ON_BOT", false) and not bFieldNISDone then
            bFieldNISDone = true
            SoundSetAudioFocusPlayer()
            F_CreateBulliesAndBurton()
            break
        end
        Wait(0)
    end
end

function F_CreateBulliesAndBurton()
    for i, entry in tblGoonDex do
        entry.id = PedCreatePoint(entry.model, POINTLIST._1_04_FIELDSPAWN, entry.element)
        PedSetInfiniteSprint(entry.id, true)
        PedMoveToPoint(entry.id, 1, POINTLIST._1_04_GOONFIELDNEW, entry.element, entry.callback)
        PedSetHealth(entry.id, 22)
        PedSetMaxHealth(entry.id, 22)
        PedClearAllWeapons(entry.id)
        PedSetFlag(entry.id, 58, true)
        entry.blip = AddBlipForChar(entry.id, 11, 26, 4)
    end
    Wait(1000)
    idBurton = PedCreatePoint(55, POINTLIST._1_04_FIELDSPAWN, 7)
    PedSetStealthBehavior(idBurton, 0, cbSpotted)
    PedOverrideStat(idBurton, 3, 20)
    tblGoonText = {
        {
            { ped = idBurton, speechid = 34 },
            { ped = idGoon1,  speechid = 35 },
            { ped = idBurton, speechid = 38 }
        },
        {
            { ped = idBurton, speechid = 34 },
            { ped = idBurton, speechid = 38 }
        }
    }
    PedMoveToPoint(idBurton, 1, POINTLIST._1_04_BURTONFIELD, 1, cbBurtonRun, 0.5)
end

function F_TreeAssault()
    bNextPhase = 0
    if bHasFailedElsewhere then
        return
    end
    if F_SittingInTree() and WeaponEquipped(303) then
        if not gHighMusicPlaying then
            SoundPlayInteractiveStreamLocked("MS_FunHigh.rsm", MUSIC_DEFAULT_VOLUME)
            gHighMusicPlaying = true
        end
    elseif gHighMusicPlaying then
        SoundPlayInteractiveStream("MS_FunLow.rsm", MUSIC_DEFAULT_VOLUME)
        SoundSetMidIntensityStream("MS_FunMid.rsm", MUSIC_DEFAULT_VOLUME)
        SoundSetHighIntensityStream("MS_FunHigh.rsm", MUSIC_DEFAULT_VOLUME)
        gHighMusicPlaying = false
    end
    if IsButtonPressed(0, 1) then
        --print("===== Burton Debug ====", tostring(bBurtonShouldShout), BurtonLastShoutedTime, GetTimer())
    end
    F_BranchMessage()
    F_HitReactSpeech()
    if GetTimer() >= BurtonLastShoutedTime or bBurtonSeesHit then
        for i, guy in tblGoonDex do
            if PedIsValid(guy.id) and not PedIsDead(guy.id) then
                PedFaceObjectNow(idBurton, guy.id, 2)
                break
            end
        end
        if not bPlayerSpotted then
            if bBurtonSeesHit and not SoundSpeechPlaying(idBurton) then
                SoundPlayScriptedSpeechEvent(idBurton, "M_1_04", 34, "genric", false, false)
                bBurtonSeesHit = false
            elseif not SoundSpeechPlaying(idBurton) then
                SoundPlayScriptedSpeechEvent(idBurton, "M_1_04", 38, "genric", false, false)
            end
        end
        bBurtonShouldShout = false
        BurtonLastShoutedTime = GetTimer() + 10000
    end
    if bPlayerSpotted then
        F_PlayerSpotted(spottingPed)
        bPlayerSpotted = false
        return
    end
    F_CheckBullyDeaths()
    F_SwitchToJacks()
    F_CheckBullyAttacked()
end

function F_HitReactSpeech()
    if bSomeoneGotHit and GetTimer() >= gSomeoneGotHitTimer then
        local pedID = gHitPed
        SoundPlayAmbientSpeechEvent(pedID, "FIGHT_WTF")
        bSomeoneGotHit = false
    end
end

function F_CheckHit(pedID)
    for i, guy in tblGoonDex do
        if pedID == guy.id and guy.hit == false and PedIsValid(guy.id) and (PedGetLastHitWeapon(guy.id) == 304 or PedGetWhoHitMeLast(guy.id) == gPlayer) and b_InTree and guy.hit == false then
            --print("=== Hit a bully from the tree ====")
            guy.workout = false
            if PedGetHealth(pedID) <= 0 or PedIsDead(pedID) then
                guy.hit = true
            end
            if not PedIsDead(pedID) then
                gHitPed = pedID
                gSomeoneGotHitTimer = GetTimer() + 500
                bSomeoneGotHit = true
            end
            bBurtonSeesHit = true
            --print("===== Burton Debug ====", tostring(bBurtonShouldShout), BurtonLastShoutedTime, GetTimer())
            break
        end
    end
end

function F_CheckBullyAttacked()
    if not bRunning then
        F_MakeThenRun()
        CreateThread("T_JumpingJacks")
        bRunning = true
    end
    for b, bully in tblGoonDex do
        if not bully.dead and (PedGetHealth(bully.id) <= 0 or PedIsDead(bully.id)) then
            bully.dead = true
            BlipRemoveFromChar(bully.id)
            totalhit = totalhit + 1
            bBurtonSeesHit = true
            --print("===== totalhit ====", totalhit)
        end
    end
    if 6 <= totalhit then
        gAllDead = 1
        bHitFromTree = true
        F_BurtonPissed()
        if not bHasFailedElsewhere then
            bSpotting = false
            bWarnDontKOBullies = false
            while SoundSpeechPlaying(idBurton) do
                Wait(0)
            end
            CameraSetWidescreen(true)
            F_MakeFieldPedsAmb()
            CameraReset()
            CameraReturnToPlayer()
            Wait(500)
            SetFactionRespect(1, 55)
            MinigameSetCompletion("M_PASS", true, 0)
            SoundPlayMissionEndMusic(true, 4)
            Wait(500)
            MinigameAddCompletionMsg("MRESPECT_NP5", 2)
            while MinigameIsShowingCompletion() do
                Wait(0)
            end
            bMissionComplete = true
            MissionSucceed(false, false, false)
        end
    end
end

function F_AllDead()
    return gAllDead
end

function F_GetBackToWork()
    for i, guy in tblGoonDex do
        if not F_PedIsDead(guy.id) then
            if PedGetWhoHitMeLast(guy.id) == gPlayer and guy.workout then
                guy.workout = false
            else
                guy.workout = true
            end
        end
    end
    for j, guy in tblGoonDex do
        if not guy.workout then
            if not bPlayingBurtonYell then
                SoundPlayScriptedSpeechEvent(idBurton, "M_1_04", 34, "genric", false, false)
                Wait(1500)
                F_MakeHimRun(guy)
                guy.workout = true
                bPlayingBurtonYell = true
                bBurtonWorkoutTimer = GetTimer() + 15000
            elseif TimerPassed(bBurtonWorkoutTimer) then
                bPlayingBurtonYell = false
            end
        end
    end
end

function F_MakeThenRun()
    PedMoveToPoint(idBurton, 2, POINTLIST._1_04_BURTONFIELD, 2, cbBurtonNextPatrol)
    Wait(1000)
    for i, guy in tblGoonDex do
        if PedIsValid(guy.id) and not F_PedIsDead(guy.id) then
            F_ClearHisMind(guy.id)
            PedFollowPath(guy.id, guy.path, 2, 1, guy.cbJack)
            guy.state = STATE_RUNN
        end
    end
end

function F_SwitchToJacks()
    for i, guy in tblGoonDex do
        if guy.time == -1 and guy.state == STATE_RUNN and PedIsValid(guy.id) and not F_PedIsDead(guy.id) then
            F_ClearHisMind(guy.id)
            PedSetActionNode(guy.id, "/Global/Ambient/Scripted/Workout", "Act/Anim/Ambient.act")
            guy.state = STATE_JACK
            guy.time = GetTimer() + 3000
        end
    end
end

function T_JumpingJacks()
    while not (not MissionActive() or bPlayerSpotted or gTreeFailure or bHasFailedElsewhere) do
        for i, guy in tblGoonDex do
            if PedIsValid(guy.id) and not F_PedIsDead(guy.id) and TimerPassed(guy.time) and guy.state == STATE_JACK then
                F_ClearHisMind(guy.id)
                while PedIsPlaying(guy.id, "/Global/Ambient/Scripted/Workout/Workout_Child/BeginWorkout/EndWorkout", true) do
                    if bPlayerSpotted or gTreeFailure then
                        break
                    end
                    Wait(0)
                end
                PedFollowPath(guy.id, guy.path, 2, 1, guy.cbJack)
                guy.state = STATE_RUNN
                break
            end
        end
        Wait(0)
    end
end

function cbJacks(pedID, pathID, nodeID)
    if nodeID == 1 then
        for i, guy in tblGoonDex do
            if PedIsValid(guy.id) and guy.id == pedID and guy.path == pathID and guy.state == STATE_RUNN then
                guy.state = STATE_JACK
                guy.time = -1
            end
        end
    end
end

function F_MakeHimRun(tbl)
    if tbl.state == STATE_JACK and TimerPassed(tbl.time) and PedIsValid(guy.id) and not F_PedIsDead(tbl.id) then
        F_ClearHisMind(tbl.id)
        PedFollowPath(tbl.id, tbl.path, 2, 1, tbl.cbJack)
        tbl.state = STATE_RUNN
    end
end

function cbBurtonNextPatrol()
    PedSetStationary(idBurton, true)
    for i, guy in tblGoonDex do
        if PedIsValid(guy.id) and not PedIsDead(guy.id) then
            PedFaceObjectNow(idBurton, guy.id, 2)
            break
        end
    end
end

local b_TreeBlips

function F_ToggleTreeBlips(blipsOn)
    b_TreeBlips = blipsOn
    if blipsOn then
        Tree1Blip = BlipAddPoint(POINTLIST._1_04_TREE1, 0, 1, 1, 7)
    else
        BlipRemove(Tree1Blip)
        Tree1Blip = nil
    end
end

function F_SetupPedForAfterMissionFail(pedid)
    --DebugPrint("F_SetupPedForAfterMissionFail(pedid): " .. pedid)
    if F_PedIsDead(pedid) then
        return
    end
    --DebugPrint("F_SetupPedForAfterMissionFail(pedid) not dead")
    PedStop(pedid)
    Wait(1)
    F_SafePedMakeAmbient(pedid)
    Wait(1)
    if pedid ~= idBurton then
        PedClearObjectives(pedid)
        Wait(1)
        PedAttack(pedid, gPlayer, 3)
    end
    Wait(1)
    --DebugPrint("F_SetupPedForAfterMissionFail(pedid) end")
end

function F_ClearHisMind(ped)
    PedStop(ped)
    PedClearObjectives(ped)
end

local t = 0

function F_BurtonPissed()
    PedStop(idBurton)
    if bSpotted then
        return
    end
    SoundPlayScriptedSpeechEvent(tblGoonText[nCurrentGoonRoute][1].ped, "M_1_04", tblGoonText[nCurrentGoonRoute][1].speechid)
    if bSpotted then
        return
    end
    PedStop(idBurton)
    if bSpotted then
        return
    end
    bNextPhase = 0
end

function F_NemesisDistance(nDistance)
    local nemx, nemy = PedGetPosXYZ(idNemesis)
    local playx, playy = PedGetPosXYZ(gPlayer)
    if nDistance >= DistanceBetweenCoords2d(nemx, nemy, playx, playy) then
        return true
    else
        return false
    end
end

function F_CBGoonBehaviour(pedID)
    if pedID == idBurton and WeaponEquipped(303) and not bBurtonSpotted then
        bBurtonSpotted = true
    end
    if pedID == idBurton and bPlayerFistAttack then
        bBurtonSawAssault = true
    end
    if bGoonWasHit and WeaponEquipped(303) then
        bSpotted = true
    end
end

function cbBurtonRun()
    PedStop(idBurton)
    PedFaceHeading(idBurton, 146, 1)
    bCreateSpotTread = true
end

function cbRun01()
    PedFaceHeading(tblGoonDex[1].id, 180, 1)
    PedSetActionNode(tblGoonDex[1].id, "/Global/Ambient/Scripted/Workout", "Act/Anim/Ambient.act")
    tblGoonDex[1].state = STATE_EXER
end

function cbRun02()
    PedFaceHeading(tblGoonDex[2].id, 180, 1)
    PedSetActionNode(tblGoonDex[2].id, "/Global/Ambient/Scripted/Workout", "Act/Anim/Ambient.act")
    tblGoonDex[2].state = STATE_EXER
end

function cbRun03()
    PedFaceHeading(tblGoonDex[3].id, 180, 1)
    PedSetActionNode(tblGoonDex[3].id, "/Global/Ambient/Scripted/Workout", "Act/Anim/Ambient.act")
    tblGoonDex[3].state = STATE_EXER
end

function cbRun04()
    PedFaceHeading(tblGoonDex[4].id, 180, 1)
    PedSetActionNode(tblGoonDex[4].id, "/Global/Ambient/Scripted/Workout", "Act/Anim/Ambient.act")
    tblGoonDex[4].state = STATE_EXER
end

function cbRun05()
    PedFaceHeading(tblGoonDex[5].id, 180, 1)
    PedSetActionNode(tblGoonDex[5].id, "/Global/Ambient/Scripted/Workout", "Act/Anim/Ambient.act")
    tblGoonDex[5].state = STATE_EXER
end

function cbRun06()
    PedFaceHeading(tblGoonDex[6].id, 180, 1)
    PedSetActionNode(tblGoonDex[6].id, "/Global/Ambient/Scripted/Workout", "Act/Anim/Ambient.act")
    tblGoonDex[6].state = STATE_EXER
end

function F_BranchMessage()
    if not bFirstHitBullyObjective and PlayerIsInTrigger(TRIGGER._1_04_TREE1_TRIG) and F_SittingInTree() then
        --print("===== Hit the bullies objective =====")
        MissionObjectiveComplete(Obj05)
        TextPrint("1_04_FIELDOBJ", 5, 1)
        Obj06 = MissionObjectiveAdd("1_04_FIELDOBJ")
        bFirstHitBullyObjective = true
    end
end

function F_SittingInTree()
    if PedMePlaying(gPlayer, "HoistUp_Spawns", true) then
        return true
    else
        return false
    end
end

function T_Treed()
    while not (not MissionActive() or bHitFromTree or bHasFailedElsewhere) do
        Wait(30)
        if not bHitFromTree then
            if b_InTree and b_TreeBlips then
                F_ToggleTreeBlips(false)
            else
                if not b_InTree and not b_TreeBlips and not bGoonsBarfed then
                    F_ToggleTreeBlips(true)
                else
                end
            end
        end
        if bFieldNISDone then
            if not gTimerGetBackInTree and not PedIsPlaying(gPlayer, "/Global/TreeClimb/Actions/ON_BOT", false) then
                gTimerGetBackInTree = true
                TextPrint("1_04_TREE_WARN", 4, 1)
                MissionTimerStart(gTreeTime)
            end
            if gTimerGetBackInTree then
                if PlayerIsInTrigger(TRIGGER._1_04_TREE2_TRIG) and PedIsPlaying(gPlayer, "/Global/TreeClimb/Actions/ON_BOT", false) and not MissionTimerHasFinished() then
                    --print("=== Back In Tree ====")
                    MissionTimerStop()
                    gTimerGetBackInTree = false
                end
                if MissionTimerHasFinished() then
                    gTreeFailure = true
                    MissionTimerStop()
                    break
                end
            end
        end
    end
end

function F_TreeTrigEnter(TriggerID, PedID)
    if PedID == gPlayer and TriggerID == TRIGGER._1_04_TREE1_TRIG then
        b_InTree = true
        if bFieldNISDone and gTimerGetBackInTree then
            MissionTimerStop()
            gTimerGetBackInTree = false
        end
    end
end

function F_TreeTrigExit(TriggerID, PedID)
    if PedID == gPlayer and TriggerID == TRIGGER._1_04_TREE1_TRIG then
        b_InTree = false
        if not bHitFromTree and bFieldNISDone then
            gTimerGetBackInTree = true
            TextPrint("1_04_TREE_WARN", 4, 1)
            MissionTimerStart(gTreeTime)
        end
    end
end

function T_NemBleach()
    --DebugPrint("=+=+=+=+=+= T_NemBleach() start")
    while not (not (MissionActive() and PedIsValid(idNemesis)) or PedIsInTrigger(idNemesis, TRIGGER._1_04_NEMSITDOWN) or bHasFailedElsewhere) do
        Wait(100)
    end
    PedSetPOI(idNemesis, POI._1_04_NEMSITSPOT, false)
    --DebugPrint("=+=+=+=+=+= T_NemBleach() end")
end

function F_OnGaryDeath()
    --DebugPrint("F_OnGaryDeath start")
    bGaryHasDied = F_PedIsDead(idNemesis)
end

function T_WatchForGaryDeath()
    while not (not MissionActive() or bHasFailedElsewhere) do
        Wait(33)
        if bGaryHasDied then
            bHasFailedElsewhere = true
            break
        end
    end
end

local mybullyDeathCount = 0

function F_CheckBullyDeaths()
    mybullyDeathCount = 0
    if F_PedIsDead(idBurton) then
        --print("===== Burton Is Dead ====")
        b_DeadBeforeTheirTime = true
        bHasFailedElsewhere = true
    end
    bullyDeathCount = mybullyDeathCount
end

function F_SafePedMakeAmbient(pedID)
    if PedIsValid(pedID) then
        if not F_PedIsDead(pedID) then
            BlipRemoveFromChar(pedID)
            F_ClearHisMind(pedID)
            PedSetActionNode(pedID, "/Global/1_04/1_04_ClearActions", "Act/Conv/1_04.act")
            PedSetIsStealthMissionPed(pedID, false)
            PedResetAttitudes(pedID)
            PedMoveToPoint(pedID, 1, POINTLIST._1_04_PLAYERFIELDPT, 1)
        end
        PedMakeAmbient(pedID)
    end
end

function F_MakeFieldPedsAmb()
    if PedIsValid(idNemesis) then
        PedHideHealthBar()
        if not PedIsDead(idNemesis) then
            PedStop(idNemesis)
            PedMakeAmbient(idNemesis)
            PedWander(idNemesis, 0)
        end
    end
    if PedIsValid(idBurton) and not PedIsDead(idBurton) then
        PedLockTarget(idBurton, -1)
        PedSetStationary(idBurton, false)
        F_SafePedMakeAmbient(idBurton)
    end
    for k, ent in tblGoonDex do
        if PedIsValid(ent.id) then
            Wait(1)
            PedSetFlag(ent.id, 58, false)
            F_SafePedMakeAmbient(ent.id)
        end
    end
end

function TimerPassed(time)
    if time <= GetTimer() then
        return true
    else
        return false
    end
end

function TimerCheck(timer, atime)
    local min, max = 0, 0
    min = atime
    max = atime + __timerDelta
    if timer >= min and timer < max then
        return true
    end
    return false
end

function F_PlayerSpotted(buster)
    CameraSetWidescreen(true)
    bSpotFailure = true
    SoundDisableSpeech_ActionTree()
    PlayerSetControl(0)
    PedStop(buster)
    PedClearObjectives(buster)
    PedLockTarget(buster, gPlayer, 3)
    PedFaceObject(buster, gPlayer, 3, 1, false)
    PedFaceObject(gPlayer, buster, 2, 1)
    Wait(250)
    local spotX, spotY, spotZ = PedGetOffsetInWorldCoords(buster, 0, 1.5, 1.65)
    local bustX, bustY, bustZ = PedGetPosXYZ(buster)
    CameraSetXYZ(spotX, spotY, spotZ, bustX, bustY, bustZ + 1.65)
    PedSetIsStealthMissionPed(buster, false)
    PedSetFlag(gPlayer, 2, false)
    SoundSetAudioFocusCamera()
    while SoundSpeechPlaying(buster) do
        Wait(0)
    end
    SoundPlayScriptedSpeechEvent(buster, "M_1_04", 39, "generic", false, true)
    while SoundSpeechPlaying(buster) do
        Wait(0)
    end
    CameraReset()
    SoundEnableSpeech_ActionTree()
    Wait(1000)
end

function cbSpotted(pedID)
    spottingPed = pedID
    bPlayerSpotted = true
end

function F_IsHeSitting()
    return gSitting
end
