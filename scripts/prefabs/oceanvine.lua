
local assets=
{
	Asset("ANIM", "anim/oceanvine.zip"),
    Asset("MINIMAP_IMAGE", "oceanvine"),
}

local prefabs =
{
    "oceanvine_patch",
    "fig",
}

local BURN_DURATION = 2

--[[
local function round(x)
  x = x *10
  local num = x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
  return num/10
end
]]
local function placegoffgrids(inst, radiusMax, prefab,tags)
    local x,y,z = inst.Transform:GetWorldPosition()
    local offgrid = false
    local inc = 1
    while offgrid == false do

        if not radiusMax then 
        	radiusMax = 12
        end
        local rad = math.random()*radiusMax
        local xdiff = math.random()*rad
        local ydiff = math.sqrt( (rad*rad) - (xdiff*xdiff))

        if math.random() > 0.5 then
        	xdiff= -xdiff
        end

        if math.random() > 0.5 then
        	ydiff= -ydiff
        end
        x = x+ xdiff
        z = z+ ydiff

        local ents = TheSim:FindEntities(x,y,z, 1, tags)
        local test = true
        for i,ent in ipairs(ents) do
            local entx,enty,entz = ent.Transform:GetWorldPosition()
           -- print("checing round x:",round(x),round(entx),"z:", round(z), round(entz),"diff:",round(math.abs(entx-x)),round( math.abs(entz-z)) )
            if round(x) == round(entx) or round(z) == round(entz) or ( math.abs(round(entx-x)) == math.abs(round(entz-z)) )  then
                test = false
         --       print("test fail")
                break
            end
        end
        
        offgrid = test
        inc = inc +1 
    end

    local tile = GetWorld().Map:GetTileAtPoint(x,y,z)
    if  tile == WORLD_TILES.DEEPRAINFOREST then
    	local plant = SpawnPrefab(prefab)
    	plant.Transform:SetPosition(x,y,z) 
    	plant.spawnpatch = inst
    	return true
	end
	return false
end

local function spawnitem(inst,prefab)
	local rad = 14
	if prefab == "grabbing_vine" then
		rad = 12
	end
	placegoffgrids(inst, rad, prefab,{"hangingvine"})
end

local function spawnvines(inst)
	inst.spawnedchildren = true
    for i=1,math.random(8,16),1 do
        spawnitem(inst,"hanging_vine")
    end	

    for i=1,math.random(6,9),1 do
    	spawnitem(inst,"grabbing_vine")
    end	   
end

local function spawnNewVine(inst,prefab)
	if not inst.spawntasks then
		inst.spawntasks = {}
	end
	local spawntime = TUNING.TOTAL_DAY_TIME*2 + (TUNING.TOTAL_DAY_TIME*math.random())
	local newtask = {}
    inst.spawntasks[newtask] = newtask
	newtask.prefab = prefab
    newtask.task, newtask.taskinfo = inst:ResumeTask(spawntime,
        function()
            spawnitem(inst,newtask.prefab)
            inst.spawntasks[newtask] = nil
        end)
    inst.spawntasks[newtask] = newtask
end

local function onsave(inst, data)
    data.spawnedchildren = inst.spawnedchildren
    if inst.spawntasks then
    	data.spawntasks= {}
    	for i,oldtask in pairs(inst.spawntasks)do
            local test = inst:DoTaskInTime(5,function()end)
            dumptable(test,1,1)

    		local newtask = {}
    		newtask.prefab = oldtask.prefab
    		newtask.time = inst:TimeRemainingInTask(oldtask.taskinfo)
            table.insert(data.spawntasks,newtask)
    	end
    end
end

local function onload(inst, data)
    if data then
        if data.spawnedchildren then
        	inst.spawnedchildren = true
        end      
        if data.spawntasks then
        	inst.spawntasks = {}
        	for i,oldtask in ipairs(data.spawntasks)do
        		local newtask = {}
                inst.spawntasks[newtask] = newtask  
        		newtask.prefab = oldtask.prefab
                newtask.task, newtask.taskinfo = inst:ResumeTask(oldtask.time,
					function()
						spawnitem(inst,oldtask.prefab) 
                        inst.spawntasks[newtask] = nil
					end)        		
        	end
        end
    end
end

local function patchfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst:DoTaskInTime(0,function() if not inst.spawnedchildren then spawnvines(inst) end end) 
    --inst:DoTaskInTime(0, function() inst:Remove() end)
    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.spawnNewVine = spawnNewVine
	return inst
end

local COCOON_TAGS = {"webbed"}
local function alert_nearby_cocoons(inst, picker, loot)
    local px, py, pz = inst.Transform:GetWorldPosition()
    local nearby_cocoons = TheSim:FindEntities(px, py, pz, TUNING.OCEANVINE_COCOON_SPIDER_RADIUS, COCOON_TAGS)
    for _, cocoon in ipairs(nearby_cocoons) do
        cocoon:PushEvent("activated", {target = picker})
    end
end

local function OnStartBurnAnim(inst)
    inst.persists = false

    if inst.components.inspectable ~= nil then
        inst:RemoveComponent("inspectable")
    end

    if inst.components.pickable ~= nil then
        inst:RemoveComponent("pickable")
    end

    inst.components.burnable:SetOnExtinguishFn(inst.Remove)

    inst.AnimState:PlayAnimation("burn")
    inst:ListenForEvent("animover", inst.Remove)

    local theta = math.random() * TWOPI
    local spd = math.random() * 2
    local ash = SpawnPrefab("ash")
    ash.Transform:SetPosition(inst:GetPosition():Get())
    ash.Physics:SetVel(math.cos(theta) * spd, 8 + math.random() * 4, math.sin(theta) * spd)
end

local function OnExtinguishNotFinishedBurning(inst)
    if inst.burn_anim_task ~= nil then
        inst.burn_anim_task:Cancel()
        inst.burn_anim_task = nil
    end
end

local function OnIgnite(inst, source, doer)
    inst.burn_anim_task = inst:DoTaskInTime(BURN_DURATION, OnStartBurnAnim)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguishNotFinishedBurning)
end

local function falldown(inst)
    inst.AnimState:PlayAnimation("spawn", false)
    inst.AnimState:PushAnimation("idle_fruit", true)
end

local function onpicked(inst, picker, loot)
    alert_nearby_cocoons(inst, picker, loot)

    inst.AnimState:PlayAnimation("harvest", false)
    inst.AnimState:PushAnimation("idle_nofruit", true)

    if inst.components.inspectable ~= nil then
        inst:RemoveComponent("inspectable")
    end
end

local function makeempty(inst)
    inst.AnimState:Hide("fig")
    inst.AnimState:PlayAnimation("idle_nofruit", true)

    if inst.components.inspectable ~= nil then
        inst:RemoveComponent("inspectable")
    end
end

local function makefull(inst)
    inst.AnimState:Show("fig")
    if POPULATING then
        inst.AnimState:PlayAnimation("idle_fruit", true)
    else
        inst.AnimState:PlayAnimation("fruit_grow", false)
        inst.AnimState:PushAnimation("idle_fruit", true)
    end

    if inst.components.inspectable == nil then
        inst:AddComponent("inspectable")
    end
end

local function onloadpostpass(inst, newents, savedata)
	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
end

local function fall(inst)
    inst.persists = false
    local point = inst:GetPosition()
    local onland = TheWorld.Map:IsVisualGroundAtPoint(point.x,point.y,point.z) or TheWorld.Map:GetPlatformAtPoint(point.x,point.z) 
    if onland then
        inst.AnimState:PlayAnimation("fall_land", false)
        inst:ListenForEvent("animover", function() ErodeAway(inst) end)
    else
        inst.AnimState:PlayAnimation("fall_ocean", false)
        inst:ListenForEvent("animover", function() inst:Remove() end)
    end
    inst:DoTaskInTime(19*FRAMES, function() 
        if inst.components.pickable ~= nil and inst.components.pickable:CanBePicked() then
            local point = inst:GetPosition()
            inst.components.pickable:MakeEmpty()
            local product = SpawnPrefab(inst.components.pickable.product)
            product.Transform:SetPosition(point.x,0,point.z)
        end
    end)

end

local function commonfn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.shadow = inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("oceanvine.png")

	inst.shadow:SetSize( 1.5, .75 )
    
	inst.AnimState:SetBank("oceanvine")
    inst.AnimState:SetBuild("oceanvine")
	inst.AnimState:PlayAnimation("idle_fruit", true)
    inst.scrapbook_anim = "idle_fruit"

	inst:AddTag("hangingvine")
    inst:AddTag("flying")
    inst:AddTag("NOBLOCK")                  -- To not block boat deployment.
    inst:AddTag("oceanvine")
--[[
    if not TheNet:IsDedicated() then
        inst:AddComponent("distancefade")
        inst.components.distancefade:Setup(15,25)
    end
    ]]

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst.source_tree = nil -- source_tree is only used to tally number of vines per watertree_pillar on loading in the world after creation, doesn't hold a saved reference after that
    inst.fall_down_fn = falldown
    -- inst.burn_anim_task = nil

	inst:AddComponent("inspectable")
    
    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
    inst.components.pickable.onpickedfn = onpicked
    inst.components.pickable.makeemptyfn = makeempty
    inst.components.pickable.makefullfn = makefull
    inst.components.pickable:SetUp("fig", TUNING.OCEANVINE_REGROW_TIME)
    inst.components.pickable.max_cycles = nil
    inst.components.pickable.cycles_left = 1

    MakeSmallBurnable(inst, nil, nil, nil, "swap_fire")
    inst.components.burnable.fxdata[1].prefab = "character_fire"
    inst.components.burnable.fxdata[1].followaschild = true
    inst.components.burnable:SetFXOffset(0, 1, 0)
    inst.components.burnable:SetBurnTime(BURN_DURATION + 5) -- 5 = a value considerably higher than the burn anim duration
    inst.components.burnable:SetOnIgniteFn(OnIgnite)
    inst.components.burnable:SetOnBurntFn(inst.Remove) -- Burning is handled differently, but if it ever gets to this point it's better to just remove the object
    MakeSmallPropagator(inst)

    MakeHauntableIgnite(inst)
    
    inst.placegoffgrids = placegoffgrids
    inst.fall = fall
    inst.OnLoadPostPass = onloadpostpass
	
	return inst
end

return Prefab("oceanvine", commonfn, assets, prefabs),
	   Prefab("oceanvine_patch", patchfn, assets, prefabs)