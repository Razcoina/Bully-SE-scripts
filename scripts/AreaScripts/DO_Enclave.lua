local tblProps = {}
local tblBarricadeDoors = {}
local gRoundhouseOpen = false

function F_BarricadeDoorOpen(tblProp)
	if tblProp == nil then
		--DebugPrint("************************************************************** tblProp is NIL in barricade door open")
	end
	F_SetDoor(tblProp, true)
end

function F_BarricadeDoorClose(tblProp)
	F_SetDoor(tblProp, false)
end

function F_SetDoor(tblProp)
	local i, tblEntry, x, y, z
	if tblProp == nil then
		--DebugPrint("************************************************************** tblProp is NIL")
	end
	for i, tblEntry in tblBarricadeDoors do
		if tblEntry.idSwitch == tblProp.id then
			if tblEntry.idCamPath2 ~= nil then
				x, y, z = GetAnchorPosition(tblEntry.idDoor)
				x2, y2, z2 = PedGetPosXYZ(gPlayer)
				distance = DistanceBetweenCoords3d(x, y, z, x2, y2, z2)
				--print("************************ DISTANCE:", distance)
				if distance < 15 then
					PlayerSetControl(0)
					CameraSetWidescreen(true)
					Wait(800)
					CameraSetPath(tblEntry.idCamPath2, true)
					CameraLookAtXYZ(x, y, z, true)
				end
				Wait(500)
				--DebugPrint("******************** bIsOpen = " .. tostring(tblProp.bIsOpen))
				if tblProp.bIsOpen then
					AreaSetDoorLocked(tblEntry.idDoor, true)
					PAnimCloseDoor(tblEntry.idDoor)
					tblProp.bIsOpen = false
				else
					AreaSetDoorLocked(tblEntry.idDoor, false)
					PAnimOpenDoor(tblEntry.idDoor)
					if tblEntry.idDoor2 then
						AreaSetDoorLocked(tblEntry.idDoor2, false)
						PAnimOpenDoor(tblEntry.idDoor2)
					end
					tblProp.bIsOpen = true
				end
				if distance < 15 then
					Wait(1500)
					CameraSetPath(tblEntry.idCamPath, true)
					if tblEntry.idLookAtPoint ~= nil then
						x, y, z = GetPointList(tblEntry.idLookAtPoint)
					end
					CameraLookAtXYZ(x, y, z, true)
					Wait(1500)
					CameraSetWidescreen(false)
					CameraReturnToPlayer()
					PlayerSetControl(1)
				end
				break
			end
			if tblEntry.idLookAtPoint ~= nil then
				x, y, z = GetPointList(tblEntry.idLookAtPoint)
			else
				x, y, z = GetAnchorPosition(tblEntry.idDoor)
			end
			x2, y2, z2 = PedGetPosXYZ(gPlayer)
			distance = DistanceBetweenCoords3d(x, y, z, x2, y2, z2)
			--print("************************ DISTANCE:", distance)
			if distance < 15 then
				PlayerSetControl(0)
				CameraSetWidescreen(true)
				Wait(800)
				CameraSetPath(tblEntry.idCamPath, true)
				CameraLookAtXYZ(x, y, z, true)
				Wait(500)
			end
			--DebugPrint("******************** bIsOpen = " .. tostring(tblProp.bIsOpen))
			if tblProp.bIsOpen then
				AreaSetDoorLocked(tblEntry.idDoor, true)
				PAnimCloseDoor(tblEntry.idDoor)
				tblProp.bIsOpen = false
			else
				AreaSetDoorLocked(tblEntry.idDoor, false)
				PAnimOpenDoor(tblEntry.idDoor)
				if tblEntry.idDoor2 then
					AreaSetDoorLocked(tblEntry.idDoor2, false)
					PAnimOpenDoor(tblEntry.idDoor2)
				end
				tblProp.bIsOpen = true
			end
			if distance < 15 then
				Wait(1500)
				CameraSetWidescreen(false)
				CameraReturnToPlayer()
				PlayerSetControl(1)
			end
			break
		end
	end
end

function F_RoundhouseMove()
	local x, y, z = -2.36, -398.84, 2.363
	x2, y2, z2 = PedGetPosXYZ(gPlayer)
	distance = DistanceBetweenCoords3d(x, y, z, x2, y2, z2)
	if distance < 15 then
		PlayerSetControl(0)
		CameraSetWidescreen(true)
		Wait(800)
		CameraSetPath(PATH._TINDUST_ROUNDHOUSE_CAM, true)
		CameraLookAtXYZ(x, y, z, true)
		Wait(500)
	end
	if gRoundhouseOpen then
		--print("---------[RAUL] CLOSING THE TRAIN ")
		gRoundhouseOpen = false
		PAnimRotate("RoundHStrain", -2.35955, -398.84, 2.36308, 64, -20)
		PAnimClearWhenDoneRotation("RoundHStrain", -2.35955, -398.84, 2.36308)
	else
		--print("---------[RAUL] OPENING THE TRAIN ")
		gRoundhouseOpen = true
		PAnimRotate("RoundHStrain", -2.35955, -398.84, 2.36308, 64, 20)
		PAnimClearWhenDoneRotation("RoundHStrain", -2.35955, -398.84, 2.36308)
	end
	if distance < 15 then
		Wait(5000)
		CameraSetWidescreen(false)
		CameraReturnToPlayer()
		PlayerSetControl(1)
	end
end

function F_PropMonitor()
	for i, prop in tblProps do
		if prop.bIsSwitch then
			local bPlaying = PAnimIsPlaying(prop.id, prop.actNode, prop.bRecursive)
			if bPlaying and prop.bSwitchActive == false then
				--DebugPrint("****************************** Prop is now playing node, and wasn't before.")
				prop.bSwitchActive = true
				if prop.OnActivate ~= nil then
					--DebugPrint("****************************** calling OnActivate")
					prop.OnActivate(prop)
				end
			elseif not bPlaying and prop.bSwitchActive == true then
				--DebugPrint("****************************** Prop is no longer playing the node")
				prop.bSwitchActive = false
				if prop.OnDeactivate ~= nil then
					--DebugPrint("****************************** calling OnDeactivate")
					prop.OnDeactivate(prop)
				end
			end
		end
		Wait(0)
	end
end

function F_SetupProps()
	tblProps = {
		{
			id = TRIGGER._TINDUST_BAR_DOOR_SWITCH_01,
			OnActivate = F_BarricadeDoorOpen,
			OnDeactivate = F_BarricadeDoorClose,
			bIsSwitch = true,
			bIsDoor = false,
			bIsOpen = false,
			bSwitchActive = false,
			actNode = "/Global/BRSwitch/Active",
			bRecursive = false
		},
		{
			id = TRIGGER._TINDUST_BAR_DOOR_SWITCH_02,
			OnActivate = F_BarricadeDoorOpen,
			OnDeactivate = F_BarricadeDoorClose,
			bIsSwitch = true,
			bIsDoor = false,
			bIsOpen = false,
			bSwitchActive = false,
			actNode = "/Global/BRSwitch/Active",
			bRecursive = false
		},
		{
			id = TRIGGER._TINDUST_BAR_DOOR_SWITCH_03,
			OnActivate = F_BarricadeDoorOpen,
			OnDeactivate = F_BarricadeDoorClose,
			bIsSwitch = true,
			bIsDoor = false,
			bIsOpen = false,
			bSwitchActive = false,
			actNode = "/Global/BRSwitch/Active",
			bRecursive = false
		},
		{
			id = TRIGGER._TINDUST_TRAIN_SWITCH_01,
			OnActivate = F_RoundhouseMove,
			OnDeactivate = F_RoundhouseMove,
			bIsSwitch = true,
			bIsDoor = false,
			bIsOpen = false,
			bSwitchActive = false,
			actNode = "/Global/Switch/Active",
			bRecursive = false
		},
		{
			id = TRIGGER._TINDUST_TRAIN_SWITCH_02,
			OnActivate = F_RoundhouseMove,
			OnDeactivate = F_RoundhouseMove,
			bIsSwitch = true,
			bIsDoor = false,
			bIsOpen = false,
			bSwitchActive = false,
			actNode = "/Global/Switch/Active",
			bRecursive = false
		},
		{
			id = TRIGGER._TINDUST_GATE_SWITCH,
			OnActivate = F_BarricadeDoorOpen,
			OnDeactivate = F_BarricadeDoorClose,
			bIsSwitch = true,
			bIsDoor = false,
			bIsOpen = false,
			bSwitchActive = false,
			actNode = "/Global/Switch/Active",
			bRecursive = false
		},
		{
			id = TRIGGER._TINDUST_BAR_DOOR_SWITCH_PORT,
			OnActivate = F_BarricadeDoorOpen,
			OnDeactivate = F_BarricadeDoorClose,
			bIsSwitch = true,
			bIsDoor = false,
			bIsOpen = false,
			bSwitchActive = false,
			actNode = "/Global/Switch/Active",
			bRecursive = false
		}
	}
	tblBarricadeDoors = {
		{
			idSwitch = TRIGGER._TINDUST_BAR_DOOR_SWITCH_02,
			idDoor = TRIGGER._TINDUST_BAR_DOOR_02,
			idDoor2 = TRIGGER._TINDUST_BAR_DOOR_01,
			idCamPath = PATH._TINDUST_BAR_DOOR_CAM_02
		},
		{
			idSwitch = TRIGGER._TINDUST_BAR_DOOR_SWITCH_03,
			idDoor = TRIGGER._TINDUST_BAR_DOOR_03,
			idCamPath = PATH._TINDUST_BAR_DOOR_CAM_03
		},
		{
			idSwitch = TRIGGER._TINDUST_BAR_DOOR_SWITCH_PORT,
			idDoor = TRIGGER._TINDUST_BAR_DOOR_PORT,
			idCamPath = PATH._TINDUST_BAR_DOOR_CAM_PORT
		},
		{
			idSwitch = TRIGGER._TINDUST_GATE_SWITCH,
			idDoor = TRIGGER._TINDUST_REDSTAR_GATE_01,
			idCamPath = PATH._TINDUST_REDSTAR_GATE_CAM
		}
	}
	Wait(0)
	PAnimSetActionNode(TRIGGER._TINDUST_REDSTAR_GATE_01, "/Global/Door/Closed", "Act/Props/Door.act")
	AreaSetDoorLocked(TRIGGER._TINDUST_REDSTAR_GATE_01, true)
end

function main()
	F_SetupProps()
	while not (not PlayerIsInTrigger(TRIGGER._INDUSTRIALAREA_DROPOUTENCLAVE) or SystemShouldEndScript()) do
		F_PropMonitor()
		Wait(0)
	end
	collectgarbage()
end
