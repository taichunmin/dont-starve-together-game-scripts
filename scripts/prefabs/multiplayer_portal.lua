local assets_stone =
{
    Asset("ANIM", "anim/portal_stone.zip"),
    Asset("MINIMAP_IMAGE", "portal_dst"),
}

local assets_construction =
{
    Asset("ANIM", "anim/portal_stone_construction.zip"),
    Asset("ANIM", "anim/portal_stone.zip"),
    Asset("ANIM", "anim/ui_construction_4x1.zip"),
    Asset("MINIMAP_IMAGE", "portal_dst"),
}

local assets_moonrock =
{
    Asset("ANIM", "anim/portal_moonrock.zip"),
    Asset("ANIM", "anim/portal_stone.zip"),
    Asset("MINIMAP_IMAGE", "portal_dst"),
}

local assets_fx =
{
    Asset("ANIM", "anim/portal_moonrock.zip"),
    Asset("ANIM", "anim/portal_stone.zip"),
}

local prefabs_construction =
{
    "multiplayer_portal_moonrock",
    "construction_container",
}

local prefabs_moonrock =
{
    "multiplayer_portal_moonrock_fx",
}

local function OnRezPlayer(inst)
    if not inst.sg:HasStateTag("construction") then
        inst.sg:GoToState("spawn_pre")
    end
end

local function OnGetPortalRez(inst, portalrez)
    if portalrez then
        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
        inst:AddTag("resurrector")
    elseif inst.components.hauntable then
        inst:RemoveComponent("hauntable")
        inst:RemoveTag("resurrector")
    end
end

local function MakePortal(name, bank, build, assets, prefabs, common_postinit, master_postinit)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()

        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        -- MakeObstaclePhysics(inst, 1)

        inst.MiniMapEntity:SetIcon("portal_dst.png")

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle_loop", true)

        inst:AddTag("multiplayer_portal")
        inst:AddTag("antlion_sinkhole_blocker")

		inst:SetDeploySmartRadius(2.5)

        inst.scrapbook_specialinfo = "MULTIPLAYERPORTAL"
        inst.scrapbook_proxy = "multiplayer_portal"

        if common_postinit ~= nil then
            common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.scrapbook_adddeps = { "moonrockidol", "multiplayer_portal_moonrock_constr_plans" }

        inst:SetStateGraph("SGmultiplayerportal")

        inst:AddComponent("inspectable")
        inst.components.inspectable:RecordViews()

        OnGetPortalRez(inst, GetPortalRez())
        inst:ListenForEvent("ms_onportalrez", function() OnGetPortalRez(inst, GetPortalRez()) end, TheWorld)

        inst:ListenForEvent("ms_newplayercharacterspawned", function(world, data)
            if data and data.player then
                data.player.AnimState:SetMultColour(0, 0, 0, 1)
                data.player:Hide()
                data.player.components.playercontroller:Enable(false)
                data.player:DoStaticTaskInTime(12 * FRAMES, function(inst)
                    data.player:Show()
                    data.player:DoStaticTaskInTime(60 * FRAMES, function(inst)
                        inst.components.colourtweener:StartTween({ 1, 1, 1, 1 }, 14 * FRAMES, function(inst)
                            data.player.components.playercontroller:Enable(true)
                        end, true)
                    end)
                end)
            end
            if not inst.sg:HasStateTag("construction") then
                inst.sg:GoToState("spawn_pre", true)
            end
        end, TheWorld)

        inst:ListenForEvent("rez_player", OnRezPlayer)

        if build == "portal_stone" then
            MakeRoseTarget_CreateFuel(inst)
        end

        if master_postinit ~= nil then
            master_postinit(inst)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local STONE_SOUNDS =
{
    idle_loop = "dontstarve/common/together/spawn_vines/spawnportal_idle_LP",
    idle = "dontstarve/common/together/spawn_vines/spawnportal_idle",
    scratch = "dontstarve/common/together/spawn_vines/spawnportal_scratch",
    jacob = "dontstarve/common/together/spawn_vines/spawnportal_jacob",
    blink = "dontstarve/common/together/spawn_vines/spawnportal_blink",
    vines = "dontstarve/common/together/spawn_vines/vines",
    spawning_loop = "dontstarve/common/together/spawn_vines/spawnportal_spawning",
    armswing = "dontstarve/common/together/spawn_vines/spawnportal_armswing",
    shake = "dontstarve/common/together/spawn_vines/spawnportal_shake",
    open = "dontstarve/common/together/spawn_vines/spawnportal_open",
    glow_loop = nil,
    shatter = nil,
    place = nil,
    transmute_pre = nil,
    transmute = nil,
}

local function stone_common_postinit(inst)
    inst.sounds = TheWorld.ismastersim and STONE_SOUNDS or nil

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(-130)
    end

    inst.scrapbook_inspectonseen = true
end

local function construction_common_postinit(inst)
    inst.AnimState:Hide("stage2")
    inst.AnimState:Hide("stage3")
    inst.AnimState:AddOverrideBuild("portal_stone_construction")
    inst.AnimState:OverrideSymbol("portal_moonrock", "portal_moonrock", "portal_moonrock")
    inst.AnimState:OverrideSymbol("curtains", "portal_moonrock", "curtains")
	inst.AnimState:OverrideSymbol("lunar_mote", "portal_moonrock", "lunar_mote")
	inst.AnimState:OverrideSymbol("light", "portal_stone", "light")
	inst.AnimState:OverrideSymbol("portalbg", "portal_stone", "portalbg")
	inst.AnimState:OverrideSymbol("spiralfx1", "portal_stone", "spiralfx1")

    if TheWorld:HasTag("cave") then
        inst.AnimState:Hide("eyefx")
    else
		inst.AnimState:OverrideSymbol("glow01", "portal_moonrock", "glow01")
    end

    --constructionsite (from constructionsite component) added to pristine state for optimization
    inst:AddTag("constructionsite")

    inst.constructionname = "multiplayer_portal_moonrock"
    inst:SetPrefabNameOverride("multiplayer_portal")

    inst.sounds = TheWorld.ismastersim and
    {
        idle_loop = nil,
        idle = "dontstarve/common/together/spawn_vines/spawnportal_idle",
        scratch = nil,
        jacob = "dontstarve/common/together/spawn_vines/spawnportal_jacob",
        blink = nil,
        vines = "dontstarve/common/together/spawn_vines/vines",
        spawning_loop = "dontstarve/common/together/spawn_vines/spawnportal_spawning",
        armswing = nil,
        shake = "dontstarve/common/together/spawn_vines/spawnportal_shake",
        open = "dontstarve/common/together/spawn_vines/spawnportal_open",
        glow_loop = "dontstarve/common/together/spawn_vines/spawnportal_spawning",
        shatter = "dontstarve/common/together/spawn_vines/spawnportal_open",
        place = "dontstarve/common/together/spawn_portal_celestial/reveal",
        transmute_pre = "dontstarve/common/together/spawn_portal_celestial/cracking",
        transmute = "dontstarve/common/together/spawn_portal_celestial/shatter",
    } or nil
end

local function OnStartConstruction(inst)
    inst.sg:GoToState("placeconstruction")
end

local function CalculateConstructionPhase(inst)
    --single ingredients worth one phase each
    --remaining ingredient stacks worth percentage of remaining phases
    local singles_amount = 0
    local singles_total = 0
    local amount = 0
    local total = 0
    for i, v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
        if v.amount > 1 then
            amount = amount + inst.components.constructionsite:GetMaterialCount(v.type)
            total = total + v.amount
        else
            singles_amount = singles_amount + inst.components.constructionsite:GetMaterialCount(v.type)
            singles_total = singles_total + 1
        end
    end
    return (total > 0 and math.clamp(singles_amount + math.floor((3 - singles_total) * amount / total) + 1, 1, 4))
        or (singles_total > 0 and math.clamp(math.floor(3 * singles_amount / singles_total) + 1, 1, 4))
        or 1
end

local function OnConstructed(inst, doer)
    local amount = 0
    local total = 0
    for i, v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
        amount = amount + inst.components.constructionsite:GetMaterialCount(v.type)
        total = total + v.amount
    end
    inst.sg.mem.targetconstructionphase = CalculateConstructionPhase(inst)
    if not (inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("open")) then
        inst.sg:GoToState(inst.sg.mem.constructionphase >= 3 and inst.sg.mem.targetconstructionphase >= 4 and "constructionphase4" or "constructed")
    end
end

local function construction_onload(inst)--, data, newents)
    inst.sg.mem.targetconstructionphase = CalculateConstructionPhase(inst)
    inst.sg.mem.constructionphase = math.min(3, inst.sg.mem.targetconstructionphase)
    for i = 1, 3 do
        if i == inst.sg.mem.constructionphase then
            inst.AnimState:Show("stage"..tostring(i))
        else
            inst.AnimState:Hide("stage"..tostring(i))
        end
    end
    if inst.sg.mem.constructionphase == 3 then
        inst.AnimState:Hide("hidestage3")
        inst.sounds.vines = nil
    else
        inst.AnimState:Show("hidestage3")
    end
    if inst.sg.mem.targetconstructionphase ~= inst.sg.mem.constructionphase then
        inst.sg:GoToState("constructionphase"..tostring(inst.sg.mem.targetconstructionphase))
    end
end

local function construction_master_postinit(inst)
    inst.sg.mem.nofunny = true
    inst.sg.mem.constructionphase = 1
    inst.sg.mem.targetconstructionphase = 1

    inst:AddComponent("constructionsite")
    inst.components.constructionsite:SetConstructionPrefab("construction_container")
    inst.components.constructionsite:SetOnConstructedFn(OnConstructed)

    inst:ListenForEvent("onstartconstruction", OnStartConstruction)

    inst.OnLoad = construction_onload
end

local MOONROCK_SOUNDS =
{
    idle_loop = nil,
    idle = "dontstarve/common/together/spawn_vines/spawnportal_idle",
    scratch = nil,
    jacob = "dontstarve/common/together/spawn_vines/spawnportal_jacob",
    blink = nil,
    vines = nil,
    spawning_loop = "dontstarve/common/together/spawn_vines/spawnportal_spawning",
    armswing = nil,
    shake = "dontstarve/common/together/spawn_vines/spawnportal_shake",
    open = "dontstarve/common/together/spawn_vines/spawnportal_open",
    glow_loop = nil,
    shatter = nil,
    place = nil,
    transmute_pre = nil,
    transmute = nil,
}

local function moonrock_common_postinit(inst)
	inst.AnimState:OverrideSymbol("light", "portal_stone", "light")
    inst.AnimState:OverrideSymbol("portalbg", "portal_stone", "portalbg")
	inst.AnimState:OverrideSymbol("spiralfx1", "portal_stone", "spiralfx1")

    if TheWorld:HasTag("cave") then
		inst.AnimState:OverrideSymbol("FX_ray1", "portal_stone", "FX_ray1")
        inst.AnimState:Hide("eyefx")
    else
        inst.AnimState:SetLightOverride(.04)
        inst.AnimState:Hide("eye")
        inst.AnimState:Hide("eyefx")
        inst.AnimState:Hide("FX_rays")

        inst:AddTag("moonportal")
    end

    --moontrader (from moontrader component) added to pristine state for optimization
    inst:AddTag("moontrader")

    if TheWorld.ismastersim then
        inst.fx = not TheWorld:HasTag("cave") and SpawnPrefab("multiplayer_portal_moonrock_fx") or nil
        inst.sounds = MOONROCK_SOUNDS
    end
end

local function moonrock_onsleep(inst)
    if inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end
end

local MOONPORTALKEY_TAGS = { "moonportalkey" }
local function moonrock_onupdate(inst, instant)
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 8, MOONPORTALKEY_TAGS)) do
        v:PushEvent("ms_moonportalproximity", { instant = instant })
    end
end

local function moonrock_onwake(inst)
    if inst._task == nil then
        inst._task = inst:DoPeriodicTask(1, moonrock_onupdate)
        moonrock_onupdate(inst, true)
    end
end

local function moonrock_canaccept(inst, item)--, giver)
    if not item:HasTag("moonportalkey") then
        return false
    elseif TheWorld:HasTag("cave") then
        return false, "NOMOON"
    end
    return true
end

local function moonrock_onaccept(inst, giver)--, item)
    giver:PushEvent("ms_playerreroll")
    if giver.components.inventory ~= nil then
        giver.components.inventory:DropEverything()
    end

	if giver.components.leader ~= nil then
		local followers = giver.components.leader.followers
		for k, v in pairs(followers) do
			if k.components.inventory ~= nil then
				k.components.inventory:DropEverything()
			elseif k.components.container ~= nil then
				k.components.container:DropEverything()
			end
		end
	end

    inst._savedata[giver.userid] = giver.SaveForReroll ~= nil and giver:SaveForReroll() or nil
    TheWorld:PushEvent("ms_playerdespawnanddelete", giver)
end

local function moonrock_onsave(inst, data)
    data.players = next(inst._savedata) ~= nil and inst._savedata or nil
end

local function moonrock_onload(inst, data)
    inst._savedata = data ~= nil and data.players or inst._savedata
end

local function moonrock_master_postinit(inst)
    inst:AddComponent("moontrader")
    inst.components.moontrader:SetCanAcceptFn(moonrock_canaccept)
    inst.components.moontrader:SetOnAcceptFn(moonrock_onaccept)

    if not TheWorld:HasTag("cave") then
        inst.fx.entity:SetParent(inst.entity)
        inst._task = nil
        inst._savedata = {}
        inst.OnEntitySleep = moonrock_onsleep
        inst.OnEntityWake = moonrock_onwake
        inst.OnSave = moonrock_onsave
        inst.OnLoad = moonrock_onload

        inst:ListenForEvent("ms_newplayerspawned", function(world, player)
            if inst._savedata[player.userid] ~= nil then
                if player.LoadForReroll ~= nil then
                    player:LoadForReroll(inst._savedata[player.userid])
                end
                inst._savedata[player.userid] = nil
            end
        end, TheWorld)

        inst:ListenForEvent("ms_playerjoined", function(world, player)
            --In case despawn never finished after saving for reroll
            inst._savedata[player.userid] = nil
        end, TheWorld)
    end
end

local function moonrockfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("portal_moonrock_dst")
    inst.AnimState:SetBuild("portal_moonrock")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:Hide("portal")
	inst.AnimState:OverrideSymbol("FX_ray1", "portal_stone", "FX_ray1")
    inst.AnimState:SetLightOverride(.2)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return MakePortal("multiplayer_portal", "portal_dst", "portal_stone", assets_stone, nil, stone_common_postinit),
    MakePortal("multiplayer_portal_moonrock_constr", "portal_construction_dst", "portal_stone", assets_construction, prefabs_construction, construction_common_postinit, construction_master_postinit),
    MakePortal("multiplayer_portal_moonrock", "portal_moonrock_dst", "portal_moonrock", assets_moonrock, prefabs_moonrock, moonrock_common_postinit, moonrock_master_postinit),
    Prefab("multiplayer_portal_moonrock_fx", moonrockfxfn, assets_fx)
