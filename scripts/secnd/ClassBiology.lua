--[[ Changes to this file:
	* Modified function MissionCleanup, may require testing
	* Modified function main, may require testing
]]

local DT_FROG = 0
local DT_RAT = 1
local DT_PERCH = 2
local DT_PIGEON = 3
local DT_PIG = 4
local missionSuccess = false
local nCurrentWordScore = 0
local nCurrentScore = 0
local nCurrentClass
local bStageLoaded = false
local tblClasses = {
	{
		animalType = DT_FROG,
		timer = 180,
		percent = 1,
		grade = 1
	},
	{
		animalType = DT_RAT,
		timer = 165,
		percent = 1,
		grade = 2
	},
	{
		animalType = DT_PERCH,
		timer = 170,
		percent = 1,
		grade = 3
	},
	{
		animalType = DT_PIGEON,
		timer = 165,
		percent = 1,
		grade = 4
	},
	{
		animalType = DT_PIG,
		timer = 180,
		percent = 1,
		grade = 5
	}
}
local gInsultModels = {
	70,
	66,
	69,
	142,
	139
}

function MissionSetup()
	--print("[ScottieP] --> MissionSetup")
	DATLoad("ClassLoc.DAT", 2)
	DATLoad("C8.DAT", 2)
	DATInit()
	MissionDontFadeIn()
	SoundEnableInteractiveMusic(false)
	AreaTransitionPoint(6, POINTLIST._C8_PSTART, nil, true)
	MinigameCreate("BIOLOGY", false)
	while not MinigameIsReady() do
		--print("STUCK MISSION SETUP")
		Wait(0)
	end
	PlayerSetMinPunishmentPoints(0)
	HUDSaveVisibility()
	HUDClearAllElements()
	ToggleHUDComponentVisibility(42, true)
	Wait(2)
	SoundStopPA()
	SoundStopCurrentSpeechEvent()
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	SoundDisableSpeech_ActionTree()
end

function MissionCleanup() -- ! Modified
	--print("[ScottieP] --> Mission Cleanup")
	PlayerSetControl(0)   -- Added this
	HUDRestoreVisibility()
	PlayerWeaponHudLock(false)
	SoundRestartPA()
	SoundEnableInteractiveMusic(true)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	SoundFadeoutStream()
	PedSetActionNode(gPlayer, "/Global/C8/Release", "Act/Conv/C8.act")
	MinigameDestroy()
	SoundStopStream()
	SoundEnableSpeech_ActionTree()
	UnLoadAnimationGroup("NPC_Adult")
	UnLoadAnimationGroup("UBO")
	UnLoadAnimationGroup("MINI_React")
	UnLoadAnimationGroup("ENGLISHCLASS")
	UnLoadAnimationGroup("SBULL_X")
	if not transitioned then
		AreaTransitionPoint(2, POINTLIST._C8_PEND)
	end
	PedClearObjectives(gPlayer)
	PedStop(gPlayer)
	PlayerSetPunishmentPoints(0)
	F_MakePlayerSafeForNIS(false)
	if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
		PlayerSetHealth(PedGetMaxHealth(gPlayer))
	end
	PedSetFlag(gPlayer, 128, false)
	PlayerSetControl(1)
	DATUnload(2)
	if IsDemoBuildEnabled() == true then
		DemoBuildReturnToMain()
	end
end

function main() -- ! Modified
	--print("[ScottieP] --> Main")
	while not bStageLoaded do
		Wait(0)
		--print("STUCK HERE")
	end
	F_MakePlayerSafeForNIS(true)
	PlayerSetControl(0) -- Added this
	PlayerWeaponHudLock(true)
	VehicleOverrideAmbient(0, 0, 0, 0)
	AreaClearAllPeds()
	PlayerSetControl(0)
	LoadActionTree("Act/Conv/C8.act")
	LoadAnimationGroup("NPC_Adult")
	LoadAnimationGroup("MINI_React")
	LoadAnimationGroup("UBO")
	LoadAnimationGroup("ENGLISHCLASS")
	LoadAnimationGroup("SBULL_X")
	F_IntroCinematic()
	ClassBiologySetAnimal(nCurrentClass - 1)
	MinigameStart()
	--[[
	SoundPlayStream("MS_BiologyClass.rsm", 0.95, 0, 0)
	]] -- Changed to: 
	SoundPlayStream("MS_BiologyClass.rsm", 0.15, 0, 0)
	F_InitRules()
	CameraSetWidescreen(false)
	MinigameEnableHUD(true)
	Wait(1000)
	CameraSetFOV(30)
	CameraSetXYZ(-707.43854, 316.45575, 34.958454, -707.70355, 317.4143, 34.854702)
	while MinigameIsActive() do
		Wait(0)
		if gStartedLoop and GetTimer() - gStartedLoop > 13000 then
			SoundLoopPlay2D("TimeWarningLOOP", false)
		end
		if ClassBiologyIsGrossOut() then
			if math.random(1, 3) == 2 then
				SoundPlayScriptedSpeechEvent(gPlayer, "ClassBiology", 13, "large", true)
			end
			ClassBiologyResetGrossOut()
		end
		if ClassBiologyIsBadMove() then
			SoundPlayScriptedSpeechEvent(bioTeacher, "ClassBiology", 12, "large", true)
			ClassBiologyResetBadMove()
		end
		F_CheckRules()
	end
	CameraSetWidescreen(true)
	MinigameEnableHUD(false)
	PedFaceObject(gPlayer, bioTeacher, 2, 0)
	if missionSuccess then
		if nCurrentClass == 5 then
			SoundPlayScriptedSpeechEvent(bioTeacher, "ClassBiology", 6, "large", true)
		else
			SoundPlayScriptedSpeechEvent(bioTeacher, "ClassBiology", nCurrentClass + 5, "large", true)
		end
		PedSetActionNode(gPlayer, "/Global/C8/PlayerVictory/PlayerVictory03", "Act/Conv/C8.act")
	else
		SoundPlayScriptedSpeechEvent(bioTeacher, "ClassBiology", 11, "large", true)
		SoundPlay2D("Fatigued01")
		PedSetActionNode(gPlayer, "/Global/C8/PlayerFail", "Act/Conv/C8.act")
		PedSetActionNode(bioTeacher, "/Global/C8/TeacherDisgust", "Act/Conv/C8.act")
	end
	SoundLoopPlay2D("TimeWarningLOOP", false)
	if missionSuccess and not bIsRepeatable then
		PlayerSetGrade(4, tblClasses[nCurrentClass].grade)
	end
	if not bIsRepeatable then
		if 0 < tblClasses[nCurrentClass].grade then
			MinigameSetGrades(4, tblClasses[nCurrentClass].grade - 1)
		else
			MinigameSetGrades(4, tblClasses[nCurrentClass].grade)
		end
		SoundFadeoutStream()
		if missionSuccess then
			SoundPlayMissionEndMusic(true, 9)
		else
			SoundPlayMissionEndMusic(false, 9)
		end
		while MinigameIsShowingGrades() do
			Wait(0)
		end
		if missionSuccess and nCurrentClass == 5 then
			CameraFade(500, 0)
			Wait(500)
			CameraSetXYZ(-708.2253, 317.97073, 35.870102, -707.9722, 317.01312, 35.732483)
			SoundStopCurrentSpeechEvent(bioTeacher)
			PedStop(bioTeacher)
			PedClearObjectives(bioTeacher)
			PedFaceHeading(bioTeacher, 0, 0)
			CameraFade(500, 1)
			Wait(500)
			SoundPlayScriptedSpeechEvent(bioTeacher, "ClassBiology", 10, "large", true)
			Wait(6500)
		end
	end
	Wait(1000)
	CameraFade(500, 0)
	Wait(500)
	PlayerSetControl(1)
	CameraSetWidescreen(false)
	if missionSuccess then
		if not bIsRepeatable then
			F_EndCinematic()
		end
		MissionSucceed(false, true, false)
	else
		SoundPlayMissionEndMusic(false, 9)
		MissionFail(true, false)
	end
	CameraReturnToPlayer()
	CameraReset()
end

function F_InitRules()
	if tblClasses[nCurrentClass].timer then
		if tblClasses[nCurrentClass].taxicab then
			ClassBiologySetTimer(tblClasses[nCurrentClass].timer, tblClasses[nCurrentClass].taxicab)
		else
			ClassBiologySetTimer(tblClasses[nCurrentClass].timer, 0)
		end
	end
	if tblClasses[nCurrentClass].percent then
		ClassBiologySetScorePercentage(tblClasses[nCurrentClass].percent)
	end
	ClassBiologySetTrigFunc(15, F_ChangeMusic)
end

function F_CheckRules()
	if MinigameIsSuccess() then
		missionSuccess = true
	end
end

function F_CalcTime()
	initTimer = GetTimer()
	while true do
		if IsButtonPressed(0, 0) then
			endTimer = GetTimer()
			break
		end
		Wait(0)
	end
	--print(" TIMER ", endTimer - initTimer)
end

function F_IntroCinematic()
	PedSetPosPoint(gPlayer, POINTLIST._C8_PSTART)
	bioTeacher = PedCreatePoint(64, POINTLIST._C8_BIOTEACHER)
	student1 = PedCreatePoint(3, POINTLIST._C8_STUDENTS, 1)
	student2 = PedCreatePoint(35, POINTLIST._C8_STUDENTS, 2)
	student3 = PedCreatePoint(66, POINTLIST._C8_STUDENTS, 3)
	Wait(1500)
	PedIgnoreStimuli(bioTeacher, true)
	PedIgnoreStimuli(student1, true)
	PedIgnoreStimuli(student2, true)
	PedIgnoreStimuli(student3, true)
	PedSetAsleep(bioTeacher, true)
	CameraSetWidescreen(true)
	Wait(1000)
	if not F_CheckIfPrefect() then
		CameraFade(1000, 1)
	end
	CameraSetXYZ(-707.60547, 318.99103, 35.46547, -707.33887, 318.0342, 35.349823)
	PedFollowPath(student1, PATH._C8_STUDENTPATH1, 0, 0)
	PedFollowPath(student2, PATH._C8_STUDENTPATH2, 0, 0)
	PedStop(gPlayer)
	PedIgnoreStimuli(gPlayer, true)
	PedFollowPath(gPlayer, PATH._C8_PLAYERPATH, 0, 0)
	PedPathNodeReachedDistance(gPlayer, 0.5)
	SoundPlayScriptedSpeechEvent(bioTeacher, "ClassBiology", nCurrentClass, "large", true)
	Wait(6000)
	PedFollowPath(student3, PATH._C8_STUDENTPATH3, 0, 0)
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	PlayerSetPosPoint(POINTLIST._C8_PLAYERSTAND)
	Wait(1000)
	CameraSetFOV(40)
	CameraSetXYZ(-707.5762, 316.5639, 34.836285, -707.7704, 317.5434, 34.783672)
	Wait(2000)
	CameraFade(500, 0)
	Wait(600)
	F_CleanPrefect()
	CameraFade(0, 1)
end

function F_SetStage(param)
	nCurrentClass = param
	bStageLoaded = true
	--print("[SCOTT]======> nCurrentClass = " .. nCurrentClass)
end

function F_SetStageRepeatable(param)
	nCurrentClass = param
	bStageLoaded = true
	bIsRepeatable = true
	--print("[JASON]======> nCurrentClass = " .. nCurrentClass)
end

function F_ChangeMusic()
	--print("CHANGING MUSIC")
	SoundPlay2D("TimeTransition")
	SoundLoopPlay2D("TimeWarningLOOP", true)
	gStartedLoop = GetTimer()
end

function F_EndCinematic()
	local victoryAnim
	if nCurrentClass == 1 then
		ClothingGivePlayer("SP_MuscleShirt", 1)
		victoryAnim = "/Global/C8/PlayerVictory/"
		unlockText = "MGBI_Unlock01"
	elseif nCurrentClass == 2 then
		ClothingGivePlayer("SP_Hazmat", 0)
		victoryAnim = "/Global/C8/PlayerVictory/Unlocks/SuccessMed1"
		unlockText = "MGBI_Unlock02"
	elseif nCurrentClass == 3 then
		ClothingGivePlayer("SP_Basshat", 0)
		victoryAnim = "/Global/C8/PlayerVictory/Unlocks/SuccessHi2"
		unlockText = "MGBI_Unlock03"
	elseif nCurrentClass == 4 then
		ClothingGivePlayerOutfit("Alien", true, true)
		victoryAnim = "/Global/C8/PlayerVictory/Unlocks/SuccessHi1"
		unlockText = "MGBI_Unlock04"
	elseif nCurrentClass == 5 then
		ClothingGivePlayer("SP_Pigmask", 0)
		victoryAnim = "/Global/C8/PlayerVictory/Unlocks/SuccessHi3"
		unlockText = "MGBI_Unlock05"
		unlockTextRoom = "MGBI_Unlock06"
	end
	CameraFade(-1, 0)
	Wait(FADE_OUT_TIME + 1000)
	PlayerSetControl(0)
	AreaTransitionPoint(2, POINTLIST._C8_PEND, nil, true)
	NonMissionPedGenerationDisable()
	HUDRestoreVisibility()
	PlayerWeaponHudLock(false)
	CameraAllowChange(true)
	PedSetWeaponNow(gPlayer, -1, 0)
	SoundEnableSpeech_ActionTree()
	CameraSetWidescreen(true)
	while not AreaGetVisible() == 2 do
		Wait(0)
	end
	transitioned = true
	CameraFade(1000, 1)
	Wait(1000)
	MinigameSetCompletion("MEN_BLANK", true, 0, unlockText)
	SoundPlayScriptedSpeechEvent(gPlayer, "PLAYER_SUCCESS", 0, "speech")
	PedSetActionNode(gPlayer, victoryAnim, "Act/Conv/C8.act")
	if unlockTextRoom then
		TutorialShowMessage(unlockTextRoom, -1, true)
		Wait(3000)
	end
	while PedIsPlaying(gPlayer, victoryAnim, true) do
		Wait(0)
	end
	NonMissionPedGenerationEnable()
	TutorialRemoveMessage()
	CameraSetWidescreen(false)
	PedLockTarget(gPlayer, -1)
end

function F_ScenePlay(sceneNo, unlockText, unlockMissionText)
end

function F_CheckIfPrefect()
	if shared.bBustedClassLaunched then
		local prefectModels = {
			49,
			50,
			51,
			52
		}
		local prefectModel = prefectModels[math.random(1, 4)]
		LoadModels({ prefectModel })
		prefect = PedCreatePoint(prefectModel, POINTLIST._PREFECTLOC)
		PedStop(prefect)
		PedClearObjectives(prefect)
		PedIgnoreStimuli(prefect, true)
		PedFaceObject(gPlayer, prefect, 2, 0)
		PedFaceObject(prefect, gPlayer, 3, 1, false)
		PedSetInvulnerable(prefect, true)
		PedSetPedToTypeAttitude(prefect, 3, 2)
		CameraSetXYZ(-707.40424, 314.81995, 35.785667, -708.06854, 314.11295, 35.543507)
		CameraFade(-1, 1)
		SoundPlayScriptedSpeechEvent(prefect, "BUSTED_CLASS", 0, "speech")
		PedSetActionNode(prefect, "/Global/Ambient/MissionSpec/Prefect/PrefectChew", "Act/Anim/Ambient.act")
		PedSetActionNode(gPlayer, "/Global/C8/PlayerFail", "Act/Conv/C8.act")
		Wait(3000)
		PedSetActionNode(gPlayer, "/Global/C8/Release", "Act/Conv/C8.act")
		shared.bBustedClassLaunched = false
		return true
	end
	return false
end

function F_CleanPrefect()
	if prefect and PedIsValid(prefect) then
		PedDelete(prefect)
	end
end

function F_Socialize(pedId, bDisableX, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 23, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 24, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 25, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 26, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 32, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 35, bDisableX)
	PlayerSocialDisableActionAgainstPed(pedId, 28, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 29, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 30, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 33, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 36, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 34, bDisableO)
	PlayerSocialDisableActionAgainstPed(pedId, 31, bDisableO)
end
