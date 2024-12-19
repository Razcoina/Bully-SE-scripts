local proj1
local bSuccessMessage = false
local ax, ay, az
local num_kicked = 0
local button_down = false
local nSocPenExternalLevel
local level = 1
local new_counter
local bStageLoaded = false
local gCurrentScore = 0
local gPaths = {}
local gHits = 0
local gMaxBet = 2000
local gNoOfHits = 3

function F_SocPenInit()
	if proj1 then
		DestroyProjectile(proj1)
	end
	proj1 = CreateProjectile(329, ax + 0.5, ay, az + 0.2, 0, 0, 0)
	PedSetActionNode(gPlayer, "/Global/MGSocPen/UseSoccerGoal3Old/UseSoccerGoalStart", "Act/Conv/MGSocPen.act")
	SoccerPSetProjectile(proj1)
	SoccerPSetPed(gTargetBoy)
end

function MissionSetup()
	MissionDontFadeIn()
	DATLoad("SoccerGoal.DAT", 2)
	DATInit()
	DisablePunishmentSystem(true)
	PlayerSetControl(0)
	WeaponRequestModel(329)
	LoadAnimationGroup("MINI_React")
	LoadAnimationGroup("BBALL_21")
	LoadAnimationGroup("NPC_Cheering")
	MinigameCreate("SOCCERP", false)
	SoundFadeWithCamera(false)
	PedSetFlag(gPlayer, 98, false)
	PedSetFlag(gPlayer, 108, true)
	local points = {
		POINTLIST._UPPERLEFT,
		POINTLIST._UPPERMIDDLE,
		POINTLIST._UPPERRIGHT,
		POINTLIST._LOWERLEFT,
		POINTLIST._LOWERMIDDLE,
		POINTLIST._LOWERRIGHT
	}
	ax, ay, az = GetPointFromPointList(POINTLIST._ALIGNMENTPOINT, 1)
	AreaTransitionPoint(0, POINTLIST._ALIGNMENTPOINT, nil, true)
	DisablePOI(true, true)
	NonMissionPedGenerationDisable()
	AreaClearAllPeds()
	F_MakePlayerSafeForNIS(true, false)
	HudComponents(false)
	num_kicked = 0
	gPaths = {
		PATH._SOC_PATH01,
		PATH._SOC_PATH02,
		PATH._SOC_PATH03,
		PATH._SOC_PATH04,
		PATH._SOC_PATH05,
		PATH._SOC_PATH06,
		PATH._SOC_PATH07
	}
end

function MissionCleanup()
	NonMissionPedGenerationEnable()
	EnablePOI(true, true)
	DisablePunishmentSystem(false)
	if proj1 then
		DestroyProjectile(proj1)
	end
	PlayerSetControl(1)
	PedSetActionNode(gPlayer, "/Global/MGSocPen/UseSoccerGoalEnd", "Act/Conv/MGSocPen.act")
	TextPrintString("", 0.5, 1)
	TextPrintString("", 0.5, 2)
	PedSetFlag(gPlayer, 98, true)
	PedSetFlag(gPlayer, 108, false)
	PedActionControllerUpdate(gPlayer)
	PlayerWeaponHudLock(false)
	MinigameEnd()
	SoundFadeWithCamera(true)
	MinigameDestroy()
	HudComponents(true)
	CameraReturnToPlayer()
	F_MakePlayerSafeForNIS(false, false)
	CameraReset()
	DATUnload(2)
	UnLoadAnimationGroup("MINI_React")
end

function F_Success()
	if not bSuccessMessage then
		bSuccessMessage = true
	end
end

function main()
	PlayerUnequip()
	gTargetBoy = PedCreatePoint(70, POINTLIST._PEDTARGETLOCATION)
	PedSetActionTree(gTargetBoy, "/Global/MGSocPen/TargetReactions/Default", "Act/Conv/MGSocPen.act")
	Wait(1000)
	PlayerWeaponHudLock(true)
	local bikes = VehicleFindInAreaXYZ(68.0681, -89.2663, 5.0771, 5)
	if bikes then
		for i, bike in bikes do
			VehicleDelete(bike)
		end
	end
	CameraLookAtXYZ(69.05131, -89.33579, 6.0425286, true)
	CameraSetXYZ(66.456825, -89.91024, 5.9025617, 69.05131, -89.33579, 6.0425286)
	proj1 = CreateProjectile(329, ax + 0.5, ay, az + 0.2, 0, 0, 0)
	PlayerFaceHeadingNow(-90)
	CameraFade(500, 1)
	if GetMissionCurrentSuccessCount() <= 2 then
		TutorialShowMessage("MGSP_INST")
	end
	SoundPlayAmbientSpeechEvent(gTargetBoy, "JEER")
	Wait(2000)
	SoundPlayAmbientSpeechEvent(gTargetBoy, "LAUGH_CRUEL")
	Wait(2000)
	CameraSetPath(PATH._SCO_INTROCAMPATH, true)
	CameraSetSpeed(4.2, 4.2, 4.2)
	CameraLookAtPath(PATH._SCO_INTROLOOKPATH, true)
	CameraLookAtPathSetSpeed(2.8, 2.8, 2.8)
	PlayerSetPosSimple(ax, ay, az)
	F_Betting()
	F_SetDifficulty()
	gMaxTargetHealth = PedGetMaxHealth(gTargetBoy)
	gPedHealth = gMaxTargetHealth
	PedShowHealthBar(gTargetBoy, true, "N_CONSTANTINOS", true)
	TextPrintString("", 0, 1)
	gSoccerValues = {
		15,
		10,
		15,
		15,
		10,
		15,
		20,
		20,
		20,
		20
	}
	gGameStarted = true
	CreateThread("T_PedFunction")
	Wait(400)
	while 0 < num_kicked do
		F_InitMinigame()
		PlayerFaceHeadingNow(-90)
		SoccerPSetProjectile(proj1)
		SoccerPStartAiming()
		local buttonPressed = 0
		button_down = false
		pedHit = false
		ToggleHUDComponentVisibility(3, true)
		MissionTimerStart(10)
		gTimerEnded = false
		gHeWasHit = false
		while MinigameIsActive() do
			if not button_down and IsButtonPressed(7, 0) then
				--DebugPrint("X is pressed!!!")
				button_down = true
				PedStop(gTargetBoy)
				PedClearObjectives(gTargetBoy)
				if not PedIsPlaying(gTargetBoy, "/Global/MGSocPen/TargetReactions/Mock/Mock1", true) then
					PedSetActionNode(gTargetBoy, "/Global/MGSocPen/TargetReactions/Scared", "Act/Conv/MGSocPen.act")
				end
				MissionTimerStop()
			end
			if button_down and not pedHit then
				Wait(1000)
				if not gHeWasHit then
					SoundStopCurrentSpeechEvent(gTargetBoy)
					SoundPlayScriptedSpeechEvent(gTargetBoy, "PENALTY", 2, "speech")
					PedFaceObject(gTargetBoy, gPlayer, 3, 0)
					Wait(10)
					PedSetActionNode(gTargetBoy, "/Global/MGSocPen/TargetReactions/Cheer/Cheer1", "Act/Conv/MGSocPen.act")
				end
				pedHit = true
			end
			if MissionTimerHasFinished() then
				SoccerPStopAiming()
				gTimerEnded = true
			end
			Wait(0)
		end
		MissionTimerStop()
		num_kicked = num_kicked - 1
		SoccerPSetBallsToKick(num_kicked)
		local bSuccess = MinigameIsSuccess()
		local x, y, z = SoccerPGetHitPos()
		targetindex = SoccerPGetHitTarget()
		PlayerSetControl(0)
		if gHits >= gNoOfHits then
			num_kicked = 0
		end
		Wait(1000)
		if not bSuccess and not gTimerEnded then
			num_kicked = 0
			MinigameEnableHUD(false)
			MissionFail(true, false)
		end
	end
	MinigameEnableHUD(false)
	gGameStarted = false
	MinigameEnd()
	PedHideHealthBar()
	CameraLookAtPlayer(true, 0.5)
	CameraSetPath(PATH._SOC_CAMPATH, true)
	CameraSetSpeed(1.5, 1.5, 1.5)
	--print("-------[RAUL] Soccer Position ", x, y, z, targetindex)
	if gHits >= gNoOfHits then
		PlayerAddMoney(gCurrentBet, false)
		PedSetActionNode(gPlayer, "/Global/MGSocPen/PlayerReactions/PlayerGoodVictory", "Act/Conv/MGSocPen.act")
	else
		PlayerAddMoney(-gCurrentBet, false)
		PedSetActionNode(gPlayer, "/Global/MGSocPen/PlayerReactions/PlayerBadFailure", "Act/Conv/MGSocPen.act")
		PedSetActionTree(gTargetBoy, "/Global/GS_Male_A", "Act/Anim/GS_Male_A.act")
		PedStop(gTargetBoy)
		PedClearObjectives(gTargetBoy)
	end
	Wait(4000)
	if gHits >= gNoOfHits then
		MissionSucceed(true, true, false)
		StatAddToInt(215)
	else
		PedMakeAmbient(gTargetBoy)
		PedFlee(gTargetBoy, gPlayer)
		MissionFail(true, false)
	end
end

function T_PedFunction()
	while gGameStarted do
		if not gFollowingPath then
			PedStop(gTargetBoy)
			PedClearObjectives(gTargetBoy)
			PedFollowPath(gTargetBoy, gPaths[math.random(1, 7)], 3, 1, CbTargetReach)
			gFollowingPath = true
		end
		if PedIsPlaying(gTargetBoy, "/Global/MGSocPen/TargetReactions/Scared", true) then
			while PedIsPlaying(gTargetBoy, "/Global/MGSocPen/TargetReactions/Scared", true) do
				Wait(0)
			end
			gFollowingPath = false
		end
		if PedIsPlaying(gTargetBoy, "/Global/MGSocPen/TargetReactions/Cheer", true) then
			while PedIsPlaying(gTargetBoy, "/Global/MGSocPen/TargetReactions/Cheer", true) do
				Wait(0)
			end
			gFollowingPath = false
		end
		if PedIsPlaying(gTargetBoy, "/Global/MGSocPen/TargetReactions/CustomHitTree", true) then
			while PedIsPlaying(gTargetBoy, "/Global/MGSocPen/TargetReactions/CustomHitTree", true) do
				Wait(0)
			end
			gFollowingPath = false
		end
		if gReachedPath then
			gReachedPath = false
			PedStop(gTargetBoy)
			PedClearObjectives(gTargetBoy)
			Wait(100)
			PedFaceObject(gTargetBoy, gPlayer, 3, 0)
			Wait(200)
			SoundPlayScriptedSpeechEvent(gTargetBoy, "PENALTY", 1, "speech")
			PedSetActionNode(gTargetBoy, "/Global/MGSocPen/TargetReactions/Mock", "Act/Conv/MGSocPen.act")
			gFollowingPath = false
		end
		Wait(0)
	end
end

function CbTargetReach(pedId, pathId, pathNode)
	gReachedPath = true
	--print("ReachedPath")
end

function F_SetDifficulty()
	gMissionSucceedCount = GetMissionCurrentSuccessCount()
	--DebugPrint([[
	--
	--
	--MISSION SUCCESS COUNT: ]] .. gMissionSucceedCount .. [[
	--
	--
	--]])
	max_num_kicks_allowed = 5
	if gMissionSucceedCount < 1 then
		gNoOfHits = 3
	elseif gMissionSucceedCount < 2 then
		gNoOfHits = 4
	else
		gNoOfHits = 5
	end
	SoccerPSetBallsToKick(max_num_kicks_allowed)
	--DebugPrint("-----------------------")
	--DebugPrint("max_num_kicks_allowed " .. max_num_kicks_allowed)
	num_kicked = max_num_kicks_allowed
end

function F_SetStage(param)
	nSocPenExternalLevel = param
	bStageLoaded = true
	--print("[ARC]======> nSocPenExternalLevel = " .. nSocPenExternalLevel)
end

function F_InitMinigame()
	F_SocPenInit()
	MinigameStart()
	SoccerPSetMeterSpeed(0.02, 0.02)
	SoccerPSetGoalArea(69.8239, -86.369, 5.15712, 69.8389, -92.414, 5.15712, 2.89)
	SoccerPSetTargetCount(10)
	SoccerPSetTarget(1, 69.7939, -87.054, 7.62712, 1, 0.7, gSoccerValues[1])
	SoccerPSetTarget(2, 69.8064, -88.2215, 6.61594, 0.7, 0.7, gSoccerValues[2])
	SoccerPSetTarget(3, 69.8539, -91.824, 7.62712, 1, 0.7, gSoccerValues[3])
	SoccerPSetTarget(4, 69.7939, -87.054, 5.68212, 1, 0.7, gSoccerValues[4])
	SoccerPSetTarget(5, 69.8364, -90.6065, 6.61594, 0.7, 0.7, gSoccerValues[5])
	SoccerPSetTarget(6, 69.8539, -91.824, 5.68212, 1, 0.7, gSoccerValues[6])
	SoccerPSetTarget(7, 69.8292, -88.5083, 7.62712, 0.5, 0.3, gSoccerValues[7])
	SoccerPSetTarget(8, 69.8335, -90.2746, 7.62712, 0.5, 0.3, gSoccerValues[8])
	SoccerPSetTarget(9, 69.8292, -88.5083, 5.68212, 0.5, 0.3, gSoccerValues[9])
	SoccerPSetTarget(10, 69.8335, -90.2746, 5.68212, 0.5, 0.3, gSoccerValues[10])
	MinigameEnableHUD(true)
	PlayerSetControl(1)
end

function HudComponents(bShow)
	bShow = bShow or false
	ToggleHUDComponentVisibility(11, bShow)
	ToggleHUDComponentVisibility(4, bShow)
	ToggleHUDComponentVisibility(0, bShow)
end

function CbPedHit(pedId)
	--print("[RAUL] Ped Was hit ")
	if gGameStarted and not gHeWasHit then
		gHits = gHits + 1
		if gHits >= gNoOfHits then
			SoundStopCurrentSpeechEvent(gTargetBoy)
			SoundPlayAmbientSpeechEvent(gTargetBoy, "FIGHT_SACKED")
			gGameStarted = false
		else
			SoundStopCurrentSpeechEvent(gTargetBoy)
			SoundPlayScriptedSpeechEvent(gTargetBoy, "PENALTY", 3, "speech")
		end
		gPedHealth = gPedHealth - gMaxTargetHealth / gNoOfHits
		PedSetHealth(pedId, gPedHealth)
		SoccerPSetPedsHealthBar(gPedHealth, gMaxTargetHealth)
		gHeWasHit = true
	end
end

function F_Betting()
	bWaiting = true
	gCurrentBet = 100
	gCurrentAmount = PlayerGetMoney()
	--print("PLAYER HAS MONEY:", gCurrentAmount)
	Wait(200)
	TutorialShowMessage("MGSP_BTUT")
	while bWaiting do
		TextAddParamNum(gCurrentBet)
		TextPrint("MGSP_BET", 1, 2)
		if IsButtonPressed(3, 0) or GetStickValue(17, 0) < -0.5 then
			gCurrentBet = gCurrentBet - 25
			if gCurrentBet < 100 then
				gCurrentBet = 100
				SoundPlay2D("NavInvalid")
			else
				SoundPlay2D("NavDwn")
			end
			Wait(50)
		end
		if IsButtonPressed(2, 0) or GetStickValue(17, 0) > 0.5 then
			gCurrentBet = gCurrentBet + 25
			if gCurrentBet > gMaxBet then
				gCurrentBet = gMaxBet
				SoundPlay2D("NavInvalid")
			else
				SoundPlay2D("NavUp")
			end
			if gCurrentBet > gCurrentAmount then
				gCurrentBet = gCurrentAmount
			end
			Wait(50)
		end
		if IsButtonBeingPressed(8, 0) then
			CameraFade(1000, 0)
			Wait(1000)
			CameraReturnToPlayer()
			CameraReset()
			PlayerSetControl(1)
			CameraSetWidescreen(false)
			TutorialRemoveMessage()
			MissionFail(true, false)
		elseif IsButtonPressed(7, 0) then
			gWindow = 0.5
			gHack = true
			bWaiting = false
			SoundPlay2D("BuyItem")
			StatAddToInt(214)
		end
		Wait(0)
	end
	TutorialRemoveMessage()
end

function F_PedHit(param)
	--print("PED WAS HIT !!!!", param)
	if gGameStarted and not gHeWasHit then
		gHits = gHits + 1
		if param == 1 then
			gHits = gNoOfHits
		elseif param == 2 then
			gHits = gHits + 1
		end
		if gHits >= gNoOfHits then
			SoundStopCurrentSpeechEvent(gTargetBoy)
			SoundPlayAmbientSpeechEvent(gTargetBoy, "FIGHT_SACKED")
			gGameStarted = false
		else
			SoundStopCurrentSpeechEvent(gTargetBoy)
			SoundPlayScriptedSpeechEvent(gTargetBoy, "PENALTY", 3, "speech")
		end
		gPedHealth = gPedHealth - gMaxTargetHealth / gNoOfHits
		if param == 1 then
			gPedHealth = 0
		elseif param == 2 then
			gPedHealth = gPedHealth - gMaxTargetHealth / gNoOfHits
		end
		PedSetHealth(gTargetBoy, gPedHealth)
		SoccerPSetPedsHealthBar(gPedHealth, gMaxTargetHealth)
		gHeWasHit = true
	end
end

function F_HitInTheHead()
	--print("HEADSHOT !!!!")
	gHits = gNoOfHits
end
