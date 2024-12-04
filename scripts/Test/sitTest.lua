ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false
TonyTestOn = false
g_PosX, g_PosY, g_PosZ = -41, -43.6, 27
g_PosCX, g_PosCY, g_PosCZ = -41, -45.6, 27
pedTable = {
	{
		x = g_PosX,
		y = g_PosY,
		z = g_PosZ,
		model = 68,
		gravity = true
	},
	{
		x = g_PosX,
		y = g_PosY,
		z = g_PosZ,
		model = 38,
		gravity = true
	}
}
chairTable = {
	{
		x = g_PosCX,
		y = g_PosCY,
		z = g_PosCZ,
		r = 0
	},
	{
		x = g_PosCX,
		y = g_PosCY,
		z = g_PosCZ,
		r = 0
	}
}

function initPositionTables()
	local Offset = 1
	for i, ped in pedTable do
		ped.x = ped.x + Offset * (i - 1)
	end
	for i, chair in chairTable do
		chair.x = chair.x + Offset * (i - 1)
	end
end

function EnemyCreate()
	L_PedLoadXYZ(nil, pedTable)
end

function MissionSetup()
	PlayerSetHealth(200)
	local Offset = 2
	AreaTransitionXYZ(22, g_PosX, g_PosY + Offset, g_PosZ)
	if TonyTestOn == false then
		initPositionTables()
		EnemyCreate()
	end
end

function MissionCleanup()
end

function TargetChairPositionChange(pedID)
	for i, ped in pedTable do
		if ped.id == pedID then
			PedSetWorldAnchor(pedID, chairTable[i].x, chairTable[i].y, chairTable[i].z, chairTable[i].r)
		end
	end
end

function TargetStartPositionChange(pedID)
	for i, ped in pedTable do
		if ped.id == pedID then
			PedSetWorldAnchor(pedID, ped.x, ped.y, ped.z, 0)
		end
	end
end

function main()
	if TonyTestOn == false then
		L_PedExec(nil, PedSetPedToTypeAttitude, "id", gPlayer, 2)
		L_PedExec(nil, PedAddPedToIgnoreList, "id", gPlayer)
		L_PedExec(nil, PedSetAITree, "id", "/Global/AI_SitTest", "Act/AI/AI_SitTest.act")
	else
		F_TonyTest()
	end
	while mission_completed == false do
		if TonyTestOn == false and L_PedAllDead() then
			mission_completed = true
		end
		Wait(0)
	end
	MissionSucceed()
end

function F_TonyTest()
	local Lefty = PedCreatePoint(24, POINTLIST._LOWSITTEST1)
	PedSetPOI(Lefty, POI._POILOWSIT)
	local Student = PedCreatePoint(72, POINTLIST._HIGHSITTEST1)
	PedSetPOI(Student, POI._POIHIGHSIT)
end
