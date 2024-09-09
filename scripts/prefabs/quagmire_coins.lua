local assets =
{
    Asset("ANIM", "anim/quagmire_coins.zip"),
}

local prefabs =
{
    "quagmire_coin_fx",
}

local function MakeCoin(id, hasfx)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("quagmire_coins")
        inst.AnimState:SetBuild("quagmire_coins")
        inst.AnimState:PlayAnimation("idle")
        if id > 1 then
            inst.AnimState:OverrideSymbol("coin01", "quagmire_coins", "coin0"..tostring(id))
            inst.AnimState:OverrideSymbol("coin_shad1", "quagmire_coins", "coin_shad"..tostring(id))
        end

        inst:AddTag("quagmire_coin")

        MakeInventoryPhysics(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_coins").master_postinit(inst, hasfx)

        return inst
    end

    return Prefab("quagmire_coin"..id, fn, assets, hasfx and prefabs or nil)
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("quagmire_coins")
    inst.AnimState:SetBuild("quagmire_coins")
    inst.AnimState:PlayAnimation("opal_loop", true)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_coins").master_postinit_fx(inst)

    return inst
end

return MakeCoin(1),
    MakeCoin(2),
    MakeCoin(3),
    MakeCoin(4, true),
    Prefab("quagmire_coin_fx", fxfn, assets)