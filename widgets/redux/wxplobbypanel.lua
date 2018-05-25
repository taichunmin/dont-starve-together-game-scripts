local Text = require "widgets/text"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local TEMPLATES = require "widgets/redux/templates"
local WxpUtils = require "wxputils"
require("stringutil")

local TIME_PER_DETAIL = 2
local LEVELUP_TIME = 1
local achievement_spacing = 38
local achievement_start = -256-18

local function TextTintToHelper(self, r, g, b, a)
	self:SetColour(self.colour[1], self.colour[2], self.colour[3], a)
end 

local WxpLobbyPanel = Class(Widget, function(self, profile, on_anim_done_fn)
    Widget._ctor(self, "WxpLobbyPanel")
    self.profile = profile
    self.on_anim_done_fn = on_anim_done_fn
    
    self.current_eventid = TheNet:GetServerGameMode()
    
	self.wxp = (TheNet:IsOnlineMode() and Settings.match_results.wxp_data ~= nil) and Settings.match_results.wxp_data[TheNet:GetUserID()] or {}
	local new_wxp = false
	if next(self.wxp) ~= nil then
		if self.wxp.match_xp ~= nil then
			self.wxp.achievements = {}
			for k, detail in pairs(self.wxp.details) do
				if EventAchievements:IsAnAchievement(self.current_eventid, detail.desc) then
					detail._is_achievement = true
					EventAchievements:SetAchievementTempUnlocked(detail.desc)
					table.insert(self.wxp.achievements, detail.desc)
				end
			end

			table.sort(self.wxp.details, function(a, b) return (a.val+(a._is_achievement and 99999 or 0)) < (b.val+(b._is_achievement and 99999 or 0)) end)
			
			self.wxp.old_xp = math.max(0, self.wxp.new_xp - self.wxp.match_xp)
			self.wxp.old_level = TheItems:GetLevelForWXP(self.wxp.old_xp)

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
			self.wxp.old_level = TheItems:GetLevelForWXP(self.wxp.new_xp)
		end
	else
		self.wxp = {}
		self.wxp.new_xp = TheInventory:GetWXP()
		self.wxp.earned_boxes = 0
		self.wxp.details = {}
		self.wxp.match_xp = 0
		self.wxp.old_xp = self.wxp.new_xp
		self.wxp.old_level = TheInventory:GetWXPLevel()
		self.wxp.achievements = {}
	end

	self.detail_index = 1

	self.displayinfo = {}
	self.displayinfo.timer = 0
	self.displayinfo.duration =  #self.wxp.details * TIME_PER_DETAIL
	self.displayinfo.showing_level = self.wxp.old_level
	self.displayinfo.showing_level_start_xp = TheItems:GetWXPForLevel(self.wxp.old_level)
	self.displayinfo.showing_level_end_xp = TheItems:GetWXPForLevel(self.wxp.old_level + 1)

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

function WxpLobbyPanel:ShowAchievement(achievement_id, animate)
	local num_shown = #self.displayachievements
	local img_width = 36
	local max_num_wide = 9
	
	local img = self.achievement_root:AddChild(Image("images/"..self.current_eventid.."_achievements.xml", achievement_id..".tex"))
	img:SetPosition(achievement_start + (achievement_spacing)*(num_shown%max_num_wide), (achievement_spacing*math.floor(1 + num_shown/max_num_wide)) + 3)
	img:SetSize(img_width, img_width)
	img:SetHoverText(STRINGS.UI.ACHIEVEMENTS.LAVAARENA.ACHIEVEMENT[achievement_id].TITLE, {offset_y = 32, colour = UICOLOURS.EGGSHELL})
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
    	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/collectionscreen/earned") --change to earned boxes

        local newbox_title = self.wxpbar:AddChild(Text(HEADERFONT, 30, "", UICOLOURS.EGGSHELL))
		newbox_title:SetPosition(0, -37)

        local newbox_body = self.wxpbar:AddChild(Text(HEADERFONT, 22, "", UICOLOURS.HIGHLIGHT_GOLD))
		newbox_body:SetPosition(0, -155)
		newbox_body:EnableWordWrap(true)
		newbox_body:SetVAlign(ANCHOR_TOP)
		newbox_body:SetRegionSize(350, 200)
		
		if self.wxp.earned_boxes == 1 then
			newbox_title:SetString(STRINGS.UI.WXPLOBBYPANEL.NEWBOX_TITLE)
			newbox_body:SetString(STRINGS.UI.WXPLOBBYPANEL.NEWBOX_BODY)
		else
			newbox_title:SetString(subfmt(STRINGS.UI.WXPLOBBYPANEL.NEWBOXES_TITLE, {num = tostring(self.wxp.earned_boxes)}))
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
				if self.wxp.details[i]._is_achievement then
					self:ShowAchievement(self.wxp.details[i].desc)
				end
			end
		end
	end
	
	local level = TheItems:GetLevelForWXP(self.wxp.new_xp)
	local level_start_xp = TheItems:GetWXPForLevel(level)
	local next_level_xp = TheItems:GetWXPForLevel(level + 1)
	local levelup = self.wxp.match_xp ~= nil and (TheItems:GetLevelForWXP(self.wxp.new_xp - self.wxp.match_xp) ~= level) or false
	self:SetRank(level, levelup, next_level_xp - level_start_xp)
	self.wxpbar:UpdateExperience(self.wxp.new_xp - level_start_xp, next_level_xp - level_start_xp)
	
	self.is_animation_done = true
	if self.on_anim_done_fn ~= nil then
		self.on_anim_done_fn()
	end
end

function WxpLobbyPanel:RefreshWxpDetailWidgets()
	if #self.wxp.details > 0 then
		local name = STRINGS.UI.WXP_DETAILS[self.wxp.details[self.detail_index].desc]
		if name == nil then
			local achievelemt_desc = STRINGS.UI.ACHIEVEMENTS.LAVAARENA.ACHIEVEMENT[self.wxp.details[self.detail_index].desc]
			if achievelemt_desc ~= nil then
				name = subfmt(STRINGS.UI.WXPLOBBYPANEL.ACHIEVEMENT_UNLOCKED, {name=achievelemt_desc.TITLE})
				self:ShowAchievement(self.wxp.details[self.detail_index].desc, true)
			end
		end
		
		self.detail_name_textbox:SetString(name or "")
		self.detail_wxp_textbox:SetString(subfmt(STRINGS.UI.WXPLOBBYPANEL.DETAILS_XP, {num = self.wxp.details[self.detail_index].val}))
		
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
		self.displayinfo.showing_level_end_xp = TheItems:GetWXPForLevel(self.displayinfo.showing_level + 1)

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
