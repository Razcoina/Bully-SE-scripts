--[[ Changes to this file:
	* Modified function main, may require testing
]]

local RIDE_COASTER = 0
local RIDE_SQUID = 1
local RIDE_FERRIS = 2
local gCurrentRide
local bRideOver = false
local gCost = 0

function F_SetupRide(ride)
	--print(">>>[RUI]", "++F_SetupRide " .. tostring(ride))
	gCurrentRide = ride
end

function F_RideOver(ride)
	--print(">>>[RUI]", "!!F_RideOver  " .. tostring(gCurrentRide))
	bRideOver = true
end

function CarnivalRideSetup(ride)
	if ride == RIDE_COASTER then
		--print(">>>[RUI]", "CarnivalRideSetup  Coaster")
		gCost = -100
		gCurrentRide = RIDE_COASTER
		gRideId = TRIGGER._COASTER
		gRideActionFile = "Act/Props/Coaster.act"
		gRideActiveActionNode = "/Global/Coaster/RideMe"
		gRideResetNode = "/Global/Coaster/NotUseable/Loop"
		gRide = "Coaster"
		gStartPoint = POINTLIST._COASTERSTART
		gEndPoint = POINTLIST._COASTEREND
		StatAddToInt(239)
	elseif ride == RIDE_SQUID then
		--print(">>>[RUI]", "CarnivalRideSetup  Squid")
		gCost = -100
		gCurrentRide = RIDE_SQUID
		gRideId = TRIGGER._SQUID
		gRideActionFile = "Act/Props/Squid.act"
		gRideActiveActionNode = "/Global/Squid/RideMe"
		gRideResetNode = "/Global/Squid/NotUseable/Loop"
		gRide = "Squid"
		gStartPoint = POINTLIST._BIGSQUIDSTART
		gEndPoint = POINTLIST._BIGSQUIDEND
		StatAddToInt(240, 1)
	elseif ride == RIDE_FERRIS then
		--print(">>>[RUI]", "CarnivalRideSetup  Ferris Wheel")
		gCost = -100
		gCurrentRide = RIDE_FERRIS
		gRideId = TRIGGER._FERRIS
		gRideActionFile = "Act/Props/Ferris.act"
		gRideActiveActionNode = "/Global/Ferris/RideMe"
		gRideResetNode = "/Global/Ferris/NotUseable/Loop"
		gRide = "Ferris"
		gStartPoint = POINTLIST._FERRISWHEELSTART
		gEndPoint = POINTLIST._FERRISWHEELEND
		StatAddToInt(195)
	end
	PlayerAddMoney(gCost)
	SoundPlay2D("BuyItem")
	Wait(200)
end

function NIS_EnterRide(ride)
	--print(">>>[RUI]", "!NIS_EnterRide")
	PlayerSetControl(0)
	shared.g2_G2_HidePinky = true
	AreaForceLoadAreaByAreaTransition(true)
	AreaTransitionPoint(0, gStartPoint, 1)
	AreaForceLoadAreaByAreaTransition(false)
	PAnimModelNeeded(gRideId)
	if ride == RIDE_COASTER then
		CameraSetXYZ(141.089, 478.2689, 8.900843, 140.42162, 479.0092, 8.825794)
	elseif ride == RIDE_FERRIS then
		CameraSetXYZ(194.2338, 467.338, 9.207143, 195.01477, 467.8911, 8.917427)
	else
		CameraSetXYZ(163.33458, 454.72284, 9.482884, 163.7845, 455.61584, 9.487644)
	end
	Wait(500)
	PAnimSetActionNode(gRideId, gRideActiveActionNode, gRideActionFile)
	CameraFade(500, 1)
	Wait(601)
end

function NIS_ExitRide(ride, bEmergencyExit)
	--print(">>>[RUI]", "!!NIS_ExitRide")
	if bEmergencyExit then
		fadeInTime = 500
		fadeOutTime = 100
	else
		fadeInTime = FADE_IN_TIME
		fadeOutTime = FADE_OUT_TIME
	end
	CameraFade(fadeOutTime, 0)
	Wait(fadeOutTime + 1)
	PAnimSetActionNode(gRideId, gRideResetNode, gRideActionFile)
	if ride == RIDE_COASTER then
		shared.g2_G2_ReturnWhere = 1
	elseif ride == RIDE_FERRIS then
		shared.g2_G2_ReturnWhere = 3
	else
		shared.g2_G2_ReturnWhere = 2
	end
	shared.g2_G2_ReturnPinky = true
	EnableHudComponents(true)
	PedSetEffectedByGravity(gPlayer, true)
	PlayerSetPosPoint(gEndPoint, 1)
	CameraReturnToPlayer()
	CameraFade(fadeInTime, 1)
	Wait(fadeInTime + 1)
	CameraReset()
	PlayerSetControl(1)
	--print(">>>[RUI]", "--NIS_ExitRollerCoaster")
end

function EnableHudComponents(bShow)
	if bShow then
		HUDRestoreVisibility()
	else
		HUDSaveVisibility()
		HUDClearAllElements()
	end
end

function TimerPassed(time)
	return time < GetTimer()
end

function GetOnRide(ride)
	local timer = GetTimer() + 2000
	PedSetFlag(gPlayer, 2, false)
	Wait(50)
	PedTargetPAnim(gPlayer, ride)
	while not PedSetActionNode(gPlayer, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act") do
		if TimerPassed(timer) then
			return false
		end
		Wait(0)
	end
	--print(">>>[RUI]", "!!GetOnRide ON")
	while not PedMePlaying(gPlayer, gRide, true) do
		if TimerPassed(timer) then
			return false
		end
		Wait(0)
	end
	--print(">>>[RUI]", "!!GetOnRide RIDING")
	return true
end

function MissionSetup()
	MissionDontFadeIn()
	PlayerSetControl(0)
	F_MakePlayerSafeForNIS(true)
	DATLoad("CarnivalRides.DAT", 2)
	DATInit()
	SoundFadeWithCamera(false)
	SystemEnableFrontEndAndSelectScreens(false)
	--print(">>>[RUI]", "!!MissionSetup")
end

function MissionInit()
	while not gCurrentRide do
		Wait(10)
	end
	CarnivalRideSetup(gCurrentRide)
	--print(">>>[RUI]", "++MissionInit")
end

function main() -- ! Modified
	MissionInit()
	CameraFade(FADE_OUT_TIME, 0)
	Wait(FADE_OUT_TIME + 1)
	EnableHudComponents(false)
	PedSetFlag(gPlayer, 5, true)
	Wait(1000)
	NIS_EnterRide(gCurrentRide)
	bGotOnRide = GetOnRide(gRideId)
	while not (not bGotOnRide or bRideOver) do
		if not bRideOver and not PedMePlaying(gPlayer, gRide, true) then
			--print(">>>[RUI]", "!!EMERGENCY EXIT RIDE KAPUT")
			PedSetEffectedByGravity(gPlayer, false)
			PedSetEntityFlag(gPlayer, 1, true)
			PedSetEntityFlag(gPlayer, 0, true)
			PedSetInvulnerable(gPlayer, false)
			bEmergencyExit = true
			break
		end
		Wait(10)
	end
	--[[
	if not bGotOnRide then
		--print(">>>[RUI]", "MAIN PLAYER FAILED GETTING ON RIDE BAIL")
	end
	]] -- Removed this
	NIS_ExitRide(gCurrentRide, bEmergencyExit)
	PedSetFlag(gPlayer, 5, false)
	MissionSucceed(false, true, false)
	collectgarbage()
end

function MissionCleanup()
	SystemEnableFrontEndAndSelectScreens(true)
	PedTargetPAnim(gPlayer, -1)
	SoundFadeWithCamera(true)
	F_MakePlayerSafeForNIS(false)
	PlayerSetControl(1)
	shared.gCoasterRideOver = false
	UnLoadAnimationGroup("N_STRIKER_B")
	UnLoadAnimationGroup("PedCoaster")
	DATUnload(2)
	--print(">>>[RUI]", "--MissionCleanup")
end
