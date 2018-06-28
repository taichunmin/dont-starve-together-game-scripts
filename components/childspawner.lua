--- Spawns and tracks child entities in the world
-- For setup the following params should be set
-- @param childname The prefab name of the default child to be spawned. This can be overridden in the SpawnChild method
-- @param delay The time between spawning children when the spawner is actively spawning. If nil, only manual spawning works.
-- @param newchilddelay The time it takes for a killed/captured child to be regenerated in the childspawner. If nil, dead children aren't regenerated.
-- It's also a good idea to call SetMaxChildren as part of the childspawner setup.

local function AddChildOutside(self, child)
    if self.childrenoutside[child] ~= nil then
        print("Ack! We already have this child outside!?")
        return
    end

    self.childrenoutside[child] = child
    self.numchildrenoutside = GetTableSize(self.childrenoutside)
end

local function RemoveChildOutside(self, child)
    if self.childrenoutside[child] == nil then
        print("Ack! That's not our child, or he's not outside!")
        return
    end

    self.childrenoutside[child] = nil
    self.numchildrenoutside = GetTableSize(self.childrenoutside)
end

local function AddEmergencyChildOutside(self, child)
    self.emergencychildrenoutside[child] = child
    self.numemergencychildrenoutside = GetTableSize(self.emergencychildrenoutside)
end

local function RemoveEmergencyChildOutside(self, child)
    self.emergencychildrenoutside[child] = nil
    self.numemergencychildrenoutside = GetTableSize(self.emergencychildrenoutside)
end

local function AddChildListeners(self, child)
    self.inst:ListenForEvent("ontrapped", self._onchildkilled, child)
    self.inst:ListenForEvent("death", self._onchildkilled, child)
    self.inst:ListenForEvent("detachchild", self._onchildkilled, child)
end

local function RemoveChildListeners(self, child)
    self.inst:RemoveEventCallback("ontrapped", self._onchildkilled, child)
    self.inst:RemoveEventCallback("death", self._onchildkilled, child)
    self.inst:RemoveEventCallback("detachchild", self._onchildkilled, child)
end

local ChildSpawner = Class(function(self, inst)
    self.inst = inst
    self.childrenoutside = {}
    self.childreninside = 1
    self.numchildrenoutside = 0
    self.maxchildren = 0

    self.childname = ""
    self.rarechild = nil
    self.rarechildchance = 0.1

    self.onvacate = nil
    self.onoccupied = nil
    self.onspawned = nil
    self.ongohome = nil

    self.spawning = false
    self.timetonextspawn = 0
    self.spawnperiod = 20
    self.spawnvariance = 2
	--self.spawnradius = nil

    self.regening = true
    self.timetonextregen = 0
    self.regenperiod = 20
    self.regenvariance = 2
    self.spawnoffscreen = false

    self.task = nil

    -- "Emergency" children, for when multiple players are around
    -- This is almost like a second spawner running alongside the first
    self.emergencychildname = nil
    self.emergencychildrenperplayer = 1
    self.maxemergencychildren = 0
    self.maxemergencycommit = 0
    self.emergencydetectionradius = 10

    self.emergencychildreninside = 0
    self.emergencychildrenoutside = {}
    self.numemergencychildrenoutside = 0

    self._onchildkilled = function(child) self:OnChildKilled(child) end
end)

function ChildSpawner:OnRemoveFromEntity()
    for k, v in pairs(self.childrenoutside) do
        RemoveChildListeners(self, v)
    end
    for k, v in pairs(self.emergencychildrenoutside) do
        RemoveChildListeners(self, v)
    end
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

function ChildSpawner:StartRegen()
    self.regening = true

    if self.numchildrenoutside + self.childreninside < self.maxchildren or
        self.numemergencychildrenoutside + self.emergencychildreninside < self.maxemergencychildren then

        self.timetonextregen = self.regenperiod + (math.random()*2-1)*self.regenvariance
        self:StartUpdate(6)
    end
end

function ChildSpawner:SetRareChild(childname, chance)
    self.rarechild = childname
    self.rarechildchance = chance
end

function ChildSpawner:StopRegen()
    self.regening = false
end

function ChildSpawner:SetSpawnPeriod(period, variance)
    self.spawnperiod = period
    self.spawnvariance = variance or period * 0.1
end

function ChildSpawner:SetRegenPeriod(period, variance)
    self.regenperiod = period
    self.regenvariance = variance or period * 0.1
end

function ChildSpawner:SetEmergencyRadius(rad)
    self.emergencydetectionradius = rad
end

function ChildSpawner:IsFull() 
	return (self.numchildrenoutside + self.childreninside) >= self.maxchildren
end

function ChildSpawner:NumChildren() 
	return self.numchildrenoutside + self.childreninside
end

function ChildSpawner:OnUpdate(dt)
    if self.regening then
        local missingchildren = self.numchildrenoutside + self.childreninside < self.maxchildren
        local missingemergencychildren = self.numemergencychildrenoutside + self.emergencychildreninside < self.maxemergencychildren
        if missingchildren or missingemergencychildren then
            self.timetonextregen = self.timetonextregen - dt
            if self.timetonextregen < 0 then
                self.timetonextregen = self.regenperiod + (math.random()*2-1)*self.regenvariance
                if missingchildren then
                    self:AddChildrenInside(1)
                end
                if missingemergencychildren then
                    self:AddEmergencyChildrenInside(1)
                end
            end
        else
            self.timetonextregen = self.regenperiod + (math.random()*2-1)*self.regenvariance
        end
    end

    if self.spawning then
        if self.childreninside > 0 then
            self.timetonextspawn = self.timetonextspawn - dt
            if self.timetonextspawn < 0 then
                self.timetonextspawn = self.spawnperiod + (math.random()*2-1)*self.spawnvariance
                self:SpawnChild()
            end
        else
            self.timetonextspawn = 0
        end
    end

    if self.task ~= nil and
        --check need to continue spawning
        not (self.spawning and self.childreninside > 0) and
        --check need to continue regening
        not (self.regening
            and (self.numchildrenoutside + self.childreninside < self.maxchildren or
                self.numemergencychildrenoutside + self.emergencychildreninside < self.maxemergencychildren))
        then

        self.task:Cancel()
        self.task = nil
    end
end

local function _OnUpdate(inst, self, dt)
    self:OnUpdate(dt)
end

function ChildSpawner:StartUpdate(dt)
    if self.task == nil then
        local dt = 5 + math.random() * 5
        self.task = self.inst:DoPeriodicTask(dt, _OnUpdate, nil, self, dt)
    end
end

function ChildSpawner:StartSpawning()
    --print(self.inst, "ChildSpawner:StartSpawning()")
    self.spawning = true
    self.timetonextspawn = 0
    self:StartUpdate(6)
end

function ChildSpawner:StopSpawning()
    self.spawning = false
end

function ChildSpawner:SetOccupiedFn(fn)
    self.onoccupied = fn
end

function ChildSpawner:SetSpawnedFn(fn)
    self.onspawned = fn
end

function ChildSpawner:SetGoHomeFn(fn)
    self.ongohome = fn
end

function ChildSpawner:SetVacateFn(fn)
    self.onvacate = fn
end

function ChildSpawner:SetOnChildKilledFn(fn)
	self.onchildkilledfn = fn
end

function ChildSpawner:SetOnAddChildFn(fn)
    self.onaddchild = fn
end

function ChildSpawner:CountChildrenOutside(fn)
    local vacantchildren = 0
    for k,v in pairs(self.childrenoutside) do
        if v and v:IsValid() and (not fn or fn(v) ) then
            vacantchildren = vacantchildren + 1
        end
    end
    return vacantchildren
end

function ChildSpawner:SetMaxChildren(max)
    self.childreninside = max - self:CountChildrenOutside()
    self.maxchildren = max
    if self.childreninside < 0 then self.childreninside = 0 end
end

function ChildSpawner:SetMaxEmergencyChildren(max)
    self.emergencychildreninside = max - self.numemergencychildrenoutside
    self.emergencychildreninside = math.max(0, self.emergencychildreninside)
    self.maxemergencychildren = max
    if self.emergencychildreninside < 0 then self.emergencychildreninside = 0 end
end

function ChildSpawner:OnSave()
    local data = {}
    local references = {}

    for k, v in pairs(self.childrenoutside) do
        if data.childrenoutside == nil then
            data.childrenoutside = { v.GUID }
        else
            table.insert(data.childrenoutside, v.GUID)
        end

        table.insert(references, v.GUID)
    end
    data.childreninside = self.childreninside

    for k, v in pairs(self.emergencychildrenoutside) do
        if data.emergencychildrenoutside == nil then
            data.emergencychildrenoutside = { v.GUID }
        else
            table.insert(data.emergencychildrenoutside, v.GUID)
        end

        table.insert(references, v.GUID)
    end
    data.emergencychildreninside = self.emergencychildreninside

    data.spawning = self.spawning
    data.regening = self.regening
    data.timetonextregen = math.floor(self.timetonextregen)
    data.timetonextspawn = math.floor(self.timetonextspawn)

    return data, references
end

function ChildSpawner:GetDebugString()
    local str = string.format("%s: %d in, %d out", self.childname, self.childreninside, self.numchildrenoutside)

    local num_children = self.numchildrenoutside + self.childreninside
    if num_children < self.maxchildren and self.regening then
        str = str..string.format(" Regen in %2.2f ", self.timetonextregen)
    end

    if self.childreninside > 0 and self.spawning then
        str = str..string.format(" Spawn in %2.2f ", self.timetonextspawn)
    end

    if self.spawning then
        str = str.." : Spawning "
    end

    if self.regening then
        str = str.." : Regening :"
    end

    if self.maxemergencychildren > 0 then
        str = str..string.format(" emgergency: %d in %d out (commit %d/%d)", self.emergencychildreninside, self.numemergencychildrenoutside, self.maxemergencycommit, self.maxemergencychildren)
    end

    return str
end

function ChildSpawner:OnLoad(data)
    --print(self.inst, "ChildSpawner:OnLoad")

    --convert previous data
    if data.occupied then
        data.childreninside = 1
    end
    if data.childid ~= nil then
        data.childrenoutside = { data.childid }
    end

    if data.childreninside ~= nil then
        self.childreninside = 0
        self:AddChildrenInside(data.childreninside)
        if self.childreninside > 0 and self.onoccupied ~= nil then
            self.onoccupied(self.inst)
        elseif self.childreninside == 0 and self.onvacate ~= nil then
            self.onvacate(self.inst)
        end
    end

    self.spawning = data.spawning or self.spawning
    self.regening = data.regening or self.regening
    self.timetonextregen = data.timetonextregen or self.timetonextregen
    self.timetonextspawn = data.timetonextspawn or self.timetonextspawn

    if data.emergencychildreninside ~= nil then
        self.emergencychildreninside = 0
        self:AddEmergencyChildrenInside(data.emergencychildreninside)
    end
    self.maxemergencycommit = data.maxemergencycommit or 0

    if self.spawning or self.regening then
        self:StartUpdate(6)
    end
end

function ChildSpawner:DoTakeOwnership(child)
    if child.components.knownlocations ~= nil then
        child.components.knownlocations:RememberLocation("home", self.inst:GetPosition())
    end
	if child.components.homeseeker == nil then
	    child:AddComponent("homeseeker")
	end
    child.components.homeseeker:SetHome(self.inst)
    AddChildListeners(self, child)
end

function ChildSpawner:TakeOwnership(child)
    self:DoTakeOwnership(child)
    AddChildOutside(self, child)
end

function ChildSpawner:TakeEmergencyOwnership(child)
    self:DoTakeOwnership(child)
    AddEmergencyChildOutside(self, child)
end

function ChildSpawner:LoadPostPass(newents, savedata)
    --print(self.inst, "ChildSpawner:LoadPostPass")
    if savedata.childrenoutside ~= nil then
        for i, v in ipairs(savedata.childrenoutside) do
            local child = newents[v]
            if child ~= nil then
                self:TakeOwnership(child.entity)
            end
        end
    end
    if savedata.emergencychildrenoutside ~= nil then
        for i, v in ipairs(savedata.emergencychildrenoutside) do
            local child = newents[v]
            if child ~= nil then
                self:TakeEmergencyOwnership(child.entity)
            end
        end
    end
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

-- This should only be called interally
function ChildSpawner:DoSpawnChild(target, prefab, radius)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local offset = FindWalkableOffset(Vector3(x, 0, z), math.random() * PI * 2, (radius or self.spawnradius or .5) + self.inst:GetPhysicsRadius(0), 8, false, true, NoHoles)
    if offset == nil then
        return
    end

    local child =
        SpawnPrefab(
            self.rarechild ~= nil and
            math.random() < self.rarechildchance and
            self.rarechild or
            prefab or
            self.childname
        )
    if child ~= nil then
        child.Transform:SetPosition(x + offset.x, 0, z + offset.z)
        if target ~= nil and child.components.combat ~= nil then
            child.components.combat:SetTarget(target)
        end

        if self.onspawned ~= nil then
            self.onspawned(self.inst, child)
        end
    end
    return child
end

function ChildSpawner:SpawnChild(target, prefab, radius)
    if not self:CanSpawn() then
        return
    end

    --print(self.inst, "ChildSpawner:SpawnChild")

    local child = self:DoSpawnChild(target, prefab or self.childname, radius)
    if child ~= nil then
        self:TakeOwnership(child)
        if self.childreninside == 1 and self.onvacate ~= nil then
            self.onvacate(self.inst)
        end
        self.childreninside = self.childreninside - 1
    end
    return child
end

function ChildSpawner:SpawnEmergencyChild(target, prefab, radius)
    if not self:CanEmergencySpawn() then
        return
    end

    --print(self.inst, "ChildSpawner:SpawnEmergencyChild")

    local child = self:DoSpawnChild(target, prefab or self.emergencychildname, radius)
    if child ~= nil then
        self:TakeEmergencyOwnership(child)
        self.emergencychildreninside = self.emergencychildreninside - 1
    end
    return child
end

function ChildSpawner:UpdateMaxEmergencyCommit()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.emergencydetectionradius, { "player" }, { "playerghost" })
    self.maxemergencycommit = RoundBiasedDown(#ents * self.emergencychildrenperplayer)
end

function ChildSpawner:TrySpawnEmergencyChild()
    self:UpdateMaxEmergencyCommit()
    return self:SpawnEmergencyChild()
end

function ChildSpawner:GoHome( child )
    if self.childrenoutside[child] then
        self.inst:PushEvent("childgoinghome", {child = child})
        child:PushEvent("goinghome", {home = self.inst})
        if self.ongohome then
            self.ongohome(self.inst, child)
        end
        RemoveChildOutside(self, child)
        child:Remove()
        self:AddChildrenInside(1)
        return true
    end
    if self.emergencychildrenoutside[child] then
        self.inst:PushEvent("childgoinghome", { child = child })
        child:PushEvent("goinghome", { home = self.inst })
        if self.ongohome ~= nil then
            self.ongohome(self.inst, child)
        end
        RemoveEmergencyChildOutside(self, child)
        child:Remove()
        self:AddEmergencyChildrenInside(1)
        return true
    end
end

function ChildSpawner:CanSpawn()
    return self.inst:IsValid() --V2C: This valid check probably hid a lot of bugs that we could've caught and fixed =(
        and self.childreninside > 0
        and (self.spawnoffscreen or not self.inst:IsAsleep())
        and (self.inst.components.health == nil or not self.inst.components.health:IsDead())
        and (self.canspawnfn == nil or self.canspawnfn(self.inst))
end

function ChildSpawner:CanEmergencySpawn()
    return self.inst:IsValid() --V2C: This valid check probably hid a lot of bugs that we could've caught and fixed =(
        and self.emergencychildreninside > 0
        -- the num inside means 'comitted' is both outside and dead
        and self.maxemergencychildren - self.emergencychildreninside < self.maxemergencycommit
        and (self.spawnoffscreen or not self.inst:IsAsleep())
        and (self.inst.components.health == nil or not self.inst.components.health:IsDead())
end

function ChildSpawner:OnChildKilled(child)
    RemoveChildListeners(self, child)

    if self.childrenoutside[child] then
        RemoveChildOutside(self, child)

        if self.onchildkilledfn ~= nil then
            self.onchildkilledfn(self.inst, child)
        end

        if self.regening then
            self:StartUpdate(6)
        end
    end
    if self.emergencychildrenoutside[child] then
        RemoveEmergencyChildOutside(self, child)

        if self.regening then
            self:StartUpdate(6)
        end
    end
end

function ChildSpawner:ReleaseAllChildren(target, prefab)
    while self:CanSpawn() do
        self:SpawnChild(target, prefab)
    end
    self:UpdateMaxEmergencyCommit()
    while self:CanEmergencySpawn() do
        self:SpawnEmergencyChild(target, prefab)
    end
end

function ChildSpawner:AddChildrenInside(count)
    if self.childreninside == 0 and self.onoccupied then
        self.onoccupied(self.inst)
    end
    self.childreninside = self.childreninside + count
    if self.maxchildren ~= nil then
        self.childreninside = math.min(self.maxchildren, self.childreninside)
    end
    if self.onaddchild ~= nil then
        self.onaddchild(self.inst, count)
    end

    if self.spawning or self.regening then
        self:StartUpdate(6)
    end
end

function ChildSpawner:AddEmergencyChildrenInside(count)
    self.emergencychildreninside = self.emergencychildreninside + count
    if self.maxemergencychildren then
        self.emergencychildreninside = math.min(self.maxemergencychildren, self.emergencychildreninside)
    end
end

function ChildSpawner:LongUpdate(dt)
    if self.spawning then
        self:OnUpdate(dt)
    end
end

return ChildSpawner
