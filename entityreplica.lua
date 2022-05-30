--------------------------------------------------------------------------
--Extends EntityScript with network replica functionality
--------------------------------------------------------------------------

local REPLICATABLE_COMPONENTS =
{
    builder = true,
    combat = true,
    container = true,
    constructionsite = true,
    equippable = true,
    fishingrod = true,
    follower = true,
    health = true,
    hunger = true,
    inventory = true,
    inventoryitem = true,
    moisture = true,
    named = true,
    oceanfishingrod = true,
    rider = true,
    sanity = true,
    sheltered = true,
    stackable = true,
    writeable = true,
}

local Replicas = {}

function EntityScript:ValidateReplicaComponent(name, cmp)
    return self:HasTag("_"..name) and cmp or nil
end

function EntityScript:ReplicateComponent(name)
    if not REPLICATABLE_COMPONENTS[name] then
        return
    end

    if TheWorld.ismastersim then
        self:AddTag("_"..name)
        if self:HasTag("__"..name) then
            self:RemoveTag("__"..name)
            return
        end
    end

    if rawget(self.replica, "_")[name] ~= nil then
        print("replica "..name.." already exists! "..debugstack_oneline(3))
    end

    local filename = name.."_replica"
    local cmp = Replicas[filename]
    if cmp == nil then
        cmp = require("components/"..filename)
        Replicas[filename] = cmp
    end
    assert(cmp ~= nil, "replica "..name.." does not exist!")

    rawset(self.replica._, name, cmp(self))
end

function EntityScript:UnreplicateComponent(name)
    if rawget(self.replica, "_")[name] ~= nil and TheWorld.ismastersim then
        self:RemoveTag("_"..name)
        self:AddTag("__"..name)
    end
end

function EntityScript:PrereplicateComponent(name)
    self:ReplicateComponent(name)
    self:UnreplicateComponent(name)
end

--Triggered on clients immediately after initial deserialization of tags from construction
function EntityScript:ReplicateEntity()
    for k, v in pairs(REPLICATABLE_COMPONENTS) do
        if v and (self:HasTag("_"..k) or self:HasTag("__"..k)) then
            self:ReplicateComponent(k)
        end
    end

    if self.OnEntityReplicated ~= nil then
        self:OnEntityReplicated()
    end
end

-- Mod access
function AddReplicableComponent(name)
    REPLICATABLE_COMPONENTS[name] = true
end
