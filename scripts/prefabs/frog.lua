local normal_assets =
{
    Asset("ANIM", "anim/frog.zip"),
    Asset("SOUND", "sound/frog.fsb"),
}

local lunar_assets =
{
    Asset("ANIM", "anim/froglunar.zip"),
    Asset("ANIM", "anim/froglunar_build.zip"),
    Asset("SOUND", "sound/frog.fsb"),
}

local normal_prefabs =
{
    "froglegs",
    "frogsplash",
}

local lunar_prefabs =
{
    "froglegs",
}

-----------------------------------------------------------------------------------------------------------------

local LUNARFROG_SCALE = 1.15

local brain = require "brains/frogbrain"

local NORMAL_SOUNDS = {
    attack_spit  = "dontstarve/frog/attack_spit",
    attack_voice = "dontstarve/frog/attack_voice",
    die          = "dontstarve/frog/die",
    grunt        = "dontstarve/frog/grunt",
    walk         = "dontstarve/frog/walk",
    splat        = "dontstarve/frog/splat",
    wake         = "dontstarve/frog/wake",
}

local LUNAR_SOUNDS = {
    attack_spit  = "rifts3/mutated_frog/attack_spit",
    attack_voice = "rifts3/mutated_frog/attack_voice",
    die          = "rifts3/mutated_frog/die",
    grunt        = "rifts3/mutated_frog/grunt",
    walk         = "rifts3/mutated_frog/walk",
    splat        = "rifts3/mutated_frog/splat",
    wake         = "rifts3/mutated_frog/wake",
}

-----------------------------------------------------------------------------------------------------------------

local RETARGET_MUST_TAGS = { "_combat", "_health" }
local RETARGET_CANT_TAGS = { "merm" }
local LUNAR_RETARGET_CANT_TAGS = { "merm", "lunar_aligned" }

local function retargetfn(inst)
	if not inst.components.health:IsDead() and not (inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep()) then
        local target_dist = inst.islunar and TUNING.LUNARFROG_TARGET_DIST or TUNING.FROG_TARGET_DIST
        local cant_tags   = inst.islunar and LUNAR_RETARGET_CANT_TAGS or RETARGET_CANT_TAGS

        return FindEntity(inst, target_dist, function(guy)
            if not guy.components.health:IsDead() then
                return guy.components.inventory ~= nil
            end
        end,
        RETARGET_MUST_TAGS, -- see entityreplica.lua
        cant_tags
        )
    end
end

local function ShouldSleep(inst)
    if inst.components.knownlocations:GetLocation("home") ~= nil then
        return false -- frogs either go to their home, or just sit on the ground.
    end

	-- Homeless frogs will sleep at night.
	return TheWorld.state.isnight
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude) return dude:HasTag("frog") and not dude.components.health:IsDead() end, 5)
end

local function OnGoingHome(inst)
    SpawnPrefab("frogsplash").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function OnHitOther(inst, other, damage, stimuli, weapon, damageresolved, spdamage, damageredirecttarget)
    if inst.islunar then
        if not damageredirecttarget then
            local n = GetRandomMinMax(TUNING.LUNARFROG_ITEMS_TO_STEAL_MIN, TUNING.LUNARFROG_ITEMS_TO_STEAL_MAX)

            for i=1, n do
                inst.components.thief:StealItem(other)
            end
        end

        local grogginess = other.components.grogginess

        -- We don't want to knock out the target.
        if grogginess ~= nil and
            (grogginess.grog_amount + TUNING.LUNARFROG_ONATTACK_GROGGINESS) < grogginess:GetResistance()
        then
            other.components.grogginess:AddGrogginess(TUNING.LUNARFROG_ONATTACK_GROGGINESS)
        end

    elseif not damageredirecttarget then
        inst.components.thief:StealItem(other)
    end
end

local function commonfn(build, common_postinit)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1, .3)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("frog")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("hostile")
    inst:AddTag("smallcreature")
    inst:AddTag("frog")
    inst:AddTag("canbetrapped")

	if common_postinit ~= nil then
		common_postinit(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 8

    -- boat hopping enable.
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:SetStateGraph("SGfrog")

    inst:SetBrain(brain)

    inst:AddComponent("health")

    inst:AddComponent("combat")
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat.onhitotherfn = OnHitOther

    inst:AddComponent("thief")

    MakeTinyFreezableCharacter(inst, "frogsack")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"froglegs"})

    inst:AddComponent("knownlocations")
    inst:AddComponent("inspectable")

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("goinghome", OnGoingHome)

    MakeHauntablePanic(inst)

    return inst
end

local function normalfn()
    local inst = commonfn("frog")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = NORMAL_SOUNDS

	inst:AddComponent("sleeper")
	inst.components.sleeper:SetSleepTest(ShouldSleep)

    inst.components.health:SetMaxHealth(TUNING.FROG_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.FROG_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.FROG_ATTACK_PERIOD)

    return inst
end

local function lunar_common_postinit(inst)
	inst.Transform:SetScale(LUNARFROG_SCALE, LUNARFROG_SCALE, LUNARFROG_SCALE)

	inst:AddTag("lunar_aligned")

	inst.AnimState:SetSymbolLightOverride("flameanim", 0.1)
	inst.AnimState:SetSymbolBloom("flameanim")
	--inst.AnimState:SetSymbolLightOverride("frogeye", 0.1)
	--inst.AnimState:SetSymbolLightOverride("frogeye_back", 0.1)
	--@V2C: can't target the frog eyes because not all anims use the
	--      back comp with individual eye symbols.
end

local function lunarfn()
	local inst = commonfn("froglunar_build", lunar_common_postinit)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = LUNAR_SOUNDS

    inst.islunar = true

    inst:AddComponent("planarentity")

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.LUNARFROG_PLANAR_DAMAGE)

    inst.components.lootdropper:AddChanceLoot("froglegs", TUNING.LUNARFROG_ADDITIONAL_LOOT_CHANCE)

    inst.components.health:SetMaxHealth(TUNING.LUNARFROG_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.LUNARFROG_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.LUNARFROG_ATTACK_PERIOD)

    return inst
end

return
        Prefab("frog",      normalfn, normal_assets, normal_prefabs),
        Prefab("lunarfrog", lunarfn,  lunar_assets,  lunar_prefabs )
