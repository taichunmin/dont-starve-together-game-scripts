local Grid = require "widgets/grid"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local TEMPLATES = require "widgets/redux/templates"

local function BuildModLink(region_size, button_height)
    -- Use noop function to make ListItemBackground build something that's
    -- clickable.
    local modlink = TEMPLATES.ListItemBackground(region_size, button_height, function() end)
    modlink.move_on_click = true
    modlink:SetText(STRINGS.UI.MODSSCREEN.LOADING.."...")
    modlink.text:SetRegionSize(region_size, 70)
    modlink:SetTextSize(28)
    modlink:SetFont(CHATFONT)
    modlink:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
    modlink:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
    return modlink
end

local function BuildSectionTitle(text, region_size)
    local title_root = Widget("title_root")
    local title = title_root:AddChild(Text(HEADERFONT, 26))
    title:SetRegionSize(region_size, 70)
    title:SetString(text)
    title:SetColour(UICOLOURS.GOLD_SELECTED)

    local titleunderline = title_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
    titleunderline:SetScale(0.4, 0.5)
    titleunderline:SetPosition(0, -20)

    return title_root
end

local TopModsPanel = Class(Widget, function(self)
    Widget._ctor(self, "TopModsPanel")

    -- These two panels are positioned carefully so they fit in
    -- ServerCreationScreen when shifted to the right.

    self.root = self:AddChild(Widget("root"))
    self.root:SetPosition(0,-60)

    self.topmods_panel = self.root:AddChild(Widget("topmods"))
    self.topmods_panel:SetPosition(0,0)

	if PLATFORM ~= "WIN32_RAIL" then
		self.morebutton = self.root:AddChild(TEMPLATES.StandardButton(
				function() ModManager:ShowMoreMods() end,
				STRINGS.UI.MODSSCREEN.MOREMODS
			))
		self.morebutton:SetPosition(0,-170)
		self.morebutton:SetScale(.56)
	end

    local region_size = 550
    local button_height = 45

    self.toptitle = self.topmods_panel:AddChild(BuildSectionTitle(STRINGS.UI.MODSSCREEN.TOPMODS, region_size))
    self.toptitle:SetPosition(0,310)

    self.modlinks = {}

    self.modlink_grid = self.topmods_panel:AddChild(Grid())
    self.modlink_grid:SetPosition(0, 245)
    for i = 1, 9 do
        table.insert(self.modlinks, BuildModLink(region_size, button_height))
    end
    self.modlink_grid:FillGrid(1, 100, button_height, self.modlinks)

   	TheSim:QueryTopMods( function(result, isSuccessful, resultCode) self:OnStatsQueried(result, isSuccessful, resultCode) end)

    self:DoFocusHookups()
    self.topmods_panel.focus_forward = self.modlink_grid
    self.focus_forward = self.modlink_grid
end)

function TopModsPanel:GenerateRandomPicks(num, numrange)
    local picks = {}
    while #picks < num do
        local index = math.random(1, numrange)
        if not table.contains(picks, index) then
            table.insert(picks, index)
        end
    end
    return picks
end

function TopModsPanel:OnStatsQueried( success, json_body )
    if not (self.inst:IsValid()) then
        return
    end

    if not success or string.len(json_body) <= 1 then return end
    local status, jsonresult = pcall( function() return json.decode(json_body) end )

    if not jsonresult or type(jsonresult) ~= "table" or not status or jsonresult["modnames"] == nil then return end

    if next(jsonresult["modnames"]) == nil then return end

    local randomPicks = self:GenerateRandomPicks(#self.modlinks, #jsonresult["modnames"])
    for i = 1, #self.modlinks do
        local title = jsonresult["modnames"][randomPicks[i]]
        if title then
            local url = jsonresult["modlinks"][title]
            title = string.gsub(title, "(ws%-)", "")
            local maxchars = 55
            if string.len(title) > maxchars then
                title = string.sub(title, 0, maxchars).."..."
            end
            self.modlinks[i]:SetText(title)
            if url then
				self.modlinks[i]:SetOnClick(function() VisitURL(url) end)
            end
        end
    end
end

function TopModsPanel:DoFocusHookups()
	if self.morebutton ~= nil then
		self.morebutton:SetFocusChangeDir(MOVE_UP, self.modlinks[#self.modlinks])
		self.topmods_panel:SetFocusChangeDir(MOVE_DOWN, self.morebutton)
	end
end

return TopModsPanel
