
local assets =
{
	Asset("ANIM", "anim/carnivaldecor_lamp.zip"),
}

local NUM_SHAPES = 6

local function onhammered(inst, worker)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function LightOff(inst)
	inst.Light:Enable(false)

    inst.AnimState:PlayAnimation("idle"..(inst.shape or 1).."_off")

	if inst.components.activatable ~= nil then
		inst.components.activatable.inactive = true
	end

	inst.turnofftask = nil
end

local function LightOn(inst)
	inst.Light:Enable(true)
	inst.SoundEmitter:PlaySound("summerevent/lamp/turn_on")

    inst.AnimState:PlayAnimation("idle"..inst.shape.."_on", true)
	if inst.components.activatable ~= nil then
		inst.components.activatable.inactive = false
	end
end

local function EnableLight(inst, duration)
	LightOn(inst)
	--inst.SoundEmitter:PlaySound("summerevent/lamp/turn_on")

	if inst.turnofftask ~= nil then
		inst.turnofftask:Cancel()
	end
	inst.turnofftask = inst:DoTaskInTime(duration, LightOff)
end

local function OnActivate(inst, doer)
	EnableLight(inst, TUNING.CARNIVALDECOR_LAMP_ACTIVATE_TIME)

	return true
end

local function OnAcceptItem(inst, doer)
	EnableLight(inst, TUNING.CARNIVALDECOR_LAMP_TOKEN_TIME)
	return true
end

local function AbleToAcceptTest(inst, item, giver)
	if not inst:HasTag("inactive") then
		--return false
	end

	if item.prefab == "carnival_gametoken" then
		return true
	end
	return false, "CARNIVALGAME_INVALID_ITEM"
end

local function onsave(inst, data)
    data.shape = inst.shape
end

local function onload(inst, data)
	if data ~= nil and data.shape ~= nil and data.shape ~= inst.shape then
		inst.shape = data.shape
	    inst.AnimState:PlayAnimation("idle"..inst.shape.."_off")
	end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place"..inst.shape)
    inst.AnimState:PushAnimation("idle"..inst.shape.."_off", false)
    inst.SoundEmitter:PlaySound("summerevent/lamp/place"..inst.shape)
end

local function fn(data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("carnivaldecor_lamp")
    inst.AnimState:SetBuild("carnivaldecor_lamp")
    inst.AnimState:PlayAnimation("idle1_off")

	inst.Light:SetFalloff(1)
	inst.Light:SetIntensity(0.6)
	inst.Light:SetRadius(2)
	inst.Light:SetColour(180/255, 195/255, 150/255)

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.LESS] / 2) --match kit item
	inst:SetPhysicsRadiusOverride(0.5)

	LightOff(inst)

	inst:AddTag("carnivaldecor")
	inst:AddTag("carnivallamp")
    inst:AddTag("structure")
    inst:AddTag("cattoyairborne")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.shape = math.random(NUM_SHAPES)
	if inst.shape ~= 1 then
	    inst.AnimState:PlayAnimation("idle"..inst.shape.."_off")
	end

    inst:AddComponent("inspectable")
	inst:AddComponent("lootdropper")

	inst:AddComponent("carnivaldecor")
	inst.components.carnivaldecor.value = 48


	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(onhammered)

	inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)
    inst.components.trader.onaccept = OnAcceptItem

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.quickaction = true

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

	inst.OnSave = onsave
	inst.OnLoad = onload

    inst:ListenForEvent("onbuilt", onbuilt)

	if data.master_postinit then
		data.master_postinit(inst)
	end

    return inst
end

local function placer_postinit_fn(inst)
	inst.deployhelper_key = "carnival_plaza_decor"
end

return Prefab("carnivaldecor_lamp", fn, assets),
		MakeDeployableKitItem("carnivaldecor_lamp_kit", "carnivaldecor_lamp", "carnivaldecor_lamp", "carnivaldecor_lamp", "kit_item", nil, {size = "small", scale = 1.1}, nil, {fuelvalue = TUNING.SMALL_FUEL}, { deployspacing = DEPLOYSPACING.LESS }, TUNING.STACK_SIZE_LARGEITEM),
		MakePlacer("carnivaldecor_lamp_kit_placer", "carnivaldecor_lamp", "carnivaldecor_lamp", "kit_item", nil, nil, nil, nil, nil, nil, placer_postinit_fn)
