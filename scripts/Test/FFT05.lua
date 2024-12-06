--[[ Changes to this file:
	* Modified function EnemyCreate, may require testing
]]

ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false

function MissionSetup()
	DATLoad("TFIGHT01.DAT", 2)
	DATInit()
	PlayerSetHealth(200)
	AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
	EnemyCreate()
end

function EnemyCreate() -- ! Modified
	L_PedLoadPoint(nil, {
		{
			--[[
			model = 30,
			]] -- Changed to:
			model = 41,
			point = POINTLIST._TFIGHT01_NE_01
		},
		{
			--[[
			model = 31,
			]] -- Changed to:
			model = 43,
			point = POINTLIST._TFIGHT01_E_01
		},
		{
			--[[
			model = 32,
			]] -- Changed to:
			model = 44,
			point = POINTLIST._TFIGHT01_SE_01
		},
		{
			--[[
			model = 34,
			]] -- Changed to:
			model = 45,
			point = POINTLIST._TFIGHT01_W_01
		}
	})
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	L_PedExec(nil, PedAttack, "id", gPlayer)
	while mission_completed == false do
		if L_PedAllDead() then
			mission_completed = true
		end
		Wait(0)
	end
	Wait(3000)
	MissionSucceed()
end
