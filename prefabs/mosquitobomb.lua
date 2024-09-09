local assets =
{
    Asset("ANIM", "anim/mosquitobomb.zip"),
    Asset("ANIM", "anim/swap_mosquitobomb.zip"),
}

local prefabs =
{
    "mosquito",
    "reticule",
    "reticuleaoe",
    "reticuleaoeping",
}

----------------------------------------------------------------------------------------------------------------------------------------------

local TARGET_MAX_DIST = 15
local SKILL_ADDITIONAL_MOSQUITOS = 2

local TARGET_CANT_TAGS  = { "INLIMBO", "invisible", "notarget", "noattack", "playerghost", "mosquito" }
local TARGET_ONEOF_TAGS = { "character", "animal", "monster" }

local THROWN_SOUNDNAME = "toss"
local IDLE_SOUNDNAME = "idle"

local function IsMosquitoMusk(item)
    return item:HasTag("mosquitomusk")
end

local function SpawnMosquitos(inst, attacker)
    local x, y, z = inst.Transform:GetWorldPosition()

    local x, y, z = inst.Transform:GetWorldPosition()
    local targets = TheSim:FindEntities(x, 0, z, TARGET_MAX_DIST, nil, TARGET_CANT_TAGS, TARGET_ONEOF_TAGS)

    local total_mosquitos = TUNING.MOSQUITOBOMB_MOSQUITOS

    if attacker ~= nil and
        attacker.components.skilltreeupdater ~= nil and
        attacker.components.skilltreeupdater:IsActivated("wurt_mosquito_craft_3")
    then
        total_mosquitos = total_mosquitos + SKILL_ADDITIONAL_MOSQUITOS
    end

    for i = 1, total_mosquitos do
        local mosquito = SpawnPrefab("mosquito")

        if mosquito ~= nil then
            if mosquito.components.follower ~= nil then
                mosquito.components.follower:SetLeader(attacker or nil)
            end

            local dist = math.random()
            local angle = math.random() * TWOPI

            mosquito.Physics:Teleport(x + dist * math.cos(angle), 0, z + dist * math.sin(angle))

            if mosquito.components.combat ~= nil then
                for _, target in ipairs(targets) do
                    if mosquito.components.combat:CanTarget(target) and
                        not mosquito.components.combat:IsAlly(target) and
                        (not mosquito.components.follower.leader or not mosquito.components.follower.leader.components.combat:IsAlly(target) ) and                     
                        (target.components.inventory == nil or not target.components.inventory:FindItem(IsMosquitoMusk)) then
                        mosquito.components.combat:SuggestTarget(target)

                        break
                    end
                end
            end
        end
    end
end

local IMPACT_DAMAGE_MUST_TAGS = { "_combat", "_health" }
local IMPACT_DAMAGE_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack", "mosquito" }

local function DoImpactDamage(inst, attacker, pvpattacker)
    local x, y, z = inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, 0, z, TUNING.BOMB_MOSQUITO_RANGE, IMPACT_DAMAGE_MUST_TAGS, IMPACT_DAMAGE_CANT_TAGS)

    for _, ent in ipairs(ents) do
        if not ent:IsInLimbo() and ent:IsValid() and
            (pvpattacker == nil or ent == pvpattacker or not ent:HasTag("player"))
        then
            if ent.components.combat ~= nil and not (ent.components.health ~= nil and ent.components.health:IsDead()) then
                ent.components.combat:GetAttacked(inst, TUNING.BOMB_MOSQUITO_DAMAGE) -- NOTES(JBK): The component combat might remove itself in the GetAttacked callback!

                if attacker ~= nil and
                    ent:IsValid() and
                    attacker:IsValid() and
                    ent.components.combat ~= nil and
                    not (ent.components.health ~= nil and ent.components.health:IsDead())
                then
                    ent.components.combat:SuggestTarget(attacker)
                end
            end
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    -- local skin_build = inst:GetSkinBuild()

    -- if skin_build ~= nil then
    --     owner:PushEvent("equipskinneditem", inst:GetSkinName())
    --     owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_mosquitobomb", inst.GUID, "swap_mosquitobomb")
    -- else
            owner.AnimState:OverrideSymbol("swap_object", "swap_mosquitobomb", "swap_mosquitobomb")
    -- end
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    -- local skin_build = inst:GetSkinBuild()

    -- if skin_build ~= nil then
    --     owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    -- end
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function OnThrown(inst, attacker)
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.AnimState:PlayAnimation("spin_loop")

    inst:KillIdleSound()

    inst.SoundEmitter:PlaySound("meta4/mosquito_bomb/spin_lp", THROWN_SOUNDNAME)

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:SetCapsule(.2, .2)
end

local function OnHit(inst, attacker, target)
    inst.SoundEmitter:KillSound(THROWN_SOUNDNAME)
    inst.SoundEmitter:PlaySound("meta4/mosquito_bomb/explode")

    local ispvp = attacker ~= nil and attacker:IsValid() and attacker:HasTag("player")

    inst:DoImpactDamage(attacker, ispvp and attacker or nil)
    inst:SpawnMosquitos(attacker)

    inst.AnimState:PlayAnimation("used")

    inst:ListenForEvent("animover", inst.Remove)
end

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()

    --Attack range is 8, leave room for error
    --Min range was chosen to not hit yourself (2 is the hit range)
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)

        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end

    return pos
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function PlayFunnyIdle(inst)
    local loop_twice = math.random() <= .75
    local tasktime = math.random()*2 + 5

    inst.AnimState:PlayAnimation("idle_loop")

    local killsoundtime = inst.AnimState:GetCurrentAnimationLength()

    if loop_twice then
        inst.AnimState:PushAnimation("idle_loop")

        tasktime = tasktime * 1.25
        killsoundtime = killsoundtime * 2
    end

    inst.AnimState:PushAnimation("idle")

    inst.SoundEmitter:PlaySound("meta4/mosquito_bomb/idle_lp", IDLE_SOUNDNAME)

    inst._killsoundtask = inst:DoTaskInTime(killsoundtime, inst.KillIdleSound)
    inst._funnyidletask = inst:DoTaskInTime(tasktime,      inst.PlayFunnyIdle)
end

local function KillIdleSound(inst)
    inst.SoundEmitter:KillSound(IDLE_SOUNDNAME)
end

local function OnEntityWake(inst)
    if inst:IsInLimbo() or inst:IsAsleep() then
        return
    end

    if inst._funnyidletask ~= nil then
        inst._funnyidletask:Cancel()
        inst._funnyidletask = nil
    end

    local tasktime = math.random()*2 + 5

    inst._funnyidletask = inst:DoTaskInTime(tasktime, inst.PlayFunnyIdle)
end

local function OnEntitySleep(inst)
    if inst._funnyidletask ~= nil then
        inst._funnyidletask:Cancel()
        inst._funnyidletask = nil
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetTwoFaced()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mosquitobomb")
    inst.AnimState:SetBuild("mosquitobomb")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetDeltaTimeMultiplier(.75)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true

    MakeInventoryFloatable(inst, "small", 0.23, 1.15)

    -- Weapon (from weapon component) added to pristine state for optimization.
    inst:AddTag("weapon")

    -- Projectile (from complexprojectile component) added to pristine state for optimization.
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_weapondamage = TUNING.BOMB_MOSQUITO_DAMAGE

    inst.SpawnMosquitos = SpawnMosquitos
    inst.DoImpactDamage = DoImpactDamage
    inst.PlayFunnyIdle  = PlayFunnyIdle
    inst.KillIdleSound  = KillIdleSound

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("locomotor")
    inst:AddComponent("stackable")

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(OnThrown)
    inst.components.complexprojectile:SetOnHit(OnHit)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.equipstack = true

    inst.OnEntityWake  = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep
    inst:ListenForEvent("exitlimbo",  inst.OnEntityWake )
    inst:ListenForEvent("enterlimbo", inst.OnEntitySleep)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mosquitobomb", fn, assets, prefabs)
