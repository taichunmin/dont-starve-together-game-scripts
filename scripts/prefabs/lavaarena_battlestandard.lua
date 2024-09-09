local function CreatePulse(target)
    local inst = CreateEntity()

    inst:AddTag("DECOR") --"FX" will catch mouseover
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lavaarena_battlestandard")
    inst.AnimState:SetBuild("lavaarena_battlestandard")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.entity:SetParent(target.entity)

    return inst
end

local function ApplyPulse(ent, params)
    if ent:HasTag("debuffable") and not IsEntityDead(ent) then
        local fx = CreatePulse(ent)
        fx:ListenForEvent("animover", fx.Remove)
        fx.AnimState:PlayAnimation(params.fxanim)
    end
end

local function OnPulse(inst)
    if inst.fxanim ~= nil and inst.fx ~= nil and inst.fx:IsValid() then
        inst.fx.AnimState:PlayAnimation(inst.fxanim)
    end

    if TheWorld.components.lavaarenamobtracker ~= nil then
        TheWorld.components.lavaarenamobtracker:ForEachMob(ApplyPulse, { fxanim = inst.fxanim })
    end
end

local function MakeBattleStandard(name, build_swap, debuffprefab, fx_anim)
    local assets =
    {
        Asset("ANIM", "anim/lavaarena_battlestandard.zip"),
    }
    if build_swap ~= nil then
        table.insert(assets, Asset("ANIM", "anim/"..build_swap..".zip"))
    end

    local prefabs =
    {
        debuffprefab,
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("lavaarena_battlestandard")
        inst.AnimState:SetBuild("lavaarena_battlestandard")
        if build_swap ~= nil then
            inst.AnimState:AddOverrideBuild(build_swap)
        end
        inst.AnimState:PlayAnimation("idle", true)

        inst:AddTag("battlestandard")
        inst:AddTag("LA_mob")

        inst.fxanim = fx_anim

        --Dedicated server does not need local fx
        if not TheNet:IsDedicated() then
           	inst.fx = CreatePulse(inst)
        end
        inst.pulse = net_event(inst.GUID, "lavaarena_battlestandard_damager.pulse")

        inst:SetPrefabNameOverride("lavaarena_battlestandard")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:ListenForEvent("lavaarena_battlestandard_damager.pulse", OnPulse)

            return inst
        end

        inst.debuffprefab = debuffprefab
        inst.OnPulse = OnPulse

        event_server_data("lavaarena", "prefabs/lavaarena_battlestandard").battlestandard_postinit(inst)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function MakeBuff(name, buffid)
    local function fn()
        return event_server_data("lavaarena", "prefabs/lavaarena_battlestandard").createbuff(buffid)
    end

    return Prefab(name, fn)
end

------------------------------------------------------------------------------

return MakeBattleStandard("lavaarena_battlestandard_damager", "lavaarena_battlestandard_attack_build", "lavaarena_battlestandard_damagerbuff", "attack_fx3"),
    MakeBattleStandard("lavaarena_battlestandard_shield", nil, "lavaarena_battlestandard_shieldbuff", "defend_fx"),
    MakeBattleStandard("lavaarena_battlestandard_heal", "lavaarena_battlestandard_heal_build", "lavaarena_battlestandard_healbuff", "heal_fx"),
    MakeBuff("lavaarena_battlestandard_damagerbuff", "damager"),
    MakeBuff("lavaarena_battlestandard_shieldbuff", "shield"),
    MakeBuff("lavaarena_battlestandard_healbuff", "heal")
