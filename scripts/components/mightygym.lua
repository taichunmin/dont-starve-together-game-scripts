local MightyGym = Class(function(self, inst)
    self.inst = inst
    self.strongman = nil

    self.weight = 0

    self.full_drop_slot = 1

    self.inst:DoTaskInTime(0,function() 
        self:CheckForWeight() 
        self:SetLevelArt(self:CalcWeight()) 
    end)
end)

local slot_ids = 
{
    "swap_item",
    "swap_item2",
}

local gym_symbols = {
    "woodenarm",
    "wooden_circles",
    "wheel",
    "slackrope",
    "machine_rope_comp",
    "platform",
    "brick",
    "board",
    "meter",
    "bellfx_art",
}

function MightyGym:SetLevelArt(level, target)
    if not target then
        target = self.inst 
    end
    if level < 2 then
        target.AnimState:HideSymbol("meter_color2")
    else
        target.AnimState:ShowSymbol("meter_color2")
        local gym_skin = target.gym_skin or target.prefab == "mighty_gym" and target.AnimState:GetSkinBuild() or nil
        if gym_skin and gym_skin ~= "" then
            target.AnimState:OverrideItemSkinSymbol("meter_color2", gym_skin, "meter_color"..level, self.inst.GUID, "mighty_gym")
        else
            target.AnimState:OverrideSymbol("meter_color2", "mighty_gym", "meter_color"..level)
        end
    end
end

function MightyGym:CalcWeight()
    local weight = 0
    local function checkforweightitem(item)
        if item:HasTag("heavy") then
            return true
        end
        return false
    end
    local inventory = self.inst.components.inventory
    local items = inventory:FindItems(checkforweightitem)

    if #items > 1 then
        for i,item in ipairs(items)do
            weight = weight + (item.gymweight or 2)
        end
    end
    self.weight = weight
    return weight
end

function MightyGym:CheckForWeight()

    if self.inst:HasTag("burnt") then
        return
    end    
    local inventory = self.inst.components.inventory
    for i=1, 2 do
        local item = inventory:GetItemInSlot(i)
        if item then
            self:SetWeightSymbol(item, i)
            self.inst:AddTag("loaded")
        end
    end    
end

local ROCK_SOUND = "wolfgang1/mightygym/marblerock_place"
local GLASS_SOUND = "wolfgang1/mightygym/moonglass_place"
local VEGGIE_SOUND = "wolfgang1/mightygym/vegetable_place"
local POTATOSACK_SOUND = "wolfgang1/mightygym/sack_place"

local MATERIAL_SOUNDS =
{
    --Rock
    ["cavein_boulder"] = ROCK_SOUND,
    ["sunkenchest"] = ROCK_SOUND,
    ["sculpture_knighthead"] = ROCK_SOUND,
    ["sculpture_bishophead"] = ROCK_SOUND,
    ["sculpture_rooknose"] = ROCK_SOUND,

    --Glass
    ["glassspike"] = GLASS_SOUND,
    ["moon_altar_idol"] = GLASS_SOUND,
    ["moon_altar_seed"] = GLASS_SOUND,
    ["moon_altar_glass"] = GLASS_SOUND,

    --Veggie
    ["oceantreenut"] = VEGGIE_SOUND,
    ["shell_cluster"] = VEGGIE_SOUND,

    -- Potato sack
    ["potatosack"] = POTATOSACK_SOUND,
}

local function kickoffgym(inst, owner)
    local gym = inst.components.inventoryitem:GetContainer()
    if gym then
        gym.inst.components.mightygym:UnloadWeight()
    end
end

function MightyGym:SwapWeight(item,swapitem)
    local slot = self.inst.components.inventory:GetItemSlot(item)
    self.inst.components.mightygym:LoadWeight(swapitem, slot)
end

function MightyGym:SetWeightSymbol(weight, slot)
    if weight.components.symbolswapdata ~= nil then
        if weight.components.symbolswapdata.is_skinned then
            self.inst.AnimState:OverrideItemSkinSymbol(slot_ids[slot], weight.components.symbolswapdata.build, weight.components.symbolswapdata.symbol, weight.GUID, "swap_cavein_boulder" ) --default should never be used
        else
            self.inst.sg:GoToState("place_weight",{slot=slot})
            self.inst.AnimState:OverrideSymbol(slot_ids[slot], weight.components.symbolswapdata.build, weight.components.symbolswapdata.symbol)
        end
        if self.strongman then
            if weight.components.symbolswapdata.is_skinned then
                self.inst.AnimState:OverrideItemSkinSymbol(slot_ids[slot], weight.components.symbolswapdata.build, weight.components.symbolswapdata.symbol, weight.GUID, "swap_cavein_boulder" ) --default should never be used
            else
                self.strongman.AnimState:OverrideSymbol(slot_ids[slot], weight.components.symbolswapdata.build, weight.components.symbolswapdata.symbol)
            end
        end
    end

end

function MightyGym:LoadWeight(weight, slot)
    local inventory = self.inst.components.inventory
    local selectedslot = nil
    if inventory:IsFull() and not slot then
        inventory:DropItem(inventory:GetItemInSlot(self.full_drop_slot))
        self.inst.SoundEmitter:PlaySound("wolfgang1/mightygym/item_removed")

        inventory:GiveItem(weight)

        selectedslot = self.full_drop_slot
        self.full_drop_slot = self.full_drop_slot == 1 and 2 or 1
    else
        selectedslot = inventory:GiveItem(weight,slot)
        if slot then
            selectedslot = slot
        end
    end

    self:SetWeightSymbol(weight, selectedslot)
    
    self.inst:AddTag("loaded")

    local sound = POTATOSACK_SOUND
    if weight.materialid ~= nil then
        if weight.materialid == 1 or weight.materialid == 2 then
            sound = ROCK_SOUND
        else
            sound = GLASS_SOUND
        end
    elseif weight:HasTag("oversized_veggie") then
        sound = VEGGIE_SOUND
    elseif MATERIAL_SOUNDS[weight.prefab] ~= nil then
        sound = MATERIAL_SOUNDS[weight.prefab]
    end

    self.inst.SoundEmitter:PlaySound(sound)
    self:SetLevelArt(self:CalcWeight())
    if self.strongman then    
        local newweight = self:CalcWeight()
        self.strongman.player_classified.inmightygym:set(math.max(0,newweight-1))    
        self:SetLevelArt(newweight, self.strongman)
    end
end

local function checkforweightitem(item)
    if item:HasTag("heavy") then
        return true
    end
    return false
end

function MightyGym:UnloadWeight()

    self.inst.components.inventory:DropEverything()
    self.inst.AnimState:ClearOverrideSymbol("swap_item")
    self.inst.AnimState:ClearOverrideSymbol("swap_item2")
    self.full_drop_slot = 1
    self.inst:RemoveTag("loaded")

    self.inst.SoundEmitter:PlaySound("wolfgang1/mightygym/item_removed")

    self:SetLevelArt(self:CalcWeight(), self.strongman)
end

function MightyGym:CanWorkout(doer)

    if not doer:HasTag("strongman") or not doer.components.mightiness then
        return false -- should not have gottn here, no need for a message
    elseif self.inst.components.burnable and self.inst.components.burnable:IsBurning() then
        return false, "ONFIRE" 
    elseif  self.inst.components.burnable and self.inst.components.burnable:IsSmoldering() then
        return false, "SMOULDER"    
    elseif self.strongman ~= nil then
        return false, "FULL"
    elseif doer.components.hunger.current < TUNING.CALORIES_SMALL then
        return false, "HUNGRY"
    end

    local items = 0
    for i=1, 2 do
        local inventory = self.inst.components.inventory
        local item = inventory:GetItemInSlot(i)
        if item then
            items = items + 1
        end
    end
    if items == 0 then
        return false, "NOWEIGHT"
    elseif items < 2 then
        return false, "UNBALANCED"
    end

    return  true
end

function MightyGym:CalculateMightiness(perfect)

    local might = TUNING.GYM_RATE.LOW
    if perfect then
        might =  TUNING.GYM_RATE.MED
    end        
    local weight = self:CalcWeight()
    if weight >= 7 then
        might =  TUNING.GYM_RATE.MED
        if perfect then
            might = TUNING.GYM_RATE.HIGH
        end
    end
    return might
end

function MightyGym:SetSkinModeOnGym(doer, skin_mode)
    local base_skin = self.skin_base_data[skin_mode] or doer.prefab
    SetSkinsOnAnim( self.inst.AnimState, doer.prefab, base_skin, self.skins, self.monkey_curse, skin_mode )
end

function MightyGym:StartWorkout(doer)
    if self.strongman == nil and doer.gym == nil then
        self.strongman = doer
        self.strongman.gym = self.inst
        self.strongman.components.strongman:DoWorkout(self.inst)
        
        local hunger_level = self.weight > 6 and TUNING.MIGHTYGYM_WORKOUT_HUNGER.HIGH
							or self.weight > 3 and TUNING.MIGHTYGYM_WORKOUT_HUNGER.MED
							or TUNING.MIGHTYGYM_WORKOUT_HUNGER.LOW
		
        self.strongman.components.hunger.burnratemodifiers:SetModifier(self.inst, hunger_level)
        
        self.skins = doer.components.skinner:GetClothing()
        self.monkey_curse = doer.components.skinner:GetMonkeyCurse()
        self.inst.AnimState:AssignItemSkins(doer.userid, self.skins.base or "", self.skins.body or "", self.skins.hand or "", self.skins.legs or "", self.skins.feet or "")
        
        self.skin_base_data = {}
		local skin_prefab = Prefabs[self.skins.base] or nil
		if skin_prefab and skin_prefab.skins then
            self.skin_base_data = skin_prefab.skins
		end
        self:SetSkinModeOnGym(doer, doer.components.mightiness:GetSkinMode())
        self.inst:AddTag("hasstrongman")
    end
end

function MightyGym:StopWorkout()
    if self.strongman.gym_skin and self.strongman.gym_skin ~= "" then
        self.inst.AnimState:SetSkin(self.strongman.gym_skin, "mighty_gym")
    else
        self.inst.AnimState:SetBuild("mighty_gym")
    end
    self.strongman.components.strongman:StopWorkout()
    self.strongman.components.hunger.burnratemodifiers:RemoveModifier(self.inst)
    self.strongman.gym_skin = nil
    self.strongman = nil
    self.inst:RemoveTag("hasstrongman")
end

function MightyGym:InUse()
    return self.strongman ~= nil
end

local function onstopworkout(inst, data)
    inst.gym.sg:GoToState("workout_pst", data.mightiness)
end

local function trytoexitgym(player)
    local gym = player.components.strongman and player.components.strongman.gym 
    if gym then
        gym.components.mightygym:CharacterExitGym(player)
    end
end

function MightyGym:CharacterEnterGym(player)
    player.gym_skin = self.inst.AnimState:GetSkinBuild()
    -- HIDE THE REAL GYM
    self.inst:Hide()
    if self.inst.Physics then
        self.inst.Physics:SetActive(false)
    end
    self.inst:AddTag("fireimmune")
    self.inst.enterdirection = player.Transform:GetRotation()
    -- SWAP THE PLAYER
    player:ApplyAnimScale("mightiness", 1)

    if player.gym_skin and player.gym_skin ~= "" then
        for _, symbol in ipairs(gym_symbols) do
            player.AnimState:OverrideItemSkinSymbol(symbol, player.gym_skin, symbol, self.inst.GUID, "mighty_gym")
        end
    else
        player.AnimState:AddOverrideBuild("mighty_gym")
    end
    player.AnimState:AddOverrideBuild("fx_wolfgang")

    local x,y,z = self.inst.Transform:GetWorldPosition()
	player.Physics:Teleport(x, y, z)

    player.sg:GoToState("mighty_gym_active_pre")
    
    self.inst:ListenForEvent("onremove",trytoexitgym,player)
    self.inst:ListenForEvent("attacked", trytoexitgym, player)

    player:ListenForEvent("stopworkout",onstopworkout)
    if player.Physics ~= nil then
        ChangeToObstaclePhysics(player, 1)
    end

    if player.DynamicShadow ~= nil then
        player.DynamicShadow:Enable(false)
    end 

    -- UPDATE THE WEIGHT ART.
    local function doitemswap(inventory,slot)
        local item = inventory:GetItemInSlot(slot)
        if item.components.symbolswapdata.is_skinned then
            player.AnimState:OverrideItemSkinSymbol(slot_ids[slot], item.components.symbolswapdata.build, item.components.symbolswapdata.symbol, item.GUID, "swap_cavein_boulder" )     
        else
            player.AnimState:OverrideSymbol(slot_ids[slot],  item.components.symbolswapdata.build, item.components.symbolswapdata.symbol)
        end
    end

    doitemswap(self.inst.components.inventory,1)
    doitemswap(self.inst.components.inventory,2)

	if player.SetGymStartState ~= nil then
	    player:SetGymStartState()
	end
    player.player_classified.inmightygym:set(math.max(0,self.weight-1))
    self:SetLevelArt(self.weight, player)

    self:StartWorkout(player)
end

local function saywisecrack(player)
    if player.components.mightiness then
        local state = string.upper(player.components.mightiness:GetState())
        player.components.talker:Say(GetString(player, "ANNOUNCE_EXITGYM", state))
    end
end

function MightyGym:CharacterExitGym(player)
    self.inst:RemoveEventCallback("onremove",trytoexitgym,player)
    self.inst:RemoveEventCallback("attacked", trytoexitgym, player)

    local pos = Vector3(player.Transform:GetWorldPosition())
    --BRING REAL GYM BACK
    self.inst:Show()
    if self.inst.Physics then
        self.inst.Physics:SetActive(true)
    end
    self.inst:RemoveTag("fireimmune")
    self.inst.sg:GoToState("workout_pst", player.components.mightiness:GetPercent())
    self.inst.AnimState:SetFinalOffset(-1)


    local theta = self.inst.enterdirection and (self.inst.enterdirection *DEGREES)-PI or math.random() * TWOPI
    local offset = FindWalkableOffset(pos, theta, 3, 16, true, nil, nil, false, true) or Vector3(0,0,0)
    local teleport = false

    if player.SetGymStopState ~= nil then
        player:SetGymStopState()
    end

    -- JUMP OUT PLAYER
    if player.components.health:IsDead() then
        teleport = true
    else
        if player.gym_skin and player.gym_skin ~= "" then
            for _, symbol in ipairs(gym_symbols) do
                player.AnimState:ClearOverrideSymbol(symbol)
            end
        else
            player.AnimState:ClearOverrideBuild("mighty_gym")
        end
        player.AnimState:ClearOverrideBuild("fx_wolfgang")  
        
        player:ApplyAnimScale("mightiness", player.components.mightiness:GetScale())

        if player.Physics then
            ChangeToCharacterPhysics(player, 75, .5)
            player.Physics:SetActive(true)
        end
        if player.DynamicShadow ~= nil then
            player.DynamicShadow:Enable(true)
        end
            
        player:FacePoint(pos.x+offset.x,0,pos.z+offset.z)

        if (player.components.freezable and player.components.freezable:IsFrozen()) or (player.components.sleeper and not player.components.sleeper:IsAsleep()) or (player.components.grogginess and player.components.grogginess.knockedout) then 
            teleport = true
        else
            player.sg.statemem.dontleavegym = true -- this is pretty confusing but basically, setting this true means that the gym wont auto try to run CharcterExitGym (THIS VERY FUNCTION) again.
            player.sg:GoToState("jumpout")
            player.sg:AddStateTag("nointerrupt") -- Make the player treat this like a dismounting action.
            player.AnimState:SetFrame(4)
            player:DoTaskInTime(0.3, saywisecrack)
            player.Transform:SetPosition(pos.x,pos.y,pos.z)
        end    
    end

    player.SoundEmitter:KillSound("workout_LP")
    player.player_classified.inmightygym:set(0)

    if teleport then 
        player.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
    end

    self:StopWorkout()

    player.gym = nil
    player:RemoveEventCallback("stopworkout",onstopworkout)
end

return MightyGym