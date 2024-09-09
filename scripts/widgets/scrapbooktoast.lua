local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local UIAnimButton = require "widgets/uianimbutton"

-- Where the toast is supposed to be when it's active
local down_pos = -200

local TIMEOUT = 1

local ScrapbookToast = Class(Widget, function(self, owner, controls)
    Widget._ctor(self, "SkillTreeToast")
    self.controls = controls
    self.owner = owner
    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetPosition(0,-200,0)

    self.tab_gift = self.root:AddChild(UIAnimButton("tab_scrapbook", "scrapbook_updated", "pre"))

    --local scale = 0.35
    --self.tab_gift.animstate:SetScale(scale,scale,scale)

    self.tab_gift.inst:ListenForEvent("animover", function()
        if self.tab_gift.inst:GetAnimState():IsCurrentAnimation("pre") then
            self.tab_gift.animstate:PlayAnimation("idle",true)
        end
    end)

    self.tab_gift:SetOnClick(function()
        ThePlayer.HUD:OpenScrapbookScreen() 
    end)

    self.tab_gift:Hide()

    self.tab_gift:SetTooltip(STRINGS.SCRAPBOOK.NEW_SCRAPBOOK_ENTRY)
    self.tab_gift:SetTooltipPos(0, -40, 0)

    self.inst:ListenForEvent("scrapbookupdated", function(player, data)        
        self:UpdateElements()
    end, ThePlayer)


    self.controller_hide = false
    self.craft_hide = false
    self.opened = false

    self.hud_focus = owner.HUD.focus
    self.shownotification = Profile:GetScrapbookHudDisplay()
    self.inst:StartUpdatingComponent(self)

    self.inst:ListenForEvent("scrapbookopened", function(player, data)        
        if self.opened then
            self.tab_gift:Hide()
            self.controls:ManageToast(self,true)
            self.opened = false
        end
    end, ThePlayer)
end)


function ScrapbookToast:UpdateElements()

    if not self.opened and self.shownotification then        
        self.controls:ManageToast(self)
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/scrapbook_dropdown")
        self.tab_gift:Show()
        self.opened = true
        self.tab_gift.animstate:PlayAnimation("pre")
    end

end

function ScrapbookToast:ToggleHUDFocus(focus)
    self.hud_focus = focus
    self:UpdateControllerHelp()
end

function ScrapbookToast:ToggleController(hide)
    self.controller_hide = hide
    self:UpdateElements()
end

function ScrapbookToast:ToggleCrafting(hide)
    self.craft_hide = hide
    self:UpdateElements()
end

--Called from PlayerHud:OnControl
function ScrapbookToast:CheckControl(control, down)
    if self.shown and down and control == CONTROL_INSPECT_SELF then
        return true
    end
end

function ScrapbookToast:OnUpdate()
    if self.shownotification ~= Profile:GetScrapbookHudDisplay() then
        self.shownotification = Profile:GetScrapbookHudDisplay()

        if self.shownotification == false then
            self.tab_gift:Hide()
            self.controls:ManageToast(self,true)
            self.opened = false
        end
    end
end

return ScrapbookToast
