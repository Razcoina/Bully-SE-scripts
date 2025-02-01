--[[ Changes ti this file:
    * Modified function main, may require testing
]]

gameprint = print

function print(...)
    str = "print|" .. table.concat(arg, "\t")
    SendDebugMessage(str)
    gameprint(str)
end

function HandlePCMessage(cmd, param)
    if cmd == "launch" then
        local success, err
        success, err = pcall(LaunchScript, param)
        if success == false then
            SendDebugMessage("execerr|" .. err)
        end
    elseif cmd == "startMission" then
        local success, err
        success, err = pcall(ForceStartMission, param)
        if success == false then
            SendDebugMessage("execerr|" .. err)
        end
    elseif cmd == "exec" then
        local f, err
        f, err = loadstring(param, "<remote exec>")
        if f == nil then
            SendDebugMessage("execerr|" .. err)
        else
            local success, err
            setfenv(f, getfenv())
            success, err = pcall(f)
            if success == false then
                SendDebugMessage("execerr|" .. err)
            end
        end
    end
end

function main() -- ! Modified
    if GetNextDebugMessage == nil then
        --print("GetNextDebugMessage function not defined; RemoteDebug script exiting.")
        --[[
        do return end
        ]] -- Changed to:
        return
        --[[
        while true do
            local cmd, param
            cmd, param = GetNextDebugMessage()
            if cmd == nil then
                Wait(0)
            else
                HandlePCMessage(cmd, param)
            end
        end
        ]] -- Moved this outside the if
    end
    while true do
        local cmd, param
        cmd, param = GetNextDebugMessage()
        if cmd == nil then
            Wait(0)
        else
            HandlePCMessage(cmd, param)
        end
    end
end
