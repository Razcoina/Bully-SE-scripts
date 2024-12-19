local gInitial = true
local gPlayerWon = true
local gPlayerStart = -1
local gPedCreatePoint = -1
local gCameraStatic = -1
local gCameraDynamic = -1
local gWindow = 0.9
local gMaxBet = 2000
local gDifficultyLevel = 1
local gTierNo = 5
local gActionsPerLevel = {
	8,
	8,
	8,
	8,
	8
}
local gTimingPerLevel = {
	0.85,
	1.046,
	1.02,
	0.5,
	0.5
}
local gWindowTime = {
	1,
	0.8,
	0.7,
	0.6,
	0.5
}
local gInitialTiming = 1.5
local camNo = 1
local actionNo = 0
local gFullActions = {
	0,
	1,
	2,
	3,
	4,
	5,
	6,
	7
}
local gTimingTable = {
	105,
	26,
	26,
	32,
	27,
	37,
	27,
	32,
	26,
	35,
	29,
	36,
	26,
	24,
	26,
	27,
	34,
	37,
	28,
	36,
	31,
	28,
	23
}
local gGameCams = {}

function F_End(param)
	--print("THE PARAM IS ", param)
	if gInitial then
		gInitial = false
	else
		if param == 0 then
			--print(" THE PLAYER PASSED")
			gPlayerWon = true
		elseif param == 1 then
			--print(" THE PLAYER FAILED")
			gPlayerWon = false
		end
		gInitial = true
	end
end

function F_Finished()
	gFinished = true
end

function F_TierTwo()
	if 1 < gTierNo then
		--print("TIER TWO <<<<<<<<<<<<<<<<<< true")
		return 1
	else
		--print("TIER TWO <<<<<<<<<<<<<<<<<< false")
		return 0
	end
end

function F_TierThree()
	if 2 < gTierNo then
		--print("TIER THREE <<<<<<<<<<<<<<<<<< true")
		return 1
	else
		--print("TIER THREE <<<<<<<<<<<<<<<<<< false")
		return 0
	end
end

function F_TierFour()
	--print("TIER FOUR <<<<<<<<<<<<<<<<<<")
	if 3 < gTierNo then
		return 1
	else
		return 0
	end
end

function F_TierFive()
	--print("TIER FIVE <<<<<<<<<<<<<<<<<<")
	if 4 < gTierNo then
		return 1
	else
		return 0
	end
end

function MissionSetup()
	MissionDontFadeIn()
	DATLoad("MGHackySack.DAT", 2)
	DATInit()
	SoundDisableSpeech_ActionTree()
	gPlayerStart = POINTLIST._HACKYSACK01
	gPedCreatePoint = POINTLIST._HACKY_JOCKSTART
	gCameraStatic = PATH._HACKY_STATICCAM
	gCameraDynamic = PATH._HACKY_CAMPATH
	gPlayerCamera = PATH._HACKY_PLAYERCAM
	gBallStart = POINTLIST._HACKY_BALLSTART
	gPlayerPath = PATH._HACKY_PLAYERPATH01
	gPlayerToBall = PATH._HACKY_PLAYERTOBALL01
	gJockPath = PATH._HACKY_JOCKAWAY01
	cx, cy, cz = GetPointList(POINTLIST._HACKY_PLAYERSTART)
	cz = cz + 1.8
	gCameraFOV = 50
	local x, y, z = GetPointList(POINTLIST._HACKYSACK02)
	if PedIsInAreaXYZ(gPlayer, x, y, z, 5, 0) then
		gPlayerStart = POINTLIST._HACKY_PLAYERSTART02
		gPedCreatePoint = POINTLIST._HACKYSACK02
		gCameraStatic = PATH._HACKY_STATICCAM02
		gCameraDynamic = PATH._HACKY_CAMPATH02
		gPlayerCamera = PATH._HACKY_PLAYERCAM02
		gBallStart = POINTLIST._HACKY_BALLSTART02
		gPlayerPath = PATH._HACKY_PLAYERPATH02
		gPlayerToBall = PATH._HACKY_PLAYERTOBALL02
		gJockPath = PATH._HACKY_JOCKAWAY02
		cx, cy, cz = GetPointList(POINTLIST._HACKY_PLAYERSTART02)
		cz = cz + 1.8
	end
	PedSetFlag(gPlayer, 108, true)
	HudComponents()
	NonMissionPedGenerationDisable()
	AreaTransitionPoint(0, gPlayerStart, nil, true)
	AreaClearAllPeds()
end

function MissionCleanup()
	--print(" >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MISSION CLEANUP ")
	NonMissionPedGenerationEnable()
	MinigameDestroy()
	SoundEnableSpeech_ActionTree()
	PlayerWeaponHudLock(false)
	PedDestroyWeapon(gPlayer, 378)
	PedSetFlag(gPlayer, 108, false)
	UnLoadAnimationGroup("MINIHACKY")
	PlayerSetControl(1)
	DATUnload(2)
	HudComponents(true)
end

function F_SequenceStart()
	gStarted = true
end

function F_GetRandom(lastElement, actions)
	local tempAction = RandomTableElement(actions)
	if tempAction == lastElement then
		tempAction = F_GetRandom(lastElement, actions)
	end
	return tempAction
end

function main()
	gGameCams = {
		{
			path = PATH._HACKY_CAMSHOT01,
			offset = 0.49999934
		},
		{
			path = PATH._HACKY_CAMSHOT02,
			offset = 0.9599989
		},
		{
			path = PATH._HACKY_CAMSHOT03,
			offset = 0.79999936
		},
		{
			path = PATH._HACKY_CAMSHOT04,
			offset = 0.019999925
		},
		{
			path = PATH._HACKY_CAMSHOT05,
			offset = 1.0799979
		}
	}
	WeaponRequestModel(378)
	while not WeaponRequestModel(378) do
		Wait(0)
	end
	LoadAnimationGroup("MINIHACKY")
	LoadActionTree("Act/KeepUps.act")
	while IsStreamingBusy() do
		Wait(0)
	end
	gTierNo = GetMissionCurrentSuccessCount() + 1
	if 5 < gTierNo then
		gTierNo = 5
	end
	AreaClearAllPeds()
	gTierNo = 5
	gLuis = PedCreatePoint(16, gPedCreatePoint)
	PedSetPedToTypeAttitude(gLuis, 13, 4)
	Wait(0)
	PedFaceObject(gPlayer, gLuis, 2, 0)
	PedFaceObject(gLuis, gPlayer, 2, 0)
	PlayerUnequip()
	while WeaponEquipped() do
		Wait(0)
	end
	PlayerWeaponHudLock(true)
	CameraSetWidescreen(true)
	PlayerSetControl(0)
	MinigameCreate("KEEPUPS", false)
	while MinigameIsReady() == false do
		Wait(0)
	end
	CameraSetPath(PATH._HACKY_INTROCAM, true)
	CameraSetSpeed(1.5, 1.5, 1.5)
	CameraLookAtPath(PATH._HACKY_INTROCAMLOOKAT, true)
	CameraLookAtPathSetSpeed(1.5, 1.5, 1.5)
	CameraFade(1000, 1)
	PedMoveToPoint(gLuis, 1, POINTLIST._HACKY_JOCKRUNTO)
	Wait(10)
	PedSetWeapon(gLuis, 329, 1)
	Wait(2000)
	SoundPlayScriptedSpeechEvent(gLuis, "KEEPUPS", 2, "speech")
	PedSetActionNode(gLuis, "/Global/AI/WeaponActions/WeaponActions/RangedWeaponActions/AmmoCheck/DeEquipWeapon", "Act/Ai/Ai.act")
	Wait(2500)
	PedClearObjectives(gLuis)
	Wait(500)
	F_InitialJockCutscene()
	PedMoveToPoint(gLuis, 0, POINTLIST._HACKY_RESTPOINT)
	Wait(500)
	PedMoveToPoint(gPlayer, 0, gBallStart)
	Wait(1000)
	PedSetActionNode(gLuis, "/Global/KeepUps/IdleAnimations/WalkTOWall", "Act/KeepUps.act")
	CameraSetXYZ(-5.791627, -105.093414, 2.5703156, -3.3076508, -107.48812, 1.8705637)
	CameraLookAtPlayer(true, 0.41999966)
	Wait(1000)
	bWaiting = true
	Wait(100)
	CameraSetWidescreen(false)
	F_Betting()
	TutorialShowMessage("MGSK_11", 5000)
	if not gMissionFail then
		local actions = {}
		for i = 1, gActionsPerLevel[gTierNo] do
			table.insert(actions, gFullActions[i])
		end
		local gameTable = {}
		local lastAction
		for i = 1, table.getn(gTimingTable) do
			if i <= 1 then
				lastAction = 0
			else
				lastAction = F_GetRandom(lastAction, actions)
			end
			table.insert(gameTable, lastAction)
		end
		MinigameStart()
		MinigameEnableHUD(true)
		local gCurrentTierAddition = 0
		local gCurrentTier = 1
		local firstMove
		for i, element in gameTable do
			MGKeepUpsAddAction(0, element, gTimingTable[i] / 30 - gWindow, gWindow)
			gCurrentTierAddition = gCurrentTierAddition + 1
			if 5 <= gCurrentTierAddition then
				gCurrentTierAddition = 0
				gCurrentTier = gCurrentTier + 1
			end
		end
		CameraSetPath(PATH._HACKY_CAMSHOT00, true)
		CameraSetSpeed(0.5, 0.5, 0.5)
		CameraLookAtPlayer(true, 0.41999966)
		TextPrintString("", 1, 2)
		TextPrintString("", 1, 1)
		CameraSetWidescreen(false)
		Wait(1000)
		gStarted = nil
		TextPrint("MGSK_18", 2, 1)
		Wait(2500)
		TextPrint("MGSK_19", 1, 1)
		Wait(2000)
		camNo = 1
		actionNo = 0
		CameraSetPath(gGameCams[camNo].path, true)
		CameraSetSpeed(0.5, 0.5, 0.5)
		CameraLookAtPlayer(true, gGameCams[camNo].offset)
		PedSetActionNode(gPlayer, "/Global/KeepUps/Keepups", "Act/KeepUps.act")
		while not gStarted do
			Wait(0)
		end
		local aTableSize = table.getn(gameTable)
		--print("ATABLESIZE", aTableSize)
		local aCurrent = 1
		PlayerSetControl(1)
		MGKeepUpsSetFuncs(F_Pass, F_Fail)
		MGKeepUpsStartSeq(0)
		while MinigameIsActive() do
			Wait(0)
		end
		while not gInitial do
			Wait(0)
		end
		PlayerSetControl(0)
		if MinigameIsSuccess() then
			CameraLookAtXYZ(-3.6803718, -107.32619, 2.251011, true)
			CameraSetXYZ(-8.544561, -110.093994, 3.8510067, -3.6803718, -107.32619, 2.251011)
			gPlayerWon = true
		else
			gPlayerWon = false
		end
		Wait(2000)
		if gPlayerWon then
			PlayerAddMoney(gCurrentBet, false)
			if gTierNo == 5 then
				PedSetActionNode(gPlayer, "/Global/KeepUps/IdleAnimations/PlayerWin", "Act/KeepUps.act")
				PedSetActionNode(gLuis, "/Global/KeepUps/IdleAnimations/PlayerFail", "Act/KeepUps.act")
				SoundPlayScriptedSpeechEvent(gLuis, "VICTIMIZED", 0, "speech")
				PedFaceObject(gLuis, gPlayer, 3, 1)
				Wait(3000)
				PedMakeAmbient(gLuis)
			else
				PedSetActionNode(gPlayer, "/Global/KeepUps/IdleAnimations/PlayerWin", "Act/KeepUps.act")
				PedSetActionNode(gLuis, "/Global/KeepUps/IdleAnimations/PlayerFail", "Act/KeepUps.act")
				SoundPlayScriptedSpeechEvent(gLuis, "SEE_SOMETHING_CRAP", 0, "speech")
				PedMakeAmbient(gLuis)
			end
			Wait(1500)
			PlayerSetControl(1)
			StatAddToInt(213)
			MissionSucceed(true, false, false)
		else
			PlayerAddMoney(-gCurrentBet, false)
			PedClearObjectives(gLuis)
			PedSetActionNode(gLuis, "/Global/KeepUps/IdleAnimations/PlayerWin", "Act/KeepUps.act")
			if 1 >= GetMissionCurrentAttemptCount() then
				SoundPlayScriptedSpeechEvent(gLuis, "TAUNT_PLAYER_FALLEN", 0, "speech")
			else
				SoundPlayScriptedSpeechEvent(gLuis, "JEER", 0, "speech")
			end
			Wait(2500)
			CameraFade(1000, 0)
			Wait(1000)
			MissionFail(true, false)
		end
		PedClearObjectives(gPlayer)
		PedSetActionNode(gPlayer, "/Global/KeepUps/IdleAnimations/PlayerIdle", "Act/KeepUps.act")
	end
end

function HudComponents(bShow)
	bShow = bShow or false
	ToggleHUDComponentVisibility(11, bShow)
	ToggleHUDComponentVisibility(4, bShow)
	ToggleHUDComponentVisibility(0, bShow)
end

function F_Betting()
	bWaiting = true
	gCurrentBet = 100
	gCurrentAmount = PlayerGetMoney()
	--print("PLAYER HAS MONEY:", gCurrentAmount)
	Wait(200)
	TutorialShowMessage("MGSK_21")
	while bWaiting do
		TextAddParamNum(gCurrentBet)
		TextPrintF("MGSK_20", 1, 2)
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
			elseif gCurrentBet > gCurrentAmount then
				gCurrentBet = gCurrentAmount
				SoundPlay2D("NavInvalid")
			else
				SoundPlay2D("NavUp")
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
			PedMakeAmbient(gLuis)
			TutorialRemoveMessage()
			gMissionFail = true
			MissionFail(true, false)
			bWaiting = false
		elseif IsButtonPressed(7, 0) then
			SoundPlay2D("BuyItem")
			StatAddToInt(212)
			gHack = true
			bWaiting = false
		end
		Wait(0)
	end
	TutorialRemoveMessage()
	MinigameSetElapsedGameTime(0, 15)
end

function F_Pass(index)
	--print("PASSED ONE", index)
	if index ~= gLastIndexCalled then
		gLastIndexCalled = index
		aCurrent = index + 1
		actionNo = actionNo + 1
		if 5 <= actionNo then
			actionNo = 0
			camNo = camNo + 1
			if 5 < camNo then
				camNo = 1
			end
			CameraSetPath(gGameCams[camNo].path, true)
			CameraSetSpeed(0.5, 0.5, 0.5)
			CameraLookAtPlayer(true, gGameCams[camNo].offset)
		end
	end
end

function F_Fail(index)
	--print("FAILED ONE", index)
	CameraLookAtXYZ(-3.8834343, -107.21885, 2.15487, true)
	CameraSetXYZ(-5.4131722, -105.07023, 1.1148763, -3.8834343, -107.21885, 2.15487)
	PedSetActionNode(gPlayer, "/Global/KeepUps/Sequences/Fail", "Act/KeepUps.act")
	MinigameEnd()
	--print("PLAYER IS FAILING NOW ")
end

function F_InitialJockCutscene()
	if GetMissionCurrentAttemptCount() <= 1 then
		PedStop(gLuis)
		PedClearObjectives(gLuis)
		SoundPlayScriptedSpeechEvent(gPlayer, "KEEPUPS", 1, "speech")
		Wait(50)
		PedMoveToPoint(gLuis, 0, gBallStart)
		Wait(1000)
		CameraFade(500, 0)
		Wait(600)
		local jx, jy, jz = PedGetPosXYZ(gLuis)
		CameraSetPath(PATH._HACKY_JOCKPLAY, true)
		CameraSetSpeed(1, 1, 1)
		CameraLookAtPath(PATH._HACKY_JOCKPLAYLOOKAT, true)
		CameraLookAtPathSetSpeed(1, 1, 1)
		SoundPlayScriptedSpeechEvent(gLuis, "KEEPUPS", 3, "speech")
		PickupDestroyTypeInAreaXYZ(jx, jy, jz, 5, 329)
		PedSetActionNode(gLuis, "/Global/KeepUps/Keepups", "Act/KeepUps.act")
		Wait(150)
		CameraFade(500, 1)
		while not gFinished do
			Wait(0)
		end
		PickupCreatePoint(329, gBallStart, 1, 0)
	end
end
