function MissionSetup()
	LoadCutscene("CS_COUNTER")
	AreaAddExtraScene(270, -100, true, true, true, 0, 10)
	while IsStreamingBusy() do
		Wait(50)
	end
end

function MissionCleanup()
	StopCutscene()
end

function main()
	StartCutscene()
	while GetCutsceneTime() < 89466 do
		Wait(50)
	end
	SoundPlayMissionEndMusic(true, 10)
	MissionSucceed()
	AreaRemoveExtraScene()
end
