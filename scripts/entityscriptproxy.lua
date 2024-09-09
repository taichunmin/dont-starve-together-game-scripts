local ProxyClasses = {}

local function __index(t, k)
	return getmetatable(t)[k] or rawget(t, "_")[k]
end

local function __newindex(t, k, v)
	rawget(t, "_")[k] = v
end

local function __eq(a, b)
	return rawequal(rawget(a, "_") or a, rawget(b, "_") or b)
end

function ProxyClass(class, ctor)
	local proxy_class = ProxyClasses[class]
	if proxy_class == nil then
		local count = 0
		local function __gc()
			if count > 1 then
				count = count - 1
			else
				count = 0
				class.__eq = nil
			end
		end
		proxy_class = Class(class, function(self, obj)
			rawset(self, "_", obj:is_a(proxy_class) and rawget(obj, "_") or obj)

			--Keep track of how many proxies there are;
			--Override the base class __eq operator, but only when actually needed.
			if count > 0 then
				count = count + 1
			else
				count = 1
				class.__eq = __eq
			end

			--Using newproxy to generate blank userdata, since __gc doesn't work on tables.
			--In later versions of LUA, newproxy is removed, and __gc works with tables.
			local prox = newproxy(true)
			getmetatable(prox).__gc = __gc
			rawset(self, prox, true)

			if ctor then
				ctor(self)
			end
		end)
		proxy_class.__index = __index
		proxy_class.__newindex = __newindex
		proxy_class.__eq = __eq
		proxy_class.SetProxyProperty = rawset
		ProxyClasses[class] = proxy_class
	end
	return proxy_class
end

function ProxyInstance(obj)
	return ProxyClass(getmetatable(obj))(obj)
end

local components_proxy_mt =
{
	__index = function(t, k)
		local cmp = rawget(t, "_")[k]
		if cmp then
			local proxy_cmp = rawget(t, cmp)
			if proxy_cmp == nil then
				proxy_cmp = ProxyInstance(cmp)
				proxy_cmp:SetProxyProperty("inst", rawget(t, "inst"))
				rawset(t, cmp, proxy_cmp)
			end
			return proxy_cmp
		end
	end,
	__newindex = function(t, k, v)
		rawget(t, "_")[k] = v
	end,
}

EntityScriptProxy = ProxyClass(EntityScript, function(self)
	--Override components/replica so that their .inst returns this proxy as well

	local components_proxy = { _ = self.components, inst = self }
	setmetatable(components_proxy, components_proxy_mt)
	rawset(self, "components", components_proxy)

	local replica_proxy = { _ = self.replica, inst = self }
	setmetatable(replica_proxy, components_proxy_mt)
	rawset(self, "replica", replica_proxy)
end)
