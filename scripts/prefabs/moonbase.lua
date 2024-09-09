local assets =
{
    Asset("ANIM", "anim/moonbase.zip"),
    Asset("ANIM", "anim/staffs.zip"),
}

local prefabs =
{
    "moonrocknugget",
    "moonrock_pieces",
    "moonhound",
    "moonpig",
    "positronbeam_front",
    "positronbeam_back",
    "positronpulse",
    "staffcoldlightfx",
}

local MIN_CHARGE_START_DELAY = 1
local KEY_STAFF = "yellowstaff"
local MORPHED_STAFF = "opalstaff"

local function HasStaff(inst, staffname)
    return (inst._staffinst ~= nil and inst._staffinst.prefab or inst.components.pickable.product) == staffname
end

local function IsFixed(inst)
    return inst.components.workable.workleft > TUNING.MOONBASE_DAMAGED_WORK
end

local function StopLight(inst)
    inst._stoplighttask = nil
    inst.Light:Enable(false)
    if inst._staffstar == nil then
        inst.AnimState:ClearBloomEffectHandle()
    end
end

local function StopFX(inst)
    if inst._fxpulse ~= nil then
        inst._fxpulse:KillFX()
        inst._fxpulse = nil
    end
    if inst._fxfront ~= nil or inst._fxback ~= nil then
        if inst._fxback ~= nil then
            inst._fxfront:KillFX()
            inst._fxfront = nil
        end
        if inst._fxback ~= nil then
            inst._fxback:KillFX()
            inst._fxback = nil
        end
        if inst._stoplighttask ~= nil then
            inst._stoplighttask:Cancel()
        end
        inst._stoplighttask = inst:DoTaskInTime(9 * FRAMES, StopLight)
    end
    if inst._startlighttask ~= nil then
        inst._startlighttask:Cancel()
        inst._startlighttask = nil
    end
end

local function StartLight(inst)
    inst._startlighttask = nil
    inst.Light:Enable(true)
    if inst._staffstar == nil then
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local function StartFX(inst)
    if inst._fxfront == nil or inst._fxback == nil then
        local x, y, z = inst.Transform:GetWorldPosition()

        if inst._fxpulse ~= nil then
            inst._fxpulse:Remove()
        end
        inst._fxpulse = SpawnPrefab("positronpulse")
        inst._fxpulse.Transform:SetPosition(x, y, z)

        if inst._fxfront ~= nil then
            inst._fxfront:Remove()
        end
        inst._fxfront = SpawnPrefab("positronbeam_front")
        inst._fxfront.Transform:SetPosition(x, y, z)

        if inst._fxback ~= nil then
            inst._fxback:Remove()
        end
        inst._fxback = SpawnPrefab("positronbeam_back")
        inst._fxback.Transform:SetPosition(x, y, z)

        if inst._startlighttask ~= nil then
            inst._startlighttask:Cancel()
        end
        inst._startlighttask = inst:DoTaskInTime(3 * FRAMES, StartLight)
    end
    if inst._stoplighttask ~= nil then
        inst._stoplighttask:Cancel()
        inst._stoplighttask = nil
    end
end

local function OnRemoveEntity(inst)
    if inst._fxpulse ~= nil then
        inst._fxpulse:Remove()
        inst._fxpulse = nil
    end
    if inst._fxfront ~= nil then
        inst._fxfront:Remove()
        inst._fxfront = nil
    end
    if inst._fxback ~= nil then
        inst._fxback:Remove()
        inst._fxback = nil
    end
end

local function PushMusic(inst, level)
    if ThePlayer ~= nil and ThePlayer:IsNear(inst, 30) then
        ThePlayer:PushEvent("triggeredevent", { name = "moonbase", level = level })
    end
end

local function OnMusicDirty(inst)
    --Dedicated server does not need to trigger music
    if not TheNet:IsDedicated() then
        if inst._musictask ~= nil then
            inst._musictask:Cancel()
        end
        inst._musictask = inst._music:value() > 0 and inst:DoPeriodicTask(1, PushMusic, 0, inst._music:value()) or nil
    end
end

local function StartMusic(inst, level)
    if inst._music:value() ~= level then
        inst._music:set(level)
        OnMusicDirty(inst)
    end
end

local function StopMusic(inst)
    StartMusic(inst, 0)
end

local function ShowColdStar(inst)
    if inst._staffstar == nil then
        inst._staffstar = SpawnPrefab("staffcoldlightfx")
        inst._staffstar.entity:SetParent(inst.entity)
        if not inst.Light:IsEnabled() then
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end
    end
end

local function HideColdStar(inst)
    if inst._staffstar ~= nil then
        inst._staffstar:Remove()
        inst._staffstar = nil
        if not inst.Light:IsEnabled() then
            inst.AnimState:ClearBloomEffectHandle()
        end
    end
end

local function IsInAnimState(inst, state)
    return inst.AnimState:IsCurrentAnimation(state)
        or inst.AnimState:IsCurrentAnimation("recharging_"..state)
        or inst.AnimState:IsCurrentAnimation("hit_"..state)
        or inst.AnimState:IsCurrentAnimation("fix_"..state)
end

local function GetAnimState(inst)
    return (IsFixed(inst) and "full")
        or (inst.components.workable.workleft * 2 > TUNING.MOONBASE_DAMAGED_WORK and "med")
        or (inst.components.workable.workleft > 0 and "medlow")
        or "low"
end

local function ToggleMoonCharge(inst)
    if inst.components.workable.workleft <= 0 then
        inst.components.trader:Disable()

        if inst.components.lootdropper == nil then
            inst:AddComponent("lootdropper")

            for i = 1, math.random(2) do
                inst.components.lootdropper:SpawnLootPrefab("moonrocknugget")
            end
            inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
        end

        if inst.components.pickable.caninteractwith then
            inst.components.pickable.caninteractwith = false

            inst.AnimState:ClearOverrideSymbol("swap_staffs")

            HideColdStar(inst)

            if inst._staffinst ~= nil then
                inst:RemoveChild(inst._staffinst)
                inst._staffinst:ReturnToScene()
				inst._staffinst.components.inventoryitem:InheritWorldWetnessAtTarget(inst)
                inst.components.lootdropper:FlingItem(inst._staffinst)
                inst._staffinst = nil
                inst._staffuse = nil
            else
                local staff = inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
                if inst._staffuse ~= nil then
                    if staff ~= nil and staff.components.finiteuses ~= nil then
                        staff.components.finiteuses:SetUses(inst._staffuse)
                    end
                    inst._staffuse = nil
                end
            end
        end

        --Stop moon charging
        inst.components.timer:StopTimer("moonchargepre")
        inst.components.timer:StopTimer("mooncharge")
        inst.components.timer:StopTimer("mooncharge2")
        inst.components.timer:StopTimer("mooncharge3")
        inst:RemoveTag("intense")
        inst.components.moonbeastspawner:Stop()
        local state = GetAnimState(inst)
        if state ~= "low" then
            if inst.AnimState:IsCurrentAnimation("recharging_"..state) then
                inst.AnimState:PlayAnimation(state)
            else
                inst.AnimState:PushAnimation(state, false)
            end
        end
        StopFX(inst)
    else
        if inst.components.lootdropper ~= nil then
            inst:RemoveComponent("lootdropper")
        end

        if TheWorld.state.isfullmoon and
            inst.components.pickable.caninteractwith and
            HasStaff(inst, KEY_STAFF) then
            --Start moon charging
            local state = GetAnimState(inst)
            if state ~= "low" then
                if inst.AnimState:IsCurrentAnimation(state) then
                    inst.AnimState:PlayAnimation("recharging_"..state, true)
                else
                    inst.AnimState:PushAnimation("recharging_"..state, true)
                end
            end
            if inst.components.timer:TimerExists("mooncharge") then
                inst.components.moonbeastspawner:Start()
                StartFX(inst)
                StartMusic(inst, (inst.components.timer:TimerExists("mooncharge2") or inst.components.timer:TimerExists("mooncharge3")) and 1 or 2)
            elseif not inst.components.timer:TimerExists("moonchargepre") then
                inst.components.timer:StartTimer("moonchargepre", math.max(MIN_CHARGE_START_DELAY, inst.components.timer:GetTimeLeft("fullmoonstartdelay") or MIN_CHARGE_START_DELAY))
                inst.components.timer:StopTimer("fullmoonstartdelay")
            end
        else
            if not inst.components.pickable.caninteractwith then
                if IsFixed(inst) then
                    inst.components.trader:Enable()
                else
                    inst.components.trader:Disable()
                end
            end

            --Stop moon charging
            inst.components.timer:StopTimer("moonchargepre")
            inst.components.timer:StopTimer("mooncharge")
            inst.components.timer:StopTimer("mooncharge2")
            inst.components.timer:StopTimer("mooncharge3")
            inst:RemoveTag("intense")
            inst.components.moonbeastspawner:Stop()
            local state = GetAnimState(inst)
            if state ~= "low" then
                if inst.AnimState:IsCurrentAnimation("recharging_"..state) then
                    inst.AnimState:PlayAnimation(state)
                else
                    inst.AnimState:PushAnimation(state, false)
                end
            end
            StopFX(inst)
        end
    end
end

local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    elseif string.sub(item.prefab, -5) ~= "staff" then
        return false, "NOTSTAFF"
    end
    return true
end

--Not all staff prefabs match asset names!
local STAFF_SYMBOLS =
{
    ["firestaff"] = "redstaff",
    ["icestaff"] = "bluestaff",
    ["telestaff"] = "purplestaff",
}

local function GetStaffSymbol(staffname)
    return STAFF_SYMBOLS[staffname] or staffname
end

local function OnStaffGiven(inst, giver, item)
    local staffname, skin_build
    if type(item) == "table" then
        staffname = item.prefab
        skin_build = item:GetSkinBuild()
    else
        staffname = item
    end

    --Disable trading, enable picking.
    inst.components.trader:Disable()
    inst.components.pickable:SetUp(staffname, 1000000)
    inst.components.pickable:Pause()
    inst.components.pickable.caninteractwith = true

    if skin_build ~= nil then
        inst.AnimState:OverrideItemSkinSymbol("swap_staffs", skin_build, GetStaffSymbol(staffname), item.GUID, "staffs")
        inst.components.pickable:ChangeProduct(nil)
        inst._staffinst = item
        inst._staffuse = nil
        inst:AddChild(item)
        item.Transform:SetPosition(0, 0, 0)
        item:RemoveFromScene()
    else
        inst.AnimState:OverrideSymbol("swap_staffs", "staffs", GetStaffSymbol(staffname))
        if type(item) == "table" then
            if inst._staffinst ~= nil then
                --Shouldn't happen
                inst._staffinst:Remove()
                inst._staffinst = nil
            end
            inst._staffuse = item.components.finiteuses ~= nil and item.components.finiteuses:GetUses() or nil
            item:Remove()
        end
    end

    inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/moonstaff_place")

    if staffname == MORPHED_STAFF then
        ShowColdStar(inst)
    else
        HideColdStar(inst)
    end

    if not inst._loading then
        ToggleMoonCharge(inst)
    end
end

local function OnStaffTaken(inst, picker, loot)
    if IsFixed(inst) then
        inst.components.trader:Enable()
    end
    inst.components.pickable.caninteractwith = false

    inst.AnimState:ClearOverrideSymbol("swap_staffs")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/moonstaff_place")

    HideColdStar(inst)

    if inst._staffinst ~= nil then
        if loot ~= nil then
            --Shouldn't happen
            loot:Remove()
        end
        inst:RemoveChild(inst._staffinst)
        inst._staffinst:ReturnToScene()
		inst._staffinst.components.inventoryitem:InheritWorldWetnessAtTarget(inst)
        if picker ~= nil then
            picker:PushEvent("picksomething", { object = inst, loot = inst._staffinst })
            picker.components.inventory:GiveItem(inst._staffinst, nil, inst:GetPosition())
        end
        inst._staffinst = nil
        inst._staffuse = nil
    elseif inst._staffuse ~= nil then
        if loot ~= nil and loot.components.finiteuses ~= nil then
            loot.components.finiteuses:SetUses(inst._staffuse)
        end
        inst._staffuse = nil
    end

    if not inst._loading then
        ToggleMoonCharge(inst)
    end
end

local function OnTimerDone(inst, data)
    if data.name == "moonchargepre" then
        if inst.components.timer:TimerExists("fullmoonstartdelay") then
            inst.components.timer:StartTimer("moonchargepre", inst.components.timer:GetTimeLeft("fullmoonstartdelay"))
            inst.components.timer:StopTimer("fullmoonstartdelay")
        else
            inst.components.timer:StartTimer("mooncharge", TUNING.MOONBASE_CHARGE_DURATION)
            inst.components.timer:StartTimer("mooncharge2", math.min(TUNING.MOONBASE_CHARGE_DURATION1, TUNING.MOONBASE_CHARGE_DURATION))
            inst.components.moonbeastspawner:Start()
            StartFX(inst)
            StartMusic(inst, 1)
        end
    elseif data.name == "mooncharge2" then
        if inst._fxpulse ~= nil then
            inst._fxpulse:SetLevel(2)
        end
        inst:AddTag("intense")
        inst.components.timer:StartTimer("mooncharge3", math.min(TUNING.MOONBASE_CHARGE_DURATION1, math.max(0, TUNING.MOONBASE_CHARGE_DURATION - TUNING.MOONBASE_CHARGE_DURATION1)))
        --StartMusic(inst, 2)
    elseif data.name == "mooncharge3" then
        if inst._fxpulse ~= nil then
            inst._fxpulse:SetLevel(3)
        end
        StartMusic(inst, 2)
    elseif data.name == "mooncharge"
        and inst.components.pickable.caninteractwith
        and HasStaff(inst, KEY_STAFF) then
        --morph staff
        inst.components.pickable:ChangeProduct(MORPHED_STAFF)
        if inst._staffinst ~= nil then
            local new_staff = SpawnPrefab(MORPHED_STAFF, inst._staffinst.morph_skin, inst._staffinst.skin_id) or nil
            inst._staffinst:Remove()
            inst._staffinst = new_staff
            inst:AddChild(new_staff)
            new_staff.Transform:SetPosition(0, 0, 0)
            new_staff:RemoveFromScene()

            inst.AnimState:OverrideItemSkinSymbol("swap_staffs", inst._staffinst:GetSkinBuild(), GetStaffSymbol(MORPHED_STAFF), inst._staffinst.GUID, "staffs")
        else
            inst.AnimState:OverrideSymbol("swap_staffs", "staffs", GetStaffSymbol(MORPHED_STAFF))
        end
        inst._staffuse = nil


        ShowColdStar(inst)

        if inst._fxpulse ~= nil then
            inst._fxpulse:FinishFX()
            inst._fxpulse = nil
        end

        if not inst._loading then
            inst.components.moonbeastspawner:ForcePetrify()
            StopMusic(inst)
            ToggleMoonCharge(inst)
        end
    end
end

local function OnRepaired(inst)
    local state = GetAnimState(inst)

    if state == "full" then
        --avoid repair & give action priority conflict
        inst:RemoveComponent("repairable")
        inst.components.workable:SetWorkLeft(inst.components.workable.maxwork)
    end

    if not IsInAnimState(inst, state) then
        if state ~= "low" then
            inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/repair")
            inst.AnimState:PlayAnimation("fix_"..state)
            if inst.components.timer:TimerExists("mooncharge") then
                inst.AnimState:PushAnimation("recharging_"..state, true)
            else
                inst.AnimState:PushAnimation(state, false)
            end
        else
            inst.AnimState:PlayAnimation("low")
        end
    end

    if not inst._loading then
        ToggleMoonCharge(inst)
    end
end

local function MakeRepairable(inst)
    if inst.components.repairable == nil then
        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = MATERIALS.MOONROCK
        inst.components.repairable.onrepaired = OnRepaired
        inst.components.repairable.noannounce = true
    end
end

local function UpdateWorkState(inst)
    local state = GetAnimState(inst)

    if state ~= "low" then
        inst.AnimState:PlayAnimation("hit_"..state)
        if inst.components.timer:TimerExists("mooncharge") then
            inst.AnimState:PushAnimation("recharging_"..state, true)
        else
            inst.AnimState:PushAnimation(state, false)
        end
    else
        inst.AnimState:PlayAnimation("low")
    end

    if state ~= "full" then
        MakeRepairable(inst)
    end

    if not inst._loading then
        ToggleMoonCharge(inst)
    end
end

local function getstatus(inst)
    return (not IsFixed(inst) and "BROKEN")
        or (not inst.components.pickable.caninteractwith and "GENERIC")
        or (HasStaff(inst, KEY_STAFF) and "STAFFED")
        or (HasStaff(inst, MORPHED_STAFF) and "MOONSTAFF")
        or "WRONGSTAFF"
end

local function onsave(inst, data)
    if inst.components.pickable.caninteractwith then
        if inst._staffinst ~= nil then
            data.staff = inst._staffinst:GetSaveRecord()
        else
            data.staffname = inst.components.pickable.product
            data.staffuse = inst._staffuse
        end
    end
end

local function onload(inst, data)
    local staffloaded = false
    if inst.components.pickable.caninteractwith then
        if data.staff ~= nil then
            local staff = SpawnSaveRecord(data.staff)
            if staff ~= nil then
                OnStaffGiven(inst, nil, staff)
                staffloaded = true
            end
        elseif data.staffname ~= nil then
            OnStaffGiven(inst, nil, data.staffname)
            inst._staffuse = data.staffuse
            staffloaded = true
        end
    end
    if not staffloaded then
        if inst._staffinst ~= nil then
            inst._staffinst:Remove()
            inst._staffinst = nil
        end
        inst._staffuse = nil
        OnStaffTaken(inst)
    end

    if IsFixed(inst) and inst.components.repairable ~= nil then
        --avoid repair & give action priority conflict
        inst:RemoveComponent("repairable")
    end
end

local function OnFullmoon(inst, isfullmoon)
    if not isfullmoon then
        inst.components.timer:StopTimer("fullmoonstartdelay")
        StopMusic(inst)
    elseif not inst.components.timer:TimerExists("fullmoonstartdelay") then
        inst.components.timer:StartTimer("fullmoonstartdelay", TUNING.MOONBASE_CHARGE_DELAY)
    end
    ToggleMoonCharge(inst)
end

local function init(inst)
    inst._loading = nil
    inst:WatchWorldState("isfullmoon", OnFullmoon)
    ToggleMoonCharge(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("moonbase")
    inst.AnimState:SetBuild("moonbase")
    inst.AnimState:PlayAnimation("med")
    inst.AnimState:SetFinalOffset(1)

    inst.Light:SetRadius(2)
    inst.Light:SetIntensity(.75)
    inst.Light:SetFalloff(.75)
    inst.Light:SetColour(128 / 255, 128 / 255, 255 / 255)
    inst.Light:Enable(false)

    inst.MiniMapEntity:SetPriority(4)
    inst.MiniMapEntity:SetIcon("moonbase.png")

    MakeObstaclePhysics(inst, 1)

    --trader (from trader component) added to pristine state for optimization
    --inst:AddTag("trader")

    inst:AddTag("moonbase")
    inst:AddTag("event_trigger")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("NPC_workable")

    inst._music = net_tinybyte(inst.GUID, "moonbase._music", "musicdirty")

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(320)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("musicdirty", OnMusicDirty)

        return inst
    end

    inst.scrapbook_anim = "full"

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("workable")
    --avoid pick & mine action priority conflict
    inst.components.workable:SetWorkAction(nil)
    inst.components.workable:SetMaxWork(TUNING.MOONBASE_COMPLETE_WORK)
    inst.components.workable:SetWorkLeft(TUNING.MOONBASE_DAMAGED_WORK)
    inst.components.workable:SetOnWorkCallback(UpdateWorkState)
    inst.components.workable:SetOnLoadFn(UpdateWorkState)
    inst.components.workable.savestate = true

    MakeRepairable(inst)

    inst:AddComponent("pickable")
    inst.components.pickable.caninteractwith = false
    inst.components.pickable.onpickedfn = OnStaffTaken

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.deleteitemonaccept = false
    inst.components.trader.onaccept = OnStaffGiven
    inst.components.trader:Disable()

    inst:AddComponent("lootdropper")

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst:AddComponent("moonbeastspawner")

    MakeHauntableWork(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst._fxpulse = nil
    inst._fxfront = nil
    inst._fxback = nil
    inst._startlighttask = nil
    inst._stoplighttask = nil
    inst.OnRemoveEntity = OnRemoveEntity

    inst._staffinst = nil
    inst._staffuse = nil
    inst._loading = inst:DoTaskInTime(0, init)

    return inst
end

return Prefab("moonbase", fn, assets, prefabs)
