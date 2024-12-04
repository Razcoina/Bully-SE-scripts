local x, y, z, idTeacher

function main()
	F_CreatePeds()
	while not (IsButtonPressed(12, 0) or IsButtonPressed(10, 0)) do
		Wait(0)
	end
	MissionSucceed()
end

function F_CreatePeds()
	PedSocialOverrideLoad(24, "Mission/2_S05WantGift.act")
	PedSocialOverrideLoad(4, "Mission/2_S05Follow.act")
	idTeacher = PedCreatePoint(63, POINTLIST._4324_TEACHER, 1)
	PedUseSocialOverride(idTeacher, 24)
	PedUseSocialOverride(idTeacher, 4)
	PlayerSocialDisableActionAgainstPed(idTeacher, 28, true)
	PlayerSocialDisableActionAgainstPed(idTeacher, 29, true)
	PedSetPedToTypeAttitude(idTeacher, 13, 3)
	PedSetEmotionTowardsPed(idTeacher, gPlayer, 7)
	PedOverrideSocialResponseToStimulus(idTeacher, 10, 24)
	PedSetRequiredGift(idTeacher, 1, false, true)
end

function MissionCleanup()
	DATUnload(2)
end

function MissionSetup()
	DATLoad("SocialAuthority.DAT", 2)
	AreaTransitionPoint(22, POINTLIST._4324_PLAYERSTART, 1)
	ItemSetCurrentNum(478, 5)
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	VehicleOverrideAmbient(0, 0, 0, 0)
end

function socFollow()
	TextPrintString("I RECEIVED THE GIFT!", 4, 1)
end
