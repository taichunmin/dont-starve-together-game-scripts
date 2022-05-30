local LootDropper = Class(function(self, inst)
    self.inst = inst
    self.numrandomloot = nil
    self.randomloot = nil
    self.chancerandomloot = nil
    self.totalrandomweight = nil
    self.chanceloot = nil
    self.ifnotchanceloot = nil
    self.droppingchanceloot = false
    self.loot = nil
    self.chanceloottable = nil

    self.trappable = true

    self.lootfn = nil
    self.flingtargetpos = nil
    self.flingtargetvariance = nil
end)

LootTables = {}
function SetSharedLootTable(name, table)
    LootTables[name] = table
end

function LootDropper:SetChanceLootTable(name)
    self.chanceloottable = name
end

function LootDropper:SetLoot(loots)
    self.loot = loots
    self.chanceloot = nil
    self.randomloot = nil
    self.numrandomloot = nil
end

function LootDropper:SetLootSetupFn(fn)
    self.lootsetupfn = fn
end

function LootDropper:AddRandomLoot(prefab, weight)
    if not self.randomloot then
        self.randomloot = {}
        self.totalrandomweight = 0
    end

    table.insert(self.randomloot, { prefab = prefab, weight = weight })
    self.totalrandomweight = self.totalrandomweight + weight
end

-- This overrides the normal loot table while haunted
function LootDropper:AddRandomHauntedLoot(prefab, weight)
    if not self.randomhauntedloot then
        self.randomhauntedloot = {}
        self.totalhauntedrandomweight = 0
    end

    table.insert(self.randomhauntedloot, { prefab = prefab, weight = weight })
    self.totalhauntedrandomweight = self.totalhauntedrandomweight + weight
end

function LootDropper:AddChanceLoot(prefab, chance)
    if not self.chanceloot then
        self.chanceloot = {}
    end
    table.insert(self.chanceloot, { prefab = prefab, chance = chance })
end

function LootDropper:AddIfNotChanceLoot(prefab)
    if not self.ifnotchanceloot then
        self.ifnotchanceloot = {}
    end
    table.insert(self.ifnotchanceloot, { prefab = prefab })
end

function LootDropper:PickRandomLoot()
    if self.inst.components.hauntable and self.inst.components.hauntable.haunted and self.totalhauntedrandomweight and self.totalhauntedrandomweight > 0 and self.randomhauntedloot then
        local rnd = math.random()*self.totalhauntedrandomweight
        for k,v in pairs(self.randomhauntedloot) do
            rnd = rnd - v.weight
            if rnd <= 0 then
                return v.prefab
            end
        end
    elseif self.totalrandomweight and self.totalrandomweight > 0 and self.randomloot then
        local rnd = math.random()*self.totalrandomweight
        for k,v in pairs(self.randomloot) do
            rnd = rnd - v.weight
            if rnd <= 0 then
                return v.prefab
            end
        end
    end
end

function LootDropper:GetFullRecipeLoot(recipe)
    local loot = {}

    for k,v in ipairs(recipe.ingredients) do
        local amt = v.amount
        for n = 1, amt do
            if v.deconstruct then
                local recipeloot = self:GetFullRecipeLoot(AllRecipes[v.type])
                for k,v in ipairs(recipeloot) do
                    table.insert(loot, v)
                end
            else
                table.insert(loot, v.type)
            end
        end
    end

    return loot
end

function LootDropper:GetRecipeLoot(recipe)
    local percent = 1

    local loots = {}

    if self.inst.components.finiteuses then
        percent = self.inst.components.finiteuses:GetPercent()
    end

    for k,v in ipairs(recipe.ingredients) do
        local amt = math.ceil( (v.amount * TUNING.HAMMER_LOOT_PERCENT) * percent)
        if self.inst:HasTag("burnt") then
            amt = math.ceil( (v.amount * TUNING.BURNT_HAMMER_LOOT_PERCENT) * percent)
        end
        for n = 1, amt do
            if v.deconstruct then
                local recipeloot = self:GetRecipeLoot(AllRecipes[v.type])
                for k,v in ipairs(recipeloot) do
                    table.insert(loots, v)
                end
            else
                table.insert(loots, v.type)
            end
        end
    end

    return loots
end

function LootDropper:GenerateLoot()
    local loots = {}

    if self.lootsetupfn then
        self.lootsetupfn(self)
    end

    if self.numrandomloot and math.random() <= (self.chancerandomloot or 1) then
        for k = 1, self.numrandomloot do
            local loot = self:PickRandomLoot()
            if loot then
                table.insert(loots, loot)
            end
        end
    end

    if self.chanceloot then
        for k,v in pairs(self.chanceloot) do
            if v.chance >= 1.0 then
                table.insert(loots, v.prefab)
            elseif math.random() < v.chance then
                table.insert(loots, v.prefab)
                self.droppingchanceloot = true
            end
        end
    end

    if self.chanceloottable then
        local loot_table = LootTables[self.chanceloottable]
        if loot_table then
            for i, entry in ipairs(loot_table) do
                local prefab = entry[1]
                local chance = entry[2]
                if chance >= 1.0 then
                    table.insert(loots, prefab)
                elseif math.random() <= chance then
                    table.insert(loots, prefab)
                    self.droppingchanceloot = true
                end
            end
        end
    end

    if not self.droppingchanceloot and self.ifnotchanceloot then
        self.inst:PushEvent("ifnotchanceloot")
        for k,v in pairs(self.ifnotchanceloot) do
            table.insert(loots, v.prefab)
        end
    end

    if self.loot then
        for k,v in ipairs(self.loot) do
            table.insert(loots, v)
        end
    end

    local recipe = AllRecipes[self.inst.prefab]
    if recipe then
        local recipeloot = self:GetRecipeLoot(recipe)
        for k,v in ipairs(recipeloot) do
            table.insert(loots, v)
        end
    end

    if self.inst:HasTag("burnt") and math.random() < .4 then
        table.insert(loots, "charcoal") -- Add charcoal to loot for burnt structures
    end

    return loots
end

function LootDropper:SetFlingTarget(pos, variance)
    self.flingtargetpos = pos
    self.flingtargetvariance = variance
end

function LootDropper:FlingItem(loot, pt)
    if loot ~= nil then
        if pt == nil then
            pt = self.inst:GetPosition()
        end

        loot.Transform:SetPosition(pt:Get())

        local min_speed = self.min_speed or 0
        local max_speed = self.max_speed or 2
        local y_speed = self.y_speed or 8
        local y_speed_variance = self.y_speed_variance or 4

        if loot.Physics ~= nil then
            local angle = self.flingtargetpos ~= nil and GetRandomWithVariance(self.inst:GetAngleToPoint(self.flingtargetpos), self.flingtargetvariance or 0) * DEGREES or math.random() * 2 * PI
            local speed = min_speed + math.random() * (max_speed - min_speed)
            if loot:IsAsleep() then
                local radius = .5 * speed + (self.inst.Physics ~= nil and loot:GetPhysicsRadius(1) + self.inst:GetPhysicsRadius(1) or 0)
                loot.Transform:SetPosition(
                    pt.x + math.cos(angle) * radius,
                    0,
                    pt.z - math.sin(angle) * radius
                )
            else
                local sinangle = math.sin(angle)
                local cosangle = math.cos(angle)
                loot.Physics:SetVel(speed * cosangle, GetRandomWithVariance(y_speed, y_speed_variance), speed * -sinangle)

                if self.inst ~= nil and self.inst.Physics ~= nil then
                    local radius = loot:GetPhysicsRadius(1) + self.inst:GetPhysicsRadius(1)
                    if not self.spawn_loot_inside_prefab then
                        loot.Transform:SetPosition(
                            pt.x + cosangle * radius,
                            pt.y,
                            pt.z - sinangle * radius
                        )
                    else
                        radius = radius * math.random()
                        loot.Transform:SetPosition(
                            pt.x + cosangle * radius,
                            pt.y + 0.5,
                            pt.z - sinangle * radius
                        )
                    end
                end

            end
        end
    end
end

function LootDropper:SpawnLootPrefab( lootprefab, pt, linked_skinname, skin_id, userid )
    if lootprefab ~= nil then
        local loot = SpawnPrefab( lootprefab, linked_skinname, skin_id, userid )
        if loot ~= nil then
            if loot.components.inventoryitem ~= nil then
                if self.inst.components.inventoryitem ~= nil then
                    loot.components.inventoryitem:InheritMoisture(self.inst.components.inventoryitem:GetMoisture(), self.inst.components.inventoryitem:IsWet())
                else
                    loot.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
                end
            end

        -- here? so we can run a full drop loot?
            self:FlingItem(loot, pt)

            loot:PushEvent("on_loot_dropped", {dropper = self.inst})
            self.inst:PushEvent("loot_prefab_spawned", {loot = loot})

            return loot
        end
    end
end

function LootDropper:DropLoot(pt)
    local prefabs = self:GenerateLoot()
    if self.inst:HasTag("burnt")
        or (self.inst.components.burnable ~= nil and
            self.inst.components.burnable:IsBurning() and
            (self.inst.components.fueled == nil or self.inst.components.burnable.ignorefuel)) then

        local isstructure = self.inst:HasTag("structure")
        for k, v in pairs(prefabs) do
            if TUNING.BURNED_LOOT_OVERRIDES[v] ~= nil then
                prefabs[k] = TUNING.BURNED_LOOT_OVERRIDES[v]
            elseif PrefabExists(v.."_cooked") then
                prefabs[k] = v.."_cooked"
            elseif PrefabExists("cooked"..v) then
                prefabs[k] = "cooked"..v
            --V2C: This used to make hammering WHILE burning give ash only
            --     while hammering AFTER burnt give back good ingredients.
            --     It *should* ALWAYS return ash based on certain types of
            --     ingredients (wood), but we'll let them have this one :O
            elseif (not isstructure and not self.inst:HasTag("tree")) or self.inst:HasTag("hive") then -- because trees have specific burnt loot and "hive"s are structures...
                prefabs[k] = "ash"
            end
        end
    end
    for k, v in pairs(prefabs) do
        self:SpawnLootPrefab(v, pt)
    end

    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        local prefabname = string.upper(self.inst.prefab)
        local num_decor_loot = self.GetWintersFeastOrnaments ~= nil and self.GetWintersFeastOrnaments(self.inst) or TUNING.WINTERS_FEAST_TREE_DECOR_LOOT[prefabname] or nil
        if num_decor_loot ~= nil then
            for i = 1, num_decor_loot.basic do
                self:SpawnLootPrefab(GetRandomBasicWinterOrnament(), pt)
            end
            if num_decor_loot.special ~= nil then
                self:SpawnLootPrefab(num_decor_loot.special, pt)
            end
        elseif not TUNING.WINTERS_FEAST_LOOT_EXCLUSION[prefabname] and (self.inst:HasTag("monster") or self.inst:HasTag("animal")) then
            local loot = math.random()
            if loot < 0.005 then
                self:SpawnLootPrefab(GetRandomBasicWinterOrnament(), pt)
            elseif loot < 0.20 then
                self:SpawnLootPrefab("winter_food"..math.random(NUM_WINTERFOOD), pt)
            end
        end
    end

    TheWorld:PushEvent("entity_droploot", { inst = self.inst })
end

return LootDropper
