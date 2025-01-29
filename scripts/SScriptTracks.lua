function F_RollPropDice()
    if PedIsPlaying(shared.gPOIKidsPlayingDice[1].ped, "/Global/AniDice/Minigame/AmbientDice/GrappleAttempt/GrappleSuccess/PickupDice", true) then
        PAnimSetActionNode(shared.gPOIKidsPlayingDice[4].dice1, "/Global/AniDice/RollDice/Roll", "Act/Props/AniDice.act")
    elseif PedIsPlaying(shared.gPOIKidsPlayingDice[2].ped, "/Global/AniDice/Minigame/AmbientDice/GrappleAttempt/GrappleSuccess/PickupDice", true) then
        PAnimSetActionNode(shared.gPOIKidsPlayingDice[4].dice2, "/Global/AniDice/RollDice/Roll", "Act/Props/AniDice.act")
    end
end

function F_PickupDice()
    if PedIsPlaying(shared.gPOIKidsPlayingDice[1].ped, "/Global/AniDice/Minigame/AmbientDice/GrappleAttempt/GrappleSuccess/PickupDice", true) then
        PAnimSetActionNode(shared.gPOIKidsPlayingDice[4].dice1, "/Global/AniDice/IdleDice/Idle", "Act/Props/AniDice.act")
    elseif PedIsPlaying(shared.gPOIKidsPlayingDice[2].ped, "/Global/AniDice/Minigame/AmbientDice/GrappleAttempt/GrappleSuccess/PickupDice", true) then
        PAnimSetActionNode(shared.gPOIKidsPlayingDice[4].dice2, "/Global/AniDice/IdleDice/Idle", "Act/Props/AniDice.act")
    end
end

function F_SetupLockpickingGame()
    if shared.gStartingEvent == false then
        LaunchScript("secnd/MGLockPicking.lua")
        if shared.gLockpickStartingFunction ~= nil then
            local x, y, z = PlayerGetPosXYZ()
            shared.gLockpickStartingFunction(x, y, z)
        end
    end
end

function F_DisplayLockPickingHud()
    shared.gLockpickingHudTurnOn = true
end

function F_FailedLockPicking()
    shared.gFailedPickingLocker = true
end

function F_LockpickingDoorIsOpen()
    if shared.gLockpickingSuccess == true then
        return 1
    end
    return 0
end

function F_PedStoppedLockpicking()
    if shared.gFailedPickingLocker == true then
        if shared.gLockpickFailureFunction ~= nil then
            local x, y, z = PlayerGetPosXYZ()
            shared.gLockpickFailureFunction(x, y, z)
            shared.gLockpickFailureFunction = nil
            shared.gLockpickSuccessFunction = nil
        else
            shared.gStartingEvent = false
        end
        return 1
    end
    return 0
end

function F_LockpickingRewardPlayer()
    if shared.gLockpickSuccessFunction ~= nil then
        local x, y, z = PlayerGetPosXYZ()
        shared.gLockpickSuccessFunction(x, y, z)
        shared.gLockpickFailureFunction = nil
        shared.gLockpickSuccessFunction = nil
    elseif MissionActiveSpecific("1_02B") and PlayerIsInAreaXYZ(-604, -304.8, 0, 5, 0) then
        PlayerSetWeapon(383, 1, true)
        PlayerClearRewardStore()
    end
    shared.gLockpickingSuccess = false
    shared.gStartingEvent = false
end

function F_CheckSleepType()
    --print("CHECK SLEEP TYPE ", shared.WakeUpType)
    if shared.WakeUpType == 0 then
        shared.WakeUpType = 1
        return 1
    else
        return 0
    end
end

function F_PlayerControlFunhouse()
    return shared.FHPlayerControlTraps
end

function F_PlayerBroughtBike()
    local lastBike = PlayerGetLastBikeId()
    local x, y, z = PlayerGetPosXYZ()
    if -1 < lastBike and VehicleIsInAreaXYZ(lastBike, x, y, z, 10, 0) then
        return 1
    end
    return 0
end

function F_RaceSetCurrent(raceID)
    shared.g3_R08_CurrentRace = raceID
end

function F_RevengeOnMrBurton()
    return shared.g5_05
end

function F_DisableBuses()
    if shared.gDisableBusStops then
        return 1
    else
        return 0
    end
end

function F_GrafittiCleanupAvailable()
    local savedData = PlayerGetScriptSavedData(14)
    if savedData == 1 then
        return 1
    end
    return 0
end

function F_LawnmowerAvailable()
    local savedData = PlayerGetScriptSavedData(14)
    if ChapterGet() ~= 2 and savedData == 1 then
        return 1
    end
    return 0
end

function F_HasRadioParts()
    if ItemGetCurrentNum(476) > 0 then
        return 1
    else
        return 0
    end
end

function F_WindowsOpen()
    if shared.gWindowsOpen then
        return 1
    else
        return 0
    end
end

function F_SnowShovelAvailable()
    local savedData = PlayerGetScriptSavedData(14)
    if ChapterGet() == 2 and savedData == 1 then
        return 1
    end
    return 0
end

function F_CoasterHUDOff()
    HUDSaveVisibility()
    HUDClearAllElements()
end

function F_CoasterHUDOn()
    HUDRestoreVisibility()
end

function F_2_04_FirstAttempt()
    return PlayerGetScriptSavedData(23) ~= 1 and 1 or 0
end

function F_2_04_NotFirstAttempt()
    if PlayerGetScriptSavedData(23) == 1 then
        return 1
    else
        return 0
    end
end

function F_2_R03_FirstAttempt()
    return GetMissionAttemptCount("2_R03") == 0 and 1 or 0
end

function F_2_R03_NotFirstAttempt()
    return GetMissionAttemptCount("2_R03") > 0 and 1 or 0
end

function F_3_S11_FirstAttempt()
    return GetMissionAttemptCount("3_S11") == 0 and 1 or 0
end

function F_3_S11_NotFirstAttempt()
    return GetMissionAttemptCount("3_S11") > 0 and 1 or 0
end

function F_Wrestling_FirstAttempt()
    return GetMissionAttemptCount("C_Wrestling_1") == 0 and 1 or 0
end

function F_Chemistry_FirstAttempt()
    return GetMissionAttemptCount("C_Chem_1") == 0 and 1 or 0
end

function F_DormAlarmActive()
    return shared.gBDormFAlarmOn == true and 1 or 0
end

function F_FireAlarmActive()
    if AreaGetVisible() == 2 then
        return shared.gSchoolFAlarmOn == true and 1 or 0
    elseif AreaGetVisible() == 14 then
        return shared.gBDormFAlarmOn == true and 1 or 0
    elseif AreaGetVisible() == 35 then
        return shared.gGDormFAlarmOn == true and 1 or 0
    end
    return 0
end

function F_Check1_11X2Stage()
    if shared._1_11X2OnStage2 == true then
        return 1
    else
        return 0
    end
end

function F_ChemForceStart()
    ForceStartMission("C_Chem_1")
end

function F_ChemForceAvailable()
    ForceMissionAvailable("C_Chem_1")
end

function F_1_02CCompleted()
    return shared.g1_02_Completed == true and 1 or 0
end

function F_ChemistryWeapons(param)
end

function F_PlayerHasSlept()
    if PlayerGetScriptSavedData(26) == 1 then
        return 1
    end
    return 0
end

function F_CanUseChemistrySet()
    if shared.ChemistrySetLocked == 1 then
        return 1
    end
    return 0
end

function F_PlayerUsedChemistrySet()
    if F_CheckMaxItems() then
        --print("GIVING IT TO THE PLAYER??")
        local ammo = 3
        if IsMissionCompleated("C_Chem_4") then
            ammo = 5
            if PlayerHasItem(307) then
                --print("GIVING AMMO TO THE PLAYER ")
                GiveAmmoToPlayer(308, 12)
            end
        end
        if IsMissionCompleated("C_Chem_3") then
            GiveAmmoToPlayer(394, ammo)
        end
        if IsMissionCompleated("C_Chem_2") then
            GiveAmmoToPlayer(309, ammo)
        end
        GiveAmmoToPlayer(301, ammo)
        shared.ChemistrySetLocked = 2
        shared.ChemistrySetLastTimeUsed = GetCurrentDay(false)
        PlayerSetScriptSavedData(25, shared.ChemistrySetLastTimeUsed)
    else
        TutorialShowMessage("CHEMSET_FULL", 3000)
    end
end

function F_CheckMaxItems()
    --print("CHECKING MAX ITEMS")
    if IsMissionCompleated("C_Chem_4") and PlayerHasItem(307) and PedGetAmmoCount(gPlayer, 308) < 12 then
        --print("CHECKING MAX ITEMS CHEM 4")
        return true
    end
    if IsMissionCompleated("C_Chem_3") and PedGetAmmoCount(gPlayer, 394) < 5 then
        --print("CHECKING MAX ITEMS CHEM 3")
        return true
    end
    if IsMissionCompleated("C_Chem_2") and 5 > PedGetAmmoCount(gPlayer, 309) then
        --print("CHECKING MAX ITEMS CHEM 2")
        return true
    end
    if 5 > PedGetAmmoCount(gPlayer, 301) then
        return true
    end
    return false
end

function F_CheckBalloonErrand()
    if shared.balloonErrandActive then
        return 1
    else
        return 0
    end
end

function F_ToggleArcadeMachines(param)
    if param == 1 and not shared.ArcadeMachinesOn then
        shared.ArcadeMachinesOn = true
    elseif param == 0 and shared.ArcadeMachinesOn then
        shared.ArcadeMachinesOn = false
    end
    SoundEmitterEnable("Dorm1stFLoorArcade", shared.ArcadeMachinesOn)
    SoundEmitterEnable("NerdArcade", shared.ArcadeMachinesOn)
    SoundEmitterEnable("DropArcade", shared.ArcadeMachinesOn)
    SoundEmitterEnable("GreaserArcade", shared.ArcadeMachinesOn)
    SoundEmitterEnable("Nerd Arcade", shared.ArcadeMachinesOn)
    SoundEmitterEnable("PrepArcade", shared.ArcadeMachinesOn)
    SoundEmitterEnable("SouvineerArcade", shared.ArcadeMachinesOn)
end
