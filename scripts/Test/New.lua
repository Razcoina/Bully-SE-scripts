local enemy01 = {}
local enemy02 = {}
local gardenX, gardenY, gardenZ = 0, 0, 0
local bat, gardenBlip
local mission_running = true
local bPlayerHasEntered = false
local bPlayerAttacked = false

function F_TableInit()
	enemy01 = {
		model = 45,
		point = POINTLIST._NEW_ENEMY01,
		id = 0
	}
	enemy02 = {
		model = 46,
		point = POINTLIST._NEW_ENEMY02,
		id = 0,
		path = PATH._NEW_ENEMY02
	}
end

function F_CreateEnemies()
	PedRequestModel(enemy01.model)
	PedRequestModel(enemy02.model)
	enemy01.id = PedCreatePoint(enemy01.model, enemy01.point)
	enemy02.id = PedCreatePoint(enemy02.model, enemy02.point)
	AddBlipForChar(enemy01.id, 3, 2, 1)
	AddBlipForChar(enemy02.id, 3, 2, 4)
	PedSetActionNode(enemy01.id, "/Global/New/Animations/PlayAnimationCyclic", "Act/Conv/New.act")
	PedFollowPath(enemy02.id, enemy02.path, 1, 1, cbRunningMan)
end

function F_CheckGate()
	if not bPlayerHasEntered and PlayerIsInTrigger(TRIGGER._NEW_GATE) then
		F_EnemiesAttackPlayer()
		bPlayerHasEntered = true
	end
end

function F_EnemiesAttackPlayer()
	PedAttack(enemy01.id, gPlayer, 3)
	PedSetActionNode(enemy01.id, "/Global/New/Animations/BreakCyclicAnimation", "Act/Conv/New.act")
	PedStop(enemy02.id)
	PedClearObjectives(enemy02.id)
	PedAttack(enemy02.id, gPlayer, 3)
	bPlayerAttacked = true
	TextPrintString("Get to the Centre of the Garden", 4, 1)
	TextPrintString("Dude: Leave our Garden or Die!", 4, 2)
end

function F_TellPlayerToGetToCenterOfGarden()
	if bPlayerAttacked then
		gardenX, gardenY, gardenZ = GetPointList(POINTLIST._NEW_GARDENCENTRE)
		if PlayerIsInAreaXYZ(gardenX, gardenY, gardenZ, 1.5, 7) then
			TextPrintString("KO all the Drop Outs to win", 4, 1)
			bPlayerAttacked = false
			BlipRemove(gardenBlip)
		end
	end
end

function F_CheckEnemiesDead()
	if PedIsDead(enemy01.id) and PedIsDead(enemy02.id) then
		bMissionComplete = true
		return true
	end
	return false
end

function cbRunningMan(ped, path, node)
	if node == 3 then
		TextPrintString("Dude: Running sucks!", 4, 2)
	end
end

function MissionSetup()
	DATLoad("NEW.DAT", 2)
	DATInit()
	AreaTransitionPoint(0, POINTLIST._NEW_PLAYERSTART)
	F_TableInit()
end

function MissionCleanup()
end

function main()
	F_CreateEnemies()
	TextPrintString("Go into the Garden", 4, 1)
	gardenBlip = BlipAddPoint(POINTLIST._NEW_GARDENCENTRE, 0)
	bat = PickupCreatePoint(300, POINTLIST._NEW_BAT, 1, 0, "PermanentMission")
	while mission_running do
		F_CheckGate()
		F_TellPlayerToGetToCenterOfGarden()
		if F_CheckEnemiesDead() then
			break
		end
		Wait(0)
	end
	if bMissionComplete then
		TextPrint("M_PASS", 3, 0)
		Wait(3000)
		MissionSucceed()
	else
		TextPrint("M_FAIL", 3, 0)
		Wait(3000)
		MissionFail()
	end
end
