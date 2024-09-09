local function onequipslot(self, equipslot)
    self.inst.replica.equippable:SetEquipSlot(equipslot)
end

--Update inventoryitem_replica constructor if any more properties are added

local function onwalkspeedmult(self, walkspeedmult)
    if self.inst.replica.inventoryitem ~= nil then
        --This network optimization hack is shared by saddler component,
        --so a prefab must not have both components at the same time.
        self.inst.replica.inventoryitem:SetWalkSpeedMult(walkspeedmult)
    end
end

local function onrestrictedtag(self, restrictedtag)
    if self.inst.replica.inventoryitem ~= nil then
        self.inst.replica.inventoryitem:SetEquipRestrictedTag(restrictedtag)
    end
end

local function onpreventunequipping(self, prevent)
    self.inst.replica.equippable:SetPreventUnequipping(prevent)
end

local Equippable = Class(function(self, inst)
    self.inst = inst

    self.isequipped = false
    self.equipslot = EQUIPSLOTS.HANDS
    self.onequipfn = nil
    self.onunequipfn = nil
    self.onpocketfn = nil
    self.onequiptomodelfn = nil
    self.equipstack = false
    self.walkspeedmult = nil
    --self.retrictedtag = nil --only entities with this tag can equip
    self.dapperness = 0
    self.dapperfn = nil
    self.insulated = false
    self.equippedmoisture = 0
    self.maxequippedmoisture = 0

    -- self.preventunequipping = nil -- Set to true to block unequipping the item.

	-- self.is_magic_dapperness -- some survivors are only affected by magic sources
end,
nil,
{
    equipslot = onequipslot,
    walkspeedmult = onwalkspeedmult,
    restrictedtag = onrestrictedtag,
    preventunequipping = onpreventunequipping
})

function Equippable:OnRemoveFromEntity()
    local inventoryitem = self.inst.replica.inventoryitem
    if inventoryitem ~= nil then
        inventoryitem:SetWalkSpeedMult(1)
        inventoryitem:SetEquipRestrictedTag(nil)
    end
end

function Equippable:IsInsulated() -- from electricity, not temperature
    return self.insulated
end

function Equippable:SetOnEquip(fn)
    self.onequipfn = fn
end

function Equippable:SetOnPocket(fn)
    self.onpocketfn = fn
end

function Equippable:SetOnUnequip(fn)
    self.onunequipfn = fn
end

function Equippable:SetDappernessFn(fn)
    self.dapperfn = fn
end

function Equippable:SetOnEquipToModel(fn)
    self.onequiptomodelfn = fn
end

function Equippable:IsEquipped()
    return self.isequipped
end

function Equippable:Equip(owner, from_ground)
    self.isequipped = true

    if self.inst.components.burnable ~= nil then
        self.inst.components.burnable:StopSmoldering()
    end

    if self.onequipfn ~= nil then
        self.onequipfn(self.inst, owner, from_ground)
    end
    self.inst:PushEvent("equipped", { owner = owner })

    if self.onequiptomodelfn ~= nil and owner:HasTag("equipmentmodel") then
        self.onequiptomodelfn(self.inst, owner, from_ground)
    end
end

function Equippable:ToPocket(owner)
    if self.onpocketfn ~= nil then
        self.onpocketfn(self.inst, owner)
    end
end

function Equippable:Unequip(owner)
    self.isequipped = false

    if self.onunequipfn ~= nil then
        self.onunequipfn(self.inst, owner)
    end

    self.inst:PushEvent("unequipped", { owner = owner })
end

function Equippable:GetWalkSpeedMult()
    return self.walkspeedmult or 1.0
end

function Equippable:IsRestricted(target)
    return self.restrictedtag ~= nil
        and self.restrictedtag:len() > 0
        and not target:HasTag(self.restrictedtag)
        and target:HasTag("player") --restricted tags only apply to players
end

function Equippable:IsRestricted_FromLoad(target)
    if SKILLTREE_EQUIPPABLE_RESTRICTED_TAGS[self.restrictedtag] == target.prefab then
        -- NOTES(JBK): If a player is resolving equipment from a snapshot load assume the player has the tag only if the tag is from a skill tree.
        return false
    end
    return self:IsRestricted(target)
end

function Equippable:ShouldPreventUnequipping()
    return self.preventunequipping
end

local function OnRemove(inst, data)
    inst.components.equippable:SetPreventUnequipping(false)
end

function Equippable:SetPreventUnequipping(shouldprevent)
    if shouldprevent then
        if self._onremovelistener == nil then
            self._onremovelistener = self.inst:ListenForEvent("onremove", OnRemove)
        end
    else
        if self._onremovelistener ~= nil then
            self.inst:RemoveEventCallback("onremove", OnRemove)
            self._onremovelistener = nil
        end
    end
    self.preventunequipping = shouldprevent
end

function Equippable:GetDapperness(owner, ignore_wetness)
    local dapperness = self.dapperness

    if self.flipdapperonmerms and owner and owner:HasTag("merm") then
        dapperness = -dapperness
    end

    if self.dapperfn ~= nil then
        dapperness = self.dapperfn(self.inst, owner)
    end

    if not ignore_wetness and self.inst:GetIsWet() then
        dapperness = dapperness + TUNING.WET_ITEM_DAPPERNESS
    end

    return dapperness
end

function Equippable:GetEquippedMoisture()
    return { moisture = self.equippedmoisture, max = self.maxequippedmoisture }
end

return Equippable
