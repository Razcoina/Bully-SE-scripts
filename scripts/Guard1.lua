local mission_completed = false

function MissionSetup()
	local x, y, z = 3, 23, 27
	PlayerSetHealth(200)
	AreaTransitionXYZ(22, x, y, z)
	EnemyCreate()
end

function EnemyCreate()
	local model = 17
	local x, y, z = -16, 23, 27
	local ped1 = PedCreateXYZ(model, x, y, z)
	PedSetTetherToXYZ(ped1, x, y, z, 5)
	local model = 15
	local x, y, z = -16, 20, 27
	local ped2 = PedCreateXYZ(model, x, y, z)
	PedGuardPed(ped2, ped1)
	PedAttack(ped2, gPlayer, true, false)
end

function MissionCleanup()
end

function main()
	while mission_completed == false do
		Wait(0)
	end
	Wait(1000)
	TextPrintString("Clear Fight Test", 2000)
	Wait(4000)
	MissionSucceed()
end
