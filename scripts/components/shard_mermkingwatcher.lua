-- shard_mermkingwatcher class definition

local SourceModifierList = require("util/sourcemodifierlist")

return Class(function(self, inst)
assert(TheWorld.ismastersim, "shard_mermkingwatcher should not exist on a client.")
self.inst = inst

local _world = TheWorld
local _ismastershard = _world.ismastershard

-- Merm king synchronization
self.mermkings = SourceModifierList(inst, false, SourceModifierList.boolean)
self.hasmermking = net_bool(inst.GUID, "mermkingwatcher.hasmermking", "hasmermkingdirty")
self.hasmermking:set(false)

function self:AddMermKingSource(source)
    local hadking = self:HasMermKing()
    self.mermkings:SetModifier(source, true)
    self.hasmermking:set(true)

    if not hadking then
        TheWorld:PushEvent("onmermkingcreated_anywhere")
    end
end
function self:RemoveMermKingSource(source)
    self.mermkings:RemoveModifier(source)
    if not self.mermkings:Get() then
        self.hasmermking:set(false)

        TheWorld:PushEvent("onmermkingdestroyed_anywhere")
    end
end

function self:HasMermKing()
    return self.hasmermking:value()
end

function self:OnMermKingCreated()
    Shard_SyncMermKingExists(true)
end
function self:OnMermKingDestroyed()
    Shard_SyncMermKingExists(false)
end
self.inst:ListenForEvent("onmermkingcreated", function() self:OnMermKingCreated() end, _world)
self.inst:ListenForEvent("onmermkingdestroyed", function() self:OnMermKingDestroyed() end, _world)

-- Trident buff synchronization -----------------------------------------------------------------------
self.tridents = SourceModifierList(inst, false, SourceModifierList.boolean)
self.hastrident = net_bool(inst.GUID, "mermkingwatcher.hastrident", "hastridentdirty")
self.hastrident:set(false)

function self:AddTridentSource(source)
    local hadtrident = self:HasTrident()
    self.tridents:SetModifier(source, true)
    self.hastrident:set(true)

    if not hadtrident then
        TheWorld:PushEvent("onmermkingtridentadded_anywhere")
    end
end
function self:RemoveTridentSource(source)
    self.tridents:RemoveModifier(source)
    if not self.tridents:Get() then
        self.hastrident:set(false)

        TheWorld:PushEvent("onmermkingtridentremoved_anywhere")
    end
end
function self:HasTrident()
    return self.hastrident:value()
end
function self:OnTridentAdded()
    Shard_SyncMermKingTrident(true)
end
function self:OnTridentRemoved()
    Shard_SyncMermKingTrident(false)
end
self.inst:ListenForEvent("onmermkingtridentadded", function() self:OnTridentAdded() end, _world)
self.inst:ListenForEvent("onmermkingtridentremoved", function() self:OnTridentRemoved() end, _world)

-- Crown buff synchronization -----------------------------------------------------------------------
self.crowns = SourceModifierList(inst, false, SourceModifierList.boolean)
self.hascrown = net_bool(inst.GUID, "mermkingwatcher.hascrown", "hascrowndirty")
self.hascrown:set(false)

function self:AddCrownSource(source)
    local hadcrown = self:HasCrown()
    self.crowns:SetModifier(source, true)
    self.hascrown:set(true)

    if not hadcrown then
        TheWorld:PushEvent("onmermkingcrownadded_anywhere")
    end
end
function self:RemoveCrownSource(source)
    self.crowns:RemoveModifier(source)
    if not self.crowns:Get() then
        self.hascrown:set(false)

        TheWorld:PushEvent("onmermkingcrownremoved_anywhere")
    end
end
function self:HasCrown()
    return self.hascrown:value()
end
function self:OnCrownAdded()
    Shard_SyncMermKingCrown(true)
end
function self:OnCrownRemoved()
    Shard_SyncMermKingCrown(false)
end
self.inst:ListenForEvent("onmermkingcrownadded", function() self:OnCrownAdded() end, _world)
self.inst:ListenForEvent("onmermkingcrownremoved", function() self:OnCrownRemoved() end, _world)

-- Pauldron buff synchronization -----------------------------------------------------------------------
self.pauldrons = SourceModifierList(inst, false, SourceModifierList.boolean)
self.haspauldron = net_bool(inst.GUID, "mermkingwatcher.haspauldron", "haspauldrondirty")
self.haspauldron:set(false)

function self:AddPauldronSource(source)
    local hadpauldron = self:HasPauldron()
    self.pauldrons:SetModifier(source, true)
    self.haspauldron:set(true)

    if not hadpauldron then
        TheWorld:PushEvent("onmermkingpauldronadded_anywhere")
    end
end
function self:RemovePauldronSource(source)
    self.pauldrons:RemoveModifier(source)
    if not self.pauldrons:Get() then
        self.haspauldron:set(false)

        TheWorld:PushEvent("onmermkingpauldronremoved_anywhere")
    end
end
function self:HasPauldron()
    return self.haspauldron:value()
end
function self:OnPauldronAdded()
    Shard_SyncMermKingPauldron(true)
end
function self:OnPauldronRemoved()
    Shard_SyncMermKingPauldron(false)
end
self.inst:ListenForEvent("onmermkingpauldronadded", function() self:OnPauldronAdded() end, _world)
self.inst:ListenForEvent("onmermkingpauldronremoved", function() self:OnPauldronRemoved() end, _world)



if _ismastershard then
    --Register master shard events
    self.OnMermKingExists = function(src, data)
        --print("MASTERSHARD OnMermKingExists", src, data and data.exists, data and data.shardid)
        if data == nil then
            return
        end

        if data.exists then
            self:AddMermKingSource(data.shardid)
        else
            self:RemoveMermKingSource(data.shardid)
        end
    end
    inst:ListenForEvent("master_shardmermkingexists", self.OnMermKingExists, _world)

    self.OnMermKingTridentChanged = function(src, data)
        if not data then return end

        (data.pickedup and self.AddTridentSource or self.RemoveTridentSource)(self, data.shardid)
    end
    inst:ListenForEvent("master_shardmermkingtrident", self.OnMermKingTridentChanged, _world)

    self.OnMermKingCrownChanged = function(src, data)
        if not data then return end

        (data.pickedup and self.AddCrownSource or self.RemoveCrownSource)(self, data.shardid)
    end
    inst:ListenForEvent("master_shardmermkingcrown", self.OnMermKingCrownChanged, _world)

    self.OnMermKingPauldronsChanged = function(src, data)
        if not data then return end

        (data.pickedup and self.AddPauldronSource or self.RemovePauldronSource)(self, data.shardid)
    end
    inst:ListenForEvent("master_shardmermkingpauldron", self.OnMermKingPauldronsChanged, _world)

    function self:ResyncNetVars()
        -- NOTES(JBK): Not the most efficient but if a shard connects late we need to send the variable off to it so we broadcast it off to all connected shards.
        local val
        val = self.hasmermking:value()
        self.hasmermking:set_local(false)
        self.hasmermking:set(val)
        val = self.hastrident:value()
        self.hastrident:set_local(false)
        self.hastrident:set(val)
        val = self.hascrown:value()
        self.hascrown:set_local(false)
        self.hascrown:set(val)
        val = self.haspauldron:value()
        self.haspauldron:set_local(false)
        self.haspauldron:set(val)
    end
else
    -- NOTES(JBK): Shards need to update their world state as if they have a Merm King.
    self.OnHasMermKingDirty = function()
        --print("SHARD OnHasMermKingDirty", self.hasmermking:value())
        if self.hasmermking:value() then
            TheWorld:PushEvent("onmermkingcreated_anywhere")
        else
            TheWorld:PushEvent("onmermkingdestroyed_anywhere")
        end
    end
    self.OnHasTridentDirty = function()
        local mermkingmanager = TheWorld.components.mermkingmanager
        local hastrident = (mermkingmanager and mermkingmanager:HasTridentLocal()) or false
        if not hastrident then
            TheWorld:PushEvent((self.hastrident:value() and "onmermkingtridentadded_anywhere")
                or "onmermkingtridentremoved_anywhere")
        end
    end
    self.OnHasCrownDirty = function()
        local mermkingmanager = TheWorld.components.mermkingmanager
        local hascrown = (mermkingmanager and mermkingmanager:HasCrownLocal()) or false
        if not hascrown then
            TheWorld:PushEvent((self.hascrown:value() and "onmermkingcrownadded_anywhere")
                or "onmermkingcrownremoved_anywhere")
        end
    end
    self.OnHasPauldronDirty = function()
        local mermkingmanager = TheWorld.components.mermkingmanager
        local haspauldron = (mermkingmanager and mermkingmanager:HasPauldronLocal()) or false
        if not haspauldron then
            TheWorld:PushEvent((self.haspauldron:value() and "onmermkingpauldronadded_anywhere")
                or "onmermkingpauldronremoved_anywhere")
        end
    end

    --Register network variable sync events
    -- NOTES(JBK): Delay to allow network deserialization to go first.
    TheWorld:DoTaskInTime(0, function()
        inst:ListenForEvent("hasmermkingdirty", self.OnHasMermKingDirty)
        inst:ListenForEvent("hastridentdirty", self.OnHasTridentDirty)
        inst:ListenForEvent("hascrowndirty", self.OnHasCrownDirty)
        inst:ListenForEvent("haspauldrondirty", self.OnHasPauldronDirty)
    end)
end



function self:GetDebugString()
    return string.format("Mastershard: %d, HasMermKing: %s", _ismastershard and 1 or 0, self:HasMermKing() and 1 or 0)
end

end)
