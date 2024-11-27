function main()
	AreaTransitionPoint(0, POINTLIST._BIKE_START)

	Wait(1000)
	shared.gSkippedWeedKiller = true
	AreaTransitionPoint(14, POINTLIST._BOYSDORM_BEDWAKEUP)
	Wait(1000)
	MissionSucceed()
end

function MissionSetup()
	MissionDontFadeIn()
end

function MissionCleanup()
end
