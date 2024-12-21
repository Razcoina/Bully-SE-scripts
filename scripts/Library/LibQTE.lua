--[[ Changes to this file:
	* Modified value of a local variable, may require testing
]]

local myWaitTime = 0.45
local failedSequencesMax = 3
local seq1 = 0
local seq2 = 1
local seq3 = 2
local bUsingTimer = false
--[[
local debugMessages = {
	{
		act = CLASSCHEMACTION_TAP_CROSS,
		name = "_CLASSCHEMACTION_TAP_CROSS"
	},
	{
		act = CLASSCHEMACTION_TAP_CIRCLE,
		name = "_CLASSCHEMACTION_TAP_CIRCLE"
	},
	{
		act = CLASSCHEMACTION_TAP_SQUARE,
		name = "_CLASSCHEMACTION_TAP_SQUARE"
	},
	{
		act = CLASSCHEMACTION_TAP_TRIANGLE,
		name = "_CLASSCHEMACTION_TAP_TRIANGLE"
	},
	{
		act = CLASSCHEMACTION_TAP_L1,
		name = "_CLASSCHEMACTION_TAP_L1"
	},
	{
		act = CLASSCHEMACTION_TAP_L2,
		name = "_CLASSCHEMACTION_TAP_L2"
	},
	{
		act = CLASSCHEMACTION_TAP_L3,
		name = "_CLASSCHEMACTION_TAP_L3"
	},
	{
		act = CLASSCHEMACTION_TAP_R1,
		name = "_CLASSCHEMACTION_TAP_R1"
	},
	{
		act = CLASSCHEMACTION_TAP_R2,
		name = "_CLASSCHEMACTION_TAP_R2"
	},
	{
		act = CLASSCHEMACTION_TAP_R3,
		name = "_CLASSCHEMACTION_TAP_R3"
	},
	{
		act = CLASSCHEMACTION_ROTATE_LSTICK_CW,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CW"
	},
	{
		act = CLASSCHEMACTION_ROTATE_LSTICK_CCW,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CCW"
	},
	{
		act = CLASSCHEMACTION_ROTATE_RSTICK_CW,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CW"
	},
	{
		act = CLASSCHEMACTION_ROTATE_RSTICK_CCW,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CCW"
	},
	{
		act = 23,
		name = "_CLASSCHEMACTION_END"
	},
	{
		act = CLASSCHEMACTION_ROTATE_LSTICK_CW,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CW"
	},
	{
		act = CLASSCHEMACTION_ROTATE_LSTICK_CCW,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CCW"
	},
	{
		act = CLASSCHEMACTION_ROTATE_LSTICK_CW_HALF,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CW_HALF"
	},
	{
		act = CLASSCHEMACTION_ROTATE_LSTICK_CCW_HALF,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CCW_HALF"
	},
	{
		act = CLASSCHEMACTION_ROTATE_LSTICK_CW_QTR,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CW_QTR"
	},
	{
		act = CLASSCHEMACTION_ROTATE_LSTICK_CCW_QTR,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CCW_QTR"
	},
	{
		act = CLASSCHEMACTION_ROTATE_RSTICK_CW,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CW"
	},
	{
		act = CLASSCHEMACTION_ROTATE_RSTICK_CCW,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CCW"
	},
	{
		act = CLASSCHEMACTION_ROTATE_RSTICK_CW_HALF,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CW_HALF"
	},
	{
		act = CLASSCHEMACTION_ROTATE_RSTICK_CCW_HALF,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CCW_HALF"
	},
	{
		act = CLASSCHEMACTION_ROTATE_RSTICK_CW_QTR,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CW_QTR"
	},
	{
		act = CLASSCHEMACTION_ROTATE_RSTICK_CCW_QTR,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CCW_QTR"
	}
}
]] -- Changed to:
local debugMessages = {
	{
		act = 0,
		name = "_CLASSCHEMACTION_TAP_CROSS"
	},
	{
		act = 1,
		name = "_CLASSCHEMACTION_TAP_CIRCLE"
	},
	{
		act = 2,
		name = "_CLASSCHEMACTION_TAP_SQUARE"
	},
	{
		act = 3,
		name = "_CLASSCHEMACTION_TAP_TRIANGLE"
	},
	{
		act = 4,
		name = "_CLASSCHEMACTION_TAP_L1"
	},
	{
		act = 5,
		name = "_CLASSCHEMACTION_TAP_L2"
	},
	{
		act = 6,
		name = "_CLASSCHEMACTION_TAP_L3"
	},
	{
		act = 7,
		name = "_CLASSCHEMACTION_TAP_R1"
	},
	{
		act = 8,
		name = "_CLASSCHEMACTION_TAP_R2"
	},
	{
		act = 9,
		name = "_CLASSCHEMACTION_TAP_R3"
	},
	{
		act = 22,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CW"
	},
	{
		act = 23,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CCW"
	},
	{
		act = 28,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CW"
	},
	{
		act = 29,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CCW"
	},
	{
		act = 34,
		name = "_CLASSCHEMACTION_END"
	},
	{
		act = 22,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CW"
	},
	{
		act = 23,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CCW"
	},
	{
		act = 24,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CW_HALF"
	},
	{
		act = 25,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CCW_HALF"
	},
	{
		act = 26,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CW_QTR"
	},
	{
		act = 27,
		name = "_CLASSCHEMACTION_ROTATE_LSTICK_CCW_QTR"
	},
	{
		act = 28,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CW"
	},
	{
		act = 29,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CCW"
	},
	{
		act = 30,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CW_HALF"
	},
	{
		act = 31,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CCW_HALF"
	},
	{
		act = 32,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CW_QTR"
	},
	{
		act = 33,
		name = "_CLASSCHEMACTION_ROTATE_RSTICK_CCW_QTR"
	}
}
local QTE_NOT_STARTED = 0
local QTE_STARTED = 1
local QTE_STOP = 2
local QTE_TimerStatus, l_missionSuccess
local diff_easy = 1
local diff_hard = 2
local HardSeqLength = 10
local curr = 0
local num_missed = 0
local max_num_missed = 1

function lQTE_Create(game)
	--DebugPrint("lQTE_Create(game): game = " .. game)
	MinigameCreate(game, false)
	while MinigameIsReady() == false do
		Wait(0)
	end
	QTE_TimerStatus = QTE_NOT_STARTED
end

function lQTE_MainLoop(completedTotalReq, ClassDurationReq, ActAnimTable, ActAnimFile, diff, ActionsCallback, outnode, restrictActions)
	math.randomseed(GetTimer())
	local seq = seq1
	--DebugPrint("sequence: " .. seq)
	if 0 < ClassDurationReq then
		MissionTimerStart(ClassDurationReq)
		bUsingTimer = true
	else
		bUsingTimer = false
	end
	QTE_TimerStatus = QTE_STARTED
	local completedTotal = 0
	local failedSequenceTotal = 0
	ActAnimTableSize = table.getn(ActAnimTable)
	while completedTotalReq > completedTotal and failedSequenceTotal < failedSequencesMax and QTE_TimerStatus ~= QTE_STOP do
		--DebugPrint("start a sequence!")
		MinigameStart()
		if restrictActions then
			ClassChemSetActiveActions(restrictActions)
		end
		--DebugPrint("enable HUD!")
		MinigameEnableHUD(true)
		--DebugPrint("enable HUD done!")
		lQTE_InitSequences(ActAnimTable, ActAnimTableSize, diff)
		ClassChemStartSeq(seq)
		curr = 1
		while not (not MinigameIsActive() or MissionTimerHasFinished() and bUsingTimer) do
			Wait(0)
			lQTE_MonitorActions(ActAnimTable, ActAnimFile, ActAnimTableSize, ActionsCallback)
		end
		--DebugPrint("end: performance: " .. ClassChemGetPerformance())
		if MinigameIsSuccess() and not (num_missed >= max_num_missed) then
			completedTotal = completedTotal + 1
		else
			failedSequenceTotal = failedSequenceTotal + 1
			--DebugPrint("starting over")
		end
		Wait(2000)
		MinigameEnableHUD(false)
	end
	PedSetActionNode(gPlayer, outnode, ActAnimFile)
	--DebugPrint("loop over!")
	--DebugPrint("loop over!")
	--DebugPrint("loop over!")
	--DebugPrint("loop over!")
	if 0 < ClassDurationReq then
		MissionTimerStop()
	end
	MinigameEnableHUD(false)
	if completedTotalReq <= completedTotal then
		l_missionSuccess = true
	else
		MinigameEnd()
	end
	return l_missionSuccess
end

local j = 1

function SetWaitTime(waitTimeReq)
	if type(waitTimeReq) == "number" then
		myWaitTime = waitTimeReq
	end
end

function DbgNameAction(act)
	for j, dm in debugMessages do
		if dm.act == act then
			--DebugPrint("        adding action: " .. dm.name .. " " .. dm.act)
			break
		end
	end
end

local wait_time = myWaitTime

function lQTE_InitSequences(ActAnimTable, ActAnimTableSize, difficultyReq)
	--DebugPrint("lQTE_InitSequences() start.  difficultyReq =" .. difficultyReq)
	if difficultyReq == diff_easy then
		--DebugPrint("difficulty: easy")
		--DebugPrint("ActAnimTableSize = " .. ActAnimTableSize)
		ClassChemAddAction(seq1, ActAnimTable[1].act, myWaitTime + 2, ActAnimTable[1].window)
		DbgNameAction(ActAnimTable[1].act)
		if ActAnimTable[1].fail_anim then
			--DebugPrint("               fail_anim: " .. ActAnimTable[1].fail_anim)
		end
		for i = 2, ActAnimTableSize do
			DbgNameAction(ActAnimTable[i].act)
			if ActAnimTable[i].wait then
				wait_time = ActAnimTable[i].wait
			else
				wait_time = myWaitTime
			end
			if ActAnimTable[i].fail_anim then
				--DebugPrint("               fail_anim: " .. ActAnimTable[i].fail_anim)
			end
			ClassChemAddAction(seq1, ActAnimTable[i].act, wait_time, ActAnimTable[i].window)
		end
		--DebugPrint("lQTE_InitSequences() fin")
	end
	if difficultyReq == 0 then
		--DebugPrint("ERROR!  difficulty not set!")
	end
	if difficultyReq ~= diff_easy and difficultyReq ~= nil then
		--assert(false, "LUA ERROR: libQTE: lQTE_InitSequences() - non-easy difficulty not handled.")
	end
	num_missed = 0
end

function lQTE_MonitorActions(AAtable, AAfile, AAtableSize, F_ActionsCallback)
	if bUsingTimer and MissionTimerHasFinished() then
		MinigameEnd()
	end
	if AAtableSize > curr then
		if ClassChemGetActionJustFinished(AAtable[curr].act) then
			--DebugPrint("now playing step: " .. curr)
			if F_ActionsCallback then
				F_ActionsCallback(AAtable[curr], true)
			else
				--DebugPrint("F_ActionsCallback == false!")
			end
			curr = curr + 1
		end
		if ClassChemGetActionJustFailed(AAtable[curr].act) then
			num_missed = num_missed + 1
			if F_ActionsCallback then
				F_ActionsCallback(AAtable[curr], false, num_missed)
			end
			if num_missed >= max_num_missed then
				MinigameEnd()
			end
			curr = curr + 1
		end
	end
end

function lQTE_T_EventLooper()
	while Alive and QTE_TimerStatus ~= QTE_STOP do
		UpdateTextQueue()
		Wait(0)
		if bUsingTimer and MissionTimerHasFinished() and QTE_TimerStatus == QTE_STARTED then
			MissionTimerStop()
			QTE_TimerStatus = QTE_STOP
		end
	end
end

function lQTE_Destroy()
	MinigameDestroy()
end
