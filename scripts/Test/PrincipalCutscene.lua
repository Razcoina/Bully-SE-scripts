function MissionSetup()
end

function main()
	DATLoad("PrincipalCutscene.DAT", 2)
	--print("DAT TYPE IS MISSION DAT TYPE")
	DATInit()
	CameraFade(500, 0)
	Wait(500)
	AreaTransitionPoint(5, POINTLIST.SPAWN, 1)
	local principal = PedCreatePoint(65, POINTLIST.SPAWN, 2)
	CameraFade(500, 1)
	Wait(500)
	PedLockTarget(gPlayer, principal)
	PedLockTarget(principal, gPlayer)
	ConversationMovePeds(false)
	PedStartConversation("/Global/PriOff/PrincipalDialogue", "Act/Conv/PriOff.act", gPlayer, principal)
	while PedInConversation(principal) do
		Wait(0)
	end
	--print("=================== Teleporting them to the outside...")
	CameraFade(500, 0)
	Wait(500)
	ConversationMovePeds(true)
	CameraSetWidescreen(false)
	CameraReset()
	CameraReturnToPlayer()
	AreaTransitionPoint(0, POINTLIST.OUTSIDE, 1)
	PedDelete(principal)
	CameraFade(900, 1)
	Wait(900)
	MissionSucceed()
end

function F_SetCamera()
	x, y, z = GetPointFromPointList(POINTLIST.LOOKATPT, 1)
	CameraLookAtXYZ(x, y, z, true)
	CameraSetPath(PATH.PRINCIPALCAMERA, true)
end

function MissionCleanup()
	DATUnload(2)
end
