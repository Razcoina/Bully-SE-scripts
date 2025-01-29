local bBigPrank = false
local bCreatePrank = false
local bShitTheBed = false
local bLoadAfterCurrentCompletion = false
local objMission = -1
local PrankToCreate = 1
local gNextPrank = -1
local tblPrank = {}
local gCurrentInitStage
local bGiveWeapon = false
local bCompletedPranks = false
local RoguePed = -1
local bRoguePrank = false
local pedbool = false
local bPrankRubbedOut = false
local prankCount = 0
local gRat01 = -1
local gRat02 = -1
local gBlipRat01 = 0
local gBlipRat02 = 0
local tblPeds = {
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1
}
local tblCE = {
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1
}
local bDeadRatGreet = false
local bDeadRatGoal = false
local bDeadRatReward = false
local tblRatPeds = {
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1
}
local tblEggPeds = {
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1
}
local tblDeadPool = {
    -1,
    -1,
    -1
}
local girlsHit = 3
local bPedbool = false
local bRatSlapped = false
local bMoreRats = false
local bAlreadyHit = false
local gRattedPed = -1
local bHitByRat = false
local bEggManGreet = false
local bEggManGoal = false
local bEggManReward = false
local bOutOfAmmo = false
local bPedbool = false
local bEgged = false
local peopleEgged = 3
local bHitByEgg = false
local gEggedPed = -1
local bLitFountain = false
local bF4000Greet = false
local bF4000Goal = false
local bF4000Reward = false
local bDroppedIt = false
local bF4000ed = false
local gLitTime = 0
local gDropTime = 0
local bFirecrackerGreet = false
local bFirecrackerGoal = false
local bFirecrackerReward = false
local bFirecracked = false
local bHitByFirecracker = true
local gFirecrackerPed = -1
local crackerHit = 3
local bItchPowderGreet = false
local bItchPowderGoal = false
local bItchPowderReward = false
local bItched = false
local peopleItched = 3
local bHitByItchPowder = false
local gItchPowderPed = -1
local bKickMeGreet = false
local bKickMeGoal = false
local bKickMeReward = false
local bNoteStuckOn = false
local bMarblesGreet = false
local bMarblesGoal = false
local bMarblesReward = false
local bMarbled = false
local bHitByMarbles = false
local gMarblesPed = -1
local peopleMarbled = 3
local bStinkBombGreet = false
local bStinkBombGoal = false
local bStinkBombReward = false
local bStunk = false
local bHitByStink = false
local gStinkPed = -1
local peopleStunk = 3
local bActivePrank = false
local bPassedMission = false
local bPrankCompleted = false
local tblBmodels = {
    85,
    99,
    102,
    145,
    146,
    147,
    170
}

function MissionSetup()
    MissionDontFadeIn()
    DATLoad("1_11XP.DAT", 2)
    DATInit()
    SoundPlayInteractiveStream("MS_HalloweenLow.rsm", 0.5)
    SoundSetMidIntensityStream("MS_HalloweenMid.rsm", 0.6)
    SoundSetHighIntensityStream("MS_HalloweenHigh.rsm", 1)
    PedSetUniqueModelStatus(159, 2)
end

function MissionCleanup()
    CameraSetWidescreen(false)
    SoundStopInteractiveStream()
    PedResetTypeAttitudesToDefault()
    if not bPassedMission then
        if shared.gPetey and PedIsValid(shared.gPetey) then
            PedDelete(shared.gPetey)
        end
        if shared.gGary and PedIsValid(shared.gGary) then
            PedDelete(shared.gGary)
        end
    else
        if shared.gPetey and PedIsValid(shared.gPetey) then
            PedMakeAmbient(shared.gPetey)
        end
        if shared.gGary and PedIsValid(shared.gGary) then
            PedMakeAmbient(shared.gGary)
        end
    end
    for p, prank in tblPrank do
        if PedIsValid(prank.id) then
            F_MakePedSafe(prank.id, false)
            PedMakeAmbient(prank.id)
        end
    end
    if bCompletedPranks then
        UnpauseGameClock()
    end
    CounterClearText()
    CounterMakeHUDVisible(false)
    WeatherRelease()
    DATUnload(2)
    PunishersRespondToPlayerOnly(false)
end

function main()
    AreaTransitionPoint(0, POINTLIST._1_11XP_PLAYERSTART, 1, false)
    F_MissionSetup()
    AreaDisableAllPatrolPaths()
    CameraFade(1000, 1)
    TextPrint("1_11_XP_OBJ", 5, 1)
    objMission = MissionObjectiveAdd("1_11_XP_OBJ")
    CounterSetText("1_11_XP_COUNTER")
    CounterMakeHUDVisible(true)
    CounterSetCurrent(0)
    CounterSetMax(5)
    while MissionActive() do
        F_CreatePrank()
        if tblPrank[1].bLoaded then
            F_DeadRat()
        end
        if tblPrank[2].bLoaded then
            F_EggMan()
        end
        if tblPrank[3].bLoaded then
            F_F4000()
        end
        if tblPrank[4].bLoaded then
            F_Firecracker()
        end
        if tblPrank[5].bLoaded then
            F_ItchPowder()
        end
        if tblPrank[6].bLoaded then
            F_KickMe()
        end
        if tblPrank[7].bLoaded then
            F_Marbles()
        end
        if tblPrank[8].bLoaded then
            F_StinkBomb()
        end
        if F_FiveDone() then
            MissionObjectiveComplete(objMission)
            break
        end
        Wait(0)
    end
    CameraSetWidescreen(true)
    MinigameSetCompletion("M_PASS", true, 0, "1_11_XP_UNLOCK")
    while MinigameIsShowingCompletion() do
        Wait(0)
    end
    bPassedMission = true
    MissionSucceed(false, false, false)
end

function F_FiveDone()
    local totalDone = 0
    for p, prank in tblPrank do
        if prank.bComplete then
            totalDone = totalDone + 1
        end
    end
    if 7 <= totalDone then
        bCompletedPranks = true
        return true
    else
        return false
    end
end

function F_CheckForActivePranks()
    bActivePrank = false
    for p, prank in tblPrank do
        if prank.bLoaded and prank.bActive then
            bActivePrank = true
            break
        end
    end
end

function F_CreatePrank()
    if bCreatePrank or bLoadAfterCurrentCompletion and not tblPrank[PrankToCreate].bActive then
        if bCreatePrank then
            bCreatePrank = false
        elseif bLoadAfterCurrentCompletion then
            bLoadAfterCurrentCompletion = false
            PrankToCreate = gNextPrank
        end
        prank = tblPrank[PrankToCreate]
        if not prank.bComplete and not bActivePrank then
            BlipRemove(prank.blip)
            prank.id = PedCreatePoint(prank.model, prank.point, 1)
            PedClearAllWeapons(prank.id)
            if not PedIsValid(prank.id) then
                prank.id = PedCreatePoint(prank.model, prank.point, 1)
                PedClearAllWeapons(prank.id)
            end
            PedSetFlag(prank.id, 110, true)
            PedSetFlag(prank.id, 108, true)
            PedMakeMissionChar(prank.id)
            PedSetPedToTypeAttitude(prank.id, 13, 2)
            PlayerSocialDisableActionAgainstPed(prank.id, 23, true)
            PlayerSocialDisableActionAgainstPed(prank.id, 28, true)
            PlayerSocialDisableActionAgainstPed(prank.id, 29, true)
            prank.blip = AddBlipForChar(prank.id, 6, 1, 4)
            prank.bLoaded = true
            prank.bOnDeck = false
            prank.func()
            PedMoveToObject(prank.id, gPlayer, 2, 1, nil, 2.5)
        end
    elseif tblPrank[PrankToCreate].bOnDeck and PlayerIsInTrigger(tblPrank[PrankToCreate].trigger) then
        local pedAlready = PedGetPedCountWithModel(tblPrank[PrankToCreate].model)
        if pedAlready == 0 then
            tblPrank[PrankToCreate].id = PedCreatePoint(tblPrank[PrankToCreate].model, tblPrank[PrankToCreate].point, 1)
            PedClearAllWeapons(tblPrank[PrankToCreate].id)
            PedSetPedToTypeAttitude(tblPrank[PrankToCreate].id, 13, 2)
            tblPrank[PrankToCreate].bOnDeck = false
        else
            tblPrank[PrankToCreate].bOnDeck = false
        end
    end
end

function F_LoadPrank(trigger)
    F_CheckForActivePranks()
    if not bActivePrank then
        for p, prank in tblPrank do
            if prank.trigger == trigger then
                if not prank.bLoaded and prank.time <= GetTimer() and not prank.bComplete then
                    bCreatePrank = true
                    PrankToCreate = p
                end
                break
            end
        end
    else
        for p, prank in tblPrank do
            if prank.trigger == trigger then
                if not prank.bComplete then
                    prank.bOnDeck = true
                    bLoadAfterCurrentCompletion = true
                    gNextPrank = p
                end
                break
            end
        end
    end
end

function F_UnLoadPrank(trigger)
    for p, prank in tblPrank do
        if prank.trigger == trigger then
            if prank.bLoaded and not prank.bActive then
                if PedIsValid(prank.id) then
                    if PedCanSeeObject(gPlayer, prank.id, 2) then
                        PedMakeAmbient(prank.id)
                    else
                        --print("==== Prank is not active and the player cannot see prank.id so DELETE ===")
                        PedDelete(prank.id)
                    end
                end
                BlipRemove(prank.blip)
                prank.bLoaded = false
                prank.blip = BlipAddPoint(prank.point, 1)
            end
            break
        end
    end
end

function F_DeleteRougePrank()
    if bRoguePrank then
        if PedIsValid(RoguePed) then
            if not PedCanSeeObject(gPlayer, RoguePed, 2) then
                --print("======== Deleted a Rogue Prank! ======")
                PedDelete(RoguePed)
                RoguePed = -1
                bRoguePrank = false
            else
                PedMakeAmbient(RoguePed)
            end
        else
            RoguePed = -1
            bRoguePrank = false
        end
    end
end

function F_RemoveOtherBlips()
    for p, prank in tblPrank do
        BlipRemove(prank.blip)
    end
end

function F_PrankCleanup(tbl)
    if not bOutOfAmmo then
        BlipRemoveFromChar(tbl.id)
        DoSocialErrands(false)
        RegisterGlobalEventHandler(7, nil)
        if PedIsValid(tbl.id) then
            F_MakePedSafe(tbl.id, false)
            PedMakeAmbient(tbl.id, false)
            PedClearPOI(tbl.id)
            PedSetPedToTypeAttitude(tbl.id, 13, 3)
            PedWander(tbl.id, 1)
            PedSetFlag(tbl.id, 110, false)
        end
        tbl.bActive = false
        tbl.bLoaded = false
        bActivePrank = false
        for p, prank in tblPrank do
            BlipRemove(prank.blip)
            if not prank.bComplete then
                prank.blip = BlipAddPoint(prank.point, 1)
            end
        end
    else
        DoSocialErrands(false)
        bOutOfAmmo = false
        tbl.bActive = false
        if PedIsValid(tbl.id) then
            F_MakePedSafe(tbl.id, false)
            BlipRemove(tbl.blip)
            PedSetFlag(tbl.id, 110, false)
            PedClearPOI(tbl.id)
            PedSetFlag(tbl.id, 110, true)
            tbl.blip = AddBlipForChar(tbl.id, 6, 1, 4)
            PedMoveToObject(tbl.id, gPlayer, 2, 1, nil, 2.5)
            gCurrentInitStage()
        else
            BlipRemove(tbl.blip)
            RegisterGlobalEventHandler(7, nil)
            tbl.bActive = false
            tbl.bLoaded = false
            bActivePrank = false
            for p, prank in tblPrank do
                BlipRemove(prank.blip)
                if not prank.bComplete then
                    prank.blip = BlipAddPoint(prank.point, 1)
                end
            end
        end
    end
end

function F_PrankVaild(tbl)
    if PedIsValid(tbl.id) then
        if not (not F_PedIsDead(tbl.id) and (not PedIsInCombat(tbl.id) or bPrankCompleted or tbl.bActive)) or PedGetWhoHitMeLast(tbl.id) == gPlayer and not tbl.bActive then
            bPrankRubbedOut = true
            DoSocialErrands(false)
            if tbl.bActive then
                --print("==== Invalid and Active ====")
                MinigameSetErrandCompletion(-1, "AS_PFAIL", false)
            end
            return false
        end
        if not tbl.bActive and PedIsInCombat(tbl.id) then
            --print("==== Invalid and Not Active and in combat ====")
            BlipRemoveFromChar(tbl.id)
            bShitTheBed = true
        end
        return true
    else
        if tbl.bActive then
            --print("==== Ped Not Valid and Prank is no Valid ====")
            DoSocialErrands(false)
            MinigameSetErrandCompletion(-1, "AS_PFAIL", false)
        end
        return false
    end
end

function F_MakePedSafe(ped, bool)
    --print("=========  F_MakePedSafe ===", ped, tostring(bool))
    PedSetStationary(ped, bool)
    PedIgnoreAttacks(ped, bool)
    PedIgnoreStimuli(ped, bool)
    PedSetInvulnerable(ped, bool)
end

function F_PedIsBully(ped)
    return false
end

function F_DeadRatInit()
    DoSocialErrands(false, "AS_RA_OBJCOUNT1", 1)
    bDeadRatGreet = false
    bDeadRatGoal = false
    bDeadRatReward = false
    girlsHit = 1
    bRatSlapped = false
    bMoreRats = false
    bAlreadyHit = false
    gRattedPed = -1
    bHitByRat = false
    bPrankCompleted = false
    for d, dead in tblDeadPool do
        dead = -1
    end
    gCurrentInitStage = F_DeadRatInit
end

function F_DeadRat()
    if tblPrank[1].bLoaded then
        if F_PrankVaild(tblPrank[1]) then
            if not bDeadRatGreet then
                bDeadRatGreet = F_DeadRatOnDialog()
            elseif not bDeadRatGoal then
                bDeadRatGoal = F_DeadRatMissionSpecificCheck()
            elseif not bDeadRatReward then
                bDeadRatReward = F_DeadRatsObjectiveMet()
            else
                F_PrankCleanup(tblPrank[1])
            end
        else
            F_PrankCleanup(tblPrank[1])
        end
    else
        F_PrankCleanup(tblPrank[1])
    end
end

function F_ScenarioRats(rats)
    local x, y, z = PedGetPosXYZ(tblPrank[1].id)
    gRat01 = PedCreateXYZ(136, x, y + 1, z + 1)
    gBlipRat01 = AddBlipForChar(gRat01, 0, 1, 4)
    gRat02 = PedCreateXYZ(136, x, y - 1, z + 1)
    gBlipRa02 = AddBlipForChar(gRat02, 0, 1, 4)
end

function F_DeadRatOnDialog()
    if PedIsDoingTask(tblPrank[1].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        DoSocialErrands(true, "AS_RA_OBJCOUNT1", girlsHit)
        F_RemoveOtherBlips()
        RegisterGlobalEventHandler(7, nil)
        RegisterGlobalEventHandler(7, F_DeadRatHit)
        tblPrank[1].bActive = true
        TutorialStart("GirlRats")
        F_ScenarioRats(2)
        return true
    else
        return false
    end
end

function F_DeadRatHit(pedID)
    if PedIsDoingTask(pedID, "/Global/AI/Reactions/Stimuli/DeadRat", true) or PedGetLastHitWeapon(pedID) == 346 and PedGetWhoHitMeLast(pedID) == gPlayer and PedIsFemale(pedID) then
        bHitByRat = true
        gRattedPed = pedID
    end
end

function F_DeadRatMissionSpecificCheck()
    if not bPickedUpRat and PlayerHasWeapon(346) then
        BlipRemove(gBlipRat01)
        BlipRemove(gBlipRat02)
        bPickedUpRat = true
    end
    if bHitByRat then
        bRatSlapped = false
        for v, vic in tblDeadPool do
            if vic == gRattedPed then
                bHitByRat = false
                break
            end
        end
        if bHitByRat then
            girlsHit = girlsHit - 1
            if 1 < girlsHit or girlsHit == 0 then
                DoSocialErrands(true, "AS_RA_OBJCOUNT", girlsHit)
            else
                DoSocialErrands(true, "AS_RA_OBJCOUNT1", girlsHit)
            end
            bHitByRat = false
            bRatSlapped = true
            for v, vic in tblDeadPool do
                if vic == -1 then
                    tblDeadPool[v] = gRattedPed
                    break
                end
            end
        end
    end
    if bRatSlapped then
        if girlsHit == 0 then
            return true
        else
            return false
        end
    else
        return false
    end
end

function F_DeadRatsObjectiveMet()
    if bRatSlapped then
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PCOMPLETE", true)
        tblPrank[1].bComplete = true
        tblPrank[1].time = GetTimer() + 15000
        PedSetTaskNode(tblPrank[1].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[1].id)
        prankCount = prankCount + 1
        CounterSetCurrent(prankCount)
        return true
    else
        return false
    end
end

function F_EggManInit()
    DoSocialErrands(false, "AS_EM_OBJECTIVE")
    bEggManGreet = false
    bEggManAccept = false
    bEggManGoal = false
    bEggManReward = false
    bOutOfAmmo = false
    bPedbool = false
    bEgged = false
    tblEggPeds = {
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1,
        -1
    }
    peopleEgged = 3
    bHitByEgg = false
    bGoGetAmmo = false
    gEggedPed = -1
    bEggTimer = 0
    bPrankCompleted = false
    for d, dead in tblDeadPool do
        dead = -1
    end
    gCurrentInitStage = F_EggManInit
end

function F_EggMan()
    if tblPrank[2].bLoaded then
        if F_PrankVaild(tblPrank[2]) then
            if not bEggManGreet then
                bEggManGreet = F_EggManOnDialog()
            elseif not bEggManAccept then
                bEggManAccept = F_EggManAccept()
            elseif not bEggManGoal then
                bEggManGoal = F_EggManMissionSpecificCheck()
            elseif not bEggManReward then
                bEggManReward = F_EggManObjectiveMet()
            else
                F_PrankCleanup(tblPrank[2])
            end
        else
            F_PrankCleanup(tblPrank[2])
        end
    else
        F_PrankCleanup(tblPrank[2])
    end
end

function F_EggManOnDialog()
    if PedIsDoingTask(tblPrank[2].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        SoundPlayAmbientSpeechEvent(tblPrank[2].id, "HELP_EXPLANATION")
        return true
    else
        return false
    end
end

function F_EggManAccept()
    if PedIsDoingTask(tblPrank[2].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted", true) == true then
        PlayerSetControl(0)
        PedSetActionNode(tblPrank[2].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        PedSetWeapon(gPlayer, 312, 6)
        F_MakePedSafe(tblPrank[2].id, true)
        DoSocialErrands(true, "AS_EM_OBJECTIVE")
        PlayerSetControl(1)
        F_RemoveOtherBlips()
        RegisterGlobalEventHandler(7, nil)
        RegisterGlobalEventHandler(7, F_EggHit)
        peopleEgged = 3
        tblPrank[2].bActive = true
        return true
    else
        return false
    end
end

function F_EggHit(pedID)
    local bDog = false
    if PedIsModel(pedID, 219) or PedIsModel(pedID, 220) then
        bDog = true
    else
        bDog = false
    end
    if not bDog and PedGetLastHitWeapon(pedID) == 312 and PedGetWhoHitMeLast(pedID) == gPlayer then
        bHitByEgg = true
        PedStop(pedID)
        PedOverrideStat(pedID, 6, 100)
        PedOverrideStat(pedID, 7, 100)
        PedOverrideStat(pedID, 14, 10)
        PedFlee(pedID, gPlayer)
        gEggedPed = pedID
    end
end

function F_EggManMissionSpecificCheck()
    bEgged = false
    if bHitByEgg then
        for v, vic in tblDeadPool do
            if vic == gEggedPed then
                bHitByEgg = false
                break
            end
        end
        if bHitByEgg then
            peopleEgged = peopleEgged - 1
            if peopleEgged ~= 0 then
                if 1 < peopleEgged or peopleEgged == 0 then
                    DoSocialErrands(true, "AS_EM_OBJCOUNT", peopleEgged)
                else
                    DoSocialErrands(true, "AS_EM_OBJCOUNT1", peopleEgged)
                end
            end
            bHitByEgg = false
            bEgged = true
            for v, vic in tblDeadPool do
                if vic == -1 then
                    tblDeadPool[v] = gEggedPed
                    break
                end
            end
        end
    end
    if bEgged then
        if peopleEgged == 0 then
            bPrankCompleted = true
            bOutOfAmmo = false
            return true
        else
            return false
        end
    else
        if PedGetAmmoCount(gPlayer, 312) == 0 and not bOutOfAmmo then
            bEggTimer = GetTimer()
            bOutOfAmmo = true
        elseif bOutOfAmmo and GetTimer() >= bEggTimer + 5000 and not bGoGetAmmo then
            tblPrank[2].blip = AddBlipForChar(tblPrank[2].id, 6, 1, 4)
            bGoGetAmmo = true
            DoSocialErrands(true, "AS_EM_AMMO")
        elseif bOutOfAmmo then
            if PedGetAmmoCount(gPlayer, 312) == 0 and PlayerIsInAreaObject(tblPrank[2].id, 2, 1, 0) and IsButtonPressed(7, 0) and IsButtonPressed(10, 0) and bGiveWeapon then
                PedSetActionNode(tblPrank[2].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
                Wait(1000)
                PedSetWeapon(gPlayer, 312, 6)
                bGiveWeapon = false
                bOutOfAmmo = false
                bGoGetAmmo = false
                BlipRemove(tblPrank[2].blip)
                if 1 < peopleEgged or peopleEgged == 0 then
                    DoSocialErrands(true, "AS_EM_OBJCOUNT", peopleEgged)
                else
                    DoSocialErrands(true, "AS_EM_OBJCOUNT1", peopleEgged)
                end
            end
            if not IsButtonPressed(7, 0) and not IsButtonPressed(10, 0) and not bGiveWeapon then
                bGiveWeapon = true
            end
        end
        return false
    end
end

function F_EggManObjectiveMet()
    if bEgged then
        Wait(1000)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PCOMPLETE", true)
        tblPrank[2].time = GetTimer() + 60000
        tblPrank[2].bComplete = true
        PedSetTaskNode(tblPrank[2].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[2].id)
        prankCount = prankCount + 1
        CounterSetCurrent(prankCount)
        bOutOfAmmo = false
        return true
    else
        return false
    end
end

function F_F4000Init()
    DoSocialErrands(false, "AS_F4_OBJECTIVE")
    bLitFountain = false
    bDroppedIt = false
    bF4000ed = false
    bF4000Greet = false
    bF4000Accept = false
    bF4000Goal = false
    bF4000Reward = false
    gLitTime = 0
    gDropTime = 0
    bPrankCompleted = false
    bOutOfAmmo = false
    gCurrentInitStage = F_F4000Init
end

function F_F4000()
    if tblPrank[3].bLoaded then
        if F_PrankVaild(tblPrank[3]) then
            if not bF4000Greet then
                bF4000Greet = F_F4000OnDialog()
            elseif not bF4000Accept then
                bF4000Accept = F_F4000Accept()
            elseif not bF4000Goal then
                bF4000Goal = F_F4000MissionSpecificCheck()
            elseif not bF4000Reward then
                bF4000Reward = F_F4000ObjectiveMet()
            else
                F_PrankCleanup(tblPrank[3])
            end
        else
            F_PrankCleanup(tblPrank[3])
        end
    else
        F_PrankCleanup(tblPrank[3])
    end
end

function F_F4000OnDialog()
    if PedIsDoingTask(tblPrank[3].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        SoundPlayAmbientSpeechEvent(tblPrank[3].id, "HELP_EXPLANATION")
        return true
    else
        return false
    end
end

function F_F4000Accept()
    if PedIsDoingTask(tblPrank[3].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted", true) == true then
        PlayerSetControl(0)
        PedSetActionNode(tblPrank[3].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        while not WeaponRequestModel(397) do
            Wait(0)
        end
        PedSetWeapon(gPlayer, 397, 1)
        F_MakePedSafe(tblPrank[3].id, true)
        PlayerSetControl(1)
        F_RemoveOtherBlips()
        DoSocialErrands(true, "AS_F4_OBJECTIVE")
        RegisterGlobalEventHandler(7, nil)
        RegisterGlobalEventHandler(7, F_F4000Hit)
        tblPrank[3].bActive = true
        Wait(1000)
        return true
    else
        return false
    end
end

function F_F4000Hit(pedID)
    if PedGetLastHitWeapon(pedID) == 397 and PedGetWhoHitMeLast(pedID) == gPlayer then
        bF4000ed = true
    end
end

function F_F4000MissionSpecificCheck()
    if not bLitFountain and PedIsPlaying(gPlayer, "/Global/Weapons/WeaponActions/Thrown/ThrownActions/SpecialFire/Fountain/LightFountain/PlaceFountain", false) then
        bLitFountain = true
        gLitTime = GetTimer()
    end
    if not bLitFountain and not bDroppedIt and not PedHasWeapon(gPlayer, 397) then
        bDroppedIt = true
        gDropTime = GetTimer()
    end
    if bDroppedIt and PedHasWeapon(gPlayer, 397) then
        bDroppedIt = false
    end
    if bF4000ed then
        return true
    else
        if (bLitFountain and GetTimer() >= gLitTime + 17000 or bDroppedIt and GetTimer() >= gDropTime + 15000) and PedGetAmmoCount(gPlayer, 397) == 0 and not bOutOfAmmo then
            tblPrank[3].blip = AddBlipForChar(tblPrank[3].id, 6, 1, 4)
            bOutOfAmmo = true
            DoSocialErrands(true, "AS_F4_AMMO")
        elseif bOutOfAmmo then
            if PlayerIsInAreaObject(tblPrank[3].id, 2, 1.25, 0) and IsButtonPressed(7, 0) and IsButtonPressed(10, 0) and bGiveWeapon then
                PedSetActionNode(tblPrank[3].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
                Wait(1000)
                PedSetWeapon(gPlayer, 397, 1)
                bGiveWeapon = false
                bOutOfAmmo = false
                bLitFountain = false
                bDroppedIt = false
                BlipRemove(tblPrank[3].blip)
                DoSocialErrands(true, "AS_F4_OBJECTIVE")
            elseif PedGetAmmoCount(gPlayer, 397) == 0 and PedHasWeapon(gPlayer, 397) then
                bGiveWeapon = false
                bOutOfAmmo = false
                bLitFountain = false
                bDroppedIt = false
                BlipRemove(tblPrank[3].blip)
                DoSocialErrands(true, "AS_F4_OBJECTIVE")
            end
            if not IsButtonPressed(7, 0) and not IsButtonPressed(10, 0) and not bGiveWeapon then
                bGiveWeapon = true
            end
        end
        return false
    end
end

function F_F4000ObjectiveMet()
    if bF4000ed then
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PCOMPLETE", true)
        tblPrank[3].time = GetTimer() + 30000
        tblPrank[3].bComplete = true
        PedSetTaskNode(tblPrank[3].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[3].id)
        prankCount = prankCount + 1
        CounterSetCurrent(prankCount)
        bOutOfAmmo = false
        return true
    elseif bF4000fail or bDroppedIt then
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PFAIL", false)
        tblPrank[3].time = GetTimer() + 30000
        PedSetTaskNode(tblPrank[3].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[3].id)
        bOutOfAmmo = true
        return true
    else
        return false
    end
end

function F_FirecrackerInit()
    DoSocialErrands(false, "AS_FC_OBJECTIVE")
    bFirecrackerGreet = false
    bFirecrackerGoal = false
    bFirecrackerReward = false
    bFirecracked = false
    bAlreadyHit = false
    bOutOfAmmo = false
    bHitByFirecracker = true
    gFirecrackerPed = -1
    crackerHit = 3
    bPrankCompleted = false
    for d, dead in tblDeadPool do
        dead = -1
    end
    gCurrentInitStage = F_FirecrackerInit
end

function F_Firecracker()
    if tblPrank[4].bLoaded then
        if F_PrankVaild(tblPrank[4]) then
            if not bFirecrackerGreet then
                bFirecrackerGreet = F_FirecrackerOnDialog()
            elseif not bFirecrackerGoal then
                bFirecrackerGoal = F_FirecrackerMissionSpecificCheck()
            elseif not bFirecrackerReward then
                bFirecrackerReward = F_FirecrackerObjectiveMet()
            else
                F_PrankCleanup(tblPrank[4])
            end
        else
            F_PrankCleanup(tblPrank[4])
        end
    else
        F_PrankCleanup(tblPrank[4])
    end
end

function F_FirecrackerOnDialog()
    if PedIsDoingTask(tblPrank[4].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        PlayerSetControl(0)
        PedSetActionNode(tblPrank[4].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        PedSetWeapon(gPlayer, 301, 10)
        Wait(1000)
        PlayerSetControl(1)
        RegisterGlobalEventHandler(7, nil)
        RegisterGlobalEventHandler(7, F_FirecrackerHit)
        F_RemoveOtherBlips()
        DoSocialErrands(true, "AS_FC_OBJCOUNT", crackerHit)
        tblPrank[4].bActive = true
        return true
    else
        return false
    end
end

function F_FirecrackerHit(pedID)
    if PedGetLastHitWeapon(pedID) == 301 and PedGetWhoHitMeLast(pedID) == gPlayer then
        bHitByFirecracker = true
        gFirecrackerPed = pedID
    end
end

function F_FirecrackerMissionSpecificCheck()
    if bHitByFirecracker then
        bFirecracked = false
        for v, vic in tblDeadPool do
            if vic == gFirecrackerPed then
                bHitByFirecracker = false
                break
            end
        end
        if bHitByFirecracker then
            crackerHit = crackerHit - 1
            if 1 < crackerHit or crackerHit == 0 then
                DoSocialErrands(true, "AS_FC_OBJCOUNT", crackerHit)
            else
                DoSocialErrands(true, "AS_FC_OBJCOUNT1", crackerHit)
            end
            bHitByFirecracker = false
            bFirecracked = true
            for v, vic in tblDeadPool do
                if vic == -1 then
                    tblDeadPool[v] = gFirecrackerPed
                    break
                end
            end
        end
    end
    if bFirecracked then
        if crackerHit == 0 then
            return true
        else
            return false
        end
    else
        if PedGetAmmoCount(gPlayer, 301) == 0 and not bOutOfAmmo then
            tblPrank[4].blip = AddBlipForChar(tblPrank[4].id, 6, 1, 4)
            bOutOfAmmo = true
            DoSocialErrands(true, "AS_FC_AMMO")
        elseif bOutOfAmmo then
            if PedGetAmmoCount(gPlayer, 301) == 0 and PlayerIsInAreaObject(tblPrank[4].id, 2, 1, 0) and IsButtonPressed(7, 0) and IsButtonPressed(10, 0) and bGiveWeapon then
                PedSetActionNode(tblPrank[4].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
                Wait(1000)
                PedSetWeapon(gPlayer, 301, 5)
                bGiveWeapon = false
                bOutOfAmmo = false
                BlipRemove(tblPrank[4].blip)
                if 1 < crackerHit or crackerHit == 0 then
                    DoSocialErrands(true, "AS_FC_OBJCOUNT", crackerHit)
                else
                    DoSocialErrands(true, "AS_FC_OBJCOUNT1", crackerHit)
                end
            end
            if not IsButtonPressed(7, 0) and not IsButtonPressed(10, 0) and not bGiveWeapon then
                bGiveWeapon = true
            end
        end
        return false
    end
end

function F_FirecrackerObjectiveMet()
    if bFirecracked then
        Wait(1000)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PCOMPLETE", true)
        tblPrank[4].time = GetTimer() + 60000
        tblPrank[4].bComplete = true
        PedSetTaskNode(tblPrank[4].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[4].id)
        prankCount = prankCount + 1
        CounterSetCurrent(prankCount)
        return true
    elseif bOutOfAmmo then
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PFAIL", false)
        tblPrank[4].time = GetTimer() + 15000
        PedSetTaskNode(tblPrank[4].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[4].id)
        return true
    else
        return false
    end
end

function F_ItchPowderInit()
    DoSocialErrands(false, "AS_IP_OBJECTIVE")
    bItchPowderGreet = false
    bItchPowderAccept = false
    bItchPowderGoal = false
    bItchPowderReward = false
    bItched = false
    bAlreadyHit = false
    bOutOfAmmo = false
    bHitByItchPowder = false
    gItchPowderPed = -1
    gOutOfAmmoTimer = 0
    peopleItched = 3
    bPrankCompleted = false
    for d, dead in tblDeadPool do
        tblDeadPool[d] = -1
    end
    gCurrentInitStage = F_ItchPowderInit
end

function F_ItchPowder()
    if tblPrank[5].bLoaded then
        if F_PrankVaild(tblPrank[5]) then
            if not bItchPowderGreet then
                bItchPowderGreet = F_ItchPowderOnDialog()
            elseif not bItchPowderAccept then
                bItchPowderAccept = F_ItchPowderAccept()
            elseif not bItchPowderGoal then
                bItchPowderGoal = F_ItchPowderMissionSpecificCheck()
            elseif not bItchPowderReward then
                bItchPowderReward = F_ItchPowderObjectiveMet()
            else
                F_PrankCleanup(tblPrank[5])
            end
        else
            F_PrankCleanup(tblPrank[5])
        end
    else
        F_PrankCleanup(tblPrank[5])
    end
end

function F_ItchPowderOnDialog()
    if PedIsDoingTask(tblPrank[5].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        SoundPlayAmbientSpeechEvent(tblPrank[5].id, "HELP_EXPLANATION")
        return true
    else
        return false
    end
end

function F_ItchPowderAccept()
    if PedIsDoingTask(tblPrank[5].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted", true) == true then
        PlayerSetControl(0)
        PedSetActionNode(tblPrank[5].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        PedSetWeapon(gPlayer, 394, 5)
        WaitSkippable(1000)
        F_MakePedSafe(tblPrank[5].id, true)
        RegisterGlobalEventHandler(7, nil)
        RegisterGlobalEventHandler(7, F_ItchPowderHit)
        PlayerSetControl(1)
        DoSocialErrands(true, "AS_IP_OBJCOUNT", peopleItched)
        F_RemoveOtherBlips()
        tblPrank[5].bActive = true
        return true
    else
        return false
    end
end

function F_ItchPowderHit(pedID)
    local bDog = false
    if PedIsModel(pedID, 219) or PedIsModel(pedID, 220) then
        bDog = true
    else
        bDog = false
    end
    if not bDog and PedGetLastHitWeapon(pedID) == 394 then
        bHitByItchPowder = true
        PedStop(pedID)
        PedOverrideStat(pedID, 6, 100)
        PedOverrideStat(pedID, 7, 100)
        PedOverrideStat(pedID, 14, 10)
        PedFlee(pedID, gPlayer)
        gItchPowderPed = pedID
    end
end

function F_ItchPowderMissionSpecificCheck()
    bItched = false
    if bHitByItchPowder then
        for v, vic in tblDeadPool do
            if vic == gItchPowderPed then
                bHitByItchPowder = false
                break
            end
        end
        if bHitByItchPowder then
            peopleItched = peopleItched - 1
            if 1 < peopleItched or peopleItched == 0 then
                DoSocialErrands(true, "AS_IP_OBJCOUNT", peopleItched)
            else
                DoSocialErrands(true, "AS_IP_OBJCOUNT1", peopleItched)
            end
            bHitByItchPowder = false
            bItched = true
            for v, vic in tblDeadPool do
                if vic == -1 then
                    tblDeadPool[v] = gItchPowderPed
                    break
                end
            end
        end
    end
    if PedIsValid(gItchPowderPed) and PedIsPlaying(gItchPowderPed, "/Global/HitTree/Standing/Ranged/ItchingPowder/Default", true) then
        local x, y, z = PedGetPosXYZ(gItchPowderPed)
        bPedbool, tblCE[1], tblCE[2], tblCE[3], tblCE[4], tblCE[5] = PedFindInAreaXYZ(x, y, z, 1.5)
        if bPedbool then
            for p, ped in tblCE do
                if PedIsValid(ped) then
                    local model = PedGetModel
                    local bNewVic = true
                    for v, vic in tblDeadPool do
                        if vic == ped then
                            bNewVic = false
                            break
                        end
                    end
                    if bNewVic and PedIsPlaying(ped, "/Global/HitTree/Standing/Ranged/ItchingPowder/Default", true) then
                        peopleItched = peopleItched - 1
                        if peopleItched ~= 0 then
                            if 1 < peopleItched or peopleItched == 0 then
                                DoSocialErrands(true, "AS_IP_OBJCOUNT", peopleItched)
                            else
                                DoSocialErrands(true, "AS_IP_OBJCOUNT1", peopleItched)
                            end
                        end
                        bHitByItchPowder = false
                        PedStop(ped)
                        PedOverrideStat(ped, 6, 100)
                        PedOverrideStat(ped, 7, 100)
                        PedOverrideStat(ped, 14, 10)
                        PedFlee(ped, gPlayer)
                        bItched = true
                        for v, vic in tblDeadPool do
                            if vic == -1 then
                                tblDeadPool[v] = ped
                                --print("===== gItchPowderPed ==", ped)
                                break
                            end
                        end
                        break
                    end
                end
            end
        end
    end
    if bItched then
        if peopleItched == 0 then
            bPrankCompleted = true
            return true
        else
            return false
        end
    else
        if PedGetAmmoCount(gPlayer, 394) == 0 and not bOutOfAmmo then
            tblPrank[5].blip = AddBlipForChar(tblPrank[5].id, 6, 1, 4)
            bOutOfAmmo = true
            DoSocialErrands(true, "AS_IP_AMMO")
        elseif bOutOfAmmo then
            if PedGetAmmoCount(gPlayer, 394) == 0 and PlayerIsInAreaObject(tblPrank[5].id, 2, 1, 0) and IsButtonPressed(7, 0) and IsButtonPressed(10, 0) and bGiveWeapon then
                PedSetActionNode(tblPrank[5].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
                Wait(1000)
                PedSetWeapon(gPlayer, 394, 5)
                bGiveWeapon = false
                bOutOfAmmo = false
                BlipRemove(tblPrank[5].blip)
                if peopleItched ~= 0 then
                    if 1 < peopleItched or peopleItched == 0 then
                        DoSocialErrands(true, "AS_IP_OBJCOUNT", peopleItched)
                    else
                        DoSocialErrands(true, "AS_IP_OBJCOUNT1", peopleItched)
                    end
                end
            end
            if not IsButtonPressed(7, 0) and not IsButtonPressed(10, 0) and not bGiveWeapon then
                bGiveWeapon = true
            end
        end
        return false
    end
end

function F_ItchPowderObjectiveMet()
    if bItched then
        Wait(1000)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PCOMPLETE", true)
        tblPrank[5].time = GetTimer() + 30000
        tblPrank[5].bComplete = true
        PedSetTaskNode(tblPrank[5].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[5].id)
        prankCount = prankCount + 1
        CounterSetCurrent(prankCount)
        return true
    else
        return false
    end
end

function F_KickMeInit()
    DoSocialErrands(false, "AS_KP_OBJECTIVE")
    bKickMeGreet = false
    bKickMeOnAccept = false
    bKickMeGoal = false
    bKickMeReward = false
    bNoteStuckOn = false
    bAlreadyHit = false
    bOutOfAmmo = false
    bDroppedIt = false
    gDropTime = 0
    bPrankCompleted = false
    for i, entry in tblCE do
        entry = -1
    end
    gCurrentInitStage = F_KickMeInit
end

function F_KickMe()
    if tblPrank[6].bLoaded then
        if F_PrankVaild(tblPrank[6]) then
            if not bKickMeGreet then
                bKickMeGreet = F_KickMeOnDialog()
            elseif not bKickMeOnAccept then
                bKickMeOnAccept = F_KickMeOnAccept()
            elseif not bKickMeGoal then
                bKickMeGoal = F_KickMeCheckNoteStuckOn()
            elseif not bKickMeReward then
                bKickMeReward = F_KickMeObjectiveMet()
            else
                F_PrankCleanup(tblPrank[6])
            end
        else
            F_PrankCleanup(tblPrank[6])
        end
    else
        F_PrankCleanup(tblPrank[6])
    end
end

function F_KickMeOnDialog()
    if PedIsDoingTask(tblPrank[6].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        SoundPlayAmbientSpeechEvent(tblPrank[6].id, "HELP_EXPLANATION")
        return true
    else
        return false
    end
end

function F_KickMeOnAccept()
    if PedIsDoingTask(tblPrank[6].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted", true) == true then
        PlayerSetControl(0)
        PedSetActionNode(tblPrank[6].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        while not WeaponRequestModel(372) do
            Wait(0)
        end
        PlayerSetWeapon(372, 1)
        F_MakePedSafe(tblPrank[6].id, true)
        PlayerSetControl(1)
        DoSocialErrands(true, "AS_KP_OBJECTIVE")
        F_RemoveOtherBlips()
        tblPrank[6].bActive = true
        return true
    else
        return false
    end
end

function F_KickMeCheckNoteStuckOn()
    if bNoteStuckOn then
        bPrankCompleted = true
        return true
    end
    if not bDroppedIt and not PedHasWeapon(gPlayer, 372) then
        bDroppedIt = true
        gDropTime = GetTimer()
    end
    if bDroppedIt and PedHasWeapon(gPlayer, 372) then
        bDroppedIt = false
    end
    if bDroppedIt and GetTimer() >= gDropTime + 10000 and PedGetAmmoCount(gPlayer, 372) == 0 and not bOutOfAmmo then
        tblPrank[6].blip = AddBlipForChar(tblPrank[6].id, 6, 1, 4)
        bOutOfAmmo = true
        DoSocialErrands(true, "AS_KM_AMMO")
    elseif bOutOfAmmo then
        if PedGetAmmoCount(gPlayer, 372) == 0 and PlayerIsInAreaObject(tblPrank[6].id, 2, 1, 0) and IsButtonPressed(7, 0) and IsButtonPressed(10, 0) and bGiveWeapon then
            PedSetActionNode(tblPrank[6].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
            Wait(1000)
            PlayerSetWeapon(372, 1)
            bGiveWeapon = false
            bOutOfAmmo = false
            bDroppedIt = false
            BlipRemove(tblPrank[6].blip)
            DoSocialErrands(true, "AS_KP_OBJECTIVE")
        end
        if not IsButtonPressed(7, 0) and not IsButtonPressed(10, 0) and not bGiveWeapon then
            bGiveWeapon = true
        end
    end
    return false
end

function F_PlayerAttachedSign()
    bNoteStuckOn = true
    bOutOfAmmo = false
end

function F_KickMeObjectiveMet()
    if bNoteStuckOn then
        Wait(1000)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PCOMPLETE", true)
        tblPrank[6].time = GetTimer() + 30000
        tblPrank[6].bComplete = true
        PedSetTaskNode(tblPrank[6].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[6].id)
        prankCount = prankCount + 1
        CounterSetCurrent(prankCount)
        return true
    elseif bOutOfAmmo then
        Wait(1000)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PFAIL", false)
        tblPrank[6].time = GetTimer() + 15000
        PedSetTaskNode(tblPrank[6].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[6].id)
        return true
    else
        return false
    end
end

function F_MarblesInit()
    DoSocialErrands(false, "AS_MA_OBJECTIVE")
    bMarblesGreet = false
    bMarblesAccept = false
    bMarblesGoal = false
    bMarblesReward = false
    bMarbled = false
    bAlreadyHit = false
    bHitByMarbles = false
    bOutOfAmmo = false
    gMarblesPed = -1
    gOutOfAmmoTimer = 0
    peopleMarbled = 1
    bPrankCompleted = false
    for d, dead in tblDeadPool do
        dead = -1
    end
    gCurrentInitStage = F_MarblesInit
end

function F_Marbles()
    if tblPrank[7].bLoaded then
        if F_PrankVaild(tblPrank[7]) then
            if not bMarblesGreet then
                bMarblesGreet = F_MarblesOnDialog()
            elseif not bMarblesAccept then
                bMarblesAccept = F_MarblesAccept()
            elseif not bMarblesGoal then
                bMarblesGoal = F_MarblesMissionSpecificCheck()
            elseif not bMarblesReward then
                bMarblesReward = F_MarblesObjectiveMet()
            else
                F_PrankCleanup(tblPrank[7])
            end
        else
            F_PrankCleanup(tblPrank[7])
        end
    else
        F_PrankCleanup(tblPrank[7])
    end
end

function F_MarblesOnDialog()
    if PedIsDoingTask(tblPrank[7].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        SoundPlayAmbientSpeechEvent(tblPrank[7].id, "HELP_EXPLANATION")
        return true
    else
        return false
    end
end

function F_MarblesAccept()
    if PedIsDoingTask(tblPrank[7].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted", true) == true then
        PlayerSetControl(0)
        PedSetActionNode(tblPrank[7].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        PedSetWeapon(gPlayer, 349, 5)
        Wait(1000)
        F_MakePedSafe(tblPrank[7].id, true)
        RegisterGlobalEventHandler(7, nil)
        RegisterGlobalEventHandler(7, F_MarblesHit)
        PlayerSetControl(1)
        DoSocialErrands(true, "AS_MA_OBJCOUNT1", peopleMarbled)
        F_RemoveOtherBlips()
        tblPrank[7].bActive = true
        return true
    else
        return false
    end
end

function F_MarblesHit(pedID)
    local bDog = false
    if PedIsModel(pedID, 219) or PedIsModel(pedID, 220) then
        bDog = true
    else
        bDog = false
    end
    if not bDog and PedGetWhoHitMeLast(pedID) == gPlayer then
        bHitByMarbles = true
        PedStop(pedID)
        PedOverrideStat(pedID, 6, 100)
        PedOverrideStat(pedID, 7, 100)
        PedOverrideStat(pedID, 14, 10)
        PedFlee(pedID, gPlayer)
        gMarblesPed = pedID
    end
end

function F_MarblesMissionSpecificCheck()
    if bHitByMarbles then
        bMarbled = false
        for v, vic in tblDeadPool do
            if vic == gMarblesPed then
                bHitByMarbles = false
                break
            end
        end
        if bHitByMarbles then
            if PedIsValid(gMarblesPed) then
                if PedIsPlaying(gMarblesPed, "/Global/HitTree/Standing/Ranged/Marbles", true) then
                    bHitByMarbles = true
                else
                    bHitByMarbles = false
                end
            end
            if bHitByMarbles then
                peopleMarbled = peopleMarbled - 1
                if 1 < peopleMarbled or peopleMarbled == 0 then
                    DoSocialErrands(true, "AS_MA_OBJCOUNT", peopleMarbled)
                else
                    DoSocialErrands(true, "AS_MA_OBJCOUNT1", peopleMarbled)
                end
                bHitByMarbles = false
                bMarbled = true
                for v, vic in tblDeadPool do
                    if vic == -1 then
                        tblDeadPool[v] = gMarblesPed
                        break
                    end
                end
            end
        end
    end
    if bMarbled then
        if peopleMarbled == 0 then
            return true
        else
            return false
        end
    else
        if PedGetAmmoCount(gPlayer, 349) == 0 and not bOutOfAmmo then
            tblPrank[7].blip = AddBlipForChar(tblPrank[7].id, 6, 1, 4)
            bOutOfAmmo = true
            DoSocialErrands(true, "AS_MA_AMMO")
        elseif bOutOfAmmo then
            if PedGetAmmoCount(gPlayer, 349) == 0 and PlayerIsInAreaObject(tblPrank[7].id, 2, 1, 0) and IsButtonPressed(7, 0) and IsButtonPressed(10, 0) and bGiveWeapon then
                PedSetActionNode(tblPrank[7].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
                Wait(1000)
                PedSetWeapon(gPlayer, 349, 5)
                bGiveWeapon = false
                bOutOfAmmo = false
                BlipRemove(tblPrank[7].blip)
                if 1 < peopleMarbled or peopleMarbled == 0 then
                    DoSocialErrands(true, "AS_MA_OBJCOUNT", peopleMarbled)
                else
                    DoSocialErrands(true, "AS_MA_OBJCOUNT1", peopleMarbled)
                end
            end
            if not IsButtonPressed(7, 0) and not IsButtonPressed(10, 0) and not bGiveWeapon then
                bGiveWeapon = true
            end
        end
        return false
    end
end

function F_MarblesObjectiveMet()
    if bMarbled then
        Wait(1000)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PCOMPLETE", true)
        tblPrank[7].time = GetTimer() + 30000
        tblPrank[7].bComplete = true
        PedSetTaskNode(tblPrank[7].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[7].id)
        prankCount = prankCount + 1
        CounterSetCurrent(prankCount)
        return true
    elseif bOutOfAmmo then
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PFAIL", false)
        tblPrank[7].time = GetTimer() + 15000
        tblPrank[7].bComplete = false
        PedSetTaskNode(tblPrank[7].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[7].id)
        return true
    else
        return false
    end
end

function F_StinkBombInit()
    DoSocialErrands(false, "AS_SB_OBJECTIVE")
    bStinkBombGreet = false
    bStinkBombAccept = false
    bStinkBombGoal = false
    bStinkBombReward = false
    bStunk = false
    bAlreadyHit = false
    bOutOfAmmo = false
    peopleStunk = 3
    bPrankCompleted = false
    for d, dead in tblDeadPool do
        tblDeadPool[d] = -1
    end
    gCurrentInitStage = F_StinkBombInit
end

function F_StinkBomb()
    if tblPrank[8].bLoaded then
        if F_PrankVaild(tblPrank[8]) then
            if not bStinkBombGreet then
                bStinkBombGreet = F_StinkBombOnDialog()
            elseif not bStinkBombAccept then
                bStinkBombAccept = F_StinkBombAccept()
            elseif not bStinkBombGoal then
                bStinkBombGoal = F_StinkBombMissionSpecificCheck()
            elseif not bStinkBombReward then
                bStinkBombReward = F_StinkBombObjectiveMet()
            else
                F_PrankCleanup(tblPrank[8])
            end
        else
            F_PrankCleanup(tblPrank[8])
        end
    else
        F_PrankCleanup(tblPrank[8])
    end
end

function F_StinkBombOnDialog()
    if PedIsDoingTask(tblPrank[8].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog", false) == true then
        SoundPlayAmbientSpeechEvent(tblPrank[8].id, "HELP_EXPLANATION")
        return true
    else
        return false
    end
end

function F_StinkBombAccept()
    if PedIsDoingTask(tblPrank[8].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted", true) == true then
        PlayerSetControl(0)
        PedSetActionNode(tblPrank[8].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
        Wait(1000)
        PedSetWeapon(gPlayer, 309, 5)
        WaitSkippable(1000)
        F_MakePedSafe(tblPrank[8].id, true)
        RegisterGlobalEventHandler(7, nil)
        RegisterGlobalEventHandler(7, F_StinkBombHit)
        PlayerSetControl(1)
        DoSocialErrands(true, "AS_SB_OBJCOUNT", peopleStunk)
        F_RemoveOtherBlips()
        tblPrank[8].bActive = true
        return true
    else
        return false
    end
end

function F_StinkBombHit(pedID)
    if pedID ~= tblDeadPool[1] and pedID ~= tblDeadPool[2] and pedID ~= tblDeadPool[3] and pedID ~= gPlayer and PedGetWhoHitMeLast(pedID) == gPlayer then
        --print("=== Found Someone to Stink =====")
        if PedIsPlaying(pedID, "/Global/HitTree/Standing/Ranged/Bomb/Stinky/Stinky", true) and PedGetWhoHitMeLast(pedID) == gPlayer then
            --print("=== Found Someone to Stink and They are playing stinked out =====")
            for v, vic in tblDeadPool do
                if vic == -1 then
                    tblDeadPool[v] = pedID
                    break
                end
            end
            gStinkPed = pedID
            PedStop(pedID)
            PedOverrideStat(pedID, 6, 100)
            PedOverrideStat(pedID, 7, 100)
            PedOverrideStat(pedID, 14, 10)
            PedFlee(pedID, gPlayer)
            local bPeds, ped1, ped2, ped3, ped4, ped5, ped6 = PedFindInAreaObject(pedID, 4)
            if bPeds then
                if ped1 ~= pedID and PedIsValid(ped1) and not F_InDeadPool(ped1) and PedIsPlaying(ped1, "/Global/HitTree/Standing/Ranged/Bomb/Stinky/Stinky", true) then
                    F_PutInDeadPool(ped1)
                end
                if ped2 ~= pedID and PedIsValid(ped2) and not F_InDeadPool(ped2) and PedIsPlaying(ped2, "/Global/HitTree/Standing/Ranged/Bomb/Stinky/Stinky", true) then
                    F_PutInDeadPool(ped2)
                end
                if ped3 ~= pedID and PedIsValid(ped3) and PedIsPlaying(ped3, "/Global/HitTree/Standing/Ranged/Bomb/Stinky/Stinky", true) and not F_InDeadPool(ped3) then
                    F_PutInDeadPool(ped3)
                end
                if ped4 ~= pedID and PedIsValid(ped4) and PedIsPlaying(ped4, "/Global/HitTree/Standing/Ranged/Bomb/Stinky/Stinky", true) and not F_InDeadPool(ped4) then
                    F_PutInDeadPool(ped4)
                end
                if ped5 ~= pedID and PedIsValid(ped5) and PedIsPlaying(ped5, "/Global/HitTree/Standing/Ranged/Bomb/Stinky/Stinky", true) and not F_InDeadPool(ped5) then
                    F_PutInDeadPool(ped5)
                end
                if ped6 ~= pedID and PedIsValid(ped6) and PedIsPlaying(ped6, "/Global/HitTree/Standing/Ranged/Bomb/Stinky/Stinky", true) and not F_InDeadPool(ped6) then
                    F_PutInDeadPool(ped6)
                end
            end
            bHitByStink = true
        end
    end
end

function F_InDeadPool(ped)
    if ped ~= tblDeadPool[1] and ped ~= tblDeadPool[2] and ped ~= tblDeadPool[3] and PedIsPlaying(ped, "/Global/HitTree/Standing/Ranged/Bomb/Stinky/Stinky", true) then
        return false
    else
        return true
    end
end

function F_PutInDeadPool(ped)
    for v, vic in tblDeadPool do
        if vic == -1 then
            tblDeadPool[v] = ped
            break
        end
    end
    if not F_PedIsBully(ped) then
        PedStop(ped)
        PedOverrideStat(ped, 6, 100)
        PedOverrideStat(ped, 7, 100)
        PedOverrideStat(ped, 14, 10)
        PedFlee(ped, gPlayer)
    end
end

function F_StinkBombMissionSpecificCheck()
    if bHitByStink then
        local peephit = 0
        for v, vic in tblDeadPool do
            if vic ~= -1 then
                peephit = peephit + 1
            end
        end
        peopleStunk = 3
        peopleStunk = peopleStunk - peephit
        if peopleStunk < 0 then
            peopleStunk = 0
        end
        if peopleStunk ~= 0 then
            if 1 < peopleStunk or peopleStunk == 0 then
                DoSocialErrands(true, "AS_SB_OBJCOUNT", peopleStunk)
            else
                DoSocialErrands(true, "AS_SB_OBJCOUNT1", peopleStunk)
            end
        end
        if peopleStunk == 0 then
            bStunk = true
            bPrankCompleted = true
            return true
        end
        bHitByStink = false
    end
    if PedGetAmmoCount(gPlayer, 309) == 0 and not bOutOfAmmo then
        tblPrank[8].blip = AddBlipForChar(tblPrank[8].id, 6, 1, 4)
        bOutOfAmmo = true
        DoSocialErrands(true, "AS_SB_AMMO")
        PedLockTarget(tblPrank[8].id, -1)
        PedStop(tblPrank[8].id)
        PedClearObjectives(tblPrank[8].id)
    elseif bOutOfAmmo then
        if PedGetAmmoCount(gPlayer, 309) == 0 and PlayerIsInAreaObject(tblPrank[8].id, 2, 1, 0) and IsButtonPressed(7, 0) and IsButtonPressed(10, 0) and bGiveWeapon then
            PedSetActionNode(tblPrank[8].id, "/Global/Ambient/Scenarios/ScenarioGive/ScenarioGive", "Act/Anim/Ambient.act")
            Wait(1000)
            PedSetWeapon(gPlayer, 309, 5)
            bGiveWeapon = false
            bOutOfAmmo = false
            BlipRemove(tblPrank[8].blip)
            if 1 < peopleStunk or peopleStunk == 0 then
                DoSocialErrands(true, "AS_SB_OBJCOUNT", peopleStunk)
            else
                DoSocialErrands(true, "AS_SB_OBJCOUNT1", peopleStunk)
            end
        end
        if not IsButtonPressed(7, 0) and not IsButtonPressed(10, 0) and not bGiveWeapon then
            bGiveWeapon = true
        end
    end
    return false
end

function F_StinkBombObjectiveMet()
    if bStunk then
        Wait(1000)
        DoSocialErrands(false)
        MinigameSetErrandCompletion(-1, "AS_PCOMPLETE", true)
        tblPrank[8].time = GetTimer() + 30000
        tblPrank[8].bComplete = true
        PedSetTaskNode(tblPrank[8].id, "/Global/AI/GeneralObjectives/POIPoint/Scenario/ScenarioSeek/ScenarioOpen/ScenarioWait/ScenarioDialog/ScenarioAccepted/ScenarioOptions/ScenarioObjective/WaitForObjective/ObjectiveOptions/ObjCompleted/ObjScenarioEnd", "Act/AI/AI.act")
        PedClearPOI(tblPrank[8].id)
        prankCount = prankCount + 1
        CounterSetCurrent(prankCount)
        return true
    else
        return false
    end
end

function T_EnterKickMe(triggerID, pedID)
    if pedID == gPlayer then
        F_LoadPrank(triggerID)
    end
end

function T_EnterDeadRat(triggerID, pedID)
    if pedID == 0 then
        F_LoadPrank(triggerID)
    end
end

function T_EnterF4000(triggerID, pedID)
    if pedID == gPlayer then
        F_LoadPrank(triggerID)
    end
end

function T_EnterStinkBomb(triggerID, pedID)
    if pedID == gPlayer then
        F_LoadPrank(triggerID)
    end
end

function T_EnterEggMan(triggerID, pedID)
    if pedID == gPlayer then
        F_LoadPrank(triggerID)
    end
end

function T_EnterFirecracker(triggerID, pedID)
    if pedID == gPlayer then
        F_LoadPrank(triggerID)
    end
end

function T_EnterItchPowder(triggerID, pedID)
    if pedID == gPlayer then
        F_LoadPrank(triggerID)
    end
end

function T_EnterMarbles(triggerID, pedID)
    if pedID == gPlayer then
        F_LoadPrank(triggerID)
    end
end

function T_ExitKickMe(triggerID, pedID)
    if pedID == gPlayer then
        F_UnLoadPrank(triggerID)
    end
end

function T_ExitDeadRat(triggerID, pedID)
    if pedID == gPlayer then
        F_UnLoadPrank(triggerID)
    end
end

function T_ExitF4000(triggerID, pedID)
    if pedID == gPlayer then
        F_UnLoadPrank(triggerID)
    end
end

function T_ExitStinkBomb(triggerID, pedID)
    if pedID == gPlayer then
        F_UnLoadPrank(triggerID)
    end
end

function T_ExitEggMan(triggerID, pedID)
    if pedID == gPlayer then
        F_UnLoadPrank(triggerID)
    end
end

function T_ExitFirecracker(triggerID, pedID)
    if pedID == gPlayer then
        F_UnLoadPrank(triggerID)
    end
end

function T_ExitItchPowder(triggerID, pedID)
    if pedID == gPlayer then
        F_UnLoadPrank(triggerID)
    end
end

function T_ExitMarbles(triggerID, pedID)
    if pedID == gPlayer then
        F_UnLoadPrank(triggerID)
    end
end

function F_MissionSetup()
    LoadPedModels({
        169,
        162,
        161,
        163,
        164,
        159,
        170,
        186,
        136,
        160,
        165
    })
    while not WeaponRequestModel(411) do
        Wait(0)
    end
    tblPrank = {
        {
            id = -1,
            blip = 0,
            model = 169,
            func = F_DeadRatInit,
            point = POINTLIST._1_11XP_FIRECRACKER,
            bComplete = true,
            bLoaded = false,
            bActive = false,
            time = 0,
            bOnDeck = false,
            trigger = TRIGGER._1_11XP_FIRECRACKER
        },
        {
            id = -1,
            blip = 0,
            model = 164,
            func = F_EggManInit,
            point = POINTLIST._1_11XP_JOKECANDY,
            bComplete = false,
            bLoaded = false,
            bActive = false,
            time = 0,
            bOnDeck = false,
            trigger = TRIGGER._1_11XP_JOKECANDY
        },
        {
            id = -1,
            blip = 0,
            model = 162,
            func = F_F4000Init,
            point = POINTLIST._1_11XP_F4000,
            bComplete = false,
            bLoaded = false,
            bActive = false,
            time = 0,
            bOnDeck = false,
            trigger = TRIGGER._1_11XP_F4000
        },
        {
            id = -1,
            blip = 0,
            model = 161,
            func = F_FirecrackerInit,
            point = POINTLIST._1_11XP_DEADRAT,
            bComplete = true,
            bLoaded = false,
            bActive = false,
            time = 0,
            bOnDeck = false,
            trigger = TRIGGER._1_11XP_DEADRAT
        },
        {
            id = -1,
            blip = 0,
            model = 163,
            func = F_ItchPowderInit,
            point = POINTLIST._1_11XP_ITCHPOWDER,
            bComplete = false,
            bLoaded = false,
            bActive = false,
            time = 0,
            bOnDeck = false,
            trigger = TRIGGER._1_11XP_ITCHPOWDER
        },
        {
            id = -1,
            blip = 0,
            model = 159,
            func = F_KickMeInit,
            point = POINTLIST._1_11XP_KICKME,
            bComplete = false,
            bLoaded = false,
            bActive = false,
            time = 0,
            bOnDeck = false,
            trigger = TRIGGER._1_11XP_KICKME
        },
        {
            id = -1,
            blip = 0,
            model = 161,
            func = F_MarblesInit,
            point = POINTLIST._1_11XP_MARBLES,
            bComplete = false,
            bLoaded = false,
            bActive = false,
            time = 0,
            bOnDeck = false,
            trigger = TRIGGER._1_11XP_MARBLES
        },
        {
            id = -1,
            blip = 0,
            model = 186,
            func = F_StinkBombInit,
            point = POINTLIST._1_11XP_STINKBOMB,
            bComplete = false,
            bLoaded = false,
            bActive = false,
            time = 0,
            bOnDeck = false,
            trigger = TRIGGER._1_11XP_STINKBOMB
        }
    }
    RegisterTriggerEventHandler(TRIGGER._1_11XP_JOKECANDY, 1, T_EnterEggMan)
    RegisterTriggerEventHandler(TRIGGER._1_11XP_F4000, 1, T_EnterF4000)
    RegisterTriggerEventHandler(TRIGGER._1_11XP_ITCHPOWDER, 1, T_EnterItchPowder)
    RegisterTriggerEventHandler(TRIGGER._1_11XP_KICKME, 1, T_EnterKickMe)
    RegisterTriggerEventHandler(TRIGGER._1_11XP_MARBLES, 1, T_EnterMarbles)
    RegisterTriggerEventHandler(TRIGGER._1_11XP_STINKBOMB, 1, T_EnterStinkBomb)
    RegisterTriggerEventHandler(TRIGGER._1_11XP_JOKECANDY, 4, T_ExitEggMan)
    RegisterTriggerEventHandler(TRIGGER._1_11XP_F4000, 4, T_ExitF4000)
    RegisterTriggerEventHandler(TRIGGER._1_11XP_ITCHPOWDER, 4, T_ExitItchPowder)
    RegisterTriggerEventHandler(TRIGGER._1_11XP_KICKME, 4, T_ExitKickMe)
    RegisterTriggerEventHandler(TRIGGER._1_11XP_MARBLES, 4, T_ExitMarbles)
    RegisterTriggerEventHandler(TRIGGER._1_11XP_STINKBOMB, 4, T_ExitStinkBomb)
    WeatherSet(3)
    if not PedHasAllyFollower(gPlayer) then
        if shared.gPetey and PedIsValid(shared.gPetey) then
            PedDelete(shared.gPetey)
            shared.gPetey = nil
        end
        if shared.gGary and PedIsValid(shared.gGary) then
            PedDelete(shared.gGary)
            shared.gGary = nil
        end
        shared.gGary = PedCreatePoint(160, POINTLIST._1_11XP_PLAYERSTART, 2)
        shared.gPetey = PedCreatePoint(165, POINTLIST._1_11XP_PLAYERSTART, 3)
        PedSetWeaponNow(shared.gGary, 411, 1, false)
        PedRecruitAlly(gPlayer, shared.gGary)
        Wait(100)
        PedRecruitAlly(shared.gGary, shared.gPetey)
        PedMakeAmbient(shared.gPetey)
        PedMakeMissionChar(shared.gPetey)
        PedMakeAmbient(shared.gGary)
        PedMakeMissionChar(shared.gGary)
        AddBlipForChar(shared.gGary, 6, 27, 1)
        AddBlipForChar(shared.gPetey, 6, 27, 1)
    end
    PedSetTypeToTypeAttitude(11, 13, 2)
    PedSetTypeToTypeAttitude(2, 13, 2)
    PedSetTypeToTypeAttitude(5, 13, 2)
    PedSetTypeToTypeAttitude(4, 13, 2)
    PedSetTypeToTypeAttitude(1, 13, 2)
    PedSetTypeToTypeAttitude(6, 13, 2)
    for p, prank in tblPrank do
        if not prank.bComplete then
            prank.blip = BlipAddPoint(prank.point, 1)
        end
    end
    PunishersRespondToPlayerOnly(true)
end
