local bDebugFlag = false
local gDebugLevel = 2
local gGary, gGaryBlip
local gGaryCanAvoid = false
local effectTable = {}
local bellTowerCamera = false
local stage = 0
local mission_running = true
local mission_pass = false
local Break = 0
local ScaffoldOneBroke = false
local ScaffoldTwoBroke = false
local ScaffoldThreeBroke = false
local GARY_ANGRY = false
local GaryCanThrowStuff = true
local CollisionApply = 0
local OBJONE, OBJTWO
local One = true
local bTrigger01 = false
local bTrigger02 = false
local bTrigger03 = false
local bTrigger04 = false
local bTrigger05 = false
local bTrigger06 = false
local bTrigger07 = false
local bTrigger08 = false
local bTrigger09 = false
local bTrigger10 = false
local bLoop = true
local bMissionFailed = false
local bMissionPassed = false
local bGoToStage2 = false
local bStartedCompletionThread = false
local bMonitorPlayerOnLadder = false
local bHadToResetPlayersCamera = false
local gMissionFailMessage = 0

function MissionSetup()
	--print("()xxxxx[:::::::::::::::> [start] MissionSetup()")
	MissionDontFadeIn()
	ClockSet(19, 0)
	WeatherSet(2, true)
	DATLoad("6_Ba.DAT", 2)
	DATLoad("6_B.DAT", 2)
	DATInit()
	if shared.b602reachedScaffolds == true then
		PlayCutsceneWithLoad("6-BB", true)
	else
		PlayCutsceneWithLoad("6-B", true)
	end
	PlayerSetControl(0)
	--print("()xxxxx[:::::::::::::::> [finish] MissionSetup()")
end

function MissionCleanup()
	--print("()xxxxx[:::::::::::::::> [start] MissionCleanup()")
	PlayerSetControl(1)
	DisablePunishmentSystem(false)
	PedSetInvulnerable(gPlayer, false)
	SoundEmitterStop(197.159, -75.7203, 46.4597, "BELLSTHREE")
	SoundEmitterStop(191.725, -75.7203, 46.4597, "BELLSTWO")
	SoundEmitterStop(186.275, -71.1643, 46.4597, "BELLSONE")
	SoundStopStream()
	if PlayerGetHealth() < 200 then
		PlayerSetHealth(200)
	end
	CameraAllowChange(true)
	CameraReturnToPlayer()
	PedSetFlag(gPlayer, 58, false)
	DATUnload(2)
	WeatherRelease()
	F_EffectCleanup()
	DATInit()
	NonMissionPedGenerationEnable()
	UnLoadAnimationGroup("Px_Rail")
	UnLoadAnimationGroup("Boxing")
	UnLoadAnimationGroup("6B_PARA")
	UnLoadAnimationGroup("Russell")
	UnLoadAnimationGroup("Nemesis")
	UnLoadAnimationGroup("MINI_React")
	ToggleHUDComponentVisibility(17, false)
	if bellTowerCamera == true then
		GeometryInstance("SC1d_mainTop", false, 191.749, -73.3786, 56.352, false)
		GeometryInstance("SC1d_mainTopProxy", false, 191.731, -73.3668, 56.2318, false)
	end
	CameraSetWidescreen(false)
	PedSetActionNode(gPlayer, "/Global/6_B/GravityReset", "Act/Conv/6_B.act")
	PedRestoreWeaponInventorySnapshot(gPlayer)
	mission_running = false
	--print("()xxxxx[:::::::::::::::> [finish] MissionCleanup()")
end

function main()
	--print("()xxxxx[:::::::::::::::> [start] main()")
	F_SetupMission()
	if bDebugFlag then
		if gDebugLevel == 2 then
			F_StartAtStage2()
		end
	elseif shared.b602reachedScaffolds == true then
		F_StartAtStage2()
	else
		F_Stage1()
	end
	if bMissionFailed then
		PlayerSetControl(0)
		TextPrint("6_B_EMPTY", 1, 1)
		SoundPlayMissionEndMusic(false, 10)
		if gMissionFailMessage == 1 then
			MissionFail(false, true, "6_B_FAIL_01")
			local x1, y1, z1 = PedGetOffsetInWorldCoords(gPlayer, 0.5, 1, 1.2)
			local x2, y2, z2 = PedGetOffsetInWorldCoords(gPlayer, -0.5, -0.7, 1.7)
			CameraSetXYZ(x1, y1, z1, x2, y2, z2)
			PedSetActionNode(gPlayer, "/Global/6_B/Failure", "Act/Conv/6_B.act")
		elseif gMissionFailMessage == 2 then
			MissionFail(false, true, "6_B_FAIL_02")
		elseif gMissionFailMessage == 3 then
			MissionFail(false, true, "6_B_FAIL_03")
		else
			MissionFail(false)
		end
	elseif bMissionPassed then
		if Break ~= 4 then
			PAnimApplyDamage("Scaffold", 178.173, -73.1613, 40.1403, 251)
			PAnimApplyDamage("Scaffold", 178.173, -73.1613, 35.2763, 251)
			PAnimApplyDamage("Scaffold", 178.173, -73.1613, 30.5194, 251)
			SoundPlay2D("ScaffoldCrash")
			SetUpCamera(4)
			Break = 4
		end
		F_CrashThroughRoofCutscene()
		UnLoadAnimationGroup("Px_Rail")
		UnLoadAnimationGroup("6B_PARA")
		UnLoadAnimationGroup("Boxing")
		UnLoadAnimationGroup("Russell")
		UnLoadAnimationGroup("Nemesis")
		UnLoadAnimationGroup("MINI_React")
		PlayCutsceneWithLoad("6-BC", true)
		local schoolx, schooly, schoolz = GetPointList(POINTLIST._PLAYER_START)
		AreaForceLoadAreaByAreaTransition(true)
		AreaDisableCameraControlForTransition(true)
		AreaTransitionXYZ(0, schoolx, schooly, 10)
		AreaDisableCameraControlForTransition(false)
		AreaForceLoadAreaByAreaTransition(false)
		SetFactionRespect(11, 100)
		SetFactionRespect(1, 100)
		SetFactionRespect(5, 100)
		SetFactionRespect(4, 100)
		SetFactionRespect(2, 100)
		SetFactionRespect(3, 100)
		UnlockYearbookPicture(130)
		F_UnlockYearbookReward()
		MissionSucceed(true, false, false)
	end
	--print("()xxxxx[:::::::::::::::> [finish] main()")
end

function F_SetupMission()
	--print("()xxxxx[:::::::::::::::> [start] F_SetupMission()")
	DisablePunishmentSystem(true)
	NonMissionPedGenerationDisable()
	LoadAnimationGroup("Px_Rail")
	LoadAnimationGroup("6B_PARA")
	LoadAnimationGroup("Boxing")
	LoadAnimationGroup("Russell")
	LoadAnimationGroup("Nemesis")
	LoadAnimationGroup("MINI_React")
	LoadActionTree("Act/AI/AI_Gary.act")
	LoadActionTree("Act/Conv/6_B.act")
	PedSetFlag(gPlayer, 58, true)
	F_SetupRoof()
	PedSetWeaponNow(gPlayer, -1, 0)
	PedSaveWeaponInventorySnapshot(gPlayer)
	PedClearAllWeapons(gPlayer)
	--print("()xxxxx[:::::::::::::::> [finish] F_SetupMission()")
end

function F_Intro()
	--print("()xxxxx[:::::::::::::::> [start] F_Intro()")
	--print("()xxxxx[:::::::::::::::> [finish] F_Intro()")
end

function F_Stage1()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1()")
	F_Stage1_Setup()
	F_Stage1_Loop()
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1()")
end

function F_Stage1_Setup()
	--print("()xxxxx[:::::::::::::::> [start] F_Stage1_Setup()")
	AreaTransitionPoint(0, POINTLIST._6_B_PLAYERSTART, 1, true)
	F_ResetPAnims()
	F_BellSetup()
	F_BellSwingScatter()
	CreateThread("T_CheckPlayerHealth")
	CreateThread("T_GaryBlahBlah")
	local ActionTreeIndex
	ActionTreeIndex = RequestActionTree("Rails")
	if 0 < ActionTreeIndex then
		while not IsActionTreeLoaded(ActionTreeIndex) do
			--print("()xxxxx[:::::::::::::::> Waiting for Rails action tree to load.")
			Wait(0)
		end
	end
	while IsStreamingBusy() do
		Wait(0)
	end
	CameraFade(500, 1)
	Wait(500)
	PlayerSetControl(1)
	SoundPlayStream("MS_FinalShowdown03Low.rsm", 0.75)
	TextPrint("6_B_MOBJ_01", 3, 1)
	OBJONE = MissionObjectiveAdd("6_B_MOBJ_01")
	stage = 0
	CreateThread("T_GaryUpdater")
	CreateThread("T_RoofCheck")
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage1_Setup()")
end

function F_Stage1_Loop()
	while bLoop do
		Stage1_Objectives()
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
	shared.b602reachedScaffolds = true
	Wait(100)
	if F_PedExists(gGary) then
		PedSetMissionCritical(gGary, false)
		PedDelete(gGary)
	end
	CreateThread("T_ScaffoldBreak")
	gGary = PedCreatePoint(130, POINTLIST._6_B_GARYPOSITION)
	PedOverrideStat(gGary, 34, 0)
	PedSetHealth(gGary, 400)
	GaryHealth = PedGetHealth(gGary)
	PedSetActionTree(gGary, "/Global/Nemesis", "Act/Anim/Nemesis.act")
	PedSetAITree(gGary, "/Global/GaryAI", "Act/AI/AI_Gary.act")
	local tempX, tempY, tempZ = GetPointList(POINTLIST._6_B_PLAYERPOSITION)
	PlayerSetPosSimple(tempX, tempY, tempZ)
	PedFaceObject(gPlayer, gGary, 2, 0)
	PedSetPosPoint(gGary, POINTLIST._6_B_GARYPOSITION)
	CreateThread("T_AngryHit")
	SetUpCamera(1)
	PedShowHealthBar(gGary, true, "6_B_GARY", true)
	CameraFade(500, 1)
	Wait(500)
	PlayerSetControl(1)
	PedAttackPlayer(gGary)
	PedSetInvulnerable(gGary, false)
	SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 22, "large", false, true)
	SoundPlayStream("MS_FinalShowdown03High.rsm", 0.75)
	MissionObjectiveComplete(OBJONE)
	OBJTWO = MissionObjectiveAdd("6_B_MOBJ_02")
	Wait(10)
	PedSetActionNode(gGary, "/Global/HitTree/Standing/PostHit/BellyUp/OnGroundBounce/BounceLegsUp_L", "Act/HitTree.act")
	PedSetActionNode(gPlayer, "/Global/HitTree/Standing/PostHit/BellyUp/OnGroundBounce/BounceLegsUp_L", "Act/HitTree.act")
	--print("()xxxxx[:::::::::::::::> [finish] F_Stage2_Setup()")
end

function F_Stage2_Loop()
	while bLoop do
		Stage2_Objectives()
		if bMissionPassed or bMissionFailed then
			break
		end
		Wait(0)
	end
end

function Stage1_Objectives()
	if not bTrigger01 and PlayerIsInTrigger(TRIGGER._6_B_GARY_TRIGGER_1) then
		GaryCanThrowStuff = false
		PedSetActionTree(gGary, "/Global/Nemesis", "Act/Anim/Nemesis.act")
		--print("===Current Stage 1 =====")
		PedSetActionNode(gGary, "/Global/Nemesis/Default_KEY/Idle", "Act/Anim/Nemesis.act")
		gGaryCanAvoid = true
		PedSetInvulnerable(gGary, true)
		stage = 1
		CreateThread("T_GaryUpdater")
		CreateThread("T_RoofCheck")
		bTrigger01 = true
	end
	if not bTrigger02 and PlayerIsInTrigger(TRIGGER._6_B_LADDER1_BEGIN) and PedIsPlaying(gPlayer, "/Global/Ladder/Ladder_Actions/Climb_ON_BOT", true) then
		--print("====Start the wheelbarrow!!====")
		x, y, z = GetPointFromPointList(POINTLIST._6_B_LADDERSETUP1, 1)
		CameraLookAtXYZ(x, y, z, false)
		CameraSetPath(PATH._6_B_LADDERSETUP1, false)
		CameraSetSpeed(30, 5, 5)
		PedSetActionNode(gGary, "/Global/Nemesis/Special/WheelBarrowInteract", "Act/Anim/Nemesis.act")
		CollisionApply = 4
		CreateThread("T_CollisionApply")
		bMonitorPlayerOnLadder = true
		CreateThread("T_MonitorPlayerFirstLadder")
		StruggleButtonSetDisplay(1)
		StruggleButtonSetText("MEN_BLANK")
		ToggleHUDComponentVisibility(17, true)
		Wait(4300)
		GaryCanThrowStuff = false
		PedSetActionNode(gGary, "/Global/Nemesis", "Act/Anim/Nemesis.act")
		--print("===Current Stage 2 =====")
		gGaryCanAvoid = true
		PedSetInvulnerable(gGary, true)
		stage = 2
		CreateThread("T_GaryUpdater")
		Wait(1500)
		bMonitorPlayerOnLadder = false
		if not bHadToResetPlayersCamera then
			CameraReset()
			CameraReturnToPlayer()
		end
		ToggleHUDComponentVisibility(17, false)
		SoundPlayStream("MS_FinalShowdown03Mid.rsm", 0.75)
		bTrigger02 = true
	end
	if not bTrigger03 and PlayerIsInTrigger(TRIGGER._6_B_GARY_TRIGGER_3) then
		GaryCanThrowStuff = false
		PedSetActionTree(gGary, "/Global/Nemesis", "Act/Anim/Nemesis.act")
		--print("===Current Stage 3 =====")
		gGaryCanAvoid = true
		PedSetInvulnerable(gGary, true)
		stage = 3
		CreateThread("T_GaryUpdater")
		bTrigger03 = true
	end
	if not bTrigger04 and PlayerIsInTrigger(TRIGGER._6_B_GARY_TRIGGER_5) then
		GaryCanThrowStuff = false
		PedSetActionTree(gGary, "/Global/Nemesis", "Act/Anim/Nemesis.act")
		--print("===Current Stage 4 =====")
		gGaryCanAvoid = true
		PedSetInvulnerable(gGary, true)
		stage = 4
		CreateThread("T_GaryUpdater")
		bTrigger04 = true
	end
	if not bTrigger05 and PlayerIsInTrigger(TRIGGER._6_B_LADDER2_BEGIN) and PedIsPlaying(gPlayer, "/Global/Ladder/Ladder_Actions/Climb_ON_BOT", true) then
		--print("====Start the wheelbarrow!!222====")
		bHadToResetPlayersCamera = false
		local hdg = PedGetHeading(gGary)
		PedFaceHeading(gGary, hdg + 180, 0)
		x, y, z = GetPointFromPointList(POINTLIST._6_B_LADDERSETUP2, 1)
		CameraLookAtXYZ(x, y, z, false)
		CameraSetPath(PATH._6_B_LADDERSETUP2, false)
		CameraSetSpeed(30, 5, 5)
		PedSetActionNode(gGary, "/Global/Nemesis/Special/WheelBarrowInteract", "Act/Anim/Nemesis.act")
		CollisionApply = 5
		CreateThread("T_CollisionApply")
		bMonitorPlayerOnLadder = true
		CreateThread("T_MonitorPlayerSecondLadder")
		StruggleButtonSetDisplay(1)
		StruggleButtonSetText("MEN_BLANK")
		ToggleHUDComponentVisibility(17, true)
		Wait(4300)
		GaryCanThrowStuff = false
		PedSetActionNode(gGary, "/Global/Nemesis", "Act/Anim/Nemesis.act")
		--print("===Current Stage 5 =====")
		gGaryCanAvoid = true
		PedSetInvulnerable(gGary, true)
		stage = 5
		CreateThread("T_GaryUpdater")
		Wait(1500)
		bMonitorPlayerOnLadder = false
		if not bHadToResetPlayersCamera then
			CameraReset()
			CameraReturnToPlayer()
		end
		ToggleHUDComponentVisibility(17, false)
		bTrigger05 = true
	end
	if not bTrigger06 and PlayerIsInTrigger(TRIGGER._6_B_GARY_TRIGGER_6) then
		SoundEmitterStart(197.159, -75.7203, 46.4597, "BELLSTHREE", "BellTower")
		SoundEmitterStart(191.725, -75.7203, 46.4597, "BELLSTWO", "BellTower")
		SoundEmitterStart(186.275, -71.1643, 46.4597, "BELLSONE", "BellTower")
		bTrigger06 = true
	end
	if not bTrigger07 and PlayerIsInTrigger(TRIGGER._6_B_BELLS_ONE) then
		CollisionApply = 1
		PAnimSetActionNode("SCBell", 197.159, -75.7203, 46.4597, 1, "/Global/SCBELL/Idle/DoDamage", "Act/Props/SCBell.act")
		CreateThread("T_CollisionApply")
		One = false
		SoundEmitterStop(197.159, -75.7203, 46.4597, "BELLSTHREE")
		PedFaceObject(gGary, gPlayer, 3, 1, false)
		bTrigger07 = true
	end
	if not bTrigger08 and PlayerIsInTrigger(TRIGGER._6_B_BELLS_TWO) then
		CollisionApply = 2
		PAnimSetActionNode("SCBell", 191.725, -75.7203, 46.4597, 1, "/Global/SCBELL/Idle/DoDamage", "Act/Props/SCBell.act")
		CreateThread("T_CollisionApply")
		SoundEmitterStop(191.725, -75.7203, 46.4597, "BELLSTWO")
		bTrigger08 = true
	end
	if not bTrigger09 and PlayerIsInTrigger(TRIGGER._6_B_BELLS_THREE) then
		CollisionApply = 3
		PAnimSetActionNode("SCBell", 186.275, -71.1643, 46.4597, 1, "/Global/SCBELL/Idle/DoDamage", "Act/Props/SCBell.act")
		CreateThread("T_CollisionApply")
		SoundEmitterStop(186.275, -71.1643, 46.4597, "BELLSONE")
		bTrigger09 = true
	end
	if not bTrigger10 and PlayerIsInTrigger(TRIGGER._6_B_SCHOOLROOFTOP) then
		PlayerSetControl(0)
		GaryCanThrowStuff = false
		--print("===Current Stage 6 =====")
		BlipRemove(gGaryBlip)
		PedSetFlag(gGary, 107, false)
		SoundRemoveAllQueuedSpeech(gGary, true)
		PlayCutsceneWithLoad("6-BB", true, false, true, true)
		bGoToStage2 = true
		bTrigger10 = true
	end
end

function Stage2_Objectives()
	if not ScaffoldOneBroke then
		if PedGetHealth(gGary) / GaryHealth * 100 < 75 then
			GARY_ANGRY = true
		end
	elseif not ScaffoldTwoBroke and PedGetHealth(gGary) / GaryHealth * 100 < 50 then
		GARY_ANGRY = true
	end
	if not ScaffoldThreeBroke and PedGetHealth(gGary) / GaryHealth * 100 < 1 then
		PedSetActionNode(gPlayer, "/Global/6_B/AdjustGravity", "Act/Conv/6_B.act")
		PedSetActionNode(gGary, "/Global/6_B/AdjustGravity", "Act/Conv/6_B.act")
		bMissionPassed = true
	end
end

function F_ResetPAnims()
	PAnimReset("Scaffold", 178.173, -73.1613, 40.1403)
	PAnimReset("Scaffold", 178.173, -73.1613, 35.2763)
	PAnimReset("Scaffold", 178.173, -73.1613, 30.5194)
	PAnimReset("SCBell", 197.159, -75.7203, 46.4597)
	PAnimReset("SCBell2", 197.159, -73.4447, 46.4597)
	PAnimReset("SCBell2", 197.159, -71.1643, 46.4597)
	PAnimReset("SCBell", 191.725, -75.7203, 46.4597)
	PAnimReset("SCBell", 191.725, -73.4447, 46.4597)
	PAnimReset("SCBell2", 191.725, -71.1643, 46.4597)
	PAnimReset("SCBell2", 186.275, -75.7203, 46.4597)
	PAnimReset("SCBell", 186.275, -73.4447, 46.4597)
	PAnimReset("SCBell", 186.275, -71.1643, 46.4597)
	PAnimReset("WheelBrl", 183.545, -80.2706, 41.078)
	PAnimReset("WheelBrl", 204.582, -68.0396, 35.6995)
	One = true
	Two = true
	Three = true
end

function F_BellSwingScatter()
	PAnimSetActionNode("SCBell", 197.159, -75.7203, 46.4597, 1, "/Global/SCBELL/Idle/IdleAnimationChooser/animstart1", "Act/Props/SCBell.act")
	PAnimSetActionNode("SCBell2", 197.159, -73.4447, 46.4597, 1, "/Global/SCBELL/Idle/IdleAnimationChooser/animstart2", "Act/Props/SCBell.act")
	PAnimSetActionNode("SCBell2", 197.159, -71.1643, 46.4597, 1, "/Global/SCBELL/Idle/IdleAnimationChooser/animstart3", "Act/Props/SCBell.act")
	PAnimSetActionNode("SCBell", 191.725, -75.7203, 46.4597, 1, "/Global/SCBELL/Idle/IdleAnimationChooser/animstart4", "Act/Props/SCBell.act")
	PAnimSetActionNode("SCBell", 191.725, -73.4447, 46.4597, 1, "/Global/SCBELL/Idle/IdleAnimationChooser/animstart5", "Act/Props/SCBell.act")
	PAnimSetActionNode("SCBell2", 191.725, -71.1643, 46.4597, 1, "/Global/SCBELL/Idle/IdleAnimationChooser/animstart6", "Act/Props/SCBell.act")
	PAnimSetActionNode("SCBell2", 186.275, -75.7203, 46.4597, 1, "/Global/SCBELL/Idle/IdleAnimationChooser/animstart7", "Act/Props/SCBell.act")
	PAnimSetActionNode("SCBell", 186.275, -73.4447, 46.4597, 1, "/Global/SCBELL/Idle/IdleAnimationChooser/animstart8", "Act/Props/SCBell.act")
	PAnimSetActionNode("SCBell", 186.275, -71.1643, 46.4597, 1, "/Global/SCBELL/Idle/IdleAnimationChooser/animstart9", "Act/Props/SCBell.act")
end

function F_SetupRoof()
	F_SteamEffectSetup()
	gGary = PedCreatePoint(130, POINTLIST._6_B_GARYSTART)
	PedSetActionTree(gGary, "/Global/Nemesis", "Act/Anim/Nemesis.act")
	gGaryBlip = AddBlipForChar(gGary, 2, 0, 4)
	PedSetFlag(gGary, 107, true)
	PedIgnoreStimuli(gGary, true)
	PedSetPedToTypeAttitude(gGary, 13, 4)
	PedOverrideStat(gGary, 34, 0)
	PedSetMissionCritical(gGary, true, F_MissionCriticalGary, true)
	PedSetMinHealth(gGary, (PedGetHealth(gGary)))
	PedOverrideStat(gGary, 10, 50)
	F_CreatePops()
end

function F_BellSetup()
	GeometryInstance("SCBell", false, 197.159, -75.7203, 46.4597, false)
	GeometryInstance("SCBell2", false, 197.159, -73.4447, 46.4597, false)
	GeometryInstance("SCBell2", false, 197.159, -71.1643, 46.4597, false)
	GeometryInstance("SCBell", false, 191.725, -75.7203, 46.4597, false)
	GeometryInstance("SCBell", false, 191.725, -73.4447, 46.4597, false)
	GeometryInstance("SCBell2", false, 191.725, -71.1643, 46.4597, false)
	GeometryInstance("SCBell2", false, 186.275, -75.7203, 46.4597, false)
	GeometryInstance("SCBell", false, 186.275, -73.4447, 46.4597, false)
	GeometryInstance("SCBell", false, 186.275, -71.1643, 46.4597, false)
	GeometryInstance("WheelBrl", false, 183.545, -80.2706, 41.078, false)
	GeometryInstance("WheelBrl", false, 204.582, -68.0396, 35.6995, false)
end

function F_SteamEffectSetup()
	table.insert(effectTable, {
		id = EffectCreate("SteamSlow", 175.5, -62.8, 22.7)
	})
	table.insert(effectTable, {
		id = EffectCreate("SteamSlow", 166.4, -57.5, 22.7)
	})
	table.insert(effectTable, {
		id = EffectCreate("SteamSlow", 178.6, -83.4, 22.7)
	})
	table.insert(effectTable, {
		id = EffectCreate("SteamSlow", 166.1, -89.4, 22.7)
	})
	table.insert(effectTable, {
		id = EffectCreate("SteamSlow", 199.7, -57.2, 22.7)
	})
end

function F_EffectCleanup()
	for i, entry in effectTable do
		EffectKill(entry.id)
	end
end

function F_ScaffoldBreak()
	Break = Break + 1
end

function SetUpCamera(StageNum)
	if StageNum == 1 then
		CameraAllowChange(true)
		CameraSetXYZ(172.49997, -73.60599, 42, 173.49889, -73.59898, 41.95471)
		CameraLookAtPlayer(true, 1)
		CameraSetPath(PATH._6_B_FINAL_CAM1, true)
		CameraSetSpeed(30, 5, 5)
		CameraAllowChange(false)
	elseif StageNum == 2 then
		CameraAllowChange(true)
		CameraLookAtPlayer(false, 1)
		CameraSetPath(PATH._6_B_FINAL_CAM2, false)
		CameraSetSpeed(30, 5, 5)
		CameraAllowChange(false)
	elseif StageNum == 3 then
		CameraAllowChange(true)
		CameraLookAtPlayer(false, 1)
		CameraSetPath(PATH._6_B_FINAL_CAM3, false)
		CameraSetSpeed(30, 5, 5)
		CameraAllowChange(false)
	elseif StageNum == 4 then
		CameraAllowChange(true)
		CameraSetFOV(80)
		CameraSetWidescreen(true)
		CameraSetFOV(80)
		CameraSetXYZ(173.48853, -69.161736, 23.542883, 174.1904, -69.72885, 23.973589)
		CameraAllowChange(false)
	end
end

function F_GaryAngry()
	if GARY_ANGRY then
		return 1
	else
		return 0
	end
end

function F_DodgeCondition()
	if gGaryCanAvoid then
		--print("==Can Avoid!===")
		return 1
	else
		--print("===no avoid for you===")
		return 0
	end
end

function CB_GARYPATH03(PedId, PathId, NodeId)
	if NodeId == 9 then
		PedFaceObject(gGary, gPlayer, 3, 1, false)
	end
end

function F_CrashThroughRoofCutscene()
	while not PlayerIsInTrigger(TRIGGER._6_B_GLASS_TRIGGER) do
		--print("()xxxxx[:::::::::::::::> Waiting for player to hit glass trigger.")
		Wait(0)
	end
	--print("()xxxxx[:::::::::::::::> Done waiting.")
	SoundPlay2D("BIGWINDOW_BRK")
	Wait(50)
	SoundPlay2D("MEDWINDOW_BREAK")
	SoundPlay2D("BIGWINDOW_BRK")
	Wait(50)
	SoundPlay2D("MEDWINDOW_BREAK")
	Wait(50)
	SoundPlay2D("SMLWINDOW_BREAK")
	local x, y, z = 0, 0, 0
	x, y, z = GetPointFromPointList(POINTLIST._6_B_GLASSBREAK, 1)
	EffectCreate("GlassLRGshards", x, y, z)
	x, y, z = GetPointFromPointList(POINTLIST._6_B_GLASSBREAK, 2)
	EffectCreate("GlassLRGshards", x, y, z)
	x, y, z = GetPointFromPointList(POINTLIST._6_B_GLASSBREAK, 3)
	EffectCreate("GlassLRGshards", x, y, z)
	x, y, z = GetPointFromPointList(POINTLIST._6_B_GLASSBREAK, 4)
	EffectCreate("GlassLRGshards", x, y, z)
	Wait(500)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	CameraFade(1000, 0)
	Wait(1000)
	--print("()xxxxx[:::::::::::::::> what the fuck.")
end

function F_WhatScaffoldAreWeOn()
	if not ScaffoldOneBroke then
		return 0
	end
	return 1
end

function F_MissionCriticalGary()
	--print("()xxxxx[:::::::::::::::> [start] F_MissionCriticalGary()")
	GaryCanThrowStuff = false
	if PedIsValid(gGary) then
		PedSetActionTree(gGary, "/Global/Nemesis", "Act/Anim/Nemesis.act")
	end
	gMissionFailMessage = 1
	bMissionFailed = true
	--print("()xxxxx[:::::::::::::::> [finish] F_MissionCriticalGary()")
end

function F_CreatePops()
	pop1 = PickupCreatePoint(362, POINTLIST._6_B_POPPICKUP, 1, 0, "HealthBute")
	pop2 = PickupCreatePoint(362, POINTLIST._6_B_POPPICKUP, 2, 0, "HealthBute")
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

function F_StartAtStage2()
	OBJONE = MissionObjectiveAdd("6_B_MOBJ_01")
	CreateThread("T_CheckPlayerHealth")
	F_Stage2()
end

function T_GaryBlahBlah()
	local TalkOne = true
	local TalkTwo = true
	local TalkThree = true
	local TalkFour = true
	local TalkFive = true
	while mission_running do
		if TalkOne then
			if PlayerIsInTrigger(TRIGGER._6_B_GARY_TRIGGER_1) then
				SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 1, "large", false)
				F_WaitForSpeech(gGary)
				SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 2, "large", false)
				TalkOne = false
			end
		elseif TalkTwo then
			if PlayerIsInTrigger(TRIGGER._6_B_GARY_TRIGGER_2) then
				PedFaceObject(gGary, gPlayer, 3, 1, false)
				F_WaitForSpeech(gGary)
				SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 4, "large", false)
				F_WaitForSpeech(gGary)
				SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 6, "large", false)
				TalkTwo = false
			end
		elseif TalkThree then
			if PlayerIsInTrigger(TRIGGER._6_B_GARY_TRIGGER_4) then
				PedFaceObject(gGary, gPlayer, 3, 1, false)
				F_WaitForSpeech(gGary)
				SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 8, "large", false)
				F_WaitForSpeech(gGary)
				SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 10, "large", false)
				TalkThree = false
			end
		elseif TalkFour then
			if PlayerIsInTrigger(TRIGGER._6_B_GARY_TRIGGER_6) then
				F_WaitForSpeech(gGary)
				SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 11, "large", false)
				F_WaitForSpeech(gGary)
				SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 12, "large", false)
				TalkFour = false
			end
		elseif TalkFive and PlayerIsInTrigger(TRIGGER._6_B_BELLS_TWO) then
			PedFaceObject(gGary, gPlayer, 3, 1, false)
			F_WaitForSpeech(gGary)
			SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 13, "large", false)
			TalkFive = false
		end
		Wait(0)
	end
end

function T_CheckPlayerHealth()
	while mission_running do
		if F_PlayerIsDead() then
			SoundStopCurrentSpeechEvent(gGary)
			SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 20, "large", true, true)
			mission_running = false
			MinigameSetCompletion("M_FAIL", false)
			SoundPlayMissionEndMusic(false, 10)
			MissionFail(true, true, "6_B_FAIL_02")
		end
		Wait(0)
	end
end

function T_AngryHit()
	while mission_running do
		if GARY_ANGRY and DistanceBetweenPeds2D(gPlayer, gGary) <= 1 and (PedIsPlaying(gGary, "/Global/Nemesis/Default_KEY/Locomotion", true) or PedIsPlaying(gGary, "/Global/HitTree/Standing/PostHit", true)) and not PedIsPlaying(gPlayer, "/Global/HitTree/Standing/PostHit", true) then
			Wait(250)
			--print("==Hit the player==")
			PedSetActionNode(gGary, "/Global/Nemesis/Special/GarySpecialGrapple", "Act/Anim/Nemesis.act")
		end
		Wait(0)
	end
end

function T_CollisionApply()
	if CollisionApply == 1 then
		Wait(500)
		GeometryInstance("SCBell", false, 197.159, -75.7203, 46.4597, true)
	elseif CollisionApply == 2 then
		PAnimSetActionNode("SCBell", 191.725, -73.4447, 46.4597, 1, "/Global/SCBELL/Idle/DoDamage", "Act/Props/SCBell.act")
		Wait(250)
		GeometryInstance("SCBell", false, 191.725, -73.4447, 46.4597, true)
		Wait(250)
		GeometryInstance("SCBell", false, 191.725, -75.7203, 46.4597, true)
	elseif CollisionApply == 3 then
		PAnimSetActionNode("SCBell", 186.275, -73.4447, 46.4597, 1, "/Global/SCBELL/Idle/DoDamage", "Act/Props/SCBell.act")
		GeometryInstance("SCBell", false, 186.275, -73.4447, 46.4597, true)
		Wait(500)
		GeometryInstance("SCBell", false, 186.275, -71.1643, 46.4597, true)
	elseif CollisionApply == 4 then
		GeometryInstance("WheelBrl", false, 204.582, -68.0396, 35.6995, true)
	elseif CollisionApply == 5 then
		GeometryInstance("WheelBrl", false, 183.545, -80.2706, 41.078, true)
	end
end

function T_RoofCheck()
	while mission_running do
		if PlayerIsInTrigger(TRIGGER._6_B_OFFROOF) then
			--print("====Player Off RoofTop====")
			gMissionFailMessage = 3
			mission_running = false
			bMissionFailed = true
			break
		end
		Wait(0)
	end
end

function T_GaryUpdater()
	if stage == 0 then
		CreateThread("T_GaryThrowActions")
	elseif stage == 1 then
		--print("==Gary climb stage 1==")
		PedClimbLadder(gGary, POINTLIST._6_B_LADDERS, 1)
		PickupRemoveAll(311)
		while not PedIsPlaying(gGary, "/Global/Ladder/Ladder_Actions_PED", true) do
			Wait(0)
		end
		while PedIsPlaying(gGary, "/Global/Ladder/Ladder_Actions_PED", true) do
			Wait(0)
		end
		PedSetEntityFlag(gGary, 56, true)
		--print("===set ignore projectiles back to true===")
		PedFollowPath(gGary, PATH._6_B_MINIPATH, 0, 0)
		Wait(600)
		PedFaceObject(gGary, gPlayer, 3, 1, false)
		PedSetInvulnerable(gGary, false)
	elseif stage == 2 then
		--print(" Gary climb stage 2==")
		PedStop(gGary)
		PedClearObjectives(gGary)
		PedFollowPath(gGary, PATH._6_B_GARYPATH01, 0, 1)
		while not PedIsInTrigger(gGary, TRIGGER._6_B_GARY_THROW_1) do
			Wait(0)
		end
		PedSetInvulnerable(gGary, false)
		gGaryCanAvoid = false
		GaryCanThrowStuff = true
		CreateThread("T_GaryThrowActions")
	elseif stage == 3 then
		--print(" Gary climb stage 3==")
		PedStop(gGary)
		PedClearObjectives(gGary)
		PedFollowPath(gGary, PATH._6_B_GARYPATH02, 0, 1)
		while not PedIsInTrigger(gGary, TRIGGER._6_B_GARY_THROW_2) do
			--print(" Waiting stage 3==")
			if PedIsInTrigger(gGary, TRIGGER._6_B_GARY_TRIGGER_4) then
				--print("==Warping...")
				PedSetPosPoint(gGary, POINTLIST._6_B_WARP_POINT)
			end
			Wait(0)
		end
		--print(" Done==")
		PedSetInvulnerable(gGary, false)
		gGaryCanAvoid = false
		GaryCanThrowStuff = true
		CreateThread("T_GaryThrowActions")
	elseif stage == 4 then
		--print(" Gary climb stage 4==")
		PedStop(gGary)
		PedClearObjectives(gGary)
		PickupRemoveAll(311)
		PedMoveToPoint(gGary, 0, POINTLIST._6_B_LADDERS, 2)
		Wait(500)
		PedClimbLadder(gGary, POINTLIST._6_B_LADDERS, 2)
		while not PedIsPlaying(gGary, "/Global/Ladder/Ladder_Actions_PED", true) do
			Wait(0)
		end
		while PedIsPlaying(gGary, "/Global/Ladder/Ladder_Actions_PED", true) do
			Wait(0)
		end
		PedSetEntityFlag(gGary, 56, true)
		--print("===set ignore projectiles back to true===")
		PedSetInvulnerable(gGary, false)
		PedFaceObject(gGary, gPlayer, 3, 1, false)
		PedStop(gGary)
		PedClearObjectives(gGary)
		PedFollowPath(gGary, PATH._6_B_MINIPATH2, 0, 2)
	elseif stage == 5 then
		--print(" Gary climb stage 5==")
		PedStop(gGary)
		PedClearObjectives(gGary)
		PedFollowPath(gGary, PATH._6_B_GARYPATH03, 0, 2, CB_GARYPATH03)
	end
end

function T_GaryThrowActions()
	PedStop(gGary)
	PedClearObjectives(gGary)
	PedFaceObject(gGary, gPlayer, 3, 0, true)
	PedSetEntityFlag(gGary, 56, false)
	while GaryCanThrowStuff do
		Wait(100)
		if not GaryCanThrowStuff then
			break
		end
		PedLockTarget(gGary, gPlayer, 3)
		PedFaceObjectNow(gGary, gPlayer, 3)
		Wait(100)
		if not GaryCanThrowStuff then
			break
		end
		if math.random(1, 100) >= 50 and not SoundSpeechPlaying(gGary) then
			SoundPlayScriptedSpeechEvent(gGary, "M_6_B", 15, "large", false)
		end
		PedSetActionTree(gGary, "/Global/Nemesis/Special/Throw", "Act/Anim/Nemesis.act")
		while not PedIsPlaying(gGary, "/Global/Nemesis/Special/Throw/GetWeapon/Release/Empty", true) do
			Wait(0)
		end
		if not GaryCanThrowStuff then
			break
		end
		PedSetActionTree(gGary, "/Global/Nemesis", "Act/Anim/Nemesis.act")
		PedLockTarget(gGary, gPlayer, -1)
		PedSetActionNode(gGary, "/Global/Nemesis/Special/Crouch/Crouch", "Act/Anim/Nemesis.act")
		Wait(5000)
	end
end

function T_ScaffoldBreak()
	while Break <= 0 do
		Wait(0)
	end
	--print("==break scaffold one==")
	while not PAnimIsDestroyed("Scaffold", 178.173, -73.1613, 40.1403) do
		--print("====Waiting for Scaffold Break====")
		PAnimApplyDamage("Scaffold", 178.173, -73.1613, 40.1403, 251)
		Wait(10)
	end
	SoundPlay2D("ScaffoldCrash")
	SetUpCamera(2)
	ScaffoldOneBroke = true
	GARY_ANGRY = false
	while Break <= 1 do
		Wait(0)
	end
	while not PAnimIsDestroyed("Scaffold", 178.173, -73.1613, 35.2763) do
		--print("====Waiting for Scaffold Break2====")
		PAnimApplyDamage("Scaffold", 178.173, -73.1613, 35.2763, 251)
		Wait(10)
	end
	SoundPlay2D("ScaffoldCrash")
	SetUpCamera(3)
	ScaffoldTwoBroke = true
	GARY_ANGRY = false
	while Break <= 2 do
		Wait(0)
	end
	while not PAnimIsDestroyed("Scaffold", 178.173, -73.1613, 30.5194) do
		--print("====Waiting for Scaffold Break3====")
		PAnimApplyDamage("Scaffold", 178.173, -73.1613, 30.5194, 251)
		Wait(10)
	end
	PedSetInvulnerable(gPlayer, true)
	SoundFadeWithCamera(false)
	SetUpCamera(4)
	SoundPlay2D("ScaffoldCrash")
	ScaffoldThreeBroke = true
	GARY_ANGRY = false
	while Break <= 3 do
		Wait(0)
	end
end

function T_MissionComplete()
	Wait(5000)
	bMissionPassed = true
end

function T_MonitorPlayerFirstLadder()
	--print("()xxxxx[:::::::::::::::> [start] T_MonitorPlayerFirstLadder()")
	while bMonitorPlayerOnLadder do
		if not PedIsPlaying(gPlayer, "/Global/Ladder/Ladder_Actions", true) then
			CameraReset()
			CameraReturnToPlayer()
			bHadToResetPlayersCamera = true
			break
		end
		Wait(0)
	end
	collectgarbage()
	--print("()xxxxx[:::::::::::::::> [finish] T_MonitorPlayerFirstLadder()")
end

function T_MonitorPlayerSecondLadder()
	--print("()xxxxx[:::::::::::::::> [start] T_MonitorPlayerSecondLadder()")
	while bMonitorPlayerOnLadder do
		if not PedIsPlaying(gPlayer, "/Global/Ladder/Ladder_Actions", true) then
			CameraReset()
			CameraReturnToPlayer()
			bHadToResetPlayersCamera = true
			break
		end
		Wait(0)
	end
	collectgarbage()
	--print("()xxxxx[:::::::::::::::> [finish] T_MonitorPlayerSecondLadder()")
end

function F_SecondStage()
	if shared.b602reachedScaffolds == true then
		return 1
	end
	return 0
end
