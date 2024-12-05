local gUmpires = {}
local gCatchers = {}
local gBatters = {}
local gChances = {
	{
		catcher = 20,
		batter = 50,
		umpire = 30
	},
	{
		catcher = 20,
		batter = 50,
		umpire = 30
	},
	{
		catcher = 20,
		batter = 50,
		umpire = 30
	}
}
local gPathSpeeds = {
	1.6,
	1.9,
	2.2
}
local gNoOfPropsPerPath = {
	6,
	7,
	7
}
local gMissionTime = 60
local gPathOneProps = {}
local gPathTwoProps = {}
local gPathThreeProps = {}
local gOne, gTwo, gThree = false, false, false
local gCurrentScore = 0
local gBalls = 0
local gStrikes = 0
local gPathScores = {
	50,
	100,
	150
}
local game_running = true
local game_won = false
local gTimeToCruise = 6930
local gPathWaits = {
	gTimeToCruise / gPathSpeeds[1] / (gNoOfPropsPerPath[1] + 1),
	gTimeToCruise / gPathSpeeds[2] / (gNoOfPropsPerPath[2] + 1),
	gTimeToCruise / gPathSpeeds[3] / (gNoOfPropsPerPath[3] + 1)
}

function F_LoadTriggers()
	--print(" %%%%%%%%%%%% F_LoadTriggers ")
	gUmpires = {
		TRIGGER._UMPIREONE,
		TRIGGER._UMPIRETWO,
		TRIGGER._UMPIRETHREE,
		TRIGGER._UMPIREFOUR,
		TRIGGER._UMPIREFIVE,
		TRIGGER._UMPIRESIX,
		TRIGGER._UMPIRESEVEN
	}
	gCatchers = {
		TRIGGER._CATCHERONE,
		TRIGGER._CATCHERTWO,
		TRIGGER._CATCHERTHREE,
		TRIGGER._CATCHERFOUR,
		TRIGGER._CATCHERFIVE,
		TRIGGER._CATCHERSIX,
		TRIGGER._CATCHERSEVEN
	}
	gBatters = {
		TRIGGER._BATTERONE,
		TRIGGER._BATTERTWO,
		TRIGGER._BATTERTHREE,
		TRIGGER._BATTERFOUR,
		TRIGGER._BATTERFIVE,
		TRIGGER._BATTERSIX,
		TRIGGER._BATTERSEVEN,
		TRIGGER._BATTEREIGHT,
		TRIGGER._BATTERNINE
	}
	for i, anim in gUmpires do
		PAnimCreate(anim)
		PAnimOverrideDamage(anim, 1)
	end
	for i, anim in gCatchers do
		PAnimCreate(anim)
		PAnimOverrideDamage(anim, 1)
	end
	for i, anim in gBatters do
		PAnimCreate(anim)
		PAnimOverrideDamage(anim, 1)
	end
	--print(" %%%%%%%%%%%% F_LoadTriggers END")
end

function F_UnloadTriggers()
	for i, anim in gUmpires do
		PAnimDelete(anim)
	end
	for i, anim in gCatchers do
		PAnimDelete(anim)
	end
	for i, anim in gBatters do
		PAnimDelete(anim)
	end
end

function F_EvaluateHit(type, score)
	--print(" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
	--print(" EVALUATING HIT: ", type, score)
	if type == "B" then
		gBalls = gBalls + 1
		if 4 <= gBalls then
			game_running = false
			TextPrintString("Ball 4! You lost the game ! ", 2000, 2)
		else
			TextPrintString("Ball " .. gBalls, 2000, 2)
		end
	elseif type == "C" then
		gStrikes = gStrikes + 1
		if 3 <= gStrikes then
			TextPrintString("He is OUT!", 3000, 2)
			gCurrentScore = gCurrentScore + score
			game_running = false
			game_won = true
		else
			gCurrentScore = gCurrentScore + score
			TextPrintString("Strike " .. gStrikes .. " Score " .. gCurrentScore, 2000, 2)
		end
	else
		game_running = false
		TextPrintString("Ugh, Hit the umpire, you lost the game! ", 3000, 2)
	end
	--print(" END EVALUATING HIT ")
	--print(" ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
end

function F_CheckTriggers()
	for i, tOne in gPathOneProps do
		if PAnimIsDestroyed(tOne.id) and tOne.alive then
			F_EvaluateHit(tOne.type, gPathScores[1])
			tOne.alive = false
		end
	end
	for i, tTwo in gPathTwoProps do
		if PAnimIsDestroyed(tTwo.id) and tTwo.alive then
			F_EvaluateHit(tTwo.type, gPathScores[2])
			tTwo.alive = false
		end
	end
	for i, tThree in gPathThreeProps do
		if PAnimIsDestroyed(tThree.id) and tThree.alive then
			F_EvaluateHit(tThree.type, gPathScores[3])
			tThree.alive = false
		end
	end
end

function F_FollowPath(path)
	local propid = -1
	local trigger = -1
	local pType = -1
	if path == 1 then
		trigger, pType, propid = F_CreateProp(1)
		while trigger < 0 do
			trigger, pType, propid = F_CreateProp(1)
		end
		Wait(10)
		--print(" INSERTING IN TABLE 1 ", trigger, pType)
		table.insert(gPathOneProps, {
			id = trigger,
			type = pType,
			alive = true
		})
		PAnimFollowPath(trigger, PATH._BASEBALLTOSS_ROWONEPATH, false, CbRowOne)
		PAnimSetPathFollowSpeed(trigger, gPathSpeeds[1])
	elseif path == 2 then
		trigger, pType, propid = F_CreateProp(2)
		while trigger < 0 do
			trigger, pType, propid = F_CreateProp(2)
		end
		Wait(10)
		--print(" INSERTING IN TABLE 2 ", trigger, pType)
		table.insert(gPathTwoProps, {
			id = trigger,
			type = pType,
			alive = true
		})
		PAnimFollowPath(trigger, PATH._BASEBALLTOSS_ROWTWOPATH, false, CbRowTwo)
		PAnimSetPathFollowSpeed(trigger, gPathSpeeds[2])
	elseif path == 3 then
		trigger, pType, propid = F_CreateProp(3)
		while trigger < 0 do
			trigger, pType, propid = F_CreateProp(3)
		end
		Wait(10)
		--print(" INSERTING IN TABLE 3 ", trigger, pType)
		table.insert(gPathThreeProps, {
			id = trigger,
			type = pType,
			alive = true
		})
		PAnimFollowPath(trigger, PATH._BASEBALLTOSS_ROWTHREEPATH, false, CbRowThree)
		PAnimSetPathFollowSpeed(trigger, gPathSpeeds[3])
	end
end

function F_CreateProp(pathNo)
	--print("<<<<<<<<<<<<<  F_CreateProp ")
	local propid = -1
	local trigger = -1
	local pType = "U"
	local randNo = math.random(1, 100)
	local pCatcher = gChances[pathNo].catcher
	local pBatter = gChances[pathNo].batter + pCatcher
	if randNo < pCatcher then
		pType = "C"
	elseif randNo < pBatter then
		pType = "B"
	end
	if pType == "B" then
		if table.getn(gBatters) > 0 then
			trigger = gBatters[1]
			table.remove(gBatters, 1)
		end
	elseif pType == "C" then
		if table.getn(gCatchers) > 0 then
			trigger = gCatchers[1]
			table.remove(gCatchers, 1)
		end
	elseif pType == "U" and table.getn(gUmpires) > 0 then
		trigger = gUmpires[1]
		table.remove(gUmpires, 1)
	end
	--print("<<<<<<<<<<<<<  F_CreateProp END", trigger, pType, propid, GetTimer())
	return trigger, pType, propid
end

function CbRowOne(propId, pathId, pathNode)
	if pathNode == 1 then
		F_EliminateProp(propId, 1)
		gOne = true
	end
end

function CbRowTwo(propId, pathId, pathNode)
	if pathNode == 1 then
		F_EliminateProp(propId, 2)
		gTwo = true
	end
end

function CbRowThree(propId, pathId, pathNode)
	if pathNode == 1 then
		F_EliminateProp(propId, 3)
		gThree = true
	end
end

function F_EliminateProp(triggerId, pathNo)
	local pType = "U"
	local pId = -1
	if pathNo == 1 then
		--print("Eliminating 1", table.getn(gPathOneProps))
		pType = gPathOneProps[1].type
		pId = gPathOneProps[1].id
		table.remove(gPathOneProps, 1)
		--print("Eliminating 1", table.getn(gPathOneProps))
	elseif pathNo == 2 then
		--print("Eliminating 2", table.getn(gPathTwoProps))
		pType = gPathTwoProps[1].type
		pId = gPathTwoProps[1].id
		table.remove(gPathTwoProps, 1)
		--print("Eliminating 2", table.getn(gPathTwoProps))
	elseif pathNo == 3 then
		--print("Eliminating 3", table.getn(gPathThreeProps))
		pType = gPathThreeProps[1].type
		pId = gPathThreeProps[1].id
		table.remove(gPathThreeProps, 1)
		--print("Eliminating 3", table.getn(gPathThreeProps))
	end
	--print(" >>>> I HAVE JUST ERASED ", triggerId, pId, " BEING A TYPE ", pType, "In Path", pathNo, GetTimer())
	if pType == "B" then
		table.insert(gBatters, triggerId)
	elseif pType == "C" then
		table.insert(gCatchers, triggerId)
	elseif pType == "U" then
		table.insert(gUmpires, triggerId)
	end
	PAnimReset(triggerId)
	PAnimStopFollowPath(triggerId)
end

function MissionSetup()
	DATLoad("MGBaseballToss.DAT", 2)
	DATInit()
	AreaTransitionPoint(0, POINTLIST.BASEBALLTOSS_MINIGAME_ENTRY)
end

function MissionCleanup()
	F_UnloadTriggers()
	local WarpToX, WarpToY, WarpToZ = GetPointList(POINTLIST.BASEBALLTOSS_MINIGAME_EXIT)
	CameraAllowChange(true)
	PlayerWeaponHudLock(false)
	CameraReturnToPlayer()
	AreaTransitionPoint(0, POINTLIST.BASEBALLTOSS_MINIGAME_EXIT)
	Wait(1000)
	DATUnload(2)
end

function main()
	F_LoadTriggers()
	gClerk = PedCreatePoint(82, POINTLIST.BASEBALLTOSS_MINIGAME_CLERK)
	PedFaceObject(gClerk, gPlayer, 2, 0)
	PedStartConversation("/Global/PriOff/PrincipalDialogue", "Act/Conv/PriOff.act", gPlayer, principal)
	while PedInConversation(gClerk) do
		Wait(0)
	end
	PlayerSetWeapon(312, 140)
	CameraSetActive(2)
	Wait(1000)
	CameraAllowChange(false)
	PlayerWeaponHudLock(true)
	MissionTimerStart(gMissionTime)
	local noP01, noP02, noP03 = 0, 0, 0
	local bS01, bS02, bS03 = true, true, true
	local tS01 = GetTimer()
	local tS02 = GetTimer()
	local tS03 = GetTimer()
	while game_running do
		F_CheckTriggers()
		if bS01 and GetTimer() - tS01 > gPathWaits[1] then
			noP01 = noP01 + 1
			tS01 = GetTimer()
			F_FollowPath(1)
			if noP01 > gNoOfPropsPerPath[1] then
				bS01 = false
			end
		end
		if bS02 and GetTimer() - tS02 > gPathWaits[2] then
			noP02 = noP02 + 1
			tS02 = GetTimer()
			F_FollowPath(2)
			if noP02 > gNoOfPropsPerPath[2] then
				bS02 = false
			end
		end
		if bS03 and GetTimer() - tS03 > gPathWaits[3] then
			noP03 = noP03 + 1
			tS03 = GetTimer()
			F_FollowPath(3)
			if noP03 > gNoOfPropsPerPath[3] then
				bS03 = false
			end
		end
		if gOne then
			F_FollowPath(1)
			gOne = false
		end
		if gTwo then
			F_FollowPath(2)
			gTwo = false
		end
		if gThree then
			F_FollowPath(3)
			gThree = false
		end
		if MissionTimerHasFinished() then
			game_running = false
		end
		Wait(0)
	end
	MissionTimerStop()
	Wait(2000)
	if game_won then
		TextPrintString("Excellent Job Kid ! ", 2000, 2)
		Wait(2000)
		TextPrintString("This is your final score: " .. gCurrentScore, 2000, 2)
	else
		TextPrintString("Better luck next time ! ", 2000, 2)
		Wait(2000)
		TextPrintString("This is your final score: " .. gCurrentScore, 2000, 2)
	end
	Wait(5000)
	MissionSucceed()
end
