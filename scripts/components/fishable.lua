local function onfrozen(self, frozen)
    if frozen then
        self.inst:RemoveTag("fishable")
    else
        self.inst:AddTag("fishable")
    end
end

local Fishable = Class(function(self, inst)
    self.inst = inst
    self.fish = {}
    self.maxfish = 10
    self.fishleft = 10
    self.hookedfish = {}
    self.fishrespawntime = nil
    self.respawntask = nil
    self.frozen = false
end,
nil,
{
    frozen = onfrozen,
})

function Fishable:OnRemoveFromEntity()
    self.inst:RemoveTag("fishable")
end

function Fishable:GetDebugString()
    local str = string.format("fishleft: %d", self.fishleft)
    return str
end

function Fishable:AddFish(prefab)
    self.fish[prefab] = prefab
end

function Fishable:SetGetFishFn(fn)
	self.getfishfn = fn
end

function Fishable:SetRespawnTime(time)
    self.fishrespawntime = time
end

local function RespawnFish(inst)
    local fishable = inst.components.fishable
    if fishable then
        fishable.respawntask = nil
        if fishable.fishleft < fishable.maxfish then
            fishable.fishleft = fishable.fishleft + 1
            if fishable.fishleft < fishable.maxfish then
                fishable:RefreshFish()
            end
        end
    end
end

function Fishable:HookFish(fisherman)
    local fishprefab = self.getfishfn ~= nil and self.getfishfn(self.inst) or GetRandomKey(self.fish)
    local fish = SpawnPrefab(fishprefab)
    if fish ~= nil then
        self.hookedfish[fish] = fish
        self.inst:AddChild(fish)
        fish.entity:Hide()
        fish.persists = false
        if fish.DynamicShadow ~= nil then
            fish.DynamicShadow:Enable(false)
        end
        if fish.Physics ~= nil then
            fish.Physics:SetActive(false)
        end
		if fisherman ~= nil and fish.components.weighable ~= nil then
			fish.components.weighable:SetPlayerAsOwner(fisherman)
		end
        if self.fishleft > 0 then
            self.fishleft = self.fishleft - 1
        end
    end
    return fish
end

function Fishable:ReleaseFish(fish)
    if self.hookedfish[fish] == fish then
        fish:Remove()
        self.hookedfish[fish] = nil
        if self.fishleft < self.maxfish then
            self.fishleft = self.fishleft + 1
        end
    end
end

function Fishable:RemoveFish(fish)
    if self.hookedfish[fish] == fish then
        self.hookedfish[fish] = nil
        self.inst:RemoveChild(fish)
        --[[--Fish state restored by fishingrod instead, for better timing
        fish.entity:Show()
        if fish.DynamicShadow ~= nil then
            fish.DynamicShadow:Enable(true)
        end
        if fish.Physics ~= nil then
            fish.Physics:SetActive(true)
        end
        fish.persists = true
        ]]
        if not self.respawntask then
            self:RefreshFish()
        end
        return fish
    end
end

function Fishable:IsFrozenOver()
	return self.frozen
end

function Fishable:Freeze()
	self.frozen = true
end

function Fishable:Unfreeze()
	self.frozen = false
end

function Fishable:RefreshFish()
    if self.fishrespawntime then
        self.respawntask = self.inst:DoTaskInTime(self.fishrespawntime, RespawnFish)
    end
end

function Fishable:GetFishPercent()
    return self.fishleft / self.maxfish
end

function Fishable:OnSave()
    if self.fishleft < self.maxfish then
        return {fish = self.fishleft}
    end
end

function Fishable:OnLoad(data)
    if data then
        self.fishleft = data.fish
        self:RefreshFish()
    end
end

return Fishable