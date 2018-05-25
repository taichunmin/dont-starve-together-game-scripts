-- Yup, this is almost the same as PortraitBackgroundExplorerPanel.
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local TEMPLATES = require "widgets/redux/templates"

require("dlcsupport")
require("misc_items")
require("util")


local AchievementsPanel = Class(Widget, function(self, user_profile, festival_key)
    Widget._ctor(self, "AchievementsPanel")
    self.user_profile = user_profile

    self.achievements_root = self:AddChild(Widget("achievements_root"))

    self.dialog = self.achievements_root:AddChild(TEMPLATES.RectangleWindow(736, 406))
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.dialog:SetBackgroundTint(r,g,b,0.8) -- need high opacity because of text behind
    self.dialog:SetPosition(0, -5)
    self.dialog.top:Hide() -- top crown would be behind our title.
    
    self.grid = self.dialog:InsertWidget( self:_BuildAchievementsExplorer(festival_key) )
    self.grid:SetPosition(-10,0)
    
    local title = self.achievements_root:AddChild(Text(HEADERFONT, 28, STRINGS.UI.ACHIEVEMENTS.SCREENTITLE, UICOLOURS.HIGHLIGHT_GOLD))
	title:SetPosition(0, 222)

	local unlocked, total = EventAchievements:GetNumAchievementsUnlocked(festival_key)

    local completed = self.achievements_root:AddChild(Text(HEADERFONT, 24, subfmt(STRINGS.UI.XPUTILS.XPPROGRESS, {num=unlocked, max=total}), UICOLOURS.HIGHLIGHT_GOLD))
	completed:SetHAlign(ANCHOR_RIGHT)
	completed:SetPosition(330, 222)

    self.focus_forward = self.grid
end)

function AchievementsPanel:_BuildAchievementsExplorer(current_eventid)
    
    local row_w = 720;
    local row_h = 60;
    local icon_size = 50;
    local reward_width = 80;
    local icon_spacing = 5;
    local row_spacing = 5;
    
    local function ScrollWidgetsCtor(context, index)
        local w = Widget("achievement-cell-".. index)

        local function OnPortraitFocused(is_enabled)
        end
        local function OnPortraitClicked()
        end

        -- Using a valid character to silence load errors.
        
        w.frame = w:AddChild(Image("images/frontend_redux.xml", "achievement_backing.tex"))
        w.frame:ScaleToSize(row_w,row_h)
        w.frame:SetPosition(0,0)
        
        w.title = w:AddChild(Text(HEADERFONT, 22, ""))
        w.title:SetColour(UICOLOURS.HIGHLIGHT_GOLD)
        w.title:SetRegionSize(row_w, 24)
        w.title:SetHAlign(ANCHOR_LEFT)
        w.title:SetPosition(0,-row_h/2+20)
        w.count = w:AddChild(Text(HEADERFONT, 22, ""))
        w.count:SetColour(UICOLOURS.HIGHLIGHT_GOLD)
        w.count:SetRegionSize(row_w, 24)
        w.count:SetHAlign(ANCHOR_RIGHT)
        w.count:SetPosition(0,-row_h/2+20)
        w.divider = w:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
        w.divider:ScaleToSize(row_w,5)
        w.divider:SetPosition(0,-row_h/2+5)
        
        w.reward_num = w:AddChild(Text(HEADERFONT, 25, "")) 
        w.reward_num:SetColour(UICOLOURS.GOLD_SELECTED)
        w.reward_num:SetRegionSize(reward_width, 25)
        w.reward_num:SetPosition(row_w/2-reward_width/2-5,8)
        w.reward_label = w:AddChild(Text(HEADERFONT, 16, "")) 
        w.reward_label:SetColour(UICOLOURS.HIGHLIGHT_GOLD)
        w.reward_label:SetRegionSize(reward_width, 16)
        w.reward_label:SetPosition(row_w/2-reward_width/2-5,-10)
        w.reward_label:SetString(STRINGS.UI.WXPLOBBYPANEL.WXP)
        
        w.name = w:AddChild(Text(HEADERFONT, 18, "")) 
        w.name:SetColour(UICOLOURS.GOLD_SELECTED)
        w.name:SetRegionSize(row_w - reward_width -icon_spacing - icon_size - icon_spacing - 10, 18)
        w.name:SetHAlign(ANCHOR_LEFT)
        w.name:SetPosition(-10,14)
        
        w.desc = w:AddChild(Text(CHATFONT, 18, ""))
        w.desc:SetColour(UICOLOURS.GREY)
        w.desc:SetRegionSize(row_w - reward_width -icon_spacing - icon_size - icon_spacing - 10, 40)
        w.desc:SetHAlign(ANCHOR_LEFT)
        w.desc:EnableWordWrap(true)
        w.desc:SetPosition(-10,-9)
        
        w.icon = w:AddChild(Image("images/"..current_eventid.."_achievements.xml", "achievement_locked.tex"))
        w.icon:ScaleToSize(icon_size,icon_size)
        w.icon:SetPosition(-325,0)
        
        w.ic_completed = w:AddChild(Image("images/frontend_redux.xml", "accountitem_frame_arrow.tex"))
        w.ic_completed:ScaleToSize(icon_size/2.2,icon_size/2.2)
        w.ic_completed:SetPosition(-306,-17)

        return w

    end

    local function ScrollWidgetApply(context, widget, data, index)
        if data then
            if data.category == true then
                widget.title:SetString(data.title)
                widget.count:SetString(data.count)
                widget.title:Show()
                widget.count:Show()
                widget.divider:Show()
                widget.frame:Hide()
                widget.reward_num:Hide()
                widget.reward_label:Hide()
                widget.name:Hide()
                widget.desc:Hide()
                widget.icon:Hide()
                widget.ic_completed:Hide()
            else
                widget.title:Hide()
                widget.count:Hide()
                widget.divider:Hide()
                widget.name:SetString(data.achievement_title)
                widget.desc:SetString(data.achievement_desc)
                widget.reward_num:SetString(data.wxp)
                widget.name:Show()
                widget.desc:Show()
                widget.reward_num:Show()
                widget.reward_label:Show()
                widget.icon:Show()
                widget.frame:Show()
                if data.completed then
                    widget.ic_completed:Hide()
                    widget.name:SetColour(UICOLOURS.GOLD_FOCUS)
                    widget.desc:SetColour(UICOLOURS.HIGHLIGHT_GOLD)
                    widget.reward_num:SetColour(UICOLOURS.GOLD_FOCUS)
                    widget.reward_label:SetColour(UICOLOURS.HIGHLIGHT_GOLD)
                    widget.icon:SetTexture("images/"..current_eventid.."_achievements.xml", data.icon..".tex")
                else
                    widget.ic_completed:Hide()
                    widget.name:SetColour(UICOLOURS.GREY)
                    widget.desc:SetColour(UICOLOURS.GOLD_SELECTED)
                    widget.reward_num:SetColour(UICOLOURS.GREY)
                    widget.reward_label:SetColour(UICOLOURS.GREY)
                    widget.icon:SetTexture("images/"..current_eventid.."_achievements.xml", "achievement_locked.tex")
                end
            end
        else
            widget:Hide()
        end
    end

    local scrollitems = {}
    for _,categories in ipairs(EventAchievements:GetAchievementsCategoryList(current_eventid)) do
        local num_completed = 0
        for _,achievement in ipairs(categories.data) do
            if EventAchievements:IsAchievementUnlocked(achievement.achievementid) then
                num_completed = num_completed + 1
            end
        end
        local count_str = subfmt(STRINGS.UI.XPUTILS.XPPROGRESS, {num=num_completed, max=#categories.data})
        table.insert(scrollitems, {category=true, title=STRINGS.UI.ACHIEVEMENTS[string.upper(current_eventid)].CATEGORIES[categories.category], count=count_str})
        for _,achievement in ipairs(categories.data) do
            table.insert(scrollitems, { 
                category=false, 
                category_goal=achievement.category_goal, 
                achievement_title = STRINGS.UI.ACHIEVEMENTS[string.upper(current_eventid)].ACHIEVEMENT[achievement.achievementid].TITLE, 
                achievement_desc = STRINGS.UI.ACHIEVEMENTS[string.upper(current_eventid)].ACHIEVEMENT[achievement.achievementid].DESC, 
                wxp = achievement.wxp, 
                completed = EventAchievements:IsAchievementUnlocked(achievement.achievementid),
                icon = achievement.achievementid,
            })
        end
    end

    local grid = TEMPLATES.ScrollingGrid(
        scrollitems,
        {
            context = {},
            widget_width  = row_w+50,
            widget_height = row_h+row_spacing,
            num_visible_rows = 6,
            num_columns      = 1,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ScrollWidgetApply,
            scrollbar_offset = 0,
            scrollbar_height_offset = -60,
        })
    
    return grid

end

return AchievementsPanel
