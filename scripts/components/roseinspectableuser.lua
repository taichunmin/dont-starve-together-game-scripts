local RoseInspectableUser = Class(function(self, inst)
    self.inst = inst

    self.cooldowntime = TUNING.SKILLS.WINONA.ROSEGLASSES_COOLDOWNTIME
    --self.cooldowntask = nil
end)

function RoseInspectableUser:OnRemoveFromEntity()
    if self.cooldowntask ~= nil then
        self.cooldowntask:Cancel()
        self.cooldowntask = nil
        self:OnCooldown()
    end
end

--------------------------------------------------

function RoseInspectableUser:SetCooldownTime(cooldowntime)
    self.cooldowntime = cooldowntime
end

function RoseInspectableUser:GoOnCooldown()
    if self.cooldowntask ~= nil then
        self.cooldowntask:Cancel()
        self.cooldowntask = nil
    end
    if self.cooldowntime ~= nil then
        self:ApplyCooldown(self.cooldowntime)
    end
end

--------------------------------------------------

function RoseInspectableUser:OnCharlieResidueActivated(residue)
    if residue ~= self.residue then
        return
    end

    if self.target ~= nil then
        local roseinspectable = self.target.components.roseinspectable
        if roseinspectable ~= nil then
            local will_cooldown = roseinspectable:WillInduceCooldownOnActivate(self.inst)
            if not will_cooldown or (will_cooldown and not self:IsInCooldown()) then
                roseinspectable:DoRoseInspection(self.inst)
                if will_cooldown then
                    self:GoOnCooldown()
                end
            else
                self:DoQuip("ROSEGLASSES_COOLDOWN", true)
            end
        end
        self.target = nil
    else
        if self:DoRoseInspectionOnPoint() then
            self:GoOnCooldown()
        end
        self.point = nil
    end
end

--------------------------------------------------

function RoseInspectableUser:SetRoseInpectionOnTarget(target)
    self.target = target
    self.point = nil

    self:SpawnResidue()
    if self.target.components.roseinspectable then
        self.target.components.roseinspectable:HookupResidue(self.inst, self.residue)
    end
    self.residue:ListenForEvent("onremove", function() self:ForceDecayResidue() end, self.target)
end

function RoseInspectableUser:SetRoseInpectionOnPoint(point)
    self.target = nil
    self.point = point

    self:SpawnResidue()
end

--------------------------------------------------

function RoseInspectableUser:ForceDecayResidue()
    if self.residue then
        self.inst:RemoveEventCallback("onremove", self.residue._onresidueremoved, self.residue)
        self.residue:Decay()
    end
end

function RoseInspectableUser:SpawnResidue()
    self:ForceDecayResidue()

    local residue = SpawnPrefab("charlieresidue")
    self.residue = residue
    self.residue._onresidueremoved = function()
        self.residue = nil
    end
    self.inst:ListenForEvent("onremove", self.residue._onresidueremoved, self.residue)
    local x, y, z
    local theta = math.random() * PI2
    if self.target then
        x, y, z = self.target.Transform:GetWorldPosition()
        self.residue:SetTarget(self.target)
    else
        x, y, z = self.point:Get()
    end
    self.residue.Transform:SetPosition(x, y, z)
    self.residue:SetFXOwner(self.inst) -- Handles the self.inst's onremove event.
end

--------------------------------------------------

function RoseInspectableUser:DoRoseInspectionOnPoint()
    local is_cooldown = self:IsInCooldown()
    local dofailquip = false
    for _, config in ipairs(ROSEPOINT_CONFIGURATIONS) do
        local will_cooldown = false
        if config.forcedcooldown ~= nil then
            will_cooldown = config.forcedcooldown
        elseif config.cooldownfn ~= nil then
            will_cooldown = config.cooldownfn(self.inst, self.point, data)
        end
        local success, data = config.checkfn(self.inst, self.point)
        if success then
            if not will_cooldown or (will_cooldown and not is_cooldown) then
                config.callbackfn(self.inst, self.point, data)
                return will_cooldown
            else
                dofailquip = true
            end
        end
    end

    if dofailquip then
        self:DoQuip("ROSEGLASSES_COOLDOWN", true)
    end
    return false
end

--------------------------------------------------

function RoseInspectableUser:DoQuip(reason, failed)
    if failed then
        if self.inst.components.talker then
			local sgparam = { closeinspect = true }
			self.inst.components.talker:Say(GetActionFailString(self.inst, "LOOKAT", reason), nil, nil, nil, nil, nil, nil, nil, nil, sgparam)
        end
        return
    end
    if self.quipcooldowntime ~= nil and self.quipcooldowntime > GetTime() then
		self.inst:PushEvent("silentcloseinspect")
        return
    end
    if self.inst.components.talker then
        self.quipcooldowntime = GetTime() + 4 + math.random()
		local sgparam = { closeinspect = true }
		self.inst.components.talker:Say(GetString(self.inst, reason), nil, nil, nil, nil, nil, nil, nil, nil, sgparam)
    end
end

RoseInspectableUser.InvalidTags = {"lunar_aligned", "notroseinspectable"}

function RoseInspectableUser:TryToDoRoseInspectionOnTarget(target)
    if target.prefab == "charlieresidue" then
        self:ForceDecayResidue()
        return false, "ROSEGLASSES_DISMISS"
    end

    if not CLOSEINSPECTORUTIL.IsValidTarget(self.inst, target) then
        return false, "ROSEGLASSES_INVALID"
    end

    if target:HasAnyTag(self.InvalidTags) then
        return false, "ROSEGLASSES_INVALID"
    end

    local roseinspectable = target.components.roseinspectable
    if roseinspectable == nil then
        return false, "ROSEGLASSES_INVALID"
    end

    if not roseinspectable:CanResidueBeSpawnedBy(self.inst) then
        return false, "ROSEGLASSES_STUMPED"
    end

    local will_cooldown = roseinspectable:WillInduceCooldownOnActivate(self.inst)
    if will_cooldown and self:IsInCooldown() then
        return false, "ROSEGLASSES_COOLDOWN"
    end

    self:SetRoseInpectionOnTarget(target)

    self:DoQuip("ANNOUNCE_ROSEGLASSES")
    return true
end

function RoseInspectableUser:TryToDoRoseInspectionOnPoint(pt)
    self:SetRoseInpectionOnPoint(pt)

    self:DoQuip("ANNOUNCE_ROSEGLASSES")
    return true
end

--------------------------------------------------

RoseInspectableUser.OnCooldown_Bridge = function(inst)
    local self = inst.components.roseinspectableuser
    self:OnCooldown()
end
function RoseInspectableUser:ApplyCooldown(duration)
    self.cooldowntask = self.inst:DoTaskInTime(duration, self.OnCooldown_Bridge)
    local player_classified = self.inst.player_classified
    if player_classified then
        player_classified.roseglasses_cooldown:set(true)
    end
end
function RoseInspectableUser:OnCooldown()
    self.cooldowntask = nil
    local player_classified = self.inst.player_classified
    if player_classified then
        player_classified.roseglasses_cooldown:set(false)
    end
end

function RoseInspectableUser:IsInCooldown()
    return self.cooldowntask ~= nil
end

--------------------------------------------------

function RoseInspectableUser:OnSave()
    local data = {}

    local timeleft = GetTaskRemaining(self.cooldowntask)
    if timeleft > 0 then
        data.cooldown = timeleft
    end

    return data
end

function RoseInspectableUser:OnLoad(data)
    if data == nil then
        return
    end

    if data.cooldown ~= nil then
        self:ApplyCooldown(data.cooldown)
    end
end

function RoseInspectableUser:LongUpdate(dt)
    if self.cooldowntask ~= nil then
        local remaining = GetTaskRemaining(self.cooldowntask) - dt
        self.cooldowntask:Cancel()
        if remaining > 0 then
            self:ApplyCooldown(remaining)
        else
            self:OnCooldown()
        end
    end
end

--------------------------------------------------

function RoseInspectableUser:GetDebugString()
    return string.format("Target: %s, Cooldown: %.1f", self.target and tostring(self.target) or self.point and tostring(self.point) or "N/A", GetTaskRemaining(self.cooldowntask))
end

return RoseInspectableUser
