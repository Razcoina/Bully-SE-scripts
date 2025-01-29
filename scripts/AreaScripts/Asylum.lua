local gOrderlyABlock = -1
local gOrderlyBBlock = -1
local gOrderlyShower = -1
local gOrderlyFrontD = -1
local bAsylumBusted = false
local peds = { 53, 158 }

function main()
    DATLoad("iasylum.DAT", 0)
    DATLoad("SP_Asylum.DAT", 0)
    if shared.bAsylumPatrols then
        F_AsylumLoadOrderlies()
    end
    F_PreDATInit()
    DATInit()
    if shared.bAsylumPatrols then
        gOrderlyABlock = F_AsylumCreateOrderly(53, POINTLIST._ASYLUM_ABLOCK, PATH._ASYLUM_PATROL_ABLOCK, 1)
        gOrderlyBBlock = F_AsylumCreateOrderly(53, POINTLIST._ASYLUM_BBLOCK, PATH._ASYLUM_PATROL_BBLOCK, 1)
        gOrderlyShower = F_AsylumCreateOrderly(53, POINTLIST._ASYLUM_SHOWER, PATH._ASYLUM_PATROL_SHOWER, 1)
        gOrderlyRecRoom = F_AsylumCreateOrderly(53, POINTLIST._ASYLUM_RECROOM, PATH._ASYLUM_PATROL_RECROOM, 1)
        F_AsylumLockDoors()
    end
    shared.gAreaDATFileLoaded[38] = true
    shared.gAreaDataLoaded = true
    PAnimOpenDoor(TRIGGER._CELLDOOR12)
    while AreaGetVisible() == 38 and not SystemShouldEndScript() do
        F_AsylumSwitch()
        Wait(0)
    end
    DATUnload(0)
    if shared.bAsylumPatrols then
        if PedIsValid(gOrderlyABlock) then
            PedDelete(gOrderlyABlock)
        end
        if PedIsValid(gOrderlyBBlock) then
            PedDelete(gOrderlyBBlock)
        end
        if PedIsValid(gOrderlyShower) then
            PedDelete(gOrderlyShower)
        end
        if PedIsValid(gOrderlyRecRoom) then
            PedDelete(gOrderlyRecRoom)
        end
        if PedIsValid(gOrderlyFrontD) then
            PedDelete(gOrderlyFrontD)
        end
    end
    shared.gAreaDataLoaded = false
    shared.gAreaDATFileLoaded[38] = false
    collectgarbage()
end

function F_AsylumLoadOrderlies()
    LoadPedModels(peds)
end

function F_AsylumCreateOrderly(model, point, path, followtype)
    local ped = PedCreatePoint(model, point, 1)
    PedOverrideStat(ped, 3, 8)
    PedOverrideStat(ped, 2, 70)
    if not ClothingIsWearingOutfit("Orderly") then
        PedSetStealthBehavior(ped, 1)
    end
    PedFollowPath(ped, path, followtype, 0)
    return ped
end

function F_AsylumLockDoors()
    AreaSetDoorLocked(TRIGGER._CELLDOOR, true)
    AreaSetDoorLocked(TRIGGER._CELLDOOR12, true)
    AreaSetDoorLocked(TRIGGER._CELLDOOR13, true)
    AreaSetDoorLocked(TRIGGER._CELLDOOR14, true)
    AreaSetDoorLocked(TRIGGER._CELLDOOR15, true)
    AreaSetDoorLocked(TRIGGER._CELLDOOR16, true)
    AreaSetDoorLocked(TRIGGER._CELLDOOR17, true)
    AreaSetDoorLocked(TRIGGER._CELLDOOR18, true)
    AreaSetDoorLocked(TRIGGER._CELLDOOR19, true)
    AreaSetDoorLocked(TRIGGER._CELLDOOR20, true)
    AreaSetDoorLocked(TRIGGER._CELLDOOR21, true)
    AreaSetDoorLocked(TRIGGER._FMDOOR02, true)
    AreaSetDoorLocked(TRIGGER._ASYDOORB, false)
    AreaSetDoorLocked(TRIGGER._ASYDOORS, false)
    AreaSetDoorLocked(TRIGGER._ASYDOORS10, false)
    AreaSetDoorLocked(TRIGGER._ASYDOORS11, false)
    AreaSetDoorLocked(TRIGGER._ASYDOORS12, false)
    AreaSetDoorLocked(TRIGGER._ASYDOORS13, false)
    AreaSetDoorLocked(TRIGGER._ASYDOORS14, false)
    AreaSetDoorLocked(TRIGGER._ASYDOORS15, false)
    AreaSetDoorLockedToPeds(TRIGGER._ASYDOORS, false)
    AreaSetDoorLockedToPeds(TRIGGER._ASYDOORB, false)
    AreaSetDoorLockedToPeds(TRIGGER._ASYDOORS10, false)
    AreaSetDoorLockedToPeds(TRIGGER._ASYDOORS11, false)
    AreaSetDoorLockedToPeds(TRIGGER._ASYDOORS12, false)
    AreaSetDoorLockedToPeds(TRIGGER._ASYDOORS13, false)
    AreaSetDoorLockedToPeds(TRIGGER._ASYDOORS14, false)
    AreaSetDoorLockedToPeds(TRIGGER._ASYDOORS15, false)
end

function F_AsylumSwitch()
end
