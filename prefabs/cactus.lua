local assets =
{
    Asset("ANIM", "anim/cactus.zip"),
    Asset("ANIM", "anim/oasis_cactus.zip"),
    Asset("ANIM", "anim/cactus_flower.zip"),
}

local prefabs =
{
    "cactus_meat",
    "cactus_flower",
}

local function ontransplantfn(inst)
    inst.components.pickable:MakeEmpty()
end

local function onpickedfn(inst, picker)
    inst.Physics:SetActive(false)
    inst.AnimState:PlayAnimation(inst.has_flower and "picked_flower" or "picked")
    inst.AnimState:PushAnimation("empty", true)

    if picker ~= nil then
        if picker.components.combat ~= nil and not (picker.components.inventory ~= nil and picker.components.inventory:EquipHasTag("bramble_resistant")) then
            picker.components.combat:GetAttacked(inst, TUNING.CACTUS_DAMAGE)
            picker:PushEvent("thorns")
        end

        if inst.has_flower then
            -- You get a cactus flower, yay.
            local loot = SpawnPrefab("cactus_flower")
            loot.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
            if picker.components.inventory ~= nil then
                picker.components.inventory:GiveItem(loot, nil, inst:GetPosition())
            else
                local x, y, z = inst.Transform:GetWorldPosition()
                loot.components.inventoryitem:DoDropPhysics(x, y, z, true)
            end
        end
    end

    inst.has_flower = false
end

local function onregenfn(inst)
    if TheWorld.state.issummer then
        inst.AnimState:PlayAnimation("grow_flower")
        inst.AnimState:PushAnimation("idle_flower", true)
        inst.has_flower = true
    else
        inst.AnimState:PlayAnimation("grow")
        inst.AnimState:PushAnimation("idle", true)
        inst.has_flower = false
    end
    inst.Physics:SetActive(true)
end

local function makeemptyfn(inst)
    inst.Physics:SetActive(false)
    inst.AnimState:PlayAnimation("empty", true)
    inst.has_flower = false
end

local function OnEntityWake(inst)
    if inst.components.pickable ~= nil and inst.components.pickable.canbepicked then
        inst.has_flower = TheWorld.state.issummer
        inst.AnimState:PlayAnimation(inst.has_flower and "idle_flower" or "idle", true)
    else
        inst.AnimState:PlayAnimation("empty", true)
        inst.has_flower = false
    end
end

local function MakeCactus(name)
    local function cactusfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst.MiniMapEntity:SetIcon(name..".png")

        inst.AnimState:SetBuild(name)
        inst.AnimState:SetBank(name)
        inst.AnimState:PlayAnimation("idle", true)

        inst:AddTag("plant")
        inst:AddTag("thorny")

        MakeObstaclePhysics(inst, .3)

        inst:SetPrefabNameOverride("cactus")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.AnimState:SetTime(math.random() * 2)

        inst:AddComponent("pickable")
        inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"

        inst.components.pickable:SetUp("cactus_meat", TUNING.CACTUS_REGROW_TIME)
        inst.components.pickable.onregenfn = onregenfn
        inst.components.pickable.onpickedfn = onpickedfn
        inst.components.pickable.makeemptyfn = makeemptyfn
        inst.components.pickable.ontransplantfn = ontransplantfn

        inst:AddComponent("inspectable")

        MakeLargeBurnable(inst)
        MakeMediumPropagator(inst)

        inst.OnEntityWake = OnEntityWake

        MakeHauntableIgnite(inst)

        return inst
    end

    return Prefab(name, cactusfn, assets, prefabs)
end

local function cactusflowerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cactusflower")
    inst.AnimState:SetBuild("cactus_flower")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("edible")
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.sanityvalue = TUNING.SANITY_TINY
    inst.components.edible.foodtype = "VEGGIE"

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    return inst
end

return MakeCactus("cactus"),
    MakeCactus("oasis_cactus"),
    Prefab("cactus_flower", cactusflowerfn, assets)
