local assets =
{
    Asset("ANIM", "anim/cursed_beads.zip"),
    Asset("INV_IMAGE", "cursed_beads1"),
    Asset("INV_IMAGE", "cursed_beads2"),  
    Asset("INV_IMAGE", "cursed_beads3"),
    Asset("INV_IMAGE", "cursed_beads4"),  
}

local prefabs =
{
    "monkey_morphin_power_players_fx",
    "monkey_de_morphin_fx",
    "cursed_monkey_token_prop",
}

local HIGHEST_NUM = 4

local function OnStackSizeChange(inst)
    if inst.components.stackable then
        if inst.components.stackable.stacksize > 1 then
            inst.image_num = HIGHEST_NUM
        else
            inst.image_num = math.random(1,HIGHEST_NUM-1)
        end
    else
        inst.image_num = 1
    end
    inst:seticons()
end

local function seticons(inst)
    inst.components.inventoryitem:ChangeImageName("cursed_beads"..inst.image_num)
    inst.AnimState:PlayAnimation("idle"..inst.image_num)
end

local function OnSave(inst, data)
    data.image_num = inst.image_num
end

local function OnLoad(inst, data)
    if data ~= nil and data.image_num then
        inst.image_num = data.image_num
    end
    seticons(inst)
end

local function OnTimerDone(inst, data)
    if data.name == "errode" then
        inst:StopUpdatingComponent(inst.components.curseditem)
        ErodeAway(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)

    inst.AnimState:SetBank("cursedbeads")
    inst.AnimState:SetBuild("cursed_beads")
    inst.AnimState:PlayAnimation("idle1")

    inst:AddTag("cattoy")
    inst:AddTag("monkey_token")
    inst:AddTag("nosteal")
    inst:AddTag("cursed")

    MakeInventoryFloatable(inst, "med", 0.05, 0.68)

    inst.entity:SetPristine()

    inst.image_num = 1

    if not TheWorld.ismastersim then
        return inst
    end

	inst.scrapbook_tex = "cursed_beads4"
    inst.scrapbook_specialinfo = "CURSEDMONKEYTOKEN"

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canonlygoinpocket = true

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("curseditem")
    inst.components.curseditem.curse = "MONKEY"

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("errode", TUNING.CURSED_TRINKET_LIFETIME)
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst:ListenForEvent("onpickup", function() 
            inst.components.timer:StopTimer("errode")
        end)

    inst.seticons = seticons

    OnStackSizeChange(inst)
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("stacksizechange", OnStackSizeChange)

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

local ATTACHDIST = 2

local function OnUpdateProp(inst,dt)

    if inst.target and inst.target:IsValid() then
        local dist = inst:GetDistanceSqToInst(inst.target)
        if dist < ATTACHDIST*ATTACHDIST then
            inst.target:PushEvent("stopcursechanneling",{success=true})
            inst.target = nil
            inst:Remove()
        else
            local x,y,z = inst.target.Transform:GetWorldPosition()
            local angle = inst:GetAngleToPoint(x, y, z)*DEGREES
            local dist =  math.sqrt(dist)
            local speed = math.max(Remap( dist ,0,10,20,1)*dt, 10*dt )
            if speed > 0 then
                local offset = Vector3(speed * math.cos( angle ), 0, -speed * math.sin( angle ))
                local x1,y1,z1 = inst.Transform:GetWorldPosition()
                inst.Transform:SetPosition(x1+offset.x,0,z1+offset.z)
            end
        end
    else
       -- inst:Remove()
    end
end

local function propfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeTinyFlyingCharacterPhysics(inst, 1, 0.5)

    inst.AnimState:SetBank("cursedbeads")
    inst.AnimState:SetBuild("cursed_beads")
    inst.AnimState:PlayAnimation("idle1")

    inst:AddTag("fx")

    MakeInventoryFloatable(inst, "med", 0.05, 0.68)

    inst.entity:SetPristine()

    inst.image_num = 1

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(OnUpdateProp)

    inst:ListenForEvent("onremove", function()
        if inst.target then
            inst.target:PushEvent("stopcursechanneling",{success=false})
        end
    end)

    inst.OnEntitySleep = inst.Remove

    inst.seticons = seticons

    return inst
end

return Prefab("cursed_monkey_token", fn, assets, prefabs),
        Prefab("cursed_monkey_token_prop", propfn, assets, prefabs)