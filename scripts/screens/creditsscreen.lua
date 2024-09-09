local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/templates"

local internal_names_pages =
{
    {x=300, y=30, bg=1, build="credits", bank="credits", anim="1", names=true},
    {x=-220,y=30, bg=2, build="credits", bank="credits", anim="2", names=true},
    {x=-325,y=30, bg=3, build="credits", bank="credits", anim="3", names=true},
    {x=260, y=30, bg=1, build="credits", bank="credits", anim="4", names=true},
    {x=-300,y=30, bg=2, build="credits", bank="credits", anim="5", names=true},
    {x=300, y=30, bg=3, build="credits3", bank="credits3", anim="12", names=true},
    {x=-300,y=30, bg=1, build="credits4", bank="credits4", anim="13", names=true},
    {x=-300,y=30, bg=2, build="credits4", bank="credits4", anim="14", names=true},
    {x=260, y=30, bg=3, build="credits4", bank="credits4", anim="15", names=true},
    {x=-300,y=30, bg=1, build="credits4", bank="credits4", anim="16", names=true},
    {x=300, y=30, bg=2, build="credits5", bank="credits5", anim="17", names=true},
    {x=-320,y=30, bg=3, build="credits5", bank="credits5", anim="18", names=true},
    {x=300, y=30, bg=1, build="credits5", bank="credits5", anim="19", names=true},
    {x=-300,y=30, bg=2, build="credits6", bank="credits6", anim="20", names=true},
    {x=80,y=30, bg=2, build="credits7", bank="credits7", anim="21", names=true},
    {x=-300,y=30, bg=2, build="credits8", bank="credits8", anim="23", names=true},
}

local pc_pages=
{
    {x=260,y=0, bg=3, tx=260,ty=200, title = STRINGS.UI.CREDITS.THANKYOU, build="credits", bank="credits", anim="6", flavour = STRINGS.UI.CREDITS.EXTRA_THANKS},    -- EXTRA THANKS
    {x=-320,y=0, bg=2, tx=-320,ty=200, title = STRINGS.UI.CREDITS.THANKYOU, build="credits", bank="credits", anim="7", flavour = STRINGS.UI.CREDITS.EXTRA_THANKS_2},    -- EXTRA THANKS - STEAM
    {x=0,y=0, bg=1, tx=0,ty=200, title = STRINGS.UI.CREDITS.ALTGAMES.TITLE, build="credits2", bank="credits2", anim="8", flavour = table.concat(STRINGS.UI.CREDITS.ALTGAMES.NAMES, "\n")},    -- ALTGAME
    {x=0,y=60, bg=3, flavour = STRINGS.UI.CREDITS.FMOD, build="credits2", bank="credits2", anim="9"},    -- FMOD
    {x=0,y=180, bg=2, tx=0,ty=180, title =STRINGS.UI.CREDITS.THANKYOU, thanks=true, delay=10, build="credits2", bank="credits2", anim="10"},      -- THANKS
}

local ps4_pages =
{
    {x=260,y=0, bg=1, tx=260,ty=200,  title =STRINGS.UI.CREDITS.THANKYOU, build="credits", bank="credits", anim="6", flavour = STRINGS.UI.CREDITS.EXTRA_THANKS},    -- GOOGLE
    {x=-320,y=0, bg=3, tx=-320,ty=200, title =STRINGS.UI.CREDITS.THANKYOU, build="credits", bank="credits", anim="7", flavour = STRINGS.UI.CREDITS.EXTRA_THANKS_2},    -- STEAM
    {x=220,y=0, bg=2, tx=220,ty=200,  title =STRINGS.UI.CREDITS.THANKYOU, build="credits", bank="credits", anim="1", flavour = STRINGS.UI.CREDITS.SONY_THANKS},    -- SONY
    {x=-260,y=0, bg=1, tx=-260, ty=200, title =STRINGS.UI.CREDITS.THANKYOU, build="credits", bank="credits", anim="3", flavour = table.concat(STRINGS.UI.CREDITS.ALTGAMES.NAMES, "\n")},    -- ALTGAMES
    {x=-220,y=0, bg=3, x2 = 260, y2 = 0, tx=20,ty=250, title = STRINGS.UI.CREDITS.BABEL.TITLE, build="credits2", bank="credits2", anim="8", flavour =table.concat(STRINGS.UI.CREDITS.BABEL.NAMES1, "\n"), flavour2 =table.concat(STRINGS.UI.CREDITS.BABEL.NAMES2, "\n")},    -- BABEL
    {x=-220,y=0, bg=3, x2 = 260, y2 = 0, tx=20,ty=250, title = STRINGS.UI.CREDITS.BABEL.TITLE, build="credits2", bank="credits2", anim="9", flavour =table.concat(STRINGS.UI.CREDITS.BABEL.NAMES1, "\n"), flavour2 =table.concat(STRINGS.UI.CREDITS.BABEL.NAMES2, "\n")},    -- BABEL
	{x=-100,y=60, bg=2, flavour = STRINGS.UI.CREDITS.FMOD, build="credits", bank="credits", anim="2"},    -- FMOD
}



local klei_pages =
{
    {x=0,y=180, bg=1, build="credits2", bank="credits2", anim="11"},
    {x=0,y=180, bg=1, build="credits8", bank="credits8", anim="24"},
}

local names_per_page = 5
local PS4CREDITS = PLATFORM == "PS4"

local CreditsScreen = Class(Screen, function(self)
    Screen._ctor(self, "CreditsScreen")

    self.bg = self:AddChild(Image("images/bg_plain.xml", "bg.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.bg:SetTint(unpack(BGCOLOURS.HALF))

    self.klei_img = self:AddChild(Image("images/ui.xml", "klei_new_logo.tex"))
    self.klei_img:SetVAnchor(ANCHOR_MIDDLE)
    self.klei_img:SetHAnchor(ANCHOR_MIDDLE)
    self.klei_img:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.klei_img:SetPosition( 0, 25, 0)

    self.center_root = self:AddChild(Widget("root"))
    self.center_root:SetVAnchor(ANCHOR_MIDDLE)
    self.center_root:SetHAnchor(ANCHOR_MIDDLE)
    self.center_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.bottom_root = self:AddChild(Widget("root"))
    self.bottom_root:SetVAnchor(ANCHOR_BOTTOM)
    self.bottom_root:SetHAnchor(ANCHOR_MIDDLE)
    self.bottom_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.back_button_root = self:AddChild(Widget("root"))
    self.back_button_root:SetVAnchor(ANCHOR_MIDDLE)
    self.back_button_root:SetHAnchor(ANCHOR_MIDDLE)
    self.back_button_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.worldanim = self.bottom_root:AddChild(UIAnim())
    self.worldanim:GetAnimState():SetBuild("credits")
    self.worldanim:GetAnimState():SetBank("credits")

    self.flavourtext = self.center_root:AddChild(Text(TITLEFONT, 70))
    self.flavourtext2 = self.center_root:AddChild(Text(TITLEFONT, 70))
    self.thankyoutext = self.center_root:AddChild(Text(NEWFONT, 40))
    self.thankyoutext:SetString(STRINGS.UI.CREDITS.THANKS)
    self.thankyoutext:Hide()

    TheFrontEnd:Fade(FADE_IN, 2)

    self.titletext = self.center_root:AddChild(Text(TITLEFONT, 70))
    self.titletext:SetPosition(0, 180, 0)
    self.titletext:SetString(STRINGS.UI.CREDITS.THANKYOU)
    self.titletext:Hide()

    self:SetupRandomPages()

    self.credit_name_idx = 1
    self.page_order_idx = 1
    self:ShowNextPage()

    if not TheInput:ControllerAttached() then
        local right_pos_x = -150
        local left_pos_x = 150

        self.OK_button = self.back_button_root:AddChild(TEMPLATES.BackButton(function()
            self.OK_button:Disable()
            self:Disable()
			TheFrontEnd:FadeBack()
        end , STRINGS.UI.MAINSCREEN.BACK))

        if PLATFORM ~= "PS4" and PLATFORM ~= "WIN32_RAIL" then
            self.FB_button = self:AddChild(ImageButton())
            self.FB_button:SetScale(.8,.8,.8)
            self.FB_button:SetText(STRINGS.UI.CREDITS.FACEBOOK)
            self.FB_button:SetOnClick( function() VisitURL("http://facebook.com/kleientertainment") end )
            self.FB_button:SetHAnchor(ANCHOR_RIGHT)
            self.FB_button:SetVAnchor(ANCHOR_BOTTOM)
            self.FB_button:SetPosition( right_pos_x, 55*2, 0)

            self.TWIT_button = self:AddChild(ImageButton())
            self.TWIT_button:SetScale(.8,.8,.8)
            self.TWIT_button:SetText(STRINGS.UI.CREDITS.TWITTER)
            self.TWIT_button:SetOnClick( function() VisitURL("http://twitter.com/klei") end )
            self.TWIT_button:SetHAnchor(ANCHOR_RIGHT)
            self.TWIT_button:SetVAnchor(ANCHOR_BOTTOM)
            self.TWIT_button:SetPosition( right_pos_x, 55, 0)

            self.THANKS_button = self:AddChild(ImageButton())
            self.THANKS_button:SetScale(.8,.8,.8)
            self.THANKS_button:SetText(STRINGS.UI.CREDITS.THANKYOU)
            self.THANKS_button:SetOnClick( function() VisitURL("http://www.dontstarvegame.com/Thank-You") end )
            self.THANKS_button:SetHAnchor(ANCHOR_RIGHT)
            self.THANKS_button:SetVAnchor(ANCHOR_BOTTOM)
            self.THANKS_button:SetPosition( right_pos_x, 55*3, 0)

            --focus crap
            self.OK_button:SetFocusChangeDir(MOVE_RIGHT, self.TWIT_button)
            self.TWIT_button:SetFocusChangeDir(MOVE_LEFT, self.OK_button)
            self.TWIT_button:SetFocusChangeDir(MOVE_UP, self.FB_button)
            self.FB_button:SetFocusChangeDir(MOVE_DOWN, self.TWIT_button)
            self.FB_button:SetFocusChangeDir(MOVE_UP, self.THANKS_button)
            self.THANKS_button:SetFocusChangeDir(MOVE_DOWN, self.FB_button)
        end
    end
end)


function CreditsScreen:SetupRandomPages()
    self.credit_names = deepcopy(STRINGS.UI.CREDITS.NAMES)
    if PS4CREDITS then
        table.insert(self.credit_names, "Auday Hussein")
    end

    self.num_credit_pages = math.floor(#self.credit_names / (names_per_page-1))
    self.num_leftover_names = #self.credit_names - self.num_credit_pages * (names_per_page-1)

    shuffleArray(self.credit_names)

    self.pages = {}
	local offset = math.floor(GetRandomMinMax(0,#internal_names_pages))
	for k = 1, self.num_credit_pages do
        table.insert(self.pages, internal_names_pages[1+((offset+k) % #internal_names_pages)])
    end
	for k,v in ipairs( PS4CREDITS and ps4_pages or pc_pages) do
        table.insert(self.pages, v)
	end
	local ki = math.floor(GetRandomMinMax(0,#klei_pages))
	table.insert(self.pages, klei_pages[1+ki])
end

function CreditsScreen:OnBecomeActive()
    CreditsScreen._base.OnBecomeActive(self)
    TheFrontEnd:GetSound():PlaySound("dontstarve/music/gramaphone_ragtime", "creditsscreenmusic")
end

function CreditsScreen:OnBecomeInactive()
    CreditsScreen._base.OnBecomeInactive(self)

    TheFrontEnd:GetSound():KillSound("creditsscreenmusic")
    TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
end

function CreditsScreen:OnControl(control, down)
    if Screen.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then
        if self.OK_button then self.OK_button:Disable() end
        self:Disable()
		TheFrontEnd:FadeBack()
     return true
    end
end


function CreditsScreen:OnUpdate(dt)
	if self.delay ~= nil then
		self.delay = self.delay - dt
		if self.delay < 0 then
			self:ShowNextPage()
		end
	else
		if self.worldanim:GetAnimState():AnimDone() then
			self:ShowNextPage()
		end
	end
end

function CreditsScreen:ShowNextPage()
    local page = self.pages[self.page_order_idx]

    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/creditpage_flip", "flippage")

    self.worldanim:Show()
    self.worldanim:GetAnimState():SetBuild(page.build)
    self.worldanim:GetAnimState():SetBank(page.bank)
    self.worldanim:GetAnimState():PlayAnimation(page.anim)

    if page.title then
        self.titletext:Show()
        self.titletext:SetPosition(page.tx or 0, page.ty or 0, 0)
        self.titletext:SetString(page.title)
    else
        self.titletext:Hide()
    end

    if page.klei then
        self.klei_img:Show()
    else
        self.klei_img:Hide()
    end

    if page.thanks then
        self.thankyoutext:Show()
    else
        self.thankyoutext:Hide()
    end

	self.flavourtext:Hide()
    if page.flavour then
        self.flavourtext:Show()
        self.flavourtext:SetPosition(page.x or 0, page.y or 0, 0)
        self.flavourtext:SetString(page.flavour)
	end

    if page.flavour2 then
        self.flavourtext2:Show()
        self.flavourtext2:SetPosition(page.x2 or 0, page.y2 or 0, 0)
        self.flavourtext2:SetString(page.flavour2)
	else
		self.flavourtext2:Hide()
	end

    if page.names then
        self.flavourtext:Show()
        self.flavourtext:SetPosition(page.x or 0, page.y or 0, 0)

        local names_to_show = names_per_page-1
        if self.page_order_idx <= self.num_leftover_names then
            names_to_show = names_to_show + 1
        end

        local str = {}
        for k = 1, names_to_show do
            local name = self.credit_names[1 + (self.credit_name_idx -1) % #self.credit_names]
            table.insert(str, name)
            self.credit_name_idx = self.credit_name_idx + 1
        end
        --print (str)
        self.flavourtext:SetString(table.concat(str, "\n"))
    end


    self.page_order_idx = self.page_order_idx + 1
    if self.page_order_idx > #self.pages then
        self.page_order_idx = 1
        self:SetupRandomPages()
    end

    self.delay = page.delay
end



function CreditsScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    return TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK
end


return CreditsScreen
