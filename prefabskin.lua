require("class")
require("prefabs")

local BACKPACK_DECAY_TIME = 3 * TUNING.TOTAL_DAY_TIME -- will decay after this amount of time on the ground

--tuck_torso = "full" - torso goes behind pelvis slot
--tuck_torso = "none" - torso goes above the skirt
--tuck_torso = "skirt" - torso goes betwen the skirt and pelvis (the default)
BASE_TORSO_TUCK = {}

BASE_ALTERNATE_FOR_BODY = {}
BASE_ALTERNATE_FOR_SKIRT = {}

BASE_LEGS_SIZE = {}
BASE_FEET_SIZE = {}

SKIN_FX_PREFAB = {}

--------------------------------------------------------------------------
--[[ Backpack skin functions ]]
--------------------------------------------------------------------------
local function backpack_pickedup(inst)
    if inst.decay_task ~= nil then
        inst.decay_task:Cancel()
        inst.decay_task = nil
    end
end 

local function backpack_decay_fn(inst, backpack_dropped)
    inst.decay_task = nil
    if not inst.decayed then
        inst.AnimState:SetSkin("backpack_mushy", "swap_backpack")
        inst.skin_build_name = "backpack_mushy"
        inst.override_skinname = "backpack_mushy"
        inst.components.inventoryitem:ChangeImageName("backpack_mushy")
        inst.decayed = true
        inst:RemoveEventCallback("ondropped", backpack_dropped)
        inst:RemoveEventCallback("onputininventory", backpack_pickedup)
    end
end

local function backpack_dropped(inst)
    if not inst.decayed then
        if inst.decay_task ~= nil then
            inst.decay_task:Cancel()
        end
        inst.decay_task = inst:DoTaskInTime(BACKPACK_DECAY_TIME, backpack_decay_fn, backpack_dropped)
    end
end

local function backpack_decay_long_update(inst, dt)
    if inst.decay_task ~= nil then
        local time_remaining = GetTaskRemaining(inst.decay_task)
        inst.decay_task:Cancel()
        if time_remaining > dt then
            inst.decay_task = inst:DoTaskInTime(time_remaining - dt, backpack_decay_fn, backpack_dropped)
        else
            backpack_decay_fn(inst, backpack_dropped)
        end
    end
end

local function backpack_skin_save_fn(inst, data)
    if inst.decayed then
        data.decayed = true
    elseif inst.decay_task ~= nil then
        data.remaining_decay_time = math.floor(GetTaskRemaining(inst.decay_task))
    end
end

local function backpack_skin_load_fn(inst, data)
    if data.decayed then
        if inst.decay_task ~= nil then
            inst.decay_task:Cancel()
        end
        backpack_decay_fn(inst, backpack_dropped)
    elseif data.remaining_decay_time ~= nil and not (inst.decayed or inst.components.inventoryitem:IsHeld()) then
        if inst.decay_task ~= nil then
            inst.decay_task:Cancel()
        end
        inst.decay_task = inst:DoTaskInTime(math.max(0, data.remaining_decay_time), backpack_decay_fn, backpack_dropped)
    end
end

function backpack_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_backpack")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())

    --Now add decay logic
    inst:ListenForEvent("ondropped", backpack_dropped)
    inst:ListenForEvent("onputininventory", backpack_pickedup)
    backpack_dropped(inst)

    inst.OnSave = backpack_skin_save_fn
    inst.OnLoad = backpack_skin_load_fn
    inst.OnLongUpdate = backpack_decay_long_update
end


--------------------------------------------------------------------------
--[[ Armor skin functions ]]
--------------------------------------------------------------------------
function armor_init_fn(inst, build_name, def_build)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, def_build)
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

armordragonfly_init_fn = function(inst, build_name) armor_init_fn(inst, build_name, "torso_dragonfly" ) end
armorgrass_init_fn =  function(inst, build_name) armor_init_fn(inst, build_name, "armor_grass" ) end
armormarble_init_fn =  function(inst, build_name) armor_init_fn(inst, build_name, "armor_marble" ) end
armorwood_init_fn =  function(inst, build_name) armor_init_fn(inst, build_name, "armour_wood") end
armorruins_init_fn =  function(inst, build_name) armor_init_fn(inst, build_name, "armor_ruins" ) end

--------------------------------------------------------------------------
--[[ Ruins Bat skin functions ]]
--------------------------------------------------------------------------
function ruins_bat_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_ruins_bat")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Hammer skin functions ]]
--------------------------------------------------------------------------
function hammer_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_hammer")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Torch skin functions ]]
--------------------------------------------------------------------------
function torch_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_torch")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Lighter skin functions ]]
--------------------------------------------------------------------------
function lighter_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_lighter")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Spear skin functions ]]
--------------------------------------------------------------------------
function spear_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_spear")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Bug Net skin functions ]]
--------------------------------------------------------------------------
function bugnet_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_bugnet")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
    
    local skin_data = GetSkinData(inst:GetSkinName())
    inst.overridebugnetsound = skin_data.skin_sound
end

--------------------------------------------------------------------------
--[[ Axe skin functions ]]
--------------------------------------------------------------------------
function axe_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "axe")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Boomerang skin functions ]]
--------------------------------------------------------------------------
function boomerang_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "boomerang")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Battle Spear skin functions ]]
--------------------------------------------------------------------------
function spear_wathgrithr_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_spear_wathgrithr")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Umbrella skin functions ]]
--------------------------------------------------------------------------
function umbrella_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_umbrella")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Shovel skin functions ]]
--------------------------------------------------------------------------
function shovel_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_shovel")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Hambat skin functions ]]
--------------------------------------------------------------------------
function hambat_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_ham_bat")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Batbat skin functions ]]
--------------------------------------------------------------------------
function batbat_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "batbat")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Amulet skin functions ]]
--------------------------------------------------------------------------
function amulet_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "amulets")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Books skin functions ]]
--------------------------------------------------------------------------
function book_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "books")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end
book_brimstone_init_fn = book_init_fn

--------------------------------------------------------------------------
--[[ Hat skin functions ]]
--------------------------------------------------------------------------
function hat_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "hat_flower") --needs to be the default for the specific prefab
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

tophat_init_fn = hat_init_fn
flowerhat_init_fn = hat_init_fn
strawhat_init_fn = hat_init_fn
winterhat_init_fn = hat_init_fn
catcoonhat_init_fn = hat_init_fn
rainhat_init_fn = hat_init_fn
minerhat_init_fn = hat_init_fn
footballhat_init_fn = hat_init_fn
featherhat_init_fn = hat_init_fn
beehat_init_fn = hat_init_fn
watermelonhat_init_fn = hat_init_fn
wathgrithrhat_init_fn = hat_init_fn
beefalohat_init_fn = hat_init_fn
eyebrellahat_init_fn = hat_init_fn

--------------------------------------------------------------------------
--[[ Bedroll skin functions ]]
--------------------------------------------------------------------------
function bedroll_furry_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_bedroll_straw")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Beemine skin functions ]]
--------------------------------------------------------------------------
function beemine_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "bee_mine")
    if inst.components.inventoryitem ~= nil then
        inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
    end
end

--------------------------------------------------------------------------
--[[ Crockpot skin functions ]]
--------------------------------------------------------------------------
function cookpot_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "cook_pot")
end

--------------------------------------------------------------------------
--[[ Tent skin functions ]]
--------------------------------------------------------------------------
function tent_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "tent")
end

--------------------------------------------------------------------------
--[[ Rainometer functions ]]
--------------------------------------------------------------------------
function rainometer_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "rain_meter")
end

--------------------------------------------------------------------------
--[[ Winterometer functions ]]
--------------------------------------------------------------------------
function winterometer_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "winter_meter")
end

--------------------------------------------------------------------------
--[[ Arrowsign_post functions ]]
--------------------------------------------------------------------------
function arrowsign_post_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "sign_arrow_post")
end

--------------------------------------------------------------------------
--[[ Chest skin functions ]]
--------------------------------------------------------------------------
function treasurechest_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "treasure_chest")
end

--------------------------------------------------------------------------
--[[ Firesuppressor skin functions ]]
--------------------------------------------------------------------------
function firesuppressor_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    if inst.prefab == "firesuppressor_placer" then
        for _, v in pairs(inst.components.placer.linked) do
            v.AnimState:SetSkin(build_name, "firefighter")
        end
    else
        inst.AnimState:SetSkin(build_name, "firefighter")
        inst.AnimState:OverrideItemSkinSymbol("swap_meter", build_name, "10", inst.GUID, "firefighter_meter")
    end
end

--------------------------------------------------------------------------
--[[ Wardrobe skin functions ]]
--------------------------------------------------------------------------
function wardrobe_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "wardrobe")
end

--------------------------------------------------------------------------
--[[ Tooth Trap skin functions ]]
--------------------------------------------------------------------------
function trap_teeth_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "trap_teeth")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Trap skin functions ]]
--------------------------------------------------------------------------
function trap_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "trap")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Bird Trap skin functions ]]
--------------------------------------------------------------------------
function birdtrap_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "birdtrap")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

--------------------------------------------------------------------------
--[[ Endtable skin functions ]]
--------------------------------------------------------------------------
function endtable_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "stagehand")
end

--------------------------------------------------------------------------
--[[ Firepit skin functions ]]
--------------------------------------------------------------------------
function firepit_init_fn(inst, build_name, fxoffset)
    if inst.components.placer ~= nil then
        --Placers can run this on clients as well as servers
        inst.AnimState:SetSkin(build_name, "firepit")
        return
    elseif not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "firepit")
    inst.components.burnable:SetFXOffset(fxoffset)

    local skin_fx = SKIN_FX_PREFAB[build_name]
    if skin_fx ~= nil and skin_fx[1] ~= nil then
        inst:ListenForEvent("takefuel", function(inst, data)
            local fuelvalue = data ~= nil and data.fuelvalue or 0
            if fuelvalue > 0 then
                local fx = SpawnPrefab(skin_fx[1])
                fx.entity:SetParent(inst.entity)
                fx.level:set(
                    (fuelvalue >= TUNING.LARGE_FUEL and 3) or
                    (fuelvalue >= TUNING.MED_FUEL and 2) or
                    1
                )
            end
        end)
    end
end

--------------------------------------------------------------------------
--[[ Pet skin functions ]]
--------------------------------------------------------------------------
function critter_builder_init_fn(inst, build_name)
    inst.linked_skinname = build_name --hack that relies on the build name to match the linked skinname
end

function pet_init_fn(inst, build_name, default_build)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, default_build)
end

function perdling_init_fn(inst, build_name, default_build, hungry_sound)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, default_build)
    inst.skin_hungry_sound = hungry_sound
end

--------------------------------------------------------------------------
--[[ Birdcage skin functions ]]
--------------------------------------------------------------------------
function birdcage_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "bird_cage")
end

--------------------------------------------------------------------------
--[[ Pighouse skin functions ]]
--------------------------------------------------------------------------
function pighouse_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "pig_house")
    
    if inst._window ~= nil then --check to make sure these entitys exist, they don't on dedis, and on placers.
         inst._window.AnimState:SetSkin(build_name)
         inst._windowsnow.AnimState:SetSkin(build_name)
    end
end

--------------------------------------------------------------------------
--[[ Fence skin functions ]]
--------------------------------------------------------------------------
function fence_item_init_fn(inst, build_name)
    inst.linked_skinname = build_name --hack that relies on the build name to match the linked skinname
    inst.AnimState:SetSkin(build_name, "fence") --same hack is used here by the deployable code in player controller
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end
function fence_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end
    inst.AnimState:SetSkin(build_name, "fence")
end


--------------------------------------------------------------------------
--[[ Bernie skin functions ]]
--------------------------------------------------------------------------
function bernie_inactive_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end
    inst.AnimState:SetSkin(build_name, "bernie_build")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

function bernie_active_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end
    inst.AnimState:SetSkin(build_name, "bernie_build")
end
function bernie_big_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end
    inst.AnimState:SetSkin(build_name, "bernie_build")
end

--------------------------------------------------------------------------
--[[ Mushroomlight skin functions ]]
--------------------------------------------------------------------------
function mushroom_light_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "mushroom_light")
end

function mushroom_light2_init_fn(inst, build_name)
    if inst.components.placer == nil and not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "mushroom_light2")
end

--------------------------------------------------------------------------
--[[ Reviver skin functions ]]
--------------------------------------------------------------------------
local function reviver_playbeatanimation(inst)
    inst.AnimState:PlayAnimation("idle")
    inst.highlightchildren[1].AnimState:PlayAnimation("idle")
end

function reviver_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "bloodpump")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())

    local skin_fx = SKIN_FX_PREFAB[build_name]
    if skin_fx ~= nil then
        inst.reviver_beat_fx = skin_fx[1]

        if skin_fx[2] ~= nil then
            local fx = SpawnPrefab(skin_fx[2])
            fx.entity:SetParent(inst.entity)
            fx.AnimState:OverrideItemSkinSymbol("bloodpump01", build_name, "bloodpumpglow", inst.GUID, "bloodpump")
            inst.highlightchildren = { fx }
            inst.PlayBeatAnimation = reviver_playbeatanimation
        end
    end
end

--------------------------------------------------------------------------
--[[ Cane skin functions ]]
--------------------------------------------------------------------------
local function cane_do_trail(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner() or inst
    if not owner.entity:IsVisible() then
        return
    end

    local x, y, z = owner.Transform:GetWorldPosition()
    if owner.sg ~= nil and owner.sg:HasStateTag("moving") then
        local theta = -owner.Transform:GetRotation() * DEGREES
        local speed = owner.components.locomotor:GetRunSpeed() * .1
        x = x + speed * math.cos(theta)
        z = z + speed * math.sin(theta)
    end
    local mounted = owner.components.rider ~= nil and owner.components.rider:IsRiding()
    local map = TheWorld.Map
    local offset = FindValidPositionByFan(
        math.random() * 2 * PI,
        (mounted and 1 or .5) + math.random() * .5,
        4,
        function(offset)
            local pt = Vector3(x + offset.x, 0, z + offset.z)
            return map:IsPassableAtPoint(pt:Get())
                and not map:IsPointNearHole(pt)
                and #TheSim:FindEntities(pt.x, 0, pt.z, .7, { "shadowtrail" }) <= 0
        end
    )

    if offset ~= nil then
        SpawnPrefab(inst.trail_fx).Transform:SetPosition(x + offset.x, 0, z + offset.z)
    end
end

local function cane_equipped(inst, data)
    if inst.vfx_fx ~= nil then
        if inst._vfx_fx_inst == nil then
            inst._vfx_fx_inst = SpawnPrefab(inst.vfx_fx)
            inst._vfx_fx_inst.entity:AddFollower()
        end
        inst._vfx_fx_inst.entity:SetParent(data.owner.entity)
        inst._vfx_fx_inst.Follower:FollowSymbol(data.owner.GUID, "swap_object", 0, inst.vfx_fx_offset or 0, 0)
    end
    if inst.trail_fx ~= nil and inst._trailtask == nil then
        inst._trailtask = inst:DoPeriodicTask(6 * FRAMES, cane_do_trail, 2 * FRAMES)
    end
end

local function cane_unequipped(inst, owner)
    if inst._vfx_fx_inst ~= nil then
        inst._vfx_fx_inst:Remove()
        inst._vfx_fx_inst = nil
    end
    if inst._trailtask ~= nil then
        inst._trailtask:Cancel()
        inst._trailtask = nil
    end
end

function cane_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "swap_cane")
    inst.AnimState:OverrideSymbol("grass", "swap_cane", "grass")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())

    local skin_fx = SKIN_FX_PREFAB[build_name] --build_name is prefab name for canes
    if skin_fx ~= nil then
        inst.vfx_fx = skin_fx[1] ~= nil and skin_fx[1]:len() > 0 and skin_fx[1] or nil
        inst.trail_fx = skin_fx[2]
        if inst.vfx_fx ~= nil or inst.trail_fx ~= nil then
            inst:ListenForEvent("equipped", cane_equipped)
            inst:ListenForEvent("unequipped", cane_unequipped)
            if inst.vfx_fx ~= nil then
                inst.vfx_fx_offset = -60
                inst:ListenForEvent("onremove", cane_unequipped)
            end
        end
    end
end

--------------------------------------------------------------------------
--[[ Staff skin functions ]]
--------------------------------------------------------------------------
local function staff_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "staffs")
    inst.AnimState:OverrideSymbol("grass", "staffs", "grass")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName())
end

function orangestaff_init_fn(inst, build_name)
    staff_init_fn(inst, build_name)

    if not TheWorld.ismastersim then
        return
    end

    local skin_fx = SKIN_FX_PREFAB[build_name] --build_name is prefab name for orangestaff
    if skin_fx ~= nil then
        inst.vfx_fx = skin_fx[1] ~= nil and skin_fx[1]:len() > 0 and skin_fx[1] or nil
        inst.trail_fx = skin_fx[2] ~= nil and skin_fx[2]:len() > 0 and skin_fx[2] or nil
        if inst.vfx_fx ~= nil or inst.trail_fx ~= nil then
            inst:ListenForEvent("equipped", cane_equipped)
            inst:ListenForEvent("unequipped", cane_unequipped)
            if inst.vfx_fx ~= nil then
                inst.vfx_fx_offset = -110
                inst:ListenForEvent("onremove", cane_unequipped)
            end
        end

        if skin_fx[3] ~= nil then
            inst.components.blinkstaff:SetFX(skin_fx[3], skin_fx[4])
        end
    end
end

function yellowstaff_init_fn(inst, build_name)
    staff_init_fn(inst, build_name)

    local skin_data = GetSkinData( build_name ) --build_name is skin name for yellowstaff
    inst.morph_skin = skin_data.granted_items[1]
end

opalstaff_init_fn = staff_init_fn
firestaff_init_fn = staff_init_fn
icestaff_init_fn = staff_init_fn



--------------------------------------------------------------------------
--[[ Thermal Stone skin functions ]]
--------------------------------------------------------------------------
function heatrock_init_fn(inst, build_name)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "heat_rock")
    inst.components.inventoryitem:ChangeImageName(inst:GetSkinName()..tostring(inst.currentTempRange))
end



--------------------------------------------------------------------------
--[[ Lantern skin functions ]]
--------------------------------------------------------------------------
local function lantern_onremovefx(fx)
    fx._lantern._lit_fx_inst = nil
end

local function lantern_enterlimbo(inst)
    --V2C: wow! superhacks!
    --     we want to drop the FX behind when the item is picked up, but the transform
    --     is cleared before lantern_off is reached, so we need to figure out where we
    --     were just before.
    if inst._lit_fx_inst ~= nil then
        inst._lit_fx_inst._lastpos = inst._lit_fx_inst:GetPosition()
        local parent = inst.entity:GetParent()
        if parent ~= nil then
            local x, y, z = parent.Transform:GetWorldPosition()
            local angle = (360 - parent.Transform:GetRotation()) * DEGREES
            local dx = inst._lit_fx_inst._lastpos.x - x
            local dz = inst._lit_fx_inst._lastpos.z - z
            local sinangle, cosangle = math.sin(angle), math.cos(angle)
            inst._lit_fx_inst._lastpos.x = dx * cosangle + dz * sinangle
            inst._lit_fx_inst._lastpos.y = inst._lit_fx_inst._lastpos.y - y
            inst._lit_fx_inst._lastpos.z = dz * cosangle - dx * sinangle
        end
    end
end

local function lantern_off(inst)
    local fx = inst._lit_fx_inst
    if fx ~= nil then
        if fx.KillFX ~= nil then
            inst._lit_fx_inst = nil
            inst:RemoveEventCallback("onremove", lantern_onremovefx, fx)
            fx:RemoveEventCallback("enterlimbo", lantern_enterlimbo, inst)
            fx._lastpos = fx._lastpos or fx:GetPosition()
            fx.entity:SetParent(nil)
            if fx.Follower ~= nil then
                fx.Follower:FollowSymbol(0, "", 0, 0, 0)
            end
            fx.Transform:SetPosition(fx._lastpos:Get())
            fx:KillFX()
        else
            fx:Remove()
        end
    end
end

local function lantern_on(inst)
    local owner = inst.components.inventoryitem.owner
    if owner ~= nil then
        if inst._lit_fx_inst ~= nil and inst._lit_fx_inst.prefab ~= inst._heldfx then
            lantern_off(inst)
        end
        if inst._heldfx ~= nil then
            if inst._lit_fx_inst == nil then
                inst._lit_fx_inst = SpawnPrefab(inst._heldfx)
                inst._lit_fx_inst._lantern = inst
                if inst._overridesymbols ~= nil and inst._lit_fx_inst.AnimState ~= nil then
                    for i, v in ipairs(inst._overridesymbols) do
                        inst._lit_fx_inst.AnimState:OverrideItemSkinSymbol(v, inst:GetSkinBuild(), v, inst.GUID, "lantern")
                    end
                end
                inst._lit_fx_inst.entity:AddFollower()
                inst:ListenForEvent("onremove", lantern_onremovefx, inst._lit_fx_inst)
            end
            inst._lit_fx_inst.entity:SetParent(owner.entity)
            inst._lit_fx_inst.Follower:FollowSymbol(owner.GUID, "swap_object", inst._followoffset ~= nil and inst._followoffset.x or 0, inst._followoffset ~= nil and inst._followoffset.y or 0, inst._followoffset ~= nil and inst._followoffset.z or 0)
        end
    else
        if inst._lit_fx_inst ~= nil and inst._lit_fx_inst.prefab ~= inst._groundfx then
            lantern_off(inst)
        end
        if inst._groundfx ~= nil then
            if inst._lit_fx_inst == nil then
                inst._lit_fx_inst = SpawnPrefab(inst._groundfx)
                inst._lit_fx_inst._lantern = inst
                if inst._overridesymbols ~= nil and inst._lit_fx_inst.AnimState ~= nil then
                    for i, v in ipairs(inst._overridesymbols) do
                        inst._lit_fx_inst.AnimState:OverrideItemSkinSymbol(v, inst:GetSkinBuild(), v, inst.GUID, "lantern")
                    end
                end
                inst:ListenForEvent("onremove", lantern_onremovefx, inst._lit_fx_inst)
                if inst._lit_fx_inst.KillFX ~= nil then
                    inst._lit_fx_inst:ListenForEvent("enterlimbo", lantern_enterlimbo, inst)
                end
            end
            inst._lit_fx_inst.entity:SetParent(inst.entity)
        end
    end
end

function lantern_init_fn(inst, build_name, overridesymbols, followoffset)
    if not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "lantern")

    local skin_fx = SKIN_FX_PREFAB[build_name] --build_name is prefab name for lanterns
    if skin_fx ~= nil then
        inst._heldfx = skin_fx[1]
        inst._groundfx = skin_fx[2]
        if inst._heldfx ~= nil or inst._groundfx ~= nil then
            inst._overridesymbols = overridesymbols
            inst._followoffset = followoffset
            inst:ListenForEvent("lantern_on", lantern_on)
            inst:ListenForEvent("lantern_off", lantern_off)
            inst:ListenForEvent("unequipped", lantern_off)
            inst:ListenForEvent("onremove", lantern_off)
        end
    end
end

--------------------------------------------------------------------------
--[[ ResearchLab2 skin functions ]]
--------------------------------------------------------------------------
local function researchlab2_cancelflash(inst)
    for i = 1, #inst.flashtasks do
        table.remove(inst.flashtasks):Cancel()
    end
end

local function researchlab2_applyflash(inst, intensity)
    inst.AnimState:SetLightOverride(intensity * .6)
    inst.highlightchildren[1].AnimState:SetLightOverride(intensity)
end

local function researchlab2_flashupdate(inst, intensity, totalframes)
    inst.flashframe = inst.flashframe + 1
    if inst.flashframe < totalframes then
        local k = inst.flashframe / totalframes
        researchlab2_applyflash(inst, (1 - k * k) * intensity)
    else
        inst.flashfadetask:Cancel()
        inst.flashfadetask = nil
        inst.flashframe = nil
        researchlab2_applyflash(inst, 0)
    end
end

local function researchlab2_flash(inst, intensity, frames)
    if not inst.AnimState:IsCurrentAnimation("proximity_loop") then
        researchlab2_cancelflash(inst)
        return
    end
    if inst.flashfadetask ~= nil then
        inst.flashfadetask:Cancel()
    end
    inst.flashfadetask = inst:DoPeriodicTask(0, researchlab2_flashupdate, nil, intensity, frames)
    inst.flashframe = -1
    researchlab2_applyflash(inst, intensity * .5)
end

local function researchlab2_checkflashing(inst, anim, offset)
    if inst.checkanimtask ~= nil then
        inst.checkanimtask:Cancel()
        inst.checkanimtask = nil
    end
    researchlab2_cancelflash(inst)
    if anim == "proximity_loop" then
        local period = 49 * FRAMES
        table.insert(inst.flashtasks, inst:DoPeriodicTask(period, researchlab2_flash, 18 * FRAMES, .2, 8))
        table.insert(inst.flashtasks, inst:DoPeriodicTask(period, researchlab2_flash, 24 * FRAMES, .2, 10))
    end
end

local function researchlab2_checkanim(inst)
    if inst.AnimState:IsCurrentAnimation("proximity_loop") then
        inst.checkanimtask = nil
        researchlab2_checkflashing(inst, "proximity_loop", inst.AnimState:GetCurrentAnimationTime())
    else
        inst.checkanimtask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime() + FRAMES, researchlab2_checkanim)
    end
end

local function researchlab2_playanimation(inst, anim, loop)
    inst.AnimState:PlayAnimation(anim, loop)
    inst.highlightchildren[1].AnimState:PlayAnimation(anim, loop)
    researchlab2_checkflashing(inst, anim, 0)
end

local function researchlab2_pushanimation(inst, anim, loop)
    local wasplaying = inst.AnimState:IsCurrentAnimation(anim)
    inst.AnimState:PushAnimation(anim, loop)
    inst.highlightchildren[1].AnimState:PushAnimation(anim, loop)
    if not wasplaying and inst.AnimState:IsCurrentAnimation(anim) then
        researchlab2_checkflashing(inst, anim, 0)
    elseif anim == "proximity_loop" and inst.checkanimtask == nil then
        inst.checkanimtask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime() + FRAMES, researchlab2_checkanim)
    end
end

function researchlab2_init_fn(inst, build_name)
    if inst.components.placer ~= nil then
        --Placers can run this on clients as well as servers
        inst.AnimState:SetSkin(build_name, "researchlab2")
        return
    elseif not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "researchlab2")
    inst.AnimState:OverrideSymbol("shadow_plume", "researchlab2", "shadow_plume")
    inst.AnimState:OverrideSymbol("shadow_wisp", "researchlab2", "shadow_wisp")

    local skin_fx = SKIN_FX_PREFAB[build_name]
    if skin_fx ~= nil and skin_fx[1] ~= nil then
        local fx = SpawnPrefab(skin_fx[1])
        fx.entity:SetParent(inst.entity)
        for i = 1, 4 do
            local symbol = "newfx"..tostring(i)
            fx.AnimState:OverrideItemSkinSymbol(symbol, build_name, symbol, inst.GUID, "researchlab2")
        end
        inst.highlightchildren = { fx }
        inst.flashtasks = {}
        inst._PlayAnimation = researchlab2_playanimation
        inst._PushAnimation = researchlab2_pushanimation
    end
end

--------------------------------------------------------------------------
--[[ ResearchLab4 skin functions ]]
--------------------------------------------------------------------------
function researchlab4_init_fn(inst, build_name)
    if inst.components.placer ~= nil then
        --Placers can run this on clients as well as servers
        inst.AnimState:OverrideItemSkinSymbol("machine_hat", build_name, "machine_hat", inst.GUID, "researchlab4")
        return
    elseif not TheWorld.ismastersim then
        return
    end

    inst.AnimState:OverrideItemSkinSymbol("machine_hat", build_name, "machine_hat", inst.GUID, "researchlab4")
end

--------------------------------------------------------------------------
--[[ Icebox skin functions ]]
--------------------------------------------------------------------------
local function icebox_opened(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst.open_fx ~= nil then
        local t = GetTime()
        if t >= (inst._open_fx_time or 0) then
            inst._open_fx_time = t + 1.3
            SpawnPrefab(inst.open_fx).Transform:SetPosition(x, y, z)
        end
    end
    if inst.frost_fx ~= nil and inst._frostfx == nil then
        inst._frostfx = SpawnPrefab(inst.frost_fx)
        inst._frostfx.Transform:SetPosition(x, y, z)

        --Note(Peter) Set the skin build here instead of overriding specific symbols, but we'd need to assign the id/sig first
        inst._frostfx.AnimState:OverrideItemSkinSymbol("cold_air", inst:GetSkinName(), "cold_air", inst.GUID, "ice_box")
        inst._frostfx.AnimState:OverrideItemSkinSymbol("blink_dot", inst:GetSkinName(), "blink_dot", inst.GUID, "ice_box")
    end
end

local function icebox_closed(inst)
    if inst._frostfx ~= nil then
        inst._frostfx:Kill()
        inst._frostfx = nil
    end
end

function icebox_init_fn(inst, build_name)
    if inst.components.placer ~= nil then
        --Placers can run this on clients as well as servers
        inst.AnimState:SetSkin(build_name, "ice_box")
        return
    elseif not TheWorld.ismastersim then
        return
    end

    inst.AnimState:SetSkin(build_name, "ice_box")

    local skin_fx = SKIN_FX_PREFAB[build_name]
    if skin_fx ~= nil then
        inst.frost_fx = skin_fx[1] ~= nil and skin_fx[1]:len() > 0 and skin_fx[1] or nil
        inst.open_fx = skin_fx[2]
        if inst.frost_fx ~= nil or inst.open_fx ~= nil then
            inst:ListenForEvent("onopen", icebox_opened)
            if inst.frost_fx ~= nil then
                inst:ListenForEvent("onclose", icebox_closed)
                inst:ListenForEvent("onremove", icebox_closed)
            end
        end
    end
end

--------------------------------------------------------------------------

function CreatePrefabSkin(name, info)
    local prefab_skin = Prefab(name, nil, info.assets, info.prefabs)
    prefab_skin.is_skin = true

    prefab_skin.base_prefab         = info.base_prefab
    prefab_skin.type                = info.type
    prefab_skin.skin_tags           = info.skin_tags
    prefab_skin.init_fn             = info.init_fn
    prefab_skin.build_name_override = info.build_name_override
    prefab_skin.bigportrait         = info.bigportrait
    prefab_skin.rarity              = info.rarity
    prefab_skin.rarity_modifier     = info.rarity_modifier
    prefab_skin.skins               = info.skins
    prefab_skin.skin_sound          = info.skin_sound
    prefab_skin.is_restricted       = info.is_restricted
    prefab_skin.granted_items       = info.granted_items
	prefab_skin.marketable			= info.marketable
    prefab_skin.release_group       = info.release_group

    if info.torso_tuck_builds ~= nil then
        for _,base_skin in pairs(info.torso_tuck_builds) do
            BASE_TORSO_TUCK[base_skin] = "full"
        end
    end

    if info.torso_untuck_builds ~= nil then
        for _,base_skin in pairs(info.torso_untuck_builds) do
            BASE_TORSO_TUCK[base_skin] = "untucked"
        end
    end

    if info.torso_untuck_wide_builds ~= nil then
        for _,base_skin in pairs(info.torso_untuck_wide_builds) do
            BASE_TORSO_TUCK[base_skin] = "untucked_wide"
        end
    end

    if info.has_alternate_for_body ~= nil then
        for _,base_skin in pairs(info.has_alternate_for_body) do
            BASE_ALTERNATE_FOR_BODY[base_skin] = true
        end
    end

    if info.has_alternate_for_skirt ~= nil then
        for _,base_skin in pairs(info.has_alternate_for_skirt) do
            BASE_ALTERNATE_FOR_SKIRT[base_skin] = true
        end
    end

    if info.legs_cuff_size ~= nil then
        for base_skin,size in pairs(info.legs_cuff_size) do
            BASE_LEGS_SIZE[base_skin] = size
        end
    end

    if info.feet_cuff_size ~= nil then
        for base_skin,size in pairs(info.feet_cuff_size) do
            BASE_FEET_SIZE[base_skin] = size
        end
    end

    if info.fx_prefab ~= nil then
        SKIN_FX_PREFAB[name] = info.fx_prefab
    end

    return prefab_skin
end
