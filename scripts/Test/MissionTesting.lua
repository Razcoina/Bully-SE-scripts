local gMissions = {
	"1_01",
	"1_03",
	"1_04",
	"1_05",
	"1_07",
	"1_08",
	"1_09",
	"1_10",
	"1_11"
}

function waitForStreaming()
	while IsStreamingBusy() do
		Wait(500)
	end
end

function main()
	for i, missionName in gMissions do
		Wait(1000)
		--print("MissionTesting: Starting mission", missionName)
		ForceStartMission(missionName)
		repeat
			waitForStreaming()
			Wait(2000)
			StopCutscene()
		until MissionGetCurrentName() ~= nil
		repeat
			if GetCutsceneRunning() then
				print("MissionTesting: Stopping cutscene(s)")
				StopCutscene()
				waitForStreaming()
			end
			Wait(5000)
			--print("MissionTesting: Succeed mission", MissionGetCurrentName())
			MissionSucceed()
			waitForStreaming()
			Wait(500)
			--print("MissionTesting: Wait for mission", MissionGetCurrentName(), "to clean up and end")
		until MissionGetCurrentName() == nil
		Wait(1000)
	end
	--print("Mission testing script finished.")
	Quit()
end
