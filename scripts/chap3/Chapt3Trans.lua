local pete
local peds = {}

function MissionSetup()
	MissionDontFadeIn()
	DATLoad("Chapt3Trans.DAT", 2)
	SoundDisableSpeech_ActionTree()
	SoundStopCurrentSpeechEvent()
	PedClearPOIForAllPeds()
	AreaClearAllPeds()
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	LoadAnimationGroup("Hang_Talking")
	LoadActionTree("Act/Conv/Chapt3Trans.act")
	ChapterSet(3)
	LoadPedModels({
		71,
		85,
		102,
		69,
		5,
		39
	})
	ClockSet(8, 30)
	SoundStopCurrentSpeechEvent()
	SystemEnableFrontEndAndSelectScreens(false)
end

function main()
	PlayerSetHealth(200)
	PlayerSetPunishmentPoints(0)
	AreaLoadSpecialEntities("Christmas", false)
	AreaTransitionPoint(0, POINTLIST._CHAPT3TRANSPED, 1, true)
	pete = PedCreatePoint(134, POINTLIST._CHAPT3TRANSPED, 2)
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	SoundPreloadSpeech(gPlayer, "NARRATION", 112, "supersize", true)
	Wait(50)
	while not SoundIsSpeechPreloaded() do
		Wait(0)
	end
	CameraSetXYZ(298.85968, -73.13537, 9.273766, 297.86002, -73.110916, 9.280636)
	CameraSetPath(PATH._CHAPT3TRANS_CAM, true)
	CameraLookAtXYZ(249.25732, -72.784676, 9.223299, true)
	CameraSetSpeed(2, 0, 0)
	local ped = PedCreatePoint(69, POINTLIST._CHAPT3TRANSFLEE, 1)
	PedFollowPath(ped, PATH._C3T_FLEE, 0, 3)
	table.insert(peds, ped)
	local ped2 = PedCreatePoint(102, POINTLIST._CHAPT3TRANSFLEE, 2)
	PedAttack(ped2, ped, 3)
	table.insert(peds, ped)
	ped = PedCreatePoint(85, POINTLIST._CHAPT3TRANSFATTY, 2)
	table.insert(peds, ped)
	ped = PedCreatePoint(71, POINTLIST._CHAPT3TRANSFATTY, 1)
	PedFollowPath(ped, PATH._C3T_FATBOY, 0, 0)
	table.insert(peds, ped)
	ped = PedCreatePoint(5, POINTLIST._CHAPT3TRANSCOUPLE, 1)
	PedFollowPath(ped, PATH._C3T_COUPLE1, 0, 0)
	table.insert(peds, ped)
	ped = PedCreatePoint(39, POINTLIST._CHAPT3TRANSCOUPLE, 2)
	PedFollowPath(ped, PATH._C3T_COUPLE2, 0, 0)
	table.insert(peds, ped)
	MinigameSetChapterCompletion("Chapt3Trans_Title", "Chapt3Trans_Name", true, 0)
	MinigameHoldCompletion()
	CameraFade(500, 1)
	Wait(501)
	PedFollowPath(gPlayer, PATH._C3T_PLAYER, 0, 0)
	PedFollowPath(pete, PATH._C3T_PETEY, 0, 0)
	SoundPlayPreloadedSpeech()
	CameraSetSpeed(10, 10, 10)
	Wait(50)
	SoundPreloadSpeech(gPlayer, "NARRATION", 113, "supersize", true)
	Wait(50)
	while not SoundIsSpeechPreloaded() do
		Wait(0)
	end
	while SoundSpeechPlaying(gPlayer, "NARRATION", 112) do
		Wait(0)
	end
	SoundPlayPreloadedSpeech()
	Wait(50)
	SoundPreloadSpeech(gPlayer, "NARRATION", 114, "supersize", true)
	Wait(50)
	while not SoundIsSpeechPreloaded() do
		Wait(0)
	end
	while SoundSpeechPlaying(gPlayer, "NARRATION", 113) do
		Wait(0)
	end
	SoundPlayPreloadedSpeech()
	Wait(50)
	while SoundSpeechPlaying(gPlayer, "NARRATION", 114) do
		Wait(0)
	end
	MinigameReleaseCompletion()
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	CameraFade(500, 0)
	Wait(500)
	PedDelete(pete)
	for i, ped in peds do
		if ped and PedIsValid(ped) then
			PedDelete(ped)
		end
	end
	UnloadModels({
		71,
		85,
		102,
		69,
		5,
		39
	})
	PlayCutsceneWithLoad("4-0", true, true)
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	pete = PedCreatePoint(134, POINTLIST._CHAPT3ENDPETE, 1)
	PlayerSetPosPoint(POINTLIST._CHAPT3ENDPLYR, 1)
	PlayerFaceHeading(180, 0)
	Wait(300)
	CameraReset()
	CameraReturnToPlayer()
	CameraFade(500, 1)
	Wait(501)
	PedSetActionNode(pete, "/Global/Chapter3Trans/JimmyBye", "Act/Conv/Chapt3Trans.act")
	SoundPlayScriptedSpeechEvent(pete, "BYE", 0, "large")
	PedMakeAmbient(pete)
	PedMoveToXYZ(pete, 0, 187.708, -159.923, 8.944, 1, true)
	Wait(3000)
	MissionSucceed(false, false, false)
end

function MissionCleanup()
	PedWander(pete, 0)
	PedMakeAmbient(pete)
	CameraReturnToPlayer()
	PlayerSetScriptSavedData(3, PlayerGetNumTimesBusted())
	PlayerSetScriptSavedData(14, 0)
	SoundEnableSpeech_ActionTree()
	AreaRevertToDefaultPopulation()
	SoundRemoveAllQueuedSpeech(gPlayer)
	SetFactionRespect(11, 100)
	SetFactionRespect(1, 100)
	SetFactionRespect(5, 100)
	SetFactionRespect(4, 100)
	SetFactionRespect(2, 45)
	SetFactionRespect(3, 0)
	SystemEnableFrontEndAndSelectScreens(true)
	DATUnload(2)
end
