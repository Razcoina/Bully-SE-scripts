ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false

function MissionSetup()
	DATLoad("TProjAI.DAT", 2)
	DATInit()
	AreaTransitionPoint(0, POINTLIST._TProjAI_Player_Start)
	PlayerSetHealth(200)
	EnemyCreate()
end

function EnemyCreate()
	L_PedLoadPoint(nil, {
		{
			model = 15,
			point = POINTLIST._TProjAI_Tree01
		},
		{
			model = 15,
			point = POINTLIST._TProjAI_Tree02
		},
		{
			model = 15,
			point = POINTLIST._TProjAI_Tree03
		},
		{
			model = 15,
			point = POINTLIST._TProjAI_Tree04
		},
		{
			model = 15,
			point = POINTLIST._TProjAI_Rock01
		},
		{
			model = 15,
			point = POINTLIST._TProjAI_Rock02
		},
		{
			model = 15,
			point = POINTLIST._TProjAI_Rock03
		}
	})
	for i, ped in L_PedGroup() do
		PedSetStatsType(ped.id, "STAT_X04_RANGED")
		PedCoverSet(ped.id, gPlayer, ped.point, 1, 20, 3, 2, 3, 2, 1, 1, 1, 1, 1, false)
	end
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	PedSetTypeToTypeAttitude(4, 13, 1)
	while mission_completed == false do
		if L_PedAllDead() then
			mission_completed = true
		end
		Wait(0)
	end
	Wait(1000)
	TextPrintString("Clear Projectile AI Test", 2000)
	Wait(4000)
	MissionSucceed()
end
