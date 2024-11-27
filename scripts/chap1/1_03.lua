ImportScript("Library/LibTable.lua")
ImportScript("Library/LibTriggerNew.lua")
local bMissionRunning = true
local bDavisFightStart = false
local bDavisDefeated = false
local gFailMessage, bDavisCanAttackNow
local runner_attacking = false
local runner_Hiding = false
local bDoneFleeGarage = false
local bDoneFleeFountain = false
local gDavis, gCSBully, attack_waves, tblWeapon
local tblDoors = {}
local bDoorOpened
local bMissionPassed = false
local bDoneClimbing = false
local bOpenAllHack = true
local bLadderCreated = false
local bBattleOver = false
local ARROW_OFFSET_Z = 1.7
local MAX_FAIL_DISTANCE_LIMIT = 35
local MAX_FAILURE_DELAY = 20000
local DISTANCE_COUNTDOWN_MAX = 20
local gDistanceCountDown = DISTANCE_COUNTDOWN_MAX
local bFailedToKeepUp = false

function WaveInit()
	attack_waves = {
		barrelWave = {
			trigger = TRIGGER._1_03_FIGHT3,
			attackers = {
				{
					model = 85,
					spawn = POINTLIST._1_03_BULLY3,
					id = nil,
					guard = false,
					dropHealth = false,
					speech = nil
				}
			},
			OnAttack = Wave_FightFromBehindBarrel,
			Action = "/Global/1_03/animations/Hiding/CrouchHide",
			EndAction = "/Global/1_03/animations/Hiding/endHide",
			processed = false,
			door = TRIGGER._SCGRDOOR01,
			OnWaveDead = Wave1Dead,
			IsDead = false,
			speech = nil
		},
		garageFightWave = {
			trigger = TRIGGER._1_03_FIGHT4,
			attackers = {
				{
					model = 145,
					spawn = POINTLIST._1_03_BULLY4,
					id = nil,
					guard = false,
					dropHealth = true
				}
			},
			OnAttack = nil,
			processed = false,
			door = TRIGGER._SCGRDOOR02,
			OnWaveDead = Wave2Dead,
			speech = nil,
			IsDead = false
		},
		finalFightWave = {
			trigger = TRIGGER._1_03_FIGHT5,
			attackers = {
				{
					model = 146,
					spawn = POINTLIST._1_03_GUARD1,
					id = nil,
					guard = false,
					dropHealth = false
				},
				{
					model = 147,
					spawn = POINTLIST._1_03_GUARD2,
					id = nil,
					guard = false,
					dropHealth = true
				}
			},
			OnAttack = nil,
			Action = "/Global/1_03/animations/GenStandTalking",
			EndAction = "/Global/1_03/animations/GenStandTalking/endTalking",
			processed = false,
			door = nil,
			OnWaveDead = LastWaveDead,
			speech = nil,
			IsDead = false
		},
		dropLadder = {
			trigger = TRIGGER._1_03_LADDER_DROP,
			attackers = {},
			OnAttack = DavisDropLadder,
			Action = nil,
			EndAction = nil,
			processed = false,
			door = nil,
			IsDead = false,
			speech = nil
		}
	}
	bWavesMade = true
end

function FinalFight()
	--print(">>>[RUI]", "!!FinalFight")
	WaveAttackPlayer(attack_waves.finalFightWave)
	DoDavisBarrelClimb()
	bDistanceCheckPaused = true
	PAnimSetActionNode(tblDoors.Garage2.ID, "/Global/1_03/ParametricDoor/POpenUp/Close/Closing/NotUseable/propClosed", "Act/Conv/1_03.act")
	AreaSetDoorLockedToPeds(tblDoors.Garage2.ID, true)
	AreaSetDoorPathableToPeds(tblDoors.Garage2.ID, false)
	AreaSetDoorLockedToPeds(tblDoors.Garage3.ID, false)
	AreaSetDoorPathableToPeds(tblDoors.Garage3.ID, true)
	Wait(10)
	for _, wave in attack_waves do
		if wave then
			for _, attacker in wave.attackers do
				if F_PedExists(attacker.id) and not PedIsInTrigger(attacker.id, TRIGGER._1_03_KEEPPEDTRIGGER) then
					--print(">>>[RUI]", "FinalFight Ped cleanup")
					PedClearObjectives(attacker.id)
					Wait(10)
					PedDelete(attacker.id)
				end
			end
		end
	end
	--print(">>>[RUI]", "--FinalFight")
end

function DoDavisBarrelClimb()
	--print(">>>[RUI]", "!!DoDavisBarrelClimb")
	MissionObjectiveComplete(chaseDavisObj)
	PedClearObjectives(gDavis)
	PedSetPosPoint(gDavis, POINTLIST._1_03_BARRELSTOP)
	PedFaceHeading(gDavis, 180, 0)
	bTaunting = true
	CreateThread("T_Taunt")
	bChicken = false
	PAnimSetActionNode(TRIGGER._TBARRELS_SBARELS1, "/Global/sbarels1/InitCollisionOn", "Act/Props/SBarels1.act")
	PAnimMakeTargetable(TRIGGER._TBARRELS_SBARELS1, false)
	SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 22, "jumbo")
	--print(">>>[RUI]", "--DoDavisBarrelClimb")
end

function GarageFight()
	--print(">>>[RUI]", "!!GarageFight")
	AreaSetDoorLockedToPeds(tblDoors.Garage2.ID, false)
	AreaSetDoorPathableToPeds(tblDoors.Garage2.ID, true)
	Wait(10)
	WaveAttackPlayer(attack_waves.garageFightWave)
	PedSetActionNode(gDavis, "/Global/1_03/animations/DavisWait/release", "Act/Conv/1_03.act")
	runner_Hiding = false
	PedSetAsleep(gDavis, false)
	SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 33, "jumbo")
	PedFollowPath(gDavis, PATH._1_03_FLEEGARAGE, 0, 2, cbFleeGarage)
	--print(">>>[RUI]", "--GarageFight")
end

function Wave_FightFromBehindBarrel()
	SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 32, "jumbo")
	WaveAttackPlayer(attack_waves.barrelWave)
end

function cbDoneClimbing()
	bDoneClimbing = true
	--print(">>>[RUI]", "!!cbDoneClimbing")
end

function cbDoorOpened()
	bDoorOpened = true
	--print(">>>[RUI]", "!!cbDoorOpened")
end

function cbBobbleDone()
	bBobbleDone = true
	--print(">>>[RUI]", "!!cbBobbleDone")
end

function cbFallDone()
	bFallDone = true
	--print(">>>[RUI]", "!!cbFallDone")
end

function DavisExitDoorTrigger(door)
	door.luckyExit = true
	if not door.processed then
		PAnimSetActionNode(door.ID, door.closeAction, "Act/Conv/1_03.act")
		AreaSetDoorLockedToPeds(door.ID, true)
		AreaSetDoorPathableToPeds(door.ID, false)
		door.bCoronaActive = true
		--print(">>>[RUI]", "close door")
		door.processed = true
		bDoorOpened = false
	end
	--print(">>>[RUI]", "!!DavisExitDoorTrigger")
end

function T_DoorMonitor()
	--print(">>>[RUI]", "++T_DoorMonitor")
	while bMissionRunning and MissionActive() do
		for _, door in tblDoors do
			loc = door.coronaLoc
			while door.bCoronaActive do
				PlayerIsInAreaXYZ(loc[1], loc[2], loc[3], 0.75, 7)
				if bDoorOpened then
					AreaSetDoorLockedToPeds(door.ID, false)
					AreaSetDoorPathableToPeds(door.ID, true)
					door.bCoronaActive = false
					if door.startFight then
						door.startFight()
						--print(">>>[RUI]", ">>>> door triggered a fight")
					end
				else
					door.bCoronaActive = true
				end
				door.bCoronaActive = not bDoorOpened
				Wait(0)
			end
		end
		Wait(0)
	end
	--print(">>>[RUI]", "!!T_DoorMonitor:    opened")
	collectgarbage()
end

function T_WaveMonitor()
	--print(">>>[RUI]", "++T_WaveMonitor")
	while bMissionRunning do
		for _, wave in attack_waves do
			if AreWaveAttackersDead(wave) and not wave.isDead then
				wave.isDead = true
				if wave.OnWaveDead then
					wave.OnWaveDead(wave)
				end
			end
		end
		if not MissionActive() then
			break
		end
		Wait(0)
	end
	collectgarbage()
	--print(">>>[RUI]", "--T_WaveMonitor")
end

function F_CheckDistanceFailure()
	if not bDistanceCheckPaused then
		if PlayerTooFarFromDavis() then
			if gFailureTimer then
				TextPrint("1_03_D13", 0.5, 1)
				--print(">>>[RUI]", "gDistanceCountDown: " .. tostring(gDistanceCountDown))
				if TimerPassed(gDistanceCountDownTimer) then
					gDistanceCountDown = gDistanceCountDown - 1
					if gDistanceCountDown < 0 then
						gDistanceCountDown = 0
					end
					gDistanceCountDownTimer = GetTimer() + 1000
				end
				if TimerPassed(gFailureTimer) then
					return true
				end
			else
				gFailureTimer = GetTimer() + MAX_FAILURE_DELAY
				gDistanceCountDownTimer = GetTimer() + 1000
				gDistanceCountDown = DISTANCE_COUNTDOWN_MAX
			end
		else
			gDistanceCountDown = DISTANCE_COUNTDOWN_MAX
			gFailureTimer = nil
			gDistanceCountDownTimer = nil
		end
		if PlayerIsInTrigger(TRIGGER._1_03_FAILTRIGGER01) or PlayerIsInTrigger(TRIGGER._1_03_FAILTRIGGER02) or PlayerIsInTrigger(TRIGGER._1_03_FAILTRIGGER04) or AreaGetVisible() ~= 0 then
			TextPrint("1_03_D10", 0.5, 1)
			return true
		end
	end
	return false
end

function TimerPassed(time)
	return time < GetTimer()
end

function PlayerTooFarFromDavis()
	local bFail = false
	bFail = DistanceBetweenPeds3D(gPlayer, gDavis) > MAX_FAIL_DISTANCE_LIMIT
	return bFail
end

function LastWaveDead(wave)
	bLastWaveIsDead = true
	--print(">>>[RUI]", "!!LastWaveDead")
end

function Wave1Dead()
	bWave1Dead = true
	--print(">>>[RUI]", "!!Wave1Dead")
end

function Wave2Dead()
	bWave2Dead = true
	--print(">>>[RUI]", "!!Wave2Dead")
end

function AllWavesDead()
	return bLastWaveIsDead and bWave1Dead and bWave2Dead
end

function AreWaveAttackersDead(wave)
	for _, attacker in wave.attackers do
		if F_PedExists(attacker.id) and not F_PedIsDead(attacker.id) then
			return false
		end
	end
	return true
end

function AllWaveAttackersFlee()
	--print(">>>[RUI]", "!!AllWaveAttackersFlee")
	for _, wave in attack_waves do
		if wave then
			for _, attacker in wave.attackers do
				if attacker and F_PedExists(attacker.id) then
					PedFleeNow(attacker.id, gPlayer, 13)
				end
			end
		end
	end
	if F_PedExists(gCSBully) then
		PedFleeNow(gCSBully, gPlayer, 13)
	end
	return true
end

function PedFleeNow(ped, fleePed, fleePedType)
	PedClearObjectives(ped)
	Wait(10)
	PedSetPedToTypeAttitude(ped, fleePedType, 4)
	PedAddPedToIgnoreList(ped, fleePed)
	PedIgnoreStimuli(ped, true)
	PedIgnoreAttacks(ped, true)
	Wait(10)
	PedFlee(ped, fleePed)
end

function CreateCharacters()
	for _, wave in attack_waves do
		for __, attacker in wave.attackers do
			attacker.id = PedCreatePoint(attacker.model, attacker.spawn)
			if wave.Action then
				PedSetActionNode(attacker.id, wave.Action, "Act/Conv/1_03.act")
			end
			if attacker.dropHealth then
				F_PedSetDropItem(attacker.id, 362)
			end
		end
	end
	gCSBully = PedCreatePoint(146, POINTLIST._1_03_BULLY1)
	F_PedSetDropItem(gCSBully, 362)
	--print(">>>[RUI]", "++CreateCharacters")
end

function DavisIgnorePlayer(bIgnore)
	if bIgnore then
		PedAddPedToIgnoreList(gDavis, gPlayer)
		PedIgnoreAttacks(gDavis, true)
		--print(">>>[RUI]", "Davis set to ignore player")
	else
		PedRemovePedFromIgnoreList(gDavis, gPlayer)
		PedIgnoreAttacks(gDavis, false)
		--print(">>>[RUI]", "Davis set to NOT ignore player")
	end
end

function DavisCreate()
	local davis = PedCreatePoint(99, POINTLIST._1_03_DAVISSTART)
	PedSetInfiniteSprint(davis, true)
	PedSetMinHealth(davis, 10)
	PedSetInvulnerable(davis, true)
	PedIgnoreStimuli(davis, true)
	PedSetActionTree(davis, "/Global/1_03_Davis/Default_KEY", "Act/Anim/1_03_Davis.act")
	--print(">>>[RUI]", "++DavisCreate: " .. tostring(davis))
	return davis
end

function DavisSetup()
	--print(">>>[RUI]", "++DavisSetup")
	--print(">>>[RUI]", "DavisSetup DAVIS_FLEE_SCHOOL_01")
	PedLockTarget(gDavis, gPlayer, 3)
	PedSetFocus(gDavis, gPlayer)
	PedOverrideStat(gDavis, 1, 0)
	PedOverrideStat(gDavis, 10, 90)
	PedOverrideStat(gDavis, 11, 70)
	DavisIgnorePlayer(true)
	gDavisBlip = AddBlipForChar(gDavis, 2, 26, 4)
end

function DoorsAssociateDavis(doorsTable)
	for _, door in doorsTable do
		door.ped = gDavis
	end
	L_AddTrigger("davisDoors", tblDoors)
	--print(">>>[RUI]", "!!DoorsAssociateDavis")
end

function CreateGarbageCans()
	garbageCans = {
		{
			id = TRIGGER._1_03_GARBAGECAN02,
			blipStyle = 0
		},
		{
			id = TRIGGER._1_03_GARBAGECAN05,
			blipStyle = 0
		},
		{
			id = TRIGGER._1_03_GARBAGECAN06,
			blipStyle = 0
		},
		{
			id = TRIGGER._1_03_GARBAGECAN07,
			blipStyle = 0
		}
	}
	for _, e in garbageCans do
		PAnimCreate(e.id)
		PAnimMakeTargetable(e.id, false)
	end
	--print(">>>[RUI]", "++CreateGarbageCans")
end

function CreateRespawnableBricks()
	local s = GetPointListSize(POINTLIST._1_03_PICKUPBRICKS)
	local x, y, z
	for i = 1, s do
		x, y, z = GetPointFromPointList(POINTLIST._1_03_PICKUPBRICKS, i)
		PickupCreateXYZ(311, x, y, z, "BrickBute")
	end
	--print(">>>[RUI]", "CreateRespawnableBricks++")
end

local x, y, z

function CreateWeaponPickups()
	tblWeapon = {
		{
			point = POINTLIST._1_03_TCLID02,
			model = 315
		},
		{
			point = POINTLIST._1_03_TCLID04,
			model = 315
		},
		{
			point = POINTLIST._1_03_TCLID05,
			model = 315
		},
		{
			point = POINTLIST._1_03_TCLID06,
			model = 315
		}
	}
	for _, weapon in tblWeapon do
		x, y, z = GetPointFromPointList(weapon.point, 1)
		weapon.id = PickupCreateXYZ(weapon.model, x, y, z, "PermanentMission")
	end
	--print(">>>[RUI]", "++CreateWeaponPickups")
end

function WaveAttackPlayer(wave)
	if not wave.attackers then
		return
	end
	for _, attacker in wave.attackers do
		if wave.EndAction then
			if F_PedExists(attacker.id) then
				PedSetActionNode(attacker.id, wave.EndAction, "Act/Conv/1_03.act")
				--print(">>>[RUI]", "!!WaveAttackPlayer break action wait")
				while PedIsPlaying(attacker.id, wave.EndAction, true) do
					Wait(4)
				end
			end
			--print(">>>[RUI]", "!!WaveAttackPlayer break action done")
		end
		if attacker.guard then
			if F_PedExists(attacker.id) then
				PedSetFocus(attacker.id, gPlayer)
				PedGuardPed(attacker.id, gDavis)
			end
			--print(">>>[RUI]", "!!WaveAttackPlayer->guard")
		else
			if F_PedExists(attacker.id) then
				PedAttackPlayer(attacker.id)
			end
			--print(">>>[RUI]", "!!AttackPlayer")
		end
	end
	--print(">>>[RUI]", "!!WaveAttackPlayer")
end

function CountWave(wave)
	return not wave.processed
end

function T_RunFights()
	--print(">>>[RUI]", "++T_RunFights")
	local processedCount = 0
	local waveCount = F_TableSize(attack_waves, CountWave)
	while bMissionRunning and waveCount > processedCount and MissionActive() do
		for _, wave in attack_waves do
			if PlayerIsInTrigger(wave.trigger) and not wave.processed then
				if wave.OnAttack then
					wave.OnAttack(wave)
				end
				wave.processed = true
				processedCount = processedCount + 1
			end
		end
		Wait(0)
	end
	--print(">>>[RUI]", "--T_RunFights")
	collectgarbage()
end

function cbDoneFleeToFountain(runner, path, node)
	if runner == gDavis then
		if node == 1 then
			PedSetActionNode(gDavis, "/Global/1_03/animations/DavisShoulder/ShoulderSlam", "Act/Conv/1_03.act")
			PedSetActionNode(gPeter, "/Global/1_03/animations/PeterFistShake/PeterHit", "Act/Conv/1_03.act")
		elseif node == PathGetLastNode(path) then
			bNISBragTime = true
			--print(">>>[RUI]", "!!cbDoneFleeToFountain")
		end
	end
end

function cbDoneFleeFountain(runner, path, node)
	if runner == gDavis and node == PathGetLastNode(path) then
		bDoneFleeFountain = true
		--print(">>>[RUI]", "!!cbDoneFleeFountain")
	end
end

function cbDoneFleeToGarage(runner, path, node)
	if runner == gDavis and node == PathGetLastNode(path) then
		bDoneFleeToGarage = true
		--print(">>>[RUI]", "!!cbDoneFleeToGarage")
	end
end

function cbFleeGarage(runner, path, node)
	if runner == gDavis and node == PathGetLastNode(path) then
		bDoneFleeGarage = true
		--print(">>>[RUI]", "!!cbFleeGarage")
	end
end

function cbDavisHit(victim, attacker)
	if attacker == gPlayer then
		gDavisHitCount = gDavisHitCount + 1
		if gDavisHitCount == 1 and not bHit1Handled then
			damage = gDavisMaxHealth * 0.3
			--print(">>>[RUI]", "cbDavisHit    'Davis: that wasn't funny!'")
			SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 12, "jumbo")
			bHit1Handled = true
			--print(">>>[RUI]", "cbDavisHit    gDavisHitCount == 1    damage: " .. tostring(damage) .. " max: " .. tostring(PedGetMaxHealth(gDavis)))
		elseif gDavisHitCount == 2 and not bHit2Handled then
			damage = gDavisMaxHealth * 0.6
			bHit2Handled = true
			--print(">>>[RUI]", "cbDavisHit    gDavisHitCount == 2    damage: " .. tostring(damage) .. " max: " .. tostring(PedGetMaxHealth(gDavis)))
		elseif gDavisHitCount == 3 and not bHit3Handled then
			damage = gDavisMaxHealth * 0.91
			PedSetInvulnerableToPlayer(gDavis, true)
			PedMakeTargetable(gDavis, false)
			PedIgnoreStimuli(gDavis, true)
			bHit3Handled = true
			bDavisDefeated = true
			--print(">>>[RUI]", "cbDavisHit    gDavisHitCount == 3    damage: " .. tostring(damage) .. " max: " .. tostring(PedGetMaxHealth(gDavis)))
		end
		PedSetHitRecordDamage(gDavis, 0)
		bDavisCanAttackNow = true
		PedSetHealth(gDavis, gDavisMaxHealth - damage)
	end
end

function DavisDropLadder()
	--print(">>>[RUI]", "!!DavisDropLadder")
	PedSetActionNode(gDavis, "/Global/1_03/animations/DavisKickLadder", "Act/Conv/1_03.act")
	PAnimSetActionNode(TRIGGER._1_03_BARELLAD, "/Global/BarellLadder/Destroyed", "Act/Props/barrelLad.act")
	bLadderDropped = true
end

function CutsceneDavisBegs()
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	CameraSetWidescreen(true)
	PlayerSetControl(0)
	F_MakePlayerSafeForNIS(true)
	CameraAllowChange(true)
	TextClear()
	AllWaveAttackersFlee()
	bTaunting = false
	bChicken = false
	CameraSetFOV(90)
	CameraSetXYZ(127.90819, 24.97325, 7.055124, 128.21823, 25.78979, 7.541829)
	CameraLookAtObject(gDavis, 2, true)
	PedSetPosPoint(gDavis, POINTLIST._1_03_DAVISFALLFROM)
	PedClearTether(gDavis)
	PedStop(gDavis)
	local x, y, z = GetPointFromPointList(POINTLIST._1_03_OFFBARRELS, 1)
	PedFaceXYZ(gDavis, x, y, z, 0)
	--print(">>>[RUI]", "CusceneDavisBegs:    'Davis:    [falling]Woah'")
	if not bLadderDropped then
		--print(">>>[RUI]", "emergency ladder drop")
		PAnimSetActionNode(TRIGGER._1_03_BARELLAD, "/Global/BarellLadder/Destroyed", "Act/Props/barrelLad.act")
		bLadderDropped = true
	end
	SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 11, "supersize")
	PedSetActionNode(gDavis, "/Global/1_03/animations/FallOffBarrels/NewFall", "Act/Conv/1_03.act")
	PAnimSetActionNode(TRIGGER._TBARRELS_SBARELS1, "/Global/sbarels1/Rumble", "Act/Props/SBarels1.act")
	while not bBobbleDone do
		Wait(0)
	end
	--print(">>>[RUI]", "CutsceneDavisBegs BobbleDone")
	Wait(100)
	BarrelsDestroy()
	while not bFallDone do
		Wait(10)
	end
	--print(">>>[RUI]", "CutsceneDavisBegs Fell off")
	Wait(500)
	PedClearWeapon(gDavis, 303)
	SoundFadeWithCamera(false)
	MakeAllFightersAmbient(true)
	CameraFade(500, 0)
	Wait(501)
	SoundStopInteractiveStream(0)
	PlayerSetPosPoint(POINTLIST._1_03_PLAYERCS2, 1)
	DavisCleanup()
	AreaEnsureSpecialEntitiesAreCreatedWithOverride("1_03", 4)
	PAnimSetActionNode(tblDoors.Garage2.ID, openAction, "Act/Conv/1_03.act")
	CameraSetFOV(30)
	CameraSetXYZ(128.40541, 24.343134, 6.822272, 129.01411, 25.118198, 6.99084)
	Wait(250)
	CameraFade(500, 1)
	CameraSetFOV(30)
	Wait(501)
	PedSetActionNode(gPlayer, "/Global/1_03/animations/PlayerPickupSlingshot", "Act/Conv/1_03.act")
	SoundPlayMissionEndMusic(true, 8)
	MinigameSetCompletion("M_PASS", true, 0, "1_03_SLINGSHOT")
	Wait(500)
	MinigameAddCompletionMsg("MRESPECT_BM5", 1)
	while PedIsPlaying(gPlayer, "/Global/1_03/animations/PlayerPickupSlingshot", true) do
		Wait(10)
	end
	while MinigameIsFadingCompletion() do
		Wait(0)
	end
	AreaSetPathableInRadius(134.7, 27.6, 6.1, 0.2, 10, true)
	GiveWeaponToPlayer(303, false)
	Wait(250)
	TutorialShowMessage("TUT_RSPX02", 4500, true)
	Wait(4750)
	TutorialShowMessage("TUT_RSPX03", 4500, true)
	Wait(4750)
	CameraFade(500, 0)
	Wait(501)
	F_MakePlayerSafeForNIS(false)
	DavisCleanup()
	DoorsRemove()
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	--print(">>>[RUI]", "--CutsceneDavisBegs")
end

function BarrelsDestroy()
	PAnimSetActionNode(TRIGGER._TBARRELS_SBARELS1, "/Global/sbarels1/Destroy", "Act/Props/SBarels1.act")
	--print(">>>[RUI]", "--BarrelsDestroy")
end

function F_cbBarrelDestroyTime()
	--print(">>>[RUI]", "!!F_cbBarrelDestroyTime")
	bBarrelDestroyTime = true
end

function T_Taunt()
	--print(">>>[RUI]", "++T_Taunt")
	DavisTaunt()
	while not bChicken and bMissionRunning do
		Wait(10)
		if not MissionActive() then
			return
		end
	end
	Wait(6000)
	DavisChicken()
	collectgarbage()
	--print(">>>[RUI]", "--T_Taunt")
end

function DavisTaunt()
	--print(">>>[RUI]", "DavisTaunt")
	if not bTaunting then
		return
	end
	--print(">>>[RUI]", "T_Taunt: Davis: \tDoesn't seem like such a good idea now, does it?")
	SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 21, "jumbo")
	while SoundSpeechPlaying() == 1 do
		Wait(10)
	end
	Wait(5000 + math.random(30) * 100)
	if not bTaunting then
		return
	end
	--print(">>>[RUI]", "T_Taunt: Davis: \tFunny, you don't look so tough ")
	SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 23, "jumbo")
	while SoundSpeechPlaying() == 1 do
		Wait(10)
	end
	--print(">>>[RUI]", "--DavisTaunt")
end

function DavisChicken()
	--print(">>>[RUI]", "++DavisChicken")
	if not bChicken then
		return
	end
	--print(">>>[RUI]", "T_Taunt: Davis: \tHey, stay away from me...")
	SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 41, "jumbo")
	while SoundSpeechPlaying() == 1 do
		Wait(10)
	end
	Wait(5000 + math.random(30) * 100)
	if not bChicken then
		return
	end
	--print(">>>[RUI]", "T_Taunt: Davis: \tHey, What are you crazy or something?")
	SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 42, "jumbo")
	--print(">>>[RUI]", "--DavisChicken")
end

function DavisBreakForGarage()
	--print(">>>[RUI]", "!!DavisBreakForGarage")
	SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 14, "jumbo")
	PedSetActionNode(gDavis, "/Global/1_03/animations/DavisWaitTired/Stop", "Act/Conv/1_03.act")
	PedSetActionNode(gCSBully, "/Global/1_03/animations/DavisBrag/release", "Act/Conv/1_03.act")
	PedFollowPath(gDavis, PATH._1_03_FLEEFROMFOUNTAIN, 0, 3, cbDoneFleeFountain)
	SoundPlayScriptedSpeechEvent(gCSBully, "M_1_03", 3, "jumbo")
	PedMakeTargetable(gPlayer, true)
	PedClearObjectives(gCSBully)
	PedAttackPlayer(gCSBully)
	DavisGroupHitRegister(false)
end

function DavisGroupHitRegister(bOn)
	--print(">>>[RUI]", "DavisGroupHitRegister on " .. tostring(bOn))
	if bOn then
		RegisterPedEventHandler(gDavis, 0, cbDavisGroupHit)
		RegisterPedEventHandler(gCSBully, 0, cbDavisGroupHit)
	else
		RegisterPedEventHandler(gDavis, 0, nil)
		RegisterPedEventHandler(gCSBully, 0, nil)
	end
end

function cbDavisGroupHit(victim, attacker)
	--print(">>>[RUI]", "??cbDavisGroupHit")
	if attacker == gPlayer and (victim == gDavis or victim == gCSBully) then
		--print(">>>[RUI]", "!!cbDavisGroupHit")
		bDavisGroupHit = true
	end
end

function T_ChasePartTwo()
	--print(">>>[RUI]", "!!T_ChasePartTwo")
	while not PlayerIsInTrigger(TRIGGER._1_03_DAVISREGISTERHIT) do
		DavisGroupHitRegister(true)
		Wait(0)
	end
	while not (PlayerIsInTrigger(TRIGGER._1_03_FIGHT1) or bDavisGroupHit) do
		if bNISBragTime then
			--print(">>>[RUI]", "!!T_ChasePartTwo set up DAVIS TIRED")
			PedStop(gDavis)
			PedSetPosPoint(gDavis, POINTLIST._1_03_DAVISBRAG, 1)
			--print(">>>[RUI]", "Chase2_WaitForBrag: bNISBragTime == true")
			PedFaceObject(gDavis, gCSBully, 2, 0)
			PedFaceObject(gCSBully, gDavis, 2, 0)
			PedSetActionNode(gDavis, "/Global/1_03/animations/DavisWaitTired/TiredLoop", "Act/Conv/1_03.act")
			DavisGroupHitRegister(true)
			bNISBragTime = false
		end
		if not MissionActive() or not bMissionRunning then
			return
		end
		Wait(0)
	end
	Wait(850)
	DavisBreakForGarage()
	CreateThread("T_BarrelTutorial")
	SoundPlayInteractiveStreamLocked("MS_BikeChaseHigh.rsm", 0.6)
	Chase2_WaitForPauseLocation()
	Chase2_WaitForGarageLocation()
	Chase2_WaitForPathEnd()
	Chase2_HandleBarrelFight()
	bMissionRunning = false
	collectgarbage()
	--print(">>>[RUI]", "--T_ChasePartTwo")
end

function T_BarrelTutorial()
	bDoBarrelTutorial = true
	Wait(3000)
	TutorialShowMessage("TUT_GBIN1")
	local x, y, z = GetPointList(POINTLIST._1_03_BARRELBLIP)
	gGarbageCanBlip = BlipAddXYZ(x, y, z + ARROW_OFFSET_Z, -1, 2)
	while not (not bDoBarrelTutorial or F_PedIsDead(gCSBully)) do
		if not MissionActive() or not bMissionRunning then
			return
		end
		Wait(100)
	end
	TutorialRemoveMessage()
	BlipClean(gGarbageCanBlip)
end

function T_Chase2_MeetPeter()
	--print(">>>[RUI]", "++T_Chase2_MeetPeter")
	while not F_PedExists(gPeter) do
		if not MissionActive() or not bMissionRunning then
			return
		end
		Wait(50)
	end
	--print(">>>[RUI]", "!!T_Chase2_MeetPeter:    in school yard")
	while not PlayerIsInTrigger(TRIGGER._1_03_PETERTRIGGER) do
		if not MissionActive() or not bMissionRunning then
			return
		end
		Wait(0)
	end
	if not F_PedIsDead(gPeter) then
		PedSetActionNode(gPeter, "/Global/1_03/animations/PeterFistShake/FistShakeEnd", "Act/Conv/1_03.act")
		--print(">>>[RUI]", "!!T_Chase2_MeetPeter:    player sees Peter")
		while PedIsPlaying(gPeter, "/Global/1_03/animations/PeterFistShake/FistShakeEnd", true) do
			if not MissionActive() or not bMissionRunning then
				return
			end
			Wait(0)
		end
		if F_PedExists(gPeter) then
			PedWander(gPeter, 0)
			PedMakeAmbient(gPeter)
			--print(">>>[RUI]", "Dismiss Peter")
		end
	end
	collectgarbage()
	--print(">>>[RUI]", "--T_Chase2_MeetPeter")
end

function Chase2_WaitForPauseLocation()
	--print(">>>[RUI]", "!!Chase2_WaitForPauseLocation")
	while not PlayerIsInTrigger(TRIGGER._1_03_DAVISRUN) do
		if bDoneFleeFountain then
			PedClearObjectives(gDavis)
			Wait(10)
			PedSetAsleep(gDavis, true)
			bDoneFleeFountain = false
			--print(">>>[RUI]", "DoneFountainFlee")
		end
		if not MissionActive() or not bMissionRunning then
			return
		end
		Wait(50)
	end
	bDoBarrelTutorial = false
	PedSetActionNode(gDavis, "/Global/1_03/animations/DavisWait/release", "Act/Conv/1_03.act")
	PedSetAsleep(gDavis, false)
	SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 5, "jumbo")
	PedFollowPath(gDavis, PATH._1_03_FLEETOGARAGE, 0, 3, cbDoneFleeToGarage)
	--print(">>>[RUI]", "Chase2_WaitForPauseLocation: runner_attacking == true")
end

function Chase2_WaitForGarageLocation()
	--print(">>>[RUI]", "!!Chase2_WaitForGarageLocation")
	while not bDoneFleeToGarage do
		if not MissionActive() or not bMissionRunning then
			return
		end
		Wait(0)
	end
	--print(">>>[RUI]", "Davis Hide")
	PedClearObjectives(gDavis)
	PedSetPosPoint(gDavis, POINTLIST._1_03_DAVISINGARAGE)
	PedSetActionNode(gDavis, "/Global/1_03/animations/DavisWait", "Act/Conv/1_03.act")
	Wait(10)
	PedSetAsleep(gDavis, true)
	PedFaceObjectNow(gDavis, gPlayer, 3)
	--print(">>>[RUI]", "Chase2_WaitForGarageLocation: davis not hiding")
end

function Chase2_WaitForPathEnd()
	--print(">>>[RUI]", "!!Chase2_WaitForPathEnd")
	while not bDoneFleeGarage do
		if not MissionActive() or not bMissionRunning then
			return
		end
		Wait(0)
	end
	PedClearObjectives(gDavis)
	PedStop(gDavis)
	PedSetAsleep(gDavis, true)
	--print(">>>[RUI]", "Chase2_WaitForPathEnd: bDoneFleeGarage or PedIsDead(gDavis)")
end

function Chase2_HandleBarrelFight()
	--print(">>>[RUI]", "!!Chase2_HandleBarrelFight")
	gDavisMaxHealth = 200
	gDavisMinHealth = gDavisMaxHealth - gDavisMaxHealth * 0.9
	PedSetHealth(gDavis, gDavisMaxHealth)
	gDavisHitCount = 0
	--print(">>>[RUI]", "wait for Davis Attack")
	RegisterPedEventHandler(gDavis, 0, cbDavisHit)
	PedSetMinHealth(gDavis, 0)
	PedSetInvulnerable(gDavis, false)
	PedMakeTargetable(gDavis, true)
	while not bDavisDefeated do
		if not MissionActive() or not bMissionRunning then
			return
		end
		if not bDavisFightStart then
			if AllWavesDead() or bDavisCanAttackNow then
				bTaunting = false
				bChicken = true
				PedSetTetherToPoint(gDavis, POINTLIST._1_03_BARRELSTOP, 1, 1)
				PedSetWeapon(gDavis, 303, 6)
				PedSetFlag(gDavis, 21, false)
				PedCoverSet(gDavis, gPlayer, POINTLIST._1_03_BARRELSTOP, 1, 20, 1, 0, 0, 2, 1, 0, 0, 1, 1, true)
				if not bDavisCanAttackNow then
					CreateThread("T_BossBattleTutorial")
				end
				bDavisFightStart = true
				--print(">>>[RUI]", "!!Start Davis Fighting")
			end
		elseif not bHealthBarShown then
			PedShowHealthBar(gDavis, true, "1_03_D12", true)
			bHealthBarShown = true
		end
		if not MissionActive() or not bMissionRunning then
			return
		end
		Wait(30)
	end
	RegisterPedEventHandler(gDavis, 0, nil)
	--print(">>>[RUI]", "Chase2_HandleBarrelFight:    Davis hurt badly")
	bBattleOver = true
	bMissionPassed = true
	HealthBarCleanup()
	bTaunting = false
	bChicken = false
end

function MakeAllFightersAmbient(bDelete)
	if not bWavesMade then
		return
	end
	for _, wave in attack_waves do
		for __, attacker in wave.attackers do
			if F_PedExists(attacker.id) then
				if not bDelete then
					PedStop(attacker.id)
					PedDontCleanup(attacker.id)
					PedWander(attacker.id, 1)
					PedMakeAmbient(attacker.id)
				else
					PedDelete(attacker.id)
				end
			end
		end
	end
	if F_PedExists(gCSBully) then
		if bDelete then
			PedDelete(gCSBully)
		else
			PedStop(gCSBully)
			PedDontCleanup(gCSBully)
			PedWander(gCSBully, 1)
			PedMakeAmbient(gCSBully)
		end
	end
	--print(">>>[RUI]", "MakeAllFightersAmbient")
	bWavesMade = false
end

function DoorsInit()
	tblDoors = {
		FrontGate = {
			ped = gPlayer,
			trigger = TRIGGER._1_03_FRONTGATE,
			OnExit = DavisExitDoorTrigger,
			ID = TRIGGER._TSCHOOL_AUTOSHOPFGATE,
			bCoronaActive = false,
			coronaLoc = {
				GetPointFromPointList(POINTLIST._1_03_GATECORONA, 1)
			},
			openAction = "/Global/1_03/ParametricDoor/POpenSide/Base",
			closeAction = "/Global/1_03/ParametricDoor/POpenSide/Close",
			startFight = nil,
			tutorial = true,
			name = "SlidingDoor",
			processed = false
		},
		Garage2 = {
			ped = gPlayer,
			trigger = TRIGGER._1_03_GARAGE02,
			OnExit = DavisExitDoorTrigger,
			ID = TRIGGER._SCGRDOOR01,
			bCoronaActive = false,
			coronaLoc = {
				GetPointFromPointList(POINTLIST._1_03_DOOR1CORONA, 1)
			},
			openAction = "/Global/1_03/ParametricDoor/POpenUp/Base",
			closeAction = "/Global/1_03/ParametricDoor/POpenUp/Close",
			startFight = GarageFight,
			name = "GarageDoor1",
			processed = false
		},
		Garage3 = {
			ped = gPlayer,
			trigger = TRIGGER._1_03_GARAGE03,
			OnExit = DavisExitDoorTrigger,
			ID = TRIGGER._SCGRDOOR02,
			bCoronaActive = false,
			coronaLoc = {
				GetPointFromPointList(POINTLIST._1_03_DOOR2CORONA, 1)
			},
			openAction = "/Global/1_03/ParametricDoor/POpenUp/BaseWithCollissionOn",
			closeAction = "/Global/1_03/ParametricDoor/POpenUp/Close",
			startFight = FinalFight,
			name = "GarageDoor2",
			processed = false
		}
	}
	bDoorsMade = true
end

function DoorsCreate()
	PAnimCreate(TRIGGER._SCGRDOOR)
	PAnimCloseDoor(TRIGGER._SCGRDOOR)
	AreaSetDoorLockedToPeds(TRIGGER._SCGRDOOR, true)
	AreaSetDoorPathableToPeds(TRIGGER._SCGRDOOR, false)
	--print(">>>[RUI]", "++TRIGGER._SCGRDOOR")
	for _, door in tblDoors do
		PAnimCreate(door.ID)
		PAnimSetActionNode(door.ID, door.openAction, "Act/Conv/1_03.act")
		--print(">>>[RUI]", "++" .. door.name)
	end
	--print(">>>[RUI]", "++Doors")
end

function DoorsRemove()
	AreaSetDoorPathableToPeds(TRIGGER._SCGRDOOR, true)
	PAnimDelete(TRIGGER._SCGRDOOR)
	--print(">>>[RUI]", "--TRIGGER._SCGRDOOR")
	for _, door in tblDoors do
		AreaSetDoorPathableToPeds(door.ID, true)
		PAnimDelete(door.ID)
		--print(">>>[RUI]", "--" .. door.name)
	end
	--print(">>>[RUI]", "--Doors")
end

function DoorsOpenAll()
	--print(">>>[RUI]", "!!DoorsOpenAll")
	for _, door in tblDoors do
		if not door.processed then
			PAnimSetActionNode(door.ID, door.openAction, "Act/Conv/1_03.act")
			door.bCoronaActive = false
		end
	end
	--print(">>>[RUI]", "!!DoorsOpenAll done")
end

function DoorsCloseAll()
	for _, door in tblDoors do
		if not door.processed then
			PAnimSetActionNode(door.ID, door.closeAction, "Act/Conv/1_03.act")
			AreaSetDoorPathableToPeds(door.ID, false)
			door.bCoronaActive = true
		end
	end
	--print(">>>[RUI]", "!!DoorsCloseAll")
end

function DoorsAreAllDone()
	for _, door in tblDoors do
		if not door.processed then
			return false
		end
	end
	--print(">>>[RUI]", "!!DoorsAreAllDone")
	return true
end

function WaitForButton(btn, warning)
	buttonTime = GetTimer()
	bBtnTimedOut = false
	while not IsButtonPressed(btn, 0) do
		Wait(10)
	end
	if warning and warning ~= "" and bBtnTimedOut then
		while not IsButtonPressed(btn, 0) do
			TutorialShowMessage(warning)
			Wait(10)
		end
	end
	TutorialRemoveMessage()
	Wait(500)
end

function WaitForWeapon(weapon, mode, warning)
	equipTimer = GetTimer()
	bSwitchTimedOut = false
	if mode == "equip" then
		while not PlayerHasWeapon(weapon) do
			Wait(10)
		end
	else
		while PlayerHasWeapon(weapon) do
			Wait(10)
		end
	end
	if warning and warning ~= "" and bSwitchTimedOut then
		if mode == "equip" then
			while not PlayerHasWeapon(weapon) do
				TutorialShowMessage(warning)
				Wait(10)
			end
		else
			while PlayerHasWeapon(weapon) do
				TutorialShowMessage(warning)
				Wait(10)
			end
		end
	end
	TutorialRemoveMessage()
	Wait(500)
end

function T_BossBattleTutorial()
	--print(">>>[RUI]", "++T_BossBattleTutorial")
	local bDroppedWeapon = true
	local weapon
	Wait(1500)
	TutorialShowMessage("1_03_T01")
	while not PlayerHasProjectile() do
		if GameOver() then
			break
		end
		Wait(10)
	end
	if not WaitInterruptible(500, GameOver) then
		while not GameOver() do
			if PlayerHasProjectile() then
				if bDroppedWeapon then
					TutorialShowMessage("1_03_T02")
					bDroppedWeapon = false
				end
				while not GameOver() do
					if not PlayerHasProjectile() then
						bDroppedWeapon = true
						TutorialRemoveMessage()
						break
					else
						bDroppedWeapon = false
					end
					bEndTutorial = false
					if gDavisHitCount > 0 then
						TutorialRemoveMessage()
						break
					end
					Wait(10)
				end
				Wait(500)
				if not bDroppedWeapon then
					bEndTutorial = true
					break
				end
				if bEndTutorial then
					break
				end
			end
			Wait(10)
		end
		TutorialRemoveMessage()
	end
	TutorialRemoveMessage()
	--print(">>>[RUI]", "--T_BossBattleTutorial")
	collectgarbage()
end

function PlayerHasProjectile(weapon)
	if weapon == nil then
		return PlayerHasWeapon(315) or PlayerHasWeapon(311)
	else
		return PlayerHasWeapon(weapon)
	end
end

function GameOver()
	return bMissionPassed or bBattleOver
end

function MissionSetup()
	MissionDontFadeIn()
	shared.gTurnOff_SGD_PREFECT3 = true
	shared.gTurnOff_HALLSPATROL_1C = true
	PedSetFlag(gPlayer, 2, false)
	PlayerSetControl(0)
	SoundPlayInteractiveStream("MS_BikeChaseLow.rsm", 0.5)
	SoundSetMidIntensityStream("MS_BikeChaseMid.rsm", 0.6)
	SoundSetHighIntensityStream("MS_BikeChaseHigh.rsm", 0.6)
	PlayCutsceneWithLoad("1-03", true, true, true)
	DATLoad("1_03.DAT", 2)
	DATLoad("tschool_garagedoors.DAT", 2)
	DATLoad("tbarrels.DAT", 2)
	DATInit()
	LoadAnimationGroup("1_03The Setup")
	LoadAnimationGroup("NIS_1_03")
	LoadAnimationGroup("POI_Smoking")
	LoadAnimationGroup("Hang_Talking")
	LoadAnimationGroup("GEN_Social")
	LoadAnimationGroup("Cheer_Cool2")
	LoadAnimationGroup("NPC_Adult")
	LoadAnimationGroup("TSGate")
	LoadAnimationGroup("SCgrdoor")
	LoadAnimationGroup("Sbarels1")
	LoadAnimationGroup("Area_School")
	LoadAnimationGroup("Px_Rail")
	LoadAnimationGroup("DO_Grap")
	LoadActionTree("Act/Props/SBarels1.act")
	LoadActionTree("Act/Props/barrelLad.act")
	LoadActionTree("Act/Conv/1_03.act")
	LoadActionTree("Act/Anim/1_03_Davis.act")
	F_SetCharacterModelsUnique(true, {
		99,
		85,
		145,
		146,
		147
	})
	F_RainBeGone()
	DisablePOI(true, true)
	AreaOverridePopulationPedType(11, 0)
	AreaActivatePopulationTrigger(TRIGGER._1_03_AUTOSHOPAREA)
	AreaDeactivatePopulationTrigger(TRIGGER._GREASERS)
	AreaClearAllPeds()
	AreaSetNodesSwitchedOffInTrigger(TRIGGER._1_03_AUTOSHOPAREA, true)
end

function MissionInit()
	bullyModels = {
		102,
		85,
		145,
		146,
		147
	}
	SoundMusicJimmyComeToTheOfficePA(false)
	LoadModels(bullyModels)
	LoadModels({
		362,
		311,
		315,
		134
	})
	LoadWeaponModels({
		315,
		303,
		311
	})
	Wait(10)
end

function DavisCleanup()
	if F_PedExists(gDavis) then
		PedClearObjectives(gDavis)
		PedDelete(gDavis)
		HealthBarCleanup()
		--print(">>>[RUI]", "--Davis")
	end
end

function HealthBarCleanup()
	if bHealthBarShown then
		PedHideHealthBar()
		bHealthBarShown = false
		--print(">>>[RUI]", "--HealthBar")
	end
end

function MissionCleanup()
	CameraSetWidescreen(false)
	PlayerSetControl(1)
	F_MakePlayerSafeForNIS(false)
	F_SetCharacterModelsUnique(false)
	SoundFadeWithCamera(true)
	TutorialRemoveMessage()
	MakeAllFightersAmbient()
	if F_PedExists(gPeter) then
		PedMakeAmbient(gPeter)
	end
	if F_PedExists(gCSBully) then
		PedMakeAmbient(gCSBully)
	end
	DavisCleanup()
	if F_PedExists(gPeter) then
		PedSetActionNode(gPeter, "/Global/1_03/animations/PeterFistShake/end", "Act/Conv/1_03.act")
		PedWander(gPeter, 0)
		PedMakeAmbient(gPeter)
	end
	if not bMissionPassed then
		shared.g1_03_BoughtSlingshot = nil
	end
	DoorsRemove()
	AreaSetNodesSwitchedOffInTrigger(TRIGGER._1_03_AUTOSHOPAREA, false)
	AreaDeactivatePopulationTrigger(TRIGGER._1_03_AUTOSHOPAREA)
	AreaActivatePopulationTrigger(TRIGGER._GREASERS)
	EnablePOI()
	AreaRevertToDefaultPopulation()
	WeatherRelease()
	shared.gTurnOff_SGD_PREFECT3 = false
	shared.gTurnOff_HALLSPATROL_1C = false
	TutorialRemoveMessage()
	if bMissionPassed then
		--print(">>>[RUI]", "--Barrels Collision")
		PAnimSetActionNode(TRIGGER._TBARRELS_SBARELS1, "/Global/sbarels1/DeadCollisionOff", "Act/Props/sBarels1.act")
	else
		PAnimSetActionNode(TRIGGER._TBARRELS_SBARELS1, "/Global/sbarels1/InitCollisionOn", "Act/Props/sBarels1.act")
	end
	if bLadderCreated then
		PAnimDelete(TRIGGER._1_03_BARELLAD)
	end
	SoundStopInteractiveStream(0)
	if not bMissionPassed then
		AreaEnsureSpecialEntitiesAreCreatedWithOverride("1_03", 1)
	end
	UnLoadAnimationGroup("1_03The Setup")
	UnLoadAnimationGroup("POI_Smoking")
	UnLoadAnimationGroup("Hang_Talking")
	UnLoadAnimationGroup("GEN_Social")
	UnLoadAnimationGroup("NPC_Adult")
	UnLoadAnimationGroup("TSGate")
	UnLoadAnimationGroup("SCgrdoor")
	UnLoadAnimationGroup("Sbarels1")
	UnLoadAnimationGroup("Px_Rail")
	DATUnload(2)
end

function BlipClean(blip)
	--print(">>>[RUI]", "!!BlipClean")
	if blip and blip ~= -1 then
		BlipRemove(blip)
	end
	return nil
end

function ChaseTwoSetup()
	--print(">>>[RUI]", "!!ChaseTwoSetup")
	gDavisBlip = AddBlipForChar(gDavis, 2, 26, 4)
	PedFollowPath(gDavis, PATH._1_03_FLEETOFOUNTAIN, 0, 3, cbDoneFleeToFountain)
	--print(">>>[RUI]", "++Peter")
	gLagStartTime = nil
	CreateThread("T_Chase2_MeetPeter")
	CreateThread("T_ChasePartTwo")
	CreateThread("T_RunFights")
	CreateThread("L_MonitorTriggers")
	CreateThread("T_WaveMonitor")
	CreateThread("T_DoorMonitor")
end

function ChaseTwoLoop()
	if F_CheckDistanceFailure() then
		gFailMessage = "1_03_D11"
		bMissionRunning = false
		bMissionPassed = false
		gMainLoop = nil
		return
	end
	if bOpenAllHack and PedIsInTrigger(gDavis, TRIGGER._1_03_FIGHT3) then
		DoorsOpenAll()
		bOpenAllHack = false
	end
	Wait(0)
end

function ChaseOneSetup()
	PlayerSetPosPoint(POINTLIST._1_03_START, 1)
	PlayerSetControl(0)
	F_MakePlayerSafeForNIS(true)
	CameraSetWidescreen(true)
	WaveInit()
	CreateCharacters()
	CreateGarbageCans()
	CreateWeaponPickups()
	CreateRespawnableBricks()
	PickupSetIgnoreRespawnDistance(true)
	PAnimCreate(TRIGGER._1_03_BARELLAD)
	PAnimMakeTargetable(TRIGGER._1_03_BARELLAD, false)
	bLadderCreated = true
	PAnimCreate(TRIGGER._TBARRELS_SBARELS1)
	PAnimMakeTargetable(TRIGGER._TBARRELS_SBARELS1, false)
	gDavis = DavisCreate()
	DavisSetup()
	DoorsInit()
	DoorsCreate()
	DoorsAssociateDavis(tblDoors)
	Wait(20)
	DoorsOpenAll()
	gPeter = PedCreatePoint(134, POINTLIST._1_03_PETER)
	Wait(50)
	PedSetActionNode(gPeter, "/Global/1_03/animations/PeterFistShake/Init", "Act/Conv/1_03.act")
	PedFaceObject(gPlayer, gDavis, 2, 1)
	CameraReturnToPlayer()
	CameraFade(600, 1)
	PedFollowPath(gDavis, PATH._1_03_SCHOOLFLEE, 0, 3, cbSchoolFlee)
	Wait(150)
	PedFollowPath(gPlayer, PATH._1_03_PURSUE, 0, 2, cbIntroPursueDone)
	TextPrint("1_03_INSTRUC02", 6, 1)
	while not bIntroPursueDone do
		Wait(100)
	end
	CameraSetWidescreen(false)
	F_MakePlayerSafeForNIS(false)
	PedFaceObject(gPlayer, gDavis, 2, 0)
	PlayerSetControl(1)
	TutorialStart("SPRINT1")
	chaseDavisObj = MissionObjectiveAdd("1_03_INSTRUC02")
	--print(">>>[RUI]", "!!ChaseOneSetup")
end

function cbIntroPursueDone(pedId, pathId, pathNode)
	if pedId == gPlayer and PathGetLastNode(pathId) == pathNode then
		bIntroPursueDone = true
		--print(">>>[RUI]", "!!bIntroPursueDone")
	end
end

function ChaseOneLoop()
	if not bSchoolFleeDone then
		if F_CheckDistanceFailure() then
			gFailMessage = "1_03_D11"
			bMissionRunning = false
			bMissionPassed = false
			gMainLoop = nil
			return
		end
	else
		--print(">>>[RUI]", "ChaseOneLoop player used other exits")
		ChaseTwoSetup()
		gMainLoop = ChaseTwoLoop
		return
	end
	Wait(10)
end

function cbSchoolFlee(pedId, pathId, pathNode)
	if pathId == PATH._1_03_SCHOOLFLEE then
		if pathNode == PathGetLastNode(pathId) then
			bSchoolFleeDone = true
			--print(">>>[RUI]", "!!cbSchoolFlee")
		elseif pathNode == 2 then
			SoundPlayScriptedSpeechEvent(gDavis, "M_1_03", 5, "jumbo")
		end
	end
end

function main()
	PlayerSetControl(0)
	MissionInit()
	ChaseOneSetup()
	gMainLoop = ChaseOneLoop
	while bMissionRunning do
		gMainLoop()
		Wait(0)
	end
	if bMissionPassed then
		--print(">>>[RUI]", "!!missionComplete")
		if bBattleOver then
			CutsceneDavisBegs()
		end
		PlayerSetScriptSavedData(15, 1)
		SetFactionRespect(11, 20)
		CameraSetXYZ(128.72765, 24.309237, 7.239811, 129.0967, 25.229708, 7.368386)
		Wait(10)
		CameraReturnToPlayer(false)
		Wait(500)
		MissionSucceed(true, false, false)
	else
		if bFailedToKeepUp then
			gDavisBlip = BlipClean(gDavisBlip)
			PedMakeAmbient(gDavis)
			Wait(3000)
		end
		TextClear()
		SoundPlayMissionEndMusic(false, 8)
		if gFailMessage then
			MissionFail(true, true, gFailMessage)
		else
			MissionFail(true, true)
		end
	end
end
