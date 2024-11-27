--[[ Changes to this file:
	* Modified function T_DinnerFail, may require testing
]]

local bAngryEdna = false
local tblMissionPeds = {
	{
		{}
	}
}
local tblTrashTriggers = {}
local bPerfumeDistracted, bGotPerfume, blipCandy, blipDrugs, bGotCandy, bCopSuspicious, bGotDrugs
local bDinCurrentlyDisturbed = false
local nEventsFinished = 0
local nCurrentDisturbPath = 1
local bGreaserDisturbedEarly = false
local idMoveGirl, nStage
local prepDisturbed = false
local nerdDisturbed
local bTimerRunning = false
local bSitDown = false
local bGiveInsult = false
local bSmokerWarded = false
local bNextEvent = true
local bFinishedWobble = false
local bCinPlaying = false
local bTextFinished = false
local bPlayerSpotted = false
local bInPosition = 0
local CurrentDateChoice = 1
local tblAllDateEvents = {}
local bEventPlaying = false
local bMissionFail = false
local bMissionComplete = false
local idTeacher, idTeacher2, edna, watts, smoker, fatty, candyPed1, candyPed2, idHobo, objPerfume, objLeave, objCandy, objDrugs, objReturn, objClimb, objDinner, randomCan, spawnedDrugs
local dogspawned = false
local dogspawntime = 10000
local dogspawnstart = GetTimer()
local bPuke = false
local bCandyComplete = false
local bCandyBribed = false
local CandyAttacker
local bCandyHit = false
local nCandyTalkTime = 1
local nCandyTalkIndex = 1
local candyGiven = false
local tblDialogue = {
	{ model = 40, event = 51 },
	{ model = 30, event = 50 },
	{ model = 17, event = 55 },
	{ model = 20, event = 58 },
	{ model = 4,  event = 68 },
	{ model = 9,  event = 33 },
	{ model = 14, event = 92 },
	{ model = 5,  event = 69 },
	{ model = 6,  event = 16 },
	{
		model = 67,
		event = 0,
		mis = "JEER"
	},
	{
		model = 38,
		event = 19,
		mis = "M_2_06"
	},
	{
		model = 34,
		event = 49,
		mis = "M_2_08"
	},
	{
		model = 32,
		event = 10,
		mis = "M_4_G4"
	},
	{
		model = 31,
		event = 7,
		mis = "M_3_02"
	},
	{
		model = 15,
		event = 23,
		mis = "M_2_G2"
	},
	{
		model = 13,
		event = 12,
		mis = "M_4_04"
	}
}
local tblDatalogue = {}
local idDialogueQueue
local bStand = 0
local szFailReason
local tblPedModels = {}
local tblGirlModels, tblNerdModels, tblPrepModels, tblJockModels
local tblPickupModels = {
	478,
	522,
	490
}
local tblWeaponModels = { 327 }
local tblAnnoyEvents = {
	girls = {
		group = {
			67,
			14,
			38,
			39
		},
		rate = 3,
		threshold = 0.9
	},
	nerds = {
		group = { 9, 11 },
		rate = 3.5,
		threshold = 0.8,
		reinforce = {
			4,
			5,
			6,
			11
		},
		reinforceDelay = 4000
	},
	preps = {
		group = { 30, 34 },
		rate = 3.5,
		threshold = 0.85,
		reinforce = {
			32,
			40,
			31,
			30,
			34
		},
		reinforceDelay = 5000
	},
	jocks = {
		group = {
			20,
			15,
			13
		},
		rate = 4,
		threshold = 0.8,
		reinforce = {
			17,
			13,
			16,
			15,
			20
		},
		reinforceDelay = 5000
	}
}
local DINNER_FAIL = -1
local DINNER_RUNNING = 0
local DINNER_PASS = 1
local bDinnerStatus = DINNER_RUNNING
local tblAnnoyPeds = {}
local tblAnnoySpawn = {}

function F_Debug()
	local earnie = PedCreatePoint(10, POINTLIST._2_S05_BPLAYERSTART, 1)
	while true do
		Wait(0)
		if PedIsValid(earnie) and PedIsHit(earnie, 2, 1000) then
			--print(PedGetLastHitWeapon(earnie))
		end
	end
end

function MissionSetup()
	SoundStopInteractiveStream()
	if PedIsValid(shared.gEdnaID) then
		PedClearObjectives(shared.gEdnaID)
		PedClearHitRecord(shared.gEdnaID)
	end
	MissionDontFadeIn()
end

function main()
	while not nStage do
		--print("[Jason] Populating nStage....")
		Wait(0)
	end
	if nStage == 1 then
		PlayCutsceneWithLoad("2-S05", true, true)
	end
	nEdnaModel = 58
	DATLoad("2_S05.DAT", 2)
	DATInit()
	LoadAnimationGroup("2_S05_CooksCrush")
	LoadAnimationGroup("Hobos")
	LoadActionTree("Act/Conv/2_S05.act")
	if nStage == 2 then
		if IsMissionFromDebug() then
			AreaTransitionPoint(0, POINTLIST._2_S05_DINCLIMBPOINT)
		end
		DisablePunishmentSystem(true)
		LoadAnimationGroup("Px_Ladr")
		LoadAnimationGroup("Px_Tree")
	end
	CreateThread("T_MissionFail")
	F_PopulateTables()
	if nStage == 1 then
		tblPedModels = {
			nEdnaModel,
			106,
			64,
			157,
			6,
			155,
			9
		}
		PAnimCreate(TRIGGER._2_S05_TRASHCAN1, true)
		PAnimCreate(TRIGGER._2_S05_TRASHCAN2, true)
		PAnimCreate(TRIGGER._2_S05_TRASHCAN3, true)
		LoadModels(tblPedModels)
		LoadModels(tblPickupModels)
		LoadModels({ 327 }, true)
		SoundPlayInteractiveStream("MS_SearchingLow.rsm", MUSIC_DEFAULT_VOLUME)
		SoundSetMidIntensityStream("MS_SearchingMid.rsm", MUSIC_DEFAULT_VOLUME)
		SoundSetHighIntensityStream("MS_SearchingHigh.rsm", MUSIC_DEFAULT_VOLUME)
		F_StartCounter(3)
		F_SetupMission()
		CreateThread("F_GetPerfume")
		F_GetDowntownStuff()
		F_ReturnItemsToEdna()
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		CameraFade(500, 0)
		Wait(501)
		CameraReset()
		CameraReturnToPlayer()
		CameraSetWidescreen(false)
		PlayerSetPosPoint(POINTLIST._2_S05_ENDPOS, 2)
		Wait(500)
		MissionSucceed(true, false, false)
	elseif nStage == 2 then
		F_RainBeGone()
		SoundDisableSpeech_ActionTree()
		SoundPlayInteractiveStream("MS_Candidate.rsm", 0.6)
		tblPedModels = { nEdnaModel, 106 }
		tblGirlModels = {
			67,
			14,
			38,
			39
		}
		tblNerdModels = {
			9,
			11,
			4,
			5,
			6
		}
		tblPrepModels = {
			30,
			34,
			32,
			40,
			31
		}
		tblJockModels = {
			20,
			15,
			17,
			13,
			16,
			12
		}
		LoadModels(tblPedModels)
		CameraReturnToPlayer()
		PlayerSetControl(0)
		PlayerFaceHeadingNow(0)
		CameraReturnToPlayer()
		CameraFade(1000, 1)
		PlayerSetControl(1)
		F_MeetEdnaInRichArea()
		F_EdnaWattsDinner()
		PickupCreatePoint(462, POINTLIST._2_S05_DOLLAR, 1, 0)
	end
end

function MissionCleanup()
	PedHideHealthBar()
	PedShowHealthBarInFPmode(false)
	PedSetHealthBarQuiet(false)
	WeatherRelease()
	SoundEnableSpeech_ActionTree()
	DisablePunishmentSystem(false)
	SoundStopInteractiveStream()
	CameraSetWidescreen(false)
	F_MakePlayerSafeForNIS(false)
	PlayerSetControl(1)
	ItemSetCurrentNum(522, 0)
	ItemSetCurrentNum(490, 0)
	CounterUseMeter(false)
	CounterMakeHUDVisible(false)
	AreaSetDoorLocked("DT_ischool_Staff", true)
	RadarRestoreMinMax()
	DATUnload(2)
	BlipRemove(blipCandy)
	BlipRemove(blipDrugs)
	UnLoadAnimationGroup("2_S05_CooksCrush")
	UnLoadAnimationGroup("Hobos")
	UnLoadAnimationGroup("Px_Ladr")
	UnLoadAnimationGroup("Px_Tree")
end

function F_SetupMission()
	AreaTransitionPoint(2, POINTLIST._2_S05_PLAYERSTART)
	CameraReturnToPlayer()
	Wait(3000)
	if PedIsValid(shared.gEdnaID) then
		PedDelete(shared.gEdnaID)
		shared.gEdnaID = edna
	end
	edna = PedCreatePoint(nEdnaModel, POINTLIST._2_S05_OUTSIDECAFE)
	PedSetFlag(edna, 133, false)
	PedSetMissionCritical(edna, true, cbFail, true)
	PedIgnoreStimuli(edna, true)
	CameraFade(1000, 1)
end

function F_GetPerfume()
	local blipPerfume = BlipAddPoint(POINTLIST._2_S05_PERFUME, 0)
	local perfume
	local bTeachersLeftLounge = false
	local bValidPed, objGetTeachersAway
	local msgStaffRoom = false
	local enteredRoom = false
	local bTeachCreated = false
	local bBumped = false
	objPerfume = MissionObjectiveAdd("2_S05_O1", 0, -1)
	if PlayerHasItem(478) then
		TextPrint("2_S05_OITEMS2", 4, 1)
	else
		TextPrint("2_S05_OPERFUME", 4, 1)
	end
	PedSocialOverrideLoad(24, "Mission/2_S05WantGift.act")
	idTeacher = PedCreatePoint(106, POINTLIST._2_S05_PLAYERKICKEDOUT)
	idTeacher2 = PedCreatePoint(64, POINTLIST._2_S05_PLAYERKICKEDOUT, 2)
	PedSetGrappleTarget(idTeacher2, idTeacher)
	local bHattrickSpeak = false
	while not bGotPerfume or AreaGetVisible() == 23 do
		if not bTeachersLeftLounge then
			if not SoundSpeechPlaying(idTeacher) and not SoundSpeechPlaying(idTeacher2) then
				if bHattrickSpeak then
					SoundPlayScriptedSpeechEvent(idTeacher2, "CONVERSATION_NEGATIVE_PERSONAL", 0, "medium", false)
					bHattrickSpeak = false
				else
					bHattrickSpeak = true
					SoundPlayScriptedSpeechEvent(idTeacher, "CONVERSATION_NEGATIVE_REPLY", 0, "medium", false)
					Wait(4000)
				end
			end
			if not msgStaffRoom and PlayerIsInAreaObject(idTeacher, 2, 20, 0) then
				TextPrint("2_S05_O2", 4, 1)
				objGetTeachersAway = MissionObjectiveAdd("2_S05_O2", 0, -1)
				msgStaffRoom = true
			end
			if not bBumped then
				if PedIsValid(idTeacher) then
					if PedHasGeneratedStimulusOfType(idTeacher, 18) then
						PlayerSetPunishmentPoints(PlayerGetPunishmentPoints() + 150)
						bBumped = true
					end
				elseif PedIsValid(idTeacher2) and PedHasGeneratedStimulusOfType(idTeacher2, 18) then
					PlayerSetPunishmentPoints(PlayerGetPunishmentPoints() + 150)
					bBumped = true
				end
			end
			if shared.gSchoolFAlarmOn then
				if objGetTeachersAway then
					MissionObjectiveComplete(objGetTeachersAway)
				end
				PedMakeAmbient(idTeacher)
				PedMakeAmbient(idTeacher2)
				AreaSetDoorLocked("DT_ischool_Staff", false)
				bTeachersLeftLounge = true
			elseif not PedIsInTrigger(idTeacher, TRIGGER._2_S05_TEACHERAREA) and not PedIsInTrigger(idTeacher2, TRIGGER._2_S05_TEACHERAREA) then
				if objGetTeachersAway then
					MissionObjectiveComplete(objGetTeachersAway)
				end
				PedMakeAmbient(idTeacher)
				PedMakeAmbient(idTeacher2)
				AreaSetDoorLocked("DT_ischool_Staff", false)
				bTeachersLeftLounge = true
			end
		end
		if not bGotPerfume and AreaGetVisible() == 23 then
			enteredRoom = enteredRoom or GetTimer()
			if not perfume then
				BlipRemove(blipPerfume)
				perfume = PickupCreatePoint(490, POINTLIST._2_S05_PERFUME, 1, 0, "PermanentMission")
				Wait(100)
				blipPerfume = AddBlipForPickup(perfume, 0, 4)
				for i, entry in tblMissionPeds.staffroom do
					if entry.id then
						PedDelete(entry.id)
					end
				end
			elseif PickupIsPickedUp(perfume) then
				MissionObjectiveComplete(objPerfume)
				CounterIncrementCurrent(1)
				BlipRemove(blipPerfume)
				AreaSetDoorLocked("DT_ischool_Staff", true)
				bGotPerfume = true
				Wait(4000)
			end
		end
		if not bTeachCreated and enteredRoom and GetTimer() - enteredRoom >= 30000 then
			--print("Creating teachers!")
			local teacher = PedCreatePoint(106, POINTLIST._2_S05_TEACHERSPAWN)
			PedSetPunishmentPoints(gPlayer, 150)
			PedMakeAmbient(teacher)
			PedFollowPath(teacher, PATH._2_S05_TEACHERENTERPATH, 0, 2)
			enteredRoom = nil
			bTeachCreated = true
		end
		Wait(0)
	end
end

function F_GetDowntownStuff()
	local bHit = false
	local bGetDrugsMsg = false
	local bFattyMsg = false
	local bCansDisturbed = false
	local bHoboAttack = false
	local bDogAttack
	local blip1, blip2 = BlipAddPoint(POINTLIST._2_S05_FATTY, 0), BlipAddPoint(POINTLIST._2_S05_DRUGCANS, 0)
	objCandy = MissionObjectiveAdd("2_S05_O3", 0, -1)
	objDrugs = MissionObjectiveAdd("2_S05_O4", 0, -1)
	CreateThread("T_PedCreation")
	while not PedIsValid(fatty) do
		Wait(0)
		if not bGotCandy and PlayerHasItem(478) then
			--print("[JASON]", "Got the Candy.")
			if PedIsValid(fatty) then
				PedMakeAmbient(fatty)
				BlipRemove(blip1)
			end
			if PedIsValid(candyPed1) then
				PedMakeAmbient(candyPed1)
			end
			if PedIsValid(candyPed2) then
				PedMakeAmbient(candyPed2)
			end
			CounterIncrementCurrent(1)
			MissionObjectiveComplete(objCandy)
			bGotCandy = true
			BlipRemove(blip1)
		end
	end
	BlipRemove(blip1)
	blip1 = nil
	BlipRemove(blip2)
	blip2 = nil
	PedSetPedToTypeAttitude(fatty, 13, 1)
	PedSetEmotionTowardsPed(fatty, gPlayer, 4, true)
	blipDrugs = BlipAddPoint(POINTLIST._2_S05_DRUGCANS, 0)
	if not bGotCandy then
		blipCandy = AddBlipForChar(fatty, 12, 0, 4)
	end
	PedSetActionNode(idHobo, "/Global/2_S05/Anims/Drink", "Act/Conv/2_S05.act")
	randomCan = RandomTableElement(tblTrashTriggers)
	PlayerRegisterSocialCallbackVsPed(fatty, 30, F_FattyHit, true)
	PlayerRegisterSocialCallbackVsPed(fatty, 32, F_FattyGift, true)
	PedSetPedToTypeAttitude(fatty, 13, 2)
	PedSetRequiredGift(fatty, 23, false, true)
	local bCansCreated
	while not (bGotCandy and bGotDrugs) do
		if not bGotCandy then
			if not bFattyMsg and not bHit and PedIsValid(fatty) and PedIsInAreaObject(gPlayer, fatty, 2, 5, 0) then
				SoundPlayScriptedSpeechEvent(fatty, "M_2_S05", 13, "jumbo", false, false)
				bFattyMsg = true
			end
			if PedIsValid(fatty) and PedGetHealth(fatty) < PedGetMaxHealth(fatty) and not bHit then
				bHit = true
				PedOverrideStat(fatty, 6, 0)
				PedAttackPlayer(fatty, 3)
				PedSetPedToTypeAttitude(fatty, 13, 0)
				PedSetRequiredGift(fatty, 0)
				SoundPlayScriptedSpeechEvent(fatty, "M_2_S05", 15, "jumbo", false)
				if PedIsValid(candyPed1) then
					PedMakeAmbient(candyPed1)
					PedAttackPlayer(candyPed1)
				end
				if PedIsValid(candyPed2) then
					PedMakeAmbient(candyPed2)
					PedAttackPlayer(candyPed2)
				end
				PedSetPedToTypeAttitude(candyPed1, 13, 0)
				PedSetPedToTypeAttitude(candyPed2, 13, 0)
				PedSetPedToTypeAttitude(fatty, 13, 0)
				BlipRemove(blipCandy)
				blipCandy = AddBlipForChar(fatty, 12, 26, 4)
				Wait(3000)
				F_Speech(candyPed1, 16)
			end
			if PlayerHasItem(478) then
				--print("[JASON]", "Got the Candy.")
				if PedIsValid(fatty) then
					PedMakeAmbient(fatty)
					BlipRemove(blipCandy)
				end
				if PedIsValid(candyPed1) then
					PedMakeAmbient(candyPed1)
				end
				if PedIsValid(candyPed2) then
					PedMakeAmbient(candyPed2)
				end
				CounterIncrementCurrent(1)
				MissionObjectiveComplete(objCandy)
				BlipRemove(blipCandy)
				bGotCandy = true
			end
			if PedIsValid(fatty) and PedHasReceivedGift(fatty) then
				candyGiven = true
				GiveItemToPlayer(478)
				PedOverrideStat(fatty, 1, 0)
			end
		end
		if not bGotDrugs then
			if not PlayerHasItem(522) then
				for i, entry in tblTrashTriggers do
					if PAnimIsDestroyed(entry) then
						bCansDisturbed = true
						if entry == randomCan then
							if not spawnedDrugs then
								local x, y, z = GetAnchorPosition(randomCan)
								spawnedDrugs = PickupCreateXYZ(522, x, y, z, "PermanentButes")
								--print("SPAWN DRUGS YO!")
							end
						else
							table.remove(tblTrashTriggers, i)
						end
					end
					if not bHoboAttack and 1 > PAnimGetHealth(entry) then
						if PedIsValid(idHobo) then
							PedDestroyWeapon(idHobo, 327)
							PedSetActionNode(idHobo, "/Global/2_S05/Anims/Break", "Act/Conv/2_S05.act")
							PedMakeAmbient(idHobo)
							PedAttackPlayer(idHobo, 0)
						end
						Wait(3000)
						bPuke = true
						PedSetActionNode(idHobo, "/Global/2_S05/Anims/Drink/Puke/Load", "Act/Conv/2_S05.act")
						bHoboAttack = true
					end
					Wait(500)
				end
			else
				--print("[JASON]", "Got the Drugs.")
				CounterIncrementCurrent(1)
				BlipRemove(blipDrugs)
				MissionObjectiveComplete(objDrugs)
				bGotDrugs = true
			end
		end
		if not bGetDrugsMsg and PlayerIsInTrigger(TRIGGER._2_S05_DRUGALLEY) then
			TextPrint("2_S05_ODRUG", 4, 1)
			bGetDrugsMsg = true
		end
		bCansDisturbed = bCansDisturbed and false
		Wait(0)
	end
	if PedIsValid(idHobo) then
		PedMakeAmbient(idHobo)
	end
	if PedIsValid(candyPed2) then
		PedMakeAmbient(candyPed2)
	end
	if PedIsValid(candyPed1) then
		PedMakeAmbient(candyPed1)
	end
	if PedIsValid(fatty) then
		PedMakeAmbient(fatty)
	end
	Wait(2000)
	while CounterGetCurrent() ~= CounterGetMax() do
		Wait(0)
	end
	TextPrint("2_S05_RETEDNA", 4, 1)
	objReturn = MissionObjectiveAdd("2_S05_O5")
end

function F_FattyHit()
	PickupCreateFromPed(478, fatty, "PermanentButes")
end

function F_FattyGift()
	SoundPlayScriptedSpeechEvent(fatty, "GIFT_RECEIVE", 0, "jumbo", false)
end

function F_PlayerGiveGiftCallback()
	TextPrintString("CALLBACK CALLED MMM RED TEXT", 4, 1)
	--print("CALLBACK CALLED!!!")
end

function F_CBCopAlley(pedid)
	if not PlayerIsInTrigger(TRIGGER._2_S05_DRUGALLEY) or not bCopSuspicious then
	else
		PedSetStealthBehavior(pedid, 1)
	end
end

function F_ReturnItemsToEdna()
	local bEdnaMoved = false
	CounterMakeHUDVisible(false)
	if PedIsValid(edna) then
		PedSetMissionCritical(edna, false)
		PedDelete(edna)
	end
	if ChapterGet() == 2 then
		nEdnaModel = 221
	else
		nEdnaModel = 58
	end
	while not PedRequestModel(nEdnaModel) do
		Wait(0)
	end
	edna = PedCreatePoint(nEdnaModel, POINTLIST._2_S05_OUTSIDECAFE, 2)
	PedSetFlag(edna, 133, false)
	PedSetMissionCritical(edna, true, cbFail, true)
	PedIgnoreStimuli(edna, true)
	blip = AddBlipForChar(edna, 12, 0, 4)
	while not PlayerIsInAreaObject(edna, 2, 7, 0, 0) do
		Wait(0)
	end
	if not bMissionFail then
		PedSetInvulnerable(edna, true)
		PlayerSetControl(0)
		CameraFade(500, 0)
		Wait(501)
		PedSetMissionCritical(edna, false)
		PedDelete(edna)
		--print(">>>[JASON]", "NOW IN RANGE OF THE EDNA")
		MissionObjectiveComplete(objReturn)
		PlayerSetPunishmentPoints(0)
		UnloadModels(tblPedModels)
		UnloadModels(tblPickupModels)
		UnloadModels({ 327 }, true)
		PlayCutsceneWithLoad("2-S05B", true, true)
		PlayerSetControl(0)
		BlipRemove(blip)
		CounterMakeHUDVisible(false)
		CameraSetWidescreen(true)
		F_MakePlayerSafeForNIS(true)
		CounterMakeHUDVisible(false)
		if PedIsValid(edna) then
			PedSetInvulnerable(edna, false)
			PedAddPedToIgnoreList(edna, gPlayer)
		end
		Wait(250)
		PlayerSetPosPoint(POINTLIST._2_S05_ENDPOS, 1)
		CameraSetXYZ(-638.11536, -276.94833, -0.385751, -638.47485, -277.88113, -0.407544)
		Wait(250)
		CameraFade(500, 1)
		Wait(501)
		bMissionComplete = true
		MinigameSetCompletion("M_PASS", true, 4000)
		SoundPlayMissionEndMusic(true, 10)
	else
		Wait(50000)
	end
end

function cbFail()
	szFailReason = "2_S05_FAILEDNA"
	if PedIsValid(edna) then
		PedMakeAmbient(edna)
	end
	bMissionFail = true
	PedHideHealthBar()
	PedShowHealthBarInFPmode(false)
end

function F_MeetEdnaInRichArea()
	local vantageBlip = BlipAddPoint(POINTLIST._2_S05_DINCLIMBPOINT, 0, 1)
	local vantageCorona = BlipAddPoint(POINTLIST._2_S05_DINCLIMBPOINT, 0, 1, 0, 7)
	local x, y, z = GetPointList(POINTLIST._2_S05_DINCLIMBPOINT)
	TextPrint("2_S05_O6", 6, 1)
	objClimb = MissionObjectiveAdd("2_S05_O6")
	MissionTimerStart(30)
	CreateThread("T_DinnerFail")
	while not bInVantage do
		if MissionTimerHasFinished() then
			szFailReason = "2_S05_FAILTIME"
			bDinnerStatus = DINNER_FAIL
			bMissionFail = true
		end
		if PlayerIsInTrigger(TRIGGER._2_S05_TREE) and PlayerIsInStealthProp() then
			Wait(700)
			bInVantage = true
		end
		Wait(0)
	end
	MissionTimerStop()
	MissionObjectiveComplete(objClimb)
	BlipRemove(vantageBlip)
	BlipRemove(vantageCorona)
	if not bMissionFail then
		Wait(1000)
		AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		AreaClearAllPeds()
		edna = PedCreatePoint(nEdnaModel, POINTLIST._2_S05_DINNEREDNA, 1)
		PedSetFlag(edna, 133, false)
		PedSetActionNode(edna, "/Global/WProps/PropInteract", "Act/WProps.act")
		watts = PedCreatePoint(106, POINTLIST._2_S05_DINNEREDNA, 2)
		PedSetPedToTypeAttitude(edna, 13, 4)
		PedSetPedToTypeAttitude(watts, 13, 4)
		PedSetPedToTypeAttitude(gPlayer, 8, 4)
		PedMakeTargetable(watts, false)
		PedMakeTargetable(edna, false)
		F_NISEdnaDate()
		AreaRevertToDefaultPopulation()
		PedSetFlag(edna, 23, true)
		PedSetFlag(edna, 19, true)
		PedSetFlag(watts, 23, true)
		PedSetFlag(watts, 19, true)
		TextPrint("2_S05_ODATE1", 4, 1)
		objDinner = MissionObjectiveAdd("2_S05_ODATE1")
	else
		PedHideHealthBar()
		PedShowHealthBarInFPmode(false)
		Wait(10000)
	end
end

function F_StartCin()
	PlayerSetInvulnerable(true)
	PlayerSetControl(0)
	CameraSetXYZ(444.482, 197.447, 10.132, 450.301, 197.406, 9.732)
	CameraSetWidescreen(true)
	bCinPlaying = true
end

function F_EndCin()
	PlayerSetInvulnerable(false)
	PlayerSetControl(1)
	CameraReturnToPlayer()
	CameraSetWidescreen(false)
	bNextEvent = true
	bPlayingAnim = false
	bCinPlaying = false
end

function F_PauseTextAdvanceEvent()
	if not bCinPlaying then
		bCinPlaying = true
	elseif bCinPlaying then
		Wait(3000)
		bNextEvent = true
		bPlayingAnim = false
		bCinPlaying = false
	end
end

function F_StopTimer()
	if bTimerRunning then
		MissionTimerStop()
		MissionTimerPause(true)
		bTimerRunning = false
	end
end

function F_StartTimer()
	if not bTimerRunning then
		MissionTimerStart(5)
		MissionTimerPause(false)
		TextPrint("2_S05_OPROTDATE", 4, 1)
		bTimerRunning = true
	end
end

function T_PedCreation()
	while not PlayerIsInTrigger(TRIGGER._AMB_BUSINESS_AREA) do
		Wait(0)
	end
	idHobo = F_StreamCreatePed(157, POINTLIST._2_S05_BUM, 1)
	candyPed1, candyPed2 = F_StreamCreatePed(6, POINTLIST._2_S05_FATTY, 2), F_StreamCreatePed(9, POINTLIST._2_S05_FATTY, 3)
	fatty = F_StreamCreatePed(155, POINTLIST._2_S05_FATTY, 1)
	PedOverrideStat(fatty, 0, 478)
	PedOverrideStat(fatty, 1, 100)
	--print("registering fatty callback")
end

function F_StreamCreatePed(model, point, element)
	return PedCreatePoint(model, point, element)
end

function F_NISEdnaDate()
	F_DeleteUnusedVehicles(447.6, 196, 8.4, 5)
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	CameraSetSpeed(2.3, 2.3, 0.75)
	CameraLookAtPathSetSpeed(2.3, 2.3, 0.75)
	CameraSetPath(PATH._2_S05_CINDIN1, true)
	CameraLookAtPath(PATH._2_S05_CINDIN2, true)
	PedFollowPath(watts, PATH._2_S05_DINWATTSSIT, 0, 0, F_CBSitDown)
	Wait(1000)
	SoundPlayScriptedSpeechEvent(edna, "M_2_S05", 18, "large")
	while not bSitDown do
		Wait(0)
	end
	Wait(500)
	PedSetActionNode(watts, "/Global/WProps/PropInteract", "Act/WProps.act")
	Wait(3000)
	BlipRemoveFromChar(edna)
	BlipRemoveFromChar(watts)
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
end

function F_CBSitDown(pedid, pathid, nodeid)
	if nodeid == PathGetLastNode(pathid) then
		bSitDown = true
	end
end

function F_CBDisturbDinner(pedid, pathid, nodeid)
	if not bDinCurrentlyDisturbed then
		bDinCurrentlyDisturbed = true
	end
end

function F_PedIsHurt(pedid)
	if PedGetHealth(pedid) < PedGetMaxHealth(pedid) then
		return true
	else
		return false
	end
end

function F_DisableSeating()
	--print("[JASON] ======>     Disabling Seating")
	PAnimSetPropFlag("pxSitStl", 449.953, 197.932, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 448.608, 197.932, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 446.444, 197.961, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 445.268, 197.961, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 446.444, 196.917, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 445.251, 196.917, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 448.61, 196.888, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 449.93, 196.888, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 445.251, 192.463, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 446.444, 192.463, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 446.444, 193.507, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 445.268, 193.507, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 448.608, 193.507, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 448.61, 192.463, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 449.93, 192.463, 8.37797, 11, true)
	PAnimSetPropFlag("pxSitStl", 449.953, 193.507, 8.37797, 11, true)
end

function F_EnableSeating()
	PAnimSetPropFlag("pxSitStl", 449.953, 197.932, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 448.608, 197.932, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 446.444, 197.961, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 445.268, 197.961, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 446.444, 196.917, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 445.251, 196.917, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 448.61, 196.888, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 449.93, 196.888, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 445.251, 192.463, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 446.444, 192.463, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 446.444, 193.507, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 445.268, 193.507, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 448.608, 193.507, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 448.61, 192.463, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 449.93, 192.463, 8.37797, 11, false)
	PAnimSetPropFlag("pxSitStl", 449.953, 193.507, 8.37797, 11, false)
end

local nAnnoyLevel = 0
local nAnnoyDecay = 15
local nAnnoyRate = 0
local nAnnoyMax = 1000

function F_EdnaWattsDinner()
	if not bMissionFail then
		CreateThread("T_AnnoyanceMonitor")
		CreateThread("T_PlayerInTreeCheck")
		CreateThread("T_DialogueSpeech")
		F_RefreshSpawnTable()
		F_DinnerEvent(tblAnnoyEvents.girls, tblGirlModels)
		F_QueueDialogue(edna, 22)
		F_QueueDialogue(edna, 23)
		F_QueueDialogue(watts, 23)
		F_QueueDialogue(edna, 24)
		F_QueueDialogue(edna, 25)
		F_QueueDialogue(watts, 25)
		F_QueueDialogue(watts, 26)
		F_QueueDialogue(edna, 26)
		F_QueueDialogue(edna, 27)
		Wait(12000)
		F_DinnerEvent(tblAnnoyEvents.nerds, tblNerdModels)
		F_QueueDialogue(watts, 27)
		F_QueueDialogue(watts, 28)
		F_QueueDialogue(edna, 28)
		F_QueueDialogue(edna, 29)
		F_QueueDialogue(watts, 29)
		F_QueueDialogue(watts, 30)
		F_QueueDialogue(edna, 30)
		F_QueueDialogue(edna, 31)
		F_QueueDialogue(watts, 31)
		F_QueueDialogue(edna, 32)
		Wait(10000)
		F_DinnerEvent(tblAnnoyEvents.preps, tblPrepModels)
		F_QueueDialogue(edna, 82)
		F_QueueDialogue(edna, 84)
		F_QueueDialogue(watts, 85)
		F_QueueDialogue(watts, 87)
		F_QueueDialogue(edna, 88)
		F_QueueDialogue(watts, 89)
		Wait(9000)
		F_DinnerEvent(tblAnnoyEvents.jocks, tblJockModels)
		while bDinnerStatus ~= DINNER_PASS do
			if table.getn(tblDatalogue) == 0 and not SoundSpeechPlaying(watts) and not SoundSpeechPlaying(edna) then
				bDinnerStatus = DINNER_PASS
			end
			--print("PEDS LEF: " .. table.getn(tblAnnoyPeds) .. "      LINES LEFT: " .. table.getn(tblDatalogue))
			Wait(0)
		end
		Wait(1000)
		MissionObjectiveComplete(objDinner)
		CounterUseMeter(false)
		CounterMakeHUDVisible(false)
		for i, entry in tblAnnoyPeds do
			if entry.id and PedIsValid(entry.id) then
				PedDelete(entry.id)
			end
		end
		UnLoadAnimationGroup("Px_Ladr")
		UnLoadAnimationGroup("Px_Tree")
		UnLoadAnimationGroup("2_S05_CooksCrush")
		UnLoadAnimationGroup("Hobos")
		UnloadModels(tblPedModels)
		PlayCutsceneWithLoad("2-S05C", false, false, true, true)
		if PedIsValid(edna) then
			PedDelete(edna)
		end
		if PedIsValid(watts) then
			PedDelete(watts)
		end
		CameraSetWidescreen(true)
		CameraReturnToPlayer()
		CameraFade(500, 1)
		Wait(501)
		SoundPlayMissionEndMusic(true, 10)
		MissionSucceed(false, true, true, 5000)
	end
end

function T_DinnerFail() -- ! Modified
	while bDinnerStatus ~= DINNER_FAIL do
		Wait(0)
	end
	--[[
	PlayerSetControl(0)
	CameraFollowPed(gPlayer)
	CameraReset()
	CameraReturnToPlayer(true)
	]] -- Not present in original script
	SoundPlayMissionEndMusic(false, 10)
	if szFailReason then
		MissionFail(false, true, szFailReason)
	else
		MissionFail(false)
	end
end

function F_DinnerEvent(tblEvent, tblModelsToLoad)
	local pointlist = POINTLIST._2_S05_DINANNOYSPAWN
	local rated = tblEvent.rate
	local thresh = tblEvent.threshold
	LoadModels(tblModelsToLoad)
	for i, entry in tblEvent.group do
		if CounterGetCurrent() < CounterGetMax() then
			local element, path = F_GetSpawnPath()
			local ped = PedCreatePoint(entry, pointlist, element)
			table.insert(tblAnnoyPeds, {
				id = ped,
				rate = rated,
				threshold = thresh
			})
			PedSetMinHealth(ped, 0.5)
			PedIgnoreAttacks(ped, true)
			PedIgnoreStimuli(ped, true)
			PedSetPedToTypeAttitude(ped, 13, 0)
			PedFollowPath(ped, path, 0, 1, cbAnnoy)
		end
	end
	if tblEvent.reinforce and CounterGetCurrent() < CounterGetMax() then
		for i, entry in tblEvent.reinforce do
			Wait(tblEvent.reinforceDelay)
			local element, path = F_GetSpawnPath()
			local ped = PedCreatePoint(entry, pointlist, element)
			table.insert(tblAnnoyPeds, {
				id = ped,
				rate = rated,
				threshold = thresh
			})
			PedSetMinHealth(ped, 0.5)
			PedIgnoreAttacks(ped, true)
			PedIgnoreStimuli(ped, true)
			PedSetPedToTypeAttitude(ped, 13, 0)
			PedFollowPath(ped, path, 0, 1, cbAnnoy)
		end
	end
	UnloadModels(tblModelsToLoad)
end

function cbAnnoy(pedid, pathid, nodeid)
	if nodeid == 2 and bDinnerStatus ~= DINNER_FAIL then
		--print("[cbAnnoy] >> CALLBACK fired")
		for i, entry in tblDialogue do
			if PedIsModel(pedid, entry.model) then
				if entry.mis then
					--print("[cbAnnoy] >> SPEECH " .. entry.mis)
					SoundPlayScriptedSpeechEvent(pedid, entry.mis, entry.event, "medium", true)
				else
					--print("[cbAnnoy] >> SPEECH 2_S05")
					SoundPlayScriptedSpeechEvent(pedid, "M_2_S05", entry.event, "medium", true)
				end
			end
		end
	end
end

function T_AnnoyanceMonitor()
	CounterSetCurrent(0)
	CounterSetMax(nAnnoyMax)
	CounterUseMeter(true)
	CounterMakeHUDVisible(false)
	PedSetMaxHealth(edna, nAnnoyMax)
	PedSetMinHealth(edna, nAnnoyDecay)
	PedShowHealthBar(edna, true, "N_Edna", false)
	PedSetHealthBarQuiet(true)
	PedShowHealthBarInFPmode(true)
	local time = 0
	while CounterGetCurrent() < CounterGetMax() and bDinnerStatus ~= DINNER_PASS do
		Wait(0)
		for i, entry in tblDialogue do
			if PedIsValid(tblDialogueQueue) and PedIsModel(tblDialogueQueue, entry.model) then
				F_Speech(tblDialogueQueue, entry.event, entry.mis)
				tblDialogueQueue = nil
			end
		end
		nAnnoyRate = F_FindAnnoyRate(tblAnnoyPeds)
		if 0 < nAnnoyRate then
			nAnnoyLevel = F_TruncateNegative(nAnnoyLevel + nAnnoyRate)
		else
			nAnnoyLevel = F_TruncateNegative(nAnnoyLevel - nAnnoyDecay)
		end
		if nAnnoyLevel >= nAnnoyMax or bAngryEdna then
			--print("[T_AnnoyanceMonitor]", "EDNA IS MAD")
			PedHideHealthBar()
			PedShowHealthBarInFPmode(false)
			bAngryEdna = false
			szFailReason = "2_S05_FAILMAD"
			bDinnerStatus = DINNER_FAIL
			F_AngryEdna()
			Wait(2000)
			F_Speech(watts, 77)
			Wait(1000)
			break
		else
			newTime = GetTimer()
			if newTime > time + 50 then
				PedSetHealth(edna, nAnnoyMax - nAnnoyLevel)
				time = newTime
			end
		end
	end
	for i, entry in tblAnnoyPeds do
		if entry.blip then
			BlipRemove(entry.blip)
		end
	end
	PedHideHealthBar()
	PedShowHealthBarInFPmode(false)
	--print("T_AnnoyanceMonitor:: FINISHED")
end

function F_FindAnnoyRate(tblTable)
	if table.getn(tblTable) > 0 then
		local annoyRate = 0
		Wait(30)
		for i, entry in tblTable do
			if PedIsValid(entry.id) then
				if PedGetHealth(entry.id) / PedGetMaxHealth(entry.id) < entry.threshold then
					PedSetFlag(entry.id, 13, true)
					PedClearTether(entry.id)
					PedMakeAmbient(entry.id)
					PedFollowPath(entry.id, PATH._2_S05_DINPEDFLEE, 0, 1)
					if entry.blip then
						BlipRemove(entry.blip)
						entry.blip = nil
					end
					table.remove(tblTable, i)
					--print("annoy ped health too low, removing from table!!")
				elseif PedIsInTrigger(entry.id, TRIGGER._2_S05_DISTURBRADIUS) then
					annoyRate = annoyRate + entry.rate
					if not entry.blip then
						entry.blip = AddBlipForChar(entry.id, 12, 26, 4)
					end
					if not F_PedIsHitWithWeapon(entry.id, 309) and not PedIsPlaying(entry.id, "/Global/2_S05/Anims/Disturb/Gawk", true) then
						PedFaceObjectNow(entry.id, edna, 2)
						Wait(10)
						PedSetActionNode(entry.id, "/Global/2_S05/Anims/Disturb/Gawk", "Act/Conv/2_S05.act")
					end
				end
			end
		end
		if 8 < annoyRate then
			annoyRate = 8
		end
		return annoyRate
	end
	return 0
end

function PedIsInAreaPoint(ped, point, radius)
	local x, y, z = GetPointList(point)
	return PedIsInAreaXYZ(ped, x, y, z, radius, 0)
end

function F_TruncateNegative(number)
	if number < 0 then
		return 0
	else
		return number
	end
end

function T_PlayerInTreeCheck()
	--print("Jason", "T_PlayerInTreeCheck started")
	local x, y, z = GetPointList(POINTLIST._2_S05_DINCLIMBPOINT)
	local blipVantage
	while bDinnerStatus == DINNER_RUNNING do
		Wait(0)
		if PlayerIsInTrigger(TRIGGER._2_S05_TREE2) then
			if blipVantage then
				BlipRemove(blipVantage)
				MissionTimerStop()
				blipVantage = nil
			end
		else
			if not blipVantage then
				blipVantage = BlipAddXYZ(x, y, z, 0)
				TextPrint("2_S05_OBRANCH", 4, 1)
				MissionTimerStart(30)
			end
			PlayerIsInAreaXYZ(x, y, z, 3, 7)
			if MissionTimerHasFinished() then
				bDinnerStatus = DINNER_FAIL
			end
		end
	end
end

function F_GetSpawnPath(pointindex)
	if table.getn(tblAnnoySpawn) < 2 then
		F_RefreshSpawnTable()
	end
	local nPick = math.random(1, table.getn(tblAnnoySpawn))
	local retElement, retPath = tblAnnoySpawn[nPick].element, tblAnnoySpawn[nPick].path
	table.remove(tblAnnoySpawn, nPick)
	return retElement, retPath
end

function F_AngryEdna()
	local idChase
	SoundStopCurrentSpeechEvent()
	SoundRemoveAllQueuedSpeech(edna, true)
	SoundRemoveAllQueuedSpeech(watts, true)
	Wait(500)
	SoundStopCurrentSpeechEvent()
	F_Speech(edna, 75)
	SoundRemoveAllQueuedSpeech(edna, true)
	SoundRemoveAllQueuedSpeech(watts, true)
	PedSetActionNode(edna, "/Global/2_S05/Anims/DateActions/GetUp", "Act/Conv/2_S05.act")
	PedSetActionNode(watts, "/Global/2_S05/Anims/DateActions/GetUp", "Act/Conv/2_S05.act")
	Wait(1500)
	F_Speech(edna, 76)
	Wait(1500)
	if table.getn(tblAnnoyPeds) > 0 then
		idChase = RandomTableElement(tblAnnoyPeds).id
		PedMakeAmbient(edna)
		PedMakeAmbient(watts)
		PedClearObjectives(edna)
		PedClearObjectives(watts)
		PedFollowPath(edna, PATH._2_S05_DINPEDFLEE, 0, 2)
		Wait(500)
		for i, entry in tblAnnoyPeds do
			PedMakeAmbient(entry.id)
			PedClearObjectives(entry.id)
			PedSetActionNode(entry.id, "/Global/2_S05/Anims/Break", "Act/Conv/2_S05.act")
			PedFlee(entry.id, edna)
		end
	end
end

function F_GoMascotGo()
	local ped = PedCreatePoint(88, POINTLIST._2_S05_SURPRISE)
	table.insert(tblAnnoyPeds, {
		id = ped,
		rate = 8,
		threshold = 0.9
	})
	PedIgnoreAttacks(ped, true)
	PedIgnoreStimuli(ped, true)
	PedFollowPath(ped, PATH._2_S05_SURPRISE, 0, 1, cbAnnoyMascot)
end

function cbAnnoyMascot(pedid, pathid, nodeid)
	if nodeid == PathGetLastNode(pathid) then
		PedSetActionNode(pedid, "/Global/2_S05/Anims/Disturb/MascotDance", "Act/Conv/2_S05.act")
		tblDialogueQueue = pedid
		--print("cbAnnoyMascot", "Does nothing.")
	end
end

function drvFireAlarmCheck()
	if shared.gSchoolFAlarmOn == true then
		return 1
	else
		return 0
	end
end

function drvAmbientTeachers()
	if PedIsValid(idTeacher) then
		PedMakeAmbient(idTeacher)
	end
	if PedIsValid(idTeacher2) then
		PedMakeAmbient(idTeacher2)
	end
end

function F_StartCounter(countermax)
	CounterMakeHUDVisible(true)
	CounterSetCurrent(0)
	CounterSetMax(3)
	CounterSetText("2_S05_EDNA_ITEMS")
	CounterSetTextXYOffset(0, 0)
end

function PlayerIsInAreaPoint(point, proximity, coronatype)
	local x, y, z = GetPointList(point)
	if PlayerIsInAreaXYZ(x, y, z, proximity, coronatype) then
		return true
	else
		return false
	end
end

function F_DistanceBetweenPeds(ped1, ped2)
	local X1, Y1, _ = PedGetPosXYZ(ped1)
	local X2, Y2, _ = PedGetPosXYZ(ped2)
	return DistanceBetweenCoords2d(X1, Y1, X2, Y2)
end

function F_CreatePedsOffArea(pedtable, bGravity)
	for _, entry in pedtable do
		entry.id = PedCreatePoint(entry.model, entry.point, entry.element)
		--print("Created : " .. entry.id)
		if not bGravity then
		end
		if entry.stealth then
			PedSetIsStealthMissionPed(entry.id)
			PedSetStealthBehavior(entry.id, 0, F_CBCopAlley)
		end
		if entry.path then
			PedFollowPath(entry.id, entry.path, 2, 0)
		end
		if entry.animation then
			PedSetActionNode(entry.id, entry.animation, "Act/Conv/2_S05.act")
		end
	end
end

function F_PopulateTables()
	tblMissionPeds = {
		staffroom = {
			{
				id = nil,
				model = 151,
				point = POINTLIST._2_S05_STAFFROOMTEACHERS,
				element = 1
			},
			{
				id = nil,
				model = 64,
				point = POINTLIST._2_S05_STAFFROOMTEACHERS,
				element = 2
			}
		},
		business = {
			fatty = {
				id = nil,
				model = 155,
				point = POINTLIST._2_S05_FATTY,
				element = 1
			}
		}
	}
	tblTrashTriggers = {
		TRIGGER._2_S05_TRASHCAN1,
		TRIGGER._2_S05_TRASHCAN2,
		TRIGGER._2_S05_TRASHCAN3
	}
end

local targets = {}

function drvPuke()
	if bPuke then
		return 1
	else
		return 0
	end
end

targets = {
	{ target = -1 },
	{ target = -1 },
	{ target = -1 },
	{ target = -1 }
}

function F_FindValidPedPoint(point, proximity)
	local x2, y2, z2 = GetPointList(point)
	target, targets[1].target, targets[2].target, targets[3].target = PedFindInAreaXYZ(x2, y2, z2, proximity)
	for i = table.getn(targets), 1, -1 do
		if PedIsValid(targets[i].target) then
			--print("RETURNING: " .. targets[i].target)
			return targets[i].target
		end
	end
	return false
end

function F_SetStage(param)
	nStage = param
end

function socFollow(param)
	candyGiven = true
end

function socWantGift()
end

function socFollow2(param)
	--print("[JASON]", "socFollow2 fired")
end

function socTeacher()
	--print("[JASON]", "socTeacher")
end

function T_MissionFail()
	while not bMissionComplete do
		Wait(0)
		if PedIsValid(watts) and (PedGetWhoHitMeLast(watts) or PedGetWhoHitMeLast(edna)) == gPlayer then
			szFailReason = "2_S05_HITTEACH"
			bAngryEdna = true
			bMissionFail = true
		end
		if PedIsValid(shared.gEdnaID) and PedGetWhoHitMeLast(shared.gEdnaID) == gPlayer then
			bMissionFail = true
		end
		if bMissionFail then
			bMissionComplete = true
		end
	end
	if bMissionFail then
		PedHideHealthBar()
		PedShowHealthBarInFPmode(false)
		SoundPlayMissionEndMusic(false, 10)
		if szFailReason then
			MissionFail(true, true, szFailReason)
		else
			MissionFail(true)
		end
	end
end

function F_Speech(speaker, event, mis)
	if PedIsValid(speaker) then
		if mis then
			SoundPlayScriptedSpeechEvent(speaker, mis, event, "jumbo")
		else
			SoundPlayScriptedSpeechEvent(speaker, "M_2_S05", event, "jumbo")
		end
	end
end

function T_DialogueSpeech()
	while not (bDinnerStatus == (DINNER_PASS or DINNER_FAIL) or bMissionFail or bAngryEdna) do
		Wait(0)
		if 0 < table.getn(tblDatalogue) and CounterGetCurrent() < CounterGetMax() and not SoundSpeechPlaying(edna) and not SoundSpeechPlaying(watts) and bDinnerStatus ~= DINNER_FAIL then
			--print(">>> PLAYING SPEECH ON ", tostring(tblDatalogue[1].id), tblDatalogue[1].event)
			SoundPlayScriptedSpeechEvent(tblDatalogue[1].id, "M_2_S05", tblDatalogue[1].event, "jumbo")
			table.remove(tblDatalogue, 1)
		end
	end
end

function F_QueueDialogue(speaker, nEvent)
	if bDinnerStatus ~= DINNER_FAIL then
		table.insert(tblDatalogue, { id = speaker, event = nEvent })
	else
		--print("F_QueueDialogue:: CLEARING DATALOGUE TABLE")
		tblDatalogue = {}
	end
end

function F_KeepSitting()
	return bStand
end

function F_RefreshSpawnTable()
	tblAnnoySpawn = {
		{
			point = nil,
			element = 1,
			path = PATH._2_S05_DINANNOYPATH
		},
		{
			point = nil,
			element = 2,
			path = PATH._2_S05_DINANNOYPATH2
		},
		{
			point = nil,
			element = 3,
			path = PATH._2_S05_DINANNOYPATH3
		},
		{
			point = nil,
			element = 4,
			path = PATH._2_S05_DINANNOYPATH4
		},
		{
			point = nil,
			element = 5,
			path = PATH._2_S05_DINANNOYPATH5
		},
		{
			point = nil,
			element = 6,
			path = PATH._2_S05_DINANNOYPATH6
		},
		{
			point = nil,
			element = 2,
			path = PATH._2_S05_DINANNOYPATH9
		},
		{
			point = nil,
			element = 3,
			path = PATH._2_S05_DINANNOYPATH7
		},
		{
			point = nil,
			element = 2,
			path = PATH._2_S05_DINANNOYPATH8
		}
	}
end

function F_PedIsHitWithWeapon(ped, weapon)
	if PedIsValid(ped) and PedIsHit(ped, 2, 500) and PedGetLastHitWeapon(ped) == weapon then
		return true
	end
end

function F_DeleteUnusedVehicles(x, y, z, radius)
	local tblFoundPeds = {}
	local tblFoundVehicles = {}
	tblFoundPeds = {
		PedFindInAreaXYZ(x, y, z, radius)
	}
	tblFoundVehicles = VehicleFindInAreaXYZ(x, y, z, radius, false)
	--print(tostring(tblFoundPeds), tostring(tblFoundVehicles))
	if tblFoundVehicles then
		for i, vehicle in tblFoundVehicles do
			local bDelete = true
			for _, ped in tblFoundPeds do
				--print("TESTING VEHICLE", i, "PED", _)
				if PedIsValid(ped) and PedIsInVehicle(ped, vehicle) then
					--print("TESTING VEHICLE", i, "PED", _, "** PASSED **")
					bDelete = false
				end
			end
			if bDelete then
				--print("DELETING VEHICLE", i)
				VehicleDelete(vehicle)
			end
		end
	end
end
