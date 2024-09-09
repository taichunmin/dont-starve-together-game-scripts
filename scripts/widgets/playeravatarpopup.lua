local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local PlayerAvatarPortrait = require "widgets/redux/playeravatarportrait"
local TEMPLATES = require "widgets/templates"
local EquipSlot = require("equipslotutil")

local TEXT_COLUMN = 42
local TEXT_WIDTH = 100
local REFRESH_INTERVAL = .5

local ITEM_TEXT_SIZE = 32

local PlayerAvatarPopup = Class(Widget, function(self, owner, player_name, data, show_net_profile)
    Widget._ctor(self, "PlayerAvatarPopupScreen")

    self.owner = owner
    self.player_name = nil
    self.userid = nil
    self.target = nil
    self.anchorpos = nil
    self.anchortime = 0
    self.resetanchortime = -.3
    self.targetmovetime = TheInput:ControllerAttached() and .5 or .75
    self.started = true
    self.settled = true
    self.time_to_refresh = REFRESH_INTERVAL

    self.proot = self:AddChild(Widget("PROOT"))
    self.proot.sroot = self.proot:AddChild(Widget("SROOT"))

    self:SetPlayer(player_name, data, show_net_profile)
end)

--For ease of overriding in mods
function PlayerAvatarPopup:GetDisplayName(player_name, character)
    return player_name or ""
end

function PlayerAvatarPopup:UpdateDisplayName()
    self.title:SetTruncatedString(self:GetDisplayName(self.player_name, self.currentcharacter), 200, 35, true)
end

function PlayerAvatarPopup:ResolveCharacter(data)
    local character = data.prefab or data.character or "wilson"
    return (character == "" and "notselected")
        or (not softresolvefilepath("bigportraits/"..character..".xml") and "unknownmod")
        or character
end

function PlayerAvatarPopup:SetPlayer(player_name, data, show_net_profile)
    self.currentcharacter = self:ResolveCharacter(data)
    self.player_name = player_name
    self.data = data
    self.userid = data.userid
    self.target = data.inst
    self.anchorpos = self.owner:GetPosition()
    self.anchortime = self.resetanchortime

    self:Layout(data, show_net_profile)
    self:UpdateData(data)
end



function PlayerAvatarPopup:Layout(data, show_net_profile)
    local color = data.colour or DEFAULT_PLAYER_COLOUR
    -- net profile button is unreachable with controllers
    show_net_profile = show_net_profile and not TheInput:ControllerAttached()

    if self.currentcharacter ~= "notselected" then
        local left_side = -220
        
        local portrait_height = 150

        if data.playerage ~= nil then
            self.age = self.proot:AddChild(Text(BUTTONFONT, ITEM_TEXT_SIZE)) --25
            self.age:SetPosition(100, portrait_height + 130, 0)
            self.age:SetColour(0, 0, 0, 1)
        end

        self.puppet = self.proot:AddChild(PlayerAvatarPortrait())
        self.puppet:SetPosition(left_side, portrait_height -250)
        self.puppet:SetScale(1)
        
        self.portrait = self.proot:AddChild(Image())
        self.portrait:SetScale(.37)
        self.portrait:SetPosition(left_side, portrait_height)

        self.character_name = self.proot:AddChild(Image("images/names_gold_wilson.xml", "wilson.tex"))
        self.character_name:SetScale(.13)
        self.character_name:SetPosition(left_side, portrait_height + 130)
        SetHeroNameTexture_Gold(self.character_name, self.currentcharacter)

        local widget_height = 100
        local body_offset = 10
        local line_offset = body_offset + (widget_height/2) -- 42 --37
        local line_scale = 1.05

        local left_column = -94
        local right_column = 94

        self.proot.sroot:SetPosition(100,160)

        self.srootbg = self.proot.sroot:AddChild(Image("images/skilltree.xml", "background_box.tex"))
        --self.srootbg = self.proot.sroot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
        self.srootbg:ScaleToSize(450,4*widget_height + 105)
        self.srootbg:SetPosition(7, -144)
        --self.srootbg:SetTint(0.25,0.22,0.15,0.5)

        self.horizontal_line1 = self.proot.sroot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
        self.horizontal_line1:SetScale(line_scale, .25)
        self.horizontal_line1:SetPosition(7, line_offset)

        self.vertical_line = self.proot.sroot:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
        self.vertical_line:SetScale(.5, .6)
        self.vertical_line:SetPosition(5, -142)

        self.body_image = self.proot.sroot:AddChild(self:CreateSkinWidgetForSlot())
        self.body_image:SetPosition(left_column, body_offset)
        self:UpdateSkinWidgetForSlot(self.body_image, "body", data.body_skin or "none")

        self.horizontal_line2 = self.proot.sroot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
        self.horizontal_line2:SetScale(line_scale, .25)
        self.horizontal_line2:SetPosition(7, line_offset - widget_height)

        self.hand_image = self.proot.sroot:AddChild(self:CreateSkinWidgetForSlot())
        self.hand_image:SetPosition(left_column, body_offset - widget_height)
        self:UpdateSkinWidgetForSlot(self.hand_image, "hand", data.hand_skin or "none")

        self.horizontal_line3 = self.proot.sroot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
        self.horizontal_line3:SetScale(line_scale, .25)
        self.horizontal_line3:SetPosition(7, line_offset - 2 * widget_height)

        self.legs_image = self.proot.sroot:AddChild(self:CreateSkinWidgetForSlot())
        self.legs_image:SetPosition(left_column, body_offset - 2 * widget_height)
        self:UpdateSkinWidgetForSlot(self.legs_image, "legs", data.legs_skin or "none")

        self.horizontal_line4 = self.proot.sroot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
        self.horizontal_line4:SetScale(line_scale, .25)
        self.horizontal_line4:SetPosition(7, line_offset - 3 * widget_height)

        self.feet_image = self.proot.sroot:AddChild(self:CreateSkinWidgetForSlot())
        self.feet_image:SetPosition(left_column, body_offset - 3 * widget_height)
        self:UpdateSkinWidgetForSlot(self.feet_image, "feet", data.feet_skin or "none")
 
        self.horizontal_line5 = self.proot.sroot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
        self.horizontal_line5:SetScale(line_scale, .25)
        self.horizontal_line5:SetPosition(7, line_offset - 4 * widget_height)


        local equip_offset = 10

        self.base_image = self.proot.sroot:AddChild(self:CreateSkinWidgetForSlot())
        self.base_image:SetPosition(right_column, equip_offset)
        self:UpdateSkinWidgetForSlot(self.base_image, "base", data.base_skin or self.currentcharacter.."_none")

        self.head_equip_image = self.proot.sroot:AddChild(self:CreateEquipWidgetForSlot())
        self.head_equip_image:SetPosition(right_column, equip_offset - widget_height)
        self:UpdateEquipWidgetForSlot(self.head_equip_image, EQUIPSLOTS.HEAD, data.equip)

        self.hand_equip_image = self.proot.sroot:AddChild(self:CreateEquipWidgetForSlot())
        self.hand_equip_image:SetPosition(right_column, equip_offset - 2 * widget_height)
        self:UpdateEquipWidgetForSlot(self.hand_equip_image, EQUIPSLOTS.HANDS, data.equip)

        self.body_equip_image = self.proot.sroot:AddChild(self:CreateEquipWidgetForSlot())
        self.body_equip_image:SetPosition(right_column, equip_offset - 3 * widget_height)
        self:UpdateEquipWidgetForSlot(self.body_equip_image, EQUIPSLOTS.BODY, data.equip)

        if show_net_profile and TheNet:IsNetIDPlatformValid(data.netid) then

            self.netprofilebutton = self.proot:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "steam.tex", "", false, false, function() if data.netid ~= nil then TheNet:ViewNetProfile(data.netid) end end ))
            self.netprofilebutton:SetScale(.5)
            --self.netprofilebutton:SetPosition(left_column - 60, 62, 0)
            self.netprofilebutton:SetPosition(100, portrait_height + 130, 0) 
        end
    else
        self.proot:SetPosition(10, 0)
        self.bg = self.proot:AddChild(TEMPLATES.CenterPanel(nil, nil, true))
        self.bg:SetScale(.3, .6)

        self.title = self.proot:AddChild(Text(TALKINGFONT, 30))
        self.title:SetPosition(0, 75, 0)
        self:UpdateDisplayName()

        self.text = self.proot:AddChild(Text(UIFONT, 25, STRINGS.UI.PLAYER_AVATAR.CHOOSING))
        self.text:SetColour(color)

        if show_net_profile and TheNet:IsNetIDPlatformValid(data.netid) then
            self.netprofilebutton = self.proot:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "steam.tex", "", false, false, function() if data.netid ~= nil then TheNet:ViewNetProfile(data.netid) end end ))
            self.netprofilebutton:SetScale(.5)
            self.netprofilebutton:SetPosition(0, -75, 0)
        end
    end
end

function PlayerAvatarPopup:UpdateData(data)
    if self.title ~= nil then
        if data.colour ~= nil then
            self.title:SetColour(unpack(data.colour))
        else
            self.title:SetColour(0, 0, 0, 1)
        end
    end

    if self.age ~= nil and data.playerage ~= nil then
        self.age:SetString(STRINGS.UI.PLAYER_AVATAR.AGE_SURVIVED.." "..data.playerage.." "..(data.playerage == 1 and STRINGS.UI.PLAYER_AVATAR.AGE_DAY or STRINGS.UI.PLAYER_AVATAR.AGE_DAYS))        local w = self.age:GetRegionSize()
        if self.netprofilebutton then
            local pos = self.netprofilebutton:GetPosition()
            self.netprofilebutton:SetPosition(pos.x - (w/2) -25, pos.y, 0)
        end
    end

    if self.puppet ~= nil then
        local build = self.currentcharacter == "unknownmod" and "mod_player_build" or self.currentcharacter
        self.puppet:UpdatePlayerListing(nil, nil, build, GetSkinsDataFromClientTableData(data))
        if self.userid == nil then
            -- Only actual users get vanity items.
            self.puppet:HideVanityItems()
        end
    end

    if self.portrait ~= nil then
        SetSkinnedOvalPortraitTexture( self.portrait, self.currentcharacter, data.base_skin or self.currentcharacter.."_none")
    end

    if self.body_image ~= nil then
        self:UpdateSkinWidgetForSlot(self.body_image, "body", data.body_skin or "none")
    end
    if self.hand_image ~= nil then
        self:UpdateSkinWidgetForSlot(self.hand_image, "hand", data.hand_skin or "none")
    end
    if self.legs_image ~= nil then
        self:UpdateSkinWidgetForSlot(self.legs_image, "legs", data.legs_skin or "none")
    end
    if self.feet_image ~= nil then
        self:UpdateSkinWidgetForSlot(self.feet_image, "feet", data.feet_skin or "none")
    end

    if self.base_image ~= nil then
        self:UpdateSkinWidgetForSlot(self.base_image, "base", data.base_skin or self.currentcharacter.."_none")
    end
    if self.head_equip_image ~= nil then
        self:UpdateEquipWidgetForSlot(self.head_equip_image, EQUIPSLOTS.HEAD, data.equip)
    end
    if self.hand_equip_image ~= nil then
        self:UpdateEquipWidgetForSlot(self.hand_equip_image, EQUIPSLOTS.HANDS, data.equip)
    end
    if self.body_equip_image ~= nil then
        self:UpdateEquipWidgetForSlot(self.body_equip_image, EQUIPSLOTS.BODY, data.equip)
    end
end

function PlayerAvatarPopup:SetTitleTextSize(size)
    self.title:SetSize(size)
end

function PlayerAvatarPopup:SetButtonTextSize(size)
    self.menu:SetTextSize(size)
end

function PlayerAvatarPopup:OnControl(control, down)
    if PlayerAvatarPopup._base.OnControl(self,control, down) then return true end
end

function PlayerAvatarPopup:OnUpdate(dt)
    if not self.started then
        return
    elseif self.owner.components.playercontroller == nil or
        not self.owner.components.playercontroller:IsEnabled() or
        not self.owner.HUD:IsVisible() or
        (self.target ~= nil and
        not (self.target:IsValid() and
            self.owner:IsNear(self.target, 20))) then
        -- Auto close when controls become disabled or target moves away
        self:Close()
        return
    end

    local pos = self.owner:GetPosition()
    local moved = self.anchorpos ~= pos
    if moved then
        self.anchorpos = pos
    end

    -- Anchor to a position once we've stopped moving a certain time
    -- Then auto-close once we've continuously moved a certain time
    if self.anchortime < 0 then
        self.anchortime = moved and self.resetanchortime or self.anchortime + dt
    elseif self.anchortime < self.targetmovetime then
        self.anchortime = moved and self.anchortime + dt or 0
    else
        self:Close()
        return
    end

    -- Periodic refresh if we're still active
    if self.time_to_refresh > dt then
        self.time_to_refresh = self.time_to_refresh - dt
    elseif self.userid ~= nil then
        self.time_to_refresh = REFRESH_INTERVAL
        local client_obj = TheNet:GetClientTableForUser(self.userid)
        if client_obj ~= nil then
            self:UpdateData(client_obj)
        end
    end
end

function PlayerAvatarPopup:GetHelpText()
    --[[local controller_id = TheInput:GetControllerID()
    local t = {}
    if #self.buttons > 1 and self.buttons[#self.buttons] then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    end
    return table.concat(t, "  ")
    ]]
end

function PlayerAvatarPopup:CreateSkinWidgetForSlot()
    local image_group = Widget("image_group")

    image_group._text = image_group:AddChild(Text(UIFONT, ITEM_TEXT_SIZE))
    image_group._text:SetPosition(TEXT_COLUMN, -3, 0)
    image_group._text:SetHAlign(ANCHOR_LEFT)
    image_group._text:SetVAlign(ANCHOR_BOTTOM)

    image_group._shadow = image_group:AddChild(UIAnim())
    image_group._shadow:GetAnimState():SetBuild("frames_comp")
    image_group._shadow:GetAnimState():SetBank("frames_comp")
    image_group._shadow:GetAnimState():Hide("frame")
    image_group._shadow:GetAnimState():Hide("NEW")
    image_group._shadow:GetAnimState():PlayAnimation("idle_on", true)
    image_group._shadow:SetScale(.7)
    image_group._shadow:SetPosition(-53, -3)
    image_group._shadow:GetAnimState():SetMultColour(0.3,0.3,0.3,0.7)
    image_group._shadow:Hide()

    image_group._image = image_group:AddChild(UIAnim())
    image_group._image:GetAnimState():SetBuild("frames_comp")
    image_group._image:GetAnimState():SetBank("frames_comp")
    image_group._image:GetAnimState():Hide("frame")
    image_group._image:GetAnimState():Hide("NEW")
    image_group._image:GetAnimState():PlayAnimation("idle_on", true)
    image_group._image:SetScale(.7)
    image_group._image:SetPosition(-50, 0)

    return image_group
end

function PlayerAvatarPopup:UpdateSkinWidgetForSlot(image_group, slot, skin_name)
    image_group._text:SetColour(unpack(GetColorForItem(skin_name)))

    local namestr = STRINGS.NAMES[string.upper(skin_name)] or GetSkinName(skin_name)

    image_group._text:SetMultilineTruncatedString(namestr, 2, TEXT_WIDTH, 25, true, true)
    local shadow_build = nil
    local skin_build = GetBuildForItem(skin_name)

    if skin_build == nil or skin_build == "none" then
        skin_build =
            (slot == "body" and "body_default1") or
            (slot == "hand" and "hand_default1") or
            (slot == "legs" and "legs_default1") or
            (slot == "feet" and "feet_default1") or
            self.currentcharacter

        if slot == "body" or slot == "hand" or slot == "legs" or slot == "feet" then
            image_group._shadow:Show()
            shadow_build = 
                (slot == "body" and "body_default1") or
                (slot == "hand" and "hand_default1") or
                (slot == "legs" and "legs_default1") or
                (slot == "feet" and "feet_default1")
            image_group._shadow:GetAnimState():OverrideSkinSymbol("SWAP_ICON", shadow_build, "SWAP_ICON")
        end
    end
    image_group._image:GetAnimState():OverrideSkinSymbol("SWAP_ICON", skin_build, "SWAP_ICON")
end

local DEFAULT_IMAGES =
{
    hands = "unknown_hand.tex",
    head = "unknown_head.tex",
    body = "unknown_body.tex",
}

function PlayerAvatarPopup:CreateEquipWidgetForSlot()
    local image_group = Widget("image_group")

    image_group._text = image_group:AddChild(Text(UIFONT, ITEM_TEXT_SIZE))
    image_group._text:SetPosition(TEXT_COLUMN, -3, 0)
    image_group._text:SetHAlign(ANCHOR_LEFT)
    image_group._text:SetVAlign(ANCHOR_BOTTOM)

    image_group._shadow = image_group:AddChild(Image())
    image_group._shadow:SetScale(1)
    image_group._shadow:SetPosition(-53, -3)
    image_group._shadow:SetTint(0.3,0.3,0.3,0.7)
    image_group._shadow:Hide()

    image_group._image = image_group:AddChild(Image())
    image_group._image:SetScale(1)
    image_group._image:SetPosition(-50, 0)

    return image_group
end

function PlayerAvatarPopup:UpdateEquipWidgetForSlot(image_group, slot, equipdata)
    local name = equipdata ~= nil and equipdata[EquipSlot.ToID(slot)] or nil
    name = name ~= nil and #name > 0 and name or "none"
    local namestr = STRINGS.NAMES[string.upper(name)] or GetSkinName(name)

    image_group._text:SetColour(unpack(GetColorForItem(name)))
    image_group._text:SetMultilineTruncatedString(namestr, 2, TEXT_WIDTH, 25, true, true)

    local atlas = ""
    local default = DEFAULT_IMAGES[slot] or "trinket_5.tex"
    local shadow = false
    if name == "none" then
        shadow = true
        if slot == EQUIPSLOTS.BODY then
            --atlas = "images/hud2.xml"
            name = "equip_slot_body_hud"
        elseif slot == EQUIPSLOTS.HANDS then
            --atlas = "images/hud2.xml"
            name = "equip_slot_hud"
        elseif slot == EQUIPSLOTS.HEAD then
            --atlas = "images/hud2.xml"
            name = "equip_slot_head_hud"
        else
            name = "default"
        end
    end

	if softresolvefilepath("images/inventoryimages/"..name..".xml") ~= nil then
        atlas = "images/inventoryimages/"..name..".xml"
    else
        atlas = GetInventoryItemAtlas(name..".tex")
    end

    image_group._image:SetTexture(atlas, name..".tex", default)

    if shadow then
        image_group._shadow:SetTexture(atlas, name..".tex", default)
        image_group._shadow:Show()
    end
end

return PlayerAvatarPopup
