local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local CraftSlots = require "widgets/craftslots"

require "widgets/widgetutil"

local TileBG = require ("widgets/tilebg"..((TheNet ~= nil and TheNet:GetServerGameMode() == "quagmire") and "_quagmire" or ""))

local CRAFTING_ATLAS = nil

local Crafting = Class(Widget, function(self, owner, num_slots)
    Widget._ctor(self, "Crafting")

    CRAFTING_ATLAS = GetGameModeProperty("hud_atlas") or HUD_ATLAS --done inside the constructor so that pipeline scripts don't need GetGameModeProperty

    self.owner = owner

    self.bg = self:AddChild(TileBG(CRAFTING_ATLAS, "craft_slotbg.tex"))

    --slots
    self.max_slots = num_slots
    self.current_slots = num_slots
    self.craftslots = CraftSlots(num_slots, owner)
    self:AddChild(self.craftslots)

    --connectors
    self.downconnector = self:AddChild(Image(CRAFTING_ATLAS, "craft_sep_h.tex"))
    self.upconnector = self:AddChild(Image(CRAFTING_ATLAS, "craft_sep_h.tex"))
    self.downendcapbg = self:AddChild(Image(CRAFTING_ATLAS, "craft_sep.tex"))
	self.downendcapbg:MoveToBack()
    self.upendcapbg = self:AddChild(Image(CRAFTING_ATLAS, "craft_sep.tex"))
	self.upendcapbg:MoveToBack()

    --buttons
    self.downbutton = self:AddChild(ImageButton(CRAFTING_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex", nil, nil, {1,1}, {0,0}))
    self.upbutton = self:AddChild(ImageButton(CRAFTING_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex", nil, nil, {1,1}, {0,0}))
    local but_w, but_h = self.downbutton:GetSize()
    self.but_w = but_w
    self.but_h = but_h
    self.downbutton.scale_on_focus = false
    self.upbutton.scale_on_focus = false
    self.downbutton:SetOnClick(function() self:ScrollDown() end)
    self.upbutton:SetOnClick(function() self:ScrollUp() end)

    -- start slightly scrolled down
    self.idx = -1
    self.scrolldir = true

    self:UpdateRecipes()
end)

local function Quagmire_Layout(self, horizontal)
	local cap_w, cap_h = self.downbutton:GetSize()
	local slot_w, slot_h = self.craftslots.slots[1]:GetSize()
	local con_w, con_h = self.downendcapbg:GetSize()
	local con_overlap = 3 -- the slots have to overlap the connectors because the slots do not have a hard edge (there is alpha around it)

	-- screen anchors, Quagmire doesn't need them
	self.downconnector:Hide()
	self.upconnector:Hide()

    self.downbutton:SetScale(Vector3(1, -1, 1))

	if self.valid_recipes ~= nil and #self.valid_recipes <= self.max_slots then
		self.downbutton:SetPosition(0, -(cap_h*0.5), 0)
		self.downendcapbg:SetPosition(0, -(cap_h + con_h*0.5), 0)

		local slot_y = con_overlap - (cap_h + con_h)
		for k = 1, self.current_slots do
			self.craftslots.slots[k]:SetPosition(0, slot_y - (slot_h*0.5))
			slot_y = slot_y - (slot_h - con_overlap)
			if self.bg.seps[k] ~= nil then
				self.bg.seps[k]:SetPosition(0, slot_y - (con_h*0.5)) -- thin rope
				slot_y = slot_y - con_h
			end
		end
		self.upendcapbg:SetPosition(0, slot_y - (con_h*0.5))
		self.upbutton:SetPosition(0, slot_y - (con_h + cap_h*0.5) + con_overlap)

		self.upendcapbg:Show()
		self.downendcapbg:Show()
	else
		self.downbutton:SetPosition(0, -(cap_h*0.5), 0)

		local slot_y = con_overlap - (cap_h) + slot_h*0.5
		for k = 1, self.current_slots do
			self.craftslots.slots[k]:SetPosition(0, slot_y - (slot_h*0.5))
			slot_y = slot_y - (slot_h - con_overlap)
			if self.bg.seps[k] ~= nil then
				self.bg.seps[k]:SetPosition(0, slot_y - (con_h*0.5)) -- thin rope
				slot_y = slot_y - con_h
			end
		end
		self.upbutton:SetPosition(0, slot_y - (cap_h*0.5) + con_overlap + slot_h*0.5)

		self.downendcapbg:Hide()
		self.upendcapbg:Hide()
	end
end

function Crafting:SetOrientation(horizontal)
    self.horizontal = horizontal
    self.bg.horizontal = horizontal
    self.bg.sepim = horizontal and "craft_sep_h.tex" or "craft_sep.tex"

    self.bg:SetNumTiles(self.current_slots)

	if TheNet:GetServerGameMode() == "quagmire" then
		Quagmire_Layout(self, horizontal)
    elseif horizontal then
		for k = 1, #self.craftslots.slots do
			local slotpos = self.bg:GetSlotPos(k)
			self.craftslots.slots[k]:SetPosition(slotpos:Get())
		end

        self.downbutton:SetRotation(90)
        self.upbutton:SetRotation(-90)

		local slot_w, slot_h = self.bg:GetSlotSize()

        local x = (self.bg.length + self.but_w - slot_w) * .5
        self.downbutton:SetPosition(-x, 0, 0)
        self.upbutton:SetPosition(x, 0, 0)

        self.downconnector:Hide()
        self.upconnector:Hide()
        self.downendcapbg:Hide()
        self.upendcapbg:Hide()
    else
        self.downbutton:SetScale(Vector3(1, -1, 1))

		local slot_w, slot_h = self.bg:GetSlotSize()
		local w, h = self.bg:GetSize()

		for k = 1, #self.craftslots.slots do
			local slotpos = self.bg:GetSlotPos(k)
			self.craftslots.slots[k]:SetPosition(slotpos:Get())
		end

	    local end_padding = 25
		if self.valid_recipes ~= nil and #self.valid_recipes <= self.max_slots then
			local dy = (self.bg.length - slot_h) * .5 - end_padding
			local y = dy + self.but_h / 1.35
			self.downbutton:SetPosition(0, y, 0)
			self.upbutton:SetPosition(0, -y, 0)

			y = dy + self.but_h / 1.5
			self.downconnector:SetPosition(-71, y, 0)
			self.upconnector:SetPosition(-71, 5 - y, 0)

			y = dy + self.but_h * .5
			self.downendcapbg:SetPosition(0, y, 0)
			self.upendcapbg:SetPosition(0, -y, 0)

			self.downendcapbg:Show()
			self.upendcapbg:Show()
		else
			local y = (self.bg.length + self.but_h - slot_h) * .5
			self.downbutton:SetPosition(0, y, 0)
			self.upbutton:SetPosition(0, -y, 0)

			self.downconnector:SetPosition(-68, y - end_padding + 5, 0)
			self.upconnector:SetPosition(-68, end_padding - y + 5, 0)

			self.downendcapbg:Hide()
			self.upendcapbg:Hide()
		end
    end
end

function Crafting:SetFilter(filter)
    local new_filter = filter ~= self.filter
    self.filter = filter

    if new_filter then
        self:UpdateRecipes()
    end
end

function Crafting:Close(fn)
    self.open = false
    self:Disable()
    self.craftslots:CloseAll()
    self:MoveTo(self.in_pos, self.out_pos, .33, function()
        self:Hide()
        if fn ~= nil then
            fn()
        end
    end)
end

function Crafting:Open(fn)
    self.open = true
    self:Enable()
    self:MoveTo(self.out_pos, self.in_pos, .33, fn)
    self:Show()
    self:UpdateScrollButtons()
end

local function SortByKey(a, b)
    return a.sortkey < b.sortkey
end

function Crafting:Resize(num_recipes)
    --V2C: always refresh now... even if num_recipes is the same,
    --     whether or not we need page up/down buttons may change
    self.num_recipes = num_recipes
    self.current_slots = math.min(num_recipes, self.max_slots)
    self.craftslots:SetNumSlots(self.current_slots)

    if #self.valid_recipes <= self.max_slots then
        self.downbutton:SetTextures(CRAFTING_ATLAS, "craft_end_short.tex", "craft_end_short.tex", "craft_end_short.tex", nil, nil, {1,1}, {0,0})-- self.downbutton:Hide()
        self.upbutton:SetTextures(CRAFTING_ATLAS, "craft_end_short.tex", "craft_end_short.tex", "craft_end_short.tex", nil, nil, {1,1}, {0,0})-- self.upbutton:Hide()

        self.downbutton.o_pos = nil
        self.upbutton.o_pos = nil

        self.upconnector:SetScale(1.7,.7)
        self.downconnector:SetScale(1.7,.7)
    else
        self.downbutton:SetTextures(CRAFTING_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex", nil, nil, {1,1}, {0,0})-- self.downbutton:Show()
        self.upbutton:SetTextures(CRAFTING_ATLAS, "craft_end_normal.tex", "craft_end_normal_mouseover.tex", "craft_end_normal_disabled.tex", nil, nil, {1,1}, {0,0})-- self.upbutton:Show()

        self.upconnector:SetScale(1,1)
        self.downconnector:SetScale(1,1)
    end

    self:SetOrientation(false)
end

function Crafting:UpdateIdx()
    self.use_idx = self:CanScroll()
end

function Crafting:CanScroll()
    return self.valid_recipes ~= nil and #self.valid_recipes > self.max_slots
end

function Crafting:UpdateRecipes()
    if self.owner ~= nil and self.owner.replica.builder ~= nil then

        self.valid_recipes = {}

        for k,v in pairs(AllRecipes) do
            if IsRecipeValid(v.name) and
            (self.filter == nil or self.filter(v.name)) and --Has no filter or passes the filter in place
            (self.owner.replica.builder:KnowsRecipe(v) or --[[Knows the recipe]]
            ShouldHintRecipe(v.level, self.owner.replica.builder:GetTechTrees())) --[[ Knows enough to see it]] then
                table.insert(self.valid_recipes, v)
            end
        end
        table.sort(self.valid_recipes, SortByKey)

        local shown_num = 0 --Number of recipes shown

        local num = math.min(self.max_slots, #self.valid_recipes) --How many recipe slots we're going to need

        self:Resize(#self.valid_recipes)
        self.craftslots:Clear()

        self:UpdateIdx()

        --V2C: NOTE: when it does need to scroll, there are 2 empty half-slots
        --           at the top and bottom, which is why this math looks weird
        --default is -1, the recipe starts in the top slot.
        self.idx = self.use_idx
            and math.clamp(self.idx, -1, #self.valid_recipes - (self.max_slots - 1))
            or -1

        for i = 1, num + 1 do --For each visible slot assign a recipe
            local slot = self.craftslots.slots[i]
            if slot ~= nil then
                local recipe = self.valid_recipes[((self.use_idx and self.idx) or 0) + i]
                if recipe then
                    slot:SetRecipe(recipe.name)
                    shown_num = shown_num + 1
                else
                    slot:Close()
                end
            end
        end

        self:UpdateScrollButtons()
    end
end

function Crafting:UpdateScrollButtons()
    -- #### It should be noted that downbutton goes "up" and up button goes "down"! ####

    local canscroll = self:CanScroll()

    if canscroll and self.idx >= 0 then
        self.downbutton:Enable()
    else
        self.downbutton:Disable()
    end

    if canscroll and self.idx + self.current_slots <= #self.valid_recipes then
        self.upbutton:Enable()
    else
        self.upbutton:Disable()
    end
end

function Crafting:OnControl(control, down)
    if Crafting._base.OnControl(self, control, down) then return true end

    if down and self.focus then
        if control == CONTROL_SCROLLBACK then
            self:ScrollDown()
            return true
        elseif control == CONTROL_SCROLLFWD then
            self:ScrollUp()
            return true
        end
    end
end

function Crafting:ScrollUp()
    if not IsPaused() then
        local oldidx = self.idx
        self.idx = self.idx + 1
        self:UpdateRecipes()
        if self.idx ~= oldidx then
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/craft_up")
        end
    end
end

function Crafting:ScrollDown()
    if not IsPaused() then
        local oldidx = self.idx
        self.idx = self.idx - 1
        self:UpdateRecipes()
        if self.idx ~= oldidx then
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/craft_down")
        end
    end
end

return Crafting
