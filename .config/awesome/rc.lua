-- {{{ Header
------------------------------------------------------------
-- Awesome configuration, using awesome-git on Arch Linux --
--   * Mod by William Díaz <leprosys.info>                --
--   * Original config by <anrxc.sysphere.org>            --
------------------------------------------------------------
-- }}}


-- {{{ Libraries
require("awful")
require("awful.autofocus")
require("awful.rules")
-- User libraries
require("vicious")
require("teardrop")
require("scratchpad")
-- }}}


-- {{{ Variable definitions
--
-- Custom theme
beautiful.init(awful.util.getdir("config") .. "/themes/zenburn/theme.lua")

-- Default Apps
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Modifier keys
altkey = "Mod1"      -- Alt_L
modkey = "Mod4"      -- Super_L

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
    awful.layout.suit.tile,            -- 1
    awful.layout.suit.tile.left,       -- 2
    awful.layout.suit.tile.bottom,     -- 3
    awful.layout.suit.tile.top,        -- 4
    awful.layout.suit.fair,            -- 5
    awful.layout.suit.fair.horizontal, -- 6
--  awful.layout.suit.spiral,          -- /
--  awful.layout.suit.spiral.dwindle,  -- /
    awful.layout.suit.max,             -- 7
--  awful.layout.suit.max.fullscreen,  -- /
    awful.layout.suit.magnifier,       -- 8
    awful.layout.suit.floating         -- 9
}
-- }}}


-- {{{ Tags
--
-- Define tags table
tags = {}
tags.settings = {
    { name = "www",       layout = layouts[7], mwfact = 0.550  }, 
    { name = "dev1",      layout = layouts[1]  },
    { name = "dev2",      layout = layouts[1]  },
    { name = "4",         layout = layouts[2]  },
    { name = "5",         layout = layouts[3]  },
    { name = "6",         layout = layouts[1], },
    { name = "7",         layout = layouts[1], },
    { name = "8",         layout = layouts[1], },
    { name = "music",     layout = layouts[9]  },
    --{ name = "9",         layout = layouts[9], }
}

-- Initialize tags
for s = 1, screen.count() do
    tags[s] = {}
    for i, v in ipairs(tags.settings) do
        tags[s][i] = tag({ name = v.name })
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], "layout",  v.layout)
        awful.tag.setproperty(tags[s][i], "mwfact",  v.mwfact)
        awful.tag.setproperty(tags[s][i], "hide",    v.hide)
        awful.tag.setproperty(tags[s][i], "nmaster", v.nmaster)
        awful.tag.setproperty(tags[s][i], "ncols",   v.ncols)
        awful.tag.setproperty(tags[s][i], "icon",    v.icon)
    end
    tags[s][1].selected = true
end
-- }}}


-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Reusable separators
spacer         = widget({ type = "textbox", name = "spacer" })
separator      = widget({ type = "textbox", name = "separator" })
spacer.text    = " "
separator.text = "|"
-- }}}

-- {{{ CPU usage graph and temperature
-- Widget icon
cpuicon        = widget({ type = "imagebox", name = "cpuicon" })
cpuicon.image  = image(beautiful.widget_cpu)
-- Initialize widgets
thermalwidget  = widget({ type = "textbox", name = "thermalwidget" })
cpuwidget      = awful.widget.graph({ layout = awful.widget.layout.horizontal.rightleft })
-- CPU graph properties
cpuwidget:set_width(50)
cpuwidget:set_scale(false)
cpuwidget:set_max_value(100)
cpuwidget:set_background_color(beautiful.fg_off_widget)
cpuwidget:set_border_color(beautiful.border_widget)
cpuwidget:set_color(beautiful.fg_end_widget)
cpuwidget:set_gradient_colors({
    beautiful.fg_end_widget,
    beautiful.fg_center_widget,
    beautiful.fg_widget })
-- Register widgets
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")
--vicious.register(thermalwidget, vicious.widgets.thermal, "$1°C", 19, "TZS0")
-- }}}

-- {{{ Battery percentage and state indicator
-- Widget icon
baticon       = widget({ type = "imagebox", name = "baticon" })
baticon.image = image(beautiful.widget_bat)
-- Initialize widget
batwidget     = widget({ type = "textbox", name = "batwidget" })
-- Register widget
vicious.register(batwidget, vicious.widgets.bat, "//%", 61, "BAT0")
-- }}}

-- {{{ Memory usage bar
-- Widget icon
memicon       = widget({ type = "imagebox", name = "memicon" })
memicon.image = image(beautiful.widget_mem)
-- Initialize widget
memwidget     = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
-- MEM progressbar properties
memwidget:set_width(8)
memwidget:set_height(10)
memwidget:set_vertical(true)
memwidget:set_background_color(beautiful.fg_off_widget)
memwidget:set_border_color(nil)
memwidget:set_color(beautiful.fg_widget)
memwidget:set_gradient_colors({
    beautiful.fg_widget,
    beautiful.fg_center_widget,
    beautiful.fg_end_widget })
awful.widget.layout.margins[memwidget.widget] = { top = 2, bottom = 2 }
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, "$1", 60)
-- }}}

-- {{{ File system usage bars
-- Widget icon
fsicon       = widget({ type = "imagebox", name = "fsicon" })
fsicon.image = image(beautiful.widget_fs)
-- Initialize widgets
fswidget = {
    ["root"]    = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft }),
    ["home"]    = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft }),
    ["boot"] = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft }),
    -- Configure widgets
    margins = {
        top = 1, bottom = 1
    },
    settings = {
        width = 5, height=12, vertical = true 
    },
    colors = {
        border    = beautiful.border_widget,
        bg        = beautiful.fg_off_widget,
        fg        = beautiful.fg_widget,
        fg_center = beautiful.fg_center_widget,
        fg_end    = beautiful.fg_end_widget
}}
-- FS progressbar properties
for _, w in pairs(fswidget) do
    if w.widget ~= nil then
        w:set_width(fswidget.settings.width)
        w:set_height(fswidget.settings.height)
        w:set_vertical(fswidget.settings.vertical)
        w:set_background_color(fswidget.colors.bg)
        w:set_border_color(fswidget.colors.border)
        w:set_color(fswidget.colors.fg)
        w:set_gradient_colors({
            fswidget.colors.fg,
            fswidget.colors.fg_center,
            fswidget.colors.fg_end
        })
        awful.widget.layout.margins[w.widget] = fswidget.margins
        -- Register buttons
        w.widget:buttons(awful.util.table.join(
            awful.button({ }, 1, function () awful.util.spawn("rox", false) end)
        ))
    end
end
-- Register widgets
--vicious.register(fswidget["root"],    vicious.widgets.fs, "${/ usep}",            240)
--vicious.register(fswidget["home"],    vicious.widgets.fs, "${/home usep}",        240)
--vicious.register(fswidget["boot"],    vicious.widgets.fs, "${/boot usep}",        240)
-- }}}

-- {{{ Network usage statistics
-- Widget icons
neticon         = widget({ type = "imagebox", name = "neticon" })
neticonup       = widget({ type = "imagebox", name = "neticonup" })
neticon.image   = image(beautiful.widget_net)
neticonup.image = image(beautiful.widget_netup)
-- Initialize widgets
netwidget       = widget({ type = "textbox", name = "netwidget" })
netfiwidget     = widget({ type = "textbox", name = "netfiwidget" })
-- Register ethernet widget
vicious.register(netwidget, vicious.widgets.net,'<span color="'
		 .. beautiful.fg_netdn_widget ..'">100</span> <span color="'
		    .. beautiful.fg_netup_widget ..'">100</span>', 3)
-- Register wireless widget
vicious.register(netfiwidget, vicious.widgets.net,'<span color="'
		 .. beautiful.fg_netdn_widget ..'">100</span> <span color="'
		    .. beautiful.fg_netup_widget ..'">100</span>', 3)
-- }}}

-- {{{ Volume level, progressbar and changer
-- Widget icon
volicon       = widget({ type = "imagebox", name = "volicon" })
volicon.image = image(beautiful.widget_vol)
-- Initialize widgets
volwidget     = widget({ type = "textbox", name = "volwidget" })
volbarwidget  = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
-- VOL progressbar properties
volbarwidget:set_width(8)
volbarwidget:set_height(10)
volbarwidget:set_vertical(true)
volbarwidget:set_background_color(beautiful.fg_off_widget)
volbarwidget:set_border_color(nil)
volbarwidget:set_color(beautiful.fg_widget)
volbarwidget:set_gradient_colors({
    beautiful.fg_widget,
    beautiful.fg_center_widget,
    beautiful.fg_end_widget })
awful.widget.layout.margins[volbarwidget.widget] = { top = 2, bottom = 2 }
-- Register widgets
vicious.register(volwidget, vicious.widgets.volume, "$1%", 2, "Master")
vicious.register(volbarwidget, vicious.widgets.volume, "$1", 2, "Master")
-- Register buttons
volbarwidget.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("volwheel", false)                     end),
    awful.button({ }, 2, function () awful.util.spawn("amixer -q sset Master toggle", false) end),
    awful.button({ }, 4, function () awful.util.spawn("amixer -q sset Master 2dB+", false)   end),
    awful.button({ }, 5, function () awful.util.spawn("amixer -q sset Master 2dB-", false)   end)
))  volwidget:buttons( volbarwidget.widget:buttons() )
-- }}}

-- {{{ Date, time and a calendar
-- Widget icon
dateicon       = widget({ type = "imagebox", name = "dateicon" })
dateicon.image = image(beautiful.widget_date)
-- Initialize widget
datewidget     = widget({ type = "textbox", name = "datewidget" })
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%b %e, %I:%M %p", 60)
-- Register buttons
datewidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("pylendar.py", false) end)))
-- }}}

-- {{{ System tray
systray = widget({ type = "systray" })
-- }}}
-- }}}

-- {{{ Wibox initialisation
wibox = {}
promptbox = {}
layoutbox = {}
taglist = {}
taglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)

    -- Create the wibox
    wibox[s] = awful.wibox({
        position = "top", screen = s, height = 14,
        fg = beautiful.fg_normal, bg = beautiful.bg_normal
    })
    -- Add widgets to the wibox - order matters
    wibox[s].widgets = {{
        taglist[s],
        layoutbox[s],
        promptbox[s],
        layout = awful.widget.layout.horizontal.leftright
    },
        s == screen.count() and systray or nil,
        separator,
        datewidget, dateicon,
        separator,
        volwidget, spacer, volbarwidget.widget, volicon,
        separator,
        neticonup, netfiwidget, neticon,
        separator,
        neticonup, netwidget, neticon,
        separator,
        fswidget["boot"].widget,
        fswidget["home"].widget,
        fswidget["root"].widget, fsicon,
        separator,
        spacer, memwidget.widget, spacer, memicon,
        separator,
        spacer, batwidget, baticon,
        separator,
        cpuwidget.widget, spacer, thermalwidget, cpuicon,
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Client mouse bindings
clientbuttons = awful.util.table.join(
    awful.button({        }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}


-- {{{ Key bindings
--
-- {{{ Global keys
globalkeys = awful.util.table.join(
    -- {{{ Applications
    awful.key({ modkey }, "w",      function () awful.util.spawn("swiftweasel", false)           end),
    awful.key({ modkey }, "Return", function () awful.util.spawn(terminal)                       end),
    awful.key({ modkey }, "F1",     function () teardrop.toggle("urxvtc", "bottom")              end),
    awful.key({ modkey }, "F2",     function () teardrop.toggle("gmrun", nil, nil, nil, 0, 0.08) end),
    
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    -- }}}

    -- {{{ Multimedia keys
    -- Volume
    awful.key({}, "XF86AudioMute",        function () awful.util.spawn("amixer -q set Master toggle", false)    end),
    awful.key({}, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -q set Master 2- unmute", false) end),
    awful.key({}, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -q set Master 2+ unmute", false) end),
    -- Player
    awful.key({}, "XF86AudioPrev",   function () awful.util.spawn("mpc prev", false)   end),
    awful.key({}, "XF86AudioPlay",   function () awful.util.spawn("mpc toggle", false) end),
    awful.key({}, "XF86AudioNext",   function () awful.util.spawn("mpc next", false)   end),
    awful.key({}, "XF86AudioStop",   function () awful.util.spawn("mpc stop", false)   end),
    -- Brightness
    awful.key({}, "XF86MonBrightnessDown", function () awful.util.spawn("plight.py -s -a -q", false) end),
    awful.key({}, "XF86MonBrightnessUp",   function () awful.util.spawn("plight.py -s -a -q", false) end),
    -- Others
    awful.key({}, "XF86Display",     function () awful.util.spawn("pypres.py", false)   end),
    awful.key({}, "XF86ScreenSaver", function () awful.util.spawn("xlock", false)       end),
    awful.key({}, "XF86HomePage",    function () awful.util.spawn("swiftweasel", false) end),
    -- }}}

   -- {{{ Prompt menus
   awful.key({ altkey }, "F2",
              function ()
                  awful.prompt.run({ prompt = "Run: " },
                  promptbox[mouse.screen].widget,
              function (...) promptbox[mouse.screen].text = awful.util.spawn(unpack(arg), false) end,
                  awful.completion.shell, awful.util.getdir("cache") .. "/history")
             end),
   awful.key({ altkey }, "F3",
              function ()
                  awful.prompt.run({ prompt = "Manual: " },
                  promptbox[mouse.screen].widget,
              function (page) awful.util.spawn("urxvt -e man " .. page, false) end)
              end),
   awful.key({ altkey }, "F4",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  promptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history")
              end),
    -- }}}

    -- {{{ Awesome controls
    awful.key({ modkey, "Shift" }, "m", function () awful.mouse.finder():find() end),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),
    awful.key({ modkey, "Shift" }, "r", function ()
        promptbox[mouse.screen].text = awful.util.escape(awful.util.restart())
    end),
    -- }}}

    -- {{{ Tag browsing
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    -- }}}

    -- {{{ Layout manipulation
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    -- }}}

    -- {{{ Focus controls
    awful.key({ modkey,           }, "p", function () awful.screen.focus_relative(1)  end),
    awful.key({ modkey,           }, "s", function () scratchpad.toggle()             end),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end)
    -- }}}
)
-- }}}

-- {{{ Client manipulation
clientkeys = awful.util.table.join(
    awful.key({ modkey }, "b", function ()
        if wibox[mouse.screen].screen == nil then
             wibox[mouse.screen].screen = mouse.screen
        else wibox[mouse.screen].screen = nil end
    end),
    awful.key({ modkey,           }, "F11",    function (c) c.fullscreen = not c.fullscreen               end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                                     ),
--  awful.key({ modkey,           }, "F9",     function (c) c.minimized = not c.minimized                 end),
--  awful.key({ modkey,           }, "F10",    function (c) c.maximized = not c.maximized                 end),
    awful.key({ modkey,           }, "d",      function (c) scratchpad.set(c, 0.60, 0.60, true)           end),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster())              end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) awful.util.spawn("kill -CONT "..c.pid, false) end),
    awful.key({ modkey, "Shift"   }, "s",      function (c) awful.util.spawn("kill -STOP "..c.pid, false) end),
    awful.key({ modkey, "Shift"   }, "0",      function (c) c.sticky = not c.sticky                       end),
    awful.key({ modkey, "Shift"   }, "o",      function (c) c.ontop = not c.ontop                         end),
    awful.key({ modkey, "Control" }, "r",      function (c) c:redraw()                                    end),
    awful.key({ modkey,           }, "F10",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    awful.key({ modkey, "Shift" }, "t",
        function (c)
            if c.titlebar then awful.titlebar.remove(c)
            else awful.titlebar.add(c, { modkey = modkey }) end
        end),
    awful.key({ modkey, "Control" }, "space", 
    function (c)
        awful.client.floating.toggle(c)
            if awful.client.floating.get(c) then
                c.above = true;  awful.titlebar.add(c)
            else c.above = false; awful.titlebar.remove(c) end
        end)
)
-- }}}

-- {{{ Keyboard digits
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end
-- }}}

-- {{{ Tag controls
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, i,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, i,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end
-- }}}

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = {
          border_width = beautiful.border_width,
          border_color = beautiful.border_normal,
          focus = true,
          keys = clientkeys,
          buttons = clientbuttons 
    }},
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "Smplayer" },
      properties = { floating = true } },
    { rule = { class = "Sonata" },
      properties = { floating = true } },
    { rule = { class = "Amsn" },
      properties = { floating = true } },
    { rule = { class = "Pinentry-gtk-2" },
      properties = { floating = true } },
    { rule = { class = "Gimp" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "Inkscape" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "Swiftweasel" },
      properties = { tag = tags[1][2] } },
    { rule = { class = "Kmag" },
      properties = { floating = true } },
      { rule = { class = "volwheel" },
      properties = { floating = true } },
    { rule = { class = "Xmessage", instance = "xmessage" } },
}
-- }}}


-- {{{ Signals
--
-- {{{ Signal function to execute when a new client appears
client.add_signal("manage", function (c, startup)
    -- Add a titlebar to each floating client
    if awful.client.floating.get(c) or
        awful.layout.get(c.screen) == awful.layout.suit.floating
    then
        if not c.titlebar and c.class ~= "Xmessage" then
            awful.titlebar.add(c, { modkey = modkey })
        end
        -- Floating clients are always on top
        c.above = true
    end

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    -- Client placement
    awful.client.setslave(c)
    awful.placement.no_offscreen(c)

    -- Honor size hints
    c.size_hints_honor = false
end)
-- }}}

-- {{{ Focus signal functions
client.add_signal("focus",   function(c) c.border_color = beautiful.border_focus  end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- }}}

-- Agregado por n0dix. 09/10/09
-- Autostart nm-applet
--os.execute("nm-applet &")
