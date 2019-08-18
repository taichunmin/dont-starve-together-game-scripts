local assets =
{

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
    inst.entity:AddDynamicShadow()

    inst.entity:SetPristine()    

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("groundshadow", fn, assets, prefabs)

