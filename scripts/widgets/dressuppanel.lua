local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Puppet = require "widgets/skinspuppet"
local Spinner = require "widgets/spinner"
local AnimSpinner = require "widgets/animspinner"


local TEMPLATES = require "widgets/templates"

local testNewTag = false

-------------------------------------------------------------------------------------------------------
-- onNextFn and onPrevFn are called when the base spinner is changed. They should be used to
-- update the portrait picture.

-- See wardropepopup for definitions of recent_item_types and recent_item_ids

local window_y_pos = RESOLUTION_Y-325

local DressupPanel = Class(Widget, function(self, owner_screen, profile, playerdata, onChanged, recent_item_types, recent_item_ids, include_random_options)
    self.owner_screen = owner_screen

    Widget._ctor(self, "DressupPanel")

    --print("DressupPanel constructor", self, owner, profile or "nil", onNextFn or "nil", onPrevFn or "nil")
    self.profile = profile
    self.playerdata = playerdata
    self.include_random_options = include_random_options
    self:GetClothingOptions()
    self:GetSkinsList()
	self.currentcharacter = "wilson"

    self.recent_item_types = recent_item_types
    -- ids can be ignored at least for now.

    self.onChanged = onChanged

    self.root = self:AddChild(Widget("Root"))
	if not TheNet:IsOnlineMode() then
		self.bg_group = self.root:AddChild(TEMPLATES.CurlyWindow(10, 400, .6, .6, 39, -25))

		self.dressup_bg = self.bg_group:AddChild(Image("images/serverbrowser.xml", "side_panel.tex"))
		self.dressup_bg:SetScale(-.66, .63)
		self.dressup_bg:SetPosition(5, 5)

		self.dressup_hanger = self.bg_group:AddChild(Image("images/lobbyscreen.xml", "customization_coming_image_all.tex"))
		self.dressup_hanger:SetScale(.66, .7)

		local text1 = nil
		if owner_screen.name == "ScarecrowClothingPopupScreen" then
			text1 = self.bg_group:AddChild(Text(TALKINGFONT, 30, STRINGS.UI.LOBBYSCREEN.CUSTOMIZE_SCARECROW))
		else
			text1 = self.bg_group:AddChild(Text(TALKINGFONT, 30, STRINGS.UI.LOBBYSCREEN.CUSTOMIZE))
		end
		text1:SetPosition(10,150)
		text1:SetHAlign(ANCHOR_MIDDLE)
		text1:SetColour(unpack(GREY))

		local text2 = self.bg_group:AddChild(Text(TALKINGFONT, 30, STRINGS.UI.LOBBYSCREEN.OFFLINE))
		text2:SetPosition(10,-100)
		text2:SetHAlign(ANCHOR_MIDDLE)
		text2:SetColour(unpack(GREY))
	else
		self.bg_group = self.root:AddChild(TEMPLATES.CurlyWindow(10, 520, .6, .6, 39, -25))
	    --self.dressup.bg_group:SetPosition(RESOLUTION_X - 250, window_y_pos, 0)

		self.dressup_bg = self.bg_group:AddChild(Image("images/serverbrowser.xml", "side_panel.tex"))
		self.dressup_bg:SetScale(-.66, -.82)
		self.dressup_bg:SetPosition(5, 6)

		self.spinners = self.root:AddChild(Widget("spinners"))
		self.spinners:SetPosition(-5, 0)
		self.dressup_frame = self.root:AddChild(Widget("frame"))
		self.outline = self.dressup_frame:AddChild(Widget("outline"))
		self.outline:SetPosition(-5, 0)

		local title_height = 190


		self.puppet_group = self.root:AddChild(Widget("puppet"))
		self.puppet_group:SetPosition(-5, 0)

		self.glow = self.puppet_group:AddChild(Image("images/lobbyscreen.xml", "glow.tex"))
		self.glow:SetPosition( 10, title_height-20)
		self.glow:SetScale(1)
		self.glow:SetTint(1, 1, 1, .5)
		self.glow:SetClickable(false)

		self.puppet = self.puppet_group:AddChild(Puppet())
		self.puppet:SetPosition( 10, title_height - 70)
		self.puppet:SetScale(1.75)
		self.puppet:SetClickable(false)

		self.shadow = self.puppet_group:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
	    self.shadow:SetPosition(8, title_height - 75)
	    self.shadow:SetScale(.3)

	    self.random_avatar = self.puppet_group:AddChild(Image("images/lobbyscreen.xml", "randomskin.tex"))
		self.random_avatar:SetPosition(10, title_height )
		self.random_avatar:SetScale(.34)
		self.random_avatar:SetClickable(false)
		self.random_avatar:Hide()

		local body_offset = 35
		local vert_scale = .56
		local option_height = 75
		local spinner_offset = -10
		local arrow_scale = .3

		self.upper_horizontal_line = self.outline:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
		self.upper_horizontal_line:SetScale(.19, .4)
		self.upper_horizontal_line:SetPosition(10, body_offset+option_height, 0)

	    self.mid_horizontal_line1 = self.outline:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	    self.mid_horizontal_line1:SetScale(.19, .4)
	    self.mid_horizontal_line1:SetPosition(10, body_offset, 0)

	    self.mid_horizontal_line2 = self.outline:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	    self.mid_horizontal_line2:SetScale(.19, .4)
	    self.mid_horizontal_line2:SetPosition(10, body_offset-option_height, 0)

	    self.mid_horizontal_line3 = self.outline:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	    self.mid_horizontal_line3:SetScale(.19, .4)
	    self.mid_horizontal_line3:SetPosition(10, body_offset-2*option_height, 0)

	    self.mid_horizontal_line4 = self.outline:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	    self.mid_horizontal_line4:SetScale(.19, .4)
	    self.mid_horizontal_line4:SetPosition(10, body_offset-3*option_height, 0)

	    self.left_vertical_line = self.outline:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
	    self.left_vertical_line:SetScale(.45, vert_scale)
	    self.left_vertical_line:SetPosition(-100, -75, 0)

	    self.right_vertical_line = self.outline:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
	    self.right_vertical_line:SetScale(.45, vert_scale)
	    self.right_vertical_line:SetPosition(120, -75, 0)

		self.base_spinner = self.spinners:AddChild(self:MakeSpinner("base"))
		self.base_spinner:SetPosition(0, body_offset + spinner_offset)
		self.base_spinner.spinner:SetArrowScale(arrow_scale)

		self.body_spinner = self.spinners:AddChild(self:MakeSpinner("body"))
		self.body_spinner:SetPosition(0, body_offset-option_height + spinner_offset)
		self.body_spinner.spinner:SetArrowScale(arrow_scale)

		self.hand_spinner = self.spinners:AddChild(self:MakeSpinner("hand"))
		self.hand_spinner:SetPosition(0, body_offset-2*option_height + spinner_offset)
		self.hand_spinner.spinner:SetArrowScale(arrow_scale)

		self.legs_spinner = self.spinners:AddChild(self:MakeSpinner("legs"))
		self.legs_spinner:SetPosition(0, body_offset-3*option_height + spinner_offset)
		self.legs_spinner.spinner:SetArrowScale(arrow_scale)

		self.feet_spinner = self.spinners:AddChild(self:MakeSpinner("feet"))
		self.feet_spinner:SetPosition(0, body_offset-4*option_height + spinner_offset)
		self.feet_spinner.spinner:SetArrowScale(arrow_scale)

		self.all_spinners = { self.base_spinner, self.body_spinner, self.hand_spinner, self.legs_spinner, self.feet_spinner }

		self.lower_horizontal_line = self.outline:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
    	self.lower_horizontal_line:SetScale(.19, .4)
    	self.lower_horizontal_line:SetPosition(10, body_offset-4*option_height, 0)

		self.default_focus = self.body_spinner.spinner
		self.focus_forward = self.body_spinner.spinner
	end

	self:DoFocusHookups()

end)

function DressupPanel:ReverseFocus()
	if self.legs_spinner then
		self.default_focus = self.feet_spinner.spinner
		self.focus_forward = self.feet_spinner.spinner
	end
end
-- This function removes the background and moves the puppet out to the side. This is only done when the game is online
-- because the offline images don't work without the background.
function DressupPanel:SeparateAvatar()
	if TheNet:IsOnlineMode() then

		self.bg_group:Hide()
		self.outline:Hide()

		local body_offset = 35
		local option_height = 55
		local spinner_offset = 7
		local new_tag_offset = 66
		local new_tag_x_offset = -70
		local new_tag_scale = .25
		local arrow_scale = .25
		self.base_spinner:SetPosition(0, body_offset + spinner_offset)
		self.base_spinner.spinner:SetArrowScale(arrow_scale)
		self.base_spinner.spinner.background:ScaleToSize(220, option_height + 3)
		self.base_spinner.spinner.background:SetPosition(0, -.5)
		self.base_spinner.new_tag:SetScale(new_tag_scale)
		self.base_spinner.new_tag:SetPosition(new_tag_x_offset, new_tag_offset)

		self.body_spinner:SetPosition(0, body_offset-option_height + spinner_offset)
		self.body_spinner.spinner:SetArrowScale(arrow_scale)
		self.body_spinner.spinner.background:ScaleToSize(220, option_height + 3)
		self.body_spinner.spinner.background:SetPosition(0, -.5)
		self.body_spinner.new_tag:SetScale(new_tag_scale)
		self.body_spinner.new_tag:SetPosition(new_tag_x_offset, new_tag_offset)

		self.hand_spinner:SetPosition(0, body_offset-2*option_height + spinner_offset)
		self.hand_spinner.spinner:SetArrowScale(arrow_scale)
		self.hand_spinner.spinner.background:ScaleToSize(220, option_height + 3)
		self.hand_spinner.spinner.background:SetPosition(0, -.5)
		self.hand_spinner.new_tag:SetScale(new_tag_scale)
		self.hand_spinner.new_tag:SetPosition(new_tag_x_offset, new_tag_offset)

		self.legs_spinner:SetPosition(0, body_offset-3*option_height + spinner_offset)
		self.legs_spinner.spinner:SetArrowScale(arrow_scale)
		self.legs_spinner.spinner.background:ScaleToSize(220, option_height + 3)
		self.legs_spinner.spinner.background:SetPosition(0, -.5)
		self.legs_spinner.new_tag:SetScale(new_tag_scale)
		self.legs_spinner.new_tag:SetPosition(new_tag_x_offset, new_tag_offset)

		self.feet_spinner:SetPosition(0, body_offset-4*option_height + spinner_offset)
		self.feet_spinner.spinner:SetArrowScale(arrow_scale)
		self.feet_spinner.spinner.background:ScaleToSize(220, option_height + 3)
		self.feet_spinner.spinner.background:SetPosition(0, -.5)
		self.feet_spinner.new_tag:SetScale(new_tag_scale)
		self.feet_spinner.new_tag:SetPosition(new_tag_x_offset, new_tag_offset)

		self.base_spinner:EnableGlow()
		self.body_spinner:EnableGlow()
		self.hand_spinner:EnableGlow()
		self.legs_spinner:EnableGlow()
		self.feet_spinner:EnableGlow()

		self.underlines = self.root:AddChild(Widget("underlines"))
		self.underlines:SetPosition(0, .5*body_offset+5)

		self.mid_horizontal_line0 = self.underlines:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	    self.mid_horizontal_line0:SetScale(.15, .25)
	    self.mid_horizontal_line0:SetPosition(10, body_offset+option_height, 0)

		self.mid_horizontal_line1 = self.underlines:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	    self.mid_horizontal_line1:SetScale(.15, .25)
	    self.mid_horizontal_line1:SetPosition(10, body_offset, 0)

	    self.mid_horizontal_line2 = self.underlines:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	    self.mid_horizontal_line2:SetScale(.15, .25)
	    self.mid_horizontal_line2:SetPosition(10, body_offset-option_height, 0)

	    self.mid_horizontal_line3 = self.underlines:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	    self.mid_horizontal_line3:SetScale(.15, .25)
	    self.mid_horizontal_line3:SetPosition(10, body_offset-2*option_height, 0)

	    self.mid_horizontal_line4 = self.underlines:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	    self.mid_horizontal_line4:SetScale(.15, .25)
	    self.mid_horizontal_line4:SetPosition(10, body_offset-3*option_height, 0)

	    self.mid_horizontal_line5 = self.underlines:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	    self.mid_horizontal_line5:SetScale(.15, .25)
	    self.mid_horizontal_line5:SetPosition(10, body_offset-4*option_height, 0)

	    self.spinners:SetScale(1.5)
	    self.spinners:SetPosition(0, -15)

	    self.underlines:SetScale(1.5)
	else
		local title_height = 190

		self.bg_group:SetPosition(8, -35, 0)

		self.puppet_group = self.root:AddChild(Widget("puppet"))

		self.puppet = self.puppet_group:AddChild(Puppet())
		self.puppet:SetPosition( 10, title_height - 70)
		self.puppet:SetScale(1.75)

		self.shadow = self.puppet_group:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
	    self.shadow:SetPosition(8, title_height - 75)
	    self.shadow:SetScale(.3)

	    self.random_avatar = self.puppet_group:AddChild(Image("images/lobbyscreen.xml", "randomskin.tex"))
		self.random_avatar:SetPosition(10, title_height )
		self.random_avatar:SetScale(.34)
		self.random_avatar:Hide()
	end

	self.puppet_group:SetPosition(-330, -450)
	self.puppet_group:SetScale(2)
end


function DressupPanel:MakeSpinner(slot)

	local spinner_group = Widget("spinner group")

	local textures = {
		arrow_left_normal = "arrow2_left.tex",
		arrow_left_over = "arrow2_left_over.tex",
		arrow_left_disabled = "arrow_left_disabled.tex",
		arrow_left_down = "arrow2_left_down.tex",
		arrow_right_normal = "arrow2_right.tex",
		arrow_right_over = "arrow2_right_over.tex",
		arrow_right_disabled = "arrow_right_disabled.tex",
		arrow_right_down = "arrow2_right_down.tex",
		bg_middle = "blank.tex",
		bg_middle_focus = "spinner_focus.tex", --"box_2.tex",
		bg_middle_changing = "blank.tex",
		bg_end = "blank.tex",
		bg_end_focus = "blank.tex",
		bg_end_changing = "blank.tex",
	}


	local spinner_width = 226
	local spinner_height = 86

	--local bg = spinner_group:AddChild(Image("images/lobbyscreen.xml", "playerlobby_whitebg_chat.tex"))
	--bg:SetSize(52, 52)
	--bg:SetPosition(-39, 42, 0)

	--[[spinner_group.shadow = spinner_group:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
    spinner_group.shadow:SetPosition(10, 21)

    if slot == "base" then
    	spinner_group.shadow:SetScale(.15)
    else
    	spinner_group.shadow:SetScale(.25)
    end]]

    spinner_group.new_tag = spinner_group:AddChild(Image("images/ui.xml", "new_label.tex"))
    spinner_group.new_tag:SetScale(.4)
    spinner_group.new_tag:SetPosition(-70, spinner_height - 12)

    spinner_group.new_tag:Hide()

	spinner_group.slot = slot

	spinner_group.glow = spinner_group:AddChild(Image("images/lobbyscreen.xml", "glow.tex"))
	spinner_group.glow:SetScale(.4)
	spinner_group.glow:SetPosition(-40, 46)
	spinner_group.glow:SetClickable(false)
	spinner_group.glow:Hide()

	local t_w = 150
	local t_h = 80
	spinner_group.spinner = spinner_group:AddChild(AnimSpinner( self:GetSkinOptionsForSlot(slot), spinner_width, nil, {font=NEWFONT_OUTLINE, size=20}, nil, nil, textures, true, t_w, t_h ))
	spinner_group.spinner:SetAnim("frames_comp", "frames_comp", "idle_on", "SWAP_ICON", true)
	spinner_group.spinner.fganim:GetAnimState():Hide("frame")
	spinner_group.spinner.fganim:GetAnimState():Hide("NEW")
	spinner_group.spinner:SetTextColour(0,0,0,1)
	spinner_group.spinner:SetPosition(10, 46, 0)
	spinner_group.spinner.text:SetHAlign(ANCHOR_LEFT)
    spinner_group.spinner.text:SetVAlign(ANCHOR_MIDDLE)
    spinner_group.spinner.text:EnableWordWrap( true )
	spinner_group.spinner.text:SetPosition(30, 1)
	spinner_group.spinner.fganim:SetScale(.55)
	spinner_group.spinner.fganim:SetPosition(-52, 1)
	spinner_group.spinner.background:ScaleToSize(spinner_width - 2, spinner_height - 6)
	spinner_group.spinner.background:SetPosition(0, 1)

	spinner_group.EnableGlow = function()
		spinner_group.glow:Show()
		spinner_group.glow:SetTint(1, 1, 1, .5)
		spinner_group.glow:SetClickable(false)
	end

	if slot == "base" then
		spinner_group.GetItem =
			function()
				local which = spinner_group.spinner:GetSelectedIndex()
				local skin_options = self:GetSkinOptionsForSlot(slot)
				if which <= #skin_options then
					local item = skin_options[which].item
					--if item == nil then print("######$$$$$$ ERROR NO ITEM") dumptable( skin_options ) end
					return item, skin_options[which].build == "random_skin"
				else
					-- This can happen if the random skin option is chosen for the random character,
					-- but the actual character who is selected only has the default base skin available.
					return "", false
				end
			end


		spinner_group.spinner:SetOnChangedFn(function()
												if self.currentcharacter ~= "random" then
													local skin_options = self:GetSkinOptionsForSlot(slot)
													local which = spinner_group.spinner:GetSelectedIndex()
													if skin_options[which].new_indicator or testNewTag then
														spinner_group.new_tag:Show()
														--print("Showing new tag", spinner_group.GetItem())
													else
														spinner_group.new_tag:Hide()
														--print("Hiding new_tag", spinner_group.GetItem())
													end
													self:SetPuppetSkins()

													if self.onChanged then
														self.onChanged()
													end

													self:SetDefaultSkinsForBase()
												else
													spinner_group.new_tag:Hide() --none of the random options can be "new"
												end
										end)

	else
		spinner_group.GetItem =
			function()
				local which = spinner_group.spinner:GetSelectedIndex()
				local skin_options = self:GetSkinOptionsForSlot(slot)
				if which <= #skin_options then
					local item = skin_options[which].item
					--if item == nil then print("######$$$$$$ ERROR NO ITEM") dumptable( skin_options ) end
					return item, skin_options[which].build == "random_skin"
				else
					-- This can happen if the random skin option is chosen for the random character,
					-- but the actual character who is selected only has the default skin available.
					return "", false
				end
			end
		spinner_group.spinner:SetOnChangedFn(function()
							if self.currentcharacter ~= "random" then
								local which = spinner_group.spinner:GetSelectedIndex()
								local skin_options = self:GetSkinOptionsForSlot(slot)
								if skin_options[which].new_indicator or testNewTag then
								  	spinner_group.new_tag:Show()
								  	--print("Showing new tag", spinner_group.GetItem())
								else
								  	spinner_group.new_tag:Hide()
								  	--print("Hiding new_tag", spinner_group.GetItem())
								end
								self:SetPuppetSkins()
							else
								spinner_group.new_tag:Hide() --none of the random options can be "new"
							end
						end)
	end

	spinner_group.GetIndexForSkin = function(this, skin_name)

		local slot = this.slot
		--print("looking for ", skin, "for ", slot)
		local skin_options = self:GetSkinOptionsForSlot(slot)

		for i=1, #skin_options do
			if skin_options[i].item == skin_name then
				return i
			end
		end

		return 1
	end

	spinner_group.new_tag:MoveToFront()

	spinner_group.focus_forward = spinner_group.spinner
	return spinner_group

end



function DressupPanel:GetSkinOptionsForSlot(slot)

	local skin_options = {}

	local dressup_timestamp = self.profile:GetCollectionTimestamp()

	local function IsInList(list, item)
		for k,v in pairs(list) do
			if v.item == item then
				return k
			end
		end

		return nil
	end


	local default_build = nil
	if slot == "body" then
		default_build = "body_default1"
	elseif slot == "hand" then
		default_build = "hand_default1"
	elseif slot == "legs" then
		default_build = "legs_default1"
	elseif slot == "feet" then
		default_build = "feet_default1"
	else
		default_build = self.currentcharacter  --fallback for scarecrow, for skins we'd just want to do GetBuildForItem(self.currentcharacter.."_none") but scarecrow is a bit of a legacy hack.
	end

	local colour = DEFAULT_SKIN_COLOR
	table.insert(skin_options,
	{
		text = GetSkinName("none"),
		data = nil,
		build = default_build,
		item = "",
		symbol = "SWAP_ICON",
		colour = colour,
		new_indicator = false,
	})

	local skin_options_items = {}
	for which = 1, #self.skins_list do
		if self.skins_list[which].type == slot then
			local skin_data = GetSkinData(self.skins_list[which].item)
			if slot == "base" and ((skin_data.base_prefab ~= self.currentcharacter) or (IsDefaultCharacterSkin(self.skins_list[which].item)) ) then
				--print( "skipping ", self.skins_list[which].item  )
			else
				local item = self.skins_list[which].item
				local new_indicator = not self.skins_list[which].timestamp or (self.skins_list[which].timestamp > dressup_timestamp)
				local colour = GetColorForItem(item)
				local text_name = GetSkinName(self.skins_list[which].item)
				local key = IsInList(skin_options_items, item)

				if new_indicator and key then
					skin_options_items[key].new_indicator = true

				elseif new_indicator or not key then
					table.insert(skin_options_items,
					{
						text = text_name,
						data = nil,
						build = GetBuildForItem(item),
						item = item,
						symbol = "SWAP_ICON",
						colour = colour,
						new_indicator = new_indicator,
					})
				end
			end
		end
	end
	table.sort( skin_options_items, function (a,b) return a.text < b.text end )
	for _,v in pairs( skin_options_items ) do
		table.insert( skin_options, v )
	end

	if self.include_random_options and (#skin_options > 1) then
		table.insert(skin_options,
				{
					text = STRINGS.UI.LOBBYSCREEN.SKINS_RANDOM,
					data = nil,
					build = "random_skin",
					symbol = "SWAP_ICON",
					colour = DEFAULT_SKIN_COLOR,
					new_indicator = false,
				})
	end

	return skin_options
end

function DressupPanel:SetDefaultSkinsForBase()
	local _, random_base = self.base_spinner.GetItem()

	if random_base then
		self.body_spinner.spinner:SetSelectedIndex(1)
		self.hand_spinner.spinner:SetSelectedIndex(1)
		self.legs_spinner.spinner:SetSelectedIndex(1)
		self.feet_spinner.spinner:SetSelectedIndex(1)
	else
		local skins = self.profile:GetSkinsForCharacter(self.currentcharacter)

		self.body_spinner.spinner:SetSelectedIndex(self.body_spinner:GetIndexForSkin(skins.body))
		self.hand_spinner.spinner:SetSelectedIndex(self.hand_spinner:GetIndexForSkin(skins.hand))
		self.legs_spinner.spinner:SetSelectedIndex(self.legs_spinner:GetIndexForSkin(skins.legs))
		self.feet_spinner.spinner:SetSelectedIndex(self.feet_spinner:GetIndexForSkin(skins.feet))
	end

	if self.puppet then
		self:UpdatePuppet()
	end
end

function DressupPanel:UpdateSpinners()
	if self.currentcharacter == "random" then
		--self:DisableSpinners()

		if self.base_spinner then
			self.base_spinner.spinner:SetOptions(self:GetSkinOptionsForRandom())
			self.base_spinner.spinner:SetSelectedIndex(1)
		end

		if self.body_spinner then
			self.body_spinner.spinner:SetOptions(self:GetSkinOptionsForRandom())
			self.body_spinner.spinner:SetSelectedIndex(1)
		end

		if self.hand_spinner then
			self.hand_spinner.spinner:SetOptions(self:GetSkinOptionsForRandom())
			self.hand_spinner.spinner:SetSelectedIndex(1)
		end

		if self.legs_spinner then
			self.legs_spinner.spinner:SetOptions(self:GetSkinOptionsForRandom())
			self.legs_spinner.spinner:SetSelectedIndex(1)
		end

		if self.feet_spinner then
			self.feet_spinner.spinner:SetOptions(self:GetSkinOptionsForRandom())
			self.feet_spinner.spinner:SetSelectedIndex(1)
		end

		if self.owner_screen.SetPortraitImage then
			self.owner_screen:SetPortraitImage(0)
		end
		return
	else
		self:EnableSpinners()
	end

	self:Reset(true)

end


function DressupPanel:DoFocusHookups()

	if self.base_spinner and self.body_spinner then
        self.base_spinner:SetFocusChangeDir(MOVE_DOWN, self.body_spinner)
        self.body_spinner:SetFocusChangeDir(MOVE_UP, self.base_spinner)
    end

    if self.body_spinner and self.hand_spinner then
        self.body_spinner:SetFocusChangeDir(MOVE_DOWN, self.hand_spinner)
        self.hand_spinner:SetFocusChangeDir(MOVE_UP, self.body_spinner)
    end

    if self.hand_spinner and self.legs_spinner then
        self.hand_spinner:SetFocusChangeDir(MOVE_DOWN, self.legs_spinner)
        self.legs_spinner:SetFocusChangeDir(MOVE_UP, self.hand_spinner)
    end

    if self.legs_spinner and self.feet_spinner then
    	self.legs_spinner:SetFocusChangeDir(MOVE_DOWN, self.feet_spinner)
    	self.feet_spinner:SetFocusChangeDir(MOVE_UP, self.legs_spinner)
    end

end

function DressupPanel:Reset(set_spinner_to_new_item)
	local savedSkinsForCharacter = self.profile:GetSkinsForCharacter(self.currentcharacter)

	local recent_item_type = self.recent_item_types and GetTypeForItem(self.recent_item_types[1]) or nil

	--[[print("Updating spinners with ", self.currentcharacter)
	for k,v in pairs(savedSkinsForCharacter) do
		print(k, v)
	end]]

	if self.base_spinner then
		self.base_spinner.spinner:SetOptions(self:GetSkinOptionsForSlot("base"))

		if set_spinner_to_new_item and recent_item_type and recent_item_type == "base" then
			self.base_spinner.spinner:SetSelectedIndex(self.base_spinner:GetIndexForSkin(self.recent_item_types[1]))
		elseif self.playerdata then
			self.base_spinner.spinner:SetSelectedIndex(self.base_spinner:GetIndexForSkin(self.playerdata.base_skin or self.currentcharacter))
		elseif savedSkinsForCharacter.base and savedSkinsForCharacter.base ~= "" then
            self.base_spinner.spinner:SetSelectedIndex(self.base_spinner:GetIndexForSkin(savedSkinsForCharacter.base))
		else
			self.base_spinner.spinner:SetSelectedIndex(1)
		end
	end

	if self.body_spinner then
		self.body_spinner.spinner:SetOptions(self:GetSkinOptionsForSlot("body"))

		if set_spinner_to_new_item and recent_item_type and recent_item_type == "body" then
			self.body_spinner.spinner:SetSelectedIndex(self.body_spinner:GetIndexForSkin(self.recent_item_types[1]))
		elseif self.playerdata then
			self.body_spinner.spinner:SetSelectedIndex(self.body_spinner:GetIndexForSkin(self.playerdata.body_skin or "body_default1"))
		elseif savedSkinsForCharacter.body and savedSkinsForCharacter.body ~= "" then
			self.body_spinner.spinner:SetSelectedIndex(self.body_spinner:GetIndexForSkin(savedSkinsForCharacter.body))
		else
			self.body_spinner.spinner:SetSelectedIndex(1)
		end
	end

	if self.hand_spinner then
		self.hand_spinner.spinner:SetOptions(self:GetSkinOptionsForSlot("hand"))

		if set_spinner_to_new_item and recent_item_type and recent_item_type == "hand" then
			self.hand_spinner.spinner:SetSelectedIndex(self.hand_spinner:GetIndexForSkin(self.recent_item_types[1]))
		elseif self.playerdata then
			self.hand_spinner.spinner:SetSelectedIndex(self.hand_spinner:GetIndexForSkin(self.playerdata.hand_skin or "hand_default1"))
		elseif  savedSkinsForCharacter.hand and savedSkinsForCharacter.hand ~= "" then
			self.hand_spinner.spinner:SetSelectedIndex(self.hand_spinner:GetIndexForSkin(savedSkinsForCharacter.hand))
		else
			self.hand_spinner.spinner:SetSelectedIndex(1)
		end
	end

	if self.legs_spinner then
		self.legs_spinner.spinner:SetOptions(self:GetSkinOptionsForSlot("legs"))

		if set_spinner_to_new_item and recent_item_type and recent_item_type == "legs" then
			self.legs_spinner.spinner:SetSelectedIndex(self.legs_spinner:GetIndexForSkin(self.recent_item_types[1]))
		elseif self.playerdata then
			self.legs_spinner.spinner:SetSelectedIndex(self.legs_spinner:GetIndexForSkin(self.playerdata.legs_skin or "legs_default1"))
		elseif savedSkinsForCharacter.legs and savedSkinsForCharacter.legs ~= "" then
			self.legs_spinner.spinner:SetSelectedIndex(self.legs_spinner:GetIndexForSkin(savedSkinsForCharacter.legs))
		else
			self.legs_spinner.spinner:SetSelectedIndex(1)
		end
	end

	if self.feet_spinner then
		self.feet_spinner.spinner:SetOptions(self:GetSkinOptionsForSlot("feet"))

		if set_spinner_to_new_item and recent_item_type and recent_item_type == "feet" then
			self.feet_spinner.spinner:SetSelectedIndex(self.feet_spinner:GetIndexForSkin(self.recent_item_types[1]))
		elseif self.playerdata then
			self.feet_spinner.spinner:SetSelectedIndex(self.feet_spinner:GetIndexForSkin(self.playerdata.feet_skin or "feet_default1"))
		elseif savedSkinsForCharacter.feet and savedSkinsForCharacter.feet ~= "" then
			self.feet_spinner.spinner:SetSelectedIndex(self.feet_spinner:GetIndexForSkin(savedSkinsForCharacter.feet))
		else
			self.feet_spinner.spinner:SetSelectedIndex(1)
		end
	end

	if self.puppet then
		self:UpdatePuppet(true)
	end

end

-- This is the full skins list, which is used to populate the spinners
-- (Duplicates are removed.)
function DressupPanel:GetSkinsList()
	--print("Getting skins list (full inventory)")

	local templist = TheInventory:GetFullInventory()
	self.skins_list = {}
	self.timestamp = 0

	for k,v in ipairs(templist) do
		local type, item = GetTypeForItem(v.item_type)
		self.skins_list[k] = {}
		self.skins_list[k].type = type
		self.skins_list[k].item = item
		self.skins_list[k].timestamp = v.modified_time
		--self.skins_list[k].item_id = v.item_id

		if v.modified_time > self.timestamp then
			self.timestamp = v.modified_time
		end
	end
end

-- These lists don't have duplicates, and are used for the random option
function DressupPanel:GetClothingOptions()
	self.clothing_options = {}
	self.clothing_options["body"] = self.profile:GetClothingOptionsForType("body")
	self.clothing_options["hand"] = self.profile:GetClothingOptionsForType("hand")
	self.clothing_options["legs"] = self.profile:GetClothingOptionsForType("legs")
	self.clothing_options["feet"] = self.profile:GetClothingOptionsForType("feet")
	--print("Got clothing options", #self.clothing_options["body"], #self.clothing_options["hand"], #self.clothing_options["legs"])
end

function DressupPanel:GetSkinOptionsForRandom()

	local skin_options = {}

	table.insert(skin_options,
			{
				text = STRINGS.UI.LOBBYSCREEN.SKINS_PREVIOUS,
				data = nil,
				build = "previous_skin",
				symbol = "SWAP_ICON",
				colour = DEFAULT_SKIN_COLOR,
				new_indicator = false,
			})

	table.insert(skin_options,
			{
				text = STRINGS.UI.LOBBYSCREEN.SKINS_RANDOM,
				data = nil,
				build = "random_skin",
				symbol = "SWAP_ICON",
				colour = DEFAULT_SKIN_COLOR,
				new_indicator = false,
			})

	return skin_options

end

function DressupPanel:GetBaseSkin()
	return (self.base_spinner and self.base_spinner.GetItem()) or nil
end

function DressupPanel:GetSkinsForGameStart()
	local skins = { base = self.currentcharacter.."_none", body = "", hand = "", legs = "", feet = "" } --default skins values

	local currentcharacter_skins = self.profile:GetSkinsForPrefab(self.currentcharacter)

	if self.currentcharacter == "random" then
		local all_chars = ExceptionArrays(GetActiveCharacterList(), MODCHARACTEREXCEPTIONS_DST)
		self.currentcharacter = all_chars[math.random(#all_chars)]
		currentcharacter_skins = self.profile:GetSkinsForPrefab(self.currentcharacter)
		if self.dressup_frame then
			local previous_skins = self.profile:GetSkinsForCharacter(self.currentcharacter)

			if self.base_spinner and self.base_spinner.spinner:GetSelectedIndex() == 1 then
				skins.base = previous_skins.base
			else
				skins.base = GetRandomItem(currentcharacter_skins)
			end

			if self.body_spinner and self.body_spinner.spinner:GetSelectedIndex() == 1 then
				skins.body = previous_skins.body
			else
				skins.body = GetRandomItem(self.clothing_options["body"])
			end

			if self.hand_spinner and self.hand_spinner.spinner:GetSelectedIndex() == 1 then
				skins.hand = previous_skins.hand
			else
				skins.hand = GetRandomItem(self.clothing_options["hand"])
			end

			if self.legs_spinner and self.legs_spinner.spinner:GetSelectedIndex() == 1 then
				skins.legs = previous_skins.legs
			else
				skins.legs = GetRandomItem(self.clothing_options["legs"])
			end

			if self.feet_spinner and self.feet_spinner.spinner:GetSelectedIndex() == 1 then
				skins.feet = previous_skins.feet
			else
				skins.feet = GetRandomItem(self.clothing_options["feet"])
			end
		else
			--offline and random
			skins.base = self.currentcharacter.."_none"
		end
	else
		if self.dressup_frame then
			local base, random_base, body, random_body, hand, random_hand, legs, random_legs, feet, random_feet
			base, random_base = self.base_spinner.GetItem()
			body, random_body = self.body_spinner.GetItem()
			hand, random_hand = self.hand_spinner.GetItem()
			legs, random_legs = self.legs_spinner.GetItem()
			feet, random_feet = self.feet_spinner.GetItem()


			if random_base then
				base = GetRandomItem(currentcharacter_skins)
			end

			if random_body then
				body = GetRandomItem(self.clothing_options["body"])
			end

			if random_hand then
				hand = GetRandomItem(self.clothing_options["hand"])
			end

			if random_legs then
				legs = GetRandomItem(self.clothing_options["legs"])
			end

			if random_feet then
				feet = GetRandomItem(self.clothing_options["feet"])
			end

			skins =
			{
				base = base,
				body = body,
				hand = hand,
				legs = legs,
				feet = feet
			}

			--cleanup spinner items
			if not skins.base or skins.base == self.currentcharacter or skins.base == "" then skins.base = (self.currentcharacter.."_none") end
			if not IsValidClothing( skins.body ) then skins.body = "" end
			if not IsValidClothing( skins.hand ) then skins.hand = "" end
			if not IsValidClothing( skins.legs ) then skins.legs = "" end
			if not IsValidClothing( skins.feet ) then skins.feet = "" end

			self.profile:SetSkinsForCharacter(self.currentcharacter, skins)
		else
			--offline here, leave skins as default
			if TheNet:IsOnlineMode() then
				print( "Error: Game is online but the dressup panel hasn't been created." )
			end
		end
	end

	return skins
end

function DressupPanel:SetPuppetSkins(skip_change_emote)
	if self.currentcharacter == "random" then
		return -- no puppet in this case
	elseif not TheNet:IsOnlineMode() then
		-- no spinners in this case
		self.puppet:SetSkins(self.currentcharacter, nil, {}, skip_change_emote) --base_skin is nil and clothing_names is {}
		return
	end

	local base_skin_build = nil
	local skin_item_name = self.base_spinner.GetItem()
	local skin_data = GetSkinData(skin_item_name)
	if skin_data.skins then
		base_skin_build = skin_data.skins.normal_skin
	else
		base_skin_build = self.currentcharacter --fallback for scarecrow
	end

	local clothing_names = {}

	--print("Body item is ", self.body_spinner.GetItem())
	--print("Gloves item is ", self.gloves_spinner.GetItem())
	--print("Legs item is ", self.legs_spinner.GetItem())

	if self.body_spinner.GetItem() ~= "" then
		clothing_names["body"] = self.body_spinner.GetItem()
	end
	if self.hand_spinner.GetItem() ~= "" then
		clothing_names["hand"] = self.hand_spinner.GetItem()
	end
	if self.legs_spinner.GetItem() ~= "" then
		clothing_names["legs"] = self.legs_spinner.GetItem()
	end
	if self.feet_spinner.GetItem() ~= "" then
		clothing_names["feet"] = self.feet_spinner.GetItem()
	end

	self.puppet:SetSkins(self.currentcharacter, base_skin_build, clothing_names, skip_change_emote)
end

function DressupPanel:SetCurrentCharacter(character)

	self.currentcharacter = character

	-- Note: these must be done in this order or the spinners and the puppet will be
	-- out of sync.
	if self.dressup_frame then
		self:UpdateSpinners()
		self:UpdatePuppet(true)
	end
end

function DressupPanel:UpdatePuppet(skip_change_emote)
	if self.puppet then
		if self.currentcharacter == "random" then
			self.puppet:Hide()
			self.random_avatar:Show()
			self.shadow:Hide()
		else
			self.puppet:Show()
			self.puppet:SetCharacter(self.currentcharacter)
			self:SetPuppetSkins(skip_change_emote)
			self.random_avatar:Hide()
			self.shadow:Show()
		end
	end
end


function DressupPanel:EnableSpinners()

	if self.dressup_frame then
		if self.base_spinner then
			self.base_spinner:Show()
		end

		if self.body_spinner then
			self.body_spinner:Show()
		end

		if self.hand_spinner then
			self.hand_spinner:Show()
		end

		if self.legs_spinner then
			self.legs_spinner:Show()
		end

		if self.feet_spinner then
			self.feet_spinner:Show()
		end

		self.dressup_frame:Show()
	end
end


function DressupPanel:DisableSpinners()
	if self.dressup_frame then
		if self.base_spinner then
			self.base_spinner:Hide()
		end

		if self.body_spinner then
			self.body_spinner:Hide()
		end

		if self.hand_spinner then
			self.hand_spinner:Hide()
		end

		if self.legs_spinner then
			self.legs_spinner:Hide()
		end

		if self.feet_spinner then
			self.feet_spinner:Hide()
		end

		self.dressup_frame:Hide()
	end
end

function DressupPanel:AllSpinnersToEnd()
	if self.dressup_frame then
		if self.base_spinner then
			self.base_spinner.spinner:GoToEnd()
		end

		if self.body_spinner then
			self.body_spinner.spinner:GoToEnd()
		end

		if self.hand_spinner then
			self.hand_spinner.spinner:GoToEnd()
		end

		if self.legs_spinner then
			self.legs_spinner.spinner:GoToEnd()
		end

		if self.feet_spinner then
			self.feet_spinner.spinner:GoToEnd()
		end
	end
end

function DressupPanel:OnClose()
	--print("Setting dressup timestamp from dressuppanel:OnClose", self.timestamp)
	self.profile:SetCollectionTimestamp(self.timestamp)
end


function DressupPanel:OnUpdate(dt)
	if self.repeat_time > -.01 then
        self.repeat_time = self.repeat_time - dt
    end
end

--NOTE(Peter): Do we even need to do this repeat logic if it's already done at the control level in frontend.lua?
local SCROLL_REPEAT_TIME = .15
local MOUSE_SCROLL_REPEAT_TIME = 0
local STICK_SCROLL_REPEAT_TIME = .25

function DressupPanel:ScrollBack(control)
	if self.all_spinners ~= nil then
		if not self.repeat_time or self.repeat_time <= 0 then
       		for _,spinner in pairs( self.all_spinners ) do
       			if spinner.focus then
       				local prev_index = spinner.spinner.selectedIndex

       				spinner.spinner.leftimage:onclick()

       				if spinner.spinner.selectedIndex ~= prev_index then
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
					end
       			end
       		end

			self.repeat_time =
				TheInput:GetControlIsMouseWheel(control)
				and MOUSE_SCROLL_REPEAT_TIME
				or (control == CONTROL_SCROLLBACK and SCROLL_REPEAT_TIME)
				or (control == CONTROL_PREVVALUE and STICK_SCROLL_REPEAT_TIME)
		end
	end
end

function DressupPanel:ScrollFwd(control)
	if self.all_spinners ~= nil then
		if not self.repeat_time or self.repeat_time <= 0 then
			for _,spinner in pairs( self.all_spinners ) do
       			if spinner.focus then
					local prev_index = spinner.spinner.selectedIndex

       				spinner.spinner.rightimage:onclick()

       				if spinner.spinner.selectedIndex ~= prev_index then
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
					end
       			end
       		end

			self.repeat_time =
				TheInput:GetControlIsMouseWheel(control)
				and MOUSE_SCROLL_REPEAT_TIME
				or (control == CONTROL_SCROLLFWD and SCROLL_REPEAT_TIME)
				or (control == CONTROL_NEXTVALUE and STICK_SCROLL_REPEAT_TIME)
		end
	end
end

return DressupPanel