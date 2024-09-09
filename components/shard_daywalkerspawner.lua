-- shard_daywalkerspawner class definition

return Class(function(self, inst)
assert(TheWorld.ismastersim, "shard_daywalkerspawner should not exist on a client.")
self.inst = inst

local _world = TheWorld
local _ismastershard = _world.ismastershard


self.DAYWALKERLOCATION = {
    cavejail = 0, -- In the caves trapped in shadow restraints.
    forestjunkpile = 1, -- On the surface trapped under junk.
    -- Max value 7 from self.location netvar.
}
function self:UpdateLocationNames()
    self.DAYWALKERLOCATION_LOOKUP = {}
    for name, enum in pairs(self.DAYWALKERLOCATION) do
        self.DAYWALKERLOCATION_LOOKUP[enum] = name
    end
end
self:UpdateLocationNames()


self.location = net_tinybyte(inst.GUID, "daywalkernetwork.location", "locationdirty")

function self:GetLocation()
    return self.location:value()
end
function self:GetLocationName()
    return self.DAYWALKERLOCATION_LOOKUP[self:GetLocation()]
end
function self:SetLocation(location)
    if type(location) == "string" then
        location = self.DAYWALKERLOCATION[location] or 0
    end
    self.location:set(location)
    --print("SetLocation", self:GetLocationName())
end


if _ismastershard then
    function self:GetNewLocationName(oldlocation)
        if oldlocation == "cavejail" then
            return "forestjunkpile"
        elseif oldlocation == "forestjunkpile" then
            return "cavejail"
        end
        -- TODO(JBK): More daywalker positions may be added here.
    end
    self.OnLocationUpdate = function(src, data)
        --print("MASTERSHARD OnLocationUpdate", src, data and data.bossprefab, data and data.shardid)
        if data == nil then
            return
        end

        if data.bossprefab == "daywalker" then
            local oldlocation = self:GetLocationName()
            local newlocation = self:GetNewLocationName(oldlocation)
            self:SetLocation(newlocation)
        end
    end
    function self:OnSave()
        return {
            location = self:GetLocationName(),
        }
    end
    function self:OnLoad(data)
        if data == nil then
            return
        end

        self:SetLocation(data.location)
    end

    --Register master shard events
    inst:ListenForEvent("master_shardbossdefeated", self.OnLocationUpdate, _world)
else
    -- NOTES(JBK): Shards do not need to do anything yet for this but keeping this function stub here in case it will be used for something else.
    self.OnLocationDirty = function()
        --print("SHARD OnLocationDirty")
    end

    --Register network variable sync events
    inst:ListenForEvent("locationdirty", self.OnLocationDirty)
end


self.location:set(0)


function self:GetDebugString()
    return string.format("Mastershard: %d, Location: %s", _ismastershard and 1 or 0, self:GetLocationName())
end

end)
