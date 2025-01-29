ImportScript("Library/LibTable.lua")
ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibPed.lua")
ImportScript("Library/LibTrigger.lua")
ImportScript("Library/LibPropNew.lua")
ImportScript("Library/LibPlayer.lua")
local mission_started = false
local bDarbyFightStarted = false
local bSpawnPreppies = true
local bDarbyAtRest = false
local bDarbyCalledPreps = false
local bHintNIS = false
local lastChosenPoint
local gFirstTimer = true
local gPleaseCreateSomeHealth = true
local gRestCompleted = false
local gDarbyCanAvoid = false
local gDoorLocked, gDoor01Locked = false, false
local DARBY_MAX_HEALTH = 300
local SUMMON_HEALTH_PERCENT = 80
local MAX_PREPPIES = 2
local ACTIVE_DOORS = 2
local HEALTH_INTERVAL = 15000
local LOCKED = true
local UNLOCKED = false
idDarby = nil
local idDarbyBlip, idEndBlip, idPrevModel1, idPrevModel2, idPrevModel3, idSpawnedPreppy
local intCurrentPreppies = 0
local intCurrentDoors = 2
local intHealthPercent = 0
local oldAttitude = PedGetTypeToTypeAttitude(5, 13)
local gPlayerKnockedOut = false
local gDarbyRestingTime = -1
local gStartFollowPath = true
local gTotalAvoidTime = 5000
local gDoorsClosed = false
local tblPreppySpawnLocs = {}
local tblAvailableSpawnLocations = {}
local tblSpawnedPreppies = {}
local tblPreppyModels = {
    30,
    35,
    32,
    34,
    40
}
local gDarbyReturningComments = {
    "2_B_16",
    "2_B_17",
    "2_B_18"
}
local gCurrentComment = 1
local gDarbyCheer = {
    "2_B_19",
    "2_B_20",
    "2_B_21"
}
local gCurrentCheer = 1
local gDarbyCheerDelay = 30000

function F_FailMission()
    gPlayerFailed = true
    MinigameSetCompletion("M_FAIL", false)
    Wait(1000)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORL)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORR)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORL01)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORR01)
    PedRestoreWeaponInventorySnapshot(gPlayer)
    SoundPlayMissionEndMusic(false, 10)
    MissionFail(true, true, "M_FAIL_DEAD")
end

function F_CompleteMission()
    PAnimSetActionNode(TRIGGER._DRBRACE, "/Global/DRBrace/NotUseable/NotMoving", "Act/Props/DRBrace.act")
    PAnimSetActionNode(TRIGGER._DRBRACE01, "/Global/DRBrace/NotUseable/NotMoving", "Act/Props/DRBrace.act")
    Wait(5000)
    mission_started = false
    if gFirstImmortalPrep and PedIsValid(gFirstImmortalPrep) then
        --print("[RAUL] Making the first ped mortal")
        PedSetFlag(gFirstImmortalPrep, 58, false)
    end
    if gSecondImmortalPrep and PedIsValid(gSecondImmortalPrep) then
        --print("[RAUL] Making the second ped mortal")
        PedSetFlag(gSecondImmortalPrep, 58, false)
    end
    F_CleanupDarby()
    UnLoadAnimationGroup("N2B Dishonerable")
    UnLoadAnimationGroup("NIS_2_B")
    UnLoadAnimationGroup("Boxing")
    SoundFadeoutStream()
    PlayCutsceneWithLoad("2-BB", true)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORL)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORR)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORL01)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORR01)
    PedDeleteWeaponInventorySnapshot(gPlayer)
    SetFactionRespect(5, 100)
    UnlockYearbookPicture(37)
    F_UnlockYearbookReward()
    MissionSucceed(false, false, false)
    PlayerSetScriptSavedData(14, 0)
end

function F_MonitorHealth()
    if F_PlayerIsDead() then
        return true
    end
    return false
end

function F_DarbyDead()
    if bDarbyFightStarted and idDarby ~= nil and not bPrepsAlive and (PedIsDead(idDarby) or PedGetHealth(idDarby) <= 0) then
        gDarbyFightBegun = false
        return true
    end
    return false
end

function F_OpenDoor()
    if gDoorsClosed and (PAnimIsOpen(TRIGGER._IBOXING_ESCDOORL) or PAnimIsOpen(TRIGGER._IBOXING_ESCDOORR) or PAnimIsOpen(TRIGGER._IBOXING_ESCDOORL01) or PAnimIsOpen(TRIGGER._IBOXING_ESCDOORR01)) then
        return true
    else
        return false
    end
end

function F_MoveDarbyToLounge()
    CameraAllowChange(true)
    SoundFadeWithCamera(false)
    MusicFadeWithCamera(false)
    CameraFade(500, 0)
    Wait(500)
    CameraReturnToPlayer()
    PedClearObjectives(idDarby)
    PedStop(idDarby)
    F_DarbyRest(true)
    CameraFade(500, 1)
    Wait(500)
    SoundFadeWithCamera(true)
    MusicFadeWithCamera(true)
end

function F_BeginDarbyFight()
    if not gDarbyFightBegun then
        gDarbyFightBegun = true
        gDarbyCanAvoid = false
        SoundFadeWithCamera(false)
        MusicFadeWithCamera(false)
        CameraFade(1000, 0)
        PlayerSetControl(0)
        Wait(1000)
        F_MakePlayerSafeForNIS(true)
        CameraSetWidescreen(true)
        F_SetupDarbyFight()
        Wait(500)
        while not gRestCompleted do
            Wait(0)
        end
        PedSetActionNode(idDarby, "/Global/2_B/DrbyVault/PlayAnim/ReleaseGroup", "Act/Conv/2_B.act")
        PedSetActionNode(idDarby, "/Global/2_B/Talking/DARBYIDLE", "Act/Conv/2_B.act")
        Wait(10)
        PedSetPosPoint(idDarby, POINTLIST._2_B_DARBY_REST)
        PlayerSetPosPoint(POINTLIST._2_B_PLAYERNIS01)
        L_PedExec("first_wave", F_PreparePreps, "id")
        L_PedExec("boxing_ring", F_PreparePreps, "id")
        CameraSetFOV(70)
        CameraSetXYZ(-729.0317, 385.36002, 299.5287, -729.7147, 386.08142, 299.41556)
        PedLockTarget(idDarby, gPlayer, 3)
        PedLockTarget(gPlayer, idDarby, 3)
        CameraFade(1000, 1)
        SoundDisableSpeech_ActionTree()
        Wait(500)
        PedMoveToPoint(gPlayer, 1, POINTLIST._2_B_PLAYERNIS01, 2)
        F_PlaySpeechAndWait(gPlayer, "M_2_B", 3, "supersize")
        CameraSetFOV(20)
        CameraSetXYZ(-728.88135, 386.52426, 299.40536, -729.7396, 387.03674, 299.4135)
        PedSetActionNode(idDarby, "/Global/2_B/Talking/Darby02", "Act/Conv/2_B.act")
        F_PlaySpeechAndWait(idDarby, "M_2_B", 8, "supersize")
        PedSetActionNode(idDarby, "/Global/2_B/Talking/DARBYIDLE", "Act/Conv/2_B.act")
        CameraSetFOV(20)
        CameraSetXYZ(-734.7173, 388.7518, 299.47632, -733.7308, 388.5906, 299.47113)
        CameraLookAtObject(gPlayer, 3, true, 0.85)
        PedSetActionNode(gPlayer, "/Global/2_B/Talking/Player02", "Act/Conv/2_B.act")
        F_PlaySpeechAndWait(gPlayer, "M_2_B", 13, "supersize")
        PedLockTarget(gPlayer, -1)
        CameraSetFOV(20)
        CameraSetXYZ(-728.88135, 386.52426, 299.40536, -729.7396, 387.03674, 299.4135)
        if gPedsAlive then
            SoundPlayScriptedSpeechEvent(idDarby, "M_2_B", 11, "large")
        else
            PedSetActionNode(idDarby, "/Global/2_B/Talking/Darby01", "Act/Conv/2_B.act")
            SoundPlayScriptedSpeechEvent(idDarby, "M_2_B", 6, "supersize")
        end
        SoundEnableSpeech_ActionTree()
        if not gDoor01Locked then
            F_SetLoungeDoorsLocked(1, LOCKED)
        end
        if not gDoorLocked then
            F_SetLoungeDoorsLocked(0, LOCKED)
        end
        CreateThread("F_MonitorDarby")
        bDarbyFightStarted = true
        CameraReset()
        CameraReturnToPlayer()
        F_SummonPreppies()
        if PedIsValid(idBiff) then
            PedSetActionNode(idBiff, "/Global/2_B/BiffKO", "Act/Conv/2_B.act")
        end
        PlayerSetControl(1)
        CameraSetWidescreen(false)
        F_MakePlayerSafeForNIS(false)
        SoundFadeWithCamera(true)
        MusicFadeWithCamera(true)
    end
end

function F_FightCondition()
    if not bPrepsAlive and bSpawnPreppies then
        if not bDarbyAtRest then
            --print("Testing LUA COND, returning 1 <<<<<<<<<<<<<<")
            return 1
        else
            return 0
        end
    else
        --print("Testing LUA COND, returning 0 <<<<<<<<<<<<<<")
        return 0
    end
end

function F_MonitorDarby()
    while mission_started do
        intHealthPercent = PedGetHealth(idDarby) / DARBY_MAX_HEALTH * 100
        if not bPrepsAlive and gPlayerKnockedOut and bSpawnPreppies and not bDarbyAtRest then
            F_DarbyRest()
        end
        if not gCheckingDarby and PedGetHealth(idDarby) <= 0 and PedIsPlaying(idDarby, "/Global/HitTree/Standing/PostHit/Standing/Dead/BoxingStun/StunControl", true) and F_PedIsHitByPlayer(idDarby) then
            PedSetActionNode(idDarby, "/Global/HitTree/Standing/PostHit/Standing/Dead/BoxingStun/StunControl/KnockoutHit/KnockoutHit", "Act/HitTree.act")
            gCheckingDarby = true
        end
        Wait(100)
        if gDarbyLastReturn and bDarbyAtRest then
            F_DarbyReturn()
        end
        if not gFirstCheap and PedIsValid(gFirstImmortalPrep) and 0 >= PedGetHealth(gFirstImmortalPrep) then
            PedMakeTargetable(gFirstImmortalPrep, false)
            gFirstCheap = true
        end
        if not gSecondCheap and PedIsValid(gSecondImmortalPrep) and 0 >= PedGetHealth(gSecondImmortalPrep) then
            PedMakeTargetable(gSecondImmortalPrep, false)
            gSecondCheap = true
        end
    end
end

function F_DarbyRest(isFirstRest)
    local x, y, z, heading = GetPointList(POINTLIST._2_B_DARBY_RETURN_FROM_REST)
    local intDarbyTime = GetTimer()
    local bDarbyInArea = false
    bDarbyAtRest = true
    gDarbyRestingTime = GetTimer()
    PedSetPedToTypeAttitude(idDarby, 13, 4)
    PedSetPedToTypeAttitude(idDarby, 5, 1)
    PedSetInvulnerable(idDarby, true)
    PedClearObjectives(idDarby)
    PedMoveToXYZ(idDarby, 2, x, y, z)
    while not bDarbyInArea do
        if PedIsInAreaXYZ(idDarby, x, y, z, 0.5, 0) then
            bDarbyInArea = true
        else
            PedClearObjectives(idDarby)
            PedMoveToXYZ(idDarby, 2, x, y, z)
            if GetTimer() >= intDarbyTime + 6000 then
                PedSetPosPoint(idDarby, POINTLIST._2_B_DARBY_RETURN_FROM_REST)
                bDarbyInArea = true
            end
        end
        Wait(0)
    end
    PedStop(idDarby)
    PedFaceHeading(idDarby, heading - 90, 0)
    PedSetActionNode(idDarby, "/Global/2_B/DrbyVault/PlayAnim", "Act/Conv/2_B.act")
    Wait(0)
    while PedIsPlaying(idDarby, "/Global/2_B/DrbyVault/PlayAnim", true) do
        Wait(0)
    end
    PedStop(idDarby)
    Wait(0)
    PedFaceObject(idDarby, gPlayer, 2, 1)
    PedSetInvulnerable(idDarby, false)
    PedSetEntityFlag(idDarby, 56, true)
    if not gFirstTimer then
        Wait(4000)
        if not bDarbyCalledPreps then
            bDarbyCalledPreps = true
        end
        F_SummonPreppies()
    end
    gRestCompleted = true
end

function T_DarbyShouldAvoid()
    while gDarbyFightBegun do
        Wait(0)
        if not gDarbyCanAvoid then
            if PedIsHit(idDarby, 2, 1000) and WeaponGetType(PedGetLastHitWeapon(idDarby)) == 0 then
                --print("[RAUL] DARBY GOT HIT BY A PROJECTILE WEAPON... HE IS INVULNERABLE NOW")
                gDarbyCanAvoid = true
                gAvoidingTime = GetTimer()
                PedSetEntityFlag(idDarby, 56, true)
            end
        elseif GetTimer() - gAvoidingTime > gTotalAvoidTime then
            --print("[RAUL] DARBY'S INVULNERABLE TIME IS UP")
            gDarbyCanAvoid = false
            PedSetEntityFlag(idDarby, 56, false)
        end
    end
end

function T_DarbyThrowBottle()
    while bPrepsAlive do
        if not bPrepsAlive then
            break
        end
        Wait(1000)
        if not bPrepsAlive then
            break
        end
        PedSetInvulnerable(idDarby, true)
        PedStop(idDarby)
        PedClearObjectives(idDarby)
        if PedIsInAreaXYZ(idDarby, -735.357, 389.926, 298.039, 0.5, 0) then
            PedMoveToPoint(idDarby, 0, POINTLIST._2_B_DARBY_BOTTLE_THROW, 2)
        else
            PedMoveToPoint(idDarby, 0, POINTLIST._2_B_DARBY_BOTTLE_THROW, 1)
        end
        if not bPrepsAlive then
            break
        end
        Wait(1000)
        PedClearAllWeapons(idDarby)
        Wait(100)
        if not bPrepsAlive then
            break
        end
        PedStop(idDarby)
        PedClearObjectives(idDarby)
        PedFaceObjectNow(idDarby, gPlayer, 3)
        Wait(100)
        if not bPrepsAlive then
            break
        end
        while not PlayerIsInTrigger(TRIGGER._2_B_PLAYER_NEAR_BAR) do
            if not bPrepsAlive then
                break
            end
            Wait(0)
        end
        if not bPrepsAlive then
            break
        end
        PedLockTarget(idDarby, gPlayer, 3)
        PedFaceObjectNow(idDarby, gPlayer, 3)
        PedSetInvulnerable(idDarby, true)
        Wait(100)
        PedSetActionTree(idDarby, "/Global/BOSS_Darby/Special/Throw", "Act/Anim/BOSS_Darby.act")
        while not PedIsPlaying(idDarby, "/Global/BOSS_Darby/Special/Throw/GetWeapon/Release/Empty", true) do
            Wait(0)
        end
        PedSetActionTree(idDarby, "/Global/BOSS_Darby", "Act/Anim/BOSS_Darby.act")
        PedSetInvulnerable(idDarby, false)
        PedLockTarget(idDarby, gPlayer, -1)
        if not bPrepsAlive then
            break
        end
        Wait(2000)
        if not bPrepsAlive then
            break
        end
        Wait(2000)
        if not bPrepsAlive then
            break
        end
        Wait(2000)
        Wait(0)
    end
    PedClearAllWeapons(idDarby)
    PedSetInvulnerable(idDarby, true)
    F_DarbyReturn()
end

function F_HintNIS()
    bHintNIS = true
end

function F_DarbyReturn()
    local x, y, z, heading = GetPointList(POINTLIST._2_B_DARBY_REST)
    local intDarbyTime = GetTimer()
    local bReturn = false
    PedSetEntityFlag(idDarby, 56, false)
    bDarbyAtRest = false
    PedStop(idDarby)
    PedClearObjectives(idDarby)
    PedIgnoreStimuli(idDarby, true)
    PedSetActionNode(idDarby, "/Global/2_B/Empty", "Act/Conv/2_B.act")
    if not gFirstTimer then
        if not gDarbyLastReturn then
            SoundPlayScriptedSpeechEvent(idDarby, "M_2_B", 9, "large")
            gCurrentComment = gCurrentComment + 1
            if gCurrentComment > table.getn(gDarbyReturningComments) then
                gCurrentComment = 1
            end
        else
            gDarbyLastReturn = nil
        end
    end
    gFirstTimer = false
    PedMoveToXYZ(idDarby, 1, x, y, z, 0.1)
    --print("[RAUL] - Moving Darby...")
    while not bReturn do
        if PedIsValid(idDarby) and not PedIsDead(idDarby) and PedIsInAreaXYZ(idDarby, x, y, z, 0.5, 0) then
            --print("[RAUL] - DARBY REACHED PATH...")
            bReturn = true
        else
        end
        Wait(0)
    end
    PedStop(idDarby)
    PedFaceHeading(idDarby, heading - 90, 0)
    Wait(0)
    PedSetActionNode(idDarby, "/Global/2_B/DrbyVault/PlayAnim", "Act/Conv/2_B.act")
    Wait(0)
    while PedIsPlaying(idDarby, "/Global/2_B/DrbyVault/PlayAnim", true) do
        Wait(0)
    end
    PedStop(idDarby)
    PedClearObjectives(idDarby)
    PedSetInvulnerable(idDarby, false)
    PedSetPedToTypeAttitude(idDarby, 13, 0)
    PedSetPedToTypeAttitude(idDarby, 5, 4)
    PedIgnoreStimuli(idDarby, false)
    PedAttackPlayer(idDarby)
    DARBY_MAX_HEALTH = PedGetHealth(idDarby)
end

function F_GetRandomXYZ(idPoint, intRadius)
    local newX, newY, z = GetPointList(idPoint)
    newX = math.random(newX - intRadius, newX + intRadius)
    newY = math.random(newY - intRadius, newY + intRadius)
    return newX, newY, z
end

function F_SummonPreppies()
    --print("*************************************~n~****************************************")
    SoundPlayScriptedSpeechEvent(idDarby, "M_2_B", 5, "jumbo")
    --print("*************************************~n~****************************************")
    PedStop(idDarby)
    local idPreppy, idx
    local bPreppyCreated = false
    local spawnPoint, moveToPoint, x, y, z
    CreateThread("T_LockDoors")
    local prepHealth = 0
    if bSpawnPreppies then
        F_SetupSpawnLocations()
        while intCurrentPreppies < MAX_PREPPIES do
            spawnPoint, moveToPoint = F_GetSpawnLocation()
            x, y, z = F_GetRandomXYZ(spawnPoint, 2.5)
            if not gFirstPreppyCreated then
                idPreppy = PedCreateXYZ(30, x, y, z)
                gFirstPreppyCreated = true
                gFirstImmortalPrep = idPreppy
                PedSetFlag(idPreppy, 58, true)
            elseif not gSecondPreppyCreated then
                idPreppy = PedCreateXYZ(40, x, y, z)
                gSecondPreppyCreated = true
                gSecondImmortalPrep = idPreppy
                PedSetFlag(idPreppy, 58, true)
            else
                idPreppy = PedCreateXYZ(F_GetPreppyModel(), x, y, z)
            end
            idSpawnedPreppy = idPreppy
            bPreppyCreated = true
            table.insert(tblSpawnedPreppies, {})
            idx = table.getn(tblSpawnedPreppies)
            tblSpawnedPreppies[idx].id = idPreppy
            tblSpawnedPreppies[idx].KO = false
            tblSpawnedPreppies[idx].moveToPoint = moveToPoint
            tblSpawnedPreppies[idx].createTime = GetTimer()
            tblSpawnedPreppies[idx].nextMoveTime = 0
            prepHealth = PedGetMaxHealth(idPreppy) / 2
            PedSetMaxHealth(idPreppy, prepHealth)
            PedSetHealth(idPreppy, prepHealth)
            intCurrentPreppies = intCurrentPreppies + 1
            PedMoveToXYZ(idPreppy, 1, -730.5, 385.3, 298.06, 5)
            Wait(300)
        end
        gPleaseCreateSomeHealth = true
        CreateThread("F_MonitorSpawnedPreppies")
    end
end

function T_LockDoors()
    local timeout = GetTimer()
    local waiting = true
    if not gDoor01Locked then
        F_SetLoungeDoorsLocked(1, UNLOCKED)
    end
    if not gDoorLocked then
        F_SetLoungeDoorsLocked(0, UNLOCKED)
    end
    while waiting do
        Wait(0)
        if GetTimer() - timeout > 5000 then
            if not gDoor01Locked then
                F_SetLoungeDoorsLocked(1, LOCKED)
            end
            if not gDoorLocked then
                F_SetLoungeDoorsLocked(0, LOCKED)
            end
            waiting = nil
        end
    end
end

function F_DeleteSpawnedPreppies()
    for i, tblEntry in tblSpawnedPreppies do
        if tblEntry.id ~= nil and PedIsValid(tblEntry.id) and not PedIsInTrigger(tblEntry.id, TRIGGER._2_B_BOSS_FIGHT) then
            PedDelete(tblEntry.id)
        end
    end
end

function F_MonitorSpawnedPreppies()
    local i, tblEntry
    bPrepsAlive = true
    local gTimerForReturn = GetTimer()
    while bPrepsAlive do
        if intCurrentDoors <= 0 then
            bPrepsAlive = false
        end
        if gTimerForReturn and GetTimer() - gTimerForReturn > 5000 then
            gTimerForReturn = nil
            if PedIsValid(idDarby) and not PedIsDead(idDarby) then
                F_DarbyReturn()
            end
        end
        for i, tblEntry in tblSpawnedPreppies do
            if not tblEntry.KO then
                if PedIsDead(tblEntry.id) or 0 >= PedGetHealth(tblEntry.id) then
                    tblEntry.KO = true
                    intCurrentPreppies = intCurrentPreppies - 1
                    Wait(500)
                    tblEntry.id = nil
                elseif tblEntry.nextMoveTime and GetTimer() >= tblEntry.nextMoveTime and GetTimer() >= tblEntry.createTime + 4000 then
                    if not PedIsInTrigger(tblEntry.id, TRIGGER._2_B_BOSS_FIGHT) then
                        if PedIsInTrigger(tblEntry.id, TRIGGER._IBOXING_ESCDOORL) then
                            if AreaIsDoorLockedToPeds(TRIGGER._IBOXING_ESCDOORL) then
                                PedDelete(tblEntry.id)
                                tblEntry.KO = true
                                intCurrentPreppies = intCurrentPreppies - 1
                            end
                        elseif PedIsInTrigger(tblEntry.id, TRIGGER._IBOXING_ESCDOORL01) then
                            if AreaIsDoorLockedToPeds(TRIGGER._IBOXING_ESCDOORL01) then
                                PedDelete(tblEntry.id)
                                tblEntry.KO = true
                                intCurrentPreppies = intCurrentPreppies - 1
                            end
                        else
                            PedSetPosPoint(tblEntry.id, tblEntry.moveToPoint)
                            tblEntry.nextMoveTime = GetTimer() + 1000
                        end
                    else
                        --print("TELLING PREPPY TO ATTACK THE PLAYER <')))<", tblEntry.id)
                        PedClearObjectives(tblEntry.id)
                        PedAttackPlayer(tblEntry.id)
                        PedLockTarget(tblEntry.id, gPlayer)
                        tblEntry.nextMoveTime = false
                    end
                end
            end
        end
        if intCurrentPreppies <= 0 then
            bPrepsAlive = false
        end
        Wait(100)
    end
end

function F_SetupSpawnLocations()
    local i, tblEntry
    tblAvailableSpawnLocations = {}
    for i, tblEntry in tblPreppySpawnLocs do
        if tblEntry.valid then
            table.insert(tblAvailableSpawnLocations, tblEntry)
        end
    end
end

function F_GetSpawnLocation()
    local chosenPoint = RandomTableElement(tblAvailableSpawnLocations)
    if table.getn(tblAvailableSpawnLocations) > 1 then
        while chosenPoint.point == lastChosenPoint do
            chosenPoint = RandomTableElement(tblAvailableSpawnLocations)
        end
    end
    lastChosenPoint = chosenPoint.point
    return chosenPoint.point, chosenPoint.moveTo
end

function F_SpawnHealth(idPed)
    local chance = math.random(1, 100)
    local x, y, z
    if PlayerGetHealth() / PedGetMaxHealth(gPlayer) < 0.4 then
        chance = 100
    end
    if 50 <= chance then
        x, y, z = PedGetPosXYZ(idPed)
        PickupCreateXYZ(502, x, y, z)
    end
end

function F_CheckPed(idPed, bIsKO)
    if not bIsKO and (PedIsDead(idPed) or PedGetHealth(idPed) <= 0) then
        L_PedSetData(idPed, "ko", true)
        F_SpawnHealth(idPed)
    end
end

function PedExists(ped)
    return ped and PedIsValid(ped) and not (PedGetHealth(ped) <= 0)
end

function F_AttackIfClose(pedId)
    if PedExists(pedId) and (PlayerIsInAreaObject(pedId, 2, 7, 0) or PedIsHit(pedId, 2, 1000)) then
        PedAttackPlayer(pedId)
    end
end

function F_WrapperAttack(pedId)
    if PedExists(pedId) then
        PedAttackPlayer(pedId)
    end
end

function F_MonitorFirstPreps()
    local bMonitor = true
    local intDeadCount = 0
    while bMonitor do
        if not L_PedAllDead("first_wave") then
            L_PedExec("first_wave", F_CheckPed, "id", "ko")
        else
            if not othersAttacked then
                othersAttacked = true
                if not L_PedAllDead("boxing_ring") then
                    L_PedExec("boxing_ring", F_AttackIfClose, "id")
                end
            end
            intDeadCount = 1
        end
        if not L_PedAllDead("boxing_ring") then
            L_PedExec("boxing_ring", F_CheckPed, "id", "ko")
        else
            intDeadCount = intDeadCount + 1
        end
        if intDeadCount == 2 then
            bMonitor = false
        end
        Wait(100)
    end
    collectgarbage()
end

function F_SetLoungeDoorsLocked(doorSide, isLocked)
    if doorSide == 0 then
        --print("[RAUL] Setting Door Locked to Peds ", tostring(isLocked))
        AreaSetDoorLockedToPeds(TRIGGER._IBOXING_ESCDOORL, isLocked)
        AreaSetDoorPathableToPeds(TRIGGER._IBOXING_ESCDOORL, not isLocked)
        AreaSetDoorLockedToPeds(TRIGGER._IBOXING_ESCDOORR, isLocked)
        AreaSetDoorPathableToPeds(TRIGGER._IBOXING_ESCDOORR, not isLocked)
    elseif doorSide == 1 then
        --print("[RAUL] Setting Door 01 Locked to Peds ", tostring(isLocked))
        AreaSetDoorLockedToPeds(TRIGGER._IBOXING_ESCDOORL01, isLocked)
        AreaSetDoorPathableToPeds(TRIGGER._IBOXING_ESCDOORL01, not isLocked)
        AreaSetDoorLockedToPeds(TRIGGER._IBOXING_ESCDOORR01, isLocked)
        AreaSetDoorPathableToPeds(TRIGGER._IBOXING_ESCDOORR01, not isLocked)
    end
end

function F_BlockDoors()
    local i, tblEntry
    --print(" > > > > > > > > > > > > >[RAUL] Calling the blockdoor function")
    intCurrentDoors = intCurrentDoors - 1
    MAX_PREPPIES = MAX_PREPPIES - 1
    bHintNIS = false
    if intCurrentDoors <= 0 then
        bSpawnPreppies = false
        bPrepsAlive = false
        F_DeleteSpawnedPreppies()
        gDarbyLastReturn = true
        SoundPlayScriptedSpeechEvent(idDarby, "M_2_B", 14, "large")
        if PAnimIsPlaying(TRIGGER._DRBRACE, "/Global/DRBrace/Falling", false) then
            F_SetLoungeDoorsLocked(1, LOCKED)
            PAnimSetPulsateLight(TRIGGER._DRBRACE, false)
            gDoor01Locked = true
        elseif PAnimIsPlaying(TRIGGER._DRBRACE01, "/Global/DRBrace/Falling", false) then
            F_SetLoungeDoorsLocked(0, LOCKED)
            PAnimSetPulsateLight(TRIGGER._DRBRACE01, false)
            gDoorLocked = true
        end
    else
        TextQueue(-1, 1, 2)
        SoundPlayScriptedSpeechEvent(idDarby, "M_2_B", 12, "large")
        if PAnimIsPlaying(TRIGGER._DRBRACE, "/Global/DRBrace/Falling", false) then
            for i, tblEntry in tblPreppySpawnLocs do
                if tblEntry.prop == TRIGGER._DRBRACE then
                    tblEntry.valid = false
                end
            end
            F_SetLoungeDoorsLocked(1, LOCKED)
            PAnimSetPulsateLight(TRIGGER._DRBRACE, false)
            gDoor01Locked = true
        elseif PAnimIsPlaying(TRIGGER._DRBRACE01, "/Global/DRBrace/Falling", false) then
            for i, tblEntry in tblPreppySpawnLocs do
                if tblEntry.prop == TRIGGER._DRBRACE01 then
                    tblEntry.valid = false
                end
            end
            F_SetLoungeDoorsLocked(0, LOCKED)
            PAnimSetPulsateLight(TRIGGER._DRBRACE01, false)
            gDoorLocked = true
        end
    end
end

function F_RemoveDoor(tblProp)
    local i, tblEntry
    intCurrentDoors = intCurrentDoors - 1
    MAX_PREPPIES = MAX_PREPPIES - 1
    bHintNIS = false
    if intCurrentDoors <= 0 then
        bSpawnPreppies = false
        bPrepsAlive = false
        gDarbyLastReturn = true
        SoundPlayScriptedSpeechEvent(idDarby, "M_2_B", 14, "large")
        if tblProp.id == TRIGGER._DRBRACE then
            F_SetLoungeDoorsLocked(1, LOCKED)
        elseif tblProp.id == TRIGGER._DRBRACE01 then
            F_SetLoungeDoorsLocked(0, LOCKED)
        end
    else
        TextQueue(-1, 1, 2)
        SoundPlayScriptedSpeechEvent(idDarby, "M_2_B", 12, "large")
        for i, tblEntry in tblPreppySpawnLocs do
            if tblEntry.prop == tblProp.id then
                tblEntry.valid = false
            end
        end
        if tblProp.id == TRIGGER._DRBRACE then
            F_SetLoungeDoorsLocked(1, LOCKED)
        elseif tblProp.id == TRIGGER._DRBRACE01 then
            F_SetLoungeDoorsLocked(0, LOCKED)
        end
    end
end

function T_DoorChecker()
    while mission_running do
        if 2 <= intCurrentDoors then
            if PlayerIsInTrigger(TRIGGER._2_B_DRBRACE_DOOR01) then
                for i, tblEntry in tblPreppySpawnLocs do
                    if tblEntry.prop == TRIGGER._DRBRACE01 then
                        tblEntry.valid = false
                    end
                end
            elseif PlayerIsInTrigger(TRIGGER._2_B_DRBRACE_DOOR) then
                for i, tblEntry in tblPreppySpawnLocs do
                    if tblEntry.prop == TRIGGER._DRBRACE then
                        tblEntry.valid = false
                    end
                end
            else
                if not PAnimIsDestroyed(TRIGGER._DRBRACE01) then
                    for i, tblEntry in tblPreppySpawnLocs do
                        if tblEntry.prop == TRIGGER._DRBRACE01 then
                            tblEntry.valid = true
                        end
                    end
                end
                if not PAnimIsDestroyed(TRIGGER._DRBRACE) then
                    for i, tblEntry in tblPreppySpawnLocs do
                        if tblEntry.prop == TRIGGER._DRBRACE then
                            tblEntry.valid = true
                        end
                    end
                end
            end
        end
        Wait(0)
    end
end

function F_CreateDarby()
    idDarby = PedCreatePoint(37, POINTLIST._2_B_DARBY_START)
    PedSetFlag(idDarby, 58, true)
    PedSetAITree(idDarby, "/Global/DarbyAI", "Act/AI/AI_DARBY_2_B.act")
    PedSetActionTree(idDarby, "/Global/BOSS_Darby", "Act/Anim/BOSS_Darby.act")
    PedSetMaxHealth(idDarby, DARBY_MAX_HEALTH)
    PedSetHealth(idDarby, DARBY_MAX_HEALTH)
    PedOverrideStat(idDarby, 38, 50)
    PedOverrideStat(idDarby, 39, 50)
    PedSetInfiniteSprint(idDarby, true)
    PedSetDamageTakenMultiplier(idDarby, 0, 0.2)
    PedSetDamageTakenMultiplier(idDarby, 3, 0.2)
end

function F_DeletePed(idPed)
    if PedIsValid(idPed) and not PedIsDead(idPed) then
        PedDelete(idPed)
    end
end

function F_SecondaryAttack()
end

function F_SetupDarbyFight()
    if idDarbyBlip ~= nil then
        BlipRemove(idDarbyBlip)
        idDarbyBlip = nil
    end
    PedSetActionTree(idDarby, "/Global/BOSS_Darby", "Act/Anim/BOSS_Darby.act")
    PedShowHealthBar(idDarby, true, "2_B_10", true)
    PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORL)
    PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORR)
    PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORL01)
    PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORR01)
    AreaSetDoorLocked(TRIGGER._IBOXING_ESCDOORL, true)
    AreaSetDoorLocked(TRIGGER._IBOXING_ESCDOORL01, true)
    AreaSetDoorLocked(TRIGGER._IBOXING_ESCDOORR, true)
    AreaSetDoorLocked(TRIGGER._IBOXING_ESCDOORR01, true)
    gPrepIds = 1
    PAnimSetActionNode(TRIGGER._DRBRACE, "/Global/DRBrace/Useable", "Act/Props/DRBrace.act")
    PAnimSetActionNode(TRIGGER._DRBRACE01, "/Global/DRBrace/Useable", "Act/Props/DRBrace.act")
end

function F_PreparePreps(prepId)
    --print("---[RAUL] prepId ", prepId)
    if F_PedExists(prepId) then
        PedDelete(prepId)
    end
end

function F_ResetPreps(prepId)
    if PedExists(prepId) then
        PedIgnoreStimuli(prepId, false)
        PedSetPedToTypeAttitude(prepId, 13, 0)
        PedAttackPlayer(prepId)
    end
end

function F_CleanupDarby()
    if idDarby ~= nil and PedIsValid(idDarby) then
        PedSetFlag(idDarby, 58, false)
        idDarby = nil
    end
    if idDarbyBlip ~= nil then
        BlipRemove(idDarbyBlip)
        idDarbyBlip = nil
    end
    if bDarbyFightStarted then
    end
end

function F_GetPreppyModel()
    local idModel
    idModel = RandomTableElement(tblPreppyModels)
    while idModel == idPrevModel1 or idModel == idPrevModel2 or idModel == idPrevModel3 do
        idModel = RandomTableElement(tblPreppyModels)
    end
    idPrevModel3 = idPrevModel2
    idPrevModel2 = idPrevModel1
    idPrevModel1 = idModel
    return idModel
end

function F_CreatePreppies()
    L_PedLoadPoint("first_wave", {
        {
            model = 30,
            point = POINTLIST._2_B_PREP_02,
            ko = false
        },
        {
            model = 35,
            point = POINTLIST._2_B_PREP_03,
            ko = false
        }
    })
    L_PedLoadPoint("boxing_ring", {
        {
            model = 34,
            point = POINTLIST._2_B_PREP_06,
            ko = false
        },
        {
            model = 32,
            point = POINTLIST._2_B_PREP_10,
            ko = false
        }
    })
    idBiff = PedCreatePoint(133, POINTLIST._2_B_BIFF)
    PedSetCheap(idBiff, true)
    PedMakeTargetable(idBiff, false)
    PedSetInvulnerable(idBiff, true)
    PedIgnoreStimuli(idBiff, true)
    PedSetActionNode(idBiff, "/Global/2_B/BiffKO", "Act/Conv/2_B.act")
end

function F_CleanupPreppies()
end

function F_SetupTriggers()
    L_AddTrigger(nil, {
        trigger1 = {
            trigger = TRIGGER._2_B_BOSS_FIGHT_INTRO,
            OnEnter = F_BeginDarbyFight,
            ped = gPlayer,
            bTriggerOnlyOnce = true
        },
        trigger2 = {
            trigger = TRIGGER._2_B_SECOND_ATTACK,
            OnEnter = F_SecondaryAttack,
            ped = gPlayer,
            bTriggerOnlyOnce = true
        }
    })
end

function F_SetupProps()
    PAnimCreate(TRIGGER._DRBRACE)
    PAnimCreate(TRIGGER._DRBRACE01)
end

function F_PickupSpawn()
    while mission_started do
        if PlayerIsInTrigger(TRIGGER._2_B_BOSS_FIGHT) and intCurrentPreppies == 1 then
            for i, tblEntry in tblSpawnedPreppies do
                if (PedIsDead(tblEntry.id) or PedGetHealth(tblEntry.id) <= 0) and tblEntry.id ~= nil and gPleaseCreateSomeHealth then
                    --print("==create pickup==")
                    if PedIsValid(tblEntry.id) and not PedIsDead(tblEntry.id) then
                        PickupCreateFromPed(502, tblEntry.id, "HealthBute")
                    end
                    gPleaseCreateSomeHealth = false
                end
            end
        end
        Wait(0)
    end
    collectgarbage()
end

function CbDarbyRun(pedId, pathId, pathNode)
    --print("DARBY RUNNING", pathNode)
    if pathNode == 13 then
        PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORL)
        PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORL01)
        PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORR)
        PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORR01)
        gDoorsClosed = true
        gDarbyFinishedPath = true
    end
end

function main()
    MissionInit()
    while IsStreamingBusy() do
        Wait(0)
    end
    WeaponRequestModel(310)
    SoundPlayStream("MS_DishonorableFight.rsm", 0.7)
    if mission_started then
        tblPreppySpawnLocs = {
            {
                point = POINTLIST._2_B_DOOR01_PREP_SPAWN,
                moveTo = POINTLIST._2_B_DOOR01_PREP_MOVE,
                prop = TRIGGER._DRBRACE01,
                valid = true
            },
            {
                point = POINTLIST._2_B_DOOR02_PREP_SPAWN,
                moveTo = POINTLIST._2_B_DOOR02_PREP_MOVE,
                prop = TRIGGER._DRBRACE,
                valid = true
            }
        }
        PlayerSetControl(0)
        local plx, ply, plz = GetPointList(POINTLIST._2_B_PSTART)
        PlayerSetPosSimple(plx, ply, plz)
        F_CreateDarby()
        F_CreatePreppies()
        F_SetupTriggers()
        F_SetupProps()
        PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORL)
        PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORR)
        AreaSetDoorLocked(TRIGGER._IBOXING_ESCDOORL, false)
        AreaSetDoorLocked(TRIGGER._IBOXING_ESCDOORL01, false)
        AreaSetDoorLocked(TRIGGER._IBOXING_ESCDOORR, false)
        AreaSetDoorLocked(TRIGGER._IBOXING_ESCDOORR01, false)
        AreaSetDoorLocked(TRIGGER._DT_IBOXING_DOORL, true)
        AreaSetDoorLockedToPeds(TRIGGER._DT_IBOXING_DOORL, true)
        AreaSetDoorPathableToPeds(TRIGGER._DT_IBOXING_DOORL, false)
        PickupSetIgnoreRespawnDistance(true)
        intCurrentDoors = ACTIVE_DOORS
        PlayerSetPosSimple(plx, ply, plz)
        PlayerFaceHeadingNow(-172.3)
        CameraSetXYZ(-715.23865, 369.97644, 297.38385, -714.30035, 370.23477, 297.15408)
        Wait(500)
        AreaClearAllPeds()
        CameraFade(500, 1)
        CameraSetWidescreen(true)
        Wait(500)
        PedSetActionNode(gPlayer, "/Global/WProps/PropInteract", "Act/WProps.act")
        if not IsMissionFromRestart() then
            SoundPlayScriptedSpeechEvent(idDarby, "M_2_B", 1, "large")
            PedFollowPath(idDarby, PATH._2_B_DARBY_FLEE, 0, 2, CbDarbyRun)
            PedSetInfiniteSprint(idDarby, true)
            idDarbyBlip = AddBlipForChar(idDarby, 5, 0, 1)
        else
            F_MoveDarbyToLounge()
        end
        Wait(100)
        local pGord = L_PedGetIDByIndex("first_wave", 2)
        PedAttackPlayer(pGord)
        Wait(200)
        L_PedExec("first_wave", PedAttackPlayer, "id")
        --print("====gord is trying to grapple====")
        PedStop(pGord)
        PedClearObjectives(pGord)
        --print("====gord is done grapple====")
        Wait(1500)
        TextPrint("2_B_11", 4, 1)
        MissionObjectiveAdd("2_B_11", 0, -1)
        CameraSetWidescreen(false)
        CameraReturnToPlayer(false)
        PlayerSetControl(1)
        L_PedExec("first_wave", PedSetPedToTypeAttitude, "id", 13, 0)
        L_PedExec("boxing_ring", PedSetPedToTypeAttitude, "id", 13, 0)
        L_PedExec("first_wave", PedAttackPlayer, "id")
        CreateThread("TextQueueThread")
        CreateThread("T_ObjectiveMonitor")
        CreateThread("L_MonitorTriggers")
        CreateThread("F_PickupSpawn")
        CreateThread("F_MonitorFirstPreps")
        mission_running = true
        CreateThread("T_DoorChecker")
        Wait(100)
        while not L_ObjectiveProcessingDone() do
            if gDarbyFinishedPath then
                gDarbyFinishedPath = nil
                Wait(100)
                F_DarbyRest(true)
            end
            if bDarbyFightStarted and not gPlayerFailed then
                if not gPlayerKnockedOut and PedIsPlaying(gPlayer, "/Global/HitTree/Standing/PostHit/BellyUp", true) then
                    if not bDarbyAtRest and not bPrepsAlive and bSpawnPreppies then
                        gPlayerKnockedOut = true
                        PedSetActionNode(gPlayer, "/Global/2_B/PlayerOnGround/BellyUp", "Act/Conv/2_B.act")
                    end
                else
                    gPlayerKnockedOut = false
                end
                if bDarbyAtRest and GetTimer() - gDarbyRestingTime > gDarbyCheerDelay then
                    gDarbyRestingTime = GetTimer()
                    SoundPlayScriptedSpeechEvent(idDarby, "M_2_B", 11, "large")
                    gCurrentCheer = gCurrentCheer + 1
                    if gCurrentCheer > table.getn(gDarbyCheer) then
                        gCurrentCheer = 1
                    end
                end
            end
            Wait(100)
        end
        mission_running = false
        mission_started = false
        L_StopMonitoringTriggers()
    end
end

function F_IsMission()
    return 1
end

function T_DebugController()
    Wait(100)
    while mission_running do
        if IsButtonPressed(11, 0) then
            --print("==turing off targetting==")
            PAnimMakeTargetable(TRIGGER._DRBRACE, false)
            PAnimMakeTargetable(TRIGGER._DRBRACE01, false)
        elseif IsButtonPressed(13, 0) then
            --print("==turing on targetting==")
            PAnimMakeTargetable(TRIGGER._DRBRACE, true)
            PAnimMakeTargetable(TRIGGER._DRBRACE01, true)
        end
    end
end

function F_DodgeCondition()
    if bDarbyAtRest then
        return 1
    else
        return 0
    end
end

local gTextQueue = {}
local gTextQueueTimer = 0
local gTextWaitTimer = 0
local gStartPrinting = false

function TextQueueThread()
    while mission_running do
        CheckTextQueue()
        Wait(0)
    end
    collectgarbage()
end

function TextQueue(val, tTime, style, isText, priority)
    if table.getn(gTextQueue) <= 0 then
        gStartPrinting = true
    end
    if priority then
        table.insert(gTextQueue, 1, {
            textVal = val,
            textTime = tTime * 1000,
            bText = isText,
            tStyle = style
        })
    else
        table.insert(gTextQueue, {
            textVal = val,
            textTime = tTime * 1000,
            bText = isText,
            tStyle = style
        })
    end
end

function ClearTextQueue()
    gTextQueue = {}
end

function CheckTextQueue()
    if table.getn(gTextQueue) > 0 then
        if gStartPrinting then
            gTextQueueTimer = GetTimer()
            gTextWaitTimer = gTextQueue[1].textTime
            if gTextQueue[1].textVal ~= -1 then
                if gTextQueue[1].bText then
                    TextPrintString(gTextQueue[1].textVal, gTextQueue[1].textTime / 1000, gTextQueue[1].tStyle)
                else
                    TextPrint(gTextQueue[1].textVal, gTextQueue[1].textTime / 1000, gTextQueue[1].tStyle)
                end
            end
            gStartPrinting = false
        end
        if GetTimer() - gTextQueueTimer >= gTextWaitTimer then
            gStartPrinting = true
            local tempBool = false
            table.remove(gTextQueue, 1)
        end
    end
end

function MissionInit()
    LoadActionTree("Act/Conv/2_B.act")
    LoadActionTree("Act/Anim/BOSS_Darby.act")
    LoadActionTree("Act/Props/DRBrace.act")
    ClothingSetPlayerOutfit("Boxing NG")
    ClothingBuildPlayer()
    if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
        PlayerSetHealth(PedGetMaxHealth(gPlayer))
    end
    PedSetFlag(gPlayer, 58, true)
    PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORL)
    PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORR)
    PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORL01)
    PAnimCloseDoor(TRIGGER._IBOXING_ESCDOORR01)
    AreaTransitionPoint(27, POINTLIST._2_B_PSTART, nil, true)
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    DisablePOI(true, true)
    AreaClearAllPeds()
    L_ObjectiveSetParam({
        objStayAlive = {
            failureConditions = { F_MonitorHealth },
            stopOnFailed = true,
            failActions = { F_FailMission }
        },
        objDefeatDarby = {
            successConditions = { F_DarbyDead },
            stopOnCompleted = true,
            stopOnFailed = false,
            completeActions = { F_CompleteMission }
        },
        objOpenDoor = {
            successConditions = { F_OpenDoor },
            stopOnCompleted = false,
            stopOnFailed = false,
            completeActions = { F_BeginDarbyFight }
        }
    })
    LoadAnimationGroup("N2B Dishonerable")
    LoadAnimationGroup("NIS_2_B")
    LoadAnimationGroup("Boxing")
    LoadModels({
        30,
        133,
        35,
        32,
        34,
        40
    })
    PedSetTypeToTypeAttitude(5, 13, 2)
    WeaponRequestModel(327)
    WeaponRequestModel(310)
    WeaponRequestModel(502)
    mission_started = true
    PedSaveWeaponInventorySnapshot(gPlayer)
end

function MissionSetup()
    MissionDontFadeIn()
    MissionDontFadeInAfterCompetion()
    L_PlayerClothingBackup()
    ClothingSetPlayerOutfit("Boxing")
    ClothingBuildPlayer()
    DATLoad("2_B.DAT", 2)
    DisablePunishmentSystem(true)
    DATInit()
end

function MissionCleanup()
    UnLoadAnimationGroup("N2B Dishonerable")
    UnLoadAnimationGroup("NIS_2_B")
    UnLoadAnimationGroup("Boxing")
    DisablePunishmentSystem(false)
    gDarbyFightBegun = false
    local i, tblEntry
    F_CleanupDarby()
    F_CleanupPreppies()
    if gFirstImmortalPrep and PedIsValid(gFirstImmortalPrep) then
        --print("[RAUL] Making the first ped mortal")
        PedSetFlag(gFirstImmortalPrep, 58, false)
        PedDelete(gFirstImmortalPrep)
    end
    if gSecondImmortalPrep and PedIsValid(gSecondImmortalPrep) then
        --print("[RAUL] Making the second ped mortal")
        PedSetFlag(gSecondImmortalPrep, 58, false)
        PedDelete(gSecondImmortalPrep)
    end
    if idEndBlip ~= nil then
        BlipRemove(idEndBlip)
        idEndBlip = nil
    end
    PedSetFlag(gPlayer, 58, false)
    PedSetTypeToTypeAttitude(5, 13, oldAttitude)
    WeaponRequestModel(327)
    ConversationMovePeds(true)
    SoundFadeoutStream()
    RadarSetVisibility(true)
    DetentionMeterSetVisibility(true)
    PickupSetIgnoreRespawnDistance(false)
    for i, tblEntry in tblSpawnedPreppies do
        if tblEntry.id ~= nil then
        end
    end
    AreaSetDoorLocked("IBOXING_ESCDOORL", false)
    AreaSetDoorLocked("IBOXING_ESCDOORL01", false)
    AreaSetDoorLocked("IBOXING_ESCDOORR", false)
    AreaSetDoorLocked("IBOXING_ESCDOORR01", false)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORL)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORL01)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORR)
    PAnimOpenDoor(TRIGGER._IBOXING_ESCDOORR01)
    F_SetLoungeDoorsLocked(1, UNLOCKED)
    F_SetLoungeDoorsLocked(0, UNLOCKED)
    AreaSetDoorLocked("DT_IBOXING_DOORL", false)
    AreaSetDoorLockedToPeds("DT_IBOXING_DOORL", false)
    AreaSetDoorPathableToPeds(TRIGGER._DT_IBOXING_DOORL, true)
    PAnimDelete(TRIGGER._DRBRACE)
    PAnimDelete(TRIGGER._DRBRACE01)
    AreaRevertToDefaultPopulation()
    EnablePOI()
    L_PlayerClothingRestore()
    DATUnload(2)
    DATInit()
    mission_started = false
end
