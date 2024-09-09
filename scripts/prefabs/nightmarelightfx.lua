local function Make(name, bank, mouseparent)
    local assets =
    {
        Asset("ANIM", "anim/"..bank..".zip"),
    }

    local OnEntityReplicated = mouseparent ~= nil and function(inst)
        local parent = inst.entity:GetParent()
        if parent ~= nil and parent.prefab == mouseparent then
            parent.highlightchildren = { inst }
        end
    end or nil

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork() -- gjans: this is networked coz we trigger animations on it

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(bank)
        inst.AnimState:PlayAnimation("idle_closed")

        --"FX" will catch mouseover, "DECOR" will not
        inst:AddTag(mouseparent ~= nil and "DECOR" or "FX")
        inst:AddTag("NOCLICK")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst.OnEntityReplicated = OnEntityReplicated

            return inst
        end

        inst.persists = false

        return inst
    end

    return Prefab(name, fn, assets)
end

return Make("nightmarelightfx", "rock_light_fx", "nightmarelight"),
    Make("nightmarefissurefx", "nightmare_crack_ruins_fx", "fissure_lower"),
    Make("upper_nightmarefissurefx", "nightmare_crack_upper_fx", "fissure"),
    Make("fissure_grottowarfx", "fissure_grottowarfx", "fissure")
