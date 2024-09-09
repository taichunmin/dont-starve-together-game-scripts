local assets =
{
    Asset("ANIM", "anim/sparks.zip"),
}

--Not using proxy because this FX needs to be synced to other entities' anims
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("sparks")
    inst.AnimState:SetBuild("sparks")
    inst.AnimState:PlayAnimation("sparks_1")
    inst.AnimState:SetAddColour(1, 1, 0, 0)
	inst.AnimState:SetLightOverride(0.3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local rnd = math.random(3)
    if rnd > 1 then
        inst.AnimState:PlayAnimation("sparks_"..tostring(rnd))
    end

    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false

    return inst
end

return Prefab("winona_battery_sparks", fn, assets)
