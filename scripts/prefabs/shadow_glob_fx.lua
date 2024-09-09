local assets =
{
	Asset("ANIM", "anim/cane_shadow_fx.zip"),
	Asset("ANIM", "anim/splash_weregoose_fx.zip"),
	Asset("ANIM", "anim/splash_water_drop.zip"),
}

local NUM_VARIATIONS = 3
local MIN_SCALE = 1
local MAX_SCALE = 1.8
local PERIOD = 28 * FRAMES --ripple anim length minus blank frames at end

local function CreateRipple()
	local inst = CreateEntity()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("splash_weregoose_fx")
	inst.AnimState:SetBuild("splash_water_drop")
	inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
	inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)

	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

local function DoRipple(inst, scale, fx)
	local frame = inst.AnimState:GetCurrentAnimationFrame()
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
		if fx == nil or not fx:IsValid() then
			fx = CreateRipple()
		end
		fx.Transform:SetPosition(x, 0, z)
		fx.AnimState:SetScale(scale, scale)
		fx.AnimState:PlayAnimation(math.random() < .5 and "no_splash" or "no_splash2")
		if frame < PERIOD then
			fx.AnimState:SetFrame(frame)
		end
	end
	if frame < PERIOD then
		inst._ripple_task = inst:DoTaskInTime((PERIOD - frame) * FRAMES, DoRipple, .6, fx)
	end
end

local function OnRippleEnabled(inst)
	if inst._ripple_enabled:value() then
		if inst._ripple_task == nil then
			inst._ripple_task = inst:DoTaskInTime(0, DoRipple, .75)
		end
	elseif inst._ripple_task ~= nil then
		inst._ripple_task:Cancel()
		inst._ripple_task = nil
	end
end

local function EnableRipples(inst, enable)
	inst._ripple_enabled:set(enable ~= false)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("shadowtrail")

	inst.AnimState:SetBank("cane_shadow_fx")
	inst.AnimState:SetBuild("cane_shadow_fx")
	inst.AnimState:PlayAnimation("shad1")
	inst.AnimState:SetMultColour(1, 1, 1, .5)

	inst._ripple_enabled = net_bool(inst.GUID, "shadow_glob_fx._ripple_enabled", "ripple_enabled_dirty")

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		inst:ListenForEvent("ripple_enabled_dirty", OnRippleEnabled)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	local rnd = math.random(NUM_VARIATIONS)
	if rnd ~= 1 then
		inst.AnimState:PlayAnimation("shad"..tostring(rnd))
	end
	local scale = MIN_SCALE + math.random() * (MAX_SCALE - MIN_SCALE)
	rnd = math.random()
	if rnd < .5 or scale ~= 1 then
		inst.AnimState:SetScale(rnd < .5 and -scale or scale, scale, scale)
	end

	inst:ListenForEvent("animover", inst.Remove)
	inst.persists = false

	inst.EnableRipples = EnableRipples

	return inst
end

return Prefab("shadow_glob_fx", fn, assets)
