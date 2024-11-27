local nRadarRange = 30
local modelDiary = 483
local diaryRequest = 19
local objective = -1
local objective1 = -1
local objective2 = -1
local objective3 = -1
local blipObjective, blipObjectivePoint
local bGotDiary = false
local bMissionFailed = false
local szMissionPhase
local beatrice = -1
local bReturnedDiary = false
local bSocGaveDiary = false
local bDoorUsed = false
local bPlayerAtEnd = false
local bButtonReleased = false
local szFailReason

function MissionSetup()
	PlayCutsceneWithLoad("1-G1", true, true)
	DATLoad("1_G1_new.DAT", 2)
	LoadAnimationGroup("MINI_Lock")
	LoadAnimationGroup("1_G1_TheDiary")
	LoadAnimationGroup("1_03The Setup")
	LoadAnimationGroup("MINI_Lock")
	LoadAnimationGroup("1_07_SaveBucky")
	WeaponRequestModel(483)
	WeaponRequestModel(432)
	PedSetUniqueModelStatus(3, -1)
	MissionDontFadeIn()
end

function main()
	F_SocializeBeatriceLoad()
	LoadActionTree("Act/Conv/1_G1.act")
	PlayerSetControl(0)
	AreaTransitionPoint(0, POINTLIST._1_G1_PLAYERSTART, 1, false)
	CreateThread("T_MissionFail")
	SoundPlayInteractiveStream("MS_FootStealthLow.rsm", 0.5)
	SoundSetMidIntensityStream("MS_FootStealthMid.rsm", 0.6)
	SoundSetHighIntensityStream("MS_FootStealthHigh.rsm", 0.7)
	while not RequestModel(486) do
		Wait(0)
	end
	while not RequestModel(3) do
		Wait(0)
	end
	shared.gWindowsOpen = true
	F_LockMissionDoors()
	O_EnterWindow()
	shared.gWindowsOpen = nil
	O_GetDiary()
	shared.gWindowsOpen = true
	O_LeaveSchool()
	O_FindBeatrice()
	O_KissBeatrice()
	F_UnLockMissionDoors()
	if not bMissionFailed then
		while MinigameIsShowingCompletion() do
			Wait(0)
		end
		CameraFade(500, 0)
		Wait(501)
		CameraReset()
		CameraReturnToPlayer()
		MissionSucceed(false, false, false)
		Wait(500)
		CameraFade(500, 1)
		CameraSetWidescreen(false)
		Wait(101)
		PlayerSetControl(1)
	end
end

function MissionCleanup()
	AreaSetDoorLocked("DT_ischool_Staff", true)
	SoundStopInteractiveStream()
	shared.gWindowsOpen = nil
	ItemSetCurrentNum(modelDiary, 0)
	if PedIsValid(beatrice) then
		PedSetFlag(beatrice, 113, false)
		PedSetInvulnerable(beatrice, false)
		PedIgnoreStimuli(beatrice, false)
		PedSetStationary(beatrice, false)
		PlayerSocialDisableActionAgainstPed(beatrice, 28, false)
		PlayerSocialDisableActionAgainstPed(beatrice, 29, false)
		PedSetRequiredGift(beatrice, 0, false, false)
		PedMakeAmbient(beatrice)
		PedWander(beatrice, 0)
	end
	AreaSetDoorLocked("DT_tschool_ExtWind", true)
	AreaSetDoorLocked("DT_tschool_HallWind", true)
	PedSetUniqueModelStatus(3, 1)
	F_UnLockMissionDoors()
	UnLoadAnimationGroup("MINI_Lock")
	UnLoadAnimationGroup("1_G1_TheDiary")
	UnLoadAnimationGroup("1_03The Setup")
	UnLoadAnimationGroup("MINI_Lock")
	UnLoadAnimationGroup("1_07_SaveBucky")
	DATUnload(2)
	if bMissionFailed then
		PlayerSetControl(1)
		CameraSetWidescreen(false)
	end
	F_MakePlayerSafeForNIS(false)
	CameraSetWidescreen(false)
end

function T_MissionFail()
	while not bMissionFailed do
		Wait(0)
	end
	if not bPlayerAtEnd then
		bMissionFailed = true
		SoundPlayMissionEndMusic(false, 7)
		if szFailReason then
			MissionFail(false, true, szFailReason)
		else
			MissionFail(false)
		end
	end
end

function F_FailMission()
	bMissionFailed = true
end

function F_BeaHit()
	if beatrice and PedIsValid(beatrice) then
		PedSetInvulnerable(beatrice, false)
		PedSetFlag(beatrice, 113, false)
		PedSetStationary(beatrice, false)
		PedIgnoreStimuli(beatrice, false)
		PedMakeAmbient(beatrice)
	end
	bMissionFailed = true
	szFailReason = "1_G1_BEAHIT"
end

function F_SocializeBeatrice()
	PedSetMissionCritical(beatrice, true, F_BeaHit, true)
	PedSetEmotionTowardsPed(beatrice, gPlayer, 8)
	PedSetRequiredGift(beatrice, diaryRequest, false, true)
	PedOverrideSocialResponseToStimulus(beatrice, 28, 4)
	PlayerSocialDisableActionAgainstPed(beatrice, 28, true)
	PlayerSocialDisableActionAgainstPed(beatrice, 29, true)
	PedUseSocialOverride(beatrice, 4)
end

function F_SocializeBeatriceLoad()
	LoadActionTree("Act/Anim/Overrides/Mission/1_G1WantGift.act")
	LoadActionTree("Act/Anim/Overrides/Mission/1_G1Follow.act")
	PedSocialOverrideLoad(24, "Mission/1_G1WantGift.act")
	PedSocialOverrideLoad(4, "Mission/1_G1Follow.act")
end

function socWantGift()
	--print(">>[JASON]", "socWantGift played.")
end

function socFollow()
	--print(">>[JASON]", "socFollow played.")
	bSocGaveDiary = true
end

function O_EnterWindow()
	local objectiveid = MissionObjectiveAdd("1_G1_OBJ1")
	local blipLattice = BlipAddPoint(POINTLIST._1_G1_LATTICE, 29, 1, 0, 1)
	TextPrint("1_G1_OBJ1", 4, 1)
	blipObjective, blipObjectivePoint = F_UpdateObjectiveBlip(blipObjective, POINTLIST._1_G1_WINDOWENTRY)
	beatrice = PedCreatePoint(3, POINTLIST._1_G1_BEASPAWN)
	F_SocializeBeatrice()
	PlayerSetControl(1)
	CameraFade(1000, 1)
	CreateThread("T_WindowBlip")
	while AreaGetVisible() ~= 2 do
		Wait(0)
	end
	BlipRemove(blipLattice)
	MissionObjectiveComplete(objectiveid)
end

function O_GetDiary()
	local objectiveid = MissionObjectiveAdd("1_G1_OBJ5")
	F_ClearAmbientPeds()
	local cx, cy, cz = GetPointList(POINTLIST._1_G1_MATHCLASS)
	blipObjective, blipObjectivePoint = F_UpdateObjectiveBlip(blipObjective, POINTLIST._1_G1_MATHCLASS)
	TextPrint("1_G1_OBJ5", 4, 1)
	PAnimCreate(TRIGGER._1_G1_MATHPROXY, false, false)
	while not bDoorUsed do
		Wait(0)
		PedIsInAreaXYZ(gPlayer, cx, cy, cz, 1, 7)
	end
	bDoorUsed = false
	PAnimDelete(TRIGGER._1_G1_MATHPROXY)
	MissionObjectiveComplete(objectiveid)
	objectiveid = MissionObjectiveAdd("1_G1_OSTAFF")
	cx, cy, cz = GetPointList(POINTLIST._1_G1_ROOMOBJECTIVE)
	blipObjective, blipObjectivePoint = F_UpdateObjectiveBlip(blipObjective, POINTLIST._1_G1_DIARY)
	TextPrint("1_G1_OBJ4", 4, 1)
	AreaSetDoorLocked("DT_ischool_Staff", false)
	cx, cy, cz = GetPointList(POINTLIST._1_G1_DIARY)
	while not PlayerHasItem(modelDiary) do
		Wait(0)
		if PlayerIsInAreaXYZ(cx, cy, cz, 0.5, 1) then
			TextPrint("1_G1_GETDIARY", 0.1, 3)
			if IsButtonPressed(9, 0) then
				PlayerSetPosSimple(-645.80054, 222.25, -0.39)
				PlayerFaceHeadingNow(180)
				CameraSetXYZ(-645.1992, 221.4531, 1.163621, -645.90344, 222.15561, 1.064427)
				PedSetActionNode(gPlayer, "/Global/1_G1/Anims/GetDiary", "Act/Conv/1_G1.act")
				while PedIsPlaying(gPlayer, "/Global/1_G1/Anims/GetDiary", true) do
					Wait(0)
				end
				CameraSetWidescreen(false)
				CameraReturnToPlayer(true)
				PedDestroyWeapon(gPlayer, 432)
				HUDDiaryVisible(true)
				CameraReturnToPlayer(true)
				GiveItemToPlayer(modelDiary)
				PlayerSetControl(1)
			end
		end
	end
	AreaSetDoorLocked("DT_ischool_Staff", true)
	BlipRemove(diaryBlip)
	--print("DONE BUSTING IN!")
	MissionObjectiveComplete(objectiveid)
end

function F_ProxyActivated()
	bDoorUsed = true
end

function F_Cinematic(bStart)
	if bStart then
		CameraFade(500, 0)
		Wait(500)
		PlayerSetControl(0)
		CameraSetWidescreen(true)
		CameraFade(500, 1)
		F_MakePlayerSafeForNIS(true)
	elseif not bStart then
		CameraFade(500, 0)
		Wait(500)
		CameraReturnToPlayer()
		CameraFade(500, 1)
		F_MakePlayerSafeForNIS(false)
	end
end

function O_LeaveSchool()
	objective = MissionObjectiveAdd("1_G1_OBJ3")
	TextPrint("1_G1_OBJ3", 4, 1)
	SoundStopInteractiveStream()
	PedSetFlag(beatrice, 113, true)
	local cx, cy, cz = GetPointList(POINTLIST._1_G1_SECONDFLOORWINDOW)
	BlipRemove(blipObjective)
	blipObjective = AddBlipForChar(beatrice, 12, 17, 4)
	szMissionPhase = O_LeaveSchool
	PedIgnoreStimuli(beatrice, true)
	PedSetStationary(beatrice, true)
	while AreaGetVisible() ~= 0 do
		Wait(0)
	end
	BlipRemove(pointBlip)
end

function O_FindBeatrice()
	local cx, cy, cz = GetPointList(POINTLIST._1_G1_SECONDFLOORWINDOW)
	local loop = true
	szMissionPhase = O_FindBeatrice
	PlayerSetControl(1)
	while loop do
		Wait(0)
		if PedIsValid(beatrice) and 0 < ItemGetCurrentNum(modelDiary) and PlayerIsInAreaObject(beatrice, 2, 3, 0) then
			loop = false
		end
	end
	if not bMissionFailed then
		if 0 < ItemGetCurrentNum(modelDiary) and PlayerIsInAreaObject(beatrice, 2, 3, 0) then
			PedSetInvulnerable(beatrice, true)
			PlayerSetInvulnerable(true)
			PedSetMissionCritical(beatrice, false, F_BeaHit, false)
			bPlayerAtEnd = true
			F_MakePlayerSafeForNIS(true)
			PlayerSetControl(0)
			CameraSetWidescreen(true)
			F_PlayerDismountBike()
			PedSetFlag(beatrice, 113, false)
			PedSetInvulnerable(beatrice, false)
			PedIgnoreStimuli(beatrice, false)
			PedSetStationary(beatrice, false)
			PlayerSetInvulnerable(false)
			PedSetEmotionTowardsPed(beatrice, gPlayer, 8, true)
			PedSetPedToTypeAttitude(beatrice, gPlayer, 4)
			PedSetFlag(beatrice, 84, true)
			PedFaceObject(beatrice, gPlayer, 3, 1)
			PedFaceObject(gPlayer, beatrice, 2, 1)
			PedLockTarget(gPlayer, beatrice, 3)
			PedStop(beatrice)
			PedClearObjectives(beatrice)
			PedFaceObjectNow(beatrice, gPlayer, 3)
			PedFaceObjectNow(gPlayer, beatrice, 2)
			PedLockTarget(gPlayer, beatrice, 3)
			PedSetActionNode(gPlayer, "/Global/1_G1/Anims/Give/GiveBeatrice1_G1", "Act/Conv/1_G1.act")
			while PedIsPlaying(gPlayer, "/Global/1_G1/Anims/Give/GiveBeatrice1_G1", true) do
				Wait(0)
			end
			Wait(1000)
			MinigameSetCompletion("M_PASS", true, 2000)
			SoundPlayMissionEndMusic(true, 7)
			while PedIsPlaying(gPlayer, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) or PedIsPlaying(beatrice, "/Global/Player/Social_Actions/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
				Wait(0)
			end
			PedLockTarget(gPlayer, -1, 3)
			PedMakeAmbient(beatrice)
			PedWander(beatrice, 0)
			PlayerSocialDisableActionAgainstPed(beatrice, 28, false)
			PlayerSocialDisableActionAgainstPed(beatrice, 29, false)
			if beatrice ~= nil and not PedIsDead(beatrice) then
				PedSetMissionCritical(beatrice, false)
				PedMakeAmbient(beatrice)
				PedWander(beatrice, 0)
			end
		end
		bReturnedDiary = true
		MissionObjectiveComplete(objective)
	end
end

function F_PlaySpeechWait(pedId, strEvent, commentId, volume)
	SoundPlayScriptedSpeechEvent(pedId, strEvent, commentId, volume)
	while SoundSpeechPlaying() do
		Wait(0)
	end
end

function O_KissBeatrice()
	if PedIsValid(beatrice) then
		PedMakeAmbient(beatrice)
		BlipRemove(blipObjective)
	end
end

function F_UpdateObjectiveBlip(BlipID, nextBlipPoint)
	if BlipID then
		BlipRemove(BlipID)
		BlipID = nil
	end
	if nextBlipPoint then
		return BlipAddPoint(nextBlipPoint, 0), nextBlipPoint
	end
end

function F_GiveDiary()
	--print(">>>[JASON]", "F_GiveDiary Executed")
	GiveItemToPlayer(modelDiary, 1)
	bGotDiary = true
end

function F_LockMissionDoors()
	AreaSetDoorLocked("DT_TSCHOOL_SCHOOLFRONTDOORL", true)
	AreaSetDoorLocked("DT_TSCHOOL_SCHOOLLEFTBACKDOOR", true)
	AreaSetDoorLocked("DT_TSCHOOL_SCHOOLLEFTFRONTDOOR", true)
	AreaSetDoorLocked("DT_TSCHOOL_SCHOOLRIGHTFRONTDOOR", true)
	AreaSetDoorLocked("DT_TSCHOOL_SCHOOLRIGHTBACKDOOR", true)
	AreaSetDoorLocked("DT_tschool_GirlsDormL", true)
end

function F_UnLockMissionDoors()
	AreaSetDoorLocked("DT_TSCHOOL_SCHOOLFRONTDOORL", false)
	AreaSetDoorLocked("DT_TSCHOOL_SCHOOLLEFTBACKDOOR", false)
	AreaSetDoorLocked("DT_TSCHOOL_SCHOOLLEFTFRONTDOOR", false)
	AreaSetDoorLocked("DT_TSCHOOL_SCHOOLRIGHTFRONTDOOR", false)
	AreaSetDoorLocked("DT_TSCHOOL_SCHOOLRIGHTBACKDOOR", false)
	AreaSetDoorLocked("DT_tschool_GirlsDormL", false)
end

function F_ClearAmbientPeds()
	if PedIsSpotted(gPlayer, 3) then
		--print(">>[JASON]", "Clearing all ambient peds, as player is spotted.")
		AreaClearAllPeds()
	end
end

function T_WindowBlip()
	local cx, cy, cz = GetPointList(POINTLIST._1_G1_WINDOWENTRY)
	local blipIsRemovedByThisFunction = false
	local windowBlip
	while ItemGetCurrentNum(modelDiary) == 0 do
		if AreaGetVisible() == 0 then
			if blipObjective then
				BlipRemove(blipObjective)
				blipObjective = nil
				blipIsRemovedByThisFunction = true
				windowBlip = BlipAddPoint(POINTLIST._1_G1_WINDOWENTRY, 29)
			end
			PlayerIsInAreaXYZ(cx, cy, cz, 0.75, 7)
		elseif AreaGetVisible() == 2 then
			if not blipObjective then
				blipObjective = BlipAddPoint(blipObjectivePoint, 0)
				blipIsRemovedByThisFunction = false
			end
			if windowBlip then
				BlipRemove(windowBlip)
				windowBlip = nil
			end
		end
		Wait(0)
	end
end
