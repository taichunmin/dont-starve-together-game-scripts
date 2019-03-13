
function ShouldHintRecipe(recipetree, buildertree)
    for k, v in pairs(recipetree) do
        local v1 = buildertree[tostring(k)]
        if v ~= nil and v1 ~= nil and v > v1 + 1 then
            return false
        end
    end
    return true
end

function CanPrototypeRecipe(recipetree, buildertree)
    for k, v in pairs(recipetree) do
        local v1 = buildertree[tostring(k)]
        if v ~= nil and v1 ~= nil and v > v1 then
            return false
        end
    end
    return true
end

function DoRecipeClick(owner, recipe, skin)
    if skin == recipe.name then
        skin = nil
    end

    if recipe ~= nil and owner ~= nil and owner.replica.builder ~= nil then
        if owner:HasTag("busy") or owner.replica.builder:IsBusy() then
            return true
        end
        if owner.components.playercontroller ~= nil then
            local iscontrolsenabled, ishudblocking = owner.components.playercontroller:IsEnabled()
            if not (iscontrolsenabled or ishudblocking) then
                --Ignore button click when controls are disabled
                --but not just because of the HUD blocking input
                return true
            end
        end

        local knows = owner.replica.builder:KnowsRecipe(recipe.name)
        local can_build = owner.replica.builder:CanBuild(recipe.name)

        if not can_build and TheWorld.ismastersim then
            owner:PushEvent("cantbuild", { owner = owner, recipe = recipe })
            --You might have the materials now. Check again.
            can_build = owner.replica.builder:CanBuild(recipe.name)
        end

        local buffered = owner.replica.builder:IsBuildBuffered(recipe.name)

        if knows then
            if buffered then
                --TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                --owner.HUD.controls.crafttabs.tabs:DeselectAll()
                if recipe.placer == nil then
                    owner.replica.builder:MakeRecipeFromMenu(recipe, skin)
                elseif owner.components.playercontroller ~= nil then
                    owner.components.playercontroller:StartBuildPlacementMode(recipe, skin)
                end
            elseif can_build then
                --TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")           
                if recipe.placer == nil then
                    owner.replica.builder:MakeRecipeFromMenu(recipe, skin)
                    return true
                elseif owner.components.playercontroller ~= nil then
                    --owner.HUD.controls.crafttabs.tabs:DeselectAll()
                    owner.replica.builder:BufferBuild(recipe.name)
                    if not owner.replica.builder:IsBuildBuffered(recipe.name) then
                        return true
                    end
                    owner.components.playercontroller:StartBuildPlacementMode(recipe, skin)
                end
            else
                return true
            end
        else
            local tech_level = owner.replica.builder:GetTechTrees()
            if can_build and CanPrototypeRecipe(recipe.level, tech_level) then
                if recipe.placer == nil then
                    owner.replica.builder:MakeRecipeFromMenu(recipe, skin)
                    if recipe.nounlock then
                        return true
                    end
                elseif owner.components.playercontroller ~= nil then
                    owner.replica.builder:BufferBuild(recipe.name)
                    if not owner.replica.builder:IsBuildBuffered(recipe.name) then
                        return true
                    end
                    owner.components.playercontroller:StartBuildPlacementMode(recipe, skin)
                    if owner.components.builder ~= nil then
                        owner.components.builder:ActivateCurrentResearchMachine(recipe)
                        owner.components.builder:UnlockRecipe(recipe.name)
                    end
                end
                if not recipe.nounlock then
                    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/research_unlock")
                end
            else
                return true
            end
        end
    end
end