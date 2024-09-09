local Text = require "widgets/text"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local TEMPLATES = require "widgets/redux/templates"
require("stringutil")

local TIME_PER_DETAIL = 2
local LEVELUP_TIME = 1
local achievement_spacing = 38
local achievement_image_size = 36
local achievement_max_per_row = 9

local achievement_start = -256-18

local function TextTintToHelper(self, r, g, b, a)
	self:SetColour(self.colour[1], self.colour[2], self.colour[3], a)
end

local function IsAFoodDiscovery(name)
	local prefix = "food_"
	return string.sub(name, 1, string.len(prefix)) == prefix
end

local WxpLobbyPanel = Class(Widget, function(self, profile, on_anim_done_fn)
    Widget._ctor(self, "WxpLobbyPanel")
    self.profile = profile
    self.on_anim_done_fn = on_anim_done_fn

    self.current_eventid = TheNet:GetServerGameMode()
    self.levelup = false

	self.wxp = (TheNet:IsOnlineMode() and Settings.match_results.wxp_data ~= nil) and Settings.match_results.wxp_data[TheNet:GetUserID()] or {}
	local new_wxp = false
	if next(self.wxp) ~= nil then
		if self.wxp.match_xp ~= nil then
			self.levelup = wxputils.GetLevelForWXP(self.wxp.new_xp - self.wxp.match_xp) ~= wxputils.GetLevelForWXP(self.wxp.new_xp)

			if Client_IsTournamentActive() and Settings.match_results.outcome ~= nil and Settings.match_results.outcome.tournament_ticket ~= nil and not TheSim:IsBorrowed() then
				table.insert(self.wxp.details, {desc = string.upper(Settings.match_results.outcome.tournament_ticket), val = 0})
			end

			self.wxp.achievements = {}
			for k, detail in ipairs(self.wxp.details) do
				if Settings.match_results.outcome ~= nil and Settings.match_results.outcome.won and string.match(detail.desc, "MILESTONE_") then
					detail.desc = "WIN"
				end
				local achievement_name = EventAchievements:ParseFullQuestName(detail.desc).quest_id
				if EventAchievements:IsActiveAchievement(achievement_name) then
					detail._has_icon = true
					detail._is_achievement = true
					detail._sort_value = string.match(achievement_name, "_daily") and 20000 or 50000
					EventAchievements:SetAchievementTempUnlocked(detail.desc)
					detail.desc = achievement_name
					table.insert(self.wxp.achievements, deepcopy(detail))
				elseif IsAFoodDiscovery(detail.desc) then
					detail._has_icon = true
					detail._is_discovery = true
					detail._sort_value = 100000

					EventAchievements:SetAchievementTempUnlocked(detail.desc)
					table.insert(self.wxp.achievements, deepcopy(detail))
				else
					if self.current_eventid == "lavaarena" then
						detail.desc = "LAB_" .. tostring(detail.desc)
					end
					detail._has_icon = true
					detail.is_match_goal = true
					detail._sort_value = 0

					table.insert(self.wxp.achievements, deepcopy(detail))
				end
			end

			table.sort(self.wxp.details, function(a, b) return (a.val+(a._sort_value or 0)) < (b.val+(b._sort_value or 0)) end)
			table.sort(self.wxp.achievements, function(a, b) return (a.val+(a._sort_value or 0)) < (b.val+(b._sort_value or 0)) end)

			self.wxp.old_xp = math.max(0, self.wxp.new_xp - self.wxp.match_xp)
			self.wxp.old_level = wxputils.GetLevelForWXP(self.wxp.old_xp)

			new_wxp = true
			Settings.match_results.wxp_data[TheNet:GetUserID()] = {new_xp = self.wxp.new_xp, achievements = self.wxp.achievements}
		else
            --V2C: make a new table so we don't write all the
            --     data back to the table referenced in Settings!
            self.wxp = { new_xp = self.wxp.new_xp, achievements = self.wxp.achievements }
			self.wxp.earned_boxes = 0
			self.wxp.details = {}
			self.wxp.match_xp = 0
			self.wxp.old_xp = self.wxp.new_xp
			self.wxp.old_level = wxputils.GetLevelForWXP(self.wxp.new_xp)
		end
	else
		self.wxp = {}
		self.wxp.new_xp = wxputils.GetActiveWXP()
		self.wxp.earned_boxes = 0
		self.wxp.details = {}
		self.wxp.match_xp = 0
		self.wxp.old_xp = self.wxp.new_xp
		self.wxp.old_level = wxputils.GetActiveLevel()
		self.wxp.achievements = {}
	end

	if not self.levelup then
		achievement_max_per_row = 15
		if #self.wxp.achievements > 30 then
			achievement_spacing = 30
			achievement_image_size = 28
			achievement_max_per_row = 19
		end
	elseif #self.wxp.achievements > 18 then
		achievement_spacing = 30
		achievement_image_size = 28
		achievement_max_per_row = 11
	end

	self.detail_index = 1

	self.displayinfo = {}
	self.displayinfo.timer = 0
	self.displayinfo.duration =  #self.wxp.details * TIME_PER_DETAIL
	self.displayinfo.showing_level = self.wxp.old_level
	self.displayinfo.showing_level_start_xp, self.displayinfo.showing_level_end_xp = wxputils.GetWXPForLevel(self.wxp.old_level)

	self.displayachievements = {}

    self:DoInit(not new_wxp or self.displayinfo.duration <= 0)

	if new_wxp then
		self.inst:DoTaskInTime(0.5, function() self.is_updating = true self:RefreshWxpDetailWidgets() end)
    else
		self.inst:DoTaskInTime(0.0, function() self:OnCompleteAnimation() end)
	end
end)

function WxpLobbyPanel:DoInit(nosound)
    self.wxpbar = self:AddChild(TEMPLATES.WxpBar())
    self.wxpbar:SetPosition(0, -40)
    self.rank = self.wxpbar.rank
    self.nextrank = self.wxpbar.nextrank

    self.details_widget = self.wxpbar:AddChild(self:_BuildGameStats())
    self.details_widget:SetPosition(0, -65)

	self:SetRank(self.displayinfo.showing_level, false, self.displayinfo.showing_level_end_xp - self.displayinfo.showing_level_start_xp)
	self.wxpbar:UpdateExperience(self.wxp.old_xp - self.displayinfo.showing_level_start_xp, self.displayinfo.showing_level_end_xp - self.displayinfo.showing_level_start_xp)

	self.achievement_root = self.wxpbar:AddChild(Widget("achievement_root"))

    if not nosound then
	   TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/collectionscreen/xp_shepard_LP", "fillsound")
	   TheFrontEnd:GetSound():SetParameter("fillsound","pitch",0.8)
    end
end

function WxpLobbyPanel:ShowAchievement(achievement, animate)
	local num_shown = #self.displayachievements
	local img_width = achievement_image_size
	local max_num_wide = achievement_max_per_row

	local img = nil

	--print("SDFSDF", achievement.desc, IsAFoodDiscovery(achievement.desc))

	local hover_text = nil
	local achievement_altas = self.current_eventid == "lavaarena" and "images/lavaarena_quests.xml" or "images/quagmire_achievements.xml"

	if achievement._is_discovery then
		img = self.achievement_root:AddChild(Image("images/quagmire_recipebook.xml", "recipe_known.tex"))

		local split_desc = string.split(achievement.desc, "_")
		local recipe_name = (tonumber(split_desc[#split_desc]) ~= nil and "quagmire_food_" or "quagmire_") .. tostring(split_desc[#split_desc])
		hover_text = subfmt(STRINGS.UI.WXPLOBBYPANEL.FOOD_DISCOVERY, {name = STRINGS.NAMES[string.upper(recipe_name)]})

		if TheRecipeBook.recipes[recipe_name] ~= nil then
			local dish = TheRecipeBook.recipes[recipe_name].dish
			if dish ~= nil then
				local dish_img = img:AddChild(Image("images/quagmire_food_common_inv_images_hires.xml", dish..".tex"))
				dish_img:SetSize(img_width - 8, img_width - 8)
				if animate then
					dish_img:SetTint(1,1,1,0)
					dish_img:TintTo({r=1,g=1,b=1,a=0}, {r=1,g=1,b=1,a=1}, LEVELUP_TIME)
				end
			end
			local atlas = "images/quagmire_food_inv_images_hires_"..recipe_name..".xml"
			if dish == nil then
				atlas = GetInventoryItemAtlas(recipe_name..".tex")
			end

			local food_img = img:AddChild(Image(atlas, recipe_name..".tex"))
			food_img:SetSize(img_width - 8, img_width - 8)
			if animate then
				food_img:SetTint(1,1,1,0)
				food_img:TintTo({r=1,g=1,b=1,a=0}, {r=1,g=1,b=1,a=1}, LEVELUP_TIME)
			end
		end
	elseif achievement.is_match_goal then
		img = self.achievement_root:AddChild(Image(achievement_altas, string.lower(achievement.desc)..".tex"))
		hover_text = STRINGS.UI.WXP_DETAILS[string.upper(achievement.desc)]
	else
		img = self.achievement_root:AddChild(Image(achievement_altas, achievement.desc..".tex"))

		local ach_str = GetActiveFestivalEventAchievementStrings()
		hover_text = ach_str.ACHIEVEMENT[achievement.desc].TITLE
	end

	if hover_text ~= nil then
		if achievement.val ~= nil and achievement.val > 0 then
			hover_text = subfmt(STRINGS.UI.WXPLOBBYPANEL.ADD_XP_VAL, {name = hover_text, val = tostring(achievement.val)})
		end
		img:SetHoverText(hover_text, {offset_y = 32, colour = UICOLOURS.EGGSHELL})
	end

	img:SetPosition(achievement_start + (achievement_spacing)*(num_shown%max_num_wide), (achievement_spacing*math.floor(1 + num_shown/max_num_wide)) + 3)
	img:SetSize(img_width, img_width)
	img:MoveToBack()

	if animate then
		img:SetTint(1,1,1,0)
		img:TintTo({r=1,g=1,b=1,a=0}, {r=1,g=1,b=1,a=1}, LEVELUP_TIME)
	end

	table.insert(self.displayachievements, img)
end

function WxpLobbyPanel:SetRank(rank, levelup, next_level_xp)
	self.wxpbar:SetRank(rank, next_level_xp, GetMostRecentlySelectedItem(Profile, "profileflair"))

	if levelup then
		if self.leveluptext == nil then
			self.leveluptext = self.wxpbar:AddChild(Text(HEADERFONT, 50, STRINGS.UI.WXPLOBBYPANEL.LEVEL_UP, UICOLOURS.HIGHLIGHT_GOLD))
			local x = 0
			local width = self.leveluptext:GetRegionSize()
			if (achievement_start + #self.wxp.achievements*achievement_spacing) >= (-width/2) then
				x = 300 - (width*0.5)
			end

			self.leveluptext:SetPosition(x, 38)

			local glow = self.wxpbar:AddChild(Image("images/global_redux.xml", "progressbar_wxplarge_glow.tex"))
			glow:SetTint(1,1,1,0)
			glow:TintTo({r=1,g=1,b=1,a=0}, {r=1,g=1,b=1,a=1}, LEVELUP_TIME)
			glow:MoveToBack()
		end
		if self.leveluptext._isscalingtorank == nil or self.leveluptext._isscalingtorank ~= rank then
			self.leveluptext._isscalingtorank = rank

			self.leveluptext:SetScale(0.8)
			self.leveluptext:ScaleTo(.8, 1, LEVELUP_TIME)

			local next_rank_pulse = self.nextrank.num:AddChild(Text(self.nextrank.num.font, self.nextrank.num.size, self.nextrank.num:GetString(), UICOLOURS.WHITE))
			next_rank_pulse:SetScale(1)
			next_rank_pulse:ScaleTo(1, 2, LEVELUP_TIME)
			next_rank_pulse.SetTint = TextTintToHelper
			next_rank_pulse:SetTint(1,1,1,1)
			next_rank_pulse:TintTo({r=1,g=1,b=1,a=1}, {r=1,g=1,b=1,a=0}, LEVELUP_TIME, function() next_rank_pulse:Kill() end)

			local cur_rank_pulse = self.rank.num:AddChild(Text(self.rank.num.font, self.rank.num.size, self.rank.num:GetString(), UICOLOURS.WHITE))
			cur_rank_pulse:SetScale(1)
			cur_rank_pulse:ScaleTo(1, 2, LEVELUP_TIME)
			cur_rank_pulse.SetTint = TextTintToHelper
			cur_rank_pulse:SetTint(1,1,1,1)
			cur_rank_pulse:TintTo({r=1,g=1,b=1,a=1}, {r=1,g=1,b=1,a=0}, LEVELUP_TIME, function() cur_rank_pulse:Kill() end)
		end
	end

end

function WxpLobbyPanel:_BuildGameStats()
    local gamestats = Widget("gamestats")
    gamestats:Hide()

    self.detail_name_textbox = gamestats:AddChild(Text(HEADERFONT, 25, "", UICOLOURS.EGGSHELL))
    self.detail_name_textbox:SetHAlign(ANCHOR_LEFT)
    self.detail_name_textbox:SetPosition(0, 30)

    self.detail_wxp_textbox = gamestats:AddChild(Text(HEADERFONT, 40, "", UICOLOURS.HIGHLIGHT_GOLD))
    self.detail_wxp_textbox:SetPosition(0, 0)
    self.detail_wxp_textbox:SetHAlign(ANCHOR_LEFT)

    self.detail_wxplabel_textbox = gamestats:AddChild(Text(CHATFONT, 25, STRINGS.UI.WXPLOBBYPANEL.WXP, UICOLOURS.HIGHLIGHT_GOLD))
    self.detail_wxplabel_textbox:SetPosition(0, -25)

    return gamestats
end

function WxpLobbyPanel:IsAnimating()
	return not self.is_animation_done
end

function WxpLobbyPanel:SkipAnimation()
    self:OnCompleteAnimation()
end

function WxpLobbyPanel:OnCompleteAnimation()
	self.is_updating = false
	self.details_widget:Hide()
	TheFrontEnd:GetSound():KillSound("fillsound")

    if self.wxp.earned_boxes > 0 then
    	--TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/collectionscreen/earned") --change to earned boxes

        local newbox_title = self.wxpbar:AddChild(Text(HEADERFONT, 30, "", UICOLOURS.EGGSHELL))
		newbox_title:SetPosition(0, -37)

        local newbox_body = self.wxpbar:AddChild(Text(HEADERFONT, 22, "", UICOLOURS.HIGHLIGHT_GOLD))
		newbox_body:SetPosition(0, -155)
		newbox_body:EnableWordWrap(true)
		newbox_body:SetVAlign(ANCHOR_TOP)
		newbox_body:SetRegionSize(350, 200)

		if self.wxp.earned_boxes == 1 then
			newbox_title:SetString(STRINGS.UI.WXPLOBBYPANEL.NEWBOX_TITLE[WORLD_FESTIVAL_EVENT])
			newbox_body:SetString(STRINGS.UI.WXPLOBBYPANEL.NEWBOX_BODY)
		else
			newbox_title:SetString(subfmt(STRINGS.UI.WXPLOBBYPANEL.NEWBOXES_TITLE[WORLD_FESTIVAL_EVENT], {num = tostring(self.wxp.earned_boxes)}))
			newbox_body:SetString(STRINGS.UI.WXPLOBBYPANEL.NEWBOXES_BODY)
		end
	end

	if #self.wxp.achievements > 0 then
		if #self.displayachievements == 0 then
			for k, v in ipairs(self.wxp.achievements) do
				self:ShowAchievement(v)
			end
		elseif self.detail_index ~= nil and ((self.detail_index + 1) <= #self.wxp.details) then
			for i = self.detail_index + 1, #self.wxp.details do
				if self.wxp.details[i]._has_icon then
					self:ShowAchievement(self.wxp.details[i])
				end
			end
		end
	end

	local level = wxputils.GetLevelForWXP(self.wxp.new_xp)
	local level_start_xp, next_level_xp = wxputils.GetWXPForLevel(level)
	self:SetRank(level, self.levelup, next_level_xp - level_start_xp)
	self.wxpbar:UpdateExperience(self.wxp.new_xp - level_start_xp, next_level_xp - level_start_xp)

	self.is_animation_done = true
	if self.on_anim_done_fn ~= nil then
		self.on_anim_done_fn()
	end
end

function WxpLobbyPanel:RefreshWxpDetailWidgets()
	if #self.wxp.details > 0 then
		local name = STRINGS.UI.WXP_DETAILS[self.wxp.details[self.detail_index].desc]
		if self.wxp.details[self.detail_index]._has_icon then
			if self.wxp.details[self.detail_index]._is_discovery then
				local split_desc = string.split(self.wxp.details[self.detail_index].desc, "_")
				local recipe_name = (tonumber(split_desc[#split_desc]) ~= nil and "quagmire_food_" or "quagmire_") .. tostring(split_desc[#split_desc])
				name = subfmt(STRINGS.UI.WXPLOBBYPANEL.FOOD_DISCOVERY, {name = STRINGS.NAMES[string.upper(recipe_name)]})
			elseif self.wxp.details[self.detail_index]._is_achievement then
				local ach_str = GetActiveFestivalEventAchievementStrings()
				local achievelemt_desc = ach_str.ACHIEVEMENT[self.wxp.details[self.detail_index].desc]
				if achievelemt_desc ~= nil then
					name = subfmt(STRINGS.UI.WXPLOBBYPANEL.ACHIEVEMENT_UNLOCKED, {name=achievelemt_desc.TITLE})
				end
			end
			self:ShowAchievement(self.wxp.details[self.detail_index], true)
		end

		self.detail_name_textbox:SetString(name or "")
		if self.wxp.details[self.detail_index].val > 0 then
			self.detail_wxp_textbox:SetString(subfmt(STRINGS.UI.WXPLOBBYPANEL.DETAILS_XP, {num = self.wxp.details[self.detail_index].val}))
			self.detail_wxp_textbox:Show()
			self.detail_wxplabel_textbox:Show()
		else
			self.detail_wxp_textbox:Hide()
			self.detail_wxplabel_textbox:Hide()
		end

		self.details_widget:SetScale(.8)
		self.details_widget:ScaleTo(.8, 1, TIME_PER_DETAIL)
		self.details_widget:Hide()
		self.details_widget.inst:DoTaskInTime(0, function() self.details_widget:Show() end)

		self.detail_wxp_textbox.SetTint = TextTintToHelper
		self.detail_wxp_textbox:SetTint(1,1,1,0)
		self.detail_wxp_textbox:TintTo({r=1,g=1,b=1,a=0}, {r=1,g=1,b=1,a=1}, TIME_PER_DETAIL * 0.5)

		self.detail_name_textbox.SetTint = TextTintToHelper
		self.detail_name_textbox:SetTint(1,1,1,0)
		self.detail_name_textbox:TintTo({r=1,g=1,b=1,a=0}, {r=1,g=1,b=1,a=1}, TIME_PER_DETAIL * 0.5)

		self.detail_wxplabel_textbox.SetTint = TextTintToHelper
		self.detail_wxplabel_textbox:SetTint(1,1,1,0)
		self.detail_wxplabel_textbox:TintTo({r=1,g=1,b=1,a=0}, {r=1,g=1,b=1,a=1}, TIME_PER_DETAIL * 0.5)

	end
end

function WxpLobbyPanel:OnUpdate(dt)
	if not self.is_updating then
		return
	end

	self.displayinfo.timer = math.min(self.displayinfo.timer + dt, self.displayinfo.duration)
	local t = math.clamp((math.sin((self.displayinfo.timer / self.displayinfo.duration) * math.pi - math.pi * 0.5) + 1) * 0.5, 0, 1)

	if self.displayinfo.timer >= self.displayinfo.duration then
		t = 1
		self:OnCompleteAnimation()
	end

	local showing_xp = t * self.wxp.match_xp + self.wxp.old_xp
	if showing_xp >= self.displayinfo.showing_level_end_xp then
		showing_xp = self.displayinfo.showing_level_end_xp
		self.displayinfo.showing_level = self.displayinfo.showing_level + 1
		self.displayinfo.showing_level_start_xp = self.displayinfo.showing_level_end_xp
		self.displayinfo.showing_level_end_xp = wxputils.GetWXPForLevel(self.displayinfo.showing_level + 1)

		-- do level up anims on badge
		self:SetRank(self.displayinfo.showing_level, true, self.displayinfo.showing_level_end_xp - self.displayinfo.showing_level_start_xp)
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/XP_bar_fill_unlock")
        if TheFrontEnd:GetSound():PlayingSound("fillsound") then
            TheFrontEnd:GetSound():KillSound("fillsound")
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/collectionscreen/xp_shepard_LP", "fillsound")
            TheFrontEnd:GetSound():SetParameter("fillsound","pitch",0.8)
        end
	end

	self.wxpbar:UpdateExperience(showing_xp - self.displayinfo.showing_level_start_xp, self.displayinfo.showing_level_end_xp - self.displayinfo.showing_level_start_xp)

	if math.floor(self.displayinfo.timer / (TIME_PER_DETAIL )) + 1 > self.detail_index then
		self.detail_index = self.detail_index + 1
		if self.detail_index <= #self.wxp.details then
			self:RefreshWxpDetailWidgets()
		end
	end


end


return WxpLobbyPanel
