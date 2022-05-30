local InventoryItem = Class(function(self, inst)
    self.inst = inst

    self._cannotbepickedup = net_bool(inst.GUID, "inventoryitem._cannotbepickedup")
    self._iswet = net_bool(inst.GUID, "inventoryitem._iswet", "iswetdirty")

    if TheWorld.ismastersim then
        self.classified = SpawnPrefab("inventoryitem_classified")
        self.classified.entity:SetParent(inst.entity)

        inst:ListenForEvent("percentusedchange", function(inst, data) self.classified:SerializePercentUsed(data.percent) end)
        inst:ListenForEvent("perishchange", function(inst, data) self.classified:SerializePerish(data.percent) end)
        inst:ListenForEvent("forceperishchange", function(inst) self.classified:ForcePerishDirty() end)
        inst:ListenForEvent("rechargechange", function(inst, data) self.classified:SerializeRecharge(data.percent, data.overtime) end)

        if inst.components.deployable ~= nil then
            self:SetDeployMode(inst.components.deployable.mode)
            self:SetDeploySpacing(inst.components.deployable.spacing)
            self:SetDeployRestrictedTag(inst.components.deployable.restrictedtag)
            self:SetUseGridPlacer(inst.components.deployable.usegridplacer)
        end

        if inst.components.weapon ~= nil then
            self:SetAttackRange(inst.components.weapon.attackrange or 0)
        end

        --V2C: Look at this hack - _-"  (for network optimization...)
        --     This means no item can be both equippable and saddler!
        --     Avoiding asserts, but hopefully comments are enough =)
        if inst.components.equippable ~= nil then
            self:SetWalkSpeedMult(inst.components.equippable.walkspeedmult or 1)
            self:SetEquipRestrictedTag(inst.components.equippable.restrictedtag)
        elseif inst.components.saddler ~= nil then
            self:SetWalkSpeedMult(inst.components.saddler.speedmult or 1)
        end
    elseif self.classified == nil and inst.inventoryitem_classified ~= nil then
        self:AttachClassified(inst.inventoryitem_classified)
        inst.inventoryitem_classified.OnRemoveEntity = nil
        inst.inventoryitem_classified = nil
    end
end)

--------------------------------------------------------------------------

function InventoryItem:OnRemoveFromEntity()
    if self.classified ~= nil then
        if TheWorld.ismastersim then
            self.classified:Remove()
            self.classified = nil
        else
            self.classified._parent = nil
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

InventoryItem.OnRemoveEntity = InventoryItem.OnRemoveFromEntity

function InventoryItem:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function InventoryItem:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
end

--------------------------------------------------------------------------

function InventoryItem:SetCanBePickedUp(canbepickedup)
    self._cannotbepickedup:set(not canbepickedup)
end

function InventoryItem:CanBePickedUp()
    return not self._cannotbepickedup:value()
end

function InventoryItem:SetCanGoInContainer(cangoincontainer)
    self.classified.cangoincontainer:set(cangoincontainer)
end

function InventoryItem:CanGoInContainer()
    return self.classified ~= nil and self.classified.cangoincontainer:value()
end

function InventoryItem:SetCanOnlyGoInPocket(canonlygoinpocket)
    self.classified.canonlygoinpocket:set(canonlygoinpocket)
end

function InventoryItem:CanOnlyGoInPocket()
    return self.classified ~= nil and self.classified.canonlygoinpocket:value()
end

function InventoryItem:SetImage(imagename)
    self.classified.image:set(imagename ~= nil and (imagename..".tex") or 0)
end

local function GetClientSideInventoryImageOverride(self)
    if self.inst:HasClientSideInventoryImageOverrides() then
        local imagehash = self.classified ~= nil and
            self.classified.image:value() ~= 0 and
            self.classified.image:value() or hash(self.inst.prefab..".tex")
        return self.inst:GetClientSideInventoryImageOverride(imagehash)
    end
end

function InventoryItem:GetImage()
    local override = GetClientSideInventoryImageOverride(self)
    return (override and override.image) or
        (self.classified ~= nil and self.classified.image:value() ~= 0 and self.classified.image:value()) or
        self.inst.prefab..".tex"
end

function InventoryItem:SetAtlas(atlasname)
    self.classified.atlas:set(atlasname ~= nil and resolvefilepath(atlasname) or 0)
end

function InventoryItem:GetAtlas()
    local override = GetClientSideInventoryImageOverride(self)

    return (override and override.atlas) or
        (self.classified ~= nil and self.classified.atlas:value() ~= 0 and self.classified.atlas:value()) or
        GetInventoryItemAtlas(self:GetImage())
end

function InventoryItem:SetOwner(owner)
    local opencount = owner ~= nil and owner.components.container ~= nil and owner.components.container.opencount or 0
    if opencount > 1 then
        self.inst:ForceOutOfLimbo(true)
        if self.inst.Network ~= nil then
            self.inst.Network:SetClassifiedTarget(nil)
        end
        if self.classified ~= nil then
            self.classified.Network:SetClassifiedTarget(nil)
        end
    else
        owner = (opencount == 0 and owner) or (opencount == 1 and table.getkeys(owner.components.container.openlist)[1]) or nil
        self.inst:ForceOutOfLimbo(false)
        if self.inst.Network ~= nil then
            self.inst.Network:SetClassifiedTarget(owner)
        end
        if self.classified ~= nil then
            self.classified.Network:SetClassifiedTarget(owner or self.inst)
        end
    end
end

function InventoryItem:IsHeld()
    if self.inst.components.inventoryitem ~= nil then
        return self.inst.components.inventoryitem:IsHeld()
    else
        return self.classified ~= nil
    end
end

function InventoryItem:IsHeldBy(guy)
    if self.inst.components.inventoryitem ~= nil then
        return self.inst.components.inventoryitem:IsHeldBy(guy)
    else
        return self.classified ~= nil and guy ~= nil and guy == ThePlayer and
            guy.replica.inventory:IsHolding(self.inst)
    end
end

function InventoryItem:IsGrandOwner(guy)
    if self.inst.components.inventoryitem ~= nil then
        return self.inst.components.inventoryitem:GetGrandOwner() == guy
    else
        return self.classified ~= nil and guy ~= nil and guy == ThePlayer and
            guy.replica.inventory:IsHolding(self.inst, true)
    end
end

function InventoryItem:SetPickupPos(pos)
    if pos ~= nil then
        self.classified.src_pos.isvalid:set(true)
        self.classified.src_pos.x:set(pos.x)
        self.classified.src_pos.z:set(pos.z)
    else
        self.classified.src_pos.isvalid:set(false)
    end
end

function InventoryItem:GetPickupPos()
    if self.classified ~= nil then
        local src_pos = self.classified.src_pos
        return src_pos.isvalid:value() and Vector3(src_pos.x:value(), 0, src_pos.z:value()) or nil
    end
end

function InventoryItem:SerializeUsage()
    local percentusedcomponent =
        self.inst.components.armor or
        self.inst.components.finiteuses or
        self.inst.components.fueled

    self.classified:SerializePercentUsed(percentusedcomponent ~= nil and percentusedcomponent:GetPercent() or nil)
    self.classified:SerializePerish(self.inst.components.perishable ~= nil and self.inst.components.perishable:GetPercent() or nil)
    if self.inst.components.rechargeable ~= nil then
        self.classified:SerializeRecharge(self.inst.components.rechargeable:GetPercent())
        self.classified:SerializeRechargeTime(self.inst.components.rechargeable:GetRechargeTime())
    else
        self.classified:SerializeRecharge(nil)
        self.classified:SerializeRechargeTime(nil)
    end
end

function InventoryItem:DeserializeUsage()
    if self.classified ~= nil then
        self.classified:DeserializePercentUsed()
        self.classified:DeserializePerish()
        self.classified:DeserializeRecharge()
        self.classified:DeserializeRechargeTime()
    end
end

function InventoryItem:SetChargeTime(t)
    self.classified:SerializeRechargeTime(t)
    self.classified.recharge:set(self.classified.recharge:value())
    self.inst:PushEvent("rechargetimechange", { t = t })
end

function InventoryItem:SetDeployMode(deploymode)
    self.classified.deploymode:set(deploymode)
end

function InventoryItem:IsDeployable(deployer)
    if self.inst.components.deployable ~= nil then
        return self.inst.components.deployable:IsDeployable(deployer)
    elseif self.classified == nil or self.classified.deploymode:value() == DEPLOYMODE.NONE then
        return false
    end
    local restrictedtag = self.classified.deployrestrictedtag:value()
    return restrictedtag == nil or restrictedtag == 0 or (deployer ~= nil and deployer:HasTag(restrictedtag))
end

function InventoryItem:SetDeploySpacing(deployspacing)
    self.classified.deployspacing:set(deployspacing)
end

function InventoryItem:DeploySpacingRadius()
    if self.inst.components.deployable ~= nil then
        return self.inst.components.deployable:DeploySpacingRadius()
    elseif self.classified ~= nil then
        return DEPLOYSPACING_RADIUS[self.classified.deployspacing:value()]
    else
        return DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT]
    end
end

function InventoryItem:SetDeployRestrictedTag(restrictedtag)
    self.classified.deployrestrictedtag:set(restrictedtag or 0)
end

function InventoryItem:CanDeploy(pt, mouseover, deployer, rot)
    if self.inst.components.deployable ~= nil then
        return self.inst.components.deployable:CanDeploy(pt, mouseover, deployer, rot)
    elseif not self:IsDeployable(deployer) then
        return false
    elseif self.classified.deploymode:value() == DEPLOYMODE.ANYWHERE then
        return TheWorld.Map:IsPassableAtPoint(pt:Get())
    elseif self.classified.deploymode:value() == DEPLOYMODE.TURF then
        return TheWorld.Map:CanPlaceTurfAtPoint(pt:Get())
    elseif self.classified.deploymode:value() == DEPLOYMODE.PLANT then
        return TheWorld.Map:CanDeployPlantAtPoint(pt, self.inst)
    elseif self.classified.deploymode:value() == DEPLOYMODE.WALL then
        return TheWorld.Map:CanDeployWallAtPoint(pt, self.inst)
    elseif self.classified.deploymode:value() == DEPLOYMODE.DEFAULT then
        return TheWorld.Map:CanDeployAtPoint(pt, self.inst, mouseover)
    elseif self.classified.deploymode:value() == DEPLOYMODE.WATER then
        return TheWorld.Map:CanDeployAtPointInWater(pt, self.inst, mouseover,
        {
            land = 0.2, boat = 0.2, radius = self:DeploySpacingRadius(),
        })
    elseif self.classified.deploymode:value() == DEPLOYMODE.CUSTOM then
        if self.inst._custom_candeploy_fn ~= nil then
            return self.inst._custom_candeploy_fn(self.inst, pt, mouseover, deployer, rot)
        else -- use old DEPLOYMODE.MAST logic
            return TheWorld.Map:CanDeployMastAtPoint(pt, self.inst, mouseover)
        end
    end
end

function InventoryItem:SetUseGridPlacer(usegridplacer)
    self.classified.usegridplacer:set(usegridplacer)
end

function InventoryItem:GetDeployPlacerName()
    if self.inst.components.deployable ~= nil then
        if self.inst.components.deployable.usegridplacer then
            return "gridplacer"
        end
    elseif self.classified ~= nil and self.classified.usegridplacer:value() then
        return "gridplacer"
    end
    return self.inst.overridedeployplacername or ((self.inst.prefab or "").."_placer")
end

function InventoryItem:SetAttackRange(attackrange)
    self.classified.attackrange:set(attackrange or 0)
end

function InventoryItem:AttackRange()
    if self.inst.components.weapon ~= nil then
        return self.inst.components.weapon.attackrange or 0
    elseif self.classified ~= nil and self.classified.attackrange:value() > -99 then
        return self.classified.attackrange:value()
    else
        return 0
    end
end

function InventoryItem:IsWeapon()
    return self.inst.components.weapon ~= nil or
        (self.classified ~= nil and
        self.classified.attackrange:value() > -99)
end

function InventoryItem:SetWalkSpeedMult(walkspeedmult)
    --V2C: inconsistent precision errors with math.floor
    --     e.g. math.floor(1.15 * 100) => 114 ERMAHGERD
    --     switched to a string solution instead
    --local x = math.floor((walkspeedmult or 1) * 100)
    local x = 100
    if walkspeedmult ~= nil then
        x = tostring(x * walkspeedmult)
        x = tonumber(x:sub(x:find("^%-?%d+")))
    end
    assert(x >= 0 and x <= 255, "Walk speed multiplier out of range: "..tostring(walkspeedmult))
    assert(walkspeedmult == nil or math.abs(walkspeedmult * 100 - x) < .01 , "Walk speed multiplier can only have up to .01 precision: "..tostring(walkspeedmult))
    self.classified.walkspeedmult:set(x)
end

function InventoryItem:GetWalkSpeedMult()
    if self.inst.components.equippable ~= nil then
        return self.inst.components.equippable:GetWalkSpeedMult()
    elseif self.classified ~= nil then
        return self.classified.walkspeedmult:value() / 100
    else
        return 1
    end
end

function InventoryItem:SetEquipRestrictedTag(restrictedtag)
    self.classified.equiprestrictedtag:set(restrictedtag or 0)
end

function InventoryItem:GetEquipRestrictedTag()
    if self.inst.components.equippable ~= nil then
        return self.inst.components.equippable:GetRestrictedTag()
    end
    return self.classified ~= nil
        and self.classified.equiprestrictedtag:value() ~= 0
        and self.classified.equiprestrictedtag:value()
        or nil
end

function InventoryItem:SetMoistureLevel(moisture)
    if self.classified ~= nil then
        self.classified.moisture:set(moisture)
    end
end

function InventoryItem:GetMoisture()
    if self.inst.components.inventoryitemmoisture ~= nil then
        return self.inst.components.inventoryitemmoisture.moisture
    elseif self.classified ~= nil then
        return self.classified.moisture:value()
    else
        return 0
    end
end

function InventoryItem:SetIsWet(iswet)
    if iswet ~= self._iswet:value() then
        self._iswet:set(iswet)
        self.inst:PushEvent("wetnesschange", iswet)
    end
end

function InventoryItem:IsWet()
    return self._iswet:value()
end

return InventoryItem
