ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPhotography.lua")
local mission_started = false
local idGord, idFire

function MissionSetup()
    DATLoad("tphotoglass.DAT", 2)
    mission_started = true
end

function MissionCleanup()
    DATUnload(2)
    if idGord ~= nil then
        PedDelete(idGord)
    end
    if idFire ~= nil then
        FireDestroy(idFire)
    end
    mission_started = false
end

function F_PhotoTaken(tblTargets)
    local i, tblEntry
    local strText = "Photo taken with "
    for i, tblEntry in tblTargets do
        if tblEntry.id ~= nil then
            strText = strText .. "ped "
        elseif tblEntry.x ~= nil then
            strText = strText .. "point "
        end
    end
    strText = strText .. "in view."
    TextPrintString(strText, 4, 2)
end

function main()
    AreaTransitionPoint(0, POINTLIST._TPHOTO_PSTARTG)
    PedSetWeapon(0, 328, 10000)
    idGord = PedCreatePoint(30, POINTLIST._TPHOTO_PEDG)
    idFire = FireCreate(TRIGGER._TPHOTO_FIREG, 10000, 1, 20, 100)
    local x2, y2, z2 = GetAnchorPosition(TRIGGER._TPHOTO_FIREG)
    L_AddPhotoTarget("testphotos", {
        { id = idGord, type = 2 },
        {
            x = x2,
            y = y2,
            z = z2
        }
    })
    L_PhotoSetFunction(F_PhotoTaken)
    TextPrintString("Take a picture of Gord or the fire (you cannot see the fire through the glass).", 2, 1)
    CreateThread("L_MonitorTargets")
    while mission_started do
        Wait(0)
    end
    L_StopMonitoringTargets()
end
