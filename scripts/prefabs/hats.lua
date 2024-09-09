local BALLOONS = require "prefabs/balloons_common"

local SPIDER_TAGS = {"spider"}

ALL_HAT_PREFAB_NAMES = {}

local function MakeHat(name)
    local fns = {}
    local fname = "hat_"..name
    local symname = name.."hat"
    local prefabname = symname

    --If you want to use generic_perish to do more, it's still
    --commented in all the relevant places below in this file.
    --[[local function generic_perish(inst)
        inst:Remove()
    end]]

    local swap_data = { bank = symname, anim = "anim" }

	-- do not pass this function to equippable:SetOnEquip as it has different a parameter listing
	local function _base_onequip(inst, owner, symbol_override, swap_hat_override)
		local skin_build = inst:GetSkinBuild()
		if skin_build ~= nil then
			owner:PushEvent("equipskinneditem", inst:GetSkinName())
			owner.AnimState:OverrideItemSkinSymbol(swap_hat_override or "swap_hat", skin_build, symbol_override or "swap_hat", inst.GUID, fname)
		else
			owner.AnimState:OverrideSymbol(swap_hat_override or "swap_hat", fname, symbol_override or "swap_hat")
		end

		if inst.components.fueled ~= nil then
			inst.components.fueled:StartConsuming()
		end

		if inst.skin_equip_sound and owner.SoundEmitter then
			owner.SoundEmitter:PlaySound(inst.skin_equip_sound)
		end
	end

	-- do not pass this function to equippable:SetOnEquip as it has different a parameter listing
    local function _onequip(inst, owner, symbol_override, headbase_hat_override)
		_base_onequip(inst, owner, symbol_override)

        owner.AnimState:ClearOverrideSymbol("headbase_hat") --clear out previous overrides
        if headbase_hat_override ~= nil then
            local skin_build = owner.AnimState:GetSkinBuild()
            if skin_build ~= "" then
                owner.AnimState:OverrideSkinSymbol("headbase_hat", skin_build, headbase_hat_override )
            else 
                local build = owner.AnimState:GetBuild()
                owner.AnimState:OverrideSymbol("headbase_hat", build, headbase_hat_override)
            end
        end

        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
			owner.AnimState:Show("HEAD_HAT_NOHELM")
			owner.AnimState:Hide("HEAD_HAT_HELM")
        end
    end

    local function _onunequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
        end

        owner.AnimState:ClearOverrideSymbol("headbase_hat") --it might have been overriden by _onequip
        if owner.components.skinner ~= nil then
            owner.components.skinner.base_change_cb = owner.old_base_change_cb
        end

        owner.AnimState:ClearOverrideSymbol("swap_hat")
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
			owner.AnimState:Hide("HEAD_HAT_NOHELM")
			owner.AnimState:Hide("HEAD_HAT_HELM")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    -- This is not really implemented, can just use _onequip
	fns.simple_onequip =  function(inst, owner, from_ground)
		_onequip(inst, owner)
	end

    -- This is not really implemented, can just use _onunequip
	fns.simple_onunequip = function(inst, owner, from_ground)
		_onunequip(inst, owner)
	end

    fns.opentop_onequip = function(inst, owner)
		_base_onequip(inst, owner)

        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
		owner.AnimState:Hide("HEAD_HAT_NOHELM")
		owner.AnimState:Hide("HEAD_HAT_HELM")
    end

	fns.fullhelm_onequip = function(inst, owner)
		if owner:HasTag("player") then
			_base_onequip(inst, owner, nil, "headbase_hat")

			owner.AnimState:Hide("HAT")
			owner.AnimState:Hide("HAIR_HAT")
			owner.AnimState:Hide("HAIR_NOHAT")
			owner.AnimState:Hide("HAIR")

			owner.AnimState:Hide("HEAD")
			owner.AnimState:Show("HEAD_HAT")
			owner.AnimState:Hide("HEAD_HAT_NOHELM")
			owner.AnimState:Show("HEAD_HAT_HELM")

			owner.AnimState:HideSymbol("face")
			owner.AnimState:HideSymbol("swap_face")
			owner.AnimState:HideSymbol("beard")
			owner.AnimState:HideSymbol("cheeks")

			owner.AnimState:UseHeadHatExchange(true)
		else
			_base_onequip(inst, owner)

			owner.AnimState:Show("HAT")
			owner.AnimState:Hide("HAIR_HAT")
			owner.AnimState:Hide("HAIR_NOHAT")
			owner.AnimState:Hide("HAIR")
		end
	end

	fns.fullhelm_onunequip = function(inst, owner)
		_onunequip(inst, owner)

		if owner:HasTag("player") then
			owner.AnimState:ShowSymbol("face")
			owner.AnimState:ShowSymbol("swap_face")
			owner.AnimState:ShowSymbol("beard")
			owner.AnimState:ShowSymbol("cheeks")

			owner.AnimState:UseHeadHatExchange(false)
		end
	end

    fns.simple_onequiptomodel = function(inst, owner, from_ground)
        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local _skinfns = { -- NOTES(JBK): These are useful for skins to have access to them instead of sometimes storing a reference to a hat.
        simple_onequip = fns.simple_onequip,
        simple_onunequip = fns.simple_onunequip,
        opentop_onequip = fns.opentop_onequip,
		fullhelm_onequip = fns.fullhelm_onequip,
		fullhelm_onunequip = fns.fullhelm_onunequip,
        simple_onequiptomodel = fns.simple_onequiptomodel,
    }

    local function simple(custom_init)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(symname)
        inst.AnimState:SetBuild(fname)
        inst.AnimState:PlayAnimation("anim")

        inst:AddTag("hat")

        if custom_init ~= nil then
            custom_init(inst)
        end

        MakeInventoryFloatable(inst)
        inst.components.floater:SetBankSwapOnFloat(false, nil, swap_data) --Hats default animation is not "idle", so even though we don't swap banks, we need to specify the swap_data for re-skinning to reset properly when floating

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst._skinfns = _skinfns

        inst:AddComponent("inventoryitem")

        inst:AddComponent("inspectable")

        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(fns.simple_onequip)
        inst.components.equippable:SetOnUnequip(fns.simple_onunequip)
        inst.components.equippable:SetOnEquipToModel(fns.simple_onequiptomodel)

        MakeHauntableLaunch(inst)

        return inst
    end

    local function straw_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.straw = function()
        local inst = simple(straw_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.STRAWHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        return inst
    end

    local function default()
        return simple()
    end

    local function bee_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.bee = function()
        local inst = simple(bee_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.73)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_BEEHAT, TUNING.ARMOR_BEEHAT_ABSORPTION)
        inst.components.armor:SetTags({ "bee" })

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function earmuffs_custom_init(inst)
        inst:AddTag("open_top_hat")

        inst.AnimState:SetRayTestOnBB(true)
    end

    fns.earmuffs = function()
        local inst = simple(earmuffs_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.6)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
        inst.components.equippable:SetOnEquip(fns.opentop_onequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.EARMUFF_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        return inst
    end

    fns.winter = function()
        local inst = simple()

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.6)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.WINTERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        return inst
    end

    local function football_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.football_onequip = function(inst, owner)
        if inst:HasTag("open_top_hat") then
            fns.opentop_onequip(inst, owner)
        else
            _onequip(inst, owner)
        end
    end

    fns.football_onunequip = function(inst, owner)
        _onunequip(inst, owner)
    end


    fns.football = function()
        local inst = simple(football_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT, TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.equippable:SetOnEquip(fns.football_onequip)
        inst.components.equippable:SetOnUnequip(fns.football_onunequip)

        return inst
    end

    fns.woodcarved_custom_init = function(inst)
        inst:AddTag("wood")
    end

    fns.woodcarved_onhitbyquakedebris = function(inst, damage)
        -- NOTE(DiogoW): This is not considering bonus damage and planar damage, etc.
        if inst.components.armor ~= nil then
            inst.components.armor:TakeDamage(damage)
        end
    end

    fns.woodcarved = function()
        local inst = simple(fns.woodcarved_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("resistance")
        inst.components.resistance:AddResistance("quakedebris")
        inst.components.resistance:AddResistance("lunarhaildebris")
        inst.components.resistance:SetOnResistDamageFn(fns.woodcarved_onhitbyquakedebris)

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_WOODCARVED_HAT, TUNING.ARMOR_WOODCARVED_HAT_ABSORPTION)
        inst.components.armor:AddWeakness("beaver", TUNING.BEAVER_WOOD_DAMAGE)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)

        return inst
    end

    local function ruinshat_fxanim(inst)
        inst._fx.AnimState:PlayAnimation("hit")
        inst._fx.AnimState:PushAnimation("idle_loop")
    end

    local function ruinshat_oncooldown(inst)
        inst._task = nil
    end

    local function ruinshat_unproc(inst)
        if inst:HasTag("forcefield") then
            inst:RemoveTag("forcefield")
            if inst._fx ~= nil then
                inst._fx:kill_fx()
                inst._fx = nil
            end
            inst:RemoveEventCallback("armordamaged", ruinshat_fxanim)

            inst.components.armor:SetAbsorption(TUNING.ARMOR_RUINSHAT_ABSORPTION)
            inst.components.armor.ontakedamage = nil

            if inst._task ~= nil then
                inst._task:Cancel()
            end
            inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_COOLDOWN, ruinshat_oncooldown)
        end
    end

    local function ruinshat_proc(inst, owner)
        inst:AddTag("forcefield")
        if inst._fx ~= nil then
            inst._fx:kill_fx()
        end
        inst._fx = SpawnPrefab("forcefieldfx")
        inst._fx.entity:SetParent(owner.entity)
        inst._fx.Transform:SetPosition(0, 0.2, 0)
        inst:ListenForEvent("armordamaged", ruinshat_fxanim)

        inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)
        inst.components.armor.ontakedamage = function(inst, damage_amount)
            if owner ~= nil and owner.components.sanity ~= nil then
                owner.components.sanity:DoDelta(-damage_amount * TUNING.ARMOR_RUINSHAT_DMG_AS_SANITY, false)
            end
        end

        if inst._task ~= nil then
            inst._task:Cancel()
        end
        inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_DURATION, ruinshat_unproc)
    end

    local function tryproc(inst, owner, data)
        if inst._task == nil and
            not data.redirected and
            math.random() < TUNING.ARMOR_RUINSHAT_PROC_CHANCE then
            ruinshat_proc(inst, owner)
        end
    end

    local function ruins_onunequip(inst, owner)
        _onunequip(inst, owner)
        inst.ondetach()
    end

    local function ruins_onequip(inst, owner)
        fns.opentop_onequip(inst, owner)
        inst.onattach(owner)
    end

    local function ruins_custom_init(inst)
        inst:AddTag("open_top_hat")
        inst:AddTag("metal")

		--shadowlevel (from shadowlevel component) added to pristine state for optimization
		inst:AddTag("shadowlevel")
    end

    local function ruins_onremove(inst)
        if inst._fx ~= nil then
            inst._fx:kill_fx()
            inst._fx = nil
        end
    end

    fns.ruins = function()
        local inst = simple(ruins_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_RUINSHAT, TUNING.ARMOR_RUINSHAT_ABSORPTION)

        inst.components.equippable:SetOnEquip(ruins_onequip)
        inst.components.equippable:SetOnUnequip(ruins_onunequip)

		inst:AddComponent("shadowlevel")
		inst.components.shadowlevel:SetDefaultLevel(TUNING.RUINSHAT_SHADOW_LEVEL)

        MakeHauntableLaunch(inst)

        inst.OnRemoveEntity = ruins_onremove

        inst._fx = nil
        inst._task = nil
        inst._owner = nil
        inst.procfn = function(owner, data) tryproc(inst, owner, data) end
        inst.onattach = function(owner)
            if inst._owner ~= nil then
                inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
                inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
            end
            inst:ListenForEvent("attacked", inst.procfn, owner)
            inst:ListenForEvent("onremove", inst.ondetach, owner)
            inst._owner = owner
            inst._fx = nil
        end
        inst.ondetach = function()
            ruinshat_unproc(inst)
            if inst._owner ~= nil then
                inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
                inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
                inst._owner = nil
                inst._fx = nil
            end
        end

        return inst
    end

    local function feather_equip(inst, owner)
        _onequip(inst, owner)
        local attractor = owner.components.birdattractor
        if attractor then
            attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_MAXDELTA_FEATHERHAT, "maxbirds")
            attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_DELAYDELTA_FEATHERHAT.MIN, "mindelay")
            attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_DELAYDELTA_FEATHERHAT.MAX, "maxdelay")

            local birdspawner = TheWorld.components.birdspawner
            if birdspawner ~= nil then
                birdspawner:ToggleUpdate(true)
            end
        end
    end

    local function feather_unequip(inst, owner)
        _onunequip(inst, owner)

        local attractor = owner.components.birdattractor
        if attractor then
            attractor.spawnmodifier:RemoveModifier(inst)

            local birdspawner = TheWorld.components.birdspawner
            if birdspawner ~= nil then
                birdspawner:ToggleUpdate(true)
            end
        end
    end

    fns.feather = function()
        local inst = simple()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
        inst.components.equippable:SetOnEquip(feather_equip)
        inst.components.equippable:SetOnUnequip(feather_unequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.FEATHERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        return inst
    end

    local function beefalo_equip(inst, owner)
        _onequip(inst, owner)
        owner:AddTag("beefalo")
    end

    local function beefalo_unequip(inst, owner)
        _onunequip(inst, owner)
        owner:RemoveTag("beefalo")
    end

    fns.beefalo_onequiptomodel = function(inst, owner, from_ground)
        fns.simple_onequiptomodel(inst, owner, from_ground)
        owner:RemoveTag("beefalo")
    end

    local function beefalo_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.beefalo = function()
        local inst = simple(beefalo_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable:SetOnEquip(beefalo_equip)
        inst.components.equippable:SetOnUnequip(beefalo_unequip)
        inst.components.equippable:SetOnEquipToModel(fns.beefalo_onequiptomodel)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.BEEFALOHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        return inst
    end

    fns.walrus = function()
        local inst = simple()

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.63)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        return inst
    end

    local function miner_turnon(inst)
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if not inst.components.fueled:IsEmpty() then
            if inst._light == nil or not inst._light:IsValid() then
                inst._light = SpawnPrefab("minerhatlight")
            end
            if owner ~= nil then
                _onequip(inst, owner)
                inst._light.entity:SetParent(owner.entity)
            end
            inst.components.fueled:StartConsuming()
            local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
            soundemitter:PlaySound("dontstarve/common/minerhatAddFuel")
        elseif owner ~= nil then
            _onequip(inst, owner, "swap_hat_off")
        end
    end

    local function miner_turnoff(inst)
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil and inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            _onequip(inst, owner, "swap_hat_off")
        end
        inst.components.fueled:StopConsuming()
        if inst._light ~= nil then
            if inst._light:IsValid() then
                inst._light:Remove()
            end
            inst._light = nil
            local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
            soundemitter:PlaySound("dontstarve/common/minerhatOut")
        end
    end

    local function miner_unequip(inst, owner)
        _onunequip(inst, owner)
        miner_turnoff(inst)
    end

    fns.miner_onequiptomodel = function(inst, owner, from_ground)
        fns.simple_onequiptomodel(inst, owner, from_ground)
        miner_turnoff(inst)
    end

    local function miner_perish(inst)
        local equippable = inst.components.equippable
        if equippable ~= nil and equippable:IsEquipped() then
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            if owner ~= nil then
                local data =
                {
                    prefab = inst.prefab,
                    equipslot = equippable.equipslot,
                }
                miner_turnoff(inst)
                owner:PushEvent("torchranout", data)
                return
            end
        end
        miner_turnoff(inst)
    end

    local function miner_takefuel(inst)
        if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            miner_turnon(inst)
        end
    end

    local function miner_custom_init(inst)
        inst.entity:AddSoundEmitter()
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function miner_onremove(inst)
        if inst._light ~= nil and inst._light:IsValid() then
            inst._light:Remove()
        end
    end

    fns.miner = function()
        local inst = simple(miner_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.6)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem:SetOnDroppedFn(miner_turnoff)
        inst.components.equippable:SetOnEquip(miner_turnon)
        inst.components.equippable:SetOnUnequip(miner_unequip)
        inst.components.equippable:SetOnEquipToModel(fns.miner_onequiptomodel)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.CAVE
        inst.components.fueled:InitializeFuelLevel(TUNING.MINERHAT_LIGHTTIME)
        inst.components.fueled:SetDepletedFn(miner_perish)
        inst.components.fueled:SetTakeFuelFn(miner_takefuel)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled.accepting = true

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst._light = nil
        inst.OnRemoveEntity = miner_onremove

        return inst
    end

    local function spider_disable(inst)
        if inst.updatetask then
            inst.updatetask:Cancel()
            inst.updatetask = nil
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            if not owner:HasTag("spiderwhisperer") then
                if not owner:HasTag("playermonster") then
                    owner:RemoveTag("monster")
                end
                owner:RemoveTag("spiderdisguise")

                for k,v in pairs(owner.components.leader.followers) do
                    if k:HasTag("spider") and k.components.combat then
                        k.components.combat:SuggestTarget(owner)
                    end
                end
                owner.components.leader:RemoveFollowersByTag("spider")
            else
                owner.components.leader:RemoveFollowersByTag("spider", function(follower)
                    if follower and follower.components.follower then
                        if follower.components.follower:GetLoyaltyPercent() > 0 then
                            return false
                        else
                            return true
                        end
                    end
                end)
            end

        end
    end

    local function spider_update(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            owner.components.leader:RemoveFollowersByTag("pig")
            local x,y,z = owner.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x,y,z, TUNING.SPIDERHAT_RANGE, SPIDER_TAGS)
            for k,v in pairs(ents) do
                if v.components.follower and not v.components.follower.leader and not owner.components.leader:IsFollower(v) and owner.components.leader.numfollowers < 10 then
                    owner.components.leader:AddFollower(v)
                end
            end
        end
    end

    local function spider_enable(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            owner.components.leader:RemoveFollowersByTag("pig")
            owner:AddTag("monster")
            owner:AddTag("spiderdisguise")
        end
        inst.updatetask = inst:DoPeriodicTask(0.5, spider_update, 1)
    end

    local function spider_equip(inst, owner)
        _onequip(inst, owner)
        spider_enable(inst)
    end

    local function spider_unequip(inst, owner)
        _onunequip(inst, owner)
        spider_disable(inst)
    end

    fns.spider_onequiptomodel = function(inst, owner, from_ground)
        fns.simple_onequiptomodel(inst, owner, from_ground)
        spider_disable(inst)
    end

    local function spider_perish(inst)
        spider_disable(inst)
        inst:Remove()--generic_perish(inst)
    end

    local function spider_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.spider = function()
        local inst = simple(spider_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.62)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem:SetOnDroppedFn(spider_disable)

        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_SMALL
        inst.components.equippable:SetOnEquip(spider_equip)
        inst.components.equippable:SetOnUnequip(spider_unequip)
        inst.components.equippable:SetOnEquipToModel(fns.spider_onequiptomodel)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.SPIDERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(spider_perish)
        inst.components.fueled.no_sewing = true

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

	local function top_displaynamefn(inst)
		return inst:HasTag("magiciantool") and STRINGS.NAMES.TOPHAT_MAGICIAN or nil
	end

	local function top_onclose(tophatcontainer)
		tophatcontainer.tophat.components.magiciantool:StopUsing()
	end

	local function top_onstartusing(inst, doer)
		if inst.container == nil then
			inst.container = SpawnPrefab("tophat_container")
			inst.container.Network:SetClassifiedTarget(doer)
			inst.container.tophat = inst
			inst.container.components.container_proxy:SetOnCloseFn(top_onclose)
		end
		doer:PushEvent("opencontainer", { container = inst.container.components.container_proxy:GetMaster() })
		inst.container.components.container_proxy:Open(doer)
		if doer.SoundEmitter ~= nil and not doer.SoundEmitter:PlayingSound("magician_tophat_loop") then
			doer.SoundEmitter:PlaySound("maxwell_rework/shadow_magic/storage_void_LP", "magician_tophat_loop")
		end
	end

	local function top_onstopusing(inst, doer)
		if inst.container ~= nil then
			inst.container.components.container_proxy:Close(doer)
			doer:PushEvent("closecontainer", { container = inst.container.components.container_proxy:GetMaster() })
			inst.container:Remove()
			inst.container = nil
		end
		if doer.SoundEmitter ~= nil then
			doer.SoundEmitter:KillSound("magician_tophat_loop")
		end
	end

	local function top_hidefx(inst)
		if inst.fx ~= nil then
			inst.fx:Remove()
			inst.fx = nil
		end
	end

	local function top_showfx_onground(inst)
		if inst.fx == nil then
			inst.fx = SpawnPrefab("tophat_shadow_fx")
		else
			inst.fx.Follower:StopFollowing()
			inst.fx.Transform:SetPosition(0, 0, 0)
		end
		inst.fx.entity:SetParent(inst.entity)
	end

	local function top_showfx_equipped(inst, owner)
		if inst.fx == nil then
			inst.fx = SpawnPrefab("tophat_shadow_fx")
		end
		inst.fx.entity:SetParent(owner.entity)
		inst.fx.Follower:FollowSymbol(owner.GUID, "swap_hat", 0, -100, 0)
	end

	local function top_onequip(inst, owner)
		_onequip(inst, owner)
		top_showfx_equipped(inst, owner)
	end

	local function top_onunequip(inst, owner)
		_onunequip(inst, owner)
		if inst:IsInLimbo() then
			top_hidefx(inst)
		else
			top_showfx_onground(inst)
		end
	end

	local function top_enterlimbo(inst, owner)
		if not inst.components.equippable:IsEquipped() then
			top_hidefx(inst)
		end
	end

	local function top_exitlimbo(inst)
		if not inst.components.equippable:IsEquipped() then
			top_showfx_onground(inst)
		end
	end

	local function top_convert_to_magician(inst)
		if inst.components.magiciantool ~= nil then
			--Already converted
			return
		end

		inst:AddTag("shadow_item")
		inst:AddTag("nocrafting")

		inst.components.inspectable.nameoverride = "TOPHAT_MAGICIAN"

		inst:AddComponent("shadowlevel")
		inst.components.shadowlevel:SetDefaultLevel(TUNING.MAGICIAN_TOPHAT_SHADOW_LEVEL)

		inst:AddComponent("magiciantool")
		inst.components.magiciantool:SetOnStartUsingFn(top_onstartusing)
		inst.components.magiciantool:SetOnStopUsingFn(top_onstopusing)

		inst.components.equippable:SetOnEquip(top_onequip)
		inst.components.equippable:SetOnUnequip(top_onunequip)

		inst:ListenForEvent("enterlimbo", top_enterlimbo)
		inst:ListenForEvent("exitlimbo", top_exitlimbo)

		local owner = inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner or nil
		if owner ~= nil then
			top_showfx_equipped(inst, owner)
		elseif not inst:IsInLimbo() then
			top_showfx_onground(inst)
		end
	end

	local function top_onsave(inst, data)
		if inst.components.magiciantool ~= nil then
			data.magician = true
		end
	end

	local function top_onload(inst, data)
		if data ~= nil and data.magician then
			top_convert_to_magician(inst)
		end
	end

	local function top_onprebuilt(inst, builder, materials, recipe)
		if recipe.name == "tophat_magician" then
			inst:ConvertToMagician()
		end
	end

    local function top_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

		inst.displaynamefn = top_displaynamefn
    end

    fns.top = function()
        local inst = simple(top_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.TOPHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

		inst.OnSave = top_onsave
		inst.OnLoad = top_onload
		inst.ConvertToMagician = top_convert_to_magician
		inst.onPreBuilt = top_onprebuilt

        return inst
    end


    local function nightcap_custom_init(inst)
        inst:AddTag("good_sleep_aid")
    end

    fns.nightcap = function()
        local inst = simple(nightcap_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    local function stopusingbush(inst, data)
        local hat = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        if hat ~= nil and data.statename ~= "hide" then
            hat.components.useableitem:StopUsingItem()
        end
    end

    local function bush_onequip(inst, owner)
        _onequip(inst, owner)

        inst:ListenForEvent("newstate", stopusingbush, owner)
    end

    local function bush_onunequip(inst, owner)
        _onunequip(inst, owner)

        inst:RemoveEventCallback("newstate", stopusingbush, owner)
    end

    local function bush_onuse(inst)
        local owner = inst.components.inventoryitem.owner
        if owner then
            owner.sg:GoToState("hide")
        end
    end

    local function bush_custom_init(inst)
        inst:AddTag("hide")
    end

    fns.bush = function()
        local inst = simple(bush_custom_init)

        inst.foleysound = "dontstarve/movement/foley/bushhat"

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(bush_onuse)

        inst.components.equippable:SetOnEquip(bush_onequip)
        inst.components.equippable:SetOnUnequip(bush_onunequip)

        return inst
    end

    local function flower_custom_init(inst)
        inst:AddTag("open_top_hat")
        inst:AddTag("show_spoilage")
    end

    fns.flower = function()
        local inst = simple(flower_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.68)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
        inst.components.equippable.flipdapperonmerms = true
        inst.components.equippable:SetOnEquip(fns.opentop_onequip)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(inst.Remove)

        inst:AddComponent("forcecompostable")
        inst.components.forcecompostable.green = true

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local function kelp_custom_init(inst)
        inst:AddTag("show_spoilage")
    end

    fns.kelp = function()
        local inst = simple(kelp_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.68)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_TINY
        inst.components.equippable.flipdapperonmerms = true
        inst.components.equippable:SetOnEquip(fns.opentop_onequip)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(inst.Remove)

        inst:AddComponent("forcecompostable")
        inst.components.forcecompostable.green = true

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local function cookiecutter_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.cookiecutter = function()
        local inst = simple(cookiecutter_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_COOKIECUTTERHAT, TUNING.ARMOR_COOKIECUTTERHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALLMED)

        return inst
    end

    local function slurtle_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function slurtle_equip(inst, owner)
        _onequip(inst, owner)

        -- check for the armor_snurtleshell pairing achievement
        if owner:HasTag("player") then
			local equipped_body = owner.components.inventory ~= nil and owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) or nil
			if equipped_body ~= nil and equipped_body.prefab == "armorsnurtleshell" then
				AwardPlayerAchievement("snail_armour_set", owner)
			end
		end

    end

    fns.slurtle = function()
        local inst = simple(slurtle_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_SLURTLEHAT, TUNING.ARMOR_SLURTLEHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.equippable:SetOnEquip( slurtle_equip )

        return inst
    end

    local function rain_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.rain = function()
        local inst = simple(rain_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.RAINHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)

        inst.components.equippable.insulated = true

        return inst
    end

    local function eyebrella_onequip(inst, owner)
        fns.opentop_onequip(inst, owner)

        owner.DynamicShadow:SetSize(2.2, 1.4)
    end

    local function eyebrella_onunequip(inst, owner)
        _onunequip(inst, owner)

        owner.DynamicShadow:SetSize(1.3, 0.6)
    end

    local function eyebrella_perish(inst)
        local equippable = inst.components.equippable
        if equippable ~= nil and equippable:IsEquipped() then
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            if owner ~= nil then
                owner.DynamicShadow:SetSize(1.3, 0.6)
                local data =
                {
                    prefab = inst.prefab,
                    equipslot = equippable.equipslot,
                }
                inst:Remove()--generic_perish(inst)
                owner:PushEvent("umbrellaranout", data)
                return
            end
        end
        inst:Remove()--generic_perish(inst)
    end

    local function eyebrella_custom_init(inst)
        inst:AddTag("open_top_hat")
        inst:AddTag("umbrella")

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.eyebrella = function()
        local inst = simple(eyebrella_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.95)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.EYEBRELLA_PERISHTIME)
        inst.components.fueled:SetDepletedFn(eyebrella_perish)

        inst.components.equippable:SetOnEquip(eyebrella_onequip)
        inst.components.equippable:SetOnUnequip(eyebrella_onunequip)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
        inst.components.insulator:SetSummer()

        inst.components.equippable.insulated = true

        return inst
    end

    local function balloon_onownerattackedfn(inst, data)
        local balloon = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        if balloon ~= nil and balloon.components.poppable ~= nil then
			balloon.components.poppable:Pop()
        end
    end

    local function balloon_onequip(inst, owner)
        fns.simple_onequip(inst, owner)
		inst:ListenForEvent("attacked", balloon_onownerattackedfn, owner)
    end

    local function balloon_onunequip(inst, owner)        
        _onunequip(inst, owner)
		inst:RemoveEventCallback("attacked", balloon_onownerattackedfn, owner)
    end

    local function balloon_custom_init(inst)
        inst.entity:AddSoundEmitter() -- NOTES(JBK): Needed for damage dealing attacks that play sounds on the victim from health combat components.

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

		inst:AddTag("cattoy")
	    inst:AddTag("balloon")
		inst:AddTag("noepicmusic")
    end

    fns.balloon = function()
        local inst = simple(balloon_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

		BALLOONS.MakeBalloonMasterInit(inst, BALLOONS.DoPop)

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
        inst.components.equippable:SetOnEquip(balloon_onequip)
        inst.components.equippable:SetOnUnequip(balloon_onunequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.MAGIC
        inst.components.fueled:InitializeFuelLevel(TUNING.PERISH_ONE_DAY)
		inst.components.fueled:SetDepletedFn(BALLOONS.FueledDepletedPop)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.equippable.insulated = true

        return inst
    end

    local function wathgrithr_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst:AddTag("battlehelm")
    end

	fns.wathgrithr_refreshattunedskills = function(inst, owner)
		local skilltreeupdater = owner and owner.components.skilltreeupdater or nil

		if inst.components.armor then
			local skill_level = skilltreeupdater and skilltreeupdater:CountSkillTag("helmetcondition") or 0
			if skill_level > 0 then
				inst.components.armor.conditionlossmultipliers:SetModifier(inst, TUNING.SKILLS.WATHGRITHR.WATHGRITHRHAT_DURABILITY_MOD[skill_level], "arsenal_helm")
			else
				inst.components.armor.conditionlossmultipliers:RemoveModifier(inst, "arsenal_helm")
			end
		end

		if inst._is_improved_hat then
			if skilltreeupdater and skilltreeupdater:IsActivated("wathgrithr_arsenal_helmet_4") then
				inst.components.planardefense:AddBonus(inst, TUNING.SKILLS.WATHGRITHR.HELM_PLANAR_DEF, "wathgrithr_arsenal_helmet_4")
			else
				inst.components.planardefense:RemoveBonus(inst, "wathgrithr_arsenal_helmet_4")
			end

			if skilltreeupdater and skilltreeupdater:IsActivated("wathgrithr_arsenal_helmet_5") then
				inst:AddTag("battleborn_repairable")
			else
				inst:RemoveTag("battleborn_repairable")
			end
		end
	end

	fns.wathgrithr_watchskillrefresh = function(inst, owner)
		if inst._owner then
			inst:RemoveEventCallback("onactivateskill_server", inst._onskillrefresh, inst._owner)
			inst:RemoveEventCallback("ondeactivateskill_server", inst._onskillrefresh, inst._owner)
		end
		inst._owner = owner
		if owner then
			inst:ListenForEvent("onactivateskill_server", inst._onskillrefresh, owner)
			inst:ListenForEvent("ondeactivateskill_server", inst._onskillrefresh, owner)
		end
	end

    fns.wathgrithr_onequip = function(inst, owner)
        if inst:HasTag("open_top_hat") then
            fns.opentop_onequip(inst, owner)
        else
            _onequip(inst, owner)
        end

		fns.wathgrithr_watchskillrefresh(inst, owner)
		fns.wathgrithr_refreshattunedskills(inst, owner)
    end

    fns.wathgrithr_onunequip = function(inst, owner)
        _onunequip(inst, owner)

		fns.wathgrithr_watchskillrefresh(inst, nil)
		fns.wathgrithr_refreshattunedskills(inst, nil)
    end

    fns.wathgrithr = function()
        local inst = simple(wathgrithr_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

		inst._onskillrefresh = function(owner) fns.wathgrithr_refreshattunedskills(inst, owner) end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_WATHGRITHRHAT, TUNING.ARMOR_WATHGRITHRHAT_ABSORPTION)

        inst.components.equippable:SetOnEquip(fns.wathgrithr_onequip)
        inst.components.equippable:SetOnUnequip(fns.wathgrithr_onunequip)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function wathgrithr_improved_custom_init(inst)
        wathgrithr_custom_init(inst)

        inst:AddTag("heavyarmor")
    end

    fns.wathgrithr_improved = function()
        local inst = simple(wathgrithr_improved_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst._is_improved_hat = true

		inst._onskillrefresh = function(owner) fns.wathgrithr_refreshattunedskills(inst, owner) end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_WATHGRITHR_IMPROVEDHAT, TUNING.ARMOR_WATHGRITHR_IMPROVEDHAT_ABSORPTION)

        inst:AddComponent("planardefense")

        inst.components.equippable:SetOnEquip(fns.wathgrithr_onequip)
        inst.components.equippable:SetOnUnequip(fns.wathgrithr_onunequip)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALLMED)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        return inst
    end

    local function walter_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function walter_onunequip(inst, owner)
        _onunequip(inst, owner)
		if owner._sanity_damage_protection ~= nil then
			owner._sanity_damage_protection:RemoveModifier(inst)
		end
    end

    local function walter_onequip(inst, owner)
        local do_walter_onequip = function()
            if owner.prefab == "walter" then
            	--Note(Peter): please forgive my sins..... walterhats are a mess, and walterhat_nature complicates it
                --When walter wears a walter hat, we use headbase_walter_hat, except for walterhat_nature unless it's one of these listed skins
                if (inst.skinname ~= "walterhat_nature" or (owner.components.skinner ~= nil and
                      (owner.components.skinner.skin_name == "walter_none"
                    or owner.components.skinner.skin_name == "walter_bee"
                    or owner.components.skinner.skin_name == "walter_bee_d"
                    or owner.components.skinner.skin_name == "walter_nature"
                    or owner.components.skinner.skin_name == "walter_ventriloquist")
                )) then
                    --print("headbase_walter_hat", owner.components.skinner.skin_name)
                    _onequip(inst, owner, nil, "headbase_walter_hat" )
                else
                    --print("headbase_hat", owner.components.skinner.skin_name)
                    _onequip(inst, owner )
                end
            else
                _onequip(inst, owner, "swap_hat_large")
            end
        end
        if owner.components.skinner ~= nil then
            owner.old_base_change_cb = owner.components.skinner.base_change_cb
            owner.components.skinner.base_change_cb = function()
                if owner.old_base_change_cb ~= nil then
                    owner.old_base_change_cb()
                end
                do_walter_onequip()
            end
        end
        do_walter_onequip()

		if owner._sanity_damage_protection ~= nil then
			owner._sanity_damage_protection:SetModifier(inst, TUNING.WALTERHAT_SANITY_DAMAGE_PROTECTION)
		end
    end

    fns.walter = function()
        local inst = simple(walter_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        inst.components.equippable:SetOnEquip(walter_onequip)
        inst.components.equippable:SetOnUnequip(walter_onunequip)
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.WALTERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        return inst
    end

    local function ice_custom_init(inst)
        inst:AddTag("show_spoilage")
        inst:AddTag("frozen")
        inst:AddTag("icebox_valid")

        --HASHEATER (from heater component) added to pristine state for optimization
        inst:AddTag("HASHEATER")

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.ice = function()
        local inst = simple(ice_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.66)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("heater")
        inst.components.heater:SetThermics(false, true)
        inst.components.heater.equippedheat = TUNING.ICEHAT_COOLER

        inst.components.equippable.walkspeedmult = TUNING.ICEHAT_SPEED_MULT
        inst.components.equippable.equippedmoisture = 1
        inst.components.equippable.maxequippedmoisture = 49 -- Meter reading rounds up, so set 1 below

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
        inst.components.insulator:SetSummer()

        inst:AddComponent("waterproofer")
        inst.components.waterproofer.effectiveness = 0

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FASTISH)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(function(inst)
            local owner = inst.components.inventoryitem.owner
            if owner ~= nil then
                if owner.components.moisture ~= nil then
                    owner.components.moisture:DoDelta(30)
                elseif owner.components.inventoryitem ~= nil then
                    owner.components.inventoryitem:AddMoisture(50)
                end
            end
            inst:Remove()--generic_perish(inst)
        end)

        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = MATERIALS.ICE
        inst.components.repairable.announcecanfix = false

        return inst
    end

    fns.catcoon = function()
        local inst = simple()

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.63)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.CATCOONHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        return inst
    end

    local function watermelon_custom_init(inst)
        inst:AddTag("show_spoilage")
        inst:AddTag("icebox_valid")

        --HASHEATER (from heater component) added to pristine state for optimization
        inst:AddTag("HASHEATER")

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.watermelon = function()
        local inst = simple(watermelon_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("heater")
        inst.components.heater:SetThermics(false, true)
        inst.components.heater.equippedheat = TUNING.WATERMELON_COOLER

        inst.components.equippable.equippedmoisture = 0.5
        inst.components.equippable.maxequippedmoisture = 32 -- Meter reading rounds up, so set 1 below

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
        inst.components.insulator:SetSummer()

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(--[[generic_perish]]inst.Remove)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_SMALL

        inst.components.floater:SetVerticalOffset(0.1)

        return inst
    end

    local function mole_turnon(owner)
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_on")
    end

    local function mole_turnoff(owner)
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_off")
    end

    local function mole_onequip(inst, owner)
        _onequip(inst, owner)
        mole_turnon(owner)
    end

    local function mole_onunequip(inst, owner)
        _onunequip(inst, owner)
        mole_turnoff(owner)
    end

    local function mole_perish(inst)
        if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            if owner ~= nil then
                mole_turnoff(owner)
            end
        end
        inst:Remove()--generic_perish(inst)
    end

    local function mole_custom_init(inst)
        inst:AddTag("nightvision")
    end

    fns.mole = function()
        local inst = simple(mole_custom_init)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable:SetOnEquip(mole_onequip)
        inst.components.equippable:SetOnUnequip(mole_onunequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.WORMLIGHT
        inst.components.fueled:InitializeFuelLevel(TUNING.MOLEHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(mole_perish)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled.accepting = true

        return inst
    end

    fns.mushroom_onattacked_moonspore_tryspawn = function(hat)
        local periodicspawner = hat.components.periodicspawner
        if periodicspawner == nil then
            hat._moonspore_tryspawn_count = nil
            return
        end

        periodicspawner:TrySpawn()

        hat._moonspore_tryspawn_count = hat._moonspore_tryspawn_count - 1
        if hat._moonspore_tryspawn_count <= 0 then
            hat._moonspore_tryspawn_count = nil
            return
        end

        hat:DoTaskInTime(TUNING.MUSHROOMHAT_MOONSPORE_RETALIATION_SPORE_DELAY, fns.mushroom_onattacked_moonspore_tryspawn)
    end
    fns.mushroom_onattacked_moonspore = function(inst, data)
        local hat = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        if hat ~= nil then
            if hat._moonspore_tryspawn_count == nil then
                hat:DoTaskInTime(TUNING.MUSHROOMHAT_MOONSPORE_RETALIATION_SPORE_DELAY, fns.mushroom_onattacked_moonspore_tryspawn)
            end
            hat._moonspore_tryspawn_count = TUNING.MUSHROOMHAT_MOONSPORE_RETALIATION_SPORE_COUNT
        end
    end
    fns.mushroom_spawnpoint_moonspore = function(inst)
        local pos = inst:GetPosition()
        local dist = GetRandomMinMax(0.1, 2.0)
    
        local offset = FindWalkableOffset(pos, math.random() * TWOPI, dist, 8)
    
        if offset ~= nil then
            return pos + offset
        end

        return pos
    end

    local function mushroom_onequip(inst, owner)
        _onequip(inst, owner)
        owner:AddTag("spoiler")
        if inst._ismoonspore then
            owner:AddTag("moon_spore_protection")
            inst:ListenForEvent("attacked", fns.mushroom_onattacked_moonspore, owner)
        end

        inst.components.periodicspawner:Start()

        if owner.components.hunger ~= nil then
            owner.components.hunger.burnratemodifiers:SetModifier(inst, TUNING.MUSHROOMHAT_SLOW_HUNGER)
        end

    end

    local function mushroom_onunequip(inst, owner)
        _onunequip(inst, owner)
        owner:RemoveTag("spoiler")
        if inst._ismoonspore then
            owner:RemoveTag("moon_spore_protection")
            inst:RemoveEventCallback("attacked", fns.mushroom_onattacked_moonspore, owner)
        end
        inst.components.periodicspawner:Stop()

        if owner.components.hunger ~= nil then
            owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
        end
    end

    fns.mushroom_onequiptomodel = function(inst, owner, from_ground)
        fns.simple_onequiptomodel(inst, owner, from_ground)

        owner:RemoveTag("spoiler")
        inst.components.periodicspawner:Stop()
        if owner.components.hunger ~= nil then
            owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
        end
    end

    local function mushroom_displaynamefn(inst)
        return STRINGS.NAMES[string.upper(inst.prefab)]
    end

    local function mushroom_custom_init(inst)
        inst:AddTag("show_spoilage")

        --Use common inspect strings, but unique display names
        inst:SetPrefabNameOverride("mushroomhat")
        inst.displaynamefn = mushroom_displaynamefn

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    fns.mushroom_onspawn_moonspore = function(inst, spore)
        spore._alwaysinstantpops = true
    end

    local function common_mushroom(spore_prefab)
        local ismoonspore = spore_prefab == "spore_moon"
        local inst = simple(mushroom_custom_init)

        if ismoonspore then
            inst._ismoonspore = true
        end

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable:SetOnEquip(mushroom_onequip)
        inst.components.equippable:SetOnUnequip(mushroom_onunequip)
        inst.components.equippable:SetOnEquipToModel(fns.mushroom_onequiptomodel)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(inst.Remove)

        inst:AddComponent("periodicspawner")
        inst.components.periodicspawner:SetPrefab(spore_prefab)
        inst.components.periodicspawner:SetIgnoreFlotsamGenerator(true) -- NOTES(JBK): These spores float and self expire do not flotsam them.
        if ismoonspore then
            inst.components.periodicspawner:SetRandomTimes(TUNING.MUSHROOMHAT_MOONSPORE_TIME, TUNING.MUSHROOMHAT_MOONSPORE_TIME_VARIANCE, true)
            inst.components.periodicspawner:SetOnSpawnFn(fns.mushroom_onspawn_moonspore)
            inst.components.periodicspawner:SetGetSpawnPointFn(fns.mushroom_spawnpoint_moonspore)
        else
            inst.components.periodicspawner:SetRandomTimes(TUNING.MUSHROOMHAT_SPORE_TIME, 1, true)
        end

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    fns.red_mushroom = function()
        local inst = common_mushroom("spore_medium")

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.95)

        inst.scrapbook_specialinfo = "MUSHHAT"

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    fns.green_mushroom = function()
        local inst = common_mushroom("spore_small")

        inst.scrapbook_specialinfo = "MUSHHAT"

        inst.components.floater:SetSize("med")

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    fns.blue_mushroom = function()
        local inst = common_mushroom("spore_tall")

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.7)

        inst.scrapbook_specialinfo = "MUSHHAT"

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end
    
    fns.moon_mushroom = function()
        local inst = common_mushroom("spore_moon")

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.7)        

        inst.scrapbook_specialinfo = "MUSHHAT"

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end

    local function hive_onunequip(inst, owner)
        _onunequip(inst, owner)

        if owner ~= nil and owner.components.sanity ~= nil then
            owner.components.sanity.neg_aura_absorb = 0
        end
    end

    local function hive_onequip(inst, owner)
        _onequip(inst, owner)

        if owner ~= nil and owner.components.sanity ~= nil then
            owner.components.sanity.neg_aura_absorb = TUNING.ARMOR_HIVEHAT_SANITY_ABSORPTION
        end
    end

    local function hive_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst:AddTag("regal")
    end

    fns.hive = function()
        local inst = simple(hive_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.8)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_HIVEHAT, TUNING.ARMOR_HIVEHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.equippable:SetOnEquip(hive_onequip)
        inst.components.equippable:SetOnUnequip(hive_onunequip)

        return inst
    end

    local function dragon_countpieces(node, dancers, pieces, count)
        local nodes = {}
        for i = #dancers, 1, -1 do
            local dancer = dancers[i]
            if dancer:IsNear(node, 2) then
                table.remove(dancers, i)
                local piece =
                    (dancer.sg:HasStateTag("dragonhead") and "head") or
                    (dancer.sg:HasStateTag("dragonbody") and "body") or
                    (dancer.sg:HasStateTag("dragontail") and "tail") or
                    nil
                if piece ~= nil then
                    if not pieces[piece] then
                        count = count + 1
                        if count >= 3 then
                            return count
                        end
                        pieces[piece] = true
                    end
                    table.insert(nodes, dancer)
                end
            end
        end
        for i, v in ipairs(nodes) do
            count = dragon_countpieces(v, dancers, pieces, count)
            if count >= 3 then
                return count
            end
        end
        return count
    end

    local function dragon_ondancing(inst)
        local pieces = {}
        local dancers = {}
        for i, v in ipairs(AllPlayers) do
            if v.sg:HasStateTag("dragondance") then
                table.insert(dancers, v)
            end
        end
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE * dragon_countpieces(inst, dancers, pieces, 0)
    end

    local function dragon_startdancing(inst, doer, data)
        if not (doer.components.rider ~= nil and doer.components.rider:IsRiding()) then
            if inst.dancetask == nil then
                inst.dancetask = inst:DoPeriodicTask(1, dragon_ondancing)
            end
            inst.components.fueled:StartConsuming()
            return {
                anim = inst.prefab == "dragonheadhat" and
                    { "hatdance2_pre", "hatdance2_loop" } or
                    { "hatdance_pre", "hatdance_loop" },
                loop = true,
                fx = false,
                tags = { "nodangle", "dragondance", string.sub(inst.prefab, 1, -4) },
            }
        end
    end

    local function dragon_stopdancing(inst, doer)
        inst.components.fueled:StopConsuming()
        inst.components.equippable.dapperness = 0
        if inst.dancetask ~= nil then
            inst.dancetask:Cancel()
            inst.dancetask = nil
        end
    end

    local function dragon_equip(inst, owner)
        _onequip(inst, owner)
        dragon_stopdancing(inst, owner)
    end

    local function dragon_unequip(inst, owner)
        _onunequip(inst, owner)
        dragon_stopdancing(inst, owner)
        if owner.sg ~= nil and owner.sg:HasStateTag("dragondance") then
            owner.sg:GoToState("idle")
        end
    end

    fns.dragon_onequiptomodel = function(inst, owner, from_ground)
        fns.simple_onequiptomodel(inst, owner, from_ground)

        dragon_stopdancing(inst, owner)
        if owner.sg ~= nil and owner.sg:HasStateTag("dragondance") then
            owner.sg:GoToState("idle")
        end
    end

    fns.dragon = function()
        local inst = simple()

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.DRAGONHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        inst.components.equippable:SetOnEquip(dragon_equip)
        inst.components.equippable:SetOnUnequip(dragon_unequip)
        inst.components.equippable:SetOnEquipToModel(fns.dragon_onequiptomodel)

        inst.OnStartDancing = dragon_startdancing
        inst.OnStopDancing = dragon_stopdancing

        return inst
    end

    local function desert_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst:AddTag("goggles")
    end

    fns.desert = function()
        local inst = simple(desert_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.72)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.GOGGLES_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

        return inst
    end

    --NOTE: goggleshat do NOT provide "goggles" tag benefits because you do not
    --      actually wear them over your eyes, and they're just for style -_ -"
    local function goggles_custom_init(inst)
        inst:AddTag("open_top_hat")
    end

    fns.goggles = function()
        local inst = simple(goggles_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.68)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
        inst.components.equippable:SetOnEquip(fns.opentop_onequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.GOGGLES_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        return inst
    end

    local function moonstorm_equip(inst, owner)
        _onequip(inst, owner)
        owner:AddTag("wagstaff_detector")
    end

    local function moonstorm_unequip(inst, owner)
        _onunequip(inst, owner)
        owner:RemoveTag("wagstaff_detector")
    end

    local function moonstorm_custom_init(inst)
        inst:AddTag("waterproofer")
        inst:AddTag("goggles")
        inst:AddTag("moonsparkchargeable")
    end

    fns.moonstorm_goggles = function()
        local inst = simple(moonstorm_custom_init)

        inst.components.floater:SetSize("med")        
        inst.components.floater:SetScale(0.72)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.MOONSTORM_GOGGLES_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst.components.equippable:SetOnEquip(moonstorm_equip)
        inst.components.equippable:SetOnUnequip(moonstorm_unequip)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function eyemask_custom_init(inst)
        -- To play an eat sound when it's on the ground and fed.
        inst.entity:AddSoundEmitter()

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

		inst:AddTag("handfed")
		inst:AddTag("fedbyall")

		-- for eater
		inst:AddTag("eatsrawmeat")
		inst:AddTag("strongstomach")
    end

	local function eyemask_oneatfn(inst, food)
		local health = math.abs(food.components.edible:GetHealth(inst)) * inst.components.eater.healthabsorption
		local hunger = math.abs(food.components.edible:GetHunger(inst)) * inst.components.eater.hungerabsorption
		inst.components.armor:Repair(health + hunger)

		if not inst.inlimbo then
			inst.AnimState:PlayAnimation("eat")
			inst.AnimState:PushAnimation("anim", true)

			inst.SoundEmitter:PlaySound("terraria1/eyemask/eat")
		end
	end

    fns.eyemask = function()
        local inst = simple(eyemask_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.72)

        if not TheWorld.ismastersim then
            return inst
        end

		inst:AddComponent("eater")
        --inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI }) -- FOODGROUP.OMNI  is default
		inst.components.eater:SetOnEatFn(eyemask_oneatfn)
		inst.components.eater:SetAbsorptionModifiers(4.0, 1.75, 0)
		inst.components.eater:SetCanEatRawMeat(true)
		inst.components.eater:SetStrongStomach(true)
		inst.components.eater:SetCanEatHorrible(true)

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT, TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    --------------------- ANTLION HAT

    local function antlion_onequip(inst, owner)
        fns.simple_onequip(inst, owner)

		if inst.components.autoterraformer ~= nil and owner.components.locomotor ~= nil then
            inst.components.autoterraformer:StartTerraforming()
        end

        if inst.components.container ~= nil then
            inst.components.container:Open(owner)
        end
    end

    local function antlion_onunequip(inst, owner)
        _onunequip(inst, owner)

        if inst.components.autoterraformer ~= nil then
            inst.components.autoterraformer:StopTerraforming()
        end

        if inst.components.container ~= nil then
            inst.components.container:Close()
        end
    end

    local function antlion_onfinishterraforming(inst, x, y, z)
        local turf_smoke = SpawnPrefab("turf_smoke_fx")
        turf_smoke.Transform:SetPosition(TheWorld.Map:GetTileCenterPoint(x, y, z))
    end

    local function antlion_onfinished(inst)
        inst.components.container:DropEverything(inst:GetPosition())
        inst:Remove()
    end

    local function antlion_custom_init(inst)
        inst:AddTag("turfhat")

		--waterproofer (from waterproofer component) added to pristine state for optimization
		inst:AddTag("waterproofer")

		--shadowlevel (from shadowlevel component) added to pristine state for optimization
		inst:AddTag("shadowlevel")
    end

    fns.antlion = function()
        local inst = simple(antlion_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.72)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable:SetOnEquip(antlion_onequip)
        inst.components.equippable:SetOnUnequip(antlion_onunequip)

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetOnFinished(antlion_onfinished)
        inst.components.finiteuses:SetMaxUses(TUNING.ANTLIONHAT_USES)
        inst.components.finiteuses:SetUses(TUNING.ANTLIONHAT_USES)

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("antlionhat")

        inst:AddComponent("autoterraformer")
        inst.components.autoterraformer.onfinishterraformingfn = antlion_onfinishterraforming

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

		inst:AddComponent("shadowlevel")
		inst.components.shadowlevel:SetDefaultLevel(TUNING.ANTLIONHAT_SHADOW_LEVEL)

        return inst
    end

    --------------------- POLLY ROGERS


    local function update_polly_hat_art(inst)
        inst.AnimState:PlayAnimation(inst.defaultanim)
        local deadpolly = not inst.components.spawner.child or inst.components.spawner.child.components.health:IsDead()
        if deadpolly then
            inst.components.inventoryitem:ChangeImageName("polly_rogershat2")
            inst.AnimState:PlayAnimation("anim_dead")
        else
            inst.components.inventoryitem:ChangeImageName("polly_rogershat")
            inst.AnimState:PlayAnimation("anim")
        end
        if inst.components.equippable:IsEquipped() then
            local skin_build = inst:GetSkinBuild()
            local symbol = deadpolly and "swap_hat2" or "swap_hat"
            local owner = inst.components.inventoryitem.owner
            if skin_build ~= nil then
                owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, symbol, inst.GUID, fname)
            else
                owner.AnimState:OverrideSymbol("swap_hat", fname, symbol)
            end
        end
    end

    local function pollyremoved(inst)
        inst:RemoveEventCallback("onremove", pollyremoved, inst.polly)
        inst.polly = nil
    end

    local function polly_rogers_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function test_polly_spawn(inst)
        if not inst.polly and not inst.components.spawner:IsSpawnPending() then
            inst.components.spawner:ReleaseChild()
        end
    end

    local function polly_rogers_go_away(inst)
        if inst.pollytask then
            inst.pollytask:Cancel()
            inst.pollytask = nil
        end

        if inst.polly then
            inst.polly.flyaway = true
            inst.polly:PushEvent("flyaway")
        end
    end

    local function polly_rogers_ondeplete(inst, data)
        polly_rogers_go_away(inst)
        inst:Remove()
    end

    local function polly_rogers_equip(inst,owner)
        _onequip(inst, owner)
        inst.pollytask = inst:DoTaskInTime(0,function()
            inst.worn = true
            test_polly_spawn(inst)

            inst.polly = inst.components.spawner.child
            if inst.polly then
                inst.polly.components.follower:SetLeader(owner)
                inst.polly.flyaway = nil
            end
            update_polly_hat_art(inst)
        end)
    end

    local function polly_rogers_unequip(inst,owner)
        _onunequip(inst, owner)
        inst.worn = nil

        polly_rogers_go_away(inst)
        --update_polly_hat_art(inst)
    end

    fns.polly_rogers_onequiptomodel = function(inst, owner, from_ground)
        fns.simple_onequiptomodel(inst, owner, from_ground)

        inst.worn = nil
        polly_rogers_go_away(inst)
    end

    local function getpollyspawnlocation(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner or inst
        local pos = Vector3(owner.Transform:GetWorldPosition())
        local offset = nil
        local count = 0
        while offset == nil and count < 12 do
            offset = FindWalkableOffset(pos, math.random()*TWOPI, math.random() * 5, 12, false, false, nil, false, true)
            count = count + 1
        end

        if offset then
            pos.x = pos.x + offset.x
            pos.z = pos.z + offset.z
        end
        return pos.x, 15, pos.z
    end


    local function polly_rogers_onoccupied(inst,child)
        inst.polly = nil
        child.components.follower:StopFollowing()
    end

    local function polly_rogers_onvacate(inst, child)

        if not inst.worn then
            inst.components.spawner:GoHome(child)
            return
        end
               
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner or nil
        if owner then
            child.sg:GoToState("glide")
            child.Transform:SetRotation(math.random() * 180)
            child.components.locomotor:StopMoving()
            child.hat = inst
            inst:ListenForEvent("onremove", pollyremoved, inst.polly)
        end
    end


    local function updatepolly(spawner,polly)
        update_polly_hat_art(spawner)
    end

    fns.polly_rogers = function()
        local inst = simple(polly_rogers_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.72)

        inst.defaultanim = "anim"

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.POLLY_ROGERS_HAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(polly_rogers_ondeplete)

        inst.components.equippable:SetOnEquip(polly_rogers_equip)
        inst.components.equippable:SetOnUnequip(polly_rogers_unequip)
        inst.components.equippable:SetOnEquipToModel(fns.polly_rogers_onequiptomodel)

        inst:AddComponent("spawner")
        inst.components.spawner:Configure("polly_rogers", TUNING.POLLY_ROGERS_SPAWN_TIME)
        inst.components.spawner.onvacate = polly_rogers_onvacate
        inst.components.spawner.onoccupied = polly_rogers_onoccupied
        inst.components.spawner.overridespawnlocation = getpollyspawnlocation
        inst.components.spawner:CancelSpawning()
        inst.components.spawner.onkilledfn = updatepolly
        inst.components.spawner.onspawnedfn = updatepolly

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALLMED)

        inst:DoTaskInTime(0,function() update_polly_hat_art(inst) end)

        return inst
    end

    ------------------ MASKS
    fns.mask = function()
        local inst = simple()

        inst.components.floater:SetSize("med")

        inst.defaultanim = "anim"
        inst.scrapbook_specialinfo = "COSTUME"

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)

        return inst
    end

    ---------------------- MONEY SMALL
    local function monkey_small_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function monkey_small_equip(inst,owner)
        _onequip(inst, owner)
        owner:AddTag("master_crewman")
    end

    local function monkey_small_unequip(inst,owner)
        _onunequip(inst, owner)
        owner:RemoveTag("master_crewman")
    end

    fns.monkey_small = function()
        local inst = simple(monkey_small_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.72)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.MONKEY_MEDIUM_HAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst.components.equippable:SetOnEquip(monkey_small_equip)
        inst.components.equippable:SetOnUnequip(monkey_small_unequip)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    ---------------------- MONEY MEDIUM
    local function monkey_medium_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function monkey_medium_equip(inst,owner)
        _onequip(inst, owner)
        owner:AddTag("boat_health_buffer")
    end

    local function monkey_medium_unequip(inst,owner)
        _onunequip(inst, owner)
        owner:RemoveTag("boat_health_buffer")
    end

    fns.monkey_medium_onequiptomodel = function(inst, owner, from_ground)
        fns.simple_onequiptomodel(inst, owner, from_ground)
        owner:RemoveTag("boat_health_buffer")
    end

    fns.monkey_medium = function()
        local inst = simple(monkey_medium_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.72)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.MONKEY_MEDIUM_HAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst.components.equippable:SetOnEquip(monkey_medium_equip)
        inst.components.equippable:SetOnUnequip(monkey_medium_unequip)
        inst.components.equippable:SetOnEquipToModel(fns.monkey_medium_onequiptomodel)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function skeleton_onequip(inst, owner)
        _onequip(inst, owner)
        if owner.components.sanity ~= nil then
            owner.components.sanity:SetInducedInsanity(inst, true)
        end
    end

    local function skeleton_onunequip(inst, owner)
        _onunequip(inst, owner)
        if owner.components.sanity ~= nil then
            owner.components.sanity:SetInducedInsanity(inst, false)
        end
    end

    local function skeleton_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

		--shadowlevel (from shadowlevel component) added to pristine state for optimization
		inst:AddTag("shadowlevel")

		--shadowdominance (from shadowdominance component) added to pristine state for optimization
        inst:AddTag("shadowdominance")
    end

    local function skeleton()
        local inst = simple(skeleton_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.68)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = TUNING.CRAZINESS_MED
        inst.components.equippable.is_magic_dapperness = true
        inst.components.equippable:SetOnEquip(skeleton_onequip)
        inst.components.equippable:SetOnUnequip(skeleton_onunequip)

		inst:AddComponent("shadowlevel")
		inst.components.shadowlevel:SetDefaultLevel(TUNING.SKELETONHAT_SHADOW_LEVEL)

		inst:AddComponent("shadowdominance")

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_SKELETONHAT, TUNING.ARMOR_SKELETONHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function merm_disable(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner then
			if owner.mermhat_wasmonster then
                owner:AddTag("monster")
                owner.mermhat_wasmonster = nil
			end
			if owner.mermhat_notamerm then
                owner:RemoveTag("merm")
	            owner:RemoveTag("mermdisguise")
				if owner.components.leader then
					owner.components.leader:RemoveFollowersByTag("merm")
				end
                owner.mermhat_notamerm = nil
			end
		end
    end

    local function merm_enable(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner then
			if owner.components.leader then
	            owner.components.leader:RemoveFollowersByTag("pig")
            end

			if not owner:HasTag("merm") then
				owner.mermhat_notamerm = true
	            owner:AddTag("merm")
	            owner:AddTag("mermdisguise")
			end
			if owner:HasTag("monster") then
				owner.mermhat_wasmonster = true
	            owner:RemoveTag("monster")
			end
        end
    end

    local function merm_equip(inst, owner)
        fns.opentop_onequip(inst, owner)
        merm_enable(inst)
    end

    local function merm_unequip(inst, owner)
        _onunequip(inst, owner)
        merm_disable(inst)
    end

    fns.merm_onequiptomodel = function(inst, owner, from_ground)
        fns.simple_onequiptomodel(inst, owner, from_ground)
        merm_disable(inst)
    end

    local function merm_custom_init(inst)
        inst:AddTag("open_top_hat")
        inst:AddTag("show_spoilage")
    end

    fns.merm = function()
        local inst = simple(merm_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.68)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_TINY
        inst.components.equippable:SetOnEquip(merm_equip)
        inst.components.equippable:SetOnUnequip(merm_unequip)
        inst.components.equippable:SetOnEquipToModel(fns.merm_onequiptomodel)

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(inst.Remove)

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local function batnose_equip(inst, owner)
        _onequip(inst, owner)

        inst.components.perishable:StartPerishing()

        owner:PushEvent("learncookbookstats", inst.prefab)
        owner:AddDebuff("hungerregenbuff", "hungerregenbuff")
    end

    local function batnose_unequip(inst, owner)
        _onunequip(inst, owner)

        inst.components.perishable:StopPerishing()

        owner:RemoveDebuff("hungerregenbuff")

        if owner.components.foodmemory ~= nil then
            owner.components.foodmemory:RememberFood("hungerregenbuff")
        end
    end

    fns.batnose_onequiptomodel = function(inst, owner, from_ground)
        fns.simple_onequiptomodel(inst, owner, from_ground)

        inst.components.perishable:StopPerishing()

        owner:RemoveDebuff("hungerregenbuff")

        if owner.components.foodmemory ~= nil then
            owner.components.foodmemory:RememberFood("hungerregenbuff")
        end
    end

    fns.batnose = function()
        local inst = simple()

        inst.components.floater:SetSize("med")

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_TINY
        inst.components.equippable.flipdapperonmerms = true
        inst.components.equippable:SetOnEquip(batnose_equip)
        inst.components.equippable:SetOnUnequip(batnose_unequip)
        inst.components.equippable:SetOnEquipToModel(fns.batnose_onequiptomodel)
        inst.components.equippable.restrictedtag = "usesvegetarianequipment"
        inst.components.equippable.refuse_on_restrict = true

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.BATNOSEHAT_PERISHTIME)
        inst.components.perishable:SetOnPerishFn(inst.Remove)

        MakeHauntableLaunchAndPerish(inst)

        return inst
    end

    local function stopusingplantregistry(inst, data)
        local hat = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        if hat ~= nil and data.statename ~= "plantregistry_open" then
            hat.components.useableitem:StopUsingItem()
        end
    end

    local function plantregistry_onequip(inst, owner)
        _onequip(inst, owner)
        inst:ListenForEvent("newstate", stopusingplantregistry, owner)
    end

    local function plantregistry_onunequip(inst, owner)
        _onunequip(inst, owner)
        inst:RemoveEventCallback("newstate", stopusingplantregistry, owner)
    end

    local function plantregistry_onuse(inst)
        local owner = inst.components.inventoryitem.owner
        if owner then
            if not CanEntitySeeTarget(owner, inst) then return false end
            owner.sg:GoToState("plantregistry_open")
            owner:ShowPopUp(POPUPS.PLANTREGISTRY, true)
        end
    end

    local function plantregistry_custom_init(inst)
        inst:AddTag("plantinspector")
    end

    fns.plantregistry = function()
        local inst = simple(plantregistry_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable:SetOnEquip(plantregistry_onequip)
        inst.components.equippable:SetOnUnequip(plantregistry_onunequip)

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(plantregistry_onuse)

        return inst
    end

    local function nutrients_onequip(inst, owner)
        plantregistry_onequip(inst, owner) --calls onequip
    end

    local function nutrients_onunequip(inst, owner)
        plantregistry_onunequip(inst, owner) --calls onunequip
    end

    local function nutrients_custom_init(inst)
        plantregistry_custom_init(inst)
        inst:AddTag("detailedplanthappiness")
        inst:AddTag("nutrientsvision")

		--shadowlevel (from shadowlevel component) added to pristine state for optimization
		inst:AddTag("shadowlevel")
    end

    fns.nutrientsgoggles = function()
        local inst = simple(nutrients_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.72)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable:SetOnEquip(nutrients_onequip)
        inst.components.equippable:SetOnUnequip(nutrients_onunequip)

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(plantregistry_onuse)

		inst:AddComponent("shadowlevel")
		inst.components.shadowlevel:SetDefaultLevel(TUNING.NUTRIENTSGOGGLESHAT_SHADOW_LEVEL)

        return inst
    end

    local function alterguardian_custom_init(inst)
        inst:AddTag("open_top_hat")

        inst:AddTag("gestaltprotection")
    end

    local function alterguardianhat_IsRed(inst) return inst.prefab == MUSHTREE_SPORE_RED end
    local function alterguardianhat_IsGreen(inst) return inst.prefab == MUSHTREE_SPORE_GREEN end
    local function alterguardianhat_IsBlue(inst) return inst.prefab == MUSHTREE_SPORE_BLUE end
    local alterguardianhat_colourtint = { 0.4, 0.3, 0.25, 0.2, 0.15, 0.1 }
    local alterguardianhat_multtint = { 0.7, 0.6, 0.55, 0.5, 0.45, 0.4 }

    local function alterguardianhat_animstatemult(animstate, r, g, b)
        animstate:SetMultColour(
            alterguardianhat_multtint[1+g+b],
            alterguardianhat_multtint[r+1+b],
            alterguardianhat_multtint[r+g+1],
            1
        )
    end
    local function alterguardianhat_updatelight(inst)
        local num_sources = #inst.components.container:FindItems(function(item)
            return item:HasTag("spore")
        end)

        local r = #inst.components.container:FindItems(alterguardianhat_IsRed)
        local g = #inst.components.container:FindItems(alterguardianhat_IsGreen)
        local b = #inst.components.container:FindItems(alterguardianhat_IsBlue)

        if inst._light ~= nil and inst._light:IsValid() then
            if r > 0 or g > 0 or b > 0 then
                inst._light.Light:SetColour(
                    alterguardianhat_colourtint[1+g+b] + r/11,
                    alterguardianhat_colourtint[r+1+b] + g/11,
                    alterguardianhat_colourtint[r+g+1] + b/11
                )
            else
                -- If no spores are inserted, match the colour of the miner hat light.
                inst._light.Light:SetColour(180 / 255, 195 / 255, 150 / 255)
            end
        end

        alterguardianhat_animstatemult(inst.AnimState, r, g, b)

        if inst._front and inst._front:IsValid() then
            alterguardianhat_animstatemult(inst._front.AnimState, r, g, b)
        end

        if inst._back and inst._back:IsValid() then
            alterguardianhat_animstatemult(inst._back.AnimState, r, g, b)
        end
    end

	local function alterguardian_activate(inst, owner)
		if inst._is_active then
			return
		end
		inst._is_active = true

		if inst._task ~= nil then
			inst._task:Cancel()
			inst._task = nil
		end

		_onunequip(inst, owner) -- hide the swap_hat

		if inst._front == nil then
			inst._front = SpawnPrefab("alterguardian_hat_equipped")
			inst._front:OnActivated(owner, true)
		end
		if inst._back == nil then
			inst._back = SpawnPrefab("alterguardian_hat_equipped")
			inst._back:OnActivated(owner, false)
		end

        local skin_build = inst:GetSkinBuild()
        if skin_build then
            inst._front:SetSkin(skin_build, inst.GUID)
            inst._back:SetSkin(skin_build, inst.GUID)
        end

        if inst._light == nil then
            inst._light = SpawnPrefab("alterguardianhatlight")
	        inst._light.entity:SetParent(owner.entity)
        end
        alterguardianhat_updatelight(inst)
	end

	local function alterguardian_deactivate(inst, owner)
		if not inst._is_active then
			return
		end
		inst._is_active = false

        if inst._light ~= nil then
            inst._light:Remove()
            inst._light = nil
		end

		if inst._front ~= nil then
			inst._front:OnDeactivated()
			inst._front = nil
			inst._task = inst:DoTaskInTime(8*FRAMES, function()
                fns.opentop_onequip(inst, owner)
                inst._task = nil
            end)
		else
			fns.opentop_onequip(inst, owner)
		end

		if inst._back ~= nil then
			inst._back:OnDeactivated()
			inst._back = nil
		end
	end

	local function alterguardian_onsanitydelta(inst, owner)
		local sanity = owner.components.sanity ~= nil and owner.components.sanity:GetPercentWithPenalty() or 0
		if sanity > TUNING.SANITY_BECOME_ENLIGHTENED_THRESH then
			alterguardian_activate(inst, owner)
		else
			alterguardian_deactivate(inst, owner)
		end
	end

	local function alterguardian_spawngestalt_fn(inst, owner, data)
		if not inst._is_active then
			return
		end

		if owner ~= nil and (owner.components.health == nil or not owner.components.health:IsDead()) then
		    local target = data.target
			if target and target ~= owner and target:IsValid() and (target.components.health == nil or not target.components.health:IsDead() and not target:HasTag("structure") and not target:HasTag("wall")) then

                -- In combat, this is when we're just launching a projectile, so don't spawn a gestalt yet
                if data.weapon ~= nil and data.projectile == nil
                        and (data.weapon.components.projectile ~= nil
                            or data.weapon.components.complexprojectile ~= nil
                            or data.weapon.components.weapon:CanRangedAttack()) then
                    return
                end

				local x, y, z = target.Transform:GetWorldPosition()

				local gestalt = SpawnPrefab("alterguardianhat_projectile")
				local r = GetRandomMinMax(3, 5)
				local delta_angle = GetRandomMinMax(-90, 90)
				local angle = (owner:GetAngleToPoint(x, y, z) + delta_angle) * DEGREES
				gestalt.Transform:SetPosition(x + r * math.cos(angle), y, z + r * -math.sin(angle))
				gestalt:ForceFacePoint(x, y, z)
				gestalt:SetTargetPosition(Vector3(x, y, z))
				gestalt.components.follower:SetLeader(owner)

				if owner.components.sanity ~= nil then
					owner.components.sanity:DoDelta(-1, true) -- using overtime so it doesnt make the sanity sfx every time you attack
				end
			end
		end
	end

    local function alterguardian_onequip(inst, owner)
        fns.opentop_onequip(inst, owner)

		inst.alterguardian_spawngestalt_fn = function(_owner, _data) alterguardian_spawngestalt_fn(inst, _owner, _data) end
		inst:ListenForEvent("onattackother", inst.alterguardian_spawngestalt_fn, owner)

		inst._onsanitydelta = function() alterguardian_onsanitydelta(inst, owner) end
		inst:ListenForEvent("sanitydelta", inst._onsanitydelta, owner)

		local sanity = owner.components.sanity ~= nil and owner.components.sanity:GetPercent() or 0
		if sanity > TUNING.SANITY_BECOME_ENLIGHTENED_THRESH then
			alterguardian_activate(inst, owner)
		end

        if inst.components.container ~= nil and inst.keep_closed ~= owner.userid then
            inst.components.container:Open(owner)
        end
    end

    local function alterguardian_onunequip(inst, owner)
		inst._is_active = false

		inst:RemoveEventCallback("sanitydelta", inst._onsanitydelta, owner)
		inst:RemoveEventCallback("onattackother", inst.alterguardian_spawngestalt_fn, owner)

		if inst._task then
			inst._task:Cancel()
			inst._task = nil
		end

        if inst._light ~= nil then
            inst._light:Remove()
            inst._light = nil
		end

        _onunequip(inst, owner)
		if inst._front ~= nil then
			inst._front:Remove()
			inst._front = nil
		end
		if inst._back ~= nil then
			inst._back:Remove()
			inst._back = nil
		end

        if inst.components.container ~= nil then
			inst.keep_closed = inst.components.container.opencount == 0 and owner.userid or nil
            inst.components.container:Close()
        end
    end

    local function alterguardianhat_onremove(inst)
        if inst._front ~= nil and inst._front:IsValid() then
            inst._front:Remove()
        end
        if inst._back ~= nil and inst._back:IsValid() then
            inst._back:Remove()
        end
    end

    fns.alterguardian_onsave = function(inst, data)
        local equipper = inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() or nil
        local keep_closed = (equipper ~= nil and inst.components.container.opencount == 0 and equipper.userid) or inst.keep_closed -- Try to get new data and fallback to saved variable.

        if keep_closed ~= nil then
            data.owner_id = keep_closed
        end
    end

    fns.alterguardian_onload = function(inst, data)
        if data.owner_id ~= nil then
            inst.keep_closed = data.owner_id
        end
    end

    fns.alterguardian = function()
        local inst = simple(alterguardian_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.68)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable.dapperness = -TUNING.CRAZINESS_SMALL
        inst.components.equippable:SetOnEquip(alterguardian_onequip)
        inst.components.equippable:SetOnUnequip(alterguardian_onunequip)
	    inst.components.equippable.is_magic_dapperness = true

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("alterguardianhat")
        inst.components.container.acceptsstacks = false

        inst:AddComponent("preserver")
        inst.components.preserver:SetPerishRateMultiplier(0)

        inst.OnSave = fns.alterguardian_onsave
		inst.OnLoad = fns.alterguardian_onload

        MakeHauntableLaunchAndPerish(inst)

        inst:ListenForEvent("itemget", alterguardianhat_updatelight)
        inst:ListenForEvent("itemlose", alterguardianhat_updatelight)
        inst:ListenForEvent("onremove", alterguardianhat_onremove)

        return inst
    end

	local function dreadstone_getsetbonusequip(inst, owner)
		local body = owner.components.inventory ~= nil and owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) or nil
		return body ~= nil and body.prefab == "armordreadstone" and body or nil
	end

	local function dreadstone_doregen(inst, owner)
		if owner.components.sanity ~= nil and owner.components.sanity:IsInsanityMode() then
			local setbonus = inst.components.setbonus ~= nil and inst.components.setbonus:IsEnabled(EQUIPMENTSETNAMES.DREADSTONE) and TUNING.ARMOR_DREADSTONE_REGEN_SETBONUS or 1
			local rate = 1 / Lerp(1 / TUNING.ARMOR_DREADSTONE_REGEN_MAXRATE, 1 / TUNING.ARMOR_DREADSTONE_REGEN_MINRATE, owner.components.sanity:GetPercent())
			inst.components.armor:Repair(inst.components.armor.maxcondition * rate * setbonus)
		end
		if not inst.components.armor:IsDamaged() then
			inst.regentask:Cancel()
			inst.regentask = nil
		end
	end

	local function dreadstone_startregen(inst, owner)
		if inst.regentask == nil then
			inst.regentask = inst:DoPeriodicTask(TUNING.ARMOR_DREADSTONE_REGEN_PERIOD, dreadstone_doregen, nil, owner)
		end
	end

	local function dreadstone_stopregen(inst)
		if inst.regentask ~= nil then
			inst.regentask:Cancel()
			inst.regentask = nil
		end
	end

	local function dreadstone_onequip(inst, owner)
		_onequip(inst, owner)

		if owner.components.sanity ~= nil and inst.components.armor:IsDamaged() then
			dreadstone_startregen(inst, owner)
		else
			dreadstone_stopregen(inst)
		end
	end

	local function dreadstone_onunequip(inst, owner)
		_onunequip(inst, owner)
		dreadstone_stopregen(inst)
	end

	local function dreadstone_ontakedamage(inst, amount)
		if inst.regentask == nil and inst.components.equippable:IsEquipped() then
			local owner = inst.components.inventoryitem.owner
			if owner ~= nil and owner.components.sanity ~= nil then
				dreadstone_startregen(inst, owner)
			end
		end
	end

	local function dreadstone_calcdapperness(inst, owner)
		local insanity = owner.components.sanity ~= nil and owner.components.sanity:IsInsanityMode()
		local other = dreadstone_getsetbonusequip(inst, owner)
		if other ~= nil then
			return (insanity and (inst.regentask ~= nil or other.regentask ~= nil) and TUNING.CRAZINESS_MED or 0) * 0.5
		end
		return insanity and inst.regentask ~= nil and TUNING.CRAZINESS_MED or 0
	end

	local function dreadstone_custom_init(inst)
		inst:AddTag("dreadstone")
		inst:AddTag("shadow_item")

		--waterproofer (from waterproofer component) added to pristine state for optimization
		inst:AddTag("waterproofer")

		--shadowlevel (from shadowlevel component) added to pristine state for optimization
		inst:AddTag("shadowlevel")
	end

	fns.dreadstone = function()
		local inst = simple(dreadstone_custom_init)

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("armor")
		inst.components.armor:InitCondition(TUNING.ARMOR_DREADSTONEHAT, TUNING.ARMOR_DREADSTONEHAT_ABSORPTION)
		inst.components.armor.ontakedamage = dreadstone_ontakedamage

		inst.components.equippable.dapperfn = dreadstone_calcdapperness
		inst.components.equippable.is_magic_dapperness = true
		inst.components.equippable:SetOnEquip(dreadstone_onequip)
		inst.components.equippable:SetOnUnequip(dreadstone_onunequip)

		inst:AddComponent("planardefense")
		inst.components.planardefense:SetBaseDefense(TUNING.ARMOR_DREADSTONEHAT_PLANAR_DEF)

		inst:AddComponent("waterproofer")
		inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

		inst:AddComponent("damagetyperesist")
		inst.components.damagetyperesist:AddResist("shadow_aligned", inst, TUNING.ARMOR_DREADSTONEHAT_SHADOW_RESIST)

		inst:AddComponent("shadowlevel")
		inst.components.shadowlevel:SetDefaultLevel(TUNING.DREADSTONEHAT_SHADOW_LEVEL)

        local setbonus = inst:AddComponent("setbonus")
        setbonus:SetSetName(EQUIPMENTSETNAMES.DREADSTONE)

		MakeHauntableLaunch(inst)

		return inst
	end

	local function lunarplant_onequip(inst, owner)
		fns.fullhelm_onequip(inst, owner)

		if inst.fx ~= nil then
			inst.fx:Remove()
		end
		inst.fx = SpawnPrefab("lunarplanthat_fx")
		inst.fx:AttachToOwner(owner)
		owner.AnimState:SetSymbolLightOverride("swap_hat", .1)
		if owner.components.grue ~= nil then
			owner.components.grue:AddImmunity("lunarplanthat")
		end
	end

	local function lunarplant_onunequip(inst, owner)
		fns.fullhelm_onunequip(inst, owner)

		if inst.fx ~= nil then
			inst.fx:Remove()
			inst.fx = nil
		end
		owner.AnimState:SetSymbolLightOverride("swap_hat", 0)
		if owner.components.grue ~= nil then
			owner.components.grue:RemoveImmunity("lunarplanthat")
		end
	end

    local function lunarplant_onsetbonus_enabled(inst)
		inst.components.damagetyperesist:AddResist("lunar_aligned", inst, TUNING.ARMOR_LUNARPLANT_SETBONUS_LUNAR_RESIST, "setbonus")
    end

    local function lunarplant_onsetbonus_disabled(inst)
        inst.components.damagetyperesist:RemoveResist("lunar_aligned", inst, "setbonus")
    end

	local lunarplant_swap_data_broken = { bank = "hat_lunarplant", anim = "broken" }

	local function lunarplant_onbroken(inst)
		if inst.components.equippable ~= nil then
			inst:RemoveComponent("equippable")
			inst.AnimState:PlayAnimation("broken")
			inst.components.floater:SetSwapData(lunarplant_swap_data_broken)
			inst:AddTag("broken")
			inst.components.inspectable.nameoverride = "BROKEN_FORGEDITEM"
		end
	end

	local function lunarplant_onrepaired(inst)
		if inst.components.equippable == nil then
			inst:AddComponent("equippable")
			inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
			inst.components.equippable:SetOnEquip(lunarplant_onequip)
			inst.components.equippable:SetOnUnequip(lunarplant_onunequip)
			inst.components.equippable:SetOnEquipToModel(fns.simple_onequiptomodel)
			inst.AnimState:PlayAnimation("anim")
			inst.components.floater:SetSwapData(swap_data)
			inst:RemoveTag("broken")
			inst.components.inspectable.nameoverride = nil
		end
	end

	local function lunarplant_custom_init(inst)
		inst:AddTag("lunarplant")
		inst:AddTag("gestaltprotection")
		inst:AddTag("goggles")
		inst:AddTag("show_broken_ui")

		--waterproofer (from waterproofer component) added to pristine state for optimization
		inst:AddTag("waterproofer")
	end

	fns.lunarplant = function()
		local inst = simple(lunarplant_custom_init)

		inst.components.floater:SetSize("med")
		inst.components.floater:SetVerticalOffset(0.25)
		inst.components.floater:SetScale(.75)

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("armor")
		inst.components.armor:InitCondition(TUNING.ARMOR_LUNARPLANT_HAT, TUNING.ARMOR_LUNARPLANT_HAT_ABSORPTION)

		inst.components.equippable:SetOnEquip(lunarplant_onequip)
		inst.components.equippable:SetOnUnequip(lunarplant_onunequip)

		inst:AddComponent("planardefense")
		inst.components.planardefense:SetBaseDefense(TUNING.ARMOR_LUNARPLANT_HAT_PLANAR_DEF)

		inst:AddComponent("waterproofer")
		inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALLMED)

		inst:AddComponent("damagetyperesist")
		inst.components.damagetyperesist:AddResist("lunar_aligned", inst, TUNING.ARMOR_LUNARPLANT_LUNAR_RESIST)

        local setbonus = inst:AddComponent("setbonus")
        setbonus:SetSetName(EQUIPMENTSETNAMES.LUNARPLANT)
        setbonus:SetOnEnabledFn(lunarplant_onsetbonus_enabled)
        setbonus:SetOnDisabledFn(lunarplant_onsetbonus_disabled)

		MakeForgeRepairable(inst, FORGEMATERIALS.LUNARPLANT, lunarplant_onbroken, lunarplant_onrepaired)
		MakeHauntableLaunch(inst)

		return inst
	end

	local function voidcloth_applyitembuff(inst, item, stacks)
		if item.components.planardamage ~= nil then
			if stacks > 0 then
				local bonus = Remap(stacks, 0, TUNING.ARMOR_VOIDCLOTH_SETBONUS_PLANARDAMAGE_MAX_HITS, 0, TUNING.ARMOR_VOIDCLOTH_SETBONUS_PLANARDAMAGE_MAX)
				item.components.planardamage:AddBonus(inst, bonus, "voidclothhat_rampingbuff")
			else
				item.components.planardamage:RemoveBonus(inst, "voidclothhat_rampingbuff")
			end
		end
	end

	local function voidcloth_setbuffitem(inst, item)
		if inst.buff_item ~= item then
			if inst.buff_item ~= nil then
				voidcloth_applyitembuff(inst, inst.buff_item, 0)
			end
			inst.buff_item = item
			if item ~= nil then
				voidcloth_applyitembuff(inst, item, inst.buff_stacks)
			end
		end
	end

	local function voidcloth_resetbuff(inst)
		if inst.decaystacktask ~= nil then
			inst.decaystacktask:Cancel()
			inst.decaystacktask = nil
		end

		inst.buff_stacks = 0
		if inst.buff_item ~= nil then
			voidcloth_applyitembuff(inst, inst.buff_item, 0)
		end

		if inst.fx ~= nil then
			inst.fx.buffed:set(false)
		end
	end

	local function voidcloth_onattackother(inst)
		if inst.buff_item == nil then
			return
		end

		if inst.decaystacktask ~= nil then
			inst.decaystacktask:Cancel()
		end
		inst.decaystacktask = inst:DoTaskInTime(TUNING.ARMOR_VOIDCLOTH_SETBONUS_PLANARDAMAGE_DECAY_TIME, voidcloth_resetbuff)

		if inst.buff_stacks < TUNING.ARMOR_VOIDCLOTH_SETBONUS_PLANARDAMAGE_MAX_HITS then
			inst.buff_stacks = inst.buff_stacks + 1
			if inst.buff_item ~= nil then
				voidcloth_applyitembuff(inst, inst.buff_item, inst.buff_stacks)
			end
		end

		if inst.fx ~= nil then
			inst.fx.buffed:set(true)
		end
	end

	local function voidcloth_setbuffowner(inst, owner)
		if inst._owner ~= owner then
			if inst._owner ~= nil then
				inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
				inst:RemoveEventCallback("unequip", inst._onownerunequip, inst._owner)
				inst:RemoveEventCallback("attacked", inst._onattacked, inst._owner)
				inst:RemoveEventCallback("onattackother", inst._onattackother, inst._owner)
				inst._onownerunequip = nil
				inst._onattacked = nil
				inst._onattackother = nil

				voidcloth_setbuffitem(inst, nil)
				voidcloth_resetbuff(inst)
				inst.buff_stacks = nil
			end
			inst._owner = owner
			if owner ~= nil then
				inst._onownerequip = function(owner, data)
					if data ~= nil and data.eslot == EQUIPSLOTS.HANDS then
						if data.item ~= nil and data.item.components.planardamage ~= nil and data.item:HasTag("shadow_item") then
							voidcloth_setbuffitem(inst, data.item)
						else
							voidcloth_setbuffitem(inst, nil)
						end
					end
				end
				inst._onownerunequip = function(owner, data)
					if data ~= nil and data.eslot == EQUIPSLOTS.HANDS then
						voidcloth_setbuffitem(inst, nil)
					end
				end
				inst._onattacked = function(owner)
					voidcloth_resetbuff(inst)
				end
				inst._onattackother = function(owner)
					voidcloth_onattackother(inst)
				end
				inst:ListenForEvent("equip", inst._onownerequip, owner)
				inst:ListenForEvent("unequip", inst._onownerunequip, owner)
				inst:ListenForEvent("attacked", inst._onattacked, owner)
				inst:ListenForEvent("onattackother", inst._onattackother, owner)

				inst.buff_stacks = 0
				local weapon = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
				if weapon ~= nil and weapon.components.planardamage ~= nil and weapon:HasTag("shadow_item") then
					voidcloth_setbuffitem(inst, weapon)
				end
			end
		end
	end

	fns.voidcloth_onequip = function(inst, owner)
		fns.fullhelm_onequip(inst, owner)

		if inst.fx ~= nil then
			inst.fx:Remove()
		end
		inst.fx = SpawnPrefab("voidclothhat_fx")
		inst.fx:AttachToOwner(owner)

		voidcloth_setbuffowner(inst, owner)
	end

	fns.voidcloth_onunequip = function(inst, owner)
		fns.fullhelm_onunequip(inst, owner)

		if inst.fx ~= nil then
			inst.fx:Remove()
			inst.fx = nil
		end

		voidcloth_setbuffowner(inst, nil)
	end

	local voidcloth_swap_data_broken = { bank = "hat_voidcloth", anim = "broken" }

	fns.voidcloth_onbroken = function(inst)
		if inst.components.equippable ~= nil then
			inst:RemoveComponent("equippable")
			inst.AnimState:PlayAnimation("broken")
			inst.components.floater:SetSwapData(voidcloth_swap_data_broken)
			inst:AddTag("broken")
			inst.components.inspectable.nameoverride = "BROKEN_FORGEDITEM"
		end
	end

	fns.voidcloth_onrepaired = function(inst)
		if inst.components.equippable == nil then
			inst:AddComponent("equippable")
			inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
			inst.components.equippable:SetOnEquip(fns.voidcloth_onequip)
			inst.components.equippable:SetOnUnequip(fns.voidcloth_onunequip)
			inst.components.equippable:SetOnEquipToModel(fns.simple_onequiptomodel)
			inst.AnimState:PlayAnimation("anim")
			inst.components.floater:SetSwapData(swap_data)
			inst:RemoveTag("broken")
			inst.components.inspectable.nameoverride = nil
		end
	end

	fns.voidcloth_custom_init = function(inst)
		inst:AddTag("cloth")
		inst:AddTag("shadow_item")
		inst:AddTag("show_broken_ui")
		inst:AddTag("miasmaimmune")

		--shadowlevel (from shadowlevel component) added to pristine state for optimization
		inst:AddTag("shadowlevel")
	end

    fns.voidcloth_onsetbonus_enabled = function(inst)
        inst.components.damagetyperesist:AddResist("shadow_aligned", inst, TUNING.ARMOR_VOIDCLOTH_SETBONUS_SHADOW_RESIST, "setbonus")
    end

    fns.voidcloth_onsetbonus_disabled = function(inst)
        inst.components.damagetyperesist:RemoveResist("shadow_aligned", inst, "setbonus")
    end

	fns.voidcloth = function()
		local inst = simple(fns.voidcloth_custom_init)

		inst.components.floater:SetSize("med")
		inst.components.floater:SetVerticalOffset(0.1)
		inst.components.floater:SetScale(.75)

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("armor")
		inst.components.armor:InitCondition(TUNING.ARMOR_VOIDCLOTH_HAT, TUNING.ARMOR_VOIDCLOTH_HAT_ABSORPTION)

		inst.components.equippable:SetOnEquip(fns.voidcloth_onequip)
		inst.components.equippable:SetOnUnequip(fns.voidcloth_onunequip)

		inst:AddComponent("planardefense")
		inst.components.planardefense:SetBaseDefense(TUNING.ARMOR_VOIDCLOTH_HAT_PLANAR_DEF)

		inst:AddComponent("damagetyperesist")
		inst.components.damagetyperesist:AddResist("shadow_aligned", inst, TUNING.ARMOR_VOIDCLOTH_SHADOW_RESIST)

		inst:AddComponent("shadowlevel")
		inst.components.shadowlevel:SetDefaultLevel(TUNING.VOIDCLOTHHAT_SHADOW_LEVEL)

        local setbonus = inst:AddComponent("setbonus")
        setbonus:SetSetName(EQUIPMENTSETNAMES.VOIDCLOTH)
        setbonus:SetOnEnabledFn(fns.voidcloth_onsetbonus_enabled)
        setbonus:SetOnDisabledFn(fns.voidcloth_onsetbonus_disabled)

		MakeForgeRepairable(inst, FORGEMATERIALS.VOIDCLOTH, fns.voidcloth_onbroken, fns.voidcloth_onrepaired)
		MakeHauntableLaunch(inst)

        inst.voidcloth_onattackother = voidcloth_onattackother -- Mods

		return inst
	end

    -----------------------------------------------------------------------------
    -- WAGPUNK HAT

    fns.wagpunk_attach_classified = function(inst, classified)
        inst._classified = classified
        inst.ondetachclassified = function() inst:DetachClassified() end
        inst:ListenForEvent("onremove", inst.ondetachclassified, classified)
    end

    fns.wagpunk_detach_classified = function(inst)
        inst._classified = nil
        inst.ondetachclassified = nil
    end

    fns.wagpunk_onremoveentity = function(inst)
        if inst._classified ~= nil then
            if TheWorld.ismastersim then
                inst._classified:Remove()
                inst._classified = nil
            else
                inst._classified._parent = nil
                inst:RemoveEventCallback("onremove", inst.ondetachclassified, inst._classified)
                inst:DetachClassified()
            end
        end
    end

    fns.wagpunk_killsaytask = function(inst)
        if inst.delaysaytask then
            inst.delaysaytask:Cancel()
            inst.delaysaytask = nil
        end
    end 

    fns.wagpunk_dosayindelay = function(inst, string)
        fns.wagpunk_killsaytask(inst)

        inst.delaysaytask = inst:DoTaskInTime(0.5, function()
            if inst._classified ~= nil then
                inst._classified:Say(string)
            end
        end)
    end

    fns.wagpunk_ondonetalking = function(inst)
        inst.localsounds.SoundEmitter:KillSound("talk")
    end

    fns.wagpunk_ontalk = function(inst)
        local sound = inst._classified ~= nil and inst._classified:GetTalkSound() or nil
        if sound ~= nil then
            inst.localsounds.SoundEmitter:KillSound("talk")
            inst.localsounds.SoundEmitter:PlaySound(sound, "talk")
        end
    end

    fns.wagpunk_custom_init = function(inst)
        inst:AddTag("show_broken_ui")

        inst:AddComponent("talker")
        inst.components.talker.fontsize = 28
        inst.components.talker.font = TALKINGFONT
        inst.components.talker.colour = Vector3(247/255, 196/255, 77/255)
        inst.components.talker.offset = Vector3(0, 120, 0)

        inst.Transform:SetScale(0.8, 0.8, 0.8)
        inst.scrapbook_scale = 0.8

        inst.AttachClassified = fns.wagpunk_attach_classified
        inst.DetachClassified = fns.wagpunk_detach_classified
        inst.OnRemoveEntity   = fns.wagpunk_onremoveentity

        --Dedicated server does not need to spawn the local sound fx
        if not TheNet:IsDedicated() then
            inst.localsounds = CreateEntity()
            inst.localsounds:AddTag("FX")

            --[[Non-networked entity]]
            inst.localsounds.entity:AddTransform()
            inst.localsounds.entity:AddSoundEmitter()
            inst.localsounds.entity:SetParent(inst.entity)
            inst.localsounds:Hide()
            inst.localsounds.persists = false
            inst:ListenForEvent("ontalk", fns.wagpunk_ontalk)
            inst:ListenForEvent("donetalking", fns.wagpunk_ondonetalking)
        end
    end

    local function SpawnSteamFX_Internal(inst, prefab)
        if inst:IsValid() and not (inst.components.health ~= nil and inst.components.health:IsDead()) and not (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen()) then
            inst:AddChild(SpawnPrefab(prefab))
        end
    end

    fns.wagpunk_spawnsteam = function(inst, owner, fx)
        if owner == nil or not owner:IsValid() then return end

        if inst._spawnsteamfx ~= nil then
            inst._spawnsteamfx:Cancel()
            inst._spawnsteamfx = nil
        end
    
        local delay = math.random() * 0.3
    
        inst._spawnsteamfx = owner:DoTaskInTime(delay, SpawnSteamFX_Internal, fx)
    end 

    fns.wagpunk_spawnbufffx = function(inst, owner)
        fns.wagpunk_spawnsteam(inst, owner, "wagpunksteam_hat_up")    
    end

    fns.wagpunk_reset = function(inst)
        if inst._targettask then
            inst._targettask:Cancel()
            inst._targettask = nil
        end 
        inst._potencialtarget = nil

        fns.wagpunk_dosayindelay(inst, STRINGS.WARBIS.STOP)

        local owner = inst.components.inventoryitem.owner
        if owner ~= nil then
            if owner.components.combat ~= nil then
                owner.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.ARMOR_WAGPUNK_HAT_STAGE0)
            end

            fns.wagpunk_spawnsteam(inst, owner, "wagpunksteam_hat_down")

            if owner.SoundEmitter ~= nil then
                owner.SoundEmitter:KillSound("wagpunkambient_hat")
            end
        end

        if inst.fx ~= nil then
            inst.fx.level:set(1)
        end
    end

    fns.wagpunk_setnewtarget = function(inst, target, owner)
        if owner == nil or inst.components.equippable == nil or not target:IsValid() or target.components.health == nil or target.components.health:IsDead() then
            if inst.fx ~= nil then
                inst.fx.level:set(1)
            end

            if owner ~= nil and owner.SoundEmitter ~= nil then
                owner.SoundEmitter:KillSound("wagpunkambient_hat")
            end

            return
        end

        if inst.fx ~= nil then
            inst.fx.level:set(2)
        end

        if inst._targettask then
            inst._targettask:Cancel()
            inst._targettask = nil
        end
        inst._potencialtarget = nil

        if inst and inst.components.targettracker then
            if not inst.components.targettracker:IsTracking(target) then
                inst.components.targettracker:TrackTarget(target)
                fns.wagpunk_spawnbufffx(inst, owner)

                fns.wagpunk_dosayindelay(inst,STRINGS.WARBIS.START)
            end

            local armor = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

            if armor ~= nil and armor.components.targettracker ~= nil and not armor.components.targettracker:HasTarget() then
                armor:SetNewTarget(target, owner)
            end
        end
    end

    fns.wagpunk_playambient = function(owner,level)
        if not owner.SoundEmitter then return end

        if not owner.SoundEmitter:PlayingSound("wagpunkambient_hat") then
            owner.SoundEmitter:PlaySound("rifts3/wagpunk_armor/wagpunk_armor_hat_lp","wagpunkambient_hat")
        end
        owner.SoundEmitter:SetParameter("wagpunkambient_hat", "param00", level)
    end

    fns.wagpunk_OnAttack = function(owner, data)
        if data.target == owner then
            -- Don't track us.
            return
        end

        local hat = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if hat._targettask and hat._potencialtarget == data.target then
            return
        end

        if hat.components.targettracker:IsTracking(data.target) then
            return 
        end

        if hat._targettask then
            hat._targettask:Cancel()
            hat._targettask = nil
        end

        hat._potencialtarget = nil

        if data.target:IsValid() then
            if hat.components.targettracker ~= nil and hat.components.targettracker:HasTarget() then
                hat.components.targettracker:StopTracking(true)
            else
                fns.wagpunk_dosayindelay(hat, STRINGS.WARBIS.NEW)
            end

            if hat.fx ~= nil then
                hat.fx.level:set(2)
            end

            fns.wagpunk_playambient(owner,0)

            hat._potencialtarget = data.target
            hat._targettask = hat:DoTaskInTime(2, hat.SetNewTarget, data.target, owner)
        end
    end

    fns.wagpunk_timecheck = function(inst, targettime, lasttime)
        local STAGE1 = TUNING.ARMORPUNK_STAGE1
        local STAGE2 = TUNING.ARMORPUNK_STAGE2
        local STAGE3 = TUNING.ARMORPUNK_STAGE3
        local owner = inst.components.inventoryitem.owner

        if owner ~= nil then
            local saystring = nil

            if STAGE3 <= targettime and lasttime < STAGE3 then
                if inst.fx ~= nil then
                    inst.fx.level:set(5)
                end

                if owner.components.combat ~= nil then
                    owner.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.ARMOR_WAGPUNK_HAT_STAGE3)
                end
                
                fns.wagpunk_playambient(owner,0.7)
                -- ADD EFFECT 3
                saystring = STRINGS.WARBIS.STAGE3
                fns.wagpunk_spawnbufffx(inst, owner)
    
            elseif STAGE2 <= targettime and lasttime < STAGE2 then
                if inst.fx ~= nil then
                    inst.fx.level:set(4)
                end

                if owner.components.combat ~= nil then
                    owner.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.ARMOR_WAGPUNK_HAT_STAGE2)
                end

                fns.wagpunk_playambient(owner,0.5)
                -- ADD EFFECT 2
                saystring = STRINGS.WARBIS.STAGE2
                fns.wagpunk_spawnbufffx(inst, owner)

            elseif STAGE1 <= targettime and lasttime < STAGE1 then
                if inst.fx ~= nil then
                    inst.fx.level:set(3)
                end

                if owner.components.combat ~= nil then
                    owner.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.ARMOR_WAGPUNK_HAT_STAGE1)
                end

                fns.wagpunk_playambient(owner,0.3)
               -- ADD EFFECT 1
                fns.wagpunk_spawnbufffx(inst, owner)
                saystring = STRINGS.WARBIS.STAGE1

            elseif STAGE1 > targettime and lasttime <= 0 then
                if inst.fx ~= nil then
                    inst.fx.level:set(2)
                end

                fns.wagpunk_spawnbufffx(inst, owner)
                fns.wagpunk_playambient(owner,0)
            end

            if saystring then
                fns.wagpunk_dosayindelay(inst,saystring)
            end
        end
    end

    fns.wagpunk_test = function(inst,target)
        return inst:GetDistanceSqToInst(target) <= TUNING.WAGPUNK_MAXRANGE*TUNING.WAGPUNK_MAXRANGE
    end

    fns.wagpunk_onequip = function(inst, owner)
        _onequip(inst, owner)
        inst:ListenForEvent("onattackother", fns.wagpunk_OnAttack, owner)

        local armor = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

        if armor ~= nil and armor.components.targettracker ~= nil then
            inst.components.targettracker:CloneTargetFrom(armor, TUNING.WAGPUNK_SYNC_TIME)
        end

        if owner and owner.components.combat then
            owner.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.ARMOR_WAGPUNK_HAT_STAGE0)
        end

        inst.fx = SpawnPrefab("wagpunkhat_fx")

        if inst.fx ~= nil then 
            inst.fx:AttachToOwner(owner)
            inst.fx.level:set(1)
        end

        inst._wearer:set(owner)

        inst._classified:SetTarget(owner)
    end

    fns.wagpunk_onunequip = function(inst, owner)
        _onunequip(inst, owner)

        local armor = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

        if armor ~= nil and armor.components.targettracker ~= nil and armor.components.targettracker:IsCloningTarget() then
            armor.components.targettracker:StopTracking()
        end

        inst:RemoveEventCallback("onattackother", fns.wagpunk_OnAttack, owner)

        if inst._targettask then
            inst._targettask:Cancel()
            inst._targettask = nil
        end

        inst._potencialtarget = nil

        if owner ~= nil and owner.components.combat ~= nil then
            owner.components.combat.externaldamagemultipliers:RemoveModifier(inst)
        end

        inst.components.targettracker:StopTracking()

        if owner ~= nil and owner.SoundEmitter ~= nil then
            owner.SoundEmitter:KillSound("wagpunkambient_hat")
        end

        if inst.fx ~= nil then
            inst.fx:Remove()
            inst.fx = nil
        end

        if inst._spawnsteamfx ~= nil then
            inst._spawnsteamfx:Cancel()
            inst._spawnsteamfx = nil
        end

        if inst._classified ~= nil then
            inst._classified:ShutUp()
        end

        fns.wagpunk_killsaytask(inst)

        inst._wearer:set(nil)
    end

    fns.wagpunk_pause = function(inst)
        inst._synch:push()
        fns.wagpunk_dosayindelay(inst,STRINGS.WARBIS.SYNCHING) 
    end

    fns.wagpunk_unpause = function(inst)
        local timetracking = inst.components.targettracker:GetTimeTracking() or 0

        local owner = inst.components.inventoryitem:GetGrandOwner()
        local armor = owner ~= nil and owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

        if armor ~= nil and armor.components.targettracker ~= nil then
            local armor_timetracking = armor.components.targettracker:GetTimeTracking()

            if armor_timetracking ~= nil and armor_timetracking > timetracking then
                inst.components.targettracker:SetTimeTracking(armor_timetracking)
            end
        end

        fns.wagpunk_dosayindelay(inst, STRINGS.WARBIS.SYNCHED)
    end

    fns.wagpunk_trackerstart = function(inst,target)    
        inst._target:set(target)
    end

    fns.wagpunk_trackerstop = function(inst,target)
       inst._target:set(nil)
    end

    fns.OnChangeTargetDirty = function(inst)
        local wearer = inst._wearer:value()

        if wearer == ThePlayer then
            -- This is ThePlayer and there is no target, stop the targeting
            if inst._target:value() == nil then
                ThePlayer:PushEvent("wagpunkui_targetupdate", nil)
            -- ThePlayer is wearing this hat, or it's broken then update the targeting
            elseif inst.replica.inventoryitem:IsHeldBy(wearer) and (inst:HasTag("broken") or inst.replica.equippable:IsEquipped()) then
                wearer:PushEvent("wagpunkui_targetupdate", inst._target:value())
            end
        end
    end

    fns.OnChangeWearerDirty = function(inst)
        if inst._wearer:value() == ThePlayer then
            ThePlayer:PushEvent("wagpunkui_worn",inst)
        elseif ThePlayer ~= nil then
            ThePlayer:PushEvent("wagpunkui_removed",inst)
        end
    end

    local wagpunk_swap_data_broken = { bank = "wagpunkhat", anim = "broken" }

    fns.wagpunk_onbroken = function(inst)
        if inst.components.equippable ~= nil then
            inst:RemoveComponent("equippable")
            inst.AnimState:PlayAnimation("broken")
            inst.components.floater:SetSwapData(wagpunk_swap_data_broken)
            inst:AddTag("broken")
            inst.components.inspectable.nameoverride = "BROKEN_FORGEDITEM"
        end
    end

    fns.wagpunk_onrepaired = function(inst)
        if inst.components.equippable == nil then
            inst:AddComponent("equippable")
            inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
            inst.components.equippable:SetOnEquip(fns.wagpunk_onequip)
            inst.components.equippable:SetOnUnequip(fns.wagpunk_onunequip)
            inst.components.equippable:SetOnEquipToModel(fns.simple_onequiptomodel)
            inst.AnimState:PlayAnimation("anim")
            inst.components.floater:SetSwapData(swap_data)
            inst:RemoveTag("broken")
            inst.components.inspectable.nameoverride = nil
        end
    end

    fns.OnSynchDirty = function(inst)
        if inst._wearer:value() then
            inst._wearer:value():PushEvent("wagpunkui_synch", inst)
        end
    end

    fns.wagpunk = function()
        local inst = simple(fns.wagpunk_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(.75)

        inst:ListenForEvent("targettracker_starttrack",fns.wagpunk_trackerstart)
        inst:ListenForEvent("targettracker_stoptrack",fns.wagpunk_trackerstop)
        
        inst._wearer = net_entity(inst.GUID, "wagpunkhat.wearer", "OnChangeWearerDirty")
        inst._target = net_entity(inst.GUID, "wagpunkhat.target", "OnChangeTargetDirty")
        inst._synch = net_event(inst.GUID, "OnSynchDirty")

        if not TheNet:IsDedicated() then
            inst:ListenForEvent("OnChangeTargetDirty", fns.OnChangeTargetDirty)
            inst:ListenForEvent("OnChangeWearerDirty", fns.OnChangeWearerDirty)
            inst:DoTaskInTime(0, inst.ListenForEvent, "OnSynchDirty", fns.OnSynchDirty)         
        end
        inst._target:set_local(nil)

        if not TheWorld.ismastersim then
            return inst
        end

        inst._classified = SpawnPrefab("wagpunkhat_classified")
        inst._classified.entity:SetParent(inst.entity)
        inst._classified._parent = inst
        inst._classified:SetTarget(nil)

        inst:AddComponent("targettracker")
        inst.components.targettracker:SetOnTimeUpdateFn(fns.wagpunk_timecheck)
        inst.components.targettracker:SetOnResetTarget(fns.wagpunk_reset)
        inst.components.targettracker:SetShouldKeepTrackingFn(fns.wagpunk_test)
        inst.components.targettracker:SetOnPauseFn(fns.wagpunk_pause)
        inst.components.targettracker:SetOnResumeFn(fns.wagpunk_unpause)

        inst.SetNewTarget = fns.wagpunk_setnewtarget 

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_WAGPUNK_HAT, TUNING.ARMOR_WAGPUNK_HAT_ABSORPTION)

        local planardefense = inst:AddComponent("planardefense")
        planardefense:SetBaseDefense(TUNING.ARMOR_WAGPUNK_HAT_PLANAR_DEF)

        inst.components.equippable:SetOnEquip(fns.wagpunk_onequip)
        inst.components.equippable:SetOnUnequip(fns.wagpunk_onunequip)

        MakeForgeRepairable(inst, FORGEMATERIALS.WAGPUNKBITS, fns.wagpunk_onbroken, fns.wagpunk_onrepaired)
        MakeHauntableLaunch(inst)

        return inst
    end

    -----------------------------------------------------------------------------

    fns.scrap_monocle_onequip = function(inst, owner)
        fns.opentop_onequip(inst, owner)

        if owner.isplayer then
            owner:AddCameraExtraDistance(inst, TUNING.SCRAP_MONOCLE_EXTRA_VIEW_DIST)
        end
    end

    fns.scrap_monocle_onunequip = function(inst, owner)
        _onunequip(inst, owner)

        if owner.isplayer then
            owner:RemoveCameraExtraDistance(inst)
        end
    end

    fns.scrap_monocle_custom_init = function(inst)
        inst:AddTag("scrapmonolevision")
    end

    fns.scrap_monocle_dappernessfn = function(inst, owner)
        return inst.dapperness_per_phase[TheWorld.state.phase] or TUNING.DAPPERNESS_TINY
    end

    fns.scrap_monocle = function()
        local inst = simple(fns.scrap_monocle_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(.6)

        if not TheWorld.ismastersim then
            return inst
        end

        -- Here for mod compability.
        inst.dapperness_per_phase = {
            day   =   TUNING.DAPPERNESS_SMALL,
            dusk  =   0,
            night = - TUNING.DAPPERNESS_TINY,
        }

        inst.components.equippable:SetOnEquip(fns.scrap_monocle_onequip)
        inst.components.equippable:SetOnUnequip(fns.scrap_monocle_onunequip)
        inst.components.equippable:SetDappernessFn(fns.scrap_monocle_dappernessfn)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.SCRAP_MONOCLEHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)
        inst.components.fueled.no_sewing = true

        MakeHauntableLaunch(inst)

        return inst
    end

    -----------------------------------------------------------------------------

	fns.scrap_custom_init = function(inst)
		inst:AddTag("junk")
	end

    fns.scrap = function()
		local inst = simple(fns.scrap_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.2)

        if not TheWorld.ismastersim then
            return inst
        end

		inst:AddComponent("armor")
		inst.components.armor:InitCondition(TUNING.ARMOR_SCRAP_HAT, TUNING.ARMOR_SCRAP_HAT_ABSORPTION)

		inst:AddComponent("waterproofer")
		inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        MakeHauntableLaunch(inst)

        return inst
    end

    -----------------------------------------------------------------------------

    fns.inspectacles_signalpulsedirty = function(inst)
        local owner = inst.replica.inventoryitem ~= nil and inst.entity:GetParent() or nil
        if not owner then
            return
        end

        local inspectaclesparticipant = owner.components.inspectaclesparticipant
        if not inspectaclesparticipant then
            return
        end

        inspectaclesparticipant:OnSignalPulse()
    end

    fns.inspectacles_signalleveldirty = function(inst)
        local owner = inst.replica.inventoryitem ~= nil and inst.entity:GetParent() or nil
        if not owner then
            return
        end

        local level = inst.signallevel:value()
        if owner == ThePlayer then
            inst:PushEvent("inventoryitem_updatetooltip")
        end
    end

	fns.inspectacles_refreshicon = function(inst)
		local owner = inst.components.inventoryitem.owner
		inst.components.inventoryitem:ChangeImageName(
			owner and
			owner.components.inspectaclesparticipant and
			owner.components.inspectaclesparticipant:CanCreateGameInWorld() and
			owner.components.skilltreeupdater and
			owner.components.skilltreeupdater:IsActivated("winona_wagstaff_1") and
			inst.signallevel:value() ~= 1 and
			(	inst.fx and inst.fx.ledstate:value() >= 2 and
				"inspectacleshat_equip_signal" or
				"inspectacleshat_signal"
			) or
			nil
		)
	end

    fns.inspectacles_custom_init = function(inst)
        inst:AddTag("inspectaclesvision")
        inst:AddTag("cannotuse")

        inst.signalpulse = net_event(inst.GUID, "inspectacles.signalpulse")
        inst.signallevel = net_tinybyte(inst.GUID, "inspectacles.signallevel", "signalleveldirty")
        if not TheNet:IsDedicated() then
            inst:ListenForEvent("inspectacles.signalpulse", fns.inspectacles_signalpulsedirty)
            inst:ListenForEvent("signalleveldirty", fns.inspectacles_signalleveldirty)
        end
    end

    fns.inspectacles_stopusingitem = function(inst, data)
        local hat = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        if hat ~= nil and data.statename ~= "inspectacles_open" and hat:HasTag("inuse") then
            hat.components.useableitem:StopUsingItem()
        end
    end

    fns.inspectacles_tick_getlevel = function(inst)
        local level = 0
        local owner = inst.components.inventoryitem.owner
        local inspectaclesparticipant = nil
        if owner == nil then
            return level, inspectaclesparticipant
        end
        local inspectaclesparticipant = owner.components.inspectaclesparticipant
        if inspectaclesparticipant == nil then
            return level, inspectaclesparticipant
        end
        local game, puzzle, puzzledata = inspectaclesparticipant:GetSERVERDetails()
        if game ~= nil then
            local hasinspectaclesvision = owner.components.inventory ~= nil and owner.components.inventory:EquipHasTag("inspectaclesvision")
            if hasinspectaclesvision and inspectaclesparticipant:IsParticipantClose() then
                level = 3
            else
                level = 2
            end
        elseif inspectaclesparticipant:IsInCooldown() then
            level = 1
        end
        if level == 3 then
            inst:RemoveTag("cannotuse")
        else
            inst:AddTag("cannotuse")
        end
        return level, inspectaclesparticipant
    end

	fns.inspectacles_onactivate_fx = function(fx, inst, activate)
		if activate then
			fx.activatetask = nil
		else
			fx.deactivatetask = nil
		end
		fx.ledstate:set(
			(not activate and 1) or
			(inst.signallevel:value() >= 3 and 3) or
			2
		)
		fns.inspectacles_refreshicon(inst)
	end

	fns.inspectacles_activate_fx = function(inst)
		if inst.fx then
			if inst.fx.deactivatetask then
				inst.fx.deactivatetask:Cancel()
				inst.fx.deactivatetask = nil
			elseif inst.fx.ledstate:value() < 2 and inst.fx.activatetask == nil then
				inst.fx.activatetask = inst.fx:DoTaskInTime(0.2, fns.inspectacles_onactivate_fx, inst, true)
			end
		end
	end

	fns.inspectacles_deactivate_fx = function(inst)
		if inst.fx then
			if inst.fx.activatetask then
				inst.fx.activatetask:Cancel()
				inst.fx.activatetask = nil
			elseif inst.fx.ledstate:value() >= 2 and inst.fx.deactivatetask == nil then
				inst.fx.deactivatetask = inst.fx:DoTaskInTime(1, fns.inspectacles_onactivate_fx, inst, false)
			end
		end
	end

	fns.inspectacles_setsignallevel = function(inst, level)
		inst.signallevel:set(level)
		if level >= 2 then
			fns.inspectacles_activate_fx(inst)
			if inst.fx and inst.fx.ledstate:value() >= 2 then
				inst.fx.ledstate:set(level >= 3 and 3 or 2)
			end
		else
			fns.inspectacles_deactivate_fx(inst)
		end
		fns.inspectacles_refreshicon(inst)
	end

    fns.inspectacles_tick = function(inst)
        inst.signalpulse:push()
        local level, inspectaclesparticipant = fns.inspectacles_tick_getlevel(inst)
        if inspectaclesparticipant ~= nil and inspectaclesparticipant:IsParticipantClose(PLAYER_CAMERA_SEE_DISTANCE) then
            if inst.fasterupdatetask == nil then
                inst.fasterupdatetask = inst:DoPeriodicTask(0.2, inst.UpdateInspectacles)
            end
        else
            if inst.fasterupdatetask ~= nil then
                inst.fasterupdatetask:Cancel()
                inst.fasterupdatetask = nil
            end
        end
		fns.inspectacles_setsignallevel(inst, level)
    end

    fns.inspectacles_updateinspectacles = function(inst)
        local level = fns.inspectacles_tick_getlevel(inst)
		fns.inspectacles_setsignallevel(inst, level)
    end

	fns.inspectacles_onfindgametask = function(inst, owner)
		inst.inspectacles_findgametask = nil

        local inspectaclesparticipant = owner.components.inspectaclesparticipant
        if inspectaclesparticipant == nil then
            return
        end

		if inst.fx and
			inst.fx.ledstate:value() == 0 and
			inspectaclesparticipant:CanCreateGameInWorld() and
			owner.components.skilltreeupdater and
			owner.components.skilltreeupdater:IsActivated("winona_wagstaff_1")
		then
			inst.fx.ledstate:set(1)
		end

        if not inspectaclesparticipant:CreateNewAndOrShowCurrentGame() then
            -- Reschedule a find.
			inst.inspectacles_findgametask = inst:DoTaskInTime(3, fns.inspectacles_onfindgametask, owner)
            return
        end

        -- NOTES(JBK): We want the signal to happen for all players at once.
        local tick_time = TUNING.SKILLS.WINONA.INSPECTACLES_TICK_TIME
        local current_time = GetTime()
        local sync_delay = math.ceil(current_time / tick_time) * tick_time - current_time
        if inst.inspectacles_ticktask ~= nil then
            inst.inspectacles_ticktask:Cancel()
        end
        inst.inspectacles_ticktask = inst:DoPeriodicTask(tick_time, fns.inspectacles_tick, sync_delay)
    end

    fns.inspectacles_onequip = function(inst, owner)
		_onequip(inst, owner)

		if inst.fx then
			inst.fx:Remove()
		end
		inst.fx = SpawnPrefab("inspectacleshat_fx")
		inst.fx:AttachToOwner(owner)
		if inst.signallevel:value() > 1 then
			fns.inspectacles_activate_fx(inst)
			inst.fx.ledstate:set(1)
		elseif inst.signallevel:value() == 1 then
			inst.fx.ledstate:set(1)
		end

        inst:ListenForEvent("newstate", fns.inspectacles_stopusingitem, owner)

		-- Delay a frame for unsafe load order.
		if inst.inspectacles_findgametask then
			inst.inspectacles_findgametask:Cancel()
		end
		inst.inspectacles_findgametask = inst:DoTaskInTime(0, fns.inspectacles_onfindgametask, owner)
    end

    fns.inspectacles_onunequip = function(inst, owner)
        _onunequip(inst, owner)

		if inst.fx then
			inst.fx:Remove()
			inst.fx = nil
			fns.inspectacles_refreshicon(inst)
		end

        inst:RemoveEventCallback("newstate", fns.inspectacles_stopusingitem, owner)
        if inst:HasTag("inuse") then
            inst.components.useableitem:StopUsingItem()
        end
        inst:AddTag("cannotuse")
        if inst.inspectacles_findgametask ~= nil then
            inst.inspectacles_findgametask:Cancel()
            inst.inspectacles_findgametask = nil
        end
        if inst.inspectacles_ticktask ~= nil then
            inst.inspectacles_ticktask:Cancel()
            inst.inspectacles_ticktask = nil
        end
        if inst.fasterupdatetask ~= nil then
            inst.fasterupdatetask:Cancel()
            inst.fasterupdatetask = nil
        end

        local inspectaclesparticipant = owner.components.inspectaclesparticipant
        if inspectaclesparticipant == nil then
            return
        end

        inspectaclesparticipant:HideCurrentGame()
    end

	fns.inspectacles_toground = function(inst)
		fns.inspectacles_setsignallevel(inst, 0)
	end

    fns.inspectacles_onuse = function(inst)
        local owner = inst.components.inventoryitem.owner
        if owner == nil then
            return false
        end
        local inspectaclesparticipant = owner.components.inspectaclesparticipant
        if inspectaclesparticipant == nil then
            return false
        end
        if not CanEntitySeeTarget(owner, inst) then
            return false
        end
        if not inspectaclesparticipant:IsParticipantClose() then
            return false
        end

        local game, puzzle, puzzledata = inspectaclesparticipant:GetSERVERDetails()
        if inspectaclesparticipant:IsFreeGame(game) then
            inspectaclesparticipant:FinishCurrentGame()
            return true
        end
        owner.sg:GoToState("inspectacles_open")
        owner:ShowPopUp(POPUPS.INSPECTACLES, true)
        return true
    end

    fns.inspectacles_onstopuse = function(inst)
        local owner = inst.components.inventoryitem.owner
        if owner == nil then
            return
        end
        local inspectaclesparticipant = owner.components.inspectaclesparticipant
        if inspectaclesparticipant == nil then
            return
        end

        owner:ShowPopUp(POPUPS.INSPECTACLES, false)
    end

    fns.inspectacles_getstatus = function(inst, viewer)
        if viewer ~= nil and viewer:HasTag("handyperson") then
            local skilltreeupdater = viewer.components.skilltreeupdater
            if skilltreeupdater == nil or not skilltreeupdater:IsActivated("winona_wagstaff_1") then
                return "MISSINGSKILL"
            end
        end

        return nil
    end

    fns.inspectacles = function()
        local inst = simple(fns.inspectacles_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(.6)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.UpdateInspectacles = fns.inspectacles_updateinspectacles

		inst.components.inventoryitem:SetOnPutInInventoryFn(fns.inspectacles_updateinspectacles)
		inst.components.inventoryitem:SetOnDroppedFn(fns.inspectacles_toground)

        inst.components.equippable.restrictedtag = "inspectacleshatuser"
        inst.components.equippable:SetOnEquip(fns.inspectacles_onequip)
        inst.components.equippable:SetOnUnequip(fns.inspectacles_onunequip)

        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(fns.inspectacles_onuse)
        inst.components.useableitem:SetOnStopUseFn(fns.inspectacles_onstopuse)

        MakeHauntableLaunch(inst)

        inst.components.inspectable.getstatus = fns.inspectacles_getstatus

        return inst
    end

	-----------------------------------------------------------------------------

	fns.roseglasses_inspecttarget = function(inst, owner, target)
        if owner.components.roseinspectableuser == nil then
            return false
        end
        return owner.components.roseinspectableuser:TryToDoRoseInspectionOnTarget(target)
	end

	fns.roseglasses_inspectpoint = function(inst, owner, pt)
        if owner.components.roseinspectableuser == nil then
            return false
        end
        return owner.components.roseinspectableuser:TryToDoRoseInspectionOnPoint(pt)
	end

	fns.roseglasses_refreshattunedskills = function(inst, owner)
		if owner and owner.components.skilltreeupdater and owner.components.skilltreeupdater:IsActivated("winona_charlie_1") then
			if inst.components.closeinspector == nil then
				inst:AddComponent("closeinspector")
				inst.components.closeinspector:SetInspectTargetFn(fns.roseglasses_inspecttarget)
				inst.components.closeinspector:SetInspectPointFn(fns.roseglasses_inspectpoint)
			end
            if owner.components.skilltreeupdater:IsActivated("winona_charlie_2") then
                owner:AddTag("wormholetracker")
            end
		else
			inst:RemoveComponent("closeinspector")
		end
	end

	fns.roseglasses_watchskillrefresh = function(inst, owner)
		if inst._owner then
			inst:RemoveEventCallback("onactivateskill_server", inst._onskillrefresh, inst._owner)
			inst:RemoveEventCallback("ondeactivateskill_server", inst._onskillrefresh, inst._owner)
            if owner == nil then
                inst._owner:RemoveTag("wormholetracker")
            end
		end
		inst._owner = owner
		if owner then
			inst:ListenForEvent("onactivateskill_server", inst._onskillrefresh, owner)
			inst:ListenForEvent("ondeactivateskill_server", inst._onskillrefresh, owner)
		end
	end

	fns.roseglasses_onequip = function(inst, owner)
		fns.opentop_onequip(inst, owner)
		fns.roseglasses_watchskillrefresh(inst, owner)
		fns.roseglasses_refreshattunedskills(inst, owner)
	end

	fns.roseglasses_onunequip = function(inst, owner)
		_onunequip(inst, owner)
		fns.roseglasses_watchskillrefresh(inst, nil)
		fns.roseglasses_refreshattunedskills(inst, nil)
	end

	fns.roseglasses_custom_init = function(inst)
        inst:AddTag("roseglassesvision")
		inst:AddTag("open_top_hat")
	end

    fns.roseglasses_getstatus = function(inst, viewer)
        if viewer ~= nil and viewer:HasTag("handyperson") then
            local skilltreeupdater = viewer.components.skilltreeupdater
            if skilltreeupdater == nil or not skilltreeupdater:IsActivated("winona_charlie_1") then
                return "MISSINGSKILL"
            end
        end

        return nil
    end

	fns.roseglasses = function()
		local inst = simple(fns.roseglasses_custom_init)

		inst.components.floater:SetSize("med")
		inst.components.floater:SetScale(0.68)

		if not TheWorld.ismastersim then
			return inst
		end

		inst._onskillrefresh = function(owner) fns.roseglasses_refreshattunedskills(inst, owner) end

		inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
		inst.components.equippable:SetOnEquip(fns.roseglasses_onequip)
		inst.components.equippable:SetOnUnequip(fns.roseglasses_onunequip)
        inst.components.equippable.restrictedtag = "handyperson"

		MakeHauntableLaunch(inst)

        inst.components.inspectable.getstatus = fns.roseglasses_getstatus

		return inst
	end

    -----------------------------------------------------------------------------
    fns.mermarmor_custom_init = function(inst)
        inst:AddTag("mermarmorhat")
    end

    fns.mermarmor_onequip = function(inst, owner)
        if inst:HasTag("open_top_hat") then
            fns.opentop_onequip(inst, owner)
        else
            _onequip(inst, owner)
        end
    end

    fns.mermarmor_onunequip = function(inst, owner)
        _onunequip(inst, owner)
    end

    fns.mermarmor = function()
        local inst = simple(fns.mermarmor_custom_init)

		inst.components.floater:SetScale(.85)
		inst.components.floater:SetVerticalOffset(.05)

		if not TheWorld.ismastersim then
			return inst
		end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_MERMARMORHAT, TUNING.ARMOR_MERMARMORHAT_ABSORPTION)

        inst.components.equippable:SetOnEquip(fns.mermarmor_onequip)
        inst.components.equippable:SetOnUnequip(fns.mermarmor_onunequip)
        inst.components.equippable.restrictedtag = "merm_npc"       

        return inst
    end
    
    -----------------------------------------------------------------------------

    fns.mermarmorupgraded_custom_init = function(inst)
        inst:AddTag("mermarmorupgradedhat")
    end

    fns.mermarmorupgraded_onequip = function(inst, owner)
        if inst:HasTag("open_top_hat") then
            fns.opentop_onequip(inst, owner)
        else
            _onequip(inst, owner)
        end
    end

    fns.mermarmorupgraded_onunequip = function(inst, owner)
        _onunequip(inst, owner)
    end

    fns.mermarmorupgraded = function()
        local inst = simple(fns.mermarmorupgraded_custom_init)        

		inst.components.floater:SetScale(.85)
		inst.components.floater:SetVerticalOffset(.05)

		if not TheWorld.ismastersim then
			return inst
		end

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_MERMARMORUPGRADEDHAT, TUNING.ARMOR_MERMARMORUPGRADEDHAT_ABSORPTION)

        inst.components.equippable:SetOnEquip(fns.mermarmorupgraded_onequip)
        inst.components.equippable:SetOnUnequip(fns.mermarmorupgraded_onunequip)
        inst.components.equippable.restrictedtag = "merm_npc"

        return inst
    end

    -----------------------------------------------------------------------------

    local fn = nil
    local assets = { Asset("ANIM", "anim/"..fname..".zip") }
    local prefabs = nil

    if name == "bee" then
        fn = fns.bee
    elseif name == "straw" then
        fn = fns.straw
    elseif name == "top" then
        fn = fns.top
		prefabs =
		{
			"tophat_container",
			"tophat_shadow_fx",
			"tophat_swirl_fx",
			"tophat_using_shadow_fx",
		}
    elseif name == "feather" then
        fn = fns.feather
    elseif name == "football" then
        fn = fns.football
    elseif name == "flower" then
        fn = fns.flower
    elseif name == "spider" then
        fn = fns.spider
    elseif name == "miner" then
        fn = fns.miner
        prefabs = { "minerhatlight" }
    elseif name == "earmuffs" then
        fn = fns.earmuffs
    elseif name == "winter" then
        fn = fns.winter
    elseif name == "beefalo" then
        fn = fns.beefalo
    elseif name == "bush" then
        fn = fns.bush
    elseif name == "walrus" then
        fn = fns.walrus
    elseif name == "slurtle" then
        fn = fns.slurtle
    elseif name == "ruins" then
        fn = fns.ruins
        prefabs = { "forcefieldfx" }
    elseif name == "mole" then
        fn = fns.mole
    elseif name == "wathgrithr" then
        fn = fns.wathgrithr
    elseif name == "wathgrithr_improved" then
        fn = fns.wathgrithr_improved
    elseif name == "walter" then
        fn = fns.walter
    elseif name == "ice" then
        fn = fns.ice
    elseif name == "rain" then
        fn = fns.rain
    elseif name == "catcoon" then
        fn = fns.catcoon
    elseif name == "watermelon" then
        fn = fns.watermelon
    elseif name == "eyebrella" then
        fn = fns.eyebrella
    elseif name == "red_mushroom" then
        fn = fns.red_mushroom
    elseif name == "green_mushroom" then
        fn = fns.green_mushroom
    elseif name == "blue_mushroom" then
        fn = fns.blue_mushroom
    elseif name == "moon_mushroom" then
        fn = fns.moon_mushroom
    elseif name == "hive" then
        fn = fns.hive
    elseif name == "dragonhead" then
        fn = fns.dragon
    elseif name == "dragonbody" then
        fn = fns.dragon
    elseif name == "dragontail" then
        fn = fns.dragon
    elseif name == "desert" then
        fn = fns.desert
    elseif name == "goggles" then
        fn = fns.goggles
    elseif name == "moonstorm_goggles" then
        fn = fns.moonstorm_goggles
    elseif name == "skeleton" then
        fn = skeleton
    elseif name == "kelp" then
        fn = fns.kelp
    elseif name == "merm" then
        fn = fns.merm
    elseif name == "cookiecutter" then
        fn = fns.cookiecutter
    elseif name == "batnose" then
        fn = fns.batnose
        prefabs = {"hungerregenbuff"}
    elseif name == "nutrientsgoggles" then
        fn = fns.nutrientsgoggles
    elseif name == "plantregistry" then
        fn = fns.plantregistry
	elseif name == "balloon" then
		fn = fns.balloon
        prefabs = { "balloon_pop_head" }
		table.insert(assets, Asset("SCRIPT", "scripts/prefabs/balloons_common.lua"))
	elseif name == "alterguardian" then
        prefabs = {
            "alterguardian_hat_equipped",
            "alterguardianhatlight",
            "alterguardianhat_projectile",
            "alterguardianhatshard",
        }
        table.insert(assets, Asset("ANIM", "anim/ui_alterguardianhat_1x6.zip"))
        fn = fns.alterguardian
    elseif name == "monkey_medium" then
        fn = fns.monkey_medium
    elseif name == "monkey_small" then
        fn = fns.monkey_small
    elseif name == "polly_rogers" then
        prefabs = {"polly_rogers",}
        table.insert(assets, Asset("INV_IMAGE", "polly_rogershat2"))
        fn = fns.polly_rogers
	elseif name == "eyemask" then
        fn = fns.eyemask
    elseif name == "antlion" then
        prefabs = {
            "turf_smoke_fx",
        }
        table.insert(assets, Asset("ANIM", "anim/ui_antlionhat_1x1.zip"))
        fn = fns.antlion
    elseif name == "mask_doll" then
        fn = fns.mask  
    elseif name == "mask_dollbroken" then
        fn = fns.mask
    elseif name == "mask_dollrepaired" then
        fn = fns.mask
    elseif name == "mask_blacksmith" then
        fn = fns.mask
    elseif name == "mask_mirror" then
        fn = fns.mask
    elseif name == "mask_queen" then
        fn = fns.mask
    elseif name == "mask_king" then
        fn = fns.mask
    elseif name == "mask_tree" then
        fn = fns.mask
    elseif name == "mask_fool" then
        fn = fns.mask        
    elseif name == "nightcap" then
        fn = fns.nightcap
    elseif name == "dreadstone" then
    	fn = fns.dreadstone
    elseif name == "lunarplant" then
    	prefabs = { "lunarplanthat_fx" }
    	fn = fns.lunarplant
    elseif name == "voidcloth" then
    	prefabs = { "voidclothhat_fx" }
    	fn = fns.voidcloth
    elseif name == "woodcarved" then
    	fn = fns.woodcarved
    elseif name == "wagpunk" then
        prefabs = { "wagpunkhat_fx", "wagpunksteam_hat_up", "wagpunksteam_hat_down", "wagpunk_bits", "wagpunkhat_classified" }
        table.insert(assets, Asset("ANIM", "anim/firefighter_placement.zip"))
        fn = fns.wagpunk
    elseif name == "scrap_monocle" then
        fn = fns.scrap_monocle
    elseif name == "scrap" then
        fn = fns.scrap
    elseif name == "mermarmor" then
        fn = fns.mermarmor
    elseif name == "mermarmorupgraded" then
        fn = fns.mermarmorupgraded
    elseif name == "inspectacles" then
		prefabs = { "inspectacleshat_fx" }
        fn = fns.inspectacles
        table.insert(assets, Asset("INV_IMAGE", "inspectacleshat_signal"))
		table.insert(assets, Asset("INV_IMAGE", "inspectacleshat_equip_signal"))
	elseif name == "roseglasses" then
		fn = fns.roseglasses
    end

    table.insert(ALL_HAT_PREFAB_NAMES, prefabname)

    return Prefab(prefabname, fn or default, assets, prefabs)
end

local function minerhatlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(2.5)
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function alterguardianhatlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(4)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

--------------------------------------------------------------------------

local function wagpunkhat_CreateFxFollowFrame(i)
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.AnimState:SetBank("wagpunkhat")
    inst.AnimState:SetBuild("hat_wagpunk")
    inst.anim = "idle"..tostring(i)
    inst.AnimState:PlayAnimation(inst.anim, true)

    inst:AddComponent("highlightchild")

    inst.persists = false

    return inst
end

local function wagpunkhat_fx_leveldirty(inst)
    if inst.fx ~= nil then
        if inst.level:value() then
			local bank =
				(inst.level:value() == 5 and "hat_wagpunk_05") or
				(inst.level:value() == 4 and "hat_wagpunk_04") or
				(inst.level:value() == 3 and "hat_wagpunk_03") or
				(inst.level:value() == 2 and "hat_wagpunk_02") or
				"wagpunkhat"

            for i, v in ipairs(inst.fx) do
				v.AnimState:SetBank(bank)
            end
        end
    end

    local owner = inst.entity:GetParent()

    if owner ~= nil then
        owner:PushEvent("wagpunk_changelevel", {level = inst.level:value()})
    end
end

local function wagpunkhat_fx_common_postinit(inst)
    inst.level = net_tinybyte(inst.GUID, "wagpunkhat_fx.level", "wagpunk_leveldirty")
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("wagpunk_leveldirty", wagpunkhat_fx_leveldirty)
    end
end

local function lunarplanthat_CreateFxFollowFrame(i)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst:AddTag("FX")

	inst.AnimState:SetBank("lunarplanthat")
	inst.AnimState:SetBuild("hat_lunarplant")
	inst.AnimState:PlayAnimation("idle"..tostring(i), true)
	inst.AnimState:SetSymbolBloom("glow01")
	inst.AnimState:SetSymbolBloom("float_top")
	inst.AnimState:SetSymbolLightOverride("glow01", .5)
	inst.AnimState:SetSymbolLightOverride("float_top", .5)
	inst.AnimState:SetSymbolMultColour("float_top", 1, 1, 1, .6)
	inst.AnimState:SetLightOverride(.1)

	inst:AddComponent("highlightchild")

	inst.persists = false

	return inst
end

local function voidclothhat_CreateFxFollowFrame(i)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst:AddTag("FX")

	inst.AnimState:SetBank("voidclothhat")
	inst.AnimState:SetBuild("hat_voidcloth")
	inst.anim = "idle"..tostring(i)
	inst.AnimState:PlayAnimation(inst.anim, true)

	inst:AddComponent("highlightchild")

	inst.persists = false

	return inst
end

local function voidclothhat_fx_buffeddirty(inst)
	if inst.fx ~= nil then
		if inst.buffed:value() then
			for i, v in ipairs(inst.fx) do
				local anim = v.anim.."_powerup"
				if not v.AnimState:IsCurrentAnimation(anim) then
					v.AnimState:PlayAnimation(anim.."_pre")
					v.AnimState:PushAnimation(anim)
				end
			end
		else
			for i, v in ipairs(inst.fx) do
				if not v.AnimState:IsCurrentAnimation(v.anim) then
					v.AnimState:PlayAnimation(v.anim.."_powerup_pst")
					v.AnimState:PushAnimation(v.anim)
				end
			end
		end
	end
end

local function voidclothhat_fx_common_postinit(inst)
	inst.buffed = net_bool(inst.GUID, "voidclothhat_fx.buffed", "buffeddirty")
	if not TheNet:IsDedicated() then
		inst:ListenForEvent("buffeddirty", voidclothhat_fx_buffeddirty)
	end
end

local function inspectacleshat_CreateFxFollowFrame(i)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst:AddTag("FX")

	inst.AnimState:SetBank("inspectacleshat")
	inst.AnimState:SetBuild("hat_inspectacles")
	inst.animidx = tostring(i)
	inst.AnimState:PlayAnimation("off"..inst.animidx)
	inst.AnimState:SetSymbolLightOverride("led_on", 0.5)
	inst.AnimState:SetSymbolBloom("led_on")

	inst:AddComponent("highlightchild")

	inst.persists = false

	return inst
end

local function inspectacleshat_fx_SetLedEnabled(inst, enabled)
	if enabled then
		inst.AnimState:OverrideSymbol("led_off", "hat_inspectacles", "led_on")
		inst.AnimState:SetSymbolBloom("led_off")
		inst.AnimState:SetSymbolLightOverride("led_off", 0.5)
		inst.AnimState:SetSymbolLightOverride("inspectacles_toppart", 0.2)
		inst.AnimState:SetSymbolLightOverride("inspectacles_dishpart", 0.1)
		inst.AnimState:SetLightOverride(0.03)
	else
		inst.AnimState:ClearOverrideSymbol("led_off")
		inst.AnimState:ClearSymbolBloom("led_off")
		inst.AnimState:SetSymbolLightOverride("led_off", 0)
		inst.AnimState:SetSymbolLightOverride("inspectacles_toppart", 0)
		inst.AnimState:SetSymbolLightOverride("inspectacles_dishpart", 0)
		inst.AnimState:SetLightOverride(0)
	end
end

local function inspectacleshat_fx_doblink(inst, ison)
	for i, v in ipairs(inst.fx) do
		inspectacleshat_fx_SetLedEnabled(v, ison)
	end
	local delay =
		inst.ledstate:value() == 1 and
		(ison and 0.75 or 1.5) or
		(ison and 0.1 or 0)
	inst.blinktask = inst:DoTaskInTime(delay, inspectacleshat_fx_doblink, not ison)
end

local function inspectacleshat_fx_ledstatedirty(inst)
	if inst.fx then
		if inst.ledstate:value() >= 2 then
			local playsound = false
			for i, v in ipairs(inst.fx) do
				local anim = "activate"..v.animidx
				if not v.AnimState:IsCurrentAnimation(anim) then
					v.AnimState:PlayAnimation(anim)
					playsound = true
				end
				inspectacleshat_fx_SetLedEnabled(v, true)
			end
			if playsound then
				--NOTE: this is local fx on clients
				inst.SoundEmitter:PlaySound("meta4/wires_minigame/inspectacles/activate")
			end
			if inst.ledstate:value() == 2 then
				if inst.blinktask then
					inst.blinktask:Cancel()
					inst.blinktask = nil
				end
			elseif inst.blinktask == nil then
				inspectacleshat_fx_doblink(inst, inst.initledstate or false)
			end
		else
			local playsound = false
			for i, v in ipairs(inst.fx) do
				--deactivated could be "off" or "deactivate", so easier to check that it's not "activate"
				if v.AnimState:IsCurrentAnimation("activate"..v.animidx) then
					v.AnimState:PlayAnimation("deactivate"..v.animidx)
					playsound = true
				end
			end
			if playsound then
				--NOTE: this is local fx on clients
				inst.SoundEmitter:PlaySound("meta4/wires_minigame/inspectacles/deactivate")
			end
			if inst.ledstate:value() == 0 then
				if inst.blinktask then
					inst.blinktask:Cancel()
					inst.blinktask = nil
				end
				for i, v in ipairs(inst.fx) do
					inspectacleshat_fx_SetLedEnabled(v, false)
				end
			elseif inst.blinktask == nil then
				inspectacleshat_fx_doblink(inst, inst.initledstate or false)
			end
		end
	end
	inst.initledstate = nil
end

local function inspectacleshat_fx_common_postinit(inst)
	inst.entity:AddSoundEmitter()

	inst.ledstate = net_tinybyte(inst.GUID, "inspectacleshat_fx.ledstate", "ledstatedirty")
	--0: off
	--1: cooldown; dish down; blink
	--2: on; dish up
	if not TheNet:IsDedicated() then
		inst.initledstate = true
		inst:ListenForEvent("ledstatedirty", inspectacleshat_fx_ledstatedirty)
	end
end

--------------------------------------------------------------------------

local function FollowFx_OnRemoveEntity(inst)
	for i, v in ipairs(inst.fx) do
		v:Remove()
	end
end

local function FollowFx_ColourChanged(inst, r, g, b, a)
	for i, v in ipairs(inst.fx) do
		v.AnimState:SetAddColour(r, g, b, a)
	end
end

local function SpawnFollowFxForOwner(inst, owner, createfn, framebegin, frameend, isfullhelm)
	local follow_symbol = isfullhelm and owner:HasTag("player") and owner.AnimState:BuildHasSymbol("headbase_hat") and "headbase_hat" or "swap_hat"
	inst.fx = {}
	local frame
	for i = framebegin, frameend do        
		local fx = createfn(i)
		frame = frame or math.random(fx.AnimState:GetCurrentAnimationNumFrames()) - 1
		fx.entity:SetParent(owner.entity)
		fx.Follower:FollowSymbol(owner.GUID, follow_symbol, nil, nil, nil, true, nil, i - 1)
		fx.AnimState:SetFrame(frame)
		fx.components.highlightchild:SetOwner(owner)
		table.insert(inst.fx, fx)
	end
	inst.components.colouraddersync:SetColourChangedFn(FollowFx_ColourChanged)
	inst.OnRemoveEntity = FollowFx_OnRemoveEntity
end

local function MakeFollowFx(name, data)
	local function OnEntityReplicated(inst)
		local owner = inst.entity:GetParent()
		if owner ~= nil then
			SpawnFollowFxForOwner(inst, owner, data.createfn, data.framebegin, data.frameend, data.isfullhelm)
		end
	end

	local function AttachToOwner(inst, owner)        
		inst.entity:SetParent(owner.entity)
		if owner.components.colouradder ~= nil then
			owner.components.colouradder:AttachChild(inst)
		end
		--Dedicated server does not need to spawn the local fx
		if not TheNet:IsDedicated() then            
			SpawnFollowFxForOwner(inst, owner, data.createfn, data.framebegin, data.frameend, data.isfullhelm)
		end
	end

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddNetwork()

		inst:AddTag("FX")

		inst:AddComponent("colouraddersync")

		if data.common_postinit ~= nil then
			data.common_postinit(inst)
		end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			inst.OnEntityReplicated = OnEntityReplicated

			return inst
		end

		inst.AttachToOwner = AttachToOwner
		inst.persists = false

		if data.master_postinit ~= nil then
			data.master_postinit(inst)
		end

		return inst
	end

	return Prefab(name, fn, data.assets, data.prefabs)
end

--------------------------------------------------------------------------

local function tophatcontainerfn()
	local inst = CreateEntity()

	inst.entity:AddNetwork()

	inst:AddTag("CLASSIFIED")
	inst:Hide()

	inst:AddComponent("container_proxy")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.components.container_proxy:SetMaster(TheWorld:GetPocketDimensionContainer("shadow"))

	inst.persists = false

	return inst
end

return  MakeHat("straw"),
        MakeHat("top"),
        MakeHat("beefalo"),
        MakeHat("feather"),
        MakeHat("bee"),
        MakeHat("miner"),
        MakeHat("spider"),
        MakeHat("football"),
        MakeHat("earmuffs"),
        MakeHat("winter"),
        MakeHat("bush"),
        MakeHat("flower"),
        MakeHat("walrus"),
        MakeHat("slurtle"),
        MakeHat("ruins"),
        MakeHat("mole"),
        MakeHat("wathgrithr"),
        MakeHat("wathgrithr_improved"),
        MakeHat("walter"),
        MakeHat("ice"),
        MakeHat("rain"),
        MakeHat("catcoon"),
        MakeHat("watermelon"),
        MakeHat("eyebrella"),
        MakeHat("red_mushroom"),
        MakeHat("green_mushroom"),
        MakeHat("blue_mushroom"),
        MakeHat("hive"),
        MakeHat("dragonhead"),
        MakeHat("dragonbody"),
        MakeHat("dragontail"),
        MakeHat("desert"),
        MakeHat("goggles"),
        MakeHat("moonstorm_goggles"),
        MakeHat("skeleton"),
        MakeHat("kelp"),
        MakeHat("merm"),
        MakeHat("cookiecutter"),
        MakeHat("batnose"),
        MakeHat("nutrientsgoggles"),
        MakeHat("plantregistry"),
        MakeHat("balloon"),
        MakeHat("alterguardian"),
        MakeHat("eyemask"),
        MakeHat("antlion"),
        MakeHat("mask_doll"),
        MakeHat("mask_dollbroken"),
        MakeHat("mask_dollrepaired"),
        MakeHat("mask_blacksmith"),
        MakeHat("mask_mirror"),
        MakeHat("mask_queen"),
        MakeHat("mask_king"),
        MakeHat("mask_tree"),
        MakeHat("mask_fool"),
        MakeHat("monkey_medium"),
        MakeHat("monkey_small"),
        MakeHat("polly_rogers"),
        MakeHat("nightcap"),
        MakeHat("woodcarved"),
        MakeHat("dreadstone"),

        MakeHat("lunarplant"),
        MakeHat("voidcloth"),
        MakeHat("wagpunk"),
        MakeHat("moon_mushroom"),
        MakeHat("scrap_monocle"),
        MakeHat("scrap"),
        MakeHat("mermarmor"),
        MakeHat("mermarmorupgraded"),        

        MakeHat("inspectacles"),
		MakeHat("roseglasses"),

		MakeFollowFx("lunarplanthat_fx", {
			createfn = lunarplanthat_CreateFxFollowFrame,
			framebegin = 1,
			frameend = 3,
			isfullhelm = true,
			assets = { Asset("ANIM", "anim/hat_lunarplant.zip") },
		}),
		MakeFollowFx("voidclothhat_fx", {
			createfn = voidclothhat_CreateFxFollowFrame,
			common_postinit = voidclothhat_fx_common_postinit,
			framebegin = 1,
			frameend = 3,
			isfullhelm = true,
			assets = { Asset("ANIM", "anim/hat_voidcloth.zip") },
		}),
        MakeFollowFx("wagpunkhat_fx", {
            createfn = wagpunkhat_CreateFxFollowFrame,
            common_postinit = wagpunkhat_fx_common_postinit,
            framebegin = 1,
            frameend = 3,            
            assets = { Asset("ANIM", "anim/hat_wagpunk.zip"),  
                       Asset("ANIM", "anim/hat_wagpunk_02.zip"),  
                       Asset("ANIM", "anim/hat_wagpunk_03.zip"),  
                       Asset("ANIM", "anim/hat_wagpunk_04.zip"),  
                       Asset("ANIM", "anim/hat_wagpunk_05.zip") },
        }),
		MakeFollowFx("inspectacleshat_fx", {
			createfn = inspectacleshat_CreateFxFollowFrame,
			common_postinit = inspectacleshat_fx_common_postinit,
			framebegin = 1,
			frameend = 3,
			assets = { Asset("ANIM", "anim/hat_inspectacles.zip") },
		}),

        Prefab("minerhatlight", minerhatlightfn),
        Prefab("alterguardianhatlight", alterguardianhatlightfn),

		Prefab("tophat_container", tophatcontainerfn)
