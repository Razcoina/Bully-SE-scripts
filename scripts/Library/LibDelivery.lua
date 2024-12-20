local strMissionCode = "3_R05b"
local ClientAITree = "/Global/AI_3_R05"
local ClientAIFile = "Act/AI/AI_3_R05.act"
local ClientAnimTree = "/Global/Client_3_R05"
local ClientAnimFile = "Act/Anim/Client_3_R05.act"
local deliveryParam = {
	run_proximity = 10,
	handoff_proximity = 2,
	handoff_limit = 2.3,
	lookaround_odds = 50
}
local compound_cost = {
	{
		500,
		1000,
		2000
	},
	{
		1000,
		2000,
		3000
	},
	{
		2000,
		3000,
		5000
	},
	{
		2000,
		3000,
		5000
	}
}
local tblDeliverySuccess, tblDeliveryNotDone, tblObjective, tblClient, tblTimeLimit, timeLimit, tblLookAnim, level
local tblClientDefault = {
	model = 76,
	delivered = false,
	radarIcon = 2,
	blipStyle = 4
}

function F_DeliveryTableInit()
	tblLookAnim = {
		"/Global/Client_3_R05/Look/LookAround",
		"/Global/Client_3_R05/Look/LookLeft",
		"/Global/Client_3_R05/Look/LookRight"
	}
	tblDeliverySuccess = {
		"_THNX_01",
		"_THNX_02",
		"_THNX_03",
		"_THNX_04",
		"_THNX_05"
	}
	tblDeliveryNotDone = {
		"_WAIT_01",
		"_WAIT_02",
		"_WAIT_03",
		"_WAIT_04",
		"_WAIT_05"
	}
	tblObjective = {
		deliverChemicals = {
			successConditions = { F_DeliveredChemicals },
			failureConditions = { MissionTimerHasFinished },
			completeActions = { MissionTimerStop },
			failActions = { MissionTimerStop },
			stopOnCompleted = true,
			stopOnFailed = true
		}
	}
end

function L_DeliverySetParam(tblClientParam, tblTimeLimitParam)
	--assert(tblClientParam ~= nil, "ASSERT: L_DeliverySetParam() got a nil tblClient (argument 1)")
	--assert(tblTimeLimitParam ~= nil, "ASSERT: L_DeliverySetParam() got a nil tblTimeLimit (argument 2)")
	level = L_DeliveryGetLevel()
	for i, client in tblClientParam do
		--assert(client.point ~= nil, "client.point is nil for level " .. tostring(level) .. ", client " .. tostring(i) .. ", difficulty " .. tostring(shared.g3_R05_Diff))
		client.model = client.model or tblClientDefault.model
		client.delivered = client.delivered or tblClientDefault.delivered
		client.blipStyle = client.blipStyle or tblClientDefault.blipStyle
	end
	tblClient = tblClientParam
	timeLimit = tblTimeLimitParam[level][shared.g3_R05_Diff]
end

function L_DeliverySetMissionCode(strCode)
	strMissionCode = strCode
end

function F_DeliverySetLanguageRef()
	for i, ref in tblDeliverySuccess do
		tblDeliverySuccess[i] = strMissionCode .. tblDeliverySuccess[i]
	end
	for i, ref in tblDeliveryNotDone do
		tblDeliveryNotDone[i] = strMissionCode .. tblDeliveryNotDone[i]
	end
end

function F_DeliveredChemicals()
	for i, client in tblClient do
		if client.delivered == false then
			return false
		end
	end
	return true
end

function F_ClientNukeOffScreen(client)
	if client.id ~= nil and client.delivered and not PedIsOnScreen(client.id) then
		PedDelete(client.id)
		client.id = nil
	end
end

function F_ActivateDelivery(client)
	if not client.findingPlayer and PlayerIsInAreaObject(client.id, 2, deliveryParam.run_proximity, 0) then
		--print("@@@@@@@@@@@@@@@@@@ORDERING PED TO MOVE TOWARDS PLAYER")
		PedLockTarget(gPlayer, client.id)
		PedMoveToObject(client.id, gPlayer, 2, 0)
		client.findingPlayer = true
	end
end

function F_HandOff(client)
	if not client.delivered and client.findingPlayer and PlayerIsInAreaObject(client.id, 2, deliveryParam.handoff_proximity, 0) then
		PedClearObjectives(client.id)
		PedStop(client.id)
		PedSetActionNode(client.id, RandomTableElement(tblLookAnim), ClientAnimTree)
		while PedIsPlaying(client.id, "/Global/Client_3_R05/Look", true) do
			if not PlayerIsInAreaObject(client.id, 2, deliveryParam.handoff_limit, 0) then
				TextPrint(RandomTableElement(tblDeliveryNotDone), 3, 2)
				client.findingPlayer = false
				return nil
			end
			Wait(0)
		end
		PedSetActionNode(gPlayer, "/Global/Vehicles/Test/Throw", "Act/Vehicles.act")
		while PedIsPlaying(gPlayer, "/Global/Vehicles/Test/Throw", true) do
			Wait(0)
		end
		client.delivered = true
		L_HUDBlipRemove(client)
		TextPrint(RandomTableElement(tblDeliverySuccess), 3, 2)
		PedLockTarget(gPlayer, -1)
		PedWander(client.id, 2)
	end
end

function F_ClientHitByPlayer()
	for i, client in tblClient do
		if client.id ~= nil and PedGetWhoHitMeLast(client.id) == gPlayer then
			return true
		end
	end
end

function T_DeliveryMonitor()
	while not L_ObjectiveProcessingDone() do
		L_PedExec("client", F_ActivateDelivery, "element")
		L_PedExec("client", F_HandOff, "element")
		L_PedExec("client", F_ClientNukeOffScreen, "element")
		Wait(0)
	end
end

function L_DeliverySetEasy()
	L_DeliverySetDifficulty(1)
	return 0
end

function L_DeliverySetAverage()
	L_DeliverySetDifficulty(2)
	return 0
end

function L_DeliverySetHard()
	L_DeliverySetDifficulty(3)
	return 0
end

function L_DeliverySetDifficulty(difficulty)
	shared.g3_R05_Diff = difficulty
end

function L_DeliveryGetLevel()
	local numLevels = table.getn(compound_cost)
	return (numLevels >= shared.g3_R05_SuccessCount and shared.g3_R05_SuccessCount or numLevels) + 1
end

function L_DeliveryBranchByCompleted()
	local lastBranch = table.getn(compound_cost) - 1
	return lastBranch >= shared.g3_R05_SuccessCount and shared.g3_R05_SuccessCount or lastBranch
end

function L_DeliveryMoneyBranch()
	difficulty = 1
	local enough = L_DeliveryCheckPlayerMoney(difficulty)
	if enough then
		return 1
	else
		return 0
	end
end

function L_DeliveryCheckPlayerMoney(difficulty)
	return true
end

function L_DeliveryCheckMoneyForEasy()
	return L_DeliveryCheckPlayerMoney(1)
end

function L_DeliveryCheckMoneyForMedium()
	return L_DeliveryCheckPlayerMoney(2)
end

function L_DeliveryCheckMoneyForHard()
	return L_DeliveryCheckPlayerMoney(3)
end

function F_DeliverySetLookAround(tblClient)
	local clientCount = table.getn(tblClient)
	quota = math.floor(clientCount * deliveryParam.lookaround_odds / 100)
	local indices = {}
	for i = 1, clientCount do
		table.insert(indices, i)
	end
	local lookAroundCount = 0
	while lookAroundCount < quota do
		local randIndex = RandomTableElement(indices)
		tblClient[randIndex].lookAround = true
		table.remove(indices, randIndex)
		lookAroundCount = lookAroundCount + 1
	end
end

function L_DeliveryClientCount()
	return table.getn(tblClient)
end

function L_DeliveryGetReward()
	return compound_cost[level][shared.g3_R05_Diff] * 2
end

function F_DeliveryRandomizeClient(tblClient)
	for i, client in tblClient do
		if type(client.point) == "table" then
			client.point = RandomTableElement(client.point)
		end
		if type(client.model) == "table" then
			client.model = RandomTableElement(client.model)
		end
	end
end

function F_DeliverySetCustomTree(pedID)
	PedSetAITree(pedID, ClientAITree, ClientAIFile)
	PedSetActionTree(pedID, ClientAnimTree, ClientAnimFile)
end

function L_DeliverySetup()
	F_DeliveryTableInit()
	AreaOverridePopulation(4, 0, 0, 0, 0, 2, 0, 0, 1, 0, 1, 0, 0)
	VehicleOverrideAmbient(3, 1, 1, 1)
	F_DeliverySetLookAround(tblClient)
	F_DeliverySetLanguageRef(strMissionCode)
	L_ObjectiveSetParam(tblObjective)
	F_DeliveryRandomizeClient(tblClient)
	L_PedLoadPoint("client", tblClient)
	L_PedExec("client", F_DeliverySetCustomTree, "id")
	L_PedExec("client", F_PedSetInvincibleToPlayer, "id")
	L_HUDBlipSetup()
	local player_money = PedGetMoney(gPlayer)
	PedSetMoney(gPlayer, player_money - compound_cost[math.mod(shared.g3_R05_SuccessCount, table.getn(compound_cost)) + 1][shared.g3_R05_Diff])
end

function F_PedSetInvincibleToPlayer(id)
	PedSetInvulnerableToPlayer(id, true)
end

function L_DeliveryCleanup()
	L_HUDBlipCleanup()
end

function L_DeliveryControl()
	local objThreadID = CreateThread("T_ObjectiveMonitor")
	local monThreadID = CreateThread("T_DeliveryMonitor")
	TextPrint("3_R05b_INSTRUC", 3, 1)
	MissionTimerStart(timeLimit)
	L_WaitUntilObjectiveProcessingDone()
	if F_DeliveredChemicals() then
		TextPrintString("Your made $" .. string.format("%.2f", L_DeliveryGetReward() / 200) .. " in profit", 1, 1)
		Wait(3000)
		TextPrint("M_PASS", 3, 1)
		Wait(3000)
		shared.g3_R05_SuccessCount = shared.g3_R05_SuccessCount + 1
		SoundPlayMissionEndMusic(true, 10)
		MissionSucceed()
	else
		if not IsMissionRestartable() then
			TextPrint("M_FAIL", 3, 1)
		end
		SoundPlayMissionEndMusic(false, 10)
		MissionFail()
	end
	TerminateThread(objThreadID)
	TerminateThread(monThreadID)
end

function main()
	while PedInConversation(gPlayer) do
		Wait(0)
	end
end
