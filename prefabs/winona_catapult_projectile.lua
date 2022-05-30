local assets =
{
    Asset("ANIM", "anim/winona_catapult_projectile.zip"),
}

local function OnThrown(inst)
    if inst.components.complexprojectile.attacker ~= nil then
        inst.direction:set(inst.components.complexprojectile.attacker.Transform:GetRotation())
        if inst.animent ~= nil then
            inst.animent.Transform:SetRotation(inst.direction:value())
        end
    end
end

local NO_TAGS_PVP = { "INLIMBO", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "notarget", "companion", "shadowminion" }
local NO_TAGS = { "player" }
for i, v in ipairs(NO_TAGS_PVP) do
    table.insert(NO_TAGS, v)
end

local COMBAT_TAGS = { "_combat" }
local function OnHit(inst, attacker, target)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.Physics:Stop()
    inst.Physics:Teleport(x, 0, z)
    inst.Transform:SetRotation(inst.direction:value())
    inst.AnimState:PlayAnimation("impact")
    inst:ListenForEvent("animover", inst.Remove)

    inst.hideanim:set(true)
    if inst.animent ~= nil then
        inst.animent:Remove()
        inst.animent = nil
    end

    if attacker ~= nil and attacker.components.combat ~= nil and attacker:IsValid() then
        attacker.components.combat.ignorehitrange = true
    else
        attacker = nil
    end
    local hit = false
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 4, COMBAT_TAGS, TheNet:GetPVPEnabled() and NO_TAGS_PVP or NO_TAGS)) do
        if v:IsValid() and v.entity:IsVisible() and inst.components.combat:CanTarget(v) then
            if attacker ~= nil and not (v.components.combat.target ~= nil and v.components.combat.target:HasTag("player")) then
                --if target is not targeting a player, then use the catapult as attacker to draw aggro
                attacker.components.combat:DoAttack(v)
            else
                inst.components.combat:DoAttack(v)
            end
            hit = true
        end
    end
    if attacker ~= nil then
        attacker.components.combat.ignorehitrange = false
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/rock_hit", nil, hit and .5 or nil)
end

local function KeepTargetFn(inst)
    return false
end

local function CreateProjectileAnim()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("winona_catapult_projectile")
    inst.AnimState:SetBuild("winona_catapult_projectile")
    inst.AnimState:PlayAnimation("air", true)

    return inst
end

local function OnDirectionDirty(inst)
    if inst.animent ~= nil then
        inst.animent.Transform:SetRotation(inst.direction:value())
    end
end

local function OnHideAnimDirty(inst)
    if inst.hideanim:value() and inst.animent ~= nil then
        inst.animent:Remove()
        inst.animent = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("winona_catapult_projectile")
    inst.AnimState:SetBuild("winona_catapult_projectile")
    inst.AnimState:PlayAnimation("empty")

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetRestitution(.5)
    inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetSphere(.4)

    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")

    --projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.direction = net_float(inst.GUID, "winona_catapult_projectile.direction", "directiondirty")
    inst.hideanim = net_bool(inst.GUID, "winona_catapult_projectile.hideanim", "hideanimdirty")

    --Dedicated server does not need to spawn the local animation
    if not TheNet:IsDedicated() then
        inst.animent = CreateProjectileAnim()
        inst.animent.entity:SetParent(inst.entity)

        if not TheWorld.ismastersim then
            inst:ListenForEvent("directiondirty", OnDirectionDirty)
            inst:ListenForEvent("hideanimdirty", OnHideAnimDirty)
        end
    end

    inst:SetPrefabNameOverride("winona_catapult") --for death announce

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(30)
    inst.components.complexprojectile:SetGravity(-100)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(1.25, 3, 0))
    inst.components.complexprojectile:SetOnLaunch(OnThrown)
    inst.components.complexprojectile:SetOnHit(OnHit)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.WINONA_CATAPULT_DAMAGE)
    inst.components.combat:SetRange(TUNING.WINONA_CATAPULT_AOE_RADIUS)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst.persists = false

    return inst
end

return Prefab("winona_catapult_projectile", fn, assets)
