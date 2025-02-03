local _GG = _G
shared = {}
local _Import = ImportScript

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

local _nspaces = {}

function CreateNameSpace(filename)
    local nst = {}
    --assert(not _nspaces[filename], "Namespace exists")
    _nspaces[filename] = nst
    nst.file = filename
    local func_env = {}
    nst.func_env = func_env
    setmetatable(func_env, { __index = _GG })

    function func_env.ImportScript(impfile)
        local scr = _Import(impfile)
        setfenv(scr, func_env)
        scr()
    end

    function func_env._Thread(funcstr)
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

    local function namespace(file)
        --assert(func_env and type(func_env) == "table")
        setfenv(1, func_env)
        local scr = _Import(filename)
        setfenv(scr, func_env)
        scr()
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

function KillNameSpace(filename)
    _nspaces[filename] = nil
    --print("Threads left after kill:")
end

function NSCall(filename, func, err, arg1, arg2, arg3, arg4, arg5, arg6)
    local nst = _nspaces[filename]
    if nst == nil then
        return nil
    end
    local fcall = nst.func_env._Call
    return fcall(func, err, arg1, arg2, arg3, arg4, arg5, arg6)
end
