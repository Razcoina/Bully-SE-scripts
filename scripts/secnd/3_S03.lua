--[[ Changes to this file:
	* Added local variable
	* Modified function F_Stage1_Objectives, may require testing
	* Modified function F_Stage2_Objectives, may require testing
	* Modified function F_Stage3_Objectives, may require testing
]]

local bDebugMode = false
local bDebugStage = 2
local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bGoToStage3 = false
local bArrivedAtGreasers = false
local bArrivedAtJocks = false
local bArrivedAtHattrick = false
local bPicGreaser = false
local bPicJock = false
local bPicHattrick = false
local bArrivedInPool = false
local bDeletePoolPrep = false
local bRemovedPoolExitBlip = false
local bGallowaySpawned = false
local bPlayerHasGoneToMainMap = false
local gMissionFailMessage = 0
local bPrepAttackedPlayer = false
local photohasbeentaken = false
local wasValid = false
local validGreaserTarget = false
local validJockTarget = false
local validHattrickTarget = false
local L25_1 = false -- ! Cannot recover original name

function MissionSetup()
	--print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
	if not bDebugMode then
		PlayCutsceneWithLoad("3-S03", true)
	end
	MissionDontFadeIn()
	DATLoad("3_S03.DAT", 2)
	DATInit()
	--print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
	--print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	AreaRevertToDefaultPopulation()
	DATUnload(2)
	DATInit()
	UnLoadAnimationGroup("NIS_3_S03")
	F_HideCounter()
	CameraSetWidescreen(false)
	SoundStopInteractiveStream()
	--print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
	--print("()xxxxx[:::::::::::::::> [start] main()")
	F_SetupMission()
	if bDebugMode then
		if bDebugStage == 2 then
			F_StartAtStage2()
		elseif bDebugStage == 3 then
			F_StartAtStage3()
		elseif bDebugStage == 4 then
			F_StartAtStage4()
		end
	else
		F_Stage1()
	end
	if bMissionFailed then
		TextPrint("3_S03_EMPTY", 1, 1)
		SoundPlayMissionEndMusic(false, 7)
		if gMissionFailMessage == 1 then
			MissionFail(false, true, "3_S03_FAIL_01")
		elseif gMissionFailMessage == 2 then
			MissionFail(false, true, "3_S03_FAIL_02")
		elseif gMissionFailMessage == 3 then
			MissionFail(false, true, "3_S03_FAIL_03")
		else
			MissionFail(false)
		end
	elseif bMissionPassed then
		CameraSetWidescreen(true)
		CameraSetXYZ(171.68631, -5.171072, 6.315695, 170.90573, -5.758317, 6.528976)
		Wait(250)
		PlayerFaceHeadingNow(315)
		CameraFade(500, 1)
		Wait(501)
		MinigameSetCompletion("M_PASS", true, 6000)
		SoundPlayMissionEndMusic(true, 7)
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		CameraFade(500, 0)
		Wait(501)
		CameraReset()
		CameraReturnToPlayer(true)
		CameraSetWidescreen(false)
		MissionSucceed(false, false, false)
		Wait(500)
		CameraFade(500, 1)
		Wait(101)
		PlayerSetControl(1)
	end
	--print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_TableInit()
	--print("()xxxxx[:::::::::::::::> [start] F_TableInit()")
	pedGalloway = {
		spawn = POINTLIST._3_S03_SPAWNGALLOWAY,
		element = 1,
		model = 57
	}
	pedHattrick = {
		spawn = POINTLIST._3_S03_SPAWNHATTRICKALLEY,
		element = 1,
		model = 61
	}
	pedPrep = {
		spawn = POINTLIST._3_S03_SPAWNPREPAUTO,
		element = 1,
		model = 34
	}
	pedPoolPrep = {
		spawn = POINTLIST._3_S03_SPAWNPREPPOOL,
		element = 1,
		model = 34
	}
	pedGreaser01 = {
		spawn = POINTLIST._3_S03_SPAWNGREASERAUTO01,
		element = 1,
		model = 27
	}
	pedGreaser02 = {
		spawn = POINTLIST._3_S03_SPAWNGREASERAUTO02,
		element = 1,
		model = 26
	}
	pedJock = {
		spawn = POINTLIST._3_S03_SPAWNJOCKPOOL,
		element = 1,
		model = 17
	}
	pedMandy = {
		spawn = POINTLIST._3_S03_SPAWNMANDYPOOL,
		element = 1,
		model = 14
	}
	pedCrabbleSnitch = {
		spawn = POINTLIST._3_S03_OUTROCRABBLESNITCH,
		element = 1,
		model = 65
	}
	--print("()xxxxx[:::::::::::::::> [finish] F_TableInit()")
end

function F_SetupMission()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupMission()")
	F_TableInit()
	F_PedLoadModels()
	LoadAnimationGroup("NIS_3_S03")
	LoadActionTree("Act/Conv/3_S03.act")
	LoadActionTree("Act/Gifts/NIS_3_S03_GiveCas.act")
	LoadActionTree("Act/Gifts/NIS_3_S03_GiveHat.act")
	LoadActionTree("Act/Gifts/NIS_3_S03_GiveVan.act")
	WeaponRequestModel(327)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupMission()")
end

function F_Stage1()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
	F_Stage1_Setup()
	F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
	F_SetupGalloway()
	CreateThread("T_HandleGalloway")
	blipGreaserObjective = BlipAddPoint(POINTLIST._3_S03_OBJECTIVEGREASER, 29, 1, 1, 7)
	if IsMissionFromDebug() then
		AreaTransitionPoint(0, POINTLIST._3_S03_SPAWNPLAYER)
	end
	F_ShowCounter()
	CameraFade(500, 1)
	Wait(500)
	TextPrint("3_S03_MOBJ_01", 3, 1)
	gObjective01 = MissionObjectiveAdd("3_S03_MOBJ_01")
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
	while bLoop do
		F_Stage1_Objectives()
		if bMissionFailed then
			break
		end
		if bGoToStage2 then
			F_Stage2()
			break
		end
		Wait(0)
	end
end

function F_Stage2()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2()")
	F_Stage2_Setup()
	F_Stage2_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2()")
end

function F_Stage2_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage2_Setup()")
	blipJockObjective = BlipAddPoint(POINTLIST._3_S03_OBJECTIVEJOCK, 0, 1, 1, 7)
	MissionObjectiveComplete(gObjective02)
	TextPrint("3_S03_MOBJ_03", 3, 1)
	gObjective03 = MissionObjectiveAdd("3_S03_MOBJ_03")
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
	while bLoop do
		F_Stage2_Objectives()
		if bMissionFailed then
			break
		end
		if bGoToStage3 then
			F_Stage3()
			break
		end
		Wait(0)
	end
end

function F_Stage3()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage3()")
	F_Stage3_Setup()
	F_Stage3_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage3()")
end

function F_Stage3_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage3_Setup()")
	MissionObjectiveComplete(gObjective05)
	TextPrint("3_S03_MOBJ_06", 3, 1)
	gObjective06 = MissionObjectiveAdd("3_S03_MOBJ_06")
	pedPrep.id = PedCreatePoint(pedPrep.model, POINTLIST._3_S03_SPAWNPREPALLEY, pedPrep.element)
	PedSetMissionCritical(pedPrep.id, true, F_MissionCriticalPrep, true)
	PedSetFlag(pedPrep.id, 108, true)
	PedSetFlag(pedPrep.id, 117, false)
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage3_Setup()")
end

function F_Stage3_Loop()
	while bLoop do
		F_Stage3_Objectives()
		if bMissionFailed then
			break
		end
		if bGoToStage4 then
			F_Stage4()
			break
		end
		Wait(0)
	end
end

function F_Stage4()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage4()")
	F_Stage4_Setup()
	F_Stage4_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage4()")
end

function F_Stage4_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage4_Setup()")
	MissionObjectiveComplete(gObjective07)
	TextPrint("3_S03_MOBJ_08", 3, 1)
	gObjective08 = MissionObjectiveAdd("3_S03_MOBJ_08")
	pedGalloway.blip = BlipAddPoint(POINTLIST._3_S03_SPAWNGALLOWAY, 0, 1, 1, 7)
	F_HideCounter()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage4_Setup()")
end

function F_Stage4_Loop()
	while bLoop do
		F_Stage4_Objectives()
		if bMissionFailed then
			break
		end
		if bMissionPassed then
			break
		end
		Wait(0)
	end
end

function F_StartAtStage2()
	--print("()xxxxx[:::::::::::::::> [start] F_StartAtStage2()")
	F_PedLoadModels()
	AreaTransitionPoint(13, POINTLIST._3_S03_DEBUGSPAWNPLAYERSTAGE2)
	gObjective01 = MissionObjectiveAdd("3_S03_MOBJ_01")
	gObjective02 = MissionObjectiveAdd("3_S03_MOBJ_02")
	MissionObjectiveComplete(gObjective01)
	F_ShowCounter()
	CounterSetCurrent(1)
	CameraFade(500, 1)
	Wait(500)
	F_Stage2()
	--print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage2()")
end

function F_StartAtStage3()
	--print("()xxxxx[:::::::::::::::> [start] F_StartAtStage3()")
	F_PedLoadModels()
	AreaTransitionPoint(0, POINTLIST._3_S03_DEBUGSPAWNPLAYERSTAGE3)
	gObjective01 = MissionObjectiveAdd("4_01_MOBJ_01")
	MissionObjectiveComplete(gObjective01)
	gObjective02 = MissionObjectiveAdd("4_01_MOBJ_02")
	MissionObjectiveComplete(gObjective02)
	gObjective03 = MissionObjectiveAdd("4_01_MOBJ_03")
	MissionObjectiveComplete(gObjective03)
	gObjective04 = MissionObjectiveAdd("4_01_MOBJ_04")
	MissionObjectiveComplete(gObjective04)
	gObjective05 = MissionObjectiveAdd("4_01_MOBJ_05")
	F_ShowCounter()
	CounterSetCurrent(2)
	CameraFade(500, 1)
	Wait(500)
	F_Stage3()
	--print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage3()")
end

function F_StartAtStage4()
	--print("()xxxxx[:::::::::::::::> [start] F_StartAtStage4()")
	gObjective07 = MissionObjectiveAdd("3_S03_MOBJ_07")
	F_PedLoadModels()
	AreaTransitionPoint(0, POINTLIST._3_S03_DEBUGSPAWNPLAYERSTAGE4)
	CameraFade(500, 1)
	Wait(500)
	F_Stage4()
	--print("()xxxxx[:::::::::::::::> [finish] F_StartAtStage4()")
end

function F_Stage1_Objectives() -- ! Modified
	if not bArrivedAtGreasers then
		if PlayerIsInTrigger(TRIGGER._3_S03_OBJECTIVEGREASER) then
			BlipRemove(blipGreaserObjective)
			F_NIS_Greaser()
			blipGreaser = AddBlipForChar(pedGreaser01.id, 4, 0, 4, 0)
			MissionObjectiveComplete(gObjective01)
			TextPrint("3_S03_MOBJ_02", 3, 1)
			gObjective02 = MissionObjectiveAdd("3_S03_MOBJ_02")
			F_StartTimer(15)
			PedLockTarget(pedGreaser01.id, pedPrep.id, 3)
			PedLockTarget(pedPrep.id, pedGreaser01.id, 3)
			PedSetActionNode(pedPrep.id, "/Global/NIS_3_S03_GiveVan/Give_Attempt", "Act/Gifts/NIS_3_S03_GiveVan.act")
			SoundPlayInteractiveStream("MS_StealthLow.rsm", 0.35)
			SoundSetMidIntensityStream("MS_StealthMid.rsm", 0.4)
			SoundSetHighIntensityStream("MS_StealthHigh.rsm", 0.5)
			bArrivedAtGreasers = true
		end
	else
		if MissionTimerHasFinished() or PlayerIsInTrigger(TRIGGER._3_S03_FAILGREASER) then
			if PlayerIsInTrigger(TRIGGER._3_S03_FAILGREASER) then
				gMissionFailMessage = 2
				PedAttackPlayer(pedGreaser01.id, 3)
				PedAttackPlayer(pedGreaser02.id, 3)
				SoundPlayScriptedSpeechEvent(pedPrep.id, "M_3_S03", 61, "large", false, true)
			else
				gMissionFailMessage = 1
			end
			PedMakeAmbient(pedGreaser01.id)
			PedMakeAmbient(pedGreaser02.id)
			PedFlee(pedPrep.id, gPlayer)
			PedMakeAmbient(pedPrep.id)
			bMissionFailed = true
		end
		if not bPicGreaser then
			validGreaserTarget = false
			wasValidTarget = L25_1 -- Added this
			if PhotoTargetInFrame(pedPrep.id, 2) then
				--print("()xxxxx[:::::::::::::::> [photo loop] greaser is valid")
				validGreaserTarget = true
			end
			L25_1 = validGreaserTarget -- Added this
			PhotoSetValid(validGreaserTarget)
			photohasbeentaken, wasValid = PhotoHasBeenTaken()
			joshLazyHack = validGreaserTarget or wasValidTarget -- Added this
			--[[
			if photohasbeentaken and wasValid and validGreaserTarget then
			]] -- Modified to:
			if photohasbeentaken and wasValid and joshLazyHack then
				CounterSetCurrent(1)
				F_DisperseGreaser()
				F_StopTimer()
				bPicGreaser = true
				L25_1 = false -- Added this
				bGoToStage2 = true
			end
		end
	end
end

function F_Stage2_Objectives() -- ! Modified
	if not bArrivedInPool and PlayerIsInTrigger(TRIGGER._3_S03_POOLAREA) then
		MissionObjectiveComplete(gObjective03)
		gObjective04 = MissionObjectiveAdd("3_S03_MOBJ_04")
		TextPrint("3_S03_MOBJ_04", 4, 1)
		bArrivedInPool = true
	end
	if not bArrivedAtJocks then
		if PlayerIsInTrigger(TRIGGER._3_S03_OBJECTIVEPOOL) then
			BlipRemove(blipJockObjective)
			F_NIS_Jock()
			blipJock = AddBlipForChar(pedJock.id, 2, 0, 4, 0)
			MissionObjectiveComplete(gObjective04)
			TextPrint("3_S03_MOBJ_05", 3, 1)
			gObjective05 = MissionObjectiveAdd("3_S03_MOBJ_05")
			F_StartTimer(15)
			PedLockTarget(pedJock.id, pedPoolPrep.id, 3)
			PedLockTarget(pedPoolPrep.id, pedJock.id, 3)
			PedSetActionNode(pedPoolPrep.id, "/Global/NIS_3_S03_GiveCas/Give_Attempt", "Act/Gifts/NIS_3_S03_GiveCas.act")
			bArrivedAtJocks = true
		end
	else
		if MissionTimerHasFinished() or PlayerIsInTrigger(TRIGGER._3_S03_FAILPOOL) then
			if PlayerIsInTrigger(TRIGGER._3_S03_FAILPOOL) then
				gMissionFailMessage = 2
				PedAttackPlayer(pedJock.id, 3)
				SoundPlayScriptedSpeechEvent(pedPrep.id, "M_3_S03", 61, "large", false, true)
			else
				gMissionFailMessage = 1
			end
			PedMakeAmbient(pedJock.id)
			PedMakeAmbient(pedMandy.id)
			PedFlee(pedPoolPrep.id, gPlayer)
			PedMakeAmbient(pedPoolPrep.id)
			bMissionFailed = true
		end
		if not bPicJock then
			validJockTarget = false
			wasValidTarget = L25_1 -- Added this
			if PhotoTargetInFrame(pedPoolPrep.id, 2) then
				--print("()xxxxx[:::::::::::::::> [photo loop] jock is valid")
				validJockTarget = true
			end
			L25_1 = validJockTarget -- Added this
			PhotoSetValid(validJockTarget)
			photohasbeentaken, wasValid = PhotoHasBeenTaken()
			joshLazyHack = validJockTarget or wasValidTarget -- Added this
			--[[
			if photohasbeentaken and wasValid and validJockTarget then
			]] -- Modified to:
			if photohasbeentaken and wasValid and joshLazyHack then
				CounterSetCurrent(2)
				F_DisperseJock()
				F_StopTimer()
				bPicJock = true
				L25_1 = false -- Added this
				bGoToStage3 = true
			end
		end
	end
end

function F_Stage3_Objectives() -- ! Modified
	if bDeletePoolPrep then
		if F_PedExists(pedPoolPrep.id) then
			PedDelete(pedPoolPrep.id)
		end
		bDeletePoolPrep = false
	end
	if not bRemovedPoolExitBlip and AreaGetVisible() == 0 then
		bDeletePoolPrep = true
		PedFaceObject(gPlayer, pedPrep.id, 2, 0)
		CameraReset()
		BlipRemove(blipPoolExit)
		CreateThread("T_LaunchAlleyPrep")
		bRemovedPoolExitBlip = true
	end
	if not bArrivedAtHattrick then
		if PlayerIsInTrigger(TRIGGER._3_S03_OBJECTIVEALLEY) then
			PedSetMissionCritical(pedPrep.id, false)
			PedSetInvulnerable(pedPrep.id, true)
			BlipRemove(pedPrep.blip)
			F_NIS_Hattrick()
			CreateThread("T_HattrickConversation")
			pedHattrick.blip = AddBlipForChar(pedHattrick.id, 2, 0, 4, 0)
			MissionObjectiveComplete(gObjective06)
			TextPrint("3_S03_MOBJ_07", 3, 1)
			gObjective07 = MissionObjectiveAdd("3_S03_MOBJ_07")
			F_StartTimer(15)
			PedLockTarget(pedHattrick.id, pedPrep.id, 3)
			PedLockTarget(pedPrep.id, pedHattrick.id, 3)
			PedSetActionNode(pedPrep.id, "/Global/NIS_3_S03_GiveHat/Give_Attempt", "Act/Gifts/NIS_3_S03_GiveHat.act")
			bArrivedAtHattrick = true
		end
	else
		if MissionTimerHasFinished() or PlayerIsInTrigger(TRIGGER._3_S03_FAILALLEY) then
			if PlayerIsInTrigger(TRIGGER._3_S03_FAILALLEY) then
				gMissionFailMessage = 2
				SoundPlayScriptedSpeechEventWrapper(pedHattrick.id, "M_3_S03", 46, "large")
				PedAttackPlayer(pedHattrick.id, 3)
			else
				gMissionFailMessage = 1
			end
			PedMakeAmbient(pedHattrick.id)
			PedFlee(pedPrep.id, gPlayer)
			PedMakeAmbient(pedPrep.id)
			bMissionFailed = true
		end
		if not bPicHattrick then
			validHattrickTarget = false
			wasValidTarget = L25_1 -- Added this
			if PhotoTargetInFrame(pedHattrick.id, 2) then
				--print("()xxxxx[:::::::::::::::> [photo loop] hattrick is valid")
				validHattrickTarget = true
			end
			L25_1 = validHattrickTarget -- Added this
			PhotoSetValid(validHattrickTarget)
			photohasbeentaken, wasValid = PhotoHasBeenTaken()
			joshLazyHack = validHattrickTarget or wasValidTarget
			--[[
			if photohasbeentaken and wasValid and validHattrickTarget then
			--]] -- Modified to:
			if photohasbeentaken and wasValid and joshLazyHack then
				CounterSetCurrent(3)
				F_DisperseHattrick()
				F_StopTimer()
				bPicHattrick = true
				bGoToStage4 = true
			end
		end
	end
end

function F_Stage4_Objectives()
	if not bPrepAttackedPlayer and PedIsValid(pedPrep.id) and PedCanSeeObject(pedPrep.id, gPlayer, 3) then
		PedStop(pedPrep.id)
		PedClearObjectives(pedPrep.id)
		SoundPlayAmbientSpeechEvent(pedPrep.id, "TAUNT")
		PedAttackPlayer(pedPrep.id, 3)
		bPrepAttackedPlayer = true
	end
	if PlayerIsInTrigger(TRIGGER._3_S03_PARKINGLOT) then
		BlipRemove(pedGalloway.blip)
		F_NIS_Outro()
		bMissionPassed = true
	end
end

function F_SetupGalloway()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupGalloway()")
	pedGalloway.id = PedCreatePoint(pedGalloway.model, pedGalloway.spawn, pedGalloway.element)
	PedSetMissionCritical(pedGalloway.id, true, F_MissionCriticalGalloway, true)
	PedSetFaction(pedGalloway.id, 9)
	PedSetActionNode(pedGalloway.id, "/Global/3_S03/3_S03_Givebottle/GiveBottle", "Act/Conv/3_S03.act")
	PedFollowPath(pedGalloway.id, PATH._3_S03_GALLOWAY, 0, 0)
	bGallowaySpawned = true
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupGalloway()")
end

function F_DeleteGalloway()
	--print("()xxxxx[:::::::::::::::> [start] F_DeleteGalloway()")
	PedSetMissionCritical(pedGalloway.id, false)
	PedDelete(pedGalloway.id)
	bGallowaySpawned = false
	--print("()xxxxx[:::::::::::::::> [finish] F_DeleteGalloway()")
end

function F_ShowCounter()
	--print("()xxxxx[:::::::::::::::> [start] F_ShowCounter()")
	CounterClearText()
	CounterSetCurrent(0)
	CounterSetMax(3)
	CounterSetIcon("HUDIcon_photos", "HUDIcon_photos_x")
	CounterMakeHUDVisible(true)
	--print("()xxxxx[:::::::::::::::> [finish] F_ShowCounter()")
end

function F_HideCounter()
	--print("()xxxxx[:::::::::::::::> [start] F_HideCounter()")
	CounterClearIcon()
	CounterMakeHUDVisible(false)
	--print("()xxxxx[:::::::::::::::> [finish] F_HideCounter()")
end

function F_DisperseGreaser()
	--print("()xxxxx[:::::::::::::::> [start] F_DisperseGreaser()")
	BlipRemove(blipGreaser)
	PedSetMissionCritical(pedPrep.id, false)
	PedSetMissionCritical(pedGreaser01.id, false)
	PedSetMissionCritical(pedGreaser02.id, false)
	SoundPlayScriptedSpeechEvent(pedPrep.id, "M_3_S03", 60, "large", false, true)
	PedMakeAmbient(pedPrep.id)
	PedMakeAmbient(pedGreaser01.id)
	PedMakeAmbient(pedGreaser02.id)
	--print("()xxxxx[:::::::::::::::> [finish] F_DisperseGreaser()")
end

function F_DisperseJock()
	--print("()xxxxx[:::::::::::::::> [start] F_DisperseJock()")
	BlipRemove(blipJock)
	PedSetMissionCritical(pedJock.id, false)
	PedSetMissionCritical(pedMandy.id, false)
	PedSetMissionCritical(pedPoolPrep.id, false)
	SoundPlayScriptedSpeechEvent(pedPoolPrep.id, "M_3_S03", 60, "large", false, true)
	PedMakeAmbient(pedJock.id)
	PedMakeAmbient(pedMandy.id)
	PedFollowPath(pedPoolPrep.id, PATH._3_S03_PREPLEAVEPOOL, 0, 0, F_CleanupPoopPrep)
	blipPoolExit = BlipAddPoint(POINTLIST._3_S03_BLIPPOOLEXIT, 0, 1, 1)
	--print("()xxxxx[:::::::::::::::> [finish] F_DisperseJock()")
end

function F_DisperseHattrick()
	--print("()xxxxx[:::::::::::::::> [start] F_DisperseHattrick()")
	F_NIS_DealDone()
	--print("()xxxxx[:::::::::::::::> [finish] F_DisperseHattrick()")
end

function F_StartTimer(timeInSeconds)
	--print("()xxxxx[:::::::::::::::> [start] F_StartTimer()")
	MissionTimerStart(timeInSeconds)
	--print("()xxxxx[:::::::::::::::> [finish] F_StartTimer()")
end

function F_StopTimer()
	--print("()xxxxx[:::::::::::::::> [start] F_StopTimer()")
	MissionTimerStop()
	--print("()xxxxx[:::::::::::::::> [finish] F_StopTimer()")
end

function F_PedLoadModels()
	--print("()xxxxx[:::::::::::::::> [start] F_PedLoadModels()")
	PedRequestModel(57)
	PedRequestModel(61)
	PedRequestModel(34)
	PedRequestModel(29)
	PedRequestModel(26)
	PedRequestModel(17)
	--print("()xxxxx[:::::::::::::::> [finish] F_PedLoadModels()")
end

function F_ResetCamera()
	--print("()xxxxx[:::::::::::::::> [start] F_ResetCamera()")
	if PlayerHasItem(426) then
		PedSetWeaponNow(gPlayer, 426, 1)
		--print("()xxxxx[:::::::::::::::> [camera] putting camera in players hand")
	elseif PlayerHasItem(328) then
		PedSetWeaponNow(gPlayer, 328, 1)
		--print("()xxxxx[:::::::::::::::> [camera] putting camera in players hand")
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_ResetCamera()")
end

function F_WaitForSpeech(pedID)
	--print("()xxxxx[:::::::::::::::> [start] F_WaitForSpeech()")
	if pedID == nil then
		while SoundSpeechPlaying() do
			Wait(0)
		end
	else
		while SoundSpeechPlaying(pedID) do
			Wait(0)
		end
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_WaitForSpeech()")
end

function F_NIS_Greaser()
	--print("()xxxxx[:::::::::::::::> [start] F_NIS_Greaser()")
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	PlayerSetControl(0)
	CameraFade(500, 0)
	Wait(500)
	PedSetTypeToTypeAttitude(4, 5, 4)
	pedPrep.id = PedCreatePoint(pedPrep.model, pedPrep.spawn, pedPrep.element)
	pedGreaser01.id = PedCreatePoint(pedGreaser01.model, pedGreaser01.spawn, pedGreaser01.element)
	pedGreaser02.id = PedCreatePoint(pedGreaser02.model, pedGreaser02.spawn, pedGreaser02.element)
	PedSetMissionCritical(pedPrep.id, true, F_MissionCriticalGreaser, true)
	PedSetMissionCritical(pedGreaser01.id, true, F_MissionCriticalGreaser, true)
	PedSetMissionCritical(pedGreaser02.id, true, F_MissionCriticalGreaser, true)
	PedIgnoreStimuli(pedPrep.id, true)
	PedIgnoreStimuli(pedGreaser01.id, true)
	PedIgnoreStimuli(pedGreaser02.id, true)
	PedClearAllWeapons(pedGreaser01.id)
	PedClearAllWeapons(pedGreaser02.id)
	CameraSetFOV(40)
	CameraSetXYZ(114.8016, -3.185778, 7.536414, 115.24289, -2.292768, 7.4498)
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	CameraFade(500, 1)
	PedSetActionNode(pedGreaser01.id, "/Global/3_S03/NIS/Cheaters/Greasers/Vance/VanceWait", "Act/Conv/3_S03.act")
	PedSetActionNode(pedGreaser02.id, "/Global/3_S03/NIS/Cheaters/Greasers/Lucky/LuckyWait", "Act/Conv/3_S03.act")
	PedMoveToPoint(pedPrep.id, 0, POINTLIST._3_S03_PREPMOVETO, 1)
	Wait(2000)
	CameraSetFOV(40)
	CameraSetXYZ(119.42189, 3.565211, 7.872099, 118.644585, 2.942935, 7.786284)
	SoundPlayScriptedSpeechEvent(pedPrep.id, "M_3_S03", 59, "large", true)
	F_WaitForSpeech(pedPrep.id)
	Wait(1500)
	CameraSetFOV(40)
	CameraSetXYZ(115.739494, 1.333625, 7.967975, 116.65231, 1.705655, 7.800253)
	SoundPlayScriptedSpeechEventWrapper(pedGreaser01.id, "M_3_S03", 8, "large")
	PedSetActionNode(pedGreaser01.id, "/Global/3_S03/Empty", "Act/Conv/3_S03.act")
	PedLockTarget(pedGreaser01.id, pedPrep.id, 3)
	Wait(1500)
	F_WaitForSpeech(pedGreaser01.id)
	CameraFade(500, 0)
	Wait(500)
	PlayerSetPosPoint(POINTLIST._3_S03_FACETARGETGREASER)
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
	CameraReset()
	F_ResetCamera()
	CameraFade(500, 1)
	Wait(500)
	PlayerSetControl(1)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	--print("()xxxxx[:::::::::::::::> [finish] F_NIS_Greaser()")
end

function F_NIS_Jock()
	--print("()xxxxx[:::::::::::::::> [start] F_NIS_Jock()")
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	PlayerSetControl(0)
	CameraFade(500, 0)
	Wait(500)
	local tempx, tempy, tempz = 0, 0, 0
	tempx, tempy, tempz = GetPointList(POINTLIST._3_S03_FACETARGETPOOL)
	PlayerSetPosSimple(tempx, tempy, tempz)
	pedPoolPrep.id = PedCreatePoint(pedPoolPrep.model, pedPoolPrep.spawn, pedPoolPrep.element)
	pedJock.id = PedCreatePoint(pedJock.model, pedJock.spawn, pedJock.element)
	pedMandy.id = PedCreatePoint(pedMandy.model, pedMandy.spawn, pedMandy.element)
	PedSetMissionCritical(pedPoolPrep.id, true, F_MissionCriticalJock, true)
	PedSetMissionCritical(pedJock.id, true, F_MissionCriticalJock, true)
	PedSetMissionCritical(pedMandy.id, true, F_MissionCriticalJock, true)
	PedIgnoreStimuli(pedPoolPrep.id, true)
	PedIgnoreStimuli(pedJock.id, true)
	PedIgnoreStimuli(pedMandy.id, true)
	PedClearAllWeapons(pedPoolPrep.id)
	CameraSetFOV(40)
	CameraSetXYZ(-673.4522, -77.59752, 60.815228, -673.08075, -76.67007, 60.845833)
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	CameraFade(500, 1)
	PedSetActionNode(pedJock.id, "/Global/3_S03/NIS/Cheaters/Jocks/Casey/CaseyWait", "Act/Conv/3_S03.act")
	PedSetActionNode(pedMandy.id, "/Global/3_S03/NIS/Cheaters/Jocks/Mandy/MandyWait", "Act/Conv/3_S03.act")
	SoundPlayScriptedSpeechEvent(pedJock.id, "M_3_S03", 21, "large", true)
	F_WaitForSpeech(pedJock.id)
	SoundPlayScriptedSpeechEvent(pedMandy.id, "M_3_S03", 20, "large", true)
	F_WaitForSpeech(pedMandy.id)
	PedFollowPath(pedPoolPrep.id, PATH._3_S03_PREPPOOL, 0, 0)
	Wait(250)
	CameraSetFOV(40)
	CameraSetXYZ(-672.54285, -72.07847, 61.49709, -672.4946, -73.066826, 61.355545)
	SoundPlayScriptedSpeechEvent(pedPoolPrep.id, "M_3_S03", 59, "large", true)
	F_WaitForSpeech(pedPoolPrep.id)
	SoundPlayScriptedSpeechEvent(pedJock.id, "M_3_S03", 62, "large", true)
	F_WaitForSpeech(pedJock.id)
	CameraFade(500, 0)
	Wait(500)
	PedSetActionNode(pedJock.id, "/Global/3_S03/Empty", "Act/Conv/3_S03.act")
	PedSetActionNode(pedMandy.id, "/Global/3_S03/Empty", "Act/Conv/3_S03.act")
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
	CameraReset()
	F_ResetCamera()
	CameraFade(500, 1)
	Wait(500)
	PlayerSetControl(1)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	--print("()xxxxx[:::::::::::::::> [finish] F_NIS_Jock()")
end

function F_NIS_Hattrick()
	--print("()xxxxx[:::::::::::::::> [start] F_NIS_Hattrick()")
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	PlayerSetControl(0)
	CameraFade(500, 0)
	Wait(500)
	pedHattrick.id = PedCreatePoint(pedHattrick.model, pedHattrick.spawn, pedHattrick.element)
	PedSetMissionCritical(pedHattrick.id, true, F_MissionCriticalHattrick, true)
	PedSetMissionCritical(pedPrep.id, true, F_MissionCriticalHattrick, true)
	PedIgnoreStimuli(pedPrep.id, true)
	PedIgnoreStimuli(pedHattrick.id, true)
	PedStop(pedPrep.id)
	PedClearObjectives(pedPrep.id)
	PedSetPosPoint(pedPrep.id, POINTLIST._3_S03_SPAWNPREPALLEYCUT, 1)
	PedMoveToPoint(pedPrep.id, 0, POINTLIST._3_S03_PREPHATTRICKMOVETO, 1)
	CameraSetFOV(40)
	CameraSetXYZ(67.58179, -107.81211, 8.252475, 68.45856, -108.29146, 8.242161)
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	CameraFade(500, 1)
	Wait(500)
	SoundPlayScriptedSpeechEventWrapper(pedPrep.id, "M_3_S03", 35, "large")
	F_WaitForSpeech(pedPrep.id)
	CameraSetFOV(40)
	CameraSetXYZ(70.242256, -111.081474, 8.784476, 71.234665, -111.14678, 8.680552)
	PedSetActionNode(pedHattrick.id, "/Global/3_S03/NIS/Cheaters/Hattrick/Hattrick01", "Act/Conv/3_S03.act")
	SoundPlayScriptedSpeechEventWrapper(pedHattrick.id, "M_3_S03", 14, "large")
	F_WaitForSpeech(pedHattrick.id)
	PedSetActionNode(pedPrep.id, "/Global/NIS_3_S03_GiveHat/Give/Give/PrepIdle", "Act/Conv/3_S03.act")
	CameraFade(500, 0)
	Wait(500)
	PedSetInvulnerable(pedPrep.id, false)
	PlayerSetPosPoint(POINTLIST._3_S03_FACETARGETALLEY)
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
	CameraReset()
	F_ResetCamera()
	CameraFade(500, 1)
	Wait(500)
	PlayerSetControl(1)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	--print("()xxxxx[:::::::::::::::> [finish] F_NIS_Hattrick()")
end

function F_NIS_DealDone()
	--print("()xxxxx[:::::::::::::::> [start] F_NIS_DealDone()")
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	PlayerSetControl(0)
	CameraFade(500, 0)
	Wait(500)
	CameraSetFOV(40)
	CameraSetXYZ(67.58179, -107.81211, 8.252475, 68.45856, -108.29146, 8.242161)
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	PedSetActionNode(pedPrep.id, "/Global/3_S03/Empty", "Act/Conv/3_S03.act")
	PedSetActionNode(pedHattrick.id, "/Global/3_S03/Empty", "Act/Conv/3_S03.act")
	CameraFade(500, 1)
	Wait(500)
	PedFollowPath(pedPrep.id, PATH._3_S03_DEALDONEPREPLEAVE, 0, 0)
	SoundPlayScriptedSpeechEventWrapper(pedHattrick.id, "M_3_S03", 19, "large")
	Wait(1500)
	PedMoveToPoint(pedHattrick.id, 0, POINTLIST._3_S03_SPAWNHATTRICKALLEY, 2)
	Wait(5000)
	CameraFade(500, 0)
	Wait(500)
	PedSetMissionCritical(pedPrep.id, false)
	PedSetMissionCritical(pedHattrick.id, false)
	PedDelete(pedHattrick.id)
	PedMakeAmbient(pedPrep.id)
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
	CameraReset()
	F_ResetCamera()
	CameraFade(500, 1)
	Wait(500)
	PlayerSetControl(1)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	--print("()xxxxx[:::::::::::::::> [finish] F_NIS_DealDone()")
end

function F_NIS_Outro()
	--print("()xxxxx[:::::::::::::::> [start] F_NIS_Outro()")
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	PlayerSetControl(0)
	CameraFade(500, 0)
	Wait(501)
	if PlayerIsInAnyVehicle() then
		PlayerDetachFromVehicle()
	end
	F_MakePlayerSafeForNIS(true)
	SoundDisableSpeech_ActionTree()
	CameraSetWidescreen(true)
	LoadAnimationGroup("NIS_3_S03_B")
	pedCrabbleSnitch.id = PedCreatePoint(pedCrabbleSnitch.model, pedCrabbleSnitch.spawn, pedCrabbleSnitch.element)
	pedGalloway.id = PedCreatePoint(pedGalloway.model, POINTLIST._3_S03_OUTROGALLOWAY, 1)
	pedHattrick.id = PedCreatePoint(pedHattrick.model, POINTLIST._3_S03_OUTROHATTRICK, 1)
	WeaponRequestModel(361)
	PedClearObjectives(gPlayer)
	PedStop(gPlayer)
	Wait(1)
	local tempX, tempY, tempZ = GetPointList(POINTLIST._3_S03_OUTROJIMMY)
	PlayerSetPosSimple(tempX, tempY, tempZ)
	PedFaceObjectNow(gPlayer, pedCrabbleSnitch.id, 2)
	--print("LSDFMLKSMDLFKMSDKFMSLKDMF!!!")
	PedSetActionNode(pedHattrick.id, "/Global/3_S03/NIS/Hattrick/Hattrick01", "Act/Conv/3_S03.act")
	PedSetActionNode(pedCrabbleSnitch.id, "/Global/3_S03/NIS/Crabble/Crabble01", "Act/Conv/3_S03.act")
	PedSetActionNode(gPlayer, "/Global/3_S03/NIS/Player/Player01", "Act/Conv/3_S03.act")
	PedSetActionNode(pedGalloway.id, "/Global/3_S03/NIS/Galloway/Galloway01", "Act/Conv/3_S03.act")
	CameraSetFOV(30)
	CameraSetXYZ(171.65514, -9.538472, 7.243635, 171.08614, -8.716345, 7.255291)
	SoundPlayScriptedSpeechEvent(pedHattrick.id, "M_3_S03", 48, "medium")
	Wait(100)
	CameraFade(500, 1)
	F_WaitForSpeech(pedHattrick.id)
	CameraSetFOV(30)
	SoundPlayScriptedSpeechEvent(pedCrabbleSnitch.id, "M_3_S03", 49, "medium")
	Wait(2000)
	CameraSetFOV(30)
	CameraSetXYZ(169.10414, -3.296641, 7.142729, 169.20985, -4.289656, 7.188948)
	Wait(3000)
	CameraSetFOV(30)
	CameraSetXYZ(171.04077, -8.875181, 7.503707, 170.47609, -8.051736, 7.449919)
	F_WaitForSpeech(pedCrabbleSnitch.id)
	CameraSetFOV(30)
	CameraSetXYZ(165.70955, -8.52017, 7.402529, 166.57417, -8.022421, 7.335853)
	SoundPlayScriptedSpeechEvent(gPlayer, "M_3_S03", 50, "medium")
	F_WaitForSpeech(gPlayer)
	CameraSetFOV(30)
	SoundPlayScriptedSpeechEvent(pedCrabbleSnitch.id, "M_3_S03", 51, "medium")
	F_WaitForSpeech(pedCrabbleSnitch.id)
	CameraSetFOV(30)
	SoundPlayScriptedSpeechEvent(gPlayer, "M_3_S03", 52, "medium")
	F_WaitForSpeech(gPlayer)
	CameraSetFOV(30)
	CameraSetXYZ(171.75958, -8.031951, 7.249989, 171.08676, -7.292189, 7.25409)
	SoundPlayScriptedSpeechEvent(pedHattrick.id, "M_3_S03", 53, "medium")
	F_WaitForSpeech(pedHattrick.id)
	SoundPlayScriptedSpeechEvent(pedCrabbleSnitch.id, "M_3_S03", 54, "medium")
	F_WaitForSpeech(pedCrabbleSnitch.id)
	SoundPlayScriptedSpeechEvent(pedHattrick.id, "M_3_S03", 55, "medium")
	F_WaitForSpeech(pedHattrick.id)
	CameraSetXYZ(169.54396, -2.814726, 6.951551, 169.49521, -3.811324, 7.015233)
	SoundPlayScriptedSpeechEvent(gPlayer, "M_3_S03", 56, "medium")
	F_WaitForSpeech(gPlayer)
	SoundPlayScriptedSpeechEvent(pedCrabbleSnitch.id, "M_3_S03", 57, "medium")
	Wait(3000)
	CameraSetFOV(30)
	CameraSetXYZ(171.33061, -9.167021, 7.287096, 170.71982, -8.375427, 7.298646)
	F_WaitForSpeech(pedCrabbleSnitch.id)
	PedSetActionNode(pedGalloway.id, "/Global/3_S03/Empty", "Act/Conv/3_S03.act")
	PedSetActionNode(pedCrabbleSnitch.id, "/Global/3_S03/Empty", "Act/Conv/3_S03.act")
	PedMoveToPoint(pedCrabbleSnitch.id, 0, POINTLIST._3_S03_SPAWNGALLOWAY, 1)
	Wait(500)
	PedMoveToPoint(pedGalloway.id, 0, POINTLIST._3_S03_SPAWNGALLOWAY, 1)
	Wait(1000)
	CameraFade(500, 0)
	Wait(500)
	SoundEnableSpeech_ActionTree()
	PedDelete(pedHattrick.id)
	PedDelete(pedCrabbleSnitch.id)
	PedDelete(pedGalloway.id)
	Wait(1000)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	SoundStopInteractiveStream(0)
	F_MakePlayerSafeForNIS(false)
	UnLoadAnimationGroup("NIS_3_S03_B")
	CameraReturnToPlayer()
	CameraReset()
	Wait(250)
	--print("()xxxxx[:::::::::::::::> [finish] F_NIS_Outro()")
end

function T_LaunchAlleyPrep()
	pedPrep.blip = AddBlipForChar(pedPrep.id, 5, 0, 4, 0)
	Wait(3000)
	PedFollowPath(pedPrep.id, PATH._3_S03_PREPALLEY01, 0, 0)
end

function T_HandleGalloway()
	while bLoop do
		if bGallowaySpawned then
			if not PlayerIsInTrigger(TRIGGER._3_S03_PARKINGLOT) then
				F_DeleteGalloway()
			end
		elseif PlayerIsInTrigger(TRIGGER._3_S03_PARKINGLOT) then
			F_SetupGalloway()
		end
		Wait(0)
	end
end

function T_HattrickConversation()
	SoundPlayScriptedSpeechEventWrapper(pedPrep.id, "M_3_S03", 37, "medium")
	F_WaitForSpeech(pedPrep.id)
	SoundPlayScriptedSpeechEventWrapper(pedPrep.id, "M_3_S03", 39, "medium")
end

function F_MissionCriticalPrep()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalPrep()")
	PedMakeAmbient(pedPrep.id)
	F_StopTimer()
	gMissionFailMessage = 2
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalPrep()")
end

function F_MissionCriticalGreaser()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalGreaser()")
	PedMakeAmbient(pedGreaser01.id)
	PedMakeAmbient(pedGreaser02.id)
	PedFlee(pedPrep.id, gPlayer)
	PedMakeAmbient(pedPrep.id)
	F_StopTimer()
	gMissionFailMessage = 2
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalGreaser()")
end

function F_MissionCriticalJock()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalJock()")
	PedMakeAmbient(pedJock.id)
	PedMakeAmbient(pedMandy.id)
	PedFlee(pedPoolPrep.id, gPlayer)
	PedMakeAmbient(pedPoolPrep.id)
	F_StopTimer()
	gMissionFailMessage = 2
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalJock()")
end

function F_MissionCriticalHattrick()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalHattrick()")
	PedMakeAmbient(pedHattrick.id)
	PedAttackPlayer(pedHattrick.id, 3)
	PedFlee(pedPrep.id, gPlayer)
	PedMakeAmbient(pedPrep.id)
	F_StopTimer()
	gMissionFailMessage = 2
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalHattrick()")
end

function F_MissionCriticalGalloway()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalGalloway()")
	PedSetFaction(pedGalloway.id, 8)
	PedMakeAmbient(pedGalloway.id)
	PedAttackPlayer(pedGalloway.id, 3)
	F_StopTimer()
	gMissionFailMessage = 3
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalGalloway()")
end

function F_CleanupPoopPrep(pedID, pathID, nodeID)
	--print("()xxxxx[:::::::::::::::> [start] F_CleanupPoopPrep()")
	if nodeID == 2 then
		bDeletePoolPrep = true
	end
	--print("()xxxxx[:::::::::::::::> [finish] F_CleanupPoopPrep()")
end
