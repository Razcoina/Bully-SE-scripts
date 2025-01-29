local ped1 = -1
local ped2 = -1
local ped3 = -1
local ped4 = -1

function MissionSetup()
    DATLoad("tphoto.DAT", 2)
    DATInit()
end

function MissionCleanup()
    PedDelete(ped1)
    PedDelete(ped2)
    PedDelete(ped3)
    PedDelete(ped4)
    DATUnload(2)
end

function main()
    AreaTransitionPoint(22, POINTLIST._TPHOTO_PSTART)
    local x, y, z = GetPointList(POINTLIST._TPHOTO_PSTART)
    ped1 = PedCreateXYZ(30, x + 10, y - 2, z)
    ped2 = PedCreateXYZ(30, x + 3, y, z)
    ped3 = PedCreateXYZ(30, x + 2, y + 2, z)
    ped4 = PedCreateXYZ(30, x, y + 3, z)
    Wait(5000000)
    MissionSucceed()
end
