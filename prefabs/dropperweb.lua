local assets =
{
	Asset("MINIMAP_IMAGE", "whitespider_den"),
}

local prefabs =
{
    "spider_dropper",
}




local function SpawnInvestigators(inst, data)
    if inst.components.childspawner ~= nil then
        local num_to_release = math.min(2, inst.components.childspawner.childreninside)
        for i = 1, num_to_release do
            local spider = inst.components.childspawner:SpawnChild(data.target, nil, 3)
            if spider ~= nil then
                spider.sg:GoToState("dropper_enter")
            end
        end
    end
end

local function OnEntityWake(inst)
    if GetTime() > inst.lastwebtime + TUNING.TOTAL_DAY_TIME then
        local x,y,z = inst.Transform:GetWorldPosition()
        local webbed = TheSim:FindEntities(x,y,z,TUNING.MUSHTREE_WEBBED_SPIDER_RADIUS,{"webbed"})
        if #webbed < TUNING.MUSHTREE_WEBBED_MAX_PER_DEN then
            local webbable = TheSim:FindEntities(x,y,z,TUNING.MUSHTREE_WEBBED_SPIDER_RADIUS,{"webbable"})
            while GetTime() > inst.lastwebtime + TUNING.TOTAL_DAY_TIME
                and #webbable > 0
                and #webbed < TUNING.MUSHTREE_WEBBED_MAX_PER_DEN do

                local r = math.random(#webbable)
                local target = webbable[r]
                local w_x,w_y,w_z = target.Transform:GetWorldPosition()
                local spawned = SpawnPrefab("mushtree_tall_webbed")
                spawned.Transform:SetPosition(w_x,w_y,w_z)
                target:Remove()

                -- these tables are discarded, this is just for counting
                table.remove(webbable, r)
                table.insert(webbed, target)
                inst.lastwebtime = inst.lastwebtime + TUNING.TOTAL_DAY_TIME
            end
        end
        inst.lastwebtime = GetTime()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddGroundCreepEntity()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.GroundCreepEntity:SetRadius(5)
    inst:AddTag("cavedweller")
    inst:AddTag("spiderden")
    inst.MiniMapEntity:SetIcon("whitespider_den.png")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("creepactivate", SpawnInvestigators)

    inst:AddComponent("health")
    inst.components.health.nofadeout = true

    inst:AddComponent("childspawner")
    inst.components.childspawner:SetRegenPeriod(120)
    inst.components.childspawner:SetSpawnPeriod(240)
    inst.components.childspawner:SetMaxChildren(math.random(2, 3))
    inst.components.childspawner:StartRegen()
    inst.components.childspawner.childname = "spider_dropper"
    inst.components.childspawner.emergencychildname = "spider_dropper"
    inst.components.childspawner.emergencychildrenperplayer = 1

    inst.lastwebtime = GetTime()
    inst.OnEntityWake = OnEntityWake

    return inst
end

return Prefab("dropperweb", fn, assets, prefabs)
