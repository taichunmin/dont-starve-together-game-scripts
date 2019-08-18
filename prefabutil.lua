function MakePlacer(name, bank, build, anim, onground, snap, metersnap, scale, fixedcameraoffset, facing, postinit_fn, offset)
    local function fn()
        local inst = CreateEntity()

        inst:AddTag("CLASSIFIED")
        inst:AddTag("NOCLICK")
        inst:AddTag("placer")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        if anim ~= nil then
            inst.AnimState:SetBank(bank)
            inst.AnimState:SetBuild(build)
            inst.AnimState:PlayAnimation(anim, true)
            inst.AnimState:SetLightOverride(1)
        end

        if facing == "two" then
            inst.Transform:SetTwoFaced()
        elseif facing == "four" then
            inst.Transform:SetFourFaced()
        elseif facing == "six" then
            inst.Transform:SetSixFaced()
        elseif facing == "eight" then
            inst.Transform:SetEightFaced()
        end

        inst:AddComponent("placer")
        inst.components.placer.snaptogrid = snap
        inst.components.placer.snap_to_meters = metersnap
        inst.components.placer.fixedcameraoffset = fixedcameraoffset
        inst.components.placer.onground = onground

        if offset ~= nil then
            inst.components.placer.offset = offset
        end

        if scale ~= nil and scale ~= 1 then
            inst.Transform:SetScale(scale, scale, scale)
        end

        if onground then
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        end

        if postinit_fn ~= nil then
            postinit_fn(inst)
        end

        return inst
    end

    return Prefab(name, fn)
end
