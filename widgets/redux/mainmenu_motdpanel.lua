local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local easing = require "easing"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
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

	self.config = config
	self.bg = self:AddChild(Widget("motdpanel_bg"))
	self.fg = self:AddChild(Widget("motdpanel_fg"))

	if TheFrontEnd.MotdManager:IsLoading() then
		self:ShowSyncingIndicator()
		TheFrontEnd.MotdManager:AddOnLoadingDoneCB(self.inst, function(success) self:OnImagesLoaded() end)
	else
		self:OnImagesLoaded()
	end
end)

function MotdPanel:SetMotdInfo(src_motd_info)
	if src_motd_info ~= nil then
		self.motd_info = deepcopy(src_motd_info)
--[[
		self.motd_info.box6[1].streamer = "The Coolstreamer"
		self.motd_info.box6[1].title = "DST -  Lets take over the world! | Twitch.tv Skins Campaign Active"
		self.motd_info.box6[1].text = "Streaming Now on Twitch.tv!"
]]

	else
		self.motd_info = nil
	end

end

function MotdPanel:ShowSyncingIndicator()
	if self.sync_indicator ~= nil then
		return
	end

	self.sync_indicator = self.fg:AddChild(Widget("sync_indicator"))
    self.sync_indicator:SetPosition(175, -150)

	local text = self.sync_indicator:AddChild(Text(self.config.font, 18, STRINGS.UI.MAINSCREEN.MOTD_SYNCING, UICOLOURS.GOLD_UNIMPORTANT))
    text:SetPosition(0, -22)
	

	local image = self.sync_indicator:AddChild(Image("images/avatars.xml", "loading_indicator.tex"))
	local function dorotate() image:RotateTo(0, -360, .75, dorotate) end
	dorotate()
    image:SetScale(.7)
	image:SetTint(unpack(UICOLOURS.GOLD_UNIMPORTANT))
end

function MotdPanel:RemoveSyncingIndicator()
	if self.sync_indicator ~= nil then
		self.sync_indicator:Kill()
		self.sync_indicator = nil
	end
end

function MotdPanel:OnImagesLoaded()
	self.bg:KillAllChildren()
	self.fg:KillAllChildren()

	self:SetMotdInfo(TheFrontEnd.MotdManager:GetMotd())

	if self.motd_info == nil then
		Stats.PushMetricsEvent("motd2.failed", TheNet:GetUserID(), {}, "is_only_local_users_data")

		if self.config.error_cb ~= nil then
			self.config.error_cb()
		end
		return
	end

	local cell = nil
	local center_x = 167
	local center_y = -162

    local w = 295
	local cell_size = {width = w, height = w/16*9}
	local cell_spacing = 1

	local function AddCell(box_id, data, x, y)
		local image = nil
		if data.image ~= nil and data.image ~= "" and not data.requires_download then
			image = self.bg:AddChild(Image("images/motd_"..box_id..".xml", box_id..".tex"))
		else
			image = self.bg:AddChild(Image("images/motd_fallbacks_"..box_id..".xml", box_id..".tex"))
		end
		image:SetSize(cell_size.width, cell_size.height)
		--image:SetTint(.257, .257, .257, 1)
		image:SetPosition(x, y)

		local text_padding = 13

		local title_str = nil
		local body_str = nil

		if data.streamer ~= nil then -- twitch.tv live streamer
			title_str = data.text
			body_str = tostring(data.streamer).."\n"..(data.title ~= nil and tostring(data.title) or "")
		else
			title_str = data.title
			body_str = data.text
		end

		if body_str ~= nil and type(body_str) == "table" then	-- check for variables
			local format_vars = {}
			for k, v in pairs(body_str.variables) do
				if k == "date" then
					format_vars[k] = str_date(v)
				else
					format_vars[k] = v
				end
			end

			str = subfmt(body_str.text, format_vars)
		end

		local motd_msg = {}
		local screen = TheFrontEnd:GetActiveScreen()
		motd_msg.target = box_id
		motd_msg.url = data.link or "none"
		motd_msg.prefab = title_str or "unknown"
		motd_msg.special_event = WORLD_FESTIVAL_EVENT or FESTIVAL_EVENTS.NONE
		Stats.PushMetricsEvent("motd2.seen", TheNet:GetUserID(), motd_msg, "is_only_local_users_data")

		if data.link ~= nil then
			self.link_btn = self.fg:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "goto_url.tex", nil, false, false, 
				function() 
					Stats.PushMetricsEvent("motd2.clicked", TheNet:GetUserID(), motd_msg, "is_only_local_users_data")

					if data.link == "skins" then
						self.config.on_to_skins_cb()
					else
						VisitURL(data.link) 
					end
				end))
			self.link_btn:SetScale(0.5)
			local half_image_size = 10
			self.link_btn:SetPosition(x + cell_size.width / 2 - text_padding - half_image_size, y - cell_size.height / 2 + text_padding + half_image_size + 5)

			image.focus_forward = self.link_btn
		end

		if body_str ~= nil then
			local button_spacing = 21
			local font_size = 16
			local body = self.fg:AddChild(Text(self.config.font, font_size, "", UICOLOURS.GOLD_SELECTED))
			body:SetMultilineTruncatedString(body_str, 3, cell_size.width - text_padding * 2 - button_spacing, nil, true)
			body:SetHAlign(ANCHOR_LEFT)
			local w, h = body:GetRegionSize()
			local body_x, body_y = x + w/2 - cell_size.width/2 + text_padding, y -cell_size.height / 2 + h/2 + text_padding
			body:SetPosition(body_x, body_y)

			local shadow = self.fg:AddChild(Text(self.config.font, font_size, "", UICOLOURS.BLACK))
			shadow:SetMultilineTruncatedString(body_str, 3, cell_size.width - text_padding * 2 - button_spacing, nil, true)
			shadow:SetHAlign(ANCHOR_LEFT)
			shadow:SetPosition(body_x + 1.5, body_y - 1.5)
			shadow:MoveToBack()
		end

		if title_str ~= nil then
			local font_size = 20
			local max_w = cell_size.width - text_padding * 2
			local title = self.fg:AddChild(Text(self.config.font, font_size, "", UICOLOURS.HIGHLIGHT_GOLD))
			title:SetAutoSizingString(title_str, max_w)
			title:SetHAlign(ANCHOR_LEFT)
			local w = title:GetRegionSize()
			title:SetPosition(x - max_w/2 + w/2, y + cell_size.height / 2 - font_size / 2 - text_padding + 4)

			local shadow = self.fg:AddChild(Text(self.config.font, title:GetSize(), title_str, UICOLOURS.BLACK))
			local parent_pos = title:GetPosition()
			shadow:SetHAlign(ANCHOR_LEFT)
			shadow:SetPosition(parent_pos.x + 1.5, parent_pos.y - 1.5)
			shadow:MoveToBack()
		end

		if data.version ~= nil and tonumber(data.version) ~= nil then
			if tonumber(data.version) > tonumber(APP_VERSION) then
				local font_size = 18
				local str = STRINGS.UI.MAINSCREEN.MOTD_NEW_UPDATE
				local title = self.fg:AddChild(Text(self.config.font, font_size, str, alert_images.error.colour))
				title:SetRegionSize(cell_size.width - text_padding * 2, font_size + 2)
				title:SetHAlign(ANCHOR_LEFT)
				title:SetPosition(x, y + cell_size.height / 2 - font_size / 2 - text_padding + 4 - font_size)

				local shadow = self.fg:AddChild(Text(self.config.font, font_size, str, UICOLOURS.BLACK))
				shadow:SetRegionSize(cell_size.width - text_padding * 2, font_size + 2)
				shadow:SetHAlign(ANCHOR_LEFT)
				shadow:SetPosition(x + 1.5, y + cell_size.height / 2 - font_size / 2 - text_padding + 4 - font_size - 1.5)
				shadow:MoveToBack()
			end
		elseif data.icon ~= nil and ICON_MAP[data.icon] ~= nil then
			local icon_info = ICON_MAP[data.icon]
			local icon_image = self.fg:AddChild(Image(icon_info.atlas, icon_info.image))
			icon_image:SetScale(icon_info.scale)
			local w, h = icon_image:GetSize()
			icon_image:SetPosition(x + (w * icon_info.scale / 2) - cell_size.width/2 + text_padding + icon_info.x_offset, y + cell_size.height / 2 - h * icon_info.scale / 2 - text_padding - 20 + icon_info.y_offset)
			icon_image:SetClickable(false)
		end
	end

	local function AddAlert(data)
		local x, y = -220, 50

		local info = GetAlertInfo(data.level)

		if data.link ~= nil then
			local alert = self.fg:AddChild(TEMPLATES.IconButton("images/button_icons.xml", info.image, STRINGS.UI.MAINSCREEN.MOTD_ALERT_DETAILS, false, false, function() VisitURL(data.link) end, {offset_y = 45}))
			alert:SetScale(0.65)
			alert:SetPosition(x - 25, y)
		end

		local font_size = 20
		local body = self.fg:AddChild(Text(CHATFONT_OUTLINE, font_size, "", info.colour))
		body:SetMultilineTruncatedString(data.text, 10, 820, nil, true)
		body:SetHAlign(ANCHOR_LEFT)
		local w, h = body:GetRegionSize()
		local body_x, body_y = x + w/2 , y + h/2
		body:SetPosition(body_x, y)
	end

	for i = 1, 6 do
		local boxid = "box"..tostring(i)
	
		local x = ((i-1) % 3) - 1
		local y = math.floor((i-1) / 3)
		AddCell(boxid, self.motd_info[boxid][1], center_x + x * (cell_size.width + cell_spacing), center_y + (cell_size.height + cell_spacing) / 2 - (y * (cell_size.height + cell_spacing)))
	end

	if self.config.bg ~= nil then
		self.config.bg:Kill()
		self.config.bg = self.bg:AddChild(Image("images/bg_redux_dark_bottom.xml", "dark_bottom.tex"))
		self.config.bg:SetScale(.669)
		self.config.bg:SetPosition(0, -160)
		self.config.bg:SetClickable(false)
	end

	if self.motd_info.alert ~= nil then
		AddAlert(self.motd_info.alert[1])
	end

	self:SetPosition(0, 0) -- force an update to the transform so the parent's scissor info gets set...
end


return MotdPanel
