local FX_MAP =
{
    ["evergreen"] =
    {
        [1] = "evergreen_short",
        [2] = "evergreen_normal",
        [3] = "evergreen_tall",
        [4] = "evergreen_old",
    },
    ["evergreen_sparse"] =
    {
        [1] = "lumpy_short",
        [2] = "lumpy_normal",
        [3] = "lumpy_tall",
        [4] = "evergreen_old",
    },
    ["twiggytree"] =
    {
        [1] = "twiggy_short",
        [2] = "twiggy_normal",
        [3] = "twiggy_tall",
        [4] = "twiggy_old",
    },
    ["deciduoustree"] =
    {
        [1] = "leaf_short",
        [2] = "leaf_normal",
        [3] = "leaf_tall",
    },
    ["marsh_tree"] = "marsh",
    ["mushtree_small"] = "mushroom_short",
    ["mushtree_medium"] = "mushroom_normal",
    ["mushtree_tall"] = "mushroom_tall",
    ["mushtree_tall_webbed"] = "mushroom_webbed",
}

local Spooked = Class(function(self, inst)
    self.inst = inst
    self.spookedlevel = 0
    self.spookedthreshold = 70 --start getting spooked if above this level
    self.maxspookedlevel = 100
    self.maxspookdelta = 3.5
    self.maxspookage = TUNING.SEASON_LENGTH_HARSH_DEFAULT * TUNING.TOTAL_DAY_TIME
    self.lastspooktime = GetTime()
end)

function Spooked:ShouldSpook()
    if self.spookedlevel <= self.spookedthreshold or
        (self.inst:HasDebuff("halloweenpotion_bravery_buff")) or
        self.inst:HasTag("wereplayer") then
        return false
    end
    local k = (self.spookedlevel - self.spookedthreshold) / (self.maxspookedlevel - self.spookedthreshold)
    return math.random() < k * k
end

local function CalcSpooked(self, t)
    local dt = (t or GetTime()) - self.lastspooktime
    return math.max(0, self.spookedlevel - dt * dt)
end

local function DoSpooked(inst, source)
    inst:PushEvent("spooked", { source = source })
end

function Spooked:Spook(source)
    local t = GetTime()
    local agefactor = self.inst.components.age ~= nil and math.min(1, self.inst.components.age:GetAge() / self.maxspookage) or 1
    self.spookedlevel = math.min(self.maxspookedlevel + self.maxspookdelta, CalcSpooked(self, t) + agefactor * agefactor * self.maxspookdelta)
    self.lastspooktime = t

    if source.monster then
        --deciduous tree monsters
        return
    end
    local stage = source.components.growable ~= nil and source.components.growable.stage or nil
    if stage ~= 4 and not (source.components.workable ~= nil and source.components.workable:CanBeWorked() and source.components.workable:GetWorkAction() == ACTIONS.CHOP) then
        --finished chopping (only spawn if it was a 'old' growth state)
        return
    end
    local anim = FX_MAP[source.prefab]
    if type(anim) == "table" then
        anim = anim[stage]
    end
    if anim ~= nil and self:ShouldSpook() then
        local x, y, z = source.Transform:GetWorldPosition()
        local fx = SpawnPrefab("battreefx")
        fx.Transform:SetPosition(x, -.1, z)
        fx.Transform:SetScale(source.Transform:GetScale())
        if fx.SetViewerAndAnim ~= nil then
            fx:SetViewerAndAnim(self.inst, anim)
        end
        self.inst:DoTaskInTime((self.inst:HasTag("woodcutter") and 8 or 10) * FRAMES, DoSpooked, source)
        self.spookedlevel = 0
    end
end

function Spooked:GetDebugString()
    return string.format("spookedlevel = %.2f", CalcSpooked(self))
end

return Spooked
