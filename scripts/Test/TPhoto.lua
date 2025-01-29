ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPhotography.lua")
local mission_started = false
local idGord, idFire

function MissionSetup()
    DATLoad("tphoto.DAT", 2)
    mission_started = true
    HUDPhotographySetColourUpgrade(false)
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

function G_TestScriptedCamTestCase()
    TextPrintString("Going into scripted cam in 3 seconds", 4, 2)
    Wait(3000)
    CameraSetWidescreen(true)
    CameraLookAtObject(gPlayer, 2, true, 1)
    CameraSetPath(PATH._TPHOTO_CAMPATH, true)
    Wait(20000)
    CameraSetWidescreen(false)
    CameraReturnToPlayer()
    Wait(500000)
end

function F_PictureTaken()
    --print("TargetEnum: Start")
    PhotoGetEntityStart()
    local gEntity, gType = PhotoGetEntityNext()
    while gEntity ~= -1 do
        --print("TargetEnum: Target ID", gEntity, ", TargetType: ", gType)
        gEntity, gType = PhotoGetEntityNext()
    end
    --print("TargetEnum: [Last] Target ID", gEntity, ", TargetType: ", gType)
end

function F_PictureTakenThread()
    while true do
        F_PictureTaken()
        Wait(1000)
    end
end

function main()
    PedSetWeaponNow(0, 328, 10000)
    WeaponSetRangeMultiplier(0, 328, 20)
    idGord = PedCreatePoint(30, POINTLIST._TPHOTO_PED)
    idFire = FireCreate(TRIGGER._TPHOTO_FIRE, 10000, 1, 20, 100)
    local x2, y2, z2 = GetAnchorPosition(TRIGGER._TPHOTO_FIRE)
    L_AddPhotoTarget("testphotos", {
        { id = idGord, type = 2 },
        {
            x = x2,
            y = y2,
            z = z2
        }
    })
    L_PhotoSetFunction(F_PhotoTaken)
    TextPrintString("Take a picture of Gord or the fire", 2, 1)
    CreateThread("L_MonitorTargets")
    TextPrintString("Color Upgrade", 2, 1)
    HUDPhotographySetColourUpgrade(true)
    while mission_started do
        Wait(0)
    end
    L_StopMonitoringTargets()
end
