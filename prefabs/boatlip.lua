local assets =
{
    Asset("ANIM", "anim/boat_test.zip"),
}

local prefabs =
{
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst:AddTag("DECOR")

    inst.AnimState:SetBank("boat_01")
    inst.AnimState:SetBuild("boat_test")
    inst.AnimState:PlayAnimation("lip", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGroundFixed)    
    inst.AnimState:SetLayer(LAYER_BACKGROUND)  
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_BOAT)
    inst.AnimState:SetFinalOffset(0)    
    inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)  

    inst.Transform:SetRotation(90)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
       
    inst.persists = false

    return inst
end

return Prefab("boatlip", fn, assets, prefabs)
