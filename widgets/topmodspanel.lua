local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local TextButton = require "widgets/textbutton"
local ScrollableList = require "widgets/scrollablelist"

local TEMPLATES = require "widgets/templates"

local TopModsPanel = Class(Widget, function(self, servercreationscreen)
    Widget._ctor(self, "ModsTab")

    self.servercreationscreen = servercreationscreen

    self.topmods_panel = self:AddChild(Widget("topmods"))
    self.topmods_panel:SetScale(.86,.9)

    self.topmodsbg = self.topmods_panel:AddChild( Image( "images/fepanels.xml", "panel_topmods.tex" ) )
    self.topmodsbg:SetScale(.8,.8,1)
    self.topmodsbg:SetPosition(40, 10)

    self.topmodsgreybg = self.topmods_panel:AddChild( Image( "images/frontend.xml", "submenu_greybox.tex") )
    self.topmodsgreybg:SetScale(.6, .8, 1)
    self.topmodsgreybg:SetPosition(40, 0)
	self.topmodsgreybg:SetTint(0.7,0.7,0.7,1)

    self.morebutton = self.topmods_panel:AddChild(TEMPLATES.Button(STRINGS.UI.MODSSCREEN.MOREMODS, function() self:MoreWorkshopMods() end))
    self.morebutton:SetPosition(Vector3(45,-230,0))
    self.morebutton:SetScale(.56)

    local region_size = 160

    self.title = self.topmods_panel:AddChild(Text(TITLEFONT, 36))
    self.title:SetPosition(Vector3(40,170,0))
    self.title:SetRegionSize(region_size, 70)
    self.title:SetString(STRINGS.UI.MODSSCREEN.TOPMODS)

    self.modlinks = {}

    local yoffset = 120
    for i = 1, 5 do
        local modlink = self.topmods_panel:AddChild(TextButton("images/ui.xml", "blank.tex","blank.tex","blank.tex","blank.tex"))
        modlink:SetPosition(Vector3(45,yoffset,0))
        modlink:SetText(STRINGS.UI.MODSSCREEN.LOADING.."...")
        modlink.text:SetRegionSize(region_size, 70)
        modlink:SetTextSize(28)
	    modlink:SetFont(UIFONT)
        modlink:SetTextColour(0.9,0.8,0.6,1)
        modlink:SetTextFocusColour(1,1,1,1)
        table.insert(self.modlinks, modlink)
        yoffset = yoffset - 45
    end

    self.featuredtitle = self.topmods_panel:AddChild(Text(TITLEFONT, 36))
    self.featuredtitle:SetPosition(Vector3(45,-120,0))
    self.featuredtitle:SetString(STRINGS.UI.MODSSCREEN.FEATUREDMOD)
    self.featuredtitle:SetRegionSize( region_size, 70 )

    self.featuredtitleunderline = self.topmods_panel:AddChild( Image( "images/ui.xml", "line_horizontal_white.tex") )
    self.featuredtitleunderline:SetScale(.8, 1, 1)
    self.featuredtitleunderline:SetPosition(40, 150)

    self.featuredbutton = self.topmods_panel:AddChild(TextButton("images/ui.xml", "blank.tex","blank.tex","blank.tex","blank.tex"))
    self.featuredbutton:SetPosition(Vector3(40,-170,0))
    self.featuredbutton:SetText(STRINGS.UI.MODSSCREEN.LOADING.."...")
    self.featuredbutton.text:SetRegionSize(region_size, 70)
    self.featuredbutton:SetFont(UIFONT)
	self.featuredbutton:SetTextSize(28)
    self.featuredbutton:SetTextColour(0.9,0.8,0.6,1)
    self.featuredbutton:SetTextFocusColour(1,1,1,1)

    self.featuredbuttonunderline = self.topmods_panel:AddChild( Image( "images/ui.xml", "line_horizontal_white.tex") )
    self.featuredbuttonunderline:SetScale(.8, 1, 1)
    self.featuredbuttonunderline:SetPosition(40, -140)

    local linkpref = (PLATFORM == "WIN32_STEAM" and "external") or "klei"
    TheSim:QueryStats( '{ "req":"modrank", "field":"Session.Loads.Mods.list", "fieldop":"unwind", "linkpref":"'..linkpref..'", "limit": 20}',
        function(result, isSuccessful, resultCode) self:OnStatsQueried(result, isSuccessful, resultCode) end)

    self:DoFocusHookups()
    self.default_focus = self.modlinks[1]
    self.topmods_panel.focus_forward = self.modlinks[1]
end)

DROP_SPEED = -400
DROP_ACCEL = 750
UP_ACCEL = 2000
BOUNCE_ABSORB = 0.25
SETTLE_SPEED = 25
function TopModsPanel:OnUpdate(dt)
    if self.started then
        if not self.settled then
            self.current_speed = self.current_speed - DROP_ACCEL * dt
            self.current_x_pos = self.current_x_pos + self.current_speed * dt
            if self.current_x_pos < self.target_x_pos then
                self.current_speed = -self.current_speed * BOUNCE_ABSORB
                if self.current_speed < SETTLE_SPEED then
                    self.settled = true
                end
                self.current_x_pos = self.target_x_pos
            end
            self.topmods_panel:SetPosition(Vector3(self.current_x_pos, 0, 0))
        end
    elseif self.current_x_pos > self.start_x_pos then
        self.current_speed = self.current_speed + UP_ACCEL * dt
        self.current_x_pos = self.current_x_pos - self.current_speed * dt
        self.topmods_panel:SetPosition(Vector3(self.current_x_pos, 0, 0))
    else
        self:StopUpdating()
        self:Hide()
    end
end

function TopModsPanel:ShowPanel()
    self.started = true
    self.settled = false
    self:StartUpdating()
    self:Show()

    self.current_speed = DROP_SPEED
    local w,h  = self.topmodsbg:GetSize()
    local pos = self.topmodsbg:GetPosition()
    self.start_x_pos = pos.x
    self.current_x_pos = self.start_x_pos
    self.target_x_pos = pos.x+(w/2) - 3
    self.topmods_panel:SetPosition(Vector3(self.current_x_pos, 0, 0))
end

function TopModsPanel:HidePanel()
    self.started = false
    self.current_speed = 0
end

function TopModsPanel:GenerateRandomPicks(num, numrange)
    local picks = {}

    while #picks < num do
        local num = math.random(1, numrange)
        if not table.contains(picks, num) then
            table.insert(picks, num)
        end
    end
    return picks
end

function TopModsPanel:OnStatsQueried( result, isSuccessful, resultCode )
    if not (self.inst:IsValid()) then
        return
    end

    if not result or not isSuccessful or string.len(result) <= 1 then return end

    local status, jsonresult = pcall( function() return json.decode(result) end )

    if not jsonresult or type(jsonresult) ~= "table" or  not status or jsonresult["modnames"] == nil then return end

    local randomPicks = self:GenerateRandomPicks(#self.modlinks, 20)

    for i = 1, #self.modlinks do
        local title = jsonresult["modnames"][randomPicks[i]]
        if title then
            local url = jsonresult["modlinks"][title]
            title = string.gsub(title, "(ws%-)", "")
            if string.len(title) > 25 then
                title = string.sub(title, 0, 25).."..."
            end
            self.modlinks[i]:SetText(title)
            if url then
                self.modlinks[i]:SetOnClick(function() VisitURL(url) end)
            end
        end
    end

    local title, url = next(jsonresult["modfeature"])
    if title and url then
        title = string.gsub(title, "(ws%-)", "")
        self.featuredbutton:SetText(title)
        self.featuredbutton:SetOnClick(function() VisitURL(url) end)
    end
end

function TopModsPanel:DoFocusHookups()
    self.featuredbutton:SetFocusChangeDir(MOVE_UP, self.modlinks[5])
    self.featuredbutton:SetFocusChangeDir(MOVE_LEFT, self.modlinkbutton)
    self.featuredbutton:SetFocusChangeDir(MOVE_DOWN, self.morebutton)

    self.morebutton:SetFocusChangeDir(MOVE_UP, self.featuredbutton)
    self.morebutton:SetFocusChangeDir(MOVE_LEFT, self.modlinkbutton)
    self.morebutton:SetFocusChangeDir(MOVE_DOWN, self.servercreationscreen.create_button)

    if self.modlinks then
        for i = 1, 5 do
            if self.modlinks[i+1] ~= nil then
                self.modlinks[i]:SetFocusChangeDir(MOVE_DOWN, self.modlinks[i+1])
            else
                self.modlinks[i]:SetFocusChangeDir(MOVE_DOWN, self.featuredbutton)
            end

            if self.modlinks[i-1] ~= nil then
                self.modlinks[i]:SetFocusChangeDir(MOVE_UP, self.modlinks[i-1])
            end

            if self.modlinks[i] ~= nil then
                self.modlinks[i]:SetFocusChangeDir(MOVE_LEFT, self.modlinkbutton)
            end
        end
    end
end

-- Need knowledge of the mods tab for focus movement stuff
function TopModsPanel:SetModsTab(tab)
    self.mods_tab = tab

    self:DoFocusHookups()
end

function TopModsPanel:MoreWorkshopMods()
    VisitURL("http://steamcommunity.com/app/322330/workshop/")
end

return TopModsPanel
