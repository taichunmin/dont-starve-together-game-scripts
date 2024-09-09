require("prefabutil")

local assets =
{
	Asset("ANIM", "anim/lunar_forge.zip"),
	Asset("ANIM", "anim/lunarthrall_plant_front.zip"),
}

local prefabs =
{
	"collapse_small",
}

local kit_assets =
{
	Asset("ANIM", "anim/lunar_forge.zip"),
	Asset("INV_IMAGE", "lunar_forge_kit"),
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("stone")
	inst:Remove()
end

local function onhit(inst, worker)
	if inst.components.prototyper.on then
		inst.AnimState:PlayAnimation("hit_open")
		inst.AnimState:PushAnimation("proximity_loop", true)
	else
		inst.AnimState:PlayAnimation("hit_close")
		inst.AnimState:PushAnimation("idle", false)
	end
end

local function doonact(inst)
	if inst._activecount > 1 then
		inst._activecount = inst._activecount - 1
	else
		inst._activecount = 0
	end	
end

local function onturnon(inst)
	if inst._activetask == nil then
		if inst.AnimState:IsCurrentAnimation("proximity_loop") then
			--In case other animations were still in queue
			inst.AnimState:PlayAnimation("proximity_loop", true)
		elseif inst.AnimState:IsCurrentAnimation("use") then
			inst.AnimState:PlayAnimation("proximity_loop", true)
		else
			if inst.AnimState:IsCurrentAnimation("place") then
				inst.AnimState:PushAnimation("proximity_pre")
			else
				inst.AnimState:PlayAnimation("proximity_pre")
			end
			inst.AnimState:PushAnimation("proximity_loop", true)
		end		
	end
	if not inst.SoundEmitter:PlayingSound("loopsound") then
		inst.SoundEmitter:PlaySound("rifts/forge/proximity_lp","loopsound")
	end	
end

local function onturnoff(inst)
	if inst._activetask == nil then
		inst.AnimState:PushAnimation("proximity_pst")
		inst.AnimState:PushAnimation("idle", false)
		inst.SoundEmitter:PlaySound("rifts/forge/proximity_pst")	
	end
	inst.SoundEmitter:KillSound("loopsound")
end

local function doneact(inst)
	inst._activetask = nil
	if inst.components.prototyper.on then
		onturnon(inst)
	else
		onturnoff(inst)
	end
end

local function onactivate(inst)
	inst.AnimState:PlayAnimation("use")
	inst.SoundEmitter:PlaySound("rifts/forge/use")
	inst._activecount = inst._activecount + 1
	inst:DoTaskInTime(1.5, doonact)
	if inst._activetask ~= nil then
		inst._activetask:Cancel()
	end
	inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), doneact)
end

local function onbuilt(inst, data)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", false)
	inst.SoundEmitter:PlaySound("rifts/forge/place")
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --match kit item
	MakeObstaclePhysics(inst, .4)

	inst.MiniMapEntity:SetPriority(5)
	inst.MiniMapEntity:SetIcon("lunar_forge.png")

	inst.AnimState:SetBank("lunar_forge")
	inst.AnimState:SetBuild("lunar_forge")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:OverrideSymbol("fx_puff2", "lunarthrall_plant_front", "fx_puff2")
	inst.AnimState:SetSymbolBloom("fx_puff2")
	inst.AnimState:SetSymbolBloom("head_fx_big")
	inst.AnimState:SetSymbolBloom("glows")
	inst.AnimState:SetSymbolLightOverride("fx_puff2", .1)
	inst.AnimState:SetSymbolLightOverride("head_fx_big", .1)
	inst.AnimState:SetSymbolLightOverride("glows", .2)

	inst:AddTag("structure")
    inst:AddTag("lunar_forge")

	--prototyper (from prototyper component) added to pristine state for optimization
	inst:AddTag("prototyper")

	MakeSnowCoveredPristine(inst)

	inst.scrapbook_specialinfo = "LUNARFORGE"

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst._activecount = 0
	inst._activetask = nil

	inst:AddComponent("inspectable")
	inst:AddComponent("prototyper")
	inst.components.prototyper.onturnon = onturnon
	inst.components.prototyper.onturnoff = onturnoff
	inst.components.prototyper.onactivate = onactivate
	inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.LUNAR_FORGE

	inst:ListenForEvent("onbuilt", onbuilt)

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	MakeSnowCovered(inst)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	return inst
end

return Prefab("lunar_forge", fn, assets, prefabs),
	MakeDeployableKitItem("lunar_forge_kit", "lunar_forge", "lunar_forge", "lunar_forge", "kit", assets),
	MakePlacer("lunar_forge_kit_placer", "lunar_forge", "lunar_forge", "idle")
