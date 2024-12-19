--[[ Changes to this file:
	* Modified function LockStores, may require testing
	* Modified function Intro, may require testing
]]

ImportScript("Library/LibTable.lua")
ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibPlayer.lua")
ImportScript("Library/LibHud.lua")
ImportScript("Library/LibTagging.lua")
local attempts = GetMissionCurrentAttemptCount()
local TIER1 = 0
local TIER2 = 1
local TIER3 = 2
local gCurrentTier
local MISSION_RUNNING = 0
local MISSION_PASSED = 1
local MISSION_FAILED = 2
local gMissionState = MISSION_RUNNING
local inGraffitiArea = true
local gExitTimer
local GAMEAREA_RETURN_DELAY = 8500
local tagCount = 0
local gTimeLimit = 0
local tblObjective, tblSchoolTagLocation, tblDowntownTagLocation, tblPoorAreaTagLocation
local bFoundAttacker = false
local bProcessNumbers = true
local bFindingClosest = true
local TotalCleanedTags = 0
local tblCurrentTags = {}
local gObj, gObjectiveStr
local gTagLimit = 0
local WbrushAct = "Act/Props/Wbrush.act"
local PrepTags = "/Global/WBrush/Tagged/PrepMed"
local JockTags = "/Global/WBrush/Tagged/JockMed"
local NerdTags = "/Global/WBrush/Tagged/NerdMed"
local tagFactions = {
	PrepTags,
	JockTags,
	NerdTags
}
local dropModels = {}
local jockModels = {}
local greaseModels = {}
local bPlayerBusted = false
local gBasePunishment = 0

function F_SetupPunishmentTier(tier)
	gCurrentTier = tier
	--print(">>>[RUI]", "F_SetupPunishmentTier: " .. tier)
end

function UpdateObjectiveLog(newObjStr, oldObj)
	local newObj
	if newObjStr then
		newObj = MissionObjectiveAdd(newObjStr)
		TextPrint(newObjStr, 3, 1)
	end
	if oldObj ~= nil then
		MissionObjectiveComplete(oldObj)
		--print(">>>[RUI]", "!!UpdateObjectiveLog close old obj")
	end
	return newObj
end

function PedExists(ped)
	return ped and PedIsValid(ped) and not (PedGetHealth(ped) <= 0)
end

function PedIsHitByPlayer(ped)
	if not PedExists(ped) then
		return false
	end
	PedClearHitRecord(ped)
	Wait(5)
	return PedIsHit(ped, 2, 500) and PedGetWhoHitMeLast(ped) == gPlayer
end

function SetDropModels()
	--print(">>>[RUI]", "!!SetDropModels")
	dropModels = {
		41,
		42,
		43,
		44,
		45,
		46,
		47,
		48,
		75,
		91
	}
end

function SetJockModels()
	--print(">>>[RUI]", "!!SetJockModels")
	jockModels = {
		12,
		13,
		14,
		15,
		16,
		17,
		18,
		19,
		20
	}
end

function SetGreaseModels()
	--print(">>>[RUI]", "!!SetGreaseModels")
	greaseModels = {
		21,
		22,
		23,
		24,
		25,
		26,
		27,
		28,
		29
	}
end

function KillMission()
	--print(">>>[RUI]", "++KillMission")
	gMissionState = MISSION_FAILED
end

function TableInit()
	--print(">>>[RUI]", "!!TableInit")
	tblObjective = {
		cleanupGraffiti = {
			successConditions = { TagCleanupMonitor },
			stopOnCompleted = true
		},
		timedOut = {
			failureConditions = { MissionTimerHasFinished },
			failActions = { KillMission },
			stopOnFailed = true
		},
		busted = {
			failureConditions = { PlayerBusted },
			failActions = { KillMission },
			stopOnFailed = true
		},
		prefectAttacked = {
			failureConditions = { PrefectHitByPlayer },
			failActions = { KillMission },
			stopOnFailed = true
		},
		leftGameArea = {
			failureConditions = { PlayerLeftGameAreaTimedOut },
			failActions = { KillMission },
			stopOnFailed = true
		}
	}
end

function SetupTagsForTier(tblTierTags)
	UsingTags = RandomTableElement(tagFactions)
	for _, tagLoc in tblTierTags do
		tag = {
			id = tagLoc.trigger,
			bCheckTag = true,
			startNode = UsingTags,
			startFile = WbrushAct,
			blip = nil,
			factionTag = UsingTags,
			name = tagLoc.name
		}
		table.insert(tblCurrentTags, tag)
	end
	--print(">>>[RUI]", "++SetupTagsForTier, tagFaction: " .. UsingTags)
end

function SetupDifficulty(tier)
	if tier == TIER1 then
		--print(">>>[RUI]", "!!SetupDifficulty:  new TIER1")
		local tblSchoolInteriorTagLocation = {
			{
				trigger = TRIGGER._SG_MEDIUM02,
				name = "TRIGGER._SG_MEDIUM02"
			},
			{
				trigger = TRIGGER._SG_MEDIUM03,
				name = "TRIGGER._SG_MEDIUM03"
			},
			{
				trigger = TRIGGER._SG_MEDIUM04,
				name = "TRIGGER._SG_MEDIUM04"
			},
			{
				trigger = TRIGGER._SG_MEDIUM07,
				name = "TRIGGER._SG_MEDIUM07"
			},
			{
				trigger = TRIGGER._SG_MEDIUM01,
				name = "TRIGGER._SG_MEDIUM01"
			}
		}
		SetupTagsForTier(tblSchoolInteriorTagLocation)
		gTagLimit = 5
		gTimeLimit = 120
		playerStart = POINTLIST._GC1A_PSTART
		prefectStart = POINTLIST._GC1A_PREFECTSTART
		guardModel = 50
		gExitPath = PATH._GC1A_EXITPATH
		gStartCamera = PATH._GC1A_CAMERA
		gGameArea = TRIGGER._GC1A_GAMEAREA
		gCameraSetup = Tier1CameraSetup
		SetGreaseModels()
		gPrefectLine = "P_GRAF_T1_01"
		gJimmyLine = "P_GRAF_T1_02"
		gObjectiveStr = "GRAF_OBJ01"
		gWorldDepopTriggers = nil
		gTierPopTrigger = TRIGGER._GC1A_GAMEAREA
		gBustedArea = 2
		gAwardMoney = 1000
		AreaDisableAllPatrolPaths()
		--print(">>>[RUI]", "SetupDifficulty:  new TIER1]]")
	elseif tier == TIER2 then
		--print(">>>[RUI]", "!!SetupDifficulty:  TIER2")
		local tblDowntownTagLocation = {
			{
				trigger = TRIGGER._DT_MEDIUM_022,
				name = "TRIGGER._DT_MEDIUM_022"
			},
			{
				trigger = TRIGGER._DT_MEDIUM_021,
				name = "TRIGGER._DT_MEDIUM_021"
			},
			{
				trigger = TRIGGER._DT_MEDIUM_023,
				name = "TRIGGER._DT_MEDIUM_023"
			},
			{
				trigger = TRIGGER._DT_MEDIUM_001,
				name = "TRIGGER._DT_MEDIUM_001"
			},
			{
				trigger = TRIGGER._DT_MEDIUM_018,
				name = "TRIGGER._DT_MEDIUM_018"
			},
			{
				trigger = TRIGGER._DT_MEDIUM_003,
				name = "TRIGGER._DT_MEDIUM_003"
			},
			{
				trigger = TRIGGER._DT_MEDIUM_007,
				name = "TRIGGER._DT_MEDIUM_007"
			}
		}
		SetupTagsForTier(tblDowntownTagLocation)
		gTagLimit = 7
		gTimeLimit = 180
		playerStart = POINTLIST._GC2_PSTART
		prefectStart = POINTLIST._GC2_PREFECTSTART
		guardModel = 173
		gExitPath = PATH._GC2_EXITPATH
		gStartCamera = PATH._GC2_CAMERA
		gGameArea = TRIGGER._DOWNTOWNGAMEAREA
		gCameraSetup = Tier2CameraSetup
		SetJockModels()
		gPrefectLine = "P_GRAF_T2_01"
		gJimmyLine = "P_GRAF_T2_02"
		gObjectiveStr = "GRAF_OBJ02"
		gWorldDepopTriggers = {
			TRIGGER._DOWNTOWN
		}
		gTierPopTrigger = TRIGGER._DOWTOWNDEPOP
		gBustedArea = 2
		gAwardMoney = 1500
		--print(">>>[RUI]", "SetupDifficulty:  TIER2]]")
	elseif tier == TIER3 then
		--print(">>>[RUI]", "!!SetupDifficulty:  TIER3")
		local tblPoorAreaTagLocation = {
			{
				trigger = TRIGGER._POORAREA_MEDIUM_008,
				name = "TRIGGER._POORAREA_MEDIUM_008"
			},
			{
				trigger = TRIGGER._POORAREA_MEDIUM_023,
				name = "TRIGGER._POORAREA_MEDIUM_023"
			},
			{
				trigger = TRIGGER._POORAREA_MEDIUM_001,
				name = "TRIGGER._POORAREA_MEDIUM_001"
			},
			{
				trigger = TRIGGER._POORAREA_MEDIUM_007,
				name = "TRIGGER._POORAREA_MEDIUM_007"
			},
			{
				trigger = TRIGGER._POORAREA_MEDIUM_004,
				name = "TRIGGER._POORAREA_MEDIUM_004"
			},
			{
				trigger = TRIGGER._POORAREA_MEDIUM_009,
				name = "TRIGGER._POORAREA_MEDIUM_009"
			},
			{
				trigger = TRIGGER._POORAREA_MEDIUM_005,
				name = "TRIGGER._POORAREA_MEDIUM_005"
			},
			{
				trigger = TRIGGER._POORAREA_MEDIUM_022,
				name = "TRIGGER._POORAREA_MEDIUM_022"
			},
			{
				trigger = TRIGGER._POORAREA_MEDIUM_006,
				name = "TRIGGER._POORAREA_MEDIUM_006"
			},
			{
				trigger = TRIGGER._POORAREA_MEDIUM_011,
				name = "TRIGGER._POORAREA_MEDIUM_011"
			}
		}
		SetupTagsForTier(tblPoorAreaTagLocation)
		gTagLimit = 10
		gTimeLimit = 240
		playerStart = POINTLIST._GC3_PSTART
		prefectStart = POINTLIST._GC3_PREFECTSTART
		guardModel = 173
		gExitPath = PATH._GC3_EXITPATH
		gStartCamera = PATH._GC3_CAMERA
		gGameArea = TRIGGER._POORGAMEAREA
		gCameraSetup = Tier3CameraSetup
		SetGreaseModels()
		gPrefectLine = "P_GRAF_T3_01"
		gJimmyLine = "P_GRAF_T3_02"
		gObjectiveStr = "GRAF_OBJ03"
		gWorldDepopTriggers = {
			TRIGGER._POORAREA
		}
		gTierPopTrigger = TRIGGER._POORDEPOP
		gBustedArea = 2
		gAwardMoney = 2000
		--print(">>>[RUI]", "SetupDifficulty:  TIER3]]")
	end
	BlipNextTag()
	if gWorldDepopTriggers then
		for _, t in gWorldDepopTriggers do
			AreaDeactivatePopulationTrigger(t)
		end
	end
	AreaClearAllPeds()
	if gTierPopTrigger then
		AreaActivatePopulationTrigger(gTierPopTrigger)
	end
	--print(">>>[RUI]", "--SetupDifficulty")
end

function PlayerLeftGameAreaTimedOut()
	if not PlayerIsInTrigger(gGameArea) then
		TextPrint("P_GRAF_01", 0.5, 1)
		if gExitTimer then
			if GetTimer() - gExitTimer > GAMEAREA_RETURN_DELAY then
				inGraffitiArea = false
			end
		else
			gExitTimer = GetTimer()
		end
	else
		inGraffitiArea = true
		gExitTimer = nil
	end
	return not inGraffitiArea
end

function TagAddCleanedEffect(tag)
	local x, y, z = GetAnchorPosition(tag.id)
	EffectCreate("GraffitiGone", x, y, z)
	--print(">>>[RUI]", "++TagAddCleanedEffect")
end

function TagCleanupMonitor()
	for _, tag in tblCurrentTags do
		if tag.bCheckTag then
			if PAnimIsPlaying(tag.id, "/Global/WBrush/NotUseable/CleanedUp", true) then
				TextPrint("GRAF_TAG_C", 4, 1)
				tag.bCheckTag = false
				tag.bCleaned = true
				bFoundAttacker = false
				bFindingClosest = true
				bProcessNumbers = true
				CounterIncrementCurrent(1)
				TotalCleanedTags = TotalCleanedTags + 1
				if tag.bBlipped then
					BlipRemove(tag.blip)
					tag.blip = nil
				end
				--print(">>>[RUI]", "!!TagCleanupMonitor tag cleaned name: " .. tag.name)
				BlipNextTag()
			else
				ForceTagRefresh(tag)
			end
		end
	end
	if TotalCleanedTags == gTagLimit then
		--print(">>>[RUI]", "!!TagCleanupMonitor  Tags All Cleaned")
		gMissionState = MISSION_PASSED
		return true
	else
		return false
	end
end

function ForceTagRefresh(tag)
	if not tag.bCleaned and not PAnimIsPlaying(tag.id, "/Global/Tags/NotUseable/Tagged", true) and not PAnimIsPlaying(tag.id, "/Global/WBrush/Tagged", true) then
		--print(">>>[RUI]", "!!ForceTagRefresh resetting bunk tag -->'" .. tag.name .. "' usingTag: " .. tostring(tag.factionTag))
		PAnimSetActionNode(tag.id, tag.factionTag, "Act/Props/WBrush.act")
	end
end

function BlipNextTag()
	--print(">>>[RUI]", "++BlipNextTag")
	for _, tag in tblCurrentTags do
		if not tag.bBlipped then
			if tag.blip and tag.blip ~= -1 then
				--print(">>>[RUI]", "BlipNextTag  Remove blip " .. tag.name)
				BlipRemove(tag.blip)
				tag.blip = nil
			end
			if not tag.bCleaned then
				x, y, z = GetAnchorPosition(tag.id)
				tag.blip = BlipAddXYZ(x, y, z, 0, 1)
				tag.blipped = true
				--print(">>>[RUI]", "BlipNextTag  ADD blip " .. tag.name)
				break
			end
		end
	end
end

function LockStores(bLock) -- ! Modified
	AreaSetDoorLocked("DT_tbusines_BikeShopDoor", bLock)
	AreaSetDoorLocked("DT_tbusines_ClothDoor", bLock)
	AreaSetDoorLocked("DT_tbusines_ComicShopDoor", bLock)
	AreaSetDoorLocked("DT_tbusines_FirewShopDoor", bLock) -- Added this
	AreaSetDoorLocked("DT_tbusines_GenShop1Door", bLock)
	AreaSetDoorLocked("DT_tbusines_GenShop2Door", bLock)
	AreaSetDoorLocked("DT_tbusiness_Barber", bLock)
	AreaSetDoorLocked("DT_tpoor_Barber", bLock)
	AreaSetDoorLocked("DT_trich_BikeShopDoor", bLock)
	AreaSetDoorLocked("DT_trich_FirewShopDoor", bLock) -- Added this
	AreaSetDoorLocked("DT_trich_ClothRichDoor", bLock)
	AreaSetDoorLocked("DT_trich_GenShopDoor", bLock)
end

function Tier1CameraSetup()
	CameraLookAtXYZ(215.9877, -31.088358, 7.5356026, true)
	CameraSetXYZ(221.72185, -36.276695, 6.4954324, 215.9877, -31.088358, 7.5356026)
	--print(">>>[RUI]", "++Tier1CameraSetup")
end

function Tier2CameraSetup()
	CameraLookAtXYZ(527.70044, -69.73396, 5.2370296, true)
	CameraSetXYZ(525.06335, -79.94685, 6.5370464, 527.70044, -69.73396, 5.2370296)
	--print(">>>[RUI]", "++Tier2CameraSetup")
end

function Tier3CameraSetup()
	CameraLookAtXYZ(501.63803, -290.18976, 3.1430483, true)
	CameraSetXYZ(500.71524, -293.56427, 3.7230544, 501.63803, -290.18976, 3.1430483)
	--print(">>>[RUI]", "++Tier2CameraSetup")
end

function NIS_CameraForTier(tier)
	if tier == TIER1 then
		Tier1CameraSetup()
	elseif tier == TIER2 then
		Tier2CameraSetup()
	elseif tier == TIER3 then
		Tier3CameraSetup()
	end
end

function PlayerBusted()
	return PlayerGetPunishmentPoints() > gBasePunishment
end

function PrefectHitByPlayer()
	Wait(100)
	bPrefectAttacked = PedIsHitByPlayer(gPrefect)
	return bPrefectAttacked
end

function Intro() -- ! Modified
	--print(">>>[RUI]", "!!Intro")
	F_MakePlayerSafeForNIS(true)
	gPrefect = GuardCreate(prefectStart, guardModel)
	PedFaceObject(gPrefect, gPlayer, 3, 1, false)
	L_TagLoad("CleanMe", tblCurrentTags)
	--[[
	if bUseCameraTweak then
		WaitSkippable(1.99999996E11)
		TextPrintString("CameraTweak Mode ON", 4, 1)
		F_CameraTweak()
	end
	]] -- Removed this
	PlayerSetWeapon(MODELENUM._WBRUSH, 1, false)
	CameraFade(500, 0)
	Wait(501)
	PedClearObjectives(gPlayer)
	CameraSetWidescreen(false)
	PlayerSetPosPoint(playerStart, 2)
	CameraReturnToPlayer()
	CameraReset()
	CameraFade(500, 1)
	Wait(500)
	F_MakePlayerSafeForNIS(false)
	gObj = UpdateObjectiveLog(gObjectiveStr, nil)
end

function OnSkip()
	bOnSkip = true
end

function cbWalkDone(pedId, pathId, pathNode)
	if pedId == gPlayer and PathGetLastNode(pathId) == pathNode then
		bWalkDone = true
	end
end

function MissionInit()
	--print(">>>[RUI]", "MissionInit")
	PlayerSetControl(0)
	while not gCurrentTier do
		Wait(10)
	end
	--print(">>>[RUI]", "Tier: " .. gCurrentTier)
	TableInit()
	SetupDifficulty(gCurrentTier)
	--print("========== tagCount =========", tagCount)
	L_HUDBlipSetup()
end

function MissionSetup()
	--print(">>>[RUI]", "MissionSetup")
	MissionDontFadeIn()
	DATLoad("GraffitiPunishment.DAT", 2)
	DATInit()
	SoundPlayInteractiveStream("MS_PunishmentDetention.rsm", MUSIC_DEFAULT_VOLUME, 500, 500)
	PlayerSetPunishmentPoints(0)
	gBasePunishment = PlayerGetPunishmentPoints()
	RadarSetMinMax(15, 75, 25)
	DisablePOI(true, true)
	LoadAnimationGroup("MINIGRAF")
	LoadAnimationGroup("W_Thrown")
	Load("Act/Props/WBrush.act")
	CounterSetCurrent(0)
	PedRequestModel(50)
	VehicleRequestModel(273)
	WeaponRequestModel(MODELENUM._WBRUSH)
	LockStores(true)
end

function CounterSetup(Max)
	CounterSetCurrent(0)
	CounterSetMax(Max)
	CounterSetText("P_GRAF_COUNT")
	CounterMakeHUDVisible(true, true)
end

function ClearCounter()
	CounterMakeHUDVisible(false)
	print(">>>[RUI]", "CounterMakeHUDVisible")
	CounterSetCurrent(0)
	CounterSetMax(0)
	CounterClearText()
end

function PrefectWanderAmbiently(prefect)
	PedClearTether(prefect)
	PedClearObjectives(prefect)
	PedWander(prefect, 0)
	PedMakeAmbient(prefect)
	--print(">>>[RUI]", "!!PrefectWanderAmbiently")
end

function MissionCleanup()
	--print(">>>[RUI]", "MissionCleanup")
	L_HUDBlipCleanup()
	ClearCounter()
	RadarRestoreMinMax()
	DATUnload(2)
	SoundStopInteractiveStream()
	if gTierPopTrigger then
		AreaDeactivatePopulationTrigger(gTierPopTrigger)
	end
	if gWorldDepopTriggers then
		for _, t in gWorldDepopTriggers do
			AreaActivatePopulationTrigger(t)
		end
	end
	if WeaponEquipped(MODELENUM._WBRUSH) then
		PedDestroyWeapon(gPlayer, MODELENUM._WBRUSH)
	end
	if gCurrentTier == TIER1 then
		AreaEnableAllPatrolPaths()
	end
	if PedExists(gPrefect) then
		PrefectWanderAmbiently(gPrefect)
	end
	UnLoadBranch("/Global/WBrush")
	LockStores(false)
	UnLoadAnimationGroup("MINIGRAF")
	UnLoadAnimationGroup("W_Thrown")
	--print(">>>[RUI]", "MissionCleanup]]")
end

function GuardCreate(pos, model)
	local guard = PedCreatePoint(model, pos, 1)
	PedOverrideStat(guard, 3, 25)
	PedSetTetherToPoint(guard, pos, 2, 15)
	PedIgnoreStimuli(guard, false)
	PedIgnoreAttacks(guard, false)
	--print(">>>[RUI]", "++GuardCreate")
	return guard
end

function MissionPassedCheck()
	if tblObjective.cleanupGraffiti.completed then
		--print(">>>[RUI]", "MissionPassed:  YES")
		gMissionState = MISSION_PASSED
	elseif tblObjective.timedOut.failed then
		--print(">>>[RUI]", "MissionPassed:  NO timedOut")
		gFailMessage = "PUN_TIME"
		gMissionState = MISSION_FAILED
	elseif tblObjective.busted.failed then
		--print(">>>[RUI]", "MissionPassed:  NO busted")
		gFailMessage = "BUSTED"
		bPlayerBusted = true
		gMissionState = MISSION_FAILED
	elseif tblObjective.leftGameArea.failed then
		--print(">>>[RUI]", "MissionPassed:  NO left game area")
		gFailMessage = "M_FAIL"
		gMissionState = MISSION_FAILED
	elseif tblObjective.prefectAttacked.failed then
		--print(">>>[RUI]", "MissionPassed:  NO prefectAttacked")
		gFailMessage = "BUSTED"
		bPlayerBusted = true
		PlayerSetPunishmentPoints(200)
		PlayerSetControl(0)
		gMissionState = MISSION_FAILED
	end
end

function main()
	MissionInit()
	Intro()
	CreateThread("T_MonitorTags")
	if gCurrentTier == TIER1 then
		CreateThread("T_TagCleanTutorial")
	end
	L_ObjectiveSetParam(tblObjective)
	CreateThread("T_ObjectiveMonitor")
	CounterSetup(gTagLimit)
	MissionTimerStart(gTimeLimit)
	while not L_ObjectiveProcessingDone() do
		Wait(100)
	end
	MissionTimerStop()
	MissionPassedCheck()
	if gMissionState == MISSION_PASSED then
		PedSetActionNode(gPlayer, "/Global/GraffitiCleanup/TossBrush/Toss", "Act/Anim/GraffitiCleanup.act")
		PedDestroyWeapon(gPlayer, MODELENUM._WBRUSH)
		Wait(3500)
		SoundPlayMissionEndMusic(true, 10)
		MissionSucceed(false, true, true, gAwardMoney)
	else
		Wait(500)
		PedSetActionNode(gPlayer, "/Global/GraffitiCleanup/TossBrush/Toss", "Act/Anim/GraffitiCleanup.act")
		PedDestroyWeapon(gPlayer, MODELENUM._WBRUSH)
		Wait(3500)
		fade = bPlayerBusted or false
		SoundPlayMissionEndMusic(false, 10)
		MissionFail(fade, true)
	end
end

function T_TagCleanTutorial()
	while CounterGetCurrent() == 0 and gMissionState == MISSION_RUNNING do
		Wait(100)
		if PedIsPlaying(gPlayer, "/Global/WBrush/PedPropsActions/PerformCleanup/CleanMedTag", true) then
			TutorialShowMessage("TUT_GP_02", 6000)
			Wait(6000)
			break
		end
	end
	collectgarbage()
	--print(">>>[RUI]", "--T_TagCleanTutorial")
end
