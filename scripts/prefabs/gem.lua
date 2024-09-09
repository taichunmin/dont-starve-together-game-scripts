local assets =
{
    Asset("ANIM", "anim/gems.zip"),
}

local FLOATER_PROPERTIES =
{
    ["purple"]  = {0.10, 0.80},
    ["blue"]    = {0.10, 0.80},
    ["red"]     = {0.10, 0.80},
    ["orange"]  = {0.10, 0.82},
    ["yellow"]  = {0.10, 0.85},
    ["green"]   = {0.05, 0.75},
    ["opal"]    = {0.10, 0.87},
}

local function buildgem(colour, precious)
    local function Sparkle(inst)
        if not inst.AnimState:IsCurrentAnimation(colour.."gem_sparkle") then
            inst.AnimState:PlayAnimation(colour.."gem_sparkle")
            inst.AnimState:PushAnimation(colour.."gem_idle", true)
        end
        inst:DoTaskInTime(4 + math.random(), Sparkle)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("gems")
        inst.AnimState:SetBuild("gems")
        inst.AnimState:PlayAnimation(colour.."gem_idle", true)
        inst.scrapbook_anim = colour.."gem_idle"

        inst:AddTag("molebait")
        inst:AddTag("quakedebris")
        inst:AddTag("gem")

        inst.pickupsound = "gem"

        inst.colour = colour

        local fp = FLOATER_PROPERTIES[colour]
        MakeInventoryFloatable(inst, "small", fp[1], fp[2])

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("edible")
        inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
        inst:AddComponent("tradable")
        inst.components.edible.hungervalue = 5

        inst:AddComponent("bait")

        inst:AddComponent("repairer")
        inst.components.repairer.repairmaterial = MATERIALS.GEM
        inst.components.repairer.workrepairvalue = TUNING.REPAIR_GEMS_WORK

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")

        MakeHauntableLaunchAndSmash(inst)

        inst:DoTaskInTime(1, Sparkle)

        return inst
    end
    return Prefab(colour..(precious and "preciousgem" or "gem"), fn, assets)
end

return buildgem("purple"),
    buildgem("blue"),
    buildgem("red"),
    buildgem("orange"),
    buildgem("yellow"),
    buildgem("green"),
    buildgem("opal", true)
