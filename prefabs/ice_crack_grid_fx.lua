local assets =
{
    Asset("ANIM", "anim/gridicecrack.zip"),
}

local prefabs =
{

}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("gridicecrack")
    inst.AnimState:SetBank("gridplacer")
    inst.AnimState:PlayAnimation(math.random() < 0.5 and "left" or "right")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)    

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("FX")
    inst:AddTag("ice_crack_fx")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab( "ice_crack_grid_fx", fn, assets, prefabs )