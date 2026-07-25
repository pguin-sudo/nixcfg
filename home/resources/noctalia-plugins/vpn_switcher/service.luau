--!nonstrict
-- VPN Switcher -- headless service.
--
-- Owns polling vpnctl and driving connect/disconnect for the whole session,
-- so vpnctl's own mutual-exclusion/timeout/locking logic is the only place
-- that logic lives (see pkgs/vpnctl). The widget and panel are thin clients:
-- they read the published "profiles" / "status" and drive this service by
-- writing to the "command" channel.

noctalia.setUpdateInterval(2500)

local busy = false -- true while a connect/disconnect vpnctl call is in flight

local function log(msg)
    noctalia.log(`vpn_switcher: {msg}`)
end

local function shellQuote(value)
    return "'" .. value:gsub("'", [['"'"']]) .. "'"
end

-- Fast, read-only: `vpnctl list`/`status --json` are just a handful of
-- `systemctl is-active` + `ip link/route show` calls, safe at this cadence.
local function refresh()
    if busy then
        return
    end

    noctalia.runAsync("vpnctl list --json", function(result)
        if result.exitCode == 0 then
            local decoded = noctalia.json.decode(result.stdout)
            if decoded ~= nil then
                noctalia.state.set("profiles", decoded)
            end
        else
            log(`list failed: {result.stderr}`)
        end
    end, 5000)

    noctalia.runAsync("vpnctl status --json", function(result)
        if result.exitCode == 0 then
            local decoded = noctalia.json.decode(result.stdout)
            if decoded ~= nil then
                noctalia.state.set("status", { pending = false, data = decoded })
            end
        else
            log(`status failed: {result.stderr}`)
        end
    end, 5000)
end

local function runVpnctl(args, timeoutMs)
    busy = true
    noctalia.state.set("status", { pending = true })
    noctalia.runAsync(`vpnctl {args}`, function(result)
        busy = false
        if result.exitCode ~= 0 then
            log(`'{args}' failed: {result.stderr}`)
            noctalia.notifyError(noctalia.tr("notify.failed-title"), result.stderr)
        end
        refresh()
    end, timeoutMs or 15000)
end

function onIpc(event, payload)
    local name = if type(payload) == "table" then payload.name else payload

    if event == "connect" and type(name) == "string" and name ~= "" then
        log(`connect {name}`)
        runVpnctl(`connect {shellQuote(name)}`)
    elseif event == "disconnect" then
        if type(name) == "string" and name ~= "" then
            log(`disconnect {name}`)
            runVpnctl(`disconnect {shellQuote(name)}`)
        else
            log("disconnect (active)")
            runVpnctl("disconnect")
        end
    elseif event == "add-source" then
        local link = if type(payload) == "table" then payload.link else nil
        if type(link) == "string" and link ~= "" then
            log("add-source")
            -- A subscription can bundle a dozen-plus servers, each written
            -- individually -- give it more room than a plain connect/disconnect.
            runVpnctl(`add-source {shellQuote(link)}`, 30000)
        end
    elseif event == "remove-source" and type(name) == "string" and name ~= "" then
        log(`remove-source {name}`)
        runVpnctl(`remove-source {shellQuote(name)}`)
    elseif event == "remove-group" then
        local url = if type(payload) == "table" then payload.url else nil
        if type(url) == "string" and url ~= "" then
            log("remove-group")
            runVpnctl(`remove-group {shellQuote(url)}`, 30000)
        end
    elseif event == "sync-source" then
        local url = if type(payload) == "table" then payload.url else nil
        if type(url) == "string" and url ~= "" then
            log("sync-source")
            runVpnctl(`sync-source {shellQuote(url)}`, 30000)
        end
    elseif event == "refresh" then
        refresh()
    else
        log(`unknown command '{event}'`)
    end
end

-- Widget/panel drive this service through the shared state channel.
noctalia.state.watch("command", function(cmd)
    local action = if type(cmd) == "table" and cmd.action ~= nil then cmd.action else cmd
    if type(action) == "string" then
        onIpc(action, if type(cmd) == "table" then cmd else nil)
    end
end)

function update()
    refresh()
end
