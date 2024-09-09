local dead_sea_bones_assets =
{
    Asset("ANIM", "anim/fishbones.zip"),
}

local prefabs =
{
    "boneshard",
    "collapse_small",
}

SetSharedLootTable( "dead_sea_bones_loot",
{
    {"boneshard",       1.00},
    {"boneshard",       1.00},
    {"boneshard",       0.50},
})

local function on_hammer(inst, worker, workleft, numworks)
    if workleft > 0 then
        local animnum_string = tostring(inst.animnum or 1)
        inst.AnimState:PlayAnimation("mine_"..animnum_string)
        inst.AnimState:PushAnimation("idle_"..animnum_string)
    end
end

local function on_hammering_finished(inst)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("rock")

    inst:Remove()
end

local function on_save(inst, data)
    data.animnum = inst.animnum
end

local function set_bones_type(inst, animnum)
    if inst.animnum == nil or (animnum ~= nil and inst.animnum ~= animnum) then
        inst.animnum = animnum or math.random(3)

        inst.AnimState:PlayAnimation("idle_"..tostring(inst.animnum))
    end
end

local function on_load(inst, data)
    set_bones_type(inst, data ~= nil and data.animnum or nil)
end

local function dead_sea_bones()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.25)

    inst.AnimState:SetBank("fishbones")
    inst.AnimState:SetBuild("fishbones")
    inst.AnimState:PlayAnimation("idle_1")

    inst.scrapbook_anim = "idle_1"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("dead_sea_bones_loot")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(TUNING.DEAD_SEA_BONES_HAMMERS)
    inst.components.workable:SetOnWorkCallback(on_hammer)
    inst.components.workable:SetOnFinishCallback(on_hammering_finished)

    inst:AddComponent("inspectable")

    MakeHauntableWork(inst)

    if not POPULATING then
        set_bones_type(inst, nil)
    end

    inst.OnSave = on_save
    inst.OnLoad = on_load

    return inst
end

return Prefab("dead_sea_bones", dead_sea_bones, dead_sea_bones_assets, prefabs)
