local assets =
{
    Asset("ANIM", "anim/structure_collapse_fx.zip"),
}

local MATERIAL_NAMES =
{
    "wood",
    "metal",
    "rock",
    "stone",
    "straw",
    "pot",
    "none",
}
local MATERIALS = table.invert(MATERIAL_NAMES)

local MATERIAL_SOUND_MAP =
{
    ["rock"] = "dontstarve/wilson/rock_break",
    --default: "dontstarve/common/destroy_"..material
}

local function playfx(proxy, anim)
    local inst = CreateEntity()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("collapse")
    inst.AnimState:SetBuild("structure_collapse_fx")
    inst.AnimState:PlayAnimation(anim)

    local material = MATERIAL_NAMES[proxy.material:value()]
    if material ~= "none" then
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke")

        if material ~= nil then
            inst.SoundEmitter:PlaySound(MATERIAL_SOUND_MAP[material] or ("dontstarve/common/destroy_"..material))
        end
    end

    inst:ListenForEvent("animover", inst.Remove)
end

local function SetMaterial(inst, material)
    inst.material:set(MATERIALS[material] or 0)
end

local function makefn(anim)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("NOCLICK")
        inst:AddTag("FX")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            inst:DoTaskInTime(0, playfx, anim)
        end

        inst.material = net_tinybyte(inst.GUID, "collapse_fx.material")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.SetMaterial = SetMaterial

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end
end

return Prefab("collapse_big", makefn("collapse_large"), assets),
    Prefab("collapse_small", makefn("collapse_small"), assets)
