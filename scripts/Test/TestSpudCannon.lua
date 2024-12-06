local mission_completed = false
local earnest

function MissionSetup()
	DATLoad("TESTSPUDCANNON.DAT", 2)
	DATInit()
	PlayerSetHealth(200)
	AreaTransitionPoint(22, POINTLIST._TESTSPUDCANNON_PLAYER)
	earnest = PedCreatePoint(10, POINTLIST._TESTSPUDCANNON_EARNEST)
	PedSetActionTree(earnest, "/Global/N_Earnest", "Act/Anim/N_Earnest.act")
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	PedSetActionNode(earnest, "/Global/Ambient/MissionSpec/GetOnCannon", "Act/Anim/Ambient.act")
	PedSetTaskNode(earnest, "/Global/AI/GeneralObjectives/SpecificObjectives/UseSpudCannon", "Act/AI/AI.act")
	Wait(0)
	PedAttack(earnest, gPlayer, 3)
	while mission_completed == false do
		Wait(0)
	end
	MissionSucceed()
end
