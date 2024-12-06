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

function EnemyCreate()
	L_PedLoadPoint(nil, {
		{
			model = 24,
			point = POINTLIST._TFIGHT01_E_01
		},
		{
			model = 22,
			point = POINTLIST._TFIGHT01_N_01
		},
		{
			model = 26,
			point = POINTLIST._TFIGHT01_NE_01
		},
		{
			model = 28,
			point = POINTLIST._TFIGHT01_NW_01
		},
		{
			model = 24,
			point = POINTLIST._TFIGHT01_S_01
		},
		{
			model = 22,
			point = POINTLIST._TFIGHT01_SE_01
		},
		{
			model = 26,
			point = POINTLIST._TFIGHT01_SW_01
		},
		{
			model = 28,
			point = POINTLIST._TFIGHT01_W_01
		},
		{
			model = 24,
			point = POINTLIST._TFIGHT01_NWN_01
		},
		{
			model = 22,
			point = POINTLIST._TFIGHT01_NEN_01
		},
		{
			model = 26,
			point = POINTLIST._TFIGHT01_NEE_01
		},
		{
			model = 28,
			point = POINTLIST._TFIGHT01_SEE_01
		},
		{
			model = 24,
			point = POINTLIST._TFIGHT01_SES_01
		},
		{
			model = 22,
			point = POINTLIST._TFIGHT01_SWS_01
		},
		{
			model = 26,
			point = POINTLIST._TFIGHT01_SWW_01
		},
		{
			model = 28,
			point = POINTLIST._TFIGHT01_NWW_01
		}
	})
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	L_PedExec(nil, PedAttack, "id", gPlayer, true, false)
	while mission_completed == false do
		if L_PedAllDead() then
			mission_completed = true
		end
		Wait(0)
	end
	Wait(3000)
	MissionSucceed()
end
