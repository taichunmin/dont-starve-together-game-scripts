local assets =
{
    Asset("ANIM", "anim/moonglass_bigwaterfall_steam.zip"),
    Asset("ANIM", "anim/moonglasspool_tile.zip"),
    Asset("MINIMAP_IMAGE", "grotto_pool_small"),
}

local prefabs =
{
    "grotto_waterfall_small1",
    "grotto_waterfall_small2",
    "grottopool_sfx",
}

local function setup_children(inst)
    if inst._waterfall == nil then
        local wf = SpawnPrefab("grotto_waterfall_small"..math.random(1,2))
        wf.Transform:SetPosition(inst.Transform:GetWorldPosition())

        inst._waterfall = wf
    end

    if inst._waterfall ~= nil then
        inst._waterfall:ListenForEvent("onremove", function() inst._waterfall = nil end)
    end
end

local function register_pool(inst)
    TheWorld:PushEvent("ms_registergrottopool", {pool = inst, small = true})
end

local function on_save(inst, data)
    if inst._waterfall ~= nil then
        data.wf_id = inst._waterfall.GUID
        return {data.wf_id}
    end
end

local function on_load_postpass(inst, newents, data)
    if data ~= nil and data.wf_id ~= nil then
        local waterfall = newents[data.wf_id]
        if waterfall ~= nil then
            inst._waterfall = waterfall.entity
        end
    end
end

local function on_removed(inst)
    if inst._waterfall ~= nil then
        inst._waterfall:Remove()
    end
end

local function makesmallmist(proxy)
    if not proxy then
        return nil
    end

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --[[Non-networked entity]]

    local parent = proxy.entity:GetParent()
    if parent ~= nil then
        inst.entity:SetParent(parent.entity)
    end

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBuild("moonglass_bigwaterfall_steam")
    inst.AnimState:SetBank("moonglass_bigwaterfall_steam")
    inst.AnimState:PlayAnimation("steam_small"..math.random(1,2), true)
    inst.AnimState:SetLightOverride(0.5)

    proxy:ListenForEvent("onremove", function() inst:Remove() end)

    return inst
end

local COLOUR_R, COLOUR_G, COLOUR_B = 227/255, 227/255, 227/255
local function poolfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, makesmallmist)
    end

    MakeObstaclePhysics(inst, TUNING.GROTTO_POOL_SMALL_RADIUS)

    inst.AnimState:SetBuild("moonglasspool_tile")
    inst.AnimState:SetBank("moonglasspool_tile")
    inst.AnimState:PlayAnimation("smallpool_idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetLightOverride(0.25)

    inst.MiniMapEntity:SetIcon("grotto_pool_small.png")

    inst.Light:SetColour(COLOUR_R, COLOUR_G, COLOUR_B)
    inst.Light:SetIntensity(0.3)
    inst.Light:SetFalloff(0.6)
    inst.Light:SetRadius(0.6)

    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")
    -- From watersource component
    inst:AddTag("watersource")

    inst.no_wet_prefix = true

	inst:SetDeploySmartRadius(2.5)

    inst.scrapbook_specialinfo = "GROTTOPOOL"

    inst.scrapbook_build = "moonglass_bigwaterfall"
    inst.scrapbook_bank  = "moonglass_bigwaterfall"
    inst.scrapbook_anim   = "water_small1"

    inst.scrapbook_adddeps = { "moonglass" }

    if not TheNet:IsDedicated() then
        -- Register into the waterfall sound system.
        inst:DoTaskInTime(0, register_pool)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("watersource")

    inst:ListenForEvent("onremove", on_removed)

    inst:DoTaskInTime(0, setup_children)

    inst.OnSave = on_save
    inst.OnLoadPostPass = on_load_postpass

    return inst
end

return Prefab("grotto_pool_small", poolfn, assets, prefabs)
