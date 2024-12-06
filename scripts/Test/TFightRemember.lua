function MissionSetup()
	DATLoad("TestRemember.DAT", 2)

	LoadPedModels({
		85,
		5,
		15
	})
end

function MissionCleanup()
end

function main()
	F_AttackProps()
	while true do
		Wait(0)
	end
	MissionSucceed()
end

function F_AttackPeds()
	AreaTransitionPoint(22, POINTLIST._REMEMBERSETUP, 4)
	local ped1, ped2, ped3
	ped1 = PedCreatePoint(85, POINTLIST._REMEMBERSETUP, 3)
	ped2 = PedCreatePoint(5, POINTLIST._REMEMBERSETUP, 2)
	ped3 = PedCreatePoint(139, POINTLIST._REMEMBERSETUP, 1)
	PedSetHealth(ped1, 50000)
	PedSetHealth(ped2, 1)
	PedAttack(ped1, ped2, 1)
	PedAttack(ped1, ped3, 1)
end

function F_AttackProps()
	AreaTransitionPoint(22, POINTLIST._REMEMBERSETUP, 5)
	local ped1
	ped1 = PedCreatePoint(85, POINTLIST._REMEMBERSETUP, 6)
	ped2 = PedCreatePoint(5, POINTLIST._REMEMBERSETUP, 2)
	PedSetHealth(ped1, 200)
	PedSetHealth(ped2, 20)
	PedAttackProp(ped1, TRIGGER._SMALLCRATE10)
	PedAttackProp(ped1, TRIGGER._SMALLCRATE3)
	PedAttackProp(ped1, TRIGGER._SMALLCRATE5)
	Wait(1000)
	PedAttack(ped2, ped1, 1)
end
