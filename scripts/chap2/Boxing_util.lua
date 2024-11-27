ImportScript("Library/LibPlayer.lua")
local mission_completed = false
local boxer
local round_length = 40000
local rewardMoney = 2000
local player_knockout = false
local boxing_setup = false
local crowd_enable = false
local index_crowd01, entity_crowd01, index_crowd02, entity_crowd02, index_crowd03, entity_crowd03, index_crowd04, entity_crowd04, index_crowd05, entity_crowd05, index_BlkFade, entity_BlkFade
local gPlayerWins = false
local gOpponentWins = false
local gPlayerHealth, gOpponentHealth
local gFirstStun = true
local gPlayerKnockDowns = 1
local P_ENTRY_HEALTH
local OPPONENT_STUNNED = false
local HOLD_ON_A_SEC = false
local round_finished = false
local CrowdCheerThread
local gMusicToPlay = "MS_BoxingReg.rsm"
local opponents = {
	{
		name = "2_09_01",
		model = 133,
		model2 = 172,
		model3 = 243,
		model2n = "PR2nd_Bif_OBOX_D1",
		model3n = "PR2nd_Bif_OBOX_D2"
	},
	{
		name = "2_R11_Chad_Name",
		model = 117,
		model2 = 241,
		model3 = 242,
		model2n = "PRH2A_Chad_OBOX_D1",
		model3n = "PRH2A_Chad_OBOX_D2"
	},
	{
		name = "2_R11_Justin_Name",
		model = 118,
		model2 = 244,
		model3 = 245,
		model2n = "PRH3_Justin_OBOX_D1",
		model3n = "PRH3_Justin_OBOX_D2"
	},
	{
		name = "2_R11_Parker_Name",
		model = 119,
		model2 = 246,
		model3 = 247,
		model2n = "PRH3a_Prkr_OBOX_D1",
		model3n = "PRH3a_Prkr_OBOX_D2"
	},
	{
		name = "2_R11_Bryce_Name",
		model = 36,
		model2 = 239,
		model3 = 240,
		model2n = "PRH2_Bryce_OBOX_D1",
		model3n = "PRH2_Bryce_OBOX_D2"
	}
}

function BoxingSetBif()
	shared.gBoxingOpponent = 1
	gBoxingAgainstBif = true
	gMusicToPlay = "MS_BoxingBossFight.rsm"
	return 0
end

function BoxingSetRandom()
	--print("==random++")
	shared.gBoxingOpponent = math.random(2, 5)
	gIsRandom = true
	return 0
end

function BoxingSetOpponent(opNo)
	shared.gBoxingOpponent = opNo
end

function BoxingSetChad()
	shared.gBoxingOpponent = 2
	return 0
end

function BoxingSetJustin()
	shared.gBoxingOpponent = 3
	return 0
end

function BoxingSetParker()
	shared.gBoxingOpponent = 4
	return 0
end

function BoxingSetBryce()
	shared.gBoxingOpponent = 5
	return 0
end

function SetPlayerIsKnockout(knockout)
	if knockout == 0 then
		--print("Player RECOVERED")
		CameraAllowChange(true)
		CameraSetShot(9, "BoxingCam", true)
		CameraAllowChange(false)
		CameraAllowScriptedChange(true)
		PedSetActionNode(boxer, "/Global/P_Bif", "Act/Anim/P_Bif.act")
		player_knockout = false
		MissionTimerPause(false)
	else
		--print("Player KOD !")
		SoundPlayScriptedSpeechEvent_2D("M_2_09", 2)
		PedSetActionNode(boxer, "/Global/Ambient/MissionSpec/BoxingCheer", "Act/Anim/Ambient.act")
		gPlayerKnockDowns = gPlayerKnockDowns + 1
		player_knockout = true
		MissionTimerPause(true)
	end
end

function IsPlayerKO()
	return player_knockout
end

function CreateBoxer()
	boxer = PedCreatePoint(opponents[shared.gBoxingOpponent].model, POINTLIST._Boxing_EnemyStart)
	PedSetActionTree(boxer, "/Global/P_Bif", "Act/Anim/P_Bif.act")
	PedSetFightingSystem(boxer, 1)
	PedSetAlwaysStrafe(boxer, true)
	PedSetCombatZoneMask(boxer, true, false, false)
	PedOverrideStat(boxer, 62, 0)
	if shared.gBoxingOpponent == 2 then
		--print("==stat setting for chad==")
	elseif shared.gBoxingOpponent == 3 then
		--print("==stat setting for justin==")
	elseif shared.gBoxingOpponent == 4 then
		--print("==stat setting for parker==")
	elseif shared.gBoxingOpponent == 5 then
		--print("==stat setting for Bryce==")
	end
	PedSetPedToTypeAttitude(boxer, 13, 4)
	--print("[RAUL] BOXER INIT --- HEALTH - " .. PedGetMaxHealth(boxer))
end

function RoundAdvance()
	HOLD_ON_A_SEC = false
	PLAYER_CAN_GO_DOWN = true
	PedSetFightingSystem(gPlayer, 1)
	PedSetInvulnerable(gPlayer, false)
	PedSetInvulnerable(boxer, false)
	local healthInc = PedGetMaxHealth(gPlayer) * 0.24
	local playerhealthcheck = PedGetHealth(gPlayer) / PedGetMaxHealth(gPlayer) * 100
	if PedGetHealth(gPlayer) < PedGetMaxHealth(gPlayer) then
		PedSetHealth(gPlayer, PedGetHealth(gPlayer) + healthInc)
	end
	PedSetPosPoint(gPlayer, POINTLIST._BOXING_PLAYERCORNER)
	if shared.gBoxingOpponent == 1 or shared.gBoxingOpponent == 69 then
		healthInc = PedGetMaxHealth(boxer) * 0.23
	else
		healthInc = PedGetMaxHealth(boxer) * 0.1
	end
	if PedGetHealth(boxer) < PedGetMaxHealth(boxer) then
		PedSetHealth(boxer, PedGetHealth(boxer) + healthInc)
	end
	CameraSetShot(9, "BoxingCam", false)
	CameraAllowScriptedChange(true)
	CameraAllowChange(false)
	PedStop(boxer)
	PedClearObjectives(boxer)
	PedSetPosPoint(boxer, POINTLIST._BOXING_ENEMYCORNER)
	PlayerIgnoreTargeting(false)
	PedLockTarget(gPlayer, boxer)
	PedFaceObject(gPlayer, boxer, 2, 1)
	PedFaceObject(boxer, gPlayer, 3, 0, false)
	CameraReset()
end

function PlayerSetup()
	PedSetWeaponNow(gPlayer, -1, 0)
	L_PlayerClothingBackup()
	ClothingSetPlayerOutfit("Boxing")
	ClothingBuildPlayer()
	P_ENTRY_HEALTH = PlayerGetHealth()
	if P_ENTRY_HEALTH < PedGetMaxHealth(gPlayer) then
		PlayerSetHealth(200)
	end
	PedSetPosPoint(gPlayer, POINTLIST._BOXING_PLAYERSTART)
	PedSetFightingSystem(gPlayer, 1)
end

function PedMakeCheap(ped, isPinky)
	PedSetInvulnerable(ped, true)
	PedIgnoreAttacks(ped, true)
	PedIgnoreStimuli(ped, true)
	PedMakeTargetable(ped, false)
	PedSetStationary(ped, true)
	PedSetCheap(ped, true)
	PedClearAllWeapons(ped)
	if not isPinky then
		PedSetTaskNode(ped, "/Global/AI/ScriptedAI/CheeringAINode", "Act/AI/AI.act")
	end
end

function BoxingMissionSetup(crowd)
	crowd_enable = crowd
	LoadAnimationGroup("Boxing")
	LoadAnimationGroup("MINI_React")
	LoadActionTree("Act/Anim/BoxingPlayer.act")
	LoadActionTree("Act/AI/AI_BOXER.act")
	SoundLoadBank("Mission\\2_09.bnk")
	index_BlkFade, entity_BlkFade = CreatePersistentEntity("BX_BlkFade", -712.038, 377.699, 299.063, 0, 27)
	SoundEnableInteractiveMusic(false)
	PauseGameClock()
	if crowd_enable then
	end
	StatAddToInt(180)
	gPrepModels = {
		38,
		32,
		34,
		40,
		35,
		30,
		31
	}
	LoadModels(gPrepModels)
	LoadModels({
		opponents[shared.gBoxingOpponent].model,
		opponents[shared.gBoxingOpponent].model2,
		opponents[shared.gBoxingOpponent].model3
	})
	gPrepIds = {}
	shared.gDisableBoxingMask = false
	PlayerSetControl(0)
	DATLoad("Boxing.DAT", 2)
	DATInit()
	AreaTransitionPoint(27, POINTLIST._BOXING_PLAYERSTART, 1, true)
	for i, pedModel in gPrepModels do
		if shared.gBoxingOpponent ~= i then
			gPrepIds[i] = PedCreatePoint(pedModel, POINTLIST._BOXING_CROWD, i)
			if pedModel ~= 38 then
				PedMakeCheap(gPrepIds[i])
			else
				PedMakeCheap(gPrepIds[i], true)
			end
		else
			gPrepIds[i] = false
		end
	end
	ToggleHUDComponentVisibility(4, true)
	ToggleHUDComponentVisibility(11, false)
	ToggleHUDComponentVisibility(0, false)
	ToggleHUDComponentVisibility(20, false)
	CreateBoxer()
	PlayerSetup()
	PlayerWeaponHudLock(true)
	PedLockTarget(gPlayer, boxer)
	PedLockTarget(boxer, gPlayer)
	PlayerIgnoreTargeting(true)
	PedShowHealthBar(boxer, true, opponents[shared.gBoxingOpponent].name, true)
	PedSetAIButes("Boxing")
	PedFaceObject(gPlayer, boxer, 2, 1)
	HUDSetFightStyle()
	boxing_setup = true
	CameraSetPath(PATH._BOXING_INTROCAM, true)
	CameraSetSpeed(4.8, 4.4, 5.4)
	CameraLookAtPlayer(true, 1)
	CameraSetWidescreen(true)
	CameraFade(-1, 1)
	SoundPlayStream(gMusicToPlay, 0.7)
end

function IsEnemeyKO()
	if PedIsDead(boxer) or gPlayerWins then
		MissionTimerPause(true)
		--print("===enemy is ko, turn stuggle off====")
		ToggleHUDComponentVisibility(17, false)
		PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/BoxingCheer", "Act/Anim/Ambient.act")
		mission_completed = true
		if not gPlayerWins then
			TextPrint("BOXING_03", 3, 1)
			Wait(2000)
		end
		F_EndNIS()
		CameraFade(-1, 0)
		Wait(FADE_OUT_TIME)
		if gBoxingAgainstBif then
			CameraAllowScriptedChange(false)
			CameraAllowChange(true)
			CameraReturnToPlayer()
			TextPrint("MEN_BLANK", 1, 3)
			if index_BlkFade then
				DeletePersistentEntity(index_BlkFade, entity_BlkFade)
				index_BlkFade = nil
				entity_BlkFade = nil
			end
			PlayCutsceneWithLoad("2-B", true)
		end
		CameraSetWidescreen(false)
		PlayerSetControl(0)
		ManagedPlayerSetPosPoint(POINTLIST._BOXING_PLAYERSTART)
		gPlayerWins = true
		StatAddToInt(181)
		MissionSucceed(true, false, false)
		return true
	else
		return false
	end
end

function BoxingMissionCleanup()
	mission_completed = true
	round_finished = true
	if boxing_setup == true then
		TextPrint("MEN_BLANK", 1, 3)
		PlayerWeaponHudLock(false)
		PedSetFightingSystem(gPlayer, 0)
		UnpauseGameClock()
		if shared.gBoxingOpponent == 69 then
			--print("==Bif boxer==")
			if not gPlayerWins then
				AreaTransitionPoint(0, POINTLIST._BOXING_END_2_09, nil, true)
				PedSetPosPoint(gPlayer, POINTLIST._BOXING_END_2_09)
			end
		else
			--print("==Regular boxer==")
			PedSetPosPoint(gPlayer, POINTLIST._BOXING_FINISHEDBOXING)
		end
		DATUnload(2)
		PlayerSetControl(1)
		PlayerIgnoreTargeting(false)
		PedLockTarget(gPlayer, -1)
		SoundEnableInteractiveMusic(true)
		SoundFadeoutStream()
		CameraAllowScriptedChange(false)
		CameraAllowChange(true)
		CameraReturnToPlayer()
		PedHideHealthBar()
		PedSetAlpha(gPlayer, 255, false)
		PedSetAIButes("Default")
		if PlayerGetHealth() < PedGetMaxHealth(gPlayer) then
			PlayerSetHealth(PedGetMaxHealth(gPlayer))
		end
		ToggleHUDComponentVisibility(11, true)
		ToggleHUDComponentVisibility(20, true)
		ToggleHUDComponentVisibility(0, true)
		ToggleHUDComponentVisibility(21, false)
		if index_BlkFade then
			DeletePersistentEntity(index_BlkFade, entity_BlkFade)
		end
		if crowd_enable then
		end
		shared.gDisableBoxingMask = true
		L_PlayerClothingRestore()
		PedSetActionNode(gPlayer, "/Global/Player", "Act/Player.act")
		LockFPS30(true)
		UnLoadAnimationGroup("Boxing")
		UnLoadAnimationGroup("MINI_React")
		PedSetActionTree(gPlayer, "", "")
		PedClearObjectives(gPlayer)
		--print("===cleanup struggle button off===")
		ToggleHUDComponentVisibility(17, false)
		CameraSetWidescreen(false)
		if shared.PrepVendettaRunning then
			if gPlayerWins then
				shared.BoxingSuccess = 1
			else
				shared.BoxingSuccess = 0
			end
		end
	end
end

function MissionFailBoxing()
	WeatherForceSnow(false)
	WeatherRelease()
	TextPrint("MEN_BLANK", 1, 3)
	SoundPlayMissionEndMusic(false, 10)
	MissionFail(true, true, "M_FAIL_DEAD")
end

function BoxingMissionControl()
	local round_current = 1
	local round_time
	gPlayerHealth = PedGetHealth(gPlayer)
	gOpponentHealth = PedGetHealth(boxer)
	PedSetActionTree(gPlayer, "/Global/BoxingPlayer", "Act/Anim/BoxingPlayer.act")
	PedSetFightingSystem(gPlayer, 1)
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	WaitSkippable(5500)
	CameraFade(-1, 0)
	Wait(FADE_OUT_TIME)
	CameraSetWidescreen(false)
	PedSetAlpha(gPlayer, 180, true)
	CameraSetShot(9, "BoxingCam", true)
	CameraAllowChange(false)
	CameraAllowScriptedChange(true)
	Wait(200)
	CameraFade(200, 1)
	Wait(200)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	local gBoxerHealth = PedGetHealth(boxer)
	local gDamagedStage = 0
	while mission_completed == false do
		local timerText = "BOXING_R"
		if round_current < 10 then
			timerText = timerText .. "0" .. round_current
		else
			timerText = timerText .. round_current
		end
		MinigameSetAnnouncement(timerText, true)
		Wait(2000)
		MinigameSetAnnouncement("MEN_BLANK", true)
		Wait(500)
		MinigameSetAnnouncement("BOXING_07", true)
		Wait(500)
		SoundPlay2D("Fite_Bell")
		Wait(1000)
		CreateThread("T_BifCrowdCheer")
		if shared.gBoxingOpponent == 1 then
			shared.gBoxingOpponent = 69
		end
		PedSetPedToTypeAttitude(boxer, 13, 0)
		PlayerSetControl(1)
		MissionTimerStart(round_length / 1000)
		ObjTimerSetText(timerText)
		PedIgnoreAttacks(boxer, false)
		PedSetAITree(boxer, "/Global/AI_BOXER", "Act/AI/AI_BOXER.act")
		PedAttack(boxer, gPlayer, 3)
		round_time = GetTimer() + round_length
		while round_finished == false do
			TextPrint("BOXING_INST", 50, 3)
			if gDamagedStage then
				gBoxerHealth = PedGetHealth(boxer)
				boxerIndex = shared.gBoxingOpponent
				if boxerIndex == 69 then
					boxerIndex = 1
				end
				if gDamagedStage == 0 and gBoxerHealth < gOpponentHealth / 2 then
					gDamagedStage = 1
					PedSwapModel(boxer, opponents[boxerIndex].model2n)
				elseif gDamagedStage == 1 and gBoxerHealth < gOpponentHealth / 4 then
					PedSwapModel(boxer, opponents[boxerIndex].model3n)
					gDamagedStage = false
				end
			end
			if not OPPONENT_STUNNED and PedIsPlaying(boxer, "/Global/HitTree/Standing/PostHit/Standing/Dead/BoxingStun/StunControl", true) then
				MissionTimerPause(true)
				--print("=========struggle on============")
				TextPrint("BOXING_09", 10, 1)
				OPPONENT_STUNNED = true
				gCurrentHealth = PlayerGetHealth()
				gMaxHealth = PedGetMaxHealth(gPlayer)
				if gFirstStun then
					Wait(1500)
					gFirstStun = false
				end
			end
			if OPPONENT_STUNNED then
				if PlayerGetHealth() < gMaxHealth then
					PlayerSetHealth(PlayerGetHealth() + 1)
				end
				if not PedIsPlaying(boxer, "/Global/HitTree/Standing/PostHit/Standing/Dead/BoxingStun/StunControl", true) then
					--print("=========struggle off============")
					TextPrintString("", 1, 1)
					OPPONENT_STUNNED = false
					MissionTimerPause(false)
				end
			end
			if IsEnemeyKO() then
				break
			end
			if round_time < GetTimer() and not IsPlayerKO() then
				while PedIsPlaying(boxer, "/Global/HitTree/Standing/PostHit/Standing/Dead/BoxingStun/StunControl", true) do
					--print("==Opponent on Ground....==")
					Wait(0)
				end
				if not HOLD_ON_A_SEC then
					PedSetInvulnerable(gPlayer, true)
					PedSetInvulnerable(boxer, true)
					Wait(500)
					PlayerSetControl(0)
					PedLockTarget(gPlayer, -1)
					PedSetFightingSystem(gPlayer, 0)
					PlayerIgnoreTargeting(true)
					CameraAllowScriptedChange(false)
					CameraAllowChange(true)
					PedSetAlpha(gPlayer, 255, true)
					if PlayerIsInTrigger(TRIGGER._BOXHALFTHERING) then
						CameraSetXYZ(-708.1398, 373.82175, 295.69522, -708.85803, 374.51727, 295.70963)
					else
						CameraSetXYZ(-715.7916, 381.57556, 295.49298, -715.0454, 380.90988, 295.49408)
					end
					local coinflip = math.random(1, 2)
					if coinflip == 1 then
						--print("==look at player== Coinflip ==" .. coinflip)
						CameraLookAtPlayer(true)
						coinflip = nil
					else
						--print("==look at boxer== Coinflip ==" .. coinflip)
						CameraLookAtObject(boxer, 2, true)
						coinflip = nil
					end
					round_finished = true
					MissionTimerStop()
					PedIgnoreAttacks(boxer, true)
					PedStop(boxer)
					PedStop(gPlayer)
					PedClearObjectives(boxer)
					PedClearObjectives(gPlayer)
					PlayerSetControl(0)
					SoundPlay2D("Fite_Bell")
					TextPrint("BOXING_02", 2, 1)
					Wait(500)
					if not PlayerIsInTrigger(TRIGGER._CORNER_CHECK1) and not PlayerIsInTrigger(TRIGGER._CORNER_CHECK3) then
						PedLockTarget(gPlayer, -1)
						PedFaceXYZ(gPlayer, -715.931, 373.532, 295.225, 0)
						PedMoveToPoint(boxer, 0, POINTLIST._BOXING_ENEMYCORNER)
						PedMoveToPoint(gPlayer, 0, POINTLIST._BOXING_PLAYERCORNER)
					end
					Wait(2000)
					if round_current == 12 then
						if PedGetHealth(gPlayer) / gPlayerHealth * 100 > PedGetHealth(boxer) / gOpponentHealth * 100 then
							gPlayerWins = true
							PedClearObjectives(boxer)
							PedIgnoreAttacks(boxer, true)
							mission_completed = true
						else
							gOpponentWins = true
							SetPlayerIsKnockout(1)
							SoundPlayMissionEndMusic(false, 10)
							Wait(3000)
							mission_completed = true
							WeatherForceSnow(false)
							WeatherRelease()
							MissionFail(true, true, "PUN_02")
						end
					end
				end
				if IsEnemeyKO() then
					break
				end
				if HOLD_ON_A_SEC then
					--print("===Switching holding flag back to false.======")
					HOLD_ON_A_SEC = false
				end
			end
			Wait(0)
		end
		if mission_completed == false then
			SoundFadeWithCamera(false)
			MusicFadeWithCamera(false)
			CameraFade(1000, 0)
			Wait(1000)
			PedSetActionNode(boxer, "/Global/P_Bif", "Act/Anim/P_Bif.act")
			if IsPlayerKO() then
				PedSetActionNode(gPlayer, "/Global/HitTree/KnockOuts/BoxingSpecialKO/BoxingSpeicalKO/Knockout/KnockoutRecover", "Act/HitTree.act")
			end
			RoundAdvance()
			round_current = round_current + 1
			round_finished = false
			PedClearObjectives(gPlayer)
			PedClearObjectives(boxer)
			PedSetAlpha(gPlayer, 180, true)
			CameraFade(1000, 1)
			Wait(1000)
			SoundFadeWithCamera(true)
			MusicFadeWithCamera(true)
		end
	end
end

function T_BifCrowdCheer()
	local time = GetTimer()
	local bBiffFight = shared.gBoxingOpponent == 1 or shared.gBoxingOpponent == 69
	while mission_completed == false do
		if not OPPONENT_STUNNED and GetTimer() - time > 7500 then
			if IsPlayerKO() then
				SoundPlayScriptedSpeechEvent_2D("M_2_09", 2)
			elseif PedIsHit(gPlayer, 2, 1500) then
				--print("===========Player is hit, talk=======")
				if bBiffFight and math.random(1, 100) < 45 then
					SoundPlayScriptedSpeechEvent_2D("M_2_09", 30)
				else
					SoundPlayScriptedSpeechEvent_2D("M_2_09", 3)
				end
			elseif PedIsHit(boxer, 2, 1500) then
				--print("=======boxerdude is hit, talk=========")
				SoundPlayScriptedSpeechEvent_2D("M_2_09", 4)
			else
				--print("=======nobody is hit, talk======")
				if bBiffFight and math.random(1, 100) < 45 then
					SoundPlayScriptedSpeechEvent_2D("M_2_09", 10)
				else
					SoundPlayScriptedSpeechEvent_2D("M_2_09", 1)
				end
			end
			time = GetTimer()
		end
		Wait(0)
	end
end

function F_CheckImpossibleGetUp()
	if 5 <= gPlayerKnockDowns then
		--print("==impossible struggle!==")
		return 1
	else
		return 0
	end
end

function F_CheckHardGetUp()
	if 3 <= gPlayerKnockDowns then
		--print("==hard struggle!==")
		return 1
	else
		return 0
	end
end

function F_CheckMediumGetUp()
	if gPlayerKnockDowns == 2 then
		--print("==medium struggle!==")
		return 1
	else
		return 0
	end
end

function F_IsOpponentStunned()
	if OPPONENT_STUNNED then
		return 1
	else
		return 0
	end
end

function F_HoldUpHomeBoy()
	HOLD_ON_A_SEC = true
end

function F_DamageMultiplier()
	--print("++INCREASE PLAYER DAMAGE++")
	--print("+++++++Before Multiplier ==" .. PedGetDamageGivenMultiplier(gPlayer, 2))
	if PedGetDamageGivenMultiplier(gPlayer, 2) <= 1 then
		PedSetDamageGivenMultiplier(gPlayer, 2, 1.075)
		gIsRandom = false
		--print("+++++++After Multiplier1 ==" .. PedGetDamageGivenMultiplier(gPlayer, 2))
	elseif PedGetDamageGivenMultiplier(gPlayer, 2) <= 1.075 then
		PedSetDamageGivenMultiplier(gPlayer, 2, 1.15)
		gIsRandom = false
		--print("+++++++After Multiplier2 ==" .. PedGetDamageGivenMultiplier(gPlayer, 2))
	elseif PedGetDamageGivenMultiplier(gPlayer, 2) <= 1.15 then
		PedSetDamageGivenMultiplier(gPlayer, 2, 1.225)
		gIsRandom = false
		--print("+++++++After Multiplier3 ==" .. PedGetDamageGivenMultiplier(gPlayer, 2))
	elseif PedGetDamageGivenMultiplier(gPlayer, 2) <= 1.225 then
		PedSetDamageGivenMultiplier(gPlayer, 2, 1.3)
		gIsRandom = false
		--print("+++++++After Multiplier4 ==" .. PedGetDamageGivenMultiplier(gPlayer, 2))
	end
end

function F_EndNIS()
	if not gBoxingAgainstBif then
		SoundFadeWithCamera(false)
		MusicFadeWithCamera(false)
		CameraFade(-1, 0)
		Wait(FADE_OUT_TIME + 1000)
		TextPrint("MEN_BLANK", 1, 3)
		CameraSetWidescreen(true)
		if PedIsValid(boxer) then
			PedDelete(boxer)
		end
		local x, y, z = GetPointList(POINTLIST._BOXING_PLAYERSTART)
		PlayerSetPosSimple(x, y, z)
		PlayerFaceHeadingNow(-53.639343)
		CameraAllowScriptedChange(false)
		CameraAllowChange(true)
		CameraReturnToPlayer()
		CameraSetWidescreen(true)
		CameraLookAtXYZ(-712.10333, 377.20825, 296.33905, true)
		CameraSetXYZ(-710.29865, 378.75714, 296.04504, -712.10333, 377.20825, 296.33905)
		PedSetAlpha(gPlayer, 255, false)
		if not shared.PrepVendettaRunning then
			F_DamageMultiplier()
			if not gIsRandom then
				PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/BoxingCheer/BoxingEnding", "Act/Anim/Ambient.act")
				CameraFade(-1, 1)
				MinigameSetCompletion("BOXING_04", true, 0, "BOXING_10")
				while PedIsPlaying(gPlayer, "/Global/Ambient/MissionSpec/BoxingCheer/BoxingEnding", true) do
					Wait(0)
				end
				Wait(3000)
			else
				PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/BoxingCheer", "Act/Anim/Ambient.act")
				CameraFade(-1, 1)
				MinigameSetCompletion("BOXING_04", true, rewardMoney)
				StatAddToInt(182, rewardMoney)
				Wait(3000)
			end
		else
			PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/BoxingCheer", "Act/Anim/Ambient.act")
			CameraFade(-1, 1)
			MinigameSetCompletion("BOXING_04", true)
			Wait(2000)
			MissionDontFadeInAfterCompetion()
		end
		SoundFadeWithCamera(true)
		MusicFadeWithCamera(true)
	end
end
