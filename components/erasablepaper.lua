local function GiveOrDropItem(item, doer, eraser)
    local pos = eraser:GetPosition()

    if doer ~= nil and doer.components.inventory ~= nil then
        doer.components.inventory:GiveItem(item, nil, pos)
    else
        item.Transform:SetPosition(pos:Get())
        item.components.inventoryitem:OnDropped(true)
    end
end

local ErasablePaper = Class(function(self, inst)
    self.inst = inst

    self.erased_prefab = "papyrus"
    self.stacksize = 1
end)

function ErasablePaper:SetErasedPrefab(prefab)
    assert(Prefabs[prefab] ~= nil, "Invalid prefab name")

    self.erased_prefab = prefab
end

function ErasablePaper:SetStackSize(size)
    assert(size >= 1, "Invalid stack size")

    self.stacksize = size
end

function ErasablePaper:DoErase(eraser, doer)
    local paper = SpawnPrefab(self.erased_prefab)

    -- Fail when trying to spawn non-items.
    if paper == nil or paper.components.inventoryitem == nil then
        if paper ~= nil then
            paper:Remove()
        end

        return
    end

    if self.inst.components.stackable ~= nil and self.inst.components.stackable:IsStack() then
        self.inst.components.stackable:Get():Remove()
    else
        self.inst:Remove()
    end

    if paper.components.stackable ~= nil then
        -- The item is stackable. Just increase the stack size of the original item.
        paper.components.stackable:SetStackSize(self.stacksize)

        GiveOrDropItem(paper, doer, eraser)
    else
        -- We still need to give the player the original product that was spawned, so do that.
        GiveOrDropItem(paper, doer, eraser)

        -- Now spawn in the rest of the items and give them to the player.
        for i = 2, self.stacksize do
            local addt_paper = SpawnPrefab(self.erased_prefab)
            GiveOrDropItem(addt_paper, doer, eraser)
        end
    end

    return paper
end

return ErasablePaper