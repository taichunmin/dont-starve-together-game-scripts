local assets =
{
    Asset("ANIM", "anim/sand_spike.zip"),
    Asset("ANIM", "anim/swap_glass_spike.zip"),
    Asset("INV_IMAGE", "glassspike"),
}

local block_assets =
{
    Asset("ANIM", "anim/sand_block.zip"),
    Asset("ANIM", "anim/swap_glass_block.zip"),
}

local SPIKE_SIZES =
{
    "short",
    "med",
    "tall",
}

local RADIUS =
{
    ["short"] = .12,
    ["med"] = .25,
    ["tall"] = .3,
    ["block"] = .45,
}

local function onequipspike(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_glass_spike", "swap_body_"..inst.animname)
end

local function onequipblock(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_glass_block", "swap_body")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function onworked(inst)
    inst.AnimState:PlayAnimation(inst.animname.."_glass_hit")
end

local function onworkfinished(inst)
    inst:AddTag("NOCLICK")
    inst.Physics:SetActive(false)
    inst.OnEntitySleep = nil
    inst.OnEntityWake = nil
    inst:ListenForEvent("animover", ErodeAway)
    inst.AnimState:PlayAnimation(inst.animname.."_glass_break")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/glass_break")
end

local function Sparkle(inst)
    if inst.sparkletask ~= nil then
        inst.sparkletask:Cancel()
    end
    if inst:IsAsleep() or inst.components.workable.workleft <= 0 then
        inst.sparkletask = nil
    else
        inst.sparkletask = inst:DoTaskInTime(4 + math.random() * 5, Sparkle)
        inst.AnimState:PushAnimation(inst.animname.."_glass_sparkle"..tostring(math.random(3)), false)
    end
end

local function OnEntitySleep(inst)
    if inst.sparkletask ~= nil then
        inst.sparkletask:Cancel()
        inst.sparkletask = nil
    end
end

local function OnEntityWake(inst)
    if inst.sparkletask == nil then
        inst.sparkletask = inst:DoTaskInTime(4 + math.random() * 5, Sparkle)
    end
end

local function MakeSpikeFn(shape, size)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        if shape == "spike" then
            inst.spikesize = size or SPIKE_SIZES[math.random(#SPIKE_SIZES)]
            inst.animname = inst.spikesize
            if size == nil then
                inst:SetPrefabName("glassspike_"..inst.spikesize)
            end
            inst:SetPrefabNameOverride("glassspike")
        else
            inst.animname = "block"
        end
        inst.spikeradius = RADIUS[inst.animname]

        inst.AnimState:SetBank("sand_"..shape)
        inst.AnimState:SetBuild("sand_"..shape)
        inst.AnimState:PlayAnimation(inst.animname.."_glass_idle")

        inst:AddTag("heavy")

        MakeHeavyObstaclePhysics(inst, inst.spikeradius)

        inst.scrapbook_proxy = "glass"..shape

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.scrapbook_anim = shape == "spike" and "tall_glass_idle" or "block_glass_idle"

        inst:AddComponent("heavyobstaclephysics")
        inst.components.heavyobstaclephysics:SetRadius(inst.spikeradius)

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.cangoincontainer = false
        inst.components.inventoryitem:SetSinks(true)

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

        if shape == "spike" then
            inst.components.inventoryitem:ChangeImageName("glassspike")
            inst.components.equippable:SetOnEquip(onequipspike)
        else
            inst.components.equippable:SetOnEquip(onequipblock)
        end

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnWorkCallback(onworked)
		inst.components.workable:SetOnFinishCallback(onworkfinished)

		inst:AddComponent("submersible")
		inst:AddComponent("symbolswapdata")
		if shape == "spike" then
			inst.components.symbolswapdata:SetData("swap_glass_spike", "swap_body_"..inst.animname)
		else
			inst.components.symbolswapdata:SetData("swap_glass_block", "swap_body")
		end

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst.sparkletask = nil

        inst.Sparkle = Sparkle
        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake

        return inst
    end
end

--For searching: glassspike_short, glassspike_med, glassspike_tall
local prefabs = {}
local ret = {}
for i, v in ipairs(SPIKE_SIZES) do
    local name = "glassspike_"..v
    table.insert(prefabs, name)
    table.insert(ret, Prefab(name, MakeSpikeFn("spike", v), assets))
end
table.insert(prefabs, "underwater_salvageable")
table.insert(prefabs, "splash_green")
table.insert(ret, Prefab("glassspike", MakeSpikeFn("spike"), assets, prefabs))
prefabs = nil

table.insert(ret, Prefab("glassblock", MakeSpikeFn("block"), block_assets, { "underwater_salvageable" }))

return unpack(ret)
