local assets =
{
    Asset("ANIM", "anim/lighter.zip"),
    Asset("ANIM", "anim/swap_lighter.zip"),
    --Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "lighterfire",
	"channel_absorb_fire_fx",
    "channel_absorb_fire",
    "channel_absorb_smoulder",
    "channel_absorb_embers",
}

--------------------------------------------------------------------------

local SNUFF_ONEOF_TAGS = { "smolder", "fire", "willow_ember" }
local SNUFF_NO_TAGS = { "INLIMBO","snuffed" }
local ABSORB_RANGE = 2.5

local function UpdateSnuff(inst, owner)
	local x, y, z = owner.Transform:GetWorldPosition()
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, ABSORB_RANGE, nil, SNUFF_NO_TAGS, SNUFF_ONEOF_TAGS)) do
		if v:IsValid() and not v:IsInLimbo() then
            local fx = nil
            local giveember = nil
			if v:HasTag("willow_ember") then
                v:AddTag("snuffed")				
                fx = "channel_absorb_embers"
                giveember = true
			elseif v.components.burnable then
				if v.components.burnable:IsBurning() then
					v.components.burnable:Extinguish()                    
                    fx = "channel_absorb_fire"
				elseif v.components.burnable:IsSmoldering() then
					v.components.burnable:SmotherSmolder()
                    fx = "channel_absorb_smoulder"
				end
			end

            if fx then
                owner.SoundEmitter:PlaySound("meta3/willow_lighter/ember_absorb")
                local fxprefab = SpawnPrefab(fx)
                fxprefab.Follower:FollowSymbol(owner.GUID, "swap_object", 56, -40, 0)

                if giveember then
                    v.AnimState:PlayAnimation("idle_pst")
                    v:DoTaskInTime(10*FRAMES,function()
                        if not owner.components.health:IsDead() then
                            owner.components.inventory:GiveItem(v, nil, owner:GetPosition())
                        end
                        v:RemoveTag("snuffed")
                        v.AnimState:PlayAnimation("idle_pre")
                        v.AnimState:PushAnimation("idle_loop",true)
                    end)
                end
            end

		end
	end
end

local function OnStartChanneling(inst, user)
	if inst.snuff_task then
		inst.snuff_task:Cancel()
	end
	inst.snuff_task = inst:DoPeriodicTask(0.3, UpdateSnuff, nil, user)

	user.SoundEmitter:PlaySound("meta3/willow_lighter/lighter_absorb_LP","channel_loop")

	if inst.snuff_fx then
		inst.snuff_fx:KillFX()
	end
	inst.snuff_fx = SpawnPrefab("channel_absorb_fire_fx")
	inst.snuff_fx.Follower:FollowSymbol(user.GUID, "swap_object", 56, -40, 0)
end

local function OnStopChanneling(inst, user)

    user.SoundEmitter:KillSound("channel_loop")
    user.SoundEmitter:PlaySound("meta3/willow_lighter/extinguisher_deactivate")

	if inst.snuff_task then
		inst.snuff_task:Cancel()
		inst.snuff_task = nil
	end
	if inst.snuff_fx then
		inst.snuff_fx:KillFX()
		inst.snuff_fx = nil
	end
end

--------------------------------------------------------------------------

local function applyskillbrightness(inst, value)
    if inst.fires then
        for i,fx in ipairs(inst.fires) do
            fx:SetLightRange(value)
        end
    end
end

--[[local function applyskillfueleffect(inst, value)
	if value ~= 1 then
		inst.components.fueled.rate_modifiers:SetModifier(inst, value, "willowskill")
	else
		inst.components.fueled.rate_modifiers:RemoveModifier(inst, "willowskill")
	end
end]]

local function RefreshAttunedSkills(inst, owner)
	local skilltreeupdater = owner and owner.components.skilltreeupdater or nil
	if skilltreeupdater then
		if skilltreeupdater:IsActivated("willow_attuned_lighter") then
			if inst.components.channelcastable == nil then
				inst:AddComponent("channelcastable")
				inst.components.channelcastable:SetStrafing(false)
				inst.components.channelcastable:SetOnStartChannelingFn(OnStartChanneling)
				inst.components.channelcastable:SetOnStopChannelingFn(OnStopChanneling)
			end
		else
			inst:RemoveComponent("channelcastable")
		end

		applyskillbrightness(inst,
			(skilltreeupdater:IsActivated("willow_lightradius_2") and TUNING.SKILLS.WILLOW_BRIGHTNESS_2) or
			(skilltreeupdater:IsActivated("willow_lightradius_1") and TUNING.SKILLS.WILLOW_BRIGHTNESS_1) or
			1
		)

		--[[applyskillfueleffect(inst,
			(skilltreeupdater:IsActivated("willow_consumption_3") and TUNING.SKILLS.WILLOW_CONSUMPTION_3) or
			(skilltreeupdater:IsActivated("willow_consumption_2") and TUNING.SKILLS.WILLOW_CONSUMPTION_2) or
			(skilltreeupdater:IsActivated("willow_consumption_1") and TUNING.SKILLS.WILLOW_CONSUMPTION_1) or
			1
		)]]
	else
		if owner then --don't need to remove when unequipped, less garbage
			inst:RemoveComponent("channelcastable")
		end
		applyskillbrightness(inst, 1)
		--applyskillfueleffect(inst, 1)
	end
end

local function WatchSkillRefresh(inst, owner)
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

local function onequip(inst, owner)
    inst.components.burnable:Ignite()

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_lighter", inst.GUID, "swap_lighter")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_lighter", "swap_lighter")
    end

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.SoundEmitter:PlaySound("dontstarve/wilson/lighter_on")

    if inst.fires == nil then
        inst.fires = {}

        for i, fx_prefab in ipairs(inst:GetSkinName() == nil and { "lighterfire" } or SKIN_FX_PREFAB[inst:GetSkinName()] or {}) do
            local fx = SpawnPrefab(fx_prefab)
            fx.entity:SetParent(owner.entity)
            fx.entity:AddFollower()
            fx.Follower:FollowSymbol(owner.GUID, "swap_object", fx.fx_offset_x, fx.fx_offset_y, 0)
            fx:AttachLightTo(owner)

            table.insert(inst.fires, fx)
        end
    end

	WatchSkillRefresh(inst, owner)
	RefreshAttunedSkills(inst, owner)
end

local function onunequip(inst,owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    if inst.fires ~= nil then
        for i, fx in ipairs(inst.fires) do
            fx:Remove()
        end
        inst.fires = nil
    end

    inst.components.burnable:Extinguish()
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.SoundEmitter:PlaySound("dontstarve/wilson/lighter_off")

	WatchSkillRefresh(inst, nil)
	RefreshAttunedSkills(inst, nil)
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.fires ~= nil then
        for i, fx in ipairs(inst.fires) do
            fx:Remove()
        end
        inst.fires = nil
    end

    inst.components.burnable:Extinguish()
end

local function onpocket(inst, owner)
    inst.components.burnable:Extinguish()
end

local function onattack(weapon, attacker, target)
    --target may be killed or removed in combat damage phase
	if target and target:IsValid() and target.components.burnable and (
		attacker.components.skilltreeupdater and attacker.components.skilltreeupdater:IsActivated("willow_controlled_burn_1") or
		math.random() < TUNING.LIGHTER_ATTACK_IGNITE_PERCENT * target.components.burnable.flammability
	) then
        target.components.burnable:Ignite(nil, attacker)
    end
end

local function onupdatefueledraining(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    inst.components.fueled.rate =
        owner ~= nil and
		(owner.components.sheltered ~= nil and owner.components.sheltered.sheltered or owner.components.rainimmunity ~= nil) and
        1 or 1 + TUNING.LIGHTER_RAIN_RATE * TheWorld.state.precipitationrate
end

local function onisraining(inst, israining)
    if inst.components.fueled ~= nil then
        if israining then
            inst.components.fueled:SetUpdateFn(onupdatefueledraining)
            onupdatefueledraining(inst)
        else
            inst.components.fueled:SetUpdateFn()
            inst.components.fueled.rate = 1
        end
    end
end

local function onfuelchange(newsection, oldsection, inst)
    if newsection <= 0 then
        --when we burn out
        if inst.components.burnable ~= nil then
            inst.components.burnable:Extinguish()
        end
        local equippable = inst.components.equippable
        if equippable ~= nil and equippable:IsEquipped() then
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            if owner ~= nil then
                local data =
                {
                    prefab = inst.prefab,
                    equipslot = equippable.equipslot,
                    announce = "ANNOUNCE_TORCH_OUT",
                }
                inst:Remove()
                owner:PushEvent("itemranout", data)
                return
            end
        end
        inst:Remove()
    end
end

local function oncook(inst, product, chef)
    if not chef:HasTag("expertchef") then
        --burn
        if chef.components.health ~= nil then
            chef.components.health:DoFireDamage(5, inst, true)
            chef:PushEvent("burnt")
        end
        if inst.components.fueled ~= nil then
            inst.components.fueled:DoDelta(-.05 * inst.components.fueled.maxfuel)
        end
    elseif inst.components.fueled ~= nil then
        inst.components.fueled:DoDelta(-.01 * inst.components.fueled.maxfuel)
    end
end

local function OnRemoveEntity(inst)
	if inst.snuff_fx then
		inst.snuff_fx:KillFX()
		inst.snuff_fx = nil
	end
end

local function ontakefuel(inst)
   inst.SoundEmitter:PlaySound("meta3/willow_lighter/ember_absorb")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lighter")
    inst.AnimState:SetBuild("lighter")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("lighter.png")

    inst:AddTag("dangerouscooker")
    inst:AddTag("wildfireprotected")

    --lighter (from lighter component) added to pristine state for optimization
    inst:AddTag("lighter")

    --cooker (from cooker component) added to pristine state for optimization
    inst:AddTag("cooker")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "small", 0.05, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.LIGHTER_DAMAGE)
    inst.components.weapon:SetOnAttack(onattack)

    -----------------------------------
    inst:AddComponent("lighter")
    -----------------------------------
    inst:AddComponent("inventoryitem")
    -----------------------------------
    inst:AddComponent("cooker")
    inst.components.cooker.oncookfn = oncook
    -----------------------------------

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnPocket(onpocket)
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    -----------------------------------

    inst:AddComponent("inspectable")

    -----------------------------------

    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil

    inst:AddComponent("fueled")
    inst.components.fueled:SetSectionCallback(onfuelchange)
    inst.components.fueled:InitializeFuelLevel(TUNING.LIGHTER_FUEL)
    inst.components.fueled:SetDepletedFn(inst.Remove)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    inst.components.fueled.fueltype = FUELTYPE.LIGHTER
    inst.components.fueled.accepting = true
    inst.components.fueled:SetTakeFuelFn(ontakefuel)

	inst._onskillrefresh = function(owner) RefreshAttunedSkills(inst, owner) end

    inst:WatchWorldState("israining", onisraining)
    onisraining(inst, TheWorld.state.israining)

    MakeHauntableLaunch(inst)

	inst.OnRemoveEntity = OnRemoveEntity

    return inst
end

return Prefab("lighter", fn, assets, prefabs)
