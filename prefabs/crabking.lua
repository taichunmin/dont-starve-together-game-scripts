local brain = require "brains/crabkingbrain"

-- red gem  -- MAX HEALTH
-- blue gem -- FREEZE TIME
-- purple gem -- GEYSERS
-- yellow gem -- CAST DELAY
-- green gem -- CLAWS
-- orange gem -- REGEN BUFF

local assets =
{
    Asset("ANIM", "anim/crab_king_basic.zip"),
    Asset("ANIM", "anim/crab_king_actions.zip"),
    Asset("ANIM", "anim/crab_king_build.zip"),
}

local chipassets =
{
    Asset("ANIM", "anim/crabking_rockchip.zip"),
}

local prefabs =
{
    "crabking_geyserspawner",
    "crabking_claw",
    "crab_king_shine",
    "crabking_feeze",
    "crabking_ring_fx",
    "crabking_chip_high",
    "crabking_chip_med",
    "crabking_chip_low",
    "moon_altar_cosmic",
    "hermit_cracked_pearl",
    "chesspiece_crabking_sketch",
    "trident_blueprint",
    "meat",
    "singingshell_octave5",
    "singingshell_octave4",
    "singingshell_octave3",
    "barnacle",
	"winter_ornament_boss_crabking",
	"winter_ornament_boss_crabkingpearl",
}

local geyserprefabs =
{
    "crab_king_bubble1",
    "crab_king_bubble2",
    "crab_king_bubble3",
    "crab_king_waterspout",
}

local freezeprefabs =
{
    "mushroomsprout_glow",
    "crab_king_icefx",
}

local TARGET_DIST = 16

local MAX_SOCKETS = 9

local ARMTIME = {
    0,
    0.25,
    0.1,
    0.2,
    0.15,
    0.3,
}

local function getfreezerange(inst)
    return TUNING.CRABKING_FREEZE_RANGE * (0.75 + Remap(inst.countgems(inst).blue,0,9,0,2.25)) /2
end

local function removecrab(inst)
    inst.crab = nil
    inst:Remove()
end

local function RemoveDecor(inst, data)
    inst.AnimState:ClearOverrideSymbol("gems_blue")
end

local function AddDecor(inst, data)
    if data == nil or data.slot == nil or data.itemprefab == nil then
        return
    end
    local symbol = "gems_blue"
    if data.itemprefab == "redgem" then
        symbol = "gems_red"
    elseif data.itemprefab == "purplegem" then
        symbol = "gems_purple"
    elseif data.itemprefab == "orangegem" then
        symbol = "gems_orange"
    elseif data.itemprefab == "yellowgem" then
        symbol = "gems_yellow"
    elseif data.itemprefab == "greengem" then
        symbol = "gems_green"
    elseif data.itemprefab == "opalpreciousgem" then
        symbol = "gems_opal"
    elseif data.itemprefab == "hermit_pearl" then
        symbol = "hermit_pearl"
    end

    inst.AnimState:OverrideSymbol("gem"..data.slot, "crab_king_build", symbol)
    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/gem_place")
    inst.shinefx = SpawnPrefab("crab_king_shine")
    inst.shinefx.entity:AddFollower()
    --inst.shinefx.entity:SetParent(inst)
    inst.shinefx.Follower:FollowSymbol(inst.GUID, "gem"..data.slot, 0, 0, 0)
    inst:PushEvent("socket")
end

local function clearsocketart(inst)
    inst.AnimState:ClearOverrideSymbol("gems_blue")
    for i=1,9 do
        inst.AnimState:ClearOverrideSymbol("gem"..i)
    end
end

local function socketitem(inst,item,socketnum)
    -- find open slot
    if socketnum then
        for i = #inst.socketlist, 1, -1 do
            if inst.socketlist[i] == socketnum then
                table.remove(inst.socketlist, i)
                break
            end
        end
    else
        if #inst.socketlist <=0 or item.prefab == "hermit_pearl" then
            socketnum = 5
        else
            local idx = math.random(1,#inst.socketlist)
            socketnum = inst.socketlist[idx]
            table.remove(inst.socketlist,idx)
        end
    end
    local data = {slot = socketnum, itemprefab = item.prefab}
    table.insert(inst.socketed,data)
    AddDecor(inst, data)
    item:RemoveTag("irreplaceable")
    item:Remove()

    if #inst.socketed >= MAX_SOCKETS then
        inst.components.health:SetMaxHealth(TUNING.CRABKING_HEALTH + (math.floor(inst.countgems(inst).red/2) * math.floor(inst.countgems(inst).red/2) *TUNING.CRABKING_HEALTH_BONUS ))
        inst.components.health.currenthealth = inst.components.health.maxhealth

        MakeLargeBurnableCharacter(inst, "body")
        MakeHugeFreezableCharacter(inst, "body")

        inst.components.freezable:SetResistance(3 + inst.countgems(inst).blue)

        inst:AddTag("epic")
        inst:AddTag("animal")
        inst:AddTag("scarytoprey")
        inst:AddTag("hostile")

        inst:PushEvent("activate")
    end
end

local function doshine(inst,slot)
    inst.shinefx = SpawnPrefab("crab_king_shine")
    inst.shinefx.entity:AddFollower()
    --inst.shinefx.entity:SetParent(inst)
    inst.shinefx.Follower:FollowSymbol(inst.GUID, "gem"..slot, 0, 0, 0)
end

local function gemshine(inst,color)
    if inst.socketed then
        local t = 0
        for i,data in ipairs(inst.socketed)do

            if (data.itemprefab == "bluegem" and color == "blue") or
               (data.itemprefab == "redgem" and color == "red") or
               (data.itemprefab == "purplegem" and color == "purple") or
               (data.itemprefab == "orangegem" and color == "orange") or
               (data.itemprefab == "yellowgem" and color == "yellow") or
               (data.itemprefab == "greengem" and color == "green") or
               (data.itemprefab == "opalpreciousgem" or data.itemprefab == "hermit_pearl") then
                inst:DoTaskInTime( t*0.15 ,function()
                    doshine(inst,data.slot)
                end)
                t = t+1
            end

        end
    end
end

local RETARGET_MUST_TAGS = { "_combat","hostile" }
local RETARGET_CANT_TAGS = { "wall","INLIMBO" }

local function RetargetFn(inst)
    local range = inst:GetPhysicsRadius(0) + 8
    return FindEntity(
            inst,
            TARGET_DIST,
            function(guy)
                return inst.components.combat:CanTarget(guy)
                    and (   guy.components.combat:TargetIs(inst) or
                            guy:IsNear(inst, range)
                        )
            end,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS
        )
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function OnNewTarget(inst, data)

end

local function ShouldAcceptItem(inst, item)
    return item:HasTag("gem") and #inst.socketed < MAX_SOCKETS
end

local function OnGetItemFromPlayer(inst, giver, item)
    socketitem(inst,item)
end

local function OnRefuseItem(inst, item)

end

local function OnAttacked(inst, data)
    if data.attacker then
        local x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = data.attacker.Transform:GetWorldPosition()
        local r = data.attacker:GetPhysicsRadius(.5)
        r = r / (r + 1)
        SpawnPrefab("mining_fx").Transform:SetPosition(x1 + (x - x1) * r, 0, z1 + (z - z1) * r)
    end
end

local function OnRemove(inst)

end

local function OnDead(inst)
    if inst.arms then
        for i,arm in pairs(inst.arms)do
            if arm.prefab then
                arm:DoTaskInTime(math.random()*0.3, function(inst) arm.components.health:Kill() end)
            end
        end
    end
end

local function OnEntitySleep(inst)
    inst.components.health:DoDelta(inst.components.health.maxhealth - inst.components.health.currenthealth)
    if not inst.sg:HasStateTag("inert") then
        inst.components.health:SetMaxHealth(200000)
        inst.components.health.currenthealth = inst.components.health.maxhealth
        inst.spawnstacks(inst)
        inst.dropgems(inst)
        inst.sg:GoToState("inert")
        if inst.arms then
            for i,arm in pairs(inst.arms)do
                if arm.prefab then
                    arm:Remove()
                end
            end
        end
        inst.arms = nil
        inst:RemoveTag("epic")
        inst:RemoveTag("animal")
        inst:RemoveTag("scarytoprey")
        inst:RemoveTag("hostile")

        inst:RemoveComponent("freezable")
        inst:RemoveComponent("burnable")
   end
end

local function OnEntityWake(inst)

end

local function OnTimerDone(inst, data)
    if data.name == "claw_regen_timer" then
        inst.regenarm(inst)
    end
    if data.name == "fix_timer" then
        inst.wantstoheal = nil
    end
end

local function OnSave(inst, data)
    local ents = {}
    data.socketlist = inst.socketlist

    data.socketed = {}
    data.socketedslot = {}
    if #inst.socketed > 0 then
        for k,v in ipairs(inst.socketed)do
            table.insert(data.socketed,v.itemprefab)
            table.insert(data.socketedslot,v.slot)
        end
    end

    if inst.arms then
        data.arms = {}
        for i,arm in pairs(inst.arms)do
            if arm.prefab then
                data.arms[i] = arm.GUID
                table.insert(ents, arm.GUID)
            end
        end
    end

    data.healthpercent = inst.components.health:GetPercent()

    return ents
end

local function OnLoad(inst, data)

end

local function OnLoadPostPass(inst, newents, data)
    clearsocketart(inst)
    -- reset sockets
    if data then
        inst.socketlist = data.socketlist
        if data.socketed then
            for k,v in ipairs(data.socketed) do
                local gem = SpawnPrefab(v)
                socketitem(inst,gem,data.socketedslot[k])
            end
        end
        if data.arms and #data.arms > 0 then
            inst.arms = {}
            for i,arm in pairs(data.arms) do
                if newents[arm] then
                    inst.arms[i] = newents[arm].entity
                    inst.arms[i].armpos = i
                end
            end
        end
        if data.healthpercent then
            inst.components.health:SetPercent(data.healthpercent)
        end
    end

    --retrofit crabking spawner
    if not TheSim:FindFirstEntityWithTag("crabking_spawner") then
        local spawner = SpawnPrefab("crabking_spawner")
        local x, y, z = inst.Transform:GetWorldPosition()
        spawner.Transform:SetPosition(x, y, z)
        spawner.components.childspawner.childreninside = 0
        spawner.components.childspawner:TakeOwnership(inst)
    end
end

local BOAT_TAGS = {"boat"}
local CRABKING_SPELLGENERATOR_TAGS = {"crabking_spellgenerator"}
local SEASTACK_TAGS = {"seastack"}
local REPAIRED_PATCH_TAGS = {"boat_repaired_patch"}

local function startcastspell(inst, freeze)
    if freeze then
        local x,y,z = inst.Transform:GetWorldPosition()
        local fx = SpawnPrefab("crabking_feeze")
        fx.crab = inst
        fx:ListenForEvent("onremove", function() removecrab(fx) end, inst)
        fx.Transform:SetPosition(x,y,z)
        local scale = 0.75 + Remap(inst.countgems(inst).blue,0,9,0,1.55)
        fx.Transform:SetScale(scale,scale,scale)
    else
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, 25, BOAT_TAGS)
        if #ents >0 then
            for i,boat in pairs(ents)do
                -- find position around boat and spawn the attack prefab
                local theta = math.random()*2*PI
                local radius = 6
                local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                local boatpt = Vector3(boat.Transform:GetWorldPosition())
                local fx = SpawnPrefab("crabking_geyserspawner")
                fx.crab = inst
                fx.fisher_prefab = inst.prefab
                fx:ListenForEvent("onremove", function() removecrab(fx) end, inst)
                fx.Transform:SetPosition(boatpt.x,boatpt.y,boatpt.z)
                fx.dogeyserburbletask(fx)
            end
        end
    end
end

local function endcastspell(inst, lastwasfreeze)
    if inst.components.timer:TimerExists("spell_cooldown") then
        inst.components.timer:StopTimer("spell_cooldown")
    end
    inst.components.timer:StartTimer("spell_cooldown",TUNING.CRABKING_CAST_DELAY)

    inst.dofreezecast = nil
    inst.wantstocast = nil

    local range = getfreezerange(inst)

    if inst.components.health:GetPercent() < TUNING.CRABKING_FREEZE_THRESHOLD and inst:IsNearPlayer(range) then
        inst.dofreezecast = true
    end

    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 25, nil, nil, CRABKING_SPELLGENERATOR_TAGS)
    if #ents > 0 then
        for i,ent in pairs(ents)do
            if (not inst.components.freezable or not inst.components.freezable:IsFrozen()) and not inst.components.health:IsDead() then
                ent:PushEvent("endspell")
            else
                ent:Remove()
            end
        end
    end
    if lastwasfreeze then
        inst.dofreezecast = nil
        local x,y,z = inst.Transform:GetWorldPosition()
        local boatents = TheSim:FindEntities(x,y,z, 25, BOAT_TAGS)
        if #boatents > 0 then
            inst.wantstocast = true
        end
        inst.gemshine(inst,"blue")
    else
        inst.gemshine(inst,"purple")
    end
end

local function oncrabfreeze(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 25, nil, nil, CRABKING_SPELLGENERATOR_TAGS)
    if #ents > 0 then
        for i,ent in pairs(ents)do
            ent:Remove()
        end
    end
end

local function spawnstacks(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local stacks =  math.max(0,TUNING.CRABKING_STACKS - #TheSim:FindEntities(pos.x,0,pos.z, 20, SEASTACK_TAGS))
    local pos = Vector3(inst.Transform:GetWorldPosition())
    if stacks > 0 then
        for i=1,stacks do
            local theta = math.random()*2*PI
            local radius = 9+ (math.pow(math.random(),0.8)* (17-9) )
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            if not TheWorld.Map:GetPlatformAtPoint(pos.x+offset.x, pos.z+offset.z) and #TheSim:FindEntities(pos.x+offset.x,0,pos.z+offset.z, 3, SEASTACK_TAGS) <= 0 then
                inst:DoTaskInTime(math.random()*0.5,function()
                    local stack = SpawnPrefab("seastack")
                    stack.Transform:SetPosition(pos.x+offset.x,0,pos.z+offset.z)
                    stack.AnimState:PlayAnimation(stack.stackid.."_emerge")
                    stack.AnimState:PushAnimation(stack.stackid.."_full")
                    SpawnPrefab("splash_green_large").Transform:SetPosition(pos.x+offset.x,0,pos.z+offset.z)
                end)
            end
        end
    end
end

local function removearm(inst,armpos)
    inst.components.timer:StartTimer("claw_regen_delay"..armpos,TUNING.CRABKING_CLAW_RESPAWN_DELAY)
end

local function spawnarm(inst,armpos, fx)

    local clawsnum = TUNING.CRABKING_BASE_CLAWS + (math.floor(inst.countgems(inst).green/2))

    local theta = armpos*(2*PI/clawsnum )
    local radius = 8
    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

    local pos = Vector3(inst.Transform:GetWorldPosition()) + offset
    local boat =  TheWorld.Map:GetPlatformAtPoint(pos.x, pos.z)
    local tries = 0
    while boat and tries < 5 do

        if boat then
            pos = Vector3(boat.Transform:GetWorldPosition())
            local theta = math.random()*2*PI
            local radius = 5
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            pos = pos + offset
        end
        boat =  TheWorld.Map:GetPlatformAtPoint(pos.x, pos.z)
        tries = tries + 1
    end
    if not boat then
        local arm = SpawnPrefab("crabking_claw")
        arm.Transform:SetPosition(pos.x, 0, pos.z)
        arm.armpos = armpos
        inst.arms[armpos] = arm
        local health = TUNING.CRABKING_CLAW_HEALTH + (math.ceil(inst.countgems(inst).green/2)* TUNING.CRABKING_CLAW_HEALTH_BOOST )
        arm.components.health:SetMaxHealth(health)
        arm.components.health:SetCurrentHealth(health)
        arm:PushEvent("emerge")

        local function death_event()
            removearm(inst, armpos)
            inst:RemoveEventCallback("death", death_event, arm)
        end
        inst:ListenForEvent("death", death_event, arm)
    end
    if fx then
        inst.gemshine(inst,"green")
    end
end

local function spawnarms(inst)

    local clawsnum = TUNING.CRABKING_BASE_CLAWS + (math.floor(inst.countgems(inst).green/2))


    if not inst.arms then
        inst.arms = {}
    end

    for i=1,clawsnum do
        if not inst.arms[i] or not inst.arms[i].prefab or not inst.arms[i]:IsValid() then
            inst:DoTaskInTime(ARMTIME[i%#ARMTIME+1],function() inst.spawnarm(inst,i)end)
        end
    end
end

local function regenarm(inst)
    if inst.arms then
        for i, arm in ipairs(inst.arms) do
            if not arm.prefab or not arm:IsValid() and not inst.components.timer:TimerExists("claw_regen_delay"..i) then
                inst.spawnarm(inst,i,true)
                break
            end
        end
        inst.components.timer:StartTimer("claw_regen_timer",TUNING.CRABKING_CLAW_REGEN_DELAY)
    end
end

local function finishfixing(inst)
    inst.wantstoheal = nil
    inst.components.timer:StartTimer("heal_cooldown",TUNING.CRABKING_HEAL_DELAY)
    if inst.components.timer:TimerExists("claw_regen_timer") then
        inst.components.timer:StopTimer("claw_regen_timer")
    end
end

local function dropgems(inst)
    for i, socket in ipairs (inst.socketed) do
        local gem = SpawnPrefab(socket.itemprefab)
        inst.components.lootdropper:FlingItem(gem)
    end
    inst.socketed = {}
    inst.socketlist = {1,2,3,4,6,7,8,9}

    clearsocketart(inst)
end

local function removegem(inst,gemname)
    for i=#inst.socketed,1, -1 do
        if inst.socketed[i].itemprefab == gemname then
            table.remove(inst.socketed,i)
        end
    end
end
local function addgem(inst,gemname)
    table.insert(inst.socketed,{itemprefab = gemname})
end

local function countgems(inst)

    local gems = {
        red = 0,
        blue = 0,
        purple = 0,
        orange = 0,
        yellow = 0,
        green = 0,
        pearl = 0,
		opal = 0,
    }

    if inst.socketed then
        for i,data in ipairs(inst.socketed)do
            if data.itemprefab == "bluegem" then
                gems.blue = gems.blue + 1
            elseif data.itemprefab == "redgem" then
                gems.red = gems.red + 1
            elseif data.itemprefab == "purplegem" then
                gems.purple = gems.purple + 1
            elseif data.itemprefab == "orangegem" then
                gems.orange = gems.orange + 1
            elseif data.itemprefab == "yellowgem" then
                gems.yellow = gems.yellow + 1
            elseif data.itemprefab == "greengem" then
                gems.green = gems.green + 1
            elseif data.itemprefab == "opalpreciousgem" then
                gems.green =  gems.green + 1
                gems.yellow = gems.yellow + 1
                gems.orange = gems.orange + 1
                gems.red =    gems.red + 1
                gems.blue =   gems.blue + 1
                gems.purple = gems.purple + 1
                gems.opal =   gems.opal + 1
            elseif data.itemprefab == "hermit_pearl" then
                gems.green =  gems.green + 3
                gems.yellow = gems.yellow + 3
                gems.orange = gems.orange + 3
                gems.red =    gems.red + 3
                gems.blue =   gems.blue + 3
                gems.purple = gems.purple + 3
                gems.pearl = gems.pearl +1
            end
        end
    end

    return gems
end

local function countarms(inst)
    local count = 0
    if inst.arms then
        for i,arm in ipairs(inst.arms)do
            if arm.prefab and arm:IsValid() then
                count = count+1
            end
        end
    end
    return count
end

local function spawnchunk(inst,prefab,pos)
    local chip = SpawnPrefab(prefab)
    if chip and pos then
        local pos = Vector3(inst.Transform:GetWorldPosition())
        chip.Transform:SetPosition(pos.x,0,pos.z)
    end
    return chip
end

local function setdamageart(inst)
    local index = math.random(1,#inst.nondamagedsymbollist)
    local art = inst.nondamagedsymbollist[index]
    table.remove(inst.nondamagedsymbollist,index)
    table.insert(inst.damagedsymbollist,art)

    local fx = SpawnPrefab("round_puff_fx_lg")
    fx.entity:AddFollower()
    fx.entity:SetParent(inst.entity)
    fx.Follower:FollowSymbol(inst.GUID, "damage"..art, 0, 0, 0)

    local pos = Vector3(inst.AnimState:GetSymbolPosition("damage"..art,0,0,0))
    if art == 7 or art == 8 then
       inst.spawnchunk(inst,"crabking_chip_high",pos)
    elseif art == 1 or art == 3 or art == 5 or art == 6 or art == 9 or art == 10 then
        inst.spawnchunk(inst,"crabking_chip_med",pos)
    elseif art == 2 or art == 4 then
        inst.spawnchunk(inst,"crabking_chip_low",pos)
    end
    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/rock_hit")
    inst.AnimState:OverrideSymbol("damage"..art, "crab_king_build", "nil")
end

local function setrepairedart(inst)
    local index = math.random(1,#inst.damagedsymbollist)
    local art = inst.damagedsymbollist[index]
    table.remove(inst.damagedsymbollist,index)
    table.insert(inst.nondamagedsymbollist,art)
    inst.AnimState:OverrideSymbol("damage"..art, "crab_king_build", "damage"..art)
end

local function onHealthChange(inst,data)
    local current = data.oldpercent

    local done = nil
    while data.newpercent and not done do
        if data.oldpercent > data.newpercent then
            current = math.max(current - 0.1,data.newpercent)
        else
            current = math.min(current + 0.1,data.newpercent)
        end
        if (current <= 0.9 and current > 0.8 and #inst.nondamagedsymbollist >= 10) or
           (current <= 0.8 and current > 0.7 and #inst.nondamagedsymbollist >= 9) or
           (current <= 0.7 and current > 0.6 and #inst.nondamagedsymbollist >= 8) or
           (current <= 0.6 and current > 0.5 and #inst.nondamagedsymbollist >= 7) or
           (current <= 0.5 and current > 0.4 and #inst.nondamagedsymbollist >= 6) or
           (current <= 0.4 and current > 0.3 and #inst.nondamagedsymbollist >= 5) or
           (current <= 0.3 and current > 0.2 and #inst.nondamagedsymbollist >= 4) or
           (current <= 0.2 and current > 0.1 and #inst.nondamagedsymbollist >= 3) or
           (current <= 0.1 and current > 0.0 and #inst.nondamagedsymbollist >= 2) or
           (current <= 0.0                   and #inst.nondamagedsymbollist >= 1) then

            setdamageart(inst)
        end

        if (current >= 1.0                   and #inst.nondamagedsymbollist < 10) or
           (current >= 0.9 and current < 1.0 and #inst.nondamagedsymbollist < 9) or
           (current >= 0.8 and current < 0.9 and #inst.nondamagedsymbollist < 8) or
           (current >= 0.7 and current < 0.8 and #inst.nondamagedsymbollist < 7) or
           (current >= 0.6 and current < 0.7 and #inst.nondamagedsymbollist < 6) or
           (current >= 0.5 and current < 0.6 and #inst.nondamagedsymbollist < 5) or
           (current >= 0.4 and current < 0.5 and #inst.nondamagedsymbollist < 4) or
           (current >= 0.3 and current < 0.4 and #inst.nondamagedsymbollist < 3) or
           (current >= 0.2 and current < 0.3 and #inst.nondamagedsymbollist < 2) or
           (current >= 0.1 and current < 0.2 and #inst.nondamagedsymbollist < 1) then

            setrepairedart(inst)
        end
        if current == data.newpercent then
            done = true
        end
    end
end

SetSharedLootTable( 'crabking',
{
    {"chesspiece_crabking_sketch",          1.00},
    {"trident_blueprint",                   1.00},
    {'meat',                                1.00},
    {'meat',                                1.00},
    {'meat',                                1.00},
    {'meat',                                1.00},
    {'meat',                                1.00},
    {'meat',                                1.00},
    {'meat',                                1.00},
    {"singingshell_octave5",                1.00},
    {"singingshell_octave5",                1.00},
    {"singingshell_octave5",                1.00},
    {"singingshell_octave5",                1.00},
    {"singingshell_octave5",                0.50},
    {"singingshell_octave5",                0.25},
    {"singingshell_octave4",                1.00},
    {"singingshell_octave4",                1.00},
    {"singingshell_octave4",                1.00},
    {"singingshell_octave4",                0.50},
    {"singingshell_octave4",                0.25},
    {"singingshell_octave3",                1.00},
    {"singingshell_octave3",                1.00},
    {"singingshell_octave3",                0.50},
    {"barnacle",                            1.00},
    {"barnacle",                            1.00},
    {"barnacle",                            1.00},
    {"barnacle",                            0.25},
    {"barnacle",                            0.25},
    {"barnacle",                            0.25},
    {"barnacle",                            0.25},
})

local function GetWintersFeastOrnaments(inst)
	local gems = inst:countgems()
	local is_pearled = gems.pearl > 0
	if not is_pearled and gems.opal >= 3 then
		local hermit = TheWorld.components.messagebottlemanager ~= nil and TheWorld.components.messagebottlemanager:GetHermitCrab()
		is_pearled = hermit and hermit.pearlgiven
	end

	return is_pearled and {basic = 2, special = "winter_ornament_boss_crabkingpearl"} or {basic = 1, special = "winter_ornament_boss_crabking"}
end

local function PushMusic(inst)
    if ThePlayer == nil or (inst.sg and inst.sg:HasStateTag("inert")) then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "crabking" })
    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
        inst._playingmusic = false
    end
end

local function getstatus(inst)
    return inst.sg and inst.sg:HasStateTag("inert") and "INERT"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(3.4) --2.5

    MakeWaterObstaclePhysics(inst, 1.7, 2, 0.1)

    inst.MiniMapEntity:SetIcon("crabking.png")

    local s  = 0.7
    inst.Transform:SetScale(s, s, s)

    inst.AnimState:SetBank("king_crab")
    inst.AnimState:SetBuild("crab_king_build")

    inst:AddTag("ignorewalkableplatforms") -- added so the crab king will not get attached to a moving boat when it is past entity-sleep range
    inst:AddTag("crabking")
    inst:AddTag("largecreature")
    inst:AddTag("gemsocket")
    inst:AddTag("birdblocker")

    inst.AnimState:PlayAnimation("inert", true)

    inst.entity:SetPristine()

    inst.spawnchunk = spawnchunk

    if not TheNet:IsDedicated() then
        inst._playingmusic = false
        inst:DoPeriodicTask(1, PushMusic, 0)
    end

    if not TheWorld.ismastersim then
        return inst
    end

    ------------------------------------------

    inst:SetStateGraph("SGcrabking")

    ------------------

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(200000)--TUNING.CRABKING_HEALTH)
    inst.components.health.destroytime = 5

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.CRABKING_DAMAGE)
    inst.components.combat.playerdamagepercent = TUNING.CRABKING_DAMAGE_PLAYER_PERCENT
    inst.components.combat:SetRange(TUNING.CRABKING_ATTACK_RANGE)
    inst.components.combat:SetAreaDamage(TUNING.CRABKING_AOE_RANGE, TUNING.CRABKING_AOE_SCALE)
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetAttackPeriod(TUNING.CRABKING_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    ------------------------------------------

    inst:AddComponent("inventory")

    ------------------------------------------

    inst:AddComponent("explosiveresist")

    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('crabking')
	inst.components.lootdropper.GetWintersFeastOrnaments = GetWintersFeastOrnaments

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
    inst.components.inspectable:RecordViews()

    ------------------------------------------

    inst:AddComponent("timer")

    ------------------------------------------

    inst:AddComponent("knownlocations")

    ------------------------------------------

    inst:AddComponent("entitytracker")

    ------------------------------------------

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false

    ------------------------------------------

    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDead)
    inst:ListenForEvent("onremove", OnRemove)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("entitysleep", OnEntitySleep)
    inst:ListenForEvent("entitywake", OnEntityWake)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("healthdelta", onHealthChange)
    inst:ListenForEvent("freeze", oncrabfreeze)

    clearsocketart(inst)
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    inst.socketlist = {1,2,3,4,6,7,8,9}
    inst.damagedsymbollist = {}
    inst.nondamagedsymbollist = {1,2,3,4,5,6,7,8,9,10}
    inst.socketed = {}
    inst.startcastspell = startcastspell
    inst.endcastspell = endcastspell
    inst.spawnarms = spawnarms
    inst.regenarm = regenarm
    inst.spawnarm = spawnarm
    inst.spawnstacks = spawnstacks
    inst.countarms = countarms
    inst.countgems = countgems
    inst.dropgems = dropgems
    inst.finishfixing = finishfixing
    inst.gemshine = gemshine
    inst.spawnchunk = spawnchunk
    inst.removegem = removegem
    inst.addgem = addgem
    inst.getfreezerange = getfreezerange

    return inst
end

local function dogeyserburbletask(inst)
    if inst.burbletask then
        inst.burbletask:Cancel()
        inst.burbletask = nil
    end
    local totalcasttime = TUNING.CRABKING_CAST_TIME - (inst.crab and inst.crab:IsValid() and math.floor(inst.crab.countgems(inst.crab).yellow/2 or 0))
    local time = Remap(inst.components.age:GetAge(),0,totalcasttime,0.2,0.01)
    inst.burbletask = inst:DoTaskInTime(time,function() inst.burble(inst) end) -- 0.01+ math.random()*0.1
end

local function burble(inst)
    local MAXRADIUS = 6
    local x,y,z = inst.Transform:GetWorldPosition()
    local theta = math.random()*2*PI
    local radius = math.pow(math.random(),0.8)* MAXRADIUS
    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
    local prefab = "crab_king_bubble"..math.random(1,3)

    if TheWorld.Map:IsOceanAtPoint(x+offset.x, 0, z+offset.z) then
        local fx = SpawnPrefab(prefab)
        fx.Transform:SetPosition(x+offset.x,y+offset.y,z+offset.z)
    else
        local boat = TheWorld.Map:GetPlatformAtPoint(x+offset.x, z+offset.z)
        if boat then
            ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.1, 0.01, 0.3, boat, boat:GetPhysicsRadius(4))
        end
    end

    dogeyserburbletask(inst)
end

local function endgeyser(inst)
    inst:DoTaskInTime(2.4,function()
        if inst.burbletask then
            inst.burbletask:Cancel()
            inst.burbletask = nil
        end
    end)
    local extrageysers = 0
    if inst.crab and inst.crab:IsValid() then
        extrageysers = math.floor(inst.crab.countgems(inst.crab).purple/2)
    end
    for i=1,TUNING.CRABKING_DEADLY_GEYSERS + extrageysers do
        inst:DoTaskInTime(math.random()*0.4,function()
            local MAXRADIUS = 4.5
            local x,y,z = inst.Transform:GetWorldPosition()
            local theta = math.random()*2*PI
            local radius = math.pow(math.random(),0.8)* MAXRADIUS
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            local prefab = "crab_king_waterspout"
            if TheWorld.Map:IsOceanAtPoint(x+offset.x, 0, z+offset.z) then
                local fx = SpawnPrefab(prefab)
                fx.Transform:SetPosition(x+offset.x,y+offset.y,z+offset.z)

                local INITIAL_LAUNCH_HEIGHT = 0.1
                local SPEED = 8
                local CANT_HAVE_TAGS = {"INLIMBO", "outofreach", "DECOR"}
                local function launch_away(inst, position)
                    local ix, iy, iz = inst.Transform:GetWorldPosition()
                    inst.Physics:Teleport(ix, iy + INITIAL_LAUNCH_HEIGHT, iz)

                    local px, py, pz = position:Get()
                    local angle = (180 - inst:GetAngleToPoint(px, py, pz)) * DEGREES
                    local sina, cosa = math.sin(angle), math.cos(angle)
                    inst.Physics:SetVel(SPEED * cosa, 4 + SPEED, SPEED * sina)
                end
                local affected_entities = TheSim:FindEntities(x+offset.x,y+offset.y,z+offset.z, 2, nil, CANT_HAVE_TAGS)
                for _, v in ipairs(affected_entities) do
                    if v.components.oceanfishable ~= nil then
                        -- Launch fishable things because why not.

                        local projectile = v.components.oceanfishable:MakeProjectile()
                        if projectile.components.weighable ~= nil then
                            projectile.components.weighable.prefab_override_owner = inst.fisher_prefab
                        end
                        local position = Vector3(x+offset.x,y+offset.y,z+offset.z)
                        if projectile.components.complexprojectile then
                            projectile.components.complexprojectile:SetHorizontalSpeed(16)
                            projectile.components.complexprojectile:SetGravity(-30)
                            projectile.components.complexprojectile:SetLaunchOffset(Vector3(0, 0.5, 0))
                            projectile.components.complexprojectile:SetTargetOffset(Vector3(0, 0.5, 0))

                            local v_position = v:GetPosition()
                            local launch_position = v_position + (v_position - position):Normalize() * SPEED
                            projectile.components.complexprojectile:Launch(launch_position, projectile)
                        else
                            launch_away(projectile, position)
                        end
                    end
                end


            else
                local boat = TheWorld.Map:GetPlatformAtPoint(x+offset.x, z+offset.z)
                if boat then
                    local pt = Vector3(x+offset.x,0,z+offset.z)
                    boat.components.health:DoDelta(-TUNING.CRABKING_GEYSER_BOATDAMAGE)

                    -- look for patches
                    local nearpatch = TheSim:FindEntities(pt.x, 0, pt.z, 2, REPAIRED_PATCH_TAGS)
                    for i,patch in pairs(nearpatch)do
                        pt = Vector3(patch.Transform:GetWorldPosition())
                        patch:Remove()
                        break
                    end

                    boat:PushEvent("spawnnewboatleak", {pt = pt, leak_size = "small_leak", playsoundfx = true})
                end
            end
        end)
    end

    inst:DoTaskInTime(1,function() inst:Remove() end)
end

local function geyserfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("fx")
    inst:AddTag("crabking_spellgenerator")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("age")

    inst.persists = false

    inst.burble = burble
    inst.dogeyserburbletask = dogeyserburbletask

    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble_LP","burble")
    inst.SoundEmitter:SetParameter("burble", "intensity", 0)
    inst.burblestarttime = GetTime()
    inst.burbleintensity = inst:DoPeriodicTask(1,function()
            local totalcasttime = TUNING.CRABKING_CAST_TIME - ((inst.crab and inst.crab:IsValid()) and math.floor(inst.crab.countgems(inst.crab).yellow/2) or 0)
            local intensity = math.min(1,( GetTime() - inst.burblestarttime ) / totalcasttime)

            inst.SoundEmitter:SetParameter("burble", "intensity", intensity)
      end)
    inst:ListenForEvent("onremove", function()
        if inst.burbletask then
            inst.burbletask:Cancel()
            inst.burbletask = nil
        end
        if inst.burbleintensity then
            inst.burbleintensity:Cancel()
            inst.burbleintensity = nil
        end
        inst.SoundEmitter:KillSound("burble")
    end)

    inst:ListenForEvent("endspell", function()
        endgeyser(inst)
    end)

    inst:DoTaskInTime(TUNING.CRABKING_CAST_TIME+2,function()
        endgeyser(inst)
    end)



    return inst
end


-- FREEZE FX

local function onfreeze(inst, target)
    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    end

    if target.components.burnable ~= nil then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end

    if target.components.combat ~= nil and inst.crab and inst.crab:IsValid() then
        target.components.combat:SuggestTarget(inst.crab)
    end

    if target.sg ~= nil and not target.sg:HasStateTag("frozen") and inst.crab and inst.crab:IsValid() then
        target:PushEvent("attacked", { attacker = inst.crab, damage = 0, weapon = inst })
    end

    if target.components.freezable ~= nil then
        target.components.freezable:AddColdness(10,10 + Remap((inst.crab and inst.crab:IsValid() and inst.crab.countgems(inst.crab).blue or 0),0,9,0,10) )
        target.components.freezable:SpawnShatterFX()
    end
end

local function dofreezefz(inst)
    if inst.freezetask then
        inst.freezetask:Cancel()
        inst.freezetask = nil
    end
    local time = 0.1
    inst.freezetask = inst:DoTaskInTime(time,function() inst.freezefx(inst) end)
end

local function freezefx(inst)
    local function spawnfx()
        local MAXRADIUS = inst.crab and inst.crab:IsValid() and getfreezerange(inst.crab) or (TUNING.CRABKING_FREEZE_RANGE * 0.75)
        local x,y,z = inst.Transform:GetWorldPosition()
        local theta = math.random()*2*PI
        local radius = 4+ math.pow(math.random(),0.8)* MAXRADIUS
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

        local prefab = "crab_king_icefx"
        local fx = SpawnPrefab(prefab)
        fx.Transform:SetPosition(x+offset.x,y+offset.y,z+offset.z)
    end

    local MAXFX = Remap(( inst.crab and inst.crab:IsValid() and inst.crab.countgems(inst.crab).blue or 0),0, 9,5,15)


    local fx = Remap(inst.components.age:GetAge(),0,TUNING.CRABKING_CAST_TIME_FREEZE - (math.min((inst.crab and inst.crab:IsValid() and math.floor(inst.crab.countgems(inst.crab).yellow/2) or 0),4)),1,MAXFX)

    for i=1,fx do
        if math.random()<0.2 then
            spawnfx()
        end
    end

    dofreezefz(inst)
end

local FREEZE_CANT_TAGS = {"crabking_claw","crabking", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO"}

local function dofreeze(inst)
    local interval = 0.2
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local range = inst.crab and inst.crab:IsValid() and getfreezerange(inst.crab) or (TUNING.CRABKING_FREEZE_RANGE * 0.75)
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, range, nil, FREEZE_CANT_TAGS)
    for i,v in pairs(ents)do
        if v.components.temperature then
            local rate = (TUNING.CRABKING_BASE_FREEZE_AMOUNT + ((inst.crab and inst.crab:IsValid() and inst.crab.countgems(inst.crab).blue or 0) * TUNING.CRABKING_FREEZE_INCRAMENT)) /( (TUNING.CRABKING_CAST_TIME_FREEZE - (inst.crab and inst.crab:IsValid() and math.floor(inst.crab.countgems(inst.crab).yellow/2) or 0) ) /interval)
            if v.components.moisture then
                rate = rate * Remap(v.components.moisture:GetMoisture(),0,v.components.moisture.maxmoisture,1,3)
            end

            local mintemp = v.components.temperature.mintemp
            local curtemp = v.components.temperature:GetCurrent()
            if mintemp < curtemp then
                v.components.temperature:DoDelta(math.max(-rate, mintemp - curtemp))
            end
        end
    end

    local time = 0.2
    inst.lowertemptask = inst:DoTaskInTime(time,function() inst.dofreeze(inst) end)
end

local function endfreeze(inst)
    if inst.freezetask then
        inst.freezetask:Cancel()
        inst.freezetask = nil
    end

    if inst.lowertemptask then
        inst.lowertemptask:Cancel()
        inst.lowertemptask = nil
    end

    local pos = Vector3(inst.Transform:GetWorldPosition())
    local range = inst.crab and inst.crab:IsValid() and getfreezerange(inst.crab) or (TUNING.CRABKING_FREEZE_RANGE * 0.75)
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, range, nil, FREEZE_CANT_TAGS)
    for i,v in pairs(ents)do
        onfreeze(inst, v)
    end
    SpawnPrefab("crabking_ring_fx").Transform:SetPosition(pos.x,pos.y,pos.z)
    inst:DoTaskInTime(1,function() inst:Remove() end)
end

local function freezefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("fx")
    inst:AddTag("crabking_spellgenerator")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("age")

    inst.persists = false

    inst.freezefx = freezefx
    inst.dofreeze = dofreeze
    inst:DoTaskInTime(0,function()
        dofreezefz(inst)
        dofreeze(inst)
    end)

    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/ice_attack")

    inst:ListenForEvent("onremove", function()
        if inst.burbletask then
            inst.burbletask:Cancel()
            inst.burbletask = nil
        end
    end)

    inst:ListenForEvent("endspell", function()
        endfreeze(inst)
    end)

    inst:DoTaskInTime(TUNING.CRABKING_CAST_TIME+2,function()
        endfreeze(inst)
    end)

    return inst
end

local function chipfn(type)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local phys = inst.entity:AddPhysics()
    phys:SetMass(1)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.FLYERS)
    phys:ClearCollisionMask()
    phys:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    phys:SetCapsule(0.5, 1)

    local s  = 0.7
    inst.Transform:SetScale(s, s, s)

    inst.AnimState:SetBank("rockchip")
    inst.AnimState:SetBuild("crabking_rockchip")
    inst.AnimState:PlayAnimation("rockchip_"..type)

    inst:AddTag("NOCLICK")
    inst:AddTag("fx")

    local down = TheCamera:GetDownVec()
    local offset = (math.random()*30 + 50)
    if math.random() > 0.5 then
        offset = -offset
    end
    local angle = (math.atan2(-down.z, down.x) / DEGREES ) + offset
    inst.Transform:SetRotation(angle)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("hit_water") or inst.AnimState:IsCurrentAnimation("hit_land") then
            inst:Remove()
        end
        if not inst.landed then
            inst.Physics:Stop()
            inst.landed = true
            local pos = Vector3(inst.Transform:GetWorldPosition())
            if not TheWorld.Map:IsVisualGroundAtPoint(pos.x,pos.y,pos.z) and not TheWorld.Map:GetPlatformAtPoint(pos.x,pos.z) then
                inst.AnimState:PlayAnimation("hit_water")
            else
                inst.AnimState:PlayAnimation("hit_land")
            end
        end
    end)

    inst.Physics:SetMotorVel(math.random(8,12), 0, 0)

    inst.persists = false

    return inst
end



return Prefab("crabking", fn, assets, prefabs),
       Prefab("crabking_geyserspawner", geyserfn, nil, geyserprefabs),
       Prefab("crabking_feeze", freezefn, nil, freezeprefabs),
       Prefab("crabking_chip_high", function() return chipfn("high") end, chipassets),
       Prefab("crabking_chip_med",  function() return chipfn("mid") end, chipassets),
       Prefab("crabking_chip_low",  function() return chipfn("low") end,  chipassets)
