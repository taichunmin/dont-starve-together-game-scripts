local wagpunkui_crosshair = require "widgets/wagpunkui_crosshair"
local wagpunkui_distmeter = require "widgets/wagpunkui_distmeter"
local wagpunkui_overlay = require "widgets/wagpunkui_overlay"
local Widget = require "widgets/widget"

local SOUNDRATE = 0.2

local WagpunkUI =  Class(Widget, function(self, owner)
    self.owner = owner

    Widget._ctor(self, "wagpunkui")

    local w, h = TheSim:GetScreenSize()

    self.target = nil
    self.hat = nil
    self.level = 0

    self.overlay = self:AddChild(wagpunkui_overlay(owner))
    self.overlay:SetPosition(0, 0, 0)
    self.overlay:Hide()

    self.crosshair = self:AddChild(wagpunkui_crosshair(owner))
    self.crosshair:SetPosition(0, 0, 0)
    self.crosshair:Hide()

    self.crosshairDist = self:AddChild(wagpunkui_crosshair(owner))
    self.crosshairDist:SetPosition(0, 0, 0)
    self.crosshairDist:Hide()

    self.synch = self:AddChild(wagpunkui_crosshair(owner))
    self.synch:SetPosition(0, 0, 0)  -- h/2-200
    self.synch:Hide()
    self.synch:GetAnimState():SetScale(0.5,0.5,0.5)

    self.synch.inst:ListenForEvent("animover", function()
        if self.synch:GetAnimState():IsCurrentAnimation("wagpunk_sync") then
            self.synch:Hide()
        end
    end)

    self.crosshair.inst:ListenForEvent("animover", function()
        if self.crosshairDist:GetAnimState():IsCurrentAnimation("distance_meter_pst") then
            self.crosshairDist:Hide()
            self.crosshair:Hide()
        end
    end)

    self.distmeter = self:AddChild(wagpunkui_distmeter(owner))
    self.distmeter:SetPosition(0, h/2*2/3, 0)
    self.distmeter:Hide()

    local function _SetTarget(owner,target) self:SetTarget(target) end
    self.owner:ListenForEvent("wagpunkui_targetupdate", _SetTarget, owner)

    local function _SetHat(owner,hat) self:SetHat(hat) end
    self.owner:ListenForEvent("wagpunkui_worn", _SetHat, owner)

    local function _HatRemoved(owner,hat) self:HatRemoved(hat) end
    self.owner:ListenForEvent("wagpunkui_removed", _HatRemoved, owner)

    local function _ChangeLevel(owner,data) self:ChangeLevel(data) end
    self.owner:ListenForEvent("wagpunk_changelevel", _ChangeLevel, owner)

    local function _Synch(owner,hat) self:ShowSynch(hat) end
    self.owner:ListenForEvent("wagpunkui_synch", _Synch, owner)

    local function _OnUnequip(owner) self:OnUnequip() end
    self.owner:ListenForEvent("unequip", _OnUnequip, owner)

    local function _OnEquip(owner) self:OnEquip() end
    self.owner:ListenForEvent("equip", _OnEquip, owner)
end)

function WagpunkUI:SetTarget(target)
    self.target = target
    if self.target then

        self.owner:StartUpdatingComponent(self)
        self.crosshairDist:GetAnimState():PlayAnimation("distance_meter_pre")
        self.crosshairDist:GetAnimState():PushAnimation("distance_meter")

        self.crosshair:GetAnimState():PlayAnimation("target_meter_pre")
        self.crosshair:GetAnimState():PushAnimation("target_meter_1")
    else
        self.distmeter:Hide()
        self.crosshairDist:GetAnimState():PlayAnimation("distance_meter_pst",false)
        self.crosshair:GetAnimState():PlayAnimation("target_meter_pst",false)

        self.owner:StopUpdatingComponent(self)
    end
end

function WagpunkUI:ShowSynch(hat)
    if hat == self.hat then
        self.synch:GetAnimState():PlayAnimation("wagpunk_sync")
        self.synch:Show()
    end
end

function WagpunkUI:OnUnequip()
    if self.hat ~= nil and (not self.hat:IsValid() or self.hat._wearer:value() ~= ThePlayer) then
        self:HatRemoved(self.hat)
    end
end

function WagpunkUI:OnEquip()
    if self.hat ~= nil and (not self.hat:IsValid() or self.hat._wearer:value() ~= ThePlayer) then
        self:HatRemoved(self.hat)
    end
end

function WagpunkUI:SetHat(hat)
    self.hat = hat
    self.overlay:Show()
    self.overlay:GetAnimState():PlayAnimation("hud_0_to_1")
    self.overlay:GetAnimState():PushAnimation("hud1")
end

function WagpunkUI:HatRemoved(hat)
    if self.hat == hat then
        self.overlay:GetAnimState():PushAnimation("over")
        self.crosshairDist:GetAnimState():PlayAnimation("distance_meter_pst",false)
        self.crosshair:GetAnimState():PlayAnimation("target_meter_pst",false)

        self.target = nil
        self.hat = nil
        self.level = 0

        self.overlay:SetPosition(0, 0, 0)
        self.overlay:Hide()

        self.crosshair:SetPosition(0, 0, 0)
        self.crosshair:Hide()

        self.crosshairDist:SetPosition(0, 0, 0)
        self.crosshairDist:Hide()

        self.synch:SetPosition(0, 0, 0)
        self.synch:Hide()
    end
end

function WagpunkUI:ChangeLevel(data)
    if data.level > self.level then
        if data.level == 1 then
            self.overlay:GetAnimState():PlayAnimation("hud_0_to_1")
            self.overlay:GetAnimState():PushAnimation("hud1")
            self.crosshair:GetAnimState():PushAnimation("target_meter_0")
        elseif data.level == 2 then
            self.overlay:GetAnimState():PlayAnimation("hud_1_to_2")
            self.overlay:GetAnimState():PushAnimation("hud2")
            self.crosshair:GetAnimState():PushAnimation("target_meter_1")
        elseif data.level == 3 then
            self.overlay:GetAnimState():PlayAnimation("hud_2_to_3")
            self.overlay:GetAnimState():PushAnimation("hud3")
            self.crosshair:GetAnimState():PushAnimation("target_meter_2")
        elseif data.level == 4 then
            self.overlay:GetAnimState():PlayAnimation("hud_3_to_4")
            self.overlay:GetAnimState():PushAnimation("hud4")
            self.crosshair:GetAnimState():PushAnimation("target_meter_3")
        elseif data.level == 5 then
            self.overlay:GetAnimState():PlayAnimation("hud_4_to_5")
            self.overlay:GetAnimState():PushAnimation("hud5")
            self.crosshair:GetAnimState():PushAnimation("target_meter_4")
        end
    else
        if self.level == 2 then
            self.overlay:GetAnimState():PlayAnimation("hud_2_to_1")
            self.overlay:GetAnimState():PushAnimation("hud1")
            self.crosshair:GetAnimState():PushAnimation("target_meter_0")
        elseif self.level == 3 then
            self.overlay:GetAnimState():PlayAnimation("hud_3_to_2")
            self.overlay:GetAnimState():PushAnimation("hud_2_to_1")
            self.overlay:GetAnimState():PushAnimation("hud1")
            self.crosshair:GetAnimState():PushAnimation("target_meter_0")
        elseif self.level == 4 then
            self.overlay:GetAnimState():PlayAnimation("hud_4_to_3")
            self.overlay:GetAnimState():PushAnimation("hud_3_to_2")
            self.overlay:GetAnimState():PushAnimation("hud_2_to_1")
            self.overlay:GetAnimState():PushAnimation("hud1")
            self.crosshair:GetAnimState():PushAnimation("target_meter_0")
        elseif self.level == 5 then
            self.overlay:GetAnimState():PlayAnimation("hud_5_to_4")
            self.overlay:GetAnimState():PushAnimation("hud_4_to_3")
            self.overlay:GetAnimState():PushAnimation("hud_3_to_2")
            self.overlay:GetAnimState():PushAnimation("hud_2_to_1")
            self.overlay:GetAnimState():PushAnimation("hud1")
            self.crosshair:GetAnimState():PushAnimation("target_meter_0")
        end
    end

    self.level  = data.level
end

function WagpunkUI:OnUpdate(dt)
    if self.target ~= nil and self.target:IsValid() and self.hat ~= nil then
        local x,y,z = self.target.Transform:GetWorldPosition()

        local w, h = TheSim:GetScreenSize()
        local x1, y1 = TheSim:GetScreenPos(x, 0, z)

        local dist = self.owner:GetDistanceSqToInst(self.target)
        local percent = math.clamp(dist / (TUNING.WAGPUNK_MAXRANGE * TUNING.WAGPUNK_MAXRANGE),0,1)

        if self.lastdist then
            
            if not self.soundtime or self.soundtime <= 0 then
                -- PLAY SOUND
               -- print(dist,self.lastdist,math.abs(self.lastdist-dist))
                if dist > self.lastdist then
                   -- print("FARTHER")
                    TheFocalPoint.SoundEmitter:PlaySound("rifts3/wagpunk_armor/lockon_farther")
                elseif dist < self.lastdist then
                    --print("CLOSER")
                    TheFocalPoint.SoundEmitter:PlaySound("rifts3/wagpunk_armor/lockon_closer")
                end
                self.soundtime = SOUNDRATE
            else
                self.soundtime = self.soundtime - dt
            end

        end
       
        self.lastdist = dist

        if self.crosshairDist:GetAnimState():IsCurrentAnimation("distance_meter") then
            self.crosshairDist:GetAnimState():SetPercent("distance_meter",percent)
        end

        local HEIGHT = -60
        self.crosshair:SetPosition(x1 - (w* 0.5), y1 - (h*0.5) + HEIGHT)
        self.crosshairDist:SetPosition(x1 - (w* 0.5), y1 - (h*0.5) + HEIGHT)


        self.crosshair:Show()
        self.crosshairDist:Show()

    else
        self.crosshair:Hide()
        self.crosshairDist:Hide()
        self.distmeter:Hide()
        if self.lastdist then
            self.lastdist = nil
        end
        if self.soundtime then
            self.soundtime = nil
        end
    end
end

return WagpunkUI
