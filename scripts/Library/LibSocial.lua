local tblPedGiftLookup = {}
local tblGiftTypeLookup = {}
local tblForceReceiveLookup = {}
local tblPedRequestedGift = {}
local missionCode
tblGiftTypeLookup[474] = 3

function L_SocialGiftPedSetup(pedID, giftModel, forceReceive, missionCode)
	shared.tblPedGiftLookup = tblPedGiftLookup
	shared.tblPedGiftModelLookup = tblPedGiftLookup
	shared.tblForceReceiveLookup = tblForceReceiveLookup
	shared.tblPedRequestedGift = tblPedRequestedGift
	shared.missionCode = missionCode
	local giftType = tblGiftTypeLookup[giftModel]
	--assert(giftType ~= nil, "ERROR LibSocial: Unable to find gift type for gift model " .. tostring(giftModel) .. tostring(" (needs to be added to tblGiftTypeLookup[] in LibSocial.lua)"))
	tblPedGiftLookup[pedID] = giftModel
	tblForceReceiveLookup[pedID] = forceReceive
	if forceReceive then
		PedSocialOverrideLoad(18, "Mission/" .. (missionCode and missionCode .. "AskAboutGift.act" or "AskAboutGift.act"))
		PedUseSocialOverride(pedID, 24, true)
		PedOverrideSocialResponseToStimulus(pedID, 10, 18)
	else
		PedSocialOverrideLoad(24, "Mission/" .. (missionCode and missionCode .. "RequestGift.act" or "RequestGift.act"))
		PedSocialOverrideLoad(18, "Mission/" .. (missionCode and missionCode .. "AskAboutGift.act" or "AskAboutGift.act"))
		PedUseSocialOverride(pedID, 24, true)
	end
	PedSocialOverrideLoad(4, "Mission/" .. (missionCode and missionCode .. "ReceiveGift.act" or "ReceiveGift.act"))
	PedUseSocialOverride(pedID, 4, true)
	PlayerSocialOverrideLoad(32, "Mission/" .. (shared.missionCode and shared.missionCode .. "GiveGift.act" or "GiveGift.act"))
	PlayerSocialEnableOverrideAgainstPed(pedID, 32, true)
	PedSetMissionCritical(pedID, true, L_SocialCriticalPedHitCallback, true)
	PlayerSocialDisableActionAgainstPed(pedID, 28, true)
	PlayerSocialDisableActionAgainstPed(pedID, 29, true)
	PedSetStationary(pedID, true)
	PedSetRequiredGift(pedID, giftType, false, forceReceive == true)
end

function L_SocialGiftPedCleanup(pedID)
	PedUseSocialOverride(pedID, 24, false)
	PedUseSocialOverride(pedID, 4, false)
	PedUseSocialOverride(pedID, 18, false)
	PlayerSocialEnableOverrideAgainstPed(pedID, 32, false)
	PedOverrideSocialResponseToStimulus(pedID, 10, 0)
	PedSetStationary(pedID, false)
	PedSetRequiredGift(pedID, 0)
end

function L_SocialGiftReceiveCallback(pedID)
end

function L_SocialGiftGiveCallback(pedID)
end

function L_SocialGiftRequestCallback(pedID)
end

function L_SocialGiftAskAboutCallback(pedID)
end

function L_SocialCriticalPedHitCallback(pedID)
	TextPrint("M_FAIL", 3, 1)
	SoundPlayMissionEndMusic(false, 10)
	MissionFail()
end

function L_SocialCleanup()
	for pedID, gift in tblPedGiftLookup do
		if PedIsValid(pedID) then
			PedUseSocialOverride(pedID, 24, false)
			PedUseSocialOverride(pedID, 4, false)
			PedUseSocialOverride(pedID, 18, false)
			PlayerSocialEnableOverrideAgainstPed(pedID, 32, false)
		end
	end
	shared.tblPedGiftLookup = nil
	shared.tblGiftTypeLookup = nil
	collectgarbage()
end

function L_SocialPedSetMissionCritical(pedID, state, callback, noViolence)
	--print("setting noViolence to " .. tostring(noViolence == nil or noViolence == true))
	PedSetMissionCritical(pedID, state, callback ~= nil and callback or L_SocialCriticalPedHitCallback, noViolence == nil or noViolence == true)
end

function L_SocialGiftAskAbout(pedID)
	L_SocialGiftAskAboutCallback(pedID)
end

function L_SocialGiftReceive(pedID)
	PedStopSocializing(pedID)
	L_SocialGiftReceiveCallback(pedID)
	L_SocialGiftPedCleanup(pedID)
end

function L_SocialGiftRequest(pedID)
	if not tblForceReceiveLookup[pedID] then
		PedOverrideSocialResponseToStimulus(pedID, 10, 18)
	end
	L_SocialGiftRequestCallback(pedID)
end

function L_SocialPlayerGiftGive()
	L_SocialGiftGiveCallback(gPlayer)
end

function L_SocialPedStopSocializing(pedID)
	PedStopSocializing(pedID)
end
