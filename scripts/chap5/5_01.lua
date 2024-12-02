ImportScript("Library/LibTable.lua")
ImportScript("Library/LibObjective.lua")
ImportScript("Library/LibPed.lua")
local keep_monitoring = true
local RatGroup = "rats"
local rat_model = 136
local rats_created = false
local max_rats = 20
local garbagePickupsTable = {}
local SpawnPoints, SpawnTriggers
local deadcount = 0
local bEnteredLibrary = false
local LibraryBlip, librarian
local librarian_last_talked_time = 0
local count_poison
local MissionEndFollowCamera = "RegularOutside"
local gStartedMidIntensity = false
local gStartedHighIntensity = false
local NUM_RATS = 20
local DeadRats = {}

function MissionSetup()
	MissionDontFadeIn()
	SoundEnableInteractiveMusic(false)
	if not debug_skip_intro then
		PlayCutsceneWithLoad("5-01", true)
	end
	DATLoad("5_01.DAT", 2)
	DATInit()
	AreaTransitionPoint(9, POINTLIST._5_01_MOVETO, nil, true)
	PlayerSetControl(0)
	Load("Act/Conv/5_01.act")
	LoadAnimationGroup("5_01Grp")
	LoadAnimationGroup("F_Nerds")
	shared.gLibraryCrateShouldShow = true
	NonMissionPedGenerationDisable()
	SpawnPoints = {
		POINTLIST._5_01_RATSPAWN01,
		POINTLIST._5_01_RATSPAWN02,
		POINTLIST._5_01_RATSPAWN03,
		POINTLIST._5_01_RATSPAWN04,
		POINTLIST._5_01_RATSPAWN05,
		POINTLIST._5_01_RATSPAWN06,
		POINTLIST._5_01_RATSPAWN07,
		POINTLIST._5_01_RATSPAWN08,
		POINTLIST._5_01_RATSPAWN09,
		POINTLIST._5_01_RATSPAWN10,
		POINTLIST._5_01_RATSPAWN11,
		POINTLIST._5_01_RATSPAWN12,
		POINTLIST._5_01_RATSPAWN13,
		POINTLIST._5_01_RATSPAWN14,
		POINTLIST._5_01_RATSPAWN15,
		POINTLIST._5_01_RATSPAWN16,
		POINTLIST._5_01_RATSPAWN17,
		POINTLIST._5_01_RATSPAWN18,
		POINTLIST._5_01_RATSPAWN19,
		POINTLIST._5_01_RATSPAWN20
	}
	SpawnTriggers = {
		TRIGGER._5_01_RATSPAWNT01,
		TRIGGER._5_01_RATSPAWNT02,
		TRIGGER._5_01_RATSPAWNT03,
		TRIGGER._5_01_RATSPAWNT04,
		TRIGGER._5_01_RATSPAWNT05,
		TRIGGER._5_01_RATSPAWNT06,
		TRIGGER._5_01_RATSPAWNT07,
		TRIGGER._5_01_RATSPAWNT08,
		TRIGGER._5_01_RATSPAWNT09,
		TRIGGER._5_01_RATSPAWNT10,
		TRIGGER._5_01_RATSPAWNT11,
		TRIGGER._5_01_RATSPAWNT12,
		TRIGGER._5_01_RATSPAWNT13,
		TRIGGER._5_01_RATSPAWNT14,
		TRIGGER._5_01_RATSPAWNT15,
		TRIGGER._5_01_RATSPAWNT16,
		TRIGGER._5_01_RATSPAWNT17,
		TRIGGER._5_01_RATSPAWNT18,
		TRIGGER._5_01_RATSPAWNT19,
		TRIGGER._5_01_RATSPAWNT20
	}
	WeaponRequestModel(395)
	WeaponRequestModel(310)
	WeaponRequestModel(312)
	WeaponRequestModel(343)
	PedRequestModel(62)
	PedRequestModel(rat_model)
	gUniqueStatus = PedGetUniqueModelStatus(rat_model)
	PedSetUniqueModelStatus(rat_model, 0)
	local i
	for i = 1, NUM_RATS do
		DeadRats[i] = -1
	end
	gSetupDone = true
end

function MissionCleanup()
	PedSetUniqueModelStatus(rat_model, gUniqueStatus)
	CameraSetWidescreen(false)
	CameraReturnToPlayer()
	F_MakePlayerSafeForNIS(false)
	PlayerSetControl(1)
	F_ClearDizzy()
	MissionStopActionController()
	MissionTimerStop()
	CounterMakeHUDVisible(false)
	--DebugPrint("MissionCleanup() start")
	if AreaGetVisible() == 9 then
	end
	for i, g in garbagePickupsTable do
		PickupDelete(g)
	end
	if not mission_succeeded then
		if librarian and PedIsValid(librarian) then
			PedDelete(librarian)
		end
		AreaEnsureSpecialEntitiesAreCreatedWithOverride("5_01", 0)
		local i
		for i = 1, NUM_RATS do
			local rat
			rat = DeadRats[i]
			if rat ~= -1 and PedIsValid(rat) then
				PedDelete(rat)
			end
		end
	end
	if LibraryBlip ~= nil then
		BlipRemove(LibraryBlip)
	end
	AreaSetDoorLocked(TRIGGER._DT_LIBRARYEXITR, false)
	UnLoadAnimationGroup("5_01Grp")
	UnLoadAnimationGroup("F_Nerds")
	UnLoadAnimationGroup("NIS_5_01")
	UnLoadBranch("/Global/5_01/")
	PlayerSetControl(1)
	SoundFadeoutStream()
	SoundEnableInteractiveMusic(true)
	DATUnload(2)
	NonMissionPedGenerationEnable()
	shared.gLibraryCrateShouldShow = false
	DATInit()
end

function main()
	while not gSetupDone do
		Wait(0)
	end
	T_LibraryInteriorInit()
	CreateThread("T_MonitorLoop")
	CreateThread("T_LibraryInteriorExitWait")
	CreateThread("T_PoisonCount")
	while not mission_done do
		if MissionTimerHasFinished() then
			MissionTimerStop()
			mission_done = true
			mission_succeeded = false
			gMissionFailMessage = "5_01_01"
		end
		Wait(100)
	end
	CounterMakeHUDVisible(false)
	if mission_succeeded then
		F_FinalCutscene()
	else
		if PedIsPlaying(gPlayer, "/Global/pxSitStl/PedPropsActions", true) then
			PedSetActionNode(gPlayer, "/Global/pxSitStl/Disengage/GetUp/GetUpChoice/GetUp", "Act/Props/pxSitStl.act")
		end
		SoundPlayMissionEndMusic(false, 4)
		if gMissionFailMessage then
			MissionFail(true, true, gMissionFailMessage)
		else
			MissionFail()
		end
	end
end

function F_FinalCutscene()
	--DebugPrint("F_FinalCutscene()")
	PlayerSetControl(0)
	SoundFadeoutStream()
	CameraAllowChange(true)
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	CameraFade(-1, 0)
	Wait(FADE_OUT_TIME)
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	PedSetActionNode(gPlayer, "/Global/5_01/5_01_Empty", "Act/Conv/5_01.act")
	CameraSetWidescreen(true)
	F_MakePlayerSafeForNIS(true)
	F_ClearDizzy()
	local x, y, z = GetPointList(POINTLIST._5_01_PLAYERENDINGSTART)
	PlayerSetPosSimple(x, y, z)
	PedClearTether(librarian)
	PedSetPosPoint(librarian, POINTLIST._5_01_LIBRARIAN, 2)
	PedStop(librarian)
	PedClearObjectives(librarian)
	PedFaceObject(librarian, gPlayer, 3, 0)
	PedFaceObject(gPlayer, librarian, 2, 0)
	PedLockTarget(librarian, gPlayer, 3)
	PedDestroyWeapon(gPlayer, 395)
	gWeaponDestroyed = true
	Wait(200)
	LoadAnimationGroup("NIS_5_01")
	PedSetActionNode(librarian, "/Global/5_01/5_01_Empty", "Act/Conv/5_01.act")
	CameraSetFOV(70)
	CameraSetXYZ(-776.6641, 202.39737, 91.45094, -775.70514, 202.67747, 91.411514)
	CameraFade(500, 1)
	Wait(501)
	PedLockTarget(librarian, gPlayer, 3)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	PedSetActionNode(librarian, "/Global/5_01/NIS/Librarian/Librarian_01", "Act/Conv/5_01.act")
	PedFollowPath(gPlayer, PATH._5_01_RETURNWEAPON, 0, 0)
	PedSetActionNode(librarian, "/Global/5_01/NIS/Librarian/Librarian_02", "Act/Conv/5_01.act")
	SoundPlayScriptedSpeechEvent(librarian, "M_5_01", 7, "jumbo")
	F_WaitForSpeech(librarian)
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	CameraSetFOV(70)
	CameraSetXYZ(-768.02185, 204.71379, 90.55249, -769.01086, 204.56741, 90.56719)
	PedFollowPath(gPlayer, PATH._5_01_ENDINGPATH, 0, 0)
	F_PlaySpeechAndWait(gPlayer, "M_5_01", 8, "large", true)
	F_PlaySpeechAndWait(librarian, "M_5_01", 9, "large", true)
	PedSetActionNode(gPlayer, "/Global/5_01/NIS/Player/Player_02", "Act/Conv/5_01.act")
	F_PlaySpeechAndWait(gPlayer, "M_5_01", 10, "large", true)
	PedFaceObject(librarian, gPlayer, 3, 0)
	PedFaceObject(gPlayer, librarian, 2, 1)
	Wait(500)
	CameraSetFOV(30)
	CameraSetXYZ(-770.6998, 202.60297, 91.63631, -771.6537, 202.90048, 91.59966)
	PedFollowPath(gPlayer, PATH._5_01_ENDINGPATH02, 0, 0)
	PedLockTarget(gPlayer, librarian, 3)
	PedSetActionNode(librarian, "/Global/5_01/NIS/Librarian/Librarian_03", "Act/Conv/5_01.act")
	SoundPlayScriptedSpeechEvent(librarian, "M_5_01", 11, "jumbo")
	PedFaceObject(gPlayer, librarian, 2, 1)
	F_WaitForSpeech(librarian)
	CameraSetFOV(70)
	CameraSetXYZ(-768.02185, 204.71379, 90.55249, -769.01086, 204.56741, 90.56719)
	PedSetActionNode(gPlayer, "/Global/5_01/NIS/Player/Player_01", "Act/Conv/5_01.act")
	F_PlaySpeechAndWait(gPlayer, "M_5_01", 12, "large", true)
	PedMakeAmbient(librarian)
	PedFollowPath(librarian, PATH._5_01_LIBRARIANEND, 0, 0)
	PedIgnoreStimuli(librarian, false)
	PedSetInvulnerable(librarian, false)
	TextPrintString("", 0.1, 2)
	CameraDefaultFOV()
	PlayerFaceHeadingNow(135)
	CameraSetXYZ(-774.10675, 201.86986, 91.276726, -773.4385, 202.6095, 91.35538)
	Wait(100)
	MinigameSetCompletion("M_PASS", true, 3000)
	MinigameAddCompletionMsg("MRESPECT_NP15", 2)
	SoundPlayMissionEndMusic(true, 4)
	SetFactionRespect(1, GetFactionRespect(1) + 15)
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	CameraFade(500, 0)
	Wait(501)
	CameraSetWidescreen(false)
	CameraReset()
	CameraReturnToPlayer(true)
	MissionSucceed(false, false, false)
	Wait(500)
	CameraFade(500, 1)
	Wait(101)
	PlayerSetControl(1)
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

function T_LibraryInteriorExitWait()
	while not bEnteredLibrary do
		Wait(33)
	end
	while AreaGetVisible() == 9 do
		Wait(33)
	end
	if not mission_done then
		keep_monitoring = false
		if idSpawner then
			AreaRemoveSpawner(idSpawner)
		end
		CounterMakeHUDVisible(false)
		MissionEndFollowCamera = "Regular"
		Wait(4000)
	end
end

function T_LibraryInteriorInit()
	--DebugPrint("T_LibraryInteriorInit start")
	PAnimOpenDoor(TRIGGER._DT_LIBRARYEXITR)
	bEnteredLibrary = true
	MissionEndFollowCamera = "Regular"
	LibraryBlip = nil
	librarian = PedCreatePoint(62, POINTLIST._5_01_LIBRARIAN)
	PedSetTetherToPoint(librarian, POINTLIST._5_01_LIBRARIAN, 0.25)
	librarian_last_talked_time = GetTimer()
	PedSetActionNode(librarian, "/Global/5_01/5_01_Librarian", "Act/Conv/5_01.act")
	PedIgnoreStimuli(librarian, true)
	tempBlip = AddBlipForChar(librarian, 0, 2)
	BlipRemove(tempBlip)
	PedSetMissionCritical(librarian, true, CbPlayerAggressed, true)
	PedMakeTargetable(librarian, false)
	CameraFade(1000, 1)
	Wait(500)
	PAnimCloseDoor(TRIGGER._DT_LIBRARYEXITR)
	F_CreateSpawner()
	PedStop(gPlayer)
	PedClearObjectives(gPlayer)
	Wait(50)
	PlayerSetControl(1)
	SoundPlayStream("MS_FinalShowdownMid.rsm", 0.35, 500, 500)
	MissionTimerStart(400)
	CameraReturnToPlayer()
	CameraReset()
	CounterMakeHUDVisible(true, true)
	CounterSetMax(max_rats)
	CounterSetIcon("Rat", "Rat_x")
	CounterSetCurrent(0)
	TextPrint("5_01_Obj", 4, 1)
	MissionObjectiveAdd("5_01_Obj")
	AreaSetDoorLocked(TRIGGER._DT_LIBRARYEXITR, true)
	PedSetPosPoint(librarian, POINTLIST._5_01_LIBRARIAN)
end

function F_PlayerIsSpraying()
	return PedIsPlaying(gPlayer, "/Global/Weapons/WeaponActions/Melee/PoisonSpray/Attacks/PoisonSpray/ShootActions/SprayAttackRun/SprayFrontRun", false)
end

local poison_count = 0
local bdizzy01 = false
local bdizzy02 = false
local bdizzy03a = false
local bdizzy03b = false
local bdizzy03c = false
local stage1 = 30000
local stage2 = 60000
local stage3a = 70000
local stage3b = 80000
local stage3c = 90000
local stage1undizzy = 25500
local stage2undizzy = 51000

function T_PoisonCount()
	count_poison = true
	while count_poison do
		if F_PlayerIsSpraying() then
			poison_count = poison_count + 100
		elseif poison_count - 50 >= 0 then
			poison_count = poison_count - 50
		end
		Wait(33)
		if poison_count > stage1 and not bdizzy01 then
			bdizzy01 = true
			MissionPlayActionNode("/Global/5_01/5_01_PoisonEffect1")
			if PedIsValid(librarian) then
				SoundPlayScriptedSpeechEvent(librarian, "M_5_01", 4, "large")
			end
		end
		if poison_count > stage2 and not bdizzy02 then
			bdizzy02 = true
			MissionPlayActionNode("/Global/5_01/5_01_PoisonEffect2")
			if PedIsValid(librarian) then
				SoundPlayScriptedSpeechEvent(librarian, "M_5_01", 5, "large")
			end
		end
		if bdizzy02 and poison_count < stage2undizzy then
			MissionPlayActionNode("/Global/5_01/5_01_PoisonEffect2/5_01_PoisonEffect2intro/5_01_PoisonEffect2cycle/5_01_PoisonEffect2outro")
			TextPrintString("", 2, 2)
			bdizzy02 = false
			bdizzy01 = false
		end
		if bdizzy01 and poison_count < stage1undizzy then
			MissionPlayActionNode("/Global/5_01/5_01_PoisonEffect1/5_01_PoisonEffect1intro/5_01_PoisonEffect1cycle/5_01_PoisonEffect1outro")
			bdizzy01 = false
			bdizzy02 = false
		end
	end
end

local spawn_loc = {
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1
}

function F_CreateSpawner()
	Wait(1000)
	--DebugPrint("F_CreateSpawner() start")
	local idx
	if idSpawner == nil then
		idSpawner = AreaAddMissionSpawner(max_rats, 15, -1, 0, 1000)
		AreaMissionSpawnerSetCallback(idSpawner, F_SpawnerCallback)
		for i = 1, NUM_RATS do
			spawn_loc[i] = AreaAddSpawnLocation(idSpawner, SpawnPoints[i], SpawnTriggers[i])
			AreaAddPedModelIdToSpawnLocation(idSpawner, spawn_loc[i], rat_model)
		end
		spawn_loc = nil
	end
	AreaMissionSpawnerSetActivated(idSpawner, true)
	--DebugPrint("F_CreateSpawner() end")
end

local spawncount = 0

function F_SpawnerCallback(idPed, idSpawner)
	spawncount = spawncount + 1
	PedMakeMissionChar(idPed)
	PedSetTetherToTrigger(idPed, TRIGGER._5_01_MAIN_ROOM_TR)
	blipID = AddBlipForChar(idPed, 2, 2, 1)
	L_PedLoad(RatGroup, {
		{ id = idPed, blip = blipID }
	})
	rats_created = true
	--DebugPrint("[RAUL] - F_SpawnerCallback() for " .. idPed .. " which is number: " .. spawncount .. " with blipID: " .. blipID)
end

function F_SetSecondFloorInvisible(p_invisible)
	local alpha = 126
	if not p_invisible then
		alpha = 255
	end
	GeometryInstance("HID_LCountrBm", p_invisible, -772.679, 205.913, 94.1227, not p_invisible)
	GeometryInstance("DCL_LibShdw02", p_invisible, -772.036, 203.127, 94.1479, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -762.324, 207.864, 94.2906, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -762.324, 200.939, 94.2908, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -762.324, 194.288, 94.2949, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -771.469, 216.069, 94.3053, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -778.063, 216.069, 94.3053, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -763.917, 216.069, 94.3053, not p_invisible)
	GeometryInstance("DCL_LibShdw03", p_invisible, -768.804, 203.079, 94.5468, not p_invisible)
	GeometryInstance("DCL_LibShdw01", p_invisible, -773.462, 203.12, 95.0835, not p_invisible)
	GeometryInstance("HID_LibBloomo06", p_invisible, -770.202, 205.176, 95.3861, not p_invisible)
	GeometryInstance("Lib_PortrtB", p_invisible, -768.746, 192.093, 95.5403, not p_invisible)
	GeometryInstance("Lib_PortrtA", p_invisible, -768.804, 213.073, 95.7541, not p_invisible)
	GeometryInstance("LibCoffTble", p_invisible, -760.981, 214.797, 95.8932, not p_invisible)
	GeometryInstance("RndStand", p_invisible, -758.03, 217.269, 95.9858, not p_invisible)
	GeometryInstance("HID_2ndFlor", p_invisible, -768.802, 203.208, 95.9957, not p_invisible)
	GeometryInstance("ChessTble", p_invisible, -762.398, 189.321, 96.0133, not p_invisible)
	GeometryInstance("ChessTble", p_invisible, -760.159, 191.748, 96.0133, not p_invisible)
	GeometryInstance("ChessTble", p_invisible, -759.619, 189.321, 96.0133, not p_invisible)
	GeometryInstance("LibChair", p_invisible, -759.666, 191.784, 96.2315, not p_invisible)
	GeometryInstance("LibChair", p_invisible, -760.877, 191.784, 96.2315, not p_invisible)
	GeometryInstance("LibChair", p_invisible, -762.409, 189.89, 96.2315, not p_invisible)
	GeometryInstance("LibChair", p_invisible, -762.409, 188.665, 96.2315, not p_invisible)
	GeometryInstance("LibChair", p_invisible, -759.634, 188.665, 96.2315, not p_invisible)
	GeometryInstance("LibChair", p_invisible, -759.634, 189.89, 96.2315, not p_invisible)
	GeometryInstance("LibSofa", p_invisible, -760.85, 217.205, 96.244, not p_invisible)
	GeometryInstance("LibSofa", p_invisible, -757.921, 214.704, 96.2477, not p_invisible)
	GeometryInstance("LibFern", p_invisible, -760.917, 214.763, 96.3345, not p_invisible)
	GeometryInstance("Standlamp", p_invisible, -757.683, 187.425, 96.5913, not p_invisible)
	GeometryInstance("Standlamp", p_invisible, -757.802, 213.247, 96.5913, not p_invisible)
	GeometryInstance("HID_LibBloom5", p_invisible, -768.69, 203.393, 96.606, not p_invisible)
	GeometryInstance("LibDecoLamp", p_invisible, -758.05, 217.24, 96.6706, not p_invisible)
	GeometryInstance("LibTallPlant", p_invisible, -763.929, 187.721, 96.7284, not p_invisible)
	GeometryInstance("Lib_BkShelf", p_invisible, -763.348, 217.887, 96.7839, not p_invisible)
	GeometryInstance("Lib_vent", p_invisible, -769.771, 209.114, 97.0028, not p_invisible)
	GeometryInstance("LIB_BKCase04", p_invisible, -759.214, 199.54, 97.1002, not p_invisible)
	GeometryInstance("LIB_BKCase28", p_invisible, -772.605, 217.647, 97.1002, not p_invisible)
	GeometryInstance("LIB_BKCase31", p_invisible, -772.56, 216.259, 97.1002, not p_invisible)
	GeometryInstance("ShelfLamp", p_invisible, -761.167, 194.232, 97.466, not p_invisible)
	GeometryInstance("ShelfLamp", p_invisible, -761.167, 197.624, 97.466, not p_invisible)
	GeometryInstance("ShelfLamp", p_invisible, -761.167, 201.23, 97.466, not p_invisible)
	GeometryInstance("ShelfLamp", p_invisible, -761.167, 204.904, 97.466, not p_invisible)
	GeometryInstance("ShelfLamp", p_invisible, -776.291, 214.31, 97.466, not p_invisible)
	GeometryInstance("ShelfLamp", p_invisible, -779.893, 214.304, 97.466, not p_invisible)
	GeometryInstance("ShelfLamp", p_invisible, -772.622, 214.308, 97.466, not p_invisible)
	GeometryInstance("ShelfLamp", p_invisible, -768.942, 214.307, 97.466, not p_invisible)
	GeometryInstance("ShelfLamp", p_invisible, -765.248, 214.307, 97.466, not p_invisible)
	GeometryInstance("LibLrgChandlr", p_invisible, -775.55, 192.878, 97.8599, not p_invisible)
	GeometryInstance("LibLrgChandlr", p_invisible, -775.55, 202.675, 97.8599, not p_invisible)
	GeometryInstance("LibLrgChandlr", p_invisible, -769.286, 202.675, 97.8599, not p_invisible)
	GeometryInstance("LibLrgChandlr", p_invisible, -769.257, 192.877, 97.8599, not p_invisible)
	GeometryInstance("LibLrgChandlr", p_invisible, -772.383, 222.502, 98.0303, not p_invisible)
	GeometryInstance("LibLrgChandlr", p_invisible, -772.383, 183.713, 98.0406, not p_invisible)
	GeometryInstance("LibLrgChandlr", p_invisible, -784.708, 203.135, 98.0406, not p_invisible)
	GeometryInstance("LibLrgChandlr", p_invisible, -784.708, 219.378, 98.0406, not p_invisible)
	GeometryInstance("LibLrgChandlr", p_invisible, -784.708, 185.82, 98.0406, not p_invisible)
	GeometryInstance("HID_LbArches02", p_invisible, -772.293, 198.922, 98.1125, not p_invisible)
	GeometryInstance("Lib_BooksA", p_invisible, -778.12, 217.608, 98.78, not p_invisible)
	GeometryInstance("Lib_BooksA", p_invisible, -770.633, 217.922, 98.78, not p_invisible)
	GeometryInstance("Lib_BooksC", p_invisible, -776.297, 215.945, 98.7813, not p_invisible)
	GeometryInstance("Lib_BooksC", p_invisible, -759.557, 204.869, 98.7848, not p_invisible)
	GeometryInstance("Lib_BooksD", p_invisible, -759.778, 197.721, 98.791, not p_invisible)
	GeometryInstance("Lib_BooksD", p_invisible, -769.02, 215.717, 98.791, not p_invisible)
	GeometryInstance("Lib_BooksD", p_invisible, -774.411, 217.557, 98.7988, not p_invisible)
	GeometryInstance("Lib_BooksD", p_invisible, -757.789, 203.397, 98.7988, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -762.675, 194.288, 99.7264, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -762.675, 200.939, 99.7464, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -775.174, 212.589, 99.7553, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -768.58, 212.589, 99.7553, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -760.916, 214.832, 99.7553, not p_invisible)
	GeometryInstance("LibMiniChndlr", p_invisible, -762.675, 207.848, 99.7671, not p_invisible)
	GeometryInstance("HID_Penn27", p_invisible, -772.625, 209.637, 100.225, not p_invisible)
	GeometryInstance("DCL_LibBloom5", p_invisible, -769.642, 202.155, 101.006, not p_invisible)
	GeometryInstance("HID_LibTPFlr", p_invisible, -768.802, 202.576, 95.6264, not p_invisible)
	GeometryInstance("HID_LIBceling", p_invisible, -768.8, 202.576, 101.011, not p_invisible)
	GeometryInstance("DCL_LibBloom86", p_invisible, -772.677, 203.128, 93.6025, not p_invisible)
end

function F_CustomDeadCounter(ratped)
	if ratped and ratped.id and PedIsDead(ratped.id) or PedIsValid(ratped.id) and PedGetHealth(ratped.id) <= 0 then
		deadcount = deadcount + 1
		DeadRats[deadcount] = ratped.id
		if deadcount == 7 and gStartedMidIntensity == false then
			SoundPlayStream("MS_FinalShowdownMid.rsm", 0.6, 500, 500)
			gStartedMidIntensity = true
		end
		if deadcount == 13 and gStartedHighIntensity == false then
			SoundPlayStream("MS_FinalShowdownHigh.rsm", 0.7, 500, 500)
			gStartedHighIntensity = true
		end
	end
end

function F_RemoveBlipsIterator(ratped)
	if ratped and ratped.blip and ratped.id and PedGetHealth(ratped.id) <= 0 then
		BlipRemove(ratped.blip)
		--DebugPrint("******************* 1 Removed blip: " .. ratped.blip)
		ratped.blip = nil
	end
end

function T_MonitorLoop()
	local quip
	while keep_monitoring do
		Wait(10)
		if librarian and GetTimer() - librarian_last_talked_time > 12000 then
			SoundPlayScriptedSpeechEvent(librarian, "M_5_01", 1, "large")
			librarian_last_talked_time = GetTimer() + (math.random(5) - 1) * 1000
		end
		if rats_created then
			deadcount = 0
			L_PedIterateWithFunc(RatGroup, F_CustomDeadCounter)
			L_PedIterateWithFunc(RatGroup, F_RemoveBlipsIterator)
			CounterSetCurrent(deadcount)
		end
		if rats_created and deadcount == max_rats then
			mission_succeeded = true
			break
		end
	end
	Wait(1000)
	mission_done = true
end

function F_ClearDizzy()
	poison_count = 0
	MissionPlayActionNode("/Global/5_01/5_01_PoisonEffect0")
	MissionUpdateActionController()
	bdizzy01 = false
	bdizzy02 = false
end

function F_PedsFromPointList(group, pointlist, modelReq, attackingReq, targetReq)
	pointlistSize = GetPointListSize(pointlist)
	isFunc = "function" == type(modelReq)
	temp_att = attackingReq or false
	temp_target = targetReq
	for i = 1, pointlistSize do
		if isFunc then
			temp_model = modelReq()
		else
			temp_model = modelReq
		end
		x1, y1, z1 = GetPointFromPointList(pointlist, i)
		L_PedLoadXYZ(group, {
			{
				model = temp_model,
				x = x1,
				y = y1,
				z = z1,
				target = temp_target,
				KO = false,
				attacking = temp_att,
				--DebugPrint("F_PedsFromPointList(): created model " .. temp_model .. " at x:" .. x1 .. " y:" .. y1 .. " z:" .. z1),
				--DebugPrint("F_PedsFromPointList(): number" .. i .. " of " .. pointlistSize)
			}
		})
	end
end

function T_DieCamera()
	--DebugPrint("T_DieCamera() start")
	--DebugPrint("T_DieCamera() end")
end

function CbPlayerAggressed()
	--print("PLAYER HAS AGGRESSED !!!!")
	MissionTimerStop()
	mission_done = true
	mission_succeeded = false
	gMissionFailMessage = "5_01_02"
end
