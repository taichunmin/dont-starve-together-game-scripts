local assets =
{
    Asset("ANIM", "anim/fan.zip"),
}

local assets_perd =
{
    Asset("ANIM", "anim/fan.zip"),
}

local prefabs_perd =
{
    "tornado",
}

local FANTARGET_CANT_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost" }
local FANTARGET_ONEOF_TAGS = { "smolder", "fire", "player" }
local function OnUse(inst, target)
    local x, y, z = target.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.FEATHERFAN_RADIUS, nil, FANTARGET_CANT_TAGS, FANTARGET_ONEOF_TAGS)
    for i, v in pairs(ents) do
        if v.components.burnable ~= nil then
            -- Extinguish smoldering/fire and reset the propagator to a heat of .2
            v.components.burnable:Extinguish(true, 0)
        end
        if v.components.temperature ~= nil then
            -- cool off yourself and any other nearby players
            v.components.temperature:DoDelta(math.clamp(TUNING.FEATHERFAN_MINIMUM_TEMP - v.components.temperature:GetCurrent(), TUNING.FEATHERFAN_COOLING, 0))
        end
    end
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function OnChanneling(inst, target)
    if inst.components.finiteuses:GetUses() > 3 then
        local pos =
            (target ~= nil and target:GetPosition()) or
            (inst.components.inventoryitem.owner ~= nil and inst.components.inventoryitem.owner:GetPosition()) or
            nil
        if pos ~= nil then
            local angle
            if inst.lasttornadoangle == nil then
                angle = math.random() * 2 * PI
                inst.lasttornadoangle = angle
            else
                angle = inst.lasttornadoangle + PI
                inst.lasttornadoangle = nil
            end
            local offset = FindWalkableOffset(pos, angle, 4, 8, false, true, NoHoles)
            if offset ~= nil then
                inst.components.finiteuses:Use(2)

                local tornado = SpawnPrefab("tornado")
                tornado:SetDuration(TUNING.PERDFAN_TORNADO_LIFETIME)
                tornado.WINDSTAFF_CASTER = inst.components.inventoryitem.owner
                tornado.WINDSTAFF_CASTER_ISPLAYER = tornado.WINDSTAFF_CASTER ~= nil and tornado.WINDSTAFF_CASTER:HasTag("player")
                tornado.Transform:SetPosition(pos.x + offset.x * .5, 0, pos.z + offset.z * .5)
                pos.x = pos.x + offset.x
                pos.y = 0
                pos.z = pos.z + offset.z
                tornado.components.knownlocations:RememberLocation("target", pos)

                if tornado.WINDSTAFF_CASTER_ISPLAYER then
                    tornado.overridepkname = tornado.WINDSTAFF_CASTER:GetDisplayName()
                    tornado.overridepkpet = true
                end
            end
        end
    end
end

local function common_fn(overridesymbol, onchannelingfn)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("fan")
    inst.AnimState:SetBuild("fan")
    inst.AnimState:PlayAnimation("idle")

    if overridesymbol ~= nil then
        inst.AnimState:OverrideSymbol("swap_fan", "fan", overridesymbol)
    end

    inst:AddTag("fan")
    if onchannelingfn ~= nil then
        --channelingfan (from fan component) added to pristine state for optimization
        inst:AddTag("channelingfan")
    end

    local swap_data = {bank = "fan", anim = "idle"}
    MakeInventoryFloatable(inst, nil, nil, nil, nil, nil, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("fan")
    inst.components.fan:SetOnUseFn(OnUse)
    if onchannelingfn ~= nil then
        inst.components.fan:SetOnChannelingFn(onchannelingfn)
    end
    if overridesymbol ~= nil then
        inst.components.fan:SetOverrideSymbol(overridesymbol)
    end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.FAN, 1)

    MakeHauntableLaunch(inst)

    return inst
end

local function feather_fn()
    local inst = common_fn()

    inst.components.floater:SetSize("med")
    inst.components.floater:SetVerticalOffset(0.05)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.finiteuses:SetMaxUses(TUNING.FEATHERFAN_USES)
    inst.components.finiteuses:SetUses(TUNING.FEATHERFAN_USES)

    return inst
end

local function perd_fn()
    local inst = common_fn("swap_fan_perd", OnChanneling)

    local swap_data = {sym_build = "fan", sym_name = "swap_fan_perd", bank = "fan"}
    inst.components.floater:SetBankSwapOnFloat(true, -15, swap_data)
    inst.components.floater:SetSize("large")
    inst.components.floater:SetVerticalOffset(0.15)
    inst.components.floater:SetScale({0.55, 0.5, 0.55})

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.finiteuses:SetMaxUses(TUNING.PERDFAN_USES)
    inst.components.finiteuses:SetUses(TUNING.PERDFAN_USES)

    return inst
end

return Prefab("featherfan", feather_fn, assets),
    Prefab("perdfan", perd_fn, assets_perd, prefabs_perd)
