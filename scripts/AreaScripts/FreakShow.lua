local frSkeletonMan, frBeardedWoman, frSiamese02, frMidget01, frMidget02, frPaintedMan, frMermaid
local freakList = {}

function main()
	DATLoad("SP_FreakShow.DAT", 0)
	DATLoad("FreakShow.DAT", 0)
	shared.gAreaDATFileLoaded[55] = true
	shared.gAreaDataLoaded = true
	WeaponRequestModel(339)
	WeaponRequestModel(407)
	WeaponRequestModel(433)
	WeaponRequestModel(406)
	LoadAnimationGroup("Mermaid")
	LoadAnimationGroup("Jv_Asylum")
	LoadAnimationGroup("Siamese2")
	LoadAnimationGroup("SIAMESE")
	LoadAnimationGroup("BeardLady")
	LoadAnimationGroup("SkeltonMan")
	LoadActionTree("Act/Anim/FreakShow.act")
	LoadActionTree("Act/Anim/TO_Siamese.act")
	frSkeletonMan = PedCreatePoint(190, POINTLIST._FRS_SKELETONMAN)
	frBeardedWoman = PedCreatePoint(191, POINTLIST._FRS_BEARDEDWOMAN)
	frSiamese02 = PedCreatePoint(193, POINTLIST._FRS_SIAMESE02)
	frMidget01 = PedCreatePoint(188, POINTLIST._FRS_MIDGET01)
	frMidget02 = PedCreatePoint(189, POINTLIST._FRS_MIDGET02)
	frPaintedMan = PedCreatePoint(194, POINTLIST._FRS_PAINTEDMAN)
	frMermaid = PedCreatePoint(192, POINTLIST._FRS_MERMAID)
	PedSetEffectedByGravity(frMermaid, false)
	PedSetPosPoint(frMermaid, POINTLIST._FRS_MERMAID)
	ToggleHUDComponentVisibility(5, false)
	F_PreDATInit()
	DATInit()
	F_SetupDockers()
	freakList = {
		{
			id = frSkeletonMan,
			x = -454.75,
			y = -68.4164,
			z = 9.83986,
			tree = "/Global/Freaks/Skeleton/SkeletonInit"
		},
		{
			id = frBeardedWoman,
			x = -438.877,
			y = -53.691,
			z = 10.55,
			tree = "/Global/Freaks/Bearded/BeardedInit"
		},
		{
			id = frSiamese02,
			x = -450.859,
			y = -37.1411,
			z = 9.80341,
			tree = "/Global/TO_Siamese/SiameseTwinsLoad"
		},
		{
			id = frPaintedMan,
			x = -477.043,
			y = -38.299,
			z = 9.80357,
			tree = "/Global/Freaks/PaintedMan"
		},
		{
			id = frMermaid,
			x = -487.37,
			y = -51.4066,
			z = 10.5,
			tree = "/Global/Freaks/Mermaid/MermaidIdle"
		}
	}
	PedSetInvulnerable(frSkeletonMan, true)
	PedSetInvulnerable(frBeardedWoman, true)
	PedSetInvulnerable(frSiamese02, true)
	PedSetInvulnerable(frPaintedMan, true)
	PedSetInvulnerable(frMermaid, true)
	PedIgnoreStimuli(frSkeletonMan, true)
	PedIgnoreStimuli(frBeardedWoman, true)
	PedIgnoreStimuli(frSiamese02, true)
	PedIgnoreStimuli(frPaintedMan, true)
	PedIgnoreStimuli(frMermaid, true)
	PedSetFaction(frMidget01, 12)
	PedSetFaction(frMidget02, 12)
	gMidgetMaxHealth = PedGetMaxHealth(frMidget01)
	PedSetHealth(frMidget01, gMidgetMaxHealth)
	PedSetHealth(frMidget02, gMidgetMaxHealth)
	PedSetMaxHealth(frMidget01, gMidgetMaxHealth)
	PedSetMaxHealth(frMidget02, gMidgetMaxHealth)
	PedSetMinHealth(frMidget01, gMidgetMaxHealth)
	PedSetMinHealth(frMidget02, gMidgetMaxHealth)
	PedSetFlag(frMidget01, 21, false)
	PedSetFlag(frMidget02, 21, false)
	PedSetPedToTypeAttitude(frMidget01, 12, 0)
	PedSetPedToTypeAttitude(frMidget02, 12, 0)
	PedSetPedToTypeAttitude(frMidget01, 13, 3)
	PedSetPedToTypeAttitude(frMidget02, 13, 3)
	PedAddPedToIgnoreList(frMidget01, gPlayer)
	PedAddPedToIgnoreList(frMidget02, gPlayer)
	PedClearAllWeapons(frMidget01)
	PedClearAllWeapons(frMidget02)
	PedOverrideStat(frMidget01, 1, 0)
	PedOverrideStat(frMidget02, 1, 0)
	F_Socialize(frSkeletonMan, true)
	F_Socialize(frBeardedWoman, true)
	F_Socialize(frSiamese02, true)
	F_Socialize(frMidget01, true)
	F_Socialize(frMidget02, true)
	F_Socialize(frPaintedMan, true)
	F_Socialize(frMermaid, true)
	Wait(1000)
	PedSetActionNode(frSiamese02, "/Global/TO_Siamese/SiameseTwinsLoad", "Act/Anim/TO_Siamese.act")
	Wait(10)
	PedSetActionNode(frPaintedMan, "/Global/Freaks/PaintedMan", "Act/Anim/FreakShow.act")
	Wait(10)
	PedSetActionNode(frSkeletonMan, "/Global/Freaks/Skeleton/SkeletonInit", "Act/Anim/FreakShow.act")
	Wait(10)
	PedSetActionNode(frBeardedWoman, "/Global/Freaks/Bearded/BeardedInit", "Act/Anim/FreakShow.act")
	Wait(10)
	PedSetActionNode(frMermaid, "/Global/Freaks/Mermaid/MermaidIdle", "Act/Anim/FreakShow.act")
	Wait(10)
	local gAllPedsStarting = true
	while not (AreaGetVisible() ~= 55 or SystemShouldEndScript()) do
		if IsButtonPressed(0, 0) then
			SoundPlayScriptedSpeechEvent(frSkeletonMan, "FREAK_SHOW", 5)
			Wait(100)
		end
		if gAllPedsStarting then
			gAllPedsStarting = false
			for i, freak in freakList do
				if freak.id then
					gAllPedsStarting = true
					if PlayerIsInAreaXYZ(freak.x, freak.y, freak.z, 10, 0) then
						--print("SETTING FREAK - ", i)
						if freak.act then
							PedSetActionNode(freak.id, freak.tree, freak.act)
						else
							PedSetActionNode(freak.id, freak.tree, "Act/Anim/FreakShow.act")
						end
						freak.id = nil
					end
				end
			end
		end
		if gFightGoing then
			F_MonitorFight()
		elseif 0 < PlayerGetMoney() and PlayerIsInAreaXYZ(-466.2011, -42.3588, 9.7998, 1, 7) then
			F_Betting()
		end
		if not gMidgetFight and PlayerIsInTrigger(TRIGGER._FREAKSHOW_MIDGETS) then
			--print("Setting their health in 142")
			F_Midgets(true)
			PedSetHealth(frMidget01, gMidgetMaxHealth)
			PedSetHealth(frMidget02, gMidgetMaxHealth)
			gMidgetFight = true
		elseif gMidgetFight and not PlayerIsInTrigger(TRIGGER._FREAKSHOW_MIDGETS) then
			if gFightGoing then
				gFightGoing = false
				PedHideHealthBar()
				PlayerAddMoney(gCurrentBet, false)
			end
			F_Midgets(false)
			gMidgetFight = false
		end
		Wait(0)
	end
	ToggleHUDComponentVisibility(5, true)
	PedDelete(frSkeletonMan)
	PedDelete(frBeardedWoman)
	PedDelete(frSiamese02)
	PedDelete(frMidget01)
	PedDelete(frMidget02)
	PedDelete(frPaintedMan)
	PedDelete(frMermaid)
	UnLoadAnimationGroup("Mermaid")
	UnLoadAnimationGroup("Jv_Asylum")
	UnLoadAnimationGroup("Siamese2")
	UnLoadAnimationGroup("SIAMESE")
	UnLoadAnimationGroup("SkeltonMan")
	UnLoadAnimationGroup("BeardLady")
	DATUnload(0)
	F_MakePlayerSafeForNIS(false)
	shared.gAreaDataLoaded = false
	shared.gAreaDATFileLoaded[55] = false
	collectgarbage()
end

function F_MonitorFight()
	local deadMidget
	local gPlayerWon = false
	if gCurrentMidget == 1 then
		if PedIsDead(frMidget02) or PedGetHealth(frMidget02) <= 0 then
			deadMidget = 2
			gFightGoing = false
			gPlayerWon = true
		elseif PedIsDead(frMidget01) or PedGetHealth(frMidget01) <= 0 then
			deadMidget = 1
			gFightGoing = false
		end
	elseif gCurrentMidget == 2 then
		if PedIsDead(frMidget01) or PedGetHealth(frMidget01) <= 0 then
			deadMidget = 1
			gPlayerWon = true
			gFightGoing = false
		elseif PedIsDead(frMidget02) or PedGetHealth(frMidget02) <= 0 then
			deadMidget = 2
			gFightGoing = false
		end
	end
	if not gFightGoing then
		PlayerSetControl(0)
		if gPlayerWon then
			TextPrint("MIF_BET03", 3, 1)
			PlayerAddMoney(gCurrentBet * 2, false)
		else
			TextPrint("MIF_BET04", 3, 1)
		end
		Wait(2000)
		CameraFade(1000, 0)
		Wait(1001)
		if deadMidget == 2 then
			if frMidget02 then
				PedDelete(frMidget02)
			end
			frMidget02 = PedCreatePoint(189, POINTLIST._FRS_MIDGET02)
		elseif deadMidget == 1 then
			if frMidget01 then
				PedDelete(frMidget01)
			end
			frMidget01 = PedCreatePoint(188, POINTLIST._FRS_MIDGET01)
		end
		PedHideHealthBar()
		PedClearAllWeapons(frMidget01)
		PedClearAllWeapons(frMidget02)
		PedSetHealth(frMidget01, gMidgetMaxHealth)
		PedSetHealth(frMidget02, gMidgetMaxHealth)
		PedSetMinHealth(frMidget01, gMidgetMaxHealth)
		PedSetMinHealth(frMidget02, gMidgetMaxHealth)
		Wait(500)
		F_Midgets(true)
		PlayerSetControl(1)
		CameraFade(1000, 1)
	end
end

function F_Betting()
	TextPrint("BUT_BETS", 1, 2)
	if IsButtonPressed(9, 0) then
		PlayerSetControl(0)
		CameraFade(500, 0)
		F_MakePlayerSafeForNIS(true, true)
		if not MissionActive() and not ClockIsPaused() and not IsMissionAvailable("3_08") and not IsMissionAvailable("6_01") then
			PauseGameClock()
			gPausedGameClock = true
		end
		F_Midgets(false)
		Wait(1000)
		F_Midgets(false)
		PedStop(frMidget01)
		PedStop(frMidget02)
		PedClearObjectives(frMidget01)
		PedClearObjectives(frMidget02)
		PedSetPosPoint(frMidget01, POINTLIST._FRS_MIDGETCHOOSE, 1)
		PedSetPosPoint(frMidget02, POINTLIST._FRS_MIDGETCHOOSE, 2)
		PedSetActionNode(frMidget01, "/Global/Freaks/Midgets/CyclicIdle", "Act/Anim/FreakShow.act")
		PedSetActionNode(frMidget02, "/Global/Freaks/Midgets/CyclicIdle", "Act/Anim/FreakShow.act")
		TutorialShowMessage("MIF_BET01")
		gMidgetBlip = BlipAddPoint(POINTLIST._FRS_MIDGETCHOOSE, 2, 1, 0, 7)
		gCurrentMidget = 1
		bWaiting = true
		CameraFade(500, 1)
		CameraLookAtXYZ(-463.79413, -44.985256, 11.479783, true)
		CameraSetXYZ(-464.02594, -43.781612, 12.019781, -463.79413, -44.985256, 11.479783)
		CameraLookAtObject(frMidget01, 2, false)
		gCurrentBet = 100
		gCurrentAmount = PlayerGetMoney()
		--print("PLAYER HAS MONEY:", gCurrentAmount)
		Wait(200)
		while bWaiting do
			PedFaceHeading(frMidget01, 0, 0)
			PedFaceHeading(frMidget02, 0, 0)
			TextAddParamNum(gCurrentBet)
			TextPrint("MIF_BET02", 1, 2)
			WaitSkippable(1)
			if (GetStickValue(16, 0) > 0.5 or IsButtonPressed(0, 0)) and gCurrentMidget == 2 then
				PedSetActionNode(frMidget01, "/Global/Freaks/Midgets/Select", "Act/Anim/FreakShow.act")
				PedSetActionNode(frMidget02, "/Global/Freaks/Midgets/Deselect", "Act/Anim/FreakShow.act")
				gCurrentMidget = 1
				BlipRemove(gMidgetBlip)
				CameraLookAtObject(frMidget01, 2, false)
				gMidgetBlip = BlipAddPoint(POINTLIST._FRS_MIDGETCHOOSE, 2, 1, 0, 7)
				--print("adding midgetblip 1")
			end
			if (GetStickValue(16, 0) < -0.5 or IsButtonPressed(1, 0)) and gCurrentMidget == 1 then
				PedSetActionNode(frMidget02, "/Global/Freaks/Midgets/Select", "Act/Anim/FreakShow.act")
				PedSetActionNode(frMidget01, "/Global/Freaks/Midgets/Deselect", "Act/Anim/FreakShow.act")
				gCurrentMidget = 2
				BlipRemove(gMidgetBlip)
				gMidgetBlip = BlipAddPoint(POINTLIST._FRS_MIDGETCHOOSE, 2, 2, 0, 7)
				CameraLookAtObject(frMidget02, 2, false)
				--print("adding midgetblip 2")
			end
			if -0.5 > GetStickValue(17, 0) or IsButtonPressed(3, 0) then
				gCurrentBet = gCurrentBet - 100
				if gCurrentBet < 100 then
					gCurrentBet = 100
					SoundPlay2D("NavInvalid")
				else
					SoundPlay2D("NavDwn")
				end
				Wait(50)
			end
			if 0.5 < GetStickValue(17, 0) or IsButtonPressed(2, 0) then
				gCurrentBet = gCurrentBet + 100
				if gCurrentBet > 10000 then
					gCurrentBet = 10000
					SoundPlay2D("NavInvalid")
				elseif gCurrentBet > gCurrentAmount then
					gCurrentBet = gCurrentAmount
					SoundPlay2D("NavInvalid")
				else
					SoundPlay2D("NavUp")
				end
				Wait(50)
			end
			if PedIsHit(gPlayer, 3, 1000) then
				gFightGoing = false
				bWaiting = false
				PedSetHealth(frMidget01, gMidgetMaxHealth)
				PedSetHealth(frMidget02, gMidgetMaxHealth)
				CameraReturnToPlayer()
			end
			if IsButtonPressed(8, 0) then
				gFightGoing = false
				bWaiting = false
				PedSetHealth(frMidget01, gMidgetMaxHealth)
				PedSetHealth(frMidget02, gMidgetMaxHealth)
				PedSetMinHealth(frMidget01, 100)
				PedSetMinHealth(frMidget02, 100)
				CameraReturnToPlayer()
			elseif IsButtonPressed(7, 0) then
				PlayerAddMoney(-gCurrentBet, false)
				SoundPlay2D("BuyItem")
				gFightGoing = true
				if gCurrentMidget == 1 then
					PedShowHealthBar(frMidget02, true, "N_Zeke", true)
				else
					PedShowHealthBar(frMidget01, true, "N_Lightning", true)
				end
				PedSetHealth(frMidget01, gMidgetMaxHealth)
				PedSetHealth(frMidget02, gMidgetMaxHealth)
				PedSetMinHealth(frMidget01, -1)
				PedSetMinHealth(frMidget02, -1)
				bWaiting = false
				PedFaceObject(gPlayer, frMidget01, 2, 0)
				CameraReturnToPlayer()
			end
		end
		BlipRemove(gMidgetBlip)
		PedSetActionNode(frMidget01, "/Global/Freaks/Break", "Act/Anim/FreakShow.act")
		PedSetActionNode(frMidget02, "/Global/Freaks/Break", "Act/Anim/FreakShow.act")
		F_Midgets(true)
		TutorialRemoveMessage()
		F_MakePlayerSafeForNIS(false, true)
		PlayerSetControl(1)
		if gPausedGameClock and not MissionActive() and not IsMissionAvailable("3_08") and not IsMissionAvailable("6_01") then
			UnpauseGameClock()
		end
		Wait(500)
	end
end

function F_Midgets(attack)
	if not PedIsValid(frMidget02) or PedIsDead(frMidget02) then
		if PedIsValid(frMidget02) then
			PedDelete(frMidget02)
		end
		frMidget02 = PedCreatePoint(189, POINTLIST._FRS_MIDGET02)
		PedClearAllWeapons(frMidget02)
		PedSetHealth(frMidget02, gMidgetMaxHealth)
		PedSetMinHealth(frMidget02, gMidgetMaxHealth)
	end
	if not PedIsValid(frMidget01) or PedIsDead(frMidget01) then
		if PedIsValid(frMidget01) then
			PedDelete(frMidget01)
		end
		frMidget01 = PedCreatePoint(188, POINTLIST._FRS_MIDGET01)
		PedClearAllWeapons(frMidget01)
		PedSetHealth(frMidget01, gMidgetMaxHealth)
		PedSetMinHealth(frMidget01, gMidgetMaxHealth)
	end
	if attack then
		PedSetPedToTypeAttitude(frMidget01, 12, 0)
		PedSetPedToTypeAttitude(frMidget02, 12, 0)
		PedAttack(frMidget01, frMidget02, 3, true)
		PedAttack(frMidget02, frMidget01, 3, true)
	else
		PedClearObjectives(frMidget01)
		PedClearObjectives(frMidget02)
		PedSetPedToTypeAttitude(frMidget01, 12, 2)
		PedSetPedToTypeAttitude(frMidget02, 12, 2)
		PedStop(frMidget01)
		PedStop(frMidget02)
	end
end

function F_Socialize(pedId, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 23, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 24, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 25, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 26, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 27, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 28, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 29, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 30, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 31, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 32, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 33, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 34, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 35, bDisable)
	PlayerSocialDisableActionAgainstPed(pedId, 36, bDisable)
end

function F_SetupDockers()
	local FSSpawner = AreaAddAmbientSpawner(2, 1, 2000, 5000)
	local FSDocker = AreaAddDocker(2, 1)
	AreaAddSpawnLocation(FSSpawner, POINTLIST._FREAKSHOW_ENTRANCE, TRIGGER._DT_FREAKSHOW_ENTRANCE)
	AreaAddDockLocation(FSDocker, POINTLIST._FREAKSHOW_ENTRANCE, TRIGGER._DT_FREAKSHOW_ENTRANCE)
	AreaAddSpawnLocation(FSSpawner, POINTLIST._FREAKSHOW_EXIT, TRIGGER._DT_FREAKSHOW_EXIT)
	AreaAddDockLocation(FSDocker, POINTLIST._FREAKSHOW_EXIT, TRIGGER._DT_FREAKSHOW_EXIT)
	AreaAddAmbientSpawnPeriod(FSSpawner, 7, 20, 720)
	AreaAddDockPeriod(FSDocker, 7, 20, 720)
	DockerSetMinimumRange(FSDocker, 1)
	DockerSetMaximumRange(FSDocker, 10)
	DockerSetUseFacingCheck(FSDocker, true)
end
