local assetsfx =
{
    Asset("ANIM", "anim/merm_lunar_spike_fx.zip"),
}

local MAXRANGE = 3
local NO_TAGS_NO_PLAYERS =  { "merm", "INLIMBO", "notarget", "noattack", "flight", "invisible", "wall", "player", "companion" }
local NO_TAGS            =  { "merm", "INLIMBO", "notarget", "noattack", "flight", "invisible", "wall", "playerghost" }
local COMBAT_TARGET_TAGS =  { "_combat" }

local function OnUpdateThorns(inst)
    inst.range = inst.range + .75

    local cant_tags = (inst.canhitplayers and NO_TAGS) or NO_TAGS_NO_PLAYERS
    local entities_range = inst.range + 3

    local x, y, z = inst.Transform:GetWorldPosition()
    for _, potential_target in ipairs(TheSim:FindEntities(x, y, z, entities_range, COMBAT_TARGET_TAGS, cant_tags)) do
        if not inst.ignore[potential_target] and potential_target:IsValid() and potential_target.entity:IsVisible() then
            local range = inst.range + potential_target:GetPhysicsRadius(0)

            if potential_target:GetDistanceSqToPoint(x, y, z) < range * range then
                if inst.owner ~= nil and not inst.owner:IsValid() then
                    inst.owner = nil
                end

                if inst.owner ~= nil then
                    local leader = inst.owner.components.follower and inst.owner.components.follower.leader
                    if inst.owner.components.combat ~= nil and
                        inst.owner.components.combat:CanTarget(potential_target) and
                        not inst.owner.components.combat:IsAlly(potential_target) and
                        (not leader or not leader.components.combat:IsAlly(potential_target))
                    then
                        inst.ignore[potential_target] = true
                        local attacker = (potential_target.components.follower ~= nil
                            and potential_target.components.follower:GetLeader() == inst.owner
                            and inst) or inst.owner
                        potential_target.components.combat:GetAttacked(attacker, inst.damage, nil, nil, inst.spdmg)
                    end
                elseif potential_target.components.combat:CanBeAttacked() then
                    -- NOTES(JBK): inst.owner is nil here so this is for non worn things like the bramble trap.
                    local isally = false
                    if not inst.canhitplayers then
                        --non-pvp, so don't hit any player followers (unless they are targeting a player!)
                        local leader = (potential_target.components.follower ~= nil and potential_target.components.follower:GetLeader()) or nil
                        isally = leader ~= nil and leader.isplayer and
                            not (potential_target.components.combat ~= nil and
                                potential_target.components.combat.target ~= nil and
                                potential_target.components.combat.target.isplayer)
                    end
                    if not isally then
                        inst.ignore[potential_target] = true
                        potential_target.components.combat:GetAttacked(inst, inst.damage, nil, nil, inst.spdmg)
                    end
                end
            end
        end
    end

    if inst.range >= MAXRANGE then
        inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateThorns)
    end
end

local function SetFXOwner(inst, owner)
    inst.Transform:SetPosition(owner.Transform:GetWorldPosition())
    inst.owner = owner
    inst.canhitplayers = not owner:HasTag("player") or TheNet:GetPVPEnabled()
    inst.ignore[owner] = true

    if owner:HasDebuff("wurt_merm_planar") then
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local function MakeLunarMermThornsFx(name, anim, damage)
    local function fxfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("thorny")

        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("merm_lunar_spike_fx")
        inst.AnimState:SetBuild("merm_lunar_spike_fx")
        inst.AnimState:PlayAnimation(anim)

        inst.AnimState:SetFinalOffset(-1)

        inst:SetPrefabNameOverride("bramblefx") -- Nice string for death announcement.

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateThorns)

        inst:ListenForEvent("animover", inst.Remove)
        inst.persists = false
        inst.damage = TUNING[damage]
        inst.range = .75
        inst.ignore = {}
        inst.canhitplayers = true
        --inst.owner = nil

        inst.SetFXOwner = SetFXOwner

        return inst
    end

    return Prefab(name, fxfn, assetsfx)
end

--
local function soilmarkerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst:AddTag("merm_soil_blocker")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(5, inst.Remove)

    return inst
end

--
return MakeLunarMermThornsFx("lunarmerm_thorns_fx", "idle", "MERM_LUNAR_THORN_DAMAGE"),
    Prefab("merm_soil_marker", soilmarkerfn)