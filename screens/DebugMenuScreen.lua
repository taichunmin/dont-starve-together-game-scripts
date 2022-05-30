require "util"

local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local menus = require "debugmenu"

local time_warp =1
local DebugMenuScreen = Class(Screen, function(self)
	Screen._ctor(self, "DebugMenuScreen")

   	self.blackoverlay = self:AddChild(Image("images/global.xml", "square.tex"))
    self.blackoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.blackoverlay:SetClickable(false)
	self.blackoverlay:SetTint(0,0,0,.75)

--	self.text = self:AddChild(Text(BODYTEXTFONT, 16, "blah"))
	self.text = self:AddChild(Text(BODYTEXTFONT, TheSim.GetIsSplitScreen ~= nil and TheSim:GetIsSplitScreen() and 32 or 16, "blah"))
	self.text:SetVAlign(ANCHOR_TOP)
	self.text:SetHAlign(ANCHOR_LEFT)
    self.text:SetVAnchor(ANCHOR_MIDDLE)
    self.text:SetHAnchor(ANCHOR_MIDDLE)
	self.text:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self.text:SetRegionSize(900, 700)
	self.text:SetPosition(0,0,0)

	TheFrontEnd:HideConsoleLog()
end)


local god = false
local map_reveal = false
local free_craft = false
local show_log = false

function Remote_Spawn(prefab, x, y, z)
		local fnstr = string.format('c_spawn("%s")',prefab)
		print("Command:",fnstr)
		print("pos",x,z)
		TheNet:SendRemoteExecute(fnstr, x, z)
end

function ConsoleRemote(cmd, data)
		local fnstr = string.format(cmd, unpack(data or {}))
		c_remote(fnstr)
end

local function c_gonext(val)
	ConsoleRemote('c_gonext("%s")', {val})
end

function DebugMenuScreen:OnBecomeActive()
	DebugMenuScreen._base.OnBecomeActive(self)
	SetPause(true,"console")

	self.menu = menus.TextMenu(InGamePlay() and "IN GAME DEBUG MENU" or "FRONT END DEBUG MENU")
	local main_options = {}


	local map = TheWorld and TheWorld.minimap or nil


	local craft_menus = {}
	for k,v in pairs(AllRecipes) do
        if IsRecipeValid(v.name) and v.tab then -- no tab for pighead/mermhead (things that aren't buidlable but need to behave like recipes)
    		craft_menus[v.tab] = craft_menus[v.tab] or {}
    		table.insert(craft_menus[v.tab], menus.DoAction(v.name, function() for kk,vv in pairs(v.ingredients) do ConsoleRemote('c_give("%s", %d)',{vv.type, vv.amount}) end end))
        end
	end

	local spawncraft = {}
	for k,v in pairs(craft_menus) do
		table.insert(spawncraft, menus.Submenu(k.str, v))
	end

	local bars = {
		menus.NumericToggle("Health", 1, 100, function() return math.floor(ThePlayer.replica.health:GetPercent()*100) end, function(val) ConsoleRemote('c_sethealth("%f")',{val/100}) end,5),
		menus.NumericToggle("Sanity", 1, 100, function() return math.floor(ThePlayer.replica.sanity:GetPercent()*100) end, function(val) ConsoleRemote('c_setsanity("%f")',{val/100}) end,5),
		menus.NumericToggle("Hunger", 1, 100, function() return math.floor(ThePlayer.replica.hunger:GetPercent()*100) end, function(val) ConsoleRemote('c_sethunger("%f")',{val/100}) end,5),
	}
	local timecontrol = {
		menus.DoAction("Advance Phase", function() ConsoleRemote('TheWorld:PushEvent("ms_nextphase")') end),
		menus.DoAction("Advance Day", function() ConsoleRemote('TheWorld:PushEvent("ms_nextcycle")') end),
		menus.DoAction("Advance Season", function() for i=1,TheWorld.state.remainingdaysinseason do ConsoleRemote('TheWorld:PushEvent("ms_advanceseason")') end end),
	}
	local teleport = {
		menus.DoAction("Eyebone", function() ConsoleRemote('c_gonext("chester_eyebone")') self:Close() end),
		menus.DoAction("Cave Entrance", function() c_gonext("cave_entrance") self:Close() end),
		menus.DoAction("Cave Exit", function() c_gonext("cave_exit") self:Close() end),
		menus.DoAction("Spawn Portal", function() c_gonext("multiplayer_portal") self:Close() end),
        menus.DoAction("Antlion Nest", function() ConsoleRemote('c_give("deserthat")') ConsoleRemote('c_gonext("antlion_spawner")') self:Close() end),
        menus.DoAction("Desert Oasis", function() ConsoleRemote('c_give("deserthat")') ConsoleRemote('c_gonext("oasislake")') self:Close() end),
		menus.DoAction("Gather Players", function() ConsoleRemote("c_gatherplayers()") self:Close() end),
	}

	local allprefabs = {}
	for k, v in pairs(Prefabs) do
		local can_spawn = not string.find(v.name, "blueprint") and not string.find(v.name, "placer")
		if v.name == "forest" or v.name == "cave" then can_spawn = false end
		if can_spawn then
			table.insert(allprefabs, v.name)
		end
	end
	table.sort(allprefabs)

	local PER_PAGE = 30
	local spawn_lists = {}
	local current = {}
	for k = 1, #allprefabs do
		table.insert(current, allprefabs[k])

		if k % PER_PAGE == 0 then
			table.insert(spawn_lists, current)
			current = {}
		end
	end
	if #current > 0 then
		table.insert(spawn_lists, current)
	end
	current = nil
	local spawn = {}

	for k,v in pairs(spawn_lists) do
		local inner_list = {}
		for kk, vv in pairs(v) do
			table.insert(inner_list, menus.DoAction(vv, function() ConsoleRemote('c_spawn("%s")',{vv}) end))
		end
		table.insert(spawn, menus.Submenu(v[1] .. " thru " .. v[#v], inner_list))
	end


    local weathercontrol = {
        menus.CheckBox("Toggle Precipitation", function() return TheWorld.state.precipitation ~= "none" or TheWorld.state.moisture >= TheWorld.state.moistureceil end,
            function(val)
                ConsoleRemote('TheWorld:PushEvent("ms_forceprecipitation", true)')
            end),
            menus.CheckBox("Toggle Winter", function() return TheWorld.state.iswinter end,
            function(val)
                if val then
                    ConsoleRemote('TheWorld:PushEvent("ms_setseason", "winter")')
                else
                    ConsoleRemote('TheWorld:PushEvent("ms_setseason", "summer")')
                end
            end)
    }

    local languages =
    {
		menus.DoAction("French", function() LOC.SwapLanguage(LANGUAGE.FRENCH) self:Close() end),
        menus.DoAction("Spanish", function() LOC.SwapLanguage(LANGUAGE.SPANISH) self:Close() end),
        menus.DoAction("Mexican", function() LOC.SwapLanguage(LANGUAGE.SPANISH_LA) self:Close() end),
        menus.DoAction("German", function() LOC.SwapLanguage(LANGUAGE.GERMAN) self:Close() end),
		menus.DoAction("Italian", function() LOC.SwapLanguage(LANGUAGE.ITALIAN) self:Close() end),
        menus.DoAction("Brazilian", function() LOC.SwapLanguage(LANGUAGE.PORTUGUESE_BR) self:Close() end),
        menus.DoAction("Polish", function() LOC.SwapLanguage(LANGUAGE.POLISH) self:Close() end),
        menus.DoAction("Korean", function() LOC.SwapLanguage(LANGUAGE.KOREAN) self:Close() end),
        menus.DoAction("Japanese", function() LOC.SwapLanguage(LANGUAGE.JAPANESE) self:Close() end),
        menus.DoAction("Chinese (T)", function() LOC.SwapLanguage(LANGUAGE.CHINESE_T) self:Close() end),
        menus.DoAction("Chinese (S)", function() LOC.SwapLanguage(LANGUAGE.CHINESE_S) self:Close() end),
    }

	if InGamePlay() then
		table.insert(main_options, menus.CheckBox("Toggle God Mode", function() return god end, function(val) god = val ConsoleRemote("c_godmode()") end))
		table.insert(main_options, menus.CheckBox("Toggle Free Crafting", function() return free_craft end, function(val) free_craft = val ConsoleRemote("c_freecrafting()") end))
		table.insert(main_options, menus.CheckBox("Toggle Log", function() return show_log end, function(val) show_log = val if show_log then TheFrontEnd:ShowConsoleLog() else TheFrontEnd:HideConsoleLog() end end ))
		table.insert(main_options, menus.CheckBox("Toggle Reveal Map", function() return map_reveal end,
                                            function(val)
                                                map_reveal = val
                                                map.MiniMap:EnableFogOfWar(not map_reveal)
                                            end))
		table.insert(main_options, menus.Submenu("Teleport", teleport))
		table.insert(main_options, menus.Submenu("Time Control", timecontrol))
		table.insert(main_options, menus.Submenu("Weather Control", weathercontrol))
		table.insert(main_options, menus.Submenu("Player Bars", bars))
		table.insert(main_options, menus.Submenu("Spawn", spawn))
		table.insert(main_options, menus.Submenu("Give Ingredients for", spawncraft))
	else
		table.insert(main_options, menus.CheckBox("Toggle Log", function() return show_log end, function(val) show_log = val if show_log then TheFrontEnd:ShowConsoleLog() else TheFrontEnd:HideConsoleLog() end end ))
	end

	table.insert(main_options, menus.DoAction("Grab Profile", function() TheSim:Profile() self:Close() end ))
    table.insert(main_options, menus.Submenu("Language", languages))
	--table.insert(main_options, menus.DoAction("Restart", function() StartNextInstance() self:Close() end ))


	self.menu:PushOptions(main_options, "")

	self.text:SetString(tostring(self.menu))

end

function DebugMenuScreen:OnControl(control, down)
	if DebugMenuScreen._base.OnControl(self, control, down) then return true end

	if not down and control == CONTROL_OPEN_DEBUG_MENU then
		self:Close()

		return true
	end

	if not down then
		if control == CONTROL_CANCEL then
			if not self.menu:Cancel() then
				self:Close()
			end
		elseif control == CONTROL_ACCEPT then
			self.menu:Accept()
		else
			return false
		end
	else
		if control == CONTROL_INVENTORY_UP or control == CONTROL_FOCUS_UP then
			self.menu:Up()
		elseif control == CONTROL_INVENTORY_DOWN or control == CONTROL_FOCUS_DOWN then
			self.menu:Down()
		elseif control == CONTROL_INVENTORY_LEFT or control == CONTROL_FOCUS_LEFT then
			self.menu:Left()
		elseif control == CONTROL_INVENTORY_RIGHT or control == CONTROL_FOCUS_RIGHT then
			self.menu:Right()
		else
			return false
		end
	end

	self.text:SetString(tostring(self.menu))
	return true
end

function DebugMenuScreen:Close()
	SetPause(false)
	TheSim:SetTimeScale(time_warp)
	TheFrontEnd:PopScreen()
end

return DebugMenuScreen
