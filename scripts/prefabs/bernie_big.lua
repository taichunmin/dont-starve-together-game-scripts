local commonfn =  require "prefabs/bernie_common"
local brain = require("brains/berniebigbrain")

local assets =
{
    Asset("ANIM", "anim/bernie_big.zip"),
    Asset("ANIM", "anim/bernie_build.zip"),
    Asset("ANIM", "anim/bernie_lunar_build.zip"),
    Asset("ANIM", "anim/bernie_shadow_build.zip"),    
    Asset("ANIM", "anim/bernie_lunar_fx.zip"), 
    Asset("ANIM", "anim/bernie_shadow_fx.zip"),       
    Asset("ANIM", "anim/bernie_fire_fx_shadow_build.zip"),
    Asset("ANIM", "anim/bernie_fire_fx_lunar_build.zip"), 
    
	Asset("MINIMAP_IMAGE", "bernie"),
    Asset("SCRIPT", "scripts/prefabs/bernie_common.lua"),
}

local fireassets =
{
    Asset("ANIM", "anim/bernie_fire_fx.zip"),
}


local prefabs =
{
    "bernie_inactive",
    "bernie_big_fire",
}

local TARGET_DIST = 12
local TAUNT_DIST = 16
local TAUNT_PERIOD = 2

--[[
local function onattackedthorns(inst,data)
    if data.attacker then
        if inst:GetDistanceSqToInst(data.attacker) < 4*4 then
            inst.components.combat:DoAttack(data.attacker)
        end
    end
end
]]

local function OnReflectDamage(inst, data)
   
    if data.attacker ~= nil and data.attacker:IsValid() then
        local impactfx = SpawnPrefab("impact")
        if impactfx ~= nil then
            if data.attacker.components.combat ~= nil then
                local follower = impactfx.entity:AddFollower()
                follower:FollowSymbol(data.attacker.GUID, data.attacker.components.combat.hiteffectsymbol, 0, 0, 0)
            else
                impactfx.Transform:SetPosition(data.attacker.Transform:GetWorldPosition())
            end
            impactfx:FacePoint(inst.Transform:GetWorldPosition())
        end
    end
end

local function endthornsfire(inst)
    if inst.fire_fx then
        --inst.fire_fx:Remove()
        inst.fire_fx:EndBernieFire()
    end
    if inst.fire_thorns_task then
        inst.fire_thorns_task:Cancel()
        inst.fire_thorns_task = nil
    end
    inst:RemoveComponent("damagereflect")
    inst:RemoveEventCallback("onreflectdamage", OnReflectDamage)

    --inst:RemoveEventCallback("attacked",onattackedthorns)

    inst:AddTag("canlight")
end

local function goinactive(inst)
    local skin_name = inst:GetSkinName()
    if skin_name ~= nil then
        skin_name = skin_name:gsub("_shadow_build", ""):gsub("_lunar_build", ""):gsub("_big", "")
    end
    local inactive = SpawnPrefab("bernie_inactive", skin_name, inst.skin_id, nil)
    if inactive ~= nil then
        --Transform health % into fuel.
        inactive.components.fueled:SetPercent(inst.components.health:GetPercent())
        inactive.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inactive.Transform:SetRotation(inst.Transform:GetRotation())
        inactive.components.timer:StartTimer("transform_cd", TUNING.BERNIE_BIG_COOLDOWN)
        inst:Remove()
        return inactive
    end

    endthornsfire(inst)
end

-- 
-- inst.bernieleader.components.skilltreeupdater:IsActivated("willow_bernieai")
-- self_leader

local function IsTauntable(inst, target)
    return not (target.components.health ~= nil and target.components.health:IsDead())
        and target.components.combat ~= nil
        and not target.components.combat:TargetIs(inst)
        and target.components.combat:CanTarget(inst)
        and (   
                (   
                    target:HasTag("shadowcreature")  or 
                    (
                        inst.bernieleader and  inst.bernieleader.components.skilltreeupdater:IsActivated("willow_bernieai") and 
                        (
                            target:HasTag("hostile") and
                            (
                                target:HasTag("brightmare") or 
                                target:HasTag("lunar_aligned") or 
                                target:HasTag("shadow_aligned")
                            ) 
                        )  
                    )   
                ) or
                (   target.components.combat:HasTarget() and
                    (   target.components.combat.target:HasTag("player") or
                        (target.components.combat.target:HasTag("companion") and target.components.combat.target.prefab ~= inst.prefab)
                    )
                )
            )
end

local function IsTargetable(inst, target)
    return not (target.components.health ~= nil and target.components.health:IsDead())
        and target.components.combat ~= nil
        and target.components.combat:CanTarget(inst)
        and (   target.components.combat:TargetIs(inst) or
                (   
                    target:HasTag("shadowcreature")  or 
                    (
                        inst.bernieleader and  inst.bernieleader.components.skilltreeupdater:IsActivated("willow_bernieai") and 
                        (
                            target:HasTag("hostile") and
                            (
                                target:HasTag("brightmare") or 
                                target:HasTag("lunar_aligned") or 
                                target:HasTag("shadow_aligned") 
                            )
                        )  
                    )   
                ) or
                (   target.components.combat:HasTarget() and
                    (   target.components.combat.target:HasTag("player") or
                        target.components.combat.target:HasTag("companion")
                    )
                )
                or
                (   inst.bernieleader and 
                    inst.bernieleader.components.combat:HasTarget() and
                    inst.bernieleader.components.combat.target == target  )
            )
end

local TAUNT_MUST_TAGS = { "_combat" }
local TAUNT_CANT_TAGS = { "INLIMBO", "player", "companion", "epic", "notaunt"}
local TAUNT_ONEOF_TAGS = { "locomotor", "lunarthrall_plant" }
local function TauntCreatures(inst)
    if not inst.components.health:IsDead() then
        local x, y, z = inst.Transform:GetWorldPosition()
        for i, v in ipairs(TheSim:FindEntities(x, y, z, TAUNT_DIST, TAUNT_MUST_TAGS, TAUNT_CANT_TAGS, TAUNT_ONEOF_TAGS)) do
            if IsTauntable(inst, v) then
                v.components.combat:SetTarget(inst)
            end
        end
    end
end

local function OnLoad(inst)
    inst._taunttask:Cancel()
    inst._taunttask = inst:DoPeriodicTask(TAUNT_PERIOD, TauntCreatures, math.random() * TAUNT_PERIOD)
    inst.sg:GoToState("idle")
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "player", "companion", "retaliates"}
local RETARGET_ONEOF_TAGS = { "locomotor", "epic", "NPCcanaggro"}

local function RetargetFn(inst)
    if inst.components.combat:HasTarget() then
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, TARGET_DIST, RETARGET_MUST_TAGS, RETARGET_CANT_TAGS, RETARGET_ONEOF_TAGS)) do
        if IsTargetable(inst, v) then
            return v
        end
    end
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target) and inst:IsNear(target, TARGET_DIST) and not target:HasTag("retaliates")
end

local function ShouldAggro(combat, target)
    if target:HasTag("player") then
        return TheNet:GetPVPEnabled()
    end
    return true
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil and not PreventTargetingOnAttacked(inst, attacker, TheNet:GetPVPEnabled() and "bernieowner" or "player") then
        local target = inst.components.combat.target
        if not (target ~= nil and target:IsValid() and inst:IsNear(target, TUNING.BERNIE_BIG_ATTACK_RANGE + target:GetPhysicsRadius(0))) then
            inst.components.combat:SetTarget(attacker)
        end
    end
end

local function OnSleepTask(inst)
    inst._sleeptask = nil
    inst:GoInactive()
end

local function OnEntitySleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask = inst:DoTaskInTime(.5, OnSleepTask)
    end
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end
end

local function OnLighterLight(inst)
    if inst.fire_thorns_task then
        inst.fire_thorns_task:Cancel()
        inst.fire_thorns_task = nil
    else
        inst.fire_fx = SpawnPrefab("bernie_big_fire")
        inst.fire_fx.entity:SetParent(inst.entity)

        if inst.bernieleader and inst.bernieleader.components.skilltreeupdater:IsActivated("willow_allegiance_shadow_bernie") then
            inst.fire_fx.AnimState:SetBuild("bernie_fire_fx_shadow_build")
            inst.fire_fx.AnimState:SetMultColour(0, 0, 0, 0.5)
        end
        
        if inst.bernieleader and inst.bernieleader.components.skilltreeupdater:IsActivated("willow_allegiance_lunar_bernie") then
            inst.fire_fx.AnimState:SetBuild("bernie_fire_fx_lunar_build")
            inst.fire_fx.AnimState:SetMultColour(0.3, 0.3, 0.3, 0.3)
        end        

        inst.fire_fx.AnimState:SetFinalOffset(-3)

        inst:AddComponent("damagereflect")
        inst.components.damagereflect:SetDefaultDamage(TUNING.BERNIE_BURNING_REFLECT_DAMAGE)
        inst:ListenForEvent("onreflectdamage", OnReflectDamage)

        inst:RemoveTag("canlight")
    end

    inst.fire_thorns_task = inst:DoTaskInTime(20,function()
                endthornsfire(inst)
            end)
end

-- called bu the brain
local function onLeaderChanged(inst,leader)    
    if inst.bernieleader ~= leader then
        inst.bernieleader = leader
    end

    if leader and leader.components.skilltreeupdater:IsActivated("willow_berniespeed_2") then
        inst.components.locomotor.walkspeed = TUNING.BERNIE_BIG_WALK_SPEED * TUNING.SKILLS.WILLOW_BERNIESPEED_2
        inst.components.locomotor.runspeed = TUNING.BERNIE_BIG_RUN_SPEED * TUNING.SKILLS.WILLOW_BERNIESPEED_2
    elseif leader and leader.components.skilltreeupdater:IsActivated("willow_berniespeed_1") then
        inst.components.locomotor.walkspeed = TUNING.BERNIE_BIG_WALK_SPEED * TUNING.SKILLS.WILLOW_BERNIESPEED_1
        inst.components.locomotor.runspeed = TUNING.BERNIE_BIG_RUN_SPEED * TUNING.SKILLS.WILLOW_BERNIESPEED_1
    else
        inst.components.locomotor.walkspeed = TUNING.BERNIE_BIG_WALK_SPEED
        inst.components.locomotor.runspeed = TUNING.BERNIE_BIG_RUN_SPEED
    end

    inst.components.health:StopRegen()
    if leader and leader.components.skilltreeupdater:IsActivated("willow_bernieregen_2") then
        inst.components.health:StartRegen(TUNING.SKILLS.WILLOW_BERNIE_HEALTH_REGEN_2, TUNING.SKILLS.WILLOW_BERNIE_HEALTH_REGEN_PERIOD)
    elseif leader and leader.components.skilltreeupdater:IsActivated("willow_bernieregen_1") then
        inst.components.health:StartRegen(TUNING.SKILLS.WILLOW_BERNIE_HEALTH_REGEN_1, TUNING.SKILLS.WILLOW_BERNIE_HEALTH_REGEN_PERIOD)        
    end        

    if leader then 
        inst:CheckForAllegiances(leader)
    end

    local percent = inst.components.health:GetPercent()
    if leader and leader.components.skilltreeupdater:IsActivated("willow_berniehealth_2") then 
        inst.components.health:SetMaxHealth(TUNING.BERNIE_BIG_HEALTH * TUNING.SKILLS.WILLOW_BERNIEHEALTH_2)
    elseif leader and leader.components.skilltreeupdater:IsActivated("willow_berniehealth_1") then
        inst.components.health:SetMaxHealth(TUNING.BERNIE_BIG_HEALTH * TUNING.SKILLS.WILLOW_BERNIEHEALTH_1)
    else
        inst.components.health:SetMaxHealth(TUNING.BERNIE_BIG_HEALTH)
    end 
    inst.components.health:SetPercent(percent)


    if leader and ( leader.components.skilltreeupdater:IsActivated("willow_allegiance_lunar_bernie") or leader.components.skilltreeupdater:IsActivated("willow_allegiance_shadow_bernie") )  then
        if leader.components.skilltreeupdater:IsActivated("willow_allegiance_lunar_bernie") then
            inst:AddTag("lunar_aligned")
            local damagetyperesist = inst.components.damagetyperesist
            if damagetyperesist then
                damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_LUNAR_RESIST, "willow_allegiance_lunar")
            end
            local damagetypebonus = inst.components.damagetypebonus
            if damagetypebonus then
                damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_VS_SHADOW_BONUS, "willow_allegiance_lunar")
            end
        end
        if leader.components.skilltreeupdater:IsActivated("willow_allegiance_shadow_bernie") then
            inst:AddTag("shadow_aligned")
            local damagetyperesist = inst.components.damagetyperesist
            if damagetyperesist then
                damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_SHADOW_RESIST, "willow_allegiance_shadow")
            end
            local damagetypebonus = inst.components.damagetypebonus
            if damagetypebonus then
                damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_VS_LUNAR_BONUS, "willow_allegiance_shadow")                        
            end
        end        
    else
        inst:RemoveTag("shadow_aligned")
        inst:RemoveTag("lunar_aligned")
        local damagetyperesist = inst.components.damagetyperesist
        if damagetyperesist then
            damagetyperesist:RemoveResist("shadow_aligned", inst, "willow_allegiance_shadow")
            damagetyperesist:RemoveResist("lunar_aligned", inst, "willow_allegiance_lunar")
        end
        local damagetypebonus = inst.components.damagetypebonus
        if damagetypebonus then
            damagetypebonus:RemoveBonus("shadow_aligned", inst, "willow_allegiance_lunar")
            damagetypebonus:RemoveBonus("lunar_aligned", inst, "willow_allegiance_shadow")
        end        
    end

    if leader and leader.components.skilltreeupdater:IsActivated("willow_burnignbernie") then
        inst:AddTag("canlight")
        inst:ListenForEvent("onlighterlight", OnLighterLight)
    end
end

local function OnColourChanged(inst, r, g, b, a)
    for i, v in ipairs(inst.highlightchildren) do
        v.AnimState:SetAddColour(r, g, b, a)
    end
end

local BERNIE_SKIN_SYMBOLS = {
    "blob_body",
    "big_tail",
    "big_strand",
    "big_leg_upper",
    "big_leg_lower",
    "big_head",
    "big_hand",
    "big_fluff",
    "big_ear",
    "big_body",
    "big_arm_upper",
    "big_arm_lower",
}
local BERNIE_SMALL_SKIN_SYMBOLS = {
    "bernie_torso",
    "bernie_tail",
    "bernie_legupper",
    "bernie_leglower",
    "bernie_inactive",
    "bernie_headbase",
    "bernie_head",
    "bernie_hand",
    "bernie_face",
    "bernie_ear",
    "bernie_armupper",
    "bernie_armlower",
}
local function CheckForAllegiances(inst, leader)
    inst.should_shrink = nil
    local allegiance = inst.current_allegiance:value()
    local shadow = leader.components.skilltreeupdater:IsActivated("willow_allegiance_shadow_bernie")
    local lunar = leader.components.skilltreeupdater:IsActivated("willow_allegiance_lunar_bernie")

    if not shadow and not lunar then
        if allegiance ~= 0 then
            inst.should_shrink = true
            inst.AnimState:ClearSymbolBloom("blob_body")
            inst:RemoveTag("shadow_aligned")
            inst:RemoveTag("lunar_aligned")
            inst.current_allegiance:set(0)
            if inst.components.planarentity ~= nil then
                inst:RemoveComponent("planarentity")
            end
            if inst.components.planardamage ~= nil then
                inst:RemoveComponent("planardamage")
            end
            if inst.components.planardefense ~= nil then
                inst:RemoveComponent("planardefense")
            end
        end
        return
    end

    if allegiance == 0 and (shadow or lunar) then -- and (inst:HasTag("shadow_aligned") or inst:HasTag("lunar_aligned")) 
        inst.should_shrink = true
        local base_build = shadow and "bernie_shadow_build" or "bernie_lunar_build"
        inst.AnimState:SetBuild(base_build)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            local modified_skin_build = skin_build .. (shadow and "_shadow_build" or "_lunar_build")
            for _, symbol in ipairs(BERNIE_SKIN_SYMBOLS) do
                inst.AnimState:OverrideItemSkinSymbol(symbol, modified_skin_build, symbol, inst.GUID, base_build)
            end
            for _, symbol in ipairs(BERNIE_SMALL_SKIN_SYMBOLS) do
                inst.AnimState:OverrideItemSkinSymbol(symbol, skin_build, symbol, inst.GUID, skin_build)
            end
        else
            for _, symbol in ipairs(BERNIE_SKIN_SYMBOLS) do
                inst.AnimState:ClearOverrideSymbol(symbol)
            end
            for _, symbol in ipairs(BERNIE_SMALL_SKIN_SYMBOLS) do
                inst.AnimState:ClearOverrideSymbol(symbol)
            end
        end
        inst.AnimState:SetSymbolBloom("blob_body")

        inst:AddTag(shadow and "shadow_aligned" or "lunar_aligned")

        inst.current_allegiance:set(shadow and BERNIEALLEGIANCE.SHADOW or BERNIEALLEGIANCE.LUNAR)

        if inst.components.planarentity == nil then
            inst:AddComponent("planarentity")
        end

        if inst.components.planardamage == nil then
            inst:AddComponent("planardamage")
        end

        if inst.components.planardefense == nil then
            inst:AddComponent("planardefense")
        end

        inst.components.planardamage:SetBaseDamage(TUNING.BERNIE_PLANAR_DAMAGE)
        inst.components.planardefense:SetBaseDefense(TUNING.BERNIE_PLANAR_DEFENCE)
    end
end

local function CreateFlameFx(bank,build,anim,override,bloomsymbols)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    if not TheWorld.ismastersim then
        inst.entity:SetCanSleep(false)
    end
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim, true)
    inst.AnimState:SetSymbolLightOverride(override, 1)

    if bloomsymbols then
        for i,symbol in ipairs(bloomsymbols)do
            inst.AnimState:SetSymbolBloom(symbol)
        end
    end
    
    --inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()))

    return inst
end

local function doshadowbernieart(inst)
    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then

        local flame1 = CreateFlameFx("head_shadow_fx","bernie_shadow_fx","head_shadow_fx","head_gestalt_follow")
        flame1.entity:SetParent(inst.entity)
        flame1.Follower:FollowSymbol(inst.GUID, "head_gestalt_follow", nil, nil, nil, true)

        local flame2 = CreateFlameFx("head_shadow_fx","bernie_shadow_fx","shoulder_shadow_fx","shoulder_follow")
        flame2.entity:SetParent(inst.entity)
        flame2.Follower:FollowSymbol(inst.GUID, "shoulder_gestalt_follow", nil, nil, nil, true)

        inst.highlightchildren = { flame1, flame2 }

        inst.components.colouraddersync:SetColourChangedFn(OnColourChanged)
    end
end

local function dolunarbernieart(inst)
    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then

        local flame1 = CreateFlameFx("bernie_lunar_fx","bernie_lunar_fx","head_gestalt_fx","head_gestalt_follow",{"head_fx","blob_head"})
        flame1.entity:SetParent(inst.entity)
        flame1.Follower:FollowSymbol(inst.GUID, "head_gestalt_follow", nil, nil, nil, true)

        local flame2 = CreateFlameFx("bernie_lunar_fx","bernie_lunar_fx","shoulder_gestalt_fx","shoulder_gestalt_follow",{"shoulder_gestalt_comp"})
        flame2.entity:SetParent(inst.entity)
        flame2.Follower:FollowSymbol(inst.GUID, "shoulder_gestalt_follow", nil, nil, nil, true)

        inst.highlightchildren = { flame1, flame2 }

        inst.components.colouraddersync:SetColourChangedFn(OnColourChanged)
    end
end

local function clearshadowlunarbernieart(inst)
    --Dedicated server does not need to remove the local fx
    if not TheNet:IsDedicated() then
        if inst.highlightchildren ~= nil then -- NOTES(JBK): Assuming the highlightchildren are all safe to remove from above code.
            for _, child in ipairs(inst.highlightchildren) do
                if child:IsValid() then
                    child:Remove()
                end
            end
            inst.highlightchildren = nil
        end
        inst.components.colouraddersync:SetColourChangedFn(nil)
    end
end

local function current_allegiancedirty(inst)
    if inst.current_allegiance:value() then
        if inst.current_allegiance:value() == BERNIEALLEGIANCE.SHADOW then
            doshadowbernieart(inst)
        elseif inst.current_allegiance:value() == BERNIEALLEGIANCE.LUNAR then
            dolunarbernieart(inst)
        else
            clearshadowlunarbernieart(inst)
        end
    end
end

local RESKIN_MUST_HAVE_LUNAR = {"_lunar_build",}
local RESKIN_MUST_HAVE_SHADOW = {"_shadow_build",}
local RESKIN_MUST_NOT_HAVE_LUNARSHADOW = {"_lunar_build", "_shadow_build",}
local function ReskinToolFilterFn(inst)
    local build = inst.AnimState:GetBuild()
    local must_have, must_not_have
    if build:find("_lunar_build") then
        return RESKIN_MUST_HAVE_LUNAR, nil
    elseif build:find("_shadow_build") then
        return RESKIN_MUST_HAVE_SHADOW, nil
    end
    return nil, RESKIN_MUST_NOT_HAVE_LUNARSHADOW
end
local function SetBernieSkinBuild(inst, skin_build)
    local leader = inst.bernieleader
    if leader then
        local shadow = leader.components.skilltreeupdater:IsActivated("willow_allegiance_shadow_bernie")
        local lunar = leader.components.skilltreeupdater:IsActivated("willow_allegiance_lunar_bernie")
    
        if shadow or lunar then
            local base_build = shadow and "bernie_shadow_build" or "bernie_lunar_build"
            inst.AnimState:SetBuild(base_build)
            if skin_build ~= nil then
                local modified_skin_build = skin_build .. (shadow and "_shadow_build" or "_lunar_build")
                for _, symbol in ipairs(BERNIE_SKIN_SYMBOLS) do
                    inst.AnimState:OverrideItemSkinSymbol(symbol, modified_skin_build, symbol, inst.GUID, base_build)
                end
                for _, symbol in ipairs(BERNIE_SMALL_SKIN_SYMBOLS) do
                    inst.AnimState:OverrideItemSkinSymbol(symbol, skin_build, symbol, inst.GUID, skin_build)
                end
            end
            return
        end
    end
end
local function ClearBernieSkinBuild(inst)
    for _, symbol in ipairs(BERNIE_SKIN_SYMBOLS) do
        inst.AnimState:ClearOverrideSymbol(symbol)
    end
    for _, symbol in ipairs(BERNIE_SMALL_SKIN_SYMBOLS) do
        inst.AnimState:ClearOverrideSymbol(symbol)
    end
    local leader = inst.bernieleader
    if leader then
        local shadow = leader.components.skilltreeupdater:IsActivated("willow_allegiance_shadow_bernie")
        local lunar = leader.components.skilltreeupdater:IsActivated("willow_allegiance_lunar_bernie")
    
        if shadow or lunar then
            inst.AnimState:SetBuild(shadow and "bernie_shadow_build" or "bernie_lunar_build")
            return
        end
    end
    inst.AnimState:SetBuild("bernie_build")
end

local function canactivate(inst,doer)
    if doer ~= inst.bernieleader then
        return false, "NOTMYBERNIE"
    end
    return true
end

local function GetVerb()
    return "CALM"
end

local function OnActivate(inst, doer)    
    inst.should_shrink = true
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 500, .65)
    inst.DynamicShadow:SetSize(2.75, 1.3)

    inst.Transform:SetScale(.7, .7, .7)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("bernie_big")
    inst.AnimState:SetBuild("bernie_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.MiniMapEntity:SetIcon("bernie.png")

    inst.GetActivateVerb = GetVerb

    inst:AddTag("largecreature")
    inst:AddTag("companion")
    inst:AddTag("soulless")
    inst:AddTag("crazy")
    inst:AddTag("bigbernie")

    inst:AddComponent("colouraddersync")
    inst.current_allegiance = net_tinybyte(inst.GUID, "bernie_big.current_allegiance", "current_allegiancedirty")
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("current_allegiancedirty", current_allegiancedirty)
    end
    inst.current_allegiance:set(0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_specialinfo = "BERNIE"
    inst.ReskinToolFilterFn = ReskinToolFilterFn
    inst.SetBernieSkinBuild = SetBernieSkinBuild
    inst.ClearBernieSkinBuild = ClearBernieSkinBuild

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BERNIE_BIG_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BERNIE_BIG_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.BERNIE_BIG_RUN_SPEED

    -- Enable boat hopping
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BERNIE_BIG_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BERNIE_BIG_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.BERNIE_BIG_ATTACK_RANGE, TUNING.BERNIE_BIG_HIT_RANGE)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetShouldAggroFn(ShouldAggro)
    inst.components.combat.battlecryinterval = 16
    inst.components.combat.hiteffectsymbol = "body"

    inst:AddComponent("timer")

    inst:AddComponent("activatable")
    inst.components.activatable.CanActivateFn = canactivate
    inst.components.activatable.OnActivate = OnActivate
    
    inst.components.activatable.quickaction = true

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("damagetyperesist")
    inst:AddComponent("damagetypebonus")

    inst.hit_recovery = TUNING.BERNIE_BIG_HIT_RECOVERY

    inst:SetStateGraph("SGberniebig")
    inst:SetBrain(brain)

    inst._taunttask = inst:DoPeriodicTask(TAUNT_PERIOD, TauntCreatures, 0)
    inst.OnLoad = OnLoad
    inst.GoInactive = goinactive
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.onLeaderChanged = onLeaderChanged
    inst.isleadercrazy = commonfn.isleadercrazy
    inst.CheckForAllegiances = CheckForAllegiances
    inst.hotheaded = commonfn.hotheaded

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

local function EndBernieFire(inst)
    inst.AnimState:PlayAnimation("bernie_fire_reg_pst", false)

end

local function firefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()    
    inst.entity:AddNetwork()

    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(0.7)
    inst.Light:SetRadius(3)
    inst.Light:SetColour(180/255, 195/255, 150/255)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)
    
    inst.AnimState:SetBank("bernie_fire_fx")
    inst.AnimState:SetBuild("bernie_fire_fx")
    inst.AnimState:PlayAnimation("bernie_fire_reg_pre", false)
    inst.AnimState:PushAnimation("bernie_fire_reg", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetMultColour(1,0.7,0,0.3)

    inst.SoundEmitter:PlaySound("dontstarve/common/treefire","firelp")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    inst.EndBernieFire = EndBernieFire

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("bernie_fire_reg_pst") then
            inst:Remove()
        end
    end)

    return inst
end

return Prefab("bernie_big", fn, assets, prefabs),
       Prefab("bernie_big_fire", firefn, fireassets, prefabs)
