ImportScript("\\Library\\LibTable.lua")
ImportScript("\\Library\\LibPed.lua")
local mission_completed = false
local dog_model = 136

function MissionSetup()
	DATLoad("TFIGHT01.DAT", 2)
	DATInit()
	PlayerSetHealth(200)
	AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
	EnemyCreate()
	DumpGarbage()
end

function EnemyCreate()
	L_PedLoadPoint(nil, {
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_E_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_N_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_NE_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_NW_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_S_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_SE_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_SW_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_W_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_NWN_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_NEN_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_NEE_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_SEE_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_SES_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_SWS_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_SWW_01
		},
		{
			model = dog_model,
			point = POINTLIST._TFIGHT01_NWW_01
		}
	})
end

function DumpGarbage()
	for i = 1, 8 do
		local x = -8 + math.random(-10, 10)
		local y = 23 + math.random(-10, 10)
		local z = 26.1
		PickupCreateXYZ(343, x, y, z)
	end
	for i = 1, 8 do
		local x = -8 + math.random(-10, 10)
		local y = 23 + math.random(-10, 10)
		local z = 26.1
		PickupCreateXYZ(310, x, y, z)
	end
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	L_PedExec(nil, PedSetAITree, "id", "/Global/AI_Rat", "Act/AI/AI_Rat.act")
	L_PedExec(nil, PedWander, "id", 0)
	while mission_completed == false do
		if L_PedAllDead() then
			mission_completed = true
		end
		Wait(0)
	end
	Wait(3000)
	MissionSucceed()
end
