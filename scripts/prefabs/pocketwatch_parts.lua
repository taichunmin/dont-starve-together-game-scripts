local assets =
{
    Asset("ANIM", "anim/pocketwatch_parts.zip"),
}

local function beat(inst)
    inst.AnimState:PlayAnimation("idle2")
    inst.AnimState:PushAnimation("idle1", false)
    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/pocketwatch_parts/idle2")

    inst.beattask = inst:DoTaskInTime(4 + math.random() * 5, beat)
end

local function ondropped(inst)
    if inst.beattask ~= nil then
        inst.beattask:Cancel()
    end
	if not inst:IsInLimbo() and inst.entity:IsAwake() then
		if not inst.SoundEmitter:PlayingSound("loop") then
			inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/pocketwatch_parts/idle1_LP", "loop")
		end
		inst.beattask = inst:DoTaskInTime(.75 + math.random() * .75, beat)
	end
end

local function onpickup(inst)
    if inst.beattask ~= nil then
        inst.beattask:Cancel()
        inst.beattask = nil
    end
    inst.SoundEmitter:KillSound("loop")
end

local function OnEntityWake(inst)
	ondropped(inst)
end

local function OnEntitySleep(inst)
    if inst.beattask ~= nil then
        inst.beattask:Cancel()
    end

    inst.SoundEmitter:KillSound("loop")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("pocketwatch_parts")
    inst.AnimState:SetBuild("pocketwatch_parts")
    inst.AnimState:PlayAnimation("idle1")

    inst:AddTag("molebait")
	inst:AddTag("cattoy")

	MakeInventoryFloatable(inst, "small", 0.25, { 1.24, 1, 1.24 })

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("bait")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(onpickup)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    MakeHauntableLaunch(inst)

    inst.beattask = nil
    ondropped(inst)

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep

    return inst
end

return Prefab("pocketwatch_parts", fn, assets)
