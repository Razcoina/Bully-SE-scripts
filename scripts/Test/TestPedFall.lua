ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPed.lua")

function F_TableInit()
	tblOwner = {
		model = 84,
		point = POINTLIST._2_02_OWNER,
		asleep = true,
		blipStyle = 4,
		radarIcon = 0
	}
end

function MissionSetup()
	DATLoad("2_02.DAT", 2)
	DATInit()
	F_TableInit()
	L_PedCreate(tblOwner)
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	AreaTransitionPoint(0, POINTLIST._2_02_PLAYER)
	while true do
		Wait(0)
	end
end
