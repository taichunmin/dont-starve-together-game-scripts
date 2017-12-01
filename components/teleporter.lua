local function onavailable(self)
    if self.targetTeleporter ~= nil and self.enabled == true then
        self.inst:AddTag("teleporter")
    else
        self.inst:RemoveTag("teleporter")
    end
end

local Teleporter = Class(function(self, inst)
    self.inst = inst
    self.targetTeleporter = nil
    self.onActivate = nil
    self.onActivateByOther = nil
    self.offset = 2
    self.enabled = true
    self.numteleporting = 0
    self.teleportees = {}
    self.saveenabled = true

    self.travelcameratime = 3
    self.travelarrivetime = 4

    self._onremoveteleportee = function(doer) self:UnregisterTeleportee(doer) end
end,
nil,
{
    targetTeleporter = onavailable,
    enabled = onavailable,
})

function Teleporter:OnRemoveFromEntity()
    self.inst:RemoveTag("teleporter")
end

function Teleporter:IsActive()
    return self.enabled and self.targetTeleporter ~= nil
end

function Teleporter:IsBusy()
    return self.numteleporting > 0 or next(self.teleportees) ~= nil
end

function Teleporter:IsTargetBusy()
    return self.targetTeleporter ~= nil and self.targetTeleporter.components.teleporter:IsBusy()
end

--Notifies ahead of time that someone will try to teleport soon
function Teleporter:RegisterTeleportee(doer)
    if not self.teleportees[doer] then
        self.teleportees[doer] = true
        self.inst:ListenForEvent("onremove", self._onremoveteleportee, doer)
    end
end

function Teleporter:UnregisterTeleportee(doer)
    if self.teleportees[doer] then
        self.teleportees[doer] = nil
        self.inst:RemoveEventCallback("onremove", self._onremoveteleportee, doer)
    end
end

function Teleporter:Activate(doer)
    if not self:IsActive() then
        return false
    end

    if self.onActivate ~= nil then
        self.onActivate(self.inst, doer)
    end

    if self.targetTeleporter.components.teleporter ~= nil then
        if self.targetTeleporter.components.teleporter.onActivateByOther ~= nil then
            self.targetTeleporter.components.teleporter.onActivateByOther(self.targetTeleporter, self.inst, doer)
        end
        self.targetTeleporter.components.teleporter.numteleporting = self.targetTeleporter.components.teleporter.numteleporting + 1
    end

    self:Teleport(doer)

    if self.targetTeleporter.components.teleporter ~= nil then
        if doer:HasTag("player") then
            self.targetTeleporter.components.teleporter:ReceivePlayer(doer)
        elseif doer.components.inventoryitem ~= nil then
            self.targetTeleporter.components.teleporter:ReceiveItem(doer)
        end
    end

    if doer.components.leader ~= nil then
        for follower, v in pairs(doer.components.leader.followers) do
            self:Teleport(follower)
        end
    end

    --special case for the chester_eyebone: look for inventory items with followers
    if doer.components.inventory ~= nil then
        for k, item in pairs(doer.components.inventory.itemslots) do
            if item.components.leader ~= nil then
                for follower, v in pairs(item.components.leader.followers) do
                    self:Teleport(follower)
                end
            end
        end
        -- special special case, look inside equipped containers
        for k, equipped in pairs(doer.components.inventory.equipslots) do
            if equipped.components.container ~= nil then
                for j, item in pairs(equipped.components.container.slots) do
                    if item.components.leader ~= nil then
                        for follower, v in pairs(item.components.leader.followers) do
                            self:Teleport(follower)
                        end
                    end
                end
            end
        end
    end

    return true
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function NoPlayersOrHoles(pt)
    return not (IsAnyPlayerInRange(pt.x, 0, pt.z, 2) or TheWorld.Map:IsPointNearHole(pt))
end

-- You probably don't want this, call Activate instead.
function Teleporter:Teleport(obj)
    if self.targetTeleporter ~= nil then
        local target_x, target_y, target_z = self.targetTeleporter.Transform:GetWorldPosition()
        local offset = self.targetTeleporter.components.teleporter ~= nil and self.targetTeleporter.components.teleporter.offset or 0
        if offset ~= 0 then
            local pt = Vector3(target_x, target_y, target_z)
            local angle = math.random() * 2 * PI
            offset =
                FindWalkableOffset(pt, angle, offset, 8, true, false, NoPlayersOrHoles) or
                FindWalkableOffset(pt, angle, offset * .5, 6, true, false, NoPlayersOrHoles) or
                FindWalkableOffset(pt, angle, offset, 8, true, false, NoHoles) or
                FindWalkableOffset(pt, angle, offset * .5, 6, true, false, NoHoles)
            if offset ~= nil then
                target_x = target_x + offset.x
                target_z = target_z + offset.z
            end
        end
        if obj.Physics ~= nil then
            obj.Physics:Teleport(target_x, target_y, target_z)
        elseif obj.Transform ~= nil then
            obj.Transform:SetPosition(target_x, target_y, target_z)
        end
    end
end

function Teleporter:PushDoneTeleporting(obj)
    self.inst:PushEvent("doneteleporting", obj)
end

local function onitemarrive(inst, self, item)
    -- V2C: can reach here even if item goes invalid because
    --      this is not a task or event handler on the item.
    if item:IsValid() then
        inst:RemoveChild(item)
        item:ReturnToScene()

        if item.Transform ~= nil then
            local x, y, z = item.Transform:GetWorldPosition()
            local angle = math.random() * 2 * PI
            if item.Physics ~= nil then
                item.Physics:Stop()
                if item:IsAsleep() then
                    local radius = inst:GetPhysicsRadius(0) + math.random()
                    item.Physics:Teleport(
                        x + math.cos(angle) * radius,
                        0,
                        z - math.sin(angle) * radius)
                else
                    local bounce = item.components.inventoryitem ~= nil and not item.components.inventoryitem.nobounce
                    local speed = (bounce and 3 or 4) + math.random() * .5 + inst:GetPhysicsRadius(0)
                    item.Physics:Teleport(x, 0, z)
                    item.Physics:SetVel(
                        speed * math.cos(angle),
                        bounce and speed * 3 or 0,
                        speed * math.sin(angle))
                end
            else
                local radius = 2 + math.random() * .5
                item.Transform:SetPosition(
                    x + math.cos(angle) * radius,
                    0,
                    z - math.sin(angle) * radius)
            end
        end
    else
        item = nil
    end

    self.numteleporting = self.numteleporting - 1
    self:PushDoneTeleporting(item)
end

function Teleporter:ReceiveItem(item)
    item:RemoveFromScene()
    TemporarilyRemovePhysics(item, 4.5)
    self.inst:AddChild(item)
    self.inst:DoTaskInTime(.5, onitemarrive, self, item)
end

local function oncameraarrive(inst, doer)
    -- V2C: can reach here even if doer goes invalid because
    --      this is not a task or event handler on the doer.
    if doer:IsValid() then
        doer:SnapCamera()
        doer:ScreenFade(true, 2)
    end
end

local function ondoerarrive(inst, self, doer)
    -- V2C: can reach here even if doer goes invalid because
    --      this is not a task or event handler on the doer.
    if not doer:IsValid() then
        doer = nil
    elseif doer.sg.statemem.teleportarrivestate ~= nil then
        doer.sg:GoToState(doer.sg.statemem.teleportarrivestate)
    end
    self.numteleporting = self.numteleporting - 1
    self:PushDoneTeleporting(doer)
end

function Teleporter:ReceivePlayer(doer)
    doer:ScreenFade(false)
    self.inst:DoTaskInTime(self.travelcameratime, oncameraarrive, doer)
    self.inst:DoTaskInTime(self.travelarrivetime, ondoerarrive, self, doer)
end

function Teleporter:Target(otherTeleporter)
    self.targetTeleporter = otherTeleporter
end

function Teleporter:SetEnabled(enabled)
    self.enabled = enabled
end

function Teleporter:OnSave()
    if self.saveenabled and self.targetTeleporter ~= nil then
        return { target = self.targetTeleporter.GUID }, { self.targetTeleporter.GUID }
    end
end

function Teleporter:LoadPostPass(newents, savedata)
    if savedata ~= nil and savedata.target ~= nil then
        local targEnt = newents[savedata.target]
        if targEnt ~= nil and targEnt.entity.components.teleporter ~= nil then
            self.targetTeleporter = targEnt.entity
        end
    end
end

function Teleporter:GetDebugString()
    return "Enabled: "..(self.enabled and "T" or "F").." Target:"..tostring(self.targetTeleporter)
end

return Teleporter
