local assets =
{
    Asset("ANIM", "anim/flare_large.zip"),
    Asset("INV_IMAGE", "miniflare"),
}

local prefabs =
{
    "megaflare_minimap",
}

local minimap_assets =
{
    Asset("MINIMAP_IMAGE", "flare"),
    Asset("MINIMAP_IMAGE", "flare2"),
    Asset("MINIMAP_IMAGE", "flare3"),
}

local minimap_prefabs =
{
    "globalmapicon",
}

local function RemoveHudIndicator(inst)  -- client code
	if ThePlayer ~= nil and ThePlayer.HUD ~= nil then
		ThePlayer.HUD:RemoveTargetIndicator(inst)
	end
end

local function SetupHudIndicator(inst) -- client code
	ThePlayer.HUD:AddTargetIndicator(inst, {image = "avatar_megaflare.tex"})
	inst:DoTaskInTime(TUNING.MINIFLARE.HUD_INDICATOR_TIME, RemoveHudIndicator)
	inst:ListenForEvent("onremove", RemoveHudIndicator)
end

local function ClearCooldown(inst)
    inst._megaflarecooldown = nil
end

local function show_flare_hud(inst)
    -- While we don't access the HUD directly, we're trying to send a HUD event,
    -- so if the HUD isn't there we don't need to do any work.
    if ThePlayer ~= nil then
        local fx, fy, fz = inst.Transform:GetWorldPosition()
        local px, py, pz = ThePlayer.Transform:GetWorldPosition()
        local sq_dist_to_flare = distsq(fx, fz, px, pz)

        if ThePlayer.HUD ~= nil then
            if sq_dist_to_flare < TUNING.MINIFLARE.HUD_MAX_DISTANCE_SQ then
                ThePlayer:PushEvent("startflareoverlay",{r=1,g=0.6,b=0.6})
		    else
			    SetupHudIndicator(inst)
            end
        end

        local near_audio_gate_distsq = TUNING.MINIFLARE.HUD_MAX_DISTANCE_SQ
        local far_audio_gate_distsq = TUNING.MINIFLARE.FAR_AUDIO_GATE_DISTANCE_SQ
        local volume = (sq_dist_to_flare > far_audio_gate_distsq and TUNING.MINIFLARE.BASE_VOLUME)
                or (sq_dist_to_flare > near_audio_gate_distsq and
                        TUNING.MINIFLARE.BASE_VOLUME + (1 - Remap(sq_dist_to_flare, near_audio_gate_distsq, far_audio_gate_distsq, 0, 1)) * (1-TUNING.MINIFLARE.BASE_VOLUME)
                    )
                or 1.0
            if ThePlayer._megaflarecooldown == nil then
            inst.SoundEmitter:PlaySound("wickerbottom_rework/megaflare/explode", nil, volume)
            ThePlayer._megaflarecooldown = ThePlayer:DoTaskInTime(0.1, ClearCooldown)
            end
    end
end

local function do_flare_minimap_swap(inst)
    local flare_index = math.random(1, 2)
    if flare_index == inst._small_minimap then
        flare_index = 3
    end
    inst._small_minimap = flare_index

    local flare_image = (flare_index == 1 and "flare.png") or ("flare"..flare_index..".png")

    inst.MiniMapEntity:SetIcon(flare_image)
    inst.icon.MiniMapEntity:SetIcon(flare_image)
end

local function show_flare_minimap(inst)
    -- Create a global map icon so the minimap icon is visible to other players as well.
    inst.icon = SpawnPrefab("globalmapicon")
    inst.icon:TrackEntity(inst)
    inst.icon.MiniMapEntity:SetPriority(21)

    inst:DoPeriodicTask(TUNING.MINIFLARE.ANIM_SWAP_TIME, do_flare_minimap_swap)
end

local function flare_minimap()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)
    inst.MiniMapEntity:SetIcon("flare.png")
    inst.MiniMapEntity:SetPriority(21)

	inst:SetPrefabNameOverride("MINIFLARE")

    inst.entity:SetCanSleep(false)

    inst:DoTaskInTime(0, show_flare_hud)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(0, show_flare_minimap)

    inst.persists = false

    inst._small_minimap = 1

    return inst
end

local function on_ignite_over(inst)
    local fx, fy, fz = inst.Transform:GetWorldPosition()

    local random_angle = math.pi * 2 * math.random()
    local random_radius = -(TUNING.MINIFLARE.OFFSHOOT_RADIUS) + (math.random() * 2 * TUNING.MINIFLARE.OFFSHOOT_RADIUS)

    fx = fx + (random_radius * math.cos(random_angle))
    fz = fz + (random_radius * math.sin(random_angle))

    -------------------------------------------------------------
    -- Find talkers to say speech.
    for _, player in ipairs(AllPlayers) do
        if player._miniflareannouncedelay == nil and math.random() > TUNING.MINIFLARE.CHANCE_TO_NOTICE then
            local px, py, pz = player.Transform:GetWorldPosition()
            local sq_dist_to_flare = distsq(fx, fz, px, pz)
            if sq_dist_to_flare > TUNING.MINIFLARE.SPEECH_MIN_DISTANCE_SQ then
				player._miniflareannouncedelay = player:DoTaskInTime(TUNING.MINIFLARE.NEXT_NOTICE_DELAY, function(i) i._miniflareannouncedelay = nil end) -- so gross, if this logic gets any more complicated then make a component
                player.components.talker:Say(GetString(player, "ANNOUNCE_MEGA_FLARE_SEEN"))
            end
        end
    end

    -------------------------------------------------------------
    -- Create an entity to cover the close-up minimap icon; the 'globalmapicon' doesn't cover this.
    local minimap = SpawnPrefab("megaflare_minimap")
    minimap.Transform:SetPosition(fx+10, fy, fz)
    minimap.color_r = 1
    minimap.color_g = 0.6
    minimap.color_b = 0.6
    minimap:DoTaskInTime(TUNING.MINIFLARE.TIME, function()
        minimap:Remove()
    end)

    local minimap = SpawnPrefab("megaflare_minimap")
    minimap.Transform:SetPosition(fx, fy, fz+10)
    minimap:DoTaskInTime(TUNING.MINIFLARE.TIME, function()
        minimap:Remove()
    end)

    local minimap = SpawnPrefab("megaflare_minimap")
    minimap.Transform:SetPosition(fx-5, fy, fz-5)   
    minimap:DoTaskInTime(TUNING.MINIFLARE.TIME, function()
        minimap:Remove()
    end)


    TheWorld:PushEvent("megaflare_detonated",{sourcept = Vector3(inst.Transform:GetWorldPosition()), pt=Vector3(fx, fy, fz)})

    inst:Remove()
end

local function on_ignite(inst)
    -- We've been set off; we shouldn't save anymore.
    inst.persists = false
    inst.entity:SetCanSleep(false)

    inst.AnimState:PlayAnimation("fire")
    inst:ListenForEvent("animover", on_ignite_over)

    inst.SoundEmitter:PlaySound("turnoftides/common/together/miniflare/launch")
end

local function on_dropped(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
end

local function flare_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("flare_large")
    inst.AnimState:SetBuild("flare_large")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "large", nil, {0.65, 0.4, 0.65})

    inst:AddTag("donotautopick")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("burnable")
    inst.components.burnable:SetOnIgniteFn(on_ignite)

    MakeSmallPropagator(inst)
    inst.components.propagator.heatoutput = 0
    inst.components.propagator.damages = false

    MakeHauntableLaunch(inst)

    inst:ListenForEvent("ondropped", on_dropped)
    inst:ListenForEvent("floater_startfloating", function(inst) inst.AnimState:PlayAnimation("float") end)
    inst:ListenForEvent("floater_stopfloating", function(inst) inst.AnimState:PlayAnimation("idle") end)

    return inst
end

return Prefab("megaflare", flare_fn, assets, prefabs),
        MakePlacer("megaflare_placer", "flare", "flare", "idle"),
        Prefab("megaflare_minimap", flare_minimap, minimap_assets, minimap_prefabs)
