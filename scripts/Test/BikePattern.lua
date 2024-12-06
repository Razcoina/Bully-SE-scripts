ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false
local bike

function MissionSetup()
	DATLoad("TFIGHT01.DAT", 2)
	DATInit()
	PlayerSetHealth(200)
	AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
	EnemyCreate()
end

function EnemyCreate()
	L_PedLoadPoint(nil, {
		{
			model = 23,
			point = POINTLIST._TFIGHT01_NE_01
		}
	})
	local x, y, z = PedGetPosXYZ(L_PedGetIDByIndex(nil, 1))
	bike = VehicleCreateXYZ(273, x + 5, y, z)
	PedEnterVehicle(L_PedGetIDByIndex(nil, 1), bike)
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	PedLockTarget(L_PedGetIDByIndex(nil, 1), gPlayer, false)
	while mission_completed == false do
		if L_PedAllDead() then
			mission_completed = true
		end
		Wait(0)
	end
	Wait(1000)
	TextPrintString("Clear Fight Test", 2000)
	Wait(4000)
	MissionSucceed()
end
