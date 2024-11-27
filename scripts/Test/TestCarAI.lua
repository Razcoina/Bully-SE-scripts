StartPos = {}
AIStartPos = {}
AIEndPos = {}
StartPos[0] = {
	320,
	92,
	7
}
AIStartPos[0] = {
	321,
	87,
	5
}
AIEndPos[0] = {
	434,
	230,
	10
}
StartPos[1] = {
	278,
	300,
	5
}
AIStartPos[1] = {
	281,
	300,
	5
}
AIEndPos[1] = {
	400,
	84,
	6
}
StartPos[2] = {
	549,
	402,
	40
}
AIStartPos[2] = {
	549,
	405,
	40
}
AIEndPos[2] = {
	443,
	480,
	26
}
StartPos[3] = {
	278,
	300,
	5
}
AIStartPos[3] = {
	281,
	300,
	5
}
AIEndPos[3] = {
	515,
	-86,
	8
}
StartPos[4] = {
	355,
	109,
	8
}
AIStartPos[4] = {
	384,
	130,
	8
}
AIEndPos[4] = {
	330,
	127,
	8
}
StartPos[4] = {
	391,
	536,
	27
}
AIStartPos[4] = {
	391,
	540,
	27
}
AIEndPos[4] = {
	-24,
	-76,
	4
}
Path = 4

function MissionSetup()
	local x, y, z = 325, 160, 5
	PlayerSetHealth(200)
	AreaTransitionXYZ(0, x, y, z)
	carID = {}
	TestCreateVehicleSimple()
end

function MissionCleanup()
end

function main()
	Wait(4000)
	VehicleMoveToXYZ(carID[0], 345, 297, 7)
	while mission_completed == false do
		Wait(0)
	end
end

function TestMoveToXYZ()
	ped = PedCreateXYZ(24, 0, 0, 0)
	carID[0] = VehicleCreateXYZ(273, AIStartPos[Path][1], AIStartPos[Path][2], AIStartPos[Path][3])
	PedPutOnBike(ped, carID[0])
	VehicleMoveToXYZ(carID[0], AIEndPos[Path][1], AIEndPos[Path][2], AIEndPos[Path][3], 0.6)
	VehicleSetCruiseSpeed(carID[0], 5)
end

function TestCreateVehicleSimple()
	carID[0] = VehicleCreateXYZ(295, 320, 160, 5)
end

function TestMoveToPoint()
	carID[0] = VehicleCreateXYZ(MODELENUM._Taxicab, 320, 160, 5)
	VehicleMoveToXYZ(carID[0], 345, 297, 7)
	VehicleSetCruiseSpeed(carID[0], 5)
end

function TestMoveToObject()
	carID[0] = VehicleCreateXYZ(MODELENUM._Taxicab, 320, 160, 5)
	carID[1] = VehicleCreateXYZ(MODELENUM._Taxicab, 306, 222, 5)
	TestMoveToXYZ()
	VehicleFollowEntity(carID[1], carID[0], 1, 5)
	VehicleSetDrivingMode(carID[1], 0)
end

function TestStopSigns()
	carID[0] = VehicleCreateXYZ(MODELENUM._Taxicab, 320, 158, 5)
	VehicleMoveToXYZ(carID[0], 365, 140, 5)
	VehicleSetDrivingMode(carID[0], 0)
	VehicleSetCruiseSpeed(carID[0], 5)
	carID[3] = VehicleCreateXYZ(MODELENUM._Taxicab, 312, 167, 5)
	VehicleMoveToXYZ(carID[3], 365, 140, 5)
	VehicleSetDrivingMode(carID[3], 0)
	VehicleSetCruiseSpeed(carID[3], 5)
	carID[1] = VehicleCreateXYZ(MODELENUM._Taxicab, 342, 115, 5)
	VehicleMoveToXYZ(carID[1], 328, 165, 5)
	VehicleSetDrivingMode(carID[1], 0)
	VehicleSetCruiseSpeed(carID[1], 5)
	carID[2] = VehicleCreateXYZ(MODELENUM._Taxicab, 342, 105, 5)
	VehicleMoveToXYZ(carID[2], 328, 165, 5)
	VehicleSetDrivingMode(carID[2], 0)
	VehicleSetCruiseSpeed(carID[2], 5)
end
