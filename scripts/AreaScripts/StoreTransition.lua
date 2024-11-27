function main()
	local tp = shared.storeTransition
	AreaTransitionXYZ(tp[1], tp[2], tp[3], tp[4])
	Wait(100)
	PlayerSetControl(1)
	shared.storeTransition = nil
end
