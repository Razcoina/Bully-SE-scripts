local mandy
local mission_completed = false

function MissionSetup()
	DATLoad("PedUseLocker.DAT", 2)
	AreaTransitionPoint(31, POINTLIST._PLAYERTEST, 1)
end

function EnemyCreate()
	if mandy and PedIsValid(mandy) then
		PedDelete(mandy)
	end
	mandy = PedCreatePoint(14, POINTLIST._MANDYPOINT, 1)
	Wait(1000)
	TextPrintString("MANDY IS GOING TO USE THE PROP!", 1, 1)
	Wait(1000)
	PedSetActionNode(mandy, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
end

function MissionCleanup()
	DATUnload(2)
end

function main()
	Wait(3000)
	EnemyCreate()
	while mission_completed == false do
		TextPrintString("Press ~t~ + ~R1~ to restart!", 4, 2)
		if IsButtonPressed(9, 0) and IsButtonPressed(12, 0) then
			EnemyCreate()
		end
		Wait(0)
	end
	Wait(1000)
	MissionSucceed()
end
