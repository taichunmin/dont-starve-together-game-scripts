local function makeassetlist(name)
    return {
        Asset("ANIM", "anim/"..name..".zip")
    }
end

local function makefn(name, collide)
    return function()
    	local inst = CreateEntity()

    	inst.entity:AddTransform()
    	inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        if collide then
            MakeObstaclePhysics(inst, 2.35)
        end

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle", true)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

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
       pillar("pillar_stalactite")
