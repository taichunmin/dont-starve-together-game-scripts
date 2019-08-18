local assets =
{
    Asset("ANIM", "anim/boat_leak.zip"),
    Asset("ANIM", "anim/boat_leak_build.zip"),
}

local function onsprungleak(inst)
	if inst.components.inspectable == nil then
		inst:AddComponent("inspectable")
	end
end

local function onrepairedleak(inst)
	if inst.components.inspectable ~= nil then
		inst:RemoveComponent("inspectable")
	end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boat_leak")
    inst.AnimState:SetBuild("boat_leak_build")

    inst.entity:SetPristine()    

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("boatleak")
	inst.components.boatleak.onsprungleak = onsprungleak
	inst.components.boatleak.onrepairedleak = onrepairedleak

	inst:AddComponent("inspectable")

    return inst
end

return Prefab("boat_leak", fn, assets)