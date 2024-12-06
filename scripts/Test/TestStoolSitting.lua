function MissionSetup()
	LoadAnimationGroup("POI_Cafeteria")

	DATLoad("TestStoolSit.DAT", 2)
	DATInit()
	LoadPedModels({ 22 })
	AreaTransitionPoint(31, POINTLIST._SITTINGDOWN, 1)
end

function MissionCleanup()
	UnLoadAnimationGroup("POI_Cafeteria")
	DATUnload(2)
end

function main()
	local guy = PedCreatePoint(22, POINTLIST._SITTINGDOWN, 2)
	Wait(2000)
	PedSetActionNode(guy, "/Global/WProps/PropInteract", "Act/WProps.act")
	while true do
		Wait(0)
		TextPrintString("Press R2 on the player controller to reset the sequence!", 5, 2)
		if IsButtonPressed(13, 0) then
			PedSetActionNode(guy, "/Global/Ambient/MissionSpec/PlayerIdle/IdleOneFrame", "Act/Anim/Ambient.act")
			Wait(10)
			PedSetPosPoint(guy, POINTLIST._SITTINGDOWN, 2)
			PedFaceHeading(guy, 270, 0)
			Wait(10)
			PedSetActionNode(guy, "/Global/WProps/PropInteract", "Act/WProps.act")
		end
	end
	MissionFail()
end
