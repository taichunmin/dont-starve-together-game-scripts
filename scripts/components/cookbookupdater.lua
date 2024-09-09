local function onplayeractivated(inst)
	local self = inst.components.cookbookupdater
	if not TheNet:IsDedicated() and inst == ThePlayer then
		self.cookbook = TheCookbook
		self.cookbook.save_enabled = true
	end
end

local CookbookUpdater = Class(function(self, inst)
    self.inst = inst

	self.cookbook = require("cookbookdata")()
	inst:ListenForEvent("playeractivated", onplayeractivated)
end)

function CookbookUpdater:LearnRecipe(product, ingredients)
	if product ~= nil and ingredients ~= nil then
		local updated = self.cookbook:AddRecipe(product, ingredients)
		--print("CookbookUpdater:LearnRecipe", product, updated, unppack(ingredients))

		-- Servers will only tell the clients if this is a new recipe in this world
		-- Since the servers do not know the client's actual cookbook data, this is the best we can do for reducing the amount of data sent
		if updated and (TheNet:IsDedicated() or (TheWorld.ismastersim and self.inst ~= ThePlayer)) and self.inst.userid then
			--can't send tables via rpc, so unpack the table before sending.
			SendRPCToClient(CLIENT_RPC.LearnRecipe, self.inst.userid, product, unpack(ingredients))
		end
	end
end

function CookbookUpdater:LearnFoodStats(product)
	local updated = self.cookbook:LearnFoodStats(product)
	--print("CookbookUpdater:LearnFoodStats", product, updated)

	-- Servers will only tell the clients if this is a new recipe in this world
	-- Since the servers do not know the client's actual cookbook data, this is the best we can do for reducing the amount of data sent
	if updated and (TheNet:IsDedicated() or (TheWorld.ismastersim and self.inst ~= ThePlayer)) and self.inst.userid then
		SendRPCToClient(CLIENT_RPC.LearnFoodStats, self.inst.userid, product)
	end
end


return CookbookUpdater