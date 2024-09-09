local weighted_list = Class(function(self, t)
	self._totalWeight = 0

	if t then
        if #t > 0 and type(t[1]) == "table" then
            -- { { choice1, weight1 }, { choice2, weight2 }, ... }
		    for i, choice in ipairs(t) do
			    self:addChoice( choice[1], choice[2] )
		    end
        else
            -- { [choice1] = weight1, [choice2] = weight2, ... }
            for choice, weight in pairs(t) do
                self:addChoice( choice, weight )
            end
        end
	end
end)

function weighted_list:getTotalWeight()
	return self._totalWeight
end

function weighted_list:getCount()
	return #self / 2
end

function weighted_list:addChoice( item, weight )
	assert( weight > 0 )
	table.insert( self, weight )
	table.insert( self, item )
	self._totalWeight = self._totalWeight + weight
end

function weighted_list:addList( list )
	self._totalWeight = list:getTotalWeight() + self:getTotalWeight()
	for i, item in ipairs(list)do
		table.insert(self,item)
	end
end

function weighted_list:getChoice( weight )
	for i = 1, #self, 2 do
		weight = weight - self[i]
		if weight <= 0 then
			return self[i + 1], i
		end
	end

	return nil
end

function weighted_list:removeChoice( weight )
	local item, index = self:getChoice( weight )
	local weight
	if item then
		weight = self[ index ]
		self._totalWeight = self._totalWeight - weight
		table.remove( self, index )
		table.remove( self, index )
	end
	return item, weight
end

function weighted_list:removeHighest( )
	local maxWeight, maxIndex = 0, 0
	for i = 1, #self, 2 do
		if self[ i ] > maxWeight then
			maxWeight, maxIndex = self[ i ], i
		end
	end
	if maxIndex > 0 then
		self._totalWeight = self._totalWeight - maxWeight
		table.remove( self, maxIndex )
		return table.remove( self, maxIndex ), maxWeight
	end
end

function weighted_list:print()
    local str = {}
    for i = 1, #self, 2 do
        table.insert( str, string.format( "%d] - %3d wt, %s\n", i, self[i], tostring(self[i+1]) ))
    end
    return table.concat( str )
end

return weighted_list
