local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
require "os"

local klei_tz = 28800--The time zone offset for vancouver

local Countdown = Class(Widget, function(self, owner)
	Widget._ctor(self, "Countdown")
	self.owner = owner

    self.daysuntilanim = self:AddChild(UIAnim())
    self.daysuntilanim:GetAnimState():SetBuild("build_status")
    self.daysuntilanim:GetAnimState():SetBank("build_status")
    self.daysuntilanim:SetPosition(150, 128, 0)

    self.daysuntiltext = self:AddChild(Text(NUMBERFONT, 30))
    self.daysuntiltext:SetPosition(135, 45, 0)
	self.daysuntiltext:SetRegionSize( 220, 50 )
	self.daysuntiltext:SetClickable(false)

	-- self:DoInit()

end)

local function get_timezone()
  local now = os.time()
  return os.difftime(now, os.time(os.date("!*t", now)))
end

function Countdown:ShouldShowCountdown(date)
	if not date or type(date) ~= "table" then return false end

	local now = os.time() - get_timezone()
	local update_time = os.time(date) - klei_tz
	local build_time = TheSim:GetBuildDate()

	local days_until 		= ((((update_time - now) / 60) / 60) / 24)
	local days_since 		= ((((now - build_time) / 60) / 60) / 24)
	local build_update_diff = ((((build_time - update_time) / 60) / 60) / 24)

	local should_show = false
	if days_until <= 14 and math.ceil(days_until) >= -1 and build_update_diff < 0 then -- Show upcoming/imminent build for 2 weeks
		should_show = true
	elseif days_since <= 2 and days_since >= 0 then
		if math.abs(build_update_diff) <= 2 then
			should_show = true
		end
	end

	if should_show then
		self:SetDisplay(days_until, days_since, build_update_diff)
	end
	return should_show
end

function Countdown:SetDisplay(days_until, days_since, build_update_diff)
	if not days_until and not days_since then return end
	if days_until and days_since then
		if days_until >= 1 then
			self.days_until_string = string.format(STRINGS.UI.MAINSCREEN.NEXTUPDATEDAYS, math.ceil(days_until))
			self.daysuntilanim:GetAnimState():PlayAnimation("about", true)
		end
		if days_until < 1 and days_until >= -1 and build_update_diff < 0 then
			self.days_until_string = string.format(STRINGS.UI.MAINSCREEN.NEXTBUILDIMMINENT)
			self.daysuntilanim:GetAnimState():PlayAnimation("coming", true)
		end
		if days_since <= 2 and days_since >= 0 and math.abs(build_update_diff) <= 2 then
			self.days_until_string = string.format(STRINGS.UI.MAINSCREEN.FRESHBUILD)
			self.daysuntilanim:GetAnimState():PlayAnimation("fresh", true)
		end

		self.daysuntiltext:SetString(self.days_until_string)
	end
end

-- local function GetDaysToUpdate()
--     local local_tz = get_timezone()

--     --It would be nice to pull this from server?
--     local update_times =
-- 		{
-- 			os.time{year=2014, day=5, month=11, hour=13} - klei_tz,
-- 			os.time{year=2014, day=5, month=12, hour=13} - klei_tz,
-- 			os.time{year=2015, day=14, month=1, hour=13} - klei_tz,
-- 			os.time{year=2015, day=14, month=2, hour=13} - klei_tz,
-- 			os.time{year=2015, day=14, month=3, hour=13} - klei_tz,
-- 		}
--     table.sort(update_times)

--     local build_time = TheSim:GetBuildDate()

--     local last_build = build_time
--     local now = os.time() - local_tz

--     for k,v in ipairs(update_times) do
-- 		if v > build_time then
-- 			local seconds = v - now
-- 			return math.ceil( (((seconds / 60) / 60) / 24) ), math.ceil( ((((now - last_build) / 60) / 60) / 24) )
-- 		else
-- 			last_build = v
-- 		end
--     end
-- end

-- function Countdown:DoInit( )

--     local button_spacing = 50
--     local signup_text_size =  40

-- 	local daysuntil_offset = 70

-- 	local days_until, days_since = GetDaysToUpdate()
-- 	if days_until and days_since then
		-- if days_since <= 1 then
		-- 	self.days_since_string = string.format(STRINGS.UI.MAINSCREEN.FRESHBUILD)
		-- else
		-- 	self.days_since_string = string.format(STRINGS.UI.MAINSCREEN.LASTBUILDDAYS, days_since)
		-- end

		-- if days_until < 2 then
		-- 	self.days_until_string = string.format(STRINGS.UI.MAINSCREEN.NEXTBUILDIMMINENT)
		-- else
		-- 	self.days_until_string = string.format(STRINGS.UI.MAINSCREEN.NEXTUPDATEDAYS, days_until)
		-- end

		-- if days_until < 2 then
		-- 	self.daysuntilanim:GetAnimState():PlayAnimation("coming", true)
		-- elseif days_since <= 1 then
		-- 	self.daysuntilanim:GetAnimState():PlayAnimation("fresh", true)
		-- else
		-- 	self.daysuntilanim:GetAnimState():PlayAnimation("about", true)
		-- end

		-- self.daysuntiltext:SetString( self.days_until_string)

		-- self.daysuntilanim:SetMouseOver(function()
		-- 		self.daysuntiltext:SetString( self.days_since_string)
		-- 	end)

		-- self.daysuntilanim:SetMouseOut(function()
		-- 		self.daysuntiltext:SetString( self.days_until_string)
		-- 	end)
-- 	else
-- 		self.daysuntilanim:Hide()
-- 		self.daysuntiltext:Hide()
-- 	end
-- end

return Countdown