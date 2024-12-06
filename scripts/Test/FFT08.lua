ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false

function MissionSetup()
	DATLoad("TFIGHT01.DAT", 2)
	DATInit()
	PlayerSetHealth(200)
	AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
	PedSetTypeToTypeAttitude(4, 13, 4)
	PedSetTypeToTypeAttitude(11, 13, 0)
	PedSetTypeToTypeAttitude(11, 4, 0)
	EnemyCreate()
	AllyCreate()
end

function EnemyCreate()
	L_PedLoadPoint(nil, {
		{
			model = 102,
			point = POINTLIST._TFIGHT01_NE_01
		},
		{
			model = 99,
			point = POINTLIST._TFIGHT01_E_01
		},
		{
			model = 85,
			point = POINTLIST._TFIGHT01_SE_01
		},
		{
			model = 145,
			point = POINTLIST._TFIGHT01_W_01
		}
	})
end

function AllyCreate()
	local model = 24
	local x, y, z = PedGetPosXYZ(gPlayer)
	local ally = PedCreateXYZ(model, x + 1, y + 1, z)
	--print("RECRUIT!")
	PedRecruitAlly(gPlayer, ally)
	--print("RECRUIT 2!")
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	PedSetGlobalAttitude_Rumble(true, true)
	while mission_completed == false do
		if L_PedAllDead() then
			mission_completed = true
		end
		Wait(0)
	end
	Wait(3000)
	MissionSucceed()
end
