local function onenabled(self, enabled)
    if enabled then
        self.inst:AddTag("herdmember")
    else
        self.inst:RemoveTag("herdmember")
    end
end

--- Tracks the herd that the object belongs to, and creates one if missing
local function OnInit(inst)
    inst.components.herdmember.task = nil
    inst.components.herdmember:CreateHerd()
end

local HerdMember = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    self.enabled = true

    self.herd = nil
    self.herdprefab = "beefaloherd"

    self.task = self.inst:DoTaskInTime(8.1, OnInit)-- NOTES(JBK): Keep this larger than herd component sample rate! Search string: HERDSAMPLER823
end,
nil,
{
    enabled = onenabled,
})

function HerdMember:OnRemoveFromEntity()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    self.inst:RemoveTag("herdmember")
end

function HerdMember:SetHerd(herd)
    self.herd = herd
end

function HerdMember:SetHerdPrefab(prefab)
    self.herdprefab = prefab
end

function HerdMember:GetHerd()
    return self.herd
end

function HerdMember:CreateHerd()
    if self.enabled and (self.herd == nil or not self.herd:IsValid()) and (self.inst.components.health == nil or not self.inst.components.health:IsDead()) then
        local herd = SpawnPrefab(self.herdprefab)
        if herd then
            herd.Transform:SetPosition(self.inst.Transform:GetWorldPosition() )
            if herd.components.herd then
                herd.components.herd:GatherNearbyMembers()
            end
        end
    end
end

function HerdMember:Leave()
    if self.herd ~= nil and self.herd:IsValid() then
        self.herd.components.herd:RemoveMember(self.inst)
	end

	if self.enabled then
        self.task = self.inst:DoTaskInTime(5, OnInit)
	end
end

function HerdMember:Enable(enabled)
    if not enabled and self.herd ~= nil and self.herd:IsValid() then
        self.herd.components.herd:RemoveMember(self.inst)
    elseif enabled and (self.herd == nil or not self.herd:IsValid()) then
        self.task = self.inst:DoTaskInTime(5, OnInit)
    end
    self.enabled = enabled
end

function HerdMember:GetDebugString()
    return string.format("herd:%s %s",tostring(self.herd), (not self.enabled) and "disabled" or "")
end

return HerdMember
