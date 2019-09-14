local Badge = require("widgets/badge")
local UIAnim = require("widgets/uianim")

local WereBadge = Class(Badge, function(self, owner)
    Badge._ctor(self, nil, owner, { 70 / 255, 112 / 255, 29 / 255, 1 })

    self.circleframe:GetAnimState():SetBank("status_were")
    self.circleframe:GetAnimState():SetBuild("status_were")

    self.circleframe2 = self.circleframe:AddChild(UIAnim())
    self.circleframe2:GetAnimState():SetBank("status_were")
    self.circleframe2:GetAnimState():SetBuild("status_were")

    self.sanityarrow = self.underNumber:AddChild(UIAnim())
    self.sanityarrow:GetAnimState():SetBank("sanity_arrow")
    self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")
    self.sanityarrow:SetClickable(false)

    self.val = 100
    self.arrowdir = nil
    self.mode = nil
    self:UpdateArrow()
    self:StartUpdating()
end)

local function ShowAnimMode(animstate, mode)
    animstate:Hide("beaver")
    animstate:Hide("moose")
    animstate:Hide("goose")
    animstate:Show(mode)
end

local function RemoveFX(fxinst)
    fxinst.widget:Kill()
end

function WereBadge:SpawnNewFX()
    self.circleframe2:GetAnimState():PlayAnimation("new")
    if self.circleframe2:IsVisible() then
        --Don't use FE sound since it's not a 2D sfx
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
    end
end

function WereBadge:SpawnShatterFX()
    if self.mode ~= nil then
        if self.parent ~= nil then
            local anim = self.parent:AddChild(UIAnim())
            anim:SetPosition(self:GetPosition())
            anim:SetClickable(false)
            anim.inst:ListenForEvent("animover", RemoveFX)
            if anim:IsVisible() then
                --Don't use FE sound since it's not a 2D sfx
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/egg_deathcrack")
            end

            anim = anim:GetAnimState()
            ShowAnimMode(anim, self.mode)
            anim:SetBank("status_were")
            anim:SetBuild("status_were")
            anim:PlayAnimation("destroy")
        end
        self.mode = nil
    end
end

function WereBadge:UpdateArrow()
    local anim = "neutral"
    if self.val > 0 and self.owner.GetWerenessDrainRate ~= nil then
        local rate = self.owner:GetWerenessDrainRate()
        if rate < -5 then
            anim = "arrow_loop_decrease_most"
        elseif rate < -.5 then
            anim = "arrow_loop_decrease_more"
        elseif rate < 0 then
            anim = "arrow_loop_decrease"
        end
    end
    if self.arrowdir ~= anim then
        self.arrowdir = anim
        self.sanityarrow:GetAnimState():PlayAnimation(anim, true)
    end
end

function WereBadge:SetPercent(val)
    Badge.SetPercent(self, val)
    self.val = val
    if val > 0 and self.shown then
        self:StartUpdating()
    else
        self:StopUpdating()
    end
    self:UpdateArrow()
end

function WereBadge:OnUpdate(dt)
    if self.owner.GetWerenessDrainRate ~= nil then
        self:SetPercent(math.max(0, self.val + self.owner:GetWerenessDrainRate() * dt / 100))
    end
end

function WereBadge:OnShow()
    self.mode =
        (self.owner:HasTag("beaver") and "beaver") or
        (self.owner:HasTag("weremoose") and "moose") or
        (--[[self.owner:HasTag("weregoose") and]] "goose")
    ShowAnimMode(self.circleframe2:GetAnimState(), self.mode)
    self.circleframe2:GetAnimState():SetPercent("new", 1)
    if self.val > 0 then
        self:StartUpdating()
    end
end

function WereBadge:OnHide()
    self:StopUpdating()
end

return WereBadge
