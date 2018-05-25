local function MakeHat(name)
    local build = "hat_"..name
    local symbol = name.."hat"

    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(symbol)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("anim")

        inst:AddTag("hat")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("lavaarena", "prefabs/hats_lavaarena").master_postinit(inst, name, build, symbol)

        return inst
    end

    return Prefab("lavaarena_"..name.."hat", fn, assets)
end

return MakeHat("feathercrown"),
    MakeHat("lightdamager"),
    MakeHat("recharger"),
    MakeHat("healingflower"),
    MakeHat("tiaraflowerpetals"),
    MakeHat("strongdamager"),
    MakeHat("crowndamager"),
    MakeHat("healinggarland"),
    MakeHat("eyecirclet")
