--[[ Changes to this file:
	* Removed function call for GlobalImportScript (commented)
	* Modified function MissionStageBreakIntoTheLocker, may require testing
]]

ImportScript("Library/LibTable.lua")
ImportScript("Library/LibPed.lua")
local missionStage
local bFlagCheck1 = true
local bFlagCheck2 = true
local gStatusCheck1 = ""
local missionCondition = "Running"
local gLackey = {}
local gBeatrice, gObjectiveBlip
local gCurrentPed = 1
local gFatty
local bFountainCutscenePlayed = false
local bMissionRunning = false
local bLockerTutorial = true
local nTalkedWithBucky = 1
local bTalkedWithBeatrice = false
local nTalkedWithBeatrice = 1
local bReachedLocker = false
local nReachedLocker = 1
local bCheerleadersSpawned = false
local bDoneDrill = true
local gDoneCheerleading = false
local gPickedUpAnswerSheet = 0
local gPickedUpCake = 0
local gMandySpotted = false
local gCafPopOverride = false
local gMandy
local gCafeteriaIntro = false
local gGymnasiumCut = false
local gTimeEdnaTalked = 0
local gCurrentSpeech = 0
local gOutsidePool = true
local gPlayerFound = false
local gBreakIntoMessage = false
local gMissionObjective = {}
local gBook, gChocolate
local gNotInNIS = true
local bStanding = false
local bCheckForRigging = false
local gEdnaAfterPlayer = false
local gTurnEdnaIntoStealth = false
local sneakTutorial = false
local gNumStinkbombs = 0
local gNumPlayerChoc = 0
local gNumNotes = 0
local gLockerUsed = false
local numFatty, numBeatrice, numMandy
local bFireBathroomNIS = false
local gPrefectBlip
local bDropStinkBombs = false
local gStinkBombs
local bSpawnFatty = true
local gFattyOriginHealth = 0
local bGirlRanAway = false
--GlobalImportScript("Test/TNIS.lua")
local gDebugging = false
local bGotNotes = false
local bSuccessSoLoadHalloween = false
local bPlayerTalkedWithMandy = false
local bMusicPlaying = false
local bFattyIsFleeing = false
local bPlayerRiggedLocker = false
local bBeatriceWasHit = false
local bCoronaInLocker = false
local bLeftGym = false

function RequestActionTreeAndWait(actionTreeName)
	local ActionTreeIndex
	ActionTreeIndex = RequestActionTree(actionTreeName)
	if 0 < ActionTreeIndex then
		while not IsActionTreeLoaded(ActionTreeIndex) do
			--print("()xxxxx[:::::::::::::::> Waiting for " .. actionTreeName .. " action tree to load.")
			Wait(0)
		end
	end
end

function F_SetupNISOne()
	F_PlayIntroNIS()
	Wait(100)
	CameraFade(500, 1)
	Wait(500)
end

function F_SetupCafeteriaNIS()
	AreaTransitionPoint(2, POINTLIST._CAFRESTARTPOINT, 1)
	Wait(2000)
	CameraReturnToPlayer()
	local edna = PedCreatePoint(58, POINTLIST._EDNAPOINT, 1)
	F_SetupCafeteriaIntroCutscene()
	PedDelete(edna)
end

function F_DoFattyIntroDialogue()
	gDebugging = true
	AreaTransitionPoint(0, POINTLIST._PLAYERWITHFATTY, 4)
	gFatty = PedCreatePointWithAdjustedHeading(155, POINTLIST._BUCKYCUTSCENE, 1)
	gFattyOriginHealth = PedGetHealth(gFatty)
	PAnimSetActionNode(TRIGGER._BITCHDICE, "/Global/AniDice/DiceRolled/Rolled", "Act/Props/AniDice.act")
	PedSetActionNode(gFatty, "/Global/1_08/1_08_RollDice", "Act/Conv/1_08.act")
	PlayerSetControl(0)
	Wait(2000)
	ConversationMovePeds(false)
	Wait(1500)
	PedStartConversation("/Global/1_08/OpenCut/1_08_Nerdo", "Act/Conv/1_08.act", gPlayer, gFatty)
	while PedInConversation(gPlayer) do
		Wait(0)
	end
	ConversationMovePeds(true)
	PlayerSetControl(1)
	PedDelete(gFatty)
end

function F_DoFattyFailDialogue()
	gDebugging = true
	AreaTransitionPoint(0, POINTLIST._PLAYERWITHFATTY, 4)
	gFatty = PedCreatePointWithAdjustedHeading(155, POINTLIST._BUCKYCUTSCENE, 1)
	gFattyOriginHealth = PedGetHealth(gFatty)
	PAnimSetActionNode(TRIGGER._BITCHDICE, "/Global/AniDice/DiceRolled/Rolled", "Act/Props/AniDice.act")
	PlayerSetControl(0)
	Wait(2000)
	ConversationMovePeds(false)
	Wait(1500)
	PedStartConversation("/Global/1_08/OpenCut/1_08_NerdoNoCake", "Act/Conv/1_08.act", gPlayer, gFatty)
	while PedInConversation(gPlayer) do
		Wait(0)
	end
	ConversationMovePeds(true)
	PlayerSetControl(1)
	PedDelete(gFatty)
end

function F_DoFattySuccessDialogue()
	gDebugging = true
	AreaTransitionPoint(0, POINTLIST._PLAYERWITHFATTY, 4)
	gFatty = PedCreatePointWithAdjustedHeading(155, POINTLIST._BUCKYCUTSCENE, 1)
	gFattyOriginHealth = PedGetHealth(gFatty)
	PAnimSetActionNode(TRIGGER._BITCHDICE, "/Global/AniDice/DiceRolled/Rolled", "Act/Props/AniDice.act")
	PedSetActionNode(gFatty, "/Global/1_08/1_08_RollDice", "Act/Conv/1_08.act")
	PlayerSetControl(0)
	Wait(2000)
	ConversationMovePeds(false)
	Wait(1500)
	PedStartConversation("/Global/1_08/OpenCut/1_08_NerdoYesCake", "Act/Conv/1_08.act", gPlayer, gFatty)
	while PedInConversation(gPlayer) do
		Wait(0)
	end
	ConversationMovePeds(true)
	PlayerSetControl(1)
	PedDelete(gFatty)
end

function F_DoGirlsBathroomNIS()
	gLackey[9].bActivated = true
	PedSetActionNode(gLackey[9].ped, "/Global/Generic/GenericBathroomMirror", "Act/Anim/GenericSequences.act")
	PedSetInfiniteSprint(gLackey[9].ped, true)
	gLackey[9].currentNode = -1
	gLackey[9].destinationNode = 3
	gLackey[9].bRan = true
	gLackey[10].ped = F_RunToPrefect(gLackey[9].ped)
	gLackey[9].currentNode = -1
	gLackey[10].bPatrolling = true
	PedDelete(gLackey[10].ped)
end

function F_PlayerPickedBeatriceLocker()
	bGotNotes = true
	PlayerClearRewardStore()
	gPickedUpAnswerSheet = 2
end

function F_PlayerFailedToPickBeatriceLocker()
	gPickedUpAnswerSheet = 1
end

function F_EmptyCallback()
	if PlayerIsInTrigger(TRIGGER._CAFBACKTRIGGER) and gNotInNIS then
		gNotInNIS = false
		gPlayerFound = true
	end
end

function F_PlayerStartedLockpicking(x, y, z)
	local x2, y2, z2 = GetPointFromPointList(POINTLIST._LOCKERPOS, 1)
	if 1 > DistanceBetweenCoords3d(x, y, z, x2, y2, z2) then
		shared.gLockpickFailureFunction = F_PlayerFailedToPickBeatriceLocker
		shared.gLockpickSuccessFunction = F_PlayerPickedBeatriceLocker
	end
end

function MissionSetup()
	SoundPlayInteractiveStream("MS_StealthLow.rsm", MUSIC_DEFAULT_VOLUME)
	SoundSetMidIntensityStream("MS_StealthMid.rsm", MUSIC_DEFAULT_VOLUME)
	SoundSetHighIntensityStream("MS_StealthHigh.rsm", MUSIC_DEFAULT_VOLUME)
	PlayCutsceneWithLoad("1-08", true)
	MissionDontFadeIn()
	DATLoad("1_08.DAT", 2)
	DATInit()
end

function F_MissionSetup()
	LoadAnimationGroup("NPC_AggroTaunt")
	LoadAnimationGroup("Area_School")
	LoadAnimationGroup("Px_Sink")
	LoadAnimationGroup("TE_Female")
	LoadAnimationGroup("N_Striker_B")
	LoadAnimationGroup("MG_Craps")
	LoadAnimationGroup("F_Girls")
	LoadAnimationGroup("NIS_1_08_1")
	LoadAnimationGroup("1_08_MandPuke")
	LoadAnimationGroup("Px_Tlet")
	shared.gLockpickStartingFunction = F_PlayerStartedLockpicking
	LoadActionTree("Act/Conv/1_08.act")
	LoadActionTree("Act/Props/AniDice.act")
	LoadPedModels({
		3,
		14,
		58,
		155,
		5,
		130
	})
	LoadPAnims({
		TRIGGER._BITCHDICE
	})
	WeaponRequestModel(488)
	LoadWeaponModels({ 309, 434 })
	Wait(100)
	gLackey[1] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETA,
		pTrigger = TRIGGER._LACKEYSETA,
		pPointNum = 1,
		ped = nil
	}
	gLackey[2] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETA,
		pTrigger = TRIGGER._LACKEYSETA,
		pPointNum = 2,
		ped = nil
	}
	gLackey[3] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETB,
		pTrigger = TRIGGER._LACKEYSETB,
		pPointNum = 1,
		ped = nil
	}
	gLackey[4] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETB,
		pTrigger = TRIGGER._LACKEYSETB,
		pPointNum = 2,
		ped = nil
	}
	gLackey[5] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETB,
		pTrigger = TRIGGER._LACKEYSETB,
		pPointNum = 3,
		ped = nil
	}
	gLackey[6] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETC,
		pTrigger = TRIGGER._LACKEYSETC,
		pPointNum = 1,
		ped = nil
	}
	gLackey[7] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETC,
		pTrigger = TRIGGER._LACKEYSETC,
		pPointNum = 2,
		ped = nil
	}
	gLackey[8] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETD,
		pTrigger = TRIGGER._LACKEYSETD,
		pPointNum = 1,
		ped = nil,
		bHitFirstNode = false,
		nCurrentNode = -1
	}
	gLackey[9] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._EDNAPOINT,
		pTrigger = TRIGGER._EDNAPOINT,
		pPointNum = 1,
		ped = nil,
		bRan = false,
		currentNode = -1,
		destinationNode = -1
	}
	gLackey[10] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETD,
		pTrigger = TRIGGER._LACKEYSETD,
		pPointNum = 0,
		ped = nil,
		currentNode = -1,
		destinationNode = -1,
		gTimer = 0,
		bAttackedPlayer = false
	}
	gLackey[11] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETE,
		pTrigger = TRIGGER._LACKEYSETE,
		pPointNum = 1,
		ped = nil
	}
	gLackey[12] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETE,
		pTrigger = TRIGGER._LACKEYSETE,
		pPointNum = 2,
		ped = nil
	}
	gLackey[20] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYPATROL,
		pPointNum = 2,
		ped = nil
	}
	gLackey[21] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYPATROL,
		pPointNum = 1,
		ped = nil
	}
	gLackey[30] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYFINALA,
		pPath = PATH._LACKEYFINALA,
		pPointNum = 1,
		ped = nil
	}
	gLackey[31] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYFINALB,
		pPath = PATH._LACKEYFINALB,
		pPointNum = 1,
		ped = nil
	}
	gLackey[32] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYFINALC,
		pPath = PATH._LACKEYFINALC,
		pPointNum = 1,
		ped = nil
	}
	gLackey[33] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYFINALD,
		pPath = PATH._LACKEYFINALD,
		pPointNum = 1,
		ped = nil
	}
	gLackey[35] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETD,
		pTrigger = TRIGGER._LACKEYSETD,
		pPointNum = 1,
		ped = nil,
		bHitFirstNode = false,
		nCurrentNode = -1
	}
	gLackey[36] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._LACKEYSETD,
		pTrigger = TRIGGER._LACKEYSETD,
		pPointNum = 1,
		ped = nil,
		bHitFirstNode = false,
		nCurrentNode = -1
	}
	gLackey[40] = {
		bActivated = false,
		bAlive = true,
		pPoint = POINTLIST._GYMCUTSCENELOCATIONS,
		pPointNum = 2,
		ped = nil,
		pickup = nil
	}
	PAnimCreate(TRIGGER._BITCHDICE)
	PedSocialOverrideLoad(24, "Mission/1_08WantGift.act")
	PedSocialOverrideLoad(4, "Mission/1_08Follow.act")
	PedSocialOverrideLoad(18, "Mission/1_08Greeting.act")
	gNumPlayerChoc = ItemGetCurrentNum(478)
	gNumNotes = ItemGetCurrentNum(488)
	gNumStinkbombs = ItemGetCurrentNum(309)
	shared.gGirlsDormWarning = false
end

function MissionCleanup()
	ClearTextQueue()
	F_MakePlayerSafeForNIS(false)
	if gGary and PedIsValid(gGary) then
		PedMakeAmbient(gGary)
	end
	ItemSetCurrentNum(488, 0)
	if bSuccessSoLoadHalloween and IsMissionCompleated("1_07") then
		AreaLoadSpecialEntities("Halloween1", true)
	end
	UnLoadAnimationGroup("NPC_AggroTaunt")
	UnLoadAnimationGroup("Area_School")
	UnLoadAnimationGroup("Px_Sink")
	UnLoadAnimationGroup("TE_Female")
	UnLoadAnimationGroup("N_Striker_B")
	UnLoadAnimationGroup("MG_Craps")
	UnLoadAnimationGroup("F_Girls")
	UnLoadAnimationGroup("1_08_MandPuke")
	UnLoadAnimationGroup("Px_Tlet")
	shared.gLockpickStartingFunction = nil
	shared.g1_08_bGymPop = true
	PlayerSetControl(1)
	PAnimDelete(TRIGGER._BITCHDICE)
	PlayerSetInvulnerable(false)
	SoundStopInteractiveStream()
	SoundEnableSpeech_ActionTree()
	if numBeatrice then
		PedSetUniqueModelStatus(3, numBeatrice)
	end
	if numMandy then
		PedSetUniqueModelStatus(14, numMandy)
	end
	if numFatty then
		PedSetUniqueModelStatus(5, numFatty)
	end
	if gLackey[1].ped ~= nil and not PedIsDead(gLackey[1].ped) then
		PedDelete(gLackey[1].ped)
	end
	if gLackey[2].ped ~= nil and not PedIsDead(gLackey[2].ped) then
		PedDelete(gLackey[2].ped)
	end
	if gLackey[3].ped ~= nil and not PedIsDead(gLackey[3].ped) then
		PedDelete(gLackey[3].ped)
	end
	if gLackey[4].ped ~= nil and not PedIsDead(gLackey[4].ped) then
		PedDelete(gLackey[4].ped)
	end
	if gLackey[5].ped ~= nil and not PedIsDead(gLackey[5].ped) then
		PedDelete(gLackey[5].ped)
	end
	if gLackey[6].ped ~= nil and not PedIsDead(gLackey[6].ped) then
		PedDelete(gLackey[6].ped)
	end
	if gLackey[7].ped ~= nil and not PedIsDead(gLackey[7].ped) then
		PedDelete(gLackey[7].ped)
	end
	if gLackey[8].ped ~= nil and not PedIsDead(gLackey[8].ped) then
		PedDelete(gLackey[8].ped)
	end
	if gLackey[9].ped ~= nil and not PedIsDead(gLackey[9].ped) then
		PedDelete(gLackey[9].ped)
	end
	if gLackey[10].ped ~= nil and not PedIsDead(gLackey[10].ped) then
		PedDelete(gLackey[10].ped)
	end
	if gLackey[11].ped ~= nil and not PedIsDead(gLackey[11].ped) then
		PedDelete(gLackey[11].ped)
	end
	if gLackey[12].ped ~= nil and not PedIsDead(gLackey[12].ped) then
		PedDelete(gLackey[12].ped)
	end
	if gLackey[20].ped ~= nil and not PedIsDead(gLackey[20].ped) then
		PedDelete(gLackey[20].ped)
	end
	if gLackey[21].ped ~= nil and not PedIsDead(gLackey[21].ped) then
		PedDelete(gLackey[21].ped)
	end
	if gLackey[30].ped ~= nil and not PedIsDead(gLackey[30].ped) then
		PedDelete(gLackey[30].ped)
	end
	if gLackey[31].ped ~= nil and not PedIsDead(gLackey[31].ped) then
		PedDelete(gLackey[31].ped)
	end
	if gLackey[32].ped ~= nil and not PedIsDead(gLackey[32].ped) then
		PedDelete(gLackey[32].ped)
	end
	if gLackey[33].ped ~= nil and not PedIsDead(gLackey[33].ped) then
		PedDelete(gLackey[33].ped)
	end
	if gLackey[22] ~= nil and not PedIsDead(gLackey[22]) then
		PedDelete(gLackey[22])
	end
	if gLackey[35] ~= nil and not PedIsDead(gLackey[35]) then
		PedDelete(gLackey[35])
	end
	if gLackey[36] ~= nil and not PedIsDead(gLackey[36]) then
		PedDelete(gLackey[36])
	end
	if gLackey[37] ~= nil and not PedIsDead(gLackey[37]) then
		PedDelete(gLackey[37])
	end
	if gLackey[38] ~= nil and not PedIsDead(gLackey[38]) then
		PedDelete(gLackey[38])
	end
	if gLackey[39] ~= nil and not PedIsDead(gLackey[39]) then
		PedDelete(gLackey[39])
	end
	if gLackey[40].ped ~= nil and not PedIsDead(gLackey[40].ped) then
		PedDelete(gLackey[40].ped)
	end
	F_RemoveObjectiveBlip()
	gLackey = nil
	if gBeatrice ~= nil and not PedIsDead(gBeatrice) then
		PedSetMissionCritical(gBeatrice, false)
		PedMakeAmbient(gBeatrice)
		PedWander(gBeatrice, 0)
	end
	if gFatty ~= nil and not PedIsDead(gFatty) then
		PedDelete(gFatty)
	end
	gFatty = nil
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	DATUnload(2)
end

function MandyWalking(pedId, pathId, nodeId)
	gLackey[35].currentNode = nodeId
end

function MissionStageDeliverBook()
	UpdateBeatriceFinal()
	if gMandy ~= nil and gMandySpotted == false and gMandySpotted == false and not gLockerUsed then
		if PedCanSeeObject(gMandy, gPlayer, 3) then
			--print("SEE OBJECT???")
			if PlayerIsInTrigger(TRIGGER._1_08_GYMGIRLWASH) then
				--print("Is mandy getting in here?")
				PedSetTaskNode(gMandy, "/Global/AI/Reactions/Triggered/GirlsBathroom/GirlNotice",
					"Act/AI/AI_Reactions.act")
				PedFlee(gMandy, gPlayer)
				gMandySpotted = true
				PedMakeAmbient(gMandy)
				gMandy = nil
				PAnimCloseDoor(TRIGGER._DT_GYM_DOORL)
				gLockerUsed = true
			end
		elseif gLackey[35].currentNode == 1 and gLackey[35].pPoint == PATH._MANDYFINALPATH then
			if AreaGetVisible() ~= 0 then
				gLockerUsed = true
				--print("SDFLSMDFKMSDKFMSKDMFK!!!")
				PedClearObjectives(gMandy)
				PedSetActionNode(gMandy, "/Global/WProps/Peds/ScriptedPropInteract", "Act/WProps.act")
				--print("setting: mandy to /Global/WProps/Peds/ScriptedPropInteract")
				Wait(500)
				while not (not PedIsValid(gMandy) or PedIsPlaying(gMandy, "/Global/HitTree/Standing/Ranged/Bomb/Stink_Trap", false)) and AreaGetVisible() ~= 0 do
					Wait(0)
				end
				if PedIsValid(gMandy) then
					PAnimSetPropFlag(TRIGGER._LCKRGYMM, 22, true)
					Wait(100)
					PedSetActionNode(gMandy, "/Global/1_08/1_08_MandyCollpase/Dooit", "Act/Conv/1_08.act")
					PedSetInvulnerable(gMandy, true)
					gLackey[35].currentNode = 8
					bPlayerRiggedLocker = false
					if not PlayerIsInTrigger(TRIGGER._BathroomRightTrig) then
						gLackey[35].pPoint = PATH._MANDYTOTOILET
						PedFollowPath(gMandy, PATH._MANDYTOTOILET, 0, 2, MandyWalking, 0)
					else
						gLackey[35].pPoint = PATH._SECONDSTALL
						PedFollowPath(gMandy, PATH._SECONDSTALL, 0, 2, MandyWalking, 0)
					end
				end
			elseif gMandy ~= nil and PedIsValid(gMandy) then
				gLackey[35].currentNode = 7
				PedDelete(gMandy)
			end
		end
	end
	if bLeftGym and shared.gAreaDATFileLoaded[13] == true and AreaGetVisible() == 13 then
		--print("DISABLE THE LOCKER!!")
		bLeftGym = false
		PAnimSetPropFlag(TRIGGER._LCKRGYMM, 22, true)
		PAnimSetPropFlag(TRIGGER._LCKRGYMM, 19, true)
	end
	if gLackey[35].currentNode == 1 and AreaGetVisible() ~= 0 then
	elseif gLackey[35].pPoint ~= nil and (gLackey[35].pPoint == PATH._MANDYTOTOILET or gLackey[35].pPoint == PATH._SECONDSTALL) and gLackey[35].currentNode == PathGetLastNode(gLackey[35].pPoint) and gMandy ~= nil then
		PedStop(gMandy)
		PedMakeTargetable(gMandy, false)
		PedSetInvulnerable(gMandy, true)
		local target
		PedSetActionNode(gMandy, "/Global/1_08/InteractWithToilet", "Act/Conv/1_08.act")
		Wait(500)
		while not PedIsUsingProp(gMandy) and AreaGetVisible() ~= 0 do
			Wait(2500)
			PedSetActionNode(gMandy, "/Global/1_08/InteractWithToilet", "Act/Conv/1_08.act")
			gMandySpotted = true
		end
		gLackey[35].pPoint = nil
	end
	if gStatusCheck1 == "WORLD" and AreaGetVisible() ~= 0 then
		gStatusCheck1 = "INTERIOR"
	elseif gStatusCheck1 == "INTERIOR" and AreaGetVisible() == 0 then
		gStatusCheck1 = "WORLD"
		bLeftGym = true
	end
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
	if bAmbient then
		SoundPlayAmbientSpeechEvent(pedId, strEvent)
		while SoundSpeechPlaying() do
			Wait(0)
		end
	else
		SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
		while SoundSpeechPlaying() do
			Wait(0)
		end
	end
end

function MissionStageRigTheLocker()
	local x1, y1, z1 = GetPointFromPointList(POINTLIST._LOCKERPOS, 1)
	if bCheckForRigging then
		if PedIsInAreaXYZ(gPlayer, x1, y1, z1, 1.5, 0) then
			if bFlagCheck1 then
				TutorialStart("LOCKERBOMB")
				bFlagCheck1 = false
			end
			if PedIsPlaying(gPlayer, "/Global/NLockA/PedPropsActions/Interact/PlantStinkbomb/OpenDoor/TossStinkbomb", false) or PedIsPlaying(gPlayer, "/Global/NLockA/PedPropsActions/Interact/PlantStinkbomb/OpenDoor/TossStinkbomb/CloseDoor", false) then
				--print("LOCKER WAS RIGGED!!!")
				TextClear()
				bCoronaInLocker = false
				while PedIsPlaying(gPlayer, "/Global/NLockA/PedPropsActions/Interact/PlantStinkbomb/OpenDoor/TossStinkbomb", false) or PedIsPlaying(gPlayer, "/Global/NLockA/PedPropsActions/Interact/PlantStinkbomb/OpenDoor/TossStinkbomb", true) do
					Wait(0)
				end
				if gLockerCorona then
					BlipRemove(gLockerCorona)
					gLockerCorona = nil
				end
				if gMandy == nil and gGymnasiumCut == false then
					gGymnasiumCut = true
					PAnimCloseDoor(TRIGGER._DT_GYM_DOORL)
					PAnimSetPropFlag(TRIGGER._LCKRGYMM, 11, false)
					F_SetupFinalGymCutscene()
				end
				CameraReturnToPlayer()
				F_AddObjectiveBlip("POINT", POINTLIST._TSCHOOL_GIRLSDORMSIDEDOOR, 1, 1)
				TextPrint("1_08_OBJ17", 5, 1)
				MissionObjectiveComplete(gMissionObjective[table.getn(gMissionObjective)])
				table.insert(gMissionObjective, MissionObjectiveAdd("1_08_OBJ01"))
				Wait(3500)
				bFlagCheck1 = true
				bFlagCheck2 = true
				gPlayerFound = false
				gStatusCheck1 = "INTERIOR"
				bPlayerRiggedLocker = true
				missionStage = MissionStageDeliverBook
			end
		elseif not bFlagCheck1 then
			TutorialRemoveMessage()
			bFlagCheck1 = true
		end
	end
	if gOutsidePool == true and shared.gAreaDATFileLoaded[13] == true and AreaGetVisible() == 13 then
		Wait(3000)
		PAnimSetActionNode(TRIGGER._LCKRGYMM, "/Global/NLockA/Unlocked/Default", "Global/Props/NLockA.act")
		gOutsidePool = false
	elseif gOutsidePool == false and AreaGetVisible() == 0 then
		gOutsidePool = true
	end
	F_MonitorStinkBombs()
	F_MonitorFatty()
end

function PrefectPatrolling(pedId, pathId, nodeId)
	gLackey[10].currentNode = nodeId
end

function CB_TurnOnTheCheck()
	bCheckForRigging = true
end

function MissionStageBreakIntoTheLocker() -- ! Modified
	local x1, y1, z1 = GetPointFromPointList(POINTLIST._LOCKERPOS, 1)
	if PedIsInAreaXYZ(gPlayer, x1, y1, z1, 1.5, 0) and MinigameIsReady() == true then
		TextClear()
		while PedIsUsingProp(gPlayer) do
			if not bPlayerRiggedLocker and PedIsPlaying(gPlayer, "/Global/NLockA/PedPropsActions/Locked/LoopPicking/TryOpen/Opening", true) then
				bPlayerRiggedLocker = true
				bCoronaInLocker = false
				CameraSetXYZ(-652.2736, -49.908024, 56.77357, -653.24994, -49.747387, 56.62903)
			end
			Wait(0)
			if shared.gFailedPickingLocker then
				return
			end
		end
		if shared.gFailedPickingLocker then
			return
		end
		--[[
		while PedIsPlaying(gPlayer, "/Global/NLockA/PedPropsActions/Interact/PlantStinkbomb/OpenDoor", true) do
			Wait(0)
		end
		]] -- This was inside the last if, but it doesn't work
		while not bGotNotes do
			Wait(0)
		end
		GiveItemToPlayer(488)
		if gLockerCorona then
			BlipRemove(gLockerCorona)
			gLockerCorona = nil
		end
		if gMandy == nil and gGymnasiumCut == false then
			gGymnasiumCut = true
			PAnimCloseDoor(TRIGGER._DT_GYM_DOORL)
			F_SetupFinalGymCutscene()
		end
		F_AddObjectiveBlip("POINT", POINTLIST._TSCHOOL_GIRLSDORMSIDEDOOR, 1, 1)
		TextPrint("1_08_OBJ17", 5, 1)
		MissionObjectiveComplete(gMissionObjective[table.getn(gMissionObjective)])
		table.insert(gMissionObjective, MissionObjectiveAdd("1_08_OBJ01"))
		CameraReturnToPlayer()
		Wait(3500)
		missionStage = MissionStageDeliverBook
		gPlayerFound = false
		gPickedUpAnswerSheet = 3
		bFlagCheck1 = true
		bFlagCheck2 = true
		gStatusCheck1 = "INTERIOR"
	end
	if gPickedUpAnswerSheet == 1 then
		gPickedUpAnswerSheet = 0
	end
	if gOutsidePool == true and shared.gAreaDATFileLoaded[13] == true and AreaGetVisible() == 13 then
		PAnimSetPropFlag(TRIGGER._LCKRGYMM, 22, false)
		Wait(3000)
		PAnimSetActionNode(TRIGGER._LCKRGYMM, "/Global/NLockA/Locked1_08", "Global/Props/NLockA.act")
		--print("WTF???!!??!?!?!?")
		--print("WTF???!!??!?!?!?")
		--print("WTF???!!??!?!?!?")
		--print("WTF???!!??!?!?!?")
		--print("WTF???!!??!?!?!?")
		--print("WTF???!!??!?!?!?")
		gOutsidePool = false
	elseif gOutsidePool == false and AreaGetVisible() == 0 then
		gOutsidePool = true
	end
	F_MonitorStinkBombs()
	F_MonitorFatty()
end

function T_MonitorPrefect() -- Continue: line 2288
	while gLackey[10].ped do
		if gLackey[10].ped ~= nil and not PedIsDead(gLackey[10].ped) then
			if gLackey[10].bAttackedPlayer and PedIsValid(gLackey[10].ped) then
				--print(" DO YOUR THING!")
				PedStop(gLackey[10].ped)
				PedClearObjectives(gLackey[10].ped)
				PedMakeAmbient(gLackey[10].ped)
				PedSetActionNode(gLackey[10].ped, "/Global/1_08/ShortIdle", "Act/Conv/1_08.act")
				Wait(10)
				PedAttack(gLackey[10].ped, gPlayer, 3)
				gLackey[10].ped = nil
				break
			end
			if gLackey[10].gTimer > 0 then
				if gLackey[10].bOnTheWayBack then
					if GetTimer() - gLackey[10].gTimer > 5000 then
						PedSetActionNode(gLackey[10].ped, "/Global/1_08/1_08_Prefect/1_08_Idle", "Act/Conv/1_08.act")
						PedFollowPath(gLackey[10].ped, PATH._PREFECTPATH, 2, 0, PrefectPatrolling, 6)
						gLackey[10].gTimer = 0
					end
				elseif GetTimer() - gLackey[10].gTimer > 50000 then
					PedSetActionNode(gLackey[10].ped, "/Global/1_08/1_08_Prefect/1_08_Idle", "Act/Conv/1_08.act")
					PedFollowPath(gLackey[10].ped, PATH._PREFECTPATH, 2, 0, PrefectPatrolling, 0)
					gLackey[10].gTimer = 0
				end
			elseif gLackey[10].bPatrolling == true then
				if gLackey[10].bOnTheWayBack and gLackey[10].currentNode == 0 then
					gLackey[10].bOnTheWayBack = false
					PedSetActionNode(gLackey[10].ped, "/Global/1_08/1_08_Prefect/1_08_LookAround", "Act/Conv/1_08.act")
					gLackey[10].gTimer = GetTimer()
				elseif not gLackey[10].bOnTheWayBack and gLackey[10].currentNode == 6 then
					gLackey[10].bOnTheWayBack = true
					PedSetActionNode(gLackey[10].ped, "/Global/1_08/1_08_Prefect/1_08_LookAround", "Act/Conv/1_08.act")
					gLackey[10].gTimer = GetTimer()
				end
			end
		end
		Wait(0)
	end
	if gLackey[10].ped and PedIsValid(gLackey[10].ped) then
		PedMakeAmbient(gLackey[10].ped)
		gLackey[10].ped = nil
	end
	collectgarbage()
end

function SexyGirlRunning(pedId, pathId, nodeId)
	gLackey[9].currentNode = nodeId
end

function F_FireBathroomNIS()
	if not bFireBathroomNIS then
		bFireBathroomNIS = true
		L_PedDeleteGroup("pinky")
	end
end

function MissionStageGymFight() -- Continue: line 2538
	if gOutsidePool == true and shared.gAreaDATFileLoaded[13] == true then
		Wait(3000)
		gOutsidePool = false
	elseif gOutsidePool == false and AreaGetVisible() == 0 then
		gOutsidePool = true
	end
	local x1, y1, z1 = GetPointFromPointList(POINTLIST._LOCKERPOS, 1)
	if AreaGetVisible() == 13 then
		if PedIsInAreaXYZ(gPlayer, x1, y1, z1, 1.5, 7) then
		end
		if not gBreakIntoMessage then
			gBreakIntoMessage = true
			QueueText("1_08_OBJ15", 3, 1)
			MissionObjectiveComplete(gMissionObjective[table.getn(gMissionObjective)])
			table.insert(gMissionObjective, MissionObjectiveAdd("1_08_OBJ03"))
			local x, y, z = GetPointFromPointList(POINTLIST._GYMCUTSCENELOCATIONS, 1)
			if gObjectiveBlip then
				BlipRemove(gObjectiveBlip)
			end
			gObjectiveBlip = BlipAddXYZ(x, y, z, 0, 4)
			if bGirlRanAway then
				missionStage = MissionStageBreakIntoTheLocker
				return
			end
		end
		if gLackey[9].bRan == false and bGirlRanAway == false then
			if gLackey[9].bAlive == true and gLackey[9].bActivated == false then
				gLackey[9].ped = PedCreatePoint(38, POINTLIST._GYMCUTSCENELOCATIONS, 3)
				gLackey[9].bActivated = true
				L_PedLoad("pinky", {
					{
						id = gLackey[9].ped,
						bNISPed = true,
						cbAttacked = F_FireBathroomNIS
					}
				})
				CreateThread("T_PedMonitor")
				PedSetActionNode(gLackey[9].ped, "/Global/Generic/GenericBathroomMirror", "Act/Anim/GenericSequences.act")
				PedSetInfiniteSprint(gLackey[9].ped, true)
			elseif gLackey[9].bActivated == true and (bFireBathroomNIS or PlayerIsInTrigger(TRIGGER._CHANGEROOM)) then
				bGirlRanAway = true
				gLackey[9].currentNode = -1
				gLackey[9].destinationNode = 3
				gLackey[9].bRan = true
				gLackey[10].ped = F_RunToPrefect(gLackey[9].ped)
				gLackey[9].currentNode = -1
				gLackey[10].bPatrolling = true
				CreateThread("T_MonitorPrefect")
				missionStage = MissionStageBreakIntoTheLocker
			end
		end
		if PlayerIsInTrigger(TRIGGER._BathroomExit) and shared.gAreaDATFileLoaded[13] == true and AreaGetVisible() == 13 and not PAnimIsPlaying(TRIGGER._LCKRGYMM, "/Global/NLockA/Locked1_08", false) then
			PAnimSetPropFlag(TRIGGER._LCKRGYMM, 22, false)
			Wait(200)
			PAnimSetActionNode(TRIGGER._LCKRGYMM, "/Global/NLockA/Locked1_08", "Global/Props/NLockA.act")
		end
	elseif AreaGetVisible() == 0 then
		if gLackey[9].ped ~= nil and not PedIsDead(gLackey[9].ped) then
			PedDelete(gLackey[9].ped)
			gLackey[9].bActivated = false
		elseif gLackey[9].bActivated == true then
			gLackey[9].bAlive = false
		end
		gLackey[9].ped = nil
	end
	F_MonitorStinkBombs()
end

function T_MonitorLocker()
	local x1, y1, z1 = GetPointFromPointList(POINTLIST._LOCKERPOS, 1)
	while bLockerTutorial do
		if bCoronaInLocker then
			x1, y1, z1 = GetPointFromPointList(POINTLIST._LOCKERPOS, 1)
			PedIsInAreaXYZ(gPlayer, x1, y1, z1, 1.5, 7)
		end
		Wait(0)
	end
	collectgarbage()
end

function MissionStageGetToGym()
	UpdateRussellsLackeys()
	UpdateEventsBeatriceAfterStinkbomb()
	if not bFountainCutscenePlayed and PlayerIsInTrigger(TRIGGER._FOUNTAINCUTSCENE) then
		bFountainCutscenePlayed = true
		F_ExecuteStealthCutscene()
	elseif bFountainCutscenePlayed and AreaGetVisible() == 13 then
		local x, y, z = GetPointFromPointList(POINTLIST._GYMCUTSCENELOCATIONS, 1)
		if gObjectiveBlip then
			BlipRemove(gObjectiveBlip)
		end
		gObjectiveBlip = BlipAddXYZ(x, y, z, 0, 4)
		bCoronaInLocker = true
		missionStage = MissionStageGymFight
	end
end

function MissionStageWaitForPickup()
	F_MonitorFatty()
end

function MissionStageGetTheStinkBomb()
	UpdateRussellsLackeys()
	UpdateEventsGetStinkbomb()
	F_MonitorFatty()
end

function MissionStageGetCake()
	UpdateRussellsLackeys()
	UpdateEventsGetStinkbomb()
	F_MonitorFatty()
end

function MissionStageMeetWithFatty()
	UpdateRussellsLackeys()
	F_MonitorFatty()
	if not gDebugging then
		UpdateEventsMeetingWithFatty()
	end
	UpdateEventsBeatriceBeforeStinkbomb()
end

function UpdateRussellsLackeys()
	if bFlagCheck1 then
		local myBool = false
		myBool = InitiateCombat(gLackey[20].ped, gLackey[21].ped)
		bFlagCheck1 = not myBool
	end
	if gStatusCheck1 == "WORLD" and AreaGetVisible() ~= 0 then
		F_DeactivatePeds()
		gStatusCheck1 = "INTERIOR"
	elseif gStatusCheck1 == "INTERIOR" and AreaGetVisible() == 0 then
		gStatusCheck1 = "WORLD"
		F_SetupFountainPatrol()
	end
end

function UpdateEventsMeetingWithFatty()
	local x, y, z
	if PedIsValid(gFatty) then
		x, y, z = PedGetPosXYZ(gFatty)
	end
	if gFatty == nil and PedIsInTrigger(gPlayer, TRIGGER._BUCKYTRIGGER) then
		gFatty = PedCreatePointWithAdjustedHeading(155, POINTLIST._BUCKYCUTSCENE, 1)
		gFattyOriginHealth = PedGetHealth(gFatty)
		if 1 <= nTalkedWithBucky then
			F_AddObjectiveBlip("CHAR", gFatty, 1, 4)
		end
		GameSetPedStat(gFatty, 6, 100)
		PedSetFlag(gFatty, 106, false)
		PedUseSocialOverride(gFatty, 24)
		PedUseSocialOverride(gFatty, 4)
		PedUseSocialOverride(gFatty, 18)
		PedSetEmotionTowardsPed(gFatty, gPlayer, 4, false)
	elseif gFatty ~= nil and not PedIsInTrigger(gPlayer, TRIGGER._BUCKYTRIGGER) then
		PedDelete(gFatty)
		gFatty = nil
		if 1 <= nTalkedWithBucky then
			F_AddObjectiveBlip("POINT", POINTLIST._BUCKYCUTSCENE, 1, 4)
		end
	elseif gFatty ~= nil and not bFattyIsFleeing then
		if not PedIsInAreaObject(gPlayer, gFatty, 2, 7, 0) then
			if not PedIsPlaying(gFatty, "/Global/1_08/1_08_RollDice", true) then
				--print("Executing!!!")
				PedSetPosPoint(gFatty, POINTLIST._BUCKYCUTSCENE, 1)
				PedFaceHeading(gFatty, 60, 0)
				PAnimSetActionNode(TRIGGER._BITCHDICE, "/Global/AniDice/DiceRolled/Rolled", "Act/Props/AniDice.act")
				PedClearObjectives(gFatty)
				PedSetActionNode(gFatty, "/Global/1_08/1_08_RollDice/Idle", "Act/Conv/1_08.act")
				Wait(200)
			end
		elseif PedIsInAreaObject(gPlayer, gFatty, 2, 5, 0) and PedIsPlaying(gFatty, "/Global/1_08/1_08_RollDice", true) then
			PedSetActionNode(gFatty, "/Global/1_08/1_08_Fatty", "Act/Conv/1_08.act")
		end
	end
	if 0 < ItemGetCurrentNum(309) then
		F_PlayerHasStinkbombs()
	end
end

function F_FattyFlee()
	bFattyIsFleeing = true
end

function cbEdnaKitchen(pedId, pathId, nodeId)
	gLackey[8].nCurrentNode = nodeId
	if nodeId == 5 then
		nodeId = 6
		PedSetActionNode(gLackey[8].ped, "/Global/1_08/CafeteriaLady/MonitorOnce/MonitorOnce", "Act/Conv/1_08.act")
	end
	if nodeId == PathGetLastNode(pathId) then
		SoundPlayScriptedSpeechEvent(gLackey[8].ped, "M_1_08", 15)
	end
	if not PedGetFlag(gLackey[8].ped, 33) and not gTurnEdnaIntoStealth then
		gTurnEdnaIntoStealth = true
	end
end

function UpdateEventsGetStinkbomb()
	local x, y, z
	if PedIsValid(gFatty) then
		x, y, z = PedGetPosXYZ(gFatty)
	end
	if gFatty == nil and PedIsInTrigger(gPlayer, TRIGGER._BUCKYTRIGGER) then
		gFatty = PedCreatePointWithAdjustedHeading(155, POINTLIST._BUCKYCUTSCENE, 1)
		gFattyOriginHealth = PedGetHealth(gFatty)
		if 1 <= nTalkedWithBucky then
			F_AddObjectiveBlip("CHAR", gFatty, 1, 4)
		end
		PedSetRequiredGift(gFatty, 22, false, true)
		PedSetFlag(gFatty, 106, false)
		GameSetPedStat(gFatty, 6, 100)
		PedSetEmotionTowardsPed(gFatty, gPlayer, 4, false)
		PedUseSocialOverride(gFatty, 4)
		PedUseSocialOverride(gFatty, 18)
		PedUseSocialOverride(gFatty, 24)
	elseif gFatty ~= nil and not PedIsInTrigger(gPlayer, TRIGGER._BUCKYTRIGGER) then
		PedDelete(gFatty)
		gFatty = nil
		if 1 <= nTalkedWithBucky then
			F_AddObjectiveBlip("POINT", POINTLIST._BUCKYCUTSCENE, 1, 4)
		end
	elseif gFatty ~= nil and not bFattyIsFleeing and (not PedIsSocializing(gFatty) or PedIsWantingToSocialize(gFatty)) then
		if not PedIsInAreaObject(gPlayer, gFatty, 2, 7, 0) then
			if not PedIsPlaying(gFatty, "/Global/1_08/1_08_RollDice", true) then
				PedStopSocializing(gFatty)
				PedSetPosPoint(gFatty, POINTLIST._BUCKYCUTSCENE, 1)
				PedFaceHeading(gFatty, 60, 0)
				PAnimSetActionNode(TRIGGER._BITCHDICE, "/Global/AniDice/DiceRolled/Rolled", "Act/Props/AniDice.act")
				PedSetActionNode(gFatty, "/Global/1_08/1_08_RollDice/Idle", "Act/Conv/1_08.act")
				Wait(200)
			end
		elseif PedIsInAreaObject(gPlayer, gFatty, 2, 5, 0) and PedIsPlaying(gFatty, "/Global/1_08/1_08_RollDice", true) then
			PedSetActionNode(gFatty, "/Global/1_08/1_08_Fatty", "Act/Conv/1_08.act")
		end
	end
	if AreaGetVisible() ~= 2 then
		if gLackey[8].bAlive == true and gLackey[8].ped ~= nil then
			PedDelete(gLackey[8].ped)
			gLackey[8].ped = nil
		end
		if gCafPopOverride == true then
			SoundRestartAmbiences()
			gCafPopOverride = false
		end
	elseif AreaGetVisible() == 2 then
		if gCafPopOverride == false then
		end
		if gLackey[8].bAlive == true and gLackey[8].ped == nil then
			gLackey[8].ped = PedCreatePoint(58, POINTLIST._EDNAPOINT, 1)
			PedAlwaysUpdateAnimation(gLackey[8].ped, true)
			PedFollowPath(gLackey[8].ped, PATH._KITCHENLADY, 1, 0, cbEdnaKitchen)
			PedSetTetherToTrigger(gLackey[8].ped, TRIGGER._CAFBACKTRIGGER)
		end
		if gLackey[8].bHitFirstNode == true and gLackey[8].nCurrentNode == 0 then
			F_PlaySpeechWait(gLackey[8].ped, "M_1_08", 15, "large")
			gLackey[8].bHitFirstNode = false
		elseif gLackey[8].bHitFirstNode == false and gLackey[8].nCurrentNode == 4 then
			gLackey[8].bHitFirstNode = true
		end
	end
	if 0 < ItemGetCurrentNum(309) then
		F_PlayerHasStinkbombs()
	end
end

function F_GivePlayerStinkBombs()
	--print("F_GivePlayerStinkBombs, LSMFKSFM!")
	nTalkedWithBucky = 2
	bTalkedWithBeatrice = false
	nTalkedWithBeatrice = 1
	nReachedLocker = 1
	bReachedLocker = false
	if not bDropStinkBombs then
		if gFatty ~= nil and PedIsValid(gFatty) then
			PedSetRequiredGift(gFatty, 0, false, true)
		end
		GiveAmmoToPlayer(309, 7)
	end
	MissionObjectiveComplete(gMissionObjective[table.getn(gMissionObjective)])
	shared.g1_08_bGymPop = false
	local x, y, z = GetPointFromPointList(POINTLIST._GYMCUTSCENELOCATIONS, 1)
	if gObjectiveBlip then
		BlipRemove(gObjectiveBlip)
	end
	gObjectiveBlip = BlipAddXYZ(x, y, z, 0, 1)
	table.insert(gMissionObjective, MissionObjectiveAdd("1_08_OBJ05"))
	bCoronaInLocker = true
	missionStage = MissionStageGymFight
end

function F_PlayerHasStinkbombs()
	--print("ASLDMAKMSDKMASKDMLA F_PlayerHasStinkbombs")
	nTalkedWithBucky = 0
	bTalkedWithBeatrice = false
	nTalkedWithBeatrice = 1
	nReachedLocker = 1
	bReachedLocker = false
	shared.g1_08_bGymPop = false
	local x, y, z = GetPointFromPointList(POINTLIST._GYMCUTSCENELOCATIONS, 1)
	if gObjectiveBlip then
		BlipRemove(gObjectiveBlip)
	end
	gObjectiveBlip = BlipAddXYZ(x, y, z, 0, 1)
	if 0 < table.getn(gMissionObjective) then
		MissionObjectiveComplete(gMissionObjective[table.getn(gMissionObjective)])
	end
	TextPrint("1_08_OBJ05", 4, 1)
	table.insert(gMissionObjective, MissionObjectiveAdd("1_08_OBJ05"))
	bCoronaInLocker = true
	missionStage = MissionStageGymFight
end

function F_SetMissionStageGivePlayerStinkers()
	ClearTextQueue()
	QueueText("1_08_OBJ05", 4, 1)
	PedUseSocialOverride(gFatty, 4, false)
	PedUseSocialOverride(gFatty, 18, false)
	PedUseSocialOverride(gFatty, 24, false)
	missionStage = F_GivePlayerStinkBombs
end

function UpdateEventsBeatriceBeforeStinkbomb()
	if gBeatrice == nil and AreaGetVisible() == 35 then
		gBeatrice = PedCreatePointWithAdjustedHeading(3, POINTLIST._BEATRICECUTSCENE, 1)
		PedSetActionNode(gBeatrice, "/Global/1_08/1_08_Beatrice", "Act/Conv/1_08.act")
	elseif gBeatrice ~= nil then
		if AreaGetVisible() ~= 35 then
			PedSetMissionCritical(gBeatrice, false, nil, false)
			PedDelete(gBeatrice)
			gBeatrice = nil
		elseif PedIsDead(gBeatrice) then
			missionCondition = "Failure"
		end
	end
end

function UpdateEventsBeatriceAfterStinkbomb()
	if gBeatrice == nil and AreaGetVisible() == 35 then
		gBeatrice = PedCreatePointWithAdjustedHeading(3, POINTLIST._BEATRICECUTSCENE, 1)
		PedSetActionNode(gBeatrice, "/Global/1_08/1_08_Beatrice", "Act/Conv/1_08.act")
	elseif gBeatrice ~= nil then
		if AreaGetVisible() ~= 35 then
			PedSetMissionCritical(gBeatrice, false, nil, false)
			PedDelete(gBeatrice)
			gBeatrice = nil
		elseif PedIsDead(gBeatrice) then
			missionCondition = "Failure"
		end
	end
end

function UpdateBeatriceFinal()
	if gBeatrice == nil and AreaGetVisible() == 0 then
		gBeatrice = PedCreatePointWithAdjustedHeading(3, POINTLIST._BEATRICECUTSCENE, 1)
		F_AddObjectiveBlip("CHAR", gBeatrice, 1, 4)
		PedSetEmotionTowardsPed(gBeatrice, gPlayer, 7)
		PedSetPedToTypeAttitude(gBeatrice, 13, 4)
		PedSetMissionCritical(gBeatrice, true, F_CriticalPedDied, true)
		PlayerSocialDisableActionAgainstPed(gBeatrice, 28, true)
		PlayerSocialDisableActionAgainstPed(gBeatrice, 29, true)
		PedSetRequiredGift(gBeatrice, 12, false, true)
		if gPrefectBlip then
			--print("DELETING PREFECT BLIP!!")
			BlipRemove(gPrefectBlip)
			gPrefectBlip = nil
		end
	elseif gBeatrice ~= nil and AreaGetVisible() ~= 0 then
		PedSetMissionCritical(gBeatrice, false, nil, false)
		F_AddObjectiveBlip("POINT", POINTLIST._BEATRICECUTSCENE, 1, 1)
		PedDelete(gBeatrice)
		gBeatrice = nil
	elseif gBeatrice and PedIsValid(gBeatrice) then
		if PlayerIsInAreaObject(gBeatrice, 2, 3, 0) then
			PlayerSetControl(0)
			CameraSetWidescreen(true)
			SoundDisableSpeech_ActionTree()
			F_MakePlayerSafeForNIS(true)
			PedFaceObject(gBeatrice, gPlayer, 3, 1)
			PedFaceObject(gPlayer, gBeatrice, 2, 1)
			PedLockTarget(gPlayer, gBeatrice, 3)
			PedClearObjectives(gBeatrice)
			PedSetActionNode(gPlayer, "/Global/1_08/1_08_GiveNotes/1_08_Give/GiveLabNotes1_08", "Act/Conv/1_08.act")
			while PedIsPlaying(gPlayer, "/Global/1_08/1_08_GiveNotes/1_08_Give/GiveLabNotes1_08", true) do
				Wait(0)
			end
			bPlayerTalkedWithMandy = true
			missionCondition = "Success"
		elseif PedIsDead(gBeatrice) then
			missionCondition = "Failure"
		end
	end
end

function F_UpdateCakeObjective()
	if gPickedUpCake == 0 then
		local x1, y1, z1 = GetPointFromPointList(POINTLIST._CHOCOLATEBAR, 1)
		if gChocolate and PickupIsPickedUp(gChocolate) then
			QueueSoundSpeech(gLackey[8].ped, "M_1_08", 15, nil, "large")
			if gLackey[8].ped and PedIsValid(gLackey[8].ped) then
				QueueSoundSpeech(gLackey[8].ped, "M_1_08", 14, nil, "medium")
			end
			gPickedUpCake = 1
			if gPickedUpCake == 1 then
				gPickedUpCake = 2
				F_AddObjectiveBlip("POINT", POINTLIST._BUCKYCUTSCENE, 1, 1)
				TextPrint("1_08_OBJ07", 5, 1)
				MissionObjectiveComplete(gMissionObjective[table.getn(gMissionObjective)])
				table.insert(gMissionObjective, MissionObjectiveAdd("1_08_OBJ07"))
				missionStage = MissionStageGetTheStinkBomb
			end
		end
	end
	if PlayerIsInTrigger(TRIGGER._1_08_CAFTRIG) then
		if not sneakTutorial then
			sneakTutorial = true
			TutorialShowMessage("1_08_OBJ08", 6000)
		end
		if gChocolate == nil then
			gChocolate = PickupCreatePoint(478, POINTLIST._CHOCOLATEBAR, 1, 90, "PermanentButes")
		end
		if gPickedUpCake == -1 then
			gPickedUpCake = 0
		end
		if gLackey[8].bAlive == true and gLackey[8].ped == nil then
			gLackey[8].ped = PedCreatePoint(58, POINTLIST._EDNAPOINT, 1)
			PedAlwaysUpdateAnimation(gLackey[8].ped, true)
			PedFollowPath(gLackey[8].ped, PATH._KITCHENLADY, 1, 0, cbEdnaKitchen)
			PedSetTetherToTrigger(gLackey[8].ped, TRIGGER._CAFBACKTRIGGER)
			if gCafeteriaIntro == false then
				F_SetupCafeteriaIntroCutscene()
				gCafeteriaIntro = true
			end
		end
		if not gEdnaAfterPlayer then
			if gPickedUpCake == 0 then
				if gTimeEdnaTalked == 0 then
					gTimeEdnaTalked = GetTimer()
					F_PlaySpeechWait(gLackey[8].ped, "CHATTER", nil, nil, true)
					gCurrentSpeech = 1
				elseif gCurrentSpeech == 1 and GetTimer() - gTimeEdnaTalked > 5000 then
					gTimeEdnaTalked = GetTimer()
					F_PlaySpeechWait(gLackey[8].ped, "CHATTER", nil, nil, true)
					gCurrentSpeech = 2
				elseif gCurrentSpeech == 2 and GetTimer() - gTimeEdnaTalked > 5000 then
					gTimeEdnaTalked = GetTimer()
					F_PlaySpeechWait(gLackey[8].ped, "CHATTER", nil, nil, true)
					gCurrentSpeech = 3
				end
			end
		else
			gCurrentSpeech = 4
		end
		if gCafPopOverride == false then
		end
		if gLackey[8].bHitFirstNode == true and gLackey[8].nCurrentNode == 0 then
			QueueSoundSpeech(gLackey[8].ped, "M_1_08", 15, nil, "medium")
			gLackey[8].bHitFirstNode = false
			if gPickedUpCake == 1 then
				Wait(5000)
				gPickedUpCake = 2
				F_AddObjectiveBlip("CHAR", gFatty, 1, 4)
				if gTimeEdnaTalked ~= 0 and GetTimer() - gTimeEdnaTalked < 5000 then
					TextClear()
				end
				TextPrint("1_08_OBJ07", 5, 1)
				MissionObjectiveComplete(gMissionObjective[table.getn(gMissionObjective)])
				table.insert(gMissionObjective, MissionObjectiveAdd("1_08_OBJ07"))
				missionStage = MissionStageGetTheStinkBomb
			end
		elseif gLackey[8].bHitFirstNode == false and gLackey[8].nCurrentNode == 4 then
			gLackey[8].bHitFirstNode = true
		end
		if gPlayerFound == true then
			gPlayerFound = false
			SetupCameraForBeingCaught()
		end
	elseif AreaGetVisible() ~= 2 then
		if gChocolate ~= nil then
			PickupDelete(gChocolate)
			gChocolate = nil
		end
		if gCafPopOverride == true then
			SoundRestartAmbiences()
			gCafPopOverride = false
		end
		if gTimeEdnaTalked ~= 0 and GetTimer() - gTimeEdnaTalked < 5000 then
			TextClear()
		end
		if gLackey[8].bAlive == true and gLackey[8].ped ~= nil then
			PedMakeAmbient(gLackey[8].ped)
			gLackey[8].ped = nil
		end
		if gPickedUpCake == 1 then
			gPickedUpCake = 2
			F_AddObjectiveBlip("CHAR", gFatty, 1, 4)
			TextPrint("1_08_OBJ07", 5, 1)
			MissionObjectiveComplete(gMissionObjective[table.getn(gMissionObjective)])
			table.insert(gMissionObjective, MissionObjectiveAdd("1_08_OBJ07"))
			missionStage = MissionStageGetTheStinkBomb
		elseif gPickedUpCake == 0 then
			gPickedUpCake = -1
		end
	elseif not PlayerIsInTrigger(TRIGGER._1_08_CAFTRIG) and gLackey[8].bAlive == true and gLackey[8].ped ~= nil and PedIsValid(gLackey[8].ped) then
		PedDelete(gLackey[8].ped)
		gLackey[8].ped = nil
	end
	F_ProcessEdnaStealth()
end

function F_ProcessEdnaStealth()
	if AreaGetVisible() == 2 and gLackey[8].ped ~= nil then
		if not gEdnaAfterPlayer and not PedGetFlag(gLackey[8].ped, 33) and (gTurnEdnaIntoStealth or not PedCanSeeObject(gLackey[8].ped, gPlayer, 3)) then
			gTurnEdnaIntoStealth = false
			PedAlwaysUpdateAnimation(gLackey[8].ped, true)
		end
		if not PlayerIsInTrigger(TRIGGER._CAFBACKTRIGGER) and gEdnaAfterPlayer then
			gNotInNIS = true
			gEdnaAfterPlayer = false
			--print("Ped ID: ", gLackey[8].ped)
			PedStop(gLackey[8].ped)
			PedIgnoreStimuli(gLackey[8].ped, true)
			PedClearObjectives(gLackey[8].ped)
			PedSetActionNode(gLackey[8].ped, "/Global/1_08/CafeteriaLady/PointWarn", "Act/Conv/1_08.act")
			if gLackey[8].nCurrentNode + 1 <= PathGetLastNode(PATH._KITCHENLADY) then
				PedFollowPath(gLackey[8].ped, PATH._KITCHENLADY, 1, 0, cbEdnaKitchen, gLackey[8].nCurrentNode + 1)
			else
				PedFollowPath(gLackey[8].ped, PATH._KITCHENLADY, 1, 0, cbEdnaKitchen)
			end
		end
	end
end

function F_DeactivatePeds()
	for i = 1, 7 do
		if gLackey[i].bActivated and gLackey[i].ped ~= nil and not PedIsDead(gLackey[i].ped) then
			PedDelete(gLackey[i].ped)
			gLackey[i].ped = nil
			gLackey[i].bActivated = false
		end
	end
	if missionStage ~= MissionStageGetTheStinkBomb then
		if gLackey[20].ped ~= nil and not PedIsDead(gLackey[20].ped) then
			PedDelete(gLackey[20].ped)
			gLackey[20].ped = nil
		end
		if gLackey[21].ped ~= nil and not PedIsDead(gLackey[21].ped) then
			PedDelete(gLackey[21].ped)
			gLackey[21].ped = nil
		end
	end
end

function F_CriticalPedDied(ped)
	bBeatriceWasHit = true
	missionCondition = "Fail"
end

function main()
	CreateThread("T_MonitorLocker")
	F_MissionSetup()
	AreaTransitionPoint(0, POINTLIST._BEATRICECUTSCENE, 3, true)
	if bMissionRunning == false then
		shared.gGirlsDormWarning = true
		if ItemGetCurrentNum(309) == 0 then
			F_PlayIntroNIS()
		end
		CameraFade(500, 1)
		Wait(500)
		if 0 < ItemGetCurrentNum(309) then
			F_PlayerHasStinkbombs()
		else
			bMissionRunning = true
			QueueText("1_08_OBJ09", 5, 1)
			table.insert(gMissionObjective, MissionObjectiveAdd("1_08_OBJ09"))
			bTalkedWithBeatrice = true
			missionStage = MissionStageMeetWithFatty
			F_AddObjectiveBlip("POINT", POINTLIST._BUCKYCUTSCENE, 1, 4)
			gStatusCheck1 = "WORLD"
		end
		numBeatrice = PedGetUniqueModelStatus(3)
		PedSetUniqueModelStatus(3, -1)
		numMandy = PedGetUniqueModelStatus(14)
		PedSetUniqueModelStatus(14, -1)
		numFatty = PedGetUniqueModelStatus(5)
		PedSetUniqueModelStatus(5, -1)
		while missionCondition == "Running" do
			Wait(0)
			UpdateTextQueue()
			missionStage()
		end
		bLockerTutorial = false
		if missionCondition == "Success" then
			--print("Going in here?")
			PedLockTarget(gBeatrice, gPlayer)
			PedLockTarget(gPlayer, gBeatrice)
			PedSetActionNode(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt", "Act/Player.act")
			while not PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
				--print("SDFSDF TUCK IN HERE!!!KLMFS")
				Wait(0)
			end
			CameraSetWidescreen(true)
			Wait(1000)
			SoundStopInteractiveStream()
			MinigameSetCompletion("M_PASS", true, 0, "1_08_UNLOCK")
			SoundPlayMissionEndMusic(true, 7)
			PedSetEmotionTowardsPed(gBeatrice, gPlayer, 8, true)
			PedSetPedToTypeAttitude(gBeatrice, gPlayer, 4)
			PedSetFlag(gBeatrice, 84, true)
			while PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) or PedIsPlaying(gBeatrice, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
				--print("STUCK IN HERE!!!KLMFS")
				Wait(0)
			end
			PedLockTarget(gPlayer, -1, 3)
			PedMakeAmbient(gBeatrice)
			PedWander(gBeatrice, 0)
			if gBeatrice ~= nil and not PedIsDead(gBeatrice) then
				PedSetMissionCritical(gBeatrice, false)
				PedMakeAmbient(gBeatrice)
				PedWander(gBeatrice, 0)
				PedSetRequiredGift(gBeatrice, 2, false, true)
				PlayerSocialDisableActionAgainstPed(gBeatrice, 28, false)
				PlayerSocialDisableActionAgainstPed(gBeatrice, 29, false)
			end
			gBeatrice = nil
			while MinigameIsShowingCompletion() do
				--print("NOW IN HERE!!")
				Wait(0)
			end
			CameraFade(500, 0)
			Wait(501)
			CameraReset()
			CameraReturnToPlayer()
			bSuccessSoLoadHalloween = true
			MissionSucceed(false, false, false)
			Wait(500)
			CameraFade(500, 1)
			Wait(101)
			PlayerSetControl(1)
		else
			if gBeatrice and PedIsValid(gBeatrice) then
				PedMakeAmbient(gBeatrice)
			end
			if bBeatriceWasHit then
				SoundPlayMissionEndMusic(false, 7)
				MissionFail(false, true, "1_08_BEAHIT")
			elseif gBeatrice and PedIsValid(gBeatrice) and PedIsDead(gBeatrice) then
				SoundPlayMissionEndMusic(false, 7)
				MissionFail(false, true, "1_08_BEAKO")
			else
				SoundPlayMissionEndMusic(false, 7)
				MissionFail(false, true)
			end
		end
	end
end

function InitiateCombat(ped1, ped2)
	local attacking = false
	if ped1 ~= nil and not PedIsDead(ped1) and PedCanSeeObject(ped1, gPlayer, 3) then
		attacking = true
	end
	if not attacking and ped2 ~= nil and not PedIsDead(ped2) and PedCanSeeObject(ped2, gPlayer, 3) then
		attacking = true
	end
	if attacking then
		if ped1 ~= nil and not PedIsDead(ped1) then
			PedAttack(ped1, gPlayer)
		end
		if ped2 ~= nil and not PedIsDead(ped2) then
			PedAttack(ped2, gPlayer)
		end
	end
	return attacking
end

function PatrolReachedEnd(pedId, pathId, nodeId)
	if not PedIsDead(gLackey[20].ped) then
		PedSetActionNode(gLackey[20].ped, "/Global/1_08/PatrolMonitor", "Act/Conv/1_08.act")
	end
end

function F_SetupFountainPatrol()
	if missionStage == MissionStageGetToGym then
		if not gLackey[20].bActivated and gLackey[20].bAlive == true then
			--print("==============> CREATING PATROLLING PED!")
			gLackey[20].ped = PedCreatePointWithAdjustedHeading(13, gLackey[20].pPoint, gLackey[20].pPointNum)
		end
		if not gLackey[21].bActivated and gLackey[21].bAlive == true then
			--print("==============> CREATING PATROLLING PED!")
			gLackey[21].ped = PedCreatePointWithAdjustedHeading(15, gLackey[21].pPoint, gLackey[21].pPointNum)
		end
		AddBlipForChar(gLackey[20].ped, 2, 2, 1)
		AddBlipForChar(gLackey[21].ped, 2, 2, 1)
		PedSetPedToTypeAttitude(gLackey[20].ped, 13, 0)
		PedSetPedToTypeAttitude(gLackey[21].ped, 13, 0)
		PedFollowPath(gLackey[20].ped, PATH._LACKEYPATROL, 2, 0, PatrolReachedEnd)
	end
	--print("================> DONE F_SetupFountainPatrol")
end

function F_SetupFinalEnemyPeds()
end

function F_DeactivateFinalEnemyPeds()
end

function F_ExecuteStealthCutscene()
	local ppoints = PlayerGetPunishmentPoints()
	PlayerSetPunishmentPoints(0)
	PedSetInvulnerable(gPlayer, true)
	PlayerSetControl(0)
	F_DeactivatePeds()
	gLackey[20].ped = PedCreatePointWithAdjustedHeading(13, gLackey[20].pPoint, gLackey[20].pPointNum)
	gLackey[21].ped = PedCreatePointWithAdjustedHeading(15, gLackey[21].pPoint, gLackey[21].pPointNum)
	PedStartConversation("/Global/1_08/PatrolDialogue", "Act/Conv/1_08.act", gLackey[20].ped, gLackey[21].ped)
	while PedInConversation(gLackey[20].ped) do
		Wait(0)
	end
	CameraReset()
	CameraReturnToPlayer(true)
	F_DeactivatePeds()
	F_SetupFountainPatrol()
	PedSetInvulnerable(gPlayer, false)
	PlayerSetPunishmentPoints(ppoints)
	PlayerSetControl(1)
end

function SetupCameraForBeingCaught()
	if not gEdnaAfterPlayer then
		--print("GO AFTER THE PLAYER!!")
		gEdnaAfterPlayer = true
		PedStop(gLackey[8].ped)
		PedClearObjectives(gLackey[8].ped)
		PlayerIncPunishmentPoints(120 - PlayerGetPunishmentPoints())
		PedSetActionNode(gLackey[8].ped, "/Global/1_08/CafeteriaLady/Resume/Resume", "Act/Conv/1_08.act")
		PedFaceObject(gLackey[8].ped, gPlayer, 3, 0)
		if missionStage == MissionStageGetTheStinkBomb then
			SoundPlayScriptedSpeechEvent(gLackey[8].ped, "M_1_08", 13)
		elseif gPickedUpCake == 1 then
			SoundPlayScriptedSpeechEvent(gLackey[8].ped, "M_1_08", 13)
		else
			F_PlaySpeechWait(gLackey[8].ped, "M_1_08", 13, "medium")
		end
		PedSetActionNode(gLackey[8].ped, "/Global/1_08/CafeteriaLady/Point/Point", "Act/Conv/1_08.act")
		PedAttack(gLackey[8].ped, gPlayer, 0)
	end
end

function F_SetupCafeteriaIntroCutscene()
end

function F_MandySpotPlayer(pedId)
	if pedId == gPlayer then
		--print("Take out the player!!")
		PedStop(gMandy)
		PedClearObjectives(gMandy)
		PedAttack(gMandy, gPlayer, 1)
	end
end

function F_SetupFinalGymCutscene()
	gMandy = PedCreatePoint(14, POINTLIST._GYMCUTSCENELOCATIONS, 10)
	Wait(1)
	SoundPlayScriptedSpeechEvent(gMandy, "M_1_08", 25, "xtralarge")
	gLackey[35].pPoint = PATH._MANDYFINALPATH
	PedIgnoreStimuli(gMandy, true)
	PedFollowPath(gMandy, PATH._MANDYFINALPATH, 0, 0, MandyWalking, 0)
end

function F_RemoveObjectiveBlip()
	if gObjectiveBlip ~= nil then
		--print("==========>>> REMOVE THE CURRENT BLIP THAT HAS BEEN PLACED!")
		BlipRemove(gObjectiveBlip)
		gObjectiveBlip = nil
	end
end

function F_AddObjectiveBlip(blipType, point, index, blipEnum)
	F_RemoveObjectiveBlip()
	if gObjectiveBlip == nil then
		if blipType == "POINT" then
			local x, y, z = GetPointFromPointList(point, index)
			gObjectiveBlip = BlipAddXYZ(x, y, z + 0.1, 0, blipEnum)
		elseif blipType == "CHAR" and not PedIsDead(point) then
			gObjectiveBlip = AddBlipForChar(point, index, 0, blipEnum)
		end
	end
end

function ExecuteAnimationSequence(ped, actionNode, fileName)
	while true do
		Wait(0)
		if not PedIsDead(ped) and not PedIsPlaying(ped, actionNode, true) then
			PedSetActionNode(ped, actionNode, fileName)
		elseif true then
			break
		else
			break
		end
	end
end

local gCurrentPoint = 0

function cb_GoTowardsGary(pedId, pathId, nodeId)
	gCurrentPoint = nodeId
end

local nCurrentNode = 0

function CB_FollowPath(pedId, pathId, nodeId)
	nCurrentNode = nodeId
end

function F_PlayIntroNIS()
	local bSkip = false
	local gGary = PedCreatePoint(130, POINTLIST._BEATRICECUTSCENE, 4)
	F_MakePlayerSafeForNIS(true)
	PedSetAsleep(gGary, true)
	PlayerSetControl(0)
	PlayerSetPosPoint(POINTLIST._1_08_STARTPOINT, 1)
	CameraSetXYZ(242.38644, -25.24383, 7.048032, 243.09528, -24.552046, 7.185382)
	CameraSetWidescreen(true)
	CameraFade(500, 1)
	Wait(500)
	PedFollowPath(gPlayer, PATH._1_08_OUTSIDEGIRLS, 0, 0, CB_FollowPath)
	while not (nCurrentNode == 2 or bSkip) do
		bSkip = WaitSkippable(1)
	end
	if not bSkip then
		ConversationMovePeds(false)
		CameraDefaultFOV()
		PedStartConversation("/Global/1_08/NIS_1_08_1/ConvInitiate", "Act/Conv/1_08.act", gPlayer, gGary)
	else
		PedStop(gPlayer)
		PedClearObjectives(gPlayer)
	end
	while not bSkip and PedInConversation(gPlayer) do
		bSkip = WaitSkippable(1)
	end
	if bSkip then
		SoundCancelConversation()
	end
	UnLoadAnimationGroup("NIS_1_08_1")
	PedSetActionNode(gPlayer, "/Global/1_08/ShortIdle", "Act/Conv/1_08.act")
	PedSetActionNode(gGary, "/Global/1_08/ShortIdle", "Act/Conv/1_08.act")
	PlayerSetControl(1)
	PedWander(gGary, 0)
	while PedInConversation(gPlayer) do
		Wait(0)
	end
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
	CameraDefaultFOV()
	PedMakeAmbient(gGary)
	Wait(1)
	CameraReset()
	CameraReturnToPlayer()
end

function F_BitchPickupDice()
	PAnimSetActionNode(TRIGGER._BITCHDICE, "/Global/AniDice/IdleDice", "Act/Props/AniDice.act")
end

function F_BitchRollDice()
	PAnimSetActionNode(TRIGGER._BITCHDICE, "/Global/AniDice/RollDice/Roll", "Act/Props/AniDice.act")
end

function CB_RunTutorial()
end

function F_PrefectSpottedPlayer(prefect)
	if not gLackey[10].bAttackedPlayer and PlayerIsInTrigger(TRIGGER._1_08_GYMGIRLWASH) then
		--print("Prefec is gonna try to attack the player!")
		gLackey[10].bAttackedPlayer = true
	end
end

function F_RunToPrefect(ped)
	PedSetActionNode(ped, "/Global/Generic/GenericIdle/Idle", "Act/Anim/GenericSequences.act")
	local prefect = PedCreatePoint(50, POINTLIST._GYMCUTSCENELOCATIONS, 4)
	PedSetFlag(prefect, 97, true)
	PedFollowPath(ped, PATH._BATHROOMLACKEYS, 0, 2, SexyGirlRunning)
	F_PlaySpeechWait(gLackey[9].ped, "M_1_08", 13, "large")
	TutorialShowMessage("1_08_OBJ14", 4)
	QueueTextString("", 0.1, 1, false, CB_RunTutorial)
	PedFollowPath(prefect, PATH._PREFECTPATH, 2, 0, PrefectPatrolling, 1)
	PedMakeAmbient(ped)
	return prefect
end

function F_SetStageGetCake()
	PedStopSocializing(gFatty)
	nTalkedWithBucky = nTalkedWithBucky + 1
	PedSetRequiredGift(gFatty, 22, false, true)
end

function F_FattyWantsGift()
	if nTalkedWithBucky == 1 then
		return 1
	end
	return 0
end

function F_BeatriceReceivedGift()
	missionStage = MissionBeatriceReceivedNotes
end

function F_FattyWantsCake()
	if 0 < nTalkedWithBucky then
		return 0
	end
	return 1
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume, bAmbient)
	if bAmbient then
		SoundPlayAmbientSpeechEvent(pedId, strEvent)
		while SoundSpeechPlaying() do
			Wait(0)
		end
	else
		SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
		while SoundSpeechPlaying() do
			Wait(0)
		end
	end
end

local tempStimBool, tempStimTarget

function F_MonitorFatty()
	if gFatty ~= nil and PedIsValid(gFatty) and not bDropStinkBombs then
		tempStimBool, tempStimTarget = PedHasGeneratedStimulusOfType(gPlayer, 49)
		if tempStimBool and tempStimTarget == gFatty then
			while PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/HarassMoves/Humiliations", true) do
				Wait(0)
			end
			--print("The player has laughed.")
			PlayerSocialDisableActionAgainstPed(gFatty, 32, true)
			bFattyIsFleeing = true
			bDropStinkBombs = true
			bSpawnFatty = false
			missionStage = MissionStageWaitForPickup
			PedFlee(gFatty, gPlayer)
			PedMakeAmbient(gFatty)
		end
		if PedGetWhoHitMeLast(gFatty) == gPlayer and PedGetHealth(gFatty) < gFattyOriginHealth - 40 or PedIsPlaying(gFatty, "/Global/Actions/Grapples/Front/Grapples", true) then
			PlayerSocialDisableActionAgainstPed(gFatty, 32, true)
			--print("The player hit fatty.")
			bFattyIsFleeing = true
			bDropStinkBombs = true
			bSpawnFatty = false
			missionStage = MissionStageWaitForPickup
			PedClearHitRecord(gFatty)
			PedFlee(gFatty, gPlayer)
			PedMakeAmbient(gFatty)
		end
		if PedIsDoingTask(gFatty, "/Global/AI/GeneralObjectives/FleeObjective", true) then
			--print("Fatty fleed")
			PlayerSocialDisableActionAgainstPed(gFatty, 32, true)
			bFattyIsFleeing = true
			bDropStinkBombs = true
			bSpawnFatty = false
			PedMakeAmbient(gFatty)
			missionStage = MissionStageWaitForPickup
		end
		if bDropStinkBombs and gStinkBombs == nil then
			--print("Create them bitches")
			TextPrint("1_08_STINKBOMBS", 3, 1)
			MissionObjectiveComplete(gMissionObjective[table.getn(gMissionObjective)])
			table.insert(gMissionObjective, MissionObjectiveAdd("1_08_STINKBOMBS"))
			gStinkBombs = PickupCreatePoint(309, POINTLIST._1_08_STINKBOMBS, 1, 360, "1_08_StinkBombs")
			F_AddObjectiveBlip("POINT", POINTLIST._1_08_STINKBOMBS, 1, 4)
		end
	end
	if gStinkBombs ~= nil and (PickupIsPickedUp(gStinkBombs) or 0 < ItemGetCurrentNum(309)) then
		--print("Player picked up stink bombs!: ", ItemGetCurrentNum(309))
		if not PickupIsPickedUp(gStinkBombs) and gStinkBombs then
			PickupDelete(gStinkBombs)
		end
		if missionStage ~= MissionStageRigTheLocker then
			ClearTextQueue()
			QueueText("1_08_OBJ05", 4, 1)
			missionStage = F_GivePlayerStinkBombs
			F_PlayerHasStinkbombs()
		else
			F_AddObjectiveBlip("POINT", POINTLIST._GYMCUTSCENELOCATIONS, 1, 4)
			ClearTextQueue()
			QueueText("1_08_OBJ19", 3, 1)
			QueueTextString("", 0.1, 1, false, CB_TurnOnTheCheck)
			MissionObjectiveComplete(gMissionObjective[table.getn(gMissionObjective)])
			table.insert(gMissionObjective, MissionObjectiveAdd("1_08_OBJ19"))
		end
		gStinkBombs = nil
	end
end

function F_MonitorStinkBombs()
	if missionStage ~= MissionStageMeetWithFatty and not bPlayerRiggedLocker and ItemGetCurrentNum(309) == 0 and gStinkBombs == nil then
		--print("RESETTING THE OBJECTIVES!!!", tostring(bPlayerRiggedLocker))
		TextPrint("1_08_FATTYAGAIN", 3, 1)
		F_AddObjectiveBlip("POINT", POINTLIST._1_08_STINKBOMBS, 1, 4)
		while 0 < table.getn(gMissionObjective) do
			MissionObjectiveRemove(gMissionObjective[table.getn(gMissionObjective)])
			table.remove(gMissionObjective, table.getn(gMissionObjective))
			Wait(0)
		end
		gPickedUpCake = 0
		nTalkedWithBucky = 1
		gStinkBombs = nil
		bDropStinkBombs = false
		gBreakIntoMessage = false
		--print("Ran out of stinkbombs! Go get some more!")
		table.insert(gMissionObjective, MissionObjectiveAdd("1_08_FATTYAGAIN"))
		gStinkBombs = PickupCreatePoint(309, POINTLIST._1_08_STINKBOMBS, 1, 360, "1_08_StinkBombs")
		bCoronaInLocker = false
		missionStage = MissionStageWaitForPickup
	end
end

function F_GiveJimmyAKiss()
end

function F_PlayerRiggedLocker()
	if bPlayerRiggedLocker then
		return 1
	end
	return 0
end
