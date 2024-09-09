local song_tunings = require("prefabs/battlesongdefs").song_defs

local function oninspirationdelta(inst)
    if inst._owner and inst._owner.components.singinginspiration and
    inst._owner.components.singinginspiration:CanAddSong(inst.songdata, inst) then
        inst.components.inventoryitem:ChangeImageName(inst.prefab)
    else
        inst.components.inventoryitem:ChangeImageName(inst.prefab.."_unavaliable")
    end
end

local function updateinvimage(inst, owner)
    if owner and owner.components.container ~= nil then

        -- We've been moved from an equipped backpack into a different container, yeehaw
        if inst._container ~= nil and owner ~= inst._container and
            (inst._container.components.equippable and inst._container.components.equippable:IsEquipped()) then
            inst:RemoveEventCallback("unequipped", inst._onunequipped, inst._container)
        end


        inst._container = owner
        local grand_owner = owner.components.inventoryitem and owner.components.inventoryitem:GetGrandOwner()

        -- We've been put on an already equipped backpack
        if owner.components.equippable ~= nil and owner.components.equippable:IsEquipped() and grand_owner ~= nil then
            owner = grand_owner
            inst:ListenForEvent("unequipped", inst._onunequipped, inst._container)

        -- We've been put on an unnequipped backpack
        elseif owner.components.equippable ~= nil then
            inst:ListenForEvent("equipped", inst._onequipped, inst._container)
        else
            -- We're in a chest likely
            owner = nil
        end

    -- We've been dropped or put on a regular inventory
    elseif inst._container ~= nil then
        if inst._container.components.equippable and inst._container.components.equippable:IsEquipped() then
            inst:RemoveEventCallback("unequipped", inst._onunequipped, inst._container)
        end

        inst._container = nil
    end

    if owner and owner ~= inst._owner then
        if inst._owner and not inst._owner:HasTag("backpack") then
            inst:RemoveEventCallback("inspirationdelta", inst._oninspirationdelta, inst._owner)
        end

        inst._owner = owner
        oninspirationdelta(inst)

        if not inst._owner:HasTag("backpack") then
            inst:ListenForEvent("inspirationdelta", inst._oninspirationdelta, owner)
        end

    elseif not owner and inst._owner then
        if not inst._owner:HasTag("backpack") then
            inst:RemoveEventCallback("inspirationdelta", inst._oninspirationdelta, inst._owner)
        end

        inst._owner = nil
    end
end

local function onunequipped(inst, container)
    inst:RemoveEventCallback("unequipped", inst._onunequipped, container)
    inst:UpdateInvImage(container)
end

local function onequipped(inst, container, owner)
    inst:RemoveEventCallback("equipped", inst._onequipped, container)
    inst:UpdateInvImage(container)
end

local function IsBattleSong(item)
    return item:HasTag("battlesong")
end

local function OnPutInInventory(inst, owner)
    inst:UpdateInvImage(owner)

    if owner ~= nil and
        owner:HasTag("battlesinger") and
        owner.components.skilltreeupdater ~= nil and
        not owner.components.skilltreeupdater:IsActivated("wathgrithr_songs_container")
    then
        local battlesongs = owner.components.inventory:FindItems(IsBattleSong)

        local battlesongs_prefabs = {}

        for i, item in ipairs(battlesongs) do
            battlesongs_prefabs[item.prefab] = true
        end

        if GetTableSize(battlesongs_prefabs) >= TUNING.SKILLS.WATHGRITHR.BATTLESONGS_CONTAINER_NUM_BATTLESONGS_TO_UNLOCK then
            SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, owner.userid, "wathgrithr_container_unlocked")
        end
    end
end


local function song_fn(songdata, prefabname)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("battlesongs")
    inst.AnimState:SetBuild("battlesongs")
    inst.AnimState:PlayAnimation(prefabname)

    MakeInventoryFloatable(inst)

    inst:AddTag("battlesong")

    inst.songdata = songdata

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.UpdateInvImage = updateinvimage

	-- inst:AddComponent("finiteuses")
 --    inst.components.finiteuses:SetOnFinished(inst.Remove)
 --    inst.components.finiteuses:SetMaxUses(songdata.USES)
 --    inst.components.finiteuses:SetUses(songdata.USES)

    if inst.songdata.INSTANT then
        inst:AddComponent("rechargeable")
        inst.components.rechargeable:SetOnDischargedFn(oninspirationdelta)
        inst.components.rechargeable:SetOnChargedFn(oninspirationdelta)
    end

    inst:AddComponent("singable")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    MakeHauntableLaunch(inst)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)

    inst._oninspirationdelta = function(owner) oninspirationdelta(inst) end
    inst._onequipped = function(container, data) onequipped(inst, container, data.owner) end
    inst._onunequipped = function(container, data) onunequipped(inst, container) end

    inst:ListenForEvent("ondropped", inst.UpdateInvImage)

    return inst
end

local function SpawnFx(fx, target, scale, xOffset, yOffset, zOffset)
    local fx = SpawnPrefab(fx)
    fx.Transform:SetNoFaced()

    if fx then
        xOffset = xOffset or 0
        yOffset = yOffset or 0
        zOffset = zOffset or 0

        if target.components.rider ~= nil and target.components.rider:IsRiding() then
            yOffset = yOffset + 2.3
            xOffset = xOffset + 0.5
            zOffset = zOffset + 0.5
        end

        target:AddChild(fx)
        fx.Transform:SetPosition(xOffset, yOffset, zOffset)

        scale = scale or 1
        fx.Transform:SetScale(scale, scale, scale)
    end

    return fx
end

local function GetHorizontalOffset()
    local mult = math.random(-1, 1)
    return math.random()/2 * mult
end

local function CheckForLoopFx(inst, target)

    -- Only display the fx on the targets rather than the singers
    if inst.songdata.LOOP_FX and target.battlesong_fx_task == nil and
        (target.components.singinginspiration == nil or not target.components.singinginspiration:IsSinging()) then

        target.battlesong_fx_task = inst:DoPeriodicTask(4 + math.random(), function()
            -- If the target is a singer and suddenly starts singing we want the trebleclef fx to vanish
            if target.components.singinginspiration ~= nil and target.components.singinginspiration:IsSinging() then
                target.battlesong_fx_task:Cancel()
                target.battlesong_fx_task = nil
            else
                SpawnFx("battlesong_loop", target, 0.4, GetHorizontalOffset(), 1.6 + math.random()/5, GetHorizontalOffset())
            end
        end)
    end
end

local function buff_OnTick(inst, target)
    if inst.expire_time - GetTime() <= 0 then
        inst.components.debuff:Stop()
		return
    end

    CheckForLoopFx(inst, target)

    if target.components.health ~= nil and not target.components.health:IsDead() then
        if inst.songdata.TICK_FN ~= nil then
            inst.songdata.TICK_FN(inst, target)
        end
    else
        inst.components.debuff:Stop()
    end
end

local function buff_OnAttached(inst, target)
	inst.entity:SetParent(target.entity)
	inst.Transform:SetPosition(0, 0, 0) --in case of loading

	if inst.songdata.ONAPPLY ~= nil then
		inst.songdata.ONAPPLY(inst, target)
	end

    if inst.songdata.ATTACH_FX then
        inst:DoTaskInTime(math.random(), function() SpawnFx(inst.songdata.ATTACH_FX, target, 0.7) end)
    end

	inst.expire_time = GetTime() + TUNING.SONG_REFRESH_PERIOD
	inst.task = inst:DoPeriodicTask(TUNING.SONG_REFRESH_PERIOD, buff_OnTick, TUNING.SONG_REFRESH_PERIOD + math.random(), target)

    if target.battlesong_count == nil then
        target.battlesong_count = 0
    end

	if target.player_classified ~= nil then
		target.player_classified.hasinspirationbuff:set(true)
	end

    target.battlesong_count = target.battlesong_count + 1
    CheckForLoopFx(inst, target)

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
end

local function buff_OnExtended(inst, target)
	inst.expire_time = GetTime() + TUNING.SONG_REFRESH_PERIOD

    if inst.songdata.ONEXTENDED ~= nil then
        inst.songdata.ONEXTENDED(inst, target)
    end
end

local function buff_OnDetached(inst, target)
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = nil
	end

    target.battlesong_count = target.battlesong_count - 1

    if target.battlesong_count <= 0 then
		if target.player_classified ~= nil then
			target.player_classified.hasinspirationbuff:set(false)
		end

        if target.battlesong_fx_task ~= nil then
            target.battlesong_fx_task:Cancel()
            target.battlesong_fx_task = nil
        end

    	if inst.songdata.DETACH_FX then
    		local fx = SpawnFx(inst.songdata.DETACH_FX, target, 1)
    		--fx.AnimState:SetMultColour(1, 0, 0, 1)
    	end
    end

	if inst.songdata.ONDETACH ~= nil then
		inst.songdata.ONDETACH(inst, target)
	end

	inst:Remove()
end

local function buff_fn(songdata, dodelta_fn)
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

	inst.songdata = songdata

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(buff_OnAttached)
    inst.components.debuff:SetDetachedFn(buff_OnDetached)
    inst.components.debuff:SetExtendedFn(buff_OnExtended)

    return inst
end

local function AddSong(songs, name, songdata)
	local assets = 	{
        Asset("ANIM", "anim/battlesongs.zip"),
        Asset("INV_IMAGE", name.."_unavaliable"),
		Asset("SCRIPT", "scripts/prefabs/battlesongdefs.lua"),
	}

	local prefabs = {}
	if not songdata.INSTANT then table.insert(prefabs, songdata.NAME) end
	if songdata.ATTACH_FX then table.insert(prefabs, songdata.ATTACH_FX) end
	if songdata.DETACH_FX then table.insert(prefabs, songdata.DETACH_FX) end

	table.insert(songs, Prefab(name, function() return song_fn(songdata, name) end, assets, prefabs))
	if not songdata.INSTANT then
		table.insert(songs, Prefab(songdata.NAME, function() return buff_fn(songdata) end))
	end
end


local songs = {}
for k, v in pairs(song_tunings) do
	AddSong(songs, k, v)
end

return unpack(songs)