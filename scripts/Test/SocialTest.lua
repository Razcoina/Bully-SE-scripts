local x, y, z

function main()
	F_CreatePeds()
	Wait(5000)
	while true do
		Wait(0)
	end
end

function F_FailTheMission()
	--print("FAILED FAILED FAILED!!")
end

function F_CreatePeds()
	Girl1 = PedCreatePoint(67, POINTLIST._PUNISHTEST_P1)
	PedMakeAmbient(Girl1)
	PedSetMissionCritical(Girl1, true, F_FailTheMission, true)
	PedSetEmotionTowardsPed(Girl1, gPlayer, 8, false)
	PedSetRequiredGift(Girl1, 10)
	PlayerSocialDisableActionAgainstPed(Girl1, 28, true)
	GiveItemToPlayer(521)
	Wait(1000)
	Greaser1 = PedCreatePoint(24, POINTLIST._PUNISHTEST_P2)
	PlayerSocialEnableOverrideAgainstPed(Greaser1, 35, true)
	PedSetEmotionTowardsPed(Greaser1, gPlayer, 7, true)
	PedOverrideSocialResponseToStimulus(Greaser1, 9, 10)
	PedRegisterSocialCallback(Greaser1, 10, F_FailTheMission)
	PedAddBroadcastStimulus(5)
end

function MissionCleanup()
end

function MissionSetup()
	x, y, z = -9.988, 21.42, 30.06
	PlayerSetPosXYZArea(x, y, z, 22)
	PlayerFaceHeading(270, 1)
end
