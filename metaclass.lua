--needed due to a quirk with garbage collection, otherwise the metatable could be collected before the userdata, causing a crash.
local metatable_refs = setmetatable({}, {__mode = "k"})

local metafunctions = {
    --replaces index behavior obj[key] or obj.key
    __index = function(t, k)
        local mt = getmetatable(t)
        local c = mt.c
        local __index = mt._.__index or c.__index
        if __index then
            if type(__index) == "function" then
                return __index(t, k)
            else
                return __index[k]
            end
        else
            return mt._[k] or c[k]
        end
    end,
    --replaces setting behavior obj[key] = value
    __newindex = function(t, k, v)
        local mt = getmetatable(t)
        local __newindex = mt._.__newindex or mt.c.__newindex
        if __newindex then
            __newindex(t, k, v)
        else
            mt._[k] = v
        end
    end,
    --replaces #obj behavior (length of table)
    __len = function(t)
        local mt = getmetatable(t)
        local __len = mt._.__len or mt.c.__len
        if __len and not mt._insidelen then
            mt._insidelen = true
            local result = __len(t)
            mt._insidelen = false
            return result
        else
            return #mt._
        end
    end,
    --replaces next
    __next = function(t, k)
        local mt = getmetatable(t)
        local __next = mt._.__next or mt.c.__next
        if __next then
            return __next(t, k)
        else
            return next(mt._, k)
        end
    end,
    --replaces pairs
    __pairs = function(t)
        local mt = getmetatable(t)
        local __pairs = mt._.__pairs or mt.c.__pairs
        if __pairs then
            return __pairs(t)
        else
            return pairs(mt._)
        end
    end,
    --replaces ipairs
    __ipairs = function(t)
        local mt = getmetatable(t)
        local __ipairs = mt._.__ipairs or mt.c.__ipairs
        if __ipairs then
            return __ipairs(t)
        else
            return ipairs(mt._)
        end
    end,
    --called when garbage collecting this.
    __gc = function(t)
        local mt = getmetatable(t)
        local __gc = mt._.__gc or mt.c.__gc
        if __gc then
            return __gc(t)
        end
    end,
    __eq = function(t, o)
        local mt = getmetatable(t)
        local __eq = mt._.__eq or mt.c.__eq
        if __eq then
            return __eq(t, o)
        else
            return mt._ == getmetatable(o)._
        end
    end,
    --the following code won't normally be hit unless you intentionally run these opperations, as such no nil checking on the metafunctions
    __lt = function(t, ...)
        return metarawget(t, "__lt")(t, ...)
    end,
    __le = function(t, ...)
        return metarawget(t, "__le")(t, ...)
    end,
    __add = function(t, ...)
        return metarawget(t, "__add")(t, ...)
    end,
    __sub = function(t, ...)
        return metarawget(t, "__sub")(t, ...)
    end,
    __mul = function(t, ...)
        return metarawget(t, "__mul")(t, ...)
    end,
    __div = function(t, ...)
        return metarawget(t, "__div")(t, ...)
    end,
    __mod = function(t, ...)
        return metarawget(t, "__mod")(t, ...)
    end,
    __pow = function(t, ...)
        return metarawget(t, "__pow")(t, ...)
    end,
    __unm = function(t, ...)
        return metarawget(t, "__unm")(t, ...)
    end,
    __call = function(t, ...)
        return metarawget(t, "__call")(t, ...)
    end,
    __concat = function(t, ...)
        return metarawget(t, "__concat")(t, ...)
    end,
}

--like class, but uses a userdata object as its base instead of a table, allows replacement of __gc and __len functions that way.
--make sure to use meta* versions of functions with it, like metapairs, metanext, metaipairs, metarawget, metarawset ect.
function MetaClass(base, _ctor)
    local c = {}

	if not _ctor and type(base) == 'function' then
        _ctor = base
        base = nil
    elseif type(base) == 'table' then
        for i,v in pairs(base) do
            c[i] = v
        end
        c._base = base
    end
    -- expose a constructor which can be called by <classname>(<args>)
    local mt = {}

    mt.__call = function(class_tbl, ...)
        local obj = newproxy(true)
        local objmt = getmetatable(obj)
        metatable_refs[obj] = objmt
        objmt._ = {}
        objmt.c = c
        for k, v in pairs(metafunctions) do
            objmt[k] = v
        end

        if c._ctor then
            c._ctor(obj, ...)
        end

        return obj
    end

    c._ctor = _ctor
    c.is_a = function(self, klass)
        local m = getmetatable(self).c
        while m do
            if m == klass then return true end
            m = m._base
        end
        return false
    end
    setmetatable(c, mt)

    return c
end