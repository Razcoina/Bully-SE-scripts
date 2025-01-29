local proj1 = -1
local proj2 = -1
local proj3 = -1
local proj4 = -1
local ped1 = -1

function MissionSetup()
    local x, y, z = PedGetPosXYZ(gPlayer)
    proj1 = CreateProjectile(329, x + 2, y, z + 0.5, 0, 0, 0)
    proj2 = CreateProjectile(318, x + 3, y, z + 0.5, 0, 0, 0)
    proj3 = CreateProjectile(331, x + 4, y, z + 0.5, 0, 0, 0)
    proj4 = CreateProjectile(335, x + 5, y, z + 0.5, 0, 0, 0)
    ped1 = PedCreateXYZ(15, x - 5, y + 5, z + 0.5)
    CameraSetRotationLimit(10, 30, 1, 0, 0)
end

function MissionCleanup()
    DestroyProjectile(proj1)
    DestroyProjectile(proj2)
    DestroyProjectile(proj3)
    DestroyProjectile(proj4)
    PedDelete(ped1)
    CameraClearRotationLimit()
end

function main()
    while 1 do
        Wait(100)
    end
    Wait(10000000)
end
