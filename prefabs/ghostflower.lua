local assets =
{
    Asset("ANIM", "anim/ghostflower.zip"),
}

local prefabs =
{
	"ghostflower_spirit1_fx",
	"ghostflower_spirit2_fx",
}

local function dofx(inst)
	if not inst.inlimbo then
		local fx = SpawnPrefab("ghostflower_spirit"..tostring(math.random(2)).."_fx")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

		inst:DoTaskInTime(3 + math.random() * 6, dofx) -- the min delay needs to be greater than the grow animation + it's delay
	end
end

local function DoGrow(inst)
	inst:Show()
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
end

local function DelayedGrow(inst)
	inst:Hide()
	inst:DoTaskInTime(0.25 + math.random() * 0.25, DoGrow)
end

local function toground(inst)
    inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())

	inst:DoTaskInTime(3 + math.random() * 6, dofx)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank("ghostflower")
    inst.AnimState:SetBuild("ghostflower")
    inst.AnimState:PlayAnimation("idle", true)

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:ListenForEvent("ondropped", toground)

	inst.DelayedGrow = DelayedGrow

	toground(inst)

    return inst
end

return Prefab("ghostflower", fn, assets, prefabs)
