local PopupDialogScreen = require "screens/redux/popupdialog"

local assets =
{
    Asset("ANIM", "anim/teleportato.zip"),
    Asset("ANIM", "anim/teleportato_build.zip"),
    Asset("ANIM", "anim/teleportato_adventure_build.zip"),
	Asset("MINIMAP_IMAGE", "teleportato"),
}

local prefabs =
{
    "ash",
}

local function TransitionToNextLevel(inst, wilson)

--[[    wilson.sg:GoToState("teleportato_teleport")
    local days_survived, start_xp, reward_xp, new_xp, capped = CalculatePlayerRewards(wilson)

    local function onsave()
        scheduler:ExecuteInTime(110*FRAMES, function()
            inst.AnimState:PlayAnimation("laugh", false)
            inst.AnimState:PushAnimation("active_idle", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_maxwelllaugh", "teleportato_laugh")

        end)

        scheduler:ExecuteInTime(110*FRAMES+3, function()
            if inst.action == "restart" then
                local function onsaved()
                    StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot(), maxwell=inst.maxwell}, true)
                end
                if inst.teleportpos then
                    GetPlayer().Transform:SetPosition(inst.teleportpos:Get() )
                end
                SaveGameIndex:SaveCurrent(onsaved)
            else
                --SaveGameIndex:CompleteLevel(function() TheFrontEnd:PushScreen(DeathScreen(days_survived, start_xp, true, capped)) end )
            end
        end)
    end

    wilson.profile:Save(onsave) ]]
end

local function GetBodyText()
    return STRINGS.UI.TELEPORTBODY_SURVIVAL
end

local function CheckNextLevelSure(inst, doer)
    SetPause(true, "portal")

    TheFrontEnd:PushScreen(
        PopupDialogScreen(STRINGS.UI.TELEPORTTITLE, GetBodyText(),
            {
                {text=STRINGS.UI.TELEPORTYES, cb =  function()

                                            print("Lets Go!")
                                            TheFrontEnd:PopScreen()
                                            SetPause(false)
                                            ProfileStatsSet("teleportato_used", true)
                                            local wilson = GetPlayer()
                                            wilson.is_teleporting = true
                                            scheduler:ExecuteInTime(1, function()
                                                TransitionToNextLevel(inst, doer)
                                            end)
                                        end},
                {text=STRINGS.UI.TELEPORTNO, cb = function()
                                                        print("Think I'll stay here")
                                                        TheFrontEnd:PopScreen()
                                                        SetPause(false)
                                                        inst.components.activatable.inactive = true
                                                      end}
            }))
end

local function OnActivate(inst, doer)
    --inst.components.activatable.inactive = false
    if not inst.activatedonce then
        inst.activatedonce = true
        inst.AnimState:PlayAnimation("activate", false)
        inst.AnimState:PushAnimation("active_idle", true)
        inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_activate", "teleportato_activate")
        inst.SoundEmitter:KillSound("teleportato_idle")
        inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_activeidle_LP", "teleportato_active_idle")

        inst:DoTaskInTime(40*FRAMES, function()
            inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_activate_mouth", "teleportato_activatemouth")
        end)
--[[
        if inst.action == "restart" then
            inst:DoTaskInTime(2.0, function() TransitionToNextLevel(inst, doer) end)
        elseif SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
            inst.components.container.canbeopened = true
            inst:DoTaskInTime(2.0, function()
                inst.components.container:Open(doer)
            end)
        else
            inst:DoTaskInTime(3.0, function() CheckNextLevelSure(inst, doer) end)
        end
    elseif SaveGameIndex:GetCurrentMode(Settings.save_slot) == "survival" then
        CheckNextLevelSure(inst, doer)]]
    end
end

local function GetStatus(inst)
    ProfileStatsSet("teleportato_inspected", true)
    local partsCount = 0
    for part,found in pairs(inst.collectedParts) do
        if found == true then
            partsCount = partsCount + 1
        end
    end

    if partsCount == 4 then
        --[[if SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
            local rodbase = TheSim:FindFirstEntityWithTag("rodbase")
            if rodbase and rodbase.components.lock and rodbase.components.lock:IsLocked() then
                return "LOCKED"
            end
        else]]
            return "ACTIVE"
        --end
    elseif partsCount > 0 then
        return "PARTIAL"
    end
end

local function ItemTradeTest(inst, item)
    if item:HasTag("teleportato_part") then
        return true
    end
    return false
end

local function PowerUp(inst)
    ProfileStatsSet("teleportato_powerup", true)
    inst.AnimState:PlayAnimation("power_on", false)
    inst.AnimState:PushAnimation("idle_on", true)

    inst.components.activatable.inactive = true

    inst.travel_action_fn = function(doer) CheckNextLevelSure(inst, doer) end

    inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_powerup", "teleportato_on")
    inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_idle_LP", "teleportato_idle")

end

local partSymbols = { teleportato_ring = "RING", teleportato_crank = "CRANK", teleportato_box = "BOX", teleportato_potato = "POTATO" }

local function TestForPowerUp(inst)
    local allParts = true
    for part,found in pairs(inst.collectedParts) do
        if found == false then
            inst.AnimState:Hide(partSymbols[part])
            allParts = false
        else
            inst.AnimState:Show(partSymbols[part])
        end
    end
    if allParts == true then
        --this is a controller hack. It's... kinda gross
        inst.components.trader:Disable()
        local rodbase = TheSim:FindFirstEntityWithTag("rodbase")
        if rodbase and rodbase.components.lock and rodbase.components.lock:IsLocked() then
            rodbase:PushEvent("ready")
            inst:ListenForEvent("powerup", PowerUp)
        else
            inst:DoTaskInTime(0.5, PowerUp)
        end
    end
end

local function ItemGet(inst, giver, item)
    if inst.collectedParts[item.prefab] ~= nil then
        inst.collectedParts[item.prefab] = true
        inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_addpart", "teleportato_addpart")
        TestForPowerUp(inst)
    end
end

local function MakeComplete(inst)
    print("Made Complete")
    inst.collectedParts = {teleportato_ring = true, teleportato_crank = true, teleportato_box = true, teleportato_potato = true }
end

local function OnLoad(inst, data)
    if data then
        if data.makecomplete == 1 then
            print("has make complete data")
            MakeComplete(inst)
            TestForPowerUp(inst)
        end
        if data.collectedParts then
            inst.collectedParts = data.collectedParts
            TestForPowerUp(inst)
        end
        inst.action = data.action
        inst.maxwell = data.maxwell
        if data.teleportposx and data.teleportposz then
            inst.teleportpos = Vector3(data.teleportposx, 0, data.teleportposz)
        end
    end
end

local function OnPlayerFar(inst)
    inst.components.container:Close()
end

local function OnSave(inst, data)
    data.collectedParts = inst.collectedParts
    data.action = inst.action
    data.maxwell = inst.maxwell
    if inst.teleportpos then
        data.teleportposx = inst.teleportpos.x
        data.teleportposz = inst.teleportpos.z
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1.1)

    inst.AnimState:SetBank("teleporter")
    inst.AnimState:SetBuild("teleportato_build")
    inst.AnimState:PlayAnimation("idle_off", true)

    for part, symbol in pairs(partSymbols) do
        inst.AnimState:Hide(symbol)
    end

    inst:AddTag("teleportato")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst.MiniMapEntity:SetIcon("teleportato.png")
    inst.MiniMapEntity:SetPriority(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable:RecordViews()

    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = false
    inst.components.activatable.quickaction = true

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("teleportato_base")
    inst.components.container.canbeopened = false
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true


    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerFar(OnPlayerFar)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = ItemGet

    -- The "construction" requires a list of parts to have been added
    inst.collectedParts = { teleportato_ring = false, teleportato_crank = false, teleportato_box = false, teleportato_potato = false }

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("teleportato_base", fn, assets, prefabs)
