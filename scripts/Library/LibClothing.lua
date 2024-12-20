--[[ Changes to this file:
	* Modified function T_ClothingManager, may require testing
]]

local gCurrentCam = 0
local gCanExit = true
local gTryingTime = 0
local gChangeAnimTime = 10000
local gAccepted = false
local gPausedClock = false

function L_ClothingSetup(initialHeading, endCallback, avoidFadeIn)
	if endCallback then
		L_CbFinishClothing = endCallback
	else
		L_CbFinishClothing = nil
	end
	if not MissionActive() and not ClockIsPaused() then
		PauseGameClock()
		gPausedClock = true
	end
	if F_CheckClock() then
		SoundPlay2D("ButtonUp")
		SoundDisableSpeech_ActionTree()
		MusicFadeWithCamera(false)
		SoundFadeWithCamera(false)
		CameraFade(500, 0)
		PlayerSetControl(0)
		Wait(500)
		LoadAnimationGroup("Try_Clothes")
		HUDSaveVisibility()
		HUDClearAllElements()
		ToggleHUDComponentLocked(40, true)
		local x, y, z = GetPointList(POINTLIST._CM_PLAYERLOC)
		PlayerSetPosSimple(x, y, z)
		if shared.cm_lockHead then
			ClothingLock("HEAD", true)
		else
			ClothingLock("HEAD", false)
		end
		if shared.cm_lockTorso then
			ClothingLock("TORSO", true)
		else
			ClothingLock("TORSO", false)
		end
		if shared.cm_lockLWrist then
			ClothingLock("LEFT_WRIST", true)
		else
			ClothingLock("LEFT_WRIST", false)
		end
		if shared.cm_lockRWrist then
			ClothingLock("RIGHT_WRIST", true)
		else
			ClothingLock("RIGHT_WRIST", false)
		end
		if shared.cm_lockLegs then
			ClothingLock("LEGS", true)
		else
			ClothingLock("LEGS", false)
		end
		if shared.cm_lockFeet then
			ClothingLock("FEET", true)
		else
			ClothingLock("FEET", false)
		end
		if shared.cm_lockOutfit then
			ClothingLock("OUTFIT", true)
		else
			ClothingLock("OUTFIT", false)
		end
		shared.PlayerInClothingManager = true
		ToggleHUDComponentVisibility(14, true)
		gLookAtPoint = POINTLIST._CM_LOOKAT
		gLookAtPoint2 = POINTLIST._CM_LOOKAT2
		gCameraTransitions = {
			{
				path = PATH._CM_CAMERA02,
				camNo = 0
			},
			{
				path = PATH._CM_CAMERA03,
				camNo = 1
			},
			{
				path = PATH._CM_CAMERA04,
				camNo = 2
			},
			{
				path = PATH._CM_CAMERA04,
				camNo = 2
			},
			{
				path = PATH._CM_CAMERA05,
				camNo = 3
			},
			{
				path = PATH._CM_CAMERA06,
				camNo = 4
			},
			{
				path = PATH._CM_CAMERA01,
				camNo = 5
			},
			{
				path = PATH._CM_CAMERA01,
				camNo = 5
			}
		}
		gSize = table.getn(gCameraTransitions)
		gCurrentCamNo = gCameraTransitions[gSize].camNo
		if initialHeading then
			gClothingHeading = initialHeading
		else
			gClothingHeading = 90
		end
		gTryingTime = GetTimer()
	end
	CreateThread("T_ClothingManager")
end

function T_ClothingManager() -- ! Modified
	if F_CheckClock() then
		CameraFade(500, 0)
		Wait(500)
		DisablePOI(true, true)
		AreaClearAllPeds()
		local buttonPressed = false
		local clothingHeading = gClothingHeading
		gCurrentCam = 0
		PlayerFaceHeading(clothingHeading, 0)
		ClothingStoreRegisterFeedbackCallback(FeedbackCallback)
		if CameraGet169Mode() then
			gInWidescreen = true
			lx, ly, lz = GetPointList(gLookAtPoint2)
			CameraSetFOV(75)
		else
			gInWidescreen = false
			lx, ly, lz = GetPointList(gLookAtPoint)
		end
		CameraLookAtXYZ(lx, ly, lz, true)
		CameraSetPath(gCameraTransitions[gSize].path, true)
		CameraSetSpeed(15, 15, 15)
		F_MakePlayerSafeForNIS(true, true)
		PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/Clothing/TryingOn", "Act/Anim/Ambient.act")
		MissionTimerPause(true)
		if shared.playerKOd then
			shared.playerKOd = nil
		end
		gAccepted = false
		ClothingBackup()
		if not F_HandleExitNow() then
			CameraFade(500, 1)
			local sizeZO = table.getn(gCameraTransitions)
			while not buttonPressed do
				if gInWidescreen and not CameraGet169Mode() then
					lx, ly, lz = GetPointList(gLookAtPoint)
					CameraLookAtXYZ(lx, ly, lz, true)
					CameraDefaultFOV()
					gInWidescreen = false
				elseif not gInWidescreen and CameraGet169Mode() then
					lx, ly, lz = GetPointList(gLookAtPoint2)
					CameraSetFOV(75)
					CameraLookAtXYZ(lx, ly, lz, true)
					gInWidescreen = true
				end
				if IsButtonPressed(15, 0) then
					--[[
					clothingHeading = gClothingHeading
				elseif IsButtonPressed(24, 0) then
					clothingHeading = clothingHeading - 5
				elseif IsButtonPressed(25, 0) then
					clothingHeading = clothingHeading + 5
					]] -- Changed to (to the end of this if):
					UItempcounter = UItempcounter - 1
					if UItempcounter == 0 then
						clothingHeading = gClothingHeading
						UItempcounter = 1
					end
				elseif GetStickValue(18, 0) then
					UItempcounter = 5
					clothingHeading = clothingHeading + 5 * GetStickValue(18, 0)
				end
				if 360 < clothingHeading then
					clothingHeading = clothingHeading - 360
				elseif clothingHeading < 0 then
					clothingHeading = clothingHeading + 360
				end
				PlayerFaceHeadingNow(clothingHeading)
				if not gZoomed then
					if gCurrentCamNo ~= gCameraTransitions[sizeZO].camNo then
						CameraSetPath(gCameraTransitions[sizeZO].path, false)
						gCurrentCamNo = gCameraTransitions[sizeZO].camNo
					end
					if IsButtonPressed(12, 0) then
						local index = gCurrentCam + 1
						--print("gZOOMED IS NOW TRUE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<", gCurrentCamNo)
						gZoomed = true
						if gCurrentCamNo ~= gCameraTransitions[index].camNo then
							CameraSetPath(gCameraTransitions[index].path, false)
							gCurrentCamNo = gCameraTransitions[index].camNo
						end
					end
				elseif gZoomed then
					if not IsButtonPressed(12, 0) then
						local size = table.getn(gCameraTransitions)
						if gCurrentCamNo ~= gCameraTransitions[gSize].camNo then
							CameraSetPath(gCameraTransitions[gSize].path, false)
							gCurrentCamNo = gCameraTransitions[gSize].camNo
						end
						--print("gZOOMED IS NOW FALSE -----------------------------------------", gCurrentCamNo)
						gZoomed = false
					end
					if gCamChanged then
						local index = gCurrentCam + 1
						if gCurrentCamNo ~= gCameraTransitions[index].camNo then
							CameraSetPath(gCameraTransitions[index].path, false)
							gCurrentCamNo = gCameraTransitions[index].camNo
							Wait(100)
						end
						gCamChanged = false
					end
				end
				if gCamChanged then
					gCamChanged = false
				end
				if GetTimer() - gTryingTime > gChangeAnimTime then
					PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/Clothing/TryClothesAnims", "Act/Anim/Ambient.act")
					gTryingTime = GetTimer()
				end
				if IsButtonBeingPressed(8, 0) and gCanExit or shared.playerKOd then
					buttonPressed = true
					doFade = false
					SoundPlay2D("ButtonDown")
					CameraFade(500, 0)
					Wait(500)
					ClothingRestore()
					ClothingBuildPlayer()
				elseif gAccepted or shared.playerKOd then
					buttonPressed = true
					doFade = false
					CameraFade(500, 0)
					Wait(500)
				end
				F_HandleExitButtons()
				Wait(0)
			end
		end
		if shared.playerKOd then
			shared.playerKOd = nil
		else
			local x, y, z = GetPointList(POINTLIST._CM_CORONA)
			PlayerSetPosSimple(x, y, z)
		end
		SoundEnableSpeech_ActionTree()
		ToggleHUDComponentVisibility(14, false)
		PedSetActionNode(gPlayer, "/Global/Ambient/MissionSpec/Clothing/Finished", "Act/Anim/Ambient.act")
		ToggleHUDComponentLocked(40, false)
		HUDRestoreVisibility()
		CameraDefaultFOV()
		CameraSetActive(1, 0)
		EnablePOI(true, true)
		if not avoidFadeIn then
			CameraFade(500, 1)
		end
		ClothingExitButton(true)
		F_MakePlayerSafeForNIS(false, true)
		MissionTimerPause(false)
		PlayerSetControl(1)
		UnLoadAnimationGroup("Try_Clothes")
	end
	if not MissionActive() and gPausedClock then
		UnpauseGameClock()
	end
	shared.PlayerInClothingManager = nil
	if L_CbFinishClothing then
		L_CbFinishClothing()
	end
	Wait(500)
	MusicFadeWithCamera(true)
	SoundFadeWithCamera(true)
end

function FeedbackCallback(storeFeedbackType, relatedData)
	--print("*** SAJ *** FEEDBACK ! CALLBACK", storeFeedbackType, relatedData)
	if storeFeedbackType == 0 then
		if gCurrentCam ~= relatedData then
			gCurrentCam = relatedData
			gCamChanged = true
		end
	elseif storeFeedbackType == 10 and gCanExit then
		gAccepted = true
	end
end

function F_HandleExitNow()
	if AreaGetVisible() == 13 then
		if IsMissionAvailable("Dummy_Wrestling_1") or IsMissionAvailable("Dummy_Wrestling_3") then
			ClothingSetPlayerOutfit("Wrestling")
			ClothingBuildPlayer()
			return true
		elseif IsMissionAvailable("Dummy_Wrestling_2") or IsMissionAvailable("Dummy_Wrestling_4") or IsMissionAvailable("Dummy_Wrestling_5") then
			ClothingSetPlayerOutfit("Gym Strip")
			ClothingBuildPlayer()
			return true
		end
	end
	if MissionActiveSpecific("1_11X1") then
		ClothingSetPlayerOutfit("Halloween")
		ClothingBuildPlayer()
		return true
	end
	return false
end

function F_HandleExitButtons()
	if MissionActiveSpecific("1_11X1") then
		if ClothingIsWearingOutfit("Halloween") then
			ClothingExitButton(true)
			gCanExit = true
		else
			ClothingExitButton(false)
			gCanExit = false
		end
	elseif MissionActiveSpecific("1_02A") then
		if ClothingGetPlayer(1) == ObjectNameToHashID(shared.gUniformTorso) then
			ClothingExitButton(true)
			gCanExit = true
		else
			ClothingExitButton(false)
			gCanExit = false
		end
	end
end

function F_CheckClock()
	hour, minute = ClockGet()
	if hour == 1 and minute > 55 or hour == 2 or PlayerFellAsleep() or AreaIsLoading() then
		return false
	end
	return true
end

function F_CheckPedNotInGrapple(PedID)
	pGrapplePed = PedGetGrappleTargetPed(PedID)
	if pGrapplePed == -1 then
		return true
	end
	return false
end
