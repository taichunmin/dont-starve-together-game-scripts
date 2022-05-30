local Screen = require "widgets/screen"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local TEMPLATES = require "widgets/templates"


TRANSITION_DURATION = 0.9

local DemoOverPopup = Class(Screen, function(self, callbackfn)
    Screen._ctor(self, "DemoOverPopup")

    self.callbackfn = callbackfn

    global("TAB")
    TAB = self

    --darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,0)
    self.black:TintTo({r=0,g=0,b=0,a=0}, {r=0,g=0,b=0,a=0.75}, TRANSITION_DURATION, nil)

    self.center_root = self:AddChild(Widget("ROOT_C"))
    self.center_root:SetVAnchor(ANCHOR_MIDDLE)
    self.center_root:SetHAnchor(ANCHOR_MIDDLE)
    self.center_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.proot = self.center_root:AddChild(Widget("ROOT_P"))
    self.proot:MoveTo({x=0,y=RESOLUTION_Y,z=0}, {x=0,y=0,z=0}, TRANSITION_DURATION, nil)

    self.bg = self.proot:AddChild(Image())
	self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetScale(.97)
    self.bg:SetTexture("images/thankyou_gift.xml", "gift.tex")

    --title
    self.title = self.proot:AddChild(Text(TITLEFONT, 60))
    self.title:SetPosition(0, 235, 0)
	self.title:SetString( STRINGS.UI.DEMOOVERDIALOG.TITLE_FREEWEEKEND )
    self.title:SetPosition(0,235,0)

    self.banner = self.proot:AddChild(Image("images/giftpopup.xml", "banner.tex"))
    self.banner:SetPosition(0, -245, 0)
    self.banner:SetScale(.9, 1.2)

	self.sale_image = self.proot:AddChild(Image("images/rail.xml","rail_sale.tex"))
	self.sale_image:SetPosition(0, -100, 0)

    self.banner_title = self.banner:AddChild(Text(TITLEFONT, 45))
    self.banner_title:SetPosition(0,  -135)
    self.banner_title:SetHAlign(ANCHOR_MIDDLE)
    self.banner_title:SetVAlign(ANCHOR_TOP)
    self.banner_title:SetRegionSize(500, 300)
    self.banner_title:SetString(STRINGS.UI.DEMOOVERDIALOG.BODY_FREEWEEKEND)

    self.close_btn = self.proot:AddChild(ImageButton("images/ui.xml", "button_large.tex", "button_large_over.tex", "button_large_disabled.tex"))
    self.close_btn:SetFont(BUTTONFONT)
    self.close_btn:SetText(STRINGS.UI.DEMOOVERDIALOG.QUIT)
    self.close_btn:SetScale(0.65)
    self.close_btn:SetPosition(0, -320, 0)
    self.close_btn:SetOnClick(function() self:GoAway() end)

end)

function DemoOverPopup:OnUpdate(dt)
	if not TheSim:IsDemoExpired() then
		self.callbackfn = nil
		self:GoAway(true)
	end

	if self.sale_image then
		self.sale_image_time = self.sale_image_time or 0
		self.sale_image_time = self.sale_image_time + dt
		self.sale_image:SetScale(0.8 + math.sin(self.sale_image_time * 3) * 0.02)
	end
end


-- Plays the closing animation
function DemoOverPopup:GoAway(purchased)
	if not self.closing then
		self.closing = true

		self.proot:MoveTo({x=0,y=0,z=0}, {x=0,y=RESOLUTION_Y,z=0}, TRANSITION_DURATION, nil)
        self.black:TintTo({r=0,g=0,b=0,a=0.75}, {r=0,g=0,b=0,a=0}, TRANSITION_DURATION, function()
            TheFrontEnd:PopScreen(self)
            if not purchased then
				TheFrontEnd:Fade(FADE_OUT, TRANSITION_DURATION,
					function()
						if self.callbackfn then
							self.callbackfn()
						end
					end, nil, nil, "black")
			end
        end)

	    self.close_btn:Hide()
	end
end

function DemoOverPopup:OnControl(control, down)
    if DemoOverPopup._base.OnControl(self,control, down) then
        return true
    end
end

return DemoOverPopup
