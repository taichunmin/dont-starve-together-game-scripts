local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local DressupPanel = require "widgets/redux/dressuppanel"

local TEMPLATES = require "widgets/redux/templates"

require("characterutil")
require("util")
require("networking")
require("stringutil")

local LoadoutSelect = Class(Widget, function(self, profile, default_character)
    Widget._ctor(self, "LoadoutSelect")
    self.profile = profile

    self.currentcharacter = default_character

    self.loadout_root = self:AddChild(Widget("Loadout"))

    self.heroname = self.loadout_root:AddChild(Image())
    self.heroname:SetScale(.34)
    self.heroname:SetPosition(120,250)

    local portrait_root = self.loadout_root:AddChild(Widget("portrait_root"))
    portrait_root:SetPosition(-175,40)
    self.heroportrait = portrait_root:AddChild(Image())
    self.heroportrait:SetScale(.5)

    self.basequote = self.loadout_root:AddChild(Text(BUTTONFONT, 35))
    self.basequote:SetHAlign(ANCHOR_MIDDLE)
    self.basequote:SetVAlign(ANCHOR_TOP)
    self.basequote:SetPosition(60, -270)
    self.basequote:SetRegionSize(390, 70) -- fills space between back and ready. space for two lines used by mods and wilson.
    self.basequote:EnableWordWrap(true)
    self.basequote:SetString( "" )
    self.basequote:SetColour(GOLD)

    self.basetitle = portrait_root:AddChild(Text(BUTTONFONT, 40))
    self.basetitle:SetHAlign(ANCHOR_MIDDLE)
    self.basetitle:SetVAlign(ANCHOR_TOP)
    self.basetitle:SetPosition(0,-220)
    self.basetitle:SetRegionSize( 300, 100 )
    self.basetitle:EnableWordWrap( false )
    self.basetitle:SetString( "" )
    self.basetitle:SetColour(UICOLOURS.EGGSHELL)

    self.dressup = self.loadout_root:AddChild(DressupPanel(self, self.profile, nil, function() self:SetPortraitImage() end, nil, nil, true))
    self.dressup:SetPosition(420,80)
    self.dressup:GetClothingOptions()
    self.dressup:SeparateAvatar()

    self.focus_forward = self.dressup

	if TheNet:IsOnlineMode() then
		if not TheInput:ControllerAttached() then
			self.randomskinsbutton = self.loadout_root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "random.tex", STRINGS.UI.LOBBYSCREEN.RANDOMCHAR, false, false, function()
					self.dressup:AllSpinnersToEnd()
				end
			))
			self.randomskinsbutton:SetPosition(540, 290)
		end
	end
end)

function LoadoutSelect:OnControl(control, down)
    if LoadoutSelect._base.OnControl(self, control, down) then return true end

    -- print("Loadout got control", control, down)

    -- Use right stick for cycling players list
    if down then
        if control == CONTROL_MENU_MISC_2 then
            self.dressup:AllSpinnersToEnd()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        elseif control == CONTROL_PREVVALUE then  -- r-stick left
            self.dressup:ScrollBack(control)
            return true 
        elseif control == CONTROL_NEXTVALUE then -- r-stick right
            self.dressup:ScrollFwd(control)
            return true
        elseif control == CONTROL_SCROLLBACK then
            self.dressup:ScrollBack(control)
            return true
        elseif control == CONTROL_SCROLLFWD then
            self.dressup:ScrollFwd(control)
            return true
        end
    end

    return false
end

function LoadoutSelect:StartLoadout()
    -- Call this again to ensure the portrait is still set if spinners are
    -- disabled (offline mode).
    self:SetPortraitImage()
end

function LoadoutSelect:SetPortraitImage()
    assert(self.currentcharacter)
	if self.currentcharacter and self.currentcharacter ~= "" then
		local name = self.dressup:GetBaseSkin()

        local found_name = SetHeroNameTexture_Gold(self.heroname, self.currentcharacter)
        if found_name then 
            self.heroname:Show()
        else
            self.heroname:Hide()
        end

        local found_oval = false
        if name and name ~= "" and self.currentcharacter ~= "random" then
            found_oval = SetSkinnedOvalPortraitTexture(self.heroportrait, self.currentcharacter, name)
        else
            found_oval = SetOvalPortraitTexture(self.heroportrait, self.currentcharacter)
        end
        self.heroportrait:SetPosition(0,0)
        if not found_oval then
            -- No skinnable oval portrait. Loaded the shield portrait instead.
            -- Oval images are slightly left and shield is slightly right. Adjust to look good.
            self.heroportrait:SetPosition(10,10)
        end

        local quote = STRINGS.SKIN_QUOTES[name] or STRINGS.CHARACTER_QUOTES[self.currentcharacter]
        if quote then
            self.basequote:Show()
            local str = "\"".. quote .."\""
            str = string.gsub(str, "\"\"", "\"")
            self.basequote:SetString(str)
        else
            self.basequote:Hide()
        end

        local title = GetCharacterTitle(self.currentcharacter, name)
        if title then
            self.basetitle:Show()
            self.basetitle:SetString(title)
        else
            self.basetitle:Hide()
        end

		self.dressup:UpdatePuppet()
	end
end

function LoadoutSelect:SelectPortrait(herocharacter)
    if herocharacter ~= nil then
        self.currentcharacter = herocharacter
        self.dressup:SetCurrentCharacter(herocharacter)
    else
        --~ print("THIS SHOULD NEVER HAPPEN IN DST", debugstack())
        self.heroportrait:SetTexture("bigportraits/locked.xml", "locked.tex")
    end
end

function LoadoutSelect:GetHelpText()
	if TheNet:IsOnlineMode() then
		local controller_id = TheInput:GetControllerID()
		local t = {}

		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.LOBBYSCREEN.RANDOMCHAR)

		return table.concat(t, "  ")
	else
		return ""
	end
end

function LoadoutSelect:OnUpdate(dt)
    if self.dressup and self.dressup.puppet then
        self.dressup.puppet:EmoteUpdate(dt)
    end
end

return LoadoutSelect
