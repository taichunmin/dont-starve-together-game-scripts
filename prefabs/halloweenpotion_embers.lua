
local PotionCommon = require "prefabs/halloweenpotion_common"

local potion_tunings =
{
	sparks =
	{
		BUILD = "halloween_embers",
		ANIMS = {"sparks_sml", "sparks_med", "sparks_lrg"},
		SOUND = "dontstarve/halloween_2018/madscience_machine/sparks",
		SOUND_NAME = "sparks_fx_loop",
	},
	embers =
	{
		BUILD = "halloween_embers",
		ANIMS = {"bouncy_sml", "bouncy_med", "bouncy_lrg"},
		PRE_ANIM = true,
		SOUND = "dontstarve/halloween_2018/madscience_machine/embers",
		SOUND_NAME = "embers_fx_loop",
	},
}

local puff_fx = {"halloween_firepuff_1", "halloween_firepuff_2", "halloween_firepuff_3", }
local puff_fx_cold = {"halloween_firepuff_cold_1", "halloween_firepuff_cold_2", "halloween_firepuff_cold_3", }

local function potion_onputinfire(inst, target)
	if target:HasTag("campfire") then
		target:AddDebuff(inst.buff_prefab, inst.buff_prefab)
		PotionCommon.SpawnPuffFx(inst, target)
	end
end

local function potion_fn(anim, buff_prefab)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("halloween_potions")
    inst.AnimState:SetBuild("halloween_potions")
    inst.AnimState:PlayAnimation(anim)
    inst.scrapbook_anim = anim

    MakeInventoryFloatable(inst, "small", 0.15, 0.65)

    inst.scrapbook_specialinfo = "HALLOWEENPOTIONFIRE"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.buff_prefab = buff_prefab

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "HALLOWEENPOTION_FIRE_FX"

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    MakeHauntableLaunch(inst)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
	inst.components.fuel.ontaken = potion_onputinfire

    return inst
end

local function buff_OnLevelChanged(inst, target, level_data)
	local fuel_level = 0
	local prev_fuel_level = 0
	if target.components.fueled ~= nil and not target.components.fueled:IsEmpty() then
		fuel_level = math.max(1, math.min((level_data ~= nil and level_data.newsection or target.components.fueled:GetCurrentSection()) - 1, #inst.potion_tunings.ANIMS))
		prev_fuel_level = math.max(1, math.min((level_data ~= nil and level_data.oldsection or 0) - 1, #inst.potion_tunings.ANIMS))
	end

    if fuel_level > 0 then
		inst.SoundEmitter:SetParameter(inst.potion_tunings.SOUND_NAME, "intensity", fuel_level / #inst.potion_tunings.ANIMS)

		if level_data ~= nil then
			if fuel_level ~= prev_fuel_level then
				if inst.potion_tunings.PRE_ANIM then
					inst.AnimState:PushAnimation(inst.potion_tunings.ANIMS[prev_fuel_level].."_pst", false)
					inst.AnimState:PushAnimation(inst.potion_tunings.ANIMS[fuel_level].."_pre", false)
					inst.AnimState:PushAnimation(inst.potion_tunings.ANIMS[fuel_level].."_loop", true)
				else
					inst.AnimState:PushAnimation(inst.potion_tunings.ANIMS[fuel_level], true)
				end
			end
		else
			if inst.potion_tunings.PRE_ANIM then
				inst.AnimState:PlayAnimation(inst.potion_tunings.ANIMS[fuel_level].."_pre")
				inst.AnimState:PushAnimation(inst.potion_tunings.ANIMS[fuel_level].."_loop", true)
			else
				inst.AnimState:PlayAnimation(inst.potion_tunings.ANIMS[fuel_level], true)
			end
		end
    else
        inst.components.debuff:Stop()
    end
end

local function anim_buff_OnDetached(inst, target)
	inst.SoundEmitter:KillSound(inst.potion_tunings.SOUND_NAME)
	if target.components.fueled ~= nil then
	    target.components.fueled.rate_modifiers:RemoveModifier(inst.prefab)
	end
	ErodeAway(inst, 0.5)
end

local function buff_OnTimerDone(inst, data)
    if data.name == "buffover" then
        inst.components.debuff:Stop()
    end
end

local function buff_OnExtended(inst, target)
    inst.components.timer:StopTimer("buffover")
    inst.components.timer:StartTimer("buffover", TUNING.HALLOWEENPOTION_FIREFX_DURATION)
end

local function buff_OnAttached(inst, target)
	PotionCommon.AttachToTarget(inst, target, inst.potion_tunings.BUILD, inst.potion_tunings.BUILD .. "_cold")

	if target:HasTag("blueflame") then
		inst.AnimState:SetBuild(inst.potion_tunings.BUILD .. "_cold")
		inst.AnimState:SetBank(inst.potion_tunings.BUILD .. "_cold")
	end

	if target.components.fueled ~= nil then
	    target.components.fueled.rate_modifiers:SetModifier(inst.prefab, TUNING.HALLOWEENPOTION_FIREFX_FUEL_MOD)
	end

	inst.SoundEmitter:PlaySound(inst.potion_tunings.SOUND, inst.potion_tunings.SOUND_NAME)
	inst.SoundEmitter:SetParameter(inst.potion_tunings.SOUND_NAME, "intensity", 0)

	buff_OnLevelChanged(inst, target)
    inst:ListenForEvent("onextinguish", function()
        inst.components.debuff:Stop()
    end, target)
	inst:ListenForEvent("onfueldsectionchanged", function(t, data)
		buff_OnLevelChanged(inst, target, data)
	end, target)
end

local function anim_buff_fn(potion_tunings)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank(potion_tunings.BUILD)
    inst.AnimState:SetBuild(potion_tunings.BUILD)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:Hide("burst")
	inst.AnimState:SetFinalOffset(3)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

	inst.potion_tunings = potion_tunings

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(buff_OnAttached)
    inst.components.debuff:SetDetachedFn(anim_buff_OnDetached)
    inst.components.debuff:SetExtendedFn(buff_OnExtended)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("buffover", TUNING.HALLOWEENPOTION_FIREFX_DURATION)
    inst:ListenForEvent("timerdone", buff_OnTimerDone)

    return inst
end

local function AddPotion(potions, name, art)
	local potion_name = "halloweenpotion_"..name
	local buff_name = potion_name.."_buff"

	local potion_assets = JoinArrays(PotionCommon.assets, {Asset("ANIM", "anim/halloween_potions.zip")})
	local potion_prefabs = JoinArrays(PotionCommon.prefabs, {buff_name})

	local buff_assets =
	{
		Asset("ANIM", "anim/halloween_embers.zip"),
		Asset("ANIM", "anim/halloween_embers_cold.zip"),
		Asset("SCRIPT", "scripts/prefabs/halloweenpotion_common.lua"),
	}

	local function _buff_fn() return anim_buff_fn(potion_tunings[name]) end
	local function _potion_fn() return potion_fn(name, buff_name) end

	table.insert(potions, Prefab(potion_name, _potion_fn, potion_assets, potion_prefabs))
	table.insert(potions, Prefab(buff_name, _buff_fn, buff_assets))
end

local potions = {}
AddPotion(potions, "embers")
AddPotion(potions, "sparks")

return unpack(potions)
