local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"
local SkillTreeWidget = require "widgets/redux/skilltreewidget"
local PlayerAvatarPopup = require "widgets/playeravatarpopup"
local skilltreedefs = require "prefabs/skilltree_defs"

local SCREEN_OFFSET = 0.15 * RESOLUTION_X

local PlayerInfoPopup = Class(Screen, function(self, owner, player_name, data, show_net_profile, force)    
    self.owner = owner
    self.data = data or self.owner.components.playeravatardata:GetData()
    self.player_name = player_name or self.data.name
    self.show_net_profile = show_net_profile
    self.force = force
    self.currentcharacter = self:ResolveCharacter(self.data)
    Screen._ctor(self, "PlayerInfoPopup")

    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black.image:SetVRegPoint(ANCHOR_MIDDLE)
    black.image:SetHRegPoint(ANCHOR_MIDDLE)
    black.image:SetVAnchor(ANCHOR_MIDDLE)
    black.image:SetHAnchor(ANCHOR_MIDDLE)
    black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    black.image:SetTint(0,0,0,.5)    
    black:SetHelpTextMessage("")
    self.inst:DoTaskInTime(10/30,function()
        black:SetOnClick(function()  TheFrontEnd:PopScreen() end)
    end)

    self.anchor = self:AddChild(Widget("anchor"))
    self.anchor:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.anchor:SetHAnchor(ANCHOR_RIGHT)
    self.anchor:SetVAnchor(ANCHOR_MIDDLE)

	self.root = self.anchor:AddChild(Widget("root"))
	self.root:SetPosition(-420,-30)

    local prefab = self.data.inst and self.data.inst.prefab or self.data.prefab

    if self.currentcharacter == "notselected" then
        self:MakePlayerAvatarPopup()
    elseif skilltreedefs.SKILLTREE_DEFS[prefab] then
        self:MakeTopPanel()
        self:MakeTabs()
        self:MakeBG()
        self:MakeSkillTree()
    else
        self:MakeTopPanel()
        self:MakeBG()
        self:MakePlayerAvatarPopup()
    end

    TheCamera:PushScreenHOffset(self, SCREEN_OFFSET)

    SetAutopaused(true)
end)

function PlayerInfoPopup:MakeTopPanel()
    self.root.bg = self.root:AddChild(Image("images/skilltree.xml", "playerinfo_bg.tex"))
    self.root.bg:SetPosition(-5,240)
    self.root.bg:ScaleToSize(406,164)

    self.title = self.root:AddChild(Text(self.data.colour ~= nil and TALKINGFONT or BUTTONFONT, 32))
    self.title:SetPosition(0,225)

    -- TODO: DOES THIS NEED TO BE UPDATED? LOOK AT PLAYERAVATARPOPUP
    if self.data.colour ~= nil then
        self.title:SetColour(unpack(self.data.colour))
    else
        self.title:SetColour(0, 0, 0, 1)
    end
    self:UpdateDisplayName()
end

function PlayerInfoPopup:MakeBG()
    self.root.playerbg = self.root:AddChild(Image("images/skilltree2.xml", "background.tex"))
    self.root.playerbg:SetPosition(0,-20)
    self.root.playerbg:ScaleToSize(600, 460)

    self.bg_scratches = self.root:AddChild(Image("images/skilltree.xml", "background_scratches.tex"))
    self.bg_scratches:SetPosition(0,-20)
    self.bg_scratches:ScaleToSize(580, 460)
end

function maketabbutton(widget,pos,text,clickfn, imagename, textoffset, flip)

    local button = widget:AddChild(ImageButton("images/skilltree.xml",
        "tab_skills_unselected.tex", -- normal
        "tab_skills_unselected.tex", -- focus
        "tab_skills_over.tex", -- disabled
        "tab_skills_unselected.tex", -- down
        "tab_skills_over.tex" -- selected 
        ))

    local size = {142,96}

    if flip then
        size[1] = size[1] * -1
    end

    button:SetPosition(pos[1],pos[2])
    button:ForceImageSize(size[1],size[2])
    button:SetText(text)
    button:SetTextSize(20)
    button:SetFont(HEADERFONT)
    button:SetDisabledFont(HEADERFONT)
    button:SetTextColour(UICOLOURS.GOLD)
    button.scale_on_focus = false

    button.clickoffset = Vector3(0,5,0)
    button:SetTextFocusColour(UICOLOURS.GOLD)
    button:SetTextSelectedColour(UICOLOURS.GOLD)
    button:SetTextDisabledColour(UICOLOURS.GOLD)    
    button.text:SetPosition(textoffset[1],textoffset[2])
    button:SetOnClick(function()
        clickfn()
    end)

    return button
end

function PlayerInfoPopup:MakeTabs()
    self.root.tabs = self.root:AddChild(Widget("tabs"))
    self.root.tabs:SetPosition(0,0)

    self.root.tabs.playerAvatarPopup = maketabbutton(self.root.tabs,{-165,220}, string.upper(STRINGS.SKILLTREE.INFOPANEL), function() self:MakePlayerAvatarPopup() end, "skins", {2,-5}, true)
    self.root.tabs.skillTreePopup = maketabbutton(self.root.tabs,{165,220}, string.upper(STRINGS.SKILLTREE.SKILLTREE), function() self:MakeSkillTree() end, "skills", {-2,-5})
end

function PlayerInfoPopup:GetDisplayName(player_name, character)
    return player_name or ""
end

function PlayerInfoPopup:UpdateDisplayName()  
    self.title:SetMultilineTruncatedString(self:GetDisplayName(self.player_name, self.currentcharacter),1, 200, 40, nil, true)
end

function PlayerInfoPopup:ResolveCharacter(data)
    local character = data.prefab or data.character or "wilson"
    return (character == "" and "notselected")
        or (not softresolvefilepath("bigportraits/"..character..".xml") and "unknownmod")
        or character
end

function PlayerInfoPopup:MakeSkillTree()
    if self.playeravatar then
        self.playeravatar:Kill()
        self.playeravatar = nil
    end

    local prefab = self.data.inst and self.data.inst.prefab or self.data.prefab
    self.skilltree = self.root:AddChild(SkillTreeWidget(prefab, self.data))
    if self.root.tabs then
        self.root.tabs.skillTreePopup:Disable()
        self.root.tabs.playerAvatarPopup:Enable()
        self.root.tabs.controller = self.MakePlayerAvatarPopup
    end
    if TheInput:ControllerAttached() then
        self.skilltree.default_focus:SetFocus()
    end
end

function PlayerInfoPopup:MakePlayerAvatarPopup()
    if self.skilltree then
        self.skilltree:Kill()
        self.skilltree = nil
    end
    self.playeravatar = self.root:AddChild(PlayerAvatarPopup(self.owner, self.player_name, self.data, self.show_net_profile, self.force))
    if self.currentcharacter == "notselected" then
        self.playeravatar:SetPosition(0,60)
    else
        self.playeravatar:SetPosition(0,-50)
    end
    self.playeravatar:SetScale(0.7)
    if self.root.tabs then
        self.root.tabs.skillTreePopup:Enable()
        self.root.tabs.playerAvatarPopup:Disable()
        self.root.tabs.controller = self.MakeSkillTree
    end
end

function PlayerInfoPopup:OnDestroy()
    TheCamera:PopScreenHOffset(self, SCREEN_OFFSET)
    SetAutopaused(false)

    POPUPS.PLAYERINFO:Close(self.owner)

	PlayerInfoPopup._base.OnDestroy(self)
end

function PlayerInfoPopup:OnBecomeInactive()
    PlayerInfoPopup._base.OnBecomeInactive(self)
end

function PlayerInfoPopup:OnBecomeActive()
    PlayerInfoPopup._base.OnBecomeActive(self)

    if TheInput:ControllerAttached() then
        if self.skilltree then
            self.skilltree.default_focus:SetFocus()
        end
    end
end

function PlayerInfoPopup:OnControl(control, down)
    if PlayerInfoPopup._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        TheFrontEnd:PopScreen()
        return true
    end

    if control == CONTROL_MENU_L2 or control == CONTROL_MENU_R2 then
        if not down and self.root.tabs then
            self.root.tabs.controller(self)
            return true
        end
    end

	return false
end

function PlayerInfoPopup:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_L2).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_R2).. " " .. STRINGS.UI.HELP.CHANGE_TAB)

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end

return PlayerInfoPopup
