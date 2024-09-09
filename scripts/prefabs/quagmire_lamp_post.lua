local function LightFn(bank_build, radius, falloff, intensity, color)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .5)

        inst.AnimState:SetBank(bank_build)
        inst.AnimState:SetBuild(bank_build)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:PlayAnimation("idle")

        inst.Light:Enable(true)
        inst.Light:SetRadius(radius)
        inst.Light:SetFalloff(falloff)
        inst.Light:SetIntensity(intensity)
        inst.Light:SetColour(color / 255, color / 255, color / 255)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        return inst
    end
end

return Prefab("quagmire_lamp_post", LightFn("quagmire_lamp_post", 3.5, 0.58, 0.75, 235), { Asset("ANIM", "anim/quagmire_lamp_post.zip") }),
    Prefab("quagmire_lamp_short", LightFn("quagmire_lamp_short", 2, 0.58, 0.75, 200), { Asset("ANIM", "anim/quagmire_lamp_short.zip") })
