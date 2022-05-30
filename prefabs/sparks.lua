local function onupdate(inst, dt)
    if inst.sound then
        inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/spark")
        inst.sound = nil
    end

    inst.Light:SetIntensity(inst.i)
    inst.i = inst.i - dt * 2
    if inst.i <= 0 then
        if inst.killfx then
            inst:Remove()
        else
            inst.task:Cancel()
            inst.task = nil
        end
    end
end

local function OnAnimOver(inst)
    if inst.task == nil then
        inst:Remove()
    else
        inst:RemoveEventCallback("animover", OnAnimOver)
        inst.killfx = true
    end
end

local function StartFX(proxy, animindex, build)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    if not TheNet:IsDedicated() then
        inst.entity:AddSoundEmitter()
    end
    inst.entity:AddLight()

    local parent = proxy.entity:GetParent()
    if parent ~= nil then
        inst.entity:SetParent(parent.entity)
    end
    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank(build)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("sparks_"..tostring(animindex))
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.Light:Enable(true)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.9)
    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

    local dt = 1 / 20
    inst.i = .9
    inst.sound = inst.SoundEmitter ~= nil
    inst.task = inst:DoPeriodicTask(dt, onupdate, nil, dt)

    inst:ListenForEvent("animover", OnAnimOver)
end

local function OnRemoveFlash(inst)
    if inst.target.components.colouradder == nil and inst.target:IsValid() then
        if inst.target.components.freezable ~= nil then
            inst.target.components.freezable:UpdateTint()
        else
            inst.target.AnimState:SetAddColour(0, 0, 0, 0)
        end
    end
end

local function OnUpdateFlash(inst)
    if not inst.target:IsValid() or inst.AnimState == nil then
        inst.OnRemoveEntity = nil
        inst:RemoveComponent("updatelooper")
    elseif inst.flash > .1 then
        inst.flash = inst.flash - .08
        inst.blink = inst.blink < 3 and inst.blink + 1 or 0
        local c = inst.flash * (inst.blink < 2 and inst.intensity or inst.intensity * .25)
        if inst.target.components.colouradder ~= nil then
            inst.target.components.colouradder:PushColour(inst, c, c, c, 0)
        else
            inst.target.AnimState:SetAddColour(c, c, c, 0)
        end
    else
        if inst.target.components.colouradder ~= nil then
            inst.target.components.colouradder:PopColour(inst)
        elseif inst.target.components.freezable ~= nil then
            inst.target.components.freezable:UpdateTint()
        else
            inst.target.AnimState:SetAddColour(0, 0, 0, 0)
        end
        inst.OnRemoveEntity = nil
        inst:RemoveComponent("updatelooper")
    end
end

local function AlignToTarget(inst, target, attacker, flash)
    --NOTE: attacker could be a projectile
    local x, y, z = target.Transform:GetWorldPosition()
    local x1, y1, z1 = attacker.Transform:GetWorldPosition()
    local dx, dz = x1 - x, z1 - z
    local len = math.sqrt(dx * dx + dz * dz)
    local r = len ~= 0 and (target:GetPhysicsRadius(0) + .2) / len or 0
    inst.Transform:SetPosition(x + dx * r, y + 1, z + dz * r)

    if flash and inst.components.updatelooper == nil then
        inst.OnRemoveEntity = OnRemoveFlash
        inst.target = target
        inst.flash = 1
        inst.blink = 0
        inst.intensity = target:HasTag("largecreature") and .1 or .2

        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateFlash)
        OnUpdateFlash(inst)
    end
end

local function MakeSparks(name, build)
    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
    }

    local function OnRandDirty(inst)
        if inst._complete or inst._rand:value() <= 0 then
            return
        end

        --Delay one frame in case we are about to be removed
        inst:DoTaskInTime(0, StartFX, inst._rand:value(), build)
        inst._complete = true
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        inst.Transform:SetScale(2, 2, 2)

        inst._rand = net_tinybyte(inst.GUID, "_rand", "randdirty")
        inst._complete = false
        inst:ListenForEvent("randdirty", OnRandDirty)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        inst._rand:set(math.random(3))

        inst.AlignToTarget = AlignToTarget

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeSparks("sparks", "sparks"),
    MakeSparks("electrichitsparks", "elec_hit_fx")
