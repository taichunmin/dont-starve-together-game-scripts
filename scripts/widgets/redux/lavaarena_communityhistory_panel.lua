local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Grid = require "widgets/grid"
local Spinner = require "widgets/spinner"

local TEMPLATES = require "widgets/redux/templates"

local easing = require("easing")
require("util")

-------------------------------------------------------------------------------------------------------
local CommunityProgress = Class(Widget, function(self)
    Widget._ctor(self, "CommunityProgress")

	self.root = self:AddChild(Widget("root"))
	self.root:SetPosition(12, 0)

	self:ShowSyncing()

	self.inst:ListenForEvent("community_clientdata_updated", function() self:OnRecievedData() end, TheGlobalInstance)
		if TheWorld ~= nil then
			if not Lavaarena_CommunityProgression:IsQueryActive(TheNet:GetUserID()) then
				self:OnRecievedData()
			end
		else
			Lavaarena_CommunityProgression:RequestAllData(false)
		end

	self:_DoFocusHookups()

	return self
end)

function CommunityProgress:ShowSyncing()
	self.root:KillAllChildren()

	local title = self.root:AddChild(Text(HEADERFONT, 20, STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.SYNCING_DATA, UICOLOURS.BROWN_DARK))
	title:SetPosition(0, 0)
end

function CommunityProgress:OnRecievedData()
	self.root:KillAllChildren()

	local query_successful = Lavaarena_CommunityProgression:GetProgressionQuerySuccessful()
	if query_successful then
		if IsFestivalEventActive(FESTIVAL_EVENTS.LAVAARENA) then
			local fmt_str = Lavaarena_CommunityProgression:IsEverythingUnlocked() and STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.EVERYTHING_UNLOCKED or STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.DESCRIPTION
			local title_str = subfmt(fmt_str, {boss=STRINGS.NAMES[string.upper(Lavaarena_CommunityProgression:GetProgressionKeyBoss())]})
			local title = self.root:AddChild(Text(HEADERFONT, 18, title_str, UICOLOURS.BROWN_DARK))
			title:SetPosition(0, 200)

			self.details_root = self.root:AddChild(self:BuildDetailsPanel())
			self.details_root:SetPosition(0, 150)
		else
			self.details_root = self.root:AddChild(self:BuildDetailsPanel())
			self.details_root:SetPosition(0, 160)
		end
	else
		local failed_msg = self.root:AddChild(Text(HEADERFONT, 22, STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.PROGRESSION_QUERY_FAILURE, UICOLOURS.BROWN_DARK))
		failed_msg:SetPosition(0, 0)
	end

end

local detail_width = 375
local detail_height = 70

local function MakeDetailsEntry(item)
	local is_locked = Lavaarena_CommunityProgression:IsLocked(item.id)

    local w = Widget("detail-cell")

    local backing = w:AddChild(Image("images/lavaarena_unlocks.xml", "box1.tex"))
    backing:ScaleToSize(detail_width, detail_height)
    backing:SetPosition(0,0)

	if is_locked then
		local title = w:AddChild(Text(HEADERFONT, 20, STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.LOCKED[string.upper(item.style)], UICOLOURS.BROWN_DARK))
		title:SetPosition(20, 0)

		local icon = w:AddChild(Image("images/lavaarena_unlocks.xml", (item.style == "item" and "locked_item.tex") or (item.style == "boss" and "locked_boss.tex") or "locked_creature.tex"))
		local width, height = icon:GetSize()
		icon:SetScale((item.style == "item" and 0.8) or (item.style == "boss" and 0.5) or 0.6)
		icon:SetPosition(-detail_width / 2 + detail_height / 2 + 5, 0)
	else
		local str = STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.UNLOCKED_TITLE[string.upper(item.id)] or STRINGS.NAMES[string.upper(item.id)]
		local title = w:AddChild(Text(HEADERFONT, 18, str or STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.UNKNOWN, UICOLOURS.BROWN_DARK))
		title:SetPosition(20, 16)

		local desc = w:AddChild(Text(CHATFONT, 15, "", UICOLOURS.BROWN_MEDIUM))
		desc:SetPosition(20, -9)
		desc:SetMultilineTruncatedString(STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.UNLOCKED_DESC[string.upper(item.id)], 2, 280, 65, true)

		local atlas = item.atlas or GetInventoryItemAtlas(item.icon)
		local icon = w:AddChild(Image(atlas, item.icon))
		local width, height = icon:GetSize()
		icon:SetScale((item.style == "item" and 0.6) or (item.style == "boss" and 0.5) or 0.6)
		icon:SetPosition(-detail_width / 2 + detail_height / 2 + 5, 0)
	end

	return w
end

function CommunityProgress:BuildDetailsPanel()
    local w = Widget("details_root")

	local spacing_x = 25
	local spacing_y = 15
	local unlockorder = deepcopy(Lavaarena_CommunityProgression:GetUnlockOrder())
	table.remove(unlockorder, 1)
	for i, v in ipairs(unlockorder) do
		local detail = w:AddChild(MakeDetailsEntry(Lavaarena_CommunityProgression:GetUnlockData(v)))
		local x = (((i-1) % 2) - 1) * (detail_width + spacing_x) + detail_width /2
		local y = math.floor((i-1) / 2) * -(detail_height + spacing_y)
		detail:SetPosition(x, y)
	end

	return w
end

function CommunityProgress:_DoFocusHookups()

--	self.parent_default_focus = self
end

return CommunityProgress
