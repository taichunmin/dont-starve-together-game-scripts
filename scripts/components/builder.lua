local TechTree = require("techtree")

local function oningredientmod(self, ingredientmod)
    assert(INGREDIENT_MOD[ingredientmod] ~= nil, "Ingredient mods restricted to certain values, see constants.lua INGREDIENT_MOD")
    self.inst.replica.builder:SetIngredientMod(ingredientmod)
end

local function onfreebuildmode(self, freebuildmode)
    self.inst.replica.builder:SetIsFreeBuildMode(freebuildmode)
end

local function on_current_prototyper(self, current_prototyper)
	self.inst.replica.builder:SetCurrentPrototyper(current_prototyper)
end

local function metafn()
	local t =	{
		ingredientmod = oningredientmod,
		freebuildmode = onfreebuildmode,
		current_prototyper = on_current_prototyper,
	}
    for i, v in ipairs(TechTree.BONUS_TECH) do
        t[string.lower(v).."_bonus"] = function(self, bonus) self.inst.replica.builder:SetTechBonus(string.lower(v), bonus) end
        t[string.lower(v).."_tempbonus"] = function(self, bonus) self.inst.replica.builder:SetTempTechBonus(string.lower(v), (bonus or 0)) end
    end
	return t
end

local Builder = Class(function(self, inst)
    self.inst = inst

    self.recipes = {}
    self.station_recipes = {}
    self.accessible_tech_trees = TechTree.Create()
    self.accessible_tech_trees_no_temp = TechTree.Create()
	self.old_accessible_tech_trees = {}
    self.inst:StartUpdatingComponent(self)
    self.current_prototyper = nil
    self.buffered_builds = {}

    for i, v in ipairs(TechTree.BONUS_TECH) do
        self[string.lower(v).."_bonus"] = 0
    end
    self.ingredientmod = 1
    --self.last_hungry_build = nil
    --self.last_hungry_build_pt = nil

    self.freebuildmode = false

    self.inst.replica.builder:SetTechTrees(self.accessible_tech_trees)
    for k, v in pairs(AllRecipes) do
        if IsRecipeValid(v.name) then
            self.inst.replica.builder:SetIsBuildBuffered(v.name, false)
        end
    end

    self.exclude_tags = { "INLIMBO", "fire" }
    for k, v in pairs(CUSTOM_RECIPETABS) do
        if v.owner_tag ~= nil and not inst:HasTag(v.owner_tag) then
            table.insert(self.exclude_tags, v.owner_tag)
        end
    end
end,
nil,
metafn()
)

function Builder:ActivateCurrentResearchMachine(recipe)
    if self.current_prototyper ~= nil and
        self.current_prototyper.components.prototyper ~= nil and
        self.current_prototyper:IsValid() then
        self.current_prototyper.components.prototyper:Activate(self.inst, recipe)
    end
end

local function CheckHungryDistance(inst, last_hungry_build_pt)
    return inst:GetDistanceSqToPoint(last_hungry_build_pt) > TUNING.HUNGRY_BUILDER_RESET_DISTANCE_SQ
end

function Builder:OnSave()
    local hungrytime = self.last_hungry_build ~= nil and math.ceil(GetTime() - self.last_hungry_build) or math.huge
    hungrytime = hungrytime < TUNING.HUNGRY_BUILDER_RESET_TIME and hungrytime or nil
    local hungrypt = self.last_hungry_build_pt and not CheckHungryDistance(self.inst, self.last_hungry_build_pt) and {x=self.last_hungry_build_pt.x, y=self.last_hungry_build_pt.y, z=self.last_hungry_build_pt.z} or nil

    local tempbonuses = self:GetTempTechBonuses()

    return
    {
        buffered_builds = self.buffered_builds,
        recipes = self.recipes,
        hungrytime = hungrytime,
        hungrypt = hungrypt,
        tempbonuses = tempbonuses,
        temptechbonus_count = self.temptechbonus_count,
    }
end

function Builder:OnLoad(data)
    if data.buffered_builds ~= nil then
        for k, v in pairs(AllRecipes) do
            if data.buffered_builds[k] ~= nil and IsRecipeValid(v.name) then
                self.inst.replica.builder:SetIsBuildBuffered(v.name, true)
                self.buffered_builds[k] = true
            end
        end
    end

    if data.recipes ~= nil then
        for i, v in ipairs(data.recipes) do
            if IsRecipeValid(v) then
                self:AddRecipe(v)
            end
        end
    end

    if data.hungrytime ~= nil then
        self.last_hungry_build = GetTime() - data.hungrytime
    end
    if data.hungrypt then
        self.last_hungry_build_pt = Point(data.hungrypt.x, data.hungrypt.y, data.hungrypt.z)
    end

    if data.tempbonuses then
        self:GiveTempTechBonus(data.tempbonuses)
        self.temptechbonus_count = data.temptechbonus_count
    end
end

function Builder:IsBuildBuffered(recname)
    return self.buffered_builds[recname]
end

function Builder:OnUpdate()
    self:EvaluateTechTrees()
end

function Builder:GiveAllRecipes()
    self.freebuildmode = not self.freebuildmode
    self.inst:PushEvent("unlockrecipe")
end

local function propertech(recipetree, buildertree)
    for k, v in pairs(recipetree) do
        if buildertree[tostring(k)] ~= nil and
            recipetree[tostring(k)] ~= nil and
            recipetree[tostring(k)] > buildertree[tostring(k)] then
            return false
        end
    end
    return true
end

function Builder:UnlockRecipesForTech(tech)
    for k, v in pairs(AllRecipes) do
        if IsRecipeValid(v.name) and propertech(v.level, tech) then
            self:UnlockRecipe(v.name)
        end
    end
end

function Builder:GetTechBonuses()
	local bonus = {}
    for i, v in ipairs(TechTree.BONUS_TECH) do
        bonus[v] = self[string.lower(v).."_bonus"] or nil
        
        local tempbonus = self[string.lower(v).."_tempbonus"]
        if tempbonus ~= nil then
            if bonus[v] ~= nil then
                bonus[v] = bonus[v] + tempbonus
            else
                bonus[v] = tempbonus
            end
        end
    end

	return bonus
end

function Builder:GetTempTechBonuses()
    local bonus = {}
    for i, v in ipairs(TechTree.BONUS_TECH) do
        
        local tempbonus = self[string.lower(v).."_tempbonus"]
        if tempbonus ~= nil then
            bonus[v] = tempbonus
        end
    end

	return bonus
end

function Builder:GiveTempTechBonus(tech)
    for k, v in pairs(tech) do
        self[string.lower(k).."_tempbonus"] = v
    end

    if self.temptechbonus_count ~= nil then
        self.temptechbonus_count = self.temptechbonus_count + 1
    else
        self.temptechbonus_count = 1
    end
end

function Builder:ConsumeTempTechBonuses()
	if self.temptechbonus_count == nil then
		--we should NOT reach here normally; only assert in dev branch though!
		assert(BRANCH ~= "dev")
        return
    end

    self.temptechbonus_count = self.temptechbonus_count - 1
    if self.temptechbonus_count < 1 then
        for i, v in ipairs(TechTree.BONUS_TECH) do
            if self[string.lower(v).."_tempbonus"] ~= nil then
                self[string.lower(v).."_tempbonus"] = nil
            end
        end

        self.temptechbonus_count = nil
    end
end

local function CopyTechTrees(src, dest)
	for i, v in ipairs(TechTree.AVAILABLE_TECH) do
		dest[v] = src[v] or 0
	end
end

local PROTOTYPER_TAGS = { "prototyper" }
function Builder:EvaluateTechTrees()
    local pos = self.inst:GetPosition()

    local ents
	if self.override_current_prototyper then
		if self.override_current_prototyper:IsValid() 
			and self.override_current_prototyper:HasTags(PROTOTYPER_TAGS) 
			and not self.override_current_prototyper:HasOneOfTags(self.exclude_tags)
			and (self.override_current_prototyper.components.prototyper.restrictedtag == nil or self.inst:HasTag(self.override_current_prototyper.components.prototyper.restrictedtag))
			and self.inst:IsNear(self.override_current_prototyper, TUNING.RESEARCH_MACHINE_DIST)
			then

			ents = {self.override_current_prototyper}
		else
			self.override_current_prototyper = nil
		end
	end
	
	if ents == nil then
		ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.RESEARCH_MACHINE_DIST, PROTOTYPER_TAGS, self.exclude_tags)
	end

	CopyTechTrees(self.accessible_tech_trees, self.old_accessible_tech_trees)
    local old_station_recipes = self.station_recipes
    local old_prototyper = self.current_prototyper
    self.current_prototyper = nil
    self.station_recipes = {}

    local prototyper_active = false
    for i, v in ipairs(ents) do
        if v.components.prototyper ~= nil and (v.components.prototyper.restrictedtag == nil or self.inst:HasTag(v.components.prototyper.restrictedtag)) then
            if not prototyper_active then
                --activate the first machine in the list. This will be the one you're closest to.
                v.components.prototyper:TurnOn(self.inst)

				--prototyper:GetTrees() returns a deepcopy, which we no longer want
				CopyTechTrees(v.components.prototyper.trees, self.accessible_tech_trees)

                if v.components.craftingstation ~= nil then
                    local recs = v.components.craftingstation:GetRecipes(self.inst)
                    for _, recname in ipairs(recs) do
						local recipe = GetValidRecipe(recname)
                        if recipe ~= nil and recipe.nounlock then
                            --only nounlock recipes can be unlocked via crafting station
                            self.station_recipes[recname] = true
						end
                    end
				end

                prototyper_active = true
                self.current_prototyper = v
            else
                --you've already activated a machine. Turn all the other machines off.
                v.components.prototyper:TurnOff(self.inst)
            end
        end
    end

    --V2C: Hacking giftreceiver logic in here so we do
    --     not have to duplicate the same search logic
    if self.inst.components.giftreceiver ~= nil then
        self.inst.components.giftreceiver:SetGiftMachine(
            self.current_prototyper ~= nil and
            self.current_prototyper:HasTag("giftmachine") and
            CanEntitySeeTarget(self.inst, self.current_prototyper) and
            self.inst.components.inventory.isopen and --ignores .isvisible, as long as it's .isopen
            self.current_prototyper or
            nil)
    end

    --add any character specific bonuses to your current tech levels.
	CopyTechTrees(self.accessible_tech_trees, self.accessible_tech_trees_no_temp)
    if not prototyper_active then
        for i, v in ipairs(TechTree.AVAILABLE_TECH) do
            self.accessible_tech_trees_no_temp[v] = (self[string.lower(v).."_bonus"] or 0)
            self.accessible_tech_trees[v] = (self[string.lower(v).."_tempbonus"] or 0) + (self[string.lower(v).."_bonus"] or 0)
        end
    else
		for i, v in ipairs(TechTree.BONUS_TECH) do
            self.accessible_tech_trees_no_temp[v] = self.accessible_tech_trees_no_temp[v] + (self[string.lower(v).."_bonus"] or 0)
			self.accessible_tech_trees[v] = self.accessible_tech_trees[v] + 
                                            (self[string.lower(v).."_tempbonus"] or 0) + 
                                            (self[string.lower(v).."_bonus"] or 0)
		end
	end

    if old_prototyper ~= nil and
        old_prototyper ~= self.current_prototyper and
        old_prototyper.components.prototyper ~= nil and
        old_prototyper.entity:IsValid() then
        old_prototyper.components.prototyper:TurnOff(self.inst)
    end

    local trees_changed = false

    for recname, _ in pairs(self.station_recipes) do
        if old_station_recipes[recname] then
            old_station_recipes[recname] = nil
        else
            self.inst.replica.builder:AddRecipe(recname)
            trees_changed = true
        end
    end

    if next(old_station_recipes) ~= nil then
        for recname, _ in pairs(old_station_recipes) do
            self.inst.replica.builder:RemoveRecipe(recname)
        end
		trees_changed = true
    end

    if not trees_changed then
        for k, v in pairs(self.old_accessible_tech_trees) do
            if v ~= self.accessible_tech_trees[k] then
                trees_changed = true
                break
            end
        end
		--V2C: not required anymore; both trees should have the same keys now
        --[[if not trees_changed then
            for k, v in pairs(self.accessible_tech_trees) do
                if v ~= self.old_accessible_tech_trees[k] then
                    trees_changed = true
                    break
                end
            end
        end]]
    end

    if trees_changed then
        self.inst:PushEvent("techtreechange", { level = self.accessible_tech_trees })
        self.inst.replica.builder:SetTechTrees(self.accessible_tech_trees)
    end

	if self.override_current_prototyper ~= nil then
		if self.override_current_prototyper ~= self.current_prototyper then
			self.override_current_prototyper = nil
		elseif self.override_current_prototyper ~= old_prototyper then
			self.inst.replica.builder:OpenCraftingMenu()
		end
	end
end

function Builder:UsePrototyper(prototyper)
	if prototyper ~= nil then
		if not prototyper:HasTags(PROTOTYPER_TAGS) 
			or prototyper:HasOneOfTags(self.exclude_tags)
			or (prototyper.components.prototyper ~= nil and prototyper.components.prototyper.restrictedtag ~= nil and not self.inst:HasTag(prototyper.components.prototyper.restrictedtag))
			then

			local fail_str = prototyper.components.prototyper and prototyper.components.prototyper.restrictedtag or nil
			return false, fail_str ~= nil and string.upper(fail_str) or nil
		end
	end

	self.override_current_prototyper = prototyper
	if prototyper ~= nil and prototyper == self.current_prototyper then
		self.inst.replica.builder:OpenCraftingMenu()
	end
	return true
end

function Builder:AddRecipe(recname)
    if not table.contains(self.recipes, recname) then
        table.insert(self.recipes, recname)
    end
    self.inst.replica.builder:AddRecipe(recname)
end

function Builder:RemoveRecipe(recname)
	table.removearrayvalue(self.recipes, recname)
	self.inst.replica.builder:RemoveRecipe(recname)
end

function Builder:UnlockRecipe(recname)
    local recipe = GetValidRecipe(recname)
    if recipe ~= nil and not recipe.nounlock then
    --print("Unlocking: ", recname)
        if self.inst.components.sanity ~= nil then
            self.inst.components.sanity:DoDelta(TUNING.SANITY_MED)
        end
        self:AddRecipe(recname)
        self.inst:PushEvent("unlockrecipe", { recipe = recname })
    end
end

function Builder:GetIngredientWetness(ingredients)
    local wetness = {}
    for item, ents in pairs(ingredients) do
        for k, v in pairs(ents) do
            table.insert(wetness,
            {
				wetness =
					(k.components.inventoryitem ~= nil and k.components.inventoryitem:GetMoisture()) or
					(k.components.rainimmunity == nil and TheWorld.state.wetness) or
					0,
                num = v,
            })
        end
    end

    local totalWetness = 0
    local totalItems = 0
    for k,v in pairs(wetness) do
        totalWetness = totalWetness + (v.wetness * v.num)
        totalItems = totalItems + v.num
    end

    return totalItems > 0 and totalWetness or 0
end

function Builder:GetIngredients(recname)
    local recipe = AllRecipes[recname]
    if recipe then
        local ingredients = {}
		local discounted = false
        for k,v in pairs(recipe.ingredients) do
			if v.amount > 0 then
				local amt = math.max(1, RoundBiasedUp(v.amount * self.ingredientmod))
				local items = self.inst.components.inventory:GetCraftingIngredient(v.type, amt)
				ingredients[v.type] = items
				if amt < v.amount then
					discounted = true
				end
			end
        end
        return ingredients, discounted
    end
end

function Builder:RemoveIngredients(ingredients, recname, discounted)
	if self.freebuildmode then
		return
	end

    for item, ents in pairs(ingredients) do
        for k,v in pairs(ents) do
            for i = 1, v do
                local item = self.inst.components.inventory:RemoveItem(k, false, true)

                -- If the item we're crafting with is a container,
                -- drop the contained items onto the ground.
                if item.components.container ~= nil then
                    item.components.container:DropEverything(self.inst:GetPosition())
                end

                item:Remove()
            end
        end
    end

    local recipe = AllRecipes[recname]
    if recipe then
        for k,v in pairs(recipe.character_ingredients) do
            if v.type == CHARACTER_INGREDIENT.HEALTH then
                self.inst:PushEvent("consumehealthcost")
                self.inst.components.health:DoDelta(-v.amount, false, "builder", true, nil, true)
            elseif v.type == CHARACTER_INGREDIENT.MAX_HEALTH then
                self.inst:PushEvent("consumehealthcost")
                self.inst.components.health:DeltaPenalty(v.amount)
            elseif v.type == CHARACTER_INGREDIENT.SANITY then
                self.inst.components.sanity:DoDelta(-v.amount)
            elseif v.type == CHARACTER_INGREDIENT.MAX_SANITY then
                --[[
                    Because we don't have any maxsanity restoring items we want to be more careful
                    with how we remove max sanity. Because of that, this is not handled here.
                    Removal of sanity is actually managed by the entity that is created.
                    See maxwell's pet leash on spawn and pet on death functions for examples.

					Note: Make sure you handle self.freebuildmode in this case
                --]]
            end
        end
    end
    self.inst:PushEvent("consumeingredients", { discounted = discounted })
end

function Builder:HasCharacterIngredient(ingredient)
    if ingredient.type == CHARACTER_INGREDIENT.HEALTH then
        if self.inst.components.health ~= nil then
            --round up health to match UI display
			local amount_required = self.inst:HasTag("health_as_oldage") and math.ceil(ingredient.amount * TUNING.OLDAGE_HEALTH_SCALE) or ingredient.amount
            local current = math.ceil(self.inst.components.health.currenthealth)
            return current > amount_required, current --Don't die from crafting!
        end
    elseif ingredient.type == CHARACTER_INGREDIENT.MAX_HEALTH then
        if self.inst.components.health ~= nil then
            local penalty = self.inst.components.health:GetPenaltyPercent()
            return penalty + ingredient.amount <= TUNING.MAXIMUM_HEALTH_PENALTY, 1 - penalty
        end
    elseif ingredient.type == CHARACTER_INGREDIENT.SANITY then
        if self.inst.components.sanity ~= nil then
            --round up sanity to match UI display
            local current = math.ceil(self.inst.components.sanity.current)
            return current >= ingredient.amount, current
        end
    elseif ingredient.type == CHARACTER_INGREDIENT.MAX_SANITY then
        if self.inst.components.sanity ~= nil then
            local penalty = self.inst.components.sanity:GetPenaltyPercent()
            return penalty + ingredient.amount <= TUNING.MAXIMUM_SANITY_PENALTY, 1 - penalty
        end
    end
    return false, 0
end

function Builder:HasTechIngredient(ingredient)
    if IsTechIngredient(ingredient.type) and ingredient.type:sub(-9) == "_material" then
        local level = self.accessible_tech_trees[ingredient.type:sub(1, -10):upper()] or 0
        return level >= ingredient.amount, level
    end
    return false, 0
end

function Builder:MakeRecipe(recipe, pt, rot, skin, onsuccess)
    if recipe ~= nil and not self.inst.sg:HasStateTag("drowning") then -- TODO(JBK): Check if "drowning" can be replaced with "busy" instead with no side effects.
        self.inst:PushEvent("makerecipe", { recipe = recipe })
        if self:IsBuildBuffered(recipe.name) or self:HasIngredients(recipe) then
            self.inst.components.locomotor:Stop()
            local buffaction = BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, pt or self.inst:GetPosition(), recipe.name, recipe.build_distance, nil, rot)
            buffaction.skin = skin
            if onsuccess ~= nil then
                buffaction:AddSuccessAction(onsuccess)
            end
            self.inst.components.locomotor:PushAction(buffaction, true)
            return true
        end
    end
    return false
end

local function GiveOrDropItem(self, recipe, item, pt)
	if recipe.dropitem then
		local angle = (self.inst.Transform:GetRotation() + GetRandomMinMax(-65, 65)) * DEGREES
		local r = item:GetPhysicsRadius(0.5) + self.inst:GetPhysicsRadius(0.5) + 0.1
		item.Transform:SetPosition(pt.x + r * math.cos(angle), pt.y, pt.z - r * math.sin(angle))
		item.components.inventoryitem:OnDropped()
	else
	    self.inst.components.inventory:GiveItem(item, nil, pt)
	end
end

function Builder:DoBuild(recname, pt, rotation, skin)
    local recipe = GetValidRecipe(recname)
    if recipe ~= nil and (self:IsBuildBuffered(recname) or self:HasIngredients(recipe)) and not PREFAB_SKINS_SHOULD_NOT_SELECT[skin] then
        if recipe.placer ~= nil and
            self.inst.components.rider ~= nil and
            self.inst.components.rider:IsRiding() then
            return false, "MOUNTED"
        elseif recipe.level.ORPHANAGE > 0 and (
                self.inst.components.petleash == nil or
                self.inst.components.petleash:IsFull() or
                self.inst.components.petleash:HasPetWithTag("critter")
            ) then
            return false, "HASPET"
        elseif recipe.manufactured and (
                self.current_prototyper == nil or
                not self.current_prototyper:IsValid() or
                self.current_prototyper.components.prototyper == nil or
                not CanPrototypeRecipe(recipe.level, self.current_prototyper.components.prototyper.trees)
            ) then
            -- manufacturing stations requires the current active protyper in order to work
            return false
        end

        if recipe.canbuild ~= nil then
			local success, msg = recipe.canbuild(recipe, self.inst, pt, rotation)
			if not success then
				return false, msg
			end
		end

		local is_buffered_build = self.buffered_builds[recname] ~= nil
        if is_buffered_build then
            self.buffered_builds[recname] = nil
            self.inst.replica.builder:SetIsBuildBuffered(recname, false)
        end

        if self.inst:HasTag("hungrybuilder") and not self.inst.sg:HasStateTag("slowaction") and not self.inst.sg:HasStateTag("giving") then
            local t = GetTime()
            local hasTimeExpired = self.last_hungry_build == nil or t > self.last_hungry_build + TUNING.HUNGRY_BUILDER_RESET_TIME
            local hasPlayerMoved = self.last_hungry_build_pt == nil or CheckHungryDistance(self.inst, self.last_hungry_build_pt)
            if hasTimeExpired and hasPlayerMoved then
                self.inst.sg.mem.dohungryfastbuildtalk = true
                self.inst.components.hunger:DoDelta(TUNING.HUNGRY_BUILDER_DELTA)
                self.inst:PushEvent("hungrybuild")
            else
                self.inst.sg.mem.dohungryfastbuildtalk = nil
            end
            self.last_hungry_build = t
            self.last_hungry_build_pt = self.inst:GetPosition()
        end

        self.inst:PushEvent("refreshcrafting")

		if recipe.manufactured then
			local materials, discounted = self:GetIngredients(recname)
			self:RemoveIngredients(materials, recname, discounted)
			   -- its up to the prototyper to implement onactivate and handle spawning the prefab
		   return true
		end

        local prod = SpawnPrefab(recipe.product, recipe.chooseskin or skin, nil, self.inst.userid) or nil
        if prod ~= nil then
            pt = pt or self.inst:GetPosition()

            if prod.components.inventoryitem ~= nil then
                if self.inst.components.inventory ~= nil then
					local materials, discounted = self:GetIngredients(recname)

					local wetlevel = self:GetIngredientWetness(materials)
					if wetlevel > 0 and prod.components.inventoryitem ~= nil then
						prod.components.inventoryitem:InheritMoisture(wetlevel, self.inst:GetIsWet())
					end

					if prod.onPreBuilt ~= nil then
						prod:onPreBuilt(self.inst, materials, recipe)
					end

					self:RemoveIngredients(materials, recname, discounted)

                    --self.inst.components.inventory:GiveItem(prod)
                    self.inst:PushEvent("builditem", { item = prod, recipe = recipe, skin = skin, prototyper = self.current_prototyper })
                    if self.current_prototyper ~= nil and self.current_prototyper:IsValid() then
                        self.current_prototyper:PushEvent("builditem", { item = prod, recipe = recipe, skin = skin }) -- added this back for the gorge.
                    end
                    ProfileStatsAdd("build_"..prod.prefab)

                    if prod.components.equippable ~= nil
						and not recipe.dropitem
                        and self.inst.components.inventory:GetEquippedItem(prod.components.equippable.equipslot) == nil
                        and not prod.components.equippable:IsRestricted(self.inst) then
                        if recipe.numtogive <= 1 then
                            --The item is equippable. Equip it.
                            self.inst.components.inventory:Equip(prod)
                        elseif prod.components.stackable ~= nil then
                            --The item is stackable. Just increase the stack size of the original item.
                            prod.components.stackable:SetStackSize(recipe.numtogive)
                            self.inst.components.inventory:Equip(prod)
                        else
                            --We still need to equip the original product that was spawned, so do that.
                            self.inst.components.inventory:Equip(prod)
                            --Now spawn in the rest of the items and give them to the player.
                            for i = 2, recipe.numtogive do
                                local addt_prod = SpawnPrefab(recipe.product)
                                self.inst.components.inventory:GiveItem(addt_prod, nil, pt)
                            end
                        end
                    elseif recipe.numtogive <= 1 then
                        --Only the original item is being received.
						GiveOrDropItem(self, recipe, prod, pt)
                    elseif prod.components.stackable ~= nil then
                        --The item is stackable. Just increase the stack size of the original item.
                        prod.components.stackable:SetStackSize(recipe.numtogive)
						GiveOrDropItem(self, recipe, prod, pt)
                    else
                        --We still need to give the player the original product that was spawned, so do that.
						GiveOrDropItem(self, recipe, prod, pt)
                        --Now spawn in the rest of the items and give them to the player.
                        for i = 2, recipe.numtogive do
                            local addt_prod = SpawnPrefab(recipe.product)
							GiveOrDropItem(self, recipe, addt_prod, pt)
                        end
                    end

                    NotifyPlayerProgress("TotalItemsCrafted", 1, self.inst)

                    if self.onBuild ~= nil then
                        self.onBuild(self.inst, prod)
                    end
                    prod:OnBuilt(self.inst)

                    return true
				else
					prod:Remove()
					prod = nil
                end
            else
				if not is_buffered_build then -- items that have intermediate build items (like statues)
					local materials, discounted = self:GetIngredients(recname)
					self:RemoveIngredients(materials, recname, discounted)
				end

                local spawn_pos = pt

                -- If a non-inventoryitem recipe specifies dropitem, position the created object
                -- away from the builder so that they don't overlap.
                if recipe.dropitem then
                    local angle = (self.inst.Transform:GetRotation() + GetRandomMinMax(-65, 65)) * DEGREES
                    local r = prod:GetPhysicsRadius(0.5) + self.inst:GetPhysicsRadius(0.5) + 0.1
                    spawn_pos = Vector3(
                        spawn_pos.x + r * math.cos(angle),
                        spawn_pos.y,
                        spawn_pos.z - r * math.sin(angle)
                    )
                end

                prod.Transform:SetPosition(spawn_pos:Get())
                --V2C: or 0 check added for backward compatibility with mods that
                --     have not been updated to support placement rotation yet
                prod.Transform:SetRotation(rotation or 0)
                self.inst:PushEvent("buildstructure", { item = prod, recipe = recipe, skin = skin })
                prod:PushEvent("onbuilt", { builder = self.inst, pos = pt })
                ProfileStatsAdd("build_"..prod.prefab)
                NotifyPlayerProgress("TotalItemsCrafted", 1, self.inst)

                if self.onBuild ~= nil then
                    self.onBuild(self.inst, prod)
                end

                prod:OnBuilt(self.inst)

                return true
            end
        end
    end
end

function Builder:KnowsRecipe(recipe, ignore_tempbonus)
    if type(recipe) == "string" then
		recipe = GetValidRecipe(recipe)
	end

    if recipe == nil then
        return false
    end
	if self.freebuildmode then
		return true
	elseif recipe.builder_tag ~= nil and not self.inst:HasTag(recipe.builder_tag) then -- builder_tag cehck is require due to character swapping
		return false
    elseif recipe.builder_skill ~= nil and not self.inst.components.skilltreeupdater:IsActivated(recipe.builder_skill) then -- builder_skill check is require due to character swapping
        return false
	elseif self.station_recipes[recipe.name] or table.contains(self.recipes, recipe.name) then
		return true
	end

    local has_tech = true
    for i, v in ipairs(TechTree.AVAILABLE_TECH) do
        if ignore_tempbonus then
            if recipe.level[v] > (self[string.lower(v).."_bonus"] or 0) then
                return false
            end
        else
            if recipe.level[v] > ((self[string.lower(v).."_bonus"] or 0) + (self[string.lower(v).."_tempbonus"] or 0)) then
                return false
            end
        end
    end

    return true
end

function Builder:HasIngredients(recipe)
    if type(recipe) == "string" then 
		recipe = GetValidRecipe(recipe)
	end
	if recipe ~= nil then
		if self.freebuildmode then
			return true
		end
		for i, v in ipairs(recipe.ingredients) do
            if not self.inst.components.inventory:Has(v.type, math.max(1, RoundBiasedUp(v.amount * self.ingredientmod)), true) then
				return false
			end
		end
		for i, v in ipairs(recipe.character_ingredients) do
			if not self:HasCharacterIngredient(v) then
				return false
			end
		end
		for i, v in ipairs(recipe.tech_ingredients) do
			if not self:HasTechIngredient(v) then
				return false
			end
		end
		return true
	end

	return false
end

function Builder:CanBuild(recipe_name) -- deprecated, use HasIngredients instead
	return self:HasIngredients(GetValidRecipe(recipe_name))
end

function Builder:CanLearn(recname)
    local recipe = GetValidRecipe(recname)
    return recipe ~= nil
        and (recipe.builder_tag == nil or self.inst:HasTag(recipe.builder_tag))
        and (recipe.builder_skill == nil or self.inst.components.skilltreeupdater:IsActivated(recipe.builder_skill))
end

function Builder:LongUpdate(dt)
    if self.last_hungry_build ~= nil then
        self.last_hungry_build = self.last_hungry_build - dt
    end
end

--------------------------------------------------------------------------
--RPC handlers
--------------------------------------------------------------------------

function Builder:MakeRecipeFromMenu(recipe, skin)
    if not self.inst.components.inventory:IsOpenedBy(self.inst) then
        return -- NOTES(JBK): The inventory was hidden by gameplay do not allow crafting.
    end
    if self:HasIngredients(recipe) then
		if recipe.placer == nil then
			--Need to determine this NOW before calling async MakeRecipe
			local knows_no_temp = self:KnowsRecipe(recipe, true)
			local canproto_no_temp = CanPrototypeRecipe(recipe.level, self.accessible_tech_trees_no_temp)
			local canlearn = self:CanLearn(recipe.name)
			local usingtempbonus = not knows_no_temp and not canproto_no_temp

			if self:KnowsRecipe(recipe) then
                self:MakeRecipe(recipe, nil, nil, ValidateRecipeSkinRequest(self.inst.userid, recipe.product, skin),
                    function()
						if usingtempbonus then
							self:ConsumeTempTechBonuses()
						end

                        if self.freebuildmode then
                            --V2C: free-build should still trigger prototyping
                            if not table.contains(self.recipes, recipe.name) and CanPrototypeRecipe(recipe.level, self.accessible_tech_trees) then
                                self:ActivateCurrentResearchMachine(recipe)
                            end
						elseif not knows_no_temp and canproto_no_temp and canlearn then
							--assert(not usingtempbonus) --sanity check
							--V2C: for recipes known through temp bonus buff,
							--     but can be prototyped without consuming it
							self:ActivateCurrentResearchMachine(recipe)
							self:UnlockRecipe(recipe.name)
                        elseif not recipe.nounlock then
                            --V2C: for recipes known through tech bonus, still
                            --     want to unlock in case we reroll characters
                            self:AddRecipe(recipe.name)
						else
							self:ActivateCurrentResearchMachine(recipe)
                        end

                    end
                )
			elseif canlearn and CanPrototypeRecipe(recipe.level, self.accessible_tech_trees) then
				self:MakeRecipe(recipe, nil, nil, ValidateRecipeSkinRequest(self.inst.userid, recipe.product, skin),
					function()
						if usingtempbonus then
							self:ConsumeTempTechBonuses()
						end
						self:ActivateCurrentResearchMachine(recipe)
						self:UnlockRecipe(recipe.name)
					end
				)
			end
        end
	else
		for i, ing in ipairs(recipe.ingredients) do
			local ing_recipe = GetValidRecipe(ing.type)
			if ing_recipe ~= nil and not self.inst.components.inventory:Has(ing.type, math.max(1, RoundBiasedUp(ing.amount * self.ingredientmod)), true) and self:HasIngredients(ing_recipe) then
				--Need to determine this NOW before calling async MakeRecipe
				local knows_no_temp = self:KnowsRecipe(ing_recipe, true)
				local canproto_no_temp = CanPrototypeRecipe(ing_recipe.level, self.accessible_tech_trees_no_temp)
				local canlearn = self:CanLearn(ing_recipe.name)
				local usingtempbonus = not knows_no_temp and not canproto_no_temp

				if self:KnowsRecipe(ing_recipe) then
					self:MakeRecipe(ing_recipe, nil, nil, ValidateRecipeSkinRequest(self.inst.userid, ing_recipe.product, nil),
						function()
							if usingtempbonus then
								self:ConsumeTempTechBonuses()
							end

							if self.freebuildmode then
								--V2C: free-build should still trigger prototyping
								if not table.contains(self.recipes, ing_recipe.name) and CanPrototypeRecipe(ing_recipe.level, self.accessible_tech_trees) then
									self:ActivateCurrentResearchMachine(ing_recipe)
								end
							elseif not knows_no_temp and canproto_no_temp and canlearn then
								--assert(not usingtempbonus) --sanity check
								--V2C: for recipes known through temp bonus buff,
								--     but can be prototyped without consuming it
								self:ActivateCurrentResearchMachine(ing_recipe)
								self:UnlockRecipe(ing_recipe.name)
							elseif not ing_recipe.nounlock then
								--V2C: for recipes known through tech bonus, still
								--     want to unlock in case we reroll characters
								self:AddRecipe(ing_recipe.name)
							else
								self:ActivateCurrentResearchMachine(ing_recipe)
							end
						end
					)
				elseif canlearn and CanPrototypeRecipe(ing_recipe.level, self.accessible_tech_trees) then
					self:MakeRecipe(ing_recipe, nil, nil, ValidateRecipeSkinRequest(self.inst.userid, ing_recipe.product, nil),
						function()
							if usingtempbonus then
								self:ConsumeTempTechBonuses()
							end
							self:ActivateCurrentResearchMachine(ing_recipe)
							self:UnlockRecipe(ing_recipe.name)
						end
					)
				end
			end
		end

    end
end

function Builder:MakeRecipeAtPoint(recipe, pt, rot, skin)
    if not self.inst.components.inventory:IsOpenedBy(self.inst) then
        return -- NOTES(JBK): The inventory was hidden by gameplay do not allow crafting.
    end

    if recipe.placer ~= nil and
        self:KnowsRecipe(recipe) and
        self:IsBuildBuffered(recipe.name) and
        TheWorld.Map:CanDeployRecipeAtPoint(pt, recipe, rot) then
        self:MakeRecipe(recipe, pt, rot, skin)
    end
end

function Builder:BufferBuild(recname)
    if not self.inst.components.inventory:IsOpenedBy(self.inst) then
        return -- NOTES(JBK): The inventory was hidden by gameplay do not allow crafting.
    end

    local recipe = GetValidRecipe(recname)
    if recipe ~= nil and recipe.placer ~= nil and not self:IsBuildBuffered(recname) and self:HasIngredients(recipe) then
		local knows_no_temp = self:KnowsRecipe(recipe, true)
		local canproto_no_temp = CanPrototypeRecipe(recipe.level, self.accessible_tech_trees_no_temp)
		local canlearn = self:CanLearn(recname)
		local usingtempbonus = not knows_no_temp and not canproto_no_temp

        if self:KnowsRecipe(recipe) then
			if usingtempbonus then
				self:ConsumeTempTechBonuses()
			end

            if self.freebuildmode then
                --V2C: free-build should still trigger prototyping
                if not table.contains(self.recipes, recname) and CanPrototypeRecipe(recipe.level, self.accessible_tech_trees) then
					-- Note:	This can currently activate prototypers that have no relation to the item or structure
					--			built, such as when building a Fire Pit near a Science Machine or Mad Science Lab.
                    self:ActivateCurrentResearchMachine(recipe)
                end
			elseif not knows_no_temp and canproto_no_temp and canlearn then
				--assert(not usingtempbonus) --sanity check
				--V2C: for recipes known through temp bonus buff,
				--     but can be prototyped without consuming it
				self:ActivateCurrentResearchMachine(recipe)
				self:UnlockRecipe(recname)
            elseif not recipe.nounlock then
                --V2C: for recipes known through tech bonus, still
                --     want to unlock in case we reroll characters
                self:AddRecipe(recname)
            end
		elseif canlearn and CanPrototypeRecipe(recipe.level, self.accessible_tech_trees) then
			if usingtempbonus then
				self:ConsumeTempTechBonuses()
			end
			self:ActivateCurrentResearchMachine(recipe)
			self:UnlockRecipe(recname)
		else
			return
		end

        local materials, discounted = self:GetIngredients(recname)
        self:RemoveIngredients(materials, recname, discounted)
        self.buffered_builds[recname] = true
        self.inst.replica.builder:SetIsBuildBuffered(recname, true)
    end
end

return Builder
