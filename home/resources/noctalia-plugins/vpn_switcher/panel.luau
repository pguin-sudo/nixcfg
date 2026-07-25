--!nonstrict
-- VPN Switcher -- profile list panel.
--
-- Mirrors "profiles" / "status" published by the headless service and drives
-- connect/disconnect through the "command" channel -- no vpnctl calls here.

local profiles = {}
local pending = false
local linkText = ""
-- Bumped on every successful submit so the input node gets a fresh key,
-- which makes the host recreate it empty -- an "input" node is uncontrolled,
-- its `value` prop only seeds the field once, at creation.
local addInputGeneration = 0

local render

-- Per-row callbacks need distinct global names (the reconciler dispatches
-- callbacks by name only); pattern lifted from the official notes plugin's
-- panel.luau. getfenv() is the script environment the host reads globals
-- from, so assigning into it defines the callback the host will find.
local env = getfenv()
local function rowCallback(prefix, key, fn)
    local name = prefix .. "_" .. key
    env[name] = fn
    return name
end

-- Rows are keyed by profile name (globally unique, vpnctl-enforced) rather
-- than list position, so callback identity survives regrouping between
-- renders instead of drifting if item order changes.
local function row(p)
    local statusText = if p.active then noctalia.tr("panel.status-active") else p.state
    local actionText = if p.active then noctalia.tr("panel.disconnect") else noctalia.tr("panel.connect")
    -- "label" is the server's own name from the subscription (e.g. a flag +
    -- country); p.name is just the filesystem/unit-safe slug vpnctl derived
    -- from it, not meant for display when something nicer is available. No
    -- per-row type badge -- every row in a group is the same type as its
    -- header (obviously sing-box, since only sing-box comes from a link),
    -- and a lone standalone row is the only other profile in the panel.
    local label = if type(p.label) == "string" and p.label ~= "" then p.label else p.name

    local subtitle = {}
    if type(p.server) == "string" and p.server ~= "" then
        table.insert(subtitle, ui.label({ text = p.server, color = "on_surface_variant", fontSize = 11 }))
    end
    table.insert(subtitle, ui.label({ text = statusText, color = "on_surface_variant", fontSize = 11 }))

    local children = {
        ui.box({
            width = 8,
            height = 8,
            radius = 4,
            fill = if p.active then "primary" else "outline",
        }),
        ui.column({ flexGrow = 1, gap = 2 }, {
            ui.label({ text = label, color = "on_surface", fontWeight = "medium" }),
            ui.row({ gap = 6 }, subtitle),
        }),
        ui.button({
            glyph = if p.active then "player-stop" else "player-play",
            tooltip = actionText,
            variant = if p.active then "ghost" else "primary",
            enabled = not pending,
            onClick = rowCallback("vpnRow", p.name, function()
                if p.active then
                    noctalia.state.set("command", { action = "disconnect", name = p.name })
                else
                    noctalia.state.set("command", { action = "connect", name = p.name })
                end
            end),
        }),
    }

    -- Delete lives here only for a standalone profile (no subscription
    -- group to carry a single group-level delete instead) -- see
    -- groupBlock() for the subscription case, one button removes them all.
    if p.dynamic and not p.has_subscription then
        table.insert(
            children,
            ui.button({
                glyph = "trash",
                variant = "destructive",
                enabled = not pending,
                onClick = rowCallback("vpnDel", p.name, function()
                    noctalia.state.set("command", { action = "remove-source", name = p.name })
                end),
            })
        )
    end

    return ui.row({ key = "profile-" .. p.name, gap = 10, align = "center" }, children)
end

-- Profiles sharing a subscription URL (a Remnawave link commonly bundles
-- several servers) render as one card with a single header-level refresh,
-- instead of a flat list a 15-server subscription would turn into.
local function buildGroups(list)
    local order = {}
    local byKey = {}
    for _, p in ipairs(list) do
        local key = if type(p.group) == "string" and p.group ~= "" then p.group else p.name
        local g = byKey[key]
        if g == nil then
            g = {
                key = key,
                label = if type(p.group_label) == "string" and p.group_label ~= "" then p.group_label else p.name,
                hasSubscription = p.has_subscription == true,
                items = {},
            }
            byKey[key] = g
            table.insert(order, g)
        end
        table.insert(g.items, p)
    end
    return order
end

local function groupBlock(g)
    local itemRows = {}
    for _, p in ipairs(g.items) do
        table.insert(itemRows, row(p))
    end

    -- A lone, non-subscription profile (a plain AmneziaWG import) doesn't
    -- need its own card chrome -- that would just be visual noise around a
    -- single row repeating the same name.
    if not g.hasSubscription and #g.items <= 1 then
        return itemRows[1]
    end

    local headerChildren = {
        ui.label({
            text = g.label,
            color = "on_surface_variant",
            fontSize = 11,
            fontWeight = "medium",
            flexGrow = 1,
        }),
    }
    if g.hasSubscription then
        table.insert(
            headerChildren,
            ui.button({
                glyph = "refresh",
                variant = "ghost",
                enabled = not pending,
                -- One fetch, every profile from this link refreshed together --
                -- see vpnctl sync-source (refetching per-profile would mean
                -- re-fetching the same subscription once per server on it).
                onClick = rowCallback("vpnSync", g.key, function()
                    noctalia.state.set("command", { action = "sync-source", url = g.key })
                end),
            })
        )
        table.insert(
            headerChildren,
            ui.button({
                glyph = "trash",
                variant = "destructive",
                enabled = not pending,
                -- One button for the whole link, not one per server -- see
                -- vpnctl remove-group. Kept destructive-styled (not ghost,
                -- like refresh) since misclicking this removes every server
                -- under the subscription, not just one.
                onClick = rowCallback("vpnDelGroup", g.key, function()
                    noctalia.state.set("command", { action = "remove-group", url = g.key })
                end),
            })
        )
    end

    return ui.column({ key = "group-" .. g.key, gap = 8, align = "stretch", fill = "surface_variant", radius = 8, padding = 8 }, {
        ui.row({ align = "center", gap = 8 }, headerChildren),
        ui.column({ gap = 8, align = "stretch" }, itemRows),
    })
end

local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

local function submitLink()
    local link = trim(linkText)
    if link == "" then
        return
    end
    noctalia.state.set("command", { action = "add-source", link = link })
    linkText = ""
    addInputGeneration = addInputGeneration + 1
    render()
end

function onAddSourceChange(value)
    linkText = value
end

function onAddSourceSubmit(_value)
    submitLink()
end

function onAddSourceClicked()
    submitLink()
end

local function addSourceRow()
    return ui.row({ key = "add-source", gap = 8, align = "center" }, {
        ui.input({
            key = "add-source-input-" .. addInputGeneration,
            flexGrow = 1,
            placeholder = noctalia.tr("panel.add-placeholder"),
            enabled = not pending,
            onChange = "onAddSourceChange",
            onSubmit = "onAddSourceSubmit",
        }),
        ui.button({
            text = noctalia.tr("panel.add-button"),
            variant = "primary",
            enabled = not pending,
            onClick = "onAddSourceClicked",
        }),
    })
end

render = function()
    local blocks = {}
    for _, g in ipairs(buildGroups(profiles)) do
        table.insert(blocks, groupBlock(g))
    end
    if #blocks == 0 then
        table.insert(blocks, ui.label({ text = noctalia.tr("panel.empty"), color = "on_surface_variant" }))
    end

    panel.render(ui.column({ flexGrow = 1, gap = 16 }, {
        ui.row({ align = "center", justify = "space_between", gap = 8 }, {
            ui.label({
                text = noctalia.tr("panel.title"),
                fontSize = 16,
                fontWeight = "bold",
                color = "on_surface",
                flexGrow = 1,
            }),
            ui.button({ glyph = "close", variant = "ghost", onClick = "onCloseClicked" }),
        }),
        ui.scroll({ flexGrow = 1, gap = 8, align = "stretch" }, blocks),
        ui.separator({}),
        addSourceRow(),
    }))
end

local function applyProfiles(value)
    profiles = if type(value) == "table" then value else {}
    render()
end

local function applyStatus(status)
    pending = type(status) == "table" and status.pending == true
    render()
end

function onOpen(_context)
    applyProfiles(noctalia.state.get("profiles"))
    applyStatus(noctalia.state.get("status"))
    -- Ask the service for a fresh read the moment the panel opens, rather
    -- than waiting for the next 2.5s tick.
    noctalia.state.set("command", { action = "refresh" })
end

noctalia.state.watch("profiles", applyProfiles)
noctalia.state.watch("status", applyStatus)

function onCloseClicked()
    panel.close()
end
