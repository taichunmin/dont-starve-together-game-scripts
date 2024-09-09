local MoonBeastSpawner = Class(function(self, inst)
    self.inst = inst

    self.started = false
    self.range = 30
    self.period = 3
    self.maxspawns = 6
    self.task = nil
    self.cc = nil
end)

function MoonBeastSpawner:OnRemoveFromEntity()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

local MOONBEASTS =
{
    "moonhound",
    "moonpig",
}

local function MorphMoonBeast(old, moonbase)
    if not (old.components.health ~= nil and old.components.health:IsDead()) then
        local x, y, z = old.Transform:GetWorldPosition()
        local rot = old.Transform:GetRotation()
        local oldprefab = old.prefab
        local newprefab = old:HasTag("werepig") and "moonpig" or "moonhound"
        local new = SpawnPrefab(newprefab)
        new.components.entitytracker:TrackEntity("moonbase", moonbase)
        new.Transform:SetPosition(x, y, z)
        new.Transform:SetRotation(rot)
        old:PushEvent("detachchild")
        new:PushEvent("moontransformed", { old = old })
        old.persists = false
        old.entity:Hide()
        old:DoTaskInTime(0, old.Remove)
    end
end

local function CheckCCToFree(oldcc, newcc, tofree, target)
    --On top of breaking petrification, moon charge
    --also overpowers some lesser disabling effects
    if target.components.health ~= nil and target.components.health:IsDead() then
        return
    elseif target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
        newcc[target] = "sleeping"
    elseif target.components.freezable ~= nil and target.components.freezable:IsFrozen() and not target.components.freezable:IsThawing() then
        newcc[target] = "frozen"
    else
        return
    end

    if newcc[target] == oldcc[target] then
        table.insert(tofree, target)
    end
end

local SPAWN_CANT_TAGS = { "INLIMBO" }
local SPAWN_ONEOF_TAGS = { --[["moonbeast",]] "gargoyle", "werepig", "hound" }
local SPAWN_WALLS_ONEOF_TAGS = { "wall", "playerskeleton" }
local function DoSpawn(inst, self)
    local pos = inst:GetPosition()
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, self.range, nil, SPAWN_CANT_TAGS, SPAWN_ONEOF_TAGS)
    local offscreenworkers, newcc, tofree
    if inst:IsAsleep() then
        offscreenworkers = {}
        if next(self.cc) ~= nil then
            self.cc = {}
        end
    else
        newcc = {}
        tofree = {}
    end

    for i, v in ipairs(ents) do
        if not (v:HasTag("moonbeast") or v:HasTag("gargoyle") or v:HasTag("clay")) then
            --claim regular werepigs and hounds
            if not v.sg:HasStateTag("busy") then
                MorphMoonBeast(v, inst)
            else
                if not v._morphmoonbeast then
                    v._morphmoonbeast = true
                    v:ListenForEvent("newstate", function()
                        if not v.sg:HasStateTag("busy") and v._morphmoonbeast == true then
                            v._morphmoonbeast = v:DoTaskInTime(0, MorphMoonBeast, inst)
                        end
                    end)
                end
                if offscreenworkers == nil then
                    CheckCCToFree(self.cc, newcc, tofree, v)
                end
            end
        elseif offscreenworkers == nil then
            CheckCCToFree(self.cc, newcc, tofree, v)
        elseif v.components.combat ~= nil and math.random() < .25 then
            --do random work when off-screen
            table.insert(offscreenworkers, v)
        end
    end

    if offscreenworkers == nil then
        for i = 1, math.min(#tofree, math.random(2)) do
            local ent = table.remove(tofree, math.random(#tofree))
            if ent.components.sleeper ~= nil and ent.components.sleeper:IsAsleep() then
                ent.components.sleeper:WakeUp()
            elseif ent.components.freezable ~= nil and ent.components.freezable:IsFrozen() and not ent.components.freezable:IsThawing() then
                ent.components.freezable:Thaw()
            end
            newcc[ent] = nil
        end
        self.cc = newcc
    elseif #offscreenworkers > 0 then
        local walls = TheSim:FindEntities(pos.x, pos.y, pos.z, 10, nil, nil, SPAWN_WALLS_ONEOF_TAGS)
        for i, v in ipairs(walls) do
            if math.random(self.maxspawns * 2 + 1) <= #offscreenworkers then
                if v.components.health ~= nil and not v.components.health:IsDead() then
                    --walls
                    v.components.health:Kill()
                elseif v.components.workable ~= nil and v.components.workable:CanBeWorked() then
                    --skellies
                    v.components.workable:Destroy(inst)
                end
            end
        end
        for i, v in ipairs(offscreenworkers) do
            inst.components.workable:WorkedBy(v, 1)
            if not self.started then
                return
            end
        end
    end

    local maxwavespawn = math.random(2)
    for i = #ents + 1, self.maxspawns do
        local offset
        if inst:IsAsleep() then
            local numattempts = 3
            local minrange = 3
            for attempt = 1, numattempts do
                offset = FindWalkableOffset(pos, math.random() * TWOPI, GetRandomMinMax(minrange, math.max(minrange, minrange + .9 * (self.range - minrange) * attempt / numattempts)), 16, false, true)
                local x1 = pos.x + offset.x
                local z1 = pos.z + offset.z
                local collisions = TheSim:FindEntities(x1, 0, z1, 4, nil, SPAWN_CANT_TAGS)
                for _, collision in ipairs(collisions) do
                    local r = collision:GetPhysicsRadius(0) + 1
                    if collision:GetDistanceSqToPoint(x1, 0, z1) < r * r then
                        offset = nil
                        break
                    end
                end
                if offset ~= nil then
                    break
                end
            end
        else
            offset = FindWalkableOffset(pos, math.random() * TWOPI, self.range, 16, false, true)
        end
        if offset ~= nil then
            local creature = SpawnPrefab(MOONBEASTS[math.random(#MOONBEASTS)])
            creature.components.entitytracker:TrackEntity("moonbase", inst)
            creature.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
            creature:ForceFacePoint(pos)
            creature.components.spawnfader:FadeIn()
            if maxwavespawn > 1 then
                maxwavespawn = maxwavespawn - 1
            else
                return
            end
        end
    end
end

local PETRIFY_MUST_TAGS = { "moonbeast" }
local PETRIFY_CANT_TAGS = { "INLIMBO" }
function MoonBeastSpawner:ForcePetrify()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.range, PETRIFY_MUST_TAGS, PETRIFY_CANT_TAGS)
    for i, v in ipairs(ents) do
        if v.brain ~= nil then
            v.brain:ForcePetrify()
        end
        if v:IsAsleep() then
            v:PushEvent("moonpetrify")
        end
    end
end

local GARGOYLE_TAGS = { "gargoyle" }
function MoonBeastSpawner:Start()
    if not self.started then
        self.started = true

        local x, y, z = self.inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, self.range, GARGOYLE_TAGS)
        for i, v in ipairs(ents) do
            v:Reanimate(self.inst)
        end

        self.task = self.inst:DoPeriodicTask(self.period, DoSpawn, nil, self)
        self.cc = {}
    end
end

function MoonBeastSpawner:Stop()
    if self.started then
        self.started = false
        self.task:Cancel()
        self.task = nil
        self.cc = nil

        --Normally the brain will handle petrification after some time instead
        if self.inst:IsAsleep() then
            self:ForcePetrify()
        end
    end
end

return MoonBeastSpawner
