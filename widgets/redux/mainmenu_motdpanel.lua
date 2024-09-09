local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local easing = require "easing"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local RadioButtons = require "widgets/radiobuttons"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Stats = require("stats")

local BOX_FONT = FALLBACK_FONT -- CHATFONT, FALLBACK_FONT, CHATFONT_OUTLINE

local ICON_MAP =
{
	kleistore = { atlas = "images/frontend_redux.xml", image = "kleishop.tex", x_offset = 0, y_offset = 1, scale = 0.32},
}

local alert_images =
{
	error = {image = "motd_alert.tex", colour = WEBCOLOURS.SALMON},
	warning = {image = "motd_alert.tex", colour = UICOLOURS.HIGHLIGHT_GOLD},
	notice = {image = "goto_url.tex", colour = UICOLOURS.HIGHLIGHT_GOLD},
}

local function GetAlertInfo(level)
	return alert_images[level] ~= nil and alert_images[level] or alert_images.notice
end

local MotdPanel = Class(Widget, function(self, config)
	Widget._ctor(self, "MotdPanel")

	self.bullets = {}
	self.selected_bullet_num = 1

	self.config = config or {}

	self.root = self:AddChild(Widget("root"))

	self:SetPosition(config.x or 0, config.y or 0)

	if TheFrontEnd.MotdManager:IsLoadingMotdInfo() then
		self:ShowMOTDSyncingIndicator()
		TheFrontEnd.MotdManager:AddOnMotdDownloadedCB(self.inst, function(success) self:OnMotdLoaded() end)
	else
		self:OnMotdLoaded()
	end
end)

function MotdPanel:ShowMOTDSyncingIndicator()
	if self.sync_indicator ~= nil then
		return
	end

	self.sync_indicator = self.root:AddChild(TEMPLATES.RectangleWindow(240, 180))
	self.sync_indicator:SetBackgroundTint(0,0,0,0.85)
    self.sync_indicator:SetPosition(30, 0)

	local text = self.sync_indicator:AddChild(Text(self.config.font, 26, STRINGS.UI.MAINSCREEN.MOTD_SYNCING, UICOLOURS.GOLD_UNIMPORTANT))
    text:SetPosition(0, -20)


	local image = self.sync_indicator:AddChild(Image("images/avatars.xml", "loading_indicator.tex"))
	image:SetTint(unpack(UICOLOURS.GOLD_UNIMPORTANT))
    image:SetPosition(0, 20)
	local function dorotate() image:RotateTo(0, -360, .75, dorotate) end
	dorotate()
end

function MotdPanel:ShowMOTDSyncingFailed()
	if self.error_indicator ~= nil then
		return
	end

	self.error_indicator = self.root:AddChild(TEMPLATES.RectangleWindow(240, 60))
	self.error_indicator:SetBackgroundTint(0,0,0,0.85)
    self.error_indicator:SetPosition(30, -100)

	local text = self.error_indicator:AddChild(Text(self.config.font, 20, STRINGS.UI.MAINSCREEN.MOTD_SYNCING_FAILED, UICOLOURS.GOLD_UNIMPORTANT))
    --text:SetPosition(0, -20)
	end

function MakeDownloadingImageIndicator()
	local sync_indicator = Widget("sync_indicator")

	local text = sync_indicator:AddChild(Text(BODYTEXTFONT, 18, STRINGS.UI.MAINSCREEN.MOTD_DOWNLOADING_IMAGE, UICOLOURS.GOLD_UNIMPORTANT))
    text:SetPosition(0, -22)


	local image = sync_indicator:AddChild(Image("images/avatars.xml", "loading_indicator.tex"))
	local function dorotate() image:RotateTo(0, -360, .75, dorotate) end
	dorotate()
    image:SetScale(.7)
	image:SetTint(unpack(UICOLOURS.GOLD_UNIMPORTANT))

	return sync_indicator
end

local function OnCellImageLoaded(w, cell_size)
	local t = TheFrontEnd.MotdManager:GetMotd()

	if w.cell_data.data.no_image then
		w.motd_image:SetTexture("images/motd_fallbacks_box1.xml", "box1.tex")
	else
		w.motd_image:SetTexture("images/motd_"..w.cell_data.meta.image_file..".xml", w.cell_data.meta.image_file..".tex")
	end
	w.motd_image:SetSize(cell_size.width * w.box_scale, cell_size.height * w.box_scale)
	w.motd_image:SetTint(0, 0, 0, 1)
	w.motd_image:TintTo({r=0,g=0,b=0,a=1}, {r=1,g=1,b=1,a=1}, 1)
	if w.downloading_image ~= nil then
		w.downloading_image:Kill()
		w.downloading_image = nil
	end
end

local function focusforward_fn(self)
	if self.box_1_widget ~= nil and self.box_1_widget.link_btn:IsVisible() then
		return self.box_1_widget
	elseif self.box_2_widget ~= nil and self.box_2_widget.link_btn:IsVisible() then
		return self.box_2_widget
	elseif self.box_3_widget ~= nil and self.box_3_widget.link_btn:IsVisible() then
		return self.box_3_widget
	end
	return self.config.on_no_focusforward
end

function MotdPanel:OnMotdLoaded()
	local _motd_info, _motd_sorted_keys = TheFrontEnd.MotdManager:GetMotd()
	if _motd_info == nil or _motd_sorted_keys == nil then
		Stats.PushMetricsEvent("motd2.failed", TheNet:GetUserID(), {}, "is_only_local_users_data")

		if self.sync_indicator ~= nil then
			self.sync_indicator:Kill()
			self.sync_indicator = nil
		end
		self:ShowMOTDSyncingFailed()
		return
	end

	local new_update_available = TheFrontEnd.MotdManager:IsNewUpdateAvailable()

	local main_box_motd_info = {}
	if new_update_available then
		table.insert(main_box_motd_info, TheFrontEnd.MotdManager:GetPatchNotes())
	else
		for i, id in ipairs(_motd_sorted_keys) do
			if i ~= 2 and i ~= 3 then
				table.insert(main_box_motd_info, _motd_info[id])
			end
		end
	end
	local box2_motd_info = (not new_update_available and _motd_sorted_keys[2] ~= nil) and _motd_info[ _motd_sorted_keys[2] ] or nil
	local box3_motd_info = (not new_update_available and _motd_sorted_keys[3] ~= nil) and _motd_info[ _motd_sorted_keys[3] ] or nil


	--print("_motd_info")
	--dumptable(_motd_info)

	--print("main_box_motd_info")
	--dumptable(main_box_motd_info)

	local cell_size = {width = 480, height = 480/16*9}
	local cell_spacing = 5
	local frame_padding = 13
	local link_button_offset = 20
	local button_spacing = link_button_offset * 2

    local function CellWidgetCtor(context, index, box_scale, font_scale, frame_image, frame_size)
 		local title_size = 22 * (font_scale or 1)
		local body_size = 18 * (font_scale or 1)

        local w = Widget("recipe-cell-".. index)

		w.box_scale = box_scale

		local cell_width, cell_height = cell_size.width * box_scale, cell_size.height * box_scale

		w.scissored_root = w:AddChild(Widget("scissored_root"))
		w.scissored_root:SetScissor(-cell_width/2, -cell_height/2, cell_width, cell_height)

		w.frame = w:AddChild(Image("images/bg_redux_"..frame_image..".xml", frame_image..".tex"))
		--w.frame:SetSize(cell_size.width + 20, cell_size.height + 20)
		w.frame:SetScale(box_scale * cell_size.width/frame_size)

		w.frame:SetClickable(false)

		w.cell_root = w.scissored_root:AddChild(Widget("cell_root"))
		w.cell_root:SetPosition(0, 0)

		w.motd_image = w.cell_root:AddChild(Image("images/global.xml", "square.tex"))
		w.motd_image:SetTint(0, 0, 0, 1)
		w.motd_image:SetSize(cell_width, cell_height)

		w.vignette = w.cell_root:AddChild(Image("images/bg_redux_dark_bottom_vignette1.xml", "dark_bottom_vignette1.tex"))
		w.vignette:SetSize(cell_width, cell_height)
		w.vignette:SetClickable(false)

		w.motd_title_text = w.cell_root:AddChild(Text(self.config.font, title_size, "", UICOLOURS.GOLD_CLICKABLE)) -- EGGSHELL
		w.motd_title_text.base_colour = w.motd_title_text:GetColour()
		w.motd_title_text:SetHAlign(ANCHOR_LEFT)
		w.motd_title_shadow = w.cell_root:AddChild(Text(self.config.font, title_size, "", UICOLOURS.BLACK))
		w.motd_title_shadow:SetHAlign(ANCHOR_LEFT)
		w.motd_title_shadow:MoveToBack()

		w.motd_body_text = w.cell_root:AddChild(Text(self.config.font, body_size, "", UICOLOURS.GOLD_UNIMPORTANT))
		w.motd_body_text:SetHAlign(ANCHOR_LEFT)
		w.motd_body_shadow = w.cell_root:AddChild(Text(self.config.font, body_size, "", UICOLOURS.BLACK))
		w.motd_body_shadow:SetHAlign(ANCHOR_LEFT)
		w.motd_body_shadow:MoveToBack()

		w.link_btn = w.cell_root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "goto_url.tex", nil, false, false,
			function()
				--Stats.PushMetricsEvent("motd2.clicked", TheNet:GetUserID(), motd_msg, "is_only_local_users_data")

				if w.cell_data.data.link_url == "skins" then
					self.config.on_to_skins_cb( w.cell_data.data.filter_info )
				elseif w.cell_data.data.link_url ~= nil then
					VisitURL(w.cell_data.data.link_url)
				end
			end))
		w.link_btn:SetScale(0.6)
		w.link_btn:SetPosition(cell_width / 2 - link_button_offset - frame_padding, - cell_height / 2 + link_button_offset + frame_padding)

		w.isnew_image = w.cell_root:AddChild(Image("images/ui.xml", "new_label_motd2.tex"))
		w.isnew_image:SetScale(.3)
		w.isnew_image:SetPosition(cell_width / 2 - 20, cell_height / 2 - 28)
		w.isnew_image:SetHoverText(STRINGS.UI.MAINSCREEN.MOTD_NEW_ANNOUNCEMENT)

		w.issale_image = w.cell_root:AddChild(Image("images/global_redux.xml", "motd_sale_tag.tex"))
		--w.issale_image = w.cell_root:AddChild(Image("images/global_redux.xml", "shop_discount.tex"))
		w.issale_image:SetScale(.7)
		w.issale_image:SetPosition(cell_width / 2 - 50, cell_height / 2 - 50)
		--w.issale_image:SetHoverText(STRINGS.UI.MAINSCREEN.MOTD_SALE_ANNOUNCEMENT)
		w.issale_image.text = w.issale_image:AddChild(Text(HEADERFONT, 36, STRINGS.UI.MAINSCREEN.MOTD_SALE_ANNOUNCEMENT, UICOLOURS.BLACK))
		w.issale_image.text:SetPosition(20, 20)
		w.issale_image.text:SetRotation(45)

		w.fader = w.cell_root:AddChild(Image("images/global.xml", "square.tex"))
		w.fader:SetTint(0, 0, 0, 0)
		w.fader:SetSize(cell_width, cell_height)
		w.fader:SetClickable(false)

		w.inst:ListenForEvent("motd_image_loaded", function(_, data) if w.cell_data ~= nil and data ~= nil and data.cell_id == w.cell_data.id then OnCellImageLoaded(w, cell_size) end end, TheGlobalInstance)

		w.motd_image:MoveToBack()

		w.focus_forward = w.link_btn
		w.frame.focus_forward = w.link_btn
		w.motd_image.focus_forward = w.link_btn

		----------------
		return w

    end

    local function SetCellData(context, w, cell_data, index)
		w.cell_data = cell_data
		if cell_data ~= nil then
			w.cell_root:Show()

			local cell_width, cell_height = cell_size.width * w.box_scale, cell_size.height * w.box_scale

			local title_str = new_update_available and STRINGS.UI.MAINSCREEN.MOTD_NEW_UPDATE or cell_data.data.title
			if title_str ~= nil then
				local font_size = 20
				local max_w = cell_width - frame_padding * 2
				w.motd_title_text:SetMultilineTruncatedString(title_str, 3, max_w - 20, nil, true)
				local text_width, text_height = w.motd_title_text:GetRegionSize()
				local x, y = -max_w/2 + text_width/2, cell_height / 2 - text_height/2 - frame_padding
				w.motd_title_text:SetPosition(x, y)

				w.motd_title_shadow:SetMultilineTruncatedString(title_str, 3, max_w - 20, nil, true)
				w.motd_title_shadow:SetPosition(x + 1.5, y - 1.5)
			end

			if new_update_available then
				w.motd_title_text:SetColour(alert_images.error.colour)
			else
				w.motd_title_text:SetColour(w.motd_title_text.base_colour)
			end

			local body_str = cell_data.data.text
			if body_str ~= nil and not new_update_available then
				w.motd_body_text:Show()
				w.motd_body_shadow:Show()
				local font_size = 16
				w.motd_body_text:SetMultilineTruncatedString(body_str, 3, cell_width - frame_padding * 2 - button_spacing, nil, true)
				local text_width, text_height = w.motd_body_text:GetRegionSize()
				local x, y = text_width/2 - cell_width/2 + frame_padding, -cell_height / 2 + text_height/2 + frame_padding + 3
				w.motd_body_text:SetPosition(x, y)

				w.motd_body_shadow:SetMultilineTruncatedString(body_str, 3, cell_width - frame_padding * 2 - button_spacing, nil, true)
				w.motd_body_shadow:SetPosition(x + 1.5, y - 1.5)
			else
				w.motd_body_text:Hide()
				w.motd_body_shadow:Hide()
			end

			if cell_data.data.link_url ~= nil then
				w.link_btn:Show()
			else
				w.link_btn:Hide()
				if w.link_btn.focus then
					self:SetFocus()
				end
			end

			w.issale_image:Hide()
			w.isnew_image:Hide()
			if cell_data.meta.is_sale then
				w.issale_image:Show()
			elseif cell_data.meta.is_new then
				w.isnew_image:Show()
			end

			if cell_data.meta.image_file ~= nil or cell_data.data.no_image then
				if cell_data.data.no_image then
					w.motd_image:SetTexture("images/motd_fallbacks_box1.xml", "box1.tex")
				else
					w.motd_image:SetTexture("images/motd_"..cell_data.meta.image_file..".xml", cell_data.meta.image_file..".tex")
				end
				w.motd_image:SetSize(cell_width, cell_height)
				w.motd_image:SetTint(1, 1, 1, 1)
				if w.downloading_image ~= nil then
					w.downloading_image:Kill()
					w.downloading_image = nil
				end
			elseif w.downloading_image == nil then
				w.motd_image:SetTexture("images/global.xml", "square.tex")
				w.motd_image:SetSize(cell_width, cell_height)
				w.motd_image:TintTo({r=0,g=0,b=0,a=1}, {r=0,g=0,b=0,a=1}, 0)
				w.downloading_image = w.cell_root:AddChild(MakeDownloadingImageIndicator())
			end

			w:Enable()

			if not new_update_available then
				TheFrontEnd.MotdManager:MarkAsSeen(cell_data.id)
			end
		else
			if w.downloading_image ~= nil then
				w.downloading_image:Kill()
				w.downloading_image = nil
			end
			w:Disable()
			w.cell_root:Hide()
		end
    end

	local boxes_y = 5

	local mainbox_scale = 1.0
	local mainbox_x = (box2_motd_info == nil and box3_motd_info == nil) and 50 or -90

	local smallbox_scale = 0.55
	local smallbox_font_scale = 1.0
	local smallbox_x = 370
	local smallbox_y_offset = box3_motd_info == nil and 0 or 90

	if box2_motd_info ~= nil then
		self.box_2_widget = self.root:AddChild( CellWidgetCtor(nil, "2", smallbox_scale, smallbox_font_scale, "motd_frame_small_gold", 306) )
		SetCellData(nil, self.box_2_widget, box2_motd_info)
		self.box_2_widget:SetPosition(smallbox_x, boxes_y + smallbox_y_offset)
	end

	if box3_motd_info ~= nil then
		self.box_3_widget = self.root:AddChild( CellWidgetCtor(nil, "3", smallbox_scale, smallbox_font_scale, "motd_frame_small_gold2", 306) )
		SetCellData(nil, self.box_3_widget, box3_motd_info)
		self.box_3_widget:SetPosition(smallbox_x, boxes_y - smallbox_y_offset)
	end

	if #main_box_motd_info > 0 then
		self.box_1_root = self.root:AddChild(Widget("box_1_root"))
		self.box_1_root:SetPosition(mainbox_x, boxes_y)
		self.box_1_widget = self.box_1_root:AddChild( CellWidgetCtor(nil, "1", mainbox_scale, nil, "motd_frame_large_gold", 730) )
		self.box_1_widget:SetScale(1.2)
		SetCellData(nil, self.box_1_widget, main_box_motd_info[1])
	end

	if self.box_1_root ~= nil and #main_box_motd_info > 1 then
		local bullet_size = 30
		local bullet_offset = 8
		local width = bullet_size * #main_box_motd_info + bullet_offset * (#main_box_motd_info -1)
		self.bullet_root = self.box_1_root:AddChild(Widget("bullet_root"))
		local function update_bullet_controller_pos()
			local bullet_y = TheInput:ControllerAttached() and -(cell_size.height*1.2/2) or -(cell_size.height*1.2/2 + bullet_size/2 + bullet_offset)
			self.bullet_root:SetPosition(0, bullet_y)
		end
		self.bullet_root.inst:DoPeriodicTask(1, update_bullet_controller_pos) -- why do we not have an event for this?
		update_bullet_controller_pos()

		local function bullet_clicked(w, i)
			if self.box_1_root.last_selected then
				self.box_1_root.last_selected:Unselect()
			end
			self.box_1_root.last_selected = w
			w:Select()

			SetCellData(nil, self.box_1_widget, main_box_motd_info[w.box_num])
			self.box_1_widget.fader:SetTint(0, 0, 0, 1)
			self.box_1_widget.fader:TintTo({r=0,g=0,b=0,a=1}, {r=0,g=0,b=0,a=0}, .5)

			self.selected_bullet_num = w.box_num

			if w.is_new then
				w.is_new = false
				w.image_normal = "radiobutton_filled_gold_off.tex"
			end

			if w.new_image ~= nil then
				w.new_image:Hide()
			end

			self:DoFocusHookups()
		end

		for i = 1, #main_box_motd_info do
			local is_new = main_box_motd_info[i].meta.is_new
			local bullet = self.bullet_root:AddChild(ImageButton("images/global_redux.xml", is_new and "radiobutton_filled_gold_new.tex" or "radiobutton_filled_gold_off.tex", "radiobutton_filled_gold_hover.tex", nil, "radiobutton_filled_gold_hover.tex", "radiobutton_filled_gold_on.tex", {1, 1}))
			local x = -(width / 2) + ((i-0.5) * bullet_size) + (i > 1 and (i-1)*bullet_offset or 0)
			bullet:SetPosition(x, 0)
			bullet:ForceImageSize( bullet_size, bullet_size )
			bullet.box_num = i
			bullet:SetOnClick(function() bullet_clicked(bullet) end)

			if is_new then
				bullet.is_new = true

				--[[
				bullet.new_image = bullet:AddChild(Image("images/global_redux.xml", "radiobutton_gold_glow.tex"))
				--local function dorotate() new_image:RotateTo(0, -360, 5.75, dorotate) end
				--dorotate()
				bullet.new_image:MoveToBack()
				bullet.new_image:SetScale(.6)
				bullet.new_image:SetTint(unpack(UICOLOURS.HIGHLIGHT_GOLD))
			]]
			end
			table.insert(self.bullets, bullet)
		end

		local initial_bullet = self.bullets[1]
		for i, bullet in ipairs(self.bullets) do
			if main_box_motd_info[bullet.box_num].meta.is_new then
				initial_bullet = bullet
				break
			end
		end
		bullet_clicked(initial_bullet)
	end

	self.focus_forward = function() return focusforward_fn(self) end
	self:DoFocusHookups()
end

function MotdPanel:DoFocusHookups()
	if self.box_2_widget then
		self.box_2_widget:ClearFocusDirs()
		if self.box_2_widget.link_btn:IsVisible() then
		    self.box_1_widget:SetFocusChangeDir(MOVE_RIGHT, self.box_2_widget)
		elseif self.box_3_widget.link_btn:IsVisible() then
		    self.box_1_widget:SetFocusChangeDir(MOVE_RIGHT, self.box_3_widget)
		end

			if self.box_1_widget.link_btn:IsVisible() then
				self.box_2_widget:SetFocusChangeDir(MOVE_LEFT, self.box_1_widget)
			end

		if self.box_3_widget then
			self.box_3_widget:ClearFocusDirs()
			if self.box_3_widget.link_btn:IsVisible() then
				self.box_2_widget:SetFocusChangeDir(MOVE_DOWN, self.box_3_widget)
			end

			if self.box_2_widget.link_btn:IsVisible() then
				self.box_3_widget:SetFocusChangeDir(MOVE_UP, self.box_2_widget)
			end

			if self.box_1_widget.link_btn:IsVisible() then
				self.box_3_widget:SetFocusChangeDir(MOVE_LEFT, self.box_1_widget)
			end
		end
	end
end

function MotdPanel:OnControl(control, down)
	if MotdPanel._base.OnControl(self, control, down) then return true end

	if #self.bullets > 1 and not down then
		if control == CONTROL_MENU_L2 then
			self.selected_bullet_num = self.selected_bullet_num == 1 and #self.bullets or (self.selected_bullet_num - 1)
			self.bullets[self.selected_bullet_num].onclick()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			return true
		elseif control == CONTROL_MENU_R2 then
			self.selected_bullet_num = self.selected_bullet_num == #self.bullets and 1 or (self.selected_bullet_num + 1)
			self.bullets[self.selected_bullet_num].onclick()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			return true
		end
	end
end

function MotdPanel:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_L2).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_R2).. " " .. STRINGS.UI.HELP.CHANGE_MESSAGE)

    return table.concat(t, "  ")
end

return MotdPanel
