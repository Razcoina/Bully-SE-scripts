ImportScript("Library\\LibTable.lua")
ImportScript("Library\\LibPed.lua")
ImportScript("Library\\LibPropNew.lua")
local player_in_trigger = 1
local timer_on = true
local wait_on = false
local mission_completed = false
local melvin, thad, damon, dan, kirby, fake_jock1, fake_jock2, fake_jock3, fake_nerd1, fake_nerd2, fake_player, fake_ref
local playerProps = "A"
local enemyProps = "B"
local edgeProps = "C"
local myteamGroup = "D"
local enemyteamGroup = "E"
local mytable = {}
local myteamcovertable = {}
local enemyteamcovertable = {}
local player_PropTable = {}
local enemy_PropTable = {}
local edge_PropTable = {}
local cover_chance
local crowd = {}
local crouch1 = false
local crouch2 = false
local crouch3 = false
local crouch4 = false
local CrouchHint1, CrouchHint2, CrouchHint3, CrouchHint4
local melvin_dead = false
local thad_dead = false
local dan_dead = false
local damon_dead = false
local kirby_dead = false
local e_size, m_size
local kill_jocks = false

function MissionSetup()
    CameraFade(50, 0)
    DATLoad("3_R06_A.DAT", 2)
    DATInit()
    if ChapterGet() < 4 then
        ChapterSet(4)
    end
    AreaTransitionPoint(0, POINTLIST._3_R06_CS_PLAYER)
    F_PropSet()
    AreaClearAllPeds()
    AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    AreaDeactivatePopulationTrigger(TRIGGER._JOCKS)
    L_PropLoad(playerProps, player_PropTable)
    L_PropLoad(enemyProps, enemy_PropTable)
    L_PropLoad(edgeProps, edge_PropTable)
    SoundPlayStream("zzzPat_limbo.rsm", 0.25)
end

function main()
    CameraFade(50, 0)
    PlayerSetControl(0)
    WeatherSet(5)
    PlayerUnequip()
    while WeaponEquipped() do
        Wait(0)
    end
    PlayerWeaponHudLock(true)
    CameraSetWidescreen(false)
    PlayerSetControl(1)
    CameraFade(1000, 1)
    PlayerSetPosPoint(POINTLIST._3_R06_PLAYERSTART)
    CameraReturnToPlayer()
    F_CreateTeams()
    F_CrowdSetup()
    F_NailJocks()
    melvin = L_PedGetID("name", "melvin")
    thad = L_PedGetID("name", "thad")
    damon = L_PedGetID("name", "damon")
    dan = L_PedGetID("name", "dan")
    kirby = L_PedGetID("name", "kirby")
    CreateThread("F_Snowballs")
    PedCoverSet(melvin, nil, POINTLIST._3_R06_COVER1_4, 1, 40, 1, 1, 2, 2, 2, 1, 1, 1, 1, false)
    PedCoverSet(thad, nil, POINTLIST._3_R06_COVER1_5, 1, 40, 1, 3, 5, 2, 2, 1, 1, 1, 1, false)
    PedCoverSet(damon, nil, POINTLIST._3_R06_COVER2_1, 1, 40, 1, 1, 2, 1, 1, 1, 1, 1, 1, false)
    PedCoverSet(dan, nil, POINTLIST._3_R06_COVER2_6, 1, 40, 1, 1, 2, 1, 1, 1, 1, 1, 1, false)
    PedCoverSet(kirby, nil, POINTLIST._3_R06_COVER2_5, 1, 40, 1, 3, 5, 2, 2, 1, 1, 1, 1, false)
    while true do
        Wait(0)
    end
    CreateThread("F_West_Boundary")
    CreateThread("F_East_Boundary")
    CreateThread("F_West_Boundary_Exit")
    CreateThread("F_East_Boundary_Exit")
    CreateThread("F_Check_Health")
    CreateThread("F_Snowballs")
    CreateThread("F_Enemy_Warning1")
    CreateThread("F_Melvin")
    CreateThread("F_Thad")
    CreateThread("F_Damon")
    CreateThread("F_Dan")
    CreateThread("F_Kirby")
    TextPrint("3_R06_12", 3, 1)
    Wait(3000)
    TextPrint("3_R06_13", 3, 1)
    Wait(3000)
    TextPrint("3_R06_14", 3, 1)
    Wait(3000)
    CrouchHint1 = CreateThread("F_CrouchHint1")
    CrouchHint2 = CreateThread("F_CrouchHint2")
    CrouchHint3 = CreateThread("F_CrouchHint3")
    CrouchHint4 = CreateThread("F_CrouchHint4")
    CreateThread("F_Player_Killed")
    CreateThread("F_Melvin_Health")
    CreateThread("F_Thad_Health")
    CreateThread("F_Dan_Health")
    CreateThread("F_Damon_Health")
    CreateThread("F_Kirby_Health")
    while mission_completed == false do
        Wait(0)
    end
    GiveWeaponToPlayer(305)
    MissionSucceed()
end

function F_CreateTeams()
    L_PedLoadPoint(myteamGroup, {
        {
            model = 6,
            point = POINTLIST._3_R06_PLAYER1_2,
            name = "melvin",
            current_point = POINTLIST._3_R06_COVER1_1
        },
        {
            model = 7,
            point = POINTLIST._3_R06_PLAYER1_3,
            name = "thad",
            current_point = POINTLIST._3_R06_COVER1_5
        }
    })
    L_PedLoadPoint(enemyteamGroup, {
        {
            model = 12,
            point = POINTLIST._3_R06_PLAYER2_1,
            name = "damon",
            current_point = POINTLIST._3_R06_COVER2_1
        },
        {
            model = 15,
            point = POINTLIST._3_R06_PLAYER2_2,
            name = "dan",
            current_point = POINTLIST._3_R06_COVER2_3
        },
        {
            model = 13,
            point = POINTLIST._3_R06_PLAYER2_3,
            name = "kirby",
            current_point = POINTLIST._3_R06_COVER2_5
        }
    })
    L_PedExec(myteamGroup, PedOverrideStat, "id", 3, 50)
    L_PedExec(enemyteamGroup, PedOverrideStat, "id", 3, 50)
    L_PedExec(myteamGroup, PedOverrideStat, "id", 11, 70)
    L_PedExec(enemyteamGroup, PedOverrideStat, "id", 11, 60)
    L_PedExec(myteamGroup, PedOverrideStat, "id", 1, 0)
    L_PedExec(enemyteamGroup, PedOverrideStat, "id", 1, 0)
    L_PedExec(myteamGroup, PedClearAllWeapons, "id")
    L_PedExec(enemyteamGroup, PedClearAllWeapons, "id")
    PedSetTypeToTypeAttitude(2, 13, 0)
    PedSetTypeToTypeAttitude(2, 1, 0)
    PedSetTypeToTypeAttitude(1, 2, 0)
    PedSetTypeToTypeAttitude(1, 13, 0)
    PedSetTypeToTypeAttitude(1, 5, 0)
    PedSetTypeToTypeAttitude(2, 5, 0)
    L_PedExec(myteamGroup, PedIgnoreStimuli, "id", true)
    L_PedExec(enemyteamGroup, PedIgnoreStimuli, "id", true)
    L_PedExec(myteamGroup, F_Ignore, "id")
end

function F_NailJocks()
    Wait(3000)
    if kill_jocks == false then
        TextPrint("3_R06_17", 3, 2)
        kill_jocks = true
    end
end

function F_Ignore(pedid)
    PedMakeTargetable(pedid, false)
end

function F_Check_Health()
    while true do
        if L_PedAllDead(enemyteamGroup) then
            TextPrint("3_R06_09", 3, 2)
            Wait(2000)
            CameraFade(2000, 0)
            GiveWeaponToPlayer(305)
            MissionSucceed()
        end
        Wait(0)
    end
    collectgarbage()
end

function F_Enemy_Warning1()
    while true do
        if PlayerIsInTrigger(TRIGGER._3_R06_ENEMY_SIDE) and player_in_trigger == 1 then
            TextPrint("3_R06_10", 3, 2)
            player_in_trigger = 0
            MissionTimerStart(10)
            CreateThread("F_BackOnMySide")
            Wait(10000)
            if PlayerIsInTrigger(TRIGGER._3_R06_ENEMY_SIDE) and player_in_trigger == 0 then
                MissionFail()
            end
        end
        Wait(0)
    end
    collectgarbage()
end

function F_BackOnMySide()
    while true do
        if PlayerIsInTrigger(TRIGGER._3_R06_PLAYER_SIDE) and player_in_trigger == 0 then
            player_in_trigger = 1
            MissionTimerStop()
            while wait_on == true do
                Wait(0)
            end
        end
        Wait(0)
    end
    collectgarbage()
end

function F_West_Boundary_Exit()
    while true do
        if PlayerIsInTrigger(TRIGGER._3_R06_WEST_EXIT) then
            TextPrint("3_R06_06", 3, 2)
            Wait(3000)
            MissionFail()
        end
        Wait(0)
    end
    collectgarbage()
end

function F_East_Boundary_Exit()
    while true do
        if PlayerIsInTrigger(TRIGGER._3_R06_EAST_EXIT) then
            TextPrint("3_R06_06", 3, 2)
            Wait(3000)
            MissionFail()
        end
        Wait(0)
    end
    collectgarbage()
end

function F_East_Boundary()
    while true do
        if PlayerIsInTrigger(TRIGGER._3_R06_EAST_BOUNDARY) and player_in_trigger == 1 then
            TextPrint("3_R06_07", 3, 2)
            player_in_trigger = 0
            MissionTimerStart(10)
            CreateThread("F_BoundaryIn")
            Wait(10000)
            if PlayerIsInTrigger(TRIGGER._3_R06_EAST_BOUNDARY) and player_in_trigger == 0 then
                MissionFail()
            end
        end
        Wait(0)
    end
    collectgarbage()
end

function F_West_Boundary()
    while true do
        if PlayerIsInTrigger(TRIGGER._3_R06_WEST_BOUNDARY) and player_in_trigger == 1 then
            TextPrint("3_R06_07", 3, 2)
            player_in_trigger = 0
            MissionTimerStart(10)
            CreateThread("F_BoundaryIn")
            Wait(10000)
            if PlayerIsInTrigger(TRIGGER._3_R06_WEST_BOUNDARY) and player_in_trigger == 0 then
                MissionFail()
            end
        end
        Wait(0)
    end
    collectgarbage()
end

function F_BoundaryIn()
    while true do
        if PlayerIsInTrigger(TRIGGER._3_R06_BOUNDARY) and player_in_trigger == 0 then
            player_in_trigger = 1
            MissionTimerStop()
            while wait_on == true do
                Wait(0)
            end
        end
        Wait(0)
    end
    collectgarbage()
end

function F_Player_Killed()
    while true do
        if PedGetHealth(gPlayer) <= 0 then
            TextPrint("3_R06_08", 3, 2)
            Wait(3000)
            CameraFade(3000, 0)
            MissionFail()
        end
        Wait(0)
    end
    collectgarbage()
end

function F_Melvin_Health()
    melvin = L_PedGetID("name", "melvin")
    while true do
        if PedGetHealth(melvin) <= 0 and melvin_dead == false then
            Wait(500)
            TextPrint("3_R06_18", 3, 2)
            F_TeamTableCount()
            melvin_dead = true
        end
        Wait(0)
    end
    collectgarbage()
end

function F_Thad_Health()
    thad = L_PedGetID("name", "thad")
    while true do
        if PedGetHealth(thad) <= 0 and thad_dead == false then
            Wait(500)
            TextPrint("3_R06_19", 3, 2)
            F_TeamTableCount()
            thad_dead = true
        end
        Wait(0)
    end
    collectgarbage()
end

function F_TeamTableCount()
    m_size = L_PedSize(myteamGroup) - L_PedDeadCount(myteamGroup)
    if m_size == 2 then
        Wait(3000)
        TextPrint("3_R06_20", 3, 2)
    elseif m_size == 1 then
        Wait(3000)
        TextPrint("3_R06_21", 3, 2)
    end
end

function F_Dan_Health()
    dan = L_PedGetID("name", "dan")
    while true do
        if PedGetHealth(dan) <= 0 and dan_dead == false then
            F_EnemyTeamTableCount()
            dan_dead = true
        end
        Wait(0)
    end
    collectgarbage()
end

function F_Damon_Health()
    damon = L_PedGetID("name", "damon")
    while true do
        if PedGetHealth(damon) <= 0 and damon_dead == false then
            F_EnemyTeamTableCount()
            damon_dead = true
        end
        Wait(0)
    end
    collectgarbage()
end

function F_Kirby_Health()
    kirby = L_PedGetID("name", "kirby")
    while true do
        if PedGetHealth(kirby) <= 0 and kirby_dead == false then
            F_EnemyTeamTableCount()
            kirby_dead = true
        end
        Wait(0)
    end
    collectgarbage()
end

function F_EnemyTeamTableCount()
    e_size = L_PedSize(enemyteamGroup) - L_PedDeadCount(enemyteamGroup)
    if e_size == 3 then
        TextPrint("3_R06_22", 3, 2)
    elseif e_size == 2 then
        TextPrint("3_R06_23", 3, 2)
    elseif e_size == 1 then
        TextPrint("3_R06_24", 3, 2)
    end
end

function F_PropSet()
    edge_PropTable = {
        {
            id = TRIGGER._3_R06_SNOWPILE_EDGE1
        },
        {
            id = TRIGGER._3_R06_SNOWPILE_EDGE2
        },
        {
            id = TRIGGER._3_R06_SNOWPILE_EDGE3
        },
        {
            id = TRIGGER._3_R06_SNOWPILE_EDGE4
        },
        {
            id = TRIGGER._3_R06_SNOWPILE_EDGE5
        },
        {
            id = TRIGGER._3_R06_SNOWPILE_EDGE6
        }
    }
    enemy_PropTable = {
        {
            id = TRIGGER._3_R06_SNOWPILE2_3,
            hp = 1,
            CustomSetup = F_SetHealth
        },
        {
            id = TRIGGER._3_R06_SNOWPILE2_4,
            hp = 1,
            CustomSetup = F_SetHealth
        },
        {
            id = TRIGGER._3_R06_SNOWPILE2_5,
            hp = 1,
            CustomSetup = F_SetHealth
        },
        {
            id = TRIGGER._3_R06_SNOWPILE2_6,
            hp = 1,
            CustomSetup = F_SetHealth
        }
    }
    player_PropTable = {
        {
            id = TRIGGER._3_R06_SNOWPILE1_1,
            hp = 1,
            CustomSetup = F_SetHealth
        },
        {
            id = TRIGGER._3_R06_SNOWPILE1_5,
            hp = 1,
            CustomSetup = F_SetHealth
        },
        {
            id = TRIGGER._3_R06_SNOWPILE1_6,
            hp = 1,
            CustomSetup = F_SetHealth
        }
    }
end

function F_CrowdSetup()
    crowd = {
        {
            model = 30,
            point = POINTLIST._3_R06_CROWD1,
            id = nil
        },
        {
            model = 35,
            point = POINTLIST._3_R06_CROWD2,
            id = nil
        },
        {
            model = 27,
            point = POINTLIST._3_R06_CROWD3,
            id = nil
        },
        {
            model = 22,
            point = POINTLIST._3_R06_CROWD4,
            id = nil
        },
        {
            model = 12,
            point = POINTLIST._3_R06_CROWD5,
            id = nil
        }
    }
    for i, entry in crowd do
        entry.id = PedCreatePoint(entry.model, entry.point, 0)
        PedMakeTargetable(entry.id, false)
        PedSetStationary(entry.id, true)
        PedSetFaction(entry.id, 5)
        PedSetCheering(entry.id, true)
    end
end

function F_SetHealth(prop)
    PAnimOverrideDamage(prop.id, prop.hp)
end

function MissionCleanup()
    SoundStopStream()
    PlayerWeaponHudLock(false)
    PlayerUnequip()
    L_PropCleanup(playerProps)
    L_PropCleanup(enemyProps)
    L_PropCleanup(edgeProps)
    collectgarbage()
    DATUnload(2)
end

function F_Snowballs()
    while true do
        L_PedExec(myteamGroup, PedSetWeapon, "id", 313, 1)
        L_PedExec(enemyteamGroup, PedSetWeapon, "id", 313, 1)
        Wait(2000)
    end
    Wait(0)
end

function F_CrouchHint1()
    while true do
        if PlayerIsInTrigger(TRIGGER._3_R06_CROUCH1) and crouch1 == false then
            TextPrint("3_R06_15", 3, 1)
            Wait(3000)
            TextPrint("3_R06_16", 3, 1)
            crouch1 = true
            crouch2 = true
            crouch3 = true
            crouch4 = true
            TerminateThread(CrouchHint2)
            TerminateThread(CrouchHint3)
            TerminateThread(CrouchHint4)
        end
        Wait(0)
    end
end

function F_CrouchHint2()
    while true do
        if PlayerIsInTrigger(TRIGGER._3_R06_CROUCH2) and crouch2 == false then
            TextPrint("3_R06_15", 3, 1)
            Wait(3000)
            TextPrint("3_R06_16", 3, 1)
            crouch1 = true
            crouch2 = true
            crouch3 = true
            crouch4 = true
            TerminateThread(CrouchHint1)
            TerminateThread(CrouchHint3)
            TerminateThread(CrouchHint4)
        end
        Wait(0)
    end
end

function F_CrouchHint3()
    while true do
        if PlayerIsInTrigger(TRIGGER._3_R06_CROUCH3) and crouch3 == false then
            TextPrint("3_R06_15", 3, 1)
            Wait(3000)
            TextPrint("3_R06_16", 3, 1)
            crouch1 = true
            crouch2 = true
            crouch3 = true
            crouch4 = true
            TerminateThread(CrouchHint1)
            TerminateThread(CrouchHint2)
            TerminateThread(CrouchHint4)
        end
        Wait(0)
    end
end

function F_CrouchHint4()
    while true do
        if PlayerIsInTrigger(TRIGGER._3_R06_CROUCH4) and crouch4 == false then
            TextPrint("3_R06_15", 3, 1)
            Wait(3000)
            TextPrint("3_R06_16", 3, 1)
            crouch1 = true
            crouch2 = true
            crouch3 = true
            crouch4 = true
            TerminateThread(CrouchHint1)
            TerminateThread(CrouchHint2)
            TerminateThread(CrouchHint3)
        end
        Wait(0)
    end
end

function F_Melvin()
    melvin = L_PedGetID("name", "melvin")
    while not (PedIsDead(melvin) or L_PedAllDead(enemyteamGroup)) do
        Wait(1000)
        PedMoveToPoint(melvin, 1, POINTLIST._3_R06_COVER1_4)
        Wait(500)
        local melvintable = {}
        for i = 1, L_PedSize(enemyteamGroup) do
            id = L_PedGetIDByIndex(enemyteamGroup, i)
            if not PedIsDead(id) then
                table.insert(melvintable, id)
            end
        end
        if melvintable ~= {} and not PedIsDead(melvin) then
            local melvintarget = RandomTableElement(melvintable)
            PedClearObjectives(melvin)
            PedOverrideStat(melvin, 31, 200)
            PedOverrideStat(melvin, 10, 75)
            PedCoverSet(melvin, nil, POINTLIST._3_R06_COVER1_4, 1, 40, 1, 1, 2, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(melvin)
        PedMoveToPoint(melvin, 1, POINTLIST._3_R06_MT1_5)
        Wait(1300)
        PedClearObjectives(melvin)
        PedMoveToPoint(melvin, 1, POINTLIST._3_R06_COVER1_6)
        local melvintable = {}
        for i = 1, L_PedSize(enemyteamGroup) do
            id = L_PedGetIDByIndex(enemyteamGroup, i)
            if not PedIsDead(id) then
                table.insert(melvintable, id)
            end
        end
        if melvintable ~= {} and not PedIsDead(melvin) then
            local melvintarget = RandomTableElement(melvintable)
            PedClearObjectives(melvin)
            PedOverrideStat(melvin, 10, 75)
            PedCoverSet(melvin, nil, POINTLIST._3_R06_COVER1_6, 1, 40, 1, 3, 5, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(melvin)
        PedMoveToPoint(melvin, 1, POINTLIST._3_R06_MT1_4)
        Wait(1300)
        PedClearObjectives(melvin)
        PedMoveToPoint(melvin, 1, POINTLIST._3_R06_COVER1_5)
        local melvintable = {}
        for i = 1, L_PedSize(enemyteamGroup) do
            id = L_PedGetIDByIndex(enemyteamGroup, i)
            if not PedIsDead(id) then
                table.insert(melvintable, id)
            end
        end
        if melvintable ~= {} and not PedIsDead(melvin) then
            local melvintarget = RandomTableElement(melvintable)
            PedClearObjectives(melvin)
            PedOverrideStat(melvin, 10, 75)
            PedCoverSet(melvin, nil, POINTLIST._3_R06_COVER1_5, 1, 40, 1, 3, 5, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(melvin)
        PedMoveToPoint(melvin, 1, POINTLIST._3_R06_MT1_4)
        Wait(1000)
        PedClearObjectives(melvin)
        PedMoveToPoint(melvin, 1, POINTLIST._3_R06_MT1_2)
        Wait(900)
        PedClearObjectives(melvin)
        PedMoveToPoint(melvin, 1, POINTLIST._3_R06_COVER1_2)
        local melvintable = {}
        for i = 1, L_PedSize(enemyteamGroup) do
            id = L_PedGetIDByIndex(enemyteamGroup, i)
            if not PedIsDead(id) then
                table.insert(melvintable, id)
            end
        end
        if melvintable ~= {} and not PedIsDead(melvin) then
            local melvintarget = RandomTableElement(melvintable)
            PedClearObjectives(melvin)
            PedOverrideStat(melvin, 31, 400)
            PedOverrideStat(melvin, 10, 100)
            PedCoverSet(melvin, nil, POINTLIST._3_R06_COVER1_2, 1, 40, 1, 6, 10, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(melvin)
        PedMoveToPoint(melvin, 1, POINTLIST._3_R06_MT1_5)
        Wait(1300)
    end
    Wait(0)
end

function F_Thad()
    thad = L_PedGetID("name", "thad")
    while not (PedIsDead(thad) or L_PedAllDead(enemyteamGroup)) do
        Wait(1000)
        PedMoveToPoint(thad, 1, POINTLIST._3_R06_COVER1_5)
        Wait(500)
        local thadtable = {}
        for i = 1, L_PedSize(enemyteamGroup) do
            id = L_PedGetIDByIndex(enemyteamGroup, i)
            if not PedIsDead(id) then
                table.insert(thadtable, id)
            end
        end
        if thadtable ~= {} and not PedIsDead(thad) then
            local thadtarget = RandomTableElement(thadtable)
            PedClearObjectives(thad)
            PedOverrideStat(thad, 10, 75)
            PedCoverSet(thad, nil, POINTLIST._3_R06_COVER1_5, 1, 40, 1, 3, 5, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(thad)
        PedMoveToPoint(thad, 1, POINTLIST._3_R06_MT1_4)
        Wait(1500)
        PedClearObjectives(thad)
        PedMoveToPoint(thad, 1, POINTLIST._3_R06_COVER1_2)
        local thadtable = {}
        for i = 1, L_PedSize(enemyteamGroup) do
            id = L_PedGetIDByIndex(enemyteamGroup, i)
            if not PedIsDead(id) then
                table.insert(thadtable, id)
            end
        end
        if thadtable ~= {} and not PedIsDead(thad) then
            local thadtarget = RandomTableElement(thadtable)
            PedClearObjectives(thad)
            PedOverrideStat(thad, 31, 400)
            PedOverrideStat(thad, 10, 100)
            PedCoverSet(thad, nil, POINTLIST._3_R06_COVER1_2, 1, 40, 1, 6, 10, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(thad)
        PedMoveToPoint(thad, 1, POINTLIST._3_R06_MT1_5)
        Wait(2000)
        PedClearObjectives(thad)
        PedMoveToPoint(thad, 1, POINTLIST._3_R06_COVER1_4)
        local thadtable = {}
        for i = 1, L_PedSize(enemyteamGroup) do
            id = L_PedGetIDByIndex(enemyteamGroup, i)
            if not PedIsDead(id) then
                table.insert(thadtable, id)
            end
        end
        if thadtable ~= {} and not PedIsDead(thad) then
            local thadtarget = RandomTableElement(thadtable)
            PedClearObjectives(thad)
            PedOverrideStat(thad, 10, 75)
            PedOverrideStat(thad, 31, 200)
            PedCoverSet(thad, nil, POINTLIST._3_R06_COVER1_4, 1, 40, 1, 3, 5, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(thad)
        PedMoveToPoint(thad, 1, POINTLIST._3_R06_MT1_5)
        Wait(1000)
        PedClearObjectives(thad)
        PedMoveToPoint(thad, 1, POINTLIST._3_R06_COVER1_6)
        local thadtable = {}
        for i = 1, L_PedSize(enemyteamGroup) do
            id = L_PedGetIDByIndex(enemyteamGroup, i)
            if not PedIsDead(id) then
                table.insert(thadtable, id)
            end
        end
        if thadtable ~= {} and not PedIsDead(thad) then
            local thadtarget = RandomTableElement(thadtable)
            PedClearObjectives(thad)
            PedOverrideStat(thad, 10, 75)
            PedCoverSet(thad, nil, POINTLIST._3_R06_COVER1_6, 1, 40, 1, 5, 7, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(thad)
        PedMoveToPoint(thad, 1, POINTLIST._3_R06_MT1_4)
        Wait(500)
    end
    Wait(0)
end

function F_Damon()
    damon = L_PedGetID("name", "damon")
    while not PedIsDead(damon) do
        Wait(1000)
        PedMoveToPoint(damon, 1, POINTLIST._3_R06_COVER2_1)
        Wait(500)
        local damontable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(damontable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(damon) then
            damontarget = gPlayer
            PedClearObjectives(damon)
            PedOverrideStat(damon, 31, 400)
            PedOverrideStat(damon, 10, 100)
            PedCoverSet(damon, nil, POINTLIST._3_R06_COVER2_1, 1, 40, 1, 1, 2, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(damon) and damontable ~= {} then
            local damontarget = RandomTableElement(damontable)
            PedClearObjectives(damon)
            PedOverrideStat(damon, 31, 200)
            PedOverrideStat(damon, 10, 75)
            PedCoverSet(damon, nil, POINTLIST._3_R06_COVER2_1, 1, 40, 1, 1, 2, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(damon)
        PedMoveToPoint(damon, 1, POINTLIST._3_R06_MT2_4)
        Wait(1550)
        PedClearObjectives(damon)
        PedMoveToPoint(damon, 1, POINTLIST._3_R06_COVER2_3)
        local damontable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(damontable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(damon) then
            damontarget = gPlayer
            PedClearObjectives(damon)
            PedOverrideStat(damon, 31, 400)
            PedOverrideStat(damon, 10, 100)
            PedCoverSet(damon, nil, POINTLIST._3_R06_COVER2_3, 1, 40, 1, 6, 10, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(damon) and damontable ~= {} then
            local damontarget = RandomTableElement(damontable)
            PedClearObjectives(damon)
            PedOverrideStat(damon, 31, 400)
            PedOverrideStat(damon, 10, 75)
            PedCoverSet(damon, nil, POINTLIST._3_R06_COVER2_3, 1, 40, 1, 6, 10, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(damon)
        PedMoveToPoint(damon, 1, POINTLIST._3_R06_MT2_5)
        Wait(1800)
        PedClearObjectives(damon)
        PedMoveToPoint(damon, 1, POINTLIST._3_R06_COVER2_5)
        local damontable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(damontable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(damon) then
            damontarget = gPlayer
            PedClearObjectives(damon)
            PedOverrideStat(damon, 31, 400)
            PedOverrideStat(damon, 10, 100)
            PedCoverSet(damon, nil, POINTLIST._3_R06_COVER2_5, 1, 40, 1, 1, 2, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(damon) and damontable ~= {} then
            local damontarget = RandomTableElement(damontable)
            PedClearObjectives(damon)
            PedOverrideStat(damon, 31, 200)
            PedOverrideStat(damon, 10, 75)
            PedCoverSet(damon, nil, POINTLIST._3_R06_COVER2_5, 1, 40, 1, 1, 2, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(damon)
        PedMoveToPoint(damon, 1, POINTLIST._3_R06_MT2_5)
        Wait(1500)
        PedClearObjectives(damon)
        PedMoveToPoint(damon, 1, POINTLIST._3_R06_COVER2_6)
        local damontable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(damontable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(damon) then
            damontarget = gPlayer
            PedClearObjectives(damon)
            PedOverrideStat(damon, 31, 400)
            PedOverrideStat(damon, 10, 100)
            PedCoverSet(damon, nil, POINTLIST._3_R06_COVER2_6, 1, 40, 1, 1, 2, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(damon) and damontable ~= {} then
            local damontarget = RandomTableElement(damontable)
            PedClearObjectives(damon)
            PedOverrideStat(damon, 31, 200)
            PedOverrideStat(damon, 10, 75)
            PedCoverSet(damon, nil, POINTLIST._3_R06_COVER2_6, 1, 40, 1, 1, 2, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(damon)
        PedMoveToPoint(damon, 1, POINTLIST._3_R06_MT2_4)
        Wait(300)
    end
    Wait(0)
end

function F_Dan()
    dan = L_PedGetID("name", "dan")
    while not PedIsDead(dan) do
        Wait(1000)
        PedMoveToPoint(dan, 1, POINTLIST._3_R06_COVER2_6)
        Wait(500)
        local dantable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(dantable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(dan) then
            dantarget = gPlayer
            PedClearObjectives(dan)
            PedOverrideStat(dan, 31, 400)
            PedOverrideStat(dan, 10, 100)
            PedCoverSet(dan, nil, POINTLIST._3_R06_COVER2_6, 1, 40, 1, 1, 2, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(dan) and dantable ~= {} then
            local dantarget = RandomTableElement(dantable)
            PedClearObjectives(dan)
            PedOverrideStat(dan, 31, 200)
            PedOverrideStat(dan, 10, 75)
            PedCoverSet(dan, nil, POINTLIST._3_R06_COVER2_6, 1, 40, 1, 5, 7, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(dan)
        PedMoveToPoint(dan, 1, POINTLIST._3_R06_MT2_4)
        Wait(1300)
        PedClearObjectives(dan)
        PedMoveToPoint(dan, 1, POINTLIST._3_R06_COVER2_1)
        local dantable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(dantable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(dan) then
            dantarget = gPlayer
            PedClearObjectives(dan)
            PedOverrideStat(dan, 31, 400)
            PedOverrideStat(dan, 10, 100)
            PedCoverSet(dan, nil, POINTLIST._3_R06_COVER2_1, 1, 40, 1, 1, 2, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(dan) and dantable ~= {} then
            local dantarget = RandomTableElement(dantable)
            PedClearObjectives(dan)
            PedOverrideStat(dan, 31, 200)
            PedOverrideStat(dan, 10, 75)
            PedCoverSet(dan, nil, POINTLIST._3_R06_COVER2_1, 1, 40, 1, 5, 7, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(dan)
        PedMoveToPoint(dan, 1, POINTLIST._3_R06_MT2_4)
        Wait(1500)
        PedClearObjectives(dan)
        PedMoveToPoint(dan, 1, POINTLIST._3_R06_COVER2_3)
        local dantable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(dantable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(dan) then
            dantarget = gPlayer
            PedClearObjectives(dan)
            PedOverrideStat(dan, 31, 400)
            PedOverrideStat(dan, 10, 100)
            PedCoverSet(dan, nil, POINTLIST._3_R06_COVER2_3, 1, 40, 1, 6, 10, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(dan) and dantable ~= {} then
            local dantarget = RandomTableElement(dantable)
            PedClearObjectives(dan)
            PedOverrideStat(dan, 31, 400)
            PedOverrideStat(dan, 10, 75)
            PedCoverSet(dan, nil, POINTLIST._3_R06_COVER2_3, 1, 40, 1, 6, 10, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(dan)
        PedMoveToPoint(dan, 1, POINTLIST._3_R06_MT2_3)
        Wait(1000)
        PedClearObjectives(dan)
        PedMoveToPoint(dan, 1, POINTLIST._3_R06_MT2_5)
        Wait(1000)
        PedClearObjectives(dan)
        PedMoveToPoint(dan, 1, POINTLIST._3_R06_COVER2_5)
        local dantable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(dantable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(dan) then
            dantarget = gPlayer
            PedClearObjectives(dan)
            PedOverrideStat(dan, 31, 400)
            PedOverrideStat(dan, 10, 100)
            PedCoverSet(dan, nil, POINTLIST._3_R06_COVER2_5, 1, 40, 1, 1, 2, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(dan) and dantable ~= {} then
            local dantarget = RandomTableElement(dantable)
            PedClearObjectives(dan)
            PedOverrideStat(dan, 31, 200)
            PedOverrideStat(dan, 10, 75)
            PedCoverSet(dan, nil, POINTLIST._3_R06_COVER2_5, 1, 40, 1, 5, 7, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(dan)
        PedMoveToPoint(dan, 1, POINTLIST._3_R06_MT2_5)
        Wait(300)
    end
    Wait(0)
end

function F_Kirby()
    kirby = L_PedGetID("name", "kirby")
    while not PedIsDead(kirby) do
        Wait(1000)
        PedMoveToPoint(kirby, 1, POINTLIST._3_R06_COVER2_5)
        Wait(500)
        local kirbytable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(kirbytable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(kirby) then
            kirbytarget = gPlayer
            PedClearObjectives(kirby)
            PedOverrideStat(kirby, 31, 400)
            PedOverrideStat(kirby, 10, 100)
            PedCoverSet(kirby, nil, POINTLIST._3_R06_COVER2_5, 1, 40, 1, 1, 2, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(kirby) and kirbytable ~= {} then
            local kirbytarget = RandomTableElement(kirbytable)
            PedClearObjectives(kirby)
            PedOverrideStat(kirby, 31, 150)
            PedOverrideStat(kirby, 10, 75)
            PedCoverSet(kirby, nil, POINTLIST._3_R06_COVER2_5, 1, 40, 1, 3, 5, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(kirby)
        PedMoveToPoint(kirby, 1, POINTLIST._3_R06_MT2_5)
        Wait(1300)
        PedClearObjectives(kirby)
        PedMoveToPoint(kirby, 1, POINTLIST._3_R06_COVER2_6)
        local kirbytable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(kirbytable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(kirby) then
            kirbytarget = gPlayer
            PedClearObjectives(kirby)
            PedOverrideStat(kirby, 31, 400)
            PedOverrideStat(kirby, 10, 100)
            PedCoverSet(kirby, nil, POINTLIST._3_R06_COVER2_6, 1, 40, 1, 1, 2, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(kirby) and kirbytable ~= {} then
            local kirbytarget = RandomTableElement(kirbytable)
            PedClearObjectives(kirby)
            PedOverrideStat(kirby, 31, 150)
            PedOverrideStat(kirby, 10, 75)
            PedCoverSet(kirby, nil, POINTLIST._3_R06_COVER2_6, 1, 40, 1, 5, 7, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(kirby)
        PedMoveToPoint(kirby, 1, POINTLIST._3_R06_MT2_4)
        Wait(1200)
        PedClearObjectives(kirby)
        PedMoveToPoint(kirby, 1, POINTLIST._3_R06_COVER2_1)
        local kirbytable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(kirbytable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(kirby) then
            kirbytarget = gPlayer
            PedClearObjectives(kirby)
            PedOverrideStat(kirby, 31, 400)
            PedOverrideStat(kirby, 10, 100)
            PedCoverSet(kirby, nil, POINTLIST._3_R06_COVER2_1, 1, 40, 1, 1, 2, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(kirby) and kirbytable ~= {} then
            local kirbytarget = RandomTableElement(kirbytable)
            PedClearObjectives(kirby)
            PedOverrideStat(kirby, 31, 150)
            PedOverrideStat(kirby, 10, 75)
            PedCoverSet(kirby, nil, POINTLIST._3_R06_COVER2_1, 1, 40, 1, 3, 5, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(kirby)
        PedMoveToPoint(kirby, 1, POINTLIST._3_R06_MT2_4)
        Wait(1000)
        PedClearObjectives(kirby)
        PedMoveToPoint(kirby, 1, POINTLIST._3_R06_MT2_2)
        Wait(1000)
        PedClearObjectives(kirby)
        PedMoveToPoint(kirby, 1, POINTLIST._3_R06_COVER2_3)
        local kirbytable = { gPlayer }
        for i = 1, L_PedSize(myteamGroup) do
            id = L_PedGetIDByIndex(myteamGroup, i)
            if not PedIsDead(id) then
                table.insert(kirbytable, id)
            end
        end
        if PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(kirby) then
            kirbytarget = gPlayer
            PedClearObjectives(kirby)
            PedOverrideStat(kirby, 31, 400)
            PedOverrideStat(kirby, 10, 100)
            PedCoverSet(kirby, nil, POINTLIST._3_R06_COVER2_3, 1, 40, 1, 6, 10, 1, 1, 1, 1, 1, 1, false)
        elseif not PlayerIsInTrigger(TRIGGER._3_R06_KILL_ZONE) and not PedIsDead(kirby) and kirbytable ~= {} then
            local kirbytarget = RandomTableElement(kirbytable)
            PedClearObjectives(kirby)
            PedOverrideStat(kirby, 31, 150)
            PedOverrideStat(kirby, 10, 100)
            PedCoverSet(kirby, kirbytarget, POINTLIST._3_R06_COVER2_3, 1, 40, 1, 6, 10, 2, 2, 1, 1, 1, 1, false)
        end
        Wait(10000)
        PedClearObjectives(kirby)
        PedMoveToPoint(kirby, 1, POINTLIST._3_R06_MT2_5)
        Wait(1200)
    end
    Wait(0)
end
