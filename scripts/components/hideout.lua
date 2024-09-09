--- Like an inventory for creatures; gives creatures an alternate "home" to go to.

local Hideout = Class(function(self, inst)
    self.inst = inst
    self.storedcreatures = {}
    self.numstoredcreatures = 0

    self.onvacate = nil
    self.onoccupied = nil
    self.onspawned = nil
    self.ongohome = nil

    self.timetonextspawn = 0
    self.spawnperiod = 20
    self.spawnvariance = 2

    self.spawnoffscreen = false

    -- possible other features:
    -- max occupants
    -- restrict occupants by tag
    -- ... but I don't need 'em.

    self.task = nil
end)

function Hideout:SetSpawnPeriod(period, variance)
    self.spawnperiod = period
    self.spawnvariance = variance or period * 0.1
end

function Hideout:OnUpdate(dt)
    self.timetonextspawn = self.timetonextspawn - dt
    if self:CanRelease() and self.timetonextspawn < 0 then
        self.timetonextspawn = self.spawnperiod + (math.random() * 2 - 1) * self.spawnvariance
        self:ReleaseChild()
    end
end

local function _OnUpdate(inst, self, dt)
    self:OnUpdate(dt)
end

function Hideout:StartUpdate()
    if self.task == nil then
        local dt = math.min(self.spawnperiod - self.spawnvariance, 5 + math.random() * 5)
        self.task = self.inst:DoPeriodicTask(dt, _OnUpdate, nil, self, dt)
    end
end

function Hideout:StartSpawning()
    --print(self.inst, "Hideout:StartSpawning()")
    self.timetonextspawn = 0
    self:StartUpdate()
end

function Hideout:StopSpawning()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

function Hideout:SetOccupiedFn(fn)
    self.onoccupied = fn
end

function Hideout:SetSpawnedFn(fn)
    self.onspawned = fn
end

function Hideout:SetGoHomeFn(fn)
    self.ongohome = fn
end

function Hideout:SetVacateFn(fn)
    self.onvacate = fn
end

function Hideout:OnSave()
    --print(self.inst, "Hideout:OnSave")
    local references = {}
    local data = {}
    data.storedcreatures = {}

    for _, creature in pairs(self.storedcreatures) do
        table.insert(references,creature.GUID)
        table.insert(data.storedcreatures,creature.GUID)
    end
    data.spawning = self.task ~= nil

    return data, references
end

function Hideout:OnLoad(data, newents)
    --print(self.inst, "Hideout:OnLoad")
    if data.spawning then
        self:StartSpawning()
    end
end

function Hideout:LoadPostPass(newents, data)
    --print(self.inst, "Hideout:LoadPostPass")
    if data.storedcreatures and #data.storedcreatures > 0 then
        for i,v in ipairs(data.storedcreatures) do
            local child = newents[v]
            if child then
                child = child.entity
                self:GoHome(child)
            end
        end
    end
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

-- This should only be called internally
function Hideout:DoReleaseChild(target, child, radius)
    if child == nil or self.storedcreatures[child] == nil then
        return
    end

    local pos = self.inst:GetPosition()
    local offset = FindWalkableOffset(pos, math.random() * TWOPI, (radius or .5) + self.inst:GetPhysicsRadius(0), 8, false, true, NoHoles)
    if offset == nil then
        return
    end

    child:ReturnToScene()
    child.Transform:SetPosition(pos.x + offset.x, pos.y, pos.z + offset.z)
    if child.components.brain ~= nil then
        BrainManager:Wake(child)
    end

    if target ~= nil and child.components.combat ~= nil then
        child.components.combat:SetTarget(target)
    end

    if self.onspawned ~= nil then
        self.onspawned(self.inst, child)
    end

    return child
end

function Hideout:ReleaseChild(target, prefab, radius)
    if not self:CanRelease() then
        return
    end

    --print(self.inst, "Hideout:ReleaseChild")

    local child = GetRandomItem(self.storedcreatures)

    local success = self:DoReleaseChild(target, child, radius)
    if success then
        if self.numstoredcreatures == 1 and self.onvacate then
            self:onvacate(self.inst)
        end
        self.storedcreatures[child] = nil
        self.numstoredcreatures = GetTableSize(self.storedcreatures)
    end
    return child
end

function Hideout:GoHome( child )
    if self.storedcreatures[child] ~= nil then
        print("Ack! We already have this child inside!?")
        return
    end

    self.storedcreatures[child] = child
    self.numstoredcreatures = GetTableSize(self.storedcreatures)

    child:RemoveFromScene()
    child.Transform:SetPosition(0,0,0)
    if child.components.brain then
        BrainManager:Hibernate(child)
    end
    if child.SoundEmitter then
        child.SoundEmitter:KillAllSounds()
    end

    if self.ongohome then
        self.ongohome(self.inst, count)
    end

    if self.numstoredcreatures == 1 and self.onoccupied then
        self:onoccupied(self.inst)
    end
end

function Hideout:CanRelease()
    if self.numstoredcreatures <= 0 then
        return false
    end

    if self.inst:IsAsleep() and not self.spawnoffscreen then
        return false
    end

    if not self.inst:IsValid() then
        return false
    end

    if self.inst.components.health and self.inst.components.health:IsDead() then
        return false
    end

    if self.canrealeasefn then
        self.canrealeasefn(self.inst)
    end

    return true
end

function Hideout:ReleaseAllChildren(target, prefab)
    while self:CanRelease() do
        self:ReleaseChild(target, prefab)
    end
end

function Hideout:LongUpdate(dt)
    if self.task ~= nil then
        self:OnUpdate(dt)
    end
end

function Hideout:GetDebugString()
    local str = ""

    if self.task ~= nil then
        str = str.."Spawning : "
        if self.numstoredcreatures > 0 then
            str = str..string.format(" Spawn in %2.2f ", self.timetonextspawn )
        end
    end

    str = str.." Inside: "
    for k,v in pairs(self.storedcreatures) do
        str = str .. v.prefab .. ", "
    end

    if self.numstoredcreatures > 5 then
        str = str .. " and "..(self.numstoredcreatures-5).. " more. "
    end

    return str
end

return Hideout
