local __dTable = {}
local __dType = {}
local errorFuncName

function LT_Add(group, data, typename)
	errorFuncName = "LT_Add"
	if not __dTable[group] then
		__dTable[group] = {}
		__dType[group] = typename
	else
		--assert(__dType[group] == typename, errorFuncName .. ": " .. __dType[group] .. " table already exists with name " .. group)
	end
	for i, element in data do
		for j, field in element do
			--assert(field ~= nil, LT__ErrorField(j .. " is nil"))
		end
		if type(i) == "number" then
			table.insert(__dTable[group], element)
		else
			--assert(__dTable[group][i] == nil, errorFuncName .. ": tried to insert element with index " .. i .. " into group " .. group .. ", but element already exists")
			__dTable[group][i] = element
		end
	end
end

function LT_Delete(group)
	errorFuncName = "LT_Delete"
	--assert(__dTable[group], errorFuncName .. ": " .. group .. " does not exist.")
	__dTable[group] = nil
	__dType[group] = nil
end

function LT_FindElement(field, value, type)
	local found = false
	for i, group in __dTable do
		if __dType[i] == type then
			for j, element in group do
				if element[field] == value then
					return element
				end
			end
		end
	end
end

function LT_LibTable()
	return __dTable
end

function LT_Group(group)
	if __dTable[group] == nil then
		--DebugPrint("group " .. group .. " not found")
	end
	return __dTable[group]
end

function LT_Type(group)
	return __dType[group]
end

function LT_GetData(id, field, type)
	local elementFound = LT_FindElement("id", id, type)
	if elementFound then
		return elementFound[field]
	end
end

function LT_SetData(id, field, value, type)
	errorFuncName = "LT_SetData"
	local elementFound = LT_FindElement("id", id, type)
	--assert(field ~= nil, LT__ErrorField(field .. " field name is invalid"))
	if elementFound then
		elementFound[field] = value
	end
end

function LT_SetGroupData(group, field, value)
	errorFuncName = "LT_SetGroupData"
	--assert(field ~= nil, LT__ErrorField(field .. " field name is invalid"))
	for i, element in __dTable[group] do
		element[field] = value
	end
end

function LT_GroupSize(group)
	local count = 0
	for i, element in __dTable[group] do
		count = count + 1
	end
	return count
end

function LT_GroupFunction(group, funcName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
	for i, element in __dTable[group] do
		funcName(LT_GetArgs(element, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20))
	end
end

function LT_TypeFunction(type, funcName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
	for i, group in __dTable do
		if __dType[i] == type then
			for j, element in group do
				funcName(LT_GetArgs(element, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20))
			end
		end
	end
end

function LT_IndexFunction(type, index, funcName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
	for i, group in __dTable do
		local element = group[index]
		if __dType[i] == type and element then
			funcName(LT_GetArgs(element, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20))
		end
	end
end

function LT_FieldFunction(type, field, value, funcName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
	for i, group in __dTable do
		if __dType[i] == type then
			for j, element in group do
				if element[field] == value then
					funcName(LT_GetArgs(element, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20))
				end
			end
		end
	end
end

function LT_GroupObjectCreate(group, funcName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
	for i, element in __dTable[group] do
		if not element.id then
			element.id = funcName(LT_GetArgs(element, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20))
		end
	end
end

function LT_GetArgs(element, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
	if arg1 ~= nil then
		if element[arg1] ~= nil then
			arg1 = element[arg1]
		end
		if arg1 == "element" then
			arg1 = element
		end
		return arg1, LT_GetArgs(element, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
	end
end

function LT_GroupIterateWith(group, funcName)
	for i, element in __dTable[group] do
		if element then
			funcName(element)
		end
	end
end

function LT_Cleanup()
	__dTable = nil
	__dType = nil
	collectgarbage()
end

function LT__ErrorGroup(groupMsg)
	return errorFuncName .. ": Group " .. groupMsg
end

function LT__ErrorField(fieldMsg)
	return errorFuncName .. ": Field(s): " .. fieldMsg
end

function ValidateGroup(groupName, defaultGroupName, type)
	groupName = groupName or defaultGroupName
	if __dType[groupName] then
		--assert(__dType[groupName] == type, errorFuncName .. ": Group ", group, " is not a " .. type .. " group")
	end
	return groupName
end
