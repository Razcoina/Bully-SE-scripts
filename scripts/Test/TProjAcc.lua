local mission_completed = false

function MissionSetup()
    DATLoad("TFIGHT01.DAT", 2)
    DATInit()
    local x, y, z = GetPointList(POINTLIST._TFIGHT01_C)
    PlayerSetHealth(200)
    PlayerSetPosPoint(POINTLIST._TFIGHT01_C)
    TestPed = PedCreateXYZ(28, x, y + 3, z)
    PedOverrideStat(TestPed, 10, 100)
    PedSetWeapon(TestPed, 312, 10000)
    PedSetCombatZoneMask(TestPed, false, false, true)
end

function MissionCleanup()
    DATUnload(2)
end

function main()
    PedAttack(TestPed, gPlayer)
    while true do
        if PedGetAmmoCount(TestPed, 312) < 2 then
            PedSetWeapon(TestPed, 312, 100)
        end
        Wait(4000)
    end
end
