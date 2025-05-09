local missionName

function MissionSetup()
end

function MissionCleanup()
end

function main()
    local missionName = MissionGetCurrentName()
    if string.find(missionName, "Rich Area 1") then
        shared.g3_R08_CurrentRace = 0
        TextPrint("GOTO_RACERICH1", 3, 1)
    elseif string.find(missionName, "Rich Area 2") then
        shared.g3_R08_CurrentRace = 1
        TextPrint("GOTO_RACERICH2", 3, 1)
    elseif string.find(missionName, "Business") then
        shared.g3_R08_CurrentRace = 2
        TextPrint("GOTO_RACEBUSINESS", 3, 1)
    elseif string.find(missionName, "Poor") then
        shared.g3_R08_CurrentRace = 3
        TextPrint("GOTO_RACEPOOR", 3, 1)
    elseif string.find(missionName, "School") then
        shared.g3_R08_CurrentRace = 4
        TextPrint("GOTO_RACESCHOOL", 3, 1)
    end
    SoundPlayMissionEndMusic(true, 10)
    MissionSucceed()
end
