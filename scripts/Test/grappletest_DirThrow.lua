ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false
g_PosX, g_PosY, g_PosZ = -14, 22, 27
pedTable = {
	{
		x = g_PosX,
		y = g_PosY,
		z = g_PosZ,
		model = 32
	},
	{
		x = g_PosX,
		y = g_PosY,
		z = g_PosZ,
		model = 32
	},
	{
		x = g_PosX,
		y = g_PosY,
		z = g_PosZ,
		model = 32
	},
	{
		x = g_PosX,
		y = g_PosY,
		z = g_PosZ,
		model = 32
	},
	{
		x = g_PosX,
		y = g_PosY,
		z = g_PosZ,
		model = 32
	}
}

function MissionSetup()
	PlayerSetHealth(200)
	AreaTransitionXYZ(22, g_PosX, g_PosY, g_PosZ)
	grappleMissions = {
		{
			name = "C_Wrestling_1"
		},
		{
			name = "C_Wrestling_2"
		},
		{
			name = "C_Wrestling_3"
		}
	}
	for i, mission in grappleMissions do
		MissionSuccessCountInc(mission.name)
	end
	EnemyCreate()
end

function EnemyCreate()
	pedOffsetTable = {
		{ x = 1,  y = 0 },
		{ x = 0,  y = 1 },
		{ x = -1, y = 0 },
		{ x = 0,  y = -1 },
		{ x = 1,  y = 0 }
	}
	local xPos = 0
	local Offset = 1.5
	L_PedLoadXYZ(nil, pedTable)
	pedTable[1].x = pedTable[1].x + 1
	PedSetPosXYZ(pedTable[1].id, pedTable[1].x, pedTable[1].y, pedTable[1].z)
	PedFaceObjectNow(gPlayer, pedTable[1].id, 2)
	PedFaceObjectNow(pedTable[1].id, gPlayer, 2)
	for i, ped in pedTable do
		if i ~= 1 then
			ped.x = ped.x + Offset * pedOffsetTable[i - 1].x
			ped.y = ped.y + Offset * pedOffsetTable[i - 1].y
			PedSetPosXYZ(ped.id, ped.x, ped.y, ped.z)
			PedFaceObjectNow(ped.id, gPlayer, 2)
		end
	end
end

function MissionCleanup()
end

function MaintainPosition()
	for i, ped in pedTable do
		PedMoveToXYZ(ped.id, 1, ped.x, ped.y)
	end
end

function main()
	L_PedExec(nil, PedSetPedToTypeAttitude, "id", gPlayer, 4)
	L_PedExec(nil, PedAddPedToIgnoreList, "id", gPlayer)
	L_PedExec(nil, PedOverrideStat, "id", 5, 100)
	L_PedExec(nil, PedOverrideStat, "id", 38, 0)
	L_PedExec(nil, PedOverrideStat, "id", 39, 0)
	while mission_completed == false do
		MaintainPosition()
		if L_PedAllDead() then
			mission_completed = true
		end
		Wait(0)
	end
	MissionSucceed()
end
