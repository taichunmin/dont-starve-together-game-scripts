local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Puppet = require "widgets/skinspuppet"
local Image = require "widgets/image"
local Menu = require "widgets/menu"
local Text = require "widgets/text"

local TEMPLATES = require("widgets/redux/templates")


local SkinDebugScreen = Class(Screen, function(self, prev_screen, user_profile)
	Screen._ctor(self, "skindebugscreen")
    self.prev_screen = prev_screen
    self.user_profile = user_profile


    self.pants = {}
    self.shoes = {}

	self:DoInit()


	self.default_focus = self.menu
end)

function SkinDebugScreen:DoInit()
    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(Image("images/bg_spiral.xml", "bg_spiral.tex"))


    local menu_items = {}
    table.insert( menu_items, {text="Last Shoes", cb= function() self:SetShoes(false) end})
    table.insert( menu_items, {text="Next Shoes", cb= function() self:SetShoes(true) end})
    table.insert( menu_items, {text="Last Pants", cb= function() self:SetPants(false) end})
    table.insert( menu_items, {text="Next Pants", cb= function() self:SetPants(true) end})
    self.control_menu = self.root:AddChild(Menu(menu_items, 50))
    self.control_menu:SetPosition(505, -300)


    local size_items = {}
    table.insert( size_items, {text="Shoes -", cb= function() self:ResizeShoes(-1) end})
    table.insert( size_items, {text="Shoes +", cb= function() self:ResizeShoes(1) end})
    table.insert( size_items, {text="Pants -", cb= function() self:ResizePants(-1) end})
    table.insert( size_items, {text="Pants +", cb= function() self:ResizePants(1) end})
    self.size_menu = self.root:AddChild(Menu(size_items, 50))
    self.size_menu:SetPosition(285, -300)



    self.pants_txt = self.root:AddChild(Text(UIFONT, 30))
    self.pants_txt:SetPosition(500, -40)
    self.shoes_txt = self.root:AddChild(Text(UIFONT, 30))
    self.shoes_txt:SetPosition(500, -80)

    self.puppet_root = self.root:AddChild(Widget("puppet_root"))
    self.puppet_root:SetPosition(0, -200)

    self.puppet = self.puppet_root:AddChild(Puppet())
    self.puppet:SetScale(5.0)
    self.puppet:SetClickable(false)

    self.character = "wilson"
    self.skintypes = GetSkinModes(self.character)
	self.view_index = 1
    self.selected_skintype = self.skintypes[self.view_index].type

    self.puppet:SetSkins(self.character, "wilson_formal", {}, true, self.selected_skintype)




    for id,data in pairs( CLOTHING ) do
        if table.contains( data.symbol_overrides, "leg" ) then
            table.insert( self.pants,
                {
                    id = id,
                    type = data.type
                }
            )
        elseif table.contains( data.symbol_overrides, "foot" ) then
            table.insert( self.shoes,
                {
                    id = id,
                    type = data.type
                }
            )
        end
    end

    self.pants_index = 1 --need default before sorting
    self.shoes_index = 1 --need default before sorting
    self:SortClothesLists()
    self.pants_index = 1
    self.shoes_index = 1
    self:UpdatePuppet()

    if not TheInput:ControllerAttached() then
        self.back_button = self.root:AddChild(TEMPLATES.BackButton(
                function()
                    TheFrontEnd:FadeBack()
                end
            ))
    end
end


function SkinDebugScreen:ResizePants(delta)
    local a = self.pants[self.pants_index]
    CLOTHING[a.id].legs_cuff_size = (CLOTHING[a.id].legs_cuff_size or 1) + delta

    self:SortClothesLists()
    self:UpdatePuppet()
end

function SkinDebugScreen:ResizeShoes(delta)
    local b = self.shoes[self.shoes_index]
    CLOTHING[b.id].feet_cuff_size = (CLOTHING[b.id].feet_cuff_size or 1) + delta

    self:SortClothesLists()
    self:UpdatePuppet()
end


function SkinDebugScreen:SortClothesLists()

    local pants_name = self.pants[self.pants_index].id
    local shoes_name = self.shoes[self.shoes_index].id

    table.sort(self.pants,
        function(a,b)
            if (CLOTHING[a.id].legs_cuff_size or 1) == (CLOTHING[b.id].legs_cuff_size or 1) then
                return a.id > b.id
            else
                return (CLOTHING[a.id].legs_cuff_size or 1) > (CLOTHING[b.id].legs_cuff_size or 1)
            end
        end
    )

    table.sort(self.shoes,
        function(a,b)
            if (CLOTHING[a.id].feet_cuff_size or 1) == (CLOTHING[b.id].feet_cuff_size or 1) then
                return a.id > b.id
            else
                return (CLOTHING[a.id].feet_cuff_size or 1) > (CLOTHING[b.id].feet_cuff_size or 1)
            end
        end
    )

    --maintain positiion
    for k,v in ipairs(self.pants) do
        if pants_name == v.id then
            self.pants_index = k
        end
    end
    for k,v in ipairs(self.shoes) do
        if shoes_name == v.id then
            self.shoes_index = k
        end
    end
end


function SkinDebugScreen:UpdatePuppet()
    local a = self.pants[self.pants_index]
    local b = self.shoes[self.shoes_index]

    local clothes = {}
    clothes[a.type] = a.id
    clothes[b.type] = b.id

    self.pants_txt:SetString( a.id .. " " .. tostring(CLOTHING[a.id].legs_cuff_size) )
    self.shoes_txt:SetString( b.id .. " " .. tostring(CLOTHING[b.id].feet_cuff_size) )

    self.puppet:SetSkins(self.character, "wilson_none", clothes, true, self.selected_skintype)
end

function SkinDebugScreen:SetShoes(forward)
    if forward then
        self.shoes_index = self.shoes_index + 1
    else
        self.shoes_index = self.shoes_index - 1
    end

    if self.shoes_index == 0 then
        self.shoes_index = 1
    end
    if self.shoes_index > #self.shoes then
        self.shoes_index = #self.shoes
    end

    self:UpdatePuppet()
end


function SkinDebugScreen:SetPants(forward)
    if forward then
        self.pants_index = self.pants_index + 1
    else
        self.pants_index = self.pants_index - 1
    end

    if self.pants_index == 0 then
        self.pants_index = 1
    end
    if self.pants_index > #self.pants then
        self.pants_index = #self.pants
    end

    self:UpdatePuppet()
end

function SkinDebugScreen:OnControl(control, down)
    if SkinDebugScreen._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:FadeBack()
        return true
    end
end

function SkinDebugScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SERVERLISTINGSCREEN.BACK)

    return table.concat(t, "  ")
end

function SkinDebugScreen:OnUpdate(dt)
end


return SkinDebugScreen
