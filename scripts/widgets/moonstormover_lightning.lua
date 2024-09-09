local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local function OnLightningDone(inst)
    inst.next_time = math.random()*20
--    inst.ref:Hide()
end

local MoonstormOver_Lightning = Class(Widget, function(self, owner, dustlayer)

    self.owner = owner
    Widget._ctor(self, "MoonstormOver_Lightning")

    self:SetClickable(false)

    self.minscale = .9 --min scale supported by art size
    self.maxscale = 1.20625 --defaults to 1 based on camera [15, 50] (default 30)
    self.active = false

    self.lightning = self:AddChild(UIAnim())
    self.lightning:GetAnimState():SetBuild("screenlightning")
    self.lightning:GetAnimState():SetBank("screenlightning")
    self.lightning:GetAnimState():PlayAnimation("lightningstrike1",true)
    self.lightning:GetAnimState():AnimateWhilePaused(false)
    self.lightning:Hide()
    self.lightning.inst:ListenForEvent("animover", OnLightningDone)
    self.lightning.inst.ref = self.lightning
    self.lightning:SetHAnchor(ANCHOR_MIDDLE)
    self.lightning:SetVAnchor(ANCHOR_MIDDLE)
    self.lightning:GetAnimState():SetBloomEffectHandle("shaders/anim.ksh")

    self.lightning.inst.next_time = math.random()*20

    if owner ~= nil then
        self.inst:ListenForEvent("stormlevel", function(owner, data)
            if data.stormtype == STORM_TYPES.MOONSTORM then
                self:Activate(data.level)
            else
                self:Activate(0)
            end
        end, owner)
    end
end)

function MoonstormOver_Lightning:Activate(level)
    if level > 0 and not self.active then
        self.active = true
        self.lightning.inst.next_time = math.random()*20
        self:StartUpdating()
    elseif level <= 0 and self.active then
        self.active = false
        self:StopUpdating()
    end
end

function MoonstormOver_Lightning:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end

    if self.lightning.inst.next_time then
        self.lightning.inst.next_time = self.lightning.inst.next_time - dt
        if self.lightning.inst.next_time <= 0 then
            --TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/get_gold")
            --TheFrontEnd:GetSound():PlaySound("dontstarve/rain/thunder_close", nil, 1)
            self.lightning:GetAnimState():PlayAnimation("lightningstrike"..math.random(1,2))
            self.lightning:Show()
            local rot = math.random()*360
            self.lightning:SetRotation(rot)
            self.lightning.inst.next_time = nil

            rot = rot - 90
            local radius = math.random()*200 + 100
            local offset = Vector3(radius * math.cos(rot*DEGREES), 0, -radius * math.sin(rot* DEGREES))
            self.lightning:SetPosition(offset.x, offset.z)

            --self.lightning:SetPosition(0,0)
            --TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/get_gold")
            TheFocalPoint.SoundEmitter:PlaySound("moonstorm/common/moonstorm/lightning")
        end
    end
end

return MoonstormOver_Lightning
