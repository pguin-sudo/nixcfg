--!nonstrict
-- VPN Switcher -- bar widget (thin presentation client).
--
-- The service (service.luau) owns connect/disconnect and polling; this
-- widget only mirrors "status" and drives it through the command channel,
-- same as the panel does.
--
-- Colors: muted = disconnected, secondary/amber = unit active but not yet
-- routed (connecting, or something's wrong), primary/green = connected.

local pending = false
local active = nil -- { name, type, unit, interface, link_up, has_default_route } | nil
-- Remembers the last profile this widget saw active, so left-click has
-- something to reconnect to once disconnected -- otherwise "toggle" has no
-- meaning with nothing currently running.
local lastProfileName = nil

local function applyStatus(status)
    if type(status) ~= "table" then
        return
    end

    pending = status.pending == true
    active = if type(status.data) == "table" then status.data.active else nil
    if type(active) == "table" and type(active.name) == "string" then
        lastProfileName = active.name
    end

    if pending then
        barWidget.setGlyph("shield-exclamation")
        barWidget.setGlyphColor("secondary")
        barWidget.setTooltip(noctalia.tr("widget.connecting"))
        return
    end

    if active == nil then
        barWidget.setGlyph("shield")
        barWidget.setGlyphColor("on_surface_variant")
        barWidget.setTooltip(noctalia.tr("widget.disconnected"))
        return
    end

    local routed = active.link_up == true and active.has_default_route == true
    if routed then
        barWidget.setGlyph("shield-check")
        barWidget.setGlyphColor("primary")
    else
        -- Unit reports active but the interface/default route isn't up yet.
        barWidget.setGlyph("shield-exclamation")
        barWidget.setGlyphColor("secondary")
    end

    barWidget.setTooltip({
        { key = noctalia.tr("widget.tooltip-profile"), value = active.name },
        { key = noctalia.tr("widget.tooltip-type"), value = active.type },
    })
end

applyStatus(noctalia.state.get("status"))
noctalia.state.watch("status", applyStatus)

-- Left click: toggle the current (or last-seen) profile on/off directly,
-- no panel trip needed for the common case of "just flip my VPN". Right
-- click: open the panel, for picking a different profile or managing
-- sources.
function onClick()
    if pending then
        return
    end
    if active ~= nil then
        noctalia.state.set("command", { action = "disconnect", name = active.name })
    elseif lastProfileName ~= nil then
        noctalia.state.set("command", { action = "connect", name = lastProfileName })
    else
        -- Never connected this session -- nothing to toggle, so fall back
        -- to letting the user pick one.
        noctalia.togglePanel("pguin/vpn_switcher:panel")
    end
end

function onRightClick()
    noctalia.togglePanel("pguin/vpn_switcher:panel")
end
