-- spawner in unique from childspawner in that it manages a single persistant entity
-- (eg. a specific named pigman with a specific hat)
-- whereas childspawner creates and destroys one or more generic entities as they enter
-- and leave the spawner (eg. spiders). it can manage more than one, but can not maintain
-- individual properties of each entity

local function OnReleaseChild(inst, self)
    self.task = nil
    if not self.spawnoffscreen or inst:IsAsleep() then
        self:ReleaseChild()
    end
end

local function OnEntitySleep(inst)
    local self = inst.components.spawner
    if self and (self.useexternaltimer and self.externaltimerfinished) or (self.nextspawntime and GetTime() > self.nextspawntime) then
        self:ReleaseChild()
    end
end

local Spawner = Class(function(self, inst)
    self.inst = inst
    self.child = nil
    self.delay = 0
    self.onoccupied = nil
    self.onvacate = nil
    self.spawnoffscreen = nil
    --self.spawn_in_water
    --self.spawn_on_boats

    self.task = nil
    self.nextspawntime = nil
    self.queue_spawn = nil
    self.retry_period = nil

    self._onchildkilled = function(child) self:OnChildKilled(child) end

    self.useexternaltimer = false
    --self.externaltimerfinished = false
    --self.starttimerfn = nil
    --self.stoptimerfn = nil
    --self.timertestfn = nil
end)

function Spawner:OnRemoveFromEntity()
    if self.spawnoffscreen then
        self.inst:RemoveEventCallback("entitysleep", OnEntitySleep)
    end
    if self.child ~= nil and self.child.parent ~= self.inst then
        --Child is outside, release it!
        self.inst:RemoveEventCallback("ontrapped", self._onchildkilled, self.child)
        self.inst:RemoveEventCallback("death", self._onchildkilled, self.child)
        self.inst:RemoveEventCallback("detachchild", self._onchildkilled, self.child)
    end
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

function Spawner:GetDebugString()
    return "child: "..tostring(self.child)
        ..(self:IsOccupied() and " occupied" or "")
        ..(self.queue_spawn and " queued" or "")
        ..(self.nextspawntime ~= nil and string.format(" spawn in %2.2fs", self.nextspawntime - GetTime()) or "")
end

function Spawner:SetOnOccupiedFn(fn)
    self.onoccupied = fn
end

function Spawner:SetOnVacateFn(fn)
    self.onvacate = fn
end

function Spawner:SetWaterSpawning(spawn_in_water, spawn_on_boats)
    self.spawn_in_water = spawn_in_water
    self.spawn_on_boats = spawn_on_boats
end

function Spawner:SetOnlySpawnOffscreen(offscreen)
    if offscreen then
        if not self.spawnoffscreen then
            self.spawnoffscreen = true
            self.inst:ListenForEvent("entitysleep", OnEntitySleep)
        end
    elseif self.spawnoffscreen then
        self.spawnoffscreen = nil
        self.inst:RemoveEventCallback("entitysleep", OnEntitySleep)
    end
end

function Spawner:Configure(childname, delay, startdelay)
    self.childname = childname
    self.delay = delay

    self:SpawnWithDelay(startdelay or 0)
end

function Spawner:SpawnWithDelay(delay)
    delay = math.max(0, delay)
    if self.useexternaltimer then
        self.starttimerfn(self.inst, delay)
    else
        self.nextspawntime = GetTime() + delay
        if self.task ~= nil then
            self.task:Cancel()
        end
        self.task = self.inst:DoTaskInTime(delay, OnReleaseChild, self)
    end
end

function Spawner:IsSpawnPending()
    if not self.useexternaltimer then
        return self.task ~= nil
    else
        return self.timertestfn(self.inst)
    end
end

function Spawner:SetQueueSpawning(queued, retryperiod)
    if queued then
        self.queue_spawn = true
        self.retryperiod = retryperiod
    else
        self.queue_spawn = nil
        self.retryperiod = nil
    end
end

function Spawner:CancelSpawning()
    if self.useexternaltimer then
        self.stoptimerfn(self.inst)
    else
        if self.task ~= nil then
            self.task:Cancel()
            self.task = nil
        end
        self.nextspawntime = nil
    end
end

function Spawner:OnSave()
    local data = {}
    if self.child ~= nil and self:IsOccupied() then
        data.child = self.child:GetSaveRecord()
    elseif self.child ~= nil and (self.child.components.health == nil or not self.child.components.health:IsDead()) then
        data.childid = self.child.GUID
    elseif not self.useexternaltimer and self.nextspawntime ~= nil then
        data.startdelay = self.nextspawntime - GetTime()
    elseif self.useexternaltimer and self.externaltimerfinished then
        data.externaltimerfinished = true
    end

    local refs = data.childid ~= nil and { data.childid } or nil
    return data, refs
end

function Spawner:OnLoad(data, newents)
    self:CancelSpawning()

    if data.child ~= nil then
        local child = SpawnSaveRecord(data.child, newents)
        if child ~= nil then
            self:TakeOwnership(child)
            self:GoHome(child)
        end
    end
    if not self.useexternaltimer and data.startdelay ~= nil then
        self:SpawnWithDelay(data.startdelay)
    end
    if self.useexternaltimer and data.externaltimerfinished then
        self.externaltimerfinished = data.externaltimerfinished
    end
end

function Spawner:TakeOwnership(child)
    if self.child ~= child then
        self.inst:ListenForEvent("ontrapped", self._onchildkilled, child)
        self.inst:ListenForEvent("death", self._onchildkilled, child)
        self.inst:ListenForEvent("detachchild", self._onchildkilled, child)
        if child.components.knownlocations ~= nil then
            child.components.knownlocations:RememberLocation("home", self.inst:GetPosition())
        end
        self.child = child
    end
    if child.components.homeseeker == nil then
        child:AddComponent("homeseeker")
    end
    child.components.homeseeker:SetHome(self.inst)
end

function Spawner:LoadPostPass(newents, savedata)
    if savedata.childid ~= nil then
        local child = newents[savedata.childid]
        if child ~= nil then
            child = child.entity
            self:TakeOwnership(child)
        end
    end
end

function Spawner:IsOccupied()
    return self.child ~= nil and self.child.parent == self.inst
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

function Spawner:ReleaseChild()
    self:CancelSpawning()

    if self.child == nil then
        local childname = self.childfn ~= nil and self.childfn(self.inst) or self.childname
        local child = SpawnPrefab(childname)
        if child ~= nil then
            self:TakeOwnership(child)
            if self:GoHome(child) then
                self:CancelSpawning()
            end
        end
    end

    if self:IsOccupied() then
        -- We want to release child, but are we set to queue the spawn right now?
        if self.queue_spawn and self.retryperiod ~= nil then
            self:SpawnWithDelay(self.retryperiod)
        -- If not, go for it!
        else
            self.inst:RemoveChild(self.child)
            self.child:ReturnToScene()

            local rad = .5 + self.inst:GetPhysicsRadius(0) + self.child:GetPhysicsRadius(0)
            local x, y, z = self.inst.Transform:GetWorldPosition()
            local start_angle = math.random() * 2 * PI

            local offset = FindWalkableOffset(Vector3(x, 0, z), start_angle, rad, 8, false, true, NoHoles, self.spawn_in_water or false, self.spawn_on_boats or false)
            if offset == nil then
                -- well it's gotta go somewhere!
                --print(self.inst, "Spawner:ReleaseChild() no good place to spawn child: ", self.child)
                x = x + rad * math.cos(start_angle)
                z = z - rad * math.sin(start_angle)
            else
                --print(self.inst, "Spawner:ReleaseChild() safe spawn of: ", self.child)
                x = x + offset.x
                z = z + offset.z
            end

            self:TakeOwnership(self.child)
            if self.child.Physics ~= nil then
                self.child.Physics:Teleport(x, 0, z)
            else
                self.child.Transform:SetPosition(x, 0, z)
            end

            if self.onvacate ~= nil then
                self.onvacate(self.inst, self.child)
            end
            return true
        end
    end
end

function Spawner:GoHome(child)
    if self.child == child and not self:IsOccupied() then
        self.inst:AddChild(child)
        child.Transform:SetPosition(0,0,0)
        child:RemoveFromScene()

        if child.components.locomotor ~= nil then
            child.components.locomotor:Stop()
        end

        if child.components.burnable ~= nil and child.components.burnable:IsBurning() then
            child.components.burnable:Extinguish()
        end

        --if child.components.health ~= nil and child.components.health:IsHurt() then
        --end

        if child.components.homeseeker ~= nil then
            child:RemoveComponent("homeseeker")
        end

        if self.onoccupied ~= nil then
            self.onoccupied(self.inst, child)
        end

        return true
    end
end

function Spawner:OnChildKilled(child)
    if self.child == child then
        self.child = nil
        self:SpawnWithDelay(self.delay)
    end
end

return Spawner
