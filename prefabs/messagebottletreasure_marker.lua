local assets =
{
	Asset("MINIMAP_IMAGE", "messagebottletreasure_marker"),
}

-- local prefabs =
-- {
-- }

local function OnAdd(inst)
	TheWorld:PushEvent("messagebottletreasure_marker_added", inst)
end

local function OnRemove(inst)
	TheWorld:PushEvent("messagebottletreasure_marker_removed", inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst.MiniMapEntity:SetIcon("messagebottletreasure_marker.png")
	inst.MiniMapEntity:SetPriority(6)

	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
	end

	inst.persists = false

	inst:DoTaskInTime(0, OnAdd)

	inst:ListenForEvent("onremove", OnRemove)

    return inst
end

return Prefab("messagebottletreasure_marker", fn, assets--[[, prefabs]])