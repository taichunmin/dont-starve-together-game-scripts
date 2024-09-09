require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/sculpting_station.zip"),
    Asset("MINIMAP_IMAGE", "sculpting_station"),
}

local prefabs =
{
    "collapse_small",
    "sketch",
}

local sculptable_materials =
{
    marble      = {swapfile="marble",       symbol="marble01",      material = "marble"},
    cutstone    = {swapfile="cutstone",     symbol="cutstone01",    material = "stone"},
    moonglass   = {swapfile="moonglass",    symbol="moonglass01",   material = "moonglass"},
}

local function AddSketch(inst, sketch)
    inst.components.craftingstation:LearnItem(sketch:GetSpecificSketchPrefab(), sketch:GetRecipeName())
    inst.AnimState:PlayAnimation("hit")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/moonstaff_place")

    if inst.components.prototyper.on then
        inst.AnimState:PushAnimation("proximity_loop", true)
    else
        inst.AnimState:PushAnimation("idle", false)
    end
end

local function CalcSymbolFile(itemname)
    return sculptable_materials[itemname] ~= nil and sculptable_materials[itemname].swapfile or ("swap_"..itemname)
end

local function CalcItemSymbol(itemname)
    return sculptable_materials[itemname] ~= nil and sculptable_materials[itemname].symbol or "swap_body"
end

local function CalcSculptingSymbol(itemname)
    return sculptable_materials[itemname] ~= nil and "cutstone01" or "swap_body"
end

local function CalcSculptingTech(itemname)
    return sculptable_materials[itemname] ~= nil and TECH.SCULPTING_TWO.SCULPTING or TECH.SCULPTING_ONE.SCULPTING
end

local function dropitems(inst)
    if inst.components.pickable.caninteractwith then
        inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
    end

    for i,k in ipairs(inst.components.craftingstation:GetItems()) do
        inst.components.lootdropper:SpawnLootPrefab(k)
    end
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    dropitems(inst)

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        if inst.components.prototyper.on then
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PushAnimation("idle", false)
        end
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/sculpting_table/craft")
end

local function onitemtaken(inst, picker, loot)
    if inst.components.pickable.caninteractwith then
        inst.components.pickable.caninteractwith = false
        inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/moonstaff_place")
    end

    if loot ~= nil and picker ~= nil and sculptable_materials[loot.prefab] == nil then
        picker.components.inventory:Equip(loot)
    end

    inst.AnimState:ClearOverrideSymbol("cutstone01")
    inst.AnimState:ClearOverrideSymbol("swap_body")

    inst.components.prototyper.trees.SCULPTING = CalcSculptingTech("")

    inst:RemoveTag("chess_moonevent")
end

local function giveitem(inst, itemname)
    inst.components.pickable:SetUp(itemname, 1000000)
    inst.components.pickable:Pause()
    if not inst.components.pickable.caninteractwith then
        inst.components.pickable.caninteractwith = true
        inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/moonstaff_place")
    end

    inst.AnimState:ClearOverrideSymbol("cutstone01")
    inst.AnimState:ClearOverrideSymbol("swap_body")
    inst.AnimState:OverrideSymbol(CalcSculptingSymbol(itemname), CalcSymbolFile(itemname), CalcItemSymbol(itemname))

    inst.components.prototyper.trees.SCULPTING = CalcSculptingTech(itemname)

    if string.find(inst.components.pickable.product, "rook")
        or string.find(inst.components.pickable.product, "bishop")
        or string.find(inst.components.pickable.product, "knight") then

        inst:AddTag("chess_moonevent")
    end
end

local function ongivenitem(inst, giver, item)
    if item:HasTag("sketch") then
        AddSketch(inst, item)
    else
        giveitem(inst, item.prefab)
    end
end

local function abletoaccepttest(inst, item)
    if item:HasTag("sketch") then
        if inst.components.craftingstation:KnowsItem(item:GetSpecificSketchPrefab()) then
            return false, "DUPLICATE"
        end

        return true
    end

    if inst.components.pickable.caninteractwith then
        return false, "SLOTFULL"
    end

    for k,v in pairs(sculptable_materials) do
        if k == item.prefab then
            return true
        end
    end
    return false, "NOTSCULPTABLE"
end

local function onignite(inst)
    if inst.components.trader ~= nil then
        inst.components.trader:Disable()
    end
    DefaultBurnFn(inst)
end

local function onextinguish(inst)
    if inst.components.trader ~= nil then
        inst.components.trader:Enable()
    end
    DefaultExtinguishFn(inst)
end

local function onburnt(inst)
    if inst.components.pickable.caninteractwith then
        inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
        onitemtaken(inst)
    end

    for i,k in ipairs(inst.components.craftingstation:GetItems()) do
        inst.components.lootdropper:SpawnLootPrefab(k)
    end
    inst.components.craftingstation:ForgetAllItems()

    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end

    DefaultBurntStructureFn(inst)
end

local function onremoveingredients(inst, doer, recipename)
    onitemtaken(inst)
end

local function onturnon(inst)
    if not inst:HasTag("burnt") then
        if inst.AnimState:IsCurrentAnimation("proximity_loop") or
            inst.AnimState:IsCurrentAnimation("place") then
            --NOTE: push again even if already playing, in case an idle was also pushed
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PlayAnimation("proximity_loop", true)
        end

        inst.SoundEmitter:PlaySound("dontstarve/common/together/sculpting_table/proximity_LP", "loop")
    end
end

local function onturnoff(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:KillSound("loop")
    end
end

local function CreateItem(inst, item)
    local base_ingredient = inst.components.pickable.caninteractwith and inst.components.pickable.product or nil
    if base_ingredient ~= nil and sculptable_materials[base_ingredient] ~= nil then
        giveitem(inst, item.."_"..sculptable_materials[base_ingredient].material)

        local fx = SpawnPrefab("collapse_small")
        local x, y, z = inst.Transform:GetWorldPosition()
        fx.Transform:SetPosition(x, y + 1.2, z)
        fx:SetMaterial("stone")
    end
end

local function getstatus(inst)
    return inst:HasTag("burnt") and "BURNT"
            or (not inst.components.pickable.caninteractwith) and "EMPTY"
            or sculptable_materials[inst.components.pickable.product] ~= nil and "BLOCK"
            or "SCULPTURE"
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end

    data.itemname = inst.components.pickable.caninteractwith and inst.components.pickable.product or nil
end

local function onload(inst, data)
    if data ~= nil then
        if data.itemname then
            giveitem(inst, data.itemname)
        end

        if data.burnt then
            inst.components.burnable.onburnt(inst)
        end
    end
end

local function DoChessMoonEventKnockOff(inst)
    if inst:HasTag("chess_moonevent") and inst.components.pickable.caninteractwith then
        local chesspiece = inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
        onitemtaken(inst)
    end
end

local function CheckChessMoonEventKnockOff(inst)
    if TheWorld.state.isnewmoon then
        DoChessMoonEventKnockOff(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("sculpting_station.png")

    inst.AnimState:SetBank("sculpting_station")
    inst.AnimState:SetBuild("sculpting_station")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")

    --trader, alltrader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")
    inst:AddTag("alltrader")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("craftingstation")

    inst:AddComponent("prototyper")
    inst.components.prototyper.trees = deepcopy(TUNING.PROTOTYPER_TREES.SCULPTINGTABLE)
    inst.components.prototyper.trees.SCULPTING = CalcSculptingTech("")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff

    inst:AddComponent("pickable")
    inst.components.pickable.caninteractwith = false
    inst.components.pickable.onpickedfn = onitemtaken
    inst.components.pickable.paused = true

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(abletoaccepttest)
    inst.components.trader.acceptnontradable = true
    inst.components.trader.onaccept = ongivenitem

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    inst.components.burnable:SetOnIgniteFn(onignite)
    inst.components.burnable:SetOnExtinguishFn(onextinguish)

    MakeSnowCovered(inst)
    MakeMediumPropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst.CreateItem = CreateItem

    inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("ondeconstructstructure", dropitems)

    if not TheWorld:HasTag("cave") then
        inst.OnEntityWake = CheckChessMoonEventKnockOff
        inst.OnEntitySleep = CheckChessMoonEventKnockOff
        inst:WatchWorldState("isnewmoon", CheckChessMoonEventKnockOff)

        inst:ListenForEvent("shadowchessroar", DoChessMoonEventKnockOff)
    end

    return inst
end

return Prefab("sculptingtable", fn, assets, prefabs),
    MakePlacer("sculptingtable_placer", "sculpting_station", "sculpting_station", "idle")
