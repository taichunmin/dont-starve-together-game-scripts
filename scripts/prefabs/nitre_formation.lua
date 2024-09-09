local assets =
{
    Asset("ANIM", "anim/pond_nitrecrystal.zip"),
}

local function OnRemoveEntity(inst)
	if inst.pond ~= nil and inst.pond.highlightchildren ~= nil then
		table.removearrayvalue(inst.pond.highlightchildren, inst)
		if #inst.pond.highlightchildren <= 0 then
			inst.pond.highlightchildren = nil
		end
	end
end

local function OnEntityReplicated(inst)
	local parent = inst.entity:GetParent()
	if parent ~= nil and parent.prefab == "pond_cave" then
		if parent.highlightchildren == nil then
			parent.highlightchildren = { inst }
		else
			table.insert(parent.highlightchildren, inst)
		end

		inst.pond = parent
		inst.OnRemoveEntity = OnRemoveEntity
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("pond_rock")
    inst.AnimState:SetBuild("pond_nitrecrystal")
    inst.AnimState:PlayAnimation("idle1")
    inst.AnimState:SetScale(0.75, 0.75)

	inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		inst.OnEntityReplicated = OnEntityReplicated

        return inst
    end

    return inst
end

return Prefab("nitre_formation", fn, assets)
