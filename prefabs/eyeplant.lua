local assets =
{
    Asset("ANIM", "anim/eyeplant.zip"),
    Asset("SOUND", "sound/plant.fsb"),
}

local function checkmaster(tar, inst)
    if inst.minionlord then
        return tar == inst.minionlord
    end

    if tar.minionlord and inst.minionlord then
        return tar.minionlord == inst.minionlord
    else
        return false
    end
end

local function retargetfn(inst)
    return FindEntity(
        inst,
        TUNING.EYEPLANT_ATTACK_DIST,
        function(guy) 
            return not (guy.components.health:IsDead() or checkmaster(guy, inst))
        end,
        { "_combat", "_health" }, -- see entityreplica.lua
        { "INLIMBO", "plantkin" },
        { "character", "monster", "animal", "prey", "eyeplant", "lureplant" }
    )
end

local function shouldKeepTarget(inst, target)
    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)
        
        return distsq < TUNING.EYEPLANT_STOPATTACK_DIST*TUNING.EYEPLANT_STOPATTACK_DIST
    else
        return false
    end
end

local function onnewcombattarget(inst, data)
    if data.target and not inst.sg:HasStateTag("attack") and not inst.sg:HasStateTag("hit") and not inst.components.health:IsDead() then
        inst.sg:GoToState("attack")
    end
end

local function ongotnewitem(inst, data)
    --print ("got item", data.item)
    --print (debugstack())
    if data.item.components.health ~= nil then
        inst:DoTaskInTime(0, inst.PushBufferedAction, BufferedAction(inst, data.item, ACTIONS.MURDER))
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .1)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("eyeplant")
    inst.AnimState:SetBuild("eyeplant")
    inst.AnimState:PlayAnimation("spawn")
    inst.AnimState:PushAnimation("idle")

    inst:AddTag("eyeplant")
    inst:AddTag("veggie")
    inst:AddTag("smallcreature")
    inst:AddTag("hostile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = 0

    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(TUNING.EYEPLANT_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.EYEPLANT_ATTACK_DIST)
    inst.components.combat:SetRetargetFunction(0.2, retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    inst.components.combat:SetDefaultDamage(TUNING.EYEPLANT_DAMAGE)

    inst:ListenForEvent("newcombattarget", onnewcombattarget)

    inst:ListenForEvent("gotnewitem", ongotnewitem)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.EYEPLANT_HEALTH)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")

    inst:SetStateGraph("SGeyeplant")

    inst:AddComponent("lootdropper")

    MakeSmallBurnable(inst)
    MakeMediumPropagator(inst)

    MakeHauntableIgnite(inst)

    return inst
end

return Prefab("eyeplant", fn, assets)
