-- Hammerspoon config mirroring the SUPER (⌘) binds from hypr/hyprland.lua.
-- Target: Hammerspoon 1.1.1 on macOS 26 (spaces are integer IDs, no
-- :visibleFrame, no window :level). Reload: menu bar icon → Reload.
-- Not a WM: no borders, no master layout, no always-on-top
-- (float = excluded from the tiler).
-- per-machine
local apps = {
	terminal = "Alacritty",
	fileManager = "Finder", -- hyprland uses strata (Linux-only)
	browser = "Zen",
	obsidian = "Obsidian",
}
local mod = { "cmd" } -- SUPER == Command
local GAP = 3
local ANIM = 0.15
local MENUBAR = 25 -- top inset; bump for a taller menu bar

hs.window.animationDuration = ANIM

-- launchers. Native stand-ins for the rest: Spotlight = menu,
-- Ctrl+Cmd+Q = lock, Cmd+Shift+4 = slurp, Ctrl+Cmd+F = fullscreen.
local function launch(name)
	hs.application.launchOrFocus(name)
end
hs.hotkey.bind(mod, "S", function() launch(apps.terminal) end)
hs.hotkey.bind(mod, "W", function() launch(apps.fileManager) end)
hs.hotkey.bind(mod, "Q", function() launch(apps.browser) end)
hs.hotkey.bind({ "cmd", "shift" }, "A", function() launch(apps.obsidian) end)
hs.hotkey.bind(mod, "`", function() -- close focused window
	local w = hs.window.focusedWindow()
	if w then w:close() end
end)
hs.hotkey.bind(mod, "escape", function() -- quit active app
	local a = hs.application.frontmostApplication()
	if a then a:kill() end
end)
hs.hotkey.bind(mod, "M", function() -- shut down
	hs.osascript.applescript('tell application "System Events" to shut down')
end)

-- tiler: N managed windows = N equal columns (1 window = full, i.e.
-- hyprland's fullscreen_on_one_column); floating windows stay put
local floating = {} -- window ids excluded from tiling
local SYSTEM_APPS = { -- windows that must never be tiled
	["Notification Center"] = true, -- macOS/iPhone notification banners
	["UserNotificationCenter"] = true, -- older name for the same
	["Spotlight"] = true, -- macOS ⌘Space search bar
}

local function isManaged(w)
	local a = w.application and w:application()
	if a and SYSTEM_APPS[a:name()] then
		return false
	end
	return w:isVisible() and not w:isMinimized() and not floating[w:id()]
		and w:id() ~= 0 -- skip the desktop background window
end

local managedFilter = hs.window.filter.new(function(w)
	return w ~= nil and isManaged(w)
end)
-- managed windows on the CURRENT space of each display (the filter also
-- sees windows on other spaces; windowSpaces tells us where they really are)
local function managedWindows()
	local here = {}
	for _, sid in pairs(hs.spaces.activeSpaces() or {}) do
		here[sid] = true
	end
	local out = {}
	for _, w in ipairs(managedFilter:getWindows()) do
		local ws = hs.spaces.windowSpaces(w:id())
		local onCur = #ws == 0 -- unknown space membership: keep current behavior
		for _, sid in ipairs(ws) do
			if here[sid] then
				onCur = true
				break
			end
		end
		if onCur then
			out[#out + 1] = w
		end
	end
	return out
end

local function center(w)
	local f = w:frame()
	return { x = f.x + f.w / 2, y = f.y + f.h / 2 }
end

local function frameContains(f, p)
	return p.x >= f.x and p.x < f.x + f.w and p.y >= f.y and p.y < f.y + f.h
end

local function screenOfPoint(p)
	for _, s in ipairs(hs.screen.allScreens()) do
		if frameContains(s:frame(), p) then
			return s
		end
	end
	return hs.screen.primaryScreen()
end

local function screenOf(w)
	return screenOfPoint(center(w))
end

local function setKey(wins)
	local ids = {}
	for _, w in ipairs(wins) do
		ids[#ids + 1] = tostring(w:id())
	end
	table.sort(ids)
	return table.concat(ids, ",")
end

local function tileRect(screen)
	local f = screen:frame()
	return { x = f.x, y = f.y + MENUBAR, w = f.w, h = f.h - MENUBAR }
end

local function targetFrames(screen, n)
	local f = tileRect(screen)
	if n == 1 then
		return { f }
	end
	local colw = (f.w - (n - 1) * GAP) / n
	local frames = {}
	for i = 1, n do
		frames[i] = { x = f.x + (i - 1) * (colw + GAP), y = f.y, w = colw, h = f.h }
	end
	return frames
end

local function frameSettled(a, b)
	return math.abs(a.x - b.x) <= 1 and math.abs(a.y - b.y) <= 1
		and math.abs(a.w - b.w) <= 1 and math.abs(a.h - b.h) <= 1
end

local function tileNow()
	local groups = {}
	for _, w in ipairs(managedWindows()) do
		-- key by screen id: screen userdata is not identity-stable
		local s = screenOf(w)
		local g = groups[s:id()] or { screen = s, wins = {} }
		groups[s:id()] = g
		g.wins[#g.wins + 1] = w
	end
	for _, g in pairs(groups) do
		table.sort(g.wins, function(a, b)
			return a:frame().x < b:frame().x
		end)
		local frames = targetFrames(g.screen, #g.wins)
		for i, w in ipairs(g.wins) do
			if not frameSettled(w:frame(), frames[i]) then
				w:move(frames[i])
			end
		end
	end
end

-- re-tile only when the managed SET changes; the 0.75s poll covers
-- windowCreated events the filter drops for windows invisible at birth.
-- lastSet advances on success only, so a failed tile retries next tick.
local lastSet, pending, tilingPaused = nil, false, false
local function scheduleTile()
	if pending or tilingPaused then
		return
	end
	pending = true
	hs.timer.doAfter(0.25, function()
		pending = false
		local k = setKey(managedWindows())
		if k ~= lastSet and pcall(tileNow) then
			lastSet = k
		end
	end)
end

for _, e in ipairs({ "windowCreated", "windowDestroyed", "windowMinimized", "windowUnminimized" }) do
	managedFilter:subscribe(hs.window.filter[e], scheduleTile)
end
hs.timer.doEvery(0.75, scheduleTile)
hs.screen.watcher.new(scheduleTile)
hs.hotkey.bind({ "cmd", "ctrl" }, "R", tileNow) -- force re-tile

-- focus & move: vim keys, wraps horizontally (hyprland: SUPER+hjkl / +SHIFT)
local function overlap(a, b)
	local x = math.min(a.x + a.w, b.x + b.w) - math.max(a.x, b.x)
	local y = math.min(a.y + a.h, b.y + b.h) - math.max(a.y, b.y)
	return math.max(0, x), math.max(0, y)
end

local function candidates(c)
	local cs = screenOf(c)
	local out = {}
	for _, w in ipairs(managedWindows()) do
		if w:id() ~= c:id() and screenOf(w):id() == cs:id() then
			out[#out + 1] = w
		end
	end
	return out
end

-- best window strictly in the dx/dy direction; score = distance minus overlap
local function pick(cands, c, dx, dy)
	local cf = c:frame()
	local best, bestScore
	for _, w in ipairs(cands) do
		local f = w:frame()
		local ok = (dx > 0 and f.x >= cf.x + cf.w - 2)
			or (dx < 0 and f.x + f.w <= cf.x + 2)
			or (dy > 0 and f.y >= cf.y + cf.h - 2)
			or (dy < 0 and f.y + f.h <= cf.y + 2)
		if ok then
			local ox, oy = overlap(f, cf)
			local dist = (dx ~= 0) and math.abs(f.x - cf.x) or math.abs(f.y - cf.y)
			local score = dist - (dx ~= 0 and oy or ox)
			if not best or score < bestScore then
				best, bestScore = w, score
			end
		end
	end
	return best
end

-- nothing in that direction: wrap to the outermost column/row
local function edgeWrap(cands, dx, dy)
	local best
	for _, w in ipairs(cands) do
		if not best then
			best = w
		elseif dx > 0 then
			if w:frame().x < best:frame().x then best = w end
		elseif dx < 0 then
			if w:frame().x > best:frame().x then best = w end
		elseif dy > 0 then
			if w:frame().y > best:frame().y then best = w end
		else
			if w:frame().y < best:frame().y then best = w end
		end
	end
	return best
end

local function focusIn(dx, dy)
	local c = hs.window.focusedWindow()
	if not c then
		return
	end
	local cands = candidates(c)
	local t = pick(cands, c, dx, dy) or (dx ~= 0 and edgeWrap(cands, dx, dy))
	if t then
		t:focus()
	end
end

local function moveIn(dx, dy) -- swap frames with the target
	local c = hs.window.focusedWindow()
	if not c then
		return
	end
	local t = pick(candidates(c), c, dx, dy)
	if t then
		local cf, tf = c:frame(), t:frame()
		c:move(tf)
		t:move(cf)
	end
end

local DIRS = { h = { -1, 0 }, l = { 1, 0 }, k = { 0, -1 }, j = { 0, 1 } }
for key, d in pairs(DIRS) do
	hs.hotkey.bind(mod, key, function() focusIn(d[1], d[2]) end)
	hs.hotkey.bind({ "cmd", "shift" }, key, function() moveIn(d[1], d[2]) end)
end

-- move focused window to the other monitor (hyprland: SUPER+ALT+h/l)
local function screenInDirection(current, dir)
	local cf = current:frame()
	local best, bestDist
	for _, s in ipairs(hs.screen.allScreens()) do
		if s:id() ~= current:id() then
			local f = s:frame()
			-- 100pt tolerance so near-vertical arrangements still resolve
			local d = (dir > 0) and (f.x - (cf.x + cf.w)) or (cf.x - (f.x + f.w))
			if d > -100 and (not best or d < bestDist) then
				best, bestDist = s, d
			end
		end
	end
	return best
end

local function moveScreen(dir)
	local c = hs.window.focusedWindow()
	if not c then
		return
	end
	local t = screenInDirection(screenOf(c), dir)
	if t then
		c:move(tileRect(t))
		tileNow()
	end
end
hs.hotkey.bind({ "cmd", "alt" }, "h", function() moveScreen(-1) end)
hs.hotkey.bind({ "cmd", "alt" }, "l", function() moveScreen(1) end)

-- toggle tiling for the focused window (hyprland: SUPER+V float)
hs.hotkey.bind({ "cmd", "shift" }, "V", function()
	local w = hs.window.focusedWindow()
	if not w then
		return
	end
	if floating[w:id()] then
		floating[w:id()] = nil
	else
		floating[w:id()] = true
	end
	scheduleTile()
end)

-- workspaces: the Nth *user* space per display (macOS "Displays have
-- separate Spaces"). Cmd+N jumps; Cmd+Shift+N sends the focused window.
local function screenUserSpaces()
	local c = hs.window.focusedWindow()
	local s = c and screenOf(c) or hs.screen.primaryScreen()
	local all = hs.spaces.allSpaces()
	local ids = all and all[s:getUUID()] or nil
	local user = {}
	for _, id in ipairs(ids or {}) do
		if hs.spaces.spaceType(id) == "user" then
			user[#user + 1] = id
		end
	end
	return user
end

-- moveWindowToSpace is broken on macOS 15/26 (Hammerspoon #3698), so
-- simulate it: grab the title bar and drag to the screen edge — macOS
-- switches space with the window. One edge drag per space; needs the
-- Input Monitoring permission for Hammerspoon.
local function sendToSpace(targetIdx)
	local w = hs.window.focusedWindow()
	if not w then return end
	local sps = screenUserSpaces()
	local from, target = nil, nil
	local cur = hs.spaces.activeSpaceOnScreen()
	for i, id in ipairs(sps) do
		if id == cur then from = i end
		if i == targetIdx then target = id end
	end
	if not from or not target or from == targetIdx then return end
	local dir = targetIdx > from and 1 or -1
	local sf = (w:screen() or hs.screen.primaryScreen()):fullFrame()
	local mt = hs.eventtap.event.types
	tilingPaused = true
	local function hop(remaining)
		if remaining == 0 then
			tilingPaused = false
			hs.timer.doAfter(0.5, scheduleTile)
			return
		end
		local f = w:frame()
		local pt0 = hs.geometry.point(f.x + f.w / 2, f.y + 12)
		local edge = dir > 0 and (sf.x + sf.w - 8) or (sf.x + 8)
		local n = 6
		local function step(i)
			if i > n then
				hs.timer.doAfter(2.0, function() -- edge hold: native switch happens here
					local p = hs.mouse.absolutePosition()
					hs.eventtap.event.newMouseEvent(mt["leftMouseUp"], p):post()
					hs.timer.doAfter(0.6, function() hop(remaining - 1) end)
				end)
				return
			end
			local x = pt0.x + (edge - pt0.x) * (i / n)
			local p = hs.geometry.point(x, pt0.y)
			hs.mouse.setAbsolutePosition(p)
			hs.eventtap.event.newMouseEvent(mt["leftMouseDragged"], p):post()
			hs.timer.doAfter(0.15, function() step(i + 1) end)
		end
		hs.mouse.setAbsolutePosition(pt0)
		hs.eventtap.event.newMouseEvent(mt["leftMouseDown"], pt0):post()
		hs.timer.doAfter(0.25, function() step(1) end)
	end
	hop(math.abs(targetIdx - from))
end

for i = 1, 10 do
	local key, n = tostring(i % 10), i
	hs.hotkey.bind(mod, key, function()
		local sps = screenUserSpaces()
		if sps[n] then
			hs.spaces.gotoSpace(sps[n])
			hs.timer.doAfter(1.2, scheduleTile) -- Mission Control click lands late
		end
	end)
	hs.hotkey.bind({ "cmd", "shift" }, key, function()
		local c = hs.window.focusedWindow()
		if c then sendToSpace(n) end
	end)
end
