local function makeassetlist(name)
    return {
        Asset("ANIM", "anim/"..name..".zip")
    }
end

local function doshake(inst)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")

    -- JIGGLE SOUND [AMANDA]
end

local function makefn(name, collide)
    return function()
    	local inst = CreateEntity()

    	inst.entity:AddTransform()
    	inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        if name == "pillar_ruins" then
           inst.entity:AddSoundEmitter()
           inst:AddTag("charge_barrier")
           inst:AddTag("quake_on_charge")           
        end

        if collide then
            MakeObstaclePhysics(inst, 2.35)
        else
            inst:AddTag("NOBLOCK")
        end

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle", true)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:ListenForEvent("shake", doshake)

        return inst
    end
end

local function pillar(name, collide)
    return Prefab(name, makefn(name, collide), makeassetlist(name))
end

return pillar("pillar_ruins", true),
       pillar("pillar_algae", true),
       pillar("pillar_cave", true),
       pillar("pillar_cave_flintless", true),
       pillar("pillar_cave_rock", true),
       pillar("pillar_stalactite")--,
       --pillar("pillar_cave_moon", true),
       --pillar("pillar_stalactite_moon"),
