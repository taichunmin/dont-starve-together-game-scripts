local assets =
{
    Asset("ANIM", "anim/boat_leak.zip"),
    Asset("ANIM", "anim/boat_leak_build.zip"),
    Asset("ANIM", "anim/boat_leak_ancient_build.zip"),
}

local BLOCK_RADIUS = 0.4

local function onsprungleak(inst)
    if inst.components.inspectable == nil then
        inst:AddComponent("inspectable")

        inst:AddComponent("hauntable")
        inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY

        inst._wettargets = {}
        inst.components.updatelooper:AddOnUpdateFn(inst.FindLeakBlocker)
    end

    inst:RemoveTag("NOCLICK")
    inst:RemoveTag("NOBLOCK")
end

local function onrepairedleak(inst)
    if inst.components.inspectable ~= nil then
        inst:RemoveComponent("inspectable")

        inst:RemoveComponent("hauntable")

        inst.components.updatelooper:RemoveOnUpdateFn(inst.FindLeakBlocker)

        for target in pairs(inst._wettargets) do
            if target.components.moisture ~= nil then
                target.components.moisture:RemoveRateBonus(inst)
            end
        end

        inst._wettargets = nil
    end

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
end

local function checkforleakimmune(inst)
    local boat = inst:GetCurrentPlatform()
    if not boat or boat.components.hullhealth.leakproof then
        local x, y, z = inst.Transform:GetWorldPosition()
        print("Warning: A boat leak tried to spawn on land or a leakproof boat at", x, y, z)
        inst:Remove()
    end
end

local function SpikeLaunch(inst, launcher, basespeed, startheight, startradius)
    local x0, y0, z0 = launcher.Transform:GetWorldPosition()
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local dx, dz = x1 - x0, z1 - z0
    local dsq = dx * dx + dz * dz
    local angle
    if dsq > 0 then
        local dist = math.sqrt(dsq)
        angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
    else
        angle = TWOPI * math.random()
    end
    local sina, cosa = math.sin(angle), math.cos(angle)
    local speed = basespeed + math.random()
    inst.Physics:Teleport(x0 + startradius * cosa, startheight, z0 + startradius * sina)
    inst.Physics:SetVel(cosa * speed, speed * 5 + math.random() * 2, sina * speed)
end

local function OnEndFlung(inst)
    inst:RemoveEventCallback("enterlimbo", OnEndFlung)
    inst:RemoveEventCallback("on_landed",  OnEndFlung)

    ChangeToInventoryItemPhysics(inst)
end

local function JiggleItems(items)
    for item, _ in pairs(items) do
        if item.components.mine ~= nil then
            item.components.mine:Deactivate()
        end

        if not item.components.inventoryitem.nobounce and item.Physics ~= nil and item.Physics:IsActive() then
            item.Physics:SetVel(0, 3 ,0)

            item.components.inventoryitem:SetLanded(false, true)

            RemovePhysicsColliders(item)
            item:ListenForEvent("enterlimbo", OnEndFlung)
            item:ListenForEvent("on_landed",  OnEndFlung)
        end
    end
end

local function LaunchItems(items, launcher)
    for item, _ in pairs(items) do
        if item.components.mine ~= nil then
            item.components.mine:Deactivate()
        end

        if not item.components.inventoryitem.nobounce and item.Physics ~= nil and item.Physics:IsActive() then
            SpikeLaunch(item, launcher, 3, .6, BLOCK_RADIUS + item:GetPhysicsRadius(0))

            item.components.inventoryitem:SetLanded(false, true)

            RemovePhysicsColliders(item)
            item:ListenForEvent("enterlimbo", OnEndFlung)
            item:ListenForEvent("on_landed",  OnEndFlung)
        end
    end
end

local LEAK_BLOCKER_ONEOF_TAGS = { "_inventoryitem", "player", "creature", "animal", "largecreature", "smallcreature", "monster" }
local LEAK_BLOCKER_CANT_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "flying" }

local function FindLeakBlocker(inst, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, BLOCK_RADIUS, nil, LEAK_BLOCKER_CANT_TAGS, LEAK_BLOCKER_ONEOF_TAGS)

    if ents == nil or #ents <= 0 then
        inst.launchtime = nil
        inst.jiggletime = nil

        inst.components.boatleak:SetPlugged(false)

        for target in pairs(inst._wettargets) do
            if target.components.moisture ~= nil then
                target.components.moisture:RemoveRateBonus(inst)
            end
        end

        inst._wettargets = {}

        return
    end

    inst.components.boatleak:SetPlugged(true)

    local inventoryitems = {}
    local heavyitem = false

    for i, ent in ipairs(ents) do
        local moisture = ent.components.moisture

        if moisture ~= nil then
            if not inst._wettargets[ent] then
                inst._wettargets[ent] = true
                moisture:AddRateBonus(inst, TUNING.BOATLEAK_PLUG_WETNESS)
            end
        end

        heavyitem = heavyitem or ent.components.floater == nil

        if ent.components.inventoryitem ~= nil then
            inventoryitems[ent] = true
        end
    end

    for target in pairs(inst._wettargets) do
        if not target:IsValid() or target.components.moisture == nil then
            inst._wettargets[target] = nil

        elseif not table.contains(ents, target) then
            if target.components.moisture ~= nil then
                target.components.moisture:RemoveRateBonus(inst)
            end

            inst._wettargets[target] = nil
        end
    end

    if IsTableEmpty(inventoryitems) then
        inst.launchtime = nil
        inst.jiggletime = nil

    else
        local mult = heavyitem and 0.3 or 1

        if inst.launchtime == nil then
            inst.launchtime = TUNING.BOAT_LEAK_PLUGGED_TIME + math.random() * TUNING.BOAT_LEAK_PLUGGED_TIME_VARIANCE

        else
            inst.launchtime = inst.launchtime - (dt * mult)

            if inst.launchtime < 4 then
                if inst.jiggletime == nil then
                    JiggleItems(inventoryitems)

                    inst.jiggletime = 0.10 + math.random()*0.07

                else
                    inst.jiggletime = inst.jiggletime - dt

                    if inst.jiggletime <= 0 then
                        inst.jiggletime = nil
                    end
                end
            end

            if inst.launchtime <= 0 then
                LaunchItems(inventoryitems, inst)

                inst.launchtime = nil
                inst.jiggletime = nil
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boat_leak")
    inst.AnimState:SetBuild("boat_leak_build")

    inst:AddTag("boatleak")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.FindLeakBlocker = FindLeakBlocker

    inst.persists = false

    inst:AddComponent("updatelooper")
    inst:AddComponent("lootdropper")

    inst:AddComponent("boatleak")
    inst.components.boatleak.onsprungleak = onsprungleak
    inst.components.boatleak.onrepairedleak = onrepairedleak

    inst:DoTaskInTime(0, checkforleakimmune) -- NOTES(JBK): This is now just a last resort safeguard checker.

    return inst
end

return Prefab("boat_leak", fn, assets)
