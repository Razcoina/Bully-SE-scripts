local tblTagTypes = {}
tblTagTypes[0] = "/Global/Tags/Useable"
tblTagTypes[1] = "/Global/Tags/NotUseable/Tagged/NerdMed"
tblTagTypes[2] = "/Global/Tags/NotUseable/Tagged/JockMed"
tblTagTypes[3] = "/Global/Tags/NotUseable/Tagged/GreaserMed"
tblTagTypes[4] = "/Global/Tags/NotUseable/Tagged/PrepMed"
tblTagTypes[5] = "/Global/TagSmall/NotUseable/Tagged"
tblTagTypes[6] = "/Global/WBrush/NotUseable"
local tblTagDefault
local bMonitorTags = false
local tagType = "_Tag"
local tagDefaultGroupName = "_dTg"

function F_Nil()
	return
end

function F_DefaultForNil(originalValue, defaultValue)
	if originalValue == nil then
		return defaultValue
	end
	return originalValue
end

function F_TagTableInit()
	tblTagDefault = {
		OnClean = L_TagOnClean,
		OnTag = F_Nil,
		OnTagDone = F_Nil,
		OnTagFail = F_Nil,
		OnClear = F_Nil,
		clearNode = "/Global/Tags/Useable",
		clearFile = "/Act/Props/Tags.act",
		startNode = "/Global/Tags/Useable",
		startFile = "/Act/Props/Tags.act",
		taggedSmall = "/Global/TagSmall/NotUseable/Tagged",
		taggedMedium = "/Global/Tags/NotUseable/Tagged",
		taggedSmallAction = "/Global/TagSmall/PedPropsActions/IsPlayer/DrawVandalTag/ParametricTagging/Finished",
		taggedAction = "/Global/Tags/PedPropsActions/PerformTag/DrawMedTag/ParametricTagging/Finished",
		tagFailAction = nil
	}
end

function L_TagLoad(groupName, tagTable)
	errorFuncName = "L_TagLoad"
	--assert(tagTable ~= nil, errorFuncName .. ":  called with nil tagTable")
	F_TagTableInit()
	local i, tag
	local group = ValidateGroup(groupName, tagDefaultGroupName, tagType)
	for i, tag in tagTable do
		--assert(tag.id, errorFuncName .. ": Missing id (trigger ENUM) for tag: " .. tostring(i) .. " group: " .. tostring(group))
		local x, y, z = GetAnchorPosition(tag.id)
		tag.x = x
		tag.y = y
		tag.z = z
		tag.OnClean = tag.OnClean or tblTagDefault.OnClean
		tag.OnClear = tag.OnClear or tblTagDefault.OnClear
		tag.OnTag = tag.OnTag or tblTagDefault.OnTag
		tag.OnTagDone = tag.OnTagDone or tblTagDefault.OnTagDone
		tag.OnTagFail = tag.OnTagFail or tblTagDefault.OnTagFail
		tag.clearNode = tag.clearNode or tblTagDefault.clearNode
		tag.clearFile = tag.clearFile or tblTagDefault.clearFile
		tag.startNode = tag.startNode or tblTagDefault.startNode
		tag.startFile = tag.startFile or tblTagDefault.startFile
		tag.bCheckTag = F_DefaultForNil(tag.bCheckTag, true)
		tag.bIsCleaned = F_DefaultForNil(tag.bIsCleaned, false)
		tag.bIsTagged = F_DefaultForNil(tag.bIsTagged, false)
		tag.bClearTag = F_DefaultForNil(tag.bClearTag, false)
		tag.taggedSmallAction = tag.taggedSmallAction or tblTagDefault.taggedSmallAction
		tag.taggedAction = tag.taggedAction or tblTagDefault.taggedAction
		tag.bIsTagDone = false
		tag.clear_count = F_DefaultForNil(tag.clear_count, 0)
		tag.taggedSmall = F_DefaultForNil(tag.taggedSmall, tblTagDefault.taggedSmall)
		tag.taggedMedium = F_DefaultForNil(tag.taggedMedium, tblTagDefault.taggedMedium)
	end
	LT_Add(group, tagTable, tagType)
	L_TagExec(group, L_TagSet, "id", "startNode", "startFile")
end

function L_TagSet(idTrigger, strNode, strFile)
	if idTrigger ~= nil then
		if strNode ~= nil and strFile ~= nil then
			PAnimSetActionNode(idTrigger, strNode, strFile)
		end
	else
		--DebugPrint("L_TagSet: called with nil trigger id")
	end
end

function L_TagIsFaction(idTrigger, idTagType)
	if idTrigger ~= nil then
		if idTagType ~= nil then
			if tblTagTypes[idTagType] ~= nil then
				return PAnimIsPlaying(idTrigger, tblTagTypes[idTagType], true)
			else
				--DebugPrint("L_TagIsFaction: called with invalid TagType of " .. tostring(idTagType))
			end
		else
			--DebugPrint("L_TagIsFaction: called with nil TagType ENUM")
		end
	else
		--DebugPrint("L_TagIsFaction: called with nil trigger id")
	end
end

function L_ClearTag(idTag, intFrames)
	--assert(0 < intFrames, "L_ClearTag: Frames <= 0")
	LT_SetData(idTag, "bClearTag", true, tagType)
	LT_SetData(idTag, "clear_count", intFrames, tagType)
end

function L_TagOnClean(tag)
	L_HUDBlipRemove(tag)
end

function L_TagsAllSetTo(field, value, groupName)
	--assert(field ~= nil, "L_TagsAllSetTo: called with field = nil")
	--assert(value ~= nil, "L_TagsAllSetTo: called with value = nil")
	local group = ValidateGroup(groupName, tagDefaultGroupName, tagType)
	for i, tag in LT_Group(group) do
		if tag[field] then
			if tag[field] ~= value then
				return false
			end
		else
			return false
		end
	end
end

function F_MonitorTags()
	local i, j, group, tag
	local x, y, z = 0, 0, 0
	while not L_ObjectiveProcessingDone() or bMonitorTags do
		for i, group in LT_LibTable() do
			if LT_Type(i) == tagType then
				for j, tag in group do
					if tag.bCheckTag then
						x, y, z = GetAnchorPosition(tag.id)
						if PlayerIsInAreaXYZ(x, y, z, 15, 0) then
							if tag.bIsTagDone and not tag.bIsCleaned and PAnimIsPlaying(tag.id, "/Global/TagSmall/Useable", false) then
								PAnimSetActionNode(tag.id, "/Global/TagSmall/NotUseable/Tagged/VandalTag", "/Act/Props/TagSmall.act")
							elseif tag.bClearTag then
								tag.clear_count = tag.clear_count - 1
								if 0 >= tag.clear_count then
									PAnimSetActionNode(tag.id, tag.clearNode, tag.clearFile)
									tag.bClearTag = false
									tag.bIsTagged = false
									if tag.OnClear ~= nil then
										tag.OnClear(tag)
									end
								end
							elseif tag.bIsTagged and not tag.bIsCleaned and PAnimIsPlaying(tag.id, tblTagTypes[6], false) then
								tag.bIsTagged = false
								tag.bIsCleaned = true
								if tag.OnClean then
									tag.OnClean(tag)
								end
							elseif not tag.bIsTagged then
								if PAnimIsPlaying(tag.id, tag.taggedSmall, true) or PAnimIsPlaying(tag.id, tag.taggedMedium, true) then
									tag.bIsTagged = true
									tag.bIsCleaned = false
									if tag.OnTag ~= nil then
										tag.OnTag(tag)
									end
								end
							elseif not tag.bIsTagDone and tag.bIsTagged and (PedIsPlaying(gPlayer, tag.taggedAction, false) or PedIsPlaying(gPlayer, tag.taggedSmallAction, false)) then
								tag.bIsTagDone = true
								tag.bIsCleaned = false
								if tag.OnTagDone ~= nil then
									tag.OnTagDone(tag)
								end
							end
						end
					end
				end
			end
		end
		Wait(0)
	end
	collectgarbage()
end

function T_MonitorTags()
	F_MonitorTags()
end

function L_MonitorTags()
	bMonitorTags = true
	F_MonitorTags()
end

function L_StopMonitoringTags()
	bMonitorTags = false
end

function L_TagExec(groupName, func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
	errorFuncName = "L_TagExec"
	local group = ValidateGroup(groupName, tagDefaultGroupName, tagType)
	LT_GroupFunction(group, func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
end

function L_TagSetData(tagID, field, value)
	--assert(field ~= "id", "L_TagSetData: Don't try to modify the ID directly !!!")
	LT_SetData(tagID, field, value, tagType)
end

function L_TagGetData(tagID, field)
	return LT_GetData(tagID, field, tagType)
end

function L_TagGetTag()
	return tblTagTypes
end

function TagsInit()
	LoadActionTree("/Act/Props/Tags.act")
end
