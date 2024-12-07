--[[ Changes to this file:
	* Basically had to rewrite the entire thing. Definitely requires testing
]]

-- ! I can only guess local variable names
local CowAct = "Act/Anim/Ambient.act"
local CowTriangle = "/Global/Ambient/Scripted/CowDance/Animation/Triangle/Triangle"
local CowCircle = "/Global/Ambient/Scripted/CowDance/Animation/Circle/Circle"
local CowSquare = "/Global/Ambient/Scripted/CowDance/Animation/Square/Square"
local CowCross = "/Global/Ambient/Scripted/CowDance/Animation/Cross/Cross"
local CowIdle = "/Global/Ambient/Scripted/CowDance/Animation/CustomIdle"
local CowBotch = "/Global/Ambient/Scripted/CowDance/Animation/Botch"
local CowFail = "/Global/Ambient/Scripted/CowDance/Animation/Failure"
local CowPass = "/Global/Ambient/Scripted/CowDance/Animation/Success"
local CowMusicStart = "/Global/Ambient/Scripted/CowDance/CowDanceMusicStart"
local CowMusicStop = "/Global/Ambient/Scripted/CowDance/CowDanceMusicStop"
local CowButtonScrewedAttempts = 0
local CowLastAnim = 0
local PlayerClothes = 0
local tblMoves = {}
local gbFailed = false
local AnimSeq = {
	3,
	1,
	2,
	0
}

function F_CowDanceInit()
	tblMoves = {}
	local move
	for i = 1, 8 do
		move = F_GetMove(move, 0)
		table.insert(tblMoves, move)
	end
	for key, value in tblMoves do
		if key == 1 then
			ClassChemAddAction(0, value, 1.1, 0.5)
		else
			ClassChemAddAction(0, value, 1, 0.5)
		end
	end
end

function F_GetMove(tbl, CurIndex)
	local move = RandomTableElement(AnimSeq)
	if move == tbl then
		CurIndex = CurIndex + 1
		if 4 <= CurIndex then
			if tbl == 3 then
				move = 1
			else
				move = 3
			end
		else
			move = F_GetMove(tbl, CurIndex)
		end
	end
	return move
end

function F_DoMove(move)
	if move == 3 then
		PedSetActionNode(gPlayer, CowTriangle, CowAct)
	elseif move == 1 then
		PedSetActionNode(gPlayer, CowCircle, CowAct)
	elseif move == 2 then
		PedSetActionNode(gPlayer, CowSquare, CowAct)
	elseif move == 0 then
		PedSetActionNode(gPlayer, CowCross, CowAct)
	end
	move = 0
end

function F_KillCow()
end

function F_DanceCowDance()
	shared.forceCowDanceEnd = nil
	while true do
		if bDanceThatCow then
			MinigameCreate("CHEM", false)
			StatAddToInt(15)
			while MinigameIsReady() == false do
				Wait(0)
			end
			MinigameStart()
			ToggleHUDComponentVisibility(20, false)
			ClassChemSetGameType("OTHER")
			MinigameEnableHUD(true)
			ClassChemSetActiveActions(1)
			TextPrint("4_06_CD04", 3, 1)
			PedMakeTargetable(gPlayer, false)
			CowButtonScrewedAttempts = 0
			PedSetActionNode(gPlayer, "/Global/Ambient/Scripted/CowDance/CowDanceMusicStart", CowAct)
			PedSetActionNode(gPlayer, CowIdle, CowAct)
			Wait(1000)
			PedSetActionNode(gPlayer, CowIdle, CowAct)
			F_CowDanceInit()
			local NumOfElements = table.getn(tblMoves)
			local MIndex = 1
			ClassChemSetScrollyOnly(true)
			ClassChemStartSeq(0)
			SoundLoopPlay2D("CowDanceMusic", true)
			--print("===== Starting Up Cow Dance ======")
			PedSetFlag(gPlayer, 13, true)
			PedSetInvulnerable(gPlayer, true)
			while MinigameIsActive() do
				PlayerClothes = ClothingGetPlayer(0)
				if PlayerClothes ~= ObjectNameToHashID("SP_Mascot_H") then
					PedSetActionNode(gPlayer, "/Global/Ambient/Scripted/CowDance/CowDanceMusicStop", CowAct)
					while PedIsPlaying(gPlayer, "/Global/Ambient/Scripted/CowDance/CowDanceMusicStop", false) do
						Wait(0)
					end
					MinigameDestroy(false)
					break
				end
				if NumOfElements > MIndex then
					if ClassChemGetActionJustFinished(tblMoves[MIndex]) then
						F_DoMove(tblMoves[MIndex])
						MIndex = MIndex + 1
					elseif ClassChemGetActionJustFailed(tblMoves[MIndex]) then
						CowButtonScrewedAttempts = CowButtonScrewedAttempts + 1
						PedSetActionNode(gPlayer, CowBotch, CowAct)
						MIndex = MIndex + 1
					end
				end
				if shared.forceCowDanceEnd then
					shared.forceCowDanceEnd = nil
					--print("ENDING COW DANCE IN THE SHARED FORCED END")
					MinigameDestroy(false)
					--break
				end
				if PedIsPlaying(gPlayer, "/Global/Actions/Grapples", true) or 0 >= PlayerGetHealth() then
					--print("ENDING COW DANCE DUE TO GRAPPLING")
					shared.forceCowDanceEnd = true
					MinigameDestroy(false)
					--break
				end
				if CowButtonScrewedAttempts == 3 then
					MinigameEnd()
					shared.forceCowDanceEnd = nil
				end
				Wait(0)
			end
			PedSetInvulnerable(gPlayer, false)
			PedSetFlag(gPlayer, 13, false)
			SoundLoopPlay2D("CowDanceMusic", false)
			PedMakeTargetable(gPlayer, true)
			ToggleHUDComponentVisibility(20, true)
			if MinigameIsReady() then
				if MinigameIsSuccess() then
					gPlayerWon = true
				else
					gPlayerWon = false
				end
				if gPlayerWon then
					PedSetActionNode(gPlayer, CowPass, CowAct)
					TextPrint("4_06_CD05", 3, 1)
					CowLastAnim = CowPass
					StatAddToInt(16)
				else
					PedSetActionNode(gPlayer, CowFail, CowAct)
					TextPrint("4_06_CD06", 3, 1)
					CowLastAnim = CowFail
				end
				Wait(1000)
				while PedIsPlaying(gPlayer, CowLastAnim, false) do
					Wait(0)
				end
				Wait(250)
				MinigameDestroy(false)
			end
			PedSetActionNode(gPlayer, "/Global/Ambient/Scripted/Empty/EmptyNode/TrueEmptyNode", "Act/Anim/Ambient.act")
			--print("===== Shutting Down Cow Dance ======")
			UnLoadAnimationGroup("NPC_MASCOT")
			bDanceThatCow = false
		end
		Wait(0)
	end
end

-- ? Original file, all the way to the end:
--[[ -- ? Original variables (from Wii)
local CowAct = "Act/Anim/Ambient.act"
local CowAnim = "/Global/Ambient/Scripted/CowDance/"
local CowIdle = "Animation/CustomIdle"
local CowBotch = "Animation/Botch"
local CowFail = "Animation/Failure"
local CowPass = "Animation/Success"
local CowMusicStart = "CowDanceMusicStart"
local CowMusicStop = "CowDanceMusicStop"
local CowButtonScrewedAttempts = 0
local CowLastAnim = 0
local bButtonPressed = false
local tWait = 0.5
local gbFailed = false
local longWin = 2
local shortWin = 1
local introWin = 0.5
local AnimSeq1 = {
	{
		waitTime = tWait,
		windowTime = introWin,
		act = 18,
		Anim = "None",
		Point = false
	},
	{
		waitTime = 0,
		windowTime = longWin,
		act = 18,
		Anim = "Animation/Triangle/Triangle",
		Point = true
	},
	{
		waitTime = 0,
		windowTime = shortWin,
		act = 22,
		Anim = "None",
		Point = false
	}
}
local AnimSeq2 = {
	{
		waitTime = tWait,
		windowTime = introWin,
		act = 2,
		Anim = "None",
		Point = false
	},
	{
		waitTime = 0,
		windowTime = longWin,
		act = 2,
		Anim = "Animation/Circle/Circle",
		Point = true
	},
	{
		waitTime = 0,
		windowTime = shortWin,
		act = 22,
		Anim = "None",
		Point = false
	}
}
local AnimSeq3 = {
	{
		waitTime = tWait,
		windowTime = introWin,
		act = 1,
		Anim = "None",
		Point = false
	},
	{
		waitTime = 0,
		windowTime = longWin,
		act = 1,
		Anim = "Animation/Square/Square",
		Point = true
	},
	{
		waitTime = 0,
		windowTime = shortWin,
		act = 22,
		Anim = "None",
		Point = false
	}
}
local AnimSeq4 = {
	{
		waitTime = tWait,
		windowTime = introWin,
		act = 19,
		Anim = "None",
		Point = false
	},
	{
		waitTime = 0,
		windowTime = longWin,
		act = 19,
		Anim = "Animation/Cross/Cross",
		Point = true
	},
	{
		waitTime = 0,
		windowTime = shortWin,
		act = 22,
		Anim = "None",
		Point = false
	}
}
local AnimSeq = {
	AnimSeq1,
	AnimSeq2,
	AnimSeq3,
	AnimSeq4
}
local tblMoves = {}
tblMoveSet = {
	{
		1,
		2,
		3,
		4,
		1,
		2,
		3,
		4
	},
	{
		2,
		4,
		3,
		1,
		2,
		4,
		3,
		1
	},
	{
		3,
		1,
		2,
		4,
		3,
		1,
		2,
		4
	},
	{
		4,
		3,
		2,
		1,
		4,
		3,
		2,
		1
	}
}
local MIndex = 1
]] -- So different I might as well start all over

-- ? Multiline comment doesn't work here
--function F_CowDanceInit()
--local move
--move = math.random(1, 4)
--for i = 1, 8 do
--for k = 1, 3 do
--DebugPrint(" current move to Add = " .. AnimSeq[tblMoveSet[move][i]][k].Anim)
--ClassChemAddAction(0, AnimSeq[tblMoveSet[move][i]][k].act, AnimSeq[tblMoveSet[move][i]][k].waitTime, AnimSeq[tblMoveSet[move][i]][k].windowTime, AnimSeq[tblMoveSet[move][i]][k].Point)
--tblMoves[MIndex] = {
--act = AnimSeq[tblMoveSet[move][i]][k].act,
--Anim = AnimSeq[tblMoveSet[move][i]][k].Anim,
--windowTime = AnimSeq[tblMoveSet[move][i]][k].windowTime,
--waitTime = AnimSeq[tblMoveSet[move][i]][k].waitTime
--}
--MIndex = MIndex + 1
--end
--end
--ClassChemAddAction(0, 23, 2, shortWin, false)
--end
-- Not present in original script
--[[
function F_DanceCowDance()
	shared.forceCowDanceEnd = nil
	while true do
		if bDanceThatCow then
			MinigameCreate("CHEM", false)
			while not MinigameIsReady() do
				Wait(0)
			end
			MinigameSetType(2)
			MinigameStart()
			ClassChemSetGameType("COWDANCE")
			MinigameEnableHUD(true)
			F_CowDanceInit()
			StatAddToInt(15)
			ToggleHUDComponentVisibility(20, false)
			MinigameEnableHUD(true)
			TextPrint("4_06_CD04", 3, 1)
			PedMakeTargetable(gPlayer, false)
			CowButtonScrewedAttempts = 0
			PedSetActionNode(gPlayer, CowAnim .. CowMusicStart, CowAct)
			PedSetActionNode(gPlayer, CowAnim .. CowIdle, CowAct)
			Wait(1000)
			ClassChemFeedbackCallback(F_ActionsCallback)
			ClassChemStartSeq(1)
			print("===== Starting Up Cow Dance ======")
			PedSetFlag(gPlayer, 13, true)
			PedSetInvulnerable(gPlayer, true)
			while MinigameIsActive() do
				if ClothingGetPlayer(0) ~= ObjectNameToHashID("SP_Mascot_H") then
					PedSetActionNode(gPlayer, CowAnim .. CowMusicStop, CowAct)
					while PedIsPlaying(gPlayer, CowAnim .. CowMusicStop, false) do
						Wait(0)
					end
					MinigameDestroy(false)
					break
				end
				if shared.forceCowDanceEnd then
					shared.forceCowDanceEnd = nil
					print("ENDING COW DANCE IN THE SHARED FORCED END")
					MinigameDestroy(false)
					break
				end
				if PedIsPlaying(gPlayer, "/Global/Actions/Grapples", true) or 0 >= PlayerGetHealth() then
					print("ENDING COW DANCE DUE TO GRAPPLING")
					shared.forceCowDanceEnd = true
					MinigameDestroy(false)
					break
				end
				if gbFailed == true then
					for index = 1, MIndex - 1 do
						ClassChemResetAction(0, index - 1, tblMoves[index].waitTime, tblMoves[index].windowTime)
					end
					Wait(2000)
					ClassChemStartSeq(1)
					gbFailed = false
				end
				Wait(0)
			end
			PedSetInvulnerable(gPlayer, false)
			PedSetFlag(gPlayer, 13, false)
			PedMakeTargetable(gPlayer, true)
			ToggleHUDComponentVisibility(20, true)
			if MinigameIsReady() then
				if MinigameIsSuccess() then
					PedSetActionNode(gPlayer, CowAnim .. CowPass, CowAct)
					TextPrint("4_06_CD05", 3, 1)
					CowLastAnim = CowAnim .. CowPass
					StatAddToInt(16)
				else
					PedSetActionNode(gPlayer, CowAnim .. CowFail, CowAct)
					TextPrint("4_06_CD06", 3, 1)
					CowLastAnim = CowAnim .. CowFail
				end
				Wait(1000)
				while PedIsPlaying(gPlayer, CowLastAnim, false) do
					Wait(0)
				end
				Wait(250)
				MinigameDestroy(false)
			end
			PedSetActionNode(gPlayer, "/Global/Ambient/Scripted/Empty/EmptyNode/TrueEmptyNode", "Act/Anim/Ambient.act")
			print("===== Shutting Down Cow Dance ======")
			UnLoadAnimationGroup("NPC_MASCOT")
			bDanceThatCow = false
		end
		Wait(0)
	end
end
]] -- Present in original script, but heavily modified

--[[
local num_missed = 1
]] -- Not present in original script

--[[
function F_ActionsCallback(PlayerIndex, cAction, bPass, CurIndex)
	DebugPrint("F_ActionsCallback(): pass:" .. tostring(bPass) .. " " .. tostring(cAction) .. " " .. tostring(CurIndex))
	if bPass then
		if tblMoves[CurIndex].Anim ~= "None" then
			DebugPrint("Actiontree node: " .. CowAnim .. tblMoves[CurIndex].Anim .. " ************************************  " .. CowAct)
			PedSetActionNode(gPlayer, CowAnim .. tblMoves[CurIndex].Anim, CowAct)
		end
	elseif cAction ~= 23 then
		if num_missed < 3 then
			PedSetActionNode(gPlayer, CowAnim .. CowBotch, CowAct)
			gbFailed = true
		else
			PedSetActionNode(gPlayer, CowAnim .. CowFail, CowAct)
			MinigameEnd()
			num_missed = 1
			shared.forceCowDanceEnd = nil
		end
		num_missed = num_missed + 1
	end
end
]] -- Not present in original script

--[[
function F_GetTSize(tbl)
	local NumOfElements = 0
	for i, k in AnimSeq do
		NumOfElements = NumOfElements + 1
	end
	return NumOfElements
end
]] -- Not present in original script
