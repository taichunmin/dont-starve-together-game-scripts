local assets =
{
    Asset("ANIM", "anim/mushroom_tree_webbed.zip"),
    Asset("MINIMAP_IMAGE", "mushroom_tree_webbed"),
}

local prefabs =
{
    "log",
    "blue_cap",
    "charcoal",
    "ash",
    "silk",
    "mushtree_tall_webbed_burntfx",
}

SetSharedLootTable('mushtree_tall_webbed',
{
    { "log", 1.0 },
    { "silk", 1.0 },
    { "silk", 0.3 },
    { "silk", 0.3 },
})

local function tree_burnt(inst)
    inst.components.lootdropper:SpawnLootPrefab("ash")
    if math.random() < .5 then
        inst.components.lootdropper:SpawnLootPrefab("charcoal")
    end
    SpawnPrefab("mushtree_tall_webbed_burntfx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local SPIDERDEN_TAGS = { "spiderden" }
local function workcallback(inst, worker, workleft)
    if not (worker ~= nil and worker:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_mushroom")
    end

    local pos = inst:GetPosition()
    for i, den in ipairs(TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.MUSHTREE_WEBBED_SPIDER_RADIUS, SPIDERDEN_TAGS)) do
        den:PushEvent("creepactivate", { target = worker })
    end
    if workleft <= 0 then
        inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")

        inst.AnimState:PlayAnimation("fall")

        inst.components.lootdropper:DropLoot(pos)
        inst:ListenForEvent("animover", inst.Remove)
    else
        inst.AnimState:PlayAnimation("chop")
        inst.AnimState:PushAnimation("idle_loop", true)
    end
end

local function onsave(inst, data)
    data.burnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or nil
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        tree_burnt(inst)
    end
end

local function burntfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("mushroom_tree_webbed")
    inst.AnimState:SetBank("mushroom_tree_webbed")
    inst.AnimState:PlayAnimation("chop_burnt")

    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    -- In case we're off screen and animation is asleep
    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .25)

    inst.AnimState:SetBuild("mushroom_tree_webbed")
    inst.AnimState:SetBank("mushroom_tree_webbed")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.MiniMapEntity:SetIcon("mushroom_tree_webbed.png")

    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(.8)
    inst.Light:SetColour(111/255, 111/255, 227/255)

    inst:AddTag("shelter")
    inst:AddTag("mushtree")
    inst:AddTag("webbed")
    inst:AddTag("cavedweller")
    inst:AddTag("plant")
    inst:AddTag("tree")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local color = .5 + math.random() * .5
    inst.AnimState:SetMultColour(color, color, color, 1)
    inst.AnimState:SetTime(math.random() * 2)

    MakeMediumPropagator(inst)
    MakeLargeBurnable(inst)
    inst.components.burnable:SetFXLevel(5)
    inst.components.burnable:SetOnBurntFn(tree_burnt)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("mushtree_tall_webbed")

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetWorkLeft(math.ceil(TUNING.MUSHTREE_CHOPS_TALL * .5))
    inst.components.workable:SetOnWorkCallback(workcallback)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("mushtree_tall_webbed", fn, assets, prefabs),
    Prefab("mushtree_tall_webbed_burntfx", burntfxfn, assets)
