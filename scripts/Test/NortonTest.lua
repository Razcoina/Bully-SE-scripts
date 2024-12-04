local norton

local function F_DebugNorton()
	local loop = true
	while loop do
		if IsButtonPressed(13, 1) then
			AreaTransitionPoint(36, POINTLIST._TFIGHT01_NORTONTEN)
			PedSetPosPoint(norton, POINTLIST._TFIGHT01_NORTONTEN, 2)
			loop = false
		end
		Wait(0)
	end
	collectgarbage()
end

function main()
	CreateThread("F_DebugNorton")
	AreaTransitionPoint(22, POINTLIST._TFIGHT01_C)
	norton = PedCreatePoint(29, POINTLIST._TFIGHT01_NE_01)
	PedSetStatsType(norton, "STAT_3_05_NORTON")
	PedAttack(norton, gPlayer, true, false)
	while true do
		Wait(0)
	end
end

function MissionSetup()
	DATLoad("TFIGHT01.DAT", 2)
	DATInit()
	LoadAnimationGroup("Area_Tenements")
end

function MissionCleanup()
	UnLoadAnimationGroup("Area_Tenements")
	DATUnload(2)
end
