--[[ Changes to this file:
    * Modified function F_Wave4, may require testing
    * Modified function T_Delete_Wave3_2, may require testing
    * Modified function F_CreateWindowSnipers, may require testing
    * Modified function F_SetUpWave, may require testing
]]

local gThad, gCorn, gFatty, gBeatriceWave1, gThadWave1
local bWindowSpawners = false
local bSpawnersActive = false
local numFatty = 0
local numCorny = 0
local numThad = 0
local numMelvin = 0
local bFluxLinePlayed = false
local gBlipAlgie
local bMissionSuccess = false
local bWave3Dead = false
local bFattyTalks = false
local bCodeGiven = false
local bEarnestLockedTheDoor = false
local bBreakerAlive = true
local bSpudLinePlayed = false
local tblCoverProps = {}
local bCoverPropsSet = false
local bDoorDead = false
local nerd_spawner1, nerd_spawner2, nerd_spawner3, nerd_spawner4, nerd_spawner5, nerd_spawner6
local bThadCreate = false
local gCannonNerd
local bOnCannon = false
local gBlipObs, gBlipTransformer, gBlipCannon
local bCannonBlipped = false
local gBlipObs2
local mission_won = false
local mis_obj01 = 0
local mis_obj02 = 0
local mis_obj03 = 0
local mis_obj04 = 0
local mis_obj05 = 0
local mis_obj06 = 0
local mis_obj07 = 0
local mis_obj08 = 0
local bCreateThad = false
local bShortCut = false
local social_time = 0
local gBlipNerds01
local bDoorLineDone = false
local bNerdsHit = false
local bPlayerGreets = false
local gMelvin, gFattyBlip, gFattyBlip, gBlipThad
local bPlayerGreetsFatty = false
local bSecDoorIsThere = false
local gWindowsStage = 1
local gThadSaysNoWay = false
local bPlayerIsAsking = false
local bPlayerIsTaunting = false
local bFattyBeingCanned = false
local bFattyInTheCan = false
local bPointOfNoReturn = false
local bEndCut = false
local bOnSpudCannon = false
local bOnCannon = false
local bPlayerOffCannon = false
local bWave04Engaged = false
local bWave04Launched = false
local bWave03Engaged = false
local bWave03Launched = false
local bWave02Engaged = false
local bWave02Launched = false
local bEnterGauntlet = false
local bWave01Engaged = false
local bGotTheCode = false
local bGotInfo = false
local bThadCreated = false
local bHitCorn = false
local bHitFatty = false
local bHitMelvin = false
local bFattyGrappled = false
local bPlayerAttackDoors = false
local bSuperThad = false
local bMisobjDoor = false
local gSpawned01 = -1
local gSpawned02 = -1
local gSpawned03 = -1
local gSpawned04 = -1
local gSpawned05 = -1
local gSpawned06 = -1
local bSetMove01 = false
local bSetMove02 = false
local bSetMove03 = false
local bSetMove04 = false
local bSetMove05 = false
local bSetMove06 = false
local bHasMoved01 = false
local bHasMoved02 = false
local bHasMoved03 = false
local bHasMoved04 = false
local bHasMoved05 = false
local bHasMoved06 = false

function MissionSetup()
    MissionDontFadeIn()
    PlayCutsceneWithLoad("4-02", true, true, true)
    DATLoad("4_02.DAT", 2)
    DATInit()
    AreaTransitionPoint(0, POINTLIST._4_02_PLAYERSTART, nil, true)
end

function F_MissionSetup()
    DisablePOI()
    LoadAnimationGroup("F_NERDS")
    LoadAnimationGroup("IDLE_NERD_C")
    LoadActionTree("Act/Conv/4_02.act")
    LoadPedModels({
        9,
        5,
        6,
        8,
        7,
        11,
        4,
        10
    })
    LoadWeaponModels({
        303,
        307,
        301,
        309
    })
    numFatty = PedGetUniqueModelStatus(5)
    PedSetUniqueModelStatus(5, -1)
    numCorny = PedGetUniqueModelStatus(9)
    PedSetUniqueModelStatus(9, -1)
    numThad = PedGetUniqueModelStatus(7)
    PedSetUniqueModelStatus(7, -1)
    numMelvin = PedGetUniqueModelStatus(6)
    PedSetUniqueModelStatus(6, -1)
end

function main()
    MissionDontFadeIn()
    F_MissionSetup()
    DisablePOI()
    F_PropSet()
    PlayerSetControl(1)
    CameraReturnToPlayer()
    CreateThread("T_PlayerAsks")
    CreateThread("T_FattyScared")
    CameraFade(1000, 1)
    F_GetInfo()
    F_GetKeyCode()
    F_Wave01()
    F_Wave02()
    F_Wave03()
    F_Wave04()
    F_GetOnSpudCannon()
    F_DestroyDoors()
    F_GetInObservatory()
    if bMissionSuccess then
        PlayerSetControl(0)
        CameraLookAtObject(gPlayer, 3, true, 1)
        CameraSetWidescreen(true)
        F_MakePlayerSafeForNIS(true)
        SoundDisableSpeech_ActionTree()
        PedMoveToPoint(gPlayer, 1, POINTLIST._4_02_OBSERVATORY)
        CameraFade(500, 1)
        AreaClearAllPeds()
        Wait(501)
        MinigameSetCompletion("M_PASS", true, 0)
        MinigameAddCompletionMsg("MRESPECT_JP5", 2)
        MinigameAddCompletionMsg("MRESPECT_NM100", 1)
        SoundPlayMissionEndMusic(true, 10)
        while MinigameIsShowingCompletion() do
            Wait(0)
        end
        mission_won = true
        SetFactionRespect(1, 0)
        SetFactionRespect(2, 50)
        F_MakePlayerSafeForNIS(false)
        PlayerSetControl(1)
        MissionSucceed(true, false, false)
    else
        SoundPlayMissionEndMusic(false, 10)
        MissionFail()
    end
end

function F_PropSet()
    tblCoverProps = {
        {
            trigger = TRIGGER._4_02_BAR_01,
            id = 0
        },
        {
            trigger = TRIGGER._4_02_BAR_02,
            id = 0
        },
        {
            trigger = TRIGGER._4_02_BAR_03,
            id = 0
        }
    }
    for i, prop in tblCoverProps do
        while not PAnimRequest(prop.trigger) do
            Wait(0)
        end
    end
    for i, prop in tblCoverProps do
        prop.id = PAnimCreate(prop.trigger)
    end
end

function F_GetInObservatory()
    while MissionActive() do
        bMissionSuccess = true
        PlayerSetControl(0)
        CameraFade(1000, 0)
        Wait(1000)
        PedSetActionNode(gPlayer, "/Global/WPCANNON/Disengage", "Act/Props/WPCANNON.act")
        Wait(250)
        PlayerSetPosPoint(POINTLIST._4_02_PLAYERENDCUT)
        F_DeleteWindowsNerds()
        Wait(250)
        Wait(0)
        CameraSetXYZ(43.559174, -140.24785, 3.387123, 43.75394, -139.2694, 3.454439)
        break
    end
end

function F_DestroyDoors()
    while not (not MissionActive() or bDoorDead) do
        if not bPlayerOffCannon and not F_PlayerOnSpudCannon() then
            --print("=== Off the Cannon ===")
            gBlipCannon = BlipAddPoint(POINTLIST._4_02_SPUD_NERD01, 0)
            bPlayerOffCannon = true
            PAnimSetInvulnerable(TRIGGER._DT_OBSERVATORY, true)
            PAnimMakeTargetable(TRIGGER._DT_OBSERVATORY, false)
        elseif bPlayerOffCannon and F_PlayerOnSpudCannon() then
            --print("=== On the Cannon ===")
            BlipRemove(gBlipCannon)
            bPlayerOffCannon = false
            PAnimSetInvulnerable(TRIGGER._DT_OBSERVATORY, false)
            PAnimMakeTargetable(TRIGGER._DT_OBSERVATORY, true)
        end
        if bSetMove01 then
            bSetMove01 = false
        end
        if bSetMove02 then
            bSetMove02 = false
        end
        if bSetMove03 then
            bSetMove03 = false
        end
        if bSetMove04 then
            bSetMove04 = false
        end
        if bSetMove05 then
            --print("===== gSpawned05 should be walking to attack point ====")
            PedMoveToPoint(gSpawned05, 0, POINTLIST._4_02_O_R1_2, 1, cbSpawner5, 0.2)
            bSetMove05 = false
        end
        if bSetMove06 then
            --print("===== gSpawned06 should be walking to attack point ====")
            PedMoveToPoint(gSpawned06, 0, POINTLIST._4_02_O_R2_2, 1, cbSpawner6, 0.2)
            bSetMove06 = false
        end
        if bHasMoved01 then
            PedStop(gSpawned01)
            PedSetStationary(gSpawned01, true)
            PedAttackPlayer(gSpawned01, 3)
            bHasMoved01 = false
        end
        if bHasMoved02 then
            PedStop(gSpawned02)
            PedSetStationary(gSpawned02, true)
            PedAttackPlayer(gSpawned02, 3)
            bHasMoved02 = false
        end
        Wait(0)
        if bHasMoved03 then
            PedStop(gSpawned03)
            PedSetStationary(gSpawned03, true)
            PedAttackPlayer(gSpawned03, 3)
            bHasMoved03 = false
        end
        if bHasMoved04 then
            PedStop(gSpawned04)
            PedSetStationary(gSpawned04, true)
            PedAttackPlayer(gSpawned04, 3)
            bHasMoved04 = false
        end
        if bHasMoved05 then
            PedStop(gSpawned05)
            PedSetStationary(gSpawned05, true)
            PedAttackPlayer(gSpawned05, 3)
            bHasMoved05 = false
        end
        if bHasMoved06 then
            PedStop(gSpawned06)
            PedSetStationary(gSpawned06, true)
            PedAttackPlayer(gSpawned06, 3)
            bHasMoved06 = false
        end
    end
    --print("=== Door Dead ===")
end

function F_RunEarnestNIS()
    F_MakePlayerSafeForNIS(true)
    CameraFade(500, 0)
    Wait(501)
    PedStop(gCannonNerd)
    PedSetPosPoint(gCannonNerd, POINTLIST._4_02_NIS_EARNEST, 1)
    PedSetActionNode(gCannonNerd, "/Global/4_02/NIS/Earnest_01", "Act/Conv/4_02.act")
    PedSetEffectedByGravity(gCannonNerd, true)
    CameraSetWidescreen(true)
    CameraSetFOV(80)
    CameraSetPath(PATH._4_02_NIS_CAM, true)
    CameraSetSpeed(0.5, 1, 0.5)
    CameraLookAtPath(PATH._4_02_NIS_CAM_LOOK, true)
    PlayerSetControl(0)
    CameraFade(500, 1)
    Wait(501)
    PedSetActionNode(gCannonNerd, "/Global/4_02/Blank", "Act/Conv/4_02.act")
    PedFollowPath(gCannonNerd, PATH._4_02_NIS_EARNESTRUN, 0, 2)
    SoundPlayScriptedSpeechEvent_2D("M_4_02_2D", 36)
    Wait(5500)
    CameraFade(500, 0)
    Wait(501)
    LoadActionTree("Act/Props/scObsDr.act")
    CameraDefaultFOV()
    CameraSetWidescreen(false)
    CameraReturnToPlayer(true)
    F_MakePlayerSafeForNIS(false)
    PedDelete(gCannonNerd)
    PlayerSetControl(1)
    CameraFade(500, 1)
    Wait(501)
    AreaSetDoorLocked(TRIGGER._SCGATE_OBSERVATORY, false)
    AreaSetDoorLockedToPeds(TRIGGER._SCGATE_OBSERVATORY, false)
    PAnimOpenDoor(TRIGGER._SCGATE_OBSERVATORY)
    MissionObjectiveComplete(mis_obj05)
    BlipRemove(gBlipTransformer)
    TextPrint("4_02_GCANNON", 4, 1)
    mis_obj06 = MissionObjectiveAdd("4_02_GCANNON")
    gBlipCannon = BlipAddPoint(POINTLIST._4_02_SPUD_NERD01, 0)
end

function F_GetOnSpudCannon()
    while not (not MissionActive() or bOnSpudCannon) do
        if not bOnCannon and F_PlayerOnCannon() then
            --print("=== On the Cannon ===")
            F_PlayerOnCannonAction()
            bOnCannon = true
            bOnSpudCannon = true
        end
        Wait(0)
    end
    --print("==== F_GetOnSpudCannon dead ===")
end

function F_Wave04()
    while not (not MissionActive() or bWave04Engaged) do
        if not bWave04Launched and F_ApproachWave04() then
            F_Wave4()
            bWave04Launched = true
            bWave04Engaged = true
        end
        Wait(0)
    end
end

function F_Wave03()
    while not (not MissionActive() or bWave03Engaged) do
        if not bWave03Launched and F_ApproachWave03() then
            F_Wave3()
            bWave03Launched = true
            bWave03Engaged = true
        end
        Wait(0)
    end
end

function F_Wave02()
    while not (not MissionActive() or bWave02Engaged) do
        if not bWave02Launched and F_ApproachWave02() then
            F_Wave2()
            bWave02Launched = true
            bWave02Engaged = true
        end
        Wait(0)
    end
end

function F_Wave01()
    while not (not MissionActive() or bWave01Engaged) do
        if not bEnterGauntlet and F_EnteringGauntlet() then
            F_EnteringGauntletAction()
            bEnterGauntlet = true
            bWave01Engaged = true
        end
        Wait(0)
    end
end

function F_GetKeyCode()
    SoundDisableSpeech_ActionTree()
    while not (not MissionActive() or bKeyCodeGiven) do
        if not bGotTheCode and F_ThadSubmitts() then
            F_ThadCode()
            bGotTheCode = true
            bKeyCodeGiven = true
        end
        Wait(0)
    end
end

function F_GetInfo()
    F_SetupLibraryNerds()
    F_CreateDoorAndPad()
    TextPrint("4_02_NERDS", 5, 1)
    mis_obj01 = MissionObjectiveAdd("4_02_NERDS")
    while not (not MissionActive() or bGotInfo) do
        if not bCreateThad and (PlayerIsInTrigger(TRIGGER._4_02_GATEKEEPER) or PedGetWhoHitMeLast(gThad) == gPlayer) then
            --print("=== Not Hit Fatty ====")
            BlipRemove(gBlipNerds01)
            BlipRemoveFromChar(gFatty)
            MissionObjectiveRemove(mis_obj01)
            PedSetPedToTypeAttitude(gThad, 13, 0)
            BlipRemoveFromChar(gThad)
            gBlipThad = AddBlipForChar(gThad, 1, 26, 4)
            if not gThadSaysNoWay then
                gThadSaysNoWay = true
                SoundPlayScriptedSpeechEvent(gThad, "M_4_02", 13, "genric", false, true)
                while SoundSpeechPlaying(gThad) do
                    Wait(0)
                end
                PedSetMinHealth(gThad, 0)
            end
            bPlayerGreets = false
            bNerdsHit = false
            bShortCut = true
            bCreateThad = true
            if mis_obj03 == 0 then
                mis_obj03 = MissionObjectiveAdd("4_02_KEYCODE")
                TextPrint("4_02_KEYCODE", 4, 1)
            end
            PedClearObjectives(gFatty)
            PedClearObjectives(gCorn)
            PedMakeAmbient(gFatty)
            PedMakeAmbient(gCorn)
            PedWander(gFatty, 0)
            PedWander(gCorn, 0)
            gFatty = 0
            bGotInfo = true
            break
        end
        if not gThadSaysNoWay and bCreateThad and (PlayerIsInTrigger(TRIGGER._4_02_GATEKEEPER) or PedGetWhoHitMeLast(gThad) == gPlayer) then
            --print("=== Hit Fatty ====")
            PedSetPedToTypeAttitude(gThad, 13, 0)
            BlipRemoveFromChar(gThad)
            gBlipThad = AddBlipForChar(gThad, 1, 26, 4)
            if not gThadSaysNoWay then
                gThadSaysNoWay = true
                SoundPlayScriptedSpeechEvent(gThad, "M_4_02", 13, "genric", false, true)
                while SoundSpeechPlaying(gThad) do
                    Wait(0)
                end
            end
            PedSetMinHealth(gThad, 0)
            if not bShortCut or mis_obj02 ~= 0 then
                MissionObjectiveComplete(mis_obj02)
            end
            if mis_obj03 == 0 then
                mis_obj03 = MissionObjectiveAdd("4_02_KEYCODE")
                TextPrint("4_02_KEYCODE", 4, 1)
            end
            gFatty = 0
            gThadSaysNoWay = true
            bGotInfo = true
            break
        end
        if not bThadCreated and F_CreateThad() then
            F_CreateThadAction()
            bThadCreated = true
        end
        if not bHitCorn and F_HittingCorn() then
            F_HitCorn()
            bHitCorn = true
        end
        if not bHitFatty and F_HittingFatty() then
            F_HitFatty()
            bHitFatty = true
        end
        Wait(0)
    end
end

function F_SetupLibraryNerds()
    social_time = 1
    gCorn = PedCreatePoint(9, POINTLIST._4_02_LIBCORNY)
    gFatty = PedCreatePoint(5, POINTLIST._4_02_LIBFATTY)
    gFattyBlip = AddBlipForChar(gFatty, 1, 0, 4)
    PedSetPedToTypeAttitude(gCorn, 13, 2)
    PedSetPedToTypeAttitude(gFatty, 13, 2)
    PedSocialOverrideLoad(7, "Mission/4_02_Taunt.act")
    PedSocialOverrideLoad(18, "Mission/4_02_Greeting.act")
    PedOverrideSocialResponseToStimulus(gFatty, 55, 7)
    PedOverrideSocialResponseToStimulus(gFatty, 10, 18)
    PedOverrideSocialResponseToStimulus(gFatty, 9, 7)
    PlayerSocialDisableActionAgainstPed(gFatty, 27, true)
    PedUseSocialOverride(gFatty, 7, true)
    PedUseSocialOverride(gFatty, 18, true)
    PlayerRegisterSocialCallbackVsPed(gFatty, 35, F_Player_Greets_1)
    PlayerRegisterSocialCallbackVsPed(gFatty, 28, F_Player_Greets_2)
    PlayerRegisterSocialCallbackVsPed(gCorn, 35, F_Player_Greets_1)
    PlayerRegisterSocialCallbackVsPed(gCorn, 28, F_Player_Greets_2)
end

function F_Player_Greets_1()
    bPlayerGreets = true
    bPlayerIsAsking = true
    if not bFattyTalks then
        SoundPlayScriptedSpeechEvent(gPlayer, "M_4_02", 1, "genric", false, false)
        bFattyTalks = true
    end
    bPlayerGreetsFatty = true
end

function F_Player_Greets_2()
    bPlayerGreets = true
    bPlayerIsAsking = true
    if not bFattyTalks then
        SoundPlayScriptedSpeechEvent(gPlayer, "M_4_02", 6, "genric", false, false)
        bFattyTalks = true
    end
    bPlayerGreetsFatty = true
end

function F_Social_Greet_Fatty()
    if not bFattyTalks then
        SoundPlayScriptedSpeechEvent(gFatty, "M_4_02", 2, "genric", false, false)
    end
    PlayerSocialDisableActionAgainstPed(gFatty, 35, true)
    bPlayerGreetsFatty = true
end

function F_Social_Taunt_Fatty()
    if social_time == 1 then
        social_time = 0
        bPlayerIsAsking = true
        PlayerSocialDisableActionAgainstPed(gFatty, 28, true)
    end
end

function T_PlayerAsks()
    while not (not MissionActive() or bFattyInTheCan) do
        if bNerdsHit then
            if bFattyBeingCanned then
                break
            end
            local health = PedGetHealth(gFatty)
            if PedGetLastHitWeapon(gFatty) == 301 or PedGetLastHitWeapon(gFatty) == 308 then
                break
            end
            SoundPlayScriptedSpeechEvent(gFatty, "M_4_02", 26, "genric", false, false)
            PedSetTypeToTypeAttitude(1, 13, 0)
            BlipRemove(gBlipNerds01)
            BlipRemoveFromChar(gFatty)
            gFattyBlip = AddBlipForChar(gFatty, 1, 26, 4)
            PedOverrideStat(gCorn, 14, 10)
            PedOverrideStat(gCorn, 6, 100)
            PedOverrideStat(gCorn, 7, 100)
            PedFlee(gCorn, gPlayer)
            PedAttack(gFatty, gPlayer, 3)
            PedOverrideStat(gFatty, 0, 362)
            PedOverrideStat(gFatty, 1, 100)
            bNerdsHit = false
            break
        end
        if bPlayerIsAsking then
            bFattyTalks = true
            while SoundSpeechPlaying(gPlayer) do
                if PedIsPlaying(gFatty, "/Global/Actions/Grapples/Front/Grapples/Hold_Idle/RCV", true) then
                    bFattyGrappled = true
                end
                if bFattyBeingCanned or bFattyGrappled then
                    break
                end
                Wait(0)
            end
            Wait(100)
            if bFattyBeingCanned or bFattyGrappled then
                break
            end
            if not bFattyGrappled and not bFattyBeingCanned then
                SoundPlayScriptedSpeechEvent(gFatty, "M_4_02", 2, "genric", false, true)
            end
            PedSetTypeToTypeAttitude(1, 13, 0)
            BlipRemove(gBlipNerds01)
            BlipRemoveFromChar(gFatty)
            gFattyBlip = AddBlipForChar(gFatty, 1, 26, 4)
            PedOverrideStat(gCorn, 14, 10)
            PedOverrideStat(gCorn, 6, 100)
            PedOverrideStat(gCorn, 7, 100)
            PedFlee(gCorn, gPlayer)
            PedAttack(gFatty, gPlayer, 3)
            PedOverrideStat(gFatty, 0, 362)
            PedOverrideStat(gFatty, 1, 100)
            break
        end
        Wait(0)
    end
    --print(" =====  T_PlayerAsks dead =====")
    collectgarbage()
end

function F_HittingCorn()
    if PedGetWhoHitMeLast(gCorn) == gPlayer or bNerdsHit then
        return true
    else
        return false
    end
end

function F_HitCorn()
    bNerdsHit = true
end

function F_HittingFatty()
    if PedGetWhoHitMeLast(gFatty) == gPlayer or bNerdsHit then
        return true
    else
        return false
    end
end

function F_HitFatty()
    bNerdsHit = true
end

function F_HittingMelvin()
    if PedGetWhoHitMeLast(gMelvin) == gPlayer or bNerdsHit then
        return true
    else
        return false
    end
end

function F_HitMelvin()
    bNerdsHit = true
end

function T_FattyScared()
    while not (not (MissionActive() and PedIsValid(gFatty)) or bPointOfNoReturn) do
        if PedIsPlaying(gFatty, "/Global/Garbagecan/PedPropsActions/StuffGrap/RCV", true) then
            bFattyBeingCanned = true
        end
        if PedIsPlaying(gFatty, "/Global/Garbagecan/PedPropsActions/StuffGrap/RCV/InCan/die", true) then
            bFattyInTheCan = true
        end
        if PedIsPlaying(gFatty, "/Global/Actions/Grapples/Front/Grapples/Hold_Idle/RCV", true) then
            bFattyGrappled = true
        end
        if PedGetHealth(gFatty) <= 25 or bFattyInTheCan then
            BlipRemoveFromChar(gFatty)
            BlipRemove(gBlipNerds01)
            PedLockTarget(gCorn, gPlayer, -1)
            PedClearObjectives(gCorn)
            PedMakeAmbient(gCorn)
            PedFlee(gCorn, gPlayer)
            F_MakePlayerSafeForNIS(true, true)
            PlayerSetControl(0)
            CameraSetWidescreen(true)
            PedFaceObject(gPlayer, gFatty, 2, 1, true)
            bFattyTalks = true
            PedClearObjectives(gFatty)
            PedIgnoreStimuli(gFatty, true)
            PedSetInvulnerableToPlayer(gFatty, true)
            --print("===== bFattyInTheCan? ====", tostring(bFattyInTheCan))
            if not bFattyInTheCan and not bFattyGrappled then
                PedSetActionNode(gFatty, "/Global/4_02/AlgieCower/Cower_Start", "Act/Conv/4_02.act")
            end
            SoundPlayScriptedSpeechEvent(gFatty, "M_4_02", 12, "genric", false, false)
            while SoundSpeechPlaying(gFatty) do
                Wait(0)
            end
            PlayerSetControl(1)
            CameraSetWidescreen(false)
            F_MakePlayerSafeForNIS(false, true)
            bCreateThad = true
            MissionObjectiveComplete(mis_obj01)
            mis_obj02 = MissionObjectiveAdd("4_02_SECDOOR")
            TextPrint("4_02_SECDOOR", 5, 1)
            if not bFattyInTheCan then
                PedSetInvulnerableToPlayer(gFatty, false)
                PedIgnoreStimuli(gFatty, false)
                PedSetActionNode(gFatty, "/Global/N_Striker_A", "Act/Anim/N_Striker_A.act")
                PedMakeAmbient(gFatty)
                PedClearObjectives(gFatty)
                PedFlee(gFatty, gPlayer)
            end
            break
        end
        Wait(0)
    end
    --print(" =====  T_FattyScared dead =====")
    collectgarbage()
end

function F_CreateThad()
    return bCreateThad
end

function F_CreateThadAction()
    if not bShortCut then
        bPlayerGreets = false
        bNerdsHit = false
        gBlipThad = AddBlipForChar(gThad, 1, 0, 4)
    end
end

function F_Player_Greets_3()
    bPlayerGreets = true
    if not bFattyTalks then
        SoundPlayScriptedSpeechEvent(gPlayer, "M_4_02", 3, "genric", false, false)
    end
end

function F_Social_Greet_Thad()
    if bPlayerGreets then
    end
    SoundPlayScriptedSpeechEvent(gThad, "M_4_02", 15, "genric", false, false)
    PlayerSocialDisableActionAgainstPed(gThad, 35, true)
end

function F_Social_Taunt_Thad()
    if not gThadSaysNoWay then
        gThadSaysNoWay = true
        SoundPlayScriptedSpeechEvent(gThad, "M_4_02", 13, "genric", false, true)
    end
    BlipRemove(gBlipAlgie)
    BlipRemoveFromChar(gFatty)
    PedSetTypeToTypeAttitude(1, 13, 0)
    BlipRemoveFromChar(gThad)
    gBlipThad = AddBlipForChar(gThad, 0, 26)
    PedAttack(gThad, gPlayer, 3)
end

function F_ThadHit()
    return bThadCreate and PedGetWhoHitMeLast(gThad) == gPlayer and not bNerdsHit and not bPlayerGreets
end

function F_ThadHitAction()
    bNerdsHit = true
    F_Social_Taunt_Thad()
end

function F_ThadSubmitts()
    return bThadCreate and PedGetHealth(gThad) <= 45
end

function F_ThadCode()
    PedSetTypeToTypeAttitude(1, 13, 2)
    PedSetInvulnerableToPlayer(gThad, true)
    if PedGetGrappleTargetPed(gPlayer) == -1 then
        PedSetActionNode(gThad, "/Global/4_02/AlgieCower/Cower_Start", "Act/Conv/4_02.act")
    end
    bCodeGiven = true
    BlipRemoveFromChar(gThad)
    SoundPlayScriptedSpeechEvent(gThad, "M_4_02", 17, "genric", false, true)
    while SoundSpeechPlaying(gThad) do
        Wait(0)
    end
    PedClearObjectives(gThad)
    PedIgnoreStimuli(gThad, true)
    PedMakeTargetable(gThad, false)
    PedOverrideStat(gThad, 14, 10)
    PedOverrideStat(gThad, 6, 100)
    PedOverrideStat(gThad, 7, 100)
    mis_objDoor = MissionObjectiveAdd("4_02_OPENDOOR")
    bMisobjDoor = true
    SoundDisableSpeech_ActionTree()
    if PedGetGrappleTargetPed(gPlayer) == -1 then
        PedSetActionNode(gThad, "/Global/4_02/Break/BreakNode", "Act/Conv/4_02.act")
    end
    PedSetMinHealth(gThad, 0)
    PedSetInvulnerableToPlayer(gThad, false)
    PedIgnoreStimuli(gThad, false)
    PedMakeTargetable(gThad, true)
    PedMakeAmbient(gThad)
    PedMoveToPoint(gThad, 1, POINTLIST._4_02_PLAYERSTART, 1, nil, 0.3, false, true)
    bCoverPropsSet = true
    TextPrint("4_02_OPENDOOR", 5, 1)
    door_blip = BlipAddPoint(POINTLIST._4_02_SECDOORBLIP, 0)
    SoundPlayAmbientSpeechEvent(gThad, "SCARED")
    MissionObjectiveComplete(mis_obj03)
end

function F_CreateDoorAndPad()
    PedSetTypeToTypeAttitude(1, 13, 0)
    gThad = PedCreatePoint(7, POINTLIST._4_02_GATEKEEPER)
    local health = PedGetHealth(gThad)
    PedSetMinHealth(gThad, health)
    PedSetPedToTypeAttitude(gThad, 13, 2)
    bThadCreate = true
    PedOverrideSocialResponseToStimulus(gThad, 10, 18)
    PedOverrideSocialResponseToStimulus(gThad, 55, 7)
    PedOverrideSocialResponseToStimulus(gThad, 9, 7)
    PlayerSocialDisableActionAgainstPed(gThad, 27, true)
    PedUseSocialOverride(gThad, 7, true)
    PedUseSocialOverride(gThad, 18, true)
    PlayerRegisterSocialCallbackVsPed(gThad, 35, F_Player_Greets_3)
    PlayerRegisterSocialCallbackVsPed(gThad, 28, F_Player_Greets_3)
    AreaSetDoorLockedToPeds(TRIGGER._NERDPATH_BRDOOR, true)
    bSecDoorIsThere = true
end

function F_OpenDoors()
    if bCodeGiven then
        AreaSetDoorLocked(TRIGGER._NERDPATH_BRDOOR, false)
        PAnimOpenDoor(TRIGGER._NERDPATH_BRDOOR)
        bDoorLineDone = false
        if mis_obj04 == 0 then
            if bMisobjDoor then
                MissionObjectiveComplete(mis_objDoor)
                bMisobjDoor = false
            end
            mis_obj04 = MissionObjectiveAdd("4_02_GO_OBS")
            TextPrint("4_02_GO_OBS", 5, 1)
            BlipRemove(door_blip)
            gBlipObs = BlipAddPoint(POINTLIST._4_02_OBSERVATORY, 0)
        end
    elseif not bEarnestLockedTheDoor then
        TextPrint("4_02_CODE", 5, 1)
    end
end

function F_CloseDoors()
    PAnimCloseDoor(TRIGGER._NERDPATH_BRDOOR)
    if bCodeGiven then
    end
end

function F_EnteringGauntlet()
    if AreaGetVisible() ~= 0 then
        bCodeGiven = true
    end
    return PlayerIsInTrigger(TRIGGER._4_02_SPOTTED_SCOUT)
end

function F_EnteringGauntletAction()
    F_SetUpEnemies1()
    F_SetUpWave(tblNerd01)
    bCodeGiven = false
    bEarnestLockedTheDoor = true
    PAnimCloseDoor(TRIGGER._NERDPATH_BRDOOR)
    AreaSetDoorLocked(TRIGGER._NERDPATH_BRDOOR, true)
    bPointOfNoReturn = true
    PickupRemoveAll()
    SoundPlayInteractiveStreamLocked("MS_ActionHigh.rsm", MUSIC_DEFAULT_VOLUME)
    Wait(3000)
    SoundPlayScriptedSpeechEvent_2D("M_4_02_2D", 19)
    PedSetTypeToTypeAttitude(1, 13, 0)
    PAnimSetInvulnerable(TRIGGER._4_02_BAR_01, true)
    PAnimMakeTargetable(TRIGGER._4_02_BAR_01, false)
    PAnimSetInvulnerable(TRIGGER._4_02_BAR_02, true)
    PAnimMakeTargetable(TRIGGER._4_02_BAR_02, false)
end

function F_ApproachWave02()
    return PlayerIsInTrigger(TRIGGER._4_02_P_WAVE2)
end

function F_Wave2()
    F_SetUpEnemies2()
    F_SetUpWave(tblNerd02)
    Wait(50)
    PickupCreatePoint(301, POINTLIST._4_02_ISLANDPICKUP, 1, 0, "MissionPermanent")
    Wait(5000)
    SoundPlayScriptedSpeechEvent_2D("M_4_02_2D", 21)
end

function F_Delete_Wave1_1()
    return PlayerIsInTrigger(TRIGGER._4_02_DELETE_WAVE1)
end

function F_Delete_Wave1_2()
    for n, nerd in tblNerd01 do
        if PedIsValid(nerd.id) then
            PedDelete(nerd.id)
        end
    end
end

function F_ApproachWave03()
    return PlayerIsInTrigger(TRIGGER._4_02_P_WAVE3)
end

function F_Wave3()
    F_SetUpEnemies3()
    F_SetUpWave(tblNerd03)
    PAnimSetInvulnerable(TRIGGER._4_02_BAR_03, true)
    PAnimMakeTargetable(TRIGGER._4_02_BAR_03, false)
    SoundPlayScriptedSpeechEvent_2D("M_4_02_2D", 21)
end

function F_ApproachWave04()
    return PlayerIsInTrigger(TRIGGER._4_02_P_WAVE4)
end

function F_Wave4() -- ! Modified
    F_MakePlayerSafeForNIS(true, true)
    CameraSetWidescreen(true)
    PlayerSetControl(0)
    for n, nerd in tblNerd02 do
        if PedIsValid(nerd.id) then
            PedDelete(nerd.id)
        end
    end
    for n, nerd in tblNerd03 do
        if PedIsValid(nerd.id) then
            PedDelete(nerd.id)
        end
    end
    AreaSetDoorLocked(TRIGGER._SCGATE_OBSERVATORY, true)
    AreaSetDoorLockedToPeds(TRIGGER._SCGATE_OBSERVATORY, true)
    PAnimSetInvulnerable(TRIGGER._DT_OBSERVATORY, true)
    Wait(0)
    while not PAnimRequest(TRIGGER._4_02_OBSDOOR) do
        Wait(0)
    end
    PAnimCreate(TRIGGER._4_02_OBSDOOR)
    gCannonNerd = PedCreatePoint(10, POINTLIST._4_02_SPUD_NERD01)
    PedSetEffectedByGravity(gCannonNerd, false)
    Wait(50)
    --[[
    PedDestroyWeapon(gCannonNerd, 8)
    ]] -- Changed to:
    PedDestroyWeapon(gCannonNerd, 299)
    PedClearAllWeapons(gCannonNerd)
    PedClearObjectives(gCannonNerd)
    PedOverrideStat(gCannonNerd, 3, 80)
    Wait(50)
    BlipRemove(gBlipObs)
    gBlipTransformer = BlipAddPoint(POINTLIST._4_02_FUSE_POINT, 26, 0, 4)
    PedStop(gPlayer)
    Wait(1000)
    while not PedIsPlaying(gCannonNerd, "/Global/Ambient/MissionSpec/GetOnCannon", true) do
        PedSetActionNode(gCannonNerd, "/Global/Ambient/MissionSpec/GetOnCannon", "Act/Anim/Ambient.act")
        Wait(0)
    end
    PedLockTarget(gCannonNerd, gPlayer, 3)
    SoundSetAudioFocusCamera()
    CameraLookAtObject(gCannonNerd, 2, true)                                                                                    -- Added this
    CameraSetPath(PATH._4_02_CANNON_PATH, true)                                                                                 -- Added this
    CameraSetSpeed(15, 5, 30)                                                                                                   -- Added this
    Wait(1500)                                                                                                                  -- Added this
    SoundPlayScriptedSpeechEvent_2D("M_4_02_2D", 21)                                                                            -- Added this
    Wait(6000)                                                                                                                  -- Added this
    PedSetTaskNode(gCannonNerd, "/Global/AI/GeneralObjectives/SpecificObjectives/UseSpudCannon/PreFireWait/Fire", "Act/AI/AI.act") -- Added this
    Wait(2000)                                                                                                                  -- Added this
    PedLockTarget(gCannonNerd, -1)                                                                                              -- Added this
    PedClearObjectives(gCannonNerd)                                                                                             -- Added this
    PedSetActionTree(gCannonNerd, "/Global/N_Ranged_A", "Act/Anim/N_Ranged_A.act")                                              -- Added this
    PedIgnoreStimuli(gCannonNerd, true)                                                                                         -- Added this
    bSpudLinePlayed = true                                                                                                      -- Added this
    --[[
    local cameraX = 33.885
    local cameraY = -133.481
    local cameraZ = 8.554
    CameraLookAtXYZ(cameraX, cameraY, cameraZ, true)
    CameraSetPath(PATH._4_02_CANNON_PATH, true)
    CameraSetSpeed(15, 5, 30)
    Wait(1500)
    SoundPlayScriptedSpeechEvent_2D("M_4_02_2D", 21)
    Wait(6000)
    PedSetTaskNode(gCannonNerd, "/Global/AI/GeneralObjectives/SpecificObjectives/UseSpudCannon/PreFireWait/Fire", "Act/AI/AI.act")
    Wait(2000)
    PedLockTarget(gCannonNerd, -1)
    PedClearObjectives(gCannonNerd)
    PedSetActionTree(gCannonNerd, "/Global/N_Ranged_A", "Act/Anim/N_Ranged_A.act")
    PedIgnoreStimuli(gCannonNerd, true)
    bSpudLinePlayed = true
    ]] -- Removed this
    local fx, fy, fz = GetPointList(POINTLIST._4_02_FUSE_POINT)
    CameraLookAtXYZ(fx, fy, fz, false)
    Wait(500)
    SoundPlayScriptedSpeechEvent_2D("M_4_02_2D", 31)
    Wait(3000)
    CameraSetWidescreen(false)
    F_MakePlayerSafeForNIS(false, true)
    PlayerSetControl(1)
    CameraReturnToPlayer()
    SoundSetAudioFocusPlayer()
    F_SetUpEnemies4()
    F_SetUpWave(tblNerd04)
    CreateThread("T_Breaker_Box")
    CreateThread("T_Delete_Wave3_2")
    MissionObjectiveComplete(mis_obj04)
    mis_obj05 = MissionObjectiveAdd("4_02_TRANS")
    TextPrint("4_02_TRANS", 5, 1)
end

function T_Delete_Wave3_2() -- ! Modified
    while not (not MissionActive() or bWave3Dead) do
        if PlayerIsInTrigger(TRIGGER._4_02_DELETE_WAVE3) then
            bWave3Dead = true
            PedDelete(gCannonNerd)
            Wait(50)
            gCannonNerd = PedCreatePoint(10, POINTLIST._4_02_SPUD_NERD01)
            PedSetEffectedByGravity(gCannonNerd, false)
            Wait(50)
            --[[
            PedDestroyWeapon(gCannonNerd, 8)
            ]] -- Changed to:
            PedDestroyWeapon(gCannonNerd, 299)
            PedClearAllWeapons(gCannonNerd)
            PedClearObjectives(gCannonNerd)
            AddBlipForChar(gCannonNerd, 2, 2, 1)
            PedOverrideStat(gCannonNerd, 3, 80)
            Wait(50)
            PedSetActionNode(gCannonNerd, "/Global/Ambient/MissionSpec/GetOnCannon", "Act/Anim/Ambient.act")
            PedLockTarget(gCannonNerd, gPlayer, 3)
            Wait(50)
            PedSetTaskNode(gCannonNerd, "/Global/AI/GeneralObjectives/SpecificObjectives/UseSpudCannon", "Act/AI/AI.act")
            bFluxLinePlayed = true
        end
        Wait(0)
    end
    Wait(0)
    collectgarbage()
end

function T_Breaker_Box()
    while MissionActive() and bBreakerAlive do
        local index_light, simplePool_light = PAnimGetPoolIndex("SC_ObservTrans", 33.1794, -130.376, 10.681, 1)
        if PAnimIsDestroyed(index_light, simplePool_light) then
            F_RunEarnestNIS()
            bBreakerAlive = false
        end
        Wait(0)
    end
    Wait(0)
    collectgarbage()
end

function cbCannonNerd()
    PedAttackPlayer(gCannonNerd, 3)
end

function F_PlayerOnSpudCannon()
    return PedIsPlaying(gPlayer, "/Global/WPCANNON/UseSpudCannon/In/In/Use/MasterSpawns", true)
end

function F_PlayerOnCannon()
    return PedIsPlaying(gPlayer, "/Global/WPCANNON/UseSpudCannon/In/In/Use/MasterSpawns", false)
end

function F_PlayerOnCannonAction()
    CreateThread("T_Door_Health")
    bOnCannon = true
    PAnimSetInvulnerable(TRIGGER._DT_OBSERVATORY, false)
    PAnimOverrideDamage(TRIGGER._DT_OBSERVATORY, 1200)
    PAnimShowHealthBar(TRIGGER._DT_OBSERVATORY, true, "4_02_OBSDOOR", true)
    PAnimMakeTargetable(TRIGGER._DT_OBSERVATORY, true)
    bPlayerAttackDoors = true
    MissionObjectiveComplete(mis_obj06)
    TextPrint("4_02_KILLDOORS", 4, 1)
    mis_obj07 = MissionObjectiveAdd("4_02_KILLDOORS")
    gBlipObsDoor = BlipAddPoint(POINTLIST._4_02_OBSDOORBLIP, 0)
    BlipRemove(gBlipCannon)
    F_SpawnerAttackPlayer5()
    F_SpawnerAttackPlayer6()
    CreateThread("T_Spawn_Window")
    Wait(500)
end

function T_Spawn_Window()
    while not (not MissionActive() or bDoorDead) do
        if gWindowsStage == 1 and PAnimGetHealth(TRIGGER._DT_OBSERVATORY) <= 0.75 and PAnimGetHealth(TRIGGER._DT_OBSERVATORY) >= 0.55 then
            F_SpawnerAttackPlayer4()
            F_SpawnerAttackPlayer3()
            gWindowsStage = 2
        elseif gWindowsStage == 2 and PAnimGetHealth(TRIGGER._DT_OBSERVATORY) <= 0.5 and PAnimGetHealth(TRIGGER._DT_OBSERVATORY) >= 0.25 then
            F_SpawnerAttackPlayer2()
            F_SpawnerAttackPlayer1()
            gWindowsStage = 3
        elseif gWindowsStage == 3 and PAnimGetHealth(TRIGGER._DT_OBSERVATORY) <= 0.2 and PAnimGetHealth(TRIGGER._DT_OBSERVATORY) >= 0 then
            if not PedIsValid(gSpawned05) then
                F_SpawnerAttackPlayer5()
            end
            if not PedIsValid(gSpawned06) then
                F_SpawnerAttackPlayer6()
            end
            if not PedIsValid(gSpawned04) then
                F_SpawnerAttackPlayer4()
            end
            if not PedIsValid(gSpawned03) then
                F_SpawnerAttackPlayer3()
            end
            gWindowsStage = 4
        end
        Wait(0)
    end
    Wait(0)
    collectgarbage()
    --print("=== T_Spawn_Window Dead ===")
end

function T_Door_Health()
    while not (not MissionActive() or bDoorDead) do
        if PAnimIsDestroyed(TRIGGER._DT_OBSERVATORY) then
            while not PAnimRequest(TRIGGER._DT_OBSERVATORY) do
                Wait(0)
            end
            BlipRemove(gBlipObsDoor)
            bDoorDead = true
            PAnimHideHealthBar(TRIGGER._DT_OBSERVATORY)
            PAnimMakeTargetable(TRIGGER._DT_OBSERVATORY, false)
            PAnimSetActionNode(TRIGGER._DT_OBSERVATORY, "/Global/scObsDr/Functions/Open", "Act/Props/scObsDr.act")
            MissionObjectiveComplete(mis_obj07)
            BlipRemove(gBlipObs)
            bEndCut = true
        end
        Wait(0)
    end
    Wait(0)
    collectgarbage()
end

function F_CreateWindowSnipers(idPed, spudbool) -- ! Modified
    PedClearObjectives(idPed)
    --[[
    PedDestroyWeapon(idPed, 8)
    ]] -- Changed to:
    PedDestroyWeapon(idPed, 299)
    PedClearAllWeapons(idPed)
    if spudbool then
        PedSetWeapon(idPed, 307, 30)
    else
        PedSetWeapon(idPed, 307, 30)
    end
    PedLockTarget(idPed, gPlayer, 3)
    PedOverrideStat(idPed, 3, 50)
    PedOverrideStat(idPed, 11, 85)
end

function F_DeleteWindowsNerds()
    F_WindowNerdDelete(gSpawned01)
    F_WindowNerdDelete(gSpawned02)
    F_WindowNerdDelete(gSpawned03)
    F_WindowNerdDelete(gSpawned04)
    F_WindowNerdDelete(gSpawned05)
    F_WindowNerdDelete(gSpawned06)
end

function F_WindowNerdDelete(nerd)
    if PedIsValid(nerd) then
        PedDelete(nerd)
    end
end

function F_SpawnerAttackPlayer1(idPed, nerd_spawner1)
    gSpawned01 = PedCreatePoint(5, POINTLIST._4_02_O_WN4_2)
    F_CreateWindowSnipers(gSpawned01, false)
    bSetMove01 = true
end

function F_SpawnerAttackPlayer2(idPed, nerd_spawner2)
    gSpawned02 = PedCreatePoint(6, POINTLIST._4_02_O_WN2_2)
    F_CreateWindowSnipers(gSpawned02, true)
    bSetMove02 = true
end

function F_SpawnerAttackPlayer3(idPed, nerd_spawner3)
    gSpawned03 = PedCreatePoint(7, POINTLIST._4_02_O_WN3_2)
    F_CreateWindowSnipers(gSpawned03, false)
    bSetMove03 = true
end

function F_SpawnerAttackPlayer4(idPed, nerd_spawner4)
    gSpawned04 = PedCreatePoint(11, POINTLIST._4_02_O_WN1_2)
    F_CreateWindowSnipers(gSpawned04, true)
    bSetMove04 = true
end

function F_SpawnerAttackPlayer5(idPed, nerd_spawner5)
    gSpawned05 = PedCreatePoint(9, POINTLIST._4_02_O_R1_1)
    F_CreateWindowSnipers(gSpawned05, true)
    bSetMove05 = true
end

function F_SpawnerAttackPlayer6(idPed, nerd_spawner6)
    gSpawned06 = PedCreatePoint(8, POINTLIST._4_02_O_R2_1)
    F_CreateWindowSnipers(gSpawned06, false)
    bSetMove06 = true
end

function cbSpawner1()
    bHasMoved01 = true
end

function cbSpawner2()
    bHasMoved02 = true
end

function cbSpawner3()
    bHasMoved03 = true
end

function cbSpawner4()
    bHasMoved04 = true
end

function cbSpawner5()
    bHasMoved05 = true
end

function cbSpawner6()
    bHasMoved06 = true
end

function F_SetUpWave(tbl) -- ! Modified
    for n, nerd in tbl do
        nerd.id = PedCreatePoint(nerd.model, nerd.point)
        if not nerd.bNoCover then
            --[[
            PedDestroyWeapon(nerd.id, 8)
            ]] -- Changed to:
            PedDestroyWeapon(nerd.id, 299)
            PedClearAllWeapons(nerd.id)
            PedSetWeaponNow(nerd.id, nerd.p_weapon, nerd.ammo, false)
        end
        PedOverrideStat(nerd.id, 3, 80)
        PedOverrideStat(nerd.id, 0, 362)
        PedOverrideStat(nerd.id, 1, 100)
        PedSetFlag(nerd.id, 134, true)
        if not nerd.bNoCover then
            PedCoverSetFromProfile(nerd.id, nerd.target, nerd.cover, nerd.cover_file)
        end
        PedAttackPlayer(nerd.id, 3)
    end
end

function F_SetUpEnemies1()
    tblNerd01 = {
        {
            model = 6,
            point = POINTLIST._4_02_P_NERD01,
            target = gPlayer,
            cover = POINTLIST._4_02_P_NERD01,
            p_weapon = 301,
            ammo = 50,
            cover_file = "4_02_p1_1_cover"
        },
        {
            model = 11,
            point = POINTLIST._4_02_P_NERD02,
            target = gPlayer,
            cover = POINTLIST._4_02_P_NERD02,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p1_2_cover"
        },
        {
            model = 7,
            point = POINTLIST._4_02_P_NERD05,
            target = gPlayer,
            cover = POINTLIST._4_02_P_NERD05,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p1_5_cover"
        }
    }
end

function F_SetUpEnemies2()
    tblNerd02 = {
        {
            model = 11,
            point = POINTLIST._4_02_NERD_SCOUT2_01,
            target = gPlayer,
            cover = POINTLIST._4_02_NERD_SCOUT2_01,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p2_scout_cover"
        },
        {
            model = 8,
            point = POINTLIST._4_02_P2_NERD01,
            target = gPlayer,
            cover = POINTLIST._4_02_P2_NERD01,
            p_weapon = 309,
            ammo = 50,
            cover_file = "4_02_p1_1_cover"
        },
        {
            model = 5,
            point = POINTLIST._4_02_P2_NERD02,
            target = gPlayer,
            cover = POINTLIST._4_02_P2_NERD02,
            p_weapon = 301,
            ammo = 50,
            cover_file = "4_02_p1_1_cover"
        },
        {
            model = 9,
            point = POINTLIST._4_02_P2_NERD03,
            target = gPlayer,
            cover = POINTLIST._4_02_P2_NERD03,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p1_scout_cover"
        }
    }
end

function F_SetUpEnemies3()
    tblNerd03 = {
        {
            model = 7,
            point = POINTLIST._4_02_P3_NERD_SCOUT1_01,
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD_SCOUT1_02,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p3_scout1_cover",
            bNoCover = true
        },
        {
            model = 8,
            point = POINTLIST._4_02_P3_NERD_SCOUT2_01,
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD_SCOUT2_02,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p3_scout2_cover",
            bNoCover = true
        },
        {
            model = 5,
            point = POINTLIST._4_02_P3_NERD01,
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD01,
            p_weapon = 301,
            ammo = 50,
            cover_file = "4_02_p3_1_cover"
        },
        {
            model = 9,
            point = POINTLIST._4_02_P3_NERD02,
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD02,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p2_scout_cover"
        },
        {
            model = 11,
            point = POINTLIST._4_02_P3_NERD05,
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD05,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p3_5_cover"
        },
        {
            model = 6,
            point = POINTLIST._4_02_P3_NERD07,
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD07,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p3_7_cover"
        }
    }
end

function F_SetUpEnemies4()
    tblNerd04 = {
        {
            model = 9,
            point = POINTLIST._4_02_P4_NERD02,
            target = gPlayer,
            cover = POINTLIST._4_02_P4_NERD02,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p4_2_cover"
        },
        {
            model = 8,
            point = POINTLIST._4_02_P4_NERD03,
            target = gPlayer,
            cover = POINTLIST._4_02_P4_NERD03,
            p_weapon = 301,
            ammo = 50,
            cover_file = "4_02_p3_1_cover"
        },
        {
            model = 4,
            point = POINTLIST._4_02_P4_NERD05,
            target = gPlayer,
            cover = POINTLIST._4_02_P4_NERD05,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p3_1_cover"
        },
        {
            model = 6,
            point = POINTLIST._4_02_P4_NERD06,
            target = gPlayer,
            cover = POINTLIST._4_02_P4_NERD06,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p3_1_cover"
        }
    }
end

function F_FailMission()
    mission_completed = true
    Wait(3000)
    SoundPlayMissionEndMusic(false, 10)
    MissionFail()
end

function MissionCleanup()
    SoundStopInteractiveStream()
    PAnimHideHealthBar()
    PedSetUniqueModelStatus(5, numFatty)
    PedSetUniqueModelStatus(9, numCorny)
    PedSetUniqueModelStatus(7, numThad)
    PedSetUniqueModelStatus(6, numMelvin)
    BlipRemove(gBlipObs2)
    BlipRemove(gBlipObs)
    CameraReturnToPlayer()
    PAnimSetActionNode(TRIGGER._DT_OBSERVATORY, "/Global/scObsDr/Functions/Close", "/Act/Props/scObsDr.act")
    AreaSetDoorLocked(TRIGGER._SCGATE_OBSERVATORY, false)
    EnablePOI()
    CameraSetWidescreen(false)
    DATUnload(2)
    PlayerSetControl(1)
    UnLoadAnimationGroup("F_NERDS")
    UnLoadAnimationGroup("IDLE_NERD_C")
end
