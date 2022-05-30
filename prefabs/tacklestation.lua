local assets =
{
    Asset("ANIM", "anim/tackle_station.zip"),
    Asset("SOUND", "sound/together.fsb"),
}

local prefabs =
{
	"tacklesketch",
	"small_puff",
}

local sounds =
{
	onbuilt = "hookline/common/tackle_station/place",
	idle = "hookline/common/tackle_station/proximity_LP",
	learn = "hookline/common/tackle_station/recieive_item",
	use = "hookline/common/tackle_station/use",
}

local function DropTackleSketches(inst)
    for i,k in ipairs(inst.components.craftingstation:GetItems()) do
        inst.components.lootdropper:SpawnLootPrefab(k)
    end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
	inst.SoundEmitter:PlaySound(sounds.onbuilt)
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
    DropTackleSketches(inst)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        if inst.components.prototyper.on then
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PushAnimation("idle", false)
        end
    end
end

local function onturnon(inst)
    if inst._activetask == nil then
		inst:PushEvent("onturnon")
		inst.AnimState:PushAnimation("proximity_loop", true)
        if not inst.SoundEmitter:PlayingSound("idlesound") then
            inst.SoundEmitter:PlaySound(sounds.idle, "idlesound")
        end
    end
end

local function onturnoff(inst)
	if inst._activetask == nil then
		inst:PushEvent("onturnoff")

		inst.AnimState:PlayAnimation("idle", false)
		inst.SoundEmitter:KillSound("idlesound")
    end
end

local function doneact(inst)
    inst._activetask = nil
    if inst.components.prototyper.on then
        inst.AnimState:PlayAnimation("proximity_loop", true)
        if not inst.SoundEmitter:PlayingSound("idlesound") then
            inst.SoundEmitter:PlaySound(sounds.idle, "idlesound")
        end
    else
		inst.AnimState:PushAnimation("idle")
		inst.SoundEmitter:KillSound("idlesound")
    end
end

local function onuse(inst, hasfx)
    inst.AnimState:PlayAnimation("use")

    inst.SoundEmitter:PlaySound(sounds.use)
    if inst._activetask ~= nil then
        inst._activetask:Cancel()
    end
    inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), doneact)
end

local function onactivate(inst)
    onuse(inst, true)
end

local function onlearnednewtacklesketch(inst)
    inst.AnimState:PlayAnimation("receive_item")
    inst.SoundEmitter:PlaySound(sounds.learn)

    if inst.components.prototyper.on then
        inst.AnimState:PushAnimation("proximity_loop", true)
    else
        inst.AnimState:PushAnimation("idle", false)
    end
end

local function OnHaunt(inst, haunter)
    if not inst:HasTag("burnt") and inst.components.prototyper.on then
        onuse(inst, false)
    else
        Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
    end
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    return true
end

local function onburnt(inst)
	DropTackleSketches(inst)
    inst.components.craftingstation:ForgetAllItems()

    DefaultBurntStructureFn(inst)
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil then
        inst.components.burnable.onburnt(inst)
    end
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
	inst.MiniMapEntity:SetIcon("tacklestation.png")

    inst.AnimState:SetBank("tackle_station")
    inst.AnimState:SetBuild("tackle_station")
    inst.AnimState:PlayAnimation("idle")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

	inst:AddTag("structure")
	inst:AddTag("tacklestation")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._activetask = nil
    inst._soundtasks = {}

    inst:AddComponent("inspectable")

	inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("craftingstation")

    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.onactivate = onactivate
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.FISHING

    MakeLargeBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeLargePropagator(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

	inst:ListenForEvent("onlearnednewtacklesketch", onlearnednewtacklesketch)
	inst:ListenForEvent("onbuilt", onbuilt)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("tacklestation", fn, assets, prefabs),
	MakePlacer("tacklestation_placer", "tackle_station", "tackle_station", "idle")
