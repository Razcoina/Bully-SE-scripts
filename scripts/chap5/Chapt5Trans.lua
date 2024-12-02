--[[ Changed to this file:
	* Changed local variables
	* Removed local variables
	* Modified function RollCredits, may require testing
	* Modified function main, may require testing
]]

local gPeds = {}
local gZoe
local bRollTheCredits = false
local bEndCreditsNow = false
local NAME_X_OFFSET = 320
local NAME_Y_OFFSET = 19
--[[
local TITLE_Y_GAP = 30
]] -- Changed to:
local TITLE_Y_GAP = 60
local TITLE_SCALE = 0.75
local NAME_SCALE = 0.6
local TITLE_COL = {
	255,
	255,
	255,
	255
}
local NAME_COL = {
	255,
	255,
	255,
	255
}
local X_TITLEPOS = 50
local Y_TITLEPOS = 400
local TITLE_OFFSCREEN = 30
local TITLE_ONSCREEN = 400
local Y_DEC = 2
local ACTOR_X_OFFSET = 600
local CreditTbl = {}
local bFirstTitle = true
--[[
local ACTOR_INDEX = 41
]] -- Changed to:
local ACTOR_INDEX = 64
--[[
local LONDON_INDEX = 54
local MUSIC_INDEX = 47
]] -- Not present in original script

function RollTitleName(Credit)
	local title, nameString
	if Credit.y < TITLE_OFFSCREEN then
		return false
	end
	Credit.y = Credit.y - Y_DEC
	if Credit.y > TITLE_ONSCREEN then
		return true
	end
	title = "TITLE" .. tostring(Credit.TitleIndex)
	if Credit.y >= TITLE_OFFSCREEN and Credit.y <= TITLE_ONSCREEN and Credit.TitleName == true then
		CreditSetup(TITLE_COL[1], TITLE_COL[2], TITLE_COL[3], TITLE_COL[4], TITLE_SCALE, Credit.Justification)
		CreditPrintText(Credit.x, Credit.y, false, title)
		return true
	end
	local justification, x_offset, split
	nameString = title .. "_NAME" .. tostring(Credit.NameIndex)
	if Credit.TitleName == false and CreditFindText(nameString) then
		CreditSetup(NAME_COL[1], NAME_COL[2], NAME_COL[3], NAME_COL[4], NAME_SCALE, Credit.Justification)
		if Credit.y >= TITLE_OFFSCREEN and Credit.y <= TITLE_ONSCREEN then
			CreditPrintText(Credit.x, Credit.y, false, nameString)
		end
	end
	return true
end

function RollCredits() -- ! Modified
	local xpos, ypos, title, name
	local titleIndex = 0
	local numNames
	local NamesToPrint = 0
	local nameString, characterName
	xpos = X_TITLEPOS
	ypos = Y_TITLEPOS
	title = ""
	while true do
		title = "TITLE" .. tostring(titleIndex)
		if not CreditFindText(title) then
			break
		end
		NamesToPrint = CreditGetInteger(title .. "_NUMNAMES")
		table.insert(CreditTbl, {
			TitleName = true,
			Justification = 2,
			TitleIndex = titleIndex,
			NameIndex = 0,
			x = NAME_X_OFFSET,
			y = ypos
		})
		ypos = ypos + TITLE_Y_GAP
		characterName = true
		for nameIndex = 0, NamesToPrint - 1 do
			xpos = X_TITLEPOS
			if titleIndex == ACTOR_INDEX then
				if characterName then
					table.insert(CreditTbl, {
						TitleName = false,
						Justification = 0,
						TitleIndex = titleIndex,
						NameIndex = nameIndex,
						x = xpos,
						y = ypos
					})
					ypos = ypos + NAME_Y_OFFSET
					characterName = false
				else
					table.insert(CreditTbl, {
						TitleName = false,
						Justification = 1,
						TitleIndex = titleIndex,
						NameIndex = nameIndex,
						x = ACTOR_X_OFFSET,
						y = ypos - NAME_Y_OFFSET
					})
					characterName = true
				end
			else
				table.insert(CreditTbl, {
					TitleName = false,
					Justification = 2,
					TitleIndex = titleIndex,
					NameIndex = nameIndex,
					x = NAME_X_OFFSET,
					y = ypos
				})
				ypos = ypos + NAME_Y_OFFSET
			end
		end
		--[[
		if titleIndex ~= LONDON_INDEX and titleIndex ~= MUSIC_INDEX then
			ypos = ypos + TITLE_Y_GAP
		end
		]] -- Not present in original script
		ypos = ypos + TITLE_Y_GAP
		titleIndex = titleIndex + 1
	end
	while not bRollTheCredits do
		Wait(0)
	end
	local CreditCount
	while not bEndCreditsNow do
		CreditReset()
		CreditCount = 0
		for i, Credit in CreditTbl do
			if RollTitleName(Credit) then
				CreditCount = CreditCount + 1
			end
		end
		if CreditCount == 0 then
			break
		end
		Wait(20)
	end
	bRollTheCredits = false
	--print("credit thread end")
end

function MissionSetup()
	MissionDontFadeIn()
	DATLoad("Chapt5Trans.DAT", 2)
	DATInit()
	LoadActionTree("Act/Conv/Chap5Trans.act")
	LoadAnimationGroup("CHEER_COOL2")
	LoadAnimationGroup("CHEER_NERD1")
	LoadAnimationGroup("CHEER_NERD3")
	LoadAnimationGroup("CHEER_POSH1")
	LoadAnimationGroup("CHEER_POSH3")
	LoadAnimationGroup("CHEER_GEN3")
	LoadAnimationGroup("CHEER_GEN3")
	LoadAnimationGroup("CHEER_GIRL2")
	LoadAnimationGroup("CHEER_GIRL3")
	LoadAnimationGroup("2_06_MOVIETICKETS")
	SoundStopInteractiveStream()
	CreditLoadDB()
	if IsMissionCompleated("C_Engllish_2") then
		LoadAnimationGroup("KISS2")
	elseif IsMissionCompleated("C_Engllish_3") then
		LoadAnimationGroup("KISS3")
	elseif IsMissionCompleated("C_Engllish_4") then
		LoadAnimationGroup("KISS4")
	end
	LoadPedModels({
		63,
		57,
		58,
		19,
		37,
		23,
		91,
		75,
		10,
		14,
		134,
		4,
		74,
		2
	})
	ClockSet(8, 30)
	WeatherSet(4)
	SoundStopCurrentSpeechEvent()
end

function main() -- ! Modified
	SetClipRange(0, 448)
	TITLE_OFFSCREEN = -30
	TITLE_ONSCREEN = 448
	bRollTheCredits = true
	PlayerSetHealth(200)
	PlayerSetPunishmentPoints(0)
	ChapterSet(5)
	AreaTransitionPoint(0, POINTLIST._C5T_PLYR, 1, false)
	AreaActivatePopulationTrigger(TRIGGER._C5T_POP)
	AreaOverridePopulation(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	AreaClearAllPeds()
	local gGalloway = PedCreatePoint(57, POINTLIST._C5T_GALLOWAY, 1)
	local gPhillips = PedCreatePoint(63, POINTLIST._C5T_PHILLIPS, 1)
	local gCafeteria = PedCreatePoint(58, POINTLIST._C5T_CAFETERIA, 1)
	local gTed = PedCreatePoint(19, POINTLIST._C5T_TED, 1)
	local gDarby = PedCreatePoint(37, POINTLIST._C5T_DARBY, 1)
	local gJohnny = PedCreatePoint(23, POINTLIST._C5T_JOHNNY, 1)
	local gEdgar = PedCreatePoint(91, POINTLIST._C5T_EDGAR, 1)
	local gRussell = PedCreatePoint(75, POINTLIST._C5T_RUSSELL, 1)
	local gEarnest = PedCreatePoint(10, POINTLIST._C5T_EARNEST, 1)
	local gMandy = PedCreatePoint(14, POINTLIST._C5T_MANDY, 1)
	local gPeter = PedCreatePoint(134, POINTLIST._C5T_PETER, 1)
	local gAlgernon = PedCreatePoint(4, POINTLIST._C5T_ALGERNON, 1)
	local gFatgirl = PedCreatePoint(74, POINTLIST._C5T_GN_FATGIRL, 1)
	local gZoe = PedCreatePoint(2, POINTLIST._C5T_ZOE, 1)
	local i, ped
	PlayerSetControl(0)
	CameraSetWidescreen(true)
	F_MakePlayerSafeForNIS(true)
	SoundPreloadSpeech(gPlayer, "NARRATION", 120, "supersize", true)
	Wait(100)
	while not SoundIsSpeechPreloaded() do
		Wait(0)
	end
	PedSetActionNode(gPhillips, "/Global/Chap5Trans/Cheering/Cheer_MsPhillips/Cheer_MsPhillips01", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gCafeteria, "/Global/Chap5Trans/Cheering/CheerPosh1/CheerPosh_04", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gTed, "/Global/Chap5Trans/Cheering/CheerCool2/CheerCool08", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gDarby, "/Global/Chap5Trans/Cheering/CheerPosh1/CheerPosh_01", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gJohnny, "/Global/Chap5Trans/Cheering/CheerCool2/CheerCool08", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gEdgar, "/Global/Chap5Trans/Cheering/CheerGen3/CheerGen09", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gRussell, "/Global/Chap5Trans/Cheering/CheerCool2/CheerCool06", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gEarnest, "/Global/Chap5Trans/Cheering/CheerNerd3/CheerNerd_10", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gMandy, "/Global/Chap5Trans/Cheering/CheerGirl2/CheerGirl07", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gPeter, "/Global/Chap5Trans/Cheering/CheerGen3/CheerGen08", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gAlgernon, "/Global/Chap5Trans/Cheering/CheerNerd1/CheerNerd_03", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gFatgirl, "/Global/Chap5Trans/Cheering/CheerGirl3/CheerGirl11", "Act/Conv/Chap5Trans.act")
	PedSetActionNode(gZoe, "/Global/Chap5Trans/Cheering/CheerGirl2/CheerGirl06", "Act/Conv/Chap5Trans.act")
	table.insert(gPeds, { id = gPhillips })
	table.insert(gPeds, { id = gCafeteria })
	table.insert(gPeds, { id = gTed })
	table.insert(gPeds, { id = gDarby })
	table.insert(gPeds, { id = gJohnny })
	table.insert(gPeds, { id = gEdgar })
	table.insert(gPeds, { id = gRussell })
	table.insert(gPeds, { id = gEarnest })
	table.insert(gPeds, { id = gMandy })
	table.insert(gPeds, { id = gPeter })
	table.insert(gPeds, { id = gAlgernon })
	table.insert(gPeds, { id = gFatgirl })
	table.insert(gPeds, { id = gZoe })
	CameraSetFOV(70)
	CameraSetXYZ(224.12473, -73.190994, 8.785095, 223.18439, -73.1228, 9.118213)
	CameraFade(500, 1)
	SoundPlayStream("MS_6B_EndlessSummerCreditsNIS.rsm", 1, 0, 2000)
	Wait(50)
	PedMoveToPoint(gPlayer, 0, POINTLIST._C5T_PLYR, 2)
	Wait(501)
	SoundPlayPreloadedSpeech()
	Wait(50)
	SoundPreloadSpeech(gPlayer, "NARRATION", 121, "supersize", true)
	Wait(50)
	while not SoundIsSpeechPreloaded() do
		Wait(0)
	end
	Wait(2000)
	CameraSetFOV(20)
	CameraSetXYZ(216.30237, -73.20678, 10.896948, 217.27576, -73.207855, 10.672375)
	while SoundSpeechPlaying(gPlayer, "NARRATION", 120, true) do
		Wait(0)
	end
	SoundPlayPreloadedSpeech()
	Wait(1000)
	CameraSetFOV(20)
	CameraSetXYZ(226.7518, -74.58378, 7.517513, 227.74557, -74.48604, 7.542999)
	Wait(1000)
	PedSetActionNode(gZoe, "/Global/Chap5Trans/Blank", "Act/Conv/Chap5Trans.act")
	PedMoveToPoint(gZoe, 2, POINTLIST._C5T_ZOE, 2)
	Wait(750)
	CameraSetFOV(40)
	CameraSetXYZ(216.30237, -73.20678, 10.896948, 217.27576, -73.207855, 10.672375)
	Wait(2000)
	PedSetEmotionTowardsPed(gZoe, gPlayer, 8, true)
	PedSetPedToTypeAttitude(gZoe, gPlayer, 4)
	PedSetFlag(gZoe, 84, true)
	PedLockTarget(gPlayer, gZoe, 3)
	PedLockTarget(gZoe, gPlayer, 3)
	PedSetActionNode(gPlayer, "/Global/Chap5Trans/MakeOut/Makeout/GrappleAttempt", "Act/Player.act")
	Wait(10)
	CameraSetFOV(30)
	CameraSetXYZ(218.36806, -74.2167, 9.846148, 219.08235, -73.52165, 9.927397)
	while not PedIsPlaying(gPlayer, "/Global/Chap5Trans/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
		Wait(0)
	end
	PedStop(gZoe)
	PedClearObjectives(gZoe)
	CreateThread("RollCredits")
	SoundFadeWithCamera(false)
	MusicFadeWithCamera(false)
	while PedIsPlaying(gPlayer, "/Global/Chap5Trans/MakeOut/Makeout/GrappleAttempt/Kisses", true) do
		Wait(0)
	end
	CameraHoldFadeout(true)
	SoundFadeWithCamera(true)
	CameraFade(1000, 0)
	Wait(1001)
	for i, ped in gPeds do
		PedDelete(ped.id)
	end
	while bRollTheCredits do
		Wait(0)
		--[[
		if IsButtonPressed(7, 0) then
			bEndCreditsNow = true
		end
		]] -- Not present in original script
	end
	PlayerSetControl(1)
	SoundStopInteractiveStream(1000)
	Wait(1000)
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	CameraHoldFadeout(false)
	AreaForceLoadAreaByAreaTransition(true)
	AreaTransitionPoint(0, POINTLIST._CST_PLAYEREND, 1, false)
	CameraSetXYZ(95.19139, -68.4279, 9.770363, 96.179184, -68.54063, 9.873886)
	CameraSetWidescreen(true)
	MinigameSetChapterCompletion("Chapt5Message", "Chapt5Name", true, 0)
	MinigameHoldCompletion()
	Wait(500)
	CameraFade(500, 1)
	Wait(501)
	Wait(4000)
	MinigameReleaseCompletion()
	while MinigameIsShowingCompletion() do
		Wait(0)
	end
	CameraFade(500, 0)
	Wait(501)
	CameraSetWidescreen(false)
	CameraReset()
	CameraReturnToPlayer(true)
	AreaTransitionPoint(14, POINTLIST._BOYSDORM_BEDWAKEUP, 1, true)
	AreaForceLoadAreaByAreaTransition(false)
	ClockSet(8, 0)
	Wait(500)
	MissionSucceed(false, false, false)
end

function MissionCleanup()
	SoundFadeWithCamera(true)
	MusicFadeWithCamera(true)
	bEndCreditsNow = true
	SoundStopInteractiveStream()
	if IsMissionCompleated("C_Engllish_2") then
		UnLoadAnimationGroup("KISS2")
	elseif IsMissionCompleated("C_Engllish_3") then
		UnLoadAnimationGroup("KISS3")
	elseif IsMissionCompleated("C_Engllish_4") then
		UnLoadAnimationGroup("KISS4")
	end
	CameraSetWidescreen(false)
	F_MakePlayerSafeForNIS(false)
	PlayerSetScriptSavedData(3, PlayerGetNumTimesBusted())
	PlayerSetScriptSavedData(14, 0)
	CreditUnLoadDB()
end
