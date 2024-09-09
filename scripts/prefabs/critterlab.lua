local assets =
{
    Asset("ANIM", "anim/critterlab.zip"),
}

local function blink(inst)
    inst.AnimState:PlayAnimation("proximity_loop"..math.random(4))
	inst.idletask = inst:DoTaskInTime(math.random() + 1.0, blink)
end

local function onturnoff(inst)
	if inst.idletask ~= nil then
		inst.idletask:Cancel()
		inst.idletask = nil
	end
    inst.AnimState:PushAnimation("idle", false)
	inst.SoundEmitter:KillSound("loop")
end

local function onturnon(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/together/critter_lab/idle", "loop")
	blink(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("critterlab.png")

    inst.AnimState:SetBank("critterlab")
    inst.AnimState:SetBuild("critterlab")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("critterlab")
    inst:AddTag("antlion_sinkhole_blocker")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)
    inst.scrapbook_specialinfo = "CRITTERDEN"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.CRITTERLAB

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return Prefab("critterlab", fn, assets, prefabs)
