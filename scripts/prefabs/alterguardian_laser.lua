local assets =
{
    Asset("ANIM", "anim/alterguardian_laser_hit_sparks_fx.zip"),
}

local assets_scorch =
{
    Asset("ANIM", "anim/burntground.zip"),
}

local assets_trail =
{
    Asset("ANIM", "anim/lavaarena_staff_smoke_fx.zip"),
}

local prefabs =
{
    "alterguardian_laserscorch",
    "alterguardian_lasertrail",
    "alterguardian_laserhit",
}

local LAUNCH_SPEED = .2
local RADIUS = .7

local function SetLightRadius(inst, radius)
    inst.Light:SetRadius(radius)
end

local function DisableLight(inst)
    inst.Light:Enable(false)
end

local DAMAGE_CANT_TAGS = { "brightmareboss", "brightmare", "playerghost", "INLIMBO", "DECOR", "FX" }
local DAMAGE_ONEOF_TAGS = { "_combat", "pickable", "NPC_workable", "CHOP_workable", "HAMMER_workable", "MINE_workable", "DIG_workable" }
local LAUNCH_MUST_TAGS = { "_inventoryitem" }
local LAUNCH_CANT_TAGS = { "locomotor", "INLIMBO" }

local function DoDamage(inst, targets, skiptoss, skipscorch, scale, scorchscale, hitscale, heavymult, mult, forcelanded)
    inst.task = nil

    local x, y, z = inst.Transform:GetWorldPosition()

    -- First, get our presentation out of the way, since it doesn't change based on the find results.
    if inst.AnimState ~= nil then
		if scale then
			inst.AnimState:SetScale(scale, math.abs(scale))
		end
        inst.AnimState:PlayAnimation("hit_"..tostring(math.random(5)))
        inst:Show()
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)

        inst.Light:Enable(true)
        inst:DoTaskInTime(4 * FRAMES, SetLightRadius, .5)
        inst:DoTaskInTime(5 * FRAMES, DisableLight)

        if not skipscorch and TheWorld.Map:IsPassableAtPoint(x, 0, z, false) then
			local scorch = SpawnPrefab("alterguardian_laserscorch")
			scorch.Transform:SetPosition(x, 0, z)
			if scorchscale then
				scorch.AnimState:SetScale(scorchscale, math.abs(scorchscale))
			end
        end

        local fx = SpawnPrefab("alterguardian_lasertrail")
        fx.Transform:SetPosition(x, 0, z)
        fx:FastForward(GetRandomMinMax(.3, .7))
    else
        inst:DoTaskInTime(2 * FRAMES, inst.Remove)
    end

	--for knockback
	local disttocaster = mult and inst.caster and inst.caster:IsValid() and math.sqrt(inst.caster:GetDistanceSqToPoint(x, y, z)) or nil

	local restoredmg, restorepdp
	if inst.caster and inst.caster:IsValid() then
		if inst.overridedmg then
			restoredmg = inst.caster.components.combat.defaultdamage
			inst.caster.components.combat:SetDefaultDamage(inst.overridedmg)
		end
		if inst.overridepdp then
			restorepdp = inst.caster.components.combat.playerdamagepercent
			inst.caster.components.combat.playerdamagepercent = inst.overridepdp
		end
		inst.caster.components.combat.ignorehitrange = true
	end

	--override the fx's combat damage as well in case it gets used, but no need to restore
	if inst.overridedmg then
		inst.components.combat:SetDefaultDamage(inst.overridedmg)
	end
	if inst.overridepdp then
		inst.components.combat.playerdamagepercent = inst.overridepdp
	end
    inst.components.combat.ignorehitrange = true

	local hitradius = RADIUS * (hitscale or 1)
    for _, v in ipairs(TheSim:FindEntities(x, 0, z, hitradius + 3, nil, DAMAGE_CANT_TAGS, DAMAGE_ONEOF_TAGS)) do
        if not targets[v] and v:IsValid() and
                not (v.components.health ~= nil and v.components.health:IsDead()) then
			local range = hitradius + v:GetPhysicsRadius(.5)
            local dsq_to_laser = v:GetDistanceSqToPoint(x, y, z)
            if dsq_to_laser < range * range then
                v:PushEvent("onalterguardianlasered")

                local isworkable = false
                if v.components.workable ~= nil then
                    local work_action = v.components.workable:GetWorkAction()
                    --V2C: nil action for NPC_workable (e.g. campfires)
                    isworkable =
                        (   work_action == nil and v:HasTag("NPC_workable") ) or
                        (   v.components.workable:CanBeWorked() and
                            (   work_action == ACTIONS.CHOP or
                                work_action == ACTIONS.HAMMER or
                                work_action == ACTIONS.MINE or
                                (   work_action == ACTIONS.DIG and
                                    v.components.spawner == nil and
                                    v.components.childspawner == nil
                                )
                            )
                        )
                end
                if isworkable then
                    targets[v] = true
					v.components.workable:Destroy(inst.caster and inst.caster:IsValid() and inst.caster or inst)

                    -- Completely uproot trees.
                    if v:HasTag("stump") then
                        v:Remove()
                    end
                elseif v.components.pickable ~= nil
                        and v.components.pickable:CanBePicked()
                        and not v:HasTag("intense") then
                    targets[v] = true
					local success, loots = v.components.pickable:Pick(inst)
					if loots then
						for i, v in ipairs(loots) do
							skiptoss[v] = true
							targets[v] = true
							Launch(v, inst, LAUNCH_SPEED)
                        end
                    end
                elseif v.components.combat == nil and v.components.health ~= nil then
                    targets[v] = true
                elseif inst.components.combat:CanTarget(v) then
                    targets[v] = true

					--for knockback
					local strengthmult = mult and ((v.components.inventory and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult) or nil

                    if inst.caster ~= nil and inst.caster:IsValid() then
                        inst.caster.components.combat:DoAttack(v)
						if strengthmult then
							v:PushEvent("knockback", { knocker = inst.caster, radius = disttocaster + hitradius, strengthmult = strengthmult, forcelanded = forcelanded })
						end
                    else
                        inst.components.combat:DoAttack(v)
						if strengthmult then
							v:PushEvent("knockback", { knocker = inst, radius = hitradius, strengthmult = strengthmult, forcelanded = forcelanded })
						end
                    end

                    SpawnPrefab("alterguardian_laserhit"):SetTarget(v)

                    if not v.components.health:IsDead() then
                        if v.components.freezable ~= nil then
                            if v.components.freezable:IsFrozen() then
                                v.components.freezable:Unfreeze()
                            elseif v.components.freezable.coldness > 0 then
                                v.components.freezable:AddColdness(-2)
                            end
                        end
                        if v.components.temperature ~= nil then
                            local maxtemp = math.min(v.components.temperature:GetMax(), 10)
                            local curtemp = v.components.temperature:GetCurrent()
                            if maxtemp > curtemp then
                                v.components.temperature:DoDelta(math.min(10, maxtemp - curtemp))
                            end
                        end
                        if v.components.sanity ~= nil then
                            v.components.sanity:DoDelta(TUNING.GESTALT_ATTACK_DAMAGE_SANITY)
                        end
                    end
                end
            end
        end
    end
    inst.components.combat.ignorehitrange = false
	if inst.caster and inst.caster:IsValid() then
		inst.caster.components.combat.ignorehitrange = false
		if restorepdp then
			inst.caster.components.combat.playerdamagepercent = restorepdp
		end
		if restoredmg then
			inst.caster.components.combat:SetDefaultDamage(restoredmg)
		end
	end

    -- After lasering stuff, try tossing any leftovers around.
	for _, v in ipairs(TheSim:FindEntities(x, 0, z, hitradius + 3, LAUNCH_MUST_TAGS, LAUNCH_CANT_TAGS)) do
        if not skiptoss[v] then
			local range = hitradius + v:GetPhysicsRadius(.5)
            if v:GetDistanceSqToPoint(x, y, z) < range * range then
                if v.components.mine ~= nil then
                    targets[v] = true
                    skiptoss[v] = true
                    v.components.mine:Deactivate()
                end
                if not v.components.inventoryitem.nobounce and v.Physics ~= nil and v.Physics:IsActive() then
                    targets[v] = true
                    skiptoss[v] = true
                    Launch(v, inst, LAUNCH_SPEED)
                end
            end
        end
    end

    -- If the laser hit a boat, do boat stuff!
    local platform_hit = TheWorld.Map:GetPlatformAtPoint(x, 0, z)
    if platform_hit then
        local dsq_to_boat = platform_hit:GetDistanceSqToPoint(x, 0, z)
        if dsq_to_boat < TUNING.GOOD_LEAKSPAWN_PLATFORM_RADIUS then
            platform_hit:PushEvent("spawnnewboatleak", {pt = Vector3(x, 0, z), leak_size = "small_leak", playsoundfx = true})
        end
        platform_hit.components.health:DoDelta(-1 * TUNING.ALTERGUARDIAN_PHASE3_LASERDAMAGE / 10)
    end
end

local function Trigger(inst, delay, targets, skiptoss, skipscorch, scale, scorchscale, hitscale, heavymult, mult, forcelanded)
    if inst.task ~= nil then
        inst.task:Cancel()
        if (delay or 0) > 0 then
			inst.task = inst:DoTaskInTime(delay, DoDamage, targets or {}, skiptoss or {}, skipscorch, scale, scorchscale, hitscale, heavymult, mult, forcelanded)
        else
			DoDamage(inst, targets or {}, skiptoss or {}, skipscorch, scale, scorchscale, hitscale, heavymult, mult, forcelanded)
        end
    end
end

--V2C: Added for daywalker2 due to buggy CC laser damage code.
--     (Damage is different depending on whether .caster is provided or not.)
--     Not worth "fixing" CC atm; as that should be treated as rebalancing.
local function OverrideDamage(inst, damage, playerdamagepercent)
	inst.overridedmg = damage
	inst.overridepdp = playerdamagepercent
end

local function KeepTargetFn()
    return false
end

local function common_fn(isempty)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    if not isempty then
        inst.entity:AddAnimState()
        inst.AnimState:SetBank("alterguardian_laser_hits_sparks")
        inst.AnimState:SetBuild("alterguardian_laser_hit_sparks_fx")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetLightOverride(1)

        inst.entity:AddLight()
        inst.Light:SetIntensity(.6)
        inst.Light:SetRadius(1)
        inst.Light:SetFalloff(.7)
        inst.Light:SetColour(0.1, 0.4, 1.0)
        inst.Light:Enable(false)
    end

    inst:Hide()

    inst:AddTag("notarget")
    inst:AddTag("hostile")

    inst:SetPrefabNameOverride("deerclops")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.ALTERGUARDIAN_PHASE3_LASERDAMAGE)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst.task = inst:DoTaskInTime(0, inst.Remove)
    inst.Trigger = Trigger
	inst.OverrideDamage = OverrideDamage
    inst.persists = false

    return inst
end

local function fn()
    return common_fn(false)
end

local function emptyfn()
    return common_fn(true)
end

local SCORCH_BLUE_FRAMES = 20
local SCORCH_DELAY_FRAMES = 0
local SCORCH_FADE_FRAMES = 5

local function Scorch_OnFadeDirty(inst)
    --V2C: hack alert: using SetHightlightColour to achieve something like OverrideAddColour
    --     (that function does not exist), because we know this FX can never be highlighted!
    if inst._fade:value() > SCORCH_FADE_FRAMES + SCORCH_DELAY_FRAMES then
        local k = (inst._fade:value() - SCORCH_FADE_FRAMES - SCORCH_DELAY_FRAMES) / SCORCH_BLUE_FRAMES
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour(0, 0, k, 0)
    elseif inst._fade:value() >= SCORCH_FADE_FRAMES then
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour()
    else
        local k = inst._fade:value() / SCORCH_FADE_FRAMES
        k = k * k
        inst.AnimState:OverrideMultColour(1, 1, 1, k)
        inst.AnimState:SetHighlightColour()
    end
end

local function Scorch_OnUpdateFade(inst)
    if inst._fade:value() > 1 then
        inst._fade:set_local(inst._fade:value() - 1)
        Scorch_OnFadeDirty(inst)
    elseif TheWorld.ismastersim then
        inst:Remove()
    elseif inst._fade:value() > 0 then
        inst._fade:set_local(0)
        inst.AnimState:OverrideMultColour(1, 1, 1, 0)
    end
end

local function scorchfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("burntground")
    inst.AnimState:SetBank("burntground")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst._fade = net_byte(inst.GUID, "alterguardian_laserscorch._fade", "fadedirty")
    inst._fade:set(SCORCH_BLUE_FRAMES + SCORCH_DELAY_FRAMES + SCORCH_FADE_FRAMES)

    inst:DoPeriodicTask(0, Scorch_OnUpdateFade)
    Scorch_OnFadeDirty(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", Scorch_OnFadeDirty)

        return inst
    end

    inst.Transform:SetRotation(math.random() * 360)
    inst.persists = false

    return inst
end

local function FastForwardTrail(inst, pct)
    if inst._task ~= nil then
        inst._task:Cancel()
    end
    local len = inst.AnimState:GetCurrentAnimationLength()
    pct = math.clamp(pct, 0, 1)
    inst.AnimState:SetTime(len * pct)
    inst._task = inst:DoTaskInTime(len * (1 - pct) + 2 * FRAMES, inst.Remove)
end

local function trailfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("lavaarena_staff_smoke_fx")
    inst.AnimState:SetBuild("lavaarena_staff_smoke_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, 0, 1, 0)
    inst.AnimState:SetMultColour(0, 0, 1, 1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst._task = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)

    inst.FastForward = FastForwardTrail

    return inst
end

local function OnRemoveHit(inst)
    if inst.target ~= nil and inst.target:IsValid() then
        if inst.target.components.colouradder == nil then
            if inst.target.components.freezable ~= nil then
                inst.target.components.freezable:UpdateTint()
            else
                inst.target.AnimState:SetAddColour(0, 0, 0, 0)
            end
        end
        if inst.target.components.bloomer == nil then
            inst.target.AnimState:ClearBloomEffectHandle()
        end
    end
end

local function UpdateHit(inst, target)
    if target:IsValid() then
        local oldflash = inst.flash
        inst.flash = math.max(0, inst.flash - .075)
        if inst.flash > 0 then
            local c = math.min(1, inst.flash)
            if target.components.colouradder ~= nil then
                target.components.colouradder:PushColour(inst, 0, 0, c, 0)
            else
                target.AnimState:SetAddColour(0, 0, c, 0)
            end
            if inst.flash < .3 and oldflash >= .3 then
                if target.components.bloomer ~= nil then
                    target.components.bloomer:PopBloom(inst)
                else
                    target.AnimState:ClearBloomEffectHandle()
                end
            end
            return
        end
    end
    inst:Remove()
end

local function SetTarget(inst, target)
    if inst.inittask ~= nil then
        inst.inittask:Cancel()
        inst.inittask = nil

        inst.target = target
        inst.OnRemoveEntity = OnRemoveHit

        if target.components.bloomer ~= nil then
            target.components.bloomer:PushBloom(inst, "shaders/anim.ksh", -1)
        else
            target.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end
        inst.flash = .8 + math.random() * .4
        inst:DoPeriodicTask(0, UpdateHit, nil, target)
        UpdateHit(inst, target)
    end
end

local function hitfn()
    local inst = CreateEntity()

    inst:AddTag("CLASSIFIED")
    --[[Non-networked entity]]
    inst.persists = false

    inst.SetTarget = SetTarget
    inst.inittask = inst:DoTaskInTime(0, inst.Remove)

    return inst
end

return Prefab("alterguardian_laser", fn, assets, prefabs),
    Prefab("alterguardian_laserempty", emptyfn, assets, prefabs),
    Prefab("alterguardian_laserscorch", scorchfn, assets_scorch),
    Prefab("alterguardian_lasertrail", trailfn, assets_trail),
    Prefab("alterguardian_laserhit", hitfn)
