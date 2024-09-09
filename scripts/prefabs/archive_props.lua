
local RuinsRespawner = require "prefabs/ruinsrespawner"

local assets =
{
    Asset("ANIM", "anim/archive_moon_statue.zip"),
    Asset("ANIM", "anim/archive_runes.zip"),
    Asset("MINIMAP_IMAGE", "archive_runes"),
    Asset("MINIMAP_IMAGE", "archive_moon_statue1"),
    Asset("MINIMAP_IMAGE", "archive_moon_statue2"),
    Asset("MINIMAP_IMAGE", "archive_moon_statue3"),
    Asset("MINIMAP_IMAGE", "archive_moon_statue4"),
}

local prefabs =
{

}

local assets_desk =
{
    Asset("ANIM", "anim/archive_security_desk.zip"),
}

local prefabs_desk =
{
    "archive_security_pulse",
    "archive_security_waypoint",
}

local assets_security =
{
    Asset("ANIM", "anim/archive_security_pulse.zip"),
}

local prefabs_security =
{
    "archive_security_pulse_sfx",
}

local assets_switch =
{
    Asset("ANIM", "anim/archive_switch.zip"),
    Asset("MINIMAP_IMAGE", "archive_power_switch"),
}

local prefabs_switch =
{
    "archive_switch_base",
    "archive_switch_pad",
    "archive_dispencer_sfx",
    "grotto_war_sfx",
}

local assets_switch_base =
{
    Asset("ANIM", "anim/archive_switch_ground.zip"),
}

local assets_switch_pad =
{
    Asset("ANIM", "anim/archive_switch_ground_small.zip"),
}

SetSharedLootTable('archive_statues',
{
    {'thulecite',     1.00},
    {'moonrocknugget',1.00},
    {'moonrocknugget',0.05},
})

local assets_seal =
{
    Asset("ANIM", "anim/moonbase_fx.zip"),
}

local assets_portal =
{
    Asset("ANIM", "anim/archive_portal.zip"),
    Asset("ANIM", "anim/archive_portal_base.zip"),
    Asset("MINIMAP_IMAGE", "archive_portal"),
}

local function ShowWorkState(inst, worker, workleft)
    --NOTE: worker is nil when called from ShowPhaseState
    inst.AnimState:PlayAnimation(
        (   (workleft < TUNING.MARBLEPILLAR_MINE / 3 and "idle_low_") or
            (workleft < TUNING.MARBLEPILLAR_MINE * 2 / 3 and "idle_med_") or
            "idle_full_"
        )..(inst.anim or ""),
        true
    )
end

local function OnWorkFinished(inst)--, worker)
    inst.components.lootdropper:DropLoot(inst:GetPosition())

    local fx = SpawnAt("collapse_small", inst)
    fx:SetMaterial("rock")

    inst:Remove()
end

local function setminimapiconstatue(inst)
    inst.MiniMapEntity:SetIcon("archive_moon_statue"..inst.anim..".png")
end

local function onsave(inst, data)
    data.anim = inst.anim
end

local function onloadpostpass(inst, newents, data)
    if data ~= nil and data.anim ~= nil then
        inst.anim = data.anim
    end
    setminimapiconstatue(inst)
    ShowWorkState(inst, nil, inst.components.workable.workleft)
end

local function statuefn()

    local inst = CreateEntity()
    inst.anim = math.random(1,4)

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.66)

    inst.AnimState:SetBank("archive_moon_statue")
    inst.AnimState:SetBuild("archive_moon_statue")
    inst.AnimState:PlayAnimation("idle_full_"..inst.anim)
    inst.scrapbook_anim = "idle_full_1"

    inst:AddTag("structure")
    inst:AddTag("statue")
    inst:AddTag("dustable")

    inst:SetPrefabNameOverride("archive_moon_statue")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.MARBLEPILLAR_MINE)
    inst.components.workable:SetOnWorkCallback(ShowWorkState)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("archive_statues")

    MakeHauntableWork(inst)

    setminimapiconstatue(inst)

    inst.OnLoadPostPass = onloadpostpass
    inst.OnSave = onsave

    return inst
end

local _storyprogress = 0
local NUM_STORY_LINES = 5

local function getstatus(inst)
    if inst.storyprogress == nil then
        _storyprogress = (_storyprogress % NUM_STORY_LINES) + 1
        inst.storyprogress = _storyprogress
    end

    return "LINE_"..tostring(inst.storyprogress)
end

local function onsaveRune(inst, data)
    data.storyprogress = inst.storyprogress
    data.animid = inst.animid
    data.anim = inst.anim
end

local function setruneanimation(inst)
    if inst.anim == 1 then
        inst.AnimState:PlayAnimation("idle")        
    else
        inst.AnimState:PlayAnimation("idle"..inst.anim)
    end
    inst.scrapbook_anim = "idle"
end

local function onloadRune(inst, data)
    if data ~= nil and data.storyprogress ~= nil then
        inst.storyprogress = data.storyprogress
        _storyprogress = (_storyprogress % NUM_STORY_LINES) + 1
    end

    if data ~= nil and data.anim ~= nil then
        inst.anim = data.anim
        setruneanimation(inst)
    end
end

local function runefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.66)

    inst.anim = math.random(1,3)

    inst.AnimState:SetBank("archive_rune")
    inst.AnimState:SetBuild("archive_runes")
    setruneanimation(inst)

    inst.MiniMapEntity:SetIcon("archive_runes.png")

    inst:AddTag("structure")
    inst:AddTag("statue")
    inst:AddTag("dustable")

    inst:SetPrefabNameOverride("archive_rune_statue")

    inst.scrapbook_specialinfo = "ARCHIVERUNESTATUE"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst.OnLoad = onloadRune
    inst.OnSave = onsaveRune

    return inst
end

local function canspawn(inst)
    local archive = TheWorld.components.archivemanager
    if not archive or archive:GetPowerSetting() and inst.AnimState:IsCurrentAnimation("idle") then
        return inst.canspawn == true
    end
end

local function OnUpdateDesk(inst)
    local archive = TheWorld.components.archivemanager

    if archive and not archive:GetPowerSetting() then
        if not inst.AnimState:IsCurrentAnimation("idle_leave") and
           not inst.AnimState:IsCurrentAnimation("leave") then
            inst.AnimState:PlayAnimation("leave",false)
            inst.AnimState:PushAnimation("idle_leave",false)
            inst.Light:Enable(false)
            inst.SoundEmitter:KillSound("loop")
        end
    else
        if inst.components.childspawner.childreninside > 0 then
            if  not inst.AnimState:IsCurrentAnimation("appear") and
                not inst.AnimState:IsCurrentAnimation("idle") then
                    inst.AnimState:PlayAnimation("appear",false)
                    inst.AnimState:PushAnimation("idle",true)

                    inst.SoundEmitter:PlaySound("grotto/common/archive_security_desk/appear")
            end
            inst.components.childspawner:SpawnChild()
            inst.Light:Enable(true)
            if not inst.SoundEmitter:PlayingSound("loop") then
                inst.SoundEmitter:PlaySound("grotto/common/archive_security_desk/contained_LP","loop")
            end
        else
            if  not inst.AnimState:IsCurrentAnimation("idle_leave") and
                not inst.AnimState:IsCurrentAnimation("leave") then
                    inst.AnimState:PlayAnimation("leave",false)
                    inst.AnimState:PushAnimation("idle_leave",false)
            end
            inst.Light:Enable(false)
            inst.SoundEmitter:KillSound("loop")
        end
    end
end

local function getStatusPower(inst)
    local archive = TheWorld.components.archivemanager

    return archive and not archive:GetPowerSetting() and "POWEROFF"
end

local function securityfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
  --  inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.entity:AddLight()

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(0.5)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(false)

    MakeObstaclePhysics(inst, 0.66)

    inst.anim = math.random(1,3)

    inst.AnimState:SetBuild("archive_security_desk")
    inst.AnimState:SetBank("archive_security_desk")
    inst.AnimState:PlayAnimation("idle_leave",false)

   -- inst.MiniMapEntity:SetIcon("statue_ruins.png")

    inst:AddTag("structure")
    inst:AddTag("statue")
    inst:AddTag("dustable")

    inst.scrapbook_specialinfo = "ARCHIVESECURITYDESK"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "idle"

    -------------------
    inst.canspawn = false

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getStatusPower

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "archive_security_pulse"
    inst.components.childspawner:SetRegenPeriod(TUNING.ARCHIVE_SECURITY.REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.ARCHIVE_SECURITY.RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner:SetSpawnedFn(function()
        inst.SoundEmitter:PlaySound("grotto/common/archive_security_desk/leave")
    end)
    inst.components.childspawner.canspawnfn = canspawn

    inst.components.childspawner.overridespawnlocation = function(inst)
        return Vector3(0,0,0)
    end

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(OnUpdateDesk)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(6,7)

    inst.components.playerprox:SetOnPlayerNear(function()
        inst.canspawn = true
    end)
    inst.components.playerprox:SetOnPlayerFar(function()
        inst.canspawn = false
    end)

    return inst
end

local function securitywaypointfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst:AddTag("archive_waypoint")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

----------------------------------------------------------------------------------------------------

local brain = require("brains/archive_securitypulsebrain")

local SFXRANGE = 4

local POWERPOINT_POSSESSION_RANGE = 0.2

local POWERPOINT_MUST_TAGS = { "security_powerpoint" }
local POWERPOINT_CAN_TAGS =  { "INLIMBO", "FX" }

local function FindSecurityPulseTarget(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, inst.possession_range, POWERPOINT_MUST_TAGS, POWERPOINT_CAN_TAGS)

    for i=#ents, 1, -1 do
        local ent = ents[i]

        if ent.components.health ~= nil and ent.components.health:GetPercent() < (ent.MED_THRESHOLD_DOWN or 1) then
            table.remove(ents, i)
        end
    end

    if ents[1] ~= nil then
        ents[1]:PushEvent("possess", { possesser = inst })
    end
end

local function OnLocomote(inst)
    if inst.components.locomotor:WantsToMoveForward() then
        inst.components.locomotor:WalkForward()
    else
        inst.components.locomotor:StopMoving()
    end
end

local function SetSfxPosition(inst)
    if inst.sfx_prefab ~= nil then
        inst.sfx_prefab.Transform:SetPosition(SFXRANGE, 0, 0)
    end
end

local function securitypulsefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(0.5)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(true)

    MakeTinyGhostPhysics(inst, 1, .5)

    inst.AnimState:SetBank("archive_security_pulse")
    inst.AnimState:SetBuild("archive_security_pulse")
    inst.AnimState:PlayAnimation("idle",true)
    inst.AnimState:SetLightOverride(1)

    inst:AddTag("power_point")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.patrol = true
    inst.possession_range = POWERPOINT_POSSESSION_RANGE

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.ARCHIVE_SECURITY.WALK_SPEED

    inst.OnLocomote = OnLocomote -- Mods
    inst.FindSecurityPulseTarget = FindSecurityPulseTarget -- Mods

    inst.sfx_prefab = inst:SpawnChild("archive_security_pulse_sfx")

    inst:ListenForEvent("locomote", inst.OnLocomote)

    inst:DoPeriodicTask(.25, inst.FindSecurityPulseTarget)
    inst:DoTaskInTime(0, SetSfxPosition)

    inst:SetBrain(brain)

    return inst
end

local function OnUpdatePulseSFX(inst,dt)
	if inst.parent == nil then
		inst:Remove()
	else
		local pt = inst:GetPosition()
		local CIRCLE_TIME = 2
		local rate = TWOPI/ CIRCLE_TIME
		local theta = (inst.parent:GetAngleToPoint(pt)* DEGREES) + (rate * dt)
		local offset = Vector3(SFXRANGE * math.cos( theta ), 0, -SFXRANGE * math.sin( theta ))
		inst.Transform:SetPosition(offset.x,offset.y,offset.z)
	end
end

local function securitypulse_sfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

    inst.entity:AddNetwork()

    --[[ for debugging

    inst.entity:AddAnimState()
    inst.AnimState:SetBank("grass")
    inst.AnimState:SetBuild("grass1")
    inst.AnimState:PlayAnimation("idle", true)

    ]]

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(OnUpdatePulseSFX)

    inst.SoundEmitter:PlaySound("grotto/common/archive_security_desk/leave_LP", "loop")

    return inst
end

local function ItemTradeTestSwitch(inst, item)
    if item == nil then
        return false
    elseif item.prefab ~= "opalpreciousgem" then
        return false, string.sub(item.prefab, -3) == "gem" and "WRONGGEM" or "NOTGEM"
    end
    return true
end

local function startshadowwar(inst)
    local warstarted = TheWorld.components.grottowarmanager and TheWorld.components.grottowarmanager:IsWarStarted()
    if not warstarted and not inst.shadowwartask then
        inst.shadowwartask = inst:DoTaskInTime(7 ,function()
            TheWorld:PushEvent("ms_archivesbreached")
        end)
    end
end

local WAYPOINT_MUST_TAGS = {"archive_waypoint"}
local function findwaypoints(inst, dist)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, dist, WAYPOINT_MUST_TAGS)
    for i,ent in ipairs(ents)do
        if ent == inst then
            table.remove(ents,i)
            break
        end
    end
    return ents
end

local function spawnsounderobj(pos, sound)
    local soundobj = SpawnPrefab("archive_dispencer_sfx")
    soundobj.Transform:SetPosition(pos.x,pos.y,pos.z)
    soundobj:DoTaskInTime(10,function() soundobj:Remove() end)
    soundobj.SoundEmitter:PlaySound(sound)
end

local function testbetweenpoints(pt1,pt2)
    local x1,y1,z1 = pt1.Transform:GetWorldPosition()
    local x2,y2,z2 = pt2.Transform:GetWorldPosition()

    local xdiff = (x2 - x1)/2
    local zdiff = (z2 - z1)/2

    local x = x1 + xdiff
    local z = z1 + zdiff

    return TheWorld.Map:IsVisualGroundAtPoint(x,0,z)
end

local WAYPOINT_RANGE = 34
local function startpowersound(inst)
    local wp = findwaypoints(inst, 5)

    if #wp > 0 then
        wp = wp[1]
        local wps = findwaypoints(wp, WAYPOINT_RANGE)

        local pos = Vector3(wp.Transform:GetWorldPosition())
        spawnsounderobj(pos, "grotto/common/archive_switch/start")
        --print("1 NUMBER OF WAY POINTS!",#wps)


        for i=#wps,1,-1 do
            if not testbetweenpoints(wp,wps[i]) then
                table.remove(wps,i)
            end
        end
        --print("2 NUMBER OF WAY POINTS!",#wps)

        for i,ent in ipairs(wps)do
            local pos = Vector3(wp.Transform:GetWorldPosition())
            local x,y,z = ent.Transform:GetWorldPosition()
            local theta = wp:GetAngleToPoint(x,y,z)*DEGREES
            local radius = 6
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            local time = 0


            time = time + 1
            wp:DoTaskInTime(time,function()
                local pos1 = pos + offset
                spawnsounderobj(pos1, "grotto/common/archive_switch/1")
            end)

            time = time + 1
            wp:DoTaskInTime(time,function()
                local pos1 = pos + (offset *2)
                spawnsounderobj(pos1, "grotto/common/archive_switch/2")
            end)

            time = time + 1
            wp:DoTaskInTime(time,function()
                local pos1 = pos + (offset *3)
                spawnsounderobj(pos1, "grotto/common/archive_switch/3")
            end)

            time = time + 1
            wp:DoTaskInTime(time,function()
                local pos1 = pos + (offset *4)
                spawnsounderobj(pos1, "grotto/common/archive_switch/4")
            end)
        end
    end
end

local GEM_SOCKET_MUST_TAGS = {"gemsocket","archive_switch"}
local CHANDELIER_MUST_TAGS = {"archive_chandelier"}
local function checkforgems(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 6, GEM_SOCKET_MUST_TAGS )

    for i=#ents,1,-1 do
        local ent = ents[i]
        if not ent.gem then
            table.remove(ents,i)
        end
    end

    local archive = TheWorld.components.archivemanager
    if archive and #ents >= 3  then
        archive:SwitchPowerOn(true)
        startpowersound(inst)
        startshadowwar(inst)
        local ents = TheSim:FindEntities(x, y, z, 10, CHANDELIER_MUST_TAGS )
        for i,ent in ipairs(ents)do
            if ent.updatelight then
                ent.updatelight(ent)
            end
        end
    end
end

local function OnGemGiven(inst, giver, item)
    --Disable trading, enable picking.
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")

    inst.components.trader:Disable()
    inst.components.pickable:SetUp("opalpreciousgem", 1000000)
    inst.components.pickable:Pause()
    inst.components.pickable.caninteractwith = true
    inst.gem = true

    if not inst.entity:IsAwake() then
        inst.AnimState:PlayAnimation("idle_full",false)
        checkforgems(inst)
    else
        if not inst.AnimState:IsCurrentAnimation("idle_full") then
            if not inst.AnimState:IsCurrentAnimation("activate") then
                inst:DoTaskInTime(11/30, function()
                    local pos = Vector3(inst.Transform:GetWorldPosition())
                    ShakeAllCameras(CAMERASHAKE.SIDE, 2, .02, .05, pos, 50)
                end)
                inst.AnimState:PlayAnimation("activate",false)
                inst.SoundEmitter:PlaySound("grotto/common/archive_switch/on")
            end
        end
    end
end

local function OnGemTaken(inst)

    inst.components.trader:Enable()
    inst.components.pickable.caninteractwith = false
    inst.gem = false

    local archive = TheWorld.components.archivemanager
    if archive then
        archive:SwitchPowerOn(false)
    end
    if not inst.AnimState:IsCurrentAnimation("idle_empty") then
        if not inst.AnimState:IsCurrentAnimation("deactivate") then

            local pos = Vector3(inst.Transform:GetWorldPosition())
            ShakeAllCameras(CAMERASHAKE.SIDE, 20/30, .02, .05, pos, 50)

            inst.AnimState:PlayAnimation("deactivate",false)
            inst.SoundEmitter:PlaySound("grotto/common/archive_switch/off")
        end
    end
end

local function ShatterGem(inst)
    inst.SoundEmitter:KillSound("hover_loop")
    inst.AnimState:ClearBloomEffectHandle()
    inst.AnimState:PlayAnimation("shatter")
    inst.AnimState:PushAnimation("idle_empty")
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
end

local function DestroyGem(inst)
    inst.components.trader:Enable()
    inst.components.pickable.caninteractwith = false
    inst:DoTaskInTime(math.random() * 0.5, ShatterGem)
end

local function OnSaveSwitch(inst, data)
    if inst.shadowwartask then
        data.startwar = true
    end
end

local function OnLoadPostPassSwitch(inst, newents, data) --OnLoadSwitch

    if data and data.spawnopal then
        local opal = SpawnPrefab("opalpreciousgem")
        inst.components.trader:AcceptGift(nil,opal,1)
    end

    if not inst.components.pickable.caninteractwith then
        OnGemTaken(inst)
    else
        OnGemGiven(inst)
    end

    if data and data.startwar then
        startshadowwar(inst)
    end
end

local function getstatusSwitch(inst)
    return inst.components.pickable.caninteractwith and "VALID" or "GEMS"
end

local function switchfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("archive_power_switch.png")

    inst.AnimState:SetBank("archive_switch")
    inst.AnimState:SetBuild("archive_switch")
    inst.AnimState:PlayAnimation("idle_empty")

    inst:AddTag("gemsocket")
    inst:AddTag("outofreach") --to prevent things from stealing the gem.
    inst:AddTag("archive_switch")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst.scrapbook_proxy = "archive_switch_base"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatusSwitch

    inst:AddComponent("pickable")
    inst.components.pickable.caninteractwith = false
    inst.components.pickable.onpickedfn = OnGemTaken

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTestSwitch)
    inst.components.trader.onaccept = OnGemGiven

    inst.DestroyGemFn = DestroyGem

    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("activate") then
            inst.AnimState:PlayAnimation("idle_full")
            checkforgems(inst)
        end
        if inst.AnimState:IsCurrentAnimation("deactivate") then
            inst.AnimState:PlayAnimation("idle_empty")
        end
    end)

    inst:DoTaskInTime(0,function()
        local x,y,z = inst.Transform:GetWorldPosition()
        local pad = SpawnPrefab("archive_switch_pad")
        pad.Transform:SetPosition(x,y,z)
    end)

    inst.OnSave = OnSaveSwitch
    --inst.OnLoad = OnLoadSwitch
    inst.OnLoadPostPass = OnLoadPostPassSwitch

    return inst
end


local function switchpadfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("archive_switch_ground_small")
    inst.AnimState:SetBuild("archive_switch_ground_small")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local SWITCH_MUST_TAGS = {"archive_switch"}
local function switchbasefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("archive_switch_ground")
    inst.AnimState:SetBuild("archive_switch_ground")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(220)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "idle_empty"
    inst.scrapbook_bank = "archive_switch"
    inst.scrapbook_build = "archive_switch"
    inst.scrapbook_specialinfo = "ARCHIVESWITCH"
    inst.scrapbook_speechname = "archive_switch"

    inst:DoTaskInTime(0,function()
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, 10, SWITCH_MUST_TAGS)
        if #ents > 0 then
            local target = ents[1]
            local pos = Vector3(target.Transform:GetWorldPosition())
            local angle = inst:GetAngleToPoint(pos.x, 0, pos.z)
            inst.Transform:SetRotation(angle-90)
        end
    end)

    inst:ListenForEvent("arhivepoweron", function()
            inst.AnimState:PlayAnimation("activate", false)
            inst.AnimState:PushAnimation("activate_loop", true)

            inst.SoundEmitter:PlaySound("grotto/common/archive_switch/LP","loop")
        end,TheWorld)
    inst:ListenForEvent("arhivepoweroff", function()
            inst.AnimState:PlayAnimation("deactivate", false)
            inst.AnimState:PushAnimation("idle", true)
            inst.SoundEmitter:KillSound("loop")
        end,TheWorld)

    return inst
end

local function CreateDropShadow(parent)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --[[Non-networked entity]]

    inst.AnimState:SetBuild("archive_portal_base")
    inst.AnimState:SetBank("archive_portal_base")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    --inst.AnimState:OverrideSymbol("quagmire_portal01", "quagmire_portal", "shadow")

    inst.Transform:SetEightFaced()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.persists = false
    inst.entity:SetParent(parent.entity)

    return inst
end

local function getstatusportal(inst)
    local archive = TheWorld.components.archivemanager

    return archive and not archive:GetPowerSetting() and "POWEROFF"
end

local function portalfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("archive_portal")
    inst.AnimState:SetBuild("archive_portal")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetFinalOffset(2)

    inst.MiniMapEntity:SetIcon("archive_portal.png")
    inst:AddTag("groundhole")
    inst:AddTag("blocker")

    if not TheNet:IsDedicated() then
        CreateDropShadow(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "scrapbook"
    inst.scrapbook_overridedata = { "archive_portal_base_01", "archive_portal_base", "archive_portal_base_01" }

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatusportal

    return inst
end

local function ambientfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("arhivepoweron", function()
            inst.SoundEmitter:PlaySound("grotto/common/archive_on/"..math.random(1,4),"loop")
        end,TheWorld)
    inst:ListenForEvent("arhivepoweroff", function()
            inst.SoundEmitter:KillSound("loop")
        end,TheWorld)

    return inst
end

local function worldgenitemfn()
    -- this is just used during world gen and should not stick around.
    local inst = CreateEntity()
    inst.entity:AddTransform()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(0,function() inst:Remove() end)
    return inst
end


return Prefab("archive_moon_statue",statuefn, assets, prefabs),
       Prefab("archive_rune_statue", runefn, assets, prefabs),
       Prefab("archive_security_desk", securityfn, assets_desk, prefabs_desk),
       Prefab("archive_security_pulse", securitypulsefn, assets_security, prefabs_security),
       Prefab("archive_security_pulse_sfx", securitypulse_sfxfn),
       Prefab("archive_security_waypoint", securitywaypointfn),
       Prefab("archive_switch", switchfn, assets_switch, prefabs_switch),
       Prefab("archive_switch_pad", switchpadfn, assets_switch_pad),
       Prefab("archive_switch_base", switchbasefn, assets_switch_base),
       Prefab("archive_portal", portalfn, assets_portal),
       Prefab("archive_ambient_sfx", ambientfn),
       Prefab("rubble1",worldgenitemfn),
       Prefab("rubble2",worldgenitemfn)
