local proj1 = -1
local ped1 = -1
local ped2 = -1

function MissionSetup()
    local x, y, z = PedGetPosXYZ(gPlayer)
    ped1 = PedCreateXYZ(15, x - 5, y + 7, z + 0.5)
    ped2 = PedCreateXYZ(15, x + 5, y + 7, z + 0.5)
    PedOverrideStat(ped1, 10, 100)
    PedOverrideStat(ped2, 10, 100)
    PedSetRemoveOwnedProj(ped1, true)
    PedSetRemoveOwnedProj(ped2, true)
    PedSetWeapon(ped1, 331, 1)
    Wait(2000)
    PedPlayCatch(ped1, ped2, 100000)
    PedPlayCatch(ped2, ped1, 100000)
end

function MissionCleanup()
    PedDelete(ped1)
    PedDelete(ped2)
end

function main()
    while 1 do
        Wait(100)
    end
    Wait(10000000)
end
