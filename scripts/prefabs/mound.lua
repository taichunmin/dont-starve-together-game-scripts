local assets =
{
    Asset("ANIM", "anim/gravestones.zip"),
}

local prefabs =
{
    "ghost",
    "amulet",
    "redgem",
    "gears",
    "bluegem",
    "nightmarefuel",
	"bat",
	"cookingrecipecard",
    "scrapbook_page",
}

for k = 1, NUM_TRINKETS do
    table.insert(prefabs, "trinket_"..tostring(k))
end
for k = 1, NUM_HALLOWEEN_ORNAMENTS do
    table.insert(prefabs, "halloween_ornament_"..tostring(k))
end


local LOOTS =
{
    nightmarefuel = 1,
    amulet = 1,
    gears = 1,
    redgem = 5,
    bluegem = 5,    
}

local function ReturnChildren(inst)
    local toremove = {}
    for k, v in pairs(inst.components.childspawner.childrenoutside) do
        table.insert(toremove, v)
    end
    for i, v in ipairs(toremove) do
        if v:IsAsleep() then
            v:PushEvent("detachchild")
            v:Remove()
        else
            v.components.health:Kill()
        end
    end
end

local function spawnghost(inst, chance)
    if inst.ghost == nil and math.random() <= (chance or 1) then
        inst.ghost = SpawnPrefab("ghost")
        if inst.ghost ~= nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            inst.ghost.Transform:SetPosition(x - .3, y, z - .3)
            inst:ListenForEvent("onremove", function() inst.ghost = nil end, inst.ghost)
            return true
        end
    end
    return false
end

local function onfinishcallback(inst, worker)
    inst.AnimState:PlayAnimation("dug")
    inst:RemoveComponent("workable")

    if worker ~= nil then
        if worker.components.sanity ~= nil then
            worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
        end
        if not spawnghost(inst, inst.ghost_of_a_chance) then
            local item = math.random() < .5 and PickRandomTrinket() or weighted_random_choice(LOOTS) or nil
            if item ~= nil then
                inst.components.lootdropper:SpawnLootPrefab(item)
            end

			if math.random() < TUNING.COOKINGRECIPECARD_GRAVESTONE_CHANCE then
                inst.components.lootdropper:SpawnLootPrefab("cookingrecipecard")
			end

            if math.random() < TUNING.SCRAPBOOK_PAGE_GRAVESTONE_CHANCE then
                inst.components.lootdropper:SpawnLootPrefab("scrapbook_page")
            end

			if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
				local ornament = math.random(NUM_HALLOWEEN_ORNAMENTS * 4)
				if ornament <= NUM_HALLOWEEN_ORNAMENTS then
	                inst.components.lootdropper:SpawnLootPrefab("halloween_ornament_"..tostring(ornament))
				end
				if TheWorld.components.specialeventsetup ~= nil then
					if math.random() < TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance then
						local num_bats = 3
						for i = 1, num_bats do
							inst:DoTaskInTime(0.2 * i + math.random() * 0.3, function()
								local bat = SpawnPrefab("bat")
								local pos = FindNearbyLand(inst:GetPosition(), 3)
								bat.Transform:SetPosition(pos:Get())
								bat:PushEvent("fly_back")
							end)
						end

						TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance = 0
					else
						TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance = TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance + 0.1 + (math.random() * 0.1)
					end
				end
			end
		else
			if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
                inst.components.lootdropper:SpawnLootPrefab("halloween_ornament_1") -- ghost
			end
        end
    end
end

local function onfullmoon(inst, isfullmoon)
    if isfullmoon then
        inst.components.childspawner:StartSpawning()
        inst.components.childspawner:StopRegen()
    else
        inst.components.childspawner:StopSpawning()
        inst.components.childspawner:StartRegen()
        ReturnChildren(inst)
    end
end

local function GetStatus(inst)
    if not inst.components.workable then
        return "DUG"
    end
end

local function OnSave(inst, data)
    if inst.components.workable == nil then
        data.dug = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.dug or inst.components.workable == nil then
        inst:RemoveComponent("workable")
        inst.AnimState:PlayAnimation("dug")
    end
end

local function OnHaunt(inst, haunter)
    --#HAUNTFIX
    --return spawnghost(inst, TUNING.HAUNT_CHANCE_HALF)
    return true
end

local function oninit(inst)
    inst:WatchWorldState("isfullmoon", onfullmoon)
    onfullmoon(inst, TheWorld.state.isfullmoon)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gravestone")
    inst.AnimState:SetBuild("gravestones")
    inst.AnimState:PlayAnimation("gravedirt")

    inst:AddTag("grave")
	inst:AddTag("buried")

    inst.scrapbook_anim = "gravedirt"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst:AddComponent("lootdropper")

    inst.components.workable:SetOnFinishCallback(onfinishcallback)

    inst.ghost = nil
    inst.ghost_of_a_chance = 0.1

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "ghost"
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:SetSpawnPeriod(10, 3)

    inst:DoTaskInTime(0, oninit)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("mound", fn, assets, prefabs)
