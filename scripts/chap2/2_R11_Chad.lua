ImportScript("chap2/Boxing_util.lua")
local noPass = 1

function MissionSetup()
	MissionDontFadeIn()
end

function MissionCleanup()
	NonMissionPedGenerationEnable()
	BoxingMissionCleanup()
end

function main()
	while not bStageLoaded do
		Wait(0)
	end
	NonMissionPedGenerationDisable()
	if 4 < noPass then
		BoxingSetRandom()
	else
		BoxingSetOpponent(noPass + 1)
	end
	BoxingMissionSetup(false)
	BoxingMissionControl()
end

function F_SetStage(param)
	noPass = param
	if shared.PrepVendettaRunning then
		noPass = shared.PrepVendettaRunning
	end
	bStageLoaded = true
end
