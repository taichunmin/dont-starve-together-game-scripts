require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/carnival_prizebooth.zip"),
}

local kit_assets =
{
    Asset("ANIM", "anim/carnival_prizebooth.zip"),
}

local prefabs =
{
    "carnival_prizebooth_kit",
}

local function onturnoff(inst)
    inst.Light:Enable(false)
	inst.AnimState:SetLightOverride(0)
    inst.AnimState:PlayAnimation("idle", false)
    inst.SoundEmitter:KillSound("loop_sound")
end

local function onturnon(inst)
    inst.Light:Enable(true)
	inst.AnimState:SetLightOverride(0.8)

    if inst.AnimState:IsCurrentAnimation("proximity_loop") or
        inst.AnimState:IsCurrentAnimation("place") or
        inst.AnimState:IsCurrentAnimation("use") then
        --NOTE: push again even if already playing, in case an idle was also pushed
        inst.AnimState:PushAnimation("proximity_loop", true)
        if not inst.SoundEmitter:PlayingSound("loop_sound") then
            inst.SoundEmitter:PlaySound("summerevent/prizebooth/prox_LP", "loop_sound")
        end
    else
        inst.AnimState:PlayAnimation("proximity_loop", true)
        if not inst.SoundEmitter:PlayingSound("loop_sound") then
            inst.SoundEmitter:PlaySound("summerevent/prizebooth/prox_LP", "loop_sound")
        end
    end
end

local function onactivate(inst)
    inst.AnimState:PlayAnimation("use")
    inst.AnimState:PushAnimation("proximity_loop", true)
    inst.SoundEmitter:PlaySound("summerevent/prizebooth/use")
end

local function onhammered(inst, worker)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst.components.lootdropper:DropLoot()

    inst:Remove()
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("summerevent/prizebooth/place")
end

local function UpdateGameMusic(inst)
	if ThePlayer ~= nil and ThePlayer:IsValid() and ThePlayer:IsNear(inst, TUNING.CARNIVAL_THEME_MUSIC_RANGE) then
		ThePlayer:PushEvent("playcarnivalmusic", false)
	end
end

local function OnEntityWake(inst)
	if not TheNet:IsDedicated() then
		inst._musiccheck = inst:DoPeriodicTask(1, UpdateGameMusic)
	end
end

local function OnEntitySleep(inst)
	if inst._musiccheck ~= nil then
		inst._musiccheck:Cancel()
		inst._musiccheck = nil
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.Light:Enable(false)
    inst.Light:SetRadius(4)
    inst.Light:SetIntensity(0.55)
    inst.Light:SetFalloff(1.3)
    inst.Light:SetColour(251/255, 240/255, 218/255)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("carnival_prizebooth.png")

    inst.AnimState:SetBank("carnival_prizebooth")
    inst.AnimState:SetBuild("carnival_prizebooth")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("carnival_prizebooth")
	inst:AddTag("carnivaldecor")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	inst:AddComponent("carnivaldecor")
	inst:AddComponent("lootdropper")

    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.onactivate = onactivate
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.CARNIVAL_PRIZESHOP

    inst:ListenForEvent("onbuilt", onbuilt)

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(onhammered)

    MakeSnowCovered(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep

    return inst
end

local deployable_data =
{
	deploymode = DEPLOYMODE.CUSTOM,
	custom_candeploy_fn = function(inst, pt, mouseover, deployer)
		local x, y, z = pt:Get()
		return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and TheWorld.Map:IsAboveGroundAtPoint(x, y, z, false)
	end,
}

local function placer_postinit_fn(inst)
	inst.deployhelper_key = "carnival_plaza_decor"
end

return Prefab("carnival_prizebooth", fn, assets, prefabs),
    MakeDeployableKitItem("carnival_prizebooth_kit", "carnival_prizebooth", "carnival_prizebooth", "carnival_prizebooth", "kit_item", kit_assets, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.MED_FUEL}, deployable_data),
	MakePlacer("carnival_prizebooth_kit_placer", "carnival_prizebooth", "carnival_prizebooth", "idle", nil, nil, nil, nil, nil, nil, placer_postinit_fn)
