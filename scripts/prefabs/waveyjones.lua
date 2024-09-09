local assets =
{
    Asset("ANIM", "anim/shadow_wavey_jones.zip"),
    --Asset("ANIM", "anim/shadow_wavey_jones.zip"),
}

local prefabs =
{
    "waveyjones_arm",
    "waveyjones_marker"
}

local assets_hand =
{
    Asset("ANIM", "anim/shadow_wavey_jones_hand.zip"),
}

local prefabs_hand =
{
    "waveyjones_hand_art",
    "shadowhand_fx",
}

local assets_arm =
{

}

local prefabs_arm =
{
    "waveyjones_hand"
}

local handbrain = require("brains/waveyjoneshandbrain")

local function scareaway(inst)
    inst.persists = false

    local function scarearm(arm)
        if arm then
            if arm.hand then
                if arm.hand.handart then
                    arm.hand.handart:PushEvent("onscared")
                end
                arm.hand:PushEvent("onscared")
            end
            arm:PushEvent("onscared")
        end
    end
    if inst and inst:IsValid() then
        scarearm(inst.arm1)

        scarearm(inst.arm2)

        if not inst.AnimState:IsCurrentAnimation("scared") then
            inst.SoundEmitter:PlaySound("dangerous_sea/creatures/wavey_jones/scared")
            inst.AnimState:PlayAnimation("scared")
        end
        inst:ListenForEvent("animover", function()
            if inst.AnimState:IsCurrentAnimation("scared") then
                inst:Remove()
            end
        end)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("shadow_wavey_jones")
    inst.AnimState:SetBank("shadow_wavey_jones")
    inst.AnimState:PlayAnimation("idle_in", true)
    inst.AnimState:PushAnimation("idle", true)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_WAVES)
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst.no_wet_prefix = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("entitytracker")

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(function()
        if not inst.AnimState:IsCurrentAnimation("scared") then
            local x, y, z = inst.Transform:GetWorldPosition()
            local players = FindPlayersInRange(x, y, z, 0.5)
            if #players > 0 then
                scareaway(inst)
            end
        end
    end)

    inst:DoTaskInTime(0,function()
        if inst.components.entitytracker:GetEntity("boat") then
            local boat = inst.components.entitytracker:GetEntity("boat")

            local function spawnarm(spacing,entname,left)
                local bx,by,bz = boat.Transform:GetWorldPosition()
                local x,y,z = inst.Transform:GetWorldPosition()
                local primeangle = boat:GetAngleToPoint(x, y, z) * DEGREES
                local radius = boat.components.hull:GetRadius() -0.5
                local offset1 = Vector3(radius * math.cos( primeangle + spacing ), 0, -radius * math.sin( primeangle + spacing ))


                inst[entname] = SpawnPrefab("waveyjones_arm")
                inst[entname].Transform:SetPosition(bx+offset1.x,0,bz+offset1.z)
                local arm1angle = inst[entname]:GetAngleToPoint(bx, by, bz)
                inst[entname].Transform:SetRotation(arm1angle)
                inst[entname].jones = inst
                if left then
                    inst[entname].left =true
                end
            end

            inst:DoTaskInTime(0.5,function()
                spawnarm(0.5,"arm1")
            end)

            inst:DoTaskInTime(0.7,function()
                spawnarm(-0.5,"arm2",true)
            end)

        end
    end)

    inst:ListenForEvent("onremove", function()
        scareaway(inst)
    end)

    inst:AddComponent("timer")

    inst:ListenForEvent("laugh", function()
        if not inst.components.timer:TimerExists("laughter") and not inst.AnimState:IsCurrentAnimation("scared") then
            inst.components.timer:StartTimer("laughter", 5)

            inst.AnimState:PlayAnimation("laugh")
            inst:DoTaskInTime(15*FRAMES,function()
                if inst.AnimState:IsCurrentAnimation("laugh") then
                    inst.SoundEmitter:PlaySound("dangerous_sea/creatures/wavey_jones/laugh")
                end
            end)
        end
    end)

    return inst
end

local function ClearWaveyJonesTarget(inst)
    if inst.waveyjonestarget then
        TheWorld:removewaveyjonestarget(inst.waveyjonestarget)
        inst.waveyjonestarget = nil
    end
end

local function resetposition(inst)
    if inst.arm then
        inst.Transform:SetPosition(inst.arm.Transform:GetWorldPosition())
        inst.sg:GoToState("in")
        inst.components.timer:StartTimer("reactiondelay", 2)
        inst.Transform:SetRotation(inst.arm.Transform:GetRotation())
        if inst.handart then
            inst.handart.Transform:SetRotation(inst.arm.Transform:GetRotation())
            inst.handart.Transform:SetPosition(inst.arm.Transform:GetWorldPosition())
            inst.handart.pauserotation = true
        end
    end
end
local rotatearthand = function(inst)
    if inst.handart and inst.handart:IsValid() then
        inst.handart.Transform:SetPosition(inst.Transform:GetWorldPosition())

        if not inst.handart.pauserotation and inst.arm then

            local x,y,z = inst.Transform:GetWorldPosition()

            local dist = inst:GetDistanceSqToInst(inst.arm)
            local rotation = nil
            if dist < 0.5 * 0.5 then
                 rotation = inst.arm.Transform:GetRotation()
            else
                 rotation = inst.arm:GetAngleToPoint(x,y,z)
            end
            inst.handart.Transform:SetRotation( rotation )
        end
    end
end

local function playernear(inst)
    inst:PushEvent("trapped")
end

local function playerfar(inst)
    inst:PushEvent("released")
end


local function handfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst, 10, .5)

    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.WAVEYJONES.HAND.WALK_SPEED
    inst:SetStateGraph("SGwaveyjoneshand")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(0.8,1.2)
    inst.components.playerprox:SetOnPlayerNear(playernear)
    inst.components.playerprox:SetOnPlayerFar(playerfar)

    inst:AddComponent("timer")

    inst:SetBrain(handbrain)

    inst.ClearWaveyJonesTarget = ClearWaveyJonesTarget

    inst:ListenForEvent("onremove", function()
        inst:ClearWaveyJonesTarget()
    end)

    inst:ListenForEvent("onscared", function()
        inst:Remove()
    end)

    inst.rotatearthand = rotatearthand
    inst.resetposition = resetposition

    inst:DoTaskInTime(0,function()
        local handart = SpawnPrefab("waveyjones_hand_art")
        if inst.left then
            handart.AnimState:SetScale(1,-1)
        end
        handart.sg:GoToState("in")
        inst.handart = handart
        inst.handart.parent = inst
        inst.handart.pauserotation = true
        inst.handart.Transform:SetRotation( inst.Transform:GetRotation() )

        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnWallUpdateFn(rotatearthand)

        inst.components.timer:StartTimer("reactiondelay", 2)
    end)

    return inst
end

local function handartfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("shadow_wavey_jones_hand")
    inst.AnimState:SetBank("shadow_wavey_jones_hand")
    inst.AnimState:PlayAnimation("hand_in_loop")

    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_SKYSHADOWS)
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)

    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.no_wet_prefix = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:SetStateGraph("SGwaveyjoneshand_art")

    inst:ListenForEvent("onscared", function()
        inst.sg:GoToState("scared")
    end)

    inst:ListenForEvent("STATE_IN", function() inst.sg:GoToState("in")  end)
    inst:ListenForEvent("STATE_IDLE", function() inst.sg:GoToState("idle")  end)
    inst:ListenForEvent("STATE_MOVING", function() inst.sg:GoToState("moving")  end)
    inst:ListenForEvent("STATE_PREMOVING", function() inst.sg:GoToState("premoving")  end)
    inst:ListenForEvent("STATE_LOOP_ACTION_ANCHOR_PST", function() inst.sg:GoToState("loop_action_anchor_pst")  end)
    inst:ListenForEvent("STATE_LOOP_ACTION_ANCHOR", function() inst.sg:GoToState("loop_action_anchor")  end)
    inst:ListenForEvent("STATE_SHORT_ACTION", function() inst.sg:GoToState("short_action")  end)
    inst:ListenForEvent("STATE_MOVING", function() inst.sg:GoToState("moving")  end)
    inst:ListenForEvent("STATE_PREMOVING", function() inst.sg:GoToState("premoving")  end)
    inst:ListenForEvent("STATE_TRAPPED", function() inst.sg:GoToState("trapped")  end)
    inst:ListenForEvent("STATE_TRAPPED_PST", function() inst.sg:GoToState("trapped_pst")  end)
    inst:ListenForEvent("STATE_SCARED_RELOCATE", function() inst.sg:GoToState("scared_relocate")  end)

    inst:DoPeriodicTask(2,function()
        inst:DoTaskInTime(math.random()*0.5,function()
            local fx = SpawnPrefab("shadowhand_fx")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end)
    end)

    return inst
end

local function armfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst, 10, .5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(0,function()
        inst.hand = SpawnPrefab("waveyjones_hand")
        local x,y,z = inst.Transform:GetWorldPosition()
        inst.hand.Transform:SetRotation(inst.Transform:GetRotation())
        inst.hand.Transform:SetPosition(x,y,z)
        inst.hand.arm = inst
        inst.hand.sg:GoToState("in")

        if inst.left then
            inst.hand.left = true
        end
    end)

    inst:ListenForEvent("onscared", function()
        inst:Remove()
    end)

    return inst
end

local function spawnjones(inst,boat)

    local x,y,z = inst.Transform:GetWorldPosition()
    local jones = SpawnPrefab("waveyjones")
    local angle = math.random()*360

    local players = FindPlayersInRange(x, y, z, boat.components.hull:GetRadius(), true)
    local angles = {}
    if #players > 0 then
        for i,player in pairs(players)do
            local px,py,pz = player.Transform:GetWorldPosition()
            table.insert(angles,boat:GetAngleToPoint(px, py, pz))
        end

        local biggest = nil

        table.sort(angles, function(a,b) return a < b end)
        if #angles > 1 then
            for i,subangle in ipairs(angles)do
                local diff = subangle - (angles[i-1] or angles[#angles])
                if diff < 0 then
                    diff = 360 + diff
                end
                if biggest == nil or diff > biggest then
                    biggest = diff
                    angle = angles[i] - diff/2
                end
            end
        elseif #angles == 1 then
            angle = angles[1] + 180
        end
    end
    jones.Transform:SetRotation(angle-90)
    angle = angle * DEGREES
    local radius = boat.components.hull:GetRadius() - 0.5
    local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle))
    local x,y,z = boat.Transform:GetWorldPosition()
    jones.Transform:SetPosition(x+offset.x,0,z+offset.z)
    jones.components.entitytracker:TrackEntity("boat", boat)

    inst.jones = jones

    inst:ListenForEvent("onremove", function()
            inst.jones = nil
            inst.components.timer:StartTimer("respawndelay", TUNING.WAVEYJONES.RESPAWN_TIMER)
            if not inst.jonesremovedcount then
                inst.jonesremovedcount = 0
            end
            inst.jonesremovedcount = inst.jonesremovedcount +1
            if inst.jonesremovedcount >= 3 then
                inst.SoundEmitter:KillSound("creeping")
                inst:Remove()
            end
        end,jones)
end

local function markerfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("entitytracker")

    inst:AddComponent("timer")

    inst.components.timer:StartTimer("respawndelay", TUNING.WAVEYJONES.RESPAWN_TIMER)

    inst.SoundEmitter:PlaySound("dangerous_sea/creatures/wavey_jones/appear_LP", "creeping")

    inst:WatchWorldState("phase", function(src,phase)
        if phase ~= "night" then
            if inst.jones then
                scareaway(inst.jones)
            end
            inst.SoundEmitter:KillSound("creeping")
            inst:Remove()
        end
    end)

    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "respawndelay" then
            if inst.components.entitytracker:GetEntity("boat") then
                local boat = inst.components.entitytracker:GetEntity("boat")
                local player = FindClosestPlayerToInst(boat,boat.components.hull:GetRadius(),true)
                if player then
                    spawnjones(inst,boat)
                else
                    inst.components.timer:StartTimer("respawndelay", 1)
                end
            end
        end
    end)

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnWallUpdateFn(function()
        local intensity = 1
        if inst.components.timer:TimerExists("respawndelay") then
            intensity = Remap(inst.components.timer:GetTimeLeft("respawndelay"), TUNING.WAVEYJONES.RESPAWN_TIMER, 0, 0, 1)
        end
        inst.SoundEmitter:SetParameter("creeping", "intensity", intensity)
    end)

    return inst
end


return  Prefab("waveyjones", fn, assets, prefabs),
        Prefab("waveyjones_hand", handfn,  {}, prefabs_hand),
        Prefab("waveyjones_hand_art", handartfn, assets_hand, {}),
        Prefab("waveyjones_arm", armfn, assets_arm, prefabs_arm),
        Prefab("waveyjones_marker", markerfn, assets, prefabs)