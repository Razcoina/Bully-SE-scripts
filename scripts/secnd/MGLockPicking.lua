local gDisplayHud = false
local gPlayerWon = false
local gPlayerIsInMission = false
local gReward
local gLastTimePressed = 0

function F_AssignRandomValue()
	local x, y, z = PlayerGetPosXYZ()
	local combo1, combo2, combo3 = math.random(0, 39), math.random(0, 39), math.random(0, 39)
	if shared.gFailedPickingLocker == true then
		local distanceToPrev = DistanceBetweenCoords3d(x, y, z, shared.gLastLockPickLocation.x1, shared.gLastLockPickLocation.y1, shared.gLastLockPickLocation.z1)
		if distanceToPrev <= 5 then
			combo1, combo2, combo3 = shared.gLastLockPickCombo.c1, shared.gLastLockPickCombo.c2, shared.gLastLockPickCombo.c3
		end
		shared.gFailedPickingLocker = false
		MGLockSetCombo(combo1, combo2, combo3)
		return
	end
	combo1, combo2, combo3 = math.random(0, 39), math.random(0, 39), math.random(0, 39)
	shared.gLastLockPickCombo = {
		c1 = combo1,
		c2 = combo2,
		c3 = combo3
	}
	shared.gLastLockPickLocation = {
		x1 = x,
		y1 = y,
		z1 = z
	}
	MGLockSetCombo(combo1, combo2, combo3)
end

function F_LookUpLocker()
	F_AssignRandomValue()
end

function main()
	--print(" =====================>> SCRIPT IS LAUNCHING!!")
	--print(" =====================>> Starting event!!", tostring(shared.gStartingEvent))
	shared.gFailedPickingLocker = false
	shared.gLockpickingHudTurnOn = false
	shared.gLockpickingSuccess = false
	shared.gStartingEvent = false
	local bMissionActive = MissionActive()
	AreaPatrolPathShowVisionCones(true)
	if shared.gStartingEvent == false then
		MinigameCreate("LOCK", false)
		--print("===========>> mini-game is starting up!")
		while MinigameIsReady() == false do
			--print("=======>>>> trying to setup the game!!!")
			Wait(0)
		end
		--print("===========>> mini-game has been setup, turn on the hud!!")
		while shared.gLockpickingHudTurnOn == false do
			Wait(0)
			--print("=======================>>>>> waiting for hud to turn on!!")
			if not PedIsUsingProp(gPlayer) or bMissionActive and not MissionActive() then
				--print("+==================>>> LOCKER MINI-GAME IS BREAKING UP BECAUSE THE PED STOPPED USING THE PROP!!!")
				shared.gFailedPickingLocker = true
				shared.gLockpickingHudTurnOn = false
				shared.gLockpickingSuccess = false
				shared.gStartingEvent = false
				CameraReset()
				CameraReturnToPlayer()
				AreaPatrolPathShowVisionCones(false)
				MinigameDestroy()
				return
			end
		end
		if shared.gLockpickingHudTurnOn == true then
			--print("Hud is supposed to be showing up!!")
			MinigameStart()
			DisablePunishmentSystem(false)
			F_LookUpLocker()
			MinigameEnableHUD(false)
			MinigameEnableHUD(true)
			shared.gStartingEvent = true
		end
		if shared.gStartingEvent == true then
			while MinigameIsActive() do
				Wait(0)
				if not PedIsUsingProp(gPlayer) or bMissionActive and not MissionActive() then
					--print("=================>>>>>> MINIGAMe IS GOING TO BE DESTROYED BECAUSE APPARENTLY THE PLAYER WAS HIT!!!")
					CameraReset()
					CameraReturnToPlayer()
					MinigameEnd()
					AreaPatrolPathShowVisionCones(false)
					MinigameDestroy()
					shared.gFailedPickingLocker = true
					shared.gLockpickingHudTurnOn = false
					shared.gLockpickingSuccess = false
					shared.gStartingEvent = false
					return
				end
				if IsButtonPressed(8, 0) and GetTimer() > gLastTimePressed + 24000 then
					gLastTimePressed = GetTimer()
				end
				UpdateTextQueue()
			end
			TextPrintString("", 1, 1)
			ClearTextQueue()
			if MinigameIsSuccess() then
				shared.gLockpickingSuccess = true
				shared.gFailedPickingLocker = false
			else
				shared.gFailedPickingLocker = true
			end
			shared.gLockpickingHudTurnOn = false
			MinigameEnableHUD(false)
			MinigameEnd()
		end
		AreaPatrolPathShowVisionCones(false)
		MinigameDestroy()
		if shared.gLockpickingSuccess == true then
			while shared.gLockpickingSuccess == true do
				--print("?????")
				if not PedIsUsingProp(gPlayer) or bMissionActive and not MissionActive() then
					shared.gLockpickingSuccess = false
					CameraReset()
					CameraReturnToPlayer()
					break
				end
				Wait(0)
			end
		end
		if shared.gStartingEvent == true then
			while shared.gStartingEvent == true do
				if not PedIsUsingProp(gPlayer) or bMissionActive and not MissionActive() then
					shared.gStartingEvent = false
					CameraReset()
					CameraReturnToPlayer()
					break
				end
				Wait(0)
			end
		end
	end
end
