# Notifitable

_Lua tables that notify you when values have changed._

The Notifitable library exposes a single function that creates or wraps
a Lua table. The resulting table has a `registerForChange()` method
that lets you specify one or more callbacks to invoke when certain
keys in the table get a new value.

## Simple Usage

```lua
function yellOnValueChanges(key,newval,oldval)
  print("The key", key, "just changed from", oldval, "to", newval)
end

local notifitable = require('notifitable')
local t1 = notifitable()
t1:registerForChange( 'foo', yellOnValueChange )

t1.foo = 42 --> "The key foo just changed from nil to 42"
t1.foo = 42 --> (no callback for same value)
t1.bar = 99 --> (no callback for non-registered keys)
t1.foo = 17 --> "The key foo just changed from 42 to 17"
```

## Wrapping an Existing Table
If you already have a table of information that you want to monitor, pass it to the function:

```lua
local prefs = {
  theme = 'dismal',
  socks = false
}
local t2 = notifitable(prefs)
t2:registerForChange( 'theme', yellOnValueChange )
t2.theme = 'bright'           --> "The key theme just changed from dismal to bright"
assert(prefs.theme=='bright') --> The original table is updated…
prefs.theme = "don't do this" --> …but changes to it do not causes notifications
```

## Registering in a Hierarchy
If you have a hierarchy of values you may register for a specific key deep in the chain:

```lua
local prefs = notifitable{
  settings = {
    editor = {
      usetabs = true,
      tabsize = 2
    }
  }
}

prefs:registerForChange('settings','editor','usetabs',onTabsChanged)
```

Internally this replaces each table in the hierarchy with a notifitable wrapper.

## Autovivification

You can register for an access path that does not already exist:

```lua
local t3 = notifitable() -- an empty table
t3:registerForChange('settings','editor','usetabs',someFunction)
```

The implementation of this creates notifitable values along the path to that final function. (It might be nice if this was super lightweight, only taking effect if at some point in the future that path was created. This is not the current situation.)

## Running Into Trouble

Under happy circumstances the `registerForChange()` method returns `true`. However, if you attempt to register for a hierarchical value, but one of the keys in that path exists and is **not** a table, the `registerForChange()` method will fail and return `nil` instead. This is your only indication that the registration could not be accomplished.

```lua
local t4 = notifitable{ settings='rainbows' }
local success = t4:registerForChange('settings','editor','usetabs',someFunction)
assert(success) --> FAIL
```

# Removing a Registration
If you have a callback that you no longer wish to have invoked, there is an equivalent `unregisterForChange()` method on the notifitable.

```lua
t:registerForChange('settings','editor','usetabs',someFunction)
-- and then later
t:registerForChange('settings','editor','usetabs',someFunction)
```

_Note that this does not 'unwrap' any notifitables along the path that might no longer be needed for registration._

# Limitations (aka TODO)

* It would be nice to be able to perform wildcard registrations at a particular level.
* It would be nice to not autovivify the full path to a registration, but instead use a lightweight hook.
* It might be nice to not wrap a table (in order to use `__newindex` as the hook), but instead require a setter function that took the path and also kicked off notifications on an otherwise-normal table.
* For simplicity, the order in which callbacks are invoked for the same key is not specified. It might be nice to allow control over this (i.e. first registered is the first invoked).
* There's no reason to wrap every table on the path down a hierarchy as a notifitable; only the last table in the list needs to support registration.

# License

Notifitable is licensed under the MIT License.
See the file LICENSE for details.
