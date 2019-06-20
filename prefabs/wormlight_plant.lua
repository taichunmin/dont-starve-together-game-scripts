local assets =
{
    Asset("ANIM", "anim/worm.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "wormlight_lesser",
}

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("berry_idle", true)
    inst:DoTaskInTime(8*FRAMES, function()
        inst.Light:Enable(true)
    end)
end

local function makeemptyfn(inst)
    inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("picked")
    inst.Light:Enable(false)
end

local function onpickedfn(inst)
    inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("picked")
    inst.Light:Enable(false)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    --inst.MiniMapEntity:SetIcon("grass.png") -- no icon for these?

    inst.Transform:SetTwoFaced()

    inst:AddTag("plant")

    inst.AnimState:SetBank("worm")
    inst.AnimState:SetBuild("worm")
    inst.AnimState:PlayAnimation("berry_idle", true)

    inst.Light:SetRadius(1.5)
    inst.Light:SetIntensity(0.8)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetColour(1,1,1)
    inst.Light:Enable(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Transform:SetRotation(math.random()*360)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"

    inst.components.pickable:SetUp("wormlight_lesser", TUNING.WORMLIGHT_PLANT_REGROW_TIME)
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")

    ---------------------

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)
    MakeHauntableIgnite(inst)

    ---------------------

    return inst
end

return Prefab("wormlight_plant", fn, assets, prefabs)
