local Screen = require "widgets/screen"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
require "os"

local PopupDialogScreen = require "screens/redux/popupdialog"
local FestivalEventScreen = require "screens/redux/festivaleventscreen"
local ModsScreen = require "screens/redux/modsscreen"
local OptionsScreen = require "screens/redux/optionsscreen"
local CompendiumScreen = require "screens/redux/compendiumscreen"
local PlayerSummaryScreen = require "screens/redux/playersummaryscreen"
local QuickJoinScreen = require "screens/redux/quickjoinscreen"
local ServerListingScreen = require "screens/redux/serverlistingscreen"
local ServerSlotScreen = require "screens/redux/serverslotscreen"

local TEMPLATES = require "widgets/redux/templates"

local FriendsManager = require "widgets/friendsmanager"
local OnlineStatus = require "widgets/onlinestatus"
local ThankYouPopup = require "screens/thankyoupopup"
local ItemBoxOpenerPopup = require "screens/redux/itemboxopenerpopup"
local SkinGifts = require("skin_gifts")
local Stats = require("stats")

local MainMenuMotdPanel = require "widgets/redux/mainmenu_motdpanel"
local MainMenuStatsPanel = require "widgets/redux/mainmenu_statspanel"
local PurchasePackScreen = require "screens/redux/purchasepackscreen"

local KitcoonPuppet = require "widgets/kitcoonpuppet"

local SHOW_DST_DEBUG_HOST_JOIN = BRANCH == "dev"
local SHOW_QUICKJOIN = false

local IS_BETA = BRANCH == "staging" or BRANCH == "dev"
local IS_DEV_BUILD = BRANCH == "dev"

local function PlayBannerSound(inst, self, sound)
    if self.bannersoundsenabled then
        TheFrontEnd:GetSound():PlaySound(sound)
    end
end

local function MakeWaterloggedBanner(self, banner_root, anim)
    local anim_bg = banner_root:AddChild(UIAnim())
    anim_bg:GetAnimState():SetBuild("dst_menu_waterlogged")
    anim_bg:GetAnimState():SetBank("dst_menu_waterlogged")
    anim_bg:SetScale(0.667)
    anim_bg:GetAnimState():PlayAnimation("loop", true)
    anim_bg:MoveToBack()
end

local function MakeMoonstormBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_moonstorm_background")
    anim:GetAnimState():SetBank ("dst_menu_moonstorm_background")
    anim:GetAnimState():PlayAnimation("loop_w1", true)
    anim:SetScale(.667)
    anim.inst:ListenForEvent("animover", function()
        anim:GetAnimState():PlayAnimation("loop_w"..math.random(3))
    end)


    local anim_wrench = banner_root:AddChild(UIAnim())
    anim_wrench:GetAnimState():SetBuild("dst_menu_moonstorm_wrench")
    anim_wrench:GetAnimState():SetBank ("dst_menu_moonstorm_wrench")
    anim_wrench:GetAnimState():PlayAnimation("loop_w1", false)
    anim_wrench:SetScale(.667)
    anim_wrench:GetAnimState():SetErosionParams(0.06, 0, -1.0)
    anim_wrench.inst.holo_time = 0
    anim_wrench.inst:DoPeriodicTask(FRAMES, function()
        anim_wrench.inst.holo_time = anim_wrench.inst.holo_time + FRAMES
        anim_wrench:GetAnimState():SetErosionParams(0.06, anim_wrench.inst.holo_time, -1.0)
    end)
    anim_wrench.inst:ListenForEvent("animover", function()
        -- This is a hack to get it to loop in sync with Wilson in the background,
        -- since the Wilson anim isn't set to loop either (it switches randomly
        -- between different animations)
        anim_wrench:GetAnimState():PlayAnimation("loop_w1")
    end)


    local anim_wagstaff = banner_root:AddChild(UIAnim())
    anim_wagstaff:GetAnimState():SetBuild("dst_menu_moonstorm_wagstaff")
    anim_wagstaff:GetAnimState():SetBank ("dst_menu_moonstorm_wagstaff")
    anim_wagstaff:GetAnimState():PlayAnimation("loop_w2", true)
    anim_wagstaff:SetScale(.667)
    anim_wagstaff:GetAnimState():SetErosionParams(1, 0, -1.0)
    anim_wagstaff:GetAnimState():SetMultColour(1, 1, 1, 0.9)

    local wagstaff_erosion_min = 0.02 -- Not 0 so there's always a little bit of influence on the alpha from the lines
    local wagstaff_erosion_max = 1.2 -- Overshoots 1.2 to get more stable alpha lines when close to fully faded out
    local wagstaff_erosion_speed = 1.65
    local wagstaff_visible_time_min = 5.2
    local wagstaff_visible_time_variance = 3.4
    local wagstaff_invisible_time_min = 8
    local wagstaff_invisible_time_variance = 5.7
    --
    anim_wagstaff.inst.holo_time = 0
    anim_wagstaff.inst.holo_erosion = 1
    anim_wagstaff.inst.holo_fade_in = false
    anim_wagstaff.inst.holo_position = math.random(3)
    anim_wagstaff.inst:DoPeriodicTask(FRAMES, function()
        if anim_wagstaff.inst.holo_fade_in then
            anim_wagstaff.inst.holo_erosion = math.max(wagstaff_erosion_min, anim_wagstaff.inst.holo_erosion - FRAMES * wagstaff_erosion_speed)
        else
            anim_wagstaff.inst.holo_erosion = math.min(wagstaff_erosion_max, anim_wagstaff.inst.holo_erosion + FRAMES * wagstaff_erosion_speed)
        end
        anim_wagstaff.inst.holo_time = anim_wagstaff.inst.holo_time + FRAMES
        anim_wagstaff:GetAnimState():SetErosionParams(anim_wagstaff.inst.holo_erosion, anim_wagstaff.inst.holo_time, -1)
    end)
    local holo_fade_in
    local holo_fade_out
    holo_fade_out = function(inst)
        anim_wagstaff.inst.holo_fade_in = false

        inst:DoTaskInTime(wagstaff_invisible_time_min + wagstaff_invisible_time_variance * math.random(), holo_fade_in)
    end
    holo_fade_in = function(inst)
        anim_wagstaff.inst.holo_fade_in = true
        anim_wagstaff.inst.holo_time = 0

        local anim_variations = {[1] = 1, [2] = 1, [3] = 1}
        anim_variations[anim_wagstaff.inst.holo_position] = 0
        anim_wagstaff.inst.holo_position = weighted_random_choice(anim_variations)
        anim_wagstaff:GetAnimState():PlayAnimation("loop_w"..anim_wagstaff.inst.holo_position, true)

        if anim_wagstaff.inst.holo_position == 1 and IsConsole() then
            anim_wagstaff:GetAnimState():PlayAnimation("loop_w1_console", true)
        end

        anim_wagstaff.inst:DoTaskInTime(wagstaff_visible_time_min + wagstaff_visible_time_variance * math.random(), holo_fade_out)
    end
    anim_wagstaff.inst:DoTaskInTime(1.5 + wagstaff_invisible_time_min * math.random() + wagstaff_invisible_time_variance * math.random(), holo_fade_in)


    local anim_foreground = banner_root:AddChild(UIAnim())
    anim_foreground:GetAnimState():SetBuild("dst_menu_moonstorm_foreground")
    anim_foreground:GetAnimState():SetBank ("dst_menu_moonstorm_foreground")
    anim_foreground:GetAnimState():PlayAnimation("loop_w"..math.random(3), true)
    anim_foreground:SetScale(.667)
    anim_foreground.inst:ListenForEvent("animover", function()
        anim_foreground:GetAnimState():PlayAnimation("loop_w"..math.random(3))
    end)
end

local function MakeYOTCBanner(self, banner_root, anim)
    local anim_bg = banner_root:AddChild(UIAnim())
    anim_bg:GetAnimState():SetBuild("dst_menu_carrat_bg")
    anim_bg:GetAnimState():SetBank("dst_carrat_bg")
    anim_bg:SetScale(0.7)
    anim_bg:GetAnimState():PlayAnimation("loop", true)
    anim_bg:MoveToBack()

    anim:GetAnimState():SetBuild("dst_menu_carrat")
    anim:GetAnimState():SetBank("dst_carrat")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(0.6)

    local colors ={
        "blue",
        "brown",
        "pink",
        "purple",
        "yellow",
        "green",
        "white",
        nil, -- normal?
        }

    local color = colors[math.random(1,#colors)]

    if color then
        anim:GetAnimState():OverrideSymbol("ear1", "dst_menu_carrat_swaps", color.."_ear1")
        anim:GetAnimState():OverrideSymbol("ear2", "dst_menu_carrat_swaps", color.."_ear2")
        anim:GetAnimState():OverrideSymbol("tail", "dst_menu_carrat_swaps", color.."_tail")
    end
end

local function MakeYOTDBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_yotd")
    anim:GetAnimState():SetBank ("dst_menu_yotd")
    anim:SetScale(.667)
    anim:GetAnimState():PlayAnimation("loop", true)
end

local function MakeYOTCatcoonBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_yot_catcoon")
    anim:GetAnimState():SetBank ("dst_menu_yot_catcoon")
    anim:SetScale(.667)
    anim:GetAnimState():PlayAnimation("loop", true)
end

local function MakeYOTRBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_yotr")
    anim:GetAnimState():SetBank ("dst_menu_yotr")
    anim:SetScale(.667)
    anim:GetAnimState():PlayAnimation("loop", true)
end

local function MakeHallowedNightsBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_halloween2")
    anim:GetAnimState():SetBank ("dst_menu_halloween2")
    anim:SetScale(.667)
    anim:GetAnimState():PlayAnimation("loop", true)
end

local function MakeCawnivalBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_carnival")
    anim:GetAnimState():SetBank ("dst_menu_carnival")
    anim:SetScale(.667)
    anim:GetAnimState():PlayAnimation("loop", true)
end

local function MakeWebberCawnivalBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_webber_carnival")
    anim:GetAnimState():SetBank ("dst_menu_webber")
    anim:SetScale(.667)
    anim:GetAnimState():PlayAnimation("loop", true)
end

local function MakeWesV1Banner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_wes")
    anim:GetAnimState():SetBank("dst_menu_wes")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakeWesV2Banner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_wes2")
    anim:GetAnimState():SetBank ("dst_menu_wes2")
    anim:SetScale(.667)
    anim:GetAnimState():PlayAnimation("loop", true)
end

local function MakeWendyBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_wendy")
    anim:GetAnimState():SetBank("dst_menu_wendy")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakeWebberBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_webber")
    anim:GetAnimState():SetBank ("dst_menu_webber")
    anim:SetScale(.667)
    anim:GetAnimState():PlayAnimation("loop", true)
end

local function MakeWandaBanner(self, banner_root, anim)
    local anim_bg = banner_root:AddChild(UIAnim())
    anim_bg:GetAnimState():SetBuild("dst_menu_wanda")
    anim_bg:GetAnimState():SetBank("dst_menu_wanda")
    anim_bg:SetScale(0.667)
    anim_bg:GetAnimState():PlayAnimation("loop_"..math.random(3), true)
    anim_bg:MoveToBack()
end

local function MakeTerrariaBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_terraria")
    anim:GetAnimState():SetBank("dst_menu_terraria")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local WOLFGANG_STATES = {"wimpy", "mid", "mighty"}
local function MakeWolfgangBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_wolfgang")
    anim:GetAnimState():SetBank("dst_menu_wolfgang")
    anim:GetAnimState():PlayAnimation("loop", true)

    local wolfgang_state_index = math.random(3)
    for i, state in ipairs(WOLFGANG_STATES) do
        if i == wolfgang_state_index then
            anim:GetAnimState():Show(WOLFGANG_STATES[i])
        else
            anim:GetAnimState():Hide(WOLFGANG_STATES[i])
        end
    end
    anim:SetScale(.667)
end

local function MakeWX78Banner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_wx")
    anim:GetAnimState():SetBank("dst_menu_wx")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakeWickerbottomBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_wickerbottom")
    anim:GetAnimState():SetBank ("dst_menu_wickerbottom")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakePiratesBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_pirates")
    anim:GetAnimState():SetBank("dst_menu_pirates")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakeDramaBanner(self, banner_root, anim)
    local anim_bg = banner_root:AddChild(UIAnim())
    anim_bg:GetAnimState():SetBuild("dst_menu_charlie2")
    anim_bg:GetAnimState():SetBank("dst_menu_charlie2")
    anim_bg:GetAnimState():PlayAnimation("loop_bg", true)
    anim_bg:SetScale(0.667)
    anim_bg:MoveToBack()

	if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
		anim:GetAnimState():SetBuild("dst_menu_charlie_halloween")
		anim:GetAnimState():SetBank ("dst_menu_charlie_halloween")
	else
		anim:GetAnimState():SetBuild("dst_menu_charlie")
		anim:GetAnimState():SetBank ("dst_menu_charlie")
	end
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(0.667)
end

local function MakeWaxwellBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_waxwell")
    anim:GetAnimState():SetBank("dst_menu_waxwell")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakeWilsonBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_wilson")
    anim:GetAnimState():SetBank("dst_menu_wilson")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakeLunarRiftBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_lunarrifts")
    anim:GetAnimState():SetBank("dst_menu_lunarrifts")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakeShadowRiftBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_rift2")
    anim:GetAnimState():SetBank("dst_menu_rift2")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakeMeta2Banner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_meta2_cotl")
    anim:GetAnimState():SetBank("dst_menu_meta2")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakeLunarMutantsBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_rift3_BG")
    anim:GetAnimState():SetBank("dst_menu_rift3_BG")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
    anim:GetAnimState():Hide("HOLLOW")

    local anim_front = banner_root:AddChild(UIAnim())
    anim_front:GetAnimState():SetBuild("dst_menu_rift3")
    anim_front:GetAnimState():SetBank ("dst_menu_rift3")
    anim_front:GetAnimState():PlayAnimation("loop", true)
    anim_front:SetScale(.667)
    anim_front:GetAnimState():Hide("HOLLOW")
end

local function MakeMeta3Banner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_meta3")
    anim:GetAnimState():SetBank("dst_menu_meta3")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakeRiftsMetaQoLBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_riftsqol")
    anim:GetAnimState():SetBank("banner")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)
end

local function MakeLunarMutantsBanner_hallowednights(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_rift3_BG")
    anim:GetAnimState():SetBank("dst_menu_rift3_BG")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)

    local anim_front = banner_root:AddChild(UIAnim())
    anim_front:GetAnimState():SetBuild("dst_menu_rift3")
    anim_front:GetAnimState():SetBank ("dst_menu_rift3")
    anim_front:GetAnimState():PlayAnimation("loop", true)
    anim_front:SetScale(.667)
end

local function MakeWurtWinonaQOLBanner(self, banner_root, anim)
    anim:GetAnimState():SetBuild("dst_menu_winona_wurt")
    anim:GetAnimState():SetBank("dst_menu_winona_wurt")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)

    local anim_front = banner_root:AddChild(UIAnim())
    anim_front:GetAnimState():SetBuild("dst_menu_winona_wurt_carnival_foreground")
    anim_front:GetAnimState():SetBank ("dst_menu_winona_wurt")
    anim_front:GetAnimState():PlayAnimation("loop_foreground", true)
    anim_front:SetScale(.667)  
end


local function MakeDefaultBanner(self, banner_root, anim)
	local banner_height = 350
	banner_root:SetPosition(0, RESOLUTION_Y / 2 - banner_height / 2 + 1 ) -- positioning for when we had the top banner art

    local anim_bg = banner_root:AddChild(UIAnim())
    anim_bg:GetAnimState():SetBuild("dst_menu_v2_bg")
    anim_bg:GetAnimState():SetBank("dst_menu_v2_bg")
    anim:SetScale(.667)
    anim_bg:GetAnimState():PlayAnimation("loop", true)
    anim_bg:MoveToBack()

    anim:GetAnimState():SetBuild("dst_menu_v2")
    anim:GetAnimState():SetBank("dst_menu_v2")
    anim:GetAnimState():PlayAnimation("loop", true)
    anim:SetScale(.667)

    local creatures =
    {
        "creature_cookie",
        "creature_squid",
        "creature_gnarwail",
        "creature_puffin",
        "creature_hound",
        "creature_malbatross",
    }

    for _,v in pairs(creatures) do
        anim:GetAnimState():Hide(v)
    end

    local c1 = creatures[math.random(1,#creatures)]
    local c2 = creatures[math.random(1,#creatures)]
    local c3 = creatures[math.random(1,#creatures)]

    --could end up with dupes picked, that's okay, then we'll have only 1 or 2 chosen
    anim:GetAnimState():Show(c1)
    anim:GetAnimState():Show(c2)
    anim:GetAnimState():Show(c3)
end

function MakeBanner(self)
	local title_str = nil

	local banner_root = Widget("banner_root")
	banner_root:SetPosition(0, 0)
	local anim = banner_root:AddChild(UIAnim())

	if IS_BETA then
		title_str = STRINGS.UI.MAINSCREEN.MAINBANNER_BETA_TITLE

		--*** !!! ***
		--REMINDER: Banner changes in beta need to go in the default "else" block below too!
		--
		--REMINDER: Check MakeBannerFront as well!
		--
        MakeWurtWinonaQOLBanner(self, banner_root, anim)
    elseif IsSpecialEventActive(SPECIAL_EVENTS.YOTD) then
        MakeYOTDBanner(self, banner_root, anim)
    elseif IsSpecialEventActive(SPECIAL_EVENTS.YOTR) then
        MakeYOTRBanner(self, banner_root, anim)
	elseif IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
        MakeYOTCBanner(self, banner_root, anim)
	elseif IsSpecialEventActive(SPECIAL_EVENTS.YOT_CATCOON) then
        MakeYOTCatcoonBanner(self, banner_root, anim)
	elseif IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
		--MakeDramaBanner(self, banner_root, anim)
        --MakeHallowedNightsBanner(self, banner_root, anim)
        MakeMeta3Banner(self, banner_root, anim)
	elseif IsSpecialEventActive(SPECIAL_EVENTS.CARNIVAL) then

        --MakeMeta2Banner(self, banner_root, anim)
        --MakeCawnivalBanner(self, banner_root, anim)
        MakeWurtWinonaQOLBanner(self, banner_root, anim)
	else
		--*** !!! ***
		--REMINDER: Check MakeBannerFront as well!
		--
        MakeWurtWinonaQOLBanner(self, banner_root, anim)
        --MakeRiftsMetaQoLBanner(self, banner_root, anim)
		--MakeMeta2Banner(self, banner_root, anim)
        --MakeDramaBanner(self, banner_root, anim)
        --MakeDefaultBanner(self, banner_root, anim)
        --MakePiratesBanner(self, banner_root, anim)
        --MakeWX78Banner(self, banner_root, anim)
        --[[
		local cur_time = os.time()
		if cur_time <= 1585810740 and (not IsConsole() or cur_time >= 1585759200) then -- 9:40am to 11:59pm PDT
            MakeWesV1Banner(self, banner_root, anim)
		else
            MakeWendyBanner(self, banner_root, anim)
        end
        ]]
	end

    if title_str ~= nil then
        local x, y = 170, 19
        local text_width = 880
        local font_size = 22

        local shadow = banner_root:AddChild(Text(self.info_font, font_size, title_str, UICOLOURS.BLACK))
        local title  = banner_root:AddChild(Text(self.info_font, font_size, title_str, UICOLOURS.HIGHLIGHT_GOLD))

        shadow:SetRegionSize(text_width, 2*(font_size + 2))
        title:SetRegionSize(text_width, 2*(font_size + 2))
        shadow:SetHAlign(ANCHOR_RIGHT)
        title:SetHAlign(ANCHOR_RIGHT)
        
        shadow:SetPosition(x + 2, y - 2)
        title:SetPosition(x, y)
    end

    return banner_root
end

--------------------------------------------------------------------------------

local function MakeWX78BannerFront(self, banner_front, anim)
    anim:GetAnimState():SetBuild("dst_menu_wx")
    anim:GetAnimState():SetBank("dst_menu_wx")
    anim:GetAnimState():PlayAnimation("loop_top", true)
    anim:SetScale(0.667)
end

local function MakeDramaBannerFront(self, banner_front, anim)
	if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
		anim:GetAnimState():SetBuild("dst_menu_charlie_halloween")
		anim:GetAnimState():SetBank ("dst_menu_charlie_halloween")
	else
		anim:GetAnimState():SetBuild("dst_menu_charlie")
		anim:GetAnimState():SetBank ("dst_menu_charlie")
	end
    anim:GetAnimState():PlayAnimation("overlay", true)
    anim:SetScale(0.667)
end

local function MakeWinonaWurtCarnivalBannerFront(self, banner_front, anim)
    anim:GetAnimState():SetBuild("dst_menu_winona_wurt_carnival_foreground")
    anim:GetAnimState():SetBank ("dst_menu_winona_wurt")

    anim:GetAnimState():PlayAnimation("loop_foreground", true)
    anim:SetScale(0.667)
end

-- For drawing things in front of the MOTD panels
local function MakeBannerFront(self)
    if IS_BETA then
		--*** !!! ***
		--REMINDER: Banner changes in beta need to go in the default "else" block below too!
		--

        --[[local banner_front = Widget("banner_front")
        banner_front:SetPosition(0, 0)
        banner_front:SetClickable(false)
        local anim = banner_front:AddChild(UIAnim())

        MakeDramaBannerFront(self, banner_front, anim)

        return banner_front]]

        local banner_front = Widget("banner_front")
        banner_front:SetPosition(0, 0)
        banner_front:SetClickable(false)
        local anim = banner_front:AddChild(UIAnim())

        MakeWinonaWurtCarnivalBannerFront(self, banner_front, anim)
        
        return banner_front

    elseif IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
        return nil
    elseif IsSpecialEventActive(SPECIAL_EVENTS.YOT_CATCOON) then
        return nil
    elseif IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
        local banner_front = Widget("banner_front")
        banner_front:SetPosition(0, 0)
        banner_front:SetClickable(false)
        local anim = banner_front:AddChild(UIAnim())

        MakeDramaBannerFront(self, banner_front, anim)

        return banner_front

    elseif IsSpecialEventActive(SPECIAL_EVENTS.CARNIVAL) then

        local banner_front = Widget("banner_front")
        banner_front:SetPosition(0, 0)
        banner_front:SetClickable(false)
        local anim = banner_front:AddChild(UIAnim())

        MakeWinonaWurtCarnivalBannerFront(self, banner_front, anim)
        
        return banner_front
    else
        --[[local banner_front = Widget("banner_front")
        banner_front:SetPosition(0, 0)
        local anim = banner_front:AddChild(UIAnim())

        MakeWickerbottomBannerFront(self, banner_front, anim)
        
        return banner_front]]
        return nil
    end
end

local MultiplayerMainScreen = Class(Screen, function(self, prev_screen, profile, offline, session_data)
	Screen._ctor(self, "MultiplayerMainScreen")

	self.info_font = BODYTEXTFONT -- CHATFONT, FALLBACK_FONT, CHATFONT_OUTLINE

    --kitcoon stuff in the UI
	PostProcessor:SetColourCubeData( 0, "images/colour_cubes/day05_cc.tex", "images/colour_cubes/dusk03_cc.tex" )
	PostProcessor:SetColourCubeLerp( 0, 0.05 )
	TheSim:SetVisualAmbientColour( 0.6, 0.6, 0.6 )

    self.profile = profile
    self.offline = offline
    self.session_data = session_data
	self.log = true
    self.prev_screen = prev_screen
	self:DoInit()
	self.default_focus = self.menu

    TheGenericKV:ApplyOnlineProfileData() -- Applies the data after synchronization in login flow if applicable.
end)

function MultiplayerMainScreen:GotoShop( filter_info )
	if (TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) then
		local error_message
		if TheInventory:HasSupportForOfflineSkins() then
			error_message = STRINGS.UI.MAINSCREEN.STORE_DISABLE
		else
			error_message = STRINGS.UI.MAINSCREEN.ITEMCOLLECTION_DISABLE
		end
		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.OFFLINE, error_message, 
			{
				{text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_LOGIN, cb = function()
						SimReset()
					end},
				{text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BACK, cb=function() TheFrontEnd:PopScreen() end },
			}))
	else
		self:StopMusic()
		self:_FadeToScreen(PurchasePackScreen, {Profile, filter_info})
	end
end


function MultiplayerMainScreen:getStatsPanel()
    return MainMenuStatsPanel({store_cb = function()
        if not TheInventory:HasSupportForOfflineSkins() and (TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) then
            TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.OFFLINE, STRINGS.UI.MAINSCREEN.ITEMCOLLECTION_DISABLE,
                {
                    {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_LOGIN, cb = function()
                            SimReset()
                        end},
                    {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BACK, cb=function() TheFrontEnd:PopScreen() end },
                }))
        else
            self:StopMusic()
            self:_FadeToScreen(PurchasePackScreen, {Profile})
        end
    end
    })
end
function MultiplayerMainScreen:DoInit()
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

	self.banner_root = self.fixed_root:AddChild(MakeBanner(self))

	self.sidebar = self.fixed_root:AddChild(Image("images/bg_redux_black_sidebar.xml", "black_sidebar.tex"))
	self.sidebar:SetPosition(-RESOLUTION_X/2 + 180, 0)
	self.sidebar:SetScale(0.95, 1.01)
	self.sidebar:SetTint(0, 0, 0, .85)

	self.build_number = TEMPLATES.AddBuildString(self.fixed_root, {x = RESOLUTION_X * .5 - 150, y = -RESOLUTION_Y * .5 + 20, size = 18, align = ANCHOR_RIGHT, w = 250, h = 45, colour = UICOLOURS.GOLD_UNIMPORTANT})

	if IsFestivalEventActive(FESTIVAL_EVENTS.LAVAARENA) then
		self.logo = self.fixed_root:AddChild(Image("images/lavaarena_frontend.xml", "title.tex"))
		self.logo:SetScale(.6)
		self.logo:SetPosition( -RESOLUTION_X/2 + 180, 5)
	else
		self.logo = self.fixed_root:AddChild(Image("images/frontscreen.xml", "title.tex"))
		self.logo:SetScale(.36)
		self.logo:SetPosition( -RESOLUTION_X/2 + 180, RESOLUTION_Y / 2 - 170)
		self.logo:SetTint(unpack(FRONTEND_TITLE_COLOUR))
	end

    self:MakeMainMenu()
	self:MakeSubMenu()

    self.onlinestatus = self.fixed_root:AddChild(OnlineStatus( true ))

    --TODO(Peter) put the snowflakes back in after 2021
	--[
    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
		self.banner_snowfall = self.banner_root:AddChild(TEMPLATES.old.Snowfall(-.39 * RESOLUTION_Y, .35, 3, 15))
		self.banner_snowfall:SetVAnchor(ANCHOR_TOP)
		self.banner_snowfall:SetHAnchor(ANCHOR_MIDDLE)
		self.banner_snowfall:SetScaleMode(SCALEMODE_PROPORTIONAL)

		self.snowfall = self.fixed_root:AddChild(TEMPLATES.old.Snowfall(-.97 * RESOLUTION_Y, .15, 5, 20))
		self.snowfall:SetVAnchor(ANCHOR_TOP)
		self.snowfall:SetHAnchor(ANCHOR_MIDDLE)
		self.snowfall:SetScaleMode(SCALEMODE_PROPORTIONAL)
	end
    --]

    ----------------------------------------------------------
	-- new MOTD

    local kit_puppet_positions = {
        { x = 90.0, y = -25.0, scale = 0.75 },
        { x = 390.0, y = -25.0, scale = 0.75 },
    }
    self.kit_puppet = self.fixed_root:AddChild(KitcoonPuppet( Profile, nil, kit_puppet_positions ))

	if TheFrontEnd.MotdManager:IsEnabled() then
		local motd_panel = MainMenuMotdPanel({font = self.info_font, x = 100, y = -180,
			on_no_focusforward = self.menu,
			on_to_skins_cb = function( filter_info ) self:GotoShop( filter_info ) end,
			})
		if self.motd_panel == nil then
            motd_panel:SetScale(0.84)
			self.motd_panel = self.fixed_root:AddChild(motd_panel)
		end
	else
		self.motd_panel = self.fixed_root:AddChild(self:getStatsPanel())
	end

    if IsAnyFestivalEventActive() then
        if TheInventory:HasSupportForOfflineSkins() or not TheFrontEnd:GetIsOfflineMode() then
			self.userprogress = self.fixed_root:AddChild(TEMPLATES.UserProgress(function()
				self:OnPlayerSummaryButton()
			end))
		end
    end

    ----------------------------------------------------------

    local banner_front = MakeBannerFront(self)
    if banner_front ~= nil then
        self.banner_front = self.fixed_root:AddChild(banner_front)
        self.banner_front:MoveToFront()
    end

    ----------------------------------------------------------

	self:DoFocusHookups()
    self.menu:SetFocus(#self.menu.items)

    --V2C: This is so the first time we become active will trigger OnShow to UpdatePuppets
    self:Hide()
end

function MultiplayerMainScreen:DoFocusHookups()
    --focus moving
    self.submenu:SetFocusChangeDir(MOVE_UP, self.menu.items[1])
    self.menu:SetFocusChangeDir(MOVE_DOWN, self.submenu)

    if self.debug_menu then
        self.menu:SetFocusChangeDir(MOVE_UP, self.debug_menu, -1)
        self.menu:SetFocusChangeDir(MOVE_RIGHT, self.debug_menu, -1)
        self.debug_menu:SetFocusChangeDir(MOVE_LEFT, self.menu)
    end

	self.menu:SetFocusChangeDir(MOVE_RIGHT, self.motd_panel)
	self.motd_panel:SetFocusChangeDir(MOVE_LEFT, self.menu)
end

function MultiplayerMainScreen:OnControl(control, down)
    if MultiplayerMainScreen._base.OnControl(self, control, down) then return true end

    if self.motd_panel ~= nil and self.motd_panel:OnControl(control, down) then return true end
end

function MultiplayerMainScreen:EnableBannerSounds(enable)
    self.bannersoundsenabled = enable
end

function MultiplayerMainScreen:OnShow()
    self._base.OnShow(self)
    if self.snowfall ~= nil then
        self.snowfall:EnableSnowfall(not (TheSim:IsNetbookMode() or TheFrontEnd:GetGraphicsOptions():IsSmallTexturesMode()))
        self.snowfall:StartSnowfall()
    end
    if self.banner_snowfall ~= nil then
        self.banner_snowfall:EnableSnowfall(not (TheSim:IsNetbookMode() or TheFrontEnd:GetGraphicsOptions():IsSmallTexturesMode()))
        self.banner_snowfall:StartSnowfall()
    end
    self:EnableBannerSounds(true)

    TheSim:PauseFileExistsAsync(false)
end

function MultiplayerMainScreen:OnHide()
    self._base.OnHide(self)
    if self.snowfall ~= nil then
        self.snowfall:StopSnowfall()
    end
    if self.banner_snowfall ~= nil then
        self.banner_snowfall:StopSnowfall()
    end
    self:EnableBannerSounds(false)
end

function MultiplayerMainScreen:OnDestroy()
    self:OnHide()
    self._base.OnDestroy(self)
end

function MultiplayerMainScreen:OnRawKey(key, down)
end

function MultiplayerMainScreen:_FadeToScreen(screen_ctor, data)
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true --Note(Peter): what is this even used for?!?

    TheFrontEnd:FadeToScreen( self, function() return screen_ctor(self, unpack(data)) end, nil )
end

--------------------------------------------------------------------------------
--V2C: Peter: Currently only "screens with their own music" transitions use these music helpers

function MultiplayerMainScreen:StopMusic()
    if not self.musicstopped then
        self.musicstopped = true
        TheFrontEnd:GetSound():KillSound("FEMusic")
        --TheFrontEnd:GetSound():KillSound("FEPortalSFX")
    elseif self.musictask ~= nil then
        self.musictask:Cancel()
        self.musictask = nil
    end
end

local function OnStartMusic(inst, self)
    self.musictask = nil
    self.musicstopped = false
    TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
    --TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/portal_idle_vines", "FEPortalSFX")
end

function MultiplayerMainScreen:StartMusic()
    TheFrontEnd:GetSound():SetParameter("FEMusic", "fade", 0)
    if self.musicstopped and self.musictask == nil then
        self.musictask = self.inst:DoTaskInTime(1.25, OnStartMusic, self)
    end
end

--------------------------------------------------------------------------------
function MultiplayerMainScreen:_GoToFestfivalEventScreen(fadeout_cb)
    if GetFestivalEventInfo().FEMUSIC ~= nil then
        self:StopMusic() --only stop the main menu music if we have something for the next screeen
    end

	self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true --Note(Peter): what is this even used for?!?

    TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
		if fadeout_cb ~= nil then
			fadeout_cb()
		end
        TheFrontEnd:PushScreen(FestivalEventScreen(self, self.session_data))
        TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
        self:Hide()
    end)
end

function MultiplayerMainScreen:OnFestivalEventButton()
    if not TheInventory:HasSupportForOfflineSkins() and (TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_TITLE, STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BODY[WORLD_FESTIVAL_EVENT],
            {
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_LOGIN, cb = function()
                        SimReset()
                    end},
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BACK, cb=function() TheFrontEnd:PopScreen() end },
            }))
    else
		if AreAnyModsEnabled() and not KnownModIndex:GetIsSpecialEventModWarningDisabled() then
			local popup_body = subfmt(STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_BODY, {event=STRINGS.UI.GAMEMODES[string.upper(GetFestivalEventInfo().GAME_MODE)]})
			TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_TITLE, popup_body,
				{
					{text=STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_DISABLE_MODS, cb = function()
							self:Disable()
                            KnownModIndex:DisableAllMods()
                            ForceAssetReset()
                            KnownModIndex:SetDisableSpecialEventModWarning()
                            KnownModIndex:Save(function()
                                SimReset()
                            end)
						end},
					{text=STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_CONTINUE, cb=function()
						    KnownModIndex:SetDisableSpecialEventModWarning()
                            KnownModIndex:Save(function()
								self:_GoToFestfivalEventScreen(function() TheFrontEnd:PopScreen() end)
							end)
						end},
					{text=STRINGS.UI.FESTIVALEVENTSCREEN.MODS_POPUP_CANCEL, cb=function()
								TheFrontEnd:PopScreen()
						end},
				}))
		else
			self:_GoToFestfivalEventScreen()
		end

	end
end

function MultiplayerMainScreen:OnCreateServerButton()
    self:_GoToOnlineScreen(ServerSlotScreen, {})
end

function MultiplayerMainScreen:_GoToOnlineScreen(screen_ctor, data)
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true --Note(Peter): what is this even used for?!?
    TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
        Profile:ShowedNewUserPopup()
        Profile:Save(function()
            TheFrontEnd:PushScreen(screen_ctor(self, unpack(data)))
            TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
            self:Hide()
        end)
    end)
end

function MultiplayerMainScreen:OnBrowseServersButton()
    if self:CheckNewUser(self.OnBrowseServersButton, STRINGS.UI.MAINSCREEN.NEWUSER_NO) then
        return
    end

    local function cb(filters)
	    self.filter_settings = filters
    end

	if not self.filter_settings then
		self.filter_settings = Profile:GetSavedFilters()
	end

    if self.filter_settings and #self.filter_settings > 0 then
        for i,v in pairs(self.filter_settings) do
			if v.name == "SHOWLAN" then
				v.data = self.offline
			end
		end
    else
        self.filter_settings = {}
        table.insert(self.filter_settings, {name = "SHOWLAN", data=self.offline} )
    end

    self:_GoToOnlineScreen(ServerListingScreen, { self.filter_settings, cb, self.offline, self.session_data })
end

function MultiplayerMainScreen:OnPlayerSummaryButton()
    if not TheInventory:HasSupportForOfflineSkins() and (TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.OFFLINE, STRINGS.UI.MAINSCREEN.ITEMCOLLECTION_DISABLE,
            {
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_LOGIN, cb = function()
                        SimReset()
                    end},
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BACK, cb=function() TheFrontEnd:PopScreen() end },
            }))
    else
        self:StopMusic()
        self:_FadeToScreen(PlayerSummaryScreen, {Profile})
    end
end

function MultiplayerMainScreen:OnCompendiumButton()
    self:_FadeToScreen(CompendiumScreen, {self})
end

function MultiplayerMainScreen:OnQuickJoinServersButton()
    if self:CheckNewUser(self.OnQuickJoinServersButton, STRINGS.UI.MAINSCREEN.NEWUSER_NO_QUICKJOIN) then
        return
    end

    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true

    -- QuickJoin is a popup, so don't fade to it.
    TheFrontEnd:PushScreen(QuickJoinScreen(self, self.offline, self.session_data,
		"",
		CalcQuickJoinServerScore,
		function() self:OnCreateServerButton() end,
		function() self:OnBrowseServersButton() end))
end


function MultiplayerMainScreen:Settings( default_section )
    self:_FadeToScreen(OptionsScreen, {default_section})
end

function MultiplayerMainScreen:OnModsButton()
    self:_FadeToScreen(ModsScreen, {})
end

function MultiplayerMainScreen:Quit()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    TheFrontEnd:PushScreen(PopupDialogScreen(
            STRINGS.UI.MAINSCREEN.ASKQUIT,
            STRINGS.UI.MAINSCREEN.ASKQUITDESC,
            {
                { text=STRINGS.UI.MAINSCREEN.YES, cb = function() RequestShutdown() end },
                { text=STRINGS.UI.MAINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end },
            }
        ))
end

function MultiplayerMainScreen:OnHostButton()
    ShardSaveGameIndex:LoadSlotEnabledServerMods()
    KnownModIndex:Save()
    local start_in_online_mode = false
    local slot = 1
    if TheNet:StartServer(start_in_online_mode, slot, ShardSaveGameIndex:GetSlotServerData(slot)) then
        DisableAllDLC()
        local shift_down = TheInput:IsKeyDown(KEY_SHIFT)
        if shift_down or TheInput:IsKeyDown(KEY_CTRL) then
            ShardSaveGameIndex:DeleteSlot(
                slot,
                function() if TheSim:EnsureShardIndexPathExists(slot) then StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = slot }) end end,
                shift_down -- true causes world gen options to be preserved, false causes world gen options to be wiped!
            )
        else
            StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot =  slot })
        end
    end
end

function MultiplayerMainScreen:OnJoinButton()
	local start_worked = TheNet:StartClient(DEFAULT_JOIN_IP)
	if start_worked then
        DisableAllDLC()
	end
	ShowLoading()
end

function MultiplayerMainScreen:MakeMainMenu()
    -- There's no Back on main menu, so menu and tooltip positions are shifted.
    self.menu_root = self.fixed_root:AddChild(Widget("menu_root"))
    self.menu_root:SetPosition(0,-95)

--    self.tooltip = self.menu_root:AddChild(TEMPLATES.ScreenTooltip())
--    self.tooltip:SetPosition( -(RESOLUTION_X*.5)+220, -(RESOLUTION_Y*.5)+157 )
--    self.tooltip:SetRegionSize(300,100)

    local function MakeMainMenuButton(text, onclick, tooltip_text, tooltip_widget)
        local btn = TEMPLATES.MenuButton(text, onclick, tooltip_text, tooltip_widget)
        return btn
    end

    local browse_button		= MakeMainMenuButton(STRINGS.UI.MAINSCREEN.BROWSE,    function() self:OnBrowseServersButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_BROWSE, self.tooltip)
    local host_button		= MakeMainMenuButton(STRINGS.UI.MAINSCREEN.CREATE,    function() self:OnCreateServerButton() end,  STRINGS.UI.MAINSCREEN.TOOLTIP_HOST, self.tooltip)
    local summary_button	= MakeMainMenuButton(STRINGS.UI.PLAYERSUMMARYSCREEN.TITLE, function() self:OnPlayerSummaryButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_PLAYERSUMMARY, self.tooltip)
    local compendium_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.COMPENDIUM, function() self:OnCompendiumButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_COMPENDIUM, self.tooltip)
    local options_button	= MakeMainMenuButton(STRINGS.UI.MAINSCREEN.OPTIONS,   function() self:Settings() end,              STRINGS.UI.MAINSCREEN.TOOLTIP_OPTIONS, self.tooltip)
    local quit_button		= MakeMainMenuButton(STRINGS.UI.MAINSCREEN.QUIT,      function() self:Quit() end,                  STRINGS.UI.MAINSCREEN.TOOLTIP_QUIT, self.tooltip)

	local menu_items = {
        {widget = quit_button},
        {widget = options_button},
        {widget = compendium_button},
        {widget = summary_button},
        {widget = host_button},
        {widget = browse_button},
    }

	if IsConsole() then
		local shop_button = MakeMainMenuButton(STRINGS.UI.PLAYERSUMMARYSCREEN.PURCHASE, function() self:GotoShop() end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_PURCHASE, self.tooltip)
		table.insert(menu_items, 2, {widget = shop_button})
	end

    if MODS_ENABLED then
        local mods_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.MODS, function() self:OnModsButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_MODS, self.tooltip)
        -- Mods should appear above quit (the last menu option).
        table.insert(menu_items, 2, {widget = mods_button})
    end
	if SHOW_QUICKJOIN and not TheFrontEnd:GetIsOfflineMode() and not IsAnyFestivalEventActive() then
        local quickjoin_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.QUICKJOIN, function() self:OnQuickJoinServersButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_QUICKJOIN, self.tooltip)
		table.insert(menu_items, {widget = quickjoin_button})
	end
    if IsAnyFestivalEventActive() then
        local festival_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.FESTIVALEVENT[string.upper(WORLD_FESTIVAL_EVENT)], function() self:OnFestivalEventButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_FESTIVALEVENT[string.upper(WORLD_FESTIVAL_EVENT)], self.tooltip)
        -- Event should appear first in the menu.
        table.insert(menu_items, {widget = festival_button})
    end

    self.menu = self.menu_root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))

    -- For Debugging/Testing
    if SHOW_DST_DEBUG_HOST_JOIN then
		local debug_menu_items = {}
        table.insert( debug_menu_items, {text=STRINGS.UI.MAINSCREEN.JOIN, cb= function() self:OnJoinButton() end})
        table.insert( debug_menu_items, {text=STRINGS.UI.MAINSCREEN.HOST, cb= function() self:OnHostButton() end})

		self.debug_menu = self.fixed_root:AddChild(Menu(debug_menu_items, 74))
		self.debug_menu:SetPosition(-450, 250)
		self.debug_menu:SetScale(.8)
    end
end

function MultiplayerMainScreen:MakeSubMenu()
    local submenuitems = {}

    if IsSteam() or IsRail() then
		if not IsLinux() and not IsSteamDeck() then
			table.insert(submenuitems, {widget = TEMPLATES.IconButton("images/button_icons.xml", "folder.tex", STRINGS.UI.MAINSCREEN.SAVE_LOCATION, false, true, function() TheSim:OpenDocumentsFolder() end, {font=NEWFONT_OUTLINE})})
		end

        if TheFrontEnd:GetAccountManager():HasSteamTicket() then
            table.insert(submenuitems, {widget = TEMPLATES.IconButton("images/button_icons.xml", "profile.tex", STRINGS.UI.SERVERCREATIONSCREEN.MANAGE_ACCOUNT, false, true, function() TheFrontEnd:GetAccountManager():VisitAccountPage() end, {font=NEWFONT_OUTLINE})})
        end

		if not IsRail() then
			table.insert(submenuitems, {widget = TEMPLATES.IconButton("images/button_icons.xml", "forums.tex", STRINGS.UI.MAINSCREEN.FORUM, false, true, function() VisitURL("http://forums.kleientertainment.com/forums/forum/73-dont-starve-together/") end, {font=NEWFONT_OUTLINE})})
	        table.insert(submenuitems, {widget = TEMPLATES.IconButton("images/button_icons.xml", "more_games.tex", STRINGS.UI.MAINSCREEN.MOREGAMES, false, true, function() VisitURL("http://store.steampowered.com/search/?developer=Klei%20Entertainment") end, {font=NEWFONT_OUTLINE})})
		end
    end

    self.submenu = self.fixed_root:AddChild(Menu(submenuitems, 75, true))
    self.submenu:SetPosition( -RESOLUTION_X*.5 + 90, -(RESOLUTION_Y*.5)+85, 0)
    self.submenu:SetScale(.8)
end

function MultiplayerMainScreen:OnBecomeActive()
    MultiplayerMainScreen._base.OnBecomeActive(self)

    ValidateItemsInProfile(Profile)

    if self.leaving and self.userprogress then
        -- Maybe have returned from collection with new icon or from game with  more xp.
        self.userprogress:UpdateProgress()
    end

    if not self.shown then
        self:Show()
    end

    local friendsmanager = self:AddChild(FriendsManager())
    friendsmanager:SetHAnchor(ANCHOR_RIGHT)
    friendsmanager:SetVAnchor(ANCHOR_BOTTOM)
    friendsmanager:SetScaleMode(SCALEMODE_PROPORTIONAL)

	if self.last_focus_widget then
		self.menu:RestoreFocusTo(self.last_focus_widget)
	end

    if self.debug_menu then self.debug_menu:Enable() end

    self.leaving = nil

    self:StartMusic()

    --start a new query everytime we go back to the mainmenu
	if TheSim:IsLoggedOn() then
		TheSim:StartWorkshopQuery()
	end

	if self.motd_panel ~= nil and self.motd_panel.OnBecomeActive ~= nil then
		self.motd_panel:OnBecomeActive()
	end

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end

    --delay for a frame to allow the screen to finish building, then check the entity count for leaks
	if IS_DEV_BUILD then
		self.inst:DoTaskInTime(0, function()
			if self.cached_entity_count ~= nil and self.cached_entity_count ~= TheSim:GetNumberOfEntities() then
				print("### Error: Leaked entities in the frontend.", self.cached_entity_count, TheSim:GetNumberOfEntities())
				for k, v in pairs(Ents) do
                    if v.widget and not v.widget.global_widget and (not v:IsValid() or v.widget.parent == nil) then
					    print(k, v.widget.name, v:IsValid(), v.widget.parent ~= nil, v)
                    end
				end
			end
			self.cached_entity_count = TheSim:GetNumberOfEntities()
		end)
	end
end

function MultiplayerMainScreen:OnBecomeInactive()
    MultiplayerMainScreen._base.OnBecomeInactive(self)

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
end

function MultiplayerMainScreen:FinishedFadeIn()
    if not TheFrontEnd:GetAccountManager():HasAuthToken() then
        -- NOTES(JBK): We should not try doing any inventory actions without a logged in player.
        return
    end
    if HasNewSkinDLCEntitlements() then
        if IsSteam() or IsRail() then
            local popup_screen = PopupDialogScreen( STRINGS.UI.PURCHASEPACKSCREEN.GIFT_RECEIVED_TITLE, STRINGS.UI.PURCHASEPACKSCREEN.GIFT_RECEIVED_BODY,
                    {
                        { text=STRINGS.UI.PURCHASEPACKSCREEN.OK, cb = function()
                                TheFrontEnd:PopScreen()
                                MakeSkinDLCPopup( function() self:FinishedFadeIn() end )
                            end
                        },
                    }
                )

            TheFrontEnd:PushScreen( popup_screen )
        else
            MakeSkinDLCPopup( function() self:FinishedFadeIn() end )
        end
    else
        local box_item = TheInventory:GetAutoBoxItem()
        if box_item ~= nil then
            local box_item_type = box_item.item_type
            local box_item_id = box_item.item_id

            if GetTypeForItem(box_item_type) ~= "mysterybox" then
                --this isn't a mysterybox, so just set it as opened
                TheInventory:SetItemOpened(box_item_id)
                self:FinishedFadeIn()
                return
            end

            local options = {
                message = box_item.box_message,
                allow_cancel = false,
                box_build = box_item.box_build_override or GetBoxBuildForItem( box_item_type ),
            }
            local box_popup = ItemBoxOpenerPopup(options,
                function(success_cb)
                    TheItems:OpenBox(box_item_id, function(success, item_types)
                        if not success or #item_types == 0 then
                            local body_txt = (not success) and STRINGS.UI.BOX_POPUP.SERVER_ERROR_BODY or STRINGS.UI.BOX_POPUP.SERVER_NO_ITEM_BODY
                            local box_error = PopupDialogScreen(STRINGS.UI.BOX_POPUP.SERVER_ERROR_TITLE, body_txt,
                                {
                                    {
                                        text = STRINGS.UI.BOX_POPUP.OK,
                                        cb = function()
                                            SimReset()
                                        end
                                    }
                                })
                            TheFrontEnd:PushScreen( box_error )
                        else
                            success_cb(item_types)
                        end
                    end)
                end,
                function()
                    self:FinishedFadeIn()
                end
            )
            TheFrontEnd:PushScreen(box_popup)
        else
            --Do new entitlement items
            local items = {}
            local entitlement_items = TheInventory:GetUnopenedEntitlementItems()
            for _,item in pairs(entitlement_items) do
                table.insert(items, { item = item.item_type, item_id = item.item_id, gifttype = SkinGifts.types[item.item_type] or "DEFAULT" })
            end

            local daily_gift = GetDailyGiftItem()
            if daily_gift then
                table.insert(items, { item = daily_gift, item_id = 0, gifttype = "DAILY_GIFT" })
            end

            if #items > 0 then
                local thankyou_popup = ThankYouPopup(items)
                TheFrontEnd:PushScreen(thankyou_popup)
            else
                --Make sure we only do one mainscreen popup at a time, do language assistance popups
                if IsSteam() then
                    local interface_lang = TheNet:GetLanguageCode()
                    if interface_lang ~= "english" then
                        if Profile:GetValue("steam_language_asked") ~= true then
                            local popup_screen = PopupDialogScreen( STRINGS.UI.OPTIONS.LANG_TITLE, STRINGS.UI.OPTIONS.LANG_BODY_STEAM,
                                    {
                                        {text=STRINGS.UI.OPTIONS.YES, cb = function() TheFrontEnd:PopScreen() self:Settings("LANG") end },
                                        {text=STRINGS.UI.OPTIONS.NO, cb = function() TheFrontEnd:PopScreen() end}
                                    }
                                )
                            TheFrontEnd:PushScreen( popup_screen )
                            Profile:SetValue("steam_language_asked", true)
                            Profile:Save()
                
                        end
                    end
                end
            end
		end
	end
end


function MultiplayerMainScreen:OnUpdate(dt)
end

function MultiplayerMainScreen:CheckNewUser(onnofn, no_button_text)
    if Profile:SawNewUserPopup() then
        return false
    end

    local popup = PopupDialogScreen(
        STRINGS.UI.MAINSCREEN.NEWUSER_DETECTED_HEADER,
        STRINGS.UI.MAINSCREEN.NEWUSER_DETECTED_BODY,
        {
            {
                text = STRINGS.UI.MAINSCREEN.NEWUSER_YES,
                cb = function()
                    TheFrontEnd:PopScreen()
                    Profile:ShowedNewUserPopup()
                    self:OnCreateServerButton()
                end,
            },
            {
                text = no_button_text,
                cb = function()
                    TheFrontEnd:PopScreen()
                    Profile:ShowedNewUserPopup()
                    onnofn(self)
                end,
            },
        }
    )

    TheFrontEnd:PushScreen(popup)
    return true
end

function MultiplayerMainScreen:GetHelpText()
    return (self.motd_panel ~= nil and self.motd_panel.GetHelpText ~= nil and not self.motd_panel.focus) and self.motd_panel:GetHelpText() or ""
end


return MultiplayerMainScreen
