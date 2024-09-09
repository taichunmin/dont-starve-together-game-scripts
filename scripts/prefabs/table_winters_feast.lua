local assets =
{
    Asset("ANIM", "anim/table_winters_feast.zip"),
	Asset("ANIM", "anim/winona_battery_placement.zip"),
}

local prefabs =
{
	"collapse_small",
	"wintersfeastbuff",
	"winters_feast_depletefood",
	"winters_feast_food_depleted",
}

-- Placeholder sounds
local sounds =
{
	place_food = "wintersfeast2019/winters_feast/table/food",
	food_fx = "wintersfeast2019/winters_feast/table/fx",
	eject_food = "wintersfeast2019/winters_feast/table/food",
	finish_food = "wintersfeast2019/winters_feast/table/fx",
	ruffle = "dontstarve/creatures/together/stagehand/awake_pre",
	hit = "wintersfeast2019/winters_feast/table/bump",
	built = "wintersfeast2019/winters_feast/table/place",
	bump = "wintersfeast2019/winters_feast/table/bump",
}

local FOOD_BUMP_DELAY = 31*FRAMES


local FOOD_LAUNCH_SPEED = 2
local FOOD_LAUNCH_STARTHEIGHT = 1

local function SetFoodSymbol(inst, foodname, override_build)
	if foodname == nil then
		inst.AnimState:ClearOverrideSymbol("swap_cooked")
	else
		inst.AnimState:OverrideSymbol("swap_cooked", override_build or "food_winters_feast_2019", foodname)
	end
end

local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    elseif (not item:HasTag("wintersfeastcookedfood") and not item:HasTag("preparedfood")) or
		inst:HasTag("takeshelfitem") or
		not inst.components.trader.enabled or
		inst:HasTag("fire") or inst:HasTag("burnt") then

		return false
    end
    return true
end

local function DropFoodFromShelf(inst)
	local item = inst.components.shelf.itemonshelf

	if item ~= nil then
		local cantakeitem = inst.components.shelf.cantakeitem
		inst.components.shelf.cantakeitem = true
		inst.components.shelf:TakeItem(nil) -- taker = nil means item isn't given to an inventory
		inst.components.shelf.cantakeitem = cantakeitem

		return item
	end
end

local function onhammered(inst, worker)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
	end

	local item = DropFoodFromShelf(inst)
	if item ~= nil then
		item.Transform:SetPosition(inst.Transform:GetWorldPosition())
	end

	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")
	inst:Remove()
end

local function onhit(inst, worker)
	print("table burnt:", inst:HasTag("burnt"))
	if inst.AnimState:IsCurrentAnimation("idle") and not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle")
		inst.SoundEmitter:PlaySound(sounds.hit)
	end
end

local function OnAnimOver(inst)
	inst.components.trader:Enable()
	inst:RemoveEventCallback("animover", OnAnimOver)
end

local function EjectFood(inst)
	local item = DropFoodFromShelf(inst)

	if item ~= nil then
		item.Transform:SetPosition(inst.Transform:GetWorldPosition())

		-- Turning off collision with obstacles so item can be spawned inside table collider
		item.Physics:ClearCollidesWith(COLLISION.OBSTACLES)
		item:DoTaskInTime(0.5, function(inst) inst.Physics:CollidesWith(COLLISION.OBSTACLES) end)

		Launch2(item, inst, FOOD_LAUNCH_SPEED, 1, FOOD_LAUNCH_STARTHEIGHT, 0)
	end
	if inst.AnimState:IsCurrentAnimation("bump") then
		inst.SoundEmitter:PlaySound(sounds.bump)
		inst.SoundEmitter:PlaySound(sounds.eject_food)
	end
end

local function RefuseFood(inst)
	inst.AnimState:PlayAnimation("bump")
	inst.AnimState:PushAnimation("idle")

	-- In case we are already listening for this event (i.e. incorrect food rots in middle of bump animation)
	inst:RemoveEventCallback("animover", OnAnimOver)
	if inst._eject_task ~= nil then
		inst._eject_task:Cancel()
		inst._eject_task = nil
	end

	inst:ListenForEvent("animover", OnAnimOver)
	inst._eject_task = inst:DoTaskInTime(FOOD_BUMP_DELAY, EjectFood)
end

local function OnItemGiven(inst, giver, item)
	if item ~= nil then
		inst.components.shelf:PutItemOnShelf(item)
		inst.SoundEmitter:PlaySound(sounds.place_food)
	end
end
local function spawnfx(inst)
	if math.random()<0.3 then
		inst:DoTaskInTime(math.random()* 1/3, function() SpawnPrefab("winters_feast_depletefood").Transform:SetPosition(inst.Transform:GetWorldPosition())end )
	end
end

local function OnDepleteFood(inst)
	if TheWorld.components.feasts then
		local group = TheWorld.components.feasts:GetTableGroup(inst)
		local feasters = 0

	    for i,set in ipairs(TheWorld.components.feasts:GetFeasters())do
	        local testgroup = TheWorld.components.feasts:GetTableGroup(set.target)
	        if group == testgroup then
	        	feasters = feasters+ 1
	        end
	    end

		if feasters > 0 then
			for i=1,feasters do
				spawnfx(inst)
			end
		end

	end
end

local function OnFinishFood(inst)
	local item_on_table = inst.components.inventory:GetItemInSlot(1)
	if item_on_table ~= nil then
		item_on_table.persists = false
	end

	inst:DoTaskInTime(math.random()*0.5,function()
		local item = DropFoodFromShelf(inst)
		if item ~= nil then
			item:Remove()
		end

		inst.components.trader:Enable()

		inst.components.wintersfeasttable.canfeast = false
		inst.components.shelf.cantakeitem = false

		SpawnPrefab("winters_feast_food_depleted").Transform:SetPosition(inst.Transform:GetWorldPosition())

	    inst.SoundEmitter:PlaySound(sounds.finish_food)
	end)
end

local function OnFoodRot(inst)
    inst:DoTaskInTime(0, function()
        local item = inst.components.inventory:GetItemInSlot(1)
        if item then
            inst.components.shelf:PutItemOnShelf(item)
        end
    end)
end

local function OnGetShelfItem(inst, item)
    item.OnRotFn = function() OnFoodRot(inst) end
    inst:ListenForEvent("perished", item.OnRotFn, item)

	if item ~= nil then
		inst.components.trader:Disable()

		if item.prefab == "spoiled_food" then
			SetFoodSymbol(inst, "spoiled01", item.AnimState:GetBuild())

			RefuseFood(inst)
			inst.components.wintersfeasttable.canfeast = false
			inst.components.shelf.cantakeitem = false
		elseif not item:HasTag("wintersfeastcookedfood") then
			if item:HasTag("spicedfood") then
				local spice_start, spice_end = string.find(item.prefab, "_spice_")
				local baseprefab = string.sub(item.prefab, 1, spice_start - 1)
				local spicesymbol = string.sub(item.prefab, spice_start + 1)

				SetFoodSymbol(inst, baseprefab, item.food_symbol_build or item.AnimState:GetBuild())
				inst.AnimState:OverrideSymbol("swap_garnish", "spices", spicesymbol)
				inst.AnimState:OverrideSymbol("swap_plate", "plate_food", "plate")
			else
				SetFoodSymbol(inst, item.prefab, item.AnimState:GetBuild())
			end

			RefuseFood(inst)
			inst.components.wintersfeasttable.canfeast = false
			inst.components.shelf.cantakeitem = false
		else
			-- A Festive Food item has been placed on the table
			SetFoodSymbol(inst, item.prefab)

			inst.components.wintersfeasttable.canfeast = true
			inst.components.shelf.cantakeitem = true

			inst.AnimState:PlayAnimation("food")
			inst.AnimState:PushAnimation("idle")

			inst.SoundEmitter:PlaySound(sounds.food_fx)
		end
	end
end

local function OnLoseShelfItem(inst, taker, item)
    if item and item.OnRotFn then
        inst:RemoveEventCallback("perished", item.OnRotFn, item)
    end

	inst.AnimState:ClearOverrideSymbol("swap_garnish")
	inst.AnimState:ClearOverrideSymbol("swap_plate")

	SetFoodSymbol(inst, nil)
	inst.components.wintersfeasttable.canfeast = false

	if not inst.AnimState:IsCurrentAnimation("bump") then
		inst.components.trader:Enable()
	end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
	inst.SoundEmitter:PlaySound(sounds.built)
	inst.SoundEmitter:PlaySound(sounds.food_fx)
end

local function onburnt(inst)
	EjectFood(inst)

	inst.components.trader:Disable()

	inst.components.wintersfeasttable.canfeast = false
	inst.components.shelf.cantakeitem = false

	if TheWorld.components.feasts then
		TheWorld.components.feasts:UnregisterTable(inst)
	end
end

local function onignite(inst)--, data)
	inst.components.trader:Disable()

	inst.components.wintersfeasttable.canfeast = false
end

local function onextinguish(inst)
	if not inst.AnimState:IsCurrentAnimation("bump") then
		if inst.components.shelf.itemonshelf == nil then
			inst.components.trader:Enable()
		else
			inst.components.wintersfeasttable.canfeast = true
		end
	end
end

local function onremove(inst)
	if inst.components.wintersfeasttable ~= nil then
		inst.components.wintersfeasttable:CancelFeasting()
	end

	if TheWorld.components.feasts then
		TheWorld.components.feasts:UnregisterTable(inst)
	end
end

local function OnSave(inst, data)
	if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
		data.burnt = true
	end
end

local function OnLoadPostPass(inst, ents, data)
	local item = inst.components.inventory:GetItemInSlot(1)
	if item ~= nil then
		inst.components.shelf:PutItemOnShelf(item)
	end

	if data ~= nil and data.burnt then
		inst.components.burnable.onburnt(inst)
		inst:PushEvent("onburnt")
	end
end

local function getstatus(inst)
	return (inst:HasTag("burnt") and "BURNT") or
		(inst.AnimState:IsCurrentAnimation("bump") and "WRONG_TYPE") or
		(inst:HasTag("takeshelfitem") and "HAS_FOOD") or
		"EMPTY"
end

local function onhaunt(inst)
	if inst:HasTag("readyforfeast") then
		RefuseFood(inst)
		inst.components.wintersfeasttable.canfeast = false
		inst.components.shelf.cantakeitem = false

		return true
	end
end

local PLACER_SCALE = 1.25

local function testforgrouphilighted(inst)
	if  TheWorld.components.feasts then
		local thisgroup = TheWorld.components.feasts:GetTableGroup(inst.parent)
		if thisgroup then
			for i,wintertable in ipairs(TheWorld.components.feasts:GetTableGroups()[thisgroup])do
				if wintertable ~= inst.parent and wintertable.highlited then
					return true
				end
			end
		end
	end
end

local function platformtest(instA,instB)
	local platA = instA:GetCurrentPlatform()
	local platB = instB:GetCurrentPlatform()
	if platA and platB and platA == platB then
		return true
	end
	if not platA and not platB then
		return true
	end
end

local function OnUpdatePlacerHelper(helperinst)

	helperinst.parent.highlited = nil

    if not helperinst.placerinst:IsValid() then
        helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    elseif (helperinst:IsNear(helperinst.placerinst, TUNING.WINTERSFEASTTABLE.TABLE_RANGE) and platformtest(helperinst,helperinst.placerinst)) or testforgrouphilighted(helperinst) then
        local hp = helperinst:GetPosition()
        local p1 = TheWorld.Map:GetPlatformAtPoint(hp.x, hp.z)

        local pp = helperinst.placerinst:GetPosition()
        local p2 = TheWorld.Map:GetPlatformAtPoint(pp.x, pp.z)

        if p1 == p2 then
            helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
            if helperinst:IsNear(helperinst.placerinst, TUNING.WINTERSFEASTTABLE.TABLE_RANGE) then
            	helperinst.parent.highlited = true
            end
        else
            helperinst.AnimState:SetAddColour(0, 0, 0, 0)

        end
    else
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    end
end

local function CreatePlacerRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("winona_battery_placement")
    inst.AnimState:SetBuild("winona_battery_placement")
    inst.AnimState:PlayAnimation("idle_small")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    return inst
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
    if enabled then
        if inst.helper == nil and not inst:HasTag("burnt") then
            if recipename == "table_winters_feast" then
                inst.helper = CreatePlacerRing()
                inst.helper.parent = inst
                inst.helper.entity:SetParent(inst.entity)
                if placerinst ~= nil and recipename == "table_winters_feast" then
                    inst.helper:AddComponent("updatelooper")
                    inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                    inst.helper.placerinst = placerinst
                    OnUpdatePlacerHelper(inst.helper)
                end
            end
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1.4) --recipe min_spacing/2

    MakeObstaclePhysics(inst, 1, 0.25)

	inst:AddTag("structure")

	--wintersfeasttable (from wintersfeasttable component) added to pristine state for optimization
	inst:AddTag("wintersfeasttable")

	inst.MiniMapEntity:SetIcon("table_winters_feast.png")

    inst.AnimState:SetBank ("table_winters_feast")
    inst.AnimState:SetBuild("table_winters_feast")
    inst.AnimState:PlayAnimation("idle")

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("table_winters_feast")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    --MakeSnowCoveredPristine(inst)
    inst.scrapbook_specialinfo = "TABLEWINTERSFEAST"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

	-- inst._eject_task = nil

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

    --MakeSnowCovered(inst)

	inst:AddComponent("wintersfeasttable")
	inst.components.wintersfeasttable.ondepletefoodfn = OnDepleteFood
	inst.components.wintersfeasttable.onfinishfoodfn = OnFinishFood

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1

	inst:AddComponent("shelf")
    inst.components.shelf:SetOnShelfItem(OnGetShelfItem)
    inst.components.shelf:SetOnTakeItem(OnLoseShelfItem)

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnItemGiven
	inst.components.trader.deleteitemonaccept = false

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_MEDIUM)
    inst.components.hauntable:SetOnHauntFn(onhaunt)

	MakeLargeBurnable(inst, nil, nil, true)
	MakeMediumPropagator(inst)

	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("onburnt", onburnt)
	inst:ListenForEvent("onignite", onignite)
	inst:ListenForEvent("onextinguish", onextinguish)
	inst:ListenForEvent("onremove", onremove)
	inst:ListenForEvent("ruffle", function()
			if not inst:HasTag("burnt") then
				inst.AnimState:PlayAnimation("ruffle")
                inst.AnimState:PushAnimation("idle")
                inst.SoundEmitter:PlaySound(sounds.ruffle)
            end
        end)

	inst.OnSave = OnSave
	inst.OnLoadPostPass = OnLoadPostPass

	inst:DoTaskInTime(0,function()
		if TheWorld.components.feasts and not inst:HasTag("burnt") then
			TheWorld.components.feasts:RegisterTable(inst)
		end
	end)

    return inst
end

local function placer_postinit_fn(inst)
	inst.AnimState:Hide("inner")

	--

    local inner = CreateEntity()

    --[[Non-networked entity]]
    inner.entity:SetCanSleep(false)
    inner.persists = false

    inner.entity:AddTransform()
    inner.entity:AddAnimState()

    inner:AddTag("CLASSIFIED")
    inner:AddTag("NOCLICK")
    inner:AddTag("placer")

    inner.AnimState:SetBank("winona_battery_placement")
    inner.AnimState:SetBuild("winona_battery_placement")
    inner.AnimState:PlayAnimation("idle")
    inner.AnimState:SetLightOverride(1)
	inner.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inner.AnimState:Hide("outer")

    inner.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(inner)

	--local recipe = AllRecipes.table_winters_feast
	local inner_radius_scale = PLACER_SCALE --recipe ~= nil and recipe.min_spacing ~= nil and (recipe.min_spacing / 2.2) or 1 -- roughly lines up size of animation with blocking radius
    inner.AnimState:SetScale(inner_radius_scale, inner_radius_scale)

	--

	local outer_radius_scale = (TUNING.WINTERSFEASTTABLE.TABLE_RANGE + 1.4 ) / 4.5 -- roughly lines up size of animation with feast radius
    inst.AnimState:SetScale(outer_radius_scale, outer_radius_scale)

	--

    local placer2 = CreateEntity()

    --[[Non-networked entity]]
    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    placer2.AnimState:SetBank("table_winters_feast")
    placer2.AnimState:SetBuild("table_winters_feast")
    placer2.AnimState:PlayAnimation("idle")
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)
end

return Prefab("table_winters_feast", fn, assets, prefabs),
	MakePlacer("table_winters_feast_placer", "winona_battery_placement", "winona_battery_placement", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn)