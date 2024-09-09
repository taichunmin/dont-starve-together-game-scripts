local assets =
{
    Asset("ANIM", "anim/boat_pointer_small.zip"),
}

local function OnEntityReplicated(inst)
    local parent = inst.entity:GetParent()

    if parent ~= nil and parent:HasTag("mast") then
        if parent.highlightchildren ~= nil then
            table.insert(parent.highlightchildren, inst)
        else
            parent.highlightchildren = { inst }
        end
    end
end

local function CLIENT_OnRemoveEntity(inst)
    local parent = inst.entity:GetParent()

    if parent ~= nil and parent.highlightchildren ~= nil then
        table.removearrayvalue(parent.highlightchildren, inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boatpointer_small")
    inst.AnimState:SetBuild("boat_pointer_small")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_BOAT)
    inst.AnimState:SetFinalOffset(2)

    inst:AddTag("NOBLOCK")
    inst:AddTag("DECOR")

    inst.Transform:SetRotation(90)

    inst.OnRemoveEntity = CLIENT_OnRemoveEntity

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated

        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("rudder", fn, assets)
