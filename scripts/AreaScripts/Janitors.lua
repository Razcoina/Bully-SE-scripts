local FIREDAMAGE = 40
local FIREHEALTH = 1000
local fire0, fire1, fire2

function main()
    shared.gAreaDATFileLoaded[8] = false
    DATLoad("janitors.DAT", 0)
    DATLoad("SP_Janitors_Room.DAT", 0)
    F_PreDATInit()
    DATInit()
    Wait(2000)
    shared.gHoleGateOpenIndex, shared.gHoleGateOpenGeometry = CreatePersistentEntity("FightPit_DoorOpen", -770.009, -127.039, 8.801, 0, 8)
    shared.gAreaDATFileLoaded[8] = true
    if not shared.on_mission_110 then
        FiresCreate()
        DoorsOpenAll(true)
    else
        DoorsOpenAll(false)
    end
    while not (AreaGetVisible() ~= 8 or SystemShouldEndScript()) do
        Wait(32)
    end
    if not shared.on_mission_110 then
        FiresCleanup()
    end
    DATUnload(0)
    shared.gAreaDATFileLoaded[8] = false
    DeletePersistentEntity(shared.gHoleGateOpenIndex, shared.gHoleGateOpenGeometry)
    collectgarbage()
end

function FiresCreate()
    fire0 = FireCreate(TRIGGER._JANEXTRAFIRE, FIREHEALTH, FIREDAMAGE, 100, 115, "boilerfire2")
    fire1 = FireCreate(TRIGGER._JANFIRE01, FIREHEALTH, FIREDAMAGE, 100, 115, "boilerfire2")
    fire2 = FireCreate(TRIGGER._JANFIRE02, FIREHEALTH, FIREDAMAGE, 100, 115, "boilerfire2")
    bFiresCreated = true
    --print(">>>[RUI]", "++Janitor::FiresCreate")
    Wait(1000)
end

function CleanupFire(fire)
    if fire and fire ~= -1 then
        FireDestroy(fire)
    end
end

function FiresCleanup()
    if not bFiresCreated then
        return
    end
    CleanupFire(fire0)
    CleanupFire(fire1)
    CleanupFire(fire2)
    --print(">>>[RUI]", "--Janitor::FiresCleanup()")
end

function DoorsOpenAll(bOpen)
    if bOpen then
        --print(">>>[RUI]", "Janitors::DoorsOpenAll() true")
        PAnimOpenDoor(TRIGGER._JANDOORS00)
        PAnimOpenDoor(TRIGGER._JANDOORS01)
        PAnimOpenDoor(TRIGGER._JANDOORS02)
        PAnimOpenDoor(TRIGGER._JANDOORS03B)
        PAnimDoorStayOpen(TRIGGER._JANDOORS00)
        PAnimDoorStayOpen(TRIGGER._JANDOORS01)
        PAnimDoorStayOpen(TRIGGER._JANDOORS02)
        PAnimDoorStayOpen(TRIGGER._JANDOORS03B)
        AreaSetDoorLockedToPeds(TRIGGER._JANDOORS00, false)
        AreaSetDoorLocked(TRIGGER._JANDOORS00, false)
        AreaSetDoorPathableToPeds(TRIGGER._JANDOORS00, true)
        AreaSetDoorLockedToPeds(TRIGGER._JANDOORS01, false)
        AreaSetDoorLocked(TRIGGER._JANDOORS01, false)
        AreaSetDoorPathableToPeds(TRIGGER._JANDOORS01, true)
        AreaSetDoorLockedToPeds(TRIGGER._JANDOORS02, false)
        AreaSetDoorLocked(TRIGGER._JANDOORS02, false)
        AreaSetDoorPathableToPeds(TRIGGER._JANDOORS02, true)
        AreaSetDoorLockedToPeds(TRIGGER._JANDOORS03B, false)
        AreaSetDoorLocked(TRIGGER._JANDOORS03B, false)
        AreaSetDoorPathableToPeds(TRIGGER._JANDOORS03B, true)
        AreaSetDoorLockedToPeds(TRIGGER._DT_JANITOR_SCHOOLEXIT, false)
        AreaSetDoorLocked(TRIGGER._DT_JANITOR_SCHOOLEXIT, false)
        AreaSetDoorPathableToPeds(TRIGGER._DT_JANITOR_SCHOOLEXIT, true)
    else
        --print(">>>[RUI]", "Janitors::DoorsOpenAll() false")
        PAnimCloseDoor(TRIGGER._JANDOORS00)
        PAnimCloseDoor(TRIGGER._JANDOORS01)
        PAnimCloseDoor(TRIGGER._JANDOORS02)
        PAnimCloseDoor(TRIGGER._JANDOORS03B)
        AreaSetDoorLockedToPeds(TRIGGER._JANDOORS00, true)
        AreaSetDoorLocked(TRIGGER._JANDOORS00, true)
        AreaSetDoorPathableToPeds(TRIGGER._JANDOORS00, false)
        AreaSetDoorLockedToPeds(TRIGGER._JANDOORS01, true)
        AreaSetDoorLocked(TRIGGER._JANDOORS01, true)
        AreaSetDoorPathableToPeds(TRIGGER._JANDOORS01, false)
        AreaSetDoorLockedToPeds(TRIGGER._JANDOORS02, true)
        AreaSetDoorLocked(TRIGGER._JANDOORS02, true)
        AreaSetDoorPathableToPeds(TRIGGER._JANDOORS02, false)
        AreaSetDoorLockedToPeds(TRIGGER._JANDOORS03B, true)
        AreaSetDoorLocked(TRIGGER._JANDOORS03B, true)
        AreaSetDoorPathableToPeds(TRIGGER._JANDOORS03B, false)
        AreaSetDoorLockedToPeds(TRIGGER._DT_JANITOR_SCHOOLEXIT, true)
        AreaSetDoorLocked(TRIGGER._DT_JANITOR_SCHOOLEXIT, true)
        AreaSetDoorPathableToPeds(TRIGGER._DT_JANITOR_SCHOOLEXIT, false)
    end
end
