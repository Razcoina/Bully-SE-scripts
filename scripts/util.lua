--[[ Changes to this file:
    * Removed unused local variables
    * Removed global variable gNS, not present in original script
    * Moved functions ImportScript, GlobalImportScript and NS_ON out of pseudo-goto
    * Entire pseudo-goto removed as well as all code besides previous stated functions, not present in original script
    * Removed function UPrintShared, not present in original script
    * Removed function GrecInit, not present in original script
    * Removed function GrecCheck , not present in original script
    * Modified function CreateNameSpace, may require testing
    * Modified local function namespace, may require testing
    * Modified function KillNameSpace, may require testing
]]

local _GG = _G
shared = {}
local _Import = ImportScript

--[[
repeat
    function ImportScript(file)
        _Import(file)()
    end

    function GlobalImportScript(file)
        print("Global import:", file)
        _Import(file)()
    end

    function NS_ON()
        ImportScript = nil
    end
    function RecordGW()
        setmetatable(_GG, {
            __newindex = function(t, k, v)
                print("new global", k, v)
                rawset(t, k, v)
            end
        })
    end

    do break end -- pseudo-goto
    setmetatable(shared, {
        __index = function(t, k)
            print("GET SHARED", k)
            return rawget(t, k)
        end,
        __newindex = function(t, k, v)
            print("SET SHARED", k, v)
            rawset(t, k, v)
        end
    })
until true
]] -- Not present in original script

function ImportScript(file)
    _Import(file)()
end

function GlobalImportScript(file)
    --print("Global import:", file)
    _Import(file)()
end

function NS_ON()
    ImportScript = nil
end

--[[
function UPrintShared()
    print(">>>> SHARED")
    for k, v in shared do
        print(k, tostring(v))
    end
end

local _grec

function GrecInit()
    _grec = {}
    for k, v in _GG do
        _grec[k] = 1
    end
end

function GrecCheck()
    local i = 0
    for k, v in _GG do
        if not _grec[k] then
            print("XXXXX Extra key:", k)
        end
        i = i + 1
    end
    print("GrecCheck checked ", i, "elements")
end
]] -- Not present in original script

local _nspaces = {}
--[[
gNS = {}
]]                                 -- Removed this

function CreateNameSpace(filename) -- ! Modified
    local nst = {}
    --assert(not _nspaces[filename], "Namespace exists")
    _nspaces[filename] = nst
    nst.file = filename
    local func_env = {}
    --[[
    gNS[filename] = func_env
    ]] -- Removed this
    nst.func_env = func_env
    setmetatable(func_env, { __index = _GG })

    function func_env.ImportScript(impfile)
        local scr = _Import(impfile)
        setfenv(scr, func_env)
        scr()
    end

    function func_env._Thread(funcstr) -- ! Modified
        local func
        if funcstr and type(funcstr) == "function" then
            func = funcstr
        else
            func = func_env[funcstr]
            --assert(func and type(func) == "function", "Bad thread function " .. tostring(funcstr))
        end

        local function wrapped()
            func()
        end

        setfenv(wrapped, func_env)
        return coroutine.create(wrapped)
    end

    function func_env._Call(func, err, arg1, arg2, arg3, arg4, arg5, arg6)
        local func = func_env[func]
        if func or err then
            --assert(func and type(func) == "function", "A function is being called that doesnt exist or not type function: " .. tostring(func))
            return func(arg1, arg2, arg3, arg4, arg5, arg6)
        end
        return 0
    end

    local function namespace(file) -- ! Modified
        --assert(func_env and type(func_env) == "table")
        setfenv(1, func_env)
        local scr = _Import(filename)
        setfenv(scr, func_env)
        scr()
        --[[
        _scope1 = 111
        ]] -- Removed this
        coroutine.yield()
    end

    --assert(_scope1 == nil)
    local co = coroutine.create(namespace)
    local res = coroutine.resume(co, filename)
    return co
end

function ThreadNameSpace(filename, func)
    --print("ThreadNameSpace", filename, func)
    local nst = _nspaces[filename]
    --assert(nst)
    return nst.func_env._Thread(func)
end

function KillNameSpace(filename) -- ! Modified
    _nspaces[filename] = nil
    --[[
    gNS[filename] = nil
    ]] -- Removed this
    --print("Threads left after kill:")
    --[[
    for k, v in _nspaces do
        print("_nspace -", k, v)
    end
    ]] -- Removed this
end

function NSCall(filename, func, err, arg1, arg2, arg3, arg4, arg5, arg6)
    local nst = _nspaces[filename]
    if nst == nil then
        return nil
    end
    local fcall = nst.func_env._Call
    return fcall(func, err, arg1, arg2, arg3, arg4, arg5, arg6)
end
