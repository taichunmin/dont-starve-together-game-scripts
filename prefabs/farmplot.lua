require "prefabutil"
require "tuning"

local assets =
{
    Asset("ANIM", "anim/farmplot.zip"),
	Asset("MINIMAP_IMAGE", "farm1"),
	Asset("MINIMAP_IMAGE", "farm2"),
	Asset("MINIMAP_IMAGE", "farm3"),
}

local prefabs =
{
    "plant_normal",
    "farmrock",
    "farmrocktall",
    "farmrockflat",
    "stick",
    "stickleft",
    "stickright",
    "burntstick",
    "burntstickleft",
    "burntstickright",
    "signleft",
    "signright",
    "fencepost",
    "fencepostright",
    "burntfencepost",
    "burntfencepostright",
    "collapse_small",
}

local back = -1
local front = 0
local left = 1.5
local right = -1.5

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    if inst.components.grower ~= nil then
        inst.components.grower:Reset()
    end
    if inst.components.lootdropper ~= nil then
        inst.components.lootdropper:DropLoot()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function setfertilityfn(inst, fert_percent)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation(
            (fert_percent <= 0 and "empty") or
            (fert_percent <= .33 and "med2") or
            (fert_percent <= .66 and "med1") or
            "full")
    end
end

local rates =
{
    TUNING.FARM1_GROW_BONUS,
    TUNING.FARM2_GROW_BONUS,
    TUNING.FARM3_GROW_BONUS,
}

local croppoints =
{
    { Vector3(0, 0, 0) },
    { Vector3(0, 0, 0) },
    { Vector3(0, 0, 0) },
}

local rock_front = 1

local decor_defs =
{
    [1] = { { signright = { { -1.1, 0, 0.5 } } } },

    [2] = { { stick = {
                        { left - 0.9, 0, back },
                        { right, 0, front },
                      }
            },
            { stickleft = {
                        { 0.0, 0, back },
                        { left, 0, front },
                      }
            },
            { stickright = {
                        { right + 0.9, 0, back },
                        { left - 0.3, 0, back + 0.5 },
                        { right + 0.3, 0, back + 0.5 },
                      }
            },
            { signleft = { { -1.0, 0, 0.5 } } }
          },

    [3] = { { signleft = { { -1.0, 0, 0.5 } } },

            -- left side
            { farmrock = {
                    { right + 3.0, 0, rock_front + 0.2 },
                    { right + 3.05, 0, rock_front - 1.5 },
                }
            },

            { farmrocktall = { { right + 3.07, 0, rock_front - 1.0 }, } },
            { farmrockflat = { { right + 3.06, 0, rock_front - 0.4 }, } },

            -- right side
            { farmrock = { { left - 3.05, 0, rock_front - 1.0 }, } },
            { farmrocktall = { { left - 3.07, 0, rock_front - 1.5 }, } },
            { farmrockflat = { { left - 3.06, 0, rock_front - 0.4 }, } },

            -- front row
            { farmrock = {
                    { right + 1.1, 0, rock_front + 0.21 },
                    { right + 2.4, 0, rock_front + 0.25 },
                }
            },

            { farmrocktall = { { right + 0.5, 0, rock_front + 0.195 }, } },

            { farmrockflat = {
                    { right + 0.0, 0, rock_front - 0.0 },
                    { right + 1.8, 0, rock_front + 0.22 },
                }
            },

            -- back row
            { farmrockflat = {

                    { left - 1.3, 0, back - 0.19 },
                }
            },

            { farmrock = {
                    { left - 0.5, 0, back - 0.21 },
                    { left - 2.5, 0, back - 0.22 },
                }
            },

            { farmrocktall = {
                    { left + 0.0, 0, back - 0.15 },
                    { left - 3.0, 0, back - 0.20 },
                    { left - 1.9, 0, back - 0.205 },
                }
            },

            { fencepost = {
                    { left - 1.0,  0, back + 0.15 },
                    { right + 0.8, 0, back + 0.15 },
                    { right + 0.3, 0, back + 0.15 },
                },
            },

            { fencepostright = {
                    { left - 0.5,  0, back + 0.15 },
                    { 0,           0, back + 0.15 },
                },
            },
          },
}

local burntdecor_defs =
{
    [2] = {
            { burntstick = {
                        { left - 0.9, 0, back },
                        { right, 0, front },
                      }
            },
            { burntstickleft = {
                        { 0.0, 0, back },
                        { left, 0, front },
                      }
            },
            { burntstickright = {
                        { right + 0.9, 0, back },
                        --{ left - 0.3, 0, back + 0.5 },
                        --{ right + 0.3, 0, back + 0.5 },
                      }
            },
          },

    [3] = { -- back row
            { burntfencepost = {
                    --{ left - 1.0,  0, back + 0.15 },
                    { right + 0.8, 0, back + 0.15 },
                    --{ right + 0.3, 0, back + 0.15 },
                },
            },

            { burntfencepostright = {
                    { left - 0.5,  0, back + 0.15 },
                    { 0,           0, back + 0.15 },
                },
            },
          },
}

local function RefreshDecor(inst, burnt)
    for i = 1, #inst.decor do
        table.remove(inst.decor):Remove()
    end
    local decor_table = burnt and burntdecor_defs or decor_defs
    for i, item_info in ipairs(decor_table[inst.level]) do
        for item_name, item_offsets in pairs(item_info) do
            for j, offset in ipairs(item_offsets) do
                local item_inst = SpawnPrefab(item_name)
                item_inst.entity:SetParent(inst.entity)
                item_inst.Transform:SetPosition(unpack(offset))
                table.insert(inst.decor, item_inst)
            end
        end
    end
end

local function OnBurntDirty(inst)
    RefreshDecor(inst, inst._burnt:value())
end

local function OnBurnt(inst)
    inst._burnt:set(true)
    if not TheNet:IsDedicated() then
        RefreshDecor(inst, true)
    end
end

local function OnBuilt(inst)
    inst.SoundEmitter:PlaySound(
        inst.level < 3 and
        "dontstarve/common/farm_basic_craft" or
        "dontstarve/common/farm_improved_craft"
    )
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function getstatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (not inst.components.grower:IsFertile() and "NEEDSFERTILIZER")
        or (not inst.components.grower:IsEmpty() and "GROWING")
        or nil
end

local function OnHaunt(inst, haunter)
    if inst.components.grower ~= nil and
        inst.components.grower.cycles_left > 0 and
        math.random() <= TUNING.HAUNT_CHANCE_ALWAYS then
        inst.components.grower.cycles_left = math.max(0, inst.components.grower.cycles_left - 1)
        setfertilityfn(inst, inst.components.grower.cycles_left / inst.components.grower.max_cycles_left)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_COOLDOWN_TINY
        return true
    end
    return false
end

local function plot(level)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst:AddTag("structure")

        inst.AnimState:SetBank("farmplot")
        inst.AnimState:SetBuild("farmplot")
        inst.AnimState:PlayAnimation("full")
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(3)

        inst.MiniMapEntity:SetIcon("farm"..level..".png")

        --inst.Transform:SetRotation(45)

        inst.level = level
        inst._burnt = net_bool(inst.GUID, "farmplot._burnt", "burntdirty")

        --Dedicated server does not need to spawn the local decor
        if not TheNet:IsDedicated() then
            inst.decor = {}
            RefreshDecor(inst, false)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:ListenForEvent("burntdirty", OnBurntDirty)

            return inst
        end

        inst:AddComponent("inspectable")
        inst.components.inspectable.nameoverride = "FARMPLOT"
        inst.components.inspectable.getstatus = getstatus

        MakeLargeBurnable(inst, nil, nil, true)
        MakeMediumPropagator(inst)

        inst.OnSave = onsave
        inst.OnLoad = onload

        inst:ListenForEvent("burntup", OnBurnt)
        inst:ListenForEvent("onbuilt", OnBuilt)

        inst:AddComponent("grower")
        inst.components.grower.level = level
        inst.components.grower.onplantfn = function() inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_seeds") end
        inst.components.grower.croppoints = croppoints[level]
        inst.components.grower.growrate = rates[level]

        local cycles_per_level = { 10, 20, 30 }
        inst.components.grower.max_cycles_left = cycles_per_level[level] or 6
        inst.components.grower.cycles_left = inst.components.grower.max_cycles_left
        inst.components.grower.setfertility = setfertilityfn

        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        inst.components.workable:SetOnFinishCallback(onhammered)

        inst:AddComponent("savedrotation")

        inst:AddComponent("hauntable")
        inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
        inst.components.hauntable:SetOnHauntFn(OnHaunt)

        return inst
    end
end

local function placerdecor(level)
    return function(inst)
        --Show decor on top of the ground placer
        for i, item_info in ipairs(decor_defs[level]) do
            for item_name, item_offsets in pairs(item_info) do
                for j, offset in ipairs(item_offsets) do
                    local item_inst = SpawnPrefab(item_name)
                    item_inst:AddTag("CLASSIFIED")
                    item_inst:AddTag("NOCLICK") --not all decor pieces come with NOCLICK by default
                    item_inst:AddTag("placer")
                    item_inst.entity:SetCanSleep(false)
                    item_inst.entity:SetParent(inst.entity)
                    item_inst.Transform:SetPosition(unpack(offset))
                    item_inst.AnimState:SetLightOverride(1)
                    inst.components.placer:LinkEntity(item_inst)
                end
            end
        end
    end
end

return --Prefab("farmplot",  plot(1), assets, prefabs),
    Prefab("slow_farmplot", plot(2), assets, prefabs),
    Prefab("fast_farmplot", plot(3), assets, prefabs),
    MakePlacer("slow_farmplot_placer", "farmplot", "farmplot", "full", true, nil, nil, nil, 90, nil, placerdecor(2)),
    MakePlacer("fast_farmplot_placer", "farmplot", "farmplot", "full", true, nil, nil, nil, 90, nil, placerdecor(3))
