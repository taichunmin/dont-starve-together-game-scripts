local function onavailable(self)
    if self:IsActive() then
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
    self.saveenabled = true -- this only toggles saving targetTeleporter

    self.travelcameratime = 3
    self.travelarrivetime = 4

	self.items = {} -- list of all things teleporting right now

    self._onremoveteleportee = function(doer) self:UnregisterTeleportee(doer) end
end,
nil,
{
    targetTeleporter = onavailable,
    migration_data = onavailable,
    enabled = onavailable,
})

function Teleporter:OnRemoveFromEntity()
    self.inst:RemoveTag("teleporter")
end

function Teleporter:IsActive()
    return self.enabled and (self.targetTeleporterTemporary ~= nil or self.targetTeleporter ~= nil or self.migration_data ~= nil)
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

function Teleporter:UseTemporaryExit(doer, temporaryexit)
    self.targetTeleporterTemporary = temporaryexit
    local travelarrivetime = self.travelarrivetime
    if temporaryexit == self.inst then
        self.stopcamerafades = true
        self.travelarrivetime = travelarrivetime * 0.1
    end
    local success = self:Activate(doer)
    self.stopcamerafades = nil
    self.travelarrivetime = travelarrivetime
    self.targetTeleporterTemporary = nil
    return success
end

function Teleporter:Activate(doer)
    if not self:IsActive() then
        return false
    end

    if self.onActivate ~= nil then
        self.onActivate(self.inst, doer, self.migration_data)
    end

	if self.migration_data ~= nil then
		local data = self.migration_data
		if data.worldid ~= TheShard:GetShardId() and Shard_IsWorldAvailable(data.worldid) then
			TheWorld:PushEvent("ms_playerdespawnandmigrate", { player = doer, portalid = nil, worldid = data.worldid, x = data.x, y = data.y, z = data.z })
			return true
		else
			return false
		end
	end

    self:Teleport(doer)

    local targetTeleporter = self.targetTeleporterTemporary or self.targetTeleporter

    if targetTeleporter.components.teleporter ~= nil then
        if doer:HasTag("player") then
            targetTeleporter.components.teleporter:ReceivePlayer(doer, self.inst)
        elseif doer.components.inventoryitem ~= nil then
            targetTeleporter.components.teleporter:ReceiveItem(doer, self.inst)
        end
    end

    if doer.components.leader ~= nil then
        for follower, v in pairs(doer.components.leader.followers) do
			if not (follower.components.follower ~= nil and follower.components.follower.noleashing) then
				self:Teleport(follower)
			end
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
    local targetTeleporter = self.targetTeleporterTemporary or self.targetTeleporter
    if targetTeleporter ~= nil then
        local target_x, target_y, target_z = targetTeleporter.Transform:GetWorldPosition()
        local offset = targetTeleporter.components.teleporter ~= nil and targetTeleporter.components.teleporter.offset or 0

        local is_aquatic = obj.components.locomotor ~= nil and obj.components.locomotor:IsAquatic()
		local allow_ocean = is_aquatic or obj.components.amphibiouscreature ~= nil or obj.components.drownable ~= nil

		if targetTeleporter.components.teleporter ~= nil and targetTeleporter.components.teleporter.trynooffset then
            local pt = Vector3(target_x, target_y, target_z)
			if FindWalkableOffset(pt, 0, 0, 1, true, false, NoPlayersOrHoles, allow_ocean) ~= nil then
				offset = 0
			end
		end

        if offset ~= 0 then
            local pt = Vector3(target_x, target_y, target_z)
            local angle = math.random() * TWOPI

            if not is_aquatic then
                offset =
                    FindWalkableOffset(pt, angle, offset, 8, true, false, NoPlayersOrHoles, allow_ocean) or
                    FindWalkableOffset(pt, angle, offset * .5, 6, true, false, NoPlayersOrHoles, allow_ocean) or
                    FindWalkableOffset(pt, angle, offset, 8, true, false, NoHoles, allow_ocean) or
                    FindWalkableOffset(pt, angle, offset * .5, 6, true, false, NoHoles, allow_ocean)
            else
                offset =
                    FindSwimmableOffset(pt, angle, offset, 8, true, false, NoPlayersOrHoles) or
                    FindSwimmableOffset(pt, angle, offset * .5, 6, true, false, NoPlayersOrHoles) or
                    FindSwimmableOffset(pt, angle, offset, 8, true, false, NoHoles) or
                    FindSwimmableOffset(pt, angle, offset * .5, 6, true, false, NoHoles)
            end

            if offset ~= nil then
                target_x = target_x + offset.x
                target_z = target_z + offset.z
            end
        end

        local ocean_at_point = TheWorld.Map:IsOceanAtPoint(target_x, target_y, target_z, false)
        if ocean_at_point then
			if not allow_ocean then
				local terrestrial = obj.components.locomotor ~= nil and obj.components.locomotor:IsTerrestrial()
				if terrestrial then
					return
				end
			end
        else
            if is_aquatic then
                return
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
	if self.OnDoneTeleporting ~= nil then
		self.OnDoneTeleporting(self.inst, obj)
	end
end

local function onitemarrive(inst, self, item)
    -- V2C: can reach here even if item goes invalid because
    --      this is not a task or event handler on the item.
	self.items[item] = nil
    if item:IsValid() then
        inst:RemoveChild(item)
        item.Transform:SetPosition(inst.Transform:GetWorldPosition())
		item:ReturnToScene()

		if item.Transform ~= nil then
            local x, y, z = item.Transform:GetWorldPosition()
            local angle = math.random() * TWOPI
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

function Teleporter:ReceiveItem(item, source)
    if self.onActivateByOther ~= nil then
        self.onActivateByOther(self.inst, source, item)
    end
    self.numteleporting = self.numteleporting + 1
	self.items[item] = true
    self.inst:AddChild(item)
    item.Transform:SetPosition(0,0,0) -- transform is now local?
    item:RemoveFromScene()

    self.inst:DoTaskInTime(3.5, onitemarrive, self, item)
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
    elseif self.overrideteleportarrivestate ~= nil then
        doer.sg:GoToState(self.overrideteleportarrivestate)
	elseif doer.sg.statemem.teleportarrivestate ~= nil then
        doer.sg:GoToState(doer.sg.statemem.teleportarrivestate)
    end
    self.numteleporting = self.numteleporting - 1
    self:PushDoneTeleporting(doer)
end

function Teleporter:ReceivePlayer(doer, source, skiptime)
    if self.onActivateByOther ~= nil then
        self.onActivateByOther(self.inst, source, doer)
    end

	if skiptime then
		skiptime = math.min(skiptime, self.travelarrivetime)
		if not self.stopcamerafades then
			skiptime = math.min(skiptime, self.travelcameratime)
		end
	else
		skiptime = 0
	end

    self.numteleporting = self.numteleporting + 1
    if not self.stopcamerafades then
        doer:ScreenFade(false)
		self.inst:DoTaskInTime(self.travelcameratime - skiptime, oncameraarrive, doer)
    else
        doer._failed_doneteleporting = true -- Hack for wisecracker to not change event parameters.
    end
	self.inst:DoTaskInTime(self.travelarrivetime - skiptime, ondoerarrive, self, doer)
end

function Teleporter:Target(otherTeleporter)
    self.targetTeleporter = otherTeleporter
end

function Teleporter:MigrationTarget(worldid, x, y, z)
	if worldid ~= nil then
	    self.migration_data = {worldid = worldid, x = x, y = y, z = z}
	else
		self.migration_data = nil
	end
end

function Teleporter:GetTarget()
    return self.targetTeleporter
end

function Teleporter:SetEnabled(enabled)
    self.enabled = enabled
end

function Teleporter:GetEnabled()
    return self.enabled
end

function Teleporter:OnSave()
    local data = { items = {} }
    local references = {}

	if self.saveenabled and self.targetTeleporter ~= nil then
		data.target = self.targetTeleporter.GUID
		table.insert(references, self.targetTeleporter.GUID)

		data.migration_data = self.migration_data
	end

    local refs = {}
    for item, v in pairs(self.items) do
        if item.persists then
            data.items[#data.items], refs = item:GetSaveRecord()
            if refs then
                for k,v in pairs(refs) do
                    table.insert(references, v)
                end
            end
        end
    end

	return data, references
end

function Teleporter:OnLoad(data, newents)
    if data.items ~= nil then
        for _, v in pairs(data.items) do
            local item = SpawnSaveRecord(v, newents)
            if item ~= nil then
                self:ReceiveItem(item, nil)
            end
        end
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
