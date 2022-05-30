require("worldsettingsutil")

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

local WEBBED_TAGS = {"webbed"}
local WEBBABLE_TAGS = {"webbable"}

local function OnEntityWake(inst)
    if GetTime() > inst.lastwebtime + TUNING.TOTAL_DAY_TIME then
        local x,y,z = inst.Transform:GetWorldPosition()
        local webbed = TheSim:FindEntities(x,y,z,TUNING.MUSHTREE_WEBBED_SPIDER_RADIUS, WEBBED_TAGS)
        if #webbed < TUNING.MUSHTREE_WEBBED_MAX_PER_DEN then
            local webbable = TheSim:FindEntities(x,y,z,TUNING.MUSHTREE_WEBBED_SPIDER_RADIUS, WEBBABLE_TAGS)
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

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.DROPPERWEB_RELEASE_TIME, TUNING.DROPPERWEB_REGEN_TIME)
end

local function OnGoHome(inst, child)
    -- Drops the hat before it goes home if it has any
    local hat = child.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    if hat ~= nil then
        child.components.inventory:DropItem(hat)
    end
end

local function SummonChildren(inst, data)
    if inst.components.health and not inst.components.health:IsDead() then
        if inst.components.childspawner ~= nil then
            local children_released = inst.components.childspawner:ReleaseAllChildren()

            for i,v in ipairs(children_released) do
                v:AddDebuff("spider_summoned_buff", "spider_summoned_buff")
                v.sg:GoToState("dropper_enter")
            end
        end
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
    inst.components.childspawner:SetRegenPeriod(TUNING.DROPPERWEB_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.DROPPERWEB_RELEASE_TIME)
    inst.components.childspawner:SetGoHomeFn(OnGoHome)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.DROPPERWEB_RELEASE_TIME, TUNING.DROPPERWEB_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.DROPPERWEB_REGEN_TIME, TUNING.DROPPERWEB_ENABLED)
    inst.components.childspawner:SetMaxChildren(math.random(TUNING.DROPPERWEB_MIN_CHILDREN, TUNING.DROPPERWEB_MAX_CHILDREN))
    if not TUNING.DROPPERWEB_ENABLED then
        inst.components.childspawner.childreninside = 0
    end
    inst.components.childspawner:StartRegen()
    inst.components.childspawner.childname = "spider_dropper"
    inst.components.childspawner.emergencychildname = "spider_dropper"
    inst.components.childspawner.emergencychildrenperplayer = 1
    inst.components.childspawner.canemergencyspawn = TUNING.DROPPERWEB_ENABLED

    inst.SummonChildren = SummonChildren

    inst.lastwebtime = GetTime()
    inst.OnEntityWake = OnEntityWake
    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("dropperweb", fn, assets, prefabs)
