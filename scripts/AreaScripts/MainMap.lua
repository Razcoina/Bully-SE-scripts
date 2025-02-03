ImportScript("Library/LibSchool.lua")
ImportScript("Library/Mailboxes.lua")
SchoolGroundsSpawners = {}
SchoolGroundsDockers = {}
RichAreaSpawners = {}
RichAreaDockers = {}
BusinessAreaSpawners = {}
BusinessAreaDockers = {}
PoorAreaSpawners = {}
PoorAreaDockers = {}
IndustrialSpawners = {}
IndustrialDockers = {}
IndustrialGates = {}
tblBalls = {}
tblStores = {}
local gBarricadeCreated = 0
local GOKART_KEEP_RADIUS = 70
local tblSchoolExitBlocks = {}
local MAILBOXES_NONE = -1
local MAILBOXES_CREATE = 0
local MAILBOXES_DELETE = 1
shared.MailboxesRespawn = MAILBOXES_CREATE
shared.bDisableRetirementHome = false
local BCreateFlag = false
local RainFlag = false
local bInDropoutEnclave = false
local bCreatedExitBlocks = false
local tblGeo = {}
local DispersePatrolPrefects = false
local industrialGate = {}
local industrialGateDestroyed = false
local gPortaPottyTbl = {}
local gPortaPottyCreated = false
local gPatrolPath_SG_PREFECT01_disabled = false
local gPatrolPath_SG_PREFECT02_disabled = false
local gPatrolPath_SG_PREFECT03_disabled = false
local gPatrolPath_SG_PREFECT04_disabled = false
local gPatrolPath_SG_PREFECT05_disabled = false
local gPatrolPath_SGD_PREFECT1_disabled = false
local gPatrolPath_SGD_PREFECT2_disabled = false
local gPatrolPath_SGD_PREFECT3_disabled = false
local XmasTreeHashID = ObjectNameToHashID("WALKABLE_buWallsOP")
bAttack = false
AttackModel = nil
AttackSpawner = nil
local gRetirementTable = {}
local bRetirementEvents = false
local bRetirementPedsLoaded = false
local bRetirementPedsCreated = false
local gFootballTable = {}
local bFootballThread = false
local bFootballEvents = false
local bMailman = false
local bMailmanLoaded = false
local bMailmanCreated = false
local gMailmanID
local MailmanTable = {}
local bRichTownspeople = false
local tblRaceSignupSheet = {}
tblRaceSignupSheet = {
    {
        mission = "3_R08_Rich1",
        prereq = "2_07",
        poolIndex = nil,
        x = 331.975,
        y = 263.405,
        z = 7.56303,
        o = 0.288,
        poster = "RC_rtv01"
    },
    {
        mission = "3_R08_Rich2",
        poolIndex = nil,
        x = 333.205,
        y = 262.796,
        z = 7.56303,
        o = 0.288,
        poster = "RC_rtv02"
    },
    {
        mission = "3_R08_Rich3",
        poolIndex = nil,
        x = 334.463,
        y = 262.214,
        z = 7.56303,
        o = 0.288,
        poster = "RC_rtv03"
    },
    {
        mission = "3_R08_Rich4",
        poolIndex = nil,
        x = 335.307,
        y = 269.518,
        z = 7.74286,
        o = 0.317,
        poster = "RC_vsb01"
    },
    {
        mission = "3_R08_Rich5",
        poolIndex = nil,
        x = 337.085,
        y = 269.501,
        z = 7.74286,
        o = 0.317,
        poster = "RC_vsb02"
    },
    {
        mission = "3_R08_Rich6",
        poolIndex = nil,
        x = 338.846,
        y = 269.478,
        z = 7.74286,
        o = 0.317,
        poster = "RC_vsb03"
    },
    {
        mission = "3_R08_Rich7",
        poolIndex = nil,
        x = 340.715,
        y = 269.453,
        z = 7.74286,
        o = 0.317,
        poster = "RC_vsb04"
    },
    {
        mission = "3_R08_Business1",
        prereq = "2_07",
        poolIndex = nil,
        x = 486.352,
        y = -76.2431,
        z = 7.17596,
        o = 0.27,
        poster = "BU_btt01"
    },
    {
        mission = "3_R08_Business2",
        poolIndex = nil,
        x = 486.393,
        y = -74.1054,
        z = 7.17596,
        o = 0.27,
        poster = "BU_btt02"
    },
    {
        mission = "3_R08_Business3",
        poolIndex = nil,
        x = 492.095,
        y = -77.0245,
        z = 6.58976,
        o = 0.27,
        poster = "BU_btt03"
    },
    {
        mission = "3_R08_Business4",
        mission2 = "2_B",
        poolIndex = nil,
        x = 492.095,
        y = -79.0632,
        z = 6.58976,
        o = 0.27,
        poster = "BU_btt04"
    },
    {
        mission = "3_R08_Poor1",
        prereq = "3_01",
        poolIndex = nil,
        x = 470.512,
        y = -312.079,
        z = 3.97607,
        o = 0.378,
        poster = "BU_ncc01"
    },
    {
        mission = "3_R08_Poor2",
        poolIndex = nil,
        x = 470.512,
        y = -309.764,
        z = 3.97607,
        o = 0.378,
        poster = "BU_ncc02"
    },
    {
        mission = "3_R08_School1",
        prereq = "3_R08_Business4",
        poolIndex = nil,
        x = 202.528,
        y = -23.4205,
        z = 8.14162,
        o = 0.159,
        poster = "SC_agp01"
    }
}
local tblSprinklerTable = {}
local tblFoundPeds = {}
local bSprinklersOn = false
local bOnBus = false
local tblBusLocations = {}
local gPlayerInCarnival = false
local gCarnivalEntranceCorona
local bPeteyCreatedAndWaiting = false
local gPeteyPier = -1
local gPinkyTicket = -1
local gGordTicket = -1
local gLolaTicket = -1

function PatrolPathInit()
    AreaInitPatrolPath(PATH._SG_PREFECT01, 3, 0, 2)
    AreaInitPatrolPath(PATH._SG_PREFECT02, 3, 0, 2)
    AreaInitPatrolPath(PATH._SG_PREFECT03, 3, 0, 2)
    AreaInitPatrolPath(PATH._SG_PREFECT04, 3, 0, 1)
    AreaInitPatrolPath(PATH._SG_PREFECT05, 3, 0, 2)
    AreaInitPatrolPath(PATH._SGD_PREFECT1, 0, 3, 2, false)
    AreaInitPatrolPath(PATH._SGD_PREFECT2, 0, 3, 1, false)
    AreaInitPatrolPath(PATH._SGD_PREFECT3, 0, 3, 1, false)
    AreaInitPatrolPath(PATH._CITYHALLPATROL1, 3, 0, 2, false)
    AreaInitPatrolPath(PATH._CITYHALLPATROL2, 0, 3, 2, false)
end

function F_SchoolGatesOpenStateRules()
    isNotChapterOne = ChapterGet() ~= 0 or 0 < GetMissionAttemptCount("2_01")
    shouldBeOpened = isNotChapterOne
    return shouldBeOpened
end

function F_AreaDATLoadMainMap()
    if IsMissionCompleated("4_02") then
        DATLoad("world_brocket.DAT", 1)
    end
    if IsMissionCompleated("4_02") then
        DATLoad("world_spudgun.DAT", 1)
    end
    DATLoad("tcarni.DAT", 5)
    DATLoad("lib_regular.DAT", 0)
    DATLoad("eventsAsylum.DAT", 0)
    DATLoad("Football_Paths.DAT", 0)
    DATLoad("mm_retirement.DAT", 0)
    DATLoad("Barricade_Triggers.DAT", 0)
    DATLoad("SP_MainMap.DAT", 0)
    DATLoad("MainMap_bus.DAT", 0)
    DATLoad("EasyDrugs.DAT", 0)
    if shared.gHCriminalsActive == true then
        DATLoad("Hcrim.DAT", 0)
        --print("LOADING CRIMINALS")
    end
    DATLoad("PrefectsSchoolGround.DAT", 0)
    DATLoad("Patrol_SchoolGrounds.DAT", 0)
    PatrolPathInit()
end

function main()
    F_AreaDATLoadMainMap()
    shared.F_AreaDATLoadMainMap = F_AreaDATLoadMainMap
    if shared.gBDormFAlarmOn == true then
        DATLoad("DFAlarm.DAT", 0)
    end
    if shared.gSchoolFAlarmOn == true then
        DATLoad("SFAlarm.DAT", 0)
    end
    MailmanTable = {
        POINTLIST._MAILMAN1,
        POINTLIST._MAILMAN2,
        POINTLIST._MAILMAN3
    }
    AreaRegisterAnimProps()
    collectgarbage()
    Wait(5)
    shared.gAreaDataLoaded = true
    shared.gAreaDATFileLoaded[0] = true
    F_SetupStoreTable()
    F_SetupSchoolSpawners()
    F_StartSchoolSpawners()
    F_SetupEventSpawners()
    F_GeometrySetup()
    F_SetupRichAreaSpawners()
    F_StartRichAreaSpawners()
    F_SetupBusinessAreaSpawners()
    F_StartBusinessAreaSpawners()
    F_SetupPoorAreaSpawners()
    F_StartPoorAreaSpawners()
    F_SetupIndustrialSpawners()
    F_StartIndustrialSpawners()
    F_SetupIndustrialGates()
    F_RegisterEventHandlers()
    F_SetupFactionAreas()
    F_BarricadeTriggers()
    F_SetupBus()
    F_OutsideSchoolTrigger()
    F_SetupIndustrialArea()
    if not IsMissionCompleated("1_B") then
        F_BlockSchoolExits()
    end
    shared.gSchoolBusDoorIndex, shared.gSchoolBusDoorGeometry = CreatePersistentEntity("scBusDr_Open", 176.103, 13.236, 7.00958, 0, 0)
    F_KillTables()
    LoadActionTree("Act/Props/TSGate.act")
    F_RequestBalls()
    F_CreateRaceSignupSheet()
    F_SetupSchoolGates()
    F_SetupHoboGates()
    CreateThread("F_CheckStores")
    if shared.gBDormFAlarmOn == true then
        CreateThread("F_BDormAlarmOn")
    end
    if shared.gSchoolFAlarmOn == true then
        CreateThread("F_SchoolAlarmOn")
    end
    F_PreDATInit()
    DATInit()
    if not IsMissionCompleated("4_02") then
        PAnimDelete(TRIGGER._SCHOOL_TURRETTRIPOD)
        PAnimDelete(TRIGGER._SCHOOL_TURRET)
    end
    while not (AreaGetVisible() ~= 0 or SystemShouldEndScript()) do
        Wait(0)
        if shared.forceRun5_07 then
            --print("SHOULD FORCE RUN NOW")
            if IsMissionCompleated("5_06") then
                --print("[RAUL] FORCE START MISSION 5_07")
                ForceStartMission("5_07a")
                shared.forceRun5_07 = nil
            end
        end
        F_HandlePatrolPathOverrides()
        if shared.enclaveGateRespawn then
            F_ToggleIndustrialAreaBarricade()
        end
        if IsMissionCompleated("GoKart_SR3") then
            if PlayerIsInTrigger(TRIGGER._WM_GOKARTCREATE) then
                if VehicleExists(shared.gGoKart) then
                    if not PlayerIsInAreaObject(shared.gGoKart, 1, GOKART_KEEP_RADIUS, 0) and not VehicleIsInTrigger(shared.gGoKart, TRIGGER._WM_GOKARTCREATE) then
                        if AreaGetVisible() == 0 then
                            F_GoKartCleanup()
                        end
                        F_GoKartCreate()
                    end
                else
                    F_GoKartCreate()
                end
            elseif VehicleExists(shared.gGoKart) and not PlayerIsInAreaObject(shared.gGoKart, 1, GOKART_KEEP_RADIUS, 0) and AreaGetVisible() == 0 then
                F_GoKartCleanup()
            end
        end
        if shared.MailboxesRespawn == MAILBOXES_CREATE then
            F_RichAreaMailboxesCreate()
        elseif shared.MailboxesRespawn == MAILBOXES_DELETE then
            F_RichAreaMailboxesRemove()
        end
        if PlayerIsInTrigger(TRIGGER._INDUSTRIALAREA_DROPOUTENCLAVE) then
            if not bInDropoutEnclave then
                F_CleanupProps()
                F_SetupProps()
                bInDropoutEnclave = true
            end
            if shared.resetEnclave then
                F_CleanupProps()
                F_SetupProps()
                F_ResetEnclave()
                shared.resetEnclave = nil
            end
            F_PropMonitor()
        elseif bInDropoutEnclave then
            F_CleanupProps()
            bInDropoutEnclave = false
        end
        local classHour, classMinute = ClockGet()
        if classHour == 11 and classMinute == 30 or classHour == 15 and classMinute == 30 then
            if ClassSpawners ~= nil then
                AreaSetAmbientSpawnerExclusive(ClassSpawners, true)
            end
        elseif classHour == 11 and classMinute == 35 or classHour == 15 and classMinute == 35 then
            if ClassSpawners ~= nil then
                AreaSetAmbientSpawnerExclusive(ClassSpawners, false)
            end
        elseif classHour == 6 and 55 <= classMinute and DispersePatrolPrefects == false then
            DispersePatrolPrefects = true
            F_DispersePatrolPrefects()
        elseif classHour == 7 and classMinute <= 0 and DispersePatrolPrefects == true then
            DispersePatrolPrefects = false
            F_RestoreSchoolSpawners()
        end
        if RainFlag == false and (WeatherGet() == 2 or WeatherGet() == 5) and ChapterGet() ~= 3 then
            RainFlag = true
            --print("RAINFLAG========TRUE")
            F_RainStuff()
        elseif RainFlag == true and WeatherGet() ~= 2 and WeatherGet() ~= 5 then
            RainFlag = false
            --print("RAINFLAG========FALSE")
            F_RainStuff()
        end
        if bCreatedExitBlocks and IsMissionCompleated("1_B") then
            F_DeleteExitBlocks()
        end
        F_CheckGeometry()
        if bRetirementEvents == true then
            bRetirementEvents = false
            LoadPedModels({
                53,
                158,
                183,
                184,
                185
            })
            bRetirementPedsLoaded = true
            --print("RetirementPedsLoaded")
            F_CreateRetirementPeds()
        end
        if bMailman == true then
            bMailman = false
            LoadPedModels({ 127 })
            bMailmanCreated = true
            F_CreateMailman()
        end
        if shared.gParkSprinklers and bSprinklersOn == false then
            bSprinklersOn = true
            CreateThread("F_SprinklerThread")
        end
        if shared.gBusTransition and not bOnBus then
            CreateThread("F_BusTransition")
            bOnBus = true
        end
        if shared.gRefreshRacePosters and not MissionActive() then
            F_CreateRaceSignupSheet()
            shared.gRefreshRacePosters = false
        end
        if bFootballThread == true and bFootballEvents == false and (not MissionActive() or shared.bFootBallFieldEnabled) then
            bFootballThread = false
            x = CreateThread("F_FootballFieldThread")
            bFootballEvents = true
        end
        F_CheckCarnival()
        F_PeteyOnThePier()
        F_MovieTicketLine()
    end
    AreaClearPatrolPaths()
    AreaClearDockers()
    AreaClearSpawners()
    shared.F_AreaDATLoadMainMap = nil
    DeletePersistentEntity(shared.gSchoolBusDoorIndex, shared.gSchoolBusDoorGeometry)
    F_RichAreaMailboxesRemove()
    F_CleanupIndustrialArea()
    F_CleanupSchoolGates()
    F_CleanupHoboGates()
    F_DeleteEntity(tblRaceSignupSheet)
    F_DeleteExitBlocks()
    tblSchoolExitBlocks = nil
    gRetirementTable = nil
    MailmanTable = nil
    DATUnload(0)
    DATUnload(5)
    collectgarbage()
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[0] = false
end

function F_CreateEntity(tblEntity)
    for i, entity in tblEntity do
        entity.poolIndex, entity.type = CreatePersistentEntity(entity.id, entity.x, entity.y, entity.z, entity.heading, entity.visibleArea)
    end
end

function F_DeleteEntity(tblEntity)
    for i, entity in tblEntity do
        if entity.poolIndex then
            DeletePersistentEntity(entity.poolIndex, entity.type)
        end
    end
end

function VehicleExists(car)
    return car and VehicleIsValid(car)
end

function F_CreateRaceSignupSheet()
    for i, entry in tblRaceSignupSheet do
        local nCreateNew = 0
        if GetMissionSuccessCount(entry.mission) >= 1 then
            nCreateNew = 2
            if entry.poolIndex then
                if nCreateNew > (entry.created or 0) then
                    --print("[MainMap.lua]>> F_CreateRaceSignupSheet:: UPDATING poster complete", entry.mission)
                    DeletePersistentEntity(entry.poolIndex, entry.type)
                    entry.poolIndex, entry.type = CreatePersistentEntity(entry.poster .. "a", entry.x, entry.y, entry.z + entry.o, 0, 0)
                else
                    --print("[MainMap.lua]>> F_CreateRaceSignupSheet:: NOT updating poster complete", entry.mission)
                end
            else
                --print("[MainMap.lua]>> F_CreateRaceSignupSheet:: CREATING new poster complete", entry.mission)
                entry.poolIndex, entry.type = CreatePersistentEntity(entry.poster .. "a", entry.x, entry.y, entry.z + entry.o, 0, 0)
            end
        elseif 1 <= GetMissionSuccessCount(entry.prereq or tblRaceSignupSheet[i - 1].mission) and F_PosterCheckMission(entry.mission2) then
            nCreateNew = 1
            if entry.poolIndex then
                if nCreateNew > (entry.created or 0) then
                    --print("[MainMap.lua]>> F_CreateRaceSignupSheet:: UPDATING poster", entry.mission)
                    DeletePersistentEntity(entry.poolIndex, entry.type)
                    entry.poolIndex, entry.type = CreatePersistentEntity(entry.poster, entry.x, entry.y, entry.z, 0, 0)
                else
                    --print("[MainMap.lua]>> F_CreateRaceSignupSheet:: NOT updating poster", entry.mission)
                end
            else
                --print("[MainMap.lua]>> F_CreateRaceSignupSheet:: CREATING new updating poster", entry.mission)
                entry.poolIndex, entry.type = CreatePersistentEntity(entry.poster, entry.x, entry.y, entry.z, 0, 0)
            end
        end
        --print("[MainMap.lua]>> F_CreateRaceSignupSheet:: SETTING POSTER STATUS", entry.mission, nCreateNew)
        entry.created = nCreateNew
    end
end

function F_PosterCheckMission(mission)
    if mission then
        if GetMissionSuccessCount(mission) >= 1 then
            return true
        end
        return false
    else
        return true
    end
end

function F_GoKartCreate()
    if not VehicleExists(shared.gGoKart) then
        LoadModels({ "289" })
        shared.gGoKart = VehicleCreatePoint(289, POINTLIST._MM_GOKART, 1)
        --print(">>>[RUI]", "++F_GoKartCreate")
    end
end

function F_GoKartCleanup()
    if VehicleExists(shared.gGoKart) and not PedIsInVehicle(gPlayer, shared.gGoKart) then
        VehicleStop(shared.gGoKart)
        VehicleDelete(shared.gGoKart)
        shared.gGoKart = nil
        --print(">>>[RUI]", "--F_GoKartCleanup VEHICLEDELETE")
    end
end

function F_BlockSchoolExits()
    if not IsMissionCompleated("1_B") then
        objID, objPool = CreatePersistentEntity("SC_FieldBarracade", -57.1224, -79.093, 3.52962, 0, 0)
        table.insert(tblSchoolExitBlocks, { id = objID, bPool = objPool })
        bCreatedExitBlocks = true
    end
end

function F_DeleteExitBlocks()
    for i, Entry in tblSchoolExitBlocks do
        if Entry.id ~= nil and Entry.id ~= -1 then
            DeletePersistentEntity(Entry.id, Entry.bPool)
        end
    end
    bCreatedExitBlocks = false
    tblSchoolExitBlocks = {}
end

function F_GeometrySetup()
    tblGeo = {
        {
            triggerList = {
                TRIGGER._POORAREA
            },
            geometry = "NOGO_fireBOP",
            x = 545.496,
            y = -364.066,
            z = 7.67277,
            F_Hide = function()
                return shared.gDisableRumbleFire01
            end
        },
        {
            triggerList = {
                TRIGGER._POORAREA
            },
            geometry = "NOGO_fireAOP",
            x = 537.103,
            y = -322.813,
            z = 7.67277,
            F_Hide = function()
                return shared.gDisableRumbleFire02
            end
        },
        {
            triggerList = {
                TRIGGER._POORAREA
            },
            geometry = "NOGO_blockadesOP",
            x = 514.892,
            y = -330.449,
            z = 7.67277,
            F_Hide = function()
                return shared.gDisableRumbleCollision
            end
        }
    }
end

function F_CheckGeometry()
    local bInTrigger = false
    for i, entry in tblGeo do
        bInTrigger = false
        for j, trigger in entry.triggerList do
            if PlayerIsInTrigger(trigger) then
                bInTrigger = true
            end
        end
        if bInTrigger then
            if entry.F_Hide() then
                GeometryInstance(entry.geometry, true, entry.x, entry.y, entry.z, false)
            else
                GeometryInstance(entry.geometry, false, entry.x, entry.y, entry.z, true)
            end
        end
    end
end

function F_SetupStoreTable()
    table.insert(tblStores, {
        cleartime = 0,
        chance = 0.75,
        bNearStore = false,
        spawnerid = nil,
        spawninfo = {
            point = POINTLIST._TBUSINES_GENSHOP2DOOR1,
            trigger = TRIGGER._DT_TBUSINES_GENSHOP2DOOR,
            model = 156
        },
        ped = nil,
        props = {
            {
                trigger = "DPE_BSignYumYum",
                x = 535.644,
                y = -81.1947,
                z = 4.68638,
                broken = false,
                checked = false
            }
        }
    })
    --print("THIIS SHIIT")
    --print(tblStores[1].props[1].trigger)
    table.insert(tblStores, {
        cleartime = 0,
        chance = 0.5,
        bNearStore = false,
        spawnerid = nil,
        spawninfo = {
            point = POINTLIST._TBUSINES_BIKESHOPDOOR1,
            trigger = TRIGGER._DT_TBUSINES_BIKESHOPDOOR,
            model = 86
        },
        ped = nil,
        props = {
            {
                trigger = "DPE_BSignBkShp",
                x = 483.816,
                y = -85.641,
                z = 5.36087,
                broken = false,
                checked = false
            }
        }
    })
    table.insert(tblStores, {
        cleartime = 0,
        chance = 0.5,
        bNearStore = false,
        spawnerid = nil,
        spawninfo = {
            point = POINTLIST._TBUSINESS_TSTOREDOOR1,
            trigger = TRIGGER._DT_TBUSINESS_FIREWBUSDOOR,
            model = 77
        },
        ped = nil,
        props = {
            {
                trigger = "DPE_G_150x225",
                x = 496.228,
                y = -80.4083,
                z = 6.58009,
                broken = false,
                checked = false
            },
            {
                trigger = "DPE_G_150x225",
                x = 493.583,
                y = -80.4083,
                z = 6.58009,
                broken = false,
                checked = false
            },
            {
                trigger = "DPE_G_150x225",
                x = 501.023,
                y = -80.4083,
                z = 6.2839,
                broken = false,
                checked = false
            }
        }
    })
    table.insert(tblStores, {
        cleartime = 0,
        chance = 0.5,
        bNearStore = false,
        spawnerid = nil,
        spawninfo = {
            point = POINTLIST._TBUSINES_CLOTHDOOR1,
            trigger = TRIGGER._DT_TBUSINES_CLOTHDOOR,
            model = 104
        },
        ped = nil,
        props = {
            {
                trigger = "DPE_BSign",
                x = 545.444,
                y = -139.465,
                z = 5.8649,
                broken = false,
                checked = false
            }
        }
    })
    table.insert(tblStores, {
        cleartime = 0,
        chance = 0.5,
        bNearStore = false,
        spawnerid = nil,
        spawninfo = {
            point = POINTLIST._TBUSINESS_BARBER1,
            trigger = TRIGGER._DT_TBUSINESS_BARBER,
            model = 132
        },
        ped = nil,
        props = {
            {
                trigger = "DPE_BSign",
                x = 532.108,
                y = -96.9603,
                z = 4.59853,
                broken = false,
                checked = false
            }
        }
    })
    table.insert(tblStores, {
        cleartime = 0,
        chance = 0.75,
        bNearStore = false,
        spawnerid = nil,
        spawninfo = {
            point = POINTLIST._DT_TRICH_GENSHOPDOOR1,
            trigger = TRIGGER._DT_TRICH_GENSHOPDOOR,
            model = 156
        },
        ped = nil,
        props = {
            {
                trigger = "DPE_BSignYumYum",
                x = 348.264,
                y = 149.053,
                z = 5.22525,
                broken = false,
                checked = false
            }
        }
    })
    table.insert(tblStores, {
        cleartime = 0,
        chance = 0.65,
        bNearStore = false,
        spawnerid = nil,
        spawninfo = {
            point = POINTLIST._IND_DOORSTR03,
            trigger = TRIGGER._DT_INDOOR_TATTOOSHOP,
            model = 128
        },
        ped = nil,
        props = {
            {
                trigger = "DPE_BSignB",
                x = 318.394,
                y = -339.866,
                z = 2.67577,
                broken = false,
                checked = false
            }
        }
    })
    table.insert(tblStores, {
        cleartime = 0,
        chance = 0.45,
        bNearStore = false,
        spawnerid = nil,
        spawninfo = {
            point = POINTLIST._TBUSINES_GENSHOP1DOOR1,
            trigger = TRIGGER._DT_TBUSINES_GENSHOP1DOOR,
            model = 156
        },
        ped = nil,
        props = {
            {
                trigger = "DPE_BSignYumYum",
                x = 493.075,
                y = -274.61,
                z = 2.3013,
                broken = false,
                checked = false
            }
        }
    })
end

function F_SetupSchoolSpawners()
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_AUTOSHOPL,
        point = POINTLIST._TSCHOOL_AUTOSHOPL,
        kind = "hangout"
    })
    table.insert(SchoolGroundsSpawners, {
        trigger = TRIGGER._TSCHOOL_GIRLSDORMR,
        point = POINTLIST._TSCHOOL_GIRLSDORMR,
        kind = "gdorm"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_GIRLSDORML,
        point = POINTLIST._TSCHOOL_GIRLSDORML,
        kind = "gdorm"
    })
    table.insert(SchoolGroundsSpawners, {
        trigger = TRIGGER._TSCHOOL_BOYSDORMR,
        point = POINTLIST._TSCHOOL_BOYSDORMR,
        kind = "bdorm"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_BOYSDORML,
        point = POINTLIST._TSCHOOL_BOYSDORML,
        kind = "bdorm"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_PREPPYL,
        point = POINTLIST._TSCHOOL_PREPPYL,
        kind = "hangout"
    })
    table.insert(SchoolGroundsSpawners, {
        trigger = TRIGGER._TSCHOOL_LIBRARYR,
        point = POINTLIST._TSCHOOL_LIBRARYR,
        kind = "hangout"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_LIBRARYL,
        point = POINTLIST._TSCHOOL_LIBRARYL,
        kind = "hangout"
    })
    table.insert(SchoolGroundsSpawners, {
        trigger = TRIGGER._TSCHOOL_POOLR,
        point = POINTLIST._TSCHOOL_POOLR,
        kind = "hangout"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_POOLL,
        point = POINTLIST._TSCHOOL_POOLL,
        kind = "hangout"
    })
    table.insert(SchoolGroundsSpawners, {
        trigger = TRIGGER._TSCHOOL_GYMR,
        point = POINTLIST._TSCHOOL_GYMR,
        kind = "class"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_GYML,
        point = POINTLIST._TSCHOOL_GYML,
        kind = "class"
    })
    table.insert(SchoolGroundsSpawners, {
        trigger = TRIGGER._TSCHOOL_SCHOOLFRONTDOORR,
        point = POINTLIST._TSCHOOL_SCHOOLFRONTDOORR,
        kind = "class"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_SCHOOLFRONTDOORL,
        point = POINTLIST._TSCHOOL_SCHOOLFRONTDOORL,
        kind = "class"
    })
    table.insert(SchoolGroundsSpawners, {
        trigger = TRIGGER._DT_TSCHOOL_SCHOOLLEFTBACKDOOR,
        point = POINTLIST._TSCHOOL_SCHOOLLEFTBACKDOOR,
        kind = "class"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_SCHOOLLEFTBACKDOOR,
        point = POINTLIST._TSCHOOL_SCHOOLLEFTBACKDOOR,
        kind = "class"
    })
    table.insert(SchoolGroundsSpawners, {
        trigger = TRIGGER._DT_TSCHOOL_SCHOOLRIGHTBACKDOOR,
        point = POINTLIST._TSCHOOL_SCHOOLRIGHTBACKDOOR,
        kind = "class"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_SCHOOLRIGHTBACKDOOR,
        point = POINTLIST._TSCHOOL_SCHOOLRIGHTBACKDOOR,
        kind = "class"
    })
    table.insert(SchoolGroundsSpawners, {
        trigger = TRIGGER._TSCHOOL_SCHOOLLEFTFRONTDOOR,
        point = POINTLIST._TSCHOOL_SCHOOLLEFTFRONTDOOR,
        kind = "class"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_SCHOOLLEFTFRONTDOOR,
        point = POINTLIST._TSCHOOL_SCHOOLLEFTFRONTDOOR,
        kind = "class"
    })
    table.insert(SchoolGroundsSpawners, {
        trigger = TRIGGER._DT_TSCHOOL_SCHOOLRIGHTFRONTDOOR,
        point = POINTLIST._TSCHOOL_SCHOOLRIGHTFRONTDOOR,
        kind = "class"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_SCHOOLRIGHTFRONTDOOR,
        point = POINTLIST._TSCHOOL_SCHOOLRIGHTFRONTDOOR,
        kind = "class"
    })
    table.insert(SchoolGroundsSpawners, {
        trigger = TRIGGER._DT_TSCHOOL_GIRLSDORMSIDEL,
        point = POINTLIST._TSCHOOL_GIRLSDORMSIDEDOOR,
        kind = "gdorm"
    })
    table.insert(SchoolGroundsDockers, {
        trigger = TRIGGER._DT_TSCHOOL_GIRLSDORMSIDEL,
        point = POINTLIST._TSCHOOL_GIRLSDORMSIDEDOOR,
        kind = "gdorm"
    })
end

function F_StartSchoolSpawners()
    ClassSpawners = AreaAddAmbientSpawner(6, 2, 100, 2000)
    HangOutSpawners = AreaAddAmbientSpawner(3, 3, 100, 4000)
    GDormSpawn = AreaAddAmbientSpawner(1, 3, 100, 5000)
    BDormSpawn = AreaAddAmbientSpawner(1, 3, 100, 5000)
    for i, key in SchoolGroundsSpawners do
        if SchoolGroundsSpawners[i].kind == "class" then
            AreaAddSpawnLocation(ClassSpawners, SchoolGroundsSpawners[i].point, SchoolGroundsSpawners[i].trigger)
        end
        if SchoolGroundsSpawners[i].kind == "hangout" then
            AreaAddSpawnLocation(HangOutSpawners, SchoolGroundsSpawners[i].point, SchoolGroundsSpawners[i].trigger)
        end
        if SchoolGroundsSpawners[i].kind == "gdorm" then
            AreaAddSpawnLocation(GDormSpawn, SchoolGroundsSpawners[i].point, SchoolGroundsSpawners[i].trigger)
        end
        if SchoolGroundsSpawners[i].kind == "bdorm" then
            AreaAddSpawnLocation(BDormSpawn, SchoolGroundsSpawners[i].point, SchoolGroundsSpawners[i].trigger)
        end
    end
    AreaAddAmbientSpawnPeriod(ClassSpawners, 11, 30, 30)
    AreaAddAmbientSpawnPeriod(ClassSpawners, 15, 0, 30)
    AreaAddAmbientSpawnPeriod(HangOutSpawners, 7, 0, 108)
    AreaAddAmbientSpawnPeriod(HangOutSpawners, 11, 30, 75)
    AreaAddAmbientSpawnPeriod(HangOutSpawners, 15, 30, 420)
    AreaAddAmbientSpawnPeriod(GDormSpawn, 7, 0, 108)
    AreaAddAmbientSpawnPeriod(GDormSpawn, 11, 30, 75)
    AreaAddAmbientSpawnPeriod(GDormSpawn, 15, 30, 420)
    AreaAddAmbientSpawnPeriod(BDormSpawn, 7, 0, 108)
    AreaAddAmbientSpawnPeriod(BDormSpawn, 11, 0, 75)
    AreaAddAmbientSpawnPeriod(GDormSpawn, 15, 30, 420)
    AreaSpawnerSetSexGeneration(BDormSpawn, false, true)
    AreaSpawnerSetSexGeneration(GDormSpawn, true, false)
    ClassDockers = AreaAddDocker(6, 2)
    HangOutDockers = AreaAddDocker(4, 2)
    GDormDock = AreaAddDocker(1, 2)
    BDormDock = AreaAddDocker(1, 2)
    for i, key in SchoolGroundsDockers do
        if SchoolGroundsDockers[i].kind == "class" then
            AreaAddDockLocation(ClassDockers, SchoolGroundsDockers[i].point, SchoolGroundsDockers[i].trigger)
        end
        if SchoolGroundsDockers[i].kind == "hangout" then
            AreaAddDockLocation(HangOutDockers, SchoolGroundsDockers[i].point, SchoolGroundsDockers[i].trigger)
        end
        if SchoolGroundsDockers[i].kind == "gdorm" then
            AreaAddDockLocation(GDormDock, SchoolGroundsDockers[i].point, SchoolGroundsDockers[i].trigger)
        end
        if SchoolGroundsDockers[i].kind == "bdorm" then
            AreaAddDockLocation(BDormDock, SchoolGroundsDockers[i].point, SchoolGroundsDockers[i].trigger)
        end
    end
    AreaAddDockPeriod(ClassDockers, 8, 45, 30)
    AreaAddDockPeriod(ClassDockers, 12, 45, 30)
    DockerSetUseFacingCheck(ClassDockers, false)
    DockerSetMinimumRange(ClassDockers, 0)
    DockerSetMaximumRange(ClassDockers, 100)
    AreaSetDockerRunPercentage(ClassDockers, 80)
    AreaSetDockerPatrolPedReception(ClassDockers, false)
    AreaAddDockPeriod(HangOutDockers, 11, 30, 75)
    AreaAddDockPeriod(HangOutDockers, 15, 30, 420)
    DockerSetMinimumRange(HangOutDockers, 3)
    DockerSetMaximumRange(HangOutDockers, 10)
    AreaSetDockerRunPercentage(HangOutDockers, 0)
    AreaSetDockerPatrolPedReception(HangOutDockers, false)
    AreaAddDockPeriod(GDormDock, 0, 0, 1440)
    AreaAddDockPeriod(GDormDock, 0, 0, 1440)
    AreaAddDockPeriod(BDormDock, 0, 0, 1440)
    AreaAddDockPeriod(BDormDock, 0, 0, 1440)
    AreaSetDockerSexReception(BDormDock, false, true)
    DockerSetUseFacingCheck(BDormDock, true)
    DockerSetMinimumRange(BDormDock, 3)
    DockerSetMaximumRange(BDormDock, 15)
    AreaSetDockerRunPercentage(BDormDock, 3)
    AreaSetDockerSexReception(GDormDock, true, false)
    DockerSetUseFacingCheck(GDormDock, true)
    DockerSetMinimumRange(GDormDock, 3)
    DockerSetMaximumRange(GDormDock, 15)
    AreaSetDockerRunPercentage(GDormDock, 3)
end

function F_RestoreSchoolSpawners()
    DockerSetOverrideActiveSetting(ClassDockers, false)
    AreaSetDockerPatrolPedReception(ClassDockers, false)
    DockerSetMaximumRange(ClassDockers, 100)
    DockerSetUseFacingCheck(ClassDockers, false)
    AreaSetDockerRunPercentage(ClassDockers, 80)
    DockerSetOverrideActiveSetting(HangOutDockers, false)
    AreaSetDockerPatrolPedReception(HangOutDockers, false)
    DockerSetMaximumRange(HangOutDockers, 10)
    DockerSetUseFacingCheck(HangOutDockers, false)
    AreaSetDockerRunPercentage(HangOutDockers, 0)
end

function F_DispersePatrolPrefects()
    DockerSetOverrideActiveSetting(ClassDockers, true)
    AreaSetDockerPatrolPedReception(ClassDockers, true)
    DockerSetMaximumRange(ClassDockers, 100)
    DockerSetMaximumRange(ClassDockers, 100)
    DockerSetUseFacingCheck(ClassDockers, false)
    AreaSetDockerRunPercentage(ClassDockers, 100)
    DockerSetOverrideActiveSetting(HangOutDockers, true)
    AreaSetDockerPatrolPedReception(HangOutDockers, true)
    DockerSetMaximumRange(HangOutDockers, 100)
    DockerSetUseFacingCheck(HangOutDockers, false)
    AreaSetDockerRunPercentage(HangOutDockers, 100)
end

function F_GStoreCallback(PedID, SpawnerID)
    local PropCrim = F_GetPedForSpawner(SpawnerID)
    if PedIsValid(PropCrim) then
        PedAttack(PedID, PropCrim, 0, true, true)
        PedIgnoreStimuli(PedID, true)
    end
    if PedIsValid(PedID) then
        PedModelNotNeededAmbient(PedID)
    end
end

function F_SetupEventSpawners()
    local i, tblStore, spawnLoc
    for i, tblStore in tblStores do
        tblStore.spawnerid = AreaAddMissionSpawner(1, 1, -1, 1, 0, 0)
        spawnLoc = AreaAddSpawnLocation(tblStore.spawnerid, tblStore.spawninfo.point, tblStore.spawninfo.trigger)
        AreaAddPedModelIdToSpawnLocation(tblStore.spawnerid, spawnLoc, tblStore.spawninfo.model)
        AreaMissionSpawnerSetCallback(tblStore.spawnerid, F_GStoreCallback)
    end
end

function F_RegisterEventHandlers()
    RegisterGlobalEventHandler(1, F_MMPropBroken)
    RegisterTriggerEventHandler(TRIGGER._RETIREMENTTRIGGER, 1, F_MMTriggerEnterEvents, 0)
    RegisterTriggerEventHandler(TRIGGER._RETIREMENTTRIGGER, 4, F_MMTriggerExitEvents, 0)
    RegisterTriggerEventHandler(TRIGGER._MAILMANTRIGGER, 1, F_MMTriggerEnterEvents, 0)
    RegisterTriggerEventHandler(TRIGGER._MAILMANTRIGGER, 4, F_MMTriggerExitEvents, 0)
    RegisterTriggerEventHandler(TRIGGER._RICHFOLKTRIGGER, 1, F_MMTriggerEnterEvents, 0)
    RegisterTriggerEventHandler(TRIGGER._RICHFOLKTRIGGER, 4, F_MMTriggerExitEvents, 0)
    RegisterTriggerEventHandler(TRIGGER._FOOTFIELDTRIG, 1, F_MMTriggerEnterEvents, 0)
    RegisterTriggerEventHandler(TRIGGER._FOOTFIELDTRIG, 4, F_MMTriggerExitEvents, 0)
    F_WalkableMeshCallback()
    RegisterGlobalEventHandler(6, F_WalkableMeshCallback)
end

function F_MMPropBroken(HashID, ObjectPoolIndex)
    local idProp, bPropPool
    local hour, minute = ClockGet()
    --print("FF_MMPROPBORKED START")
    if hour < 22 and 7 <= hour then
        for i, store in tblStores do
            for p, prop in store.props do
                idProp, bPropPool = PAnimGetPoolIndex(prop.trigger, prop.x, prop.y, prop.z, 1.2)
                if idProp == ObjectPoolIndex and math.random() <= store.chance then
                    ped = PAnimDestroyedByPed(idProp, bPropPool)
                    if PedIsValid(ped) then
                        store.ped = ped
                        store.cleartime = GetTimer() + 300000
                        bAttack = true
                        AttackSpawner = store.spawnerid
                        AttackModel = store.spawninfo.model
                        --print("FARK FARK FARK")
                    end
                end
            end
        end
    end
    local broken = 0
    for i, entry in IndustrialGates do
        if entry.hash == HashID then
            --print("FOUND IndustrialGates callback")
            broken = entry
            AreaSetPathableInRadius(broken.x, broken.y, broken.z, 0.5, 10, true)
            return
        end
    end
    --print("FF_MMPROPBORKED END")
end

function F_CheckStores()
    local AMCheck = false
    while not (AreaGetVisible() ~= 0 or SystemShouldEndScript()) do
        if bAttack == true and AttackModel ~= nil then
            if PedGetUniqueModelStatus(AttackModel) == -1 then
                PedSetUniqueModelStatus(AttackModel, 1)
                AMCheck = true
            end
            AreaMissionSpawnerSetActivated(AttackSpawner, true)
            --print("ACTIVATE SPAWNER")
            while RequestModel(AttackModel, true) == false do
                Wait(0)
            end
            if AMCheck == true then
                local AMCount = PedGetPedCountWithModel(AttackModel)
                while AMCount ~= 1 do
                    Wait(0)
                end
                PedSetUniqueModelStatus(AttackModel, -1)
            end
            AMCheck = false
            bAttack = false
            AttackModel = nil
            AttackSpawner = nil
        end
        Wait(0)
    end
    collectgarbage()
end

function F_GetPedForSpawner(idSpawner)
    local i, tblStore
    for i, tblStore in tblStores do
        if tblStore.spawnerid == idSpawner then
            return tblStore.ped
        end
    end
    return nil
end

function F_RequestBalls()
    while not WeaponRequestModel(329) do
        Wait(0)
    end
    while not WeaponRequestModel(381) do
        Wait(0)
    end
    while not WeaponRequestModel(331) do
        Wait(0)
    end
end

function F_BDormAlarmOn()
    if AreaIsLoading() == false then
        local PointTable = {}
        local DormPeds = {}
        local PedTypeTable = {
            6,
            5,
            4,
            2
        }
        PedSetGlobalAttitude_IgnoreTruants(true)
        table.insert(PointTable, {
            MinPeds = 1,
            MaxPeds = 3,
            Point = POINTLIST._DORMFAPT3
        })
        table.insert(PointTable, {
            MinPeds = 1,
            MaxPeds = 1,
            Point = POINTLIST._DORMFAPT4
        })
        table.insert(PointTable, {
            MinPeds = 1,
            MaxPeds = 2,
            Point = POINTLIST._DORMFAPT5
        })
        while RequestModel(82, true) == false do
            Wait(0)
        end
        FireMan = PedCreatePoint(82, POINTLIST._DORMFAPT1)
        ModelNotNeededAmbient(82)
        PedModelNotNeededAmbient(FireMan)
        PedFollowPath(FireMan, PATH._DORMFAPATH1, 0, 1, F_FiremanD)
        --print("making peds")
        for i, key in PointTable do
            local PedCount = math.random(key.MinPeds, key.MaxPeds)
            local x, y, z = GetPointList(key.Point)
            local PedTypeChoice = math.random(1, 4)
            for count = 1, PedCount do
                local DormPed = PedGetRandomModelId(PedTypeTable[PedTypeChoice], 1, -1)
                while RequestModel(DormPed, true) == false do
                    Wait(0)
                end
                local id = PedCreatePoint(DormPed, key.Point, count)
                PedModelNotNeededAmbient(id)
                ModelNotNeededAmbient(DormPed)
                table.insert(DormPeds, { handle = id })
                PedMakeAmbient(id)
            end
        end
        DockerSetOverrideActiveSetting(BDormDock, false)
        while shared.gBDormFAlarmOn == true do
            if AreaGetVisible() ~= 0 then
                break
            end
            if SystemShouldEndScript() then
                break
            end
            --print("Waiting for Alarm")
            Wait(0)
        end
        if shared.gBDormFAlarmOn == false and not SystemShouldEndScript() then
            for k, key in DormPeds do
                PedClearObjectives(key.handle)
                Wait(2)
                PedWander(key.handle, 0)
                PedMakeAmbient(key.handle)
            end
            if PedIsValid(FireMan) then
                PedClearObjectives(FireMan)
                PedWander(FireMan, 0)
                PedMakeAmbient(FireMan)
            end
            DockerSetOverrideActiveSetting(BDormDock, true)
            DockerSetMaximumRange(BDormDock, 30)
            DockerSetUseFacingCheck(BDormDock, false)
            AreaSetDockerRunPercentage(BDormDock, 100)
            --print("deleting peds")
            local waitCount = 0
            while not (not (waitCount < 200) or SystemShouldEndScript()) do
                Wait(100)
                waitCount = waitCount + 1
                --print("waiting for end")
            end
            if not SystemShouldEndScript() then
                DockerClearOverrideActiveSetting(BDormDock)
                DockerSetMaximumRange(BDormDock, 15)
                DockerSetUseFacingCheck(BDormDock, true)
                AreaSetDockerRunPercentage(BDormDock, 3)
            end
        end
        PedSetGlobalAttitude_IgnoreTruants(false)
    end
end

function F_FiremanD(PedID, PathID, NodeID)
    if NodeID == 7 and PedIsValid(FireMan) then
        PedSetActionNode(FireMan, "/Global/Ambient/MissionSpec/FireMan/LookAround", "/Act/Anim/Ambient.Act")
    end
    if NodeID == 9 and PedIsValid(FireMan) then
        PedSetActionNode(FireMan, "/Global/Ambient/MissionSpec/FireMan/Wall_Smoke", "/Act/Anim/Ambient.Act")
    end
end

function F_SchoolAlarmOn()
    if AreaIsLoading() == false then
        local PointTable = {}
        local SchoolPeds = {}
        local PedTypeTable = {
            6,
            5,
            4,
            2
        }
        PedSetGlobalAttitude_IgnoreTruants(true)
        table.insert(PointTable, {
            MinPeds = 1,
            MaxPeds = 4,
            Point = POINTLIST._SCHOOLMAINFAPT1
        })
        table.insert(PointTable, {
            MinPeds = 1,
            MaxPeds = 2,
            Point = POINTLIST._SCHOOLMAINFAPT2
        })
        table.insert(PointTable, {
            MinPeds = 1,
            MaxPeds = 2,
            Point = POINTLIST._SCHOOLMAINFAPT4
        })
        table.insert(PointTable, {
            MinPeds = 1,
            MaxPeds = 1,
            Point = POINTLIST._SCHOOLMAINFAPT5
        })
        table.insert(PointTable, {
            MinPeds = 1,
            MaxPeds = 3,
            Point = POINTLIST._SCHOOLMAINFAPT7
        })
        while RequestModel(82, true) == false do
            Wait(0)
        end
        FireManS2 = PedCreatePoint(82, POINTLIST._SCHOOLMAINFAPT9)
        ModelNotNeededAmbient(82)
        PedModelNotNeededAmbient(FireManS2)
        PedSetActionNode(FireManS2, "/Global/Ambient/MissionSpec/FireMan/Wall_Smoke", "/Act/Anim/Ambient.Act")
        for i, key in PointTable do
            local PedCount = math.random(key.MinPeds, key.MaxPeds)
            local x, y, z = GetPointList(key.Point)
            local PedTypeChoice = math.random(1, 4)
            for count = 1, PedCount do
                local SchoolPed = PedGetRandomModelId(PedTypeTable[PedTypeChoice], 1, -1)
                while RequestModel(SchoolPed, true) == false do
                    Wait(0)
                end
                local id = PedCreatePoint(SchoolPed, key.Point, count)
                PedModelNotNeededAmbient(id)
                ModelNotNeededAmbient(SchoolPed)
                table.insert(SchoolPeds, { handle = id })
                PedMakeAmbient(id)
            end
        end
        DockerSetOverrideActiveSetting(ClassDockers, false)
        local turnflag = false
        while shared.gSchoolFAlarmOn == true do
            Wait(0)
            if AreaGetVisible() ~= 0 or SystemShouldEndScript() then
                break
            end
        end
        if shared.gSchoolFAlarmOn == false and not SystemShouldEndScript() then
            for k, key in SchoolPeds do
                PedClearObjectives(key.handle)
                PedWander(key.handle, 0)
                Wait(2)
                PedMakeAmbient(key.handle)
            end
            if PedIsValid(FireManS2) then
                PedMakeAmbient(FireManS2)
                PedClearObjectives(FireManS2)
                PedWander(FireManS2, 0)
                PedMakeAmbient(FireManS2)
            end
            DockerSetOverrideActiveSetting(ClassDockers, true)
            local waitCount = 0
            while not (not (waitCount < 200) or SystemShouldEndScript()) do
                waitCount = waitCount + 1
                Wait(100)
            end
            if not SystemShouldEndScript() then
                DockerClearOverrideActiveSetting(ClassDockers)
            end
        end
        PedSetGlobalAttitude_IgnoreTruants(false)
    end
end

function F_SetupRichAreaSpawners()
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.DT_trich_BikeShopDoor,
        point = POINTLIST.DT_trich_BikeShopDoor1,
        kind = "store"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.DT_trich_GenShopDoor,
        point = POINTLIST.DT_trich_GenShopDoor1,
        kind = "store"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.DT_trich_GenShopDoor,
        point = POINTLIST.DT_trich_GenShopDoor1,
        kind = "store"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.DT_trich_FirewShopDoor,
        point = POINTLIST.DT_trich_FirewShopDoor1,
        kind = "store"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.DT_trich_ClothRichDoor,
        point = POINTLIST.DT_trich_ClothRichDoor1,
        kind = "store"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.DT_trich_ClothRichDoor,
        point = POINTLIST.DT_trich_ClothRichDoor1,
        kind = "store"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.icecream,
        point = POINTLIST.icecream,
        kind = "store"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.icecream,
        point = POINTLIST.icecream,
        kind = "store"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_DoorStr02,
        point = POINTLIST.RA_DoorStr02,
        kind = "store"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_DoorStr02,
        point = POINTLIST.RA_DoorStr02,
        kind = "store"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_DoorStr05,
        point = POINTLIST.RA_DoorStr05,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_DoorStr05,
        point = POINTLIST.RA_DoorStr05,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_DoorStr06,
        point = POINTLIST.RA_DoorStr06,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_DoorStr06,
        point = POINTLIST.RA_DoorStr06,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_DoorStr07,
        point = POINTLIST.RA_DoorStr07,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_DoorStr07,
        point = POINTLIST.RA_DoorStr07,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_DoorStr08,
        point = POINTLIST.RA_DoorStr08,
        kind = "store"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_DoorStr08,
        point = POINTLIST.RA_DoorStr08,
        kind = "store"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_DoorStr09,
        point = POINTLIST.RA_DoorStr09,
        kind = "store"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_DoorStr09,
        point = POINTLIST.RA_DoorStr09,
        kind = "store"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor02,
        point = POINTLIST.RA_PrepDoor02,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor02,
        point = POINTLIST.RA_PrepDoor02,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor03,
        point = POINTLIST.RA_PrepDoor03,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor03,
        point = POINTLIST.RA_PrepDoor03,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor05,
        point = POINTLIST.RA_PrepDoor05,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor05,
        point = POINTLIST.RA_PrepDoor05,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor06,
        point = POINTLIST.RA_PrepDoor06,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor06,
        point = POINTLIST.RA_PrepDoor06,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor07,
        point = POINTLIST.RA_PrepDoor07,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor07,
        point = POINTLIST.RA_PrepDoor07,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor08,
        point = POINTLIST.RA_PrepDoor08,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor08,
        point = POINTLIST.RA_PrepDoor08,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor09,
        point = POINTLIST.RA_PrepDoor09,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor09,
        point = POINTLIST.RA_PrepDoor09,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor10,
        point = POINTLIST.RA_PrepDoor10,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor10,
        point = POINTLIST.RA_PrepDoor10,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor11,
        point = POINTLIST.RA_PrepDoor11,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor11,
        point = POINTLIST.RA_PrepDoor11,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor12,
        point = POINTLIST.RA_PrepDoor12,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor12,
        point = POINTLIST.RA_PrepDoor12,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor13,
        point = POINTLIST.RA_PrepDoor13,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor13,
        point = POINTLIST.RA_PrepDoor13,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor14,
        point = POINTLIST.RA_PrepDoor14,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor14,
        point = POINTLIST.RA_PrepDoor14,
        kind = "house"
    })
    table.insert(RichAreaDockers, {
        trigger = TRIGGER.RA_PrepDoor15,
        point = POINTLIST.RA_PrepDoor15,
        kind = "house"
    })
    table.insert(RichAreaSpawners, {
        trigger = TRIGGER.RA_PrepDoor15,
        point = POINTLIST.RA_PrepDoor15,
        kind = "house"
    })
end

function F_StartRichAreaSpawners()
    RAStoreSpawners = AreaAddAmbientSpawner(7, 1, 100, 5000)
    HouseSpawners = AreaAddAmbientSpawner(13, 1, 100, 10000)
    for i, key in RichAreaSpawners do
        if RichAreaSpawners[i].kind == "store" then
            AreaAddSpawnLocation(RAStoreSpawners, RichAreaSpawners[i].point, RichAreaSpawners[i].trigger)
        elseif RichAreaSpawners[i].kind == "house" then
            AreaAddSpawnLocation(HouseSpawners, RichAreaSpawners[i].point, RichAreaSpawners[i].trigger)
        end
    end
    AreaAddAmbientSpawnPeriod(RAStoreSpawners, 8, 0, 780)
    AreaAddAmbientSpawnPeriod(HouseSpawners, 7, 0, 240)
    RAStoreDockers = AreaAddDocker(6, 1)
    HouseDockers = AreaAddDocker(13, 1)
    for i, key in RichAreaDockers do
        if RichAreaDockers[i].kind == "store" then
            AreaAddDockLocation(RAStoreDockers, RichAreaDockers[i].point, RichAreaDockers[i].trigger)
        elseif RichAreaDockers[i].kind == "house" then
            AreaAddDockLocation(HouseDockers, RichAreaDockers[i].point, RichAreaDockers[i].trigger)
        end
    end
    DockerSetUseFacingCheck(HouseDockers, true)
    AreaAddDockPeriod(HouseDockers, 17, 0, 300)
    DockerSetMinimumRange(HouseDockers, 2)
    DockerSetMaximumRange(HouseDockers, 12)
    AreaSetDockerChanceToDock(HouseDockers, 10)
    DockerSetUseFacingCheck(RAStoreDockers, true)
    AreaAddDockPeriod(RAStoreDockers, 7, 0, 960)
    DockerSetMinimumRange(RAStoreDockers, 5)
    DockerSetMaximumRange(RAStoreDockers, 15)
    AreaSetDockerChanceToDock(RAStoreDockers, 20)
end

function F_SetupBusinessAreaSpawners()
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_DOORSTR01,
        point = POINTLIST._BA_DOORSTR01,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_DOORSTR01,
        point = POINTLIST._BA_DOORSTR01,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_DOORSTR02,
        point = POINTLIST._BA_DOORSTR02,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_DOORSTR02,
        point = POINTLIST._BA_DOORSTR02,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_DOORSTR03,
        point = POINTLIST._BA_DOORSTR03,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_DOORSTR03,
        point = POINTLIST._BA_DOORSTR03,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_DOORSTR04,
        point = POINTLIST._BA_DOORSTR04,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_DOORSTR04,
        point = POINTLIST._BA_DOORSTR04,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_DOORSTR05,
        point = POINTLIST._BA_DOORSTR05,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_DOORSTR05,
        point = POINTLIST._BA_DOORSTR05,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_DOORSTR07,
        point = POINTLIST._BA_DOORSTR07,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_DOORSTR07,
        point = POINTLIST._BA_DOORSTR07,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_DOORSTR08,
        point = POINTLIST._BA_DOORSTR08,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_DOORSTR08,
        point = POINTLIST._BA_DOORSTR08,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_PREPDOOR02,
        point = POINTLIST._BA_PREPDOOR02,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_PREPDOOR02,
        point = POINTLIST._BA_PREPDOOR02,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_PREPDOOR03,
        point = POINTLIST._BA_PREPDOOR03,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_PREPDOOR03,
        point = POINTLIST._BA_PREPDOOR03,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_PREPDOOR04,
        point = POINTLIST._BA_PREPDOOR04,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_PREPDOOR04,
        point = POINTLIST._BA_PREPDOOR04,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_PREPDOOR05,
        point = POINTLIST._BA_PREPDOOR05,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_PREPDOOR05,
        point = POINTLIST._BA_PREPDOOR05,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_PREPDOOR06,
        point = POINTLIST._BA_PREPDOOR06,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_PREPDOOR06,
        point = POINTLIST._BA_PREPDOOR06,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_PREPDOOR09,
        point = POINTLIST._BA_PREPDOOR09,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_PREPDOOR09,
        point = POINTLIST._BA_PREPDOOR09,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_PREPDOOR10,
        point = POINTLIST._BA_PREPDOOR10,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_PREPDOOR10,
        point = POINTLIST._BA_PREPDOOR10,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._BA_PREPDOOR11,
        point = POINTLIST._BA_PREPDOOR11,
        kind = "xxx"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._BA_PREPDOOR11,
        point = POINTLIST._BA_PREPDOOR11,
        kind = "xxx"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._DT_TBUSINES_BIKESHOPDOOR,
        point = POINTLIST._TBUSINES_BIKESHOPDOOR1,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._DT_TBUSINES_CLOTHDOOR,
        point = POINTLIST._TBUSINES_CLOTHDOOR1,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._DT_TBUSINES_CLOTHDOOR,
        point = POINTLIST._TBUSINES_CLOTHDOOR1,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._DT_TBUSINES_COMICSHOPDOOR,
        point = POINTLIST._TBUSINES_COMICSHOPDOOR1,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._DT_TBUSINES_GENSHOP2DOOR,
        point = POINTLIST._TBUSINES_GENSHOP2DOOR1,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._DT_TBUSINES_GENSHOP2DOOR,
        point = POINTLIST._TBUSINES_GENSHOP2DOOR1,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._DT_TBUSINESS_BARBER,
        point = POINTLIST._TBUSINESS_BARBER1,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._DT_TBUSINESS_BARBER,
        point = POINTLIST._TBUSINESS_BARBER1,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._DT_TBUSINESS_RECORDDOOR,
        point = POINTLIST._TBUSINESS_RECORDDOOR1,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._DT_TBUSINESS_RECORDDOOR,
        point = POINTLIST._TBUSINESS_RECORDDOOR1,
        kind = "store"
    })
    table.insert(BusinessAreaSpawners, {
        trigger = TRIGGER._DT_TBUSINESS_FIREWBUSDOOR,
        point = POINTLIST._TBUSINESS_TSTOREDOOR1,
        kind = "store"
    })
    table.insert(BusinessAreaDockers, {
        trigger = TRIGGER._DT_TBUSINESS_FIREWBUSDOOR,
        point = POINTLIST._TBUSINESS_TSTOREDOOR1,
        kind = "store"
    })
end

function F_StartBusinessAreaSpawners()
    BAStoreSpawners = AreaAddAmbientSpawner(23, 1, 100, 5000)
    XXXSpawners = AreaAddAmbientSpawner(1, 1, 100, 8000)
    MovieSpawners = AreaAddAmbientSpawner(2, 1, 100, 5000)
    for i, key in BusinessAreaSpawners do
        if BusinessAreaSpawners[i].kind == "store" then
            AreaAddSpawnLocation(BAStoreSpawners, BusinessAreaSpawners[i].point, BusinessAreaSpawners[i].trigger)
        elseif BusinessAreaSpawners[i].kind == "xxx" then
            AreaAddSpawnLocation(XXXSpawners, BusinessAreaSpawners[i].point, BusinessAreaSpawners[i].trigger)
        elseif BusinessAreaSpawners[i].kind == "movie" then
            AreaAddSpawnLocation(MovieSpawners, BusinessAreaSpawners[i].point, BusinessAreaSpawners[i].trigger)
        end
    end
    AreaAddAmbientSpawnPeriod(BAStoreSpawners, 7, 0, 960)
    AreaAddAmbientSpawnPeriod(XXXSpawners, 20, 0, 600)
    AreaAddAmbientSpawnPeriod(MovieSpawners, 18, 0, 300)
    BAStoreDockers = AreaAddDocker(21, 2)
    BAKidDockers = AreaAddDocker(4, 2)
    XXXDockers = AreaAddDocker(1, 2)
    MovieDockers = AreaAddDocker(2, 2)
    for i, key in BusinessAreaDockers do
        if BusinessAreaDockers[i].kind == "store" then
            AreaAddDockLocation(BAStoreDockers, BusinessAreaDockers[i].point, BusinessAreaDockers[i].trigger)
        elseif BusinessAreaDockers[i].kind == "xxx" then
            AreaAddDockLocation(XXXDockers, BusinessAreaDockers[i].point, BusinessAreaDockers[i].trigger)
        elseif BusinessAreaDockers[i].kind == "movie" then
            AreaAddDockLocation(MovieDockers, BusinessAreaDockers[i].point, BusinessAreaDockers[i].trigger)
        end
    end
    AreaAddDockLocation(BAKidDockers, POINTLIST.tbusines_ComicShopDoor1, TRIGGER.DT_tbusines_ComicShopDoor)
    AreaAddDockLocation(BAKidDockers, POINTLIST.tbusines_BikeShopDoor1, TRIGGER.DT_tbusines_BikeShopDoor)
    AreaAddDockLocation(BAKidDockers, POINTLIST.DT_trich_BikeShopDoor1, TRIGGER.DT_trich_BikeShopDoor)
    AreaAddDockLocation(BAKidDockers, POINTLIST.DT_trich_FirewShopDoor1, TRIGGER.DT_trich_FirewShopDoor)
    AreaAddDockPeriod(XXXDockers, 20, 0, 600)
    DockerSetUseFacingCheck(XXXDockers, true)
    DockerSetMinimumRange(XXXDockers, 5)
    DockerSetMaximumRange(XXXDockers, 20)
    AreaSetDockerChanceToDock(XXXDockers, 20)
    DockerSetUseFacingCheck(BAStoreDockers, true)
    AreaAddDockPeriod(BAStoreDockers, 7, 0, 960)
    DockerSetMinimumRange(BAStoreDockers, 4)
    DockerSetMaximumRange(BAStoreDockers, 25)
    AreaSetDockerChanceToDock(BAStoreDockers, 30)
    DockerSetUseFacingCheck(BAKidDockers, true)
    AreaAddDockPeriod(BAKidDockers, 7, 0, 960)
    DockerSetMinimumRange(BAKidDockers, 4)
    DockerSetMaximumRange(BAKidDockers, 25)
    AreaSetDockerChanceToDock(BAKidDockers, 30)
    AreaSetDockerKidReception(BAKidDockers, true)
    DockerSetUseFacingCheck(MovieDockers, true)
    AreaAddDockPeriod(MovieDockers, 18, 0, 180)
    DockerSetMinimumRange(MovieDockers, 5)
    DockerSetMaximumRange(MovieDockers, 20)
    AreaSetDockerChanceToDock(MovieDockers, 20)
end

function F_SetupPoorAreaSpawners()
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.DT_tbusines_GenShop1Door,
        point = POINTLIST.tbusines_GenShop1Door1,
        kind = "store"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.DT_tbusines_GenShop1Door,
        point = POINTLIST.tbusines_GenShop1Door1,
        kind = "store"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.DT_tbusines_FirewShopDoor,
        point = POINTLIST.tbusines_FirewShopDoor1,
        kind = "store"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.DT_tbusines_FirewShopDoor,
        point = POINTLIST.tbusines_FirewShopDoor1,
        kind = "store"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_DoorStr10,
        point = POINTLIST.bu_DoorStr10,
        kind = "store"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_DoorStr10,
        point = POINTLIST.bu_DoorStr10,
        kind = "store"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor13,
        point = POINTLIST.bu_PrepDoor13,
        kind = "store"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor13,
        point = POINTLIST.bu_PrepDoor13,
        kind = "store"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor14,
        point = POINTLIST.bu_PrepDoor14,
        kind = "store"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor14,
        point = POINTLIST.bu_PrepDoor14,
        kind = "store"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor15,
        point = POINTLIST.bu_PrepDoor15,
        kind = "store"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor15,
        point = POINTLIST.bu_PrepDoor15,
        kind = "store"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor16,
        point = POINTLIST.bu_PrepDoor16,
        kind = "store"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor16,
        point = POINTLIST.bu_PrepDoor16,
        kind = "store"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor17,
        point = POINTLIST.bu_PrepDoor17,
        kind = "store"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor17,
        point = POINTLIST.bu_PrepDoor17,
        kind = "store"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor18,
        point = POINTLIST.bu_PrepDoor18,
        kind = "store"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor18,
        point = POINTLIST.bu_PrepDoor18,
        kind = "store"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor19,
        point = POINTLIST.bu_PrepDoor19,
        kind = "store"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor19,
        point = POINTLIST.bu_PrepDoor19,
        kind = "store"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor20,
        point = POINTLIST.bu_PrepDoor20,
        kind = "house"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor20,
        point = POINTLIST.bu_PrepDoor20,
        kind = "house"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor21,
        point = POINTLIST.bu_PrepDoor21,
        kind = "house"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor21,
        point = POINTLIST.bu_PrepDoor21,
        kind = "house"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor22,
        point = POINTLIST.bu_PrepDoor22,
        kind = "house"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor22,
        point = POINTLIST.bu_PrepDoor22,
        kind = "house"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor23,
        point = POINTLIST.bu_PrepDoor23,
        kind = "house"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor23,
        point = POINTLIST.bu_PrepDoor23,
        kind = "house"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor24,
        point = POINTLIST.bu_PrepDoor24,
        kind = "house"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor24,
        point = POINTLIST.bu_PrepDoor24,
        kind = "house"
    })
    table.insert(PoorAreaSpawners, {
        trigger = TRIGGER.bu_PrepDoor25,
        point = POINTLIST.bu_PrepDoor25,
        kind = "house"
    })
    table.insert(PoorAreaDockers, {
        trigger = TRIGGER.bu_PrepDoor25,
        point = POINTLIST.bu_PrepDoor25,
        kind = "house"
    })
end

function F_StartPoorAreaSpawners()
    PAStoreSpawners = AreaAddAmbientSpawner(10, 1, 100, 5000)
    PAhouseSpawners = AreaAddAmbientSpawner(6, 1, 100, 8000)
    for i, key in PoorAreaSpawners do
        if PoorAreaSpawners[i].kind == "store" then
            AreaAddSpawnLocation(PAStoreSpawners, PoorAreaSpawners[i].point, PoorAreaSpawners[i].trigger)
        elseif PoorAreaSpawners[i].kind == "house" then
            AreaAddSpawnLocation(PAhouseSpawners, PoorAreaSpawners[i].point, PoorAreaSpawners[i].trigger)
        end
    end
    AreaAddAmbientSpawnPeriod(PAStoreSpawners, 7, 0, 960)
    AreaAddAmbientSpawnPeriod(PAhouseSpawners, 7, 0, 240)
    PAStoreDockers = AreaAddDocker(10, 1)
    PAhouseDockers = AreaAddDocker(6, 1)
    for i, key in PoorAreaDockers do
        if PoorAreaDockers[i].kind == "store" then
            AreaAddDockLocation(PAStoreDockers, PoorAreaDockers[i].point, PoorAreaDockers[i].trigger)
        elseif PoorAreaDockers[i].kind == "house" then
            AreaAddDockLocation(PAhouseDockers, PoorAreaDockers[i].point, PoorAreaDockers[i].trigger)
        end
    end
    AreaAddDockPeriod(PAhouseDockers, 17, 0, 300)
    DockerSetUseFacingCheck(PAhouseDockers, true)
    DockerSetMinimumRange(PAhouseDockers, 5)
    DockerSetMaximumRange(PAhouseDockers, 20)
    AreaSetDockerChanceToDock(PAhouseDockers, 20)
    DockerSetUseFacingCheck(PAStoreDockers, true)
    AreaAddDockPeriod(PAStoreDockers, 7, 0, 960)
    DockerSetMinimumRange(PAStoreDockers, 5)
    DockerSetMaximumRange(PAStoreDockers, 20)
    AreaSetDockerChanceToDock(PAStoreDockers, 20)
end

function F_SetupIndustrialGates()
    table.insert(IndustrialGates, {
        hash = 0,
        object = "in_gate01",
        x = 171.523,
        y = -358.195,
        z = 2.41375,
        destroyed = false
    })
    table.insert(IndustrialGates, {
        hash = 0,
        object = "in_gate02",
        x = 259.617,
        y = -348.243,
        z = 2.53426
    })
    table.insert(IndustrialGates, {
        hash = 0,
        object = "in_gate03",
        x = 287.051,
        y = -332.754,
        z = 2.54751
    })
    table.insert(IndustrialGates, {
        hash = 0,
        object = "in_gate04",
        x = 294.809,
        y = -328.694,
        z = 2.47003
    })
    table.insert(IndustrialGates, {
        hash = 0,
        object = "in_gate07",
        x = 334.855,
        y = -365.759,
        z = 2.46657
    })
    table.insert(IndustrialGates, {
        hash = 0,
        object = "in_gate08",
        x = 328.544,
        y = -380,
        z = 2.45214
    })
    table.insert(IndustrialGates, {
        hash = 0,
        object = "in_gate12",
        x = 306.185,
        y = -413.489,
        z = 2.40205
    })
    table.insert(IndustrialGates, {
        hash = 0,
        object = "in_gate13",
        x = 305.556,
        y = -453.388,
        z = 3.43716
    })
    table.insert(IndustrialGates, {
        hash = 0,
        object = "in_gate14",
        x = 276.876,
        y = -466.431,
        z = 3.91125
    })
    table.insert(IndustrialGates, {
        hash = 0,
        object = "in_gate15",
        x = 246.601,
        y = -438.654,
        z = 2.59514
    })
    for i, entry in IndustrialGates do
        entry.hash = ObjectNameToHashID(entry.object)
    end
end

function F_SetupIndustrialSpawners()
    table.insert(IndustrialSpawners, {
        trigger = TRIGGER.Ind_DoorStr1,
        point = POINTLIST.Ind_DoorStr1,
        kind = "house"
    })
    table.insert(IndustrialDockers, {
        trigger = TRIGGER.Ind_DoorStr1,
        point = POINTLIST.Ind_DoorStr1,
        kind = "house"
    })
    table.insert(IndustrialSpawners, {
        trigger = TRIGGER.Ind_DoorStr02,
        point = POINTLIST.Ind_DoorStr02,
        kind = "house"
    })
    table.insert(IndustrialDockers, {
        trigger = TRIGGER.Ind_DoorStr02,
        point = POINTLIST.Ind_DoorStr02,
        kind = "house"
    })
    table.insert(IndustrialSpawners, {
        trigger = TRIGGER.DT_indoor_TattooShop,
        point = POINTLIST.Ind_DoorStr03,
        kind = "house"
    })
    table.insert(IndustrialDockers, {
        trigger = TRIGGER.DT_indoor_TattooShop,
        point = POINTLIST.Ind_DoorStr03,
        kind = "house"
    })
end

function F_StartIndustrialSpawners()
    IHouseSpawners = AreaAddAmbientSpawner(3, 1, 100, 8000)
    for i, key in IndustrialSpawners do
        if IndustrialSpawners[i].kind == "house" then
            AreaAddSpawnLocation(IHouseSpawners, IndustrialSpawners[i].point, IndustrialSpawners[i].trigger)
        end
    end
    AreaAddAmbientSpawnPeriod(IHouseSpawners, 7, 0, 1200)
    IHouseDockers = AreaAddDocker(3, 1)
    for i, key in IndustrialDockers do
        if IndustrialDockers[i].kind == "house" then
            AreaAddDockLocation(IHouseDockers, IndustrialDockers[i].point, IndustrialDockers[i].trigger)
        end
    end
    DockerSetUseFacingCheck(IHouseDockers, true)
    AreaAddDockPeriod(IHouseDockers, 7, 0, 1200)
    DockerSetMinimumRange(IHouseDockers, 2)
    DockerSetMaximumRange(IHouseDockers, 25)
    AreaSetDockerChanceToDock(IHouseDockers, 20)
end

function F_SetupSchoolGates()
    if not MissionActiveSpecific("Chapt1Trans") and not MissionActiveSpecific("6_03") then
        if IsMissionCompleated("Chapt1Trans") then
            --print("Open the gates!")
            local objID, objPool = CreatePersistentEntity("ScGate01Opened", 299.988, -72.5031, 8.04657, 0, 0)
            GeometryInstance("ScGate01Opened", false, 299.988, -72.5031, 8.04657, true)
            table.insert(shared.gSchoolGates, {
                id = objID,
                bPool = objPool,
                str = "ScGate01Opened"
            })
            objID, objPool = CreatePersistentEntity("ScGate02Opened", 224.477, 5.8009, 8.39471, 0, 0)
            GeometryInstance("ScGate02Opened", false, 224.477, 5.8009, 8.39471, true)
            table.insert(shared.gSchoolGates, {
                id = objID,
                bPool = objPool,
                str = "ScGate02Opened"
            })
        else
            --print("Close the gates!")
            local objID, objPool = CreatePersistentEntity("ScGate01Closed", 301.439, -72.5059, 8.04657, 0, 0)
            GeometryInstance("ScGate01Closed", false, 301.439, -72.5059, 8.04657, true)
            table.insert(shared.gSchoolGates, {
                id = objID,
                bPool = objPool,
                str = "ScGate01Closed"
            })
            objID, objPool = CreatePersistentEntity("ScGate02Closed", 225.928, 5.79816, 8.39471, 0, 0)
            GeometryInstance("ScGate02Closed", false, 225.928, 5.79816, 8.39471, true)
            table.insert(shared.gSchoolGates, {
                id = objID,
                bPool = objPool,
                str = "ScGate02Closed"
            })
        end
    end
end

function F_CleanupSchoolGates()
    for i, geo in shared.gSchoolGates do
        DeletePersistentEntity(geo.id, geo.bPool)
    end
end

function F_SetupHoboGates()
    if not shared.hoboGateIndex and not MissionActiveSpecific("1_06_01") then
        shared.hoboGateIndex, shared.hoboGateObject = CreatePersistentEntity("1_06_GateClosed", 165.967, 18.8144, 7.31457, 0, 0)
    end
end

function F_CleanupHoboGates()
    if shared.hoboGateIndex then
        DeletePersistentEntity(shared.hoboGateIndex, shared.hoboGateObject)
        shared.hoboGateIndex = nil
        shared.hoboGateObject = nil
    end
end

function F_RainStuff()
    if RainFlag == true then
        DockerSetOverrideActiveSetting(XXXDockers, true)
        DockerSetOverrideActiveSetting(MovieDockers, true)
        DockerSetOverrideActiveSetting(RAStoreDockers, true)
        DockerSetOverrideActiveSetting(BAStoreDockers, true)
        DockerSetOverrideActiveSetting(BAKidDockers, true)
        DockerSetOverrideActiveSetting(PAStoreDockers, true)
        DockerSetOverrideActiveSetting(HouseDockers, true)
        DockerSetOverrideActiveSetting(PAhouseDockers, true)
        DockerSetOverrideActiveSetting(ClassDockers, true)
        DockerSetOverrideActiveSetting(HangOutDockers, true)
        DockerSetOverrideActiveSetting(GDormDock, true)
        DockerSetOverrideActiveSetting(BDormDock, true)
        DockerSetOverrideActiveSetting(IHouseDockers, true)
        AreaSetDockerRunPercentage(XXXDockers, 100)
        AreaSetDockerRunPercentage(MovieDockers, 100)
        AreaSetDockerRunPercentage(RAStoreDockers, 100)
        AreaSetDockerRunPercentage(BAStoreDockers, 100)
        AreaSetDockerRunPercentage(BAKidDockers, 100)
        AreaSetDockerRunPercentage(PAStoreDockers, 100)
        AreaSetDockerRunPercentage(PAhouseDockers, 100)
        AreaSetDockerRunPercentage(HouseDockers, 100)
        AreaSetDockerRunPercentage(ClassDockers, 100)
        AreaSetDockerRunPercentage(GDormDock, 100)
        AreaSetDockerRunPercentage(BDormDock, 100)
        AreaSetDockerRunPercentage(IHouseDockers, 100)
        AreaSetDockerChanceToDock(XXXDockers, 100)
        AreaSetDockerChanceToDock(MovieDockers, 100)
        AreaSetDockerChanceToDock(RAStoreDockers, 100)
        AreaSetDockerChanceToDock(BAStoreDockers, 100)
        AreaSetDockerChanceToDock(BAKidDockers, 100)
        AreaSetDockerChanceToDock(PAStoreDockers, 100)
        AreaSetDockerChanceToDock(PAhouseDockers, 100)
        AreaSetDockerChanceToDock(HouseDockers, 100)
        AreaSetDockerChanceToDock(HangOutDockers, 100)
        AreaSetDockerChanceToDock(IHouseDockers, 100)
    elseif RainFlag == false then
        DockerClearOverrideActiveSetting(XXXDockers)
        DockerClearOverrideActiveSetting(MovieDockers)
        DockerClearOverrideActiveSetting(RAStoreDockers)
        DockerClearOverrideActiveSetting(BAStoreDockers)
        DockerClearOverrideActiveSetting(BAKidDockers)
        DockerClearOverrideActiveSetting(PAStoreDockers)
        DockerClearOverrideActiveSetting(PAhouseDockers)
        DockerClearOverrideActiveSetting(HouseDockers)
        DockerClearOverrideActiveSetting(ClassDockers)
        DockerClearOverrideActiveSetting(HangOutDockers)
        DockerClearOverrideActiveSetting(GDormDock)
        DockerClearOverrideActiveSetting(BDormDock)
        AreaSetDockerRunPercentage(XXXDockers, 0)
        AreaSetDockerRunPercentage(MovieDockers, 0)
        AreaSetDockerRunPercentage(RAStoreDockers, 0)
        AreaSetDockerRunPercentage(BAStoreDockers, 0)
        AreaSetDockerRunPercentage(BAKidDockers, 0)
        AreaSetDockerRunPercentage(PAStoreDockers, 0)
        AreaSetDockerRunPercentage(PAhouseDockers, 0)
        AreaSetDockerRunPercentage(HouseDockers, 0)
        AreaSetDockerRunPercentage(ClassDockers, 80)
        AreaSetDockerRunPercentage(HangOutDockers, 0)
        AreaSetDockerRunPercentage(GDormDock, 0)
        AreaSetDockerRunPercentage(BDormDock, 0)
        AreaSetDockerRunPercentage(IHouseDockers, 0)
        AreaSetDockerChanceToDock(XXXDockers, 20)
        AreaSetDockerChanceToDock(MovieDockers, 20)
        AreaSetDockerChanceToDock(RAStoreDockers, 20)
        AreaSetDockerChanceToDock(BAStoreDockers, 30)
        AreaSetDockerChanceToDock(BAKidDockers, 30)
        AreaSetDockerChanceToDock(PAStoreDockers, 20)
        AreaSetDockerChanceToDock(PAhouseDockers, 20)
        AreaSetDockerChanceToDock(HouseDockers, 10)
        AreaSetDockerChanceToDock(IHouseDockers, 20)
    end
end

function F_KillTables()
    SchoolGroundsSpawners = nil
    SchoolGroundsDockers = nil
    RichAreaSpawners = nil
    RichAreaDockers = nil
    BusinessAreaSpawners = nil
    BusinessAreaDockers = nil
    PoorAreaSpawners = nil
    PoorAreaDockers = nil
    IndustrialSpawners = nil
    IndustrialDockers = nil
    collectgarbage()
end

function F_MMTriggerEnterEvents(TriggerID, PedID)
    if TriggerID == TRIGGER._RETIREMENTTRIGGER and not shared.bDisableRetirementHome then
        F_StartRetirement()
        --print("starting retirement")
    elseif TriggerID == TRIGGER._MAILMANTRIGGER then
        if not IsMissionAvailable("2_09") then
            F_StartMailman()
        end
    elseif TriggerID == TRIGGER._RICHFOLKTRIGGER then
        --print("starting richfolk")
        F_EnableRichFolk()
    elseif TriggerID == TRIGGER._FOOTFIELDTRIG then
        F_StartFootball()
    end
end

function F_MMTriggerExitEvents(TriggerID)
    if TriggerID == TRIGGER._RETIREMENTTRIGGER then
        F_DeleteRetirementPeds()
    elseif TriggerID == TRIGGER._MAILMANTRIGGER then
        F_DeleteMailman()
    elseif TriggerID == TRIGGER._RICHFOLKTRIGGER then
        F_DisableRichFolk()
    elseif TriggerID == TRIGGER._FOOTFIELDTRIG then
        F_EndFootball()
    end
end

function F_SetupFactionAreas()
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._GREASERS, 4)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._POORAREA, 4)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._JOCKS, 2)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._JOCKS_FOOTBALLFIELD, 2)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._PREPS, 5)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._RICHAREA, 5)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._NERDS, 1)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._INDUSTRIALAREA_DROPOUTENCLAVE, 3)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._DT_COMICSHOP, 1)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._DT_DROPOUTALLEY, 3)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._DT_GREASERALLEY, 4)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._DT_GASSTATION, 4)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._BULLYTURF, 11)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._RICH_GREASERALLEY, 4)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._RICH_GREASERALLEY2, 4)
    AreaDeteriorateAttitudeForPopTriggerPedType(TRIGGER._POOR_DROPTURF1, 3)
end

function F_SetupIndustrialArea()
    if IsMissionCompleated("5_07a") then
        --print("[RAUL] CREATING GATE 2 IN SETUP ")
        indexOfGate, simpleObjectOfGate = CreatePersistentEntity("in_DO_Barricade02", 147.78, -484.506, 5.0257, 0, 0)
        table.insert(industrialGate, { ind = index, obj = simpleObject })
        gBarricadeCreated = 2
    else
        --print("[RAUL] CREATING GATE 1 IN SETUP ")
        index, simpleObject = CreatePersistentEntity("in_DO_Barricade01", 150.232, -483.16, 5.34952, 0, 0)
        table.insert(industrialGate, { ind = index, obj = simpleObject })
        gBarricadeCreated = 1
    end
end

function F_CleanupIndustrialArea()
    --print("[RAUL] START CLEANING UP !")
    for i, element in industrialGate do
        if element.ind then
            --print("[RAUL] CLEANING UP IN LOOP", i)
            DeletePersistentEntity(element.ind, element.obj)
            element.ind, element.obj = nil, nil
        end
    end
    industrialGateDestroyed = false
end

function F_ToggleIndustrialAreaBarricade()
    F_CleanupIndustrialArea()
    if shared.enclaveGateRespawn == 1 then
        --print("[RAUL] CREATING GATE 01")
        index, simpleObject = CreatePersistentEntity("in_DO_Barricade01", 150.232, -483.16, 5.34952, 0, 0)
        table.insert(industrialGate, { ind = index, obj = simpleObject })
        gBarricadeCreated = 1
    elseif shared.enclaveGateRespawn == 2 then
        --print("[RAUL] CREATING GATE 02")
        indexOfGate, simpleObjectOfGate = CreatePersistentEntity("in_DO_Barricade02", 147.78, -484.506, 5.0257, 0, 0)
        table.insert(industrialGate, { ind = index, obj = simpleObject })
        gBarricadeCreated = 2
    elseif shared.enclaveGateRespawn == 3 then
        --print("[RAUL] Deleting gate")
    end
    shared.enclaveGateRespawn = nil
end

function F_SetupPortaPotty()
    if not gPortaPottyCreated then
        if IsMissionCompleated("5_05") then
            gPortaPottyCreated = true
            local index, simpleObject = CreatePersistentEntity("rc2d_PortaPoo_A", 473.144, 260.006, 13.0302, 1.00179E-5, 0)
            table.insert(gPortaPottyTbl, { ind = index, obj = simpleObject })
            local index, simpleObject = CreatePersistentEntity("RI1d_railChunk1", 482.443, 266.737, 20.6787, 0, 0)
            table.insert(gPortaPottyTbl, { ind = index, obj = simpleObject })
        elseif not MissionActiveSpecific("5_05") then
            gPortaPottyCreated = true
            local index, simpleObject = CreatePersistentEntity("PortaPoo", 483.007, 267.632, 19.8585, 126.511, 0)
            table.insert(gPortaPottyTbl, { ind = index, obj = simpleObject })
        end
    end
end

function F_CleanupPortaPotty()
    for i, element in gPortaPottyTbl do
        DeletePersistentEntity(element.ind, element.obj)
    end
    gPortaPottyCreated = false
    gPortaPottyTbl = {}
end

function F_OutsideSchoolTrigger()
    if IsMissionCompleated("1_B") then
        AreaDeactivatePopulationTrigger(TRIGGER._POPROADS1)
        AreaActivatePopulationTrigger(TRIGGER._OUTSIDESCHOOL1)
    else
        AreaActivatePopulationTrigger(TRIGGER._POPROADS1)
        AreaDeactivatePopulationTrigger(TRIGGER._OUTSIDESCHOOL1)
    end
end

function F_WalkableMeshCallback(hashID)
    --print("MainMap.lua: F_WalkableMeshCallback: Finished loading walkable mesh: " .. tostring(hashID))
    if IsMissionCompleated("Chapt2Trans") and not IsMissionCompleated("3_08_PostDummy") then
        AreaSetPathableInRadius(597.511, -89.6485, 5.98401, 4, 10, false)
        AreaSetPathableInRadius(339, 209.681, 4.01, 1, 10, false)
    end
    if not IsMissionCompleated("4_03") then
        if MissionActiveSpecific("4_03") or IsMissionCompleated("4_03") then
            AreaSetPathableInRadius(1.1, -113, 2.1, 0.5, 5, true)
        else
            AreaSetPathableInRadius(1.1, -113, 2.1, 0.5, 5, false)
        end
    end
    if not IsMissionCompleated("1_02B") then
        AreaSetPathableInRadius(239.4, -105.9, 7.3, 0.2, 10, false)
    end
    if ChapterGet() < 2 then
        AreaSetPathableInRadius(502.9, -208.2, 2, 0.2, 10, false)
        AreaSetPathableInRadius(242.2, 12.4, 6.1, 0.1, 10, false)
    end
    if not IsMissionCompleated("4_B1") then
        AreaSetPathableInRadius(382.5, -423.6, 2.7, 0.01, 10, false)
        AreaSetPathableInRadius(40.9, -365.1, 0.4, 0.2, 10, false)
        AreaSetPathableInRadius(6.3, -269.9, 2.7, 5, 10, false)
        AreaSetPathableInRadius(-13.2, -234.8, 6, 10, 10, false)
    end
    for i, entry in IndustrialGates do
        AreaSetPathableInRadius(entry.x, entry.y, entry.z, 0.01, 10, false)
    end
    if not MissionActiveSpecific("Chapt1Trans") and not MissionActiveSpecific("6_03") then
        if IsMissionCompleated("Chapt1Trans") then
            AreaSetPathableInRadius(303.1998, -72.23503, 7, 0.5, 10, true)
            AreaSetPathableInRadius(226.3478, 5.853811, 7, 0.5, 10, true)
        else
            AreaSetPathableInRadius(303.1998, -72.23503, 7, 0.5, 10, false)
            AreaSetPathableInRadius(226.3478, 5.853811, 7, 0.5, 10, false)
        end
    end
    if not MissionActiveSpecific("1_06_01") then
        AreaSetDoorPathableToPeds(TRIGGER._BUSDOORS, false)
    end
    if not IsMissionCompleated("1_03") then
        AreaSetPathableInRadius(134.7, 27.6, 6.1, 0.2, 10, false)
    end
end

function F_OpenDoors()
    --print("[MainMap.lua] == Side Observatory Door opened!")
    if not PAnimIsOpen(TRIGGER._NERDPATH_BRDOOR) then
        PAnimOpenDoor(TRIGGER._NERDPATH_BRDOOR)
    end
end

function F_OrderlyCallback(pedId, pathId, nodeId)
    local randValue = math.random(1, 100)
    if 55 < randValue then
        PedSetActionNode(pedId, "/Global/Ambient/Scripted/OrderlyPatrol/OrderlyPatrol_Child", "Act/Anim/Ambient.act")
    end
end

function F_StartRetirement()
    if bRetirementEvents == false and bRetirementPedsLoaded == false then
        bRetirementEvents = true
    end
end

function F_StartMailman()
    if bMailman == false and bMailmanLoaded == false then
        bMailman = true
    end
end

function F_CreateRetirementPeds()
    local roll = math.random(1, 100)
    --print("Roll: " .. roll)
    if bRetirementPedsCreated == false and bRetirementPedsLoaded == true then
        bRetirementPedsCreated = true
        dbg_print(2, "Creating RETIREMENT PEDS")
        local hour, minute = ClockGet()
        if 5 <= hour and hour <= 17 then
            gRetirementTable.ped1 = PedCreatePoint(53, POINTLIST._SPAWNRETIREMENT1)
            ModelNotNeededAmbient(53)
            PedModelNotNeededAmbient(gRetirementTable.ped1)
            dbg_print(2, "RETIREMENT PED=" .. gRetirementTable.ped1)
            if PedIsValid(gRetirementTable.ped1) then
                local BlipID = AddBlipForChar(gRetirementTable.ped1, 0, 2, 3)
                PedFollowPath(gRetirementTable.ped1, PATH._FULLPATHOFRETIREMENT, 1, 0, F_OrderlyCallback)
                PedSetTetherToTrigger(gRetirementTable.ped1, TRIGGER._RT_TETHER)
                PedSetActionNode(gRetirementTable.ped1, "/Global/Ambient/Scripted/OrderlyPatrol/OrderlyPatrol_Child", "Act/Anim/Ambient.act")
            end
            if 20 <= roll then
                gRetirementTable.ped2 = PedCreatePoint(183, POINTLIST._OLDFOLKSSPAWN1)
                PedModelNotNeededAmbient(gRetirementTable.ped2)
                ModelNotNeededAmbient(183)
                dbg_print(2, "RETIREMENT PED=" .. gRetirementTable.ped2)
                if PedIsValid(gRetirementTable.ped2) then
                    PedFollowPath(gRetirementTable.ped2, PATH._RETOLDFOLKS1, 2, 0)
                end
            end
            if 50 <= roll then
                gRetirementTable.ped3 = PedCreatePoint(184, POINTLIST._OLDFOLKSSPAWN2)
                PedModelNotNeededAmbient(gRetirementTable.ped3)
                ModelNotNeededAmbient(184)
                dbg_print(2, "RETIREMENT PED=" .. gRetirementTable.ped3)
                if PedIsValid(gRetirementTable.ped3) then
                    PedFollowPath(gRetirementTable.ped3, PATH._RETOLDFOLKS1, 2, 0)
                end
            end
            if 70 <= roll then
                gRetirementTable.ped4 = PedCreatePoint(185, POINTLIST._OLDFOLKSSPAWN3)
                PedModelNotNeededAmbient(gRetirementTable.ped4)
                ModelNotNeededAmbient(185)
                dbg_print(2, "RETIREMENT PED=" .. gRetirementTable.ped4)
                if PedIsValid(gRetirementTable.ped4) then
                    PedFollowPath(gRetirementTable.ped4, PATH._RETOLDFOLKS3, 2, 0)
                end
            end
        elseif 17 < hour or hour < 5 then
            if 50 < roll then
                gRetirementTable.ped1 = PedCreatePoint(53, POINTLIST._SPAWNRETIREMENT1, 1)
                ModelNotNeededAmbient(53)
                PedModelNotNeededAmbient(gRetirementTable.ped1)
                dbg_print(2, "RETIREMENT PED=" .. gRetirementTable.ped1)
                if PedIsValid(gRetirementTable.ped1) then
                    local BlipID = AddBlipForChar(gRetirementTable.ped1, 0, 2, 3)
                    PedFollowPath(gRetirementTable.ped1, PATH._RIGHTOFRETIREMENT, 1, 0, F_OrderlyCallback)
                    PedSetActionNode(gRetirementTable.ped1, "/Global/Ambient/Scripted/OrderlyPatrol/OrderlyPatrol_Child", "Act/Anim/Ambient.act")
                    PedSetTetherToTrigger(gRetirementTable.ped1, TRIGGER._RT_TETHER)
                end
            else
                gRetirementTable.ped2 = PedCreatePoint(53, POINTLIST._SPAWNRETIREMENT2)
                PedModelNotNeededAmbient(gRetirementTable.ped2)
                ModelNotNeededAmbient(53)
                dbg_print(2, "RETIREMENT PED=" .. gRetirementTable.ped2)
                if PedIsValid(gRetirementTable.ped2) then
                    local BlipID = AddBlipForChar(gRetirementTable.ped2, 0, 2, 3)
                    PedFollowPath(gRetirementTable.ped2, PATH._LEFTOFRETIREMENT, 1, 0, F_OrderlyCallback)
                    PedSetActionNode(gRetirementTable.ped2, "/Global/Ambient/Scripted/OrderlyPatrol/OrderlyPatrol_Child", "Act/Anim/Ambient.act")
                    PedSetTetherToTrigger(gRetirementTable.ped2, TRIGGER._RT_TETHER)
                end
            end
        end
    end
end

function F_DeleteRetirementPeds()
    if bRetirementPedsCreated == true then
        bRetirementPedsCreated = false
        bRetirementPedsLoaded = false
        if gRetirementTable.ped1 ~= nil and gRetirementTable.ped1 ~= -1 and not PedIsDead(gRetirementTable.ped1) then
            PedMakeAmbient(gRetirementTable.ped1)
            gRetirementTable.ped1 = -1
        end
        if gRetirementTable.ped2 ~= nil and gRetirementTable.ped2 ~= -1 and not PedIsDead(gRetirementTable.ped2) then
            PedMakeAmbient(gRetirementTable.ped2)
            gRetirementTable.ped2 = -1
        end
        if gRetirementTable.ped3 ~= nil and gRetirementTable.ped3 ~= -1 and not PedIsDead(gRetirementTable.ped3) then
            PedMakeAmbient(gRetirementTable.ped3)
            gRetirementTable.ped3 = -1
        end
        if gRetirementTable.ped4 ~= nil and gRetirementTable.ped4 ~= -1 and not PedIsDead(gRetirementTable.ped4) then
            PedMakeAmbient(gRetirementTable.ped4)
            gRetirementTable.ped4 = -1
        end
        if gRetirementTable.ped5 ~= nil and gRetirementTable.ped5 ~= -1 and not PedIsDead(gRetirementTable.ped5) then
            PedMakeAmbient(gRetirementTable.ped5)
            gRetirementTable.ped5 = -1
        end
        gRetirementTable = {}
    end
end

function F_HandlePatrolPathOverridesHelper(isDisabled, shouldDisable, pathID)
    if isDisabled == true then
        if shouldDisable == false then
            AreaEnablePatrolPath(pathID)
            return false
        end
    elseif shouldDisable == true then
        AreaDisablePatrolPath(pathID)
        return true
    end
    return isDisabled
end

function F_HandlePatrolPathOverrides()
    gPatrolPath_SG_PREFECT01_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_SG_PREFECT01_disabled, shared.gTurnOff_SG_PREFECT01, PATH._SG_PREFECT01)
    gPatrolPath_SG_PREFECT02_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_SG_PREFECT02_disabled, shared.gTurnOff_SG_PREFECT02, PATH._SG_PREFECT02)
    gPatrolPath_SG_PREFECT03_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_SG_PREFECT03_disabled, shared.gTurnOff_SG_PREFECT03, PATH._SG_PREFECT03)
    gPatrolPath_SG_PREFECT04_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_SG_PREFECT04_disabled, shared.gTurnOff_SG_PREFECT04, PATH._SG_PREFECT04)
    gPatrolPath_SG_PREFECT05_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_SG_PREFECT05_disabled, shared.gTurnOff_SG_PREFECT05, PATH._SG_PREFECT05)
    gPatrolPath_SGD_PREFECT1_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_SGD_PREFECT1_disabled, shared.gTurnOff_SGD_PREFECT1, PATH._SGD_PREFECT1)
    gPatrolPath_SGD_PREFECT2_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_SGD_PREFECT2_disabled, shared.gTurnOff_SGD_PREFECT2, PATH._SGD_PREFECT2)
    gPatrolPath_SGD_PREFECT3_disabled = F_HandlePatrolPathOverridesHelper(gPatrolPath_SGD_PREFECT3_disabled, shared.gTurnOff_SGD_PREFECT3, PATH._SGD_PREFECT3)
end

function F_CheckWeatherConds()
    if ChapterGet() == 2 then
        return false
    end
    local hour, minute = ClockGet()
    local weathercheck = WeatherGet()
    if 18 < hour or hour < 8 then
        return false
    end
    if weathercheck == 2 or weathercheck == 5 then
        return false
    end
    return true
end

function F_StartSprinklers()
    if PlayerIsInTrigger(TRIGGER._AMB_RICH_AREA) and shared.gParkSprinklers == false then
        shared.gParkSprinklers = true
    end
end

function F_SprinklerThread()
    shared.gParkSprinklers = true
    for i = 1, GetPointListSize(POINTLIST._PANMAIN_SPRINKLERS) do
        local x, y, z = GetPointFromPointList(POINTLIST._PANMAIN_SPRINKLERS, i)
        local effect = EffectCreate("Sprinkler", x, y, z)
        table.insert(tblSprinklerTable, effect)
        tblFoundPeds = {
            PedFindInAreaXYZ(x, y, z, 5)
        }
        for i, entry in tblFoundPeds do
            if PedIsValid(entry) then
                PedFlee(entry, gPlayer)
            end
        end
    end
    --print(">>>[main.lua]", "Created Sprinklers")
    local nSprinklerTime = 120000
    local startTime = GetTimer()
    while nSprinklerTime > GetTimer() - startTime do
        Wait(0)
    end
    for i, effect in tblSprinklerTable do
        EffectKill(effect)
        SoundLoopStop3D("SprinklerA")
    end
    --print(">>>[main.lua]", "Deleted Sprinklers")
    bSprinklersOn = false
    shared.gParkSprinklers = false
end

function F_CreateMailman()
    if F_CheckWeatherConds() == true then
        local mindistance, tempdistance
        local x, y, z = PlayerGetPosXYZ()
        local x1, y1, z1, minpoint
        for i, point in MailmanTable do
            x1, y1, z1 = GetPointList(point)
            tempdistance = DistanceBetweenCoords2d(x1, y1, x, y)
            if mindistance == nil or mindistance > tempdistance then
                mindistance = tempdistance
                minpoint = point
            end
        end
        gMailmanID = PedCreatePoint(127, minpoint)
        ModelNotNeededAmbient(127)
        PedModelNotNeededAmbient(gMailmanID)
        --print("CREATING MAILMAN!!!")
        PedWander(gMailmanID, 0)
    end
end

function F_DeleteMailman()
    if PedIsValid(gMailmanID) then
        bMailmanCreated = false
        bMailmanLoaded = false
        --print("DELETING MAILMAN")
        PedDelete(gMailmanID)
    end
end

function F_EnableRichFolk()
    if bRichTownspeople == false then
        bRichTownspeople = true
        PedSetUniqueModelStatus(76, -1)
        PedSetUniqueModelStatus(77, -1)
        PedSetUniqueModelStatus(144, -1)
        PedSetUniqueModelStatus(148, -1)
        PedSetUniqueModelStatus(149, -1)
        PedSetUniqueModelStatus(78, -1)
        PedSetUniqueModelStatus(79, -1)
    end
end

function F_DisableRichFolk()
    if bRichTownspeople == true then
        bRichTownspeople = false
        PedSetUniqueModelStatus(76, 2)
        PedSetUniqueModelStatus(77, 2)
        PedSetUniqueModelStatus(144, 2)
        PedSetUniqueModelStatus(148, 2)
        PedSetUniqueModelStatus(149, 2)
        PedSetUniqueModelStatus(78, 2)
    end
end

function F_BarricadeTriggers()
    local CurrentChapter = ChapterGet()
    if CurrentChapter < 2 then
        AreaSetNodesSwitchedOffInTrigger(TRIGGER._POORBARRICADE, true)
    else
        AreaSetNodesSwitchedOffInTrigger(TRIGGER._POORBARRICADE, false)
    end
    if CurrentChapter < 4 then
        AreaSetNodesSwitchedOffInTrigger(TRIGGER._INDUSTRIALBARRICADE, true)
    else
        AreaSetNodesSwitchedOffInTrigger(TRIGGER._INDUSTRIALBARRICADE, false)
    end
end

local tblProps = {}
local tblBarricadeDoors = {}
local gRoundhouseOpen = false

function F_BarricadeDoorOpen(tblProp)
    --print("TRYING TO OPEN A DOOR")
    F_SetDoor(tblProp, true)
end

function F_BarricadeDoorClose(tblProp)
    --print("TRYING TO CLOSE A DOOR")
    F_SetDoor(tblProp, false)
end

function F_ResetWrapper(trigger, bClose)
    if PAnimExists(trigger) then
        PAnimReset(trigger)
        if bClose then
            PAnimCloseDoor(trigger)
        end
    end
end

function F_ResetEnclave()
    F_RoundhouseMove(false, true)
    F_ResetWrapper(TRIGGER._TINDUST_POWER_SWITCH_01)
    F_ResetWrapper(TRIGGER._TINDUST_POWER_SWITCH_02)
    F_ResetWrapper(TRIGGER._TINDUST_REDSTAR_GATE_01)
    F_ResetWrapper(TRIGGER._TINDUST_GATE_SWITCH)
    F_ResetWrapper(TRIGGER._TINDUST_TRAIN_SWITCH_01)
    F_ResetWrapper(TRIGGER._TINDUST_TRAIN_SWITCH_02)
    F_ResetWrapper(TRIGGER._TINDUST_BAR_DOOR_SWITCH_01)
    F_ResetWrapper(TRIGGER._TINDUST_BAR_DOOR_SWITCH_02)
    F_ResetWrapper(TRIGGER._TINDUST_BAR_DOOR_SWITCH_03)
    F_ResetWrapper(TRIGGER._TINDUST_BAR_DOOR_SWITCH_PORT)
    F_ResetWrapper(TRIGGER._TINDUST_REDSTAR_SECURITY_DOOR, true)
    F_ResetWrapper(TRIGGER._TINDUST_BAR_DOOR_02, true)
    F_ResetWrapper(TRIGGER._TINDUST_BAR_DOOR_01, true)
    F_ResetWrapper(TRIGGER._TINDUST_BAR_DOOR_03, true)
    F_ResetWrapper(TRIGGER._TINDUST_BAR_DOOR_PORT, true)
end

function F_SetDoor(tblProp)
    local i, tblEntry, x, y, z
    for i, tblEntry in tblBarricadeDoors do
        if tblEntry.idSwitch == tblProp.id and not tblProp.activated then
            if tblEntry.idLookAtPoint ~= nil then
                x, y, z = GetPointList(tblEntry.idLookAtPoint)
            else
                x, y, z = GetAnchorPosition(tblEntry.idDoor)
            end
            x2, y2, z2 = PedGetPosXYZ(gPlayer)
            distance = DistanceBetweenCoords3d(x, y, z, x2, y2, z2)
            if distance < 15 then
                PlayerSetControl(0)
                CameraSetWidescreen(true)
                Wait(800)
                CameraSetPath(tblEntry.idCamPath, true)
                if tblEntry.idx and tblEntry.idy and tblEntry.idz then
                    CameraLookAtXYZ(tblEntry.idx, tblEntry.idy, tblEntry.idz, true)
                else
                    CameraLookAtXYZ(x, y, z, true)
                end
                Wait(500)
            end
            if tblProp.bIsOpen then
                --print("THE PROP IS OPEN !!!")
                if tblEntry.idCloseNode then
                    PAnimSetActionNode(tblEntry.idDoor, tblEntry.idCloseNode, tblEntry.idFile)
                else
                    AreaSetDoorLocked(tblEntry.idDoor, true)
                    AreaSetDoorLockedToPeds(tblEntry.idDoor, true)
                    PAnimCloseDoor(tblEntry.idDoor)
                end
                tblProp.bIsOpen = false
            else
                --print("THE PROP IS CLOSED !!!")
                if tblEntry.idOpenNode then
                    PAnimSetActionNode(tblEntry.idDoor, tblEntry.idOpenNode, tblEntry.idFile)
                else
                    AreaSetDoorLocked(tblEntry.idDoor, false)
                    AreaSetDoorLockedToPeds(tblEntry.idDoor, false)
                    PAnimOpenDoor(tblEntry.idDoor)
                    PAnimDoorStayOpen(tblEntry.idDoor)
                end
                if tblEntry.idDoor2 then
                    AreaSetDoorLocked(tblEntry.idDoor2, false)
                    AreaSetDoorLockedToPeds(tblEntry.idDoor2, false)
                    PAnimOpenDoor(tblEntry.idDoor2)
                    PAnimDoorStayOpen(tblEntry.idDoor2)
                end
                tblProp.bIsOpen = true
            end
            if distance < 15 then
                Wait(2000)
                CameraSetWidescreen(false)
                CameraReturnToPlayer()
                PlayerSetControl(1)
            end
            if tblProp.notUseable then
                PAnimSetActionNode(tblProp.id, tblProp.notUseable, "Act/Props/BRSwitch.act")
                tblProp.activated = true
            end
            break
        end
    end
end

function F_RoundhouseMove(propId, bResetting)
    local x, y, z = -2.36, -398.84, 2.363
    x2, y2, z2 = PedGetPosXYZ(gPlayer)
    distance = DistanceBetweenCoords3d(x, y, z, x2, y2, z2)
    --print("[RAUL] MOVING THE ROUNDHOUSE ")
    if not bResetting and MissionActiveSpecific("5_07a") then
        --print("[RAUL] Setting the shared variable ")
        shared.trainButton = true
    end
    if not bResetting and distance < 15 then
        PlayerSetControl(0)
        CameraSetWidescreen(true)
        SoundLoopPlay2D("RoundHouseTurns", true)
        Wait(800)
        local tempVehicleTable = VehicleFindInAreaXYZ(x, y, z, 9, true)
        if tempVehicleTable then
            for i, bike in tempVehicleTable do
                VehicleDelete(bike)
            end
        end
        CameraSetPath(PATH._TINDUST_ROUNDHOUSE_CAM, true)
        CameraLookAtXYZ(x, y, z, true)
        Wait(500)
    end
    if gRoundhouseOpen then
        --print("---------[RAUL] CLOSING THE TRAIN ")
        gRoundhouseOpen = false
        PAnimRotate("RoundHStrain", -2.35955, -398.84, 2.36308, -64, -20)
        PAnimClearWhenDoneRotation("RoundHStrain", -2.35955, -398.84, 2.36308)
    elseif not bResetting then
        gRoundhouseOpen = true
        PAnimRotate("RoundHStrain", -2.35955, -398.84, 2.36308, 64, 20)
        PAnimClearWhenDoneRotation("RoundHStrain", -2.35955, -398.84, 2.36308)
    end
    if propId then
        PAnimSetActionNode(propId.id, "/Global/Switch/NotUseable", "Act/Props/Switch.act")
    end
    if not bResetting and distance < 15 then
        Wait(3200)
        SoundLoopPlay2D("RoundHouseTurns", false)
        Wait(1800)
        CameraSetWidescreen(false)
        CameraReturnToPlayer()
        PlayerSetControl(1)
    end
end

function F_PropMonitor()
    for i, prop in tblProps do
        if prop.bIsSwitch then
            local bPlaying = PAnimIsPlaying(prop.id, prop.actNode, prop.bRecursive)
            if bPlaying and prop.bSwitchActive == false then
                prop.bSwitchActive = true
                if prop.OnActivate ~= nil then
                    prop.OnActivate(prop)
                end
            elseif not bPlaying and prop.bSwitchActive == true then
                prop.bSwitchActive = false
                if prop.OnDeactivate ~= nil then
                    prop.OnDeactivate(prop)
                end
            end
        end
        Wait(0)
    end
end

function F_CleanupProps()
    tblProps = nil
    tblBarricadeDoors = nil
    PAnimDelete(TRIGGER._TINDUST_BAR_DOOR_01)
    PAnimDelete(TRIGGER._TINDUST_BAR_DOOR_02)
    PAnimDelete(TRIGGER._TINDUST_BAR_DOOR_03)
    collectgarbage()
end

function F_SetupProps()
    tblProps = {
        {
            id = TRIGGER._TINDUST_BAR_DOOR_SWITCH_01,
            OnActivate = F_BarricadeDoorOpen,
            bIsSwitch = true,
            bIsDoor = false,
            bIsOpen = false,
            bSwitchActive = false,
            actNode = "/Global/BRSwitch/Active",
            notUseable = "/Global/BRSwitch/NotUseable",
            activated = false,
            bRecursive = false
        },
        {
            id = TRIGGER._TINDUST_BAR_DOOR_SWITCH_02,
            OnActivate = F_BarricadeDoorOpen,
            bIsSwitch = true,
            bIsDoor = false,
            bIsOpen = false,
            bSwitchActive = false,
            actNode = "/Global/BRSwitch/Active",
            notUseable = "/Global/BRSwitch/NotUseable",
            activated = false,
            bRecursive = false
        },
        {
            id = TRIGGER._TINDUST_BAR_DOOR_SWITCH_03,
            OnActivate = F_BarricadeDoorOpen,
            bIsSwitch = true,
            bIsDoor = false,
            bIsOpen = false,
            bSwitchActive = false,
            actNode = "/Global/BRSwitch/Active",
            notUseable = "/Global/BRSwitch/NotUseable",
            activated = false,
            bRecursive = false
        },
        {
            id = TRIGGER._TINDUST_TRAIN_SWITCH_01,
            OnActivate = F_RoundhouseMove,
            bIsSwitch = true,
            bIsDoor = false,
            bIsOpen = false,
            bSwitchActive = false,
            actNode = "/Global/Switch/Active",
            bRecursive = false
        },
        {
            id = TRIGGER._TINDUST_TRAIN_SWITCH_02,
            OnActivate = F_RoundhouseMove,
            bIsSwitch = true,
            bIsDoor = false,
            bIsOpen = false,
            bSwitchActive = false,
            actNode = "/Global/Switch/Active",
            bRecursive = false
        },
        {
            id = TRIGGER._TINDUST_GATE_SWITCH,
            OnActivate = F_BarricadeDoorOpen,
            bIsSwitch = true,
            bIsDoor = false,
            bIsOpen = false,
            bSwitchActive = false,
            actNode = "/Global/BRSwitch/Active",
            notUseable = "/Global/BRSwitch/NotUseable",
            activated = false,
            bRecursive = false
        },
        {
            id = TRIGGER._TINDUST_BAR_DOOR_SWITCH_PORT,
            OnActivate = F_BarricadeDoorOpen,
            bIsSwitch = true,
            bIsDoor = false,
            bIsOpen = false,
            bSwitchActive = false,
            actNode = "/Global/BRSwitch/Active",
            bRecursive = false
        }
    }
    tblBarricadeDoors = {
        {
            idSwitch = TRIGGER._TINDUST_BAR_DOOR_SWITCH_02,
            idDoor = TRIGGER._TINDUST_BAR_DOOR_02,
            idDoor2 = TRIGGER._TINDUST_BAR_DOOR_01,
            idCamPath = PATH._TINDUST_BAR_DOOR_CAM_02,
            idx = 11.986814,
            idy = -506.3147,
            idz = 6.563723
        },
        {
            idSwitch = TRIGGER._TINDUST_BAR_DOOR_SWITCH_03,
            idDoor = TRIGGER._TINDUST_BAR_DOOR_03,
            idCamPath = PATH._TINDUST_BAR_DOOR_CAM_03
        },
        {
            idSwitch = TRIGGER._TINDUST_BAR_DOOR_SWITCH_PORT,
            idDoor = TRIGGER._TINDUST_BAR_DOOR_PORT,
            idCamPath = PATH._TINDUST_BAR_DOOR_CAM_PORT
        },
        {
            idSwitch = TRIGGER._TINDUST_GATE_SWITCH,
            idDoor = TRIGGER._TINDUST_REDSTAR_GATE_01,
            idCamPath = PATH._TINDUST_REDSTAR_GATE_CAM,
            idOpenNode = "/Global/TSGate/Actions/DefaultOpening",
            idCloseNode = "/Global/TSGate/Actions/DefaultClosing",
            idFile = "Act/Props/TSGate.act"
        }
    }
    Wait(0)
    if not PAnimExists(TRIGGER._TINDUST_BAR_DOOR_01) then
        while not PAnimRequest(TRIGGER._TINDUST_BAR_DOOR_01) do
            Wait(0)
        end
        PAnimCreate(TRIGGER._TINDUST_BAR_DOOR_01)
    end
    if not PAnimExists(TRIGGER._TINDUST_BAR_DOOR_02) then
        while not PAnimRequest(TRIGGER._TINDUST_BAR_DOOR_02) do
            Wait(0)
        end
        PAnimCreate(TRIGGER._TINDUST_BAR_DOOR_02)
    end
    if not PAnimExists(TRIGGER._TINDUST_BAR_DOOR_03) then
        while not PAnimRequest(TRIGGER._TINDUST_BAR_DOOR_03) do
            Wait(0)
        end
        PAnimCreate(TRIGGER._TINDUST_BAR_DOOR_03)
    end
    PAnimSetActionNode(TRIGGER._TINDUST_REDSTAR_GATE_01, "/Global/TSGate/Closed", "Act/Props/TSGate.act")
    AreaSetDoorLocked("TINDUST_REDSTAR_GATE_01", true)
end

function F_BusGetLocationData(location)
    for i, entry in tblBusLocations do
        --print("[Mainmap.lua] >> BUSES >> Checking Trigger: " .. location .. "/" .. tostring(entry.trig))
        if location == entry.trig then
            location = i
            --print("[Mainmap.lua] >> BUSES >> Player at Location: " .. i)
        end
    end
    x1, y1, z1 = GetPointList(tblBusLocations[location].camera)
    x2, y2, z2 = GetPointFromPointList(tblBusLocations[location].camera, 2)
    return tblBusLocations[location].path, tblBusLocations[location].rotate, x1, y1, z1, x2, y2, z2
end

function F_BusStartTransition(param, param2)
    --print("[Mainmap.lua] >> BUSES :", tostring(param), tostring(param2))
    shared.gBusTransition = param
end

function F_SetupBus()
    tblBusLocations = {
        {
            trig = TRIGGER._BUS_LOC1,
            path = PATH._BUS_LOC1_PATH,
            leave = PATH._BUS_LOC1_LEAVE,
            player = POINTLIST._BUS_LOC1_PLAYER,
            camera = POINTLIST._BUS_LOC1_CAMERA,
            rotate = nil
        },
        {
            trig = nil,
            path = PATH._BUS_LOC2_PATH,
            leave = PATH._BUS_LOC2_LEAVE,
            player = POINTLIST._BUS_LOC2_PLAYER,
            camera = POINTLIST._BUS_LOC2_CAMERA,
            rotate = nil
        },
        {
            trig = TRIGGER._BUS_LOC3,
            path = PATH._BUS_LOC3_PATH,
            camera = POINTLIST._BUS_LOC3_CAMERA,
            rotate = 180
        },
        {
            trig = TRIGGER._BUS_LOC4,
            path = PATH._BUS_LOC4_PATH,
            camera = POINTLIST._BUS_LOC4_CAMERA,
            rotate = -212
        },
        {
            trig = TRIGGER._BUS_LOC5,
            path = PATH._BUS_LOC5_PATH,
            camera = POINTLIST._BUS_LOC5_CAMERA,
            rotate = -178
        },
        {
            trig = TRIGGER._BUS_LOC6,
            path = PATH._BUS_LOC6_PATH,
            camera = POINTLIST._BUS_LOC6_CAMERA,
            rotate = 180
        },
        {
            trig = TRIGGER._BUS_LOC7,
            path = PATH._BUS_LOC7_PATH,
            camera = POINTLIST._BUS_LOC7_CAMERA,
            rotate = 180
        },
        {
            trig = TRIGGER._BUS_LOC8,
            path = PATH._BUS_LOC8_PATH,
            camera = POINTLIST._BUS_LOC8_CAMERA,
            rotate = 179
        },
        {
            trig = TRIGGER._BUS_LOC9,
            path = PATH._BUS_LOC9_PATH,
            camera = POINTLIST._BUS_LOC9_CAMERA,
            rotate = 180
        },
        {
            trig = TRIGGER._BUS_LOCX,
            path = PATH._BUS_LOC10_PATH,
            camera = POINTLIST._BUS_LOC10_CAMERA,
            rotate = 22
        }
    }
    --print("************************************** tblBusLocations Entries = " .. table.getn(tblBusLocations))
end

function F_BusTransition()
    local path, rotate, camx, camy, camz, px, py, pz
    SoundDisableSpeech_ActionTree()
    PedSetFlag(gPlayer, 108, true)
    PedSetInvulnerable(gPlayer, true)
    SoundFadeWithCamera(false)
    PlayerSetControl(0)
    SoundDisableSpeech_ActionTree()
    SoundPlayScriptedSpeechEvent_2D("BUS", 2)
    CameraFade(1000, 0)
    while not PAnimRequest(TRIGGER._BUS_BUS) do
        Wait(0)
    end
    path, rotate, camx, camy, camz, px, py, pz = F_BusGetLocationData(shared.gBusTransition)
    PAnimCreate(TRIGGER._BUS_BUS)
    if rotate then
        PAnimRotate(TRIGGER._BUS_BUS, rotate, rotate)
        PAnimClearWhenDoneRotation(TRIGGER._BUS_BUS)
    end
    Wait(1005)
    F_BusMakeSafeForNIS()
    AreaClearAllVehicles()
    CameraSetWidescreen(true)
    CameraFade(1000, 1)
    CameraSetFOV(50)
    CameraSetXYZ(camx, camy, camz, px, py, pz + 1)
    PAnimFollowPath(TRIGGER._BUS_BUS, path, true)
    F_BusSlowdown(true)
    Wait(800)
    SoundFadeWithCamera(true)
    CameraFade(1000, 0)
    Wait(1005)
    CameraReturnToPlayer()
    path, player, camx, camy, camz = F_BusGetDestinationData()
    PedSetEffectedByGravity(gPlayer, false)
    AreaForceLoadAreaByAreaTransition(true)
    AreaTransitionPoint(0, player, 1, true)
    AreaForceLoadAreaByAreaTransition(false)
    while AreaIsLoading() do
        Wait(0)
    end
    PAnimDelete(TRIGGER._BUS_BUS)
    PAnimCreate(TRIGGER._BUS_BUS)
    PedSetEffectedByGravity(gPlayer, true)
    SoundStopCurrentSpeechEvent()
    SoundPlayScriptedSpeechEvent_2D("BUS", 1)
    px, py, pz = PlayerGetPosXYZ()
    CameraSetXYZ(camx, camy, camz, px, py, pz + 0.5)
    PAnimFollowPath(TRIGGER._BUS_BUS, path, true)
    PAnimSetPathFollowSpeed(TRIGGER._BUS_BUS, 0)
    AreaClearAllVehicles()
    Wait(500)
    CameraDefaultFOV()
    CameraFade(1000, 1)
    Wait(1500)
    SoundEnableSpeech_ActionTree()
    PAnimFollowPath(TRIGGER._BUS_BUS, path, true)
    F_BusSlowdown(false)
    Wait(800)
    PedSetInvulnerable(gPlayer, false)
    F_MakePlayerSafeForNIS(false)
    PedSetFlag(gPlayer, 108, false)
    PlayerSetControl(1)
    CameraSetWidescreen(false)
    CameraReturnToPlayer(false)
    PAnimDelete(TRIGGER._BUS_BUS)
    SoundEnableSpeech_ActionTree()
    bOnBus = nil
    shared.gBusTransition = nil
end

function F_BusMakeSafeForNIS()
    EnterNIS()
    AreaClearAllExplosions()
    AreaClearAllProjectiles()
    PedSetFlag(gPlayer, 2, false)
    DisablePunishmentSystem(true)
    StopAmbientPedAttacks()
    SetAmbientPedsIgnoreStimuli(true)
    PedStop(gPlayer)
    PedSetInvulnerable(gPlayer, true)
    AreaClearAllPeds()
    StopPedProduction(true)
    shared.bClearedPopulationBeforeCut = true
end

function F_BusSlowdown(bSlowDown)
    local nAcceleration, nStartSpeed = 0, 0
    if bSlowDown then
        nStartSpeed, nAcceleration = 12, -1
    else
        nStartSpeed, nAcceleration = 0, 1
    end
    for i = 1, 12 do
        --print("BUS SPEED = ", nStartSpeed + nAcceleration)
        PAnimSetPathFollowSpeed(TRIGGER._BUS_BUS, nStartSpeed)
        nStartSpeed = nStartSpeed + nAcceleration
        Wait(100)
    end
end

function F_BusGetDestinationData(trigger)
    return tblBusLocations[2].leave, tblBusLocations[2].player, GetPointList(tblBusLocations[2].camera)
end

local ceX, ceY, ceZ

function F_CheckCarnival()
    if not gPlayerInCarnival and (PlayerIsInTrigger(TRIGGER._CARNY_ENTRANCE) or PlayerIsInTrigger(TRIGGER._CARNY_GAMESAREA) or PlayerIsInTrigger(TRIGGER._CARNY_GOKARTAREA)) then
        --print("[CARNIVAL] PLAYER IS IN THE CARNIVAL NOW")
        if PlayerHasItem(479) then
            AreaSetDoorLocked(TRIGGER._CARNGATE01, false)
            AreaSetDoorLocked(TRIGGER._CARNGATE02, false)
            AreaSetDoorLocked(TRIGGER._CARNGATE03, false)
            AreaSetDoorLocked(TRIGGER._CARNGATE04, false)
        else
            gCarnivalEntranceCorona = BlipAddPoint(POINTLIST._CARNIEENTRANCECORONA, 0, 1, 0, 8)
            ceX, ceY, ceZ = GetPointList(POINTLIST._CARNIEENTRANCECORONA)
            AreaSetDoorLocked(TRIGGER._CARNGATE01, true)
            AreaSetDoorLockedToPeds(TRIGGER._CARNGATE01, false)
            AreaSetDoorLocked(TRIGGER._CARNGATE02, true)
            AreaSetDoorLockedToPeds(TRIGGER._CARNGATE02, false)
            AreaSetDoorLocked(TRIGGER._CARNGATE03, true)
            AreaSetDoorLockedToPeds(TRIGGER._CARNGATE03, false)
            AreaSetDoorLocked(TRIGGER._CARNGATE04, true)
            AreaSetDoorLockedToPeds(TRIGGER._CARNGATE04, false)
        end
        gPlayerInCarnival = true
    elseif gPlayerInCarnival then
        if not PlayerIsInTrigger(TRIGGER._CARNY_ENTRANCE) and not PlayerIsInTrigger(TRIGGER._CARNY_GAMESAREA) and not PlayerIsInTrigger(TRIGGER._CARNY_GOKARTAREA) then
            --print("[CARNIVAL] PLAYER IS NOT IN THE CARNIVAL NOW")
            gPlayerInCarnival = false
        elseif not gCarnivalEntranceCorona and 0 >= ItemGetCurrentNum(479) then
            gPlayerInCarnival = false
            --print("[CARNIVAL] PLAYER IS NOT IN THE CARNIVAL NOW 1")
        end
        if gCarnivalEntranceCorona then
            if PlayerIsInTrigger(TRIGGER._ZONECARNIVAL) and 0 >= ItemGetCurrentNum(479) then
                GiveItemToPlayer(479, 1)
                shared.PlayerGotCarnieTicket = GetCurrentDay(false)
                BlipRemove(gCarnivalEntranceCorona)
                gCarnivalEntranceCorona = nil
                AreaSetDoorLocked(TRIGGER._CARNGATE01, false)
                AreaSetDoorLocked(TRIGGER._CARNGATE02, false)
                AreaSetDoorLocked(TRIGGER._CARNGATE03, false)
                AreaSetDoorLocked(TRIGGER._CARNGATE04, false)
            end
            if PlayerIsInAreaXYZ(ceX, ceY, ceZ, 1, 0) then
                TextPrint("USE_BUYTICKET", 1, 3)
                if IsButtonPressed(9, 0) then
                    if PlayerGetMoney() < 100 then
                        TextPrint("GIFT_NEG", 1, 3)
                        Wait(1000)
                        SoundPlay2D("NavInvalid")
                    else
                        shared.PlayerGotCarnieTicket = GetCurrentDay(false)
                        GiveItemToPlayer(479, 1)
                        BlipRemove(gCarnivalEntranceCorona)
                        gCarnivalEntranceCorona = nil
                        PlayerAddMoney(-100, false)
                        SoundPlay2D("BuyItem")
                        AreaSetDoorLocked(TRIGGER._CARNGATE01, false)
                        AreaSetDoorLocked(TRIGGER._CARNGATE02, false)
                        AreaSetDoorLocked(TRIGGER._CARNGATE03, false)
                        AreaSetDoorLocked(TRIGGER._CARNGATE04, false)
                    end
                end
            end
        end
    end
end

function F_PeteyOnThePier()
    if IsMissionAvailable("2_09") and not MissionActive() and not bPeteyCreatedAndWaiting and PlayerIsInTrigger(TRIGGER._PETEYPIER) then
        while not RequestModel(134, true) do
            Wait(0)
        end
        gPeteyPier = PedCreatePoint(134, POINTLIST._PETEYPIER)
        PedSetPOI(gPeteyPier, POI._PETEYPIER, false)
        PedModelNotNeededAmbient(gPeteyPier)
        ModelNotNeededAmbient(134)
        bPeteyCreatedAndWaiting = true
    end
    if bPeteyCreatedAndWaiting and (not (not MissionActive() and PlayerIsInTrigger(TRIGGER._PETEYPIER)) or not IsMissionAvailable("2_09")) then
        if PedIsValid(gPeteyPier) then
            PedMakeAmbient(gPeteyPier)
        end
        bPeteyCreatedAndWaiting = false
    end
end

function F_MovieTicketLine()
    if IsMissionAvailable("2_06") and not MissionActive() and ClockGet() >= 8 and ClockGet() < 20 and not shared.b2_06Failed and not shared.bMovieTicketLine and PlayerIsInAreaXYZ(346.873, 218.43, 4.95147, 50, 0) then
        while not RequestModel(38, true) do
            Wait(0)
        end
        while not RequestModel(25, true) do
            Wait(0)
        end
        while not RequestModel(30, true) do
            Wait(0)
        end
        gPinkyTicket = PedCreateXYZ(38, 342.93, 224.62, 4.90147)
        PedModelNotNeededAmbient(gPinkyTicket)
        ModelNotNeededAmbient(38)
        PedFaceHeading(gPinkyTicket, 120, 0)
        gGordTicket = PedCreateXYZ(30, 345.847, 221.686, 4.95147)
        PedModelNotNeededAmbient(gGordTicket)
        ModelNotNeededAmbient(30)
        gLolaTicket = PedCreateXYZ(25, 345.98, 220.851, 4.95147)
        PedModelNotNeededAmbient(gLolaTicket)
        ModelNotNeededAmbient(25)
        PedRecruitAlly(gGordTicket, gLolaTicket, true)
        shared.bMovieTicketLine = true
    end
    if shared.bMovieTicketLine and (not (not MissionActive() and PlayerIsInAreaXYZ(346.873, 218.43, 4.95147, 55, 0)) or not IsMissionAvailable("2_06")) then
        shared.b2_06Failed = false
        if PedIsValid(gPinkyTicket) then
            PedMakeAmbient(gPinkyTicket)
        end
        if PedIsValid(gGordTicket) then
            PedMakeAmbient(gGordTicket)
        end
        if PedIsValid(gLolaTicket) then
            PedMakeAmbient(gLolaTicket)
        end
        shared.bMovieTicketLine = false
    end
    if shared.bMovieTicketLine and ClockGet() >= 20 then
        shared.b2_06Failed = false
        if PedIsValid(gPinkyTicket) then
            PedMakeAmbient(gPinkyTicket)
        end
        if PedIsValid(gGordTicket) then
            PedMakeAmbient(gGordTicket)
        end
        if PedIsValid(gLolaTicket) then
            PedMakeAmbient(gLolaTicket)
        end
        shared.bMovieTicketLine = false
    end
    if shared.b2_06Failed and not PlayerIsInAreaXYZ(346.873, 218.43, 4.95147, 55, 0) then
        shared.b2_06Failed = false
        shared.bMovieTicketLine = false
    end
end

local FootballPed1 = -1
local FootballPed2 = -1
local FootballPed3 = -1
local FootballPed4 = -1
local FootballPedCount = 2

function F_CritereaMet()
    local iCount = 0
    if FootballPed1 ~= -1 then
        iCount = iCount + 1
    end
    if FootballPed2 ~= -1 then
        iCount = iCount + 1
    end
    if FootballPed3 ~= -1 then
        iCount = iCount + 1
    end
    if FootballPed4 ~= -1 then
        iCount = iCount + 1
    end
    return iCount >= FootballPedCount
end

function F_FootballFieldThread()
    local hour, minute = ClockGet()
    local POIFaction
    if 18 < hour or hour < 8 then
        return
    end
    if 9 <= hour and hour < 11 or 13 <= hour and hour < 15 then
        POIFaction = 12
    else
        POIFaction = 2
    end
    FootballPed1 = -1
    FootballPed2 = -1
    FootballPed3 = -1
    FootballPed4 = -1
    FootballPedCount = 2
    local FourRunners = false
    local char1, char2, char3, char4
    if math.random(1, 100) > 50 then
        FourRunners = true
        FootballPedCount = 4
    end
    local TryCount = 1
    while F_CritereaMet() == false and TryCount < 40 do
        if FootballPed1 == -1 then
            FootballPed1 = GetGymModel(POIFaction)
            if FootballPed1 == FootballPed2 or FootballPed1 == FootballPed3 or FootballPed1 == FootballPed4 then
                FootballPed1 = -1
            end
        end
        if FootballPed2 == -1 then
            FootballPed2 = GetGymModel(POIFaction)
            if FootballPed2 == FootballPed1 or FootballPed2 == FootballPed3 or FootballPed2 == FootballPed4 then
                FootballPed2 = -1
            end
        end
        if FootballPed3 == -1 then
            FootballPed3 = GetGymModel(POIFaction)
            if FootballPed3 == FootballPed1 or FootballPed3 == FootballPed2 or FootballPed3 == FootballPed4 then
                FootballPed3 = -1
            end
        end
        if FootballPed4 == -1 then
            FootballPed4 = GetGymModel(POIFaction)
            if FootballPed4 == FootballPed1 or FootballPed4 == FootballPed2 or FootballPed4 == FootballPed3 then
                FootballPed4 = -1
            end
        end
        TryCount = TryCount + 1
    end
    if FootballPed1 == -1 or FootballPed2 == -1 then
        bFootballThread = false
        return
    end
    if FootballPed1 ~= -1 then
        LoadPedPOIModel(FootballPed1)
        if PedGetPedCountWithModel(FootballPed1) == 0 then
            char = PedCreatePoint(FootballPed1, POINTLIST._FOOTBALLOUTSIDE)
        end
        ModelNotNeededAmbient(FootballPed1)
    end
    if FootballPed2 ~= -1 then
        LoadPedPOIModel(FootballPed2)
        if PedGetPedCountWithModel(FootballPed2) == 0 then
            char2 = PedCreatePoint(FootballPed2, POINTLIST._FOOTBALLINSIDE)
        end
        ModelNotNeededAmbient(FootballPed2)
    end
    if FootballPed3 ~= -1 then
        LoadPedPOIModel(FootballPed3)
        if PedGetPedCountWithModel(FootballPed3) == 0 then
            char3 = PedCreatePoint(FootballPed3, POINTLIST._FOOTBALLOUTSIDE2)
        end
        ModelNotNeededAmbient(FootballPed3)
    end
    if FootballPed4 ~= -1 then
        LoadPedPOIModel(FootballPed4)
        if PedGetPedCountWithModel(FootballPed4) == 0 then
            char4 = PedCreatePoint(FootballPed4, POINTLIST._FOOTBALLINSIDE2)
        end
        ModelNotNeededAmbient(FootballPed4)
    end
    if PedIsValid(char) then
        PedFollowPath(char, PATH._OUTSIDE_PATH, 1, 1, nil)
        PedClearAllWeapons(char)
    end
    if PedIsValid(char2) then
        PedFollowPath(char2, PATH._INSIDE_PATH, 1, 1, nil)
        PedClearAllWeapons(char2)
    end
    if PedIsValid(char3) then
        PedFollowPath(char3, PATH._OUTSIDE_PATH, 1, 1, nil)
        PedClearAllWeapons(char3)
    end
    if PedIsValid(char4) then
        PedFollowPath(char4, PATH._INSIDE_PATH, 1, 1, nil)
        PedClearAllWeapons(char4)
    end
    while bFootballEvents == true do
        if not shared.bFootBallFieldEnabled then
            print(">>>[RUI]", "Kill footballers")
            break
        end
        Wait(0)
    end
    if PedIsValid(char) then
        PedMakeAmbient(char)
    end
    if PedIsValid(char2) then
        PedMakeAmbient(char2)
    end
    if PedIsValid(char3) then
        PedMakeAmbient(char3)
    end
    if PedIsValid(char4) then
        PedMakeAmbient(char4)
    end
    bFootballThread = false
end

function F_StartFootball()
    bFootballThread = true
end

function F_EndFootball()
    bFootballEvents = false
end
