function waitForStreaming()
    while IsStreamingBusy() do
        Wait(500)
    end
end

function RunMission(missionName)
    Wait(500)
    --print("MissionTesting: Starting mission", missionName)
    ForceStartMission(missionName)
    repeat
        waitForStreaming()
        Wait(500)
        StopCutscene()
    until MissionGetCurrentName() ~= nil
    local did_heap_dump = false
    repeat
        if GetCutsceneRunning() then
            print("MissionTesting: Stopping cutscene(s)")
            StopCutscene()
            waitForStreaming()
        end
        Wait(500)
        if not did_heap_dump and DoRemoteXmlHeapDump ~= nil then
            DoRemoteXmlHeapDump(missionName .. ".xml")
            did_heap_dump = true
        end
        --print("MissionTesting: Succeed mission", MissionGetCurrentName())
        MissionSucceed()
        waitForStreaming()
        Wait(250)
        --print("MissionTesting: Wait for mission", MissionGetCurrentName(), "to clean up and end")
    until MissionGetCurrentName() == nil
    Wait(500)
    --print("Mission testing script finished.")
    Quit()
end
