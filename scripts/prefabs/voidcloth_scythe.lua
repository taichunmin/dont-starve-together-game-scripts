local assets =
{
    Asset("ANIM", "anim/scythe_voidcloth.zip"),
}

local prefabs =
{
    "voidcloth_scythe_fx",
    "hitsparks_fx",

    "voidcloth_scythe_classified",
}

local function AttachClassified(inst, classified)
    inst._classified = classified
    inst.ondetachclassified = function() inst:DetachClassified() end
    inst:ListenForEvent("onremove", inst.ondetachclassified, classified)
end

local function DetachClassified(inst)
    inst._classified = nil
    inst.ondetachclassified = nil
end

local function OnRemoveEntity(inst)
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

--------------------------------------------------------------------------

local function ondonetalking(inst)
    inst.localsounds.SoundEmitter:KillSound("talk")
end

local function ontalk(inst)
    local sound = inst._classified ~= nil and inst._classified:GetTalkSound() or nil
    if sound ~= nil then
        inst.localsounds.SoundEmitter:KillSound("talk")
        inst.localsounds.SoundEmitter:PlaySound(sound, "talk")
    end
end

--------------------------------------------------------------------------

local function SetBuffEnabled(inst, enabled)
	if enabled then
		if not inst._bonusenabled then
			inst._bonusenabled = true
			if inst.components.weapon ~= nil then
				inst.components.weapon:SetDamage(TUNING.VOIDCLOTH_SCYTHE_DAMAGE * TUNING.WEAPONS_VOIDCLOTH_SETBONUS_DAMAGE_MULT)
			end
			inst.components.planardamage:AddBonus(inst, TUNING.WEAPONS_VOIDCLOTH_SETBONUS_PLANAR_DAMAGE, "setbonus")
		end
	elseif inst._bonusenabled then
		inst._bonusenabled = nil
		if inst.components.weapon ~= nil then
			inst.components.weapon:SetDamage(TUNING.VOIDCLOTH_SCYTHE_DAMAGE)
		end
		inst.components.planardamage:RemoveBonus(inst, "setbonus")
	end
end

local function SetBuffOwner(inst, owner)
	if inst._owner ~= owner then
		if inst._owner ~= nil then
			inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
			inst:RemoveEventCallback("unequip", inst._onownerunequip, inst._owner)
			inst._onownerequip = nil
			inst._onownerunequip = nil
			SetBuffEnabled(inst, false)
		end
		inst._owner = owner
		if owner ~= nil then
			inst._onownerequip = function(owner, data)
				if data ~= nil then
					if data.item ~= nil and data.item.prefab == "voidclothhat" then
						SetBuffEnabled(inst, true)
					elseif data.eslot == EQUIPSLOTS.HEAD then
						SetBuffEnabled(inst, false)
					end
				end
			end
			inst._onownerunequip  = function(owner, data)
				if data ~= nil and data.eslot == EQUIPSLOTS.HEAD then
					SetBuffEnabled(inst, false)
				end
			end
			inst:ListenForEvent("equip", inst._onownerequip, owner)
			inst:ListenForEvent("unequip", inst._onownerunequip, owner)

			local hat = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
			if hat ~= nil and hat.prefab == "voidclothhat" then
				SetBuffEnabled(inst, true)
			end
		end
	end
end

local function SetFxOwner(inst, owner)
	if inst._fxowner ~= nil and inst._fxowner.components.colouradder ~= nil then
		inst._fxowner.components.colouradder:DetachChild(inst.fx)
	end
	inst._fxowner = owner
    if owner ~= nil then
        inst.fx.entity:SetParent(owner.entity)
        inst.fx.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true, nil, 2)
        inst.fx.components.highlightchild:SetOwner(owner)
        inst.fx:ToggleEquipped(true)
		if owner.components.colouradder ~= nil then
			owner.components.colouradder:AttachChild(inst.fx)
		end
    else
        inst.fx.entity:SetParent(inst.entity)
        --For floating
        inst.fx.Follower:FollowSymbol(inst.GUID, "swap_spear", nil, nil, nil, true, nil, 2)
        inst.fx.components.highlightchild:SetOwner(inst)
        inst.fx:ToggleEquipped(false)
    end
end

local function PushIdleLoop(inst)
	if inst.components.finiteuses:GetUses() > 0 then
		inst.AnimState:PushAnimation("idle")
	else
		inst.AnimState:PlayAnimation("broken")
	end
end

local function OnStopFloating(inst)
    inst.fx.AnimState:SetFrame(0)
    inst:DoTaskInTime(0, PushIdleLoop) --#V2C: #HACK restore the looping anim, timing issues
end

local function SayRandomLine(inst, str_list, owner)
    if owner:HasTag("player_shadow_aligned") and inst._classified ~= nil then
        inst._classified:Say(str_list, math.random(#str_list))

        if inst.talktask ~= nil then
            inst.talktask:Cancel()
            inst.talktask = nil
        end

        local iswoodie = owner ~= nil and owner:HasTag("woodcutter")
        local str_list = iswoodie and math.random() > 0.7 and STRINGS.VOIDCLOTH_SCYTHE_TALK.lucy or STRINGS.VOIDCLOTH_SCYTHE_TALK.overtime

        inst.talktask = inst:DoTaskInTime(TUNING.VOIDCLOTH_SCYTHE_TALK_INTERVAL, inst.SayRandomLine, str_list, owner)
    end
end

local function ToggleTalking(inst, turnon, owner)
    if inst.talktask ~= nil then
        inst.talktask:Cancel()
        inst.talktask = nil
    end

    if turnon and owner:HasTag("player_shadow_aligned") then
        inst._classified:SetTarget(owner)
        inst.talktask = inst:DoTaskInTime(TUNING.VOIDCLOTH_SCYTHE_TALK_INITIAL_INTERVAL, inst.SayRandomLine, STRINGS.VOIDCLOTH_SCYTHE_TALK.overtime, owner)
    end
end

local function OnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_scythe", inst.GUID, "scythe_voidcloth")
    else
        owner.AnimState:OverrideSymbol("swap_object", "scythe_voidcloth", "swap_scythe")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    SetFxOwner(inst, owner)
	SetBuffOwner(inst, owner)

    inst:ToggleTalking(true, owner)
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
    SetFxOwner(inst, nil)
	SetBuffOwner(inst, nil)

    inst:ToggleTalking(false, owner)
end

local function HarvestPickable(inst, ent, doer)
    if ent.components.pickable.picksound ~= nil then
        doer.SoundEmitter:PlaySound(ent.components.pickable.picksound)
    end

    local success, loot = ent.components.pickable:Pick(TheWorld)

    if loot ~= nil then
        for i, item in ipairs(loot) do
            Launch(item, doer, 1.5)
        end
    end
end

local function IsEntityInFront(inst, entity, doer_rotation, doer_pos)
    local facing = Vector3(math.cos(-doer_rotation / RADIANS), 0 , math.sin(-doer_rotation / RADIANS))

    return IsWithinAngle(doer_pos, facing, TUNING.VOIDCLOTH_SCYTHE_HARVEST_ANGLE_WIDTH, entity:GetPosition())
end

local HARVEST_MUSTTAGS  = {"pickable"}
local HARVEST_CANTTAGS  = {"INLIMBO", "FX"}
local HARVEST_ONEOFTAGS = {"plant", "lichen", "oceanvine", "kelp"}

local function DoScythe(inst, target, doer)
    inst:SayRandomLine(STRINGS.VOIDCLOTH_SCYTHE_TALK.onharvest, doer)

    if target.components.pickable ~= nil then
        local doer_pos = doer:GetPosition()
        local x, y, z = doer_pos:Get()

        local doer_rotation = doer.Transform:GetRotation()

        local ents = TheSim:FindEntities(x, y, z, TUNING.VOIDCLOTH_SCYTHE_HARVEST_RADIUS, HARVEST_MUSTTAGS, HARVEST_CANTTAGS, HARVEST_ONEOFTAGS)
        for _, ent in pairs(ents) do
            if ent:IsValid() and ent.components.pickable ~= nil then
                if inst:IsEntityInFront(ent, doer_rotation, doer_pos) then
                    inst:HarvestPickable(ent, doer)
                end
            end
        end
    end
end

local hitsparks_fx_colouroverride = {1, 0, 0}
local function OnAttack(inst, attacker, target)
    if target ~= nil and target:IsValid() then
        local spark = SpawnPrefab("hitsparks_fx")
        spark:Setup(attacker, target, nil, hitsparks_fx_colouroverride)
        spark.black:set(true)
    end
end

local function SetupComponents(inst)
	inst:AddComponent("equippable")
	inst.components.equippable.dapperness = -TUNING.DAPPERNESS_MED
	inst.components.equippable.is_magic_dapperness = true
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(inst._bonusenabled and TUNING.VOIDCLOTH_SCYTHE_DAMAGE * TUNING.WEAPONS_VOIDCLOTH_SETBONUS_DAMAGE_MULT or TUNING.VOIDCLOTH_SCYTHE_DAMAGE)
	inst.components.weapon:SetOnAttack(OnAttack)

	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.SCYTHE)
end

local function DisableComponents(inst)
	inst:RemoveComponent("equippable")
	inst:RemoveComponent("weapon")
    inst:RemoveComponent("tool")
end

local FLOAT_SCALE_BROKEN = { 0.8, 0.4, 0.8 }
local FLOAT_SCALE = { 1.2, 0.4, 1.2 }

local function OnIsBrokenDirty(inst)
	if inst.isbroken:value() then
		inst.components.floater:SetSize("med")
		inst.components.floater:SetVerticalOffset(0.25)
		inst.components.floater:SetScale(FLOAT_SCALE_BROKEN)
	else
		inst.components.floater:SetSize("med")
		inst.components.floater:SetVerticalOffset(0)
		inst.components.floater:SetScale(FLOAT_SCALE)
	end
end

local SWAP_DATA_BROKEN = { sym_build = "scythe_voidcloth", sym_name = "scythe_base_broken_float", bank = "scythe_voidcloth", anim = "broken" }
local SWAP_DATA = { sym_build = "scythe_voidcloth", sym_name = "swap_scythe", bank = "scythe_voidcloth" }

local function SetIsBroken(inst, isbroken)
	if isbroken then
		inst.components.floater:SetBankSwapOnFloat(true, -10, SWAP_DATA_BROKEN)
		if inst.fx ~= nil then
			inst.fx:Hide()
		end
	else
		inst.components.floater:SetBankSwapOnFloat(true, -20, SWAP_DATA)
		if inst.fx ~= nil then
			inst.fx:Show()
		end
	end
	inst.isbroken:set(isbroken)
	OnIsBrokenDirty(inst)
end

local function OnBroken(inst)
	if inst.components.equippable ~= nil then
		DisableComponents(inst)
		inst.AnimState:PlayAnimation("broken")
		SetIsBroken(inst, true)
		inst:AddTag("broken")
		inst.components.inspectable.nameoverride = "BROKEN_FORGEDITEM"
	end
end

local function OnRepaired(inst)
	if inst.components.equippable == nil then
		SetupComponents(inst)
		inst.fx.AnimState:SetFrame(0)
		inst.AnimState:PlayAnimation("idle", true)
		SetIsBroken(inst, false)
		inst:RemoveTag("broken")
		inst.components.inspectable.nameoverride = nil
	end
end

local function ScytheFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("scythe_voidcloth")
    inst.AnimState:SetBuild("scythe_voidcloth")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AttachClassified = AttachClassified
    inst.DetachClassified = DetachClassified
    inst.OnRemoveEntity   = OnRemoveEntity

    inst:AddTag("sharp")
	inst:AddTag("show_broken_ui")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --shadowlevel (from shadowlevel component) added to pristine state for optimization
    inst:AddTag("shadowlevel")

    inst:AddTag("shadow_item")

	inst:AddComponent("floater")
	inst.isbroken = net_bool(inst.GUID, "voidcloth_scythe.isbroken", "isbrokendirty")
	SetIsBroken(inst, false)

    local talker = inst:AddComponent("talker")
    talker.fontsize = 28
    talker.font = TALKINGFONT
    talker.colour = Vector3(143/255, 41/255, 41/255)
    talker.offset = Vector3(0, 0, 0)
    talker.symbol = "swap_object"

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
        inst:ListenForEvent("ontalk", ontalk)
        inst:ListenForEvent("donetalking", ondonetalking)
    end

    inst.scrapbook_specialinfo = "VOIDCLITHSCYTHE"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		inst:ListenForEvent("isbrokendirty", OnIsBrokenDirty)

        return inst
    end

    inst._classified = SpawnPrefab("voidcloth_scythe_classified")
    inst._classified.entity:SetParent(inst.entity)
    inst._classified._parent = inst
    inst._classified:SetTarget(nil)

    local frame = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1
    inst.AnimState:SetFrame(frame)
    --V2C: one networked fx for frame 3 (needed for floating)
    --     all other frames will be spawned locally client-side by this fx
    inst.fx = SpawnPrefab("voidcloth_scythe_fx")
    inst.fx.AnimState:SetFrame(frame)
    SetFxOwner(inst, nil)
    inst:ListenForEvent("floater_stopfloating", OnStopFloating)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    local finiteuses = inst:AddComponent("finiteuses")
    finiteuses:SetMaxUses(TUNING.VOIDCLOTH_SCYTHE_USES)
    finiteuses:SetUses(TUNING.VOIDCLOTH_SCYTHE_USES)
    finiteuses:SetConsumption(ACTIONS.SCYTHE, 1)

    local planardamage = inst:AddComponent("planardamage")
    planardamage:SetBaseDamage(TUNING.VOIDCLOTH_SCYTHE_PLANAR_DAMAGE)

    local damagetypebonus = inst:AddComponent("damagetypebonus")
    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WEAPONS_VOIDCLOTH_VS_LUNAR_BONUS)

	SetupComponents(inst)

    inst:AddComponent("shadowlevel")
    inst.components.shadowlevel:SetDefaultLevel(TUNING.VOIDCLOTH_SCYTHE_SHADOW_LEVEL)

	MakeForgeRepairable(inst, FORGEMATERIALS.VOIDCLOTH, OnBroken, OnRepaired)
    MakeHauntableLaunch(inst)

    inst.SayRandomLine = SayRandomLine
    inst.ToggleTalking = ToggleTalking
    inst.DoScythe = DoScythe
    inst.IsEntityInFront = IsEntityInFront
    inst.HarvestPickable = HarvestPickable

    return inst
end

--------------------------------------------------------------------------

local FX_DEFS =
{
    { anim = "swap_loop_1", frame_begin = 0, frame_end = 2 },
    --{ anim = "swap_loop_3", frame_begin = 2 },
    { anim = "swap_loop_6", frame_begin = 5 },
    { anim = "swap_loop_7", frame_begin = 6 },
    { anim = "swap_loop_8", frame_begin = 7 },
}

local function CreateFxFollowFrame()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.AnimState:SetBank("scythe_voidcloth")
    inst.AnimState:SetBuild("scythe_voidcloth")

    inst:AddComponent("highlightchild")

    inst.persists = false

    return inst
end

local function FxRemoveAll(inst)
    for i = 1, #inst.fx do
        inst.fx[i]:Remove()
        inst.fx[i] = nil
    end
end

local function FxColourChanged(inst, r, g, b, a)
	for i = 1, #inst.fx do
		inst.fx[i].AnimState:SetAddColour(r, g, b, a)
	end
end

local function FxOnEquipToggle(inst)
    local owner = inst.equiptoggle:value() and inst.entity:GetParent() or nil
    if owner ~= nil then
        if inst.fx == nil then
            inst.fx = {}
        end
        local frame = inst.AnimState:GetCurrentAnimationFrame()
        for i, v in ipairs(FX_DEFS) do
            local fx = inst.fx[i]
            if fx == nil then
                fx = CreateFxFollowFrame()
                fx.AnimState:PlayAnimation(v.anim, true)
                inst.fx[i] = fx
            end
            fx.entity:SetParent(owner.entity)
            fx.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true, nil, v.frame_begin, v.frame_end)
            fx.AnimState:SetFrame(frame)
            fx.components.highlightchild:SetOwner(owner)
        end
        inst.components.colouraddersync:SetColourChangedFn(FxColourChanged)
        inst.OnRemoveEntity = FxRemoveAll
    elseif inst.OnRemoveEntity ~= nil then
        inst.OnRemoveEntity = nil
		inst.components.colouraddersync:SetColourChangedFn(nil)
        FxRemoveAll(inst)
    end
end

local function FxToggleEquipped(inst, equipped)
    if equipped ~= inst.equiptoggle:value() then
        inst.equiptoggle:set(equipped)
        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            FxOnEquipToggle(inst)
        end
    end
end

local function FollowSymbolFxFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("scythe_voidcloth")
    inst.AnimState:SetBuild("scythe_voidcloth")
    inst.AnimState:PlayAnimation("swap_loop_3", true) --frame 3 is used for floating

    inst:AddComponent("highlightchild")
	inst:AddComponent("colouraddersync")

    inst.equiptoggle = net_bool(inst.GUID, "voidcloth_scythe_fx.equiptoggle", "equiptoggledirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("equiptoggledirty", FxOnEquipToggle)
        return inst
    end

    inst.ToggleEquipped = FxToggleEquipped
    inst.persists = false

    return inst
end

return
        Prefab("voidcloth_scythe",    ScytheFn,         assets, prefabs),
        Prefab("voidcloth_scythe_fx", FollowSymbolFxFn, assets)