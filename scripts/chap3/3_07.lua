local gMissionRunning = true

function MissionSetup()
	SplashScreenDisplay("Chapter2", "Chapter2")
	CameraFade(500, 1)
	Wait(2500)
	CameraFade(500, 0)
	Wait(500)
	SplashScreenDisable()
	LoadAnimationGroup("Hang_Talking")
	DATLoad("3_07.DAT", 2)
	DATInit()
	AreaTransitionPoint(14, POINTLIST._3_07_PLAYER_SPAWN, 1)
end

function main()
	Pedro = PedCreatePoint(69, POINTLIST._3_07_PEDRO)
	Justin = PedCreatePoint(34, POINTLIST._3_07_JUSTIN)
	Trevor = PedCreatePoint(73, POINTLIST._3_07_TREVOR)
	while not PlayerIsInTrigger(TRIGGER._3_07_STARTCONV) do
		Wait(0)
	end
	F_ChristmasChat()
	PedSetActionNode(Pedro, "/Global/Animations/Listening", "Act/Conv/3_07.act")
	PedSetActionNode(Justin, "/Global/Animations/Talking", "Act/Conv/3_07.act")
	PedSetActionNode(Trevor, "/Global/Animations/Listening", "Act/Conv/3_07.act")
	while gMissionRunning do
		UpdateTextQueue()
		if PedIsHit(Pedro, 2, 1000) then
			gMissionRunning = false
		end
		if PedIsHit(Justin, 2, 1000) then
			gMissionRunning = false
		end
		if PedIsHit(Trevor, 2, 1000) then
			gMissionRunning = false
		end
		if AreaGetVisible() == 0 then
			gMissionRunning = false
		end
		Wait(0)
	end
	ClearTextQueue()
	PedSetActionNode(Pedro, "/Global/AI", "Act/AI/AI.act")
	PedSetActionNode(Justin, "/Global/AI", "Act/AI/AI.act")
	PedSetActionNode(Trevor, "/Global/AI", "Act/AI/AI.act")
	PedMakeAmbient(Pedro)
	PedMakeAmbient(Justin)
	PedMakeAmbient(Trevor)
	PlayerSetScriptSavedData(17, 1)
	SoundPlayMissionEndMusic(true, 10)
	MissionSucceed()
end

function MissionCleanup()
	DATUnload(2)
	UnLoadAnimationGroup("Hang_Talking")
end

function F_ChristmasChat()
	QueueText("3_07_Speech01", 3, 2, false)
	QueueText("3_07_Speech02", 3, 2, false)
	QueueText("3_07_Speech03", 3, 2, false)
	QueueText("3_07_Speech04", 5, 2, false)
	QueueText("3_07_Speech05", 5, 2, false)
	QueueText("3_07_Speech06", 3, 2, false, CB_ENDIT)
end

function CB_ENDIT()
	Wait(3000)
	gMissionRunning = false
end
