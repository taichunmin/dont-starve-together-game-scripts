local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local function TryCompass(self)
    if self.owner.replica.inventory ~= nil then
        local equipment = self.owner.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equipment ~= nil and equipment:HasTag("compass") then
            --self:OnEquipCompass(equipment)
            self:OpenCompass()
            return true
        end
    end
    --self:OnEquipCompass(nil)
    self:CloseCompass()
    return false
end

--base class for imagebuttons and animbuttons.
local HudCompass = Class(Widget, function(self, owner, isattached)
    self.owner = owner
    Widget._ctor(self, "Hud Compass")
    self:SetClickable(false)

    self.isattached = isattached

    self.bg = self:AddChild(UIAnim())

    self.needle = self:AddChild(UIAnim())
    self.needle:GetAnimState():SetBank("compass_needle")
    self.needle:GetAnimState():SetBuild("compass_needle")
    self.needle:GetAnimState():PlayAnimation("idle", true)

    if isattached then
        self.bg:GetAnimState():SetBank("compass_hud")
        self.bg:GetAnimState():SetBuild("compass_hud")
        self.bg:GetAnimState():PlayAnimation("hidden")

        self.needle:SetPosition(0, 70, 0)
        self.needle:Hide()
    else
        self.bg:GetAnimState():SetBank("compass_bg")
        self.bg:GetAnimState():SetBuild("compass_bg")
        self.bg:GetAnimState():PlayAnimation("idle")
    end

    self:Hide()

    self.displayheading = 0
    self.currentheading = 0
    self.offsetheading = 0
    self.forceperdegree = 0.005
    self.headingvel = 0
    self.damping = 0.98
    self.easein = 0

    --self.currentcompass = nil

    self.inst:ListenForEvent("refreshinventory", function(inst)
        TryCompass(self)
    end, self.owner)

    self.inst:ListenForEvent("equip", function(inst, data)
        if data.item ~= nil and data.item:HasTag("compass") then
            --self:OnEquipCompass(data.item)
            self:OpenCompass()
        end
    end, self.owner)
    self.inst:ListenForEvent("unequip", function(inst, data)
        if data.eslot == EQUIPSLOTS.HANDS then
            --self:OnEquipCompass(nil)
            self:CloseCompass()
        end
    end, self.owner)
    --Client only event, because when inventory is closed, we will stop
    --getting "equip" and "unequip" events, but we can also assume that
    --our inventory is emptied.
    self.inst:ListenForEvent("inventoryclosed", function()
        self:CloseCompass()
    end, self.owner)

    self.isopen = false
    self.istransitioning = false
    self.wantstoclose = false

    self.ontransout = function(bginst)
        self.inst:RemoveEventCallback("animover", self.ontransout, bginst)
        self.istransitioning = false
        self.bg:GetAnimState():PlayAnimation("idle")
        self.needle:Show()
        self:StartUpdating()
    end

    self.ontransin = function(bginst)
        self.inst:RemoveEventCallback("animover", self.ontransin, bginst)
        self.istransitioning = false
        self.bg:GetAnimState():PlayAnimation("hidden")
        self:Hide()
    end

    TryCompass(self)
end)

--------------------------------------------------------------------------
--The one compass to rule them all.
--(aka. all other widgets' needles can follow the master's needle -_-)
local mastercompass = nil

local function OnRemoveMaster(inst)
    if inst == mastercompass.inst then
        mastercompass = nil
    end
end

function HudCompass:SetMaster()
    if mastercompass ~= nil and mastercompass ~= self then
        mastercompass.inst:RemoveEventCallback("onremove", OnRemoveMaster)
    end
    mastercompass = self
    self.inst:ListenForEvent("onremove", OnRemoveMaster)
end

function HudCompass:CopyMasterNeedle()
    self.displayheading = mastercompass.displayheading
    self.currentheading = mastercompass.currentheading
    self.offsetheading = mastercompass.offsetheading
    self.headingvel = mastercompass.headingvel
    self.easein = mastercompass.easin
end
--------------------------------------------------------------------------

function HudCompass:OpenCompass()
    if not self.isattached then
        if not self.isopen then
            self.isopen = true
            if mastercompass ~= nil and mastercompass ~= self then
                self:CopyMasterNeedle()
            else
                self.displayheading = self:GetCompassHeading()
                self.currentheading = self.displayheading
                self.offsetheading = 0
                self.headingvel = 0
                self.easein = 1
            end
            self.needle:SetRotation(self.displayheading)
            self:StartUpdating()
            self:Show()
        end
        return
    elseif self.wantstoclose then
        self.wantstoclose = false
        self.easein = 0
        return
    elseif self.isopen then
        return
    end

    self.isopen = true
    self.displayheading = 0
    self.currentheading = 0
    self.offsetheading = 0
    self.headingvel = 0
    self.easein = 0

    self.needle:SetRotation(0)

    if self.istransitioning then
        self.inst:RemoveEventCallback("animover", self.ontransin, self.bg.inst)
    else
        self.istransitioning = true
    end

    self.bg:GetAnimState():PlayAnimation("trans_out")
    self.inst:ListenForEvent("animover", self.ontransout, self.bg.inst)
    self:Show()
end

function HudCompass:CloseCompass()
    if not self.isattached then
        if self.isopen then
            self.isopen = false
            self:StopUpdating()
            self:Hide()
        end
        return
    elseif not self.isopen then
        return
    elseif math.abs(self.displayheading) > 1 then
        self.wantstoclose = true
        return
    end

    self.isopen = false
    self.wantstoclose = false

    if self.istransitioning then
        self.inst:RemoveEventCallback("animover", self.ontransout, self.bg.inst)
    else
        self.istransitioning = true
    end

    self:StopUpdating()
    self.needle:Hide()
    self.bg:GetAnimState():PlayAnimation("trans_in")
    self.inst:ListenForEvent("animover", self.ontransin, self.bg.inst)
end

--[[
function HudCompass:OnEquipCompass(compass)
    if compass ~= nil then
        self.currentcompass = compass
        self:OpenCompass()
    else
        self.currentcompass = nil
        self:CloseCompass()
    end
end
]]

local function NormalizeHeading(heading)
    while heading < -180 do heading = heading + 360 end
    while heading > 180 do heading = heading -360 end
    return heading
end

local function EaseHeading(heading0, heading1, k)
    local delta = NormalizeHeading(heading1 - heading0)
    return NormalizeHeading(heading0 + math.clamp(delta * k, -20, 20))
end

function HudCompass:GetCompassHeading()
    return TheCamera ~= nil and (TheCamera:GetHeading() - 45) or 0
end

function HudCompass:OnUpdate(dt)
    if mastercompass ~= nil and mastercompass ~= self then
        self:CopyMasterNeedle()
        self.needle:SetRotation(self.displayheading)
        return
    end

    if self.wantstoclose then
        self.displayheading = EaseHeading(self.displayheading, 0, .5)
        self.needle:SetRotation(self.displayheading)
        self:CloseCompass()
        return
    end

    local delta = NormalizeHeading(self:GetCompassHeading() - self.currentheading)

    self.headingvel = self.headingvel + delta * self.forceperdegree
    self.headingvel = self.headingvel * self.damping
    self.currentheading = NormalizeHeading(self.currentheading + self.headingvel)

    --if self.currentcompass == nil then
        --return
    --end

    local t = GetTime()

    -- Offsets from haunting
    --local spooky_denominator = self.currentcompass.spookyoffsetfinish-self.currentcompass.spookyoffsetstart
    --local spooky_t = 1
    --if spooky_denominator > 0 then
        --spooky_t = math.clamp((t-self.currentcompass.spookyoffsetstart)/spooky_denominator, 0, 1)
    --end
    --local spooky_offset = math.sin(t*0.005) * Lerp(self.currentcompass.spookyoffsettarget,0,spooky_t)

    -- Offsets from sanity
    local sanity = self.owner.replica.sanity
    local sanity_t = math.clamp((sanity:IsInsanityMode() and sanity:GetPercentWithPenalty() or (1.0 - sanity:GetPercentWithPenalty())) * 3, 0, 1)
    local sanity_offset = math.sin(t*0.2) * Lerp(720, 0, sanity_t)

    -- Offset from full moon
    local fullmoon_t = TheWorld.state.isfullmoon and math.sin(TheWorld.state.timeinphase * math.pi) or 0
    local fullmoon_offset = math.sin(t*0.8) * Lerp(0, 720, fullmoon_t)

    -- Offset from wobble
    local wobble_offset = math.sin(t*2)*5

    self.offsetheading = EaseHeading(self.offsetheading, wobble_offset + fullmoon_offset + sanity_offset, .5)

    self.easein = math.min(1, self.easein + dt)
    self.displayheading = EaseHeading(self.displayheading, self.currentheading + self.offsetheading, self.easein)
    self.needle:SetRotation(self.displayheading)
end

return HudCompass
