local assets =
{
    Asset("ANIM", "anim/player_ghost_withhat.zip"),
    Asset("ANIM", "anim/ghost_abigail_build.zip"),
    Asset("SOUND", "sound/ghost.fsb"),
}

local brain = require("brains/abigailbrain")

local function Retarget(inst)
    return FindEntity(
        inst,
        20,
        function(guy)
            return inst._playerlink ~= nil
                and inst.components.combat:CanTarget(guy)
                and (guy.components.combat.target == inst._playerlink or
                    inst._playerlink.components.combat.target == guy)
				and guy.components.minigame_participator == nil
        end,
        { "_combat", "_health" },
        { "INLIMBO", "noauradamage" }
    )
end

local function OnAttacked(inst, data)
    if data.attacker == nil then
        inst.components.combat:SetTarget(nil)
    elseif data.attacker == inst._playerlink then
        inst.components.health:SetVal(0)
    elseif not data.attacker:HasTag("noauradamage") then
        inst.components.combat:SetTarget(data.attacker)
    end
end

local function OnDeath(inst)
    inst.components.aura:Enable(false)
end

local function auratest(inst, target)
    if target == inst._playerlink then
        return false
    end

	if target.components.minigame_participator ~= nil then
		return false
	end

    if inst.components.combat.target == target then
        return true
    end

    local leader = inst.components.follower.leader
    if target.components.combat.target ~= nil
        and (target.components.combat.target == inst or
            target.components.combat.target == leader) then
        return true
    end

    if leader ~= nil
        and (leader == target
            or (target.components.follower ~= nil and
                target.components.follower.leader == leader)) then
        return false
    end

    return not target:HasTag("player") and target:HasTag("monster") or target:HasTag("prey")
end

local function updatedamage(inst, phase)
    if phase == "day" then
        inst.components.combat.defaultdamage = .5 * TUNING.ABIGAIL_DAMAGE_PER_SECOND 
    elseif phase == "night" then
        inst.components.combat.defaultdamage = 2 * TUNING.ABIGAIL_DAMAGE_PER_SECOND     
    elseif phase == "dusk" then
        inst.components.combat.defaultdamage = TUNING.ABIGAIL_DAMAGE_PER_SECOND 
    end
end

local LOOT = { "abigail_flower" }

local function refreshcontainer(container)
    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item ~= nil and item.prefab == "abigail_flower" then
            item:Refresh()
        end
    end
end

local function unlink(inst)
    inst._playerlink.abigail = nil
    local inv = inst._playerlink.components.inventory
    refreshcontainer(inv)

    local activeitem = inv:GetActiveItem()
    if activeitem ~= nil and activeitem.prefab == "abigail_flower" then
        activeitem:Refresh()
    end

    for k, v in pairs(inv.opencontainers) do
        refreshcontainer(k.components.container)
    end
end

local function linktoplayer(inst, player)
    inst.components.lootdropper:SetLoot(LOOT)
    inst.persists = false
    inst._playerlink = player
    player.abigail = inst
    player.components.leader:AddFollower(inst)
    for k, v in pairs(player.abigail_flowers) do
        k:Refresh()
    end
    player:ListenForEvent("onremove", unlink, inst)
end

local function AbleToAcceptTest(inst, item)
    return false, item.prefab == "reviver" and "ABIGAILHEART" or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("ghost")
    inst.AnimState:SetBuild("ghost_abigail_build")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")
    inst.AnimState:SetLightOverride(TUNING.GHOST_LIGHT_OVERRIDE)
    --inst.AnimState:SetMultColour(1, 1, 1, .6)

    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("girl")
    inst:AddTag("ghost")
    inst:AddTag("noauradamage")
    inst:AddTag("notraptrigger")
    inst:AddTag("abigail")
    inst:AddTag("NOBLOCK")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    MakeGhostPhysics(inst, 1, .5)

    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(.5)
    inst.Light:SetFalloff(.6)
    inst.Light:Enable(true)
    inst.Light:SetColour(180 / 255, 195 / 255, 225 / 255)

    --It's a loop that's always on, so we can start this in our pristine state
    inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_howl_LP", "howl")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._playerlink = nil

    inst:SetBrain(brain)

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.ABIGAIL_SPEED*.5
    inst.components.locomotor.runspeed = TUNING.ABIGAIL_SPEED
    
    inst:SetStateGraph("SGghost")

    inst:AddComponent("inspectable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ABIGAIL_HEALTH)
    inst.components.health:StartRegen(1, 1)

    inst:AddComponent("combat")
    inst.components.combat.defaultdamage = TUNING.ABIGAIL_DAMAGE_PER_SECOND
    inst.components.combat.playerdamagepercent = TUNING.ABIGAIL_DMG_PLAYER_PERCENT
    inst.components.combat:SetRetargetFunction(3, Retarget)
	inst.components.combat:SetKeepTargetFunction(auratest)

    inst:AddComponent("aura")
    inst.components.aura.radius = 3
    inst.components.aura.tickperiod = 1
    inst.components.aura.ignoreallies = true
    inst.components.aura.auratestfn = auratest

    MakeHauntableGoToState(inst, "haunted", nil, 64 * FRAMES * 1.2)

    inst:AddComponent("lootdropper")
    ------------------
    --Added so you can attempt to give hearts to trigger flavour text when the action fails
    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
	inst.components.follower.keepleaderduringminigame = true

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)

    inst:WatchWorldState("phase", updatedamage)

    updatedamage(inst, TheWorld.state.phase)

    inst.LinkToPlayer = linktoplayer

    return inst
end

return Prefab("abigail", fn, assets)
