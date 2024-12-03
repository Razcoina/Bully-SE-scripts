local bSuccess = false
local destBlip
local gPAAnnouncementTimer = 0
local gCurrentArea
local bGetOutOfBed = false
local bPlayerGoToPrincipal = false
local bDebug = false

function MissionSetup()
	DATLoad("6_01.DAT", 2)
	DATLoad("3_08.DAT", 2)
	MissionSurpressMissionNameText()
	MissionDontFadeIn()
end

function main()
	PlayCutsceneWithLoad("6-0", true, true)
	if ClothingGetPlayer(1) == ObjectNameToHashID("S_Sweater5") then
		ClothingSetPlayer(1, "B_Jacket6")
	end
	if ClothingGetPlayer(4) == ObjectNameToHashID("S_Pants1") then
		ClothingSetPlayer(4, "B_Pants2")
	end
	ClothingBuildPlayer()
	AreaTransitionPoint(14, POINTLIST._6_01_BDORM, 1, false)
	CameraReset()
	CameraReturnToPlayer()
	CameraFade(500, 1)
	Wait(501)
	TextPrint("6_01_EXPELLED", 4, 1)
	shared.gPlayerInitialArea = nil
	MissionSucceed(false, false, false)
end

function MissionCleanup()
	if bSuccess then
		PlayerSetScriptSavedData(3, PlayerGetNumTimesBusted())
		PlayerSetScriptSavedData(14, 0)
	end
	UnpauseGameClock()
	CameraSetWidescreen(false)
	DATUnload(2)
end

function F_PlayerGetOutOfBed()
	--print("WTF???!?!?!")
	if bGetOutOfBed then
		return 1
	end
	return 0
end
