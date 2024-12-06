local norton
local dont_end = true

function main()
	norton = PedCreatePoint(99, POINTLIST._PP_PEDSTART)
	nemesis = PedCreatePoint(130, POINTLIST._PP_NEM)
	TextPrintString("Try to run away from the bully after he dies so you don't accidentally pick up the key yourself.", 3, 1)
	Wait(3000)
	PedAttack(norton, gPlayer)
	CreateThread("T_WaitForPedKO")
	while dont_end do
		Wait(0)
	end
end

function MissionSetup()
	DATLoad("TestPedPickup.DAT", 2)
	DATInit()
	AreaTransitionPoint(22, POINTLIST._PP_PSTART)
end

function MissionCleanup()
	DATUnload(2)
end

function T_WaitForPedKO()
	while not PedIsDead(norton) do
		Wait(0)
	end
	key_ped_x, key_ped_y, key_ped_z = PedGetPosXYZ(norton)
	F_GetKeyCutscene()
end

function F_GetKeyCutscene()
	TextPrintString("Nemesis should pick up key now.", 4, 1)
	key_id = PickupCreateXYZ(494, key_ped_x, key_ped_y, key_ped_z, "PermanentMission")
	PedPickup(nemesis, key_id)
	keypickup_start = GetTimer()
	while not PickupIsPickedUp(key_id) do
		Wait(33)
	end
	TextPrintString("Key was picked up!", 4, 1)
	dont_end = false
end
