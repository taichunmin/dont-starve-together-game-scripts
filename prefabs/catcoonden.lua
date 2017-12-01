local assets =
{
    Asset("ANIM", "anim/catcoon_den.zip"),
}

local prefabs =
{
    "catcoon",
    "log",
    "rope",
    "twigs",
    "collapse_small",
}

local loots =
{
    {'log', 1.00},
    {'twigs',   1.00},
    {'rope',    0.05},
    {'boneshard', 0.2},
    {'feather', 0.05},
    {'feather_robin', 0.05},
    {'feather_robin_winter', 0.05},
    {'canary', 0.05},
    {'crow', 0.02},
    {'robin', 0.02},
    {'robin_winter', 0.02},
    {'canary', 0.02},
    {'rabbit', 0.02},
    {'mole', 0.02},
    {'smallmeat', 0.3},
}

local MAX_LIVES = 9

local function onhammered(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren()
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.components.lootdropper:DropLoot(Vector3(x, y, z))
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst.playing_dead_anim then
        inst.AnimState:PlayAnimation("hit", false)
    end
end

local function OnEntityWake(inst)
    if inst.lives_left <= 0 and inst.delay_end <= GetTime() then
        inst.lives_left = MAX_LIVES
        if inst.components.childspawner ~= nil then
            inst.components.childspawner:SetMaxChildren(1)
            inst.components.childspawner:StartRegen()
            inst.components.childspawner:StartSpawning()
        end
    end
    if inst.playing_dead_anim then
        if inst.lives_left > 0 then
            inst.playing_dead_anim = nil
            inst.AnimState:PlayAnimation("idle")
        end
    elseif inst.lives_left <= 0 then
        inst.playing_dead_anim = true
        inst.AnimState:PlayAnimation("dead", true)
    end
end

--local function OnEntitySleep(inst)
--end

local function OnChildChilled(inst, child)
    inst.lives_left = inst.lives_left - 1
    if inst.lives_left <= 0 then
        if inst.components.childspawner ~= nil then
            inst.components.childspawner:StopRegen()
            inst.components.childspawner:StopSpawning()
            inst.components.childspawner:SetMaxChildren(0)
        end
        local mindelay = TheWorld.state.winterlength
        if mindelay <= 0 then
            mindelay = TheWorld.state.autumnlength
            if mindelay <= 0 then
                mindelay = TheWorld.state.summerlength
                if mindelay <= 0 then
                    mindelay = TheWorld.state.springlength
                end
            end
        end
        local delay = TheWorld.state.remainingdaysinseason
        if TheWorld.state.season ~= "winter" then
            delay = delay + TheWorld.state.winterlength
            if TheWorld.state.season ~= "autumn" then
                delay = delay + TheWorld.state.autumnlength
                if TheWorld.state.season ~= "summer" then
                    delay = delay + TheWorld.state.summerlength
                end
            end
        end
        inst.delay_end = GetTime() + math.max(delay, mindelay) * TUNING.TOTAL_DAY_TIME
    end
end

local function onsave(inst, data)
    if inst.lives_left > 0 then
        data.lives = inst.lives_left
    elseif inst.delay_end > GetTime() then
        data.delay_remaining = inst.delay_end - GetTime()
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.lives_left ~= nil and data.lives_left > 0 then
            if inst.lives_left <= 0 and inst.components.childspawner ~= nil then
                inst.components.childspawner:SetMaxChildren(1)
                inst.components.childspawner:StartRegen()
                inst.components.childspawner:StartSpawning()
            end
            inst.lives_left = data.lives_left
            inst.delay_end = 0
        else
            if inst.lives_left > 0 and inst.components.childspawner ~= nil then
                if #inst.components.childspawner.childrenoutside > 0 then
                    for i, v in pairs(inst.components.childspawner.childrenoutside) do
                        v:Remove()
                    end
                end
                inst.components.childspawner:StopRegen()
                inst.components.childspawner:StopSpawning()
                inst.components.childspawner:SetMaxChildren(0)
            end
            inst.lives_left = 0
            inst.delay_end = GetTime() + (data.delay_remaining or 0)
        end
        if inst.playing_dead_anim then
            if inst.lives_left > 0 then
                inst.playing_dead_anim = nil
                inst.AnimState:PlayAnimation("idle")
            end
        elseif inst.lives_left <= 0 then
            inst.playing_dead_anim = true
            inst.AnimState:PlayAnimation("dead", true)
        end
    end
end

local function getstatus(inst, viewer)
    return inst.lives_left <= 0 and "EMPTY" or nil
end

local function canspawn(inst)
    return not TheWorld.state.israining
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeSmallObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("catcoonden.png")

    inst.AnimState:SetBank("catcoon_den")
    inst.AnimState:SetBuild("catcoon_den")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("chewable") -- by werebeaver
    inst:AddTag("catcoonden")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)       

    -------------------
    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "catcoon"
    inst.components.childspawner:SetRegenPeriod(TUNING.CATCOONDEN_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.CATCOONDEN_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner.canspawnfn = canspawn
    inst.components.childspawner:StartSpawning()

    inst.playing_dead_anim = nil
    inst.delay_end = 0
    inst.lives_left = MAX_LIVES
    inst.components.childspawner.onchildkilledfn = OnChildChilled

    ---------------------
    inst:AddComponent("lootdropper")
    for i, v in ipairs(loots) do
        inst.components.lootdropper:AddRandomLoot(unpack(v))
    end
    inst.components.lootdropper.numrandomloot = 4

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)

    ---------------------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    MakeSnowCovered(inst)

    --inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeHauntableIgnite(inst)

    return inst
end

return Prefab("catcoonden", fn, assets, prefabs)
