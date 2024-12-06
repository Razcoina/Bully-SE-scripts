local x, y, z
local BullyAttack = false

function main()
	F_CreatePeds()
	while true do
		Wait(0)
		if BullyAttack == false and PedIsInAreaObject(gPlayer, Student2, 2, 4, 0) then
			BullyAttack = true
			PedClearPOI(Student1)
			PedAttack(Student1, gPlayer, 1, true, true)
			PedClearPOI(Student2)
			PedAttack(Student2, gPlayer, 1, true, true)
		end
	end
end

function F_CreatePeds()
	Student1 = PedCreatePoint(102, POINTLIST._PUNISHTEST_P1)
	Student2 = PedCreatePoint(99, POINTLIST._PUNISHTEST_P2)
	PedSetPOI(Student1, POI._BULLYHO1)
	PedSetPOI(Student2, POI._BULLYHO1)
end

function MissionCleanup()
	DATUnload(2)
end

function MissionSetup()
	local x, y, z = -9.988, 21.42, 30.06
	DATLoad("HangTest.DAT", 2)
	DATInit()
	POISetDisablePedProduction(POI._BULLYHO1, true)
	AreaTransitionXYZ(22, x, y, z)
	PlayerFaceHeading(270, 1)
end
