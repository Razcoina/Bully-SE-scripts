--[[ Changes to this file:
    * Modified lines where function PedDestroyWeapon was called, changed values from 8 to WEAPON_YARDSTICK, may require testing
]]

ImportScript("Library/LibTable.lua")
ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibPed.lua")
ImportScript("Library/LibTriggerNew.lua")
ImportScript("Library/LibPropNew.lua")
local algie3, csnerd3, csnerd4, ambushnerd03, ambushnerd04, ambushnerd05, scout, p1_2, p1_5, p1_3, p2_3, p2_5, p3_7, p4_1, p4_2, scout2, scout3, scout4
local scout3_ran = false
local scout4_ran = false
local window_spawners = false
local spawners_activated = false
local flux_line_played = false
local algie_blip3
local mission_success = false
local wave3_dead = false
local player_out = false
local nerds_escaped_01 = false
local nerds_escaped_03 = false
local runawayline1_played = false
local runawayline2_played = false
local code_is_given = false
local ambush1 = false
local ambush2 = false
local breaker_box_alive = true
local spud_line_played = false
local p_wave1 = "A"
local p_wave_scout = "AA"
local p_wave2 = "B"
local p_wave_scout3 = "BB"
local p_wave3 = "C"
local p_wave4 = "D"
local cover_PropTable = {}
local coverProps = {}
local cover_props_set = false
local door_dead = false
local nerd_spawner1, ns_point1, nerd_spawner2, ns_point2, nerd_spawner3, ns_point3, nerd_spawner4, ns_point4, nerd_spawner5, ns_point5, nerd_spawner6, ns_point6, nerd_spawner7, ns_point7
local spawned_nerds1 = {}
local spawned_nerds2 = {}
local spawned_nerds3 = {}
local spawned_nerds4 = {}
local spawned_nerds5 = {}
local spawned_nerds6 = {}
local spawned_nerds7 = {}
local algie3_create = false
local spud_nerd
local hint_line1 = false
local hint_line2 = false
local on_cannon = false
local blip_library, csnerd3_blip, csnerd4_blip, ambushnerd03_blip, ambushnerd04_blip, ambushnerd05_blip, ob_blip
local ob_blip_remove = false
local spudcannon_blip
local cannon_blip = false
local ob_blip2
local ob_blip2_set = false
local water_cam = false
local mission_won = false
local mis_obj01, mis_obj02, mis_obj03, mis_obj04, thread_T_1st_Group_Dead_No_Hint1, thread_T_ScaredNerds01, thread_T_1st_Group_Dead_No_Hint2, thread_T_Ambushnerd_Health1

function F_PropSet()
    cover_PropTable = {
        {
            id = TRIGGER._4_02_BAR_01
        },
        {
            id = TRIGGER._4_02_BAR_02
        },
        {
            id = TRIGGER._4_02_BAR_03
        }
    }
end

function F_SetUpEnemies1()
    L_PedLoadPoint(p_wave1, {
        {
            model = 7,
            point = POINTLIST._4_02_NERD_SCOUT_01,
            name = "p1_scout",
            target = gPlayer,
            cover = POINTLIST._4_02_NERD_SCOUT_03,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p1_scout_cover"
        },
        {
            model = 8,
            point = POINTLIST._4_02_P_NERD01,
            name = "p1_1",
            target = gPlayer,
            cover = POINTLIST._4_02_P_NERD01,
            p_weapon = 301,
            ammo = 50,
            cover_file = "4_02_p1_1_cover"
        },
        {
            model = 9,
            point = POINTLIST._4_02_P_NERD02,
            name = "p1_2",
            target = gPlayer,
            cover = POINTLIST._4_02_P_NERD02,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p1_2_cover"
        },
        {
            model = 9,
            point = POINTLIST._4_02_P_NERD03,
            name = "p1_3",
            target = gPlayer,
            cover = POINTLIST._4_02_P_NERD03,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p1_3_cover"
        },
        {
            model = 7,
            point = POINTLIST._4_02_P_NERD05,
            name = "p1_5",
            target = gPlayer,
            cover = POINTLIST._4_02_P_NERD05,
            p_weapon = 305,
            ammo = 50,
            cover_file = "4_02_p1_5_cover"
        }
    })
end

function F_SetUpEnemies2()
    L_PedLoadPoint(p_wave_scout2, {
        {
            model = 7,
            point = POINTLIST._4_02_NERD_SCOUT2_01,
            name = "p2_scout",
            target = gPlayer,
            cover = POINTLIST._4_02_NERD_SCOUT2_01,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p2_scout_cover"
        }
    })
    L_PedLoadPoint(p_wave2, {
        {
            model = 8,
            point = POINTLIST._4_02_P2_NERD01,
            name = "p2_1",
            target = gPlayer,
            cover = POINTLIST._4_02_P2_NERD01,
            p_weapon = 309,
            ammo = 50,
            cover_file = "4_02_p1_1_cover"
        },
        {
            model = 7,
            point = POINTLIST._4_02_P2_NERD02,
            name = "p2_2",
            target = gPlayer,
            cover = POINTLIST._4_02_P2_NERD02,
            p_weapon = 301,
            ammo = 50,
            cover_file = "4_02_p1_1_cover"
        },
        {
            model = 9,
            point = POINTLIST._4_02_P2_NERD03,
            name = "p2_3",
            target = gPlayer,
            cover = POINTLIST._4_02_P2_NERD03,
            p_weapon = 305,
            ammo = 50,
            cover_file = "4_02_p1_scout_cover"
        },
        {
            model = 7,
            point = POINTLIST._4_02_P2_NERD05,
            name = "p2_5",
            target = gPlayer,
            cover = POINTLIST._4_02_P2_NERD05,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p1_scout_cover"
        }
    })
end

function F_SetUpEnemies3()
    L_PedLoadPoint(p_wave_scout3, {
        {
            model = 7,
            point = POINTLIST._4_02_P3_NERD_SCOUT1_01,
            name = "p3_scout1",
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD_SCOUT1_02,
            p_weapon = 305,
            ammo = 50,
            cover_file = "4_02_p3_scout1_cover"
        },
        {
            model = 8,
            point = POINTLIST._4_02_P3_NERD_SCOUT2_01,
            name = "p3_scout2",
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD_SCOUT2_02,
            p_weapon = 305,
            ammo = 50,
            cover_file = "4_02_p3_scout2_cover"
        }
    })
    L_PedLoadPoint(p_wave3, {
        {
            model = 8,
            point = POINTLIST._4_02_P3_NERD01,
            name = "p3_1",
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD01,
            p_weapon = 301,
            ammo = 50,
            cover_file = "4_02_p3_1_cover"
        },
        {
            model = 9,
            point = POINTLIST._4_02_P3_NERD02,
            name = "p3_2",
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD02,
            p_weapon = 305,
            ammo = 50,
            cover_file = "4_02_p2_scout_cover"
        },
        {
            model = 7,
            point = POINTLIST._4_02_P3_NERD03,
            name = "p3_3",
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD03,
            p_weapon = 309,
            ammo = 50,
            cover_file = "4_02_p3_3_cover"
        },
        {
            model = 8,
            point = POINTLIST._4_02_P3_NERD05,
            name = "p3_5",
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD05,
            p_weapon = 305,
            ammo = 50,
            cover_file = "4_02_p3_5_cover"
        },
        {
            model = 7,
            point = POINTLIST._4_02_P3_NERD06,
            name = "p3_6",
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD06,
            p_weapon = 301,
            ammo = 50,
            cover_file = "4_02_p3_6_cover"
        },
        {
            model = 9,
            point = POINTLIST._4_02_P3_NERD07,
            name = "p3_7",
            target = gPlayer,
            cover = POINTLIST._4_02_P3_NERD07,
            p_weapon = 305,
            ammo = 50,
            cover_file = "4_02_p3_7_cover"
        }
    })
end

function F_SetUpEnemies4()
    L_PedLoadPoint(p_wave4, {
        {
            model = 9,
            point = POINTLIST._4_02_P4_NERD02,
            name = "p4_2",
            target = gPlayer,
            cover = POINTLIST._4_02_P4_NERD02,
            p_weapon = 305,
            ammo = 50,
            cover_file = "4_02_p4_2_cover"
        },
        {
            model = 8,
            point = POINTLIST._4_02_P4_NERD03,
            name = "p4_3",
            target = gPlayer,
            cover = POINTLIST._4_02_P4_NERD03,
            p_weapon = 301,
            ammo = 50,
            cover_file = "4_02_p3_1_cover"
        },
        {
            model = 7,
            point = POINTLIST._4_02_P4_NERD04,
            name = "p4_4",
            target = gPlayer,
            cover = POINTLIST._4_02_P4_NERD04,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p3_scout2_cover"
        },
        {
            model = 9,
            point = POINTLIST._4_02_P4_NERD05,
            name = "p4_5",
            target = gPlayer,
            cover = POINTLIST._4_02_P4_NERD05,
            p_weapon = 305,
            ammo = 50,
            cover_file = "4_02_p3_1_cover"
        },
        {
            model = 8,
            point = POINTLIST._4_02_P4_NERD06,
            name = "p4_6",
            target = gPlayer,
            cover = POINTLIST._4_02_P4_NERD06,
            p_weapon = 307,
            ammo = 50,
            cover_file = "4_02_p3_1_cover"
        }
    })
end

function MissionSetup()
    DATLoad("Test_4_02.DAT", 2)
    DATInit()
    AreaTransitionPoint(0, POINTLIST._4_02_TEMP_START_TEST)
    DisablePOI()
    WeaponRequestModel(303)
    WeaponRequestModel(305)
    WeaponRequestModel(307)
    WeaponRequestModel(301)
    WeaponRequestModel(309)
    L_ObjectiveSetParam({
        Obj07 = {
            successConditions = { F_Scout_Spotted_Player },
            stopOnCompleted = false,
            completeActions = { F_Scout_Warning }
        },
        Obj08 = {
            successConditions = { F_Player_Approaching_Wave2 },
            stopOnCompleted = false,
            completeActions = { F_Wave2 }
        },
        Obj09 = {
            successConditions = { F_Player_Approaching_Wave3 },
            stopOnCompleted = false,
            completeActions = { F_Wave3 }
        },
        Obj10 = {
            successConditions = { F_Player_Approaching_Wave4 },
            stopOnCompleted = false,
            completeActions = { F_Wave4 }
        },
        Obj11 = {
            successConditions = { T_Player_Enters_Ob1 },
            stopOnCompleted = false,
            completeActions = { T_Player_Enters_Ob2 }
        },
        Obj12 = {
            successConditions = { F_Strong_Door1 },
            stopOnCompleted = false,
            completeActions = { F_Strong_Door2 }
        },
        Obj13 = {
            successConditions = { F_Player_On_Cannon1 },
            stopOnCompleted = false,
            completeActions = { F_Player_On_Cannon2 }
        },
        Obj14 = {
            successConditions = { F_Breaker_Hint1_1 },
            stopOnCompleted = false,
            completeActions = { F_Breaker_Hint1_2 }
        },
        Obj15 = {
            successConditions = { F_Breaker_Hint2_1 },
            stopOnCompleted = false,
            completeActions = { F_Breaker_Hint2_2 }
        },
        Obj16 = {
            successConditions = { F_Breaker_Hint3_1 },
            stopOnCompleted = false,
            completeActions = { F_Breaker_Hint3_2 }
        },
        Obj17 = {
            successConditions = { F_Delete_Wave1_1 },
            stopOnCompleted = false,
            completeActions = { F_Delete_Wave1_2 }
        }
    })
end

function main()
    AreaOverridePopulation(5, 0, 0, 1, 0, 1, 1, 2, 0, 0, 0, 0, 0)
    GiveWeaponToPlayer(303)
    GiveWeaponToPlayer(306)
    PlayerSetControl(1)
    F_PropSet()
    CameraReturnToPlayer()
    CreateThread("T_ObjectiveMonitor")
    CreateThread("T_Water_Cam")
    CreateThread("T_Regular_Cam")
    F_SetUpEnemies1()
    L_PropLoad(coverProps, cover_PropTable)
    cover_props_set = true
    CreateThread("T_ObjectiveMonitor")
    while mission_success == false do
        Wait(0)
    end
    Wait(3000)
    MissionSucceed()
end

function T_Water_Cam()
    while true do
        while water_cam == false do
            if PlayerIsInTrigger(TRIGGER._4_02_WATER) then
                water_cam = true
                CameraAllowChange(true)
                CameraReturnToPlayer()
                Wait(0)
                CameraSetShot(1, "WaterPuzzleCam", true)
                CameraAllowChange(false)
            end
            Wait(0)
        end
        Wait(0)
    end
    Wait(0)
    collectgarbage()
end

function T_Regular_Cam()
    while true do
        while water_cam == true do
            if not PlayerIsInTrigger(TRIGGER._4_02_WATER) then
                water_cam = false
                CameraAllowChange(true)
                CameraReturnToPlayer(false)
            end
            Wait(0)
        end
        Wait(0)
    end
    Wait(0)
    collectgarbage()
end

function F_Scout_Spotted_Player()
    return PlayerIsInTrigger(TRIGGER._4_02_SPOTTED_SCOUT)
end

function F_Scout_Warning()
    PedSetTypeToTypeAttitude(1, 13, 0)
    PAnimSetInvulnerable(TRIGGER._4_02_BAR_01, true)
    PAnimMakeTargetable(TRIGGER._4_02_BAR_01, false)
    PAnimSetInvulnerable(TRIGGER._4_02_BAR_02, true)
    PAnimMakeTargetable(TRIGGER._4_02_BAR_02, false)
    scout = L_PedGetID("name", "p1_scout")
    PedSetHealth(scout, 60)
    PedDestroyWeapon(scout, WEAPON_YARDSTICK) -- ! Modified here
    PedClearAllWeapons(scout)
    PedSetWeapon(scout, 307, 50)
    PedCoverSetFromProfile(scout, -1, POINTLIST._4_02_NERD_SCOUT_03, "4_02_p1_scout_cover")
    WaitSkippable(3000)
    L_PedExec(p_wave1, AddBlipForChar, "id", 2, 2, 1)
    L_PedExec(p_wave1, PedSetHealth, "id", 60)
    L_PedExec(p_wave1, PedDestroyWeapon, "id", WEAPON_YARDSTICK) -- ! Modified here
    L_PedExec(p_wave1, PedClearAllWeapons, "id")
    L_PedExec(p_wave1, PedOverrideStat, "id", 3, 80)
    L_PedExec(p_wave1, PedSetWeapon, "id", "p_weapon", "ammo")
    L_PedExec(p_wave1, PedCoverSetFromProfile, "id", "target", "cover", "cover_file")
    TextPrint("4_02_25", 3, 2)
    p1_5 = L_PedGetID("name", "p1_5")
    PedOverrideStat(p1_5, 0, 362)
    PedOverrideStat(p1_5, 1, 100)
    p1_2 = L_PedGetID("name", "p1_2")
    PedOverrideStat(p1_2, 0, 362)
    PedOverrideStat(p1_2, 1, 100)
end

function F_Player_Approaching_Wave2()
    return PlayerIsInTrigger(TRIGGER._4_02_P_WAVE2)
end

function F_Wave2()
    F_SetUpEnemies2()
    Wait(50)
    scout2 = L_PedGetID("name", "p2_scout")
    AddBlipForChar(scout2, 2, 2, 1)
    Wait(1000)
    TextPrint("4_02_45", 3, 2)
    PedDestroyWeapon(scout2, WEAPON_YARDSTICK) -- ! Modified here
    PedClearAllWeapons(scout2)
    PedSetHealth(scout2, 60)
    PedSetWeapon(scout2, 307, 50)
    PedCoverSetFromProfile(scout2, gPlayer, POINTLIST._4_02_NERD_SCOUT2_01, "4_02_p1_scout_cover")
    L_PedExec(p_wave2, AddBlipForChar, "id", 2, 2, 1)
    L_PedExec(p_wave2, PedSetHealth, "id", 60)
    L_PedExec(p_wave2, PedDestroyWeapon, "id", WEAPON_YARDSTICK) -- ! Modified here
    L_PedExec(p_wave2, PedClearAllWeapons, "id")
    L_PedExec(p_wave2, PedOverrideStat, "id", 3, 80)
    L_PedExec(p_wave2, PedSetWeapon, "id", "p_weapon", "ammo")
    L_PedExec(p_wave2, PedCoverSetFromProfile, "id", "target", "cover", "cover_file")
    p2_3 = L_PedGetID("name", "p2_3")
    PedOverrideStat(p2_3, 0, 362)
    PedOverrideStat(p2_3, 1, 100)
    p2_5 = L_PedGetID("name", "p2_5")
    PedOverrideStat(p2_5, 0, 362)
    PedOverrideStat(p2_5, 1, 100)
    Wait(5000)
    TextPrint("4_02_26", 3, 2)
end

function F_Delete_Wave1_1()
    return PlayerIsInTrigger(TRIGGER._4_02_DELETE_WAVE1)
end

function F_Delete_Wave1_2()
    if not L_PedAllDead(p_wave1) then
        L_PedExec(p_wave1, PedDelete, "id")
    end
end

function F_Player_Approaching_Wave3()
    return PlayerIsInTrigger(TRIGGER._4_02_P_WAVE3)
end

function F_Wave3()
    F_SetUpEnemies3()
    scout4 = L_PedGetID("name", "p3_scout2")
    Wait(1000)
    TextPrint("4_02_46", 3, 2)
    L_PedExec(p_wave_scout3, PedSetHealth, "id", 60)
    L_PedExec(p_wave_scout3, PedAttack, gPlayer, 3)
    L_PedExec(p_wave_scout3, AddBlipForChar, "id", 2, 2, 1)
    PAnimSetInvulnerable(TRIGGER._4_02_BAR_03, true)
    PAnimMakeTargetable(TRIGGER._4_02_BAR_03, false)
    L_PedExec(p_wave3, AddBlipForChar, "id", 2, 2, 1)
    L_PedExec(p_wave3, PedSetHealth, "id", 60)
    L_PedExec(p_wave3, PedDestroyWeapon, "id", WEAPON_YARDSTICK) -- ! Modified here
    L_PedExec(p_wave3, PedClearAllWeapons, "id")
    L_PedExec(p_wave3, PedSetWeapon, "id", "p_weapon", "ammo")
    L_PedExec(p_wave3, PedCoverSetFromProfile, "id", "target", "cover", "cover_file")
    PedOverrideStat(scout4, 0, 362)
    PedOverrideStat(scout4, 1, 100)
    Wait(3000)
    TextPrint("4_02_27", 3, 2)
end

function F_Player_Approaching_Wave4()
    return PlayerIsInTrigger(TRIGGER._4_02_P_WAVE4)
end

function F_Wave4()
    if not L_PedAllDead(p_wave2) then
        L_PedExec(p_wave2, PedDelete, "id")
    end
    if not L_PedAllDead(p_wave_scout2) then
        L_PedExec(p_wave_scout2, PedDelete, "id")
    end
    AreaSetDoorLocked(TRIGGER._SCGATE_OBSERVATORY, true)
    PAnimSetInvulnerable(TRIGGER._DT_OBSERVATORY, true)
    Wait(0)
    spud_nerd = PedCreatePoint(7, POINTLIST._4_02_SPUD_NERD01)
    PedSetEffectedByGravity(spud_nerd, false)
    Wait(50)
    PedDestroyWeapon(spud_nerd, WEAPON_YARDSTICK) -- ! Modified here
    PedClearAllWeapons(spud_nerd)
    PedClearObjectives(spud_nerd)
    AddBlipForChar(spud_nerd, 2, 2, 1)
    PedOverrideStat(spud_nerd, 3, 80)
    PedSetHealth(spud_nerd, 60)
    Wait(50)
    PedSetActionNode(spud_nerd, "/Global/Ambient/MissionSpec/GetOnCannon", "Act/Anim/Ambient.act")
    PedLockTarget(spud_nerd, gPlayer, 3)
    CameraSetWidescreen(true)
    PedStop(gPlayer)
    PlayerSetControl(0)
    Wait(1000)
    SoundSetAudioFocusCamera()
    CameraLookAtObject(spud_nerd, 2, true)
    CameraSetPath(PATH._4_02_CANNON_PATH, true)
    Wait(1500)
    TextPrint("4_02_29", 4, 2)
    Wait(2500)
    TextPrint("4_02_30", 4, 2)
    Wait(2500)
    TextPrint("4_02_31", 3, 2)
    Wait(3000)
    TextPrint("4_02_32", 4, 2)
    Wait(3000)
    PedSetTaskNode(spud_nerd, "/Global/AI/GeneralObjectives/SpecificObjectives/UseSpudCannon", "Act/AI/AI.act")
    TextPrint("4_02_33", 3, 2)
    Wait(3000)
    PedLockTarget(spud_nerd, -1)
    PedClearObjectives(spud_nerd)
    PedSetActionTree(spud_nerd, "/Global/N_Melee_A", "Act/Anim/N_Melee_A.act")
    PedIgnoreStimuli(spud_nerd, true)
    spud_line_played = true
    local fx, fy, fz = GetPointList(POINTLIST._4_02_FUSE_POINT)
    CameraLookAtXYZ(fx, fy, fz, false)
    Wait(500)
    TextPrint("4_02_34", 3, 2)
    Wait(3000)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    CameraReturnToPlayer()
    SoundSetAudioFocusPlayer()
    F_SetUpEnemies4()
    L_PedExec(p_wave4, AddBlipForChar, "id", 2, 2, 1)
    L_PedExec(p_wave4, PedSetHealth, "id", 60)
    L_PedExec(p_wave4, PedDestroyWeapon, "id", WEAPON_YARDSTICK) -- ! Modified here
    L_PedExec(p_wave4, PedClearAllWeapons, "id")
    L_PedExec(p_wave4, PedSetWeapon, "id", "p_weapon", "ammo")
    L_PedExec(p_wave4, PedCoverSetFromProfile, "id", "target", "cover", "cover_file")
    p4_2 = L_PedGetID("name", "p4_2")
    PedOverrideStat(p4_2, 0, 362)
    PedOverrideStat(p4_2, 1, 100)
    CreateThread("T_Breaker_Box")
    CreateThread("T_Delete_Wave3_2")
    mis_obj04 = MissionObjectiveAdd("4_02_48")
end

function T_Delete_Wave3_2()
    while wave3_dead == false do
        if PlayerIsInTrigger(TRIGGER._4_02_DELETE_WAVE3) then
            wave3_dead = true
            PedDelete(spud_nerd)
            Wait(50)
            spud_nerd = PedCreatePoint(7, POINTLIST._4_02_SPUD_NERD01)
            PedSetEffectedByGravity(spud_nerd, false)
            Wait(50)
            PedDestroyWeapon(spud_nerd, WEAPON_YARDSTICK) -- ! Modified here
            PedClearAllWeapons(spud_nerd)
            PedClearObjectives(spud_nerd)
            AddBlipForChar(spud_nerd, 2, 2, 1)
            PedOverrideStat(spud_nerd, 3, 80)
            PedSetHealth(spud_nerd, 60)
            Wait(50)
            PedSetActionNode(spud_nerd, "/Global/Ambient/MissionSpec/GetOnCannon", "Act/Anim/Ambient.act")
            PedLockTarget(spud_nerd, gPlayer, 3)
            Wait(50)
            PedSetTaskNode(spud_nerd, "/Global/AI/GeneralObjectives/SpecificObjectives/UseSpudCannon", "Act/AI/AI.act")
            if not L_PedAllDead(p_wave3) then
                L_PedExec(p_wave3, PedDelete, "id")
            end
            if not L_PedAllDead(p_wave_scout3) then
                L_PedExec(p_wave_scout3, PedDelete, "id")
            end
            Wait(3500)
            TextPrint("4_02_35", 3, 2)
            Wait(3000)
            TextPrint("4_02_36", 3, 2)
            flux_line_played = true
        end
        Wait(0)
    end
    Wait(0)
    collectgarbage()
end

function T_Breaker_Box()
    while breaker_box_alive == true do
        local index_light, simplePool_light = PAnimGetPoolIndex("SC_ObservTrans", 33.1794, -130.376, 10.681, 1)
        if PAnimIsDestroyed(index_light, simplePool_light) then
            breaker_box_alive = false
            MissionObjectiveComplete(mis_obj04)
            TextPrint("4_02_38", 3, 2)
            Wait(3000)
            AreaSetDoorLocked(TRIGGER._SCGATE_OBSERVATORY, false)
            PAnimOpenDoor(TRIGGER._SCGATE_OBSERVATORY)
            PedDelete(spud_nerd)
            TextPrint("4_02_37", 3, 2)
            spud_nerd = PedCreatePoint(7, POINTLIST._4_02_SPUD_NERD01)
            PedFollowPath(spud_nerd, PATH._4_02_SPUD_PATH, 0, 2)
            local snx, sny, snz = GetPointList(POINTLIST._4_02_SPUD_PATH_STOP)
            while not PedIsInAreaXYZ(spud_nerd, snx, sny, snz, 2, 0) do
                Wait(0)
            end
            PedSetPedToTypeAttitude(spud_nerd, 1, 4)
            PedMakeAmbient(spud_nerd)
            PedClearObjectives(spud_nerd)
            PedWander(spud_nerd, 2)
        end
        Wait(0)
    end
    Wait(0)
    collectgarbage()
end

function F_Breaker_Hint1_1()
    return spud_line_played and breaker_box_alive and flux_line_played
end

function F_Breaker_Hint1_2()
    TextPrint("4_02_52", 3, 1)
    mis_obj04 = MissionObjectiveAdd("4_02_52")
    hint_line1 = true
end

function F_Breaker_Hint2_1()
    return hint_line1 and breaker_box_alive and flux_line_played
end

function F_Breaker_Hint2_2()
    Wait(30000)
    TextPrint("4_02_40", 3, 2)
    hint_line2 = true
end

function F_Breaker_Hint3_1()
    return hint_line2 and breaker_box_alive and flux_line_played
end

function F_Breaker_Hint3_2()
    Wait(30000)
    TextPrint("4_02_41", 3, 2)
end

function F_Player_On_Cannon1()
    return PlayerIsInTrigger(TRIGGER._4_02_PLAYER_ON_CANNONT)
end

function F_Player_On_Cannon2()
    PAnimSetInvulnerable(TRIGGER._DT_OBSERVATORY, false)
    PAnimOverrideDamage(TRIGGER._DT_OBSERVATORY, 180)
    PAnimShowHealthBar(TRIGGER._DT_OBSERVATORY, true, "4_02_47")
    PAnimMakeTargetable(TRIGGER._DT_OBSERVATORY, true)
    CreateThread("T_Door_Health")
    TextPrint("4_02_42", 3, 2)
    on_cannon = true
    if cannon_blip then
        BlipRemove(spudcannon_blip)
    end
    CreateThread("T_Spawn_Window")
    Wait(500)
    CreateThread("T_Activate")
end

function T_Spawn_Window()
    while true do
        if window_spawners == false then
            window_spawners = true
            F_Spawn_The_Window_Nerds()
        end
        Wait(0)
    end
    Wait(0)
    collectgarbage()
end

function T_Activate()
    while true do
        if spawners_activated == false then
            spawners_activated = true
            F_ActivateSpawners()
        end
        Wait(0)
    end
    Wait(0)
    collectgarbage()
end

function T_Door_Health()
    while door_dead == false do
        if PAnimIsDestroyed(TRIGGER._DT_OBSERVATORY) then
            door_dead = true
            PAnimHideHealthBar(TRIGGER._DT_OBSERVATORY)
            PAnimMakeTargetable(TRIGGER._DT_OBSERVATORY, false)
            PAnimSetActionNode(TRIGGER._DT_OBSERVATORY, "/Global/scObsDr/Functions/Open", "Act/Props/scObsDr.act")
            TextPrint("4_02_43", 3, 2)
            AreaMissionSpawnerSetActivated(nerd_spawner1, false)
            AreaMissionSpawnerSetActivated(nerd_spawner2, false)
            AreaMissionSpawnerSetActivated(nerd_spawner3, false)
            AreaMissionSpawnerSetActivated(nerd_spawner5, false)
            AreaMissionSpawnerSetActivated(nerd_spawner6, false)
            AreaMissionSpawnerSetActivated(nerd_spawner7, false)
            ob_blip2 = BlipAddPoint(POINTLIST._4_02_OBSERVATORY, 0)
            ob_blip2_set = true
        end
        Wait(0)
    end
    Wait(0)
    collectgarbage()
end

function T_Player_Enters_Ob1()
    return PlayerIsInTrigger(TRIGGER._4_02_FINALE)
end

function T_Player_Enters_Ob2()
    mission_won = true
    TextPrint("4_02_53", 3, 1)
    MissionSucceed()
end

function F_ActivateSpawners()
    AreaMissionSpawnerSetActivated(nerd_spawner1, true)
    AreaMissionSpawnerSetActivated(nerd_spawner2, true)
    AreaMissionSpawnerSetActivated(nerd_spawner3, true)
    AreaMissionSpawnerSetActivated(nerd_spawner5, true)
    AreaMissionSpawnerSetActivated(nerd_spawner6, true)
    AreaMissionSpawnerSetActivated(nerd_spawner7, true)
end

function F_Spawn_The_Window_Nerds()
    local random_spawn1 = 0
    local random_delay1 = 0
    random_spawn = math.random(1000, 3000)
    random_delay = math.random(1000, 3000)
    nerd_spawner1 = AreaAddMissionSpawner(1, 1, -1, 1, random_spawn1, random_delay1)
    local random_spawn2 = 0
    local random_delay2 = 0
    random_spawn2 = math.random(1000, 3000)
    random_delay2 = math.random(1000, 3000)
    nerd_spawner2 = AreaAddMissionSpawner(1, 1, -1, 1, random_spawn2, random_delay2)
    local random_spawn3 = 0
    local random_delay3 = 0
    random_spawn3 = math.random(1000, 3000)
    random_delay3 = math.random(1000, 3000)
    nerd_spawner3 = AreaAddMissionSpawner(1, 1, -1, 1, random_spawn3, random_delay3)
    local random_spawn5 = 0
    local random_delay5 = 0
    random_spawn5 = math.random(1000, 3000)
    random_delay5 = math.random(1000, 3000)
    nerd_spawner5 = AreaAddMissionSpawner(1, 1, -1, 1, random_spawn5, random_delay5)
    local random_spawn6 = 0
    local random_delay6 = 0
    random_spawn6 = math.random(1000, 3000)
    random_delay6 = math.random(1000, 3000)
    nerd_spawner6 = AreaAddMissionSpawner(1, 1, -1, 1, random_spawn6, random_delay6)
    local random_spawn7 = 0
    local random_delay7 = 0
    random_spawn7 = math.random(1000, 3000)
    random_delay7 = math.random(1000, 3000)
    nerd_spawner7 = AreaAddMissionSpawner(1, 1, -1, 1, random_spawn7, random_delay7)
    AreaMissionSpawnerSetCallback(nerd_spawner1, F_SpawnerAttackPlayer1)
    ns_point1 = AreaAddSpawnLocation(nerd_spawner1, POINTLIST._4_02_O_WN1_1, TRIGGER._4_02_O_WN1_1T)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner1, ns_point1, 7)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner1, ns_point1, 8)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner1, ns_point1, 9)
    AreaMissionSpawnerSetCallback(nerd_spawner2, F_SpawnerAttackPlayer2)
    ns_point2 = AreaAddSpawnLocation(nerd_spawner2, POINTLIST._4_02_O_WN2_1, TRIGGER._4_02_O_WN2_1T)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner2, ns_point2, 7)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner2, ns_point2, 8)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner2, ns_point2, 9)
    AreaMissionSpawnerSetCallback(nerd_spawner3, F_SpawnerAttackPlayer3)
    ns_point3 = AreaAddSpawnLocation(nerd_spawner3, POINTLIST._4_02_O_WN3_1, TRIGGER._4_02_O_WN3_1T)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner3, ns_point3, 7)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner3, ns_point3, 8)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner3, ns_point3, 9)
    AreaMissionSpawnerSetCallback(nerd_spawner5, F_SpawnerAttackPlayer5)
    ns_point5 = AreaAddSpawnLocation(nerd_spawner5, POINTLIST._4_02_O_WN4_1, TRIGGER._4_02_O_WN4_1T)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner5, ns_point5, 7)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner5, ns_point5, 8)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner5, ns_point5, 9)
    AreaMissionSpawnerSetCallback(nerd_spawner6, F_SpawnerAttackPlayer6)
    ns_point6 = AreaAddSpawnLocation(nerd_spawner6, POINTLIST._4_02_O_R1_1, TRIGGER._4_02_O_R1_1T)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner6, ns_point6, 7)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner6, ns_point6, 8)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner6, ns_point6, 9)
    AreaMissionSpawnerSetCallback(nerd_spawner7, F_SpawnerAttackPlayer7)
    ns_point7 = AreaAddSpawnLocation(nerd_spawner7, POINTLIST._4_02_O_R2_1, TRIGGER._4_02_O_R2_1T)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner7, ns_point7, 7)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner7, ns_point7, 8)
    AreaAddPedModelIdToSpawnLocation(nerd_spawner7, ns_point7, 9)
end

function F_SpawnerAttackPlayer1(idPed, nerd_spawner1)
    L_PedLoad("spawned_nerds1", {
        { id = idPed }
    })
    PedClearObjectives(idPed)
    PedDestroyWeapon(idPed, WEAPON_YARDSTICK) -- ! Modified here
    PedClearAllWeapons(idPed)
    PedSetWeapon(idPed, 305, 50)
    PedLockTarget(idPed, gPlayer, 3)
    PedCoverSetFromProfile(idPed, gPlayer, POINTLIST._4_02_O_WN1_2, "4_02_window_cover")
end

function F_SpawnerAttackPlayer2(idPed, nerd_spawner2)
    L_PedLoad("spawned_nerds2", {
        { id = idPed }
    })
    PedClearObjectives(idPed)
    PedDestroyWeapon(idPed, WEAPON_YARDSTICK) -- ! Modified here
    PedClearAllWeapons(idPed)
    PedSetWeapon(idPed, 305, 50)
    PedLockTarget(idPed, gPlayer, 3)
    PedCoverSetFromProfile(idPed, gPlayer, POINTLIST._4_02_O_WN2_2, "4_02_window_cover")
end

function F_SpawnerAttackPlayer3(idPed, nerd_spawner3)
    L_PedLoad("spawned_nerds3", {
        { id = idPed }
    })
    PedClearObjectives(idPed)
    PedDestroyWeapon(idPed, WEAPON_YARDSTICK) -- ! Modified here
    PedClearAllWeapons(idPed)
    PedSetWeapon(idPed, 305, 50)
    PedLockTarget(idPed, gPlayer, 3)
    PedCoverSetFromProfile(idPed, gPlayer, POINTLIST._4_02_O_WN3_2, "4_02_window_cover")
end

function F_SpawnerAttackPlayer5(idPed, nerd_spawner5)
    L_PedLoad("spawned_nerds5", {
        { id = idPed }
    })
    PedClearObjectives(idPed)
    PedDestroyWeapon(idPed, WEAPON_YARDSTICK) -- ! Modified here
    PedClearAllWeapons(idPed)
    PedSetWeapon(idPed, 305, 50)
    PedLockTarget(idPed, gPlayer, 3)
    PedCoverSetFromProfile(idPed, gPlayer, POINTLIST._4_02_O_WN4_2, "4_02_window_cover")
end

function F_SpawnerAttackPlayer6(idPed, nerd_spawner6)
    L_PedLoad("spawned_nerds6", {
        { id = idPed }
    })
    PedClearObjectives(idPed)
    PedDestroyWeapon(idPed, WEAPON_YARDSTICK) -- ! Modified here
    PedClearAllWeapons(idPed)
    PedSetWeapon(idPed, 305, 50)
    PedLockTarget(idPed, gPlayer, 3)
    PedCoverSetFromProfile(idPed, gPlayer, POINTLIST._4_02_O_R1_2, "4_02_window_cover")
end

function F_SpawnerAttackPlayer7(idPed, nerd_spawner7)
    L_PedLoad("spawned_nerds7", {
        { id = idPed }
    })
    PedClearObjectives(idPed)
    PedDestroyWeapon(idPed, WEAPON_YARDSTICK) -- ! Modified here
    PedClearAllWeapons(idPed)
    PedSetWeapon(idPed, 305, 50)
    PedLockTarget(idPed, gPlayer, 3)
    PedCoverSetFromProfile(idPed, gPlayer, POINTLIST._4_02_O_R2_2, "4_02_window_cover")
end

function F_Strong_Door1()
    return on_cannon == false and PlayerIsInTrigger(TRIGGER._DT_OBSERVATORY)
end

function F_Strong_Door2()
    TextPrint("4_02_44", 3, 2)
    BlipRemove(ob_blip)
    ob_blip_remove = true
    spudcannon_blip = BlipAddPoint(POINTLIST._4_02_SPUD_NERD01, 0)
    cannon_blip = true
end

function F_FailMission()
    mission_completed = true
    TextPrint("M_FAIL", 3, 1)
    Wait(3000)
    MissionFail()
end

function MissionCleanup()
    if cover_props_set then
        L_PropCleanup(coverProps)
    end
    if ob_blip2_set then
        BlipRemove(ob_blip2)
    end
    if ob_blip_remove then
        BlipRemove(ob_blip)
    end
    AreaEnableAllPatrolPaths()
    CameraReturnToPlayer()
    PAnimSetActionNode(TRIGGER._DT_OBSERVATORY, "/Global/scObsDr/Functions/Close", "/Act/Props/scObsDr.act")
    ToggleHUDComponentVisibility(0, true)
    EnablePOI()
    DATUnload(2)
    PlayerSetControl(1)
end
