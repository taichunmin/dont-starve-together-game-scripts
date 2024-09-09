local function make_break_fx(name)
    local break_prefab_name = name.."_break"

    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("ANIM", "anim/"..break_prefab_name..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank(break_prefab_name)
        inst.AnimState:SetBuild(break_prefab_name)
        inst.AnimState:AddOverrideBuild(name)
        inst.AnimState:PlayAnimation("break")

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end

    return Prefab(break_prefab_name, fn, assets)
end

-- moon_altar_break, moon_altar_claw_break, moon_altar_crown_break
return make_break_fx("moon_altar"),
    make_break_fx("moon_altar_claw"),
    make_break_fx("moon_altar_crown")
