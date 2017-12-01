--V2C: TODO: work
--     Keep this file up to date with luanetworkvariable.cpp
--[[

    net_bool                1-bit boolean
    net_tinybyte            3-bit unsigned integer   [0..7]
    net_smallbyte           6-bit unsigned integer   [0..63]
    net_byte                8-bit unsigned integer   [0..255]
    net_shortint            16-bit signed integer    [-32767..32767]
    net_ushortint           16-bit unsigned integer  [0..65535]
    net_int                 32-bit signed integer    [-2147483647..2147483647]
    net_uint                32-bit unsigned integer  [0..4294967295]
    net_float               32-bit float
    net_hash                32-bit hash of the string assigned
    net_string              variable length string
    net_entity              entity instance
    net_bytearray           array of 8-bit unsigned integers (max size = 31)
    net_smallbytearray      array of 6-bit unsigned integers (max size = 31)

    * Arrays are expensive.  Avoid using them, especially if the values
      will change often.

    * net_hash can be set by a hash or string (automatically converted to
      hash), but only returns the hash value when read.  The network cost
      is the same as a 32-bit unsigned integer.

    * netvars must exist and be declared identically on server and clients
      for each entity, otherwise entity deserialization will fail.  Note
      that this means if a MOD uses netvars, then server and clients must
      all have the same MOD active.

    * Server and clients may register different listeners for dirty events.

    * netvar dirty events are triggered before lua update.

--]]

----------------------------------------------------------------------------

--[[

    netvar:set(x)
    - Call on the server to set the value, which will be synced to clients.
    - Dirty event is triggered on server and clients (only if value has
      actually changed).

    netvar:value()
    - Call on the server or clients to read the current value.

    netvar:set_local(x)
    - Call on the server or clients to set the value without triggering
      a sync or dirty event.
    - NOTE: this results in the next server set(x) to be dirty regardless
            of whether the value changed, since we assume the client may
            have set_local(x) to any arbitrary value.

    * set_local is generally used in code paths shared between server and
      clients.  Clients may have enough information (such as elapsed time)
      to estimate and update the value locally.  Sharing the code path also
      allows the server to be aware that the value is being updated locally
      on clients.

    * Example usage of set_local(x) is to let clients update smooth timer
      ticks locally.  Server saves bandwidth by only needing set(x) to
      force a resync every now and then.

--]]

----------------------------------------------------------------------------

--[[

    net_event (as a wrapper over net_bool)
    net_event:push()

    * Use events for one-shot triggers such as a sound FX, but not state
      changes (which should use net_bool instead).

--]]

require("class")

net_event = Class(function(self, guid, event)
    self._bool = net_bool(guid, event, event)
end)

function net_event:push()
    self._bool:set_local(true)
    self._bool:set(true)
end