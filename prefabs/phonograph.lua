local assets =
{
    Asset("ANIM", "anim/phonograph.zip"),
    Asset("INV_IMAGE", "phonograph"),
    Asset("MINIMAP_IMAGE", "phonograph"),
}

local prefabs =
{
    "record",
}

local function DropRecord(inst)
    if inst.components.machine:IsOn() then
        inst.components.machine:TurnOff()
    end
    inst.components.machine.enabled = false
    inst.components.inventory:DropEverything()
end

local function OnHammered(inst, worker)
    inst:DropRecord()
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst:Remove()
end

local function ShouldAcceptItem(inst, item)
    if item:HasTag("phonograph_record") then
        return true
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    inst:DropRecord()
    inst.components.inventory:GiveItem(item) -- Give back the target item because we dropped everything in DropRecord.
    inst.AnimState:PlayAnimation("open")

    if not inst.components.machine:IsOn() then
        inst.components.machine:TurnOn()
    end
end

-- Song fns
local function StopPlayingRecord(inst)
    if inst._play_song_task then
        inst._play_song_task:Cancel()
        inst._play_song_task = nil
    end

    if inst._tend_update_task then
        inst._tend_update_task:Cancel()
        inst._tend_update_task = nil
    end

    inst.AnimState:PlayAnimation("idle")
    inst.SoundEmitter:KillSound("ragtime")
    inst.SoundEmitter:PlaySound("dontstarve/music/gramaphone_end")

    inst:PushEvent("turnedoff")
end

local FARM_PLANT_TAGS = {"tendable_farmplant"}
local function song_update(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local nearby_tendable_plants = TheSim:FindEntities(ix, iy, iz, TUNING.PHONOGRAPH_TEND_RANGE, FARM_PLANT_TAGS)
    for _, tendable_plant in pairs(nearby_tendable_plants) do
        tendable_plant.components.farmplanttendable:TendTo()
    end
end

local function TurnOffMachine(inst)
    local machine = inst.components.machine
    if machine then
        machine:TurnOff()
    end
end

local function play_song(inst, song)
    inst.SoundEmitter:PlaySound(song, "ragtime")

    if inst._stop_song_task then
        inst._stop_song_task:Cancel()
        inst._stop_song_task = nil
    end
    inst._stop_song_task = inst:DoTaskInTime(TUNING.PHONOGRAPH_PLAY_TIME, inst.TurnOffMachine)

    inst._tend_update_task = inst:DoPeriodicTask(1, song_update, 1)
end

local function GetRecordSong(inst)
    local record = inst.components.inventory:GetItemsWithTag("phonograph_record")[1]
    if not record then
        return nil
    end

    return record.songToPlay_skin or record.songToPlay
end

local function TryToPlayRecord(inst)
    local song = inst:GetRecordSong()
    if not song or inst.components.inventoryitem:IsHeld() then
        inst.components.machine.enabled = false
        return
    end

    inst.components.machine.enabled = true

    inst.AnimState:PushAnimation("play_loop", true)
    inst._play_song_task = inst:DoTaskInTime(0, play_song, song)
end

-- Inventory item fns
local function OnPutInInventory(inst, owner)
    if inst.components.machine:IsOn() then
        inst.components.machine:TurnOff()
    end
end

local function OnDroppedFromInventory(inst)
    if inst.components.inventory:NumItems() > 0 then
        inst.components.machine.enabled = true
    end
end

-- Save/Load
local function OnLoad(inst, data)
    if inst.components.inventory:NumItems() > 0 then
        inst.components.machine.enabled = true
    end
end

--
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("phonograph")
    inst.AnimState:SetBuild("phonograph")
    inst.AnimState:PlayAnimation("idle", false)

    inst:AddTag("structure")
    inst:AddTag("trader")
    inst:AddTag("recordplayer")
    inst:AddTag("furnituredecor")

    MakeInventoryFloatable(inst, "med", 0.07, 0.72)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    inst.DropRecord = DropRecord
    inst.OnHammered = OnHammered
    inst.ShouldAcceptItem = ShouldAcceptItem
    inst.OnGetItemFromPlayer = OnGetItemFromPlayer
    inst.GetRecordSong = GetRecordSong
    inst.TryToPlayRecord = TryToPlayRecord
    inst.StopPlayingRecord = StopPlayingRecord
    inst.TurnOffMachine = TurnOffMachine
    inst.OnPutInInventory = OnPutInInventory
    inst.OnDroppedFromInventory = OnDroppedFromInventory
    
    --
    inst:AddComponent("furnituredecor")

    --
    inst:AddComponent("inspectable")

    --
    inst:AddComponent("inventory")

    --
    local inventoryitem = inst:AddComponent("inventoryitem")
    inventoryitem:SetOnPutInInventoryFn(inst.OnPutInInventory)
    inventoryitem:SetOnDroppedFn(inst.OnDroppedFromInventory)

    --
    inst:AddComponent("lootdropper")

    --
    local machine = inst:AddComponent("machine")
    machine.turnonfn = inst.TryToPlayRecord
    machine.turnofffn = inst.StopPlayingRecord
    machine.enabled = false

    --
    local trader = inst:AddComponent("trader")
    trader:SetAcceptTest(inst.ShouldAcceptItem)
    trader.onaccept = inst.OnGetItemFromPlayer
    trader.deleteitemonaccept = false

    --
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(1)
    workable:SetOnFinishCallback(inst.OnHammered)

    --
    inst.OnLoad = OnLoad

    --
    MakeHauntable(inst)

    return inst
end

return Prefab("phonograph", fn, assets, prefabs)
